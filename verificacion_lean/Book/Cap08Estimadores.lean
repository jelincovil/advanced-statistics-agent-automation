import Mathlib

/-!
# Book.Cap08Estimadores — definiciones y álgebra del cap. 8 (capitulos/cap08_intervalos.typ)

Módulo de apoyo para `Book.Cap08Intervalos`: formaliza las **definiciones**
de los estimadores de varianza del capítulo y el álgebra de la evaluación
secuencial (SAVE).

* `def:ch11-var-if` — contribuciones por episodio: `φ̂_i = D_i − D̄`,
  `s_D² = (1/(n−1)) Σ φ̂_i²`, `SE = s_D/√n`, con las identidades
  básicas: la suma de las contribuciones centradas es `0` (n ≠ 0),
  `s_D² · (n−1) = Σ φ̂_i²`, `s_D² ≥ 0` y `s_D²` es invariante por
  traslación (sumar una constante a todas las contribuciones no cambia
  la varianza estimada).
* `def:ch11-hac` — varianza HAC con pesos de Bartlett: `ĉ_k`, los pesos
  `1 − k/(K+1)` en `[0,1]`, `σ̂²_HAC = ĉ_0 + 2 Σ_{k=1}^K (1−k/(K+1))ĉ_k`;
  se prueba que con `K = 0` se reduce a `ĉ_0`, que una secuencia constante
  en la ventana da `σ̂²_HAC = 0`, y la cota triangular
  `|σ̂²_HAC| ≤ |ĉ_0| + 2 Σ_{k=1}^K |ĉ_k|` (los pesos Bartlett nunca
  amplifican).
* `ex:ch11-ej5` — término de separación de SAVE:
  `Σ_k a_k J(π_k) = J(π_f) + Σ_k a_k (J(π_k) − J(π_f))` cuando `Σ_k a_k = 1`,
  el término no se anula en general (ejemplo exacto con dos bloques) y es
  estrictamente positivo si todos los pesos son positivos y todos los
  valores de bloque superan el de la política final.

Fidelidad declarada: se formaliza el **contenido algebraico exacto** de las
definiciones y de la descomposición de SAVE; no se formalizan aquí los
enunciados asintóticos asociados (CLT, consistencia) — esos son objetos de
`thm:ch11-var-consistente` / `thm:ch11-clt-mixing` — ni el procedimiento
SAVE completo (orden temporal, partición y studentización del artículo
original), que el libro describe en prosa y no como fórmula.

Origen: enjambre smw82qi6q, miembro m11.
-/

set_option linter.unusedVariables false

open Finset BigOperators

namespace Cap08Estimadores

/-! ## def:ch11-var-if — varianza de contribuciones por episodio -/

/-- Media muestral de las contribuciones `D : Fin n → ℝ`. -/
noncomputable def dMean {n : ℕ} (D : Fin n → ℝ) : ℝ := (∑ i, D i) / (n : ℝ)

/-- Contribución centrada `φ̂_i = D_i − D̄`. -/
noncomputable def dPhi {n : ℕ} (D : Fin n → ℝ) (i : Fin n) : ℝ := D i - dMean D

/-- `s_D² = (1/(n−1)) Σ_i φ̂_i²`. -/
noncomputable def dS2 {n : ℕ} (D : Fin n → ℝ) : ℝ := (∑ i, dPhi D i ^ 2) / ((n : ℝ) - 1)

/-- `ŜE = s_D / √n` (con `s_D = √(s_D²)`). -/
noncomputable def dSE {n : ℕ} (D : Fin n → ℝ) : ℝ :=
  Real.sqrt (dS2 D) / Real.sqrt (n : ℝ)

theorem dMean_mul {n : ℕ} (D : Fin n → ℝ) (hn : n ≠ 0) :
    (n : ℝ) * dMean D = ∑ i, D i := by
  have h : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  simp only [dMean]
  field_simp

