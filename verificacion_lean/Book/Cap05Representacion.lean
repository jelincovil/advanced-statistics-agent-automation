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
