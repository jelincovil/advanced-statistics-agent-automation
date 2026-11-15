import Book.Cap08BanditsM7

/-!
# UCB1: esqueleto determinista completo y frontera probabilística explícita

`book: capitulos/cap03_mdp.typ:145 (key: thm:ch8-ucb1)`

El bloque del libro (líneas 145–151 de `capitulos/cap03_mdp.typ`) enuncia, para
recompensas en `[0,1]` y `T ≥ K`, que UCB1 juega cada brazo una vez y luego
elige un máximo de `muhat_a(t-1) + sqrt(2 log t / N_a(t-1))`, y cita a Auer et
al. (2002) para
`R_T ≤ 8 Σ_{a: Δ_a>0} (log T)/Δ_a + (1+π²/3) Σ_a Δ_a`.
El libro declara expresamente que no desarrolla la demostración.

Este módulo cierra la mitad **determinista** de esa demostración, es decir la
parte que no usa ninguna desigualdad de concentración, y deja la mitad
probabilística como una hipótesis nombrada y separada. Qué se prueba:

* `count`, `count_eq_card`: la cuenta `N_a(t)` de selecciones del brazo `a` en
  las rondas `0, …, t-1` (la `N_a(t-1)` del libro con rondas 1-indexadas), y
  sus propiedades de monotonía y crecimiento por pasos.
* `sum_play_eq`, `pseudoRegret_eq_sum`, `pseudoRegret_eq_gap_sum`: la
  descomposición del pseudorregret por brazos
  `R_T = Σ_a Δ_a N_a(T) = Σ_{a: Δ_a>0} Δ_a N_a(T)`
  (paso (a) del esqueleto, que el módulo `Cap08BanditsM7` anunciaba pero no
  contenía).
* `Confident`, `IndexMax`: las dos premisas del argumento: el evento de
  confianza (medias empíricas dentro de sus bonus, **sólo para brazos ya
  jugados**: con `N_a = 0` el bonus vale `0` en Lean y exigirlo forzaría a
  conocer la media exacta de los brazos nunca jugados) y la regla de la política
  (el brazo jugado maximiza el índice). La tercera premisa es la de
  inicialización `hvis`: si en la ronda `t ≥ 1` se repite un brazo, todos los
  brazos tienen cuenta positiva.
* `index_comparison_bound`: la comparación de índices **sin** la hipótesis
  `0 < n` que exige `Cap08Bandits.ucb_comparacion_indices`; el caso `n = 0`
  (primera visita) es trivial porque `0` multiplica.
* `ucb1_count_bound`, `ucb1_selection_bound`: bajo el evento de confianza, la
  regla de índice y la inicialización, `Δ_a² N_a(T) ≤ 8 log T + Δ_a²`, o sea
  `N_a(T) ≤ 8 log T/Δ_a² + 1` (paso (c)), ya **derivado**, no postulado: aquí
  se conectan por primera vez `ucb_comparacion_indices` y `ucb_conteo`.
* `sum_gap_mul_count_le`: la suma por brazos **sólo sobre las brechas
  positivas**. Esto repara un defecto real de `Cap08Bandits.ucb1_cota_regret`,
  cuya hipótesis `∀ a, 0 < Δ_a` es insatisfacible en el marco del propio
  teorema (en un conjunto finito no vacío de brazos siempre hay uno con
  `Δ_a = 0`): tal enunciado no es aplicable al caso del libro. La versión de
  este módulo sí lo es.
* `regret_le_gaps`, `regret_le_card`: la cota final determinista
  `R_T ≤ 8 log T Σ_{a:Δ_a>0} Δ_a^{-1} + Σ_{a:Δ_a>0} Δ_a ≤ 8 log T Σ + K`,
  incondicional en `T`, con `K = card A` brazos.

Lo que **no** se prueba y queda declarado como frontera:

* la desigualdad de Hoeffding para recompensas en `[0,1]` ni el lema de la
  unión sobre rondas y brazos que producen, para el evento complementario de
  `Confident`, una probabilidad `≤ (π²/3) Σ_a Δ_a` (la constante
  `(1+π²/3)` del libro);
* la construcción de la ley del bandido (independencia de las secuencias de
  recompensas) y de `R_T` como **esperanza** sobre historias infinitas;
* la optimalidad de la constante asintótica, que el libro no afirma.

