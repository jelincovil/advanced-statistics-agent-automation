/-
# Book.Cap05CltStudentizedM2 — reparación del CLT iid y forma studentizada

Módulo auxiliar de la reparación de `C.thm:ch5-clt` (libro:
`capitulos/cap04_herramientas.typ:1464`, clave `thm:ch5-clt`).

## Qué contiene

1. `BookCap05M2.ch5_clt_sin_fintype`: **copia literal** de `BookCap05.ch5_clt`
   (`verificacion_lean/Book/Cap05Asintotica.lean`) con `omit [Fintype Ω]`. Es la
   reparación mínima: el módulo original abre `variable {Ω : Type*} [Fintype Ω]`
   (línea 34) y Lean inserta ese binder en `ch5_clt` aunque la prueba no lo use
   (el propio Lean lo avisa: «automatically included section variable(s) unused
   in theorem `BookCap05.ch5_clt`»). Con `[Fintype Ω]` el paquete de hipótesis
   fuerza `Var[X 0; P] = 0` (argumento no formalizado, ver README), de modo que
   la hipótesis del libro `0 < σ²` no es instancia del target registrado.

2. `BookCap05M2.ch5_clt_reparado_subsume_antiguo`: el tipo antiguo (con
   `[Fintype Ω]` en contexto) se sigue del nuevo con los mismos argumentos;
   la reparación es conservadora y sustituible sin romper aplicaciones.

3. `BookCap05M2.ch5_clt_estudentizado`: la cláusula «o equivalentemente»
   del libro, `(X̄_n − μ)/(σ/√n) →d N(0,1)`, que el módulo original declara
   no formalizar. Se enuncia con testigo `Y ~ N(0, v)` dividido por `√v`
   (la ley límite es `gaussianReal 0 1` por `BookCap05M2.hasLaw_div_sqrt`), o
   directamente con un testigo `N(0,1)`: `ch5_clt_estudentizado_norm` (dos
   testigos) y `ch5_clt_estudentizado_norm1` (un solo testigo; el `N(0,v)` que
   pide el CLT se construye como `√v · Y₁`).

4. `BookCap05M2.InstanciaGaussiana.ch5_clt_estudentizado_gauss`: **instancia
   no vacía** en el caso del libro `0 < σ²`. Con la sucesión iid `N(0,1)`
   sobre el producto infinito (`Measure.infinitePi`), `Var = 1`, media `0`, y
   la forma studentizada da `(∑_{k<n} X_k)/√n →d N(0,1)`. Sirve de contraste
   con el binder `[Fintype Ω]` retirado: sobre un portador finito ese caso no
   es alcanzable (argumento de la revisión, no formalizado), aquí sí.

## Fidelidad declarada

- Misma normalización y misma ley límite que el libro; `μ = ∫ X 0 ∂P` es la
  media común calculada a partir de `IdentDistrib`, no postulada.
- `0 < σ²` es hipótesis explícita de la forma studentizada (`hv : 0 < v` con
  `variance (X 0) P = v`); el CLT sin studentizar no la necesita (es más fuerte
  que el libro en ese punto).
- `MemLp (X 0) 2 P` cubre `σ² < ∞` e integrabilidad.
- No se formaliza aquí la equivalencia entre ambas formas como *si y solo si*:
  se prueban las dos direcciones por separado desde el mismo CLT de Mathlib.
- Sin `sorry`, sin axiomas propios; solo los tres de Mathlib.
-/

import Mathlib

open MeasureTheory ProbabilityTheory Filter
open scoped Topology ENNReal NNReal

namespace BookCap05M2

/-! ### 1. El CLT sin `[Fintype Ω]` (reparación mínima de una línea) -/

section HerenciaFintype

variable {Ω : Type*} [Fintype Ω]

omit [Fintype Ω] in
/-- book: capitulos/cap04_herramientas.typ:1464 (key: thm:ch5-clt) —
**CLT clásico de Lindeberg–Lévy, sin el binder `[Fintype Ω]` heredado.**

Copia literal de `BookCap05.ch5_clt` con `omit [Fintype Ω]`; la prueba es la
misma (el CLT de Mathlib `tendstoInDistribution_inv_sqrt_mul_sum_sub`, que no
pide finitud de `Ω`). El binder `[Fintype Ω]` es una variable de sección
automáticamente incluida que la prueba no usa.

