import Mathlib

/-!
# Book.Cap06Fronteras — cap. 6 del libro (capitulos/cap06_fallos.typ)

Transporte de conjuntos de confianza por imagen (`thm:ch9-ic`): la parte
operativa del resultado del libro, en la capa de sumas finitas.

Fidelidad declarada (plan §4): espacio muestral `Ω` finito con pesos `w ≥ 0`
de suma 1 (la ley `P`); el conjunto de confianza `C_n` es una función de la
muestra; la cobertura es la probabilidad del suceso `θ ∈ C_n`. La prueba es
la del libro: el suceso `{θ ∈ C_n}` está contenido en
`{g(θ) ∈ g(C_n)}`, y la probabilidad de un suceso no decrece al agrandarlo.
La observación del libro de que el conjunto imagen no tiene por qué ser un
intervalo (y que su envolvente intervalar conserva la desigualdad cuando
está bien definida) es comentario, no parte formalizable aquí.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

universe u

section IC

variable {Ω Θ : Type u} [Fintype Ω] [Fintype Θ] [DecidableEq Θ]

/-- book: capitulos/cap06_fallos.typ:181 (key: thm:ch9-ic) —
transporte de conjuntos de confianza: si `C_n` cubre a `θ` con probabilidad
`≥ 1 - α`, el conjunto imagen `g(C_n)` cubre a `g(θ)` con la misma cota.
La cobertura puede aumentar; el conjunto imagen no es necesariamente un
intervalo.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch9_ic (w : Ω → ℝ) (hw : ∀ ω, 0 ≤ w ω) (hw1 : ∑ ω, w ω = 1)
    (θ : Θ) (g : Θ → Θ) (C : Ω → Finset Θ) (α : ℝ)
    (h : 1 - α ≤ ∑ ω, if θ ∈ C ω then w ω else 0) :
    1 - α ≤ ∑ ω, if g θ ∈ Finset.image g (C ω) then w ω else 0 := by
  refine le_trans h ?_
  refine Finset.sum_le_sum ?_
  intro ω _
  by_cases hθ : θ ∈ C ω
  · have hmem : g θ ∈ Finset.image g (C ω) := Finset.mem_image_of_mem _ hθ
    simp [hθ, hmem]
  · simp only [hθ, if_false]
    split_ifs
    · exact hw ω
    · rfl

end IC
