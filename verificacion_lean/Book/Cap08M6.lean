import Mathlib

/-!
# Cap08 (m6) — brecha espectral de la cadena de dos estados y factor AR(1)

Verificación en Lean 4 / Mathlib de dos resultados del capítulo 11
(`capitulos/cap08_intervalos.typ`):

* `cor:ch11-gap`: en `P = [[1/100, 99/100], [99/100, 1/100]]` el
  autovalor no trivial es `-49/50`. Se verifica que `(1,-1)` es
  autovector con ese autovalor, que `(-49/50)^k` alterna signo (por eso
  no basta con ordenar los autovalores reales: hay que mirar el módulo),
  que la brecha en módulo es `1 - 49/50 = 1/50`, la forma cerrada
  `P^(k+1) = ½J + (-49/50)^k (P - ½J)` y la convergencia de las leyes de
  `k` pasos a la uniforme `(1/2, 1/2)`.

* `prop:ch11-impacto`: con autocovarianza `Cov(X_0,X_k) = σ²ρ^k`,
  `|ρ| < 1`, el factor de varianza de la media es
  `σ²_LR = σ²(1 + 2∑_{k≥1} ρ^k) = σ²(1+ρ)/(1-ρ)`; se prueba la
  identidad general y la instancia numérica del libro (`ρ = 95/100` ⟹
  factor `39`; `T_eff = T(1-ρ)/(1+ρ)`; `T = 1000` ⟹ `1000/39 < 1000`).

Fidelidad declarada: la cadena es explícita, de 2 estados y con entradas
racionales exactas; «brecha» se formaliza como `1 - |λ₂|` y se prueba por
separado que `λ₂^k` alterna signo (el punto del libro: no confundir el
gap con el segundo autovalor *sin* valor absoluto). Del ejemplo AR(1) se
formaliza la suma de autocovarianzas como serie geométrica y la
aritmética del ejemplo; no se formaliza un CLT para el proceso, que el
libro explícitamente no afirma en esa forma.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

namespace Cap08M6

/-! ## cor:ch11-gap — la cadena de dos estados y la alternancia -/

/-- Matriz de transición `P = [[1/100, 99/100], [99/100, 1/100]]`
(índices `Bool`: `false` = estado 0). -/
noncomputable def P : Matrix Bool Bool ℝ :=
  fun s s' => if s = s' then 1 / 100 else 99 / 100

/-- Segundo autovalor de la cadena: `λ₂ = -49/50`. -/
noncomputable def lam : ℝ := -49 / 50

/-- Vector `(1, -1)`. -/
noncomputable def w : Bool → ℝ := fun s => if s then -1 else 1

/-- Distribución uniforme `(1/2, 1/2)`. -/
noncomputable def unif : Bool → ℝ := fun _ => 1 / 2

theorem P_row (s : Bool) : ∑ s', P s s' = 1 := by
  cases s <;> rw [Fintype.sum_bool] <;> norm_num [P]

