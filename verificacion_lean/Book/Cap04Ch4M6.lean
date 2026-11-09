import Mathlib

/-!
# Cap04 — lote m6 (enjambre smw8gy947): capítulo 4, claves `ch4-*`

Formalizaciones nuevas para claves pendientes de
`capitulos/cap04_herramientas.typ`, en el idioma que ya usa el proyecto
(`Book/Cap04Herramientas.lean`, `Book/Cap04LoteM16.lean`): enunciados
explícitos, sin `sorry`, y cada teorema con su traza `book:`.

Claves cubiertas aquí: `ex:ch4-regularidad`, `ex:ch4-ar1`,
`ex:ch4-no-parametrico`, `ex:ch4-bootstrap-unidad`,
`ex:ch4-if-media-cuantil`. Las claves `thm:ch4-umpu` y `thm:ch4-bh` se
abordan en `Book/Cap04Ch4BhUmpuM6.lean`.

Fidelidad declarada: todo es la versión escalar/finita. Las
probabilidades entran como hipótesis explícitas sobre una medida de
probabilidad (`MeasureTheory.IsProbabilityMeasure`) cuando se usa
integración, y como un funcional de esperanza abstracto `Expect` cuando
sólo se usa linealidad y positividad (mismo idioma que
`thm:ch4-bonferroni` para `P : Set Ω → ℝ`).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators MeasureTheory ProbabilityTheory Filter
open scoped Topology

universe u

namespace Cap04M6

/-! ## Funcional de esperanza abstracto (base no enunciada) -/

/-- Funcional de esperanza: lineal, normalizado y monótono. Las propiedades
que en el libro se dan por supuestas de `EE` entran aquí como campos; así los
cálculos de varianza no arrastran condiciones de integrabilidad. -/
structure Expect (Ω : Type u) where
  /-- el funcional -/
  toFun : (Ω → ℝ) → ℝ
  /-- normalización: `E[1] = 1` -/
  map_one : toFun 1 = 1
  /-- linealidad en la suma -/
  map_add : ∀ f g : Ω → ℝ, toFun (f + g) = toFun f + toFun g
  /-- homogeneidad escalar -/
  map_smul : ∀ (c : ℝ) (f : Ω → ℝ), toFun (fun ω => c * f ω) = c * toFun f
  /-- congruencia puntual -/
  map_congr : ∀ f g : Ω → ℝ, (∀ ω, f ω = g ω) → toFun f = toFun g
  /-- positividad -/
  map_nonneg : ∀ f : Ω → ℝ, (∀ ω, 0 ≤ f ω) → 0 ≤ toFun f

namespace Expect

variable {Ω : Type u}

/-- Las constantes se evalúan en sí mismas: `E[c] = c`. -/
theorem map_const (P : Expect Ω) (c : ℝ) : P.toFun (fun _ => c) = c := by
  have h := P.map_smul c (1 : Ω → ℝ)
  have h1 : (fun ω => c * (1 : Ω → ℝ) ω) = fun _ => c := by funext ω; simp
  rw [h1, P.map_one, mul_one] at h
  exact h

/-- La esperanza de una combinación lineal de dos funciones. -/
theorem map_lin (P : Expect Ω) (a b : ℝ) (f g : Ω → ℝ) :
    P.toFun (fun ω => a * f ω + b * g ω) = a * P.toFun f + b * P.toFun g := by
  have h : (fun ω => a * f ω + b * g ω) = (fun ω => a * f ω) + (fun ω => b * g ω) := rfl
  rw [h, P.map_add, P.map_smul, P.map_smul]

end Expect

/-- Varianza bajo un funcional de esperanza abstracto: `Var(Y) = E[(Y − E[Y])²]`. -/
noncomputable def var {Ω : Type u} (P : Expect Ω) (Y : Ω → ℝ) : ℝ :=
  P.toFun (fun ω => (Y ω - P.toFun Y) ^ 2)

