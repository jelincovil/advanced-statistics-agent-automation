import Mathlib

/-!
# Book.Cap04Ejemplos — verificación de ejemplos numéricos del cap. 4

Módulo de control de calidad: los ejemplos del capítulo
`capitulos/cap04_herramientas.typ` que enuncian **identidades y valores
numéricos exactos** se formalizan aquí tal como el libro los afirma, en su
forma exacta (racionales, no flotantes) y sin debilitar el enunciado.

Fidelidad declarada: el libro trabaja con esperanzas bajo un modelo
paramétrico; aquí se verifica el núcleo aritmético/algebraico que el libro
usa (las identidades de sesgo-varianza-ECM, la forma exponencial de las
densidades y las derivadas de la log-partición). Donde el libro enuncia una
esperanza bajo una ley concreta, se declara la versión finita: la suma
sobre `Fin n` con pesos.

Sin «s-o-r-r-y»; cada teorema se audita con `#print axioms` en
`work/Book/AuditEjemplos.lean`.
-/

set_option linter.unusedVariables false

open Finset BigOperators

namespace Book.Cap04Ejemplos

/-! ## ex:ch1-calculo-numerico -/

/-- book: capitulos/cap04_herramientas.typ:263 (key: ex:ch1-calculo-numerico) —
Cálculo numérico de sesgo, varianza y ECM con cinco indicadores. La muestra
sintética `(1,0,1,0,1)` da `θ̂₁ = x̄ = 0.6` y `θ̂₂ = 0.9 x̄ = 0.54`: son
valores observados, no esperanzas. Fidelidad declarada: la media muestral es
la suma sobre `Fin 5` dividida por `5`; no interviene ninguna ley de
probabilidad. -/
theorem ch1_calculo_numerico_observado :
    (([1, 0, 1, 0, 1] : List ℝ).sum / 5 = 3 / 5)
      ∧ (9 / 10) * (([1, 0, 1, 0, 1] : List ℝ).sum / 5) = 27 / 50 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:263 (key: ex:ch1-calculo-numerico) —
riesgos de los dos estimadores del ejemplo en `θ = 1/2`: el insesgado
`θ(1−θ)/5` vale `0.05` y el contraído `0.81 θ(1−θ)/5 + 0.01 θ²` vale
`0.043`. -/
theorem ch1_calculo_numerico_riesgos_en_medio :
    (1 / 2 : ℝ) * (1 - 1 / 2) / 5 = 1 / 20
      ∧ (81 / 100) * ((1 / 2 : ℝ) * (1 - 1 / 2) / 5) + (1 / 100) * (1 / 2 : ℝ) ^ 2
          = 43 / 1000 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:263 (key: ex:ch1-calculo-numerico) —
el contraído mejora el ECM para `0 < θ < 19/24` y lo empeora para
`θ > 19/24` (la frontera es exacta: `24θ − 19 = 0`). En particular menor
varianza no ordena por sí sola las reglas de decisión. -/
theorem ch1_calculo_numerico_frontera (θ : ℝ) (hθ : 0 < θ) :
    ((81 / 100) * (θ * (1 - θ) / 5) + (1 / 100) * θ ^ 2 < θ * (1 - θ) / 5
        ↔ θ < 19 / 24)
      ∧ (θ * (1 - θ) / 5 < (81 / 100) * (θ * (1 - θ) / 5) + (1 / 100) * θ ^ 2
        ↔ 19 / 24 < θ) := by
  have h₁ : θ * (1 - θ) / 5 - ((81 / 100) * (θ * (1 - θ) / 5) + (1 / 100) * θ ^ 2)
      = θ * (19 - 24 * θ) / 500 := by
    field_simp
    ring
  have h₂ : (81 / 100) * (θ * (1 - θ) / 5) + (1 / 100) * θ ^ 2 - θ * (1 - θ) / 5
      = θ * (24 * θ - 19) / 500 := by
    field_simp
    ring
  constructor
  · rw [← sub_pos, h₁]
    constructor
    · intro hpos
      nlinarith
    · intro hlt
      have hpos : 0 < 19 - 24 * θ := by nlinarith
      positivity
  · rw [← sub_pos, h₂]
    constructor
    · intro hpos
      nlinarith
    · intro hgt
      have hpos : 0 < 24 * θ - 19 := by nlinarith
      positivity


