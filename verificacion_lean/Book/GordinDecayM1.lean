/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m1 (dirección d2).

# Gordin: de la contracción por bloques al decaimiento geométrico puntual

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

Este módulo cubre el hueco explícito que `Book/GordinDoeblin.lean` deja abierto:
`ApendiceDGordinDoeblin.contraction_iterate` sólo acota las potencias del bloque,
`|((P^k)^n g)_x| ≤ (1 − m)^n · sup|g|`. Aquí se pasa de esa cota de bloques a una
cota geométrica **puntual en el número de pasos `t`**:

* `abs_mulVec_pow_le` — para todo `t`, con `q = t / k`, `r = t % k`,
  `|(P^t g)_x| ≤ (1 − m)^(t / k) · B`, usando `P^t = P^r · P^(k q)`,
  `P^(k q) = (P^k)^q` (`pow_mul`) y que `P^r` es estocástica y no negativa;
* `exists_geom_bound` — constantes **explícitas** `ρ = 1 − m/(2k) ∈ (0,1)`,
  `C = (ρ⁻¹)^(k−1)` con `(1 − m)^(t/k) ≤ C ρ^t` para todo `t`;
* `summable_mulVec_pow`, `tsum_abs_mulVec_pow_le` — sumabilidad absoluta y cota
  del total, uniforme en el estado;
* `poissonSeries` y `poissonSeries_poisson` — `h = ∑_t P^t g` resuelve
  `h − P h = g` (ecuación de Poisson) sin teoría espectral;
* las versiones `Chain`, sin modificar la estructura: `Chain.toMatrix` (`D.P`
  vista como `Matrix`), `Chain.exists_block_witness`,
  `Chain.geom_decay_of_primitive`, `Chain.tendsto_evalP_of_primitive`,
  `Chain.summable_evalP_of_primitive`,
  `Chain.exists_uniform_tsum_abs_le_of_primitive`,
  `Chain.poissonSeries_poisson_of_primitive`,
  `Chain.avg_poissonSeries_of_primitive` (`π(h) = 0`) y
  `Chain.eq_poissonSeries_of_poisson` (unicidad), todas bajo la hipótesis
  `Matrix.IsPrimitive D.toMatrix`.

La identificación `σ² = γ(0) + 2∑_{k≥1} γ(k)` que se construye con estas piezas
está en `GordinSigmaSeriesM1.lean`. **Fidelidad declarada.** No se prueba el CLT
de Gordin ni Skorokhod. No se construye `π` desde `P`. No se construye la
periodicidad de ningún estado: la aperiodicidad entra como `Matrix.IsPrimitive`
(y sin ella el enunciado es falso; véase `DEUDA.md` §2.2). `C.thm:appD-gordin`
sigue `pending`.
-/
import Mathlib
import Book.GordinDoeblin
import Book.GordinCoreM8

open Finset
open scoped Matrix

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

namespace ApendiceDGordinBloques

variable {S : Type*} [Fintype S] [DecidableEq S] [Nonempty S]

/-! ## 1. Potencias no negativas y descomposición en bloques -/

