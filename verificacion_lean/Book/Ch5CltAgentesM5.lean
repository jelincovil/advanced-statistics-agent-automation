import Mathlib

/-!
# Book.Ch5CltAgentesM5 — clave `thm:ch5-clt-agentes` (CLT para una contribución estacionaria)

El libro (`cap06_fallos.typ:324`) enuncia, bajo la condición de mixing
`def:ch5-mixing-clt` (momentos `E|X_0|^{2+δ} < ∞`, coeficientes `α(k)` con
`∑ α(k)^{δ/(2+δ)} < ∞`):

> con `μ = E[X_0]`, `√T(X̄_T − μ) →d N(0, σ²_LR)`, donde
> `σ²_LR = Var(X_0) + 2∑_{k≥1} Cov(X_0,X_k)`; **la serie de covarianzas es
> absolutamente convergente**; si además `σ²_LR > 0` y `σ̂²_LR →P σ²_LR`,
> un intervalo asintótico es `X̄_T ± z_{1−α/2} σ̂_LR/√T`. La varianza de la
> media es aproximadamente `σ²_LR/T`; no se reemplaza una varianza de la
> media por una varianza sin dividir por el tamaño de la trayectoria.

Con la convención de fidelidad del proyecto se formalizan las piezas que
**no** son el límite distribucional (que el libro mismo declara externo y
remite a las notas de Shalizi sobre mixing, teorema 355):

* `lrVariance`: la varianza de largo plazo `σ²_LR` del libro;
* `lr_covarianzas_sumables`: la convergencia absoluta de la serie de
  covarianzas (que es una consecuencia de la condición de mixing, aquí
  hipótesis explícita);
* `lr_varianza_finita`: la fórmula finita exacta que usa `ex:ch5-cadena`,
  `Var(∑_{t<T} X_t) = ∑_{i,j<T} γ_{|i−j|}`;
* `lr_varianza_media`: `Var(X̄_T) = Var(∑_{t<T}X_t)/T²`, es decir la
  varianza de la media dividida por el tamaño de la trayectoria (la
  advertencia del libro);
* `lr_semiancho`: el semiancho `z·σ̂/√T` del intervalo tiende a `0` cuando
  `σ̂` está acotado, así que el intervalo se estrecha a la tasa `1/√T`;
* `lr_cadena2*`: el valor `σ²_LR = 72` del ejemplo de la cadena de 2
  estados del libro (`γ_k = 24·(1/2)^k`), calculado con la definición.

No se reproduce el límite distribucional `√T(X̄_T − μ) →d N(0,σ²_LR)`
(es el CLT de Ibragimov, externo al libro), ni el paso de la serie de
covarianzas a `τ²` como límite de `T·Var(X̄_T)` (requiere el lema de
Kronecker y la identidad de conteo del covariograma).
-/

open Finset BigOperators
open Filter
open scoped Topology

set_option maxHeartbeats 2000000
set_option linter.unusedVariables false

namespace BookCh5CltAgentesM5

/-! ## 0. Capa de probabilidad finita (misma convención que `Book/Cap05Asintotica.lean`) -/

variable {Ω : Type*} [Fintype Ω]

