import Mathlib

/-!
# Book.ApendiceDHac — Consistencia del estimador HAC de Newey–West

Formalización de `apendices/apendice_regularidad.typ` claves `def:appD-hac` y
`thm:appD-hac-consistencia` (y del mismo resultado en `cap08_intervalos.typ`,
`thm:ch11-var-consistente`).

## Fidelidad declarada

El libro define, para una serie estrictamente estacionaria `(X_t)` con
autocovarianzas `γ_k = Cov(X_0, X_k)` y ancho de banda `K_n`,

* `σ²_LR = γ_0 + 2∑_{k≥1} γ_k` (varianza de largo plazo),
* `σ̂²_HAC = γ̂_0 + 2∑_{k=1}^{K_n} w(k/K_n) γ̂_k` con `w(x) = 1 - x` (Bartlett),
  `γ̂_k = (1/n)∑_{t=k+1}^n (X_t - X̄)(X_{t-k} - X̄)`,

y demuestra `σ̂²_HAC →^P σ²_LR` bajo sumabilidad absoluta de `γ`, `K_n → ∞`,
`K_n/n → 0` y la condición agregada `∑_{k=0}^{K_n}|γ̂_k - γ_k| →^P 0`.

Aquí:

* los pesos son `bartlett x = max 0 (1 - x)`, que coincide con `1 - x` en
  `[0,1]` (`bartlett_eq_one_sub`), de modo que la fórmula del libro es la
  definición `hacBartlett`;
* `σ²_LR` es literalmente `γ_0 + 2∑'_{k≥1} γ_k` (`sigmaLR`), y se prueba que la
  serie converge absolutamente (`abs_sigmaLR_le`);
* la condición agregada de covarianzas del libro se toma como **hipótesis**
  (`TendstoInMeasure μ (fun n ω => errorAcum …) … 0`), que es exactamente el
  lugar donde el libro la exige («la condición agregada de covarianzas debe
  demostrarse para el proceso»); no se deriva de estacionariedad + mixing, que
  queda declarado como obligación separada en `DEUDA.md`;
* la conclusión es `TendstoInMeasure` con la medida de probabilidad `μ`, es
  decir convergencia en probabilidad `→^P` del libro, no una versión
  determinista; además hay un teorema determinista (`hac_tendsto`) con la misma
  cota, útil para encadenar con cotas de sesgo de las autocovarianzas;
* la cota de sesgo se da también en forma explícita para decaimiento
  geométrico `|γ_k| ≤ C ρ^k` (`hac_diff_bound_geometrico`), que es el régimen
  de las cadenas finitas de `C.thm:appD-ergodico`.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

open Finset BigOperators Filter MeasureTheory
open scoped Topology

namespace Book.ApendiceDHac

/-! ## Pesos de Bartlett, varianza de largo plazo y estimador HAC -/

/-- Peso de Bartlett `w(x) = max 0 (1 - x)`; en `[0,1]` es `1 - x`, como en
`def:appD-hac`. -/
def bartlett (x : ℝ) : ℝ := max 0 (1 - x)

lemma bartlett_nonneg (x : ℝ) : 0 ≤ bartlett x := le_max_left 0 (1 - x)

lemma bartlett_eq_one_sub {x : ℝ} (h1 : x ≤ 1) : bartlett x = 1 - x :=
  max_eq_right (by linarith)

lemma bartlett_le_one {x : ℝ} (h0 : 0 ≤ x) : bartlett x ≤ 1 := by
  rcases le_total x 1 with h1 | h1
  · rw [bartlett_eq_one_sub h1]; linarith
  · unfold bartlett
    rw [max_eq_left (by linarith)]
    linarith

lemma bartlett_zero : bartlett 0 = 1 := by
  simp [bartlett]

lemma bartlett_one : bartlett 1 = 0 := by
  simp [bartlett]

/-- `|w(x) - 1| ≤ 1` para `x ∈ [0,1]`. -/
lemma abs_bartlett_sub_one_le_one {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    |bartlett x - 1| ≤ 1 := by
  rw [bartlett_eq_one_sub h1, show 1 - x - 1 = -x by ring, abs_neg, abs_of_nonneg h0]
  linarith

/-- **Varianza de largo plazo** (`def:appD-hac` / `def:ch11-hac`):
`σ²_LR = γ_0 + 2∑_{k≥1} γ_k`. -/
noncomputable def sigmaLR (γ : ℕ → ℝ) : ℝ := γ 0 + 2 * ∑' k : ℕ, γ (k + 1)

/-- **Estimador HAC de Newey–West** (`def:appD-hac`) con kernel de Bartlett y
ancho de banda `K`:
`σ̂²_HAC = γ̂_0 + 2∑_{k=1}^{K} w(k/K) γ̂_k`. -/
noncomputable def hacBartlett (K : ℕ) (γhat : ℕ → ℝ) : ℝ :=
  γhat 0 + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γhat (k + 1)

/-- **Error de estimación agregado** `∑_{k=0}^{K}|γ̂_k - γ_k|`, la condición
agregada de covarianzas del libro. -/
def errorAcum (K : ℕ) (γhat γ : ℕ → ℝ) : ℝ := ∑ k ∈ range (K + 1), |γhat k - γ k|

/-- **Cola de la varianza de largo plazo**: `∑_{k≥K+1} γ_k`. -/
noncomputable def cola (γ : ℕ → ℝ) (K : ℕ) : ℝ := ∑' k : ℕ, γ (k + (K + 1))

/-! ## Sumabilidad y colas -/

/-- Si `γ` es sumable, la serie desplazada `k ↦ γ (k+1)` también. -/
lemma summable_shift {γ : ℕ → ℝ} (h : Summable γ) : Summable fun k => γ (k + 1) :=
  h.comp_injective (fun a b hab => Nat.succ_injective hab)

lemma summable_abs_shift {γ : ℕ → ℝ} (h : Summable γ) : Summable fun k => |γ (k + 1)| :=
  (summable_shift h).abs

/-- La varianza de largo plazo está bien definida y acotada por la serie de
valores absolutos: `|σ²_LR| ≤ |γ_0| + 2∑_k |γ_{k+1}|`. -/
theorem abs_sigmaLR_le {γ : ℕ → ℝ} (h : Summable γ) :
    |sigmaLR γ| ≤ |γ 0| + 2 * ∑' k : ℕ, |γ (k + 1)| := by
  have hsum : Summable fun k : ℕ => γ (k + 1) := summable_shift h
  have hsumabs : Summable fun k : ℕ => |γ (k + 1)| := summable_abs_shift h
  have hS : ∑' k : ℕ, γ (k + 1) ≤ ∑' k : ℕ, |γ (k + 1)| :=
    hsum.tsum_le_tsum (fun k => le_abs_self _) hsumabs
  have hS' : -(∑' k : ℕ, γ (k + 1)) ≤ ∑' k : ℕ, |γ (k + 1)| := by
    have hneg : ∑' k : ℕ, -(γ (k + 1)) ≤ ∑' k : ℕ, |γ (k + 1)| :=
      hsum.neg.tsum_le_tsum (fun k => neg_le_abs _) hsumabs
    rwa [tsum_neg] at hneg
  have h2 : |∑' k : ℕ, γ (k + 1)| ≤ ∑' k : ℕ, |γ (k + 1)| :=
    abs_le.2 ⟨by linarith, hS⟩
  have h3 : |sigmaLR γ| ≤ |γ 0| + 2 * |∑' k : ℕ, γ (k + 1)| := by
    have h4 : |γ 0 + 2 * ∑' k : ℕ, γ (k + 1)| ≤ |γ 0| + |2 * ∑' k : ℕ, γ (k + 1)| :=
      abs_add_le _ _
    rw [abs_mul] at h4
    norm_num at h4
    simpa [sigmaLR] using h4
  linarith

