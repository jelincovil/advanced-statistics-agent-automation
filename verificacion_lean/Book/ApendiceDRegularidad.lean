import Mathlib

/-!
# Book.ApendiceDRegularidad — coeficientes de dependencia (α, β, φ)

Formalización de `apendices/apendice_regularidad.typ` del libro *Inferencia
Estadística*. Claves del libro: `def:appD-alpha`, `def:appD-beta`,
`def:appD-phi`, `prop:appD-relaciones`.

## Fidelidad declarada (versión finita/discreta)

El libro define, para dos σ-álgebras `F` y `G` de un espacio de probabilidad:

* `α(F,G) = sup_{A∈F, B∈G} |P(A∩B) − P(A)P(B)|`
* `β(F,G) = E[sup_{B∈G} |P(B|F) − P(B)|]`
* `φ(F,G) = sup_{A∈F, P(A)>0, B∈G} |P(B|A) − P(B)|`

Aquí el espacio es **finito** y las σ-álgebras son las generadas por dos
variables `f : X → I`, `g : X → J` con `I`, `J` finitos. Entonces todo evento de
`σ(f)` es una unión de átomos `f = i` y el supremo sobre `σ(f)` es el máximo
sobre subconjuntos `S ⊆ I`. Trabajamos con la ley conjunta
`p i j = P(f = i ∧ g = j)`; la masa es `P(f ∈ S) = ∑_{i∈S} fila p i`. En espacio
finito las tres definiciones del libro son:

* `α = max_{S,T} |∑_{i∈S, j∈T} desv p i j|` (máximo, se alcanza);
* `β = (1/2) ∑_{i,j} |desv p i j|`, porque
  `sup_{B∈σ(g)} |P(B|A_i) − P(B)| = (1/2)∑_j |desv p i j| / P(A_i)`
  (la fila suma cero y todo `B ∈ σ(g)` es unión de átomos), de donde
  `β = ∑_i P(A_i)·(1/2)∑_j|desv|/P(A_i) = (1/2)∑_{i,j}|desv|`;
* `φ = max_{S,T} |∑_{i∈S,j∈T} desv p i j| / P(f ∈ S)`, con la convención
  `x/0 = 0` de Lean, que coincide con la restricción `P(A) > 0` porque una `S`
  de masa cero tiene desviación cero.

Los tres coinciden con el libro en espacio finito. `relaciones` es
`2α ≤ β ≤ φ` para un par de σ-álgebras; el enunciado global del libro
(`α(k) = sup_t α(F^t, F^∞_{t+k})`, etc.) se obtiene aplicando la desigualdad
puntual y la monotonía del supremo, que se formaliza en
`two_mul_alphaFam_le_betaFam` / `betaFam_le_phiFam`; el paso a «mixing»
(coeficientes que tienden a cero) está en `tendsto_beta_of_tendsto_phi` y
`tendsto_alpha_of_tendsto_phi`.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

open Finset BigOperators Filter

namespace Book.ApendiceD

/-! ## Ley conjunta de dos particiones finitas -/

section Coef

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]

/-- `fila p i = P(f = i)`: masa marginal del átomo `i`. -/
def fila (p : I → J → ℝ) (i : I) : ℝ := ∑ j, p i j

/-- `col p j = P(g = j)`: masa marginal del átomo `j`. -/
def col (p : I → J → ℝ) (j : J) : ℝ := ∑ i, p i j

/-- `desv p i j = P(f=i ∧ g=j) − P(f=i)P(g=j)`: desviación de independencia. -/
def desv (p : I → J → ℝ) (i : I) (j : J) : ℝ := p i j - fila p i * col p j

/-- Masa de un evento de `σ(f)`: `masa p S = P(f ∈ S)`. -/
def masa (p : I → J → ℝ) (S : Finset I) : ℝ := ∑ i ∈ S, fila p i

/-- Desviación de un rectángulo `A × B` con `A ∈ σ(f)`, `B ∈ σ(g)`. -/
def rectDesv (p : I → J → ℝ) (S : Finset I) (T : Finset J) : ℝ :=
  ∑ i ∈ S, ∑ j ∈ T, desv p i j

/-- **α** (`def:appD-alpha`), versión finita: máximo sobre rectángulos. -/
noncomputable def alpha (p : I → J → ℝ) : ℝ :=
  (Finset.univ : Finset (Finset I × Finset J)).sup' ⟨(∅, ∅), Finset.mem_univ _⟩
    fun ST => |rectDesv p ST.1 ST.2|

/-- **β** (`def:appD-beta`), versión finita: `E[sup_B |P(B|F) − P(B)|]`, que en
espacio finito vale `(1/2)∑_{i,j}|desv|`. -/
noncomputable def beta (p : I → J → ℝ) : ℝ := (1 / 2) * ∑ i, ∑ j, |desv p i j|

/-- **φ** (`def:appD-phi`), versión finita: máximo de `|P(B|A)−P(B)|` sobre
rectángulos `A × B` (`x/0 = 0` para `P(A) = 0`). -/
noncomputable def phi (p : I → J → ℝ) : ℝ :=
  (Finset.univ : Finset (Finset I × Finset J)).sup' ⟨(∅, ∅), Finset.mem_univ _⟩
    fun ST => |rectDesv p ST.1 ST.2| / masa p ST.1

variable {p : I → J → ℝ}

lemma fila_nonneg (hp : ∀ i j, 0 ≤ p i j) (i : I) : 0 ≤ fila p i :=
  Finset.sum_nonneg fun j _ => hp i j

lemma masa_nonneg (hp : ∀ i j, 0 ≤ p i j) (S : Finset I) : 0 ≤ masa p S :=
  Finset.sum_nonneg fun i _ => fila_nonneg hp i

