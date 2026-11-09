/-
  Apéndice D — Estimación de la Varianza de Largo Plazo (HAC, Newey–West).

  Fuente: `book_stat_inference_v0/apendices/apendice_regularidad.typ`
    * `def:appD-hac`              (línea 149): estimador HAC, kernel de Bartlett
    * `thm:appD-hac-consistencia` (línea 162): consistencia del estimador
    * `prop:appD-bandwidth`       (línea 169): comentario sobre el ancho de banda

  Convención del repo: enunciados escalares, con las hipótesis del libro
  explícitas; «→^P» es la definición literal de convergencia en probabilidad
  (`Cap11HacM1.TendstoInProb`), no una versión disfrazada.

  Enjambre smw9lhdoa / m9 (dirección d9).
-/
import Mathlib
import Book.Cap11HacM1

open Filter MeasureTheory
open scoped BigOperators Topology

set_option linter.unusedVariables false

namespace AppDHacM9

/-! ### `def:appD-hac`: el estimador tal como lo escribe el apéndice -/

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
Peso de Bartlett del apéndice: `w(x) = 1 - x` para `x ∈ [0,1]`, evaluado en
`x = k/K_n`.  El denominador es `K_n`, el del apéndice; el módulo del capítulo
11 usa `K_n + 1`.  Ambas son convenciones del mismo kernel y
`hacNW_sub_hacEst` cuantifica la diferencia, que es `o(1)`. -/
noncomputable def bartlettNW (K k : ℕ) : ℝ := 1 - (k : ℝ) / (K : ℝ)

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
Estimador HAC de Newey–West con kernel de Bartlett, con la fórmula literal del
apéndice: `σ̂²_HAC = γ̂_0 + 2 ∑_{k=1}^{K_n} w(k/K_n) γ̂_k
= γ̂_0 + 2 ∑_{k=1}^{K_n} (1 - k/K_n) γ̂_k`. -/
noncomputable def hacNW (K : ℕ) (ĉ : ℕ → ℝ) : ℝ :=
  ĉ 0 + 2 * ∑ k ∈ Finset.range K, bartlettNW K (k + 1) * ĉ (k + 1)

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
La varianza de largo plazo `σ²_LR = γ_0 + 2 ∑_{k≥1} γ_k`, el límite que el
estimador HAC debe alcanzar.  (Coincide definicionalmente con
`Cap11M1.longRun`.) -/
noncomputable def longRun (γ : ℕ → ℝ) : ℝ := γ 0 + 2 * ∑' k : ℕ, γ (k + 1)

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
`σ²_LR` del apéndice es la definición del capítulo 11. -/
lemma longRun_eq_cap11 (γ : ℕ → ℝ) : longRun γ = Cap11M1.longRun γ := rfl

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
Media muestral `X̄ = (1/n) ∑_{t<n} X_t` de la serie `X`. -/
noncomputable def sampleMean {Ω : Type*} (X : ℕ → Ω → ℝ) (n : ℕ) (ω : Ω) : ℝ :=
  (n : ℝ)⁻¹ * ∑ t ∈ Finset.range n, X t ω

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
Autocovarianza muestral del apéndice,
`γ̂_k = (1/n) ∑_{t} (X_t - X̄)(X_{t-k} - X̄)`, escrita con el índice hacia
adelante (`t ↦ t + k`): es el mismo cambio de índices que lleva `t = k+1,…,n`
a `t = 0,…,n-1`. -/
noncomputable def gammaHat {Ω : Type*} (X : ℕ → Ω → ℝ) (n k : ℕ) (ω : Ω) : ℝ :=
  (n : ℝ)⁻¹ * ∑ t ∈ Finset.range n,
    (X t ω - sampleMean X n ω) * (X (t + k) ω - sampleMean X n ω)

