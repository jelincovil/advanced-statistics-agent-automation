/-
Copyright: proyecto des504 — enjambre smwi7ezya, miembro m3 (dirección d5).

# La identificación `σ² = γ(0) + 2∑_{k≥1} γ(k)` en el modelo exactamente soluble

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

`Book/GordinCoreM8.lean` deja como deuda la identificación del parámetro
`σ² = π(v)` (varianza del incremento de martingala) con la serie de
covarianzas `γ(0) + 2∑_{k≥1} γ(k)`, y `GordinPeriodico` (enjambre anterior,
m1) muestra que **no** se sigue de `Chain` sin aperiodicidad.

Aquí se cierra esa identificación en una clase no trivial y exactamente
soluble: aquélla en que el observable centrado `f` es **autofunción** de `P`
con autovalor `λ`, `|λ| < 1`. No hace falta ninguna cota de Doeblin general:
la serie de covarianzas es geométrica y la ecuación de Poisson se resuelve a
mano, `h = f/(1-λ)`. La identificación resulta ser una identidad algebraica
exacta `σ² = ((1+λ)/(1-λ))·π(f²)`, sin término de error.

En `GordinEigenTwoState.lean` se instancia en la cadena de dos estados con
`P = [[p,1-p],[1-p,p]]`, `p ∈ (0,1)` (primitiva), donde `λ = 2p-1` y
`σ² = p/(1-p)`.
-/
import Book.GordinCoreM8

open ApendiceDGordinM8 Filter
open scoped BigOperators Topology

set_option linter.unusedSectionVars false

namespace GordinEigenM3

variable {S : Type*} [Fintype S] [DecidableEq S]

namespace Chain

variable (D : Chain S)

/-! ## 1. Las potencias del operador de transición -/

/-- `P^t` como operador lineal sobre funciones: `P^{t+1} = P ∘ P^t`. -/
noncomputable def Ppow (D : Chain S) : ℕ → ((S → ℝ) →ₗ[ℝ] (S → ℝ))
  | 0 => LinearMap.id
  | n + 1 => D.applyP.comp (Ppow D n)

@[simp] lemma Ppow_zero_apply (g : S → ℝ) : Ppow D 0 g = g := rfl

lemma Ppow_succ_apply (t : ℕ) (g : S → ℝ) :
    Ppow D (t + 1) g = D.applyP (Ppow D t g) := rfl

