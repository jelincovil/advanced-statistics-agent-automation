import Book.ApendiceDIbragimov

/-!
# `Book.IbraComplexM5` — pieza ℂ-valuada del aparato α-mixing de Ibragimov

`verificacion_lean/Book/ApendiceDIbragimov.lean` formaliza la desigualdad de
covarianza de Ibragimov y el lema de bloqueo **para funciones reales** y deja
declarado el hueco (DEUDA.md §1.3.2): la versión ℂ-valuada es la que se aplica a
`exp (it · B_j)` en la prueba por bloques. Este módulo lo cubre:

* `normSupC`, `abs_le_normSupC`, `normSupC_nonneg`: norma supremo ℂ-valuada.
* `abs_cov_le_C`: `‖Cov(u∘f, v∘g)‖ ≤ 2 ‖u‖∞ ‖v‖∞ α` con la **misma constante 2**
  (la prueba original no usa el orden de ℝ, sólo `‖·‖`, así que se transporta tal cual).
* `integral_comp_fintype_C`, `integral_comp_pair_C`: integral de una función ℂ de
  variable finita y de un producto de dos variables finitas = suma sobre la ley.
* `abs_integral_mul_sub_le_alphaCoef_C`: versión ℂ de la desigualdad de covarianza
  para dos variables aleatorias finitas.
* `norm_prod_bloque_le_C`, `normSupC_prod_bloque_le_C`,
  `abs_integral_prod_sub_prod_le_C`: **lema de bloqueo ℂ-valuado**
  `‖E∏_{j<k} u_j(Z_j) − ∏_{j<k} E u_j(Z_j)‖ ≤ 2 B^k ∑_{j<k} a_j`.
* `charFun_sum_block_le`: corolario con funciones características de sumas
  **dependientes**: para `|t|` real,
  `‖E exp(it ∑_{j<k} X_j) − ∏_{j<k} E exp(it X_j)‖ ≤ 2 ∑_{j<k} α_j`.
* `alphaSum_mono_refine`, `alphaCoef_comp_fst_le`: **monotonía** del coeficiente α
  al refinar el pasado (la cota para el pasado fino vale para el grueso): es el
  mecanismo correcto para justificar la hipótesis de bloqueo.
* `not_alphaSum_subadditive_join`: la **subaditividad** de α sobre joins que
  `DEUDA.md` §1.3.1 daba por necesaria es **falsa** (contraejemplo XOR, cálculo exacto).

## Fidelidad declarada (lo que este módulo NO hace)

* No enuncia ni cierra el CLT de Ibragimov `C.thm:appD-ibragimov`: la hipótesis
  `α(σ(Z_0,…,Z_{j−1}), Z_j) ≤ a_j` se **toma como premisa**, igual que en la versión
  real. Descargarla desde coeficientes por pares exige la subaditividad de `α` sobre
  joins (DEUDA.md §1.3.1), que es falsa: la refuta el acoplamiento XOR de más abajo.
  La subaditividad no puede usarse para justificar el bloqueo; usamos premisas explícitas.
* No hay paso al límite, ni tightness, ni Skorokhod: nada distribucional se afirma.
* Estado finito `S` y funciones acotadas, como en el módulo base. La versión con
  momentos `2+δ` (Davydov, DEUDA.md §1.2) sigue fuera de alcance.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

open MeasureTheory Finset BigOperators Filter
open scoped ENNReal Topology

namespace Book.IbraComplexM5

open Book.ApendiceDIbragimov

variable {Ω : Type*} {mΩ : MeasurableSpace Ω} {μ : Measure Ω} [IsProbabilityMeasure μ]

/-! ## Norma supremo ℂ-valuada -/

/-- Norma supremo de una función ℂ-valuada sobre un tipo finito no vacío. -/
noncomputable def normSupC {K : Type*} [Fintype K] [Nonempty K] (u : K → ℂ) : ℝ :=
  Finset.univ.sup' ⟨Classical.arbitrary K, Finset.mem_univ _⟩ fun i => ‖u i‖

lemma abs_le_normSupC {K : Type*} [Fintype K] [Nonempty K] (u : K → ℂ) (i : K) :
    ‖u i‖ ≤ normSupC u := by
  rw [normSupC]
  exact Finset.le_sup' (fun i => ‖u i‖) (Finset.mem_univ i)

lemma normSupC_nonneg {K : Type*} [Fintype K] [Nonempty K] (u : K → ℂ) : 0 ≤ normSupC u :=
  le_trans (norm_nonneg _) (abs_le_normSupC u (Classical.arbitrary K))

/-! ## Álgebra: desigualdad de covarianza ℂ-valuada -/

section Algebra

variable {I J : Type*} [Fintype I] [Fintype J]

