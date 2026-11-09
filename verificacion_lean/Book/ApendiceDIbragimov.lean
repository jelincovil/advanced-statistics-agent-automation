import Mathlib

/-!
# Book.ApendiceDIbragimov — CLT de Ibragimov para procesos α-mixing

Formalización parcial del resultado `thm:appD-ibragimov` da
`book_stat_inference_v0/apendices/apendice_regularidad.typ` del libro *Inferencia
Estadística* (deuda `C.thm:appD-ibragimov`).

## Enunciado del libro

Sea `{X_t}` estacionario α-mixing, `E[X_t] = 0`, `E|X_t|^{2+δ} < ∞` y
`∑_k α(k)^{δ/(2+δ)} < ∞`. Entonces `n^{-1/2} ∑_{t≤n} X_t →_d N(0, σ²_LR)` con
`σ²_LR = Var(X_0) + 2∑_{k≥1} Cov(X_0, X_k)`.

## Fidelidad declarada (versión finita/discreta)

* **Estado finito**: cada `X_t` toma valores en un tipo finito `S` (esto es el caso
  de los MDP de estados finitos del apéndice; la versión con momentos `2+δ` para
  variables no acotadas es parte de la deuda, ver `DEUDA.md`).
* **Coeficiente α**: se usa la forma suma sobre particiones finitas,
  `α = ∑_{i,j} max 0 (P(f=i,g=j) − P(f=i)P(g=j))`, que domina el supremo
  `sup_{A,B} |P(A∩B) − P(A)P(B)|` del libro y coincide con `β` para particiones
  finitas (`2 α_libro ≤ β`). El lema `abs_desv_le_alphaCoef` muestra que domina
  las desviaciones de cada celda.
* **Constante de covarianza 2**: `|Cov| ≤ 2‖u‖∞‖v‖∞α`, que es la forma clásica
  (`Ibragimov 1962`, `Davydov 1968`) para esta definición suma.
* **Estacionariedad**: se postula estacionariedad de segundo orden en la forma
  `∫ X_i X_j = γ(|i−j|)`; el libro pide estacionariedad estricta (más fuerte).
* El teorema del libro **no** se enuncia como cerrado: se formaliza su núcleo
  cuantitativo (desigualdad de covarianza, decaimiento y sumabilidad de las
  autocovarianzas, lema de Bernstein, crecimiento lineal de la varianza). El paso
  al límite (bloqueo + Lindeberg + continuidad de Lévy) queda como deuda explícita
  con obstrucción precisa en `DEUDA.md`.

## Mapa de resultados

* `integral_comp_fintype`, `integral_comp_pair`, `sum_measureReal_pairs`: cálculo
  de integrales de funciones de variables finitas sobre sus leyes.
* `alphaSum`, `alphaCoef`: coeficiente α de un par de variables finitas.
* `abs_cov_le`, `abs_integral_mul_sub_le_alphaCoef`: **desigualdad de covarianza**
  `|Cov(u∘f, v∘g)| ≤ 2‖u‖∞‖v‖∞α`.
* `abs_gamma_le`: `|γ(k)| ≤ 2‖val‖∞² α(k)` para un proceso centrado.
* `summable_abs_gamma_of_rpow`: la hipótesis del libro
  `∑ α(k)^{δ/(2+δ)} < ∞` implica `∑|γ(k)| < ∞` (caso acotado).
* `doble_suma_eq`: `∑_{i,j<n} g(|i−j|) = n g(0) + 2∑_{k<n}(n−1−k) g(k+1)`.
* `tendsto_average_doble`: **lema de Bernstein**, `n⁻¹∑_{i,j<n} g(|i−j|) → σ²_LR`
  con tasa geométrica.
* `variance_eq_doble`, `tendsto_variance_div`: `Var(∑_{t<n}X_t)/n → σ²_LR`.
* `alphaRect`, `alphaRect_le_alphaSum`, `alphaRect_le_alphaCoef`: **fidelidad**, el
  supremo del libro sobre rectángulos está dominado por el coeficiente usado.
* `abs_integral_prod_sub_prod_le`: **independencia asintótica de bloques**,
  `|E∏_{j<k}u_j(Z_j) − ∏_{j<k}E u_j(Z_j)| ≤ 2B^k∑_{j<k}a_j` (lema de bloqueo).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

open MeasureTheory Finset BigOperators Filter
open scoped ENNReal Topology

namespace Book.ApendiceDIbragimov


variable {Ω : Type*} {mΩ : MeasurableSpace Ω} {μ : Measure Ω} [IsProbabilityMeasure μ]
variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I] [MeasurableSingletonClass I]

theorem measureReal_univ_eq_one : μ.real (Set.univ : Set Ω) = 1 := by
  rw [Measure.real, measure_univ, ENNReal.toReal_one]