lemma sum_col (htot : ∑ i, ∑ j, p i j = 1) : ∑ j, col p j = 1 := by
  unfold col
  rw [Finset.sum_comm]
  exact htot

lemma sum_fila (htot : ∑ i, ∑ j, p i j = 1) : ∑ i, fila p i = 1 := htot

/-- Cada fila de la matriz de desviaciones suma cero. -/
lemma desv_row_sum_zero (htot : ∑ i, ∑ j, p i j = 1) (i : I) : ∑ j, desv p i j = 0 := by
  simp only [desv]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum, sum_col htot]
  simp [fila]

/-- Cada columna de la matriz de desviaciones suma cero. -/
lemma desv_col_sum_zero (htot : ∑ i, ∑ j, p i j = 1) (j : J) : ∑ i, desv p i j = 0 := by
  simp only [desv]
  rw [Finset.sum_sub_distrib, ← Finset.sum_mul, sum_fila htot]
  simp [col]

/-! ## Dos lemas numéricos sobre familias de suma cero -/

/-- Si `∑ i, c i = 0`, toda suma parcial está acotada por la mitad de la
norma `ℓ¹`: `|∑_{i∈T} c i| ≤ (1/2)∑_i |c i|`. -/
lemma abs_sum_subset_le_half {ι : Type*} [Fintype ι] [DecidableEq ι] (c : ι → ℝ) (h : ∑ i, c i = 0)
    (T : Finset ι) : |∑ i ∈ T, c i| ≤ (1 / 2) * ∑ i, |c i| := by
  have hcompl : ∑ i ∈ Tᶜ, c i = -∑ i ∈ T, c i := by
    have := Finset.sum_add_sum_compl T c
    linarith
  have habs : |∑ i ∈ T, c i| = |∑ i ∈ Tᶜ, c i| := by rw [hcompl, abs_neg]
  have hsplit : (∑ i ∈ T, |c i|) + (∑ i ∈ Tᶜ, |c i|) = ∑ i, |c i| :=
    Finset.sum_add_sum_compl T _
  have hT : |∑ i ∈ T, c i| ≤ ∑ i ∈ T, |c i| := abs_sum_le_sum_abs _ _
  have hTc : |∑ i ∈ T, c i| ≤ ∑ i ∈ Tᶜ, |c i| := by
    rw [habs]; exact abs_sum_le_sum_abs _ _
  linarith

/-- Si `∑ i, c i = 0`, la suma sobre la parte positiva vale la mitad de la
norma `ℓ¹`: `∑_{c>0} c = (1/2)∑_i |c i|`. -/
lemma sum_pos_part_half {ι : Type*} [Fintype ι] (c : ι → ℝ) (h : ∑ i, c i = 0) :
    ∑ i ∈ Finset.univ.filter (fun i => 0 < c i), c i = (1 / 2) * ∑ i, |c i| := by
  have hpt : ∀ i, |c i| = 2 * max (c i) 0 - c i := by
    intro i
    rcases le_total 0 (c i) with h0 | h0
    · rw [abs_of_nonneg h0, max_eq_left h0]; ring
    · rw [abs_of_nonpos h0, max_eq_right h0]; ring
  have hmax : ∑ i ∈ Finset.univ.filter (fun i => 0 < c i), c i
      = ∑ i, max (c i) 0 := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases hc : 0 < c i
    · simp [hc, max_eq_left hc.le]
    · simp [hc, max_eq_right (le_of_not_gt hc)]
  rw [hmax]
  have hsplit : ∑ i, |c i| = 2 * ∑ i, max (c i) 0 - ∑ i, c i := by
    have h1 : ∑ i, (2 * max (c i) 0 - c i) = 2 * ∑ i, max (c i) 0 - ∑ i, c i := by
      rw [Finset.sum_sub_distrib, Finset.mul_sum]
    rw [← h1]
    exact Finset.sum_congr rfl fun i _ => hpt i
  rw [hsplit, h]
  ring

/-! ## `2α ≤ β` -/

lemma rectDesv_eq_sum_col (S : Finset I) (T : Finset J) :
    rectDesv p S T = ∑ j ∈ T, ∑ i ∈ S, desv p i j := by
  unfold rectDesv
  rw [Finset.sum_comm]

lemma rectDesv_singleton (i : I) (T : Finset J) :
    rectDesv p {i} T = ∑ j ∈ T, desv p i j := by
  unfold rectDesv
  simp

theorem alpha_nonneg (hp : ∀ i j, 0 ≤ p i j) : 0 ≤ alpha p := by
  unfold alpha
  have h := Finset.le_sup' (s := (Finset.univ : Finset (Finset I × Finset J)))
    (fun ST => |rectDesv p ST.1 ST.2|) (Finset.mem_univ ((∅ : Finset I), (∅ : Finset J)))
  simpa [rectDesv] using h

theorem beta_nonneg (hp : ∀ i j, 0 ≤ p i j) : 0 ≤ beta p := by
  unfold beta
  have : (0 : ℝ) ≤ ∑ i, ∑ j, |desv p i j| :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg _
  linarith

theorem phi_nonneg (hp : ∀ i j, 0 ≤ p i j) : 0 ≤ phi p := by
  unfold phi
  have h := Finset.le_sup' (s := (Finset.univ : Finset (Finset I × Finset J)))
    (fun ST => |rectDesv p ST.1 ST.2| / masa p ST.1)
    (Finset.mem_univ ((∅ : Finset I), (∅ : Finset J)))
  simpa [rectDesv] using h

