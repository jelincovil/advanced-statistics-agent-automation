/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m2 (dirección d3).

# Instancia verificada: la cadena de 2 estados con `γ(k) = 2^{-k}` y `σ² = 3`

Este fichero comprueba que el teorema abstracto `tendsto_pairCov_div_of_decay`
(`GordinCovarianzaM2.lean`) **no es vacuo**: exhibe una `Chain` concreta, calcula
su covariograma de forma exacta y aplica el teorema, obteniendo el valor exacto
del límite.

Cadena: `S = Bool`, `P = [[3/4, 1/4], [1/4, 3/4]]` (reversible, aperiódica:
todas las entradas positivas), `π = (1/2, 1/2)` y `f = (1, -1)` (centrada:
`π(f) = 0`).

Como `P f = (1/2) f`, se tiene `P^k f = 2^{-k} f` y por tanto

  `γ(k) = ⟨f, P^k f⟩_π = 2^{-k}`,  `γ(0) = 1`,  `σ² = γ(0) + 2∑_{k≥1}γ(k) = 1 + 2 = 3`.

Lo que se **demuestra** aquí (no se postula): que `Pex`/`π`/`f` cumplen los campos
de `Chain` (estocasticidad, invariancia, irreducibilidad por alcanzabilidad), la
fórmula `P^k f = 2^{-k} f`, `γ(k) = 2^{-k}` y el límite `→ 3`. Nada de esto usa
`sorry` ni axiomas propios (auditado en `axiomas.log`).

Fidelidad declarada: es una cadena finita de 2 estados; no se afirma que sea el
ejemplo `ex:ch5-cadena` del libro (allí `γ_k = 24·(1/2)^k`), sólo que es una
instancia real donde las hipótesis del teorema se descargan y el valor del
límite se calcula exactamente.
-/
import Book.GordinCovarianzaM2

open Finset BigOperators Filter
open scoped Topology

set_option maxHeartbeats 1000000
set_option linter.unusedSectionVars false

namespace GordinCovarianzaM2Ejemplo

open ApendiceDGordinM8

/-- Transiciones del ejemplo: `3/4` en la diagonal, `1/4` fuera. -/
noncomputable def Pex (x y : Bool) : ℝ := if x = y then 3 / 4 else 1 / 4

/-- Ley estacionaria del ejemplo: uniforme. -/
noncomputable def piEx (_ : Bool) : ℝ := 1 / 2

/-- La función observable: `f = (1, -1)`, centrada bajo `π`. -/
noncomputable def fex (x : Bool) : ℝ := if x then -1 else 1

lemma Pex_nonneg (x y : Bool) : 0 ≤ Pex x y := by
  unfold Pex
  split_ifs <;> norm_num

lemma Pex_sum (x : Bool) : ∑ y, Pex x y = 1 := by
  unfold Pex
  cases x <;> simp <;> norm_num

lemma piEx_inv (x : Bool) : ∑ y, piEx y * Pex y x = piEx x := by
  unfold piEx Pex
  cases x <;> simp <;> norm_num

/-- La cadena del ejemplo. -/
noncomputable def Dex : Chain Bool where
  P := Pex
  π := piEx
  P_nonneg := Pex_nonneg
  P_sum := Pex_sum
  π_nonneg := by intro x; unfold piEx; norm_num
  π_sum := by unfold piEx; simp
  π_inv := piEx_inv
  irreduc := by
    intro x y
    by_cases h : x = y
    · subst h
      exact Relation.ReflTransGen.refl
    · refine Relation.ReflTransGen.single ?_
      simp only [Pex, h, ite_false]
      norm_num

/-- `f` está centrada: `π(f) = 0`. -/
lemma avg_fex : Dex.avg fex = 0 := by
  change (∑ x : Bool, piEx x * fex x) = 0
  simp only [piEx, fex]
  norm_num

/-- **`P f = (1/2) f`** para el observable del ejemplo. -/
lemma applyP_fex : Dex.applyP fex = fun x => (1 / 2) * fex x := by
  funext x
  rw [ApendiceDGordinM8.Chain.applyP_apply]
  change (∑ y : Bool, Pex x y * fex y) = (1 / 2) * fex x
  cases x <;> simp [Pex, fex] <;> norm_num

/-- **`P^k f = 2^{-k} f`**. -/
lemma applyP_iterate_fex (k : ℕ) : (Dex.applyP^[k]) fex = fun x => (1 / 2) ^ k * fex x := by
  induction k with
  | zero => funext x; simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih, ApendiceDGordinM8.Chain.applyP_const_mul,
      applyP_fex]
    funext x
    rw [pow_succ]
    ring

