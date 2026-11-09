import Mathlib

/-!
# Book.Cap03LaiRobbinsM7 — cota asintótica de Lai–Robbins (bandidos Bernoulli)

`thm:ch8-lai-robbins` (`capitulos/cap03_mdp.typ:159`), clave `thm:ch8-lai-robbins`:

> Considérese la familia de bandidos Bernoulli con medias en `(0,1)` y mejor brazo
> único. Una política uniformemente eficiente satisface `R_T = o(T^α)` para todo
> `α > 0` en cada instancia de la familia. La cota de tipo Lai–Robbins es
> `liminf_{T→∞} R_T / log T ≥ Σ_{a: Δ_a>0} Δ_a / kl(μ_a, μ*)`,
> donde `kl(p,q) = p log(p/q) + (1-p) log((1-p)/(1-q))`.

## Fidelidad (qué se demuestra y qué se toma como hipótesis)

El libro remite la demostración por cambio de medida a `lai1985asymptotically` y
`lattimore2020bandit`. Este módulo formaliza, sin `sorry`:

1. **La función `kl` del enunciado** (`klBern`), exactamente
   `kl(p,q) = p log(p/q) + (1-p) log((1-p)/(1-q))`, y el hecho de que es la
   divergencia KL entre las leyes de Bernoulli de medias `p` y `q`
   (`klBern_eq_sum`: `Σ_{x∈{0,1}} P_p(x) log(P_p(x)/P_q(x)) = kl(p,q)`).
2. **El denominador de la cota está bien definido y es estrictamente positivo**:
   `kl(p,q) ≥ 0` (`klBern_nonneg`, desigualdad de Gibbs vía `log x ≤ x-1`) y
   `p ≠ q → kl(p,q) > 0` (`klBern_pos`). Con mejor brazo único, `Δ_a > 0` para
   todo brazo subóptimo, de modo que cada sumando `Δ_a/kl(μ_a,μ*)` del enunciado
   es finito y positivo (`laiRobbinsConst_pos`).
3. **La descomposición del pseudorregret** `R_T = Σ_a Δ_a E[N_a(T)]`
   (`def:ch8-mab`), incluida la reducción a brazos subóptimos
   (`pseudoregret_eq_sum_erase`).
4. **El paso de eficiencia uniforme de la primera frase del enunciado**: si
   `R_T = o(T^α)` para todo `α > 0`, todo brazo subóptimo se juega `o(T)` veces,
   `E[N_a(T)]/T → 0` (`arm_sublinear_of_uniformlyEfficient`). Es el paso de
   Markov del argumento de cambio de medida.
5. **El ensamblaje del enunciado**: de la cota por brazo
   `E[N_a(T)] ≥ (1-ε) log T / kl(μ_a,μ*)` (conclusión del cambio de medida
   adaptativo: cada extracción del brazo `a` compra `kl(μ_a,μ*)` nats de
   información, cf. `klBern_eq_sum`) se deduce la cota global de Lai–Robbins en
   forma épsilon (`lai_robbins`), equivalente al `liminf` del libro porque
   `R_T ≥ 0` y `log T → ∞`.

Se toma como hipótesis explícita `CambioDeMedida` = la cota por brazo que el
libro cita de `lai1985asymptotically`; todo lo demás —KL Bernoulli, positividad
estricta del denominador, descomposición del pseudorregret, consecuencia de la
eficiencia uniforme y ensamblaje de la suma— queda demostrado. Cero `sorry`;
axiomas ⊆ {propext, Classical.choice, Quot.sound}.
-/

set_option linter.unusedVariables false
set_option maxHeartbeats 1000000

open Finset BigOperators Filter
open scoped Topology

namespace Cap03M7

/-! ## La divergencia `kl` de Bernoulli del enunciado -/

/-- `kl(p,q) = p log(p/q) + (1-p) log((1-p)/(1-q))`, la fórmula de
`thm:ch8-lai-robbins` (divergencia KL entre Bernoulli(p) y Bernoulli(q)). -/
noncomputable def klBern (p q : ℝ) : ℝ :=
  p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-- `kl(p,p) = 0`: dos brazos con la misma media son indistinguibles. -/
theorem klBern_self {p : ℝ} (hp : 0 < p) (hp1 : p < 1) : klBern p p = 0 := by
  have hp0 : p ≠ 0 := ne_of_gt hp
  have h1p : (1 : ℝ) - p ≠ 0 := by intro h; linarith
  simp [klBern, hp0, h1p]