/-! ## ex:ch5-cociente — varianza asintótica del cociente (método delta) -/

/-- book: capitulos/cap04_herramientas.typ:1593 (key: ex:ch5-cociente) —
método delta para `g(x,y) = x/y`: con `∇g = (1/μ_Y, −μ_X/μ_Y²)` y
`Σ = [[σ_X², σ_XY], [σ_XY, σ_Y²]]`, la varianza asintótica de `X̄/Ȳ` es
`(1/n) ∇gᵀ Σ ∇g = 1/(n μ_Y²)(σ_X² − 2 (μ_X/μ_Y) σ_XY + (μ_X²/μ_Y²) σ_Y²)`.
Aquí se verifica la identidad de la forma cuadrática (el factor `1/n` es
escalado y se omite); fidelidad declarada: parte algebraica exacta del
método delta, sin la normalidad asintótica. -/
theorem ch5_cociente_delta (sx2 sy2 sxy mx my : ℝ) (hmy : my ≠ 0) :
    (1 / my) ^ 2 * sx2 + 2 * ((1 / my) * (-(mx / my ^ 2))) * sxy
        + (-(mx / my ^ 2)) ^ 2 * sy2
      = 1 / my ^ 2 * (sx2 - 2 * (mx / my) * sxy + (mx ^ 2 / my ^ 2) * sy2) := by
  field_simp
  ring_nf

/-- book: capitulos/cap04_herramientas.typ:1593 (key: ex:ch5-cociente) —
interpretación del libro: si `μ_X/μ_Y > 0` y la covarianza muestral es
positiva, la varianza del cociente es estrictamente menor que la que
resultaría de `σ_XY = 0`; de ahí el interés de comparaciones pareadas. -/
theorem ch5_cociente_covarianza (sx2 sy2 sxy mx my : ℝ) (hmy : my ≠ 0)
    (hratio : 0 < mx / my) (hsxy : 0 < sxy) :
    1 / my ^ 2 * (sx2 - 2 * (mx / my) * sxy + (mx ^ 2 / my ^ 2) * sy2)
      < 1 / my ^ 2 * (sx2 + (mx ^ 2 / my ^ 2) * sy2) := by
  have h1 : (0 : ℝ) < 1 / my ^ 2 := by positivity
  have h2 : 2 * (mx / my) * sxy > 0 := by positivity
  rw [← sub_pos]
  have : 1 / my ^ 2 * (sx2 + (mx ^ 2 / my ^ 2) * sy2)
      - 1 / my ^ 2 * (sx2 - 2 * (mx / my) * sxy + (mx ^ 2 / my ^ 2) * sy2)
      = 1 / my ^ 2 * (2 * (mx / my) * sxy) := by
    ring
  rw [this]
  positivity

/-! ## ex:ch1-normal — familia normal con varianza conocida -/