/-- book: apendices/apendice_regularidad.typ:149 (key: def:appD-hac) —
El estimador del apéndice evaluado en las autocovarianzas muestrales: es
`hacNW` con `γ̂_k = gammaHat X n k ω`. -/
lemma hacNW_gammaHat {Ω : Type*} (X : ℕ → Ω → ℝ) (K n : ℕ) (ω : Ω) :
    hacNW K (fun k => gammaHat X n k ω)
      = gammaHat X n 0 ω
        + 2 * ∑ k ∈ Finset.range K,
            (1 - ((k : ℝ) + 1) / (K : ℝ)) * gammaHat X n (k + 1) ω := by
  simp [hacNW, bartlettNW]

/-! ### Propiedades de los pesos de Bartlett del apéndice -/

lemma bartlettNW_nonneg {K k : ℕ} (hk : k ≤ K) : 0 ≤ bartlettNW K k := by
  rcases Nat.eq_zero_or_pos K with hK | hK
  · have hk0 : k = 0 := Nat.le_zero.mp (hK ▸ hk)
    subst hk0
    simp [bartlettNW]
  · rw [bartlettNW, sub_nonneg, div_le_one (by exact_mod_cast hK)]
    exact_mod_cast hk

lemma abs_bartlettNW_le_one {K k : ℕ} (hk : k ≤ K) : |bartlettNW K k| ≤ 1 := by
  rw [abs_of_nonneg (bartlettNW_nonneg hk), bartlettNW, sub_le_iff_le_add]
  have : (0 : ℝ) ≤ (k : ℝ) / (K : ℝ) := by positivity
  linarith

/-! ### `hacNW` frente a `hacEst`: la diferencia de convención es `o(1)`

El módulo `Book/Cap11HacM1.lean` formaliza el mismo estimador con pesos
`1 - k/(K+1)`.  Las dos convenciones difieren en
`2 ∑_{k=1}^{K} k Ĉ_k / (K (K+1))`, que es despreciable: eso permite trasladar
la cota de error del capítulo 11 al estimador tal como lo escribe el apéndice. -/

theorem hacNW_sub_hacEst (K : ℕ) (ĉ : ℕ → ℝ) (hK : 1 ≤ K) :
    hacNW K ĉ - Cap11M1.hacEst K ĉ
      = -(2 / ((K : ℝ) * ((K : ℝ) + 1)))
          * ∑ k ∈ Finset.range K, ((k : ℝ) + 1) * ĉ (k + 1) := by
  have hK0 : (K : ℝ) ≠ 0 := by positivity
  have hK1 : (K : ℝ) + 1 ≠ 0 := by positivity
  have hterm : ∀ k ∈ Finset.range K,
      2 * (bartlettNW K (k + 1) * ĉ (k + 1))
        = Cap11M1.bartlettW K (k + 1) * ĉ (k + 1)
          - (2 / ((K : ℝ) * ((K : ℝ) + 1))) * (((k : ℝ) + 1) * ĉ (k + 1)) := by
    intro k _
    rw [Cap11M1.bartlettW_succ, bartlettNW]
    field_simp
    push_cast
    ring
  have hmain : (ĉ 0 + 2 * ∑ k ∈ Finset.range K, bartlettNW K (k + 1) * ĉ (k + 1))
        - (ĉ 0 + ∑ k ∈ Finset.range K, Cap11M1.bartlettW K (k + 1) * ĉ (k + 1))
      = ∑ k ∈ Finset.range K,
          (2 * (bartlettNW K (k + 1) * ĉ (k + 1))
            - Cap11M1.bartlettW K (k + 1) * ĉ (k + 1)) := by
    rw [Finset.mul_sum]
    calc ĉ 0 + ∑ i ∈ Finset.range K, 2 * (bartlettNW K (i + 1) * ĉ (i + 1))
          - (ĉ 0 + ∑ i ∈ Finset.range K, Cap11M1.bartlettW K (i + 1) * ĉ (i + 1))
        = (∑ i ∈ Finset.range K, 2 * (bartlettNW K (i + 1) * ĉ (i + 1)))
          - ∑ i ∈ Finset.range K, Cap11M1.bartlettW K (i + 1) * ĉ (i + 1) := by ring
      _ = ∑ i ∈ Finset.range K,
            (2 * (bartlettNW K (i + 1) * ĉ (i + 1)) - Cap11M1.bartlettW K (i + 1) * ĉ (i + 1)) := by
          rw [← Finset.sum_sub_distrib]
  have hsum_eq : ∑ k ∈ Finset.range K,
        (2 * (bartlettNW K (k + 1) * ĉ (k + 1))
          - Cap11M1.bartlettW K (k + 1) * ĉ (k + 1))
      = ∑ k ∈ Finset.range K,
          -(2 / ((K : ℝ) * ((K : ℝ) + 1))) * (((k : ℝ) + 1) * ĉ (k + 1)) :=
    Finset.sum_congr rfl fun k hk => by
      have h := hterm k hk
      rw [hterm k hk] at *
      ring
  have hneg : ∑ k ∈ Finset.range K,
        -(2 / ((K : ℝ) * ((K : ℝ) + 1))) * (((k : ℝ) + 1) * ĉ (k + 1))
      = -(2 / ((K : ℝ) * ((K : ℝ) + 1)))
          * ∑ k ∈ Finset.range K, ((k : ℝ) + 1) * ĉ (k + 1) := by
    rw [Finset.mul_sum]
  rw [hacNW, Cap11M1.hacEst_eq, hmain, hsum_eq, hneg]

