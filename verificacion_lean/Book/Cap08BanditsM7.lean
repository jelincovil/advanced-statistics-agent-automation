import Mathlib
import Book.Cap03MDP

/-!
# Book.Cap08Bandits — bandidos multi-brazo (capitulos/cap03_mdp.typ, §Bandidos)

Formaliza el contenido matemático de las claves pendientes del capítulo 8
(`sec:ch8-bandits`, `sec:ch8-bandits-thompson`):

* `prop:ch8-mab-mdp` (línea 141) — con medias conocidas el bandido es un MDP de
  un solo estado: el valor descontado `μ*/(1−γ)` es punto fijo de la ecuación de
  Bellman óptima y ninguna sucesión de brazos lo supera; la política que repite
  un brazo óptimo lo alcanza. Con medias desconocidas el estado de información
  debe incluir el posterior y el horizonte: se exhibe un cálculo exacto con dos
  brazos de media *idéntica* (`1/2`) en el que el horizonte 2 prefiere
  estrictamente explorar (`37/36 > 1`).
* `thm:ch8-ucb1` (línea 145) — el esqueleto determinista de la garantía de
  UCB1: (a) descomposición del pseudorregret por brazos
  `R_T = Σ_a Δ_a N_a(T)`; (b) comparación de índices: si en la ronda `t` UCB1
  juega un brazo con brecha `Δ>0` y las medias empíricas están dentro de sus
  bonus, entonces `Δ² N_a(t−1) ≤ 8 log t`; (c) conteo: `N_a(T) ≤ 8 log T/Δ² + 1`;
  (d) cota final `R_T ≤ 8 Σ log T/Δ_a + Σ Δ_a`.
* `prop:ch8-thompson` (línea 154) — sin empates, la probabilidad de que Thompson
  Sampling seleccione un brazo es su probabilidad posterior de ser óptimo; y su
  recompensa predictiva es la mezcla `Σ_a P(sel=a) m_a ≤ máx_a m_a`, estricta
  si la selección es aleatoria. No minimiza el riesgo posterior de la acción.
* `prop:ch8-mab-mdp-thompson` (línea 178) — con una ronda restante la acción
  bayesiana maximiza la media posterior (y la exploración no aporta nada);
  la media posterior Beta–Bernoulli es una martingala (sube tras éxito, baja
  tras fracaso), que es lo que la recursión de horizonte mayor debe incorporar.

Fidelidad declarada (plan §4):

* `prop:ch8-mab-mdp`: versión de un solo estado y horizonte infinito
  descontado `0 ≤ γ < 1` con acciones finitas no vacías; el libro enuncia la
  representación, aquí se prueba la ecuación de Bellman y la optimalidad del
  brazo greedy. El cálculo de horizonte 2 es exacto con números racionales y
  prior finito declarado (no es una simulación).
* `thm:ch8-ucb1`: se formaliza la parte **determinista** de la demostración
  (comparación de índices y control del número de selecciones), condicionada al
  evento de confianza. La constante `(1+π²/3)` del libro procede de la
  probabilidad de fallo de las cotas de Hoeffding y del lema de la unión; el
  libro mismo remite la demostración completa a Auer et al. (2002) y no la
  desarrolla («Este resultado se usa con atribución bibliográfica»), de modo
  que aquí se declara esa frontera en lugar de simularla. No se formaliza
  ninguna distribución de probabilidad sobre historias infinitas.
* `prop:ch8-thompson`: posterior finito arbitrario (pesos no negativos), regla
  de selección determinista `sel` que maximiza la media muestreada; «sin
  empates» se declara como peso posterior nulo del conjunto de empates.
* `prop:ch8-mab-mdp-thompson`: utilidad igual a la recompensa; la última ronda
  se prueba para un posterior finito arbitrario. La parte Beta–Bernoulli se
  formaliza como identidad algebraica de los parámetros `(α,β)` (no se
  construye la distribución Beta).

Origen: enjambre smw8gy947, miembro m7, dirección d6 (ch8 bandits).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators
open scoped Topology

namespace Cap08Bandits

/-! ### prop:ch8-mab-mdp — medias conocidas: MDP de un estado -/

section UnEstado

variable {A : Type*} [Fintype A] [Nonempty A]

/-- Media del mejor brazo (`μ* = max_a μ_a` del libro). -/
noncomputable def muStar (mu : A → ℝ) : ℝ :=
  (univ : Finset A).sup' Finset.univ_nonempty mu

theorem le_muStar (mu : A → ℝ) (a : A) : mu a ≤ muStar mu :=
  Finset.le_sup' mu (Finset.mem_univ a)