/-- **El covariograma es `γ(k) = 2^{-k}`.** -/
theorem covLag_fex (k : ℕ) : Dex.covLag fex k = (1 / 2 : ℝ) ^ k := by
  rw [ApendiceDGordinM8.Chain.covLag_eq_avg, applyP_iterate_fex]
  change (∑ x : Bool, piEx x * (fex x * ((1 / 2) ^ k * fex x))) = (1 / 2) ^ k
  simp only [piEx, fex]
  simp
  ring

/-- La covarianza del par es `2^{-|i-j|}`. -/
theorem pairCov_fex (i j : ℕ) : Dex.pairCov fex i j = (1 / 2 : ℝ) ^ (Nat.dist i j) := by
  rw [ApendiceDGordinM8.Chain.pairCov_eq_covLag, covLag_fex]

/-- **El decaimiento geométrico puntual se cumple** con `C = 1`, `ρ = 1/2`. -/
theorem decay_fex (k : ℕ) (x : Bool) :
    |Matrix.mulVec (Dex.toMatrix ^ k) fex x| ≤ 1 * (1 / 2 : ℝ) ^ k := by
  rw [← ApendiceDGordinM8.Chain.iterate_applyP_eq_mulVec, applyP_iterate_fex]
  have hf : |fex x| = 1 := by
    unfold fex
    cases x <;> simp
  rw [abs_mul, hf, mul_one, abs_of_nonneg (by positivity : (0 : ℝ) ≤ (1 / 2) ^ k)]
  norm_num

/-- **La varianza de largo plazo vale exactamente `3`.** -/
theorem lrVariance_fex : BookCh5CltAgentesM5.lrVariance (Dex.covLag fex) = 3 := by
  rw [ApendiceDGordinM8.Chain.lrVariance_covLag]
  have hk : ∀ k : ℕ, Dex.covLag fex k = (1 / 2 : ℝ) ^ k := covLag_fex
  simp only [hk]
  have hts : (∑' k : ℕ, (1 / 2 : ℝ) ^ (k + 1)) = 1 := by
    have hgeo : (∑' k : ℕ, (1 / 2 : ℝ) ^ k) = 2 := by
      have h := tsum_geometric_of_norm_lt_one (ξ := (1 / 2 : ℝ)) (by norm_num)
      rw [h]
      norm_num
    calc (∑' k : ℕ, (1 / 2 : ℝ) ^ (k + 1))
        = ∑' k : ℕ, ((1 / 2 : ℝ) ^ k * (1 / 2)) := by
          refine tsum_congr fun k => ?_
          rw [pow_succ]
      _ = (∑' k : ℕ, (1 / 2 : ℝ) ^ k) * (1 / 2) := tsum_mul_right
      _ = 2 * (1 / 2) := by rw [hgeo]
      _ = 1 := by norm_num
  rw [hts]
  norm_num

/-- **El teorema abstracto se aplica y da `3`.** Es decir, en esta cadena
`(1/n)·∑_{i,j<n} Cov(f(S_i),f(S_j)) → 3 = γ(0) + 2∑_{k≥1}γ(k)`. -/
theorem tendsto_pairCov_fex :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ range n, ∑ j ∈ range n, Dex.pairCov fex i j)
      atTop (𝓝 3) := by
  have h := ApendiceDGordinM8.Chain.tendsto_pairCov_div_of_decay Dex fex
    (C := 1) (ρ := 1 / 2) (by norm_num) (by norm_num) (by norm_num) decay_fex
  simpa [lrVariance_fex] using h

/-- La identidad de conteo, en el ejemplo: `∑_{i,j<n} 2^{-|i−j|} = 3n - 4 + 4·2^{-n}`. -/
theorem doubleSum_fex (n : ℕ) :
    (∑ i ∈ range n, ∑ j ∈ range n, Dex.pairCov fex i j)
      = 3 * (n : ℝ) - 4 + 4 * (1 / 2 : ℝ) ^ n := by
  have hpt : ∀ i j : ℕ, Dex.pairCov fex i j = (1 / 2 : ℝ) ^ (Nat.dist i j) := pairCov_fex
  simp only [hpt]
  rw [Ch11M10.sum_dist_range (fun k : ℕ => (1 / 2 : ℝ) ^ k) n]
  -- ∑_{k<n}(n−1−k)·2^{-(k+1)} = n − 2 + 2·2^{-n}
  have hw : (∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1))
      = (n : ℝ) - 2 + 2 * (1 / 2 : ℝ) ^ n := by
    have hkey : ∀ k ∈ range n,
        ((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1)
          = (1 / 2) * (((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k) := by
      intro k _
      rw [pow_succ]
      ring
    rw [Finset.sum_congr rfl hkey, ← Finset.mul_sum, BookCh5CltAgentesCov.geom_pesos_half n]
    ring
  rw [hw]
  simp only [pow_zero]
  ring

end GordinCovarianzaM2Ejemplo
