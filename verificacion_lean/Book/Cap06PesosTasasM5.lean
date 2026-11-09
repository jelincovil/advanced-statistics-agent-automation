import Mathlib

/-!
# Book.Cap06PesosTasasM5 — cap. 6 (`cap06_fallos.typ`): costo del horizonte en IS y tasas

Cierra dos claves pendientes del capítulo 6 del libro:

* `ex:ch6-horizonte-pesos` (`capitulos/cap06_fallos.typ:453`): en un modelo de un
  estado con acciones iid bajo cada política y recompensa terminal constante,
  el peso de IS por trayectoria `W_H = ∏_{t<H} π_e(A_t)/π_b(A_t)` verifica
  `E_b[W_H] = 1` y `Var_b(W_H) = c^H - 1` con `c = p²/b + (1-p)²/(1-b)`;
  para `p = 4/5` el libro da `c = 1.36` (`b = 0.5`) y `c = 3.25` (`b = 0.2`).
* `ex:ch6-tasas` (`capitulos/cap06_fallos.typ:486`): compatibilidad e
  incompatibilidad de tasas en el resto de segundo orden
  `a_n·b_n = o_P(n^{-1/2})`, y la frontera de suavidad
  `n^{-β/(2β+d)} > n^{-1/4} ⟺ β > d/2`.

Convención del proyecto: docstring `book: <archivo>:<línea> (key: <clave>)` y
fidelidad declarada en cada teorema. Cero `sorry`; axiomas ⊆
`{propext, Classical.choice, Quot.sound}`.
-/

set_option linter.unusedVariables false
set_option maxHeartbeats 2000000

open Finset BigOperators MeasureTheory ProbabilityTheory Filter
open scoped ENNReal Topology

namespace Cap06M5

/-! ## ex:ch6-horizonte-pesos — modelo de un estado con acciones iid -/

/-- Medida de Bernoulli de parámetro `b` sobre `Bool`: `true` con peso `b`,
`false` con peso `1 - b`. Se escribe con `ENNReal.ofReal` para evitar
truncamientos cuando `0 ≤ b ≤ 1`. -/
noncomputable def bernMeasure (b : ℝ) : Measure Bool :=
  ENNReal.ofReal b • Measure.dirac true + ENNReal.ofReal (1 - b) • Measure.dirac false

instance (b : ℝ) : IsFiniteMeasure (bernMeasure b) := by
  constructor
  rw [bernMeasure, Measure.add_apply, Measure.smul_apply, Measure.smul_apply,
    Measure.dirac_apply_of_mem (by simp), Measure.dirac_apply_of_mem (by simp), smul_eq_mul,
    smul_eq_mul, mul_one, mul_one]
  exact ENNReal.add_lt_top.mpr ⟨ENNReal.ofReal_lt_top, ENNReal.ofReal_lt_top⟩

instance (b : ℝ) : SigmaFinite (bernMeasure b) := inferInstance

