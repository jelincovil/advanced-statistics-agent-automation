/-
Copyright: proyecto `book_stat_inference_v0` (apéndice E). Sin copyright externo.
-/
import Mathlib

/-!
# Apéndice E — Condiciones de regularidad para el teorema de la función implícita

Formalización de la clave `prop:appE-condiciones-funcion-implicita`
(`apendices/apendice_medido.typ`, línea 187).

Texto del libro (informal): «Para una ecuación de estimación `F(x, θ) = 0`, el
teorema exige `F` continuamente diferenciable cerca de la solución y Jacobiano
`∂_θ F` invertible en ella. La información de Fisher es una esperanza y no
coincide necesariamente con el Jacobiano de una ecuación muestral. Su
invertibilidad no prueba por sí sola la invertibilidad de ese Jacobiano ni la
existencia de una solución. Identificación global y no singularidad local son
requisitos distintos.»

## Fidelidad declarada

La proposición del libro es prosa (no un enunciado con cuantificadores). Aquí
se formaliza cada una de sus afirmaciones como un teorema exacto y concreto.
Cada docstring cita la frase del libro que se formaliza.

1. `bernFisher_eq`, `bernFisher_half`: la información de Fisher es una
   **esperanza** (suma ponderada por las probabilidades del modelo); en el
   modelo `Bernoulli (θ)` vale `1/(θ(1-θ))`, y en `θ = 1/2` vale `4 ≠ 0`
   (en 1-D, «invertible» ⇔ no nula).
2. `fisher_informacion_no_da_jacobiano_invertible`: hay una ecuación de
   estimación resoluble en un punto cuya Jacobiana `∂_θ F` **no** es
   invertible allí (`∂_θ F = 0`), aunque la información de Fisher sí es no
   nula. La invertibilidad de Fisher no prueba la del Jacobiano muestral.
3. `jacobiano_invertible_sin_solucion`: hay una ecuación con Jacobiana
   invertible en un punto y **sin ninguna** solución real: la invertibilidad
   local no prueba existencia de solución.
4. `identificacion_sin_nonsingularidad` y `nonsingularidad_sin_identificacion`:
   hay aplicaciones inyectivas (identificación global) con derivada singular,
   y aplicaciones con derivada invertible en todo punto que no son inyectivas
   (reparametrización con Jacobiano nunca singular que no identifica).
   Identificación global y no singularidad local son requisitos distintos.

Convención: en 1-D se trabaja con `fderiv` y `ContinuousLinearMap.IsInvertible`
sobre `ℝ →L[ℝ] ℝ`; la «Jacobiana `∂_θ F`» se representa como
`fderiv ℝ F (u, θ) ∘L ContinuousLinearMap.inr ℝ ℝ ℝ`.
-/

open Filter Topology
open scoped ContDiff

namespace AppECond

noncomputable section

/-! ### 1. La información de Fisher es una esperanza: modelo Bernoulli -/

/-- Masa de probabilidad de `Bernoulli (θ)` en `x : Bool` (`true = 1`,
`false = 0`). -/
def bernP (θ : ℝ) (x : Bool) : ℝ := if x then θ else 1 - θ

/-- Score del modelo `Bernoulli (θ)`: `∂_θ log p_θ (x) = (x - θ)/(θ(1-θ))`. -/
def bernScore (θ : ℝ) (x : Bool) : ℝ := ((if x then (1 : ℝ) else 0) - θ) / (θ * (1 - θ))

/-- Información de Fisher del modelo `Bernoulli (θ)`: la esperanza
`E_θ[(∂_θ log p_θ)²] = ∑_x p_θ(x) · (score)²`. Es una esperanza de una función
del dato, no la derivada de una ecuación muestral. -/
def bernFisher (θ : ℝ) : ℝ := ∑ x : Bool, bernP θ x * (bernScore θ x) ^ 2

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

La información de Fisher del modelo Bernoulli es `1/(θ(1-θ))`. Se calcula como
una esperanza (suma ponderada por las probabilidades `p_θ`), lo que ilustra la
frase del libro «la información de Fisher es una esperanza». -/
theorem bernFisher_eq (θ : ℝ) (h0 : θ ≠ 0) (h1 : θ ≠ 1) :
    bernFisher θ = 1 / (θ * (1 - θ)) := by
  have h1' : (1 - θ) ≠ 0 := by intro h; apply h1; linarith
  simp only [bernFisher, Fintype.sum_bool, bernP, bernScore, if_true, if_false,
    Bool.false_eq_true]
  field_simp
  ring

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

En `θ = 1/2` la información de Fisher vale `4 ≠ 0`: es «invertible» como
Jacobiano `1 × 1`, pese a ser una esperanza. -/
theorem bernFisher_half : bernFisher (1 / 2) = 4 := by
  have h := bernFisher_eq (1 / 2) (by norm_num) (by norm_num)
  norm_num at h
  exact h