/-- `P` conmuta con el producto por una constante. -/
lemma applyP_const_mul (c : ℝ) (g : S → ℝ) :
    D.applyP (fun y => c * g y) = fun x => c * D.applyP g x := by
  funext x
  simp only [Chain.applyP_apply, Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

/-- `π` conmuta con el producto por una constante. -/
lemma avg_const_mul (c : ℝ) (g : S → ℝ) :
    D.avg (fun y => c * g y) = c * D.avg g := by
  simp only [Chain.avg_apply, Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

/-- **Una autofunción de `P` lo es de todas las potencias**: `P^t f = λ^t · f`. -/
lemma Ppow_eigen {f : S → ℝ} {lam : ℝ} (heig : ∀ x, D.applyP f x = lam * f x) :
    ∀ (t : ℕ) (x : S), Ppow D t f x = lam ^ t * f x := by
  intro t
  induction t with
  | zero => intro x; simp
  | succ n ih =>
    intro x
    rw [Ppow_succ_apply D]
    have h1 : Ppow D n f = fun y => lam ^ n * f y := funext ih
    rw [h1, applyP_const_mul D]
    show lam ^ n * D.applyP f x = lam ^ (n + 1) * f x
    rw [heig x]
    ring

/-! ## 2. El covariograma `γ(t) = ⟨f, P^t f⟩_π` -/

/-- Producto escalar estacionario `⟨u,v⟩_π = ∑_x π_x u(x) v(x)`. -/
noncomputable def inner (D : Chain S) (u v : S → ℝ) : ℝ := D.avg (fun x => u x * v x)

/-- El covariograma del observable `f`: `γ(t) = ⟨f, P^t f⟩_π`. -/
noncomputable def gamma (D : Chain S) (f : S → ℝ) (t : ℕ) : ℝ := inner D f (Ppow D t f)

lemma gamma_zero (f : S → ℝ) : gamma D f 0 = D.avg (fun x => (f x) ^ 2) := by
  simp [gamma, inner, pow_two]

/-- `π` saca escalares del segundo factor. -/
lemma avg_mul_smul_right (u v : S → ℝ) (c : ℝ) :
    D.avg (fun x => u x * (c * v x)) = c * D.avg (fun x => u x * v x) := by
  simp only [Chain.avg_apply, Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- Con `f` autofunción, **el covariograma es geométrico**: `γ(t) = λ^t γ(0)`.
No se usa la estacionariedad, sólo la autofunción. -/
lemma gamma_eigen {f : S → ℝ} {lam : ℝ} (heig : ∀ x, D.applyP f x = lam * f x) (t : ℕ) :
    gamma D f t = lam ^ t * gamma D f 0 := by
  have h1 : Ppow D t f = fun y => lam ^ t * f y := funext (Ppow_eigen D heig t)
  simp only [gamma, inner, h1, Ppow_zero_apply]
  exact avg_mul_smul_right D f f (lam ^ t)

/-! ## 3. La solución de Poisson explícita `h = f/(1-λ)` -/

/-- En el caso autofunción la solución de Poisson es explícita: `h = f/(1-λ)`
satisface `h - Ph = f`. El centrado `π(h) = 0` cuando `π(f) = 0` es la
siguiente declaración, `avg_smul_of_avg_eq_zero`. -/
lemma poisson_eigen {f : S → ℝ} {lam : ℝ} (heig : ∀ x, D.applyP f x = lam * f x)
    (hlam : lam ≠ 1) (x : S) :
    f x = (1 - lam)⁻¹ * f x - D.applyP (fun y => (1 - lam)⁻¹ * f y) x := by
  have hc : (1 - lam) ≠ 0 := sub_ne_zero.mpr (Ne.symm hlam)
  simp only [applyP_const_mul D, heig]
  field_simp

/-- `π(h) = 0` si `π(f) = 0`. -/
lemma avg_smul_of_avg_eq_zero {f : S → ℝ} (hf : D.avg f = 0) (c : ℝ) :
    D.avg (fun x => c * f x) = 0 := by
  rw [avg_const_mul D, hf, mul_zero]

/-- **Unicidad de la solución de Poisson centrada**: dos soluciones centradas
de `h - Ph = f` coinciden. Con esto, la `h` explícita `f/(1-λ)` *es* la que
produce `Chain.poisson_solution` de `Book/GordinCoreM8.lean`, luego el `σ²` que
se calcula abajo es el `σ²` del módulo del libro. -/
lemma poisson_unique [Nonempty S] {f h1 h2 : S → ℝ}
    (h1c : D.avg h1 = 0) (h1p : ∀ x, f x = h1 x - D.applyP h1 x)
    (h2c : D.avg h2 = 0) (h2p : ∀ x, f x = h2 x - D.applyP h2 x) : h1 = h2 := by
  have hharm : ∀ z, (h1 - h2) z = D.applyP (h1 - h2) z := by
    intro z
    have h1z := h1p z
    have h2z := h2p z
    simp only [Pi.sub_apply, map_sub]
    linarith
  have havg : D.avg (h1 - h2) = 0 := by
    rw [map_sub, h1c, h2c, sub_zero]
  funext z
  have hz := D.harmonic_eq_zero hharm havg z
  exact sub_eq_zero.mp hz

/-! ## 4. El parámetro `σ²` en el caso autofunción -/

/-- Varianza condicional de una autofunción: `v(x) = (P f²)(x) - λ² f(x)²`. -/
lemma condVar_eigen {g : S → ℝ} {lam : ℝ} (heig : ∀ x, D.applyP g x = lam * g x) (x : S) :
    D.condVar g x = D.applyP (fun y => (g y) ^ 2) x - lam ^ 2 * (g x) ^ 2 := by
  have hterm : ∀ y, D.P x y * (g y - D.applyP g x) ^ 2
      = D.P x y * (g y) ^ 2 - (2 * (lam * g x)) * (D.P x y * g y)
        + (lam * g x) ^ 2 * D.P x y := by
    intro y
    rw [heig x]
    ring
  simp only [Chain.condVar]
  rw [Finset.sum_congr rfl fun y _ => hterm y]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    D.P_sum]
  simp only [Chain.applyP_apply, mul_one]
  have hS : ∑ y, D.P x y * g y = lam * g x := heig x
  rw [hS]
  ring

/-- **`σ²` de una autofunción**: `σ² = (1-λ²)·π(g²)` (forma de Dirichlet). -/
lemma sigmaSq_eigen {g : S → ℝ} {lam : ℝ} (heig : ∀ x, D.applyP g x = lam * g x) :
    D.sigmaSq g = (1 - lam ^ 2) * D.avg (fun x => (g x) ^ 2) := by
  have h1 : D.condVar g
      = fun x => D.applyP (fun y => (g y) ^ 2) x - lam ^ 2 * (g x) ^ 2 :=
    funext (condVar_eigen D heig)
  have h2 : (fun x => D.applyP (fun y => (g y) ^ 2) x - lam ^ 2 * (g x) ^ 2)
      = D.applyP (fun y => (g y) ^ 2) - (fun x => lam ^ 2 * (g x) ^ 2) := rfl
  simp only [Chain.sigmaSq, h1, h2, map_sub, Chain.avg_applyP, avg_const_mul D]
  ring

/-- `π` saca el cuadrado de un escalar: `π((c·g)²) = c²·π(g²)`. -/
lemma avg_smul_sq (c : ℝ) (g : S → ℝ) :
    D.avg (fun x => (c * g x) ^ 2) = c ^ 2 * D.avg (fun x => (g x) ^ 2) := by
  simp only [Chain.avg_apply, Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

/-- **`σ²` de la solución de Poisson explícita**: con `h = f/(1-λ)`,
`σ² = ((1+λ)/(1-λ))·π(f²)`. Es una identidad algebraica: no hay término de
error ni hipótesis de convergencia. -/
theorem sigmaSq_poisson_eigen {f : S → ℝ} {lam : ℝ}
    (heig : ∀ x, D.applyP f x = lam * f x) (hlam : lam ≠ 1) :
    D.sigmaSq (fun x => (1 - lam)⁻¹ * f x)
      = (1 + lam) / (1 - lam) * D.avg (fun x => (f x) ^ 2) := by
  have hc : (1 - lam) ≠ 0 := sub_ne_zero.mpr (Ne.symm hlam)
  have heig' : ∀ x, D.applyP (fun y => (1 - lam)⁻¹ * f y) x
      = lam * ((1 - lam)⁻¹ * f x) := by
    intro x
    simp only [applyP_const_mul D, heig]
    ring
  rw [sigmaSq_eigen D heig', avg_smul_sq D]
  field_simp
  ring

/-! ## 5. La identificación `σ² = γ(0) + 2∑_{k≥1} γ(k)` -/

/-- El covariograma es sumable en el caso autofunción con `|λ| < 1`. -/
theorem summable_gamma {f : S → ℝ} {lam : ℝ}
    (heig : ∀ x, D.applyP f x = lam * f x) (hlam1 : |lam| < 1) :
    Summable (gamma D f) := by
  have hgeom : Summable (fun t : ℕ => lam ^ t) := summable_geometric_of_norm_lt_one hlam1
  have hfun : gamma D f = fun t => gamma D f 0 * lam ^ t := by
    funext t
    rw [gamma_eigen D heig t]
    ring
  rw [hfun]
  exact hgeom.mul_left _

/-- **Sumabilidad absoluta del covariograma**: `∑_t |γ(t)| < ∞` (serie
geométrica de razón `|λ| < 1`; el enunciado no incluye el valor de la suma).
Es exactamente la hipótesis `habs` que usan
las máquinas de Toeplitz/covariograma ya auditadas
(`Book/Ch5CltAgentesCovarianza.lean`, p. ej. `cov_doble_limite`,
`toeplitz_weighted`): este teorema la descarga en el caso autofunción. -/
theorem summable_abs_gamma {f : S → ℝ} {lam : ℝ}
    (heig : ∀ x, D.applyP f x = lam * f x) (hlam1 : |lam| < 1) :
    Summable (fun t : ℕ => |gamma D f t|) := by
  have hgeom : Summable (fun t : ℕ => |lam| ^ t) := by
    refine summable_geometric_of_norm_lt_one ?_
    simpa using hlam1
  have hfun : (fun t : ℕ => |gamma D f t|) = fun t => |gamma D f 0| * |lam| ^ t := by
    funext t
    rw [gamma_eigen D heig t, abs_mul, abs_pow]
    ring
  rw [hfun]
  exact hgeom.mul_left _

/-- **La identificación de Gordin en el modelo exactamente soluble.**

Si el observable centrado `f` es autofunción de `P` con autovalor `λ`, `|λ| < 1`,
entonces la solución de Poisson `h = f/(1-λ)` —que es la centrada— satisface

  `σ² = π(condVar h) = γ(0) + 2 ∑_{k≥1} γ(k)`,  `γ(k) = ⟨f, P^k f⟩_π`.

Todo está demostrado: la serie es geométrica (`∑ γ(k) = γ(0)/(1-λ)`), y la
identidad algebraica `σ² = ((1+λ)/(1-λ))γ(0)` la cierra. -/
theorem sigmaSq_eq_gamma_tsum {f : S → ℝ} {lam : ℝ}
    (heig : ∀ x, D.applyP f x = lam * f x) (hlam : lam ≠ 1) (hlam1 : |lam| < 1) :
    D.sigmaSq (fun x => (1 - lam)⁻¹ * f x)
      = gamma D f 0 + 2 * ∑' k : ℕ, gamma D f (k + 1) := by
  have hc : (1 - lam) ≠ 0 := sub_ne_zero.mpr (Ne.symm hlam)
  have hsummable : Summable (gamma D f) := summable_gamma D heig hlam1
  have hterm : ∀ t : ℕ, gamma D f t = gamma D f 0 * lam ^ t := by
    intro t
    rw [gamma_eigen D heig t]
    ring
  have hval : ∑' t : ℕ, gamma D f t = gamma D f 0 * (1 - lam)⁻¹ := by
    rw [tsum_congr hterm, tsum_mul_left, tsum_geometric_of_norm_lt_one hlam1]
  have hsplit : ∑' t : ℕ, gamma D f t = gamma D f 0 + ∑' k : ℕ, gamma D f (k + 1) :=
    hsummable.tsum_eq_zero_add
  rw [hval] at hsplit
  have htail : ∑' k : ℕ, gamma D f (k + 1) = gamma D f 0 * (1 - lam)⁻¹ - gamma D f 0 := by
    linarith
  rw [htail, sigmaSq_poisson_eigen D heig hlam, gamma_zero D]
  field_simp
  ring

/-! ## 6. La clase de cadenas `P = (1-α)·I + α·1π`: todo observable centrado -/

/-- **Cadenas de rango uno** `P = (1-α)·I + α·1π` con `0 < α < 2`. Aquí *todo*
observable centrado es autofunción con el mismo autovalor `λ = 1-α`, `|λ| < 1`,
de modo que la identificación vale para **cada** `f` con `π(f) = 0`, sin
hipótesis por observable. La `h` de Poisson es `f/α`. -/
theorem sigmaSq_eq_gamma_tsum_rankOne {α : ℝ} (hα0 : 0 < α) (hα2 : α < 2)
    (hP : ∀ (g : S → ℝ) (x : S), D.applyP g x = (1 - α) * g x + α * D.avg g)
    {f : S → ℝ} (hf : D.avg f = 0) :
    D.sigmaSq (fun x => α⁻¹ * f x) = gamma D f 0 + 2 * ∑' k : ℕ, gamma D f (k + 1) := by
  have hsub : (1 : ℝ) - (1 - α) = α := by ring
  have heig : ∀ x, D.applyP f x = (1 - α) * f x := by
    intro x
    rw [hP f x, hf, mul_zero, add_zero]
  have hlam : (1 - α) ≠ 1 := by intro h; linarith
  have hlt : |1 - α| < 1 := by rw [abs_lt]; constructor <;> linarith
  have hmain := sigmaSq_eq_gamma_tsum (D := D) heig hlam hlt
  have hfun : (fun x => (1 - (1 - α))⁻¹ * f x) = fun x => α⁻¹ * f x := by
    funext x
    rw [hsub]
  rwa [hfun] at hmain

/-- En la clase de rango uno, la varianza tiene forma cerrada:
`σ² = ((1+(1-α))/α)·π(f²) = ((2-α)/α)·π(f²)`. -/
theorem sigmaSq_rankOne_eq {α : ℝ} (hα0 : 0 < α)
    (hP : ∀ (g : S → ℝ) (x : S), D.applyP g x = (1 - α) * g x + α * D.avg g)
    {f : S → ℝ} (hf : D.avg f = 0) :
    D.sigmaSq (fun x => α⁻¹ * f x) = ((2 - α) / α) * D.avg (fun x => (f x) ^ 2) := by
  have heig : ∀ x, D.applyP f x = (1 - α) * f x := by
    intro x
    rw [hP f x, hf, mul_zero, add_zero]
  have hlam : (1 - α) ≠ 1 := by intro h; linarith
  have hmain := sigmaSq_poisson_eigen (D := D) heig hlam
  have hfun : (fun x => (1 - (1 - α))⁻¹ * f x) = fun x => α⁻¹ * f x := by
    funext x
    rw [show (1 : ℝ) - (1 - α) = α by ring]
  rw [hfun] at hmain
  rw [hmain]
  have hα : α ≠ 0 := ne_of_gt hα0
  field_simp
  ring

end Chain

end GordinEigenM3
