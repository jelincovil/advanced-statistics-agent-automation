import Mathlib

/-!
# Book.SSCHCap04M7 / SSCHCap05M7 — `ex:ssch-cap04-b` y `ex:ssch-cap05-b`

Formaliza dos ejemplos de `capitulos/cap10_casos.typ` (enjambre `smw9820kx`,
dirección `d7`):

* `ex:ssch-cap04-b` (:125): comparación de dos políticas del simulador,
  `Δ = V^{π₃}(s₃) − V^{π₂}(s₃)`, contraste `H₀: Δ ≤ 0` frente a `H₁: Δ > 0`
  con un único análisis prefijado; realización `Δ̂ ≈ 4.606798`, error estándar
  `0.882817`, intervalo bilateral normal aproximado al 95% `[2.876508, 6.337087]`.
* `ex:ssch-cap05-b` (:148): distribución asintótica de `V̂^π`;
  `δV^π = γ(I − γP^π)^{-1}(δP^π)V^π`, derivada por entrada
  `g^π_{s,a,j} = γ A^π_{s₃,s} π(a|s) V^π_j`, usada «en direcciones cuyas
  entradas suman cero», y bootstrap paramétrico del diseño.

Fidelidad declarada:

* En `ex:ssch-cap04-b` se formaliza la **aritmética y la regla de decisión**
  con los valores redondeados publicados: los extremos del intervalo quedan
  entre los valores impresos por el programa (tolerancia de redondeo
  declarada, `[2.8764, 2.8766]` y `[6.3370, 6.3372]`), el intervalo se calcula
  como `Δ̂ ± 1.96·SE`, y se prueba la equivalencia «el intervalo excluye el
  cero ⟺ se rechaza `H₀`», que es lo único que usa el dictamen. La cola
  normal `p = 9.029·10⁻⁸` no se re-deriva: se formaliza el criterio en la
  escala estandarizada (`Δ̂/SE` frente al cuantil `1.6448536`), que es
  equivalente bajo el modelo normal declarado. Nada de aritmética flotante
  (plan §4): los decimales publicados entran como racionales exactos.
* En `ex:ssch-cap05-b` se formaliza la **identidad de la derivada**: la
  ecuación de Bellman linealizada `δV = γP δV + γ δP V` tiene solución única
  (contracción, `ex:ssch-cap03-b`), y si `A` es una inversa por la izquierda de
  `(I − γP)` aditiva y homogénea entonces `δV = γ A (δP V)`. También que una
  dirección `δP` con filas de suma cero preserva la estocasticidad por filas,
  y que perturbar una sola entrada `(s,a,j)` de la dinámica induce
  `u(s') = 1{s'=s}·π(a|s)·V_j`, de donde `g^π_{s,a,j} = γ A_{s₃,s}π(a|s)V_j`.
  La escala `√m` y el bootstrap paramétrico se enuncian en prosa: son
  afirmaciones asintóticas del CLT multinomial, no re-derivadas aquí.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHCap04M7

/-! ## La comparación de dos políticas: aritmética publicada -/

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — diferencia
estimada `Δ̂ = V̂^{π₃}(s₃) − V̂^{π₂}(s₃)` de la realización generada. -/
noncomputable def dHat : ℝ := 4.606798

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — error estándar
`δ` de la diferencia: `0.882817`. -/
noncomputable def seDelta : ℝ := 0.882817

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — cuantil
normal bilateral al 95% usado por el programa (`1.96`). -/
noncomputable def z95 : ℝ := 1.96

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — cuantil
normal unilateral al 5% usado por el contraste prefijado (`1.6448536`). -/
noncomputable def z05 : ℝ := 1.6448536

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — el error
estándar es positivo; sin eso la regla de decisión no está bien definida. -/
theorem seDelta_pos : 0 < seDelta := by
  simp only [seDelta]
  norm_num

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — extremo
inferior del intervalo bilateral: `Δ̂ − 1.96·SE = 2.876476…`, que cae en
`[2.8764, 2.8766]` y contiene el valor publicado `2.876508` (la discrepancia
es el redondeo de `Δ̂` y `SE` a seis decimales en el libro). -/
theorem ci95_lo :
    2.8764 ≤ dHat - z95 * seDelta ∧ dHat - z95 * seDelta ≤ 2.8766 := by
  simp only [dHat, seDelta, z95]
  norm_num

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — extremo
superior: `Δ̂ + 1.96·SE = 6.337119…`, en `[6.3370, 6.3372]`, que contiene el
valor publicado `6.337087`. -/
theorem ci95_hi :
    6.3370 ≤ dHat + z95 * seDelta ∧ dHat + z95 * seDelta ≤ 6.3372 := by
  simp only [dHat, seDelta, z95]
  norm_num

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — el intervalo
bilateral al 95% **excluye el cero**: su extremo inferior es positivo. -/
theorem ci95_excluye_cero : 0 < dHat - z95 * seDelta := by
  have h := ci95_lo.1
  linarith

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — **regla de
decisión**: para un error estándar positivo, «el límite inferior `Δ̂ − c·SE`
es positivo» equivale a «el estadístico estandarizado `Δ̂/SE` supera el
cuantil `c`». Es la equivalencia que usa el dictamen del ejemplo. -/
theorem regla_decision (c x s : ℝ) (hs : 0 < s) :
    0 < x - c * s ↔ c < x / s := by
  rw [lt_div_iff₀ hs]
  constructor <;> intro h <;> linarith

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — **se rechaza
`H₀: Δ ≤ 0` al 5% unilateral** con el análisis prefijado: el estadístico
estandarizado `Δ̂/SE = 5.218…` supera `1.6448536`. -/
theorem rechazo_unilateral : z05 < dHat / seDelta := by
  have h : 0 < dHat - z05 * seDelta := by
    simp only [dHat, seDelta, z05]
    norm_num
  exact (regla_decision z05 dHat seDelta seDelta_pos).mp h

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — el contraste
unilateral al 5% y el intervalo bilateral al 95% **coinciden en este caso**:
como el intervalo excluye el cero, el límite unilateral al 5% también es
positivo. -/
theorem unilateral_positivo : 0 < dHat - z05 * seDelta := by
  simp only [dHat, seDelta, z05]
  norm_num