/-- **Desigualdad de covarianza de Ibragimov, ℂ-valuada**, con la misma constante
`2` que la versión real: la prueba sólo usa `‖·‖`, `‖uv‖ = ‖u‖‖v‖` y
`∑|desv| = 2α`. -/
theorem abs_cov_le_C [Nonempty I] [Nonempty J] {p : I → J → ℝ}
    (htot : ∑ i, ∑ j, p i j = 1) (u : I → ℂ) (v : J → ℂ) :
    ‖(∑ i, ∑ j, u i * v j * (p i j : ℂ))
        - (∑ i, u i * (fila p i : ℂ)) * (∑ j, v j * (col p j : ℂ))‖
      ≤ 2 * normSupC u * normSupC v * alphaSum p := by
  have hkey : (∑ i, ∑ j, u i * v j * (p i j : ℂ))
        - (∑ i, u i * (fila p i : ℂ)) * (∑ j, v j * (col p j : ℂ))
      = ∑ i, ∑ j, u i * v j * (desv p i j : ℂ) := by
    rw [Finset.sum_mul_sum, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun j _ => ?_
    simp only [desv]
    push_cast
    ring
  rw [hkey]
  have hBu := normSupC_nonneg u
  have hBv := normSupC_nonneg v
  calc ‖∑ i, ∑ j, u i * v j * (desv p i j : ℂ)‖
      ≤ ∑ i, ‖∑ j, u i * v j * (desv p i j : ℂ)‖ := norm_sum_le _ _
    _ ≤ ∑ i, ∑ j, ‖u i * v j * (desv p i j : ℂ)‖ :=
        Finset.sum_le_sum fun i _ => norm_sum_le _ _
    _ ≤ ∑ i, ∑ j, normSupC u * normSupC v * |desv p i j| := by
        refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
        rw [norm_mul, norm_mul, Complex.norm_real]
        have h1 := abs_le_normSupC u i
        have h2 := abs_le_normSupC v j
        have h3 : 0 ≤ |desv p i j| := abs_nonneg _
        have hab : ‖u i‖ * ‖v j‖ ≤ normSupC u * normSupC v :=
          mul_le_mul h1 h2 (norm_nonneg _) hBu
        calc ‖u i‖ * ‖v j‖ * |desv p i j| = (‖u i‖ * ‖v j‖) * |desv p i j| := by ring
          _ ≤ (normSupC u * normSupC v) * |desv p i j| := mul_le_mul_of_nonneg_right hab h3
          _ = normSupC u * normSupC v * |desv p i j| := by ring
    _ = 2 * normSupC u * normSupC v * alphaSum p := by
        have hinner : ∀ i : I, (∑ j, normSupC u * normSupC v * |desv p i j|)
            = normSupC u * normSupC v * (∑ j, |desv p i j|) := fun i =>
          (Finset.mul_sum Finset.univ (fun j => |desv p i j|) (normSupC u * normSupC v)).symm
        simp only [hinner]
        rw [(Finset.mul_sum Finset.univ (fun i => ∑ j, |desv p i j|)
          (normSupC u * normSupC v)).symm, sum_abs_desv_eq htot]
        ring

end Algebra

/-! ## Integrales de funciones ℂ-valuadas de variables finitas -/

section Integral

variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I]
  [MeasurableSingletonClass I]

