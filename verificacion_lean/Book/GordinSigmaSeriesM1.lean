/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m1 (dirección d2).

# Gordin: el covariograma `γ(k) = ⟨f, P^k f⟩` y la identificación de `σ²`

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

Continuación de `GordinDecayM1.lean`. Allí se prueba que, con `f` `π`-centrada y
`P` primitiva, `t ↦ (P^t f)_x` decae geométricamente y es sumable, y que
`h = ∑_t P^t f` resuelve `h − P h = f` con `π(h) = 0`. Aquí se cierra el paso
analítico que `DEUDA.md` §2.2 y `GordinCoreM8` dejan abierto: la representación
del covariograma como serie.

* `Chain.gamma f k = ∑_x π_x f(x) (P^k f)(x)` — el covariograma del libro,
  `γ(k) = Cov(f(S_0), f(S_k))` con `S_0 ∼ π`;
* `Chain.summable_gamma` — `∑_k |γ(k)| < ∞` (comparación con la cota geométrica);
* `Chain.avg_mul_poissonSeries` — **Fubini discreto**:
  `⟨f, h⟩_π = ∑_{t≥0} γ(t)`;
* `Chain.two_avg_sub_gamma` — álgebra de series:
  `2∑_{t≥0} γ(t) − γ(0) = γ(0) + 2∑_{k≥1} γ(k)`;
* `Chain.sigmaSq_eq_gamma_series` — **la identificación del libro**
  `σ² = γ(0) + 2∑_{k≥1} γ(k)`, componiendo con `GordinSigmaM1.sigmaSq_eq_two_avg`
  (la pieza algebraica auditada del enjambre `smwa5izeq`; importada aquí como
  copia declarada, no se reproba ni se reformula).

**Fidelidad declarada.** `π` es dato (no se construye), la matriz se supone
primitiva (`Matrix.IsPrimitive`, la versión nativa de irreducible + aperiódica) y
`f` centrada. NO se prueba el CLT de Gordin ni Skorokhod: la convergencia del
puente de martingalas sigue fuera de Mathlib. `C.thm:appD-gordin` sigue
`pending`; esto sólo cierra la identificación de la varianza asintótica.
-/
import Book.GordinDecayM1
import Book.GordinSigmaAlgebraM1

open Finset
open scoped Matrix

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

namespace ApendiceDGordinM8

namespace Chain

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- **Covariograma de `f`**: `γ(k) = ∑_x π_x f(x) · (P^k f)(x)`, es decir
`Cov(f(S_0), f(S_k))` cuando `S_0 ∼ π`. -/
noncomputable def gamma (D : Chain S) (f : S → ℝ) (k : ℕ) : ℝ :=
  D.avg (fun x => f x * (D.toMatrix ^ k *ᵥ f) x)

/-- `γ(0) = π(f²)`. -/
theorem gamma_zero (D : Chain S) (f : S → ℝ) :
    D.gamma f 0 = D.avg (fun x => (f x) ^ 2) := by
  simp only [gamma, pow_zero, Matrix.one_mulVec]
  congr 1
  funext x
  ring

variable (D : Chain S) [Nonempty S]

/-- El covariograma hereda la cota geométrica: `|γ(k)| ≤ C · S² · ρ^k` con
`S = supBound f` (la constante incorpora la cota uniforme de `f`). -/
theorem exists_gamma_geom_bound (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) :
    ∃ ρ C : ℝ, 0 < ρ ∧ ρ < 1 ∧ 0 ≤ C ∧ ∀ k : ℕ, |D.gamma f k| ≤ C * ρ ^ k := by
  obtain ⟨k, hk0, m, hm0, hm1, hm⟩ := D.exists_block_witness hprim
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := ApendiceDGordinBloques.exists_geom_bound hm0 hm1 hk0
  set SS : ℝ := ApendiceDGordinM8.supBound f with hSS
  have hS0 : 0 ≤ SS := Chain.supBound_nonneg f
  refine ⟨ρ, C * SS * SS, hρ0, hρ1, mul_nonneg (mul_nonneg (le_of_lt hC0) hS0) hS0, fun t => ?_⟩
  have hdec : ∀ x, |(D.toMatrix ^ t *ᵥ f) x| ≤ C * ρ ^ t * SS := by
    intro x
    calc |(D.toMatrix ^ t *ᵥ f) x|
        ≤ (1 - m) ^ (t / k) * ApendiceDGordinM8.supBound f :=
          ApendiceDGordinBloques.abs_mulVec_pow_le D.toMatrix D.π hprim.nonneg D.P_sum
            D.π_inv D.π_nonneg D.π_sum hm0 hm1 hm hf (Chain.abs_le_supBound f) t x
      _ ≤ (C * ρ ^ t) * ApendiceDGordinM8.supBound f :=
          mul_le_mul_of_nonneg_right (hbound t) (Chain.supBound_nonneg f)
      _ = C * ρ ^ t * SS := by rw [hSS]
  calc |D.gamma f t| = |∑ x, D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x)| := by
        rw [gamma, avg_apply]
    _ ≤ ∑ x, |D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x)| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ x, D.π x * (|f x| * |(D.toMatrix ^ t *ᵥ f) x|) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [abs_mul, abs_mul, abs_of_nonneg (D.π_nonneg x)]
    _ ≤ ∑ x, D.π x * (SS * (C * ρ ^ t * SS)) := by
        refine Finset.sum_le_sum fun x _ => ?_
        refine mul_le_mul_of_nonneg_left ?_ (D.π_nonneg x)
        exact mul_le_mul (Chain.abs_le_supBound f x) (hdec x) (abs_nonneg _) hS0
    _ = (∑ x : S, D.π x) * (SS * (C * ρ ^ t * SS)) := (Finset.sum_mul ..).symm
    _ = SS * (C * ρ ^ t * SS) := by rw [D.π_sum, one_mul]
    _ = C * SS * SS * ρ ^ t := by ring

