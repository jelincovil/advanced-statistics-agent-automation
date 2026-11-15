/-
Copyright: proyecto des504 — enjambre smwi1z2xl, miembro m8 (dirección 8).

# Gordin: decaimiento geométrico (Doeblin) para la identificación de `σ²`

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

El teorema del libro pide una cadena finita **irreducible y aperiódica**. La
estructura `ApendiceDGordinM8.Chain` (en `Book/GordinCoreM8.lean`) no incluye la
aperiodicidad y, como documenta `DEUDA.md` §2.2 con un contraejemplo formalizado,
sin ella la identificación `σ² = γ(0) + 2∑_{k≥1} γ(k)` es **falsa**. La versión
nativa de esa hipótesis en la Mathlib instalada (Lean 4.35.0) es
`Matrix.IsPrimitive P` («no negativa y alguna potencia con todas las entradas
estrictamente positivas», exactamente irreducible + aperiódica para matrices
estocásticas finitas): `Mathlib/LinearAlgebra/Matrix/Irreducible/Defs.lean`,
`Matrix.IsPrimitive`, `Matrix.IsPrimitive.isIrreducible`,
`Matrix.isIrreducible_iff_exists_pow_pos`.

Este módulo prueba el paso analítico que convierte esa hipótesis en **decaimiento
geométrico** de las potencias sobre funciones `π`-centradas:

* `doeblin_contraction` — un paso: si `M = P^k` tiene todas las entradas `≥ m > 0`
  con `m ≤ 1`, entonces `|(M g)_x| ≤ (1 − m) · sup_y |g_y|` para `π(g) = 0`;
* `contraction_iterate` — el decaimiento por bloques:
  `|((P^k)^n g)_x| ≤ (1 − m)^n · sup_y |g_y|`.

Es la entrada que DEUDA.md §2.2 pide para `h = ∑_k P^k f` y el telescopaje de
covarianzas; **no** prueba la identificación completa ni el CLT (ver README).

Argumento (elemental, estado finito; `M := P^k`):

* `π ≥ 0`, `∑ π = 1` ⟹ `π_y ≤ 1` ⟹ `m π_y ≤ m ≤ M_{x y}`;
* `M` es estocástica (`pow_sum_one`), luego `∑_y (M_{xy} − m π_y) = 1 − m`;
* si `π(g) = 0`, entonces `(M g)_x = ∑_y (M_{xy} − m π_y) g_y`, pesos no negativos
  que suman `1 − m`: la contracción;
* `π` es invariante bajo `M` (`inv_pow`), luego `M g` sigue centrada y la
  contracción se itera.

Fidelidad declarada: `P` es una matriz estocástica por filas sobre un tipo finito
no vacío; `π` es una probabilidad invariante dada como dato (no se construye desde
`P`); `k` y `m` son testigos explícitos, no se elige `k` canónico, no se prueba que
`m` sea óptimo y no se usa la periodicidad de ningún estado. **No** se prueba aquí
la sumabilidad de `∑_k P^k f`, ni la representación `h = ∑_k P^k f`, ni
`σ² = γ(0) + 2∑ γ(k)`, ni el CLT funcional.
-/
import Mathlib

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

open Finset

namespace ApendiceDGordinDoeblin

variable {S : Type*} [Fintype S] [DecidableEq S] [Nonempty S]

/-! ## 1. Potencias estocásticas e invariancia -/