/-- La varianza es no negativa. -/
theorem var_nonneg {Ω : Type u} (P : Expect Ω) (Y : Ω → ℝ) : 0 ≤ var P Y :=
  P.map_nonneg _ fun _ => sq_nonneg _

/-! ## ex:ch4-regularidad — regularidad, mala especificación y frontera -/

/-- Media muestral `x̄ = (∑ xᵢ)/n` (base no enunciada). -/
noncomputable def sampleMean {n : ℕ} (x : Fin n → ℝ) : ℝ := (∑ i, x i) / (n : ℝ)

/-- Los residuos respecto de la media muestral suman cero (si `n ≠ 0`). -/
theorem sum_sub_sampleMean {n : ℕ} (x : Fin n → ℝ) (hn : n ≠ 0) :
    ∑ i, (x i - sampleMean x) = 0 := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  simp only [sampleMean]
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul]
  field_simp
  ring

/-- Descomposición de la suma de cuadrados:
`∑(xᵢ−c)² = ∑(xᵢ−x̄)² + n(x̄−c)²`. -/
theorem sse_decomposition {n : ℕ} (x : Fin n → ℝ) (hn : n ≠ 0) (c : ℝ) :
    ∑ i, (x i - c) ^ 2 = ∑ i, (x i - sampleMean x) ^ 2 + (n : ℝ) * (sampleMean x - c) ^ 2 := by
  have hmid : ∑ i, (x i - sampleMean x) = 0 := sum_sub_sampleMean x hn
  have hkey : ∀ i : Fin n,
      (x i - c) ^ 2 = (x i - sampleMean x) ^ 2
        + 2 * (sampleMean x - c) * (x i - sampleMean x) + (sampleMean x - c) ^ 2 :=
    fun i => by ring
  calc ∑ i, (x i - c) ^ 2
      = ∑ i, ((x i - sampleMean x) ^ 2 + 2 * (sampleMean x - c) * (x i - sampleMean x)
          + (sampleMean x - c) ^ 2) := Finset.sum_congr rfl fun i _ => hkey i
    _ = ∑ i, (x i - sampleMean x) ^ 2 + 2 * (sampleMean x - c) * (∑ i, (x i - sampleMean x))
          + (n : ℝ) * (sampleMean x - c) ^ 2 := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum,
          Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    _ = _ := by rw [hmid]; ring

