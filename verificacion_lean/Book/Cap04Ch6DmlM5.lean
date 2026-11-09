import Mathlib

/-!
# Book.Cap04Ch6DmlM5 — `thm:ch6-dml`: AIPW con cross-fitting

Cierra la clave pendiente `thm:ch6-dml` (`capitulos/cap04_herramientas.typ:2012`,
«Un caso suficiente para AIPW con cross-fitting»).

Contenido, en el orden del libro:

1. **Ortogonalidad poblacional** (`ch6_dml_identidad`): la identidad exacta
   `E_p[D(·;η̂)] − E_p[m₁ − m₀] = ∑_x p(x)(ê(x) − e(x))((m̄₁ − m₁)/ê + (m̄₀ − m₀)/(1 − ê))`:
   el sesgo de primer orden se anula si *alguna* de las dos funciones auxiliares
   es correcta (`ch6_dml_doble_robustez`), y en general queda como **producto**
   de los errores de propensión y de resultado.
2. **Resto `o_P(n^{-1/2})`** (`ch6_dml_resto_pequeno`): si el sesgo poblacional
   está acotado por `C·ε_e·(ε_{m₁}+ε_{m₀})` y el producto de errores es
   `o(n^{-1/2})`, entonces `√n · sesgo → 0`.
3. **Conclusión asintótica** (`ch6_dml_clt`): si además
   `ψ̂ₙ − ψ₀ = n^{-1}∑_{i<n} φ_eff(O_i) + bₙ` con `√n·bₙ →P 0` (el resto que
   deja el cross-fitting), entonces
   `√n(ψ̂ₙ − ψ₀) →d N(0, σ²_eff)` con `σ²_eff = Var[φ_eff(O_0)]`, por el CLT de
   Mathlib (`tendstoInDistribution_inv_sqrt_mul_sum_sub`) y Slutsky
   (`TendstoInDistribution.add_of_tendstoInMeasure_const`).

**Fidelidad declarada.** Se formaliza la parte *poblacional y algebraica* del
caso suficiente (identidad de ortogonalidad, doble robustez, producto de
errores) en un espacio de covariables finito con pesos `p`, y la *conclusión
asintótica* a partir de la expansión con resto `o_P(n^{-1/2})`. Lo que **no** se
formaliza: (i) la construcción misma del cross-fitting (partición en `K` folds
y el argumento empírico que produce la expansión), que se toma como la
hipótesis de expansión; (ii) la consistencia de la varianza empírica de los
pseudoresultados (requiere LGN, no incluida); (iii) el paso `O_P`/`o_P`
probabilístico de las tasas de los ajustes, que aquí entra como la hipótesis
`√n·bₙ →P 0`. El libro mismo declara estas hipótesis como *suficientes, no
necesarias*. Véase `README.md`.
-/

set_option linter.unusedVariables false
set_option maxHeartbeats 2000000

open Finset BigOperators MeasureTheory ProbabilityTheory Filter
open scoped ENNReal Topology

namespace Cap04Ch6M5

/-! ## 1. Ortogonalidad poblacional del AIPW -/

/-- Esperanza poblacional del pseudoresultado AIPW, integrando `A | X = x` con
la propensión verdadera `e`:
`E_p[D] = ∑_x p(x)[m̄₁ − m̄₀ + (e/ê)(m₁ − m̄₁) − ((1−e)/(1−ê))(m₀ − m̄₀)]`. -/
noncomputable def aipwMean {ι : Type*} [Fintype ι] (p e ehat m1 m0 m1h m0h : ι → ℝ) : ℝ :=
  ∑ x, p x * (m1h x - m0h x + (e x / ehat x) * (m1 x - m1h x)
    - ((1 - e x) / (1 - ehat x)) * (m0 x - m0h x))

/-- Funcional objetivo `ψ₀ = E_p[m₁ − m₀]`. -/
noncomputable def ate {ι : Type*} [Fintype ι] (p m1 m0 : ι → ℝ) : ℝ :=
  ∑ x, p x * (m1 x - m0 x)

