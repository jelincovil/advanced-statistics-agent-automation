import Mathlib

/-!
# Book.Cap07OPE — cap. 7 del libro (capitulos/cap07_ope.typ): OPE finito

Versión finita y estacionaria de la capa de evaluación fuera de línea:
identificación del valor de una política por cambio de medida
(`thm:ch10-identificacion`), la forma por decisión del estimador, y la
identidad de doble robustez (`thm:ch10-dr`).

Fidelidad declarada (plan §4): `S`, `A` finitos; políticas, kernel y
recompensa estacionarios (el libro los indexa por `t`); las probabilidades
son pesos de suma 1; el soporte del libro (b > 0 donde la identificación lo
exige) se enuncia como hipótesis `e > 0 → b > 0` y no se relaja.

La codificación de trayectorias (tipo inductivo `Traj` indexado por el
horizonte, pesos por política, razón de importancia por producto de razones
de paso) es base no enunciada en el libro: el libro argumenta con la ley
del episodio y cocientes de medidas; aquí esa ley es una suma finita sobre
`Traj S A k` y el cociente se factoriza paso a paso (lema
`bweight_mul_rhow`), que es exactamente «se cancelan ν y los núcleos».
-/

open Finset BigOperators

universe u

-- Las hipótesis de modelo (normalización, soporte) se declaran completas por
-- fidelidad al enunciado del libro aunque una prueba algebraica no las use.
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

/-! ## Trayectorias finitas (base) -/

section Trajectories

variable {S A : Type u} [Fintype S] [Fintype A]

/-- Trayectoria de `k` pasos: `k` acciones con sus transiciones. El estado
de entrada se pasa por fuera; `stop` agota el horizonte. -/
inductive Traj (S A : Type u) : ℕ → Type u where
  | stop : Traj S A 0
  | step : {k : ℕ} → A → S → Traj S A k → Traj S A (k + 1)

def stepEquiv : A × S × Traj S A k ≃ Traj S A (k + 1) where
  toFun p := Traj.step p.1 p.2.1 p.2.2
  invFun t := match t with
    | .step a s' r => (a, (s', r))
  left_inv t := by cases t; rfl
  right_inv p := by obtain ⟨a, s', r⟩ := p; rfl

theorem stepEquiv_apply (p : A × S × Traj S A k) :
    stepEquiv p = Traj.step p.1 p.2.1 p.2.2 := rfl

instance trajFintype (k : ℕ) : Fintype (Traj S A k) := by
  induction k with
  | zero => exact ⟨{Traj.stop}, by intro x; cases x; simp⟩
  | succ k ih => exact Fintype.ofEquiv (A × S × Traj S A k) stepEquiv

instance : Unique (Traj S A 0) := ⟨⟨Traj.stop⟩, fun τ => by cases τ; rfl⟩

@[simp]
theorem sum_traj_zero (f : Traj S A 0 → ℝ) :
    ∑ τ : Traj S A 0, f τ = f Traj.stop := by
  rw [show (Finset.univ : Finset (Traj S A 0)) = {Traj.stop} from Finset.univ_unique,
    Finset.sum_singleton]