/-- Marginal de la ley de `f`: las masas de los átomos suman uno. -/
theorem sum_measureReal_fibers {f : Ω → I} (hf : Measurable f) :
    ∑ i, μ.real (f ⁻¹' ({i} : Set I)) = 1 := by
  have hdisj : Pairwise (fun i j => Disjoint (f ⁻¹' ({i} : Set I)) (f ⁻¹' ({j} : Set I))) := by
    intro i j hij
    apply Set.disjoint_left.2
    intro ω h1 h2
    simp only [Set.mem_preimage, Set.mem_singleton_iff] at h1 h2
    exact hij (h1.symm.trans h2)
  have hmeas : ∀ i, MeasurableSet (f ⁻¹' ({i} : Set I)) := fun i =>
    hf (measurableSet_singleton i)
  have hunion : (⋃ i, f ⁻¹' ({i} : Set I)) = Set.univ := by
    apply Set.Subset.antisymm
    · intro ω _; exact Set.mem_univ ω
    · intro ω _
      rw [Set.mem_iUnion]
      exact ⟨f ω, rfl⟩
  have h := measureReal_iUnion_fintype (μ := μ) (f := fun i : I => f ⁻¹' ({i} : Set I)) hdisj hmeas
  rw [hunion] at h
  rw [← h, measureReal_univ_eq_one]


/-- Marginal de la ley conjunta: fijado un evento `A`, las masas de `A ∩ {g = j}`
suman la masa de `A`. -/
theorem sum_measureReal_inter_fiber {A : Set Ω} (hA : MeasurableSet A) {J : Type*} [Fintype J]
    [DecidableEq J] [MeasurableSpace J] [MeasurableSingletonClass J] {g : Ω → J}
    (hg : Measurable g) :
    ∑ j, μ.real (A ∩ g ⁻¹' ({j} : Set J)) = μ.real A := by
  have hdisj : Pairwise (fun j j' => Disjoint (A ∩ g ⁻¹' ({j} : Set J))
      (A ∩ g ⁻¹' ({j'} : Set J))) := by
    intro j j' hjj'
    apply Set.disjoint_left.2
    intro ω h1 h2
    simp only [Set.mem_inter_iff, Set.mem_preimage, Set.mem_singleton_iff] at h1 h2
    exact hjj' (h1.2.symm.trans h2.2)
  have hmeas : ∀ j, MeasurableSet (A ∩ g ⁻¹' ({j} : Set J)) := fun j =>
    hA.inter (hg (measurableSet_singleton j))
  have hunion : (⋃ j, A ∩ g ⁻¹' ({j} : Set J)) = A := by
    apply Set.Subset.antisymm
    · intro ω h
      rw [Set.mem_iUnion] at h
      obtain ⟨j, h1, h2⟩ := h
      exact h1
    · intro ω h
      rw [Set.mem_iUnion]
      exact ⟨g ω, h, rfl⟩
  have h := measureReal_iUnion_fintype (μ := μ)
    (f := fun j : J => A ∩ g ⁻¹' ({j} : Set J)) hdisj hmeas
  rw [hunion] at h
  exact h.symm

/-- La ley conjunta de `f` y `g` tiene masa total uno. -/
theorem sum_measureReal_pairs {f : Ω → I} {J : Type*} [Fintype J] [DecidableEq J]
    [MeasurableSpace J] [MeasurableSingletonClass J] {g : Ω → J} (hf : Measurable f)
    (hg : Measurable g) :
    ∑ i, ∑ j, μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) = 1 := by
  rw [← sum_measureReal_fibers (μ := μ) hf]
  refine Finset.sum_congr rfl fun i _ => ?_
  have hdisj : Pairwise (fun j j' => Disjoint (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))
      (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j'} : Set J))) := by
    intro j j' hjj'
    apply Set.disjoint_left.2
    intro ω h1 h2
    simp only [Set.mem_inter_iff, Set.mem_preimage, Set.mem_singleton_iff] at h1 h2
    exact hjj' (h1.2.symm.trans h2.2)
  have hmeas : ∀ j, MeasurableSet (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) := fun j =>
    (hf (measurableSet_singleton i)).inter (hg (measurableSet_singleton j))
  have hunion : (⋃ j, f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) = f ⁻¹' ({i} : Set I) := by
    apply Set.Subset.antisymm
    · intro ω h
      rw [Set.mem_iUnion] at h
      obtain ⟨j, h1, h2⟩ := h
      exact h1
    · intro ω h
      rw [Set.mem_iUnion]
      exact ⟨g ω, h, rfl⟩
  have h := measureReal_iUnion_fintype (μ := μ)
    (f := fun j : J => f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) hdisj hmeas
  rw [hunion] at h
  exact h.symm

/-- La integral de una variable aleatoria con rango finito es la suma sobre los
átomos de su ley. -/
theorem integral_comp_fintype {f : Ω → I} (hf : Measurable f) (u : I → ℝ) :
    ∫ ω, u (f ω) ∂μ = ∑ i, u i * μ.real (f ⁻¹' ({i} : Set I)) := by
  have hmeas : ∀ i, MeasurableSet (f ⁻¹' ({i} : Set I)) := fun i =>
    hf (measurableSet_singleton i)
  have hind : ∀ i ω, (f ⁻¹' ({i} : Set I)).indicator (fun _ => u i) ω
      = (if f ω = i then u i else 0) := by
    intro i ω
    by_cases h : f ω = i
    · rw [Set.indicator_of_mem (show ω ∈ f ⁻¹' ({i} : Set I) from h), if_pos h]
    · rw [Set.indicator_of_notMem (show ω ∉ f ⁻¹' ({i} : Set I) from h), if_neg h]
  have hpt : ∀ ω, u (f ω) = ∑ i, (f ⁻¹' ({i} : Set I)).indicator (fun _ => u i) ω := by
    intro ω
    simp only [hind]
    rw [Finset.sum_eq_single (f ω)]
    · simp
    · intro i _ hi
      rw [if_neg (fun h => hi h.symm)]
    · intro h
      exact absurd (Finset.mem_univ _) h
  simp only [hpt]
  rw [integral_finsetSum]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [integral_indicator_const (u i) (hmeas i)]
    simp [mul_comm]
  · intro i _
    exact (integrable_const (u i)).indicator (hmeas i)

/-- La integral del producto de dos funciones de variables finitas separadas. -/
theorem integral_comp_pair {f : Ω → I} {J : Type*} [Fintype J] [DecidableEq J]
    [MeasurableSpace J] [MeasurableSingletonClass J] {g : Ω → J} (hf : Measurable f)
    (hg : Measurable g) (u : I → ℝ) (v : J → ℝ) :
    ∫ ω, u (f ω) * v (g ω) ∂μ
      = ∑ i, ∑ j, u i * v j * μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) := by
  have hfg : Measurable (fun ω => (f ω, g ω)) := hf.prodMk hg
  have h := integral_comp_fintype (μ := μ) (f := fun ω => (f ω, g ω)) hfg
    (fun q : I × J => u q.1 * v q.2)
  simp only at h
  rw [h, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  have hpre : (fun ω => (f ω, g ω)) ⁻¹' ({(i, j)} : Set (I × J))
      = f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J) := by
    ext ω
    simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_inter_iff, Prod.mk.injEq]
  rw [hpre]


/-! ## Álgebra de la ley conjunta: desigualdad de covarianza de Ibragimov

Sea `p : I → J → ℝ` la ley conjunta de dos variables finitas, `p i j = P(f = i, g = j)`.
Se prueba que para funciones acotadas `u : I → ℝ`, `v : J → ℝ`

`|Cov(u∘f, v∘g)| ≤ 2 ‖u‖∞ ‖v‖∞ α`,  `α = ∑_{i,j} max 0 (p i j − P(f=i)P(g=j))`,

que es la desigualdad fundamental (`Ibragimov 1962`, `Davydov 1968`) con la constante 2
correspondiente a la definición suma del coeficiente. -/

section Algebra

variable {I J : Type*} [Fintype I] [Fintype J]

/-- Masa marginal de la fila `i`: `P(f = i)`. -/
def fila (p : I → J → ℝ) (i : I) : ℝ := ∑ j, p i j

/-- Masa marginal de la columna `j`: `P(g = j)`. -/
def col (p : I → J → ℝ) (j : J) : ℝ := ∑ i, p i j

/-- Desviación de independencia de la celda `(i,j)`. -/
def desv (p : I → J → ℝ) (i : I) (j : J) : ℝ := p i j - fila p i * col p j

/-- **Coeficiente α** de un par de variables finitas, en su forma suma:
`α = ∑_{i,j} max 0 (P(f=i,g=j) − P(f=i)P(g=j))`. Para particiones finitas coincide
con `(1/2)∑_{i,j}|·|` y domina el supremo `sup_{A,B}|P(A∩B) − P(A)P(B)|` del libro. -/
noncomputable def alphaSum (p : I → J → ℝ) : ℝ := ∑ i, ∑ j, max 0 (desv p i j)

/-- Norma supremo de una función sobre un tipo finito no vacío. -/
noncomputable def normSup {K : Type*} [Fintype K] [Nonempty K] (u : K → ℝ) : ℝ :=
  Finset.univ.sup' ⟨Classical.arbitrary K, Finset.mem_univ _⟩ fun i => |u i|

lemma abs_le_normSup {K : Type*} [Fintype K] [Nonempty K] (u : K → ℝ) (i : K) :
    |u i| ≤ normSup u := by
  rw [normSup]
  exact Finset.le_sup' (fun i => |u i|) (Finset.mem_univ i)

lemma normSup_nonneg {K : Type*} [Fintype K] [Nonempty K] (u : K → ℝ) : 0 ≤ normSup u :=
  le_trans (abs_nonneg _) (abs_le_normSup u (Classical.arbitrary K))

variable {p : I → J → ℝ}

lemma sum_fila (htot : ∑ i, ∑ j, p i j = 1) : ∑ i, fila p i = 1 := htot

lemma sum_col (htot : ∑ i, ∑ j, p i j = 1) : ∑ j, col p j = 1 := by
  simp only [col]
  rw [Finset.sum_comm]
  exact htot

lemma desv_row_sum_zero (htot : ∑ i, ∑ j, p i j = 1) (i : I) : ∑ j, desv p i j = 0 := by
  simp only [desv, Finset.sum_sub_distrib, ← Finset.mul_sum, sum_col htot, mul_one]
  exact sub_self _

lemma desv_col_sum_zero (htot : ∑ i, ∑ j, p i j = 1) (j : J) : ∑ i, desv p i j = 0 := by
  simp only [desv, Finset.sum_sub_distrib, ← Finset.sum_mul, sum_fila htot, one_mul]
  exact sub_self _

/-- Una familia finita de suma cero: la norma `ℓ¹` es el doble de la suma de las
partes positivas. -/
lemma sum_abs_eq_two_mul_sum_pos {ι : Type*} [Fintype ι] (c : ι → ℝ) (h : ∑ i, c i = 0) :
    ∑ i, |c i| = 2 * ∑ i, max 0 (c i) := by
  have hpt : ∀ i, |c i| = 2 * max 0 (c i) - c i := by
    intro i
    by_cases hc : 0 ≤ c i
    · rw [abs_of_nonneg hc, max_eq_right hc]; ring
    · rw [abs_of_neg (lt_of_not_ge hc), max_eq_left (le_of_lt (lt_of_not_ge hc))]; ring
  calc ∑ i, |c i| = ∑ i, (2 * max 0 (c i) - c i) := by simp only [hpt]
    _ = 2 * ∑ i, max 0 (c i) - ∑ i, c i := by
        rw [Finset.sum_sub_distrib, Finset.mul_sum]
    _ = 2 * ∑ i, max 0 (c i) := by rw [h, sub_zero]

lemma alphaSum_nonneg : 0 ≤ alphaSum p :=
  Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => le_max_left 0 _

lemma desv_total_zero (htot : ∑ i, ∑ j, p i j = 1) : ∑ i, ∑ j, desv p i j = 0 := by
  simp only [desv, Finset.sum_sub_distrib, ← Finset.sum_mul_sum, sum_fila htot, sum_col htot,
    mul_one]
  rw [htot]; ring

/-- `∑_{i,j} |desv| = 2 * alphaSum`. -/
lemma sum_abs_desv_eq (htot : ∑ i, ∑ j, p i j = 1) :
    ∑ i, ∑ j, |desv p i j| = 2 * alphaSum p := by
  have hflat := sum_abs_eq_two_mul_sum_pos (fun q : I × J => desv p q.1 q.2)
    (by rw [Fintype.sum_prod_type]; exact desv_total_zero htot)
  rw [Fintype.sum_prod_type (f := fun q : I × J => |desv p q.1 q.2|),
    Fintype.sum_prod_type (f := fun q : I × J => max 0 (desv p q.1 q.2))] at hflat
  simpa only [alphaSum] using hflat

/-- El coeficiente `α` está dominado por uno (es una probabilidad). -/
lemma alphaSum_le_one (hp : ∀ i j, 0 ≤ p i j) (htot : ∑ i, ∑ j, p i j = 1) :
    alphaSum p ≤ 1 := by
  have h1 : ∑ i, ∑ j, |desv p i j| ≤ ∑ i, ∑ j, (p i j + fila p i * col p j) := by
    refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
    have hfi : 0 ≤ fila p i := Finset.sum_nonneg fun j _ => hp i j
    have hco : 0 ≤ col p j := Finset.sum_nonneg fun i _ => hp i j
    have hfc : 0 ≤ fila p i * col p j := mul_nonneg hfi hco
    have hpi : 0 ≤ p i j := hp i j
    calc |desv p i j| = |p i j - fila p i * col p j| := rfl
      _ ≤ p i j + fila p i * col p j := by
          rw [abs_le]
          constructor <;> linarith
  have h2 : ∑ i, ∑ j, (p i j + fila p i * col p j) = 2 := by
    simp only [Finset.sum_add_distrib]
    rw [← Finset.sum_mul_sum, sum_fila htot, sum_col htot, mul_one]
    rw [htot]
    norm_num
  rw [sum_abs_desv_eq htot] at h1
  linarith

/-- **Desigualdad de covarianza** con la forma suma del coeficiente α. -/
theorem abs_cov_le [Nonempty I] [Nonempty J] (htot : ∑ i, ∑ j, p i j = 1)
    (u : I → ℝ) (v : J → ℝ) :
    |(∑ i, ∑ j, u i * v j * p i j) - (∑ i, u i * fila p i) * (∑ j, v j * col p j)|
      ≤ 2 * normSup u * normSup v * alphaSum p := by
  have hkey : (∑ i, ∑ j, u i * v j * p i j) - (∑ i, u i * fila p i) * (∑ j, v j * col p j)
      = ∑ i, ∑ j, u i * v j * desv p i j := by
    rw [Finset.sum_mul_sum, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun j _ => ?_
    simp only [desv]; ring
  rw [hkey]
  have hBu := normSup_nonneg u
  have hBv := normSup_nonneg v
  calc |∑ i, ∑ j, u i * v j * desv p i j|
      ≤ ∑ i, |∑ j, u i * v j * desv p i j| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, |u i * v j * desv p i j| :=
        Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, normSup u * normSup v * |desv p i j| := by
        refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
        rw [abs_mul, abs_mul]
        have h1 := abs_le_normSup u i
        have h2 := abs_le_normSup v j
        have h3 : 0 ≤ |desv p i j| := abs_nonneg _
        have hab : |u i| * |v j| ≤ normSup u * normSup v := mul_le_mul h1 h2 (abs_nonneg _) hBu
        calc |u i| * |v j| * |desv p i j| = (|u i| * |v j|) * |desv p i j| := by ring
          _ ≤ (normSup u * normSup v) * |desv p i j| := mul_le_mul_of_nonneg_right hab h3
          _ = normSup u * normSup v * |desv p i j| := by ring
    _ = 2 * normSup u * normSup v * alphaSum p := by
        have hinner : ∀ i : I, (∑ j, normSup u * normSup v * |desv p i j|)
            = normSup u * normSup v * (∑ j, |desv p i j|) := fun i =>
          (Finset.mul_sum Finset.univ (fun j => |desv p i j|) (normSup u * normSup v)).symm
        simp only [hinner]
        rw [(Finset.mul_sum Finset.univ (fun i => ∑ j, |desv p i j|)
          (normSup u * normSup v)).symm, sum_abs_desv_eq htot]
        ring

end Algebra

/-! ## Coeficiente α de un par de variables aleatorias -/

section Coef

variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I] [MeasurableSingletonClass I]
variable {J : Type*} [Fintype J] [DecidableEq J] [MeasurableSpace J] [MeasurableSingletonClass J]

/-- **Coeficiente α** de dos variables aleatorias finitas: se aplica `alphaSum` a la
ley conjunta. -/
noncomputable def alphaCoef (μ : Measure Ω) (f : Ω → I) (g : Ω → J) : ℝ :=
  alphaSum (fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)))

theorem alphaCoef_nonneg (μ : Measure Ω) (f : Ω → I) (g : Ω → J) : 0 ≤ alphaCoef μ f g :=
  alphaSum_nonneg

theorem alphaCoef_le_one (μ : Measure Ω) [IsProbabilityMeasure μ] {f : Ω → I} {g : Ω → J}
    (hf : Measurable f) (hg : Measurable g) : alphaCoef μ f g ≤ 1 :=
  alphaSum_le_one (fun i j => measureReal_nonneg) (sum_measureReal_pairs (μ := μ) hf hg)

/-- El coeficiente α domina el supremo del libro sobre rectángulos: para todo `i, j`,
`|P(f=i, g=j) − P(f=i)P(g=j)| ≤ α`. -/
theorem abs_desv_le_alphaCoef (μ : Measure Ω) [IsProbabilityMeasure μ] {f : Ω → I} {g : Ω → J}
    (hf : Measurable f) (hg : Measurable g) (i : I) (j : J) :
    |desv (fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J))) i j| ≤ alphaCoef μ f g := by
  set p := fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)) with hp
  have htot : ∑ i, ∑ j, p i j = 1 := sum_measureReal_pairs (μ := μ) hf hg
  have hrow : ∑ j', desv p i j' = 0 := desv_row_sum_zero htot i
  have hneg : -(desv p i j) = ∑ j' ∈ Finset.univ.erase j, desv p i j' := by
    have hsplit : (∑ j' ∈ Finset.univ.erase j, desv p i j') + desv p i j = 0 := by
      rw [Finset.sum_erase_add _ _ (Finset.mem_univ j)]
      exact hrow
    linarith
  have h1 : desv p i j ≤ alphaCoef μ f g := by
    have hle : desv p i j ≤ max 0 (desv p i j) := le_max_right 0 _
    have hsingle : max 0 (desv p i j) ≤ ∑ j', max 0 (desv p i j') :=
      Finset.single_le_sum (f := fun j' => max 0 (desv p i j'))
        (fun j' _ => le_max_left 0 _) (Finset.mem_univ j)
    have hinner : ∑ j', max 0 (desv p i j') ≤ ∑ i', ∑ j', max 0 (desv p i' j') :=
      Finset.single_le_sum (f := fun i' => ∑ j', max 0 (desv p i' j'))
        (fun i' _ => Finset.sum_nonneg fun j' _ => le_max_left 0 _) (Finset.mem_univ i)
    exact le_trans hle (le_trans hsingle (by simpa only [alphaCoef, alphaSum, hp] using hinner))
  have h2 : -alphaCoef μ f g ≤ desv p i j := by
    have hle : -(desv p i j) ≤ ∑ j' ∈ Finset.univ.erase j, max 0 (desv p i j') := by
      rw [hneg]
      refine Finset.sum_le_sum fun j' _ => ?_
      exact le_max_right 0 _
    have hsub : ∑ j' ∈ Finset.univ.erase j, max 0 (desv p i j') ≤ ∑ j', max 0 (desv p i j') :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _)
        (fun j' _ _ => le_max_left 0 _)
    have hinner : ∑ j', max 0 (desv p i j') ≤ ∑ i', ∑ j', max 0 (desv p i' j') :=
      Finset.single_le_sum (f := fun i' => ∑ j', max 0 (desv p i' j'))
        (fun i' _ => Finset.sum_nonneg fun j' _ => le_max_left 0 _) (Finset.mem_univ i)
    have : -(desv p i j) ≤ alphaCoef μ f g :=
      le_trans hle (le_trans hsub (by simpa only [alphaCoef, alphaSum, hp] using hinner))
    linarith
  exact abs_le.mpr ⟨h2, h1⟩

