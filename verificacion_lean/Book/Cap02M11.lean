import Mathlib
import Book.Foundation

/-!
# Pendientes de cap. 7 (decisión de Wald): `ex:ch7-perdidas` y `ex:ch7-james-stein`

Módulo del enjambre `smw8gy947`, miembro `m11`, dirección d13 en el board (cap. 7: pérdidas /
James–Stein). Cubre las dos claves pendientes de `argumentos/kernel/pendientes.json`
cuya fuente es `capitulos/cap02_wald.typ` (líneas 40 y 61).

Convenciones del proyecto (`PLAN_LEAN_LIBRO_2026-11-04.md` §6): sin huecos de
prueba, auditoría `#print axioms` por teorema, clave del libro en cada declaración
(`book: capitulos/<file>.typ:<line> (key: <clave>)`) y fidelidad declarada
en el docstring. La versión formal de la tabla de pérdidas es la del proyecto
(espacios de parámetro, observación y acción finitos, riesgos como sumas
ponderadas); la del ejemplo de James–Stein es la versión de espacio de
probabilidad con las dos entradas analíticas gaussianas declaradas como
hipótesis (véase el docstring del teorema).
-/

open Finset BigOperators
open MeasureTheory
open scoped RealInnerProductSpace

namespace Cap02M11

/-! ## `ex:ch7-perdidas` — tabla de pérdidas y objetivos (cap02_wald.typ:40)

La tabla del libro asigna a cada pérdida su riesgo: cuadrática → error
cuadrático medio, absoluta → error absoluto esperado, clasificación →
probabilidad de clasificación errónea, cuadrática ponderada → error
ponderado con `w(θ) ≥ 0`. Aquí se formaliza esa asignación en el problema
finito del proyecto (`risk` de `Book.Foundation`) y se prueba la lectura
probabilística de cada fila. -/

/-- Pérdida cuadrática `L(θ,a) = (a − ψ(θ))²` de la tabla de
`ex:ch7-perdidas`. -/
def lossCuad {Θ : Type*} (ψ : Θ → ℝ) (θ : Θ) (a : ℝ) : ℝ :=
  (a - ψ θ) ^ 2

/-- Pérdida absoluta `L(θ,a) = |a − ψ(θ)|` de la tabla de `ex:ch7-perdidas`. -/
def lossAbs {Θ : Type*} (ψ : Θ → ℝ) (θ : Θ) (a : ℝ) : ℝ :=
  |a - ψ θ|

/-- Pérdida de clasificación `L(θ,a) = 1{a ≠ g(θ)}` de la tabla de
`ex:ch7-perdidas`. El espacio de acciones `A` es independiente del de
parámetros `Θ`: la categoría `g(θ)` no exige que el parámetro sea una
etiqueta (frase final del ejemplo del libro). -/
def lossClas {Θ A : Type*} [DecidableEq A] (g : Θ → A) (θ : Θ) (a : A) : ℝ :=
  if a = g θ then 0 else 1

/-- Pérdida cuadrática ponderada `L(θ,a) = w(θ)·(a − ψ(θ))²` de la tabla de
`ex:ch7-perdidas` (el libro pide `w(θ) ≥ 0`). -/
def lossPond {Θ : Type*} (w ψ : Θ → ℝ) (θ : Θ) (a : ℝ) : ℝ :=
  w θ * (a - ψ θ) ^ 2

