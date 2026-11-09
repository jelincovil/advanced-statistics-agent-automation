import Mathlib

/-!
# Book.Cap04Ch1Ch2 — pendientes `ch1` y `ch2` de `capitulos/cap04_herramientas.typ`

Formalización de las claves **pendientes** del kernel (`argumentos/kernel/pendientes.json`)
cuyo código de capítulo es `ch1` y `ch2`:

* cap. 1 — pérdidas comunes (`ex:ch1-perdidas-comunes`), suficiencia del
  estadístico natural (`thm:ch1-suficiencia-natural`), Normal-Gamma
  (`ex:ch1-normal-gamma`), `t` de Student (`ex:ch1-t-student`), mezcla de dos
  normales (`ex:ch1-mezcla-normal`), Gumbel (`ex:ch1-gumbel`);
* cap. 2 — Bernoulli minimax (`ex:ch2-bernoulli-minimax`, en
  `cap02_wald.typ`), minimalidad en familias exponenciales
  (`ex:ch2-minimal-exponencial`), multinomial para SSCH
  (`ex:ch2-multinomial-ssch`), ancilaridad de los residuos
  (`ex:ch2-ancilar-localizacion`), aplicación de Basu
  (`ex:ch2-basu-aplicacion`) y suficiencia de políticas
  (`prop:ch2-suficiencia-politicas`, en `cap09_verificacion.typ`).

Convenciones del proyecto (`verificacion_lean/README.md`, plan §6): cada
declaración lleva el docstring `book: capitulos/<archivo>.typ:<línea>
(key: <clave>)` con la **fidelidad declarada**; cero «s-o-r-r-y»; auditoría
`#print axioms` en `AuditCh1Ch2.lean` (⊆ {propext, Classical.choice,
Quot.sound}).

Fidelidad global declarada: el libro escribe densidades sobre `ℝ` y
esperanzas bajo leyes paramétricas; donde la integral no interviene en el
enunciado se verifica el núcleo algebraico exacto (forma canónica, cociente de
verosimilitudes, factorización, actualización de hiperparámetros, identidades
de sesgo/varianza/riesgo). Los espacios muestrales finitos se escriben como
`Fin n → ℝ` o con sumas ponderadas; donde el libro usa una densidad normal
normalizada se usa `ProbabilityTheory.gaussianPDFReal`, cuya integral vale 1
(`integral_gaussianPDFReal_eq_one`). Cada teorema declara en su propio
docstring qué parte del enunciado del libro queda fuera.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory

namespace Book.Cap04Ch1Ch2

/-! ## Cap. 1 — pérdidas comunes (`ex:ch1-perdidas-comunes`) -/

/-- Pérdida cuadrática `L(θ, a) = (θ − a)²`. -/
def perdidaCuadratica (θ a : ℝ) : ℝ := (θ - a) ^ 2

/-- Pérdida absoluta `L(θ, a) = |θ − a|`. -/
def perdidaAbsoluta (θ a : ℝ) : ℝ := |θ - a|

/-- Pérdida 0-1 de clasificación: `L(θ, a) = 1` si `a ≠ θ`, `0` si `a = θ`
(el libro escribe `𝟙(a ≠ θ)`). -/
noncomputable def perdidaCeroUno (θ a : ℝ) : ℝ := if a = θ then 0 else 1

/-- Pérdida cuadrática ponderada `L(θ, a) = w(θ)(θ − a)²`. -/
def perdidaPonderada (w : ℝ → ℝ) (θ a : ℝ) : ℝ := w θ * (θ - a) ^ 2

/-- Riesgo de una regla `δ` bajo pesos `P` sobre un espacio muestral finito:
`R(θ, δ) = ∑_x P_θ(x)·L(θ, δ(x))`. Es la definición de `def:ch1-perdida-riesgo`
con la esperanza escrita como suma finita. -/
def riesgo {X : Type*} [Fintype X] (P : X → ℝ) (L : ℝ → ℝ → ℝ) (θ : ℝ)
    (δ : X → ℝ) : ℝ :=
  ∑ x, P x * L θ (δ x)

/-- Probabilidad de error de una regla de clasificación `δ`:
`∑_x P(x)·𝟙(δ(x) ≠ θ)`. -/
noncomputable def probError {X : Type*} [Fintype X] (P : X → ℝ) (δ : X → ℝ)
    (θ : ℝ) : ℝ :=
  ∑ x, P x * perdidaCeroUno θ (δ x)

