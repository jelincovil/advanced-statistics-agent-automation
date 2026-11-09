import Mathlib

/-!
# Book.ApendiceEMedidoDctM5 — apéndice E: Teorema de Convergencia Dominada de Lebesgue

Formaliza `thm:appE-convergencia-dominada` de `apendices/apendice_medido.typ:201`:

> Sea `{f_n}` una sucesión de funciones medibles tal que `f_n → f` casi
> seguramente. Si existe una función integrable `g` tal que `|f_n| ≤ g` para
> todo `n`, entonces: (i) `f` es integrable; (ii) `∫ f_n dμ → ∫ f dμ`.

Convención del proyecto: docstring `book: <archivo>:<línea> (key: <clave>)` y
fidelidad declarada en cada teorema. Cero `sorry`; axiomas ⊆
`{propext, Classical.choice, Quot.sound}`.

## Fidelidad declarada

* El libro escribe «funciones medibles»; aquí se usa la noción de Mathlib
  `AEStronglyMeasurable (f n) μ`, que es la que el teorema necesita y la más
  general (medibilidad fuerte sólo módulo conjuntos nulos).
* La dominación `|f_n| ≤ g` se formaliza «en casi todo punto» (`∀ᵐ ω ∂μ`),
  que es la forma en que el teorema es cierto y la que el libro usa en la
  práctica.
* El límite es una función `F : Ω → ℝ`; no se pide que `f_n` converja en todo
  punto, sino en casi todo punto, como en el libro.
* Las funciones toman valores en `ℝ`. La versión de Bochner en Mathlib vale en
  cualquier espacio de Banach real; el enunciado del libro es real.
* `appE_dct_dominacion_necesaria` no está en el libro: se incluye porque el
  apéndice justifica la hipótesis de dominación y el contraejemplo (masa que
  escapa al infinito, `f_n = 1_{(n, n+1]}` sobre `(ℝ, λ)`) muestra que sin ella
  la conclusión (ii) falla aunque (i) sea trivialmente cierta. El contraejemplo
  se completa con `masaQueEscapa_sin_dominante`: **no existe** `g` integrable
  que domine a todas las `f_n`, así que el ejemplo no es un caso de dominación
  no detectada.
-/

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

open MeasureTheory Filter Topology
open scoped ENNReal Topology

namespace Book.ApendiceEMedidoDctM5

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}

/-! ## El teorema -/

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
**Teorema de Convergencia Dominada de Lebesgue.** Si `f_n → F` casi
seguramente, todas las `f_n` son (casi) medibles y existe `g` integrable con
`|f_n| ≤ g` c.s. para todo `n`, entonces `F` es integrable y las integrales
convergen: `∫ f_n dμ → ∫ F dμ`.