/-- Media ponderada `∑_x P_θ(x)·δ(x)`: la esperanza de `δ(X)` bajo los pesos
`P_θ` del problema finito (la `EE_theta[δ(X)]` del capítulo). -/
def mediaP {Θ X : Type*} [Fintype X] (P : Θ → X → ℝ) (θ : Θ) (δ : X → ℝ) : ℝ :=
  ∑ x, P θ x * δ x

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
[fila 1 de 4: pérdida cuadrática] el riesgo de la pérdida cuadrática es el
error cuadrático medio, y bajo pesos normalizados se descompone como
varianza ponderada más sesgo al cuadrado:
`∑_x P_θ(x)(δ(x) − ψ(θ))² = ∑_x P_θ(x)(δ(x) − m)² + (m − ψ(θ))²`, con
`m = ∑_x P_θ(x)δ(x)` la media ponderada.
Fidelidad declarada: problema finito del proyecto (`Θ`, `X` finitos, `P_θ`
pesos no normalizados en general); la normalización `∑_x P_θ(x) = 1` es la
hipótesis `hP1` — es la lectura de «riesgo = media bajo `P_θ`» del libro. La
acción es real (`a : ℝ`), como en la tabla. -/
theorem ex_ch7_perdidas_cuadratica {Θ X : Type*} [Fintype X] (P : Θ → X → ℝ)
    (ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ) (hP1 : ∑ x, P θ x = 1) :
    risk P (lossCuad ψ) θ δ
      = ∑ x, P θ x * (δ x - mediaP P θ δ) ^ 2 + (mediaP P θ δ - ψ θ) ^ 2 := by
  have hsum : ∑ x, P θ x * δ x = mediaP P θ δ := rfl
  have hpx : ∀ x : X, P θ x * (δ x - ψ θ) ^ 2
      = P θ x * (δ x - mediaP P θ δ) ^ 2
        + 2 * (mediaP P θ δ - ψ θ) * (P θ x * (δ x - mediaP P θ δ))
        + (mediaP P θ δ - ψ θ) ^ 2 * P θ x := by
    intro x
    have h : δ x - ψ θ = (δ x - mediaP P θ δ) + (mediaP P θ δ - ψ θ) := by ring
    rw [h]; ring
  have hcross : ∑ x, P θ x * (δ x - mediaP P θ δ) = 0 := by
    have h2 : ∀ x : X, P θ x * (δ x - mediaP P θ δ)
        = P θ x * δ x - P θ x * mediaP P θ δ := by
      intro x; ring
    rw [Finset.sum_congr rfl fun x _ => h2 x, Finset.sum_sub_distrib, hsum,
      ← Finset.sum_mul, hP1, one_mul, sub_self]
  have hB : ∑ x, 2 * (mediaP P θ δ - ψ θ) * (P θ x * (δ x - mediaP P θ δ)) = 0 := by
    rw [← Finset.mul_sum, hcross, mul_zero]
  have hC : ∑ x, (mediaP P θ δ - ψ θ) ^ 2 * P θ x = (mediaP P θ δ - ψ θ) ^ 2 := by
    rw [← Finset.mul_sum, hP1, mul_one]
  simp only [risk, lossCuad]
  rw [Finset.sum_congr rfl fun x _ => hpx x, Finset.sum_add_distrib,
    Finset.sum_add_distrib, hB, hC, add_zero]

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
[fila 3 de 4: clasificación] con pesos normalizados, el riesgo de la pérdida
de clasificación es la probabilidad de clasificación errónea, es decir uno
menos la masa de acierto: `∑_x P_θ(x)·1{δ(x) ≠ g(θ)} = 1 − ∑_x P_θ(x)·1{δ(x) = g(θ)}`.
Fidelidad declarada: problema finito; `g : Θ → A` con `A` arbitrario
(la categoría no es el parámetro, como señala el libro). -/
theorem ex_ch7_perdidas_clasificacion {Θ X A : Type*} [Fintype X] [DecidableEq A]
    (P : Θ → X → ℝ) (g : Θ → A) (θ : Θ) (δ : X → A)
    (hP1 : ∑ x, P θ x = 1) :
    risk P (lossClas g) θ δ
      = 1 - ∑ x, P θ x * (if δ x = g θ then (1 : ℝ) else 0) := by
  have h1 : ∀ x : X, P θ x * (if δ x = g θ then (0 : ℝ) else 1)
      = P θ x - P θ x * (if δ x = g θ then (1 : ℝ) else 0) := by
    intro x
    by_cases h : δ x = g θ <;> simp [h]
  simp only [risk, lossClas]
  rw [Finset.sum_congr rfl fun x _ => h1 x, Finset.sum_sub_distrib, hP1]

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
[fila 4 de 4: cuadrática ponderada] el riesgo de la pérdida cuadrática
ponderada es el error ponderado: el peso `w(θ)` sale del promedio,
`∑_x P_θ(x)·w(θ)(δ(x) − ψ(θ))² = w(θ)·∑_x P_θ(x)(δ(x) − ψ(θ))²`.
Fidelidad declarada: problema finito; el peso `w(θ)` puede ser cualquier real
en la identidad (la no negatividad se usa en las cotas de signo, más abajo). -/
theorem ex_ch7_perdidas_ponderada {Θ X : Type*} [Fintype X] (P : Θ → X → ℝ)
    (w ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ) :
    risk P (lossPond w ψ) θ δ = w θ * ∑ x, P θ x * (δ x - ψ θ) ^ 2 := by
  simp only [risk, lossPond]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
