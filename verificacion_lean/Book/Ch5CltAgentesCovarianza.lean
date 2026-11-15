import Mathlib
import Book.Ch5CltAgentesM5
import Book.Cap08Ch11M10

/-!
# Book.Ch5CltAgentesCovarianza — `thm:ch5-clt-agentes`: la varianza de la media

Módulo auxiliar del miembro m4 del swarm `smwi1z2xl`. Dirección: **covarianzas
y Cesàro en la contribución estacionaria**. No sustituye a
`Book/Ch5CltAgentesM5.lean` (que queda intacto): lo complementa con el paso
analítico que su propio docstring declara ausente,

> «ni el paso de la serie de covarianzas a `τ²` como límite de
> `T·Var(X̄_T)` (requiere el lema de Kronecker y la identidad de conteo del
> covariograma)».

## Qué se prueba (y con qué hipótesis)

El libro (`capitulos/cap06_fallos.typ:324`, clave `thm:ch5-clt-agentes`) afirma,
entre otras cosas, que **la varianza de la media es aproximadamente
`σ²_LR/T`**, con `σ²_LR = γ_0 + 2∑_{k≥1}γ_k` y `γ_k = Cov(X_0,X_k)`, y que la
serie de covarianzas es absolutamente convergente.

Aquí se formaliza **el límite exacto** que hace precisa esa frase, bajo
estacionariedad débil del covariograma y sumabilidad absoluta de la serie de
covarianzas (`∑|γ_k| < ∞`, que es la consecuencia de la condición de mixing
`def:ch5-mixing-clt` citada por el libro; no se deriva del mixing, entra como
hipótesis explícita):

* `cov_doble_limite` — `(1/n)·∑_{i,j<n} γ_{|i−j|} → γ_0 + 2∑_{k≥1}γ_k`;
* `var_media_covarianza` — identidad finita exacta
  `Var_p(X̄_T) = (∑_{i,j<T}γ_{|i−j|})/T²` (la advertencia del libro: dividir por
  el tamaño de la trayectoria);
* `ch5_var_media_limite` — `T·Var_p(X̄_T) → σ²_LR`;
* `cadena2_suma_exacta`, `cadena2_var_media`, `cadena2_var_media_limite`,
  `cadena2_T100`, `cadena2_T100_correccion` — el ejemplo `ex:ch5-cadena` del
  libro (cadena de 2 estados, `γ_k = 24·(1/2)^k`): forma cerrada exacta
  `∑_{i,j<n}γ_{|i−j|} = 72n − 96 + 96·(1/2)^n`, valor exacto en `n = 100`
  (`7104 + 96·2^{−100}`, es decir `0.7104` con corrección `< 10^{−25}`) y
  `T·Var → 72`.

## Qué NO se prueba

* La convergencia distribucional `√T(X̄_T − μ) →d N(0,σ²_LR)`: es el CLT de
  Ibragimov/mezcla, **externo al libro** (notas de Shalizi, teorema 355) y
  excluido por `PLAN_LEAN_LIBRO_2026-11-04.md` §1 («CLT de mixing»). No se
  postula ni se axiomatiza.
* La consistencia `σ̂²_LR →P σ²_LR` ni la cobertura del intervalo asintótico.
* `def:ch5-mixing-clt` no se formaliza: `∑|γ_k| < ∞` es hipótesis explícita.
* No se usa ninguna suposición numérica como teorema: los valores del ejemplo
  se **demuestran** (identidades racionales exactas).

`#print axioms` de cada teorema reclamado ⊆ {`propext`, `Classical.choice`,
`Quot.sound`}; cero `sorry` (auditoría en `axiomas.log`).
-/

open Finset BigOperators Filter
open scoped Topology

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

namespace BookCh5CltAgentesCov

/-! ## 1. Análisis real: Toeplitz/Cesàro con pesos `(1 − k/n)`

El núcleo analítico del límite. `Summable |γ|` controla la cola; el peso
`(1 − k/n)` se introduce al dividir la suma doble por `n`. -/