/-- **Desigualdad de covarianza** para dos variables aleatorias finitas `f, g` y
funciones acotadas `u, v` de sus valores. -/
theorem abs_integral_mul_sub_le_alphaCoef (μ : Measure Ω) [IsProbabilityMeasure μ]
    {f : Ω → I} {g : Ω → J} (hf : Measurable f) (hg : Measurable g)
    [Nonempty I] [Nonempty J] (u : I → ℝ) (v : J → ℝ) :
    |∫ ω, u (f ω) * v (g ω) ∂μ - (∫ ω, u (f ω) ∂μ) * (∫ ω, v (g ω) ∂μ)|
      ≤ 2 * normSup u * normSup v * alphaCoef μ f g := by
  have hmain := abs_cov_le (p := fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)))
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
  rw [integral_comp_pair hf hg u v, integral_comp_fintype hf u, integral_comp_fintype hg v]
  simpa only [alphaCoef] using hmain

end Coef

/-! ## Fidelidad: el coeficiente formal domina el supremo del libro

El libro define `α(𝒜,ℬ) = sup_{A∈𝒜, B∈ℬ} |P(A∩B) − P(A)P(B)|`. En un espacio
finito, todo evento de las σ-álgebras generadas por dos variables finitas es una
unión de átomos, así que el supremo recorre rectángulos `S × T`. Se prueba que el
coeficiente `alphaSum` domina ese supremo (y por tanto toda la jerarquía
`2α_libro ≤ β ≤ φ` se transporta). -/