/-- La media muestral minimiza la suma de cuadrados. -/
theorem sse_min {n : ℕ} (x : Fin n → ℝ) (hn : 0 < n) (c : ℝ) :
    ∑ i, (x i - sampleMean x) ^ 2 ≤ ∑ i, (x i - c) ^ 2 := by
  rw [sse_decomposition x hn.ne' c]
  have hnn : (0 : ℝ) ≤ (n : ℝ) * (sampleMean x - c) ^ 2 := by positivity
  linarith

/-- Log-verosimilitud gaussiana con media `c` y varianza impuesta `σ²`. -/
noncomputable def gaussLoglik {n : ℕ} (σ : ℝ) (x : Fin n → ℝ) (c : ℝ) : ℝ :=
  -((n : ℝ) / 2) * Real.log (2 * Real.pi) - ((n : ℝ) / 2) * Real.log (σ ^ 2)
    - (1 / (2 * σ ^ 2)) * ∑ i, (x i - c) ^ 2

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 1 — con varianza impuesta `σ²`, el MLE de la media es `x̄`; la varianza
impuesta sólo entra en un término constante y no desplaza el argmax.
Fidelidad declarada: modelo normal univariado, `n` observaciones, `σ ≠ 0`. -/
theorem gauss_loglik_max {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) {σ : ℝ} (hσ : σ ≠ 0)
    (c : ℝ) : gaussLoglik σ x c ≤ gaussLoglik σ x (sampleMean x) := by
  have h1 := sse_min x hn c
  have h2 : (0 : ℝ) < 1 / (2 * σ ^ 2) := by positivity
  have h3 : (1 / (2 * σ ^ 2)) * (∑ i, (x i - sampleMean x) ^ 2)
      ≤ (1 / (2 * σ ^ 2)) * (∑ i, (x i - c) ^ 2) :=
    mul_le_mul_of_nonneg_left h1 h2.le
  simp only [gaussLoglik]
  linarith

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 2 — si la ley verdadera tiene varianza `τ²` y las observaciones son
coordenadas independientes (`Measure.pi`), la varianza de la media es `τ²/n`,
no `σ²/n` (la varianza impuesta al modelo). Prueba: `Var[(1/n)∑Xᵢ] =
(1/n)²∑Var[Xᵢ] = τ²/n`.
Fidelidad declarada: `ν` medida de probabilidad en `ℝ` con segundo momento
finito y `Var[ν] = τ²`; la independencia es la del producto `Measure.pi`. -/
theorem mean_variance_true {n : ℕ} (hn : 0 < n) {ν : Measure ℝ} [IsProbabilityMeasure ν]
    (hν : MemLp (id : ℝ → ℝ) 2 ν) {τ : ℝ} (hτ : variance (id : ℝ → ℝ) ν = τ ^ 2) :
    variance (fun ω : Fin n → ℝ => (1 / (n : ℝ)) * ∑ i, ω i)
        (Measure.pi (fun _ : Fin n => ν)) = τ ^ 2 / n := by
  have hn' : (n : ℝ) ≠ 0 := by
    have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    exact ne_of_gt this
  have hsum : variance (fun ω : Fin n → ℝ => ∑ i, ω i) (Measure.pi (fun _ : Fin n => ν))
      = ∑ _i : Fin n, variance (id : ℝ → ℝ) ν := by
    have h := variance_sum_pi (μ := fun _ : Fin n => ν)
      (X := fun (_ : Fin n) => (id : ℝ → ℝ)) (fun _ => hν)
    have hfun : (fun ω : Fin n → ℝ => ∑ i, ω i)
        = ∑ i : Fin n, fun ω : Fin n → ℝ => id (ω i) := by
      funext ω; simp [Finset.sum_apply]
    rw [hfun]
    exact h
  rw [variance_const_mul, hsum, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, hτ]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 3 — matriz sándwich en el caso escalar gaussiano: con información del
modelo impuesto `H = 1/σ²` y covarianza del score bajo la ley verdadera
`J = Var((X−m)/σ²) = τ²/σ⁴`, se tiene `J/H² = τ²` (y no `σ²`).
Fidelidad declarada: caso escalar; `Var[(X−m)/σ²]` se calcula con
`variance_const_mul` y `variance_sub_const`. -/
theorem gauss_sandwich {Ω : Type u} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    {X : Ω → ℝ} (hX : MemLp X 2 μ) {τ σ : ℝ} (hσ : σ ≠ 0) (m : ℝ)
    (hV : variance X μ = τ ^ 2) :
    variance (fun ω => (X ω - m) / σ ^ 2) μ / (1 / σ ^ 2) ^ 2 = τ ^ 2 := by
  have hcongr : (fun ω => (X ω - m) / σ ^ 2) = (fun ω => (1 / σ ^ 2) * (X ω - m)) := by
    funext ω; ring
  have h1 : variance (fun ω => (X ω - m) / σ ^ 2) μ
      = (1 / σ ^ 2) ^ 2 * variance X μ := by
    rw [hcongr, variance_const_mul, variance_sub_const hX.aestronglyMeasurable m]
  rw [h1, hV]
  have hbase : (1 : ℝ) / σ ^ 2 ≠ 0 := by
    simp [hσ]
  have hden : (1 / σ ^ 2) ^ 2 ≠ 0 := pow_ne_zero 2 hbase
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 4a — score del modelo `U(0,θ)`: `∂_θ log(1/θ) = −1/θ`, constante, luego
su media bajo la densidad `1/θ` es `−1/θ ≠ 0`: el score formal no está
centrado porque el soporte depende del parámetro.
Fidelidad declarada: la media se calcula con el funcional `Expect` (la
densidad `1/θ` sólo aporta `E[1] = 1` al ser el score constante). -/
theorem uniform_score {Ω : Type u} (P : Expect Ω) {θ : ℝ} (hθ : 0 < θ) :
    P.toFun (fun _ => -(1 / θ)) = -(1 / θ) ∧ -(1 / θ) ≠ 0 := by
  refine ⟨P.map_const _, ?_⟩
  have : (0 : ℝ) < 1 / θ := by positivity
  linarith

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 4b — frontera del razonamiento regular: con `M_n = max(X₁,…,X_n)` de
uniformes en `(0,θ)`, la CDF de `n(1 − M_n/θ)` en `t` vale `1 − (1−t/n)^n`,
cuyo límite es `1 − e^{−t}` (exponencial de media uno): el máximo converge a
escala `n`, no a escala `√n`.
Fidelidad declarada: se formaliza la identidad algebraica de la CDF
(`(θ − θt/n)/θ = 1 − t/n`) y su límite; la distribución del máximo se usa en
la forma `P(M_n ≤ x) = (x/θ)^n`, que es el cálculo elemental de la CDF. -/
theorem uniform_max_cdf_identity {θ : ℝ} (hθ : θ ≠ 0) (t : ℝ) {n : ℕ} (hn : n ≠ 0) :
    1 - ((θ - θ * (t / n)) / θ) ^ n = 1 - (1 - t / n) ^ n := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  congr 2
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1099 (key: ex:ch4-regularidad),
parte 4b (límite) — `1 − (1 − t/n)^n → 1 − e^{−t}`. -/
theorem uniform_max_cdf_tendsto (t : ℝ) :
    Tendsto (fun n : ℕ => 1 - (1 - t / ((n : ℝ) + 1)) ^ (n + 1)) atTop
      (𝓝 (1 - Real.exp (-t))) := by
  have h := Real.tendsto_one_add_div_pow_exp (-t)
  have hcomp : Tendsto (fun n : ℕ => (1 + (-t) / (((n + 1 : ℕ) : ℝ))) ^ (n + 1)) atTop
      (𝓝 (Real.exp (-t))) := by
    simpa [Function.comp_def, Nat.cast_add, Nat.cast_one] using
      h.comp (tendsto_add_atTop_nat 1)
  have hcongr : (fun n : ℕ => (1 + (-t) / (((n + 1 : ℕ) : ℝ))) ^ (n + 1))
      = fun n : ℕ => (1 - t / ((n : ℝ) + 1)) ^ (n + 1) := by
    funext n
    simp only [Nat.cast_add, Nat.cast_one]
    congr 1
    ring
  rw [hcongr] at hcomp
  simpa using hcomp.const_sub 1

/-! ## ex:ch4-ar1 — la correlación cambia el error estándar -/

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) — con
`γ_k = σ²ρ^k` y `|ρ| < 1`, la varianza de largo plazo de la media es
`τ² = γ₀ + 2∑_{k≥1} γ_k = σ²(1+ρ)/(1−ρ)`.
Fidelidad declarada: la autocovarianza `Cov(Z₀,Z_k) = σ²ρ^k` de un AR(1)
estacionario es hipótesis; se formaliza la suma geométrica y el valor. -/
theorem ar1_longrun_variance {σ2 ρ : ℝ} (hρ : |ρ| < 1) :
    σ2 * ρ ^ 0 + 2 * (∑' k : ℕ, σ2 * ρ ^ (k + 1)) = σ2 * (1 + ρ) / (1 - ρ) := by
  have hnorm : ‖ρ‖ < 1 := by simpa using hρ
  have hρ1 : ρ ≠ 1 := by
    intro h; rw [h] at hρ; norm_num at hρ
  have hgeom : (∑' k : ℕ, ρ ^ (k + 1)) = ρ * (∑' k : ℕ, ρ ^ k) := by
    rw [← tsum_mul_left]
    exact tsum_congr fun k => by rw [pow_succ, mul_comm]
  have hgeom' : (∑' k : ℕ, ρ ^ (k + 1)) = ρ / (1 - ρ) := by
    rw [hgeom, tsum_geometric_of_norm_lt_one hnorm, div_eq_mul_inv, mul_comm]
  have hshift : (∑' k : ℕ, σ2 * ρ ^ (k + 1)) = σ2 * (ρ / (1 - ρ)) := by
    rw [tsum_mul_left, hgeom']
  rw [hshift, pow_zero, div_eq_mul_inv]
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) — para
`ρ = 0.6`, `τ² = 4σ_Z²`: el error estándar de la media es asintóticamente el
doble del que supone independencia (equivalente heurístico de tamaño efectivo
`n/4`). -/
theorem ar1_tau_sq_three_fifths (σ2 : ℝ) :
    σ2 * (1 + (3 : ℝ) / 5) / (1 - (3 : ℝ) / 5) = 4 * σ2 := by
  have h1 : (1 : ℝ) + (3 : ℝ) / 5 = 8 / 5 := by norm_num
  have h2 : (1 : ℝ) - (3 : ℝ) / 5 = 2 / 5 := by norm_num
  rw [h1, h2]
  field_simp
  ring

/-! ## ex:ch4-no-parametrico — CDF empírica, kernel uniforme y órdenes -/

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico),
parte 1 — para los retornos sintéticos `(0,1,2,3,4)`, `F̂₅(2) = 3/5` sin fijar
ninguna familia de densidades. -/
theorem empirical_cdf_at_two :
    ((Finset.range 5).filter (fun i : ℕ => ((i : ℝ) ≤ 2))).card = 3 := by
  have h : (Finset.range 5).filter (fun i : ℕ => ((i : ℝ) ≤ 2))
      = (Finset.range 5).filter (fun i : ℕ => i ≤ 2) := by
    refine Finset.filter_congr fun i _ => ?_
    constructor
    · intro h1; exact_mod_cast h1
    · intro h1; exact_mod_cast h1
  rw [h]
  decide

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico),
parte 2 — kernel uniforme `f̂_h(x) = (1/(2nh))·#{|Xᵢ−x| ≤ h}` en `x = 2`:
con `h = 0.6` sólo contribuye `Xᵢ = 2` (`1/6`); con `h = 1.1` contribuyen
`1, 2, 3` (`3/11`). El ancho de banda cambia qué observaciones contribuyen. -/
theorem kernel_uniform_h_small :
    ((Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (3 : ℝ) / 5)).card = 1 := by
  have hpred : (Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (3 : ℝ) / 5)
      = (Finset.range 5).filter (fun i : ℕ => i = 2) := by
    refine Finset.filter_congr fun i hi => ?_
    simp only [Finset.mem_range] at hi
    interval_cases i <;> norm_num
  rw [hpred]
  decide

