import Mathlib
import Book.Cap05Asintotica

/-!
# Book.Ch5StudentizadoM6 — intervalo normal studentizado condicional

book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes)
book: capitulos/cap08_intervalos.typ:180 (key: thm:ch11-clt-mixing)

Pieza auxiliar para las claves `thm:ch5-clt-agentes` (`capitulos/cap06_fallos.typ:324`)
y `thm:ch11-clt-mixing` (`capitulos/cap08_intervalos.typ:180`): la *última*
cláusula de ambos bloques, «si además `σ²_LR > 0` y `σ̂²_LR →P σ²_LR`, un
intervalo asintótico es `X̄_T ± z σ̂_LR/√T`», no es el CLT de mezcla (externo,
atribuido a Ibragimov) sino una composición de Slutsky.

Este módulo demuestra esa composición con las primitivas de Mathlib 4.35:

* `tendstoInMeasure_of_continuousAt`: una función continua en el límite
  transporta la convergencia en probabilidad;
* `tendstoInMeasure_inv`: el recíproco `σ̂⁻¹ →P σ⁻¹` cuando `σ ≠ 0`;
* `tendstoInDistribution_div_of_tendstoInMeasure_const`: **Slutsky** para el
  cociente: si `Xₙ →d Z` y `σ̂ₙ →P σ ≠ 0`, entonces `Xₙ/σ̂ₙ →d Z/σ`;
* `studentized_tendsto_gaussianReal`: si además `Z ~ N(0,σ²)`, el estadístico
  studentizado converge a `N(0,1)`;
* `studentized_interval_coverage`: la probabilidad de cobertura del intervalo
  studentizado converge a `N(0,1)([-z,z])`, y
  `book_interval_coverage` es la misma afirmación escrita en la forma del
  libro, `X̄ ± z σ̂/√T`;
* `studentized_tendsto_gaussianReal_sq` y `book_interval_coverage_sq`: las
  mismas dos afirmaciones con la hipótesis literal del libro, `σ̂² →P σ²`;
* `ch5_clt_studentized`: instanciación con el CLT iid de Mathlib
  (`tendstoInDistribution_inv_sqrt_mul_sum_sub`), sin `[Fintype Ω]`, que
  exhibe un ámbito donde la premisa central se satisface;
* `ch5_clt_studentized_book`: la misma conclusión a partir del target del libro
  ya registrado `BookCap05.ch5_clt` (ámbito finito de ese target);
* `ch5_clt_iid_intervalo`: en el caso iid, cobertura de punta a punta del
  intervalo `X̄_n ± z σ̂_n/√n`, sin premisa distribucional pendiente.

## Fidelidad declarada

La convergencia distribucional central `√T(X̄_T − μ) →d N(0, σ²_LR)` **no** se
demuestra aquí: entra como hipótesis explícita
(`TendstoInDistribution X atTop id (fun _ => P) (gaussianReal 0 v)` con
`(v : ℝ) = σ²`). En particular, para la contribución estacionaria de
`C.thm:ch5-clt-agentes` la premisa sigue siendo el CLT de mezcla de Ibragimov y
su estado no cambia; lo que este módulo cierra es la cláusula del intervalo,
condicional a esa premisa. La consistencia entra en las dos formas del libro:
`σ̂² →P σ²` (`studentized_tendsto_gaussianReal_sq`, `book_interval_coverage_sq`,
donde `σ̂ = √(σ̂²)` por continuidad de `√·` en `σ > 0`) y `σ̂ →P σ`.

## Relación con `Book.Ch5CltAgentesM5`

`BookCh5CltAgentesM5.lr_semiancho` prueba que `z σ̂/√T → 0` con `σ̂` acotado;
eso es sólo el estrechamiento del semiancho. Aquí se prueba la cobertura
asintótica, que es la afirmación estadística del bloque, y `lrVariance` sigue
siendo la constante de la ley límite.
-/

set_option linter.style.haveILetI false

open MeasureTheory ProbabilityTheory Filter
open scoped Topology ENNReal NNReal

namespace Ch5StudentizadoM6

/-! ### 0. Transporte de la convergencia en probabilidad por funciones continuas -/

/-- Una función continua en el punto límite transporta convergencia en
probabilidad. Versión para sucesiones de variables reales indexadas por `ℕ`. -/
theorem tendstoInMeasure_of_continuousAt {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω}
    {s : ℕ → Ω → ℝ} {σ : ℝ} {g : ℝ → ℝ} (hg : ContinuousAt g σ)
    (hs : TendstoInMeasure P s atTop (fun _ => σ)) :
    TendstoInMeasure P (fun n ω => g (s n ω)) atTop (fun _ => g σ) := by
  rw [tendstoInMeasure_iff_dist] at hs ⊢
  intro ε hε
  obtain ⟨δ, hδpos, hδ⟩ := Metric.continuousAt_iff.mp hg ε hε
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds (hs δ hδpos)
    (fun n => zero_le) (fun n => ?_)
  exact measure_mono fun ω hω => by
    simp only [Real.dist_eq] at hω ⊢
    by_contra hcon
    exact absurd (hδ (by simpa [Real.dist_eq] using not_le.mp hcon)) (not_lt.mpr hω)

