/-
Copyright: proyecto des504 — enjambre smw9lhdoa, miembro m8.

# Apéndice D — Gordin: ecuación de Poisson en una cadena finita

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

El libro enuncia el CLT funcional para una cadena finita irreducible y aperiódica
y describe el argumento de Gordin: **la ecuación de Poisson** `h - P h = f` tiene
solución centrada en esta cadena finita; con ella

  `∑_{t=1}^n f(S_t) = ∑_{t=1}^n (h(S_t) - P h(S_{t-1})) + P h(S_0) - P h(S_n)`,

los sumandos son diferencias de martingala acotadas, la variación cuadrática
condicional normalizada converge por ergodicidad, y el término de borde es
uniformemente despreciable.

Este módulo formaliza **todos los pasos internos de esa prueba** que no requieren
el CLT de martingalas (que el libro invoca como herramienta externa). En detalle:

* `Chain` — la matriz estocástica `P`, la ley estacionaria `π` (invariante,
  `∑_y π_y P_{y x} = π_x`) y la irreducibilidad como alcanzabilidad por caminos
  de probabilidad positiva (`Relation.ReflTransGen`). No se pide periodicidad
  aquí: sólo se usa para la existencia de la solución de Poisson y para la
  descomposición, que valen también en el caso periódico.
* `Chain.poisson_solution` — **la solución de Poisson existe y es centrada**:
  si `π(f) = 0`, hay `h` con `π(h) = 0` y `f = h - P h`. La prueba es el
  principio del máximo sobre los estados, sin teoría espectral: si `x = P x`,
  entonces `x` es constante (un máximo de `x` se propaga por los caminos de
  probabilidad positiva), y el operador `Q x = x - P x + π(x)·1` es inyectivo,
  luego (dimensión finita) sobreyectivo. El desplazamiento `π(x)·1` es el que
  hace que `Q` sea invertible; el centrado `π(h) = 0` sale de aplicar `π`.
* `Chain.gordin_decomposition` — la identidad telescópica del libro, literal,
  para **toda** trayectoria `s : ℕ → S`.
* `Chain.boundary_abs_le` y `Chain.tendsto_boundary_div_sqrt` — el término de
  borde está acotado por `2 ∑_y |h y|` y por tanto es `o(1)` tras dividir por
  `√n`. Esto es la parte «el término de borde es uniformemente despreciable».
* `Chain.condVar` / `Chain.sigmaSq` — la varianza condicional del incremento
  `v(x) = ∑_y P_{x y} (h(y) - P h(x))²` y el parámetro
  `σ² = π(v) = E[d_1²]` de la aproximación de martingalas.
* `Chain.cesaro_condVar` — **la variación cuadrática condicional normalizada
  converge**: `(1/n) ∑_{t<n} v(S_t) → σ²` para toda trayectoria, con tasa
  `O(1/n)`. La prueba es una *segunda* ecuación de Poisson (para `v - σ²`), no
  el teorema ergódico: es exactamente el paso que el libro atribuye a la
  ergodicidad y aquí sale elemental porque el estado es finito.
* `Chain.martingale_increment_mean` — `∑_y P_{x y} (h(y) - P h(x)) = 0`: el
  incremento tiene media condicional cero (diferencia de martingala).

**Fidelidad declarada.** (i) `P` es una matriz estocástica por filas y `π` una
probabilidad invariante (por columnas); ambas son datos, no se construye `π`
desde `P` (el libro tampoco lo hace: parte de la ley estacionaria). (ii) La
irreducibilidad se formaliza como alcanzabilidad: para todo par de estados hay
un camino de entradas `> 0`. Es la hipótesis del libro «finita irreducible».
(iii) La aperiodicidad **no** se usa: los pasos aquí formalizados valen también
en el caso periódico. Se necesita sólo para el CLT de martingalas, que no está
en Mathlib y por eso no se formaliza (véase README.md, §3).
(iv) `σ² = ∑_{k ∈ ℤ} Cov(f(S_0), f(S_k))` del libro se formaliza como
`σ² = π(v) = E[d_1²]`, la varianza del incremento de martingala, que es la
identidad clásica de Gordin; la igualdad con la serie de covarianzas requiere
decaimiento geométrico de las covarianzas y no se prueba aquí.
-/

import Mathlib

open Finset MeasureTheory ProbabilityTheory Filter
open scoped Topology BigOperators