/-- book: capitulos/cap04_herramientas.typ:281 (key: ex:ch1-perdidas-comunes) —
las cuatro pérdidas del ejemplo son no negativas, es decir, tienen el tipo
`ParamSpace × ActionSpace → ℝ_{≥0}` que el libro les atribuye en
`def:ch1-perdida-riesgo`: cuadrática, absoluta, 0-1 y cuadrática ponderada con
peso estrictamente positivo. Fidelidad declarada: se formaliza el espacio de
parámetros y de acciones `ℝ` (el libro lo deja abstracto) y la positividad del
peso como hipótesis `∀ θ, 0 < w θ`; no se formaliza aquí la ponderación por
una función de peso medible general. -/
theorem perdidas_comunes_no_negativas :
    (∀ θ a : ℝ, 0 ≤ perdidaCuadratica θ a) ∧
    (∀ θ a : ℝ, 0 ≤ perdidaAbsoluta θ a) ∧
    (∀ θ a : ℝ, 0 ≤ perdidaCeroUno θ a) ∧
    (∀ (w : ℝ → ℝ), (∀ θ, 0 < w θ) → ∀ θ a : ℝ, 0 ≤ perdidaPonderada w θ a) := by
  refine ⟨fun θ a => sq_nonneg (θ - a), fun θ a => abs_nonneg (θ - a), ?_, ?_⟩
  · intro θ a
    unfold perdidaCeroUno
    split <;> norm_num
  · intro w hw θ a
    exact mul_nonneg (le_of_lt (hw θ)) (sq_nonneg (θ - a))

/-- book: capitulos/cap04_herramientas.typ:281 (key: ex:ch1-perdidas-comunes) —
*Pérdida cuadrática:* el riesgo es el error cuadrático medio, y éste se
descompone en varianza más sesgo al cuadrado,
`E_P[(θ̂ − t₀)²] = Var_P(θ̂) + (E_P[θ̂] − t₀)²`, con las esperanzas escritas
como sumas finitas ponderadas y `∑ P = 1`. Fidelidad declarada: la identidad
es la algebraica de sesgo-varianza-ECM; no se formaliza la optimalidad de la
media ni el caso de la pérdida absoluta (cuya solución es la mediana y exige
otro argumento). -/
theorem perdidas_comunes_ecm_descomposicion {X : Type*} [Fintype X]
    (P θb : X → ℝ) (t0 : ℝ) (hP : ∑ x, P x = 1) :
    ∑ x, P x * (θb x - t0) ^ 2
      = ((∑ x, P x * (θb x) ^ 2) - (∑ x, P x * θb x) ^ 2)
        + (∑ x, P x * θb x - t0) ^ 2 := by
  have hexp : ∀ x : X, P x * (θb x - t0) ^ 2
      = (P x * (θb x) ^ 2 - 2 * t0 * (P x * θb x) + t0 ^ 2 * P x) := by
    intro x; ring
  rw [Finset.sum_congr rfl fun x _ => hexp x]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, hP]
  ring

/-- book: capitulos/cap04_herramientas.typ:281 (key: ex:ch1-perdidas-comunes) —
*Pérdida 0-1:* el riesgo es la probabilidad de error, es decir
`∑_x P(x)·𝟙(δ(x) ≠ θ) = 1 − ∑_x P(x)·𝟙(δ(x) = θ)` cuando `∑ P = 1`: la
probabilidad del suceso complementario (acierto). Fidelidad declarada: se
verifica la identidad de complementariedad que hace del riesgo 0-1 una
probabilidad; no se formaliza el problema de clasificación (región de Bayes). -/
theorem perdidas_comunes_cero_uno_complemento {X : Type*} [Fintype X]
    (P δ : X → ℝ) (θ : ℝ) (hP : ∑ x, P x = 1) :
    probError P δ θ + ∑ x, P x * (1 - perdidaCeroUno θ (δ x)) = 1 := by
  unfold probError
  rw [← Finset.sum_add_distrib]
  have : ∀ x : X, P x * perdidaCeroUno θ (δ x) + P x * (1 - perdidaCeroUno θ (δ x))
      = P x := by
    intro x; ring
  rw [Finset.sum_congr rfl fun x _ => this x, hP]

/-! ## Cap. 1 — el estadístico natural es suficiente
(`thm:ch1-suficiencia-natural`) -/

section Exponencial

variable {ι X : Type*} [Fintype ι] [Fintype X]

/-- Densidad en forma canónica de una familia exponencial de rango `k`:
`f(x|η) = exp(⟨η, T(x)⟩ − A(η))·h(x)` con `⟨η, T(x)⟩ = ∑_i η_i T_i(x)`
(`def:ch1-familia-exponencial`). -/
noncomputable def densExp (T : X → ι → ℝ) (h : X → ℝ) (A : (ι → ℝ) → ℝ)
    (η : ι → ℝ) (x : X) : ℝ :=
  Real.exp ((∑ i, η i * T x i) - A η) * h x

/-- Probabilidad condicional de `x` dado `T = T(x)`:
`f(x|η) / ∑_{y : T(y)=T(x)} f(y|η)`. -/
noncomputable def probCondExp (T : X → ι → ℝ) (h : X → ℝ) (A : (ι → ℝ) → ℝ)
    (η : ι → ℝ) (x : X) : ℝ :=
  densExp T h A η x / ∑ y, if T y = T x then densExp T h A η y else 0