theorem kernel_uniform_h_big :
    ((Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (11 : ℝ) / 10)).card = 3 := by
  have hpred : (Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (11 : ℝ) / 10)
      = (Finset.range 5).filter (fun i : ℕ => i = 1 ∨ i = 2 ∨ i = 3) := by
    refine Finset.filter_congr fun i hi => ?_
    simp only [Finset.mem_range] at hi
    interval_cases i <;> norm_num
  rw [hpred]
  decide

/-- Los dos valores numéricos del libro: `1/(2·5·0.6) = 1/6` y
`3/(2·5·1.1) = 3/11`. -/
theorem kernel_uniform_values :
    (1 / (2 * (5 : ℝ) * ((3 : ℝ) / 5))) *
        (((Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (3 : ℝ) / 5)).card : ℝ)
      = 1 / 6 ∧
    (1 / (2 * (5 : ℝ) * ((11 : ℝ) / 10))) *
        (((Finset.range 5).filter (fun i : ℕ => |(i : ℝ) - 2| ≤ (11 : ℝ) / 10)).card : ℝ)
      = 3 / 11 := by
  rw [kernel_uniform_h_small, kernel_uniform_h_big]
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico),
parte 3 — equilibrar sesgo `h²` y desviación `1/√(nh)` motiva `h ∝ n^{−1/5}`;
entonces `h² = n^{−2/5}`, `h⁴ = n^{−4/5}` y `1/(nh) = n^{−4/5}`, de modo que
el error típico es de orden `n^{−2/5}` en una dimensión.
Fidelidad declarada: se formaliza el orden de los dos términos con la elección
`h = n^{−1/5}`; "sesgo de orden `h²`" y "varianza de orden `1/(nh)`" son las
hipótesis estándar del cálculo, no se derivan de una densidad concreta. -/
theorem kernel_rate {n : ℕ} (hn : 0 < n) :
    ((n : ℝ) ^ (-(1 : ℝ) / 5)) ^ (2 : ℕ) = (n : ℝ) ^ (-(2 : ℝ) / 5) ∧
    ((n : ℝ) ^ (-(1 : ℝ) / 5)) ^ (4 : ℕ) = (n : ℝ) ^ (-(4 : ℝ) / 5) ∧
    1 / ((n : ℝ) * (n : ℝ) ^ (-(1 : ℝ) / 5)) = (n : ℝ) ^ (-(4 : ℝ) / 5) := by
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := by positivity
  have hnpos : (0 : ℝ) < (n : ℝ) := by positivity
  refine ⟨?_, ?_, ?_⟩
  · rw [← Real.rpow_natCast, ← Real.rpow_mul hn0]; norm_num
  · rw [← Real.rpow_natCast, ← Real.rpow_mul hn0]; norm_num
  · have h1 : (n : ℝ) * (n : ℝ) ^ (-(1 : ℝ) / 5) = (n : ℝ) ^ ((4 : ℝ) / 5) := by
      calc (n : ℝ) * (n : ℝ) ^ (-(1 : ℝ) / 5)
          = (n : ℝ) ^ (1 : ℝ) * (n : ℝ) ^ (-(1 : ℝ) / 5) := by rw [Real.rpow_one]
        _ = (n : ℝ) ^ ((1 : ℝ) + (-(1 : ℝ) / 5)) := by rw [Real.rpow_add hnpos]
        _ = (n : ℝ) ^ ((4 : ℝ) / 5) := by norm_num
    rw [h1, one_div, ← Real.rpow_neg hn0]
    norm_num