`hconf` es, por tanto, la única premisa probabilística del argumento, y es la
que la bibliografía citada por el libro (Auer et al. 2002) debe suministrar.
El PLAN del proyecto (`PLAN_LEAN_LIBRO_2026-11-04.md` §1) excluye UCB1 de lo
que se formaliza: este módulo no cierra `C.thm:ch8-ucb1`, sólo documenta con
precisión dónde está su frontera y qué parte del argumento es propia y
verificada.

Fidelidad declarada:

* brazos `A` finitos, no vacíos y decidibles; rondas `0-indexadas` internamente
  (`count play a T` cuenta las rondas `0, …, T-1`, que es la `N_a(T)` de
  rondas 1-indexadas del libro);
* el pseudorregret es la forma `Σ_t (mu* - mu_{A_t})` del libro; la
  descomposición `= Σ_a Δ_a N_a(T)` se prueba, no se postula;
* la fase de inicialización se modela con `hvis`: en las rondas `0, …, K-1`
  cada brazo se juega a lo sumo una vez, y no se exige ninguna condición de
  índice (el `IndexMax` sólo se pide cuando `0 < count play a t`, es decir al
  repetir un brazo); `hvis` impone además que ninguna repetición ocurra antes de
  que todos los brazos tengan cuenta positiva. Es la lectura fiel de «juega cada
  brazo una vez y luego elige un máximo»;
* no se supone `T ≥ K`: la cota determinista vale para todo `T`, porque la
  primera visita de cada brazo entra por el `+1` de `ucb_conteo`;
* no se formaliza ninguna distribución de probabilidad sobre historias.

Origen: enjambre smwi1z2xl, miembro m7, dirección d4.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

open Finset BigOperators

namespace Cap08Ucb1M7

/-! ### 1. Conteo de selecciones -/

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- Número de veces que la secuencia `play` juega el brazo `a` en las rondas
`0, …, t-1` (cuenta antes de la ronda `t`). -/
def count (play : ℕ → A) (a : A) : ℕ → ℕ
  | 0 => 0
  | t + 1 => count play a t + if play t = a then 1 else 0

@[simp] theorem count_zero (play : ℕ → A) (a : A) : count play a 0 = 0 := rfl

theorem count_succ (play : ℕ → A) (a : A) (t : ℕ) :
    count play a (t + 1) = count play a t + if play t = a then 1 else 0 := rfl

theorem ite_le_one (p : Prop) [Decidable p] : (if p then (1:ℕ) else 0) ≤ 1 := by
  split <;> omega

theorem count_mono (play : ℕ → A) (a : A) (t : ℕ) : count play a t ≤ count play a (t+1) := by
  rw [count_succ]; omega

theorem count_step (play : ℕ → A) (a : A) (t : ℕ) : count play a (t+1) ≤ count play a t + 1 := by
  rw [count_succ]; have := ite_le_one (play t = a); omega

theorem count_eq_of_ne {play : ℕ → A} {a : A} {t : ℕ} (h : play t ≠ a) :
    count play a (t + 1) = count play a t := by
  rw [count_succ, ite_eq_right h]; omega

theorem count_eq_of_eq {play : ℕ → A} {a : A} {t : ℕ} (h : play t = a) :
    count play a (t + 1) = count play a t + 1 := by
  rw [count_succ, ite_eq_left h]

/-- Puente con la lectura por cardinal de un filtro. -/
theorem count_eq_card (play : ℕ → A) (a : A) (t : ℕ) :
    count play a t = ((Finset.range t).filter (fun s => play s = a)).card := by
  induction t with
  | zero => simp
  | succ t ih =>
    rw [count_succ, ih, Finset.range_add_one, Finset.filter_insert]
    by_cases h : play t = a
    · rw [ite_eq_left h, ite_eq_left h]
      have hmem : t ∉ (Finset.range t).filter (fun s => play s = a) := by
        intro ht
        exact absurd (Finset.mem_range.1 (Finset.mem_filter.1 ht).1) (Nat.lt_irrefl t)
      rw [Finset.card_insert_of_notMem hmem]
    · rw [ite_eq_right h, ite_eq_right h]; omega

/-- Si la cuenta de `a` crece en la ronda `t`, es que `play t = a`. -/
theorem play_of_count_lt {play : ℕ → A} {a : A} {t : ℕ}
    (h : count play a t < count play a (t + 1)) : play t = a := by
  by_contra hne
  rw [count_eq_of_ne hne] at h
  exact absurd h (Nat.lt_irrefl _)

/-! ### 2. Descomposición del pseudorregret por brazos -/

