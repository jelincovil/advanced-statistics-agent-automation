import Mathlib

/-!
# Book.Foundation — problema de decisión de Wald finito (libro `v1.0-libro`)

Capa base del proyecto `verificacion_lean`
(PLAN_LEAN_LIBRO_2026-11-04.md, §3). Definiciones compartidas por los
capítulos; estilo del piloto (`monografia_M/pilot_core_proven.lean`,
corrida `lean-pilot-mopsis`, 3/3, 2026-11-03), cuyos teoremas migra
`Book/Cap05Representacion.lean`.

Convenciones del proyecto (plan §6): cero cabos sueltos, auditoría
`#print axioms` por teorema (Book/Audit.lean), sin `native_decide`,
trazabilidad con la clave del libro en cada declaración y fidelidad
declarada: aquí la versión finita; el libro enuncia algunas de estas
definiciones para `X` finito o numerable (cap05_incrustacion.typ:17).
-/

open Finset BigOperators

/-- book: capitulos/cap05_incrustacion.typ:17 (key: def:ch9-wald) —
riesgo de Wald de una regla determinista en espacios finitos:
`R(θ, δ) = ∑_x P_θ(x) · L(θ, δ(x))`. Las `P_θ` son pesos; la normalización
no interviene en las identidades algebraicas del capítulo. -/
def risk {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) : ℝ :=
  ∑ x, P θ x * L θ (δ x)

/-- book: capitulos/cap05_incrustacion.typ:28 (key: def:ch9-mdp) —
retorno de la política copiada en el MDP de una decisión con transición
terminal: `J_θ(π) = ∑_x P_θ(x) · (−L(θ, π(x)))`. La política usa la
observación `x`; el parámetro solo indexa el modelo (nunca la política). -/
def mdpReturn {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (π : X → A) : ℝ :=
  ∑ x, P θ x * (-L θ (π x))

/-- book: capitulos/cap02_wald.typ (key: def:ch7-dominancia) — dominancia
de reglas dentro de una clase: riesgo menor en todo θ, estricto en alguno. -/
def dominates {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₁ δ₂ : X → A) : Prop :=
  (∀ θ, risk P L θ δ₁ ≤ risk P L θ δ₂) ∧ (∃ θ, risk P L θ δ₁ < risk P L θ δ₂)

/-- book: capitulos/cap05_incrustacion.typ (key: thm:ch9-admisibilidad) —
retorno-dominancia: retorno mayor o igual en todo θ, estricto en alguno. -/
def returnDominates {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (π₁ π₂ : X → A) : Prop :=
  (∀ θ, mdpReturn P L θ π₁ ≥ mdpReturn P L θ π₂) ∧
    (∃ θ, mdpReturn P L θ π₁ > mdpReturn P L θ π₂)
