/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m4 (dirección d1);
integración selectiva por el coordinador.

# Gordin: irreducibilidad de `Chain` y necesidad de la primitividad

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

Se conservan sólo las aportaciones de `GordinBridgeM4.lean` que no duplican la
serie de Poisson de `Book.GordinDecayM1`. Se reutiliza `Chain.toMatrix` de ese
módulo, en vez de introducir otra representación matricial.

* `isIrreducible_of_chain`: la alcanzabilidad por transiciones positivas es
  irreducibilidad matricial (con `[Nontrivial S]` para los ciclos propios).
* `chain_not_imp_primitive`: `Chain` no incorpora aperiodicidad; el intercambio
  periódico de dos estados es irreducible y no primitivo.
* `isPrimitive_unif`: la hipótesis primitiva no es vacua.

La primitividad se conserva como hipótesis explícita. Aquí no se demuestra una
caracterización general del período, la identificación bilateral de covarianzas,
el CLT de martingalas ni tightness/Skorokhod. `C.thm:appD-gordin` sigue
`pending`.
-/
import Mathlib
import Book.GordinDecayM1

open ApendiceDGordinM8 ApendiceDGordinDoeblin
open Finset
open scoped Matrix BigOperators

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

namespace GordinPrimitividad

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Un paso de probabilidad positiva da una entrada positiva en `A^1`, y
`ReflTransGen` con extremos distintos da una potencia de exponente positivo con
entrada positiva. -/
lemma exists_pow_pos_of_ne (A : Matrix S S ℝ) (hA : ∀ i j, 0 ≤ A i j) {x y : S}
    (h : Relation.ReflTransGen (fun a b : S => 0 < A a b) x y) (hne : x ≠ y) :
    ∃ k : ℕ, 0 < k ∧ 0 < (A ^ k) x y := by
  induction h with
  | refl => exact absurd rfl hne
  | tail hab hbc ih =>
    rename_i bb cc
    rcases eq_or_ne x bb with hxb | hxb
    · subst hxb
      exact ⟨1, one_pos, by simpa using hbc⟩
    · obtain ⟨k, hk0, hk⟩ := ih hxb
      have hnonneg : ∀ l ∈ (Finset.univ : Finset S), 0 ≤ (A ^ k) x l * A l cc := fun l _ =>
        mul_nonneg (Matrix.pow_apply_nonneg hA k x l) (hA l cc)
      have hle : (A ^ k) x bb * A bb cc ≤ ∑ l, (A ^ k) x l * A l cc :=
        Finset.single_le_sum (f := fun l => (A ^ k) x l * A l cc) hnonneg (Finset.mem_univ bb)
      refine ⟨k + 1, by omega, ?_⟩
      rw [pow_succ, Matrix.mul_apply]
      exact lt_of_lt_of_le (mul_pos hk hbc) hle

/-- Composición de caminos: los exponentes se suman. -/
lemma pow_add_pos (A : Matrix S S ℝ) (hA : ∀ i j, 0 ≤ A i j) {x y z : S} {m n : ℕ}
    (hm : 0 < (A ^ m) x y) (hn : 0 < (A ^ n) y z) : 0 < (A ^ (m + n)) x z := by
  have hnonneg : ∀ l ∈ (Finset.univ : Finset S), 0 ≤ (A ^ m) x l * (A ^ n) l z := fun l _ =>
    mul_nonneg (Matrix.pow_apply_nonneg hA m x l) (Matrix.pow_apply_nonneg hA n l z)
  have hle : (A ^ m) x y * (A ^ n) y z ≤ ∑ l, (A ^ m) x l * (A ^ n) l z :=
    Finset.single_le_sum (f := fun l => (A ^ m) x l * (A ^ n) l z) hnonneg (Finset.mem_univ y)
  rw [pow_add, Matrix.mul_apply]
  exact lt_of_lt_of_le (mul_pos hm hn) hle

/-- **Fidelidad de la irreducibilidad.** La `irreduc` de `Chain` (alcanzabilidad
por caminos de entradas `> 0`) implica la irreducibilidad de Mathlib para la
matriz de transición. No se necesita periodicidad: la única hipótesis extra es
que el espacio de estados tenga al menos dos puntos (para cerrar los bucles
`x → x` con un camino de longitud positiva). -/
theorem isIrreducible_of_chain (D : Chain S) [Nontrivial S] :
    Matrix.IsIrreducible (D.P : Matrix S S ℝ) := by
  refine (Matrix.isIrreducible_iff_exists_pow_pos D.P_nonneg).mpr ?_
  intro i j
  rcases eq_or_ne i j with rfl | hij
  · obtain ⟨k, hk⟩ : ∃ k : S, k ≠ i := exists_ne i
    obtain ⟨m, hm0, hm⟩ := exists_pow_pos_of_ne D.P D.P_nonneg (D.irreduc i k) (Ne.symm hk)
    obtain ⟨n, hn0, hn⟩ := exists_pow_pos_of_ne D.P D.P_nonneg (D.irreduc k i) hk
    exact ⟨m + n, by omega, pow_add_pos D.P D.P_nonneg hm hn⟩
  · obtain ⟨k, hk0, hk⟩ := exists_pow_pos_of_ne D.P D.P_nonneg (D.irreduc i j) hij
    exact ⟨k, hk0, hk⟩

