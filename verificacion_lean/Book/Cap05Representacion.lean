import Mathlib
import Book.Foundation

/-!
# Book.Cap05Representacion — cap. 5 del libro (capitulos/cap05_incrustacion.typ)

Migración del piloto (`monografia_M/pilot_core_proven.lean`, corrida
`lean-pilot-mopsis`, 3/3, 2026-11-03) con los nombres canónicos del plan
(§3: derivados de la clave del libro), más el eslabón que faltaba en el
piloto: `cor:ch7-traduccion` (intercambio minimax).

Los tres primeros teoremas provienen del piloto; su origen está declarado
en el dashboard (Progress/DASHBOARD.md).
-/

open Finset BigOperators

universe u

/-- book: capitulos/cap05_incrustacion.typ:41 (key: thm:ch9-isomorfismo) —
la copia puntual de la regla conserva el objetivo salvo signo:
`J_θ(π_δ) = -R(θ, δ)`. Origen: piloto 2026-11-03 (m_repr). -/
theorem ch9_isomorfismo {Θ X A : Type*} [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (θ : Θ) (δ : X → A) :
    mdpReturn P L θ δ = -risk P L θ δ := by
  simp only [mdpReturn, risk, mul_neg, Finset.sum_neg_distrib]

/-- book: capitulos/cap05_incrustacion.typ:143 (key: cor:ch9-bayes) —
el promedio bajo un prior arbitrario viaja por la identidad:
`J_ν(π_δ) = -ρ_ν(δ)`. Origen: piloto 2026-11-03 (m_bayes). -/
theorem ch9_bayes {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (ν : Θ → ℝ) (δ : X → A) :
    (∑ θ, ν θ * mdpReturn P L θ δ) = -(∑ θ, ν θ * risk P L θ δ) := by
  simp [risk, mdpReturn, Finset.mul_sum, Finset.sum_neg_distrib, mul_neg]

/-- book: capitulos/cap05_incrustacion.typ:136 (key: thm:ch9-admisibilidad) —
dominancia de reglas si y solo si retorno-dominancia de las políticas
copiadas; el orden corre sobre los modelos θ, no sobre estados iniciales.
Origen: piloto 2026-11-03 (m_admis). -/
theorem ch9_admisibilidad {Θ X A : Type*} [Fintype Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₁ δ₂ : X → A) :
    dominates P L δ₁ δ₂ ↔ returnDominates P L δ₁ δ₂ := by
  simp only [dominates, returnDominates, ch9_isomorfismo]
  constructor
  · rintro ⟨hweak, hstrict⟩
    refine ⟨fun θ => by simpa using hweak θ, ?_⟩
    obtain ⟨θ, hθ⟩ := hstrict
    exact ⟨θ, by simpa using hθ⟩
  · rintro ⟨hweak, hstrict⟩
    refine ⟨fun θ => by simpa using hweak θ, ?_⟩
    obtain ⟨θ, hθ⟩ := hstrict
    exact ⟨θ, by simpa using hθ⟩

/-! ## cor:ch7-traduccion — el eslabón que faltaba en el piloto -/

/-- Intercambio sup/neg sobre conjuntos finitos (auxiliar privado; esta
versión de Mathlib no trae `Finset.sup'_neg`). -/
private theorem sup'_neg_eq_neg_inf' {β : Type*} {s : Finset β} (H : s.Nonempty)
    (f : β → ℝ) : s.sup' H (fun i => -(f i)) = -(s.inf' H f) := by
  refine le_antisymm ?_ ?_
  · rw [Finset.sup'_le_iff]
    intro b hb
    have h1 : s.inf' H f ≤ f b := Finset.inf'_le f hb
    linarith
  · have h2 : -(s.sup' H (fun i => -(f i))) ≤ s.inf' H f := by
      rw [Finset.le_inf'_iff]
      intro b hb
      have h3 : -(f b) ≤ s.sup' H (fun i => -(f i)) := Finset.le_sup' (fun i => -(f i)) hb
      linarith
    linarith

/-- Forma dual del intercambio: `inf' (−f) = − sup' f`. -/
private theorem inf'_neg_eq_neg_sup' {β : Type*} {s : Finset β} (H : s.Nonempty)
    (f : β → ℝ) : s.inf' H (fun i => -(f i)) = -(s.sup' H f) := by
  have h := sup'_neg_eq_neg_inf' H (fun i => -(f i))
  have hnorm : s.sup' H (fun i => -(-(f i))) = s.sup' H f := by
    rw [show (fun i => -(-(f i))) = f from funext fun i => neg_neg (f i)]
  rw [hnorm] at h
  linarith

/-- Paso interior de `cor:ch7-traduccion`, compartido por la parte operativa
(`ch7_traduccion_optimos`) y la identidad de valores (`ch7_traduccion`):
para cada política, `inf_θ J_θ(π) = -sup_θ R(θ,π)`. -/
private theorem inf_J_eq_neg_sup_R {Θ X A : Type*}
    [Fintype Θ] [Nonempty Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (π : X → A) :
    (Finset.univ : Finset Θ).inf' Finset.univ_nonempty
        (fun θ => mdpReturn P L θ π)
      = -((Finset.univ : Finset Θ).sup' Finset.univ_nonempty
          (fun θ => risk P L θ π)) := by
  have hfun : (fun θ => mdpReturn P L θ π) = (fun θ => -(risk P L θ π)) :=
    funext fun θ => ch9_isomorfismo P L θ π
  rw [hfun]
  exact inf'_neg_eq_neg_sup' Finset.univ_nonempty (fun θ => risk P L θ π)

/-- book: capitulos/cap05_incrustacion.typ:183 (key: cor:ch7-traduccion) —
parte operativa del corolario: una regla `δ₀` (la `δ*` del libro) es
minimax (ninguna regla mejora su peor caso) si y solo si su política
copiada es maximin (ninguna política mejora su mejor caso). Cuantifica
sobre testigos individuales: no necesita `Fintype (X → A)`.
Origen: F0 2026-11-04 (nuevo; el piloto no cubría este corolario). -/
theorem ch7_traduccion_optimos {Θ X A : Type*}
    [Fintype Θ] [Nonempty Θ] [Fintype X]
    (P : Θ → X → ℝ) (L : Θ → A → ℝ) (δ₀ : X → A) :
    (∀ δ : X → A, (Finset.univ : Finset Θ).sup' Finset.univ_nonempty
          (fun θ => risk P L θ δ₀)
        ≤ (Finset.univ : Finset Θ).sup' Finset.univ_nonempty
          (fun θ => risk P L θ δ))
    ↔ (∀ π : X → A, (Finset.univ : Finset Θ).inf' Finset.univ_nonempty
          (fun θ => mdpReturn P L θ π)
        ≤ (Finset.univ : Finset Θ).inf' Finset.univ_nonempty
          (fun θ => mdpReturn P L θ δ₀)) := by
  constructor
  · intro h π
    rw [inf_J_eq_neg_sup_R P L π, inf_J_eq_neg_sup_R P L δ₀]
    exact neg_le_neg (h π)
  · intro h δ
    have hd := h δ
    rw [inf_J_eq_neg_sup_R P L δ, inf_J_eq_neg_sup_R P L δ₀] at hd
    linarith

section minimax_valores

variable {Θ X A : Type*} [Fintype Θ] [Nonempty Θ] [Fintype X] [DecidableEq X]
  [Fintype A] [Nonempty A]

instance : Nonempty (X → A) := ⟨fun _ => Classical.choice ‹Nonempty A›⟩

/-- book: capitulos/cap05_incrustacion.typ:183 (key: cor:ch7-traduccion) —
versión finita del intercambio minimax:
`inf_δ sup_θ R(θ,δ) = -sup_π inf_θ J_θ(π)`.
El libro añade: «Si existen óptimos, las reglas minimax corresponden a
políticas maximin de la familia»; en el problema finito los extremos
existen, y la igualdad de valores se prueba aquí directamente. La parte
operativa, par a par, es `ch7_traduccion_optimos`.
Origen: F0 2026-11-04 (nuevo; el piloto no cubría este corolario). -/
theorem ch7_traduccion (P : Θ → X → ℝ) (L : Θ → A → ℝ) :
    (Finset.univ : Finset (X → A)).inf' Finset.univ_nonempty
        (fun δ => (Finset.univ : Finset Θ).sup' Finset.univ_nonempty
          (fun θ => risk P L θ δ))
      = -((Finset.univ : Finset (X → A)).sup' Finset.univ_nonempty
           (fun π => (Finset.univ : Finset Θ).inf' Finset.univ_nonempty
             (fun θ => mdpReturn P L θ π))) := by
  -- paso exterior: sup_π (inf_θ J_θ) = -inf_δ (sup_θ R), vía el paso interior
  have hrw : (Finset.univ : Finset (X → A)).sup' Finset.univ_nonempty
        (fun π => (Finset.univ : Finset Θ).inf' Finset.univ_nonempty
          (fun θ => mdpReturn P L θ π))
      = -((Finset.univ : Finset (X → A)).inf' Finset.univ_nonempty
          (fun δ => (Finset.univ : Finset Θ).sup' Finset.univ_nonempty
            (fun θ => risk P L θ δ))) := by
    simp only [inf_J_eq_neg_sup_R]
    exact sup'_neg_eq_neg_inf' Finset.univ_nonempty
      (fun π => (Finset.univ : Finset Θ).sup' Finset.univ_nonempty
        (fun θ => risk P L θ π))
  rw [hrw]
  ring

end minimax_valores

/-! ## thm:ch9-secuencial — programación dinámica bayesiana de observación y parada -/

section Secuencial

variable {Θ Y A : Type u} [Fintype Θ] [Fintype Y] [Fintype A] [Nonempty A]
  (q : Θ → Y → ℝ) (L : Θ → A → ℝ) (c : ℝ)

/-- Estrategia de observación y parada sobre creencias: detenerse y
decidir una acción, u observar un símbolo y continuar por rama. (Base no
enunciada en el libro.) -/
inductive Strat (A Y : Type u) : Type u where
  | stop : A → Strat A Y
  | obs : (Y → Strat A Y) → Strat A Y

/-- Profundidad: máximo de observaciones que la estrategia puede usar. -/
def stratDepth : Strat A Y → ℕ
  | .stop _ => 0
  | .obs f => 1 + (univ : Finset Y).sup (fun y => stratDepth (f y))

/-- Predictiva del símbolo `y` bajo la creencia `b`. -/
def mPred (b : Θ → ℝ) (y : Y) : ℝ := ∑ θ, b θ * q θ y

/-- Actualización posterior; cuando la predictiva es cero, posterior
arbitrario (0), sin efecto sobre las esperanzas, como declara el libro. -/
noncomputable def post (b : Θ → ℝ) (y : Y) : Θ → ℝ :=
  fun θ => if mPred q b y = 0 then 0 else b θ * q θ y / mPred q b y

/-- Pérdida esperada de decidir `a` bajo la creencia `b`. -/
def ell (b : Θ → ℝ) (a : A) : ℝ := ∑ θ, b θ * L θ a

/-- Riesgo de detenerse: mínimo de la pérdida esperada sobre acciones. -/
private def wStop (b : Θ → ℝ) : ℝ :=
  (univ : Finset A).inf' Finset.univ_nonempty (ell L b)

/-- Recursión de programación dinámica del teorema. -/
private noncomputable def W : ℕ → (Θ → ℝ) → ℝ
  | 0, b => wStop L b
  | (k + 1), b => min (wStop L b) (c + ∑ y, mPred q b y * W k (post q b y))

/-- Riesgo de una estrategia bajo la creencia de entrada `b`. -/
private noncomputable def riskOf : Strat A Y → (Θ → ℝ) → ℝ
  | .stop a, b => ell L b a
  | .obs f, b => c + ∑ y, mPred q b y * riskOf (f y) (post q b y)

private theorem mPred_nonneg (hq : ∀ θ y, 0 ≤ q θ y) {b : Θ → ℝ}
    (hb : ∀ θ, 0 ≤ b θ) (y : Y) : 0 ≤ mPred q b y :=
  Finset.sum_nonneg fun θ _ => mul_nonneg (hb θ) (hq θ y)

private theorem post_nonneg (hq : ∀ θ y, 0 ≤ q θ y) {b : Θ → ℝ}
    (hb : ∀ θ, 0 ≤ b θ) (y : Y) : ∀ θ, 0 ≤ post q b y θ := by
  intro θ
  by_cases h0 : mPred q b y = 0
  · simp [post, h0]
  · rw [post, if_neg h0]
    exact div_nonneg (mul_nonneg (hb θ) (hq θ y)) (mPred_nonneg q hq hb y)

/-- book: capitulos/cap05_incrustacion.typ:92 (key: thm:ch9-secuencial) —
cota inferior: ninguna estrategia de profundidad a lo sumo `k` mejora la
recursión `W`. Es la mitad «cualquier estrategia» del teorema; la otra es
`ch9_secuencial_alcanza`. Fidelidad declarada: espacios finitos;
likelihoods y creencias no negativas (la normalización no interviene en
las identidades); horizonte finito.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch9_secuencial_cota (hq : ∀ θ y, 0 ≤ q θ y) :
    ∀ (k : ℕ) (b : Θ → ℝ), (∀ θ, 0 ≤ b θ) →
      ∀ σ : Strat A Y, stratDepth σ ≤ k →
        W q L c k b ≤ riskOf q L c σ b := by
  intro k
  induction k with
  | zero =>
      intro b hb σ hσ
      cases σ with
      | stop a =>
          exact Finset.inf'_le (ell L b) (Finset.mem_univ a)
      | obs f =>
          exfalso
          have h1 : stratDepth (Strat.obs f)
              = 1 + (univ : Finset Y).sup (fun y => stratDepth (f y)) := rfl
          omega
  | succ k ih =>
      intro b hb σ hσ
      cases σ with
      | stop a =>
          have h1 : W q L c (k + 1) b ≤ wStop L b := min_le_left _ _
          have h2 : wStop L b ≤ ell L b a := Finset.inf'_le (ell L b) (Finset.mem_univ a)
          exact le_trans (le_trans h1 h2) (by
            show ell L b a ≤ ell L b a
            rfl)
      | obs f =>
          have hdep : ∀ y : Y, stratDepth (f y) ≤ k := by
            intro y
            have h1 : stratDepth (Strat.obs f)
                = 1 + (univ : Finset Y).sup (fun y => stratDepth (f y)) := rfl
            have h2 : (univ : Finset Y).sup (fun y => stratDepth (f y)) ≤ k := by
              have hx := hσ
              rw [h1] at hx
              omega
            exact le_trans
              (Finset.le_sup (f := fun y' => stratDepth (f y')) (Finset.mem_univ y)) h2
          have hstep : ∀ y : Y,
              W q L c k (post q b y) ≤ riskOf q L c (f y) (post q b y) :=
            fun y => ih (post q b y) (post_nonneg q hq hb y) (f y) (hdep y)
          have hmono : ∑ y, mPred q b y * W q L c k (post q b y)
              ≤ ∑ y, mPred q b y * riskOf q L c (f y) (post q b y) :=
            Finset.sum_le_sum fun y _ =>
              mul_le_mul_of_nonneg_left (hstep y) (mPred_nonneg q hq hb y)
          calc W q L c (k + 1) b
              ≤ c + ∑ y, mPred q b y * W q L c k (post q b y) := min_le_right _ _
            _ ≤ c + ∑ y, mPred q b y * riskOf q L c (f y) (post q b y) :=
                add_le_add (le_refl c) hmono
            _ = riskOf q L c (Strat.obs f) b := rfl

/-- book: capitulos/cap05_incrustacion.typ:92 (key: thm:ch9-secuencial) —
existencia: para cada `(k, b)` hay una estrategia de profundidad a lo sumo
`k` que alcanza la recursión `W` (el mínimo de decidir vs observar, con
desempate fijo en la parada). Junto con `ch9_secuencial_cota` da el
enunciado del libro: el mínimo sobre estrategias es la recursión y una
estrategia óptima depende solo de `(k, b)`.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch9_secuencial_alcanza (hq : ∀ θ y, 0 ≤ q θ y) :
    ∀ (k : ℕ) (b : Θ → ℝ), (∀ θ, 0 ≤ b θ) →
      ∃ σ : Strat A Y, stratDepth σ ≤ k ∧ riskOf q L c σ b = W q L c k b := by
  intro k
  induction k with
  | zero =>
      intro b hb
      obtain ⟨a₀, -, ha₀⟩ :=
        Finset.exists_min_image (univ : Finset A) (ell L b) Finset.univ_nonempty
      have hmin : ell L b a₀ = wStop L b :=
        le_antisymm
          ((Finset.le_inf'_iff Finset.univ_nonempty (ell L b)).mpr
            fun a _ => ha₀ a (Finset.mem_univ a))
          (Finset.inf'_le (ell L b) (Finset.mem_univ a₀))
      exact ⟨Strat.stop a₀, le_refl 0, by
        show ell L b a₀ = wStop L b
        exact hmin⟩
  | succ k ih =>
      intro b hb
      by_cases h : c + ∑ y, mPred q b y * W q L c k (post q b y) ≤ wStop L b
      · have hmin : W q L c (k + 1) b
            = c + ∑ y, mPred q b y * W q L c k (post q b y) := min_eq_right h
        choose f hfdep hfval using
          fun y : Y => ih (post q b y) (post_nonneg q hq hb y)
        refine ⟨Strat.obs f, ?_, ?_⟩
        · have h1 : stratDepth (Strat.obs f)
              = 1 + (univ : Finset Y).sup (fun y => stratDepth (f y)) := rfl
          have h2 : (univ : Finset Y).sup (fun y => stratDepth (f y)) ≤ k :=
            Finset.sup_le fun y _ => hfdep y
          calc stratDepth (Strat.obs f)
              = 1 + (univ : Finset Y).sup (fun y => stratDepth (f y)) := h1
            _ ≤ 1 + k := Nat.add_le_add_left h2 1
            _ ≤ k + 1 := by omega
        · show c + ∑ y, mPred q b y * riskOf q L c (f y) (post q b y)
              = W q L c (k + 1) b
          rw [hmin]
          exact congrArg (fun X => c + X)
            (Finset.sum_congr rfl fun y _ => by rw [hfval y])
      · have hle : wStop L b
            ≤ c + ∑ y, mPred q b y * W q L c k (post q b y) :=
          (not_le.mp h).le
        have hmin : W q L c (k + 1) b = wStop L b := min_eq_left hle
        obtain ⟨a₀, -, ha₀⟩ :=
          Finset.exists_min_image (univ : Finset A) (ell L b) Finset.univ_nonempty
        have hmin' : ell L b a₀ = wStop L b :=
          le_antisymm
            ((Finset.le_inf'_iff Finset.univ_nonempty (ell L b)).mpr
              fun a _ => ha₀ a (Finset.mem_univ a))
            (Finset.inf'_le (ell L b) (Finset.mem_univ a₀))
        exact ⟨Strat.stop a₀, le_trans (Nat.zero_le _) (Nat.le_succ k), by
          show ell L b a₀ = W q L c (k + 1) b
          rw [hmin]
          exact hmin'⟩

private theorem neg_min_eq_max_neg (x y : ℝ) : -(min x y) = max (-x) (-y) := by
  rcases le_total x y with h | h
  · rw [min_eq_left h, max_eq_left (neg_le_neg h)]
  · rw [min_eq_right h, max_eq_right (neg_le_neg h)]

/-- book: capitulos/cap05_incrustacion.typ:104 (key: cor:ch9-bellman) —
Bellman para el retorno bayesiano: con `U_k(b) = -W_k(b)`, la recursión se
vuelve el máximo entre detenerse (retorno `-ℓ`) y observar (recompensa
`-c` más el retorno esperado del posterior). Se obtiene cambiando el
signo en la recursión de `thm:ch9-secuencial`, como en el libro.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch9_bellman (b : Θ → ℝ) :
    (-(W q L c 0 b) = (univ : Finset A).sup' Finset.univ_nonempty
        (fun a => -(ell L b a)))
    ∧ (∀ k : ℕ, -(W q L c (k + 1) b) = max (-(W q L c 0 b))
        (-c + ∑ y, mPred q b y * (-(W q L c k (post q b y))))) := by
  constructor
  · show -(wStop L b) = (univ : Finset A).sup' Finset.univ_nonempty
        (fun a => -(ell L b a))
    rw [wStop]
    exact (sup'_neg_eq_neg_inf' Finset.univ_nonempty (ell L b)).symm
  · intro k
    show -(min (wStop L b) (c + ∑ y, mPred q b y * W q L c k (post q b y)))
        = max (-(wStop L b))
            (-c + ∑ y, mPred q b y * (-(W q L c k (post q b y))))
    rw [neg_min_eq_max_neg]
    congr 1
    have e : ∑ y, mPred q b y * (-(W q L c k (post q b y)))
        = -(∑ y, mPred q b y * W q L c k (post q b y)) := by
      rw [← Finset.sum_neg_distrib]
      exact Finset.sum_congr rfl fun y _ => mul_neg _ _
    rw [e, neg_add]

end Secuencial