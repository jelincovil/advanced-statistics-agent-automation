import Mathlib

/-!
# Book.Cap08Bandits — cap. 3 del libro (capitulos/cap03_mdp.typ): bandidos (cap. 8 del libro)

Pendientes cubiertos aquí (dirección d7 del enjambre smw8gy947):

* `prop:ch8-mab-mdp` — estado físico y estado de información: con medias
  conocidas el bandido es un MDP de un solo estado; el retorno óptimo es
  `(∑_{t<T} γ^t)·μ*` y depende estrictamente del horizonte `T` (una sola
  ronda no contiene el beneficio futuro de explorar).
* `prop:ch8-mab-mdp-thompson` — última ronda: con una ronda restante y
  utilidad igual a la recompensa, la acción bayesiana maximiza la media
  posterior; con más rondas la recursión incorpora la actualización del
  posterior y el horizonte (y nunca vale menos).
* `prop:ch8-thompson` — Thompson Sampling: sin empates, la probabilidad de
  seleccionar un brazo es su probabilidad posterior de ser óptimo.
* `ex:ssch-bandits-cap08` — comparación calculable de exploración con
  probabilidades `(0.3, 0.5, 0.6, 0.8)`: media de selección uniforme `0.55`,
  pseudorregret esperado `5` en 20 rondas, coste de probar cada brazo una
  vez `1`.

Fidelidad declarada: los enunciados del libro son proposicionales; se
formaliza su contenido matemático exacto con los supuestos declarados en
cada docstring. `μ` es la media (posterior, cuando corresponde) del brazo;
`γ` el descuento; las esperanzas son integrales respecto de la ley posterior.
-/

open Finset BigOperators MeasureTheory

namespace Book.Ch8Bandits

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

/-! ## prop:ch8-mab-mdp — un bandido con medias conocidas es un MDP de un estado -/

/-- Retorno descontado de un plan determinista `plan` en un bandido de un
estado físico único con medias `μ` conocidas: `∑_{t<T} γ^t μ(plan t)`. -/
noncomputable def planReturn {A : Type*} (γ : ℝ) (μ : A → ℝ) (T : ℕ)
    (plan : Fin T → A) : ℝ :=
  ∑ t : Fin T, γ ^ (t : ℕ) * μ (plan t)

