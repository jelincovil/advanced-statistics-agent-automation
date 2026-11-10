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

/-- book: capitulos/cap08_intervalos.typ:469 (key: prop:ch11-baseline) —
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

/-- book: capitulos/cap08_intervalos.typ:485 (key: ex:ssch-drl-cap11) —
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

/-- book: capitulos/cap06_fallos.typ:343 (key: ex:ch5-cadena) —
varianza finita exacta de la media muestral en la cadena de dos
estados: `Var(X̄_T) = 24/T + 48/T²·Σ_{k=1}^{T−1}(T−k)(1/2)^k` (la
fórmula finita del libro). En `T = 100` el valor exacto es
`444/625 + 3/(625·2^99)`: `444/625 = 0.7104` es exactamente el
«aproximadamente 0.7104» del libro y `3/(625·2^99)` es la corrección
exponencialmente pequeña. Fidelidad declarada: evaluación puntual en
`T = 100`; la suma se evalúa en su forma escalada en naturales
(`Σ_{k=1}^{99}(100−k)·2^{99−k} = 98·2^99 + 1`, por `decide`) con el
puente a ℝ vía `Nat.cast`; la fórmula general para todo `T` no se
enuncia aquí.
Origen: t28 2026-11-06 (nuevo; la referencia a este teorema quedaba
colgante en el docstring de `ex_ch5_cadena`). -/
theorem ex_ch5_cadena_varianza_finita :
    (24:ℝ)/100 + 48/(100:ℝ)^2 * ∑ k ∈ Finset.Icc (1:ℕ) 99, ((100:ℝ) - (k:ℝ)) * (1/2)^k
      = 444/(625:ℝ) + 3/(625:ℝ) * (1/2)^99 := by
  have hnat : ∑ k ∈ Finset.Icc (1:ℕ) 99, (100 - k) * 2^(99 - k) = 98 * 2^99 + 1 := by
    decide
  have hterm : ∀ k ∈ Finset.Icc (1:ℕ) 99,
      ((100:ℝ) - (k:ℝ)) * (1/2)^k
        = (((100 - k) * 2^(99 - k) : ℕ) : ℝ) * (1/2)^99 := by
    intro k hk
    have hk' := Finset.mem_Icc.mp hk
    have hk100 : k ≤ 100 := by omega
    have hpow : ((1/2:ℝ)^(k:ℕ)) * (2:ℝ)^(99:ℕ) = (2:ℝ)^(99 - k) := by
      have hexp : (k:ℕ) + (99 - k) = 99 := by omega
      calc ((1/2:ℝ)^k) * (2:ℝ)^99 = ((1/2:ℝ)^k) * ((2:ℝ)^k * (2:ℝ)^(99-k)) := by
            rw [← pow_add, hexp]
        _ = (((1/2:ℝ) * (2:ℝ))^k) * (2:ℝ)^(99-k) := by
            rw [mul_pow]; ring
        _ = (2:ℝ)^(99-k) := by norm_num
    have hpow' : ((1/2:ℝ)^(k:ℕ)) = (2:ℝ)^(99 - k) * (1/2)^99 := by
      rw [← hpow, mul_assoc, ← mul_pow]
      norm_num
    rw [Nat.cast_mul, Nat.cast_pow, Nat.cast_sub hk100, hpow']
    ring
  rw [Finset.sum_congr rfl (fun k hk => hterm k hk), ← Finset.sum_mul, ← Nat.cast_sum, hnat]
  norm_num

/-! ## ex:ch11-pg-ssch — estado continuo y gradiente verificable -/

/-- book: capitulos/cap08_intervalos.typ:531 (key: ex:ch11-pg-ssch) —
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
    ∧ (((1:ℝ) / 2) * (2 / 3) * (1 / 2) * (1 / 2) = 1 / 12)
    ∧ (((1 / 2) * ((1:ℝ) / 5) / 4) - (1 / 12) * (1 / 12) = 13 / 720)
    ∧ ((((1:ℝ) / 5) / 16) - ((1 / 3) / 4) * ((1 / 3) / 4) = 1 / 180)
    ∧ ((1:ℝ) - (1 / 180) / (13 / 720) = 9 / 13) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num [integral_pow]
  · norm_num [integral_pow]
  · norm_num
  · norm_num
  · norm_num
  · norm_num

/-! ## thm:ch11-tasa-tabular — #34: cota espectral bajo reversibilidad -/

/-- book: capitulos/cap08_intervalos.typ:110 (key: thm:ch11-tasa-tabular) —
cota espectral bajo reversibilidad, versión finita verificada sobre la
cadena de dos estados del propio libro: para `k ≥ 1`, la forma cerrada
`P^k = 1μ^T + (1/2)^{k−1}·(P − 1μ^T)` da las desigualdades
`TV(k,s) = TV(1,s)·(1/2)^{k−1} ≤ (1/2)·√(1/μ(s)−1)·(1/2)^k` y, con la
convención estacionaria `β(k) = Σ_s μ(s)·TV(k,s)`, se obtiene
`β(k) ≤ (1/2)·√(m−1)·(1/2)^k` con `m = 2`. Fidelidad declarada: el libro
enuncia el teorema general para cadenas finitas irreducibles
aperiódicas reversibles; la demostración general (operador autoadjunto
en `L²(μ)` y Cauchy–Schwarz) no se formaliza aquí; las dos
comparaciones clave se reducen a `72 ≤ 75` y `24 ≤ 25` (racionales).
Origen: F3 2026-11-05 (nuevo). -/
theorem ch11_tasa_tabular :
    -- la forma cerrada de P^k (declarada como definición P2k)
    (∀ k : ℕ, 1 ≤ k → ∀ s : Bool, ∀ s' : Bool,
        P2k k s s' - μ2 s' = (1/2)^(k-1) * (P2 s s' - μ2 s'))
    -- el TV a un paso (calculado)
    ∧ ((1/2) * (∑ s' : Bool, |P2 true s' - μ2 s'|) = 3/10)
    ∧ ((1/2) * (∑ s' : Bool, |P2 false s' - μ2 s'|) = 1/5)
    -- las comparaciones clave (racionales: 72 ≤ 75 y 24 ≤ 25)
    ∧ (((3:ℝ)/10) * (3/10) ≤ (1/4) * (3/2))
    ∧ (((1:ℝ)/5) * (1/5) ≤ (1/4) * (2/3))
    -- la cota per-estado del libro (con la forma del TV escalado)
    ∧ (∀ k : ℕ, 1 ≤ k → ∀ s : Bool,
        (1/2) * (∑ s' : Bool, |P2k k s s' - μ2 s'|)
          ≤ (1/2) * Real.sqrt (1 / μ2 s - 1) * (1/2)^k)
    -- la cota estacionaria β(k) ≤ (1/2)·(1/2)^k (m = 2)
    ∧ (∀ k : ℕ, 1 ≤ k →
        (∑ s : Bool, μ2 s * ((1/2) * (∑ s' : Bool, |P2k k s s' - μ2 s'|)))
          ≤ (1/2) * (1/2)^k) := by
  -- la forma cerrada (la descomposición espectral de la matriz 2×2)
  have hdev : ∀ k : ℕ, 1 ≤ k → ∀ s : Bool, ∀ s' : Bool,
      P2k k s s' - μ2 s' = (1/2)^(k-1) * (P2 s s' - μ2 s') := by
    intro k hk s s'
    unfold P2k
    rw [if_neg (by omega : k ≠ 0)]
    ring
  -- las desviaciones absolutas por fila: D(true) = 3/5, D(false) = 2/5
  have hDt : (∑ s' : Bool, |P2 true s' - μ2 s'|) = 3/5 := by
    rw [Fintype.sum_bool]; norm_num [P2, μ2]
  have hDf : (∑ s' : Bool, |P2 false s' - μ2 s'|) = 2/5 := by
    rw [Fintype.sum_bool]; norm_num [P2, μ2]
  have hhalf : ∀ k : ℕ, 1 ≤ k → (1:ℝ)/2 * (1/2)^(k-1) = (1/2)^k := by
    intro k hk
    obtain ⟨m, hm⟩ : ∃ m : ℕ, k = m + 1 := ⟨k - 1, by omega⟩
    subst hm
    have h2 : (m : ℕ) + 1 - 1 = m := by omega
    simp only [h2, pow_succ]
    ring
  -- la comparación por estado: D(s) ≤ (1/2)·√(1/μ(s)−1), es decir,
  -- 9/25 ≤ 3/8 (72 ≤ 75) para true y 4/25 ≤ 1/6 (24 ≤ 25) para false
  have hkey : ∀ s : Bool,
      (∑ s' : Bool, |P2 s s' - μ2 s'|) ≤ (1/2) * Real.sqrt (1 / μ2 s - 1) := by
    intro s
    cases s
    · have hs : (1:ℝ) / μ2 false - 1 = 2/3 := by norm_num [μ2]
      rw [hDf, hs]
      have hb : (0:ℝ) ≤ 2/3 := by norm_num
      have hnn : (0:ℝ) ≤ (1/2) * Real.sqrt (2/3) := by positivity
      exact le_of_sq_le_sq (by rw [mul_pow, Real.sq_sqrt hb]; norm_num) hnn
    · have hs : (1:ℝ) / μ2 true - 1 = 3/2 := by norm_num [μ2]
      rw [hDt, hs]
      have hb : (0:ℝ) ≤ 3/2 := by norm_num
      have hnn : (0:ℝ) ≤ (1/2) * Real.sqrt (3/2) := by positivity
      exact le_of_sq_le_sq (by rw [mul_pow, Real.sq_sqrt hb]; norm_num) hnn
  -- el TV de k pasos factoriza: (1/2)·Σ|P^k − μ| = (1/2)^k·D(s)
  have hTV : ∀ k : ℕ, 1 ≤ k → ∀ s : Bool,
      (1/2) * (∑ s' : Bool, |P2k k s s' - μ2 s'|)
        = (1/2)^k * (∑ s' : Bool, |P2 s s' - μ2 s'|) := by
    intro k hk s
    have hpow : (0:ℝ) ≤ (1/2)^(k-1) := by positivity
    have habs : ∀ s' : Bool,
        |P2k k s s' - μ2 s'| = (1/2)^(k-1) * |P2 s s' - μ2 s'| := by
      intro s'
      rw [hdev k hk s s', abs_mul, abs_of_nonneg hpow]
    simp only [habs, ← Finset.mul_sum]
    rw [← mul_assoc, hhalf k hk]
  refine ⟨hdev, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hDt]; norm_num
  · rw [hDf]; norm_num
  · norm_num
  · norm_num
  · intro k hk s
    rw [hTV k hk s]
    have hw : (0:ℝ) < (1/2)^k := by positivity
    calc (1/2)^k * (∑ s' : Bool, |P2 s s' - μ2 s'|)
        = (∑ s' : Bool, |P2 s s' - μ2 s'|) * (1/2)^k := by ring
      _ ≤ ((1/2) * Real.sqrt (1 / μ2 s - 1)) * (1/2)^k :=
          mul_le_mul_of_nonneg_right (hkey s) (le_of_lt hw)
      _ = (1/2) * Real.sqrt (1 / μ2 s - 1) * (1/2)^k := by ring
  · intro k hk
    have hw : (0:ℝ) < (1/2)^k := by positivity
    have hμt : μ2 true = 2/5 := by norm_num [μ2]
    have hμf : μ2 false = 3/5 := by norm_num [μ2]
    have houter : (∑ s : Bool, μ2 s * ((1/2) * (∑ s' : Bool, |P2k k s s' - μ2 s'|)))
        = μ2 true * ((1/2) * (∑ s' : Bool, |P2k k true s' - μ2 s'|))
          + μ2 false * ((1/2) * (∑ s' : Bool, |P2k k false s' - μ2 s'|)) :=
      Fintype.sum_bool _
    calc (∑ s : Bool, μ2 s * ((1/2) * (∑ s' : Bool, |P2k k s s' - μ2 s'|)))
        = (12:ℝ)/25 * (1/2)^k := by
          rw [houter, hTV k hk true, hTV k hk false, hDt, hDf, hμt, hμf]
          ring
      _ ≤ (1/2) * (1/2)^k := mul_le_mul_of_nonneg_right (by norm_num) (le_of_lt hw)