Fidelidad: dominación y convergencia son «en casi todo punto» (el libro no lo
especifica; es la forma correcta y suficiente); medibilidad vía
`AEStronglyMeasurable`. -/
theorem appE_convergencia_dominada {f : ℕ → Ω → ℝ} {F : Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Integrable g μ)
    (hbound : ∀ n, ∀ᵐ ω ∂μ, |f n ω| ≤ g ω)
    (hlim : ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (F ω))) :
    Integrable F μ ∧ Tendsto (fun n => ∫ ω, f n ω ∂μ) atTop (𝓝 (∫ ω, F ω ∂μ)) := by
  -- (i) `F` es casi medible y está dominada por `g` como límite c.s. de las `f n`.
  have hF_meas : AEStronglyMeasurable F μ := aestronglyMeasurable_of_tendsto_ae atTop hf hlim
  have hF_bound : ∀ᵐ ω ∂μ, |F ω| ≤ g ω := by
    filter_upwards [hlim, ae_all_iff.2 hbound] with ω hω hb
    exact le_of_tendsto hω.abs (Eventually.of_forall hb)
  refine ⟨hg.mono' hF_meas hF_bound, ?_⟩
  -- (ii) convergencia de integrales: teorema de convergencia dominada de Mathlib.
  exact tendsto_integral_of_dominated_convergence g hf hg
    (fun n => by simpa [Real.norm_eq_abs] using hbound n) hlim

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
Parte (i) del teorema, aislada: el límite c.s. de funciones (casi) medibles
dominadas por una función integrable es integrable. Fidelidad: mismas
hipótesis que `appE_convergencia_dominada`, sólo se concluye la
integrabilidad. -/
theorem appE_convergencia_dominada_integrable {f : ℕ → Ω → ℝ} {F : Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Integrable g μ)
    (hbound : ∀ n, ∀ᵐ ω ∂μ, |f n ω| ≤ g ω)
    (hlim : ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (F ω))) :
    Integrable F μ :=
  (appE_convergencia_dominada hf hg hbound hlim).1

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
Parte (ii) del teorema, aislada: convergencia de las integrales. Fidelidad:
igual que `appE_convergencia_dominada`. -/
theorem appE_convergencia_dominada_tendsto {f : ℕ → Ω → ℝ} {F : Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Integrable g μ)
    (hbound : ∀ n, ∀ᵐ ω ∂μ, |f n ω| ≤ g ω)
    (hlim : ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (F ω))) :
    Tendsto (fun n => ∫ ω, f n ω ∂μ) atTop (𝓝 (∫ ω, F ω ∂μ)) :=
  (appE_convergencia_dominada hf hg hbound hlim).2

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
**Convergencia en `L¹`.** Corolario del teorema: bajo las mismas hipótesis,
`∫ ‖f_n - F‖ dμ → 0`. Es la forma en que la convergencia dominada se usa en el
resto del libro (por ejemplo para pasar la convergencia de las medias). Fidelidad:
se aplica el teorema con dominante `g + g`, válido porque `‖f_n - F‖ ≤ |f_n| + |F|`.
El libro no enuncia este corolario; es consecuencia directa de (ii). -/
theorem appE_convergencia_dominada_L1 {f : ℕ → Ω → ℝ} {F : Ω → ℝ} {g : Ω → ℝ}
    (hf : ∀ n, AEStronglyMeasurable (f n) μ) (hg : Integrable g μ)
    (hbound : ∀ n, ∀ᵐ ω ∂μ, |f n ω| ≤ g ω)
    (hlim : ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (F ω))) :
    Tendsto (fun n => ∫ ω, ‖f n ω - F ω‖ ∂μ) atTop (𝓝 0) := by
  have hg' : Integrable (fun ω => g ω + g ω) μ := hg.add hg
  have hF_int : Integrable F μ := appE_convergencia_dominada_integrable hf hg hbound hlim
  have hF_bound : ∀ᵐ ω ∂μ, |F ω| ≤ g ω := by
    filter_upwards [hlim, ae_all_iff.2 hbound] with ω hω hb
    exact le_of_tendsto hω.abs (Eventually.of_forall hb)
  have hmeas : ∀ n, AEStronglyMeasurable (fun ω => ‖f n ω - F ω‖) μ :=
    fun n => ((hf n).sub hF_int.1).norm
  have hbound' : ∀ n, ∀ᵐ ω ∂μ, ‖‖f n ω - F ω‖‖ ≤ g ω + g ω := by
    intro n
    filter_upwards [hbound n, hF_bound] with ω hb hFb
    have hb' := abs_le.1 hb
    have hFb' := abs_le.1 hFb
    have houter : ‖‖f n ω - F ω‖‖ = |f n ω - F ω| := by
      rw [Real.norm_eq_abs, abs_of_nonneg (norm_nonneg _), Real.norm_eq_abs]
    rw [houter]
    apply abs_le.2
    constructor <;> linarith [hb'.1, hb'.2, hFb'.1, hFb'.2]
  have hlim' : ∀ᵐ ω ∂μ, Tendsto (fun n => ‖f n ω - F ω‖) atTop (𝓝 ((fun _ => (0 : ℝ)) ω)) := by
    filter_upwards [hlim] with ω hω
    have h0 : Tendsto (fun n => f n ω - F ω) atTop (𝓝 (F ω - F ω)) := hω.sub_const (F ω)
    have h1 : F ω - F ω = 0 := sub_self _
    rw [h1] at h0
    simpa [Real.norm_eq_abs] using h0.abs
  have h := tendsto_integral_of_dominated_convergence (fun ω => g ω + g ω) hmeas hg' hbound' hlim'
  simpa using h

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
**Convergencia dominada con cota constante.** En un espacio de medida finito,
toda sucesión medible uniformemente acotada por una constante `C` cuyas
integrales convergen lo hace a la integral del límite. Fidelidad: es el caso
particular `g ≡ C` del teorema; la finitud de `μ` es lo que hace integrable a
la constante (`integrable_const`), exactamente la condición que el libro
supone al hablar de variables aleatorias acotadas. El libro no enuncia este
caso por separado. -/
theorem appE_convergencia_dominada_const [IsFiniteMeasure μ] {f : ℕ → Ω → ℝ} {F : Ω → ℝ}
    {C : ℝ} (hf : ∀ n, AEStronglyMeasurable (f n) μ)
    (hbound : ∀ n, ∀ᵐ ω ∂μ, |f n ω| ≤ C)
    (hlim : ∀ᵐ ω ∂μ, Tendsto (fun n => f n ω) atTop (𝓝 (F ω))) :
    Integrable F μ ∧ Tendsto (fun n => ∫ ω, f n ω ∂μ) atTop (𝓝 (∫ ω, F ω ∂μ)) :=
  appE_convergencia_dominada hf (integrable_const C) hbound hlim

