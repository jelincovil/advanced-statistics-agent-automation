import Mathlib

/-!
# Book.SSCHCap06M7 — `ex:ssch-cap06`: OPE semiparamétrica con datos observacionales

Formaliza el ejemplo `ex:ssch-cap06` de `capitulos/cap10_casos.typ:312`
(enjambre `smw9820kx`, dirección `d7`).

El libro escribe la influencia eficiente para el valor integrado en el modelo
Markov por tiempo, horizonte fijo `H`, episodios iid:

  `φ(O) = v₀(S₀) − J + Σ_{t=0}^{H−1} γ^t w_t(S_t,A_t)(R_t + γ v_{t+1}(S_{t+1}) − q_t(S_t,A_t))`,  `v_H = 0`,

advierte que `w_t` es una razón **marginal** de ocupación (no el producto de
razones de acciones de la trayectoria), que la doble robustez da una identidad
de centrado bajo los conjuntos de auxiliares correctos, y que la interpretación
causal exige consistencia, intercambio secuencial y positividad respecto del
historial pertinente; un estado discretizado puede omitir confusores.

Fidelidad declarada:

* Se formaliza el **paso de un horizonte** (`H = 1`), que es donde vive la
  identidad de centrado: la sustitución de la razón marginal `w·μ = ρ` (lo que
  hace que la corrección se evalúe bajo la política objetivo) y la anulación de
  la corrección cuando `q` es la `Q` verdadera. El paso inductivo para `H`
  genérico exige la ley conjunta de la trayectoria y la propiedad de Markov por
  tiempo; no se formaliza (el libro tampoco lo demuestra: remite a
  `thm:ch6-kallus`).
* Se formaliza también el **fallo por falta de positividad**: dos modelos con
  la misma ley observable (la política de registro nunca juega la acción `a₁`)
  y valores objetivos distintos bajo `ρ` (`0` frente a `7`). Es el contenido
  formal de «no se presumen esas propiedades para un hospital».
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHCap06M7

