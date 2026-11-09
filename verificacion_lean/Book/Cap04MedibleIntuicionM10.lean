import Mathlib

/-!
# Book.Cap04MedibleIntuicionM10 — la clave huérfana `unnamed.example.160`

Formaliza el bloque **sin clave** de `capitulos/cap04_herramientas.typ:184`
(`#thm-env("example", name: [Intuición])`, anidado dentro de
`def:medible-operativa`) y le asigna la clave **`ex:ch1-medible-intuicion`**.

Ese bloque es la única entrada de `argumentos/kernel/pendientes.json` con
`book_key` vacío:

```json
{"claim_id": "C.unnamed.example.160", "book_key": "",
 "reason_code": "SEMANTIC_MAPPING_UNRESOLVED",
 "fuente": "capitulos/cap04_herramientas.typ (sin key)",
 "impacto": "Sin clave", "proxima_accion": "Asignar clave"}
```

Texto del libro (`cap04_herramientas.typ:184-190`):

> Si `SampleSpace = RR^n` con la `sigma`-álgebra de Borel, entonces toda función
> continua es medible. En la práctica del curso, asumiremos que todos los
> estadísticos de interés son medibles; la definición formal permite definir su
> distribución; para una esperanza finita se necesita además integrabilidad.

El ejemplo tiene tres contenidos, y el módulo prueba los tres:

1. **Continuidad ⇒ medibilidad Borel** en `ℝⁿ` (§1), con los dos estadísticos
   que el libro usa de verdad (media y varianza muestral) como casos concretos,
   y con la lectura «`{x : f x ∈ B}` es un evento».
2. **«Definir su distribución»** (§2): la ley imagen `μ.map T` es una medida, es
   de probabilidad si lo es la de los datos, su masa sobre `B` es `μ (T ⁻¹' B)`,
   queda determinada por esas masas, y la esperanza se transporta a ella.
3. **«Para una esperanza finita se necesita además integrabilidad»** (§3): la
   esperanza es finita exactamente cuando `T` es integrable; la medibilidad
   **no** basta (contraejemplo explícito `medible_no_implica_integrable`); y la
   acotación sí es suficiente, con `‖∫ T dμ‖ ≤ C` (§4, caso numérico).

## Fidelidad declarada

* `SampleSpace = RR^n` se formaliza como `Fin n → ℝ` con su σ-álgebra de Borel
  (`BorelSpace`), que es la misma σ-álgebra que la de `EuclideanSpace ℝ (Fin n)`.
  No se formalizan espacios muestrales arbitrarios ni `n = ∞`.
* «Toda función continua es medible» se prueba en la forma general
  `Continuous f → Measurable f` y se instancia a `Fin n → ℝ` y a los dos
  estadísticos del curso. La frase «en la práctica del curso asumiremos que
  todos los estadísticos de interés son medibles» es una convención, no un
  teorema: se sustituye por sus casos concretos.
* «Definir su distribución» se formaliza como la medida imagen `μ.map T`
  (existencia, masa sobre conjuntos medibles, determinación por las masas y
  transporte de la integral). No se construye el espacio de probabilidad
  ambiente ni se prueba la existencia de una variable aleatoria con ley
  prescrita.
* «Esperanza finita» se formaliza como `Integrable T μ`; el contraejemplo
  (`f ≡ 1` sobre `(ℝ, volume)`: continua, medible, no integrable) es el
  contenido exacto de «se necesita *además* integrabilidad» y no se solapa con
  `ex:appE-l2` (que trata de la estructura de Hilbert de `L²(P)`).
* `T` no depende del parámetro: es estructural (`T : Ω → ℝ` fijo), como en
  `def:ch1-estadistico`.

Ninguna declaración queda aplazada; auditoría de axiomas en `axiomas.log`
(todas dependen sólo de `propext`, `Classical.choice`, `Quot.sound`).
-/

open MeasureTheory
open scoped ENNReal

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

namespace Book.Cap04MedibleIntuicionM10

/-! ## 1. Continuidad ⇒ medibilidad (Borel) en `ℝⁿ` -/

