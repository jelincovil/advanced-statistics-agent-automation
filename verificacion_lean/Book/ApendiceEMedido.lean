import Mathlib

/-!
# Book.ApendiceEMedido — fundamentos medido-teóricos (apéndice E)

Formalización de `apendices/apendice_medido.typ` del libro *Inferencia
Estadística*. Claves cubiertas:

* `ex:appE-borel` (línea 33) — σ-álgebra de Borel de `ℝ` como la σ-álgebra
  generada por los intervalos abiertos `(a,b)`, y por tanto la menor que los
  contiene.
* `prop:appE-composicion` (línea 49) — la composición de funciones medibles es
  medible.
* `ex:appE-estadisticos` (línea 54) — `T ∘ X` es medible si `T` es
  Borel-medible y `X` un vector aleatorio; un `X` constante oculta la falta de
  medibilidad de `T`; toda función continua es Borel-medible.
* `prop:appE-markov-filtracion` (línea 116) — la ley condicional es un núcleo
  de Markov que depende sólo de `(S_t,A_t)`; la filtración de historias
  `F_t = σ(S_0,A_0,R_0,…,S_t,A_t,R_t)` contiene a `G_t` (y estrictamente: una
  recompensa no medible antes de observarse lo prueba), de modo que no puede
  usarse `F_t` en la identidad de la ley conjunta antes de observar `R_t`.
* `prop:appE-estimadores-medibles` (línea 134) — la media muestral es continua
  y medible, la composición de estimadores medibles es medible, en un espacio
  paramétrico **finito** el menor maximizador es una selección medible, con
  compacidad el máximo existe, y la continuidad sola no lo garantiza.
* `prop:appE-dominacion-continuo` (línea 156) — si cada `P_θ` tiene densidad
  (medible) respecto de Lebesgue, entonces `P_θ ≪ λ` para todo `θ`; la
  continuidad de la densidad no se usa. Estados reales no bastan: `δ_0` no
  está dominada por Lebesgue.

## Fidelidad declarada

El libro enuncia las proposiciones en prosa. Aquí se fijan las versiones
formales más fuertes que el texto sostiene, sin añadir hipótesis que el libro
no tenga:

* Borel: la igualdad `borel ℝ = generateFrom {(a,b) : a < b}` usa la base de
  intervalos con extremos **racionales** (`Real.borel_eq_generateFrom_Ioo_rat`)
  y monotonía de `generateFrom`; no se postula nada.
* Estadísticos: se elige `Fin n → ℝ` como espacio muestral (el `ℝ^n` del libro);
  el recíproco se formaliza como que la composición con un `X` constante es
  medible para **cualquier** `T` (sin hipótesis), que es exactamente el
  contenido de «un `X` constante puede ocultar la falta de medibilidad».
* Markov: el núcleo `κ : Kernel (State × Action) (Reward × State)` es la
  versión Mathlib de `K_t(· | s, a)`; la propiedad de Markov se formaliza como
  que `ω ↦ κ(S_t ω, A_t ω)(B)` es `G_t`-medible (depende sólo de `(S_t,A_t)`)
  y es una probabilidad en `B`. La homogeneidad se registra como que la familia
  de núcleos no depende de `t`.
* Estimadores: `argmax` se formaliza sobre un espacio paramétrico **finito**
  (el caso compacto general exige teoremas de selección medible que Mathlib no
  tiene); se prueba que el menor maximizador es medible. La no existencia del
  máximo con continuidad sola se prueba con `x ↦ -e^x` en `ℝ`. No se formaliza
  la afirmación negativa sobre «una elección arbitraria entre empates»: no es
  un enunciado sobre una función concreta.
* Dominación: `P_θ = volume.withDensity (p θ)`; la existencia de densidad
  medible es la hipótesis que se usa. El ejemplo singular `δ_0` cierra el
  recíproco («estados reales no aseguran dominación»).

