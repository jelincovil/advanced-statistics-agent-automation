import Mathlib

/-!
# Book.BarridoM16 — barrido de claves pendientes (m16, dirección d16)

Formalización de siete claves de `argumentos/kernel/pendientes.json` que no
aparecen en `verificacion_lean/Book/*.lean` y que no están reclamadas por las
direcciones d1–d15 del enjambre:

* `prop:ch2-suficiencia-politicas` — `capitulos/cap09_verificacion.typ:227`:
  Rao–Blackwell para reglas aleatorizadas bajo un núcleo suficiente.
* `prop:ch3-rb-q` — `capitulos/cap09_verificacion.typ:343`: la misma
  reducción para Q-estimadores, con la identidad de descomposición de la
  varianza.
* `prop:ch3-valor-cr` — `capitulos/cap09_verificacion.typ:328`: cota de
  Cramér–Rao para un funcional escalar `g(θ)`, reducida a la desigualdad de
  covarianzas (Cauchy–Schwarz).
* `ex:ch4-ar1` — `capitulos/cap04_herramientas.typ:1525`: autocovarianzas
  `σ²ρ^k` y varianza de largo plazo `τ² = σ²(1+ρ)/(1−ρ)`; el caso `ρ=3/5`.
* `ex:ch4-no-parametrico` — `capitulos/cap04_herramientas.typ:1685`: CDF
  empírica y densidad por núcleo uniforme con los dos anchos de banda.
* `ex:ch4-if-media-cuantil` — `capitulos/cap04_herramientas.typ:1900`:
  función de influencia del cuantil, media cero y varianza límite
  `τ(1−τ)/f(q_τ)²`.
* `ex:ch4-bootstrap-unidad` — `capitulos/cap04_herramientas.typ:1750`: el
  bootstrap ordinario del máximo nunca supera al máximo observado y lo
  iguala con probabilidad `1 − (1 − 1/n)^n → 1 − e⁻¹`.

Fidelidad declarada (plan §4): todos los enunciados se formalizan en su
versión **finita/discreta** — pesos `p : ι → ℝ` en lugar de medidas, sumas
finitas en lugar de integrales, y recurrencias de estacionariedad en lugar de
la construcción de un proceso estocástico. Cada teorema declara al lado qué
parte del enunciado del libro queda fuera. Cero pruebas incompletas y ninguna decision nativa;
auditoría de axiomas en `Book/AuditM16.lean`.
-/

open Finset BigOperators

set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

namespace Book.BarridoM16

/-! ## 1. `ex:ch4-ar1` — autocovarianzas y varianza de largo plazo -/

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**Autocovarianza de un AR(1) estacionario.** Se codifica el proceso por su
sucesión de autocovarianzas `c k = Cov(Z_0, Z_k)`; la estacionariedad de
`Z_t − μ = ρ(Z_{t−1} − μ) + ε_t` con innovaciones iid impone la recurrencia
`c (k+1) = ρ·c k`, y la varianza marginal es `c 0 = σ_Z²`. -/
noncomputable def autocov (s2 rho : ℝ) : ℕ → ℝ := fun k => s2 * rho ^ k

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**`Cov(Z_0, Z_k) = σ_Z² ρ^k`.** Si la sucesión de autocovarianzas satisface
la recurrencia de estacionariedad `c(k+1) = ρ c(k)` con `c(0) = σ_Z²`,
entonces `c(k) = σ_Z² ρ^k` para todo `k`.

Fidelidad declarada: se toma la recurrencia de estacionariedad como hipótesis
(no se construye el proceso gaussiano estacionario ni se prueba la existencia
de la ley conjunta); `|ρ| < 1` no se necesita para esta identidad. -/
theorem ar1_cov (c : ℕ → ℝ) (s2 rho : ℝ)
    (h0 : c 0 = s2) (hrec : ∀ k, c (k + 1) = rho * c k) :
    ∀ k, c k = s2 * rho ^ k := by
  intro k
  induction k with
  | zero => simpa using h0
  | succ n ih =>
    rw [hrec n, ih, pow_succ]
    ring

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**(auxiliar)** varianza de largo plazo de la media: `τ² = c(0) + 2 ∑_{k≥1} c(k)`. -/
noncomputable def longRunVar (c : ℕ → ℝ) : ℝ := c 0 + 2 * ∑' k : ℕ, c (k + 1)

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**`τ² = σ_Z²(1+ρ)/(1−ρ)`.** Con `|ρ| < 1`, la varianza de largo plazo de la
media de un AR(1) estacionario de autocovarianzas `σ_Z² ρ^k` vale
`σ_Z²(1+ρ)/(1−ρ)`.