/-- book: capitulos/cap10_casos.typ:125 (key: ex:ssch-cap04-b) — la decisión es
sensible al estadístico: para `Δ̂` fijo, el límite inferior unilateral es
estrictamente decreciente en `SE`. Por eso «cambiar el error estándar», y no
sólo el signo de la diferencia, cambia el dictamen. -/
theorem limite_decreciente_en_se {x c s₁ s₂ : ℝ} (hc : 0 < c) (h : s₁ < s₂) :
    x - c * s₂ < x - c * s₁ := by
  nlinarith

end SSCHCap04M7

namespace SSCHCap05M7

/-! ## Perturbación de la ecuación del valor -/

/-- book: capitulos/cap10_casos.typ:148 (key: ex:ssch-cap05-b) — kernel
estocástico por filas (el mismo predicado de `ex:ssch-cap03-b`). -/
def rowStoch {n : ℕ} (P : Fin n → Fin n → ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ (∀ i, ∑ j, P i j = 1)

/-- book: capitulos/cap10_casos.typ:148 (key: ex:ssch-cap05-b) — **unicidad de
la ecuación linealizada**: si dos vectores resuelven
`δV = γP δV + γ δP V`, coinciden. Es la contracción de `ex:ssch-cap03-b`
aplicada a la diferencia (que resuelve la ecuación homogénea). -/
theorem dV_unique {n : ℕ} [NeZero n] {P : Fin n → Fin n → ℝ} {γ : ℝ}
    (hP : rowStoch P) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) {f : Fin n → ℝ}
    {w₁ w₂ : Fin n → ℝ}
    (h₁ : ∀ i, w₁ i = γ * ∑ j, P i j * w₁ j + f i)
    (h₂ : ∀ i, w₂ i = γ * ∑ j, P i j * w₂ j + f i) : w₁ = w₂ := by
  funext i
  have hu : ∀ i, (w₁ - w₂) i = γ * ∑ j, P i j * (w₁ - w₂) j := by
    intro i
    simp only [Pi.sub_apply, h₁ i, h₂ i]
    have h : γ * ∑ j, P i j * w₁ j + f i - (γ * ∑ j, P i j * w₂ j + f i)
        = γ * (∑ j, P i j * w₁ j - ∑ j, P i j * w₂ j) := by ring
    rw [h, ← Finset.sum_sub_distrib]
    congr 1
    exact Finset.sum_congr rfl fun j _ => by ring
  obtain ⟨i₀, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (Fin n)) (fun i => |(w₁ - w₂) i|)
      ⟨0, Finset.mem_univ 0⟩
  have hle : ∀ j, |(w₁ - w₂) j| ≤ |(w₁ - w₂) i₀| := fun j => hmax j (Finset.mem_univ j)
  have h2 : |∑ j, P i₀ j * (w₁ - w₂) j| ≤ |(w₁ - w₂) i₀| := by
    calc |∑ j, P i₀ j * (w₁ - w₂) j| ≤ ∑ j, |P i₀ j * (w₁ - w₂) j| :=
          Finset.abs_sum_le_sum_abs _ _
      _ = ∑ j, P i₀ j * |(w₁ - w₂) j| := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [abs_mul, abs_of_nonneg (hP.1 i₀ j)]
      _ ≤ ∑ j, P i₀ j * |(w₁ - w₂) i₀| :=
        Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left (hle j) (hP.1 i₀ j)
      _ = |(w₁ - w₂) i₀| := by rw [← Finset.sum_mul, hP.2, one_mul]
  have h4 : |(w₁ - w₂) i₀| = γ * |∑ j, P i₀ j * (w₁ - w₂) j| := by
    rw [hu i₀, abs_mul, abs_of_nonneg hγ0]
  have h3 : |(w₁ - w₂) i₀| ≤ γ * |(w₁ - w₂) i₀| := by
    calc |(w₁ - w₂) i₀| = γ * |∑ j, P i₀ j * (w₁ - w₂) j| := h4
      _ ≤ γ * |(w₁ - w₂) i₀| := mul_le_mul_of_nonneg_left h2 hγ0
  have h5 : |(w₁ - w₂) i₀| = 0 := by
    have hpos : 0 < 1 - γ := by linarith
    nlinarith [abs_nonneg ((w₁ - w₂) i₀)]
  have h6 : |(w₁ - w₂) i| = 0 := le_antisymm (by rw [← h5]; exact hle i) (abs_nonneg _)
  simpa [sub_eq_zero] using abs_eq_zero.mp h6