theorem muStar_achieved (mu : A → ℝ) : ∃ a, mu a = muStar mu := by
  obtain ⟨a, _, ha⟩ := Finset.exists_mem_eq_sup' (s := (univ : Finset A))
    Finset.univ_nonempty mu
  exact ⟨a, ha.symm⟩

/-- Pseudorregret instantáneo respecto de la media óptima. -/
noncomputable def gap (mu : A → ℝ) (a : A) : ℝ := muStar mu - mu a

theorem gap_nonneg (mu : A → ℝ) (a : A) : 0 ≤ gap mu a :=
  sub_nonneg.mpr (le_muStar mu a)

/-- Valor descontado de una sucesión de brazos `σ` (el «retorno» del MDP de un
estado que elige `σ t` en la ronda `t`). -/
noncomputable def discValue (mu : A → ℝ) (gamma : ℝ) (sigma : ℕ → A) : ℝ :=
  ∑' t : ℕ, gamma ^ t * mu (sigma t)

/-- Cota de las recompensas: `|μ a| ≤ absSup μ`. -/
noncomputable def absSup (mu : A → ℝ) : ℝ :=
  (univ : Finset A).sup' Finset.univ_nonempty fun a => |mu a|

theorem abs_le_absSup (mu : A → ℝ) (a : A) : |mu a| ≤ absSup mu :=
  Finset.le_sup' (fun a => |mu a|) (Finset.mem_univ a)

theorem absSup_nonneg (mu : A → ℝ) : 0 ≤ absSup mu :=
  le_trans (abs_nonneg _) (abs_le_absSup mu (Classical.arbitrary A))

theorem summable_discValue (mu : A → ℝ) {gamma : ℝ} (h0 : 0 ≤ gamma) (h1 : gamma < 1)
    (sigma : ℕ → A) : Summable (fun t : ℕ => gamma ^ t * mu (sigma t)) := by
  have hgeom : Summable (fun t : ℕ => gamma ^ t * absSup mu) :=
    (summable_geometric_of_lt_one h0 h1).mul_right (absSup mu)
  refine Summable.of_norm_bounded (g := fun t : ℕ => gamma ^ t * absSup mu) hgeom ?_
  intro t
  rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg (pow_nonneg h0 t)]
  exact mul_le_mul_of_nonneg_left (abs_le_absSup mu (sigma t)) (pow_nonneg h0 t)

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) —
ninguna sucesión de brazos supera el valor de repetir un brazo óptimo:
`Σ_t γ^t μ(σ t) ≤ μ*/(1−γ)`. Es la optimalidad del MDP de un estado con medias
conocidas. -/
theorem discValue_le (mu : A → ℝ) {gamma : ℝ} (h0 : 0 ≤ gamma) (h1 : gamma < 1)
    (sigma : ℕ → A) : discValue mu gamma sigma ≤ muStar mu / (1 - gamma) := by
  have hsum : Summable (fun t : ℕ => gamma ^ t * muStar mu) :=
    (summable_geometric_of_lt_one h0 h1).mul_right _
  have hle : discValue mu gamma sigma ≤ ∑' t : ℕ, gamma ^ t * muStar mu := by
    refine Summable.tsum_le_tsum (fun t => ?_) (summable_discValue mu h0 h1 sigma) hsum
    exact mul_le_mul_of_nonneg_left (le_muStar mu (sigma t)) (pow_nonneg h0 t)
  have heq : ∑' t : ℕ, gamma ^ t * muStar mu = muStar mu * (1 - gamma)⁻¹ := by
    rw [(summable_geometric_of_lt_one h0 h1).tsum_mul_right,
      tsum_geometric_of_lt_one h0 h1, mul_comm]
  rw [div_eq_mul_inv]
  rw [heq] at hle
  exact hle

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) —
la política que repite un brazo óptimo alcanza el valor `μ*/(1−γ)`: la cota de
`discValue_le` es exacta, así que el bandido con medias conocidas se resuelve
eligiendo repetidamente un brazo de media máxima. -/
theorem discValue_optimal (mu : A → ℝ) {gamma : ℝ} (h0 : 0 ≤ gamma) (h1 : gamma < 1)
    (a : A) (ha : mu a = muStar mu) :
    discValue mu gamma (fun _ => a) = muStar mu / (1 - gamma) := by
  have heq : ∑' t : ℕ, gamma ^ t * muStar mu = muStar mu * (1 - gamma)⁻¹ := by
    rw [(summable_geometric_of_lt_one h0 h1).tsum_mul_right,
      tsum_geometric_of_lt_one h0 h1, mul_comm]
  rw [discValue, div_eq_mul_inv, ha]
  exact heq

