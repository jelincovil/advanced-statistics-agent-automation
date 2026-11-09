import Mathlib

/-!
# Book.ConvergenciaBase — capa de convergencia estocástica (infraestructura compartida)

Módulo de infraestructura del swarm `smw9820kx` (dirección d16, miembro m15).

**Qué falta en Mathlib.** `MeasureTheory.TendstoInMeasure μ f l g` es exactamente
la convergencia en probabilidad del libro (`→^P`), pero Mathlib no trae el
álgebra de esa noción: no hay `TendstoInMeasure.add`, `.mul`, `.const_mul`,
`.comp_continuous`. Cada módulo del proyecto que la necesita la reimplementa
(véase `Book/ApendiceDHac_m1.lean`, que define a mano
`tendstoInMeasure_of_abs_le` y repite las cuentas ε–δ). Ese hueco es lo que este
módulo cierra.

**Qué prueba aquí.** Los cierres que cualquier enunciado asintótico pendiente
necesita: constantes, suma, resta, opuesto, producto por constante, producto de
sucesiones que tienden a constantes (Slutsky multiplicativo), mapeo continuo
(consistencia de funcionales continuos), dominación por una sucesión
determinista y consistencia vía Chebyshev.

**Fidelidad declarada.** Todas las declaraciones son formales (sin `sorry`, sin
axiomas extra). El libro no numera estos lemas: aparecen como pasos dentro de
las demostraciones de los teoremas de cap. 4, cap. 6 y del apéndice D. Por eso
la clave de cada una lleva el prefijo `der:` (lema derivado de infraestructura)
y no reclama la clave de ningún pendiente: son el andamio que los pendientes
`thm:ch3-mle-propiedades`, `thm:ch4-umpu`, `thm:ch4-bh`, `thm:ch8-lai-robbins`,
`thm:ch9-eficiencia`, `thm:appD-*` necesitan para cerrarse sin `sorry`.
-/

open MeasureTheory Filter ProbabilityTheory
open scoped Topology ENNReal

namespace MeasureTheory

variable {Ω ι : Type*} [MeasurableSpace Ω] {μ : Measure Ω} {l : Filter ι}

namespace TendstoInMeasure

/-! ## 1. Constantes y álgebra lineal -/

/-- book: capitulos/cap04_herramientas.typ:1718 (key: der:convprob-const) —
una sucesión constante converge en probabilidad a su valor. Fidelidad: formal;
el libro lo usa implícitamente al escribir `X̄*_n - X̄_n` (el bootstrap no
desplaza en probabilidad), cap04_herramientas.typ:1718. -/
lemma const {c : Ω → ℝ} : TendstoInMeasure μ (fun _ : ι => c) l c := by
  rw [tendstoInMeasure_iff_norm]
  intro ε hε
  have hzero : ∀ i : ι, μ {x : Ω | ε ≤ ‖(fun _ : ι => c) i x - c x‖} = 0 := by
    intro i
    have hempty : {x : Ω | ε ≤ ‖(fun _ : ι => c) i x - c x‖} = ∅ := by
      ext x
      simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false, not_le]
      simpa using hε
    rw [hempty, measure_empty]
  have hfun : (fun i : ι => μ {x : Ω | ε ≤ ‖(fun _ : ι => c) i x - c x‖}) = fun _ => 0 :=
    funext hzero
  rw [hfun]
  exact tendsto_const_nhds

/-- book: capitulos/cap04_herramientas.typ:1079 (key: der:convprob-add) —
la suma de dos sucesiones que convergen en probabilidad converge en
probabilidad a la suma de los límites. Fidelidad: formal; es el paso que el
libro escribe como «el numerador y el denominador convergen» antes de invocar
a Slutsky (cap04_herramientas.typ:1079). -/
lemma add {f₁ f₂ : ι → Ω → ℝ} {g₁ g₂ : Ω → ℝ}
    (h₁ : TendstoInMeasure μ f₁ l g₁) (h₂ : TendstoInMeasure μ f₂ l g₂) :
    TendstoInMeasure μ (fun i ω => f₁ i ω + f₂ i ω) l (fun ω => g₁ ω + g₂ ω) := by
  rw [tendstoInMeasure_iff_norm] at h₁ h₂ ⊢
  intro ε hε
  have hε2 : (0 : ℝ) < ε / 2 := by linarith
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le (g := fun _ => (0 : ℝ≥0∞))
    (h := fun i => μ {x : Ω | ε / 2 ≤ ‖f₁ i x - g₁ x‖}
      + μ {x : Ω | ε / 2 ≤ ‖f₂ i x - g₂ x‖}) tendsto_const_nhds ?_
    (fun i => bot_le) ?_
  · simpa using (h₁ (ε / 2) hε2).add (h₂ (ε / 2) hε2)
  · intro i
    refine (measure_mono ?_).trans (measure_union_le _ _)
    intro x hx
    simp only [Set.mem_ofPred_eq] at hx ⊢
    by_contra H
    simp only [Set.mem_union, Set.mem_ofPred_eq, not_or, not_le] at H
    obtain ⟨H1, H2⟩ := H
    have hsplit : (f₁ i x + f₂ i x) - (g₁ x + g₂ x)
        = (f₁ i x - g₁ x) + (f₂ i x - g₂ x) := by ring
    have hineq : ‖(f₁ i x + f₂ i x) - (g₁ x + g₂ x)‖
        ≤ ‖f₁ i x - g₁ x‖ + ‖f₂ i x - g₂ x‖ := by
      rw [hsplit]
      exact norm_add_le _ _
    linarith

