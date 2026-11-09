/-
Copyright: proyecto `book_stat_inference_v0` (apéndice E). Sin copyright externo.
-/
import Mathlib

/-!
# Apéndice E — Teorema de la función implícita

Formalización de la clave `thm:appE-funcion-implicita`
(`apendices/apendice_medido.typ`, línea 173).

Enunciado del libro: sean `x ∈ ℝ^m`, `y ∈ ℝ^n` y `F : U₀ ⊆ ℝ^{m+n} → ℝ^n`
continuamente diferenciable en un abierto `U₀`. Si existe `(x₀, y₀)` con
`F (x₀, y₀) = 0` y el Jacobiano `∂F/∂y (x₀, y₀)` invertible, entonces existen
vecindades `U ∋ x₀`, `V ∋ y₀` y una única `g : U → V` con `F (x, g x) = 0`
en `U`, `g` continuamente diferenciable y `g x₀ = y₀`.

## Fidelidad declarada

Se formaliza en dimensión finita concreta (`x : Fin m → ℝ`,
`y : Fin n → ℝ`) apoyándose en el teorema de la función implícita de Mathlib
(`ContDiffAt.implicitFunction`, `Mathlib/Analysis/Calculus/ImplicitContDiff.lean`),
que es la versión general en espacios de Banach.

* El Jacobiano parcial `∂F/∂y (x₀, y₀)` se representa como
  `fderiv ℝ F (x₀, y₀) ∘L ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ)`
  y su invertibilidad como `ContinuousLinearMap.IsInvertible`.
* `F` continuamente diferenciable en el abierto `U₀` se formaliza como
  `ContDiffOn ℝ 1 F U₀` (teorema `appE_funcion_implicita_abierto`, que es el
  enunciado literal del libro) y, para la versión local, como
  `ContDiffAt ℝ 1 F (x₀, y₀)` (equivalente salvo la elección de vecindad).
* «Única `g : U → V`» se formaliza como la unicidad punto a punto en `U × V`:
  si `x ∈ U`, `y ∈ V` y `F (x, y) = 0`, entonces `y = g x` (cláusula final).
  Es la forma fuerte (no sólo unicidad de la función como germen).
* «Continuamente diferenciable» se formaliza como `ContDiffOn ℝ 1 g U`.

Dependencias: sólo `Mathlib`; axiomas esperados `propext, Classical.choice,
Quot.sound` (auditoría en `Book/AuditAppE.lean`).
-/

open Filter Topology Set
open scoped ContDiff Topology

namespace AppEImplicita

noncomputable section

variable {m n : ℕ}

/-- `1` como grado de diferenciabilidad es distinto de `0`. Auxiliar. -/
lemma one_ne_zero_nninfw : (1 : ℕ∞ω) ≠ 0 := by norm_num

/-! ### Teorema de la función implícita (forma local) -/

/-- book: apendices/apendice_medido.typ:173 (key: thm:appE-funcion-implicita)

