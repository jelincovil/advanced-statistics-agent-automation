/-
  Capítulo 11 — Estimación de varianza de largo plazo (HAC).

  Fuente: `book_stat_inference_v0/capitulos/cap08_intervalos.typ`
    * `def:ch11-hac`             (línea 270): varianza HAC con pesos de Bartlett.
    * `thm:ch11-var-consistente` (línea 282): consistencia del estimador HAC.

  Convención del repo (la de `Book/Cap04Herramientas.lean`): enunciados
  escalares/finitos, con las hipótesis del libro explícitas.  Aquí la
  conclusión «→^P» es la definición literal de convergencia en probabilidad
  (`TendstoInProb`), no una versión disfrazada.

  Enjambre smw9820kx / m1 (dirección d1, id de tablero d4).
-/
import Mathlib

open Filter MeasureTheory
open scoped BigOperators Topology

set_option linter.unusedVariables false

namespace Cap11M1

/-! ### Definiciones del libro (`def:ch11-hac`) -/

/-- book: capitulos/cap08_intervalos.typ:270 (key: def:ch11-hac) —
Pesos de Bartlett `w_0 = 1`, `w_k = 2 (1 - k/(K+1))` para `1 ≤ k ≤ K`.
Se indexan por `j = k-1`, de modo que `bartlettW K (j+1) = 2 (1 - (j+1)/(K+1))`. -/
noncomputable def bartlettW (K : ℕ) : ℕ → ℝ
  | 0 => 1
  | (j + 1) => 2 * (1 - ((j : ℝ) + 1) / ((K : ℝ) + 1))

/-- book: capitulos/cap08_intervalos.typ:270 (key: def:ch11-hac) —
Varianza HAC con pesos de Bartlett:
`σ̂²_HAC = ĉ_0 + 2 ∑_{k=1}^{K} (1 - k/(K+1)) ĉ_k`. -/
noncomputable def hacEst (K : ℕ) (ĉ : ℕ → ℝ) : ℝ :=
  ∑ j ∈ Finset.range (K + 1), bartlettW K j * ĉ j

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
Varianza de largo plazo `σ²_LR = c_0 + 2 ∑_{k ≥ 1} c_k`, el límite que el
estimador HAC debe alcanzar. -/
noncomputable def longRun (c : ℕ → ℝ) : ℝ := c 0 + 2 * ∑' j : ℕ, c (j + 1)

@[simp] lemma bartlettW_zero (K : ℕ) : bartlettW K 0 = 1 := rfl

@[simp] lemma bartlettW_succ (K j : ℕ) :
    bartlettW K (j + 1) = 2 * (1 - ((j : ℝ) + 1) / ((K : ℝ) + 1)) := rfl

lemma bartlettW_succ_nonneg {K j : ℕ} (hj : j ≤ K) : 0 ≤ bartlettW K (j + 1) := by
  rw [bartlettW_succ]
  have h1 : ((j : ℝ) + 1) / ((K : ℝ) + 1) ≤ 1 := by
    rw [div_le_one (by positivity)]
    have h2 : (j : ℝ) + 1 ≤ (K : ℝ) + 1 := by
      exact_mod_cast Nat.succ_le_succ hj
    linarith
  nlinarith

lemma bartlettW_succ_le_two (K j : ℕ) : bartlettW K (j + 1) ≤ 2 := by
  rw [bartlettW_succ]
  have h0 : 0 ≤ ((j : ℝ) + 1) / ((K : ℝ) + 1) := by positivity
  nlinarith

lemma abs_bartlettW_le_two {K j : ℕ} (hj : j ≤ K) : |bartlettW K j| ≤ 2 := by
  match j with
  | 0 => simp
  | (m + 1) =>
    rw [abs_of_nonneg (bartlettW_succ_nonneg (K := K) (j := m) (by omega))]
    exact bartlettW_succ_le_two K m