theorem P_col (s' : Bool) : ∑ s, P s s' = 1 := by
  cases s' <;> rw [Fintype.sum_bool] <;> norm_num [P]

theorem P_symm (s s' : Bool) : P s s' = P s' s := by
  cases s <;> cases s' <;> norm_num [P]

/-- `(1,1)` es autovector con autovalor `1` (filas estocásticas). -/
theorem P_eigen_uno (s : Bool) : ∑ s', P s s' * 1 = 1 := by
  simpa only [mul_one] using P_row s

/-- `(1,-1)` es autovector con autovalor `-49/50`. -/
theorem P_eigen_w (s : Bool) : ∑ s', P s s' * w s' = lam * w s := by
  cases s <;> rw [Fintype.sum_bool] <;> norm_num [P, w, lam]

/-- La distribución uniforme es estacionaria. -/
theorem P_estacionaria (s' : Bool) : ∑ s, unif s * P s s' = unif s' := by
  simp only [unif]
  rw [← Finset.mul_sum, P_col]
  norm_num

/-- El autovalor `-49/50` es negativo. -/
theorem lam_neg : lam < 0 := by norm_num [lam]

/-- `λ₂^k` alterna signo: los exponentes pares dan valores positivos y
los impares negativos. Es el punto del libro: ordenar los autovalores
reales ocultaría la alternancia. -/
theorem lam_pow_alterna (k : ℕ) :
    (0 < lam ^ (2 * k)) ∧ (lam ^ (2 * k + 1) < 0) := by
  have hbase : 0 < lam ^ 2 := by norm_num [lam]
  have hpos : ∀ j : ℕ, 0 < lam ^ (2 * j) := by
    intro j
    rw [pow_mul]
    exact pow_pos hbase j
  constructor
  · exact hpos k
  · rw [pow_succ']
    exact mul_neg_of_neg_of_pos (by norm_num [lam]) (hpos k)

/-- Módulo del autovalor no trivial: `|λ₂| = 49/50`. -/
theorem lam_abs : |lam| = 49 / 50 := by
  rw [lam, abs_of_neg] <;> norm_num

/-- La brecha en módulo (`1 - r` del libro, con `r = |λ₂|`) es `1/50`. -/
theorem gap_abs : 1 - |lam| = 1 / 50 := by
  rw [lam_abs] <;> norm_num

/-- El «gap» **sin** módulo (`1 - λ₂`) sería `99/50 > 1`: confundirlos es
el error que el libro advierte. -/
theorem gap_sin_modulo : 1 - lam = 99 / 50 := by norm_num [lam]

/-- Identidad de rango uno para el cuadrado:
`(P²)_{ss'} = ½ + λ₂(P_{ss'} - ½)`. -/
theorem P_sq_apply (s s' : Bool) :
    ∑ t, P s t * P t s' = 1 / 2 + lam * (P s s' - 1 / 2) := by
  cases s <;> cases s' <;> rw [Fintype.sum_bool] <;> norm_num [P, lam]

/-- La misma identidad con el término centrado, que es la que se usa en
la inducción de la forma cerrada. -/
theorem P_mix (s s' : Bool) :
    ∑ t, (P s t - 1 / 2) * P t s' = lam * (P s s' - 1 / 2) := by
  cases s <;> cases s' <;> rw [Fintype.sum_bool] <;> norm_num [P, lam]

/-- Forma cerrada de las potencias: para `k ≥ 1`,
`(P^k)_{ss'} = ½ + λ₂^{k-1}(P_{ss'} - ½)`. -/
theorem P_pow_apply (k : ℕ) (s s' : Bool) :
    (P ^ (k + 1)) s s' = 1 / 2 + lam ^ k * (P s s' - 1 / 2) := by
  induction k generalizing s s' with
  | zero =>
    rw [pow_one, pow_zero, one_mul]
    ring
  | succ n ih =>
    rw [pow_succ, Matrix.mul_apply]
    have h1 : ∑ t : Bool, (P ^ (n + 1)) s t * P t s'
        = ∑ t : Bool, (1 / 2 * P t s' + lam ^ n * ((P s t - 1 / 2) * P t s')) := by
      exact Finset.sum_congr rfl fun t _ => by rw [ih s t]; ring
    rw [h1, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, P_col, P_mix,
      pow_succ]
    ring

/-- Convergencia de las leyes de `k` pasos a la uniforme: es lo que
justifica hablar de «mezcla» con tasa `|λ₂|^k`. -/
theorem P_tendsto (s s' : Bool) :
    Filter.Tendsto (fun k => (P ^ (k + 1)) s s') Filter.atTop (nhds (1 / 2)) := by
  have hmod : |lam| < 1 := by rw [lam_abs]; norm_num
  have h0 : Filter.Tendsto (fun k => lam ^ k) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hmod
  have h1 : Filter.Tendsto (fun k => lam ^ k * (P s s' - 1 / 2)) Filter.atTop (nhds 0) := by
    simpa using h0.mul_const (P s s' - 1 / 2)
  have h2 : Filter.Tendsto (fun k => 1 / 2 + lam ^ k * (P s s' - 1 / 2))
      Filter.atTop (nhds (1 / 2 + 0)) := tendsto_const_nhds.add h1
  simpa only [P_pow_apply, add_zero] using h2

/-- La tasa de convergencia es exactamente `|λ₂|^k`: el error de la ley
de `k+1` pasos respecto de la uniforme es `(-49/50)^k (P_{ss'} - ½)`, con
`|P_{ss'} - ½| = 49/100`. -/
theorem P_error_abs (k : ℕ) (s s' : Bool) :
    |(P ^ (k + 1)) s s' - 1 / 2| = (49 / 50) ^ k * |P s s' - 1 / 2| := by
  rw [P_pow_apply, add_sub_cancel_left, abs_mul, abs_pow, lam_abs]


/-! ## prop:ch11-impacto — dependencia y tamaño efectivo de una media -/

/-- Suma de las autocovarianzas geométricas: para `|ρ| < 1`,
`∑_{k≥1} ρ^k = ρ/(1-ρ)`. Es el contenido de `σ²_LR = σ²(1 + 2∑_{k≥1}ρ^k)`. -/
theorem geom_tsum_succ (ρ : ℝ) (hρ : |ρ| < 1) :
    (∑' k : ℕ, ρ ^ (k + 1)) = ρ / (1 - ρ) := by
  have h : HasSum (fun k : ℕ => ρ ^ k) (1 - ρ)⁻¹ := by
    simpa using hasSum_geometric_of_norm_lt_one (ξ := ρ) (by simpa using hρ)
  have h2 : HasSum (fun k : ℕ => ρ ^ k * ρ) ((1 - ρ)⁻¹ * ρ) := h.mul_right ρ
  have h3 : HasSum (fun k : ℕ => ρ ^ (k + 1)) ((1 - ρ)⁻¹ * ρ) := by
    simpa [pow_succ] using h2
  rw [h3.tsum_eq, div_eq_mul_inv, mul_comm]

/-- `prop:ch11-impacto`, parte algebraica: con autocovarianza
`Cov(X_0,X_k) = σ²ρ^k`, el factor de varianza de la media respecto de
`σ²` es `1 + 2∑_{k≥1}ρ^k = (1+ρ)/(1-ρ)`. -/
theorem prop_ch11_impacto_factor (ρ : ℝ) (hρ : |ρ| < 1) :
    1 + 2 * (∑' k : ℕ, ρ ^ (k + 1)) = (1 + ρ) / (1 - ρ) := by
  rw [geom_tsum_succ ρ hρ]
  have h1 : ρ ≠ 1 := by
    intro h
    rw [h] at hρ
    norm_num at hρ
  field_simp
  ring

/-- El tamaño efectivo `T_eff = T(1-ρ)/(1+ρ)` es menor que `T` en el
régimen de correlación positiva `0 < ρ < 1`: la media dependiente informa
menos que `T` observaciones independientes. -/
theorem prop_ch11_impacto_teff (T ρ : ℝ) (hT : 0 < T) (hρ : 0 < ρ) (hρ1 : ρ < 1) :
    T * (1 - ρ) / (1 + ρ) < T := by
  have h1 : 0 < 1 + ρ := by linarith
  rw [div_lt_iff₀ h1]
  nlinarith

/-- La ventana finita subestima el factor de largo plazo: para `0 < ρ < 1`,
`(1+ρ)/2 ≤ (1+ρ)/(2(1-ρ))`, que es el factor exacto de `T = 2`. -/
theorem prop_ch11_impacto_finito (ρ : ℝ) (hρ : 0 < ρ) (hρ1 : ρ < 1) :
    (1 + ρ) / 2 ≤ (1 + ρ) / (2 * (1 - ρ)) := by
  have h1 : 0 < 1 - ρ := by linarith
  have h2 : 0 < 1 + ρ := by linarith
  have hdiff : (1 + ρ) / (2 * (1 - ρ)) - (1 + ρ) / 2 = (1 + ρ) * ρ / (2 * (1 - ρ)) := by
    field_simp
    ring
  have hnonneg : 0 ≤ (1 + ρ) * ρ / (2 * (1 - ρ)) :=
    div_nonneg (mul_nonneg (le_of_lt h2) (le_of_lt hρ)) (by linarith)
  linarith

/-- Instancia numérica del libro: con `ρ = 95/100` el factor de varianza
es `39`, el tamaño efectivo para `T = 1000` es `1000/39 < 1000` y el
error estándar se multiplica por `√39`, que está entre `6.24` y `6.25`. -/
theorem prop_ch11_impacto_ejemplo :
    (1 + 95 / 100 : ℝ) / (1 - 95 / 100) = 39
    ∧ (1000 : ℝ) * (1 - 95 / 100) / (1 + 95 / 100) = 1000 / 39
    ∧ (1000 : ℝ) * (1 - 95 / 100) / (1 + 95 / 100) < 1000
    ∧ (6.24 : ℝ) < Real.sqrt 39 ∧ Real.sqrt 39 < 6.25 := by
  refine ⟨by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · rw [Real.lt_sqrt (by norm_num)]
    norm_num
  · rw [Real.sqrt_lt' (by norm_num)]
    norm_num

/-! ## prop:ch11-baseline (segunda parte) — la baseline óptima -/

section Baseline

variable {Ω ι : Type*} [Fintype Ω] [Fintype ι] [DecidableEq ι]

/-- Peso total de la fibra de `S` sobre `s`: `E[w · 1{S = s}]`. -/
noncomputable def pesoFibra (p w : Ω → ℝ) (S : Ω → ι) (s : ι) : ℝ :=
  (univ.filter (fun x => S x = s)).sum (fun ω => p ω * w ω)

/-- Baseline óptima (media ponderada de `G` en la fibra):
`b*(s) = E[w·G | S=s] / E[w | S=s]`. -/
noncomputable def bEstrella (p w G : Ω → ℝ) (S : Ω → ι) (s : ι) : ℝ :=
  ((univ.filter (fun x => S x = s)).sum (fun ω => p ω * w ω * G ω)) / pesoFibra p w S s

/-- Completar el cuadrado, versión finita: si `m` es la media ponderada
de `g` con pesos `u` (`m·W = ∑ u·g`, `W = ∑ u`), entonces
`∑ u(g-A)² = ∑ u(g-m)² + W(m-A)²`. -/
theorem completa_cuadrado_finset {α : Type*} (F : Finset α) (u g : α → ℝ)
    (A m W : ℝ) (hW : W = F.sum u) (hm : m * W = F.sum (fun j => u j * g j)) :
    F.sum (fun j => u j * (g j - A) ^ 2)
      = F.sum (fun j => u j * (g j - m) ^ 2) + W * (m - A) ^ 2 := by
  have hsplit : ∀ j : α, u j * (g j - A) ^ 2
      = u j * (g j - m) ^ 2 + (2 * (m - A)) * (u j * (g j - m)) + (m - A) ^ 2 * u j := by
    intro j
    ring
  rw [Finset.sum_congr rfl (fun j _ => hsplit j), Finset.sum_add_distrib,
    Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  have hzero : F.sum (fun j => u j * (g j - m)) = 0 := by
    have h1 : F.sum (fun j => u j * (g j - m))
        = F.sum (fun j => u j * g j) - F.sum (fun j => u j * m) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [h1, ← Finset.sum_mul, ← hW, ← hm]
    ring
  rw [hzero, hW]
  ring

/-- En cada fibra, la baseline óptima minimiza el error cuadrático
ponderado. -/
theorem fibra_optima (p w G : Ω → ℝ) (S : Ω → ι) (s : ι) (b : ι → ℝ)
    (hp : ∀ ω, 0 ≤ p ω) (hw : ∀ ω, 0 ≤ w ω) (hW : 0 < pesoFibra p w S s) :
    (univ.filter (fun x => S x = s)).sum
        (fun ω => p ω * w ω * (G ω - bEstrella p w G S s) ^ 2)
      ≤ (univ.filter (fun x => S x = s)).sum (fun ω => p ω * w ω * (G ω - b s) ^ 2) := by
  have hm : bEstrella p w G S s * pesoFibra p w S s
      = (univ.filter (fun x => S x = s)).sum (fun j => p j * w j * G j) := by
    rw [bEstrella]
    exact div_mul_cancel₀ _ (ne_of_gt hW)
  have hid := completa_cuadrado_finset (univ.filter (fun x => S x = s))
    (fun ω => p ω * w ω) G (b s) (bEstrella p w G S s) (pesoFibra p w S s) rfl hm
  have h1 : 0 ≤ (univ.filter (fun x => S x = s)).sum
      (fun j => p j * w j * (G j - bEstrella p w G S s) ^ 2) :=
    Finset.sum_nonneg fun j _ => mul_nonneg (mul_nonneg (hp j) (hw j)) (sq_nonneg _)
  have h2 : 0 ≤ pesoFibra p w S s * (bEstrella p w G S s - b s) ^ 2 :=
    mul_nonneg (le_of_lt hW) (sq_nonneg _)
  linarith [hid]

/-- `prop:ch11-baseline` (segunda parte): la baseline
`b*(s) = E[w·G|S=s]/E[w|S=s]` minimiza el riesgo cuadrático ponderado
`E[w (G - b(S))²]` entre **todas** las funciones de `S`. -/
theorem prop_ch11_baseline_optima (p w G : Ω → ℝ) (S : Ω → ι) (b : ι → ℝ)
    (hp : ∀ ω, 0 ≤ p ω) (hw : ∀ ω, 0 ≤ w ω)
    (hS : ∀ s ∈ univ.image S, 0 < pesoFibra p w S s) :
    (∑ ω : Ω, p ω * w ω * (G ω - bEstrella p w G S (S ω)) ^ 2)
      ≤ (∑ ω : Ω, p ω * w ω * (G ω - b (S ω)) ^ 2) := by
  have hle : ∀ s ∈ univ.image S,
      (univ.filter (fun x => S x = s)).sum
          (fun ω => p ω * w ω * (G ω - bEstrella p w G S s) ^ 2)
        ≤ (univ.filter (fun x => S x = s)).sum (fun ω => p ω * w ω * (G ω - b s) ^ 2) :=
    fun s hs => fibra_optima p w G S s b hp hw (hS s hs)
  have step : ∀ (c : ι → ℝ),
      (∑ ω : Ω, p ω * w ω * (G ω - c (S ω)) ^ 2)
        = (univ : Finset ι).sum (fun s => (univ.filter (fun x => S x = s)).sum
            (fun ω => p ω * w ω * (G ω - c (S ω)) ^ 2)) := by
    intro c
    rw [Finset.sum_fiberwise (Finset.univ : Finset Ω) S]
  have hfib : ∀ (c : ι → ℝ),
      (∑ ω : Ω, p ω * w ω * (G ω - c (S ω)) ^ 2)
        = (univ : Finset ι).sum (fun s => (univ.filter (fun x => S x = s)).sum
            (fun ω => p ω * w ω * (G ω - c s) ^ 2)) := by
    intro c
    rw [step c]
    exact Finset.sum_congr rfl fun s _ => Finset.sum_congr rfl fun ω hω => by
      rw [Finset.mem_filter] at hω
      rw [hω.2]
  have hle' : ∀ s ∈ (univ : Finset ι),
      (univ.filter (fun x => S x = s)).sum
          (fun ω => p ω * w ω * (G ω - bEstrella p w G S s) ^ 2)
        ≤ (univ.filter (fun x => S x = s)).sum (fun ω => p ω * w ω * (G ω - b s) ^ 2) := by
    intro s _
    by_cases hs : s ∈ univ.image S
    · exact hle s hs
    · have hz : ∀ c : ι → ℝ, (univ.filter (fun x => S x = s)).sum
          (fun ω => p ω * w ω * (G ω - c s) ^ 2) = 0 := by
        intro c
        apply Finset.sum_eq_zero
        intro x hx
        rw [Finset.mem_filter] at hx
        exact absurd (hx.2 ▸ Finset.mem_image_of_mem S (Finset.mem_univ x)) hs
      rw [hz (bEstrella p w G S), hz b]
  rw [hfib (bEstrella p w G S), hfib b]
  exact Finset.sum_le_sum hle'

end Baseline

end Cap08M6