/-- Las potencias de una matriz de entradas no negativas tienen entradas no
negativas. -/
theorem pow_apply_nonneg {P : Matrix S S ℝ} (hP0 : ∀ i j, 0 ≤ P i j) (t : ℕ) :
    ∀ i j, 0 ≤ (P ^ t) i j := by
  induction t with
  | zero =>
    intro i j
    rw [pow_zero, Matrix.one_apply]
    split <;> norm_num
  | succ n ih =>
    intro i j
    rw [pow_succ', Matrix.mul_apply]
    exact Finset.sum_nonneg fun l _ => mul_nonneg (hP0 i l) (ih l j)

/-- Separación del bloque: `P^t = P^(t % k) · P^(k · (t / k))`. -/
theorem pow_eq_mod_mul_div (P : Matrix S S ℝ) {k : ℕ} (t : ℕ) :
    P ^ t = P ^ (t % k) * P ^ (k * (t / k)) := by
  rw [← pow_add, Nat.mod_add_div]

/-! ## 2. Decaimiento puntual para exponente arbitrario -/

/-- **De bloques a decaimiento puntual.** Si `M = P^k` está acotada inferiormente
por `m > 0` (y `m ≤ 1`) y `g` está `π`-centrada con `|g| ≤ B`, entonces para
**todo** `t` (no sólo múltiplos de `k`)

  `|(P^t g)_x| ≤ (1 − m)^(t / k) · B`.

La prueba reagrupa `t = (t % k) + k · (t / k)`, aplica la contracción de bloques a
`P^(k·(t/k)) = (P^k)^(t/k)` y propaga la cota con la fila estocástica `P^(t%k)`. -/
theorem abs_mulVec_pow_le (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ}
    (hP0 : ∀ i j, 0 ≤ P i j) (hP1 : ∀ i, ∑ j, P i j = 1)
    (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0) {B : ℝ} (hB : ∀ y, |g y| ≤ B) :
    ∀ t : ℕ, ∀ x : S, |(P ^ t *ᵥ g) x| ≤ (1 - m) ^ (t / k) * B := by
  intro t x
  have hB0 : 0 ≤ B := le_trans (abs_nonneg (g (Classical.arbitrary S))) (hB _)
  have hdec : ∀ y, |(P ^ (k * (t / k)) *ᵥ g) y| ≤ (1 - m) ^ (t / k) * B := by
    intro y
    rw [pow_mul]
    exact ApendiceDGordinDoeblin.contraction_iterate P π hP1 hinv hπ0 hπ1 hm0 hm1 hm
      (t / k) g hg B hB y
  have hmul : (P ^ t *ᵥ g) x = (P ^ (t % k) *ᵥ (P ^ (k * (t / k)) *ᵥ g)) x := by
    rw [pow_eq_mod_mul_div P t, Matrix.mulVec_mulVec]
  rw [hmul, Matrix.mulVec_apply_eq_sum]
  calc |∑ y, (P ^ (t % k)) x y * (P ^ (k * (t / k)) *ᵥ g) y|
      ≤ ∑ y, |(P ^ (t % k)) x y * (P ^ (k * (t / k)) *ᵥ g) y| :=
        Finset.abs_sum_le_sum_abs _ _
    _ = ∑ y, (P ^ (t % k)) x y * |(P ^ (k * (t / k)) *ᵥ g) y| := by
        refine Finset.sum_congr rfl fun y _ => ?_
        rw [abs_mul, abs_of_nonneg (pow_apply_nonneg hP0 (t % k) x y)]
    _ ≤ ∑ y, (P ^ (t % k)) x y * ((1 - m) ^ (t / k) * B) := by
        refine Finset.sum_le_sum fun y _ => ?_
        exact mul_le_mul_of_nonneg_left (hdec y) (pow_apply_nonneg hP0 (t % k) x y)
    _ = (∑ y, (P ^ (t % k)) x y) * ((1 - m) ^ (t / k) * B) := (Finset.sum_mul ..).symm
    _ = (1 - m) ^ (t / k) * B := by
        rw [ApendiceDGordinDoeblin.pow_sum_one P hP1 (t % k) x, one_mul]

/-! ## 3. Constantes geométricas explícitas: `ρ = 1 − m/(2k)`, `C = (ρ⁻¹)^(k−1)` -/

/-- **Forma geométrica en `t`.** Con `0 < m ≤ 1` y `k > 0` existen constantes
explícitas `ρ = 1 − m/(2k) ∈ (0,1)` y `C > 0` tales que
`(1 − m)^(t/k) ≤ C · ρ^t` para todo `t ∈ ℕ`.

`ρ` se elige con `1 − m/(2k)`, no con `(1−m)^(1/k)`, para que sea un número real
elemental (sin raíces reales): la desigualdad de Bernoulli da `1 − m ≤ ρ^k`, y el
resto es comparar exponentes (`k·(t/k) ≥ t − (k−1)` y el caso `t < k`). -/
theorem exists_geom_bound {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) {k : ℕ} (hk : 0 < k) :
    ∃ ρ C : ℝ, 0 < ρ ∧ ρ < 1 ∧ 0 < C ∧
      ∀ t : ℕ, (1 - m) ^ (t / k) ≤ C * ρ ^ t := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have h2k : (0 : ℝ) < 2 * (k : ℝ) := by positivity
  set ρ : ℝ := 1 - m / (2 * (k : ℝ)) with hρdef
  have hfrac_nonneg : 0 ≤ m / (2 * (k : ℝ)) := by positivity
  have hfrac_pos : 0 < m / (2 * (k : ℝ)) := by positivity
  have hfrac_le : m / (2 * (k : ℝ)) ≤ 1 / 2 := by
    rw [div_le_iff₀ h2k]
    nlinarith
  have hρ0 : 0 < ρ := by simp only [hρdef]; linarith
  have hρ1 : ρ < 1 := by simp only [hρdef]; linarith
  -- Bernoulli: `1 − m ≤ ρ^k`
  have hneg : (k : ℝ) * (-(m / (2 * (k : ℝ)))) = -(m / 2) := by
    field_simp
  have hbern : 1 - m ≤ ρ ^ k := by
    have hstep : 1 - m ≤ 1 + (k : ℝ) * (-(m / (2 * (k : ℝ)))) := by
      rw [hneg]; linarith
    have hbernoulli : 1 + (k : ℝ) * (-(m / (2 * (k : ℝ)))) ≤ (1 + -(m / (2 * (k : ℝ)))) ^ k :=
      one_add_mul_le_pow (by linarith) k
    have hbase : (1 + -(m / (2 * (k : ℝ)))) = ρ := by simp only [hρdef]; ring
    rw [hbase] at hbernoulli
    exact hstep.trans hbernoulli
  refine ⟨ρ, (ρ⁻¹) ^ (k - 1), hρ0, hρ1, by positivity, fun t => ?_⟩
  have h1 : (1 - m) ^ (t / k) ≤ ρ ^ (k * (t / k)) := by
    calc (1 - m) ^ (t / k) ≤ (ρ ^ k) ^ (t / k) :=
          pow_le_pow_left₀ (by linarith) hbern (t / k)
      _ = ρ ^ (k * (t / k)) := (pow_mul ρ k (t / k)).symm
  have htmod : t % k + k * (t / k) = t := Nat.mod_add_div t k
  have hmono : t - (k - 1) ≤ k * (t / k) := by
    have := Nat.mod_lt t hk
    omega
  have h3 : ρ ^ (k * (t / k)) ≤ ρ ^ (t - (k - 1)) :=
    pow_le_pow_of_le_one (le_of_lt hρ0) (le_of_lt hρ1) hmono
  rcases le_or_gt (k - 1) t with hcase | hcase
  · -- caso `t ≥ k − 1`: `ρ^(t−(k−1)) = ρ^t · (ρ^(k−1))⁻¹ = ρ^t · C`
    have h4 : ρ ^ (t - (k - 1)) * ρ ^ (k - 1) = ρ ^ t := by
      rw [← pow_add, Nat.sub_add_cancel hcase]
    have h5 : ρ ^ (t - (k - 1)) = ρ ^ t * (ρ⁻¹) ^ (k - 1) := by
      have hne : ρ ^ (k - 1) ≠ 0 := pow_ne_zero _ (ne_of_gt hρ0)
      calc ρ ^ (t - (k - 1)) = ρ ^ (t - (k - 1)) * 1 := (mul_one _).symm
        _ = ρ ^ (t - (k - 1)) * (ρ ^ (k - 1) * (ρ ^ (k - 1))⁻¹) := by
              rw [mul_inv_cancel₀ hne, mul_one]
        _ = (ρ ^ (t - (k - 1)) * ρ ^ (k - 1)) * (ρ ^ (k - 1))⁻¹ := by ring
        _ = ρ ^ t * (ρ ^ (k - 1))⁻¹ := by rw [h4]
        _ = ρ ^ t * (ρ⁻¹) ^ (k - 1) := by rw [inv_pow]
    calc (1 - m) ^ (t / k) ≤ ρ ^ (t - (k - 1)) := h1.trans h3
      _ = (ρ⁻¹) ^ (k - 1) * ρ ^ t := by rw [h5]; ring
  · -- caso `t < k − 1`: entonces `t / k = 0` y `C · ρ^t ≥ C · ρ^(k−1) = 1`
    have htk : t < k := by omega
    have ht0 : t / k = 0 := Nat.div_eq_of_lt htk
    have h5 : ρ ^ (k - 1) ≤ ρ ^ t :=
      pow_le_pow_of_le_one (le_of_lt hρ0) (le_of_lt hρ1) (by omega)
    have hone : (ρ⁻¹) ^ (k - 1) * ρ ^ (k - 1) = 1 := by
      rw [← mul_pow, inv_mul_cancel₀ (ne_of_gt hρ0), one_pow]
    rw [ht0, pow_zero]
    calc (1 : ℝ) = (ρ⁻¹) ^ (k - 1) * ρ ^ (k - 1) := hone.symm
      _ ≤ (ρ⁻¹) ^ (k - 1) * ρ ^ t := by
          have hpos : 0 ≤ (ρ⁻¹) ^ (k - 1) := by positivity
          exact mul_le_mul_of_nonneg_left h5 hpos

/-! ## 4. Sumabilidad absoluta y cota del total -/

/-- Lema genérico: una sucesión dominada por `C · ρ^t` es sumable y su serie de
valores absolutos está acotada por `C · (1 − ρ)⁻¹`. -/
theorem summable_of_geom_bound {F : ℕ → ℝ} {ρ C : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1)
    (hC0 : 0 ≤ C) (hF : ∀ t : ℕ, |F t| ≤ C * ρ ^ t) :
    Summable F ∧ ∑' t : ℕ, |F t| ≤ C * (1 - ρ)⁻¹ := by
  have hgeom : Summable (fun t : ℕ => C * ρ ^ t) :=
    (summable_geometric_of_lt_one (le_of_lt hρ0) hρ1).mul_left C
  have habs : Summable (fun t : ℕ => |F t|) :=
    Summable.of_nonneg_of_le (fun t => abs_nonneg _) hF hgeom
  refine ⟨habs.of_abs, ?_⟩
  have h := Summable.tsum_le_tsum hF habs hgeom
  have hval : ∑' t : ℕ, C * ρ ^ t = C * (1 - ρ)⁻¹ := by
    rw [tsum_mul_left, tsum_geometric_of_lt_one (le_of_lt hρ0) hρ1]
  rwa [hval] at h

/-- Sumabilidad absoluta de `t ↦ (P^t g)_x` para `g` centrada, a partir de la
contracción de bloques. -/
theorem summable_abs_mulVec_pow (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ} (hk : 0 < k)
    (hP0 : ∀ i j, 0 ≤ P i j) (hP1 : ∀ i, ∑ j, P i j = 1)
    (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0) {B : ℝ} (hB : ∀ y, |g y| ≤ B) :
    ∀ x : S, Summable (fun t : ℕ => |(P ^ t *ᵥ g) x|) := by
  intro x
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := exists_geom_bound hm0 hm1 hk
  have hB0 : 0 ≤ B := le_trans (abs_nonneg (g (Classical.arbitrary S))) (hB _)
  refine (summable_of_geom_bound hρ0 hρ1 (mul_nonneg (le_of_lt hC0) hB0) ?_).1.abs
  intro t
  calc |(P ^ t *ᵥ g) x| ≤ (1 - m) ^ (t / k) * B := abs_mulVec_pow_le P π hP0 hP1 hinv hπ0 hπ1
        hm0 hm1 hm hg hB t x
    _ ≤ (C * ρ ^ t) * B := mul_le_mul_of_nonneg_right (hbound t) hB0
    _ = C * B * ρ ^ t := by ring

/-- Sumabilidad (sin valor absoluto) de `t ↦ (P^t g)_x` para `g` centrada. -/
theorem summable_mulVec_pow (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ} (hk : 0 < k)
    (hP0 : ∀ i j, 0 ≤ P i j) (hP1 : ∀ i, ∑ j, P i j = 1)
    (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0) {B : ℝ} (hB : ∀ y, |g y| ≤ B) :
    ∀ x : S, Summable (fun t : ℕ => (P ^ t *ᵥ g) x) :=
  fun x => (summable_abs_mulVec_pow P π hk hP0 hP1 hinv hπ0 hπ1 hm0 hm1 hm hg hB x).of_abs

/-- Cota del total: `∑_t |(P^t g)_x| ≤ C · B · (1 − ρ)⁻¹`, con `ρ, C` explícitos y
**uniforme en el estado `x`**. -/
theorem tsum_abs_mulVec_pow_le (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ} (hk : 0 < k)
    (hP0 : ∀ i j, 0 ≤ P i j) (hP1 : ∀ i, ∑ j, P i j = 1)
    (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0) {B : ℝ} (hB : ∀ y, |g y| ≤ B) :
    ∃ K : ℝ, 0 ≤ K ∧ ∀ x : S, ∑' t : ℕ, |(P ^ t *ᵥ g) x| ≤ K := by
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := exists_geom_bound hm0 hm1 hk
  have hB0 : 0 ≤ B := le_trans (abs_nonneg (g (Classical.arbitrary S))) (hB _)
  refine ⟨C * B * (1 - ρ)⁻¹, ?_, fun x => ?_⟩
  · have h1 : 0 ≤ (1 - ρ)⁻¹ := inv_nonneg.mpr (by linarith)
    exact mul_nonneg (mul_nonneg (le_of_lt hC0) hB0) h1
  · refine (summable_of_geom_bound hρ0 hρ1 (mul_nonneg (le_of_lt hC0) hB0) (fun t => ?_)).2
    calc |(P ^ t *ᵥ g) x| ≤ (1 - m) ^ (t / k) * B := abs_mulVec_pow_le P π hP0 hP1 hinv hπ0
          hπ1 hm0 hm1 hm hg hB t x
      _ ≤ (C * ρ ^ t) * B := mul_le_mul_of_nonneg_right (hbound t) hB0
      _ = C * B * ρ ^ t := by ring

/-! ## 5. La serie de Poisson `h = ∑_t P^t g` -/

/-- Serie de Poisson: `h x = ∑_t (P^t g) x`. -/
noncomputable def poissonSeries (P : Matrix S S ℝ) (g : S → ℝ) : S → ℝ :=
  fun x => ∑' t : ℕ, (P ^ t *ᵥ g) x

/-- **Ecuación de Poisson.** Con `g` `π`-centrada, la serie de Poisson resuelve
`h − P h = g`, sin teoría espectral y sin invertir `I − P`. -/
theorem poissonSeries_poisson (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ} (hk : 0 < k)
    (hP0 : ∀ i j, 0 ≤ P i j) (hP1 : ∀ i, ∑ j, P i j = 1)
    (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0) {B : ℝ} (hB : ∀ y, |g y| ≤ B) :
    ∀ x : S, poissonSeries P g x - (P *ᵥ poissonSeries P g) x = g x := by
  have hsum : ∀ y, Summable (fun t : ℕ => (P ^ t *ᵥ g) y) :=
    fun y => summable_mulVec_pow P π hk hP0 hP1 hinv hπ0 hπ1 hm0 hm1 hm hg hB y
  intro x
  -- paso 1: expandir `(P *ᵥ h) x` y conmutar la suma finita con la serie
  have hA : (P *ᵥ poissonSeries P g) x
      = ∑ y, ∑' t : ℕ, P x y * (P ^ t *ᵥ g) y := by
    rw [Matrix.mulVec_apply_eq_sum]
    refine Finset.sum_congr rfl fun y _ => ?_
    exact (tsum_mul_left (f := fun t : ℕ => (P ^ t *ᵥ g) y) (a := P x y)).symm
  have hB1 : (∑ y, ∑' t : ℕ, P x y * (P ^ t *ᵥ g) y)
      = ∑' t : ℕ, ∑ y, P x y * (P ^ t *ᵥ g) y :=
    (Summable.tsum_finsetSum (f := fun y t => P x y * (P ^ t *ᵥ g) y) (s := Finset.univ)
      (fun y _ => (hsum y).mul_left (P x y))).symm
  have hC1 : ∀ t : ℕ, (∑ y, P x y * (P ^ t *ᵥ g) y) = (P ^ (t + 1) *ᵥ g) x := by
    intro t
    rw [← Matrix.mulVec_apply_eq_sum (M := P) (v := fun y => (P ^ t *ᵥ g) y)]
    rw [Matrix.mulVec_mulVec, ← pow_succ']
  have hst : (P *ᵥ poissonSeries P g) x = ∑' t : ℕ, (P ^ (t + 1) *ᵥ g) x := by
    rw [hA, hB1]
    exact tsum_congr hC1
  -- paso 2: separar el término `t = 0`
  have hD : poissonSeries P g x = (P ^ 0 *ᵥ g) x + ∑' t : ℕ, (P ^ (t + 1) *ᵥ g) x :=
    Summable.tsum_eq_zero_add (hsum x)
  have h0 : (P ^ 0 *ᵥ g) x = g x := by simp
  rw [hD, hst, h0]
  ring

/-! ## 6. Compatibilidad con `Book/GordinCoreM8.Chain`

La matriz de transición de `Chain` es una función `S → S → ℝ`; para poder usar
`Matrix.mulVec`, `(·)^t` y `pow_mul` sin ambigüedad se introduce `Chain.toMatrix`,
que es `D.P` visto como `Matrix S S ℝ` (definicionalmente igual: `toMatrix_apply`
es `rfl`). `D.applyP g x = (D.toMatrix *ᵥ g) x`. Lo único que aporta
`Matrix.IsPrimitive` es el testigo `(k, m)` de la contracción de bloques, que
`Chain` no incluye (no tiene aperiodicidad ni `cesaro_condVar`). -/

end ApendiceDGordinBloques

namespace ApendiceDGordinM8

namespace Chain

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- `D.P` visto como matriz. -/
def toMatrix (D : Chain S) : Matrix S S ℝ := D.P

@[simp] theorem toMatrix_apply (D : Chain S) (i j : S) : D.toMatrix i j = D.P i j := rfl

theorem supBound_nonneg (h : S → ℝ) : 0 ≤ ApendiceDGordinM8.supBound h :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem abs_le_supBound (h : S → ℝ) (y : S) : |h y| ≤ ApendiceDGordinM8.supBound h :=
  Finset.single_le_sum (f := fun y => |h y|) (fun _ _ => abs_nonneg _) (Finset.mem_univ y)

/-- `Chain.applyP` es la multiplicación matriz-vector por `D.toMatrix`. -/
theorem applyP_eq_mulVec (D : Chain S) (g : S → ℝ) :
    D.applyP g = fun x => (D.toMatrix *ᵥ g) x := by
  funext x
  rw [applyP_apply, Matrix.mulVec_apply_eq_sum]
  simp

/-- La esperanza estacionaria de `P^t g` no depende de `t`. -/
theorem avg_applyP_pow (D : Chain S) (g : S → ℝ) (t : ℕ) :
    D.avg (fun x => (D.toMatrix ^ t *ᵥ g) x) = D.avg g := by
  induction t with
  | zero =>
    have h0 : (fun x => (D.toMatrix ^ 0 *ᵥ g) x) = g := by
      funext x
      rw [pow_zero, Matrix.one_mulVec]
    rw [h0]
  | succ n ih =>
    have hstep : (fun x => (D.toMatrix ^ (n + 1) *ᵥ g) x)
        = fun x => (D.toMatrix *ᵥ (fun y => (D.toMatrix ^ n *ᵥ g) y)) x := by
      funext x
      rw [pow_succ', ← Matrix.mulVec_mulVec]
    rw [hstep]
    have h2 : D.avg (fun x => (D.toMatrix *ᵥ (fun y => (D.toMatrix ^ n *ᵥ g) y)) x)
        = D.avg (fun y => (D.toMatrix ^ n *ᵥ g) y) := by
      rw [← applyP_eq_mulVec]
      exact D.avg_applyP _
    rw [h2, ih]

variable (D : Chain S) [Nonempty S]

/-- Testigos de la contracción de bloques que `Chain` no trae: `k > 0` y `m ∈ (0,1]`
con `m ≤ (P^k)_{ij}` para todo par de estados. -/
theorem exists_block_witness (hprim : Matrix.IsPrimitive D.toMatrix) :
    ∃ k : ℕ, 0 < k ∧ ∃ m : ℝ, 0 < m ∧ m ≤ 1 ∧ ∀ i j, m ≤ (D.toMatrix ^ k) i j := by
  obtain ⟨k, hk0, hk⟩ := hprim.exists_pos_pow
  obtain ⟨m, hm0, hm1, hm⟩ :=
    ApendiceDGordinDoeblin.exists_pos_le_of_pos (fun i j => (D.toMatrix ^ k) i j) hk
      (fun i => ApendiceDGordinDoeblin.pow_sum_one D.toMatrix D.P_sum k i)
  exact ⟨k, hk0, m, hm0, hm1, hm⟩

/-- **Decaimiento geométrico explícito** para una función `π`-centrada en una
cadena finita con matriz primitiva. -/
theorem geom_decay_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) :
    ∃ ρ C : ℝ, 0 < ρ ∧ ρ < 1 ∧ 0 ≤ C ∧
      ∀ (t : ℕ) (x : S), |(D.toMatrix ^ t *ᵥ f) x| ≤ C * ρ ^ t := by
  obtain ⟨k, hk0, m, hm0, hm1, hm⟩ := D.exists_block_witness hprim
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := ApendiceDGordinBloques.exists_geom_bound hm0 hm1 hk0
  refine ⟨ρ, C * ApendiceDGordinM8.supBound f, hρ0, hρ1,
    mul_nonneg (le_of_lt hC0) (supBound_nonneg f), ?_⟩
  intro t x
  calc |(D.toMatrix ^ t *ᵥ f) x|
      ≤ (1 - m) ^ (t / k) * ApendiceDGordinM8.supBound f :=
        ApendiceDGordinBloques.abs_mulVec_pow_le D.toMatrix D.π hprim.nonneg D.P_sum
          D.π_inv D.π_nonneg D.π_sum hm0 hm1 hm hf (abs_le_supBound f) t x
    _ ≤ (C * ρ ^ t) * ApendiceDGordinM8.supBound f :=
        mul_le_mul_of_nonneg_right (hbound t) (supBound_nonneg f)
    _ = C * ApendiceDGordinM8.supBound f * ρ ^ t := by ring

/-- **Decaimiento puntual hasta cero**: `(P^t f)_x → 0` geométricamente. -/
theorem tendsto_evalP_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) (x : S) :
    Filter.Tendsto (fun t : ℕ => (D.toMatrix ^ t *ᵥ f) x) Filter.atTop (nhds 0) := by
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := D.geom_decay_of_primitive hprim hf
  have hgeo : Filter.Tendsto (fun t : ℕ => C * ρ ^ t) Filter.atTop (nhds 0) := by
    have h1 : Filter.Tendsto (fun t : ℕ => ρ ^ t) Filter.atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (le_of_lt hρ0) hρ1
    simpa using h1.const_mul C
  rw [tendsto_zero_iff_abs_tendsto_zero]
  exact squeeze_zero (fun t => abs_nonneg _) (fun t => hbound t x) hgeo

/-- **Sumabilidad puntual** de `t ↦ (P^t f)_x`. -/
theorem summable_evalP_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) (x : S) :
    Summable (fun t : ℕ => (D.toMatrix ^ t *ᵥ f) x) := by
  obtain ⟨k, hk0, m, hm0, hm1, hm⟩ := D.exists_block_witness hprim
  exact ApendiceDGordinBloques.summable_mulVec_pow D.toMatrix D.π hk0 hprim.nonneg
    D.P_sum D.π_inv D.π_nonneg D.π_sum hm0 hm1 hm hf (abs_le_supBound f) x

/-- **Cota uniforme en el estado** de `∑_t |(P^t f)_x|` (absorbencia en estado
finito). -/
theorem exists_uniform_tsum_abs_le_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix)
    {f : S → ℝ} (hf : D.avg f = 0) :
    ∃ K : ℝ, 0 ≤ K ∧ ∀ x : S, ∑' t : ℕ, |(D.toMatrix ^ t *ᵥ f) x| ≤ K := by
  obtain ⟨k, hk0, m, hm0, hm1, hm⟩ := D.exists_block_witness hprim
  exact ApendiceDGordinBloques.tsum_abs_mulVec_pow_le D.toMatrix D.π hk0 hprim.nonneg
    D.P_sum D.π_inv D.π_nonneg D.π_sum hm0 hm1 hm hf (abs_le_supBound f)