/-- La cola `∑_{k≥K+1} γ_k` tiende a cero: es el «término de cola omitida» del
libro. -/
theorem tendsto_cola {γ : ℕ → ℝ} : Tendsto (cola γ) atTop (𝓝 0) := by
  have h1 : Tendsto (fun K : ℕ => ∑' k : ℕ, γ (k + (K + 1))) atTop (𝓝 0) := by
    have h0 := (tendsto_sum_nat_add γ).comp (tendsto_add_atTop_nat 1)
    simpa only [Function.comp_def] using h0
  exact h1

/-- La cola en valor absoluto tiende a cero. -/
theorem tendsto_abs_cola {γ : ℕ → ℝ} :
    Tendsto (fun K : ℕ => ∑' i : ℕ, |γ (i + (K + 1))|) atTop (𝓝 0) := by
  have h0 := (tendsto_sum_nat_add (fun k : ℕ => |γ k|)).comp (tendsto_add_atTop_nat 1)
  simpa only [Function.comp_def] using h0

/-- `|∑' f| ≤ ∑' |f|` para series reales. -/
lemma abs_tsum_le_tsum_abs {f : ℕ → ℝ} (hf : Summable f) :
    |∑' k : ℕ, f k| ≤ ∑' k : ℕ, |f k| := by
  have hfabs : Summable fun k : ℕ => |f k| := hf.abs
  have h1 : ∑' k : ℕ, f k ≤ ∑' k : ℕ, |f k| :=
    hf.tsum_le_tsum (fun k => le_abs_self _) hfabs
  have h2 : -(∑' k : ℕ, f k) ≤ ∑' k : ℕ, |f k| := by
    have hneg : ∑' k : ℕ, -(f k) ≤ ∑' k : ℕ, |f k| :=
      hf.neg.tsum_le_tsum (fun k => neg_le_abs _) hfabs
    rwa [tsum_neg] at hneg
  exact abs_le.2 ⟨by linarith, h1⟩

/-- Desplazamiento de una serie sumable: `∑ |γ_{k+m}| < ∞`. -/
lemma summable_shift_add {γ : ℕ → ℝ} (h : Summable γ) (m : ℕ) :
    Summable fun k => γ (k + m) :=
  h.comp_injective (fun a b hab => Nat.add_right_cancel hab)

/-! ## Los pesos convergen a uno en cada rezago fijo -/

/-- Para un rezago fijo `k`, el peso de Bartlett tiende a `1` cuando el ancho de
banda tiende a infinito («convergencia de los pesos a uno en cada rezago fijo»,
prueba del libro). -/
lemma tendsto_bartlett_weight {K : ℕ → ℕ} (hK : Tendsto K atTop atTop) (k : ℕ) :
    Tendsto (fun n => bartlett ((k + 1 : ℝ) / (K n : ℝ))) atTop (𝓝 1) := by
  have hdiv : Tendsto (fun n : ℕ => ((k : ℝ) + 1) / (K n : ℝ)) atTop (𝓝 0) := by
    have h := (tendsto_const_div_atTop_nhds_zero_nat ((k : ℝ) + 1)).comp hK
    simpa only [Function.comp_def] using h
  have hge : ∀ᶠ n in atTop, k + 1 ≤ K n := hK.eventually (eventually_ge_atTop (k + 1))
  have hev : ∀ᶠ n in atTop,
      bartlett ((k + 1 : ℝ) / (K n : ℝ)) = 1 - ((k : ℝ) + 1) / (K n : ℝ) := by
    filter_upwards [hge] with n hn
    refine bartlett_eq_one_sub ?_
    rw [div_le_one (by exact_mod_cast (Nat.lt_of_lt_of_le (Nat.succ_pos k) hn))]
    exact_mod_cast hn
  have hone : Tendsto (fun n : ℕ => 1 - ((k : ℝ) + 1) / (K n : ℝ)) atTop (𝓝 1) := by
    have h1 : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
    have h := h1.sub hdiv
    simpa using h
  exact (tendsto_congr' hev).2 hone

/-- **Sesgo de ponderación de Bartlett** (`thm:appD-hac-consistencia`, tercer
término de la descomposición): con pesos en `[0,1]` que convergen a `1` en cada
rezago fijo, `∑_{k=1}^{K_n} w(k/K_n) γ_k → ∑_{k≥1} γ_k`. -/
theorem tendsto_weighted_sum {γ : ℕ → ℝ} (hγ : Summable γ) {K : ℕ → ℕ}
    (hK : Tendsto K atTop atTop) :
    Tendsto (fun n => ∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1))
      atTop (𝓝 (∑' k : ℕ, γ (k + 1))) := by
  set a : ℕ → ℝ := fun k => |γ (k + 1)| with ha
  have ha_sum : Summable a := summable_abs_shift hγ
  have htail : Tendsto (fun M : ℕ => ∑' i : ℕ, a (i + M)) atTop (𝓝 0) := tendsto_sum_nat_add a
  rw [Metric.tendsto_atTop]
  intro ε hε
  have hε4 : (0 : ℝ) < ε / 4 := by linarith
  -- (1) punto de corte con cola pequeña
  obtain ⟨M, hM⟩ : ∃ M : ℕ, ∑' i : ℕ, a (i + M) ≤ ε / 4 :=
    (htail.eventually (eventually_le_nhds hε4)).exists
  -- (2) los primeros `M` rezagos aportan poco
  have hF : Tendsto
      (fun n => ∑ k ∈ range M, |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k)
      atTop (𝓝 0) := by
    have hterm : ∀ k ∈ range M,
        Tendsto (fun n => |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k) atTop (𝓝 0) := by
      intro k _
      have h1 : Tendsto (fun n => bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) atTop (𝓝 (1 - 1)) :=
        (tendsto_bartlett_weight hK k).sub_const 1
      have h2 : Tendsto (fun n => |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1|) atTop (𝓝 |1 - 1|) :=
        h1.abs
      have h3 := h2.mul_const (a k)
      simpa using h3
    have h4 := tendsto_finsetSum (range M) hterm
    simpa using h4
  have hFev : ∀ᶠ n in atTop,
      ∑ k ∈ range M, |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k ≤ ε / 4 :=
    hF.eventually (eventually_le_nhds hε4)
  have htailK : ∀ᶠ n in atTop, ∑' i : ℕ, a (i + K n) ≤ ε / 4 := by
    have h := (htail.comp hK).eventually (eventually_le_nhds hε4)
    simpa only [Function.comp_def] using h
  have hKge : ∀ᶠ n in atTop, M ≤ K n := hK.eventually (eventually_ge_atTop M)
  have hK1 : ∀ᶠ n in atTop, 1 ≤ K n := hK.eventually (eventually_ge_atTop 1)
  refine eventually_atTop.1 ?_
  filter_upwards [hFev, htailK, hKge, hK1] with n hFn htn hMn hK1n
  have hγ1 : Summable fun k : ℕ => γ (k + 1) := summable_shift hγ
  -- descomposición `∑ w_k γ_k - ∑' γ_k = ∑ (w_k - 1) γ_k - cola`
  have hsplit := Summable.sum_add_tsum_nat_add (f := fun k : ℕ => γ (k + 1)) (K n) hγ1
  simp only [Nat.add_assoc] at hsplit
  have hcola : ∑' i : ℕ, γ (i + (K n + 1)) = -(∑ k ∈ range (K n), γ (k + 1)) + ∑' k : ℕ, γ (k + 1) := by
    linarith
  -- cota del error de pesos
  have hdiff : ∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)
      = ∑ k ∈ range (K n), (bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) * γ (k + 1)
        - ∑' i : ℕ, γ (i + (K n + 1)) := by
    have hsub : ∑ k ∈ range (K n), (bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) * γ (k + 1)
        = ∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1)
          - ∑ k ∈ range (K n), γ (k + 1) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun k _ => by ring)
    rw [hsub]
    linarith
  have habs : |∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)|
      ≤ ε / 4 + ε / 4 + ε / 4 := by
    rw [hdiff]
    have h1 : |∑ k ∈ range (K n), (bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) * γ (k + 1)|
        ≤ ∑ k ∈ range (K n), |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k := by
      refine le_trans (abs_sum_le_sum_abs _ _) (le_of_eq ?_)
      apply Finset.sum_congr rfl
      intro k _
      rw [abs_mul]
    have h2 : ∑ k ∈ range (K n), |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k ≤ ε / 4 + ε / 4 := by
      set g : ℕ → ℝ := fun k => |bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1| * a k with hg
      have hb : ∑ k ∈ range (K n - M), g (M + k) ≤ ∑ k ∈ range (K n - M), a (M + k) := by
        apply Finset.sum_le_sum
        intro k hk
        have hkle : ((M + k) + 1 : ℕ) ≤ K n := by
          simp only [mem_range] at hk
          omega
        have hw : |bartlett (((M + k) + 1 : ℝ) / (K n : ℝ)) - 1| ≤ 1 := by
          refine abs_bartlett_sub_one_le_one (by positivity) ?_
          rw [div_le_one (by positivity)]
          exact_mod_cast hkle
        calc g (M + k) = |bartlett (((M + k) + 1 : ℝ) / (K n : ℝ)) - 1| * a (M + k) := by
              simp only [hg, Nat.cast_add]
          _ ≤ 1 * a (M + k) := mul_le_mul_of_nonneg_right hw (abs_nonneg _)
          _ = a (M + k) := one_mul _
      have hsummable : Summable fun k : ℕ => a (M + k) := by
        have h := summable_shift_add ha_sum M
        simpa [Nat.add_comm] using h
      have hlast : ∑ k ∈ range (K n - M), a (M + k) ≤ ∑' i : ℕ, a (i + M) := by
        refine le_trans (hsummable.sum_le_tsum (range (K n - M)) (fun i _ => abs_nonneg _)) ?_
        exact le_of_eq (tsum_congr (fun i => by rw [Nat.add_comm]))
      have hsplitg : ∑ k ∈ range (K n), g k
          = ∑ k ∈ range M, g k + ∑ k ∈ range (K n - M), g (M + k) := by
        conv_lhs => rw [show K n = M + (K n - M) from (Nat.add_sub_of_le hMn).symm]
        rw [Finset.sum_range_add]
      have hfirst : ∑ k ∈ range M, g k ≤ ε / 4 := hFn
      change ∑ k ∈ range (K n), g k ≤ ε / 4 + ε / 4
      rw [hsplitg]
      linarith
    have h3 : |∑' i : ℕ, γ (i + (K n + 1))| ≤ ∑' i : ℕ, a (i + K n) := by
      have hsum : Summable fun i : ℕ => γ (i + (K n + 1)) := summable_shift_add hγ (K n + 1)
      refine le_trans (abs_tsum_le_tsum_abs hsum) (le_of_eq ?_)
      apply tsum_congr
      intro i
      simp only [a, Nat.add_assoc]
    have h4 : |∑ k ∈ range (K n), (bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) * γ (k + 1)
        - ∑' i : ℕ, γ (i + (K n + 1))|
        ≤ |∑ k ∈ range (K n), (bartlett ((k + 1 : ℝ) / (K n : ℝ)) - 1) * γ (k + 1)|
          + |∑' i : ℕ, γ (i + (K n + 1))| := abs_sub _ _
    linarith
  rw [Real.dist_eq]
  linarith

/-! ## Descomposición del error: estimación, cola y sesgo de ponderación -/

/-- **Cota puntual del error del estimador HAC.** Para `K ≥ 1`,
`|σ̂²_HAC(K) - σ²_LR| ≤ 3 ∑_{k=0}^{K}|γ̂_k - γ_k| + 2 |∑_{k=1}^{K} w(k/K)γ_k - ∑_{k≥1}γ_k|`.
El primer sumando es el error de estimación de las covarianzas, el segundo agrupa
la cola omitida y el sesgo de ponderación de Bartlett (prueba del libro de
`thm:appD-hac-consistencia`). -/
theorem hac_diff_bound (γ γhat : ℕ → ℝ) {K : ℕ} (hK : 1 ≤ K) :
    |hacBartlett K γhat - sigmaLR γ| ≤
      3 * errorAcum K γhat γ +
        2 * |∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
              - ∑' k : ℕ, γ (k + 1)| := by
  have hKpos : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hK
  have hw0 : ∀ k : ℕ, 0 ≤ bartlett ((k + 1 : ℝ) / (K : ℝ)) := fun k => bartlett_nonneg _
  have hw1 : ∀ k : ℕ, bartlett ((k + 1 : ℝ) / (K : ℝ)) ≤ 1 := fun k =>
    bartlett_le_one (div_nonneg (by positivity) (le_of_lt hKpos))
  -- (0) reescritura del error
  have hEq : hacBartlett K γhat - sigmaLR γ
      = ((γhat 0 - γ 0)
          + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1)))
        + 2 * (∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
            - ∑' k : ℕ, γ (k + 1)) := by
    have hsum : ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))
        = ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γhat (k + 1)
          - ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun k _ => by ring)
    rw [hsum]
    simp only [hacBartlett, sigmaLR]
    ring
  -- (1) error de estimación del lag 0
  have h1 : |γhat 0 - γ 0| ≤ errorAcum K γhat γ := by
    have h := Finset.single_le_sum (f := fun k => |γhat k - γ k|)
      (fun k (_ : k ∈ range (K + 1)) => abs_nonneg _) (Finset.mem_range.2 (Nat.succ_pos K) : 0 ∈ range (K + 1))
    simpa only [errorAcum] using h
  -- (2) error de estimación de los lags 1..K, con pesos en [0,1]
  have h2 : |∑ k ∈ range K,
        bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))|
      ≤ errorAcum K γhat γ := by
    refine le_trans (abs_sum_le_sum_abs _ _) ?_
    have hstep : ∑ k ∈ range K,
          |bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))|
        = ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * |γhat (k + 1) - γ (k + 1)| := by
      apply Finset.sum_congr rfl
      intro k _
      rw [abs_mul, abs_of_nonneg (hw0 k)]
    rw [hstep]
    have h3 : ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * |γhat (k + 1) - γ (k + 1)|
        ≤ ∑ k ∈ range K, |γhat (k + 1) - γ (k + 1)| := by
      apply Finset.sum_le_sum
      intro k _
      calc bartlett ((k + 1 : ℝ) / (K : ℝ)) * |γhat (k + 1) - γ (k + 1)|
          ≤ 1 * |γhat (k + 1) - γ (k + 1)| :=
            mul_le_mul_of_nonneg_right (hw1 k) (abs_nonneg _)
        _ = |γhat (k + 1) - γ (k + 1)| := one_mul _
    refine le_trans h3 ?_
    have h4 := Finset.sum_range_succ' (fun k => |γhat k - γ k|) K
    simp only [errorAcum]
    rw [h4]
    have h5 : (0 : ℝ) ≤ |γhat 0 - γ 0| := abs_nonneg _
    linarith
  -- (3) sesgo de ponderación
  have h3 : |2 * (∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
        - ∑' k : ℕ, γ (k + 1))|
      = 2 * |∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
          - ∑' k : ℕ, γ (k + 1)| := by
    rw [abs_mul]
    norm_num
  rw [hEq]
  have hstep1 : |(γhat 0 - γ 0)
        + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))|
      ≤ |γhat 0 - γ 0| + 2 * |∑ k ∈ range K,
          bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))| := by
    have h := abs_add_le (γhat 0 - γ 0)
      (2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1)))
    have h2' : |2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))|
        = 2 * |∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))| := by
      rw [abs_mul]
      norm_num
    linarith
  have hstep2 : |((γhat 0 - γ 0)
        + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1)))
        + 2 * (∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
            - ∑' k : ℕ, γ (k + 1))|
      ≤ |(γhat 0 - γ 0)
          + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1))|
        + 2 * |∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
            - ∑' k : ℕ, γ (k + 1)| := by
    have h := abs_add_le ((γhat 0 - γ 0)
        + 2 * ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * (γhat (k + 1) - γ (k + 1)))
      (2 * (∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
        - ∑' k : ℕ, γ (k + 1)))
    rw [h3] at h
    linarith
  linarith

/-! ## Consistencia: forma determinista -/

/-- **`thm:appD-hac-consistencia` (forma determinista).** Si las autocovarianzas
son absolutamente sumables, `K_n → ∞`, `K_n/n → 0` y el error agregado de
estimación de las covarianzas tiende a cero, entonces el estimador HAC converge
a la varianza de largo plazo. La hipótesis `K_n/n → 0` es la del libro; en esta
versión no se usa porque la condición agregada de covarianzas se supone
directamente (es donde el libro la emplea). -/
theorem hac_tendsto (γ : ℕ → ℝ) (γhat : ℕ → ℕ → ℝ) (K : ℕ → ℕ)
    (hsum : Summable γ) (hK : Tendsto K atTop atTop)
    (hKsub : Tendsto (fun n => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (herr : Tendsto (fun n => errorAcum (K n) (γhat n) γ) atTop (𝓝 0)) :
    Tendsto (fun n => hacBartlett (K n) (γhat n) - sigmaLR γ) atTop (𝓝 0) := by
  have hbias : Tendsto (fun n => ∑ k ∈ range (K n),
        bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1))
      atTop (𝓝 0) := by
    have h := (tendsto_weighted_sum hsum hK).sub_const (∑' k : ℕ, γ (k + 1))
    simpa using h
  have hupper : Tendsto (fun n => 3 * errorAcum (K n) (γhat n) γ
        + 2 * |∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1)
            - ∑' k : ℕ, γ (k + 1)|) atTop (𝓝 0) := by
    have h1 := herr.const_mul 3
    have h2 := hbias.abs.const_mul 2
    have h := h1.add h2
    simpa using h
  have hle : ∀ᶠ n in atTop, |hacBartlett (K n) (γhat n) - sigmaLR γ| ≤
      3 * errorAcum (K n) (γhat n) γ
        + 2 * |∑ k ∈ range (K n), bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1)
            - ∑' k : ℕ, γ (k + 1)| := by
    filter_upwards [hK.eventually (eventually_ge_atTop 1)] with n hn
    exact hac_diff_bound γ (γhat n) hn
  rw [tendsto_iff_norm_sub_tendsto_zero]
  have hgoal : (fun n => ‖(hacBartlett (K n) (γhat n) - sigmaLR γ) - 0‖)
      = fun n => |hacBartlett (K n) (γhat n) - sigmaLR γ| := by
    funext n
    rw [sub_zero, Real.norm_eq_abs]
  rw [hgoal]
  exact squeeze_zero' (Eventually.of_forall fun n => abs_nonneg _) hle hupper

/-! ## Convergencia en probabilidad (`→^P`) -/

/-- Si `|f n ω| ≤ g n` con `g n → 0`, entonces `f n → 0` en probabilidad. -/
lemma tendstoInMeasure_of_abs_le {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    {f : ℕ → Ω → ℝ} {g : ℕ → ℝ} (hg : Tendsto g atTop (𝓝 0)) (hg0 : ∀ n, 0 ≤ g n)
    (h : ∀ᶠ n in atTop, ∀ ω, |f n ω| ≤ g n) :
    TendstoInMeasure μ f atTop (fun _ => 0) := by
  rw [tendstoInMeasure_iff_norm]
  intro ε hε
  have hev : ∀ᶠ n in atTop, ‖g n‖ < ε := by
    have h' := hg.eventually (eventually_lt_nhds hε)
    filter_upwards [h'] with n hn
    simpa [Real.norm_eq_abs, abs_of_nonneg (hg0 n)] using hn
  have heq : (fun _ : ℕ => (0 : ENNReal)) =ᶠ[atTop]
      (fun n => μ {x : Ω | ε ≤ ‖f n x - (0 : ℝ)‖}) := by
    filter_upwards [hev, h] with n hn hle
    have hempty : {x : Ω | ε ≤ ‖f n x - (0 : ℝ)‖} = ∅ := by
      ext x
      simp only [Set.mem_ofPred_eq, Set.mem_empty_iff_false, iff_false, not_le]
      calc ‖f n x - 0‖ = |f n x| := by rw [sub_zero, Real.norm_eq_abs]
        _ ≤ g n := hle x
        _ = ‖g n‖ := by rw [Real.norm_eq_abs, abs_of_nonneg (hg0 n)]
        _ < ε := hn
    rw [hempty, measure_empty]
  exact Tendsto.congr' heq tendsto_const_nhds

/-- **`thm:appD-hac-consistencia`** (y `thm:ch11-var-consistente`): para el kernel
de Bartlett, si las autocovarianzas son absolutamente sumables, `K_n → ∞`,
`K_n/n → 0` y la condición agregada de covarianzas `∑_{k=0}^{K_n}|γ̂_k - γ_k| →^P 0`
se cumple, entonces el estimador HAC converge en probabilidad a la varianza de
largo plazo `σ²_LR`. -/
theorem hac_consistencia {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ]
    (γ : ℕ → ℝ) (γhat : ℕ → Ω → ℕ → ℝ) (K : ℕ → ℕ)
    (hsum : Summable γ) (hK : Tendsto K atTop atTop)
    (hKsub : Tendsto (fun n => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (herr : TendstoInMeasure μ (fun n ω => errorAcum (K n) (γhat n ω) γ) atTop (fun _ => 0)) :
    TendstoInMeasure μ (fun n ω => hacBartlett (K n) (γhat n ω) - sigmaLR γ)
      atTop (fun _ => 0) := by
  have hbias : Tendsto (fun n => |∑ k ∈ range (K n),
        bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)|)
      atTop (𝓝 0) := by
    have h := (tendsto_weighted_sum hsum hK).sub_const (∑' k : ℕ, γ (k + 1))
    have h2 := h.abs
    simpa using h2
  rw [tendstoInMeasure_iff_measureReal_norm]
  intro ε hε
  -- el sesgo de ponderación de Bartlett es despreciable
  have hbev : ∀ᶠ n in atTop, 2 * |∑ k ∈ range (K n),
        bartlett ((k + 1 : ℝ) / (K n : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)| ≤ ε / 2 := by
    have h := hbias.eventually (eventually_le_nhds (show (0 : ℝ) < ε / 4 by linarith))
    filter_upwards [h] with n hn
    linarith
  -- la condición agregada de covarianzas, con umbral `ε/6`
  have hmeas : Tendsto (fun n => μ.real {x : Ω | ε / 6 ≤ ‖errorAcum (K n) (γhat n x) γ - 0‖})
      atTop (𝓝 0) :=
    (tendstoInMeasure_iff_measureReal_norm.1 herr) (ε / 6) (by linarith)
  have hnn : ∀ᶠ n in atTop,
      (0 : ℝ) ≤ μ.real {x : Ω | ε ≤ ‖(hacBartlett (K n) (γhat n x) - sigmaLR γ) - 0‖} :=
    Eventually.of_forall (fun n => measureReal_nonneg)
  have hle : ∀ᶠ n in atTop,
      μ.real {x : Ω | ε ≤ ‖(hacBartlett (K n) (γhat n x) - sigmaLR γ) - 0‖}
        ≤ μ.real {x : Ω | ε / 6 ≤ ‖errorAcum (K n) (γhat n x) γ - 0‖} := by
    filter_upwards [hbev, hK.eventually (eventually_ge_atTop 1)] with n hbn hKn
    refine measureReal_mono ?_
    intro ω hω
    simp only [Set.mem_ofPred_eq] at hω ⊢
    by_contra hcon
    push Not at hcon
    have hE0 : (0 : ℝ) ≤ errorAcum (K n) (γhat n ω) γ :=
      Finset.sum_nonneg (fun k _ => abs_nonneg _)
    have hcon' : errorAcum (K n) (γhat n ω) γ < ε / 6 := by
      rw [sub_zero, Real.norm_eq_abs, abs_of_nonneg hE0] at hcon
      exact hcon
    have hbound := hac_diff_bound γ (γhat n ω) hKn
    have hnorm : ‖hacBartlett (K n) (γhat n ω) - sigmaLR γ - 0‖
        = |hacBartlett (K n) (γhat n ω) - sigmaLR γ| := by
      rw [sub_zero, Real.norm_eq_abs]
    rw [hnorm] at hω
    linarith
  exact squeeze_zero' hnn hle hmeas

/-! ## Puente con la ergodicidad geométrica (`C.thm:appD-ergodico`) -/

/-- **Decaimiento geométrico ⇒ sumabilidad absoluta** de las autocovarianzas:
`|γ_k| ≤ C ρ^k` con `0 ≤ ρ < 1` implica `∑_k |γ_k| < ∞`. Es el paso que convierte
la cota de ergodicidad geométrica (`‖P^k - 1π‖_TV ≤ C ρ^k`) en la hipótesis de
sumabilidad de `thm:appD-hac-consistencia`. -/
lemma summable_of_geometric {γ : ℕ → ℝ} {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) (hγ : ∀ k, |γ k| ≤ C * ρ ^ k) : Summable γ := by
  refine Summable.of_norm_bounded ((summable_geometric_of_lt_one hρ0 hρ1).mul_left C) ?_
  intro k
  simpa [Real.norm_eq_abs] using hγ k

/-- **`thm:appD-hac-consistencia` con autocovarianzas geométricas**: si
`|γ_k| ≤ C ρ^k` (`0 ≤ ρ < 1`), la sumabilidad absoluta es automática y la
consistencia del estimador HAC sólo requiere `K_n → ∞`, `K_n/n → 0` y la
condición agregada de covarianzas. -/
theorem hac_consistencia_geometrico {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ]
    {γ : ℕ → ℝ} {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hγ : ∀ k, |γ k| ≤ C * ρ ^ k)
    (γhat : ℕ → Ω → ℕ → ℝ) (K : ℕ → ℕ)
    (hK : Tendsto K atTop atTop)
    (hKsub : Tendsto (fun n => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (herr : TendstoInMeasure μ (fun n ω => errorAcum (K n) (γhat n ω) γ) atTop (fun _ => 0)) :
    TendstoInMeasure μ (fun n ω => hacBartlett (K n) (γhat n ω) - sigmaLR γ)
      atTop (fun _ => 0) :=
  hac_consistencia μ γ γhat K (summable_of_geometric hC hρ0 hρ1 hγ) hK hKsub herr

/-- **Sesgo de Bartlett con autocovarianzas geométricas** (cota explícita): si
`|γ_k| ≤ C ρ^k` con `0 ≤ ρ < 1` y `K ≥ 1`, el sesgo de ponderación más la cola
omitida está acotado por
`C·(ρ/(1-ρ)²)/K + C·ρ^{K+1}/(1-ρ)`:
la ponderación de Bartlett aporta `O(1/K)` y la cola `O(ρ^K)`. -/
theorem abs_bias_bartlett_le_geometrico {γ : ℕ → ℝ} {C ρ : ℝ} (hC : 0 ≤ C)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) (hγ : ∀ k, |γ k| ≤ C * ρ ^ k) (K : ℕ) (hK : 1 ≤ K) :
    |∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)|
      ≤ C * (ρ / (1 - ρ) ^ 2) / K + C * ρ ^ (K + 1) / (1 - ρ) := by
  have hρabs : |ρ| < 1 := by rw [abs_of_nonneg hρ0]; exact hρ1
  have h1ρ : (0 : ℝ) < 1 - ρ := by linarith
  have hKpos : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hK
  have hγsum : Summable γ := summable_of_geometric hC hρ0 hρ1 hγ
  have hγ1 : Summable fun k : ℕ => γ (k + 1) := summable_shift hγsum
  -- ∑_{k≥0} (k+1) ρ^{k+1} = ρ/(1-ρ)²
  have hfsum : Summable fun k : ℕ => (k : ℝ) * ρ ^ k :=
    (hasSum_coe_mul_geometric_of_norm_lt_one hρabs).summable
  have hf : ∑' k : ℕ, (k : ℝ) * ρ ^ k = ρ / (1 - ρ) ^ 2 :=
    tsum_coe_mul_geometric_of_norm_lt_one hρabs
  have hcongr : (fun k : ℕ => ((k : ℝ) + 1) * ρ ^ (k + 1))
      = fun k : ℕ => ((k + 1 : ℕ) : ℝ) * ρ ^ (k + 1) := by
    funext k
    push_cast
    ring
  have hgsum : Summable fun k : ℕ => ((k : ℝ) + 1) * ρ ^ (k + 1) := by
    rw [hcongr]
    exact (summable_nat_add_iff (f := fun k : ℕ => (k : ℝ) * ρ ^ k) 1).2 hfsum
  have hg : ∑' k : ℕ, ((k : ℝ) + 1) * ρ ^ (k + 1) = ρ / (1 - ρ) ^ 2 := by
    rw [hcongr]
    have h := hfsum.tsum_eq_zero_add
    rw [show ((0 : ℕ) : ℝ) * ρ ^ 0 = 0 from by norm_num, zero_add] at h
    rw [← h, hf]
  -- cola geométrica
  have htailval : ∑' i : ℕ, C * ρ ^ (i + (K + 1)) = C * ρ ^ (K + 1) / (1 - ρ) := by
    have hp : ∀ i : ℕ, ρ ^ (i + (K + 1)) = ρ ^ (K + 1) * ρ ^ i := by
      intro i
      rw [pow_add, mul_comm]
    simp only [hp]
    rw [tsum_mul_left, tsum_mul_left, tsum_geometric_of_lt_one hρ0 hρ1, div_eq_mul_inv]
    ring
  -- (1) sesgo de ponderación
  have hA : |∑ k ∈ range K, (bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1) * γ (k + 1)|
      ≤ C * (ρ / (1 - ρ) ^ 2) / K := by
    refine le_trans (abs_sum_le_sum_abs _ _) ?_
    have hpt : ∀ k ∈ range K,
        |(bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1) * γ (k + 1)|
          ≤ C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1)) := by
      intro k hk
      have hle : ((k : ℝ) + 1) ≤ (K : ℝ) := by
        have hk' : k + 1 ≤ K := by simpa [mem_range] using hk
        exact_mod_cast hk'
      have hx1 : ((k : ℝ) + 1) / (K : ℝ) ≤ 1 := by
        rw [div_le_one hKpos]; exact hle
      have hx0 : (0 : ℝ) ≤ ((k : ℝ) + 1) / (K : ℝ) := by positivity
      have hw : |bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1| = ((k : ℝ) + 1) / (K : ℝ) := by
        rw [bartlett_eq_one_sub hx1,
          show (1 - ((k : ℝ) + 1) / (K : ℝ)) - 1 = -(((k : ℝ) + 1) / (K : ℝ)) by ring,
          abs_neg, abs_of_nonneg hx0]
      rw [abs_mul, hw]
      calc ((k : ℝ) + 1) / (K : ℝ) * |γ (k + 1)|
          ≤ ((k : ℝ) + 1) / (K : ℝ) * (C * ρ ^ (k + 1)) :=
            mul_le_mul_of_nonneg_left (hγ (k + 1)) hx0
        _ = C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1)) := by
            field_simp
    refine le_trans (Finset.sum_le_sum hpt) ?_
    have hpart : ∑ k ∈ range K, C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1))
        ≤ ∑' k : ℕ, C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1)) :=
      (hgsum.mul_left _).sum_le_tsum (range K) (fun i _ => by positivity)
    calc ∑ k ∈ range K, C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1))
        ≤ ∑' k : ℕ, C / (K : ℝ) * (((k : ℝ) + 1) * ρ ^ (k + 1)) := hpart
      _ = C * (ρ / (1 - ρ) ^ 2) / K := by
          rw [tsum_mul_left, hg]
          field_simp
  -- (2) cola omitida
  have hB : |∑' i : ℕ, γ (i + (K + 1))| ≤ C * ρ ^ (K + 1) / (1 - ρ) := by
    have hsum' : Summable fun i : ℕ => γ (i + (K + 1)) := summable_shift_add hγsum (K + 1)
    have hsumgeo : Summable fun i : ℕ => C * ρ ^ (i + (K + 1)) :=
      (summable_nat_add_iff (f := fun i : ℕ => C * ρ ^ i) (K + 1)).2
        ((summable_geometric_of_lt_one hρ0 hρ1).mul_left C)
    calc |∑' i : ℕ, γ (i + (K + 1))|
        ≤ ∑' i : ℕ, |γ (i + (K + 1))| := abs_tsum_le_tsum_abs hsum'
      _ ≤ ∑' i : ℕ, C * ρ ^ (i + (K + 1)) :=
          hsum'.abs.tsum_le_tsum (fun i => hγ _) hsumgeo
      _ = C * ρ ^ (K + 1) / (1 - ρ) := htailval
  -- (3) recomposición
  have hsplit := Summable.sum_add_tsum_nat_add (f := fun k : ℕ => γ (k + 1)) K hγ1
  simp only [Nat.add_assoc] at hsplit
  have hid : ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1) - ∑' k : ℕ, γ (k + 1)
      = ∑ k ∈ range K, (bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1) * γ (k + 1)
        - ∑' i : ℕ, γ (i + (K + 1)) := by
    have hsub : ∑ k ∈ range K, (bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1) * γ (k + 1)
        = ∑ k ∈ range K, bartlett ((k + 1 : ℝ) / (K : ℝ)) * γ (k + 1)
          - ∑ k ∈ range K, γ (k + 1) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun k _ => by ring)
    rw [hsub]
    linarith
  rw [hid]
  have hfin := abs_sub (∑ k ∈ range K, (bartlett ((k + 1 : ℝ) / (K : ℝ)) - 1) * γ (k + 1))
    (∑' i : ℕ, γ (i + (K + 1)))
  linarith [hA, hB, hfin]

/-- **Cota explícita del error del estimador HAC bajo decaimiento geométrico**:
`|σ̂²_HAC - σ²_LR| ≤ 3 b_n + 2C(ρ/(1-ρ)²)/K_n + 2Cρ^{K_n+1}/(1-ρ)` con
`b_n = ∑_{k=0}^{K_n}|γ̂_k - γ_k|`. -/
theorem hac_diff_bound_geometrico {γ : ℕ → ℝ} {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) (hγ : ∀ k, |γ k| ≤ C * ρ ^ k) (γhat : ℕ → ℝ) {K : ℕ} (hK : 1 ≤ K) :
    |hacBartlett K γhat - sigmaLR γ| ≤
      3 * errorAcum K γhat γ
        + 2 * (C * (ρ / (1 - ρ) ^ 2) / K + C * ρ ^ (K + 1) / (1 - ρ)) := by
  refine le_trans (hac_diff_bound γ γhat hK) ?_
  have h := abs_bias_bartlett_le_geometrico hC hρ0 hρ1 hγ K hK
  linarith

/-- **`thm:appD-hac-consistencia` con tasa explícita.** Si `|γ_k| ≤ C ρ^k` y el
error agregado de covarianzas está dominado por `b_n → 0`, entonces el estimador
HAC converge en probabilidad a `σ²_LR` y el error está acotado por
`3|b_n| + 2C(ρ/(1-ρ)²)/K_n + 2Cρ^{K_n+1}/(1-ρ)`. -/
theorem hac_consistencia_tasa {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ]
    {γ : ℕ → ℝ} {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hγ : ∀ k, |γ k| ≤ C * ρ ^ k)
    (γhat : ℕ → Ω → ℕ → ℝ) (K : ℕ → ℕ) {b : ℕ → ℝ} (hb : Tendsto b atTop (𝓝 0))
    (hK : Tendsto K atTop atTop)
    (hKsub : Tendsto (fun n => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (herrb : ∀ᶠ n in atTop, ∀ ω, errorAcum (K n) (γhat n ω) γ ≤ b n) :
    TendstoInMeasure μ (fun n ω => hacBartlett (K n) (γhat n ω) - sigmaLR γ)
      atTop (fun _ => 0) := by
  have h1ρ : (0 : ℝ) < 1 - ρ := by linarith
  have hinv : Tendsto (fun n => (1 : ℝ) / (K n : ℝ)) atTop (𝓝 0) := by
    have h := (tendsto_const_div_atTop_nhds_zero_nat (1 : ℝ)).comp hK
    simpa only [Function.comp_def] using h
  have hpow : Tendsto (fun n => ρ ^ (K n + 1)) atTop (𝓝 0) := by
    have h0 : Tendsto (fun n => ρ ^ (K n)) atTop (𝓝 0) :=
      (tendsto_pow_atTop_nhds_zero_of_lt_one hρ0 hρ1).comp hK
    have h := h0.mul_const ρ
    simpa [pow_succ] using h
  -- la cota determinista
  set g : ℕ → ℝ := fun n => |3 * b n|
      + 2 * (C * (ρ / (1 - ρ) ^ 2) / (K n : ℝ) + C * ρ ^ (K n + 1) / (1 - ρ)) with hg
  have hA0 : ∀ n : ℕ, (0 : ℝ) ≤ C * (ρ / (1 - ρ) ^ 2) / (K n : ℝ) := by
    intro n
    have h1 : (0 : ℝ) ≤ ρ / (1 - ρ) ^ 2 := by positivity
    have h2 : (0 : ℝ) ≤ (K n : ℝ) := by positivity
    positivity
  have hB0 : ∀ n : ℕ, (0 : ℝ) ≤ C * ρ ^ (K n + 1) / (1 - ρ) := by
    intro n
    have h1 : (0 : ℝ) ≤ ρ ^ (K n + 1) := by positivity
    positivity
  have hg0 : ∀ n, 0 ≤ g n := by
    intro n
    simp only [hg]
    have := abs_nonneg (3 * b n)
    linarith [hA0 n, hB0 n]
  have hglim : Tendsto g atTop (𝓝 0) := by
    have hb3 : Tendsto (fun n => |3 * b n|) atTop (𝓝 0) := by
      have h := hb.const_mul 3
      simpa using h.abs
    have hA : Tendsto (fun n => C * (ρ / (1 - ρ) ^ 2) / (K n : ℝ)) atTop (𝓝 0) := by
      have hmul : Tendsto (fun n => C * (ρ / (1 - ρ) ^ 2) * ((1 : ℝ) / (K n : ℝ)))
          atTop (𝓝 0) := by
        have h := hinv.const_mul (C * (ρ / (1 - ρ) ^ 2))
        simpa using h
      refine hmul.congr' (Eventually.of_forall (fun n => ?_))
      show C * (ρ / (1 - ρ) ^ 2) * (1 / (K n : ℝ)) = C * (ρ / (1 - ρ) ^ 2) / (K n : ℝ)
      rw [mul_one_div]
    have hB : Tendsto (fun n => C * ρ ^ (K n + 1) / (1 - ρ)) atTop (𝓝 0) := by
      have hmul : Tendsto (fun n => C * ρ ^ (K n + 1) * (1 - ρ)⁻¹) atTop (𝓝 0) := by
        have h := (hpow.const_mul C).mul_const ((1 - ρ)⁻¹)
        simpa using h
      refine hmul.congr' (Eventually.of_forall (fun n => ?_))
      show C * ρ ^ (K n + 1) * (1 - ρ)⁻¹ = C * ρ ^ (K n + 1) / (1 - ρ)
      rw [div_eq_mul_inv]
    have hmain : Tendsto (fun n => |3 * b n|
        + 2 * (C * (ρ / (1 - ρ) ^ 2) / (K n : ℝ) + C * ρ ^ (K n + 1) / (1 - ρ)))
        atTop (𝓝 0) := by
      have h := hb3.add ((hA.add hB).const_mul 2)
      simpa using h
    exact hmain
  have hle : ∀ᶠ n in atTop, ∀ ω,
      |hacBartlett (K n) (γhat n ω) - sigmaLR γ| ≤ g n := by
    filter_upwards [herrb, hK.eventually (eventually_ge_atTop 1)] with n hbn hKn
    intro ω
    have hdiff := hac_diff_bound_geometrico hC hρ0 hρ1 hγ (γhat n ω) hKn
    have hEb : errorAcum (K n) (γhat n ω) γ ≤ b n := hbn ω
    have h3b : (3 : ℝ) * b n ≤ |3 * b n| := by
      have h1 : |(3 : ℝ)| = 3 := by norm_num
      rw [abs_mul, h1]
      nlinarith [le_abs_self (b n)]
    simp only [hg]
    linarith
  exact tendstoInMeasure_of_abs_le μ hglim hg0 hle