/-- Las potencias de una matriz estocástica por filas son estocásticas por filas. -/
theorem pow_sum_one (P : Matrix S S ℝ) (hP : ∀ i, ∑ j, P i j = 1) (k : ℕ) :
    ∀ i, ∑ j, (P ^ k) i j = 1 := by
  induction k with
  | zero => intro i; simp [Matrix.one_apply]
  | succ n ih =>
    intro i
    rw [pow_succ']
    simp only [Matrix.mul_apply]
    rw [Finset.sum_comm]
    calc ∑ l, ∑ j, P i l * (P ^ n) l j
        = ∑ l, P i l * ∑ j, (P ^ n) l j := by
          refine Finset.sum_congr rfl fun l _ => ?_
          rw [Finset.mul_sum]
      _ = ∑ l, P i l := by simp [ih]
      _ = 1 := hP i

/-- Una probabilidad invariante bajo `P` lo es bajo cualquier potencia de `P`. -/
theorem inv_pow (P : Matrix S S ℝ) (π : S → ℝ)
    (hinv : ∀ x, ∑ y, π y * P y x = π x) (k : ℕ) :
    ∀ x, ∑ y, π y * (P ^ k) y x = π x := by
  induction k with
  | zero => intro x; simp [Matrix.one_apply]
  | succ n ih =>
    intro x
    calc ∑ y, π y * (P ^ (n + 1)) y x
        = ∑ y, π y * ∑ l, P y l * (P ^ n) l x := by
          simp only [pow_succ', Matrix.mul_apply]
      _ = ∑ y, ∑ l, π y * (P y l * (P ^ n) l x) := by
          refine Finset.sum_congr rfl fun y _ => ?_
          rw [Finset.mul_sum]
      _ = ∑ l, ∑ y, π y * (P y l * (P ^ n) l x) := Finset.sum_comm
      _ = ∑ l, (∑ y, π y * P y l) * (P ^ n) l x := by
          refine Finset.sum_congr rfl fun l _ => ?_
          rw [Finset.sum_mul]
          exact Finset.sum_congr rfl fun y _ => by ring
      _ = ∑ l, π l * (P ^ n) l x := by simp [hinv]
      _ = π x := ih x

/-- Si todas las entradas de `M` son estrictamente positivas y sus filas suman `1`,
existe `m > 0` con `m ≤ 1` y `m ≤ M i j` para todo par de índices. -/
theorem exists_pos_le_of_pos (M : S → S → ℝ) (hM : ∀ i j, 0 < M i j)
    (hM1 : ∀ i, ∑ j, M i j = 1) :
    ∃ m : ℝ, 0 < m ∧ m ≤ 1 ∧ ∀ i j, m ≤ M i j := by
  classical
  obtain ⟨p, -, hpmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset (S × S)) (fun p : S × S => M p.1 p.2)
      Finset.univ_nonempty
  refine ⟨M p.1 p.2, hM p.1 p.2, ?_, fun i j => hpmin (i, j) (Finset.mem_univ _)⟩
  calc M p.1 p.2 ≤ ∑ j, M p.1 j :=
        Finset.single_le_sum (f := fun j => M p.1 j) (fun j _ => le_of_lt (hM p.1 j))
          (Finset.mem_univ p.2)
    _ = 1 := hM1 p.1

/-! ## 2. La contracción de Doeblin y su iteración -/

/-- **Contracción de Doeblin.** Si `M = P^k` es estocástica, sus entradas están
acotadas inferiormente por `m > 0` y `m` cabe en una fila (`m ≤ 1`), entonces `M`
contrae el supremo de las funciones `π`-centradas con constante `1 − m`. -/
theorem doeblin_contraction (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ}
    (hP1 : ∀ i, ∑ j, P i j = 1)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j)
    {g : S → ℝ} (hg : ∑ y, π y * g y = 0)
    {B : ℝ} (hB : ∀ y, |g y| ≤ B) (x : S) :
    |Matrix.mulVec (P ^ k) g x| ≤ (1 - m) * B := by
  have hM1 : ∑ j, (P ^ k) x j = 1 := pow_sum_one P hP1 k x
  have hπle : ∀ y, π y ≤ 1 := by
    intro y
    have h := Finset.single_le_sum (f := π) (fun i _ => hπ0 i) (Finset.mem_univ y)
    simpa [hπ1] using h
  set r : S → ℝ := fun y => (P ^ k) x y - m * π y with hr
  have hr0 : ∀ y, 0 ≤ r y := by
    intro y
    have h1 : m * π y ≤ m * 1 := mul_le_mul_of_nonneg_left (hπle y) (le_of_lt hm0)
    have h2 : m ≤ (P ^ k) x y := hm x y
    simp only [hr]
    linarith
  have hrs : ∑ y, r y = 1 - m := by
    simp only [hr, Finset.sum_sub_distrib]
    rw [← Finset.mul_sum, hπ1, mul_one, hM1]
  have hdec : Matrix.mulVec (P ^ k) g x = ∑ y, r y * g y := by
    have hsub : ∑ y, ((P ^ k) x y - m * π y) * g y
        = ∑ y, (P ^ k) x y * g y - m * ∑ y, π y * g y := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun y _ => by ring
    rw [Matrix.mulVec_apply_eq_sum, hr, hsub, hg, mul_zero, sub_zero]
  rw [hdec]
  calc |∑ y, r y * g y| ≤ ∑ y, |r y * g y| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ y, r y * |g y| := by
        refine Finset.sum_congr rfl fun y _ => ?_
        rw [abs_mul, abs_of_nonneg (hr0 y)]
    _ ≤ ∑ y, r y * B := by
        refine Finset.sum_le_sum fun y _ => ?_
        exact mul_le_mul_of_nonneg_left (hB y) (hr0 y)
    _ = (∑ y, r y) * B := (Finset.sum_mul ..).symm
    _ = (1 - m) * B := by rw [hrs]

