import Mathlib

/-!
# Book.ApendiceDViolaciones — contraejemplos del apéndice D (swarm smw8gy947/m3)

Claves del libro cerradas aquí:

* `ex:appD-irreducible` — `capitulos/cap06_fallos.typ:602`
* `ex:appD-aperiodico` — `capitulos/cap06_fallos.typ:614`
* `ex:appD-lento` — `capitulos/cap06_fallos.typ:627`

**Fidelidad declarada**: los tres enunciados del libro son afirmaciones sobre
cadenas de Markov finitas concretas o sobre series numéricas; aquí se formalizan
sin reducción del contenido (ver el docstring de cada teorema).
-/

open Finset BigOperators
open scoped BigOperators Topology
open Filter

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

namespace Book.ApendiceDM3

/-! ## 0. Núcleo estocástico finito y sus potencias -/

section Nucleo

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Matriz de transición fila-estocástica sobre un espacio de estados finito. -/
structure Estocastica (P : S → S → ℝ) : Prop where
  nonneg : ∀ s s', 0 ≤ P s s'
  suma : ∀ s, ∑ s', P s s' = 1

/-- Potencias del núcleo: `pot P n s s' = P^n(s,s')`. -/
def pot (P : S → S → ℝ) : ℕ → S → S → ℝ
  | 0 => fun s s' => if s = s' then 1 else 0
  | n + 1 => fun s s' => ∑ t, pot P n s t * P t s'