lemma bernMeasure_univ (b : ℝ) (h0 : 0 ≤ b) (h1 : b ≤ 1) : bernMeasure b Set.univ = 1 := by
  have h1' : 0 ≤ 1 - b := by linarith
  rw [bernMeasure, Measure.add_apply, Measure.smul_apply, Measure.smul_apply,
    Measure.dirac_apply_of_mem (by simp), Measure.dirac_apply_of_mem (by simp), smul_eq_mul,
    smul_eq_mul, mul_one, mul_one, ← ENNReal.ofReal_add h0 h1']
  simp

lemma integrable_dirac_bool (f : Bool → ℝ) (a : Bool) : Integrable f (Measure.dirac a) := by
  apply integrable_dirac
  simp

/-- Integral contra la medida de Bernoulli: `∫ f ∂bern(b) = b·f(true) + (1-b)·f(false)`. -/
lemma integral_bernMeasure (b : ℝ) (h0 : 0 ≤ b) (h1 : b ≤ 1) (f : Bool → ℝ) :
    ∫ y, f y ∂(bernMeasure b) = b * f true + (1 - b) * f false := by
  have h1' : 0 ≤ 1 - b := by linarith
  have hi1 : Integrable f (ENNReal.ofReal b • Measure.dirac true) :=
    (integrable_dirac_bool f true).smul_measure ENNReal.ofReal_ne_top
  have hi2 : Integrable f (ENNReal.ofReal (1 - b) • Measure.dirac false) :=
    (integrable_dirac_bool f false).smul_measure ENNReal.ofReal_ne_top
  rw [bernMeasure, integral_add_measure hi1 hi2, integral_smul_measure, integral_smul_measure,
    integral_dirac, integral_dirac, ENNReal.toReal_ofReal h0, ENNReal.toReal_ofReal h1',
    smul_eq_mul, smul_eq_mul]

/-- Ley del vector de acciones `(A_0, …, A_{H-1})` bajo la política de
comportamiento: producto de `H` copias independientes de `bernMeasure b`. -/
noncomputable def muH (b : ℝ) (H : ℕ) : Measure (Fin H → Bool) :=
  Measure.pi (fun _ => bernMeasure b)

instance (b : ℝ) (H : ℕ) : IsFiniteMeasure (muH b H) := by
  constructor
  rw [muH, Measure.pi_univ]
  exact ENNReal.prod_lt_top (fun i _ => IsFiniteMeasure.measure_univ_lt_top)

instance (b : ℝ) (H : ℕ) : SigmaFinite (muH b H) := inferInstance

lemma muH_univ (b : ℝ) (h0 : 0 ≤ b) (h1 : b ≤ 1) (H : ℕ) : muH b H Set.univ = 1 := by
  rw [muH, Measure.pi_univ]
  exact Finset.prod_eq_one (fun i _ => bernMeasure_univ b h0 h1)

/-- Factorización de Fubini en `H` variables (independencia de las acciones). -/
lemma integral_pi_prod {H : ℕ} (f : Fin H → Bool → ℝ) :
    ∫ x : Fin H → Bool, ∏ t, f t (x t) ∂(muH b H) = ∏ t, ∫ y, f t y ∂(bernMeasure b) :=
  integral_fintype_prod_eq_prod f

/-- Razón de importancia de una acción para las políticas `π_e(1) = p` y
`π_b(1) = b`. -/
noncomputable def ratio (p b : ℝ) (y : Bool) : ℝ := if y then p / b else (1 - p) / (1 - b)

/-- Peso de importancia por trayectoria `W_H = ∏_{t<H} π_e(A_t)/π_b(A_t)`. -/
noncomputable def W (p b : ℝ) (H : ℕ) (x : Fin H → Bool) : ℝ := ∏ t, ratio p b (x t)

/-- Constante `c = p²/b + (1-p)²/(1-b)` del libro: segundo momento de una razón. -/
noncomputable def cConst (p b : ℝ) : ℝ := p ^ 2 / b + (1 - p) ^ 2 / (1 - b)

lemma measurable_W (p b : ℝ) (H : ℕ) : AEStronglyMeasurable (W p b H) (muH b H) := by
  unfold W ratio
  measurability

lemma abs_bound_W (p b : ℝ) (H : ℕ) :
    ∀ᵐ x ∂(muH b H), ‖W p b H x‖ ≤ (max |p / b| |(1 - p) / (1 - b)|) ^ H := by
  filter_upwards with x
  rw [Real.norm_eq_abs, W, Finset.abs_prod]
  calc ∏ t, |ratio p b (x t)| ≤ ∏ _t : Fin H, max |p / b| |(1 - p) / (1 - b)| := by
        gcongr with i _
        unfold ratio
        split_ifs <;> simp
    _ = (max |p / b| |(1 - p) / (1 - b)|) ^ H := by simp

lemma memLp_W (p b : ℝ) (H : ℕ) : MemLp (W p b H) 2 (muH b H) :=
  MemLp.of_bound (measurable_W p b H) _ (abs_bound_W p b H)

/-- Segundo momento de una razón: `E_b[(π_e(A)/π_b(A))²] = c`. -/
lemma integral_ratio_sq (p b : ℝ) (h0 : 0 < b) (h1 : b < 1) :
    ∫ y, (ratio p b y) ^ 2 ∂(bernMeasure b) = cConst p b := by
  have hb0 : b ≠ 0 := ne_of_gt h0
  have hb1 : 1 - b ≠ 0 := by linarith
  rw [integral_bernMeasure b (le_of_lt h0) (le_of_lt h1)]
  simp only [ratio, ite_true, ite_false, Bool.false_eq_true]
  unfold cConst
  field_simp

/-- Primer momento de una razón: `E_b[π_e(A)/π_b(A)] = 1` (cada razón está
centrada en uno, de donde `E_b[W_H] = 1`). -/
lemma integral_ratio (p b : ℝ) (h0 : 0 < b) (h1 : b < 1) :
    ∫ y, ratio p b y ∂(bernMeasure b) = 1 := by
  have hb0 : b ≠ 0 := ne_of_gt h0
  have hb1 : 1 - b ≠ 0 := by linarith
  rw [integral_bernMeasure b (le_of_lt h0) (le_of_lt h1)]
  simp only [ratio, ite_true, ite_false, Bool.false_eq_true]
  field_simp
  ring

lemma integral_W_eq (p b : ℝ) (h0 : 0 < b) (h1 : b < 1) (H : ℕ) :
    ∫ x, W p b H x ∂(muH b H) = 1 := by
  have h : ∫ x, W p b H x ∂(muH b H)
      = ∏ t : Fin H, ∫ y, ratio p b y ∂(bernMeasure b) := by
    simp only [W]
    exact integral_pi_prod (fun _ y => ratio p b y)
  rw [h, Finset.prod_eq_one (fun i _ => integral_ratio p b h0 h1)]

lemma integral_W_sq_eq (p b : ℝ) (h0 : 0 < b) (h1 : b < 1) (H : ℕ) :
    ∫ x, (W p b H ^ 2) x ∂(muH b H) = (cConst p b) ^ H := by
  have hfun : (fun x : Fin H → Bool => (W p b H ^ 2) x)
      = (fun x : Fin H → Bool => ∏ t, (ratio p b (x t)) ^ 2) := by
    funext x
    rw [Pi.pow_apply]
    simp only [W]
    exact (Finset.prod_pow (s := Finset.univ) (f := fun t => ratio p b (x t)) (n := 2)).symm
  rw [hfun]
  have h : ∫ x : Fin H → Bool, ∏ t, (ratio p b (x t)) ^ 2 ∂(muH b H)
      = ∏ t : Fin H, ∫ y, (ratio p b y) ^ 2 ∂(bernMeasure b) :=
    integral_pi_prod (fun _ y => (ratio p b y) ^ 2)
  rw [h]
  simp [integral_ratio_sq p b h0 h1]

/-- book: capitulos/cap06_fallos.typ:453 (key: ex:ch6-horizonte-pesos) —
**esperanza del peso de IS**. En el modelo de un estado con acciones iid bajo
la política de comportamiento (`P_b(A_t = 1) = b`), horizonte `H` y razón de
importancia `π_e/π_b`, el peso por trayectoria `W_H` cumple `E_b[W_H] = 1`.

Fidelidad declarada: modelo finito-discreto exacto (ley producto de `H` copias
de Bernoulli), sin recompensas aleatorias. La afirmación del libro de que «el
valor es uno» con recompensa terminal constante uno se usa sólo para leer
`E_b[W_H]` como el valor de la política objetivo; la igualdad `E_b[W_H] = 1`
es la que se prueba. -/
theorem ch6_horizonte_pesos_esperanza (p b : ℝ) (hp0 : 0 < p) (hp1 : p < 1)
    (h0 : 0 < b) (h1 : b < 1) (H : ℕ) :
    ∫ x, W p b H x ∂(muH b H) = 1 :=
  integral_W_eq p b h0 h1 H

/-- book: capitulos/cap06_fallos.typ:453 (key: ex:ch6-horizonte-pesos) —
**varianza exacta del peso de IS**: `Var_b(W_H) = c^H - 1` con
`c = p²/b + (1-p)²/(1-b)`.

Fidelidad declarada: se prueba la identidad exacta para el modelo producto
finito-discreto (acciones iid Bernoulli con `0 < b < 1`, `0 < p < 1`). No se
formaliza el estimador promedio sobre `n` trayectorias (el factor `1/n` del
libro) ni la recompensa aleatoria; véase `README.md`. -/
theorem ch6_horizonte_pesos_varianza (p b : ℝ) (hp0 : 0 < p) (hp1 : p < 1)
    (h0 : 0 < b) (h1 : b < 1) (H : ℕ) :
    variance (W p b H) (muH b H) = (cConst p b) ^ H - 1 := by
  haveI : IsProbabilityMeasure (muH b H) := ⟨muH_univ b (le_of_lt h0) (le_of_lt h1) H⟩
  rw [variance_eq_sub (memLp_W p b H), integral_W_sq_eq p b h0 h1 H, integral_W_eq p b h0 h1 H]
  ring

/-- El valor `b = 1/2` del libro: con `p = 4/5`, `c = 1.36 = 34/25`. -/
theorem ch6_horizonte_pesos_b_mitad :
    cConst (4 / 5) (1 / 2) = 34 / 25 := by
  unfold cConst
  norm_num

/-- El valor `b = 1/5` del libro (`b = 0.2`): con `p = 4/5`, `c = 3.25 = 13/4`. -/
theorem ch6_horizonte_pesos_b_quinto :
    cConst (4 / 5) (1 / 5) = 13 / 4 := by
  unfold cConst
  norm_num

/-- La varianza del peso crece geométricamente cuando `c > 1`: el costo de un
horizonte largo es una explosión exponencial en `H`, aunque cada razón sea
finita. -/
theorem ch6_horizonte_pesos_explosion (c : ℝ) (hc : 1 < c) :
    Tendsto (fun H : ℕ => c ^ H - 1) atTop atTop := by
  have h : Tendsto (fun H : ℕ => c ^ H) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt hc
  refine tendsto_atTop_atTop.mpr (fun b => ?_)
  obtain ⟨N, hN⟩ := tendsto_atTop_atTop.mp h (b + 1)
  exact ⟨N, fun k hk => by linarith [hN k hk]⟩

/-! ## ex:ch6-tasas — tasas compatibles e incompatibles -/

/-- **Tasas compatibles.** Si los errores `L²` de las dos funciones auxiliares
están acotados por las envolventes deterministas `C·x^{-3/10}` y `C'·x^{-1/4}`
(a partir de `x ≥ 1`), el producto es `o(x^{-1/2})`: multiplicado por
`x^{1/2}` tiende a cero.

Fidelidad declarada: `O_P(n^{-s})` se formaliza por su envolvente
determinista `|a_n| ≤ C·n^{-s}` (la lectura «sobre un evento de probabilidad
`1-ε`»; el paso probabilístico `O_P` no se formaliza). -/
theorem producto_tasas_compatible (a b : ℝ → ℝ) (C C' : ℝ) (hC : 0 ≤ C) (hC' : 0 ≤ C')
    (ha : ∀ x, 1 ≤ x → |a x| ≤ C * x ^ (-(3 / 10 : ℝ)))
    (hb : ∀ x, 1 ≤ x → |b x| ≤ C' * x ^ (-(1 / 4 : ℝ))) :
    Tendsto (fun x : ℝ => x ^ ((1 : ℝ) / 2) * (a x * b x)) atTop (𝓝 0) := by
  have hbound : ∀ x : ℝ, 1 ≤ x →
      ‖x ^ ((1 : ℝ) / 2) * (a x * b x)‖ ≤ (C * C') * x ^ (-(1 / 20 : ℝ)) := by
    intro x hx
    have hx0 : 0 < x := by linarith
    have h1' : (0 : ℝ) ≤ x ^ ((1 : ℝ) / 2) := Real.rpow_nonneg (le_of_lt hx0) _
    have h2' : (0 : ℝ) ≤ C * x ^ (-(3 / 10 : ℝ)) :=
      mul_nonneg hC (Real.rpow_nonneg (le_of_lt hx0) _)
    have h3' : (0 : ℝ) ≤ C' * x ^ (-(1 / 4 : ℝ)) :=
      mul_nonneg hC' (Real.rpow_nonneg (le_of_lt hx0) _)
    have hstep : ‖x ^ ((1 : ℝ) / 2) * (a x * b x)‖
        ≤ x ^ ((1 : ℝ) / 2) * ((C * x ^ (-(3 / 10 : ℝ))) * (C' * x ^ (-(1 / 4 : ℝ)))) := by
      rw [Real.norm_eq_abs, abs_mul, abs_mul, abs_of_nonneg h1']
      refine mul_le_mul_of_nonneg_left ?_ h1'
      exact mul_le_mul (ha x hx) (hb x hx) (abs_nonneg _) h2'
    refine hstep.trans (le_of_eq ?_)
    rw [show x ^ ((1 : ℝ) / 2) * ((C * x ^ (-(3 / 10 : ℝ))) * (C' * x ^ (-(1 / 4 : ℝ))))
        = (C * C') * (x ^ ((1 : ℝ) / 2) * (x ^ (-(3 / 10 : ℝ)) * x ^ (-(1 / 4 : ℝ)))) by ring]
    congr 1
    rw [← Real.rpow_add hx0, ← Real.rpow_add hx0]
    norm_num
  have hle : ∀ᶠ x : ℝ in atTop,
      ‖x ^ ((1 : ℝ) / 2) * (a x * b x)‖ ≤ (C * C') * x ^ (-(1 / 20 : ℝ)) := by
    filter_upwards [eventually_ge_atTop (1 : ℝ)] with x hx using hbound x hx
  have hlim : Tendsto (fun x : ℝ => (C * C') * x ^ (-(1 / 20 : ℝ))) atTop (𝓝 0) := by
    have h := tendsto_rpow_neg_atTop (show (0:ℝ) < 1 / 20 by norm_num)
    simpa using h.const_mul (C * C')
  exact squeeze_zero_norm' hle hlim

/-- book: capitulos/cap06_fallos.typ:486 (key: ex:ch6-tasas) —
**tasas `O_P(n^{-0.30})·O_P(n^{-0.25})` son compatibles**: el producto es
`o_P(n^{-1/2})`. Se prueba la versión con envolventes deterministas. -/
theorem ch6_tasas_compatibles :
    Tendsto (fun x : ℝ => x ^ ((1 : ℝ) / 2) *
      (x ^ (-(3 / 10 : ℝ)) * x ^ (-(1 / 4 : ℝ)))) atTop (𝓝 0) := by
  have h := producto_tasas_compatible (fun x => x ^ (-(3 / 10 : ℝ)))
    (fun x => x ^ (-(1 / 4 : ℝ))) 1 1 (by norm_num) (by norm_num)
    (fun x hx => by
      rw [abs_of_nonneg (Real.rpow_nonneg (by linarith : (0:ℝ) ≤ x) _), one_mul])
    (fun x hx => by
      rw [abs_of_nonneg (Real.rpow_nonneg (by linarith : (0:ℝ) ≤ x) _), one_mul])
  simpa using h

/-- book: capitulos/cap06_fallos.typ:486 (key: ex:ch6-tasas) —
**dos tasas `O_P(n^{-0.20})` son incompatibles**: el producto es `n^{-0.40}` y
`√n·n^{-0.40} = n^{0.10} → ∞`, de modo que no puede garantizarse inferencia a
escala `√n` (el resto no es `o_P(n^{-1/2})`). -/
theorem ch6_tasas_incompatibles_020 :
    Tendsto (fun x : ℝ => x ^ ((1 : ℝ) / 2) *
      (x ^ (-(1 / 5 : ℝ)) * x ^ (-(1 / 5 : ℝ)))) atTop atTop := by
  have hev : (fun x : ℝ => x ^ ((1 : ℝ) / 2) * (x ^ (-(1 / 5 : ℝ)) * x ^ (-(1 / 5 : ℝ))))
      =ᶠ[atTop] (fun x : ℝ => x ^ ((1 : ℝ) / 10)) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    rw [← Real.rpow_add hx, ← Real.rpow_add hx]
    norm_num
  exact (tendsto_rpow_atTop (show (0:ℝ) < 1 / 10 by norm_num)).congr' hev.symm

/-- book: capitulos/cap06_fallos.typ:486 (key: ex:ch6-tasas) —
**dos tasas exactamente `O_P(n^{-1/4})` tampoco bastan**: el producto es
exactamente `n^{-1/2}` y `√n·n^{-1/2} = 1`, que no tiende a cero: falta el
orden pequeño. -/
theorem ch6_tasas_cuarto_no_pequeno :
    Tendsto (fun x : ℝ => x ^ ((1 : ℝ) / 2) *
      (x ^ (-(1 / 4 : ℝ)) * x ^ (-(1 / 4 : ℝ)))) atTop (𝓝 1) := by
  have hev : (fun x : ℝ => x ^ ((1 : ℝ) / 2) * (x ^ (-(1 / 4 : ℝ)) * x ^ (-(1 / 4 : ℝ))))
      =ᶠ[atTop] (fun _ : ℝ => 1) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    rw [← Real.rpow_add hx, ← Real.rpow_add hx]
    norm_num
  exact tendsto_const_nhds.congr' hev.symm

/-- book: capitulos/cap06_fallos.typ:486 (key: ex:ch6-tasas) —
**caso paramétrico regular**: dos tasas `n^{-1/2}` dan producto `n^{-1}`, que
sí es `o(n^{-1/2})` (`√n·n^{-1} = n^{-1/2} → 0`). -/
theorem ch6_tasas_parametrico :
    Tendsto (fun x : ℝ => x ^ ((1 : ℝ) / 2) *
      (x ^ (-(1 / 2 : ℝ)) * x ^ (-(1 / 2 : ℝ)))) atTop (𝓝 0) := by
  have hev : (fun x : ℝ => x ^ ((1 : ℝ) / 2) * (x ^ (-(1 / 2 : ℝ)) * x ^ (-(1 / 2 : ℝ))))
      =ᶠ[atTop] (fun x : ℝ => x ^ (-(1 / 2 : ℝ))) := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    rw [← Real.rpow_add hx, ← Real.rpow_add hx]
    norm_num
  exact (tendsto_rpow_neg_atTop (show (0:ℝ) < 1 / 2 by norm_num)).congr' hev.symm

/-- book: capitulos/cap06_fallos.typ:486 (key: ex:ch6-tasas) —
**frontera de suavidad**: la tasa no paramétrica `n^{-β/(2β+d)}` supera
`n^{-1/4}` si y sólo si `β > d/2` (dimensión fija por sí sola no basta). -/
theorem ch6_tasas_no_parametrico (β d : ℝ) (hβ : 0 < β) (hd : 0 < d) :
    ((1 : ℝ) / 4 < β / (2 * β + d) ↔ d < 2 * β) := by
  have hpos : (0:ℝ) < 2 * β + d := by linarith
  rw [lt_div_iff₀ hpos]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ## Auditoría de axiomas -/

#print axioms ch6_horizonte_pesos_esperanza
#print axioms ch6_horizonte_pesos_varianza
#print axioms ch6_horizonte_pesos_b_mitad
#print axioms ch6_horizonte_pesos_b_quinto
#print axioms ch6_horizonte_pesos_explosion
#print axioms producto_tasas_compatible
#print axioms ch6_tasas_compatibles
#print axioms ch6_tasas_incompatibles_020
#print axioms ch6_tasas_cuarto_no_pequeno
#print axioms ch6_tasas_parametrico
#print axioms ch6_tasas_no_parametrico

end Cap06M5