/-- `α ≤ β/2`: la clave es que las filas **y** las columnas de `desv` suman
cero, de modo que `∑_j |∑_{i∈S} desv| ≤ (1/2)∑_{i,j}|desv|`. -/
theorem alpha_le_half_beta (hp : ∀ i j, 0 ≤ p i j) (htot : ∑ i, ∑ j, p i j = 1) :
    alpha p ≤ beta p / 2 := by
  unfold alpha beta
  refine Finset.sup'_le _ _ ?_
  rintro ⟨S, T⟩ -
  have hc : ∀ j, ∑ i ∈ S, desv p i j = -∑ i ∈ Sᶜ, desv p i j := by
    intro j
    have h := Finset.sum_add_sum_compl S (fun i => desv p i j)
    rw [desv_col_sum_zero htot j] at h
    linarith
  have hzero : ∑ j, (∑ i ∈ S, desv p i j) = 0 := by
    rw [Finset.sum_comm]
    exact Finset.sum_eq_zero fun i _ => desv_row_sum_zero htot i
  have h1 : |∑ j ∈ T, ∑ i ∈ S, desv p i j|
      ≤ (1 / 2) * ∑ j, |∑ i ∈ S, desv p i j| :=
    abs_sum_subset_le_half (fun j => ∑ i ∈ S, desv p i j) hzero T
  have hA : ∑ j, |∑ i ∈ S, desv p i j| ≤ ∑ i ∈ S, ∑ j, |desv p i j| := by
    calc ∑ j, |∑ i ∈ S, desv p i j| ≤ ∑ j, ∑ i ∈ S, |desv p i j| :=
          Finset.sum_le_sum fun j _ => abs_sum_le_sum_abs _ _
      _ = ∑ i ∈ S, ∑ j, |desv p i j| := Finset.sum_comm
  have hB : ∑ j, |∑ i ∈ S, desv p i j| ≤ ∑ i ∈ Sᶜ, ∑ j, |desv p i j| := by
    calc ∑ j, |∑ i ∈ S, desv p i j| = ∑ j, |∑ i ∈ Sᶜ, desv p i j| := by
          exact Finset.sum_congr rfl fun j _ => by rw [hc j, abs_neg]
      _ ≤ ∑ j, ∑ i ∈ Sᶜ, |desv p i j| :=
          Finset.sum_le_sum fun j _ => abs_sum_le_sum_abs _ _
      _ = ∑ i ∈ Sᶜ, ∑ j, |desv p i j| := Finset.sum_comm
  have hsplit : ∑ i, ∑ j, |desv p i j|
      = (∑ i ∈ S, ∑ j, |desv p i j|) + (∑ i ∈ Sᶜ, ∑ j, |desv p i j|) :=
    (Finset.sum_add_sum_compl S _).symm
  have h2 : 2 * (∑ j, |∑ i ∈ S, desv p i j|) ≤ ∑ i, ∑ j, |desv p i j| := by
    linarith
  rw [rectDesv_eq_sum_col]
  linarith

/-- **Relaciones entre coeficientes, parte 1** (`prop:appD-relaciones`):
`2α ≤ β`. -/
theorem two_mul_alpha_le_beta (hp : ∀ i j, 0 ≤ p i j)
    (htot : ∑ i, ∑ j, p i j = 1) : 2 * alpha p ≤ beta p := by
  have := alpha_le_half_beta hp htot
  linarith

/-! ## `β ≤ φ` -/