Fidelidad declarada: `τ²` se define por la serie `∑'(k) c(k+1)` (suma
infinita de la autocovarianza), que es el límite `lim_n n·Var(Z̄_n)` de la
suma de autocovarianzas; la convergencia se sigue de `|ρ| < 1`. -/
theorem ar1_tau2 (s2 rho : ℝ) (hrho : |rho| < 1) :
    longRunVar (autocov s2 rho) = s2 * (1 + rho) / (1 - rho) := by
  have hnorm : ‖rho‖ < 1 := by simpa [Real.norm_eq_abs] using hrho
  have hgeo : ∑' k : ℕ, rho ^ k = (1 - rho)⁻¹ := tsum_geometric_of_norm_lt_one hnorm
  have hshift : ∑' k : ℕ, rho ^ (k + 1) = rho * (1 - rho)⁻¹ := by
    have hp : (fun k : ℕ => rho ^ (k + 1)) = fun k : ℕ => rho * rho ^ k := by
      funext k; rw [pow_succ']
    rw [hp, tsum_mul_left, hgeo]
  have h1 : longRunVar (autocov s2 rho) = s2 + 2 * (s2 * (rho * (1 - rho)⁻¹)) := by
    unfold longRunVar autocov
    simp only [pow_zero, mul_one]
    rw [tsum_mul_left, hshift]
  have hne : (1 - rho) ≠ 0 := by
    have hlt : rho < 1 := (abs_lt.mp hrho).2
    intro h
    have : rho = 1 := by linarith
    linarith
  rw [h1]
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**Caso `ρ = 0.6`.** Con `ρ = 3/5` la varianza de largo plazo es
`τ² = 4σ_Z²`: el error estándar de la media es asintóticamente el doble del
que se obtendría suponiendo independencia.

Fidelidad declarada: `0.6` se escribe `3/5` (aritmética racional exacta, plan
§4: nada de flotantes). -/
theorem ar1_tau2_rho_tres_quintos (s2 : ℝ) :
    longRunVar (autocov s2 (3 / 5)) = 4 * s2 := by
  have h := ar1_tau2 s2 (3 / 5) (by norm_num)
  rw [h]
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1525 (key: ex:ch4-ar1) —
**Tamaño efectivo `n/4`.** Con `ρ = 3/5` la varianza de la media de `n`
observaciones es `τ²/n = 4σ_Z²/n = σ_Z²/(n/4)`: equivale a `n/4`
observaciones independientes.

Fidelidad declarada: es la reescritura algebraica de `τ² = 4σ_Z²`; el libro la
presenta como «equivalencia heurística» y advierte que no es una identidad
universal para todo estimador, advertencia que no se formaliza. -/
theorem ar1_tamano_efectivo (s2 : ℝ) {n : ℕ} (hn : n ≠ 0) :
    longRunVar (autocov s2 (3 / 5)) / n = s2 / (n / 4) := by
  rw [ar1_tau2_rho_tres_quintos]
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  field_simp

/-! ## 2. `ex:ch4-no-parametrico` — CDF empírica y densidad por núcleo -/

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**(auxiliar)** muestra sintética del libro: los retornos `(0, 1, 2, 3, 4)`. -/
def muestra5 : Fin 5 → ℝ := fun i => (i : ℝ)

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**(auxiliar)** CDF empírica de una muestra finita: `F̂_n(t) = #{i : X_i ≤ t} / n`. -/
noncomputable def ecdf {n : ℕ} (x : Fin n → ℝ) (t : ℝ) : ℝ :=
  ((univ.filter (fun i => x i ≤ t)).card : ℝ) / n

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**(auxiliar)** estimador de densidad por núcleo uniforme:
`f̂_h(x) = (1/(2 n h)) ∑_i 1{|X_i − x| ≤ h}`. -/
noncomputable def kernelDens {n : ℕ} (x : Fin n → ℝ) (h x0 : ℝ) : ℝ :=
  1 / (2 * n * h) * ∑ i, (if |x i - x0| ≤ h then (1 : ℝ) else 0)

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**CDF empírica en `t = 2`:** para los retornos `(0,1,2,3,4)`,
`F̂_5(2) = 3/5` (tres observaciones `≤ 2`).

Fidelidad declarada: se calcula la CDF empírica exacta con racionales; la
afirmación «esta CDF se calcula sin fijar una familia de densidades» es
cualitativa y no se formaliza. -/
theorem no_param_ecdf :
    ecdf muestra5 2 = 3 / 5 := by
  have hset : (univ.filter (fun i : Fin 5 => muestra5 i ≤ 2)) =
      ({0, 1, 2} : Finset (Fin 5)) := by
    ext i
    simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    constructor
    · intro h
      fin_cases i
      · simp
      · simp
      · simp
      · norm_num [muestra5] at h
      · norm_num [muestra5] at h
    · rintro (rfl | rfl | rfl) <;> norm_num [muestra5]
  unfold ecdf
  rw [hset]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**Suavizado con `h = 0.6`:** en `x = 2` sólo contribuye la observación
`X_i = 2`, y `f̂_h(2) = 1/(2·5·(3/5)) = 1/6 ≈ 0.1667`.

Fidelidad declarada: `0.6 = 3/5`; el cálculo es exacto, no en flotantes. -/
theorem no_param_kernel_h06 :
    kernelDens muestra5 (3 / 5) 2 = 1 / 6 := by
  have hsum : (∑ i : Fin 5, (if |muestra5 i - 2| ≤ (3 : ℝ) / 5 then (1 : ℝ) else 0)) = 1 := by
    simp only [Fin.sum_univ_succ, Fin.val_zero, Fin.val_succ, Fin.val_one, Nat.zero_eq]
    norm_num [muestra5]
  unfold kernelDens
  rw [hsum]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1685 (key: ex:ch4-no-parametrico) —
**Suavizado con `h = 1.1`:** ahora contribuyen las tres observaciones
`1, 2, 3`, y `f̂_h(2) = 3/(2·5·(11/10)) = 3/11 ≈ 0.2727`.

Fidelidad declarada: `1.1 = 11/10`; el ancho de banda cambia qué
observaciones contribuyen y el suavizado, como afirma el libro. -/
theorem no_param_kernel_h11 :
    kernelDens muestra5 (11 / 10) 2 = 3 / 11 := by
  have hsum : (∑ i : Fin 5, (if |muestra5 i - 2| ≤ (11 : ℝ) / 10 then (1 : ℝ) else 0)) = 3 := by
    simp only [Fin.sum_univ_succ, Fin.val_zero, Fin.val_succ, Fin.val_one, Nat.zero_eq]
    norm_num [muestra5]
  unfold kernelDens
  rw [hsum]
  norm_num

/-! ## 3. `ex:ch4-if-media-cuantil` — función de influencia del cuantil -/

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil) —
**(auxiliar)** función de influencia del cuantil `q_τ`:
`φ_τ(y) = (τ − 1{y ≤ q_τ})/f(q_τ)`. -/
noncomputable def ifQuant (tau q f : ℝ) (y : ℝ) : ℝ :=
  (tau - (if y ≤ q then (1 : ℝ) else 0)) / f

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil) —
**Media:** la expansión de la media muestral es exacta, es decir la función
de influencia `φ(y) = y − ψ` tiene media cero cuando `ψ = E[Y]`.

