import Mathlib

/-!
# Book.M13Mcmc — MCMC e inferencia variacional en el SSCH (m13, enjambre smw9820kx)

Claves pendientes del kernel que cierra este módulo:

* `ex:ssch-mcmc-vi-cap03` (`capitulos/cap04_herramientas.typ:1151`) — referencia
  conjugada exacta del SSCH: conteos sintéticos `(2,5,3)` con prior
  `Dirichlet(1,1,1)` dan posterior `Dirichlet(3,6,4)`, medias
  `(3/13, 6/13, 4/13)`, varianza de la segunda probabilidad `3/169`; la
  Dirichlet **no** factoriza en coordenadas independientes (suman uno); y el
  mínimo global de la divergencia KL sobre la familia variacional de todas las
  Dirichlet es cero, alcanzado en el posterior exacto.
* `ex:ch3-mcmc-ssch` (`capitulos/cap04_herramientas.typ:1181`) — paso de
  Metropolis–Hastings con prior logístico-normal no conjugado: la
  parametrización logit `θ_j = e^{z_j}/(1+e^{z_1}+e^{z_2})` vive en el simplex,
  la log-densidad no normalizada es
  `ℓ(z) = 2z_1 + 5z_2 − 10 log(1+e^{z_1}+e^{z_2}) − ‖z‖²/2`,
  y para `z = (0,0)`, `z' = (0,0.1)` la diferencia vale exactamente
  `99/200 − 10 log((2+e^{1/10})/3)`, que es positiva, de modo que la
  probabilidad de aceptación vale uno.

Soporte de ambos ejemplos (`def:ch3-mh`, cerrada): la regla de aceptación de
Metropolis–Hastings `min(1, π(y)q(y|x)/(π(x)q(x|y)))` toma valores en `[0,1]`,
con propuesta simétrica se reduce a `min(1, π(y)/π(x))`, satisface el balance
detallado y —devolviendo la masa de rechazo al estado actual— el núcleo
resultante deja `π` invariante (distribución estacionaria).

Convenciones del proyecto: 0 `sorry`, `#print axioms` ⊆
{propext, Classical.choice, Quot.sound} (`Book/M13McmcAudit.lean`), trazabilidad
`book: capitulos/<file>.typ:<line> (key: <clave>)` y fidelidad declarada en cada
declaración. Fidelidad global: los cálculos son exactos sobre `ℝ`; no se
formaliza la teoría de medida de las densidades Dirichlet sobre el simplex
(se trabaja con el núcleo no normalizado y con sus momentos declarados en el
libro), ni la ergodicidad/convergencia de la cadena, ni se verifican decimales
de ESS o diagnósticos no ejecutados en la fuente.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

namespace Book.M13

/-! ## Parte A — `ex:ssch-mcmc-vi-cap03`: referencia conjugada del SSCH -/

/-- Conteos sintéticos `(2,5,3)` del ejemplo (la fuente los declara
sintéticos: no son datos clínicos). -/
def cntD : Fin 3 → ℝ := ![2, 5, 3]

/-- Prior `Dirichlet(1,1,1)`: uniforme sobre el 2-simplex. -/
def aPri : Fin 3 → ℝ := ![1, 1, 1]

/-- Parámetros del posterior: `a = prior + conteos` (conjugación
Dirichlet–multinomial). -/
def aPos : Fin 3 → ℝ := fun j => aPri j + cntD j

/-- Parámetro total `a₀ = ∑_j a_j`. -/
def aTot (a : Fin 3 → ℝ) : ℝ := ∑ j, a j

/-- Media de la Dirichlet en la coordenada `j`: `a_j / a₀`. -/
noncomputable def dMean (a : Fin 3 → ℝ) (j : Fin 3) : ℝ := a j / aTot a

/-- Varianza de la coordenada `j` de una Dirichlet: `a_j (a₀ − a_j) / (a₀² (a₀ + 1))`. -/
noncomputable def dVar (a : Fin 3 → ℝ) (j : Fin 3) : ℝ :=
  a j * (aTot a - a j) / (aTot a ^ 2 * (aTot a + 1))

