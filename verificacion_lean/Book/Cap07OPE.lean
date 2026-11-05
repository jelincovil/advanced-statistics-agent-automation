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

/-! ## thm:ch10-identificacion — tercera identidad: J(e) = Σ_t γ^t E_b[W_t R_t] -/

section IdentificacionTotal

variable {S A : Type u} [Fintype S] [Fintype A] [Nonempty S]
  (b e : S → A → ℝ) (K : S → A → S → ℝ) (ν : S → ℝ) (R : S → A → S → ℝ) (γ : ℝ)

/-- Término por decisión del lado e: valor e de la recompensa del paso
`t` (prefijo de longitud `t + 1`, sin sufijo: bajo `e` el sufijo se
promedia a uno). -/
private def eTerm (t : ℕ) (s : S) : ℝ :=
  ∑ p : Traj S A (t + 1), eweight e K s p * lastReward R s (t + 1) p

private theorem eTerm_zero (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) (s : S) :
    eTerm e K R 0 s = ∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s' := by
  have hsum : ∀ a : A, ∀ s' : S,
      (∑ r : Traj S A 0,
          (e s a * K s a s' * eweight e K s' r)
            * lastReward R s 1 (Traj.step a s' r))
        = e s a * K s a s' * R s a s' := by
    intro a s'
    have h2 : ∀ r : Traj S A 0,
        lastReward R s 1 (Traj.step a s' r) = R s a s' := fun r => rfl
    have h3 : ∀ r : Traj S A 0, eweight e K s' r = 1 := by
      intro r
      cases r
      rfl
    have h4 : ∀ r : Traj S A 0,
        (e s a * K s a s' * eweight e K s' r)
            * lastReward R s 1 (Traj.step a s' r)
          = (e s a * K s a s' * R s a s') * eweight e K s' r := by
      intro r
      rw [h2 r, h3 r]
      ring
    rw [Finset.sum_congr rfl (fun r _ => h4 r), ← Finset.mul_sum,
      eweight_sum_one e K he hK 0 s']
    ring
  have hdef : eTerm e K R 0 s
      = ∑ p : Traj S A 1, eweight e K s p * lastReward R s 1 p := rfl
  rw [hdef]
  rw [sum_step 0 (fun p => eweight e K s p * lastReward R s 1 p)]
  refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ => ?_
  exact hsum a s'

private theorem eTerm_succ (t : ℕ) (s : S) :
    eTerm e K R (t + 1) s
      = ∑ a : A, ∑ s' : S, e s a * K s a s' * eTerm e K R t s' := by
  have hdef : eTerm e K R (t + 1) s
      = ∑ p : Traj S A (t + 2), eweight e K s p * lastReward R s (t + 2) p := rfl
  rw [hdef]
  rw [sum_step (t + 1) (fun p => eweight e K s p * lastReward R s (t + 2) p)]
  refine Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ => ?_
  have hreas : ∀ p : Traj S A (t + 1),
      eweight e K s (Traj.step a s' p) * lastReward R s (t + 2) (Traj.step a s' p)
        = (e s a * K s a s')
            * (eweight e K s' p * lastReward R s' (t + 1) p) := by
    intro p
    have h1 : eweight e K s (Traj.step a s' p)
        = e s a * K s a s' * eweight e K s' p := rfl
    have h2 : lastReward R s (t + 2) (Traj.step a s' p)
        = lastReward R s' (t + 1) p := rfl
    rw [h1, h2]
    ring
  rw [Finset.sum_congr rfl (fun p _ => hreas p), ← Finset.mul_sum]
  rfl

/-- Lema maestro (lado e, base no enunciada): el retorno descontado bajo
la ley de la política de evaluación se descompone por pasos. -/
private theorem e_sum_return (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) :
    ∀ (H : ℕ) (s : S),
      (∑ τ : Traj S A H, eweight e K s τ * trajReturn R γ s τ)
        = ∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s := by
  intro H
  induction H with
  | zero =>
      intro s
      rw [sum_traj_zero]
      show eweight e K s Traj.stop * trajReturn R γ s Traj.stop = 0
      have h1 : trajReturn R γ s Traj.stop = 0 := rfl
      rw [h1]
      ring
  | succ H ih =>
      intro s
      have hL : (∑ τ : Traj S A (H + 1), eweight e K s τ * trajReturn R γ s τ)
          = (∑ a : A, ∑ s' : S, ∑ r : Traj S A H,
              (e s a * K s a s' * eweight e K s' r)
                * (R s a s' + γ * trajReturn R γ s' r)) := by
        rw [sum_step H (fun τ => eweight e K s τ * trajReturn R γ s τ)]
        have hterm0 : ∀ a : A, ∀ s' : S, ∀ r : Traj S A H,
            eweight e K s (Traj.step a s' r) * trajReturn R γ s (Traj.step a s' r)
              = (e s a * K s a s' * eweight e K s' r)
                * (R s a s' + γ * trajReturn R γ s' r) := by
          intro a s' r
          have h1 : eweight e K s (Traj.step a s' r)
              = e s a * K s a s' * eweight e K s' r := rfl
          have h2 : trajReturn R γ s (Traj.step a s' r)
              = R s a s' + γ * trajReturn R γ s' r := rfl
          rw [h1, h2]
        exact Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ =>
          Finset.sum_congr rfl fun r _ => hterm0 a s' r
      have hterm : ∀ a : A, ∀ s' : S, ∀ r : Traj S A H,
          (e s a * K s a s' * eweight e K s' r)
              * (R s a s' + γ * trajReturn R γ s' r)
            = (e s a * K s a s' * R s a s') * eweight e K s' r
              + γ * (e s a * K s a s')
                  * (eweight e K s' r * trajReturn R γ s' r) := by
        intro a s' r
        ring
      have hsplit1 : ∀ a : A, ∀ s' : S,
          (∑ r : Traj S A H, (e s a * K s a s' * eweight e K s' r)
              * (R s a s' + γ * trajReturn R γ s' r))
            = (∑ r : Traj S A H, (e s a * K s a s' * R s a s') * eweight e K s' r)
              + (∑ r : Traj S A H, γ * (e s a * K s a s')
                  * (eweight e K s' r * trajReturn R γ s' r)) := by
        intro a s'
        rw [Finset.sum_congr rfl (fun r _ => hterm a s' r), Finset.sum_add_distrib]
      have hA : ∀ a : A, ∀ s' : S,
          (∑ r : Traj S A H, (e s a * K s a s' * R s a s') * eweight e K s' r)
            = e s a * K s a s' * R s a s' := by
        intro a s'
        rw [← Finset.mul_sum, eweight_sum_one e K he hK H s']
        ring
      have hB : ∀ a : A, ∀ s' : S,
          (∑ r : Traj S A H, γ * (e s a * K s a s')
                  * (eweight e K s' r * trajReturn R γ s' r))
            = γ * (e s a * K s a s'
                * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r)) := by
        intro a s'
        rw [← Finset.mul_sum]
        ring
      have hC : ∀ a : A,
          (∑ s' : S, γ * (e s a * K s a s'
                  * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r)))
            = γ * (∑ s' : S, e s a * K s a s'
                  * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r)) := by
        intro a
        rw [← Finset.mul_sum]
      have hL2 : (∑ a : A, ∑ s' : S, ∑ r : Traj S A H,
              (e s a * K s a s' * eweight e K s' r)
                * (R s a s' + γ * trajReturn R γ s' r))
          = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
            + γ * ∑ a : A, ∑ s' : S, e s a * K s a s'
                * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r) := by
        calc (∑ a : A, ∑ s' : S, ∑ r : Traj S A H,
                (e s a * K s a s' * eweight e K s' r)
                  * (R s a s' + γ * trajReturn R γ s' r))
            = ∑ a : A, ∑ s' : S,
                ((∑ r : Traj S A H, (e s a * K s a s' * R s a s') * eweight e K s' r)
                + (∑ r : Traj S A H, γ * (e s a * K s a s')
                    * (eweight e K s' r * trajReturn R γ s' r))) :=
                Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ =>
                  hsplit1 a s'
          _ = ∑ a : A, ((∑ s' : S, ∑ r : Traj S A H,
                  (e s a * K s a s' * R s a s') * eweight e K s' r)
                + (∑ s' : S, ∑ r : Traj S A H, γ * (e s a * K s a s')
                    * (eweight e K s' r * trajReturn R γ s' r))) :=
                Finset.sum_congr rfl fun a _ => Finset.sum_add_distrib
          _ = (∑ a : A, ∑ s' : S, ∑ r : Traj S A H,
                  (e s a * K s a s' * R s a s') * eweight e K s' r)
              + (∑ a : A, ∑ s' : S, ∑ r : Traj S A H, γ * (e s a * K s a s')
                    * (eweight e K s' r * trajReturn R γ s' r)) :=
                Finset.sum_add_distrib
          _ = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
              + (∑ a : A, ∑ s' : S, ∑ r : Traj S A H, γ * (e s a * K s a s')
                    * (eweight e K s' r * trajReturn R γ s' r)) := by
                rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ =>
                  hA a s']
          _ = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
              + (∑ a : A, ∑ s' : S, γ * (e s a * K s a s'
                    * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r))) := by
                rw [Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun s' _ =>
                  hB a s']
          _ = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
              + (∑ a : A, γ * (∑ s' : S, e s a * K s a s'
                    * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r))) := by
                rw [Finset.sum_congr rfl fun a _ => hC a]
          _ = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
              + γ * (∑ a : A, ∑ s' : S, e s a * K s a s'
                    * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r)) := by
                rw [← Finset.mul_sum]

      have hstep : ∀ t ∈ Finset.range H,
          γ ^ (t + 1) * eTerm e K R (t + 1) s
            = γ * (∑ a : A, ∑ s' : S, e s a * K s a s'
                * γ ^ t * eTerm e K R t s') := by
        intro t _
        rw [eTerm_succ e K R t s, pow_succ', Finset.mul_sum]
        have hinner : ∀ a : A,
            γ * γ ^ t * (∑ s' : S, e s a * K s a s' * eTerm e K R t s')
              = γ * (γ ^ t
                  * (∑ s' : S, e s a * K s a s' * eTerm e K R t s')) := by
          intro a
          ring
        rw [Finset.sum_congr rfl (fun a _ => hinner a), ← Finset.mul_sum]
        refine congrArg (fun X : ℝ => γ * X) ?_
        refine Finset.sum_congr rfl fun a _ => ?_
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun s' _ => by ring
      have h1 : (∑ t ∈ Finset.range H, ∑ a : A, ∑ s' : S,
            e s a * K s a s' * γ ^ t * eTerm e K R t s')
          = ∑ a : A, ∑ t ∈ Finset.range H, ∑ s' : S,
              e s a * K s a s' * γ ^ t * eTerm e K R t s' :=
          Finset.sum_comm
      have h2 : (∑ a : A, ∑ t ∈ Finset.range H, ∑ s' : S,
            e s a * K s a s' * γ ^ t * eTerm e K R t s')
          = ∑ a : A, ∑ s' : S, ∑ t ∈ Finset.range H,
              e s a * K s a s' * γ ^ t * eTerm e K R t s' :=
          Finset.sum_congr rfl fun a _ => Finset.sum_comm
      have h3 : (∑ a : A, ∑ s' : S, ∑ t ∈ Finset.range H,
            e s a * K s a s' * γ ^ t * eTerm e K R t s')
          = ∑ s' : S, ∑ a : A, ∑ t ∈ Finset.range H,
              e s a * K s a s' * γ ^ t * eTerm e K R t s' :=
          Finset.sum_comm
      have hsm2 : ∀ s' : S,
          (∑ a : A, ∑ t ∈ Finset.range H,
              e s a * K s a s' * γ ^ t * eTerm e K R t s')
            = (∑ a : A, e s a * K s a s')
                * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s') := by
        intro s'
        have hreas : ∀ a : A, ∀ t : ℕ,
            e s a * K s a s' * γ ^ t * eTerm e K R t s'
              = (e s a * K s a s') * (γ ^ t * eTerm e K R t s') := by
          intro a t
          ring
        have hinner : ∀ a : A,
            (∑ t ∈ Finset.range H,
                e s a * K s a s' * γ ^ t * eTerm e K R t s')
              = (e s a * K s a s')
                  * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s') := by
          intro a
          rw [Finset.sum_congr rfl (fun t _ => hreas a t), ← Finset.mul_sum]
        rw [Finset.sum_congr rfl (fun a _ => hinner a), ← Finset.sum_mul]
      have hR : (∑ t ∈ Finset.range (H + 1), γ ^ t * eTerm e K R t s)
          = (∑ a : A, ∑ s' : S, e s a * K s a s' * R s a s')
            + γ * ∑ s' : S, (∑ a : A, e s a * K s a s')
                * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s') := by
        rw [Finset.sum_range_succ', eTerm_zero e K R he hK s, pow_zero, one_mul]
        rw [Finset.sum_congr rfl (fun t ht => hstep t ht)]
        rw [← Finset.mul_sum]
        rw [h1, h2, h3]
        rw [Finset.sum_congr rfl (fun s' _ => hsm2 s')]
        ring

      rw [hL, hL2, hR]
      congr 1
      have hclose : ∀ a : A, ∀ s' : S,
          e s a * K s a s'
              * (∑ r : Traj S A H, eweight e K s' r * trajReturn R γ s' r)
            = e s a * K s a s'
                * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s') := by
        intro a s'
        rw [ih s']
      rw [Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun s' _ =>
        hclose a s'))]
      rw [Finset.sum_comm]
      have hsm : ∀ s' : S,
          (∑ a : A, (e s a * K s a s')
              * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s'))
            = (∑ a : A, e s a * K s a s')
                * (∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s') := by
        intro s'
        exact (Finset.sum_mul _ _ _).symm
      rw [Finset.sum_congr rfl (fun s' _ => hsm s')]

/-- book: capitulos/cap07_ope.typ:140 (key: thm:ch10-identificacion) —
tercera identidad: el valor de la política es la suma por decisiones
`J(e) = Σ_t γ^t E_b[W_t R_t]`. Cada término `E_b[W_t R_t]` se enuncia con
el prefijo de `t + 1` pasos que porta la razón `W_t` y la recompensa del
paso `t`; el sufijo restante se promedia a uno bajo la ley de
comportamiento (`bweight_sum_one`), como en `ch10_identificacion_pdis`.
Junto con `ch10_identificacion` y `ch10_identificacion_pdis` cierra el
teorema: las tres identidades. -/
theorem ch10_identificacion_per_decision (H : ℕ)
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) (hν : ∑ s, ν s = 1) :
    (∑ s₀, ν s₀ * ∑ τ : Traj S A H,
        bweight b K s₀ τ * rhow b e s₀ τ * trajReturn R γ s₀ τ)
      = ∑ t ∈ Finset.range H, γ ^ t * (∑ s₀, ν s₀ * ∑ p : Traj S A (t + 1),
          bweight b K s₀ p * rhow b e s₀ p * lastReward R s₀ (t + 1) p) := by
  have hνe : ∀ s₀ : S,
      (∑ τ : Traj S A H, eweight e K s₀ τ * trajReturn R γ s₀ τ)
        = ∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s₀ :=
    e_sum_return e K R γ he hK H
  have hconv : ∀ s₀ : S, ∀ t : ℕ,
      (∑ p : Traj S A (t + 1), bweight b K s₀ p * rhow b e s₀ p
          * lastReward R s₀ (t + 1) p)
        = ∑ p : Traj S A (t + 1), eweight e K s₀ p * lastReward R s₀ (t + 1) p := by
    intro s₀ t
    exact Finset.sum_congr rfl fun p _ => by
      rw [bweight_mul_rhow b e K hs s₀ p]
  calc (∑ s₀, ν s₀ * ∑ τ : Traj S A H,
          bweight b K s₀ τ * rhow b e s₀ τ * trajReturn R γ s₀ τ)
      = ∑ s₀, ν s₀ * ∑ τ : Traj S A H,
          eweight e K s₀ τ * trajReturn R γ s₀ τ := by
        refine Finset.sum_congr rfl fun s₀ _ => ?_
        refine congrArg (fun X : ℝ => ν s₀ * X) ?_
        exact Finset.sum_congr rfl fun τ _ => by
          rw [bweight_mul_rhow b e K hs s₀ τ]
    _ = ∑ s₀, ν s₀ * ∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s₀ :=
        Finset.sum_congr rfl fun s₀ _ => by rw [hνe s₀]
    _ = ∑ t ∈ Finset.range H, γ ^ t * (∑ s₀, ν s₀ * eTerm e K R t s₀) := by
        have hdist : ∀ s₀ : S,
            (ν s₀ * ∑ t ∈ Finset.range H, γ ^ t * eTerm e K R t s₀)
              = ∑ t ∈ Finset.range H, ν s₀ * (γ ^ t * eTerm e K R t s₀) :=
          fun s₀ => Finset.mul_sum _ _ _
        rw [Finset.sum_congr rfl (fun s₀ _ => hdist s₀)]
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun t _ => ?_
        have hreas : ∀ s₀ : S, ν s₀ * (γ ^ t * eTerm e K R t s₀)
            = γ ^ t * (ν s₀ * eTerm e K R t s₀) := by
          intro s₀
          ring
        rw [Finset.sum_congr rfl (fun s₀ _ => hreas s₀), ← Finset.mul_sum]
    _ = ∑ t ∈ Finset.range H, γ ^ t * (∑ s₀, ν s₀ * ∑ p : Traj S A (t + 1),
          bweight b K s₀ p * rhow b e s₀ p * lastReward R s₀ (t + 1) p) := by
        refine Finset.sum_congr rfl fun t _ => ?_
        refine congrArg (fun X : ℝ => γ ^ t * X) ?_
        exact Finset.sum_congr rfl fun s₀ _ => by
          rw [hconv s₀ t]
          rfl

end IdentificacionTotal

/-! ## thm:ch10-is-insesgado — IS insesgado y varianza (episodios iid) -/

/-! ### Base iid (no enunciada en el libro): producto de episodios -/

section Iid

variable {X : Type u} [Fintype X]

private theorem prod_snoc (μ : X → ℝ) (x : X) (ω' : Fin n → X) :
    ∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k)
      = (∏ k : Fin n, μ (ω' k)) * μ x := by
  rw [Fin.prod_univ_castSucc]
  simp only [Fin.snoc_castSucc, Fin.snoc_last]

private theorem sum_snoc (g : X → ℝ) (x : X) (ω' : Fin n → X) :
    ∑ k : Fin (n + 1), g ((Fin.snoc ω' x : Fin (n + 1) → X) k)
      = (∑ k : Fin n, g (ω' k)) + g x := by
  rw [Fin.sum_univ_castSucc]
  simp only [Fin.snoc_castSucc, Fin.snoc_last]

private theorem sum_snocEquiv (F : (Fin (n + 1) → X) → ℝ) :
    ∑ ω : (Fin (n + 1) → X), F ω
      = ∑ x : X, ∑ ω' : (Fin n → X), F (Fin.snoc ω' x) := by
  have h1 : ∑ ω : (Fin (n + 1) → X), F ω
      = ∑ p : X × (Fin n → X), F (Fin.snocEquiv (fun _ => X) p) :=
    (Fintype.sum_equiv (Fin.snocEquiv (fun _ => X))
      (fun p => F (Fin.snocEquiv (fun _ => X) p)) F
      (fun _ => rfl)).symm
  rw [h1, Fintype.sum_prod_type]
  rfl

/-- La ley del producto se normaliza: es una probabilidad. -/
private theorem iid_prod_one (μ : X → ℝ) (hμ : ∑ x, μ x = 1) :
    ∀ n : ℕ, ∑ ω : (Fin n → X), ∏ k, μ (ω k) = 1 := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [sum_snocEquiv]
      have hreas : ∀ x : X, ∀ ω' : (Fin n → X),
          (∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k))
            = μ x * (∏ k : Fin n, μ (ω' k)) := by
        intro x ω'
        rw [prod_snoc]
        ring
      rw [Finset.sum_congr rfl (fun x _ => Finset.sum_congr rfl (fun ω' _ =>
        hreas x ω'))]
      have hL1 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x * (∏ k : Fin n, μ (ω' k)))
            = μ x * (∑ ω' : (Fin n → X), ∏ k : Fin n, μ (ω' k)) := by
        intro x
        rw [← Finset.mul_sum]
      rw [Finset.sum_congr rfl (fun x _ => hL1 x)]
      rw [← Finset.sum_mul]
      rw [hμ, ih, one_mul]

/-- Esperanza de la suma de coordenadas iid: `n` veces la esperanza. -/
private theorem iid_sum_mean (μ : X → ℝ) (hμ : ∑ x, μ x = 1)
    (f : X → ℝ) :
    ∀ n : ℕ, ∑ ω : (Fin n → X), (∏ k, μ (ω k)) * (∑ k, f (ω k))
      = (n : ℝ) * (∑ x, μ x * f x) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [sum_snocEquiv]
      have hterm : ∀ x : X, ∀ ω' : (Fin n → X),
          (∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k))
              * (∑ k : Fin (n + 1), f ((Fin.snoc ω' x : Fin (n + 1) → X) k))
            = ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))) * μ x
                + ((∏ k : Fin n, μ (ω' k)) * f x) * μ x := by
        intro x ω'
        rw [prod_snoc, sum_snoc]
        ring
      have hreas1 : ∀ x : X, ∀ ω' : (Fin n → X),
          ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))) * μ x
            = μ x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))) := by
        intro x ω'
        ring
      have hreas2 : ∀ x : X, ∀ ω' : (Fin n → X),
          ((∏ k : Fin n, μ (ω' k)) * f x) * μ x
            = μ x * f x * (∏ k : Fin n, μ (ω' k)) := by
        intro x ω'
        ring
      have hL1 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x
              * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))))
            = μ x * ((n : ℝ) * (∑ y, μ y * f y)) := by
        intro x
        rw [← Finset.mul_sum, ih]
      have hL2 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x * f x * (∏ k : Fin n, μ (ω' k)))
            = μ x * f x := by
        intro x
        rw [← Finset.mul_sum, iid_prod_one μ hμ n]
        ring
      calc (∑ x : X, ∑ ω' : (Fin n → X),
              (∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k))
                * (∑ k : Fin (n + 1),
                    f ((Fin.snoc ω' x : Fin (n + 1) → X) k)))
          = ∑ x : X, ∑ ω' : (Fin n → X),
              (((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))) * μ x
                + ((∏ k : Fin n, μ (ω' k)) * f x) * μ x) :=
              Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun ω' _ =>
                hterm x ω'
        _ = ∑ x : X, ∑ ω' : (Fin n → X),
              (μ x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k)))
                + μ x * f x * (∏ k : Fin n, μ (ω' k))) :=
              Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun ω' _ => by
                rw [hreas1 x ω', hreas2 x ω']
        _ = ∑ x : X, ((∑ ω' : (Fin n → X), μ x
                * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))))
              + (∑ ω' : (Fin n → X), μ x * f x * (∏ k : Fin n, μ (ω' k)))) :=
              Finset.sum_congr rfl fun x _ => Finset.sum_add_distrib
        _ = ((n : ℝ) * (∑ y, μ y * f y)) * (∑ x, μ x)
            + (∑ y, μ y * f y) := by
              rw [Finset.sum_add_distrib]
              rw [Finset.sum_congr rfl (fun x _ => hL1 x)]
              rw [Finset.sum_congr rfl (fun x _ => hL2 x)]
              rw [← Finset.sum_mul]
              ring
        _ = ((n + 1 : ℕ) : ℝ) * (∑ y, μ y * f y) := by
              rw [hμ, mul_one]
              push_cast
              ring

/-- Segundo momento de la suma de coordenadas iid. -/
private theorem iid_sum2_mean (μ : X → ℝ) (hμ : ∑ x, μ x = 1)
    (f g : X → ℝ) :
    ∀ n : ℕ, ∑ ω : (Fin n → X), (∏ k, μ (ω k))
        * (∑ k, f (ω k)) * (∑ k, g (ω k))
      = (n : ℝ) * (∑ x, μ x * f x * g x)
        + (n : ℝ) * ((n : ℝ) - 1) * (∑ x, μ x * f x) * (∑ x, μ x * g x) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [sum_snocEquiv]
      have hterm : ∀ x : X, ∀ ω' : (Fin n → X),
          (∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k))
              * (∑ k : Fin (n + 1), f ((Fin.snoc ω' x : Fin (n + 1) → X) k))
              * (∑ k : Fin (n + 1), g ((Fin.snoc ω' x : Fin (n + 1) → X) k))
            = μ x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))
                * (∑ k : Fin n, g (ω' k)))
                + μ x * (f x * ((∏ k : Fin n, μ (ω' k))
                    * (∑ k : Fin n, g (ω' k))))
                + μ x * (g x * ((∏ k : Fin n, μ (ω' k))
                    * (∑ k : Fin n, f (ω' k))))
                + μ x * ((f x * g x) * (∏ k : Fin n, μ (ω' k))) := by
        intro x ω'
        rw [prod_snoc, sum_snoc, sum_snoc]
        ring
      have hL1 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x
              * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))
                * (∑ k : Fin n, g (ω' k))))
            = μ x * ((n : ℝ) * (∑ y, μ y * f y * g y)
                + (n : ℝ) * ((n : ℝ) - 1) * (∑ y, μ y * f y)
                  * (∑ y, μ y * g y)) := by
        intro x
        rw [← Finset.mul_sum, ih]
      have hL2 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x * (f x
              * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, g (ω' k)))))
            = μ x * f x * ((n : ℝ) * (∑ y, μ y * g y)) := by
        intro x
        have hsw : ∀ ω' : (Fin n → X),
            μ x * (f x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, g (ω' k))))
              = (μ x * f x)
                  * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, g (ω' k))) := by
          intro ω'
          ring
        rw [Finset.sum_congr rfl (fun ω' _ => hsw ω'), ← Finset.mul_sum]
        exact congrArg ((μ x * f x) * ·) (iid_sum_mean μ hμ g n)
      have hL3 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x * (g x
              * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k)))))
            = μ x * g x * ((n : ℝ) * (∑ y, μ y * f y)) := by
        intro x
        have hsw : ∀ ω' : (Fin n → X),
            μ x * (g x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))))
              = (μ x * g x)
                  * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))) := by
          intro ω'
          ring
        rw [Finset.sum_congr rfl (fun ω' _ => hsw ω'), ← Finset.mul_sum]
        exact congrArg ((μ x * g x) * ·) (iid_sum_mean μ hμ f n)
      have hL4 : ∀ x : X,
          (∑ ω' : (Fin n → X), μ x * ((f x * g x) * (∏ k : Fin n, μ (ω' k))))
            = μ x * f x * g x := by
        intro x
        have hsw : ∀ ω' : (Fin n → X),
            μ x * ((f x * g x) * (∏ k : Fin n, μ (ω' k)))
              = (μ x * (f x * g x)) * (∏ k : Fin n, μ (ω' k)) := by
          intro ω'
          ring
        rw [Finset.sum_congr rfl (fun ω' _ => hsw ω'), ← Finset.mul_sum]
        rw [iid_prod_one μ hμ n]
        ring
      calc (∑ x : X, ∑ ω' : (Fin n → X),
              (∏ k : Fin (n + 1), μ ((Fin.snoc ω' x : Fin (n + 1) → X) k))
                * (∑ k : Fin (n + 1), f ((Fin.snoc ω' x : Fin (n + 1) → X) k))
                * (∑ k : Fin (n + 1), g ((Fin.snoc ω' x : Fin (n + 1) → X) k)))
          = ∑ x : X, ∑ ω' : (Fin n → X),
              (μ x * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))
                  * (∑ k : Fin n, g (ω' k)))
                + μ x * (f x * ((∏ k : Fin n, μ (ω' k))
                    * (∑ k : Fin n, g (ω' k))))
                + μ x * (g x * ((∏ k : Fin n, μ (ω' k))
                    * (∑ k : Fin n, f (ω' k))))
                + μ x * ((f x * g x) * (∏ k : Fin n, μ (ω' k)))) :=
              Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun ω' _ =>
                hterm x ω'
        _ = (∑ x : X, ∑ ω' : (Fin n → X), μ x
                * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k))
                  * (∑ k : Fin n, g (ω' k))))
            + (∑ x : X, ∑ ω' : (Fin n → X), μ x * (f x
                * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, g (ω' k)))))
            + (∑ x : X, ∑ ω' : (Fin n → X), μ x * (g x
                * ((∏ k : Fin n, μ (ω' k)) * (∑ k : Fin n, f (ω' k)))))
            + (∑ x : X, ∑ ω' : (Fin n → X),
                μ x * ((f x * g x) * (∏ k : Fin n, μ (ω' k)))) := by
              simp only [Finset.sum_add_distrib]
        _ = (∑ x, μ x) * ((n : ℝ) * (∑ y, μ y * f y * g y)
                + (n : ℝ) * ((n : ℝ) - 1) * (∑ y, μ y * f y)
                  * (∑ y, μ y * g y))
            + (∑ x, μ x * f x) * ((n : ℝ) * (∑ y, μ y * g y))
            + (∑ x, μ x * g x) * ((n : ℝ) * (∑ y, μ y * f y))
            + (∑ x, μ x * f x * g x) := by
              rw [Finset.sum_congr rfl (fun x _ => hL1 x)]
              rw [Finset.sum_congr rfl (fun x _ => hL2 x)]
              rw [Finset.sum_congr rfl (fun x _ => hL3 x)]
              rw [Finset.sum_congr rfl (fun x _ => hL4 x)]
              rw [← Finset.sum_mul, ← Finset.sum_mul, ← Finset.sum_mul]
        _ = (((n + 1 : ℕ) : ℝ)) * (∑ x, μ x * f x * g x)
            + (((n + 1 : ℕ) : ℝ)) * ((((n + 1 : ℕ) : ℝ)) - 1)
              * (∑ x, μ x * f x) * (∑ x, μ x * g x) := by
              rw [hμ]
              have hE1 : (∑ y : X, μ y * f y * g y)
                  = (∑ x : X, μ x * f x * g x) := rfl
              have hE2 : (∑ y : X, μ y * f y)
                  = (∑ x : X, μ x * f x) := rfl
              have hE3 : (∑ y : X, μ y * g y)
                  = (∑ x : X, μ x * g x) := rfl
              rw [hE1, hE2, hE3]
              push_cast
              ring

end Iid

/-! ### thm:ch10-is-insesgado -/

section IS

variable {S A : Type u} [Fintype S] [Fintype A] [Nonempty S]
  (b e : S → A → ℝ) (K : S → A → S → ℝ) (ν : S → ℝ) (R : S → A → S → ℝ) (γ : ℝ)

/-- Probabilidad de un episodio bajo la ley de comportamiento. -/
private noncomputable def epProb (H : ℕ) (ep : S × Traj S A H) : ℝ :=
  ν ep.1 * bweight b K ep.1 ep.2

/-- Término `W G` del episodio. -/
private noncomputable def epWG (H : ℕ) (ep : S × Traj S A H) : ℝ :=
  rhow b e ep.1 ep.2 * trajReturn R γ ep.1 ep.2

private theorem epProb_sum_one (H : ℕ)
    (hb : ∀ s, ∑ a, b s a = 1) (hK : ∀ s a, ∑ s', K s a s' = 1)
    (hν : ∑ s, ν s = 1) :
    ∑ ep : S × Traj S A H, epProb b K ν H ep = 1 := by
  rw [Fintype.sum_prod_type]
  show (∑ s₀ : S, ∑ τ : Traj S A H, ν s₀ * bweight b K s₀ τ) = 1
  have h1 : ∀ s₀ : S,
      (∑ τ : Traj S A H, ν s₀ * bweight b K s₀ τ)
        = ν s₀ * (∑ τ : Traj S A H, bweight b K s₀ τ) :=
    fun s₀ => (Finset.mul_sum (univ : Finset (Traj S A H))
      (fun τ => bweight b K s₀ τ) (ν s₀)).symm
  rw [Finset.sum_congr rfl (fun s₀ _ => h1 s₀)]
  rw [Finset.sum_congr rfl (fun s₀ _ => by rw [bweight_sum_one b K hb hK H s₀])]
  simp [hν]

private theorem epProbWG_eq (H : ℕ) :
    (∑ ep : S × Traj S A H, epProb b K ν H ep * epWG b e R γ H ep)
      = ∑ s₀, ν s₀ * ∑ τ : Traj S A H,
          bweight b K s₀ τ * rhow b e s₀ τ * trajReturn R γ s₀ τ := by
  rw [Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun s₀ _ => ?_
  show (∑ τ : Traj S A H, (ν s₀ * bweight b K s₀ τ)
      * (rhow b e s₀ τ * trajReturn R γ s₀ τ))
      = (ν s₀ * (∑ τ : Traj S A H, bweight b K s₀ τ * rhow b e s₀ τ
          * trajReturn R γ s₀ τ))
  have hreas : ∀ τ : Traj S A H,
      (ν s₀ * bweight b K s₀ τ) * (rhow b e s₀ τ * trajReturn R γ s₀ τ)
        = ν s₀ * (bweight b K s₀ τ * rhow b e s₀ τ
            * trajReturn R γ s₀ τ) := by
    intro τ
    ring
  rw [Finset.sum_congr rfl (fun τ _ => hreas τ), ← Finset.mul_sum]

/-- book: capitulos/cap07_ope.typ:218 (key: thm:ch10-is-insesgado) —
insesgadez de IS: con pesos verdaderos, la esperanza del estimador de
media de `n` episodios iid es `J(e)`. La integrabilidad `E_e |G| < ∞` del
libro es automática en el modelo finito (recompensas acotadas por
finitud). Fidelidad declarada: los episodios son independientes e
idénticamente distribuidos bajo la ley de comportamiento (`def:ch10-is`
del libro); el estimador promedia `W G` sin normalización empírica.
Origen: F1 2026-11-04 (nuevo). -/
theorem ch10_is_insesgado (H n : ℕ) (hn : 0 < n)
    (hs : ∀ s a, e s a ≠ 0 → b s a ≠ 0)
    (hb : ∀ s, ∑ a, b s a = 1) (he : ∀ s, ∑ a, e s a = 1)
    (hK : ∀ s a, ∑ s', K s a s' = 1) (hν : ∑ s, ν s = 1) :
    (∑ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
          * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k)))
      = (∑ s₀, ν s₀ * ∑ τ : Traj S A H,
          eweight e K s₀ τ * trajReturn R γ s₀ τ) := by
  have hprob : ∑ ep : S × Traj S A H, epProb b K ν H ep = 1 :=
    epProb_sum_one b K ν H hb hK hν
  have hmean := iid_sum_mean (epProb b K ν H) hprob (epWG b e R γ H) n
  have hscale : ∀ ω : (Fin n → (S × Traj S A H)),
      (∏ k, epProb b K ν H (ω k)) * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))
        = (1 / (n : ℝ)) * ((∏ k, epProb b K ν H (ω k))
            * (∑ k, epWG b e R γ H (ω k))) := by
    intro ω
    ring
  have hnR : ((n : ℝ)) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hn)
  rw [Finset.sum_congr rfl (fun ω _ => hscale ω)]
  rw [← Finset.mul_sum]
  rw [hmean]
  rw [← mul_assoc, one_div_mul_cancel hnR, one_mul]
  rw [epProbWG_eq b e K ν R γ H]
  exact ch10_identificacion b e K ν R γ H hs hb he hK hν

/-- book: capitulos/cap07_ope.typ:218 (key: thm:ch10-is-insesgado) —
varianza del estimador IS: `Var_b(Ĵ_IS) = Var_b(W G) / n`, con
`Var_b(W G) = E_b[(WG)²] − (E_b[WG])²`. La condición de segundo momento
`E_b W² G² < ∞` del libro es automática en el modelo finito; la segunda
condición no se necesita para la primera igualdad (como el libro).
Origen: F1 2026-11-04 (nuevo). -/
theorem ch10_is_varianza (H n : ℕ) (hn : 0 < n)
    (hb : ∀ s, ∑ a, b s a = 1) (hK : ∀ s a, ∑ s', K s a s' = 1)
    (hν : ∑ s, ν s = 1) :
    ((∑ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
          * (((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))
            * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))))
      - (∑ ω : (Fin n → (S × Traj S A H)),
          (∏ k, epProb b K ν H (ω k))
            * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k)))
        * (∑ ω : (Fin n → (S × Traj S A H)),
          (∏ k, epProb b K ν H (ω k))
            * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))))
      = ((1 / (n : ℝ)) * ((∑ ep : S × Traj S A H,
            epProb b K ν H ep * epWG b e R γ H ep * epWG b e R γ H ep)
          - (∑ ep : S × Traj S A H,
              epProb b K ν H ep * epWG b e R γ H ep)
            * (∑ ep : S × Traj S A H,
              epProb b K ν H ep * epWG b e R γ H ep))) := by
  have hprob : ∑ ep : S × Traj S A H, epProb b K ν H ep = 1 :=
    epProb_sum_one b K ν H hb hK hν
  have hmean := iid_sum_mean (epProb b K ν H) hprob (epWG b e R γ H) n
  have h2 := iid_sum2_mean (epProb b K ν H) hprob (epWG b e R γ H)
    (epWG b e R γ H) n
  have hnR : ((n : ℝ)) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hn)
  -- momento primero del estimador
  have hE1 : (∑ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
          * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k)))
      = (∑ ep : S × Traj S A H,
          epProb b K ν H ep * epWG b e R γ H ep) := by
    have hscale : ∀ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
            * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))
          = (1 / (n : ℝ)) * ((∏ k, epProb b K ν H (ω k))
              * (∑ k, epWG b e R γ H (ω k))) := by
      intro ω
      ring
    rw [Finset.sum_congr rfl (fun ω _ => hscale ω)]
    rw [← Finset.mul_sum]
    rw [hmean]
    rw [← mul_assoc, one_div_mul_cancel hnR, one_mul]
  -- segundo momento del estimador
  have hE2 : (∑ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
          * (((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))
            * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))))
      = ((1 / (n : ℝ)) * (1 / (n : ℝ)))
          * ((n : ℝ) * (∑ ep : S × Traj S A H,
                epProb b K ν H ep * epWG b e R γ H ep * epWG b e R γ H ep)
            + (n : ℝ) * ((n : ℝ) - 1) * (∑ ep : S × Traj S A H,
                epProb b K ν H ep * epWG b e R γ H ep)
              * (∑ ep : S × Traj S A H,
                epProb b K ν H ep * epWG b e R γ H ep)) := by
    have hscale : ∀ ω : (Fin n → (S × Traj S A H)),
        (∏ k, epProb b K ν H (ω k))
            * (((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k))
              * ((1 / (n : ℝ)) * ∑ k, epWG b e R γ H (ω k)))
          = ((1 / (n : ℝ)) * (1 / (n : ℝ)))
              * ((∏ k, epProb b K ν H (ω k))
                  * (∑ k, epWG b e R γ H (ω k))
                  * (∑ k, epWG b e R γ H (ω k))) := by
      intro ω
      ring
    rw [Finset.sum_congr rfl (fun ω _ => hscale ω)]
    rw [← Finset.mul_sum]
    rw [h2]
  rw [hE2, hE1]
  field_simp
  ring

end IS