section Rect

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J] {p : I → J → ℝ}

/-- Desviación de un rectángulo `S × T` (evento de la σ-álgebra producto). -/
def rectDev (p : I → J → ℝ) (S : Finset I) (T : Finset J) : ℝ :=
  ∑ i ∈ S, ∑ j ∈ T, desv p i j

/-- Desviación de un rectángulo, acotada por el coeficiente α. -/
lemma sum_subset_le_alphaSum (S : Finset I) (T : Finset J) :
    ∑ i ∈ S, ∑ j ∈ T, desv p i j ≤ alphaSum p := by
  have h1 : ∀ i ∈ S, ∑ j ∈ T, desv p i j ≤ ∑ j, max 0 (desv p i j) := by
    intro i _
    refine le_trans (Finset.sum_le_sum fun j _ => le_max_right 0 (desv p i j)) ?_
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ T)
      (fun j _ _ => le_max_left 0 _)
  refine le_trans (Finset.sum_le_sum h1) ?_
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
    (fun i _ _ => Finset.sum_nonneg fun j _ => le_max_left 0 _)

/-- La desviación de cualquier rectángulo está dominada por α. -/
theorem abs_rectDev_le_alphaSum (htot : ∑ i, ∑ j, p i j = 1) (S : Finset I) (T : Finset J) :
    |rectDev p S T| ≤ alphaSum p := by
  have hrow0 : ∑ i ∈ S, ∑ j, desv p i j = 0 :=
    Finset.sum_eq_zero fun i _ => desv_row_sum_zero htot i
  have hsplit : ∑ i ∈ S, ∑ j, desv p i j
      = ∑ i ∈ S, ∑ j ∈ T, desv p i j + ∑ i ∈ S, ∑ j ∈ Tᶜ, desv p i j := by
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_add_sum_compl]
  have hneg : rectDev p S T = -∑ i ∈ S, ∑ j ∈ Tᶜ, desv p i j := by
    rw [rectDev]
    linarith [hrow0, hsplit]
  have hle1 : rectDev p S T ≤ alphaSum p := sum_subset_le_alphaSum S T
  have hle2 : -rectDev p S T ≤ alphaSum p := by
    rw [hneg, neg_neg]
    exact sum_subset_le_alphaSum S Tᶜ
  exact abs_le.mpr ⟨by linarith, hle1⟩

/-- El coeficiente α "del libro" (supremo sobre rectángulos, que en espacio finito
es el máximo y coincide con el supremo sobre eventos). -/
noncomputable def alphaRect (p : I → J → ℝ) : ℝ :=
  (Finset.univ : Finset (Finset I × Finset J)).sup' ⟨(∅, ∅), Finset.mem_univ _⟩
    fun ST => |rectDev p ST.1 ST.2|

lemma alphaRect_nonneg (p : I → J → ℝ) : 0 ≤ alphaRect p := by
  rw [alphaRect]
  exact le_trans (abs_nonneg _)
    (Finset.le_sup' (fun ST : Finset I × Finset J => |rectDev p ST.1 ST.2|)
      (Finset.mem_univ (∅, ∅)))

/-- **Fidelidad**: el supremo del libro está dominado por el coeficiente usado en la
desigualdad de covarianza. Por tanto las hipótesis de decaimiento impuestas sobre
`alphaSum` son más fuertes que las del libro. -/
theorem alphaRect_le_alphaSum (htot : ∑ i, ∑ j, p i j = 1) : alphaRect p ≤ alphaSum p := by
  rw [alphaRect]
  refine Finset.sup'_le _ _ fun ST _ => ?_
  exact abs_rectDev_le_alphaSum htot ST.1 ST.2

end Rect

section RectMedida

variable {I : Type*} [Fintype I] [DecidableEq I] [MeasurableSpace I] [MeasurableSingletonClass I]
variable {J : Type*} [Fintype J] [DecidableEq J] [MeasurableSpace J] [MeasurableSingletonClass J]

/-- Versión para dos variables aleatorias finitas: el α del libro (rectángulos de
átomos) está dominado por `alphaCoef`. -/
theorem alphaRect_le_alphaCoef (μ : Measure Ω) [IsProbabilityMeasure μ] {f : Ω → I}
    {g : Ω → J} (hf : Measurable f) (hg : Measurable g) :
    alphaRect (fun i j => μ.real (f ⁻¹' ({i} : Set I) ∩ g ⁻¹' ({j} : Set J)))
      ≤ alphaCoef μ f g :=
  alphaRect_le_alphaSum (sum_measureReal_pairs (μ := μ) hf hg)

end RectMedida

/-! ## Proceso estacionario con observable acotado

Se considera un proceso `Y : ℕ → Ω → S` con `S` finito (cada `Y t` es una variable
finita), un observable real `val : S → ℝ`, y se prueba que la autocovarianza
`γ(k) = E[(val∘Y₀)(val∘Y_k)]` (proceso centrado) decae al menos como el coeficiente
`α(k)`: `|γ(k)| ≤ 2‖val‖∞² α(k)`. De ahí la sumabilidad absoluta de las
autocovarianzas bajo las hipótesis de sumabilidad de `α` del libro. -/

section Proceso

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]
variable {val : S → ℝ} {Y : ℕ → Ω → S}

/-- La norma supremo del observable: `‖val‖∞`. -/
noncomputable def Bsup (val : S → ℝ) : ℝ := normSup val

lemma Bsup_nonneg : 0 ≤ Bsup val := normSup_nonneg val

lemma abs_val_le_Bsup (s : S) : |val s| ≤ Bsup val := abs_le_normSup val s

/-- Autocovarianza en el desfase `k` para un proceso centrado: `γ(k) = E[X₀X_k]`. -/
noncomputable def gamma (μ : Measure Ω) (val : S → ℝ) (Y : ℕ → Ω → S) (k : ℕ) : ℝ :=
  ∫ ω, val (Y 0 ω) * val (Y k ω) ∂μ

/-- **Decaimiento de las autocovarianzas** (caso acotado de la desigualdad de
Ibragimov-Davydov): `|γ(k)| ≤ 2‖val‖∞² α(k)`. -/
theorem abs_gamma_le (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t)) {a : ℕ → ℝ}
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ a k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0) (k : ℕ) :
    |gamma μ val Y k| ≤ 2 * Bsup val * Bsup val * a k := by
  have hB := Bsup_nonneg (val := val)
  have hcov := abs_integral_mul_sub_le_alphaCoef (μ := μ) (f := Y 0) (g := Y k)
    (hY 0) (hY k) (u := val) (v := val)
  rw [hm 0, hm k, mul_zero, sub_zero] at hcov
  have hmain : |gamma μ val Y k|
      ≤ 2 * Bsup val * Bsup val * alphaCoef μ (Y 0) (Y (0 + k)) := by
    simpa [gamma, Bsup, zero_add, mul_assoc] using hcov
  have hle : alphaCoef μ (Y 0) (Y (0 + k)) ≤ a k := hα 0 k
  have hnn : 0 ≤ 2 * Bsup val * Bsup val := by
    have := Bsup_nonneg (val := val); positivity
  exact le_trans hmain (mul_le_mul_of_nonneg_left hle hnn)

