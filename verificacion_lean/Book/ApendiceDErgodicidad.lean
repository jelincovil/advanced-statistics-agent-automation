import Book.ApendiceDViolaciones

/-!
# Book.ApendiceDErgodicidad — ergodicidad geométrica en cadenas finitas (m3)

Claves del libro:

* `thm:appD-ergodico` — `apendices/apendice_regularidad.typ:81`
* `cor:appD-mdp-finito` — `apendices/apendice_regularidad.typ:93`

**Fidelidad declarada.** El libro enuncia: cadena finita irreducible y aperiódica
⇒ `‖P^k(s,·) − μ‖_TV ≤ C(s)ρ^k` con `ρ ∈ (0,1)`, y `(S_t,A_t,R_t)` es
geométricamente α-mixing. Aquí:

* la hipótesis «irreducible + aperiódica» se toma en su forma operativa de
  **Doeblin**: existe `N₀` y `δ > 0` con `P^{N₀}(s,s') ≥ δ` para todo par
  (equivalente en espacio finito; ver `ApendiceDRegularidad.aperiodic_of_selfloop`
  del repositorio para el paso autolazo ⇒ eventual positividad);
* se demuestra la **contracción de Dobrushin en L¹** y de ahí el decaimiento
  geométrico de `∑_t |P^k(s,t) − P^k(s',t)| ≤ 2ρ^{⌊k/N₀⌋}`, que es la forma
  cuantitativa de la conclusión: para cualquier punto límite `μ`,
  `‖P^k(s,·) − μ‖_TV ≤ ρ^{⌊k/N₀⌋}·‖P^0(s,·) − μ‖ ≤ ρ^{⌊k/N₀⌋}`;
* la existencia de `μ` (automática en espacio finito por compacidad) y el paso a
  los coeficientes α/β se declaran citados; el coeficiente acotado aquí es
  `½∑_t|K^k(x,t) − K^k(x',t)|`, que domina a `α(k)` vía `prop:appD-relaciones`.
-/

open Finset BigOperators
open scoped BigOperators Topology
open Filter

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

namespace Book.ApendiceDM3

section Erg

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Ley de la cadena al cabo de `k` pasos partiendo de la ley `μ`. -/
noncomputable def evol (P : S → S → ℝ) (k : ℕ) (μ : S → ℝ) : S → ℝ :=
  fun t => ∑ i, μ i * pot P k i t

lemma evol_zero (P : S → S → ℝ) (μ : S → ℝ) : evol P 0 μ = μ := by
  funext t
  show ∑ i, μ i * (if i = t then 1 else 0) = μ t
  rw [Finset.sum_eq_single t]
  · rw [if_pos rfl, mul_one]
  · intro b _ hb; rw [if_neg (fun h : b = t => hb h), mul_zero]
  · intro h; exact absurd (Finset.mem_univ t) h

/-- Chapman–Kolmogorov en forma de evolución de leyes. -/
lemma evol_add (P : S → S → ℝ) (a b : ℕ) (μ : S → ℝ) :
    evol P (a + b) μ = evol P b (evol P a μ) := by
  funext t
  show (∑ i, μ i * pot P (a + b) i t) = ∑ j, (∑ i, μ i * pot P a i j) * pot P b j t
  calc ∑ i, μ i * pot P (a + b) i t
      = ∑ i, μ i * ∑ j, pot P a i j * pot P b j t := by
          refine Finset.sum_congr rfl fun i _ => by rw [pot_add]
    _ = ∑ i, ∑ j, μ i * (pot P a i j * pot P b j t) := by
          refine Finset.sum_congr rfl fun i _ => ?_
          rw [Finset.mul_sum]
    _ = ∑ j, ∑ i, μ i * (pot P a i j * pot P b j t) := Finset.sum_comm
    _ = ∑ j, ∑ i, (μ i * pot P a i j) * pot P b j t := by
          refine Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun i _ => by ring
    _ = ∑ j, (∑ i, μ i * pot P a i j) * pot P b j t := by
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [Finset.sum_mul]