namespace ApendiceDGordinM8

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Una cadena de Markov finita: matriz estocástica `P` por filas, probabilidad
invariante `π` (ecuación por columnas) e irreducibilidad por alcanzabilidad. -/
structure Chain (S : Type*) [Fintype S] where
  /-- Transición `P x y`. -/
  P : S → S → ℝ
  /-- Ley estacionaria `π`. -/
  π : S → ℝ
  P_nonneg : ∀ x y, 0 ≤ P x y
  P_sum : ∀ x, ∑ y, P x y = 1
  π_nonneg : ∀ x, 0 ≤ π x
  π_sum : ∑ x, π x = 1
  /-- Invariancia: `∑_y π_y P_{y x} = π_x`. -/
  π_inv : ∀ x, ∑ y, π y * P y x = π x
  /-- Irreducibilidad: todo estado es alcanzable desde cualquier otro. -/
  irreduc : ∀ x y, Relation.ReflTransGen (fun a b : S => 0 < P a b) x y

/-- Cota uniforme de una función sobre el espacio de estados: `∑_y |h y|`. -/
def supBound (h : S → ℝ) : ℝ := ∑ y, |h y|

namespace Chain

variable (D : Chain S)

/-! ## 1. El operador de transición y la esperanza estacionaria -/

/-- `P` actuando sobre funciones: `(P g)(x) = ∑_y P_{x y} g(y)`. -/
def applyP : (S → ℝ) →ₗ[ℝ] (S → ℝ) where
  toFun g x := ∑ y, D.P x y * g y
  map_add' g h := by
    funext x
    simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' c g := by
    funext x
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun y _ => by ring

/-- La esperanza bajo la ley estacionaria: `π(g) = ∑_x π_x g(x)`. -/
def avg : (S → ℝ) →ₗ[ℝ] ℝ where
  toFun g := ∑ x, D.π x * g x
  map_add' g h := by
    simp only [Pi.add_apply, mul_add, Finset.sum_add_distrib]
  map_smul' c g := by
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun y _ => by ring

@[simp] lemma applyP_apply (g : S → ℝ) (x : S) :
    D.applyP g x = ∑ y, D.P x y * g y := rfl

@[simp] lemma avg_apply (g : S → ℝ) : D.avg g = ∑ x, D.π x * g x := rfl

/-- La constante `1` tiene esperanza `1`. -/
lemma avg_one : D.avg (fun _ => (1 : ℝ)) = 1 := by
  simp only [avg_apply, mul_one, D.π_sum]

/-- Las constantes son puntos fijos del funcional de esperanza. -/
lemma avg_const (c : ℝ) : D.avg (fun _ => c) = c := by
  simp only [avg_apply]
  rw [← Finset.sum_mul, D.π_sum, one_mul]

/-- La ley estacionaria es invariante bajo `P` a nivel de esperanzas:
`π(P g) = π(g)`. -/
lemma avg_applyP (g : S → ℝ) : D.avg (D.applyP g) = D.avg g := by
  simp only [avg_apply, applyP_apply]
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun y _ => ?_
  have h1 : ∑ x, D.π x * (D.P x y * g y) = ∑ x, (D.π x * D.P x y) * g y :=
    Finset.sum_congr rfl fun x _ => by ring
  rw [h1, ← Finset.sum_mul, D.π_inv y]

/-! ## 2. Principio del máximo: una función armónica es constante -/