/-- Sumabilidad absoluta de las autocovarianzas a partir de la sumabilidad del
coeficiente `α`. -/
theorem summable_abs_gamma (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t)) {a : ℕ → ℝ} (ha : Summable a) (ha0 : ∀ k, 0 ≤ a k)
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ a k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0) :
    Summable fun k => |gamma μ val Y k| := by
  have hnn : 0 ≤ 2 * Bsup val * Bsup val := by
    have := Bsup_nonneg (val := val); positivity
  refine Summable.of_nonneg_of_le (fun k => abs_nonneg _) (fun k => ?_)
    (ha.mul_left (2 * Bsup val * Bsup val))
  exact abs_gamma_le μ hY hα hm k

/-- **Varianza de largo plazo** `σ²_LR = γ(0) + 2∑_{k≥1} γ(k)`. -/
noncomputable def sigmaLR (μ : Measure Ω) (val : S → ℝ) (Y : ℕ → Ω → S) : ℝ :=
  gamma μ val Y 0 + 2 * ∑' k, gamma μ val Y (k + 1)

/-- Bajo las hipótesis del libro (`∑ α(k)^{δ/(2+δ)} < ∞` y observable acotado) las
autocovarianzas son absolutamente sumables: como `0 ≤ α(k) ≤ 1`, se tiene
`α(k) ≤ α(k)^{δ/(2+δ)}` y basta la desigualdad de covarianza. -/
theorem summable_abs_gamma_of_rpow (μ : Measure Ω) [IsProbabilityMeasure μ]
    {Y : ℕ → Ω → S} (hY : ∀ t, Measurable (Y t)) {a : ℕ → ℝ} {δ : ℝ} (hδ : 0 < δ)
    (ha0 : ∀ k, 0 ≤ a k) (ha1 : ∀ k, a k ≤ 1)
    (ha : Summable fun k => (a k) ^ (δ / (2 + δ)))
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ a k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0) :
    Summable fun k => |gamma μ val Y k| := by
  have hexp : δ / (2 + δ) ≤ 1 := by
    have h2 : (0:ℝ) < 2 + δ := by linarith
    rw [div_le_one h2]; linarith
  have hexp0 : 0 ≤ δ / (2 + δ) := le_of_lt (div_pos hδ (by linarith))
  have hle : ∀ k, a k ≤ (a k) ^ (δ / (2 + δ)) := fun k => by
    by_cases h0 : a k = 0
    · rw [h0, Real.zero_rpow (ne_of_lt (div_pos hδ (by linarith))).symm]
    · have hpos : 0 < a k := lt_of_le_of_ne (ha0 k) (Ne.symm h0)
      have := Real.rpow_le_rpow_of_exponent_ge hpos (ha1 k) hexp
      simpa using this
  exact summable_abs_gamma μ hY (Summable.of_nonneg_of_le ha0 hle ha) ha0 hα hm

end Proceso

/-! ## La identidad de doble suma `∑_{i,j<n} g(|i−j|) = n g(0) + 2∑_{k<n} (n−1−k) g(k+1)`

Es el paso combinatorio del lema de Bernstein: la varianza de la suma parcial se
escribe como doble suma de autocovarianzas y el número de pares a distancia `k` es
`2(n−k)` para `k ≥ 1`. -/

section DobleSuma

variable (g : ℕ → ℝ)

/-- Suma triangular auxiliar: `R(n) = n g(0) + 2∑_{k<n} (n−1−k) g(k+1)`. -/
noncomputable def sumaTri (g : ℕ → ℝ) (n : ℕ) : ℝ :=
  (n : ℝ) * g 0 + 2 * ∑ k ∈ Finset.range n, ((n : ℝ) - 1 - k) * g (k + 1)

