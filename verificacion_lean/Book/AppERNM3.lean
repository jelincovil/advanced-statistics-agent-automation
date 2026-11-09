import Mathlib

/-!
# Apéndice E — Teorema de Radon–Nikodym (`thm:appE-radon-nikodym`)

Formalización de `apendices/apendice_medido.typ` del libro *Inferencia
Estadística*, clave `thm:appE-radon-nikodym` (la clave está en la línea 85 del
`.typ` de la instantánea fijada en `argumentos/inventory/libro.json`, sha256
`277929c3…df0d7`; el número 173 del enunciado del enjambre no es una línea de
ese archivo).

El libro enuncia:

> Sea `μ` una medida σ-finita y `P` una probabilidad con `P ≪ μ`. Existe una
> función medible no negativa `f`, finita `μ`-casi en todas partes y única salvo
> conjuntos `μ`-nulos, tal que `P(A) = ∫_A f dμ` para todo conjunto medible `A`.
> Se escribe `f = dP/dμ`. La hipótesis sobre la medida dominante es parte del
> resultado; la continuidad absoluta sola no basta para una medida arbitraria.

## Qué se demuestra aquí (0 `sorry`)

* `appE_rn_existe_unico` — **el enunciado completo**: existencia de `f ≥ 0`
  medible, finita `μ`-c.a.e., con `P(A) = ∫_A f dμ` para todo `A` medible, y
  unicidad salvo conjuntos `μ`-nulos frente a *cualquier* otra `g` que cumpla la
  misma identidad de integrales. Es el ancla elegida.
* `appE_rn_ac_iff` — la forma compacta: `P ≪ μ ↔ ∃ f, P = μ.withDensity f`.
* `appE_rn_medible`, `appE_rn_finita_a_e`, `appE_rn_identidad`,
  `appE_rn_es_derivada`, `appE_rn_integral_uno`, `appE_rn_integral_uno_toReal`,
  `appE_rn_integrable`, `appE_rn_positiva`: los ingredientes por separado
  (medibilidad, finitud c.a.e., identidad de integrales, la derivada
  `P.rnDeriv μ`, masa total `1`, integrabilidad de `(dP/dμ).toReal`,
  positividad `P`-c.a.e.).
* `appE_rn_unico`, `appE_rn_unicidad_no_puntual` — la unicidad es **sólo**
  c.a.e.: dos densidades medibles de la misma `P` coinciden `μ`-c.a.e., pero hay
  dos funciones medibles *distintas* que son densidades de la misma medida, de
  modo que no puede haber unicidad puntual.
* `appE_rn_fundamental`, `appE_rn_cadena`, `appE_rn_modelo` — consistencia de
  `dP/dμ`: derivar una medida con densidad devuelve la densidad
  (`(μ.withDensity f).rnDeriv μ =ᵐ[μ] f`), regla de la cadena
  `(dξ/dν)(dν/dκ) = dξ/dκ`, y —el punto que al libro le importa— la densidad
  `p_θ` de un modelo dominado `P_θ = p_θ·μ` **es** `dP_θ/dμ`.
* `appE_rn_uniforme`, `appE_rn_uniforme_probabilidad` — instancia concreta:
  la ley uniforme en `[0,1]` es una probabilidad de densidad `1_{[0,1]}`
  respecto de Lebesgue.
* `appE_rn_hipotesis_sigma_finita_necesaria` (con `appE_rn_ac_count`,
  `appE_rn_densidad_count_inexistente`, `appE_count_no_sigmaFinite`) — **la
  segunda parte del enunciado**: la σ-finitud de la dominante es
  indispensable. Se exhibe una *probabilidad* `P` (la uniforme en `[0,1]`) y una
  medida `μ` (la medida de contar en `ℝ`) con `P ≪ μ` para la que **no existe**
  densidad `f` con `P = μ.withDensity f`; y se prueba que `μ` no es σ-finita.
  La continuidad absoluta sola no basta.

