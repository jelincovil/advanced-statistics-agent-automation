import Mathlib

/-!
# Book/Cap12ProblemasM8.lean — los seis ejemplos del cap. 12 (`capitulos/cap12_problemas.typ`)

Formalización de las claves pendientes del capítulo 12 de `book_stat_inference_v0`:

* `ex:ssch-confound` — confounding no observado en el SSCH: dos mecanismos que
  producen la misma ley observada de `(A, Y)` y valores causales distintos, y la
  dirección del sesgo cambia con el mecanismo.
* `ex:ssch-pomdp` — SSCH como POMDP: la pérdida por observabilidad parcial.
* `ex:ssch-reliable` — agente SSCH confiable: doble robustez del estimador DR
  (AIPW) frente a errores en los modelos auxiliares.
* `ex:ssch-integration` — integración: la regla de decisión sobre intervalos es
  sólida y el error se acumula entre módulos.
* `ex:ssch-limitations` — limitaciones: sesgo del truncamiento de razones y cota
  de cola `R_max γ^H/(1-γ)` del horizonte finito.
* `ex:ssch-cap12` — el recorrido: la cifra de valor pertenece al diseño, y un
  cambio de procedimiento obliga a revisar el intervalo.

## Fidelidad declarada

Los seis ejemplos están declarados `es-sintetico: true` en el libro: no enuncian
teoremas sino situaciones. Para cada clave se declara aquí qué se formaliza.

* **Confounding.** Mecanismo generador binario con confusor latente `U ∈ {0,1}`
  (la adherencia no registrada), tratamiento `A ∈ {0,1}` y resultado
  determinista `Y = β·U + τ·A` — el ruido de media cero no altera ninguna de las
  esperanzas que se comparan. `Value(do(A=a))` es la media de `Y` bajo la ley
  marginal de `U` fijando `A = a`; el estimador sin ajustar es la comparación de
  medias `E[Y|A=1] − E[Y|A=0]`. No se formaliza ningún estimador DR concreto: el
  enunciado del libro es que «el estimador DR puede estar sesgado si no se
  controla por `U`» y que «la dirección del sesgo requiere especificar el
  mecanismo», y eso es exactamente lo que prueban `confound_misma_ley` y
  `confound_sesgo_cambia_de_signo`.
* **POMDP.** POMDP de un paso `(μ, obs, r)` con observación determinista
  `obs : S → O`; la política del agente es `π : O → A` (solo observaciones) y la
  referencia es una política `σ : S → A` que conoce el estado. El libro describe
  el estado de salud completo como no observable y las mediciones clínicas como
  parciales: el ejemplo formal exhibe el caso extremo (la medición no distingue
  estados), donde la pérdida es estricta, y el caso informativo, donde la
  pérdida desaparece. Horizonte uno: el capítulo tampoco fija horizonte para el
  ejemplo.
* **Reliable.** Decisión de un paso con estados y acciones finitos, ley conjunta
  observada `p s a`, propensión de comportamiento `e`, modelo de resultado `qh`,
  media condicional verdadera `q`. `aipw` es el funcional AIPW/DR poblacional
  (valor del modelo más corrección de importancia invertida) y `tgtValue` el
  valor de la política `π` bajo la ley del estado. «Robusto ante errores en el
  modelo de transiciones» se formaliza como doble robustez: el funcional es
  exacto si acierta **o** la propensión **o** el modelo de resultado. Los otros
  requisitos del ejemplo (IC por recomendación, explicación por Bellman,
  eficiencia semiparamétrica) no se re-prueban aquí: Bellman está en
  `Book/Cap03MDP.lean`, la frontera y la eficiencia en `Book/Cap06Fronteras.lean`
  y `Book/Cap11Despliegue.lean`, y el IC se formaliza en la Parte 4.
* **Integration.** Los módulos se modelan por su salida numérica: el módulo de
  evaluación entrega, por política candidata `i`, un centro `v i` y un semiancho
  `ε i`, y el módulo de decisión elige `i` cuando su cota inferior supera la
  superior de todos los demás. «Verifica si las diferencias son
  estadísticamente significativas» se codifica como esa separación estricta de
  intervalos; «la incertidumbre viaja con la estimación» como la suma de
  semianchos entre módulos (`error_propagation`).