/-- book: capitulos/cap04_herramientas.typ:1079 (key: der:convprob-neg) —
el opuesto de una sucesión convergente en probabilidad converge al opuesto.
Fidelidad: formal; lema de cierre de `der:convprob-sub`. -/
lemma neg {f : ι → Ω → ℝ} {g : Ω → ℝ} (h : TendstoInMeasure μ f l g) :
    TendstoInMeasure μ (fun i ω => -f i ω) l (fun ω => -g ω) := by
  rw [tendstoInMeasure_iff_norm] at h ⊢
  intro ε hε
  have h' := h ε hε
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le (g := fun _ => (0 : ℝ≥0∞))
    (h := fun i => μ {x : Ω | ε ≤ ‖f i x - g x‖}) tendsto_const_nhds h'
    (fun i => bot_le) ?_
  intro i
  apply measure_mono
  intro x hx
  simp only [Set.mem_ofPred_eq] at hx ⊢
  have hkey : ‖-f i x - -g x‖ = ‖f i x - g x‖ := by
    rw [show -f i x - -g x = -(f i x - g x) by ring, norm_neg]
  rwa [hkey] at hx

/-- book: capitulos/cap04_herramientas.typ:1079 (key: der:convprob-sub) —
la diferencia converge a la diferencia de los límites. Fidelidad: formal. -/
lemma sub {f₁ f₂ : ι → Ω → ℝ} {g₁ g₂ : Ω → ℝ}
    (h₁ : TendstoInMeasure μ f₁ l g₁) (h₂ : TendstoInMeasure μ f₂ l g₂) :
    TendstoInMeasure μ (fun i ω => f₁ i ω - f₂ i ω) l (fun ω => g₁ ω - g₂ ω) := by
  have h := h₁.add h₂.neg
  simpa [sub_eq_add_neg] using h

/-- book: capitulos/cap04_herramientas.typ:1551 (key: der:convprob-const-mul) —
el producto por una constante preserva la convergencia en probabilidad.
Fidelidad: formal; es la mitad multiplicativa de Slutsky que el libro usa en
cap04_herramientas.typ:1551-1562. -/
lemma const_mul (c : ℝ) {f : ι → Ω → ℝ} {g : Ω → ℝ} (h : TendstoInMeasure μ f l g) :
    TendstoInMeasure μ (fun i ω => c * f i ω) l (fun ω => c * g ω) := by
  rw [tendstoInMeasure_iff_norm] at h ⊢
  intro ε hε
  rcases eq_or_ne c 0 with hc | hc
  · subst hc
    have hzero : ∀ i : ι, μ {x : Ω | ε ≤ ‖(0 : ℝ) * f i x - 0 * g x‖} = 0 := by
      intro i
      have hempty : {x : Ω | ε ≤ ‖(0 : ℝ) * f i x - 0 * g x‖} = ∅ := by
        ext x
        simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false, not_le]
        simpa using hε
      rw [hempty, measure_empty]
    have hfun : (fun i : ι => μ {x : Ω | ε ≤ ‖(0 : ℝ) * f i x - 0 * g x‖}) = fun _ => 0 :=
      funext hzero
    rw [hfun]
    exact tendsto_const_nhds
  · have hcabs : (0 : ℝ) < |c| := abs_pos.mpr hc
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le (g := fun _ => (0 : ℝ≥0∞))
      (h := fun i => μ {x : Ω | ε / |c| ≤ ‖f i x - g x‖}) tendsto_const_nhds
      (h (ε / |c|) (div_pos hε hcabs)) (fun i => bot_le) ?_
    intro i
    apply measure_mono
    intro x hx
    simp only [Set.mem_ofPred_eq] at hx ⊢
    have hnorm : ‖c * f i x - c * g x‖ = |c| * ‖f i x - g x‖ := by
      rw [← mul_sub, norm_mul, Real.norm_eq_abs]
    rw [hnorm] at hx
    rw [div_le_iff₀ hcabs]
    simpa [mul_comm] using hx