/-- Divergencia KL entre dos pesos sobre `Fin 3`: `∑_j p_j log(p_j / q_j)`. -/
noncomputable def dKl (p q : Fin 3 → ℝ) : ℝ := ∑ j, p j * Real.log (p j / q j)

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
conjugación con los conteos `(2,5,3)` y prior `(1,1,1)`: el posterior es
`Dirichlet(3,6,4)`.

Fidelidad: solo los parámetros; la forma cerrada de la densidad Dirichlet no se
reconstruye (el libro da el posterior y sus momentos, que es lo que se usa). -/
theorem posterior_parametros : aPos 0 = 3 ∧ aPos 1 = 6 ∧ aPos 2 = 4 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [aPos, aPri, cntD]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
parámetro total del posterior: `a₀ = 3 + 6 + 4 = 13`. -/
theorem posterior_total : aTot aPos = 13 := by
  rw [aTot, Fin.sum_univ_three]
  norm_num [aPos, aPri, cntD]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
parámetro total del prior: `a₀ = 1 + 1 + 1 = 3`. -/
theorem prior_total : aTot aPri = 3 := by
  rw [aTot, Fin.sum_univ_three]
  norm_num [aPri]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
medias del posterior: `(3/13, 6/13, 4/13)`.

Fidelidad: la media de la Dirichlet es `a_j/a₀` (momento declarado en el libro);
se verifica la aritmética, no la integral que define el momento. -/
theorem posterior_media :
    dMean aPos 0 = 3 / 13 ∧ dMean aPos 1 = 6 / 13 ∧ dMean aPos 2 = 4 / 13 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [dMean, posterior_total] <;> norm_num [posterior_parametros]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
las tres medias del posterior suman uno (es una probabilidad sobre tres
destinos). -/
theorem posterior_media_suma : ∑ j, dMean aPos j = 1 := by
  simp only [dMean, posterior_total]
  rw [← Finset.sum_div, show ∑ j, aPos j = 13 from posterior_total]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
prior uniforme sobre el simplex: las tres medias del prior valen `1/3`. -/
theorem prior_uniforme :
    dMean aPri 0 = 1 / 3 ∧ dMean aPri 1 = 1 / 3 ∧ dMean aPri 2 = 1 / 3 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [dMean, prior_total] <;> norm_num [aPri]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
varianza de la segunda probabilidad con la fórmula de la Dirichlet:
`6·(13−6)/(13²·14) = 3/169` (la fórmula del libro) y, por `dVar`, también
`Var(θ₂) = 3/169`.

Fidelidad: se verifica la aritmética de la fórmula declarada; la identidad
`Var = a_j(a₀−a_j)/(a₀²(a₀+1))` se toma como declaración del libro (momento de
la Dirichlet), no se integra la densidad. -/
theorem posterior_varianza_segunda :
    (6 : ℝ) * (13 - 6) / (13 ^ 2 * (13 + 1)) = 3 / 169 ∧ dVar aPos 1 = 3 / 169 := by
  constructor
  · norm_num
  · rw [dVar, posterior_total]
    norm_num [posterior_parametros]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
**la Dirichlet no factoriza en coordenadas independientes**. El núcleo de la
densidad `Dirichlet(3,6,4)` en las dos primeras coordenadas del simplex es
`x² y⁵ (1−x−y)³`; no existen `g, h` con
`x² y⁵ (1−x−y)³ = g(x)·h(y)` sobre el simplex abierto. Esto es exactamente lo
que el libro señala con «suman uno»: las coordenadas de una Dirichlet no son
independientes, de modo que la familia variacional de Dirichlet no es la familia
mean-field.

Prueba: si factorizara, el determinante multiplicativo
`F(a,c)F(b,d) − F(a,d)F(b,c)` se anularía; en `(1/6,1/6)`, `(1/3,1/3)`,
`(1/6,1/3)`, `(1/3,1/6)` vale `8/729 − 1/64 ≠ 0`.