Cada declaración compila con `lean --root=.` sobre Mathlib precompilada, sin `sorry`, y su
auditoría de axiomas está en `Book/AuditAppE.lean`.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option warn.classDefReducibility false

open MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace Book.ApendiceE

/-! ## 1. La σ-álgebra de Borel (`ex:appE-borel`) -/

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Cada intervalo abierto `(a,b)` es un conjunto de Borel. Fidelidad: es la
propiedad que el libro usa para decir que `B(ℝ)` «contiene todos los conjuntos
de interés práctico»; se prueba, no se postula. -/
theorem appE_Ioo_medible (a b : ℝ) : MeasurableSet (Set.Ioo a b) := measurableSet_Ioo

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Todo abierto de `ℝ` es de Borel. -/
theorem appE_abierto_medible {U : Set ℝ} (hU : IsOpen U) : MeasurableSet U :=
  hU.measurableSet

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Todo cerrado de `ℝ` es de Borel. -/
theorem appE_cerrado_medible {F : Set ℝ} (hF : IsClosed F) : MeasurableSet F :=
  hF.measurableSet

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Todo conjunto numerable de `ℝ` es de Borel (en particular los singuletes). -/
theorem appE_numerable_medible {s : Set ℝ} (hs : s.Countable) : MeasurableSet s :=
  hs.measurableSet

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Los singuletes son de Borel. -/
theorem appE_singleton_medible (x : ℝ) : MeasurableSet ({x} : Set ℝ) :=
  MeasurableSet.singleton x

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
`B(ℝ)` es exactamente la σ-álgebra generada por los intervalos abiertos
`(a,b)`, es decir la menor σ-álgebra que los contiene. Fidelidad: la
definición del libro («la σ-álgebra más pequeña que contiene todos los
intervalos abiertos») es literalmente esta igualdad. -/
theorem appE_borel_generado_por_intervalos :
    (borel ℝ) =
      MeasurableSpace.generateFrom {s : Set ℝ | ∃ a b : ℝ, a < b ∧ s = Set.Ioo a b} := by
  refine le_antisymm ?_ ?_
  · rw [Real.borel_eq_generateFrom_Ioo_rat]
    refine MeasurableSpace.generateFrom_mono ?_
    intro s hs
    simp only [Set.mem_iUnion, Set.mem_singleton_iff] at hs
    obtain ⟨a, b, hab, rfl⟩ := hs
    exact ⟨(a : ℝ), (b : ℝ), by exact_mod_cast hab, rfl⟩
  · refine MeasurableSpace.generateFrom_le ?_
    rintro s ⟨a, b, _hab, rfl⟩
    exact measurableSet_Ioo

/-- book: apendices/apendice_medido.typ:33 (key: ex:appE-borel)
Forma «menor σ-álgebra»: cualquier σ-álgebra que contenga los intervalos
abiertos contiene a `B(ℝ)`. -/
theorem appE_borel_minima {m : MeasurableSpace ℝ}
    (h : ∀ a b : ℝ, a < b → MeasurableSet[m] (Set.Ioo a b)) : borel ℝ ≤ m := by
  rw [appE_borel_generado_por_intervalos]
  exact MeasurableSpace.generateFrom_le fun s hs => by
    obtain ⟨a, b, hab, rfl⟩ := hs
    exact h a b hab

/-! ## 2. Composición de funciones medibles (`prop:appE-composicion`) -/

/-- book: apendices/apendice_medido.typ:49 (key: prop:appE-composicion)
Si `f : Ω → Ω'` y `g : Ω' → Ω''` son medibles, entonces `g ∘ f` es medible.
Fidelidad: enunciado literal del libro. -/
theorem appE_composicion {Ω Ω' Ω'' : Type*} [MeasurableSpace Ω] [MeasurableSpace Ω']
    [MeasurableSpace Ω''] {f : Ω → Ω'} {g : Ω' → Ω''}
    (hg : Measurable g) (hf : Measurable f) : Measurable (g ∘ f) :=
  hg.comp hf

/-! ## 3. Medibilidad de estadísticos (`ex:appE-estadisticos`) -/

