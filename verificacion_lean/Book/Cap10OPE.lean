import Mathlib

/-!
# Book.Cap10OPE — cap. 7 del libro (`capitulos/cap07_ope.typ`): pendientes de ch10

Formalización finita de las claves pendientes de OPE:

* `prop:ch10-dm` — sesgo y varianza del método directo.
* `cor:ch10-curse` — el tamaño muestral que mantiene el error estándar fijo
  crece en el mismo orden que la varianza por trayectoria.
* `prop:ch10-is-shift` — cambio de población inicial: `J_* = EE_b(u(S_0) W G)`.
* `prop:ch10-dro-garantia` — cobertura de la cota robusta por ínfimo.
* `thm:ch10-truncamiento` — sesgo y varianza del estimador truncado.
* `thm:ch10-dr-eficiencia` — linealidad exacta y varianza de la función de
  influencia del DR de una decisión.
* `ex:ssch-dist-shift-cap10`, `ex:ch10-shift-ssch`, `ex:ssch-cap10`,
  `ex:ch10-pipeline` — los ejemplos numéricos del libro.

Fidelidad declarada: el libro trabaja con una ley de episodios y esperanzas
generales; aquí la ley es un peso `w : Ω → ℝ` sobre un tipo finito `Ω`
(`w ≥ 0`, `∑ w = 1`) y las esperanzas son sumas finitas. Los episodios iid se
modelan por variables con covarianza nula fuera de la diagonal y varianza
común (`var_mean_of_uncorrelated`), que es el contenido de «episodios iid»
usado en el libro para dividir por `n`. La esperanza condicional
`EE[ρ | S, A] = 0` se codifica, equivalente y sin versiones regulares, como
ortogonalidad de `ρ` frente a toda función de `(S, A)`.
-/

open Finset BigOperators

namespace Book.Cap10OPE

/-! ## Ley finita, esperanza, varianza y covarianza -/

section Base

variable {Ω : Type*} [Fintype Ω]

/-- Esperanza bajo el peso `w`. -/
noncomputable def Expect (w : Ω → ℝ) (f : Ω → ℝ) : ℝ := ∑ ω, w ω * f ω

/-- Varianza bajo el peso `w`. -/
noncomputable def Var (w : Ω → ℝ) (f : Ω → ℝ) : ℝ :=
  Expect w fun ω => (f ω - Expect w f) ^ 2

/-- Covarianza bajo el peso `w`. -/
noncomputable def Cov (w : Ω → ℝ) (f g : Ω → ℝ) : ℝ :=
  Expect w fun ω => (f ω - Expect w f) * (g ω - Expect w g)

variable {w : Ω → ℝ}

theorem Expect_const (c : ℝ) : Expect w (fun _ => c) = (∑ ω, w ω) * c := by
  simp [Expect, Finset.sum_mul]

theorem Expect_add (f g : Ω → ℝ) :
    Expect w (fun ω => f ω + g ω) = Expect w f + Expect w g := by
  simp [Expect, mul_add, Finset.sum_add_distrib]

theorem Expect_sub (f g : Ω → ℝ) :
    Expect w (fun ω => f ω - g ω) = Expect w f - Expect w g := by
  simp [Expect, mul_sub, Finset.sum_sub_distrib]

theorem Expect_neg (f : Ω → ℝ) :
    Expect w (fun ω => -f ω) = -Expect w f := by
  simp only [Expect, mul_neg, Finset.sum_neg_distrib]

theorem Expect_mul_const (f : Ω → ℝ) (c : ℝ) :
    Expect w (fun ω => f ω * c) = Expect w f * c := by
  simp only [Expect]
  rw [Finset.sum_mul]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem Expect_const_mul (c : ℝ) (f : Ω → ℝ) :
    Expect w (fun ω => c * f ω) = c * Expect w f := by
  simp only [Expect]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem Expect_sum {ι : Type*} (s : Finset ι) (f : ι → Ω → ℝ) :
    Expect w (fun ω => ∑ i ∈ s, f i ω) = ∑ i ∈ s, Expect w (f i) := by
  have h : ∀ ω, w ω * ∑ i ∈ s, f i ω = ∑ i ∈ s, w ω * f i ω := fun ω =>
    Finset.mul_sum ..
  simp only [Expect, h]
  rw [Finset.sum_comm]

theorem Expect_congr {f g : Ω → ℝ} (h : ∀ ω, f ω = g ω) : Expect w f = Expect w g := by
  simp [Expect, h]

