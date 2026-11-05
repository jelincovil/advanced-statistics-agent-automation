import Mathlib
import Book.Foundation

/-!
# Book.Cap03MDP — cap. 3 del libro (capitulos/cap03_mdp.typ): MDP finito descontado

Mejora de políticas con la regla de desempate del libro (`thm:ch8-mejora`)
y terminación finita de la iteración de políticas (`cor:ch8-pi-finita`):
sin repetición, a lo sumo `|A|^|S|` políticas, y optimalidad al detenerse.

Fidelidad declarada (plan §4): estados y acciones finitos no vacíos,
kernel `P` estocástico (entradas no negativas, filas de suma 1), descuento
`0 ≤ γ < 1`, recompensa `r` acotada (automático por finitud). Las
políticas son deterministas estacionarias (la clase de la iteración de
políticas del libro).

Base no enunciada en el libro (pedida por el autor): `V^π` como serie de
Neumann `∑' t γ^t (P_π^t r_π)(s)` (la demostración del propio libro usa
`(I - γ P^π)⁻¹ d = Σ_j γ^j (P^π)^j d`), su punto fijo `V^π = T^π V^π`
(`thm:ch8-bellman-pi`), la monotonía y el desplazamiento del operador
óptimo, y el argumento del argmín (`nonneg_of_fix`).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators
open scoped Topology

set_option maxHeartbeats 1000000

universe u

section MDP

variable {S A : Type u} [Fintype S] [Nonempty S] [Fintype A] [Nonempty A]
  [DecidableEq S] (r : S → A → ℝ) (P : S → A → S → ℝ) (γ : ℝ)

/-- Matriz de transición de la política determinista `π`. -/
def pmat (π : S → A) : S → S → ℝ := fun s s' => P s (π s) s'

/-- Vector de recompensa de la política `π`. -/
def rvec (π : S → A) : S → ℝ := fun s => r s (π s)

/-- Producto matriz–vector. -/
def mvec (M : S → S → ℝ) (v : S → ℝ) (s : S) : ℝ := ∑ s', M s s' * v s'

/-- Potencia `k`-ésima de una matriz cuadrada. -/
def mpow (M : S → S → ℝ) : ℕ → S → S → ℝ
  | 0 => fun s s' => if s = s' then 1 else 0
  | (k + 1) => fun s s' => ∑ s'', M s s'' * mpow M k s'' s'

private theorem pmat_nonneg (hP0 : ∀ s a s', 0 ≤ P s a s') (π : S → A) :
    ∀ s s', 0 ≤ pmat P π s s' := fun s s' => hP0 s (π s) s'

private theorem pmat_row_sum (hP1 : ∀ s a, ∑ s', P s a s' = 1) (π : S → A) :
    ∀ s, ∑ s', pmat P π s s' = 1 := fun s => hP1 s (π s)

