import Mathlib

/-!
# Book.Cap06FallosM6 — capítulos 5 y 6 (m6, enjambre smw9820kx)

Claves pendientes cerradas aquí:

* `ex:ch9-state` (capitulos/cap05_incrustacion.typ:164)
* `ex:ch9-estados-infinitos` (capitulos/cap06_fallos.typ:33)
* `ex:ch9-horizonte-infinito` (capitulos/cap06_fallos.typ:75)
* `thm:ch9-eficiencia` (capitulos/cap06_fallos.typ:227)
* `ex:ch9-fallo-noest` (capitulos/cap06_fallos.typ:269)

Fidelidad declarada (plan §4). El idioma es el del proyecto
(`Book/Cap06Fronteras.lean`, `Book/Cap04Ch4M6.lean`): espacio muestral
`Ω` finito con pesos `w ≥ 0` de suma 1, esperanza `E` como suma ponderada
y varianza `var` como `E[(Y − E Y)²]`. Donde el libro usa una ley normal o
una iid de Bernoulli, el enunciado formal toma *los momentos* que esa ley
produce como hipótesis explícitas (`E Z = 0`, `E Z² = 1`, `E Z³ = 0`,
`E Z⁴ = 3` para `N(0,1)`; `E k = m p`, `E k² − (E k)² = m p (1−p)` y
covarianza nula para sumas de Bernoulli independientes). La parte
algebraica —que es la que el libro calcula— queda demostrada; la parte
de modelo queda declarada como hipótesis, igual que en el resto del
proyecto. Cero `sorry`: ninguna declaración usa `native_decide` ni axiomas
adicionales.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1600000

open Finset BigOperators
open scoped Topology

universe u

namespace Cap06M6

/-! ## Funcional de esperanza y varianza sobre un espacio finito -/

section Esperanza

variable {Ω : Type u} [Fintype Ω]

/-- Esperanza bajo pesos `w` sobre un espacio muestral finito:
`E_w[f] = ∑_ω w(ω) f(ω)`. Normalización y positividad de `w` no se
exigen en la definición; entran como hipótesis donde se usan. -/
noncomputable def E (w : Ω → ℝ) (f : Ω → ℝ) : ℝ := ∑ ω, w ω * f ω

/-- Congruencia puntual de la esperanza. -/
theorem E_congr (w : Ω → ℝ) {f g : Ω → ℝ} (h : ∀ ω, f ω = g ω) : E w f = E w g := by
  simp only [E]
  exact Finset.sum_congr rfl fun ω _ => by rw [h ω]

/-- La esperanza de la constante uno es la masa total. -/
theorem E_one (w : Ω → ℝ) : E w (fun _ => (1 : ℝ)) = ∑ ω, w ω := by
  simp only [E, mul_one]

/-- Linealidad de la esperanza en dos términos. -/
theorem E_two (w : Ω → ℝ) (a b : ℝ) (f g : Ω → ℝ) :
    E w (fun ω => a * f ω + b * g ω) = a * E w f + b * E w g := by
  have h : ∀ ω, w ω * (a * f ω + b * g ω) = w ω * a * f ω + w ω * b * g ω :=
    fun ω => by ring
  have h1 : ∀ ω, w ω * a * f ω = a * (w ω * f ω) := fun ω => by ring
  have h2 : ∀ ω, w ω * b * g ω = b * (w ω * g ω) := fun ω => by ring
  simp only [E, h, Finset.sum_add_distrib, h1, h2, Finset.mul_sum]

/-- Linealidad de la esperanza en tres términos. -/
theorem E_three (w : Ω → ℝ) (a b c : ℝ) (f g h : Ω → ℝ) :
    E w (fun ω => a * f ω + b * g ω + c * h ω)
      = a * E w f + b * E w g + c * E w h := by
  have key : ∀ ω, w ω * (a * f ω + b * g ω + c * h ω)
      = w ω * a * f ω + w ω * b * g ω + w ω * c * h ω := fun ω => by ring
  have h1 : ∀ ω, w ω * a * f ω = a * (w ω * f ω) := fun ω => by ring
  have h2 : ∀ ω, w ω * b * g ω = b * (w ω * g ω) := fun ω => by ring
  have h3 : ∀ ω, w ω * c * h ω = c * (w ω * h ω) := fun ω => by ring
  simp only [E, key, Finset.sum_add_distrib, h1, h2, h3, Finset.mul_sum]

/-- La esperanza de una diferencia es la diferencia de esperanzas. -/
theorem E_sub (w : Ω → ℝ) (f g : Ω → ℝ) : E w (fun ω => f ω - g ω) = E w f - E w g := by
  have h2 : E w (fun ω => f ω + -g ω) = E w f + -E w g := by
    have h := E_two w 1 (-1) f g
    simpa using h
  calc E w (fun ω => f ω - g ω) = E w (fun ω => f ω + -g ω) :=
        E_congr w (fun ω => by ring)
    _ = E w f + -E w g := h2
    _ = E w f - E w g := by ring

