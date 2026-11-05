import Mathlib
import Book.Foundation
import Book.Cap05Representacion

/-!
# Book.SSCH — hilo longitudinal SSCH (ex:ssch-cap09, ex:ssch-cap07)

El ejemplo sintético del libro (declarado sintético en la fuente): una
decisión de seguimiento. No utiliza datos clínicos ni representa una
recomendación terapéutica (cap05_incrustacion.typ:262).

Estado `θ ∈ {0,1}` (necesidad de seguimiento intensificado), señal
`X ∈ {0,1}` con `P₀(X=1) = 1/5` y `P₁(X=1) = 4/5` (el libro escribe 0.2 y
0.8), acciones ordinario (`a = 0`) e intensificado (`a = 1`), pérdidas
ilustrativas `L(0,0)=0, L(0,1)=1, L(1,0)=4, L(1,1)=0`, prior `ν(1) = 3/10`.

Todas las cifras se verifican como igualdades racionales exactas (plan
§4: prohibido verificar con flotantes); sin `native_decide` (plan §6).
-/

open Finset BigOperators

/-! ## Modelo -/

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
señal del SSCH: `P₀(X=1) = 1/5`, `P₁(X=1) = 4/5` (racionales exactos). -/
noncomputable def qSSCH : Bool → Bool → ℝ :=
  fun θ x => if θ then (if x then 4 / 5 else 1 / 5) else (if x then 1 / 5 else 4 / 5)

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
pérdidas ilustrativas: `L(0,0)=0, L(0,1)=1, L(1,0)=4, L(1,1)=0`
(ordinario `a = 0`, intensificado `a = 1`). -/
def LSSCH : Bool → Bool → ℝ :=
  fun θ a => if θ then (if a then 0 else 4) else (if a then 1 else 0)

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
prior del ejemplo: `ν(1) = 3/10`. -/
noncomputable def nuSSCH : Bool → ℝ := fun θ => if θ then 3 / 10 else 7 / 10

/-! ## Tabla de riesgos de las cuatro reglas deterministas -/

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
fila «siempre a=0» de la tabla: `R(0) = 0`, `R(1) = 4`, riesgo de Bayes
bajo `ν(1) = 3/10`: `6/5` (el libro escribe 1.20).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_regla_ordinario :
    risk qSSCH LSSCH false (fun _ => false) = 0
    ∧ risk qSSCH LSSCH true (fun _ => false) = 4
    ∧ (∑ θ, nuSSCH θ * risk qSSCH LSSCH θ (fun _ => false)) = 6 / 5 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [risk, qSSCH, LSSCH]
  · simp [risk, qSSCH, LSSCH]
    norm_num
  · rw [Fintype.sum_bool]
    simp [risk, qSSCH, LSSCH, nuSSCH]
    norm_num

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
fila «siempre a=1» de la tabla: `R(0) = 1`, `R(1) = 0`, riesgo de Bayes
`7/10` (el libro: 0.70).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_regla_intensificado :
    risk qSSCH LSSCH false (fun _ => true) = 1
    ∧ risk qSSCH LSSCH true (fun _ => true) = 0
    ∧ (∑ θ, nuSSCH θ * risk qSSCH LSSCH θ (fun _ => true)) = 7 / 10 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [risk, qSSCH, LSSCH]
    norm_num
  · simp [risk, qSSCH, LSSCH]
  · rw [Fintype.sum_bool]
    simp [risk, qSSCH, LSSCH, nuSSCH]
    norm_num

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
fila «a = X» (seguir la señal): `R(0) = 1/5`, `R(1) = 4/5`, riesgo de
Bayes `19/50` (el libro: 0.20, 0.80, 0.38). Es la regla de Bayes y minimax
entre las cuatro deterministas.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_regla_seguir :
    risk qSSCH LSSCH false (fun x => x) = 1 / 5
    ∧ risk qSSCH LSSCH true (fun x => x) = 4 / 5
    ∧ (∑ θ, nuSSCH θ * risk qSSCH LSSCH θ (fun x => x)) = 19 / 50 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [risk, qSSCH, LSSCH]
  · simp [risk, qSSCH, LSSCH]
    norm_num
  · rw [Fintype.sum_bool]
    simp [risk, qSSCH, LSSCH, nuSSCH]
    norm_num

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
fila «a = 1−X» (invertir la señal): `R(0) = 4/5`, `R(1) = 16/5`, riesgo de
Bayes `38/25` (el libro: 0.80, 3.20, 1.52).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_regla_invertir :
    risk qSSCH LSSCH false (fun x => !x) = 4 / 5
    ∧ risk qSSCH LSSCH true (fun x => !x) = 16 / 5
    ∧ (∑ θ, nuSSCH θ * risk qSSCH LSSCH θ (fun x => !x)) = 38 / 25 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [risk, qSSCH, LSSCH]
  · simp [risk, qSSCH, LSSCH]
    norm_num
  · rw [Fintype.sum_bool]
    simp [risk, qSSCH, LSSCH, nuSSCH]
    norm_num