/-- **Lema de sumas prefijas.** La suma ponderada por `(n − k)` es la suma de
las sumas parciales: `∑_{k<n}(n−k)a_k = ∑_{m<n}∑_{k≤m}a_k`. Es la identidad
que convierte el peso triangular de Toeplitz en una media de Cesàro. -/
theorem sum_range_mul_eq_sum_prefix (a : ℕ → ℝ) :
    ∀ n : ℕ, (∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k)
      = ∑ m ∈ range n, ∑ k ∈ range (m + 1), a k := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
    have hL : (∑ k ∈ range n, ((n + 1 - k : ℕ) : ℝ) * a k)
        = (∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k) + ∑ k ∈ range n, a k := by
      rw [← sum_add_distrib]
      refine sum_congr rfl fun k hk => ?_
      have hk' : k < n := mem_range.1 hk
      have h : n + 1 - k = (n - k) + 1 := by omega
      rw [h]
      push_cast
      ring
    have hlast : ((n + 1 - n : ℕ) : ℝ) * a n = a n := by
      have h : n + 1 - n = 1 := by omega
      rw [h]; norm_num
    rw [sum_range_succ (f := fun k => ((n + 1 - k : ℕ) : ℝ) * a k),
        sum_range_succ (f := fun m => ∑ k ∈ range (m + 1), a k),
        hL, ih, hlast, sum_range_succ (f := a)]
    ring