/-- El vector `M g` sigue centrado si `g` lo está y `π` es invariante bajo `P`. -/
theorem center_mulVec (P : Matrix S S ℝ) (π : S → ℝ) (k : ℕ)
    (hinv : ∀ x, ∑ y, π y * P y x = π x) {g : S → ℝ} (hg : ∑ y, π y * g y = 0) :
    ∑ y, π y * Matrix.mulVec (P ^ k) g y = 0 := by
  calc ∑ y, π y * Matrix.mulVec (P ^ k) g y
      = ∑ y, ∑ x, π y * ((P ^ k) y x * g x) := by
        simp only [Matrix.mulVec_apply_eq_sum, Finset.mul_sum]
    _ = ∑ x, ∑ y, π y * ((P ^ k) y x * g x) := Finset.sum_comm
    _ = ∑ x, (∑ y, π y * (P ^ k) y x) * g x := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [Finset.sum_mul]
        exact Finset.sum_congr rfl fun y _ => by ring
    _ = ∑ x, π x * g x := by simp [inv_pow P π hinv k]
    _ = 0 := hg

/-- **Decaimiento geométrico por bloques.** Si `M = P^k` tiene todas las entradas
`≥ m > 0` con `m ≤ 1`, entonces `M^n` contrae las funciones `π`-centradas con
constante `(1 − m)^n`. -/
theorem contraction_iterate (P : Matrix S S ℝ) (π : S → ℝ) {k : ℕ}
    (hP1 : ∀ i, ∑ j, P i j = 1) (hinv : ∀ x, ∑ y, π y * P y x = π x)
    (hπ0 : ∀ y, 0 ≤ π y) (hπ1 : ∑ y, π y = 1)
    {m : ℝ} (hm0 : 0 < m) (hm1 : m ≤ 1) (hm : ∀ i j, m ≤ (P ^ k) i j) :
    ∀ n : ℕ, ∀ (g : S → ℝ), (∑ y, π y * g y = 0) →
      ∀ (B : ℝ), (∀ y, |g y| ≤ B) →
        ∀ x, |Matrix.mulVec ((P ^ k) ^ n) g x| ≤ (1 - m) ^ n * B := by
  intro n
  induction n with
  | zero =>
    intro g _ B hB x
    simpa using hB x
  | succ n ih =>
    intro g hg B hB x
    set h : S → ℝ := Matrix.mulVec (P ^ k) g with hh
    have hcenter : ∑ y, π y * h y = 0 := center_mulVec P π k hinv hg
    have hbound : ∀ y, |h y| ≤ (1 - m) * B := fun y =>
      doeblin_contraction P π hP1 hπ0 hπ1 hm0 hm1 hm hg hB y
    have hstep : ∀ y, |Matrix.mulVec ((P ^ k) ^ n) h y| ≤ (1 - m) ^ n * ((1 - m) * B) :=
      ih h hcenter ((1 - m) * B) hbound
    have hpow : Matrix.mulVec ((P ^ k) ^ (n + 1)) g x = Matrix.mulVec ((P ^ k) ^ n) h x := by
      rw [pow_succ, Matrix.mulVec_mulVec]
    calc |Matrix.mulVec ((P ^ k) ^ (n + 1)) g x|
        = |Matrix.mulVec ((P ^ k) ^ n) h x| := by rw [hpow]
      _ ≤ (1 - m) ^ n * ((1 - m) * B) := hstep x
      _ = (1 - m) ^ (n + 1) * B := by rw [pow_succ]; ring

/-! ## 3. Enunciado para matrices primitivas (la hipótesis del libro) -/

/-- Para una matriz estocástica **primitiva** (irreducible + aperiódica en estado
finito) existen una potencia `k > 0` y una constante `m ∈ (0,1]` tales que
`(P^k)^n` contrae toda función `π`-centrada con constante `(1 − m)^n`. -/
theorem exists_geometric_decay_of_primitive (P : Matrix S S ℝ)
    (hP1 : ∀ i, ∑ j, P i j = 1) (hprim : P.IsPrimitive) :
    ∃ k : ℕ, 0 < k ∧ ∃ m : ℝ, 0 < m ∧ m ≤ 1 ∧
      ∀ (π : S → ℝ), (∀ y, 0 ≤ π y) → (∑ y, π y = 1) →
        (∀ x, ∑ y, π y * P y x = π x) →
        ∀ (g : S → ℝ), (∑ y, π y * g y = 0) →
          ∀ (B : ℝ), (∀ y, |g y| ≤ B) →
            ∀ (n : ℕ) (x : S),
              |Matrix.mulVec ((P ^ k) ^ n) g x| ≤ (1 - m) ^ n * B := by
  obtain ⟨k, hk0, hk⟩ := hprim.exists_pos_pow
  obtain ⟨m, hm0, hm1, hm⟩ :=
    exists_pos_le_of_pos (fun i j => (P ^ k) i j) hk (fun i => pow_sum_one P hP1 k i)
  exact ⟨k, hk0, m, hm0, hm1, fun π hπ0 hπ1 hinv g hg B hB n x =>
    contraction_iterate P π hP1 hinv hπ0 hπ1 hm0 hm1 hm n g hg B hB x⟩

end ApendiceDGordinDoeblin