/-- Desdoblamiento de una suma por el constructor `step`. -/
theorem sum_step (k : ℕ) (f : Traj S A (k + 1) → ℝ) :
    ∑ τ : Traj S A (k + 1), f τ
      = ∑ a : A, ∑ s' : S, ∑ r : Traj S A k, f (Traj.step a s' r) := by
  have h1 : ∑ τ : Traj S A (k + 1), f τ = ∑ p : A × S × Traj S A k, f (stepEquiv p) :=
    Fintype.sum_equiv stepEquiv.symm f (fun p => f (stepEquiv p))
      (by intro τ; cases τ; rfl)
  rw [h1, Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun s' _ => Finset.sum_congr rfl fun r _ =>
    (stepEquiv_apply (a, (s', r))).symm ▸ rfl

end Trajectories

/-! ## Pesos, razones y retornos -/

section Weights

variable {S A : Type u} [Fintype S] [Fintype A]

/-- Peso de una trayectoria bajo la política `b` y el kernel `K`, desde el
estado de entrada `s`: producto de `b s a * K s a s'` por paso. -/
def bweight (b : S → A → ℝ) (K : S → A → S → ℝ) :
    (s : S) → {k : ℕ} → Traj S A k → ℝ
  | _, _, .stop => 1
  | s, _, .step a s' r => b s a * K s a s' * bweight b K s' r

/-- Peso análogo bajo la política de evaluación `e`. -/
def eweight (e : S → A → ℝ) (K : S → A → S → ℝ) :
    (s : S) → {k : ℕ} → Traj S A k → ℝ
  | _, _, .stop => 1
  | s, _, .step a s' r => e s a * K s a s' * eweight e K s' r

/-- Razón de importancia de un paso. Convención (declarada): si
`b s a = 0`, la razón vale 0; en los puntos con `b s a = 0` el peso `b` ya
anula el producto, y la hipótesis de soporte garantiza `e s a = 0`. -/
noncomputable def rho (b e : S → A → ℝ) (s : S) (a : A) : ℝ :=
  if b s a = 0 then 0 else e s a / b s a

/-- Producto de las razones de importancia de los pasos de una
trayectoria: `W` de la trayectoria. -/
noncomputable def rhow (b e : S → A → ℝ) : (s : S) → {k : ℕ} → Traj S A k → ℝ
  | _, _, .stop => 1
  | s, _, .step a s' r => rho b e s a * rhow b e s' r

/-- Retorno descontado de una trayectoria con recompensa por paso
`R(s, a, s')`. -/
def trajReturn (R : S → A → S → ℝ) (γ : ℝ) :
    (s : S) → {k : ℕ} → Traj S A k → ℝ
  | _, _, .stop => 0
  | s, _, .step a s' r => R s a s' + γ * trajReturn R γ s' r

/-- Último estado de una trayectoria que entra en `s`. -/
def lastState (s : S) : {k : ℕ} → Traj S A k → S
  | _, .stop => s
  | _, .step _ s' r => lastState s' r

/-- Recompensa del último paso de una trayectoria que entra en `s`
(la recompensa del paso `t` es la del último paso del prefijo de
longitud `t + 1`). -/
def lastReward (R : S → A → S → ℝ) (s : S) : (k : ℕ) → Traj S A k → ℝ
  | 0, _ => 0
  | 1, .step a s' _ => R s a s'
  | (k + 2), .step a s' r => lastReward R s' (k + 1) r

/-- Concatenación prefijo–sufijo: `trajAppend s p suf` recorre `p` desde
`s` y luego `suf` desde el estado donde quedó `p`. -/
def trajAppend (s : S) : {m j : ℕ} → Traj S A m → Traj S A j → Traj S A (j + m)
  | 0, _, .stop, suf => suf
  | (m + 1), j, .step a s' p, suf => .step a s' (trajAppend s' p suf)

section AppendLemmas

variable {b e : S → A → ℝ} {K : S → A → S → ℝ} {R : S → A → S → ℝ} {γ : ℝ}

theorem bweight_append (s : S) (p : Traj S A m) (suf : Traj S A j) :
    bweight b K s (trajAppend s p suf)
      = bweight b K s p * bweight b K (lastState s p) suf := by
  induction p generalizing s with
  | stop => simp [trajAppend, bweight, lastState]
  | step a s' p ih =>
      simp only [trajAppend, bweight, ih s', lastState]
      ring

theorem eweight_append (s : S) (p : Traj S A m) (suf : Traj S A j) :
    eweight e K s (trajAppend s p suf)
      = eweight e K s p * eweight e K (lastState s p) suf := by
  induction p generalizing s with
  | stop => simp [trajAppend, eweight, lastState]
  | step a s' p ih =>
      simp only [trajAppend, eweight, ih s', lastState]
      ring

theorem trajReturn_append (s : S) (p : Traj S A m) (suf : Traj S A j) :
    trajReturn R γ s (trajAppend s p suf)
      = trajReturn R γ s p + γ ^ m * trajReturn R γ (lastState s p) suf := by
  induction p generalizing s with
  | stop =>
      simp only [trajAppend, trajReturn, lastState, pow_zero]
      ring
  | @step k a s' p ih =>
      simp only [trajAppend, trajReturn, ih s', lastState, pow_succ]
      ring

end AppendLemmas

/-! ### Lemas de peso -/

section WeightLemmas

/-- Normalización del peso `b`: la ley de un episodio de `k` pasos bajo `b`
suma 1 desde cualquier estado de entrada. -/
theorem bweight_sum_one (b : S → A → ℝ) (K : S → A → S → ℝ)
    (hb : ∀ s, ∑ a, b s a = 1) (hK : ∀ s a, ∑ s', K s a s' = 1) :
    ∀ (k : ℕ) (s : S), ∑ τ : Traj S A k, bweight b K s τ = 1 := by
  intro k
  induction k with
  | zero => intro s; rw [sum_traj_zero]; rfl
  | succ k ih =>
      intro s
      rw [sum_step k (bweight b K s)]
      simp only [bweight]
      calc ∑ a, ∑ s', ∑ r, b s a * K s a s' * bweight b K s' r
          = ∑ a, ∑ s', b s a * (K s a s' * ∑ r, bweight b K s' r) := by
            refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ => ?_
            rw [Finset.mul_sum, Finset.mul_sum]
            exact Finset.sum_congr rfl fun r _ => by ring
        _ = ∑ a, b s a * ∑ s', K s a s' * ∑ r, bweight b K s' r := by
            refine Finset.sum_congr rfl fun a _ => ?_
            rw [Finset.mul_sum]
        _ = 1 := by
            simp only [ih, mul_one, hK, hb]

/-- Normalización del peso `e` (análogo). -/
theorem eweight_sum_one (e : S → A → ℝ) (K : S → A → S → ℝ)
    (he : ∀ s, ∑ a, e s a = 1) (hK : ∀ s a, ∑ s', K s a s' = 1) :
    ∀ (k : ℕ) (s : S), ∑ τ : Traj S A k, eweight e K s τ = 1 := by
  intro k
  induction k with
  | zero => intro s; rw [sum_traj_zero]; rfl
  | succ k ih =>
      intro s
      rw [sum_step k (eweight e K s)]
      simp only [eweight]
      calc ∑ a, ∑ s', ∑ r, e s a * K s a s' * eweight e K s' r
          = ∑ a, ∑ s', e s a * (K s a s' * ∑ r, eweight e K s' r) := by
            refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ => ?_
            rw [Finset.mul_sum, Finset.mul_sum]
            exact Finset.sum_congr rfl fun r _ => by ring
        _ = ∑ a, e s a * ∑ s', K s a s' * ∑ r, eweight e K s' r := by
            refine Finset.sum_congr rfl fun a _ => ?_
            rw [Finset.mul_sum]
        _ = 1 := by
            simp only [ih, mul_one, hK, he]

/-- Telescopio puntual: `P_b(τ) · W(τ) = P_e(τ)`. Es «se cancelan ν y los
núcleos»: la razón del paso multiplica al peso de `b` y lo convierte en el
peso de `e`, paso a paso. -/
theorem bweight_mul_rhow (b e : S → A → ℝ) (K : S → A → S → ℝ)
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0) :
    ∀ {k : ℕ} (s : S) (τ : Traj S A k),
      bweight b K s τ * rhow b e s τ = eweight e K s τ := by
  intro k
  induction k with
  | zero =>
      intro s τ
      cases τ
      simp [bweight, rhow, eweight]
  | succ k ih =>
      intro s τ
      cases τ with
      | step a s' r =>
          have hbρ : b s a * rho b e s a = e s a := by
            by_cases hb0 : b s a = 0
            · have he0 : e s a = 0 := by
                by_contra h
                exact (hs s a h) hb0
              rw [hb0]
              simp [rho, hb0, he0]
            · rw [rho, if_neg hb0]
              field_simp
          simp only [bweight, eweight, rhow]
          calc b s a * K s a s' * bweight b K s' r * (rho b e s a * rhow b e s' r)
              = (b s a * rho b e s a) * (K s a s' * (bweight b K s' r * rhow b e s' r)) := by
                ring
            _ = e s a * (K s a s' * eweight e K s' r) := by
                rw [hbρ, ih s' r]
            _ = e s a * K s a s' * eweight e K s' r := by
                ring

/-- La mezcla se normaliza: `E_b[W] = 1` localmente. -/
theorem bweight_rhow_sum_one (b e : S → A → ℝ) (K : S → A → S → ℝ)
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0)
    (he : ∀ s, ∑ a, e s a = 1) (hK : ∀ s a, ∑ s', K s a s' = 1) :
    ∀ (k : ℕ) (s : S), ∑ τ : Traj S A k, bweight b K s τ * rhow b e s τ = 1 := by
  intro k s
  rw [Finset.sum_congr rfl (fun τ _ => bweight_mul_rhow b e K hs s τ)]
  exact eweight_sum_one e K he hK k s

end WeightLemmas

end Weights

/-! ## thm:ch10-identificacion — J(e) = E_b[W G] y forma por decisión -/

section Identificacion

variable {S A : Type u} [Fintype S] [Fintype A] [Nonempty S]
  (b e : S → A → ℝ) (K : S → A → S → ℝ) (ν : S → ℝ) (R : S → A → S → ℝ) (γ : ℝ)

/-- book: capitulos/cap07_ope.typ:140 (key: thm:ch10-identificacion) —
primera identidad: el valor de la política de evaluación es la media bajo
la ley de comportamiento del retorno ponderado por la razón completa
`W = W_(H-1)`. Versión finita estacionaria; la hipótesis de soporte
`e > 0 → b > 0` es la del libro y no se relaja.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch10_identificacion (H : ℕ)
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) (hν : ∑ s, ν s = 1) :
    (∑ s₀, ν s₀ * ∑ τ : Traj S A H,
        bweight b K s₀ τ * rhow b e s₀ τ * trajReturn R γ s₀ τ)
      = (∑ s₀, ν s₀ * ∑ τ : Traj S A H,
          eweight e K s₀ τ * trajReturn R γ s₀ τ) := by
  refine Finset.sum_congr rfl fun s₀ _ => ?_
  have h : ∑ τ : Traj S A H,
        bweight b K s₀ τ * rhow b e s₀ τ * trajReturn R γ s₀ τ
      = ∑ τ : Traj S A H, eweight e K s₀ τ * trajReturn R γ s₀ τ := by
    refine Finset.sum_congr rfl fun τ _ => ?_
    rw [bweight_mul_rhow b e K hs s₀ τ]
  rw [h]

/-- book: capitulos/cap07_ope.typ:140 (key: thm:ch10-identificacion) —
forma por decisión: `E_b[W_t R_t] = E_e[R_t]`, enunciada con la
descomposición prefijo–sufijo (el prefijo de `t + 1` pasos porta la razón
`W_t` y la recompensa del paso `t`; el sufijo se promedia a uno bajo `b`).
Base no enunciada en el libro: el colapso del sufijo es
`bweight_append` + `bweight_sum_one`.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch10_identificacion_pdis {m j : ℕ}
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) (hν : ∑ s, ν s = 1) :
    (∑ s₀, ν s₀ * ∑ p : Traj S A m, ∑ suf : Traj S A j,
        bweight b K s₀ (trajAppend s₀ p suf) * rhow b e s₀ p
          * lastReward R s₀ m p)
      = (∑ s₀, ν s₀ * ∑ p : Traj S A m,
          eweight e K s₀ p * lastReward R s₀ m p) := by
  refine Finset.sum_congr rfl fun s₀ _ => ?_
  have key : ∑ p : Traj S A m, ∑ suf : Traj S A j,
      bweight b K s₀ (trajAppend s₀ p suf) * rhow b e s₀ p
        * lastReward R s₀ m p
      = ∑ p : Traj S A m,
          bweight b K s₀ p * rhow b e s₀ p * lastReward R s₀ m p := by
    refine Finset.sum_congr rfl fun p _ => ?_
    have e2 : ∀ suf : Traj S A j,
        bweight b K s₀ (trajAppend s₀ p suf) * rhow b e s₀ p
          * lastReward R s₀ m p
        = bweight b K (lastState s₀ p) suf
            * (bweight b K s₀ p * rhow b e s₀ p * lastReward R s₀ m p) := by
      intro suf
      rw [bweight_append s₀ p suf]
      ring
    rw [Finset.sum_congr rfl (fun suf _ => e2 suf), ← Finset.sum_mul,
      bweight_sum_one b K hb hK j (lastState s₀ p)]
    ring
  rw [key]
  have h2 : ∑ p : Traj S A m, bweight b K s₀ p * rhow b e s₀ p
        * lastReward R s₀ m p
      = ∑ p : Traj S A m, eweight e K s₀ p * lastReward R s₀ m p := by
    refine Finset.sum_congr rfl fun p _ => ?_
    rw [bweight_mul_rhow b e K hs s₀ p]
  rw [h2]

end Identificacion

/-! ## thm:ch10-dr — identidad de doble robustez (una decisión) -/

section DR

variable {S A : Type u} [Fintype S] [Fintype A] [Nonempty S]

/-- Regresión verdadera del modelo finito: `m(s,a) = E[R | S=s, A=a]`
con `s' ~ K(·|s,a)` (base no enunciada en el libro). -/
private def trueReg (K : S → A → S → ℝ) (R : S → A → S → ℝ) (s : S) (a : A) : ℝ :=
  ∑ s', K s a s' * R s a s'

/-- Contribución DR de una decisión: modelo inicial `v̂(s)` más el
residuo ponderado por la propensión de trabajo. -/
private noncomputable def drTerm (e b' : S → A → ℝ) (m' m : S → A → ℝ) (s : S) (a : A) : ℝ :=
  (∑ a', e s a' * m' s a') + e s a / b' s a * (m s a - m' s a)

/-- book: capitulos/cap07_ope.typ:436 (key: thm:ch10-dr) — identidad de
doble robustez para una decisión: el sesgo de la contribución DR es el
producto de los errores de propensión y de regresión. Versión finita:
recompensa determinista `R(s,a,s')` con `s' ~ K(·|s,a)`; `b̄` es la
propensión de trabajo (fija, positiva) y `m̄` la regresión de trabajo,
tratadas como funciones fijas independientes de la muestra, como en el
libro. El término inicial `v̂` es el del libro (por qué importa: ver el
ejemplo de la media 1/2 vs 3/4 en el propio cap. 7).
Origen: F1 2026-11-04 (nuevo). -/
theorem ch10_dr (b e b' : S → A → ℝ) (ν : S → ℝ) (K : S → A → S → ℝ)
    (R : S → A → S → ℝ) (m' : S → A → ℝ)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hb' : ∀ s a, b' s a ≠ 0) :
    (∑ s, ν s * ∑ a, b s a * drTerm e b' m' (trueReg K R) s a)
      - (∑ s, ν s * ∑ a, e s a * trueReg K R s a)
      = ∑ s, ν s * ∑ a, e s a * ((b' s a - b s a) / b' s a)
          * (m' s a - trueReg K R s a) := by
  have hV : ∀ s : S, ∑ a, b s a * (∑ a', e s a' * m' s a')
      = ∑ a, e s a * m' s a := by
    intro s
    rw [← Finset.sum_mul, hb s, one_mul]
  have merge : ∀ s : S,
      (∑ a, b s a * drTerm e b' m' (trueReg K R) s a)
        - (∑ a, e s a * trueReg K R s a)
      = ∑ a, (e s a * m' s a
          + b s a * (e s a / b' s a) * (trueReg K R s a - m' s a)
          - e s a * trueReg K R s a) := by
    intro s
    have hexp : ∀ a : A,
        b s a * drTerm e b' m' (trueReg K R) s a
          = b s a * (∑ a', e s a' * m' s a')
            + b s a * (e s a / b' s a) * (trueReg K R s a - m' s a) := by
      intro a
      rw [drTerm, mul_add]
      ring
    rw [Finset.sum_congr rfl (fun a _ => hexp a), Finset.sum_add_distrib, hV s,
      ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun s _ => ?_
  rw [← mul_sub, merge s, Finset.mul_sum, Finset.mul_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  have hb'0 : b' s a ≠ 0 := hb' s a
  field_simp
  ring

/-- book: capitulos/cap07_ope.typ:436 (key: thm:ch10-dr) — corolario: el
sesgo se anula si la regresión de trabajo es correcta.
Origen: F1 2026-11-04 (corolario de ch10_dr). -/
theorem ch10_dr_sesgo_m (b e b' : S → A → ℝ) (ν : S → ℝ) (K : S → A → S → ℝ)
    (R : S → A → S → ℝ) (m' : S → A → ℝ)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hb' : ∀ s a, b' s a ≠ 0)
    (hm : ∀ s a, m' s a = trueReg K R s a) :
    (∑ s, ν s * ∑ a, b s a * drTerm e b' m' (trueReg K R) s a)
      = (∑ s, ν s * ∑ a, e s a * trueReg K R s a) := by
  have h := ch10_dr b e b' ν K R m' hb he hb'
  simp only [hm, sub_self, zero_mul, Finset.sum_const_zero, mul_zero] at h
  linarith

/-- book: capitulos/cap07_ope.typ:436 (key: thm:ch10-dr) — corolario: el
sesgo se anula si la propensión de trabajo es correcta.
Origen: F1 2026-11-04 (corolario de ch10_dr). -/
theorem ch10_dr_sesgo_b (b e b' : S → A → ℝ) (ν : S → ℝ) (K : S → A → S → ℝ)
    (R : S → A → S → ℝ) (m' : S → A → ℝ)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hb' : ∀ s a, b' s a ≠ 0)
    (hb'eq : ∀ s a, b' s a = b s a) :
    (∑ s, ν s * ∑ a, b s a * drTerm e b' m' (trueReg K R) s a)
      = (∑ s, ν s * ∑ a, e s a * trueReg K R s a) := by
  have h := ch10_dr b e b' ν K R m' hb he hb'
  simp [hb'eq] at h
  linarith

end DR