Fidelidad declarada: versión finita con pesos `p` que suman uno (medida de
probabilidad discreta); «expansión exacta» se lee como `E[φ] = 0`. -/
theorem if_media_centrada {ι : Type*} [Fintype ι] (p y : ι → ℝ)
    (hp : ∑ i, p i = 1) :
    (∑ i, p i * (y i - ∑ j, p j * y j)) = 0 := by
  have hsplit : ∑ i, p i * (y i - ∑ j, p j * y j)
      = ∑ i, p i * y i - ∑ i, p i * (∑ j, p j * y j) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  rw [hsplit, ← Finset.sum_mul, hp, one_mul]
  ring

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil) —
**(auxiliar)** la «identidad del indicador»: `1{y ≤ q}² = 1{y ≤ q}`. -/
theorem ite_sq_self (q y : ℝ) :
    (if y ≤ q then (1 : ℝ) else 0) ^ 2 = (if y ≤ q then (1 : ℝ) else 0) := by
  split_ifs <;> ring

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil) —
**Función de influencia del cuantil, media cero.** Si la masa de
`P(Y ≤ q_τ)` es `τ` y `f(q_τ) > 0`, entonces la función de influencia
`φ_τ(y) = (τ − 1{y ≤ q_τ})/f(q_τ)` tiene media cero.

Fidelidad declarada: la densidad continua se sustituye por el dato
`P(Y ≤ q_τ) = τ` con pesos finitos; `f(q_τ) ≠ 0` es la hipótesis «densidad
continua y positiva en el cuantil». -/
theorem if_cuantil_media {ι : Type*} [Fintype ι] (p y : ι → ℝ) (tau q f : ℝ)
    (hp : ∑ i, p i = 1) (hf : f ≠ 0)
    (hprob : ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) = tau) :
    ∑ i, p i * ifQuant tau q f (y i) = 0 := by
  have h1 : ∑ i, p i * ifQuant tau q f (y i)
      = (∑ i, (tau * p i - p i * (if y i ≤ q then (1 : ℝ) else 0))) / f := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => by simp only [ifQuant]; ring)
  have h2 : ∑ i, (tau * p i - p i * (if y i ≤ q then (1 : ℝ) else 0))
      = tau * (∑ i, p i) - ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) := by
    rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [h1, h2, hp, hprob, mul_one, sub_self]
  simp