las cuatro pérdidas de la tabla son no negativas, de modo que sus riesgos lo
son bajo pesos no negativos: es la lectura «riesgo» de cada fila (error
cuadrático medio, error absoluto esperado, probabilidad de error de
clasificación, error ponderado con `w(θ) ≥ 0`).
Fidelidad declarada: problema finito, pesos no negativos (`hP0`). -/
theorem ex_ch7_perdidas_no_negativas {Θ X A : Type*} [Fintype X] [DecidableEq A]
    (P : Θ → X → ℝ) (hP0 : ∀ θ x, 0 ≤ P θ x) :
    (∀ (ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ), 0 ≤ risk P (lossCuad ψ) θ δ)
    ∧ (∀ (ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ), 0 ≤ risk P (lossAbs ψ) θ δ)
    ∧ (∀ (w ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ), 0 ≤ w θ → 0 ≤ risk P (lossPond w ψ) θ δ)
    ∧ (∀ (g : Θ → A) (θ : Θ) (δ : X → A), 0 ≤ risk P (lossClas g) θ δ) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro ψ θ δ
    simp only [risk, lossCuad]
    exact Finset.sum_nonneg fun x _ => mul_nonneg (hP0 θ x) (sq_nonneg _)
  · intro ψ θ δ
    simp only [risk, lossAbs]
    exact Finset.sum_nonneg fun x _ => mul_nonneg (hP0 θ x) (abs_nonneg _)
  · intro w ψ θ δ hw
    simp only [risk, lossPond]
    exact Finset.sum_nonneg fun x _ =>
      mul_nonneg (hP0 θ x) (mul_nonneg hw (sq_nonneg _))
  · intro g θ δ
    simp only [risk, lossClas]
    exact Finset.sum_nonneg fun x _ =>
      mul_nonneg (hP0 θ x) (by split <;> norm_num)

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
ancla de la clave: con pesos no negativos y normalizados (`∑_x P_θ(x) = 1`),
el riesgo de cada fila de la tabla es el objeto que el libro nombra —
error cuadrático medio descompuesto en varianza más sesgo, error absoluto
esperado como suma ponderada de desviaciones absolutas, probabilidad de
clasificación errónea como uno menos la masa de acierto, y error ponderado
con el factor `w(θ)` fuera del promedio.
Fidelidad declarada: la de las cuatro partes; problema finito del proyecto. -/
theorem ex_ch7_perdidas {Θ X A : Type*} [Fintype X] [DecidableEq A]
    (P : Θ → X → ℝ) (hP0 : ∀ θ x, 0 ≤ P θ x) (hP1 : ∀ θ, ∑ x, P θ x = 1)
    (ψ : Θ → ℝ) (g : Θ → A) (w : Θ → ℝ) (θ : Θ) (δ : X → ℝ) (δc : X → A) :
    (risk P (lossCuad ψ) θ δ
        = ∑ x, P θ x * (δ x - mediaP P θ δ) ^ 2 + (mediaP P θ δ - ψ θ) ^ 2)
      ∧ (risk P (lossAbs ψ) θ δ = ∑ x, P θ x * |δ x - ψ θ|)
      ∧ (risk P (lossClas g) θ δc
        = 1 - ∑ x, P θ x * (if δc x = g θ then (1 : ℝ) else 0))
      ∧ (risk P (lossPond w ψ) θ δ = w θ * ∑ x, P θ x * (δ x - ψ θ) ^ 2)
      ∧ 0 ≤ risk P (lossCuad ψ) θ δ := by
  refine ⟨ex_ch7_perdidas_cuadratica P ψ θ δ (hP1 θ), ?_, ?_, ?_, ?_⟩
  · simp only [risk, lossAbs]
  · exact ex_ch7_perdidas_clasificacion P g θ δc (hP1 θ)
  · exact ex_ch7_perdidas_ponderada P w ψ θ δ
  · simp only [risk, lossCuad]
    exact Finset.sum_nonneg fun x _ => mul_nonneg (hP0 θ x) (sq_nonneg _)

