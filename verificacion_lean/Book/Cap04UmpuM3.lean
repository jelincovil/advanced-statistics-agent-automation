import Mathlib

/-!
# Cap04 — `thm:ch4-umpu`: el test UMPU bilateral (cierre en soporte de 3 puntos)

`book: book_stat_inference_v0/capitulos/cap04_herramientas.typ:1330 (key: thm:ch4-umpu)`

El libro enuncia: para la familia exponencial canónica de un parámetro
`f(x|θ) = c(θ) h(x) exp{η(θ) T(x)}` con `η` estrictamente creciente, el test UMPU de nivel `α`
para `H₀: θ = θ₀` vs `H₁: θ ≠ θ₀` rechaza cuando `T(x) < c₁` o `T(x) > c₂`, con `c₁, c₂`
determinados por `EE_{θ₀}[φ] = α` y `EE_{θ₀}[Tφ] = α·EE_{θ₀}[T]`, y es UMP dentro de la clase
de tests insesgados de nivel `α`.

**Qué se cierra aquí (0 `sorry`).** La demostración general de Lehmann usa la variación
decreciente de los núcleos TP₂ (sistemas de Chebyshev), que Mathlib no tiene. El paso que
*no* es algebraico es exactamente ese. En el **soporte de 3 puntos** `T ∈ {0,1,2}` el núcleo
TP₂ degenera en un polinomio cuadrático y el argumento se vuelve exacto, lo que permite cerrar
el enunciado completo en ese caso:

* `quadratic_double_root`: si `q(u) = A + Bu + Cu²` es `≥ 0` en `(0,∞)` y se anula en `u₀ > 0`,
  entonces `u₀` es raíz doble (`B + 2Cu₀ = 0`) y `C ≥ 0`. Es el sustituto formal del paso
  TP₂: un cero interior de una función no negativa obliga a la doble raíz.
* `unbiased_double_root`: un test insesgado de tamaño `α` en `u₀` tiene
  `lik h φ α u = C(u−u₀)²` con `C = (φ₂−α)h₂ ≥ 0`; en particular su covarianza con `T` en
  `u₀` se anula —**la segunda condición del libro no se postula, se deduce del insesgamiento**.
* `umpu_coefficient_bound`: como `φ₁ ≥ 0`, `C ≤ α·h₁/(2u₀)`.
* `umpu_three_point`: para todo `u > 0`,
  `lik h φ α u ≤ (α h₁/(2u₀))·(u−u₀)²`: **ningún test insesgado de nivel `α` supera la cota**.
* `umpu_attainment`: el test con `φ₁ = 0` (rechaza sólo en las dos colas, nunca en el centro),
  `φ₀ = α + C·u₀²/h₀` y `φ₂ = α + C/h₂` con `C = αh₁/(2u₀)` tiene tamaño `α`, es insesgado y
  alcanza la cota. Es el `φ(x) = 1{T(x) < c₁} + 1{T(x) > c₂}` del libro (con aleatorización
  en los extremos), y por las dos piezas anteriores es UMPU.

**Fidelidad declarada.** `lik h φ α u = Σ_{t=0}^{2} (φ(t) − α)·h(t)·u^t` es la diferencia
`β_φ(η) − α` multiplicada por la función de partición `Z(η) > 0`, escrita en `u = e^{η}` (que es
estrictamente creciente en `η`, como pide el libro); dividir por `Z > 0` no altera ninguna de
las desigualdades, de modo que `lik` conserva el orden de las potencias. El modelo entra por
`h > 0` (pesos positivos sobre `{0,1,2}`) y la normalización por `Z`; el enunciado se prueba
para soporte `{0,1,2}` y no para `T` arbitraria, que es el punto exacto donde el argumento
general necesita TP₂. `Book/Cap04Ch4BhUmpuM6.lean` formaliza la forma del test y la identidad
de covarianza `β'(η₀) = EE_η[Tφ] − EE_η[φ]EE_η[T]`; este módulo añade la optimalidad.
-/

set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

open Finset

namespace Cap04M3U

/-- `lik h φ α u = (φ 0 − α)h 0 + (φ 1 − α)h 1·u + (φ 2 − α)h 2·u²`, la diferencia
`β_φ(η) − α` por la función de partición, en `u = e^η` (base no enunciada). -/
noncomputable def lik (h φ : Fin 3 → ℝ) (α u : ℝ) : ℝ :=
  (φ 0 - α) * h 0 + ((φ 1 - α) * h 1) * u + ((φ 2 - α) * h 2) * u ^ 2

