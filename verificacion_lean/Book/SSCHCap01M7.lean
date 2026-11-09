import Mathlib

/-!
# Book.SSCHCap01M7 — `ex:ssch-cap01`: el MDP clínico como modelo paramétrico

Formaliza el ejemplo `ex:ssch-cap01` de `capitulos/cap10_casos.typ:36`
(enjambre `smw9820kx`, dirección `d7`).

El ejemplo define el SSCH tabular: cinco estados `s₁,…,s₅`, cuatro acciones
`a₁,…,a₄`, `γ = 0.9` y horizonte descontado infinito, con la dinámica
sintética

  `w_{s,a,j} = exp(−|j − (s + d_a)|/0.7)`,
  `P_{s,a,j} = 0.98 · w_{s,a,j} / Σ_u w_{s,a,u} + 0.02/5`,  `d = (0.45, 0, −0.45, −0.8)`,

y la tabla de recompensas `tab:ssch-recompensas`. El libro afirma que *cada fila
suma uno*, que *cada entrada es al menos 0.004*, y que con `P` desconocida hay
*cien probabilidades y ochenta parámetros libres en el interior*.

Fidelidad declarada: se formaliza exactamente eso y nada más. Los índices son
`Fin 5` (estados) y `Fin 4` (acciones); las cifras son racionales exactos o
`Real.exp` con argumento racional (nunca flotantes, plan §4). No se formaliza
ninguna estimación: el ejemplo sólo describe el simulador.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHCap01M7

/-! ## La dinámica sintética -/

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — desplazamientos
`d = (0.45, 0, −0.45, −0.8)` de las cuatro acciones abstractas, exactos. -/
noncomputable def drift : Fin 4 → ℝ := ![45 / 100, 0, -(45 / 100), -(8 / 10)]

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — pesos crudos
`w_{s,a,j} = exp(−|j − (s + d_a)| / 0.7)`; `0.7` es exactamente `7/10`. -/
noncomputable def weight (s : Fin 5) (a : Fin 4) (j : Fin 5) : ℝ :=
  Real.exp (-(|(j : ℝ) - ((s : ℝ) + drift a)|) / (7 / 10))

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — fila suavizada
`0.98 · w_j / Σ_u w_u + 0.02/5` (el `0.98` reparte el peso entre los cinco
estados y el `0.02/5` garantiza positividad uniforme). -/
noncomputable def smoothRow (w : Fin 5 → ℝ) (j : Fin 5) : ℝ :=
  98 / 100 * (w j / ∑ u, w u) + (2 / 100) / 5

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — kernel del SSCH
tabular: `P_{s,a,j}` con la elección de diseño del simulador. -/
noncomputable def Pssch (s : Fin 5) (a : Fin 4) (j : Fin 5) : ℝ :=
  smoothRow (weight s a) j

/-! ## «Cada fila suma uno» -/

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — cada fila del
kernel suma uno. Fidelidad: se prueba para cualquier vector de pesos con suma
no nula, que es lo único que usa el reparto `0.98/0.02`. -/
theorem smoothRow_sum {w : Fin 5 → ℝ} (hS : (∑ u, w u) ≠ 0) :
    ∑ j : Fin 5, smoothRow w j = 1 := by
  have e : ∑ j : Fin 5, smoothRow w j
      = 98 / 100 * ((∑ j : Fin 5, w j) / (∑ u, w u))
        + ∑ _j : Fin 5, ((2 / 100 : ℝ) / 5) := by
    simp only [smoothRow, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_div]
  rw [e, div_self hS, mul_one]
  norm_num

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — cada fila del
kernel del simulador suma uno (instanciación en el modelo). -/
theorem Pssch_row_sum (s : Fin 5) (a : Fin 4) : ∑ j : Fin 5, Pssch s a j = 1 := by
  refine smoothRow_sum ?_
  have : 0 < ∑ u : Fin 5, weight s a u :=
    Finset.sum_pos (fun u _ => Real.exp_pos _) Finset.univ_nonempty
  exact ne_of_gt this