Teorema de la función implícita. Sea `F : ℝ^m × ℝ^n → ℝ^n` continuamente
diferenciable en `(x₀, y₀)`, con `F (x₀, y₀) = 0` y Jacobiano parcial
`∂F/∂y (x₀, y₀)` invertible. Entonces existen una función `g : ℝ^m → ℝ^n`,
vecindades abiertas `U ∋ x₀`, `V ∋ y₀` tales que `g x₀ = y₀`, `g` manda `U`
en `V`, `F (x, g x) = 0` para todo `x ∈ U`, `g` es `C¹` en `U`, y `g` es la
única solución punto a punto en `U × V`: si `x ∈ U`, `y ∈ V` y `F (x, y) = 0`
entonces `y = g x`. -/
theorem appE_funcion_implicita
    (F : (Fin m → ℝ) × (Fin n → ℝ) → (Fin n → ℝ))
    {x₀ : Fin m → ℝ} {y₀ : Fin n → ℝ}
    (hF : ContDiffAt ℝ (1 : ℕ∞ω) F (x₀, y₀))
    (hcero : F (x₀, y₀) = 0)
    (hJac : ((fderiv ℝ F (x₀, y₀)).comp
      (ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ))).IsInvertible) :
    ∃ (g : (Fin m → ℝ) → (Fin n → ℝ))
      (U : Set (Fin m → ℝ)) (V : Set (Fin n → ℝ)),
      IsOpen U ∧ IsOpen V ∧ x₀ ∈ U ∧ y₀ ∈ V ∧ g x₀ = y₀ ∧
      MapsTo g U V ∧
      (∀ x ∈ U, F (x, g x) = 0) ∧
      ContDiffOn ℝ (1 : ℕ∞ω) g U ∧
      (∀ x ∈ U, ∀ y ∈ V, F (x, y) = 0 → y = g x) := by
  have h1 : (1 : ℕ∞ω) ≠ 0 := one_ne_zero_nninfw
  set g : (Fin m → ℝ) → (Fin n → ℝ) := hF.implicitFunction h1 hJac with hg
  have hgself : g x₀ = y₀ := hF.implicitFunction_apply_self h1 hJac
  -- (a) `g` es C¹ en un entorno de `x₀`
  have hC1 : ContDiffAt ℝ (1 : ℕ∞ω) g x₀ := hF.contDiffAt_implicitFunction h1 hJac
  have hcont : ContinuousAt g x₀ := hC1.continuousAt
  -- (b) `F (x, g x) = 0` en un entorno de `x₀`
  have hceroev : ∀ᶠ x in 𝓝 x₀, F (x, g x) = 0 := by
    simpa only [hcero] using hF.eventually_apply_implicitFunction (u := (x₀, y₀)) h1 hJac
  -- (c) forma local de la unicidad: en un entorno de `(x₀, y₀)`,
  -- `F v = 0 ↔ g v.1 = v.2`
  have hiff : ∀ᶠ v : (Fin m → ℝ) × (Fin n → ℝ) in 𝓝 (x₀, y₀),
      (F v = 0 ↔ g v.1 = v.2) := by
    simpa only [hcero] using
      hF.eventually_apply_eq_iff_implicitFunction (u := (x₀, y₀)) h1 hJac
  -- (d) abierto donde `g` es C¹
  obtain ⟨Uc, hUc, hUcdiff⟩ := hC1.contDiffOn (le_refl (1 : ℕ∞ω)) (by simp)
  -- (e) descomponemos el filtro producto de (c) en dos entornos
  rw [nhds_prod_eq] at hiff
  obtain ⟨pa, hpa, pb, hpb, hpat⟩ := eventually_prod_iff.mp hiff
  obtain ⟨V, hVsub, hVopen, hyV⟩ := mem_nhds_iff.mp hpb
  have hVin : V ∈ 𝓝 y₀ := hVopen.mem_nhds hyV
  -- (f) `g` manda un entorno de `x₀` en `V`
  have hgV : ∀ᶠ x in 𝓝 x₀, g x ∈ V := by
    have hgx : g x₀ ∈ V := hgself ▸ hyV
    exact hcont.preimage_mem_nhds (hVopen.mem_nhds hgx)
  -- (g) juntamos todo y extraemos un abierto `U`
  have hbig : ∀ᶠ x in 𝓝 x₀, x ∈ Uc ∧ F (x, g x) = 0 ∧ g x ∈ V ∧ pa x := by
    filter_upwards [hUc, hceroev, hgV, hpa] with x hx1 hx2 hx3 hx4
    exact ⟨hx1, hx2, hx3, hx4⟩
  obtain ⟨s, hs, hsub⟩ := hbig.exists_mem
  obtain ⟨U, hUs, hUopen, hxU⟩ := mem_nhds_iff.mp hs
  refine ⟨g, U, V, hUopen, hVopen, hxU, hyV, hgself, ?_, ?_, ?_, ?_⟩
  · intro x hx
    exact (hsub x (hUs hx)).2.2.1
  · intro x hx
    exact (hsub x (hUs hx)).2.1
  · exact hUcdiff.mono fun x hx => (hsub x (hUs hx)).1
  · intro x hx y hy hFxy
    have hpax : pa x := (hsub x (hUs hx)).2.2.2
    have hpby : pb y := hVsub hy
    have := (hpat hpax hpby : F (x, y) = 0 ↔ g x = y).mp hFxy
    exact this.symm

/-! ### El enunciado del libro: `F` es `C¹` en un abierto `U₀` -/

/-- book: apendices/apendice_medido.typ:173 (key: thm:appE-funcion-implicita)

Versión literal del enunciado del libro: `F` está definida y es continuamente
diferenciable en un abierto `U₀ ∋ (x₀, y₀)` (en lugar de serlo sólo en el
punto). La conclusión es la misma que `appE_funcion_implicita`. -/
theorem appE_funcion_implicita_abierto
    (F : (Fin m → ℝ) × (Fin n → ℝ) → (Fin n → ℝ))
    {U₀ : Set ((Fin m → ℝ) × (Fin n → ℝ))}
    {x₀ : Fin m → ℝ} {y₀ : Fin n → ℝ}
    (hU₀ : IsOpen U₀) (hF : ContDiffOn ℝ (1 : ℕ∞ω) F U₀)
    (hmem : (x₀, y₀) ∈ U₀)
    (hcero : F (x₀, y₀) = 0)
    (hJac : ((fderiv ℝ F (x₀, y₀)).comp
      (ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ))).IsInvertible) :
    ∃ (g : (Fin m → ℝ) → (Fin n → ℝ))
      (U : Set (Fin m → ℝ)) (V : Set (Fin n → ℝ)),
      IsOpen U ∧ IsOpen V ∧ x₀ ∈ U ∧ y₀ ∈ V ∧ g x₀ = y₀ ∧
      MapsTo g U V ∧
      (∀ x ∈ U, F (x, g x) = 0) ∧
      ContDiffOn ℝ (1 : ℕ∞ω) g U ∧
      (∀ x ∈ U, ∀ y ∈ V, F (x, y) = 0 → y = g x) :=
  appE_funcion_implicita F (hF.contDiffAt (hU₀.mem_nhds hmem)) hcero hJac

