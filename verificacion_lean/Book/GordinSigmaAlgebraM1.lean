/-
Copyright: proyecto des504 — enjambre smwa5izeq, miembro m1 (dirección d1 gordin-deuda).

# `σ² = ⟨h,h⟩ - ⟨Ph,Ph⟩`: la pieza algebraica de la identificación de Gordin

book: apendices/apendice_regularidad.typ:137 (key: thm:appD-gordin)

La entrada pendiente `C.thm:appD-gordin` deja como pieza la identificación
`σ² = ∑_k Cov(f(S_0), f(S_k))`. Esa identificación consta de dos partes:

1. **algebraica** (este fichero): para *cualquier* solución de Poisson,
   `σ² = π(condVar h) = ⟨h,h⟩ - ⟨Ph,Ph⟩` y, con `f = h - Ph`,
   `σ² = 2⟨f,h⟩ - ⟨f,f⟩`, donde `⟨u,v⟩ = ∑_x π_x u(x) v(x)`.
2. **analítica**: representar `h = ∑_k P^k f`, que exige aperiodicidad (o una
   cota geométrica explícita de `|(P^k f)(x)|`). Sin ella la identificación es
   **falsa**: contraejemplo formalizado en `GordinPeriodico.lean`.

Formalizar (1) acota la deuda: la parte que no necesita ninguna hipótesis
adicional queda cerrada y sólo (2) queda como trabajo.
-/
import Book.GordinCoreM8

/-!
# COPIA DECLARADA — `GordinSigmaM1` (enjambre previo `smwa5izeq`, miembro m1)

Este fichero es una copia **literal** de
`.ultramath/smwa5izeq/m1/GordinSigmaAlgebra.lean`, con una única adaptación
mecánica: `import GordinCoreM8` → `import Book.GordinCoreM8` (el módulo canónico
del repo es `verificacion_lean/Book/GordinCoreM8.lean`). No se ha tocado ninguna
declaración ni prueba; el original declara `namespace GordinSigmaM1`, que este
mismo fichero conserva. La copia existe sólo para que `GordinDecayM1.lean`
pueda usar `GordinSigmaM1.sigmaSq_eq_two_avg` (área algebraica ya auditada) sin
depender del estado de compilación del directorio de otro enjambre.
-/

open ApendiceDGordinM8
open scoped BigOperators

namespace GordinSigmaM1

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- `∑_y P_y (h_y - c)² = ∑_y P_y h_y² - c²` si `∑_y P_y = 1` y
`c = ∑_y P_y h_y` (identidad `Var = E[X²] - E[X]²` para pesos que suman uno). -/
lemma sum_mul_sq_sub (P h : S → ℝ) (hs : ∑ y, P y = 1) (c : ℝ)
    (hc : c = ∑ y, P y * h y) :
    ∑ y, P y * (h y - c) ^ 2 = ∑ y, P y * (h y) ^ 2 - c ^ 2 := by
  have hstep : ∀ y, P y * (h y - c) ^ 2
      = P y * (h y) ^ 2 - 2 * c * (P y * h y) + c ^ 2 * P y := by
    intro y; ring
  rw [Finset.sum_congr rfl (fun y _ => hstep y)]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hs,
    ← hc]
  ring

/-- **Expansión de la varianza condicional**: con `c = (P h)(x)`,
`∑_y P_xy (h y - c)² = ∑_y P_xy h(y)² - c²`. -/
lemma condVar_eq_applyP_sq (D : Chain S) (h : S → ℝ) (x : S) :
    D.condVar h x = D.applyP (fun y => (h y) ^ 2) x - (D.applyP h x) ^ 2 := by
  have hs : ∑ y, D.P x y = 1 := D.P_sum x
  have hc : D.applyP h x = ∑ y, D.P x y * h y := rfl
  have := sum_mul_sq_sub (fun y => D.P x y) h hs (D.applyP h x) hc
  simpa only [Chain.condVar, Chain.applyP_apply] using this

/-- **La varianza de la aproximación de martingalas es una forma de Dirichlet**:
`σ² = π(condVar h) = ⟨h,h⟩ - ⟨Ph,Ph⟩`. -/
theorem sigmaSq_eq (D : Chain S) (h : S → ℝ) :
    D.sigmaSq h = D.avg (fun x => (h x) ^ 2) - D.avg (fun x => (D.applyP h x) ^ 2) := by
  have hcv : D.condVar h
      = fun x => D.applyP (fun y => (h y) ^ 2) x - (D.applyP h x) ^ 2 :=
    funext fun x => condVar_eq_applyP_sq D h x
  have hsplit : D.avg (fun x => D.applyP (fun y => (h y) ^ 2) x - (D.applyP h x) ^ 2)
      = D.avg (D.applyP (fun y => (h y) ^ 2)) - D.avg (fun x => (D.applyP h x) ^ 2) := by
    rw [show (fun x => D.applyP (fun y => (h y) ^ 2) x - (D.applyP h x) ^ 2)
          = D.applyP (fun y => (h y) ^ 2) - fun x => (D.applyP h x) ^ 2 from rfl,
      map_sub]
  have havg : D.avg (D.applyP (fun y => (h y) ^ 2)) = D.avg (fun x => (h x) ^ 2) :=
    D.avg_applyP (fun y => (h y) ^ 2)
  rw [Chain.sigmaSq, hcv, hsplit, havg]

/-- Con la ecuación de Poisson `f = h - Ph`: `σ² = 2⟨f,h⟩ - ⟨f,f⟩`. -/
theorem sigmaSq_eq_two_avg (D : Chain S) {f h : S → ℝ}
    (hpois : ∀ x, f x = h x - D.applyP h x) :
    D.sigmaSq h = 2 * D.avg (fun x => f x * h x) - D.avg (fun x => (f x) ^ 2) := by
  have hfh : D.avg (fun x => f x * h x)
      = D.avg (fun x => (h x) ^ 2) - D.avg (fun x => D.applyP h x * h x) := by
    have h1 : (fun x => f x * h x)
        = (fun x => (h x) ^ 2) - (fun x => D.applyP h x * h x) := by
      funext x
      rw [hpois x]
      simp only [Pi.sub_apply, Pi.add_apply]
      ring_nf
    rw [h1, map_sub]
  have hsm : (fun x => 2 * (D.applyP h x * h x))
      = (2 : ℝ) • (fun x => D.applyP h x * h x) := by
    funext x
    simp [smul_eq_mul]
  have hff : D.avg (fun x => (f x) ^ 2)
      = D.avg (fun x => (h x) ^ 2) - 2 * D.avg (fun x => D.applyP h x * h x)
        + D.avg (fun x => (D.applyP h x) ^ 2) := by
    have h1 : (fun x => (f x) ^ 2)
        = ((fun x => (h x) ^ 2) - (fun x => 2 * (D.applyP h x * h x)))
          + (fun x => (D.applyP h x) ^ 2) := by
      funext x
      rw [hpois x]
      simp only [Pi.sub_apply, Pi.add_apply]
      ring_nf
    rw [h1, map_add, map_sub, hsm, map_smul]
    simp [smul_eq_mul]
  rw [sigmaSq_eq, hfh, hff]
  ring

end GordinSigmaM1