/-- La integral de una función ℂ de una variable de rango finito es la suma sobre
los átomos de su ley. -/
theorem integral_comp_fintype_C {f : Ω → I} (hf : Measurable f) (u : I → ℂ) :
    ∫ ω, u (f ω) ∂μ = ∑ i, u i * (μ.real (f ⁻¹' ({i} : Set I)) : ℂ) := by
  have hmeas : ∀ i, MeasurableSet (f ⁻¹' ({i} : Set I)) := fun i =>
    hf (measurableSet_singleton i)
  have hind : ∀ i ω, (f ⁻¹' ({i} : Set I)).indicator (fun _ => u i) ω
      = (if f ω = i then u i else 0) := by
    intro i ω
    by_cases h : f ω = i
    · rw [Set.indicator_of_mem (show ω ∈ f ⁻¹' ({i} : Set I) from h), ite_eq_left h]
    · rw [Set.indicator_of_notMem (show ω ∉ f ⁻¹' ({i} : Set I) from h), ite_eq_right h]
  have hpt : ∀ ω, u (f ω) = ∑ i, (f ⁻¹' ({i} : Set I)).indicator (fun _ => u i) ω := by
    intro ω
    simp only [hind]
    rw [Finset.sum_eq_single (f ω)]
    · simp
    · intro i _ hi
      rw [ite_eq_right (fun h => hi h.symm)]
    · intro h
      exact absurd (Finset.mem_univ _) h
  simp only [hpt]
  rw [integral_finsetSum]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [integral_indicator_const (u i) (hmeas i)]
    simp [Algebra.smul_def, mul_comm]
  · intro i _
    exact (integrable_const (u i)).indicator (hmeas i)

/-- La integral del producto de dos funciones ℂ de variables finitas separadas es
la suma sobre la ley conjunta. -/
theorem integral_comp_pair_C {f : Ω → I} {J : Type*} [Fintype J] [DecidableEq J]
    [MeasurableSpace J] [MeasurableSingletonClass J] {g : Ω → J} (hf : Measurable f)
    (hg : Measurable g) (u : I → ℂ) (v : J → ℂ) :
    ∫ ω, u (f ω) * v (g ω) ∂μ
      = ∑ i, ∑ j, u i * v j * (μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) : ℂ) := by
  have hfg : Measurable (fun ω => (f ω, g ω)) := hf.prodMk hg
  have h := integral_comp_fintype_C (μ := μ) (f := fun ω => (f ω, g ω)) hfg
    (fun q : I × J => u q.1 * v q.2)
  simp only at h
  rw [h, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  have hpre : (fun ω => (f ω, g ω)) ⁻¹' ({(i, j)} : Set (I × J))
      = f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J) := by
    ext ω
    simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_inter_iff, Prod.mk.injEq]
  rw [hpre]

end Integral

/-! ## Coeficiente α de un par de variables, versión ℂ -/

section CoefC

variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I]
  [MeasurableSingletonClass I]
variable {J : Type*} [Fintype J] [DecidableEq J] [MeasurableSpace J]
  [MeasurableSingletonClass J]

/-- book: apendices/apendice_regularidad.typ:116 (key: thm:appD-ibragimov) —
**Desigualdad de covarianza** para dos variables aleatorias finitas y funciones
ℂ-valuadas acotadas de sus valores; es la pieza que el argumento de bloques aplica a
`exp (it · B_j)` y que el módulo base sólo tenía para `ℝ`. -/
theorem abs_integral_mul_sub_le_alphaCoef_C (μ : Measure Ω) [IsProbabilityMeasure μ]
    {f : Ω → I} {g : Ω → J} (hf : Measurable f) (hg : Measurable g)
    [Nonempty I] [Nonempty J] (u : I → ℂ) (v : J → ℂ) :
    ‖∫ ω, u (f ω) * v (g ω) ∂μ - (∫ ω, u (f ω) ∂μ) * (∫ ω, v (g ω) ∂μ)‖
      ≤ 2 * normSupC u * normSupC v * alphaCoef μ f g := by
  have hmain := abs_cov_le_C (p := fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)))
    (sum_measureReal_pairs (μ := μ) hf hg) u v
  have hfila : ∀ i : I, fila (fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))) i
      = μ.real (f ⁻¹' ({i} : Set I)) := fun i =>
    sum_measureReal_inter_fiber (hf (measurableSet_singleton i)) hg
  have hcol : ∀ j : J, col (fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))) j
      = μ.real (g ⁻¹' ({j} : Set J)) := fun j => by
    simp only [col]
    rw [← sum_measureReal_inter_fiber (A := g ⁻¹' ({j} : Set J))
      (hg (measurableSet_singleton j)) hf]
    exact Finset.sum_congr rfl fun i _ => by rw [Set.inter_comm]
  simp only [hfila, hcol] at hmain
  rw [integral_comp_pair_C hf hg u v, integral_comp_fintype_C hf u,
    integral_comp_fintype_C hg v]
  simpa only [alphaCoef] using hmain

end CoefC

/-! ## Lema de bloqueo ℂ-valuado -/

section BloquesC

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]
variable {Z : ℕ → Ω → S} {w : ℕ → S → ℂ} {B : ℝ}

/-- Cota de la norma del producto de un bloque por la de sus factores. -/
lemma norm_prod_bloque_le_C (hB : 0 ≤ B) (hw : ∀ i (s : S), ‖w i s‖ ≤ B) (j : ℕ)
    (t : Fin j → S) : ‖∏ i : Fin j, w (i : ℕ) (t i)‖ ≤ B ^ j := by
  induction j with
  | zero => simp
  | succ j ih =>
      rw [Fin.prod_univ_castSucc, norm_mul, pow_succ]
      simp only [Fin.val_castSucc, Fin.val_last]
      exact mul_le_mul (ih fun i => t (Fin.castSucc i)) (hw j _) (norm_nonneg _)
        (pow_nonneg hB j)

/-- Norma supremo del producto de un bloque. -/
lemma normSupC_prod_bloque_le_C (hB : 0 ≤ B) (hw : ∀ i (s : S), ‖w i s‖ ≤ B) (j : ℕ) :
    normSupC (fun t : Fin j → S => ∏ i : Fin j, w (i : ℕ) (t i)) ≤ B ^ j := by
  rw [normSupC]
  exact Finset.sup'_le _ _ fun t _ => norm_prod_bloque_le_C hB hw j t

/-- book: apendices/apendice_regularidad.typ:116 (key: thm:appD-ibragimov) —
**Independencia asintótica de bloques, ℂ-valuada.** Si
`α(σ(Z_0,…,Z_{j−1}), Z_j) ≤ a_j` entonces el producto de las esperanzas aproxima la
esperanza del producto con error `2 B^k ∑_{j<k} a_j`. -/
theorem abs_integral_prod_sub_prod_le_C (μ : Measure Ω) [IsProbabilityMeasure μ]
    {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {w : ℕ → S → ℂ} {B : ℝ} (hB : 0 ≤ B)
    (hw : ∀ i (s : S), ‖w i s‖ ≤ B) {a : ℕ → ℝ} (ha : ∀ i, 0 ≤ a i)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ a j) (k : ℕ) :
    ‖∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
        ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)‖
      ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) := by
  induction k with
  | zero =>
      simp [integral_const]
  | succ k ih =>
      have hsplit : ∀ ω, ∏ i : Fin (k + 1), w (i : ℕ) (Z (i : ℕ) ω)
          = (∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω)) * (w k (Z k ω)) := by
        intro ω
        rw [Fin.prod_univ_castSucc]
        simp
      have hsplitE : ∏ i : Fin (k + 1), (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)
          = (∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)) * (∫ ω, w k (Z k ω) ∂μ) := by
        rw [Fin.prod_univ_castSucc]
        simp
      have hkey : ∫ ω, ∏ i : Fin (k + 1), w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
            ∏ i : Fin (k + 1), (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)
          = (∫ ω, (∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω)) * (w k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ) *
                (∫ ω, w k (Z k ω) ∂μ))
            + (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, w k (Z k ω) ∂μ) := by
        simp only [hsplit, hsplitE]
        ring
      rw [hkey]
      have hcov := abs_integral_mul_sub_le_alphaCoef_C (μ := μ)
        (f := fun ω => fun i : Fin k => Z (i : ℕ) ω) (g := Z k)
        (measurable_bloque hZ k) (hZ k)
        (u := fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i)) (v := w k)
      have hBu : normSupC (fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i)) ≤ B ^ k :=
        normSupC_prod_bloque_le_C hB hw k
      have hBv : normSupC (w k) ≤ B := by
        rw [normSupC]
        exact Finset.sup'_le _ _ fun s _ => hw k s
      have hcov' : ‖∫ ω, (∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω)) * (w k (Z k ω)) ∂μ -
            (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, w k (Z k ω) ∂μ)‖
          ≤ 2 * B ^ k * B * a k := by
        have h1 : alphaCoef μ (fun ω => fun i : Fin k => Z (i : ℕ) ω) (Z k) ≤ a k := hα k
        have h2 : 0 ≤ 2 * normSupC (fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i)) *
            normSupC (w k) := by
          have h0 := normSupC_nonneg (u := fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i))
          have h0' := normSupC_nonneg (u := w k)
          exact mul_nonneg (mul_nonneg (by norm_num) h0) h0'
        refine le_trans hcov ?_
        have h3 : 2 * normSupC (fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i)) *
            normSupC (w k) ≤ 2 * B ^ k * B := by
          have h0 := normSupC_nonneg (u := fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i))
          nlinarith [hBu, hBv, hB, h0]
        calc 2 * normSupC (fun t : Fin k → S => ∏ i : Fin k, w (i : ℕ) (t i)) * normSupC (w k) *
              alphaCoef μ (fun ω => fun i : Fin k => Z (i : ℕ) ω) (Z k)
            ≤ (2 * B ^ k * B) * a k := by
              exact mul_le_mul h3 h1 (alphaCoef_nonneg _ _ _) (by positivity)
          _ = 2 * B ^ k * B * a k := by ring
      have hQ : ‖∫ ω, w k (Z k ω) ∂μ‖ ≤ B := by
        have hint : Integrable (fun ω => w k (Z k ω)) μ := by
          refine Integrable.of_bound
            ((measurable_of_countable (w k)).comp (hZ k)).aestronglyMeasurable B ?_
          filter_upwards with ω
          exact hw k (Z k ω)
        refine le_trans (norm_integral_le_integral_norm (f := fun ω => w k (Z k ω))) ?_
        have hle : ∫ ω, ‖w k (Z k ω)‖ ∂μ ≤ ∫ _ω : Ω, B ∂μ := by
          refine integral_mono (hint.norm) (integrable_const B) (fun ω => hw k _)
        refine le_trans hle ?_
        rw [integral_const, measureReal_univ_eq_one, one_smul]
      have hI : ‖∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
            ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)‖ ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) :=
        ih
      have hIHnn : 0 ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) := by
        refine mul_nonneg (by positivity) ?_
        exact Finset.sum_nonneg fun i _ => ha (i : ℕ)
      calc ‖(∫ ω, (∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω)) * (w k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, w k (Z k ω) ∂μ))
            + (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, w k (Z k ω) ∂μ)‖
          ≤ ‖∫ ω, (∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω)) * (w k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, w k (Z k ω) ∂μ)‖
            + ‖(∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, w k (Z k ω) ∂μ)‖ := norm_add_le _ _
        _ ≤ (2 * B ^ k * B * a k) + (2 * B ^ k * ∑ i : Fin k, a (i : ℕ)) * B := by
            refine add_le_add hcov' ?_
            rw [norm_mul]
            exact mul_le_mul hI hQ (norm_nonneg _) hIHnn
        _ = 2 * B ^ (k + 1) * ∑ i : Fin (k + 1), a (i : ℕ) := by
            rw [Fin.sum_univ_castSucc, pow_succ]
            simp only [Fin.val_castSucc, Fin.val_last]
            ring