theorem Var_def (f : Ω → ℝ) :
    Var w f = ∑ ω, w ω * (f ω - ∑ ω', w ω' * f ω') ^ 2 := rfl

/-- La varianza es la covarianza consigo misma. -/
theorem Var_eq_Cov (f : Ω → ℝ) : Var w f = Cov w f f := by
  simp [Var, Cov, sq]

theorem Var_const (hw1 : ∑ ω, w ω = 1) (c : ℝ) : Var w (fun _ => c) = 0 := by
  simp [Var, Expect_const, hw1]

theorem Var_const_mul (f : Ω → ℝ) (c : ℝ) :
    Var w (fun ω => c * f ω) = c ^ 2 * Var w f := by
  have hlin : Expect w (fun ω => c * f ω) = c * Expect w f := Expect_const_mul c f
  have hfun : (fun ω => (c * f ω - Expect w (fun ω => c * f ω)) ^ 2)
      = fun ω => c ^ 2 * (f ω - Expect w f) ^ 2 := by
    funext ω; rw [hlin]; ring
  simp only [Var]
  rw [hfun, Expect_const_mul]

/-- Intercambio de tres sumas finitas. -/
theorem sum_comm_three {ι κ : Type*} [Fintype ι] [Fintype κ] (g : Ω → ι → κ → ℝ) :
    (∑ ω, ∑ i, ∑ j, g ω i j) = ∑ i, ∑ j, ∑ ω, g ω i j := by
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_comm

/-- Descomposición de la varianza de una suma finita en covarianzas. -/
theorem Var_sum {ι : Type*} [Fintype ι] (X : ι → Ω → ℝ) :
    Var w (fun ω => ∑ i, X i ω) = ∑ i, ∑ j, Cov w (X i) (X j) := by
  have hE : (∑ x, w x * ∑ i, X i x) = ∑ i, ∑ x, w x * X i x := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun i _ => by rw [Finset.mul_sum]
  have hterm : ∀ ω, (∑ i, X i ω - ∑ i, ∑ x, w x * X i x) ^ 2
      = ∑ i, ∑ j, (X i ω - ∑ x, w x * X i x) * (X j ω - ∑ x, w x * X j x) := by
    intro ω
    rw [← Finset.sum_sub_distrib, sq, Finset.sum_mul_sum]
  have key : ∀ ω, w ω * (∑ i, ∑ j,
        (X i ω - ∑ x, w x * X i x) * (X j ω - ∑ x, w x * X j x))
      = ∑ i, ∑ j, w ω * ((X i ω - ∑ x, w x * X i x) * (X j ω - ∑ x, w x * X j x)) := by
    intro ω
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => Finset.mul_sum ..
  simp only [Var, Expect]
  rw [hE]
  have step1 : (∑ x, w x * (∑ i, X i x - ∑ i, ∑ x, w x * X i x) ^ 2)
      = ∑ x, w x * (∑ i, ∑ j,
          (X i x - ∑ x, w x * X i x) * (X j x - ∑ x, w x * X j x)) :=
    Finset.sum_congr rfl fun ω _ => by rw [hterm ω]
  rw [step1]
  rw [show (∑ x, w x * (∑ i, ∑ j,
          (X i x - ∑ x, w x * X i x) * (X j x - ∑ x, w x * X j x)))
      = ∑ i, ∑ j, ∑ x, w x * ((X i x - ∑ x, w x * X i x)
          * (X j x - ∑ x, w x * X j x)) from by
    rw [Finset.sum_congr rfl fun ω _ => key ω, sum_comm_three]]
  simp only [Cov, Expect]

/-- **Episodios iid.** Si `n` contribuciones tienen varianza común `v` y
covarianza nula entre distintas, la varianza de su promedio es `v/n`. Es la
división por `n` que el libro usa (insesgadez + independencia). -/
theorem var_mean_of_uncorrelated {ι : Type*} [Fintype ι] (hne : Fintype.card ι ≠ 0)
    (X : ι → Ω → ℝ) (v : ℝ) (hvar : ∀ i, Var w (X i) = v)
    (hcov : ∀ i j, i ≠ j → Cov w (X i) (X j) = 0) :
    Var w (fun ω => (∑ i, X i ω) / (Fintype.card ι : ℝ)) = v / (Fintype.card ι : ℝ) := by
  set n : ℝ := (Fintype.card ι : ℝ) with hn
  have hn0 : n ≠ 0 := by
    simp only [hn]; exact_mod_cast hne
  have hsum : Var w (fun ω => ∑ i, X i ω) = n * v := by
    rw [Var_sum]
    have hinner : ∀ i, ∑ j, Cov w (X i) (X j) = v := by
      intro i
      rw [Finset.sum_eq_single i]
      · simpa [Var, Cov, sq] using hvar i
      · intro j _ hji; exact hcov i j (Ne.symm hji)
      · intro h; exact absurd (Finset.mem_univ i) h
    rw [Finset.sum_congr rfl fun i _ => hinner i]
    simp [hn, mul_comm]
  have hmul : (fun ω => (∑ i, X i ω) / n) = fun ω => (1 / n) * (∑ i, X i ω) := by
    funext ω; rw [one_div, inv_mul_eq_div]
  rw [hmul, Var_const_mul, hsum]
  field_simp

end Base


/-! ## Herramientas de esperanza absoluta -/

section Bounds

variable {Ω : Type*} [Fintype Ω] {w : Ω → ℝ}

/-- `|EE X| ≤ EE |X|`. -/
theorem abs_Expect_le (hw0 : ∀ ω, 0 ≤ w ω) (f : Ω → ℝ) :
    |Expect w f| ≤ Expect w (fun ω => |f ω|) := by
  simp only [Expect]
  calc |∑ ω, w ω * f ω| ≤ ∑ ω, |w ω * f ω| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ ω, w ω * |f ω| := by
        exact Finset.sum_congr rfl fun ω _ => by rw [abs_mul, abs_of_nonneg (hw0 ω)]

/-- La varianza es el segundo momento menos el cuadrado de la media. -/
theorem Var_eq (hw1 : ∑ ω, w ω = 1) (f : Ω → ℝ) :
    Var w f = Expect w (fun ω => f ω ^ 2) - (Expect w f) ^ 2 := by
  have hpt : (fun ω => (f ω - Expect w f) ^ 2)
      = fun ω => f ω ^ 2 - 2 * (Expect w f) * f ω + (Expect w f) ^ 2 := by
    funext ω; ring
  have step1 : Expect w (fun ω => f ω ^ 2 - 2 * (Expect w f) * f ω + (Expect w f) ^ 2)
      = Expect w (fun ω => f ω ^ 2 - 2 * (Expect w f) * f ω)
        + Expect w (fun _ => (Expect w f) ^ 2) := Expect_add _ _
  have step2 : Expect w (fun ω => f ω ^ 2 - 2 * (Expect w f) * f ω)
      = Expect w (fun ω => f ω ^ 2) - Expect w (fun ω => 2 * (Expect w f) * f ω) :=
    Expect_sub _ _
  have step3 : Expect w (fun ω => 2 * (Expect w f) * f ω) = 2 * (Expect w f) * Expect w f := by
    have : (fun ω => 2 * (Expect w f) * f ω) = fun ω => (2 * (Expect w f)) * f ω := rfl
    rw [this, Expect_const_mul]
  have step4 : Expect w (fun _ => (Expect w f) ^ 2) = (Expect w f) ^ 2 := by
    rw [Expect_const, hw1, one_mul]
  rw [show Var w f = Expect w (fun ω => (f ω - Expect w f) ^ 2) from rfl, hpt, step1, step2,
    step3, step4]
  ring

/-- La varianza nunca supera el segundo momento. -/
theorem Var_le_second_moment (hw1 : ∑ ω, w ω = 1) (f : Ω → ℝ) :
    Var w f ≤ Expect w (fun ω => f ω ^ 2) := by
  rw [Var_eq hw1]
  linarith [sq_nonneg (Expect w f)]

end Bounds

/-! ## `prop:ch10-dm` — error y variabilidad del método directo -/

section DM

variable {S A : Type*} [Fintype S] [Fintype A]

/-- Valor de la política objetivo para un modelo dado: `v s = ∑_a e(a|s) q(s,a)`. -/
noncomputable def polVal (e : S → A → ℝ) (q : S → A → ℝ) : S → ℝ :=
  fun s => ∑ a, e s a * q s a

/-- Sesgo del DM bajo la ley de estados iniciales `ν`: `EE_ν (vhat_0 - v_0)`. -/
noncomputable def dmBias (ν : S → ℝ) (e : S → A → ℝ) (qhat q : S → A → ℝ) : ℝ :=
  ∑ s, ν s * (polVal e qhat s - polVal e q s)

theorem polVal_sub (e : S → A → ℝ) (q q' : S → A → ℝ) (s : S) :
    polVal e q s - polVal e q' s = ∑ a, e s a * (q s a - q' s a) := by
  simp only [polVal, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun a _ => by ring

/-- book: capitulos/cap07_ope.typ:179 (key: prop:ch10-dm) —
`|EE_ν (vhat_0 - v_0)| ≤ EE_ν (∑_a e_0(a|S_0) |qhat_0(S_0,a) - q_0(S_0,a)|)`.

Fidelidad: `S`, `A` finitos; `ν` es la ley de `S_0` (no negativa); `e_0` es
la política objetivo no negativa; `qhat` es fijo (condicional en un ajuste
independiente), que es como el libro plantea la proposición. -/
theorem prop_ch10_dm_bias (ν : S → ℝ) (e : S → A → ℝ) (qhat q : S → A → ℝ)
    (hν0 : ∀ s, 0 ≤ ν s) (he0 : ∀ s a, 0 ≤ e s a) :
    |dmBias ν e qhat q| ≤ ∑ s, ν s * ∑ a, e s a * |qhat s a - q s a| := by
  have hstep : dmBias ν e qhat q
      = ∑ s, ν s * (∑ a, e s a * (qhat s a - q s a)) := by
    simp only [dmBias, polVal_sub]
  calc |dmBias ν e qhat q|
      = |∑ s, ν s * (∑ a, e s a * (qhat s a - q s a))| := by rw [hstep]
    _ ≤ ∑ s, |ν s * (∑ a, e s a * (qhat s a - q s a))| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ s, ν s * |∑ a, e s a * (qhat s a - q s a)| := by
        refine Finset.sum_congr rfl fun s _ => ?_
        rw [abs_mul, abs_of_nonneg (hν0 s)]
    _ ≤ ∑ s, ν s * ∑ a, e s a * |qhat s a - q s a| := by
        refine Finset.sum_le_sum fun s _ => ?_
        refine mul_le_mul_of_nonneg_left ?_ (hν0 s)
        calc |∑ a, e s a * (qhat s a - q s a)|
            ≤ ∑ a, |e s a * (qhat s a - q s a)| := Finset.abs_sum_le_sum_abs _ _
          _ = ∑ a, e s a * |qhat s a - q s a| := by
              refine Finset.sum_congr rfl fun a _ => ?_
              rw [abs_mul, abs_of_nonneg (he0 s a)]

/-- book: capitulos/cap07_ope.typ:179 (key: prop:ch10-dm) —
sesgo acotado y `Var(hat J_DM) = Var_ν(vhat_0(S_0))/n`.

Fidelidad: los `n` episodios iid entran por sus contribuciones `X i`
(varianza común `Var_ν(vhat_0(S_0))` y covarianza nula entre episodios
distintos), que es el contenido de «episodios iid» que el libro usa para
dividir por `n`. La variabilidad del entrenamiento no se suma: el ajuste se
trata como fijo, tal como el enunciado condiciona. -/
theorem prop_ch10_dm {ι Ω : Type*} [Fintype ι] [Fintype Ω] (hne : Fintype.card ι ≠ 0)
    (w : Ω → ℝ) (X : ι → Ω → ℝ) (ν : S → ℝ) (e : S → A → ℝ) (qhat q : S → A → ℝ)
    (hν0 : ∀ s, 0 ≤ ν s) (he0 : ∀ s a, 0 ≤ e s a)
    (hvar : ∀ i, Var w (X i) = Var ν (polVal e qhat))
    (hcov : ∀ i j, i ≠ j → Cov w (X i) (X j) = 0) :
    |dmBias ν e qhat q| ≤ ∑ s, ν s * ∑ a, e s a * |qhat s a - q s a|
      ∧ Var w (fun ω => (∑ i, X i ω) / (Fintype.card ι : ℝ))
          = Var ν (polVal e qhat) / (Fintype.card ι : ℝ) :=
  ⟨prop_ch10_dm_bias ν e qhat q hν0 he0, var_mean_of_uncorrelated hne X _ hvar hcov⟩

end DM

/-! ## `cor:ch10-curse` — tamaño muestral bajo crecimiento `c^H` -/

/-- book: capitulos/cap07_ope.typ:277 (key: cor:ch10-curse) —
si la varianza por trayectoria crece como `σ2 c^H`, el número de episodios
que mantiene la varianza del promedio por debajo de `ε^2` es exactamente
`σ2 c^H / ε^2`, y al pasar de `H` a `H+k` se multiplica por `c^k`: el número
de episodios exigido es del mismo orden geométrico que `c^H`.

Fidelidad: es el contenido cuantitativo del corolario («mantener un error
estándar fijo exige un número de episodios del mismo orden»), enunciado para
la familia `Var = σ2 c^H` que el propio corolario condiciona. No afirma
crecimiento obligatorio: la cota del libro es superior, no exacta. -/
theorem cor_ch10_curse (σ2 c ε : ℝ) (hσ : 0 < σ2) (hc : 0 < c) (hε : 0 < ε) (H : ℕ) :
    (∀ n : ℕ, 0 < n →
        (σ2 * c ^ H / (n : ℝ) ≤ ε ^ 2 ↔ σ2 * c ^ H / ε ^ 2 ≤ (n : ℝ)))
      ∧ (∀ k : ℕ, σ2 * c ^ (H + k) / ε ^ 2 = c ^ k * (σ2 * c ^ H / ε ^ 2)) := by
  have hε2 : (0 : ℝ) < ε ^ 2 := by positivity
  refine ⟨fun n hn => ?_, fun k => ?_⟩
  · have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    rw [div_le_iff₀ hn', div_le_iff₀ hε2, mul_comm (ε ^ 2) (n : ℝ)]
  · rw [pow_add]; ring

/-! ## `prop:ch10-is-shift` — cambio de población inicial -/

section Shift

variable {S : Type*} [Fintype S]

/-- book: capitulos/cap07_ope.typ:310 (key: prop:ch10-is-shift) —
con `u s = dν_*/dν_b (s) = ν_* s / ν_b s` y `v s = EE_b(W G | S_0 = s)`
(identificación de `thm:ch10-identificacion`, tomada aquí como la función
`v` dada), se cumple `J_*(e) = EE_b(u(S_0) W G) = ∑_s ν_b(s) u(s) v(s)`, y
`EE_b(u(S_0)) = 1`.

Fidelidad: estratos finitos con `ν_b(s) > 0` para todo `s` (lo que implica
`ν_* ≪ ν_b`); `ν_b`, `ν_*` son leyes (`∑ = 1`); `u` es el cociente de
Radon–Nikodym en ese caso finito. -/
theorem prop_ch10_is_shift (νb νs : S → ℝ) (v : S → ℝ) (hνb : ∀ s, 0 < νb s)
    (hνb1 : ∑ s, νb s = 1) (hνs1 : ∑ s, νs s = 1) :
    (∑ s, νs s * v s = ∑ s, νb s * ((νs s / νb s) * v s))
      ∧ (∑ s, νb s * (νs s / νb s) = 1) := by
  constructor
  · refine Finset.sum_congr rfl fun s _ => ?_
    have hs : νb s ≠ 0 := ne_of_gt (hνb s)
    field_simp
  · rw [← hνs1]
    refine Finset.sum_congr rfl fun s _ => ?_
    have hs : νb s ≠ 0 := ne_of_gt (hνb s)
    field_simp

/-- La varianza de la razón `u = dν_*/dν_b` bajo `ν_b` es la divergencia
chi-cuadrado `χ^2(ν_*‖ν_b) = ∑_s (ν_* s - ν_b s)^2 / ν_b s`, que es el caso
`G = 1`, `e = b` discutido tras `prop:ch10-is-shift`. -/
theorem shift_var_ratio_chi2 (νb νs : S → ℝ) (hνb : ∀ s, 0 < νb s)
    (hνb1 : ∑ s, νb s = 1) (hνs1 : ∑ s, νs s = 1) :
    Var νb (fun s => νs s / νb s) = ∑ s, (νs s - νb s) ^ 2 / νb s := by
  have hEu : Expect νb (fun s => νs s / νb s) = 1 := by
    have h := (prop_ch10_is_shift νb νs (fun _ => 1) hνb hνb1 hνs1).2
    simpa [Expect, mul_comm, mul_left_comm, mul_assoc] using h
  have hsq : ∀ s, νb s * (νs s / νb s - Expect νb (fun s => νs s / νb s)) ^ 2
      = (νs s - νb s) ^ 2 / νb s := by
    intro s
    have hs : νb s ≠ 0 := ne_of_gt (hνb s)
    have h1 : νs s / νb s - 1 = (νs s - νb s) / νb s := by
      field_simp
    rw [hEu, h1]
    field_simp
  simp only [Var]
  exact Finset.sum_congr rfl fun s _ => hsq s

end Shift

/-! ## `prop:ch10-dro-garantia` — cobertura de la cota robusta -/

section DRO

variable {Ω U : Type*} [Fintype Ω] [Fintype U] [DecidableEq U]

/-- book: capitulos/cap07_ope.typ:334 (key: prop:ch10-dro-garantia) —
si el conjunto aleatorio `cal(U)_n` contiene al modelo verdadero `P_*` con
probabilidad al menos `1 - α`, entonces
`Prob(J_{P_*}(e) ≥ inf_{P ∈ cal(U)_n} J_P(e)) ≥ 1 - α`.

Fidelidad: versión finita y puntual: `Ω` finito con pesos `p ≥ 0`, el
conjunto aleatorio es `Uset : Ω → Finset U` (no vacío en cada `ω`) y el
ínfimo es `Finset.inf'`. Es exactamente el argumento del libro: en el suceso
de cobertura el ínfimo no supera el valor del elemento `P_*`; lo difícil es
la cobertura, que aquí es hipótesis. -/
theorem prop_ch10_dro_garantia (p : Ω → ℝ) (hp0 : ∀ ω, 0 ≤ p ω)
    (Uset : Ω → Finset U) (hne : ∀ ω, (Uset ω).Nonempty) (J : U → ℝ)
    (Pstar : U) (α : ℝ)
    (hcov : 1 - α ≤ ∑ ω, if Pstar ∈ Uset ω then p ω else 0) :
    1 - α ≤ ∑ ω, (if J Pstar ≥ (Uset ω).inf' (hne ω) J then p ω else 0) := by
  classical
  refine le_trans hcov (Finset.sum_le_sum fun ω _ => ?_)
  by_cases h : Pstar ∈ Uset ω
  · have hle : (Uset ω).inf' (hne ω) J ≤ J Pstar := Finset.inf'_le _ h
    rw [if_pos h, if_pos hle]
  · rw [if_neg h]
    split_ifs with h2
    · exact hp0 ω
    · exact le_refl 0

end DRO

/-! ## `thm:ch10-truncamiento` — sesgo y varianza del truncado -/

section Trunc

variable {Ω : Type*} [Fintype Ω]

/-- `W - min W M = (W - M)_+` para `W ≥ 0`, `M > 0`. -/
theorem sub_min_eq_pos_part (W M : ℝ) (hM : 0 < M) :
    W - min W M = max (W - M) 0 := by
  rw [min_def, max_def]
  split_ifs <;> linarith

/-- book: capitulos/cap07_ope.typ:582 (key: thm:ch10-truncamiento) —
para `hat J_M = n^(-1) ∑_i min(W_i, M) G_i` con `|G| ≤ B_H`, `EE_b(W) = 1` y
`W ≥ 0`:
`|EE_b(hat J_M) - J| ≤ B_H EE_b((W - M)_+)` y
`EE_b((min(W,M) G)^2) ≤ B_H^2 min(M^2, M)`; dividiendo por `n` (teorema
siguiente) resulta la cota de varianza del libro.

Fidelidad: la trayectoria es un punto de `Ω` con pesos `w` (la ley de
registro `b`); `W` es el peso de importancia verdadero, no negativo y de
media uno; `G` el retorno acotado. El sesgo se mide frente a `J = EE_b(W G)`,
la identificación de `thm:ch10-identificacion`. -/
theorem thm_ch10_truncamiento (w : Ω → ℝ) (hw0 : ∀ ω, 0 ≤ w ω)
    (hw1 : ∑ ω, w ω = 1) (W G : Ω → ℝ) (hW0 : ∀ ω, 0 ≤ W ω)
    (hW1 : Expect w W = 1) (B M : ℝ) (hB0 : 0 ≤ B) (hM0 : 0 < M)
    (hG : ∀ ω, |G ω| ≤ B) :
    |Expect w (fun ω => min (W ω) M * G ω) - Expect w (fun ω => W ω * G ω)|
        ≤ B * Expect w (fun ω => max (W ω - M) 0)
      ∧ Expect w (fun ω => (min (W ω) M * G ω) ^ 2) ≤ B ^ 2 * min (M ^ 2) M := by
  have hWmin0 : ∀ ω, 0 ≤ W ω - min (W ω) M := by
    intro ω
    have : min (W ω) M ≤ W ω := min_le_left _ _
    linarith
  constructor
  · have hdiff : Expect w (fun ω => min (W ω) M * G ω) - Expect w (fun ω => W ω * G ω)
        = -Expect w (fun ω => (W ω - min (W ω) M) * G ω) := by
      rw [← Expect_sub, ← Expect_neg]
      exact Expect_congr fun ω => by ring
    have hpt : ∀ ω, |(W ω - min (W ω) M) * G ω| ≤ B * max (W ω - M) 0 := by
      intro ω
      have hpos : 0 ≤ max (W ω - M) 0 := le_max_right _ _
      rw [sub_min_eq_pos_part (W ω) M hM0, abs_mul, abs_of_nonneg hpos]
      calc max (W ω - M) 0 * |G ω| ≤ max (W ω - M) 0 * B :=
            mul_le_mul_of_nonneg_left (hG ω) hpos
        _ = B * max (W ω - M) 0 := mul_comm _ _
    calc |Expect w (fun ω => min (W ω) M * G ω) - Expect w (fun ω => W ω * G ω)|
        = |Expect w (fun ω => (W ω - min (W ω) M) * G ω)| := by rw [hdiff, abs_neg]
      _ ≤ Expect w (fun ω => |(W ω - min (W ω) M) * G ω|) := abs_Expect_le hw0 _
      _ ≤ Expect w (fun ω => B * max (W ω - M) 0) := by
          simp only [Expect]
          exact Finset.sum_le_sum fun ω _ =>
            mul_le_mul_of_nonneg_left (hpt ω) (hw0 ω)
      _ = B * Expect w (fun ω => max (W ω - M) 0) := Expect_const_mul _ _
  · -- segundo momento: dos cotas puntuales y `le_min`
    have hmin_nonneg : ∀ ω, 0 ≤ min (W ω) M := fun ω => le_min (hW0 ω) (le_of_lt hM0)
    have hsqG : ∀ ω, (G ω) ^ 2 ≤ B ^ 2 := by
      intro ω
      nlinarith [sq_abs (G ω), abs_nonneg (G ω), hG ω, hB0]
    have h1 : ∀ ω, (min (W ω) M * G ω) ^ 2 ≤ (min (W ω) M) ^ 2 * B ^ 2 := by
      intro ω
      calc (min (W ω) M * G ω) ^ 2 = (min (W ω) M) ^ 2 * (G ω) ^ 2 := by ring
        _ ≤ (min (W ω) M) ^ 2 * B ^ 2 := mul_le_mul_of_nonneg_left (hsqG ω) (sq_nonneg _)
    have hA : ∀ ω, (min (W ω) M * G ω) ^ 2 ≤ B ^ 2 * M ^ 2 := by
      intro ω
      have h3 : (min (W ω) M) ^ 2 ≤ M ^ 2 := by
        have h4 : min (W ω) M ≤ M := min_le_right _ _
        nlinarith [hmin_nonneg ω]
      nlinarith [h1 ω, h3, hB0]
    have hB' : ∀ ω, (min (W ω) M * G ω) ^ 2 ≤ B ^ 2 * (M * W ω) := by
      intro ω
      have h3 : (min (W ω) M) ^ 2 ≤ M * W ω := by
        calc (min (W ω) M) ^ 2 = min (W ω) M * min (W ω) M := sq _
          _ ≤ M * W ω := mul_le_mul (min_le_right _ _) (min_le_left _ _)
              (hmin_nonneg ω) (le_of_lt hM0)
      nlinarith [h1 ω, h3, hB0]
    have hmA : Expect w (fun ω => (min (W ω) M * G ω) ^ 2) ≤ B ^ 2 * M ^ 2 := by
      calc Expect w (fun ω => (min (W ω) M * G ω) ^ 2)
          ≤ Expect w (fun _ => B ^ 2 * M ^ 2) := by
            simp only [Expect]
            exact Finset.sum_le_sum fun ω _ =>
              mul_le_mul_of_nonneg_left (hA ω) (hw0 ω)
        _ = B ^ 2 * M ^ 2 := by rw [Expect_const, hw1, one_mul]
    have hmB : Expect w (fun ω => (min (W ω) M * G ω) ^ 2) ≤ B ^ 2 * M := by
      calc Expect w (fun ω => (min (W ω) M * G ω) ^ 2)
          ≤ Expect w (fun ω => B ^ 2 * M * W ω) := by
            simp only [Expect]
            exact Finset.sum_le_sum fun ω _ => by
              calc w ω * (min (W ω) M * G ω) ^ 2 ≤ w ω * (B ^ 2 * (M * W ω)) :=
                    mul_le_mul_of_nonneg_left (hB' ω) (hw0 ω)
                _ = w ω * (B ^ 2 * M * W ω) := by ring
        _ = (B ^ 2 * M) * Expect w W := by rw [Expect_const_mul]
        _ = B ^ 2 * M := by rw [hW1]; ring
    rcases le_total (M ^ 2) M with h | h
    · rw [min_eq_left h]; exact hmA
    · rw [min_eq_right h]; exact hmB

/-- book: capitulos/cap07_ope.typ:582 (key: thm:ch10-truncamiento), parte `n`:
la varianza del promedio de `n` episodios truncados iid es a lo sumo
`B_H^2 min(M^2, M)/n`. -/
theorem thm_ch10_truncamiento_var {ι Ω' : Type*} [Fintype ι] [Fintype Ω']
    (hne : Fintype.card ι ≠ 0) (p : Ω' → ℝ) (X : ι → Ω' → ℝ)
    (w : Ω → ℝ) (hw0 : ∀ ω, 0 ≤ w ω) (hw1 : ∑ ω, w ω = 1) (W G : Ω → ℝ)
    (hW0 : ∀ ω, 0 ≤ W ω) (hW1 : Expect w W = 1) (B M : ℝ) (hB0 : 0 ≤ B)
    (hM0 : 0 < M) (hG : ∀ ω, |G ω| ≤ B)
    (hvar : ∀ i, Var p (X i) = Var w (fun ω => min (W ω) M * G ω))
    (hcov : ∀ i j, i ≠ j → Cov p (X i) (X j) = 0) :
    Var p (fun ω => (∑ i, X i ω) / (Fintype.card ι : ℝ))
      ≤ (B ^ 2 * min (M ^ 2) M) / (Fintype.card ι : ℝ) := by
  rw [var_mean_of_uncorrelated hne X _ hvar hcov]
  have hn : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    exact_mod_cast Nat.pos_of_ne_zero hne
  have h1 : Var w (fun ω => min (W ω) M * G ω)
      ≤ Expect w (fun ω => (min (W ω) M * G ω) ^ 2) := Var_le_second_moment hw1 _
  have h2 : Expect w (fun ω => (min (W ω) M * G ω) ^ 2) ≤ B ^ 2 * min (M ^ 2) M :=
    (thm_ch10_truncamiento w hw0 hw1 W G hW0 hW1 B M hB0 hM0 hG).2
  exact div_le_div_of_nonneg_right (le_trans h1 h2) (le_of_lt hn)

end Trunc


/-! ## `thm:ch10-dr-eficiencia` — linealidad exacta y función de influencia -/

section Efficiency

variable {Ω : Type*} [Fintype Ω] {w : Ω → ℝ}

/-- book: capitulos/cap07_ope.typ:464 (key: thm:ch10-dr-eficiencia) —
con `D = v(S) + (e/b)(S,A) ρ` y `φ = v(S) - J + (e/b)(S,A) ρ`, donde
`ρ = R - m(S,A)` es el residuo y `EE[ρ | S,A] = 0` (codificado como
`EE[Y] = EE[v(S) Y] = 0`, con `Y = (e/b)(S,A) ρ`):
`EE_b D = J`, `EE_b φ = 0`, `D - J = φ` y
`Var_b φ = Var_b(v(S)) + EE_b[Y^2]`
(la varianza de la función de influencia del DR de una decisión).

Fidelidad: cuando las dos nuisances son exactas, el resto `o_P(1)` de la
expansión asintótica del libro es idénticamente cero, de modo que la
linealidad `sqrt(n)(hat J_DR - J) = n^(-1/2) ∑ φ(O_i)` es una identidad;
es lo que se formaliza. El caso general con nuisances estimadas y
cross-fitting (errores `L^2` que convergen y producto `o_P(n^(-1/2))`) no se
formaliza: exigiría una noción de convergencia en probabilidad. La identidad
`EE_b[D] = J` con nuisances exactas es la parte de doble robustez ya probada
en `thm:ch10-dr`; aquí se añade la función de influencia y su varianza. -/
theorem thm_ch10_dr_eficiencia (hw1 : ∑ ω, w ω = 1) (vc Y : Ω → ℝ)
    (hY : Expect w Y = 0) (hYv : Expect w (fun ω => vc ω * Y ω) = 0) :
    Expect w (fun ω => vc ω + Y ω) = Expect w vc
      ∧ Expect w (fun ω => vc ω - Expect w vc + Y ω) = 0
      ∧ (∀ ω, (vc ω + Y ω) - Expect w vc = (vc ω - Expect w vc) + Y ω)
      ∧ Var w (fun ω => vc ω - Expect w vc + Y ω)
          = Var w vc + Expect w (fun ω => Y ω ^ 2) := by
  have hEphi : Expect w (fun ω => vc ω - Expect w vc + Y ω) = 0 := by
    rw [Expect_add, Expect_sub, Expect_const, hw1, one_mul, hY]
    ring
  refine ⟨?_, hEphi, fun ω => by ring, ?_⟩
  · rw [Expect_add, hY, add_zero]
  · have hcross : Expect w (fun ω => (vc ω - Expect w vc) * Y ω) = 0 := by
      have h1 : Expect w (fun ω => (vc ω - Expect w vc) * Y ω)
          = Expect w (fun ω => vc ω * Y ω) - Expect w (fun ω => (Expect w vc) * Y ω) := by
        rw [← Expect_sub]
        exact Expect_congr fun ω => by ring
      rw [h1, hYv, Expect_const_mul, hY]
      ring
    have h2C : Expect w (fun ω => 2 * ((vc ω - Expect w vc) * Y ω)) = 0 := by
      rw [Expect_const_mul, hcross]
      ring
    rw [Var_eq hw1, hEphi]
    have hpt : ∀ ω, (vc ω - Expect w vc + Y ω) ^ 2
        = (vc ω - Expect w vc) ^ 2 + 2 * ((vc ω - Expect w vc) * Y ω) + Y ω ^ 2 := by
      intro ω; ring
    rw [Expect_congr hpt, Expect_add, Expect_add, h2C]
    have hA : Expect w (fun ω => (vc ω - Expect w vc) ^ 2) = Var w vc := rfl
    rw [hA]
    ring

/-- El modelo de una decisión con residuo ortogonal a toda función de
`(S, A)` (es decir `EE_b[ρ | S,A] = 0`) satisface las hipótesis de
`thm_ch10_dr_eficiencia` con `v(S)` y `Y = (e/b)(S,A) ρ`. -/
theorem dr_residual_orthogonal {S A : Type*} [Fintype S] [Fintype A]
    (Sf : Ω → S) (Af : Ω → A) (ρ : Ω → ℝ)
    (horth : ∀ f : S → A → ℝ, ∑ ω, w ω * (f (Sf ω) (Af ω) * ρ ω) = 0)
    (b e : S → A → ℝ) (v : S → ℝ) :
    Expect w (fun ω => (e (Sf ω) (Af ω) / b (Sf ω) (Af ω)) * ρ ω) = 0
      ∧ Expect w (fun ω => v (Sf ω) *
          ((e (Sf ω) (Af ω) / b (Sf ω) (Af ω)) * ρ ω)) = 0 := by
  constructor
  · have h := horth (fun s a => e s a / b s a)
    simpa [Expect] using h
  · have h := horth (fun s a => v s * (e s a / b s a))
    simp only [Expect]
    refine Eq.trans (Finset.sum_congr rfl fun ω _ => ?_) h
    ring

end Efficiency

/-! ## Ejemplos numéricos del capítulo -/

section Ejemplos

/-- Valor de una mezcla de estratos: `J = ∑ ν_i v_i`. -/
noncomputable def Jw (m : ℕ) (ν v : Fin m → ℝ) : ℝ := ∑ i, ν i * v i

theorem sum2 (f : Fin 2 → ℝ) : ∑ i, f i = f 0 + f 1 := Fin.sum_univ_two f

/-- book: capitulos/cap07_ope.typ:353 (key: ex:ssch-dist-shift-cap10) —
dos estratos con valores `(2,6)`, registro `(0.8,0.2)`, objetivo `(0.3,0.7)`:
el valor registrado es `2.8`, el objetivo `4.8`, los pesos iniciales
`u = (0.375, 3.5)` y `0.8·0.375·2 + 0.2·3.5·6 = 4.8`; sin corregir la
población la diferencia es de dos unidades. -/
theorem ex_ssch_dist_shift_cap10 :
    Jw 2 ![0.8, 0.2] ![2, 6] = 14 / 5
      ∧ Jw 2 ![0.3, 0.7] ![2, 6] = 24 / 5
      ∧ (![0.3, 0.7] 0 / (![0.8, 0.2] : Fin 2 → ℝ) 0 = 0.375
          ∧ ![0.3, 0.7] 1 / (![0.8, 0.2] : Fin 2 → ℝ) 1 = 3.5)
      ∧ Jw 2 ![0.8, 0.2] (fun i => ![0.375, 3.5] i * ![2, 6] i) = 24 / 5
      ∧ (24 / 5 : ℝ) - 14 / 5 = 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · simp [Jw, Fin.sum_univ_two]; norm_num
  · simp [Jw, Fin.sum_univ_two]; norm_num
  · constructor <;> norm_num
  · simp [Jw, Fin.sum_univ_two]; norm_num
  · norm_num

/-- book: capitulos/cap07_ope.typ:393 (key: ex:ch10-shift-ssch) —
si además de las proporciones `(0.3,0.7)` el segundo estrato pasa de `6` a
`4`, el valor nuevo es `0.3·2 + 0.7·4 = 3.4`, mientras reponderar sólo la
población con el modelo antiguo da `4.8`: diferencia `1.4`. Los mismos pesos
iniciales no corrigen una respuesta condicional que cambió. -/
theorem ex_ch10_shift_ssch :
    Jw 2 ![0.3, 0.7] ![2, 4] = 17 / 5
      ∧ Jw 2 ![0.3, 0.7] ![2, 6] = 24 / 5
      ∧ (24 / 5 : ℝ) - 17 / 5 = 7 / 5 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [Jw, Fin.sum_univ_two]; norm_num
  · simp [Jw, Fin.sum_univ_two]; norm_num
  · norm_num

/-! ### `ex:ch10-pipeline`: política de registro adaptativa -/

/-- Ley del ejemplo de adaptación: cuatro resultados
`(R_1, A_2)` con probabilidades `(1/2, 0, 1/4, 1/4)`. `b_1(1) = 1/2` fija y
`b_2(1) = 1` si `R_1 = 1`, `1/2` si `R_1 = 0`. -/
noncomputable def pipeP : Fin 4 → ℝ := ![1 / 2, 0, 1 / 4, 1 / 4]

/-- Contribución IS del episodio 1: `R_1 / b_1(1)`, con `R_1 = A_1`. -/
noncomputable def pipeC1 : Fin 4 → ℝ := ![2, 2, 0, 0]

/-- Contribución IS del episodio 2, con `R_2 = A_2` y la propensión
condicional real `b_2(A_2)`. -/
noncomputable def pipeC2 : Fin 4 → ℝ := ![1, 1, 2, 0]

/-- book: capitulos/cap07_ope.typ:658 (key: ex:ch10-pipeline) —
el aviso del libro: si la política de registro se adapta entre episodios, el
promedio sigue siendo insesgado (`EE = J = 1`) **pero el régimen iid deja de
aplicarse**: las contribuciones no son idénticamente distribuidas
(`Var C_1 = 1`, `Var C_2 = 1/2`) y la fórmula iid `Var/n` falla
(`Var(hat J_2) = 3/8 ≠ 1/2 = Var C_1/2`).

Fidelidad: horizonte `H = 1`, acciones binarias, `R_t = A_t`, política
objetivo `e(1) = 1` (valor `J = 1`); `b_2` se fija con el resultado del
episodio anterior, que es exactamente el caso que el libro señala. Lo que se
formaliza es la parte cuantitativa del aviso (guardar las probabilidades
condicionales reales mantiene la insesgadez; la igualdad de distribuciones y
la división por `n` dejan de valer), no la lista de comprobaciones de
ingeniería del bloque de código. -/
theorem ex_ch10_pipeline :
    Expect pipeP pipeC1 = 1
      ∧ Expect pipeP pipeC2 = 1
      ∧ Expect pipeP (fun ω => (pipeC1 ω + pipeC2 ω) / 2) = 1
      ∧ Var pipeP pipeC1 = 1
      ∧ Var pipeP pipeC2 = 1 / 2
      ∧ Var pipeP (fun ω => (pipeC1 ω + pipeC2 ω) / 2) = 3 / 8
      ∧ Var pipeP (fun ω => (pipeC1 ω + pipeC2 ω) / 2) ≠ Var pipeP pipeC1 / 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [Expect, Var, pipeP, pipeC1, pipeC2, Fin.sum_univ_four,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.tail_cons,
      Matrix.cons_val_fin_one, Matrix.cons_val', Matrix.empty_val'] <;> norm_num

end Ejemplos

/-! ### `ex:ssch-cap10`: dos decisiones con cálculo completo -/

/-- Acción en la primera visita en cada una de las cuatro trayectorias
`(0,0), (0,1), (1,0), (1,1)`. -/
noncomputable def act0 : Fin 4 → Fin 2 := ![0, 0, 1, 1]

/-- Acción en la segunda visita en cada trayectoria. -/
noncomputable def act1 : Fin 4 → Fin 2 := ![0, 1, 0, 1]

/-- Cocientes por acción `e_t(a)/b_t(a)` con `b_t(1) = 0.5`, `e_t(1) = 0.75`:
`0.5` para la acción cero y `1.5` para la uno. -/
noncomputable def rhoB : Fin 2 → ℝ := ![0.5, 1.5]

/-- Modelo ajustado en la segunda visita: `hat q_1(a) = 0.2 + 0.6 a`. -/
noncomputable def q1hat : Fin 2 → ℝ := ![0.2, 0.8]

/-- Modelo ajustado en la primera visita: `hat q_0(a) = 0.685 + 0.8 a`. -/
noncomputable def q0hat : Fin 2 → ℝ := ![0.685, 1.485]

/-- `hat v_1 = sum_a e_1(a) hat q_1(a)`. -/
noncomputable def v1hat : ℝ := 0.25 * q1hat 0 + 0.75 * q1hat 1

/-- `hat v_0 = sum_a e_0(a) hat q_0(a)`, el valor DM. -/
noncomputable def v0hat : ℝ := 0.25 * q0hat 0 + 0.75 * q0hat 1

/-- Las cuatro trayectorias tienen probabilidad `1/4` bajo `b`. -/
noncomputable def lawU : Fin 4 → ℝ := ![0.25, 0.25, 0.25, 0.25]

/-- Peso acumulado hasta la primera decisión. -/
noncomputable def Wcum0 (ω : Fin 4) : ℝ := rhoB (act0 ω)

/-- Peso acumulado hasta la segunda decisión (peso IS completo). -/
noncomputable def Wcum1 (ω : Fin 4) : ℝ := rhoB (act0 ω) * rhoB (act1 ω)

/-- Retorno `G = A_0 + 0.9 A_1` (`gamma = 0.9`, `R_t = A_t`). -/
noncomputable def retG (ω : Fin 4) : ℝ := ((act0 ω).val : ℝ) + 0.9 * ((act1 ω).val : ℝ)

/-- Contribución IS por trayectoria. -/
noncomputable def ISc (ω : Fin 4) : ℝ := Wcum1 ω * retG ω

/-- Contribución PDIS por trayectoria. -/
noncomputable def PDISc (ω : Fin 4) : ℝ :=
  Wcum0 ω * ((act0 ω).val : ℝ) + 0.9 * Wcum1 ω * ((act1 ω).val : ℝ)

/-- Residuo `Delta_0 = R_0 + gamma hat v_1 - hat q_0(A_0)`. -/
noncomputable def delta0 (ω : Fin 4) : ℝ :=
  ((act0 ω).val : ℝ) + 0.9 * v1hat - q0hat (act0 ω)

/-- Residuo `Delta_1 = R_1 - hat q_1(A_1)`. -/
noncomputable def delta1 (ω : Fin 4) : ℝ := ((act1 ω).val : ℝ) - q1hat (act1 ω)

/-- Contribución DR por trayectoria. -/
noncomputable def DRc (ω : Fin 4) : ℝ :=
  v0hat + Wcum0 ω * delta0 ω + 0.9 * Wcum1 ω * delta1 ω

/-- book: capitulos/cap07_ope.typ:715 (key: ex:ssch-cap10) —
el cálculo completo del ejemplo SSCH de dos decisiones: `hat v_1 = 0.65`,
`hat v_0 = 1.285` (DM), medias exactas de IS, PDIS y DR iguales a
`J(e) = 0.75 + 0.9·0.75 = 1.425`, diferencia del DM `-0.14`, varianzas por
episodio `2.7928125` (IS), `1.7521875` (PDIS) y `0.061525` (DR), y el renglón
`(1,0)` de la tabla (IS `0.75`, PDIS `1.5`, DR `1.3`).

Fidelidad: las cuatro trayectorias uniformes bajo `b`, acciones binarias
independientes entre visitas, `R_t = A_t`, `gamma = 0.9`, `b_t(1) = 0.5`,
`e_t(1) = 0.75` y los modelos `hat q_1(a) = 0.2 + 0.6a`,
`hat q_0(a) = 0.1 + 0.8a + 0.9 hat v_1` fijados de antemano, exactamente como
el libro; las contribuciones se calculan desde ellos y no se copian de la
tabla. -/
theorem ex_ssch_cap10 :
    v1hat = 0.65
      ∧ v0hat = 1.285
      ∧ Expect lawU ISc = 1.425
      ∧ Expect lawU PDISc = 1.425
      ∧ Expect lawU DRc = 1.425
      ∧ v0hat - 1.425 = -0.14
      ∧ Var lawU ISc = 2.7928125
      ∧ Var lawU PDISc = 1.7521875
      ∧ Var lawU DRc = 0.061525
      ∧ (ISc 2 = 0.75 ∧ PDISc 2 = 1.5 ∧ DRc 2 = 1.3) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [Expect, Var, lawU, ISc, PDISc, DRc, Wcum0, Wcum1, retG, delta0, delta1,
      v0hat, v1hat, q0hat, q1hat, rhoB, act0, act1, Fin.sum_univ_four,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val,
      Matrix.head_cons, Matrix.tail_cons, Matrix.cons_val_fin_one,
      Matrix.cons_val', Matrix.empty_val'] <;> norm_num


end Book.Cap10OPE