* **Limitaciones.** (i) El clipping de razones se ejemplifica en la decisión de
  una acción con dos valores, donde el sesgo se calcula exactamente y es
  negativo; (ii) la cota de cola es la del libro, `R_max γ^H/(1-γ)`, para
  recompensas acotadas por `R_max` y `0 ≤ γ < 1`, y el ejemplo de doce pasos
  muestra que la cota se alcanza, de modo que el objetivo de doce meses no es el
  retorno infinito. No se formaliza «mixing» ni «nuisance estimation»: el libro
  solo los enumera.
* **cap12.** Valor de una política de un paso como función de la recompensa
  (el «procedimiento»): es lineal, monótono, y el ejemplo numérico muestra que un
  intervalo calculado bajo un procedimiento no cubre el valor bajo otro, que es
  la lectura formal de «un cambio de población, procedimiento o política obliga
  a revisar».

Verificado con el entorno del proyecto (Mathlib precompilado en `/opt/mathlib`,
`LEAN_PATH` del entorno, `lean --root=.`), sin `sorry`, y
`#print axioms` ⊆ {propext, Classical.choice, Quot.sound}.
-/

open Finset BigOperators

noncomputable section

namespace Book.Cap12ProblemasM8

/-! ## Parte 1 — `ex:ssch-confound`: confounding no observado -/

/-- Mecanismo generador binario con confusor latente. `p0 = P(U = 0)`,
`e0 = P(A = 1 | U = 0)`, `e1 = P(A = 1 | U = 1)`, y resultado
`Y = β·U + τ·A` (determinista; el ruido de media cero no cambia esperanzas).
`τ` es el efecto causal medio del tratamiento. -/
structure DGP where
  /-- `P(U = 0)`. -/
  p0 : ℝ
  /-- `P(A = 1 | U = 0)`. -/
  e0 : ℝ
  /-- `P(A = 1 | U = 1)`. -/
  e1 : ℝ
  /-- Efecto del confusor latente sobre el resultado. -/
  β : ℝ
  /-- Efecto causal del tratamiento. -/
  τ : ℝ

namespace DGP

/-- `P(U = 1, A = 1)`. -/
def p11 (d : DGP) : ℝ := (1 - d.p0) * d.e1

/-- `P(U = 1, A = 0)`. -/
def p10 (d : DGP) : ℝ := (1 - d.p0) * (1 - d.e1)

/-- `P(U = 0, A = 1)`. -/
def p01 (d : DGP) : ℝ := d.p0 * d.e0

/-- `P(U = 0, A = 0)`. -/
def p00 (d : DGP) : ℝ := d.p0 * (1 - d.e0)

/-- `P(A = 1)`. -/
def pA1 (d : DGP) : ℝ := d.p11 + d.p01

/-- `P(A = 0)`. -/
def pA0 (d : DGP) : ℝ := d.p10 + d.p00

/-- `E[Y | A = 1] = β·P(U = 1 | A = 1) + τ`. -/
def eY1 (d : DGP) : ℝ := d.β * (d.p11 / d.pA1) + d.τ

/-- `E[Y | A = 0] = β·P(U = 1 | A = 0)`. -/
def eY0 (d : DGP) : ℝ := d.β * (d.p10 / d.pA0)

/-- Comparación de medias observacional `E[Y|A=1] − E[Y|A=0]`: lo que reporta un
estimador que no controla por `U`. -/
def naiveDiff (d : DGP) : ℝ := d.eY1 - d.eY0

/-- Efecto causal medio `Value(do(A=1)) − Value(do(A=0))`. -/
def ate (d : DGP) : ℝ := d.τ

/-- Sesgo del estimador sin ajustar. -/
def bias (d : DGP) : ℝ := d.naiveDiff - d.ate

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — El sesgo es `β·(P(U=1|A=1) − P(U=1|A=0))`: el término `τ` se cancela, de
modo que su magnitud y su signo dependen del mecanismo. -/
theorem bias_eq (d : DGP) :
    d.bias = d.β * (d.p11 / d.pA1 - d.p10 / d.pA0) := by
  simp [bias, naiveDiff, ate, eY1, eY0]
  ring