/-! ## 2. Productos -/

/-- book: capitulos/cap04_herramientas.typ:1079 (key: der:convprob-mul-zero) —
el producto de dos sucesiones que convergen en probabilidad a `0` converge en
probabilidad a `0`. Fidelidad: formal; es el paso «los dos errores son
`o_P(1)`, luego su producto también» que el libro usa al apilar estimadores
(cap10_casos.typ:110, plug-in de valor). -/
lemma mul_zero {f₁ f₂ : ι → Ω → ℝ}
    (h₁ : TendstoInMeasure μ f₁ l (fun _ => 0))
    (h₂ : TendstoInMeasure μ f₂ l (fun _ => 0)) :
    TendstoInMeasure μ (fun i ω => f₁ i ω * f₂ i ω) l (fun _ => 0) := by
  rw [tendstoInMeasure_iff_norm] at h₁ h₂ ⊢
  intro ε hε
  have hsq : (0 : ℝ) < Real.sqrt ε := Real.sqrt_pos.mpr hε
  have hsqsq : Real.sqrt ε * Real.sqrt ε = ε := Real.mul_self_sqrt hε.le
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le (g := fun _ => (0 : ℝ≥0∞))
    (h := fun i => μ {x : Ω | Real.sqrt ε ≤ ‖f₁ i x‖}
      + μ {x : Ω | Real.sqrt ε ≤ ‖f₂ i x‖}) tendsto_const_nhds ?_
    (fun i => bot_le) ?_
  · simpa using (h₁ (Real.sqrt ε) hsq).add (h₂ (Real.sqrt ε) hsq)
  · intro i
    refine (measure_mono ?_).trans (measure_union_le _ _)
    intro x hx
    simp only [Set.mem_ofPred_eq] at hx ⊢
    by_contra H
    simp only [Set.mem_union, Set.mem_ofPred_eq, not_or, not_le] at H
    obtain ⟨H1, H2⟩ := H
    have hb1 : (0 : ℝ) ≤ ‖f₁ i x‖ := norm_nonneg _
    have hb2 : (0 : ℝ) ≤ ‖f₂ i x‖ := norm_nonneg _
    have hstep : ‖f₁ i x‖ * ‖f₂ i x‖ < Real.sqrt ε * Real.sqrt ε := by
      nlinarith [H1, H2, hb1, hb2]
    rw [sub_zero, norm_mul] at hx
    linarith

/-- book: capitulos/cap04_herramientas.typ:1079 (key: der:convprob-mul) —
**Slutsky multiplicativo**: si `X_n ->^P a` y `Y_n ->^P b` con `a b`
constantes, entonces `X_n Y_n ->^P a b`. Fidelidad: formal, para límites
constantes (que es el uso del libro: cap04_herramientas.typ:1079,
1551-1562 y apendice_demostraciones.typ:485). -/
lemma mul_const {f₁ f₂ : ι → Ω → ℝ} {a b : ℝ}
    (h₁ : TendstoInMeasure μ f₁ l (fun _ => a))
    (h₂ : TendstoInMeasure μ f₂ l (fun _ => b)) :
    TendstoInMeasure μ (fun i ω => f₁ i ω * f₂ i ω) l (fun _ => a * b) := by
  have hX : TendstoInMeasure μ (fun i ω => f₁ i ω - a) l (fun _ => 0) := by
    simpa using h₁.sub (const (μ := μ) (l := l) (c := fun _ => a))
  have hY : TendstoInMeasure μ (fun i ω => f₂ i ω - b) l (fun _ => 0) := by
    simpa using h₂.sub (const (μ := μ) (l := l) (c := fun _ => b))
  have hXY : TendstoInMeasure μ (fun i ω => (f₁ i ω - a) * (f₂ i ω - b)) l (fun _ => 0) :=
    mul_zero hX hY
  have hA : TendstoInMeasure μ (fun i ω => a * (f₂ i ω - b)) l (fun _ => 0) := by
    simpa using hY.const_mul a
  have hB : TendstoInMeasure μ (fun i ω => b * (f₁ i ω - a)) l (fun _ => 0) := by
    simpa using hX.const_mul b
  have hsum : TendstoInMeasure μ
      (fun i ω => (f₁ i ω - a) * (f₂ i ω - b) + a * (f₂ i ω - b) + b * (f₁ i ω - a))
      l (fun _ => 0) := by
    have h := hXY.add (hA.add hB)
    simpa [add_assoc] using h
  have hgoal : (fun i ω => (f₁ i ω - a) * (f₂ i ω - b) + a * (f₂ i ω - b)
        + b * (f₁ i ω - a)) = fun i ω => f₁ i ω * f₂ i ω - a * b := by
    funext i ω
    ring
  rw [hgoal] at hsum
  rw [tendstoInMeasure_iff_norm] at hsum ⊢
  intro ε hε
  simpa using hsum ε hε