/-- Esperanza bajo los pesos `p` sobre `Ω` finito: `E_p[Y] = ∑_ω p(ω)·Y(ω)`. -/
noncomputable def fexp (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := ∑ ω, p ω * Y ω

/-- Varianza bajo los pesos `p`. -/
noncomputable def fvar (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := fexp p fun ω => (Y ω - fexp p Y) ^ 2

/-- Covarianza bajo los pesos `p`. -/
noncomputable def fcov (p : Ω → ℝ) (X Y : Ω → ℝ) : ℝ :=
  fexp p fun ω => (X ω - fexp p X) * (Y ω - fexp p Y)

/-- Los pesos `p` son una distribución de probabilidad. -/
def IsProb (p : Ω → ℝ) : Prop := (∀ ω, 0 ≤ p ω) ∧ ∑ ω, p ω = 1

theorem fexp_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fexp p (fun ω => c * Y ω) = c * fexp p Y := by
  rw [fexp, fexp, Finset.mul_sum]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem fvar_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fvar p (fun ω => c * Y ω) = c ^ 2 * fvar p Y := by
  have hm : fexp p (fun ω => c * Y ω) = c * fexp p Y := fexp_const_mul p c Y
  simp only [fvar, hm]
  have hfun : (fun ω => (c * Y ω - c * fexp p Y) ^ 2)
      = fun ω => c ^ 2 * (Y ω - fexp p Y) ^ 2 := by
    funext ω; ring
  rw [hfun, fexp_const_mul]

/-- La varianza de una suma es la suma de las covarianzas de los sumandos
(identidad de Koopman, versión finita). -/
theorem fexp_sum {ι : Type*} [Fintype ι] (p : Ω → ℝ) (X : ι → Ω → ℝ) :
    fexp p (fun ω => ∑ i, X i ω) = ∑ i, fexp p (X i) := by
  simp only [fexp]
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem fvar_sum {ι : Type*} [Fintype ι] (p : Ω → ℝ) (X : ι → Ω → ℝ) :
    fvar p (fun ω => ∑ i, X i ω) = ∑ i, ∑ j, fcov p (X i) (X j) := by
  have hm : fexp p (fun ω => ∑ i, X i ω) = ∑ i, fexp p (X i) := fexp_sum p X
  rw [fvar, hm]
  have hfun : (fun ω => (∑ i, X i ω - ∑ i, fexp p (X i)) ^ 2)
      = fun ω => ∑ i, ∑ j, (X i ω - fexp p (X i)) * (X j ω - fexp p (X j)) := by
    funext ω
    rw [← Finset.sum_sub_distrib, sq, Finset.sum_mul_sum]
  rw [hfun, fexp_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [fexp_sum]
  rfl

/-! ## 1. La varianza de largo plazo `σ²_LR` y la convergencia absoluta -/

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**Varianza de largo plazo** `σ²_LR = γ_0 + 2∑_{k≥1} γ_k`, con
`γ_k = Cov(X_0, X_k)`. Es la constante de la ley límite del CLT para una
contribución estacionaria del libro. -/
noncomputable def lrVariance (γ : ℕ → ℝ) : ℝ := γ 0 + 2 * ∑' k : ℕ, γ (k + 1)

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**La serie de covarianzas es absolutamente convergente.** Si
`∑_{k} |γ_k| < ∞` (que es lo que la condición de mixing
`def:ch5-mixing-clt` da, por la desigualdad de Ibragimov), entonces la serie
desplazada `∑_{k≥1} γ_k` converge absolutamente y converge.

Fidelidad declarada: se formaliza la afirmación estructural que el libro
enuncia como parte de la proposición (convergencia absoluta de la serie de
covarianzas), tomando la sumabilidad de `∑|γ_k|` como hipótesis explícita —
que es exactamente lo que el mixing `α(k)^{δ/(2+δ)}` sumable + momentos
`2+δ` implican (teorema de Ibragimov, `thm:appD-ibragimov`). -/
theorem lr_covarianzas_sumables {γ : ℕ → ℝ} (h : Summable fun k => |γ k|) :
    Summable (fun k : ℕ => |γ (k + 1)|) ∧ Summable (fun k : ℕ => γ (k + 1)) := by
  have h1 : Summable (fun k : ℕ => |γ (k + 1)|) :=
    (summable_nat_add_iff (f := fun j => |γ j|) 1).mpr h
  have h2 : Summable (fun k : ℕ => ‖γ (k + 1)‖) := by
    simpa [Real.norm_eq_abs] using h1
  exact ⟨h1, h2.of_norm⟩

/-- La varianza de largo plazo es la constante `γ_0 + 2∑_{k≥1}γ_k` con la
serie de covarianzas absolutamente convergente: `σ²_LR` está bien definida. -/
theorem lrVariance_bien_definida {γ : ℕ → ℝ} (h : Summable fun k => |γ k|) :
    lrVariance γ = γ 0 + 2 * ∑' k : ℕ, γ (k + 1) := rfl

/-! ## 2. La identidad finita exacta y la varianza de la media -/

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**Fórmula finita exacta** (la que el libro usa en `ex:ch5-cadena`): bajo
estacionariedad, la covarianza sólo depende de la distancia,
`Cov(X_i,X_j) = γ_{|i−j|}`, y por tanto
`Var(∑_{t<T} X_t) = ∑_{i<T}∑_{j<T} γ_{|i−j|}`.

Fidelidad declarada: versión discreta finita declarada del libro, con la
estacionariedad en la forma `Cov(X_i,X_j) = γ_{|i−j|}` (que es su
definición de estacionariedad estricta más covarianzas de orden 2 finitas). -/
theorem lr_varianza_finita {T : ℕ} (p : Ω → ℝ) (Z : ℕ → Ω → ℝ) (γ : ℕ → ℝ)
    (hcov : ∀ i j : Fin T,
      fcov p (Z (i : ℕ)) (Z (j : ℕ))
        = γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ))) :
    fvar p (fun ω => ∑ i : Fin T, Z (i : ℕ) ω)
      = ∑ i : Fin T, ∑ j : Fin T,
          γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ)) := by
  rw [fvar_sum]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => hcov i j

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) —
**`Var(X̄_T) = Var(∑_{t<T}X_t)/T²`**: la varianza de la media lleva la
división por el tamaño de la trayectoria. Es la advertencia explícita del
libro («no se reemplaza una varianza de la media por una varianza sin
dividir por el tamaño de la trayectoria»): la varianza de la media es del
orden de `σ²_LR/T`, no de `σ²_LR`. -/
theorem lr_varianza_media {T : ℕ} (hT : (T : ℝ) ≠ 0) (p : Ω → ℝ) (Z : ℕ → Ω → ℝ)
    (γ : ℕ → ℝ)
    (hcov : ∀ i j : Fin T,
      fcov p (Z (i : ℕ)) (Z (j : ℕ))
        = γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ))) :
    fvar p (fun ω => (T : ℝ)⁻¹ * ∑ i : Fin T, Z (i : ℕ) ω)
      = (∑ i : Fin T, ∑ j : Fin T,
          γ (if (i : ℕ) ≤ (j : ℕ) then (j : ℕ) - (i : ℕ) else (i : ℕ) - (j : ℕ)))
        / (T : ℝ) ^ 2 := by
  rw [fvar_const_mul, lr_varianza_finita p Z γ hcov]
  field_simp

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) — el
semiancho del intervalo asintótico `z_{1−α/2}·σ̂_LR/√T` tiende a `0` a la
tasa `1/√T` cuando `σ̂` está acotado (que es el caso si
`σ̂²_LR →P σ²_LR > 0`: la consistencia da acotación en probabilidad). -/
theorem lr_semiancho {σhat : ℕ → ℝ} {z C : ℝ} (hC : 0 ≤ C) (hσ : ∀ T, |σhat T| ≤ C) :
    Tendsto (fun T : ℕ => z * σhat T / Real.sqrt T) atTop (𝓝 0) := by
  have hsqrt : Tendsto (fun T : ℕ => Real.sqrt (T : ℝ)) atTop atTop :=
    Real.tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
  have hinv : Tendsto (fun T : ℕ => (Real.sqrt (T : ℝ))⁻¹) atTop (𝓝 0) :=
    tendsto_inv_atTop_zero.comp hsqrt
  have hmaj : Tendsto (fun T : ℕ => |z| * C * (Real.sqrt (T : ℝ))⁻¹) atTop (𝓝 0) := by
    simpa using hinv.const_mul (|z| * C)
  rw [tendsto_zero_iff_norm_tendsto_zero]
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hmaj
    (Eventually.of_forall fun T => norm_nonneg _) (Eventually.of_forall fun T => ?_)
  rw [Real.norm_eq_abs, abs_div, abs_mul, abs_of_nonneg (Real.sqrt_nonneg _), div_eq_mul_inv]
  exact mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left (hσ T) (abs_nonneg z)) (by positivity)

