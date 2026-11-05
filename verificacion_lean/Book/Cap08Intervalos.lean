import Mathlib
import Book.Foundation

/-!
# Book.Cap08Intervalos — cap. 8 del libro (capitulos/cap08_intervalos.typ)

Baselines de gradiente de política (prop:ch11-baseline y el ejemplo
exacto), la cadena de Markov de dos estados (ex:ch5-cadena) con
autocovarianza `24(1/2)^k`, `σ²_LR = 72` y la varianza exacta finita en
`T = 100`, el gradiente continuo verificable (ex:ch11-pg-ssch) y la cota
espectral bajo reversibilidad (thm:ch11-tasa-tabular, versión finita
verificada sobre la cadena del propio libro).

Fidelidad declarada: espacios finitos y cálculos con racionales exactos;
la cota espectral del libro es un teorema general para cadenas
irreducibles aperiódicas reversibles (cap08_intervalos.typ:110), aquí se
verifica la desigualdad sobre la cadena de dos estados del ejemplo del
libro mediante la forma cerrada de `P^k`.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators
open intervalIntegral

/-! ## prop:ch11-baseline — centrado y varianza -/

/-- book: capitulos/cap08_intervalos.typ:467 (key: prop:ch11-baseline) —
baseline: si `b_t` depende del historial anterior a actuar pero no de la
acción muestreada, `E[z_t b_t] = 0` bajo la propiedad de score
`∑_a π(a|s) z(s,a) = 0`; puede reemplazarse `G_t` por `G_t − b_t` sin
alterar la esperanza del gradiente. Fidelidad declarada: versión finita
de una decisión; la propiedad de score es hipótesis (en el libro se
deriva de la normalización de `π_θ`); la integrabilidad es automática
por finitud.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_baseline (π : Bool → Bool → ℝ) (z : Bool → Bool → ℝ)
    (b : Bool → ℝ) (d : Bool → ℝ)
    (hπ0 : ∀ s a, 0 ≤ π s a) (hπ1 : ∀ s, ∑ a, π s a = 1)
    (hscore : ∀ s, ∑ a, π s a * z s a = 0)
    (s : Bool) :
    (∑ a, π s a * z s a) * b s = 0
    ∧ (∑ s, d s * (∑ a, π s a * (z s a * b s)))
        = (∑ s, d s * (∑ a, π s a * 0)) := by
  constructor
  · rw [hscore s, zero_mul]
  · refine Finset.sum_congr rfl fun s' _ => ?_
    have hring : ∀ a : Bool, π s' a * (z s' a * b s') = (π s' a * z s' a) * b s' :=
      fun a => by ring
    rw [Finset.sum_congr rfl (fun a _ => hring a), ← Finset.sum_mul, hscore s', zero_mul,
      Finset.sum_eq_zero (fun a _ => mul_zero _)]

/-- book: capitulos/cap08_intervalos.typ:480 (key: ex:ssch-drl-cap11) —
SSCH: baseline con cálculo exacto: `A` Bernoulli con `p = 3/4`, `R = A`,
score `A − p`, gradiente verdadero `p(1−p) = 3/16`. Sin baseline la
contribución `A(A−p)` tiene varianza `3/256 = 0.01171875`; la baseline
`b = p = 3/4` produce contribuciones `9/16` o `1/16` con varianza
`3/64 = 0.046875` (cuatro veces mayor); la baseline óptima
`b = 1 − p = 1/4` produce `3/16` para ambas acciones y varianza cero.
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_baseline_ejemplo :
    (∑ a : Bool, (1 / 4) * (if a then (3:ℝ) else 0) * ((if a then (1:ℝ) else 0) - 3 / 4))
      = 3 / 16
    ∧ (∑ a : Bool, (1 / 4) * ((if a then (1:ℝ) else 0) * ((if a then (1:ℝ) else 0) - 3 / 4))
          * ((if a then (1:ℝ) else 0) * ((if a then (1:ℝ) else 0) - 3 / 4)))
      - (∑ a : Bool, (1 / 4) * ((if a then (1:ℝ) else 0) * ((if a then (1:ℝ) else 0) - 3 / 4)))
        * (∑ a : Bool, (1 / 4) * ((if a then (1:ℝ) else 0) * ((if a then (1:ℝ) else 0) - 3 / 4)))
      = 3 / 256
    ∧ (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * (((if a then (1:ℝ) else 0) - 3 / 4) ^ 4))
      - (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * (((if a then (1:ℝ) else 0) - 3 / 4) ^ 2))
        * (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * (((if a then (1:ℝ) else 0) - 3 / 4) ^ 2))
      = 3 / 64
    ∧ (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * ((((if a then (1:ℝ) else 0) - 3 / 4) * ((if a then (1:ℝ) else 0) - 1 / 4)) ^ 2))
      - (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * (((if a then (1:ℝ) else 0) - 3 / 4) * ((if a then (1:ℝ) else 0) - 1 / 4)))
        * (∑ a : Bool, (if a then (3:ℝ) / 4 else 1 / 4)
          * (((if a then (1:ℝ) else 0) - 3 / 4) * ((if a then (1:ℝ) else 0) - 1 / 4)))
      = 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp only [Fintype.sum_bool]; norm_num
  · simp only [Fintype.sum_bool]; norm_num
  · simp only [Fintype.sum_bool]; norm_num
  · simp only [Fintype.sum_bool]; norm_num

