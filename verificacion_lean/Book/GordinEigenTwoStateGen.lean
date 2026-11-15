/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m3 (dirección d5).

# La identificación en TODA cadena irreducible aperiódica de dos estados

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

En una cadena de dos estados el espacio de funciones centradas tiene dimensión
uno, así que **todo** observable centrado es autofunción de `P` con el mismo
autovalor `λ = 1-a-b`. Esto permite aplicar `sigmaSq_eq_gamma_tsum` sin
hipótesis espectral por observable y obtener la identificación,
incondicionalmente, para cualquier cadena

  `P = [[1-a, a], [b, 1-b]]`,  `0 < a < 1`,  `0 < b < 1`

(irreducible porque `a, b > 0`; aperiódica porque `P² > 0`; `π = (b, a)/(a+b)`).

Resultado: para **cada** `f` con `π(f) = 0`,

  `γ(t) = (1-a-b)^t · π(f²)`,  `σ² = π(condVar h) = ((2-a-b)/(a+b))·π(f²)`,
  `h = f/(a+b)`,  y  `σ² = γ(0) + 2∑_{k≥1}γ(k)`.

La familia simétrica de `GordinEigenTwoState.lean` es el caso `a = b = 1-p`.
-/
import Book.GordinEigenM3

open ApendiceDGordinM8
open scoped BigOperators Topology

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

namespace GordinEigenTwoStateGen

/-- Transición general de dos estados: `P 0 0 = 1-a`, `P 0 1 = a`, `P 1 0 = b`,
`P 1 1 = 1-b`. -/
noncomputable def Pgen (a b : ℝ) : Fin 2 → Fin 2 → ℝ := fun x y =>
  if x = 0 then (if y = 0 then 1 - a else a) else (if y = 0 then b else 1 - b)

/-- Ley estacionaria `π = (b, a)/(a+b)`. -/
noncomputable def piGen (a b : ℝ) : Fin 2 → ℝ :=
  fun x => if x = 0 then b / (a + b) else a / (a + b)

/-- Todo elemento de `Fin 2` es `0` o `1`. Permite sustituir el índice por un
literal, que es la forma en que se evalúan `Pgen` y `piGen`. -/
lemma fin2_eq (x : Fin 2) : x = 0 ∨ x = 1 := by
  fin_cases x
  · exact Or.inl rfl
  · exact Or.inr rfl

/-! ## 1. La cadena general de dos estados -/

/-- **La cadena general de dos estados**, para `0 < a < 1`, `0 < b < 1`. -/
noncomputable def chainGen (a b : ℝ) (ha0 : 0 < a) (ha1 : a < 1)
    (hb0 : 0 < b) (hb1 : b < 1) : Chain (Fin 2) where
  P := Pgen a b
  π := piGen a b
  P_nonneg := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    intro x y
    rcases fin2_eq x with hx | hx <;> subst hx <;>
      rcases fin2_eq y with hy | hy <;> subst hy <;>
      simp only [Pgen, ite_true, h1, ite_false] <;> linarith
  P_sum := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    intro x
    rcases fin2_eq x with hx | hx <;> subst hx
    · simp only [Fin.sum_univ_two, Pgen, ite_true, h1, ite_false]
      ring
    · simp only [Fin.sum_univ_two, Pgen, ite_true, h1, ite_false]
      ring
  π_nonneg := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    intro x
    rcases fin2_eq x with hx | hx <;> subst hx
    · simp only [piGen, ite_true]; positivity
    · simp only [piGen, ite_true, h1, ite_false]; positivity
  π_sum := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    have hab : a + b ≠ 0 := by positivity
    simp only [Fin.sum_univ_two, piGen, ite_true, h1, ite_false]
    field_simp
    ring
  π_inv := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    have hab : a + b ≠ 0 := by positivity
    intro x
    rcases fin2_eq x with hx | hx <;> subst hx
    · simp only [Fin.sum_univ_two, piGen, Pgen, ite_true, h1, ite_false]
      field_simp
      ring
    · simp only [Fin.sum_univ_two, piGen, Pgen, ite_true, h1, ite_false]
      field_simp
      ring
  irreduc := by
    have h1 : ¬ ((1 : Fin 2) = 0) := by decide
    intro x y
    by_cases h : x = y
    · subst h; exact Relation.ReflTransGen.refl
    · refine Relation.ReflTransGen.single ?_
      rcases fin2_eq x with hx | hx <;> subst hx <;>
        rcases fin2_eq y with hy | hy <;> subst hy <;>
        simp only [Pgen, ite_true, h1, ite_false] <;>
        first
          | linarith
          | exact absurd rfl h

/-! ## 2. Media y transición explícitas -/

variable {a b : ℝ}

lemma avg_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    (g : Fin 2 → ℝ) :
    (chainGen a b ha0 ha1 hb0 hb1).avg g = (b * g 0 + a * g 1) / (a + b) := by
  have h1 : ¬ ((1 : Fin 2) = 0) := by decide
  have hab : a + b ≠ 0 := by positivity
  simp only [Chain.avg_apply, chainGen, Fin.sum_univ_two, piGen, ite_true, h1, ite_false]
  field_simp

lemma applyP_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    (g : Fin 2 → ℝ) (x : Fin 2) :
    (chainGen a b ha0 ha1 hb0 hb1).applyP g x
      = if x = 0 then (1 - a) * g 0 + a * g 1 else b * g 0 + (1 - b) * g 1 := by
  have h1 : ¬ ((1 : Fin 2) = 0) := by decide
  have hx := fin2_eq x
  rw [Chain.applyP_apply, Fin.sum_univ_two]
  simp only [chainGen]
  rcases hx with h | h <;> subst h
  · simp only [Pgen, ite_true, h1, ite_false]
  · simp only [Pgen, ite_true, h1, ite_false]