/-- book: capitulos/cap10_casos.typ:148 (key: ex:ssch-cap05-b) — **la fórmula
del resolvente**: si `A` invierte `(I − γP)` por la izquierda, es aditiva y
homogénea, y `δV` resuelve la ecuación linealizada, entonces
`δV = γ·A(δP V)`, que es `δV^π = γ(I − γP^π)^{-1}(δP^π)V^π`. -/
theorem resolvent_formula {n : ℕ} {P : Fin n → Fin n → ℝ} {γ : ℝ}
    {A : (Fin n → ℝ) → (Fin n → ℝ)}
    (hA_id : ∀ w, A (fun i => w i - γ * ∑ j, P i j * w j) = w)
    (hA_smul : ∀ (c : ℝ) (w : Fin n → ℝ), A (fun i => c * w i) = c • A w)
    {V dV : Fin n → ℝ} {dP : Fin n → Fin n → ℝ}
    (hdV : ∀ i, dV i = γ * ∑ j, P i j * dV j + γ * ∑ j, dP i j * V j) :
    dV = fun i => γ * A (fun i => ∑ j, dP i j * V j) i := by
  set u : Fin n → ℝ := fun i => ∑ j, dP i j * V j with hu
  have hlin : (fun i => dV i - γ * ∑ j, P i j * dV j) = fun i => γ * u i := by
    funext i
    rw [hdV i, hu]
    ring
  have key : dV = A (fun i => γ * u i) := by
    conv_lhs => rw [← hA_id dV]
    rw [hlin]
  rw [key, hA_smul, hu]
  rfl

/-- book: capitulos/cap10_casos.typ:148 (key: ex:ssch-cap05-b) — **direcciones
de suma cero**: si `δP` tiene filas de suma cero, la matriz perturbada
`P + δP` sigue siendo estocástica por filas. Es lo que hace que la derivada se
tome «en direcciones cuyas entradas suman cero». -/
theorem rowsum_zero_perturbation {n : ℕ} {P dP : Fin n → Fin n → ℝ}
    (hP : ∀ i, ∑ j, P i j = 1) (hdP : ∀ i, ∑ j, dP i j = 0) (i : Fin n) :
    ∑ j, (P i j + dP i j) = 1 := by
  rw [Finset.sum_add_distrib, hP i, hdP i, add_zero]

/-- book: capitulos/cap10_casos.typ:148 (key: ex:ssch-cap05-b) — **perturbar
una sola entrada**: con `δP_{s',j'} = 1{s'=s ∧ j'=j}·c` (la entrada de la
dinámica inducida por `π(a|s)`), la dirección inducida sobre el valor es
`u(s') = 1{s'=s}·c·V_j`, que es el ingrediente de
`g^π_{s,a,j} = γ A_{s₃,s}π(a|s)V_j`. -/
theorem perturbation_single_entry {n : ℕ} (s j : Fin n) (c : ℝ) (V : Fin n → ℝ) :
    (fun i => ∑ j', (if i = s ∧ j' = j then c else 0) * V j')
      = fun i => if i = s then c * V j else 0 := by
  funext i
  by_cases hi : i = s
  · subst hi
    rw [if_pos rfl]
    rw [Finset.sum_eq_single j]
    · simp
    · intro b _ hb
      simp [hb]
    · intro h
      exact absurd (Finset.mem_univ j) h
  · rw [if_neg hi]
    refine Finset.sum_eq_zero fun j' _ => ?_
    simp [hi]

end SSCHCap05M7