/-! ### Fórmula de la derivada implícita -/

/-- book: apendices/apendice_medido.typ:173 (key: thm:appE-funcion-implicita)

Fórmula de la derivada de la función implícita (contenido de «`g` es
continuamente diferenciable» y de la regla de la cadena aplicada a
`F (x, g x) = 0`):

  `g' (x₀) = - (∂F/∂y (x₀, y₀))⁻¹ ∘ ∂F/∂x (x₀, y₀)`.

Se obtiene de la versión general de Mathlib; se incluye para dejar explícita
la derivada, que el libro no escribe pero sí usa en el capítulo 4. -/
theorem appE_funcion_implicita_fderiv
    (F : (Fin m → ℝ) × (Fin n → ℝ) → (Fin n → ℝ))
    {x₀ : Fin m → ℝ} {y₀ : Fin n → ℝ}
    (hF : ContDiffAt ℝ (1 : ℕ∞ω) F (x₀, y₀))
    (hJac : ((fderiv ℝ F (x₀, y₀)).comp
      (ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ))).IsInvertible) :
    HasStrictFDerivAt (hF.implicitFunction one_ne_zero_nninfw hJac)
      (-(((fderiv ℝ F (x₀, y₀)).comp
            (ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ))).inverse).comp
          ((fderiv ℝ F (x₀, y₀)).comp
            (ContinuousLinearMap.inl ℝ (Fin m → ℝ) (Fin n → ℝ)))) x₀ :=
  hF.hasStrictFDerivAt_implicitFunction (u := (x₀, y₀)) one_ne_zero_nninfw hJac

/-! ### Unicidad como germen -/

/-- book: apendices/apendice_medido.typ:173 (key: thm:appE-funcion-implicita)

Unicidad de la función implícita como germen: cualquier `g'` continua en `x₀`,
con `g' x₀ = y₀` y que resuelva la ecuación en un entorno de `x₀` coincide con
la función implícita en un entorno de `x₀`. -/
theorem appE_funcion_implicita_germen_unico
    (F : (Fin m → ℝ) × (Fin n → ℝ) → (Fin n → ℝ))
    {x₀ : Fin m → ℝ} {y₀ : Fin n → ℝ}
    (hF : ContDiffAt ℝ (1 : ℕ∞ω) F (x₀, y₀))
    (hcero : F (x₀, y₀) = 0)
    (hJac : ((fderiv ℝ F (x₀, y₀)).comp
      (ContinuousLinearMap.inr ℝ (Fin m → ℝ) (Fin n → ℝ))).IsInvertible)
    {g' : (Fin m → ℝ) → (Fin n → ℝ)}
    (hg'cont : ContinuousAt g' x₀) (hg'0 : g' x₀ = y₀)
    (hg'sol : ∀ᶠ x in 𝓝 x₀, F (x, g' x) = 0) :
    ∀ᶠ x in 𝓝 x₀, g' x = hF.implicitFunction one_ne_zero_nninfw hJac x := by
  have h1 : (1 : ℕ∞ω) ≠ 0 := one_ne_zero_nninfw
  set g : (Fin m → ℝ) → (Fin n → ℝ) := hF.implicitFunction h1 hJac with hg
  have hiff : ∀ᶠ v : (Fin m → ℝ) × (Fin n → ℝ) in 𝓝 (x₀, y₀),
      (F v = 0 ↔ g v.1 = v.2) := by
    simpa only [hcero] using
      hF.eventually_apply_eq_iff_implicitFunction (u := (x₀, y₀)) h1 hJac
  have hcurve : Tendsto (fun x : Fin m → ℝ => (x, g' x)) (𝓝 x₀) (𝓝 (x₀, y₀)) := by
    have hg'tend : Tendsto g' (𝓝 x₀) (𝓝 y₀) := by
      rw [← hg'0]
      exact hg'cont
    exact Tendsto.prodMk_nhds tendsto_id hg'tend
  have hnear : ∀ᶠ x in 𝓝 x₀, (F (x, g' x) = 0 ↔ g x = g' x) := hcurve.eventually hiff
  filter_upwards [hnear, hg'sol] with x hx hx0
  exact (hx.mp hx0).symm

end

end AppEImplicita
