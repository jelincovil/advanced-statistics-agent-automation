/-
Apendice E — §Integrabilidad/Hilbert: tres claves pendientes de
`apendices/apendice_medido.typ`:

* `thm:appE-proyeccion`   (línea 225) — teorema de proyección ortogonal.
* `ex:appE-l2`            (línea 218) — `L²(P)` como espacio de Hilbert.
* `ex:appE-gaussiano`     (línea 163) — modelo gaussiano dominado por Lebesgue.

Cada teorema lleva su traza bidireccional `book: <archivo>:<línea> (key: <clave>)`
y una nota de fidelidad frente al enunciado del libro.

Toolchain: Lean 4.35.0 + Mathlib precompilada en `/opt/mathlib`.
-/
import Mathlib

noncomputable section

open MeasureTheory
open scoped InnerProductSpace NNReal

namespace ApendiceEHilbert

/-! ## `thm:appE-proyeccion` — teorema de proyección ortogonal -/

/-- book: apendices/apendice_medido.typ:225 (key: thm:appE-proyeccion) —

Sea `H` un espacio de Hilbert real y `M ⊆ H` un subespacio cerrado. Para todo
`f ∈ H` existe un único `p ∈ M` que minimiza `‖f - g‖` sobre `g ∈ M`, y ese `p`
es exactamente el que hace `f - p ⊥ M`.

Fidelidad: el libro escribe `H` un espacio de Hilbert (completo por
definición), `M` subespacio cerrado, y las dos cláusulas «`P_M f` realiza el
mínimo» y «`f - P_M f` es ortogonal a `M`». En Lean se trabaja sobre `ℝ`
(espacio de Hilbert real, que es el caso de `L²(P)` del apéndice); el mínimo
se escribe como `⨅ g : M, ‖f - g‖` sobre el subtipo `M`, y la conclusión
incluye la unicidad (`∃!`) del minimizador, que el libro afirma con «existe un
único elemento». La completitud se pide como `[CompleteSpace H]` y el
carácter cerrado como `IsClosed (M : Set H)`, tal cual el enunciado. -/
theorem appE_proyeccion (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℝ H]
    [CompleteSpace H] (M : Submodule ℝ H) (hM : IsClosed (M : Set H)) (f : H) :
    ∃! p : M, ‖f - p‖ = ⨅ g : M, ‖f - g‖ ∧ ∀ m ∈ M, ⟪f - p, m⟫_ℝ = 0 := by
  classical
  obtain ⟨v, hvM, hnorm⟩ := M.exists_norm_eq_iInf_of_complete_subspace hM.isComplete f
  have hvnorm : ‖f - v‖ = ⨅ g : M, ‖f - g‖ := by simpa using hnorm
  have hvort : ∀ m ∈ M, ⟪f - v, m⟫_ℝ = 0 :=
    (M.norm_eq_iInf_iff_inner_eq_zero hvM).1 hvnorm
  refine ⟨⟨v, hvM⟩, ⟨hvnorm, hvort⟩, ?_⟩
  rintro ⟨q, hqM⟩ ⟨hqnorm, hqort⟩
  have hmem : (q : H) - v ∈ M := Submodule.sub_mem M hqM hvM
  have hstep : ⟪(q : H) - v, (q : H) - v⟫_ℝ
      = ⟪f - v, (q : H) - v⟫_ℝ - ⟪f - q, (q : H) - v⟫_ℝ := by
    rw [show (q : H) - v = (f - v) - (f - q) from by abel, inner_sub_left]
  have hinner : ⟪(q : H) - v, (q : H) - v⟫_ℝ = 0 := by
    rw [hstep, hvort _ hmem, hqort _ hmem, sub_zero]
  have hnorm0 : ‖(q : H) - v‖ = 0 := by
    have hsq : ‖(q : H) - v‖ ^ 2 = 0 := by
      rw [← real_inner_self_eq_norm_sq, hinner]
    nlinarith [norm_nonneg ((q : H) - v)]
  exact Subtype.ext (sub_eq_zero.mp (norm_eq_zero.mp hnorm0))

/-- book: apendices/apendice_medido.typ:225 (key: thm:appE-proyeccion) —

Complemento del teorema de proyección: el punto `p` realiza efectivamente el
mínimo, es decir `‖f - P_M f‖ ≤ ‖f - g‖` para todo `g ∈ M`.