/-- Pseudorregret acumulado `Σ_{t<T} (mu* - mu_{A_t})` de la secuencia de
decisiones `play` en `T` rondas. Es la variable aleatoria cuya **esperanza** es el
`cal(R)_T` del libro (`def:ch8-mab`); aquí no se toma esperanza. -/
noncomputable def pseudoRegret (muStar : ℝ) (mu : A → ℝ) (play : ℕ → A) (T : ℕ) : ℝ :=
  ∑ t ∈ Finset.range T, (muStar - mu (play t))

theorem sum_play_eq (play : ℕ → A) (g : A → ℝ) (T : ℕ) :
    ∑ t ∈ Finset.range T, g (play t) = ∑ a, g a * (count play a T : ℝ) := by
  induction T with
  | zero => simp
  | succ T ih =>
    rw [Finset.sum_range_succ, ih]
    have hstep : ∀ a : A, g a * ((count play a (T + 1) : ℕ) : ℝ)
        = g a * ((count play a T : ℕ) : ℝ) + (if play T = a then g a else 0) := by
      intro a
      rw [count_succ]
      split <;> push_cast <;> ring
    calc ∑ a, g a * ((count play a T : ℕ) : ℝ) + g (play T)
        = ∑ a, g a * ((count play a T : ℕ) : ℝ) + ∑ a, (if play T = a then g a else 0) := by
          rw [Finset.sum_ite_eq, ite_eq_left (Finset.mem_univ (play T))]
      _ = ∑ a, (g a * ((count play a T : ℕ) : ℝ) + (if play T = a then g a else 0)) := by
          rw [Finset.sum_add_distrib]
      _ = ∑ a, g a * ((count play a (T + 1) : ℕ) : ℝ) :=
          Finset.sum_congr rfl fun a _ => (hstep a).symm

/-- Paso (a) del esqueleto: `R_T = Σ_a Δ_a N_a(T)`. -/
theorem pseudoRegret_eq_sum (muStar : ℝ) (mu : A → ℝ) (play : ℕ → A) (T : ℕ) :
    pseudoRegret muStar mu play T = ∑ a, (muStar - mu a) * (count play a T : ℝ) :=
  sum_play_eq play (fun a => muStar - mu a) T

/-- Sólo las brechas positivas contribuyen: si `muStar` es la media máxima, los
brazos óptimos (`Δ_a = 0`) aportan `0` al pseudorregret. -/
theorem pseudoRegret_eq_gap_sum {muStar : ℝ} {mu : A → ℝ} (hmax : ∀ a, mu a ≤ muStar)
    (play : ℕ → A) (T : ℕ) :
    pseudoRegret muStar mu play T
      = ∑ a ∈ Finset.univ.filter (fun a => 0 < muStar - mu a),
          (muStar - mu a) * (count play a T : ℝ) := by
  rw [pseudoRegret_eq_sum, Finset.sum_filter]
  refine Finset.sum_congr rfl fun a _ => ?_
  by_cases h : 0 < muStar - mu a
  · rw [ite_eq_left h]
  · rw [ite_eq_right h]
    have hzero : muStar - mu a = 0 :=
      le_antisymm (not_lt.1 h) (by linarith [hmax a])
    rw [hzero, zero_mul]

/-! ### 3. Evento de confianza, regla de índice y comparación sin `n > 0` -/

/-- Evento de confianza en la ronda `t`: para cada brazo **ya jugado** al menos
una vez (`0 < N a`), su media empírica está a distancia a lo más su bonus. La
restricción es necesaria, no cosmética: con `N a = 0` el bonus
`√(2 log t / 0)` vale `0` en Lean (división por cero) y exigir la desigualdad
forzaría conocer exactamente la media de los brazos nunca jugados, cosa que el
evento de concentración del libro no hace ni puede hacer. Es la premisa que el
lema de la unión debe suministrar con probabilidad alta; aquí es hipótesis. -/
def Confident (muhat : A → ℕ → ℝ) (mu : A → ℝ) (N : A → ℕ) (t : ℕ) : Prop :=
  ∀ a, 0 < N a → |muhat a t - mu a| ≤ Cap08Bandits.ucbBonus t (N a)

/-- La elección `choice` maximiza el índice de UCB1 en la ronda `t` con las
cuentas `N` (las de las rondas anteriores). -/
def IndexMax (muhat : A → ℕ → ℝ) (N : A → ℕ) (t : ℕ) (choice : A) : Prop :=
  ∀ b, Cap08Bandits.ucbIndex (muhat b t) t (N b)
    ≤ Cap08Bandits.ucbIndex (muhat choice t) t (N choice)

