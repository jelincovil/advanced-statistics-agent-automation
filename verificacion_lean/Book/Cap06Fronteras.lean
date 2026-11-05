import Mathlib

/-!
# Book.Cap06Fronteras — cap. 6 del libro (capitulos/cap06_fallos.typ)

Transporte de conjuntos de confianza por imagen (`thm:ch9-ic`): la parte
operativa del resultado del libro, en la capa de sumas finitas.

Fidelidad declarada (plan §4): espacio muestral `Ω` finito con pesos `w ≥ 0`
de suma 1 (la ley `P`); el conjunto de confianza `C_n` es una función de la
muestra; la cobertura es la probabilidad del suceso `θ ∈ C_n`. La prueba es
la del libro: el suceso `{θ ∈ C_n}` está contenido en
`{g(θ) ∈ g(C_n)}`, y la probabilidad de un suceso no decrece al agrandarlo.
La observación del libro de que el conjunto imagen no tiene por qué ser un
intervalo (y que su envolvente intervalar conserva la desigualdad cuando
está bien definida) es comentario, no parte formalizable aquí.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

universe u

section IC

variable {Ω Θ : Type u} [Fintype Ω] [Fintype Θ] [DecidableEq Θ]

/-- book: capitulos/cap06_fallos.typ:181 (key: thm:ch9-ic) —
transporte de conjuntos de confianza: si `C_n` cubre a `θ` con probabilidad
`≥ 1 - α`, el conjunto imagen `g(C_n)` cubre a `g(θ)` con la misma cota.
La cobertura puede aumentar; el conjunto imagen no es necesariamente un
intervalo.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch9_ic (w : Ω → ℝ) (hw : ∀ ω, 0 ≤ w ω) (hw1 : ∑ ω, w ω = 1)
    (θ : Θ) (g : Θ → Θ) (C : Ω → Finset Θ) (α : ℝ)
    (h : 1 - α ≤ ∑ ω, if θ ∈ C ω then w ω else 0) :
    1 - α ≤ ∑ ω, if g θ ∈ Finset.image g (C ω) then w ω else 0 := by
  refine le_trans h ?_
  refine Finset.sum_le_sum ?_
  intro ω _
  by_cases hθ : θ ∈ C ω
  · have hmem : g θ ∈ Finset.image g (C ω) := Finset.mem_image_of_mem _ hθ
    simp [hθ, hmem]
  · simp only [hθ, if_false]
    split_ifs
    · exact hw ω
    · rfl

end IC

/-! ## Contraejemplos del cap. 6 (ex:ch9-observabilidad-parcial … ex:ch6-minimax-dominada) -/

section ContraejemplosCap06

open scoped Topology

/-! ### ex:ch9-observabilidad-parcial -/

/-- Ley de la señal condicional en `Z`: `P(O = Z | Z) = 4/5`. -/
private noncomputable def qObs (z o : Bool) : ℝ := if z = o then 4 / 5 else 1 / 5

/-- book: capitulos/cap06_fallos.typ:56 (key: ex:ch9-observabilidad-parcial) —
observabilidad parcial: estado oculto `Z` con prior 1/2 y señal
condicionalmente independiente con `P(O = Z | Z) = 4/5`. Tras las
historias `(0,1)` y `(1,1)`, que comparten la última observación, los
posteriores son `P(Z=1 | 0,1) = 1/2` y `P(Z=1 | 1,1) = 16/17` (razones de
verosimilitud `1` y `16`); una decisión con umbral posterior `7/10` toma
acciones distintas. El último dato no resume la información pertinente.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch9_observabilidad_parcial :
    (∑ z : Bool, (1 / 2) * (qObs z false * qObs z true)) = 4 / 25
    ∧ (∑ z : Bool, (1 / 2) * (qObs z false * qObs z false)) = 17 / 50
    ∧ ((1 / 2) * (qObs true false * qObs true true)
          / ((1 / 2) * (qObs true false * qObs true true)
            + (1 / 2) * (qObs false false * qObs false true))) = 1 / 2
    ∧ ((1 / 2) * (qObs true true * qObs true true)
          / ((1 / 2) * (qObs true true * qObs true true)
            + (1 / 2) * (qObs false true * qObs false true))) = 16 / 17
    ∧ ((1 / 2 : ℝ) < 7 / 10 ∧ (7 / 10 : ℝ) < 16 / 17) := by
  refine ⟨?_, ?_, ?_, ?_, ⟨by norm_num, by norm_num⟩⟩
  · rw [Fintype.sum_bool]; simp only [qObs]; norm_num
  · rw [Fintype.sum_bool]; simp only [qObs]; norm_num
  · simp only [qObs]; norm_num
  · simp only [qObs]; norm_num