/-! ## 3. Todo centrado es autofunción, y la identificación -/

/-- **Todo observable centrado es autofunción** con `λ = 1-a-b`: en `Fin 2` el
espacio centrado es de dimensión uno. -/
theorem eigen_of_avg_zero (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    {f : Fin 2 → ℝ} (hf : (chainGen a b ha0 ha1 hb0 hb1).avg f = 0) (x : Fin 2) :
    (chainGen a b ha0 ha1 hb0 hb1).applyP f x = (1 - a - b) * f x := by
  have hbf : b * f 0 + a * f 1 = 0 := by
    have h := hf
    rw [avg_gen ha0 ha1 hb0 hb1] at h
    have hab : a + b ≠ 0 := by positivity
    field_simp at h
    linarith
  have h0 : b * f 0 = -(a * f 1) := by linarith
  have h1 : a * f 1 = -(b * f 0) := by linarith
  have hx := applyP_gen ha0 ha1 hb0 hb1 f x
  rcases fin2_eq x with hxx | hxx <;> subst hxx
  · rw [hx]
    simp only [ite_true]
    linarith
  · rw [hx]
    have hne : ¬ ((1 : Fin 2) = 0) := by decide
    simp only [hne, ite_false]
    linarith

/-- **La identificación `σ² = γ(0) + 2∑_{k≥1}γ(k)` en TODA cadena de dos
estados irreducible y aperiódica, para todo observable centrado.** No hay
hipótesis espectral por observable: en dimensión dos es automática. -/
theorem sigmaSq_eq_gamma_tsum_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    {f : Fin 2 → ℝ} (hf : (chainGen a b ha0 ha1 hb0 hb1).avg f = 0) :
    (chainGen a b ha0 ha1 hb0 hb1).sigmaSq (fun x => (a + b)⁻¹ * f x)
      = GordinEigenM3.Chain.gamma (chainGen a b ha0 ha1 hb0 hb1) f 0
        + 2 * ∑' k : ℕ, GordinEigenM3.Chain.gamma (chainGen a b ha0 ha1 hb0 hb1) f (k + 1) := by
  have heig := eigen_of_avg_zero ha0 ha1 hb0 hb1 hf
  have hlam : (1 - a - b) ≠ 1 := by intro h; linarith
  have hlt : |1 - a - b| < 1 := by rw [abs_lt]; constructor <;> linarith
  have hmain := GordinEigenM3.Chain.sigmaSq_eq_gamma_tsum (D := chainGen a b ha0 ha1 hb0 hb1)
    heig hlam hlt
  have hfun : (fun x => (1 - (1 - a - b))⁻¹ * f x) = fun x => (a + b)⁻¹ * f x := by
    funext x
    rw [show (1 : ℝ) - (1 - a - b) = a + b by ring]
  rwa [hfun] at hmain

/-- La varianza en forma cerrada: `σ² = ((2-a-b)/(a+b))·π(f²)`. -/
theorem sigmaSq_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    {f : Fin 2 → ℝ} (hf : (chainGen a b ha0 ha1 hb0 hb1).avg f = 0) :
    (chainGen a b ha0 ha1 hb0 hb1).sigmaSq (fun x => (a + b)⁻¹ * f x)
      = ((2 - a - b) / (a + b)) * (chainGen a b ha0 ha1 hb0 hb1).avg (fun x => (f x) ^ 2) := by
  have heig := eigen_of_avg_zero ha0 ha1 hb0 hb1 hf
  have hlam : (1 - a - b) ≠ 1 := by intro h; linarith
  have hmain := GordinEigenM3.Chain.sigmaSq_poisson_eigen (D := chainGen a b ha0 ha1 hb0 hb1)
    heig hlam
  have hfun : (fun x => (1 - (1 - a - b))⁻¹ * f x) = fun x => (a + b)⁻¹ * f x := by
    funext x
    rw [show (1 : ℝ) - (1 - a - b) = a + b by ring]
  rw [hfun] at hmain
  rw [hmain]
  have hab : a + b ≠ 0 := by positivity
  field_simp
  ring

/-- El covariograma es geométrico: `γ(t) = (1-a-b)^t · π(f²)`. -/
theorem gamma_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    {f : Fin 2 → ℝ} (hf : (chainGen a b ha0 ha1 hb0 hb1).avg f = 0) (t : ℕ) :
    GordinEigenM3.Chain.gamma (chainGen a b ha0 ha1 hb0 hb1) f t = (1 - a - b) ^ t
      * (chainGen a b ha0 ha1 hb0 hb1).avg (fun x => (f x) ^ 2) := by
  rw [GordinEigenM3.Chain.gamma_eigen (D := chainGen a b ha0 ha1 hb0 hb1)
    (eigen_of_avg_zero ha0 ha1 hb0 hb1 hf) t, GordinEigenM3.Chain.gamma_zero]

/-- Sumabilidad absoluta del covariograma en esta clase. -/
theorem summable_abs_gamma_gen (ha0 : 0 < a) (ha1 : a < 1) (hb0 : 0 < b) (hb1 : b < 1)
    {f : Fin 2 → ℝ} (hf : (chainGen a b ha0 ha1 hb0 hb1).avg f = 0) :
    Summable (fun t : ℕ => |GordinEigenM3.Chain.gamma (chainGen a b ha0 ha1 hb0 hb1) f t|) := by
  refine GordinEigenM3.Chain.summable_abs_gamma (D := chainGen a b ha0 ha1 hb0 hb1)
    (eigen_of_avg_zero ha0 ha1 hb0 hb1 hf) ?_
  rw [abs_lt]; constructor <;> linarith

end GordinEigenTwoStateGen