Fidelidad: se refuta la separabilidad multiplicativa del núcleo, que es la
forma algebraica de la afirmación; no se formaliza una teoría de independencia
de variables aleatorias sobre el simplex. -/
theorem dirichlet_no_factoriza :
    ¬ ∃ g h : ℝ → ℝ, ∀ x y : ℝ, 0 < x → 0 < y → x + y < 1 →
      x ^ 2 * y ^ 5 * (1 - x - y) ^ 3 = g x * h y := by
  rintro ⟨g, h, hgh⟩
  have p1 := hgh (1 / 6) (1 / 6) (by norm_num) (by norm_num) (by norm_num)
  have p2 := hgh (1 / 3) (1 / 3) (by norm_num) (by norm_num) (by norm_num)
  have p3 := hgh (1 / 6) (1 / 3) (by norm_num) (by norm_num) (by norm_num)
  have p4 := hgh (1 / 3) (1 / 6) (by norm_num) (by norm_num) (by norm_num)
  have key :
      ((1 / 6 : ℝ) ^ 2 * (1 / 6) ^ 5 * (1 - 1 / 6 - 1 / 6) ^ 3) *
        ((1 / 3 : ℝ) ^ 2 * (1 / 3) ^ 5 * (1 - 1 / 3 - 1 / 3) ^ 3) =
      ((1 / 6 : ℝ) ^ 2 * (1 / 3) ^ 5 * (1 - 1 / 6 - 1 / 3) ^ 3) *
        ((1 / 3 : ℝ) ^ 2 * (1 / 6) ^ 5 * (1 - 1 / 3 - 1 / 6) ^ 3) := by
    rw [p1, p2, p3, p4]
    ring
  norm_num at key

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
la divergencia KL entre dos pesos de probabilidad sobre `Fin 3`, estrictamente
positivos, es no negativa (desigualdad de Gibbs: `log x ≤ x − 1`).

Fidelidad: KL de sumas finitas sobre `Fin 3` con pesos positivos; no se usa la
KL de medidas. -/
theorem dKl_no_negativo {p q : Fin 3 → ℝ} (hp : ∀ j, 0 < p j) (hq : ∀ j, 0 < q j)
    (hp1 : ∑ j, p j = 1) (hq1 : ∑ j, q j = 1) : 0 ≤ dKl p q := by
  have key : ∑ j, p j * Real.log (q j / p j) ≤ 0 := by
    have h1 : ∑ j, p j * Real.log (q j / p j) ≤ ∑ j, (q j - p j) := by
      refine Finset.sum_le_sum (fun j _ => ?_)
      have hlog := Real.log_le_sub_one_of_pos (div_pos (hq j) (hp j))
      have h2 : p j * (q j / p j - 1) = q j - p j := by
        have hpj : p j ≠ 0 := ne_of_gt (hp j)
        field_simp
      rw [← h2]
      exact mul_le_mul_of_nonneg_left hlog (le_of_lt (hp j))
    rw [Finset.sum_sub_distrib, hp1, hq1] at h1
    linarith
  have h3 : dKl p q = -∑ j, p j * Real.log (q j / p j) := by
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl (fun j _ => ?_)
    rw [Real.log_div (ne_of_gt (hp j)) (ne_of_gt (hq j)),
      Real.log_div (ne_of_gt (hq j)) (ne_of_gt (hp j))]
    ring
  rw [h3]
  linarith

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
la KL de una distribución consigo misma es cero. -/
theorem dKl_self {p : Fin 3 → ℝ} (hp : ∀ j, 0 < p j) : dKl p p = 0 := by
  rw [dKl]
  refine Finset.sum_eq_zero (fun j _ => ?_)
  rw [div_self (ne_of_gt (hp j)), Real.log_one, mul_zero]

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
soporte técnico: el parámetro total `a₀ = ∑_j a_j` de un vector de parámetros
positivo es positivo (denominador no nulo de las medias de la Dirichlet). -/
theorem aTot_pos {a : Fin 3 → ℝ} (ha : ∀ j, 0 < a j) : 0 < aTot a :=
  Finset.sum_pos (fun j _ => ha j) Finset.univ_nonempty

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
soporte técnico: las medias `a_j/a₀` de una Dirichlet de parámetros positivos
son positivas (pesos de probabilidad del posterior). -/
theorem dMean_pos {a : Fin 3 → ℝ} (ha : ∀ j, 0 < a j) (j : Fin 3) : 0 < dMean a j :=
  div_pos (ha j) (aTot_pos ha)

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
soporte técnico: las medias `a_j/a₀` de una Dirichlet de parámetros positivos
suman uno: es la normalización que hace de `(3/13,6/13,4/13)` una probabilidad. -/
theorem dMean_suma {a : Fin 3 → ℝ} (ha : ∀ j, 0 < a j) : ∑ j, dMean a j = 1 := by
  simp only [dMean]
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (aTot_pos ha))