/-! ## La dominación es necesaria

El apéndice justifica la hipótesis de dominación. El ejemplo siguiente (masa
unitaria que escapa al infinito sobre `(ℝ, λ)`) muestra que sin dominante
integrable la conclusión (ii) falla, y —más fuerte— que **ninguna** función
integrable domina a toda la sucesión: los soportes `(n, n+1]` son disjuntos, de
modo que un dominante tendría integral `≥ N` para todo `N`. No aparece en el
libro; acompaña al teorema.
-/

/-- Indicatriz de `(n, n+1]`: una masa unidad que se desplaza al infinito. -/
noncomputable def masaQueEscapa (n : ℕ) (x : ℝ) : ℝ :=
  (Set.Ioc (n : ℝ) ((n : ℝ) + 1)).indicator (fun _ => (1 : ℝ)) x

/-- Cada `masaQueEscapa n` es integrable: es una indicatriz sobre un intervalo de
medida finita. -/
theorem masaQueEscapa_integrable (n : ℕ) : Integrable (masaQueEscapa n) volume := by
  have hfun : masaQueEscapa n
      = Set.indicator (Set.Ioc (n : ℝ) ((n : ℝ) + 1)) (fun _ => (1 : ℝ)) := rfl
  rw [hfun, integrable_indicator_iff measurableSet_Ioc]
  exact integrableOn_const (by simp)

/-- Los soportes `(n, n+1]` y `(m, m+1]` con `n < m` son disjuntos. -/
theorem masaQueEscapa_intervalos_disjuntos {n m : ℕ} (hnm : n < m) {x : ℝ}
    (hn : x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1)) (hm : x ∈ Set.Ioc (m : ℝ) ((m : ℝ) + 1)) :
    False := by
  have h1 : (n : ℝ) + 1 ≤ (m : ℝ) := by
    have h2 : n + 1 ≤ m := hnm
    exact_mod_cast h2
  have h3 : x ≤ (n : ℝ) + 1 := hn.2
  have h4 : (m : ℝ) < x := hm.1
  linarith