/-- Operador de Bellman óptimo del MDP de un estado (semilla escalar). -/
noncomputable def bellmanUn (mu : A → ℝ) (gamma W : ℝ) : ℝ :=
  (univ : Finset A).sup' (Finset.univ_nonempty (α := A))
    (fun a : A => mu a + gamma * W)

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) —
ecuación de Bellman del MDP de un solo estado: `W = μ*/(1−γ)` satisface
`W = max_a (μ_a + γ W)`, es decir, el bandido con medias conocidas admite la
representación de un estado que elige un brazo óptimo. -/
theorem bellman_un_estado (mu : A → ℝ) {gamma : ℝ} (h1 : gamma < 1) :
    muStar mu / (1 - gamma) = bellmanUn mu gamma (muStar mu / (1 - gamma)) := by
  set W := muStar mu / (1 - gamma) with hW
  have hkey : muStar mu + gamma * W = W := by
    rw [hW]
    field_simp
    ring
  refine le_antisymm ?_ ?_
  · obtain ⟨a, ha⟩ := muStar_achieved mu
    have h0 : mu a + gamma * W ≤ bellmanUn mu gamma W :=
      Finset.le_sup' (fun b => mu b + gamma * W) (Finset.mem_univ a)
    rw [ha] at h0
    linarith [hkey]
  · refine (Finset.sup'_le_iff (Finset.univ_nonempty (α := A)) _).mpr ?_
    intro a _
    calc mu a + gamma * W ≤ muStar mu + gamma * W := by
          have := le_muStar mu a
          linarith
      _ = W := hkey

end UnEstado

/-! ### prop:ch8-mab-mdp — el cálculo de horizonte 2 (valor de explorar) -/

/-!
El estado de información debe incluir el posterior y las rondas restantes: con
dos brazos de media prioria **idéntica** `1/2` (brazo 1 con `p = 1/2` conocida;
brazo 2 con prior `{1/3, 2/3}` equiprobable), el horizonte 2 obtiene `37/36`
explorando el brazo incierto y solo `1` repitiendo el brazo conocido. Todas las
cifras son racionales exactas: peso posterior `2/3` tras un éxito, `1/3` tras un
fracaso; medias posteriores `5/9` y `4/9`; valor de la segunda ronda
`max(1/2, ·)` promediado con la probabilidad predictiva `1/2`.
-/

section Horizonte2

theorem prior_media_brazo_incierto : (1/2 : ℝ) * (1/3) + (1/2) * (2/3) = 1/2 := by
  norm_num

theorem predictivo_exito : (1/2 : ℝ) * (2/3) + (1/2) * (1/3) = 1/2 := by norm_num

theorem posterior_peso_exito : ((2/3 : ℝ) * (1/2)) / (1/2) = 2/3 := by norm_num

theorem posterior_peso_fracaso : ((1/3 : ℝ) * (1/2)) / (1/2) = 1/3 := by norm_num

theorem posterior_media_exito : (2/3 : ℝ) * (2/3) + (1/3) * (1/3) = 5/9 := by norm_num

theorem posterior_media_fracaso : (1/3 : ℝ) * (2/3) + (2/3) * (1/3) = 4/9 := by norm_num

/-- Segunda ronda tras explorar el brazo incierto: `E[max(1/2, media posterior)]`. -/
theorem valor_segunda_ronda_explorando : (1/2 : ℝ) * (5/9) + (1/2) * (1/2) = 19/36 := by
  norm_num

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) —
con medias priorias iguales (`1/2`) el horizonte 2 prefiere estrictamente
explorar el brazo incierto: `1/2 + 19/36 = 37/36 > 1`. Una única ronda no
contiene el beneficio futuro de explorar; el estado físico (constante) no basta
como estado de información. -/
theorem explorar_estrictamente_mejor :
    (1/2 : ℝ) + ((1/2) * (5/9) + (1/2) * (1/2)) = 37/36 ∧ (1:ℝ) < 37/36 := by
  constructor
  · norm_num
  · norm_num

end Horizonte2
/-! ### prop:ch8-thompson — selección y recompensa predictiva de Thompson Sampling -/

section Thompson

variable {Theta : Type*} [Fintype Theta]

/-- Peso posterior de un suceso: `P(Θ ∈ P) = Σ_{θ ∈ P} w θ`. -/
noncomputable def postProb (w : Theta → ℝ) (P : Theta → Prop) : ℝ := by
  classical exact ((univ : Finset Theta).filter P).sum w