/-- book: capitulos/cap04_herramientas.typ:1900 (key: ex:ch4-if-media-cuantil) —
**Varianza límite `τ(1−τ)/f(q_τ)²`.** Bajo las mismas hipótesis, la varianza
límite (segundo momento de la función de influencia) es `τ(1−τ)/f(q_τ)²`.

Fidelidad declarada: el segundo momento se calcula con pesos finitos; la
afirmación del libro de que un átomo o una densidad nula hacen fallar la
fórmula se registra aquí como la hipótesis `f(q_τ) ≠ 0` y el dato
`P(Y ≤ q_τ) = τ` (sin regularidad adicional). -/
theorem if_cuantil_varianza {ι : Type*} [Fintype ι] (p y : ι → ℝ) (tau q f : ℝ)
    (hp : ∑ i, p i = 1) (hf : f ≠ 0)
    (hprob : ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) = tau) :
    ∑ i, p i * (ifQuant tau q f (y i)) ^ 2 = tau * (1 - tau) / f ^ 2 := by
  have hI : ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) ^ 2
      = ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) :=
    Finset.sum_congr rfl (fun i _ => by rw [ite_sq_self])
  have hexp : ∑ i, p i * (tau - (if y i ≤ q then (1 : ℝ) else 0)) ^ 2
      = tau ^ 2 * (∑ i, p i)
        - 2 * tau * (∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0))
        + ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) ^ 2 := by
    have hterm : ∀ i, p i * (tau - (if y i ≤ q then (1 : ℝ) else 0)) ^ 2
        = (tau ^ 2 * p i - 2 * tau * (p i * (if y i ≤ q then (1 : ℝ) else 0))
            + p i * (if y i ≤ q then (1 : ℝ) else 0) ^ 2) := fun i => by ring
    calc ∑ i, p i * (tau - (if y i ≤ q then (1 : ℝ) else 0)) ^ 2
        = ∑ i, (tau ^ 2 * p i - 2 * tau * (p i * (if y i ≤ q then (1 : ℝ) else 0))
            + p i * (if y i ≤ q then (1 : ℝ) else 0) ^ 2) :=
          Finset.sum_congr rfl (fun i _ => hterm i)
      _ = tau ^ 2 * (∑ i, p i)
            - 2 * tau * (∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0))
            + ∑ i, p i * (if y i ≤ q then (1 : ℝ) else 0) ^ 2 := by
          rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
            ← Finset.mul_sum]
  have hsq : ∑ i, p i * (ifQuant tau q f (y i)) ^ 2
      = (∑ i, p i * (tau - (if y i ≤ q then (1 : ℝ) else 0)) ^ 2) / f ^ 2 := by
    have hterm : ∀ i, p i * (ifQuant tau q f (y i)) ^ 2
        = p i * (tau - (if y i ≤ q then (1 : ℝ) else 0)) ^ 2 / f ^ 2 := fun i => by
      simp only [ifQuant, div_pow]
      ring
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => hterm i)
  rw [hsq, hexp, hI, hp, hprob, mul_one]
  field_simp
  ring


/-! ## 4. `prop:ch2-suficiencia-politicas` — Rao–Blackwell para reglas aleatorizadas -/

section Suficiencia

variable {Θ X 𝒯 A : Type*} [Fintype Θ] [Fintype X] [Fintype 𝒯] [Fintype A]

/-- book: capitulos/cap09_verificacion.typ:227 (key: prop:ch2-suficiencia-politicas) —
riesgo de Wald de una regla **aleatorizada** `δ(a|x)`:
`R(θ,δ) = ∑_x p_θ(x) ∑_a L(θ,a) δ(a|x)`. -/
noncomputable def riskRand (p : Θ → X → ℝ) (L : Θ → A → ℝ) (δ : A → X → ℝ)
    (θ : Θ) : ℝ :=
  ∑ x, p θ x * ∑ a, L θ a * δ a x

/-- book: capitulos/cap09_verificacion.typ:227 (key: prop:ch2-suficiencia-politicas) —
**Suficiencia y políticas óptimas.** Sea `T` suficiente con núcleo condicional
`k(x|t)` independiente del parámetro, es decir `p_θ(x) = m_θ(T x)·k(x|T x)`
con `k(x|t) = 0` fuera de la fibra `T x = t`. Para toda regla aleatorizada
`δ(a|x)` con pérdida integrable, la regla promediada
`δ_T(a|t) = ∑_x k(x|t) δ(a|x)` cumple `R(θ, δ_T) = R(θ, δ)` para todo `θ`.