Fidelidad: el libro escribe el mínimo de forma explícita; `appE_proyeccion`
lo codifica como una igualdad con `⨅`, y este corolario recupera la
desigualdad de minimización en la forma en que se usa en las pruebas. -/
theorem appE_proyeccion_minimo (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℝ H]
    [CompleteSpace H] (M : Submodule ℝ H) (hM : IsClosed (M : Set H)) (f : H) :
    ∃ p ∈ M, (∀ g ∈ M, ‖f - p‖ ≤ ‖f - g‖) ∧ ∀ m ∈ M, ⟪f - p, m⟫_ℝ = 0 := by
  classical
  obtain ⟨v, hvM, hnorm⟩ := M.exists_norm_eq_iInf_of_complete_subspace hM.isComplete f
  have hvnorm : ‖f - v‖ = ⨅ g : M, ‖f - g‖ := by simpa using hnorm
  refine ⟨v, hvM, fun g hg => ?_, (M.norm_eq_iInf_iff_inner_eq_zero hvM).1 hvnorm⟩
  have hbdd : BddBelow (Set.range (fun g : M => ‖f - g‖)) :=
    ⟨0, by rintro _ ⟨i, rfl⟩; exact norm_nonneg _⟩
  calc ‖f - v‖ = ⨅ g : M, ‖f - g‖ := hvnorm
    _ ≤ ‖f - g‖ := ciInf_le hbdd (⟨g, hg⟩ : M)

/-- book: apendices/apendice_medido.typ:225 (key: thm:appE-proyeccion) —

Segunda cláusula del libro aislada: `p ∈ M` es un minimizador si y sólo si
`f - p ⊥ M` (caracterización variacional del proyector).

Fidelidad: es la equivalencia `norm_eq_iInf_iff_inner_eq_zero` de Mathlib
leída en la forma del libro. -/
theorem appE_proyeccion_ortogonal_iff (H : Type*) [NormedAddCommGroup H]
    [InnerProductSpace ℝ H] (M : Submodule ℝ H) (f p : H) (hp : p ∈ M) :
    ‖f - p‖ = ⨅ g : M, ‖f - g‖ ↔ ∀ m ∈ M, ⟪f - p, m⟫_ℝ = 0 :=
  M.norm_eq_iInf_iff_inner_eq_zero hp

/-! ## `ex:appE-l2` — el espacio `L²(P)` de Hilbert -/

/-- book: apendices/apendice_medido.typ:218 (key: ex:appE-l2) —

Producto interno de `L²(P)`: `⟨f, g⟩ = E_P[f g]`, es decir la integral de
`f g` respecto de `P`.

Fidelidad: el libro escribe `⟨f, g⟩ = EE_P [f g]`; en Lean `Lp ℝ 2 μ` es el
espacio de clases de funciones de cuadrado integrable módulo igualdad `μ`-casi
segura, y su producto interno es por definición la integral del producto. La
medida `μ` es una medida arbitraria sobre `α`; el libro la llama `P`. -/
theorem appE_l2_inner {α : Type*} [MeasurableSpace α] (μ : Measure α) (f g : Lp ℝ 2 μ) :
    ⟪f, g⟫_ℝ = ∫ x, f x * g x ∂μ := by
  rw [MeasureTheory.L2.inner_def]
  simp [mul_comm]

/-- book: apendices/apendice_medido.typ:218 (key: ex:appE-l2) —

Norma de `L²(P)`: `‖f‖₂ = sqrt (E_P[f²])`.

Fidelidad: el libro define `norm(f)_2 = sqrt(EE_P[f^2])`; aquí se prueba la
misma igualdad para la norma de `Lp ℝ 2 μ`, usando `‖f‖² = ⟨f, f⟩` y la
primera cláusula. -/
theorem appE_l2_norm {α : Type*} [MeasurableSpace α] (μ : Measure α) (f : Lp ℝ 2 μ) :
    ‖f‖ = Real.sqrt (∫ x, f x ^ 2 ∂μ) := by
  have hsq : ‖f‖ ^ 2 = ∫ x, f x ^ 2 ∂μ := by
    rw [← real_inner_self_eq_norm_sq, appE_l2_inner]
    congr 1
    ext x
    ring
  calc ‖f‖ = Real.sqrt (‖f‖ ^ 2) := (Real.sqrt_sq (norm_nonneg f)).symm
    _ = Real.sqrt (∫ x, f x ^ 2 ∂μ) := by rw [hsq]