/-- `a` es un brazo óptimo en el mundo `θ`. -/
def IsOptimal {A : Type*} (mu : Theta → A → ℝ) (θ : Theta) (a : A) : Prop :=
  ∀ b, mu θ b ≤ mu θ a

/-- Mundos donde la selección no es el único brazo óptimo (empates). -/
def TieSet {A : Type*} (mu : Theta → A → ℝ) (sel : Theta → A) : Theta → Prop :=
  fun θ => ∃ b, b ≠ sel θ ∧ mu θ (sel θ) = mu θ b

/-- book: capitulos/cap03_mdp.typ:154 (key: prop:ch8-thompson) —
sin empates, la probabilidad de que Thompson Sampling seleccione el brazo `a`
coincide con la probabilidad posterior de que `a` sea óptimo. La selección
`sel` es la regla determinista que aplica el muestreo (`a = argmax` de la
muestra); el posterior es un peso finito arbitrario `w ≥ 0`. -/
theorem thompson_prob_seleccion {A : Type*} [Fintype A] (w : Theta → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (mu : Theta → A → ℝ) (sel : Theta → A)
    (hsel : ∀ θ b, mu θ b ≤ mu θ (sel θ))
    (htie : postProb w (TieSet mu sel) = 0) (a : A) :
    postProb w (fun θ => sel θ = a) = postProb w (IsOptimal mu · a) := by
  classical
  have hsub : ∀ θ, sel θ = a → IsOptimal mu θ a := by
    intro θ hθ b
    rw [← hθ]
    exact hsel θ b
  have hsplit := Finset.sum_filter_add_sum_filter_not
    (s := univ.filter (fun θ => IsOptimal mu θ a))
    (p := fun θ => sel θ = a) (f := w)
  rw [Finset.filter_filter, Finset.filter_filter] at hsplit
  have hleft : (univ.filter (fun θ => IsOptimal mu θ a ∧ sel θ = a))
      = univ.filter (fun θ => sel θ = a) := by
    apply Finset.filter_congr
    intro θ _
    exact ⟨fun h => h.2, fun h => ⟨hsub θ h, h⟩⟩
  have hright : (((univ : Finset Theta).filter
      (fun θ => IsOptimal mu θ a ∧ ¬ sel θ = a))).sum w = 0 := by
    refine Finset.sum_eq_zero fun θ hθ => ?_
    have hopt : IsOptimal mu θ a := (Finset.mem_filter.mp hθ).2.1
    have hne : ¬ sel θ = a := (Finset.mem_filter.mp hθ).2.2
    have htieθ : TieSet mu sel θ := by
      refine ⟨a, fun h => hne h.symm, ?_⟩
      exact le_antisymm (hopt (sel θ)) (hsel θ a)
    have hmem : θ ∈ (univ : Finset Theta).filter (TieSet mu sel) :=
      Finset.mem_filter.mpr ⟨Finset.mem_univ θ, htieθ⟩
    have hzero := (Finset.sum_eq_zero_iff_of_nonneg (fun θ _ => hw θ)).mp htie
    exact hzero θ hmem
  simp only [postProb]
  rw [hleft] at hsplit
  rw [hright, add_zero] at hsplit
  simpa using hsplit

/-- Media posterior del brazo `a`. -/
noncomputable def postMean {A : Type*} (w : Theta → ℝ) (mu : Theta → A → ℝ) (a : A) : ℝ :=
  ∑ θ, w θ * mu θ a

/-- Recompensa predictiva de Thompson Sampling: la mezcla de las medias
posteriores con las probabilidades de selección, `Σ_a P(sel = a) m_a`. -/
noncomputable def thompsonPayoff {A : Type*} [Fintype A] (w : Theta → ℝ)
    (mu : Theta → A → ℝ) (sel : Theta → A) : ℝ :=
  ∑ a, postProb w (fun θ => sel θ = a) * postMean w mu a

theorem postProb_nonneg {P : Theta → Prop} {w : Theta → ℝ} (hw : ∀ θ, 0 ≤ w θ) :
    0 ≤ postProb w P := by
  classical
  exact Finset.sum_nonneg fun θ _ => hw θ

/-- Las probabilidades de selección suman uno: `Σ_a P(sel = a) = Σ_θ w θ`. -/
theorem sum_postProb_sel {A : Type*} [Fintype A] (w : Theta → ℝ) (sel : Theta → A)
    (hw1 : ∑ θ, w θ = 1) :
    ∑ a, postProb w (fun θ => sel θ = a) = 1 := by
  classical
  have hstep : ∀ θ : Theta, (∑ a, if sel θ = a then w θ else 0) = w θ := by
    intro θ
    rw [Finset.sum_eq_single (sel θ)]
    · simp
    · intro b _ hb
      simp [show ¬ (sel θ = b) from fun h => hb h.symm]
    · intro h
      exact absurd (Finset.mem_univ (sel θ)) h
  simp only [postProb, Finset.sum_filter]
  calc ∑ a, ∑ θ, (if sel θ = a then w θ else 0)
      = ∑ θ, ∑ a, (if sel θ = a then w θ else 0) := Finset.sum_comm
    _ = ∑ θ, w θ := Finset.sum_congr rfl fun θ _ => hstep θ
    _ = 1 := hw1

/-- book: capitulos/cap03_mdp.typ:154 (key: prop:ch8-thompson) —
la recompensa predictiva de Thompson Sampling nunca supera la del brazo de
mayor media posterior: muestrear del posterior y actuar sobre la muestra no
minimiza el riesgo posterior de la acción actual. -/
theorem thompson_payoff_le {A : Type*} [Fintype A] [Nonempty A] (w : Theta → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1) (mu : Theta → A → ℝ) (sel : Theta → A)
    (astar : A) (hmax : ∀ a, postMean w mu a ≤ postMean w mu astar) :
    thompsonPayoff w mu sel ≤ postMean w mu astar := by
  classical
  set M := postMean w mu astar with hM
  have h1 : thompsonPayoff w mu sel ≤
      ∑ a, postProb w (fun θ => sel θ = a) * M := by
    refine Finset.sum_le_sum fun a _ => ?_
    exact mul_le_mul_of_nonneg_left (hmax a) (postProb_nonneg hw)
  have h2 : ∑ a, postProb w (fun θ => sel θ = a) * M = M := by
    rw [← Finset.sum_mul, sum_postProb_sel w sel hw1, one_mul]
  linarith [h1, h2]

/-- book: capitulos/cap03_mdp.typ:154 (key: prop:ch8-thompson) — la desigualdad
es estricta si la selección es aleatoria con probabilidad positiva sobre un
brazo de media posterior menor: ahí Thompson Sampling pierde frente a la acción
bayesiana de una ronda. -/
theorem thompson_payoff_lt {A : Type*} [Fintype A] [Nonempty A] (w : Theta → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1) (mu : Theta → A → ℝ) (sel : Theta → A)
    (astar a₀ : A)
    (hmax : ∀ a, postMean w mu a ≤ postMean w mu astar)
    (hpos : 0 < postProb w (fun θ => sel θ = a₀))
    (hlt : postMean w mu a₀ < postMean w mu astar) :
    thompsonPayoff w mu sel < postMean w mu astar := by
  classical
  set M := postMean w mu astar with hM
  have hlt' : ∑ a, postProb w (fun θ => sel θ = a) * postMean w mu a
      < ∑ a, postProb w (fun θ => sel θ = a) * M := by
    refine Finset.sum_lt_sum (fun a _ => ?_) ⟨a₀, Finset.mem_univ a₀, ?_⟩
    · exact mul_le_mul_of_nonneg_left (hmax a) (postProb_nonneg hw)
    · exact mul_lt_mul_of_pos_left hlt hpos
  have h2 : ∑ a, postProb w (fun θ => sel θ = a) * M = M := by
    rw [← Finset.sum_mul, sum_postProb_sel w sel hw1, one_mul]
  show thompsonPayoff w mu sel < M
  exact hlt'.trans_le h2.le

end Thompson
/-! ### prop:ch8-mab-mdp-thompson — última ronda y actualización Beta–Bernoulli -/

section UltimaRonda

variable {A : Type*} [Fintype A] [Nonempty A]

/-- Valor de una ronda restante: `V₁(ν) = max_a m_a(ν)`, la mayor media
posterior. No interviene ninguna actualización porque no hay futuro. -/
noncomputable def valorUnaRonda {Theta : Type*} [Fintype Theta]
    (w : Theta → ℝ) (mu : Theta → A → ℝ) : ℝ :=
  (univ : Finset A).sup' (Finset.univ_nonempty (α := A))
    (fun a : A => postMean w mu a)

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) —
con una ronda restante y utilidad igual a la recompensa, la acción bayesiana
maximiza la media posterior: el valor es `max_a m_a` y cualquier maximizador lo
alcanza. La exploración no aporta recompensa futura dentro de ese horizonte. -/
theorem ultima_ronda {Theta : Type*} [Fintype Theta] (w : Theta → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (mu : Theta → A → ℝ) (astar : A)
    (hmax : ∀ a, postMean w mu a ≤ postMean w mu astar) :
    (∀ a, postMean w mu a ≤ valorUnaRonda w mu) ∧
      valorUnaRonda w mu = postMean w mu astar := by
  constructor
  · intro a
    exact Finset.le_sup' (fun a : A => postMean w mu a) (Finset.mem_univ a)
  · refine le_antisymm ?_ ?_
    · refine (Finset.sup'_le_iff (Finset.univ_nonempty (α := A)) _).mpr ?_
      intro a _
      exact hmax a
    · exact Finset.le_sup' (fun a : A => postMean w mu a) (Finset.mem_univ astar)

/-- Media predictiva de una Beta(`α`,`β`): `α/(α+β)` (`def:ch8-mab-thompson`). -/
noncomputable def betaMedia (al be : ℝ) : ℝ := al / (al + be)

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) — un
éxito sube la media predictiva: `α/(α+β) < (α+1)/(α+β+1)`. Junto con
`betaMedia_fracaso`, la actualización del posterior cambia la media predictiva,
y por eso la recursión de horizonte mayor debe incorporarla. -/
theorem betaMedia_exito {al be : ℝ} (hal : 0 < al) (hbe : 0 < be) :
    betaMedia al be < betaMedia (al + 1) be := by
  have hkey : betaMedia (al + 1) be - betaMedia al be
      = be / ((al + be + 1) * (al + be)) := by
    rw [betaMedia, betaMedia]
    field_simp
    ring
  have hpos : 0 < be / ((al + be + 1) * (al + be)) := by positivity
  linarith

/-- Un fracaso baja la media predictiva: `α/(α+β+1) < α/(α+β)`. -/
theorem betaMedia_fracaso {al be : ℝ} (hal : 0 < al) (hbe : 0 < be) :
    betaMedia al (be + 1) < betaMedia al be := by
  have hkey : betaMedia al be - betaMedia al (be + 1)
      = al / ((al + be + 1) * (al + be)) := by
    rw [betaMedia, betaMedia]
    field_simp
    ring
  have hpos : 0 < al / ((al + be + 1) * (al + be)) := by positivity
  linarith

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) — la
media predictiva Beta–Bernoulli es una martingala: ponderada por la
probabilidad predictiva de éxito y de fracaso, la media posterior esperada es
la media actual. Esa identidad es el término que la recursión de horizonte
mayor debe arrastrar. -/
theorem betaMedia_martingala {al be : ℝ} (hal : 0 < al) (hbe : 0 < be) :
    betaMedia al be * betaMedia (al + 1) be
      + (1 - betaMedia al be) * betaMedia al (be + 1) = betaMedia al be := by
  have hkey : betaMedia al be * betaMedia (al + 1) be
      + (1 - betaMedia al be) * betaMedia al (be + 1) - betaMedia al be = 0 := by
    rw [betaMedia, betaMedia, betaMedia]
    field_simp
    ring
  linarith