/-- Media del mejor brazo, `μ*`. -/
noncomputable def bestMean {A : Type*} [Fintype A] [Nonempty A] (μ : A → ℝ) : ℝ :=
  (univ : Finset A).sup' univ_nonempty μ

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) — con medias
conocidas el bandido se representa como un MDP de un solo estado que elige
repetidamente un brazo óptimo: existe un plan que maximiza el retorno
descontado de horizonte `T`, y es el plan constante que repite un brazo de
media máxima. Fidelidad: horizonte finito `T`, plan determinista; el MDP
tiene un estado y transición trivial, de modo que sólo la recompensa media
importa. -/
theorem prop_ch8_mab_mdp {A : Type*} [Fintype A] [Nonempty A]
    (μ : A → ℝ) (γ : ℝ) (hγ : 0 ≤ γ) (T : ℕ) :
    ∃ plan : Fin T → A, ∀ plan' : Fin T → A,
      planReturn γ μ T plan' ≤ planReturn γ μ T plan := by
  obtain ⟨a₀, -, ha₀⟩ :=
    Finset.exists_max_image (univ : Finset A) μ Finset.univ_nonempty
  refine ⟨fun _ => a₀, fun plan' => ?_⟩
  refine Finset.sum_le_sum fun t _ => ?_
  exact mul_le_mul_of_nonneg_left (ha₀ _ (mem_univ _)) (pow_nonneg hγ _)

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) — valor del
plan óptimo: todo plan de horizonte `T` está acotado por `(∑_{t<T} γ^t)·μ*`
y la cota se alcanza. Fidelidad: horizonte finito; la constante es la suma
geométrica truncada, que depende de `T`. -/
theorem prop_ch8_mab_mdp_valor {A : Type*} [Fintype A] [Nonempty A]
    (μ : A → ℝ) (γ : ℝ) (hγ : 0 ≤ γ) (T : ℕ) :
    (∀ plan : Fin T → A,
      planReturn γ μ T plan ≤ (∑ t : Fin T, γ ^ (t : ℕ)) * bestMean μ) ∧
    (∃ plan : Fin T → A,
      planReturn γ μ T plan = (∑ t : Fin T, γ ^ (t : ℕ)) * bestMean μ) := by
  obtain ⟨a₀, -, ha₀⟩ :=
    Finset.exists_max_image (univ : Finset A) μ Finset.univ_nonempty
  have hbest : bestMean μ = μ a₀ := by
    refine le_antisymm ?_ (Finset.le_sup' μ (mem_univ a₀))
    exact Finset.sup'_le _ _ fun b _ => ha₀ b (mem_univ b)
  constructor
  · intro plan
    rw [hbest]
    calc planReturn γ μ T plan
        = ∑ t : Fin T, γ ^ (t : ℕ) * μ (plan t) := rfl
      _ ≤ ∑ t : Fin T, γ ^ (t : ℕ) * μ a₀ :=
          Finset.sum_le_sum fun t _ =>
            mul_le_mul_of_nonneg_left (ha₀ _ (mem_univ _)) (pow_nonneg hγ _)
      _ = (∑ t : Fin T, γ ^ (t : ℕ)) * μ a₀ := by rw [Finset.sum_mul]
  · refine ⟨fun _ => a₀, ?_⟩
    rw [hbest]
    exact (Finset.sum_mul (Finset.univ) (fun t : Fin T => γ ^ (t : ℕ)) (μ a₀)).symm

/-- Retorno óptimo de horizonte `T` calculado con el plan greedy. -/
noncomputable def optimalReturn {A : Type*} [Fintype A] [Nonempty A]
    (μ : A → ℝ) (γ : ℝ) (T : ℕ) : ℝ :=
  (∑ t : Fin T, γ ^ (t : ℕ)) * bestMean μ

/-- Suma geométrica truncada: paso de `T` a `T+1` (base para la monotonía
en el horizonte). -/
private theorem geom_succ (γ : ℝ) (T : ℕ) :
    (∑ t : Fin (T + 1), γ ^ (t : ℕ)) = (∑ t : Fin T, γ ^ (t : ℕ)) + γ ^ T := by
  rw [Fin.sum_univ_castSucc]
  simp

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) — el horizonte
entra en el valor: con `μ* > 0` y `γ > 0`, el retorno óptimo es estrictamente
creciente en `T`. Por tanto una única ronda no contiene el beneficio futuro
de explorar: el problema de un paso (que sólo mira `μ*`) no es el problema
de varios pasos. -/
theorem prop_ch8_mab_mdp_horizonte {A : Type*} [Fintype A] [Nonempty A]
    (μ : A → ℝ) (γ : ℝ) (hγ : 0 < γ) (hμ : 0 < bestMean μ) :
    StrictMono (optimalReturn μ γ) := by
  refine strictMono_nat_of_lt_succ fun T => ?_
  have hstep : optimalReturn μ γ (T + 1)
      = optimalReturn μ γ T + γ ^ T * bestMean μ := by
    simp only [optimalReturn, geom_succ γ T, add_mul]
  rw [hstep]
  have hpos : 0 < γ ^ T * bestMean μ :=
    mul_pos (pow_pos hγ T) hμ
  linarith

/-- book: capitulos/cap03_mdp.typ:141 (key: prop:ch8-mab-mdp) — caso de una
ronda: el retorno de cualquier plan es la media del brazo elegido, y el
óptimo es `μ*`. Es el sentido preciso de «una única ronda no contiene el
beneficio futuro de explorar» (no hay término futuro que explorar). -/
theorem prop_ch8_mab_mdp_una_ronda {A : Type*} [Fintype A] [Nonempty A]
    (μ : A → ℝ) (γ : ℝ) :
    (∀ plan : Fin 1 → A, planReturn γ μ 1 plan = μ (plan 0)) ∧
    optimalReturn μ γ 1 = bestMean μ := by
  constructor
  · intro plan
    rw [planReturn, Fin.sum_univ_one]
    simp
  · simp [optimalReturn]

/-! ## prop:ch8-mab-mdp-thompson — última ronda y recursión bayesiana -/

variable {Ω : Type*} [MeasurableSpace Ω] {A : Type*} [Fintype A] [Nonempty A]

/-- Media posterior del brazo `a` bajo la ley posterior `P` sobre el
parámetro: `∫ μ(ω,a) P(dω)`. -/
noncomputable def postMean (P : Measure Ω) (μ : Ω → A → ℝ) (a : A) : ℝ :=
  ∫ ω, μ ω a ∂P

