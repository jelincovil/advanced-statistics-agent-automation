/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m2 (dirección d3).

# Gordin: covariograma de la cadena finita y la varianza de largo plazo

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

La identificación pendiente del libro es

  `σ² = ∑_{k ∈ ℤ} Cov(f(S_0), f(S_k)) = γ(0) + 2∑_{k≥1} γ(k)`,

con `γ(k) = Cov_π(f(S_0), f(S_k))`. El repositorio ya contiene dos mitades:

* `ApendiceDGordinM8.Chain` (`Book/GordinCoreM8.lean`) — la cadena finita, el
  operador `applyP` y la ecuación de Poisson `h - P h = f`;
* `Book.Ch5CltAgentesCovarianza` — el **paso de Toeplitz**:
  `cov_doble_limite` prueba `(1/n)∑_{i,j<n} γ_{|i−j|} → γ_0 + 2∑_{k≥1}γ_k` a
  partir de `∑|γ_k| < ∞`, y `Ch11M10.sum_dist_range` da la identidad de conteo
  `∑_{i,j<n} γ_{|i−j|} = n γ_0 + 2∑_{k<n}(n−1−k)γ_{k+1}`.

Lo que faltaba es el **puente desde los datos de la cadena hasta ese
covariograma**. Este módulo lo construye y **no** reprobar Toeplitz (lo reusa):

* `covLag D f k` — el covariograma `γ(k) = ⟨f, P^k f⟩_π` de la cadena;
* `twoTime D i j` — la marginal de dos tiempos `P(S_i = y, S_j = z)` calculada
  algebraicamente desde `P` y `π`; su único insumo es la invariancia de `π`
  (la marginal *se define* por la suma sobre el estado inicial);
* `twoTime_eq` — **el colapso de retardo**: `∑_x π_x (P^i)_{xy}(P^{j−i})_{yz}
  = π_y (P^{j−i})_{yz}` para cualesquiera `i j` (el exponente `j − i` es la resta
  truncada, así que la identidad es pura álgebra), probado con `inv_pow`: la
  invariancia de `π` es lo único que hace falta;
* `pairCov_eq_covLag` — la covarianza del par `(i,j)` sólo depende de `|i−j|` y
  vale `γ(|i−j|)`: es exactamente la hipótesis de estacionariedad del
  covariograma que `BookCh5CltAgentesM5.lr_varianza_finita` toma como dato;
* `doubleSum_eq` — `∑_{i,j<n} pairCov(i,j) = n γ_0 + 2∑_{k<n}(n−1−k)γ_{k+1}`;
* `summable_abs_covLag_of_decay` — de `|(P^k f)(x)| ≤ C ρ^k` con `0 ≤ ρ < 1` se
  sigue `∑_k |γ(k)| < ∞` (puente desde el decaimiento geométrico puntual, que es
  la pieza de `d2`, hasta la hipótesis de Toeplitz);
* `tendsto_pairCov_div` / `tendsto_pairCov_div_of_decay` — la conclusión
  `(1/n)∑_{i,j<n} pairCov(i,j) → γ_0 + 2∑_{k≥1}γ_k`, es decir `n·Var(X̄_n) → σ²`
  en el modelo finito del libro;
* `avg_mul_partialP` y `avg_mul_eq_tsum_covLag` — el Fubini discreto que
  convierte `⟨f,h⟩` en `∑_t γ(t)` cuando `h` es el límite de las sumas
  parciales `S_n = ∑_{t<n}P^t f` y `∑|γ| < ∞`;
* `sigmaSq_eq_lrVariance` — la composición final
  `σ² = γ(0) + 2∑_{k≥1}γ(k)`, tomando como hipótesis nombradas las tres piezas
  que aún no están en el repositorio (el paso algebraico de `GordinSigmaM1`,
  el puente `⟨f,h⟩ = ∑γ` y la sumabilidad).

