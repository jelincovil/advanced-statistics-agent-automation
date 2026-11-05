import Mathlib
import Book.Foundation

/-!
# Book.Cap02Wald — cap. 2 del libro (capitulos/cap02_wald.typ)

Teoría de la decisión de Wald finita: regla de Bayes como minimización
puntual de la pérdida posterior (thm:ch7-bayes), certificación minimax
mediante Bayes (thm:ch7-minimax-bayes), admisibilidad bayesiana con prior
estrictamente positivo (thm:ch7-admisibilidad-bayes) y clase
esencialmente completa en el problema finito (thm:ch7-complete-class),
esta última por separación de conos (Farkas/Hahn–Banach geométrico,
`ProperCone.hyperplane_separation'`).

Fidelidad declarada: espacios finitos; el libro enuncia algunos de estos
resultados para espacios generales con medibilidad e integrabilidad
(cap02_wald.typ:83), aquí todo es automático por finitud. Las hipótesis
de modelo (leyes P no negativas normalizadas) se declaran completas por
fidelidad aunque parte del álgebra no las use.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators Filter
open scoped Topology

universe u

section Wald

variable {Θ X A : Type u} [Fintype Θ] [Nonempty Θ] [DecidableEq Θ]
  [Fintype X] [Fintype A] [Nonempty A] (P : Θ → X → ℝ) (L : Θ → A → ℝ)

/-! ## thm:ch7-bayes — minimización de la pérdida posterior -/

/-- Predictiva de `x` bajo el prior `ν`: `m(x) = ∑_θ ν(θ) P_θ(x)`. -/
def predLaw (ν : Θ → ℝ) (x : X) : ℝ := ∑ θ, ν θ * P θ x

/-- Posterior (convención del proyecto, como en Cap05: predictiva nula ⇒
posterior 0, sin efecto sobre las esperanzas). -/
noncomputable def bayesPost (ν : Θ → ℝ) (x : X) (θ : Θ) : ℝ :=
  if predLaw P ν x = 0 then 0 else ν θ * P θ x / predLaw P ν x

/-- Pérdida posterior de la acción `a` tras observar `x`:
`ℓ_ν(x,a) = ∑_θ bayesPost(θ|x) L(θ,a)`. -/
noncomputable def postLoss (ν : Θ → ℝ) (x : X) (a : A) : ℝ :=
  ∑ θ, bayesPost P ν x θ * L θ a

/-- Riesgo de una regla aleatorizada `δ` (filas no negativas que suman
uno), en forma previa: `∑_x ∑_a P_θ(x) δ(x,a) L(θ,a)`. -/
def rndRisk (δ : X → A → ℝ) (θ : Θ) : ℝ :=
  ∑ x, ∑ a, P θ x * δ x a * L θ a

private theorem predLaw_nonneg (hν : ∀ θ, 0 ≤ ν θ) (hP : ∀ θ x, 0 ≤ P θ x)
    (x : X) : 0 ≤ predLaw P ν x :=
  Finset.sum_nonneg fun θ _ => mul_nonneg (hν θ) (hP θ x)

/-- Puente posterior–previa: `m(x) · ℓ_ν(x,a) = ∑_θ ν(θ) P_θ(x) L(θ,a)`.
Cuando la predictiva es nula, ambos lados son cero (masas no negativas). -/
private theorem predLaw_mul_postLoss (ν : Θ → ℝ) (hν : ∀ θ, 0 ≤ ν θ)
    (hP : ∀ θ x, 0 ≤ P θ x) (x : X) (a : A) :
    predLaw P ν x * postLoss P L ν x a = ∑ θ, ν θ * P θ x * L θ a := by
  rcases em (predLaw P ν x = 0) with h0 | h0
  · have hz : ∀ θ ∈ (univ : Finset Θ), ν θ * P θ x = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg
        (fun θ _ => mul_nonneg (hν θ) (hP θ x))).mp ?_
      show ∑ θ, ν θ * P θ x = 0
      rw [← predLaw, h0]
    rw [h0, zero_mul]
    exact (Finset.sum_eq_zero fun θ _ => by
      have h := hz θ (Finset.mem_univ θ)
      rw [h, zero_mul]).symm
  · have hm : predLaw P ν x ≠ 0 := h0
    have hterm : ∀ θ : Θ, bayesPost P ν x θ * L θ a
        = (ν θ * P θ x * L θ a) / predLaw P ν x := by
      intro θ
      rw [bayesPost, if_neg hm, div_mul_eq_mul_div]
    have hsplit : postLoss P L ν x a
        = (∑ θ, ν θ * P θ x * L θ a) / predLaw P ν x := by
      calc postLoss P L ν x a = ∑ θ, bayesPost P ν x θ * L θ a := rfl
        _ = ∑ θ, (ν θ * P θ x * L θ a) / predLaw P ν x :=
            Finset.sum_congr rfl fun θ _ => hterm θ
        _ = (∑ θ, ν θ * P θ x * L θ a) / predLaw P ν x := by rw [← Finset.sum_div]
    rw [hsplit]
    field_simp

/-- Bayes-risk previo de una regla aleatorizada, en forma posterior. -/
private theorem bayesRiskRnd_eq (ν : Θ → ℝ) (hν : ∀ θ, 0 ≤ ν θ)
    (hP : ∀ θ x, 0 ≤ P θ x) (δ : X → A → ℝ) (hδa : ∀ x a, 0 ≤ δ x a)
    (hδ1 : ∀ x, ∑ a, δ x a = 1) :
    ∑ θ, ν θ * rndRisk P L δ θ
      = ∑ x, predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) := by
  have hstep : ∀ θ : Θ, ν θ * rndRisk P L δ θ
      = ∑ x, ∑ a, δ x a * (ν θ * P θ x * L θ a) := by
    intro θ
    rw [rndRisk, Finset.mul_sum]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun a _ => ?_
    ring
  calc ∑ θ, ν θ * rndRisk P L δ θ
      = ∑ θ, ∑ x, ∑ a, δ x a * (ν θ * P θ x * L θ a) :=
        Finset.sum_congr rfl fun θ _ => hstep θ
    _ = ∑ x, ∑ a, ∑ θ, δ x a * (ν θ * P θ x * L θ a) := by
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [Finset.sum_comm]
    _ = ∑ x, ∑ a, δ x a * (∑ θ, ν θ * P θ x * L θ a) := by
        refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun a _ => ?_
        rw [← Finset.mul_sum]
    _ = ∑ x, ∑ a, δ x a * (predLaw P ν x * postLoss P L ν x a) := by
        refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun a _ => ?_
        rw [predLaw_mul_postLoss P L ν hν hP x a]
    _ = ∑ x, predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        calc ∑ a, δ x a * (predLaw P ν x * postLoss P L ν x a)
            = ∑ a, predLaw P ν x * (δ x a * postLoss P L ν x a) :=
              Finset.sum_congr rfl fun a _ => by ring
          _ = predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) := by
              rw [← Finset.mul_sum]