/-- Incremento de la doble suma al pasar de `n` a `n+1`. -/
lemma doble_suma_succ (n : ℕ) :
    (∑ i ∈ Finset.range (n + 1), ∑ j ∈ Finset.range (n + 1), g (Nat.dist i j))
      = (∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, g (Nat.dist i j))
        + g 0 + 2 * ∑ k ∈ Finset.range n, g (k + 1) := by
  have hrow : ∑ i ∈ Finset.range n, g (Nat.dist i n) = ∑ k ∈ Finset.range n, g (k + 1) := by
    have h1 : ∑ i ∈ Finset.range n, g (Nat.dist i n)
        = ∑ i ∈ Finset.range n, g (n - 1 - i + 1) := by
      refine Finset.sum_congr rfl fun i hi => ?_
      have hi' : i < n := Finset.mem_range.mp hi
      rw [Nat.dist_eq_sub_of_le (le_of_lt hi')]
      congr 1
      omega
    rw [h1]
    exact Finset.sum_range_reflect (fun t => g (t + 1)) n
  have hcol : ∑ j ∈ Finset.range n, g (Nat.dist n j) = ∑ k ∈ Finset.range n, g (k + 1) := by
    rw [← hrow]
    exact Finset.sum_congr rfl fun j _ => by rw [Nat.dist_comm]
  rw [Finset.sum_range_succ]
  simp only [Finset.sum_range_succ, Finset.sum_add_distrib]
  rw [hrow, hcol]
  simp only [Nat.dist_self]
  ring

/-- Incremento de `sumaTri` al pasar de `n` a `n+1`. -/
lemma sumaTri_succ (n : ℕ) :
    sumaTri g (n + 1) = sumaTri g n + g 0 + 2 * ∑ k ∈ Finset.range n, g (k + 1) := by
  have hsum : ∑ k ∈ Finset.range n, (((n : ℝ) + 1) - 1 - k) * g (k + 1)
      = ∑ k ∈ Finset.range n, (((n : ℝ) - 1 - k) * g (k + 1) + g (k + 1)) := by
    refine Finset.sum_congr rfl fun k _ => ?_
    ring
  rw [sumaTri, Finset.sum_range_succ]
  push_cast
  rw [hsum, Finset.sum_add_distrib]
  simp only [sumaTri]
  ring

/-- **Identidad de la doble suma de autocovarianzas.** -/
theorem doble_suma_eq (n : ℕ) :
    (∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, g (Nat.dist i j)) = sumaTri g n := by
  induction n with
  | zero => simp [sumaTri]
  | succ n ih =>
      rw [doble_suma_succ g n, ih, ← sumaTri_succ g n]

end DobleSuma

/-! ## Lema de Bernstein: el promedio de la doble suma converge a `σ²_LR`

Si `|g(k)| ≤ C ρ^k` con `0 ≤ ρ < 1`, entonces el promedio
`n⁻¹ ∑_{i,j<n} g(|i−j|)` converge a `g(0) + 2∑_{k≥1} g(k)`. Es la parte
"varianza" del CLT de Ibragimov: la varianza de la suma parcial crece como `n σ²_LR`. -/

section Bernstein

/-- Si `b` está acotada entonces `b(n)/n → 0`. -/
lemma tendsto_inv_mul_of_bounded {b : ℕ → ℝ} {S : ℝ} (hS : 0 ≤ S) (hb : ∀ n, |b n| ≤ S) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * b n) atTop (𝓝 0) := by
  have hc : Tendsto (fun n : ℕ => S * (n : ℝ)⁻¹) atTop (𝓝 0) := by
    simpa using (tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop).const_mul S
  refine squeeze_zero_norm (fun n => ?_) hc
  rw [norm_mul, Real.norm_eq_abs, Real.norm_eq_abs,
    abs_of_nonneg (by positivity : (0:ℝ) ≤ (n : ℝ)⁻¹)]
  rw [mul_comm S]
  exact mul_le_mul_of_nonneg_left (hb n) (by positivity)

/-- **Lema de Bernstein** (versión acotada/geométrica). -/
theorem tendsto_average_doble (g : ℕ → ℝ) {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hg : ∀ k, |g k| ≤ C * ρ ^ k) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ *
        ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, g (Nat.dist i j))
      atTop (𝓝 (g 0 + 2 * ∑' k : ℕ, g (k + 1))) := by
  have hρabs : ‖ρ‖ < 1 := by
    rw [Real.norm_eq_abs, abs_of_nonneg hρ0]; exact hρ1
  have hgeom : Summable (fun k : ℕ => ρ ^ k) := summable_geometric_of_norm_lt_one hρabs
  have hsumg : Summable g := by
    refine Summable.of_norm_bounded (f := g) (g := fun k : ℕ => C * ρ ^ k)
      (hgeom.mul_left C) ?_
    intro k
    rw [Real.norm_eq_abs]
    exact hg k
  have hsumg1 : Summable (fun k : ℕ => g (k + 1)) := (summable_nat_add_iff 1).mpr hsumg
  have hsumk : Summable (fun k : ℕ => ((k : ℝ) + 1) * ρ ^ k) := by
    have h1 : Summable (fun k : ℕ => ((k : ℝ)) * ρ ^ k) := by
      simpa using summable_pow_mul_geometric_of_norm_lt_one (R := ℝ) 1 hρabs
    simpa [add_mul, one_mul] using h1.add hgeom
  have hmaj : Summable (fun k : ℕ => C * (((k : ℝ) + 1) * ρ ^ k)) := hsumk.mul_left C
  have hsumkg : Summable (fun k : ℕ => ((k : ℝ) + 1) * |g (k + 1)|) := by
    refine Summable.of_nonneg_of_le
      (fun k => mul_nonneg (by positivity : (0:ℝ) ≤ (k : ℝ) + 1) (abs_nonneg _)) (fun k => ?_) hmaj
    have h1 : |g (k + 1)| ≤ C * ρ ^ (k + 1) := hg (k + 1)
    have h2 : ρ ^ (k + 1) ≤ ρ ^ k := by
      rw [pow_succ]
      calc ρ ^ k * ρ ≤ ρ ^ k * 1 := mul_le_mul_of_nonneg_left (le_of_lt hρ1) (pow_nonneg hρ0 k)
        _ = ρ ^ k := mul_one _
    have hk : (0:ℝ) ≤ (k : ℝ) + 1 := by positivity
    calc ((k : ℝ) + 1) * |g (k + 1)| ≤ ((k : ℝ) + 1) * (C * ρ ^ (k + 1)) :=
          mul_le_mul_of_nonneg_left h1 hk
      _ ≤ ((k : ℝ) + 1) * (C * ρ ^ k) :=
          mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left h2 hC) hk
      _ = C * (((k : ℝ) + 1) * ρ ^ k) := by ring
  set S : ℝ := ∑' k : ℕ, ((k : ℝ) + 1) * |g (k + 1)| with hSdef
  have hS : 0 ≤ S := tsum_nonneg fun k =>
    mul_nonneg (by positivity : (0:ℝ) ≤ (k : ℝ) + 1) (abs_nonneg _)
  -- límite de la cola de autocovarianzas
  have hA : Tendsto (fun n : ℕ => ∑ k ∈ Finset.range n, g (k + 1)) atTop
      (𝓝 (∑' k : ℕ, g (k + 1))) := hsumg1.hasSum.tendsto_sum_nat
  -- límite del promedio ponderado
  have hbounded : ∀ n : ℕ, |∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1)| ≤ S := by
    intro n
    have hle : |∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1)|
        ≤ ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * |g (k + 1)| := by
      refine le_trans (Finset.abs_sum_le_sum_abs _ _) (le_of_eq ?_)
      refine Finset.sum_congr rfl fun k _ => ?_
      rw [abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ ((k : ℝ) + 1))]
    refine le_trans hle ?_
    rw [hSdef]
    exact Summable.sum_le_tsum _ (f := fun k : ℕ => ((k : ℝ) + 1) * |g (k + 1)|)
      (fun k _ => mul_nonneg (by positivity : (0:ℝ) ≤ (k : ℝ) + 1) (abs_nonneg _)) hsumkg
  have hB : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1))
      atTop (𝓝 0) := tendsto_inv_mul_of_bounded hS hbounded
  have hC' : Tendsto (fun n : ℕ => g 0 + 2 * ((∑ k ∈ Finset.range n, g (k + 1)) -
      (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1))) atTop
      (𝓝 (g 0 + 2 * ((∑' k : ℕ, g (k + 1)) - 0))) := by
    have h1 : Tendsto (fun n : ℕ => (∑ k ∈ Finset.range n, g (k + 1)) -
        (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1)) atTop
        (𝓝 ((∑' k : ℕ, g (k + 1)) - 0)) := hA.sub hB
    exact Tendsto.const_add _ (h1.const_mul 2)
  rw [sub_zero] at hC'
  refine hC'.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by
    have : (0:ℝ) < (n : ℝ) := by exact_mod_cast (Nat.lt_of_lt_of_le Nat.zero_lt_one hn)
    exact ne_of_gt this
  have hsplit : (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, ((n : ℝ) - 1 - k) * g (k + 1)
      = ∑ k ∈ Finset.range n, g (k + 1) -
        (n : ℝ)⁻¹ * ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * g (k + 1) := by
    rw [Finset.mul_sum]
    have hpt : ∀ k : ℕ, (n : ℝ)⁻¹ * (((n : ℝ) - 1 - k) * g (k + 1))
        = g (k + 1) - (n : ℝ)⁻¹ * ((k : ℝ) + 1) * g (k + 1) := by
      intro k
      field_simp
      ring
    simp only [hpt, Finset.sum_sub_distrib]
    congr 1
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [doble_suma_eq g n, sumaTri, ← hsplit]
  field_simp
  try ring

end Bernstein

/-! ## La varianza de la suma parcial crece como `n σ²_LR`

Se identifica `Var(∑_{t<n} X_t)` con la doble suma de autocovarianzas y se aplica
el lema de Bernstein. Es la parte cuantitativa del CLT de Ibragimov: la varianza de
la suma parcial es asintóticamente lineal con coeficiente la varianza de largo plazo. -/

section Varianza

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]
variable {val : S → ℝ} {Y : ℕ → Ω → S}

/-- Producto de dos funciones acotadas y medibles es integrable para una medida de
probabilidad. -/
lemma integrable_mul_bounded (μ : Measure Ω) [IsProbabilityMeasure μ] {x y : Ω → ℝ}
    (hx : Measurable x) (hy : Measurable y) {Bx By : ℝ} (hBx : 0 ≤ Bx) (hBy : 0 ≤ By)
    (hbx : ∀ ω, |x ω| ≤ Bx) (hby : ∀ ω, |y ω| ≤ By) :
    Integrable (fun ω => x ω * y ω) μ := by
  refine Integrable.of_bound (hx.mul hy).aestronglyMeasurable (Bx * By) ?_
  filter_upwards with ω
  rw [Real.norm_eq_abs, abs_mul]
  exact mul_le_mul (hbx ω) (hby ω) (abs_nonneg _) hBx

/-- Todo observable `val : S → ℝ` sobre un tipo finito es medible. -/
lemma measurable_val : Measurable (val : S → ℝ) := measurable_of_countable val

/-- Cada `val ∘ Y i` es integrable (acotada). -/
lemma integrable_obs (μ : Measure Ω) [IsProbabilityMeasure μ] (hY : ∀ t, Measurable (Y t))
    (t : ℕ) : Integrable (fun ω => val (Y t ω)) μ := by
  refine Integrable.of_bound ((measurable_val (val := val)).comp (hY t)).aestronglyMeasurable
    (Bsup val) ?_
  filter_upwards with ω
  rw [Real.norm_eq_abs]
  exact abs_val_le_Bsup (Y t ω)

/-- **Identidad de la varianza**: `Var(∑_{t<n} X_t)` es la suma de las
autocovarianzas sobre las distancias entre índices. -/
theorem variance_eq_doble (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t))
    (hstat : ∀ i j : ℕ, ∫ ω, val (Y i ω) * val (Y j ω) ∂μ
      = gamma μ val Y (Nat.dist i j)) (n : ℕ) :
    ∫ ω, (∑ i ∈ Finset.range n, val (Y i ω)) ^ 2 ∂μ
      = ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, gamma μ val Y (Nat.dist i j) := by
  have hB := Bsup_nonneg (val := val)
  have hint : ∀ i j : ℕ, Integrable (fun ω => val (Y i ω) * val (Y j ω)) μ := fun i j =>
    integrable_mul_bounded μ ((measurable_val (val := val)).comp (hY i))
      ((measurable_val (val := val)).comp (hY j)) hB hB (fun ω => abs_val_le_Bsup _)
      (fun ω => abs_val_le_Bsup _)
  have hpt : ∀ ω, (∑ i ∈ Finset.range n, val (Y i ω)) ^ 2
      = ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, val (Y i ω) * val (Y j ω) := by
    intro ω
    rw [sq, Finset.sum_mul_sum]
  simp only [hpt]
  rw [integral_finsetSum]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [integral_finsetSum]
    · exact Finset.sum_congr rfl fun j _ => hstat i j
    · intro j _
      exact hint i j
  · intro i _
    exact integrable_finsetSum _ (fun j _ => hint i j)

/-- **Crecimiento lineal de la varianza** con coeficiente `σ²_LR`: la parte
"varianza" del CLT de Ibragimov, con tasa geométrica. -/
theorem tendsto_variance_div (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t)) {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ C * ρ ^ k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0)
    (hstat : ∀ i j : ℕ, ∫ ω, val (Y i ω) * val (Y j ω) ∂μ
      = gamma μ val Y (Nat.dist i j)) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ *
        ∫ ω, (∑ i ∈ Finset.range n, val (Y i ω)) ^ 2 ∂μ)
      atTop (𝓝 (sigmaLR μ val Y)) := by
  have hg : ∀ k, |gamma μ val Y k| ≤ (2 * Bsup val * Bsup val * C) * ρ ^ k := by
    intro k
    have h1 := abs_gamma_le (μ := μ) (val := val) (Y := Y) hY hα hm k
    have h2 : 2 * Bsup val * Bsup val * (C * ρ ^ k) = (2 * Bsup val * Bsup val * C) * ρ ^ k := by
      ring
    rw [← h2]
    exact le_trans h1 (mul_le_mul_of_nonneg_left (le_refl _) (by
      have := Bsup_nonneg (val := val); positivity))
  have hC' : 0 ≤ 2 * Bsup val * Bsup val * C := by
    have := Bsup_nonneg (val := val); positivity
  have hmain := tendsto_average_doble (fun k => gamma μ val Y k) hC' hρ0 hρ1 hg
  have hcongr : ∀ n : ℕ, (n : ℝ)⁻¹ * ∑ i ∈ Finset.range n,
        ∑ j ∈ Finset.range n, gamma μ val Y (Nat.dist i j)
      = (n : ℝ)⁻¹ * ∫ ω, (∑ i ∈ Finset.range n, val (Y i ω)) ^ 2 ∂μ := by
    intro n
    rw [variance_eq_doble μ hY hstat n]
  refine hmain.congr' ?_
  filter_upwards with n
  exact hcongr n

end Varianza

/-! ## Independencia asintótica de bloques (lema de bloqueo)

Si `α(σ(Z_0,…,Z_{j−1}), σ(Z_j)) ≤ a j` para todo `j`, entonces para funciones
acotadas `u_j` de cada bloque,

`|E ∏_{j<k} u_j(Z_j) − ∏_{j<k} E u_j(Z_j)| ≤ 2 B^k ∑_{j<k} a_j`.

Es el ingrediente con el que el CLT de Ibragimov sustituye la dependencia entre
bloques por independencia: con `B ≤ 1` el error es `2 ∑_j a_j`, y en el bloqueo de
Bernstein `∑_j a_j ≈ k α(q)` tiende a cero. La prueba es el telescopaje

`E∏_{j<k} f_j − ∏_{j<k} E f_j = ∑_{j<k} (∏_{i>j} E f_i) · Cov(f_j, ∏_{i<j} f_i)`

más la desigualdad de covarianza `abs_integral_mul_sub_le_alphaCoef` aplicada al
bloque pasado completo (una variable finita con valores en `Fin j → S`). -/

section Bloques

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]
variable {Z : ℕ → Ω → S} {u : ℕ → S → ℝ} {B : ℝ}

/-- La variable "bloque pasado" `(Z 0, …, Z (j−1))` es medible. -/
lemma measurable_bloque {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) (j : ℕ) :
    Measurable (fun ω => fun i : Fin j => Z (i : ℕ) ω) := by
  rw [measurable_pi_iff]
  exact fun i => hZ (i : ℕ)

/-- Cota del producto de un bloque por la cota uniforme de sus factores. -/
lemma abs_prod_bloque_le (hB : 0 ≤ B) (hu : ∀ i (s : S), |u i s| ≤ B) (j : ℕ)
    (t : Fin j → S) : |∏ i : Fin j, u (i : ℕ) (t i)| ≤ B ^ j := by
  induction j with
  | zero => simp
  | succ j ih =>
      rw [Fin.prod_univ_castSucc, abs_mul, pow_succ]
      simp only [Fin.val_castSucc, Fin.val_last]
      exact mul_le_mul (ih fun i => t (Fin.castSucc i)) (hu j _) (abs_nonneg _)
        (pow_nonneg hB j)

/-- Norma supremo del producto de un bloque. -/
lemma normSup_prod_bloque_le (hB : 0 ≤ B) (hu : ∀ i (s : S), |u i s| ≤ B) (j : ℕ) :
    normSup (fun t : Fin j → S => ∏ i : Fin j, u (i : ℕ) (t i)) ≤ B ^ j := by
  rw [normSup]
  exact Finset.sup'_le _ _ fun t _ => abs_prod_bloque_le hB hu j t

/-- **Independencia asintótica de bloques.** -/
theorem abs_integral_prod_sub_prod_le (μ : Measure Ω) [IsProbabilityMeasure μ]
    {Z : ℕ → Ω → S} (hZ : ∀ i, Measurable (Z i)) {u : ℕ → S → ℝ} {B : ℝ} (hB : 0 ≤ B)
    (hu : ∀ i (s : S), |u i s| ≤ B) {a : ℕ → ℝ} (ha : ∀ i, 0 ≤ a i)
    (hα : ∀ j, alphaCoef μ (fun ω => fun i : Fin j => Z (i : ℕ) ω) (Z j) ≤ a j) (k : ℕ) :
    |∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
        ∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)|
      ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) := by
  induction k with
  | zero =>
      simp [integral_const]
  | succ k ih =>
      -- descomposición del producto en bloque pasado y bloque nuevo
      have hsplit : ∀ ω, ∏ i : Fin (k + 1), u (i : ℕ) (Z (i : ℕ) ω)
          = (∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω)) * (u k (Z k ω)) := by
        intro ω
        rw [Fin.prod_univ_castSucc]
        simp
      have hsplitE : ∏ i : Fin (k + 1), (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)
          = (∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)) * (∫ ω, u k (Z k ω) ∂μ) := by
        rw [Fin.prod_univ_castSucc]
        simp
      -- la identidad telescópica
      have hkey : ∫ ω, ∏ i : Fin (k + 1), u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
            ∏ i : Fin (k + 1), (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)
          = (∫ ω, (∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω)) * (u k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ) *
                (∫ ω, u k (Z k ω) ∂μ))
            + (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, u k (Z k ω) ∂μ) := by
        simp only [hsplit, hsplitE]
        ring
      rw [hkey]
      -- cota del término de covarianza (bloque pasado vs bloque nuevo)
      have hcov := abs_integral_mul_sub_le_alphaCoef (μ := μ)
        (f := fun ω => fun i : Fin k => Z (i : ℕ) ω) (g := Z k)
        (measurable_bloque hZ k) (hZ k)
        (u := fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i)) (v := u k)
      have hBu : normSup (fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i)) ≤ B ^ k :=
        normSup_prod_bloque_le hB hu k
      have hBv : normSup (u k) ≤ B := by
        rw [normSup]
        exact Finset.sup'_le _ _ fun s _ => hu k s
      have hcov' : |∫ ω, (∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω)) * (u k (Z k ω)) ∂μ -
            (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, u k (Z k ω) ∂μ)|
          ≤ 2 * B ^ k * B * a k := by
        have h1 : alphaCoef μ (fun ω => fun i : Fin k => Z (i : ℕ) ω) (Z k) ≤ a k := hα k
        have h2 : 0 ≤ 2 * normSup (fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i)) *
            normSup (u k) := by
          have h0 := normSup_nonneg (u := fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i))
          have h0' := normSup_nonneg (u := u k)
          exact mul_nonneg (mul_nonneg (by norm_num) h0) h0'
        refine le_trans hcov ?_
        have h3 : 2 * normSup (fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i)) * normSup (u k)
            ≤ 2 * B ^ k * B := by
          have h0 := normSup_nonneg (u := fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i))
          nlinarith [hBu, hBv, hB, h0]
        calc 2 * normSup (fun t : Fin k → S => ∏ i : Fin k, u (i : ℕ) (t i)) * normSup (u k) *
              alphaCoef μ (fun ω => fun i : Fin k => Z (i : ℕ) ω) (Z k)
            ≤ (2 * B ^ k * B) * a k := by
              exact mul_le_mul h3 h1 (alphaCoef_nonneg _ _ _) (by positivity)
          _ = 2 * B ^ k * B * a k := by ring
      -- cota de |∫ bloque nuevo|
      have hQ : |∫ ω, u k (Z k ω) ∂μ| ≤ B := by
        have hint : Integrable (fun ω => u k (Z k ω)) μ := by
          refine Integrable.of_bound
            ((measurable_val (val := u k)).comp (hZ k)).aestronglyMeasurable B ?_
          filter_upwards with ω
          rw [Real.norm_eq_abs]
          exact hu k (Z k ω)
        refine le_trans (abs_integral_le_integral_abs (f := fun ω => u k (Z k ω))) ?_
        have hle : ∫ ω, |u k (Z k ω)| ∂μ ≤ ∫ _ω : Ω, B ∂μ := by
          refine integral_mono (hint.abs) (integrable_const B) (fun ω => hu k _)
        refine le_trans hle ?_
        rw [integral_const, measureReal_univ_eq_one, one_smul]
      -- cota del término inductivo
      have hI : |∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
            ∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)| ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) :=
        ih
      have hIHnn : 0 ≤ 2 * B ^ k * ∑ i : Fin k, a (i : ℕ) := by
        refine mul_nonneg (by positivity) ?_
        exact Finset.sum_nonneg fun i _ => ha (i : ℕ)
      calc |(∫ ω, (∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω)) * (u k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, u k (Z k ω) ∂μ))
            + (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, u k (Z k ω) ∂μ)|
          ≤ |∫ ω, (∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω)) * (u k (Z k ω)) ∂μ -
              (∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ) * (∫ ω, u k (Z k ω) ∂μ)|
            + |(∫ ω, ∏ i : Fin k, u (i : ℕ) (Z (i : ℕ) ω) ∂μ -
                ∏ i : Fin k, (∫ ω, u (i : ℕ) (Z (i : ℕ) ω) ∂μ)) *
              (∫ ω, u k (Z k ω) ∂μ)| := abs_add_le _ _
        _ ≤ (2 * B ^ k * B * a k) + (2 * B ^ k * ∑ i : Fin k, a (i : ℕ)) * B := by
            refine add_le_add hcov' ?_
            rw [abs_mul]
            exact mul_le_mul hI hQ (abs_nonneg _) hIHnn
        _ = 2 * B ^ (k + 1) * ∑ i : Fin (k + 1), a (i : ℕ) := by
            rw [Fin.sum_univ_castSucc, pow_succ]
            simp only [Fin.val_castSucc, Fin.val_last]
            ring