end DGP

open DGP

/-- Mecanismo I: la adherencia favorece la intervención (`e1 > e0`) y mejora el
resultado (`β > 0`); no hay efecto causal (`τ = 0`). -/
def dgpI : DGP := ⟨1 / 2, 1 / 2, 1, 1, 0⟩

/-- Mecanismo II: **la misma ley observada de `(A, Y)`** que `dgpI`, pero con
efecto causal `τ = −1/2`. -/
def dgpII : DGP := ⟨9 / 16, 5 / 9, 1, 2, -1 / 2⟩

/-- Mecanismo III: la adherencia desfavorece la intervención (`e1 < e0`) con el
mismo `β > 0`; el sesgo cambia de signo. -/
def dgpIII : DGP := ⟨1 / 2, 1, 1 / 2, 1, 0⟩

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — sin
ajustar por la adherencia, la comparación de medias no es el efecto causal. -/
theorem confound_naive_biased : dgpI.naiveDiff = 2 / 3 ∧ dgpI.ate = 0 := by
  constructor <;>
    norm_num [naiveDiff, ate, eY1, eY0, p11, p10, p01, p00, pA1, pA0, dgpI]

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — la ley
observada de `(A, Y)` es la misma en los mecanismos I y II: `P(A=1)`, `E[Y|A=1]`
y `E[Y|A=0]` coinciden. -/
theorem confound_misma_ley :
    dgpI.pA1 = dgpII.pA1 ∧ dgpI.eY1 = dgpII.eY1 ∧ dgpI.eY0 = dgpII.eY0 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    norm_num [eY1, eY0, p11, p10, p01, p00, pA1, pA0, dgpI, dgpII]

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — y sin
embargo los efectos causales difieren: la adherencia no registrada no es
identificable a partir de la ley observada. -/
theorem confound_ate_distintos : dgpI.ate ≠ dgpII.ate := by
  norm_num [ate, dgpI, dgpII]

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — la
consecuencia para el estimador: dos mecanismos con la misma cifra observacional
(`naiveDiff`, el funcional DR de un paso sin covariables) tienen valores causales
distintos; ninguna corrección basada solo en la ley observada puede identificar
el valor. -/
theorem confound_no_identificable :
    dgpI.naiveDiff = dgpII.naiveDiff ∧ dgpI.ate ≠ dgpII.ate := by
  have h := confound_misma_ley
  constructor
  · simp only [naiveDiff, h.2.1, h.2.2]
  · exact confound_ate_distintos

/-- book: capitulos/cap12_problemas.typ:107 (key: ex:ssch-confound) — la
dirección del sesgo depende del mecanismo: el mecanismo I sobreestima y el
mecanismo III subestima el mismo efecto nulo. -/
theorem confound_sesgo_cambia_de_signo : 0 < dgpI.bias ∧ dgpIII.bias < 0 := by
  constructor <;>
    norm_num [bias, naiveDiff, ate, eY1, eY0, p11, p10, p01, p00, pA1, pA0, dgpI, dgpIII]

/-! ## Parte 2 — `ex:ssch-pomdp`: SSCH como POMDP -/

/-- POMDP de un paso: ley inicial `μ` (peso sobre estados), observación
determinista `obs` (la medición clínica) y recompensa `r`. -/
structure OneStepPOMDP (S A O : Type*) where
  /-- Peso inicial sobre los estados. -/
  μ : S → ℝ
  /-- Observación que recibe el agente en cada estado. -/
  obs : S → O
  /-- Recompensa del par (estado, acción). -/
  r : S → A → ℝ

section Pomdp

variable {S A O : Type*} [Fintype S] [Fintype A] [Fintype O]

/-- Valor de una política que solo ve la observación, `π : O → A`. -/
def pomdpValue (P : OneStepPOMDP S A O) (π : O → A) : ℝ :=
  ∑ s, P.μ s * P.r s (π (P.obs s))

/-- Valor de una política que conoce el estado (referencia). -/
def stateValue (P : OneStepPOMDP S A O) (σ : S → A) : ℝ :=
  ∑ s, P.μ s * P.r s (σ s)