/-- Acotación por fila: `∑_j |desv p i j| ≤ 2 φ P(f = i)`. -/
theorem row_abs_le_two_phi_mul (hp : ∀ i j, 0 ≤ p i j)
    (htot : ∑ i, ∑ j, p i j = 1) (i : I) :
    ∑ j, |desv p i j| ≤ 2 * phi p * fila p i := by
  set T : Finset J := Finset.univ.filter (fun j => 0 < desv p i j) with hT
  have hpos : ∑ j ∈ T, desv p i j = (1 / 2) * ∑ j, |desv p i j| :=
    sum_pos_part_half (desv p i) (desv_row_sum_zero htot i)
  have hrect : rectDesv p {i} T = (1 / 2) * ∑ j, |desv p i j| := by
    rw [rectDesv_singleton, hpos]
  have hnn : (0 : ℝ) ≤ (1 / 2) * ∑ j, |desv p i j| := by
    have h := Finset.sum_nonneg (s := (Finset.univ : Finset J))
      (f := fun j => |desv p i j|) fun j _ => abs_nonneg _
    linarith
  have hmasa : masa p {i} = fila p i := by simp [masa]
  have hle : |rectDesv p {i} T| / masa p {i} ≤ phi p :=
    Finset.le_sup' (s := (Finset.univ : Finset (Finset I × Finset J)))
      (fun ST => |rectDesv p ST.1 ST.2| / masa p ST.1) (Finset.mem_univ ({i}, T))
  rw [hrect, abs_of_nonneg hnn, hmasa] at hle
  rcases eq_or_lt_of_le (fila_nonneg hp i) with h0 | h0
  · have h0' : fila p i = 0 := h0.symm
    have hsum0 : ∑ j, p i j = 0 := h0'
    have hpz : ∀ j, p i j = 0 := fun j =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => hp i j)).mp hsum0 j (Finset.mem_univ j)
    have hz : ∀ j, desv p i j = 0 := by
      intro j
      simp [desv, hpz j, h0']
    have hzero : ∑ j, |desv p i j| = 0 := by simp [hz]
    rw [hzero, h0']
    simp
  · rw [div_le_iff₀ h0] at hle
    linarith

/-- **Relaciones entre coeficientes, parte 2** (`prop:appD-relaciones`):
`β ≤ φ`. -/
theorem beta_le_phi (hp : ∀ i j, 0 ≤ p i j)
    (htot : ∑ i, ∑ j, p i j = 1) : beta p ≤ phi p := by
  have hrow : ∀ i, ∑ j, |desv p i j| ≤ 2 * phi p * fila p i :=
    fun i => row_abs_le_two_phi_mul hp htot i
  have hsum : ∑ i, ∑ j, |desv p i j| ≤ ∑ i, 2 * phi p * fila p i :=
    Finset.sum_le_sum fun i _ => hrow i
  have hright : ∑ i, 2 * phi p * fila p i = 2 * phi p := by
    rw [← Finset.mul_sum, sum_fila htot]
    ring
  unfold beta
  rw [hright] at hsum
  linarith

/-- **Relaciones entre coeficientes** (`prop:appD-relaciones`): para todo par
de σ-álgebras, `2α ≤ β ≤ φ`. -/
theorem relaciones (hp : ∀ i j, 0 ≤ p i j) (htot : ∑ i, ∑ j, p i j = 1) :
    2 * alpha p ≤ beta p ∧ beta p ≤ phi p :=
  ⟨two_mul_alpha_le_beta hp htot, beta_le_phi hp htot⟩

end Coef

end Book.ApendiceD

namespace Book.ApendiceD

/-! ## Paso a «mixing»: `φ` ⇒ `β` ⇒ `α` -/

section MixingImpl

open Filter

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]

/-- Si `2 a k ≤ b k`, `a ≥ 0` y `b → 0`, entonces `a → 0`. -/
theorem tendsto_zero_of_two_mul_le {a b : ℕ → ℝ} (ha : ∀ k, 0 ≤ a k)
    (hab : ∀ k, 2 * a k ≤ b k) (hb : Tendsto b atTop (nhds 0)) :
    Tendsto a atTop (nhds 0) :=
  squeeze_zero (fun k => ha k) (fun k => by linarith [ha k, hab k]) hb

/-- Si `0 ≤ b ≤ c` y `c → 0`, entonces `b → 0`. -/
theorem tendsto_zero_of_le {b c : ℕ → ℝ} (hb : ∀ k, 0 ≤ b k) (hbc : ∀ k, b k ≤ c k)
    (hc : Tendsto c atTop (nhds 0)) : Tendsto b atTop (nhds 0) :=
  squeeze_zero hb hbc hc

end MixingImpl

/-! ## Coeficientes de un proceso: supremo sobre el índice temporal -/

section Familia

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]
variable {T : Type*} [Fintype T] [Nonempty T]

/-- `α(k) = sup_t α(F^t, F^{t+k})` (book: `def:appD-alpha`, supremo en el
tiempo). -/
noncomputable def alphaFam (q : T → I → J → ℝ) : ℝ :=
  (Finset.univ : Finset T).sup' Finset.univ_nonempty fun t => alpha (q t)

/-- `β(k) = sup_t β(F^t, F^{t+k})` (book: `def:appD-beta`). -/
noncomputable def betaFam (q : T → I → J → ℝ) : ℝ :=
  (Finset.univ : Finset T).sup' Finset.univ_nonempty fun t => beta (q t)

/-- `φ(k) = sup_t φ(F^t, F^{t+k})` (book: `def:appD-phi`). -/
noncomputable def phiFam (q : T → I → J → ℝ) : ℝ :=
  (Finset.univ : Finset T).sup' Finset.univ_nonempty fun t => phi (q t)

variable {q : T → I → J → ℝ}

lemma alphaFam_nonneg (hp : ∀ t i j, 0 ≤ q t i j) : 0 ≤ alphaFam q :=
  Finset.le_sup' (fun t => alpha (q t)) (Finset.mem_univ (Classical.arbitrary T)) |>.trans'
    (alpha_nonneg (hp _))

lemma betaFam_nonneg (hp : ∀ t i j, 0 ≤ q t i j) : 0 ≤ betaFam q :=
  Finset.le_sup' (fun t => beta (q t)) (Finset.mem_univ (Classical.arbitrary T)) |>.trans'
    (beta_nonneg (hp _))

/-- **`2α ≤ β` con supremo temporal** (`prop:appD-relaciones`). -/
theorem two_mul_alphaFam_le_betaFam (hp : ∀ t i j, 0 ≤ q t i j)
    (htot : ∀ t, ∑ i, ∑ j, q t i j = 1) : 2 * alphaFam q ≤ betaFam q := by
  have h : alphaFam q ≤ betaFam q / 2 := by
    refine Finset.sup'_le _ _ fun t _ => ?_
    have h1 := alpha_le_half_beta (hp t) (htot t)
    have h2 : beta (q t) ≤ betaFam q :=
      Finset.le_sup' (fun t => beta (q t)) (Finset.mem_univ t)
    linarith
  linarith

/-- **`β ≤ φ` con supremo temporal** (`prop:appD-relaciones`). -/
theorem betaFam_le_phiFam (hp : ∀ t i j, 0 ≤ q t i j)
    (htot : ∀ t, ∑ i, ∑ j, q t i j = 1) : betaFam q ≤ phiFam q := by
  refine Finset.sup'_le _ _ fun t _ => ?_
  have h1 := beta_le_phi (hp t) (htot t)
  have h2 : phi (q t) ≤ phiFam q :=
    Finset.le_sup' (fun t => phi (q t)) (Finset.mem_univ t)
  linarith