/-- El recíproco transporta convergencia en probabilidad a una constante no nula. -/
theorem tendstoInMeasure_inv {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω}
    {s : ℕ → Ω → ℝ} {σ : ℝ} (hσ : σ ≠ 0)
    (hs : TendstoInMeasure P s atTop (fun _ => σ)) :
    TendstoInMeasure P (fun n ω => (s n ω)⁻¹) atTop (fun _ => σ⁻¹) :=
  tendstoInMeasure_of_continuousAt (continuousAt_inv₀ hσ) hs

/-! ### 1. Slutsky para el cociente -/

/-- **Slutsky (cociente).** Si `Xₙ →d Z` y `σ̂ₙ →P σ` con `σ ≠ 0`, entonces
`Xₙ/σ̂ₙ →d Z/σ`. -/
theorem tendstoInDistribution_div_of_tendstoInMeasure_const
    {Ω Ω' : Type*} {mΩ : MeasurableSpace Ω} {mΩ' : MeasurableSpace Ω'}
    {P : Measure Ω} [IsProbabilityMeasure P] {P' : Measure Ω'} [IsProbabilityMeasure P']
    {X : ℕ → Ω → ℝ} {Z : Ω' → ℝ} {s : ℕ → Ω → ℝ} {σ : ℝ}
    (hX : TendstoInDistribution X atTop Z (fun _ => P) P')
    (hs : TendstoInMeasure P s atTop (fun _ => σ)) (hσ : σ ≠ 0)
    (hsm : ∀ n, AEMeasurable (s n) P) :
    TendstoInDistribution (fun n ω => X n ω / s n ω) atTop (fun ω => Z ω / σ)
      (fun _ => P) P' := by
  have hinv : TendstoInMeasure P (fun n ω => (s n ω)⁻¹) atTop (fun _ => σ⁻¹) :=
    tendstoInMeasure_inv hσ hs
  have hinvm : ∀ n, AEMeasurable (fun ω => (s n ω)⁻¹) P := fun n => (hsm n).inv
  have hpair := hX.continuous_comp_prodMk_of_tendstoInMeasure_const
    (g := fun p : ℝ × ℝ => p.1 * p.2) (by fun_prop)
    (Y := fun n ω => (s n ω)⁻¹) (c := σ⁻¹) hinv hinvm
  simpa only [div_eq_mul_inv, Function.comp_def] using hpair

/-! ### 2. El estadístico studentizado converge a `N(0,1)` -/

/-- **Studentización de un CLT central.** Si `Xₙ →d N(0,σ²)` (escrito como
`TendstoInDistribution X atTop id (fun _ => P) (gaussianReal 0 v)` con
`(v : ℝ) = σ²`) y `σ̂ₙ →P σ` con `σ > 0`, entonces `Xₙ/σ̂ₙ →d N(0,1)`.

La convergencia distribucional central es **hipótesis**: para la contribución
estacionaria del libro es el CLT de mezcla de Ibragimov, que el proyecto no
demuestra. Lo que se demuestra aquí es la composición de Slutsky que convierte
esa premisa en el pivote studentizado. -/
theorem studentized_tendsto_gaussianReal
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {X s : ℕ → Ω → ℝ} {σ : ℝ} {v : ℝ≥0}
    (hX : TendstoInDistribution X atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 v))
    (hv : (v : ℝ) = σ ^ 2) (hσ : 0 < σ)
    (hs : TendstoInMeasure P s atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (s n) P) :
    TendstoInDistribution (fun n ω => X n ω / s n ω) atTop (id : ℝ → ℝ) (fun _ => P)
      (gaussianReal 0 1) := by
  have hdiv := tendstoInDistribution_div_of_tendstoInMeasure_const hX hs hσ.ne' hsm
  have hmap : (gaussianReal 0 v).map (fun x : ℝ => x / σ) = gaussianReal 0 1 := by
    have hv' : v = NNReal.mk (σ ^ 2) (sq_nonneg σ) := by
      apply NNReal.coe_inj.mp
      simpa using hv
    subst hv'
    rw [gaussianReal_map_div_const]
    have h1 : (0 : ℝ) / σ = 0 := by simp
    rw [h1]
    have hne : NNReal.mk (σ ^ 2) (sq_nonneg σ) ≠ 0 :=
      NNReal.coe_ne_zero.mp (by simpa using pow_ne_zero 2 hσ.ne')
    have h2 : NNReal.mk (σ ^ 2) (sq_nonneg σ) / NNReal.mk (σ ^ 2) (sq_nonneg σ) = 1 :=
      div_self hne
    rw [h2]
  refine ⟨fun n => (hX.forall_aemeasurable n).div (hsm n), by fun_prop, ?_⟩
  simpa [hmap, Measure.map_id, Function.comp_def] using hdiv.tendsto

/-! ### 3. Cobertura asintótica del intervalo studentizado -/

/-- **Cobertura del intervalo studentizado.** Si `Yₙ →d N(0,1)`, entonces
`P(|Yₙ| ≤ z) → N(0,1)([-z,z])`. Vale para todo `z : ℝ` (con `z < 0` ambos
lados son `0`; el caso interesante es `z ≥ 0`). Es el paso de convergencia
distribucional a cobertura, vía el teorema de Portmanteau (conjuntos con
frontera nula) porque `N(0,1)` no tiene átomos. -/
theorem studentized_interval_coverage
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {Y : ℕ → Ω → ℝ} {z : ℝ}
    (hY : TendstoInDistribution Y atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 1)) :
    Tendsto (fun n => P.real {ω | |Y n ω| ≤ z}) atTop
      (𝓝 ((gaussianReal 0 1).real {x | |x| ≤ z})) := by
  haveI hns : NullSingletonClass (gaussianReal (0 : ℝ) 1) :=
    nullSingletonClass_gaussianReal (by norm_num)
  -- la frontera de `{x | |x| ≤ z}` está contenida en `{z, -z}`, que es nula
  have hfr : (gaussianReal (0 : ℝ) 1) (frontier {x : ℝ | |x| ≤ z}) = 0 := by
    refine measure_mono_null (t := {z, -z}) ?_ ?_
    · intro x hx
      have hset : {x : ℝ | |x| ≤ z} = Set.Icc (-z) z := by
        ext y; simp [abs_le]
      have h1 : x ∈ closure (Set.Icc (-z) z) := by
        rw [← hset]; exact hx.1
      have h2 : x ∉ interior (Set.Icc (-z) z) := by
        rw [← hset]; exact hx.2
      rw [closure_Icc] at h1
      rw [interior_Icc] at h2
      simp only [Set.mem_Icc] at h1
      simp only [Set.mem_Ioo, not_and, not_lt] at h2
      rcases eq_or_lt_of_le h1.1 with heq | hlt
      · exact Or.inr heq.symm
      · exact Or.inl (le_antisymm h1.2 (h2 hlt))
    · exact measure_union_null (measure_singleton z) (measure_singleton (-z))
  have hE : Tendsto (fun n => (P.map (Y n)) {x : ℝ | |x| ≤ z}) atTop
      (𝓝 ((gaussianReal (0 : ℝ) 1) {x : ℝ | |x| ≤ z})) := by
    have h := ProbabilityMeasure.tendsto_measure_of_null_frontier_of_tendsto' hY.tendsto
      (by simpa [Measure.map_id] using hfr)
    simpa [Measure.map_id] using h
  have hreal : Tendsto (fun n => (P.map (Y n)).real {x : ℝ | |x| ≤ z}) atTop
      (𝓝 ((gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z})) := by
    have h := (ENNReal.tendsto_toReal (measure_ne_top (gaussianReal (0 : ℝ) 1) _)).comp hE
    simpa [Function.comp_def, measureReal_def] using h
  have hcongr : ∀ n, P.real {ω | |Y n ω| ≤ z} = (P.map (Y n)).real {x : ℝ | |x| ≤ z} := by
    intro n
    rw [map_measureReal_apply_of_aemeasurable (hY.forall_aemeasurable n) (by measurability)]
    rfl
  simpa only [hcongr] using hreal

/-! ### 4. Comparación de eventos con una diferencia de probabilidad despreciable -/

/-- Si dos sucesiones de eventos se contienen mutuamente salvo un evento `Cₙ`
cuya probabilidad tiende a `0`, entonces las probabilidades de `Aₙ` y `Bₙ`
tienen el mismo límite. -/
theorem tendsto_measureReal_of_eventually_subset_union
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {A B C : ℕ → Set Ω} {c : ℝ}
    (hAC : ∀ᶠ n in atTop, A n ⊆ B n ∪ C n)
    (hBC : ∀ᶠ n in atTop, B n ⊆ A n ∪ C n)
    (hC : Tendsto (fun n => P.real (C n)) atTop (𝓝 0))
    (hB : Tendsto (fun n => P.real (B n)) atTop (𝓝 c)) :
    Tendsto (fun n => P.real (A n)) atTop (𝓝 c) := by
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' (g := fun n => P.real (B n) - P.real (C n))
    (h := fun n => P.real (B n) + P.real (C n)) ?_ ?_ ?_ ?_
  · simpa using hB.sub hC
  · simpa using hB.add hC
  · filter_upwards [hBC] with n hn
    have h1 : P.real (B n) ≤ P.real (A n ∪ C n) := measureReal_mono hn
    have h2 : P.real (A n ∪ C n) ≤ P.real (A n) + P.real (C n) := measureReal_union_le _ _
    linarith
  · filter_upwards [hAC] with n hn
    have h1 : P.real (A n) ≤ P.real (B n ∪ C n) := measureReal_mono hn
    have h2 : P.real (B n ∪ C n) ≤ P.real (B n) + P.real (C n) := measureReal_union_le _ _
    linarith

/-- Identidad de eventos del intervalo: para `n ≥ 1` y `σ̂ > 0`,
`|X̄ − μ| ≤ z σ̂/√n ↔ |√n (X̄ − μ)/σ̂| ≤ z`. -/
theorem abs_le_iff_sqrt_mul_div {a s z : ℝ} {n : ℕ} (hn : 0 < n) (hs : 0 < s) :
    (|a| ≤ z * s / Real.sqrt n ↔ |Real.sqrt n * a / s| ≤ z) := by
  have hr : 0 < Real.sqrt n := Real.sqrt_pos.mpr (by exact_mod_cast hn)
  have hdiv : |Real.sqrt n * a / s| = Real.sqrt n * |a| / s := by
    rw [abs_div, abs_of_pos hs, abs_mul, abs_of_pos hr]
  rw [hdiv, le_div_iff₀ hr, div_le_iff₀ hs, mul_comm |a| (Real.sqrt n)]

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**Validez asintótica del intervalo del libro `X̄_T ± z σ̂_T/√T`.**
Si el estadístico studentizado `√T(X̄_T − μ)/σ̂_T` converge a `N(0,1)` y
`σ̂_T →P σ` con `σ > 0`, la probabilidad de cobertura del intervalo del libro
converge a `N(0,1)([-z,z])`.

Fidelidad declarada: la convergencia del estadístico studentizado es
hipótesis; el paso que aquí se demuestra es la equivalencia de eventos del
intervalo (con `σ̂_T > 0`, y `σ̂_T ≤ 0` es un evento de probabilidad → 0 por la
consistencia) y el paso de convergencia distribucional a cobertura. -/
theorem book_interval_coverage
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {Xbar : ℕ → Ω → ℝ} {μ σ z : ℝ} {shat : ℕ → Ω → ℝ}
    (hσ : 0 < σ)
    (hstud : TendstoInDistribution
      (fun (n : ℕ) ω => Real.sqrt (n : ℝ) * (Xbar n ω - μ) / shat n ω) atTop (id : ℝ → ℝ)
      (fun _ => P) (gaussianReal 0 1))
    (hs : TendstoInMeasure P shat atTop (fun _ => σ)) :
    Tendsto (fun (n : ℕ) => P.real {ω | |Xbar n ω - μ| ≤ z * shat n ω / Real.sqrt (n : ℝ)}) atTop
      (𝓝 ((gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z})) := by
  -- (1) cobertura del estadístico studentizado
  have hB := studentized_interval_coverage
    (Y := fun (n : ℕ) ω => Real.sqrt (n : ℝ) * (Xbar n ω - μ) / shat n ω) (z := z) hstud
  -- (2) el evento `σ̂ ≤ 0` tiene probabilidad tendiente a 0
  have hsdist : Tendsto (fun n => P.real {ω | σ ≤ dist (shat n ω) σ}) atTop (𝓝 0) :=
    (tendstoInMeasure_iff_measureReal_dist.mp hs) σ hσ
  have hC : Tendsto (fun n => P.real {ω | shat n ω ≤ 0}) atTop (𝓝 0) := by
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hsdist
      (fun n => measureReal_nonneg) (fun n => measureReal_mono ?_)
    intro ω hω
    simp only [Set.mem_ofPred_eq] at hω ⊢
    have h1 : shat n ω - σ ≤ 0 := by linarith
    rw [Real.dist_eq, abs_of_nonpos h1]
    linarith
  -- (3) comparación de los dos eventos
  have hAC : ∀ᶠ (n : ℕ) in atTop,
      {ω | |Xbar n ω - μ| ≤ z * shat n ω / Real.sqrt (n : ℝ)}
        ⊆ {ω | |Real.sqrt (n : ℝ) * (Xbar n ω - μ) / shat n ω| ≤ z}
          ∪ {ω | shat n ω ≤ 0} := by
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn ω hω
    by_cases hspos : 0 < shat n ω
    · exact Or.inl ((abs_le_iff_sqrt_mul_div (by omega) hspos).mp hω)
    · exact Or.inr (not_lt.mp hspos)
  have hBC : ∀ᶠ (n : ℕ) in atTop,
      {ω | |Real.sqrt (n : ℝ) * (Xbar n ω - μ) / shat n ω| ≤ z}
        ⊆ {ω | |Xbar n ω - μ| ≤ z * shat n ω / Real.sqrt (n : ℝ)}
          ∪ {ω | shat n ω ≤ 0} := by
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn ω hω
    by_cases hspos : 0 < shat n ω
    · exact Or.inl ((abs_le_iff_sqrt_mul_div (by omega) hspos).mpr hω)
    · exact Or.inr (not_lt.mp hspos)
  exact tendsto_measureReal_of_eventually_subset_union hAC hBC hC hB

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
book: capitulos/cap08_intervalos.typ:180 (key: thm:ch11-clt-mixing) —
**Cláusula del intervalo de `thm:ch5-clt-agentes` / `thm:ch11-clt-mixing`**: si
`√T(X̄_T − μ) →d N(0,σ²)` (premisa: CLT de mezcla, externo) y
`σ̂_T →P σ > 0`, entonces el intervalo `X̄_T ± z σ̂_T/√T` tiene cobertura
asintótica `N(0,1)([-z,z])`. -/
theorem ch5_clt_agentes_intervalo
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {Xbar : ℕ → Ω → ℝ} {μ σ : ℝ} {shat : ℕ → Ω → ℝ} {v : ℝ≥0}
    (hσ : 0 < σ) (hv : (v : ℝ) = σ ^ 2)
    (hclt : TendstoInDistribution (fun (n : ℕ) ω => Real.sqrt (n : ℝ) * (Xbar n ω - μ))
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 v))
    (hs : TendstoInMeasure P shat atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (shat n) P) :
    Tendsto (fun (n : ℕ) => P.real {ω | |Xbar n ω - μ| ≤ z * shat n ω / Real.sqrt (n : ℝ)}) atTop
      (𝓝 ((gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z})) :=
  book_interval_coverage hσ (studentized_tendsto_gaussianReal hclt hv hσ hs hsm) hs

/-! ### 2b. La hipótesis del libro es sobre `σ̂²`, no sobre `σ̂` -/

/-- **Studentización con la hipótesis del libro `σ̂² →P σ²`.** Es la forma
literal de la cláusula del libro: la consistencia se enuncia para la varianza
estimada y `σ̂ = √(σ̂²)` es el semiancho estandarizado. -/
theorem studentized_tendsto_gaussianReal_sq
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {X sh2 : ℕ → Ω → ℝ} {σ : ℝ} {v : ℝ≥0}
    (hX : TendstoInDistribution X atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 v))
    (hv : (v : ℝ) = σ ^ 2) (hσ : 0 < σ)
    (hs2 : TendstoInMeasure P sh2 atTop (fun _ => σ ^ 2))
    (hsm : ∀ n, AEMeasurable (sh2 n) P) :
    TendstoInDistribution (fun n ω => X n ω / Real.sqrt (sh2 n ω)) atTop (id : ℝ → ℝ)
      (fun _ => P) (gaussianReal 0 1) := by
  have hsqrt : TendstoInMeasure P (fun n ω => Real.sqrt (sh2 n ω)) atTop (fun _ => σ) := by
    have h := tendstoInMeasure_of_continuousAt (g := Real.sqrt) Real.continuous_sqrt.continuousAt hs2
    simpa [Real.sqrt_sq hσ.le] using h
  exact studentized_tendsto_gaussianReal hX hv hσ hsqrt (fun n => (hsm n).sqrt)

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
book: capitulos/cap08_intervalos.typ:180 (key: thm:ch11-clt-mixing) —
**Cláusula del intervalo con `σ̂² →P σ²`**: la cobertura asintótica del
intervalo `X̄_T ± z √(σ̂²_T)/√T` es `N(0,1)([-z,z])`. Esta es la cláusula tal
como la enuncian `thm:ch5-clt-agentes` y `thm:ch11-clt-mixing`. -/
theorem book_interval_coverage_sq
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {Xbar : ℕ → Ω → ℝ} {μ σ z : ℝ} {sh2 : ℕ → Ω → ℝ}
    (hσ : 0 < σ)
    (hclt : TendstoInDistribution (fun (n : ℕ) ω => Real.sqrt (n : ℝ) * (Xbar n ω - μ))
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 (Real.toNNReal (σ ^ 2))))
    (hs2 : TendstoInMeasure P sh2 atTop (fun _ => σ ^ 2)) (hsm : ∀ n, AEMeasurable (sh2 n) P) :
    Tendsto (fun (n : ℕ) => P.real {ω | |Xbar n ω - μ| ≤ z * Real.sqrt (sh2 n ω) / Real.sqrt (n : ℝ)})
      atTop (𝓝 ((gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z})) := by
  have hsqrt : TendstoInMeasure P (fun n ω => Real.sqrt (sh2 n ω)) atTop (fun _ => σ) := by
    have h := tendstoInMeasure_of_continuousAt (g := Real.sqrt) Real.continuous_sqrt.continuousAt hs2
    simpa [Real.sqrt_sq hσ.le] using h
  have hstud := studentized_tendsto_gaussianReal_sq (v := Real.toNNReal (σ ^ 2)) hclt
    (by rw [Real.coe_toNNReal _ (sq_nonneg σ)]) hσ hs2 hsm
  exact book_interval_coverage hσ hstud hsqrt