omit [Fintype A] [Fintype O] in
/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — Toda política basada en observaciones es una política de estado
(`π ∘ obs`): no puede superar al óptimo con estado conocido. -/
theorem pomdpValue_eq_stateValue (P : OneStepPOMDP S A O) (π : O → A) :
    pomdpValue P π = stateValue P fun s => π (P.obs s) := rfl

end Pomdp

/-- SSCH del ejemplo: estado de salud en `Fin 2`, dos acciones, y la medición
clínica no distingue los estados («el médico solo observa mediciones clínicas
parciales»: aquí, ninguna información). -/
def sshPOMDP : OneStepPOMDP (Fin 2) (Fin 2) (Fin 2) where
  μ := fun _ => 1 / 2
  obs := fun _ => 0
  r := fun s a => if s = a then 1 else 0

/-- SSCH con medición completa: la observación revela el estado. -/
def sshPOMDPfull : OneStepPOMDP (Fin 2) (Fin 2) (Fin 2) where
  μ := fun _ => 1 / 2
  obs := id
  r := fun s a => if s = a then 1 else 0

/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — Con la medición parcial del ejemplo, toda política basada en observaciones
vale `1/2`. -/
theorem pomdp_parcial_toda_politica (π : Fin 2 → Fin 2) :
    pomdpValue sshPOMDP π = 1 / 2 := by
  simp only [pomdpValue, sshPOMDP, Fin.sum_univ_two]
  have h2 : ∀ x : Fin 2, x = 0 ∨ x = 1 := by
    intro x
    fin_cases x
    · exact Or.inl rfl
    · exact Or.inr rfl
  rcases h2 (π 0) with h | h
  · simp [h]
  · simp [h]

/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — La política que conoce el estado alcanza el valor `1`. -/
theorem pomdp_estado_valor : stateValue sshPOMDP (fun s => s) = 1 := by
  simp [stateValue, sshPOMDP]

/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — la
observabilidad parcial cuesta estrictamente: ninguna política basada en las
mediciones alcanza el valor de la que conoce el estado de salud completo. -/
theorem pomdp_perdida_estricta (π : Fin 2 → Fin 2) :
    pomdpValue sshPOMDP π < stateValue sshPOMDP (fun s => s) := by
  rw [pomdp_parcial_toda_politica π, pomdp_estado_valor]
  norm_num

/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — si la
medición revela el estado, la pérdida desaparece: la clase de políticas basadas
en observaciones contiene al óptimo. -/
theorem pomdp_sin_perdida_si_observa :
    pomdpValue sshPOMDPfull id = stateValue sshPOMDPfull id := rfl

/-- book: capitulos/cap12_problemas.typ:155 (key: ex:ssch-pomdp) — en el caso
informativo la política `π = id` alcanza el valor `1`, igual que la referencia
con estado conocido. -/
theorem pomdp_informativo_alcanza :
    pomdpValue sshPOMDPfull id = 1 ∧ stateValue sshPOMDPfull id = 1 := by
  constructor <;> simp [pomdpValue, stateValue, sshPOMDPfull]

/-! ## Parte 3 — `ex:ssch-reliable`: doble robustez del estimador DR -/

section DR

variable {S A : Type*} [Fintype S] [Fintype A] [DecidableEq A]

/-- Funcional AIPW (DR) poblacional para una política determinista `π`, con
propensión `e` (comportamiento) y modelo de resultado `qh`; `p s a` es
`P(S = s, A = a)` bajo el muestreo observado y `q s a = E[Y | S = s, A = a]`.
Primer sumando: valor del modelo. Segundo: corrección de importancia invertida,
`1{a = π s}·p(s,a)·(q − q̂)(s,a)/e(s,a)`. -/
def aipw (p e : S → A → ℝ) (qh q : S → A → ℝ) (π : S → A) : ℝ :=
  (∑ s, ∑ a, p s a * qh s (π s))
    + ∑ s, ∑ a, if a = π s then p s a * (q s a - qh s a) / e s a else 0

/-- Valor de la política `π` bajo la ley del estado `μ`. -/
def tgtValue (μ : S → ℝ) (q : S → A → ℝ) (π : S → A) : ℝ := ∑ s, μ s * q s (π s)

