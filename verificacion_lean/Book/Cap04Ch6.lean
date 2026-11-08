import Mathlib

/-!
# Book.Cap04Herramientas (bloque cap. 6) — estimación semiparamétrica

Formalización de los pendientes del capítulo 6 de
`book_stat_inference_v0/capitulos/cap04_herramientas.typ`: identidad
exacta de doble robustez, cota de eficiencia (Pitágoras de Hilbert),
varianza de referencia, ortogonalidad de Neyman, gradiente canónico
(modelo Markov finito por tiempo), estimador aumentado para OPE,
descomposición ortogonal, unidad de partición, ajuste backdoor y
expansión asintóticamente lineal.

Convención del proyecto (plan §6): cada teorema lleva su trazabilidad
`book: <archivo>:<línea> (key: <clave>)`, cero «s-o-r-r-y», y fidelidad
declarada en el docstring cuando el libro enuncia una versión continua o
asintótica y aquí se prueba la versión finita/discreta indicada.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators
open MeasureTheory ProbabilityTheory Filter
open scoped RealInnerProductSpace Topology

universe u6

/-! ## thm:ch6-dr — identidad exacta de doble robustez -/

/-- Identidad algebraica puntual de la doble robustez (base no enunciada):
con `a = ē(x)`, `b = e(x)`, `c = m̄₁(x)`, `d = m₁(x)`, `f = m̄₀(x)`,
`g = m₀(x)`, para `a ≠ 0` y `1 - a ≠ 0`,

`c - f + b/a·(d - c) - (1-b)/(1-a)·(g - f) - (d - g)`
`  = (a - b)·((c - d)/a + (f - g)/(1 - a))`.

