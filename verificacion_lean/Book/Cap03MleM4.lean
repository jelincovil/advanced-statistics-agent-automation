import Mathlib

/-!
# Book.Cap03MleM4 — cap. 3 (`capitulos/cap04_herramientas.typ`): MLE y Rao-Blackwell

Módulo del enjambre `smw9820kx`, dirección `d2 ch3-mle` (id de tablero `d13`).
Cierra las claves pendientes

* `thm:ch3-mle-propiedades` (§3),
* `ex:ch3-mle-normal` (§2),
* `ex:ch3-rb-bernoulli` (§4),

en el idioma del proyecto (`Book/Cap04Herramientas.lean`,
`Book/Cap04Suficiencia.lean`, `Book/Cap04LoteM16.lean`): enunciados
escalares/finitos, probabilidad como hipótesis explícita, y cada teorema con
su traza `book: capitulos/<fichero>.typ:<línea> (key: <clave>)` más la
fidelidad declarada.

Convención de fidelidad (la del repo): cuando el enunciado del libro es un
límite distribucional que Mathlib no tiene, se formaliza **el núcleo exacto
que el libro usa en su prueba** (la identidad algebraica o la desigualdad
analítica) y se declara en el docstring. El andamiaje común de este módulo es:

* un funcional de esperanza abstracto `Expect` (lineal, normalizado, monótono),
  el mismo idioma que `thm:ch4-bonferroni` y `ex:ch4-if-media-cuantil` usan
  para no arrastrar condiciones de integrabilidad;
* `sampleMean`, la media muestral, con las dos identidades clásicas
  (`sum_sub_sampleMean`, `sse_decomposition`).

El módulo importa sólo `Mathlib`, así que se copia tal cual a
`verificacion_lean/Book/`.
-/

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators Filter
open scoped Topology

universe u

namespace Ch3MleM4

/-! ## 0. Capa base: esperanza abstracta y media muestral -/

/-- Funcional de esperanza: lineal, normalizado y monótono. Las propiedades que
el libro da por supuestas de `EE` entran aquí como campos; así los cálculos de
sesgo y varianza no arrastran condiciones de integrabilidad. -/
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

/-- Linealidad en dos sumandos. -/
theorem map_lin (P : Expect Ω) (a b : ℝ) (f g : Ω → ℝ) :
    P.toFun (fun ω => a * f ω + b * g ω) = a * P.toFun f + b * P.toFun g := by
  have h : (fun ω => a * f ω + b * g ω) = (fun ω => a * f ω) + (fun ω => b * g ω) := rfl
  rw [h, P.map_add, P.map_smul, P.map_smul]

/-- `E[0] = 0`. -/
theorem map_zero (P : Expect Ω) : P.toFun (fun _ => (0 : ℝ)) = 0 := by
  have h := P.map_smul 0 (1 : Ω → ℝ)
  have h1 : (fun ω => (0 : ℝ) * (1 : Ω → ℝ) ω) = fun _ => (0 : ℝ) := by funext ω; simp
  rw [h1, P.map_one, zero_mul] at h
  exact h

/-- La esperanza como homomorfismo aditivo (sólo usa linealidad). -/
def toAddHom (P : Expect Ω) : (Ω → ℝ) →+ ℝ where
  toFun := P.toFun
  map_zero' := P.map_zero
  map_add' := P.map_add

/-- Linealidad de la esperanza sobre una suma finita. -/
theorem map_sum (P : Expect Ω) {ι : Type*} (s : Finset ι) (f : ι → Ω → ℝ) :
    P.toFun (∑ i ∈ s, f i) = ∑ i ∈ s, P.toFun (f i) :=
  _root_.map_sum P.toAddHom f s

/-- `E[f − g] = E[f] − E[g]`. -/
theorem map_sub (P : Expect Ω) (f g : Ω → ℝ) :
    P.toFun (fun ω => f ω - g ω) = P.toFun f - P.toFun g := by
  have h : (fun ω => f ω - g ω) = fun ω => 1 * f ω + (-1) * g ω := by
    funext ω; ring
  rw [h, P.map_lin, one_mul]
  ring

end Expect

/-- Varianza bajo un funcional de esperanza abstracto: `Var(Y) = E[(Y − E[Y])²]`. -/
noncomputable def var {Ω : Type u} (P : Expect Ω) (Y : Ω → ℝ) : ℝ :=
  P.toFun (fun ω => (Y ω - P.toFun Y) ^ 2)

/-- La varianza es no negativa. -/
theorem var_nonneg {Ω : Type u} (P : Expect Ω) (Y : Ω → ℝ) : 0 ≤ var P Y :=
  P.map_nonneg _ fun _ => sq_nonneg _

/-- Media muestral `x̄ = (∑ xᵢ)/n`. -/
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

/-! ## 1. `ex:ch3-mle-normal` — MLE para la Normal -/

/-- Suma de cuadrados residual `S = ∑(xᵢ−x̄)²` (base no enunciada). -/
noncomputable def sse0 {n : ℕ} (x : Fin n → ℝ) : ℝ := ∑ i, (x i - sampleMean x) ^ 2

/-- Log-verosimilitud de una muestra normal con media `μ` y varianza `σ2`:
`ℓ(μ,σ²) = −(n/2)log(2π) − (n/2)log σ² − (1/(2σ²))∑(xᵢ−μ)²`. -/
noncomputable def normalLogLik {n : ℕ} (x : Fin n → ℝ) (μ σ2 : ℝ) : ℝ :=
  -((n : ℝ) / 2) * Real.log (2 * Real.pi) - ((n : ℝ) / 2) * Real.log σ2
    - (1 / (2 * σ2)) * ∑ i, (x i - μ) ^ 2

/-- Log-verosimilitud perfilada en la varianza (media ya maximizada):
`ℓ(x̄, σ²) = −(n/2)log(2π) − (n/2)log σ² − S/(2σ²)`. -/
noncomputable def normalProfLik {n : ℕ} (x : Fin n → ℝ) (σ2 : ℝ) : ℝ :=
  -((n : ℝ) / 2) * Real.log (2 * Real.pi) - ((n : ℝ) / 2) * Real.log σ2
    - (1 / (2 * σ2)) * sse0 x

/-- La log-verosimilitud en `(x̄, σ²)` es la perfilada. -/
theorem normalLogLik_sampleMean {n : ℕ} (x : Fin n → ℝ) (σ2 : ℝ) :
    normalLogLik x (sampleMean x) σ2 = normalProfLik x σ2 := by
  simp only [normalLogLik, normalProfLik, sse0]

/-- book: capitulos/cap04_herramientas.typ:1086 (key: ex:ch3-mle-normal), parte 1 —
con `σ²` fijada, la log-verosimilitud normal es máxima en la media muestral:
`ℓ(μ,σ²) ≤ ℓ(x̄,σ²)`. Es la primera ecuación de verosimilitud: `μ̂_MLE = x̄`.
Prueba: `∑(xᵢ−μ)² = ∑(xᵢ−x̄)² + n(x̄−μ)²` (`sse_decomposition`) y el factor
`1/(2σ²) > 0`.
Fidelidad declarada: modelo normal univariado con `n ≥ 1` observaciones y
`σ² > 0`; se formaliza la maximalidad (el argmax), no la unicidad. -/
theorem mle_normal_mean {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) {σ2 : ℝ} (hσ : 0 < σ2)
    (μ : ℝ) : normalLogLik x μ σ2 ≤ normalLogLik x (sampleMean x) σ2 := by
  have h1 := sse_min x hn μ
  have h2 : (0 : ℝ) < 1 / (2 * σ2) := by positivity
  have h3 : (1 / (2 * σ2)) * (∑ i, (x i - sampleMean x) ^ 2)
      ≤ (1 / (2 * σ2)) * (∑ i, (x i - μ) ^ 2) := mul_le_mul_of_nonneg_left h1 h2.le
  simp only [normalLogLik]
  linarith