/-! ## ex:ch4-bootstrap-unidad — el bootstrap ordinario del máximo -/

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad),
parte 1 — el máximo bootstrap iguala al máximo observado con probabilidad
`1 − ((n−1)/n)^n`: de `n^n` remuestras, las que evitan el índice que alcanza el
máximo son `(n−1)^n`. -/
theorem bootstrap_max_atom {n : ℕ} (hn : 0 < n) :
    1 - (((n : ℝ) - 1) / (n : ℝ)) ^ n = 1 - (1 - 1 / (n : ℝ)) ^ n := by
  have hn' : (n : ℝ) ≠ 0 := by
    have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
    exact ne_of_gt this
  congr 2
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad),
parte 2 — ese átomo tiene límite `1 − e^{−1} > 0`, mientras que la distribución
límite continua del error escalado del máximo es exponencial y sin átomos: el
bootstrap ordinario del máximo no reproduce su distribución límite. -/
theorem bootstrap_max_tendsto :
    Tendsto (fun n : ℕ => 1 - (1 - 1 / (n : ℝ)) ^ n) atTop (𝓝 (1 - Real.exp (-1))) := by
  have h := Real.tendsto_one_add_div_pow_exp (-1)
  have hcongr : (fun n : ℕ => (1 + (-1) / (n : ℝ)) ^ n) = fun n : ℕ => (1 - 1 / (n : ℝ)) ^ n := by
    funext n
    congr 1
    ring
  rw [hcongr] at h
  simpa using h.const_sub 1

