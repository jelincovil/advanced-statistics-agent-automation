/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m3 (dirección d5).

# La identificación `σ² = γ(0) + 2∑_{k≥1}γ(k)` en la cadena de dos estados

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

Instancia paramétrica real del resultado general de `GordinEigenM3`. Para
`p ∈ (0,1)` se toma la cadena de dos estados

  `P = [[p, 1-p], [1-p, p]]`,  `π = (1/2, 1/2)`,  `f = (1, -1)`.

`P` es **estocástica por filas** con todas las entradas `> 0` (luego
irreducible en el sentido de `Chain.irreduc`, y de hecho primitiva: `P^1 > 0`),
`π` es invariante, `f` está centrada, y `f` es **autofunción** de `P` con
autovalor `λ = 2p-1`. Por tanto se aplica `sigmaSq_eq_gamma_tsum` y se obtiene,
con valores cerrados,

  `γ(t) = ⟨f, P^t f⟩_π = (2p-1)^t`,  `σ² = π(condVar h) = p/(1-p)`,

y la identificación `σ² = γ(0) + 2∑_{k≥1}γ(k)` (la serie es geométrica:
`1 + 2(2p-1)/(1-(2p-1)) = (1+λ)/(1-λ) = p/(1-p)`).

El caso límite `p = 0` de la misma familia es la cadena periódica (el
intercambio), donde `λ = -1` y la hipótesis `|λ| < 1` falla: es exactamente el
contraejemplo ya formalizado en `.ultramath/smwa5izeq/m1/GordinPeriodico.lean`
(`σ² = 0` y `γ(k) = (-1)^k` no sumable). Es decir, dentro de esta familia la
identificación vale exactamente cuando la cadena es aperiódica.
-/
import Book.GordinEigenM3

open ApendiceDGordinM8
open scoped BigOperators Topology

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option linter.unusedTactic false

namespace GordinEigenTwoState

/-! ## 1. La cadena de dos estados con parámetro `p` -/

/-- Transición `P x y = p` si `y = x`, `1-p` si `y ≠ x`. -/
noncomputable def Ptwo (p : ℝ) : Fin 2 → Fin 2 → ℝ := fun x y => if x = y then p else 1 - p

/-- Ley estacionaria uniforme `π = (1/2, 1/2)`. -/
noncomputable def piTwo : Fin 2 → ℝ := fun _ => 1 / 2

/-- Observable centrado `f = (1, -1)`. -/
noncomputable def fTwo : Fin 2 → ℝ := fun x => if x = 0 then 1 else -1

/-- **La cadena de dos estados** para `0 < p < 1`. -/
noncomputable def chainTwo (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) : Chain (Fin 2) where
  P := Ptwo p
  π := piTwo
  P_nonneg := by
    intro x y
    unfold Ptwo
    split_ifs <;> linarith
  P_sum := by
    intro x
    fin_cases x <;> simp [Ptwo, Fin.sum_univ_two]
  π_nonneg := by intro x; norm_num [piTwo]
  π_sum := by simp [piTwo]
  π_inv := by
    intro x
    fin_cases x <;> simp [Ptwo, piTwo, Fin.sum_univ_two] <;> ring
  irreduc := by
    intro x y
    by_cases h : x = y
    · subst h; exact Relation.ReflTransGen.refl
    · exact Relation.ReflTransGen.single (by
        unfold Ptwo; simp only [h, ite_false]; linarith)

/-- Todas las entradas son estrictamente positivas: la cadena es irreducible y
aperiódica (primitiva, `P^1 > 0`). -/
lemma Ptwo_pos (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) (x y : Fin 2) :
    0 < (chainTwo p hp0 hp1).P x y := by
  show 0 < Ptwo p x y
  unfold Ptwo
  split_ifs <;> linarith

/-! ## 2. Datos: centrado y autofunción -/

lemma avg_fTwo (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).avg fTwo = 0 := by
  simp only [Chain.avg_apply, chainTwo, piTwo, fTwo, Fin.sum_univ_two]
  norm_num

/-- **`f` es autofunción de `P` con autovalor `λ = 2p-1`.** -/
lemma applyP_fTwo (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) (x : Fin 2) :
    (chainTwo p hp0 hp1).applyP fTwo x = (2 * p - 1) * fTwo x := by
  fin_cases x <;>
    simp [Chain.applyP_apply, chainTwo, Ptwo, fTwo, Fin.sum_univ_two] <;> ring

lemma abs_lam (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) : |2 * p - 1| < 1 := by
  rw [abs_lt]; constructor <;> linarith

lemma lam_ne_one (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) : 2 * p - 1 ≠ 1 := by
  intro h; linarith