/-- book: capitulos/cap08_intervalos.typ:259 (key: def:ch11-var-if) —
varianza de contribuciones por episodio: con `φ̂_i = D_i − D̄`, la suma de
las contribuciones centradas es `Σ_i φ̂_i = 0` para `n ≠ 0`, de modo que
`s_D² = (1/(n−1)) Σ_i φ̂_i²` es la varianza de las desviaciones respecto
de la media y `ŜE = s_D/√n` la escala del promedio. Las identidades
compañeras son `dS2_mul` (`s_D²·(n−1) = Σ φ̂_i²`), `dS2_nonneg`
(`s_D² ≥ 0`), `dS2_add` (invariante por traslación), `dSE_nonneg` y
`dSE_sq` (`ŜE² = s_D²/n`). Fidelidad declarada: se formalizan las
definiciones y el álgebra exacta; la consistencia de la fórmula bajo
cross-fitting (condición de la expansión) es asintótica y no se formaliza
aquí. Origen: enjambre smw82qi6q, m11. -/
theorem dPhi_sum_eq_zero {n : ℕ} (D : Fin n → ℝ) (hn : n ≠ 0) :
    ∑ i, dPhi D i = 0 := by
  have hm : (n : ℝ) * dMean D = ∑ i, D i := dMean_mul D hn
  have hconst : (∑ _i : Fin n, dMean D) = (n : ℝ) * dMean D := by
    simp [Finset.sum_const, nsmul_eq_mul]
  simp only [dPhi]
  rw [Finset.sum_sub_distrib, hconst, hm, sub_self]

theorem dS2_mul {n : ℕ} (D : Fin n → ℝ) (hn : 2 ≤ n) :
    dS2 D * ((n : ℝ) - 1) = ∑ i, dPhi D i ^ 2 := by
  have h2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hne : (n : ℝ) - 1 ≠ 0 := by linarith
  simp only [dS2]
  field_simp

theorem dS2_nonneg {n : ℕ} (D : Fin n → ℝ) (hn : 2 ≤ n) : 0 ≤ dS2 D := by
  have h2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hpos : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  simp only [dS2]
  exact div_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _)) (le_of_lt hpos)