Fidelidad declarada: espacios `Θ, X, 𝒯, A` finitos y pesos `p_θ` en lugar de
medidas; la suficiencia se codifica por la factorización `p_θ(x) =
m_θ(T x) k(x|T x)` con el núcleo concentrado en la fibra, en lugar de la
existencia de una versión regular del núcleo condicional. La observación del
libro de que la comparación se hace en la clase de reglas aleatorizadas (y que
la media condicional puede salir de la clase de acciones deterministas) queda
fuera de la formalización: aquí `A` es arbitrario y `δ_T` se define como
promedio, sin normalizar. -/
theorem suf_suficiencia_politicas
    (p : Θ → X → ℝ) (L : Θ → A → ℝ) (δ : A → X → ℝ)
    (T : X → 𝒯) (m : Θ → 𝒯 → ℝ) (k : X → 𝒯 → ℝ)
    (hfac : ∀ θ x, p θ x = m θ (T x) * k x (T x))
    (hk : ∀ x t, t ≠ T x → k x t = 0) (θ : Θ) :
    riskRand p L δ θ = riskRand m L (fun a t => ∑ x, k x t * δ a x) θ := by
  unfold riskRand
  have hdist : (∑ t, m θ t * ∑ a, L θ a * ∑ x, k x t * δ a x)
      = ∑ t, ∑ a, ∑ x, m θ t * (L θ a * (k x t * δ a x)) := by
    simp only [Finset.mul_sum]
  have hswap : (∑ t, ∑ a, ∑ x, m θ t * (L θ a * (k x t * δ a x)))
      = ∑ x, ∑ a, ∑ t, m θ t * (L θ a * (k x t * δ a x)) := by
    calc ∑ t, ∑ a, ∑ x, m θ t * (L θ a * (k x t * δ a x))
        = ∑ a, ∑ t, ∑ x, m θ t * (L θ a * (k x t * δ a x)) := Finset.sum_comm
      _ = ∑ a, ∑ x, ∑ t, m θ t * (L θ a * (k x t * δ a x)) := by
            refine Finset.sum_congr rfl (fun a _ => ?_)
            exact Finset.sum_comm
      _ = ∑ x, ∑ a, ∑ t, m θ t * (L θ a * (k x t * δ a x)) := Finset.sum_comm
  have hcol : (∑ x, ∑ a, ∑ t, m θ t * (L θ a * (k x t * δ a x)))
      = ∑ x, ∑ a, m θ (T x) * (L θ a * (k x (T x) * δ a x)) := by
    refine Finset.sum_congr rfl (fun x _ => ?_)
    refine Finset.sum_congr rfl (fun a _ => ?_)
    refine Finset.sum_eq_single (T x) ?_ ?_
    · intro t _ ht
      rw [hk x t ht]
      ring
    · intro h
      exact absurd (Finset.mem_univ (T x)) h
  have hfin : (∑ x, ∑ a, m θ (T x) * (L θ a * (k x (T x) * δ a x)))
      = ∑ x, p θ x * ∑ a, L θ a * δ a x := by
    refine Finset.sum_congr rfl (fun x _ => ?_)
    rw [hfac θ x, Finset.mul_sum]
    exact Finset.sum_congr rfl (fun a _ => by ring)
  rw [hdist, hswap, hcol, hfin]

end Suficiencia

/-! ## 5. `prop:ch3-rb-q` y `prop:ch3-valor-cr` — Rao–Blackwell y Cramér–Rao -/

/-- book: capitulos/cap09_verificacion.typ:328 (key: prop:ch3-valor-cr) —
**(auxiliar, también usada en `prop:ch3-rb-q`)** varianza (momento central de
orden dos) de `u` bajo los pesos `p`. -/
noncomputable def varW {ι : Type*} [Fintype ι] (p u : ι → ℝ) : ℝ :=
  ∑ i, p i * (u i - ∑ j, p j * u j) ^ 2

/-- book: capitulos/cap09_verificacion.typ:343 (key: prop:ch3-rb-q) —
**(auxiliar)** expansión de `∑ p (a−b)²`: es `∑ p a² − 2 ∑ p (a b) + ∑ p b²`. -/
theorem sum_sq_sub {ι : Type*} [Fintype ι] (p a b : ι → ℝ) :
    ∑ i, p i * (a i - b i) ^ 2
      = (∑ i, p i * (a i) ^ 2) - 2 * (∑ i, p i * (a i * b i))
        + ∑ i, p i * (b i) ^ 2 := by
  have hterm : ∀ i, p i * (a i - b i) ^ 2
      = (p i * (a i) ^ 2 - 2 * (p i * (a i * b i)) + p i * (b i) ^ 2) := by
    intro i; ring
  calc ∑ i, p i * (a i - b i) ^ 2
      = ∑ i, (p i * (a i) ^ 2 - 2 * (p i * (a i * b i)) + p i * (b i) ^ 2) :=
        Finset.sum_congr rfl (fun i _ => hterm i)
    _ = (∑ i, p i * (a i) ^ 2) - 2 * (∑ i, p i * (a i * b i)) + ∑ i, p i * (b i) ^ 2 := by
        rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]