/-! ### 2. Fisher invertible no da Jacobiano muestral invertible -/

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

«Su invertibilidad no prueba por sí sola la invertibilidad de ese Jacobiano».

Testigo: la ecuación de estimación `F (u, θ) = (u - θ)²` se anula en
`(1/2, 1/2)` y su Jacobiana `∂_θ F = -2(u - θ)` se anula allí (raíz doble),
luego no es invertible; en cambio la información de Fisher en `θ = 1/2` vale
`4 ≠ 0`. -/
theorem fisher_informacion_no_da_jacobiano_invertible :
    bernFisher (1 / 2) = 4 ∧
    (fun p : ℝ × ℝ => (p.1 - p.2) ^ 2) (1 / 2, 1 / 2) = 0 ∧
    ¬ (((fderiv ℝ (fun p : ℝ × ℝ => (p.1 - p.2) ^ 2) (1 / 2, 1 / 2)).comp
        (ContinuousLinearMap.inr ℝ ℝ ℝ))).IsInvertible := by
  refine ⟨bernFisher_half, by norm_num, ?_⟩
  have hf : HasFDerivAt (fun p : ℝ × ℝ => p.1 - p.2)
      ((ContinuousLinearMap.fst ℝ ℝ ℝ) - (ContinuousLinearMap.snd ℝ ℝ ℝ)) (1 / 2, 1 / 2) :=
    hasFDerivAt_fst.sub hasFDerivAt_snd
  -- la derivada de `(u - θ)²` en `(1/2, 1/2)` es cero
  have hzero : fderiv ℝ (fun p : ℝ × ℝ => (p.1 - p.2) ^ 2) (1 / 2, 1 / 2)
      = (0 : (ℝ × ℝ) →L[ℝ] ℝ) := by
    have hh := HasFDerivAt.pow (𝕜 := ℝ) hf 2
    simpa using hh.fderiv
  have hz : ((fderiv ℝ (fun p : ℝ × ℝ => (p.1 - p.2) ^ 2) (1 / 2, 1 / 2)).comp
      (ContinuousLinearMap.inr ℝ ℝ ℝ)) = 0 := by
    rw [hzero]
    apply ContinuousLinearMap.ext
    intro v
    simp
  rw [hz, ContinuousLinearMap.isInvertible_zero_iff]
  rintro ⟨hsub, -⟩
  have h01 : (0 : ℝ) = 1 := Subsingleton.elim 0 1
  norm_num at h01

/-! ### 3. Jacobiano invertible no da existencia de solución -/

/-- Si `c ≠ 0`, el operador `c • id` sobre `ℝ` es invertible. Auxiliar. -/
theorem isInvertible_smul_id {c : ℝ} (hc : c ≠ 0) :
    (c • ContinuousLinearMap.id ℝ ℝ).IsInvertible := by
  refine ContinuousLinearMap.IsInvertible.of_inverse
    (g := c⁻¹ • ContinuousLinearMap.id ℝ ℝ) ?_ ?_
  · apply ContinuousLinearMap.ext
    intro x
    simp [smul_eq_mul, ← mul_assoc, inv_mul_cancel₀ hc]
  · apply ContinuousLinearMap.ext
    intro x
    simp [smul_eq_mul, ← mul_assoc, mul_inv_cancel₀ hc]

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

«…ni la existencia de una solución».