/-- book: capitulos/cap04_herramientas.typ:1151 (key: ex:ssch-mcmc-vi-cap03) —
el posterior exacto pertenece a la familia variacional de todas las Dirichlet,
luego el mínimo global de `KL(q ‖ posterior)` sobre esa familia es cero.

Enunciado: la familia es `{dMean a : a > 0}` (medias de Dirichlet con
parámetros positivos). Entonces
(1) `KL(q ‖ posterior) ≥ 0` para toda `q` de la familia, y
(2) el posterior `Dirichlet(3,6,4)` está en la familia y su KL es `0`.

Es lo que el libro afirma: «si la familia variacional contiene todas las
Dirichlet, contiene el posterior exacto y el mínimo global de KL es cero».

Fidelidad: la familia variacional se representa por sus medias (la KL entre dos
Dirichlet no se calcula en forma cerrada); lo que se prueba es (i) la KL es no
negativa en toda la familia y (ii) se anula en el posterior, que es la
propiedad de optimalidad global que el ejemplo usa como referencia. -/
theorem kl_minimo_global_cero :
    (∃ a : Fin 3 → ℝ, (∀ j, 0 < a j) ∧ dKl (dMean a) (dMean aPos) = 0) ∧
      (∀ a : Fin 3 → ℝ, (∀ j, 0 < a j) → 0 ≤ dKl (dMean a) (dMean aPos)) := by
  have hpos : ∀ j, 0 < aPos j := by
    intro j
    rw [aPos]
    fin_cases j <;> norm_num [aPri, cntD]
  refine ⟨⟨aPos, hpos, ?_⟩, fun a ha => ?_⟩
  · exact dKl_self (fun j => dMean_pos hpos j)
  · exact dKl_no_negativo (fun j => dMean_pos ha j) (fun j => dMean_pos hpos j)
      (dMean_suma ha) (dMean_suma hpos)

/-! ## Parte B — `ex:ch3-mcmc-ssch`: paso de Metropolis–Hastings fuera de la conjugación -/

/-- Denominador logístico `D(z) = 1 + e^{z₁} + e^{z₂}` (normalizador de las
probabilidades de transición en la parametrización logit). -/
noncomputable def logitDen (z1 z2 : ℝ) : ℝ := 1 + Real.exp z1 + Real.exp z2

/-- Parametrización logit de tres destinos:
`θ₁ = e^{z₁}/D`, `θ₂ = e^{z₂}/D`, `θ₃ = 1/D` con `D = 1 + e^{z₁} + e^{z₂}`. -/
noncomputable def logitSSCH (z1 z2 : ℝ) : Fin 3 → ℝ :=
  ![Real.exp z1 / logitDen z1 z2, Real.exp z2 / logitDen z1 z2, 1 / logitDen z1 z2]

/-- Log-densidad no normalizada del ejemplo (log posterior en `z`, `+C` omitida):
`ℓ(z) = 2z₁ + 5z₂ − 10 log(1 + e^{z₁} + e^{z₂}) − ‖z‖²/2`. -/
noncomputable def ellSSCH (z1 z2 : ℝ) : ℝ :=
  2 * z1 + 5 * z2 - 10 * Real.log (logitDen z1 z2) - (z1 ^ 2 + z2 ^ 2) / 2

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) —
soporte técnico: el denominador logístico `D = 1 + e^{z₁} + e^{z₂}` es positivo,
de modo que `θ_j = e^{z_j}/D` está bien definida y `log D` es real. -/
theorem logitDen_pos (z1 z2 : ℝ) : 0 < logitDen z1 z2 := by
  rw [logitDen]
  positivity

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — la
parametrización logit da probabilidades estrictamente positivas: `θ > 0`.