/-- book: capitulos/cap02_wald.typ:40 (key: ex:ch7-perdidas) —
la tabla no exige que la observación viva en un espacio finito: para una
observación en un espacio medible arbitrario (`X` con una medida `Pm`), el
riesgo de la pérdida cuadrática ponderada es
`∫ w(θ)(δ − ψ(θ))² dPm = w(θ)·∫ (δ − ψ(θ))² dPm`; es la frase del ejemplo
«el objetivo `ψ(θ)` puede ser escalar aunque el modelo tenga dimensión
infinita», con el peso fuera de la integral.
Fidelidad declarada: versión medida; se pide integrabilidad del cuadrado
(`hint`) y `Pm` finita. -/
theorem ex_ch7_perdidas_ponderada_medida {Θ X : Type*} [MeasurableSpace X]
    (Pm : Measure X) [IsFiniteMeasure Pm] (w ψ : Θ → ℝ) (θ : Θ) (δ : X → ℝ)
    (_hint : Integrable (fun x => (δ x - ψ θ) ^ 2) Pm) :
    ∫ x, lossPond w ψ θ (δ x) ∂Pm = w θ * ∫ x, (δ x - ψ θ) ^ 2 ∂Pm := by
  simpa only [lossPond] using integral_const_mul (μ := Pm) (w θ) (fun x => (δ x - ψ θ) ^ 2)

/-! ## `ex:ch7-james-stein` — identidad de riesgo y dominancia (cap02_wald.typ:61)

El ejemplo del libro: para `X ~ N_p(θ, I_p)` con `p ≥ 3` y pérdida
`‖a − θ‖²`, la regla `δ₀(X) = X` tiene riesgo `p`, mientras que
`δ_JS(X) = (1 − (p−2)/‖X‖²)·X` satisface
`R(θ, δ_JS) = p − (p−2)²·E_θ[‖X‖⁻²] < p`.

La demostración del libro (`apendices/apendice_demostraciones.typ`,
`dem:ch2-james-stein`) tiene dos piezas: (i) la identidad algebraica
puntual que escribe la pérdida de `δ_JS` como la de `δ₀` más dos términos,
y (ii) dos entradas analíticas gaussianas — el riesgo `p` de `δ₀` y la
identidad de Stein `E_θ[⟪X−θ, X⟫/‖X‖²] = (p−2)·E_θ[‖X‖⁻²]` (que usa
`div(x/‖x‖²) = (p−2)/‖x‖²` y la finitud de la esperanza para `p ≥ 3`).
Aquí se formaliza (i) y se deduce la identidad de riesgo y la dominancia
estricta; (ii) entra como hipótesis explícitas, declaradas en la fidelidad. -/