/-- book: capitulos/cap09_verificacion.typ:328 (key: prop:ch3-valor-cr) —
**(auxiliar, la «desigualdad de covarianzas»)** Cauchy–Schwarz con pesos no
negativos: `(∑ p a b)² ≤ (∑ p a²)(∑ p b²)`. -/
theorem cs_weighted {ι : Type*} [Fintype ι] (p a b : ι → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hW : 0 < ∑ i, p i * (b i) ^ 2) :
    (∑ i, p i * (a i * b i)) ^ 2 ≤ (∑ i, p i * (a i) ^ 2) * (∑ i, p i * (b i) ^ 2) := by
  have hs : ∀ i, Real.sqrt (p i) * Real.sqrt (p i) = p i := fun i => Real.mul_self_sqrt (hp i)
  have h1 : ∀ i, (Real.sqrt (p i) * a i) * (Real.sqrt (p i) * b i) = p i * (a i * b i) := by
    intro i
    calc (Real.sqrt (p i) * a i) * (Real.sqrt (p i) * b i)
        = (Real.sqrt (p i) * Real.sqrt (p i)) * (a i * b i) := by ring
      _ = p i * (a i * b i) := by rw [hs i]
  have h2 : ∀ i, (Real.sqrt (p i) * a i) ^ 2 = p i * (a i) ^ 2 := by
    intro i
    rw [mul_pow, Real.sq_sqrt (hp i)]
  have h3 : ∀ i, (Real.sqrt (p i) * b i) ^ 2 = p i * (b i) ^ 2 := by
    intro i
    rw [mul_pow, Real.sq_sqrt (hp i)]
  have key := Finset.sum_mul_sq_le_sq_mul_sq (s := Finset.univ)
    (f := fun i => Real.sqrt (p i) * a i) (g := fun i => Real.sqrt (p i) * b i)
  rw [Finset.sum_congr rfl (fun i _ => h1 i), Finset.sum_congr rfl (fun i _ => h2 i),
    Finset.sum_congr rfl (fun i _ => h3 i)] at key
  exact key

/-- book: capitulos/cap09_verificacion.typ:343 (key: prop:ch3-rb-q) —
**Rao–Blackwell para Q-estimadores.** Para política, estado y acción fijos,
sea `U` un estimador de `q^π(s,a)` con segundo momento finito y `V` una
versión de `E[U|T]` para un suficiente `T` (constante en las fibras de `T` y
con los mismos momentos contra toda función de `T`). Entonces `V` tiene la
misma esperanza que `U`, segundo momento no mayor, y se cumple la
descomposición `Var(U) = Var(V) + E[(U−V)²]`.

Fidelidad declarada: espacio finito con pesos `p ≥ 0`; `E[U|T]` se caracteriza
por su propiedad definitoria (constancia en fibras + igualdad de momentos
contra `h(T)`) en lugar de construirse con el teorema de Radon–Nikodym. La
observación del libro de que la suficiencia permite una versión implementable
del condicionamiento es cualitativa y no se formaliza. -/
theorem rb_q {ι 𝒯 : Type*} [Fintype ι] [Fintype 𝒯] (p U V : ι → ℝ) (T : ι → 𝒯)
    (hp : ∀ i, 0 ≤ p i)
    (hconst : ∀ i j, T i = T j → V i = V j)
    (hcond : ∀ h : 𝒯 → ℝ, ∑ i, p i * V i * h (T i) = ∑ i, p i * U i * h (T i)) :
    (∑ i, p i * V i = ∑ i, p i * U i) ∧
    (∑ i, p i * (V i) ^ 2 ≤ ∑ i, p i * (U i) ^ 2) ∧
    ((∑ i, p i * (U i) ^ 2) - (∑ i, p i * U i) ^ 2
      = ((∑ i, p i * (V i) ^ 2) - (∑ i, p i * V i) ^ 2)
        + ∑ i, p i * (U i - V i) ^ 2) := by
  classical
  have hmean : ∑ i, p i * V i = ∑ i, p i * U i := by
    have h := hcond (fun _ => 1)
    simpa using h
  have hUV : ∑ i, p i * (U i * V i) = ∑ i, p i * (V i) ^ 2 := by
    set hV : 𝒯 → ℝ := fun t => if h : ∃ i, T i = t then V (Classical.choose h) else 0
      with hVdef
    have hhV : ∀ i, hV (T i) = V i := by
      intro i
      simp only [hVdef]
      split_ifs with hex
      · exact hconst _ _ (Classical.choose_spec hex)
      · exact absurd ⟨i, rfl⟩ hex
    have h := hcond hV
    have h1 : ∑ i, p i * V i * hV (T i) = ∑ i, p i * (V i) ^ 2 :=
      Finset.sum_congr rfl (fun i _ => by rw [hhV i]; ring)
    have h2 : ∑ i, p i * U i * hV (T i) = ∑ i, p i * (U i * V i) :=
      Finset.sum_congr rfl (fun i _ => by rw [hhV i]; ring)
    rw [h1, h2] at h
    exact h.symm
  have hslack : (∑ i, p i * (U i) ^ 2) - (∑ i, p i * (V i) ^ 2)
      = ∑ i, p i * (U i - V i) ^ 2 := by
    rw [sum_sq_sub, hUV]
    ring
  have hnn : 0 ≤ ∑ i, p i * (U i - V i) ^ 2 :=
    Finset.sum_nonneg (fun i _ => mul_nonneg (hp i) (sq_nonneg _))
  refine ⟨hmean, ?_, ?_⟩
  · linarith
  · have hmean2 : (∑ i, p i * V i) ^ 2 = (∑ i, p i * U i) ^ 2 := by rw [hmean]
    linarith