**Lo que NO se prueba aquí** (ver `README.md`): la sumabilidad `∑|γ_k| < ∞` para
una cadena primitiva dada (es la pieza analítica de `d2`: contracción de bloques
`→` decaimiento puntual para todo `t`); la representación `h = ∑_t P^t f` y la
igualdad `π(condVar h) = 2⟨f,h⟩ - ⟨f,f⟩ = γ_0 + 2∑γ_k` (necesita `h`); la medida
de trayectorias (no se construye el espacio de probabilidad: `pairCov` es la
marginal de dos tiempos computada algebraicamente); y el CLT. Tampoco se deriva
`σ² ≥ 0`.
-/
import Book.GordinCoreM8
import Book.GordinDoeblin
import Book.GordinDecayM1
import Book.Ch5CltAgentesCovarianza

open Finset BigOperators Filter
open scoped Topology

set_option maxHeartbeats 1000000
set_option linter.unusedSectionVars false

namespace ApendiceDGordinM8.Chain

variable {S : Type*} [Fintype S] [DecidableEq S] [Nonempty S]

/-! ## 1. `applyP` es `Matrix.mulVec`, y sus iteradas son sus potencias

Se reutilizan `Chain.toMatrix` y `Chain.applyP_eq_mulVec` de
`Book.GordinDecayM1`: no hay una segunda función matricial ni una redeclaración
del puente. -/
/-- La `k`-ésima iteración de `applyP` es la potencia matricial canónica. -/
lemma iterate_applyP_eq_mulVec (D : Chain S) (k : ℕ) (g : S → ℝ) :
    (D.applyP^[k]) g = Matrix.mulVec (D.toMatrix ^ k) g := by
  induction k with
  | zero =>
    funext x
    rw [pow_zero, Matrix.one_mulVec]
    rfl
  | succ n ih =>
    funext x
    rw [Function.iterate_succ_apply', ApendiceDGordinM8.Chain.applyP_eq_mulVec,
      ih, Matrix.mulVec_mulVec, ← pow_succ']


lemma applyP_const_mul (D : Chain S) (c : ℝ) (g : S → ℝ) :
    D.applyP (fun x => c * g x) = fun x => c * D.applyP g x := by
  funext x
  simp only [applyP_apply]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

/-! ## 2. El covariograma `γ(k) = ⟨f, P^k f⟩_π` -/

/-- **Covariograma de la cadena**: `γ(k) = ∑_x π_x f(x) (P^k f)(x)`, es decir
`E_π[f(S_0) f(S_k)]` (la covarianza si `f` está centrada). -/
noncomputable def covLag (D : Chain S) (f : S → ℝ) (k : ℕ) : ℝ :=
  ∑ x, D.π x * (f x * Matrix.mulVec (D.toMatrix ^ k) f x)

/-- `γ(0)` es la varianza estacionaria de `f`. -/
lemma covLag_zero (D : Chain S) (f : S → ℝ) :
    D.covLag f 0 = ∑ x, D.π x * (f x) ^ 2 := by
  simp only [covLag, pow_zero, Matrix.one_mulVec]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- El covariograma escrito en las entradas de la matriz: la forma que usa el
colapso de retardos. -/
lemma covLag_eq_entry (D : Chain S) (f : S → ℝ) (k : ℕ) :
    D.covLag f k = ∑ y, ∑ z, D.π y * ((D.toMatrix ^ k) y z * (f y * f z)) := by
  simp only [covLag, Matrix.mulVec_apply_eq_sum, Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => Finset.sum_congr rfl fun z _ => ?_
  ring

/-- `γ(k)` es la esperanza estacionaria de `f · (P^k f)`. -/
lemma covLag_eq_avg (D : Chain S) (f : S → ℝ) (k : ℕ) :
    D.covLag f k = D.avg (fun x => f x * ((D.applyP^[k]) f) x) := by
  simp only [covLag, avg_apply, iterate_applyP_eq_mulVec]

/-- Las sumas de columnas de `P^k` son `π` (invariancia iterada). Es el único
lugar donde entra la invariancia de la ley estacionaria. -/
lemma colsum_pow (D : Chain S) (k : ℕ) (y : S) :
    ∑ x, D.π x * (D.toMatrix ^ k) x y = D.π y :=
  ApendiceDGordinDoeblin.inv_pow D.toMatrix D.π D.π_inv k y

/-- La esperanza estacionaria de `P^k f` es la de `f`: centrar `f` centra todas
sus potencias. -/
lemma avg_iterate_applyP (D : Chain S) (f : S → ℝ) (k : ℕ) :
    D.avg ((D.applyP^[k]) f) = D.avg f := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ← ih]
    exact D.avg_applyP _

/-! ## 3. La marginal de dos tiempos y el colapso de retardos -/

/-- **Marginal de dos tiempos** `P(S_i = y, S_j = z)`, calculada desde `P` y `π`
sumando sobre el estado inicial: `∑_x π_x (P^i)_{xy} (P^{j−i})_{yz}`. Para
`i ≤ j` esto es la marginal conjunta de los tiempos `i` y `j` en el modelo
finito (`S_i` es el estado tras `i` pasos); para `i > j` el exponente `j − i` se
trunca a `0` y la lectura correcta es la simétrica, que es la que usa `pairCov`.
El colapso de abajo muestra que sólo depende del retardo. -/
noncomputable def twoTime (D : Chain S) (i j : ℕ) (y z : S) : ℝ :=
  ∑ x, D.π x * ((D.toMatrix ^ i) x y * (D.toMatrix ^ (j - i)) y z)

/-- **Colapso de retardos.** La marginal de dos tiempos es `π_y (P^{j−i})_{yz}`:
la covarianza del par sólo depende del retardo. (La identidad es pura álgebra,
sin hipótesis sobre `i` y `j`; la lectura probabilística es válida para `i ≤ j`,
y `pairCov` usa siempre el orden correcto.) -/
theorem twoTime_eq (D : Chain S) (i j : ℕ) (y z : S) :
    D.twoTime i j y z = D.π y * (D.toMatrix ^ (j - i)) y z := by
  calc D.twoTime i j y z
      = ∑ x, (D.π x * (D.toMatrix ^ i) x y) * (D.toMatrix ^ (j - i)) y z := by
        rw [twoTime]
        refine Finset.sum_congr rfl fun x _ => ?_
        ring
    _ = (∑ x, D.π x * (D.toMatrix ^ i) x y) * (D.toMatrix ^ (j - i)) y z := by
        rw [Finset.sum_mul]
    _ = D.π y * (D.toMatrix ^ (j - i)) y z := by rw [colsum_pow]

/-- Las potencias de una matriz no negativa tienen entradas no negativas. -/
lemma pow_entries_nonneg (D : Chain S) : ∀ (k : ℕ) (y z : S), 0 ≤ (D.toMatrix ^ k) y z := by
  intro k
  induction k with
  | zero =>
    intro y z
    rw [pow_zero]
    simp only [Matrix.one_apply]
    split_ifs <;> norm_num
  | succ n ih =>
    intro y z
    rw [pow_succ', Matrix.mul_apply]
    exact Finset.sum_nonneg fun l _ => mul_nonneg (D.P_nonneg y l) (ih l z)

/-- La marginal de dos tiempos es no negativa. -/
lemma twoTime_nonneg (D : Chain S) (i j : ℕ) (y z : S) : 0 ≤ D.twoTime i j y z :=
  Finset.sum_nonneg fun x _ =>
    mul_nonneg (D.π_nonneg x)
      (mul_nonneg (pow_entries_nonneg D i x y) (pow_entries_nonneg D (j - i) y z))

/-- La marginal del tiempo anterior es `π`: `∑_z P(S_i=y, S_j=z) = π_y`. -/
lemma twoTime_sum_right (D : Chain S) (i j : ℕ) (y : S) :
    ∑ z, D.twoTime i j y z = D.π y := by
  have hrow : ∑ z, (D.toMatrix ^ (j - i)) y z = 1 :=
    ApendiceDGordinDoeblin.pow_sum_one D.toMatrix D.P_sum (j - i) y
  calc ∑ z, D.twoTime i j y z
      = ∑ z, ∑ x, D.π x * ((D.toMatrix ^ i) x y * (D.toMatrix ^ (j - i)) y z) := by
        rfl
    _ = ∑ x, ∑ z, D.π x * ((D.toMatrix ^ i) x y * (D.toMatrix ^ (j - i)) y z) :=
        Finset.sum_comm
    _ = ∑ x, D.π x * (D.toMatrix ^ i) x y * (∑ z, (D.toMatrix ^ (j - i)) y z) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun z _ => by ring
    _ = ∑ x, D.π x * (D.toMatrix ^ i) x y := by
        rw [hrow]
        exact Finset.sum_congr rfl fun x _ => mul_one _
    _ = D.π y := D.colsum_pow i y

/-- La marginal de dos tiempos tiene masa total `1`. -/
lemma twoTime_total (D : Chain S) (i j : ℕ) : ∑ y, ∑ z, D.twoTime i j y z = 1 := by
  simp only [twoTime_sum_right, D.π_sum]

/-- Covarianza del par `(i,j)` en el modelo finito: la marginal de dos tiempos
contra `f(y) f(z)`. Para `f` centrada es `Cov_π(f(S_i), f(S_j))`. -/
noncomputable def pairCov (D : Chain S) (f : S → ℝ) (i j : ℕ) : ℝ :=
  ∑ y, ∑ z, (if i ≤ j then D.twoTime i j y z else D.twoTime j i y z) * (f y * f z)

/-- **La covarianza sólo depende del retardo**: `pairCov(i,j) = γ(|i−j|)`. -/
theorem pairCov_eq_covLag (D : Chain S) (f : S → ℝ) (i j : ℕ) :
    D.pairCov f i j = D.covLag f (Nat.dist i j) := by
  by_cases h : i ≤ j
  · simp only [pairCov, covLag_eq_entry, h, ite_true]
    rw [Nat.dist_eq_sub_of_le h]
    refine Finset.sum_congr rfl fun y _ => Finset.sum_congr rfl fun z _ => ?_
    rw [twoTime_eq D i j y z]
    ring
  · simp only [pairCov, covLag_eq_entry, h, ite_false]
    rw [Nat.dist_comm, Nat.dist_eq_sub_of_le (le_of_not_ge h)]
    refine Finset.sum_congr rfl fun y _ => Finset.sum_congr rfl fun z _ => ?_
    rw [twoTime_eq D j i y z]
    ring

/-- La covarianza del par es simétrica. -/
lemma pairCov_comm (D : Chain S) (f : S → ℝ) (i j : ℕ) :
    D.pairCov f i j = D.pairCov f j i := by
  rw [pairCov_eq_covLag, pairCov_eq_covLag, Nat.dist_comm]

/-! ## 4. La identidad de conteo en el modelo finito -/

/-- La suma doble de covarianzas del par es la suma doble del covariograma por
retardos. -/
lemma doubleSum_pairCov_eq_dist (D : Chain S) (f : S → ℝ) (n : ℕ) :
    (∑ i ∈ range n, ∑ j ∈ range n, D.pairCov f i j)
      = ∑ i ∈ range n, ∑ j ∈ range n, D.covLag f (Nat.dist i j) := by
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  exact D.pairCov_eq_covLag f i j

/-- **Identidad finita exacta del covariograma de la cadena**:
`∑_{i,j<n} Cov(f(S_i),f(S_j)) = n γ(0) + 2∑_{k<n}(n−1−k) γ(k+1)`; dividida por
`n²` es `Var` del promedio de esos `n` valores. La identidad de conteo es
`Ch11M10.sum_dist_range` (ya verificada en el repositorio); lo nuevo es que la
suma de la izquierda son las covarianzas de la cadena, no un dato. -/
theorem doubleSum_eq (D : Chain S) (f : S → ℝ) (n : ℕ) :
    (∑ i ∈ range n, ∑ j ∈ range n, D.pairCov f i j)
      = (n : ℝ) * D.covLag f 0
        + 2 * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * D.covLag f (k + 1) := by
  rw [D.doubleSum_pairCov_eq_dist, Ch11M10.sum_dist_range]

/-! ## 5. Del decaimiento geométrico puntual a `∑|γ_k| < ∞` -/

/-- Cota del covariograma por el decaimiento puntual: si `|(P^k f)(x)| ≤ C ρ^k`
entonces `|γ(k)| ≤ (∑_x π_x |f x|)·C ρ^k`. -/
lemma abs_covLag_le (D : Chain S) (f : S → ℝ) {C ρ : ℝ}
    (hC : 0 ≤ C) (hρ : 0 ≤ ρ)
    (hdec : ∀ (k : ℕ) (x : S), |Matrix.mulVec (D.toMatrix ^ k) f x| ≤ C * ρ ^ k) (k : ℕ) :
    |D.covLag f k| ≤ (∑ x, D.π x * |f x|) * (C * ρ ^ k) := by
  have hρk : 0 ≤ ρ ^ k := pow_nonneg hρ k
  have hCk : 0 ≤ C * ρ ^ k := mul_nonneg hC hρk
  calc |D.covLag f k| ≤ ∑ x, D.π x * |f x * Matrix.mulVec (D.toMatrix ^ k) f x| := by
        simp only [covLag]
        refine (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq ?_)
        exact Finset.sum_congr rfl fun x _ => by rw [abs_mul, abs_of_nonneg (D.π_nonneg x)]
    _ ≤ ∑ x, D.π x * |f x| * (C * ρ ^ k) := by
        refine Finset.sum_le_sum fun x _ => ?_
        rw [abs_mul]
        calc D.π x * (|f x| * |Matrix.mulVec (D.toMatrix ^ k) f x|)
            ≤ D.π x * (|f x| * (C * ρ ^ k)) := by
              refine mul_le_mul_of_nonneg_left ?_ (D.π_nonneg x)
              exact mul_le_mul_of_nonneg_left (hdec k x) (abs_nonneg _)
          _ = D.π x * |f x| * (C * ρ ^ k) := by ring
    _ = (∑ x, D.π x * |f x|) * (C * ρ ^ k) := by
        rw [Finset.sum_mul]

/-- **De decaimiento geométrico a sumabilidad absoluta del covariograma.** Es el
puente que convierte la conclusión de la contracción de bloques (pieza `d2`) en
la hipótesis `∑_k |γ_k| < ∞` que exige el lema de Toeplitz `cov_doble_limite`. -/
theorem summable_abs_covLag_of_decay (D : Chain S) (f : S → ℝ)
    {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hdec : ∀ (k : ℕ) (x : S), |Matrix.mulVec (D.toMatrix ^ k) f x| ≤ C * ρ ^ k) :
    Summable fun k : ℕ => |D.covLag f k| := by
  have hgeo : Summable fun k : ℕ => (∑ x, D.π x * |f x|) * (C * ρ ^ k) :=
    ((summable_geometric_of_lt_one hρ0 hρ1).mul_left C).mul_left (∑ x, D.π x * |f x|)
  exact Summable.of_nonneg_of_le (fun k => abs_nonneg _)
    (fun k => abs_covLag_le D f hC hρ0 hdec k) hgeo

/-! ## 6. El límite `n·Var(X̄_n) → γ(0) + 2∑_{k≥1}γ(k)` -/

/-- **Varianza de largo plazo en el modelo finito del libro.** Bajo `∑_k|γ_k| < ∞`
(que la sección 5 reduce a decaimiento geométrico puntual),

  `(1/n)·∑_{i,j<n} Cov(f(S_i),f(S_j)) → γ(0) + 2∑_{k≥1}γ(k)`.

El paso de Toeplitz es `BookCh5CltAgentesCov.cov_doble_limite`; la contribución
propia es haber reducido la suma doble de covarianzas de la cadena (sección 4)
al covariograma por retardos. -/
theorem tendsto_pairCov_div (D : Chain S) (f : S → ℝ)
    (habs : Summable fun k : ℕ => |D.covLag f k|) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ range n, ∑ j ∈ range n, D.pairCov f i j)
      atTop (𝓝 (BookCh5CltAgentesM5.lrVariance (D.covLag f))) := by
  have h := BookCh5CltAgentesCov.cov_doble_limite (D.covLag f) habs
  refine h.congr' ?_
  filter_upwards with n
  rw [D.doubleSum_pairCov_eq_dist]

/-- La misma conclusión con la hipótesis analítica del decaimiento geométrico
puntual explícita (en lugar de la sumabilidad abstracta). -/
theorem tendsto_pairCov_div_of_decay (D : Chain S) (f : S → ℝ)
    {C ρ : ℝ} (hC : 0 ≤ C) (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1)
    (hdec : ∀ (k : ℕ) (x : S), |Matrix.mulVec (D.toMatrix ^ k) f x| ≤ C * ρ ^ k) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ range n, ∑ j ∈ range n, D.pairCov f i j)
      atTop (𝓝 (BookCh5CltAgentesM5.lrVariance (D.covLag f))) :=
  D.tendsto_pairCov_div f (summable_abs_covLag_of_decay D f hC hρ0 hρ1 hdec)

