import Mathlib
import Book.Foundation

/-!
# Book.Cap04Herramientas — cap. 1-4 del libro (cap04_herramientas.typ)

Familias exponenciales en espacio muestral finito: funcion de
particion `Z(η) = ∑_x h(x)·exp(η·T(x))`, log-particion `A(η) = log Z(η)`,
y la identidad derivada = media (`thm:ch1-logparticion`).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

universe u

section ExpFam

variable {X : Type u} [Fintype X] [Nonempty X] (h : X → ℝ) (T : X → ℝ)

/-- Funcion de particion: `Z(η) = ∑_x h(x)·exp(η·T(x))`. -/
noncomputable def partFun (η : ℝ) : ℝ := ∑ x, h x * Real.exp (η * T x)

/-- Log-particion: `A(η) = log Z(η)`. -/
noncomputable def logPart (η : ℝ) : ℝ := Real.log (partFun h T η)

/-- Esperanza del estadistico `T` bajo la familia exponencial. -/
noncomputable def expMean (η : ℝ) : ℝ :=
  ∑ x, T x * (h x * Real.exp (η * T x)) / partFun h T η

/-- Varianza del estadistico `T` bajo la familia exponencial. -/
noncomputable def expVar (η : ℝ) : ℝ :=
  ∑ x, (T x - expMean h T η) ^ 2 * (h x * Real.exp (η * T x)) / partFun h T η

/-- Positividad de la funcion de particion (pesos positivos). -/
theorem partFun_pos (hpos : ∀ x, 0 < h x) (η : ℝ) : 0 < partFun h T η := by
  obtain ⟨x₀⟩ := ‹Nonempty X›
  refine Finset.sum_pos' (fun x _ => ?_) ⟨x₀, Finset.mem_univ x₀, ?_⟩
  · exact mul_nonneg (le_of_lt (hpos x)) (le_of_lt (Real.exp_pos (η * T x)))
  · exact mul_pos (hpos x₀) (Real.exp_pos (η * T x₀))

/-- Derivada de la funcion de particion (base no enunciada):
`Z'(η) = ∑_x h(x)·exp(η·T(x))·T(x)`. La prueba usa HasDerivAt.sum
sobre la forma suma-de-funciones (la igualdad con partFun es por
funext + Finset.sum_apply, aplicada como reescritura previa). -/
theorem hasDerivAt_partFun (η : ℝ) :
    HasDerivAt (partFun h T) (∑ x, h x * (Real.exp (η * T x) * T x)) η := by
  have h1 : ∀ x : X, HasDerivAt (fun y => h x * Real.exp (y * T x))
      (h x * (Real.exp (η * T x) * T x)) η := by
    intro x
    have hmul : HasDerivAt (fun y => y * T x) (T x) η := by
      simpa using (hasDerivAt_id η).mul_const (T x)
    exact hmul.exp.const_mul (h x)
  have hfun : partFun h T = (∑ x : X, fun y => h x * Real.exp (y * T x)) := by
    funext y
    simp [partFun, Finset.sum_apply]
  rw [hfun]
  exact HasDerivAt.sum fun x _ => h1 x

/-- book: capitulos/cap04_herramientas.typ:314 (key: thm:ch1-logparticion) —
propiedades de la funcion log-particion (parte 3: cumulantes): la
primera derivada de `A(η)` es la esperanza del estadistico natural:
`A'(η) = E_η[T(X)]`. La prueba es la regla de la cadena para
`log ∘ Z` con `Z'` de `hasDerivAt_partFun`, seguida de la
reorganizacion `Z'/Z = E_η[T]`.
Fidelidad declarada: version finita con estadistico y parametro
escalares; la convexidad y la diferenciabilidad infinita son
cualitativas y no se enuncian por separado.
Origen: F-correction 2026-11-07 (nuevo; formalizacion de pendiente). -/
theorem ch1_logparticion (hpos : ∀ x, 0 < h x) (η : ℝ) :
    HasDerivAt (logPart h T) (expMean h T η) η := by
  have hZ := hasDerivAt_partFun h T η
  have hZpos := partFun_pos h T hpos η
  have hlog := hZ.log (ne_of_gt hZpos)
  have heq : (∑ x, h x * (Real.exp (η * T x) * T x)) / partFun h T η
      = expMean h T η := by
    unfold expMean
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun x _ => by ring
  rw [heq] at hlog
  exact hlog

end ExpFam