/-- Comparación de índices sin exigir `0 < n`: si `n = 0` la conclusión es
trivial porque `n` multiplica a la izquierda. -/
theorem index_comparison_bound {t n ns : ℕ} {ma ms mha mhs D : ℝ}
    (ht : 1 ≤ t) (hD : D = ms - ma) (hDpos : 0 < D)
    (hca : |mha - ma| ≤ Cap08Bandits.ucbBonus t n)
    (hcs : |mhs - ms| ≤ Cap08Bandits.ucbBonus t ns)
    (hplay : Cap08Bandits.ucbIndex mhs t ns ≤ Cap08Bandits.ucbIndex mha t n) :
    D ^ 2 * (n : ℝ) ≤ 8 * Real.log t := by
  rcases Nat.eq_zero_or_pos n with h0 | hpos
  · subst h0
    push_cast
    rw [mul_zero]
    have : 0 ≤ Real.log t := Real.log_nonneg (by exact_mod_cast ht)
    linarith
  · exact Cap08Bandits.ucb_comparacion_indices ht hpos hD hDpos hca hcs hplay

/-! ### 4. Del evento de confianza al conteo por brazo -/

section Esqueleto

variable [Nonempty A]

/-- **Cota de conteo (paso (c)).** Si en cada ronda `t ≥ 1` las medias
empíricas de los brazos ya jugados están dentro de sus bonus, el brazo jugado
maximiza el índice (salvo en su primera visita) y, antes de repetir cualquier
brazo, ya se jugó el brazo óptimo `astar` (la inicialización de UCB1), entonces
`Δ_a² N_a(T) ≤ 8 log T + Δ_a²`. -/
theorem ucb1_count_bound (mu : A → ℝ) (muhat : A → ℕ → ℝ) (play : ℕ → A) (a : A)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hgap : 0 < Cap08Bandits.muStar mu - mu a)
    (hconf : ∀ t, 1 ≤ t → Confident muhat mu (fun b => count play b t) t)
    (hplay : ∀ t, 1 ≤ t → 0 < count play a t →
      IndexMax muhat (fun b => count play b t) t (play t))
    (hvis : ∀ t, 1 ≤ t → 0 < count play (play t) t → ∀ b, 0 < count play b t)
    (T : ℕ) :
    (Cap08Bandits.muStar mu - mu a) ^ 2 * (count play a T : ℝ)
      ≤ 8 * Real.log T + (Cap08Bandits.muStar mu - mu a) ^ 2 := by
  refine Cap08Bandits.ucb_conteo (fun t => count play a t) (Cap08Bandits.muStar mu - mu a)
    hgap (count_zero play a) (count_mono play a) (count_step play a) ?_ T
  intro t ht hlt
  have hpt : play t = a := play_of_count_lt hlt
  have hconft := hconf t ht
  rcases Nat.eq_zero_or_pos (count play a t) with h0 | hpos
  · rw [h0]
    push_cast
    rw [mul_zero]
    exact mul_nonneg (by norm_num) (Real.log_nonneg (by exact_mod_cast ht))
  · have hidx : Cap08Bandits.ucbIndex (muhat astar t) t (count play astar t)
        ≤ Cap08Bandits.ucbIndex (muhat a t) t (count play a t) := by
      have := hplay t ht hpos astar
      rwa [hpt] at this
    exact index_comparison_bound (t := t) (n := count play a t) (ns := count play astar t)
      (ma := mu a) (ms := mu astar) (mha := muhat a t) (mhs := muhat astar t)
      (D := Cap08Bandits.muStar mu - mu a) ht (by rw [hstar]) hgap
      (hconft a hpos) (hconft astar (hvis t ht (by rw [hpt]; exact hpos) astar)) hidx

/-- Forma divisoria de la cota de conteo: `N_a(T) ≤ 8 log T/Δ_a² + 1`. -/
theorem ucb1_selection_bound (mu : A → ℝ) (muhat : A → ℕ → ℝ) (play : ℕ → A) (a : A)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hgap : 0 < Cap08Bandits.muStar mu - mu a)
    (hconf : ∀ t, 1 ≤ t → Confident muhat mu (fun b => count play b t) t)
    (hplay : ∀ t, 1 ≤ t → 0 < count play a t →
      IndexMax muhat (fun b => count play b t) t (play t))
    (hvis : ∀ t, 1 ≤ t → 0 < count play (play t) t → ∀ b, 0 < count play b t)
    (T : ℕ) :
    (count play a T : ℝ)
      ≤ 8 * Real.log T / (Cap08Bandits.muStar mu - mu a) ^ 2 + 1 := by
  have h := ucb1_count_bound mu muhat play a astar hstar hgap hconf hplay hvis T
  have hpos2 : (0:ℝ) < (Cap08Bandits.muStar mu - mu a) ^ 2 := by positivity
  have key : (count play a T : ℝ)
      ≤ (8 * Real.log T + (Cap08Bandits.muStar mu - mu a) ^ 2)
          / (Cap08Bandits.muStar mu - mu a) ^ 2 := by
    rw [le_div_iff₀ hpos2, mul_comm]
    exact h
  calc (count play a T : ℝ)
      ≤ (8 * Real.log T + (Cap08Bandits.muStar mu - mu a) ^ 2)
          / (Cap08Bandits.muStar mu - mu a) ^ 2 := key
    _ = 8 * Real.log T / (Cap08Bandits.muStar mu - mu a) ^ 2 + 1 := by
        field_simp

