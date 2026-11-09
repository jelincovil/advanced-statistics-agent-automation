import Mathlib

/-!
# Book.SSCHCap03M7 — `ex:ssch-cap03-b`: estimar la dinámica y calcular el valor

Formaliza el ejemplo `ex:ssch-cap03-b` de `capitulos/cap10_casos.typ:98`
(enjambre `smw9820kx`, dirección `d7`).

Con el diseño de tamaño fijo `m = 80` por fila el libro escribe

  `P̂_{s,a,j} = N_{s,a,j}/m`,  `Cov(P̂_{s,a,·}) = (1/m)(diag(P_{s,a,·}) − P Pᵀ)`

y afirma que las frecuencias son insesgadas; para una política fija,

  `V^π = (I − γP^π)^{-1} r^π`

«el programa usa exactamente esa ecuación», y el estimador plug-in de valor no
es necesariamente insesgado en muestra finita.

Fidelidad declarada:

* El plug-in se formaliza como lo que es en el diseño: si los conteos de una
  fila suman `m`, entonces `N/m` es de nuevo una distribución (fila estocástica).
  Eso es lo que permite aplicarle la ecuación del valor.
* Los momentos del multinomial se formalizan **por extracción** (`exMean`,
  `exCov` sobre `Fin n` con pesos `p`): insesgadez de cada indicador y
  covarianza de dos indicadores `p_j(δ_{jk} − p_k)`, que es la entrada
  `(j,k)` de la matriz anunciada. La aditividad sobre las `m` réplicas
  independientes entra como la hipótesis estándar del diseño (mismo criterio
  que la autocovarianza del AR(1) en `ex:ch4-ar1`); no se deriva aquí de
  `Measure.pi`.
* La ecuación del valor se formaliza en su forma de punto fijo: unicidad de la
  solución de `V = r + γPV` para un kernel estocástico por filas con `γ < 1`
  (contracción en norma sup), cota a priori `|V| ≤ M/(1−γ)`, y contracción de
  la iteración de valores con tasa geométrica `γ^k`. De ahí que
  `(I − γP)^{-1}` esté bien definida y que «usar exactamente esa ecuación»
  determine `V^π`.
* Las cifras `V̂(π₂) ≈ 0.964091`, `V̂(π₃) ≈ 5.570888`, `1.635906`, `5.855945`
  son salida de una corrida con semilla del simulador; no se re-derivan (plan
  §4: nada de aritmética flotante). Lo que se demuestra es la ecuación que el
  programa resuelve y su unicidad.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHCap03M7

/-! ## El plug-in `N/m` es una distribución -/

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — frecuencia
plug-in `P̂_j = N_j ∕ m` del diseño de tamaño fijo por fila. -/
noncomputable def freq {n : ℕ} (N : Fin n → ℕ) (m : ℕ) (j : Fin n) : ℝ :=
  (N j : ℝ) / (m : ℝ)

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — la fila plug-in
suma uno: con `m = 80` conteos por fila, `N/m` es otra distribución sobre los
cinco destinos y por tanto se le puede aplicar la ecuación del valor. -/
theorem freq_sum {n : ℕ} (N : Fin n → ℕ) {m : ℕ} (hm : (m : ℝ) ≠ 0)
    (hN : ∑ j, N j = m) : ∑ j, freq N m j = 1 := by
  simp only [freq]
  rw [← Finset.sum_div, ← Nat.cast_sum, hN, div_self hm]

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — las
frecuencias plug-in no son negativas. -/
theorem freq_nonneg {n : ℕ} (N : Fin n → ℕ) {m : ℕ} (hm : 0 < m) (j : Fin n) :
    0 ≤ freq N m j := by
  simp only [freq]
  have hm' : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  positivity