private theorem mpow_nonneg (M : S → S → ℝ) (hM0 : ∀ s s', 0 ≤ M s s') :
    ∀ (k : ℕ) (s s' : S), 0 ≤ mpow M k s s' := by
  intro k
  induction k with
  | zero =>
      intro s s'
      by_cases h : s = s'
      · simp [mpow, h]
      · simp [mpow, h]
  | succ k ih =>
      intro s s'
      simp only [mpow]
      exact Finset.sum_nonneg fun s'' _ => mul_nonneg (hM0 s s'') (ih s'' s')

private theorem mpow_row_sum (M : S → S → ℝ) (hM0 : ∀ s s', 0 ≤ M s s')
    (hM1 : ∀ s, ∑ s', M s s' = 1) :
    ∀ (k : ℕ) (s : S), ∑ s', mpow M k s s' = 1 := by
  intro k
  induction k with
  | zero => intro s; simp [mpow]
  | succ k ih =>
      intro s
      calc ∑ s', mpow M (k + 1) s s'
          = ∑ s'', M s s'' * (∑ s', mpow M k s'' s') := by
            simp only [mpow]
            rw [Finset.sum_comm]
            simp only [Finset.mul_sum]
        _ = ∑ s'', M s s'' * 1 := by simp only [ih]
        _ = 1 := by simp [hM1 s]

private theorem mvec_mpow_succ (M : S → S → ℝ) (v : S → ℝ) (t : ℕ) (s : S) :
    mvec (mpow M (t + 1)) v s = mvec M (mvec (mpow M t) v) s := by
  calc mvec (mpow M (t + 1)) v s
      = ∑ s', (∑ s'', M s s'' * mpow M t s'' s') * v s' := rfl
    _ = ∑ s', ∑ s'', M s s'' * mpow M t s'' s' * v s' := by
        refine Finset.sum_congr rfl fun s' _ => ?_
        rw [Finset.sum_mul]
    _ = ∑ s'', ∑ s', M s s'' * mpow M t s'' s' * v s' := Finset.sum_comm
    _ = ∑ s'', M s s'' * (∑ s', mpow M t s'' s' * v s') := by
        refine Finset.sum_congr rfl fun s'' _ => ?_
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun s' _ => by ring
    _ = mvec M (mvec (mpow M t) v) s := rfl

private theorem mvec_abs_bound (M : S → S → ℝ) (v : S → ℝ) (R : ℝ)
    (hM0 : ∀ s s', 0 ≤ M s s') (hM1 : ∀ s, ∑ s', M s s' = 1)
    (hv : ∀ s, |v s| ≤ R) (s : S) : |mvec M v s| ≤ R := by
  have h1 : ∀ s', |M s s' * v s'| ≤ M s s' * R := by
    intro s'
    calc |M s s' * v s'| = M s s' * |v s'| := by
          rw [abs_mul, abs_of_nonneg (hM0 s s')]
      _ ≤ M s s' * R := mul_le_mul_of_nonneg_left (hv s') (hM0 s s')
  calc |mvec M v s| ≤ ∑ s', |M s s' * v s'| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ s', M s s' * R := Finset.sum_le_sum (fun s' _ => h1 s')
    _ = R := by rw [← Finset.sum_mul, hM1 s, one_mul]

private theorem mvec_id (M : S → S → ℝ) (v : S → ℝ) (s : S) :
    mvec (mpow M 0) v s = v s := by
  simp only [mvec, mpow, ite_mul, one_mul, zero_mul]
  rw [Finset.sum_ite_eq]
  simp

/-! ### Valor de una política -/

/-- Cota uniforme de las recompensas de `π`. -/
private def rSup (π : S → A) : ℝ :=
  (univ : Finset S).sup' Finset.univ_nonempty (fun s' => |rvec r π s'|)

private theorem rSup_nonneg (π : S → A) : 0 ≤ rSup r π := by
  obtain ⟨s₀⟩ := ‹Nonempty S›
  exact le_trans (abs_nonneg (rvec r π s₀))
    (Finset.le_sup' (f := fun s' => |rvec r π s'|) (Finset.mem_univ s₀))

/-- `V^π(s) = ∑' t γ^t (P_π^t r_π)(s)`: la serie de Neumann del libro
(`(I - γ P^π)⁻¹ r^π`), aquí por definición. -/
private noncomputable def Vpi (π : S → A) : S → ℝ :=
  fun s => ∑' t : ℕ, γ ^ t * mvec (mpow (pmat P π) t) (rvec r π) s

/-- Sumando `t`-ésimo de la serie de `V^π`, como función de estado. -/
private def Vterm (π : S → A) (t : ℕ) (s : S) : ℝ :=
  γ ^ t * mvec (mpow (pmat P π) t) (rvec r π) s

private theorem Vpi_eq_tsum_Vterm (π : S → A) (s : S) :
    Vpi r P γ π s = ∑' t : ℕ, Vterm r P γ π t s := rfl

private theorem Vterm_abs (π : S → A) (hP0 : ∀ s a s', 0 ≤ P s a s')
    (hP1 : ∀ s a, ∑ s', P s a s' = 1) (hγ0 : 0 ≤ γ) (t : ℕ) (s : S) :
    |Vterm r P γ π t s| ≤ γ ^ t * rSup r π := by
  have h1 : |mvec (mpow (pmat P π) t) (rvec r π) s| ≤ rSup r π :=
    mvec_abs_bound (mpow (pmat P π) t) (rvec r π) (rSup r π)
      (mpow_nonneg _ (pmat_nonneg P hP0 π) t)
      (mpow_row_sum _ (pmat_nonneg P hP0 π) (pmat_row_sum P hP1 π) t)
      (fun s' => Finset.le_sup' (f := fun s'' => |rvec r π s''|) (Finset.mem_univ s')) s
  rw [Vterm, abs_mul, abs_of_nonneg (pow_nonneg hγ0 t)]
  exact mul_le_mul_of_nonneg_left h1 (pow_nonneg hγ0 t)

private theorem Vterm_summable (π : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (s : S) :
    Summable (fun t : ℕ => Vterm r P γ π t s) := by
  have hgeom : Summable (fun t : ℕ => γ ^ t) := summable_geometric_of_lt_one hγ0 hγ1
  have hscaled : Summable (fun t : ℕ => rSup r π * γ ^ t) :=
    Summable.const_smul (rSup r π) hgeom
  have hscaled' : Summable (fun t : ℕ => γ ^ t * rSup r π) :=
    hscaled.congr fun t => mul_comm _ _
  refine Summable.of_norm_bounded
    (f := fun t : ℕ => Vterm r P γ π t s)
    (g := fun t : ℕ => γ ^ t * rSup r π) hscaled' ?_
  intro t
  rw [Real.norm_eq_abs]
  exact Vterm_abs r P γ π hP0 hP1 hγ0 t s

private theorem mvec_Vterm_summable (π : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (s : S) :
    Summable (fun t : ℕ => mvec (pmat P π) (Vterm r P γ π t) s) := by
  have hgeom : Summable (fun t : ℕ => γ ^ t) := summable_geometric_of_lt_one hγ0 hγ1
  have hscaled : Summable (fun t : ℕ => rSup r π * γ ^ t) :=
    Summable.const_smul (rSup r π) hgeom
  have hscaled' : Summable (fun t : ℕ => γ ^ t * rSup r π) :=
    hscaled.congr fun t => mul_comm _ _
  refine Summable.of_norm_bounded
    (f := fun t : ℕ => mvec (pmat P π) (Vterm r P γ π t) s)
    (g := fun t : ℕ => γ ^ t * rSup r π) hscaled' ?_
  intro t
  have h1 : |mvec (pmat P π) (Vterm r P γ π t) s| ≤ γ ^ t * rSup r π :=
    mvec_abs_bound (pmat P π) (Vterm r P γ π t) (γ ^ t * rSup r π)
      (pmat_nonneg P hP0 π) (pmat_row_sum P hP1 π)
      (fun s' => Vterm_abs r P γ π hP0 hP1 hγ0 t s') s
  rw [Real.norm_eq_abs]
  exact h1

private theorem tsum_mul_const_left (h : Summable f) (b : ℝ) :
    ∑' t, b * f t = b * ∑' t, f t := by
  have hcs : HasSum (fun t => b • f t) (b • ∑' t, f t) :=
    HasSum.const_smul b h.hasSum
  have h' := HasSum.tsum_eq hcs
  rw [smul_eq_mul] at h'
  exact h'

/-! ### Operadores de Bellman -/

/-- Operador de Bellman de la política `π` (`def:ch8-operador` del libro). -/
def Tpol (π : S → A) (V : S → ℝ) : S → ℝ :=
  fun s => rvec r π s + γ * mvec (pmat P π) V s

/-- Operador de Bellman óptimo (`def:ch8-operador` del libro). -/
def Topt (V : S → ℝ) : S → ℝ :=
  fun s => (univ : Finset A).sup' Finset.univ_nonempty
    (fun a => r s a + γ * ∑ s', P s a s' * V s')

/-- Iterado `k`-veces del operador óptimo. -/
private def ToptIter : ℕ → (S → ℝ) → (S → ℝ)
  | 0, V => V
  | (k + 1), V => Topt r P γ (ToptIter k V)

/-- Punto fijo de Bellman de la política: `V^π = T^π V^π`
(`thm:ch8-bellman-pi`; base de `thm:ch8-mejora`). -/
private theorem Vpi_fix (π : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (s : S) :
    Vpi r P γ π s = Tpol r P γ π (Vpi r P γ π) s := by
  have hg : Summable (fun t : ℕ => Vterm r P γ π t s) :=
    Vterm_summable r P γ π hP0 hP1 hγ0 hγ1 s
  have hgm : Summable (fun t : ℕ => mvec (pmat P π) (Vterm r P γ π t) s) :=
    mvec_Vterm_summable r P γ π hP0 hP1 hγ0 hγ1 s
  have htail := Summable.sum_add_tsum_nat_add 1 hg
  simp only [Finset.range_one, Finset.sum_singleton] at htail
  have h0 : Vterm r P γ π 0 s = rvec r π s := by
    show γ ^ 0 * mvec (mpow (pmat P π) 0) (rvec r π) s = rvec r π s
    rw [pow_zero, one_mul, mvec_id]
  have hterm : ∀ t : ℕ, Vterm r P γ π (t + 1) s
      = γ * mvec (pmat P π) (Vterm r P γ π t) s := by
    intro t
    have e1 : mvec (mpow (pmat P π) (t + 1)) (rvec r π) s
        = mvec (pmat P π) (mvec (mpow (pmat P π) t) (rvec r π)) s :=
      mvec_mpow_succ _ _ t s
    show γ ^ (t + 1) * mvec (mpow (pmat P π) (t + 1)) (rvec r π) s
        = γ * mvec (pmat P π) (Vterm r P γ π t) s
    rw [e1, pow_succ]
    simp only [mvec, Vterm]
    rw [Finset.mul_sum, Finset.mul_sum]
    exact Finset.sum_congr rfl fun s' _ => by ring
  have hexch : ∑' t : ℕ, mvec (pmat P π) (Vterm r P γ π t) s
      = mvec (pmat P π) (Vpi r P γ π) s := by
    have h1 : ∀ s' : S,
        HasSum (fun t : ℕ => pmat P π s s' * Vterm r P γ π t s')
          (pmat P π s s' * ∑' t : ℕ, Vterm r P γ π t s') := by
      intro s'
      have hc := HasSum.const_smul (pmat P π s s')
        (Vterm_summable r P γ π hP0 hP1 hγ0 hγ1 s').hasSum
      rw [smul_eq_mul] at hc
      exact hc
    have h2 : HasSum (fun t : ℕ => ∑ s' : S, pmat P π s s' * Vterm r P γ π t s')
        (∑ s' : S, pmat P π s s' * ∑' t : ℕ, Vterm r P γ π t s') :=
      hasSum_sum (f := fun s'' t => pmat P π s s'' * Vterm r P γ π t s'')
        (fun s' _ => h1 s')
    simp only [mvec]
    rw [HasSum.tsum_eq h2]
    exact Finset.sum_congr rfl fun s' _ =>
      congrArg (pmat P π s s' * ·) (Vpi_eq_tsum_Vterm r P γ π s')
  calc Vpi r P γ π s
      = Vterm r P γ π 0 s + ∑' t : ℕ, Vterm r P γ π (t + 1) s := htail.symm
    _ = rvec r π s + ∑' t : ℕ, γ * mvec (pmat P π) (Vterm r P γ π t) s := by
        rw [h0]
        have hfun : (fun t : ℕ => Vterm r P γ π (t + 1) s)
            = (fun t : ℕ => γ * mvec (pmat P π) (Vterm r P γ π t) s) :=
          funext hterm
        rw [hfun]
    _ = rvec r π s + γ * ∑' t : ℕ, mvec (pmat P π) (Vterm r P γ π t) s := by
        rw [tsum_mul_const_left hgm γ]
    _ = rvec r π s + γ * mvec (pmat P π) (Vpi r P γ π) s := by rw [hexch]
    _ = Tpol r P γ π (Vpi r P γ π) s := rfl

private theorem mvec_add (M : S → S → ℝ) (v w : S → ℝ) (s : S) :
    mvec M (fun s' => v s' + w s') s = mvec M v s + mvec M w s := by
  simp only [mvec, mul_add, Finset.sum_add_distrib]

private theorem Tpol_add (π : S → A) (V W : S → ℝ) (s : S) :
    Tpol r P γ π (fun s' => V s' + W s') s
      = Tpol r P γ π V s + γ * mvec (pmat P π) W s := by
  simp only [Tpol, mvec, Finset.sum_add_distrib, mul_add]
  ring

private theorem le_Topt (π : S → A) (V : S → ℝ) (s : S) :
    Tpol r P γ π V s ≤ Topt r P γ V s :=
  Finset.le_sup' (f := fun a => r s a + γ * ∑ s', P s a s' * V s')
    (Finset.mem_univ (π s))

private theorem Topt_mono (hP0 : ∀ s a s', 0 ≤ P s a s') (hγ0 : 0 ≤ γ)
    (hVW : ∀ s, V s ≤ W s) (s : S) :
    Topt r P γ V s ≤ Topt r P γ W s := by
  have hq : ∀ a : A, r s a + γ * ∑ s', P s a s' * V s'
      ≤ r s a + γ * ∑ s', P s a s' * W s' := by
    intro a
    refine add_le_add (le_refl _) (mul_le_mul_of_nonneg_left ?_ hγ0)
    exact Finset.sum_le_sum fun s' _ =>
      mul_le_mul_of_nonneg_left (hVW s') (hP0 s a s')
  exact (Finset.sup'_le_iff Finset.univ_nonempty _).mpr
    (fun a _ => le_trans (hq a)
      (Finset.le_sup' (f := fun a' => r s a' + γ * ∑ s', P s a' s' * W s')
        (Finset.mem_univ a)))

/-- Desplazamiento del operador óptimo ante constantes aditivas. -/
private theorem Topt_add_const (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (V : S → ℝ) (d : ℝ) (s : S) :
    Topt r P γ (fun s' => V s' + d) s = Topt r P γ V s + γ * d := by
  have hterm : ∀ a : A,
      r s a + γ * ∑ s', P s a s' * (V s' + d)
        = (r s a + γ * ∑ s', P s a s' * V s') + γ * d := by
    intro a
    have hsplit : ∑ s', P s a s' * (V s' + d)
        = (∑ s', P s a s' * V s') + d := by
      calc ∑ s', P s a s' * (V s' + d)
          = (∑ s', P s a s' * V s') + (∑ s', P s a s' * d) := by
            rw [← Finset.sum_add_distrib]
            exact Finset.sum_congr rfl fun s' _ => mul_add _ _ _
        _ = (∑ s', P s a s' * V s') + d := by
            rw [← Finset.sum_mul, hP1 s a, one_mul]
    simp only [hsplit]
    ring
  have hrw : (fun a => r s a + γ * ∑ s', P s a s' * (V s' + d))
      = (fun a => (r s a + γ * ∑ s', P s a s' * V s') + γ * d) :=
    funext hterm
  show (univ : Finset A).sup' Finset.univ_nonempty
      (fun a => r s a + γ * ∑ s', P s a s' * (V s' + d))
    = (univ : Finset A).sup' Finset.univ_nonempty
      (fun a => r s a + γ * ∑ s', P s a s' * V s') + γ * d
  rw [hrw]
  refine le_antisymm ?_ ?_
  · refine (Finset.sup'_le_iff Finset.univ_nonempty _).mpr ?_
    intro a _
    exact add_le_add
      (Finset.le_sup' (f := fun a' => r s a' + γ * ∑ s', P s a' s' * V s')
        (Finset.mem_univ a)) (le_refl _)
  · have hkey : (univ : Finset A).sup' Finset.univ_nonempty
          (fun a => r s a + γ * ∑ s', P s a s' * V s')
        ≤ (univ : Finset A).sup' Finset.univ_nonempty
            (fun a => (r s a + γ * ∑ s', P s a s' * V s') + γ * d) - γ * d := by
      refine (Finset.sup'_le_iff Finset.univ_nonempty _).mpr ?_
      intro a _
      have hle : (r s a + γ * ∑ s', P s a s' * V s') + γ * d
          ≤ (univ : Finset A).sup' Finset.univ_nonempty
              (fun a => (r s a + γ * ∑ s', P s a s' * V s') + γ * d) :=
        Finset.le_sup' (f := fun a => (r s a + γ * ∑ s', P s a s' * V s') + γ * d)
          (Finset.mem_univ a)
      linarith
    linarith

/-- Argumento del argmín: si `u = d + γ·M u` con `d ≥ 0` y `M`
estocástica, entonces `u ≥ 0`. (Base no enunciada; es el corazón de
`thm:ch8-mejora`.) -/
private theorem nonneg_of_fix (u d : S → ℝ) (M : S → S → ℝ) (hγ0 : 0 ≤ γ)
    (hγ1 : γ < 1) (h : ∀ s, u s = d s + γ * mvec M u s) (hd : ∀ s, 0 ≤ d s)
    (hM0 : ∀ s s', 0 ≤ M s s') (hM1 : ∀ s, ∑ s', M s s' = 1) :
    ∀ s, 0 ≤ u s := by
  obtain ⟨s₀, -, hs₀⟩ :=
    Finset.exists_min_image (univ : Finset S) u Finset.univ_nonempty
  have h1 : u s₀ ≤ mvec M u s₀ := by
    have h2 : ∑ s', M s₀ s' * u s' ≥ ∑ s', M s₀ s' * u s₀ :=
      Finset.sum_le_sum fun s' _ =>
        mul_le_mul_of_nonneg_left (hs₀ s' (Finset.mem_univ s')) (hM0 s₀ s')
    have h3 : ∑ s', M s₀ s' * u s₀ = u s₀ := by
      rw [← Finset.sum_mul, hM1 s₀, one_mul]
    show u s₀ ≤ ∑ s', M s₀ s' * u s'
    linarith
  have h2 : u s₀ - γ * u s₀ ≥ d s₀ := by
    have hu : u s₀ = d s₀ + γ * mvec M u s₀ := h s₀
    have h3 : γ * mvec M u s₀ ≥ γ * u s₀ := mul_le_mul_of_nonneg_left h1 hγ0
    have h4 : d s₀ + γ * mvec M u s₀ ≥ d s₀ + γ * u s₀ :=
      add_le_add (le_refl _) h3
    linarith
  have h5 : 0 ≤ u s₀ := by
    have hpos : 0 < 1 - γ := by linarith
    have hexp : (1 - γ) * u s₀ = u s₀ - γ * u s₀ := by ring
    have hge : (1 - γ) * u s₀ ≥ d s₀ := by rw [hexp]; exact h2
    exact nonneg_of_mul_nonneg_right (le_trans (hd s₀) hge) hpos
  exact fun s => le_trans h5 (hs₀ s (Finset.mem_univ s))

/-! ### thm:ch8-mejora — mejora de políticas con desempate -/

/-- book: capitulos/cap03_mdp.typ:120 (key: thm:ch8-mejora) —
mejora de políticas: una política greedy `π'` respecto de `V^π` satisface
`V^{π'} ≥ V^π`; con la regla de desempate del libro (conservar la acción
actual si es maximizadora), si cambia una acción, la desigualdad es
estricta en al menos un estado. La prueba es la del libro con la serie de
Neumann explícita: `V^{π'} - V^π = (I - γP^{π'})⁻¹ d` con `d ≥ 0`; el
término `j = 0` de la serie da la mejora estricta (aquí `nonneg_of_fix`
cumple el papel de la no negatividad de la serie).
Origen: F1 2026-11-04 (nuevo). -/
theorem ch8_mejora (π π' : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hgreedy : ∀ s a, r s (π' s) + γ * ∑ s', P s (π' s) s' * Vpi r P γ π s'
      ≥ r s a + γ * ∑ s', P s a s' * Vpi r P γ π s')
    (hcambio : ∀ s, π' s ≠ π s →
      r s (π' s) + γ * ∑ s', P s (π' s) s' * Vpi r P γ π s' > Vpi r P γ π s) :
    (∀ s, Vpi r P γ π' s ≥ Vpi r P γ π s)
    ∧ ((∃ s, π' s ≠ π s) → ∃ s, Vpi r P γ π' s > Vpi r P γ π s) := by
  have hdeq : ∀ s, Vpi r P γ π' s - Vpi r P γ π s
      = (Tpol r P γ π' (Vpi r P γ π) s - Vpi r P γ π s)
        + γ * mvec (pmat P π')
            (fun s' => Vpi r P γ π' s' - Vpi r P γ π s') s := by
    intro s
    have hfix' := Vpi_fix r P γ π' hP0 hP1 hγ0 hγ1 s
    have hfun : Vpi r P γ π'
        = (fun s' => Vpi r P γ π s' + (Vpi r P γ π' s' - Vpi r P γ π s')) := by
      funext s'; ring
    have key : mvec (pmat P π') (Vpi r P γ π') s
        = mvec (pmat P π') (Vpi r P γ π) s
          + mvec (pmat P π')
              (fun s' => Vpi r P γ π' s' - Vpi r P γ π s') s := by
      have h2 : mvec (pmat P π') (Vpi r P γ π') s
          = mvec (pmat P π') (fun s' => Vpi r P γ π s'
              + (Vpi r P γ π' s' - Vpi r P γ π s')) s :=
        congrArg (fun X : S → ℝ => mvec (pmat P π') X s) hfun
      rw [h2]
      exact mvec_add (pmat P π') (Vpi r P γ π)
        (fun s' => Vpi r P γ π' s' - Vpi r P γ π s') s
    rw [hfix']
    simp only [Tpol]
    rw [key]
    ring
  have hd0 : ∀ s, 0 ≤ Tpol r P γ π' (Vpi r P γ π) s - Vpi r P γ π s := by
    intro s
    have hg := hgreedy s (π s)
    have hfix := Vpi_fix r P γ π hP0 hP1 hγ0 hγ1 s
    rw [hfix]
    show 0 ≤ (r s (π' s) + γ * ∑ s', P s (π' s) s' * Vpi r P γ π s')
        - (r s (π s) + γ * ∑ s', P s (π s) s' * Vpi r P γ π s')
    linarith
  have hu0 : ∀ s, 0 ≤ Vpi r P γ π' s - Vpi r P γ π s :=
    nonneg_of_fix γ (fun s => Vpi r P γ π' s - Vpi r P γ π s)
      (fun s => Tpol r P γ π' (Vpi r P γ π) s - Vpi r P γ π s) (pmat P π')
      hγ0 hγ1 hdeq hd0 (pmat_nonneg P hP0 π') (pmat_row_sum P hP1 π')
  refine ⟨fun s => by have := hu0 s; linarith, ?_⟩
  intro hex
  obtain ⟨s₁, hs₁⟩ := hex
  refine ⟨s₁, ?_⟩
  have hdpos : 0 < Tpol r P γ π' (Vpi r P γ π) s₁ - Vpi r P γ π s₁ := by
    show 0 < (r s₁ (π' s₁) + γ * ∑ s', P s₁ (π' s₁) s' * Vpi r P γ π s')
        - Vpi r P γ π s₁
    have hc := hcambio s₁ hs₁
    linarith
  have hmvec0 : 0 ≤ mvec (pmat P π')
      (fun s' => Vpi r P γ π' s' - Vpi r P γ π s') s₁ :=
    Finset.sum_nonneg fun s' _ =>
      mul_nonneg (hP0 s₁ (π' s₁) s') (hu0 s')
  have heq := hdeq s₁
  have hgm : 0 ≤ γ * mvec (pmat P π')
      (fun s' => Vpi r P γ π' s' - Vpi r P γ π s') s₁ :=
    mul_nonneg hγ0 hmvec0
  linarith

/-! ### cor:ch8-pi-finita — terminación finita -/

/-- book: capitulos/cap03_mdp.typ:128 (key: cor:ch8-pi-finita) —
parte 1: no se repite ninguna política antes de detenerse: si la regla de
mejora cambia alguna acción, el valor de la política nueva es distinto del
de la anterior.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch8_pi_finita_sin_repeticion (π π' : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hgreedy : ∀ s a, r s (π' s) + γ * ∑ s', P s (π' s) s' * Vpi r P γ π s'
      ≥ r s a + γ * ∑ s', P s a s' * Vpi r P γ π s')
    (hcambio : ∀ s, π' s ≠ π s →
      r s (π' s) + γ * ∑ s', P s (π' s) s' * Vpi r P γ π s' > Vpi r P γ π s)
    (hdiff : ∃ s, π' s ≠ π s) :
    Vpi r P γ π' ≠ Vpi r P γ π := by
  obtain ⟨s, hs⟩ := (ch8_mejora r P γ π π' hP0 hP1 hγ0 hγ1 hgreedy hcambio).2 hdiff
  intro heq
  have := congrFun heq s
  linarith

/-- book: capitulos/cap03_mdp.typ:128 (key: cor:ch8-pi-finita) —
parte 2: hay a lo sumo `|A|^|S|` políticas deterministas.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch8_pi_finita_conteo :
    Fintype.card (S → A) = Fintype.card A ^ Fintype.card S :=
  Fintype.card_fun

/-- book: capitulos/cap03_mdp.typ:128 (key: cor:ch8-pi-finita) —
parte 3: al detenerse (cuando `T* V^π = V^π`), la política es óptima:
ninguna política determinista la supera. Junto con las partes 1–2 da la
terminación finita del libro: mejora estricta en cada cambio, a lo sumo
`|A|^|S|` políticas. Este argumento es de mejora y finitud; no afirma
que la iteración de políticas sea una contracción (como el libro).
Origen: F1 2026-11-04 (nuevo). -/
theorem ch8_pi_finita_optimo (π : S → A)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hfix : ∀ s, Topt r P γ (Vpi r P γ π) s ≤ Vpi r P γ π s) :
    ∀ π' : S → A, ∀ s, Vpi r P γ π' s ≤ Vpi r P γ π s := by
  intro π' s
  set M : ℝ := (univ : Finset S).sup' Finset.univ_nonempty
    (fun s' => |Vpi r P γ π' s' - Vpi r P γ π s'|) with hMdef
  have hMono : ∀ s'' : S, Vpi r P γ π' s'' ≤ Vpi r P γ π s'' + M := by
    intro s''
    have habs := Finset.le_sup'
      (f := fun s' => |Vpi r P γ π' s' - Vpi r P γ π s'|) (Finset.mem_univ s'')
    have hab := abs_le.mp habs
    linarith [hab.2]
  have hiter : ∀ (k : ℕ) (s' : S), ToptIter r P γ k (Vpi r P γ π') s'
      ≤ Vpi r P γ π s' + γ ^ k * M := by
    intro k
    induction k with
    | zero =>
        intro s'
        show Vpi r P γ π' s' ≤ Vpi r P γ π s' + γ ^ 0 * M
        rw [pow_zero, one_mul]
        exact hMono s'
    | succ k ih =>
        intro s'
        have h1 : ToptIter r P γ (k + 1) (Vpi r P γ π') s'
            = Topt r P γ (ToptIter r P γ k (Vpi r P γ π')) s' := rfl
        calc ToptIter r P γ (k + 1) (Vpi r P γ π') s'
            = Topt r P γ (ToptIter r P γ k (Vpi r P γ π')) s' := h1
          _ ≤ Topt r P γ (fun s'' => Vpi r P γ π s'' + γ ^ k * M) s' :=
              Topt_mono r P γ hP0 hγ0 ih s'
          _ = Topt r P γ (Vpi r P γ π) s' + γ ^ (k + 1) * M := by
              rw [Topt_add_const r P γ hP1 (Vpi r P γ π) (γ ^ k * M) s', pow_succ]
              ring
          _ ≤ Vpi r P γ π s' + γ ^ (k + 1) * M :=
              add_le_add (hfix s') (le_refl _)
  have hbelow : ∀ (k : ℕ) (s' : S),
      Vpi r P γ π' s' ≤ ToptIter r P γ k (Vpi r P γ π') s' := by
    intro k
    induction k with
    | zero => intro s'; exact le_refl _
    | succ k ih =>
        intro s'
        have h1 : ToptIter r P γ (k + 1) (Vpi r P γ π') s'
            = Topt r P γ (ToptIter r P γ k (Vpi r P γ π')) s' := rfl
        calc Vpi r P γ π' s'
            = Tpol r P γ π' (Vpi r P γ π') s' :=
                Vpi_fix r P γ π' hP0 hP1 hγ0 hγ1 s'
          _ ≤ Topt r P γ (Vpi r P γ π') s' := le_Topt r P γ π' (Vpi r P γ π') s'
          _ ≤ Topt r P γ (ToptIter r P γ k (Vpi r P γ π')) s' :=
              Topt_mono r P γ hP0 hγ0 ih s'
          _ = ToptIter r P γ (k + 1) (Vpi r P γ π') s' := h1.symm
  have hall : ∀ k : ℕ, Vpi r P γ π' s ≤ Vpi r P γ π s + γ ^ k * M :=
    fun k => le_trans (hbelow k s) (hiter k s)
  have hgeom : Summable (fun k : ℕ => γ ^ k) := summable_geometric_of_lt_one hγ0 hγ1
  have htendsto : Filter.Tendsto (fun k : ℕ => γ ^ k * M) Filter.atTop (𝓝 0) := by
    simpa [zero_mul] using
      Filter.Tendsto.mul (hgeom.tendsto_atTop_zero) tendsto_const_nhds
  have hle0 : 0 ≤ -Vpi r P γ π' s + Vpi r P γ π s := by
    refine le_of_tendsto (x := Filter.atTop)
      (f := fun k : ℕ => -(γ ^ k * M)) ?_ ?_
    · simpa [neg_zero] using htendsto.neg
    · refine Filter.Eventually.of_forall (fun k => ?_)
      have hk := hall k
      linarith
  linarith

end MDP