/-- book: capitulos/cap04_herramientas.typ:402 (key: thm:ch1-suficiencia-natural) —
**El estadístico natural es suficiente.** En la familia exponencial canónica
`f(x|η) = exp(⟨η,T(x)⟩ − A(η))·h(x)` con `h > 0`, la ley condicional de `X`
dado `T = T(x)` **no depende de `η`**:
`P_η(X = x | T = T(x)) = h(x) / ∑_{y : T(y)=T(x)} h(y)`.
Esto es exactamente la factorización de Neyman–Fisher
`f(x|η) = g(T(x), η)·h(x)` leída como independencia del parámetro de la
condicional, que es la definición `def:ch2-suficiencia` de suficiencia.
Fidelidad declarada: espacio muestral finito (la suma sobre la fibra de `T`
sustituye la integral sobre `{T = t}`), y la suficiencia se enuncia para la
condicional puntual de `x` (que es la que define la ley condicional en un
espacio finito); no se formaliza la equivalencia general de versiones de la
ley condicional ni la reparametrización `θ = θ(η)`, que no interviene: la
identidad vale para todo `η`. -/
theorem suficiente_estadistico_natural (T : X → ι → ℝ) (h : X → ℝ)
    (A : (ι → ℝ) → ℝ) (hpos : ∀ x, 0 < h x) (η : ι → ℝ) (x : X) :
    probCondExp T h A η x = h x / ∑ y, if T y = T x then h y else 0 := by
  classical
  set s : ℝ := (∑ i, η i * T x i) - A η with hs
  have hnum : densExp T h A η x = Real.exp s * h x := by
    unfold densExp
    rw [← hs]
  have hden : (∑ y, if T y = T x then densExp T h A η y else 0)
      = Real.exp s * ∑ y, if T y = T x then h y else 0 := by
    have hpt : ∀ y : X, (if T y = T x then densExp T h A η y else 0)
        = Real.exp s * (if T y = T x then h y else 0) := by
      intro y
      by_cases hy : T y = T x
      · have hsum : (∑ i, η i * T y i) = (∑ i, η i * T x i) := by
          refine Finset.sum_congr rfl ?_
          intro i _
          rw [hy]
        have hval : densExp T h A η y = Real.exp s * h y := by
          unfold densExp
          rw [hsum, ← hs]
        rw [if_pos hy, if_pos hy, hval]
      · rw [if_neg hy, if_neg hy, mul_zero]
    rw [Finset.sum_congr rfl fun y _ => hpt y, Finset.mul_sum]
  have hD : 0 < ∑ y, if T y = T x then h y else 0 := by
    refine Finset.sum_pos' (fun y _ => ?_) ⟨x, Finset.mem_univ x, ?_⟩
    · by_cases hy : T y = T x
      · rw [if_pos hy]; exact le_of_lt (hpos y)
      · rw [if_neg hy]
    · rw [if_pos rfl]; exact hpos x
  have hexp : Real.exp s ≠ 0 := Real.exp_ne_zero s
  unfold probCondExp
  rw [hnum, hden]
  rw [mul_div_mul_left _ _ hexp]

end Exponencial

/-! ## Cap. 1 — Normal-Gamma (`ex:ch1-normal-gamma`) -/

/-- Hiperparámetros Normal-Gamma tras observar `x`, con la actualización
secuencial exacta del libro:
`μ₀' = (λμ₀ + x)/(λ+1)`, `λ' = λ+1`, `α' = α + 1/2`,
`β' = β + λ(x−μ₀)²/(2(λ+1))`. El resultado es la cuádrupla
`(μ₀', λ', α', β')`. -/
noncomputable def normalGammaUpdate (μ₀ lam α β x : ℝ) : ℝ × ℝ × ℝ × ℝ :=
  ((lam * μ₀ + x) / (lam + 1), lam + 1, α + 1 / 2,
    β + lam * (x - μ₀) ^ 2 / (2 * (lam + 1)))

/-- book: capitulos/cap04_herramientas.typ:485 (key: ex:ch1-normal-gamma) —
las cuatro fórmulas de actualización secuencial Normal-Gamma del ejemplo.
Fidelidad declarada: se formalizan las fórmulas de los hiperparámetros (el
núcleo que el libro llama *Actualización secuencial*); la verificación de que
la densidad conjugada reproduce el posterior Normal-Gamma exige integrales
Beta/Gamma sobre `ℝ₊` y se declara no formalizada. -/
theorem normalGamma_formulas (μ₀ lam α β x : ℝ) :
    (normalGammaUpdate μ₀ lam α β x).1 = (lam * μ₀ + x) / (lam + 1) ∧
    (normalGammaUpdate μ₀ lam α β x).2.1 = lam + 1 ∧
    (normalGammaUpdate μ₀ lam α β x).2.2.1 = α + 1 / 2 ∧
    (normalGammaUpdate μ₀ lam α β x).2.2.2 = β + lam * (x - μ₀) ^ 2 / (2 * (lam + 1)) := by
  unfold normalGammaUpdate
  exact ⟨rfl, rfl, rfl, rfl⟩