/-- Corolario con coeficiente constante: si `α(σ(Z_0,…,Z_{j−1}); Z_j) ≤ α` para todo
`j`, el error del producto es `2 B^k k α` (la forma «`k α(q)`» del bloqueo de Bernstein). -/
theorem abs_integral_prod_sub_prod_le_C_const (μ : Measure Ω) [IsProbabilityMeasure μ]
    {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {w : ℕ → S → ℂ} {B α : ℝ} (hB : 0 ≤ B)
    (hw : ∀ i (s : S), ‖w i s‖ ≤ B) (hα0 : 0 ≤ α)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ α) (k : ℕ) :
    ‖∫ ω, ∏ i : Fin k, w (i : ℕ) (Z (i : ℕ) ω) ∂μ -
        ∏ i : Fin k, (∫ ω, w (i : ℕ) (Z (i : ℕ) ω) ∂μ)‖
      ≤ 2 * B ^ k * (k * α) := by
  have h := abs_integral_prod_sub_prod_le_C (μ := μ) hZ hB hw (a := fun _ => α)
    (fun _ => hα0) hα k
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at h
  exact h

end BloquesC

/-! ## Función característica de una suma dependiente -/

section Caracteristica

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]

/-- `‖exp (i t x)‖ = 1` para `t, x : ℝ`. -/
lemma norm_exp_I_mul_real (t x : ℝ) :
    ‖Complex.exp (Complex.I * ((t * x : ℝ) : ℂ))‖ = 1 := by
  have h : Complex.I * ((t * x : ℝ) : ℂ) = ((t * x : ℝ) : ℂ) * Complex.I := by ring
  rw [h, Complex.norm_exp_ofReal_mul_I]