/-- **El covariograma es sumable**: `∑_k |γ(k)| < ∞`. -/
theorem summable_gamma (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) : Summable (D.gamma f) := by
  obtain ⟨ρ, C, hρ0, hρ1, hC0, hbound⟩ := D.exists_gamma_geom_bound hprim hf
  exact (ApendiceDGordinBloques.summable_of_geom_bound hρ0 hρ1 hC0 hbound).1

/-- **Fubini discreto**: `⟨f, h⟩_π = ∑_{t≥0} γ(t)`, donde `h = ∑_t P^t f`.
El intercambio es una suma finita sobre `S` y la serie en `t`, justificado con
`tsum_finsetSum` y `tsum_mul_left`. -/
theorem avg_mul_poissonSeries (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) :
    D.avg (fun x => f x * ApendiceDGordinBloques.poissonSeries D.toMatrix f x)
      = ∑' t : ℕ, D.gamma f t := by
  have hsum : ∀ y : S, Summable (fun t : ℕ => (D.toMatrix ^ t *ᵥ f) y) :=
    fun y => D.summable_evalP_of_primitive hprim hf y
  have h1 : D.avg (fun x => f x * ApendiceDGordinBloques.poissonSeries D.toMatrix f x)
      = ∑ x : S, ∑' t : ℕ, D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x) := by
    rw [avg_apply]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [ApendiceDGordinBloques.poissonSeries]
    have hA : f x * (∑' t : ℕ, (D.toMatrix ^ t *ᵥ f) x)
        = ∑' t : ℕ, f x * (D.toMatrix ^ t *ᵥ f) x :=
      (tsum_mul_left (f := fun t : ℕ => (D.toMatrix ^ t *ᵥ f) x) (a := f x)).symm
    have hB : D.π x * (∑' t : ℕ, f x * (D.toMatrix ^ t *ᵥ f) x)
        = ∑' t : ℕ, D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x) :=
      (tsum_mul_left (f := fun t : ℕ => f x * (D.toMatrix ^ t *ᵥ f) x) (a := D.π x)).symm
    rw [hA, hB]
  have h2 : (∑ x : S, ∑' t : ℕ, D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x))
      = ∑' t : ℕ, ∑ x : S, D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x) :=
    (Summable.tsum_finsetSum (f := fun x t => D.π x * (f x * (D.toMatrix ^ t *ᵥ f) x))
      (s := Finset.univ) (fun x _ => by
        simpa [mul_assoc] using (hsum x).mul_left (D.π x * f x))).symm
  rw [h1, h2]
  rfl

/-- Álgebra de series: `2∑_{t≥0} γ(t) − γ(0) = γ(0) + 2∑_{k≥1} γ(k)`. -/
theorem two_avg_sub_gamma (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ}
    (hf : D.avg f = 0) :
    2 * (∑' t : ℕ, D.gamma f t) - D.gamma f 0
      = D.gamma f 0 + 2 * ∑' k : ℕ, D.gamma f (k + 1) := by
  have hs := D.summable_gamma hprim hf
  have h := Summable.tsum_eq_zero_add hs
  linarith

/-- **La identificación de la varianza asintótica del libro**:
`σ² = γ(0) + 2∑_{k≥1} γ(k)`. Combina la pieza algebraica
`GordinSigmaM1.sigmaSq_eq_two_avg` (`σ² = 2⟨f,h⟩ − ⟨f,f⟩`, probada para toda
`Chain`, sin hipótesis extra) con la representación `h = ∑_t P^t f` y el Fubini
discreto de este módulo. -/
theorem sigmaSq_eq_gamma_series (hprim : Matrix.IsPrimitive D.toMatrix) {f h : S → ℝ}
    (hf : D.avg f = 0) (hh : D.avg h = 0)
    (hpois : ∀ x, f x = h x - D.applyP h x) :
    D.sigmaSq h = D.gamma f 0 + 2 * ∑' k : ℕ, D.gamma f (k + 1) := by
  have heq : h = ApendiceDGordinBloques.poissonSeries D.toMatrix f :=
    D.eq_poissonSeries_of_poisson hprim hf hh hpois
  have hfh : D.avg (fun x => f x * h x) = ∑' t : ℕ, D.gamma f t := by
    rw [heq]
    exact D.avg_mul_poissonSeries hprim hf
  have hsigma : D.sigmaSq h
      = 2 * D.avg (fun x => f x * h x) - D.avg (fun x => (f x) ^ 2) :=
    GordinSigmaM1.sigmaSq_eq_two_avg D hpois
  rw [hsigma, hfh, ← D.gamma_zero f]
  exact D.two_avg_sub_gamma hprim hf

/-- **Forma final**: para toda `f` `π`-centrada existe una solución de Poisson
centrada `h` (la de `Chain.poisson_solution`, que aquí coincide con `∑_t P^t f`)
cuya varianza asintótica es la serie de covariogramas del libro. -/
theorem exists_poisson_solution_sigmaSq_eq_gamma_series
    (hprim : Matrix.IsPrimitive D.toMatrix) {f : S → ℝ} (hf : D.avg f = 0) :
    ∃ h : S → ℝ, D.avg h = 0 ∧ (∀ x, f x = h x - D.applyP h x) ∧
      D.sigmaSq h = D.gamma f 0 + 2 * ∑' k : ℕ, D.gamma f (k + 1) := by
  obtain ⟨h, hh, hpois⟩ := D.poisson_solution hf
  exact ⟨h, hh, hpois, D.sigmaSq_eq_gamma_series hprim hf hh hpois⟩

end Chain

end ApendiceDGordinM8