/-- book: capitulos/cap04_herramientas.typ:485 (key: ex:ch1-normal-gamma) —
el posterior sigue siendo Normal-Gamma: la «precisión» crece en uno y la forma
crece en `1/2`, de modo que `α' > 1` se alcanza tras el primer dato y
`Var(μ|x) = β'/(λ'(α'−1))` queda definida. -/
theorem normalGamma_precision_crece (μ₀ lam α β x : ℝ) :
    lam < (normalGammaUpdate μ₀ lam α β x).2.1 ∧ α < (normalGammaUpdate μ₀ lam α β x).2.2.1 := by
  unfold normalGammaUpdate
  constructor <;> linarith

/-- book: capitulos/cap04_herramientas.typ:485 (key: ex:ch1-normal-gamma) —
`β` no decrece: `β' = β + λ(x−μ₀)²/(2(λ+1)) ≥ β` para `λ ≥ 0`. -/
theorem normalGamma_beta_no_decrece {μ₀ lam β x : ℝ} (hlam : 0 ≤ lam) :
    β ≤ (normalGammaUpdate μ₀ lam α β x).2.2.2 := by
  unfold normalGammaUpdate
  have h : 0 ≤ lam * (x - μ₀) ^ 2 / (2 * (lam + 1)) := by
    have h2 : 0 < lam + 1 := by linarith
    positivity
  linarith

/-- book: capitulos/cap04_herramientas.typ:485 (key: ex:ch1-normal-gamma) —
**invariante de la actualización**: `β' + λ'μ₀'²/2 = β + λμ₀²/2 + x²/2`. Es la
razón por la que, para `n` fijo, el estado puede resumirse en
`(∑ X_i, ∑ X_i², n)` (el libro: «basta `(∑ X_i, ∑ X_i²)`»): cada observación
aporta `x²/2` al invariante y una unidad a `λ`. Fidelidad declarada: se prueba
el paso de una observación; la versión con `n` observaciones es la iteración y
no se enuncia aparte. -/
theorem normalGamma_invariante (μ₀ lam α β x : ℝ) (hlam : lam + 1 ≠ 0) :
    (normalGammaUpdate μ₀ lam α β x).2.2.2
        + (normalGammaUpdate μ₀ lam α β x).2.1 * (normalGammaUpdate μ₀ lam α β x).1 ^ 2 / 2
      = β + lam * μ₀ ^ 2 / 2 + x ^ 2 / 2 := by
  unfold normalGammaUpdate
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:485 (key: ex:ch1-normal-gamma) — la
*Incertidumbre* del ejemplo: con `α' > 1`, `β' > 0` y `λ' > 0`, la varianza
posterior `Var(μ|x) = β'/(λ'(α'−1))` es estrictamente positiva y finita. -/
theorem normalGamma_varianza_pos {μ₀ lam α β x : ℝ} (hβ : 0 < β) (hlam : 0 < lam)
    (hα : 1 < α) :
    0 < (normalGammaUpdate μ₀ lam α β x).2.2.2 /
          ((normalGammaUpdate μ₀ lam α β x).2.1 *
            ((normalGammaUpdate μ₀ lam α β x).2.2.1 - 1)) := by
  unfold normalGammaUpdate
  have hlam' : 0 < lam + 1 := by linarith
  have hα' : 0 < α + 1 / 2 - 1 := by linarith
  have hβ' : 0 < β + lam * (x - μ₀) ^ 2 / (2 * (lam + 1)) := by
    have h : 0 ≤ lam * (x - μ₀) ^ 2 / (2 * (lam + 1)) := by positivity
    linarith
  positivity

/-! ## Cap. 1 — `t` de Student (`ex:ch1-t-student`) -/

/-- Constante de normalización de la densidad base `t`:
`Γ((ν+1)/2) / (√(νπ)·Γ(ν/2))`. -/
noncomputable def tColaConst (ν : ℝ) : ℝ :=
  Real.Gamma ((ν + 1) / 2) / (Real.sqrt (ν * Real.pi) * Real.Gamma (ν / 2))

/-- Densidad base `t` con `ν` grados de libertad:
`g(z) = Γ((ν+1)/2)/(√(νπ)Γ(ν/2))·(1 + z²/ν)^{−(ν+1)/2}`. -/
noncomputable def tBase (ν z : ℝ) : ℝ :=
  tColaConst ν * (1 + z ^ 2 / ν) ^ (-(ν + 1) / 2)