/-- La suma de las `N` primeras `masaQueEscapa` en un punto es el número de
intervalos `(n, n+1]` (`n < N`) que contienen a `x`, como número real. -/
theorem masaQueEscapa_suma_eq_card (N : ℕ) (x : ℝ) :
    ∑ n ∈ Finset.range N, masaQueEscapa n x
      = (((Finset.range N).filter (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))).card :
          ℝ) := by
  calc ∑ n ∈ Finset.range N, masaQueEscapa n x
      = ∑ n ∈ Finset.range N,
          (if x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1) then (1 : ℝ) else 0) := by
        refine Finset.sum_congr rfl (fun n _ => ?_)
        by_cases h : x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1) <;>
          simp [masaQueEscapa, Set.indicator_of_mem, Set.indicator_of_notMem, h]
    _ = ∑ n ∈ ((Finset.range N).filter (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))),
          (1 : ℝ) := by
        rw [Finset.sum_filter]
    _ = (((Finset.range N).filter (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))).card :
          ℝ) := by
        simp

/-- A lo sumo uno de los intervalos `(n, n+1]` con `n < N` contiene a `x`. -/
theorem masaQueEscapa_card_le_one (N : ℕ) (x : ℝ) :
    ((Finset.range N).filter (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [Finset.mem_filter] at ha hb
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact masaQueEscapa_intervalos_disjuntos hlt ha.2 hb.2
  · exact masaQueEscapa_intervalos_disjuntos hgt hb.2 ha.2

/-- La suma de las `N` primeras `masaQueEscapa` está acotada por `1` en todo punto. -/
theorem masaQueEscapa_suma_le (N : ℕ) (x : ℝ) :
    ∑ n ∈ Finset.range N, masaQueEscapa n x ≤ 1 := by
  rw [masaQueEscapa_suma_eq_card]
  have h := masaQueEscapa_card_le_one N x
  exact_mod_cast h

/-- Si `g` domina puntualmente a toda la sucesión, entonces domina también a
cualquier suma finita de las `masaQueEscapa`: a lo sumo un término es no nulo. -/
theorem masaQueEscapa_suma_le_g (N : ℕ) {g : ℝ → ℝ} {x : ℝ}
    (hx : ∀ n, |masaQueEscapa n x| ≤ g x) :
    ∑ n ∈ Finset.range N, masaQueEscapa n x ≤ g x := by
  have hg0 : 0 ≤ g x := by
    have h := hx 0
    have h0 : (0 : ℝ) ≤ |masaQueEscapa 0 x| := abs_nonneg _
    linarith
  rw [masaQueEscapa_suma_eq_card]
  have hcard := masaQueEscapa_card_le_one N x
  rcases Nat.eq_zero_or_pos ((Finset.range N).filter
      (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))).card with h0 | hpos
  · rw [h0]
    push_cast
    linarith
  · have h1 : ((Finset.range N).filter
        (fun (n : ℕ) => x ∈ Set.Ioc (n : ℝ) ((n : ℝ) + 1))).card = 1 := by omega
    obtain ⟨k, hk⟩ := Finset.card_pos.1 hpos
    simp only [Finset.mem_filter] at hk
    have hfk : masaQueEscapa k x = 1 := by
      simp [masaQueEscapa, Set.indicator_of_mem hk.2]
    have hb := hx k
    rw [hfk, abs_one] at hb
    rw [h1]
    push_cast
    linarith

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
`masaQueEscapa n → 0` en **todo** punto: cada `x` queda a la izquierda de
`(n, n+1]` para todo `n ≥ x`. -/
theorem masaQueEscapa_tendsto (x : ℝ) : Tendsto (fun n => masaQueEscapa n x) atTop (𝓝 0) := by
  have hcast : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop := tendsto_natCast_atTop_atTop
  have hx : ∀ᶠ n : ℕ in atTop, x ≤ (n : ℝ) := hcast.eventually (eventually_ge_atTop x)
  have hzero : (fun n : ℕ => masaQueEscapa n x) =ᶠ[atTop] fun _ => (0 : ℝ) := by
    filter_upwards [hx] with n hn
    simp [masaQueEscapa, Set.indicator_of_notMem, not_lt.mpr hn]
  exact tendsto_const_nhds.congr' hzero.symm

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
Cada `masaQueEscapa n` tiene integral `1`: la masa no se pierde, sólo se va. -/
theorem masaQueEscapa_integral (n : ℕ) : ∫ x, masaQueEscapa n x ∂volume = 1 := by
  simp only [masaQueEscapa]
  rw [integral_indicator_const (μ := volume) (1 : ℝ) measurableSet_Ioc,
    Real.volume_real_Ioc_of_le (by linarith)]
  norm_num

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
**Ningún dominante integrable.** No existe `g` integrable que domine a toda la
sucesión `masaQueEscapa`. Prueba: si `g` la domina, las sumas parciales están
acotadas por `g` (soportes disjuntos), y como cada `∫ masaQueEscapa n = 1`, la
integral de la suma de las `N` primeras es `N`, luego `N ≤ ∫ g` para todo `N`,
imposible para `∫ g` finito. Esto cierra la justificación de la hipótesis del
teorema: el contraejemplo no es un caso de dominación no detectada. Fidelidad:
no está en el libro; se añade como complemento del enunciado. -/
theorem masaQueEscapa_sin_dominante :
    ¬ ∃ g : ℝ → ℝ, Integrable g volume ∧
        ∀ n, ∀ᵐ x ∂volume, |masaQueEscapa n x| ≤ g x := by
  rintro ⟨g, hg, hb⟩
  have hbound : ∀ᵐ x ∂volume, ∀ n, |masaQueEscapa n x| ≤ g x := ae_all_iff.2 hb
  have hmain : ∀ N : ℕ, (N : ℝ) ≤ ∫ x, g x ∂volume := by
    intro N
    have hsum_int : ∫ x, (∑ n ∈ Finset.range N, masaQueEscapa n x) ∂volume = (N : ℝ) := by
      rw [integral_finsetSum]
      · simp [masaQueEscapa_integral]
      · intro n _
        exact masaQueEscapa_integrable n
    have hInt_sum : Integrable (fun x => ∑ n ∈ Finset.range N, masaQueEscapa n x) volume :=
      integrable_finsetSum _ (fun n _ => masaQueEscapa_integrable n)
    have hmono : ∀ᵐ x ∂volume, (∑ n ∈ Finset.range N, masaQueEscapa n x) ≤ g x := by
      filter_upwards [hbound] with x hx using masaQueEscapa_suma_le_g N hx
    calc (N : ℝ) = ∫ x, (∑ n ∈ Finset.range N, masaQueEscapa n x) ∂volume := hsum_int.symm
      _ ≤ ∫ x, g x ∂volume := integral_mono_ae hInt_sum hg hmono
  obtain ⟨N, hN⟩ := exists_nat_gt (∫ x, g x ∂volume)
  have hN' : (N : ℝ) ≤ ∫ x, g x ∂volume := hmain N
  linarith

/-- book: apendices/apendice_medido.typ:201 (key: thm:appE-convergencia-dominada)
**Sin dominación la conclusión falla.** La sucesión `masaQueEscapa` converge
casi seguramente a `0` (de hecho en todo punto) pero sus integrales son
constantemente `1`: no convergen a `∫ 0 = 0`. Por tanto el teorema necesita la
hipótesis de dominación, y no por un defecto de la formalización: por
`masaQueEscapa_sin_dominante` no hay ningún dominante integrable que aplicar.
Fidelidad: el libro no incluye este contraejemplo; se añade como justificación
de la hipótesis. -/
theorem appE_dct_dominacion_necesaria :
    (∀ x : ℝ, Tendsto (fun n => masaQueEscapa n x) atTop (𝓝 0)) ∧
      ¬ Tendsto (fun n => ∫ x, masaQueEscapa n x ∂volume) atTop
          (𝓝 (∫ x, (fun _ : ℝ => (0 : ℝ)) x ∂volume)) := by
  refine ⟨masaQueEscapa_tendsto, ?_⟩
  simp only [masaQueEscapa_integral, integral_zero]
  intro h
  have h1 : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
  exact one_ne_zero (tendsto_nhds_unique h1 h)

end Book.ApendiceEMedidoDctM5