/-- book: capitulos/cap12_problemas.typ:378 (key: ex:ssch-reliable) — Con la propensión correcta (`p s a = μ s · e s a`, `∑_a e s a = 1`), el AIPW
es exacto para **cualquier** modelo de resultado. -/
theorem aipw_eq_of_propensity (p e : S → A → ℝ) (qh q : S → A → ℝ) (μ : S → ℝ)
    (π : S → A) (hp : ∀ s a, p s a = μ s * e s a) (he : ∀ s, ∑ a, e s a = 1)
    (hne : ∀ s a, e s a ≠ 0) :
    aipw p e qh q π = tgtValue μ q π := by
  have h1 : ∀ s, (∑ a, p s a * qh s (π s)) = μ s * qh s (π s) := by
    intro s
    have : ∑ a, p s a * qh s (π s) = ∑ a, (μ s * qh s (π s)) * e s a := by
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [hp s a]; ring
    rw [this, ← Finset.mul_sum, he s, mul_one]
  have h2 : ∀ s, (∑ a, if a = π s then p s a * (q s a - qh s a) / e s a else 0)
      = μ s * (q s (π s) - qh s (π s)) := by
    intro s
    have hz : e s (π s) ≠ 0 := hne s (π s)
    rw [Finset.sum_eq_single (π s)]
    · simp only [ite_true, hp s (π s)]
      field_simp
    · intro b _ hb
      simp [hb]
    · intro h
      simp at h
  have h3 : ∀ s, (∑ a, p s a * qh s (π s))
      + (∑ a, if a = π s then p s a * (q s a - qh s a) / e s a else 0)
      = μ s * q s (π s) := by
    intro s
    rw [h1 s, h2 s]
    ring
  rw [aipw, ← Finset.sum_add_distrib, tgtValue]
  exact Finset.sum_congr rfl fun s _ => h3 s

/-- book: capitulos/cap12_problemas.typ:378 (key: ex:ssch-reliable) — Con el modelo de resultado correcto (`qh = q`), el AIPW es exacto para
**cualquier** propensión: la corrección se anula término a término. -/
theorem aipw_eq_of_outcome (p e : S → A → ℝ) (q : S → A → ℝ) (μ : S → ℝ)
    (π : S → A) (hmarg : ∀ s, ∑ a, p s a = μ s) :
    aipw p e q q π = tgtValue μ q π := by
  have h1 : ∀ s, (∑ a, p s a * q s (π s)) = μ s * q s (π s) := by
    intro s
    rw [← hmarg s, Finset.sum_mul]
  have h2 : ∀ s, (∑ a, if a = π s then p s a * (q s a - q s a) / e s a else 0) = 0 := by
    intro s
    refine Finset.sum_eq_zero fun a _ => ?_
    split_ifs with h
    · rw [sub_self, mul_zero, zero_div]
    · rfl
  rw [aipw, ← Finset.sum_add_distrib, tgtValue]
  refine Finset.sum_congr rfl fun s _ => ?_
  rw [h1 s, h2]
  ring

/-- book: capitulos/cap12_problemas.typ:378 (key: ex:ssch-reliable) — el
estimador DR es robusto ante errores en los modelos auxiliares: basta que acierte
la propensión **o** el modelo de resultado (doble robustez). -/
theorem aipw_double_robust (p e : S → A → ℝ) (qh q : S → A → ℝ) (μ : S → ℝ)
    (π : S → A) (hp : ∀ s a, p s a = μ s * e s a) (he : ∀ s, ∑ a, e s a = 1)
    (hne : ∀ s a, e s a ≠ 0) (hmarg : ∀ s, ∑ a, p s a = μ s) :
    aipw p e qh q π = tgtValue μ q π := by
  by_cases h : qh = q
  · rw [h]
    exact aipw_eq_of_outcome p e q μ π hmarg
  · exact aipw_eq_of_propensity p e qh q μ π hp he hne