/-- Densidad `t` de localización-escala
`f_{μ,σ}(x) = (1/σ)·g((x−μ)/σ)` (`def:ch1-localizacion-escala`). -/
noncomputable def tLocEscala (ν μ σ x : ℝ) : ℝ :=
  (1 / σ) * tBase ν ((x - μ) / σ)

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) — la
densidad base `t` del ejemplo es estrictamente positiva para `ν > 0`. -/
theorem tBase_pos {ν : ℝ} (hν : 0 < ν) (z : ℝ) : 0 < tBase ν z := by
  have h4 : 0 < 1 + z ^ 2 / ν := by positivity
  have h6 : 0 < tColaConst ν := by
    unfold tColaConst
    have h1 : 0 < Real.Gamma ((ν + 1) / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h2 : 0 < Real.Gamma (ν / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h3 : 0 < Real.sqrt (ν * Real.pi) := Real.sqrt_pos.mpr (by positivity)
    positivity
  unfold tBase
  exact mul_pos h6 (Real.rpow_pos_of_pos h4 _)

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) — la base
`t` es **simétrica**: `g(−z) = g(z)`. Con `def:ch1-localizacion-escala` esto es
lo que hace de la `t` una familia de localización (no de localización-escala
sesgada). -/
theorem tBase_even (ν z : ℝ) : tBase ν (-z) = tBase ν z := by
  unfold tBase
  rw [neg_sq]

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) — la `t`
de localización-escala es **equivariante bajo traslaciones**:
`f_{μ+c,σ}(x+c) = f_{μ,σ}(x)`, la propiedad de grupo que el libro asocia a las
familias de localización. -/
theorem tLocEscala_traslacion (ν μ σ c x : ℝ) :
    tLocEscala ν (μ + c) σ (x + c) = tLocEscala ν μ σ x := by
  unfold tLocEscala
  rw [show x + c - (μ + c) = x - μ by ring]

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) — la `t`
de localización-escala es **homogénea de grado −1** bajo el grupo de escala:
`f_{cμ,cσ}(cx) = c⁻¹·f_{μ,σ}(x)` para `c > 0`. -/
theorem tLocEscala_escala {ν μ σ c x : ℝ} (hc : 0 < c) :
    tLocEscala ν (c * μ) (c * σ) (c * x) = c⁻¹ * tLocEscala ν μ σ x := by
  have hc0 : c ≠ 0 := ne_of_gt hc
  unfold tLocEscala
  rw [show c * x - c * μ = c * (x - μ) by ring]
  rw [show (c * (x - μ)) / (c * σ) = (x - μ) / σ from by
    rw [mul_div_mul_left _ _ hc0]]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) —