/-- book: apendices/apendice_medido.typ:218 (key: ex:appE-l2) —

«`L²(P)` identifica funciones de cuadrado integrable que coinciden `P`-casi
seguramente; sus elementos son esas clases de equivalencia»: dos funciones de
cuadrado integrable definen el mismo elemento de `L²(P)` si y sólo si son
iguales `μ`-casi seguramente.

Fidelidad: el libro enuncia la identificación como prosa; aquí se formaliza
como la equivalencia exacta `toLp f = toLp g ↔ f =ᵐ[μ] g` (las dos
direcciones), que es el contenido matemático de «sus elementos son clases de
equivalencia». -/
theorem appE_l2_identifica {α : Type*} [MeasurableSpace α] (μ : Measure α) {f g : α → ℝ}
    (hf : MemLp f 2 μ) (hg : MemLp g 2 μ) :
    (MemLp.toLp f hf : Lp ℝ 2 μ) = MemLp.toLp g hg ↔ f =ᵐ[μ] g :=
  MemLp.toLp_eq_toLp_iff hf hg

/-- book: apendices/apendice_medido.typ:218 (key: ex:appE-l2) —

`L²(P)` es completo para la norma `‖·‖₂`: es un espacio de Hilbert junto con
el producto interno de `appE_l2_inner`.

Fidelidad: el libro afirma «es un espacio de Hilbert»; en Lean «Hilbert» es
`CompleteSpace` más `InnerProductSpace ℝ (Lp ℝ 2 μ)` (instancias de Mathlib),
así que se declara la completitud como afirmación y el producto interno en el
teorema anterior. No se exige `σ`-finitud: Mathlib prueba la completitud de
`Lp` para cualquier medida. -/
theorem appE_l2_hilbert {α : Type*} [MeasurableSpace α] (μ : Measure α) :
    CompleteSpace (Lp ℝ 2 μ) :=
  inferInstance

/-- book: apendices/apendice_medido.typ:218 (key: ex:appE-l2) —

Enunciado conjunto de `ex:appE-l2`: producto interno, norma, identificación
casi segura y completitud de `L²(P)`.

Fidelidad: agrupa las cuatro cláusulas que el libro enuncia en prosa; ver las
notas de fidelidad de cada componente. -/
theorem appE_l2 {α : Type*} [MeasurableSpace α] (μ : Measure α) :
    (∀ f g : Lp ℝ 2 μ, ⟪f, g⟫_ℝ = ∫ x, f x * g x ∂μ) ∧
    (∀ f : Lp ℝ 2 μ, ‖f‖ = Real.sqrt (∫ x, f x ^ 2 ∂μ)) ∧
    (∀ f g : α → ℝ, ∀ (hf : MemLp f 2 μ) (hg : MemLp g 2 μ),
      (MemLp.toLp f hf : Lp ℝ 2 μ) = MemLp.toLp g hg ↔ f =ᵐ[μ] g) ∧
    CompleteSpace (Lp ℝ 2 μ) :=
  ⟨appE_l2_inner μ, appE_l2_norm μ, fun _ _ hf hg => appE_l2_identifica μ hf hg,
    appE_l2_hilbert μ⟩

/-! ## `ex:appE-gaussiano` — modelo gaussiano dominado por Lebesgue -/

/-- book: apendices/apendice_medido.typ:163 (key: ex:appE-gaussiano) —

Densidad del modelo gaussiano: para `θ = (μ, σ²)` con `σ² > 0`, la densidad
respecto de Lebesgue en `ℝ` es
`p_θ x = 1/sqrt(2 π σ²) * exp (-(x - μ)²/(2 σ²))`.

Fidelidad: el libro escribe la densidad como fórmula explícita; en Lean es
`ProbabilityTheory.gaussianPDFReal μ v` con `v = ⟨σ², hσ.le⟩ : ℝ≥0` (Mathlib parametriza la
varianza en `ℝ≥0`), que por `ProbabilityTheory.gaussianPDFReal_def` es esa misma fórmula. El
paso `1/sqrt(...) = (sqrt ...)⁻¹` se hace explícito para que aparezca la
forma impresa en el libro. -/
theorem appE_gaussiano_densidad (μ σ2 : ℝ) (hσ : 0 < σ2) :
    ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) =
      fun x => (Real.sqrt (2 * Real.pi * σ2))⁻¹ * Real.exp (-(x - μ) ^ 2 / (2 * σ2)) := by
  funext x
  rw [ProbabilityTheory.gaussianPDFReal_def]
  simp