lemma avg_fTwo_sq (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).avg (fun x => (fTwo x) ^ 2) = 1 := by
  simp only [Chain.avg_apply, chainTwo, piTwo, fTwo, Fin.sum_univ_two]
  norm_num

/-! ## 3. Covariograma y varianza, con valores cerrados -/

/-- El covariograma: `γ(t) = λ^t = (2p-1)^t`. -/
theorem gamma_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) (t : ℕ) :
    GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo t = (2 * p - 1) ^ t := by
  rw [GordinEigenM3.Chain.gamma_eigen (D := chainTwo p hp0 hp1) (applyP_fTwo p hp0 hp1) t,
    GordinEigenM3.Chain.gamma_zero]
  rw [avg_fTwo_sq p hp0 hp1, mul_one]

/-- La solución de Poisson centrada es `h = f/(1-λ) = f/(2-2p)`. -/
theorem poisson_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).avg (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) = 0 ∧
      ∀ x, fTwo x = (1 - (2 * p - 1))⁻¹ * fTwo x
        - (chainTwo p hp0 hp1).applyP (fun y => (1 - (2 * p - 1))⁻¹ * fTwo y) x :=
  ⟨GordinEigenM3.Chain.avg_smul_of_avg_eq_zero (D := chainTwo p hp0 hp1) (avg_fTwo p hp0 hp1) _,
    fun x => GordinEigenM3.Chain.poisson_eigen (D := chainTwo p hp0 hp1)
      (applyP_fTwo p hp0 hp1) (lam_ne_one p hp0 hp1) x⟩

/-- **Toda solución de Poisson centrada de `f` es la explícita** `f/(2-2p)`:
la unicidad de `Chain.poisson_solution` en este modelo. -/
theorem poisson_two_unique (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) {h : Fin 2 → ℝ}
    (hc : (chainTwo p hp0 hp1).avg h = 0)
    (hp : ∀ x, fTwo x = h x - (chainTwo p hp0 hp1).applyP h x) :
    h = fun x => (1 - (2 * p - 1))⁻¹ * fTwo x :=
  (GordinEigenM3.Chain.poisson_unique (D := chainTwo p hp0 hp1) (f := fTwo)
    (h1 := fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) (h2 := h)
    (GordinEigenM3.Chain.avg_smul_of_avg_eq_zero (D := chainTwo p hp0 hp1)
      (avg_fTwo p hp0 hp1) _)
    (fun x => GordinEigenM3.Chain.poisson_eigen (D := chainTwo p hp0 hp1)
      (applyP_fTwo p hp0 hp1) (lam_ne_one p hp0 hp1) x)
    hc hp).symm

/-- **La varianza del incremento de martingala**: `σ² = p/(1-p)`. -/
theorem sigmaSq_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).sigmaSq (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) = p / (1 - p) := by
  rw [GordinEigenM3.Chain.sigmaSq_poisson_eigen (D := chainTwo p hp0 hp1)
    (applyP_fTwo p hp0 hp1) (lam_ne_one p hp0 hp1), avg_fTwo_sq p hp0 hp1, mul_one]
  have h1 : (1 + (2 * p - 1)) = 2 * p := by ring
  have h2 : (1 - (2 * p - 1)) = 2 - 2 * p := by ring
  rw [h1, h2, div_eq_div_iff (by intro h; linarith) (by intro h; linarith)]
  ring

/-- La cola geométrica: `∑_{k≥1} γ(k) = λ/(1-λ) = (2p-1)/(2-2p)`. -/
theorem tsum_tail_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    ∑' k : ℕ, (2 * p - 1) ^ (k + 1) = (2 * p - 1) / (2 - 2 * p) := by
  have hnorm : |2 * p - 1| < 1 := abs_lam p hp0 hp1
  have h1 : ∑' k : ℕ, (2 * p - 1) ^ (k + 1) = (2 * p - 1) * ∑' k : ℕ, (2 * p - 1) ^ k := by
    rw [← tsum_mul_left]
    exact tsum_congr fun k => by ring
  rw [h1, tsum_geometric_of_norm_lt_one hnorm, div_eq_mul_inv]
  congr 1
  ring

/-- La serie de covarianzas es absolutamente sumable (`∑|γ| < ∞`). -/
theorem summable_abs_gamma_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    Summable (fun t : ℕ => |GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo t|) :=
  GordinEigenM3.Chain.summable_abs_gamma (D := chainTwo p hp0 hp1)
    (applyP_fTwo p hp0 hp1) (abs_lam p hp0 hp1)