Es la cancelación de la identidad DR condicionada en `X = x`. -/
theorem dr_pointwise (a b c d f g : ℝ) (ha : a ≠ 0) (ha' : 1 - a ≠ 0) :
    c - f + b / a * (d - c) - (1 - b) / (1 - a) * (g - f) - (d - g)
      = (a - b) * ((c - d) / a + (f - g) / (1 - a)) := by
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1955 (key: thm:ch6-dr) —
identidad exacta de doble robustez (versión finita, condicionada en `X`).
`p` es la ley discreta de `X`; `e` es la propensión verdadera; `ehat`, `mbar1`,
`mbar0` son las funciones candidatas y `m1`, `m0` las medias condicionales
verdaderas. Entonces

`E_p[D(·;η̂)] - E_p[m₁ - m₀] = E_p[(ē - e)·((m̄₁ - m₁)/ē + (m̄₀ - m₀)/(1 - ē))]`

donde `D` es el pseudoresultado AIPW
`m̄₁ - m̄₀ + A/ē·(Y - m̄₁) - (1-A)/(1-ē)·(Y - m̄₀)` y la esperanza sobre
`A | X = x` se calcula con la ley de `A` dada `X` (los dos términos con
`A` colapsan a `e(x)/ē(x)·(m₁ - m̄₁)` y `-(1-e(x))/(1-ē(x))·(m₀ - m̄₀)`).
Fidelidad declarada: versión finita y *poblacional* (funciones fijas,
denominadores alejados de cero `ē(x) ∉ {0,1}`); la ley de grandes números
y el control de errores para funciones estimadas no se enuncian, y no se
afirma insesgadez finita con ajustes reutilizados en la misma muestra.
Origen: F-correction 2026-11-08 (nuevo; formalización de pendiente). -/
theorem thm_ch6_dr {X : Type u6} [Fintype X]
    (p ehat e mbar1 m1 mbar0 m0 : X → ℝ)
    (hE : ∀ x, ehat x ≠ 0) (hE1 : ∀ x, 1 - ehat x ≠ 0) :
    (∑ x, p x * (mbar1 x - mbar0 x + e x / ehat x * (m1 x - mbar1 x)
        - (1 - e x) / (1 - ehat x) * (m0 x - mbar0 x)))
      - (∑ x, p x * (m1 x - m0 x))
      = ∑ x, p x * ((ehat x - e x) * ((mbar1 x - m1 x) / ehat x
          + (mbar0 x - m0 x) / (1 - ehat x))) := by
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  have h := dr_pointwise (ehat x) (e x) (mbar1 x) (m1 x) (mbar0 x) (m0 x) (hE x) (hE1 x)
  calc p x * (mbar1 x - mbar0 x + e x / ehat x * (m1 x - mbar1 x)
        - (1 - e x) / (1 - ehat x) * (m0 x - mbar0 x)) - p x * (m1 x - m0 x)
      = p x * ((mbar1 x - mbar0 x + e x / ehat x * (m1 x - mbar1 x)
          - (1 - e x) / (1 - ehat x) * (m0 x - mbar0 x)) - (m1 x - m0 x)) := by ring
    _ = p x * ((ehat x - e x) * ((mbar1 x - m1 x) / ehat x
          + (mbar0 x - m0 x) / (1 - ehat x))) := by rw [h]

/-- book: capitulos/cap04_herramientas.typ:1955 (key: thm:ch6-dr) —
primera mitad de la doble robustez: si la propensión candidata es la
verdadera (`ē = e`), el sesgo poblacional del AIPW es exactamente cero,
`E_p[D] = E_p[m₁ - m₀] = ψ`. Fidelidad declarada: versión finita
poblacional (funciones fijas); véase `thm_ch6_dr`. -/
theorem thm_ch6_dr_propension {X : Type u6} [Fintype X]
    (p ehat e mbar1 m1 mbar0 m0 : X → ℝ)
    (hE : ∀ x, ehat x ≠ 0) (hE1 : ∀ x, 1 - ehat x ≠ 0)
    (hprop : ∀ x, ehat x = e x) :
    ∑ x, p x * (mbar1 x - mbar0 x + e x / ehat x * (m1 x - mbar1 x)
        - (1 - e x) / (1 - ehat x) * (m0 x - mbar0 x))
      = ∑ x, p x * (m1 x - m0 x) := by
  have hmain := thm_ch6_dr p ehat e mbar1 m1 mbar0 m0 hE hE1
  have hzero : ∑ x, p x * ((ehat x - e x) * ((mbar1 x - m1 x) / ehat x
      + (mbar0 x - m0 x) / (1 - ehat x))) = 0 := by
    refine Finset.sum_eq_zero fun x _ => ?_
    rw [hprop x]
    ring
  rw [hzero] at hmain
  exact sub_eq_zero.mp hmain

/-- book: capitulos/cap04_herramientas.typ:1955 (key: thm:ch6-dr) —
segunda mitad de la doble robustez: si ambas regresiones candidatas son
las verdaderas (`m̄₁ = m₁`, `m̄₀ = m₀`), el sesgo poblacional del AIPW es
exactamente cero, cualquiera sea la propensión candidata `ē`.
Fidelidad declarada: versión finita poblacional; véase `thm_ch6_dr`. -/
theorem thm_ch6_dr_modelos {X : Type u6} [Fintype X]
    (p ehat e mbar1 m1 mbar0 m0 : X → ℝ)
    (hE : ∀ x, ehat x ≠ 0) (hE1 : ∀ x, 1 - ehat x ≠ 0)
    (hm1 : ∀ x, mbar1 x = m1 x) (hm0 : ∀ x, mbar0 x = m0 x) :
    ∑ x, p x * (mbar1 x - mbar0 x + e x / ehat x * (m1 x - mbar1 x)
        - (1 - e x) / (1 - ehat x) * (m0 x - mbar0 x))
      = ∑ x, p x * (m1 x - m0 x) := by
  have hmain := thm_ch6_dr p ehat e mbar1 m1 mbar0 m0 hE hE1
  have hzero : ∑ x, p x * ((ehat x - e x) * ((mbar1 x - m1 x) / ehat x
      + (mbar0 x - m0 x) / (1 - ehat x))) = 0 := by
    refine Finset.sum_eq_zero fun x _ => ?_
    rw [hm1 x, hm0 x]
    ring
  rw [hzero] at hmain
  exact sub_eq_zero.mp hmain
/-! ## thm:ch6-cota — cota de eficiencia -/

/-- book: capitulos/cap04_herramientas.typ:1919 (key: thm:ch6-cota) —
cota de eficiencia, forma de Hilbert: si `φ_eff` está en el espacio
tangente `𝓣` y `h` es ortogonal a `𝓣`, la descomposición `φ = φ_eff + h`
es pitagórica, `‖φ‖² = ‖φ_eff‖² + ‖h‖²`. En el libro `‖·‖` es la norma
de `L²(P₀)`, i.e. `‖φ‖² = E₀[φ²]`. Fidelidad declarada: se formaliza el
contenido métrico (Pitágoras con `φ_eff ∈ 𝓣`, `h ∈ 𝓣^⊥`), que es
exactamente el argumento del libro; la existencia de `φ_eff` como
proyección y la teoría de diferenciabilidad por caminos quedan como
hipótesis estructurales del modelo (el espacio `𝓣` se toma como
subespacio de un espacio de Hilbert real). -/
theorem thm_ch6_cota {V : Type u6} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (φeff h : V) (hφ : φeff ∈ T) (hh : h ∈ Tᗮ) :
    ‖φeff + h‖ ^ 2 = ‖φeff‖ ^ 2 + ‖h‖ ^ 2 := by
  rw [norm_add_sq_real, Submodule.inner_right_of_mem_orthogonal hφ hh]
  ring

/-- book: capitulos/cap04_herramientas.typ:1919 (key: thm:ch6-cota) —
la desigualdad de la cota: `E₀[φ_eff²] ≤ E₀[φ²]` para todo representante
`φ = φ_eff + h` con `h ⊥ 𝓣`. -/
theorem thm_ch6_cota_le {V : Type u6} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (φeff h : V) (hφ : φeff ∈ T) (hh : h ∈ Tᗮ) :
    ‖φeff‖ ^ 2 ≤ ‖φeff + h‖ ^ 2 := by
  rw [thm_ch6_cota T φeff h hφ hh]
  have := norm_nonneg h
  nlinarith

/-- book: capitulos/cap04_herramientas.typ:1919 (key: thm:ch6-cota) —
la igualdad exige `φ = φ_eff` en `L²(P₀)`: si se alcanza la cota, el
componente ortogonal es nulo. -/
theorem thm_ch6_cota_igualdad {V : Type u6} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (T : Submodule ℝ V) (φeff h : V) (hφ : φeff ∈ T) (hh : h ∈ Tᗮ)
    (heq : ‖φeff + h‖ ^ 2 = ‖φeff‖ ^ 2) : h = 0 := by
  have hpit := thm_ch6_cota T φeff h hφ hh
  have hnorm : ‖h‖ ^ 2 = 0 := by linarith
  exact norm_eq_zero.mp (sq_eq_zero_iff.mp hnorm)

/-- book: capitulos/cap04_herramientas.typ:1919 (key: thm:ch6-cota) —
versión `L²(P₀)` discreta de la cota, con la notación del libro:
`E_p[φ²] = E_p[φ_eff²] + E_p[h²]` cuando `E_p[φ_eff·h] = 0` y
`φ = φ_eff + h`. Con pesos no negativos se sigue
`E_p[φ_eff²] ≤ E_p[φ²]`. -/
theorem thm_ch6_cota_expect {X : Type u6} [Fintype X] (p φ φeff h : X → ℝ)
    (hadd : ∀ x, φ x = φeff x + h x) (horth : ∑ x, p x * φeff x * h x = 0) :
    ∑ x, p x * φ x ^ 2 = ∑ x, p x * φeff x ^ 2 + ∑ x, p x * h x ^ 2 := by
  have hterm : ∀ x, p x * φ x ^ 2
      = p x * φeff x ^ 2 + 2 * (p x * φeff x * h x) + p x * h x ^ 2 := by
    intro x; rw [hadd x]; ring
  rw [Finset.sum_congr rfl fun x _ => hterm x]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, horth]
  ring