/-- book: capitulos/cap09_verificacion.typ:328 (key: prop:ch3-valor-cr) —
**Cota de Cramér–Rao para la estimación de un valor.** En un experimento
regular con `n` episodios iid y política fija, si `Ĵ` es insesgado para
`g(θ) = J_θ(π)`, tiene varianza finita y se cumplen las condiciones de
diferenciación e información (score centrado, covarianza del score con `Ĵ`
igual a la derivada `g'(θ)`, información `n·I_1(θ)`), entonces
`Var(Ĵ) ≥ (g'(θ))²/(n I_1(θ))`.

Fidelidad declarada: caso escalar —el que el libro enuncia explícitamente al
final—, con pesos finitos; la versión vectorial `∇gᵀ I₁⁻¹ ∇g` no se formaliza.
Las «condiciones de diferenciación e información» entran como hipótesis
(`hscore`, `hcov`, `hinfo`) que la prueba del libro obtiene derivando la
identidad de insesgadez; la cota se sigue entonces de la desigualdad de
covarianzas (Cauchy–Schwarz), que es lo que aquí se prueba. -/
theorem cr_cota {ι : Type*} [Fintype ι] (p J S : ι → ℝ) (g gp I : ℝ) {n : ℕ}
    (hp : ∀ i, 0 ≤ p i)
    (hmean : ∑ i, p i * J i = g)
    (hscore : ∑ i, p i * S i = 0)
    (hcov : ∑ i, p i * ((J i - g) * S i) = gp)
    (hinfo : ∑ i, p i * (S i) ^ 2 = (n : ℝ) * I)
    (hn : 0 < n) (hI : 0 < I) :
    gp ^ 2 / ((n : ℝ) * I) ≤ varW p J := by
  have hW : 0 < ∑ i, p i * (S i) ^ 2 := by
    rw [hinfo]
    positivity
  have hvar : varW p J = ∑ i, p i * (J i - g) ^ 2 := by
    unfold varW
    rw [hmean]
  have key : gp ^ 2 ≤ varW p J * ((n : ℝ) * I) := by
    rw [hvar, ← hcov, ← hinfo]
    exact cs_weighted p (fun i => J i - g) S hp hW
  have hpos : 0 < (n : ℝ) * I := by positivity
  rw [div_le_iff₀ hpos]
  exact key

/-! ## 6. `ex:ch4-bootstrap-unidad` — el bootstrap ordinario del máximo -/

section Bootstrap

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad) —
**El bootstrap nunca supera al máximo observado.** Con datos `x i = i` en
`Fin n` (el máximo observado es el índice `n−1`), cualquier remuestra
bootstrap `f : Fin n → Fin n` tiene máximo `≤ n−1`: el bootstrap ordinario del
máximo está necesariamente por debajo del máximo muestral, de modo que no
puede reproducir una distribución límite que no sea degenerada en ese punto.