/-- La forma explícita del límite: `σ² = γ(0) + 2∑_{k≥1}γ(k)`. -/
theorem lrVariance_covLag (D : Chain S) (f : S → ℝ) :
    BookCh5CltAgentesM5.lrVariance (D.covLag f)
      = D.covLag f 0 + 2 * ∑' k : ℕ, D.covLag f (k + 1) := rfl

/-- La forma `σ² = 2∑_{t≥0}γ(t) - γ(0)`, que es la de Gordin
`σ² = 2⟨f,h⟩ - ⟨f,f⟩` una vez identificado `∑_t γ(t) = ⟨f,h⟩`. -/
theorem lrVariance_eq_two_tsum (D : Chain S) (f : S → ℝ)
    (habs : Summable fun k : ℕ => |D.covLag f k|) :
    BookCh5CltAgentesM5.lrVariance (D.covLag f) = 2 * (∑' t : ℕ, D.covLag f t) - D.covLag f 0 := by
  have hsum : Summable fun k : ℕ => D.covLag f k := by
    have h2 : Summable fun k : ℕ => ‖D.covLag f k‖ := by
      simpa [Real.norm_eq_abs] using habs
    exact Summable.of_norm h2
  have hsplit : (∑' t : ℕ, D.covLag f t) = D.covLag f 0 + ∑' k : ℕ, D.covLag f (k + 1) :=
    hsum.tsum_eq_zero_add
  rw [lrVariance_covLag, hsplit]
  ring

/-! ## 7. El puente `⟨f,h⟩ = ∑_t γ(t)` y la composición hacia `σ²`

Esta sección **no** construye `h = ∑_t P^t f` (eso es la pieza analítica de
`d2`): toma la convergencia de las sumas parciales como hipótesis y demuestra el
cambio de suma (Fubini discreto) que convierte `⟨f,h⟩` en la serie del
covariograma. -/

/-- Suma parcial del operador: `S_n = ∑_{t<n} P^t f`. -/
noncomputable def partialP (D : Chain S) (f : S → ℝ) (n : ℕ) : S → ℝ :=
  ∑ t ∈ range n, (D.applyP^[t]) f

@[simp] lemma partialP_apply (D : Chain S) (f : S → ℝ) (n : ℕ) (x : S) :
    D.partialP f n x = ∑ t ∈ range n, (D.applyP^[t]) f x :=
  Finset.sum_apply x (range n) (fun t => (D.applyP^[t]) f)

/-- Identidad finita de Fubini: `⟨f, S_n⟩_π = ∑_{t<n} γ(t)`. -/
lemma avg_mul_partialP (D : Chain S) (f : S → ℝ) (n : ℕ) :
    D.avg (fun x => f x * D.partialP f n x) = ∑ t ∈ range n, D.covLag f t := by
  have hfun : (fun x => f x * D.partialP f n x)
      = ∑ t ∈ range n, fun x => f x * (D.applyP^[t]) f x := by
    funext x
    simp only [partialP, Finset.sum_apply, Finset.mul_sum]
  rw [hfun, map_sum]
  exact Finset.sum_congr rfl fun t _ => (D.covLag_eq_avg f t).symm

/-- **`⟨f,h⟩ = ∑_t γ(t)`**: si las sumas parciales convergen puntualmente a `h` y
la serie del covariograma converge absolutamente, entonces la esperanza
estacionaria intercambia con la serie (la suma en `x` es finita, la de `t` es
absolutamente convergente). -/
theorem avg_mul_eq_tsum_covLag (D : Chain S) (f h : S → ℝ)
    (hconv : ∀ x, Tendsto (fun n => D.partialP f n x) atTop (𝓝 (h x)))
    (habs : Summable fun t : ℕ => |D.covLag f t|) :
    D.avg (fun x => f x * h x) = ∑' t : ℕ, D.covLag f t := by
  have hsum : Summable fun t : ℕ => D.covLag f t := by
    have h2 : Summable fun t : ℕ => ‖D.covLag f t‖ := by
      simpa [Real.norm_eq_abs] using habs
    exact Summable.of_norm h2
  have hlim : Tendsto (fun n => ∑ t ∈ range n, D.covLag f t) atTop
      (𝓝 (∑' t : ℕ, D.covLag f t)) := hsum.hasSum.tendsto_sum_nat
  have hstep : Tendsto (fun n => D.avg (fun x => f x * D.partialP f n x)) atTop
      (𝓝 (D.avg (fun x => f x * h x))) := by
    have hterm : ∀ x : S, Tendsto (fun n => (D.π x * f x) * D.partialP f n x) atTop
        (𝓝 ((D.π x * f x) * h x)) := fun x => (hconv x).const_mul (D.π x * f x)
    have hmain := tendsto_finsetSum (Finset.univ : Finset S) (fun x _ => hterm x)
    have hfun : (fun n => D.avg (fun x => f x * D.partialP f n x))
        = fun n => ∑ x : S, (D.π x * f x) * D.partialP f n x := by
      funext n
      simp only [avg_apply]
      exact Finset.sum_congr rfl fun x _ => by ring
    have hval : D.avg (fun x => f x * h x) = ∑ x : S, (D.π x * f x) * h x := by
      simp only [avg_apply]
      exact Finset.sum_congr rfl fun x _ => by ring
    rw [hfun, hval]
    exact hmain
  have hfinal : Tendsto (fun n => D.avg (fun x => f x * D.partialP f n x)) atTop
      (𝓝 (∑' t : ℕ, D.covLag f t)) := by
    have hcongr : (fun n => D.avg (fun x => f x * D.partialP f n x))
        = fun n => ∑ t ∈ range n, D.covLag f t := funext fun n => D.avg_mul_partialP f n
    rw [hcongr]
    exact hlim
  exact tendsto_nhds_unique hstep hfinal

/-- **Composición hacia la identificación del libro.**
`σ² = γ(0) + 2∑_{k≥1}γ(k)` para la cadena finita, a partir de las tres piezas
que el repositorio tiene separadas:

* `hstep` — el paso algebraico `σ² = π(condVar h) = 2⟨f,h⟩ - ⟨f,f⟩` con la
  ecuación de Poisson: **es** `GordinSigmaM1.sigmaSq_eq_two_avg` (swarm
  `smwa5izeq`), que aquí se cita como hipótesis y no se reproba;
* `hbridge` — `⟨f,h⟩ = ∑_t γ(t)`; la sección anterior lo deduce de la
  convergencia de `S_n = ∑_{t<n}P^t f` a `h` (`avg_mul_eq_tsum_covLag`);
* `habs` — `∑_t |γ(t)| < ∞`, que `summable_abs_covLag_of_decay` reduce a
  decaimiento geométrico puntual (pieza `d2`).

Ninguna de las tres se postula como demostrada: son las hipótesis, y `README.md`
dice exactamente qué falta para cada una. -/
theorem sigmaSq_eq_lrVariance (D : Chain S) (f h : S → ℝ)
    (hstep : D.sigmaSq h = 2 * D.avg (fun x => f x * h x) - D.avg (fun x => (f x) ^ 2))
    (hbridge : D.avg (fun x => f x * h x) = ∑' t : ℕ, D.covLag f t)
    (habs : Summable fun t : ℕ => |D.covLag f t|) :
    D.sigmaSq h = BookCh5CltAgentesM5.lrVariance (D.covLag f) := by
  have havg2 : D.avg (fun x => (f x) ^ 2) = D.covLag f 0 := by
    rw [covLag_zero]
    rfl
  rw [hstep, hbridge, havg2]
  exact (lrVariance_eq_two_tsum D f habs).symm

end ApendiceDGordinM8.Chain