/-- Desigualdad de Gibbs (caso Bernoulli): `kl(p,q) ≥ 0` para `p,q ∈ (0,1)`.
Se prueba con `log x ≤ x - 1` aplicado a `q/p` y a `(1-q)/(1-p)`. -/
theorem klBern_nonneg {p q : ℝ} (hp : 0 < p) (hp1 : p < 1) (hq : 0 < q) (hq1 : q < 1) :
    0 ≤ klBern p q := by
  have hp0 : p ≠ 0 := ne_of_gt hp
  have hq0 : q ≠ 0 := ne_of_gt hq
  have h1p : 0 < 1 - p := by linarith
  have h1q : 0 < 1 - q := by linarith
  have h1 : p * Real.log (p / q) = -(p * Real.log (q / p)) := by
    rw [Real.log_div hp0 hq0, Real.log_div hq0 hp0]; ring
  have h2 : (1 - p) * Real.log ((1 - p) / (1 - q))
      = -((1 - p) * Real.log ((1 - q) / (1 - p))) := by
    rw [Real.log_div (ne_of_gt h1p) (ne_of_gt h1q),
      Real.log_div (ne_of_gt h1q) (ne_of_gt h1p)]; ring
  have b1 : p * Real.log (q / p) ≤ q - p := by
    have h := Real.log_le_sub_one_of_pos (x := q / p) (by positivity)
    have hm := mul_le_mul_of_nonneg_left h (le_of_lt hp)
    have he : p * (q / p - 1) = q - p := by field_simp
    linarith
  have b2 : (1 - p) * Real.log ((1 - q) / (1 - p)) ≤ p - q := by
    have h := Real.log_le_sub_one_of_pos (x := (1 - q) / (1 - p)) (by positivity)
    have hm := mul_le_mul_of_nonneg_left h (le_of_lt h1p)
    have he : (1 - p) * ((1 - q) / (1 - p) - 1) = p - q := by field_simp; ring
    linarith
  rw [klBern, h1, h2]
  linarith

/-- Estricta: si las medias difieren, `kl(p,q) > 0`. Es lo que hace finitos y
positivos los sumandos `Δ_a/kl(μ_a,μ*)` del enunciado. -/
theorem klBern_pos {p q : ℝ} (hp : 0 < p) (hp1 : p < 1) (hq : 0 < q) (hq1 : q < 1)
    (hne : p ≠ q) : 0 < klBern p q := by
  have hp0 : p ≠ 0 := ne_of_gt hp
  have h1p : 0 < 1 - p := by linarith
  have h1q : 0 < 1 - q := by linarith
  have hqp : q / p ≠ 1 := by
    intro h
    exact hne ((div_eq_one_iff_eq hp0).mp h).symm
  have hp1q : (1 - q) / (1 - p) ≠ 1 := by
    intro h
    rw [div_eq_one_iff_eq (ne_of_gt h1p)] at h
    exact hne (by linarith)
  have h1 : p * Real.log (p / q) = -(p * Real.log (q / p)) := by
    rw [Real.log_div hp0 (ne_of_gt hq), Real.log_div (ne_of_gt hq) hp0]; ring
  have h2 : (1 - p) * Real.log ((1 - p) / (1 - q))
      = -((1 - p) * Real.log ((1 - q) / (1 - p))) := by
    rw [Real.log_div (ne_of_gt h1p) (ne_of_gt h1q),
      Real.log_div (ne_of_gt h1q) (ne_of_gt h1p)]; ring
  have b1 : p * Real.log (q / p) < q - p := by
    have h := Real.log_lt_sub_one_of_pos (x := q / p) (by positivity) hqp
    have hm := mul_lt_mul_of_pos_left h hp
    have he : p * (q / p - 1) = q - p := by field_simp
    linarith
  have b2 : (1 - p) * Real.log ((1 - q) / (1 - p)) < p - q := by
    have h := Real.log_lt_sub_one_of_pos (x := (1 - q) / (1 - p)) (by positivity) hp1q
    have hm := mul_lt_mul_of_pos_left h h1p
    have he : (1 - p) * ((1 - q) / (1 - p) - 1) = p - q := by field_simp; ring
    linarith
  rw [klBern, h1, h2]
  linarith

/-- Masa de Bernoulli de media `p` en el resultado `x`. -/
noncomputable def bernMass (p : ℝ) (x : Bool) : ℝ := if x then p else 1 - p

/-- `kl(p,q)` es la KL entre las dos leyes de Bernoulli: la información que da
**una** extracción del brazo `a` sobre si su media es `p` o `q`. -/
theorem klBern_eq_sum {p q : ℝ} (hp : 0 < p) (hp1 : p < 1) (hq : 0 < q) (hq1 : q < 1) :
    ∑ x : Bool, bernMass p x * Real.log (bernMass p x / bernMass q x) = klBern p q := by
  simp [bernMass, klBern]