/-! ## Posteriores, umbral y regla de Bayes -/

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
posteriores tras la señal: `P(θ=1|X=1) = 12/19`, `P(θ=0|X=1) = 7/19`,
`P(θ=1|X=0) = 3/31`, `P(θ=0|X=0) = 28/31`.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_posterior :
    post qSSCH nuSSCH true true = 12 / 19
    ∧ post qSSCH nuSSCH true false = 7 / 19
    ∧ post qSSCH nuSSCH false true = 3 / 31
    ∧ post qSSCH nuSSCH false false = 28 / 31 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuSSCH]; norm_num :
      mPred qSSCH nuSSCH true ≠ 0)]
    simp [mPred, qSSCH, nuSSCH]
    norm_num
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuSSCH]; norm_num :
      mPred qSSCH nuSSCH true ≠ 0)]
    simp [mPred, qSSCH, nuSSCH]
    norm_num
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuSSCH]; norm_num :
      mPred qSSCH nuSSCH false ≠ 0)]
    simp [mPred, qSSCH, nuSSCH]
    norm_num
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuSSCH]; norm_num :
      mPred qSSCH nuSSCH false ≠ 0)]
    simp [mPred, qSSCH, nuSSCH]
    norm_num

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
pérdidas posteriores de las acciones: `4p` (ordinario) y `1−p`
(intensificado), con `p = b(1)`; base del umbral del libro.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_perdidas_posteriores (b : Bool → ℝ) :
    ell LSSCH b false = 4 * b true ∧ ell LSSCH b true = b false := by
  refine ⟨?_, ?_⟩
  · rw [ell, Fintype.sum_bool]
    simp [LSSCH]
    ring
  · rw [ell, Fintype.sum_bool]
    simp [LSSCH]

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
umbral de indiferencia: para una creencia normalizada, intensificar
(`a=1`) no es peor que ordinario (`a=0`) exactamente cuando `p ≥ 1/5`;
la indiferencia es `4p = 1−p` (el libro: «se intensifica cuando p > 1/5»).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_umbral (b : Bool → ℝ) (hnorm : b false + b true = 1) :
    ell LSSCH b true ≤ ell LSSCH b false ↔ 1 / 5 ≤ b true := by
  have h1 : ell LSSCH b false = 4 * b true := (ssch_perdidas_posteriores b).1
  have h2 : ell LSSCH b true = b false := (ssch_perdidas_posteriores b).2
  have hb : b false = 1 - b true := by linarith
  rw [h1, h2, hb]
  constructor
  · intro h
    have h5 : (1:ℝ) ≤ b true * 5 := by linarith
    exact (div_le_iff₀ (by norm_num : (0:ℝ) < 5)).mpr h5
  · intro h
    have h5 : (1:ℝ) ≤ b true * 5 :=
      (div_le_iff₀ (by norm_num : (0:ℝ) < 5)).mp h
    linarith

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
la regla de Bayes sigue la señal: tras `X=1` conviene intensificar
(`7/19 < 48/19`); tras `X=0` conviene ordinario (`12/31 < 28/31`).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_bayes_sigue :
    ell LSSCH (post qSSCH nuSSCH true) true < ell LSSCH (post qSSCH nuSSCH true) false
    ∧ ell LSSCH (post qSSCH nuSSCH false) false
        < ell LSSCH (post qSSCH nuSSCH false) true := by
  have h1 : ell LSSCH (post qSSCH nuSSCH true) true = 7 / 19 := by
    simp [ell, post, mPred, qSSCH, nuSSCH, LSSCH]
    norm_num
  have h2 : ell LSSCH (post qSSCH nuSSCH true) false = 48 / 19 := by
    simp [ell, post, mPred, qSSCH, nuSSCH, LSSCH]
    norm_num
  have h3 : ell LSSCH (post qSSCH nuSSCH false) false = 12 / 31 := by
    simp [ell, post, mPred, qSSCH, nuSSCH, LSSCH]
    norm_num
  have h4 : ell LSSCH (post qSSCH nuSSCH false) true = 28 / 31 := by
    simp [ell, post, mPred, qSSCH, nuSSCH, LSSCH]
    norm_num
  rw [h1, h2, h3, h4]
  norm_num