/-- Una acción es bayesiana para la recompensa de una ronda si ninguna otra
tiene esperanza posterior mayor. -/
def IsBayesAction (P : Measure Ω) (μ : Ω → A → ℝ) (a : A) : Prop :=
  ∀ b, postMean P μ b ≤ postMean P μ a

/-- Valor del problema de una ronda: la mayor media posterior. -/
noncomputable def oneRoundValue (P : Measure Ω) (μ : Ω → A → ℝ) : ℝ :=
  (univ : Finset A).sup' univ_nonempty (postMean P μ)

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) —
última ronda: con una ronda restante y utilidad igual a la recompensa, las
acciones bayesianas son exactamente los maximizadores de la media posterior,
y el valor del horizonte 1 es la mayor media posterior. No hay término de
recompensa futura: la exploración no puede aportar nada dentro de ese
horizonte. Fidelidad: la ley posterior `P` sobre el parámetro es un dato; la
recompensa de la acción `a` es `μ(ω,a)` (utilidad igual a la recompensa). -/
theorem prop_ch8_mab_mdp_thompson (P : Measure Ω) (μ : Ω → A → ℝ) (a : A) :
    IsBayesAction P μ a ↔ postMean P μ a = oneRoundValue P μ := by
  constructor
  · intro ha
    refine le_antisymm (Finset.le_sup' (postMean P μ) (mem_univ a)) ?_
    exact Finset.sup'_le _ _ fun b _ => ha b
  · intro ha b
    rw [ha]
    exact Finset.le_sup' (postMean P μ) (mem_univ b)

/-- Recursión del MDP bayesiano de adaptación: estado = creencia `b`, acción
`a`, observación `x ~ κ b a`, actualización `U`. `V 0 = 0` y
`V (n+1)(b) = max_a [ m(b,a) + γ ∫ V n (U b a x) κ b a(dx) ]`. -/
noncomputable def bamValue {B X : Type*} [MeasurableSpace X]
    (m : B → A → ℝ) (U : B → A → X → B) (κ : B → A → Measure X) (γ : ℝ) :
    ℕ → B → ℝ
  | 0, _ => 0
  | (n + 1), b =>
      (univ : Finset A).sup' univ_nonempty
        (fun a => m b a + γ * ∫ x, bamValue m U κ γ n (U b a x) ∂(κ b a))

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) — con
una ronda restante la recursión bayesiana se reduce a la media posterior: la
actualización del posterior no influye porque no quedan decisiones
posteriores. -/
theorem prop_ch8_mab_mdp_thompson_ultima {B X : Type*} [MeasurableSpace X]
    (m : B → A → ℝ) (U : B → A → X → B) (κ : B → A → Measure X) (γ : ℝ) (b : B) :
    bamValue m U κ γ 1 b = (univ : Finset A).sup' univ_nonempty (fun a => m b a) := by
  simp [bamValue]

/-- book: capitulos/cap03_mdp.typ:178 (key: prop:ch8-mab-mdp-thompson) — con
más rondas la recursión óptima debe considerar la actualización del
posterior y su efecto sobre decisiones posteriores: el valor nunca es menor
que el de una ronda (explorar no puede empeorar la recompensa esperada) y la
recursión incorpora explícitamente `U` y `κ`. Fidelidad: se supone
`0 ≤ m`, `0 ≤ γ` y que la integral del valor futuro está bien definida y es
no negativa; la monotonía se prueba por inducción sobre el horizonte. -/
theorem prop_ch8_mab_mdp_thompson_mas_rondas {B X : Type*} [MeasurableSpace X]
    (m : B → A → ℝ) (U : B → A → X → B) (κ : B → A → Measure X) (γ : ℝ)
    (hγ : 0 ≤ γ) (hm : ∀ b a, 0 ≤ m b a)
    (hint : ∀ (n : ℕ) (b : B) (a : A), Integrable (fun x => bamValue m U κ γ n (U b a x)) (κ b a)) :
    ∀ (n : ℕ) (b : B),
      (univ : Finset A).sup' univ_nonempty (fun a => m b a)
        ≤ bamValue m U κ γ (n + 1) b := by
  have hnonneg : ∀ (n : ℕ) (b : B), 0 ≤ bamValue m U κ γ n b := by
    intro n
    induction n with
    | zero => intro b; simp [bamValue]
    | succ n ih =>
        intro b
        obtain ⟨a₀⟩ := (inferInstance : Nonempty A)
        have h1 : 0 ≤ ∫ x, bamValue m U κ γ n (U b a₀ x) ∂(κ b a₀) :=
          integral_nonneg fun x => ih (U b a₀ x)
        have h2 : 0 ≤ γ * ∫ x, bamValue m U κ γ n (U b a₀ x) ∂(κ b a₀) :=
          mul_nonneg hγ h1
        have h3 : 0 ≤ m b a₀ + γ * ∫ x, bamValue m U κ γ n (U b a₀ x) ∂(κ b a₀) := by
          linarith [hm b a₀]
        exact le_trans h3 (Finset.le_sup'
          (f := fun a => m b a + γ * ∫ x, bamValue m U κ γ n (U b a x) ∂(κ b a))
          (mem_univ a₀))
  intro n b
  refine Finset.sup'_le _ _ fun a _ => ?_
  have h1 : 0 ≤ γ * ∫ x, bamValue m U κ γ n (U b a x) ∂(κ b a) :=
    mul_nonneg hγ (integral_nonneg fun x => hnonneg n (U b a x))
  simp only [bamValue]
  exact le_trans (le_add_of_nonneg_right h1) (Finset.le_sup'
    (f := fun a => m b a + γ * ∫ x, bamValue m U κ γ n (U b a x) ∂(κ b a))
    (mem_univ a))

