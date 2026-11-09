/-
Copyright: proyecto `book_stat_inference_v0` (cap. 4 de herramientas). Sin copyright externo.
-/
import Mathlib

/-!
# Cap. 6 — Motivación: estimar una decisión con modelos auxiliares

Formalización de la clave `ex:ch6-motivacion` (`capitulos/cap04_herramientas.typ`,
ejemplo de apertura del capítulo 6 de herramientas). El libro afirma, para un
objetivo causal `ψ = E[Y(1) − Y(0)]` a partir de observaciones `(X, A, Y)`:

* antes de estimarlo se requieren consistencia, intercambiabilidad condicional y
  positividad, y la propensión `e(X) = P(A = 1 | X)` y las medias condicionales
  `m_a(X) = E[Y | A = a, X]` permiten estimar el objetivo;
* ponderar con la propensión **verdadera** da una identidad insesgada;
* la doble robustez pertenece a un estimador aumentado específico: su sesgo
  poblacional se anula si la propensión o las dos medias condicionales son correctas.

Todo se formaliza en un modelo **finito** (`X`, `Y` finitos, masa `pX` de las
covariables, propensión `e` y leyes condicionales `q a x ·` del resultado): las
esperanzas son sumas finitas, así que no hace falta teoría de la medida.
-/

set_option linter.unusedSectionVars false

namespace Ch6Motivacion

open Finset

variable {X Y : Type*} [Fintype X] [Fintype Y]

noncomputable section

/-! ### La ley observada de `(X, A, Y)` y sus funcionales -/

/-- Peso de la rama `a` en `x`: `pX x · e x` si `a = true`, `pX x · (1 − e x)` si `a = false`. -/
def coef (pX : X → ℝ) (e : X → ℝ) (x : X) (a : Bool) : ℝ :=
  pX x * if a then e x else 1 - e x