/-- **La serie de Poisson resuelve la ecuación de Poisson**: con
`h = ∑_t P^t f`, `f = h − P h`. -/
theorem poissonSeries_poisson_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix)
    {f : S → ℝ} (hf : D.avg f = 0) :
    ∀ x : S, f x = ApendiceDGordinBloques.poissonSeries D.toMatrix f x
      - D.applyP (ApendiceDGordinBloques.poissonSeries D.toMatrix f) x := by
  intro x
  obtain ⟨k, hk0, m, hm0, hm1, hm⟩ := D.exists_block_witness hprim
  have h := ApendiceDGordinBloques.poissonSeries_poisson D.toMatrix D.π hk0 hprim.nonneg
    D.P_sum D.π_inv D.π_nonneg D.π_sum hm0 hm1 hm hf (abs_le_supBound f) x
  rw [applyP_eq_mulVec]
  linarith

/-- **La serie de Poisson está centrada**: `π(∑_t P^t f) = 0`. -/
theorem avg_poissonSeries_of_primitive (hprim : Matrix.IsPrimitive D.toMatrix)
    {f : S → ℝ} (hf : D.avg f = 0) :
    D.avg (ApendiceDGordinBloques.poissonSeries D.toMatrix f) = 0 := by
  have hsum : ∀ y : S, Summable (fun t : ℕ => (D.toMatrix ^ t *ᵥ f) y) :=
    fun y => D.summable_evalP_of_primitive hprim hf y
  have h1 : D.avg (ApendiceDGordinBloques.poissonSeries D.toMatrix f)
      = ∑ x : S, ∑' t : ℕ, D.π x * (D.toMatrix ^ t *ᵥ f) x := by
    rw [avg_apply]
    refine Finset.sum_congr rfl fun x _ => ?_
    exact (tsum_mul_left (f := fun t : ℕ => (D.toMatrix ^ t *ᵥ f) x) (a := D.π x)).symm
  rw [h1]
  have h2 : (∑ x : S, ∑' t : ℕ, D.π x * (D.toMatrix ^ t *ᵥ f) x)
      = ∑' t : ℕ, ∑ x : S, D.π x * (D.toMatrix ^ t *ᵥ f) x :=
    (Summable.tsum_finsetSum (f := fun x t => D.π x * (D.toMatrix ^ t *ᵥ f) x)
      (s := Finset.univ) (fun x _ => (hsum x).mul_left (D.π x))).symm
  rw [h2]
  have h3 : ∀ t : ℕ, (∑ x : S, D.π x * (D.toMatrix ^ t *ᵥ f) x) = 0 := by
    intro t
    rw [← avg_apply]
    rw [avg_applyP_pow D f t]
    exact hf
  simp [h3]

/-- **Identificación con la solución de Poisson de `GordinCoreM8`**: toda solución
`h` centrada de `f = h − P h` coincide con la serie `∑_t P^t f`. -/
theorem eq_poissonSeries_of_poisson (hprim : Matrix.IsPrimitive D.toMatrix) {f h : S → ℝ}
    (hf : D.avg f = 0) (hh : D.avg h = 0) (hpois : ∀ x, f x = h x - D.applyP h x) :
    h = ApendiceDGordinBloques.poissonSeries D.toMatrix f := by
  set g : S → ℝ := ApendiceDGordinBloques.poissonSeries D.toMatrix f with hgdef
  have hg_avg : D.avg g = 0 := D.avg_poissonSeries_of_primitive hprim hf
  have hg_pois : ∀ x, f x = g x - D.applyP g x := D.poissonSeries_poisson_of_primitive hprim hf
  have hharm : ∀ x, (h - g) x = D.applyP (h - g) x := by
    intro x
    have hEq : h x - D.applyP h x = g x - D.applyP g x := by rw [← hpois x, ← hg_pois x]
    have hlin : D.applyP (h - g) x = D.applyP h x - D.applyP g x := by
      rw [map_sub]
      rfl
    simp only [Pi.sub_apply]
    linarith
  have havg : D.avg (h - g) = 0 := by
    rw [map_sub, hh, hg_avg, sub_zero]
  have hzero := D.harmonic_eq_zero hharm havg
  funext x
  have hx := hzero x
  simp only [Pi.sub_apply] at hx
  linarith

end Chain

end ApendiceDGordinM8