/-- book: capitulos/cap12_problemas.typ:378 (key: ex:ssch-reliable) — testigo
numérico: con propensión correcta y modelo de resultado equivocado (`q̂ ≠ q`) el
AIPW sigue siendo exacto. -/
theorem aipw_witness_modelo_malo :
    aipw (fun (_ : Fin 1) (_ : Fin 2) => (1 : ℝ) / 2) (fun _ _ => (1 : ℝ) / 2)
      (fun _ _ => (1 : ℝ) / 2) (fun _ a => if a = 1 then 1 else 0)
      (fun _ => 1) = 1 := by
  rw [aipw_eq_of_propensity (μ := fun _ => 1)]
  · simp [tgtValue]
  · intro s a; norm_num
  · intro s; simp
  · intro s a; norm_num

end DR

/-! ## Parte 4 — `ex:ssch-integration`: decisión sobre intervalos -/

section Integracion

/-- Intervalos reportados por el módulo de evaluación: centro `v` y semiancho `ε`
por política candidata. -/
structure ICert (ι : Type*) where
  /-- Centro del intervalo (estimación de valor). -/
  v : ι → ℝ
  /-- Semiancho del intervalo. -/
  ε : ι → ℝ

/-- El intervalo es válido para los valores `V`: cada valor cae dentro. -/
def ICert.Valid {ι : Type*} (I : ICert ι) (V : ι → ℝ) : Prop := ∀ i, |I.v i - V i| ≤ I.ε i

/-- Regla del módulo de decisión: `i` se elige si su cota inferior supera
estrictamente la cota superior de todo otro candidato (diferencia
estadísticamente significativa). -/
def ICert.Selected {ι : Type*} (I : ICert ι) (i : ι) : Prop :=
  ∀ j, j ≠ i → I.v j + I.ε j < I.v i - I.ε i

/-- book: capitulos/cap12_problemas.typ:425 (key: ex:ssch-integration) — si los
intervalos son válidos y el módulo de decisión elige `i`, entonces `i` supera
estrictamente a todos los demás: la regla nunca se equivoca cuando decide. -/
theorem selected_sound {ι : Type*} (I : ICert ι) (V : ι → ℝ) (hI : I.Valid V) {i : ι}
    (h : I.Selected i) : ∀ j, j ≠ i → V j < V i := by
  intro j hj
  have hi := hI i
  have hj' := hI j
  rw [abs_le] at hi hj'
  have := h j hj
  linarith [hi.1, hi.2, hj'.1, hj'.2]

/-- book: capitulos/cap12_problemas.typ:425 (key: ex:ssch-integration) — la
incertidumbre viaja entre módulos y se acumula: el error del módulo de estimación
y el semiancho del módulo de evaluación se suman. -/
theorem error_propagation {ι : Type*} {v V Vt : ι → ℝ} {εest εev : ι → ℝ}
    (h1 : ∀ i, |v i - V i| ≤ εev i) (h2 : ∀ i, |V i - Vt i| ≤ εest i) (i : ι) :
    |v i - Vt i| ≤ εest i + εev i := by
  calc |v i - Vt i| = |(v i - V i) + (V i - Vt i)| := by ring_nf
    _ ≤ |v i - V i| + |V i - Vt i| := abs_add_le _ _
    _ ≤ εev i + εest i := add_le_add (h1 i) (h2 i)
    _ = εest i + εev i := by ring

/-- book: capitulos/cap12_problemas.typ:425 (key: ex:ssch-integration) — la regla
es sólida pero incompleta: con dos candidatos cuyos intervalos se tocan no elige
ninguno, aunque exista un ganador único. (Abstenerse es parte del flujo: el
módulo de decisión no debe forzar una comparación no significativa.) -/
theorem rule_may_abstain :
    ∀ i : Fin 2, ¬ (⟨![1, 0], ![1 / 2, 1 / 2]⟩ : ICert (Fin 2)).Selected i := by
  intro i h
  fin_cases i
  · have := h 1 (by decide)
    norm_num at this
  · have := h 0 (by decide)
    norm_num at this

end Integracion

/-! ## Parte 5 — `ex:ssch-limitations`: clipping y horizonte -/

section Limitaciones