theorem dMean_add {n : ℕ} (D : Fin n → ℝ) (c : ℝ) (hn : n ≠ 0) :
    dMean (fun i => D i + c) = dMean D + c := by
  have h : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  simp only [dMean, Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp

/-- Sumar una constante a todas las contribuciones no cambia `s_D²`. -/
theorem dS2_add {n : ℕ} (D : Fin n → ℝ) (c : ℝ) (hn : 2 ≤ n) :
    dS2 (fun i => D i + c) = dS2 D := by
  have hn0 : n ≠ 0 := by omega
  have hmean : dMean (fun i => D i + c) = dMean D + c := dMean_add D c hn0
  simp only [dS2, dPhi, hmean]
  congr 1
  exact Finset.sum_congr rfl (fun i _ => by ring)

/-- `ŜE ≥ 0` en cuanto `n ≥ 2`. -/
theorem dSE_nonneg {n : ℕ} (D : Fin n → ℝ) (hn : 2 ≤ n) : 0 ≤ dSE D := by
  have hn0 : 0 < n := by omega
  have h1 : (0 : ℝ) ≤ Real.sqrt (dS2 D) := Real.sqrt_nonneg _
  have h2 : (0 : ℝ) ≤ Real.sqrt (n : ℝ) := Real.sqrt_nonneg _
  simp only [dSE]
  exact div_nonneg h1 h2

/-- `ŜE² = s_D²/n` para `n ≥ 2`: la escala del promedio es la raíz de la
varianza estimada dividida por el tamaño muestral. -/
theorem dSE_sq {n : ℕ} (D : Fin n → ℝ) (hn : 2 ≤ n) : dSE D ^ 2 = dS2 D / (n : ℝ) := by
  have h1 : (0 : ℝ) ≤ dS2 D := dS2_nonneg D hn
  have h2 : (0 : ℝ) ≤ (n : ℝ) := by positivity
  have h3 : Real.sqrt (n : ℝ) ≠ 0 := by
    have : (0 : ℝ) < (n : ℝ) := by
      have : 0 < n := by omega
      exact_mod_cast this
    exact ne_of_gt (Real.sqrt_pos.mpr this)
  simp only [dSE]
  rw [div_pow, Real.sq_sqrt h1, Real.sq_sqrt h2]

/-! ## def:ch11-hac — varianza HAC con pesos de Bartlett -/

/-- Promedio de la secuencia en la ventana `{0, …, T−1}`. -/
noncomputable def tMean (φ : ℕ → ℝ) (T : ℕ) : ℝ := (∑ t ∈ range T, φ t) / (T : ℝ)

/-- Autocovarianza estimada de rezago `k` sobre la ventana de longitud `T`:
`ĉ_k = (1/T) Σ_{t=0}^{T−k−1} (φ_{t+k} − φ̄)(φ_t − φ̄)` (indexación desde `0`). -/
noncomputable def acv (φ : ℕ → ℝ) (T k : ℕ) : ℝ :=
  (∑ t ∈ range (T - k), (φ (t + k) - tMean φ T) * (φ t - tMean φ T)) / (T : ℝ)

/-- Peso de Bartlett `1 − k/(K+1)`. -/
noncomputable def bartlett (K k : ℕ) : ℝ := 1 - (k : ℝ) / ((K : ℝ) + 1)

/-- `σ̂²_HAC = ĉ_0 + 2 Σ_{k=1}^K (1 − k/(K+1)) ĉ_k`. -/
noncomputable def hac (φ : ℕ → ℝ) (T K : ℕ) : ℝ :=
  acv φ T 0 + 2 * ∑ k ∈ Icc 1 K, bartlett K k * acv φ T k

@[simp] theorem bartlett_zero (K : ℕ) : bartlett K 0 = 1 := by
  simp [bartlett]

theorem bartlett_nonneg {K k : ℕ} (hk : k ≤ K + 1) : 0 ≤ bartlett K k := by
  have hK : (0 : ℝ) < (K : ℝ) + 1 := by positivity
  have hk' : (k : ℝ) ≤ (K : ℝ) + 1 := by exact_mod_cast hk
  have hle : (k : ℝ) / ((K : ℝ) + 1) ≤ 1 := (div_le_one hK).mpr hk'
  simp only [bartlett]
  linarith

theorem bartlett_le_one (K k : ℕ) : bartlett K k ≤ 1 := by
  have h : (0 : ℝ) ≤ (k : ℝ) / ((K : ℝ) + 1) := by positivity
  simp only [bartlett]
  linarith

theorem bartlett_mem (K k : ℕ) (hk : k ≤ K + 1) : bartlett K k ∈ Set.Icc (0 : ℝ) 1 :=
  ⟨bartlett_nonneg hk, bartlett_le_one K k⟩

theorem tMean_const {T : ℕ} {φ : ℕ → ℝ} {c : ℝ} (hφ : ∀ t, t < T → φ t = c) (hT : T ≠ 0) :
    tMean φ T = c := by
  have hsum : (∑ t ∈ range T, φ t) = (T : ℝ) * c := by
    rw [Finset.sum_congr rfl (fun t ht => hφ t (Finset.mem_range.mp ht)), Finset.sum_const,
      Finset.card_range, nsmul_eq_mul]
  have hT' : (T : ℝ) ≠ 0 := by exact_mod_cast hT
  simp only [tMean, hsum]
  field_simp

theorem acv_const {T k : ℕ} {φ : ℕ → ℝ} {c : ℝ} (hφ : ∀ t, t < T → φ t = c) :
    acv φ T k = 0 := by
  by_cases hT : T = 0
  · subst hT
    simp [acv]
  · have hm : tMean φ T = c := tMean_const hφ hT
    have hzero : ∀ t, t < T - k → (φ (t + k) - c) * (φ t - c) = 0 := by
      intro t ht
      have h1 : t + k < T := by omega
      have h2 : t < T := by omega
      rw [hφ (t + k) h1, hφ t h2, sub_self, zero_mul]
    simp only [acv, hm]
    rw [Finset.sum_eq_zero (fun t ht => hzero t (Finset.mem_range.mp ht)), zero_div]

/-- Una secuencia constante en la ventana tiene `σ̂²_HAC = 0`. -/
theorem hac_const {T K : ℕ} {φ : ℕ → ℝ} {c : ℝ} (hφ : ∀ t, t < T → φ t = c) :
    hac φ T K = 0 := by
  have h0 : acv φ T 0 = 0 := acv_const hφ
  have hk : ∀ k ∈ Icc 1 K, bartlett K k * acv φ T k = 0 := fun k _ => by
    rw [acv_const hφ, mul_zero]
  simp only [hac, h0, Finset.sum_eq_zero hk, mul_zero, add_zero]

/-- Con `K = 0` no hay rezagos: `σ̂²_HAC = ĉ_0`. -/
theorem hac_zero_lags (φ : ℕ → ℝ) (T : ℕ) : hac φ T 0 = acv φ T 0 := by
  simp [hac]

/-- book: capitulos/cap08_intervalos.typ:270 (key: def:ch11-hac) —
varianza HAC con pesos de Bartlett: `ĉ_k = (1/T) Σ_t (φ̂_{t+k} − φ̄)(φ̂_t − φ̄)`,
`σ̂²_HAC = ĉ_0 + 2 Σ_{k=1}^K (1 − k/(K+1)) ĉ_k`. Se prueba que los pesos
Bartlett están en `[0,1]` (`bartlett_mem`), que con `K = 0` la fórmula se
reduce a `ĉ_0` (`hac_zero_lags`), que una secuencia constante en la
ventana da `σ̂²_HAC = 0` (`hac_const`) y que los pesos nunca amplifican:
`|σ̂²_HAC| ≤ |ĉ_0| + 2 Σ_{k=1}^K |ĉ_k|`. Fidelidad declarada: se formaliza
la definición y su álgebra exacta; la consistencia requiere el teorema
límite (`thm:ch11-var-consistente`) y no se formaliza aquí; el crecimiento
de `K` no se postula. Origen: enjambre smw82qi6q, m11. -/
theorem abs_hac_le (φ : ℕ → ℝ) (T K : ℕ) :
    |hac φ T K| ≤ |acv φ T 0| + 2 * ∑ k ∈ Icc 1 K, |acv φ T k| := by
  have hb : ∀ k ∈ Icc 1 K, |bartlett K k * acv φ T k| ≤ |acv φ T k| := by
    intro k hk
    have hk1 : k ≤ K + 1 := by
      have := Finset.mem_Icc.mp hk
      omega
    rw [abs_mul, abs_of_nonneg (bartlett_nonneg hk1)]
    calc bartlett K k * |acv φ T k| ≤ 1 * |acv φ T k| :=
          mul_le_mul_of_nonneg_right (bartlett_le_one K k) (abs_nonneg _)
      _ = |acv φ T k| := one_mul _
  have htri : |∑ k ∈ Icc 1 K, bartlett K k * acv φ T k|
      ≤ ∑ k ∈ Icc 1 K, |acv φ T k| := by
    calc |∑ k ∈ Icc 1 K, bartlett K k * acv φ T k|
        ≤ ∑ k ∈ Icc 1 K, |bartlett K k * acv φ T k| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ k ∈ Icc 1 K, |acv φ T k| := Finset.sum_le_sum hb
  have h2 : |2 * ∑ k ∈ Icc 1 K, bartlett K k * acv φ T k|
      = 2 * |∑ k ∈ Icc 1 K, bartlett K k * acv φ T k| := by
    rw [abs_mul]
    norm_num
  have habs : ∀ u v : ℝ, |u + v| ≤ |u| + |v| := by
    intro u v
    rw [abs_le]
    constructor <;> linarith [neg_abs_le u, neg_abs_le v, le_abs_self u, le_abs_self v]
  simp only [hac]
  calc |acv φ T 0 + 2 * ∑ k ∈ Icc 1 K, bartlett K k * acv φ T k|
      ≤ |acv φ T 0| + |2 * ∑ k ∈ Icc 1 K, bartlett K k * acv φ T k| := habs _ _
    _ = |acv φ T 0| + 2 * |∑ k ∈ Icc 1 K, bartlett K k * acv φ T k| := by rw [h2]
    _ ≤ |acv φ T 0| + 2 * ∑ k ∈ Icc 1 K, |acv φ T k| := by
        have := mul_le_mul_of_nonneg_left htri (by norm_num : (0 : ℝ) ≤ 2)
        linarith

/-! ## ex:ch11-ej5 — SAVE: término de separación entre bloques -/

/-- book: capitulos/cap08_intervalos.typ:672 (key: ex:ch11-ej5) —
SAVE y orden de aprendizaje: si `a_k` son pesos predeterminados con
`Σ_k a_k = 1` y `J(π_k)` es el valor de la política entrenada antes del
bloque `k`, el promedio ponderado se descompone como
`Σ_k a_k J(π_k) = J(π_f) + Σ_k a_k (J(π_k) − J(π_f))`. El término de
separación **no se anula por respetar el orden temporal**: solo mide la
distancia de cada bloque a la política final `π_f`, y con pesos positivos
y valores de bloque estrictamente mayores que `J(π_f)` es estrictamente
positivo. Fidelidad declarada: se formaliza la identidad algebraica y su
no anulación (el contenido exacto del ejercicio); no se formaliza el
procedimiento SAVE del artículo original (partición, agregación y
studentización), que el libro describe en prosa.
Origen: enjambre smw82qi6q, m11. -/
theorem save_separacion {K : ℕ} (a J : Fin K → ℝ) (Jf : ℝ) (ha : ∑ k, a k = 1) :
    (∑ k, a k * J k) = Jf + ∑ k, a k * (J k - Jf) := by
  have h : (∑ k, a k * (J k - Jf)) = (∑ k, a k * J k) - Jf := by
    simp only [mul_sub]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, ha, one_mul]
  rw [h]
  ring