/-- La varianza bajo pesos `w`: `Var(Y) = E[(Y − E Y)²]`. -/
noncomputable def var (w : Ω → ℝ) (f : Ω → ℝ) : ℝ :=
  E w (fun ω => (f ω - E w f) ^ 2)

/-- Forma desarrollada de la varianza: `Var(Y) = E[Y²] − (E Y)²`. -/
theorem var_eq (w : Ω → ℝ) (hw1 : ∑ ω, w ω = 1) (f : Ω → ℝ) :
    var w f = E w (fun ω => f ω ^ 2) - (E w f) ^ 2 := by
  have hpt : ∀ ω, (f ω - E w f) ^ 2
      = 1 * (f ω * f ω) + (-(2 * E w f)) * f ω + ((E w f) ^ 2) * (1 : ℝ) :=
    fun ω => by ring
  have hthree := E_three w 1 (-(2 * E w f)) ((E w f) ^ 2)
    (fun ω => f ω * f ω) f (fun _ => (1 : ℝ))
  have hone : E w (fun _ => (1 : ℝ)) = 1 := by rw [E_one, hw1]
  rw [var, E_congr w hpt, hthree, hone]
  have hsq : E w (fun ω => f ω * f ω) = E w (fun ω => f ω ^ 2) :=
    E_congr w (fun ω => by ring)
  rw [hsq]
  ring

/-- Expansión del cuadrado de una combinación lineal: la base de todos los
cálculos de varianza de este módulo. -/
theorem E_sq (w : Ω → ℝ) (a b : ℝ) (f g : Ω → ℝ) :
    E w (fun ω => (a * f ω + b * g ω) ^ 2)
      = a ^ 2 * E w (fun ω => f ω ^ 2) + (2 * a * b) * E w (fun ω => f ω * g ω)
        + b ^ 2 * E w (fun ω => g ω ^ 2) := by
  have hpt : ∀ ω, (a * f ω + b * g ω) ^ 2
      = a ^ 2 * (f ω * f ω) + (2 * a * b) * (f ω * g ω) + b ^ 2 * (g ω * g ω) :=
    fun ω => by ring
  have hsqf : ∀ ω, f ω * f ω = f ω ^ 2 := fun ω => by ring
  have hsqg : ∀ ω, g ω * g ω = g ω ^ 2 := fun ω => by ring
  rw [E_congr w hpt, E_three]
  simp only [hsqf, hsqg]

end Esperanza

/-! ## thm:ch9-eficiencia — la varianza asintótica depende del funcional -/

section Eficiencia

variable {Ω : Type u} [Fintype Ω]

/-- **book: capitulos/cap06_fallos.typ:227 (key: thm:ch9-eficiencia)** —
eficiencia no equivale a normalidad de cualquier funcional.

Con `X̄ = μ + σ Z`, `E Z = 0`, `E Z² = 1`, `E Z³ = 0`, `E Z⁴ = 3` (los
momentos de `N(0,1)`; en el libro `X̄_n ~ N(θ, 1/n)`, es decir
`σ² = 1/n`): (i) `E[X̄²] = μ² + σ²`; (ii) `Var(X̄²) = 4 μ² σ² + 2 σ⁴`.

Con `σ² = 1/n` esto da `Var(X̄²) = 4θ²/n + 2/n²`, y por tanto
`n Var(X̄²) → 4 θ²`: en `θ ≠ 0` la escala `√n` con varianza `4θ²` es la
del método delta; en `θ = 0` la varianza de `√n X̄²` es `2/n → 0` y el
término dominante es el segundo orden `n X̄²` (media `1`, varianza `2`,
las de `χ²₁`). La fórmula normal obtenida de una derivada nula no
describe el funcional.