/-! ## prop:ch8-thompson — muestreo posterior y probabilidad de ser óptimo -/

/-- book: capitulos/cap03_mdp.typ:154 (key: prop:ch8-thompson) — Thompson
Sampling extrae un vector de medias del posterior conjunto y selecciona un
brazo que maximice la muestra. Sin empates, la probabilidad (posterior) de
seleccionar un brazo coincide con su probabilidad posterior de ser óptimo.
Fidelidad: `μ ω a` es la media del brazo `a` en la muestra `ω` (ley posterior
conjunta); `pick` es una regla medible que selecciona un maximizador;
`huniq` es la ausencia de empates (maximizador único). El enunciado es la
igualdad de las dos probabilidades, no una afirmación de optimalidad del
riesgo posterior de la acción, que el libro niega expresamente. -/
theorem prop_ch8_thompson (P : Measure Ω) (μ : Ω → A → ℝ) (pick : Ω → A)
    (hmax : ∀ ω a, μ ω a ≤ μ ω (pick ω))
    (huniq : ∀ ω a b, μ ω a = μ ω b → a = b) (a : A) :
    P {ω | pick ω = a} = P {ω | ∀ b, μ ω b ≤ μ ω a} := by
  congr 1
  ext ω
  constructor
  · intro h b
    rw [← h]
    exact hmax ω b
  · intro h
    exact huniq ω (pick ω) a (le_antisymm (h (pick ω)) (hmax ω a))

/-! ## ex:ssch-bandits-cap08 — comparación calculable de exploración -/

/-- Probabilidades de éxito del ejemplo SSCH (sintético, no clínico). -/
def sschProbs : Fin 4 → ℚ := ![3/10, 1/2, 3/5, 4/5]

/-- book: capitulos/cap03_mdp.typ:166 (key: ex:ssch-bandits-cap08) —
ilustración matemática con cuatro opciones de probabilidades
`(0.3, 0.5, 0.6, 0.8)`: la media de una selección uniforme es `0.55`; en 20
rondas su pseudorregret esperado es `20(0.8−0.55) = 5`; el oráculo que conoce
las medias tiene pseudorregret cero; probar una vez cada opción cuesta en
expectativa `0.5+0.3+0.2+0 = 1`. Fidelidad: son cálculos exactos de
expectativas bajo el modelo declarado; no se atribuye ningún porcentaje de
éxito a UCB1 ni a Thompson Sampling. -/
theorem ex_ssch_bandits_cap08 :
    (∑ a : Fin 4, (1/4 : ℚ) * sschProbs a = 11/20) ∧
    ((20 : ℚ) * (4/5 - (∑ a : Fin 4, (1/4 : ℚ) * sschProbs a)) = 5) ∧
    (∑ a : Fin 4, (4/5 - sschProbs a) = 1) ∧
    (4/5 - (∑ a : Fin 4, (1/4 : ℚ) * sschProbs a) = 1/4) ∧
    ((0 : ℚ) = 20 * (4/5 - 4/5)) := by
  simp only [sschProbs, Fin.sum_univ_four]
  norm_num

end Book.Ch8Bandits