/-! ## «Cada entrada es al menos 0.004» -/

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — con pesos no
negativos, cada entrada de la fila suavizada es al menos `0.02/5 = 1/250 =
0.004`. -/
theorem smoothRow_ge {w : Fin 5 → ℝ} (hw : ∀ u, 0 ≤ w u) (hS : (∑ u, w u) ≠ 0)
    (j : Fin 5) : 1 / 250 ≤ smoothRow w j := by
  have hSpos : 0 < ∑ u : Fin 5, w u :=
    lt_of_le_of_ne (Finset.sum_nonneg fun u _ => hw u) (Ne.symm hS)
  have hwj : 0 ≤ w j := hw j
  have hdiv : 0 ≤ w j / (∑ u : Fin 5, w u) := div_nonneg hwj hSpos.le
  have h1 : (0 : ℝ) ≤ 98 / 100 * (w j / ∑ u, w u) := by
    have : (0 : ℝ) ≤ 98 / 100 := by norm_num
    exact mul_nonneg this hdiv
  have h2 : (2 / 100 : ℝ) / 5 = 1 / 250 := by norm_num
  simp only [smoothRow, h2]
  linarith

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — minoración
uniforme del kernel del simulador: toda entrada de toda fila es al menos
`0.004`. Es la propiedad que `ex:ssch-cap05-b` usa después para la minoración
uniforme de cualquier política estacionaria. -/
theorem Pssch_ge (s : Fin 5) (a : Fin 4) (j : Fin 5) : 1 / 250 ≤ Pssch s a j := by
  refine smoothRow_ge (fun u => (Real.exp_pos _).le) ?_ j
  have : 0 < ∑ u : Fin 5, weight s a u :=
    Finset.sum_pos (fun u _ => Real.exp_pos _) Finset.univ_nonempty
  exact ne_of_gt this

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — las entradas son
racionales positivos comparables con `0.004`; en particular `0.004` es
`1/250` y no una cota floja. -/
theorem Pssch_ge_four_thousandths (s : Fin 5) (a : Fin 4) (j : Fin 5) :
    (4 / 1000 : ℝ) ≤ Pssch s a j := by
  have h := Pssch_ge s a j
  have : (4 / 1000 : ℝ) = 1 / 250 := by norm_num
  rw [this]
  exact h

/-! ## La tabla de recompensas `tab:ssch-recompensas` -/

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — recompensas
sintéticas del SSCH tabular, en unidades abstractas: `r s a`, con `s₁ = 0` y
`a₁ = 0` (racionales exactos del cuadro del libro). -/
noncomputable def rSSCH : Fin 5 → Fin 4 → ℝ :=
  ![![1, 9 / 10, 7 / 10, 1 / 2],
    ![1 / 2, 7 / 10, 3 / 5, 2 / 5],
    ![0, 3 / 10, 3 / 5, 1 / 2],
    ![-(1 / 2), 0, 2 / 5, 7 / 10],
    ![-2, -(3 / 2), -(1 / 2), 1 / 5]]

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — en `s₁` la acción
con mayor recompensa es `a₁` (`1.0`), y `0.9 > 0.7 > 0.5`. -/
theorem rSSCH_s1 (a : Fin 4) : rSSCH 0 a ≤ rSSCH 0 0 := by
  have h : ∀ a : Fin 4, rSSCH 0 a ≤ rSSCH 0 0 := by
    intro a
    fin_cases a <;> norm_num [rSSCH]
  exact h a

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — en `s₃` la acción
con mayor recompensa es `a₃` (`0.6`), con `r(s₃,a₃) − r(s₃,a₄) = 1/10`. -/
theorem rSSCH_s3 (a : Fin 4) :
    rSSCH 2 a ≤ rSSCH 2 2 ∧ rSSCH 2 2 - rSSCH 2 3 = 1 / 10 := by
  refine ⟨?_, by norm_num [rSSCH]⟩
  fin_cases a <;> norm_num [rSSCH]

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — en `s₅` la acción
con mayor recompensa es `a₄` (`0.2`); las tres primeras son negativas o nulas
de signo. -/
theorem rSSCH_s5 (a : Fin 4) :
    rSSCH 4 a ≤ rSSCH 4 3 ∧ rSSCH 4 0 = -2 ∧ rSSCH 4 1 = -(3 / 2) := by
  refine ⟨?_, by norm_num [rSSCH], by norm_num [rSSCH]⟩
  fin_cases a <;> norm_num [rSSCH]

/-! ## «Cien probabilidades y ochenta parámetros libres» -/

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — el kernel tiene
`5 · 4 = 20` filas de `5 = |Δ⁴|` entradas: `100` probabilidades. -/
theorem Pssch_card_rows : Fintype.card (Fin 5 × Fin 4) = 20 ∧
    Fintype.card (Fin 5 × Fin 4 × Fin 5) = 100 := by
  simp [Fintype.card_prod]

/-- book: capitulos/cap10_casos.typ:36 (key: ex:ssch-cap01) — en el interior de
`Δ⁴` cada fila tiene `5 − 1 = 4` parámetros libres, luego `20 · 4 = 80`
parámetros libres en total. -/
theorem Pssch_free_params : Fintype.card (Fin 5 × Fin 4) * (5 - 1) = 80 := by
  simp [Fintype.card_prod]

end SSCHCap01M7