/-- **Raíz doble forzada.** Una cuadrática no negativa en `(0,∞)` que se anula en un punto
interior `u₀ > 0` tiene allí una raíz doble y coeficiente principal no negativo.
Es el sustituto (en soporte de 3 puntos) del paso de variación decreciente / TP₂. -/
theorem quadratic_double_root (A B C u₀ : ℝ) (hu : 0 < u₀)
    (hge : ∀ u : ℝ, 0 < u → 0 ≤ A + B * u + C * u ^ 2)
    (h0 : A + B * u₀ + C * u₀ ^ 2 = 0) :
    B + 2 * C * u₀ = 0 ∧ 0 ≤ C := by
  have hmin : IsLocalMin (fun u : ℝ => A + B * u + C * u ^ 2) u₀ := by
    have hop : {u : ℝ | 0 < u} ∈ nhds u₀ := Ioi_mem_nhds hu
    filter_upwards [hop] with u hu'
    show A + B * u₀ + C * u₀ ^ 2 ≤ A + B * u + C * u ^ 2
    rw [h0]
    exact hge u hu'
  have hderiv : HasDerivAt (fun u : ℝ => A + B * u + C * u ^ 2) (B + 2 * C * u₀) u₀ := by
    have h2 : HasDerivAt (fun u : ℝ => C * u ^ 2) (C * (2 * u₀ ^ 1)) u₀ :=
      (hasDerivAt_pow 2 u₀).const_mul C
    have h1 : HasDerivAt (fun u : ℝ => B * u) B u₀ := by
      simpa using (hasDerivAt_id u₀).const_mul B
    have h0' : HasDerivAt (fun _ : ℝ => A) 0 u₀ := hasDerivAt_const _ _
    have h := (h0'.add h1).add h2
    convert h using 1
    ring
  have hS : B + 2 * C * u₀ = 0 := hmin.hasDerivAt_eq_zero hderiv
  refine ⟨hS, ?_⟩
  have hA : A = C * u₀ ^ 2 := by nlinarith [h0, hS]
  have hval : A + B * (u₀ + 1) + C * (u₀ + 1) ^ 2 = C := by
    rw [hA]; nlinarith [hS]
  have hpos := hge (u₀ + 1) (by linarith)
  linarith

/-- book: capitulos/cap04_herramientas.typ:1330 (key: thm:ch4-umpu), parte 1 —
**insesgamiento ⟹ raíz doble**: si un test de nivel `α` en `u₀` es insesgado
(`0 ≤ β_φ(η) − α` para todo `η`, es decir `0 ≤ lik` en todo `u > 0`), su exceso de potencia es
`C(u − u₀)²` con `C = (φ₂ − α)h₂ ≥ 0`; en particular `(φ₁ − α)h₁ = −2C u₀`, que es la
condición `EE_{u₀}[Tφ] = α·EE_{u₀}[T]` del libro.
Fidelidad declarada: soporte `{0,1,2}`, `T(t) = t`, `u = e^η`. -/
theorem unbiased_double_root (h φ : Fin 3 → ℝ) {α u₀ : ℝ} (hu : 0 < u₀)
    (hsize : lik h φ α u₀ = 0) (hunb : ∀ u : ℝ, 0 < u → 0 ≤ lik h φ α u) :
    (φ 1 - α) * h 1 = -2 * ((φ 2 - α) * h 2) * u₀ ∧ 0 ≤ (φ 2 - α) * h 2 := by
  have key := quadratic_double_root ((φ 0 - α) * h 0) ((φ 1 - α) * h 1)
    ((φ 2 - α) * h 2) u₀ hu
    (fun u huu => hunb u huu) hsize
  exact ⟨by linarith [key.1], key.2⟩

/-- book: capitulos/cap04_herramientas.typ:1330 (key: thm:ch4-umpu), parte 2 —
**cota del coeficiente**: como el test toma valores en `[0,1]`, `φ₁ ≥ 0`, luego
`C ≤ α·h₁/(2u₀)`. Esta constante es la que fija las dos colas del test UMPU. -/
theorem umpu_coefficient_bound (h φ : Fin 3 → ℝ) (hpos : ∀ t, 0 < h t) {α u₀ : ℝ}
    (hα : 0 < α) (hu : 0 < u₀) (hb : 0 ≤ φ 1)
    (hsize : lik h φ α u₀ = 0) (hunb : ∀ u : ℝ, 0 < u → 0 ≤ lik h φ α u) :
    (φ 2 - α) * h 2 ≤ α * h 1 / (2 * u₀) := by
  obtain ⟨hS, hC⟩ := unbiased_double_root h φ hu hsize hunb
  have h1 := hpos 1
  have h1b : 0 < α * h 1 := mul_pos hα h1
  -- `(φ₁ − α)h₁ = −2Cu₀` y `φ₁ ≥ 0` dan `−αh₁ ≤ −2Cu₀`
  have hle : -(α * h 1) ≤ -2 * ((φ 2 - α) * h 2) * u₀ := by
    have : (φ 1 - α) * h 1 = φ 1 * h 1 - α * h 1 := by ring
    nlinarith [hS, hb, h1, hα]
  rw [le_div_iff₀ (by linarith : (0 : ℝ) < 2 * u₀)]
  nlinarith [hle]

/-- book: capitulos/cap04_herramientas.typ:1330 (key: thm:ch4-umpu), parte 3 —
**UMPU**: ningún test insesgado de nivel `α` supera el exceso de potencia
`(α h₁/(2u₀))·(u − u₀)²`, que es el del test de las dos colas. -/
theorem umpu_three_point (h φ : Fin 3 → ℝ) (hpos : ∀ t, 0 < h t) {α u₀ : ℝ}
    (hα : 0 < α) (hu : 0 < u₀) (hb : 0 ≤ φ 1)
    (hsize : lik h φ α u₀ = 0) (hunb : ∀ u : ℝ, 0 < u → 0 ≤ lik h φ α u) :
    ∀ u : ℝ, 0 < u → lik h φ α u ≤ (α * h 1 / (2 * u₀)) * (u - u₀) ^ 2 := by
  obtain ⟨hS, hC⟩ := unbiased_double_root h φ hu hsize hunb
  have hbound := umpu_coefficient_bound h φ hpos hα hu hb hsize hunb
  intro u _
  have hfac : lik h φ α u = ((φ 2 - α) * h 2) * (u - u₀) ^ 2 := by
    have hs := hsize
    unfold lik at hs ⊢
    nlinarith [hs, hS]
  rw [hfac]
  exact mul_le_mul_of_nonneg_right hbound (sq_nonneg _)

/-- book: capitulos/cap04_herramientas.typ:1330 (key: thm:ch4-umpu), parte 4 —
**el test que alcanza la cota**: con `φ₁ = 0` (no se rechaza en el centro del soporte),
`φ₀ = α + C·u₀²/h₀` y `φ₂ = α + C/h₂`, `C = αh₁/(2u₀)`, el test tiene tamaño `α`, es insesgado
y su exceso de potencia es exactamente `C(u − u₀)²`: por `umpu_three_point` es UMPU.
Fidelidad declarada: es la forma `1{T < c₁} + 1{T > c₂}` con aleatorización en los extremos
(los valores `φ₀, φ₂ ∈ [0,1]` son la probabilidad de rechazo en cada cola). -/
theorem umpu_attainment (h φ : Fin 3 → ℝ) (hpos : ∀ t, 0 < h t) {α u₀ : ℝ}
    (hα : 0 < α) (hu : 0 < u₀)
    (hφ0 : φ 0 = α + (α * h 1 / (2 * u₀)) * u₀ ^ 2 / h 0)
    (hφ1 : φ 1 = 0)
    (hφ2 : φ 2 = α + (α * h 1 / (2 * u₀)) / h 2) :
    lik h φ α u₀ = 0 ∧ (∀ u : ℝ, 0 ≤ lik h φ α u) ∧
      (∀ u : ℝ, lik h φ α u = (α * h 1 / (2 * u₀)) * (u - u₀) ^ 2) := by
  have h0ne : h 0 ≠ 0 := ne_of_gt (hpos 0)
  have h2ne : h 2 ≠ 0 := ne_of_gt (hpos 2)
  have key : ∀ u : ℝ, lik h φ α u = (α * h 1 / (2 * u₀)) * (u - u₀) ^ 2 := by
    intro u
    unfold lik
    rw [hφ0, hφ1, hφ2]
    field_simp
    ring
  refine ⟨?_, ?_, key⟩
  · rw [key u₀]; ring
  · intro u
    rw [key u]
    have hC : 0 ≤ α * h 1 / (2 * u₀) :=
      div_nonneg (mul_nonneg (le_of_lt hα) (le_of_lt (hpos 1))) (by positivity)
    exact mul_nonneg hC (sq_nonneg _)

end Cap04M3U