/-- La perfilada en el mínimo de la suma de cuadrados:
`(1/(2·(S/n)))·S = n/2`. -/
theorem inv_two_mul_sse0_div_mul_sse0 {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ)
    (hS : 0 < sse0 x) : (1 / (2 * (sse0 x / (n : ℝ)))) * sse0 x = (n : ℝ) / 2 := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1086 (key: ex:ch3-mle-normal), parte 2 —
la log-verosimilitud perfilada en `σ²` es máxima en la varianza muestral
`σ̂² = (1/n)∑(xᵢ−x̄)²`: `ℓ(x̄,σ²) ≤ ℓ(x̄,σ̂²)` para todo `σ² > 0`.
Prueba: con `a = S/(nσ²) > 0` la diferencia vale
`(n/2)(log a − a + 1) ≤ 0`, por `Real.log_le_sub_one_of_pos`.
Fidelidad declarada: `n ≥ 1`, `S > 0` (datos no constantes) y `σ² > 0`; se
formaliza la maximalidad, no la unicidad (que sólo falla en el caso `S = 0`). -/
theorem mle_normal_var {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) (hS : 0 < sse0 x)
    {σ2 : ℝ} (hσ : 0 < σ2) :
    normalProfLik x σ2 ≤ normalProfLik x (sse0 x / (n : ℝ)) := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hSn : 0 < sse0 x / (n : ℝ) := div_pos hS hn'
  have ha : 0 < sse0 x / ((n : ℝ) * σ2) := by positivity
  have hlog : Real.log (sse0 x / ((n : ℝ) * σ2)) ≤ sse0 x / ((n : ℝ) * σ2) - 1 :=
    Real.log_le_sub_one_of_pos ha
  have hsplit : Real.log (sse0 x / (n : ℝ)) - Real.log σ2
      = Real.log (sse0 x / ((n : ℝ) * σ2)) := by
    rw [← Real.log_div hSn.ne' hσ.ne']
    congr 1
    field_simp
  have hident : normalProfLik x σ2 - normalProfLik x (sse0 x / (n : ℝ))
      = ((n : ℝ) / 2) * (Real.log (sse0 x / (n : ℝ)) - Real.log σ2
          - sse0 x / ((n : ℝ) * σ2) + 1) := by
    have h1 : (1 / (2 * (sse0 x / (n : ℝ)))) * sse0 x = (n : ℝ) / 2 :=
      inv_two_mul_sse0_div_mul_sse0 hn x hS
    simp only [normalProfLik]
    rw [show (1 / (2 * (sse0 x / (n : ℝ)))) * sse0 x = (n : ℝ) / 2 from h1]
    field_simp
    ring
  have hbound : ((n : ℝ) / 2) * (Real.log (sse0 x / (n : ℝ)) - Real.log σ2
      - sse0 x / ((n : ℝ) * σ2) + 1) ≤ 0 := by
    have hbr : Real.log (sse0 x / (n : ℝ)) - Real.log σ2 - sse0 x / ((n : ℝ) * σ2) + 1 ≤ 0 := by
      rw [hsplit]; linarith
    nlinarith [hn'.le]
  linarith [hident, hbound]

/-- Varianza MLE `σ̂² = S/n` (base no enunciada). -/
noncomputable def mleVar {n : ℕ} (x : Fin n → ℝ) : ℝ := sse0 x / (n : ℝ)

/-- book: capitulos/cap04_herramientas.typ:1086 (key: ex:ch3-mle-normal), parte 3 —
el MLE de la varianza es **sesgado** con factor `(n−1)/n`:
`E[σ̂²] = ((n−1)/n)·σ²` bajo el modelo verdadero. Prueba: `n·σ̂² = S =
∑(Xᵢ−μ)² − n(X̄−μ)²` (`sse_decomposition` con `c = μ`) y linealidad de `E`
más las dos identidades de momentos estándar del muestreo iid
`E[(Xᵢ−μ)²] = σ²` y `E[(X̄−μ)²] = σ²/n` (la definición de `σ²` y la varianza de
la media; entran como hipótesis, no se re-derivan).
Fidelidad declarada: las dos identidades de momentos son hipótesis explícitas
(`h1`, `h2`), que es exactamente lo que el libro usa del muestreo iid; el
segundo momento finito y la independencia quedan encapsulados en ellas. -/
theorem mle_normal_bias {Ω : Type u} (P : Expect Ω) {n : ℕ} (hn : 0 < n)
    (X : Fin n → Ω → ℝ) {μ σ2 : ℝ}
    (h1 : ∀ i, P.toFun (fun ω => (X i ω - μ) ^ 2) = σ2)
    (h2 : P.toFun (fun ω => (sampleMean (fun i => X i ω) - μ) ^ 2) = σ2 / (n : ℝ)) :
    P.toFun (fun ω => mleVar (fun i => X i ω)) = ((n : ℝ) - 1) / (n : ℝ) * σ2 := by
  classical
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpoint : ∀ ω, mleVar (fun i => X i ω)
      = (1 / (n : ℝ)) * ((∑ i, (X i ω - μ) ^ 2)
          - (n : ℝ) * (sampleMean (fun i => X i ω) - μ) ^ 2) := by
    intro ω
    have hdec := sse_decomposition (fun i => X i ω) hn.ne' μ
    have hEq : (∑ i, (X i ω - sampleMean (fun i => X i ω)) ^ 2)
        = (∑ i, (X i ω - μ) ^ 2)
          - (n : ℝ) * ((sampleMean (fun i => X i ω) - μ) ^ 2) := by
      linarith [hdec]
    simp only [mleVar, sse0, hEq, div_eq_mul_inv]
    ring
  have hsum : P.toFun (fun ω => ∑ i, (X i ω - μ) ^ 2) = (n : ℝ) * σ2 := by
    have h := P.map_sum (Finset.univ : Finset (Fin n)) (fun i => fun ω => (X i ω - μ) ^ 2)
    have hfun : (∑ i ∈ (Finset.univ : Finset (Fin n)), fun ω => (X i ω - μ) ^ 2)
        = fun ω => ∑ i, (X i ω - μ) ^ 2 := by
      funext ω; simp
    rw [hfun] at h
    rw [h, Finset.sum_congr rfl (fun i _ => h1 i), Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
  have hmean : P.toFun (fun ω => (sampleMean (fun i => X i ω) - μ) ^ 2) = σ2 / (n : ℝ) := h2
  have hlin : P.toFun (fun ω => (∑ i, (X i ω - μ) ^ 2)
      - (n : ℝ) * (sampleMean (fun i => X i ω) - μ) ^ 2)
      = (n : ℝ) * σ2 - (n : ℝ) * (σ2 / (n : ℝ)) := by
    have hfun : (fun ω => (∑ i, (X i ω - μ) ^ 2)
        - (n : ℝ) * (sampleMean (fun i => X i ω) - μ) ^ 2)
        = fun ω => 1 * (∑ i, (X i ω - μ) ^ 2)
            + (-(n : ℝ)) * ((sampleMean (fun i => X i ω) - μ) ^ 2) := by
      funext ω; ring
    rw [hfun, P.map_lin, hsum, hmean, one_mul]
    ring
  rw [P.map_congr _ _ hpoint, P.map_smul, hlin]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1086 (key: ex:ch3-mle-normal), parte 4 —
el sesgo de `σ̂²` es `−σ²/n`: `E[σ̂²] − σ² = −σ²/n`. -/
theorem mle_normal_bias_gap {Ω : Type u} (P : Expect Ω) {n : ℕ} (hn : 0 < n)
    (X : Fin n → Ω → ℝ) {μ σ2 : ℝ} (hσ : 0 < σ2)
    (h1 : ∀ i, P.toFun (fun ω => (X i ω - μ) ^ 2) = σ2)
    (h2 : P.toFun (fun ω => (sampleMean (fun i => X i ω) - μ) ^ 2) = σ2 / (n : ℝ)) :
    P.toFun (fun ω => mleVar (fun i => X i ω)) - σ2 = -(σ2 / (n : ℝ)) := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [mle_normal_bias P hn X h1 h2]
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1086 (key: ex:ch3-mle-normal), parte 5 —
el factor de sesgo `((n−1)/n)` tiende a `1`: el sesgo desaparece y el MLE de la
varianza es **consistente** (el sesgo de orden `O(1/n)` es una de las dos piezas
de la consistencia; la otra es la ley de grandes números para `S`, que aquí
entra como la identidad de momentos `h1`). -/
theorem mle_normal_bias_factor_tendsto :
    Tendsto (fun n : ℕ => ((n : ℝ) - 1) / (n : ℝ)) atTop (nhds 1) := by
  have h1 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have h2 : Tendsto (fun n : ℕ => 1 - (1 : ℝ) / (n : ℝ)) atTop (nhds (1 - 0)) :=
    tendsto_const_nhds.sub h1
  rw [sub_zero] at h2
  refine h2.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  field_simp

/-- El MLE de la varianza es insesgado sólo si `n = 1`: para `n > 1` y `σ² ≠ 0`
el factor `(n−1)/n` no vale `1`. -/
theorem mle_normal_bias_nontrivial {n : ℕ} (hn : 1 < n) {σ2 : ℝ} (hσ : σ2 ≠ 0) :
    ((n : ℝ) - 1) / (n : ℝ) * σ2 ≠ σ2 := by
  intro h
  have hfac : ((n : ℝ) - 1) / (n : ℝ) = 1 := by
    refine mul_right_cancel₀ hσ ?_
    rw [h, one_mul]
  have hn' : (n : ℝ) ≠ 0 := by positivity
  have h2 : (n : ℝ) - 1 = (n : ℝ) := by
    have := congrArg (fun x => x * (n : ℝ)) hfac
    field_simp at this
    linarith
  have : (n : ℝ) = 1 := by linarith
  have hn1 : n = 1 := by exact_mod_cast this
  omega

/-! ## 2. `thm:ch3-mle-propiedades` — propiedades asintóticas del MLE

El libro enuncia la normalidad asintótica `√n(θ̂−θ₀) →d N(0, I₁(θ₀)⁻¹)` y
apoya la prueba en tres piezas: (i) la expansión de Taylor de la ecuación
score, (ii) el CLT aplicado al score (`thm:ch5-clt`) y la LGN aplicada al
Hessiano, (iii) Slutsky. Mathlib no tiene la convergencia en distribución que
(iii) requiere, así que —convención de fidelidad del repo— se formalizan las
piezas exactas: la identidad de la expansión (i), el paso de Slutsky en forma
de sucesiones reales junto con la **consistencia** que de él se sigue, la
**varianza asintótica** `I₁⁻¹` (que es el contenido de la conclusión una vez
fijado el límite del CLT) y la **invarianza** bajo reparametrización
biyectiva. -/

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 1 — expansión de Taylor de la ecuación score. Con datos `X : Fin n → Ω`,
score por observación `S`, derivada del score `Sd`, un máximo `θ̂` que resuelve
`∑ᵢ S(θ̂;Xᵢ) = 0` y puntos medios `θ̃ᵢ` que dan la identidad del valor medio
`∑ᵢ S(θ̂) − ∑ᵢ S(θ₀) = (θ̂−θ₀)·∑ᵢ Sd(θ̃ᵢ;Xᵢ)`, se tiene

`√n (θ̂ − θ₀) = (n^{-1/2} ∑ᵢ S(θ₀;Xᵢ)) / (−(1/n) ∑ᵢ Sd(θ̃ᵢ;Xᵢ))`,

que es la forma exacta sobre la que el libro aplica CLT (numerador) y LGN
(denominador) antes de Slutsky.
Fidelidad declarada: `n ≥ 1` y denominador no nulo (el Hessiano normalizado no
degenera). La existencia de `θ̃ᵢ` es la hipótesis `hmvt` (teorema del valor
medio aplicado término a término); no se formaliza la diferenciabilidad que la
produce. -/
theorem mle_score_expansion {n : ℕ} (hn : 0 < n) {Ω : Type u} (X : Fin n → Ω)
    (S Sd : ℝ → Ω → ℝ) {θ₀ θh : ℝ} (θt : Fin n → ℝ)
    (hroot : ∑ i, S θh (X i) = 0)
    (hmvt : ∑ i, S θh (X i) - ∑ i, S θ₀ (X i) = (θh - θ₀) * ∑ i, Sd (θt i) (X i))
    (hden : ∑ i, Sd (θt i) (X i) ≠ 0) :
    Real.sqrt n * (θh - θ₀)
      = ((Real.sqrt n)⁻¹ * ∑ i, S θ₀ (X i)) / (-(1 / (n : ℝ)) * ∑ i, Sd (θt i) (X i)) := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hsq : Real.sqrt (n : ℝ) * Real.sqrt (n : ℝ) = (n : ℝ) :=
    Real.mul_self_sqrt hn'.le
  have hsqrt : (Real.sqrt (n : ℝ)) ≠ 0 := by positivity
  -- la ecuación estimadora: `θ̂ − θ₀ = −Σ₀/D`
  have heq : θh - θ₀ = -(∑ i, S θ₀ (X i)) / ∑ i, Sd (θt i) (X i) := by
    rw [hroot, zero_sub] at hmvt
    field_simp at hmvt ⊢
    linarith [hmvt]
  rw [heq]
  field_simp
  ring_nf
  rw [sq, hsq]
  ring

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 2 — el paso de Slutsky que cierra la prueba, en forma de sucesiones
reales: si `√n(θ̂ₙ−θ₀) = Zₙ/Wₙ` con `Zₙ → z` (CLT: el score normalizado
converge) y `Wₙ → I₁ > 0` (LGN uniforme: el Hessiano normalizado converge),
entonces `√n(θ̂ₙ−θ₀) → z/I₁` y, como `1/√n → 0`, **`θ̂ₙ → θ₀`: el MLE es
consistente**.
Fidelidad declarada: el CLT y la LGN uniforme entran como las dos hipótesis de
convergencia `hZ`, `hW` (son `thm:ch5-clt` y la LGN uniforme, no se re-prueban
aquí); se formaliza el álgebra de límites que el libro atribuye a Slutsky y la
consistencia que de ella se sigue. -/
theorem mle_consistency (θh : ℕ → ℝ) (Z W : ℕ → ℝ) {Zlim I θ₀ : ℝ} (hI : I ≠ 0)
    (hrep : ∀ n : ℕ, Real.sqrt (n : ℝ) * (θh n - θ₀) = Z n / W n)
    (hZ : Tendsto Z atTop (nhds Zlim)) (hW : Tendsto W atTop (nhds I)) :
    (Tendsto (fun n : ℕ => Real.sqrt (n : ℝ) * (θh n - θ₀)) atTop (nhds (Zlim / I)))
      ∧ Tendsto θh atTop (nhds θ₀) := by
  have hratio : Tendsto (fun n : ℕ => Z n / W n) atTop (nhds (Zlim / I)) :=
    hZ.div hW hI
  have hscaled : Tendsto (fun n : ℕ => Real.sqrt (n : ℝ) * (θh n - θ₀)) atTop
      (nhds (Zlim / I)) := hratio.congr' (Filter.Eventually.of_forall fun n => (hrep n).symm)
  refine ⟨hscaled, ?_⟩
  -- `1/√n → 0` y por tanto `θ̂ − θ₀ = (1/√n)·√n(θ̂−θ₀) → 0`
  have hsqrtTop : Tendsto (fun n : ℕ => Real.sqrt (n : ℝ)) atTop atTop := by
    rw [Filter.tendsto_atTop]
    intro a
    filter_upwards [eventually_ge_atTop (⌈a ^ 2⌉₊ : ℕ)] with n hn
    exact Real.le_sqrt_of_sq_le ((Nat.le_ceil (a ^ 2)).trans (by exact_mod_cast hn))
  have hinv : Tendsto (fun n : ℕ => (Real.sqrt (n : ℝ))⁻¹) atTop (nhds 0) :=
    Tendsto.inv_tendsto_atTop hsqrtTop
  have hprod : Tendsto (fun n : ℕ => (Real.sqrt (n : ℝ))⁻¹
      * (Real.sqrt (n : ℝ) * (θh n - θ₀))) atTop (nhds (0 * (Zlim / I))) :=
    hinv.mul hscaled
  rw [zero_mul] at hprod
  have hEq : (fun n : ℕ => θ₀ + (Real.sqrt (n : ℝ))⁻¹ * (Real.sqrt (n : ℝ) * (θh n - θ₀)))
      =ᶠ[atTop] θh := by
    filter_upwards [eventually_gt_atTop (0 : ℕ)] with n hn
    have hsqrt : (Real.sqrt (n : ℝ)) ≠ 0 := by positivity
    field_simp
    ring
  have hlim : Tendsto (fun n : ℕ => θ₀ + (Real.sqrt (n : ℝ))⁻¹
      * (Real.sqrt (n : ℝ) * (θh n - θ₀))) atTop (nhds (θ₀ + 0)) :=
    tendsto_const_nhds.add hprod
  rw [add_zero] at hlim
  exact hlim.congr' hEq

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 3 — **varianza asintótica** `I₁(θ₀)⁻¹`. Es la conclusión del teorema una
vez fijado el límite del CLT: si el límite del score normalizado `Z` tiene
varianza `I₁` (bajo `P`), el límite de `√n(θ̂−θ₀)` es `Z/I₁` y su varianza es
`I₁/I₁² = I₁⁻¹`.
Fidelidad declarada: la ley límite se representa por la variable `Z` sobre el
espacio de probabilidad de la capa `Expect`, con `Var[Z] = I₁` como hipótesis
(es el contenido del CLT); se formaliza el cálculo de la varianza del cociente
por una constante, que es donde el libro escribe `N(0, I₁(θ₀)⁻¹)`. No se
formaliza la normalidad de la ley límite, sólo su varianza. -/
theorem var_const_mul {Ω : Type u} (P : Expect Ω) (c : ℝ) (Y : Ω → ℝ) :
    var P (fun ω => c * Y ω) = c ^ 2 * var P Y := by
  have hmean : P.toFun (fun ω => c * Y ω) = c * P.toFun Y := P.map_smul c Y
  unfold var
  rw [hmean]
  have hcongr : ∀ ω, (c * Y ω - c * P.toFun Y) ^ 2 = c * (c * (Y ω - P.toFun Y) ^ 2) := by
    intro ω; ring
  rw [P.map_congr _ _ hcongr, P.map_smul, P.map_smul]
  ring

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 3 (cont.) — `Var[Z/I₁] = I₁⁻¹` cuando `Var[Z] = I₁`. -/
theorem mle_asymptotic_variance {Ω : Type u} (P : Expect Ω) (Z : Ω → ℝ) {I : ℝ}
    (hI : I ≠ 0) (hvar : var P Z = I) :
    var P (fun ω => Z ω / I) = I⁻¹ := by
  have hcongr : ∀ ω, Z ω / I = I⁻¹ * Z ω := by
    intro ω; rw [div_eq_inv_mul]
  have hfun : (fun ω => Z ω / I) = fun ω => I⁻¹ * Z ω := by funext ω; exact hcongr ω
  rw [hfun, var_const_mul, hvar]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 4 — **eficiencia asintótica**: la varianza asintótica `I₁⁻¹` es
exactamente `n` veces la cota de Cramér–Rao para `n` observaciones iid
`1/(n·I₁)`, es decir, la cota se alcanza en el límite. -/
theorem mle_attains_cramer_rao {n : ℕ} (hn : 0 < n) {I : ℝ} (hI : 0 < I) :
    (n : ℝ) * (1 / ((n : ℝ) * I)) = I⁻¹ := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 5 — **invarianza** bajo reparametrización biyectiva: si `θ̂` maximiza la
verosimilitud `L` sobre `Θ`, entonces `φ(θ̂)` maximiza la verosimilitud
reparametrizada `L ∘ φ⁻¹` sobre `Θ'`.
Fidelidad declarada: sólo el caso en que `φ` es una biyección (el libro añade
que si la transformación no es inyectiva hay que maximizar la verosimilitud
perfilada; ese caso es cualitativo y no se enuncia). -/
theorem mle_invariance {Θ Θ' : Type*} (L : Θ → ℝ) (θh : Θ) (φ : Θ ≃ Θ')
    (hmax : ∀ θ, L θ ≤ L θh) :
    ∀ θ' : Θ', (fun t => L (φ.symm t)) θ' ≤ (fun t => L (φ.symm t)) (φ θh) := by
  intro θ'
  simpa using hmax (φ.symm θ')

/-- book: capitulos/cap04_herramientas.typ:1064 (key: thm:ch3-mle-propiedades),
parte 6 — **consistencia por separación del máximo poblacional** (argumento de
Wald, la ruta que el libro menciona: «una ley uniforme de grandes números y
separación del máximo poblacional»). Sea `ℓₙ` la log-verosimilitud normalizada,
`ℓ` su límite poblacional y `θ̂ₙ` un máximo de `ℓₙ`. Si
(i) `ℓ` tiene un máximo estricto aislado en `θ₀` — separación: fuera de la bola
`ε` la verosimilitud poblacional queda al menos `δ` por debajo de `ℓ(θ₀)`;
(ii) `ℓₙ → ℓ` **uniformemente** en el parámetro (ley uniforme de grandes
números), y
(iii) `ℓₙ(θ₀) ≤ ℓₙ(θ̂ₙ)` (θ̂ₙ es máximo),
entonces para todo `ε > 0` se tiene `|θ̂ₙ − θ₀| < ε` eventualmente: el MLE es
consistente.
Fidelidad declarada: la LGN uniforme y la separación entran como las
hipótesis `hunif` y `hsep`; lo formalizado es el paso de Wald que las combina
(comparación de `ℓₙ` en `θ̂ₙ` y en `θ₀` con el margen `δ/2`). -/
theorem mle_consistency_separation (ℓ : ℝ → ℝ) (ℓn : ℕ → ℝ → ℝ) (θh : ℕ → ℝ) {θ₀ : ℝ}
    (hsep : ∀ ε : ℝ, 0 < ε → ∃ δ : ℝ, 0 < δ ∧ ∀ θ : ℝ, ε ≤ |θ - θ₀| → ℓ θ ≤ ℓ θ₀ - δ)
    (hunif : ∀ δ : ℝ, 0 < δ → ∀ᶠ n : ℕ in atTop, ∀ θ : ℝ, |ℓn n θ - ℓ θ| < δ)
    (hmax : ∀ n, ℓn n θ₀ ≤ ℓn n (θh n)) :
    ∀ ε : ℝ, 0 < ε → ∀ᶠ n : ℕ in atTop, |θh n - θ₀| < ε := by
  intro ε hε
  obtain ⟨δ, hδpos, hδ⟩ := hsep ε hε
  filter_upwards [hunif (δ / 2) (by positivity)] with n hn
  by_contra hcon
  have hout : ε ≤ |θh n - θ₀| := not_lt.mp hcon
  have h1 : ℓn n (θh n) ≤ ℓ (θh n) + δ / 2 := by
    have := (abs_lt.mp (hn (θh n))).2
    linarith
  have h2 : ℓ θ₀ - δ / 2 < ℓn n θ₀ := by
    have := (abs_lt.mp (hn θ₀)).1
    linarith
  have h3 := hδ (θh n) hout
  linarith [hmax n]

/-! ## 3. `ex:ch3-rb-bernoulli` — Rao-Blackwellización en Bernoulli

Modelo: `n` ensayos Bernoulli(θ) iid, representados por el conjunto de éxitos
`s : Finset (Fin n)` con peso `w_θ(s) = θ^{#s}(1−θ)^{n−#s}` (el producto de
las densidades coordenada a coordenada). El estimador inicial es el indicador
del primer ensayo `X₁(s) = 1{0 ∈ s}`, el estadístico suficiente es
`T(s) = #s`, y la Rao-Blackwellización es `E[X₁|T] = T/n`. -/

/-- Peso del conjunto de éxitos `s`: `w_θ(s) = θ^{#s}(1−θ)^{n−#s}`, escrito
como producto sobre `s` y su complemento (la factorización por el estadístico
suficiente es entonces inmediata). -/
noncomputable def bernW {n : ℕ} (θ : ℝ) (s : Finset (Fin n)) : ℝ :=
  (∏ i ∈ s, θ) * (∏ i ∈ (Finset.univ : Finset (Fin n)) \ s, (1 - θ))

/-- El peso depende del dato sólo a través del estadístico suficiente:
`w_θ(s) = θ^{T(s)}(1−θ)^{n−T(s)}` con `T(s) = #s`. Es la **factorización de
Neyman** que hace de `T` un estadístico suficiente. -/
theorem bernW_eq {n : ℕ} (θ : ℝ) (s : Finset (Fin n)) :
    bernW θ s = θ ^ s.card * (1 - θ) ^ (n - s.card) := by
  have h1 : (∏ i ∈ s, θ) = θ ^ s.card := Finset.prod_const θ
  have h2 : (∏ i ∈ (Finset.univ : Finset (Fin n)) \ s, (1 - θ))
      = (1 - θ) ^ #((Finset.univ : Finset (Fin n)) \ s) := Finset.prod_const (1 - θ)
  have h3 : #((Finset.univ : Finset (Fin n)) \ s) = n - s.card := by
    rw [Finset.card_sdiff, Finset.inter_univ, Finset.card_univ, Fintype.card_fin]
  rw [bernW, h1, h2, h3]

/-- La masa total es uno: `∑_s w_θ(s) = 1` (teorema del binomio). -/
theorem bernW_sum_one {n : ℕ} (θ : ℝ) :
    ∑ s : Finset (Fin n), bernW θ s = 1 := by
  have h := Finset.prod_add (fun _ : Fin n => θ) (fun _ => 1 - θ)
    (Finset.univ : Finset (Fin n))
  rw [Finset.powerset_univ] at h
  have hleft : (∏ i ∈ (Finset.univ : Finset (Fin n)), (θ + (1 - θ))) = 1 := by
    trans ∏ i ∈ (Finset.univ : Finset (Fin n)), (1 : ℝ)
    · exact Finset.prod_congr rfl (fun i _ => by ring)
    · exact Finset.prod_const_one
  rw [hleft] at h
  exact h.symm

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 1 —
el estimador inicial `X₁` (indicador del primer ensayo) es insesgado para `θ`:
`E_θ[X₁] = θ`.
Prueba: `Finset.prod_add` con el factor `1−θ` sustituido por `0` en la
coordenada `i`; el miembro izquierdo vale `θ·1··1 = θ` y el derecho es la suma
sobre los conjuntos que contienen `i` (los demás términos se anulan).
Fidelidad declarada: modelo discreto finito (conjunto de éxitos); θ real, sin
restricción en esta identidad (la probabilidad se usa en `bernW_sum_one`). -/
theorem bern_moment_single {n : ℕ} (θ : ℝ) (i : Fin n) :
    ∑ s : Finset (Fin n), (if i ∈ s then (1 : ℝ) else 0) * bernW θ s = θ := by
  have h := Finset.prod_add (fun _ : Fin n => θ)
    (fun k => if k = i then (0 : ℝ) else 1 - θ) (Finset.univ : Finset (Fin n))
  rw [Finset.powerset_univ] at h
  have hleft : (∏ k ∈ (Finset.univ : Finset (Fin n)), (θ + (if k = i then (0 : ℝ) else 1 - θ)))
      = θ := by
    rw [← Finset.mul_prod_erase (Finset.univ : Finset (Fin n))
      (fun k => θ + (if k = i then (0 : ℝ) else 1 - θ)) (Finset.mem_univ i)]
    rw [if_pos rfl, add_zero]
    have hone : (∏ x ∈ (Finset.univ : Finset (Fin n)).erase i,
        (θ + (if x = i then (0 : ℝ) else 1 - θ))) = 1 := by
      refine Finset.prod_eq_one (fun x hx => ?_)
      have hx1 : x ≠ i := (Finset.mem_erase.mp hx).1
      rw [if_neg hx1]
      ring
    rw [hone, mul_one]
  have hrw : ∀ t ∈ (Finset.univ : Finset (Finset (Fin n))),
      (∏ k ∈ t, θ) * (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
          (if k = i then (0 : ℝ) else 1 - θ))
        = (if i ∈ t then (1 : ℝ) else 0) * bernW θ t := by
    intro t _
    by_cases hi : i ∈ t
    · have hstep : (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
          (if k = i then (0 : ℝ) else 1 - θ))
          = ∏ k ∈ (Finset.univ : Finset (Fin n)) \ t, (1 - θ) := by
        refine Finset.prod_congr rfl (fun k hk => ?_)
        have hki : k ≠ i := fun h => (Finset.mem_sdiff.mp hk).2 (h ▸ hi)
        rw [if_neg hki]
      rw [hstep, if_pos hi, one_mul]
      rfl
    · have hzero : (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
          (if k = i then (0 : ℝ) else 1 - θ)) = 0 := by
        refine Finset.prod_eq_zero (i := i) (Finset.mem_sdiff.mpr ⟨Finset.mem_univ i, hi⟩) ?_
        rw [if_pos rfl]
      rw [hzero, mul_zero, if_neg hi, zero_mul]
  have hsum : (∑ t ∈ (Finset.univ : Finset (Finset (Fin n))),
      (∏ k ∈ t, θ) * (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
        (if k = i then (0 : ℝ) else 1 - θ)))
      = ∑ s : Finset (Fin n), (if i ∈ s then (1 : ℝ) else 0) * bernW θ s :=
    Finset.sum_congr rfl hrw
  rw [hleft, hsum] at h
  exact h.symm

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 2 —
el momento cruzado de dos ensayos distintos: `E_θ[XᵢXⱼ] = θ²` para `i ≠ j`
(independencia entre coordenadas). Es la pieza que da `Var(T) = nθ(1−θ)`. -/
theorem bern_moment_pair {n : ℕ} (θ : ℝ) {i j : Fin n} (hij : i ≠ j) :
    ∑ s : Finset (Fin n), (if i ∈ s ∧ j ∈ s then (1 : ℝ) else 0) * bernW θ s = θ ^ 2 := by
  have h := Finset.prod_add (fun _ : Fin n => θ)
    (fun k => if k = i ∨ k = j then (0 : ℝ) else 1 - θ) (Finset.univ : Finset (Fin n))
  rw [Finset.powerset_univ] at h
  have hleft : (∏ k ∈ (Finset.univ : Finset (Fin n)),
      (θ + (if k = i ∨ k = j then (0 : ℝ) else 1 - θ))) = θ ^ 2 := by
    rw [← Finset.mul_prod_erase (Finset.univ : Finset (Fin n))
      (fun k => θ + (if k = i ∨ k = j then (0 : ℝ) else 1 - θ)) (Finset.mem_univ i)]
    rw [if_pos (Or.inl rfl), add_zero]
    rw [← Finset.mul_prod_erase ((Finset.univ : Finset (Fin n)).erase i)
      (fun k => θ + (if k = i ∨ k = j then (0 : ℝ) else 1 - θ))
      (Finset.mem_erase.mpr ⟨hij.symm, Finset.mem_univ j⟩)]
    rw [if_pos (Or.inr rfl), add_zero]
    have hone : (∏ x ∈ ((Finset.univ : Finset (Fin n)).erase i).erase j,
        (θ + (if x = i ∨ x = j then (0 : ℝ) else 1 - θ))) = 1 := by
      refine Finset.prod_eq_one (fun x hx => ?_)
      have hx1 : x ≠ j := (Finset.mem_erase.mp hx).1
      have hx2 : x ≠ i := (Finset.mem_erase.mp (Finset.mem_erase.mp hx).2).1
      rw [if_neg (by simp [hx1, hx2])]
      ring
    rw [hone, mul_one]
    ring
  have hrw : ∀ t ∈ (Finset.univ : Finset (Finset (Fin n))),
      (∏ k ∈ t, θ) * (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
          (if k = i ∨ k = j then (0 : ℝ) else 1 - θ))
        = (if i ∈ t ∧ j ∈ t then (1 : ℝ) else 0) * bernW θ t := by
    intro t _
    by_cases hi : i ∈ t
    · by_cases hj : j ∈ t
      · have hstep : (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
            (if k = i ∨ k = j then (0 : ℝ) else 1 - θ))
            = ∏ k ∈ (Finset.univ : Finset (Fin n)) \ t, (1 - θ) := by
          refine Finset.prod_congr rfl (fun k hk => ?_)
          have hk1 : k ≠ i := fun h => (Finset.mem_sdiff.mp hk).2 (h ▸ hi)
          have hk2 : k ≠ j := fun h => (Finset.mem_sdiff.mp hk).2 (h ▸ hj)
          rw [if_neg (by simp [hk1, hk2])]
        rw [hstep, if_pos ⟨hi, hj⟩, one_mul]
        rfl
      · have hzero : (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
            (if k = i ∨ k = j then (0 : ℝ) else 1 - θ)) = 0 := by
          refine Finset.prod_eq_zero (i := j) (Finset.mem_sdiff.mpr ⟨Finset.mem_univ j, hj⟩) ?_
          rw [if_pos (Or.inr rfl)]
        rw [hzero, mul_zero, if_neg (fun h => hj h.2), zero_mul]
    · have hzero : (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
          (if k = i ∨ k = j then (0 : ℝ) else 1 - θ)) = 0 := by
        refine Finset.prod_eq_zero (i := i) (Finset.mem_sdiff.mpr ⟨Finset.mem_univ i, hi⟩) ?_
        rw [if_pos (Or.inl rfl)]
      rw [hzero, mul_zero, if_neg (fun h => hi h.1), zero_mul]
  have hsum : (∑ t ∈ (Finset.univ : Finset (Finset (Fin n))),
      (∏ k ∈ t, θ) * (∏ k ∈ (Finset.univ : Finset (Fin n)) \ t,
        (if k = i ∨ k = j then (0 : ℝ) else 1 - θ)))
      = ∑ s : Finset (Fin n), (if i ∈ s ∧ j ∈ s then (1 : ℝ) else 0) * bernW θ s :=
    Finset.sum_congr rfl hrw
  rw [hleft, hsum] at h
  exact h.symm

/-- El estadístico suficiente `T`: número de éxitos `T(s) = #s`. -/
noncomputable def bernT {n : ℕ} (s : Finset (Fin n)) : ℝ := (s.card : ℝ)

/-- `#s` como suma de indicadores de pertenencia. -/
theorem bern_card_eq_sum {n : ℕ} (s : Finset (Fin n)) :
    (s.card : ℝ) = ∑ i : Fin n, (if i ∈ s then (1 : ℝ) else 0) := by
  have h := Finset.sum_boole (R := ℝ) (p := fun i : Fin n => i ∈ s)
    (Finset.univ : Finset (Fin n))
  rw [Finset.filter_univ_mem] at h
  exact h.symm

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 3 —
`E_θ[T] = nθ` para el número de éxitos `T = ∑ᵢ Xᵢ` (linealidad de la esperanza y
`E_θ[Xᵢ] = θ`). -/
theorem bern_mean_T {n : ℕ} (θ : ℝ) :
    ∑ s : Finset (Fin n), bernT s * bernW θ s = (n : ℝ) * θ := by
  have h : ∀ s : Finset (Fin n), bernT s * bernW θ s
      = ∑ i : Fin n, (if i ∈ s then (1 : ℝ) else 0) * bernW θ s := by
    intro s
    rw [bernT, bern_card_eq_sum, Finset.sum_mul]
  calc ∑ s : Finset (Fin n), bernT s * bernW θ s
      = ∑ s : Finset (Fin n), ∑ i : Fin n,
          (if i ∈ s then (1 : ℝ) else 0) * bernW θ s := Finset.sum_congr rfl (fun s _ => h s)
    _ = ∑ i : Fin n, ∑ s : Finset (Fin n),
          (if i ∈ s then (1 : ℝ) else 0) * bernW θ s := Finset.sum_comm
    _ = ∑ _i : Fin n, θ := Finset.sum_congr rfl (fun i _ => bern_moment_single θ i)
    _ = (n : ℝ) * θ := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- `T(s)²` como suma doble de indicadores. -/
theorem bern_sq_card {n : ℕ} (s : Finset (Fin n)) :
    (bernT s) ^ 2 = ∑ i : Fin n, ∑ j : Fin n,
      (if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0) := by
  rw [bernT, bern_card_eq_sum, sq, Finset.sum_mul_sum]

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 4 —
`E_θ[T²] = nθ + n(n−1)θ²`: la suma doble de indicadores se parte en el término
diagonal (`E[Xᵢ] = θ`) y los `n(n−1)` términos cruzados (`E[XᵢXⱼ] = θ²`). -/
theorem bern_mean_T_sq {n : ℕ} (hn : 0 < n) (θ : ℝ) :
    ∑ s : Finset (Fin n), (bernT s) ^ 2 * bernW θ s
      = (n : ℝ) * θ + (n : ℝ) * ((n : ℝ) - 1) * θ ^ 2 := by
  have h : ∀ s : Finset (Fin n), (bernT s) ^ 2 * bernW θ s
      = ∑ i : Fin n, ∑ j : Fin n,
          ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s := by
    intro s
    rw [bern_sq_card]
    simp only [Finset.sum_mul]
  have hinner : ∀ i : Fin n, (∑ j : Fin n, ∑ s : Finset (Fin n),
      ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s)
      = θ + ((n : ℝ) - 1) * θ ^ 2 := by
    intro i
    rw [← Finset.add_sum_erase (Finset.univ : Finset (Fin n))
      (fun j => ∑ s : Finset (Fin n),
        ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s)
      (Finset.mem_univ i)]
    have hdiag : (∑ s : Finset (Fin n),
        ((if i ∈ s then (1 : ℝ) else 0) * (if i ∈ s then (1 : ℝ) else 0)) * bernW θ s) = θ := by
      calc (∑ s : Finset (Fin n),
          ((if i ∈ s then (1 : ℝ) else 0) * (if i ∈ s then (1 : ℝ) else 0)) * bernW θ s)
          = ∑ s : Finset (Fin n), (if i ∈ s then (1 : ℝ) else 0) * bernW θ s := by
            refine Finset.sum_congr rfl (fun s _ => ?_)
            by_cases hi : i ∈ s <;> simp [hi]
        _ = θ := bern_moment_single θ i
    have hoff : (∑ j ∈ (Finset.univ : Finset (Fin n)).erase i, ∑ s : Finset (Fin n),
        ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s)
        = ((n : ℝ) - 1) * θ ^ 2 := by
      have hconst : ∀ j ∈ (Finset.univ : Finset (Fin n)).erase i,
          (∑ s : Finset (Fin n),
            ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s)
            = θ ^ 2 := by
        intro j hj
        have hji : j ≠ i := (Finset.mem_erase.mp hj).1
        rw [← bern_moment_pair θ (i := i) (j := j) hji.symm]
        refine Finset.sum_congr rfl (fun s _ => ?_)
        by_cases hi : i ∈ s <;> by_cases hj' : j ∈ s <;> simp [hi, hj']
      rw [Finset.sum_congr rfl hconst, Finset.sum_const,
        Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin,
        nsmul_eq_mul]
      congr 1
      rw [Nat.cast_sub (by omega : 1 ≤ n)]
      norm_num
    rw [hdiag, hoff]
  calc ∑ s : Finset (Fin n), (bernT s) ^ 2 * bernW θ s
      = ∑ s : Finset (Fin n), ∑ i : Fin n, ∑ j : Fin n,
          ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s :=
        Finset.sum_congr rfl (fun s _ => h s)
    _ = ∑ i : Fin n, ∑ j : Fin n, ∑ s : Finset (Fin n),
          ((if i ∈ s then (1 : ℝ) else 0) * (if j ∈ s then (1 : ℝ) else 0)) * bernW θ s := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl (fun i _ => Finset.sum_comm)
    _ = ∑ _i : Fin n, (θ + ((n : ℝ) - 1) * θ ^ 2) :=
        Finset.sum_congr rfl (fun i _ => hinner i)
    _ = (n : ℝ) * θ + (n : ℝ) * ((n : ℝ) - 1) * θ ^ 2 := by
        rw [Finset.sum_add_distrib, Finset.sum_const, Finset.sum_const, Finset.card_univ,
          Fintype.card_fin, nsmul_eq_mul, nsmul_eq_mul]
        ring

/-- La esperanza bajo los pesos de Bernoulli: `E_θ[f] = ∑_s f(s)·w_θ(s)`. -/
noncomputable def bernExpect {n : ℕ} (θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    Expect (Finset (Fin n)) where
  toFun f := ∑ s, bernW θ s * f s
  map_one := by
    have h : (∑ s : Finset (Fin n), bernW θ s * (1 : Finset (Fin n) → ℝ) s)
        = ∑ s : Finset (Fin n), bernW θ s :=
      Finset.sum_congr rfl (fun s _ => by simp)
    rw [h, bernW_sum_one]
  map_add f g := by
    have h : (∑ s : Finset (Fin n), bernW θ s * (f + g) s)
        = ∑ s : Finset (Fin n), (bernW θ s * f s + bernW θ s * g s) :=
      Finset.sum_congr rfl (fun s _ => by simp only [Pi.add_apply]; ring)
    rw [h, Finset.sum_add_distrib]
  map_smul c f := by
    have h : (∑ s : Finset (Fin n), bernW θ s * (c * f s))
        = ∑ s : Finset (Fin n), c * (bernW θ s * f s) :=
      Finset.sum_congr rfl (fun s _ => by ring)
    rw [h, ← Finset.mul_sum]
  map_congr f g hfg := by
    exact Finset.sum_congr rfl (fun s _ => by rw [hfg s])
  map_nonneg f hf := by
    refine Finset.sum_nonneg (fun s _ => mul_nonneg ?_ (hf s))
    rw [bernW_eq]
    exact mul_nonneg (pow_nonneg hθ0 _) (pow_nonneg (by linarith) _)

/-- `Var[Y] = E[Y²] − E[Y]²` bajo un funcional de esperanza abstracto (base no
enunciada; sólo usa linealidad). -/
theorem var_eq {Ω : Type u} (P : Expect Ω) (Y : Ω → ℝ) :
    var P Y = P.toFun (fun ω => Y ω ^ 2) - (P.toFun Y) ^ 2 := by
  have hcongr : (fun ω => (Y ω - P.toFun Y) ^ 2)
      = fun ω => (1 * (Y ω ^ 2) + (-(2 * P.toFun Y)) * Y ω) + (P.toFun Y) ^ 2 := by
    funext ω; ring
  have hsplit : (fun ω => (1 * (Y ω ^ 2) + (-(2 * P.toFun Y)) * Y ω) + (P.toFun Y) ^ 2)
      = (fun ω => 1 * (Y ω ^ 2) + (-(2 * P.toFun Y)) * Y ω) + (fun _ => (P.toFun Y) ^ 2) :=
    rfl
  rw [var, hcongr, hsplit, P.map_add, P.map_lin, P.map_const]
  ring

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 5 —
`Var_θ(X₁) = θ(1−θ)`: como `X₁` es un indicador, `X₁² = X₁` y la varianza es
`E[X₁] − E[X₁]² = θ − θ²`. -/
theorem bern_var_X1 {n : ℕ} (θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) (i₀ : Fin n) :
    var (bernExpect (n := n) θ hθ0 hθ1) (fun s => if i₀ ∈ s then (1 : ℝ) else 0)
      = θ * (1 - θ) := by
  have h1 : (bernExpect (n := n) θ hθ0 hθ1).toFun
      (fun s => (if i₀ ∈ s then (1 : ℝ) else 0) ^ 2)
      = (bernExpect (n := n) θ hθ0 hθ1).toFun (fun s => if i₀ ∈ s then (1 : ℝ) else 0) := by
    refine (bernExpect (n := n) θ hθ0 hθ1).map_congr _ _ (fun s => ?_)
    by_cases h : i₀ ∈ s <;> simp [h]
  have h2 : (bernExpect (n := n) θ hθ0 hθ1).toFun (fun s => if i₀ ∈ s then (1 : ℝ) else 0) = θ := by
    show (∑ s : Finset (Fin n), bernW θ s * (if i₀ ∈ s then (1 : ℝ) else 0)) = θ
    calc (∑ s : Finset (Fin n), bernW θ s * (if i₀ ∈ s then (1 : ℝ) else 0))
        = ∑ s : Finset (Fin n), (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s :=
          Finset.sum_congr rfl (fun s _ => by ring)
      _ = θ := bern_moment_single θ i₀
  rw [var_eq, h1, h2]
  ring

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 6 —
`Var_θ(T) = nθ(1−θ)`: de `E[T²] = nθ + n(n−1)θ²` y `E[T] = nθ`.
Fidelidad declarada: la independencia entre ensayos entra vía
`E[XᵢXⱼ] = θ²` (`bern_moment_pair`), no como hipótesis independiente. -/
theorem bern_var_T {n : ℕ} (hn : 0 < n) (θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    var (bernExpect (n := n) θ hθ0 hθ1) (bernT (n := n)) = (n : ℝ) * θ * (1 - θ) := by
  have h2 : (bernExpect (n := n) θ hθ0 hθ1).toFun (fun s => (bernT s) ^ 2)
      = (n : ℝ) * θ + (n : ℝ) * ((n : ℝ) - 1) * θ ^ 2 := by
    show (∑ s : Finset (Fin n), bernW θ s * (bernT s) ^ 2) = _
    calc (∑ s : Finset (Fin n), bernW θ s * (bernT s) ^ 2)
        = ∑ s : Finset (Fin n), (bernT s) ^ 2 * bernW θ s :=
          Finset.sum_congr rfl (fun s _ => by ring)
      _ = _ := bern_mean_T_sq hn θ
  have h1 : (bernExpect (n := n) θ hθ0 hθ1).toFun (bernT (n := n)) = (n : ℝ) * θ := by
    show (∑ s : Finset (Fin n), bernW θ s * bernT s) = _
    calc (∑ s : Finset (Fin n), bernW θ s * bernT s)
        = ∑ s : Finset (Fin n), bernT s * bernW θ s :=
          Finset.sum_congr rfl (fun s _ => by ring)
      _ = _ := bern_mean_T (n := n) θ
  rw [var_eq, h2, h1]
  ring

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 7 —
**la Rao-Blackwellización reduce la varianza por el factor `n`**: con
`p̃ = T/n = X̄` se tiene `Var_θ(p̃) = θ(1−θ)/n = Var_θ(X₁)/n`.
Fidelidad declarada: `T/n = X̄` es la media muestral. La identificación
`p̃ = E_θ[X₁|T]` (la propiedad caracterizante `E[X₁u(T)] = E[(T/n)u(T)]` para
toda `u`) **no** se formaliza aquí: exigiría el recuento de la razón
`C(n−1,t−1)/C(n,t) = t/n` en cada fibra de `T`, que es contenido combinatorio
independiente del cálculo de varianzas. Lo formalizado es la parte
cuantitativa del ejemplo: insesgadez de ambos estimadores y la reducción
exacta de varianza por el factor `n`. -/
theorem bern_var_Tdiv {n : ℕ} (hn : 0 < n) (θ : ℝ) (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    var (bernExpect (n := n) θ hθ0 hθ1) (fun s => bernT s / (n : ℝ)) = θ * (1 - θ) / (n : ℝ) := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hfun : (fun s : Finset (Fin n) => bernT s / (n : ℝ))
      = fun s => (n : ℝ)⁻¹ * bernT s := by
    funext s; rw [div_eq_inv_mul]
  rw [hfun, var_const_mul, bern_var_T hn θ hθ0 hθ1]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 8 —
la comparación de varianzas del ejemplo: `Var(p̃) = Var(X₁)/n ≤ Var(X₁)`. -/
theorem bern_rb_variance_improves {n : ℕ} (hn : 0 < n) (θ : ℝ) (hθ0 : 0 ≤ θ)
    (hθ1 : θ ≤ 1) (i₀ : Fin n) :
    var (bernExpect (n := n) θ hθ0 hθ1) (fun s => bernT s / (n : ℝ))
        = var (bernExpect (n := n) θ hθ0 hθ1) (fun s => if i₀ ∈ s then (1 : ℝ) else 0) / (n : ℝ)
      ∧ var (bernExpect (n := n) θ hθ0 hθ1) (fun s => bernT s / (n : ℝ))
        ≤ var (bernExpect (n := n) θ hθ0 hθ1) (fun s => if i₀ ∈ s then (1 : ℝ) else 0) := by
  have hT := bern_var_Tdiv hn θ hθ0 hθ1
  have hX := bern_var_X1 θ hθ0 hθ1 i₀
  have hnn : 0 ≤ θ * (1 - θ) := mul_nonneg hθ0 (by linarith)
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  constructor
  · rw [hT, hX]
  · rw [hT, hX]
    calc θ * (1 - θ) / (n : ℝ) ≤ θ * (1 - θ) / 1 :=
          div_le_div_of_nonneg_left hnn one_pos hn1
      _ = θ * (1 - θ) := by ring

/-- book: capitulos/cap04_herramientas.typ:910 (key: ex:ch3-rb-bernoulli), parte 9 —
**identificación de la Rao-Blackwellización**: para toda función `u` del
estadístico suficiente `T = #s` se tiene

`E_θ[X₁·u(T)] = E_θ[(T/n)·u(T)]`,

que es la propiedad caracterizante de `E_θ[X₁|T] = T/n` (en espacio finito
finito, equivalente a la igualdad casi segura).
Prueba: por simetría de coordenadas la permutación `swap 0 i` conserva el peso
(`bernW_eq` sólo depende de `T = #s`), de modo que `E_θ[Xᵢu(T)]` no depende de
`i`; sumando sobre `i` y usando `∑ᵢ 1{i ∈ s} = #s = T(s)` (`bern_card_eq_sum`)
resulta `E_θ[(T/n)u(T)]`.
Fidelidad declarada: la esperanza condicional se caracteriza por sus tests
`u(T)`; no se construye la versión regular de la teoría de la medida. -/
theorem bern_cond_exp {n : ℕ} (hn : 0 < n) (θ : ℝ) (i₀ : Fin n) (u : ℕ → ℝ) :
    ∑ s : Finset (Fin n), u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s
      = ∑ s : Finset (Fin n), u s.card * ((s.card : ℝ) / (n : ℝ)) * bernW θ s := by
  classical
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hnn : (n : ℝ) ≠ 0 := hn'.ne'
  -- simetría de coordenadas: el peso y `T` sólo dependen de `#s`
  have hsym : ∀ i : Fin n, (∑ s : Finset (Fin n),
        u s.card * (if i ∈ s then (1 : ℝ) else 0) * bernW θ s)
      = ∑ s : Finset (Fin n), u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s := by
    intro i
    have hcomp := Equiv.sum_comp (Equiv.swap i₀ i).finsetCongr
      (fun s : Finset (Fin n) => u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s)
    rw [hcomp.symm]
    refine Finset.sum_congr rfl (fun s _ => ?_)
    have hcard : ((Equiv.swap i₀ i).finsetCongr s).card = s.card := by
      rw [Equiv.finsetCongr_apply, Finset.card_map]
    have hmem : i₀ ∈ (Equiv.swap i₀ i).finsetCongr s ↔ i ∈ s := by
      rw [Equiv.finsetCongr_apply, Finset.mem_map_equiv, Equiv.symm_swap,
        Equiv.swap_apply_left]
    have hw : bernW θ ((Equiv.swap i₀ i).finsetCongr s) = bernW θ s := by
      rw [bernW_eq, bernW_eq, hcard]
    by_cases hi : i ∈ s
    · have hi' : i₀ ∈ (Equiv.swap i₀ i).finsetCongr s := hmem.mpr hi
      rw [hcard, hw, if_pos hi', if_pos hi]
    · have hi' : i₀ ∉ (Equiv.swap i₀ i).finsetCongr s := fun h => hi (hmem.mp h)
      rw [hcard, hw, if_neg hi', if_neg hi]
  -- suma sobre las coordenadas
  have hstep : (∑ i : Fin n, ∑ s : Finset (Fin n),
        u s.card * (if i ∈ s then (1 : ℝ) else 0) * bernW θ s)
      = (n : ℝ) * (∑ s : Finset (Fin n),
          u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s) := by
    rw [show (∑ i : Fin n, ∑ s : Finset (Fin n),
        u s.card * (if i ∈ s then (1 : ℝ) else 0) * bernW θ s)
        = ∑ _i : Fin n, (∑ s : Finset (Fin n),
          u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s) from
      Finset.sum_congr rfl (fun i _ => hsym i)]
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  calc ∑ s : Finset (Fin n), u s.card * (if i₀ ∈ s then (1 : ℝ) else 0) * bernW θ s
      = (1 / (n : ℝ)) * (∑ i : Fin n, ∑ s : Finset (Fin n),
          u s.card * (if i ∈ s then (1 : ℝ) else 0) * bernW θ s) := by
        rw [hstep]
        field_simp
    _ = (1 / (n : ℝ)) * ∑ s : Finset (Fin n), ∑ i : Fin n,
          u s.card * (if i ∈ s then (1 : ℝ) else 0) * bernW θ s := by
        rw [Finset.sum_comm]
    _ = (1 / (n : ℝ)) * ∑ s : Finset (Fin n),
          u s.card * (s.card : ℝ) * bernW θ s := by
        congr 1
        refine Finset.sum_congr rfl (fun s _ => ?_)
        have hc : (∑ i : Fin n, (if i ∈ s then (1 : ℝ) else 0)) = (s.card : ℝ) :=
          (bern_card_eq_sum s).symm
        rw [← hc, Finset.mul_sum, Finset.sum_mul]
    _ = ∑ s : Finset (Fin n), u s.card * ((s.card : ℝ) / (n : ℝ)) * bernW θ s := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl (fun s _ => ?_)
        field_simp

end Ch3MleM4
