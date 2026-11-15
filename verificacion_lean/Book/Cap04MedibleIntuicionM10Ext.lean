import Book.Cap04MedibleIntuicionM10

/-!
# Book.Cap04MedibleIntuicionM10Ext — prolongación del ejemplo `ex:ch1-medible-intuicion`

Extensión del módulo `Book/Cap04MedibleIntuicionM10.lean`, que formaliza el ejemplo
sin clave de `capitulos/cap04_herramientas.typ:184` (anidado en
`def:medible-operativa`). Este módulo **no sustituye** al original: añade cuatro
contenidos que el original deja implícitos y que son, literalmente, la operación
que el texto del libro describe.

## Qué añade

* **§0 σ-álgebra de Borel.** El libro dice «`SampleSpace = RR^n` con la
  σ-álgebra de Borel». Aquí se prueba que la instancia de `Fin n → ℝ` usada por
  el módulo base *es* la de Borel, y que el criterio del libro —«la preimagen de
  un abierto es un abierto»— basta para producir eventos.
* **§1 Finitud leída en la ley.** El módulo base prueba
  `Integrable T μ ↔ ∫⁻ ‖T‖ dμ < ∞` (en los datos) y, por separado, que sin
  integrabilidad el momento absoluto *de la ley* es `⊤`. Faltaba la identidad de
  transporte que une ambas cosas y el criterio simétrico leído en la ley.
* **§1b La ley para un codominio arbitrario.** El libro no especifica `cal(T)`.
  La ley imagen, su fórmula de masa y el transporte de esperanzas de funciones del
  estadístico se prueban aquí para `T : Ω → β` con `β` un espacio medible
  cualquiera; sólo el momento `‖·‖` (que necesita estructura métrica) queda en `ℝ`.
* **§2 «Definir su distribución» de verdad.** El módulo base transporta sólo la
  identidad (`∫ y d(μ.map T) = ∫ T dμ`). El contenido operativo de «definir la
  distribución» es más fuerte: la ley permite calcular *cualquier* esperanza de
  una función del estadístico, y la ley de `g(T)` es la imagen de la ley de `T`.
* **§3 La convención del curso, operativa.** «Asumiremos que todos los
  estadísticos de interés son medibles» no es un teorema: es la clausura de la
  clase de estadísticos bajo post-proceso continuo y bajo operaciones medibles.
  Aquí se prueban los casos que el curso usa (una y dos estadísticos, y la
  composición de leyes), sin afirmar nada sobre un estadístico arbitrario.
* **§4 Dónde está el límite del contraejemplo.** El contraejemplo del módulo
  base vive en `(ℝ, volume)`, que no es un espacio de probabilidad. Se prueba que
  el estadístico constante `1` es integrable **si y sólo si** la medida ambiente
  es finita, de modo que ese camino no puede dar un contraejemplo en un espacio
  de probabilidad; todo estadístico acotado y medible es integrable. Construir el
  contraejemplo en un espacio de probabilidad exige un estadístico **no acotado**
  y una integral divergente explícita, que **este módulo no formaliza**.
* **§4b El contraejemplo en un espacio de probabilidad** (§4b): el módulo base
  sólo exhibía un estadístico medible y no integrable sobre `(ℝ, volume)`, que no
  es un espacio de probabilidad. Aquí se da uno sobre `volume ↾ (0,1)` —masa
  total `1`— con `T x = 1/x` y momento absoluto de la ley `= ⊤`.
* **§5 Supuestos ambiente.** `A.medible-borel` y `A.probabilidad-datos` se
  registran como *campos* de una estructura: son hipótesis que todo consumidor
  recibe como argumento, no teoremas que se prueben aquí ni en el módulo base.

## Fidelidad declarada

* No se formalizan espacios muestrales arbitrarios ni `n = ∞`; `SampleSpace` es
  `Fin n → ℝ` con su σ-álgebra de Borel (§0 lo hace explícito).
* El codominio del estadístico sigue siendo `ℝ` (o `ℝ` a la `m` para la
  medibilidad). `cal(T)` no está especificado en el libro.
* «La distribución» es `Measure.map`; no se construye una variable aleatoria con
  ley prescrita ni se prueba el teorema de extensión de Kolmogorov.
* `g` en §2 es medible y real; `g` en §3 es continuo. No se afirma la
  medibilidad de un estadístico arbitrario: eso es convención, no teorema.
-/

open MeasureTheory Set

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

namespace Book.Cap04MedibleIntuicionM10Ext