lemma evol_suma {P : S → S → ℝ} (hP : Estocastica P) (k : ℕ) {μ : S → ℝ}
    (hμ : ∑ i, μ i = 1) : ∑ t, evol P k μ t = 1 := by
  show ∑ t, ∑ i, μ i * pot P k i t = 1
  rw [Finset.sum_comm]
  calc ∑ i, ∑ t, μ i * pot P k i t = ∑ i, μ i * 1 := by
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [← Finset.mul_sum, pot_suma_filas hP k i, mul_one]
    _ = 1 := by simpa using hμ

/-- **Contracción de Dobrushin en L¹.** Si todas las entradas de `A` son al menos
`δ` y sus filas suman uno, la distancia L¹ entre las imágenes de dos leyes se
contrae al menos por el factor `1 − |S|·δ`. La prueba es la identidad
`(μA)_t − (νA)_t = ∑_s (μ_s − ν_s)(A_{st} − δ)`, usando que `∑_s (μ_s − ν_s) = 0`,
más desigualdad triangular. -/
theorem contraccion (A : S → S → ℝ) {δ : ℝ} (hδ : ∀ s s', δ ≤ A s s')
    (hrow : ∀ s, ∑ s', A s s' = 1) (μ ν : S → ℝ) (hmass : ∑ s, μ s = ∑ s, ν s) :
    ∑ t, |∑ s, μ s * A s t - ∑ s, ν s * A s t|
      ≤ (1 - (Fintype.card S : ℝ) * δ) * ∑ s, |μ s - ν s| := by
  have hdiff : ∀ t, ∑ s, μ s * A s t - ∑ s, ν s * A s t
      = ∑ s, (μ s - ν s) * (A s t - δ) := by
    intro t
    have h0 : ∑ s, (μ s - ν s) = 0 := by
      rw [Finset.sum_sub_distrib, hmass, sub_self]
    have hstep : ∑ s, (μ s - ν s) * (A s t - δ)
        = (∑ s, (μ s * A s t - ν s * A s t)) - δ * ∑ s, (μ s - ν s) := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun s _ => by ring
    rw [hstep, h0, mul_zero, sub_zero, ← Finset.sum_sub_distrib]
  have hcol : ∀ s : S, ∑ t, (A s t - δ) = 1 - (Fintype.card S : ℝ) * δ := by
    intro s
    rw [Finset.sum_sub_distrib, hrow s, Finset.sum_const, Finset.card_univ]
    simp [nsmul_eq_mul]
  calc ∑ t, |∑ s, μ s * A s t - ∑ s, ν s * A s t|
      = ∑ t, |∑ s, (μ s - ν s) * (A s t - δ)| := by
          refine Finset.sum_congr rfl fun t _ => by rw [hdiff t]
    _ ≤ ∑ t, ∑ s, |μ s - ν s| * (A s t - δ) := by
          refine Finset.sum_le_sum fun t _ => ?_
          refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
          refine Finset.sum_le_sum fun s _ => ?_
          rw [abs_mul, abs_of_nonneg (sub_nonneg.mpr (hδ s t))]
    _ = (1 - (Fintype.card S : ℝ) * δ) * ∑ s, |μ s - ν s| := by
          rw [Finset.sum_comm]
          calc ∑ s, ∑ t, |μ s - ν s| * (A s t - δ)
              = ∑ s, |μ s - ν s| * ∑ t, (A s t - δ) := by
                refine Finset.sum_congr rfl fun s _ => ?_
                rw [Finset.mul_sum]
            _ = ∑ s, |μ s - ν s| * (1 - (Fintype.card S : ℝ) * δ) := by
                refine Finset.sum_congr rfl fun s _ => by rw [hcol s]
            _ = (1 - (Fintype.card S : ℝ) * δ) * ∑ s, |μ s - ν s| := by
                rw [← Finset.sum_mul]
                ring