/-! ## 3. Mapeo continuo y consistencia de funcionales -/

/-- book: capitulos/cap04_herramientas.typ:1667 (key: der:convprob-continuous) —
**mapeo continuo**: si `X_n ->^P a` y `φ` es continua en `a`, entonces
`φ(X_n) ->^P φ(a)`. Fidelidad: formal; es el argumento «cualquier funcional
continuo del proceso» que el libro invoca en cap04_herramientas.typ:1667 y la
consistencia plug-in de cap10_casos.typ:110. -/
theorem comp_continuous {f : ι → Ω → ℝ} {a : ℝ}
    (hf : TendstoInMeasure μ f l (fun _ => a)) {φ : ℝ → ℝ} (hφ : ContinuousAt φ a) :
    TendstoInMeasure μ (fun i ω => φ (f i ω)) l (fun _ => φ a) := by
  rw [tendstoInMeasure_iff_norm] at hf ⊢
  intro ε hε
  obtain ⟨δ, hδ, hδε⟩ := Metric.continuousAt_iff.mp hφ ε hε
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le (g := fun _ => (0 : ℝ≥0∞))
    (h := fun i => μ {x : Ω | δ ≤ ‖f i x - a‖}) tendsto_const_nhds (hf δ hδ)
    (fun i => bot_le) ?_
  intro i
  apply measure_mono
  intro x hx
  simp only [Set.mem_ofPred_eq] at hx ⊢
  by_contra H
  simp only [not_le] at H
  have h1 : dist (f i x) a < δ := by
    rw [Real.dist_eq]
    rwa [Real.norm_eq_abs] at H
  have h2 : dist (φ (f i x)) (φ a) < ε := hδε h1
  rw [Real.dist_eq] at h2
  rw [Real.norm_eq_abs] at hx
  linarith

/-- book: capitulos/cap09_verificacion.typ (key: der:convprob-plug-in) —
**consistencia plug-in**: un funcional continuo de un estimador consistente es
consistente. Fidelidad: formal; es la forma que el libro usa para pasar de
`hat(theta) ->^P theta_0` a `g(hat(theta)) ->^P g(theta_0)` en las varianzas e
informaciones (cap04_herramientas.typ:1551). -/
theorem consistencia_plug_in {f : ι → Ω → ℝ} {θ : ℝ}
    (hf : TendstoInMeasure μ f l (fun _ => θ)) {g : ℝ → ℝ} (hg : ContinuousAt g θ) :
    TendstoInMeasure μ (fun i ω => g (f i ω)) l (fun _ => g θ) :=
  comp_continuous hf hg

/-! ## 4. Dominación por una sucesión determinista -/