Fidelidad: los cuatro momentos de `Z` son hipótesis (los de `N(0,1)`); el
cálculo de `E[X̄²]` y `Var(X̄²)` es el del libro y está demostrado. -/
theorem ch9_eficiencia (w : Ω → ℝ) (hw1 : ∑ ω, w ω = 1) (Z : Ω → ℝ)
    (h1 : E w Z = 0) (h2 : E w (fun ω => Z ω ^ 2) = 1)
    (h3 : E w (fun ω => Z ω ^ 3) = 0) (h4 : E w (fun ω => Z ω ^ 4) = 3)
    (μ σ : ℝ) :
    E w (fun ω => (μ + σ * Z ω) ^ 2) = μ ^ 2 + σ ^ 2 ∧
    var w (fun ω => (μ + σ * Z ω) ^ 2) = 4 * μ ^ 2 * σ ^ 2 + 2 * σ ^ 4 := by
  have hone : E w (fun _ => (1 : ℝ)) = 1 := by rw [E_one, hw1]
  have hsq : E w (fun ω => Z ω * Z ω) = 1 := by
    rw [E_congr w (fun ω => by ring : ∀ ω, Z ω * Z ω = Z ω ^ 2), h2]
  -- (i) media de `X̄²`
  have hpt1 : ∀ ω, (μ + σ * Z ω) ^ 2
      = μ ^ 2 * (1 : ℝ) + (2 * μ * σ) * Z ω + σ ^ 2 * (Z ω * Z ω) := fun ω => by ring
  have hEY : E w (fun ω => (μ + σ * Z ω) ^ 2) = μ ^ 2 + σ ^ 2 := by
    rw [E_congr w hpt1, E_three, hone, h1, hsq]
    ring
  refine ⟨hEY, ?_⟩
  -- (ii) varianza: `Y − E Y = 2μσ Z + σ² (Z² − 1)`
  have hvar : var w (fun ω => (μ + σ * Z ω) ^ 2)
      = E w (fun ω => (2 * μ * σ * Z ω + σ ^ 2 * (Z ω ^ 2 - 1)) ^ 2) := by
    rw [var]
    exact E_congr w (fun ω => by rw [hEY]; ring)
  -- momentos auxiliares de `g = Z² − 1`
  have hfg : E w (fun ω => Z ω * (Z ω ^ 2 - 1)) = 0 := by
    have hpt : ∀ ω, Z ω * (Z ω ^ 2 - 1) = 1 * (Z ω ^ 3) + (-1) * Z ω := fun ω => by ring
    rw [E_congr w hpt, E_two, h3, h1]
    ring
  have hgg : E w (fun ω => (Z ω ^ 2 - 1) ^ 2) = 2 := by
    have hpt : ∀ ω, (Z ω ^ 2 - 1) ^ 2
        = 1 * (Z ω ^ 4) + (-2 : ℝ) * (Z ω ^ 2) + 1 * (1 : ℝ) := fun ω => by ring
    rw [E_congr w hpt, E_three, h4, h2, hone]
    norm_num
  rw [hvar, E_sq w (2 * μ * σ) (σ ^ 2) Z (fun ω => Z ω ^ 2 - 1), h2, hfg, hgg]
  ring

end Eficiencia

/-! ## ex:ch9-state — memoria suficiente para observaciones normales -/

section MemoriaSuficiente

/-- Densidad normal de media `μ` y varianza `s` en `y`:
`(2πs)^{-1/2} · exp(−(y−μ)²/(2s))`. `s = 1` es el caso de varianza
conocida; `s = σ²` el de varianza desconocida. -/
noncomputable def gaussDens (μ s y : ℝ) : ℝ :=
  (Real.sqrt (2 * Real.pi * s))⁻¹ * Real.exp (-((y - μ) ^ 2) / (2 * s))

/-- Producto de densidades normales (muestra de tamaño `n`):
`∏ᵢ f(yᵢ) = c(s)^n · exp(−∑ᵢ(yᵢ−μ)²/(2s))`. -/
theorem prod_gaussDens (n : ℕ) (y : Fin n → ℝ) (μ s : ℝ) :
    ∏ i, gaussDens μ s (y i)
      = ((Real.sqrt (2 * Real.pi * s))⁻¹) ^ n * Real.exp (-(∑ i, (y i - μ) ^ 2) / (2 * s)) := by
  have hsum : ∑ i, -((y i - μ) ^ 2) / (2 * s) = -(∑ i, (y i - μ) ^ 2) / (2 * s) := by
    rw [← Finset.sum_div, Finset.sum_neg_distrib]
  simp only [gaussDens, Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
    Fintype.card_fin, ← Real.exp_sum, hsum]

/-- Traslación de la suma de cuadrados:
`∑ᵢ(yᵢ−μ)² = ∑ᵢyᵢ² − 2μ∑ᵢyᵢ + nμ²`. -/
theorem sum_sq_shift (n : ℕ) (y : Fin n → ℝ) (μ : ℝ) :
    ∑ i, (y i - μ) ^ 2 = ∑ i, (y i) ^ 2 - 2 * μ * (∑ i, y i) + n * μ ^ 2 := by
  have hpt : ∀ i, (y i - μ) ^ 2 = ((y i) ^ 2 - 2 * μ * y i) + μ ^ 2 := fun i => by ring
  calc ∑ i, (y i - μ) ^ 2 = ∑ i, (((y i) ^ 2 - 2 * μ * y i) + μ ^ 2) :=
        Finset.sum_congr rfl fun i _ => hpt i
    _ = (∑ i, (y i) ^ 2 - 2 * μ * (∑ i, y i)) + n * μ ^ 2 := by
        rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_const,
          Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- El exponente del cociente de verosimilitudes normales depende de la
