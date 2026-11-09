import Mathlib

/-!
# Book.SSCHCap02M7 — `ex:ssch-cap02`: el estadístico suficiente de las transiciones

Formaliza el ejemplo `ex:ssch-cap02` de `capitulos/cap10_casos.typ:70`
(enjambre `smw9820kx`, dirección `d7`).

El libro escribe la verosimilitud observada como

  `L(θ; X) = h(X) · ∏_{(s,a,j)} θ_{s,a,j}^{N_{s,a,j}}`

y concluye que los conteos `N_{s,a,j}` son suficientes bajo ese modelo; advierte
que el número de visitas a una fila puede depender de las transiciones
anteriores, de modo que no es automáticamente ancilar, y que el cálculo
posterior usa un *diseño generativo por filas*: ochenta transiciones
independientes desde cada par estado–acción (`1600` transiciones de diseño).

Fidelidad declarada: se formaliza (i) la factorización de la verosimilitud por
conteos —de la que se sigue que dos muestras con los mismos conteos dan la
misma verosimilitud para todo `θ`, es decir la suficiencia en el sentido
finito/discreto—, (ii) el recuento `20 · 80 = 1600` y (iii) el contraejemplo
aritmético que el libro señala en prosa: con tamaño de fila aleatorio, la media
de los cocientes no es el cociente de las medias, así que condicionar
retrospectivamente no equivale a un multinomial de tamaño fijo. No se formaliza
la teoría de ancilaridad de Basu (el libro sólo la invoca para descartar su uso).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset BigOperators

namespace SSCHCap02M7

/-! ## Verosimilitud de una muestra y sus conteos -/

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — verosimilitud de
una muestra `x : ι → α` con probabilidades `θ : α → ℝ`: `∏_i θ_{x_i}` (el
factor `h(X)` del libro es el que no depende de `θ`). -/
def lik {ι α : Type*} [Fintype ι] (θ : α → ℝ) (x : ι → α) : ℝ := ∏ i, θ (x i)

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — conteo
`N_j = #{i : x_i = j}`. -/
def cnt {ι α : Type*} [Fintype ι] [DecidableEq α] (x : ι → α) (j : α) : ℕ :=
  (Finset.univ.filter fun i => x i = j).card

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — factorización de
la verosimilitud por conteos: `L(θ; X) = ∏_j θ_j^{N_j}`. Es la identidad
`∏_i g(x_i) = ∏_j g_j^{#{i : x_i = j}}` agrupando la muestra por el valor
observado. -/
theorem lik_eq_prod_cnt {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]
    (θ : α → ℝ) (x : ι → α) :
    lik θ x = ∏ j : α, θ j ^ cnt x j := by
  have h := Finset.prod_comp (s := (Finset.univ : Finset ι)) (f := θ) (g := x)
  rw [lik]
  rw [h]
  refine Finset.prod_subset (Finset.subset_univ _) ?_
  intro j _ hj
  have hzero : cnt x j = 0 := by
    rw [cnt, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    intro i _ hx
    exact hj (hx ▸ Finset.mem_image_of_mem x (Finset.mem_univ i))
  simp only [cnt] at hzero ⊢
  rw [hzero, pow_zero]

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — **suficiencia de
los conteos**, versión finita: si dos muestras tienen los mismos conteos
`N_j`, entonces tienen la misma verosimilitud para todo `θ`. La verosimilitud
relativa no depende de la muestra individual. -/
theorem lik_eq_of_cnt_eq {ι α : Type*} [Fintype ι] [Fintype α] [DecidableEq α]
    (θ : α → ℝ) {x y : ι → α} (h : ∀ j, cnt x j = cnt y j) :
    lik θ x = lik θ y := by
  rw [lik_eq_prod_cnt, lik_eq_prod_cnt]
  exact Finset.prod_congr rfl fun j _ => by rw [h j]

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — los conteos son
un estadístico: son función de la muestra. -/
theorem cnt_eq_of_eq {ι α : Type*} [Fintype ι] [DecidableEq α] {x y : ι → α}
    (h : x = y) : ∀ j, cnt x j = cnt y j := by
  subst h
  exact fun j => rfl

/-! ## El diseño generativo por filas: `20 · 80 = 1600` -/

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — el diseño fija
ochenta transiciones independientes por fila estado–acción: veinte filas,
`1600` transiciones de diseño (no doscientos pacientes ni una trayectoria). -/
theorem diseno_filas_total :
    Fintype.card (Fin 5 × Fin 4) = 20 ∧ Fintype.card (Fin 5 × Fin 4) * 80 = 1600 := by
  simp [Fintype.card_prod]

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — «guardar cien
conteos basta»: `20` filas × `5` destinos posibles. -/
theorem cien_conteos : Fintype.card (Fin 5 × Fin 4 × Fin 5) = 100 := by
  simp [Fintype.card_prod]

/-! ## El contraejemplo del tamaño de fila aleatorio -/

/-- book: capitulos/cap10_casos.typ:70 (key: ex:ssch-cap02) — **la media de los
cocientes no es el cociente de las medias.** Con un tamaño de fila aleatorio
`M` (`M = 1` con probabilidad `1/2`, `M = 2` con probabilidad `1/2`) y conteo
`N` (`N = 1` en el primer caso, `N = 0` en el segundo), `E[N/M] = 1/2`
mientras que `E[N]/E[M] = 1/3`. Por eso condicionar retrospectivamente en un
número de visitas adaptativo no es, sin más, un multinomial de tamaño fijo:
la frecuencia `N/M` no es insesgada para `E[N]/E[M]`. -/
theorem razon_media_no_es_media_razones :
    (∑ ω : Fin 2, (1 / 2 : ℝ) * (if ω = 0 then (1 : ℝ) / 1 else (0 : ℝ) / 2)) = 1 / 2
    ∧ (∑ ω : Fin 2, (1 / 2 : ℝ) * (if ω = 0 then (1 : ℝ) else 0))
        / (∑ ω : Fin 2, (1 / 2 : ℝ) * (if ω = 0 then (1 : ℝ) else 2)) = 1 / 3 := by
  refine ⟨?_, ?_⟩
  · simp
  · simp
    norm_num

end SSCHCap02M7