/-- book: capitulos/cap08_intervalos.typ (key: der:convprob-abs-le) —
si `|f_n| ≤ g_n` con `g_n -> 0` determinista, entonces `f_n ->^P 0`.
Fidelidad: formal; es el lema que `Book/ApendiceDHac_m1.lean` tenía que
reimplementar a mano para cerrar `thm:appD-hac-consistencia`. -/
lemma of_abs_le {f : ι → Ω → ℝ} {g : ι → ℝ}
    (hg : Tendsto g l (𝓝 0)) (hg0 : ∀ i, 0 ≤ g i)
    (h : ∀ᶠ i in l, ∀ ω, |f i ω| ≤ g i) :
    TendstoInMeasure μ f l (fun _ => 0) := by
  rw [tendstoInMeasure_iff_norm]
  intro ε hε
  have hev : ∀ᶠ i in l, ‖g i‖ < ε := by
    have h' := hg.eventually (eventually_lt_nhds hε)
    filter_upwards [h'] with i hi
    simpa [Real.norm_eq_abs, abs_of_nonneg (hg0 i)] using hi
  have heq : (fun _ : ι => (0 : ℝ≥0∞)) =ᶠ[l]
      (fun i => μ {x : Ω | ε ≤ ‖f i x - (0 : ℝ)‖}) := by
    filter_upwards [hev, h] with i hi hile
    have hempty : {x : Ω | ε ≤ ‖f i x - (0 : ℝ)‖} = ∅ := by
      ext x
      simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false, not_le]
      calc ‖f i x - 0‖ = |f i x| := by rw [sub_zero, Real.norm_eq_abs]
        _ ≤ g i := hile x
        _ = ‖g i‖ := by rw [Real.norm_eq_abs, abs_of_nonneg (hg0 i)]
        _ < ε := hi
    rw [hempty, measure_empty]
  exact Tendsto.congr' heq tendsto_const_nhds

/-! ## 5. Consistencia por Chebyshev -/

/-- book: apendices/apendice_demostraciones.typ:547 (key: der:convprob-chebyshev) —
**consistencia por Chebyshev**: si los estimadores tienen segundo momento
finito, su esperanza tiende al parámetro y su varianza tiende a cero, entonces
convergen en probabilidad al parámetro. Fidelidad: formal; es exactamente la
forma en que el libro usa «Chebyshev condicional» para producir `o_P(1)`
(apendice_demostraciones.typ:547). -/
theorem consistencia_chebyshev [IsFiniteMeasure μ]
    {X : ι → Ω → ℝ} {m : ι → ℝ} {θ : ℝ}
    (hL2 : ∀ i, MemLp (X i) 2 μ)
    (hmean : ∀ i, ∫ x, X i x ∂μ = m i)
    (hmtend : Tendsto m l (𝓝 θ))
    (hvar : Tendsto (fun i => variance (X i) μ) l (𝓝 0)) :
    TendstoInMeasure μ X l (fun _ => θ) := by
  rw [tendstoInMeasure_iff_norm]
  intro ε hε
  have hε2 : (0 : ℝ) < ε / 2 := by linarith
  have hvar' : Tendsto (fun i => ENNReal.ofReal (variance (X i) μ / (ε / 2) ^ 2))
      l (𝓝 0) := by
    have h1 : Tendsto (fun i => variance (X i) μ / (ε / 2) ^ 2) l (𝓝 0) := by
      simpa using hvar.div_const ((ε / 2) ^ 2)
    simpa using ENNReal.tendsto_ofReal h1
  have hsub : Tendsto (fun i => |m i - θ|) l (𝓝 0) := by
    have h' := (hmtend.sub_const θ).abs
    simpa using h'
  have hmev : ∀ᶠ i in l, |m i - θ| < ε / 2 :=
    hsub.eventually (eventually_lt_nhds hε2)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' (g := fun _ => (0 : ℝ≥0∞))
    (h := fun i => ENNReal.ofReal (variance (X i) μ / (ε / 2) ^ 2))
    tendsto_const_nhds hvar' (Eventually.of_forall fun i => bot_le) ?_
  filter_upwards [hmev] with i hi
  calc μ {x : Ω | ε ≤ ‖X i x - θ‖}
      ≤ μ {x : Ω | ε / 2 ≤ ‖X i x - ∫ y, X i y ∂μ‖} := by
        apply measure_mono
        intro x hx
        simp only [Set.mem_ofPred_eq] at hx ⊢
        by_contra H
        simp only [not_le] at H
        rw [Real.norm_eq_abs] at hx H
        have hmean' : |(∫ y, X i y ∂μ) - θ| < ε / 2 := by
          rw [hmean i]
          exact hi
        have htri : |X i x - θ| ≤ |X i x - ∫ y, X i y ∂μ| + |(∫ y, X i y ∂μ) - θ| := by
          have heq : X i x - θ = (X i x - ∫ y, X i y ∂μ) + ((∫ y, X i y ∂μ) - θ) := by
            ring
          rw [heq]
          exact abs_add_le _ _
        linarith
    _ ≤ ENNReal.ofReal (variance (X i) μ / (ε / 2) ^ 2) := by
        have hcheb := meas_ge_le_variance_div_sq (μ := μ) (X := X i) (hL2 i) hε2
        simpa [Real.norm_eq_abs] using hcheb

end TendstoInMeasure

end MeasureTheory