/-- Si todas las entradas de `A` son al menos `δ` y las filas suman uno entonces
`|S|·δ ≤ 1`. -/
theorem card_mul_le_one (A : S → S → ℝ) {δ : ℝ}
    (hδ : ∀ s s', δ ≤ A s s') (hrow : ∀ s, ∑ s', A s s' = 1) :
    (Fintype.card S : ℝ) * δ ≤ 1 := by
  rcases isEmpty_or_nonempty S with hS | hS
  · simp [Fintype.card_eq_zero]
  · obtain ⟨s⟩ := hS
    calc (Fintype.card S : ℝ) * δ = ∑ _t : S, δ := by
          rw [Finset.sum_const, Finset.card_univ]; simp [nsmul_eq_mul]
      _ ≤ ∑ t : S, A s t := Finset.sum_le_sum fun t _ => hδ s t
      _ = 1 := hrow s

/-- La contracción iterada: `m` bloques de `N₀` pasos contraen por
`(1 − |S|δ)^m`. -/
theorem contraccion_iterada {P : S → S → ℝ} (hP : Estocastica P) {N₀ : ℕ} {δ : ℝ}
    (hDob : ∀ s s', δ ≤ pot P N₀ s s') (μ ν : S → ℝ) (hμ : ∑ s, μ s = 1)
    (hν : ∑ s, ν s = 1) :
    ∀ m : ℕ, ∑ t, |evol P (m * N₀) μ t - evol P (m * N₀) ν t|
      ≤ (1 - (Fintype.card S : ℝ) * δ) ^ m * ∑ s, |μ s - ν s| := by
  intro m
  induction m with
  | zero => rw [Nat.zero_mul, evol_zero, evol_zero, pow_zero, one_mul]
  | succ m ih =>
      have hstep : (m + 1) * N₀ = m * N₀ + N₀ := by ring
      rw [hstep, evol_add, evol_add]
      have hmass : ∑ s, evol P (m * N₀) μ s = ∑ s, evol P (m * N₀) ν s := by
        rw [evol_suma hP (m * N₀) hμ, evol_suma hP (m * N₀) hν]
      refine le_trans (contraccion (pot P N₀) hDob (pot_suma_filas hP N₀)
        (evol P (m * N₀) μ) (evol P (m * N₀) ν) hmass) ?_
      rw [pow_succ]
      have hrw : (1 - (Fintype.card S : ℝ) * δ) ^ m * (1 - (Fintype.card S : ℝ) * δ)
            * ∑ s, |μ s - ν s|
          = (1 - (Fintype.card S : ℝ) * δ)
            * ((1 - (Fintype.card S : ℝ) * δ) ^ m * ∑ s, |μ s - ν s|) := by ring
      rw [hrw]
      exact mul_le_mul_of_nonneg_left ih
        (sub_nonneg.mpr (card_mul_le_one (pot P N₀) hDob (pot_suma_filas hP N₀)))

/-- `∑_i |μ_i − ν_i| ≤ 2` para dos leyes de probabilidad sobre `S`. -/
theorem abs_sub_le_two {μ ν : S → ℝ}
    (hμ0 : ∀ s, 0 ≤ μ s) (hν0 : ∀ s, 0 ≤ ν s)
    (hμ : ∑ s, μ s = 1) (hν : ∑ s, ν s = 1) :
    ∑ s, |μ s - ν s| ≤ 2 := by
  have h : ∀ s : S, |μ s - ν s| ≤ μ s + ν s := by
    intro s
    refine abs_sub_le_iff.mpr ⟨?_, ?_⟩ <;> linarith [hμ0 s, hν0 s]
  calc ∑ s, |μ s - ν s| ≤ ∑ s, (μ s + ν s) := Finset.sum_le_sum fun s _ => h s
    _ = 2 := by rw [Finset.sum_add_distrib, hμ, hν]; norm_num