end Esqueleto

/-! ### 5. Suma por brazos sobre las brechas positivas -/

section SumaBrazos

/-- **Paso (d), reparado.** Suma de las cotas de conteo sólo sobre los brazos
con `Δ_a > 0`. La versión de `Cap08Bandits.ucb1_cota_regret` pide `∀ a, 0 < Δ_a`,
hipótesis incompatible con la existencia de un brazo óptimo (`Δ_a = 0`), que es
inevitable en un conjunto finito no vacío de brazos con máximo alcanzado. -/
theorem sum_gap_mul_count_le {T : ℕ} (N : A → ℕ) (Delta : A → ℝ)
    (hN : ∀ a, 0 < Delta a → (N a : ℝ) ≤ 8 * Real.log T / (Delta a) ^ 2 + 1) :
    ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), Delta a * (N a : ℝ)
      ≤ 8 * Real.log T * ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), (Delta a)⁻¹
        + ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), Delta a := by
  calc ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), Delta a * (N a : ℝ)
      ≤ ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a),
          (8 * Real.log T * (Delta a)⁻¹ + Delta a) := by
        refine Finset.sum_le_sum fun a ha => ?_
        have hpos : 0 < Delta a := (Finset.mem_filter.1 ha).2
        have hb := hN a hpos
        have heq : Delta a * (8 * Real.log T / (Delta a) ^ 2 + 1)
            = 8 * Real.log T * (Delta a)⁻¹ + Delta a := by
          field_simp
        calc Delta a * (N a : ℝ)
            ≤ Delta a * (8 * Real.log T / (Delta a) ^ 2 + 1) :=
              mul_le_mul_of_nonneg_left hb (le_of_lt hpos)
          _ = 8 * Real.log T * (Delta a)⁻¹ + Delta a := heq
    _ = 8 * Real.log T * ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), (Delta a)⁻¹
          + ∑ a ∈ Finset.univ.filter (fun a => 0 < Delta a), Delta a := by
        simp only [Finset.sum_add_distrib, Finset.mul_sum]

end SumaBrazos

/-! ### 6. Cota del pseudorregret condicionada al evento de confianza -/

section CotaFinal

variable [Nonempty A]

/-- **Cota determinista del pseudorregret.** Bajo el evento de confianza en todas
las rondas y la regla de índice a partir de la segunda visita de cada brazo,
`R_T ≤ 8 log T Σ_{Δ_a>0} Δ_a^{-1} + Σ_{Δ_a>0} Δ_a`. -/
theorem regret_le_gaps (mu : A → ℝ) (muhat : A → ℕ → ℝ) (play : ℕ → A)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hconf : ∀ t, 1 ≤ t → Confident muhat mu (fun b => count play b t) t)
    (hplay : ∀ a t, 1 ≤ t → 0 < count play a t →
      IndexMax muhat (fun b => count play b t) t (play t))
    (hvis : ∀ t, 1 ≤ t → 0 < count play (play t) t → ∀ b, 0 < count play b t)
    (T : ℕ) :
    pseudoRegret (Cap08Bandits.muStar mu) mu play T
      ≤ 8 * Real.log T
          * ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
              (Cap08Bandits.muStar mu - mu a)⁻¹
        + ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
            (Cap08Bandits.muStar mu - mu a) := by
  rw [pseudoRegret_eq_gap_sum (fun a => Cap08Bandits.le_muStar mu a) play T]
  exact sum_gap_mul_count_le (fun a => count play a T) (fun a => Cap08Bandits.muStar mu - mu a)
    (fun a ha => ucb1_selection_bound mu muhat play a astar hstar ha hconf
      (fun t ht hc => hplay a t ht hc) hvis T)