section Continuidad

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Toda función continua entre espacios con σ-álgebra de Borel es medible.** Es la
primera frase del ejemplo en su forma general: la σ-álgebra de Borel está
generada por los abiertos, y la continuidad dice que la preimagen de un abierto
es un abierto, luego medible.

Fidelidad declarada: se pide `OpensMeasurableSpace` en el dominio y `BorelSpace`
en el codominio, que es exactamente «σ-álgebra de Borel»; el libro sólo usa
`SampleSpace = RR^n` y codominio `RR`. -/
theorem medible_continua {α β : Type*} [TopologicalSpace α] [MeasurableSpace α]
    [OpensMeasurableSpace α] [TopologicalSpace β] [MeasurableSpace β] [BorelSpace β]
    {f : α → β} (hf : Continuous f) : Measurable f :=
  hf.measurable

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Con `SampleSpace = RR^n` y la σ-álgebra de Borel, toda función continua
`RR^n → RR^m` es medible** (caso concreto de la primera frase del ejemplo). -/
theorem medible_continua_reales {n m : ℕ} {f : (Fin n → ℝ) → (Fin m → ℝ)}
    (hf : Continuous f) : Measurable f :=
  medible_continua hf

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**`{x : f x ∈ B}` es un evento** para `f` continua y `B` Boreliano: la definición
de medibilidad es exactamente que las preimágenes de conjuntos «razonables» sean
medibles, y por eso se les puede calcular probabilidad. -/
theorem preimagen_borel_medible {n : ℕ} {f : (Fin n → ℝ) → ℝ} (hf : Continuous f)
    {B : Set ℝ} (hB : MeasurableSet B) : MeasurableSet (f ⁻¹' B) :=
  medible_continua (α := Fin n → ℝ) (β := ℝ) hf hB

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La media muestral es medible.** `T(x) = (∑ i, x i)/n` depende continuamente de
los datos, luego es medible; es el primer estadístico concreto que el libro
necesita de la primera frase, y no depende de ningún parámetro. -/
theorem medible_media_muestral (n : ℕ) :
    Measurable fun x : Fin n → ℝ => (∑ i, x i) / (n : ℝ) :=
  (by fun_prop : Continuous fun x : Fin n → ℝ => (∑ i, x i) / (n : ℝ)).measurable

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La varianza muestral es medible.** `S²(x) = (∑ i, (x i − x̄)²)/(n−1)` es una
suma de cuadrados de funciones continuas dividida por una constante, luego
continua y por tanto medible. Con `n = 1` el denominador es `0`, pero la
continuidad —y con ella la medibilidad— no se ve afectada. -/
theorem medible_varianza_muestral (n : ℕ) :
    Measurable fun x : Fin n → ℝ => (∑ i, (x i - (∑ j, x j) / (n : ℝ)) ^ 2) / ((n : ℝ) - 1) :=
  (by fun_prop : Continuous fun x : Fin n → ℝ =>
      (∑ i, (x i - (∑ j, x j) / (n : ℝ)) ^ 2) / ((n : ℝ) - 1)).measurable

end Continuidad

/-! ## 2. «La definición formal permite definir su distribución» -/

section Distribucion

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La ley de un estadístico es una probabilidad.** Si `μ` es la ley de los datos y
`T` es medible, la imagen directa `μ.map T` es una medida de probabilidad: eso es
«definir su distribución», y es donde entra la medibilidad (sin ella `map` no
sería la ley de nada).

Fidelidad declarada: la distribución se formaliza como medida imagen
(`Measure.map`); no se construye el espacio de probabilidad ambiente. -/
theorem ley_es_probabilidad (μ : Measure Ω) [IsProbabilityMeasure μ] {T : Ω → ℝ}
    (hT : Measurable T) : IsProbabilityMeasure (μ.map T) :=
  (Measure.isProbabilityMeasure_map_iff hT.aemeasurable).2 ‹IsProbabilityMeasure μ›

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Masa de la ley sobre un Boreliano:** `(μ.map T)(B) = μ (T ⁻¹' B)`. Las
probabilidades de `{T ∈ B}` se leen en la ley de los datos; es la propiedad que
identifica la distribución del estadístico. -/
theorem ley_apply (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) {B : Set ℝ}
    (hB : MeasurableSet B) : μ.map T B = μ (T ⁻¹' B) :=
  Measure.map_apply hT hB

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La distribución queda determinada por sus masas.** Dos medidas sobre `ℝ` que
coinciden sobre todos los Borelianos son iguales; junto con `ley_apply`, esto
dice que `B ↦ μ (T ⁻¹' B)` define un único objeto: la distribución de `T`. -/
theorem ley_ext {ν₁ ν₂ : Measure ℝ} (h : ∀ B : Set ℝ, MeasurableSet B → ν₁ B = ν₂ B) :
    ν₁ = ν₂ :=
  Measure.ext h

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Transporte de la esperanza a la ley del estadístico:**
`∫ y d(μ.map T) = ∫ T dμ`. La esperanza del estadístico se calcula integrando la
identidad frente a su distribución.

Fidelidad declarada: la identidad de Bochner vale para `T` medible sin pedir
integrabilidad (si falta, ambos lados son `0` basura); la finitud la aporta
`esperanza_finita_iff_integrable`, que es justo la distinción que el libro
subraya. -/
theorem esperanza_transporte (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) :
    ∫ y, y ∂(μ.map T) = ∫ x, T x ∂μ :=
  integral_map hT.aemeasurable aestronglyMeasurable_id

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La integrabilidad se transporta a la ley y vuelve:** `Integrable id (μ.map T)`
es equivalente a `Integrable T μ`; la identidad de la ley no crea ni destruye
finitud de esperanza. -/
theorem integrable_transportado_iff (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) :
    Integrable (fun y : ℝ => y) (μ.map T) ↔ Integrable T μ :=
  integrable_map_measure aestronglyMeasurable_id hT.aemeasurable

end Distribucion

/-! ## 3. «Para una esperanza finita se necesita además integrabilidad» -/

section Esperanza

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La esperanza es finita exactamente cuando el estadístico es integrable:**
`Integrable T μ ↔ ∫⁻ ‖T‖ dμ < ∞`. La medibilidad es una hipótesis estructural
(se usa para que el lado derecho sea la integral de una función medible); la
finitud es la condición adicional que el libro pide aparte. -/
theorem esperanza_finita_iff_integrable (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) :
    Integrable T μ ↔ (∫⁻ x, ENNReal.ofReal ‖T x‖ ∂μ) < ∞ := by
  constructor
  · intro h
    exact (hasFiniteIntegral_iff_norm T).1 h.2
  · intro h
    exact ⟨hT.aestronglyMeasurable, (hasFiniteIntegral_iff_norm T).2 h⟩

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Sin integrabilidad, el momento absoluto de la ley del estadístico es
infinito:** si `T` es medible pero no integrable, `∫⁻ |y| d(μ.map T) = ⊤`. Es la
forma en que la falta de integrabilidad se ve en la distribución y no en los
datos. -/
theorem momento_infinito_sin_integrable (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T)
    (h : ¬ Integrable T μ) : ∫⁻ y, ENNReal.ofReal ‖y‖ ∂(μ.map T) = ⊤ := by
  rw [lintegral_map (by fun_prop : Measurable fun y : ℝ => ENNReal.ofReal ‖y‖) hT]
  by_contra hne
  exact h ((esperanza_finita_iff_integrable μ hT).2 (lt_top_iff_ne_top.2 hne))

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La medibilidad, por sí sola, no da una esperanza finita** (contraejemplo
explícito). `f ≡ 1` sobre `(ℝ, volume)` es continua —luego medible por §1— pero
no es integrable: su momento absoluto es `volume univ = ∞`. Es el contenido
literal de «para una esperanza finita se necesita *además* integrabilidad».

Fidelidad declarada: el espacio `(ℝ, volume)` no es de probabilidad; el
contraejemplo se da sobre un espacio de masa infinita porque el enunciado del
libro es sobre la *definición* de esperanza finita (integrabilidad frente a una
medida dada). Sobre un espacio de probabilidad la condición suficiente análoga
es `integrable_of_acotado`. -/
theorem uno_no_integrable_volume : ¬ Integrable (fun _ : ℝ => (1 : ℝ)) volume := by
  rw [integrable_const_iff]
  rintro (h | h)
  · norm_num at h
  · rw [isFiniteMeasure_iff, Real.volume_univ] at h
    exact lt_irrefl ⊤ h

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Existe una función continua y medible que no es integrable:** el contraejemplo
de `uno_no_integrable_volume`, empaquetado. La definición formal de medibilidad
(§1) es estrictamente más débil que la integrabilidad. -/
theorem medible_no_implica_integrable :
    ∃ f : ℝ → ℝ, Continuous f ∧ Measurable f ∧ ¬ Integrable f volume :=
  ⟨fun _ => 1, continuous_const, measurable_const, uno_no_integrable_volume⟩

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Un estadístico acotado sí es integrable** (condición suficiente de la tercera
frase). Si `‖T‖ ≤ C` sobre todo el espacio muestral y la ley de los datos es
finita, entonces `T` es integrable y su esperanza es un número real.

Fidelidad declarada: se pide `[IsFiniteMeasure μ]` (bastan medidas finitas; el
libro trabaja con probabilidades) y la cota determinista `∀ x, ‖T x‖ ≤ C`. -/
theorem integrable_of_acotado (μ : Measure Ω) [IsFiniteMeasure μ] {T : Ω → ℝ}
    (hT : Measurable T) {C : ℝ} (hC : ∀ x, ‖T x‖ ≤ C) : Integrable T μ :=
  ⟨hT.aestronglyMeasurable, HasFiniteIntegral.of_bounded (ae_of_all μ hC)⟩

end Esperanza

/-! ## 4. La esperanza acotada y un caso numérico completo -/

section Concreto

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La esperanza de un estadístico acotado está controlada por su cota:**
`‖∫ T dμ‖ ≤ C` cuando `μ` es una probabilidad y `‖T‖ ≤ C`; la integrabilidad no
sólo hace finita la esperanza, sino que la domina por el recorrido del
estadístico. -/
theorem esperanza_acotada (μ : Measure Ω) [IsProbabilityMeasure μ] {T : Ω → ℝ}
    {C : ℝ} (hC : ∀ x, ‖T x‖ ≤ C) : ‖∫ x, T x ∂μ‖ ≤ C := by
  have h := norm_integral_le_of_norm_le_const (μ := μ) (f := T) (C := C) (ae_of_all μ hC)
  simpa using h

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Instancia completa del ejemplo con `n = 2` y datos degenerados en
`(1/4, 3/4)`:** la media muestral `T(x) = (x₀+x₁)/2` es continua (bloque 1), su
ley bajo `δ_{(1/4,3/4)}` es `δ_{1/2}` (bloque 2, «definir su distribución») y esa
ley tiene una esperanza finita, `1/2` (bloque 3). -/
theorem ley_media_dos_puntos :
    (Measure.dirac (fun i : Fin 2 => if i = 0 then (1 / 4 : ℝ) else 3 / 4)).map
        (fun x : Fin 2 → ℝ => (∑ i, x i) / 2) = Measure.dirac (1 / 2) := by
  simp [Fin.sum_univ_two]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La esperanza de la ley anterior vale `1/2`**, que es el valor de la media
muestral sobre los datos: `∫ y d(δ_{1/2}) = 1/2`. Cierra la instancia numérica. -/
theorem esperanza_media_dos_puntos :
    ∫ y, y ∂((Measure.dirac (fun i : Fin 2 => if i = 0 then (1 / 4 : ℝ) else 3 / 4)).map
        (fun x : Fin 2 → ℝ => (∑ i, x i) / 2)) = 1 / 2 := by
  rw [ley_media_dos_puntos]
  simp

end Concreto

end Book.Cap04MedibleIntuicionM10