/-- **Paso del principio del máximo.** Si `x` es armónica (`x = P x`) y `a` es un
máximo de `x`, entonces `x` es constante a lo largo de toda transición de
probabilidad positiva que sale de `a`. -/
lemma eq_of_le_max {x : S → ℝ} (hharm : ∀ z, x z = D.applyP x z)
    {a b : S} (hmax : ∀ y, x y ≤ x a) (hab : 0 < D.P a b) : x b = x a := by
  have hharm' : ∀ z, x z = ∑ y, D.P z y * x y := fun z => hharm z
  have hsum : ∑ y, D.P a y * x y = ∑ y, D.P a y * x a := by
    rw [← hharm' a]
    simp only [← Finset.sum_mul, D.P_sum, one_mul]
  have hzero : ∑ y, D.P a y * (x y - x a) = 0 := by
    have h1 : ∑ y, D.P a y * (x y - x a)
        = ∑ y, D.P a y * x y - ∑ y, D.P a y * x a := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun y _ => by ring
    rw [h1, hsum]
    simp only [← Finset.sum_mul, D.P_sum, one_mul]
    ring
  have hnonpos : ∀ y ∈ (Finset.univ : Finset S), D.P a y * (x y - x a) ≤ 0 := by
    intro y _
    have hy : x y - x a ≤ 0 := by linarith [hmax y]
    have hP : 0 ≤ D.P a y := D.P_nonneg a y
    nlinarith
  have hterm : D.P a b * (x b - x a) = 0 := by
    have h := (Finset.sum_eq_zero_iff_of_nonpos hnonpos).mp hzero
    exact h b (Finset.mem_univ b)
  have hdiff : x b - x a = 0 := by
    rcases mul_eq_zero.mp hterm with h | h
    · exact absurd h (ne_of_gt hab)
    · exact h
  linarith

/-- La constancia se propaga por alcanzabilidad. -/
lemma harmonic_eq_of_reach {x : S → ℝ} (hharm : ∀ z, x z = D.applyP x z)
    {a : S} (hmax : ∀ y, x y ≤ x a) :
    ∀ b, Relation.ReflTransGen (fun a b : S => 0 < D.P a b) a b → x b = x a := by
  intro b hb
  induction hb with
  | refl => rfl
  | tail hab hbc ih =>
    rename_i p q
    have hmax' : ∀ y, x y ≤ x p := by
      intro y
      rw [ih]
      exact hmax y
    exact (D.eq_of_le_max hharm hmax' hbc).trans ih

/-! ## 3. Una función armónica centrada es nula -/

/-- **Consecuencia del principio del máximo**: si `x` es armónica (`x = P x`),
`π(x) = 0` y la cadena es irreducible, entonces `x = 0`. Es la unicidad en la
ecuación de Poisson homogénea. -/
lemma harmonic_eq_zero [Nonempty S] {x : S → ℝ} (hharm : ∀ z, x z = D.applyP x z)
    (havg : D.avg x = 0) : ∀ y, x y = 0 := by
  obtain ⟨a, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset S) x Finset.univ_nonempty
  have hmax' : ∀ y, x y ≤ x a := fun y => hmax y (Finset.mem_univ y)
  have hall : ∀ y, x y = x a := fun y => D.harmonic_eq_of_reach hharm hmax' y (D.irreduc a y)
  have hxa : x a = 0 := by
    have h1 : D.avg x = x a := by
      simp only [avg_apply]
      have h2 : ∑ y, D.π y * x y = ∑ y, D.π y * x a :=
        Finset.sum_congr rfl fun y _ => by rw [hall y]
      rw [h2]
      simp only [← Finset.sum_mul, D.π_sum, one_mul]
    rw [h1] at havg
    exact havg
  intro y
  rw [hall y, hxa]

/-! ## 4. La ecuación de Poisson `h - P h = f` tiene solución centrada -/

/-- El operador desplazado `Q x = x - P x + π(x)·1`. El desplazamiento de rango
uno es lo que lo hace invertible: `(I - P)` es singular sobre las constantes. -/
noncomputable def Qlin : (S → ℝ) →ₗ[ℝ] (S → ℝ) where
  toFun x := x - D.applyP x + fun _ => D.avg x
  map_add' x y := by
    funext z
    simp only [Pi.add_apply, Pi.sub_apply, map_add]
    ring
  map_smul' c x := by
    funext z
    simp only [Pi.sub_apply, Pi.add_apply, Pi.smul_apply, map_smul, smul_eq_mul,
      RingHom.id_apply]
    ring

@[simp] lemma Qlin_apply (x : S → ℝ) (z : S) :
    D.Qlin x z = x z - D.applyP x z + D.avg x := rfl

/-- `Q` es inyectivo. Si `Q x = 0`, aplicando `π` sale `π(x) = 0` (porque
`π(P x) = π(x)` y `π(1) = 1`) y entonces `x` es armónica, luego nula. -/
lemma Qlin_injective [Nonempty S] : Function.Injective D.Qlin := by
  rw [← LinearMap.ker_eq_bot, LinearMap.ker_eq_bot']
  intro x hx
  have hz : ∀ z, x z - D.applyP x z + D.avg x = 0 := fun z => by
    have h := congrFun hx z
    simpa only [Qlin_apply, Pi.zero_apply] using h
  have hx_eq : x = D.applyP x - (fun _ : S => D.avg x) := by
    funext z
    have h := hz z
    simp only [Pi.sub_apply]
    linarith
  have havg0 : D.avg x = 0 := by
    have h := congrArg D.avg hx_eq
    simp only [map_sub, avg_applyP] at h
    rw [D.avg_const (D.avg x)] at h
    linarith
  have hharm : ∀ z, x z = D.applyP x z := by
    intro z
    have h := hz z
    rw [havg0] at h
    linarith
  exact funext fun z => D.harmonic_eq_zero hharm havg0 z

/-- **La ecuación de Poisson tiene solución centrada** (paso 1 del argumento de
Gordin). Si `f` está centrada bajo la ley estacionaria, existe `h` con `π(h) = 0`
y `f = h - P h`. -/
theorem poisson_solution [Nonempty S] {f : S → ℝ} (hf : D.avg f = 0) :
    ∃ h : S → ℝ, D.avg h = 0 ∧ ∀ x, f x = h x - D.applyP h x := by
  have hsurj : Function.Surjective D.Qlin :=
    LinearMap.injective_iff_surjective.mp D.Qlin_injective
  obtain ⟨h, hh⟩ := hsurj f
  have hz : ∀ z, h z - D.applyP h z + D.avg h = f z := fun z => by
    have h := congrFun hh z
    simpa only [Qlin_apply] using h
  have heq : h = (D.applyP h - (fun _ : S => D.avg h)) + f := by
    funext z
    have h1 := hz z
    simp only [Pi.sub_apply, Pi.add_apply]
    linarith
  have havg0 : D.avg h = 0 := by
    have hstep := congrArg D.avg heq
    simp only [map_add, map_sub, avg_applyP] at hstep
    rw [D.avg_const (D.avg h), hf] at hstep
    linarith
  refine ⟨h, havg0, fun z => ?_⟩
  have h1 := hz z
  rw [havg0] at h1
  linarith

/-! ## 5. La descomposición de Gordin -/

/-- Incremento de martingala `d_t = h(S_t) - P h(S_{t-1})`. -/
def martIncrement (h : S → ℝ) (s : ℕ → S) (t : ℕ) : ℝ :=
  h (s (t+1)) - D.applyP h (s t)

/-- Suma de los incrementos de martingala hasta `n`. -/
noncomputable def martSum (h : S → ℝ) (s : ℕ → S) (n : ℕ) : ℝ :=
  ∑ t ∈ Finset.range n, D.martIncrement h s t

/-- **Identidad telescópica de Gordin**, literal del libro:
`∑_{t=1}^n f(S_t) = ∑_{t=1}^n (h(S_t) - P h(S_{t-1})) + P h(S_0) - P h(S_n)`. -/
theorem gordin_decomposition {f h : S → ℝ} (hpois : ∀ x, f x = h x - D.applyP h x)
    (s : ℕ → S) (n : ℕ) :
    ∑ t ∈ Finset.range n, f (s (t+1))
      = D.martSum h s n + D.applyP h (s 0) - D.applyP h (s n) := by
  have hA : ∑ t ∈ Finset.range n, D.applyP h (s (t+1)) + D.applyP h (s 0)
      = ∑ t ∈ Finset.range n, D.applyP h (s t) + D.applyP h (s n) := by
    have h1 := Finset.sum_range_succ' (fun t => D.applyP h (s t)) n
    rw [Finset.sum_range_succ] at h1
    linarith
  have hterm : ∀ t ∈ Finset.range n,
      f (s (t+1)) = D.martIncrement h s t
        + (D.applyP h (s t) - D.applyP h (s (t+1))) := by
    intro t _
    simp only [martIncrement]
    rw [hpois (s (t+1))]
    ring
  have hB : ∑ t ∈ Finset.range n, (D.applyP h (s t) - D.applyP h (s (t+1)))
      = D.applyP h (s 0) - D.applyP h (s n) := by
    rw [Finset.sum_sub_distrib]
    linarith
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, martSum, hB]
  ring

/-! ## 6. El término de borde es uniformemente despreciable -/

lemma applyP_abs_le (h : S → ℝ) (x : S) : |D.applyP h x| ≤ supBound h := by
  simp only [applyP_apply, supBound]
  refine (Finset.abs_sum_le_sum_abs (s := Finset.univ) (f := fun y => D.P x y * h y)).trans ?_
  refine Finset.sum_le_sum fun y _ => ?_
  have hP1 : D.P x y ≤ 1 := by
    have h := Finset.single_le_sum (f := fun z => D.P x z) (fun z _ => D.P_nonneg x z)
      (Finset.mem_univ y)
    simpa [D.P_sum] using h
  rw [abs_mul, abs_of_nonneg (D.P_nonneg x y)]
  nlinarith [abs_nonneg (h y)]

lemma boundary_abs_le (h : S → ℝ) (s : ℕ → S) (n : ℕ) :
    |D.applyP h (s 0) - D.applyP h (s n)| ≤ 2 * supBound h := by
  have h1 := D.applyP_abs_le h (s 0)
  have h2 := D.applyP_abs_le h (s n)
  have h3 : 0 ≤ supBound h := Finset.sum_nonneg fun y _ => abs_nonneg _
  calc |D.applyP h (s 0) - D.applyP h (s n)|
      = |D.applyP h (s 0) + -(D.applyP h (s n))| := by rw [sub_eq_add_neg]
    _ ≤ |D.applyP h (s 0)| + |-(D.applyP h (s n))| := abs_add_le _ _
    _ = |D.applyP h (s 0)| + |D.applyP h (s n)| := by rw [abs_neg]
    _ ≤ 2 * supBound h := by linarith

/-- El término de borde, dividido por `√n`, tiende a cero. -/
lemma tendsto_boundary_div_sqrt (h : S → ℝ) (s : ℕ → S) :
    Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹ * (D.applyP h (s 0) - D.applyP h (s n)))
      atTop (𝓝 0) := by
  have hsqrt : Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹) atTop (𝓝 0) :=
    tendsto_inv_atTop_zero.comp (Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop)
  have hg : Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹ * (2 * supBound h)) atTop (𝓝 0) := by
    simpa using hsqrt.mul_const (2 * supBound h)
  rw [tendsto_zero_iff_abs_tendsto_zero]
  refine squeeze_zero (fun n => abs_nonneg _) (fun n => ?_) hg
  show |(Real.sqrt n)⁻¹ * (D.applyP h (s 0) - D.applyP h (s n))|
      ≤ (Real.sqrt n)⁻¹ * (2 * supBound h)
  rw [abs_mul, abs_of_nonneg (by positivity : (0 : ℝ) ≤ (Real.sqrt n)⁻¹)]
  exact mul_le_mul_of_nonneg_left (D.boundary_abs_le h s n) (by positivity)