/-- book: apendices/apendice_regularidad.typ:116 (key: thm:appD-ibragimov) —
**Factorización de la función característica de una suma dependiente.** Para un
proceso `Z` con valores en `S`, observable `val : S → ℝ` y coeficientes que dominan
`α(σ(Z_0,…,Z_{j−1}); Z_j)`,

`‖E exp (i t ∑_{j<k} val(Z_j)) − ∏_{j<k} E exp (i t val(Z_j))‖ ≤ 2 ∑_{j<k} a_j`.

Es la forma ℂ del lema de bloqueo que el argumento de Ibragimov aplica a
`exp (i t B_j)`; **no** es una convergencia en distribución ni cierra el CLT. -/
theorem charFun_sum_block_le (μ : Measure Ω) [IsProbabilityMeasure μ]
    {val : S → ℝ} {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {a : ℕ → ℝ}
    (ha : ∀ i, 0 ≤ a i)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ a j) (t : ℝ)
    (k : ℕ) :
    ‖∫ ω, Complex.exp (Complex.I * ((t * ∑ i : Fin k, val (Z (i : ℕ) ω) : ℝ) : ℂ)) ∂μ -
        ∏ i : Fin k,
          (∫ ω, Complex.exp (Complex.I * ((t * val (Z (i : ℕ) ω) : ℝ) : ℂ)) ∂μ)‖
      ≤ 2 * ∑ i : Fin k, a (i : ℕ) := by
  have hmain := abs_integral_prod_sub_prod_le_C (μ := μ) hZ
    (w := fun i s => Complex.exp (Complex.I * ((t * val s : ℝ) : ℂ)))
    (B := 1) (by norm_num) (fun i s => (norm_exp_I_mul_real t (val s)).le) ha hα k
  have hprod : ∀ ω, Complex.exp (Complex.I * ((t * ∑ i : Fin k, val (Z (i : ℕ) ω) : ℝ) : ℂ))
      = ∏ i : Fin k, Complex.exp (Complex.I * ((t * val (Z (i : ℕ) ω) : ℝ) : ℂ)) := by
    intro ω
    rw [← Complex.exp_sum]
    congr 1
    push_cast
    rw [← mul_assoc]
    rw [Finset.mul_sum (Finset.univ : Finset (Fin k))
      (fun i => (val (Z (i : ℕ) ω) : ℂ)) (Complex.I * (t : ℂ))]
    refine Finset.sum_congr rfl fun i _ => ?_
    ring
  simp only [hprod]
  calc ‖∫ ω, ∏ i : Fin k, Complex.exp (Complex.I * ((t * val (Z (i : ℕ) ω) : ℝ) : ℂ)) ∂μ -
        ∏ i : Fin k,
          (∫ ω, Complex.exp (Complex.I * ((t * val (Z (i : ℕ) ω) : ℝ) : ℂ)) ∂μ)‖
      ≤ 2 * 1 ^ k * ∑ i : Fin k, a (i : ℕ) := hmain
    _ = 2 * ∑ i : Fin k, a (i : ℕ) := by ring

end Caracteristica

/-! ## La misma cota para `MeasureTheory.charFun` de las leyes imagen -/

section CharFunMap

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]

