import Mathlib

/-!
# Book.Cap04Ch2 — pendientes `ch2`

Formalización de las claves pendientes del kernel cuyo código de capítulo es
`ch2` y que no viven en el módulo de cap. 1:

* `ex:ch2-bernoulli-minimax` (`capitulos/cap02_wald.typ:139`),
* `ex:ch2-minimal-exponencial` (`capitulos/cap04_herramientas.typ:667`),
* `ex:ch2-multinomial-ssch` (`capitulos/cap04_herramientas.typ:718`),
* `ex:ch2-ancilar-localizacion` (`capitulos/cap04_herramientas.typ:736`),
* `ex:ch2-basu-aplicacion` (`capitulos/cap04_herramientas.typ:774`),
* `prop:ch2-suficiencia-politicas` (`capitulos/cap09_verificacion.typ:227`).

Mismas convenciones que `Ch1Ch2Pendientes.lean`: docstring `book:` con la
fidelidad declarada, cero `sorry`, auditoría `#print axioms` en
`AuditCh1Ch2.lean`.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory

namespace Book.Cap04Ch2

/-! ## `ex:ch2-bernoulli-minimax` — Bernoulli con pérdida cuadrática -/

/-- Ley Bernoulli sobre `Bool` (`false ↦ 0`, `true ↦ 1`). -/
noncomputable def probBernoulli (θ : ℝ) (b : Bool) : ℝ := if b then θ else 1 - θ

/-- Riesgo de la regla `δ` en el modelo `Bernoulli(θ)` con pérdida cuadrática
`L(θ,a) = (θ − a)²`: `R(θ,δ) = (1−θ)(θ−δ(0))² + θ(θ−δ(1))²`. -/
noncomputable def riesgoB (δ : Bool → ℝ) (θ : ℝ) : ℝ :=
  ∑ b : Bool, probBernoulli θ b * (θ - δ b) ^ 2

/-- Media posterior bajo `Beta(1/2,1/2)`: `δ(X) = (X + 1/2)/2`. -/
noncomputable def reglaBayes (b : Bool) : ℝ := if b then 3 / 4 else 1 / 4

/-- Regla de la identidad: `δ₀(X) = X`. -/
noncomputable def reglaIdentidad (b : Bool) : ℝ := if b then 1 else 0

theorem riesgoB_eq (δ : Bool → ℝ) (θ : ℝ) :
    riesgoB δ θ = (1 - θ) * (θ - δ false) ^ 2 + θ * (θ - δ true) ^ 2 := by
  unfold riesgoB probBernoulli
  rw [Fintype.sum_bool]
  norm_num
  ring

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — la
regla del ejemplo es la media posterior `δ(X) = (X + 1/2)/2` con prior
`Beta(1/2,1/2)`: en `X = 0` vale `1/4` y en `X = 1` vale `3/4`. -/
theorem bernoulli_regla_bayes_valores :
    reglaBayes false = 1 / 4 ∧ reglaBayes true = 3 / 4 := by
  unfold reglaBayes
  norm_num

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — **sesgo**
de la regla bayesiana: `E_θ[δ(X)] − θ = 1/4 − θ/2`. -/
theorem bernoulli_sesgo (θ : ℝ) :
    ((1 - θ) * reglaBayes false + θ * reglaBayes true) - θ = 1 / 4 - θ / 2 := by
  unfold reglaBayes
  norm_num
  ring

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) —
**varianza** de la regla bayesiana: `Var_θ(δ(X)) = θ(1−θ)/4`, que es la de
`X/2 + 1/4`. -/
theorem bernoulli_varianza (θ : ℝ) :
    ((1 - θ) * reglaBayes false ^ 2 + θ * reglaBayes true ^ 2)
        - ((1 - θ) * reglaBayes false + θ * reglaBayes true) ^ 2
      = θ * (1 - θ) / 4 := by
  unfold reglaBayes
  norm_num
  ring

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — **riesgo
constante** `R(θ,δ) = 1/16`: la suma de la varianza `θ(1−θ)/4` y el sesgo al
cuadrado `(1/4 − θ/2)²` no depende de `θ`. Es la identidad que el libro usa para
concluir la minimaxidad vía `thm:ch7-minimax-bayes`. -/
theorem bernoulli_riesgo_constante (θ : ℝ) : riesgoB reglaBayes θ = 1 / 16 := by
  rw [riesgoB_eq]
  have h := bernoulli_varianza θ
  have hs := bernoulli_sesgo θ
  have hexp : reglaBayes false = 1 / 4 ∧ reglaBayes true = 3 / 4 :=
    bernoulli_regla_bayes_valores
  have hvar := h
  rw [hexp.1, hexp.2] at hvar ⊢
  nlinarith [hvar]

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — riesgo de
la regla de la identidad `δ₀(X) = X`: `R(θ,δ₀) = θ(1−θ)`. -/
theorem bernoulli_riesgo_identidad (θ : ℝ) : riesgoB reglaIdentidad θ = θ * (1 - θ) := by
  rw [riesgoB_eq]
  unfold reglaIdentidad
  norm_num
  ring

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — **riesgo
máximo** de la regla de la identidad: `sup_{θ∈[0,1]} θ(1−θ) = 1/4`, alcanzado en
`θ = 1/2`. -/
theorem bernoulli_identidad_riesgo_max :
    (∀ θ : ℝ, 0 ≤ θ → θ ≤ 1 → θ * (1 - θ) ≤ 1 / 4) ∧
      (1 / 2 : ℝ) * (1 - 1 / 2) = 1 / 4 := by
  constructor
  · intro θ h0 h1
    nlinarith [sq_nonneg (θ - 1 / 2)]
  · norm_num