/-- book: capitulos/cap04_herramientas.typ:1919 (key: thm:ch6-cota) —
la cota como desigualdad de esperanzas, el enunciado del libro
`E₀[φ²] ≥ E₀[φ_eff²]`. -/
theorem thm_ch6_cota_expect_le {X : Type u6} [Fintype X] (p φ φeff h : X → ℝ)
    (hp : ∀ x, 0 ≤ p x) (hadd : ∀ x, φ x = φeff x + h x)
    (horth : ∑ x, p x * φeff x * h x = 0) :
    ∑ x, p x * φeff x ^ 2 ≤ ∑ x, p x * φ x ^ 2 := by
  rw [thm_ch6_cota_expect p φ φeff h hadd horth]
  have hnn : 0 ≤ ∑ x, p x * h x ^ 2 :=
    Finset.sum_nonneg fun x _ => mul_nonneg (hp x) (sq_nonneg _)
  linarith

/-! ## cor:ch6-varianza-minima — varianza de referencia -/

/-- book: capitulos/cap04_herramientas.typ:1927 (key: cor:ch6-varianza-minima) —
varianza de referencia: la cota por observación es `σ_eff² = E₀[φ_eff²]`;
un promedio de `n` réplicas iid tiene varianza `σ_eff²/n`. La identidad
`n·σ²/n² = σ²/n` es el cambio de escala entre la varianza de la suma
(`n·σ²`) y la del promedio (dividida por `n²`). Fidelidad declarada:
aritmética de la escala; no se formaliza la normalidad asintótica (véase
`prop:ch6-ral`), y alcanzar la cota requiere un estimador con resto
despreciable, que el libro declara no garantizado sólo por escribir la IF. -/
theorem cor_ch6_varianza_minima {n : ℕ} (hn : 0 < n) (σ2 : ℝ) :
    ((n : ℝ) * σ2) / (n : ℝ) ^ 2 = σ2 / n := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1927 (key: cor:ch6-varianza-minima) —
la cota se hereda a la varianza del promedio: si `σ_eff² ≤ σ²` entonces
`σ_eff²/n ≤ σ²/n`. -/
theorem cor_ch6_varianza_minima_cota {n : ℕ} (hn : 0 < n) {σ2 σeff2 : ℝ}
    (h : σeff2 ≤ σ2) : σeff2 / n ≤ σ2 / n := by
  have hnR : (0 : ℝ) ≤ n := by positivity
  exact div_le_div_of_nonneg_right h hnR

/-! ## prop:ch6-descomposicion — descomposición ortogonal correcta -/