end UltimaRonda

/-! ### thm:ch8-ucb1 — esqueleto determinista de la garantía de UCB1 -/

section UCB

variable {A : Type*} [Fintype A]

/-- Bonus de UCB1: `√(2 log t / n)`. -/
noncomputable def ucbBonus (t n : ℕ) : ℝ := Real.sqrt (2 * Real.log t / n)

/-- Índice de UCB1: media empírica más el bonus. -/
noncomputable def ucbIndex (muhat : ℝ) (t n : ℕ) : ℝ := muhat + ucbBonus t n

/-- book: capitulos/cap03_mdp.typ:145 (key: thm:ch8-ucb1) —
comparación de índices: si en la ronda `t` UCB1 juega el brazo `a` (índice
mayor o igual que el del mejor brazo) y ambas medias empíricas están dentro de
sus bonus, entonces `Δ_a² N_a ≤ 8 log t`. Es el paso que convierte optimismo en
una cota del número de selecciones. -/
theorem ucb_comparacion_indices {t n ns : ℕ} {ma ms mha mhs D : ℝ}
    (ht : 1 ≤ t) (hn : 0 < n) (hD : D = ms - ma) (hDpos : 0 < D)
    (hca : |mha - ma| ≤ ucbBonus t n) (hcs : |mhs - ms| ≤ ucbBonus t ns)
    (hplay : ucbIndex mhs t ns ≤ ucbIndex mha t n) :
    D ^ 2 * n ≤ 8 * Real.log t := by
  have hlog : 0 ≤ Real.log t := Real.log_nonneg (by exact_mod_cast ht)
  have hbn : 0 ≤ ucbBonus t n := Real.sqrt_nonneg _
  have ha1 : mha - ucbBonus t n ≤ ma := by linarith [(abs_le.mp hca).2]
  have hs1 : ms ≤ mhs + ucbBonus t ns := by linarith [(abs_le.mp hcs).1]
  have hp : mhs + ucbBonus t ns ≤ mha + ucbBonus t n := by
    simpa [ucbIndex] using hplay
  have hkey : ms - ma ≤ 2 * ucbBonus t n := by linarith
  have hsq : (ms - ma) ^ 2 ≤ (2 * ucbBonus t n) ^ 2 :=
    pow_le_pow_left₀ (by linarith) hkey 2
  have hval : (2 * ucbBonus t n) ^ 2 = 8 * Real.log t / n := by
    rw [mul_pow, ucbBonus, Real.sq_sqrt (by positivity)]
    field_simp
    ring
  have h2 : (ms - ma) ^ 2 ≤ 8 * Real.log t / n := by rw [← hval]; exact hsq
  have h3 : (ms - ma) ^ 2 * n ≤ (8 * Real.log t / n) * n :=
    mul_le_mul_of_nonneg_right h2 (by positivity)
  rw [hD]
  calc (ms - ma) ^ 2 * n ≤ (8 * Real.log t / n) * n := h3
    _ = 8 * Real.log t := by field_simp