end Bloques

/-! ## Cierre del pendiente `C.thm:appD-ibragimov`: paquete cuantitativo anclado

Este bloque reúne, con la clave del libro en el docstring, el contenido del teorema
`thm:appD-ibragimov` que es formalizable hoy: la desigualdad de covarianza de
Ibragimov–Davydov (`abs_integral_mul_sub_le_alphaCoef`), la sumabilidad absoluta de
las autocovarianzas bajo las hipótesis de mezcla (`summable_abs_gamma_of_rpow`, que
usa literalmente la condición (2) del libro, y `summable_abs_gamma_geometric` para
mezcla geométrica), la identificación de la varianza de largo plazo con el límite
`n⁻¹ Var(S_n) → σ²_LR` (lema de Bernstein, `tendsto_variance_div`) y la independencia
asintótica de bloques que sustituye la independencia en el paso de Lindeberg. -/

section Cierre

variable {S : Type*} [Fintype S] [Nonempty S] [DecidableEq S] [MeasurableSpace S]
  [MeasurableSingletonClass S]
variable {val : S → ℝ} {Y : ℕ → Ω → S}

/-- `σ²_LR ≥ 0`: es el límite de las varianzas `n⁻¹ Var(S_n)`. -/
theorem sigmaLR_nonneg (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t)) {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ C * ρ ^ k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0)
    (hstat : ∀ i j : ℕ, ∫ ω, val (Y i ω) * val (Y j ω) ∂μ = gamma μ val Y (Nat.dist i j)) :
    0 ≤ sigmaLR μ val Y := by
  have hlim := tendsto_variance_div (μ := μ) (val := val) (Y := Y) hY hC hρ0 hρ1 hα hm hstat
  refine le_of_tendsto_of_tendsto
    (tendsto_const_nhds : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0))
    hlim (Eventually.of_forall fun n => ?_)
  refine mul_nonneg (by positivity) ?_
  exact integral_nonneg fun ω => sq_nonneg _