/-! ## Pseudorregret y brazos subóptimos -/

/-- Pseudorregret esperado del libro (`def:ch8-mab`):
`R_T = Σ_a Δ_a E[N_a(T)]` con `Δ_a = μ* - μ_a`. -/
noncomputable def pseudoregret {ι : Type*} [Fintype ι] (mu : ι → ℝ) (a₀ : ι) (N : ι → ℕ → ℝ)
    (T : ℕ) : ℝ :=
  ∑ a, (mu a₀ - mu a) * N a T

/-- La suma del enunciado se restringe a los brazos subóptimos (`Δ_a > 0`):
el término del brazo óptimo tiene `Δ_{a₀} = 0`. -/
theorem pseudoregret_eq_sum_erase {ι : Type*} [Fintype ι] [DecidableEq ι] (mu : ι → ℝ) (a₀ : ι)
    (N : ι → ℕ → ℝ) (T : ℕ) :
    pseudoregret mu a₀ N T = ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) * N a T := by
  simp only [pseudoregret]
  rw [← Finset.sum_erase_add (Finset.univ : Finset ι)
    (fun a => (mu a₀ - mu a) * N a T) (Finset.mem_univ a₀)]
  simp

/-- La constante de Lai–Robbins `Σ_{a:Δ_a>0} Δ_a/kl(μ_a,μ*)` es estrictamente
positiva cuando hay mejor brazo único y algún brazo subóptimo: cada sumando lo es. -/
theorem laiRobbinsConst_pos {ι : Type*} [Fintype ι] [DecidableEq ι] (mu : ι → ℝ) (a₀ : ι)
    (hmu : ∀ a, 0 < mu a) (hmu1 : ∀ a, mu a < 1)
    (hbest : ∀ a, a ≠ a₀ → mu a < mu a₀) (hne : ∃ a, a ≠ a₀) :
    0 < ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀) := by
  obtain ⟨b, hb⟩ := hne
  refine Finset.sum_pos' (fun a ha => ?_) ⟨b, Finset.mem_erase.mpr ⟨hb, Finset.mem_univ b⟩, ?_⟩
  · have ha' : a ≠ a₀ := (Finset.mem_erase.mp ha).1
    have hkl : 0 < klBern (mu a) (mu a₀) :=
      klBern_pos (hmu a) (hmu1 a) (hmu a₀) (hmu1 a₀) (ne_of_lt (hbest a ha'))
    exact div_nonneg (by linarith [hbest a ha']) (le_of_lt hkl)
  · have hklb : 0 < klBern (mu b) (mu a₀) :=
      klBern_pos (hmu b) (hmu1 b) (hmu a₀) (hmu1 a₀) (ne_of_lt (hbest b hb))
    exact div_pos (by linarith [hbest b hb]) hklb

/-! ## La cota por brazo del cambio de medida adaptativo -/

/-- `CambioDeMedida`: conclusión del argumento de cambio de medida adaptativo que
el libro cita (`lai1985asymptotically`, `lattimore2020bandit`).

Si se reemplaza el brazo `a` por una copia del brazo óptimo, la KL entre las
leyes de la historia de longitud `T` vale `E[N_a(T)] · kl(μ_a,μ*)` (regla de la
cadena; el incremento por extracción del brazo `a` es `kl(μ_a,μ*)`, cf.
`klBern_eq_sum`). La eficiencia uniforme en las dos instancias fuerza entonces
`E[N_a(T)] ≥ (1-ε) log T / kl(μ_a,μ*)` para `T` grande: hacen falta del orden de
`log T / kl(μ_a,μ*)` extracciones para acumular los nats que separan las dos
instancias con error que tiende a cero. Esta es la cota que se postula. -/
def CambioDeMedida {ι : Type*} (mu : ι → ℝ) (a₀ : ι) (N : ι → ℕ → ℝ) : Prop :=
  ∀ a, a ≠ a₀ → ∀ ε : ℝ, 0 < ε → ∀ᶠ T : ℕ in atTop,
    (1 - ε) * Real.log T / klBern (mu a) (mu a₀) ≤ N a T

/-! ## Primera frase del enunciado: eficiencia uniforme ⟹ brazos o(T) -/

/-- Política uniformemente eficiente: `R_T = o(T^α)` para todo `α > 0`. -/
def UniformementeEficiente (R : ℕ → ℝ) : Prop :=
  ∀ α : ℝ, 0 < α → Tendsto (fun T : ℕ => R T / (T : ℝ) ^ α) atTop (𝓝 0)

/-- De la eficiencia uniforme (con `α = 1`) se sigue que cada brazo subóptimo se
juega `o(T)` veces: `Δ_a E[N_a(T)] ≤ R_T` y `Δ_a > 0`. Es el paso de Markov que
usa el cambio de medida para asegurar que bajo la instancia modificada el brazo
modificado es (casi) el único candidato. -/
theorem arm_sublinear_of_uniformlyEfficient {ι : Type*} [Fintype ι] {mu : ι → ℝ}
    {a₀ : ι} {N : ι → ℕ → ℝ} {R : ℕ → ℝ}
    (hR : ∀ T, R T = pseudoregret mu a₀ N T)
    (hΔ0 : ∀ a, 0 ≤ mu a₀ - mu a)
    (hN : ∀ a T, 0 ≤ N a T)
    {a : ι} (hΔ : 0 < mu a₀ - mu a)
    (hUnif : UniformementeEficiente R) :
    Tendsto (fun T : ℕ => N a T / (T : ℝ)) atTop (𝓝 0) := by
  have hR1 : Tendsto (fun T : ℕ => R T / (T : ℝ)) atTop (𝓝 0) := by
    have h := hUnif 1 one_pos
    simpa using h
  have hquot : Tendsto (fun T : ℕ => (R T / (T : ℝ)) / (mu a₀ - mu a)) atTop (𝓝 0) := by
    simpa using hR1.div_const (mu a₀ - mu a)
  refine squeeze_zero' (Eventually.of_forall (fun T => div_nonneg (hN a T) (by positivity))) ?_ hquot
  filter_upwards [eventually_ge_atTop 1] with T hT
  have hTpos : (0 : ℝ) < (T : ℝ) := by
    have h1 : (1 : ℕ) ≤ T := hT
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one h1
  have hle : (mu a₀ - mu a) * N a T ≤ pseudoregret mu a₀ N T := by
    refine Finset.single_le_sum (s := (Finset.univ : Finset ι))
      (f := fun b => (mu a₀ - mu b) * N b T) ?_ (Finset.mem_univ a)
    intro b _
    exact mul_nonneg (hΔ0 b) (hN b T)
  rw [← hR T] at hle
  rw [div_div,
    div_le_div_iff₀ (by positivity : (0 : ℝ) < (T : ℝ))
      (by positivity : (0 : ℝ) < (T : ℝ) * (mu a₀ - mu a))]
  nlinarith [hle, hTpos]

/-! ## Ensamblaje: la cota de Lai–Robbins -/

/-- **`thm:ch8-lai-robbins`** — book: capitulos/cap03_mdp.typ:159 (key: thm:ch8-lai-robbins).
Cota asintótica en bandidos Bernoulli con mejor brazo único: de las cotas por
brazo `E[N_a(T)] ≥ (1-ε) log T / kl(μ_a,μ*)` (cambio de medida adaptativo) se
sigue la cota tipo Lai–Robbins sobre el pseudorregret,

`R_T ≥ (1-ε) · (Σ_{a≠a₀} Δ_a/kl(μ_a,μ*)) · log T` para `T` grande,

que es la forma épsilon de `liminf_T R_T/log T ≥ Σ_{a:Δ_a>0} Δ_a/kl(μ_a,μ*)`. -/
theorem lai_robbins {ι : Type*} [Fintype ι] [DecidableEq ι] (mu : ι → ℝ) (a₀ : ι) (N : ι → ℕ → ℝ)
    (hmu : ∀ a, 0 < mu a) (hmu1 : ∀ a, mu a < 1)
    (hbest : ∀ a, a ≠ a₀ → mu a < mu a₀)
    (hcm : CambioDeMedida mu a₀ N) :
    ∀ ε : ℝ, 0 < ε → ∀ᶠ T : ℕ in atTop,
      (1 - ε) * (∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀))
          * Real.log T ≤ pseudoregret mu a₀ N T := by
  intro ε hε
  have hall : ∀ᶠ T : ℕ in atTop,
      ∀ a ∈ Finset.univ.erase a₀,
        (1 - ε) * Real.log T / klBern (mu a) (mu a₀) ≤ N a T := by
    have h : ∀ a ∈ Finset.univ.erase a₀,
        ∀ᶠ T : ℕ in atTop,
          (1 - ε) * Real.log T / klBern (mu a) (mu a₀) ≤ N a T := by
      intro a ha
      exact hcm a (Finset.mem_erase.mp ha).1 ε hε
    exact (Finset.eventually_all (Finset.univ.erase a₀)).mpr h
  filter_upwards [hall] with T hT
  have hterm : ∀ a ∈ Finset.univ.erase a₀,
      (mu a₀ - mu a) * ((1 - ε) * Real.log T / klBern (mu a) (mu a₀))
        ≤ (mu a₀ - mu a) * N a T := by
    intro a ha
    have ha' : a ≠ a₀ := (Finset.mem_erase.mp ha).1
    have hΔ : 0 ≤ mu a₀ - mu a := by linarith [hbest a ha']
    exact mul_le_mul_of_nonneg_left (hT a ha) hΔ
  have hsum : ∑ a ∈ Finset.univ.erase a₀,
        (mu a₀ - mu a) * ((1 - ε) * Real.log T / klBern (mu a) (mu a₀))
      ≤ ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) * N a T :=
    Finset.sum_le_sum hterm
  have hfac : ∑ a ∈ Finset.univ.erase a₀,
        (mu a₀ - mu a) * ((1 - ε) * Real.log T / klBern (mu a) (mu a₀))
      = ((1 - ε) * Real.log T)
          * ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro a ha
    have ha' : a ≠ a₀ := (Finset.mem_erase.mp ha).1
    have hkl : klBern (mu a) (mu a₀) ≠ 0 :=
      ne_of_gt (klBern_pos (hmu a) (hmu1 a) (hmu a₀) (hmu1 a₀) (ne_of_lt (hbest a ha')))
    field_simp
  calc ((1 - ε) * (∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀)))
        * Real.log T
      = ((1 - ε) * Real.log T)
          * ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀) := by ring
    _ = ∑ a ∈ Finset.univ.erase a₀,
          (mu a₀ - mu a) * ((1 - ε) * Real.log T / klBern (mu a) (mu a₀)) := hfac.symm
    _ ≤ ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) * N a T := hsum
    _ = pseudoregret mu a₀ N T := (pseudoregret_eq_sum_erase mu a₀ N T).symm


/-! ## La forma literal `liminf`

`liminf_T R_T/log T ≥ S` significa: toda constante `c < S` queda por debajo de
`R_T/log T` para `T` grande. Eso es lo que se demuestra aquí a partir de
`lai_robbins`, con `S = Σ_{a:Δ_a>0} Δ_a/kl(μ_a,μ*)`. -/

/-- Forma `liminf` de `thm:ch8-lai-robbins` (book: capitulos/cap03_mdp.typ:159,
key: thm:ch8-lai-robbins): para toda `c` menor que la constante
de Lai–Robbins `S = Σ_{a≠a₀} Δ_a/kl(μ_a,μ*)`, el pseudorregret satisface
`c · log T ≤ R_T` para `T` grande, es decir
`liminf_{T→∞} R_T / log T ≥ Σ_{a:Δ_a>0} Δ_a / kl(μ_a,μ*)`. -/
theorem lai_robbins_liminf {ι : Type*} [Fintype ι] [DecidableEq ι] (mu : ι → ℝ)
    (a₀ : ι) (N : ι → ℕ → ℝ)
    (hmu : ∀ a, 0 < mu a) (hmu1 : ∀ a, mu a < 1)
    (hbest : ∀ a, a ≠ a₀ → mu a < mu a₀)
    (hcm : CambioDeMedida mu a₀ N)
    (hne : ∃ a, a ≠ a₀) :
    ∀ c : ℝ, c < ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀) →
      ∀ᶠ T : ℕ in atTop, c * Real.log T ≤ pseudoregret mu a₀ N T := by
  set S := ∑ a ∈ Finset.univ.erase a₀, (mu a₀ - mu a) / klBern (mu a) (mu a₀) with hS
  have hSpos : 0 < S := laiRobbinsConst_pos mu a₀ hmu hmu1 hbest hne
  intro c hc
  set ε := (S - c) / (2 * S) with hε
  have hεpos : 0 < ε := by
    rw [hε]
    exact div_pos (by linarith) (by positivity)
  have hcS : c ≤ (1 - ε) * S := by
    have hεeq : ε * S = (S - c) / 2 := by
      rw [hε]
      field_simp
    nlinarith [hεeq, hSpos, hc]
  filter_upwards [lai_robbins mu a₀ N hmu hmu1 hbest hcm ε hεpos,
    eventually_ge_atTop 1] with T hT hT1
  have hlog : 0 ≤ Real.log T := by
    apply Real.log_nonneg
    exact_mod_cast hT1
  calc c * Real.log T ≤ ((1 - ε) * S) * Real.log T :=
        mul_le_mul_of_nonneg_right hcS hlog
    _ ≤ pseudoregret mu a₀ N T := hT

end Cap03M7