/-- book: capitulos/cap03_mdp.typ:145 (key: thm:ch8-ucb1) — conteo: si cada
vez que el brazo subóptimo crece su cuenta vale `Δ² N ≤ 8 log t` (con la cuenta
antes de la ronda), entonces `Δ² N_a(T) ≤ 8 log T + Δ²`, es decir
`N_a(T) ≤ 8 log T/Δ² + 1`. Cubre la condición del libro `T ≥ K`: el `+1` es la
primera visita del brazo. -/
theorem ucb_conteo (N : ℕ → ℕ) (D : ℝ) (hD : 0 < D)
    (h0 : N 0 = 0) (hmono : ∀ t, N t ≤ N (t + 1))
    (hstep : ∀ t, N (t + 1) ≤ N t + 1)
    (hkey : ∀ t, 1 ≤ t → N t < N (t + 1) → D ^ 2 * (N t : ℝ) ≤ 8 * Real.log t)
    (T : ℕ) : D ^ 2 * (N T : ℝ) ≤ 8 * Real.log T + D ^ 2 := by
  induction T with
  | zero => simp only [h0, Nat.cast_zero, mul_zero, Real.log_zero]
            positivity
  | succ t ih =>
      have hD2 : (0 : ℝ) ≤ D ^ 2 := by positivity
      rcases Nat.eq_zero_or_pos t with ht0 | ht
      · subst ht0
        have h1 : N 1 ≤ 1 := by
          have := hstep 0
          rw [h0] at this
          simpa using this
        have h2 : (N 1 : ℝ) ≤ 1 := by exact_mod_cast h1
        have h3 : D ^ 2 * (N 1 : ℝ) ≤ D ^ 2 * 1 := mul_le_mul_of_nonneg_left h2 hD2
        simpa using h3
      · have htpos : (0 : ℝ) < t := by exact_mod_cast ht
        have hlog : Real.log (t : ℝ) ≤ Real.log ((t + 1 : ℕ) : ℝ) := by
          refine Real.log_le_log htpos ?_
          push_cast
          linarith
        rcases eq_or_lt_of_le (hmono t) with hsame | hlt
        · rw [← hsame]
          linarith
        · have hjump : N (t + 1) = N t + 1 := by
            have hs := hstep t
            omega
          have hk := hkey t ht hlt
          rw [hjump]
          push_cast
          have hexp : D ^ 2 * (N t : ℝ) + D ^ 2
              = D ^ 2 * ((N t : ℝ) + 1) := by ring
          have hlog' : Real.log (t : ℝ) ≤ Real.log ((t : ℝ) + 1) := by
            push_cast at hlog
            exact hlog
          linarith