/-! ## Identidad con retornos -/

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
retornos promedio sobre señales de la regla «seguir la señal» en la
familia de MDP: `J₀ = -1/5`, `J₁ = -4/5` (el libro: -0.2 y -0.8), por la
identidad `thm:ch9-isomorfismo` ya probada. Son retornos promedio sobre
señales, no valores condicionados en una señal particular.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_retornos :
    mdpReturn qSSCH LSSCH false (fun x => x) = -(1 / 5)
    ∧ mdpReturn qSSCH LSSCH true (fun x => x) = -(4 / 5) := by
  refine ⟨?_, ?_⟩
  · rw [ch9_isomorfismo, ssch_regla_seguir.1]
  · rw [ch9_isomorfismo, ssch_regla_seguir.2.1]

/-! ## Observación costosa: la recursión `W` -/

/-- book: capitulos/cap05_incrustacion.typ:262 (key: ex:ssch-cap09) —
decidir inmediatamente tiene riesgo mínimo `7/10` (`ℓ(ν,1) = 7/10` y
`ℓ(ν,0) = 6/5`); con una señal de costo `1/20`, la recursión bayesiana da
`W₁ = 1/20 + 19/50·(7/19) + 31/50·(12/31) = 43/100 < 7/10`: conviene
observar (el libro: 0.05 + 0.38 = 0.43 < 0.7). Aplica la recursión con
una observación disponible; no demuestra optimalidad de una política
clínica longitudinal (declaración del libro).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_secuencial :
    W qSSCH LSSCH (1 / 20) 0 nuSSCH = 7 / 10
    ∧ W qSSCH LSSCH (1 / 20) 1 nuSSCH = 43 / 100
    ∧ (43 / 100 : ℝ) < 7 / 10 := by
  refine ⟨?_, ?_, ?_⟩
  · simp [W, wStop, ell, LSSCH, nuSSCH]
    norm_num
  · rw [W_succ, Fintype.sum_bool]
    have hw : wStop LSSCH nuSSCH = 7 / 10 := by
      simp [wStop, ell, LSSCH, nuSSCH]
      norm_num
    have h1 : W qSSCH LSSCH (1 / 20) 0 (post qSSCH nuSSCH true) = 7 / 19 := by
      simp [W, wStop, ell, LSSCH, post, mPred, qSSCH, nuSSCH]
      norm_num
    have h2 : W qSSCH LSSCH (1 / 20) 0 (post qSSCH nuSSCH false) = 12 / 31 := by
      simp [W, wStop, ell, LSSCH, post, mPred, qSSCH, nuSSCH]
      norm_num
    have hm1 : mPred qSSCH nuSSCH true = 19 / 50 := by
      simp [mPred, qSSCH, nuSSCH]
      norm_num
    have hm2 : mPred qSSCH nuSSCH false = 31 / 50 := by
      simp [mPred, qSSCH, nuSSCH]
      norm_num
    rw [hw, hm1, h2, hm2, h1]
    norm_num
  · norm_num