/-! ### 4b. Lectura del límite como `1 − α` (cola gaussiana) -/

/-- **Simetría de la normal estándar.** Para `z ≥ 0`,
`N(0,1)([-z,z]) = 1 − 2·N(0,1)(z,∞)`.

Es la identidad que convierte el límite de cobertura en `1 − α` cuando `z` es
el cuantil bilateral `z_{1−α/2}`, es decir cuando `α = 2·N(0,1)(z,∞)`. Se
prueba por simetría exacta de `gaussianReal 0 1` bajo `x ↦ −x`
(`gaussianReal_map_neg`), sin necesidad de la densidad ni del valor de `Φ`. -/
theorem gaussianReal_abs_le_eq (z : ℝ) (hz : 0 ≤ z) :
    (gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z}
      = 1 - 2 * (gaussianReal (0 : ℝ) 1).real (Set.Ioi z) := by
  have hset : {x : ℝ | |x| ≤ z} = (Set.Ioi z ∪ Set.Iio (-z))ᶜ := by
    ext x
    simp only [Set.mem_ofPred_eq, Set.mem_compl_iff, Set.mem_union, Set.mem_Ioi, Set.mem_Iio,
      not_or, not_lt]
    constructor
    · intro h
      exact ⟨(abs_le.mp h).2, by linarith [(abs_le.mp h).1]⟩
    · intro h
      exact abs_le.mpr ⟨by linarith [h.2], h.1⟩
  have hdisj : Disjoint (Set.Ioi z) (Set.Iio (-z)) := by
    rw [Set.disjoint_left]
    intro x hx1 hx2
    simp only [Set.mem_Ioi] at hx1
    simp only [Set.mem_Iio] at hx2
    linarith
  have hsym : (gaussianReal (0 : ℝ) 1).real (Set.Iio (-z))
      = (gaussianReal (0 : ℝ) 1).real (Set.Ioi z) := by
    have hmap : (gaussianReal (0 : ℝ) 1).map (fun x : ℝ => -x) = gaussianReal (0 : ℝ) 1 := by
      simpa using gaussianReal_map_neg (μ := 0) (v := 1)
    have hpre : (fun x : ℝ => -x) ⁻¹' (Set.Ioi z) = Set.Iio (-z) := by
      ext x
      simp only [Set.mem_preimage, Set.mem_Ioi, Set.mem_Iio]
      constructor <;> intro h <;> linarith
    have key : ((gaussianReal (0 : ℝ) 1).map (fun x : ℝ => -x)).real (Set.Ioi z)
        = (gaussianReal (0 : ℝ) 1).real (Set.Iio (-z)) := by
      rw [map_measureReal_apply_of_aemeasurable
        (by fun_prop : AEMeasurable (fun x : ℝ => -x) (gaussianReal (0 : ℝ) 1))
        measurableSet_Ioi, hpre]
    rw [hmap] at key
    exact key.symm
  rw [hset, measureReal_compl (by measurability), measureReal_union hdisj measurableSet_Iio,
    hsym, probReal_univ]
  ring