/-- Sesgo poblacional del AIPW escrito como producto de errores:
`∑_x p(x)(ê − e)((m̄₁ − m₁)/ê + (m̄₀ − m₀)/(1 − ê))`. -/
noncomputable def aipwBias {ι : Type*} [Fintype ι] (p e ehat m1 m0 m1h m0h : ι → ℝ) : ℝ :=
  ∑ x, p x * ((ehat x - e x) * ((m1h x - m1 x) / ehat x + (m0h x - m0 x) / (1 - ehat x)))

/-- book: capitulos/cap04_herramientas.typ:2012 (key: thm:ch6-dml) —
**identidad de ortogonalidad del AIPW** (versión poblacional finita):
`E_p[D(·;η̂)] − ψ₀ = ∑_x p(x)(ê(x) − e(x))((m̄₁ − m₁)/ê + (m̄₀ − m₀)/(1 − ê))`.

Fidelidad declarada: espacio de covariables `ι` finito, propensión verdadera
`e`, funciones candidatas `ê, m̄₁, m̄₀` y medias condicionales verdaderas
`m₁, m₀`; la esperanza sobre `A | X = x` se calcula con la ley de `A` dada `X`
(por eso aparecen `e/ê` y `(1−e)/(1−ê)`). Los denominadores se suponen no
nulos (`ê(x) ∉ {0,1}`). No se afirma insesgadez finita cuando los ajustes se
reutilizan en la misma muestra: es exactamente la identidad que el
cross-fitting necesita para separar las funciones del promedio. -/
theorem ch6_dml_identidad {ι : Type*} [Fintype ι] (p e ehat m1 m0 m1h m0h : ι → ℝ)
    (hne : ∀ x, ehat x ≠ 0) (hne' : ∀ x, 1 - ehat x ≠ 0) :
    aipwMean p e ehat m1 m0 m1h m0h - ate p m1 m0
      = aipwBias p e ehat m1 m0 m1h m0h := by
  rw [aipwMean, ate, aipwBias, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  have h1 := hne x
  have h2 := hne' x
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:2012 (key: thm:ch6-dml) —
**doble robustez del AIPW**: si la propensión ajustada es correcta (`ê = e`) o
si los ajustes de resultado son correctos (`m̄₁ = m₁` y `m̄₀ = m₀`), el sesgo
poblacional es exactamente cero. Es la consecuencia inmediata de que el sesgo
es un producto de errores. -/
theorem ch6_dml_doble_robustez {ι : Type*} [Fintype ι] (p e ehat m1 m0 m1h m0h : ι → ℝ)
    (hne : ∀ x, ehat x ≠ 0) (hne' : ∀ x, 1 - ehat x ≠ 0)
    (hc : (∀ x, ehat x = e x) ∨ (∀ x, m1h x = m1 x ∧ m0h x = m0 x)) :
    aipwMean p e ehat m1 m0 m1h m0h = ate p m1 m0 := by
  have h := ch6_dml_identidad p e ehat m1 m0 m1h m0h hne hne'
  have hb : aipwBias p e ehat m1 m0 m1h m0h = 0 := by
    rcases hc with hc | hc
    · refine Finset.sum_eq_zero fun x _ => ?_
      rw [hc x]; ring
    · refine Finset.sum_eq_zero fun x _ => ?_
      obtain ⟨h1, h0⟩ := hc x
      rw [h1, h0]; ring
  rw [hb] at h
  exact sub_eq_zero.mp h

/-! ## 2. El resto es `o_P(n^{-1/2})` cuando el producto de errores lo es -/

/-- book: capitulos/cap04_herramientas.typ:2012 (key: thm:ch6-dml) —
**el producto de errores pequeño hace pequeño el resto**: si el sesgo
poblacional de cada `n` está acotado por `C` veces el producto de errores
`ε_e·(ε_{m₁}+ε_{m₀})` (lo que da Cauchy–Schwarz bajo `ê ∈ [c,1−c]` y
`|Y| ≤ C`, véase el docstring de `ch6_dml_clt`) y ese producto es
`o(n^{-1/2})`, entonces `√n·sesgo → 0`: el resto no desplaza la escala `√n`.

Fidelidad declarada: versión determinista (envolventes). Es el paso que en el
libro se enuncia como `‖ê−e‖₂(‖m̄₁−m₁‖₂+‖m̄₀−m₀‖₂) = o_P(n^{-1/2})`; aquí el
`o_P` se sustituye por su lectura determinista (sobre el evento de probabilidad
`1−ε`), y la cota por el producto de normas `L²` es la desigualdad de
Cauchy–Schwarz aplicada a la identidad de ortogonalidad. -/
theorem ch6_dml_resto_pequeno (C : ℝ) (sesgo epsE eps1 eps0 : ℕ → ℝ)
    (hC : 0 ≤ C)
    (hsesgo : ∀ n, |sesgo n| ≤ C * (epsE n * (eps1 n + eps0 n)))
    (hprod : Tendsto (fun n : ℕ => (n : ℝ) ^ ((1 : ℝ) / 2) * (epsE n * (eps1 n + eps0 n)))
      atTop (𝓝 0)) :
    Tendsto (fun n : ℕ => (n : ℝ) ^ ((1 : ℝ) / 2) * sesgo n) atTop (𝓝 0) := by
  have hle : ∀ᶠ n : ℕ in atTop,
      ‖(n : ℝ) ^ ((1 : ℝ) / 2) * sesgo n‖
        ≤ C * ((n : ℝ) ^ ((1 : ℝ) / 2) * (epsE n * (eps1 n + eps0 n))) := by
    filter_upwards with n
    rw [Real.norm_eq_abs, abs_mul,
      abs_of_nonneg (Real.rpow_nonneg (Nat.cast_nonneg n) _)]
    calc (n : ℝ) ^ ((1 : ℝ) / 2) * |sesgo n|
        ≤ (n : ℝ) ^ ((1 : ℝ) / 2) * (C * (epsE n * (eps1 n + eps0 n))) :=
          mul_le_mul_of_nonneg_left (hsesgo n) (Real.rpow_nonneg (Nat.cast_nonneg n) _)
      _ = C * ((n : ℝ) ^ ((1 : ℝ) / 2) * (epsE n * (eps1 n + eps0 n))) := by ring
  have hlim : Tendsto (fun n : ℕ =>
      C * ((n : ℝ) ^ ((1 : ℝ) / 2) * (epsE n * (eps1 n + eps0 n)))) atTop (𝓝 0) := by
    have h := hprod.const_mul C
    simpa [mul_comm, mul_left_comm, mul_assoc] using h
  exact squeeze_zero_norm' hle hlim

/-! ## 3. Conclusión asintótica: expansión con resto + CLT ⟹ normalidad -/

/-- book: capitulos/cap04_herramientas.typ:2012 (key: thm:ch6-dml) —
**conclusión de `thm:ch6-dml`**: si las unidades son iid (`φ_eff ∘ O_i`
independientes e idénticamente distribuidas, `E₀[φ_eff] = 0`, segundo momento
finito) y el estimador tiene la expansión
`ψ̂ₙ − ψ₀ = n^{-1}∑_{i<n} φ_eff(O_i) + bₙ` con **resto `√n·bₙ →P 0`** (lo que
produce el cross-fitting a partir del producto de errores del apartado 2),
entonces
`√n(ψ̂ₙ − ψ₀) →d N(0, σ²_eff)`, `σ²_eff = Var[φ_eff(O₀)]`.

Prueba: el término principal es `(1/√n)∑_{i<n} φ_eff(O_i)`, que converge a
`N(0, σ²_eff)` por el CLT de Mathlib; el resto se suma con Slutsky
(`TendstoInDistribution.add_of_tendstoInMeasure_const`).

Fidelidad declarada: la expansión con resto `o_P(n^{-1/2})` es **hipótesis**,
no se deriva aquí del cross-fitting (apartado 2 da el lado poblacional); la
consistencia de la varianza empírica y el caso `E₀[φ²] = 0` no se enuncian;
`ψ̂₀` es arbitrario. -/
theorem ch6_dml_clt {Ω Ω' : Type*} {mΩ : MeasurableSpace Ω} {mΩ' : MeasurableSpace Ω'}
    {P : Measure Ω} [IsProbabilityMeasure P] {P' : Measure Ω'} [IsProbabilityMeasure P']
    (O : ℕ → Ω → Ω') (φ : Ω' → ℝ) (ψhat bew : ℕ → Ω → ℝ) (ψ0 : ℝ) (Y : Ω' → ℝ)
    (hmem : MemLp (fun ω => φ (O 0 ω)) 2 P)
    (hindep : iIndepFun (fun i ω => φ (O i ω)) P)
    (hident : ∀ i, IdentDistrib (fun ω => φ (O i ω)) (fun ω => φ (O 0 ω)) P P)
    (hmean : P[fun ω => φ (O 0 ω)] = 0)
    (hY : HasLaw Y (gaussianReal 0 (Var[fun ω => φ (O 0 ω); P]).toNNReal) P')
    (hexp : ∀ (n : ℕ), 1 ≤ n → ∀ ω,
      (n : ℝ) ^ ((1 : ℝ) / 2) * (ψhat n ω - ψ0)
        = ((n : ℝ) ^ ((1 : ℝ) / 2))⁻¹ * ∑ i ∈ Finset.range n, φ (O i ω)
          + (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω)
    (hbew : ∀ n, AEMeasurable (bew n) P)
    (hrem : TendstoInMeasure P (fun (n : ℕ) ω => (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω) atTop 0) :
    TendstoInDistribution (fun (n : ℕ) ω => (n : ℝ) ^ ((1 : ℝ) / 2) * (ψhat n ω - ψ0))
      atTop Y (fun _ => P) P' := by
  -- término principal: `Xₙ = (1/√n) ∑_{i<n} φ(Oᵢ)`
  set X : ℕ → Ω → ℝ := fun n ω =>
    (√(n : ℝ))⁻¹ * ∑ i ∈ Finset.range n, φ (O i ω) with hX
  have hclt : TendstoInDistribution X atTop Y (fun _ => P) P' := by
    have hbase := tendstoInDistribution_inv_sqrt_mul_sum_sub
      (X := fun i ω => φ (O i ω)) (P := P) (Y := Y) (P' := P') hY hmem hindep hident
    simp only [hmean, mul_zero, sub_zero] at hbase
    exact hbase
  have hYmeas : ∀ n : ℕ, AEMeasurable (fun ω => (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω) P :=
    fun n => (hbew n).const_mul _
  have hsum := hclt.add_of_tendstoInMeasure_const
    (Y := fun (n : ℕ) ω => (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω) (c := 0) hrem hYmeas
  have hfun : (fun (n : ℕ) ω => X n ω + (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω)
      = (fun (n : ℕ) ω => (n : ℝ) ^ ((1 : ℝ) / 2) * (ψhat n ω - ψ0)) := by
    funext n ω
    rcases Nat.eq_zero_or_pos n with hn0 | hpos
    · subst hn0
      simp [hX]
    · have hs : √(n : ℝ) = (n : ℝ) ^ ((1 : ℝ) / 2) := Real.sqrt_eq_rpow (n : ℝ)
      simp only [hX, hs]
      exact (hexp n hpos ω).symm
  have hsum' : TendstoInDistribution (fun n ω => X n ω + (n : ℝ) ^ ((1 : ℝ) / 2) * bew n ω)
      atTop (fun ω => Y ω + 0) (fun _ => P) P' := hsum
  have hY' : (fun ω => Y ω + 0) = Y := by funext ω; ring
  rw [hfun, hY'] at hsum'
  exact hsum'

/-! ## Auditoría de axiomas -/

#print axioms ch6_dml_identidad
#print axioms ch6_dml_doble_robustez
#print axioms ch6_dml_resto_pequeno
#print axioms ch6_dml_clt

end Cap04Ch6M5