/-! ### ex:ch9-confounding -/

/-- Resultados potenciales M1: `Y(a) = U`. -/
private def yM1 (u a : Bool) : ℝ := if u then 1 else 0

/-- Resultados potenciales M2: `Y(a) = a`. -/
private def yM2 (u a : Bool) : ℝ := if a then 1 else 0

/-- book: capitulos/cap06_fallos.typ:91 (key: ex:ch9-confounding) —
confounding no observado: `U` Bernoulli(1/2), acción registrada `A = U`.
En M1 (`Y(a) = U`) y en M2 (`Y(a) = a`) la ley observada de `(A, Y)` es
exactamente la misma (`P(A=Y=0) = P(A=Y=1) = 1/2`, resto cero), pero
intervenir fijando `A = 1` da `E[Y(1)] = 1/2` en M1 y `1` en M2: la misma
ley observada admite valores distintos de la intervención. Ningún
estimador basado solo en esos registros distingue ambos modelos.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch9_confounding :
    (∀ a y : Bool, (∑ u, (1 / 2) * (if (u : Bool) = a then 1 else 0)
          * (if (a = u) then (1:ℝ) else 0) * (yM1 u a))
        = (∑ u, (1 / 2) * (if (u : Bool) = a then 1 else 0)
          * (if (a = u) then (1:ℝ) else 0) * (yM2 u a)))
    ∧ (∑ u, (1 / 2) * yM1 u true) = 1 / 2
    ∧ (∑ u, (1 / 2) * yM2 u true) = 1 := by
  refine ⟨?_, ?_, ?_⟩
  · intro a y
    cases a <;> cases y <;>
      simp [yM1, yM2, Fintype.sum_bool] <;> norm_num
  · norm_num [yM1, Fintype.sum_bool]
  · norm_num [yM2, Fintype.sum_bool]

/-! ### ex:ch9-fallo-mixing -/

/-- book: capitulos/cap06_fallos.typ:240 (key: ex:ch9-fallo-mixing) —
fallo por violación de mixing: `Z` Bernoulli(1/2) se elige una sola vez y
`X_t = Z` para todo `t`. La media muestral de las primeras `n`
observaciones es exactamente `Z` (nunca converge a `1/2`), y la
covarianza entre `X_0` y `X_k` es `1/4` para todo rezago.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch9_fallo_mixing (n : ℕ) (hn : 0 < n) :
    (∀ z : Bool, (∑ i : Fin n, (if z then (1:ℝ) else 0)) / (n : ℝ)
      = (if z then (1:ℝ) else 0))
    ∧ (∑ z : Bool, (1 / 2) * ((if z then 1 else 0) - 1 / 2)
          * ((if z then 1 else 0) - 1 / 2)) = 1 / 4 := by
  have hnR : ((n:ℝ)) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hn)
  have hc : (Finset.univ : Finset (Fin n)).card = n := by
    rw [Finset.card_univ, Fintype.card_fin]
  refine ⟨?_, ?_⟩
  · intro z
    cases z with
    | true =>
        show (∑ i : Fin n, (1:ℝ)) / (n:ℝ) = 1
        rw [Finset.sum_const, nsmul_eq_mul, hc, mul_one, div_self hnR]
    | false =>
        show (∑ i : Fin n, (0:ℝ)) / (n:ℝ) = 0
        rw [Finset.sum_const, nsmul_eq_mul, hc, mul_zero, zero_div]
  · rw [Fintype.sum_bool]; norm_num

/-! ### ex:ch9-fallo-overlap -/

