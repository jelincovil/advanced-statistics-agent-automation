import Mathlib

/-!
# Book.Cap05Asintotica — cap. 5 del libro (`cap04_herramientas.typ`, §CLT/Delta/Bootstrap)

Cobertura nueva: teoremas numerados del libro que aún no tenían declaración en
`verificacion_lean/Book/`. Todos son teoremas de la asintótica clásica
(CLT, Lindeberg–Feller, mezcla, delta method, procesos empíricos, bootstrap,
CLT de retornos Monte Carlo y delta method para funciones de `Q`).

Convención de fidelidad (la del proyecto): cada enunciado se formaliza en la
versión más fuerte que la herramienta disponible permite sin inventar
resultados; cuando la versión del libro es un límite distribucional que Mathlib
no tiene, se formaliza el núcleo exacto que el libro usa en su prueba (la
identidad algebraica o la desigualdad analítica), y se declara en el docstring.

El andamiaje común es una capa de probabilidad finita (`fexp`, `fvar`, `fcov`:
esperanza/varianza/covarianza bajo pesos `p : Ω → ℝ` sobre `Ω` finito), que es
la versión discreta declarada del modelo del libro.
-/

open Finset BigOperators
open MeasureTheory ProbabilityTheory
open Filter
open scoped Topology

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

namespace BookCap05

/-! ### 0. Capa de probabilidad finita -/

variable {Ω : Type*} [Fintype Ω]

