import Mathlib

open Finset BigOperators

/- Finite statistical decision problem (Wald): parameter set Θ, observation
   space X, action space A (all finite), observation law P, loss L.
   All identities are sum identities; boundedness is automatic in the finite
   case. -/

/-- Risk of a deterministic rule: R(θ, δ) = Σ_x P_θ(x) · L(θ, δ(x)). -/
def risk {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) : ℝ :=
  ∑ x, P θ x * L θ (δ x)

/-- Return of the one-decision MDP policy with reward −L:
    J_θ(π) = Σ_x P_θ(x) · (−L(θ, π(x))). The policy uses the observation,
    never θ; θ only indexes the model. -/
def mdpReturn {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (π : X → A) : ℝ :=
  ∑ x, P θ x * (-L θ (π x))

/-- Theorem (risk-preserving representation, book thm:ch9-isomorfismo):
    J_θ(π_δ) = −R(θ, δ) for the policy copying the rule. -/
theorem m_repr {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) :
    mdpReturn P L θ δ = -risk P L θ δ := by
  sorry

/-- Corollary (Bayes transfer, book cor:ch9-bayes): averaging the identity
    with a prior ν gives J_ν(π_δ) = −ρ_ν(δ). -/
theorem m_bayes {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (ν : Θ → ℝ) (δ : X → A) :
    (∑ θ, ν θ * mdpReturn P L θ δ) = -(∑ θ, ν θ * risk P L θ δ) := by
  sorry

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

/-- Theorem (admissibility transfer, book thm:ch9-admisibilidad):
    dominance of rules ⇔ return-dominance of the copied policies. -/
theorem m_admis {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₁ δ₂ : X → A) :
    dominates P L δ₁ δ₂ ↔ returnDominates P L δ₁ δ₂ := by
  sorry