/-! ## 3. El ejemplo de la cadena de 2 estados: `σ²_LR = 72` -/

/-- Suma geométrica de razón `1/2`. -/
theorem sum_geometric_half : ∑' k : ℕ, (1/2 : ℝ) ^ k = 2 := by
  rw [tsum_geometric_of_norm_lt_one (by norm_num)]
  norm_num

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) — para
un covariograma geométrico `γ_k = v·ρ^k` con `ρ = 1/2`,
`σ²_LR = γ_0 + 2∑_{k≥1}γ_k = v + 2v·(1/2)·∑_k (1/2)^k = v + 2v = 3v`. -/
theorem lr_geometrico (v : ℝ) :
    lrVariance (fun k : ℕ => v * (1/2 : ℝ) ^ k) = 3 * v := by
  have hshift : ∑' k : ℕ, (1/2 : ℝ) ^ (k + 1) = 1 := by
    rw [show (fun k : ℕ => (1/2 : ℝ) ^ (k + 1)) = fun k : ℕ => (1/2 : ℝ) ^ k * (1/2) by
      funext k; rw [pow_succ]]
    rw [tsum_mul_right, sum_geometric_half]
    norm_num
  have h1 : ∑' k : ℕ, v * (1/2 : ℝ) ^ (k + 1) = v := by
    rw [tsum_mul_left, hshift, mul_one]
  rw [lrVariance]
  show v * (1/2 : ℝ) ^ 0 + 2 * ∑' k : ℕ, v * (1/2 : ℝ) ^ (k + 1) = 3 * v
  rw [h1]
  ring

/-- book: capitulos/cap06_fallos.typ:324 (key: thm:ch5-clt-agentes) — el
ejemplo de la cadena de 2 estados del libro (`ex:ch5-cadena`): con
`Var(X_0) = 24` y `Cov(X_0,X_k) = 24·(1/2)^k`, la varianza de largo plazo es
`σ²_LR = 24 + 2·24 = 72`, que es el valor que el libro reporta. -/
theorem lr_cadena2_libro : lrVariance (fun k : ℕ => 24 * (1/2 : ℝ) ^ k) = 72 := by
  rw [lr_geometrico]
  norm_num

end BookCh5CltAgentesM5