Fidelidad: `exp` y la suma positivas; no se formaliza el cambio de variable
(el libro advierte que el prior está definido en logits y por eso no se agrega
jacobiano a la densidad en `z`, que es lo que se respeta aquí). -/
theorem logitSSCH_pos (z1 z2 : ℝ) (j : Fin 3) : 0 < logitSSCH z1 z2 j := by
  have hD := logitDen_pos z1 z2
  rw [logitSSCH]
  fin_cases j <;> simp <;> positivity

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — la
parametrización logit vive en el simplex: `θ₁ + θ₂ + θ₃ = 1`. -/
theorem logitSSCH_suma (z1 z2 : ℝ) : ∑ j, logitSSCH z1 z2 j = 1 := by
  have hD := (logitDen_pos z1 z2).ne'
  rw [logitSSCH, logitDen, Fin.sum_univ_three]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — la
log-verosimilitud con conteos `(2,5,3)` en la parametrización logit es
`∑_j c_j log θ_j = 2z₁ + 5z₂ − 10 log(1 + e^{z₁} + e^{z₂})`: los tres `log θ_j`
aportan `−log D` cada uno y las ponderaciones suman `2+5+3 = 10`.

Por eso `ℓ(z) = ∑_j c_j log θ_j(z) − ‖z‖²/2` es la fórmula del libro.

Fidelidad: se verifica la identidad algebraica de la log-verosimilitud con la
constante absorbida en `C`; no se normaliza el posterior (no hace falta para el
paso de Metropolis–Hastings, cuyo cociente cancela la constante). -/
theorem ellSSCH_eq_conteos (z1 z2 : ℝ) :
    ∑ j, cntD j * Real.log (logitSSCH z1 z2 j) - (z1 ^ 2 + z2 ^ 2) / 2 =
      ellSSCH z1 z2 := by
  have hD := logitDen_pos z1 z2
  have h1 : Real.log (Real.exp z1 / logitDen z1 z2) =
      z1 - Real.log (logitDen z1 z2) := by
    rw [Real.log_div (Real.exp_pos z1).ne' hD.ne', Real.log_exp]
  have h2 : Real.log (Real.exp z2 / logitDen z1 z2) =
      z2 - Real.log (logitDen z1 z2) := by
    rw [Real.log_div (Real.exp_pos z2).ne' hD.ne', Real.log_exp]
  have h3 : Real.log (1 / logitDen z1 z2) = -Real.log (logitDen z1 z2) := by
    rw [Real.log_div one_ne_zero hD.ne', Real.log_one]
    ring
  rw [logitSSCH, Fin.sum_univ_three, ellSSCH]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.head_cons, Matrix.tail_cons, cntD]
  rw [h1, h2, h3]
  ring

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — valor
de la log-densidad en el origen: `ℓ(0,0) = −10 log 3`. -/
theorem ellSSCH_cero : ellSSCH 0 0 = -10 * Real.log 3 := by
  rw [ellSSCH]
  norm_num [logitDen, Real.exp_zero]

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — valor
de la log-densidad en el punto propuesto `z' = (0, 1/10)`:
`ℓ(0,1/10) = 5/10 − 10 log(2 + e^{1/10}) − 1/200`. -/
theorem ellSSCH_decima :
    ellSSCH 0 (1 / 10) = 5 / 10 - 10 * Real.log (2 + Real.exp (1 / 10)) - 1 / 200 := by
  rw [ellSSCH]
  norm_num [logitDen, Real.exp_zero]

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — la
diferencia de log-densidad del paso, exacta:
`ℓ(0,1/10) − ℓ(0,0) = 99/200 − 10 log((2 + e^{1/10})/3)`.

Fidelidad: forma cerrada exacta sobre `ℝ`; el decimal `≈ 0.15044` del libro no
se verifica con intervalos racionales (solo se prueba que es positivo, que es lo
que decide la aceptación). -/
theorem ellSSCH_diferencia :
    ellSSCH 0 (1 / 10) - ellSSCH 0 0 =
      99 / 200 - 10 * Real.log ((2 + Real.exp (1 / 10)) / 3) := by
  rw [ellSSCH_cero, ellSSCH_decima]
  have h1 : (0 : ℝ) < 2 + Real.exp (1 / 10) := by positivity
  rw [Real.log_div h1.ne' (by norm_num : (3 : ℝ) ≠ 0)]
  ring

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) —
soporte técnico: cota elemental `e^{1/10} ≤ 443/400`, por la serie de Taylor
truncada en `n = 2` (`Real.exp_bound'`): `1 + 1/10 + (1/100)·3/4 = 443/400`.
Es el único ingrediente numérico de la positividad de la diferencia de
log-densidad. -/
theorem exp_decima_cota : Real.exp (1 / 10) ≤ 443 / 400 := by
  have h := Real.exp_bound' (x := (1 / 10 : ℝ)) (by norm_num) (by norm_num)
    (n := 2) (by norm_num)
  norm_num [Finset.sum_range_succ, Nat.factorial] at h ⊢
  linarith

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — la
diferencia de log-densidad del paso es positiva: `ℓ(0,1/10) > ℓ(0,0)`.