theorem abs_hacNW_sub_hacEst_le {K : ℕ} (hK : 1 ≤ K) (ĉ : ℕ → ℝ) :
    |hacNW K ĉ - Cap11M1.hacEst K ĉ|
      ≤ (2 / ((K : ℝ) + 1)) * ∑ k ∈ Finset.range K, |ĉ (k + 1)| := by
  have hKpos : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hK
  have hK0 : (K : ℝ) ≠ 0 := by positivity
  have hK1 : (K : ℝ) + 1 ≠ 0 := by positivity
  have hcoef : (0 : ℝ) ≤ 2 / ((K : ℝ) * ((K : ℝ) + 1)) := by positivity
  rw [hacNW_sub_hacEst K ĉ hK, neg_mul, abs_neg, abs_mul, abs_of_nonneg hcoef]
  have h1 : |∑ k ∈ Finset.range K, ((k : ℝ) + 1) * ĉ (k + 1)|
      ≤ (K : ℝ) * ∑ k ∈ Finset.range K, |ĉ (k + 1)| := by
    calc |∑ k ∈ Finset.range K, ((k : ℝ) + 1) * ĉ (k + 1)|
        ≤ ∑ k ∈ Finset.range K, |((k : ℝ) + 1) * ĉ (k + 1)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ = ∑ k ∈ Finset.range K, ((k : ℝ) + 1) * |ĉ (k + 1)| := by
          refine Finset.sum_congr rfl fun k _ => ?_
          rw [abs_mul, abs_of_nonneg (by positivity)]
      _ ≤ ∑ k ∈ Finset.range K, (K : ℝ) * |ĉ (k + 1)| := by
          refine Finset.sum_le_sum fun k hk => ?_
          have hkK : k + 1 ≤ K := by
            have := Finset.mem_range.mp hk
            omega
          have hle : ((k : ℝ) + 1) ≤ (K : ℝ) := by exact_mod_cast hkK
          exact mul_le_mul_of_nonneg_right hle (abs_nonneg _)
      _ = (K : ℝ) * ∑ k ∈ Finset.range K, |ĉ (k + 1)| := by rw [Finset.mul_sum]
  calc 2 / ((K : ℝ) * ((K : ℝ) + 1))
        * |∑ k ∈ Finset.range K, ((k : ℝ) + 1) * ĉ (k + 1)|
      ≤ 2 / ((K : ℝ) * ((K : ℝ) + 1))
          * ((K : ℝ) * ∑ k ∈ Finset.range K, |ĉ (k + 1)|) :=
        mul_le_mul_of_nonneg_left h1 hcoef
    _ = (2 / ((K : ℝ) + 1)) * ∑ k ∈ Finset.range K, |ĉ (k + 1)| := by
        field_simp