/-- En esta familia `σ² > 0`: el modelo no es degenerado (lo que el CLT
necesita para un límite no trivial). -/
theorem sigmaSq_two_pos (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 < (chainTwo p hp0 hp1).sigmaSq (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) := by
  rw [sigmaSq_two p hp0 hp1]
  positivity

/-- **La hipótesis `|λ| < 1` es exactamente la aperiodicidad en esta familia**:
en `p = 0` (el intercambio, período 2) se tiene `λ = -1` y la hipótesis falla. -/
theorem lam_zero_fails : ¬ |2 * (0 : ℝ) - 1| < 1 := by norm_num

/-! ## 4. La identificación de Gordin en esta familia -/

/-- **Identificación `σ² = γ(0) + 2∑_{k≥1}γ(k)` en la cadena de dos estados**
(instancia del teorema general, con los dos miembros calculados). -/
theorem sigmaSq_eq_gamma_tsum_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).sigmaSq (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x)
      = GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo 0
        + 2 * ∑' k : ℕ, GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo (k + 1) :=
  GordinEigenM3.Chain.sigmaSq_eq_gamma_tsum (D := chainTwo p hp0 hp1)
    (applyP_fTwo p hp0 hp1) (lam_ne_one p hp0 hp1) (abs_lam p hp0 hp1)

/-- **La misma identidad con valores cerrados**: `p/(1-p) = 1 + 2∑_{k≥1}(2p-1)^k`. -/
theorem sigmaSq_closed_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    p / (1 - p) = 1 + 2 * ∑' k : ℕ, (2 * p - 1) ^ (k + 1) := by
  rw [tsum_tail_two p hp0 hp1]
  field_simp
  ring

/-! ## 5. La familia de dos estados es una cadena de rango uno -/

/-- La media estacionaria en `Fin 2` es el promedio. -/
lemma avg_two (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) (g : Fin 2 → ℝ) :
    (chainTwo p hp0 hp1).avg g = (g 0 + g 1) / 2 := by
  simp only [Chain.avg_apply, chainTwo, piTwo, Fin.sum_univ_two]
  ring

/-- **`P = (1-α)·I + α·1π` con `α = 2-2p`**: la familia de dos estados está en la
clase de rango uno, luego `sigmaSq_eq_gamma_tsum_rankOne` se le aplica a
*cualquier* observable centrado. -/
lemma chainTwo_rankOne (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) (g : Fin 2 → ℝ) (x : Fin 2) :
    (chainTwo p hp0 hp1).applyP g x
      = (1 - (2 - 2 * p)) * g x + (2 - 2 * p) * (chainTwo p hp0 hp1).avg g := by
  rw [avg_two p hp0 hp1]
  fin_cases x <;>
    simp [Chain.applyP_apply, chainTwo, Ptwo, Fin.sum_univ_two] <;> ring

/-- La identificación vía la clase de rango uno (instancia independiente). -/
theorem sigmaSq_eq_gamma_tsum_two_rankOne (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).sigmaSq (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x)
      = GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo 0
        + 2 * ∑' k : ℕ, GordinEigenM3.Chain.gamma (chainTwo p hp0 hp1) fTwo (k + 1) := by
  have hfun : (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) = fun x => (2 - 2 * p)⁻¹ * fTwo x := by
    funext x
    rw [show (1 : ℝ) - (2 * p - 1) = 2 - 2 * p by ring]
  rw [hfun]
  exact GordinEigenM3.Chain.sigmaSq_eq_gamma_tsum_rankOne (D := chainTwo p hp0 hp1)
    (α := 2 - 2 * p) (by linarith) (by linarith) (chainTwo_rankOne p hp0 hp1)
    (avg_fTwo p hp0 hp1)

/-- Y con el valor cerrado, por la vía de rango uno: `σ² = p/(1-p)` otra vez
(control cruzado interno con `sigmaSq_two`). -/
theorem sigmaSq_two_via_rankOne (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    (chainTwo p hp0 hp1).sigmaSq (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) = p / (1 - p) := by
  have hfun : (fun x => (1 - (2 * p - 1))⁻¹ * fTwo x) = fun x => (2 - 2 * p)⁻¹ * fTwo x := by
    funext x
    rw [show (1 : ℝ) - (2 * p - 1) = 2 - 2 * p by ring]
  rw [hfun, GordinEigenM3.Chain.sigmaSq_rankOne_eq (D := chainTwo p hp0 hp1)
    (α := 2 - 2 * p) (by linarith) (chainTwo_rankOne p hp0 hp1) (avg_fTwo p hp0 hp1)]
  rw [avg_fTwo_sq p hp0 hp1, mul_one]
  have h1 : (2 - (2 - 2 * p)) = 2 * p := by ring
  rw [h1, div_eq_div_iff (by intro h; linarith) (by intro h; linarith)]
  ring

end GordinEigenTwoState
