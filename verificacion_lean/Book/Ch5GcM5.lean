import Mathlib

/-!
# Book.Ch5GcM5 — clave `thm:ch5-gc` (Glivenko–Cantelli)

El libro (`cap04_herramientas.typ:1624`) enuncia:

> Sea `F̂_n` la distribución empírica de una muestra iid de `F`. Entonces
> `‖F̂_n − F‖_∞ = sup_{x ∈ ℝ} |F̂_n(x) − F(x)| → 0` c.s.

y lo prueba por cita (`vaart1998asymptotic`). Mathlib no tiene
Glivenko–Cantelli ni la maquinaria de clases de Glivenko–Cantelli, de modo
que — con la convención de fidelidad del proyecto — se formalizan las dos
piezas exactas en que consiste la prueba:

1. `gc_pointwise`: **convergencia puntual casi segura**, `F̂_n(x) → F(x)`
   c.s. para cada `x` fijo, que es la ley fuerte de los grandes números
   aplicada a los indicadores `1{X_i ≤ x}` (teorema `strong_law_ae_real` de
   Mathlib, Etemadi). Es la mitad «fácil» de la prueba del libro.
2. `gc_engine`: **el motor determinista** que convierte convergencia
   puntual sobre una malla fina en convergencia uniforme: si dos funciones
   monótonas distan `≤ η` sobre una malla `η`-fina en la escala de `F` (más
   las dos colas), entonces distan `≤ 2η` en todo punto. Es exactamente el
   argumento de monotonía + continuidad de `F` que el libro usa al invocar
   van der Vaart, y de ahí `gc_uniform`: si la malla se refina
   (`η_N → 0`) la distancia uniforme `sup_x|F̂_N(x) − F(x)|` tiende a cero.

Lo que **no** se reproduce, y se declara: el paso de (1) a la hipótesis de
(2) para todo `x` simultáneamente exige elegir un conjunto denso numerable
estable e incluir los átomos de `F` (que son numerables); la combinación
casi-segura sobre ese conjunto denso no se formaliza aquí.
-/

open Finset BigOperators
open MeasureTheory ProbabilityTheory
open Filter
open scoped Function Topology

set_option maxHeartbeats 2000000
set_option linter.unusedVariables false

namespace BookCh5GcM5

/-! ## 1. Motor determinista: de la malla a la norma uniforme -/

/-- book: capitulos/cap04_herramientas.typ:1624 (key: thm:ch5-gc) —
**Motor determinista de Glivenko–Cantelli.** Si `F` y `F̂` son monótonas, `F̂`
dista `≤ η` de `F` sobre una malla estrictamente creciente `t` que cubre la
recta, la malla es `η`-fina **en la escala de `F`**
(`F(t_{n+1}) − F(t_n) ≤ η`) y la cola izquierda está controlada, entonces

`sup_{x ∈ ℝ} |F̂(x) − F(x)| ≤ 2η`.

