import Mathlib

/-!
# Book.SSCHEjemplosM7 — `ex:ssch-trazability`: trazabilidad de una evaluación

Formaliza el ejemplo `ex:ssch-trazability` de
`capitulos/cap09_verificacion.typ:631` (enjambre `smw9820kx`, dirección `d7`).

El ejemplo: objetivo `Δ` = diferencia entre una política que juega acción uno
con probabilidad `0.75` y una referencia con probabilidad `0.5`, descuento
`0.9`, cien episodios iid de un entorno sintético. Contribuciones pareadas de
diferencia `0.520, 0.340, 0.430, 0.610`, cada una repetida 25 veces. El libro
publica

  `Δ̂ = 0.475`, `s²_Δ = (100/99)(0.010125)`, `SE = sqrt(s²/100) ≈ 0.010113`,
  IC bilateral normal 95% `[0.455, 0.495]`, límite unilateral al 5%
  `0.475 − 1.64485·SE ≈ 0.45837`,

y dictamina: con margen `δ₀ = 0.40` hay evidencia de mejora superior a `0.40`;
con margen `0.47` no la hay. La ruta del catálogo es DR → CLT → CI y la
propiedad afirmada es **asintótica**.

Fidelidad declarada: todo es aritmética racional exacta (plan §4: prohibido
verificar con flotantes) más el cálculo de una raíz con cotas racionales. Las
contribuciones repetidas 25 veces dan exactamente la misma media y la misma
varianza poblacional que las cuatro historias (porque `25/100 = 1/4`), y así se
calculan. La cobertura exacta del intervalo y la aproximación normal **no** se
demuestran: se formaliza la aritmética que el dictamen usa, que es lo que la
trazabilidad exige (poder localizar y reproducir el cálculo, no certificar la
aproximación).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHEjemplosM7

/-! ## Las cuatro historias y sus contribuciones pareadas -/

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
contribuciones pareadas de diferencia por historia de acciones:
`0.520, 0.340, 0.430, 0.610`. -/
def contrib : Fin 4 → ℝ := ![0.520, 0.340, 0.430, 0.610]

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
media de las contribuciones (las cuatro historias son equiprobables). -/
noncomputable def media : ℝ := (∑ i, contrib i) / 4

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
`Δ̂ = 0.475` (el libro escribe 0.475). -/
theorem media_eq : media = 19 / 40 := by
  simp only [media, contrib, Fin.sum_univ_four]
  norm_num

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
varianza poblacional sobre los cien episodios: al repetir cada historia 25
veces, `(1/100)Σ_{100}(c−x̄)² = (1/4)Σ_4(c−x̄)² = 0.010125`. -/
noncomputable def varPob : ℝ := (∑ i, (contrib i - media) ^ 2) / 4

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
`varianza poblacional = 0.010125 = 81/8000`. -/
theorem varPob_eq : varPob = 81 / 8000 := by
  rw [varPob, media_eq]
  simp only [contrib, Fin.sum_univ_four]
  norm_num

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
`varianza insesgada = (100/99)·0.010125`. -/
noncomputable def varIns : ℝ := (100 / 99) * varPob

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
`SE = sqrt(varIns/100)`, es decir `sqrt(s²_Δ/n)` con `n = 100`. -/
noncomputable def se : ℝ := Real.sqrt (varIns / 100)

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
`SE² = 81/792000`, la forma exacta con la que se acotan los extremos. -/
theorem se_sq : se ^ 2 = 81 / 792000 := by
  rw [se, varIns, varPob_eq]
  rw [Real.sq_sqrt (by norm_num)]
  norm_num

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
**cota del error estándar**: `0.01011 < SE < 0.01012`, que es la única
información numérica que necesitan el intervalo y el dictamen. -/
theorem se_bounds : 0.01011 < se ∧ se < 0.01012 := by
  have hsq : se ^ 2 = 81 / 792000 := se_sq
  have hnn : 0 ≤ se := Real.sqrt_nonneg _
  constructor
  · nlinarith [hsq, hnn, (by norm_num : (0.01011 : ℝ) ^ 2 < 81 / 792000)]
  · nlinarith [hsq, hnn, (by norm_num : (81 / 792000 : ℝ) < (0.01012) ^ 2)]

/-! ## El intervalo y el dictamen -/

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) — el
IC bilateral normal al 95% `0.475 ± 1.96·SE` cae estrictamente dentro de
`[0.455, 0.495]`, que es lo que el libro publica. -/
theorem ic95_bounds :
    0.455 < media - 1.96 * se ∧ media + 1.96 * se < 0.495 := by
  have h := se_bounds
  rw [media_eq]
  constructor <;> nlinarith [h.1, h.2]

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
límite inferior unilateral al 5%: `0.475 − 1.64485·SE ∈ (0.45835, 0.45838)`,
que contiene el valor publicado `0.45837`. -/
theorem limite_unilateral :
    0.45835 < media - 1.64485 * se ∧ media - 1.64485 * se < 0.45838 := by
  have h := se_bounds
  rw [media_eq]
  constructor <;> nlinarith [h.1, h.2]

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
**dictamen con margen `δ₀ = 0.40`**: el límite inferior supera el margen
prefijado; bajo el experimento y la aproximación declarados hay evidencia de
mejora superior a `0.40` (no es una conclusión clínica). -/
theorem dictamen_margen_040 : 0.40 < media - 1.64485 * se := by
  have h := limite_unilateral.1
  linarith

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) —
**el margen `0.47` invalida el dictamen**: mantener todo lo demás y subir el
margen deja el límite inferior por debajo de `0.47`, luego no hay evidencia de
esa mejora mayor. -/
theorem dictamen_margen_047 : media - 1.64485 * se < 0.47 := by
  have h := limite_unilateral.2
  linarith

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) — el
dictamen no es monótono en el margen: existe un umbral (el propio límite
inferior) por debajo del cual se declara evidencia y por encima del cual no. -/
theorem umbral_del_dictamen :
    (0.40 < media - 1.64485 * se) ∧ ¬ (0.47 < media - 1.64485 * se) := by
  refine ⟨dictamen_margen_040, ?_⟩
  have h := dictamen_margen_047
  linarith

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) — la
varianza usada es la **pareada**: `s²_Δ = (100/99)(0.010125)` y no `(1/100)`
del cálculo poblacional. La diferencia entre ambas es exactamente el factor
`100/99`. -/
theorem varIns_eq : varIns = 100 / 99 * (81 / 8000) := by
  rw [varIns, varPob_eq]

/-- book: capitulos/cap09_verificacion.typ:631 (key: ex:ssch-trazability) — con
`n = 100` la corrección `100/99` es pequeña pero no nula: `varIns − varPob =
varPob/99`, de modo que el programa que usara la varianza poblacional
subestimaría el error estándar. -/
theorem correccion_no_nula : varIns - varPob = varPob / 99 := by
  rw [varIns]
  field_simp
  ring

end SSCHEjemplosM7