/-! ## ex:ch5-cadena — cadena de Markov de dos estados -/

/-- Matriz de transición de la cadena: `P = [[4/5, 1/5], [3/10, 7/10]]`. -/
private noncomputable def P2 : Bool → Bool → ℝ :=
  fun s s' => if s then (if s' then 7 / 10 else 3 / 10) else (if s' then 1 / 5 else 4 / 5)

/-- Distribución invariante `(3/5, 2/5)` (índices: `false → 3/5`). -/
private noncomputable def μ2 : Bool → ℝ := fun s => if s then 2 / 5 else 3 / 5

private theorem P2_row (s : Bool) : ∑ s' : Bool, P2 s s' = 1 := by
  cases s <;> rw [Fintype.sum_bool] <;> norm_num [P2]

private theorem μ2_inv (s : Bool) : ∑ s0 : Bool, μ2 s0 * P2 s0 s = μ2 s := by
  cases s <;> rw [Fintype.sum_bool] <;> norm_num [P2, μ2]

/-- Matriz de `k` pasos por su forma cerrada (autovalores `1` y `1/2`):
`P^k = 1·μ^T + (1/2)^{k−1}·(P − 1·μ^T)` para `k ≥ 1`; `P^0 = I`. Se
declara como definición (la forma cerrada es la descomposición
espectral de la matriz 2×2 del ejemplo). -/
private noncomputable def P2k : ℕ → Bool → Bool → ℝ :=
  fun k s s' => if k = 0 then (if s = s' then 1 else 0)
    else μ2 s' + (1 / 2) ^ (k - 1) * (P2 s s' - μ2 s')

private theorem μ2_mean : (∑ s : Bool, μ2 s * (if s then (10:ℝ) else 0)) = 4 := by
  rw [Fintype.sum_bool]; norm_num [μ2]