/-- Forma «rezago a rezago» del estimador: el rezago `0` con peso `1` y los
rezagos `1..K` con pesos de Bartlett. -/
lemma hacEst_eq (K : ℕ) (x : ℕ → ℝ) :
    hacEst K x = x 0 + ∑ j ∈ Finset.range K, bartlettW K (j + 1) * x (j + 1) := by
  rw [hacEst, Finset.sum_range_succ', add_comm]
  simp

/-! ### Consistencia: el error se separa en las tres piezas del libro -/

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
**Descomposición del error HAC** (la que usa la demostración del libro):
el error del estimador con pesos de Bartlett se acota por

* dos veces la suma de los errores de las autocovarianzas estimadas,
* dos veces el sesgo de la ventana (los pesos `1 - k/(K+1)` no son `1`),
* dos veces la cola omitida `∑_{k > K} |c_k|`. -/
theorem hac_error_bound (c ĉ : ℕ → ℝ) (hc : Summable fun k => |c k|) (K : ℕ) :
    |hacEst K ĉ - longRun c| ≤
      2 * (∑ j ∈ Finset.range (K + 1), |ĉ j - c j|)
      + 2 * (∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * |c (j + 1)|)
      + 2 * (∑' j : ℕ, |c (j + K + 1)|) := by
  have hc' : Summable c := summable_abs_iff.mp hc
  have hshift : Summable fun j : ℕ => c (j + 1) :=
    hc'.comp_injective (fun a b h => by omega)
  have hshift_abs : Summable fun j : ℕ => |c (j + 1)| :=
    hc.comp_injective (fun a b h => by omega)
  have hshift_abs' : Summable fun j : ℕ => |c (j + (K + 1))| :=
    hc.comp_injective (fun a b h => by omega)
  -- (A) error de estimación de las autocovarianzas
  have hA : |hacEst K ĉ - hacEst K c| ≤
      2 * (∑ j ∈ Finset.range (K + 1), |ĉ j - c j|) := by
    have h1 : hacEst K ĉ - hacEst K c
        = ∑ j ∈ Finset.range (K + 1), bartlettW K j * (ĉ j - c j) := by
      rw [hacEst, hacEst, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [h1]
    calc |∑ j ∈ Finset.range (K + 1), bartlettW K j * (ĉ j - c j)|
        ≤ ∑ j ∈ Finset.range (K + 1), |bartlettW K j * (ĉ j - c j)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ = ∑ j ∈ Finset.range (K + 1), |bartlettW K j| * |ĉ j - c j| := by
          simp [abs_mul]
      _ ≤ ∑ j ∈ Finset.range (K + 1), 2 * |ĉ j - c j| := by
          refine Finset.sum_le_sum fun j hj => ?_
          have hj' : j ≤ K := by
            have := Finset.mem_range.mp hj
            omega
          exact mul_le_mul_of_nonneg_right (abs_bartlettW_le_two hj') (abs_nonneg _)
      _ = 2 * (∑ j ∈ Finset.range (K + 1), |ĉ j - c j|) := by
          rw [Finset.mul_sum]
  -- (B) sesgo de ventana y cola omitida
  have hsplit : hacEst K c - longRun c
      = -(2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1))
        - 2 * (∑' j : ℕ, c (j + K + 1)) := by
    have htsum : (∑' j : ℕ, c (j + 1))
        = (∑ j ∈ Finset.range K, c (j + 1)) + ∑' j : ℕ, c (j + K + 1) := by
      have h := Summable.sum_add_tsum_nat_add (f := fun j : ℕ => c (j + 1)) K hshift
      linarith
    have hstep : hacEst K c
        = c 0 + 2 * (∑ j ∈ Finset.range K, c (j + 1))
          - 2 * (∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)) := by
      rw [hacEst_eq]
      have hterm : ∀ j ∈ Finset.range K,
          bartlettW K (j + 1) * c (j + 1)
            = 2 * c (j + 1) - 2 * ((((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)) := by
        intro j _
        rw [bartlettW_succ]
        ring
      rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, Finset.mul_sum, Finset.mul_sum]
      ring
    rw [hstep, longRun, htsum]
    ring
  have hB : |hacEst K c - longRun c| ≤
      2 * (∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * |c (j + 1)|)
      + 2 * (∑' j : ℕ, |c (j + K + 1)|) := by
    have h1 : |∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)|
        ≤ ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * |c (j + 1)| := by
      calc |∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)|
          ≤ ∑ j ∈ Finset.range K, |(((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)| :=
            Finset.abs_sum_le_sum_abs _ _
        _ = ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * |c (j + 1)| := by
            refine Finset.sum_congr rfl fun j _ => ?_
            rw [abs_mul, abs_of_nonneg (by positivity)]
    have h2 : |∑' j : ℕ, c (j + K + 1)| ≤ ∑' j : ℕ, |c (j + K + 1)| := by
      have h := norm_tsum_le_tsum_norm (f := fun j : ℕ => c (j + K + 1)) hshift_abs'
      simpa [Real.norm_eq_abs] using h
    rw [hsplit]
    have h3 : |-(2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1))
        - 2 * (∑' j : ℕ, c (j + K + 1))|
        ≤ |2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)|
          + |2 * (∑' j : ℕ, c (j + K + 1))| := by
      have h := abs_add_le (2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1))
        (2 * (∑' j : ℕ, c (j + K + 1)))
      have heq : -(2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1))
          - 2 * (∑' j : ℕ, c (j + K + 1))
          = -(2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)
              + 2 * (∑' j : ℕ, c (j + K + 1))) := by ring
      rw [heq, abs_neg]
      exact h
    have h4 : |2 * ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)|
        = 2 * |∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * c (j + 1)| := by
      rw [abs_mul]
      norm_num
    have h5 : |2 * (∑' j : ℕ, c (j + K + 1))| = 2 * |∑' j : ℕ, c (j + K + 1)| := by
      rw [abs_mul]
      norm_num
    rw [h4, h5] at h3
    linarith
  calc |hacEst K ĉ - longRun c|
      = |(hacEst K ĉ - hacEst K c) + (hacEst K c - longRun c)| := by ring_nf
    _ ≤ |hacEst K ĉ - hacEst K c| + |hacEst K c - longRun c| := abs_add_le _ _
    _ ≤ 2 * (∑ j ∈ Finset.range (K + 1), |ĉ j - c j|)
          + 2 * (∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * |c (j + 1)|)
          + 2 * (∑' j : ℕ, |c (j + K + 1)|) := by linarith

/-- La cola de una serie sumable tiende a cero: `∑_{j ≥ N} b (j+N) → 0`. -/
lemma tendsto_tsum_shift_zero (b : ℕ → ℝ) (hb : Summable b) :
    Tendsto (fun N : ℕ => ∑' j : ℕ, b (j + N)) atTop (𝓝 0) := by
  have h := hb.hasSum.tendsto_sum_nat
  have h2 : Tendsto (fun N : ℕ => (∑' j : ℕ, b j) - ∑ j ∈ Finset.range N, b j) atTop
      (𝓝 ((∑' j : ℕ, b j) - ∑' j : ℕ, b j)) := tendsto_const_nhds.sub h
  have h3 : (∑' j : ℕ, b j) - ∑' j : ℕ, b j = 0 := sub_self _
  rw [h3] at h2
  refine h2.congr fun N => ?_
  rw [sub_eq_iff_eq_add, add_comm]
  exact (Summable.sum_add_tsum_nat_add (f := b) N hb).symm

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
**Lema de Kronecker para la ventana de Bartlett**: si `∑ |c_k| < ∞`, el
sesgo de la ventana tiende a cero,
`∑_{k=1}^{K} (k/(K+1)) |c_k| → 0`.  Es la pieza que el libro despacha con
«los otros tienden a cero por sumabilidad y convergencia de los pesos a uno en
cada rezago fijo». -/
theorem taper_tendsto_zero (b : ℕ → ℝ) (hb : Summable b) (hb0 : ∀ k, 0 ≤ b k) :
    Tendsto (fun K : ℕ => ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1))
      atTop (𝓝 0) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  -- la cola tiende a cero
  have htail : Tendsto (fun N : ℕ => ∑' j : ℕ, b (j + N)) atTop (𝓝 0) :=
    tendsto_tsum_shift_zero b hb
  have hev : ∀ᶠ N : ℕ in atTop, (∑' j : ℕ, b (j + N)) < ε / 2 :=
    (tendsto_order.1 htail).2 _ (by linarith)
  obtain ⟨N, hN⟩ := eventually_atTop.1 hev
  have htailN : (∑' j : ℕ, b (j + (N + 1))) < ε / 2 := hN (N + 1) (Nat.le_succ N)
  -- el resto es una constante finita dividida por K+1
  set S : ℝ := ∑ j ∈ Finset.range N, b (j + 1) with hS
  have hS0 : 0 ≤ S := Finset.sum_nonneg fun j _ => hb0 _
  obtain ⟨K₀, hK₀⟩ := exists_nat_gt (2 * (N : ℝ) * S / ε)
  refine ⟨max N K₀, fun K hK => ?_⟩
  have hKN : N ≤ K := le_trans (le_max_left _ _) hK
  have hKK₀ : K₀ ≤ K := le_trans (le_max_right _ _) hK
  have hKbig : 2 * (N : ℝ) * S / ε < (K : ℝ) := lt_of_lt_of_le hK₀ (by exact_mod_cast hKK₀)
  -- suma partida en el índice N
  have hsplit : ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1)
      = ∑ j ∈ Finset.range N, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1)
        + ∑ j ∈ Finset.range (K - N),
            ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1) := by
    have hrange : Finset.range K = Finset.range (N + (K - N)) := by
      rw [Nat.add_sub_of_le hKN]
    rw [hrange, Finset.sum_range_add]
  rw [hsplit]
  have hfirst : ∑ j ∈ Finset.range N, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1)
      ≤ ((N : ℝ) / ((K : ℝ) + 1)) * S := by
    rw [hS, Finset.mul_sum]
    refine Finset.sum_le_sum fun j hj => ?_
    have hjN : j + 1 ≤ N := by
      have := Finset.mem_range.mp hj
      omega
    have hle : (((j : ℝ) + 1) / ((K : ℝ) + 1)) ≤ (N : ℝ) / ((K : ℝ) + 1) := by
      apply div_le_div_of_nonneg_right _ (by positivity)
      exact_mod_cast hjN
    exact mul_le_mul_of_nonneg_right hle (hb0 _)
  have hsecond : ∑ j ∈ Finset.range (K - N),
        ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1)
      ≤ ∑' j : ℕ, b (N + j + 1) := by
    have hshift : Summable fun i : ℕ => b (N + i + 1) :=
      hb.comp_injective (fun a c h => by omega)
    have hstep : ∀ j ∈ Finset.range (K - N),
        ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1) ≤ b (N + j + 1) := by
      intro j hj
      have hjK : j < K - N := Finset.mem_range.mp hj
      have hbnd : ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) ≤ 1 := by
        rw [div_le_one (by positivity)]
        have hcast : ((N + j : ℕ) : ℝ) + 1 ≤ (K : ℝ) + 1 := by
          have hlt : N + j < K := by omega
          have : N + j + 1 ≤ K + 1 := by omega
          exact_mod_cast this
        linarith
      calc ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1)
          ≤ 1 * b (N + j + 1) := mul_le_mul_of_nonneg_right hbnd (hb0 _)
        _ = b (N + j + 1) := one_mul _
    calc ∑ j ∈ Finset.range (K - N),
          ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1)
        ≤ ∑ j ∈ Finset.range (K - N), b (N + j + 1) := Finset.sum_le_sum hstep
      _ ≤ ∑' j : ℕ, b (N + j + 1) := hshift.sum_le_tsum _ fun i _ => hb0 _
  have hmain : ∑ j ∈ Finset.range K, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1)
      ≤ ((N : ℝ) / ((K : ℝ) + 1)) * S + ∑' j : ℕ, b (N + j + 1) := by
    linarith
  have htailN' : (∑' j : ℕ, b (N + j + 1)) < ε / 2 := by
    have heq : (fun j : ℕ => b (N + j + 1)) = (fun j : ℕ => b (j + (N + 1))) := by
      funext j
      rw [show N + j + 1 = j + (N + 1) by omega]
    rw [heq]
    exact htailN
  have hmul : 2 * (N : ℝ) * S < (K : ℝ) * ε := (div_lt_iff₀ hε).mp hKbig
  have hsmall : ((N : ℝ) / ((K : ℝ) + 1)) * S < ε / 2 := by
    rw [div_mul_eq_mul_div, div_lt_iff₀ (by positivity)]
    nlinarith [hmul]
  have hnonneg : 0 ≤ ∑ j ∈ Finset.range N, (((j : ℝ) + 1) / ((K : ℝ) + 1)) * b (j + 1)
      + ∑ j ∈ Finset.range (K - N),
          ((((N + j : ℕ) : ℝ) + 1) / ((K : ℝ) + 1)) * b (N + j + 1) := by
    apply add_nonneg
    · refine Finset.sum_nonneg fun j _ => ?_
      exact mul_nonneg (by positivity) (hb0 _)
    · refine Finset.sum_nonneg fun j _ => ?_
      exact mul_nonneg (by positivity) (hb0 _)
  rw [Real.dist_eq, sub_zero, abs_of_nonneg hnonneg]
  linarith

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
**Consistencia determinista del estimador HAC**: si las autocovarianzas
estimadas son consistentes en el sentido de que `∑_{k ≤ K_n} |ĉ_k - c_k| → 0`
y `K_n → ∞`, entonces el estimador de Bartlett converge a `σ²_LR`. -/
theorem hacEst_tendsto (c : ℕ → ℝ) (hc : Summable fun k => |c k|)
    (K : ℕ → ℕ) (hK : Tendsto K atTop atTop) (ĉ : ℕ → ℕ → ℝ)
    (hĉ : Tendsto (fun n => ∑ j ∈ Finset.range (K n + 1), |ĉ n j - c j|) atTop (𝓝 0)) :
    Tendsto (fun n => hacEst (K n) (ĉ n)) atTop (𝓝 (longRun c)) := by
  have htaper : Tendsto (fun n => ∑ j ∈ Finset.range (K n),
      (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|) atTop (𝓝 0) :=
    (taper_tendsto_zero (fun k => |c k|) hc (fun k => abs_nonneg _)).comp hK
  have hKsucc : Tendsto (fun n => K n + 1) atTop atTop :=
    tendsto_atTop_mono (fun n => Nat.le_succ _) hK
  have htail : Tendsto (fun n => ∑' j : ℕ, |c (j + K n + 1)|) atTop (𝓝 0) :=
    (tendsto_tsum_shift_zero (fun k => |c k|) hc).comp hKsucc
  have hsum : Tendsto (fun n => 2 * (∑ j ∈ Finset.range (K n + 1), |ĉ n j - c j|))
      atTop (𝓝 0) := by
    have h := hĉ.const_mul 2
    simpa using h
  have hg : Tendsto (fun n => (2 * (∑ j ∈ Finset.range (K n + 1), |ĉ n j - c j|)
      + 2 * (∑ j ∈ Finset.range (K n), (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|))
      + 2 * (∑' j : ℕ, |c (j + K n + 1)|)) atTop (𝓝 0) := by
    have h := (hsum.add (htaper.const_mul 2)).add (htail.const_mul 2)
    simpa using h
  have hzero : Tendsto (fun n => dist (hacEst (K n) (ĉ n)) (longRun c)) atTop (𝓝 0) := by
    refine squeeze_zero (fun n => dist_nonneg) (fun n => ?_) hg
    simpa [Real.dist_eq] using hac_error_bound c (ĉ n) hc (K n)
  exact tendsto_iff_dist_tendsto_zero.mpr hzero

/-! ### Versión en probabilidad: el enunciado del libro -/

/-- Convergencia en probabilidad de una sucesión de variables aleatorias
reales (definición de manual): para todo `ε > 0`, la probabilidad de que
`|Xₙ - a| ≥ ε` tiende a cero. -/
def TendstoInProb {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (X : ℕ → Ω → ℝ) (a : ℝ) : Prop :=
  ∀ ε > 0, Tendsto (fun n => μ.real {ω | ε ≤ |X n ω - a|}) atTop (𝓝 0)

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
**`thm:ch11-var-consistente`**. Sea `c_k` la autocovarianza de una
secuencia estacionaria con `∑_k |c_k| < ∞`, `K_T → ∞`, y supóngase que las
autocovarianzas estimadas verifican `∑_{k ≤ K_T} |ĉ_k - c_k| →^P 0`.
Entonces `σ̂²_HAC →^P σ²_LR`.

Fidelidad declarada:

* «→^P» es `TendstoInProb`, la definición literal de convergencia en
  probabilidad; el espacio es una medida de probabilidad `μ` y las
  autocovarianzas estimadas `ĉ : ℕ → ℕ → Ω → ℝ` son funciones arbitrarias de
  `ω` (no se pide medibilidad: `μ.real` está definida en todo conjunto y la
  cota de error usada es puntual).
* La hipótesis `K/T → 0` del libro es la condición bajo la cual la tercera
  hipótesis (consistencia de las autocovarianzas estimadas) es derivable; el
  paso final del libro —este teorema— no la usa.  Se conserva como `hKT` para
  que el enunciado sea el del libro.
* «Secuencia estacionaria» entra únicamente a través de sus autocovarianzas
  `c_k` y de la sumabilidad absoluta, que es lo que el libro enumera. -/
theorem thm_ch11_var_consistente
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (c : ℕ → ℝ) (hc : Summable fun k => |c k|)
    (K : ℕ → ℕ) (hK : Tendsto K atTop atTop)
    (hKT : Tendsto (fun n => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (ĉ : ℕ → ℕ → Ω → ℝ)
    (hĉ : TendstoInProb μ (fun n ω => ∑ j ∈ Finset.range (K n + 1), |ĉ n j ω - c j|) 0) :
    TendstoInProb μ (fun n ω => hacEst (K n) (fun k => ĉ n k ω)) (longRun c) := by
  -- el sesgo determinista tiende a cero
  have htaper : Tendsto (fun n => ∑ j ∈ Finset.range (K n),
      (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|) atTop (𝓝 0) :=
    (taper_tendsto_zero (fun k => |c k|) hc (fun k => abs_nonneg _)).comp hK
  have hKsucc : Tendsto (fun n => K n + 1) atTop atTop :=
    tendsto_atTop_mono (fun n => Nat.le_succ _) hK
  have htail : Tendsto (fun n => ∑' j : ℕ, |c (j + K n + 1)|) atTop (𝓝 0) :=
    (tendsto_tsum_shift_zero (fun k => |c k|) hc).comp hKsucc
  have hbias : Tendsto (fun n => 2 * (∑ j ∈ Finset.range (K n),
      (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|)
      + 2 * (∑' j : ℕ, |c (j + K n + 1)|)) atTop (𝓝 0) := by
    have h := (htaper.const_mul 2).add (htail.const_mul 2)
    simpa using h
  intro ε hε
  have hε4 : (0:ℝ) < ε / 4 := by linarith
  -- en un conjunto eventual, el sesgo es menor que ε/2
  have hev : ∀ᶠ n : ℕ in atTop, 2 * (∑ j ∈ Finset.range (K n),
      (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|)
      + 2 * (∑' j : ℕ, |c (j + K n + 1)|) < ε / 2 :=
    (tendsto_order.1 hbias).2 _ (by linarith)
  -- cota puntual: si el sesgo es pequeño, un error grande del estimador fuerza
  -- un error grande de las autocovarianzas estimadas
  have key : ∀ n : ℕ, 2 * (∑ j ∈ Finset.range (K n),
      (((j : ℝ) + 1) / ((K n : ℝ) + 1)) * |c (j + 1)|)
      + 2 * (∑' j : ℕ, |c (j + K n + 1)|) < ε / 2 →
      {ω | ε ≤ |hacEst (K n) (fun k => ĉ n k ω) - longRun c|} ⊆
      {ω | ε / 4 ≤ |(∑ j ∈ Finset.range (K n + 1), |ĉ n j ω - c j|) - 0|} := by
    intro n hn ω hω
    simp only [Set.mem_ofPred_eq, sub_zero] at hω ⊢
    have hbd := hac_error_bound c (fun k => ĉ n k ω) hc (K n)
    have hsum0 : 0 ≤ ∑ j ∈ Finset.range (K n + 1), |ĉ n j ω - c j| :=
      Finset.sum_nonneg fun j _ => abs_nonneg _
    rw [abs_of_nonneg hsum0]
    linarith [abs_nonneg (hacEst (K n) (fun k => ĉ n k ω) - longRun c)]
  have hle : ∀ᶠ n : ℕ in atTop,
      μ.real {ω | ε ≤ |hacEst (K n) (fun k => ĉ n k ω) - longRun c|}
        ≤ μ.real {ω | ε / 4 ≤ |(∑ j ∈ Finset.range (K n + 1), |ĉ n j ω - c j|) - 0|} := by
    filter_upwards [hev] with n hn
    exact MeasureTheory.measureReal_mono (key n hn) (MeasureTheory.measure_ne_top μ _)
  have hconv : Tendsto (fun n => μ.real
      {ω | ε / 4 ≤ |(∑ j ∈ Finset.range (K n + 1), |ĉ n j ω - c j|) - 0|}) atTop (𝓝 0) :=
    hĉ (ε / 4) hε4
  have hnn : ∀ᶠ n : ℕ in atTop, 0 ≤ μ.real
      {ω | ε ≤ |hacEst (K n) (fun k => ĉ n k ω) - longRun c|} :=
    Eventually.of_forall fun n => MeasureTheory.measureReal_nonneg
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hconv hnn hle

/-! ### Un caso concreto: AR(1) -/

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
Para autocovarianzas `c_k = σ²ρ^k` con `|ρ| < 1`, la varianza de largo
plazo es `σ²(1+ρ)/(1-ρ)`: el número al que el estimador HAC de Bartlett debe
converger (cf. `ex:ch4-ar1`, `Book/Cap04Ch4M6.lean`). -/
theorem longRun_ar1 {σ2 ρ : ℝ} (hρ : |ρ| < 1) :
    longRun (fun k => σ2 * ρ ^ k) = σ2 * (1 + ρ) / (1 - ρ) := by
  have h1ρ : (0:ℝ) < 1 - ρ := by
    have hlt : ρ < 1 := lt_of_abs_lt hρ
    linarith
  have hfun : (fun j : ℕ => σ2 * ρ ^ (j + 1)) = (fun j : ℕ => σ2 * ρ * ρ ^ j) := by
    funext j
    rw [pow_succ]
    ring
  have hsum : Summable fun j : ℕ => σ2 * ρ ^ (j + 1) := by
    rw [hfun]
    exact (summable_geometric_of_norm_lt_one hρ).mul_left (σ2 * ρ)
  have htsum : (∑' j : ℕ, σ2 * ρ ^ (j + 1)) = σ2 * ρ * (1 - ρ)⁻¹ := by
    rw [hfun, tsum_mul_left, tsum_geometric_of_norm_lt_one hρ]
  rw [longRun, htsum]
  field_simp
  ring

/-- book: capitulos/cap08_intervalos.typ:282 (key: thm:ch11-var-consistente) —
Caso AR(1) con autocovarianzas conocidas: el estimador de Bartlett converge a
`σ²(1+ρ)/(1−ρ)`.  Es `hacEst_tendsto` con `ĉ = c`, es decir la consistencia en
el caso en que la única pieza aleatoria es el propio proceso. -/
theorem hacEst_ar1_tendsto {σ2 ρ : ℝ} (hρ : |ρ| < 1) (K : ℕ → ℕ)
    (hK : Tendsto K atTop atTop) :
    Tendsto (fun n => hacEst (K n) (fun k => σ2 * ρ ^ k)) atTop
      (𝓝 (σ2 * (1 + ρ) / (1 - ρ))) := by
  have hgeo : Summable fun k : ℕ => ρ ^ k := summable_geometric_of_norm_lt_one hρ
  have hc : Summable fun k : ℕ => |σ2 * ρ ^ k| := by
    have h : Summable fun k : ℕ => σ2 * ρ ^ k := hgeo.mul_left σ2
    simpa using h.abs
  have hĉ : Tendsto (fun n => ∑ j ∈ Finset.range (K n + 1),
      |σ2 * ρ ^ j - σ2 * ρ ^ j|) atTop (𝓝 0) := by
    simp
  have h := hacEst_tendsto (fun k => σ2 * ρ ^ k) hc K hK (fun _ k => σ2 * ρ ^ k) hĉ
  rwa [longRun_ar1 hρ] at h

end Cap11M1