section Estadisticos

variable {n k : ℕ}

/-- book: apendices/apendice_medido.typ:54 (key: ex:appE-estadisticos)
Si `X : Ω → ℝ^n` es un vector aleatorio medible y `T : ℝ^n → ℝ^k` es
Borel-medible, entonces `T ∘ X` es medible. -/
theorem appE_estadistico_comp {Ω : Type*} [MeasurableSpace Ω]
    {X : Ω → (Fin n → ℝ)} {T : (Fin n → ℝ) → (Fin k → ℝ)}
    (hT : Measurable T) (hX : Measurable X) : Measurable (T ∘ X) :=
  hT.comp hX

/-- book: apendices/apendice_medido.typ:54 (key: ex:appE-estadisticos)
Un `X` constante produce una composición medible para **cualquier** `T`: la
medibilidad de `T ∘ X` no informa sobre la de `T`. -/
theorem appE_constante_oculta_comp {Ω : Type*} [MeasurableSpace Ω]
    {X : Ω → (Fin n → ℝ)} (x : Fin n → ℝ) (hX : ∀ ω, X ω = x)
    (T : (Fin n → ℝ) → (Fin k → ℝ)) : Measurable (T ∘ X) := by
  have h : (T ∘ X) = fun _ => T x := by
    funext ω
    simp [Function.comp_apply, hX ω]
  rw [h]
  exact measurable_const

/-- book: apendices/apendice_medido.typ:54 (key: ex:appE-estadisticos)
Versión puntual del recíproco fallido: `ω ↦ T(x)` es medible sin hipótesis
sobre `T`. -/
theorem appE_constante_oculta {Ω : Type*} [MeasurableSpace Ω] (x : Fin n → ℝ)
    (T : (Fin n → ℝ) → (Fin k → ℝ)) : Measurable (fun _ : Ω => T x) := measurable_const

/-- book: apendices/apendice_medido.typ:54 (key: ex:appE-estadisticos)
Toda función continua entre estos espacios es Borel-medible. -/
theorem appE_continuo_borel {T : (Fin n → ℝ) → (Fin k → ℝ)} (hT : Continuous T) :
    Measurable T := hT.measurable

end Estadisticos

/-! ## 4. Propiedad de Markov y filtraciones (`prop:appE-markov-filtracion`) -/

section Filtracion

variable {Ω State Action Reward : Type*}
  [MeasurableSpace Ω] [MeasurableSpace State] [MeasurableSpace Action] [MeasurableSpace Reward]

/-- `G_t = σ(S_0,A_0,…,S_t,A_t)`: la información **antes** de observar la
recompensa `R_t`. -/
def sigmaHistoria (S : ℕ → Ω → State) (A : ℕ → Ω → Action) (t : ℕ) : MeasurableSpace Ω :=
  MeasurableSpace.comap (fun ω (i : Fin (t + 1)) => (S i ω, A i ω)) inferInstance