/-! ## Momentos de una extracción multinomial -/

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — media bajo los
pesos `p` de una fila (`p` es una distribución sobre `Fin n`). -/
def exMean {n : ℕ} (p : Fin n → ℝ) (f : Fin n → ℝ) : ℝ := ∑ j, p j * f j

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — covarianza bajo
los pesos `p`: `E[fg] − E[f]E[g]`. -/
def exCov {n : ℕ} (p : Fin n → ℝ) (f g : Fin n → ℝ) : ℝ :=
  exMean p (fun j => f j * g j) - exMean p f * exMean p g

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **insesgadez**:
la media de cada indicador es la probabilidad correspondiente,
`E[1{X=j}] = p_j`; con `P̂_j = N_j/m` y `m` extracciones esto da `E[P̂_j] = p_j`. -/
theorem exMean_indicator {n : ℕ} (p : Fin n → ℝ) (j : Fin n) :
    exMean p (fun x => if x = j then (1 : ℝ) else 0) = p j := by
  simp only [exMean]
  rw [Finset.sum_eq_single j]
  · simp
  · intro b _ hb
    simp [hb]
  · intro h
    exact absurd (Finset.mem_univ j) h

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **covarianza de
dos indicadores**: `Cov(1{X=j}, 1{X=k}) = p_j(δ_{jk} − p_k)`. Es la entrada
`(j,k)` de `(1/m)(diag(P) − P Pᵀ)`: la diagonal es `p_j(1−p_j)` y fuera de la
diagonal `−p_j p_k`. -/
theorem exCov_indicator {n : ℕ} (p : Fin n → ℝ) (j k : Fin n) :
    exCov p (fun x => if x = j then (1 : ℝ) else 0)
        (fun x => if x = k then (1 : ℝ) else 0)
      = p j * (if j = k then 1 else 0) - p j * p k := by
  have hprod : ∀ x : Fin n,
      (if x = j then (1 : ℝ) else 0) * (if x = k then (1 : ℝ) else 0)
        = if x = j ∧ x = k then 1 else 0 := by
    intro x
    by_cases hx : x = j <;> by_cases hy : x = k <;> simp [hx, hy]
  have h1 : exMean p (fun x => (if x = j then (1 : ℝ) else 0) *
        (if x = k then (1 : ℝ) else 0)) = if j = k then p j else 0 := by
    simp only [hprod]
    by_cases h : j = k
    · subst h
      have hjj : ∀ x : Fin n, (if x = j ∧ x = j then (1 : ℝ) else 0)
          = if x = j then 1 else 0 := by
        intro x; simp
      simp only [hjj]
      exact exMean_indicator p j
    · have hnone : ∀ x : Fin n, ¬(x = j ∧ x = k) := by
        intro x hx
        exact h (hx.1.symm.trans hx.2)
      have hzero : ∀ x : Fin n, (if x = j ∧ x = k then (1 : ℝ) else 0) = 0 := by
        intro x; simp [hnone x]
      simp only [hzero]
      simp [exMean, h]
  rw [exCov, h1, exMean_indicator, exMean_indicator]
  by_cases h : j = k
  · subst h
    simp
  · simp [h]