Prueba: por `ellSSCH_diferencia` basta `log((2+e^{1/10})/3) < 99/2000`; con
`log x ≤ x − 1` y `e^{1/10} ≤ 443/400` se tiene
`(2+e^{1/10})/3 − 1 ≤ 43/1200 < 99/2000`.

Fidelidad: se prueba la positividad (estricta); el valor decimal del libro
queda como referencia numérica, no como aserción formalizada. -/
theorem ellSSCH_diferencia_pos : 0 < ellSSCH 0 (1 / 10) - ellSSCH 0 0 := by
  rw [ellSSCH_diferencia]
  have hD : (0 : ℝ) < (2 + Real.exp (1 / 10)) / 3 := by positivity
  have hlog : Real.log ((2 + Real.exp (1 / 10)) / 3) ≤ (2 + Real.exp (1 / 10)) / 3 - 1 :=
    Real.log_le_sub_one_of_pos hD
  have hexp := exp_decima_cota
  have hbound : (2 + Real.exp (1 / 10)) / 3 - 1 < 99 / 2000 := by linarith
  linarith

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — con
propuesta simétrica `z' = z + ε`, `ε ~ N₂(0, 0.1²I)`, la probabilidad de
aceptación es `min(1, exp(ℓ(z') − ℓ(z)))`; en `z = (0,0)`, `z' = (0,0.1)` vale
**uno** (el cociente de Hastings supera uno).

Fidelidad: se formaliza la regla de aceptación (el cociente de densidades con
propuesta simétrica) y su valor en el paso; no se simula la cadena ni se
verifica convergencia (el libro insiste en que es «un paso, no una cadena
convergida»). -/
theorem mh_paso_ssch_acepta_uno :
    min 1 (Real.exp (ellSSCH 0 (1 / 10) - ellSSCH 0 0)) = 1 := by
  refine min_eq_left ?_
  exact Real.one_le_exp (le_of_lt ellSSCH_diferencia_pos)

/-! ## Parte C — soporte de ambos ejemplos: aceptación, balance detallado y estacionariedad

La regla de aceptación del libro (`def:ch3-mh`, ya cerrada) es
`α(x,y) = min(1, π(y)q(y|x)/(π(x)q(x|y)))`. Aquí se prueba que (i) es una
probabilidad, (ii) con propuesta simétrica y `π = exp ∘ ℓ` se reduce a
`min(1, exp(ℓ(y) − ℓ(x)))` —la regla usada en `ex:ch3-mcmc-ssch`—, (iii) cumple
el balance detallado y (iv) el núcleo con rechazo deja `π` invariante, que es la
afirmación de estacionariedad que el ejemplo conjugado
(`ex:ssch-mcmc-vi-cap03`) usa como referencia. -/

section MH

variable {σ : Type*}

/-- Probabilidad de aceptación de Metropolis–Hastings para el estado actual `x`
y la propuesta `y`: `α(x,y) = min(1, π(y)q(y|x)/(π(x)q(x|y)))`. -/
noncomputable def mhAlpha (π : σ → ℝ) (q : σ → σ → ℝ) (x y : σ) : ℝ :=
  min 1 (π y * q y x / (π x * q x y))

/-- book: capitulos/cap04_herramientas.typ:1115 (key: def:ch3-mh, soporte) —
la aceptación de Metropolis–Hastings es una probabilidad: `0 ≤ α(x,y) ≤ 1` con
`π > 0` y `q > 0`.