/-- Esperanza bajo los pesos `p`: `E_p[Y] = ∑_ω p(ω)·Y(ω)`. -/
noncomputable def fexp (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := ∑ ω, p ω * Y ω

/-- Varianza bajo los pesos `p`: `Var_p[Y] = E_p[(Y − E_p Y)²]`. -/
noncomputable def fvar (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := fexp p fun ω => (Y ω - fexp p Y) ^ 2

/-- Covarianza bajo los pesos `p`. -/
noncomputable def fcov (p : Ω → ℝ) (X Y : Ω → ℝ) : ℝ :=
  fexp p fun ω => (X ω - fexp p X) * (Y ω - fexp p Y)

/-- Los pesos `p` son una distribución de probabilidad sobre `Ω` finito. -/
def IsProb (p : Ω → ℝ) : Prop := (∀ ω, 0 ≤ p ω) ∧ ∑ ω, p ω = 1

theorem fexp_const (p : Ω → ℝ) (c : ℝ) : fexp p (fun _ => c) = c * ∑ ω, p ω := by
  simp only [fexp]
  rw [← Finset.sum_mul]
  ring

theorem fexp_const' (p : Ω → ℝ) (hp : IsProb p) (c : ℝ) : fexp p (fun _ => c) = c := by
  rw [fexp_const, hp.2, mul_one]

theorem fexp_sub (p : Ω → ℝ) (X Y : Ω → ℝ) :
    fexp p (fun ω => X ω - Y ω) = fexp p X - fexp p Y := by
  simp [fexp, mul_sub, Finset.sum_sub_distrib]

theorem fexp_add (p : Ω → ℝ) (X Y : Ω → ℝ) :
    fexp p (fun ω => X ω + Y ω) = fexp p X + fexp p Y := by
  simp [fexp, mul_add, Finset.sum_add_distrib]

theorem fexp_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fexp p (fun ω => c * Y ω) = c * fexp p Y := by
  rw [fexp, fexp, Finset.mul_sum]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem fexp_sum {ι : Type*} [Fintype ι] (p : Ω → ℝ) (X : ι → Ω → ℝ) :
    fexp p (fun ω => ∑ i, X i ω) = ∑ i, fexp p (X i) := by
  simp only [fexp]
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem fexp_fiberwise (p : Ω → ℝ) (Y : Ω → ℝ) (hp : IsProb p) :
    fexp p Y - fexp p (fun _ => 0) = ∑ ω, p ω * Y ω := by
  simp [fexp]

theorem fexp_nonneg (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (Y : Ω → ℝ) (hY : ∀ ω, 0 ≤ Y ω) :
    0 ≤ fexp p Y :=
  Finset.sum_nonneg fun ω _ => mul_nonneg (hp ω) (hY ω)

theorem fvar_nonneg (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (Y : Ω → ℝ) : 0 ≤ fvar p Y := by
  refine fexp_nonneg p hp _ fun ω => ?_
  exact sq_nonneg _

theorem fcov_self (p : Ω → ℝ) (X : Ω → ℝ) : fcov p X X = fvar p X := by
  simp only [fcov, fvar, sq]

theorem fvar_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fvar p (fun ω => c * Y ω) = c ^ 2 * fvar p Y := by
  have hm : fexp p (fun ω => c * Y ω) = c * fexp p Y := fexp_const_mul p c Y
  simp only [fvar, hm]
  have hfun : (fun ω => (c * Y ω - c * fexp p Y) ^ 2)
      = fun ω => c ^ 2 * (Y ω - fexp p Y) ^ 2 := by
    funext ω; ring
  rw [hfun, fexp_const_mul]

/-- La varianza de una suma es la suma de las covarianzas de los sumandos
(identidad de Koopman, en versión finita). -/
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

/-! ### 1. `thm:ch5-clt` — CLT clásico de Lindeberg–Lévy -/

/-- book: capitulos/cap04_herramientas.typ:1464 (key: thm:ch5-clt) —
**CLT clásico de Lindeberg–Lévy.** Si `X : ℕ → Ω → ℝ` es iid con
`E[X₀] = μ` y `0 < Var(X₀) = σ² < ∞`, entonces
`√n (X̄_n − μ) →d N(0, σ²)`, escrito aquí como
`(√n)⁻¹ · (∑_{k<n} X_k − n·E[X₀]) →d N(0, σ²)` con ley límite
`gaussianReal 0 σ²`.

Fidelidad declarada: el enunciado es el del libro sin recortes; la prueba
usa el CLT de Mathlib (`ProbabilityTheory.tendstoInDistribution_inv_sqrt_mul_sum_sub`),
que es exactamente el teorema de continuidad de Lévy aplicado a la función
característica, tal como el libro lo demuestra. Electo del libro: la
normalización `1/√n` en lugar de `√n` en el numerador (misma afirmación).
No se formaliza aquí la equivalencia con la forma studentizada porque es
la misma sucesión reescalada. -/
theorem ch5_clt {Ω' : Type*} [MeasurableSpace Ω] [MeasurableSpace Ω']
    (P : Measure Ω) [IsProbabilityMeasure P] (P' : Measure Ω') [IsProbabilityMeasure P']
    (X : ℕ → Ω → ℝ) (Y : Ω' → ℝ)
    (hY : HasLaw Y (gaussianReal 0 (variance (X 0) P).toNNReal) P')
    (hX : MemLp (X 0) 2 P) (hindep : iIndepFun X P)
    (hident : ∀ i : ℕ, IdentDistrib (X i) (X 0) P P) :
    TendstoInDistribution
      (fun (n : ℕ) ω => (√(n:ℝ))⁻¹ * (∑ k ∈ Finset.range n, X k ω - (n:ℝ) * ∫ x, X 0 x ∂P))
      Filter.atTop Y (fun _ => P) P' :=
  tendstoInDistribution_inv_sqrt_mul_sum_sub hY hX hindep hident


/-! ### 2. `prop:ch5-clt-retornos` — CLT para retornos Monte Carlo (núcleo exacto) -/

/-- book: capitulos/cap04_herramientas.typ:1759 (key: prop:ch5-clt-retornos) —
**CLT para retornos Monte Carlo.** Bajo política fija y estado inicial fijo, los
retornos `G_i` son iid con `E[G] = V^π(s₀)` y `Var(G) < ∞`; el libro concluye
`√n(Ḡ_n − V^π(s₀)) →d N(0, Var G)`.

Fidelidad declarada: se formaliza la parte exacta del enunciado, que es la que
usa el intervalo de confianza del libro: la media muestral es insesgada
(`E[Ḡ_n] = μ`) y su varianza es `σ²/n`. La convergencia distribucional es
`thm:ch5-clt` aplicada a los retornos (misma sucesión), de modo que el par de
identidades de aquí más el CLT es exactamente el enunciado. La independencia
entra por la covarianza nula entre retornos distintos, que es su consecuencia
(algebraicamente, `Cov(G_i,G_j)=0` para `i≠j` es lo único que la prueba usa).
Modelo: espacio de probabilidad finito con pesos `p` (versión discreta
declarada del libro). -/
theorem prop_ch5_clt_retornos {n : ℕ} (hn : 0 < n) (p : Ω → ℝ) (hp : IsProb p)
    (G : Fin n → Ω → ℝ) (μ σ2 : ℝ)
    (hmean : ∀ i, fexp p (G i) = μ) (hvar : ∀ i, fvar p (G i) = σ2)
    (hunc : ∀ i j, i ≠ j → fcov p (G i) (G j) = 0) :
    fexp p (fun ω => (n:ℝ)⁻¹ * ∑ i, G i ω) = μ ∧
      fvar p (fun ω => (n:ℝ)⁻¹ * ∑ i, G i ω) = σ2 / n := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hsum : fexp p (fun ω => ∑ i, G i ω) = (n:ℝ) * μ := by
    rw [fexp_sum]
    rw [Finset.sum_congr rfl fun i _ => hmean i]
    simp [Finset.sum_const, Fintype.card_fin, nsmul_eq_mul]
  have hinner : ∀ i : Fin n, ∑ j, fcov p (G i) (G j) = σ2 := by
    intro i
    rw [Finset.sum_eq_single i]
    · rw [fcov_self, hvar i]
    · intro j _ hj; exact hunc i j (Ne.symm hj)
    · intro hi; exact absurd (Finset.mem_univ i) hi
  have hsumvar : fvar p (fun ω => ∑ i, G i ω) = (n:ℝ) * σ2 := by
    rw [fvar_sum]
    rw [Finset.sum_congr rfl fun i _ => hinner i]
    simp [Finset.sum_const, Fintype.card_fin, nsmul_eq_mul]
  constructor
  · rw [fexp_const_mul, hsum]
    field_simp
  · rw [fvar_const_mul, hsumvar]
    field_simp

/-! ### 3. `thm:ch4-clt-mixing` — varianza límite bajo mezcla fuerte -/

/-- book: capitulos/cap04_herramientas.typ:1517 (key: thm:ch4-clt-mixing) —
**CLT bajo mezcla fuerte.** Si `(Z_t)` es estrictamente estacionaria con
`E|Z_0|^{2+δ} < ∞` y coeficientes de mezcla sumables, y
`τ² = Var(Z_0) + 2∑_{k≥1} Cov(Z_0,Z_k) > 0`, entonces
`√n(Z̄_n − μ) →d N(0, τ²)`.

Fidelidad declarada: se formaliza el objeto que define `τ²` y que es el núcleo
de la prueba: bajo estacionariedad el covariograma solo depende de la distancia,
`Cov(Z_i,Z_j) = γ(|i−j|)`, y por tanto
`Var(∑_{t<n} Z_t) = ∑_{i,j<n} γ(|i−j|)`; dividiendo por `n` y tomando `n → ∞`
aparece `γ(0) + 2∑_{k≥1} γ(k) = τ²` (la suma doble converge por sumabilidad de
los coeficientes de mezcla, hipótesis del libro). El límite distribucional
(martingala CLT, citado en el libro sin prueba) no se reproduce. -/
theorem ch4_clt_mixing_var {n : ℕ} (p : Ω → ℝ) (Z : ℕ → Ω → ℝ) (γ : ℕ → ℝ)
    (hcov : ∀ t k : ℕ, fcov p (Z t) (Z (t + k)) = γ k)
    (hrev : ∀ t k : ℕ, fcov p (Z (t + k)) (Z t) = γ k) :
    fvar p (fun ω => ∑ i : Fin n, Z (i:ℕ) ω)
      = ∑ i : Fin n, ∑ j : Fin n,
          γ (if (i:ℕ) ≤ (j:ℕ) then (j:ℕ) - (i:ℕ) else (i:ℕ) - (j:ℕ)) := by
  rw [fvar_sum]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  by_cases hij : (i:ℕ) ≤ (j:ℕ)
  · have h : (i:ℕ) + ((j:ℕ) - (i:ℕ)) = (j:ℕ) := Nat.add_sub_cancel' hij
    rw [if_pos hij]
    have hh := hcov (i:ℕ) ((j:ℕ) - (i:ℕ))
    rw [h] at hh
    exact hh
  · have hji : (j:ℕ) ≤ (i:ℕ) := le_of_not_ge hij
    have h : (j:ℕ) + ((i:ℕ) - (j:ℕ)) = (i:ℕ) := Nat.add_sub_cancel' hji
    rw [if_neg hij]
    have hh := hrev (j:ℕ) ((i:ℕ) - (j:ℕ))
    rw [h] at hh
    exact hh

/-! ### 4. `thm:ch5-lindeberg` — Lindeberg ⇒ Feller (despreciabilidad) -/

/-- Descomposición de `E[Y²]` en la parte de cola y la parte acotada. -/
theorem fexp_sq_split (p : Ω → ℝ) (Y : Ω → ℝ) (t : ℝ) :
    fexp p (fun ω => Y ω ^ 2)
      = fexp p (fun ω => if t < |Y ω| then Y ω ^ 2 else 0)
        + fexp p (fun ω => if t < |Y ω| then 0 else Y ω ^ 2) := by
  rw [← fexp_add]
  congr 1
  funext ω
  by_cases h : t < |Y ω| <;> simp [h]

/-- La parte acotada de `E[Y²]` está dominada por `t²`. -/
theorem fexp_sq_small_le (p : Ω → ℝ) (hp : IsProb p) (Y : Ω → ℝ) {t : ℝ} (ht : 0 ≤ t) :
    fexp p (fun ω => if t < |Y ω| then 0 else Y ω ^ 2) ≤ t ^ 2 := by
  rw [← fexp_const' p hp (t ^ 2)]
  refine Finset.sum_le_sum fun ω _ => ?_
  refine mul_le_mul_of_nonneg_left ?_ (hp.1 ω)
  by_cases h : t < |Y ω|
  · simp only [h, if_true]; positivity
  · simp only [h, if_false]
    have h2 : |Y ω| ≤ t := le_of_not_gt h
    nlinarith [abs_nonneg (Y ω), sq_abs (Y ω)]

/-- book: capitulos/cap04_herramientas.typ:1497 (key: thm:ch5-lindeberg) —
**CLT de Lindeberg–Feller.** Para un arreglo triangular con filas
independientes de medias `μ_{n,i}`, varianzas `σ²_{n,i}` y `s_n² = ∑_i σ²_{n,i}`,
la condición de Lindeberg
`(1/s_n²)∑_i E[(X_{n,i}−μ_{n,i})² 1{|X_{n,i}−μ_{n,i}|>ε s_n}] → 0`
implica la conclusión normal.

Fidelidad declarada: se formaliza el paso que el libro usa y que es
equivalente a la parte «despreciabilidad» del teorema (condición de Feller):
si la suma de Lindeberg de una fila está acotada por `δ·s²` y `s²` es la
varianza total, entonces **cada** varianza individual está acotada por
`δ·s² + ε²·s²`, es decir `σ²_{n,i}/s_n² ≤ δ + ε²` para todo `i`. Esto es lo
que se necesita para que el máximo sumando sea despreciable frente a la suma;
la conclusión distribucional (CLT) es el teorema clásico citado en el libro
(«véase van der Vaart»), no se reproduce. Modelo finito discreto declarado. -/
theorem ch5_lindeberg_feller {k : ℕ} (p : Ω → ℝ) (hp : IsProb p)
    (X : Fin k → Ω → ℝ) (s δ ε : ℝ) (hs : 0 ≤ s) (hε : 0 < ε)
    (hs2 : ∑ i, fvar p (X i) = s ^ 2)
    (hlind : ∑ i, fexp p (fun ω =>
        if ε * s < |X i ω - fexp p (X i)| then (X i ω - fexp p (X i)) ^ 2 else 0)
      ≤ δ * s ^ 2) :
    ∀ i, fvar p (X i) ≤ δ * s ^ 2 + ε ^ 2 * s ^ 2 := by
  intro i
  have ht : 0 ≤ ε * s := by positivity
  have hsplit := fexp_sq_split p (fun ω => X i ω - fexp p (X i)) (ε * s)
  have hsmall := fexp_sq_small_le p hp (fun ω => X i ω - fexp p (X i)) ht
  have hsingle : fexp p (fun ω =>
      if ε * s < |X i ω - fexp p (X i)| then (X i ω - fexp p (X i)) ^ 2 else 0)
      ≤ δ * s ^ 2 := by
    refine le_trans (Finset.single_le_sum (s := Finset.univ)
      (f := fun i => fexp p (fun ω =>
        if ε * s < |X i ω - fexp p (X i)| then (X i ω - fexp p (X i)) ^ 2 else 0))
      ?_ (Finset.mem_univ i)) hlind
    intro j _
    refine fexp_nonneg p hp.1 _ fun ω => ?_
    by_cases h : ε * s < |X j ω - fexp p (X j)|
    · simp only [h, if_true]; positivity
    · simp only [h, if_false]; positivity
  have hfv : fvar p (X i)
      = fexp p (fun ω => if ε * s < |X i ω - fexp p (X i)| then (X i ω - fexp p (X i)) ^ 2 else 0)
        + fexp p (fun ω => if ε * s < |X i ω - fexp p (X i)| then 0 else (X i ω - fexp p (X i)) ^ 2) := by
    rw [fvar]; exact hsplit
  have hsmall' : fexp p (fun ω => if ε * s < |X i ω - fexp p (X i)| then 0
      else (X i ω - fexp p (X i)) ^ 2) ≤ (ε * s) ^ 2 := hsmall
  have hmain : fvar p (X i) ≤ δ * s ^ 2 + (ε * s) ^ 2 := by
    rw [hfv]; exact add_le_add hsingle hsmall'
  have hsq : (ε * s) ^ 2 = ε ^ 2 * s ^ 2 := by ring
  linarith

/-- Condición de Feller como corolario: en las hipótesis de Lindeberg, la
varianza relativa de cualquier sumando es a lo sumo `δ + ε²`. -/
theorem ch5_feller_condition {k : ℕ} (p : Ω → ℝ) (hp : IsProb p)
    (X : Fin k → Ω → ℝ) (s δ ε : ℝ) (hs : 0 < s) (hε : 0 < ε)
    (hs2 : ∑ i, fvar p (X i) = s ^ 2)
    (hlind : ∑ i, fexp p (fun ω =>
        if ε * s < |X i ω - fexp p (X i)| then (X i ω - fexp p (X i)) ^ 2 else 0)
      ≤ δ * s ^ 2) :
    ∀ i, fvar p (X i) / s ^ 2 ≤ δ + ε ^ 2 := by
  intro i
  have h := ch5_lindeberg_feller p hp X s δ ε (le_of_lt hs) hε hs2 hlind i
  have hpos : (0:ℝ) < s ^ 2 := by positivity
  rw [div_le_iff₀ hpos]
  nlinarith

/-! ### 5. `thm:ch5-delta` — Delta method univariado (núcleo de Taylor) -/

/-- `f x → 0` sii `|f x| → 0`. -/
theorem real_tendsto_zero_iff_abs {α : Type*} {l : Filter α} {f : α → ℝ} :
    Tendsto f l (𝓝 0) ↔ Tendsto (fun x => |f x|) l (𝓝 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  exact ⟨fun h => by simpa [Real.norm_eq_abs] using h, fun h => by simpa [Real.norm_eq_abs] using h⟩

/-- book: capitulos/cap04_herramientas.typ:1538 (key: thm:ch5-delta) —
**Delta method univariado.** Si `√n(T_n − θ) →d N(0,σ²)` y `g` es derivable
en `θ` con jacobiana `g'(θ)`, entonces `√n(g(T_n) − g(θ)) →d N(0, g'(θ)²σ²)`.

Fidelidad declarada: se formaliza el paso analítico de la prueba del libro,
que es el único que no es Slutsky: la expansión de Taylor de primer orden
deja un resto `o_P(1)` que, multiplicado por `√n`, tiende a cero. Las
hipótesis son las dos que el libro usa: consistencia `T_n → θ` y acotación
de `√n|T_n − θ|` (consecuencia de la convergencia en distribución, que el
libro tiene por hipótesis), más la cota de Taylor `|g(x) − g(θ) − g'(θ)(x−θ)|
≤ K(x−θ)²` que es la forma cuantitativa de «g derivable con resto
`o(|x−θ|)`». La conclusión es exactamente `√n·resto → 0`, que es
`o_P(1)`. El paso de Slutsky (componer con la normal límite) no se reproduce
porque Mathlib no tiene aún convergencia en distribución de imágenes
lineales en esta forma. -/
theorem ch5_delta {g : ℝ → ℝ} {θ g' K M : ℝ} (hK : 0 ≤ K) (hM : 0 ≤ M)
    {T : ℕ → ℝ} (hT : Tendsto T atTop (𝓝 θ))
    (hbdd : ∀ n : ℕ, √(n:ℝ) * |T n - θ| ≤ M)
    (hrem : ∀ x, |g x - g θ - g' * (x - θ)| ≤ K * (x - θ) ^ 2) :
    Tendsto (fun n : ℕ => √(n:ℝ) * (g (T n) - g θ - g' * (T n - θ))) atTop (𝓝 0) := by
  have hsq : ∀ n : ℕ, |√(n:ℝ) * (g (T n) - g θ - g' * (T n - θ))|
      ≤ K * M * |T n - θ| := by
    intro n
    have hsqrt : 0 ≤ √(n:ℝ) := Real.sqrt_nonneg _
    have h1 : |√(n:ℝ) * (g (T n) - g θ - g' * (T n - θ))|
        = √(n:ℝ) * |g (T n) - g θ - g' * (T n - θ)| := by
      rw [abs_mul, abs_of_nonneg hsqrt]
    rw [h1]
    have h2 := hrem (T n)
    have h3 : √(n:ℝ) * |g (T n) - g θ - g' * (T n - θ)|
        ≤ √(n:ℝ) * (K * (T n - θ) ^ 2) := mul_le_mul_of_nonneg_left h2 hsqrt
    have h4 : √(n:ℝ) * (K * (T n - θ) ^ 2) = K * (√(n:ℝ) * |T n - θ|) * |T n - θ| := by
      rw [← sq_abs (T n - θ)]; ring
    have h5 : K * (√(n:ℝ) * |T n - θ|) * |T n - θ| ≤ K * M * |T n - θ| := by
      refine mul_le_mul_of_nonneg_right ?_ (abs_nonneg _)
      exact mul_le_mul_of_nonneg_left (hbdd n) hK
    linarith [h3, h4 ▸ h3, h5]
  have hlim : Tendsto (fun n : ℕ => K * M * |T n - θ|) atTop (𝓝 0) := by
    have h0 : Tendsto (fun n : ℕ => |T n - θ|) atTop (𝓝 0) := by
      have hsub : Tendsto (fun n : ℕ => T n - θ) atTop (𝓝 (θ - θ)) :=
        hT.sub tendsto_const_nhds
      simpa using hsub.abs
    simpa using h0.const_mul (K * M)
  refine real_tendsto_zero_iff_abs.mpr ?_
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hlim
    (Eventually.of_forall fun n => abs_nonneg _) (Eventually.of_forall hsq)

/-! ### 6. `thm:ch5-delta-multi` — Delta method multivariado -/

/-- book: capitulos/cap04_herramientas.typ:1570 (key: thm:ch5-delta-multi) —
**Delta method multivariado.** Si `√n(T_n − θ) →d N(0, Σ)` en `ℝ^k` y
`g : ℝ^k → ℝ^m` es diferenciable en `θ` con jacobiana `J`, entonces
`√n(g(T_n) − g(θ)) →d N(0, JΣJᵀ)`.

Fidelidad declarada: como en `thm:ch5-delta`, se formaliza el núcleo
analítico: el resto de Taylor de primer orden, escalado por `√n`, tiende a
cero en norma. Se enuncia para espacios normados reales cualesquiera (caso
general del libro `E = ℝ^k`, `F = ℝ^m` con la diferencial `D = J`), con la
cota de Taylor cuadrática `‖g(x) − g(θ) − D(x−θ)‖ ≤ K‖x−θ‖²`, la
consistencia `T_n → θ` y la acotación de `√n‖T_n − θ‖`. La convergencia en
distribución límite (que es `N(0, JΣJᵀ)`) no se reproduce. -/
theorem ch5_delta_multi {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    {g : E → F} {θ : E} (D : E →L[ℝ] F) {K M : ℝ} (hK : 0 ≤ K) (hM : 0 ≤ M)
    {T : ℕ → E} (hT : Tendsto T atTop (𝓝 θ))
    (hbdd : ∀ n : ℕ, √(n:ℝ) * ‖T n - θ‖ ≤ M)
    (hrem : ∀ x, ‖g x - g θ - D (x - θ)‖ ≤ K * ‖x - θ‖ ^ 2) :
    Tendsto (fun n : ℕ => √(n:ℝ) • (g (T n) - g θ - D (T n - θ))) atTop (𝓝 0) := by
  have hsq : ∀ n : ℕ, ‖√(n:ℝ) • (g (T n) - g θ - D (T n - θ))‖ ≤ K * M * ‖T n - θ‖ := by
    intro n
    have hsqrt : 0 ≤ √(n:ℝ) := Real.sqrt_nonneg _
    rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg hsqrt]
    have h2 := hrem (T n)
    have h3 : √(n:ℝ) * ‖g (T n) - g θ - D (T n - θ)‖ ≤ √(n:ℝ) * (K * ‖T n - θ‖ ^ 2) :=
      mul_le_mul_of_nonneg_left h2 hsqrt
    have h4 : √(n:ℝ) * (K * ‖T n - θ‖ ^ 2) = K * (√(n:ℝ) * ‖T n - θ‖) * ‖T n - θ‖ := by ring
    have h5 : K * (√(n:ℝ) * ‖T n - θ‖) * ‖T n - θ‖ ≤ K * M * ‖T n - θ‖ := by
      refine mul_le_mul_of_nonneg_right ?_ (norm_nonneg _)
      exact mul_le_mul_of_nonneg_left (hbdd n) hK
    linarith
  have hlim : Tendsto (fun n : ℕ => K * M * ‖T n - θ‖) atTop (𝓝 0) := by
    have h0 : Tendsto (fun n : ℕ => ‖T n - θ‖) atTop (𝓝 0) := by
      have hsub : Tendsto (fun n : ℕ => T n - θ) atTop (𝓝 (θ - θ)) :=
        hT.sub tendsto_const_nhds
      simpa using hsub.norm
    simpa using h0.const_mul (K * M)
  have hnorm : Tendsto
      (fun n : ℕ => ‖√(n:ℝ) • (g (T n) - g θ - D (T n - θ))‖) atTop (𝓝 0) :=
    tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hlim
      (Eventually.of_forall fun n => norm_nonneg _) (Eventually.of_forall hsq)
  exact (tendsto_zero_iff_norm_tendsto_zero
    (f := fun n : ℕ => √(n:ℝ) • (g (T n) - g θ - D (T n - θ)))).mpr hnorm

/-! ### 7. `prop:ch5-delta-q` — Delta method para funciones de `Q` -/

/-- Covarianza de un múltiplo escalar (por la izquierda). -/
theorem fcov_const_mul_left (p : Ω → ℝ) (c : ℝ) (X Y : Ω → ℝ) :
    fcov p (fun ω => c * X ω) Y = c * fcov p X Y := by
  have hm : fexp p (fun ω => c * X ω) = c * fexp p X := fexp_const_mul p c X
  simp only [fcov, hm]
  have hpt : (fun ω => (c * X ω - c * fexp p X) * (Y ω - fexp p Y))
      = fun ω => c * ((X ω - fexp p X) * (Y ω - fexp p Y)) := by
    funext ω; ring
  rw [hpt, fexp_const_mul]

/-- Covarianza de un múltiplo escalar (por la derecha). -/
theorem fcov_const_mul_right (p : Ω → ℝ) (c : ℝ) (X Y : Ω → ℝ) :
    fcov p X (fun ω => c * Y ω) = c * fcov p X Y := by
  have hm : fexp p (fun ω => c * Y ω) = c * fexp p Y := fexp_const_mul p c Y
  simp only [fcov, hm]
  have hpt : (fun ω => (X ω - fexp p X) * (c * Y ω - c * fexp p Y))
      = fun ω => c * ((X ω - fexp p X) * (Y ω - fexp p Y)) := by
    funext ω; ring
  rw [hpt, fexp_const_mul]

/-- book: capitulos/cap04_herramientas.typ:1778 (key: prop:ch5-delta-q) —
**Delta method para funciones de `Q`.** Con `V̂_n(s) = p_sᵀQ̂_n(s)` y
`p_s = (π(a|s))_a`, el libro concluye `√n(V̂_n − V^π(s)) →d N(0, p_sᵀΣ_Q p_s)`.

Fidelidad declarada: se formaliza la identidad exacta de la varianza que el
libro usa y explicita en la prosa (varianzas ponderadas al cuadrado más
covarianzas cruzadas): `Var(∑_a p_a Q_a) = ∑_a ∑_b p_a p_b (Σ_Q)_{a,b}`.
La convergencia distribucional es el delta method (`thm:ch5-delta-multi`) con
jacobiana `p_sᵀ`, que es lineal. Modelo finito discreto declarado. -/
theorem prop_ch5_delta_q {a : Type*} [Fintype a] (p : Ω → ℝ) (pπ : a → ℝ)
    (Q : a → Ω → ℝ) (Sg : a → a → ℝ) (hcov : ∀ i j, fcov p (Q i) (Q j) = Sg i j) :
    fvar p (fun ω => ∑ i, pπ i * Q i ω) = ∑ i, ∑ j, pπ i * pπ j * Sg i j := by
  rw [fvar_sum]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  rw [fcov_const_mul_left, fcov_const_mul_right, hcov]
  ring

/-- Comprobación numérica del ejemplo del libro (`ex:ch5-qdelta`): con
`p = (0.6, 0.4)` y `Σ = ((4.0, 1.2), (1.2, 9.0))` la varianza del valor es
`0.6²·4.0 + 0.4²·9.0 + 2·0.6·0.4·1.2 = 3.456`. -/
theorem ex_ch5_qdelta_num : (0.6:ℝ)^2 * 4.0 + (0.4:ℝ)^2 * 9.0 + 2 * 0.6 * 0.4 * 1.2 = 3.456 := by
  norm_num


/-! ### 8. `thm:ch5-donsker` — proceso empírico: media cero y covarianza del puente -/

/-- Función de distribución empírica de la muestra `X` bajo los pesos `p`. -/
noncomputable def ecdf (p : Ω → ℝ) (X : Ω → ℝ) (x : ℝ) : ℝ :=
  fexp p fun ω => if X ω ≤ x then (1:ℝ) else 0

/-- La covarianza es `E[AB] − E[A]E[B]`. -/
theorem fcov_eq (p : Ω → ℝ) (hp : IsProb p) (A B : Ω → ℝ) :
    fcov p A B = fexp p (fun ω => A ω * B ω) - fexp p A * fexp p B := by
  have hpt : (fun ω => (A ω - fexp p A) * (B ω - fexp p B))
      = fun ω => A ω * B ω - fexp p A * B ω - fexp p B * A ω + fexp p A * fexp p B := by
    funext ω; ring
  rw [fcov, hpt, fexp_add, fexp_sub, fexp_sub, fexp_const_mul, fexp_const_mul,
    fexp_const' p hp]
  ring

/-- El producto de dos indicadores de cola izquierda es el del mínimo. -/
theorem ind_mul_ind (X : Ω → ℝ) (s t : ℝ) :
    (fun ω => (if X ω ≤ s then (1:ℝ) else 0) * (if X ω ≤ t then (1:ℝ) else 0))
      = fun ω => if X ω ≤ min s t then (1:ℝ) else 0 := by
  funext ω
  by_cases hs : X ω ≤ s <;> by_cases ht : X ω ≤ t <;> simp [hs, ht, le_min_iff]

/-- book: capitulos/cap04_herramientas.typ:1658 (key: thm:ch5-donsker) —
**Donsker: covarianza del proceso empírico.** Para una muestra iid de `F`, el
proceso empírico `𝔾_n(x) = √n(F̂_n(x) − F(x))` tiene media cero en cada `x` y
covarianza `Cov(𝔾_n(s), 𝔾_n(t)) = F(min(s,t)) − F(s)F(t)`, que es la covarianza
del puente Browniano compuesto con `F`; el libro concluye de ahí
`𝔾_n →d B∘F` en `ℓ^∞` con la norma suprema.

Fidelidad declarada: se formalizan las dos identidades que el libro enuncia y
usa para identificar el límite (media cero y función de covarianza), para la
distribución `F` empírica de una observación bajo pesos `p`; para la muestra
de tamaño `n` las mismas identidades se obtienen promediando las `n`
observaciones iid (la suma de indicadores independientes conserva la covarianza
y el factor `√n` normaliza). La convergencia débil en `ℓ^∞` (teorema de
Donsker propiamente dicho, citado en el libro por referencia) no se reproduce.
`ecdf p X x` es `F(x) = P(X ≤ x)`. -/
theorem ch5_donsker (p : Ω → ℝ) (hp : IsProb p) (X : Ω → ℝ) (s t : ℝ) :
    (fexp p (fun ω => (if X ω ≤ s then (1:ℝ) else 0) - ecdf p X s) = 0) ∧
      fcov p (fun ω => if X ω ≤ s then (1:ℝ) else 0)
          (fun ω => if X ω ≤ t then (1:ℝ) else 0)
        = ecdf p X (min s t) - ecdf p X s * ecdf p X t := by
  have hIs : fexp p (fun ω => if X ω ≤ s then (1:ℝ) else 0) = ecdf p X s := rfl
  have hIt : fexp p (fun ω => if X ω ≤ t then (1:ℝ) else 0) = ecdf p X t := rfl
  constructor
  · rw [fexp_sub, hIs, fexp_const' p hp, sub_self]
  · rw [fcov_eq p hp, hIs, hIt]
    have hprod : fexp p (fun ω => (if X ω ≤ s then (1:ℝ) else 0)
        * (if X ω ≤ t then (1:ℝ) else 0)) = ecdf p X (min s t) := by
      rw [ind_mul_ind X s t]; rfl
    rw [hprod]

/-! ### 9. `thm:ch5-bootstrap-media` — bootstrap de la media -/

/-- book: capitulos/cap04_herramientas.typ:1714 (key: thm:ch5-bootstrap-media) —
**Consistencia del bootstrap para la media.** Condicionalmente en la muestra,
las réplicas bootstrap son iid con distribución `F̂_n`; su media condicional es
`X̄_n` y su varianza condicional `σ̂_n²`, de modo que
`√n(X̄*_n − X̄_n) →d N(0, σ²)` en probabilidad.

Fidelidad declarada: se formaliza el cómputo condicional exacto del que parte
la prueba del libro, con `F̂_n` la distribución empírica (pesos uniformes
`1/n` sobre la muestra): la media de `F̂_n` es la media muestral y su varianza
es la varianza empírica `σ̂_n² = (1/n)∑(X_j − X̄_n)²`. Para una réplica de
tamaño `m` la media tiene esperanza `X̄_n` y varianza `σ̂_n²/m`
(`prop:ch5-clt-retornos` con varianzas `σ̂_n²` y covarianzas nulas, que es la
independencia condicional), y la consistencia `σ̂_n² → σ²` es la LGN. El paso
de convergencia condicional (CLT triangular con ley que cambia con `n`) no se
reproduce: es exactamente el CLT de Lindeberg–Feller aplicado a las réplicas,
citado en el libro. -/
theorem ch5_bootstrap_media {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) :
    (fexp (fun _ : Fin n => (n:ℝ)⁻¹) x = (n:ℝ)⁻¹ * ∑ j, x j) ∧
      (fvar (fun _ : Fin n => (n:ℝ)⁻¹) x
        = (n:ℝ)⁻¹ * ∑ j, (x j - (n:ℝ)⁻¹ * ∑ k, x k) ^ 2) := by
  have h1 : fexp (fun _ : Fin n => (n:ℝ)⁻¹) x = (n:ℝ)⁻¹ * ∑ j, x j := by
    rw [fexp, ← Finset.mul_sum]
  refine ⟨h1, ?_⟩
  rw [fvar, h1, fexp, ← Finset.mul_sum]


/-! ### 10. Testigo de no vacuidad del delta method -/

/-- Testigo explícito de que las hipótesis de `ch5_delta` son satisfacibles:
con `g = id`, `g' = 1`, `T ≡ θ` y `K = M = 0`, la conclusión es la sucesión
nula. -/
theorem ch5_delta_testigo (θ : ℝ) :
    Tendsto (fun n : ℕ => √(n:ℝ) * (θ - θ - 1 * (θ - θ))) atTop (𝓝 0) := by
  have h := ch5_delta (g := fun x => x) (θ := θ) (g' := 1) (K := 0) (M := 0)
    (T := fun _ => θ) le_rfl le_rfl tendsto_const_nhds
    (fun n => by simp) (fun x => by simp)
  simpa using h


end BookCap05