/-! ## La ecuación del valor: unicidad, cota y contracción -/

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — producto
matriz–vector de una fila escrita como suma explícita: `(P v)_i = ∑_j P_{ij}v_j`.
Se usa esta forma (en lugar de `Matrix.mulVec`) para que todas las cuentas sean
sumas finitas transparentes. -/
noncomputable def mv {n : ℕ} (P : Fin n → Fin n → ℝ) (v : Fin n → ℝ) :
    Fin n → ℝ := fun i => ∑ j, P i j * v j

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — kernel
estocástico por filas: entradas no negativas y cada fila suma uno (lo que
`ex:ssch-cap01` verifica para el simulador y `freq_sum` para el plug-in). -/
def rowStoch {n : ℕ} (P : Fin n → Fin n → ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **núcleo del
argumento**: si `u = γPu` con `P` estocástico por filas y `γ < 1`, entonces
`u = 0`. Prueba en el punto que maximiza `|u|`: `|u_i₀| ≤ γ|u_i₀|`. -/
theorem eq_zero_of_contract {n : ℕ} [NeZero n] {P : Fin n → Fin n → ℝ} {γ : ℝ}
    (hP : rowStoch P) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) {u : Fin n → ℝ}
    (hu : ∀ i, u i = γ * ∑ j, P i j * u j) : ∀ i, u i = 0 := by
  obtain ⟨i₀, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (Fin n)) (fun i => |u i|)
      ⟨0, Finset.mem_univ 0⟩
  have hle : ∀ j, |u j| ≤ |u i₀| := fun j => hmax j (Finset.mem_univ j)
  have h2 : |∑ j, P i₀ j * u j| ≤ |u i₀| := by
    calc |∑ j, P i₀ j * u j| ≤ ∑ j, |P i₀ j * u j| := Finset.abs_sum_le_sum_abs _ _
      _ = ∑ j, P i₀ j * |u j| := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [abs_mul, abs_of_nonneg (hP.1 i₀ j)]
      _ ≤ ∑ j, P i₀ j * |u i₀| :=
        Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hle j) (hP.1 i₀ j)
      _ = |u i₀| := by rw [← Finset.sum_mul, hP.2, one_mul]
  have h4 : |u i₀| = γ * |∑ j, P i₀ j * u j| := by
    rw [hu i₀, abs_mul, abs_of_nonneg hγ0]
  have h3 : |u i₀| ≤ γ * |u i₀| := by
    calc |u i₀| = γ * |∑ j, P i₀ j * u j| := h4
      _ ≤ γ * |u i₀| := mul_le_mul_of_nonneg_left h2 hγ0
  have h5 : |u i₀| = 0 := by
    have h1 : 0 < 1 - γ := by linarith
    nlinarith [abs_nonneg (u i₀)]
  intro i
  have h6 : |u i| = 0 := le_antisymm (by rw [← h5]; exact hle i) (abs_nonneg _)
  exact abs_eq_zero.mp h6

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **unicidad del
valor**: para un kernel estocástico por filas y `0 ≤ γ < 1` hay a lo sumo una
solución de `V = r + γPV`. Por eso `V^π = (I − γP^π)^{-1}r^π` está bien
definida y el programa que resuelve el sistema obtiene *ese* vector. -/
theorem value_unique {n : ℕ} [NeZero n] {P : Fin n → Fin n → ℝ} {r V W : Fin n → ℝ}
    {γ : ℝ} (hP : rowStoch P) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hV : ∀ i, V i = r i + γ * ∑ j, P i j * V j)
    (hW : ∀ i, W i = r i + γ * ∑ j, P i j * W j) : V = W := by
  funext i
  have hu : ∀ i, (V - W) i = γ * ∑ j, P i j * (V - W) j := by
    intro i
    simp only [Pi.sub_apply, hV i, hW i]
    have h : r i + γ * ∑ j, P i j * V j - (r i + γ * ∑ j, P i j * W j)
        = γ * (∑ j, P i j * V j - ∑ j, P i j * W j) := by ring
    rw [h, ← Finset.sum_sub_distrib]
    congr 1
    exact Finset.sum_congr rfl fun j _ => by ring
  have h := eq_zero_of_contract hP hγ0 hγ1 hu i
  simpa [sub_eq_zero] using h

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **cota a
priori** del valor: si `|r| ≤ M` entonces `|V| ≤ M/(1−γ)`. Con las recompensas
del SSCH (`|r| ≤ 2`, `γ = 9/10`) da `|V| ≤ 20 = 2/(1−0.9)`. -/
theorem value_bound {n : ℕ} [NeZero n] {P : Fin n → Fin n → ℝ} {r V : Fin n → ℝ}
    {γ M : ℝ} (hP : rowStoch P) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hV : ∀ i, V i = r i + γ * ∑ j, P i j * V j) (hr : ∀ i, |r i| ≤ M) :
    ∀ i, |V i| ≤ M / (1 - γ) := by
  obtain ⟨i₀, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (Fin n)) (fun i => |V i|)
      ⟨0, Finset.mem_univ 0⟩
  have hle : ∀ j, |V j| ≤ |V i₀| := fun j => hmax j (Finset.mem_univ j)
  have h2 : |∑ j, P i₀ j * V j| ≤ |V i₀| := by
    calc |∑ j, P i₀ j * V j| ≤ ∑ j, |P i₀ j * V j| := Finset.abs_sum_le_sum_abs _ _
      _ = ∑ j, P i₀ j * |V j| := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [abs_mul, abs_of_nonneg (hP.1 i₀ j)]
      _ ≤ ∑ j, P i₀ j * |V i₀| :=
        Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hle j) (hP.1 i₀ j)
      _ = |V i₀| := by rw [← Finset.sum_mul, hP.2, one_mul]
  have h3 : |V i₀| ≤ |r i₀| + γ * |V i₀| := by
    calc |V i₀| = |r i₀ + γ * ∑ j, P i₀ j * V j| := by rw [hV i₀]
      _ ≤ |r i₀| + |γ * ∑ j, P i₀ j * V j| := abs_add_le _ _
      _ = |r i₀| + γ * |∑ j, P i₀ j * V j| := by rw [abs_mul, abs_of_nonneg hγ0]
      _ ≤ |r i₀| + γ * |V i₀| := by
          have := mul_le_mul_of_nonneg_left h2 hγ0
          linarith
  have h4 : |V i₀| ≤ M / (1 - γ) := by
    have hpos : 0 < 1 - γ := by linarith
    rw [le_div_iff₀ hpos]
    nlinarith [hr i₀, abs_nonneg (V i₀)]
  intro i
  exact le_trans (hle i) h4

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — iteración de
valores `V₀ = 0`, `V_{k+1} = r + γPV_k`. -/
noncomputable def viter {n : ℕ} (P : Fin n → Fin n → ℝ) (r : Fin n → ℝ) (γ : ℝ) :
    ℕ → Fin n → ℝ
  | 0 => fun _ => 0
  | k + 1 => fun i => r i + γ * ∑ j, P i j * viter P r γ k j

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — **la iteración
de valores converge geométricamente**: desde cualquier `V` que resuelva
`V = r + γPV`, `|V_i − (PV)_i^{(k)}| ≤ γ^k · M/(1−γ)`. Para `γ = 9/10` el error
se reduce en un factor `0.9` por paso y el límite es `0`. -/
theorem viter_contract {n : ℕ} [NeZero n] {P : Fin n → Fin n → ℝ} {r V : Fin n → ℝ}
    {γ M : ℝ} (hP : rowStoch P) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hV : ∀ i, V i = r i + γ * ∑ j, P i j * V j) (hr : ∀ i, |r i| ≤ M) :
    ∀ k i, |V i - viter P r γ k i| ≤ γ ^ k * (M / (1 - γ)) := by
  have hM : 0 ≤ M := le_trans (abs_nonneg (r 0)) (hr 0)
  have hc : 0 ≤ M / (1 - γ) := by
    apply div_nonneg hM
    linarith
  intro k
  induction k with
  | zero =>
    intro i
    simpa [viter] using value_bound hP hγ0 hγ1 hV hr i
  | succ k ih =>
    intro i
    have hstep : V i - viter P r γ (k + 1) i
        = γ * ∑ j, P i j * (V j - viter P r γ k j) := by
      simp only [viter, hV i]
      have h : r i + γ * ∑ j, P i j * V j - (r i + γ * ∑ j, P i j * viter P r γ k j)
          = γ * (∑ j, P i j * V j - ∑ j, P i j * viter P r γ k j) := by ring
      rw [h, ← Finset.sum_sub_distrib]
      congr 1
      exact Finset.sum_congr rfl fun j _ => by ring
    rw [hstep, abs_mul, abs_of_nonneg hγ0, pow_succ]
    have h1 : |∑ j, P i j * (V j - viter P r γ k j)|
        ≤ ∑ j, P i j * (γ ^ k * (M / (1 - γ))) := by
      calc |∑ j, P i j * (V j - viter P r γ k j)|
          ≤ ∑ j, |P i j * (V j - viter P r γ k j)| := Finset.abs_sum_le_sum_abs _ _
        _ = ∑ j, P i j * |V j - viter P r γ k j| := by
            refine Finset.sum_congr rfl fun j _ => ?_
            rw [abs_mul, abs_of_nonneg (hP.1 i j)]
        _ ≤ ∑ j, P i j * (γ ^ k * (M / (1 - γ))) :=
            Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (ih j) (hP.1 i j)
    have h2 : ∑ j, P i j * (γ ^ k * (M / (1 - γ))) = γ ^ k * (M / (1 - γ)) := by
      rw [← Finset.sum_mul, hP.2, one_mul]
    rw [h2] at h1
    calc γ * |∑ j, P i j * (V j - viter P r γ k j)|
        ≤ γ * (γ ^ k * (M / (1 - γ))) := by
          exact mul_le_mul_of_nonneg_left h1 hγ0
      _ = γ ^ k * γ * (M / (1 - γ)) := by ring

end SSCHCap03M7