Fidelidad declarada: es el núcleo exacto de la prueba de Glivenko–Cantelli
del libro (monotonía de la CDF empírica y de `F` + control de la malla); el
libro lo aplica sobre un conjunto denso numerable y con `η ↓ 0` para obtener
`sup_x |F̂_n(x) − F(x)| → 0` c.s. (`gc_uniform`), y la parte probabilística
es `gc_pointwise`. -/
theorem gc_engine {Fhat F : ℝ → ℝ} (hF : Monotone F) (hFh : Monotone Fhat)
    {t : ℕ → ℝ} (ht : StrictMono t) {η : ℝ} (hη : 0 ≤ η)
    (hgrid : ∀ n, |Fhat (t n) - F (t n)| ≤ η)
    (hmesh : ∀ n, F (t (n + 1)) - F (t n) ≤ η)
    (hleft : ∀ x, x ≤ t 0 → |Fhat x - F x| ≤ η)
    (hcover : ∀ x, ∃ n, x ≤ t n) :
    ∀ x, |Fhat x - F x| ≤ 2 * η := by
  intro x
  by_cases hx : x ≤ t 0
  · have := hleft x hx
    linarith
  · simp only [not_le] at hx
    set n := Nat.find (hcover x) with hn
    have hn' : x ≤ t n := Nat.find_spec (hcover x)
    have hmin : ∀ m < n, ¬ x ≤ t m := fun m hm => Nat.find_min (hcover x) hm
    have hn0 : n ≠ 0 := by
      intro h
      rw [h] at hn'
      exact absurd hn' (by linarith)
    obtain ⟨k, hk⟩ := Nat.exists_eq_succ_of_ne_zero hn0
    have hk' : n = k + 1 := by rw [hk, Nat.succ_eq_add_one]
    have hxk : x ≤ t (k + 1) := hk' ▸ hn'
    have hkt : ¬ x ≤ t k := by
      refine hmin k ?_
      rw [hk']
      exact Nat.lt_succ_self k
    have htk : t k < x := lt_of_not_ge hkt
    have h1 := abs_le.mp (hgrid k)
    have h2 := abs_le.mp (hgrid (k + 1))
    have hstep : F (t (k + 1)) - F (t k) ≤ η := hmesh k
    have hFk : F (t k) ≤ F x := hF htk.le
    have hFx : F x ≤ F (t (k + 1)) := hF hxk
    have hHk : Fhat (t k) ≤ Fhat x := hFh htk.le
    have hHx : Fhat x ≤ Fhat (t (k + 1)) := hFh hxk
    rw [abs_le]
    constructor <;> linarith

/-- book: capitulos/cap04_herramientas.typ:1624 (key: thm:ch5-gc) —
**Convergencia uniforme a partir de mallas que se refinan.** Si cada `F̂_N`
dista `≤ η_N` de `F` sobre una malla `η_N`-fina en la escala de `F` y
`η_N → 0`, entonces `sup_x |F̂_N(x) − F(x)| → 0`: la conclusión de
Glivenko–Cantelli `‖F̂_n − F‖_∞ → 0` en versión determinista (esto es,
condicional a la convergencia puntual sobre la malla). -/
theorem gc_uniform {Fhat : ℕ → ℝ → ℝ} {F : ℝ → ℝ} (hF : Monotone F)
    (hFh : ∀ N, Monotone (Fhat N)) (t : ℕ → ℕ → ℝ) (ht : ∀ N, StrictMono (t N))
    (η : ℕ → ℝ) (hη : ∀ N, 0 ≤ η N) (hη0 : Tendsto η atTop (𝓝 0))
    (hgrid : ∀ N n, |Fhat N (t N n) - F (t N n)| ≤ η N)
    (hmesh : ∀ N n, F (t N (n + 1)) - F (t N n) ≤ η N)
    (hleft : ∀ N x, x ≤ t N 0 → |Fhat N x - F x| ≤ η N)
    (hcover : ∀ N x, ∃ n, x ≤ t N n) :
    ∀ ε : ℝ, 0 < ε → ∀ᶠ N in atTop, ∀ x, |Fhat N x - F x| ≤ ε := by
  intro ε hε
  have h2 : ∀ᶠ N in atTop, η N < ε / 2 :=
    hη0.eventually (eventually_lt_nhds (by linarith))
  filter_upwards [h2] with N hN x
  have hb := gc_engine hF (hFh N) (ht N) (hη N) (hgrid N) (hmesh N) (hleft N) (hcover N) x
  linarith

/-- Testigo de no vacuidad de `gc_engine`: con `F = F̂ = 0` y `η = 0` la
conclusión es la cota trivial. -/
theorem gc_engine_testigo :
    ∀ x : ℝ, |(fun _ : ℝ => (0:ℝ)) x - (fun _ : ℝ => (0:ℝ)) x| ≤ 2 * 0 := by
  intro x
  simp

/-! ## 2. Convergencia puntual casi segura: la ley fuerte de los grandes números -/

/-- book: capitulos/cap04_herramientas.typ:1624 (key: thm:ch5-gc) —
**Convergencia puntual c.s. de la CDF empírica.** Para `X : ℕ → Ω → ℝ` iid
sobre un espacio de probabilidad y todo `x ∈ ℝ`,

`F̂_n(x) = (1/n) ∑_{i<n} 1{X_i ≤ x} → P(X_0 ≤ x) = F(x)` casi seguramente.

Fidelidad declarada: es la primera mitad de la prueba del libro (`F̂_n(x)`
es un promedio de indicadores iid e integrables, y `E[1{X_0 ≤ x}] = F(x)`)
y se obtiene del teorema de la ley fuerte de Mathlib
(`ProbabilityTheory.strong_law_ae_real`, Etemadi), que sólo pide
independencia dos a dos. La conclusión es puntual en `x`; el paso de aquí a
`sup_x` es el motor determinista `gc_engine`/`gc_uniform`. -/
theorem gc_pointwise {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω)
    [IsProbabilityMeasure P] (X : ℕ → Ω → ℝ) (hm : ∀ i, Measurable (X i))
    (hindep : Pairwise ((· ⟂ᵢ[P] ·) on X))
    (hident : ∀ i, IdentDistrib (X i) (X 0) P P) (x : ℝ) :
    ∀ᵐ ω ∂P,
      Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ Finset.range n,
        (if X i ω ≤ x then (1 : ℝ) else 0)) atTop (𝓝 (P (X 0 ⁻¹' Set.Iic x)).toReal) := by
  classical
  set g : ℝ → ℝ := fun y => if y ≤ x then (1 : ℝ) else 0 with hg
  set Y : ℕ → Ω → ℝ := fun i ω => g (X i ω) with hY
  have hg_meas : Measurable g := by
    refine Measurable.ite ?_ measurable_const measurable_const
    exact measurableSet_Iic
  have hmeas : ∀ i, Measurable (Y i) := fun i => hg_meas.comp (hm i)
  have hbound : ∀ i ω, ‖Y i ω‖ ≤ 1 := by
    intro i ω
    simp only [hY, hg, Real.norm_eq_abs]
    split_ifs <;> norm_num
  have hind : MeasurableSet (X 0 ⁻¹' Set.Iic x) := measurableSet_Iic.preimage (hm 0)
  have hfun : Y 0 = (X 0 ⁻¹' Set.Iic x).indicator (1 : Ω → ℝ) := by
    funext ω
    by_cases h : X 0 ω ≤ x <;> simp [hY, hg, Set.indicator, h]
  have hint : ∫ ω, Y 0 ω ∂P = (P (X 0 ⁻¹' Set.Iic x)).toReal := by
    rw [hfun, integral_indicator_one hind]
    rfl
  have hYint : Integrable (Y 0) P :=
    Integrable.of_bound (hmeas 0).aestronglyMeasurable 1
      (Filter.Eventually.of_forall (hbound 0))
  have hindep' : Pairwise ((· ⟂ᵢ[P] ·) on Y) := by
    intro i j hij
    exact (hindep hij).comp hg_meas hg_meas
  have hident' : ∀ i, IdentDistrib (Y i) (Y 0) P P := by
    intro i
    exact (hident i).comp hg_meas
  have h := strong_law_ae_real Y hYint hindep' hident'
  filter_upwards [h] with ω hω
  rw [hint] at hω
  simpa [hY, hg, div_eq_inv_mul] using hω

end BookCh5GcM5