/-- Suma sobre `Bool`. -/
lemma sum_bool_eq {R : Type*} [AddCommMonoid R] (g : Bool → R) :
    ∑ y, g y = g true + g false := by
  rw [Fintype.univ_bool, Finset.sum_insert (by simp), Finset.sum_singleton]

/-- La matriz del camino determinista de dos estados: `P x y = 1` si `y ≠ x`. Es
la matriz de transición del contraejemplo de `DEUDA.md` §2.2 (período 2). -/
def flipP : Matrix Bool Bool ℝ := fun x y => if x = y then 0 else 1

lemma flipP_mul_self : flipP * flipP = 1 := by
  ext x y
  rw [Matrix.mul_apply, sum_bool_eq, Matrix.one_apply]
  cases x <;> cases y <;> norm_num [flipP]

lemma flipP_pow_even : ∀ q : ℕ, flipP ^ (2 * q) = 1
  | 0 => by simp
  | q + 1 => by
    have h : 2 * (q + 1) = 2 * q + 2 := by omega
    rw [h, pow_add, flipP_pow_even q, pow_two, flipP_mul_self, one_mul]

lemma flipP_pow_odd (q : ℕ) : flipP ^ (2 * q + 1) = flipP := by
  rw [pow_succ, flipP_pow_even q, one_mul]

/-- **La matriz de período 2 no es primitiva.** -/
theorem not_isPrimitive_flipP : ¬ Matrix.IsPrimitive flipP := by
  rintro ⟨-, k, hk0, hk⟩
  rcases Nat.even_or_odd k with ⟨q, hq⟩ | ⟨q, hq⟩
  · have hzero : (flipP ^ k) true false = 0 := by
      rw [hq, show q + q = 2 * q by omega, flipP_pow_even q, Matrix.one_apply]
      simp
    have h := hk true false
    rw [hzero] at h
    exact lt_irrefl 0 h
  · have hzero : (flipP ^ k) true true = 0 := by
      rw [hq, flipP_pow_odd q]
      simp [flipP]
    have h := hk true true
    rw [hzero] at h
    exact lt_irrefl 0 h

/-- **La `Chain` de dos estados, período 2.** Satisface todos los campos de
`Chain` (estocástica por filas, `π = (1/2,1/2)` invariante, irreducible por
alcanzabilidad) y sin embargo su matriz no es primitiva. -/
noncomputable def flipChain : Chain Bool where
  P := flipP
  π := fun _ => 1 / 2
  P_nonneg := by intro x y; rw [flipP]; split <;> norm_num
  P_sum := by intro x; rw [sum_bool_eq]; cases x <;> norm_num [flipP]
  π_nonneg := by intro x; norm_num
  π_sum := by rw [sum_bool_eq]; norm_num
  π_inv := by intro x; rw [sum_bool_eq]; cases x <;> norm_num [flipP]
  irreduc := by
    intro x y
    rcases eq_or_ne x y with rfl | hxy
    · exact Relation.ReflTransGen.refl
    · exact Relation.ReflTransGen.single (by rw [flipP]; simp [hxy])

@[simp] lemma flipChain_P : flipChain.P = flipP := rfl
@[simp] lemma flipChain_pi : flipChain.π = fun _ => (1 / 2 : ℝ) := rfl

/-- La matriz de la cadena de período 2 **sí** es irreducible en el sentido de
Mathlib (lo que falla es sólo la aperiodicidad). -/
theorem isIrreducible_flipChain : Matrix.IsIrreducible (flipChain.toMatrix) :=
  isIrreducible_of_chain flipChain

/-- **`Chain` no implica primitividad.** Existe una `Chain` cuya matriz no es
primitiva: el contenido adicional de `Matrix.IsPrimitive` sobre `Chain` es
exactamente la aperiodicidad, no la irreducibilidad. -/
theorem chain_not_imp_primitive : ∃ D : Chain Bool, ¬ Matrix.IsPrimitive D.toMatrix :=
  ⟨flipChain, by simpa [Chain.toMatrix, flipChain] using not_isPrimitive_flipP⟩

/-- La cadena uniforme de dos estados: `P x y = 1/2`, `π = (1/2,1/2)`. -/
noncomputable def unifChain : Chain Bool where
  P := fun _ _ => 1 / 2
  π := fun _ => 1 / 2
  P_nonneg := by intro x y; norm_num
  P_sum := by intro x; rw [sum_bool_eq]; norm_num
  π_nonneg := by intro x; norm_num
  π_sum := by rw [sum_bool_eq]; norm_num
  π_inv := by intro x; rw [sum_bool_eq]; norm_num
  irreduc := by
    intro x y
    exact Relation.ReflTransGen.single (by norm_num)

@[simp] lemma unifChain_P : unifChain.P = fun _ _ => (1 / 2 : ℝ) := rfl
@[simp] lemma unifChain_pi : unifChain.π = fun _ => (1 / 2 : ℝ) := rfl

/-- La cadena uniforme **es** primitiva: la hipótesis de §3 es consistente con
`Chain`. -/
theorem isPrimitive_unif : Matrix.IsPrimitive (unifChain.toMatrix) := by
  refine ⟨fun i j => by norm_num [Chain.toMatrix, unifChain], 1, one_pos, fun i j => ?_⟩
  simp only [pow_one]
  norm_num [Chain.toMatrix, unifChain]


end GordinPrimitividad