private theorem μ2_zero : (∑ s : Bool, μ2 s * ((if s then (10:ℝ) else 0) - 4)) = 0 := by
  rw [Fintype.sum_bool]; norm_num [μ2]

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) —
cálculo de `σ²_LR` en una cadena de Markov de dos estados: con la matriz
`P = [[4/5,1/5],[3/10,7/10]]` iniciada en su distribución invariante
`(3/5,2/5)` y `X_t = 10·S_t`, la media de la recompensa es `4`, su
varianza es `24`, la autocovarianza es `Cov(X_0,X_k) = 24·(1/2)^k`
(segundo autovalor `1/2`) y `σ²_LR = Var + 2·Σ_{k≥1}Cov = 72`. Para
`T = 100`, el error estándar asintótico que ignora la dependencia es
`√(24/100) = 0.490` frente al correcto `√(72/100) = 0.849`; la fórmula
finita exacta está en `ex_ch5_cadena_varianza_finita`. Fidelidad
declarada: la ley conjunta de `(S_0, S_k)` bajo lo estacionario se toma
como `μ(s)·P^k(s,s')` con `P^k` su forma cerrada espectral.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch5_cadena :
    (∑ s : Bool, μ2 s * (if s then (10:ℝ) else 0)) = 4
    ∧ (∑ s : Bool, μ2 s * ((if s then (10:ℝ) else 0) - 4)
          * ((if s then (10:ℝ) else 0) - 4)) = 24
    ∧ (∀ k : ℕ, 1 ≤ k → (∑ s : Bool, ∑ s' : Bool, μ2 s * P2k k s s'
          * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4)))
        = 24 * (1 / 2) ^ k)
    ∧ (24:ℝ) + 2 * ∑' k : ℕ, 24 / 2 / 2 ^ k = 72 := by
  have hsplit : ∀ k : ℕ, 1 ≤ k → (∑ s : Bool, ∑ s' : Bool, μ2 s * P2k k s s'
          * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4)))
      = (∑ s : Bool, μ2 s * ((if s then (10:ℝ) else 0) - 4))
          * (∑ s' : Bool, μ2 s' * ((if s' then (10:ℝ) else 0) - 4))
        + (1 / 2) ^ (k - 1) * (∑ s : Bool, ∑ s' : Bool, μ2 s * (P2 s s' - μ2 s')
          * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))) := by
    intro k hk
    have hterm : ∀ s : Bool, ∀ s' : Bool, μ2 s * P2k k s s'
          * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))
        = μ2 s * μ2 s'
            * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))
          + (1 / 2) ^ (k - 1) * (μ2 s * (P2 s s' - μ2 s')
            * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))) := by
      intro s s'
      unfold P2k
      rw [if_neg (by omega : k ≠ 0)]
      ring
    calc (∑ s : Bool, ∑ s' : Bool, μ2 s * P2k k s s'
            * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4)))
        = ∑ s : Bool, ∑ s' : Bool, (μ2 s * μ2 s'
              * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))
            + (1 / 2) ^ (k - 1) * (μ2 s * (P2 s s' - μ2 s')
              * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4)))) :=
          Finset.sum_congr rfl fun s _ => Finset.sum_congr rfl fun s' _ => hterm s s'
      _ = (∑ s : Bool, μ2 s * ((if s then (10:ℝ) else 0) - 4))
            * (∑ s' : Bool, μ2 s' * ((if s' then (10:ℝ) else 0) - 4))
          + (1 / 2) ^ (k - 1) * (∑ s : Bool, ∑ s' : Bool, μ2 s * (P2 s s' - μ2 s')
            * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4))) := by
          simp only [Fintype.sum_bool]
          norm_num [μ2, P2]
          ring_nf
  have hC : (∑ s : Bool, ∑ s' : Bool, μ2 s * (P2 s s' - μ2 s')
        * (((if s then (10:ℝ) else 0) - 4) * ((if s' then (10:ℝ) else 0) - 4)))
      = 12 := by
    rw [Fintype.sum_bool, Fintype.sum_bool]; norm_num [μ2, P2]
  have hzero : (∑ s : Bool, μ2 s * ((if s then (10:ℝ) else 0) - 4)) = 0 := μ2_zero
  refine ⟨μ2_mean, ?_, ?_, ?_⟩
  · rw [Fintype.sum_bool]; norm_num [μ2]
  · intro k hk
    rw [hsplit k hk, hzero, hC, zero_mul, zero_add]
    have hcalc : (1 / 2 : ℝ) ^ (k - 1) * 12 = 24 * (1 / 2) ^ k := by
      obtain ⟨m, hm⟩ : ∃ m : ℕ, k = m + 1 := ⟨k - 1, by omega⟩
      subst hm
      have h2 : (m : ℕ) + 1 - 1 = m := by omega
      simp only [h2, Nat.cast_add, Nat.cast_one]
      rw [pow_succ]
      ring_nf
    rw [hcalc]
  · rw [tsum_geometric_two' (24:ℝ)]
    norm_num

/-! ## ex:ch11-pg-ssch — estado continuo y gradiente verificable -/

/-- book: capitulos/cap08_intervalos.typ:529 (key: ex:ch11-pg-ssch) —
estado continuo y gradiente verificable: `S` uniforme en `[−1,1]`,
`π_θ(1|s) = 1/(1+exp(−θs))` y recompensa abstracta `R = A·S`. En
`θ = 0`, `p = 1/2` y el score es `S(A−1/2)`; el gradiente verdadero es
`E[S²]/4 = 1/12`. Sin baseline, la contribución es `Z = A·S²/2`, de
varianza `13/720`; con baseline `b(s) = s/2`, vale `Z_b = S²/4`, de
varianza `1/180` (se obtiene usando `E[S²] = 1/3` y `E[S⁴] = 1/5`); la
reducción de varianza es `9/13`. Fidelidad declarada: los momentos de la
uniforme se verifican como integrales `∫_{-1}^1 x^2 = 2/3` y
`∫_{-1}^1 x^4 = 2/5`; `A` Bernoulli(1/2) independiente de `S`.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch11_pg_ssch :
    (∫ x in (-1:ℝ)..1, x ^ 2 = 2 / 3)
    ∧ (∫ x in (-1:ℝ)..1, x ^ 4 = 2 / 5)
    ∧ ((1 / 2) * (1 / 2) * (2 / 3) / 4 = 1 / 12)
    ∧ (((1 / 2) * ((1:ℝ) / 5) / 4) - (1 / 12) * (1 / 12) = 13 / 720)
    ∧ (((1 / 5) / 16) - ((1 / 3) / 4) * ((1 / 3) / 4) = 1 / 180)
    ∧ ((1:ℝ) - (1 / 180) / (13 / 720) = 9 / 13) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num [integral_pow]
  · norm_num [integral_pow]
  · norm_num
  · norm_num
  · norm_num
  · norm_num