/-- book: capitulos/cap04_herramientas.typ:1878 (key: prop:ch6-descomposicion) —
descomposición ortogonal correcta: como `𝓣_η` es un subespacio cerrado de
`𝓣` (y `𝓣` un subespacio de un espacio de Hilbert, aquí de dimensión
finita), vale `𝓣 = 𝓣_η ⊔ (𝓣 ⊓ 𝓣_η^⊥)` con intersección nula. Fidelidad
declarada: versión de dimensión finita (todo subespacio es cerrado y tiene
proyección ortogonal); el caso general de Hilbert es idéntico usando la
proyección sobre un subespacio cerrado. -/
theorem prop_ch6_descomposicion {V : Type u6} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    [FiniteDimensional ℝ V] (T Tη : Submodule ℝ V) (hsub : Tη ≤ T) :
    Tη ⊔ (T ⊓ Tηᗮ) = T ∧ Disjoint Tη (T ⊓ Tηᗮ) := by
  have hcompl : Tη ⊔ Tηᗮ = ⊤ := (Submodule.isCompl_orthogonal (K := Tη)).sup_eq_top
  refine ⟨?_, (Submodule.isCompl_orthogonal (K := Tη)).disjoint.mono_right inf_le_right⟩
  refine le_antisymm (sup_le hsub inf_le_left) ?_
  intro v hv
  have hmem : v ∈ Tη ⊔ Tηᗮ := by rw [hcompl]; exact Submodule.mem_top
  obtain ⟨a, ha, b, hb, hab⟩ := Submodule.mem_sup.mp hmem
  have hb' : b = v - a := by
    rw [eq_sub_iff_add_eq, add_comm]
    exact hab
  exact Submodule.mem_sup.mpr ⟨a, ha, b, Submodule.mem_inf.mpr
    ⟨by rw [hb']; exact T.sub_mem hv (hsub ha), hb⟩, hab⟩

/-- book: capitulos/cap04_herramientas.typ:1878 (key: prop:ch6-descomposicion) —
forma de Hilbert de la misma identidad: `𝓣 = 𝓣_η ⊕ 𝓣_η^⊥`, i.e. la
proyección ortogonal sobre `𝓣_η` existe y es única. -/
theorem prop_ch6_descomposicion_isCompl {V : Type u6} [NormedAddCommGroup V]
    [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] (Tη : Submodule ℝ V) :
    IsCompl Tη Tηᗮ :=
  Submodule.isCompl_orthogonal (K := Tη)

/-! ## thm:ch6-neyman — ortogonalidad, sesgo y eficiencia -/

/-- book: capitulos/cap04_herramientas.typ:1939 (key: thm:ch6-neyman) —
ortogonalidad de Neyman: si el mapa auxiliar `t ↦ M(ψ₀, η₀ + t·h)` tiene
la expansión de segundo orden `M t = M₀ + t·D + t²·C` y la ortogonalidad
anula la derivada (`D = 0`), el término lineal del sesgo desaparece y el
sesgo es exactamente cuadrático en la perturbación: `M t - M₀ = t²·C`.
Fidelidad declarada: se toma la expansión de segundo orden como hipótesis
(el libro pide «resto controlado»); la conclusión formalizada es la
eliminación del término lineal, no la eficiencia ni la doble robustez
global, que el libro tampoco deduce de la ortogonalidad. -/
theorem thm_ch6_neyman {M : ℝ → ℝ} {M0 D C : ℝ}
    (hexp : ∀ t, M t = M0 + t * D + t ^ 2 * C) (hort : D = 0) :
    ∀ t, M t - M0 = t ^ 2 * C := by
  intro t
  rw [hexp t, hort]
  ring

/-- book: capitulos/cap04_herramientas.typ:1939 (key: thm:ch6-neyman) —
consecuencia cuantitativa: el sesgo de una perturbación de tamaño `t` está
acotado por `|C|·t²` (resto de segundo orden). -/
theorem thm_ch6_neyman_cota {M : ℝ → ℝ} {M0 D C : ℝ}
    (hexp : ∀ t, M t = M0 + t * D + t ^ 2 * C) (hort : D = 0) (t : ℝ) :
    |M t - M0| ≤ |C| * t ^ 2 := by
  rw [thm_ch6_neyman hexp hort t, abs_mul, abs_of_nonneg (sq_nonneg t)]
  exact le_of_eq (mul_comm _ _)

/-- book: capitulos/cap04_herramientas.typ:1939 (key: thm:ch6-neyman) —
normalización: multiplicar un momento ortogonal por una constante no nula
conserva sus raíces y la ortogonalidad (la derivada sigue siendo cero),
de modo que la IF eficiente no queda caracterizada sin normalización. -/
theorem thm_ch6_neyman_escala {m : ℝ → ℝ} {D c : ℝ} (hc : c ≠ 0)
    (hm : HasDerivAt m D 0) (h0 : D = 0) (t : ℝ) :
    HasDerivAt (fun s => c * m s) 0 0 ∧ (c * m t = 0 ↔ m t = 0) := by
  refine ⟨?_, ⟨fun h => (mul_eq_zero.mp h).resolve_left hc, fun h => by rw [h, mul_zero]⟩⟩
  have := hm.const_mul c
  rwa [h0, mul_zero] at this
/-! ## thm:ch6-kallus — gradiente canónico en el modelo Markov finito -/

/-- book: capitulos/cap04_herramientas.typ:1974 (key: thm:ch6-kallus) —
gradiente canónico, pieza 1: en el modelo Markov finito por tiempo, con
`q_t(s,a) = r_t(s,a) + γ·∑_{s'} P_t(s'|s,a)·v_{t+1}(s')` y un kernel de
probabilidad (`∑_{s'} P_t(s'|s,a) = 1`), el residuo de Bellman
`R_t + γ·v_{t+1}(S_{t+1}) - q_t(S_t,A_t)` tiene esperanza condicional nula
dados `(S_t,A_t) = (s,a)`. Es el ingrediente que hace que el término
`∑_t γ^t w_t·(residuo_t)` de la IF eficiente esté centrado.
Fidelidad declarada: espacios de estados y acciones finitos (aquí `Bool`
para la acción), un paso de tiempo; no se formaliza la optimalidad ni la
eficiencia asintótica, y `w_t` (razones marginales) no interviene en esta
pieza. -/
theorem thm_ch6_kallus_residual {S : Type u6} [Fintype S]
    (P : S → S → Bool → ℝ) (r : S → Bool → ℝ) (v : S → ℝ) (q : S → Bool → ℝ)
    (γ : ℝ) (hq : ∀ s a, q s a = r s a + γ * ∑ s', P s' s a * v s')
    (hP : ∀ s a, ∑ s', P s' s a = 1) :
    ∀ s a, ∑ s', P s' s a * (r s a + γ * v s' - q s a) = 0 := by
  intro s a
  have h1 : ∑ s', P s' s a * (r s a + γ * v s' - q s a)
      = (r s a - q s a) * (∑ s', P s' s a) + γ * (∑ s', P s' s a * v s') := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun s' _ => by ring
  rw [h1, hP s a, mul_one, hq s a]
  ring

/-- book: capitulos/cap04_herramientas.typ:1974 (key: thm:ch6-kallus) —
gradiente canónico, pieza 2: ningún valor esperado de un residuo
condicionalmente centrado contribuye; ponderar por la ley estado-acción
`d` y las razones marginales `w` deja la media en cero. Es la versión
finita de «cada residuo tiene esperanza condicional cero con las funciones
verdaderas». -/
theorem thm_ch6_kallus_pesos {S : Type u6} [Fintype S]
    (d w : S → Bool → ℝ) (P : S → S → Bool → ℝ) (r : S → Bool → ℝ)
    (v : S → ℝ) (q : S → Bool → ℝ) (γ : ℝ)
    (hq : ∀ s a, q s a = r s a + γ * ∑ s', P s' s a * v s')
    (hP : ∀ s a, ∑ s', P s' s a = 1) :
    ∑ s, ∑ a, d s a * w s a * (∑ s', P s' s a * (r s a + γ * v s' - q s a)) = 0 := by
  refine Finset.sum_eq_zero fun s _ => Finset.sum_eq_zero fun a _ => ?_
  rw [thm_ch6_kallus_residual P r v q γ hq hP s a]
  ring

/-- book: capitulos/cap04_herramientas.typ:1974 (key: thm:ch6-kallus) —
gradiente canónico, pieza 3: el término asociado a la ley inicial,
`v₀(S₀) - J` con `J = ∑_s μ(s)·v₀(s)`, se anula al integrar respecto de
`μ` (si `μ` es una probabilidad). Es el «si se conoce la ley inicial y se
integra respecto de ella, se elimina el componente `v₀(S₀) - J`». -/
theorem thm_ch6_kallus_inicial {S : Type u6} [Fintype S] (μ v : S → ℝ) (J : ℝ)
    (hμ : ∑ s, μ s = 1) (hJ : J = ∑ s, μ s * v s) :
    ∑ s, μ s * (v s - J) = 0 := by
  have h1 : ∑ s, μ s * (v s - J) = ∑ s, (μ s * v s - μ s * J) :=
    Finset.sum_congr rfl fun s _ => mul_sub _ _ _
  rw [h1, Finset.sum_sub_distrib]
  have h2 : ∑ x, μ x * J = J := by rw [← Finset.sum_mul, hμ, one_mul]
  rw [h2, hJ]
  exact sub_self _

/-! ## cor:ch6-dr-ope — estimador aumentado para OPE -/

/-- book: capitulos/cap04_herramientas.typ:1982 (key: cor:ch6-dr-ope) —
estimador aumentado para OPE (un paso, versión finita): con `μ` la ley
inicial, `b` la política de comportamiento, `πt` la objetivo,
`d(s,a) = μ(s)·b(a|s)` la ley estado-acción observada y
`J = ∑_s μ(s)·∑_a πt(a|s)·q(s,a)`, la identidad poblacional
«plug-in + aumento ponderado» es correcta si **todas** las funciones `q`
son correctas (`q̄ = q`): el término de aumento se anula.
Fidelidad declarada: modelo Markov finito de un paso (`H = 1`);
la mitad de las razones (abajo) y el horizonte finito con telescopio
`∑_t γ^t` quedan fuera de esta pieza. -/
theorem cor_ch6_dr_ope_modelos {S : Type u6} [Fintype S]
    (μ : S → ℝ) (b πt : S → Bool → ℝ) (q qbar : S → Bool → ℝ) (w : S → Bool → ℝ)
    (hq : ∀ s a, qbar s a = q s a) :
    (∑ s, μ s * (∑ a, πt s a * qbar s a))
      + (∑ s, ∑ a, μ s * b s a * w s a * (q s a - qbar s a))
      = ∑ s, μ s * (∑ a, πt s a * q s a) := by
  have h1 : ∑ s, ∑ a, μ s * b s a * w s a * (q s a - qbar s a) = 0 := by
    refine Finset.sum_eq_zero fun s _ => Finset.sum_eq_zero fun a _ => ?_
    rw [hq s a, sub_self, mul_zero]
  rw [h1, add_zero]
  refine Finset.sum_congr rfl fun s _ => ?_
  congr 1
  exact Finset.sum_congr rfl fun a _ => by rw [hq s a]

/-- book: capitulos/cap04_herramientas.typ:1982 (key: cor:ch6-dr-ope) —
estimador aumentado para OPE (un paso, versión finita), mitad de las
razones: si las razones marginales son las correctas
(`w(s,a) = πt(a|s)/b(a|s)`, con `b(a|s) ≠ 0`), la identidad poblacional es
correcta para **cualquier** `q̄`: el aumento reconstruye la diferencia
`∑_{s,a} μ(s)πt(a|s)(q - q̄)` que falta al plug-in. Es la doble robustez
del corolario: `q` correctas **o** razones correctas.
Fidelidad declarada: un paso de tiempo y pesos marginales (no productos de
razones de trayectoria); la consistencia y el CLT requieren controles
adicionales de productos de errores que no se formalizan. -/
theorem cor_ch6_dr_ope_pesos {S : Type u6} [Fintype S]
    (μ : S → ℝ) (b πt : S → Bool → ℝ) (q qbar : S → Bool → ℝ) (w : S → Bool → ℝ)
    (hb : ∀ s a, b s a ≠ 0) (hw : ∀ s a, w s a = πt s a / b s a) :
    (∑ s, μ s * (∑ a, πt s a * qbar s a))
      + (∑ s, ∑ a, μ s * b s a * w s a * (q s a - qbar s a))
      = ∑ s, μ s * (∑ a, πt s a * q s a) := by
  have hstep : ∀ s a, μ s * b s a * w s a * (q s a - qbar s a)
      = μ s * (πt s a * (q s a - qbar s a)) := by
    intro s a
    have hba := hb s a
    rw [hw s a]
    field_simp
  have hstep2 : ∑ s, ∑ a, μ s * b s a * w s a * (q s a - qbar s a)
      = ∑ s, ∑ a, μ s * (πt s a * (q s a - qbar s a)) :=
    Finset.sum_congr rfl fun s _ => Finset.sum_congr rfl fun a _ => hstep s a
  rw [hstep2, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun s _ => ?_
  have h3 : ∑ a, μ s * (πt s a * (q s a - qbar s a))
      = μ s * ∑ a, πt s a * (q s a - qbar s a) := by
    rw [Finset.mul_sum]
  rw [h3, ← mul_add, ← Finset.sum_add_distrib]
  congr 1
  refine Finset.sum_congr rfl fun a _ => ?_
  ring

/-! ## thm:ch6-crossfit — unidad de partición -/

/-- book: capitulos/cap04_herramientas.typ:2028 (key: thm:ch6-crossfit) —
unidad de partición, pieza 1: si `f` asigna a cada unidad `i` su fold, la
suma de las sumas por fold devuelve la suma total
(`∑_k ∑_{i∈fold k} D_i = ∑_i D_i`). Es la razón por la que promediar
estimadores por fold coincide con el promedio simple, y sólo es válida si
la partición se hace sobre la unidad de muestreo `O_i`.
Fidelidad declarada: se formaliza la identidad combinatoria de la partición
en la unidad; la parte estadística (independencia entre unidades,
`O_i` = paciente/episodio y no visita/transición) se documenta y no se
formaliza. -/
theorem thm_ch6_crossfit_suma {n K : ℕ} (f : Fin n → Fin K) (D : Fin n → ℝ) :
    ∑ k : Fin K, ∑ i ∈ Finset.univ.filter (fun i => f i = k), D i = ∑ i, D i :=
  Finset.sum_fiberwise_of_maps_to (fun x _ => Finset.mem_univ (f x)) D

/-- book: capitulos/cap04_herramientas.typ:2028 (key: thm:ch6-crossfit) —
unidad de partición, pieza 2: con `K` folds de igual tamaño `m` y
`K·m = n` (proporciones positivas), el promedio de los promedios por fold
es el promedio total: `(1/K)·∑_k (1/m)·∑_{i∈fold k} D_i = (1/n)·∑_i D_i`.
Es la identidad que usa el estimador cross-fitted `ψ̂ = (1/K)∑_k ψ̂_k`. -/
theorem thm_ch6_crossfit_media {n K : ℕ} (f : Fin n → Fin K) (m : ℕ) (hm : 0 < m)
    (hK : 0 < K) (hKm : K * m = n) (D : Fin n → ℝ) :
    (1 / (K : ℝ)) * (∑ k : Fin K,
        (1 / (m : ℝ)) * ∑ i ∈ Finset.univ.filter (fun i => f i = k), D i)
      = (1 / (n : ℝ)) * ∑ i, D i := by
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hKR : (0 : ℝ) < K := by exact_mod_cast hK
  have hKR' : ((K : ℝ)) ≠ 0 := ne_of_gt hKR
  have hmR' : ((m : ℝ)) ≠ 0 := ne_of_gt hmR
  have h1 : ∑ k : Fin K, (1 / (m : ℝ)) *
        ∑ i ∈ Finset.univ.filter (fun i => f i = k), D i
      = (1 / (m : ℝ)) * ∑ k : Fin K,
        ∑ i ∈ Finset.univ.filter (fun i => f i = k), D i := by
    rw [Finset.mul_sum]
  rw [h1, thm_ch6_crossfit_suma f D]
  have hn : ((n : ℝ)) = (K : ℝ) * (m : ℝ) := by
    rw [← hKm]
    push_cast
    ring
  rw [hn]
  field_simp
/-! ## prop:ch6-ral — expansión asintóticamente lineal -/

/-- book: capitulos/cap04_herramientas.typ:1892 (key: prop:ch6-ral) —
expansión asintóticamente lineal ⟹normalidad asintótica: si las unidades
son iid (`φ ∘ O_i` independientes e idénticamente distribuidas), `φ` tiene
segundo momento y media cero (`E₀[φ] = 0`, `0 < E₀[φ²]`), y el estimador
satisface la expansión de forma exacta
`ψ̂ − ψ₀ = (1/n)·∑_{i<n} φ(O_i)`, entonces
`√n·(ψ̂ − ψ₀) →d N(0, E₀[φ²])`.

La prueba es el teorema central del límite de Mathlib
(`ProbabilityTheory.tendstoInDistribution_inv_sqrt_mul_sum_sub`) más la
reescritura de escala `√n·(1/n)·S = (1/√n)·S`. La varianza límite es
`Var[φ(O₀)] = E₀[φ²]` porque la media es cero; la versión de Mathlib
cubre también el caso degenerado `E₀[φ²] = 0`.

Fidelidad declarada: se formaliza la expansión *exacta* (resto nulo); el
libro permite un resto `o_P(n^(-1/2))` (caso de `thm:ch6-dml`), que aquí se
declara y no se formaliza. El lado «para un estimador regular, su función
de influencia debe representar las derivadas del objetivo» es una
condición sobre el modelo y no se enuncia. -/
theorem prop_ch6_ral {Ω Ω' : Type*} {mΩ : MeasurableSpace Ω} {mΩ' : MeasurableSpace Ω'}
    {P : Measure Ω} [IsProbabilityMeasure P] {P' : Measure Ω'} [IsProbabilityMeasure P']
    (O : ℕ → Ω → Ω') (φ : Ω' → ℝ) (ψhat : ℕ → Ω → ℝ) (ψ0 : ℝ) (Y : Ω' → ℝ)
    (hmem : MemLp (fun ω => φ (O 0 ω)) 2 P)
    (hindep : iIndepFun (fun i ω => φ (O i ω)) P)
    (hident : ∀ i, IdentDistrib (fun ω => φ (O i ω)) (fun ω => φ (O 0 ω)) P P)
    (hmean : P[fun ω => φ (O 0 ω)] = 0)
    (hY : HasLaw Y (gaussianReal 0 (Var[fun ω => φ (O 0 ω); P]).toNNReal) P')
    (h0 : ∀ ω, ψhat 0 ω = ψ0)
    (hexp : ∀ (n : ℕ), 1 ≤ n → ∀ ω,
      ψhat n ω - ψ0 = (1/(n:ℝ)) * ∑ i ∈ Finset.range n, φ (O i ω)) :
    TendstoInDistribution (fun (n : ℕ) ω => √(n:ℝ) * (ψhat n ω - ψ0)) atTop Y
      (fun _ => P) P' := by
  have hclt := tendstoInDistribution_inv_sqrt_mul_sum_sub
    (X := fun i ω => φ (O i ω)) (P := P) (Y := Y) (P' := P') hY hmem hindep hident
  simp only [hmean, mul_zero, sub_zero] at hclt
  have hpt : ∀ (n : ℕ) (ω : Ω),
      √(n:ℝ) * (ψhat n ω - ψ0) = (√(n:ℝ))⁻¹ * ∑ i ∈ Finset.range n, φ (O i ω) := by
    intro n ω
    rcases Nat.eq_zero_or_pos n with hn0 | hpos
    · subst hn0
      rw [h0 ω]
      simp
    · rw [hexp n hpos ω]
      have hnR : (0:ℝ) < n := by exact_mod_cast hpos
      have hsq : √(n:ℝ) * √(n:ℝ) = (n:ℝ) := Real.mul_self_sqrt (le_of_lt hnR)
      have hne : √(n:ℝ) ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hnR)
      have key : √(n:ℝ) * (1/(n:ℝ)) = (√(n:ℝ))⁻¹ := by
        rw [mul_one_div, inv_eq_one_div, div_eq_div_iff (ne_of_gt hnR) hne]
        rw [hsq]
        ring
      rw [← mul_assoc, key]
  exact hclt.congr (fun n => Filter.EventuallyEq.of_eq (funext fun ω => (hpt n ω).symm))
    (Filter.EventuallyEq.refl (MeasureTheory.ae P') Y)
/-! ## thm:ch6-rubin-dag — ajuste gráfico y resultados potenciales -/

/-- book: capitulos/cap04_herramientas.typ:2055 (key: thm:ch6-rubin-dag) —
ajuste gráfico y resultados potenciales (versión finita): con resultados
potenciales `Y0`, `Y1`, tratamiento `A` y covariables `Z` en un espacio
finito con pesos `p`, si se cumple

* consistencia `Y = if A then Y1 else Y0`,
* intercambiabilidad condicional en medias
  `E[Y_a | A = a, Z = z] = E[Y_a | Z = z]` para `a = 0,1` y todo `z`,
* positividad `P(A = a, Z = z) > 0` en cada celda,

entonces la fórmula de estandarización (criterio backdoor) es exacta:

`∑_z P(Z=z)·(E[Y | A=1, Z=z] − E[Y | A=0, Z=z]) = E[Y1 − Y0]`.

Prueba: por intercambiabilidad, `E[Y_a|Z=z] = E[Y_a|A=a,Z=z]`; por
consistencia, la media condicional de `Y` en la celda tratada coincide con
la de `Y1` (y la de `Y0` en la no tratada); multiplicando por `P(Z=z) > 0`
y sumando en `z` (descomposición por fibras de `Z`) se obtiene
`E[Y1] − E[Y0]`.
Fidelidad declarada: espacios finitos y ley discreta; las medias
condicionales se escriben como cocientes de sumas (las positividades
`hpos1`, `hpos0` son parte del modelo y no intervienen en el álgebra, que
sólo necesita `P(Z=z) > 0`). No se afirma el recíproco (una independencia
distribucional particular no implica el criterio gráfico) ni se formaliza
el DAG: el criterio se toma como la hipótesis de intercambiabilidad
condicional, tal como el libro lo usa. -/
theorem thm_ch6_rubin_dag {Ω ι : Type u6} [Fintype Ω] [Fintype ι] [DecidableEq ι]
    (p : Ω → ℝ) (Z : Ω → ι) (A : Ω → Bool) (Y Y0 Y1 : Ω → ℝ)
    (hcons : ∀ ω, Y ω = if A ω then Y1 ω else Y0 ω)
    (hposz : ∀ z, 0 < ∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω)
    (hpos1 : ∀ z, 0 < ∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω)
    (hpos0 : ∀ z, 0 < ∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω)
    (hexp1 : ∀ z,
      (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω * Y1 ω)
        / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω)
      = (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y1 ω)
        / (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω))
    (hexp0 : ∀ z,
      (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω * Y0 ω)
        / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω)
      = (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y0 ω)
        / (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω)) :
    ∑ z, (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω) *
        ((∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω * Y ω)
            / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω)
          - (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω * Y ω)
            / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω))
      = ∑ ω, p ω * (Y1 ω - Y0 ω) := by
  classical
  have hcell1 : ∀ z,
      (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω * Y ω)
        = (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω * Y1 ω) := by
    intro z
    refine Finset.sum_congr rfl fun ω hω => ?_
    rw [Finset.mem_filter] at hω
    have hA : A ω = true := hω.2.1
    rw [hcons ω, hA]
    simp
  have hcell0 : ∀ z,
      (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω * Y ω)
        = (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω * Y0 ω) := by
    intro z
    refine Finset.sum_congr rfl fun ω hω => ?_
    rw [Finset.mem_filter] at hω
    have hA : A ω = false := hω.2.1
    rw [hcons ω, hA]
    simp
  have hz : ∀ z,
      (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω) *
        ((∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω * Y ω)
            / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = true ∧ Z ω = z), p ω)
          - (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω * Y ω)
            / (∑ ω ∈ Finset.univ.filter (fun ω => A ω = false ∧ Z ω = z), p ω))
      = (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y1 ω)
        - (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y0 ω) := by
    intro z
    rw [hcell1 z, hcell0 z, hexp1 z, hexp0 z]
    have hWz : (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω) ≠ 0 := ne_of_gt (hposz z)
    field_simp
  rw [Finset.sum_congr rfl fun z _ => hz z, Finset.sum_sub_distrib]
  have hf1 : ∑ z, (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y1 ω)
      = ∑ ω, p ω * Y1 ω :=
    Finset.sum_fiberwise_of_maps_to (fun x _ => Finset.mem_univ (Z x)) _
  have hf0 : ∑ z, (∑ ω ∈ Finset.univ.filter (fun ω => Z ω = z), p ω * Y0 ω)
      = ∑ ω, p ω * Y0 ω :=
    Finset.sum_fiberwise_of_maps_to (fun x _ => Finset.mem_univ (Z x)) _
  rw [hf1, hf0, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun ω _ => by ring

/-! ## Auditoría de axiomas (convención del plan §6) -/

#print axioms thm_ch6_dr
#print axioms thm_ch6_dr_propension
#print axioms thm_ch6_dr_modelos
#print axioms thm_ch6_cota
#print axioms thm_ch6_cota_le
#print axioms thm_ch6_cota_igualdad
#print axioms thm_ch6_cota_expect
#print axioms thm_ch6_cota_expect_le
#print axioms cor_ch6_varianza_minima
#print axioms cor_ch6_varianza_minima_cota
#print axioms prop_ch6_descomposicion
#print axioms prop_ch6_descomposicion_isCompl
#print axioms thm_ch6_neyman
#print axioms thm_ch6_neyman_cota
#print axioms thm_ch6_neyman_escala
#print axioms thm_ch6_kallus_residual
#print axioms thm_ch6_kallus_pesos
#print axioms thm_ch6_kallus_inicial
#print axioms cor_ch6_dr_ope_modelos
#print axioms cor_ch6_dr_ope_pesos
#print axioms thm_ch6_crossfit_suma
#print axioms thm_ch6_crossfit_media
#print axioms prop_ch6_ral
#print axioms thm_ch6_rubin_dag