/-- La misma cota con el término de exploración acotado por el número de brazos:
con recompensas en `[0,1]` cada brecha es `≤ 1`. -/
theorem regret_le_card (mu : A → ℝ) (muhat : A → ℕ → ℝ) (play : ℕ → A)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hconf : ∀ t, 1 ≤ t → Confident muhat mu (fun b => count play b t) t)
    (hplay : ∀ a t, 1 ≤ t → 0 < count play a t →
      IndexMax muhat (fun b => count play b t) t (play t))
    (hvis : ∀ t, 1 ≤ t → 0 < count play (play t) t → ∀ b, 0 < count play b t)
    (h0 : ∀ a, 0 ≤ mu a) (h1 : Cap08Bandits.muStar mu ≤ 1) (T : ℕ) :
    pseudoRegret (Cap08Bandits.muStar mu) mu play T
      ≤ 8 * Real.log T
          * ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
              (Cap08Bandits.muStar mu - mu a)⁻¹
        + (Fintype.card A : ℝ) := by
  have hbase := regret_le_gaps mu muhat play astar hstar hconf hplay hvis T
  have hgaple : ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
        (Cap08Bandits.muStar mu - mu a) ≤ (Fintype.card A : ℝ) := by
    have hterm : ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
          (Cap08Bandits.muStar mu - mu a) ≤ ∑ _a ∈ Finset.univ.filter
            (fun a => 0 < Cap08Bandits.muStar mu - mu a), (1 : ℝ) := by
      refine Finset.sum_le_sum fun a ha => ?_
      have h1' := h0 a
      linarith
    have hcard : ∑ _a ∈ Finset.univ.filter
        (fun a => 0 < Cap08Bandits.muStar mu - mu a), (1 : ℝ)
        = ((Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a)).card : ℝ) := by
      simp
    have hle : ((Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a)).card : ℝ)
        ≤ (Fintype.card A : ℝ) := by
      have h := Finset.card_le_univ
        (Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a))
      exact_mod_cast h
    linarith
  linarith

end CotaFinal

/-! ### 7. La desigualdad impresa en el libro, sobre el evento de confianza -/

section Libro

variable [Nonempty A]

/-- **La desigualdad impresa del bloque, on the good event.** Sobre el evento de
confianza, el pseudorregret satisface exactamente la cota que el libro atribuye a
Auer et al. (2002):
`R_T ≤ 8 log T Σ_{a:Δ_a>0} 1/Δ_a + (1+π²/3) Σ_a Δ_a`.
El término `(1+π²/3)` del libro es más grueso que nuestro término determinista
`Σ_{a:Δ_a>0} Δ_a ≤ Σ_a Δ_a`; el excedente `(π²/3) Σ_a Δ_a` es precisamente la
masa de probabilidad que el libro paga por el lema de la unión, y que aquí no se
usa porque estamos *sobre* el evento de confianza. -/
theorem book_bound_on_good_event (mu : A → ℝ) (muhat : A → ℕ → ℝ) (play : ℕ → A)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hconf : ∀ t, 1 ≤ t → Confident muhat mu (fun b => count play b t) t)
    (hplay : ∀ a t, 1 ≤ t → 0 < count play a t →
      IndexMax muhat (fun b => count play b t) t (play t))
    (hvis : ∀ t, 1 ≤ t → 0 < count play (play t) t → ∀ b, 0 < count play b t)
    (T : ℕ) :
    pseudoRegret (Cap08Bandits.muStar mu) mu play T
      ≤ 8 * Real.log T
          * ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
              (Cap08Bandits.muStar mu - mu a)⁻¹
        + (1 + Real.pi ^ 2 / 3) * ∑ a, (Cap08Bandits.muStar mu - mu a) := by
  have hbase := regret_le_gaps mu muhat play astar hstar hconf hplay hvis T
  have hnn : ∀ a : A, 0 ≤ Cap08Bandits.muStar mu - mu a :=
    fun a => by linarith [Cap08Bandits.le_muStar mu a]
  have hsub : ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
        (Cap08Bandits.muStar mu - mu a) ≤ ∑ a, (Cap08Bandits.muStar mu - mu a) :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun a _ _ => hnn a)
  have hcoef : (1:ℝ) ≤ 1 + Real.pi ^ 2 / 3 := by
    have h4 : (0:ℝ) ≤ Real.pi ^ 2 / 3 := by positivity
    linarith
  have hsum : ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
        (Cap08Bandits.muStar mu - mu a)
      ≤ (1 + Real.pi ^ 2 / 3) * ∑ a, (Cap08Bandits.muStar mu - mu a) := by
    calc ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
          (Cap08Bandits.muStar mu - mu a) ≤ ∑ a, (Cap08Bandits.muStar mu - mu a) := hsub
      _ ≤ (1 + Real.pi ^ 2 / 3) * ∑ a, (Cap08Bandits.muStar mu - mu a) :=
          le_mul_of_one_le_left (Finset.sum_nonneg fun a _ => hnn a) hcoef
  linarith