/-! ## 7. La varianza condicional: el parámetro `σ²` -/

/-- Varianza condicional del incremento dado el estado actual:
`v(x) = ∑_y P_{x y} (h(y) - P h(x))²`. -/
noncomputable def condVar (h : S → ℝ) : S → ℝ :=
  fun x => ∑ y, D.P x y * (h y - D.applyP h x) ^ 2

/-- `σ² = π(v)`: la varianza (estacionaria) del incremento de martingala. -/
noncomputable def sigmaSq (h : S → ℝ) : ℝ := D.avg (D.condVar h)

lemma condVar_nonneg (h : S → ℝ) (x : S) : 0 ≤ D.condVar h x :=
  Finset.sum_nonneg fun y _ => mul_nonneg (D.P_nonneg x y) (sq_nonneg _)

lemma sigmaSq_nonneg (h : S → ℝ) : 0 ≤ D.sigmaSq h :=
  Finset.sum_nonneg fun x _ => mul_nonneg (D.π_nonneg x) (D.condVar_nonneg h x)

/-- El incremento de martingala tiene media condicional cero: es una diferencia
de martingala (`∑_y P_{x y} (h(y) - P h(x)) = 0`). -/
lemma martIncrement_cond_mean (h : S → ℝ) (x : S) :
    ∑ y, D.P x y * (h y - D.applyP h x) = 0 := by
  have h1 : ∑ y, D.P x y * (h y - D.applyP h x)
      = ∑ y, D.P x y * h y - ∑ y, D.P x y * D.applyP h x := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [h1]
  simp only [applyP_apply]
  rw [← Finset.sum_mul, D.P_sum, one_mul]
  ring

/-- **La segunda ecuación de Poisson**: `v - σ²` está centrada, luego tiene
solución de Poisson centrada `w`. -/
theorem bracket_poisson [Nonempty S] (h : S → ℝ) :
    ∃ w : S → ℝ, D.avg w = 0 ∧
      ∀ x, D.condVar h x - D.sigmaSq h = w x - D.applyP w x := by
  have hf : D.avg (D.condVar h - fun _ : S => D.sigmaSq h) = 0 := by
    rw [map_sub, D.avg_const]
    simp [sigmaSq]
  exact D.poisson_solution hf

/-- **Descomposición de la varianza condicional**: la funcional aditiva centrada
`v - σ²` se descompone como la segunda martingala más su término de borde. -/
theorem bracket_decomposition {h w : S → ℝ}
    (hw : ∀ x, D.condVar h x - D.sigmaSq h = w x - D.applyP w x) (s : ℕ → S) (n : ℕ) :
    ∑ t ∈ Finset.range n, (D.condVar h (s (t+1)) - D.sigmaSq h)
      = D.martSum w s n + D.applyP w (s 0) - D.applyP w (s n) :=
  D.gordin_decomposition hw s n

end Chain

end ApendiceDGordinM8