/-- `F_t = G_t ⊔ σ(R_t)`: la filtración de historias del libro, que ya
contiene `R_t`. -/
def sigmaHistoriaRecompensa (S : ℕ → Ω → State) (A : ℕ → Ω → Action)
    (R : ℕ → Ω → Reward) (t : ℕ) : MeasurableSpace Ω :=
  sigmaHistoria S A t ⊔ MeasurableSpace.comap (R t) inferInstance

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
La filtración de historias contiene la información previa a la recompensa:
`G_t ≤ F_t`. -/
theorem appE_G_le_F (S : ℕ → Ω → State) (A : ℕ → Ω → Action) (R : ℕ → Ω → Reward)
    (t : ℕ) : sigmaHistoria S A t ≤ sigmaHistoriaRecompensa S A R t := le_sup_left

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
`R_t` es `F_t`-medible (por eso `F_t` «ya contiene `R_t`»). -/
theorem appE_recompensa_medible_F (S : ℕ → Ω → State) (A : ℕ → Ω → Action)
    (R : ℕ → Ω → Reward) (t : ℕ) :
    Measurable[sigmaHistoriaRecompensa S A R t] (R t) :=
  (comap_measurable (R t)).mono le_sup_right le_rfl

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
Cada par `(S_i, A_i)` con `i ≤ t` es `G_t`-medible. -/
theorem appE_estado_accion_medible_G (S : ℕ → Ω → State) (A : ℕ → Ω → Action)
    (t : ℕ) (i : Fin (t + 1)) :
    Measurable[sigmaHistoria S A t] (fun ω => (S i ω, A i ω)) :=
  (measurable_pi_apply i).comp (comap_measurable (fun ω (i : Fin (t + 1)) => (S i ω, A i ω)))

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
La ley condicional `K_t(B | S_t, A_t)` es una función **medible** de
`(S_t,A_t)`: si `κ` es un núcleo de `(State × Action)` a `(Reward × State)`,
entonces `ω ↦ κ(S_t ω, A_t ω)(B)` es `G_t`-medible. Fidelidad: ésta es la
propiedad de Markov en la forma en que el libro la usa; el núcleo entra como
dato (el libro tampoco lo construye, lo postula). -/
theorem appE_markov_nucleo_medible {m : MeasurableSpace Ω} {S : Ω → State} {A : Ω → Action}
    (hSA : Measurable[m] (fun ω => (S ω, A ω)))
    (κ : Kernel (State × Action) (Reward × State)) {B : Set (Reward × State)}
    (hB : MeasurableSet B) : Measurable[m] (fun ω => κ (S ω, A ω) B) :=
  (Kernel.measurable_coe κ hB).comp hSA

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
Para cada `(s,a)`, `κ(· | s,a)` es una medida de probabilidad. -/
theorem appE_markov_nucleo_probabilidad (κ : Kernel (State × Action) (Reward × State))
    [IsMarkovKernel κ] (p : State × Action) : IsProbabilityMeasure (κ p) :=
  IsMarkovKernel.isProbabilityMeasure p

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
La ley condicional depende sólo de `(s,a)`: dos historias con el mismo estado y
acción tienen la misma ley condicional. -/
theorem appE_markov_depende_de_sa (κ : Kernel (State × Action) (Reward × State))
    {B : Set (Reward × State)} {s s' : State} {a a' : Action} (hs : s = s') (ha : a = a') :
    (κ (s, a)) B = (κ (s', a')) B := by
  rw [hs, ha]

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
**Homogeneidad**: si la familia de núcleos no depende de `t` (`K t = κ` para
todo `t`), la ley condicional es la misma en todo instante. -/
theorem appE_markov_homogeneo (K : ℕ → Kernel (State × Action) (Reward × State))
    (κ : Kernel (State × Action) (Reward × State)) (hK : ∀ t, K t = κ)
    (t t' : ℕ) (p : State × Action) (B : Set (Reward × State)) :
    (K t p) B = (K t' p) B := by
  rw [hK t, hK t']

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
**Ley de transición**: si `ν` es la ley de `(S_t,A_t)` y `κ` el núcleo de Markov,
la ley de `(R_t,S_{t+1})` es la mezcla `ν.bind κ`, es decir
`P((R_t,S_{t+1}) ∈ B) = ∫ κ(·|s,a)(B) dν(s,a)`. Ésta es la identidad de la ley
conjunta que el libro escribe como `P((R_t,S_{t+1}) ∈ B | G_t) = K_t(B|S_t,A_t)`,
integrada contra la ley de `(S_t,A_t)`. -/
theorem appE_markov_ley_transicion (κ : Kernel (State × Action) (Reward × State))
    [IsMarkovKernel κ] (ν : Measure (State × Action)) [IsProbabilityMeasure ν]
    (B : Set (Reward × State)) (hB : MeasurableSet B) :
    IsProbabilityMeasure (ν.bind κ) ∧ (ν.bind κ) B = ∫⁻ p, κ p B ∂ν :=
  ⟨inferInstance, Measure.bind_apply hB (Kernel.aemeasurable κ)⟩

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
**Por qué la identidad no puede condicionarse en `F_t`**: en el modelo de
juguete `Ω = ℝ`, `S_t = A_t = 0` constantes y `R_t = id`, la σ-álgebra previa
es `G = ⊥` y la recompensa `R_t` **no** es `G`-medible. -/
theorem appE_recompensa_no_medible_bot : ¬ Measurable[⊥] (fun x : ℝ => x) := by
  intro h
  have h0 : MeasurableSet[⊥] ({0} : Set ℝ) := by
    simpa using h (t := {0}) (MeasurableSet.singleton (0 : ℝ))
  rw [MeasurableSpace.measurableSet_bot_iff] at h0
  rcases h0 with h0 | h0
  · exact absurd h0 (by simp)
  · have h1 : (1 : ℝ) ∈ ({0} : Set ℝ) := by
      rw [h0]
      exact Set.mem_univ 1
    simp at h1

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
En cambio, en la σ-álgebra que **incluye** la recompensa (`G ⊔ σ(R)`), sí es
medible: la inclusión `G_t ≤ F_t` es estricta. -/
theorem appE_recompensa_medible_sup : Measurable[⊥ ⊔ (borel ℝ)] (fun x : ℝ => x) :=
  measurable_id.mono le_sup_right le_rfl

/-- book: apendices/apendice_medido.typ:116 (key: prop:appE-markov-filtracion)
Existe un par de filtraciones `G < F` (la previa y la que añade la recompensa)
en el que la recompensa es `F`-medible y no `G`-medible: condicionar en `F_t`
no es lo mismo que condicionar en `G_t`. -/
theorem appE_filtracion_estricta :
    ∃ G F : MeasurableSpace ℝ,
      G < F ∧ ¬ @Measurable ℝ ℝ G (borel ℝ) (fun x : ℝ => x) ∧
        @Measurable ℝ ℝ F (borel ℝ) (fun x : ℝ => x) := by
  refine ⟨⊥, ⊥ ⊔ (borel ℝ), ?_, appE_recompensa_no_medible_bot,
    appE_recompensa_medible_sup⟩
  refine lt_of_le_of_ne le_sup_left ?_
  intro h
  exact appE_recompensa_no_medible_bot (h.symm ▸ appE_recompensa_medible_sup)

end Filtracion

/-! ## 5. Medibilidad de estimadores comunes (`prop:appE-estimadores-medibles`) -/

section Estimadores

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
La media muestral `x ↦ (∑ x_i)/n` es continua. -/
theorem appE_media_muestral_continua (n : ℕ) :
    Continuous (fun x : Fin n → ℝ => (∑ i, x i) / (n : ℝ)) := by
  fun_prop

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Con las σ-álgebras de Borel, la media muestral es medible. -/
theorem appE_media_muestral_medible (n : ℕ) :
    Measurable (fun x : Fin n → ℝ => (∑ i, x i) / (n : ℝ)) :=
  (appE_media_muestral_continua n).measurable

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
`g(T(X))` es medible si `T` y `g` lo son. -/
theorem appE_comp_estimador {Ω : Type*} [MeasurableSpace Ω] {n k : ℕ}
    {T : (Fin n → ℝ) → (Fin k → ℝ)} {g : (Fin k → ℝ) → ℝ}
    (hg : Measurable g) (hT : Measurable T) : Measurable (g ∘ T) :=
  hg.comp hT

section Seleccion

variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [LinearOrder ι] [Nonempty ι]
  [MeasurableSpace ι] [MeasurableSingletonClass ι]

/-- El conjunto (finito) de maximizadores del criterio `F ω`. -/
noncomputable def conjuntoMax (F : Ω → ι → ℝ) (ω : Ω) : Finset ι :=
  Finset.univ.filter (fun i => ∀ j, F ω j ≤ F ω i)

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: en un espacio paramétrico finito el conjunto de maximizadores no es vacío. -/
theorem conjuntoMax_nonempty (F : Ω → ι → ℝ) (ω : Ω) : (conjuntoMax F ω).Nonempty := by
  obtain ⟨i, -, hi⟩ :=
    Finset.exists_max_image (Finset.univ : Finset ι) (fun i => F ω i) Finset.univ_nonempty
  exact ⟨i, by simp [conjuntoMax, hi]⟩

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: caracterización de la pertenencia al conjunto de maximizadores. -/
theorem mem_conjuntoMax {F : Ω → ι → ℝ} {ω : Ω} {i : ι} :
    i ∈ conjuntoMax F ω ↔ ∀ j, F ω j ≤ F ω i := by
  simp [conjuntoMax]

/-- Selección canónica: el **menor** maximizador. Es la regla de desempate que
se prueba medible. -/
noncomputable def seleccionMax (F : Ω → ι → ℝ) (ω : Ω) : ι :=
  (conjuntoMax F ω).min' (conjuntoMax_nonempty F ω)

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: la selección canónica es un maximizador. -/
theorem seleccionMax_max (F : Ω → ι → ℝ) (ω : Ω) (j : ι) :
    F ω j ≤ F ω (seleccionMax F ω) :=
  (mem_conjuntoMax.mp (Finset.min'_mem _ _)) j

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: la selección canónica es el menor maximizador. -/
theorem seleccionMax_le (F : Ω → ι → ℝ) (ω : Ω) {i : ι} (hi : ∀ j, F ω j ≤ F ω i) :
    seleccionMax F ω ≤ i :=
  Finset.min'_le _ i (mem_conjuntoMax.mpr hi)

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: caracterización de la fibra del menor maximizador — `i` es el menor maximizador si y
sólo si es maximizador y todo `j < i` es estrictamente peor. -/
theorem seleccionMax_eq_iff (F : Ω → ι → ℝ) (ω : Ω) (i : ι) :
    seleccionMax F ω = i ↔ (∀ j, F ω j ≤ F ω i) ∧ ∀ j, j < i → F ω j < F ω i := by
  constructor
  · intro h
    have hmax : ∀ j, F ω j ≤ F ω i := by
      rw [← h]
      exact seleccionMax_max F ω
    refine ⟨hmax, fun j hj => ?_⟩
    by_contra hcon
    have hle : F ω i ≤ F ω j := le_of_not_gt hcon
    have hjmax : ∀ k, F ω k ≤ F ω j := fun k => le_trans (hmax k) hle
    have hle' : seleccionMax F ω ≤ j := seleccionMax_le F ω hjmax
    have hle'' : i ≤ j := h ▸ hle'
    exact absurd hle'' (not_le.mpr hj)
  · rintro ⟨hmax, hlt⟩
    have hle : seleccionMax F ω ≤ i := seleccionMax_le F ω hmax
    rcases lt_or_eq_of_le hle with hlt' | heq
    · have h1 : F ω i ≤ F ω (seleccionMax F ω) := seleccionMax_max F ω i
      have h2 : F ω (seleccionMax F ω) < F ω i := hlt (seleccionMax F ω) hlt'
      exact absurd h1 (not_le.mpr h2)
    · exact heq

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Auxiliar: una función a un espacio medible finito con singuletes medibles es medible si todas
sus fibras lo son. -/
theorem medible_de_fibras_finitas {f : Ω → ι} (h : ∀ i, MeasurableSet (f ⁻¹' {i})) :
    Measurable f := by
  intro s _
  have hfin : s.Finite := Set.toFinite s
  have heq : s = ⋃ i ∈ s, ({i} : Set ι) := by
    ext x
    simp
  rw [heq]
  have hpre : f ⁻¹' (⋃ i ∈ s, ({i} : Set ι)) = ⋃ i ∈ s, f ⁻¹' ({i} : Set ι) := by
    ext x
    simp
  rw [hpre]
  exact Set.Finite.measurableSet_biUnion hfin (fun i _ => h i)

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
**Selección medible**: en un espacio paramétrico finito, si el criterio
`F ω ·` es medible en los datos para cada parámetro, entonces el menor
maximizador es una función medible de los datos. Es la parte del libro que
exige «existencia y selección medible»; el desempate canónico (menor índice)
sí es medible. -/
theorem appE_seleccion_max_medible (F : Ω → ι → ℝ) (hF : ∀ i, Measurable fun ω => F ω i) :
    Measurable (seleccionMax F) := by
  refine medible_de_fibras_finitas (fun i => ?_)
  have hfib : (seleccionMax F) ⁻¹' ({i} : Set ι) = {ω | seleccionMax F ω = i} := rfl
  rw [hfib]
  have heq : {ω | seleccionMax F ω = i}
      = {ω | ∀ j, F ω j ≤ F ω i} ∩ {ω | ∀ j, j < i → F ω j < F ω i} := by
    ext ω
    simp [seleccionMax_eq_iff F ω i]
  rw [heq]
  refine MeasurableSet.inter ?_ ?_
  · have h1 : {ω | ∀ j, F ω j ≤ F ω i} = ⋂ j, {ω | F ω j ≤ F ω i} := by
      ext ω
      simp
    rw [h1]
    exact MeasurableSet.iInter (fun j => measurableSet_le (hF j) (hF i))
  · have h2 : {ω | ∀ j, j < i → F ω j < F ω i}
        = ⋂ j ∈ {j : ι | j < i}, {ω | F ω j < F ω i} := by
      ext ω
      simp
    rw [h2]
    exact Set.Finite.measurableSet_biInter (Set.toFinite _)
      (fun j _ => measurableSet_lt (hF j) (hF i))

end Seleccion

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
**Selección medible en un espacio paramétrico continuo**: con criterio
estrictamente cóncavo `θ ↦ -(θ - g ω)²`, el maximizador existe, es único y la
selección `ω ↦ g ω` es medible si `g` lo es. Complementa el caso finito: con
unicidad, la selección medible no necesita compacidad. -/
theorem appE_argmax_cuadratico_medible {Ω : Type*} [MeasurableSpace Ω] {g : Ω → ℝ}
    (hg : Measurable g) :
    ∃ θ : Ω → ℝ, Measurable θ ∧ ∀ ω (t : ℝ), -(t - g ω) ^ 2 ≤ -(θ ω - g ω) ^ 2 := by
  refine ⟨g, hg, fun ω t => ?_⟩
  have h : (0 : ℝ) ≤ (t - g ω) ^ 2 := sq_nonneg _
  have h2 : (g ω - g ω) ^ 2 = 0 := by ring
  rw [h2, neg_zero]
  linarith

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
El maximizador del criterio cuadrático es único: si `t` empata con `g`, entonces
`t = g`. -/
theorem appE_argmax_cuadratico_unico (g : ℝ) {t : ℝ}
    (h : -(t - g) ^ 2 = -(g - g) ^ 2) : t = g := by
  have h0 : (g - g) ^ 2 = 0 := by ring
  have h' : (t - g) ^ 2 = 0 := by linarith
  have h2 : t - g = 0 := sq_eq_zero_iff.mp h'
  linarith

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
Con compacidad, un criterio continuo alcanza su máximo: existencia asegurada. -/
theorem appE_maximo_existe_compacto {K : Set ℝ} (hK : IsCompact K) (hne : K.Nonempty)
    {g : ℝ → ℝ} (hg : ContinuousOn g K) : ∃ x ∈ K, ∀ y ∈ K, g y ≤ g x :=
  hK.exists_isMaxOn hne hg

/-- book: apendices/apendice_medido.typ:134 (key: prop:appE-estimadores-medibles)
La continuidad **sola** no garantiza que el máximo exista: `x ↦ -e^x` es
continua en `ℝ` y no alcanza su supremo `0`. -/
theorem appE_continuidad_sin_maximo : ¬ ∃ x : ℝ, ∀ y : ℝ, -Real.exp y ≤ -Real.exp x := by
  rintro ⟨x, hx⟩
  have h1 : -Real.exp (x - 1) ≤ -Real.exp x := hx (x - 1)
  have h2 : Real.exp (x - 1) < Real.exp x := by
    rw [Real.exp_lt_exp]
    linarith
  linarith

end Estimadores

/-! ## 6. Dominación en modelos continuos (`prop:appE-dominacion-continuo`) -/

section Dominacion

/-- Un modelo está dominado por Lebesgue si toda ley de la familia es
absolutamente continua respecto de la medida de Lebesgue. -/
def DominadaPorLebesgue {Θ : Type*} (P : Θ → Measure ℝ) : Prop := ∀ θ, P θ ≪ volume

/-- book: apendices/apendice_medido.typ:156 (key: prop:appE-dominacion-continuo)
Si cada `P_θ` es la ley con densidad `p_θ` respecto de Lebesgue (densidades
existentes para todo `θ`), entonces `λ` domina a toda la familia. Fidelidad: el
libro pide además continuidad (o al menos medibilidad) de las densidades; la
dominación **no la usa**, y se declara aquí explícitamente. -/
theorem appE_dominacion_densidad {Θ : Type*} (p : Θ → ℝ → ℝ≥0∞) :
    DominadaPorLebesgue fun θ => volume.withDensity (p θ) :=
  fun θ => withDensity_absolutelyContinuous volume (p θ)

/-- book: apendices/apendice_medido.typ:156 (key: prop:appE-dominacion-continuo)
Si la densidad está normalizada (`∫ p dλ = 1`), la ley con densidad es una
probabilidad. -/
theorem appE_densidad_probabilidad {p : ℝ → ℝ≥0∞} (hp : ∫⁻ x, p x ∂volume = 1) :
    IsProbabilityMeasure (volume.withDensity p) := by
  rw [isProbabilityMeasure_iff, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ]
  exact hp

/-- book: apendices/apendice_medido.typ:156 (key: prop:appE-dominacion-continuo)
**Modelo continuo dominado**: si cada `p_θ` es una densidad normalizada
(`∫ p_θ dλ = 1`), la familia `{P_θ = p_θ · λ}` es una familia de probabilidades
dominada por Lebesgue. Es la forma conjunta de la proposición del libro. -/
theorem appE_modelo_continuo_dominado {Θ : Type*} (p : Θ → ℝ → ℝ≥0∞)
    (hp : ∀ θ, ∫⁻ x, p θ x ∂volume = 1) :
    (∀ θ, IsProbabilityMeasure (volume.withDensity (p θ))) ∧
      DominadaPorLebesgue fun θ => volume.withDensity (p θ) :=
  ⟨fun θ => appE_densidad_probabilidad (hp θ), appE_dominacion_densidad p⟩

/-- book: apendices/apendice_medido.typ:156 (key: prop:appE-dominacion-continuo)
Una densidad continua produce una densidad medible: la hipótesis «continua (o al
menos medible)» del libro es más fuerte que lo necesario. -/
theorem appE_densidad_continua_medible {p : ℝ → ℝ} (hp : Continuous p) :
    Measurable fun x => ENNReal.ofReal (p x) :=
  (ENNReal.continuous_ofReal.comp hp).measurable

/-- book: apendices/apendice_medido.typ:156 (key: prop:appE-dominacion-continuo)
**Estados reales no aseguran dominación**: la masa de Dirac en `0` es una ley
en `ℝ` que no está dominada por Lebesgue (es singular). -/
theorem appE_dirac_sin_densidad : ¬ (Measure.dirac (0 : ℝ) ≪ volume) := by
  intro h
  have h0 : volume ({0} : Set ℝ) = 0 := by simp
  have h1 : Measure.dirac (0 : ℝ) ({0} : Set ℝ) = 0 := h h0
  simp at h1

end Dominacion

end Book.ApendiceE