/-- book: apendices/apendice_medido.typ:163 (key: ex:appE-gaussiano) —

La densidad gaussiana es estrictamente positiva en todo punto cuando
`σ² > 0`.

Fidelidad: el libro presenta `p_θ` como densidad (positiva y de integral 1);
esta cláusula formaliza la positividad, que falta en el enunciado pero es lo
que hace de `p_θ` una densidad. -/
theorem appE_gaussiano_pos (μ σ2 : ℝ) (hσ : 0 < σ2) (x : ℝ) :
    0 < ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) x :=
  ProbabilityTheory.gaussianPDFReal_pos μ (NNReal.mk σ2 hσ.le) x (by
    intro h
    have h2 : ((NNReal.mk σ2 hσ.le) : ℝ) = 0 := by rw [h]; simp
    exact hσ.ne' (by simpa using h2))

/-- book: apendices/apendice_medido.typ:163 (key: ex:appE-gaussiano) —

La densidad gaussiana integra 1: `∫ p_θ = 1`, de modo que
`volume.withDensity (ProbabilityTheory.gaussianPDF μ ⟨σ², ·⟩)` es una probabilidad.

Fidelidad: el libro dice «Sea `X ~ N(μ, σ²)`», es decir, `p_θ` es una
densidad de probabilidad; se formaliza la normalización, que es su contenido
verificable. -/
theorem appE_gaussiano_integral (μ σ2 : ℝ) (hσ : 0 < σ2) :
    (∫ x, ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) x) = 1 :=
  ProbabilityTheory.integral_gaussianPDFReal_eq_one μ (by
    intro h
    have h2 : ((NNReal.mk σ2 hσ.le) : ℝ) = 0 := by rw [h]; simp
    exact hσ.ne' (by simpa using h2))

/-- book: apendices/apendice_medido.typ:163 (key: ex:appE-gaussiano) —

**Dominación**: la ley gaussiana `P_θ` de densidad `p_θ` está dominada por la
medida de Lebesgue en `ℝ`, para todo `θ = (μ, σ²)` con `σ² > 0`.

Fidelidad: el libro dice «esta familia está dominada por la medida de Lebesgue
en `ℝ`». Se formaliza como que la medida `volume.withDensity (ProbabilityTheory.gaussianPDF μ v)`
es absolutamente continua respecto de `volume` (definición de dominación:
`ν ≪ λ`), y se cuantifica sobre toda la familia `(μ, σ²)` con `σ² > 0`. -/
theorem appE_gaussiano_dominado (μ σ2 : ℝ) (hσ : 0 < σ2) :
    volume.withDensity (ProbabilityTheory.gaussianPDF μ (NNReal.mk σ2 hσ.le)) ≪ (volume : Measure ℝ) :=
  withDensity_absolutelyContinuous volume _

/-- book: apendices/apendice_medido.typ:163 (key: ex:appE-gaussiano) —

Enunciado conjunto de `ex:appE-gaussiano`: fórmula de la densidad, positividad,
normalización y dominación por Lebesgue de toda la familia.

Fidelidad: agrupa las cláusulas discutidas en las notas anteriores; la familia
se indexa por `(μ, σ²) : ℝ × ℝ` con `σ² > 0`, como `θ = (μ, σ²)` en el libro. -/
theorem appE_gaussiano :
    (∀ (μ σ2 : ℝ) (hσ : 0 < σ2), ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) =
      fun x => (Real.sqrt (2 * Real.pi * σ2))⁻¹ * Real.exp (-(x - μ) ^ 2 / (2 * σ2))) ∧
    (∀ (μ σ2 : ℝ) (hσ : 0 < σ2) (x : ℝ), 0 < ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) x) ∧
    (∀ (μ σ2 : ℝ) (hσ : 0 < σ2), (∫ x, ProbabilityTheory.gaussianPDFReal μ (NNReal.mk σ2 hσ.le) x) = 1) ∧
    (∀ (μ σ2 : ℝ) (hσ : 0 < σ2),
      volume.withDensity (ProbabilityTheory.gaussianPDF μ (NNReal.mk σ2 hσ.le)) ≪ (volume : Measure ℝ)) :=
  ⟨appE_gaussiano_densidad, appE_gaussiano_pos, appE_gaussiano_integral,
    appE_gaussiano_dominado⟩

end ApendiceEHilbert