/-- Estimador de James–Stein `δ_JS(x) = (1 − (p−2)/‖x‖²)·x`, escrito para
cualquier espacio con producto interno real. En `x = 0` la división de Lean
da `0` y el estimador vale `0`; el ejemplo del libro advierte que ese valor
es arbitrario porque el evento tiene probabilidad cero (véase
`james_stein_valor_nulo`). -/
noncomputable def jsEst {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (p : ℕ) (x : E) : E :=
  (1 - ((p : ℝ) - 2) / ‖x‖ ^ 2) • x

/-- Riesgo de una regla `δ` bajo pérdida cuadrática `‖a − θ‖²`:
`R(θ, δ) = ∫ ‖δ(X) − θ‖² dP_θ`, con `P_θ` la ley de la observación. -/
noncomputable def riesgo {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E]
    (μ : Measure Ω) (X : Ω → E) (θ : E) (δ : E → E) : ℝ :=
  ∫ ω, ‖δ (X ω) - θ‖ ^ 2 ∂μ

/-- `δ_JS` en la forma `x + g(x)` del libro: `g(x) = −((p−2)/‖x‖²)·x`. -/
theorem jsEst_eq_add {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (p : ℕ) (x : E) :
    jsEst p x = x + (-(((p : ℝ) - 2) / ‖x‖ ^ 2)) • x := by
  have hs : (1 - ((p : ℝ) - 2) / ‖x‖ ^ 2) = 1 + (-(((p : ℝ) - 2) / ‖x‖ ^ 2)) := by
    ring
  simp only [jsEst, hs, add_smul, one_smul]

/-- En dimensión `p = 2` el factor de contracción es `1 − 0/‖x‖² = 1`: el
estimador de James–Stein coincide con `δ₀` y no hay mejora. Es la lectura
formal de «el resultado concierne a la dimensión `p` del parámetro» con la
condición `p ≥ 3` del ejemplo. -/
theorem jsEst_two {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] (x : E) :
    jsEst 2 x = x := by
  have h : ((2 : ℕ) : ℝ) - 2 = 0 := by norm_num
  simp only [jsEst, h, zero_div, sub_zero, one_smul]

/-- Identidad algebraica puntual de James–Stein (`dem:ch2-james-stein`):
`‖(1 − c/‖x‖²)x − θ‖² = ‖x − θ‖² − 2c·⟪x − θ, x⟫/‖x‖² + c²/‖x‖²`.
Vale para todo `x`, también en `x = 0` (donde ambos lados valen `‖θ‖²`),
porque en Lean la división por `0` es `0`; el libro solo la necesita fuera
de `x = 0`, que es un conjunto de probabilidad cero. -/
theorem js_norm_sq {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (c : ℝ) (x θ : E) :
    ‖(1 - c / ‖x‖ ^ 2) • x - θ‖ ^ 2
      = ‖x - θ‖ ^ 2 - 2 * c * (⟪x - θ, x⟫ / ‖x‖ ^ 2) + c ^ 2 / ‖x‖ ^ 2 := by
  have hdecomp : (1 - c / ‖x‖ ^ 2) • x - θ = (x - θ) - (c / ‖x‖ ^ 2) • x := by
    rw [sub_smul, one_smul]
    abel
  have hkey : (c / ‖x‖ ^ 2) ^ 2 * ‖x‖ ^ 2 = c ^ 2 / ‖x‖ ^ 2 := by
    rcases eq_or_ne (‖x‖ ^ 2) 0 with h | h
    · simp [h]
    · field_simp
  rw [hdecomp, norm_sub_sq_real, real_inner_smul_right, norm_smul, mul_pow]
  simp only [Real.norm_eq_abs, sq_abs]
  rw [hkey]
  ring

/-- Identidad escalar de la demostración del libro: con `c = p − 2`, el
término `p − 2c·c·C + c²·C` es `p − c²·C`. Es el último paso de
`dem:ch2-james-stein` (`‖g‖² = c²/‖x‖²` y `div g = −c²/‖x‖²`). -/
theorem js_scalar (p : ℕ) (C : ℝ) :
    (p : ℝ) + (-(2 * ((p : ℝ) - 2))) * (((p : ℝ) - 2) * C) + ((p : ℝ) - 2) ^ 2 * C
      = (p : ℝ) - ((p : ℝ) - 2) ^ 2 * C := by
  ring

/-- book: capitulos/cap02_wald.typ:61 (key: ex:ch7-james-stein) —
identidad de riesgo de James–Stein: en `ℝ^p` con pérdida cuadrática y
observación de ley `μ`, si el riesgo de `δ₀(x) = x` es `p` y vale la
identidad de Stein, entonces
`R(θ, δ_JS) = ∫ ‖δ_JS(X) − θ‖² dμ = p − (p−2)²·∫ ‖X‖⁻² dμ`.
Fidelidad declarada: la identidad algebraica puntual se prueba
(`js_norm_sq`) y la linealidad de la integral se usa con integrabilidad
explícita (`h1`, `h2`, `h3`); las dos entradas analíticas gaussianas del
libro entran como hipótesis: `hR0` (riesgo `p` de `δ₀`, es decir
`E_θ‖X − θ‖² = p` para `X ~ N_p(θ, I_p)`) y `hStein` (identidad de Stein
`E_θ[⟪X−θ, X⟫/‖X‖²] = (p−2)·E_θ[‖X‖⁻²]`, cuya versión gaussiana requiere
`div(x/‖x‖²) = (p−2)/‖x‖²` y la finitud de `E_θ[‖X‖⁻²]` para `p ≥ 3`).
Lo formalizado es exactamente la cadena de `dem:ch2-james-stein` una vez
aceptadas esas dos entradas. -/
theorem james_stein_riesgo {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}
    [IsProbabilityMeasure μ] {p : ℕ} (X : Ω → EuclideanSpace ℝ (Fin p))
    (θ : EuclideanSpace ℝ (Fin p))
    (h1 : Integrable (fun ω => ‖X ω - θ‖ ^ 2) μ)
    (h2 : Integrable (fun ω => ⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) μ)
    (h3 : Integrable (fun ω => (‖X ω‖ ^ 2)⁻¹) μ)
    (hR0 : ∫ ω, ‖X ω - θ‖ ^ 2 ∂μ = (p : ℝ))
    (hStein : ∫ ω, ⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2 ∂μ
      = ((p : ℝ) - 2) * ∫ ω, (‖X ω‖ ^ 2)⁻¹ ∂μ) :
    riesgo μ X θ (jsEst p)
      = (p : ℝ) - ((p : ℝ) - 2) ^ 2 * ∫ ω, (‖X ω‖ ^ 2)⁻¹ ∂μ := by
  set C : ℝ := ∫ ω, (‖X ω‖ ^ 2)⁻¹ ∂μ with hC
  have hpt : ∀ ω : Ω, ‖jsEst p (X ω) - θ‖ ^ 2
      = ‖X ω - θ‖ ^ 2 + (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2)
        + ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹ := by
    intro ω
    have h := js_norm_sq ((p : ℝ) - 2) (X ω) θ
    rw [jsEst, h, div_eq_mul_inv]
    ring
  have hI2 : Integrable (fun ω => (-(2 * ((p : ℝ) - 2)))
      * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2)) μ := h2.const_mul _
  have hI3 : Integrable (fun ω => ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹) μ := h3.const_mul _
  have step0 : ∫ ω, ‖jsEst p (X ω) - θ‖ ^ 2 ∂μ
      = ∫ ω, ‖X ω - θ‖ ^ 2 + (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2)
          + ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹ ∂μ := by
    exact integral_congr_ae (Filter.Eventually.of_forall hpt)
  have step1 : ∫ ω, ‖X ω - θ‖ ^ 2 + (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2)
        + ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹ ∂μ
      = (∫ ω, ‖X ω - θ‖ ^ 2 + (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) ∂μ)
        + ∫ ω, ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹ ∂μ :=
    integral_add (h1.add hI2) hI3
  have step2a : ∫ ω, ‖X ω - θ‖ ^ 2 + (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) ∂μ
      = ∫ ω, ‖X ω - θ‖ ^ 2 ∂μ
        + ∫ ω, (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) ∂μ :=
    integral_add h1 hI2
  have step2b : ∫ ω, (-(2 * ((p : ℝ) - 2))) * (⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) ∂μ
      = (-(2 * ((p : ℝ) - 2))) * ∫ ω, ⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2 ∂μ :=
    integral_const_mul _ _
  have step3 : ∫ ω, ((p : ℝ) - 2) ^ 2 * (‖X ω‖ ^ 2)⁻¹ ∂μ = ((p : ℝ) - 2) ^ 2 * C := by
    rw [integral_const_mul, ← hC]
  simp only [riesgo]
  rw [step0, step1, step2a, step2b, step3, hR0, hStein]
  exact js_scalar p C

/-- book: capitulos/cap02_wald.typ:61 (key: ex:ch7-james-stein) —
dominancia estricta: con `p ≥ 3` y una esperanza positiva `∫ ‖X‖⁻² dμ > 0`,
el riesgo de James–Stein es estrictamente menor que `p`, el riesgo de
`δ₀(x) = x`:
`∫ ‖δ_JS(X) − θ‖² dμ < p`.
Fidelidad declarada: la de `james_stein_riesgo`; `hpos` es la positividad de
`E_θ[‖X‖⁻²]` (para `X ~ N_p(θ, I_p)` con `p ≥ 3` la esperanza es finita y
positiva, hecho gaussiano declarado aquí como hipótesis). -/
theorem james_stein_mejora {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}
    [IsProbabilityMeasure μ] {p : ℕ} (hp : 3 ≤ p) (X : Ω → EuclideanSpace ℝ (Fin p))
    (θ : EuclideanSpace ℝ (Fin p))
    (h1 : Integrable (fun ω => ‖X ω - θ‖ ^ 2) μ)
    (h2 : Integrable (fun ω => ⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2) μ)
    (h3 : Integrable (fun ω => (‖X ω‖ ^ 2)⁻¹) μ)
    (hR0 : ∫ ω, ‖X ω - θ‖ ^ 2 ∂μ = (p : ℝ))
    (hStein : ∫ ω, ⟪X ω - θ, X ω⟫ / ‖X ω‖ ^ 2 ∂μ
      = ((p : ℝ) - 2) * ∫ ω, (‖X ω‖ ^ 2)⁻¹ ∂μ)
    (hpos : 0 < ∫ ω, (‖X ω‖ ^ 2)⁻¹ ∂μ) :
    riesgo μ X θ (jsEst p) < (p : ℝ) := by
  rw [james_stein_riesgo X θ h1 h2 h3 hR0 hStein]
  have hc : (0 : ℝ) < ((p : ℝ) - 2) ^ 2 := by
    have h2p : (2 : ℝ) < (p : ℝ) := by
      have : (2 : ℕ) < p := by omega
      exact_mod_cast this
    nlinarith
  nlinarith

/-- book: capitulos/cap02_wald.typ:61 (key: ex:ch7-james-stein) —
«su valor en `X = 0` se define arbitrariamente, pues ese evento tiene
probabilidad cero»: cualquier regla `Y` que coincida con `δ_JS(X)` salvo en
un conjunto `μ`-nulo tiene el mismo riesgo. -/
theorem james_stein_valor_nulo {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}
    {p : ℕ} (X : Ω → EuclideanSpace ℝ (Fin p)) (θ : EuclideanSpace ℝ (Fin p))
    (Y : Ω → EuclideanSpace ℝ (Fin p)) (hae : ∀ᵐ ω ∂μ, Y ω = jsEst p (X ω)) :
    ∫ ω, ‖Y ω - θ‖ ^ 2 ∂μ = ∫ ω, ‖jsEst p (X ω) - θ‖ ^ 2 ∂μ :=
  integral_congr_ae (hae.mono fun ω hω => by
    show ‖Y ω - θ‖ ^ 2 = ‖jsEst p (X ω) - θ‖ ^ 2
    rw [hω])

end Cap02M11

/-! ## Auditoría de axiomas -/

#print axioms Cap02M11.ex_ch7_perdidas_cuadratica
#print axioms Cap02M11.ex_ch7_perdidas_clasificacion
#print axioms Cap02M11.ex_ch7_perdidas_ponderada
#print axioms Cap02M11.ex_ch7_perdidas_no_negativas
#print axioms Cap02M11.ex_ch7_perdidas
#print axioms Cap02M11.ex_ch7_perdidas_ponderada_medida
#print axioms Cap02M11.jsEst_eq_add
#print axioms Cap02M11.jsEst_two
#print axioms Cap02M11.js_norm_sq
#print axioms Cap02M11.js_scalar
#print axioms Cap02M11.james_stein_riesgo
#print axioms Cap02M11.james_stein_mejora
#print axioms Cap02M11.james_stein_valor_nulo