muestra sólo a través de `S1 = ∑ᵢyᵢ` y `S2 = ∑ᵢyᵢ²`. -/
noncomputable def gaussExp (n : ℕ) (S1 S2 μ s μ' s' : ℝ) : ℝ :=
  -(S2 / (2 * s)) + S2 / (2 * s') + μ * S1 / s - μ' * S1 / s'
    - n * μ ^ 2 / (2 * s) + n * μ' ^ 2 / (2 * s')

/-- Cociente de verosimilitudes normales en forma factorizada. -/
theorem ratio_gaussDens (n : ℕ) (y : Fin n → ℝ) (μ s μ' s' : ℝ)
    (hs : 0 < s) (hs' : 0 < s') :
    (∏ i, gaussDens μ s (y i)) / (∏ i, gaussDens μ' s' (y i))
      = ((Real.sqrt (2 * Real.pi * s))⁻¹ / (Real.sqrt (2 * Real.pi * s'))⁻¹) ^ n
          * Real.exp (gaussExp n (∑ i, y i) (∑ i, (y i) ^ 2) μ s μ' s') := by
  have hc : (Real.sqrt (2 * Real.pi * s))⁻¹ ≠ 0 := by
    have hp : 0 < Real.sqrt (2 * Real.pi * s) := Real.sqrt_pos.mpr (by positivity)
    exact inv_ne_zero hp.ne'
  have hc' : (Real.sqrt (2 * Real.pi * s'))⁻¹ ≠ 0 := by
    have hp : 0 < Real.sqrt (2 * Real.pi * s') := Real.sqrt_pos.mpr (by positivity)
    exact inv_ne_zero hp.ne'
  have hexp : -(∑ i, (y i - μ) ^ 2) / (2 * s) - -(∑ i, (y i - μ') ^ 2) / (2 * s')
      = gaussExp n (∑ i, y i) (∑ i, (y i) ^ 2) μ s μ' s' := by
    rw [sum_sq_shift, sum_sq_shift]
    simp only [gaussExp]
    field_simp
    ring
  rw [prod_gaussDens, prod_gaussDens, ← div_mul_div_comm, ← div_pow, ← Real.exp_sub, hexp]

/-- **book: capitulos/cap05_incrustacion.typ:164 (key: ex:ch9-state)** —
memoria suficiente para observaciones normales.

(a) *Varianza conocida.* Con `Yᵢ ~ N(μ, s)` independientes y tamaño `n`
fijo, si dos muestras tienen la misma suma `∑ᵢyᵢ` entonces sus cocientes
de verosimilitud `L(μ)/L(μ')` coinciden: `∑ᵢYᵢ` es suficiente para `μ`.
(b) *Varianza desconocida.* Si además coincide `∑ᵢyᵢ²`, los cocientes
`L(μ,s)/L(μ',s')` coinciden para todo par de parámetros: la pareja
`(∑ᵢYᵢ, ∑ᵢYᵢ²)` es suficiente para `(μ, σ²)`. Se debe almacenar también
la suma de cuadrados; el contador `n` es información de diseño.

Fidelidad: la normalidad entra como la forma explícita de la densidad;
no se formaliza aquí el criterio de factorización de Fisher–Neyman
general, sólo la identidad de cocientes que el libro usa. -/
theorem ch9_state (n : ℕ) (y y' : Fin n → ℝ)
    (hsum : ∑ i, y i = ∑ i, y' i) (hsq : ∑ i, (y i) ^ 2 = ∑ i, (y' i) ^ 2)
    (μ s μ' s' : ℝ) (hs : 0 < s) (hs' : 0 < s') :
    (∏ i, gaussDens μ s (y i)) / (∏ i, gaussDens μ' s' (y i))
      = (∏ i, gaussDens μ s (y' i)) / (∏ i, gaussDens μ' s' (y' i)) := by
  rw [ratio_gaussDens n y μ s μ' s' hs hs', ratio_gaussDens n y' μ s μ' s' hs hs',
    hsum, hsq]

/-- La parte (a) del ejemplo: con varianza **conocida** basta `∑ᵢyᵢ`; la
suma de cuadrados no interviene. -/
theorem ch9_state_varianza_conocida (n : ℕ) (y y' : Fin n → ℝ)
    (hsum : ∑ i, y i = ∑ i, y' i) (μ μ' s : ℝ) (hs : 0 < s) :
    (∏ i, gaussDens μ s (y i)) / (∏ i, gaussDens μ' s (y i))
      = (∏ i, gaussDens μ s (y' i)) / (∏ i, gaussDens μ' s (y' i)) := by
  have hself : ∀ (S1 S2 : ℝ), gaussExp n S1 S2 μ s μ' s
      = (μ - μ') * S1 / s - n * (μ ^ 2 - μ' ^ 2) / (2 * s) := by
    intro S1 S2
    simp only [gaussExp]
    field_simp
    ring
  rw [ratio_gaussDens n y μ s μ' s hs hs, ratio_gaussDens n y' μ s μ' s hs hs,
    hself, hself, hsum]

/-- Estado de actualización del ejemplo: `(n, suma)` — el contador y la
suma acumulada. -/
def updState (st : ℕ × ℝ) (y : ℝ) : ℕ × ℝ := (st.1 + 1, st.2 + y)

/-- Procesar una lista con `updState` desde `(0,0)` devuelve exactamente
`(longitud, suma)`: el estado `{"n": …, "suma": …}` del libro. -/
theorem updState_run (ys : List ℝ) :
    ys.foldl updState (0, 0) = (ys.length, ys.sum) := by
  have hgen : ∀ (m : ℕ) (s : ℝ), ys.foldl updState (m, s) = (m + ys.length, s + ys.sum) := by
    induction ys with
    | nil => intro m s; simp
    | cons a as ih =>
        intro m s
        simp only [List.foldl_cons, updState, ih, List.length_cons, List.sum_cons]
        exact Prod.ext (by omega) (by ring)
  simpa using hgen 0 0

end MemoriaSuficiente

/-! ## ex:ch9-estados-infinitos — estado continuo, recompensa no acotada -/

section EstadosInfinitos

/-- La desigualdad de tres términos del libro: `(x+y+z)² ≤ 3(x²+y²+z²)`. -/
theorem three_sq (x y z : ℝ) : (x + y + z) ^ 2 ≤ 3 * (x ^ 2 + y ^ 2 + z ^ 2) := by
  nlinarith [sq_nonneg (x - y), sq_nonneg (y - z), sq_nonneg (x - z)]

/-- Acciones en `{−1,1}`: la suma de las `t` primeras está acotada por `t`
(sólo se usa `|A j| ≤ 1`, no el cardinal del espacio de estados). -/
theorem action_sum_bound (t : ℕ) (A : ℕ → ℝ) (hA : ∀ j, |A j| ≤ 1) :
    |∑ j ∈ Finset.range t, A j| ≤ t := by
  calc |∑ j ∈ Finset.range t, A j| ≤ ∑ j ∈ Finset.range t, |A j| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _j ∈ Finset.range t, (1 : ℝ) := Finset.sum_le_sum fun j _ => hA j
    _ = t := by simp

/-- Cota pathwise del ejemplo. Con `S_t = s + ∑_{j<t}A_j + ∑_{j<t}ε_j`,
`|A_j| ≤ 1` y `(∑_{j<t}ε_j)² ≤ t` (el tamaño de la varianza de las
innovaciones unitarias), se tiene `S_t² ≤ 3s² + 3t² + 3t`. -/
theorem state_bound (s : ℝ) (A ε : ℕ → ℝ) (t : ℕ) (hA : ∀ j, |A j| ≤ 1)
    (hε : (∑ j ∈ Finset.range t, ε j) ^ 2 ≤ t) :
    (s + ∑ j ∈ Finset.range t, A j + ∑ j ∈ Finset.range t, ε j) ^ 2
      ≤ 3 * (s ^ 2 + (t : ℝ) ^ 2 + (t : ℝ)) := by
  have hbase := three_sq s (∑ j ∈ Finset.range t, A j) (∑ j ∈ Finset.range t, ε j)
  have hX : (∑ j ∈ Finset.range t, A j) ^ 2 ≤ (t : ℝ) ^ 2 := by
    refine sq_le_sq.mpr ?_
    have ht : |(t : ℝ)| = (t : ℝ) := abs_of_nonneg (Nat.cast_nonneg t)
    rw [ht]
    exact action_sum_bound t A hA
  nlinarith

/-- Núcleo geométrico del ejemplo: si el segundo momento de `S_t` está
acotado por `3s² + 3t² + 3t`, el retorno cuadrático descontado es finito.
`M t` es `E[S_t²]`. -/
theorem discounted_moment_summable (s γ : ℝ) (hγ0 : 0 < γ) (hγ1 : γ < 1)
    (M : ℕ → ℝ) (hM0 : ∀ t, 0 ≤ M t)
    (hM : ∀ t, M t ≤ 3 * (s ^ 2 + (t : ℝ) ^ 2 + (t : ℝ))) :
    Summable (fun t : ℕ => γ ^ t * M t) := by
  have hlt : ‖γ‖ < 1 := by rw [Real.norm_eq_abs, abs_of_pos hγ0]; exact hγ1
  have hgeom : Summable (fun t : ℕ => γ ^ t) := summable_geometric_iff_norm_lt_one.mpr hlt
  have h1 : Summable (fun t : ℕ => (3 * s ^ 2) * γ ^ t) := hgeom.mul_left _
  have h2 : Summable (fun t : ℕ => 3 * ((t : ℝ) ^ 1 * γ ^ t)) :=
    (summable_pow_mul_geometric_of_norm_lt_one 1 hlt).mul_left 3
  have h3 : Summable (fun t : ℕ => 3 * ((t : ℝ) ^ 2 * γ ^ t)) :=
    (summable_pow_mul_geometric_of_norm_lt_one 2 hlt).mul_left 3
  have hbig : Summable (fun t : ℕ => (3 * s ^ 2) * γ ^ t + 3 * ((t : ℝ) ^ 1 * γ ^ t)
      + 3 * ((t : ℝ) ^ 2 * γ ^ t)) := (h1.add h2).add h3
  refine Summable.of_nonneg_of_le (fun t => ?_) (fun t => ?_) hbig
  · exact mul_nonneg (pow_nonneg hγ0.le t) (hM0 t)
  · have hpt : (3 * s ^ 2) * γ ^ t + 3 * ((t : ℝ) ^ 1 * γ ^ t) + 3 * ((t : ℝ) ^ 2 * γ ^ t)
        = γ ^ t * (3 * (s ^ 2 + (t : ℝ) ^ 2 + (t : ℝ))) := by ring
    rw [hpt]
    exact mul_le_mul_of_nonneg_left (hM t) (pow_nonneg hγ0.le t)

/-- **book: capitulos/cap06_fallos.typ:33 (key: ex:ch9-estados-infinitos)** —
espacio de estados infinito.

(a) *Cota de segundo momento pathwise*: para `S_{t+1} = S_t + A_t + ε_t` con
acciones en `{−1,1}` y `(∑_{j<t}ε_j)² ≤ t` (innovaciones de varianza
unitaria), `S_t² ≤ 3s² + 3t² + 3t`;
(b) *conclusión*: con `0 < γ < 1`, `∑_t γ^t E[S_t²] < ∞`. El estado
continuo y la recompensa no acotada `−S_t²` no impiden que el retorno
descontado exista: la continuidad del espacio no es el problema.
La existencia de una política óptima y la validez de un algoritmo no se
deducen de esta cota (el libro tampoco las afirma).

Fidelidad: la cota de `(∑ε)²` es el dato de segundo momento que en el
libro produce la independencia normal unitaria (`E[(∑_{j<t}ε_j)²] = t`);
aquí entra como hipótesis explícita sobre la trayectoria, y (b) es la
comparación con la serie geométrica. -/
theorem ch9_estados_infinitos (s : ℝ) (A ε : ℕ → ℝ) (hA : ∀ j, |A j| ≤ 1)
    (hε : ∀ t, (∑ j ∈ Finset.range t, ε j) ^ 2 ≤ t)
    (γ : ℝ) (hγ0 : 0 < γ) (hγ1 : γ < 1) :
    (∀ t, (s + ∑ j ∈ Finset.range t, A j + ∑ j ∈ Finset.range t, ε j) ^ 2
        ≤ 3 * (s ^ 2 + (t : ℝ) ^ 2 + (t : ℝ))) ∧
    Summable (fun t : ℕ =>
      γ ^ t * (s + ∑ j ∈ Finset.range t, A j + ∑ j ∈ Finset.range t, ε j) ^ 2) := by
  refine ⟨fun t => state_bound s A ε t hA (hε t), ?_⟩
  refine discounted_moment_summable s γ hγ0 hγ1
    (fun t => (s + ∑ j ∈ Finset.range t, A j + ∑ j ∈ Finset.range t, ε j) ^ 2)
    (fun t => sq_nonneg _) (fun t => state_bound s A ε t hA (hε t))

end EstadosInfinitos

/-! ## ex:ch9-horizonte-infinito — tres funcionales distintos -/

section HorizonteInfinito

/-- Serie geométrica: con `0 ≤ γ < 1`, `∑_{t≥0} γ^t = (1−γ)⁻¹`. -/
theorem tsum_geometric_nonneg (γ : ℝ) (h0 : 0 ≤ γ) (h1 : γ < 1) :
    ∑' t : ℕ, γ ^ t = (1 - γ)⁻¹ := by
  have hlt : ‖γ‖ < 1 := by rw [Real.norm_eq_abs, abs_of_nonneg h0]; exact h1
  exact tsum_geometric_of_norm_lt_one hlt

/-- Total descontado de un estado absorbente con recompensa `r`:
`∑_{t≥0} γ^t r = r (1−γ)⁻¹`. -/
theorem tsum_geometric_mul (γ r : ℝ) (h0 : 0 ≤ γ) (h1 : γ < 1) :
    ∑' t : ℕ, γ ^ t * r = r * (1 - γ)⁻¹ := by
  rw [tsum_mul_right, tsum_geometric_nonneg γ h0 h1, mul_comm]

/-- Con `γ = 1` y recompensa positiva el total diverge: la serie no es
sumable. -/
theorem horizonte_diverge (r : ℝ) (hr : 0 < r) :
    ¬ Summable (fun t : ℕ => (1 : ℝ) ^ t * r) := by
  have hfun : (fun t : ℕ => (1 : ℝ) ^ t * r) = fun _ => r := by
    funext t; simp
  rw [hfun]
  intro h
  have h1 : r = 0 := (summable_const_iff r).mp h
  linarith

/-- Rendimiento medio por paso de un estado absorbente: el promedio de
`n` recompensas constantes vale `r`. -/
theorem mean_payoff_eventually (r : ℝ) (n : ℕ) (hn : n ≠ 0) :
    (∑ t ∈ Finset.range n, r) / (n : ℝ) = r := by
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  field_simp

/-- El rendimiento medio por paso converge a `r`. -/
theorem mean_payoff_tendsto (r : ℝ) :
    Filter.Tendsto (fun n : ℕ => (∑ t ∈ Finset.range n, r) / (n : ℝ))
      Filter.atTop (𝓝 r) := by
  refine (Filter.Tendsto.congr' ?_ tendsto_const_nhds)
  filter_upwards [Filter.eventually_gt_atTop 0] with n hn
  exact (mean_payoff_eventually r n hn.ne').symm

/-- **book: capitulos/cap06_fallos.typ:75 (key: ex:ch9-horizonte-infinito)** —
horizonte infinito sin ergodicidad.

Dos estados absorbentes con recompensas por paso `1` y `0`. Los tres
funcionales que el libro separa:
(a) con `γ = 1` el total `∑_{t≥0} 1` diverge;
(b) con `γ = 0.99` el total descontado vale `100`;
(c) el rendimiento medio por paso vale `1` en el primer estado y `0` en
el segundo — otro objetivo, con otra ecuación de evaluación;
(d) un horizonte finito de `N` decisiones con recompensas acotadas no
diverge aunque `γ = 1`: el total es `N`.
La ergodicidad no es necesaria para el retorno descontado finito, y la
garantía que se traslada depende de cuál de los funcionales se estudia. -/
theorem ch9_horizonte_infinito :
    ¬ Summable (fun t : ℕ => (1 : ℝ) ^ t * 1) ∧
    (∑' t : ℕ, (0.99 : ℝ) ^ t * 1 = 100) ∧
    (Filter.Tendsto (fun n : ℕ => (∑ t ∈ Finset.range n, (1 : ℝ)) / (n : ℝ))
        Filter.atTop (𝓝 1) ∧
      Filter.Tendsto (fun n : ℕ => (∑ t ∈ Finset.range n, (0 : ℝ)) / (n : ℝ))
        Filter.atTop (𝓝 0)) ∧
    (∀ N : ℕ, ∑ t ∈ Finset.range N, (1 : ℝ) = N) ∧
    ((1 : ℝ) ≠ 0) := by
  refine ⟨horizonte_diverge 1 one_pos, ?_, ⟨mean_payoff_tendsto 1, mean_payoff_tendsto 0⟩,
    fun N => by simp, one_ne_zero⟩
  rw [tsum_geometric_mul 0.99 1 (by norm_num) (by norm_num)]
  norm_num

end HorizonteInfinito

/-! ## ex:ch9-fallo-noest — dos regímenes: la media conjunta no es la final -/

section NoEstacionariedad

variable {Ω : Type u} [Fintype Ω]

/-- **book: capitulos/cap06_fallos.typ:269 (key: ex:ch9-fallo-noest)** —
fallo por no estacionariedad.

`n = 2m` resultados: `m` de media `1/5` seguidos de `m` de media `4/5`
(las Bernoulli `0.2` y `0.8` del libro, con varianzas `4/25` cada una y
covarianza nula entre bloques, mutuamente independientes). Entonces
(a) la media conjunta estima `1/2`, **no** la media del régimen final
`4/5`; (b) su varianza es `4/(25·(2m)) = 0.16/n`, finita y de orden `1/n`,
de modo que admite un CLT para ese promedio de regímenes.
La no estacionariedad no elimina toda inferencia: obliga a declarar qué
población y qué periodo se evalúan.

Fidelidad: los momentos de cada bloque (`E k = mp`, `E k² = (mp)² +
mp(1−p)`, covarianza nula) son las hipótesis que produce la iid de
Bernoulli; el cálculo de media y varianza de la media conjunta es el del
libro y está demostrado. -/
theorem ch9_fallo_noest (m : ℕ) (hm : 0 < m) (w : Ω → ℝ) (hw1 : ∑ ω, w ω = 1)
    (k1 k2 : Ω → ℝ)
    (h1 : E w k1 = (m : ℝ) / 5) (h2 : E w k2 = 4 * (m : ℝ) / 5)
    (h1s : E w (fun ω => k1 ω ^ 2) = (m : ℝ) ^ 2 / 25 + 4 * (m : ℝ) / 25)
    (h2s : E w (fun ω => k2 ω ^ 2) = 16 * (m : ℝ) ^ 2 / 25 + 4 * (m : ℝ) / 25)
    (hcov : E w (fun ω => k1 ω * k2 ω) = 4 * (m : ℝ) ^ 2 / 25) :
    E w (fun ω => (k1 ω + k2 ω) / (2 * (m : ℝ))) = 1 / 2 ∧
    var w (fun ω => (k1 ω + k2 ω) / (2 * (m : ℝ))) = 4 / (25 * (2 * (m : ℝ))) ∧
    ((1 / 2 : ℝ) ≠ 4 / 5) := by
  have hm0 : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
  -- (a) la media conjunta
  have hEX : E w (fun ω => (k1 ω + k2 ω) / (2 * (m : ℝ))) = 1 / 2 := by
    have hpt : ∀ ω, (k1 ω + k2 ω) / (2 * (m : ℝ))
        = (2 * (m : ℝ))⁻¹ * k1 ω + (2 * (m : ℝ))⁻¹ * k2 ω := fun ω => by ring
    rw [E_congr w hpt, E_two, h1, h2]
    field_simp
    ring
  refine ⟨hEX, ?_, by norm_num⟩
  -- (b) la varianza
  have hs1 : E w (fun ω => k1 ω * k1 ω) = (m : ℝ) ^ 2 / 25 + 4 * (m : ℝ) / 25 := by
    rw [E_congr w (fun ω => by ring : ∀ ω, k1 ω * k1 ω = k1 ω ^ 2), h1s]
  have hs2 : E w (fun ω => k2 ω * k2 ω) = 16 * (m : ℝ) ^ 2 / 25 + 4 * (m : ℝ) / 25 := by
    rw [E_congr w (fun ω => by ring : ∀ ω, k2 ω * k2 ω = k2 ω ^ 2), h2s]
  have hX2 : E w (fun ω => ((k1 ω + k2 ω) / (2 * (m : ℝ))) ^ 2)
      = 1 / 4 + 2 / (25 * (m : ℝ)) := by
    have hpt : ∀ ω, ((k1 ω + k2 ω) / (2 * (m : ℝ))) ^ 2
        = ((2 * (m : ℝ))⁻¹) ^ 2 * (k1 ω * k1 ω)
          + (2 * ((2 * (m : ℝ))⁻¹) ^ 2) * (k1 ω * k2 ω)
          + ((2 * (m : ℝ))⁻¹) ^ 2 * (k2 ω * k2 ω) := fun ω => by ring
    rw [E_congr w hpt, E_three, hs1, hs2, hcov]
    field_simp
    ring
  rw [var_eq w hw1, hEX, hX2]
  field_simp
  ring

/-- Con dos regímenes cuyas medias de bloque convergen a `1/5` y `4/5`, la
media conjunta converge a `1/2`: el estimador apunta a la mezcla, no al
régimen final (`4/5`). -/
theorem ch9_fallo_noest_tendsto (a b : ℕ → ℝ)
    (ha : Filter.Tendsto a Filter.atTop (𝓝 (1 / 5)))
    (hb : Filter.Tendsto b Filter.atTop (𝓝 (4 / 5))) :
    Filter.Tendsto (fun m : ℕ => ((m : ℝ) * a m + (m : ℝ) * b m) / (2 * (m : ℝ)))
      Filter.atTop (𝓝 (1 / 2)) := by
  have hlim : Filter.Tendsto (fun m : ℕ => (a m + b m) / 2) Filter.atTop (𝓝 (1 / 2)) := by
    have h := (ha.add hb).div_const 2
    have h3 : (1 / 5 + 4 / 5) / 2 = (1 / 2 : ℝ) := by norm_num
    rw [h3] at h
    exact h
  refine Filter.Tendsto.congr' ?_ hlim
  filter_upwards [Filter.eventually_gt_atTop 0] with m hm
  have hm0 : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
  field_simp

end NoEstacionariedad