/-- **`φ`-mixing implica `β`-mixing y `α`-mixing** (el «por tanto» de
`prop:appD-relaciones`), con coeficientes `sup_t` y retardos `k : ℕ`. -/
theorem tendsto_alpha_of_tendsto_phi (qq : ℕ → T → I → J → ℝ)
    (hp : ∀ k t i j, 0 ≤ qq k t i j) (htot : ∀ k t, ∑ i, ∑ j, qq k t i j = 1)
    (hφ : Tendsto (fun k => phiFam (qq k)) atTop (nhds 0)) :
    Tendsto (fun k => alphaFam (qq k)) atTop (nhds 0) ∧
      Tendsto (fun k => betaFam (qq k)) atTop (nhds 0) := by
  have hβ : Tendsto (fun k => betaFam (qq k)) atTop (nhds 0) :=
    tendsto_zero_of_le (fun k => betaFam_nonneg (hp k))
      (fun k => betaFam_le_phiFam (hp k) (htot k)) hφ
  refine ⟨?_, hβ⟩
  exact tendsto_zero_of_two_mul_le (fun k => alphaFam_nonneg (hp k))
    (fun k => two_mul_alphaFam_le_betaFam (hp k) (htot k)) hβ

end Familia

/-! ## Mixing geométrico y la condición de Ibragimov

El libro (`cor:appD-clt-mdp`) observa que si `α(k) ≤ C ρ^k` con `0 < ρ < 1`,
entonces `∑_k α(k)^{δ/(2+δ)} < ∞` para todo `δ > 0`, que es la condición (2)
del `thm:appD-ibragimov`. Aquí se prueba esa sumabilidad. -/

section Geometrico

/-- `∑_k (C ρ^k)^a` es sumable si `0 ≤ C`, `0 < ρ < 1` y `a > 0`. -/
theorem summable_rpow_geometric {C ρ a : ℝ} (hC : 0 ≤ C) (hρ : 0 < ρ) (hρ1 : ρ < 1)
    (ha : 0 < a) : Summable (fun k : ℕ => (C * ρ ^ k) ^ a) := by
  have hρ0 : 0 ≤ ρ := hρ.le
  have hk : ∀ k : ℕ, (ρ ^ k) ^ a = (ρ ^ a) ^ k := by
    intro k
    have h1 : (ρ ^ k) ^ a = ρ ^ ((k : ℝ) * a) := by
      rw [← Real.rpow_natCast ρ k, Real.rpow_mul hρ0]
    have h2 : (ρ ^ a) ^ k = ρ ^ (a * (k : ℝ)) := by
      rw [← Real.rpow_natCast (ρ ^ a) k, Real.rpow_mul hρ0]
    rw [h1, h2, mul_comm]
  have hfun : (fun k : ℕ => (C * ρ ^ k) ^ a) = fun k => C ^ a * (ρ ^ a) ^ k := by
    funext k
    rw [Real.mul_rpow hC (pow_nonneg hρ0 k), hk k]
  have hr : 0 ≤ ρ ^ a := Real.rpow_nonneg hρ0 a
  have hr1 : ρ ^ a < 1 :=
    (Real.rpow_lt_one_iff_of_pos hρ).mpr (Or.inr ⟨hρ1, ha⟩)
  rw [hfun]
  exact (summable_geometric_of_lt_one hr hr1).mul_left _

/-- La suma explícita: `∑_k (C ρ^k)^a = C^a / (1 − ρ^a)`. -/
theorem tsum_rpow_geometric {C ρ a : ℝ} (hC : 0 ≤ C) (hρ : 0 < ρ) (hρ1 : ρ < 1)
    (ha : 0 < a) : ∑' k : ℕ, (C * ρ ^ k) ^ a = C ^ a / (1 - ρ ^ a) := by
  have hρ0 : 0 ≤ ρ := hρ.le
  have hk : ∀ k : ℕ, (ρ ^ k) ^ a = (ρ ^ a) ^ k := by
    intro k
    have h1 : (ρ ^ k) ^ a = ρ ^ ((k : ℝ) * a) := by
      rw [← Real.rpow_natCast ρ k, Real.rpow_mul hρ0]
    have h2 : (ρ ^ a) ^ k = ρ ^ (a * (k : ℝ)) := by
      rw [← Real.rpow_natCast (ρ ^ a) k, Real.rpow_mul hρ0]
    rw [h1, h2, mul_comm]
  have hfun : (fun k : ℕ => (C * ρ ^ k) ^ a) = fun k => C ^ a * (ρ ^ a) ^ k := by
    funext k
    rw [Real.mul_rpow hC (pow_nonneg hρ0 k), hk k]
  have hr : 0 ≤ ρ ^ a := Real.rpow_nonneg hρ0 a
  have hr1 : ρ ^ a < 1 :=
    (Real.rpow_lt_one_iff_of_pos hρ).mpr (Or.inr ⟨hρ1, ha⟩)
  rw [hfun, tsum_mul_left, tsum_geometric_of_lt_one hr hr1, div_eq_mul_inv]

/-- **Condición de Ibragimov bajo mixing geométrico** (`cor:appD-clt-mdp`):
si `0 ≤ α(k) ≤ C ρ^k` con `0 < ρ < 1`, entonces
`∑_k α(k)^{δ/(2+δ)} < ∞` para todo `δ > 0`, con la cota explícita
`C^{δ/(2+δ)}/(1−ρ^{δ/(2+δ)})`. -/
theorem summable_rpow_of_geometric {α : ℕ → ℝ} {C ρ δ : ℝ}
    (hα0 : ∀ k, 0 ≤ α k) (hα : ∀ k, α k ≤ C * ρ ^ k)
    (hC : 0 ≤ C) (hρ : 0 < ρ) (hρ1 : ρ < 1) (hδ : 0 < δ) :
    Summable (fun k : ℕ => (α k) ^ (δ / (2 + δ))) := by
  have ha : 0 < δ / (2 + δ) := by positivity
  refine Summable.of_nonneg_of_le (fun k => Real.rpow_nonneg (hα0 k) _) (fun k => ?_)
    (summable_rpow_geometric hC hρ hρ1 ha)
  exact Real.rpow_le_rpow (hα0 k) (hα k) ha.le