/-! ## La identidad de centrado de un paso -/

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — recompensa
aumentada esperada en un paso:
`Q̄(s,a) = Σ_{s'} P(s,a,s')(r(s,a) + γ v(s'))`. Es la `Q` verdadera del modelo
de un paso (`q` cuando los auxiliares son correctos). -/
noncomputable def Ybar {S A : Type*} [Fintype S] (P : S → A → S → ℝ)
    (r : S → A → ℝ) (γ : ℝ) (v : S → ℝ) (s : S) (a : A) : ℝ :=
  ∑ s', P s a s' * (r s a + γ * v s')

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — media de una
recompensa aumentada con pesos de fila que suman uno:
`Σ_i P_i(r + γv_i) = r + γΣ_i P_i v_i`. -/
theorem sum_mul_add {ι : Type*} [Fintype ι] (P : ι → ℝ) (r γ : ℝ) (v : ι → ℝ)
    (hP : ∑ i, P i = 1) :
    ∑ i, P i * (r + γ * v i) = r + γ * ∑ i, P i * v i := by
  have h1 : ∀ i, P i * (r + γ * v i) = P i * r + γ * (P i * v i) := fun i => by ring
  rw [Finset.sum_congr rfl (fun i _ => h1 i), Finset.sum_add_distrib, ← Finset.sum_mul,
    ← Finset.mul_sum, hP, one_mul]

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — **sustitución de
la razón marginal**: si `w` es la razón de ocupación (`w(s,a)·μ(s,a) = ρ(s,a)`),
la corrección ponderada por la política de registro `μ` se evalúa como si se
ponderara por la política objetivo `ρ`. Es el paso que el libro subraya: `w_t`
entra como razón marginal, no como producto de razones de acciones. -/
theorem ratio_substitution {S A : Type*} [Fintype S] [Fintype A]
    (p : S → ℝ) (μ : S → A → ℝ) (ρ : S → A → ℝ) (w : S → A → ℝ)
    (hw : ∀ s a, w s a * μ s a = ρ s a) (f : S → A → ℝ) :
    ∑ s, p s * ∑ a, μ s a * (w s a * f s a) = ∑ s, p s * ∑ a, ρ s a * f s a := by
  refine Finset.sum_congr rfl fun s _ => ?_
  congr 1
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [← hw s a]
  ring

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — **centrado de la
corrección**: con `q` igual a la `Q` verdadera, la esperanza de la corrección
bajo la ley observable es cero. Doble robustez en su forma de un paso: la razón
marginal lleva la corrección a `ρ`, donde `q` reproduce exactamente la
esperanza condicional de la recompensa aumentada. -/
theorem dr_centering {S A : Type*} [Fintype S] [Fintype A]
    (p : S → ℝ) (μ ρ : S → A → ℝ) (P : S → A → S → ℝ) (r : S → A → ℝ)
    (γ : ℝ) (v : S → ℝ) (q : S → A → ℝ)
    (hQ : ∀ s a, q s a = Ybar P r γ v s a)
    (w : S → A → ℝ) (hw : ∀ s a, w s a * μ s a = ρ s a) :
    ∑ s, p s * ∑ a, μ s a * (w s a * (Ybar P r γ v s a - q s a)) = 0 := by
  have hterm : ∀ s a, μ s a * (w s a * (Ybar P r γ v s a - q s a))
      = ρ s a * (Ybar P r γ v s a - q s a) := by
    intro s a
    rw [← hw s a]
    ring
  apply Finset.sum_eq_zero
  intro s _
  rw [Finset.sum_congr rfl (fun a _ => hterm s a)]
  rw [mul_eq_zero]
  right
  apply Finset.sum_eq_zero
  intro a _
  rw [hQ s a, sub_self, mul_zero]

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — **φ está
centrado**: el valor integrado `J = Σ_s p_s v_s` es el valor esperado, bajo la
ley observable, del funcional
`v(S₀) + Σ_a μ(S₀,a)w(S₀,a)(Ybar − q)(S₀,a)`. -/
theorem dr_unbiased {S A : Type*} [Fintype S] [Fintype A]
    (p : S → ℝ) (μ ρ : S → A → ℝ) (P : S → A → S → ℝ) (r : S → A → ℝ)
    (γ : ℝ) (v : S → ℝ) (q : S → A → ℝ)
    (hQ : ∀ s a, q s a = Ybar P r γ v s a)
    (w : S → A → ℝ) (hw : ∀ s a, w s a * μ s a = ρ s a) :
    ∑ s, p s * (v s + ∑ a, μ s a * (w s a * (Ybar P r γ v s a - q s a)))
      = ∑ s, p s * v s := by
  have h1 : ∀ s, p s * (v s + ∑ a, μ s a * (w s a * (Ybar P r γ v s a - q s a)))
      = p s * v s + p s * (∑ a, μ s a * (w s a * (Ybar P r γ v s a - q s a))) := by
    intro s
    rw [mul_add]
  rw [Finset.sum_congr rfl (fun s _ => h1 s), Finset.sum_add_distrib,
    dr_centering p μ ρ P r γ v q hQ w hw, add_zero]

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — la `Q` verdadera
reproduce la recompensa aumentada (`sum_mul_add`), y de ahí sale la identidad de
Bellman de un paso para el valor integrado: la ecuación que `ex:ssch-cap03-b`
resuelve para `v`. -/
theorem valor_integrado {S A : Type*} [Fintype S] [Fintype A]
    (p : S → ℝ) (ρ : S → A → ℝ) (P : S → A → S → ℝ) (r : S → A → ℝ)
    (γ : ℝ) (v : S → ℝ) (q : S → A → ℝ)
    (hP : ∀ s a, ∑ s', P s a s' = 1)
    (hQ : ∀ s a, q s a = Ybar P r γ v s a)
    (hv : ∀ s, v s = ∑ a, ρ s a * q s a) :
    ∑ s, p s * v s
      = ∑ s, p s * ∑ a, ρ s a * r s a
        + γ * ∑ s, p s * ∑ a, ρ s a * ∑ s', P s a s' * v s' := by
  have hY : ∀ s a, Ybar P r γ v s a = r s a + γ * ∑ s', P s a s' * v s' := by
    intro s a
    simp only [Ybar]
    exact sum_mul_add (fun s' => P s a s') (r s a) γ v (hP s a)
  have h : ∀ s, v s = ∑ a, ρ s a * r s a
      + γ * ∑ a, ρ s a * ∑ s', P s a s' * v s' := by
    intro s
    rw [hv s]
    have h1 : ∀ a, ρ s a * q s a
        = ρ s a * r s a + γ * (ρ s a * ∑ s', P s a s' * v s') := by
      intro a
      rw [hQ s a, hY s a]
      ring
    rw [Finset.sum_congr rfl (fun a _ => h1 a), Finset.sum_add_distrib, ← Finset.mul_sum]
  have h2 : ∀ s, p s * v s
      = p s * (∑ a, ρ s a * r s a)
        + γ * (p s * (∑ a, ρ s a * ∑ s', P s a s' * v s')) := by
    intro s
    rw [h s]
    ring
  rw [Finset.sum_congr rfl (fun s _ => h2 s), Finset.sum_add_distrib, ← Finset.mul_sum]

/-! ## Sin positividad no hay identificación -/

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — política de
registro del contraejemplo: siempre `a₀`; la acción `a₁` nunca se observa. -/
def muReg : Bool → Bool → ℝ := fun _ a => if a then 0 else 1

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — política objetivo
del contraejemplo: siempre `a₁`. -/
def rhoObj : Bool → Bool → ℝ := fun _ a => if a then 1 else 0

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — modelo 1:
recompensa `0` en la acción no observada. -/
def rec1 : Bool → Bool → ℝ := fun _ a => if a then 0 else 5

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — modelo 2:
recompensa `7` en la acción no observada, idéntica en la observada. -/
def rec2 : Bool → Bool → ℝ := fun _ a => if a then 7 else 5

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — ley observable de
un paso (con `γ = 0`, la continuación no interviene): `E_μ[r(S,A)]`. -/
def obsLaw (r : Bool → Bool → ℝ) (s : Bool) : ℝ := ∑ a, muReg s a * r s a

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — valor objetivo de
un paso: `E_ρ[r(S,A)]`. -/
def tgtLaw (r : Bool → Bool → ℝ) (s : Bool) : ℝ := ∑ a, rhoObj s a * r s a

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — **la ley
observable no distingue los dos modelos**: como `μ(a₁) = 0`, ambos dan `5`. -/
theorem obsLaw_igual : ∀ s, obsLaw rec1 s = obsLaw rec2 s := by
  intro s
  cases s <;> simp [obsLaw, muReg, rec1, rec2]

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — **el valor
objetivo sí los distingue**: bajo `ρ` (que juega `a₁`) los valores son `0` y
`7`. Sin positividad, el funcional objetivo no está identificado por la ley
observable. -/
theorem tgtLaw_distinto : tgtLaw rec1 false = 0 ∧ tgtLaw rec2 false = 7 := by
  constructor <;> simp [tgtLaw, rhoObj, rec1, rec2]

/-- book: capitulos/cap10_casos.typ:312 (key: ex:ssch-cap06) — corolario del
contraejemplo: los dos modelos tienen la misma ley observable en todo estado y
valores objetivo distintos, luego **ningún estimador de la ley observable
identifica el valor objetivo**. -/
theorem no_identificacion_sin_positividad :
    (∀ s, obsLaw rec1 s = obsLaw rec2 s) ∧ tgtLaw rec1 false ≠ tgtLaw rec2 false := by
  refine ⟨obsLaw_igual, ?_⟩
  rw [tgtLaw_distinto.1, tgtLaw_distinto.2]
  norm_num

end SSCHCap06M7