/-- book: capitulos/cap06_fallos.typ:249 (key: ex:ch9-fallo-overlap) —
solapamiento débil: con `π_b(1) = ε > 0`, `π_e(1) = 9/10` y recompensa
`R = A`, la contribución IS vale `W = (9/10)/ε` con probabilidad `ε` y
cero en otro caso: `E[W] = 9/10` y `Var(W) = (81/100)(1/ε − 1)`. Con
`ε = 1/100` la varianza es `8019/100 = 80.19`: finita, pero grande.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch9_fallo_overlap (ε : ℝ) (hε0 : 0 < ε) (hε1 : ε ≤ 1) :
    (∑ b : Bool, (if b then ε else 1 - ε) * (if b then (9 / 10) / ε else 0)) = 9 / 10
    ∧ (∑ b : Bool, (if b then ε else 1 - ε)
          * ((if b then (9 / 10) / ε else 0)
            - (∑ b' : Bool, (if b' then ε else 1 - ε) * (if b' then (9 / 10) / ε else 0)))
          * ((if b then (9 / 10) / ε else 0)
            - (∑ b' : Bool, (if b' then ε else 1 - ε) * (if b' then (9 / 10) / ε else 0)))
      = (81 / 100) * (1 / ε - 1)) := by
  have hεne : ε ≠ 0 := ne_of_gt hε0
  have hE : (∑ b : Bool, (if b then ε else 1 - ε) * (if b then (9 / 10) / ε else 0))
      = 9 / 10 := by
    rw [Fintype.sum_bool]
    norm_num [reduceIte]
    field_simp
  constructor
  · exact hE
  · rw [Fintype.sum_bool]
    rw [hE]
    norm_num [reduceIte]
    field_simp
    ring

theorem ex_ch9_fallo_overlap_instancia :
    ((81 / 100 : ℝ) * (1 / (1 / 100) - 1)) = 8019 / 100 := by
  norm_num

/-! ### ex:ch6-memoria -/

/-- book: capitulos/cap06_fallos.typ:408 (key: ex:ch6-memoria) —
dos historias con el mismo estado resumido: en la decisión final
`S₁ = 0` siempre, con recompensa `R₁ = 1` si `A₁ = A₀` y cero en otro
caso, y `A₀` uniforme. Una regla que recuerda la acción previa
(`A₁ = A₀`) obtiene recompensa esperada `1`; cualquier regla que use
solo `S₁` (constante) y aleatorización independiente de la historia —
modelada como una acción `A₁` con ley fija `q` independiente de `A₀` —
obtiene esperanza `1/2`. El resumen borra información decisiva.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch6_memoria (q : ℝ) (hq0 : 0 ≤ q) (hq1 : q ≤ 1) :
    (∑ a₀ : Bool, (1 / 2) * (if (a₀ : Bool) = a₀ then (1:ℝ) else 0)) = 1
    ∧ (∑ a₀ : Bool, (1 / 2) * (if a₀ then q else 1 - q)) = 1 / 2 := by
  constructor
  · rw [Fintype.sum_bool]; norm_num
  · rw [Fintype.sum_bool]; norm_num [reduceIte]; linarith

/-! ### ex:ch6-minimax-dominada -/

/-- book: capitulos/cap06_fallos.typ:551 (key: ex:ch6-minimax-dominada) —
una política minimax puede ser dominada: con dos estados iniciales, las
políticas `a` y `b` tienen vectores de valor `V^a = (1,0)` y
`V^b = (0,0)`. La primera domina a la segunda, pero ambos mínimos son
`0` (ambas maximin). Bajo un prior con masa positiva en el primer
estado, solo `a` es Bayes; si el prior concentra toda su masa en el
segundo, ambas son Bayes.
Origen: F3 2026-11-05 (nuevo). -/
theorem ex_ch6_minimax_dominada (ν : Bool → ℝ)
    (hν0 : ∀ s : Bool, 0 ≤ ν s) (hν1 : ∑ s : Bool, ν s = 1) :
    (∀ s : Bool, (if s then (1:ℝ) else 0) ≥ (if s then (0:ℝ) else 0))
    ∧ (∃ s : Bool, (if s then (1:ℝ) else 0) > (if s then (0:ℝ) else 0))
    ∧ (min ((if true then (1:ℝ) else 0)) ((if false then (1:ℝ) else 0))
        = min ((if true then (0:ℝ) else 0)) ((if false then (0:ℝ) else 0)))
    ∧ (0 < ν true → ∑ s : Bool, ν s * (if s then (1:ℝ) else 0)
          > ∑ s : Bool, ν s * (if s then (0:ℝ) else 0))
    ∧ (ν true = 0 → ∑ s : Bool, ν s * (if s then (1:ℝ) else 0)
          = ∑ s : Bool, ν s * (if s then (0:ℝ) else 0)) := by
  refine ⟨?_, ⟨true, by norm_num⟩, ?_, ?_, ?_⟩
  · intro s; cases s <;> norm_num
  · norm_num
  · intro hpos
    have hνf : ν false = 1 - ν true := by
      have hh := hν1
      rw [Fintype.sum_bool] at hh
      linarith
    rw [Fintype.sum_bool, Fintype.sum_bool, hνf]
    norm_num [reduceIte]
    linarith
  · intro h0
    have hνf : ν false = 1 := by
      have hh := hν1
      rw [Fintype.sum_bool, h0] at hh
      linarith
    rw [Fintype.sum_bool, Fintype.sum_bool, h0, hνf]
    norm_num [reduceIte]

end ContraejemplosCap06