/-- book: capitulos/cap03_mdp.typ:145 (key: thm:ch8-ucb1) — suma de las cotas
por brazo: con `N_a ≤ 8 log T/Δ_a² + 1` para cada brazo con `Δ_a>0`, el
pseudorregret `Σ_a Δ_a N_a` queda acotado por `8 log T · Σ_a 1/Δ_a + Σ_a Δ_a`.
Es la forma `8 Σ_{a:Δ_a>0} (log T)/Δ_a` del libro, sin el término de
probabilidad `(1+π²/3)ΣΔ` (véase la fidelidad declarada). -/
theorem ucb1_cota_regret {T : ℕ} (N : A → ℕ) (Delta : A → ℝ)
    (hD : ∀ a, 0 < Delta a)
    (hN : ∀ a, (N a : ℝ) ≤ 8 * Real.log T / (Delta a) ^ 2 + 1) :
    ∑ a, Delta a * (N a : ℝ)
      ≤ 8 * Real.log T * ∑ a, (Delta a)⁻¹ + ∑ a, Delta a := by
  have hterm : ∀ a : A, Delta a * (N a : ℝ)
      ≤ 8 * Real.log T * (Delta a)⁻¹ + Delta a := by
    intro a
    have hpos : 0 < Delta a := hD a
    have hne : Delta a ≠ 0 := ne_of_gt hpos
    have heq : Delta a * (8 * Real.log T / (Delta a) ^ 2 + 1)
        = 8 * Real.log T * (Delta a)⁻¹ + Delta a := by
      field_simp
      try ring
    calc Delta a * (N a : ℝ)
        ≤ Delta a * (8 * Real.log T / (Delta a) ^ 2 + 1) :=
          mul_le_mul_of_nonneg_left (hN a) (le_of_lt hpos)
      _ = 8 * Real.log T * (Delta a)⁻¹ + Delta a := heq
  calc ∑ a, Delta a * (N a : ℝ)
      ≤ ∑ a, (8 * Real.log T * (Delta a)⁻¹ + Delta a) := Finset.sum_le_sum fun a _ => hterm a
    _ = 8 * Real.log T * ∑ a, (Delta a)⁻¹ + ∑ a, Delta a := by
        simp only [Finset.sum_add_distrib, Finset.mul_sum]