Fidelidad: pesos estrictamente positivos; el caso `π(x) = 0` (cadena que no
visita `x`) queda fuera porque el libro supone densidad positiva. -/
theorem mhAlpha_mem_Icc {π : σ → ℝ} {q : σ → σ → ℝ} (hπ : ∀ x, 0 < π x) (hq : ∀ x y, 0 < q x y)
    (x y : σ) : mhAlpha π q x y ∈ Set.Icc 0 1 := by
  refine ⟨?_, ?_⟩
  · exact le_min zero_le_one
      (div_nonneg (mul_nonneg (hπ y).le (hq y x).le) (mul_pos (hπ x) (hq x y)).le)
  · exact min_le_left 1 _

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — con
propuesta simétrica `q(x,y) = q(y,x)` y `π = exp ∘ ℓ` (densidad sin
normalizar), la aceptación de Metropolis–Hastings es
`min(1, exp(ℓ(y) − ℓ(x)))`. Es exactamente la regla del ejemplo
logístico-normal: la constante `C` de `ℓ` se cancela.

Fidelidad: se formaliza el cociente de aceptación para densidades positivas; la
propuesta gaussiana `N₂(0, σ²I)` entra solo por su simetría. -/
theorem mhAlpha_exp_simetrica {ℓ : σ → ℝ} {q : σ → σ → ℝ}
    (hsym : ∀ x y, q x y = q y x) (hq : ∀ x y, q x y ≠ 0) (x y : σ) :
    mhAlpha (fun z => Real.exp (ℓ z)) q x y = min 1 (Real.exp (ℓ y - ℓ x)) := by
  rw [mhAlpha]
  have key : Real.exp (ℓ y) * q y x / (Real.exp (ℓ x) * q x y) = Real.exp (ℓ y - ℓ x) := by
    rw [Real.exp_sub, hsym x y]
    have hy : q y x ≠ 0 := hq y x
    field_simp
  rw [key]

/-- book: capitulos/cap04_herramientas.typ:1115 (key: def:ch3-mh, soporte) —
identidad auxiliar del cálculo de la aceptación: `a · min 1 r = min a (a·r)`
para `a > 0` (multiplicar `min(1, ·)` por la masa positiva `π(x)q(x,y)`). -/
private theorem mul_min_one {a r : ℝ} (ha : 0 < a) : a * min 1 r = min a (a * r) := by
  rcases le_total 1 r with h | h
  · rw [min_eq_left h, min_eq_left (by nlinarith), mul_one]
  · rw [min_eq_right h, min_eq_right (by nlinarith)]

/-- book: capitulos/cap04_herramientas.typ:1115 (key: def:ch3-mh, soporte) —
**balance detallado** del paso de Metropolis–Hastings:
`π(x) q(x,y) α(x,y) = π(y) q(y,x) α(y,x)` para `π, q > 0`. Ambos lados valen
`min(π(x)q(x,y), π(y)q(y,x))`.

Fidelidad: es el balance detallado del par propuesta/aceptación (el núcleo
completo con rechazo no lo satisface fuera de la diagonal, por eso la
estacionariedad se prueba aparte). -/
theorem mh_detailed_balance {π : σ → ℝ} {q : σ → σ → ℝ} {x y : σ}
    (hπx : 0 < π x) (hπy : 0 < π y) (hqxy : 0 < q x y) (hqyx : 0 < q y x) :
    π x * q x y * mhAlpha π q x y = π y * q y x * mhAlpha π q y x := by
  have hA : π x * q x y * mhAlpha π q x y = min (π x * q x y) (π y * q y x) := by
    rw [mhAlpha, mul_min_one (mul_pos hπx hqxy)]
    congr 1
    field_simp
  have hB : π y * q y x * mhAlpha π q y x = min (π y * q y x) (π x * q x y) := by
    rw [mhAlpha, mul_min_one (mul_pos hπy hqyx)]
    congr 1
    field_simp
  rw [hA, hB, min_comm]

/-! ### Núcleo completo con rechazo (estados finitos) -/

section Finito

variable [Fintype σ] [DecidableEq σ]

/-- Masa de rechazo en `x`: `1 − ∑_y q(x,y) α(x,y)`. -/
noncomputable def mhRej (π : σ → ℝ) (q : σ → σ → ℝ) (x : σ) : ℝ :=
  1 - ∑ y, q x y * mhAlpha π q x y