Fidelidad: enunciado y conclusión idénticos a `BookCap05.ch5_clt`; solo se
retira una instancia que restringe el portador. Ver
`ch5_clt_reparado_subsume_antiguo` para la conservatividad. -/
theorem ch5_clt_sin_fintype {Ω' : Type*} [MeasurableSpace Ω] [MeasurableSpace Ω']
    (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']
    (X : ℕ → Ω → ℝ) (Y : Ω' → ℝ)
    (hY : HasLaw Y (gaussianReal 0 (variance (X 0) P).toNNReal) P')
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P) :
    TendstoInDistribution
      (fun (n : ℕ) ω => (√(n:ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P))
      Filter.atTop Y (fun _ => P) P' :=
  tendstoInDistribution_inv_sqrt_mul_sum_sub hY hX hindep hident

end HerenciaFintype

/-! ### 2. Conservatividad: el tipo antiguo se sigue del reparado -/

section Compatibilidad

variable {Ω : Type*} [Fintype Ω] [MeasurableSpace Ω]
variable {Ω' : Type*} [MeasurableSpace Ω']
variable (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']

-- `[Fintype Ω]` está en el tipo a propósito (es el enunciado antiguo) y la
-- prueba no lo usa: exactamente el artefacto que este módulo documenta.
set_option linter.unusedSectionVars false in
/-- El enunciado **antiguo** (con `[Fintype Ω]`, idéntico al de
`BookCap05.ch5_clt` en `Book/Cap05Asintotica.lean`) se deriva del reparado con
los mismos argumentos: retirar el binder no cambia ninguna hipótesis ni la
conclusión, de modo que el parche es conservador para las aplicaciones
existentes. -/
theorem ch5_clt_reparado_subsume_antiguo (X : ℕ → Ω → ℝ) (Y : Ω' → ℝ)
    (hY : HasLaw Y (gaussianReal 0 (variance (X 0) P).toNNReal) P')
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P) :
    TendstoInDistribution
      (fun (n : ℕ) ω => (√(n:ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P))
      Filter.atTop Y (fun _ => P) P' :=
  ch5_clt_sin_fintype P P' X Y hY hX hindep hident

end Compatibilidad

/-! ### 3. Forma studentizada -/

section Estudentizado

/-- La variable gaussiana centrada dividida por su desviación típica es
`N(0,1)`: si `Y ~ N(0,v)` con `v > 0`, entonces `Y/√v ~ N(0,1)`. -/
theorem hasLaw_div_sqrt {Ω' : Type*} [MeasurableSpace Ω'] {P' : Measure Ω'}
    {Y : Ω' → ℝ} {v : NNReal} (hY : HasLaw Y (gaussianReal 0 v) P') (hv : 0 < v) :
    HasLaw (fun ω' => Y ω' / √((v : ℝ))) (gaussianReal 0 1) P' := by
  have hvR : (0 : ℝ) < (v : ℝ) := by exact_mod_cast hv
  have hvne : (v : ℝ) ≠ 0 := ne_of_gt hvR
  have h := gaussianReal_div_const (μ := 0) (v := v) hY (√((v : ℝ)))
  have hc : v / NNReal.mk ((√((v : ℝ))) ^ 2) (sq_nonneg _) = 1 := by
    ext
    simp only [NNReal.coe_div, NNReal.coe_mk, NNReal.coe_one, Real.sq_sqrt (le_of_lt hvR)]
    exact div_self hvne
  simp only [zero_div] at h
  rwa [hc] at h

/-- book: capitulos/cap04_herramientas.typ:1468 (key: thm:ch5-clt, forma
studentizada) — **CLT studentizado: `(X̄_n − μ)/(σ/√n) →d N(0,1)`.**

Con `v = σ²`, `hv : 0 < v` y `hvar : Var[X 0; P] = v`, la sucesión
`(∑_{k<n} X_k − nμ) / (√n·√v)` converge en distribución al testigo
`Y/√v`, cuya ley es `gaussianReal 0 1` por `hasLaw_div_sqrt`. Es la cláusula
«o equivalentemente» del libro, que `BookCap05.ch5_clt` declara no formalizar.

Fidelidad: `√n·σ` es exactamente `σ/√n` invertido, `(X̄_n − μ)/(σ/√n) =
√n(X̄_n − μ)/σ = (∑_{k<n} X_k − nμ)/(√n·σ)`; la media `μ = ∫ X 0 ∂P` se
calcula. `hvar` y `hv` hacen explícitas `σ² < ∞` y `0 < σ²`, las hipótesis
del libro. Prueba: CLT sin finitud (`ch5_clt_sin_fintype`) + teorema del mapa
continuo (`TendstoInDistribution.continuous_comp`) con `x ↦ x/√v`. -/
theorem ch5_clt_estudentizado {Ω : Type*} [MeasurableSpace Ω] {Ω' : Type*}
    [MeasurableSpace Ω']
    (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']
    (X : ℕ → Ω → ℝ) (Y : Ω' → ℝ) (v : NNReal)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = (v : ℝ)) (hv : 0 < v)
    (hY : HasLaw Y (gaussianReal 0 v) P') :
    TendstoInDistribution
      (fun (n : ℕ) ω => (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P)
        / (√(n:ℝ) * √((v : ℝ))))
      Filter.atTop (fun ω' => Y ω' / √((v : ℝ))) (fun _ => P) P' := by
  have hvR : (0 : ℝ) < (v : ℝ) := by exact_mod_cast hv
  have htoNN : (variance (X 0) P).toNNReal = v := by
    rw [hvar, Real.toNNReal_of_nonneg (le_of_lt hvR)]
    exact NNReal.eq (by simp)
  have hclt := ch5_clt_sin_fintype P P' X Y (by rwa [htoNN]) hX hindep hident
  have hcomp := hclt.continuous_comp (g := fun x : ℝ => x / √((v : ℝ))) (by fun_prop)
  have hcomp' : TendstoInDistribution
      (fun (n : ℕ) ω =>
        ((√(n:ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P))
          / √((v : ℝ)))
      Filter.atTop (fun ω' => Y ω' / √((v : ℝ))) (fun _ => P) P' := by
    simpa only [Function.comp_def] using hcomp
  have hfun : (fun (n : ℕ) ω =>
        (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P) / (√(n:ℝ) * √((v : ℝ))))
      = fun (n : ℕ) ω =>
        ((√(n:ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P))
          / √((v : ℝ)) := by
    funext n ω
    simp only [div_eq_mul_inv, mul_inv]
    ring
  rw [hfun]
  exact hcomp'

/-- book: capitulos/cap04_herramientas.typ:1468 (key: thm:ch5-clt, forma
studentizada con testigo normal estándar) — misma conclusión que
`ch5_clt_estudentizado` pero con un testigo arbitrario `Y₁ ~ N(0,1)`, que es
literalmente `N(0,1)` en el enunciado del libro.

Fidelidad: la igualdad de leyes `P'.map (Y/√v) = P'.map Y₁` (ambas
`gaussianReal 0 1`) permite cambiar el testigo sin cambiar la ley límite. -/
theorem ch5_clt_estudentizado_norm {Ω : Type*} [MeasurableSpace Ω] {Ω' : Type*}
    [MeasurableSpace Ω']
    (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']
    (X : ℕ → Ω → ℝ) (Y Y₁ : Ω' → ℝ) (v : NNReal)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = (v : ℝ)) (hv : 0 < v)
    (hY : HasLaw Y (gaussianReal 0 v) P') (hY₁ : HasLaw Y₁ (gaussianReal 0 1) P') :
    TendstoInDistribution
      (fun (n : ℕ) ω => (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P)
        / (√(n:ℝ) * √((v : ℝ))))
      Filter.atTop Y₁ (fun _ => P) P' := by
  have h := ch5_clt_estudentizado P P' X Y v hX hindep hident hvar hv hY
  have hlaw : P'.map (fun ω' => Y ω' / √((v : ℝ))) = P'.map Y₁ := by
    rw [(hasLaw_div_sqrt hY hv).map_eq, hY₁.map_eq]
  refine ⟨h.forall_aemeasurable, hY₁.aemeasurable, ?_⟩
  simpa only [hlaw] using h.tendsto

/-- book: capitulos/cap04_herramientas.typ:1468 (key: thm:ch5-clt, forma
studentizada con **un solo** testigo) — igual que `ch5_clt_estudentizado_norm`
pero con un único testigo `Y₁ ~ N(0,1)`: el testigo `N(0,v)` que necesita el CLT
se construye como `√v · Y₁`, así que no se postula ninguna otra variable. -/
theorem ch5_clt_estudentizado_norm1 {Ω : Type*} [MeasurableSpace Ω] {Ω' : Type*}
    [MeasurableSpace Ω']
    (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']
    (X : ℕ → Ω → ℝ) (Y₁ : Ω' → ℝ) (v : NNReal)
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P)
    (hvar : variance (X 0) P = (v : ℝ)) (hv : 0 < v)
    (hY₁ : HasLaw Y₁ (gaussianReal 0 1) P') :
    TendstoInDistribution
      (fun (n : ℕ) ω => (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P)
        / (√(n:ℝ) * √((v : ℝ))))
      Filter.atTop Y₁ (fun _ => P) P' := by
  have hvR : (0 : ℝ) < (v : ℝ) := by exact_mod_cast hv
  have hs : √((v : ℝ)) ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hvR)
  have hY : HasLaw (fun ω' => √((v : ℝ)) * Y₁ ω') (gaussianReal 0 v) P' := by
    have h := gaussianReal_const_mul (μ := 0) (v := 1) hY₁ (√((v : ℝ)))
    convert h using 2
    · simp
    · ext
      simp [Real.sq_sqrt (le_of_lt hvR)]
  have hmain := ch5_clt_estudentizado P P' X (fun ω' => √((v : ℝ)) * Y₁ ω') v
    hX hindep hident hvar hv hY
  have hlaw : P'.map (fun ω' => (√((v : ℝ)) * Y₁ ω') / √((v : ℝ))) = P'.map Y₁ := by
    have hfun : (fun ω' => (√((v : ℝ)) * Y₁ ω') / √((v : ℝ))) = Y₁ := by
      funext x
      exact mul_div_cancel_left₀ (Y₁ x) hs
    rw [hfun]
  refine ⟨hmain.forall_aemeasurable, hY₁.aemeasurable, ?_⟩
  simpa only [hlaw] using hmain.tendsto

end Estudentizado

/-! ### 4. No vacuidad: la sucesión iid gaussiana estándar satisface las hipótesis

La revisión de `C.thm:ch5-clt` señala que, con `[Fintype Ω]`, el paquete de
hipótesis fuerza `Var = 0` y el caso `0 < σ²` del libro no sería instancia del
target. Aquí se exhibe lo contrario para el target **reparado**: la sucesión
iid `N(0,1)` sobre el producto infinito tiene `σ² = 1 > 0` y la forma
studentizada del libro se aplica. No es un pasaje del libro: es el testigo de
que la reparación cubre el caso no degenerado. -/

namespace InstanciaGaussiana

/-- Espacio de probabilidad producto `(N(0,1))^{⊗ℕ}` sobre `ℕ → ℝ`. -/
noncomputable def PG : Measure (ℕ → ℝ) := Measure.infinitePi (fun _ : ℕ => gaussianReal 0 1)

instance : IsProbabilityMeasure PG := by rw [PG]; infer_instance

/-- Coordenada `i`: la variable `X i` de la sucesión iid. -/
def X (i : ℕ) : (ℕ → ℝ) → ℝ := fun ω => ω i

@[simp] theorem X_apply (i : ℕ) (ω : ℕ → ℝ) : X i ω = ω i := rfl

/-- Cada coordenada tiene ley `N(0,1)`. -/
theorem hasLaw_X (i : ℕ) : HasLaw (X i) (gaussianReal 0 1) PG := by
  refine ⟨?_, ?_⟩
  · exact (measurable_pi_apply i).aemeasurable
  · show Measure.map (fun ω : ℕ → ℝ => ω i) PG = gaussianReal 0 1
    simpa [PG] using Measure.infinitePi_map_eval (fun _ : ℕ => gaussianReal 0 1) i

/-- El testigo `x ↦ x` tiene ley `N(0,1)` bajo `N(0,1)`. -/
theorem hasLaw_id : HasLaw (fun x : ℝ => x) (gaussianReal 0 1) (gaussianReal 0 1) :=
  ⟨by fun_prop, Measure.map_id⟩

/-- Las coordenadas son independientes. -/
theorem iIndepFun_X : iIndepFun X PG := by
  have h : iIndepFun (fun i (ω : ℕ → ℝ) => ω i)
      (Measure.infinitePi (fun _ : ℕ => gaussianReal 0 1)) :=
    iIndepFun_infinitePi (X := fun (_ : ℕ) (x : ℝ) => x) (by fun_prop)
  exact h

/-- Las coordenadas son idénticamente distribuidas **entre sí** (la hipótesis
`∀ i, IdentDistrib (X i) (X 0)` del CLT). -/
theorem identDistrib_X_self (i : ℕ) : IdentDistrib (X i) (X 0) PG PG :=
  (hasLaw_X i).identDistrib (hasLaw_X 0)

/-- `MemLp (X 0) 2`: segundo momento finito (es la `σ² < ∞` del libro). -/
theorem memLp_X : MemLp (X 0) 2 PG := by
  have h2 : ((2 : NNReal) : ℝ≥0∞) = 2 := by norm_num
  exact (hasLaw_X 0).memLp (by simpa [h2] using memLp_id_gaussianReal (μ := 0) (v := 1) 2)

/-- `Var[X 0] = σ² = 1 > 0`: el caso no degenerado del libro. -/
theorem variance_X : variance (X 0) PG = 1 := by
  rw [(hasLaw_X 0).variance_eq, variance_id_gaussianReal]
  norm_num

/-- La media común es `μ = 0`. -/
theorem integral_X : ∫ ω, X 0 ω ∂PG = 0 := by
  rw [(hasLaw_X 0).integral_eq]
  simp

/-- **Instancia no vacía de la forma studentizada**: para la sucesión iid
`N(0,1)`, `(∑_{k<n} X_k)/√n →d N(0,1)`. Es `(X̄_n − μ)/(σ/√n) →d N(0,1)` con
`μ = 0`, `σ = 1`, y comprueba que las hipótesis del target reparado son
satisfacibles con `0 < σ²`. -/
theorem ch5_clt_estudentizado_gauss :
    TendstoInDistribution
      (fun (n : ℕ) (ω : ℕ → ℝ) => (∑ k ∈ Finset.range n, ω k) / √(n:ℝ))
      Filter.atTop (fun x : ℝ => x) (fun _ => PG) (gaussianReal 0 1) := by
  have h := ch5_clt_estudentizado PG (gaussianReal 0 1) X (fun x : ℝ => x) 1
    memLp_X iIndepFun_X identDistrib_X_self variance_X (by norm_num) hasLaw_id
  have hfun : (fun (n : ℕ) (ω : ℕ → ℝ) => (∑ k ∈ Finset.range n, ω k) / √(n:ℝ))
      = fun (n : ℕ) (ω : ℕ → ℝ) =>
          (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂PG)
            / (√(n:ℝ) * √(((1 : NNReal) : ℝ))) := by
    funext n ω
    rw [integral_X]
    simp
  rw [hfun]
  simpa using h

end InstanciaGaussiana

end BookCap05M2

-- Auditoría de axiomas de lo reclamado.
#print axioms BookCap05M2.ch5_clt_sin_fintype
#print axioms BookCap05M2.ch5_clt_reparado_subsume_antiguo
#print axioms BookCap05M2.hasLaw_div_sqrt
#print axioms BookCap05M2.ch5_clt_estudentizado
#print axioms BookCap05M2.ch5_clt_estudentizado_norm
#print axioms BookCap05M2.InstanciaGaussiana.X_apply
#print axioms BookCap05M2.InstanciaGaussiana.hasLaw_X
#print axioms BookCap05M2.InstanciaGaussiana.hasLaw_id
#print axioms BookCap05M2.InstanciaGaussiana.identDistrib_X_self
#print axioms BookCap05M2.ch5_clt_estudentizado_norm1
#print axioms BookCap05M2.InstanciaGaussiana.memLp_X
#print axioms BookCap05M2.InstanciaGaussiana.iIndepFun_X
#print axioms BookCap05M2.InstanciaGaussiana.variance_X
#print axioms BookCap05M2.InstanciaGaussiana.integral_X
#print axioms BookCap05M2.InstanciaGaussiana.ch5_clt_estudentizado_gauss
