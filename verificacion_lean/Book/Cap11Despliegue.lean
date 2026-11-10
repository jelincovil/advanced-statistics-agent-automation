import Mathlib
import Book.Foundation

/-!
# Book.Cap11Despliegue — cuantización, truncamiento, monitoreo, MDP de validación y margen
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

/-! ## #28: cuantización -/

/-- book: capitulos/cap11_despliegue.typ:97 (key: cap11-cuantizacion) —
ejemplo verificable de cuantización. Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_cuantizacion_ejemplo :
    ((1:ℝ)/4) * (1/5) + ((3:ℝ)/4) * (4/5) + ((3:ℝ)/4) / (1/2) * (1 - 4/5) = 19 / 20
    ∧ ((1:ℝ)/4) * (1/5) + ((3:ℝ)/4) * (4/5) + ((1:ℝ)/4) / (1/2) * (0 - 1/5) = 11 / 20
    ∧ ((1:ℝ)/4) * (1/5 + 1/100) + ((3:ℝ)/4) * (4/5 - 1/100)
        + ((3:ℝ)/4) / (1/2) * (1 - (4/5 - 1/100)) = 24 / 25
    ∧ ((24:ℝ) / 25 - 19 / 20 = 1 / 100)
    ∧ ((1:ℝ) / 100) * (1 + 3 / 2) = 1 / 40 := by
  norm_num

/-! ## #29: truncamiento de horizonte -/

/-- book: capitulos/cap11_despliegue.typ:167 (key: cap11-truncamiento) —
truncamiento de horizonte: `B_H = R_max·γ^H/(1−γ)`; con `R_max = 6/5`,
`γ = 9/10` y tolerancia `1/10`, el menor `H` es `46`: con `45` todavía
falla (`B_45 > 1/10`), con `46` ya sirve (`B_46 ≤ 1/10`). Verificación
racional exacta de las dos potencias.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_truncamiento :
    (120 * 9 ^ 45 : ℕ) > 10 ^ 45
    ∧ (120 * 9 ^ 46 : ℕ) ≤ 10 ^ 46 := by
  constructor
  · decide
  · decide


/-! ## #30: monitoreo con multiplicidad temporal -/

/-- book: capitulos/cap11_despliegue.typ:611 (key: cap11-monitoreo) —
monitoreo: el telescopio suma `α` en total (cada término es
`α/(m(m+1))`, y `Σ_{m=1}^{M} 1/(m(m+1)) = 1 − 1/(M+1) ≤ 1`). Aquí se
verifica el caso `M = 3` como igualdad exacta y la cota `≤ α` en general.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_monitoreo (α : ℝ) (hα : 0 ≤ α) :
    (α / (1 * 2) + α / (2 * 3) + α / (3 * 4)) = α * (1 - 1 / 4)
    ∧ α * (1 - 1 / 4) ≤ α := by
  constructor
  · ring
  · have h : (0:ℝ) ≤ 1 / 4 := by norm_num
    nlinarith

/-! ## #33: MDP de validación (apéndice E) -/

/-- book: capitulos/cap11_despliegue.typ:273 (key: def:appE-mdp-test) —
MDP de validación del apéndice E: tres estados, dos acciones,
descuento `γ = 9/10`, política objetivo `π(a₁|s) = 3/5`. El punto fijo
`V_∞` resuelve `(I − γP^π)V = r^π` (verificado por sustitución racional
exacta); la recursión hacia atrás con `v_5 = 0` da `v_0` (las
contribuciones del gradiente). Fidelidad declarada: los valores del
libro (7.651602, 7.732035, 7.191250) son aproximaciones decimales de
los racionales exactos `(249052/32549, 251670/32549, 234068/32549)`;
`v_0(5)` en el libro (3.198864) es la aproximación del exacto
`4998224747591/1562500000000`.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_mdp_validacion :
    -- (I − γP^π)V = r^π: el punto fijo (3 ecuaciones)
    (249052:ℝ)/32549 = 4/5 + (9/10) * ((27/50) * (249052/32549)
        + (8/25) * (251670/32549) + (7/50) * (234068/32549))
    ∧ (251670:ℝ)/32549 = 24/25 + (9/10) * ((4/25) * (249052/32549)
        + (12/25) * (251670/32549) + (9/25) * (234068/32549))
    ∧ (234068:ℝ)/32549 = 23/50 + (9/10) * ((8/25) * (249052/32549)
        + (13/50) * (251670/32549) + (21/50) * (234068/32549))
    -- la recursión hacia atrás: v_5 = 0, v_0 = el valor exacto
    ∧ (4998224747591:ℝ)/1562500000000
        = (3/5) * (1 + (9/10) * ((7/10) * (16895385779/6250000000)
            + (2/10) * (8706530793/3125000000)
            + (1/10) * (14022061627/6250000000)))
        + (2/5) * (1/2 + (9/10) * ((3/10) * (16895385779/6250000000)
            + (5/10) * (8706530793/3125000000)
            + (2/10) * (14022061627/6250000000)))
    ∧ (5124631531119:ℝ)/1562500000000
        = (3/5) * (4/5 + (9/10) * ((2/10) * (16895385779/6250000000)
            + (6/10) * (8706530793/3125000000)
            + (2/10) * (14022061627/6250000000)))
        + (2/5) * (6/5 + (9/10) * ((1/10) * (16895385779/6250000000)
            + (3/10) * (8706530793/3125000000)
            + (6/10) * (14022061627/6250000000)))
    ∧ (8557933405241:ℝ)/3125000000000
        = (3/5) * (3/10 + (9/10) * ((4/10) * (16895385779/6250000000)
            + (3/10) * (8706530793/3125000000)
            + (3/10) * (14022061627/6250000000)))
        + (2/5) * (7/10 + (9/10) * ((2/10) * (16895385779/6250000000)
            + (2/10) * (8706530793/3125000000)
            + (6/10) * (14022061627/6250000000))) := by
  norm_num