Fidelidad declarada: se modela la remuestra por su función de índices
`f : Fin n → Fin n` sobre una muestra ordenada sin empates; la afirmación
general para cualquier muestra se sigue aplicando el orden de los datos. -/
theorem bootstrap_max_no_supera {n : ℕ} (hn : 0 < n) (f : Fin n → Fin n)
    (j : Fin n) : (f j : ℝ) ≤ (n : ℝ) - 1 := by
  have hlt : ((f j : ℕ)) < n := (f j).isLt
  have hle : ((f j : ℕ)) ≤ n - 1 := Nat.le_sub_one_of_lt hlt
  have hcast : (((f j : ℕ)) : ℝ) ≤ ((n - 1 : ℕ) : ℝ) := by exact_mod_cast hle
  have hsub : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    rw [Nat.cast_sub (show 1 ≤ n from hn), Nat.cast_one]
  rw [hsub] at hcast
  simpa using hcast

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad) —
**Recuento de remuestras que evitan un índice fijo.** De las `n^n` remuestras
con reemplazo de `n` índices, exactamente `(n−1)^n` no tocan un índice `i0`
dado: son las funciones `Fin n → {x // x ≠ i0}`. -/
theorem bootstrap_card_evita {n : ℕ} (hn : 0 < n) (i0 : Fin n) :
    Fintype.card {f : Fin n → Fin n // ∀ j, f j ≠ i0} = (n - 1) ^ n := by
  have e : {f : Fin n → Fin n // ∀ j, f j ≠ i0} ≃ (Fin n → {x : Fin n // x ≠ i0}) :=
    { toFun := fun f j => ⟨f.1 j, f.2 j⟩
      invFun := fun g => ⟨fun j => (g j).1, fun j => (g j).2⟩
      left_inv := fun f => by simp
      right_inv := fun g => by simp }
  rw [Fintype.card_congr e, Fintype.card_fun]
  have hc : Fintype.card {x : Fin n // x ≠ i0} = n - 1 := by
    have h := Fintype.card_subtype_compl (fun x : Fin n => x = i0)
    simp only [Fintype.card_fin, Fintype.card_subtype_eq] at h
    omega
  rw [hc, Fintype.card_fin]

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad) —
**El máximo bootstrap iguala al observado con probabilidad
`1 − (1 − 1/n)^n`.** Con `n` observaciones distintas (máximo alcanzado en el
índice `i0`), la probabilidad —uniforme sobre las `n^n` remuestras— de que
alguna réplica repita el índice del máximo es `1 − (1 − 1/n)^n`, que tiende a
`1 − e⁻¹`: hay un átomo en el máximo y la distribución límite continua del
error escalado no se reproduce.

Fidelidad declarada: se cuenta la probabilidad exacta por cardinalidad de
funciones `Fin n → Fin n`; «el máximo se alcanza en un único índice `i0`» es la
hipótesis de que la muestra no tiene empates en el máximo. -/
theorem bootstrap_prob_igual {n : ℕ} (hn : 0 < n) (i0 : Fin n) :
    1 - ((Fintype.card {f : Fin n → Fin n // ∀ j, f j ≠ i0} : ℝ)
          / (Fintype.card (Fin n → Fin n) : ℝ))
      = 1 - (1 - 1 / (n : ℝ)) ^ n := by
  rw [bootstrap_card_evita hn i0, Fintype.card_fun]
  simp only [Fintype.card_fin]
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    rw [Nat.cast_sub (show 1 ≤ n from hn), Nat.cast_one]
  have hn' : (n : ℝ) ≠ 0 := by
    have : n ≠ 0 := by omega
    exact_mod_cast this
  have key : ((n : ℝ) - 1) ^ n / (n : ℝ) ^ n = (1 - 1 / (n : ℝ)) ^ n := by
    rw [← div_pow]
    congr 1
    field_simp
  congr 1
  rw [Nat.cast_pow, Nat.cast_pow, hcast]
  exact key

/-- book: capitulos/cap04_herramientas.typ:1750 (key: ex:ch4-bootstrap-unidad) —
**El límite `1 − e⁻¹`.** La probabilidad `1 − (1 − 1/n)^n` de que el máximo
bootstrap iguale al observado converge a `1 − e⁻¹ ≈ 0.632` cuando `n → ∞`, y
no a uno: el bootstrap ordinario del máximo deja una masa límite en el
extremo, que la distribución límite continua del error escalado no tiene.

Fidelidad declarada: el límite se prueba a partir de
`Real.tendsto_one_add_div_pow_exp`; la conclusión cualitativa sobre el fallo
del bootstrap («el bootstrap ordinario del máximo no reproduce su
distribución límite») es la lectura de ese límite y no se enuncia como
teorema separado. -/
theorem bootstrap_limite :
    Filter.Tendsto (fun n : ℕ => 1 - (1 - 1 / (n : ℝ)) ^ n) Filter.atTop
      (nhds (1 - Real.exp (-1))) := by
  have h := (Real.tendsto_one_add_div_pow_exp (-1)).const_sub 1
  have hfun : (fun n : ℕ => (1 : ℝ) - (1 + (-1) / (n : ℝ)) ^ n)
      = fun n : ℕ => 1 - (1 - 1 / (n : ℝ)) ^ n := by
    funext n
    congr 2
    ring
  rw [hfun] at h
  exact h

end Bootstrap

end Book.BarridoM16