/-- **Control de la conclusión.** Jugando siempre un brazo óptimo el
pseudorregret es exactamente `0`, que es lo que la cota del libro predice (su
segundo término es `≥ 0`). No es una demostración de UCB1 ni pretende serlo: es
el control de que el enunciado reparado tiene la conclusión correcta en el caso
trivial y de que `Confident` es satisfacible con medias empíricas exactas
(`muhat := mu`). El enunciado anterior (`∀ a, 0 < Δ_a`) ni siquiera era
instanciable en este caso (`not_forall_gap_pos`). -/
theorem witness_satisfiable (mu : A → ℝ) {astar : A}
    (hstar : mu astar = Cap08Bandits.muStar mu) (T : ℕ) :
    pseudoRegret (Cap08Bandits.muStar mu) mu (fun _ => astar) T = 0 := by
  refine Finset.sum_eq_zero fun t _ => ?_
  have hz : Cap08Bandits.muStar mu - mu astar = 0 := by rw [hstar, sub_self]
  simp [hz]

end Libro

/-! ### 8. Auditoría del enunciado anterior: la hipótesis insatisfacible -/

section Auditoria

variable [Nonempty A]

/-- **El defecto de `Cap08Bandits.ucb1_cota_regret`.** Su hipótesis
`∀ a, 0 < Delta a` no puede cumplirse cuando `Delta a = mu* - mu a` con `mu*`
la media máxima: hay un brazo óptimo con `Delta = 0`. Por tanto la cota final de
suma por brazos del módulo anterior es inaplicable al caso del libro, aunque la
implicación sea verdadera. -/
theorem not_forall_gap_pos (mu : A → ℝ) :
    ¬ ∀ a, 0 < Cap08Bandits.muStar mu - mu a := by
  intro h
  obtain ⟨a, ha⟩ := Cap08Bandits.muStar_achieved mu
  have := h a
  rw [ha, sub_self] at this
  exact lt_irrefl 0 this

end Auditoria

/-! ### 9. La frontera probabilística, como interfaz explícita -/

section Frontera

variable [Nonempty A]

open MeasureTheory

variable {Ω : Type*} [MeasurableSpace Ω]

/-- **Interfaz de la frontera.** Si el pseudorregret `R` está acotado por
`T ≥ 0`, no excede `B ≥ 0` sobre un evento medible `G` y la masa de `Gᶜ` es a lo
más `p`, entonces `E[R] ≤ B + T·p`.

Todo el contenido probabilístico que falta para `C.thm:ch8-ucb1` entra por
`hp : μ.real Gᶜ ≤ p`: es el único punto donde se usa concentración. Nótese que
esta interfaz es **más gruesa** que la cota del libro: el término `T·p` no es
`(π²/3) Σ_a Δ_a`, y pasar de uno a otro exige la contabilidad fina por brazo
(la masa de fallo se cuenta por ronda y por brazo, y se suma contra las brechas),
que no está formalizada aquí. -/
theorem expectation_le_of_good_event (μ : Measure Ω) [IsProbabilityMeasure μ]
    (R : Ω → ℝ) {B T p : ℝ} (hT : 0 ≤ T) {G : Set Ω} (hG : MeasurableSet G)
    (hint : Integrable R μ) (hRT : ∀ ω, R ω ≤ T)
    (hgood : ∀ ω ∈ G, R ω ≤ B) (hB : 0 ≤ B) (hp : μ.real Gᶜ ≤ p) :
    ∫ ω, R ω ∂μ ≤ B + T * p := by
  have hsplit : ∫ ω in G, R ω ∂μ + ∫ ω in Gᶜ, R ω ∂μ = ∫ ω, R ω ∂μ :=
    integral_add_compl hG hint
  rw [← hsplit]
  have h1 : ∫ ω in G, R ω ∂μ ≤ ∫ ω in G, B ∂μ :=
    setIntegral_mono_on hint.integrableOn (integrableOn_const (measure_ne_top μ G)) hG hgood
  have h2 : ∫ ω in Gᶜ, R ω ∂μ ≤ ∫ ω in Gᶜ, T ∂μ :=
    setIntegral_mono_on hint.integrableOn (integrableOn_const (measure_ne_top μ Gᶜ))
      hG.compl (fun ω _ => hRT ω)
  have e1 : ∫ ω in G, B ∂μ = B * μ.real G := by
    rw [setIntegral_const, smul_eq_mul, mul_comm]
  have e2 : ∫ ω in Gᶜ, T ∂μ = T * μ.real Gᶜ := by
    rw [setIntegral_const, smul_eq_mul, mul_comm]
  have hmass : μ.real G ≤ 1 := measureReal_le_one
  have s1 : B * μ.real G ≤ B * 1 := mul_le_mul_of_nonneg_left hmass hB
  have s2 : T * μ.real Gᶜ ≤ T * p := mul_le_mul_of_nonneg_left hp hT
  linarith