/-- book: capitulos/cap04_herramientas.typ:352 (key: ex:ch1-normal) —
expansión de la densidad conjunta normal: al completar el cuadrado,
`exp(−Σ(xᵢ−μ)²/(2σ²)) = exp(−Σxᵢ²/(2σ²)) · exp(η Σxᵢ − nμ²/(2σ²))` con
`η = μ/σ²`, que es la escritura de familia exponencial del libro. -/
theorem ch1_normal_expansion (n : ℕ) (x : Fin n → ℝ) (mu s2 : ℝ) (hs2 : 0 < s2) :
    Real.exp (-(∑ i, (x i - mu) ^ 2) / (2 * s2))
      = Real.exp (-(∑ i, (x i) ^ 2) / (2 * s2))
          * Real.exp (mu * (∑ i, x i) / s2 - (n : ℝ) * mu ^ 2 / (2 * s2)) := by
  have hsum : (∑ i : Fin n, (x i - mu) ^ 2)
      = (∑ i, (x i) ^ 2) - 2 * mu * (∑ i, x i) + (n : ℝ) * mu ^ 2 := by
    calc (∑ i : Fin n, (x i - mu) ^ 2)
        = ∑ i : Fin n, ((x i) ^ 2 - 2 * mu * x i + mu ^ 2) :=
          Finset.sum_congr rfl fun i _ => by ring
      _ = (∑ i : Fin n, (x i) ^ 2) - (∑ i : Fin n, 2 * mu * x i)
            + ∑ _i : Fin n, mu ^ 2 := by
          rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
      _ = (∑ i : Fin n, (x i) ^ 2) - 2 * mu * (∑ i : Fin n, x i) + (n : ℝ) * mu ^ 2 := by
          rw [← Finset.mul_sum, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
            nsmul_eq_mul]
  rw [← Real.exp_add, hsum]
  congr 1
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:352 (key: ex:ch1-normal) —
la verificación del libro: `∂A/∂η = n σ² η = n μ` para la log-partición
`A(η) = n σ² η²/2` en `η = μ/σ²`, que es `E[Σ Xᵢ] = n μ`. -/
theorem ch1_normal_derivada_logparticion (n : ℕ) (s2 mu : ℝ) (hs2 : s2 ≠ 0) :
    deriv (fun eta : ℝ => (n : ℝ) * s2 * eta ^ 2 / 2) (mu / s2) = (n : ℝ) * mu := by
  have hd : HasDerivAt (fun eta : ℝ => (n : ℝ) * s2 * eta ^ 2 / 2)
      ((n : ℝ) * mu) (mu / s2) := by
    have e : ∀ eta : ℝ, (n : ℝ) * s2 * eta ^ 2 / 2 = ((n : ℝ) * s2 / 2) * eta ^ 2 :=
      fun eta => by ring
    simp only [e]
    have h2 : HasDerivAt (fun eta : ℝ => eta ^ 2) (2 * (mu / s2)) (mu / s2) := by
      simpa using hasDerivAt_pow 2 (mu / s2)
    have h3 := h2.const_mul ((n : ℝ) * s2 / 2)
    have hval : ((n : ℝ) * s2 / 2) * (2 * (mu / s2)) = (n : ℝ) * mu := by
      field_simp
    rw [hval] at h3
    exact h3
  exact hd.deriv

/-! ## ex:ch1-binomial — familia Bernoulli/Binomial -/

