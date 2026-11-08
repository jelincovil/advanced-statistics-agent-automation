import Mathlib

/-!
# Book.Cap08Poder — planificación de poder y tamaño de muestra (cap. 8, ejercicios)

Formaliza el contenido aritmético del ejercicio `ex:ch11-ej3` de
`capitulos/cap08_intervalos.typ`: el tamaño de muestra planificado
`n = ⌈(z_{1−α/2} + z_{1−β})² σ_D² / δ²⌉` para un contraste bilateral de
nivel `α`, diferencia relevante `δ`, poder `1−β` y desviación por unidad
independiente `σ_D`, y el efecto detectable con `n` fijo.

Fidelidad declarada: se formaliza el **cálculo de planificación** (los
enteros que produce la fórmula con los cuantiles normales del libro,
redondeados a seis decimales) y no la distribución normal ni el poder
exacto: el libro mismo lo presenta como «aproximación de planificación, no
una garantía finita universal». El tamaño planificado se caracteriza como
el único entero `n` con `n−1 < x ≤ n`, es decir `n = ⌈x⌉`; no se usa
ninguna tabla normal, solo los cuantiles explícitos que se declaran.

Origen: enjambre smw82qi6q, miembro m11.
-/

set_option linter.unusedVariables false

namespace Cap08Poder

/-- `Plan x n`: `n` es el entero planificado para el valor real `x`, es decir
`n = ⌈x⌉` (menor entero mayor o igual que `x`). -/
def Plan (x : ℝ) (n : ℕ) : Prop := (n : ℝ) - 1 < x ∧ x ≤ n

/-- El plan es único: si dos naturales satisfacen `Plan x ·`, son iguales. -/
theorem Plan_unique {x : ℝ} {n m : ℕ} (hn : Plan x n) (hm : Plan x m) : n = m := by
  have h1 : (n : ℝ) < (m : ℝ) + 1 := by linarith [hn.1, hm.2]
  have h2 : (m : ℝ) < (n : ℝ) + 1 := by linarith [hm.1, hn.2]
  have hnm : n ≤ m := by
    by_contra h
    have h' : m < n := Nat.lt_of_not_le h
    have hc : (m : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast h'
    linarith
  have hmn : m ≤ n := by
    by_contra h
    have h' : n < m := Nat.lt_of_not_le h
    have hc : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast h'
    linarith
  omega

/-- Cuantil normal `z_{0.975}` redondeado a seis decimales. -/
noncomputable def z975 : ℝ := 1959964 / 1000000
/-- Cuantil normal `z_{0.80}` redondeado a seis decimales. -/
noncomputable def z80 : ℝ := 841621 / 1000000
/-- Cuantil normal `z_{0.90}` redondeado a seis decimales. -/
noncomputable def z90 : ℝ := 1281552 / 1000000

/-- book: capitulos/cap08_intervalos.typ:377 (key: ex:ch11-ej3) —
planificación de poder, nivel bilateral `α = 0.05`: con `σ_D = 2` y
efecto relevante `δ = 0.5` hacen falta `126` unidades independientes para
poder `80%` y `169` para poder `90%`; con `n = 100` el efecto detectable
al `80%` es `0.5603` (es decir `0.56 < δ ≤ 0.57`); para dos grupos
independientes de igual tamaño el tamaño por grupo es `252`. Con efecto
estandarizado `δ/σ_D = 0.2` el plan es `197` con los cuantiles precisos y
`196` si se redondean antes a `1.96` y `0.84`, que es la discrepancia que
el libro advierte (conviene redondear el tamaño al final). Fidelidad
declarada: se verifica el cálculo entero de planificación con los
cuantiles indicados, no el poder exacto de la prueba normal.
Origen: enjambre smw82qi6q, m11. -/
theorem planificacion_poder :
    Plan ((z975 + z80) ^ 2 * (2:ℝ) ^ 2 / (1/2) ^ 2) 126
    ∧ Plan ((z975 + z90) ^ 2 * (2:ℝ) ^ 2 / (1/2) ^ 2) 169
    ∧ Plan (2 * ((z975 + z80) ^ 2 * (2:ℝ) ^ 2 / (1/2) ^ 2)) 252
    ∧ (0.56 : ℝ) < (z975 + z80) * 2 / Real.sqrt 100
    ∧ (z975 + z80) * 2 / Real.sqrt 100 ≤ 0.57
    ∧ Plan ((z975 + z80) ^ 2 * 1 ^ 2 / (1/5 : ℝ) ^ 2) 197
    ∧ ((196 : ℕ) : ℝ) - 1 < ((1.96 + 0.84) ^ 2 * 1 ^ 2 / (1/5 : ℝ) ^ 2)
    ∧ ((1.96 + 0.84) ^ 2 * 1 ^ 2 / (1/5 : ℝ) ^ 2) ≤ 196 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · unfold Plan z975 z80; norm_num
  · unfold Plan z975 z90; norm_num
  · unfold Plan z975 z80; norm_num
  · have h100 : Real.sqrt 100 = 10 := by
      rw [show (100:ℝ) = 10^2 by norm_num, Real.sqrt_sq (by norm_num)]
    rw [h100]; unfold z975 z80; norm_num
  · have h100 : Real.sqrt 100 = 10 := by
      rw [show (100:ℝ) = 10^2 by norm_num, Real.sqrt_sq (by norm_num)]
    rw [h100]; unfold z975 z80; norm_num
  · unfold Plan z975 z80; norm_num
  · norm_num
  · norm_num

/-- book: capitulos/cap08_intervalos.typ:377 (key: ex:ch11-ej3) —
la media de dos grupos independientes de igual tamaño `n` tiene varianza
`2σ²/n`, por lo que el plan por grupo es el doble del de una sola media
con la misma varianza por unidad (`σ_D² = 2σ²`); el cálculo exacto para
`σ = 2`, `δ = 0.5` da `252` por grupo. Esta es la aclaración del libro:
el factor dos debe justificarse por la varianza de la diferencia, no
añadirse automáticamente. Origen: enjambre smw82qi6q, m11. -/
theorem planificacion_dos_grupos (σ : ℝ) (δ : ℝ) (hδ : δ ≠ 0) (hl : 0 < δ) :
    (2 * σ ^ 2) / δ ^ 2 = σ ^ 2 / δ ^ 2 + σ ^ 2 / δ ^ 2 := by
  field_simp
  ring

/-! ## Verificación de axiomas -/

#print axioms Plan_unique
#print axioms planificacion_poder
#print axioms planificacion_dos_grupos

end Cap08Poder