## Fidelidad declarada

* `μ` σ-finita y `P` probabilidad entran como instancias de tipo
  (`[SigmaFinite μ]`, `[IsProbabilityMeasure P]`). No se añade ninguna otra
  hipótesis: en particular no se pide que `P` sea σ-finita por separado (se
  deduce) ni que las densidades sean continuas.
* «No negativa» es el codominio `ℝ≥0∞`; «finita `μ`-c.a.e.» se prueba como
  `∀ᵐ x ∂μ, f x < ∞`, no se postula.
* «Única salvo conjuntos `μ`-nulos» se formaliza como igualdad `μ`-c.a.e.
  **frente a toda** `g` medible que satisfaga la identidad de integrales;
  además se muestra con un ejemplo que la unicidad puntual es falsa.
* El paquete de Mathlib que se usa es el teorema de Radon–Nikodym ya probado en
  `Mathlib.MeasureTheory.Measure.Decomposition.RadonNikodym`
  (`Measure.withDensity_rnDeriv_eq`,
  `Measure.absolutelyContinuous_iff_withDensity_rnDeriv_eq`), no una
  suposición: aquí no se postula la existencia de la densidad, se deriva de la
  descomposición de Lebesgue de Mathlib y se empaqueta en la forma exacta del
  libro.
* La parte negativa («la continuidad absoluta sola no basta») se formaliza con
  un contraejemplo concreto, la medida de contar en `ℝ`, que no es σ-finita.

Cada declaración compila con `lean --root=.` sobre Mathlib precompilada, sin
`sorry`, y su auditoría de axiomas está en `Book/AuditAppERN.lean`
(`axiomas.log`).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false
set_option linter.style.haveILetI false
set_option maxHeartbeats 1000000

open MeasureTheory ProbabilityTheory
open scoped ENNReal

namespace Book.AppERNM3

variable {α : Type*} {m : MeasurableSpace α}