/-- Masa conjunta observada de `(X, A, Y)`. -/
def masa (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (x : X) (a : Bool) (y : Y) : ℝ :=
  coef pX e x a * q a x y

/-- Media condicional `m_a(x) = E[Y | A = a, X = x]`. -/
def mediaCond (q : Bool → X → Y → ℝ) (val : Y → ℝ) (a : Bool) (x : X) : ℝ :=
  ∑ y, q a x y * val y

/-- Objetivo causal `ψ = E[m₁(X) − m₀(X)] = E[Y(1) − Y(0)]`. -/
def psi (pX : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ) : ℝ :=
  ∑ x, pX x * (mediaCond q val true x - mediaCond q val false x)

/-- Masa de la rama `A = 1`. -/
lemma masa_true (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (x : X) (y : Y) :
    masa pX e q x true y = pX x * e x * q true x y := by
  simp [masa, coef]

/-- Masa de la rama `A = 0`. -/
lemma masa_false (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (x : X) (y : Y) :
    masa pX e q x false y = pX x * (1 - e x) * q false x y := by
  simp [masa, coef]

/-- La masa de las dos ramas suma la masa de `x`. -/
lemma sum_coef (pX : X → ℝ) (e : X → ℝ) (x : X) :
    (∑ a : Bool, coef pX e x a) = pX x := by
  rw [Fintype.sum_bool]
  simp only [coef]
  norm_num
  ring

/-- La masa conjunta suma 1 (normalización de `pX` y de `q`). -/
theorem masa_total (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ)
    (hpX : ∑ x, pX x = 1) (hq : ∀ a x, ∑ y, q a x y = 1) :
    ∑ x, ∑ a, ∑ y, masa pX e q x a y = 1 := by
  have h : ∑ x, ∑ a, ∑ y, masa pX e q x a y = ∑ x, pX x := by
    refine Finset.sum_congr rfl (fun x _ => ?_)
    trans ∑ a : Bool, coef pX e x a
    · refine Finset.sum_congr rfl (fun a _ => ?_)
      simp only [masa]
      rw [← Finset.mul_sum, hq a x, mul_one]
    · exact sum_coef pX e x
  rw [h, hpX]

/-- Producto de sumas: `∑ᵢ ∑ⱼ fᵢ·gⱼ = (∑ f)·(∑ g)`. -/
lemma sum_mul_sum' {ι κ : Type*} [Fintype ι] [Fintype κ] (f : ι → ℝ) (g : κ → ℝ) :
    ∑ i, ∑ j, f i * g j = (∑ i, f i) * ∑ j, g j := by
  rw [Finset.sum_mul_sum]

/-- Media de un residual en la rama `a`:
`∑_y q_a(x,y)·(val y − h) = m_a(x) − h` si `q_a(x,·)` es una ley. -/
lemma sum_residuo (q : Bool → X → Y → ℝ) (val : Y → ℝ) (a : Bool) (x : X) (h : ℝ)
    (hq : ∑ y, q a x y = 1) :
    ∑ y, q a x y * (val y - h) = mediaCond q val a x - h := by
  have h1 : ∑ y, q a x y * (val y - h)
      = (∑ y, q a x y * val y) - (∑ y, q a x y) * h := by
    calc ∑ y, q a x y * (val y - h)
        = ∑ y, (q a x y * val y - q a x y * h) :=
          Finset.sum_congr rfl (fun y _ => by ring)
      _ = (∑ y, q a x y * val y) - ∑ y, q a x y * h := by rw [Finset.sum_sub_distrib]
      _ = (∑ y, q a x y * val y) - (∑ y, q a x y) * h := by rw [Finset.sum_mul]
  rw [h1, hq, one_mul, mediaCond]

/-! ### La identidad de ponderación con la propensión verdadera -/

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Identidad IPW con la propensión verdadera, rama `A = 1`:
`E[1{A=1}·Y/e(X)] = E[m₁(X)] = E[Y(1)]`, escrita sobre la ley observada.
Sólo se necesita `e x ≠ 0` (positividad estricta); la ley `q true x ·` no necesita normalizarse
porque ambos lados la usan como pesos. -/
theorem ipw_true (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (he : ∀ x, e x ≠ 0) :
    ∑ x, ∑ y, masa pX e q x true y * (val y / e x)
      = ∑ x, pX x * mediaCond q val true x := by
  refine Finset.sum_congr rfl (fun x _ => ?_)
  rw [mediaCond, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun y _ => ?_)
  rw [masa_true]
  have hx : e x ≠ 0 := he x
  field_simp

/-- Identidad IPW con la propensión verdadera, rama `A = 0`:
`E[1{A=0}·Y/(1−e(X))] = E[m₀(X)] = E[Y(0)]`. -/
theorem ipw_false (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (he : ∀ x, 1 - e x ≠ 0) :
    ∑ x, ∑ y, masa pX e q x false y * (val y / (1 - e x))
      = ∑ x, pX x * mediaCond q val false x := by
  refine Finset.sum_congr rfl (fun x _ => ?_)
  rw [mediaCond, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun y _ => ?_)
  rw [masa_false]
  have hx : 1 - e x ≠ 0 := he x
  field_simp

/-- Residual con propensión verdadera, rama `A = 1`: para **cualquier** predictor
`m̂` de `m₁`, `E[1{A=1}(Y − m̂(X))/e(X)] = E[m₁(X) − m̂(X)]`. -/
theorem ipw_residuo (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (mhat : X → ℝ) (he : ∀ x, e x ≠ 0) (hq : ∀ x, ∑ y, q true x y = 1) :
    ∑ x, ∑ y, masa pX e q x true y * ((val y - mhat x) / e x)
      = ∑ x, pX x * (mediaCond q val true x - mhat x) := by
  refine Finset.sum_congr rfl (fun x _ => ?_)
  have hfac : ∑ y, masa pX e q x true y * ((val y - mhat x) / e x)
      = pX x * ∑ y, q true x y * (val y - mhat x) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun y _ => ?_)
    rw [masa_true]
    have hx : e x ≠ 0 := he x
    field_simp
  rw [hfac, sum_residuo q val true x (mhat x) (hq x)]

/-- Residual con propensión verdadera, rama `A = 0`. -/
theorem ipw_residuo_false (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (mhat : X → ℝ) (he : ∀ x, 1 - e x ≠ 0) (hq : ∀ x, ∑ y, q false x y = 1) :
    ∑ x, ∑ y, masa pX e q x false y * ((val y - mhat x) / (1 - e x))
      = ∑ x, pX x * (mediaCond q val false x - mhat x) := by
  refine Finset.sum_congr rfl (fun x _ => ?_)
  have hfac : ∑ y, masa pX e q x false y * ((val y - mhat x) / (1 - e x))
      = pX x * ∑ y, q false x y * (val y - mhat x) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun y _ => ?_)
    rw [masa_false]
    have hx : 1 - e x ≠ 0 := he x
    field_simp
  rw [hfac, sum_residuo q val false x (mhat x) (hq x)]

/-- Residual centrado con **cualquier** propensión positiva, rama `A = 1`:
`E[1{A=1}(Y − m₁(X))/ê(X)] = 0`, porque `E[Y − m₁(X) | A = 1, X = x] = 0`. -/
theorem ipw_centrado (pX : X → ℝ) (et : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (het : ∀ x, et x ≠ 0) (hq : ∀ x, ∑ y, q true x y = 1) :
    ∑ x, ∑ y, masa pX et q x true y * ((val y - mediaCond q val true x) / et x) = 0 := by
  refine Finset.sum_eq_zero (fun x _ => ?_)
  have hzero : ∑ y, q true x y * (val y - mediaCond q val true x) = 0 := by
    rw [sum_residuo q val true x (mediaCond q val true x) (hq x), sub_self]
  calc ∑ y, masa pX et q x true y * ((val y - mediaCond q val true x) / et x)
      = pX x * ∑ y, q true x y * (val y - mediaCond q val true x) := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl (fun y _ => ?_)
        rw [masa_true]
        have hx : et x ≠ 0 := het x
        field_simp
    _ = 0 := by rw [hzero, mul_zero]

/-- Residual centrado con **cualquier** propensión positiva, rama `A = 0`. -/
theorem ipw_centrado_false (pX : X → ℝ) (et : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (het : ∀ x, 1 - et x ≠ 0) (hq : ∀ x, ∑ y, q false x y = 1) :
    ∑ x, ∑ y, masa pX et q x false y * ((val y - mediaCond q val false x) / (1 - et x)) = 0 := by
  refine Finset.sum_eq_zero (fun x _ => ?_)
  have hzero : ∑ y, q false x y * (val y - mediaCond q val false x) = 0 := by
    rw [sum_residuo q val false x (mediaCond q val false x) (hq x), sub_self]
  calc ∑ y, masa pX et q x false y * ((val y - mediaCond q val false x) / (1 - et x))
      = pX x * ∑ y, q false x y * (val y - mediaCond q val false x) := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl (fun y _ => ?_)
        rw [masa_false]
        have hx : 1 - et x ≠ 0 := het x
        field_simp
    _ = 0 := by rw [hzero, mul_zero]

/-! ### El estimador aumentado y la doble robustez -/

/-- Funcional poblacional del estimador aumentado (AIPW) con propensión de trabajo `et`:
`E[m̂₁(X) − m̂₀(X)] + E[1{A=1}·(Y − m̂₁(X))/êt(X)] − E[1{A=0}·(Y − m̂₀(X))/(1 − ê(X))]`.
Es el estimador aumentado específico al que el libro atribuye la doble robustez; no
es el funcional de la ponderación simple. -/
def aipw (pX : X → ℝ) (et : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (mhat1 mhat0 : X → ℝ) : ℝ :=
  (∑ x, pX x * (mhat1 x - mhat0 x))
    + (∑ x, ∑ y, masa pX et q x true y * ((val y - mhat1 x) / et x))
    - (∑ x, ∑ y, masa pX et q x false y * ((val y - mhat0 x) / (1 - et x)))

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Doble robustez, mitad de la propensión: si la propensión usada por el estimador
aumentado es la verdadera, su sesgo poblacional se anula con **cualesquiera**
predictores `m̂₁`, `m̂₀` de las medias condicionales. -/
theorem doble_robustez_propension (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ)
    (val : Y → ℝ) (mhat1 mhat0 : X → ℝ) (he : ∀ x, e x ≠ 0) (he1 : ∀ x, 1 - e x ≠ 0)
    (hq : ∀ a x, ∑ y, q a x y = 1) :
    aipw pX e q val mhat1 mhat0 = psi pX q val := by
  rw [aipw, ipw_residuo pX e q val mhat1 he (fun x => hq true x),
    ipw_residuo_false pX e q val mhat0 he1 (fun x => hq false x), psi]
  rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl (fun x _ => ?_)
  ring

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Doble robustez, mitad de las medias: si las medias condicionales usadas por el
estimador aumentado son las verdaderas, su sesgo poblacional se anula para
**cualquier** propensión de trabajo positiva `êt`. -/
theorem doble_robustez_medias (pX : X → ℝ) (et : X → ℝ) (q : Bool → X → Y → ℝ)
    (val : Y → ℝ) (het : ∀ x, et x ≠ 0) (het1 : ∀ x, 1 - et x ≠ 0)
    (hq : ∀ a x, ∑ y, q a x y = 1) :
    aipw pX et q val (mediaCond q val true) (mediaCond q val false) = psi pX q val := by
  rw [aipw, ipw_centrado pX et q val het (fun x => hq true x),
    ipw_centrado_false pX et q val het1 (fun x => hq false x), psi]
  simp

/-! ### Identificación: el acoplamiento con resultados potenciales -/

/-- Masa conjunta de `(X, A, Y(1), Y(0))` en el acoplamiento: dado `X = x` se sortea
`A` con propensión `e x`, el resultado de la rama recibida con su ley condicional
`q a x ·` y el contrafactual con `q (!a) x ·`. Por construcción la ley conjunta de
`(Y(1), Y(0))` dado `X` no depende de `A` (intercambiabilidad) y el resultado
observado es el potencial de la rama recibida (consistencia). -/
def masaPot (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (x : X) (a : Bool)
    (y1 y0 : Y) : ℝ :=
  coef pX e x a * q true x y1 * q false x y0

/-- Producto doble con residual:
`∑_{y₁}∑_{y₀} q₁(y₁)·q₀(y₀)·(val y₁ − val y₀) = m₁ − m₀` si `q₁`, `q₀` son leyes. -/
lemma sum_doble_residuo (q1 q0 : Y → ℝ) (val : Y → ℝ)
    (h1 : ∑ y, q1 y = 1) (h0 : ∑ y, q0 y = 1) :
    ∑ y1, ∑ y0, q1 y1 * q0 y0 * (val y1 - val y0)
      = (∑ y, q1 y * val y) - (∑ y, q0 y * val y) := by
  calc ∑ y1, ∑ y0, q1 y1 * q0 y0 * (val y1 - val y0)
      = ∑ y1, ∑ y0, ((q1 y1 * val y1) * q0 y0 - q1 y1 * (q0 y0 * val y0)) :=
        Finset.sum_congr rfl (fun y1 _ => Finset.sum_congr rfl (fun y0 _ => by ring))
    _ = (∑ y1, ∑ y0, (q1 y1 * val y1) * q0 y0)
          - (∑ y1, ∑ y0, q1 y1 * (q0 y0 * val y0)) := by
        rw [← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl (fun y1 _ => by rw [Finset.sum_sub_distrib])
    _ = (∑ y, q1 y * val y) - (∑ y, q0 y * val y) := by
        rw [sum_mul_sum', sum_mul_sum', h1, h0, mul_one, one_mul]

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Identificación: en el acoplamiento que satisface consistencia e intercambiabilidad,
`E[Y(1) − Y(0)] = E[m₁(X) − m₀(X)] = ψ`. -/
theorem identificacion (pX : X → ℝ) (e : X → ℝ) (q : Bool → X → Y → ℝ) (val : Y → ℝ)
    (hq : ∀ a x, ∑ y, q a x y = 1) :
    (∑ x, ∑ a, ∑ y1, ∑ y0, masaPot pX e q x a y1 y0 * (val y1 - val y0))
      = psi pX q val := by
  rw [psi]
  refine Finset.sum_congr rfl (fun x _ => ?_)
  have hslice : ∀ a : Bool, (∑ y1, ∑ y0, masaPot pX e q x a y1 y0 * (val y1 - val y0))
      = coef pX e x a * (mediaCond q val true x - mediaCond q val false x) := by
    intro a
    have hd := sum_doble_residuo (fun y => q true x y) (fun y => q false x y) val
      (hq true x) (hq false x)
    calc ∑ y1, ∑ y0, masaPot pX e q x a y1 y0 * (val y1 - val y0)
        = coef pX e x a * ∑ y1, ∑ y0, q true x y1 * q false x y0 * (val y1 - val y0) := by
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl (fun y1 _ => ?_)
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl (fun y0 _ => ?_)
          simp only [masaPot]
          ring
      _ = coef pX e x a * (mediaCond q val true x - mediaCond q val false x) := by
          rw [hd, mediaCond, mediaCond]
  trans ∑ a : Bool, coef pX e x a * (mediaCond q val true x - mediaCond q val false x)
  · exact Finset.sum_congr rfl (fun a _ => hslice a)
  · rw [← Finset.sum_mul, sum_coef]

/-! ### Insensadez finita: una propensión estimada no la conserva

Modelo finito más pequeño en el que una propensión **estimada con la misma muestra**
puede comprobarse sesgada: `n = 2` unidades, `A_i ~ Bern(1/2)` independientes,
`Y_i(1) ~ Bern(1/2)` independientes de `A`, y `Y(0) ≡ 0`. El espacio tiene
`2^4 = 16` configuraciones equiprobables. La propensión estimada es la empírica
`ê = (#tratadas)/2`; el estimador de plug-in resultante coincide con el
autonormalizado (Hájek).
-/

/-- Indicador de un suceso booleano como número real. -/
def ind (b : Bool) : ℝ := if b then 1 else 0

/-- Esperanza sobre las `2^4 = 16` configuraciones equiprobables
`(A₁, A₂, Y₁(1), Y₂(1)) ∈ {0,1}⁴`. -/
noncomputable def E4 (f : Bool → Bool → Bool → Bool → ℝ) : ℝ :=
  (1/16) * ∑ a1 : Bool, ∑ a2 : Bool, ∑ y1 : Bool, ∑ y2 : Bool, f a1 a2 y1 y2

/-- Resultado observado de una unidad cuando `Y(0) ≡ 0`: `Y_i = 1{A_i = 1}·Y_i(1)`. -/
def YobsT (a y : Bool) : ℝ := ind a * ind y

/-- Estimador IPW de `E[Y(1)]` con la propensión **verdadera** `e = 1/2`. -/
def ipwVerdadera (a1 a2 y1 y2 : Bool) : ℝ :=
  (YobsT a1 y1 / (1/2) + YobsT a2 y2 / (1/2)) / 2

/-- Estimador de plug-in que sustituye la propensión por la estimación empírica
`ê = (#tratadas)/2` calculada en la misma muestra (convención `0/0 = 0`). -/
def plugIn (a1 a2 y1 y2 : Bool) : ℝ :=
  (YobsT a1 y1 + YobsT a2 y2) / (ind a1 + ind a2)

/-- Valor medio del resultado potencial bajo tratamiento: `E[Y(1)] = 1/2`. -/
theorem media_potencial : E4 (fun _ _ y1 _ => ind y1) = 1 / 2 := by
  simp only [E4, Fintype.sum_bool, ind]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Con la propensión verdadera el estimador IPW es insesgado en muestra finita:
`E[IPW] = E[Y(1)] = 1/2`. -/
theorem ipw_verdadera_insesgada : E4 ipwVerdadera = 1 / 2 := by
  simp only [E4, Fintype.sum_bool, ipwVerdadera, YobsT, ind]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

Sustituir la propensión por una estimación no conserva la insesgadez finita:
con `n = 2` y la propensión empírica, `E[plug-in] = 3/8 ≠ 1/2 = E[Y(1)]`. -/
theorem plugin_sesgado : E4 plugIn = 3 / 8 := by
  simp only [E4, Fintype.sum_bool, plugIn, YobsT, ind]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:17 (key: ex:ch6-motivacion)

El sesgo es no nulo: `E[plug-in] ≠ E[Y(1)]`. -/
theorem sesgo_finito_propension_estimada :
    E4 plugIn ≠ E4 (fun _ _ y1 _ => ind y1) := by
  rw [plugin_sesgado, media_potencial]
  norm_num

end

end Ch6Motivacion