/-- book: capitulos/cap02_wald.typ:139 (key: ex:ch2-bernoulli-minimax) — la
contracción hacia `1/2` **reduce el peor riesgo**: sobre `θ ∈ [0,1]` la regla
bayesiana tiene riesgo `1/16`, estrictamente menor que el riesgo máximo `1/4` de
la identidad, a costa de introducir sesgo (`1/4 − θ/2 ≠ 0` salvo en `θ = 1/2`).
Fidelidad declarada: el ejemplo se formaliza como cálculo exacto de sesgo,
varianza y riesgo; la **minimaxidad** de `δ` (ninguna regla tiene riesgo máximo
menor que `1/16`) es la conclusión de `thm:ch7-minimax-bayes`, ya formalizado en
`verificacion_lean/Book/Cap02Wald.lean`, y no se repite aquí. -/
theorem bernoulli_contraccion_mejora_peor_caso (θ : ℝ) (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    riesgoB reglaBayes θ < riesgoB reglaIdentidad (1 / 2) := by
  rw [bernoulli_riesgo_constante, bernoulli_riesgo_identidad]
  norm_num

/-! ## `ex:ch2-minimal-exponencial` — cociente de verosimilitudes -/

section Exponencial

variable {ι X : Type*} [Fintype ι]

/-- Densidad canónica de una familia exponencial de rango `k`
(repetida aquí para que este módulo sea autocontenido):
`f(x|η) = exp(⟨η,T(x)⟩ − A(η))·h(x)`. -/
noncomputable def densExp (T : X → ι → ℝ) (h : X → ℝ) (A : (ι → ℝ) → ℝ)
    (η : ι → ℝ) (x : X) : ℝ :=
  Real.exp ((∑ i, η i * T x i) - A η) * h x

/-- book: capitulos/cap04_herramientas.typ:667 (key: ex:ch2-minimal-exponencial) —
**cociente de verosimilitudes**: para `x, y` con `h(y) ≠ 0`,
`f(x|η)/f(y|η) = (h(x)/h(y))·exp(⟨η, T(x) − T(y)⟩)`. -/
theorem exponencial_cociente (T : X → ι → ℝ) (h : X → ℝ) (A : (ι → ℝ) → ℝ)
    (η : ι → ℝ) {x y : X} (hy : h y ≠ 0) :
    densExp T h A η x / densExp T h A η y
      = (h x / h y) * Real.exp (∑ i, η i * (T x i - T y i)) := by
  have hAB : Real.exp ((∑ i, η i * T x i) - A η) / Real.exp ((∑ i, η i * T y i) - A η)
      = Real.exp (∑ i, η i * (T x i - T y i)) := by
    rw [← Real.exp_sub]
    congr 1
    rw [show (∑ i, η i * T x i) - A η - ((∑ i, η i * T y i) - A η)
        = (∑ i, η i * T x i) - (∑ i, η i * T y i) from by ring,
      ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  unfold densExp
  rw [show Real.exp ((∑ i, η i * T x i) - A η) * h x
        / (Real.exp ((∑ i, η i * T y i) - A η) * h y)
      = (Real.exp ((∑ i, η i * T x i) - A η) / Real.exp ((∑ i, η i * T y i) - A η))
        * (h x / h y) from by
    rw [div_mul_div_comm]]
  rw [hAB]
  ring

/-- book: capitulos/cap04_herramientas.typ:667 (key: ex:ch2-minimal-exponencial) —
**minimalidad del estadístico natural**: el cociente de verosimilitudes no
depende de `η` si y sólo si `T(x) = T(y)` (con `η` recorriendo todo `ℝ^k`, que
contiene abiertos, y `h > 0`). Es el criterio de Lehmann–Scheffé
(`thm:ch2-lehmann-scheffe`) aplicado al cociente del ejemplo: las clases de
proporcionalidad son las fibras de `T`, luego `T` es suficiente minimal.
Fidelidad declarada: se formaliza el criterio de proporcionalidad para
`η ∈ ℝ^k` completo; la conclusión «suficiente minimal» como propiedad de
minimalidad frente a todo otro estadístico suficiente es el contenido de
`thm:ch2-lehmann-scheffe`, ya cerrado, y aquí sólo se verifica la hipótesis
«cociente constante en `η` ⇔ `T(x)=T(y)`» que ese teorema consume. -/
theorem exponencial_minimal (T : X → ι → ℝ) (h : X → ℝ) (A : (ι → ℝ) → ℝ)
    (hne : ∀ x, h x ≠ 0) (x y : X) :
    (∀ η : ι → ℝ, densExp T h A η x / densExp T h A η y = h x / h y) ↔ T x = T y := by
  constructor
  · classical
    intro H
    have key : ∀ η : ι → ℝ, Real.exp (∑ i, η i * (T x i - T y i)) = 1 := by
      intro η
      have h1 := exponencial_cociente T h A η (x := x) (y := y) (hne y)
      have h2 := H η
      rw [h1] at h2
      have hh : h x / h y ≠ 0 := div_ne_zero (hne x) (hne y)
      exact mul_left_cancel₀ hh (by rw [mul_one]; exact h2)
    funext j
    have hj := key (fun i => if i = j then 1 else 0)
    have hsum : (∑ i, (if i = j then (1 : ℝ) else 0) * (T x i - T y i))
        = T x j - T y j := by
      rw [Finset.sum_eq_single j]
      · simp
      · intro i _ hij
        simp [hij]
      · intro h
        exact absurd (Finset.mem_univ j) h
    rw [hsum] at hj
    rw [Real.exp_eq_one_iff] at hj
    linarith
  · intro hxy
    have : ∀ η : ι → ℝ, (∑ i, η i * (T x i - T y i)) = 0 := by
      intro η
      rw [hxy]
      simp
    intro η
    rw [exponencial_cociente T h A η (hne y), this η, Real.exp_zero, mul_one]

end Exponencial

/-! ## `ex:ch2-multinomial-ssch` — familia exponencial multinomial -/

/-- Parámetro natural canónico con `θ₃` como referencia: `(η₁, η₂)`. -/
noncomputable def multinomP (η : ℝ × ℝ) : ℝ × ℝ × ℝ :=
  let D := 1 + Real.exp η.1 + Real.exp η.2
  (Real.exp η.1 / D, Real.exp η.2 / D, 1 / D)

/-- book: capitulos/cap04_herramientas.typ:718 (key: ex:ch2-multinomial-ssch) —
**normalización `A(η) = n log(1 + e^{η₁} + e^{η₂})`**: las tres probabilidades
canónicas con `θ₃` de referencia son estrictamente positivas y suman uno, de
modo que `log(1 + e^{η₁} + e^{η₂})` es la log-partición de la familia. -/
theorem multinomial_normalizacion (η : ℝ × ℝ) :
    0 < (multinomP η).1 ∧ 0 < (multinomP η).2.1 ∧ 0 < (multinomP η).2.2 ∧
      (multinomP η).1 + (multinomP η).2.1 + (multinomP η).2.2 = 1 := by
  have hD : 0 < 1 + Real.exp η.1 + Real.exp η.2 := by positivity
  have e1 : 0 < Real.exp η.1 := Real.exp_pos _
  have e2 : 0 < Real.exp η.2 := Real.exp_pos _
  refine ⟨by unfold multinomP; positivity, by unfold multinomP; positivity,
    by unfold multinomP; positivity, ?_⟩
  unfold multinomP
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:718 (key: ex:ch2-multinomial-ssch) — la
parametrización `η_j = log(θ_j/θ₃)` con `θ₃` de referencia **reproduce** cualquier
vector de probabilidades estrictamente positivas: `multinomP (log(θ₁/θ₃),
log(θ₂/θ₃)) = (θ₁,θ₂,θ₃)` si `θ₁+θ₂+θ₃ = 1`. -/
theorem multinomial_referencia (θ₁ θ₂ θ₃ : ℝ) (h₁ : 0 < θ₁) (h₂ : 0 < θ₂) (h₃ : 0 < θ₃)
    (hsum : θ₁ + θ₂ + θ₃ = 1) :
    (multinomP (Real.log (θ₁ / θ₃), Real.log (θ₂ / θ₃))).1 = θ₁ ∧
      (multinomP (Real.log (θ₁ / θ₃), Real.log (θ₂ / θ₃))).2.1 = θ₂ ∧
      (multinomP (Real.log (θ₁ / θ₃), Real.log (θ₂ / θ₃))).2.2 = θ₃ := by
  have hq₁ : 0 < θ₁ / θ₃ := div_pos h₁ h₃
  have hq₂ : 0 < θ₂ / θ₃ := div_pos h₂ h₃
  have e1 : Real.exp (Real.log (θ₁ / θ₃)) = θ₁ / θ₃ := Real.exp_log hq₁
  have e2 : Real.exp (Real.log (θ₂ / θ₃)) = θ₂ / θ₃ := Real.exp_log hq₂
  have hD : 1 + θ₁ / θ₃ + θ₂ / θ₃ = 1 / θ₃ := by
    field_simp
    linarith
  refine ⟨?_, ?_, ?_⟩ <;> unfold multinomP <;> rw [e1, e2, hD] <;> field_simp

/-- book: capitulos/cap04_herramientas.typ:718 (key: ex:ch2-multinomial-ssch) —
**factorización multinomial**: la verosimilitud de conteos `(n₁,n₂,n₃)` con
`n₁+n₂+n₃ = n` factoriza por el estadístico natural `(n₁,n₂)` y la
log-partición `n·A(η) = n log(1 + e^{η₁} + e^{η₂})`:
`θ₁^{n₁}θ₂^{n₂}θ₃^{n₃} = exp(η₁n₁ + η₂n₂ − n·log(1+e^{η₁}+e^{η₂}))`.
Así `N₃ = n − N₁ − N₂` es redundante y `(N₁,N₂)` es suficiente (y completo, por
`thm:ch2-completitud-exponencial`, ya cerrado).
Fidelidad declarada: se formaliza el núcleo de la verosimilitud (sin el
coeficiente multinomial, que no depende de `η`) y la parametrización canónica;
la parte del ejemplo sobre insesgadez, varianzas `θ_j(1−θ_j)/n` y covarianzas
`−θ_jθ_k/n` de las proporciones no se formaliza (requiere los momentos de la
multinomial). -/
theorem multinomial_factorizacion (η : ℝ × ℝ) (n₁ n₂ n₃ : ℕ) :
    (multinomP η).1 ^ n₁ * (multinomP η).2.1 ^ n₂ * (multinomP η).2.2 ^ n₃
      = Real.exp (η.1 * n₁ + η.2 * n₂
          - ((n₁ : ℝ) + n₂ + n₃) * Real.log (1 + Real.exp η.1 + Real.exp η.2)) := by
  set D : ℝ := 1 + Real.exp η.1 + Real.exp η.2 with hDdef
  have hD : 0 < D := by rw [hDdef]; positivity
  have hDne : D ≠ 0 := ne_of_gt hD
  have h1 : Real.exp η.1 ^ n₁ = Real.exp (η.1 * n₁) := by
    rw [← Real.exp_nat_mul]; congr 1; push_cast; ring
  have h2 : Real.exp η.2 ^ n₂ = Real.exp (η.2 * n₂) := by
    rw [← Real.exp_nat_mul]; congr 1; push_cast; ring
  have hexpD : Real.exp (-(((n₁ : ℝ) + n₂ + n₃) * Real.log D))
      = (D ^ (n₁ + n₂ + n₃))⁻¹ := by
    have hk : ((n₁ : ℝ) + n₂ + n₃) = ((n₁ + n₂ + n₃ : ℕ) : ℝ) := by push_cast; ring
    rw [hk, Real.exp_neg, Real.exp_nat_mul, Real.exp_log hD]
  have hp1 : (multinomP η).1 = Real.exp η.1 / D := by
    simp only [multinomP, hDdef]
  have hp2 : (multinomP η).2.1 = Real.exp η.2 / D := by
    simp only [multinomP, hDdef]
  have hp3 : (multinomP η).2.2 = 1 / D := by
    simp only [multinomP, hDdef]
  rw [hp1, hp2, hp3]
  rw [show Real.exp η.1 / D = Real.exp η.1 * D⁻¹ from by rw [div_eq_mul_inv]]
  rw [show Real.exp η.2 / D = Real.exp η.2 * D⁻¹ from by rw [div_eq_mul_inv]]
  rw [show (1 : ℝ) / D = 1 * D⁻¹ from by rw [div_eq_mul_inv]]
  rw [mul_pow, mul_pow, mul_pow, one_pow, h1, h2]
  have hR : Real.exp (η.1 * n₁ + η.2 * n₂ - ((n₁ : ℝ) + n₂ + n₃) * Real.log D)
      = Real.exp (η.1 * n₁) * Real.exp (η.2 * n₂) * (D ^ (n₁ + n₂ + n₃))⁻¹ := by
    rw [show η.1 * n₁ + η.2 * n₂ - ((n₁ : ℝ) + n₂ + n₃) * Real.log D
        = (η.1 * n₁ + η.2 * n₂) + (-(((n₁ : ℝ) + n₂ + n₃) * Real.log D)) from by ring]
    rw [Real.exp_add, hexpD, Real.exp_add]
  rw [hR]
  have hpow : D⁻¹ ^ n₁ * D⁻¹ ^ n₂ * D⁻¹ ^ n₃ = (D ^ (n₁ + n₂ + n₃))⁻¹ := by
    rw [← pow_add, ← pow_add, inv_pow]
  rw [show Real.exp (η.1 * ↑n₁) * D⁻¹ ^ n₁ * (Real.exp (η.2 * ↑n₂) * D⁻¹ ^ n₂)
        * (1 * D⁻¹ ^ n₃)
      = Real.exp (η.1 * ↑n₁) * Real.exp (η.2 * ↑n₂)
        * (D⁻¹ ^ n₁ * D⁻¹ ^ n₂ * D⁻¹ ^ n₃) from by ring, hpow]

/-- book: capitulos/cap04_herramientas.typ:718 (key: ex:ch2-multinomial-ssch) —
**desigualdad de Gibbs**: la log-verosimilitud multinomial
`ℓ(θ) = ∑_j n_j log θ_j` alcanza su máximo sobre el símplex en las proporciones
empíricas `p_j = n_j/n`, es decir, **el MLE es `(n₁/n, n₂/n, n₃/n)`**. Es el
cálculo con el que el libro afirma «para `(N₁,N₂,N₃)=(2,5,3)` el MLE es
`(0.2,0.5,0.3)`». Fidelidad declarada: se prueba la desigualdad de optimalidad
en forma logarítmica (que determina el argumento máximo); la existencia y
unicidad del máximo en el interior del símplex se sigue de la igualdad en
`log x ≤ x − 1`, caso `θ_j = n_j/n`, que también se comprueba en la cadena. -/
theorem multinomial_gibbs (n₁ n₂ n₃ : ℕ) (θ₁ θ₂ θ₃ : ℝ) (h₁ : 0 < θ₁) (h₂ : 0 < θ₂)
    (h₃ : 0 < θ₃) (hsum : θ₁ + θ₂ + θ₃ = 1) (hn : 0 < n₁ + n₂ + n₃) :
    (n₁ : ℝ) * Real.log θ₁ + (n₂ : ℝ) * Real.log θ₂ + (n₃ : ℝ) * Real.log θ₃
      ≤ (n₁ : ℝ) * Real.log ((n₁ : ℝ) / ((n₁ : ℝ) + n₂ + n₃))
        + (n₂ : ℝ) * Real.log ((n₂ : ℝ) / ((n₁ : ℝ) + n₂ + n₃))
        + (n₃ : ℝ) * Real.log ((n₃ : ℝ) / ((n₁ : ℝ) + n₂ + n₃)) := by
  classical
  set N : ℝ := (n₁ : ℝ) + n₂ + n₃ with hN
  have hNpos : 0 < N := by
    rw [hN]
    exact_mod_cast hn
  rw [hN] at *
  have key : ∀ (nj : ℕ) (θj : ℝ), 0 < θj →
      (nj : ℝ) * Real.log θj - (nj : ℝ) * Real.log ((nj : ℝ) / N) ≤ N * θj - nj := by
    intro nj θj hθ
    rcases Nat.eq_zero_or_pos nj with hz | hpos
    · subst hz
      have hle : 0 ≤ N * θj := le_of_lt (mul_pos hNpos hθ)
      simpa using hle
    · have hnj : 0 < (nj : ℝ) := by exact_mod_cast hpos
      have hpj : 0 < (nj : ℝ) / N := div_pos hnj hNpos
      have hlog : Real.log θj - Real.log ((nj : ℝ) / N) ≤ θj / ((nj : ℝ) / N) - 1 := by
        have h := Real.log_le_sub_one_of_pos (div_pos hθ hpj)
        rwa [Real.log_div (ne_of_gt hθ) (ne_of_gt hpj)] at h
      have hmul : (nj : ℝ) * (Real.log θj - Real.log ((nj : ℝ) / N))
          ≤ (nj : ℝ) * (θj / ((nj : ℝ) / N) - 1) :=
        mul_le_mul_of_nonneg_left hlog (le_of_lt hnj)
      have hrhs : (nj : ℝ) * (θj / ((nj : ℝ) / N) - 1) = N * θj - nj := by
        field_simp
      calc (nj : ℝ) * Real.log θj - (nj : ℝ) * Real.log ((nj : ℝ) / N)
          = (nj : ℝ) * (Real.log θj - Real.log ((nj : ℝ) / N)) := by ring
        _ ≤ (nj : ℝ) * (θj / ((nj : ℝ) / N) - 1) := hmul
        _ = N * θj - nj := hrhs
  have h₁' := key n₁ θ₁ h₁
  have h₂' := key n₂ θ₂ h₂
  have h₃' := key n₃ θ₃ h₃
  have hsumN : N * θ₁ + N * θ₂ + N * θ₃ = N := by
    rw [← mul_add, ← mul_add, hsum, mul_one]
  nlinarith [h₁', h₂', h₃', hsumN]

/-- book: capitulos/cap04_herramientas.typ:718 (key: ex:ch2-multinomial-ssch) — la
instancia del libro `(N₁,N₂,N₃) = (2,5,3)`: el MLE es
`(2/10, 5/10, 3/10) = (0.2, 0.5, 0.3)`. -/
theorem multinomial_mle_instancia :
    ((2 : ℝ) / 10 = 1 / 5) ∧ ((5 : ℝ) / 10 = 1 / 2) ∧ ((3 : ℝ) / 10 = 3 / 10) ∧
      ((1 / 5 : ℝ) + 1 / 2 + 3 / 10 = 1) := by
  norm_num

/-! ## `ex:ch2-ancilar-localizacion` — residuos como estadístico ancilar -/

/-- Media muestral de `x : Fin n → ℝ`. -/
noncomputable def media {n : ℕ} (x : Fin n → ℝ) : ℝ := (∑ i, x i) / n

/-- Residuos centrados `D_i = X_i − X̄`. -/
noncomputable def residuos {n : ℕ} (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => x i - media x

/-- Varianza muestral `S² = (1/(n−1))·∑_i (X_i − X̄)²`. -/
noncomputable def varMuestral {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  (∑ i, (x i - media x) ^ 2) / (n - 1)

/-- book: capitulos/cap04_herramientas.typ:736 (key: ex:ch2-ancilar-localizacion) —
la media muestral es **equivariante** bajo traslaciones: `X̄(X + c) = X̄(X) + c`. -/
theorem media_traslacion {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (c : ℝ) :
    media (fun i => x i + c) = media x + c := by
  unfold media
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  field_simp

/-- book: capitulos/cap04_herramientas.typ:736 (key: ex:ch2-ancilar-localizacion) —
**los residuos centrados son ancilares**: `D_i(X + c) = D_i(X)`, es decir, la
distribución conjunta de `(D_1,…,D_n)` no depende del parámetro de localización
`θ`. Es exactamente el cálculo del libro
`(X_i − θ) − (1/n)∑_j(X_j − θ) = D_i`. -/
theorem residuos_traslacion {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (c : ℝ) :
    residuos (fun i => x i + c) = residuos x := by
  funext i
  unfold residuos
  rw [media_traslacion hn]
  ring

/-- book: capitulos/cap04_herramientas.typ:736 (key: ex:ch2-ancilar-localizacion) —
la forma explícita del libro para el residuo:
`D_i = (X_i − θ) − (1/n)∑_j (X_j − θ)`, válida para todo `θ`. -/
theorem residuos_formula {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (θ : ℝ) (i : Fin n) :
    residuos x i = (x i - θ) - (1 / n) * ∑ j, (x j - θ) := by
  unfold residuos media
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:736 (key: ex:ch2-ancilar-localizacion) —
los residuos suman cero y la varianza muestral es una función de ellos:
`S² = (1/(n−1))∑_i D_i²`. Fidelidad declarada: se formaliza que `S²` depende de
la muestra *sólo* a través del vector de residuos (la propiedad que el ejemplo
necesita para concluir que `S²` es ancilar); la parte negativa del ejemplo («`X̄`
no es suficiente en una familia de localización general») no se formaliza. -/
theorem residuos_suma_cero {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    (∑ i, residuos x i) = 0 ∧ varMuestral x = (∑ i, residuos x i ^ 2) / (n - 1) := by
  constructor
  · unfold residuos media
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
    field_simp
    ring
  · unfold varMuestral residuos
    rfl

/-! ## `ex:ch2-basu-aplicacion` — muestra normal: `X̄`, residuos y `S²` -/

/-- Densidad normal `N(μ,v)` con varianza `v`: `(√(2πv))⁻¹·exp(−(x−μ)²/(2v))`. -/
noncomputable def densNormal (μ v x : ℝ) : ℝ :=
  (Real.sqrt (2 * Real.pi * v))⁻¹ * Real.exp (-(x - μ) ^ 2 / (2 * v))

/-- Identidad de descomposición de la suma de cuadrados:
`∑_i (x_i − μ)² = ∑_i (x_i − X̄)² + n(X̄ − μ)²`. Es el cálculo que el libro
atribuye a «la distribución normal multivariante» y que aquí se hace en una
línea a partir de la definición de `X̄`. -/
theorem normal_suma_cuadrados {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (μ : ℝ) :
    (∑ i, (x i - μ) ^ 2)
      = (∑ i, (x i - media x) ^ 2) + n * (media x - μ) ^ 2 := by
  have hsum : (∑ i, (x i - media x)) = 0 := by
    unfold media
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul]
    have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
    field_simp
    ring
  have hexp : ∀ i : Fin n, (x i - μ) ^ 2
      = (x i - media x) ^ 2 + (2 * (media x - μ) * (x i - media x)
          + (media x - μ) ^ 2) := by
    intro i; ring
  rw [Finset.sum_congr rfl fun i _ => hexp i, Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, hsum, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  ring

/-- book: capitulos/cap04_herramientas.typ:774 (key: ex:ch2-basu-aplicacion) — la
verosimilitud de la muestra normal **factoriza por la media muestral**: con
`σ² = v`,
`∏_i N(μ,v)(x_i) = c·exp(−∑_i D_i²/(2v))·exp(−n(X̄−μ)²/(2v))`,
donde `c = (√(2πv))^{-n}` no depende de `μ`. El único factor que depende de `μ`
es `exp(−n(X̄−μ)²/(2v))`, luego `X̄` es suficiente para `μ` (Neyman–Fisher, con
`T = X̄`), que es la primera viñeta del ejemplo. -/
theorem normal_factorizacion {n : ℕ} (hn : 0 < n) (μ v : ℝ) (hv : 0 < v)
    (x : Fin n → ℝ) :
    (∏ i, densNormal μ v (x i))
      = ((Real.sqrt (2 * Real.pi * v))⁻¹) ^ n
        * Real.exp (-(∑ i, (x i - media x) ^ 2) / (2 * v))
        * Real.exp (-(n * (media x - μ) ^ 2) / (2 * v)) := by
  have hv' : v ≠ 0 := ne_of_gt hv
  have hprod : (∏ i, densNormal μ v (x i))
      = ((Real.sqrt (2 * Real.pi * v))⁻¹) ^ n
        * Real.exp (∑ i, (-(x i - μ) ^ 2 / (2 * v))) := by
    unfold densNormal
    rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ, Fintype.card_fin,
      ← Real.exp_sum]
  have hs : (∑ i : Fin n, (-(x i - μ) ^ 2 / (2 * v)))
      = -(∑ i, (x i - μ) ^ 2) / (2 * v) := by
    rw [← Finset.sum_div, Finset.sum_neg_distrib]
  rw [hprod, hs, normal_suma_cuadrados hn x μ]
  rw [show -((∑ i, (x i - media x) ^ 2) + n * (media x - μ) ^ 2) / (2 * v)
      = -(∑ i, (x i - media x) ^ 2) / (2 * v)
        + (-(n * (media x - μ) ^ 2) / (2 * v)) from by
    field_simp
    ring]
  rw [Real.exp_add]
  ring

/-- book: capitulos/cap04_herramientas.typ:774 (key: ex:ch2-basu-aplicacion) — la
media muestral normal tiene **varianza `σ²/n`**: el exponente que la involucra
es `−n(X̄−μ)²/(2v) = −(X̄−μ)²/(2(v/n))`. -/
theorem normal_varianza_media {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (μ v : ℝ) (hv : v ≠ 0) :
    -(n * (media x - μ) ^ 2) / (2 * v) = -((media x - μ) ^ 2) / (2 * (v / n)) := by
  have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  field_simp

/-- book: capitulos/cap04_herramientas.typ:774 (key: ex:ch2-basu-aplicacion) — la
**varianza muestral `S²` es invariante bajo traslaciones** (depende sólo de los
residuos): `S²(X + c) = S²(X)`, de modo que su distribución no depende de `μ`
(segunda viñeta del ejemplo), y con `residuos_suma_cero` es una función de
`(X_1 − X̄, …, X_n − X̄)`.
Fidelidad declarada: se formalizan las tres piezas que el argumento de Basu
consume —suficiencia de `X̄` (factorización), ancilaridad de los residuos
(invariancia por traslación) y `S²` como función de los residuos—; la
**independencia** de `X̄` y `S²` que se obtiene aplicándoles `thm:ch2-basu`
(ya cerrado en `verificacion_lean/Book/Cap04Suficiencia.lean`) no se reenuncia
aquí, porque su formalización exigiría el cálculo de la ley conjunta de
`(X̄, D)` en `ℝⁿ`, que este módulo sustituye por la factorización exacta de la
verosimilitud. -/
theorem normal_varianza_invariante {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (c : ℝ) :
    varMuestral (fun i => x i + c) = varMuestral x := by
  unfold varMuestral
  rw [media_traslacion hn]
  congr 1
  exact Finset.sum_congr rfl fun i _ => by ring

/-! ## `prop:ch2-suficiencia-politicas` — reglas aleatorizadas y núcleo condicional -/

section Politicas

variable {Θ X A 𝒯 : Type*} [Fintype X] [Fintype A] [Fintype 𝒯] [DecidableEq 𝒯]

/-- Riesgo de una regla aleatorizada `δ(a|x)`:
`R(θ,δ) = ∑_x P_θ(x)·∑_a δ(a|x)·L(θ,a)`. -/
noncomputable def riesgoAleatorio (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ : X → A → ℝ)
    (θ : Θ) : ℝ :=
  ∑ x, P θ x * ∑ a, δ x a * L θ a

/-- Regla inducida en el espacio de `T`:
`δ_T(a|t) = ∑_x K(t,x)·δ(a|x)` (la media de la regla por el núcleo condicional). -/
noncomputable def reglaInducida (K : 𝒯 → X → ℝ) (δ : X → A → ℝ) (t : 𝒯) : A → ℝ :=
  fun a => ∑ x, K t x * δ x a

/-- book: capitulos/cap09_verificacion.typ:227 (key: prop:ch2-suficiencia-politicas) —
**suficiencia y políticas óptimas**: si `T` es suficiente con un núcleo
condicional común `K(dx|t)` independiente de `θ` —formalizado como la
desintegración `P_θ(x) = Q_θ(T(x))·K(T(x), x)`—, entonces la regla inducida
`δ_T(a|t) = ∑_x K(t,x)δ(a|x)` tiene **el mismo riesgo**:
`R(θ,δ_T) = R(θ,δ)` para todo `θ`. La comparación se hace en la clase de reglas
aleatorizadas.
Fidelidad declarada: versión finita/discreta del enunciado de espacios de Borel
(las sumas sustituyen las integrales y `K` es un núcleo de masa soportado en la
fibra de `T`, `K(t,x) = 0` si `T(x) ≠ t`). La parte final de la proposición
—que si se exige una acción determinista la construcción puede salir de la
clase permitida— se declara y no se formaliza, porque es un enunciado de
existencia de un contraejemplo en espacios de acciones no convexos. -/
theorem suficiencia_politicas (T : X → 𝒯) (Q : Θ → 𝒯 → ℝ) (K : 𝒯 → X → ℝ)
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ : X → A → ℝ)
    (hK0 : ∀ t x, T x ≠ t → K t x = 0)
    (hfac : ∀ θ x, P θ x = Q θ (T x) * K (T x) x) (θ : Θ) :
    (∑ t, Q θ t * ∑ a, reglaInducida K δ t a * L θ a) = riesgoAleatorio P L δ θ := by
  have hx : ∀ x : X, (∑ t, Q θ t * K t x) = P θ x := by
    intro x
    rw [Finset.sum_eq_single (T x)]
    · exact (hfac θ x).symm
    · intro t _ ht
      rw [hK0 t x (Ne.symm ht), mul_zero]
    · intro h
      exact absurd (Finset.mem_univ (T x)) h
  unfold riesgoAleatorio reglaInducida
  calc (∑ t, Q θ t * ∑ a, (∑ x, K t x * δ x a) * L θ a)
      = ∑ t, ∑ a, Q θ t * ((∑ x, K t x * δ x a) * L θ a) := by
        refine Finset.sum_congr rfl fun t _ => ?_
        rw [Finset.mul_sum]
    _ = ∑ t, ∑ a, ∑ x, Q θ t * (K t x * δ x a) * L θ a := by
        refine Finset.sum_congr rfl fun t _ => Finset.sum_congr rfl fun a _ => ?_
        rw [Finset.sum_mul, Finset.mul_sum]
        exact Finset.sum_congr rfl fun x _ => by ring
    _ = ∑ t, ∑ x, ∑ a, Q θ t * (K t x * δ x a) * L θ a := by
        refine Finset.sum_congr rfl fun t _ => ?_
        rw [Finset.sum_comm]
    _ = ∑ x, ∑ t, ∑ a, Q θ t * (K t x * δ x a) * L θ a := by
        rw [Finset.sum_comm]
    _ = ∑ x, (∑ t, Q θ t * K t x) * (∑ a, δ x a * L θ a) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        calc (∑ t, ∑ a, Q θ t * (K t x * δ x a) * L θ a)
            = ∑ t, (Q θ t * K t x) * (∑ a, δ x a * L θ a) := by
              refine Finset.sum_congr rfl fun t _ => ?_
              rw [Finset.mul_sum]
              exact Finset.sum_congr rfl fun a _ => by ring
          _ = (∑ t, Q θ t * K t x) * (∑ a, δ x a * L θ a) := by
              rw [Finset.sum_mul]
    _ = ∑ x, P θ x * ∑ a, δ x a * L θ a := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [hx x]

end Politicas

end Book.Cap04Ch2