/-! ## Minimax aleatorizado (cap02_wald.typ:183) -/

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — riesgo de
una regla aleatorizada `δ : Y → A → ℝ` (filas no negativas que suman 1):
`R̄(θ, δ) = ∑_y P_θ(y) ∑_a δ(y,a) L(θ,a)`. -/
noncomputable def rrisk (δ : Bool → Bool → ℝ) (θ : Bool) : ℝ :=
  ∑ y, qSSCH θ y * ∑ a, δ y a * LSSCH θ a

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — prior del
certificado minimax: `ν*(1) = 1/2`. -/
noncomputable def nuStar : Bool → ℝ := fun _ => 1 / 2

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — regla
aleatorizada óptima en peor caso: intensificar siempre si `X = 1`; si
`X = 0`, intensificar con probabilidad `3/8` (y ordinario con `5/8`). -/
noncomputable def dStar : Bool → Bool → ℝ :=
  fun y a => if y then (if a then 1 else 0) else (if a then 3 / 8 else 5 / 8)

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — los dos
riesgos de `δ*` valen `1/2` (regla igualadora; el libro: «sus riesgos son
ambos 1/2, inferiores a 0.8»).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_minimax_riesgos :
    rrisk dStar false = 1 / 2 ∧ rrisk dStar true = 1 / 2 := by
  refine ⟨?_, ?_⟩
  · simp [rrisk, qSSCH, LSSCH, dStar]
    norm_num
  · simp [rrisk, qSSCH, LSSCH, dStar]
    norm_num

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — certificado
por el prior `ν*(1) = 1/2`: el posterior de `θ=1` tras `X=0` es exactamente
`1/5` (el umbral de indiferencia); tras `X=1` es `4/5` y conviene
intensificar. Junto con el riesgo constante de `δ*`, este es el
certificado del libro.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_minimax_certificado :
    post qSSCH nuStar false true = 1 / 5
    ∧ post qSSCH nuStar true true = 4 / 5 := by
  refine ⟨?_, ?_⟩
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuStar]; norm_num :
      mPred qSSCH nuStar false ≠ 0)]
    simp [mPred, qSSCH, nuStar]
    norm_num
  · rw [post]
    rw [if_neg (by simp [mPred, qSSCH, nuStar]; norm_num :
      mPred qSSCH nuStar true ≠ 0)]
    simp [mPred, qSSCH, nuStar]
    norm_num

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — cota minimax
en la clase ampliada: toda regla aleatorizada (filas no negativas que
suman 1) tiene riesgo `≥ 1/2` en alguno de los dos modelos. Prueba
directa: `R̄(0,δ) + R̄(1,δ) = 1 + 3·δ(X=1, a=0) ≥ 1`, luego algún modelo
llega a `1/2`.
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_minimax_cota (δ : Bool → Bool → ℝ)
    (h0 : ∀ y a, 0 ≤ δ y a) (h1 : ∀ y, ∑ a, δ y a = 1) :
    1 / 2 ≤ rrisk δ false ∨ 1 / 2 ≤ rrisk δ true := by
  have hr1 : δ true true + δ true false = 1 := by
    have h := h1 true
    rw [Fintype.sum_bool] at h
    exact h
  have hr0 : δ false true + δ false false = 1 := by
    have h := h1 false
    rw [Fintype.sum_bool] at h
    exact h
  have hsum : rrisk δ false + rrisk δ true = 1 + 3 * δ true false := by
    simp only [rrisk, qSSCH, LSSCH, Fintype.sum_bool]
    norm_num
    linarith
  by_contra hcon
  push Not at hcon
  have h3 : 0 ≤ δ true false := h0 true false
  linarith

/-- book: capitulos/cap02_wald.typ:183 (key: ex:ssch-cap07) — `δ*` es
minimax en la clase ampliada: su peor riesgo es exactamente `1/2` y
ninguna regla aleatorizada baja de `1/2` en peor caso. La elección de la
clase cambia la respuesta aunque los datos y las pérdidas sean idénticos
(observación del libro).
Origen: F1 2026-11-04 (nuevo). -/
theorem ssch_minimax (δ : Bool → Bool → ℝ)
    (h0 : ∀ y a, 0 ≤ δ y a) (h1 : ∀ y, ∑ a, δ y a = 1) :
    max (rrisk dStar false) (rrisk dStar true) = 1 / 2
    ∧ 1 / 2 ≤ max (rrisk δ false) (rrisk δ true) := by
  have hr := ssch_minimax_riesgos
  refine ⟨?_, ?_⟩
  · rw [hr.1, hr.2, max_self]
  · rcases ssch_minimax_cota δ h0 h1 with hc | hc
    · exact le_max_of_le_left hc
    · exact le_max_of_le_right hc