/-- Bayes-risk previo de una regla determinista, en forma posterior. -/
private theorem bayesRiskDet_eq (ν : Θ → ℝ) (hν : ∀ θ, 0 ≤ ν θ)
    (hP : ∀ θ x, 0 ≤ P θ x) (δ : X → A) :
    ∑ θ, ν θ * risk P L θ δ
      = ∑ x, predLaw P ν x * postLoss P L ν x (δ x) := by
  have hstep : ∀ θ : Θ, ν θ * risk P L θ δ
      = ∑ x, ν θ * P θ x * L θ (δ x) := by
    intro θ
    rw [risk, Finset.mul_sum]
    exact Finset.sum_congr rfl fun x _ => by ring
  calc ∑ θ, ν θ * risk P L θ δ
      = ∑ θ, ∑ x, ν θ * P θ x * L θ (δ x) :=
        Finset.sum_congr rfl fun θ _ => hstep θ
    _ = ∑ x, ∑ θ, ν θ * P θ x * L θ (δ x) := Finset.sum_comm
    _ = ∑ x, predLaw P ν x * postLoss P L ν x (δ x) := by
        refine Finset.sum_congr rfl fun x _ => ?_
        rw [predLaw_mul_postLoss P L ν hν hP x (δ x)]

/-- book: capitulos/cap02_wald.typ:83 (key: thm:ch7-bayes) —
minimización de la pérdida posterior: existe una regla determinista que
en cada `x` minimiza `ℓ_ν(x,·)` (el libro la construye con desempate
fijo por primer índice; aquí se enuncia la existencia de una regla
minimizadora puntual, equivalente en el problema finito), y esa regla es
de Bayes en la clase de todas las reglas aleatorizadas. Además, toda
regla aleatorizada que alcance el mismo riesgo de Bayes debe concentrar
su masa en acciones minimizadoras de la pérdida posterior en toda
observación con predictiva no nula (la «casi seguridad» del libro es
seguridad puntual en la versión finita); su comportamiento en
observaciones predictivamente nulas no queda determinado.
Origen: F2 2026-11-05 (nuevo). -/
theorem ch7_bayes (ν : Θ → ℝ) (hν : ∀ θ, 0 ≤ ν θ) (hν1 : ∑ θ, ν θ = 1)
    (hP : ∀ θ x, 0 ≤ P θ x) :
    ∃ δstar : X → A, (∀ x a, postLoss P L ν x (δstar x) ≤ postLoss P L ν x a)
      ∧ (∀ δ : X → A → ℝ, (∀ x a, 0 ≤ δ x a) → (∀ x, ∑ a, δ x a = 1) →
          ∑ θ, ν θ * risk P L θ δstar
            ≤ ∑ θ, ν θ * rndRisk P L δ θ)
      ∧ (∀ δ : X → A → ℝ, (∀ x a, 0 ≤ δ x a) → (∀ x, ∑ a, δ x a = 1) →
          ∑ θ, ν θ * risk P L θ δstar = ∑ θ, ν θ * rndRisk P L δ θ →
            ∀ x, predLaw P ν x ≠ 0 → ∀ a, δ x a ≠ 0 →
              postLoss P L ν x a = postLoss P L ν x (δstar x)) := by
  -- elección de la regla minimizadora puntual
  have hex : ∀ x : X, ∃ a₀ : A, ∀ a, postLoss P L ν x a₀ ≤ postLoss P L ν x a := by
    intro x
    obtain ⟨a₀, _, ha₀⟩ :=
      Finset.exists_min_image (univ : Finset A) (postLoss P L ν x) Finset.univ_nonempty
    exact ⟨a₀, fun a => ha₀ a (Finset.mem_univ a)⟩
  choose δstar hδstar using hex
  refine ⟨δstar, hδstar, ?_, ?_⟩
  · -- parte 1: Bayes entre todas las aleatorizadas
    intro δ hδa hδ1
    have hkey : ∀ x : X,
        predLaw P ν x * postLoss P L ν x (δstar x)
          ≤ predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) := by
      intro x
      have havg : ∑ a, δ x a * postLoss P L ν x a
          ≥ ∑ a, δ x a * postLoss P L ν x (δstar x) :=
        Finset.sum_le_sum fun a _ =>
          mul_le_mul_of_nonneg_left (hδstar x a) (hδa x a)
      have hsum : ∑ a, δ x a * postLoss P L ν x (δstar x)
          = postLoss P L ν x (δstar x) := by
        rw [← Finset.sum_mul, hδ1 x, one_mul]
      calc predLaw P ν x * postLoss P L ν x (δstar x)
          ≤ predLaw P ν x * (∑ a, δ x a * postLoss P L ν x (δstar x)) := by
              refine mul_le_mul_of_nonneg_left ?_ (predLaw_nonneg P hν hP x)
              rw [hsum]
          _ ≤ predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) :=
              mul_le_mul_of_nonneg_left havg (predLaw_nonneg P hν hP x)
    calc ∑ θ, ν θ * risk P L θ δstar
        = ∑ x, predLaw P ν x * postLoss P L ν x (δstar x) :=
          bayesRiskDet_eq P L ν hν hP δstar
      _ ≤ ∑ x, predLaw P ν x * (∑ a, δ x a * postLoss P L ν x a) :=
          Finset.sum_le_sum fun x _ => hkey x
      _ = ∑ θ, ν θ * rndRisk P L δ θ :=
          (bayesRiskRnd_eq P L ν hν hP δ hδa hδ1).symm
  · -- parte 2: igualdad ⇒ concentración en minimizadores
    intro δ hδa hδ1 heq x hx a ha
    by_contra hne
    have hlt : postLoss P L ν x (δstar x) < postLoss P L ν x a := lt_of_le_of_ne (hδstar x a) (Ne.symm hne)
    have hpos : 0 < predLaw P ν x :=
      lt_of_le_of_ne (predLaw_nonneg P hν hP x) (Ne.symm hx)
    -- reescritura de la brecha puntual como suma de términos no negativos
    have hrew : ∀ x' : X, (∑ a', δ x' a' * postLoss P L ν x' a') - postLoss P L ν x' (δstar x')
        = ∑ a', δ x' a' * (postLoss P L ν x' a' - postLoss P L ν x' (δstar x')) := by
      intro x'
      have h2 : ∑ a', δ x' a' * postLoss P L ν x' (δstar x') = postLoss P L ν x' (δstar x') := by
        rw [← Finset.sum_mul, hδ1 x', one_mul]
      simp only [mul_sub, Finset.sum_sub_distrib, h2]
    have hnn : ∀ x' : X,
        0 ≤ predLaw P ν x' * ((∑ a', δ x' a' * postLoss P L ν x' a') - postLoss P L ν x' (δstar x')) := by
      intro x'
      refine mul_nonneg (predLaw_nonneg P hν hP x') ?_
      rw [hrew x']
      exact Finset.sum_nonneg fun a' _ =>
        mul_nonneg (hδa x' a') (sub_nonneg.mpr (hδstar x' a'))
    have hgx : 0 < predLaw P ν x * ((∑ a', δ x a' * postLoss P L ν x a') - postLoss P L ν x (δstar x)) := by
      refine mul_pos hpos ?_
      rw [hrew x]
      have hsingle : δ x a * (postLoss P L ν x a - postLoss P L ν x (δstar x))
          ≤ ∑ a', δ x a' * (postLoss P L ν x a' - postLoss P L ν x (δstar x)) :=
        Finset.single_le_sum (fun a' _ =>
          mul_nonneg (hδa x a') (sub_nonneg.mpr (hδstar x a'))) (Finset.mem_univ a)
      have hpos' : 0 < δ x a * (postLoss P L ν x a - postLoss P L ν x (δstar x)) :=
        mul_pos (lt_of_le_of_ne (hδa x a) (fun h => ha h.symm)) (sub_pos.mpr hlt)
      exact lt_of_lt_of_le hpos' hsingle
    -- la suma de brechas es cero por la igualdad de riesgos de Bayes
    have hsplit : (∑ x', predLaw P ν x' * ((∑ a', δ x' a' * postLoss P L ν x' a')
        - postLoss P L ν x' (δstar x')))
        = (∑ θ, ν θ * rndRisk P L δ θ) - (∑ θ, ν θ * risk P L θ δstar) := by
      have hA : ∑ θ, ν θ * rndRisk P L δ θ
          = ∑ x', predLaw P ν x' * (∑ a', δ x' a' * postLoss P L ν x' a') :=
        bayesRiskRnd_eq P L ν hν hP δ hδa hδ1
      have hB : ∑ θ, ν θ * risk P L θ δstar
          = ∑ x', predLaw P ν x' * postLoss P L ν x' (δstar x') :=
        bayesRiskDet_eq P L ν hν hP δstar
      rw [hA, hB, ← Finset.sum_sub_distrib]
      refine Finset.sum_congr rfl fun x' _ => ?_
      rw [mul_sub]
    have htotal : 0 < (∑ x', predLaw P ν x' * ((∑ a', δ x' a' * postLoss P L ν x' a')
        - postLoss P L ν x' (δstar x'))) :=
      Finset.sum_pos' (fun x' _ => hnn x') ⟨x, Finset.mem_univ x, hgx⟩
    rw [hsplit, heq, sub_self] at htotal
    exact lt_irrefl 0 htotal


/-! ## thm:ch7-minimax-bayes y thm:ch7-admisibilidad-bayes (parte de #16–#17) -/

/-- book: capitulos/cap02_wald.typ:123 (key: thm:ch7-minimax-bayes) —
certificación minimax mediante Bayes: si `δ_ν` es de Bayes para `ν` y su
riesgo máximo coincide con su riesgo de Bayes, entonces es minimax: cada
regla determinista tiene riesgo máximo al menos tan grande. El control
en todo `Θ` es el del libro (cap09_tabla_canonica.typ:101: constancia
solo sobre el soporte del prior no basta).
Origen: F2 2026-11-05 (nuevo). -/
theorem ch7_minimax_bayes (ν : Θ → ℝ) (δν : X → A)
    (hν : ∀ θ, 0 ≤ ν θ) (hν1 : ∑ θ, ν θ = 1)
    (hbayes : ∀ δ : X → A, ∑ θ, ν θ * risk P L θ δν ≤ ∑ θ, ν θ * risk P L θ δ)
    (hsup : (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δν)
      = ∑ θ, ν θ * risk P L θ δν) :
    ∀ δ : X → A, (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δν)
      ≤ (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δ) := by
  intro δ
  have hle : ∑ θ, ν θ * risk P L θ δ
      ≤ (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ' => risk P L θ' δ) := by
    have h1 : ∀ θ ∈ (univ : Finset Θ),
        ν θ * risk P L θ δ
          ≤ ν θ * (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ' => risk P L θ' δ) :=
      fun θ _ => mul_le_mul_of_nonneg_left
        (Finset.le_sup' (f := fun θ' => risk P L θ' δ) (Finset.mem_univ θ)) (hν θ)
    have h2 : ∑ θ, ν θ * (univ : Finset Θ).sup' Finset.univ_nonempty
        (fun θ' => risk P L θ' δ)
        = ((univ : Finset Θ).sup' Finset.univ_nonempty (fun θ' => risk P L θ' δ))
            * (∑ θ, ν θ) := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun θ _ => mul_comm _ _
    rw [hν1] at h2
    calc ∑ θ, ν θ * risk P L θ δ
        ≤ ∑ θ, ν θ * (univ : Finset Θ).sup' Finset.univ_nonempty
            (fun θ' => risk P L θ' δ) := Finset.sum_le_sum h1
      _ = ((univ : Finset Θ).sup' Finset.univ_nonempty (fun θ' => risk P L θ' δ)) * 1 := by
          rw [h2]
      _ = (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ' => risk P L θ' δ) := by
          rw [mul_one]
  calc (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δν)
      = ∑ θ, ν θ * risk P L θ δν := hsup
    _ ≤ ∑ θ, ν θ * risk P L θ δ := hbayes δ
    _ ≤ (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δ) := hle

/-- book: capitulos/cap02_wald.typ:123 (key: thm:ch7-minimax-bayes) —
caso particular del libro: riesgo constante + Bayes ⇒ certificación. -/
theorem ch7_minimax_bayes_constante (ν : Θ → ℝ) (δν : X → A)
    (hν : ∀ θ, 0 ≤ ν θ) (hν1 : ∑ θ, ν θ = 1)
    (hbayes : ∀ δ : X → A, ∑ θ, ν θ * risk P L θ δν ≤ ∑ θ, ν θ * risk P L θ δ)
    (hconst : ∃ c : ℝ, ∀ θ, risk P L θ δν = c) :
    ∀ δ : X → A, (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δν)
      ≤ (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δ) := by
  obtain ⟨c, hc⟩ := hconst
  refine ch7_minimax_bayes P L ν δν hν hν1 hbayes ?_
  have hSup : (univ : Finset Θ).sup' Finset.univ_nonempty (fun θ => risk P L θ δν) = c := by
    refine le_antisymm ?_ ?_
    · refine (Finset.sup'_le_iff Finset.univ_nonempty _).mpr ?_
      intro θ _
      rw [hc θ]
    · have hθ₀ := Finset.le_sup' (f := fun θ' => risk P L θ' δν)
        (Finset.mem_univ (Classical.arbitrary Θ))
      rw [hc (Classical.arbitrary Θ)] at hθ₀
      exact hθ₀
  have hsum : ∑ θ, ν θ * risk P L θ δν = c * (∑ θ, ν θ) := by
    rw [Finset.sum_congr rfl (fun θ _ => by rw [hc θ])]
    rw [← Finset.sum_mul]
    exact mul_comm _ _
  rw [hSup, hsum, hν1, mul_one]

/-- book: capitulos/cap02_wald.typ:101 (key: thm:ch7-admisibilidad-bayes) —
admisibilidad bayesiana en un modelo finito: prior estrictamente
positivo ⇒ toda regla de Bayes (riesgo de Bayes finito, automático por
finitud) es admisible en la clase determinista. Para espacios continuos
se requieren otras condiciones (declarado en el libro). -/
theorem ch7_admisibilidad_bayes (ν : Θ → ℝ) (δν : X → A)
    (hν : ∀ θ, 0 < ν θ) (hν1 : ∑ θ, ν θ = 1)
    (hbayes : ∀ δ : X → A, ∑ θ, ν θ * risk P L θ δν ≤ ∑ θ, ν θ * risk P L θ δ) :
    ¬ ∃ δ : X → A, dominates P L δ δν := by
  rintro ⟨δ, hle, θ₀, hlt⟩
  have hweak : ∀ θ ∈ (univ : Finset Θ),
      ν θ * risk P L θ δ ≤ ν θ * risk P L θ δν :=
    fun θ _ => mul_le_mul_of_nonneg_left (hle θ) (le_of_lt (hν θ))
  have hstrict : ν θ₀ * risk P L θ₀ δ < ν θ₀ * risk P L θ₀ δν :=
    mul_lt_mul_of_pos_left hlt (hν θ₀)
  have hsum : ∑ θ, ν θ * risk P L θ δ < ∑ θ, ν θ * risk P L θ δν :=
    Finset.sum_lt_sum hweak ⟨θ₀, Finset.mem_univ θ₀, hstrict⟩
  exact absurd (hbayes δ) (not_le.mpr hsum)

/-! ## thm:ch7-complete-class — clase esencialmente completa (problema finito) -/

/-- Regla aleatorizada: filas no negativas que suman uno. -/
def IsRnd (δ : X → A → ℝ) : Prop :=
  (∀ x a, 0 ≤ δ x a) ∧ (∀ x, ∑ a, δ x a = 1)

/-- Vector de riesgo de una regla aleatorizada (una coordenada por
parámetro). -/
def riskVec (δ : X → A → ℝ) : Θ → ℝ :=
  fun θ => ∑ x, ∑ a, P θ x * δ x a * L θ a

/-- La mezcla de dos reglas aleatorizadas es aleatorizada. -/
private theorem isRnd_mix (δ₁ δ₂ : X → A → ℝ) (h₁ : IsRnd δ₁) (h₂ : IsRnd δ₂)
    {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    IsRnd (fun x a => t * δ₁ x a + (1 - t) * δ₂ x a) := by
  refine ⟨fun x a => add_nonneg (mul_nonneg ht0 (h₁.1 x a))
      (mul_nonneg (sub_nonneg.mpr ht1) (h₂.1 x a)), fun x => ?_⟩
  calc (∑ a, (t * δ₁ x a + (1 - t) * δ₂ x a))
      = (∑ a, t * δ₁ x a) + (∑ a, (1 - t) * δ₂ x a) := by rw [Finset.sum_add_distrib]
    _ = t * (∑ a, δ₁ x a) + (1 - t) * (∑ a, δ₂ x a) := by
        rw [← Finset.mul_sum, ← Finset.mul_sum]
    _ = t * 1 + (1 - t) * 1 := by rw [h₁.2 x, h₂.2 x]
    _ = 1 := by ring

/-- Linealidad del vector de riesgo en la regla (mezclas). -/
private theorem riskVec_mix (δ₁ δ₂ : X → A → ℝ) (t : ℝ) (θ : Θ) :
    riskVec P L (fun x a => t * δ₁ x a + (1 - t) * δ₂ x a) θ
      = t * riskVec P L δ₁ θ + (1 - t) * riskVec P L δ₂ θ := by
  have h1 : ∀ x : X, (∑ a, P θ x * (t * δ₁ x a + (1 - t) * δ₂ x a) * L θ a)
      = t * (∑ a, P θ x * δ₁ x a * L θ a) + (1 - t) * (∑ a, P θ x * δ₂ x a * L θ a) := by
    intro x
    calc ∑ a, P θ x * (t * δ₁ x a + (1 - t) * δ₂ x a) * L θ a
        = ∑ a, (t * (P θ x * δ₁ x a * L θ a) + (1 - t) * (P θ x * δ₂ x a * L θ a)) :=
          Finset.sum_congr rfl fun a _ => by ring
      _ = (∑ a, t * (P θ x * δ₁ x a * L θ a)) + (∑ a, (1 - t) * (P θ x * δ₂ x a * L θ a)) := by
          rw [Finset.sum_add_distrib]
      _ = t * (∑ a, P θ x * δ₁ x a * L θ a) + (1 - t) * (∑ a, P θ x * δ₂ x a * L θ a) := by
          rw [← Finset.mul_sum, ← Finset.mul_sum]
  calc riskVec P L (fun x a => t * δ₁ x a + (1 - t) * δ₂ x a) θ
      = ∑ x, (t * (∑ a, P θ x * δ₁ x a * L θ a)
          + (1 - t) * (∑ a, P θ x * δ₂ x a * L θ a)) :=
        Finset.sum_congr rfl fun x _ => h1 x
    _ = (∑ x, t * (∑ a, P θ x * δ₁ x a * L θ a))
        + (∑ x, (1 - t) * (∑ a, P θ x * δ₂ x a * L θ a)) := by
        rw [Finset.sum_add_distrib]
    _ = t * riskVec P L δ₁ θ + (1 - t) * riskVec P L δ₂ θ := by
        rw [riskVec, riskVec, ← Finset.mul_sum, ← Finset.mul_sum]

/-- El conjunto de reglas aleatorizadas es compacto (cerrado y acotado en
`ℝ^{X×A}`; Heine–Borel). -/
private theorem rnd_compact : IsCompact {δ : X → A → ℝ | IsRnd δ} := by
  rw [Metric.isCompact_iff_isClosed_bounded]
  constructor
  · have h1 : IsClosed {δ : X → A → ℝ | ∀ x a, 0 ≤ δ x a} := by
      have hEq : {δ : X → A → ℝ | ∀ x a, 0 ≤ δ x a}
          = ⋂ p : X × A, {δ : X → A → ℝ | 0 ≤ δ p.1 p.2} := by
        ext δ; simp [Set.mem_iInter]
      rw [hEq]
      refine isClosed_iInter (fun p => ?_)
      exact isClosed_le continuous_const
        (by fun_prop)
    have h2 : IsClosed {δ : X → A → ℝ | ∀ x, ∑ a, δ x a = 1} := by
      have hEq : {δ : X → A → ℝ | ∀ x, ∑ a, δ x a = 1}
          = ⋂ x : X, {δ : X → A → ℝ | ∑ a, δ x a = 1} := by
        ext δ; simp [Set.mem_iInter]
      rw [hEq]
      refine isClosed_iInter (fun x => ?_)
      exact isClosed_eq
        (continuous_finsetSum _ fun a _ => by fun_prop) continuous_const
    have hEq2 : {δ : X → A → ℝ | IsRnd δ}
        = {δ : X → A → ℝ | ∀ x a, 0 ≤ δ x a} ∩ {δ : X → A → ℝ | ∀ x, ∑ a, δ x a = 1} := by
      ext δ; simp [IsRnd]
    rw [hEq2]
    exact h1.inter h2
  · rw [isBounded_iff_forall_norm_le]
    refine ⟨1, ?_⟩
    intro δ hδ
    have hmem : IsRnd δ := hδ
    refine (pi_norm_le_iff_of_nonneg (by norm_num : (0:ℝ) ≤ 1)).mpr fun x => ?_
    refine (pi_norm_le_iff_of_nonneg (by norm_num : (0:ℝ) ≤ 1)).mpr fun a => ?_
    rw [Real.norm_eq_abs]
    have h2 : δ x a ≤ ∑ a', δ x a' :=
      Finset.single_le_sum (fun a' _ => hmem.1 x a') (Finset.mem_univ a)
    rw [hmem.2 x] at h2
    rw [abs_le]
    exact ⟨by linarith [hmem.1 x a], h2⟩

/-- El vector de riesgo es continuo. -/
private theorem riskVec_continuous : Continuous (fun δ : X → A → ℝ => riskVec P L δ) := by
  refine continuous_pi fun θ => ?_
  refine continuous_finsetSum _ fun x _ => ?_
  refine continuous_finsetSum _ fun a _ => ?_
  exact by fun_prop


/-! ### El cono de separación (Farkas/Hahn–Banach geométrico) -/

/-- Cono convexo punteado de los incrementos de riesgo: cerrado bajo
sumas (mezclas de reglas) y escalados no negativos; su clausura es un
cono proper y admite hiperplano de soporte. Base no enunciada del
libro: el libro usa «la convexidad del conjunto de vectores de riesgo y
un hiperplano de soporte» (cap02_wald.typ:114). -/
private def coneSet (v : Θ → ℝ) : Set (EuclideanSpace ℝ Θ) :=
  {z | ∃ t : ℝ, 0 ≤ t ∧ ∃ δ : X → A → ℝ, IsRnd δ ∧ ∃ μ : Θ → ℝ, (∀ θ, 0 ≤ μ θ) ∧
    (WithLp.ofLp z : Θ → ℝ) = t • ((riskVec P L δ) - v + μ)}

private theorem coneSet_add (v : Θ → ℝ) {w₁ w₂ : EuclideanSpace ℝ Θ}
    (h₁ : w₁ ∈ coneSet P L v) (h₂ : w₂ ∈ coneSet P L v) : w₁ + w₂ ∈ coneSet P L v := by
  rcases h₁ with ⟨t₁, ht₁, δ₁, hδ₁, μ₁, hμ₁, hq₁⟩
  rcases h₂ with ⟨t₂, ht₂, δ₂, hδ₂, μ₂, hμ₂, hq₂⟩
  by_cases hsum : t₁ + t₂ = 0
  · have ht₁0 : t₁ = 0 := by linarith
    have ht₂0 : t₂ = 0 := by linarith
    refine ⟨0, le_refl 0, δ₁, hδ₁, fun _ => 0, fun θ => le_refl 0, ?_⟩
    rw [WithLp.ofLp_add, hq₁, hq₂, ht₁0, ht₂0, zero_smul, zero_smul, add_zero]
    simp
  · have hpos : 0 < t₁ + t₂ := lt_of_le_of_ne (add_nonneg ht₁ ht₂) (Ne.symm hsum)
    set lam : ℝ := t₁ / (t₁ + t₂) with hlam
    have hla0 : 0 ≤ lam := by
      show 0 ≤ t₁ / (t₁ + t₂)
      positivity
    have hla1 : lam ≤ 1 := by
      show t₁ / (t₁ + t₂) ≤ 1
      rw [div_le_one hpos]
      linarith
    have hδmix : IsRnd (fun x a => lam * δ₁ x a + (1 - lam) * δ₂ x a) :=
      isRnd_mix δ₁ δ₂ hδ₁ hδ₂ hla0 hla1
    have hStep2 : ((t₁ + t₂) • ((riskVec P L (fun x a => lam * δ₁ x a + (1 - lam) * δ₂ x a))
            - v + (fun θ => lam * μ₁ θ + (1 - lam) * μ₂ θ)))
          = t₁ • ((riskVec P L δ₁) - v + μ₁) + t₂ • ((riskVec P L δ₂) - v + μ₂) := by
      funext θ
      have hm : (riskVec P L (fun x a => lam * δ₁ x a + (1 - lam) * δ₂ x a)) θ
          = lam * riskVec P L δ₁ θ + (1 - lam) * riskVec P L δ₂ θ :=
        riskVec_mix P L δ₁ δ₂ lam θ
      simp only [Pi.add_apply, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
      rw [hm]
      have htl : (t₁ + t₂) * lam = t₁ := by
        show (t₁ + t₂) * (t₁ / (t₁ + t₂)) = t₁
        field_simp
      have htr : (t₁ + t₂) * (1 - lam) = t₂ := by
        show (t₁ + t₂) * (1 - t₁ / (t₁ + t₂)) = t₂
        field_simp
        ring
      linear_combination htl * (riskVec P L δ₁ θ + μ₁ θ)
        + htr * (riskVec P L δ₂ θ + μ₂ θ)
    refine ⟨t₁ + t₂, le_of_lt hpos, fun x a => lam * δ₁ x a + (1 - lam) * δ₂ x a,
      hδmix, fun θ => lam * μ₁ θ + (1 - lam) * μ₂ θ,
      fun θ => add_nonneg (mul_nonneg hla0 (hμ₁ θ))
        (mul_nonneg (sub_nonneg.mpr hla1) (hμ₂ θ)), ?_⟩
    rw [WithLp.ofLp_add, hq₁, hq₂, hStep2]

private theorem coneSet_zero (v : Θ → ℝ) (δr : X → A → ℝ) (hr : IsRnd δr) :
    (0 : EuclideanSpace ℝ Θ) ∈ coneSet P L v := by
  refine ⟨0, le_refl 0, δr, hr, fun _ => 0, fun θ => le_refl 0, ?_⟩
  simp

private theorem coneSet_smul (v : Θ → ℝ) {c : {c : ℝ // 0 ≤ c}}
    {z : EuclideanSpace ℝ Θ} (hz : z ∈ coneSet P L v) : c • z ∈ coneSet P L v := by
  rcases hz with ⟨t, ht, δ, hδ, μ, hμ, hq⟩
  refine ⟨c.1 * t, mul_nonneg c.2 ht, δ, hδ, μ, hμ, ?_⟩
  show (WithLp.ofLp ((c.1 : ℝ) • z) : Θ → ℝ) = _
  rw [WithLp.ofLp_smul 2 c.1 z, hq, smul_smul]

private noncomputable def coneKP (v : Θ → ℝ) (δr : X → A → ℝ) (hr : IsRnd δr) :
    ProperCone ℝ (EuclideanSpace ℝ Θ) where
  carrier := closure (coneSet P L v)
  add_mem' := by
    intro x y hx hy
    exact map_mem_closure₂ continuous_add hx hy
      (fun _ hz _ hw => coneSet_add P L v hz hw)
  zero_mem' := subset_closure (coneSet_zero P L v δr hr)
  smul_mem' := by
    intro c x hx
    exact map_mem_closure (continuous_const_smul (c : ℝ)) hx
      (fun _ hz => coneSet_smul P L v hz)
  isClosed' := isClosed_closure

/-- El vector «todos −1» no pertenece a la clausura del cono: pertenecer
exigiría una regla que domine estrictamente a la admisible. -/
private theorem x0_not_mem (v : Θ → ℝ) (δr : X → A → ℝ) (hr : IsRnd δr)
    (hv : v = riskVec P L δr)
    (hadm : ∀ δ, IsRnd δ → (∀ θ, riskVec P L δ θ ≤ v θ) →
      ∀ θ, riskVec P L δ θ = v θ) :
    (WithLp.toLp 2 (fun _ => (-1:ℝ))) ∉ closure (coneSet P L v) := by
  intro hmem
  obtain ⟨f, hf, hlim⟩ := mem_closure_iff_seq_limit.mp hmem
  have hdist : ∀ᶠ n in atTop, dist (f n) (WithLp.toLp 2 (fun _ => (-1:ℝ))) < 1/2 :=
    (Metric.tendsto_nhds.mp hlim) (1/2) (by norm_num)
  obtain ⟨n₀, hn₀⟩ := hdist.exists
  rcases hf n₀ with ⟨t, ht, δ, hδ, μ, hμ, hq⟩
  have hbound : ∀ θ, (WithLp.ofLp (f n₀) : Θ → ℝ) θ < -1/2 := by
    intro θ
    have h1 : ‖(WithLp.ofLp (f n₀ - WithLp.toLp 2 (fun _ => (-1:ℝ))) : Θ → ℝ) θ‖
        ≤ ‖f n₀ - WithLp.toLp 2 (fun _ => (-1:ℝ))‖ := PiLp.norm_apply_le _ θ
    rw [sub_eq_add_neg, WithLp.ofLp_add, WithLp.ofLp_neg, ← sub_eq_add_neg] at h1
    have h2 : ‖f n₀ - WithLp.toLp 2 (fun _ => (-1:ℝ))‖ < 1/2 := hn₀
    have h3 : |(WithLp.ofLp (f n₀) : Θ → ℝ) θ - (fun _ => (-1:ℝ)) θ| < 1/2 := by
      rw [Real.norm_eq_abs] at h1; exact lt_of_le_of_lt h1 h2
    have h4 := abs_lt.mp h3
    have h5 : (fun _ => (-1:ℝ)) θ = (-1:ℝ) := rfl
    rw [h5] at h4
    linarith
  have hval : ∀ θ, (WithLp.ofLp (f n₀) : Θ → ℝ) θ
      = t * (((riskVec P L δ) - v + μ) θ) := by
    intro θ
    rw [hq]
    rfl
  have hbound' : ∀ θ, t * (((riskVec P L δ) - v + μ) θ) < -1/2 := by
    intro θ
    rw [← hval θ]
    exact hbound θ
  obtain ⟨θ₀⟩ := ‹Nonempty Θ›
  by_cases ht0 : t = 0
  · rw [ht0] at hbound'
    simp only [zero_mul] at hbound'
    exact absurd (hbound' θ₀) (by norm_num)
  · have htpos : 0 < t := lt_of_le_of_ne ht (Ne.symm ht0)
    have hkey : ∀ θ, riskVec P L δ θ < v θ := by
      intro θ
      have hb := hbound' θ
      have hsplit : t * (((riskVec P L δ) - v + μ) θ)
          = t * ((riskVec P L δ θ - v θ) + μ θ) := by
        simp only [Pi.add_apply, Pi.sub_apply]
      rw [hsplit] at hb
      have hlt : (riskVec P L δ θ - v θ) + μ θ < 0 := by
        by_contra hge
        push Not at hge
        have hnn : 0 ≤ t * ((riskVec P L δ θ - v θ) + μ θ) :=
          mul_nonneg (le_of_lt htpos) hge
        linarith
      linarith [hμ θ]
    have hle : ∀ θ, riskVec P L δ θ ≤ v θ := fun θ => le_of_lt (hkey θ)
    have heq := hadm δ hδ hle
    have hk := hkey θ₀
    rw [heq θ₀] at hk
    exact lt_irrefl _ hk

/-- book: capitulos/cap02_wald.typ:108 (key: thm:ch7-complete-class) —
parte 1: toda regla aleatorizada admisible es de Bayes para algún prior,
que puede asignar masa cero a ciertos parámetros. La prueba es la del
libro: convexidad de los vectores de riesgo (mezclas de reglas
aleatorizadas) e hiperplano de soporte, aquí vía la separación de conos
propios de Mathlib (Farkas geométrico) aplicada a la clausura del cono de
incrementos. La admisibilidad se enuncia en forma positiva (toda regla
con riesgo puntualmente menor o igual coincide), equivalente a la
negación de dominancia.
Origen: F2 2026-11-05 (nuevo). -/
theorem ch7_complete_class_bayes (δstar : X → A → ℝ) (hr : IsRnd δstar)
    (hadm : ∀ δ, IsRnd δ → (∀ θ, riskVec P L δ θ ≤ riskVec P L δstar θ) →
      ∀ θ, riskVec P L δ θ = riskVec P L δstar θ) :
    ∃ ν : Θ → ℝ, (∀ θ, 0 ≤ ν θ) ∧ (∑ θ, ν θ = 1) ∧
      (∀ δ, IsRnd δ → ∑ θ, ν θ * riskVec P L δstar θ
        ≤ ∑ θ, ν θ * riskVec P L δ θ) := by
  obtain ⟨v, hv⟩ : ∃ v : Θ → ℝ, v = riskVec P L δstar := ⟨_, rfl⟩
  rw [← hv] at hadm
  have hmemKP : ∀ z : EuclideanSpace ℝ Θ,
      (z ∈ coneKP P L v δstar hr ↔ z ∈ closure (coneSet P L v)) := fun z => Iff.rfl
  have hnotmem : (WithLp.toLp 2 (fun _ => (-1:ℝ))) ∉ coneKP P L v δstar hr := by
    intro hin
    exact x0_not_mem P L v δstar hr hv hadm ((hmemKP _).mp hin)
  obtain ⟨y, hy, hy₀⟩ :
      ∃ y : EuclideanSpace ℝ Θ,
        (∀ x ∈ coneKP P L v δstar hr, 0 ≤ inner ℝ x y)
        ∧ (inner ℝ (WithLp.toLp 2 (fun _ => (-1:ℝ))) y < 0) :=
    ProperCone.hyperplane_separation' (coneKP P L v δstar hr) hnotmem
  have hinner : ∀ (g : Θ → ℝ),
      inner ℝ (WithLp.toLp 2 g) y = ∑ θ, g θ * (WithLp.ofLp y : Θ → ℝ) θ := by
    intro g
    simp [PiLp.inner_apply, mul_comm]
  have hsub : ∀ z : EuclideanSpace ℝ Θ, z ∈ coneSet P L v → z ∈ coneKP P L v δstar hr := by
    intro z hz
    exact (hmemKP z).mpr (subset_closure hz)
  have hlam : ∀ θ, 0 ≤ (WithLp.ofLp y : Θ → ℝ) θ := by
    intro θ
    have hmem : (WithLp.toLp 2 ((Pi.single θ (1:ℝ) : Θ → ℝ))) ∈ coneSet P L v := by
      refine ⟨1, zero_le_one, δstar, hr, (Pi.single θ (1:ℝ) : Θ → ℝ),
        fun θ' => by simp only [Pi.single_apply]; split <;> norm_num, ?_⟩
      rw [hv]
      simp
    have hge := hy _ (hsub _ hmem)
    rw [hinner] at hge
    have hsingle : ∑ θ', (Pi.single θ (1:ℝ) : Θ → ℝ) θ' * (WithLp.ofLp y : Θ → ℝ) θ'
        = (WithLp.ofLp y : Θ → ℝ) θ := by
      rw [Finset.sum_eq_single θ]
      · simp [Pi.single_apply]
      · intro b _ hb; simp [Pi.single_apply, hb]
      · intro hout; exact absurd (Finset.mem_univ θ) hout
    rw [hsingle] at hge
    exact hge
  have hsum : 0 < ∑ θ, (WithLp.ofLp y : Θ → ℝ) θ := by
    rw [hinner (fun _ => (-1:ℝ))] at hy₀
    have hrew : (∑ θ, (fun _ => (-1:ℝ)) θ * (WithLp.ofLp y : Θ → ℝ) θ)
        = -∑ θ, (WithLp.ofLp y : Θ → ℝ) θ := by
      simp
    rw [hrew] at hy₀
    linarith
  have hmain : ∀ δ, IsRnd δ → (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ * riskVec P L δstar θ)
      ≤ (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ * riskVec P L δ θ) := by
    intro δ hδ
    have hmem : (WithLp.toLp 2 ((riskVec P L δ) - v)) ∈ coneSet P L v := by
      refine ⟨1, zero_le_one, δ, hδ, fun _ => 0, fun θ => le_refl 0, ?_⟩
      funext x
      simp
    have hge := hy _ (hsub _ hmem)
    rw [hinner] at hge
    have hsplit : (∑ θ, ((riskVec P L δ) - v) θ * (WithLp.ofLp y : Θ → ℝ) θ)
        = (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ * riskVec P L δ θ)
          - (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ * v θ) := by
      simp only [Pi.sub_apply, sub_mul, mul_comm]
      rw [Finset.sum_sub_distrib]
    rw [hsplit] at hge
    rw [← hv]
    linarith
  -- normalización del prior
  refine ⟨fun θ => (WithLp.ofLp y : Θ → ℝ) θ / (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ),
    fun θ => div_nonneg (hlam θ) (le_of_lt hsum), ?_, fun δ hδ => ?_⟩
  · rw [← Finset.sum_div, div_self (ne_of_gt hsum)]
  · have h1 := hmain δ hδ
    show (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ / (∑ θ', (WithLp.ofLp y : Θ → ℝ) θ')
          * riskVec P L δstar θ)
        ≤ (∑ θ, (WithLp.ofLp y : Θ → ℝ) θ / (∑ θ', (WithLp.ofLp y : Θ → ℝ) θ')
          * riskVec P L δ θ)
    simp only [div_mul_eq_mul_div]
    rw [← Finset.sum_div, ← Finset.sum_div]
    rw [div_le_div_iff₀ hsum hsum]
    exact mul_le_mul_of_nonneg_right h1 (le_of_lt hsum)

theorem ch7_complete_class_esencial (δ₀ : X → A → ℝ) (hr₀ : IsRnd δ₀) :
    ∃ ν : Θ → ℝ, (∀ θ, 0 ≤ ν θ) ∧ (∑ θ, ν θ = 1) ∧ ∃ δ', IsRnd δ' ∧
      (∀ θ, riskVec P L δ' θ ≤ riskVec P L δ₀ θ) ∧
      (∀ δ, IsRnd δ → ∑ θ, ν θ * riskVec P L δ' θ
        ≤ ∑ θ, ν θ * riskVec P L δ θ) := by
  obtain ⟨v₀, hv₀⟩ : ∃ v₀ : Θ → ℝ, v₀ = riskVec P L δ₀ := ⟨_, rfl⟩
  set D₀ : Set (Θ → ℝ) := (fun δ => riskVec P L δ) '' {δ : X → A → ℝ | IsRnd δ}
    ∩ {w | ∀ θ, w θ ≤ v₀ θ} with hD₀
  have hbox : IsClosed {w : Θ → ℝ | ∀ θ, w θ ≤ v₀ θ} := by
    have hEq : {w : Θ → ℝ | ∀ θ, w θ ≤ v₀ θ}
        = ⋂ θ : Θ, {w : Θ → ℝ | w θ ≤ v₀ θ} := by
      ext w; simp [Set.mem_iInter]
    rw [hEq]
    exact isClosed_iInter fun θ => isClosed_le (continuous_apply θ) continuous_const
  have hcomp : IsCompact D₀ :=
    (rnd_compact.image (riskVec_continuous P L)).inter_right hbox
  have hne : D₀.Nonempty := ⟨v₀, ⟨δ₀, hr₀, hv₀.symm⟩, fun θ => le_refl _⟩
  obtain ⟨wmin, hwmem, hwmin⟩ :=
    hcomp.exists_isMinOn hne (continuous_finsetSum _ (fun θ _ => continuous_apply θ)).continuousOn
  obtain ⟨δ', hr', rfl⟩ := hwmem.1
  have hadm : ∀ δ, IsRnd δ → (∀ θ, riskVec P L δ θ ≤ riskVec P L δ' θ) →
      ∀ θ, riskVec P L δ θ = riskVec P L δ' θ := by
    intro δ hδ hle
    have hmem : (riskVec P L δ) ∈ D₀ :=
      ⟨⟨δ, hδ, rfl⟩, fun θ => le_trans (hle θ) (hwmem.2 θ)⟩
    have hφ1 : (∑ θ, riskVec P L δ' θ) ≤ ∑ θ, riskVec P L δ θ := hwmin hmem
    have hφ2 : (∑ θ, riskVec P L δ θ) ≤ ∑ θ, riskVec P L δ' θ :=
      Finset.sum_le_sum fun θ _ => hle θ
    have hz : ∑ θ, (riskVec P L δ' θ - riskVec P L δ θ) = 0 := by
      have hsp : ∑ θ, (riskVec P L δ' θ - riskVec P L δ θ)
          = (∑ θ, riskVec P L δ' θ) - (∑ θ, riskVec P L δ θ) := by
        rw [← Finset.sum_sub_distrib]
      rw [hsp]
      linarith
    have hall := (Finset.sum_eq_zero_iff_of_nonneg
      (fun θ _ => sub_nonneg.mpr (hle θ))).mp hz
    exact fun θ => (sub_eq_zero.mp (hall θ (Finset.mem_univ θ))).symm
  obtain ⟨ν, hν, hν1, hbayes⟩ := ch7_complete_class_bayes P L δ' hr' hadm
  have hle : ∀ θ, riskVec P L δ' θ ≤ riskVec P L δ₀ θ := by
    have h := hwmem.2
    simpa [hv₀] using h
  exact ⟨ν, hν, hν1, δ', hr', hle, hbayes⟩

end Wald
