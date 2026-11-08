import Mathlib

/-!
# Book.Cap04Suficiencia — cap. 2-3 (suficiencia, equivarianza, Rao-Blackwell, Lehmann-Scheffé)

Formalización finita/discreta de la cadena de reducción y optimalidad de
`capitulos/cap04_herramientas.typ`:

* `thm:ch2-equivarianza` — el riesgo de un estimador equivariante es
  invariante bajo el grupo (constante sobre cada órbita).
* `thm:ch2-lehmann-scheffe` — criterio de cocientes de verosimilitud para
  suficiencia minimal y minimalidad frente a cualquier otro suficiente.
* `cor:ch2-smc` — en una familia exponencial finita el estadístico natural
  es suficiente, minimal y completo (SMC).
* `thm:ch3-rao-blackwell`, `cor:ch3-rb-insesgado` — versión finita de
  Rao-Blackwell: promediar por la fibra de un suficiente no cambia la
  esperanza y no aumenta el segundo momento.
* `thm:ch3-lehmann-scheffe` — con `T` completo, la función insesgada de `T`
  es el único UMVUE (optimalidad y unicidad).
* `cor:ch3-umvue-exponencial` — en familias exponenciales regulares toda
  función insesgada del estadístico natural es el UMVUE.

Fidelidad declarada: espacio muestral finito, densidades estrictamente
positivas donde se indica, y condicionamiento por fibra sustituyendo a la
esperanza condicional de la teoría de la medida. No se formaliza el caso
continuo ni la existencía de versiones regulares.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

namespace Book.Cap04Suficiencia

/-! ### Riesgo y principio de equivarianza -/

variable {X Θ A : Type*}

/-- Riesgo del estimador `δ` bajo el modelo `p` y la pérdida `L`:
`R(θ,δ) = ∑_x L(θ, δ(x))·p_θ(x)`. -/
noncomputable def risk [Fintype X] (p : Θ → X → ℝ) (L : Θ → A → ℝ) (δ : X → A)
    (θ : Θ) : ℝ :=
  ∑ x, L θ (δ x) * p θ x

/-- book: capitulos/cap04_herramientas.typ:813 (key: thm:ch2-equivarianza) —
Principio de Equivarianza (versión finita): si el modelo es invariante bajo
la transformación `σ` (`p_{σθ}(σx) = p_θ(x)`), la pérdida es invariante
(`L(σθ, σa) = L(θ,a)`) y el estimador es equivariante
(`δ(σx) = σ(δx)`), entonces el riesgo es constante sobre la órbita:
`R(σθ, δ) = R(θ, δ)` para todo `θ`.

Prueba: reindexar la suma del riesgo en `σθ` mediante la permutación `σX`
(`Equiv.sum_comp`) y aplicar las tres invariancias término a término.

Fidelidad declarada: `σX` es una permutación de `X` (grupo finito/compacto,
de modo que la medida de Haar implícita es la medida de conteo y el
promedio sobre el grupo está bien definido); `σΘ` no necesita ser
biyectiva. La afirmación «constante en todo el espacio sólo si la acción es
transitiva» es cualitativa y no se enuncia; no se afirma minimaxidad.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch2_equivarianza [Fintype X] (p : Θ → X → ℝ) (L : Θ → A → ℝ)
    (δ : X → A) (σX : Equiv.Perm X) (σΘ : Θ → Θ) (σA : A → A)
    (hmodel : ∀ θ x, p (σΘ θ) (σX x) = p θ x)
    (hest : ∀ x, δ (σX x) = σA (δ x))
    (hloss : ∀ θ a, L (σΘ θ) (σA a) = L θ a) (θ : Θ) :
    risk p L δ (σΘ θ) = risk p L δ θ := by
  unfold risk
  rw [← Equiv.sum_comp σX (fun x => L (σΘ θ) (δ x) * p (σΘ θ) x)]
  exact Finset.sum_congr rfl fun y _ => by rw [hest y, hloss θ (δ y), hmodel θ y]

/-! ### Cocientes de verosimilitud y suficiencia minimal -/

section Minimal

variable {X : Type*} [Fintype X]

/-- Cociente de verosimilitudes constante en el parámetro, en forma
multiplicativa (sin dividir): `LR p x y := ∀ θ θ', p θ x · p θ' y = p θ' x · p θ y`.
Es la relación de equivalencia «misma clase de verosimilitud». -/
def LR {Θ : Type*} (p : Θ → X → ℝ) (x y : X) : Prop :=
  ∀ θ θ' : Θ, p θ x * p θ' y = p θ' x * p θ y

/-- La factorización de Neyman implica que dos observaciones con la misma
imagen por un estadístico suficiente tienen cociente de verosimilitudes
constante: `T x = T y → LR p x y`. -/
theorem lr_of_factor {Θ τ : Type*} (p : Θ → X → ℝ) (T : X → τ)
    (g : Θ → τ → ℝ) (b : X → ℝ)
    (hfac : ∀ θ x, p θ x = g θ (T x) * b x) {x y : X} (h : T x = T y) :
    LR p x y := by
  intro θ θ'
  rw [hfac θ x, hfac θ' y, hfac θ' x, hfac θ y, h]
  ring

/-- book: capitulos/cap04_herramientas.typ:657 (key: thm:ch2-lehmann-scheffe) —
Criterio de cocientes de verosimilitud para suficiencia minimal. En una
familia exponencial finita canónica `p_η(x) = h(x)·exp(η·T(x))` con
`h > 0`, el cociente de verosimilitudes `p_η(x)/p_η(y)` no depende de `η`
si y sólo si `T(x) = T(y)`.

Fidelidad declarada: se trabaja con el cociente en forma multiplicativa
(`LR`, sin dividir por lo que podría anularse) y con parámetro natural
`η : ℝ` (el dominio natural contiene el abierto `ℝ`); el caso general del
libro usa proporcionalidad de vectores de verosimilitud y no se enuncia
aquí por separado.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch2_lehmann_scheffe_criterio (h : X → ℝ) (hpos : ∀ x, 0 < h x)
    (T : X → ℝ) (p : ℝ → X → ℝ)
    (hfac : ∀ η x, p η x = h x * Real.exp (η * T x)) (x y : X) :
    LR p x y ↔ T x = T y := by
  constructor
  · intro hLR
    have h01 := hLR 0 1
    have h1 : h x * (h y * Real.exp (T y)) = h x * Real.exp (T x) * h y := by
      simpa [hfac] using h01
    have h2 : h x * h y * Real.exp (T y) = h x * h y * Real.exp (T x) := by
      calc h x * h y * Real.exp (T y) = h x * (h y * Real.exp (T y)) := by ring
        _ = h x * Real.exp (T x) * h y := h1
        _ = h x * h y * Real.exp (T x) := by ring
    have hne : h x * h y ≠ 0 := ne_of_gt (mul_pos (hpos x) (hpos y))
    exact (Real.exp_injective (mul_left_cancel₀ hne h2)).symm
  · intro hT θ θ'
    rw [hfac θ x, hfac θ' y, hfac θ' x, hfac θ y, hT]
    ring

/-- book: capitulos/cap04_herramientas.typ:657 (key: thm:ch2-lehmann-scheffe) —
Minimalidad del estadístico natural: si `T'` es suficiente (factoriza la
verosimilitud) y el estadístico natural satisface el criterio de cocientes,
entonces `T` es función de `T'`: existe `φ` con `T x = φ (T' x)`. Es la
definición de suficiencia minimal (`def:ch2-suficiencia-minimal`).