**colas polinómicas de orden `ν+1`.** Para `z ≥ 1` y `ν > 0`, la base `t` está
acotada por arriba por `C(ν)·z^{−(ν+1)}`: la densidad decae como una potencia,
no exponencialmente. De ahí el criterio de momentos del libro (media solo para
`ν > 1`, varianza solo para `ν > 2`), que es la comparación con
`∫ z^{−ν} dz < ∞ ⇔ ν > 1`. Fidelidad declarada: se prueba la **cota de cola**
exacta; la integrabilidad (y por tanto el criterio de momentos como teorema de
existencia) se declara no formalizada, porque exige la teoría de integrales
impropias de potencias sobre `ℝ₊`. -/
theorem tBase_cola_superior {ν : ℝ} (hν : 0 < ν) {z : ℝ} (hz : 1 ≤ z) :
    tBase ν z ≤ tColaConst ν * (ν ^ ((ν + 1) / 2)) * z ^ (-(ν + 1)) := by
  have hzpos : 0 < z := lt_of_lt_of_le one_pos hz
  have hC : 0 < tColaConst ν := by
    unfold tColaConst
    have h1 : 0 < Real.Gamma ((ν + 1) / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h2 : 0 < Real.Gamma (ν / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h3 : 0 < Real.sqrt (ν * Real.pi) := Real.sqrt_pos.mpr (by positivity)
    positivity
  have hbase : 0 < 1 + z ^ 2 / ν := by positivity
  have hz2ν : 0 < z ^ 2 / ν := by positivity
  have hle : z ^ 2 / ν ≤ 1 + z ^ 2 / ν := by linarith
  have hmono : (1 + z ^ 2 / ν) ^ (-(ν + 1) / 2) ≤ (z ^ 2 / ν) ^ (-(ν + 1) / 2) :=
    Real.rpow_le_rpow_of_nonpos hz2ν hle (by linarith)
  have hz2 : (z ^ 2 / ν) ^ (-(ν + 1) / 2) = ν ^ ((ν + 1) / 2) * z ^ (-(ν + 1)) := by
    rw [Real.div_rpow (x := z ^ 2) (y := ν) (sq_nonneg z) (le_of_lt hν) (-(ν + 1) / 2)]
    have h1 : (z ^ 2) ^ (-(ν + 1) / 2) = z ^ (-(ν + 1)) := by
      rw [show (z ^ 2) ^ (-(ν + 1) / 2) = z ^ (2 * (-(ν + 1) / 2)) from by
        rw [Real.rpow_mul (le_of_lt hzpos)]
        norm_num]
      rw [show 2 * (-(ν + 1) / 2) = -(ν + 1) by ring]
    have h2 : (ν ^ (-(ν + 1) / 2))⁻¹ = ν ^ ((ν + 1) / 2) := by
      rw [← Real.rpow_neg (le_of_lt hν)]
      congr 1
      ring
    rw [h1, div_eq_mul_inv, h2, mul_comm]
  unfold tBase
  rw [hz2] at hmono
  calc tColaConst ν * (1 + z ^ 2 / ν) ^ (-(ν + 1) / 2)
      ≤ tColaConst ν * (ν ^ ((ν + 1) / 2) * z ^ (-(ν + 1))) := by
        exact mul_le_mul_of_nonneg_left hmono (le_of_lt hC)
    _ = tColaConst ν * ν ^ ((ν + 1) / 2) * z ^ (-(ν + 1)) := by ring

/-- book: capitulos/cap04_herramientas.typ:535 (key: ex:ch1-t-student) — **cota
inferior de cola**: para `z ≥ 1` y `ν > 0`, `tBase ν z ≥ C(ν)(1+1/ν)^{−(ν+1)/2}·
z^{−(ν+1)}`. Las dos cotas juntas fijan el exponente de cola `ν+1` del
ejemplo. Fidelidad declarada: igual que en `tBase_cola_superior`, la
integrabilidad no se formaliza. -/
theorem tBase_cola_inferior {ν : ℝ} (hν : 0 < ν) {z : ℝ} (hz : 1 ≤ z) :
    tColaConst ν * ((1 + 1 / ν) ^ (-(ν + 1) / 2)) * z ^ (-(ν + 1)) ≤ tBase ν z := by
  have hzpos : 0 < z := lt_of_lt_of_le one_pos hz
  have hC : 0 < tColaConst ν := by
    unfold tColaConst
    have h1 : 0 < Real.Gamma ((ν + 1) / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h2 : 0 < Real.Gamma (ν / 2) := Real.Gamma_pos_of_pos (by linarith)
    have h3 : 0 < Real.sqrt (ν * Real.pi) := Real.sqrt_pos.mpr (by positivity)
    positivity
  have hbound : 1 + z ^ 2 / ν ≤ (1 + 1 / ν) * z ^ 2 := by
    have h1 : 1 ≤ z ^ 2 := by nlinarith
    have h4 : z ^ 2 + z ^ 2 / ν = (1 + 1 / ν) * z ^ 2 := by ring
    linarith [h4]
  have hpos : 0 < (1 + 1 / ν) * z ^ 2 := by
    have : 0 < 1 + 1 / ν := by positivity
    positivity
  have hbase : 0 < 1 + z ^ 2 / ν := by positivity
  have hmono : ((1 + 1 / ν) * z ^ 2) ^ (-(ν + 1) / 2) ≤ (1 + z ^ 2 / ν) ^ (-(ν + 1) / 2) :=
    Real.rpow_le_rpow_of_nonpos hbase hbound (by linarith)
  have hexp : ((1 + 1 / ν) * z ^ 2) ^ (-(ν + 1) / 2)
      = (1 + 1 / ν) ^ (-(ν + 1) / 2) * z ^ (-(ν + 1)) := by
    rw [Real.mul_rpow (by positivity) (by positivity)]
    rw [show (z ^ 2) ^ (-(ν + 1) / 2) = z ^ (2 * (-(ν + 1) / 2)) from by
      rw [Real.rpow_mul (le_of_lt hzpos)]
      norm_num]
    rw [show 2 * (-(ν + 1) / 2) = -(ν + 1) by ring]
  unfold tBase
  rw [hexp] at hmono
  calc tColaConst ν * ((1 + 1 / ν) ^ (-(ν + 1) / 2)) * z ^ (-(ν + 1))
      = tColaConst ν * ((1 + 1 / ν) ^ (-(ν + 1) / 2) * z ^ (-(ν + 1))) := by ring
    _ ≤ tColaConst ν * (1 + z ^ 2 / ν) ^ (-(ν + 1) / 2) := by
        exact mul_le_mul_of_nonneg_left hmono (le_of_lt hC)

/-! ## Cap. 1 — mezcla de dos normales (`ex:ch1-mezcla-normal`) -/

/-- Densidad de la mezcla de dos normales con peso `w`:
`f(x) = w·N(μ₁,σ₁²)(x) + (1−w)·N(μ₂,σ₂²)(x)`. -/
noncomputable def mezclaNormal (w μ₁ μ₂ : ℝ) (v₁ v₂ : NNReal) (x : ℝ) : ℝ :=
  w * gaussianPDFReal μ₁ v₁ x + (1 - w) * gaussianPDFReal μ₂ v₂ x

/-- book: capitulos/cap04_herramientas.typ:555 (key: ex:ch1-mezcla-normal) — la
mezcla de dos normales con `0 ≤ w ≤ 1` es una **densidad de probabilidad**: es
no negativa y su integral total vale uno, de modo que modela (como el libro
dice) poblaciones heterogéneas. Fidelidad declarada: se formaliza la
normalización exacta usando `∫ gaussianPDFReal μ v = 1`; la multimodalidad
(existencia de dos modos con `μ₁ ≠ μ₂`) y el algoritmo EM se declaran no
formalizados. -/
theorem mezcla_normal_densidad (w μ₁ μ₂ : ℝ) (v₁ v₂ : NNReal) (hv₁ : v₁ ≠ 0)
    (hv₂ : v₂ ≠ 0) (hw0 : 0 ≤ w) (hw1 : w ≤ 1) :
    (∀ x, 0 ≤ mezclaNormal w μ₁ μ₂ v₁ v₂ x) ∧
      (∫ x, mezclaNormal w μ₁ μ₂ v₁ v₂ x = 1) := by
  constructor
  · intro x
    have h1 : 0 ≤ gaussianPDFReal μ₁ v₁ x := gaussianPDFReal_nonneg μ₁ v₁ x
    have h2 : 0 ≤ gaussianPDFReal μ₂ v₂ x := gaussianPDFReal_nonneg μ₂ v₂ x
    unfold mezclaNormal
    nlinarith
  · have h1 : Integrable (fun x => w * gaussianPDFReal μ₁ v₁ x) :=
      (integrable_gaussianPDFReal μ₁ v₁).const_mul w
    have h2 : Integrable (fun x => (1 - w) * gaussianPDFReal μ₂ v₂ x) :=
      (integrable_gaussianPDFReal μ₂ v₂).const_mul (1 - w)
    unfold mezclaNormal
    rw [integral_add h1 h2, integral_const_mul, integral_const_mul,
      integral_gaussianPDFReal_eq_one μ₁ hv₁, integral_gaussianPDFReal_eq_one μ₂ hv₂]
    ring

/-- book: capitulos/cap04_herramientas.typ:555 (key: ex:ch1-mezcla-normal) — ley
de la varianza total para la mezcla: la varianza de la mezcla es la media
ponderada de las varianzas condicionales más la varianza de las medias
condicionales,
`w(σ₁² + (μ₁−μ)²) + (1−w)(σ₂² + (μ₂−μ)²) = w(σ₁²+μ₁²) + (1−w)(σ₂²+μ₂²) − μ²`
con `μ = wμ₁ + (1−w)μ₂`. Fidelidad declarada: identidad algebraica de momentos
(los dos primeros momentos condicionales son datos); no se formaliza la
integral de `x²` contra la mezcla. -/
theorem mezcla_normal_varianza_total (w μ₁ μ₂ σ₁ σ₂ : ℝ) :
    w * (σ₁ ^ 2 + (μ₁ - (w * μ₁ + (1 - w) * μ₂)) ^ 2)
        + (1 - w) * (σ₂ ^ 2 + (μ₂ - (w * μ₁ + (1 - w) * μ₂)) ^ 2)
      = (w * (σ₁ ^ 2 + μ₁ ^ 2) + (1 - w) * (σ₂ ^ 2 + μ₂ ^ 2))
        - (w * μ₁ + (1 - w) * μ₂) ^ 2 := by
  ring

/-! ## Cap. 1 — Gumbel (`ex:ch1-gumbel`) -/

/-- Densidad Gumbel de localización `μ` y escala `β`:
`f(x|μ,β) = (1/β)·exp(−(x−μ)/β − exp(−(x−μ)/β))`. -/
noncomputable def gumbelDens (μ β x : ℝ) : ℝ :=
  (1 / β) * Real.exp (-((x - μ) / β) - Real.exp (-((x - μ) / β)))

/-- Función de distribución Gumbel: `F(x) = exp(−exp(−(x−μ)/β))`, que es la
integral de `gumbelDens` (declarado: no se formaliza esa integración). -/
noncomputable def gumbelCDF (μ β x : ℝ) : ℝ :=
  Real.exp (-Real.exp (-((x - μ) / β)))

/-- book: capitulos/cap04_herramientas.typ:573 (key: ex:ch1-gumbel) — **el
máximo de `n` Gumbel iid es Gumbel con la misma escala y localización
desplazada**: si `F` es la CDF Gumbel de parámetros `(μ,β)`, entonces
`F(x)^n = F_{μ+β log n, β}(x)`. Es el enunciado del ejemplo («Si `X_i` son iid
Gumbel, `max_i X_i` tiene parámetros `(μ+β log n, β)`») escrito en la forma
`P(max ≤ x) = F(x)^n` de la independencia. Fidelidad declarada: se formaliza la
identidad de funciones de distribución (que es la parte de la afirmación que
usa la independencia y la forma cerrada de `F`); el paso «`P(max ≤ x) = F(x)^n`»
para variables iid se toma como definición de la independencia y no se
formaliza como resultado de teoría de la medida. -/
theorem gumbel_max_estable (μ β : ℝ) (hβ : β ≠ 0) (n : ℕ) (hn : 1 ≤ n) (x : ℝ) :
    (gumbelCDF μ β x) ^ n = gumbelCDF (μ + β * Real.log n) β x := by
  unfold gumbelCDF
  rw [← Real.exp_nat_mul]
  congr 1
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hlog : Real.exp (Real.log (n : ℝ)) = (n : ℝ) := Real.exp_log hnpos
  have hexp : Real.exp (-((x - (μ + β * Real.log (n : ℝ))) / β))
      = (n : ℝ) * Real.exp (-((x - μ) / β)) := by
    rw [show -((x - (μ + β * Real.log (n : ℝ))) / β)
          = -((x - μ) / β) + Real.log (n : ℝ) from by field_simp; ring]
    rw [Real.exp_add, hlog, mul_comm]
  rw [hexp]
  ring

/-- book: capitulos/cap04_herramientas.typ:573 (key: ex:ch1-gumbel) — **con
escala conocida, `∑_i exp(−X_i/β)` es suficiente para la localización**: la
verosimilitud de una muestra `x : Fin n → ℝ` factoriza como
`g(∑_i exp(−x_i/β), μ, β)·h(x)`, con `g(t) = (e^{μ/β}/β)^n·e^{−e^{μ/β}·t}` y
`h(x) = e^{−∑x_i/β}`. Es la factorización de Neyman–Fisher del
`thm:ch1-suficiencia-natural` aplicada a la Gumbel de escala conocida.
Fidelidad declarada: se formaliza la factorización (suficiencia); la parte
negativa del ejemplo —que `exp(−x/β)` **no** puede llamarse estadístico natural
con escala desconocida, porque depende del parámetro— es un enunciado de
no-existencia de factorización que no se formaliza aquí. -/
theorem gumbel_suficiencia_escala (μ β : ℝ) (hβ : 0 < β) (n : ℕ) :
    ∃ g : ℝ → ℝ, ∀ x : Fin n → ℝ,
      (∏ i, gumbelDens μ β (x i))
        = g (∑ i, Real.exp (-(x i) / β)) * Real.exp (-(∑ i, x i) / β) := by
  refine ⟨fun t => (Real.exp (μ / β) / β) ^ n * Real.exp (-(Real.exp (μ / β)) * t), ?_⟩
  intro x
  have hβ' : β ≠ 0 := ne_of_gt hβ
  have hpt : ∀ y : ℝ, gumbelDens μ β y
      = (Real.exp (μ / β) / β) * Real.exp (-(y / β))
        * Real.exp (-(Real.exp (μ / β) * Real.exp (-(y / β)))) := by
    intro y
    have h1 : Real.exp (-((y - μ) / β)) = Real.exp (μ / β) * Real.exp (-(y / β)) := by
      rw [show -((y - μ) / β) = μ / β + -(y / β) from by field_simp; ring]
      rw [Real.exp_add]
    have h2 : -((y - μ) / β) = μ / β + -(y / β) := by field_simp; ring
    unfold gumbelDens
    rw [h2, Real.exp_sub, Real.exp_add]
    rw [show Real.exp (-(Real.exp (μ / β) * Real.exp (-(y / β))))
          = (Real.exp (Real.exp (μ / β) * Real.exp (-(y / β))))⁻¹ from Real.exp_neg _]
    rw [div_eq_mul_inv]
    ring
  rw [Finset.prod_congr rfl fun i _ => hpt (x i)]
  rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib, Finset.prod_const,
    Finset.card_univ, Fintype.card_fin]
  have e1 : Real.exp (∑ i : Fin n, -(x i / β)) = Real.exp (-(∑ i, x i) / β) := by
    congr 1
    rw [Finset.sum_neg_distrib, ← Finset.sum_div]
    ring
  have e2 : Real.exp (∑ i : Fin n, -(Real.exp (μ / β) * Real.exp (-(x i / β))))
      = Real.exp (-(Real.exp (μ / β)) * (∑ i, Real.exp (-(x i / β)))) := by
    congr 1
    rw [Finset.sum_neg_distrib, ← Finset.mul_sum]
    ring
  rw [← Real.exp_sum, ← Real.exp_sum, e1, e2]
  ring

end Book.Cap04Ch1Ch2