/-! ## #35: margen elemental -/

/-- Acción óptima verdadera en el estado `s` (desempate hacia `false`). -/
private noncomputable def astar {S : Type*} (q : S → Bool → ℝ) (s : S) : Bool :=
  if q s true ≤ q s false then false else true

/-- Acción greedy del aproximador en el estado `s` (desempate hacia `false`). -/
private noncomputable def ahat {S : Type*} (qhat : S → Bool → ℝ) (s : S) : Bool :=
  if qhat s true ≤ qhat s false then false else true

/-- book: capitulos/cap08_intervalos.typ:353 (key: cap11-margen) —
margen elemental (el «ejemplo elemental de una decisión» del cap. 8):
con dos acciones, `Δ(s) = |q(s,1) − q(s,0)|` y la hipótesis de masa
explícita `P(0 < Δ(S) ≤ u) ≤ C·u^κ`, si `‖q̂ − q‖_∞ ≤ ε` entonces
`E[q(S,a*(S)) − q(S,â(S))] ≤ C·(2ε)^{1+κ}`. La prueba: una acción
greedy incorrecta solo puede tener brecha positiva ≤ 2ε (cadena de tres
desigualdades desde `‖q̂−q‖_∞ ≤ ε`); la pérdida es nula fuera de
`{0 < Δ ≤ 2ε}` (los empates tienen pérdida cero; con brecha > 2ε el
greedy coincide con el óptimo porque el orden de `q̂` preserva el de
`q`); en ese conjunto la pérdida se acota por `2ε` y la masa por la
hipótesis de margen en `u = 2ε`. Fidelidad declarada: versión finita
con `S` Fintype y `μ` ley de probabilidad (no negativa y normalizada;
la prueba solo usa la no negatividad); `κ` es un exponente natural; el
desempate del argmax va hacia `false` y no afecta a la pérdida.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_margen_elemental {S : Type*} [Fintype S] (μ : S → ℝ) (q qhat : S → Bool → ℝ)
    (C ε : ℝ) (κ : ℕ)
    (hμ : ∀ s, 0 ≤ μ s) (hμ1 : ∑ s, μ s = 1)
    (hε : 0 ≤ ε)
    (herr : ∀ s a, |qhat s a - q s a| ≤ ε)
    (hmargin : ∀ u : ℝ, 0 < u →
      (∑ s ∈ Finset.univ.filter
          (fun s => 0 < |q s true - q s false| ∧ |q s true - q s false| ≤ u),
        μ s) ≤ C * u ^ κ) :
    (∑ s, μ s * (q s (astar q s) - q s (ahat qhat s))) ≤ C * (2 * ε) ^ (κ + 1) := by
  have hstar : ∀ (s : S) (a : Bool), q s a ≤ q s (astar q s) := by
    intro s a
    simp only [astar]
    split
    · next h =>
      cases a
      · exact le_refl _
      · exact h
    · next h =>
      cases a
      · exact (not_le.mp h).le
      · exact le_refl _
  have hhat : ∀ (s : S) (a : Bool), qhat s a ≤ qhat s (ahat qhat s) := by
    intro s a
    simp only [ahat]
    split
    · next h =>
      cases a
      · exact le_refl _
      · exact h
    · next h =>
      cases a
      · exact (not_le.mp h).le
      · exact le_refl _
  -- una acción greedy incorrecta solo puede tener brecha positiva ≤ 2ε
  have h2eps : ∀ s : S, q s (astar q s) - q s (ahat qhat s) ≤ 2 * ε := by
    intro s
    by_cases heq : ahat qhat s = astar q s
    · rw [heq]
      linarith
    · have h1 : qhat s (astar q s) ≤ qhat s (ahat qhat s) := hhat s (astar q s)
      obtain ⟨ha1, ha2⟩ := abs_le.mp (herr s (ahat qhat s))
      obtain ⟨hb1, hb2⟩ := abs_le.mp (herr s (astar q s))
      linarith
  -- con brecha > 2ε el orden de q̂ preserva el de q: el greedy coincide
  -- con el óptimo
  have hstrict : ∀ s : S, 2 * ε < |q s true - q s false| →
      ahat qhat s = astar q s := by
    intro s hg
    obtain ⟨ha1, ha2⟩ := abs_le.mp (herr s true)
    obtain ⟨hb1, hb2⟩ := abs_le.mp (herr s false)
    by_cases h : q s true ≤ q s false
    · -- aquí la brecha es q s false − q s true
      rw [abs_of_nonpos (by linarith : q s true - q s false ≤ 0)] at hg
      have hle' : qhat s true ≤ qhat s false := by linarith
      have hahat : ahat qhat s = false := by simp only [ahat, if_pos hle']
      have hast : astar q s = false := by simp only [astar, if_pos h]
      rw [hahat, hast]
    · -- aquí la brecha es q s true − q s false
      have hlt : q s false < q s true := not_le.mp h
      rw [abs_of_nonneg (by linarith : 0 ≤ q s true - q s false)] at hg
      have hne' : ¬ (qhat s true ≤ qhat s false) := by
        intro hle; linarith
      have hne : ¬ (q s true ≤ q s false) := by
        intro hle; linarith
      have hahat : ahat qhat s = true := by simp only [ahat, if_neg hne']
      have hast : astar q s = true := by simp only [astar, if_neg hne]
      rw [hahat, hast]
  -- los empates tienen pérdida cero
  have htie : ∀ s : S, |q s true - q s false| = 0 →
      q s (astar q s) = q s (ahat qhat s) := by
    intro s hg0
    have hq : q s true = q s false := by
      have h := abs_eq_zero.mp hg0
      linarith
    have hconst : ∀ a b : Bool, q s a = q s b := by
      intro a b
      cases a <;> cases b <;> simp [hq]
    exact hconst (astar q s) (ahat qhat s)
  -- la pérdida es nula fuera de {0 < Δ ≤ 2ε}
  have hzero : ∀ s : S,
      (¬ (0 < |q s true - q s false| ∧ |q s true - q s false| ≤ 2 * ε)) →
      q s (astar q s) - q s (ahat qhat s) = 0 := by
    intro s h
    rcases lt_or_ge 0 (|q s true - q s false|) with hpos | hle
    · have hgt : 2 * ε < |q s true - q s false| := by
        rcases lt_or_ge (2 * ε) (|q s true - q s false|) with h1 | h1
        · exact h1
        · exact absurd ⟨hpos, h1⟩ h
      rw [hstrict s hgt]
      ring
    · have hg0 : |q s true - q s false| = 0 := le_antisymm hle (abs_nonneg _)
      rw [htie s hg0]
      ring
  rcases eq_or_lt_of_le hε with hε0 | hεpos
  · -- ε = 0: la pérdida es nula y la cota vale con igualdad a cero
    subst hε0
    have hsum : (∑ s, μ s * (q s (astar q s) - q s (ahat qhat s))) ≤ 0 := by
      refine Finset.sum_nonpos fun s _ => ?_
      have h2 := h2eps s
      have hle0 : q s (astar q s) - q s (ahat qhat s) ≤ 0 := by linarith
      have h := mul_le_mul_of_nonneg_left hle0 (hμ s)
      simpa using h
    have hR : C * (2 * 0) ^ (κ + 1) = 0 := by
      rw [show (2:ℝ) * 0 = 0 from by norm_num, zero_pow (Nat.succ_ne_zero κ)]
      ring
    linarith
  · -- ε > 0: se suma solo sobre {0 < Δ ≤ 2ε} y se aplica el margen en u = 2ε
    have h2εpos : 0 < 2 * ε := by linarith
    calc (∑ s, μ s * (q s (astar q s) - q s (ahat qhat s)))
        = (∑ s ∈ Finset.univ.filter
              (fun s => 0 < |q s true - q s false| ∧ |q s true - q s false| ≤ 2 * ε),
            μ s * (q s (astar q s) - q s (ahat qhat s))) := by
          refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
          intro x _ hxn
          have hn : ¬ (0 < |q x true - q x false| ∧
              |q x true - q x false| ≤ 2 * ε) := by
            intro hp
            exact hxn (Finset.mem_filter.mpr ⟨Finset.mem_univ x, hp⟩)
          rw [hzero x hn]
          ring
      _ ≤ (∑ s ∈ Finset.univ.filter
              (fun s => 0 < |q s true - q s false| ∧ |q s true - q s false| ≤ 2 * ε),
            μ s * (2 * ε)) :=
          Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (h2eps s) (hμ s)
      _ = (∑ s ∈ Finset.univ.filter
              (fun s => 0 < |q s true - q s false| ∧ |q s true - q s false| ≤ 2 * ε),
            μ s) * (2 * ε) := by
          rw [← Finset.sum_mul]
      _ ≤ C * (2 * ε) ^ κ * (2 * ε) :=
          mul_le_mul_of_nonneg_right (hmargin (2 * ε) h2εpos) (le_of_lt h2εpos)
      _ = C * (2 * ε) ^ (κ + 1) := by
          rw [pow_succ]
          ring