/-- Núcleo de Metropolis–Hastings: con probabilidad `q(x,y)α(x,y)` se mueve a
`y`; el rechazo devuelve la masa al estado actual `x`. -/
noncomputable def mhKernel (π : σ → ℝ) (q : σ → σ → ℝ) (x y : σ) : ℝ :=
  q x y * mhAlpha π q x y + if y = x then mhRej π q x else 0

/-- book: capitulos/cap04_herramientas.typ:1115 (key: def:ch3-mh, soporte) —
**estacionariedad**: si `π > 0`, `q > 0` y `q` es estocástica por filas
(`∑_y q(x,y) = 1`), el núcleo de Metropolis–Hastings deja `π` invariante:
`∑_x π(x) P(x,y) = π(y)`.

Prueba: el balance detallado lleva `∑_x π(x)q(x,y)α(x,y)` a
`π(y)∑_x q(y,x)α(y,x) = π(y)(1 − rej(y))`, y el rechazo devuelve
`π(y)rej(y)` al estado `y`.

Fidelidad: estados finitos; la convergencia a `π` (ergodicidad, aperiodicidad,
mezcla) no se formaliza — el libro la condiciona explícitamente y advierte que
los diagnósticos no son pruebas de convergencia. -/
theorem mh_estacionaria {π : σ → ℝ} {q : σ → σ → ℝ}
    (hπ : ∀ x, 0 < π x) (hq : ∀ x y, 0 < q x y) (hqsum : ∀ x, ∑ y, q x y = 1) (y : σ) :
    ∑ x, π x * mhKernel π q x y = π y := by
  have hterm : ∀ x, π x * mhKernel π q x y =
      π x * q x y * mhAlpha π q x y + (if y = x then π x * mhRej π q x else 0) := by
    intro x
    rw [mhKernel]
    split_ifs with h <;> ring
  have hdiag : ∑ x, (if y = x then π x * mhRej π q x else 0) = π y * mhRej π q y := by
    simp
  have hbal : ∑ x, π x * q x y * mhAlpha π q x y =
      ∑ x, π y * q y x * mhAlpha π q y x :=
    Finset.sum_congr rfl (fun x _ => mh_detailed_balance (hπ x) (hπ y) (hq x y) (hq y x))
  have hrej : mhRej π q y = 1 - ∑ x, q y x * mhAlpha π q y x := rfl
  calc ∑ x, π x * mhKernel π q x y
      = ∑ x, (π x * q x y * mhAlpha π q x y +
          (if y = x then π x * mhRej π q x else 0)) :=
        Finset.sum_congr rfl (fun x _ => hterm x)
    _ = ∑ x, π x * q x y * mhAlpha π q x y +
          ∑ x, (if y = x then π x * mhRej π q x else 0) := Finset.sum_add_distrib
    _ = π y * (∑ x, q y x * mhAlpha π q y x) + π y * mhRej π q y := by
        rw [hdiag, hbal, Finset.mul_sum]
        simp only [mul_assoc]
    _ = π y * (1 - mhRej π q y) + π y * mhRej π q y := by
        rw [hrej]
        ring
    _ = π y := by ring

end Finito

/-- book: capitulos/cap04_herramientas.typ:1181 (key: ex:ch3-mcmc-ssch) — el
paso del ejemplo es la regla general de Metropolis–Hastings: con
`π = exp ∘ ℓ_{SSCH}` sobre `ℝ × ℝ` y una propuesta simétrica (aquí la constante
`q ≡ 1`, que es simétrica y positiva), la aceptación en
`z = (0,0) → z' = (0,0.1)` es `min(1, exp(ℓ(z') − ℓ(z))) = 1`.

Esto conecta el ejemplo logístico-normal con `def:ch3-mh` sin volver a
postular la regla de aceptación.

Fidelidad: la propuesta se toma constante para no formalizar la densidad
gaussiana `N₂(0, 0.1²I)`; del libro se usa solo su simetría. -/
theorem mhAlpha_ssch_paso :
    mhAlpha (fun z : ℝ × ℝ => Real.exp (ellSSCH z.1 z.2)) (fun _ _ => (1 : ℝ))
      (0, 0) (0, 1 / 10) = 1 := by
  rw [mhAlpha_exp_simetrica (fun _ _ => rfl) (fun _ _ => one_ne_zero)]
  simpa using mh_paso_ssch_acepta_uno

end MH

end Book.M13