/-- **Aplicación al bandido.** Si sobre el evento `G` se cumplen el evento de
confianza y la regla de índice en la historia `ω`, y `μ.real Gᶜ ≤ p`, entonces
el pseudorregret esperado excede a la cota impresa del libro a lo más en `T·p`. -/
theorem expected_regret_le_book
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (mu : A → ℝ) (muhat : Ω → A → ℕ → ℝ) (play : Ω → ℕ → A)
    {G : Set Ω} (hG : MeasurableSet G)
    (astar : A) (hstar : mu astar = Cap08Bandits.muStar mu)
    (hconf : ∀ ω ∈ G, ∀ t, 1 ≤ t → Confident (muhat ω) mu (fun b => count (play ω) b t) t)
    (hplay : ∀ ω ∈ G, ∀ a t, 1 ≤ t → 0 < count (play ω) a t →
      IndexMax (muhat ω) (fun b => count (play ω) b t) t (play ω t))
    (hvis : ∀ ω ∈ G, ∀ t, 1 ≤ t → 0 < count (play ω) (play ω t) t →
      ∀ b, 0 < count (play ω) b t)
    (T : ℕ) {p : ℝ}
    (hint : Integrable (fun ω => pseudoRegret (Cap08Bandits.muStar mu) mu (play ω) T) μ)
    (hRT : ∀ ω, pseudoRegret (Cap08Bandits.muStar mu) mu (play ω) T ≤ T)
    (hp : μ.real Gᶜ ≤ p) :
    ∫ ω, pseudoRegret (Cap08Bandits.muStar mu) mu (play ω) T ∂μ
      ≤ (8 * Real.log T
            * ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
                (Cap08Bandits.muStar mu - mu a)⁻¹
          + (1 + Real.pi ^ 2 / 3) * ∑ a, (Cap08Bandits.muStar mu - mu a))
        + T * p := by
  have hB : 0 ≤ 8 * Real.log T
        * ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
            (Cap08Bandits.muStar mu - mu a)⁻¹
      + (1 + Real.pi ^ 2 / 3) * ∑ a, (Cap08Bandits.muStar mu - mu a) := by
    have h1 : 0 ≤ ∑ a ∈ Finset.univ.filter (fun a => 0 < Cap08Bandits.muStar mu - mu a),
        (Cap08Bandits.muStar mu - mu a)⁻¹ :=
      Finset.sum_nonneg fun a _ =>
        inv_nonneg.2 (by linarith [Cap08Bandits.le_muStar mu a])
    have h2 : 0 ≤ ∑ a, (Cap08Bandits.muStar mu - mu a) :=
      Finset.sum_nonneg fun a _ => by linarith [Cap08Bandits.le_muStar mu a]
    have h3 : (0:ℝ) ≤ 1 + Real.pi ^ 2 / 3 := by
      have := Real.pi_pos; positivity
    have h4 : 0 ≤ 8 * Real.log T := by
      by_cases hT0 : T = 0
      · simp [hT0]
      · have hT1 : (1:ℝ) ≤ T := by
          have h1 : 1 ≤ T := Nat.one_le_iff_ne_zero.2 hT0
          exact_mod_cast h1
        have := Real.log_nonneg hT1
        linarith
    nlinarith [mul_nonneg h4 h1, mul_nonneg h3 h2]
  exact expectation_le_of_good_event μ (fun ω => pseudoRegret (Cap08Bandits.muStar mu) mu (play ω) T)
    (Nat.cast_nonneg T) hG hint hRT
    (fun ω hω => book_bound_on_good_event mu (muhat ω) (play ω) astar hstar
      (hconf ω hω) (hplay ω hω) (hvis ω hω) T)
    hB hp

end Frontera

end Cap08Ucb1M7