/-! ## 1. Existencia, finitud c.a.e. e identidad de integrales -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La derivada de Radon–Nikodym `dP/dμ = P.rnDeriv μ` es **medible**. Fidelidad: es
la «función medible no negativa» del libro; la no negatividad es el codominio
`ℝ≥0∞`. -/
theorem appE_rn_medible (P μ : Measure α) : Measurable (P.rnDeriv μ) :=
  Measure.measurable_rnDeriv P μ

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
`dP/dμ` es **finita `μ`-casi en todas partes** cuando `P` es una probabilidad.
Fidelidad: el libro pide exactamente esto; usa que `P` es finita y que `μ` es
σ-finita (`Measure.rnDeriv_lt_top`). -/
theorem appE_rn_finita_a_e (P μ : Measure α) [IsProbabilityMeasure P] :
    ∀ᵐ x ∂μ, P.rnDeriv μ x < ∞ :=
  Measure.rnDeriv_lt_top P μ

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Identidad de integrales**: para todo conjunto medible `A`,
`P(A) = ∫_A (dP/dμ) dμ`. Fidelidad: es la fórmula `P(A)=integral_A f dif mu`
del libro, con `f = dP/dμ`. -/
theorem appE_rn_identidad (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) :
    ∀ A : Set α, MeasurableSet A → P A = ∫⁻ x in A, P.rnDeriv μ x ∂μ := by
  intro A hA
  exact (Measure.setLIntegral_rnDeriv' h hA).symm

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La densidad `dP/dμ` reproduce `P` como medida con densidad:
`P = μ.withDensity (dP/dμ)`. -/
theorem appE_rn_es_derivada (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) :
    μ.withDensity (P.rnDeriv μ) = P :=
  Measure.withDensity_rnDeriv_eq P μ h

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Teorema de Radon–Nikodym, enunciado del libro.** Sea `μ` σ-finita y `P` una
probabilidad con `P ≪ μ`. Entonces existe `f : α → ℝ≥0∞` medible, finita
`μ`-c.a.e., con `P(A) = ∫_A f dμ` para todo `A` medible, y `f` es única salvo
conjuntos `μ`-nulos (frente a cualquier `g` medible con la misma identidad de
integrales). Fidelidad: literal, sin hipótesis añadidas; la unicidad se prueba,
no se postula. -/
theorem appE_rn_existe_unico (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) :
    ∃ f : α → ℝ≥0∞, Measurable f ∧ (∀ᵐ x ∂μ, f x < ∞) ∧
      (∀ A : Set α, MeasurableSet A → P A = ∫⁻ x in A, f x ∂μ) ∧
      ∀ g : α → ℝ≥0∞, Measurable g →
        (∀ A : Set α, MeasurableSet A → P A = ∫⁻ x in A, g x ∂μ) → f =ᵐ[μ] g := by
  refine ⟨P.rnDeriv μ, appE_rn_medible P μ, appE_rn_finita_a_e P μ,
    appE_rn_identidad P μ h, ?_⟩
  intro g hg hgA
  have hg_dens : μ.withDensity g = P := by
    ext A hA
    rw [withDensity_apply _ hA, ← hgA A hA]
  exact (Measure.eq_rnDeriv₀ hg.aemeasurable Measure.MutuallySingular.zero_left
    (by simpa using hg_dens.symm)).symm

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Forma compacta del teorema**: para `P` probabilidad y `μ` σ-finita,
`P ≪ μ` si y sólo si `P` tiene densidad medible respecto de `μ`. Fidelidad: el
recíproco es `withDensity_absolutelyContinuous` (toda medida con densidad es
absolutamente continua) y la implicación directa es el teorema. -/
theorem appE_rn_ac_iff (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ] :
    P ≪ μ ↔ ∃ f : α → ℝ≥0∞, Measurable f ∧ P = μ.withDensity f := by
  constructor
  · intro h
    exact ⟨P.rnDeriv μ, appE_rn_medible P μ, (appE_rn_es_derivada P μ h).symm⟩
  · rintro ⟨f, -, rfl⟩
    exact withDensity_absolutelyContinuous μ f

/-! ## 2. Masa total, integrabilidad y positividad de la densidad -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La masa total de `P` es la integral de su densidad:
`∫ (dP/dμ) dμ = P(univ)`. Para una probabilidad, `= 1`: `dP/dμ` es una densidad
de probabilidad. -/
theorem appE_rn_integral_uno (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) :
    ∫⁻ x, P.rnDeriv μ x ∂μ = 1 := by
  rw [Measure.lintegral_rnDeriv h, measure_univ]

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La versión con integral de Bochner: `∫ (dP/dμ).toReal dμ = 1` para una
probabilidad `P`. -/
theorem appE_rn_integral_uno_toReal (P μ : Measure α) [IsProbabilityMeasure P]
    [SigmaFinite μ] (h : P ≪ μ) :
    ∫ x, (P.rnDeriv μ x).toReal ∂μ = 1 := by
  rw [Measure.integral_toReal_rnDeriv h]
  simp

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
`dP/dμ` es una función integrable (en el sentido de Bochner, tras `toReal`).
Fidelidad: el libro no lo pide, pero es lo que hace utilizable la densidad como
función de `L¹(μ)`; aquí se deduce, no se postula. -/
theorem appE_rn_integrable (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ] :
    Integrable (fun x => (P.rnDeriv μ x).toReal) μ := by
  have h := Measure.integrableOn_toReal_rnDeriv (μ := P) (ν := μ) (s := Set.univ)
    (by rw [measure_univ]; exact ENNReal.one_ne_top)
  simpa using h

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Positividad**: si `P ≪ μ`, entonces `dP/dμ > 0` en un conjunto de `P`-medida
total. Fidelidad: es la contrapartida de «única salvo conjuntos nulos» que el
libro usa al escribir el cociente de densidades. -/
theorem appE_rn_positiva (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) :
    ∀ᵐ x ∂P, 0 < P.rnDeriv μ x :=
  Measure.rnDeriv_pos h

/-! ## 3. Unicidad: sólo `μ`-casi en todas partes -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Unicidad c.a.e.**: dos funciones medibles que definen la misma medida con
densidad coinciden `μ`-c.a.e. -/
theorem appE_rn_unico (μ : Measure α) [SigmaFinite μ] {f g : α → ℝ≥0∞}
    (hf : Measurable f) (hg : Measurable g) (h : μ.withDensity f = μ.withDensity g) :
    f =ᵐ[μ] g :=
  (MeasureTheory.withDensity_eq_iff_of_sigmaFinite hf.aemeasurable hg.aemeasurable).mp h

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Cualquier** versión de la densidad es la derivada de Radon–Nikodym c.a.e.: si
`P = μ.withDensity f` con `f` medible y `μ` σ-finita, entonces
`f =ᵐ[μ] dP/dμ`. Es la forma precisa de «se escribe `f = dP/dμ`»: la escritura
fija la clase c.a.e. -/
theorem appE_rn_densidad_es_derivada (P μ : Measure α) [SigmaFinite μ]
    {f : α → ℝ≥0∞} (hf : Measurable f) (h : μ.withDensity f = P) :
    f =ᵐ[μ] P.rnDeriv μ :=
  Measure.eq_rnDeriv₀ hf.aemeasurable Measure.MutuallySingular.zero_left
    (by simpa using h.symm)

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**La unicidad no es puntual**: existen dos funciones medibles distintas
`f ≠ g` que son densidades de la *misma* medida respecto de Lebesgue. Se toma
`f ≡ 1` y `g = 1` salvo en `{2}`, conjunto Lebesgue-nulo. -/
theorem appE_rn_unicidad_no_puntual :
    ∃ f g : ℝ → ℝ≥0∞, Measurable f ∧ Measurable g ∧ f ≠ g ∧
      volume.withDensity f = volume.withDensity g := by
  refine ⟨1, ({2} : Set ℝ)ᶜ.indicator 1, measurable_const,
    Measurable.indicator measurable_const (measurableSet_singleton 2).compl, ?_, ?_⟩
  · intro h
    have h2 := congrFun h 2
    simp at h2
  · refine withDensity_congr_ae ?_
    have hnull : ∀ᵐ x ∂(volume : Measure ℝ), x ≠ 2 := by
      rw [MeasureTheory.ae_iff]
      simp
    filter_upwards [hnull] with x hx
    rw [Set.indicator_of_mem (Set.mem_compl_singleton_iff.mpr hx), Pi.one_apply]

/-! ## 4. Cambio de medida: integración contra la densidad -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Cambio de medida** (consecuencia de la fórmula del libro): para toda `g ≥ 0`
medible, `∫ g dP = ∫ g·(dP/dμ) dμ`. Es la identidad `P(A)=∫_A f dμ` extendida
de indicadores a funciones medibles no negativas; aquí se deduce, no se postula.
Fidelidad: el libro no la enuncia, pero es exactamente lo que hace utilizable la
densidad (esperanzas bajo `P` calculadas con `μ`). -/
theorem appE_rn_cambio_de_medida (P μ : Measure α) [IsProbabilityMeasure P] [SigmaFinite μ]
    (h : P ≪ μ) {g : α → ℝ≥0∞} (hg : AEMeasurable g μ) :
    ∫⁻ x, g x ∂P = ∫⁻ x, P.rnDeriv μ x * g x ∂μ :=
  (lintegral_rnDeriv_mul h hg).symm

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
Cambio de medida restringido a un conjunto medible `A`:
`∫_A g dP = ∫_A g·(dP/dμ) dμ`. -/
theorem appE_rn_cambio_de_medida_conjunto (P μ : Measure α) [IsProbabilityMeasure P]
    [SigmaFinite μ] (h : P ≪ μ) {g : α → ℝ≥0∞} (hg : AEMeasurable g μ)
    {A : Set α} (hA : MeasurableSet A) :
    ∫⁻ x in A, g x ∂P = ∫⁻ x in A, P.rnDeriv μ x * g x ∂μ :=
  (setLIntegral_rnDeriv_mul h hg hA).symm

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
Cambio de medida para integrales de Bochner: `∫ (dP/dμ).toReal · f dμ = ∫ f dP`.
Fidelidad: es la contrapartida real de la misma identidad; Mathlib la prueba sin
pedir integrabilidad, con la convención `∫ = 0` fuera de `L¹`. -/
theorem appE_rn_cambio_de_medida_integral (P μ : Measure α) [IsProbabilityMeasure P]
    [SigmaFinite μ] (h : P ≪ μ) {f : α → ℝ} :
    ∫ x, (P.rnDeriv μ x).toReal * f x ∂μ = ∫ x, f x ∂P :=
  integral_toReal_rnDeriv_mul h

/-! ## 5. Consistencia de la derivada: teorema fundamental y regla de la cadena -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Teorema fundamental**: la derivada de la medida con densidad `μ.withDensity f`
respecto de `μ` es `f`, `μ`-c.a.e. Es la consistencia que el libro usa al
identificar las densidades `p_θ` de un modelo dominado con `dP_θ/dμ`. -/
theorem appE_rn_fundamental (μ : Measure α) [SigmaFinite μ] {f : α → ℝ≥0∞}
    (hf : Measurable f) :
    (μ.withDensity f).rnDeriv μ =ᵐ[μ] f :=
  Measure.rnDeriv_withDensity μ hf

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Regla de la cadena**: `(dξ/dν)·(dν/dκ) = dξ/dκ` (`κ`-c.a.e.) para medidas
σ-finitas con `ξ ≪ ν`. -/
theorem appE_rn_cadena (ξ ν κ : Measure α) [SigmaFinite ξ] [SigmaFinite ν]
    [SigmaFinite κ] (h : ξ ≪ ν) :
    ξ.rnDeriv ν * ν.rnDeriv κ =ᵐ[κ] ξ.rnDeriv κ :=
  Measure.rnDeriv_mul_rnDeriv h

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**La densidad de un modelo dominado es su derivada de Radon–Nikodym**: si
`P_θ = p_θ·μ` con `p_θ` medible, entonces `dP_θ/dμ =ᵐ[μ] p_θ`. Fidelidad: el
libro escribe «cada `P_θ` tiene densidad `p_θ(x)` respecto de la medida
dominante»; este teorema dice que esa frase y `p_θ = dP_θ/dμ` son lo mismo. -/
theorem appE_rn_modelo (μ : Measure α) [SigmaFinite μ] {Θ : Type*}
    (p : Θ → α → ℝ≥0∞) (hp : ∀ θ, Measurable (p θ)) (θ : Θ) :
    (μ.withDensity (p θ)).rnDeriv μ =ᵐ[μ] p θ :=
  appE_rn_fundamental μ (hp θ)

/-! ## 6. Instancia concreta: la ley uniforme en `[0,1]` -/

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**Instancia concreta**: la ley uniforme en `[0,1]` tiene densidad `1_{[0,1]}`
respecto de Lebesgue: `d(λ↾[0,1])/dλ =ᵐ 1_{[0,1]}`. -/
theorem appE_rn_uniforme :
    (volume.restrict (Set.Icc (0 : ℝ) 1)).rnDeriv volume
      =ᵐ[volume] (Set.Icc (0 : ℝ) 1).indicator 1 := by
  filter_upwards [Measure.rnDeriv_restrict (μ := volume) (ν := volume)
      measurableSet_Icc, Measure.rnDeriv_self (μ := volume)] with x hx h1
  rw [hx]
  by_cases hmem : x ∈ Set.Icc (0 : ℝ) 1
  · simp only [Set.indicator_of_mem hmem, Pi.one_apply]
    exact h1
  · simp only [Set.indicator_of_notMem hmem]

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La ley uniforme en `[0,1]` es una **probabilidad**; junto con `appE_rn_uniforme`
da el par (probabilidad, dominante σ-finita) del enunciado. -/
theorem appE_rn_uniforme_probabilidad :
    IsProbabilityMeasure (volume.restrict (Set.Icc (0 : ℝ) 1)) := by
  constructor
  rw [Measure.restrict_apply_univ, Real.volume_Icc]
  norm_num

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La masa de la uniforme es la integral de su densidad: `∫_{[0,1]} 1 dλ = 1`. -/
theorem appE_rn_uniforme_masa :
    (volume.restrict (Set.Icc (0 : ℝ) 1)) Set.univ = 1 := by
  rw [Measure.restrict_apply_univ, Real.volume_Icc]
  norm_num

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**La densidad concreta verifica la fórmula**: `1_{[0,1]}` es medible y
`(λ↾[0,1])(A) = ∫_A 1_{[0,1]} dλ` para todo `A` medible. -/
theorem appE_rn_uniforme_verifica :
    Measurable ((Set.Icc (0 : ℝ) 1).indicator (1 : ℝ → ℝ≥0∞)) ∧
      (∀ A : Set ℝ, MeasurableSet A →
        volume.restrict (Set.Icc (0 : ℝ) 1) A
          = ∫⁻ x in A, (Set.Icc (0 : ℝ) 1).indicator (1 : ℝ → ℝ≥0∞) x ∂volume) := by
  refine ⟨Measurable.indicator measurable_const measurableSet_Icc, fun A hA => ?_⟩
  rw [← withDensity_apply _ hA, MeasureTheory.withDensity_indicator_one measurableSet_Icc]

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**El teorema no es vacío**: se aplica a la uniforme en `[0,1]` con `μ = volume`
(probabilidad, dominante σ-finita, continuidad absoluta: todas las hipótesis del
libro se cumplen), y **toda** densidad de la uniforme coincide c.a.e. con
`1_{[0,1]}`. -/
theorem appE_rn_uniforme_existe_unico :
    ∃ f : ℝ → ℝ≥0∞, Measurable f ∧ (∀ᵐ x ∂(volume : Measure ℝ), f x < ∞) ∧
      (∀ A : Set ℝ, MeasurableSet A →
        volume.restrict (Set.Icc (0 : ℝ) 1) A = ∫⁻ x in A, f x ∂volume) ∧
      ∀ g : ℝ → ℝ≥0∞, Measurable g →
        (∀ A : Set ℝ, MeasurableSet A →
          volume.restrict (Set.Icc (0 : ℝ) 1) A = ∫⁻ x in A, g x ∂volume) →
        g =ᵐ[volume] (Set.Icc (0 : ℝ) 1).indicator 1 := by
  haveI : IsProbabilityMeasure (volume.restrict (Set.Icc (0 : ℝ) 1)) :=
    appE_rn_uniforme_probabilidad
  obtain ⟨f, hf, hfin, hA, huniq⟩ :=
    appE_rn_existe_unico (volume.restrict (Set.Icc (0 : ℝ) 1)) volume
      (Measure.absolutelyContinuous_of_le Measure.restrict_le_self)
  refine ⟨f, hf, hfin, hA, fun g hg hgA => ?_⟩
  have h1 : f =ᵐ[volume] g := huniq g hg hgA
  have h2 : f =ᵐ[volume] (Set.Icc (0 : ℝ) 1).indicator 1 :=
    huniq ((Set.Icc (0 : ℝ) 1).indicator (1 : ℝ → ℝ≥0∞)) (appE_rn_uniforme_verifica.1)
      (appE_rn_uniforme_verifica.2)
  exact h1.symm.trans h2

/-! ## 7. La σ-finitud de la dominante es indispensable -/

/-- La medida de contar en `ℝ` **no** es σ-finita: si lo fuera, `ℝ` sería unión
numerable de conjuntos finitos, luego numerable. -/
theorem appE_count_no_sigmaFinite : ¬ SigmaFinite (Measure.count : Measure ℝ) := by
  intro h
  haveI := h
  have hfin : ∀ n : ℕ, (MeasureTheory.spanningSets (Measure.count : Measure ℝ) n).Finite := by
    intro n
    rw [← Measure.count_apply_lt_top]
    exact MeasureTheory.measure_spanningSets_lt_top _ n
  have hc : (Set.univ : Set ℝ).Countable := by
    rw [← MeasureTheory.iUnion_spanningSets (Measure.count : Measure ℝ)]
    exact Set.countable_iUnion fun n => (hfin n).countable
  exact Cardinal.not_countable_real hc

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
La uniforme en `[0,1]` es absolutamente continua respecto de la medida de
contar en `ℝ` (la única `count`-nula es `∅`). Fidelidad: es el `P ≪ μ` del
enunciado, sin pedir nada más. -/
theorem appE_rn_ac_count :
    volume.restrict (Set.Icc (0 : ℝ) 1) ≪ (Measure.count : Measure ℝ) := by
  refine Measure.AbsolutelyContinuous.mk fun s _ hs => ?_
  rw [Measure.count_eq_zero_iff] at hs
  rw [hs]
  simp

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**No existe densidad** de la uniforme en `[0,1]` respecto de la medida de
contar: si `P = count.withDensity f`, evaluando en cada singulete `{x}` se
obtiene `f x = P{x} = 0`, luego `P = 0`, que es falso. -/
theorem appE_rn_densidad_count_inexistente :
    ¬ ∃ f : ℝ → ℝ≥0∞,
      volume.restrict (Set.Icc (0 : ℝ) 1) = (Measure.count : Measure ℝ).withDensity f := by
  rintro ⟨f, hf⟩
  have hf0 : ∀ x : ℝ, f x = 0 := by
    intro x
    have h1 : (Measure.count : Measure ℝ).withDensity f {x} = f x := by
      rw [withDensity_apply _ (measurableSet_singleton x), lintegral_singleton,
        Measure.count_singleton, mul_one]
    have h2 : volume.restrict (Set.Icc (0 : ℝ) 1) {x} = 0 := by
      rw [Measure.restrict_apply (measurableSet_singleton x)]
      exact measure_mono_null Set.inter_subset_left (by simp)
    rw [← h1, ← hf]
    exact h2
  have hzero : volume.restrict (Set.Icc (0 : ℝ) 1) = 0 := by
    rw [hf, show f = fun _ => 0 from funext hf0]
    simp
  have hI : volume.restrict (Set.Icc (0 : ℝ) 1) (Set.Icc (0 : ℝ) 1) = 1 := by
    rw [Measure.restrict_apply measurableSet_Icc, Set.inter_self, Real.volume_Icc]
    norm_num
  rw [hzero] at hI
  simp at hI

/-- book: apendices/apendice_medido.typ:85 (key: thm:appE-radon-nikodym)
**La hipótesis sobre la medida dominante es parte del resultado**: hay una
probabilidad `P` y una medida `μ` con `P ≪ μ` (continuidad absoluta) para las
que *no* existe `f` con `P = μ.withDensity f`, porque `μ` no es σ-finita. Es la
segunda frase del enunciado del libro, probada con el par
(uniforme en `[0,1]`, medida de contar en `ℝ`). -/
theorem appE_rn_hipotesis_sigma_finita_necesaria :
    ∃ μ : Measure ℝ, volume.restrict (Set.Icc (0 : ℝ) 1) ≪ μ ∧
      ¬ SigmaFinite μ ∧
      ¬ ∃ f : ℝ → ℝ≥0∞, volume.restrict (Set.Icc (0 : ℝ) 1) = μ.withDensity f :=
  ⟨Measure.count, appE_rn_ac_count, appE_count_no_sigmaFinite,
    appE_rn_densidad_count_inexistente⟩

end Book.AppERNM3