/-! ## ex:ch4-if-media-cuantil — media y cuantil sin modelo paramétrico -/

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil),
parte 1 — con `φ(y) = y − ψ`, la expansión de la media muestral es exacta: los
residuos respecto de `ψ = x̄` suman cero. -/
theorem mean_if_exact {n : ℕ} (x : Fin n → ℝ) (hn : n ≠ 0) :
    (1 / (n : ℝ)) * ∑ i, (x i - sampleMean x) = 0 := by
  rw [sum_sub_sampleMean x hn, mul_zero]

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil),
parte 2 — la función de influencia del cuantil es
`φ_τ(y) = (τ − 1{y ≤ q_τ})/f(q_τ)` y su varianza límite es `τ(1−τ)/f(q_τ)²`.
Prueba: `E[φ_τ] = (τ − τ)/f = 0` y `E[φ_τ²] = (1/f²)E[(τ−1)²] =
(1/f²)(τ² − 2τ² + τ) = τ(1−τ)/f²`, usando `1{y≤q}² = 1{y≤q}`.
Fidelidad declarada: `ind` es el indicador `1{y ≤ q_τ}` como función `Ω → ℝ`
con `ind ω ∈ {0,1}`; `E[ind] = τ` es la definición de cuantil; la varianza se
calcula con el funcional abstracto `Expect` (linealidad + positividad). -/
theorem quantile_if_variance {Ω : Type u} (P : Expect Ω) {ind : Ω → ℝ}
    (hind : ∀ ω, ind ω = 0 ∨ ind ω = 1) {τ f : ℝ} (hE : P.toFun ind = τ) (hf : f ≠ 0) :
    var P (fun ω => (τ - ind ω) / f) = τ * (1 - τ) / f ^ 2 := by
  have hY : P.toFun (fun ω => (τ - ind ω) / f) = 0 := by
    have hfun : (fun ω => (τ - ind ω) / f)
        = fun ω => (1 / f) * (τ * (1 : Ω → ℝ) ω + (-1) * ind ω) := by
      funext ω
      simp only [Pi.one_apply]
      field_simp
      ring
    rw [hfun, P.map_smul, P.map_lin, P.map_one, hE]
    ring
  have hsq : (fun ω => ((τ - ind ω) / f - 0) ^ 2)
      = fun ω => (1 / f ^ 2) * (τ ^ 2 * (1 : Ω → ℝ) ω + (-(2 * τ)) * ind ω + ind ω) := by
    funext ω
    rcases hind ω with h | h
    · simp only [h, Pi.one_apply]
      field_simp
      ring
    · simp only [h, Pi.one_apply]
      field_simp
      ring
  simp only [var, hY]
  rw [hsq, P.map_smul]
  have hlin : P.toFun (fun ω => τ ^ 2 * (1 : Ω → ℝ) ω + (-(2 * τ)) * ind ω + ind ω)
      = τ ^ 2 + (-(2 * τ)) * τ + τ := by
    have hassoc : (fun ω => τ ^ 2 * (1 : Ω → ℝ) ω + (-(2 * τ)) * ind ω + ind ω)
        = (fun ω => τ ^ 2 * (1 : Ω → ℝ) ω + (-(2 * τ)) * ind ω) + ind := rfl
    rw [hassoc, P.map_add, P.map_lin, P.map_one, hE]
    ring
  rw [hlin]
  field_simp
  ring

end Cap04M6