Fidelidad declarada: la igualdad es punto a punto en el espacio muestral
finito (equivalentemente, `P_θ`-c.s. para todo `θ`) y la función `φ` se
construye de forma clásica sobre la imagen de `T'`.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch2_lehmann_scheffe_minimal (h : X → ℝ) (hpos : ∀ x, 0 < h x)
    (T : X → ℝ) (p : ℝ → X → ℝ)
    (hfac : ∀ η x, p η x = h x * Real.exp (η * T x))
    {τ : Type*} (T' : X → τ) (g : ℝ → τ → ℝ) (b : X → ℝ)
    (hfac' : ∀ η x, p η x = g η (T' x) * b x) :
    ∃ φ : τ → ℝ, ∀ x, T x = φ (T' x) := by
  classical
  have hkey : ∀ x y : X, T' x = T' y → T x = T y := by
    intro x y hxy
    have hLR : LR p y x := lr_of_factor p T' g b hfac' hxy.symm
    exact ((ch2_lehmann_scheffe_criterio h hpos T p hfac y x).1 hLR).symm
  refine ⟨fun t => if h : ∃ x : X, T' x = t then T (Classical.choose h) else 0, fun x => ?_⟩
  have hex : ∃ x' : X, T' x' = T' x := ⟨x, rfl⟩
  show T x = (if h : ∃ x' : X, T' x' = T' x then T (Classical.choose h) else 0)
  rw [dif_pos hex]
  exact (hkey _ _ (Classical.choose_spec hex)).symm

end Minimal

/-! ### Suficiencia minimal y completitud en familias exponenciales (SMC) -/

section SMC

variable {X : Type*} [Fintype X]

/-- Independencia lineal de exponenciales reales en un parámetro real (vía
Vandermonde): si `t i` son distintos y `∑_i c_i·exp(η·t_i) = 0` para todo
`η : ℝ`, entonces todos los `c_i` se anulan. -/
theorem exp_linind_fiber {k : ℕ} (t : Fin k → ℝ) (ht : Function.Injective t)
    (c : Fin k → ℝ) (hc : ∀ η : ℝ, ∑ i, c i * Real.exp (η * t i) = 0) :
    ∀ i, c i = 0 := by
  have hinj : Function.Injective (fun j : Fin k => Real.exp (t j)) :=
    fun i j hij => ht (Real.exp_injective hij)
  have hpow : ∀ i : Fin k, ∑ j, c j * Real.exp (t j) ^ (i : ℕ) = 0 := by
    intro i
    simpa [Real.exp_nat_mul] using hc (i : ℝ)
  have hzero := Matrix.eq_zero_of_forall_pow_sum_mul_pow_eq_zero (f := fun j : Fin k =>
    Real.exp (t j)) hinj hpow
  intro i
  simpa using congrFun hzero i

/-- Suficiencia del estadístico natural (factorización de Neyman en forma de
multiplicación cruzada): la distribución condicional de `X` dada `T` no
depende del parámetro:
`p_η(x₀)·P_{η'}(T = T x₀) = p_{η'}(x₀)·P_η(T = T x₀)`. -/
theorem exp_sufficient (h : X → ℝ) (T : X → ℝ) (x₀ : X) (η η' : ℝ) :
    (h x₀ * Real.exp (η * T x₀))
        * (∑ x', if T x' = T x₀ then (h x' * Real.exp (η' * T x')) else 0)
      = (h x₀ * Real.exp (η' * T x₀))
        * (∑ x', if T x' = T x₀ then (h x' * Real.exp (η * T x')) else 0) := by
  have hsum : ∀ ξ : ℝ, (∑ x', if T x' = T x₀ then (h x' * Real.exp (ξ * T x')) else 0)
      = Real.exp (ξ * T x₀) * (∑ x', if T x' = T x₀ then h x' else 0) := by
    intro ξ
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun x' _ => ?_
    by_cases hx : T x' = T x₀
    · rw [if_pos hx, if_pos hx, hx]; ring
    · rw [if_neg hx, if_neg hx]; ring
  rw [hsum η', hsum η]
  ring

/-- Completitud del estadístico natural (caso general, ruta Vandermonde):
si `h > 0` y `E_η[g(T)] = ∑_x g(T x)·h(x)·exp(η·T x) = 0` para todo `η`,
entonces `g` se anula en todos los valores alcanzados por `T`. -/
theorem exp_complete (h : X → ℝ) (T : X → ℝ) (hpos : ∀ x, 0 < h x) (g : ℝ → ℝ)
    (hvan : ∀ η : ℝ, ∑ x, g (T x) * h x * Real.exp (η * T x) = 0) :
    ∀ x, g (T x) = 0 := by
  classical
  set s : Finset ℝ := (Finset.univ : Finset X).image T with hs
  set W : ℝ → ℝ :=
    fun t => ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), h x with hW
  have hgrp : ∀ η : ℝ, ∑ t ∈ s, (g t * W t) * Real.exp (η * t) = 0 := by
    intro η
    have hmap : ∀ x ∈ (Finset.univ : Finset X), T x ∈ s :=
      fun x _ => Finset.mem_image_of_mem T (Finset.mem_univ x)
    have hfib := Finset.sum_fiberwise_of_maps_to (s := (Finset.univ : Finset X)) (t := s)
      hmap (fun x => g (T x) * h x * Real.exp (η * T x))
    rw [← hvan η, ← hfib]
    refine Finset.sum_congr rfl fun t _ => ?_
    have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
        g (T x) * h x * Real.exp (η * T x) = (g t * Real.exp (η * t)) * h x := by
      intro x hx
      rw [(Finset.mem_filter.mp hx).2]
      ring
    rw [Finset.sum_congr rfl h1, ← Finset.mul_sum, hW]
    ring
  have hgrpSub : ∀ η : ℝ, ∑ i : ↥s, (g (i : ℝ) * W (i : ℝ)) * Real.exp (η * (i : ℝ)) = 0 := by
    intro η
    rw [Finset.sum_coe_sort s (fun t => (g t * W t) * Real.exp (η * t))]
    exact hgrp η
  set e := Fintype.equivFin ↥s with he
  have ht_inj : Function.Injective (fun i : Fin (Fintype.card ↥s) => ((e.symm i : ↥s) : ℝ)) := by
    intro i j hij
    exact e.symm.injective (Subtype.coe_injective hij)
  have hc : ∀ η : ℝ, ∑ i : Fin (Fintype.card ↥s),
      (g (((e.symm i : ↥s) : ℝ)) * W (((e.symm i : ↥s) : ℝ)))
        * Real.exp (η * ((e.symm i : ↥s) : ℝ)) = 0 := by
    intro η
    rw [Equiv.sum_comp e.symm
      (fun i : ↥s => (g (i : ℝ) * W (i : ℝ)) * Real.exp (η * (i : ℝ)))]
    exact hgrpSub η
  have hzero := exp_linind_fiber (fun i : Fin (Fintype.card ↥s) => ((e.symm i : ↥s) : ℝ))
    ht_inj (fun i => g (((e.symm i : ↥s) : ℝ)) * W (((e.symm i : ↥s) : ℝ))) hc
  intro x
  have hmem : T x ∈ s := Finset.mem_image_of_mem T (Finset.mem_univ x)
  have hWpos : 0 < W (T x) := by
    obtain ⟨x₀, -, hx₀⟩ := Finset.mem_image.mp hmem
    rw [hW]
    exact Finset.sum_pos (fun y _ => hpos y)
      ⟨x₀, Finset.mem_filter.mpr ⟨Finset.mem_univ x₀, hx₀⟩⟩
  have key := hzero (e ⟨T x, hmem⟩)
  rw [Equiv.symm_apply_apply] at key
  exact (mul_eq_zero.mp key).resolve_right (ne_of_gt hWpos)

/-- book: capitulos/cap04_herramientas.typ:712 (key: cor:ch2-smc) —
Suficiencia minimal y completitud (SMC) del estadístico natural en una
familia exponencial finita canónica `p_η(x) = h(x)·exp(η·T(x))` con
`h > 0`: `T` es (1) suficiente — la ley condicional dada `T` no depende de
`η` —, (2) completo — `E_η[g(T)] = 0` para todo `η` fuerza `g(T) = 0` — y
(3) minimal — `T` es función de cualquier otro estadístico suficiente.

Fidelidad declarada: la hipótesis del libro «el dominio natural contiene un
conjunto abierto de `ℝᵏ`» se instancia con el parámetro natural
`η : ℝ` que recorre todo `ℝ`; el estadístico es escalar y la completitud se
prueba por independencia lineal de exponenciales (Vandermonde). La
suficiencia se enuncia como independencia condicional en forma de
multiplicación cruzada, evitando la existencia de versiones regulares de la
condicional.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem cor_ch2_smc {τ : Type*} (h : X → ℝ) (T : X → ℝ) (hpos : ∀ x, 0 < h x) :
    (∀ (x₀ : X) (η η' : ℝ),
        (h x₀ * Real.exp (η * T x₀))
            * (∑ x', if T x' = T x₀ then (h x' * Real.exp (η' * T x')) else 0)
          = (h x₀ * Real.exp (η' * T x₀))
            * (∑ x', if T x' = T x₀ then (h x' * Real.exp (η * T x')) else 0))
      ∧ (∀ g : ℝ → ℝ,
          (∀ η : ℝ, ∑ x, g (T x) * h x * Real.exp (η * T x) = 0) → ∀ x, g (T x) = 0)
      ∧ (∀ (T' : X → τ) (g : ℝ → τ → ℝ) (b : X → ℝ),
          (∀ η x, h x * Real.exp (η * T x) = g η (T' x) * b x) →
            ∃ φ : τ → ℝ, ∀ x, T x = φ (T' x)) :=
  ⟨exp_sufficient h T, exp_complete h T hpos,
    fun T' g b hfac' => ch2_lehmann_scheffe_minimal h hpos T
      (fun η x => h x * Real.exp (η * T x)) (fun _ _ => rfl) T' g b hfac'⟩

end SMC

/-! ### Rao-Blackwell finito y optimalidad (Lehmann-Scheffé) -/

section RaoBlackwell

variable {X Θ τ : Type*} [Fintype X] [DecidableEq τ]

/-- Media de un estimador `δ`: `E_θ[δ] = ∑_x δ(x)·p_θ(x)` (forma no
normalizada; con densidades que suman `1` es la esperanza usual). -/
noncomputable def mean (p : Θ → X → ℝ) (δ : X → ℝ) (θ : Θ) : ℝ :=
  ∑ x, δ x * p θ x

/-- Segundo momento: `E_θ[δ²] = ∑_x δ(x)²·p_θ(x)`. -/
noncomputable def secondMoment (p : Θ → X → ℝ) (δ : X → ℝ) (θ : Θ) : ℝ :=
  ∑ x, (δ x) ^ 2 * p θ x

/-- Varianza como `E_θ[δ²] − E_θ[δ]²` (coincide con `E_θ[(δ−E_θδ)²]` cuando
los pesos `p_θ` suman `1`). -/
noncomputable def variance (p : Θ → X → ℝ) (δ : X → ℝ) (θ : Θ) : ℝ :=
  secondMoment p δ θ - (mean p δ θ) ^ 2

/-- Peso de la fibra de `T` sobre `t`: `W(t) = ∑_{x : T x = t} b(x)`. -/
noncomputable def fibW (T : X → τ) (b : X → ℝ) (t : τ) : ℝ :=
  ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), b x

/-- Media (no normalizada) de `δ` dentro de la fibra de `T` sobre `t`. -/
noncomputable def fibA (T : X → τ) (b : X → ℝ) (δ : X → ℝ) (t : τ) : ℝ :=
  ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), δ x * b x

/-- Segundo momento (no normalizado) de `δ` dentro de la fibra de `T` sobre `t`. -/
noncomputable def fibSq (T : X → τ) (b : X → ℝ) (δ : X → ℝ) (t : τ) : ℝ :=
  ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), (δ x) ^ 2 * b x

/-- Rao-Blackwellización: media de `δ` en la fibra de `T` sobre `t`.
Es una función de `T` por construcción. -/
noncomputable def rbFun (T : X → τ) (b : X → ℝ) (δ : X → ℝ) (t : τ) : ℝ :=
  fibA T b δ t / fibW T b t

/-- La fibra de un valor alcanzado por `T` tiene peso estrictamente positivo
si los pesos `b` lo son. -/
theorem fibW_pos (T : X → τ) (b : X → ℝ) (hbpos : ∀ x, 0 < b x) {t : τ}
    (ht : t ∈ (Finset.univ : Finset X).image T) : 0 < fibW T b t := by
  obtain ⟨x₀, -, hx₀⟩ := Finset.mem_image.mp ht
  exact Finset.sum_pos (fun x _ => hbpos x)
    ⟨x₀, Finset.mem_filter.mpr ⟨Finset.mem_univ x₀, hx₀⟩⟩

/-- Reagrupación por fibras: `∑_x u(T x)·b(x) = ∑_t u(t)·W(t)`. -/
theorem sum_fiber_comp (T : X → τ) (b : X → ℝ) (u : τ → ℝ) :
    ∑ x, u (T x) * b x = ∑ t ∈ (Finset.univ : Finset X).image T, u t * fibW T b t := by
  have hmap : ∀ x ∈ (Finset.univ : Finset X), T x ∈ (Finset.univ : Finset X).image T :=
    fun x _ => Finset.mem_image_of_mem T (Finset.mem_univ x)
  have hfib := Finset.sum_fiberwise_of_maps_to (s := (Finset.univ : Finset X))
    (t := (Finset.univ : Finset X).image T) hmap (fun x => u (T x) * b x)
  rw [← hfib]
  refine Finset.sum_congr rfl fun t _ => ?_
  have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
      u (T x) * b x = u t * b x := by
    intro x hx
    rw [(Finset.mem_filter.mp hx).2]
  rw [Finset.sum_congr rfl h1, ← Finset.mul_sum]
  rfl

/-- Reagrupación por fibras para un estimador: `∑_x v(x)·g(T x)·b(x) = ∑_t g(t)·A_v(t)`. -/
theorem sum_fiber_est (T : X → τ) (b : X → ℝ) (v : X → ℝ) (g : τ → ℝ) :
    ∑ x, v x * g (T x) * b x
      = ∑ t ∈ (Finset.univ : Finset X).image T, g t * fibA T b v t := by
  have hmap : ∀ x ∈ (Finset.univ : Finset X), T x ∈ (Finset.univ : Finset X).image T :=
    fun x _ => Finset.mem_image_of_mem T (Finset.mem_univ x)
  have hfib := Finset.sum_fiberwise_of_maps_to (s := (Finset.univ : Finset X))
    (t := (Finset.univ : Finset X).image T) hmap (fun x => v x * g (T x) * b x)
  rw [← hfib]
  refine Finset.sum_congr rfl fun t _ => ?_
  have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
      v x * g (T x) * b x = g t * (v x * b x) := by
    intro x hx
    rw [(Finset.mem_filter.mp hx).2]
    ring
  rw [Finset.sum_congr rfl h1, ← Finset.mul_sum]
  rfl

/-- La Rao-Blackwellización conserva la media dentro de cada fibra. -/
theorem rb_fibA (T : X → τ) (b : X → ℝ) (δ : X → ℝ) (hbpos : ∀ x, 0 < b x)
    {t : τ} (ht : t ∈ (Finset.univ : Finset X).image T) :
    fibA T b (fun x => rbFun T b δ (T x)) t = fibA T b δ t := by
  have hstep : fibA T b (fun x => rbFun T b δ (T x)) t
      = (fibA T b δ t / fibW T b t) * fibW T b t := by
    show (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
        rbFun T b δ (T x) * b x) = _
    have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
        rbFun T b δ (T x) * b x = (fibA T b δ t / fibW T b t) * b x := by
      intro x hx
      rw [(Finset.mem_filter.mp hx).2]
      rfl
    rw [Finset.sum_congr rfl h1, ← Finset.mul_sum]
    rfl
  rw [hstep]
  exact div_mul_cancel₀ _ (ne_of_gt (fibW_pos T b hbpos ht))

/-- Segundo momento de la Rao-Blackwellización en una fibra:
`A_{δ²}(t) = (A_δ(t))² / W(t)` (en la fibra `rb` es constante). -/
theorem rb_fibA_sq (T : X → τ) (b : X → ℝ) (δ : X → ℝ) (hbpos : ∀ x, 0 < b x)
    {t : τ} (ht : t ∈ (Finset.univ : Finset X).image T) :
    fibA T b (fun x => (rbFun T b δ (T x)) ^ 2) t
      = (fibA T b δ t) ^ 2 / fibW T b t := by
  have hstep : fibA T b (fun x => (rbFun T b δ (T x)) ^ 2) t
      = ((fibA T b δ t / fibW T b t) ^ 2) * fibW T b t := by
    show (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
        (rbFun T b δ (T x)) ^ 2 * b x) = _
    have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
        (rbFun T b δ (T x)) ^ 2 * b x = ((fibA T b δ t / fibW T b t) ^ 2) * b x := by
      intro x hx
      rw [(Finset.mem_filter.mp hx).2]
      rfl
    rw [Finset.sum_congr rfl h1, ← Finset.mul_sum]
    rfl
  rw [hstep]
  have hW : fibW T b t ≠ 0 := ne_of_gt (fibW_pos T b hbpos ht)
  field_simp

/-- Desigualdad de Cauchy-Schwarz por fibra: `A_δ(t)² ≤ A_{δ²}(t)·W(t)`. -/
theorem fibA_sq_le (T : X → τ) (b : X → ℝ) (hb : ∀ x, 0 ≤ b x) (δ : X → ℝ) (t : τ) :
    (fibA T b δ t) ^ 2 ≤ fibSq T b δ t * fibW T b t := by
  refine Finset.sum_sq_le_sum_mul_sum_of_sq_le_mul (s := (Finset.univ : Finset X).filter
      (fun x => T x = t)) (r := fun x => δ x * b x) (f := fun x => (δ x) ^ 2 * b x)
      (g := fun x => b x) ?_ ?_ ?_
  · intro x _
    exact mul_nonneg (sq_nonneg _) (hb x)
  · intro x _
    exact hb x
  · intro x _
    exact le_of_eq (by ring)

/-- book: capitulos/cap04_herramientas.typ:877 (key: thm:ch3-rao-blackwell) —
Rao-Blackwell (versión finita). Sea `δ` un estimador (con segundo momento
finito) y `T` suficiente con factorización `p_θ(x) = g_θ(T x)·b(x)`,
`b > 0`, `g_θ ≥ 0`. La Rao-Blackwellización
`δ̄(t) = (∑_{T x = t} δ(x)·b(x)) / (∑_{T x = t} b(x))` es (1) función de
`T` por construcción, (2) tiene la misma esperanza que `δ` bajo todo `θ`, y
(3) varianza no mayor:
`Var_θ(δ̄∘T) ≤ Var_θ(δ)` para todo `θ`.

Prueba: (2) se obtiene reagrupando ambas esperanzas por fibras de `T`
(`sum_fiber_est`), donde `δ̄(t)·W(t) = A_δ(t)`; (3) es la desigualdad de
Cauchy-Schwarz por fibra `A_δ(t)² ≤ A_{δ²}(t)·W(t)` multiplicada por
`g_θ(t) ≥ 0` y sumada sobre las fibras alcanzadas.

Fidelidad declarada: la esperanza condicional `E[δ | T]` se sustituye por el
promedio explícito por fibra (válido porque `T` es suficiente y la
distribución condicional no depende de `θ`, que aquí se materializa en la
factorización); la varianza se define como `E[δ²] − E[δ]²`. No se enuncia la
caracterización de igualdad («si y sólo si `δ` es función de `T`»), que
requiere analizar el caso de igualdad en Cauchy-Schwarz.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch3_rao_blackwell (p : Θ → X → ℝ) (T : X → τ) (g : Θ → τ → ℝ) (b : X → ℝ)
    (hfac : ∀ θ x, p θ x = g θ (T x) * b x) (hbpos : ∀ x, 0 < b x)
    (hg : ∀ θ t, 0 ≤ g θ t) (δ : X → ℝ) :
    (∀ θ, mean p (fun x => rbFun T b δ (T x)) θ = mean p δ θ)
      ∧ (∀ θ, variance p (fun x => rbFun T b δ (T x)) θ ≤ variance p δ θ) := by
  have hmean : ∀ θ, mean p (fun x => rbFun T b δ (T x)) θ = mean p δ θ := by
    intro θ
    unfold mean
    simp only [hfac θ]
    rw [show (∑ x, rbFun T b δ (T x) * (g θ (T x) * b x))
        = (∑ x, rbFun T b δ (T x) * g θ (T x) * b x) from
      Finset.sum_congr rfl fun x _ => by ring,
      show (∑ x, δ x * (g θ (T x) * b x)) = (∑ x, δ x * g θ (T x) * b x) from
      Finset.sum_congr rfl fun x _ => by ring]
    rw [sum_fiber_est T b (fun x => rbFun T b δ (T x)) (g θ),
        sum_fiber_est T b δ (g θ)]
    refine Finset.sum_congr rfl fun t ht => ?_
    rw [rb_fibA T b δ hbpos ht]
  constructor
  · exact hmean
  · intro θ
    have hm := hmean θ
    have hs : secondMoment p (fun x => rbFun T b δ (T x)) θ ≤ secondMoment p δ θ := by
      unfold secondMoment
      simp only [hfac θ]
      rw [show (∑ x, (rbFun T b δ (T x)) ^ 2 * (g θ (T x) * b x))
          = (∑ x, (rbFun T b δ (T x)) ^ 2 * g θ (T x) * b x) from
        Finset.sum_congr rfl fun x _ => by ring,
        show (∑ x, (δ x) ^ 2 * (g θ (T x) * b x))
          = (∑ x, (δ x) ^ 2 * g θ (T x) * b x) from
        Finset.sum_congr rfl fun x _ => by ring]
      rw [sum_fiber_est T b (fun x => (rbFun T b δ (T x)) ^ 2) (g θ),
          sum_fiber_est T b (fun x => (δ x) ^ 2) (g θ)]
      refine Finset.sum_le_sum fun t ht => ?_
      have hW : 0 < fibW T b t := fibW_pos T b hbpos ht
      rw [rb_fibA_sq T b δ hbpos ht]
      refine mul_le_mul_of_nonneg_left ?_ (hg θ t)
      show fibA T b δ t ^ 2 / fibW T b t ≤ fibSq T b δ t
      rw [div_le_iff₀ hW]
      exact fibA_sq_le T b (fun x => le_of_lt (hbpos x)) δ t
    unfold variance
    rw [hm]
    linarith

/-- book: capitulos/cap04_herramientas.typ:904 (key: cor:ch3-rb-insesgado) —
Si `δ` es insesgado para `γ`, entonces la Rao-Blackwellización `δ̄∘T` es
también insesgada para `γ` y tiene varianza no mayor. Es consecuencia
inmediata de `thm:ch3-rao-blackwell` (igualdad de medias y cota del segundo
momento).

Fidelidad declarada: idéntica a la del teorema de Rao-Blackwell finito.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem cor_ch3_rb_insesgado (p : Θ → X → ℝ) (T : X → τ) (g : Θ → τ → ℝ) (b : X → ℝ)
    (hfac : ∀ θ x, p θ x = g θ (T x) * b x) (hbpos : ∀ x, 0 < b x)
    (hg : ∀ θ t, 0 ≤ g θ t) (δ : X → ℝ) (γ : Θ → ℝ)
    (hunb : ∀ θ, mean p δ θ = γ θ) :
    (∀ θ, mean p (fun x => rbFun T b δ (T x)) θ = γ θ)
      ∧ (∀ θ, variance p (fun x => rbFun T b δ (T x)) θ ≤ variance p δ θ) := by
  obtain ⟨hmean, hvar⟩ := ch3_rao_blackwell p T g b hfac hbpos hg δ
  exact ⟨fun θ => (hmean θ).trans (hunb θ), hvar⟩

/-- book: capitulos/cap04_herramientas.typ:931 (key: thm:ch3-lehmann-scheffe) —
Teorema de Lehmann-Scheffé (versión finita). Sea `T` suficiente y completo
(`∀ u, E_θ[u(T)] = 0 ∀θ → u(T) = 0`) y `φ₀∘T` una función insesgada de `T`
para `γ`. Entonces (1) `φ₀∘T` es óptimo entre todos los estimadores
insesgados de `γ`: `Var_θ(φ₀∘T) ≤ Var_θ(δ)` para todo estimador insesgado
`δ` y todo `θ`; y (2) es el único: cualquier otra función insesgada `φ₁∘T`
de `T` coincide con `φ₀∘T` sobre el espacio muestral.

Prueba: por Rao-Blackwell (`thm:ch3-rao-blackwell`) `δ̄∘T` es insesgada y
`Var(δ̄∘T) ≤ Var(δ)`; la diferencia `δ̄ − φ₀` es función de `T` con esperanza
cero bajo todo `θ`, luego es idénticamente nula por completitud; así
`Var(φ₀∘T) = Var(δ̄∘T) ≤ Var(δ)`. La unicidad aplica completitud a
`φ₁ − φ₀`.

Fidelidad declarada: espacio muestral finito, completitud en forma puntual
(equivalente a la igualdad `P_θ`-c.s. en el caso discreto), varianza como
`E[δ²] − E[δ]²`. No se enuncia la parte «salvo igualdad casi segura» por
separado. El teorema no requiere que `δ` sea cota de ningún tipo especial:
basta `δ` insesgado (el segundo momento aparece implícito en la definición
de varianza).
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch3_lehmann_scheffe (p : Θ → X → ℝ) (T : X → τ) (g : Θ → τ → ℝ) (b : X → ℝ)
    (hfac : ∀ θ x, p θ x = g θ (T x) * b x) (hbpos : ∀ x, 0 < b x)
    (hg : ∀ θ t, 0 ≤ g θ t)
    (hcomplete : ∀ u : τ → ℝ, (∀ θ, ∑ x, u (T x) * p θ x = 0) → ∀ x, u (T x) = 0)
    (φ₀ : τ → ℝ) (γ : Θ → ℝ) (hunb₀ : ∀ θ, mean p (fun x => φ₀ (T x)) θ = γ θ) :
    (∀ (δ : X → ℝ), (∀ θ, mean p δ θ = γ θ) →
        ∀ θ, variance p (fun x => φ₀ (T x)) θ ≤ variance p δ θ)
      ∧ (∀ φ₁ : τ → ℝ, (∀ θ, mean p (fun x => φ₁ (T x)) θ = γ θ) →
          ∀ x, φ₁ (T x) = φ₀ (T x)) := by
  constructor
  · intro δ hunb θ
    have hvarAll := (ch3_rao_blackwell p T g b hfac hbpos hg δ).2
    have hmeanAll := (ch3_rao_blackwell p T g b hfac hbpos hg δ).1
    have hzero : ∀ θ', ∑ x, (rbFun T b δ (T x) - φ₀ (T x)) * p θ' x = 0 := by
      intro θ'
      rw [show (∑ x, (rbFun T b δ (T x) - φ₀ (T x)) * p θ' x)
          = (∑ x, rbFun T b δ (T x) * p θ' x) - ∑ x, φ₀ (T x) * p θ' x from by
        rw [← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun x _ => by ring]
      rw [← mean, ← mean, hmeanAll θ', hunb₀ θ', hunb θ']
      ring
    have hpt := hcomplete (fun t => rbFun T b δ t - φ₀ t) hzero
    have heq : (fun x => rbFun T b δ (T x)) = fun x => φ₀ (T x) := by
      funext x
      have := hpt x
      linarith [this]
    rw [← heq]
    exact hvarAll θ
  · intro φ₁ hunb₁ x
    have hzero : ∀ θ', ∑ x, (φ₁ (T x) - φ₀ (T x)) * p θ' x = 0 := by
      intro θ'
      rw [show (∑ x, (φ₁ (T x) - φ₀ (T x)) * p θ' x)
          = (∑ x, φ₁ (T x) * p θ' x) - ∑ x, φ₀ (T x) * p θ' x from by
        rw [← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun x _ => by ring]
      rw [← mean, ← mean, hunb₁ θ', hunb₀ θ']
      ring
    have hpt := hcomplete (fun t => φ₁ t - φ₀ t) hzero
    linarith [hpt x]

/-- book: capitulos/cap04_herramientas.typ:960 (key: cor:ch3-umvue-exponencial) —
En una familia exponencial finita canónica `p_η(x) = h(x)·exp(η·T(x))` con
`h > 0`, cualquier función insesgada `φ₀∘T` del estadístico natural con
segundo momento finito es el UMVUE (`def:ch3-umvue`) de `γ(η) = E_η[φ₀(T)]`:
su varianza es mínima entre todos los estimadores insesgados y es la única
función insesgada de `T`.

Prueba: `T` es suficiente y completo por `cor:ch2-smc`
(`exp_complete`), de modo que se aplica `thm:ch3-lehmann-scheffe`; la
factorización `p_η(x) = exp(η·T x)·h(x)` es la del teorema con
`g_η(t) = exp(η·t) ≥ 0` y `b = h > 0`.

Fidelidad declarada: estadístico y parámetro escalares, espacio muestral
finito; «segundo momento finito bajo cada modelo» es automático en el caso
finito. La hipótesis de regularidad del libro (dominio natural abierto) se
instancia con `η` recorriendo todo `ℝ`.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem cor_ch3_umvue_exponencial (h : X → ℝ) (T : X → ℝ) (hpos : ∀ x, 0 < h x)
    (φ₀ : ℝ → ℝ) (γ : ℝ → ℝ)
    (hunb₀ : ∀ η, mean (fun η x => h x * Real.exp (η * T x)) (fun x => φ₀ (T x)) η = γ η) :
    (∀ (δ : X → ℝ), (∀ η, mean (fun η x => h x * Real.exp (η * T x)) δ η = γ η) →
        ∀ η, variance (fun η x => h x * Real.exp (η * T x)) (fun x => φ₀ (T x)) η
          ≤ variance (fun η x => h x * Real.exp (η * T x)) δ η)
      ∧ (∀ φ₁ : ℝ → ℝ,
          (∀ η, mean (fun η x => h x * Real.exp (η * T x)) (fun x => φ₁ (T x)) η = γ η) →
          ∀ x, φ₁ (T x) = φ₀ (T x)) := by
  have hfac : ∀ (η : ℝ) (x : X),
      h x * Real.exp (η * T x) = (fun (η : ℝ) (t : ℝ) => Real.exp (η * t)) η (T x) * h x :=
    fun η x => by ring
  have hcomplete : ∀ u : ℝ → ℝ,
      (∀ η, ∑ x, u (T x) * (h x * Real.exp (η * T x)) = 0) → ∀ x, u (T x) = 0 := by
    intro u hu x
    refine exp_complete h T hpos u (fun η => ?_) x
    rw [show (∑ x, u (T x) * h x * Real.exp (η * T x))
        = ∑ x, u (T x) * (h x * Real.exp (η * T x)) from
      Finset.sum_congr rfl fun y _ => by ring]
    exact hu η
  exact ch3_lehmann_scheffe (fun η x => h x * Real.exp (η * T x)) T
    (fun η t => Real.exp (η * t)) h hfac hpos (fun η t => (Real.exp_pos (η * t)).le) hcomplete
    φ₀ γ hunb₀

end RaoBlackwell

/-! ### Teorema de Basu: un estadístico completo es independiente de todo ancilar -/

section Basu

variable {X τ υ : Type*} [Fintype X] [DecidableEq τ] [DecidableEq υ]

/-- Reagrupación por fibras restringida a `{A = a}`: infraestructura del
teorema de Basu. -/
theorem sum_fiber_ind (T : X → τ) (A : X → υ) (b : X → ℝ) (G : τ → ℝ) (a : υ) :
    ∑ x, (if A x = a then G (T x) else 0) * b x
      = ∑ t ∈ (Finset.univ : Finset X).image T,
          G t * (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a), b x) := by
  classical
  have hmap : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a),
      T x ∈ (Finset.univ : Finset X).image T :=
    fun x _ => Finset.mem_image_of_mem T (Finset.mem_univ x)
  have hfib := Finset.sum_fiberwise_of_maps_to (s := (Finset.univ : Finset X).filter
    (fun x => A x = a)) (t := (Finset.univ : Finset X).image T) hmap
    (fun x => G (T x) * b x)
  have hL : (∑ x, (if A x = a then G (T x) else 0) * b x)
      = ∑ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a), G (T x) * b x := by
    rw [show (∑ x, (if A x = a then G (T x) else 0) * b x)
        = ∑ x, (if A x = a then G (T x) * b x else 0) from
      Finset.sum_congr rfl fun x _ => by
        by_cases hx : A x = a
        · rw [if_pos hx, if_pos hx]
        · rw [if_neg hx, if_neg hx]; ring]
    rw [← Finset.sum_filter]
  rw [hL, ← hfib]
  refine Finset.sum_congr rfl fun t _ => ?_
  have hset : ((Finset.univ : Finset X).filter (fun x => A x = a)).filter
        (fun x => T x = t)
      = (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a) := by
    rw [Finset.filter_filter]
    congr 1
    funext x
    exact propext (and_comm)
  rw [hset]
  have h1 : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a),
      G (T x) * b x = G t * b x := by
    intro x hx
    rw [(Finset.mem_filter.mp hx).2.1]
  rw [Finset.sum_congr rfl h1, Finset.mul_sum]

/-- book: capitulos/cap04_herramientas.typ:749 (key: thm:ch2-basu) —
Teorema de Basu (versión finita). Sea `T` suficiente (factorización
`p_θ(x) = g_θ(T x)·b(x)` con `b > 0`, `g_θ ≥ 0`, pesos normalizados
`∑_x p_θ(x) = 1`) y completo, y sea `A` ancilar (la ley de `A` no depende de
`θ`). Entonces `T` y `A` son independientes bajo todo `θ`:
`P_θ(T = t, A = a) = P_θ(T = t)·P_θ(A = a)`.

Prueba: fijados `θ, a`, sea `c = P_θ(A = a)` y
`u(t) = (∑_{T x = t, A x = a} b(x)) / W(t) − c` con `W(t) = ∑_{T x = t} b(x)`.
Agrupando por fibras de `T` (reagrupaciones `sum_fiber_ind` para la parte
restringida a `{A = a}` y `sum_fiber_comp` para el total) resulta
`E_θ'[u(T)] = P_θ'(A = a) − c·1 = 0` para todo `θ'`, por ancilaridad y
normalización. La completitud da `u(T) = 0`, y multiplicando por `g_θ(t)` se
obtiene `P_θ(T = t, A = a) = c·P_θ(T = t)`.

Fidelidad declarada: espacio muestral finito, ancilaridad como igualdad de
las marginales de `A` para todo par de parámetros, independencia en la forma
`P_θ(T = t, A = a) = P_θ(T = t)·P_θ(A = a)` (la forma general para conjuntos
se sigue sumando y no se enuncia). `υ` es un tipo arbitrario con igualdad
decidible; no se exige que `A` sea real. Los pesos se suponen normalizados
(`∑ p_θ = 1`), hipótesis que en el libro es consustancial a «probabilidad».
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch2_basu {Θ : Type*} (p : Θ → X → ℝ) (T : X → τ) (A : X → υ)
    (g : Θ → τ → ℝ) (b : X → ℝ) (hfac : ∀ θ x, p θ x = g θ (T x) * b x)
    (hnorm : ∀ θ, ∑ x, p θ x = 1) (hbpos : ∀ x, 0 < b x)
    (hg : ∀ θ t, 0 ≤ g θ t)
    (hcomplete : ∀ u : τ → ℝ, (∀ θ, ∑ x, u (T x) * p θ x = 0) → ∀ x, u (T x) = 0)
    (hanc : ∀ (a : υ) (θ θ' : Θ),
        ∑ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a), p θ x
          = ∑ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a), p θ' x)
    (θ : Θ) (t : τ) (a : υ) :
    ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a), p θ x
      = (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), p θ x)
        * (∑ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a), p θ x) := by
  classical
  set c : ℝ := ∑ x ∈ (Finset.univ : Finset X).filter (fun x => A x = a), p θ x with hc
  set F : τ → ℝ := fun t =>
    ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a), b x with hF
  set u : τ → ℝ := fun t => F t / fibW T b t - c with hu
  have hzero : ∀ θ' : Θ, ∑ x, u (T x) * p θ' x = 0 := by
    intro θ'
    have h1 : (∑ x, u (T x) * p θ' x)
        = ∑ t ∈ (Finset.univ : Finset X).image T, u t * (g θ' t * fibW T b t) := by
      rw [show (∑ x, u (T x) * p θ' x) = ∑ x, (u (T x) * g θ' (T x)) * b x from
        Finset.sum_congr rfl fun x _ => by rw [hfac θ' x]; ring]
      rw [sum_fiber_comp T b (fun t => u t * g θ' t)]
      exact Finset.sum_congr rfl fun t _ => by ring
    rw [h1]
    have hsplit : ∀ t ∈ (Finset.univ : Finset X).image T, u t * (g θ' t * fibW T b t)
        = g θ' t * F t - c * (g θ' t * fibW T b t) := by
      intro t ht
      have hW : fibW T b t ≠ 0 := ne_of_gt (fibW_pos T b hbpos ht)
      rw [hu]
      calc (F t / fibW T b t - c) * (g θ' t * fibW T b t)
          = (F t / fibW T b t * fibW T b t) * g θ' t - c * (g θ' t * fibW T b t) := by ring
        _ = g θ' t * F t - c * (g θ' t * fibW T b t) := by
            rw [div_mul_cancel₀ _ hW]; ring
    rw [Finset.sum_congr rfl hsplit, Finset.sum_sub_distrib]
    have hfirst : (∑ t ∈ (Finset.univ : Finset X).image T, g θ' t * F t) = c := by
      rw [hF]
      rw [← sum_fiber_ind T A b (g θ') a]
      have hpt : ∀ x : X, (if A x = a then g θ' (T x) else 0) * b x
          = if A x = a then p θ' x else 0 := by
        intro x
        by_cases hx : A x = a
        · rw [if_pos hx, if_pos hx, hfac θ' x]
        · rw [if_neg hx, if_neg hx]; ring
      rw [Finset.sum_congr rfl fun x _ => hpt x, ← Finset.sum_filter, hc]
      exact (hanc a θ θ').symm
    have hsecond : (∑ t ∈ (Finset.univ : Finset X).image T, c * (g θ' t * fibW T b t)) = c := by
      rw [← Finset.mul_sum]
      have h2 : (∑ t ∈ (Finset.univ : Finset X).image T, g θ' t * fibW T b t) = ∑ x, p θ' x := by
        rw [← sum_fiber_comp T b (g θ')]
        exact Finset.sum_congr rfl fun x _ => (hfac θ' x).symm
      rw [h2, hnorm θ', mul_one]
    rw [hfirst, hsecond]
    ring
  have hu0 : ∀ x, u (T x) = 0 := hcomplete u hzero
  by_cases ht : t ∈ (Finset.univ : Finset X).image T
  · obtain ⟨x₀, -, hx₀⟩ := Finset.mem_image.mp ht
    have hWpos : 0 < fibW T b t := fibW_pos T b hbpos ht
    have hW : fibW T b t ≠ 0 := ne_of_gt hWpos
    have hu0t : u t = 0 := by
      have h' := hu0 x₀
      rwa [hx₀] at h'
    have hratio : F t / fibW T b t = c := by
      have h' := hu0t
      rw [hu] at h'
      linarith
    have hb_eq : F t = c * fibW T b t := by
      calc F t = (F t / fibW T b t) * fibW T b t := by rw [div_mul_cancel₀ _ hW]
        _ = c * fibW T b t := by rw [hratio]
    have hg_eq : (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a), p θ x)
        = g θ t * F t := by
      rw [hF, Finset.mul_sum]
      exact Finset.sum_congr rfl fun x hx => by
        rw [hfac θ x, (Finset.mem_filter.mp hx).2.1]
    have hT : (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), p θ x)
        = g θ t * fibW T b t := by
      show (∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), p θ x)
        = g θ t * ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), b x
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl fun x hx => by
        rw [hfac θ x, (Finset.mem_filter.mp hx).2]
    rw [hg_eq, hb_eq, hT, hc]
    ring
  · have h1 : (Finset.univ : Finset X).filter (fun x => T x = t ∧ A x = a) = ∅ :=
      Finset.filter_false_of_mem fun x _ hx => ht (by
        rw [← hx.1]; exact Finset.mem_image_of_mem T (Finset.mem_univ x))
    have h2 : (Finset.univ : Finset X).filter (fun x => T x = t) = ∅ :=
      Finset.filter_false_of_mem fun x _ hx => ht (by
        rw [← hx]; exact Finset.mem_image_of_mem T (Finset.mem_univ x))
    rw [h1, h2]
    simp

end Basu

/-! ### Cota de Cramér-Rao (versión finita con información de Fisher) -/

section CramerRao

variable {X : Type*} [Fintype X]

/-- Función score: `S(θ,x) = (∂_θ p_θ(x)) / p_θ(x)`. -/
noncomputable def score (p pd : ℝ → X → ℝ) (θ : ℝ) (x : X) : ℝ := pd θ x / p θ x

/-- Información de Fisher: `I(θ) = ∑_x S(θ,x)²·p_θ(x)`. -/
noncomputable def fisherInfo (p pd : ℝ → X → ℝ) (θ : ℝ) : ℝ :=
  ∑ x, (score p pd θ x) ^ 2 * p θ x

/-- La derivada de la media es la media de las derivadas (derivación bajo la
suma finita). -/
theorem hasDerivAt_mean (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ) (δ : X → ℝ) (θ : ℝ) :
    HasDerivAt (fun ξ => mean p δ ξ) (∑ x, δ x * pd θ x) θ := by
  have h1 : ∀ x ∈ (Finset.univ : Finset X),
      HasDerivAt (fun ξ => δ x * p ξ x) (δ x * pd θ x) θ :=
    fun x _ => (hp x θ).const_mul (δ x)
  have h := HasDerivAt.sum h1
  have h2 : (∑ i : X, fun ξ => δ i * p ξ i) = fun ξ => ∑ x, δ x * p ξ x := by
    funext ξ
    simp [Finset.sum_apply]
  rw [h2] at h
  simpa [mean] using h

/-- La derivada de la normalización se anula: `∑_x ∂_θ p_θ(x) = 0`. -/
theorem sum_pd_eq_zero (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hnorm : ∀ θ, ∑ x, p θ x = 1) (θ : ℝ) : ∑ x, pd θ x = 0 := by
  have h1 : ∀ x ∈ (Finset.univ : Finset X), HasDerivAt (fun ξ => p ξ x) (pd θ x) θ :=
    fun x _ => hp x θ
  have h := HasDerivAt.sum h1
  have h2 : (∑ i : X, fun ξ => p ξ i) = fun ξ => ∑ x, p ξ x := by
    funext ξ
    simp [Finset.sum_apply]
  rw [h2] at h
  have hconst : HasDerivAt (fun ξ => ∑ x, p ξ x) 0 θ := by
    have hfun : (fun ξ => ∑ x, p ξ x) = fun _ => (1 : ℝ) := by
      funext ξ
      exact hnorm ξ
    rw [hfun]
    exact hasDerivAt_const θ 1
  have h' : (∑ x, pd θ x) = 0 := (hconst.unique h).symm
  exact h'

/-- La varianza como suma centrada: con pesos normalizados,
`Var_θ(δ) = ∑_x (δ(x) − E_θδ)²·p_θ(x)`. -/
theorem variance_eq_centered (p : ℝ → X → ℝ) (hnorm : ∀ θ, ∑ x, p θ x = 1)
    (δ : X → ℝ) (θ : ℝ) :
    variance p δ θ = ∑ x, (δ x - mean p δ θ) ^ 2 * p θ x := by
  have hcalc : (∑ x, (δ x - mean p δ θ) ^ 2 * p θ x)
      = secondMoment p δ θ - (mean p δ θ) ^ 2 := by
    set m : ℝ := mean p δ θ with hm
    have hexp : ∀ x : X, (δ x - m) ^ 2 * p θ x
        = (δ x) ^ 2 * p θ x - 2 * m * (δ x * p θ x) + m ^ 2 * p θ x :=
      fun x => by ring
    have h1 : (∑ x, (δ x - m) ^ 2 * p θ x)
        = (∑ x, (δ x) ^ 2 * p θ x) - 2 * m * (∑ x, δ x * p θ x)
          + m ^ 2 * (∑ x, p θ x) := by
      rw [Finset.sum_congr rfl fun x _ => hexp x, Finset.sum_add_distrib,
        Finset.sum_sub_distrib]
      rw [show (∑ x, 2 * m * (δ x * p θ x)) = 2 * m * (∑ x, δ x * p θ x) from by
            rw [Finset.mul_sum],
          show (∑ x, m ^ 2 * p θ x) = m ^ 2 * (∑ x, p θ x) from by
            rw [Finset.mul_sum]]
    rw [h1, hnorm θ, hm]
    unfold mean secondMoment
    ring
  unfold variance
  linarith [hcalc]

/-- book: capitulos/cap04_herramientas.typ:990 (key: thm:ch3-cramer-rao) —
Cota inferior de Cramér-Rao (versión finita). Sea `p_θ` una familia de
densidades sobre un espacio muestral finito, derivable en `θ` con derivada
`∂_θ p_θ`, estrictamente positiva y normalizada (`∑_x p_θ(x) = 1`), y sea
`S(θ,x) = ∂_θ p_θ(x)/p_θ(x)` el score e `I(θ) = E_θ[S²]` la información de
Fisher. Entonces, para cualquier estimador `δ` con media derivable
(automático en el caso finito):
`(d/dθ E_θ[δ])² ≤ Var_θ(δ)·I(θ)`.

Prueba: (1) derivando la normalización, `∑_x ∂_θ p_θ(x) = 0`; (2) la
covarianza entre `δ` y el score vale exactamente `d/dθ E_θ[δ]`:
`∑_x (δ − E_θδ)·S·p_θ = ∑_x δ·∂_θ p_θ`; (3) Cauchy-Schwarz con pesos
`p_θ` (factores `√p_θ`) da `Cov² ≤ Var_θ(δ)·I(θ)`.

Fidelidad declarada: la derivación de la media se obtiene de la derivación
término a término (`hasDerivAt_mean`), de modo que la «regularidad
(intercambio de derivación e integración)» del libro es aquí un teorema y
no una hipótesis; el sesgo `b(θ) = E_θ[δ] − g(θ)` no se introduce: la cota
se enuncia directamente con la derivada de la media, que es
`g'(θ) + b'(θ)`. La información se define como `E[S²]` (no se usa la forma
`−E[∂² log p]`, que requiere derivar dos veces). No se enuncia la
caracterización de igualdad.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ch3_cramer_rao (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hpos : ∀ θ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1)
    (δ : X → ℝ) (θ : ℝ) :
    (∑ x, δ x * pd θ x) ^ 2 ≤ variance p δ θ * fisherInfo p pd θ := by
  have hpd0 : ∑ x, pd θ x = 0 := sum_pd_eq_zero p pd hp hnorm θ
  have hcov : (∑ x, (δ x - mean p δ θ) * score p pd θ x * p θ x)
      = ∑ x, δ x * pd θ x := by
    have h1 : ∀ x : X, (δ x - mean p δ θ) * score p pd θ x * p θ x
        = (δ x - mean p δ θ) * pd θ x := by
      intro x
      rw [score, mul_assoc, div_mul_cancel₀ _ (ne_of_gt (hpos θ x))]
    rw [Finset.sum_congr rfl fun x _ => h1 x]
    rw [show (∑ x, (δ x - mean p δ θ) * pd θ x)
        = (∑ x, δ x * pd θ x) - mean p δ θ * ∑ x, pd θ x from by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun x _ => by ring]
    rw [hpd0]
    ring
  have hvar : variance p δ θ = ∑ x, (δ x - mean p δ θ) ^ 2 * p θ x :=
    variance_eq_centered p hnorm δ θ
  have hI : fisherInfo p pd θ = ∑ x, (score p pd θ x) ^ 2 * p θ x := rfl
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (s := (Finset.univ : Finset X))
    (f := fun x => (δ x - mean p δ θ) * Real.sqrt (p θ x))
    (g := fun x => score p pd θ x * Real.sqrt (p θ x))
  have hleft : (∑ x, (δ x - mean p δ θ) * Real.sqrt (p θ x)
        * (score p pd θ x * Real.sqrt (p θ x)))
      = ∑ x, (δ x - mean p δ θ) * score p pd θ x * p θ x := by
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [show (δ x - mean p δ θ) * Real.sqrt (p θ x) * (score p pd θ x * Real.sqrt (p θ x))
        = (δ x - mean p δ θ) * score p pd θ x
          * (Real.sqrt (p θ x) * Real.sqrt (p θ x)) from by ring,
      Real.mul_self_sqrt (le_of_lt (hpos θ x))]
  have hf1 : (∑ x, ((δ x - mean p δ θ) * Real.sqrt (p θ x)) ^ 2)
      = ∑ x, (δ x - mean p δ θ) ^ 2 * p θ x := by
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [mul_pow, Real.sq_sqrt (le_of_lt (hpos θ x))]
  have hf2 : (∑ x, (score p pd θ x * Real.sqrt (p θ x)) ^ 2) = fisherInfo p pd θ := by
    rw [hI]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [mul_pow, Real.sq_sqrt (le_of_lt (hpos θ x))]
  calc (∑ x, δ x * pd θ x) ^ 2
      = (∑ x, (δ x - mean p δ θ) * score p pd θ x * p θ x) ^ 2 := by rw [hcov]
    _ = (∑ x, (δ x - mean p δ θ) * Real.sqrt (p θ x)
          * (score p pd θ x * Real.sqrt (p θ x))) ^ 2 := by rw [hleft]
    _ ≤ (∑ x, ((δ x - mean p δ θ) * Real.sqrt (p θ x)) ^ 2)
          * (∑ x, (score p pd θ x * Real.sqrt (p θ x)) ^ 2) := hcs
    _ = (∑ x, (δ x - mean p δ θ) ^ 2 * p θ x) * fisherInfo p pd θ := by rw [hf1, hf2]
    _ = variance p δ θ * fisherInfo p pd θ := by rw [← hvar]

/-- book: capitulos/cap04_herramientas.typ:1040 (key: cor:ch3-cr-iid) —
Cota de Cramér-Rao para muestras iid. Si la información de Fisher del
experimento de tamaño `n` es aditiva, `I_n(θ) = n·I_1(θ)` (véase
`prop:ch3-info-aditiva`), entonces la cota de `thm:ch3-cramer-rao` se
escribe `(d/dθ E_θ[δ])² / (n·I_1(θ)) ≤ Var_θ(δ)`.

Fidelidad declarada: la aditividad `I_n = n·I_1` se toma como hipótesis
(no se construye el modelo producto de `n` copias independientes); es
exactamente el contenido de `prop:ch3-info-aditiva`, ya formalizada.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem cor_ch3_cr_iid (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hpos : ∀ θ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1)
    (δ : X → ℝ) (θ : ℝ) {n : ℕ} (hn : 0 < n) {I₁ : ℝ} (hI₁ : 0 < I₁)
    (hI : fisherInfo p pd θ = (n : ℝ) * I₁) :
    (∑ x, δ x * pd θ x) ^ 2 / ((n : ℝ) * I₁) ≤ variance p δ θ := by
  have h := ch3_cramer_rao p pd hp hpos hnorm δ θ
  rw [hI] at h
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpos' : 0 < (n : ℝ) * I₁ := mul_pos hnR hI₁
  rw [div_le_iff₀ hpos']
  exact h

end CramerRao

section EjemplosSuficiencia

/-- book: capitulos/cap04_herramientas.typ:610 (key: ex:ch2-normal-suficiencia) —
Suficiencia en la familia normal (versión finita). La verosimilitud de una
muestra `x : Fin n → ℝ` de la normal `N(μ, σ²)` depende de `x` sólo a través de
`T(x) = (∑ᵢ xᵢ, ∑ᵢ xᵢ²)`: dos muestras con el mismo `T` tienen exactamente la
misma verosimilitud.

Prueba: `∏ᵢ exp(−(xᵢ−μ)²/(2σ²)) = exp(−(∑ᵢxᵢ² − 2μ∑ᵢxᵢ + nμ²)/(2σ²))`, que es
la expansión del cuadrado del libro; el factor de normalización
`(2πσ²)^(−n/2)` no depende de `x` y se omite.

Fidelidad declarada: se enuncia la invariancia de la verosimilitud sobre las
fibras de `T` (el contenido de la factorización de Neyman-Fisher con
`g_θ(T x) = (2πσ²)^(−n/2)·exp(−(T₂ − 2μT₁ + nμ²)/(2σ²))`, `h ≡ 1`), no la
construcción explícita de `g`. `σ² ≠ 0` en lugar de `σ² > 0` (la identidad es
algebraica).
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ex_ch2_normal_suficiencia (n : ℕ) (μ σ2 : ℝ) (hσ : σ2 ≠ 0)
    (x y : Fin n → ℝ) (hT1 : ∑ i, x i = ∑ i, y i)
    (hT2 : ∑ i, (x i) ^ 2 = ∑ i, (y i) ^ 2) :
    (∏ i, Real.exp (-((x i - μ) ^ 2) / (2 * σ2)))
      = ∏ i, Real.exp (-((y i - μ) ^ 2) / (2 * σ2)) := by
  have hsq : ∀ z : Fin n → ℝ, (∑ i, (z i - μ) ^ 2)
      = (∑ i, (z i) ^ 2) - 2 * μ * (∑ i, z i) + (n : ℝ) * μ ^ 2 := by
    intro z
    rw [show (∑ i, (z i - μ) ^ 2) = ∑ i, ((z i) ^ 2 - 2 * μ * z i + μ ^ 2) from
      Finset.sum_congr rfl fun i _ => by ring]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have key : ∀ z : Fin n → ℝ, (∏ i, Real.exp (-((z i - μ) ^ 2) / (2 * σ2)))
      = Real.exp (-((∑ i, (z i) ^ 2) - 2 * μ * (∑ i, z i) + (n : ℝ) * μ ^ 2)
          / (2 * σ2)) := by
    intro z
    rw [← Real.exp_sum, Real.exp_injective.eq_iff]
    rw [← Finset.sum_div, Finset.sum_neg_distrib, hsq z]
  rw [key x, key y, hT1, hT2]

/-- book: capitulos/cap04_herramientas.typ:629 (key: ex:ch2-poisson-suficiencia) —
Suficiencia en la familia de Poisson (versión finita). La función de masa
conjunta factoriza como `g_λ(T(x))·h(x)` con `T(x) = ∑ᵢ xᵢ`:
`∏ᵢ λ^{xᵢ}e^{−λ}/xᵢ! = (λ^{∑ᵢxᵢ}·e^{−nλ})·∏ᵢ (xᵢ!)⁻¹`.

Prueba: `∏ᵢ λ^{xᵢ} = λ^{∑ᵢxᵢ}` (`Finset.prod_pow_eq_pow_sum`), `∏ᵢ e^{−λ} = e^{−nλ}`
y separación del producto de los factoriales (`Finset.prod_mul_distrib`).

Fidelidad declarada: `T` tiene dimensión 1 con independencia de `n`; se enuncia
la factorización con `h(x) = ∏ᵢ (xᵢ!)⁻¹`, que es exactamente el `h` del libro.
Origen: enjambre smw82qi6q, dirección d4 (formalización de pendiente). -/
theorem ex_ch2_poisson_suficiencia (n : ℕ) (lam : ℝ) (x : Fin n → ℕ) :
    (∏ i, lam ^ (x i) * Real.exp (-lam) / (Nat.factorial (x i) : ℝ))
      = (lam ^ (∑ i, x i) * Real.exp (-(n : ℝ) * lam))
        * ∏ i, ((Nat.factorial (x i) : ℝ))⁻¹ := by
  have hpt : ∀ i : Fin n,
      lam ^ (x i) * Real.exp (-lam) / (Nat.factorial (x i) : ℝ)
        = (lam ^ (x i) * Real.exp (-lam)) * ((Nat.factorial (x i) : ℝ))⁻¹ := by
    intro i
    rw [div_eq_mul_inv]
  rw [Finset.prod_congr rfl fun i _ => hpt i, Finset.prod_mul_distrib,
    Finset.prod_mul_distrib, Finset.prod_pow_eq_pow_sum, Finset.prod_const,
    Finset.card_univ, Fintype.card_fin]
  have hexp : Real.exp (-lam) ^ n = Real.exp (-(n : ℝ) * lam) := by
    rw [← Real.exp_nat_mul]
    congr 1
    ring
  rw [hexp]

end EjemplosSuficiencia

end Book.Cap04Suficiencia