/-- Cobertura del intervalo del libro con el límite escrito como `1 − 2·cola`:
la forma en que el bloque del libro lo lee cuando `z = z_{1−α/2}`. -/
theorem book_interval_coverage_tail
    {Ω : Type*} {mΩ : MeasurableSpace Ω} {P : Measure Ω} [IsProbabilityMeasure P]
    {Xbar : ℕ → Ω → ℝ} {μ σ z : ℝ} {shat : ℕ → Ω → ℝ}
    (hσ : 0 < σ) (hz : 0 ≤ z)
    (hstud : TendstoInDistribution
      (fun (n : ℕ) ω => Real.sqrt (n : ℝ) * (Xbar n ω - μ) / shat n ω) atTop (id : ℝ → ℝ)
      (fun _ => P) (gaussianReal 0 1))
    (hs : TendstoInMeasure P shat atTop (fun _ => σ)) :
    Tendsto (fun (n : ℕ) => P.real {ω | |Xbar n ω - μ| ≤ z * shat n ω / Real.sqrt (n : ℝ)}) atTop
      (𝓝 (1 - 2 * (gaussianReal (0 : ℝ) 1).real (Set.Ioi z))) := by
  rw [← gaussianReal_abs_le_eq z hz]
  exact book_interval_coverage hσ hstud hs