Testigo: `F (u, θ) = θ² + 1` en el punto `(0, 1)`. Su Jacobiana
`∂_θ F (0, 1) = 2 ≠ 0` es invertible, pero `F (0, θ) = θ² + 1 > 0` para todo
`θ ∈ ℝ`: la ecuación no tiene solución. -/
theorem jacobiano_invertible_sin_solucion :
    (((fderiv ℝ (fun p : ℝ × ℝ => p.2 ^ 2 + 1) (0, 1)).comp
        (ContinuousLinearMap.inr ℝ ℝ ℝ))).IsInvertible ∧
    ¬ ∃ θ : ℝ, (fun p : ℝ × ℝ => p.2 ^ 2 + 1) (0, θ) = 0 := by
  constructor
  · -- `∂_θ (θ² + 1) = 2θ`; en `θ = 1` vale `2`
    have hsnd : HasFDerivAt (fun p : ℝ × ℝ => p.2) (ContinuousLinearMap.snd ℝ ℝ ℝ) (0, 1) :=
      hasFDerivAt_snd
    have hg : HasFDerivAt (fun t : ℝ => t ^ 2 + 1)
        (ContinuousLinearMap.toSpanSingleton ℝ (2 : ℝ)) 1 := by
      have h : HasDerivAt (fun t : ℝ => t ^ 2 + 1) (2 : ℝ) 1 := by
        simpa using (hasDerivAt_pow 2 (1 : ℝ)).add_const 1
      simpa using h.hasFDerivAt
    have hcomp := hg.comp (0, 1) hsnd
    have hcongr : fderiv ℝ (fun p : ℝ × ℝ => p.2 ^ 2 + 1) (0, 1)
        = fderiv ℝ ((fun t : ℝ => t ^ 2 + 1) ∘ (fun p : ℝ × ℝ => p.2)) (0, 1) := rfl
    have hderiv : fderiv ℝ (fun p : ℝ × ℝ => p.2 ^ 2 + 1) (0, 1)
        = (2 : ℝ) • ContinuousLinearMap.snd ℝ ℝ ℝ := by
      rw [hcongr, hcomp.fderiv]
      apply ContinuousLinearMap.ext
      intro v
      simp [ContinuousLinearMap.toSpanSingleton_apply, smul_eq_mul, mul_comm]
    rw [hderiv]
    have h3 : ((2 : ℝ) • ContinuousLinearMap.snd ℝ ℝ ℝ).comp (ContinuousLinearMap.inr ℝ ℝ ℝ)
        = (2 : ℝ) • ContinuousLinearMap.id ℝ ℝ := by
      apply ContinuousLinearMap.ext
      intro x
      simp
    rw [h3]
    exact isInvertible_smul_id (c := 2) (by norm_num)
  · rintro ⟨θ, hθ⟩
    simp only at hθ
    nlinarith [sq_nonneg θ]

/-! ### 4. Identificación global ≠ no singularidad local -/

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

Identificación global (la aplicación de parámetros es inyectiva) **sin** no
singularidad local: `θ ↦ θ³` es inyectiva en `ℝ` y su derivada en `0` es nula,
luego no invertible. -/
theorem identificacion_sin_nonsingularidad :
    Function.Injective (fun θ : ℝ => θ ^ 3) ∧
    ¬ (fderiv ℝ (fun θ : ℝ => θ ^ 3) 0).IsInvertible := by
  constructor
  · exact (Odd.strictMono_pow (R := ℝ) (n := 3) ⟨1, by norm_num⟩).injective
  · have hzero : fderiv ℝ (fun θ : ℝ => θ ^ 3) 0 = 0 := by
      have h := hasDerivAt_pow 3 (0 : ℝ)
      simpa using h.hasFDerivAt.fderiv
    rw [hzero, ContinuousLinearMap.isInvertible_zero_iff]
    rintro ⟨hsub, -⟩
    have h01 : (0 : ℝ) = 1 := Subsingleton.elim 0 1
    norm_num at h01

/-- book: apendices/apendice_medido.typ:187 (key: prop:appE-condiciones-funcion-implicita)

No singularidad local **sin** identificación global: `Complex.exp` tiene
derivada invertible en todo punto (`exp z ≠ 0` para todo `z`), pero no es
inyectiva (es periódica de periodo `2πi`). Modela una reparametrización de un
modelo identificado por una aplicación con Jacobiano nunca singular que, sin
embargo, no identifica el parámetro. -/
theorem nonsingularidad_sin_identificacion :
    (fderiv ℂ Complex.exp 0).IsInvertible ∧ ¬ Function.Injective Complex.exp := by
  constructor
  · have hderiv : fderiv ℂ Complex.exp 0 = ContinuousLinearMap.id ℂ ℂ := by
      have h := (Complex.hasDerivAt_exp 0).hasFDerivAt
      have h2 : ContinuousLinearMap.toSpanSingleton ℂ (Complex.exp 0)
          = ContinuousLinearMap.id ℂ ℂ := by
        apply ContinuousLinearMap.ext
        intro z
        simp [ContinuousLinearMap.toSpanSingleton_apply, Complex.exp_zero]
      rw [h2] at h
      exact h.fderiv
    rw [hderiv]
    simpa using ContinuousLinearMap.isInvertible_equiv
      (f := ContinuousLinearEquiv.refl ℂ ℂ)
  · intro hinj
    have hT : (2 * (Real.pi : ℂ) * Complex.I) ≠ 0 := by
      have hpi : (Real.pi : ℂ) ≠ 0 := by
        simpa using (Complex.ofReal_ne_zero.mpr Real.pi_ne_zero)
      exact mul_ne_zero (mul_ne_zero (by norm_num) hpi) Complex.I_ne_zero
    have hper := Complex.exp_periodic 0
    -- `exp (0 + T) = exp 0`, y la inyectividad fuerza `0 + T = 0`
    have h0 : (0 : ℂ) + (2 * (Real.pi : ℂ) * Complex.I) = 0 := hinj hper
    exact hT (by simpa using h0)

end

end AppECond