/-- Las sumas parciales de una serie convergente, divididas por `n`, tienden a
`0`. -/
theorem tendsto_inv_mul_partial (a : ℕ → ℝ) (h : Summable a) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, a k) atTop (𝓝 0) := by
  have hS : Tendsto (fun n : ℕ => ∑ k ∈ range n, a k) atTop (𝓝 (∑' k, a k)) :=
    h.hasSum.tendsto_sum_nat
  have hz : Tendsto (fun n : ℕ => (n : ℝ)⁻¹) atTop (𝓝 0) :=
    (tendsto_inv_atTop_zero (𝕜 := ℝ)).comp tendsto_natCast_atTop_atTop
  have := hz.mul hS
  simpa using this

/-- **Toeplitz/Cesàro con pesos `(1 − k/n)`.** Si `∑|a_k| < ∞` entonces
`(1/n)∑_{k<n}(n−k)a_k → ∑_k a_k`. La prueba pasa por la identidad de sumas
prefijas y el lema de Cesàro de Mathlib (`Filter.Tendsto.cesaro`). -/
theorem toeplitz_weighted (a : ℕ → ℝ) (h : Summable a) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k)
      atTop (𝓝 (∑' k, a k)) := by
  have hces : Tendsto (fun m : ℕ => ∑ k ∈ range (m + 1), a k) atTop (𝓝 (∑' k, a k)) :=
    h.hasSum.tendsto_sum_nat.comp (tendsto_add_atTop_nat 1)
  have hmain : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ m ∈ range n, ∑ k ∈ range (m + 1), a k)
      atTop (𝓝 (∑' k, a k)) := hces.cesaro
  have hfun : (fun n : ℕ => (n : ℝ)⁻¹ * ∑ m ∈ range n, ∑ k ∈ range (m + 1), a k)
      = fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k := by
    funext n
    rw [sum_range_mul_eq_sum_prefix a n]
  rw [hfun] at hmain
  exact hmain

/-- **Toeplitz con el peso desplazado `(1 − (k+1)/n)`.** La versión que produce
la identidad de conteo del covariograma, donde el rezago aparece como `k+1` y
el peso es `n − 1 − k`. -/
theorem toeplitz_weighted_shift (a : ℕ → ℝ) (h : Summable a) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * a k)
      atTop (𝓝 (∑' k, a k)) := by
  have hA := toeplitz_weighted a h
  have hB := tendsto_inv_mul_partial a h
  have hsub : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k
      - (n : ℝ)⁻¹ * ∑ k ∈ range n, a k) atTop (𝓝 ((∑' k, a k) - 0)) := hA.sub hB
  have hgoal : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k
      - (n : ℝ)⁻¹ * ∑ k ∈ range n, a k) atTop (𝓝 (∑' k, a k)) := by
    simpa using hsub
  have hfun : (fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * a k)
      = fun n : ℕ => (n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k
          - (n : ℝ)⁻¹ * ∑ k ∈ range n, a k := by
    funext n
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn; simp
    · have hsplit : (∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * a k)
          = (∑ k ∈ range n, ((n - k : ℕ) : ℝ) * a k) - ∑ k ∈ range n, a k := by
        rw [← sum_sub_distrib]
        refine sum_congr rfl fun k hk => ?_
        have hk' : k < n := mem_range.1 hk
        have hcast : ((n - k : ℕ) : ℝ) = ((n - 1 - k : ℕ) : ℝ) + 1 := by
          have h : n - k = (n - 1 - k) + 1 := by omega
          rw [h]; push_cast; ring
        rw [hcast]; ring
      rw [hsplit]
      ring
  rw [hfun]
  exact hgoal

/-! ## 2. Sumabilidad de la cola del covariograma -/

/-- La cola `∑_{k≥1}|γ_k|` converge si la serie completa converge. -/
theorem summable_abs_tail {γ : ℕ → ℝ} (h : Summable fun k => |γ k|) :
    Summable fun k : ℕ => |γ (k + 1)| := (summable_nat_add_iff 1).mpr h

/-- La cola `∑_{k≥1}γ_k` converge (sin el valor absoluto). -/
theorem summable_tail {γ : ℕ → ℝ} (h : Summable fun k => |γ k|) :
    Summable fun k : ℕ => γ (k + 1) := by
  have h1 : Summable fun k : ℕ => ‖γ (k + 1)‖ := by
    simpa [Real.norm_eq_abs] using summable_abs_tail h
  exact h1.of_norm

/-! ## 3. `(1/n)∑_{i,j<n}γ_{|i−j|} → γ_0 + 2∑_{k≥1}γ_k`

El límite de `T·Var(X̄_T)` a nivel de covariograma. Usa la identidad de conteo
`Ch11M10.sum_dist_range` (módulo homólogo del capítulo 11, ya verificado en el
repositorio) y el lema de Toeplitz de la sección 1. -/

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**límite de la varianza de la media, a nivel de covariograma.** Bajo
`∑_k |γ_k| < ∞`,

  `(1/n)·∑_{i<n}∑_{j<n} γ_{|i−j|} → γ_0 + 2·∑_{k≥1}γ_k`,

es decir `n·Var(X̄_n) → σ²_LR` con la definición `lrVariance` del libro. -/
theorem cov_doble_limite (γ : ℕ → ℝ) (habs : Summable fun k => |γ k|) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ range n, ∑ j ∈ range n, γ (Nat.dist i j))
      atTop (𝓝 (BookCh5CltAgentesM5.lrVariance γ)) := by
  have htoep := toeplitz_weighted_shift (fun k : ℕ => γ (k + 1)) (summable_tail habs)
  have hlim : Tendsto
      (fun n : ℕ => γ 0 + 2 * ((n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * γ (k + 1)))
      atTop (𝓝 (γ 0 + 2 * ∑' k : ℕ, γ (k + 1))) := (htoep.const_mul 2).const_add (γ 0)
  have htarget : BookCh5CltAgentesM5.lrVariance γ = γ 0 + 2 * ∑' k : ℕ, γ (k + 1) := rfl
  rw [htarget]
  refine hlim.congr' ?_
  filter_upwards [Ici_mem_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by
    have hpos : (0 : ℕ) < n := hn
    exact_mod_cast Nat.pos_iff_ne_zero.mp hpos
  rw [Ch11M10.sum_dist_range γ n]
  field_simp

/-! ## 4. La capa de probabilidad finita: `Var_p(X̄_T) = (∑_{i,j<T}γ_{|i−j|})/T²` -/

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**identidad finita exacta de la varianza de la media.** Si el covariograma es
estacionario (`Cov_p(X_i,X_j) = γ_{|i−j|}` para todo `i,j`), entonces
`Var_p(X̄_T) = (∑_{i<T}∑_{j<T}γ_{|i−j|})/T²`: la división por `T²` es la
advertencia explícita del libro (no se reemplaza la varianza de la media por
una varianza sin dividir por el tamaño de la trayectoria). -/
theorem var_media_covarianza {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (γ : ℕ → ℝ) (T : ℕ) (hT : (T : ℝ) ≠ 0)
    (hcov : ∀ i j : ℕ, BookCh5CltAgentesM5.fcov p (Z i) (Z j) = γ (Nat.dist i j)) :
    BookCh5CltAgentesM5.fvar p (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)
      = (∑ i ∈ range T, ∑ j ∈ range T, γ (Nat.dist i j)) / (T : ℝ) ^ 2 := by
  rw [BookCh5CltAgentesM5.fvar_const_mul, BookCh5CltAgentesM5.fvar_sum]
  have hpair : (∑ i : Fin T, ∑ j : Fin T,
        BookCh5CltAgentesM5.fcov p (Z (i : ℕ)) (Z (j : ℕ)))
      = ∑ i ∈ range T, ∑ j ∈ range T, γ (Nat.dist i j) := by
    rw [Fin.sum_univ_eq_sum_range
      (fun i => ∑ j : Fin T, BookCh5CltAgentesM5.fcov p (Z i) (Z (j : ℕ))) T]
    refine sum_congr rfl fun i hi => ?_
    rw [← Fin.sum_univ_eq_sum_range (fun j => γ (Nat.dist i j)) T]
    exact sum_congr rfl fun j hj => hcov i j
  rw [hpair]
  field_simp

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**`T·Var_p(X̄_T) → σ²_LR`.** Bajo estacionariedad del covariograma y
`∑_k|γ_k| < ∞`, la varianza de la media multiplicada por el tamaño de la
trayectoria converge a la varianza de largo plazo del libro. Es la lectura
precisa de «la varianza de la media es aproximadamente `σ²_LR/T`». -/
theorem ch5_var_media_limite {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (γ : ℕ → ℝ) (hcov : ∀ i j : ℕ, BookCh5CltAgentesM5.fcov p (Z i) (Z j) = γ (Nat.dist i j))
    (habs : Summable fun k => |γ k|) :
    Tendsto (fun T : ℕ => (T : ℝ) * BookCh5CltAgentesM5.fvar p
        (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)) atTop
      (𝓝 (BookCh5CltAgentesM5.lrVariance γ)) := by
  have hcore := cov_doble_limite γ habs
  refine hcore.congr' ?_
  filter_upwards [Ici_mem_atTop 1] with T hT
  have hT0 : (T : ℝ) ≠ 0 := by
    have hpos : (0 : ℕ) < T := hT
    exact_mod_cast Nat.pos_iff_ne_zero.mp hpos
  rw [var_media_covarianza p Z γ T hT0 hcov]
  field_simp

/-! ## 4-bis. Compatibilidad con la forma de hipótesis del repositorio

`BookCh5CltAgentesM5.lr_varianza_finita` y `lr_varianza_media` enuncian la
estacionariedad con la distancia escrita como
`if i ≤ j then j − i else i − j` sobre `Fin T`. Aquí se comprueba que esa
forma implica la forma `Nat.dist` de este módulo, de modo que los teoremas
anteriores **aplican** a las hipótesis ya registradas en el repositorio. -/

/-- La distancia de `Fin` escrita con `if` es `Nat.dist`. -/
theorem dist_eq_if (i j : ℕ) :
    Nat.dist i j = if i ≤ j then j - i else i - j := by
  split_ifs with h
  · rw [Nat.dist_eq_sub_of_le h]
  · rw [Nat.dist_comm, Nat.dist_eq_sub_of_le (le_of_not_ge h)]

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**la identidad finita de `lr_varianza_media` con la hipótesis tal como la
enuncia el repositorio** (`if i ≤ j then j − i else i − j`): la suma doble de
covarianzas coincide con la suma doble del covariograma por rezagos. -/
theorem suma_covarianza_if {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (γ : ℕ → ℝ) (T : ℕ)
    (hcov : ∀ i j : Fin T, BookCh5CltAgentesM5.fcov p (Z (i : ℕ)) (Z (j : ℕ))
      = γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ))) :
    (∑ i : Fin T, ∑ j : Fin T, BookCh5CltAgentesM5.fcov p (Z (i : ℕ)) (Z (j : ℕ)))
      = ∑ i ∈ range T, ∑ j ∈ range T, γ (Nat.dist i j) := by
  rw [Fin.sum_univ_eq_sum_range
    (fun i => ∑ j : Fin T, BookCh5CltAgentesM5.fcov p (Z i) (Z (j : ℕ))) T]
  refine sum_congr rfl fun i hi => ?_
  rw [← Fin.sum_univ_eq_sum_range (fun j => γ (Nat.dist i j)) T]
  refine sum_congr rfl fun j _ => ?_
  rw [hcov ⟨i, mem_range.1 hi⟩ j, dist_eq_if]

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) — la
identidad `Var_p(X̄_T) = (∑_{i,j<T}γ_{|i−j|})/T²` a partir de la hipótesis en
la forma del repositorio. -/
theorem var_media_covarianza_if {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (γ : ℕ → ℝ) (T : ℕ) (hT : (T : ℝ) ≠ 0)
    (hcov : ∀ i j : Fin T, BookCh5CltAgentesM5.fcov p (Z (i : ℕ)) (Z (j : ℕ))
      = γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ))) :
    BookCh5CltAgentesM5.fvar p (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)
      = (∑ i ∈ range T, ∑ j ∈ range T, γ (Nat.dist i j)) / (T : ℝ) ^ 2 := by
  rw [BookCh5CltAgentesM5.fvar_const_mul, BookCh5CltAgentesM5.fvar_sum,
    suma_covarianza_if p Z γ T hcov]
  field_simp

/-! ## 5. El ejemplo del libro: cadena de 2 estados, `γ_k = 24·(1/2)^k`

`ex:ch5-cadena` (`capitulos/cap06_fallos.typ:343`): con `X_t = 10·S_t`,
`Var(X_0) = 24`, `Cov(X_0,X_k) = 24·(1/2)^k` y `σ²_LR = 72`. El libro da la
fórmula finita exacta `Var(X̄_T) = 24/T + 48/T²·∑_{k=1}^{T−1}(T−k)(1/2)^k` y
su valor `≈ 0.7104` en `T = 100`. Aquí se demuestra la forma cerrada y el
valor exacto. -/

/-- Suma ponderada geométrica cerrada: `∑_{k<n}(n−1−k)·(1/2)^k = 2n − 4 + 4·(1/2)^n`. -/
theorem geom_pesos_half : ∀ n : ℕ,
    (∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k)
      = 2 * (n : ℝ) - 4 + 4 * (1 / 2 : ℝ) ^ n := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
    rw [sum_range_succ' (f := fun k => (((n + 1) - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k) n]
    have hshift : ∀ k < n, (((n + 1) - 1 - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1)
        = (1 / 2) * (((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k) := by
      intro k hk
      have h : (n + 1 - 1 - (k + 1) : ℕ) = (n - 1 - k : ℕ) := by omega
      rw [h, pow_succ]
      ring
    have h1 : (∑ k ∈ range n, (((n + 1) - 1 - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1))
        = (1 / 2) * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k := by
      rw [mul_sum]
      exact sum_congr rfl fun k hk => hshift k (mem_range.1 hk)
    rw [h1, ih]
    have h0 : (((n + 1) - 1 - 0 : ℕ) : ℝ) * (1 / 2 : ℝ) ^ 0 = (n : ℝ) := by
      have h : (n + 1 - 1 - 0 : ℕ) = n := by omega
      rw [h]; norm_num
    rw [h0]
    have hpow : (1 / 2 : ℝ) ^ (n + 1) = (1 / 2) * (1 / 2 : ℝ) ^ n := pow_succ' _ _
    rw [hpow]
    push_cast
    ring

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) —
**suma doble exacta del ejemplo de la cadena de 2 estados:**
`∑_{i,j<n}γ_{|i−j|} = 72n − 96 + 96·(1/2)^n` para `γ_k = 24·(1/2)^k`. -/
theorem cadena2_suma_exacta (n : ℕ) :
    (∑ i ∈ range n, ∑ j ∈ range n, 24 * (1 / 2 : ℝ) ^ (Nat.dist i j))
      = 72 * (n : ℝ) - 96 + 96 * (1 / 2 : ℝ) ^ n := by
  rw [show (∑ i ∈ range n, ∑ j ∈ range n, 24 * (1 / 2 : ℝ) ^ (Nat.dist i j))
      = (n : ℝ) * (24 * (1 / 2 : ℝ) ^ 0)
        + 2 * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (24 * (1 / 2 : ℝ) ^ (k + 1)) from
    Ch11M10.sum_dist_range (fun k : ℕ => 24 * (1 / 2 : ℝ) ^ k) n]
  rw [show (∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (24 * (1 / 2 : ℝ) ^ (k + 1)))
      = 12 * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k from by
    rw [mul_sum]
    exact sum_congr rfl fun k _ => by
      rw [show (24 : ℝ) * (1 / 2 : ℝ) ^ (k + 1) = 12 * (1 / 2 : ℝ) ^ k by
        rw [pow_succ]; ring]
      ring,
    geom_pesos_half n]
  norm_num
  ring

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) —
**fórmula finita exacta del libro para `Var(X̄_T)`** en la cadena de 2
estados: `Var_p(X̄_T) = 72/T − 96/T² + 96·(1/2)^T/T²`, equivalente a la
expresión `24/T + 48/T²·∑_{k=1}^{T−1}(T−k)(1/2)^k` que muestra el libro. -/
theorem cadena2_var_media {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (T : ℕ) (hT : (T : ℝ) ≠ 0)
    (hcov : ∀ i j : ℕ,
      BookCh5CltAgentesM5.fcov p (Z i) (Z j) = 24 * (1 / 2 : ℝ) ^ (Nat.dist i j)) :
    BookCh5CltAgentesM5.fvar p (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)
      = 72 / (T : ℝ) - 96 / (T : ℝ) ^ 2 + 96 * (1 / 2 : ℝ) ^ T / (T : ℝ) ^ 2 := by
  rw [var_media_covarianza p Z (fun k : ℕ => 24 * (1 / 2 : ℝ) ^ k) T hT hcov,
      cadena2_suma_exacta T]
  field_simp

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) — el valor
exacto de la suma doble en `T = 100`: `7104 + 96·(1/2)^100`. El libro reporta
`Var(X̄_100) ≈ 0.7104 = (7104 + 96·(1/2)^100)/100²`; la corrección es
`96·2^{−100}/10^4 < 10^{−25}`. -/
theorem cadena2_T100 :
    (∑ i ∈ range 100, ∑ j ∈ range 100, 24 * (1 / 2 : ℝ) ^ (Nat.dist i j))
      = 7104 + 96 * (1 / 2 : ℝ) ^ 100 := by
  rw [cadena2_suma_exacta 100]
  norm_num

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) — la corrección
`96·2^{−100}` es menor que `10^{−25}`, así que `0.7104` es el valor de
`Var(X̄_100)` con 25 decimales exactos. -/
theorem cadena2_T100_correccion : 96 * (1 / 2 : ℝ) ^ 100 < 1 / 10 ^ 25 := by
  norm_num

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) — `T·Var(X̄_T) →
72` en la cadena de 2 estados, es decir `σ²_LR = 72` es el límite de la
varianza de la media multiplicada por `T`. -/
theorem cadena2_var_media_limite :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ *
        ∑ i ∈ range n, ∑ j ∈ range n, 24 * (1 / 2 : ℝ) ^ (Nat.dist i j))
      atTop (𝓝 72) := by
  have hgeo : Summable fun k : ℕ => (1 / 2 : ℝ) ^ k :=
    summable_geometric_of_norm_lt_one (by norm_num)
  have habs : Summable fun k : ℕ => |24 * (1 / 2 : ℝ) ^ k| :=
    (hgeo.mul_left 24).abs
  have h := cov_doble_limite (fun k : ℕ => 24 * (1 / 2 : ℝ) ^ k) habs
  rw [BookCh5CltAgentesM5.lr_cadena2_libro] at h
  exact h

/-! ## 6. La forma que muestra el libro en `ex:ch5-cadena`

El libro escribe `Var(X̄_T) = 24/T + 48/T²·∑_{k=1}^{T−1}(T−k)(0.5)^k`. Aquí se
demuestra la identidad de reindexado que la conecta con la forma cerrada de la
sección 5, de modo que la fórmula impresa queda certificada tal cual. -/

/-- Suma geométrica de razón `1/2`: `∑_{k<n}(1/2)^k = 2 − 2·(1/2)^n`. -/
theorem geom_suma_half (n : ℕ) :
    (∑ k ∈ range n, (1 / 2 : ℝ) ^ k) = 2 - 2 * (1 / 2 : ℝ) ^ n := by
  rw [geom_sum_eq (by norm_num : (1 / 2 : ℝ) ≠ 1)]
  have h : (1 / 2 : ℝ) - 1 = -(1 / 2) := by norm_num
  rw [h, div_neg]
  field_simp
  ring

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) — la suma que
imprime el libro: `∑_{k=1}^{T−1}(T−k)(1/2)^k = T − 2 + 2·(1/2)^T`. -/
theorem cadena2_suma_libro (T : ℕ) :
    (∑ k ∈ range (T - 1), (((T : ℕ) - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1))
      = (T : ℝ) - 2 + 2 * (1 / 2 : ℝ) ^ T := by
  rcases Nat.eq_zero_or_pos T with hT | hT
  · subst hT; simp
  · have hT1 : T = (T - 1) + 1 := by omega
    have hpt : ∀ k ∈ range (T - 1),
        (((T : ℕ) - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1)
          = (1 / 2) * ((((T - 1) - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k)
            + (1 / 2) * (1 / 2 : ℝ) ^ k := by
      intro k hk
      have hk' : k < T - 1 := mem_range.1 hk
      have hcast : (T - (k + 1) : ℕ) = ((T - 1) - 1 - k) + 1 := by omega
      rw [hcast, pow_succ]
      push_cast
      ring
    have hsplit : (∑ k ∈ range (T - 1),
          (((T : ℕ) - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1))
        = (1 / 2) * ∑ k ∈ range (T - 1), (((T - 1) - 1 - k : ℕ) : ℝ) * (1 / 2 : ℝ) ^ k
          + (1 / 2) * ∑ k ∈ range (T - 1), (1 / 2 : ℝ) ^ k := by
      rw [mul_sum, mul_sum, ← sum_add_distrib]
      exact sum_congr rfl hpt
    have hpow : (1 / 2 : ℝ) ^ T = (1 / 2) * (1 / 2 : ℝ) ^ (T - 1) := by
      conv_lhs => rw [hT1]
      rw [pow_succ]
      ring
    have hcastT : ((T - 1 : ℕ) : ℝ) = (T : ℝ) - 1 := by
      rw [Nat.cast_sub hT]
      norm_num
    rw [hsplit, geom_pesos_half, geom_suma_half, hpow, hcastT]
    ring

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) — **la fórmula
finita exacta tal como la imprime el libro**:
`Var_p(X̄_T) = 24/T + 48/T²·∑_{k=1}^{T−1}(T−k)(1/2)^k`. -/
theorem cadena2_var_media_libro {Ω : Type*} [Fintype Ω] (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (T : ℕ) (hT : (T : ℝ) ≠ 0)
    (hcov : ∀ i j : ℕ,
      BookCh5CltAgentesM5.fcov p (Z i) (Z j) = 24 * (1 / 2 : ℝ) ^ (Nat.dist i j)) :
    BookCh5CltAgentesM5.fvar p (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)
      = 24 / (T : ℝ)
        + 48 / (T : ℝ) ^ 2
          * ∑ k ∈ range (T - 1), (((T : ℕ) - (k + 1) : ℕ) : ℝ) * (1 / 2 : ℝ) ^ (k + 1) := by
  rw [cadena2_var_media p Z T hT hcov, cadena2_suma_libro T]
  field_simp
  ring

end BookCh5CltAgentesCov