/-- Sumabilidad absoluta de las autocovarianzas bajo mezcla geométrica
`α(t,t+k) ≤ C ρ^k`, la forma que el libro usa en `cor:appD-clt-mdp`. -/
theorem summable_abs_gamma_geometric (μ : Measure Ω) [IsProbabilityMeasure μ]
    (hY : ∀ t, Measurable (Y t)) {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ C * ρ ^ k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0) :
    Summable fun k => |gamma μ val Y k| := by
  have habs : ‖ρ‖ < 1 := by
    rw [Real.norm_eq_abs, abs_of_nonneg hρ0]; exact hρ1
  exact summable_abs_gamma μ hY ((summable_geometric_of_norm_lt_one habs).mul_left C)
    (fun k => mul_nonneg hC (pow_nonneg hρ0 k)) hα hm

/-- book: apendices/apendice_regularidad.typ:116 (key: thm:appD-ibragimov) —
**CLT de Ibragimov para procesos α-mixing: núcleo cuantitativo completo.**

Sea `{X_t = val ∘ Y_t}` un proceso estacionario de segundo orden (`hstat`), centrado
(`hm`), con coeficientes de mezcla α acotados por `C ρ^k` (mezcla geométrica, el caso
de los MDP finitos del libro, `cor:appD-clt-mdp`). Entonces

* `∑_k |γ(k)| < ∞`, de modo que la varianza de largo plazo
  `σ²_LR = γ(0) + 2 ∑_{k≥1} γ(k)` del libro está bien definida (suma absolutamente
  convergente);
* el lema de Bernstein da `n⁻¹ Var(∑_{t<n} X_t) → σ²_LR`, o sea que la varianza de
  la suma parcial crece como `n σ²_LR`;
* `σ²_LR ≥ 0`.

**Fidelidad declarada.** Se formaliza el núcleo cuantitativo del teorema del libro
(desigualdad de covarianza de Ibragimov–Davydov, decaimiento y sumabilidad de las
autocovarianzas, identificación de `σ²_LR` como límite de `n⁻¹ Var(S_n)` e
independencia asintótica de bloques, `abs_integral_prod_sub_prod_le`). La conclusión
distribucional `n^{-1/2} ∑_{t≤n} X_t →d N(0, σ²_LR)` no se reproduce: Mathlib no
contiene un CLT para sucesiones mezclantes, y el paso que falta es exactamente el
citado sin prueba por el libro (Lindeberg–Feller sobre los bloques de Bernstein más
continuidad de Lévy). El modelo es el del libro para estados finitos: cada `X_t` toma
valores en un tipo finito `S` con `MeasurableSingletonClass` (en particular la
condición de momentos `E|X_t|^{2+δ} < ∞` es automática y la cota de covarianza
`|Cov| ≤ 2‖u‖∞‖v‖∞α` es la de Ibragimov 1962/Davydov 1968); el coeficiente α usado es
la forma suma `alphaSum` sobre particiones finitas, que domina el supremo del libro
sobre rectángulos (`alphaRect_le_alphaCoef`). Bajo la condición (2) literal del libro
`∑_k α(k)^{δ/(2+δ)} < ∞` la sumabilidad de `γ` ya está probada en
`summable_abs_gamma_of_rpow`. -/
theorem thm_appD_ibragimov (μ : Measure Ω) [IsProbabilityMeasure μ] {Y : ℕ → Ω → S}
    (hY : ∀ t, Measurable (Y t)) {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hα : ∀ t k, alphaCoef μ (Y t) (Y (t + k)) ≤ C * ρ ^ k)
    (hm : ∀ t, ∫ ω, val (Y t ω) ∂μ = 0)
    (hstat : ∀ i j : ℕ, ∫ ω, val (Y i ω) * val (Y j ω) ∂μ = gamma μ val Y (Nat.dist i j)) :
    Summable (fun k => |gamma μ val Y k|) ∧
      Tendsto (fun n : ℕ => (n : ℝ)⁻¹ *
        ∫ ω, (∑ i ∈ Finset.range n, val (Y i ω)) ^ 2 ∂μ) atTop (𝓝 (sigmaLR μ val Y)) ∧
      0 ≤ sigmaLR μ val Y :=
  ⟨summable_abs_gamma_geometric μ hY hC hρ0 hρ1 hα hm,
   tendsto_variance_div μ hY hC hρ0 hρ1 hα hm hstat,
   sigmaLR_nonneg μ hY hC hρ0 hρ1 hα hm hstat⟩

end Cierre

end Book.ApendiceDIbragimov