/-- book: capitulos/cap08_intervalos.typ:672 (key: ex:ch11-ej5) —
el término de separación de SAVE no se anula en general: con dos bloques
igualmente ponderados (`a = (1/2, 1/2)`), valores de bloque `J(π_0)=0`,
`J(π_1)=2` y política final de valor `J(π_f)=0`, el promedio ponderado
vale `1`, el término de separación vale `1 ≠ 0`, y por tanto promediar
evaluaciones de políticas distintas no estima el valor de la política
final. Origen: enjambre smw82qi6q, m11. -/
theorem save_separacion_no_nula :
    ∃ a J : Fin 2 → ℝ, ∃ Jf : ℝ,
      (∑ k, a k = 1) ∧ (∑ k, a k * J k) = 1
        ∧ (∑ k, a k * (J k - Jf)) = 1 ∧ Jf = 0 := by
  refine ⟨fun _ => 1 / 2, fun k => if (k : ℕ) = 1 then 2 else 0, 0, ?_, ?_, ?_, rfl⟩
  · rw [Fin.sum_univ_two]; norm_num
  · rw [Fin.sum_univ_two]; norm_num
  · rw [Fin.sum_univ_two]; norm_num

/-- book: capitulos/cap08_intervalos.typ:672 (key: ex:ch11-ej5) —
con pesos estrictamente positivos y bloques cuyo valor supera
estrictamente al de la política final, el término de separación es
estrictamente positivo: el orden temporal no lo cancela.
Origen: enjambre smw82qi6q, m11. -/
theorem save_separacion_pos {K : ℕ} (a J : Fin K → ℝ) (Jf : ℝ) (hK : 0 < K)
    (ha : ∀ k, 0 < a k) (hJ : ∀ k, Jf < J k) :
    0 < ∑ k, a k * (J k - Jf) := by
  apply Finset.sum_pos
  · intro k _
    exact mul_pos (ha k) (by linarith [hJ k])
  · exact ⟨⟨0, hK⟩, Finset.mem_univ _⟩

/-! ## Verificación de axiomas -/

#print axioms dMean_mul
#print axioms dPhi_sum_eq_zero
#print axioms dS2_mul
#print axioms dS2_nonneg
#print axioms dS2_add
#print axioms dSE_nonneg
#print axioms dSE_sq
#print axioms bartlett_mem
#print axioms hac_zero_lags
#print axioms hac_const
#print axioms abs_hac_le
#print axioms save_separacion
#print axioms save_separacion_no_nula
#print axioms save_separacion_pos

end Cap08Estimadores