end UCB
/-! ### Ejemplos numéricos exactos (`ex:ssch-bandits-cap08`, `ex:ch8-bandit-ssch`) -/

section Ejemplos

/-- book: capitulos/cap03_mdp.typ:166 (key: ex:ssch-bandits-cap08) —
cuatro opciones con probabilidades de éxito `(0.3, 0.5, 0.6, 0.8)`: la suma de
las brechas contra la mejor (`0.5+0.3+0.2+0`) vale `1`, la media de una
selección uniforme es `0.55` y su pseudorregret esperado en 20 rondas es
`20·(0.8−0.55) = 5`, mientras que el oráculo tiene pseudorregret cero. -/
theorem ssch_bandits_cap08 :
    ((4/5 : ℝ) - 3/10) + (4/5 - 1/2) + (4/5 - 3/5) + (4/5 - 4/5) = 1 ∧
      (3/10 + 1/2 + 3/5 + 4/5) / 4 = 11/20 ∧
      20 * ((4/5 : ℝ) - (3/10 + 1/2 + 3/5 + 4/5) / 4) = 5 ∧
      (11/20 : ℝ) = 0.55 ∧ (4/5 : ℝ) = 0.8 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num

/-- book: capitulos/cap03_mdp.typ:166 (key: ex:ssch-bandits-cap08) — probar una
vez cada opción cuesta en expectativa `0.5+0.3+0.2+0 = 1` de pseudorregret: el
coste de la exploración inicial es exactamente la suma de las brechas. -/
theorem ssch_bandits_cap08_exploracion :
    ((4/5 : ℝ) - 3/10) + (4/5 - 1/2) + (4/5 - 3/5) + (4/5 - 4/5) = 1 := by
  norm_num

/-- book: capitulos/cap03_mdp.typ:181 (key: ex:ch8-bandit-ssch) — con
posteriores `Beta(4,1)` (media `4/5`) y `Beta(1,1)` (media `1/2`), la decisión
bayesiana de última ronda elige la primera y obtiene `4/5`; Thompson Sampling
elige la primera con probabilidad `4/5` y su recompensa predictiva es
`(4/5)(4/5) + (1/5)(1/2) = 37/50`. -/
theorem bandit_ssch_numeros :
    ((4/5 : ℝ) * (4/5) + (1/5) * (1/2) = 37/50) ∧
      ((4/5 : ℝ) - 37/50 = 3/50) ∧ ((4/5 : ℝ) > 37/50) := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num

/-- book: capitulos/cap03_mdp.typ:181 (key: ex:ch8-bandit-ssch) — la diferencia
`3/50 = 0.06` entre la decisión de Bayes (`0.8`) y la recompensa predictiva de
Thompson Sampling (`0.74`): muestrear del posterior y actuar según la muestra
no equivale a minimizar el riesgo posterior. -/
theorem bandit_ssch_diferencia :
    ((4/5 : ℝ) - (37/50) = 3/50) ∧ ((37/50 : ℝ) = 0.74) ∧ ((4/5 : ℝ) = 0.8) := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

end Ejemplos