/-! ### 5. Instanciación con el CLT iid (sin finitud de `Ω`) -/

/-- **CLT studentizado iid** (instanciación no vacía de la hipótesis central).
Con `X` iid, `E[X₀] = ∫ X₀`, `Var(X₀) = σ² > 0` y `σ̂_n →P σ`, el pivote
`(√n)⁻¹(∑_{k<n} X_k − n∫X₀)/σ̂_n` converge a `N(0,1)`.

Se apoya en el CLT de Mathlib (`tendstoInDistribution_inv_sqrt_mul_sum_sub`) y
en la studentización de §2. **No** requiere `[Fintype Ω]`: la finitud que
arrastra `BookCap05.ch5_clt` es una variable de sección que su prueba no usa
(observación de m2, verificada aquí compilando esta misma declaración).

No demuestra el CLT de mezcla: sólo exhibe que la premisa central del teorema
anterior es consistente y que, donde el proyecto ya tiene CLT, la cláusula del
intervalo queda cerrada. -/
theorem ch5_clt_studentized
    {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    {X : ℕ → Ω → ℝ} {σ : ℝ} (hσ : 0 < σ)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = σ ^ 2)
    {shat : ℕ → Ω → ℝ} (hs : TendstoInMeasure P shat atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (shat n) P) :
    TendstoInDistribution
      (fun (n : ℕ) ω => (Real.sqrt (n : ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω
        - (n : ℝ) * ∫ x, X 0 x ∂P) / shat n ω)
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 1) := by
  have hY : HasLaw (id : ℝ → ℝ) (gaussianReal 0 (variance (X 0) P).toNNReal)
      (gaussianReal 0 (variance (X 0) P).toNNReal) :=
    ⟨by fun_prop, Measure.map_id⟩
  have hclt := tendstoInDistribution_inv_sqrt_mul_sum_sub
    (X := X) (Y := (id : ℝ → ℝ)) (P := P)
    (P' := gaussianReal 0 (variance (X 0) P).toNNReal) hY hX hindep hident
  refine studentized_tendsto_gaussianReal hclt ?_ hσ hs hsm
  rw [Real.coe_toNNReal _ (variance_nonneg _ _), hvar]

/-- La misma conclusión a partir del target del libro ya registrado en el
proyecto (`BookCap05.ch5_clt`, `book: capitulos/cap04_herramientas.typ:1464`,
key `thm:ch5-clt`), en el ámbito finito en que ese target vive. Documenta que
la premisa que consume la studentización es exactamente la que el proyecto ya
prueba; el `[Fintype Ω]` se conserva porque es el tipo vivo de ese target. -/
theorem ch5_clt_studentized_book
    {Ω : Type*} [Fintype Ω] [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    {X : ℕ → Ω → ℝ} {σ : ℝ} (hσ : 0 < σ)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = σ ^ 2)
    {shat : ℕ → Ω → ℝ} (hs : TendstoInMeasure P shat atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (shat n) P) :
    TendstoInDistribution
      (fun (n : ℕ) ω => (Real.sqrt (n : ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω
        - (n : ℝ) * ∫ x, X 0 x ∂P) / shat n ω)
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 1) := by
  have hY : HasLaw (id : ℝ → ℝ) (gaussianReal 0 (variance (X 0) P).toNNReal)
      (gaussianReal 0 (variance (X 0) P).toNNReal) :=
    ⟨by fun_prop, Measure.map_id⟩
  have hclt := BookCap05.ch5_clt (Ω' := ℝ) P (gaussianReal 0 (variance (X 0) P).toNNReal)
    X id hY hX hindep hident
  refine studentized_tendsto_gaussianReal hclt ?_ hσ hs hsm
  rw [Real.coe_toNNReal _ (variance_nonneg _ _), hvar]

/-- Caso testigo `σ̂ ≡ σ`: con la varianza límite conocida el pivote es
exactamente el del CLT reescalado, de modo que la conclusión anterior no es
vacía sobre el ámbito iid. -/
theorem ch5_clt_studentized_sigma_conocida
    {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    {X : ℕ → Ω → ℝ} {σ : ℝ} (hσ : 0 < σ)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = σ ^ 2) :
    TendstoInDistribution
      (fun (n : ℕ) ω => ((Real.sqrt (n : ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω
        - (n : ℝ) * ∫ x, X 0 x ∂P)) / σ)
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 1) := by
  have hconst : TendstoInMeasure P (fun (_ : ℕ) (_ : Ω) => σ) atTop (fun _ => σ) := by
    intro ε hε
    have hzero : P {ω : Ω | ε ≤ edist (σ : ℝ) σ} = 0 := by
      have hempty : {ω : Ω | ε ≤ edist (σ : ℝ) σ} = ∅ := by
        ext ω
        simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false]
        rw [edist_self]
        exact not_le.mpr hε
      rw [hempty, measure_empty]
    have hfun : (fun n : ℕ => P {ω : Ω | ε ≤ edist ((fun (_ : ℕ) (_ : Ω) => σ) n ω) σ})
        = fun _ => 0 := by
      funext n
      simpa using hzero
    rw [hfun]
    exact tendsto_const_nhds
  exact ch5_clt_studentized P hσ hX hindep hident hvar hconst
    (fun _ => aemeasurable_const)

/-- **Intervalo del libro en el caso iid, de punta a punta.** Con `X` iid,
`Var(X₀) = σ² > 0` y `σ̂_n →P σ`, la probabilidad de que el intervalo
`X̄_n ± z σ̂_n/√n` cubra `E[X₀]` converge a `N(0,1)([-z,z])`.

Aquí **no queda ninguna premisa distribucional sin demostrar**: el CLT iid es
el de Mathlib y la studentización es la de §2. La única hipótesis estadística
es la consistencia `σ̂_n →P σ` (el libro también la supone). El caso de
contribución estacionaria/mixing sigue condicional
(`ch5_clt_agentes_intervalo`), porque ese CLT no está en Mathlib. -/
theorem ch5_clt_iid_intervalo
    {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    {X : ℕ → Ω → ℝ} {σ z : ℝ} (hσ : 0 < σ)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = σ ^ 2)
    {shat : ℕ → Ω → ℝ} (hs : TendstoInMeasure P shat atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (shat n) P) :
    Tendsto (fun (n : ℕ) => P.real {ω | |(n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, X k ω
        - ∫ x, X 0 x ∂P| ≤ z * shat n ω / Real.sqrt (n : ℝ)})
      atTop (𝓝 ((gaussianReal (0 : ℝ) 1).real {x : ℝ | |x| ≤ z})) := by
  have hstud := ch5_clt_studentized P hσ hX hindep hident hvar hs hsm
  -- la media muestral `X̄_n = n⁻¹ ∑_{k<n} X_k`
  have hfun : ∀ (n : ℕ) (ω : Ω), Real.sqrt (n : ℝ) * ((n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, X k ω
        - ∫ x, X 0 x ∂P) / shat n ω
      = (Real.sqrt (n : ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω
        - (n : ℝ) * ∫ x, X 0 x ∂P) / shat n ω := by
    intro n ω
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn
      simp
    · have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
      have hs0 : Real.sqrt (n : ℝ) ≠ 0 := (Real.sqrt_pos.mpr hnR).ne'
      field_simp
      rw [Real.sq_sqrt hnR.le]
  have hstud' : TendstoInDistribution
      (fun (n : ℕ) ω => Real.sqrt (n : ℝ) * ((n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, X k ω
        - ∫ x, X 0 x ∂P) / shat n ω)
      atTop (id : ℝ → ℝ) (fun _ => P) (gaussianReal 0 1) :=
    TendstoInDistribution.congr
      (fun n => Filter.Eventually.of_forall fun ω => (hfun n ω).symm)
      (Filter.Eventually.of_forall fun _ => rfl) hstud
  exact book_interval_coverage (Xbar := fun n ω => (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, X k ω)
    (μ := ∫ x, X 0 x ∂P) hσ hstud' hs

/-- **Intervalo iid con el límite `1 − 2·cola`** (la lectura `1 − α` del
bloque): con `X` iid, `Var(X₀) = σ² > 0` y `σ̂_n →P σ`, la cobertura de
`X̄_n ± z σ̂_n/√n` tiende a `1 − 2·N(0,1)(z,∞)`. -/
theorem ch5_clt_iid_intervalo_tail
    {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    {X : ℕ → Ω → ℝ} {σ z : ℝ} (hσ : 0 < σ) (hz : 0 ≤ z)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = σ ^ 2)
    {shat : ℕ → Ω → ℝ} (hs : TendstoInMeasure P shat atTop (fun _ => σ))
    (hsm : ∀ n, AEMeasurable (shat n) P) :
    Tendsto (fun (n : ℕ) => P.real {ω | |(n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, X k ω
        - ∫ x, X 0 x ∂P| ≤ z * shat n ω / Real.sqrt (n : ℝ)})
      atTop (𝓝 (1 - 2 * (gaussianReal (0 : ℝ) 1).real (Set.Ioi z))) := by
  rw [← gaussianReal_abs_le_eq z hz]
  exact ch5_clt_iid_intervalo P hσ hX hindep hident hvar hs hsm

/-! ### Auditoría de axiomas -/

#print axioms Ch5StudentizadoM6.tendstoInMeasure_of_continuousAt
#print axioms Ch5StudentizadoM6.tendstoInMeasure_inv
#print axioms Ch5StudentizadoM6.tendstoInDistribution_div_of_tendstoInMeasure_const
#print axioms Ch5StudentizadoM6.studentized_tendsto_gaussianReal
#print axioms Ch5StudentizadoM6.studentized_interval_coverage
#print axioms Ch5StudentizadoM6.tendsto_measureReal_of_eventually_subset_union
#print axioms Ch5StudentizadoM6.abs_le_iff_sqrt_mul_div
#print axioms Ch5StudentizadoM6.book_interval_coverage
#print axioms Ch5StudentizadoM6.ch5_clt_agentes_intervalo
#print axioms Ch5StudentizadoM6.studentized_tendsto_gaussianReal_sq
#print axioms Ch5StudentizadoM6.book_interval_coverage_sq
#print axioms Ch5StudentizadoM6.ch5_clt_studentized
#print axioms Ch5StudentizadoM6.ch5_clt_studentized_book
#print axioms Ch5StudentizadoM6.gaussianReal_abs_le_eq
#print axioms Ch5StudentizadoM6.book_interval_coverage_tail
#print axioms Ch5StudentizadoM6.ch5_clt_iid_intervalo
#print axioms Ch5StudentizadoM6.ch5_clt_iid_intervalo_tail
#print axioms Ch5StudentizadoM6.ch5_clt_studentized_sigma_conocida

end Ch5StudentizadoM6