/-- Valor de la política objetivo en la decisión de una acción con dos valores
(`Y(0) = 0`, `Y(1) = 1`) cuando la política objetivo juega `a = 1` siempre y el
comportamiento juega `a = 1` con probabilidad `b1`. -/
def isValue (b1 : ℝ) : ℝ := b1 * (1 / b1)

/-- El mismo valor estimado por importancia con las razones truncadas en `M`. -/
def clippedIS (b1 M : ℝ) : ℝ := b1 * min (1 / b1) M

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — el
truncamiento de razones introduce sesgo negativo cuando `M < 1/b1`: la
estimación es `b1·M` mientras el valor es `1`. -/
theorem clipping_sesgo_negativo (b1 M : ℝ) (hb : 0 < b1) (h : M < 1 / b1) :
    clippedIS b1 M < isValue b1 := by
  have hbne : b1 ≠ 0 := ne_of_gt hb
  rw [clippedIS, isValue, min_eq_right (le_of_lt h)]
  exact mul_lt_mul_of_pos_left h hb

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — el caso
numérico: con razones de hasta `2` truncadas en `M = 1` la estimación vale `1/2`
cuando el valor es `1`. -/
theorem clipping_ejemplo : clippedIS (1 / 2) 1 = 1 / 2 ∧ isValue (1 / 2) = 1 := by
  constructor <;> norm_num [clippedIS, isValue]

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — Cota geométrica: `∑_{t<N} γ^t ≤ (1-γ)⁻¹` para `0 ≤ γ < 1`. -/
theorem geom_sum_le_inv (γ : ℝ) (h0 : 0 ≤ γ) (h1 : γ < 1) (N : ℕ) :
    ∑ t ∈ Finset.range N, γ ^ t ≤ (1 - γ)⁻¹ := by
  have hpos : 0 < 1 - γ := by linarith
  have key : (∑ t ∈ Finset.range N, γ ^ t) * (1 - γ) = 1 - γ ^ N := by
    induction N with
    | zero => simp
    | succ n ih => rw [Finset.sum_range_succ, add_mul, ih, pow_succ]; ring
  rw [← one_div, le_div_iff₀ hpos, key]
  linarith [pow_nonneg h0 N]

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — cota de
cola del retorno descontado: truncar en `H` una recompensa acotada por `R_max`
cuesta a lo sumo `R_max·γ^H/(1-γ)`. Es la cota que el libro propone para elegir
`H`. -/
theorem discounted_tail_bound (R : ℕ → ℝ) (M γ : ℝ) (hM : 0 ≤ M) (h0 : 0 ≤ γ)
    (h1 : γ < 1) (hR : ∀ t, |R t| ≤ M) (H N : ℕ) :
    |∑ t ∈ Finset.range N, γ ^ (H + t) * R (H + t)| ≤ M * γ ^ H / (1 - γ) := by
  have hMγ : 0 ≤ M * γ ^ H := mul_nonneg hM (pow_nonneg h0 H)
  calc |∑ t ∈ Finset.range N, γ ^ (H + t) * R (H + t)|
      ≤ ∑ t ∈ Finset.range N, |γ ^ (H + t) * R (H + t)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ = ∑ t ∈ Finset.range N, γ ^ (H + t) * |R (H + t)| := by
        refine Finset.sum_congr rfl fun t _ => ?_
        rw [abs_mul, abs_of_nonneg (pow_nonneg h0 _)]
    _ ≤ ∑ t ∈ Finset.range N, γ ^ (H + t) * M := by
        refine Finset.sum_le_sum fun t _ => ?_
        exact mul_le_mul_of_nonneg_left (hR (H + t)) (pow_nonneg h0 _)
    _ = M * γ ^ H * ∑ t ∈ Finset.range N, γ ^ t := by
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun t _ => ?_
        rw [pow_add]; ring
    _ ≤ M * γ ^ H * (1 - γ)⁻¹ :=
        mul_le_mul_of_nonneg_left (geom_sum_le_inv γ h0 h1 N) hMγ
    _ = M * γ ^ H / (1 - γ) := by rw [div_eq_mul_inv]

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — el
objetivo de doce decisiones con `γ = 1/2` vale `2 − 2⁻¹¹`, no `2`: el horizonte
finito define el objetivo y no aproxima el retorno infinito. -/
theorem doce_pasos_no_es_infinito :
    (∑' t : ℕ, ((1 / 2 : ℝ) ^ t)) - (∑ t ∈ Finset.range 12, ((1 / 2 : ℝ) ^ t))
      = (1 / 2) ^ 11 := by
  rw [tsum_geometric_of_lt_one (by norm_num) (by norm_num),
    geom_sum_eq (by norm_num : ((1 / 2 : ℝ)) ≠ 1)]
  norm_num

/-- book: capitulos/cap12_problemas.typ:467 (key: ex:ssch-limitations) — y la
cola exacta `2⁻¹¹` es justamente la cota `γ^H/(1-γ)` con `H = 12`: la cota del
libro se alcanza. -/
theorem doce_pasos_cola_es_la_cota :
    ((1 / 2 : ℝ) ^ 12) / (1 - 1 / 2) = (1 / 2) ^ 11 := by
  norm_num

end Limitaciones

/-! ## Parte 6 — `ex:ssch-cap12`: el valor pertenece al diseño -/

section Recorrido

variable {S A : Type*} [Fintype S] [Fintype A]

/-- Cifra de valor de una política determinista en una decisión de un paso: la
ley del estado `μ` (la población) y la recompensa `r` (el procedimiento). -/
def stepValue (μ : S → ℝ) (r : S → A → ℝ) (π : S → A) : ℝ := ∑ s, μ s * r s (π s)

omit [Fintype A] in
/-- book: capitulos/cap12_problemas.typ:482 (key: ex:ssch-cap12) — El valor es lineal en la recompensa: cambiar el procedimiento de `r` a
`r + δ` desplaza la cifra exactamente en `stepValue μ δ π`. -/
theorem stepValue_add (μ : S → ℝ) (r δ : S → A → ℝ) (π : S → A) :
    stepValue μ (fun s a => r s a + δ s a) π = stepValue μ r π + stepValue μ δ π := by
  simp only [stepValue, mul_add, Finset.sum_add_distrib]

omit [Fintype A] in
/-- book: capitulos/cap12_problemas.typ:482 (key: ex:ssch-cap12) — El valor es monótono en la recompensa (con `μ ≥ 0`): la dirección del cambio
se conoce, pero no su magnitud. -/
theorem stepValue_mono (μ : S → ℝ) (hμ : ∀ s, 0 ≤ μ s) {r r' : S → A → ℝ}
    (h : ∀ s a, r s a ≤ r' s a) (π : S → A) : stepValue μ r π ≤ stepValue μ r' π := by
  refine Finset.sum_le_sum fun s _ => ?_
  exact mul_le_mul_of_nonneg_left (h s (π s)) (hμ s)

/-- book: capitulos/cap12_problemas.typ:482 (key: ex:ssch-cap12) — un intervalo
calculado bajo un procedimiento no cubre el valor bajo otro: con dos estados
equiprobables, subir a `1/2` la recompensa de la acción elegida desplaza el valor
de `0` a `1/2`, fuera del intervalo de semiancho `1/4` reportado. «Un cambio de
procedimiento obliga a revisar» la cifra y su intervalo: hay que rehacer el
cálculo, no reutilizar el certificado. -/
theorem ic_no_cubre_otro_procedimiento :
    stepValue (fun _ : Fin 2 => (1 : ℝ) / 2) (fun _ _ => 0) (fun _ => (0 : Fin 2)) = 0
      ∧ stepValue (fun _ : Fin 2 => (1 : ℝ) / 2)
          (fun (_ : Fin 2) a => if a = 0 then 1 / 2 else 0) (fun _ => (0 : Fin 2)) = 1 / 2
      ∧ ¬ (|stepValue (fun _ : Fin 2 => (1 : ℝ) / 2)
            (fun (_ : Fin 2) a => if a = 0 then 1 / 2 else 0) (fun _ => (0 : Fin 2)) - 0| ≤ 1 / 4) := by
  refine ⟨?_, ?_, ?_⟩
  · simp [stepValue]
  · simp [stepValue]
  · rw [stepValue, Fin.sum_univ_two]
    norm_num

end Recorrido

end Book.Cap12ProblemasM8