/-! ## 0. La σ-álgebra del espacio muestral es la de Borel -/

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La σ-álgebra de `Fin n → ℝ` es la de Borel.** El libro dice «`SampleSpace =
RR^n` con la σ-álgebra de Borel»; esta igualdad es lo que hace que los enunciados
del módulo base sean enunciados sobre ese espacio y no sobre una σ-álgebra
elegida *ad hoc*. -/
theorem espacio_muestral_borel (n : ℕ) :
    (inferInstance : MeasurableSpace (Fin n → ℝ)) = borel (Fin n → ℝ) :=
  BorelSpace.measurable_eq

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Los abiertos de `RR^n` son eventos.** Es la mitad «con la σ-álgebra de Borel» de
la primera frase: sin esto no hay nada a lo que aplicar continuidad. -/
theorem abierto_es_evento {n : ℕ} {s : Set (Fin n → ℝ)} (hs : IsOpen s) : MeasurableSet s :=
  hs.measurableSet

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La preimagen de un abierto por una función continua es un evento.** Es el paso
concreto con el que el libro justifica «toda función continua es medible»: la
preimagen de un abierto es un abierto, y los abiertos son eventos.

Fidelidad declarada: se prueba el caso `RR^n → RR^m` del libro; el caso general
`Continuous → Measurable` ya está en el módulo base (`medible_continua`). -/
theorem preimagen_abierto_es_evento {n m : ℕ} {f : (Fin n → ℝ) → (Fin m → ℝ)}
    (hf : Continuous f) {U : Set (Fin m → ℝ)} (hU : IsOpen U) : MeasurableSet (f ⁻¹' U) :=
  (hU.measurableSet).preimage hf.measurable

/-! ## 1. Transporte de momentos y finitud leída en la ley -/

section Momentos

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**El momento absoluto se transporta a la ley:** `∫⁻ |y| d(μ.map T) = ∫⁻ |T| dμ`.
Es la identidad que falta entre `esperanza_finita_iff_integrable` (criterio en los
datos) y `momento_infinito_sin_integrable` (el caso `⊤` leído en la ley). -/
theorem momento_ley_transporte (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) :
    ∫⁻ y, ENNReal.ofReal ‖y‖ ∂(μ.map T) = ∫⁻ x, ENNReal.ofReal ‖T x‖ ∂μ :=
  lintegral_map (by fun_prop : Measurable fun y : ℝ => ENNReal.ofReal ‖y‖) hT

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La esperanza es finita exactamente cuando el momento absoluto de la ley lo es.**
El criterio de integrabilidad del módulo base, leído enteramente en la
distribución del estadístico: «para una esperanza finita se necesita además
integrabilidad» no depende de cómo se escriba la ley. -/
theorem integrable_iff_momento_ley_finito (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T) :
    Integrable T μ ↔ ∫⁻ y, ENNReal.ofReal ‖y‖ ∂(μ.map T) < ⊤ := by
  rw [momento_ley_transporte μ hT]
  exact Book.Cap04MedibleIntuicionM10.esperanza_finita_iff_integrable μ hT

end Momentos

/-! ## 1b. La ley para un codominio arbitrario `cal(T)` -/

section CalT

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La ley existe para cualquier codominio medible.** El libro deja `cal(T)` sin
especificar; esta forma general muestra que «definir su distribución» no depende
de que el estadístico sea real: si `μ` es la ley de los datos y `T : Ω → β` es
medible, la imagen `μ.map T` es una probabilidad sobre `β`. -/
theorem ley_es_probabilidad_calT {β : Type*} [MeasurableSpace β] (μ : Measure Ω)
    [IsProbabilityMeasure μ] {T : Ω → β} (hT : Measurable T) :
    IsProbabilityMeasure (μ.map T) :=
  (Measure.isProbabilityMeasure_map_iff hT.aemeasurable).2 ‹IsProbabilityMeasure μ›

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La masa de la ley sobre un medible de `cal(T)`**, para codominio arbitrario:
`(μ.map T) B = μ (T ⁻¹' B)`. Es la identificación que permite calcular
probabilidades del estadístico en los datos. -/
theorem ley_apply_calT {β : Type*} [MeasurableSpace β] (μ : Measure Ω) {T : Ω → β}
    (hT : Measurable T) {B : Set β} (hB : MeasurableSet B) : μ.map T B = μ (T ⁻¹' B) :=
  Measure.map_apply hT hB

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Transporte de esperanzas de funciones del estadístico, con codominio
arbitrario:** `∫ g d(μ.map T) = ∫ (g ∘ T) dμ` para `g : cal(T) → ℝ` medible. -/
theorem esperanza_funcion_del_estadistico_calT {β : Type*} [MeasurableSpace β] (μ : Measure Ω)
    {T : Ω → β} (hT : Measurable T) {g : β → ℝ} (hg : Measurable g) :
    ∫ y, g y ∂(μ.map T) = ∫ x, g (T x) ∂μ :=
  integral_map hT.aemeasurable hg.aestronglyMeasurable

end CalT

/-! ## 2. «Definir su distribución»: la ley sirve para integrar funciones del estadístico -/

section Ley

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La ley permite calcular cualquier esperanza de una función del estadístico:**
`∫ g d(μ.map T) = ∫ (g ∘ T) dμ`. El módulo base sólo prueba el caso `g = id`;
éste es el contenido operativo de «la definición formal permite definir su
distribución», porque es lo que se usa al calcular un estimador a partir de su
distribución. -/
theorem esperanza_funcion_del_estadistico (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T)
    {g : ℝ → ℝ} (hg : Measurable g) :
    ∫ y, g y ∂(μ.map T) = ∫ x, g (T x) ∂μ :=
  esperanza_funcion_del_estadistico_calT μ hT hg

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La ley de `g(T)` es la imagen de la ley de `T`:** `(μ.map T).map g = μ.map (g ∘ T)`.
Es la otra mitad de «definir su distribución»: aplicar una transformación al
estadístico transforma su ley de la misma manera. -/
theorem ley_composicion {β : Type*} [MeasurableSpace β] (μ : Measure Ω) {T : Ω → ℝ}
    (hT : Measurable T) {g : ℝ → β} (hg : Measurable g) :
    (μ.map T).map g = μ.map fun x => g (T x) :=
  Measure.map_map hg hT

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Caso continuo de la composición de leyes**, que es el que el curso usa: si `T` es
medible y `g` continua, `g(T)` es un estadístico y su ley es la imagen de la ley
de `T`. -/
theorem ley_composicion_continua (μ : Measure Ω) {T : Ω → ℝ} (hT : Measurable T)
    {g : ℝ → ℝ} (hg : Continuous g) :
    (μ.map T).map g = μ.map fun x => g (T x) :=
  ley_composicion μ hT hg.measurable

end Ley

/-! ## 3. La convención «todos los estadísticos de interés son medibles», operativa -/

section Clausura

variable {α : Type*} [TopologicalSpace α] [MeasurableSpace α] [OpensMeasurableSpace α]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Clausura bajo post-proceso continuo.** Si `T` es un estadístico medible y `g` es
continua, `g ∘ T` es medible. Esto es lo que la convención «asumiremos que todos
los estadísticos de interés son medibles» aporta en la práctica: no que un
funcional arbitrario sea medible, sino que las transformaciones continuas de un
estadístico medible lo siguen siendo. -/
theorem medible_comp_continua {T : α → ℝ} (hT : Measurable T) {g : ℝ → ℝ} (hg : Continuous g) :
    Measurable fun x => g (T x) :=
  hg.measurable.comp hT

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Clausura bajo una función continua de dos estadísticos.** Con dos estadísticos
medibles `S` y `T` y `g : ℝ × ℝ → ℝ` continua, `x ↦ g (S x, T x)` es medible: es
el caso con el que se construyen, por ejemplo, cocientes y contrastes. -/
theorem medible_dos_estadisticos {S T : α → ℝ} (hS : Measurable S) (hT : Measurable T)
    {g : ℝ × ℝ → ℝ} (hg : Continuous g) : Measurable fun x => g (S x, T x) :=
  hg.measurable.comp (hS.prod hT)

end Clausura

/-! ## 4. La acotación y el límite del contraejemplo -/

section Acotacion

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**El estadístico constante `1` es integrable si y sólo si la medida ambiente es
finita.** Consecuencia precisa del contraejemplo del módulo base
(`uno_no_integrable_volume`): la no integrabilidad de la constante `1` sobre
`(ℝ, volume)` no es un defecto del estadístico sino de la masa infinita. Por eso
ese contraejemplo **no** se transporta a un espacio de probabilidad y el
contraejemplo probabilístico exigiría un estadístico no acotado. -/
theorem integrable_const_uno_iff_finita (μ : Measure Ω) :
    Integrable (fun _ : Ω => (1 : ℝ)) μ ↔ IsFiniteMeasure μ := by
  rw [integrable_const_iff]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**En un espacio de probabilidad todo estadístico medible y acotado es
integrable.** Es la razón por la que el contraejemplo de «medibilidad no implica
esperanza finita» tiene que usar un estadístico no acotado; se registra la
especialización al espacio de probabilidad de A.probabilidad-datos. -/
theorem integrable_acotado_probabilidad (μ : Measure Ω) [IsProbabilityMeasure μ] {T : Ω → ℝ}
    (hT : Measurable T) {C : ℝ} (hC : ∀ x, ‖T x‖ ≤ C) : Integrable T μ :=
  Book.Cap04MedibleIntuicionM10.integrable_of_acotado μ hT hC

end Acotacion

/-! ## 4b. El contraejemplo en un espacio de probabilidad -/

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**La medibilidad, por sí sola, tampoco da esperanza finita en un espacio de
probabilidad.** El contraejemplo del módulo base vive en `(ℝ, volume)`, que no es
un espacio de probabilidad; éste cierra esa laguna de fidelidad con
`Ω = (0,1) ⊆ ℝ` (el caso `n = 1` de `RR^n`), `μ = volume ↾ (0,1)` —masa total `1`,
luego una medida de probabilidad— y el estadístico `T(x) = 1/x`, medible por ser
la inversión. Su momento absoluto diverge: `x⁻¹` no es integrable en `(0,1)`
porque el exponente `-1` no satisface `-1 < s`. La segunda conclusión da la misma
divergencia leída en la ley del estadístico.

Fidelidad declarada: `μ` es la restricción de Lebesgue a `(0,1)`; se usa `volume`
sobre `ℝ` como espacio muestral (`Fin 1 → ℝ` es `ℝ`). El estadístico es no
acotado, como debe ser por `integrable_acotado_probabilidad`. -/
theorem medible_no_implica_integrable_probabilidad :
    ∃ (μ : Measure ℝ) (_ : IsProbabilityMeasure μ) (T : ℝ → ℝ),
      Measurable T ∧ ¬ Integrable T μ ∧
        ∫⁻ y, ENNReal.ofReal ‖y‖ ∂(μ.map T) = ⊤ := by
  have hno : ¬ Integrable (fun x : ℝ => x⁻¹) ((volume : Measure ℝ).restrict (Ioo 0 1)) := by
    intro h
    have h' : IntegrableOn (fun x : ℝ => x ^ (-1 : ℝ)) (Ioo 0 1) volume := by
      refine h.congr ?_
      filter_upwards [ae_restrict_mem measurableSet_Ioo] with x hx
      exact (Real.rpow_neg_one x).symm
    rw [intervalIntegral.integrableOn_Ioo_rpow_iff zero_lt_one] at h'
    norm_num at h'
  refine ⟨(volume : Measure ℝ).restrict (Ioo 0 1), ⟨?hprob⟩, fun x => x⁻¹, measurable_inv, hno,
    Book.Cap04MedibleIntuicionM10.momento_infinito_sin_integrable _ measurable_inv hno⟩
  case hprob =>
    rw [Measure.restrict_apply_univ, Real.volume_Ioo]
    norm_num

/-! ## 5. Los dos supuestos ambiente, como hipótesis y no como teoremas -/

/-- Registro explícito de los supuestos ambiente `A.probabilidad-datos` (la ley de
los datos es una probabilidad) y `A.medible-borel` (el estadístico es medible,
independiente del parámetro). No es un teorema: es un paquete de hipótesis. Todo
enunciado que los necesite los recibe como argumento, de modo que ninguna
afirmación del kernel queda condicionada a un supuesto que aquí se dé por
demostrado. -/
structure SupuestosAmbiente (Ω : Type*) [MeasurableSpace Ω] where
  /-- `A.probabilidad-datos`: la ley de los datos. -/
  μ : Measure Ω
  /-- `A.probabilidad-datos`: es una medida de probabilidad. -/
  esProbabilidad : IsProbabilityMeasure μ
  /-- El estadístico, estructural e independiente del parámetro. -/
  T : Ω → ℝ
  /-- `A.medible-borel`: el estadístico es medible. -/
  medible : Measurable T

section Ambiente

variable {Ω : Type*} [MeasurableSpace Ω]

/-- book: capitulos/cap04_herramientas.typ:184 (key: ex:ch1-medible-intuicion) —
**Bajo los dos supuestos ambiente, la ley del estadístico es una probabilidad y la
masa se lee en los datos.** Se enuncian juntas las dos propiedades que el ejemplo
del libro atribuye a «definir su distribución», mostrando que ambas consumen
`A.probabilidad-datos` y `A.medible-borel` como hipótesis. -/
theorem ley_bajo_supuestos_ambiente (D : SupuestosAmbiente Ω) :
    IsProbabilityMeasure (D.μ.map D.T) ∧
      ∀ ⦃B : Set ℝ⦄, MeasurableSet B → (D.μ.map D.T) B = D.μ (D.T ⁻¹' B) :=
  ⟨@Book.Cap04MedibleIntuicionM10.ley_es_probabilidad Ω _ D.μ D.esProbabilidad D.T D.medible,
    fun _ hB => Book.Cap04MedibleIntuicionM10.ley_apply D.μ D.medible hB⟩

end Ambiente

end Book.Cap04MedibleIntuicionM10Ext
