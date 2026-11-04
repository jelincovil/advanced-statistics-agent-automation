import Mathlib

open Finset BigOperators

/-!
# Machine-checked core identities of Chapter 4 (monograph M).

Proved automatically by the Dream-RSI discovery pilot `lean-pilot-mopsis`
(2026-11-03, run finished: 3/3 solved) and recorded here for reproduction:

    lean pilot_core_proven.lean

Scope kept deliberately finite: the statements are the sum identities of the
risk-preserving representation; probability measures appear only as weight
functions (normalization is not needed for the algebraic identities). The
frontier theorem and the sequential stopping recursion are Phases 1–2 of
`VERIFICACION_LEAN_PLAN.md`.
-/

/-- Risk of a deterministic rule in a finite Wald problem: R(θ, δ) = Σ_x P_θ(x) · L(θ, δ(x)). -/
def risk {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) : ℝ :=
  ∑ x, P θ x * L θ (δ x)

/-- Return of the one-decision MDP policy π with reward −L, initial law P_θ:
    J_θ(π) = Σ_x P_θ(x) · (−L(θ, π(x))). The policy sees x, never θ. -/
def mdpReturn {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (π : X → A) : ℝ :=
  ∑ x, P θ x * (-L θ (π x))

/-- Risk-preserving representation (M, Ch. 4, thm:m-repr): copying the rule
    pointwise preserves the objective up to sign. -/
theorem m_repr {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) :
    mdpReturn P L θ δ = -risk P L θ δ := by
  simp only [mdpReturn, risk, mul_neg, Finset.sum_neg_distrib]

/-- Bayes transfer (M, Ch. 4, cor:m-bayes): averaging the identity with any
    prior ν yields J_ν(π_δ) = −ρ_ν(δ). -/
theorem m_bayes {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (ν : Θ → ℝ) (δ : X → A) :
    (∑ θ, ν θ * mdpReturn P L θ δ) = -(∑ θ, ν θ * risk P L θ δ) := by
  simp [risk, mdpReturn, Finset.mul_sum, Finset.sum_neg_distrib, mul_neg]

/-- δ₁ dominates δ₂ (within the deterministic class). Note the comparison is
    over θ, not over states. -/
def dominates {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₁ δ₂ : X → A) : Prop :=
  (∀ θ, risk P L θ δ₁ ≤ risk P L θ δ₂) ∧ (∃ θ, risk P L θ δ₁ < risk P L θ δ₂)

/-- Return-dominance: weakly larger return everywhere, strict somewhere. -/
def returnDominates {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (π₁ π₂ : X → A) : Prop :=
  (∀ θ, mdpReturn P L θ π₁ ≥ mdpReturn P L θ π₂) ∧
    (∃ θ, mdpReturn P L θ π₁ > mdpReturn P L θ π₂)

/-- Admissibility transfer (M, Ch. 4, thm:m-admis): dominance of rules iff
    return-dominance of the copied policies; the order runs over θ. -/
theorem m_admis {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₁ δ₂ : X → A) :
    dominates P L δ₁ δ₂ ↔ returnDominates P L δ₁ δ₂ := by
  simp only [dominates, returnDominates, m_repr]
  constructor
  · rintro ⟨hweak, hstrict⟩
    refine ⟨fun θ => by simpa using hweak θ, ?_⟩
    obtain ⟨θ, hθ⟩ := hstrict
    exact ⟨θ, by simpa using hθ⟩
  · rintro ⟨hweak, hstrict⟩
    refine ⟨fun θ => by simpa using hweak θ, ?_⟩
    obtain ⟨θ, hθ⟩ := hstrict
    exact ⟨θ, by simpa using hθ⟩