lemma pot_zero (P : S → S → ℝ) (s s' : S) : pot P 0 s s' = if s = s' then 1 else 0 := rfl

lemma pot_succ (P : S → S → ℝ) (n : ℕ) (s s' : S) :
    pot P (n + 1) s s' = ∑ t, pot P n s t * P t s' := rfl

lemma pot_one (P : S → S → ℝ) (s s' : S) : pot P 1 s s' = P s s' := by
  show ∑ t, pot P 0 s t * P t s' = P s s'
  rw [Finset.sum_eq_single s]
  · rw [pot_zero, if_pos rfl, one_mul]
  · intro b _ hb
    rw [pot_zero, if_neg (fun h : s = b => hb h.symm), zero_mul]
  · intro h; exact absurd (Finset.mem_univ s) h

lemma pot_nonneg {P : S → S → ℝ} (hP : ∀ s s', 0 ≤ P s s') :
    ∀ (n : ℕ) (s s' : S), 0 ≤ pot P n s s'
  | 0, s, s' => by
      rw [pot_zero]; split <;> norm_num
  | n + 1, s, s' => by
      rw [pot_succ]
      exact Finset.sum_nonneg fun t _ => mul_nonneg (pot_nonneg hP n s t) (hP t s')

/-- Chapman–Kolmogorov: `P^{m+n} = P^m P^n`. -/
lemma pot_add {P : S → S → ℝ} (m n : ℕ) (s s' : S) :
    pot P (m + n) s s' = ∑ t, pot P m s t * pot P n t s' := by
  induction n generalizing s' with
  | zero =>
    show pot P m s s' = ∑ t, pot P m s t * (if t = s' then 1 else 0)
    rw [Finset.sum_eq_single s']
    · rw [if_pos rfl, mul_one]
    · intro b _ hb
      rw [if_neg (fun h : b = s' => hb h), mul_zero]
    · intro h; exact absurd (Finset.mem_univ s') h
  | succ n ih =>
    calc pot P (m + (n + 1)) s s'
        = ∑ t, pot P (m + n) s t * P t s' := by rw [Nat.add_succ, pot_succ]
      _ = ∑ t, (∑ u, pot P m s u * pot P n u t) * P t s' := by simp only [ih]
      _ = ∑ t, ∑ u, (pot P m s u * pot P n u t) * P t s' := by
            refine Finset.sum_congr rfl fun t _ => ?_
            rw [Finset.sum_mul]
      _ = ∑ u, ∑ t, (pot P m s u * pot P n u t) * P t s' := Finset.sum_comm
      _ = ∑ u, pot P m s u * ∑ t, pot P n u t * P t s' := by
            refine Finset.sum_congr rfl fun u _ => ?_
            rw [Finset.mul_sum]
            refine Finset.sum_congr rfl fun t _ => ?_
            ring
      _ = ∑ u, pot P m s u * pot P (n + 1) u s' := by
            refine Finset.sum_congr rfl fun u _ => ?_
            rw [pot_succ]

/-- Las filas de `P^n` suman uno. -/
lemma pot_suma_filas {P : S → S → ℝ} (hP : Estocastica P) (n : ℕ) (s : S) :
    ∑ s', pot P n s s' = 1 := by
  induction n with
  | zero =>
      rw [Finset.sum_eq_single s]
      · rw [pot_zero, if_pos rfl]
      · intro b _ hb
        rw [pot_zero, if_neg (fun h : s = b => hb h.symm)]
      · intro h; exact absurd (Finset.mem_univ s) h
  | succ n ih =>
      rw [show ∑ s', pot P (n + 1) s s' = ∑ s', ∑ t, pot P n s t * P t s' from rfl,
        Finset.sum_comm]
      calc ∑ t, ∑ s', pot P n s t * P t s'
          = ∑ t, pot P n s t * 1 := by
            refine Finset.sum_congr rfl fun t _ => ?_
            rw [← Finset.mul_sum, hP.suma t, mul_one]
        _ = 1 := by simpa using ih

/-- Cadena irreducible: de todo estado a todo estado se llega con probabilidad
positiva en algún número de pasos. -/
def Irreducible (P : S → S → ℝ) : Prop := ∀ s s', ∃ n, 0 < pot P n s s'

/-- Cadena **aperiódica** en forma operativa: para todo par de estados, todas las
longitudes de transición suficientemente grandes son posibles. -/
def Aperiodica (P : S → S → ℝ) : Prop := ∀ s s', ∃ N, ∀ n, N ≤ n → 0 < pot P n s s'

end Nucleo

/-! ## 1. `ex:appD-irreducible` — dos clases absorbentes -/

/-- Cadena identidad sobre `Fin 2`: cada estado es absorbente. -/
def Pid : Fin 2 → Fin 2 → ℝ := fun s s' => if s = s' then 1 else 0

/-- Dirac en el estado `0`. -/
def dir0 : Fin 2 → ℝ := fun s => if s = 0 then 1 else 0

/-- Dirac en el estado `1`. -/
def dir1 : Fin 2 → ℝ := fun s => if s = 1 then 1 else 0

lemma pot_Pid (n : ℕ) : ∀ s s' : Fin 2, pot Pid n s s' = if s = s' then 1 else 0 := by
  induction n with
  | zero => intro s s'; rfl
  | succ n ih =>
      intro s s'
      rw [pot_succ, Finset.sum_eq_single s]
      · rw [ih s s]; simp [Pid]
      · intro b _ hb
        rw [ih s b, if_neg (fun h : s = b => hb h.symm), zero_mul]
      · intro h; exact absurd (Finset.mem_univ s) h

lemma Pid_estocastica : Estocastica Pid := by
  constructor
  · intro s s'; unfold Pid; split <;> norm_num
  · intro s
    rw [Fin.sum_univ_two]
    fin_cases s <;> norm_num [Pid]

lemma Pid_no_irreducible : ¬ Irreducible Pid := by
  intro h
  obtain ⟨n, hn⟩ := h 0 1
  have h01 : (0 : Fin 2) ≠ 1 := by decide
  rw [pot_Pid n 0 1, if_neg h01] at hn
  exact lt_irrefl (0 : ℝ) hn

lemma dir0_invariante (s' : Fin 2) : ∑ s, dir0 s * Pid s s' = dir0 s' := by
  rw [Fin.sum_univ_two]
  fin_cases s' <;> norm_num [dir0, Pid]

lemma dir1_invariante (s' : Fin 2) : ∑ s, dir1 s * Pid s s' = dir1 s' := by
  rw [Fin.sum_univ_two]
  fin_cases s' <;> norm_num [dir1, Pid]

lemma dir0_masa : ∑ s, dir0 s = 1 := by
  rw [Fin.sum_univ_two]; norm_num [dir0]

lemma dir1_masa : ∑ s, dir1 s = 1 := by
  rw [Fin.sum_univ_two]; norm_num [dir1]

lemma dir0_ne_dir1 : dir0 ≠ dir1 := by
  intro h
  have h0 := congrFun h 0
  norm_num [dir0, dir1] at h0

/-- **Violación de irreducibilidad** (`book: capitulos/cap06_fallos.typ:602`,
`key: ex:appD-irreducible`).

Fidelidad declarada: **exacta**. La cadena identidad sobre dos estados es
estocástica, no es irreducible (desde `0` no se llega a `1` en ningún número de
pasos) y tiene dos distribuciones invariantes distintas (`dir0`, `dir1`): el
límite temporal depende de la clase inicial, de modo que la longitud de una
trayectoria no aporta información sobre la probabilidad poblacional de inicio. -/
theorem irreducible_dos_clases_absorbentes :
    Estocastica Pid ∧ ¬ Irreducible Pid ∧
      (∃ μ ν : Fin 2 → ℝ, (∀ s, 0 ≤ μ s) ∧ (∑ s, μ s = 1) ∧
        (∀ s', ∑ s, μ s * Pid s s' = μ s') ∧ (∀ s, 0 ≤ ν s) ∧ (∑ s, ν s = 1) ∧
        (∀ s', ∑ s, ν s * Pid s s' = ν s') ∧ ν ≠ μ) := by
  refine ⟨Pid_estocastica, Pid_no_irreducible, dir0, dir1, ?_, dir0_masa, dir0_invariante,
    ?_, dir1_masa, dir1_invariante, Ne.symm dir0_ne_dir1⟩
  · intro s; unfold dir0; split <;> norm_num
  · intro s; unfold dir1; split <;> norm_num

/-- Cadena con un estado transitorio (`0 → 1`) y una única clase cerrada (`{1}`):
`P s s' = 1` si y sólo si `s' = 1`. -/
def Ptrans : Fin 2 → Fin 2 → ℝ := fun _ s' => if s' = 1 then 1 else 0

lemma Ptrans_estocastica : Estocastica Ptrans := by
  constructor
  · intro s s'; unfold Ptrans; split <;> norm_num
  · intro s
    rw [Fin.sum_univ_two]
    norm_num [Ptrans]

lemma pot_Ptrans_uno_cero (n : ℕ) : pot Ptrans n 1 0 = 0 := by
  induction n with
  | zero => rw [pot_zero]; norm_num
  | succ n ih =>
      rw [pot_succ, Fin.sum_univ_two]
      have h0 : Ptrans 0 0 = 0 := by norm_num [Ptrans]
      have h1 : Ptrans 1 0 = 0 := by norm_num [Ptrans]
      rw [h0, h1, mul_zero, mul_zero, add_zero]

lemma Ptrans_no_irreducible : ¬ Irreducible Ptrans := by
  intro h
  obtain ⟨n, hn⟩ := h 1 0
  rw [pot_Ptrans_uno_cero n] at hn
  exact lt_irrefl (0 : ℝ) hn

lemma dir1_invariante_Ptrans (s' : Fin 2) : ∑ s, dir1 s * Ptrans s s' = dir1 s' := by
  rw [Fin.sum_univ_two]
  fin_cases s' <;> norm_num [dir1, Ptrans]

/-- **Reducible con una única distribución invariante** (`book:
capitulos/cap06_fallos.typ:602`, complemento de `ex:appD-irreducible`).

Fidelidad declarada: **exacta**. El libro advierte que «reducibilidad no implica
siempre múltiples distribuciones invariantes: puede haber estados transitorios y
una sola clase cerrada». Aquí `Ptrans` es reducible (`1` no alcanza `0`) y su
única distribución invariante es `dir1`: la etiqueta «reducible» no decide. -/
theorem reducible_unica_invariante :
    Estocastica Ptrans ∧ ¬ Irreducible Ptrans ∧
      (∃ μ : Fin 2 → ℝ, (∀ s, 0 ≤ μ s) ∧ (∑ s, μ s = 1) ∧
        (∀ s', ∑ s, μ s * Ptrans s s' = μ s') ∧
        ∀ ν : Fin 2 → ℝ, (∑ s, ν s = 1) →
          (∀ s', ∑ s, ν s * Ptrans s s' = ν s') → ν = μ) := by
  refine ⟨Ptrans_estocastica, Ptrans_no_irreducible, dir1, ?_, dir1_masa,
    dir1_invariante_Ptrans, ?_⟩
  · intro s; unfold dir1; split <;> norm_num
  · intro ν hν hinv
    have h0 : ν 0 = 0 := by
      have h := hinv 0
      rw [Fin.sum_univ_two] at h
      have e0 : Ptrans 0 0 = 0 := by norm_num [Ptrans]
      have e1 : Ptrans 1 0 = 0 := by norm_num [Ptrans]
      rw [e0, e1, mul_zero, mul_zero, add_zero] at h
      exact h.symm
    have h1 : ν 1 = 1 := by
      have h := hν
      rw [Fin.sum_univ_two] at h
      rw [h0] at h
      linarith
    funext s
    fin_cases s
    · show ν (0 : Fin 2) = dir1 (0 : Fin 2)
      rw [h0]; norm_num [dir1]
    · show ν (1 : Fin 2) = dir1 (1 : Fin 2)
      rw [h1]; norm_num [dir1]

/-! ## 2. `ex:appD-aperiodico` — cadena determinista de periodo 2 -/

/-- Intercambio determinista sobre `Fin 2`: `P s s' = 1` si `s ≠ s'`. -/
def Psalto : Fin 2 → Fin 2 → ℝ := fun s s' => if s = s' then 0 else 1

lemma Psalto_estocastica : Estocastica Psalto := by
  constructor
  · intro s s'; unfold Psalto; split <;> norm_num
  · intro s
    rw [Fin.sum_univ_two]
    fin_cases s <;> norm_num [Psalto]

/-- Recurrencia de `Psalto`: `P^{n+1} = J − P^n` en cada entrada, porque cada
fila de `P^n` suma uno y `Psalto t s' = 1 − δ_{t,s'}`. -/
lemma pot_Psalto_succ (n : ℕ) (s s' : Fin 2) :
    pot Psalto (n + 1) s s' = 1 - pot Psalto n s s' := by
  rw [pot_succ]
  have hrow := pot_suma_filas Psalto_estocastica n s
  have hexp : ∀ t : Fin 2, Psalto t s' = 1 - (if t = s' then 1 else 0) := by
    intro t; unfold Psalto; by_cases h : t = s' <;> simp [h]
  calc ∑ t, pot Psalto n s t * Psalto t s'
      = ∑ t, pot Psalto n s t * (1 - (if t = s' then 1 else 0)) := by
        refine Finset.sum_congr rfl fun t _ => by rw [hexp t]
    _ = ∑ t, (pot Psalto n s t - pot Psalto n s t * (if t = s' then 1 else 0)) := by
        refine Finset.sum_congr rfl fun t _ => by rw [mul_sub, mul_one]
    _ = 1 - pot Psalto n s s' := by
        rw [Finset.sum_sub_distrib, hrow]
        congr 1
        rw [Finset.sum_eq_single s']
        · rw [if_pos rfl, mul_one]
        · intro b _ hb; rw [if_neg hb, mul_zero]
        · intro h; exact absurd (Finset.mem_univ s') h

lemma pot_Psalto_even (m : ℕ) : ∀ s s' : Fin 2,
    pot Psalto (2 * m) s s' = if s = s' then 1 else 0 := by
  induction m with
  | zero => intro s s'; rw [pot_zero]
  | succ m ih =>
      intro s s'
      have h : 2 * (m + 1) = 2 * m + 1 + 1 := by ring
      rw [h, pot_Psalto_succ, pot_Psalto_succ, ih s s']
      by_cases hs : s = s' <;> simp [hs]

lemma pot_Psalto_odd (m : ℕ) : ∀ s s' : Fin 2,
    pot Psalto (2 * m + 1) s s' = if s = s' then 0 else 1 := by
  induction m with
  | zero =>
      intro s s'
      rw [pot_Psalto_succ, pot_zero]
      by_cases hs : s = s' <;> simp [hs]
  | succ m ih =>
      intro s s'
      have h : 2 * (m + 1) + 1 = 2 * m + 1 + 1 + 1 := by ring
      rw [h, pot_Psalto_succ, pot_Psalto_succ, ih s s']
      by_cases hs : s = s' <;> simp [hs]

lemma Psalto_irreducible : Irreducible Psalto := by
  intro s s'
  by_cases h : s = s'
  · refine ⟨2, ?_⟩
    rw [pot_Psalto_even 1 s s', if_pos h]; norm_num
  · refine ⟨1, ?_⟩
    rw [pot_one]
    simp [Psalto, h]

lemma Psalto_no_aperiodica : ¬ Aperiodica Psalto := by
  intro h
  obtain ⟨N, hN⟩ := h 0 0
  have hpos := hN (2 * N + 1) (by omega)
  have hzero : pot Psalto (2 * N + 1) 0 0 = 0 := by
    rw [pot_Psalto_odd N 0 0, if_pos rfl]
  rw [hzero] at hpos
  exact lt_irrefl (0 : ℝ) hpos

lemma uniforme_invariante (s' : Fin 2) :
    ∑ s, (1 / 2 : ℝ) * Psalto s s' = 1 / 2 := by
  rw [← Finset.mul_sum]
  have hcol : ∑ s : Fin 2, Psalto s s' = 1 := by
    rw [Fin.sum_univ_two]
    fin_cases s' <;> norm_num [Psalto]
  rw [hcol, mul_one]

/-- Indicador de estado `0` a lo largo de la trayectoria determinista `S_t = t mod 2`
(la cadena `Psalto` iniciada en `0`). -/
def alternante (t : ℕ) : ℝ := if t % 2 = 0 then 1 else 0

lemma alternante_par (m : ℕ) : alternante (2 * m) = 1 := by
  unfold alternante
  rw [if_pos]
  omega

lemma alternante_impar (m : ℕ) : alternante (2 * m + 1) = 0 := by
  unfold alternante
  rw [if_neg]
  omega

lemma suma_pares : ∀ m : ℕ, Finset.sum (Finset.range (2 * m)) alternante = (m : ℝ)
  | 0 => by simp
  | m + 1 => by
      have h : 2 * (m + 1) = 2 * m + 1 + 1 := by ring
      rw [h, Finset.sum_range_succ, Finset.sum_range_succ, suma_pares m,
        alternante_par m, alternante_impar m]
      push_cast; ring

lemma alternante_par_succ (m : ℕ) : alternante (2 * m + 2) = 1 := by
  rw [show 2 * m + 2 = 2 * (m + 1) from by ring]
  exact alternante_par (m + 1)

lemma suma_impares : ∀ m : ℕ, Finset.sum (Finset.range (2 * m + 1)) alternante = (m : ℝ) + 1
  | 0 => by simp [alternante]
  | m + 1 => by
      have h : 2 * (m + 1) + 1 = (2 * m + 1) + 1 + 1 := by ring
      rw [h, Finset.sum_range_succ, Finset.sum_range_succ, suma_impares m,
        alternante_impar m, alternante_par_succ m]
      push_cast; ring

/-- **Violación de aperiodicidad** (`book: capitulos/cap06_fallos.typ:614`,
`key: ex:appD-aperiodico`).

Fidelidad declarada: **exacta**. La cadena determinista `0,1,0,1,…` con fase
inicial uniforme es estocástica, irreducible y **periódica** (no aperiódica: desde
`0` no se vuelve a `0` en tiempo impar), y su media temporal verifica
`|X̄_T − 1/2| ≤ 1/(2T)` para todo `T ≥ 1`: el promedio sí converge aunque la
distribución desde un estado fijo oscile. -/
theorem aperiodico_oscilante :
    Estocastica Psalto ∧ Irreducible Psalto ∧ ¬ Aperiodica Psalto ∧
      (∀ s', ∑ s, (1 / 2 : ℝ) * Psalto s s' = 1 / 2) ∧
      (∀ T : ℕ, 0 < T →
        |(Finset.sum (Finset.range T) alternante) / (T : ℝ) - 1 / 2| ≤ 1 / (2 * (T : ℝ))) := by
  refine ⟨Psalto_estocastica, Psalto_irreducible, Psalto_no_aperiodica,
    uniforme_invariante, ?_⟩
  intro T hT
  rcases Nat.even_or_odd T with ⟨m, hm⟩ | ⟨m, hm⟩
  · have hT' : T = 2 * m := by omega
    subst hT'
    have hm0 : 0 < m := by omega
    rw [suma_pares m]
    have hR : ((2 * m : ℕ) : ℝ) = 2 * (m : ℝ) := by push_cast; ring
    rw [hR]
    have hmR : (m : ℝ) ≠ 0 := by
      have hpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm0
      exact ne_of_gt hpos
    have hzero : (m : ℝ) / (2 * (m : ℝ)) - 1 / 2 = 0 := by
      field_simp
      norm_num
    rw [hzero, abs_zero]
    positivity
  · have hT' : T = 2 * m + 1 := by omega
    subst hT'
    rw [suma_impares m]
    have hR : ((2 * m + 1 : ℕ) : ℝ) = 2 * (m : ℝ) + 1 := by push_cast; ring
    rw [hR]
    have hkey : ((m : ℝ) + 1) / (2 * (m : ℝ) + 1) - 1 / 2 = 1 / (2 * (2 * (m : ℝ) + 1)) := by
      field_simp; ring
    rw [hkey, abs_of_nonneg (by positivity)]

/-- Autocovarianza de la cadena alternante estacionaria: `γ_k = (−1)^k/4`. -/
noncomputable def gammaAlt (k : ℕ) : ℝ := if k % 2 = 0 then 1 / 4 else -(1 / 4)

lemma abs_gammaAlt (k : ℕ) : |gammaAlt k| = 1 / 4 := by
  unfold gammaAlt; split <;> norm_num

/-- **La serie de autocovarianzas del ejemplo no es absolutamente sumable**
(`book: capitulos/cap06_fallos.typ:614`, `key: ex:appD-aperiodico`).

Fidelidad declarada: **exacta**. `∑_k |γ_k| = ∑_k 1/4 = ∞`, como afirma el libro. -/
theorem gammaAlt_no_summable : ¬ Summable (fun k : ℕ => |gammaAlt k|) := by
  intro h
  have h0 : Tendsto (fun k : ℕ => |gammaAlt k|) atTop (nhds 0) := h.tendsto_atTop_zero
  rw [show (fun k : ℕ => |gammaAlt k|) = fun _ => (1 / 4 : ℝ) from funext abs_gammaAlt] at h0
  have h1 : (1 / 4 : ℝ) = 0 := tendsto_nhds_unique tendsto_const_nhds h0
  norm_num at h1

/-! ## 3. `ex:appD-lento` — mixing polinomial -/

/-- **Mixing polinomial: la condición de sumabilidad** (`book:
capitulos/cap06_fallos.typ:627`, `key: ex:appD-lento`).

Fidelidad declarada: **exacta**. Si `α(k) ≤ C k^{−ν}` con `C ≥ 0`, `ν > 0` y
existe momento de orden `2+δ` (`δ > 0`), la sumabilidad que exige el CLT de
mixing se sigue de `νδ/(2+δ) > 1`:
`∑_k α(k)^{δ/(2+δ)} ≤ C^{δ/(2+δ)} ∑_k k^{−νδ/(2+δ)} < ∞`.
La CLT misma no se formaliza (fuera del alcance de Mathlib); sí la implicación
analítica que el libro usa como condición suficiente. -/
theorem summable_potencia_alpha {C ν δ : ℝ} (hC : 0 ≤ C) (hν : 0 < ν) (hδ : 0 < δ)
    (h : 1 < ν * δ / (2 + δ)) :
    Summable (fun k : ℕ => (C * (k : ℝ) ^ (-ν)) ^ (δ / (2 + δ))) := by
  have hbase : ∀ k : ℕ, 0 ≤ (k : ℝ) ^ (-ν) := fun k => Real.rpow_nonneg (Nat.cast_nonneg k) _
  have hp : 1 < ν * (δ / (2 + δ)) := by
    have h2 : (0 : ℝ) < 2 + δ := by linarith
    have e : ν * (δ / (2 + δ)) = ν * δ / (2 + δ) := by field_simp
    rw [e]; exact h
  have hsum : Summable (fun k : ℕ => ((k : ℝ) ^ (-(ν * (δ / (2 + δ))))) : ℕ → ℝ) := by
    have h' : Summable (fun k : ℕ => (((k : ℝ) ^ (ν * (δ / (2 + δ))))⁻¹)) :=
      (Real.summable_nat_rpow_inv (p := ν * (δ / (2 + δ)))).mpr hp
    refine h'.congr (fun k => ?_)
    rw [Real.rpow_neg (Nat.cast_nonneg k)]
  refine Summable.congr (hsum.mul_left (C ^ (δ / (2 + δ)))) ?_
  intro k
  rw [Real.mul_rpow hC (hbase k)]
  congr 1
  rw [← Real.rpow_mul (x := (k : ℝ)) (Nat.cast_nonneg k) (-ν) (δ / (2 + δ))]
  ring

/-- **Con `δ = 2` basta `ν > 2`** (`book: capitulos/cap06_fallos.typ:627`,
`key: ex:appD-lento`). Fidelidad declarada: **exacta**. -/
theorem summable_potencia_alpha_dos {C ν : ℝ} (hC : 0 ≤ C) (hν : 2 < ν) :
    Summable (fun k : ℕ => (C * (k : ℝ) ^ (-ν)) ^ ((2 : ℝ) / (2 + 2))) := by
  refine summable_potencia_alpha hC (by linarith) (by norm_num) ?_
  have e : ν * (2 : ℝ) / (2 + 2) = ν / 2 := by ring
  rw [e]; linarith

/-- **Con `ν = 1` la condición no se satisface y la serie asociada diverge**
(`book: capitulos/cap06_fallos.typ:627`, `key: ex:appD-lento`).

Fidelidad declarada: **exacta**. `νδ/(2+δ) = 1/2 ≤ 1` y `∑_k k^{−1/2} = ∞`: la
cota con `ν = 1` no permite concluir el CLT (lo que no demuestra que todo CLT sea
imposible). -/
theorem polinomial_nu_uno_diverge :
    ¬ Summable (fun k : ℕ => (((k : ℝ) ^ ((1 : ℝ) * (2 : ℝ) / (2 + 2)))⁻¹) : ℕ → ℝ) := by
  rw [Real.summable_nat_rpow_inv]
  norm_num

end Book.ApendiceDM3