/-! ### La descomposición del error del apéndice

Error de estimación de las covarianzas + sesgo de la ventana de Bartlett +
cola omitida, para los pesos `1 - k/K_n` del apéndice. -/

theorem hacNW_error_bound (γ : ℕ → ℝ) (hγ : Summable fun k => |γ k|) (ĉ : ℕ → ℝ)
    {K : ℕ} (hK : 1 ≤ K) :
    |hacNW K ĉ - longRun γ| ≤
      4 * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
      + 2 * (∑ k ∈ Finset.range K, (((k : ℝ) + 1) / ((K : ℝ) + 1)) * |γ (k + 1)|)
      + 2 * (∑' k : ℕ, |γ (k + K + 1)|)
      + 2 * (∑' k : ℕ, |γ k|) / ((K : ℝ) + 1) := by
  have hKpos : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hK
  -- (A) cota del capítulo 11 para `hacEst`
  have hEst : |Cap11M1.hacEst K ĉ - longRun γ| ≤
      2 * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
      + 2 * (∑ k ∈ Finset.range K, (((k : ℝ) + 1) / ((K : ℝ) + 1)) * |γ (k + 1)|)
      + 2 * (∑' k : ℕ, |γ (k + K + 1)|) :=
    Cap11M1.hac_error_bound γ ĉ hγ K
  -- (B) la diferencia de convención de pesos
  have hD : (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
      = ∑ k ∈ Finset.range K, |ĉ (k + 1) - γ (k + 1)| + |ĉ 0 - γ 0| := by
    rw [Finset.sum_range_succ']
  have hshift : ∑ k ∈ Finset.range K, |ĉ (k + 1) - γ (k + 1)|
      ≤ ∑ k ∈ Finset.range (K + 1), |ĉ k - γ k| := by
    rw [hD]
    linarith [abs_nonneg (ĉ 0 - γ 0)]
  have hgamma : ∑ k ∈ Finset.range K, |γ (k + 1)| ≤ ∑' k : ℕ, |γ k| := by
    have hγ' : Summable fun k : ℕ => |γ (k + 1)| :=
      hγ.comp_injective (fun a b h => by omega)
    have h1 : ∑ k ∈ Finset.range K, |γ (k + 1)| ≤ ∑' k : ℕ, |γ (k + 1)| :=
      hγ'.sum_le_tsum _ fun i _ => abs_nonneg _
    have h2 : (∑' k : ℕ, |γ (k + 1)|) ≤ ∑' k : ℕ, |γ k| := by
      have h3 := hγ.tsum_eq_zero_add
      linarith [abs_nonneg (γ 0)]
    linarith
  have hsum : ∑ k ∈ Finset.range K, |ĉ (k + 1)|
      ≤ (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|) + ∑' k : ℕ, |γ k| := by
    have hsplit : ∑ k ∈ Finset.range K, |ĉ (k + 1)|
        ≤ ∑ k ∈ Finset.range K, |ĉ (k + 1) - γ (k + 1)|
          + ∑ k ∈ Finset.range K, |γ (k + 1)| := by
      rw [← Finset.sum_add_distrib]
      refine Finset.sum_le_sum fun k _ => ?_
      calc |ĉ (k + 1)| = |(ĉ (k + 1) - γ (k + 1)) + γ (k + 1)| := by ring_nf
        _ ≤ |ĉ (k + 1) - γ (k + 1)| + |γ (k + 1)| := abs_add_le _ _
    linarith [hshift, hgamma]
  have hdiff : |hacNW K ĉ - Cap11M1.hacEst K ĉ|
      ≤ 2 * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
        + 2 * (∑' k : ℕ, |γ k|) / ((K : ℝ) + 1) := by
    have hcoef_le : 2 / ((K : ℝ) + 1) ≤ 2 := by
      rw [div_le_iff₀ (by positivity)]
      nlinarith
    have hstep : (2 / ((K : ℝ) + 1)) * ∑ k ∈ Finset.range K, |ĉ (k + 1)|
        ≤ (2 / ((K : ℝ) + 1)) * ((∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
            + ∑' k : ℕ, |γ k|) :=
      mul_le_mul_of_nonneg_left hsum (by positivity)
    have hDnn : (0 : ℝ) ≤ ∑ k ∈ Finset.range (K + 1), |ĉ k - γ k| :=
      Finset.sum_nonneg fun k _ => abs_nonneg _
    have h1 : (2 / ((K : ℝ) + 1)) * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
        ≤ 2 * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|) := by nlinarith
    have h2 : (2 / ((K : ℝ) + 1)) * (∑' k : ℕ, |γ k|)
        = 2 * (∑' k : ℕ, |γ k|) / ((K : ℝ) + 1) := by ring
    calc |hacNW K ĉ - Cap11M1.hacEst K ĉ|
        ≤ (2 / ((K : ℝ) + 1)) * ∑ k ∈ Finset.range K, |ĉ (k + 1)| :=
          abs_hacNW_sub_hacEst_le hK ĉ
      _ ≤ (2 / ((K : ℝ) + 1)) * ((∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
            + ∑' k : ℕ, |γ k|) := hstep
      _ = (2 / ((K : ℝ) + 1)) * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
            + (2 / ((K : ℝ) + 1)) * (∑' k : ℕ, |γ k|) := by ring
      _ ≤ 2 * (∑ k ∈ Finset.range (K + 1), |ĉ k - γ k|)
            + 2 * (∑' k : ℕ, |γ k|) / ((K : ℝ) + 1) := by
          rw [h2]
          linarith
  -- (C) triángulo
  have htri : |hacNW K ĉ - longRun γ|
      ≤ |hacNW K ĉ - Cap11M1.hacEst K ĉ| + |Cap11M1.hacEst K ĉ - longRun γ| := by
    calc |hacNW K ĉ - longRun γ|
        = |(hacNW K ĉ - Cap11M1.hacEst K ĉ) + (Cap11M1.hacEst K ĉ - longRun γ)| := by
          ring_nf
      _ ≤ _ := abs_add_le _ _
  linarith [htri, hEst, hdiff]

/-! ### `thm:appD-hac-consistencia`: consistencia del estimador del apéndice -/

/-- Las tres piezas deterministas del error tienden a cero: sesgo de la ventana
de Bartlett, cola omitida y la corrección de convención `2∑|γ|/(K_n+1)`. -/
theorem bias_tendsto_zero (γ : ℕ → ℝ) (hγ : Summable fun k => |γ k|) (K : ℕ → ℕ)
    (hK : Tendsto K atTop atTop) :
    Tendsto (fun n : ℕ => 2 * (∑ k ∈ Finset.range (K n),
          (((k : ℝ) + 1) / ((K n : ℝ) + 1)) * |γ (k + 1)|)
      + 2 * (∑' k : ℕ, |γ (k + K n + 1)|)
      + 2 * (∑' k : ℕ, |γ k|) / ((K n : ℝ) + 1)) atTop (𝓝 0) := by
  have htaper : Tendsto (fun n : ℕ => 2 * (∑ k ∈ Finset.range (K n),
      (((k : ℝ) + 1) / ((K n : ℝ) + 1)) * |γ (k + 1)|)) atTop (𝓝 0) := by
    have h := ((Cap11M1.taper_tendsto_zero (fun k => |γ k|) hγ
      (fun k => abs_nonneg _)).comp hK).const_mul 2
    simpa using h
  have hKsucc : Tendsto (fun n : ℕ => K n + 1) atTop atTop :=
    tendsto_atTop_mono (fun n => Nat.le_succ _) hK
  have htail : Tendsto (fun n : ℕ => 2 * (∑' k : ℕ, |γ (k + K n + 1)|)) atTop (𝓝 0) := by
    have h := ((Cap11M1.tendsto_tsum_shift_zero (fun k => |γ k|) hγ).comp hKsucc).const_mul 2
    simpa [Nat.add_assoc] using h
  have hS : Tendsto (fun n : ℕ => 2 * (∑' k : ℕ, |γ k|) / ((K n : ℝ) + 1)) atTop (𝓝 0) := by
    have hcastK : Tendsto (fun n : ℕ => (K n : ℝ)) atTop atTop :=
      tendsto_natCast_atTop_atTop.comp hK
    have hcast : Tendsto (fun n : ℕ => (K n : ℝ) + 1) atTop atTop :=
      tendsto_atTop_mono (fun n => le_add_of_nonneg_right (by norm_num : (0 : ℝ) ≤ 1)) hcastK
    have hinv : Tendsto (fun n : ℕ => ((K n : ℝ) + 1)⁻¹) atTop (𝓝 0) :=
      hcast.inv_tendsto_atTop
    have h0 : Tendsto (fun _ : ℕ => 2 * (∑' k : ℕ, |γ k|)) atTop
        (𝓝 (2 * (∑' k : ℕ, |γ k|))) := tendsto_const_nhds
    have h := h0.mul hinv
    simpa [div_eq_mul_inv] using h
  have h := (htaper.add htail).add hS
  simpa [add_assoc] using h

/-- book: apendices/apendice_regularidad.typ:162 (key: thm:appD-hac-consistencia) —
**`thm:appD-hac-consistencia`**.  Para el kernel de Bartlett, sea `(X_t)` una
serie estrictamente estacionaria con segundo momento finito y autocovarianzas
`γ_k` absolutamente sumables; sea `K_n → ∞` con `K_n/n → 0` y supóngase la
condición agregada de covarianzas `∑_{k=0}^{K_n} |γ̂_k - γ_k| →^P 0`.
Entonces `σ̂²_HAC →^P σ²_LR`, donde `σ̂²_HAC = γ̂_0 + 2∑_{k=1}^{K_n}(1-k/K_n)γ̂_k`
es el estimador del apéndice (`def:appD-hac`).

La prueba separa las tres piezas que el libro enumera (`hacNW_error_bound`):
error de estimación de las autocovarianzas, sesgo de la ponderación de Bartlett
y cola omitida; las dos últimas son deterministas y tienden a cero por
sumabilidad absoluta (`bias_tendsto_zero`), y la primera se controla con la
hipótesis agregada.

Fidelidad declarada:

* «→^P» es la definición literal de convergencia en probabilidad
  (`Cap11M1.TendstoInProb`: `∀ε>0, μ{|Xₙ-a| ≥ ε} → 0`) sobre una medida de
  probabilidad `μ`, no una versión determinista disfrazada.
* los pesos son los del apéndice, `w(k/K_n) = 1 - k/K_n` (`hacNW`), no los de
  la convención `1 - k/(K_n+1)` del capítulo 11; la diferencia entre ambas
  estimaciones está acotada en `hacNW_error_bound` (término
  `2∑|γ|/(K_n+1)`), de modo que la cota del capítulo 11 se traslada sin
  cambiar la conclusión.
* «estrictamente estacionaria con segundo momento finito» entra, como en el
  libro, sólo a través de las autocovarianzas `γ_k` y de `∑_k |γ_k| < ∞`; la
  serie `X` no se formaliza aquí (el estimador empírico se define en
  `gammaHat`, y `hacNW_gammaHat` lo conecta con `hacNW`).
* la condición agregada `∑_{k≤K_n}|γ̂_k - γ_k| →^P 0` se toma como hipótesis
  (`hcond`): es exactamente el lugar donde el libro escribe «la condición
  agregada de covarianzas debe demostrarse para el proceso».  Derivarla de
  estacionariedad + mixing geométrico es una obligación separada (no la
  resuelve este teorema, como el propio apéndice advierte).
* la hipótesis `K_n/n → 0` se conserva (`hKn`) aunque el paso final no la use:
  es la condición bajo la cual la condición agregada es derivable.
* el contraste con «ancho fijo» del apéndice es
  `ancho_fijo_no_es_suficiente` / `ancho_fijo_contraejemplo`. -/
theorem thm_appD_hac_consistencia {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ]
    (γ : ℕ → ℝ) (hγ : Summable fun k => |γ k|)
    (K : ℕ → ℕ) (hK : Tendsto K atTop atTop)
    (hKn : Tendsto (fun n : ℕ => (K n : ℝ) / (n : ℝ)) atTop (𝓝 0))
    (γhat : ℕ → ℕ → Ω → ℝ)
    (hcond : Cap11M1.TendstoInProb μ
      (fun n ω => ∑ k ∈ Finset.range (K n + 1), |γhat n k ω - γ k|) 0) :
    Cap11M1.TendstoInProb μ
      (fun n ω => hacNW (K n) (fun k => γhat n k ω)) (longRun γ) := by
  have hbias := bias_tendsto_zero γ hγ K hK
  intro ε hε
  have hε8 : (0 : ℝ) < ε / 8 := by linarith
  have hev : ∀ᶠ n : ℕ in atTop, 2 * (∑ k ∈ Finset.range (K n),
        (((k : ℝ) + 1) / ((K n : ℝ) + 1)) * |γ (k + 1)|)
      + 2 * (∑' k : ℕ, |γ (k + K n + 1)|)
      + 2 * (∑' k : ℕ, |γ k|) / ((K n : ℝ) + 1) < ε / 2 :=
    (tendsto_order.1 hbias).2 _ (by linarith)
  have hK1 : ∀ᶠ n : ℕ in atTop, 1 ≤ K n := hK.eventually (eventually_ge_atTop 1)
  have key : ∀ n : ℕ, 1 ≤ K n →
      2 * (∑ k ∈ Finset.range (K n), (((k : ℝ) + 1) / ((K n : ℝ) + 1)) * |γ (k + 1)|)
        + 2 * (∑' k : ℕ, |γ (k + K n + 1)|)
        + 2 * (∑' k : ℕ, |γ k|) / ((K n : ℝ) + 1) < ε / 2 →
      {ω | ε ≤ |hacNW (K n) (fun k => γhat n k ω) - longRun γ|} ⊆
      {ω | ε / 8 ≤ |(∑ k ∈ Finset.range (K n + 1), |γhat n k ω - γ k|) - 0|} := by
    intro n hn1 hn ω hω
    simp only [Set.mem_ofPred_eq, sub_zero] at hω ⊢
    have hbd := hacNW_error_bound γ hγ (fun k => γhat n k ω) hn1
    have hD0 : (0 : ℝ) ≤ ∑ k ∈ Finset.range (K n + 1), |γhat n k ω - γ k| :=
      Finset.sum_nonneg fun k _ => abs_nonneg _
    rw [abs_of_nonneg hD0]
    linarith [abs_nonneg (hacNW (K n) (fun k => γhat n k ω) - longRun γ)]
  have hle : ∀ᶠ n : ℕ in atTop,
      μ.real {ω | ε ≤ |hacNW (K n) (fun k => γhat n k ω) - longRun γ|}
        ≤ μ.real {ω | ε / 8 ≤ |(∑ k ∈ Finset.range (K n + 1), |γhat n k ω - γ k|) - 0|} := by
    filter_upwards [hev, hK1] with n hn hk1
    exact MeasureTheory.measureReal_mono (key n hk1 hn) (MeasureTheory.measure_ne_top μ _)
  have hconv : Tendsto (fun n : ℕ => μ.real
      {ω | ε / 8 ≤ |(∑ k ∈ Finset.range (K n + 1), |γhat n k ω - γ k|) - 0|}) atTop (𝓝 0) :=
    hcond (ε / 8) hε8
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hconv
    (Eventually.of_forall fun n => MeasureTheory.measureReal_nonneg) hle

/-! ### El contraste del apéndice: la cota `K_n = O(n^(1/3))` no basta

El apéndice advierte que «mixing geométrico y una cota superior `K_n = O(n^{1/3})`
no bastan: esa cota permite incluso un ancho fijo».  El contenido formal de esa
advertencia es que la hipótesis `K_n → ∞` es independiente de las demás: con
`K_n ≡ 0` se cumplen `K_n/n → 0`, la sumabilidad absoluta y la condición
agregada (¡trivialmente!), y sin embargo el estimador no converge a `σ²_LR`. -/

/-- Autocovarianzas del contraejemplo de ancho fijo: `γ_0 = 0`, `γ_1 = 1`,
`γ_k = 0` para `k ≥ 2`. -/
def gammaEj (k : ℕ) : ℝ := if k = 1 then 1 else 0

@[simp] lemma gammaEj_zero : gammaEj 0 = 0 := by simp [gammaEj]
@[simp] lemma gammaEj_one : gammaEj 1 = 1 := by simp [gammaEj]
lemma gammaEj_of_ne {k : ℕ} (hk : k ≠ 1) : gammaEj k = 0 := by simp [gammaEj, hk]

lemma summable_gammaEj : Summable fun k => |gammaEj k| := by
  refine summable_of_ne_finset_zero (s := {1}) ?_
  intro k hk
  simp only [Finset.mem_singleton] at hk
  simp [gammaEj, hk]

lemma longRun_gammaEj : longRun gammaEj = 2 := by
  have htsum : (∑' k : ℕ, gammaEj (k + 1)) = 1 := by
    have h : ∀ k : ℕ, k ≠ 0 → gammaEj (k + 1) = 0 := by
      intro k hk
      exact gammaEj_of_ne (by omega)
    rw [tsum_eq_single (0 : ℕ) h]
    simp
  rw [longRun, htsum, gammaEj_zero]
  norm_num

lemma hacNW_zero (ĉ : ℕ → ℝ) : hacNW 0 ĉ = ĉ 0 := by
  simp [hacNW]

/-- Con ancho fijo `K_n = 0`, el estimador del apéndice es constantemente
`γ̂_0 = 0`, mientras que `σ²_LR = 2`: no hay convergencia. -/
theorem ancho_fijo_no_es_suficiente :
    ¬ Tendsto (fun _ : ℕ => hacNW 0 (fun k => gammaEj k)) atTop (𝓝 (longRun gammaEj)) := by
  have hconst : (fun _ : ℕ => hacNW 0 (fun k => gammaEj k)) = fun _ => (0 : ℝ) := by
    funext n
    simp [hacNW_zero]
  rw [hconst, longRun_gammaEj]
  intro h
  have h2 := tendsto_nhds_unique h tendsto_const_nhds
  norm_num at h2

/-- book: apendices/apendice_regularidad.typ:162 (key: thm:appD-hac-consistencia) —
**El contraste del apéndice, en forma positiva**: existen autocovarianzas
absolutamente sumables `γ` (`gammaEj`) y un ancho `K_n ≡ 0` que cumple
`K_n/n → 0` y la condición agregada `∑_{k=0}^{K_n}|γ̂_k - γ_k| ≡ 0` (con
`γ̂ = γ`), y sin embargo `σ̂²_HAC` no converge a `σ²_LR`.  Es decir: la
hipótesis `K_n → ∞` no es consecuencia de las otras, que es exactamente lo que
el apéndice quiere decir con que la cota `K_n = O(n^{1/3})` «permite incluso un
ancho fijo». -/
theorem ancho_fijo_contraejemplo :
    (Summable fun k => |gammaEj k|) ∧
      Tendsto (fun n : ℕ => ((0 : ℕ) : ℝ) / (n : ℝ)) atTop (𝓝 0) ∧
      (∀ n : ℕ, ∑ k ∈ Finset.range (0 + 1), |gammaEj k - gammaEj k| = 0) ∧
      ¬ Tendsto (fun _ : ℕ => hacNW 0 (fun k => gammaEj k)) atTop (𝓝 (longRun gammaEj)) := by
  refine ⟨summable_gammaEj, ?_, ?_, ancho_fijo_no_es_suficiente⟩
  · simp
  · intro n
    simp

end AppDHacM9