/-- **Ergodicidad geométrica** (`book: apendices/apendice_regularidad.typ:81`,
`key: thm:appD-ergodico`).

Fidelidad declarada (ver la cabecera del módulo): se formaliza la conclusión
cuantitativa del libro con la hipótesis de Doeblin (forma finita de «irreducible
y aperiódica»): existe `ρ ∈ (0,1)` tal que para todo `k` y todo par de estados,
`∑_t |P^k(s,t) − P^k(s',t)| ≤ 2ρ^{⌊k/N₀⌋}`. Equivalentemente
`‖P^k(s,·) − P^k(s',·)‖_TV ≤ ρ^{⌊k/N₀⌋}`, de donde el decaimiento geométrico a
la ley estacionaria `μ` con `C(s) = ‖P^0(s,·) − μ‖_TV` más el error de fase
`≤ N₀` absorbido en `ρ^{⌊k/N₀⌋}`. -/
theorem ergodico_geometrico [Nonempty S] {P : S → S → ℝ} (hP : Estocastica P) {N₀ : ℕ} {δ : ℝ}
    (hδ : 0 < δ) (hDob : ∀ s s', δ ≤ pot P N₀ s s')
    (hδn : (Fintype.card S : ℝ) * δ < 1) :
    ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 ∧ ∀ (k : ℕ) (s s' : S),
      ∑ t, |pot P k s t - pot P k s' t| ≤ 2 * ρ ^ (k / N₀) := by
  have hcardpos : (0 : ℝ) < (Fintype.card S : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := S)
  have hcpos : (0 : ℝ) < (Fintype.card S : ℝ) * δ := mul_pos hcardpos hδ
  refine ⟨1 - (Fintype.card S : ℝ) * δ, by linarith, by linarith, ?_⟩
  intro k s s'
  have hk : k = k % N₀ + k / N₀ * N₀ := by
    have h := (Nat.div_add_mod k N₀).symm
    rw [Nat.mul_comm N₀ (k / N₀), Nat.add_comm] at h
    exact h
  have hsplit : ∀ (u t : S),
      pot P k u t = evol P (k / N₀ * N₀) (pot P (k % N₀) u) t := by
    intro u t
    conv_lhs => rw [hk]
    rw [pot_add]
    simp only [evol]
  have hsum : ∑ t, |pot P k s t - pot P k s' t|
      = ∑ t, |evol P (k / N₀ * N₀) (pot P (k % N₀) s) t
              - evol P (k / N₀ * N₀) (pot P (k % N₀) s') t| := by
    refine Finset.sum_congr rfl fun t _ => by rw [hsplit s t, hsplit s' t]
  rw [hsum]
  have hbound := contraccion_iterada hP hDob (pot P (k % N₀) s) (pot P (k % N₀) s')
    (pot_suma_filas hP (k % N₀) s) (pot_suma_filas hP (k % N₀) s') (k / N₀)
  refine le_trans hbound ?_
  have h2 : ∑ i, |pot P (k % N₀) s i - pot P (k % N₀) s' i| ≤ 2 :=
    abs_sub_le_two (pot_nonneg hP.nonneg (k % N₀) s) (pot_nonneg hP.nonneg (k % N₀) s')
      (pot_suma_filas hP (k % N₀) s) (pot_suma_filas hP (k % N₀) s')
  have hρ0 : (0:ℝ) ≤ 1 - (Fintype.card S : ℝ) * δ := by linarith
  calc (1 - (Fintype.card S : ℝ) * δ) ^ (k / N₀)
        * ∑ i, |pot P (k % N₀) s i - pot P (k % N₀) s' i|
      ≤ (1 - (Fintype.card S : ℝ) * δ) ^ (k / N₀) * 2 :=
        mul_le_mul_of_nonneg_left h2 (pow_nonneg hρ0 _)
    _ = 2 * (1 - (Fintype.card S : ℝ) * δ) ^ (k / N₀) := by ring


/-! ## `cor:appD-mdp-finito` — el proceso conjunto `(S_t,A_t)` de un MDP finito -/

section MDP

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- Ley conjunta del par `(S_k, A_k)` al cabo de `k` pasos con **aleatorización
fresca**: `P(S_k = s', A_k = a') = P^k(x.1, s') · π(a' | s')`. -/
noncomputable def leyConj (P : S → S → ℝ) (π : S → A → ℝ) (k : ℕ) (x : S × A) :
    S × A → ℝ :=
  fun y => pot P k x.1 y.1 * π y.1 y.2

/-- **MDPs con estados finitos** (`book: apendices/apendice_regularidad.typ:93`,
`key: cor:appD-mdp-finito`).

Fidelidad declarada: el libro concluye que `(S_t,A_t,R_t)` es geométricamente
α-mixing bajo política estacionaria, inicio estacionario, aleatorización fresca y
recompensas del kernel del modelo. Aquí se formaliza el núcleo: la **ley conjunta
del par `(S_t,A_t)`** (aleatorización fresca) hereda el decaimiento geométrico de
la cadena de estados,

  `∑_{y} |ℓ_k(x,y) − ℓ_k(x',y)| ≤ 2ρ^{⌊k/N₀⌋}`,

cota que domina el coeficiente `α(k)` del proceso conjunto (α ≤ ½β ≤ ½ de esa
suma, vía `prop:appD-relaciones`). Las recompensas `R_t = r(S_t,A_t)` son función
determinista del par, de modo que agrupar átomos no aumenta la distancia L¹; el
paso explícito a la ley de `(S_t,A_t,R_t)` se declara. -/
theorem mdp_finito_mixing [Nonempty S] {P : S → S → ℝ} (hP : Estocastica P) {N₀ : ℕ}
    {δ : ℝ} (hδ : 0 < δ) (hDob : ∀ s s', δ ≤ pot P N₀ s s')
    (hδn : (Fintype.card S : ℝ) * δ < 1) (π : S → A → ℝ)
    (hπ0 : ∀ s a, 0 ≤ π s a) (hπ1 : ∀ s, ∑ a, π s a = 1) :
    ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 ∧ ∀ (k : ℕ) (x x' : S × A),
      ∑ y : S × A, |leyConj P π k x y - leyConj P π k x' y| ≤ 2 * ρ ^ (k / N₀) := by
  obtain ⟨ρ, hρ0, hρ1, hρ⟩ := ergodico_geometrico hP hδ hDob hδn
  refine ⟨ρ, hρ0, hρ1, ?_⟩
  intro k x x'
  have hprod : ∀ y : S × A, |leyConj P π k x y - leyConj P π k x' y|
      = |pot P k x.1 y.1 - pot P k x'.1 y.1| * π y.1 y.2 := by
    intro y
    simp only [leyConj]
    rw [← sub_mul, abs_mul, abs_of_nonneg (hπ0 y.1 y.2)]
  calc ∑ y : S × A, |leyConj P π k x y - leyConj P π k x' y|
      = ∑ y : S × A, |pot P k x.1 y.1 - pot P k x'.1 y.1| * π y.1 y.2 := by
          refine Finset.sum_congr rfl fun y _ => hprod y
    _ = ∑ s, |pot P k x.1 s - pot P k x'.1 s| * (∑ a, π s a) := by
          rw [Fintype.sum_prod_type]
          refine Finset.sum_congr rfl fun s _ => ?_
          show (∑ y : A, |pot P k x.1 s - pot P k x'.1 s| * π s y)
              = |pot P k x.1 s - pot P k x'.1 s| * ∑ a, π s a
          rw [← Finset.mul_sum]
    _ = ∑ s, |pot P k x.1 s - pot P k x'.1 s| := by
          refine Finset.sum_congr rfl fun s _ => by rw [hπ1 s, mul_one]
    _ ≤ 2 * ρ ^ (k / N₀) := hρ k x.1 x'.1

end MDP

end Erg

end Book.ApendiceDM3