end Geometrico

/-! ## Cadenas de Markov finitas: núcleo iterado e irreducibilidad -/

section Cadena

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Matriz de transición fila-estocástica. -/
structure Estocastica (P : S → S → ℝ) : Prop where
  nonneg : ∀ s s', 0 ≤ P s s'
  suma : ∀ s, ∑ s', P s s' = 1

/-- Potencias del núcleo, `pot P n = P^n` (Chapman–Kolmogorov iterado). -/
def pot (P : S → S → ℝ) : ℕ → S → S → ℝ
  | 0 => fun s s' => if s = s' then 1 else 0
  | n + 1 => fun s s' => ∑ t, pot P n s t * P t s'

lemma pot_zero (P : S → S → ℝ) (s s' : S) :
    pot P 0 s s' = if s = s' then 1 else 0 := rfl

lemma pot_succ (P : S → S → ℝ) (n : ℕ) (s s' : S) :
    pot P (n + 1) s s' = ∑ t, pot P n s t * P t s' := rfl

lemma pot_one (P : S → S → ℝ) (s s' : S) : pot P 1 s s' = P s s' := by
  show ∑ t, pot P 0 s t * P t s' = P s s'
  rw [Finset.sum_eq_single s]
  · simp [pot_zero]
  · intro b _ hb
    rw [pot_zero, if_neg (fun h : s = b => hb h.symm), zero_mul]
  · intro h; exact absurd (Finset.mem_univ s) h

lemma pot_nonneg {P : S → S → ℝ} (hP : ∀ s s', 0 ≤ P s s') :
    ∀ (n : ℕ) (s s' : S), 0 ≤ pot P n s s'
  | 0, s, s' => by
      rw [pot_zero]; split <;> norm_num
  | n + 1, s, s' => by
      rw [pot_succ]
      exact Finset.sum_nonneg fun t _ => mul_nonneg (pot_nonneg hP n s t) (hP t s')

/-- Chapman–Kolmogorov: `P^{m+n} = P^m P^n`. -/
lemma pot_add {P : S → S → ℝ} (m n : ℕ) (s s' : S) :
    pot P (m + n) s s' = ∑ t, pot P m s t * pot P n t s' := by
  induction n generalizing s' with
  | zero =>
    show pot P m s s' = ∑ t, pot P m s t * (if t = s' then 1 else 0)
    rw [Finset.sum_eq_single s']
    · simp
    · intro b _ hb
      rw [if_neg (fun h : b = s' => hb h), mul_zero]
    · intro h; exact absurd (Finset.mem_univ s') h
  | succ n ih =>
    calc pot P (m + (n + 1)) s s'
        = ∑ t, pot P (m + n) s t * P t s' := by rw [Nat.add_succ, pot_succ]
      _ = ∑ t, (∑ u, pot P m s u * pot P n u t) * P t s' := by simp only [ih]
      _ = ∑ t, ∑ u, (pot P m s u * pot P n u t) * P t s' := by
            refine Finset.sum_congr rfl fun t _ => ?_
            rw [Finset.sum_mul]
      _ = ∑ u, ∑ t, (pot P m s u * pot P n u t) * P t s' := Finset.sum_comm
      _ = ∑ u, pot P m s u * ∑ t, pot P n u t * P t s' := by
            refine Finset.sum_congr rfl fun u _ => ?_
            rw [Finset.mul_sum]
            refine Finset.sum_congr rfl fun t _ => ?_
            ring
      _ = ∑ u, pot P m s u * pot P (n + 1) u s' := by
            refine Finset.sum_congr rfl fun u _ => ?_
            rw [pot_succ]

/-- Arista del grafo de transiciones positivas. -/
def arista (P : S → S → ℝ) (s s' : S) : Prop := 0 < P s s'

lemma reach_of_pot {P : S → S → ℝ} (hP : ∀ s s', 0 ≤ P s s') :
    ∀ (n : ℕ) (s s' : S), 0 < pot P n s s' → Relation.ReflTransGen (arista P) s s' := by
  intro n
  induction n with
  | zero =>
    intro s s' h
    by_cases hs : s = s'
    · subst hs; exact Relation.ReflTransGen.refl
    · rw [pot_zero, if_neg hs] at h; exact absurd h (lt_irrefl 0)
  | succ n ih =>
    intro s s' h
    rw [pot_succ, Finset.sum_pos_iff_of_nonneg (s := Finset.univ)
      (fun t _ => mul_nonneg (pot_nonneg hP n s t) (hP t s'))] at h
    obtain ⟨t, -, ht⟩ := h
    have h1 : 0 < pot P n s t := pos_of_mul_pos_left ht (hP t s')
    have h2 : 0 < P t s' := pos_of_mul_pos_right ht (pot_nonneg hP n s t)
    exact (ih s t h1).tail h2

lemma pot_of_reach {P : S → S → ℝ} (hP : ∀ s s', 0 ≤ P s s') (s : S) :
    ∀ s', Relation.ReflTransGen (arista P) s s' → ∃ n, 0 < pot P n s s' := by
  intro s' h
  induction h with
  | refl => exact ⟨0, by simp [pot_zero]⟩
  | tail _ hbc ih =>
    obtain ⟨n, hn⟩ := ih
    refine ⟨n + 1, ?_⟩
    rw [pot_succ]
    exact Finset.sum_pos' (fun t _ =>
      mul_nonneg (pot_nonneg hP n s t) (hP t _)) ⟨_, Finset.mem_univ _, mul_pos hn hbc⟩

/-- **Cadena irreducible** (book: `prop:appD-verificacion`): de todo estado a
todo estado se llega con probabilidad positiva en algún número de pasos.
Convención `n ≥ 0` (Norris, *Markov Chains*, §1.2): para `s = s'` la condición
es trivial. -/
def Irreducible (P : S → S → ℝ) : Prop := ∀ s s', ∃ n, 0 < pot P n s s'

/-- El grafo de transiciones positivas es **fuertemente conexo**. -/
def FuertementeConexo (P : S → S → ℝ) : Prop := ∀ s s', Relation.ReflTransGen (arista P) s s'

/-- Todo estado tiene una arista saliente (consecuencia de ser estocástica). -/
lemma exists_arista {P : S → S → ℝ} (hP : Estocastica P) (s : S) : ∃ t, arista P s t := by
  by_contra hc
  push Not at hc
  have hzero : ∑ s', P s s' = 0 :=
    Finset.sum_eq_zero fun s' _ => le_antisymm (not_lt.mp (hc s')) (hP.nonneg s s')
  rw [hP.suma s] at hzero
  norm_num at hzero

/-- Transporte de `ReflTransGen` a lo largo de una equivalencia de relaciones. -/
lemma reflTransGen_of_iff {r p : S → S → Prop} (h : ∀ a b, r a b ↔ p a b) :
    ∀ a b, Relation.ReflTransGen r a b → Relation.ReflTransGen p a b := by
  intro a b hab
  induction hab with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hbc ih => exact ih.tail ((h _ _).mp hbc)

lemma iff_of_reflTransGen {r p : S → S → Prop} (h : ∀ a b, r a b ↔ p a b) :
    ∀ a b, Relation.ReflTransGen p a b → Relation.ReflTransGen r a b := by
  intro a b hab
  induction hab with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hbc ih => exact ih.tail ((h _ _).mpr hbc)

/-- **Verificación de irreducibilidad** (`prop:appD-verificacion`): una cadena
estocástica es irreducible si y sólo si el grafo dirigido con aristas
`(s,s')` donde `P s s' > 0` es fuertemente conexo. -/
theorem irreducible_iff_fuertementeConexo {P : S → S → ℝ} (hP : Estocastica P) :
    Irreducible P ↔ FuertementeConexo P := by
  constructor
  · rintro h s s'
    obtain ⟨n, hn⟩ := h s s'
    exact reach_of_pot hP.nonneg n s s' hn
  · intro h s s'
    exact pot_of_reach hP.nonneg s s' (h s s')

/-- Núcleo inducido por una política estacionaria `π` y un núcleo de MDP `P`:
`Q s s' = ∑_a π(a|s) P(s'|s,a)` (book: `prop:appD-verificacion`). -/
def inducido {A : Type*} [Fintype A] (π : S → A → ℝ) (P : S → A → S → ℝ) (s s' : S) : ℝ :=
  ∑ a, π s a * P s a s'

/-- La arista positiva del núcleo inducido es la de alguna acción de
probabilidad positiva: `Q s s' > 0 ↔ ∃ a, π(a|s) > 0 ∧ P(s'|s,a) > 0`. -/
lemma inducido_pos_iff {A : Type*} [Fintype A] (π : S → A → ℝ) (P : S → A → S → ℝ)
    (hπ : ∀ s a, 0 ≤ π s a) (hP : ∀ s a s', 0 ≤ P s a s') (s s' : S) :
    0 < inducido π P s s' ↔ ∃ a, 0 < π s a ∧ 0 < P s a s' := by
  rw [inducido, Finset.sum_pos_iff_of_nonneg (s := Finset.univ)
    (fun a _ => mul_nonneg (hπ s a) (hP s a s'))]
  constructor
  · rintro ⟨a, -, ha⟩
    exact ⟨a, pos_of_mul_pos_left ha (hP s a s'), pos_of_mul_pos_right ha (hπ s a)⟩
  · rintro ⟨a, ha, hb⟩
    exact ⟨a, Finset.mem_univ a, mul_pos ha hb⟩

/-- **Irreducibilidad de la cadena inducida por la política**
(`prop:appD-verificacion`, forma MDP): la cadena inducida es irreducible si y
sólo si es fuertemente conexo el grafo con aristas `(s,s')` tales que
`∑_a π(a|s) P(s'|s,a) > 0`. -/
theorem mdp_irreducible_iff {A : Type*} [Fintype A]
    (π : S → A → ℝ) (P : S → A → S → ℝ)
    (Q : S → S → ℝ) (hQ : ∀ s s', Q s s' = inducido π P s s')
    (hπ : ∀ s a, 0 ≤ π s a) (hPa : ∀ s a s', 0 ≤ P s a s')
    (hQe : Estocastica Q) :
    Irreducible Q ↔
      ∀ s s', Relation.ReflTransGen (fun a b => ∃ c, 0 < π a c ∧ 0 < P a c b) s s' := by
  rw [irreducible_iff_fuertementeConexo hQe]
  have harista : ∀ a b : S, arista Q a b ↔ ∃ c, 0 < π a c ∧ 0 < P a c b := by
    intro a b
    rw [arista, hQ a b, inducido_pos_iff π P hπ hPa]
  exact ⟨fun h s s' => reflTransGen_of_iff harista s s' (h s s'),
    fun h s s' => iff_of_reflTransGen harista s s' (h s s')⟩

end Cadena

/-! ## Aperiodicidad en cadenas finitas irreducibles -/

section Aperiodicidad

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- Un autolazo positivo sobrevive a toda iteración: `pot P m v v > 0`. -/
lemma pot_self_pos {P : S → S → ℝ} (hP : Estocastica P) {v : S} (hv : 0 < P v v) :
    ∀ m : ℕ, 0 < pot P m v v
  | 0 => by simp [pot_zero]
  | m + 1 => by
      rw [pot_succ]
      exact lt_of_lt_of_le (mul_pos (pot_self_pos hP hv m) hv)
        (Finset.single_le_sum
          (f := fun t => pot P m v t * P t v)
          (fun t _ => mul_nonneg (pot_nonneg hP.nonneg m v t) (hP.nonneg t v))
          (Finset.mem_univ v))

/-- **Verificación de aperiodicidad** (`prop:appD-aperiodicidad`), forma
finita: en una cadena irreducible y estocástica, un autolazo `P v v > 0`
implica **período uno para toda la cadena**, es decir: para todo par de
estados `s, s'` todas las longitudes de transición suficientemente grandes
tienen probabilidad positiva. (Equivale a `gcd{k ≥ 1 : P^k(s,s) > 0} = 1` para
todo `s`; el `gcd` de la definición del libro se reescribe aquí por su
consecuencia operativa «finalmente todo `n` es posible», que es lo que usan la
ergodicidad geométrica y el CLT.) -/
theorem aperiodic_of_selfloop {P : S → S → ℝ} (hP : Estocastica P) (hirr : Irreducible P)
    {v : S} (hv : 0 < P v v) :
    ∀ s s' : S, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 0 < pot P n s s' := by
  choose a ha using fun s => hirr s v
  choose b hb using fun s' => hirr v s'
  intro s s'
  refine ⟨Finset.univ.sup a + Finset.univ.sup b, fun n hn => ?_⟩
  have ha_le : a s ≤ Finset.univ.sup a := Finset.le_sup (Finset.mem_univ s)
  have hb_le : b s' ≤ Finset.univ.sup b := Finset.le_sup (Finset.mem_univ s')
  have hm : n = a s + ((n - a s - b s') + b s') := by omega
  have hvself : 0 < pot P (n - a s - b s') v v := pot_self_pos hP hv _
  -- segundo tramo: de `v` a `s'` en `(n - a - b) + b` pasos
  have h2 : 0 < pot P ((n - a s - b s') + b s') v s' := by
    rw [pot_add]
    exact lt_of_lt_of_le (mul_pos hvself (hb s'))
      (Finset.single_le_sum
        (f := fun t => pot P (n - a s - b s') v t * pot P (b s') t s')
        (fun t _ => mul_nonneg (pot_nonneg hP.nonneg _ v t) (pot_nonneg hP.nonneg _ t s'))
        (Finset.mem_univ v))
  rw [hm, pot_add]
  exact lt_of_lt_of_le (mul_pos (ha s) h2)
    (Finset.single_le_sum
      (f := fun t => pot P (a s) s t * pot P ((n - a s - b s') + b s') t s')
      (fun t _ => mul_nonneg (pot_nonneg hP.nonneg _ s t) (pot_nonneg hP.nonneg _ t s'))
      (Finset.mem_univ v))

/-- Corolario: con un autolazo positivo, los tiempos de retorno a cualquier
estado son finalmente todos posibles (período uno en todo estado). -/
theorem return_eventually_pos {P : S → S → ℝ} (hP : Estocastica P) (hirr : Irreducible P)
    {v : S} (hv : 0 < P v v) (s : S) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 0 < pot P n s s :=
  aperiodic_of_selfloop hP hirr hv s s

end Aperiodicidad

/-! ## Fidelidad: la definición de β del libro coincide con `½∑|desv|` -/

section FidelidadBeta

variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq I] [DecidableEq J]

/-- El libro define `β(F,G) = E[sup_{B∈G} |P(B|F) − P(B)|]`. En espacio finito,
sobre cada átomo `i` de masa positiva, el supremo sobre los eventos de `σ(g)`
(que son las uniones de átomos `j`) vale exactamente
`½∑_j |desv p i j| / P(f = i)`, de modo que
`β = ∑_i P(f=i)·(½∑_j|desv|/P(f=i)) = ½∑_{i,j}|desv p i j|`, que es la
`beta` definida arriba. -/
theorem beta_libro_atomo {p : I → J → ℝ} (hp : ∀ i j, 0 ≤ p i j)
    (htot : ∑ i, ∑ j, p i j = 1) {i : I} (hi : 0 < fila p i) :
    (∀ T : Finset J,
        |rectDesv p {i} T| / fila p i ≤ (1 / 2) * (∑ j, |desv p i j|) / fila p i) ∧
      (∃ T : Finset J,
        |rectDesv p {i} T| / fila p i = (1 / 2) * (∑ j, |desv p i j|) / fila p i) := by
  have hzero := desv_row_sum_zero htot i
  constructor
  · intro T
    rw [rectDesv_singleton]
    exact div_le_div_of_nonneg_right (abs_sum_subset_le_half (desv p i) hzero T) hi.le
  · refine ⟨Finset.univ.filter (fun j => 0 < desv p i j), ?_⟩
    rw [rectDesv_singleton, sum_pos_part_half (desv p i) hzero, abs_of_nonneg]
    have hnn : (0 : ℝ) ≤ ∑ j, |desv p i j| :=
      Finset.sum_nonneg fun j _ => abs_nonneg _
    positivity

end FidelidadBeta