/-- book: capitulos/cap04_herramientas.typ:370 (key: ex:ch1-binomial) — la
masa binomial en forma exponencial:
`p^x (1−p)^{n−x} = exp(x log(p/(1−p)) + n log(1−p))`, es decir el parámetro
natural es la log-odds `η = log(p/(1−p))` y el estadístico natural `T(x)=x`. -/
theorem ch1_binomial_forma_exponencial (n x : ℕ) (hx : x ≤ n) (p : ℝ)
    (h0 : 0 < p) (h1 : p < 1) :
    p ^ x * (1 - p) ^ (n - x)
      = Real.exp (x * Real.log (p / (1 - p)) + n * Real.log (1 - p)) := by
  have hq : 0 < 1 - p := by linarith
  rw [Real.exp_add, show x * Real.log (p / (1 - p)) = (x : ℝ) * Real.log (p / (1 - p))
        from rfl,
    show n * Real.log (1 - p) = (n : ℝ) * Real.log (1 - p) from rfl,
    Real.exp_nat_mul, Real.exp_nat_mul, Real.exp_log (by positivity), Real.exp_log hq,
    div_pow, pow_sub₀ (1 - p) hq.ne' hx]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:370 (key: ex:ch1-binomial) — la
verificación del libro: `A'(η) = n e^η/(1+e^η) = n p` con log-partición
`A(η) = n log(1+e^η)`; y `p = e^η/(1+e^η)` es la inversa de la log-odds. -/
theorem ch1_binomial_derivada_logparticion (n : ℕ) (eta : ℝ) :
    deriv (fun eta : ℝ => (n : ℝ) * Real.log (1 + Real.exp eta)) eta
      = (n : ℝ) * (Real.exp eta / (1 + Real.exp eta)) := by
  have hpos : (0 : ℝ) < 1 + Real.exp eta := by positivity
  have hd : HasDerivAt (fun eta : ℝ => Real.log (1 + Real.exp eta))
      (Real.exp eta / (1 + Real.exp eta)) eta := by
    have h1 : HasDerivAt (fun eta : ℝ => 1 + Real.exp eta) (Real.exp eta) eta := by
      simpa using (Real.hasDerivAt_exp eta).const_add (1 : ℝ)
    simpa using h1.log hpos.ne'
  have h2 : HasDerivAt (fun eta : ℝ => (n : ℝ) * Real.log (1 + Real.exp eta))
      ((n : ℝ) * (Real.exp eta / (1 + Real.exp eta))) eta :=
    hd.const_mul (n : ℝ)
  exact h2.deriv

/-! ## ex:ch1-poisson — familia Poisson -/

/-- book: capitulos/cap04_herramientas.typ:384 (key: ex:ch1-poisson) — la
densidad conjunta Poisson en forma exponencial:
`λ^{Σxᵢ} e^{−nλ} = exp((log λ) Σxᵢ − nλ)`, con parámetro natural
`η = log λ`, estadístico natural `T(x) = Σxᵢ` y log-partición
`A(η) = n e^η = n λ`. -/
theorem ch1_poisson_forma_exponencial (n : ℕ) (x : Fin n → ℕ) (lam : ℝ)
    (hlam : 0 < lam) :
    lam ^ (∑ i, x i) * Real.exp (-(n : ℝ) * lam)
      = Real.exp ((Real.log lam) * (∑ i, x i) - (n : ℝ) * lam) := by
  rw [show -(n : ℝ) * lam = -((n : ℝ) * lam) by ring, sub_eq_add_neg, Real.exp_add,
    show (Real.log lam) * (∑ i, x i) = ((∑ i, x i : ℕ) : ℝ) * Real.log lam by
      push_cast
      ring,
    Real.exp_nat_mul, Real.exp_log hlam]

/-- book: capitulos/cap04_herramientas.typ:384 (key: ex:ch1-poisson) — la
log-partición `A(η) = n e^η` cumple `A'(η) = n e^η = n λ`, que es `E[ΣXᵢ]`
en el parámetro natural `η = log λ`. -/
theorem ch1_poisson_derivada_logparticion (n : ℕ) (eta : ℝ) :
    deriv (fun eta : ℝ => (n : ℝ) * Real.exp eta) eta = (n : ℝ) * Real.exp eta := by
  rw [deriv_const_mul_field]
  simp

/-! ## ex:ch1-estadisticos-fundamentales / ex:ch2-traslaciones / ex:ch2-escala -/

/-- Media muestral `x̄ = (1/n) Σ xᵢ`. -/
noncomputable def media {n : ℕ} (x : Fin n → ℝ) : ℝ := (∑ i, x i) / n

/-- Varianza muestral insesgada `S² = (1/(n−1)) Σ (xᵢ − x̄)²`. -/
noncomputable def varMuestral {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  (∑ i, (x i - media x) ^ 2) / ((n : ℝ) - 1)

/-- Desviación estándar muestral `S = √(S²)`. -/
noncomputable def desvMuestral {n : ℕ} (x : Fin n → ℝ) : ℝ := Real.sqrt (varMuestral x)

/-- book: capitulos/cap04_herramientas.typ:210 (key: ex:ch1-estadisticos-fundamentales) —
la media muestral es un estadístico: una función de la muestra que no depende
del parámetro. Fidelidad declarada: se formalizan media y varianza muestral
sobre `Fin n`; el rango y los estadísticos de orden del libro no se incluyen
en este módulo. En una muestra constante la media reproduce la constante. -/
theorem ch1_estadisticos_media_constante {n : ℕ} (hn : 0 < n) (y : ℝ) :
    media (fun _ : Fin n => y) = y := by
  unfold media
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  field_simp

/-- book: capitulos/cap04_herramientas.typ:210 (key: ex:ch1-estadisticos-fundamentales) —
la varianza muestral es no negativa (suma de cuadrados sobre `n−1 > 0`), de
modo que la desviación estándar muestral está bien definida. -/
theorem ch1_estadisticos_var_no_negativa {n : ℕ} (hn : 2 ≤ n) (x : Fin n → ℝ) :
    0 ≤ varMuestral x := by
  unfold varMuestral
  have hpos : (0 : ℝ) < (n : ℝ) - 1 := by
    have h2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    linarith
  exact div_nonneg (Finset.sum_nonneg fun i _ => sq_nonneg _) (le_of_lt hpos)

/-- book: capitulos/cap04_herramientas.typ:823 (key: ex:ch2-traslaciones) —
la media muestral es equivariante bajo traslaciones:
`x̄(x₁+c, …, xₙ+c) = x̄(x) + c`, la condición de equivarianza del grupo
`(ℝ, +)`. -/
theorem ch2_traslaciones_media {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (c : ℝ) :
    media (fun i => x i + c) = media x + c := by
  unfold media
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  have hn' : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  field_simp

/-- book: capitulos/cap04_herramientas.typ:823 (key: ex:ch2-traslaciones) — el
estimador `θ̂ = X₁` es equivariante bajo traslaciones (el libro añade la
mediana, que no se formaliza aquí), y la varianza muestral es invariante:
centrar no cambia la dispersión. -/
theorem ch2_traslaciones_varianza {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (c : ℝ) :
    varMuestral (fun i => x i + c) = varMuestral x := by
  unfold varMuestral
  rw [ch2_traslaciones_media hn x c]
  congr 1
  exact Finset.sum_congr rfl fun i _ => by ring

/-- book: capitulos/cap04_herramientas.typ:839 (key: ex:ch2-escala) — la media
es homogénea de grado uno: `x̄(c x) = c x̄(x)`, la mitad de la equivarianza
bajo el grupo multiplicativo `(ℝ⁺, ·)`. -/
theorem ch2_escala_media {n : ℕ} (x : Fin n → ℝ) (c : ℝ) :
    media (fun i => c * x i) = c * media x := by
  unfold media
  rw [← Finset.mul_sum, mul_div_assoc]

/-- book: capitulos/cap04_herramientas.typ:839 (key: ex:ch2-escala) — la
varianza muestral es homogénea de grado dos: `S²(c x) = c² S²(x)`. -/
theorem ch2_escala_varianza {n : ℕ} (x : Fin n → ℝ) (c : ℝ) :
    varMuestral (fun i => c * x i) = c ^ 2 * varMuestral x := by
  unfold varMuestral
  rw [ch2_escala_media x c]
  have hnum : (∑ i, (c * x i - c * media x) ^ 2) = c ^ 2 * (∑ i, (x i - media x) ^ 2) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hnum, mul_div_assoc]

/-- book: capitulos/cap04_herramientas.typ:839 (key: ex:ch2-escala) — la
desviación estándar muestral es equivariante bajo escala: `S(c x) = c S(x)`
para `c > 0`, como afirma el libro. -/
theorem ch2_escala_desviacion {n : ℕ} (x : Fin n → ℝ) (c : ℝ) (hc : 0 < c) :
    desvMuestral (fun i => c * x i) = c * desvMuestral x := by
  unfold desvMuestral
  rw [ch2_escala_varianza, Real.sqrt_mul (by positivity), Real.sqrt_sq_eq_abs,
    abs_of_pos hc]



/-! ## ex:ch4-mp-normal — test más potente para la normal -/

/-- book: capitulos/cap04_herramientas.typ:1272 (key: ex:ch4-mp-normal) —
razón de verosimilitudes de la normal con varianza conocida para
`H₀ : μ = μ₀` frente a `H₁ : μ = μ₁`: el libro da
`Λ(x) = exp(((μ₁−μ₀)/σ²) Σx − n(μ₁²−μ₀²)/(2σ²))`; se verifica que equivale a
la forma factorizada `exp(((μ₁−μ₀)/σ²)(Σx − n(μ₁+μ₀)/2))`, base de que
`Λ` sea monótona en `x̄`. -/
theorem ch4_mp_normal_forma_factorizada (n : ℕ) (x : Fin n → ℝ) (s2 m0 m1 : ℝ) :
    Real.exp (((m1 - m0) / s2) * (∑ i, x i) - (n : ℝ) * (m1 ^ 2 - m0 ^ 2) / (2 * s2))
      = Real.exp (((m1 - m0) / s2) * ((∑ i, x i) - (n : ℝ) * (m1 + m0) / 2)) := by
  congr 1
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1272 (key: ex:ch4-mp-normal) — el
criterio `Λ(x) > k` equivale a un umbral en la media muestral:
`x̄ > (μ₀+μ₁)/2 + σ² log k /(n(μ₁−μ₀))`, que es la forma "rechazar si
`x̄ > c`" del test MP. Fidelidad declarada: se verifica la equivalencia de
umbral (núcleo del test MP); la elección de `k` para nivel `α` vía el
cuantil normal `z_{1−α}` no se formaliza aquí. -/
theorem ch4_mp_normal_umbral (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) (s2 m0 m1 k : ℝ)
    (hs2 : 0 < s2) (hm : m0 < m1) (hk : 0 < k) :
    (Real.exp (((m1 - m0) / s2) * (∑ i, x i) - (n : ℝ) * (m1 ^ 2 - m0 ^ 2) / (2 * s2)) > k)
      ↔ ((∑ i, x i) / n > (m1 + m0) / 2 + s2 * Real.log k / ((n : ℝ) * (m1 - m0))) := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hd : (0 : ℝ) < m1 - m0 := by linarith
  rw [ch4_mp_normal_forma_factorizada, gt_iff_lt, ← Real.log_lt_iff_lt_exp hk]
  have hkey : (∑ i, x i) / n - ((m1 + m0) / 2 + s2 * Real.log k / ((n : ℝ) * (m1 - m0)))
      = (s2 / ((n : ℝ) * (m1 - m0)))
          * (((m1 - m0) / s2) * ((∑ i, x i) - (n : ℝ) * (m1 + m0) / 2)
              - Real.log k) := by
    field_simp
    ring
  have hposc : (0 : ℝ) < s2 / ((n : ℝ) * (m1 - m0)) := by positivity
  constructor
  · intro h
    rw [gt_iff_lt, ← sub_pos, hkey]
    exact mul_pos hposc (by linarith)
  · intro h
    rw [gt_iff_lt, ← sub_pos, hkey] at h
    have hX : 0 < ((m1 - m0) / s2) * ((∑ i, x i) - (n : ℝ) * (m1 + m0) / 2) - Real.log k := by
      nlinarith [h, hposc]
    linarith



/-! ## ex:ch1-beta-binomial / ex:ch1-gamma-poisson — conjugación aditiva -/

/-- book: capitulos/cap04_herramientas.typ:459 (key: ex:ch1-beta-binomial) —
núcleo de la conjugación Beta-Binomial: el producto del núcleo binomial por el
núcleo Beta es el núcleo Beta con hiperparámetros `(α+x, β+n−x)`,
`θ^x (1−θ)^{n−x} · θ^{α−1}(1−θ)^{β−1} = θ^{α+x−1}(1−θ)^{β+n−x−1}`, luego la
actualización es aditiva. Fidelidad declarada: identidad de núcleos (se omite
la constante normalizadora, como en el libro). -/
theorem ch1_beta_binomial_actualizacion (alpha beta : ℝ) (n x : ℕ) (theta : ℝ)
    (ht : 0 < theta) (ht1 : theta < 1) :
    theta ^ (x : ℝ) * (1 - theta) ^ ((n : ℝ) - x)
        * (theta ^ (alpha - 1) * (1 - theta) ^ (beta - 1))
      = theta ^ (alpha + x - 1) * (1 - theta) ^ (beta + ((n : ℝ) - x) - 1) := by
  have hq : 0 < 1 - theta := by linarith
  have h1 : theta ^ (alpha + (x : ℝ) - 1) = theta ^ (x : ℝ) * theta ^ (alpha - 1) := by
    rw [← Real.rpow_add ht]
    congr 1
    ring
  have h2 : (1 - theta) ^ (beta + ((n : ℝ) - x) - 1)
      = (1 - theta) ^ ((n : ℝ) - x) * (1 - theta) ^ (beta - 1) := by
    rw [← Real.rpow_add hq]
    congr 1
    ring
  rw [h1, h2]
  ring

/-- book: capitulos/cap04_herramientas.typ:472 (key: ex:ch1-gamma-poisson) —
núcleo de la conjugación Gamma-Poisson: `λ^x e^{−λ} · λ^{α−1} e^{−βλ}
= λ^{α+x−1} e^{−(β+1)λ}`, de modo que `λ|x ~ Gamma(α+x, β+1)` y la
actualización es aditiva en hiperparámetros. Fidelidad declarada: identidad de
núcleos, sin la constante normalizadora. -/
theorem ch1_gamma_poisson_actualizacion (alpha beta : ℝ) (x : ℕ) (lam : ℝ)
    (hl : 0 < lam) :
    lam ^ (x : ℝ) * Real.exp (-lam) * (lam ^ (alpha - 1) * Real.exp (-(beta * lam)))
      = lam ^ (alpha + x - 1) * Real.exp (-((beta + 1) * lam)) := by
  have h1 : lam ^ (alpha + (x : ℝ) - 1) = lam ^ (x : ℝ) * lam ^ (alpha - 1) := by
    rw [← Real.rpow_add hl]
    congr 1
    ring
  rw [h1, show -((beta + 1) * lam) = -lam + -(beta * lam) by ring, Real.exp_add]
  ring


/-! ## Auditoría de axiomas (`#print axioms`), equivalente a
`Book/Audit.lean` para este módulo -/

#print axioms ch1_calculo_numerico_observado
#print axioms ch1_calculo_numerico_riesgos_en_medio
#print axioms ch1_calculo_numerico_frontera
#print axioms ch5_cociente_delta
#print axioms ch5_cociente_covarianza
#print axioms ch1_normal_expansion
#print axioms ch1_normal_derivada_logparticion
#print axioms ch1_binomial_forma_exponencial
#print axioms ch1_binomial_derivada_logparticion
#print axioms ch1_poisson_forma_exponencial
#print axioms ch1_poisson_derivada_logparticion
#print axioms ch1_estadisticos_media_constante
#print axioms ch1_estadisticos_var_no_negativa
#print axioms ch2_traslaciones_media
#print axioms ch2_traslaciones_varianza
#print axioms ch2_escala_media
#print axioms ch2_escala_varianza
#print axioms ch2_escala_desviacion
#print axioms ch4_mp_normal_forma_factorizada
#print axioms ch4_mp_normal_umbral
#print axioms ch1_beta_binomial_actualizacion
#print axioms ch1_gamma_poisson_actualizacion

end Book.Cap04Ejemplos