/-- `charFun` de la ley imagen de una variable real, escrita como integral sobre `Ω`. -/
lemma charFun_map_real (μ : Measure Ω) [IsProbabilityMeasure μ] {X : Ω → ℝ}
    (hX : Measurable X) (t : ℝ) :
    charFun (μ.map X) t = ∫ ω, Complex.exp (Complex.I * ((t * X ω : ℝ) : ℂ)) ∂μ := by
  rw [charFun, integral_map hX.aemeasurable]
  · refine integral_congr_ae (Filter.Eventually.of_forall fun ω => ?_)
    show Complex.exp (↑(inner ℝ (X ω) t) * Complex.I)
      = Complex.exp (Complex.I * ↑(t * X ω))
    congr 1
    rw [show inner ℝ (X ω) t = t * X ω by simp]
    ring
  · exact ((by fun_prop : Continuous fun y : ℝ =>
      Complex.exp (↑(inner ℝ y t) * Complex.I))).aestronglyMeasurable

/-- **La función característica de una suma dependiente factoriza salvo `2∑α`**, en la
forma de `MeasureTheory.charFun` de las leyes imagen:
`‖φ_{∑_{j<k} val(Z_j)}(t) − ∏_{j<k} φ_{val(Z_j)}(t)‖ ≤ 2 ∑_{j<k} a_j`. -/
theorem charFun_map_sum_block_le (μ : Measure Ω) [IsProbabilityMeasure μ]
    {val : S → ℝ} {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {a : ℕ → ℝ}
    (ha : ∀ i, 0 ≤ a i)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ a j) (t : ℝ)
    (k : ℕ) :
    ‖charFun (μ.map (fun ω => ∑ i : Fin k, val (Z (i : ℕ) ω))) t -
        ∏ i : Fin k, charFun (μ.map (fun ω => val (Z (i : ℕ) ω))) t‖
      ≤ 2 * ∑ i : Fin k, a (i : ℕ) := by
  have hX : Measurable (fun ω => ∑ i : Fin k, val (Z (i : ℕ) ω)) :=
    Finset.measurable_sum _ fun i _ => (measurable_of_countable val).comp (hZ (i : ℕ))
  have hsum := charFun_map_real (μ := μ)
    (X := fun ω => ∑ i : Fin k, val (Z (i : ℕ) ω)) hX t
  rw [hsum]
  have hprod : ∏ i : Fin k, charFun (μ.map (fun ω => val (Z (i : ℕ) ω))) t
      = ∏ i : Fin k,
          ∫ ω, Complex.exp (Complex.I * ((t * val (Z (i : ℕ) ω) : ℝ) : ℂ)) ∂μ := by
    refine Finset.prod_congr rfl fun i _ => ?_
    exact charFun_map_real μ ((measurable_of_countable val).comp (hZ (i : ℕ))) t
  rw [hprod]
  exact charFun_sum_block_le (μ := μ) hZ ha hα t k

/-- Corolario con coeficiente constante para `charFun`: `‖φ_{∑_{j<k}val(Z_j)}(t) −
∏_{j<k} φ_{val(Z_j)}(t)‖ ≤ 2 k α` cuando `α(σ(Z_0,…,Z_{j−1}); Z_j) ≤ α`. -/
theorem charFun_map_sum_block_le_const (μ : Measure Ω) [IsProbabilityMeasure μ]
    {val : S → ℝ} {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {α : ℝ} (hα0 : 0 ≤ α)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ α) (t : ℝ)
    (k : ℕ) :
    ‖charFun (μ.map (fun ω => ∑ i : Fin k, val (Z (i : ℕ) ω))) t -
        ∏ i : Fin k, charFun (μ.map (fun ω => val (Z (i : ℕ) ω))) t‖ ≤ 2 * (k * α) := by
  have h := charFun_map_sum_block_le (μ := μ) (val := val) hZ (a := fun _ => α)
    (fun _ => hα0) hα t k
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at h
  exact h

end CharFunMap

/-! ## Monotonía de `α` al refinar el pasado — `book: apendices/apendice_regularidad.typ:16 (key: def:appD-alpha)`

El coeficiente del libro es un supremo sobre el pasado **completo**
`F^t_{-∞}`, así que la cota para el pasado fino implica la del bloque. Este es el
paso que sí es cierto (a diferencia de la subaditividad, refutada abajo): añadir
información al pasado no puede disminuir `α`. Se prueba en la forma suma del
repositorio, primero sobre leyes y luego sobre `alphaCoef`. -/

section Monotonia

variable {I I' J : Type*} [Fintype I] [Fintype I'] [Fintype J]

lemma max_zero_sum_le_sum_max {ι : Type*} [Fintype ι] (d : ι → ℝ) :
    max 0 (∑ i, d i) ≤ ∑ i, max 0 (d i) := by
  refine max_le ?_ ?_
  · exact Finset.sum_nonneg fun i _ => le_max_left 0 _
  · exact Finset.sum_le_sum fun i _ => le_max_right 0 _

/-- **Monotonía de `alphaSum` al refinar la primera variable**: la ley conjunta que
recuerda una variable adicional en el pasado tiene coeficiente α mayor o igual. -/
theorem alphaSum_mono_refine (p : I → I' → J → ℝ) :
    alphaSum (fun (i : I) (j : J) => ∑ i', p i i' j)
      ≤ alphaSum (fun (q : I × I') (j : J) => p q.1 q.2 j) := by
  have hfilaQ : ∀ i : I,
      fila (fun (i : I) (j : J) => ∑ i', p i i' j) i
        = ∑ i', fila (fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i') := by
    intro i
    simp only [fila]
    exact Finset.sum_comm
  have hcolQ : ∀ j : J,
      col (fun (i : I) (j : J) => ∑ i', p i i' j) j
        = col (fun (q : I × I') (j : J) => p q.1 q.2 j) j := by
    intro j
    simp only [col]
    exact (Fintype.sum_prod_type (fun q : I × I' => p q.1 q.2 j)).symm
  have hdecomp : ∀ (i : I) (j : J),
      (fun (i : I) (j : J) => ∑ i', p i i' j) i j
          - fila (fun (i : I) (j : J) => ∑ i', p i i' j) i
            * col (fun (i : I) (j : J) => ∑ i', p i i' j) j
        = ∑ i', ((fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i') j
            - fila (fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i')
              * col (fun (q : I × I') (j : J) => p q.1 q.2 j) j) := by
    intro i j
    rw [hfilaQ i, hcolQ j]
    rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
  calc alphaSum (fun (i : I) (j : J) => ∑ i', p i i' j)
      = ∑ i, ∑ j, max 0 ((fun (i : I) (j : J) => ∑ i', p i i' j) i j
          - fila (fun (i : I) (j : J) => ∑ i', p i i' j) i
            * col (fun (i : I) (j : J) => ∑ i', p i i' j) j) := by
        simp only [alphaSum, desv]
    _ ≤ ∑ i, ∑ j, ∑ i', max 0 ((fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i') j
          - fila (fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i')
            * col (fun (q : I × I') (j : J) => p q.1 q.2 j) j) := by
        refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
        rw [hdecomp i j]
        exact max_zero_sum_le_sum_max _
    _ = ∑ i, ∑ i', ∑ j, max 0 ((fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i') j
          - fila (fun (q : I × I') (j : J) => p q.1 q.2 j) (i, i')
            * col (fun (q : I × I') (j : J) => p q.1 q.2 j) j) := by
        refine Finset.sum_congr rfl fun i _ => ?_
        exact Finset.sum_comm
    _ = alphaSum (fun (q : I × I') (j : J) => p q.1 q.2 j) := by
        simp only [alphaSum, desv, Fintype.sum_prod_type]

end Monotonia

section AlphaCoefMono

variable {Ω : Type*} {mΩ : MeasurableSpace Ω} {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I] [MeasurableSingletonClass I]
variable {I' : Type*} [Fintype I'] [DecidableEq I'] [MeasurableSpace I']
  [MeasurableSingletonClass I']
variable {J : Type*} [Fintype J] [DecidableEq J] [MeasurableSpace J] [MeasurableSingletonClass J]

/-- Marginalizar una variable del pasado: la ley conjunta gruesa es la suma de las
leyes finas sobre las celdas de la variable olvidada. -/
lemma joint_coarse_eq_sum {f : Ω → I × I'} {g : Ω → J} (hf : Measurable f) (hg : Measurable g)
    (i : I) (j : J) :
    μ.real ((fun ω => (f ω).1) ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))
      = ∑ i', μ.real (f ⁻¹' ({(i, i')} : Set (I × I')) ∩ g ⁻¹' ({j} : Set J)) := by
  have hset : (fun ω => (f ω).1) ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)
      = ⋃ i', (f ⁻¹' ({(i, i')} : Set (I × I')) ∩ g ⁻¹' ({j} : Set J)) := by
    ext ω
    simp only [Set.mem_inter_iff, Set.mem_preimage, Set.mem_singleton_iff, Set.mem_iUnion]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨(f ω).2, Prod.ext h1 rfl, h2⟩
    · rintro ⟨i', h1, h2⟩
      refine ⟨?_, h2⟩
      rw [h1]
  rw [hset]
  refine measureReal_iUnion_fintype (fun i1 i2 hi => ?_) (fun i' => ?_)
  · refine Set.disjoint_left.2 ?_
    intro ω h1 h2
    simp only [Set.mem_inter_iff, Set.mem_preimage, Set.mem_singleton_iff] at h1 h2
    have hEq : (i, i1) = (i, i2) := by rw [← h1.1, ← h2.1]
    exact hi (by simpa using hEq)
  · exact (hf (measurableSet_singleton _)).inter (hg (measurableSet_singleton j))

/-- **Monotonía del coeficiente α al refinar el pasado.** Si el pasado se observa con
una variable adicional, α no disminuye; equivalentemente, una cota de α calculada con
el pasado fino vale para el pasado grueso. Es el paso que justifica tomar
`α(σ(pasado); Z_j) ≤ a_j` como el coeficiente de mezcla del proceso (monotonía en las
σ-álgebras), y **no** la subaditividad sobre joins, que es falsa. -/
theorem alphaCoef_comp_fst_le {f : Ω → I × I'} {g : Ω → J} (hf : Measurable f)
    (hg : Measurable g) :
    alphaCoef μ (fun ω => (f ω).1) g ≤ alphaCoef μ f g := by
  have hcoarse : ∀ i j, μ.real ((fun ω => (f ω).1) ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))
      = ∑ i', μ.real (f ⁻¹' ({(i, i')} : Set (I × I')) ∩ g ⁻¹' ({j} : Set J)) :=
    fun i j => joint_coarse_eq_sum hf hg i j
  have hmain := alphaSum_mono_refine
    (p := fun (i : I) (i' : I') (j : J) =>
      μ.real (f ⁻¹' ({(i, i')} : Set (I × I')) ∩ g ⁻¹' ({j} : Set J)))
  simp only [← hcoarse] at hmain
  simpa only [alphaCoef] using hmain

end AlphaCoefMono

/-! ## La «subaditividad de `α` sobre joins» (DEUDA.md §1.3.1) es falsa — `book: apendices/apendice_regularidad.typ:16 (key: def:appD-alpha)`

`DEUDA.md` §1.3.1 propone descargar la hipótesis de bloqueo
`α(σ(Z_0,…,Z_{j−1}); Z_j) ≤ a_j` desde coeficientes por pares mediante
`α(A ∨ B, C) ≤ α(A, C) + α(B, C)`. Ese paso **no es cierto**, ni siquiera para
variables finitas y con la forma suma que usa este repositorio: el acoplamiento XOR
`c = a + b` sobre `Fin 2` hace `a ⊥ c` y `b ⊥ c` (α = 0 en ambos) mientras que
`(a, b)` determina `c` (α = 1/2). El contraejemplo se verifica aquí por cálculo
exacto (`norm_num`), no por muestreo.

Consecuencia honesta: la hipótesis `hα` del lema de bloqueo debe tomarse como **la
definición** del coeficiente de mezcla en el retardo `j` (el pasado completo contra
el presente), que es lo que ya hace `abs_integral_prod_sub_prod_le`; no se deduce de
los `α` por pares. El CLT de Ibragimov sigue pendiente. -/

section NoSubaditividad

/-- Ley del acoplamiento XOR sobre `{0,1}³`: `c = a + b` en `Fin 2`, con masa `1/4`
en cada uno de los cuatro átomos compatibles. -/
noncomputable def pxor (a b c : Fin 2) : ℝ := if a + b = c then 1/4 else 0

lemma pxor_nonneg (a b c : Fin 2) : 0 ≤ pxor a b c := by
  simp only [pxor]
  split <;> norm_num

/-- `pxor` es una ley de probabilidad sobre los tres bits. -/
lemma pxor_total : ∑ a : Fin 2, ∑ b : Fin 2, ∑ c : Fin 2, pxor a b c = 1 := by
  simp only [Fin.sum_univ_two, pxor]
  norm_num

/-- `α(σ(a,b); σ(c)) = 1/2`: el par determina `c`. -/
theorem alphaSum_xor_join :
    alphaSum (fun (i : Fin 2 × Fin 2) (j : Fin 2) => pxor i.1 i.2 j) = 1/2 := by
  simp only [alphaSum, desv, fila, col]
  simp only [Fintype.sum_prod_type, Fin.sum_univ_two, pxor]
  norm_num

/-- `α(σ(a); σ(c)) = 0`: `a` es independiente de `c`. -/
theorem alphaSum_xor_left :
    alphaSum (fun (i : Fin 2) (j : Fin 2) => ∑ b : Fin 2, pxor i b j) = 0 := by
  simp only [alphaSum, desv, fila, col]
  simp only [Fin.sum_univ_two, pxor]
  norm_num

/-- `α(σ(b); σ(c)) = 0`: `b` es independiente de `c`. -/
theorem alphaSum_xor_right :
    alphaSum (fun (i : Fin 2) (j : Fin 2) => ∑ a : Fin 2, pxor a i j) = 0 := by
  simp only [alphaSum, desv, fila, col]
  simp only [Fin.sum_univ_two, pxor]
  norm_num

/-- **La subaditividad de `α` sobre joins falla** para la ley XOR: `1/2 > 0 + 0`. -/
theorem not_alphaSum_subadditive_join :
    ¬ (alphaSum (fun (i : Fin 2 × Fin 2) (j : Fin 2) => pxor i.1 i.2 j)
        ≤ alphaSum (fun (i : Fin 2) (j : Fin 2) => ∑ b : Fin 2, pxor i b j)
          + alphaSum (fun (i : Fin 2) (j : Fin 2) => ∑ a : Fin 2, pxor a i j)) := by
  rw [alphaSum_xor_join, alphaSum_xor_left, alphaSum_xor_right]
  norm_num

end NoSubaditividad

end Book.IbraComplexM5
