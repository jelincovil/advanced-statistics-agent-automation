import Mathlib

/-!
# Book.Ch5EjemplosM5 — claves `ex:ch5-qdelta`, `def:ch5-ic-t`, `ex:ch5-bandas`

Módulo del lote m5 (enjambre `smw8gy947`) para el capítulo 5 del libro
(`book_stat_inference_v0/capitulos/cap04_herramientas.typ`, §Procesos
Empíricos y §Bootstrap, y §Asintótica para Funciones de Valor).

Convención de fidelidad del proyecto (la de
`verificacion_lean/Book/Cap05Asintotica.lean`): cada clave se formaliza con
el enunciado del libro cuando la herramienta disponible lo permite; cuando el
libro enuncia un límite distribucional que Mathlib no tiene, se formaliza el
núcleo exacto que la prueba del libro usa (la identidad algebraica, la
equivalencia de eventos o la desigualdad numérica) y se declara en el
docstring de cada declaración.
-/

open Finset BigOperators
open MeasureTheory ProbabilityTheory
open Filter
open scoped Topology

set_option maxHeartbeats 2000000

namespace BookCh5M5

/-! ## 1. `ex:ch5-qdelta` — Propagación de varianza en el MDP de 3 estados y 2 acciones

El libro (`cap04_herramientas.typ:1799`) fija `StateSpace = {s₁,s₂,s₃}`,
`ActionSpace = {a₁,a₂}`, y para el estado `s₁` la política `π(a₁|s₁)=0.6`,
`π(a₂|s₁)=0.4`; con `n = 50` trayectorias compartidas y covarianza del
límite escalado `Σ_Q = ((4.0, 1.2), (1.2, 9.0))` calcula

`σ²_V = (0.6)²(4.0) + (0.4)²(9.0) + 2(0.6)(0.4)(1.2) = 1.44+1.44+0.576 = 3.456`,
`σ_V ≈ 1.86`, e `IC 95% = V̂_n(s₁) ± 1.96·1.86/√50 = V̂_n(s₁) ± 0.516`, y
observa que ignorar la covarianza (`1.2`) daría `2.88` y subestimaría el
ancho del IC en un 9%. El resto del MDP (estados `s₂,s₃`) no entra en la
cuenta: la varianza de `V̂_n(s₁)` sólo depende de `π(·|s₁)` y de `Σ_Q`. -/

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) —
**Propagación de varianza `πᵀ Σ π`** con dos acciones: la varianza del valor
estimado es la forma cuadrática del libro, con los dos términos de varianza
pura y los dos términos de covarianza cruzada.

Fidelidad declarada: identidad algebraica exacta que el libro escribe y usa
(`Σ₁₂ = Σ₂₁ = 1.2`); la convergencia distribucional
`√n(V̂_n(s₁) − V^π(s₁)) →d N(0, πᵀΣ_Qπ)` es `prop:ch5-delta-q`
(`thm:ch5-delta-multi` con jacobiana `p_sᵀ`), no se reproduce aquí. -/
theorem qdelta_forma_cuadratica (p1 p2 s11 s12 s21 s22 : ℝ) :
    ∑ i : Fin 2, ∑ j : Fin 2,
        (![p1, p2] : Fin 2 → ℝ) i * (![p1, p2] : Fin 2 → ℝ) j *
          (!![s11, s12; s21, s22] : Matrix (Fin 2) (Fin 2) ℝ) i j
      = p1 ^ 2 * s11 + p2 ^ 2 * s22 + p1 * p2 * s12 + p2 * p1 * s21 := by
  simp [Fin.sum_univ_two]
  ring

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) —
La cuenta explícita del libro: `σ²_V = (0.6)²·4.0 + (0.4)²·9.0 + 2·0.6·0.4·1.2
= 1.44 + 1.44 + 0.576 = 3.456`. -/
theorem qdelta_sigma2 :
    (0.6 : ℝ) ^ 2 * 4.0 + (0.4 : ℝ) ^ 2 * 9.0 + 2 * (0.6 : ℝ) * (0.4 : ℝ) * 1.2
      = 3.456 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) — la
misma forma cuadrática escrita como `πᵀ Σ π` con la política y la covarianza
del libro: `π(a₁|s₁)=0.6`, `π(a₂|s₁)=0.4`, `Σ_Q = ((4.0,1.2),(1.2,9.0))`. -/
theorem qdelta_sigma2_matricial :
    ∑ i : Fin 2, ∑ j : Fin 2,
        (![0.6, 0.4] : Fin 2 → ℝ) i * (![0.6, 0.4] : Fin 2 → ℝ) j *
          (!![4.0, 1.2; 1.2, 9.0] : Matrix (Fin 2) (Fin 2) ℝ) i j
      = 3.456 := by
  rw [qdelta_forma_cuadratica]
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) — la
varianza que resultaría de **ignorar la covarianza** `1.2`: sólo las
varianzas puras ponderadas, `(0.6)²·4.0 + (0.4)²·9.0 = 2.88`. -/
theorem qdelta_sigma2_sin_covarianza :
    (0.6 : ℝ) ^ 2 * 4.0 + (0.4 : ℝ) ^ 2 * 9.0 = 2.88 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) —
`σ_V ≈ 1.86`: la desviación típica es `√3.456 = 1.8590…`, que redondeada a
dos decimales es `1.86` (|error| ≤ 0.005, que es el radio del redondeo). -/
theorem qdelta_sigma_redondeo : |Real.sqrt 3.456 - 1.86| ≤ 0.005 := by
  rw [abs_le]
  have hs : Real.sqrt 3.456 ^ 2 = 3.456 := Real.sq_sqrt (by norm_num)
  have h0 : (0:ℝ) ≤ Real.sqrt 3.456 := Real.sqrt_nonneg _
  constructor <;> nlinarith

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) — el
semiancho del IC 95% asintótico con `n = 50`:
`1.96·σ_V/√50 = 0.5153…`, que es `0.516` a menos de `0.001`. Aquí
`σ_V/√n = √(σ²_V/n)` (`Real.sqrt_div`), que es la varianza aproximada
`Σ_Q/n` del libro. -/
theorem qdelta_ic_semiancho :
    |1.96 * (Real.sqrt 3.456 / Real.sqrt 50) - 0.516| ≤ 0.001 := by
  have hdiv : Real.sqrt 3.456 / Real.sqrt 50 = Real.sqrt (3.456 / 50) := by
    rw [Real.sqrt_div (show (0:ℝ) ≤ 3.456 by norm_num)]
  rw [hdiv, abs_le]
  have hs : Real.sqrt (3.456 / 50) ^ 2 = 3.456 / 50 := Real.sq_sqrt (by norm_num)
  have h0 : (0:ℝ) ≤ Real.sqrt (3.456 / 50) := Real.sqrt_nonneg _
  constructor <;> nlinarith

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) — la
varianza aproximada del estimador es `Σ_Q/n = 3.456/50 = 0.06912`. -/
theorem qdelta_varianza_estimador : (3.456 : ℝ) / 50 = 0.06912 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1799 (key: ex:ch5-qdelta) — si se
ignora la covarianza, el ancho del IC se subestima en
`1 − √(2.88/3.456) = 0.0871…`, es decir «un 9%» a menos de medio punto
porcentual. -/
theorem qdelta_subestimacion :
    |(1 - Real.sqrt (2.88 / 3.456)) - 0.09| ≤ 0.005 := by
  rw [abs_le]
  have hs : Real.sqrt (2.88 / 3.456) ^ 2 = 2.88 / 3.456 := Real.sq_sqrt (by norm_num)
  have h0 : (0:ℝ) ≤ Real.sqrt (2.88 / 3.456) := Real.sqrt_nonneg _
  constructor <;> nlinarith

/-! ## 2. `def:ch5-ic-t` — IC bootstrap percentil-t

El libro (`cap04_herramientas.typ:1739`) define el pivote bootstrap
studentizado `t_n^* = (θ̂_n^* − θ̂_n)/ŜE^*(θ̂_n^*)` y el intervalo
`IC_perc-t = [θ̂_n − t_n^{*(1−α/2)}·ŜE, θ̂_n − t_n^{*(α/2)}·ŜE]`, donde
`θ̂_n^{*(q)}` es el cuantil `q` de la distribución bootstrap.

Se formalizan: (i) el cuantil bootstrap como `sInf` de los puntos que
acumulan masa `q`; (ii) el pivote; (iii) el intervalo; y (iv) la
**dualidad pivote-intervalo** que define al intervalo percentil-t (inversión
del test): `θ₀ ∈ IC ⟺ t^{*(α/2)} ≤ (θ̂_n − θ₀)/ŜE ≤ t^{*(1−α/2)}`. -/

/-- El cuantil `q` de la distribución bootstrap dada por su CDF `Fb`:
`bootQuantile Fb q = sInf {t | q ≤ Fb t}`, el ínfimo de los puntos que
acumulan masa al menos `q` (book: `def:ch5-ic-t`, `θ̂_n^{*(q)}`). -/
noncomputable def bootQuantile (Fb : ℝ → ℝ) (q : ℝ) : ℝ := sInf {t : ℝ | q ≤ Fb t}

/-- El cuantil bootstrap queda por debajo de cualquier punto que acumule masa
`≥ q` (es la propiedad de ínfimo, con la acotación inferior del conjunto de
niveles que una CDF garantiza). -/
theorem bootQuantile_le {Fb : ℝ → ℝ} {q t : ℝ}
    (hbd : BddBelow {t : ℝ | q ≤ Fb t}) (h : q ≤ Fb t) : bootQuantile Fb q ≤ t :=
  csInf_le hbd h

/-- El pivote studentizado de la réplica bootstrap,
`t^* = (θ̂^* − θ̂)/ŜE^*(θ̂^*)` (book: `def:ch5-ic-t`). -/
noncomputable def bootPivot (thetaStar thetaHat seStar : ℝ) : ℝ := (thetaStar - thetaHat) / seStar

/-- El intervalo percentil-t,
`IC = [θ̂ − t^{*(1−α/2)}·ŜE, θ̂ − t^{*(α/2)}·ŜE]` (book: `def:ch5-ic-t`). -/
noncomputable def icPercT (thetaHat se qLo qHi : ℝ) : Set ℝ :=
  Set.Icc (thetaHat - qHi * se) (thetaHat - qLo * se)

/-- book: capitulos/cap04_herramientas.typ:1739 (key: def:ch5-ic-t) —
**Dualidad pivote-intervalo del IC percentil-t**: con `ŜE > 0`, el valor
`θ₀` cae en el intervalo percentil-t si y sólo si su pivote
`(θ̂_n − θ₀)/ŜE` cae entre los cuantiles bootstrap `α/2` y `1−α/2`.

Fidelidad declarada: es exactamente la definición del intervalo del libro
leída como inversión de un test; el pivote de `θ₀` se escribe
`(θ̂ − θ₀)/ŜE`, que es la forma que el libro usa (`t_n^*` es la versión
bootstrap). No se formaliza la validez asintótica de la cobertura, que el
libro remite a expansiones de Edgeworth (`thm:ch5-cobertura`). -/
theorem icPercT_mem_iff {thetaHat se qLo qHi theta0 : ℝ} (hse : 0 < se) :
    theta0 ∈ icPercT thetaHat se qLo qHi ↔
      qLo ≤ bootPivot thetaHat theta0 se ∧ bootPivot thetaHat theta0 se ≤ qHi := by
  simp only [icPercT, Set.mem_Icc, bootPivot]
  rw [div_le_iff₀ hse, le_div_iff₀ hse]
  constructor
  · rintro ⟨h1, h2⟩
    constructor <;> linarith
  · rintro ⟨h1, h2⟩
    constructor <;> linarith

/-- book: capitulos/cap04_herramientas.typ:1739 (key: def:ch5-ic-t) — el
intervalo percentil-t es un intervalo de extremos ordenados (no vacío) cuando
los cuantiles están ordenados y `ŜE ≥ 0`. -/
theorem icPercT_extremos {thetaHat se qLo qHi : ℝ} (hse : 0 ≤ se) (hq : qLo ≤ qHi) :
    thetaHat - qHi * se ≤ thetaHat - qLo * se := by
  have h : qLo * se ≤ qHi * se := mul_le_mul_of_nonneg_right hq hse
  linarith

/-- book: capitulos/cap04_herramientas.typ:1739 (key: def:ch5-ic-t) — el
intervalo percentil-t contiene al estimador `θ̂_n` siempre que los cuantiles
bootstrap straddle el cero, `qLo ≤ 0 ≤ qHi`; es la comprobación de que el
intervalo es el que el libro describe y no una traslación. -/
theorem icPercT_contiene_estimador {thetaHat se qLo qHi : ℝ} (hse : 0 ≤ se)
    (hlo : qLo ≤ 0) (hhi : 0 ≤ qHi) : thetaHat ∈ icPercT thetaHat se qLo qHi := by
  simp only [icPercT, Set.mem_Icc]
  constructor
  · have h : 0 ≤ qHi * se := mul_nonneg hhi hse
    linarith
  · have h : qLo * se ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hlo hse
    linarith

/-- book: capitulos/cap04_herramientas.typ:1739 (key: def:ch5-ic-t) — con
cuantiles simétricos `qLo = −z`, `qHi = z` el intervalo percentil-t es el
intervalo normal `θ̂ ± z·ŜE`, como debe ser. -/
theorem icPercT_simetrico (thetaHat se z : ℝ) :
    icPercT thetaHat se (-z) z = Set.Icc (thetaHat - z * se) (thetaHat + z * se) := by
  simp [icPercT]

/-! ## 3. `ex:ch5-bandas` — Bandas de confianza para la CDF vía Donsker

El libro (`cap04_herramientas.typ:1676`): del límite de Donsker,
`sup_x |𝔾_n(x)| →d sup_{t∈[0,1]} |B(t)|` (ley de Kolmogorov); sea `c_α` el
cuantil `1−α` de `sup_t |B(t)|`; entonces
`P(F(x) ∈ [F̂_n(x) ± c_α/√n] ∀x) → 1−α`.

Se formaliza el núcleo exacto: (i) la banda es **el mismo evento** que
`√n·sup_x|F̂_n(x) − F(x)| ≤ c_α`, es decir el estadístico de
Kolmogorov–Smirnov contra el umbral `c_α` (de ahí que el cuantil de
Kolmogorov dé la banda); (ii) `c_α` definido como cuantil `1−α` de la ley
límite, con su propiedad de cuantil; (iii) el criterio de monitoreo del
libro: la CDF de referencia `F₀` «sale de la banda» exactamente cuando el
estadístico de KS supera el umbral. -/

/-- El estadístico de Kolmogorov–Smirnov entre `F̂_n` y `F`:
`ksStat F̂ F = sup_x |F̂(x) − F(x)|` (book: `ex:ch5-bandas`). -/
noncomputable def ksStat (Fhat F : ℝ → ℝ) : ℝ := sSup (Set.range fun x => |Fhat x - F x|)

/-- La banda de confianza del libro: `F(x) ∈ [F̂_n(x) ± c/√n]` para todo `x`
(book: `ex:ch5-bandas`). -/
def banda (Fhat F : ℝ → ℝ) (c : ℝ) (n : ℕ) : Prop := ∀ x, |Fhat x - F x| ≤ c / Real.sqrt n

/-- book: capitulos/cap04_herramientas.typ:1676 (key: ex:ch5-bandas) —
**La banda es el evento del estadístico de Kolmogorov–Smirnov**: para una
muestra de tamaño `n ≥ 1` y `sup_x |F̂_n − F| < ∞`,
`(∀x, F(x) ∈ [F̂_n(x) ± c/√n]) ⟺ √n · sup_x |F̂_n(x) − F(x)| ≤ c`.

Esto es lo que convierte el límite de Donsker `sup_x|𝔾_n(x)| →d
sup_t|B(t)|` en la banda del libro: el evento cuya probabilidad tiende a
`1−α` es `{ksStat ≤ c_α/√n}`. Fidelidad declarada: se formaliza la
equivalencia de eventos y la definición del cuantil; el límite de Donsker
propiamente dicho (convergencia débil en `ℓ^∞`, citado en el libro) no se
reproduce, y la igualdad distribucional
`sup_x|𝔾_n(x)| =d sup_t|B(t)|` tampoco. -/
theorem banda_iff_ksStat {Fhat F : ℝ → ℝ} {c : ℝ} {n : ℕ} (hn : 0 < n)
    (hbd : BddAbove (Set.range fun x => |Fhat x - F x|)) :
    banda Fhat F c n ↔ Real.sqrt n * ksStat Fhat F ≤ c := by
  have hs : (0:ℝ) < Real.sqrt n := Real.sqrt_pos_of_pos (by exact_mod_cast hn)
  have hne : (Set.range fun x => |Fhat x - F x|).Nonempty := Set.range_nonempty _
  have key : Real.sqrt n * ksStat Fhat F ≤ c ↔ ksStat Fhat F ≤ c / Real.sqrt n := by
    rw [le_div_iff₀ hs, mul_comm]
  rw [key, banda, ksStat]
  constructor
  · intro h
    exact csSup_le hne fun b hb => by
      obtain ⟨x, rfl⟩ := hb
      exact h x
  · intro h x
    exact le_trans (le_csSup hbd ⟨x, rfl⟩) h

/-- book: capitulos/cap04_herramientas.typ:1676 (key: ex:ch5-bandas) — **el
criterio de monitoreo del libro**: la CDF de referencia `F₀` «sale de la
banda» (es decir, la banda falla en algún `x`) si y sólo si el estadístico de
Kolmogorov–Smirnov supera el umbral `c_α/√n`. Es la contrapositiva de
`banda_iff_ksStat`, y es la forma en que el libro usa la banda para detectar
cambios de distribución. -/
theorem banda_falla_iff {Fhat F : ℝ → ℝ} {c : ℝ} {n : ℕ} (hn : 0 < n)
    (hbd : BddAbove (Set.range fun x => |Fhat x - F x|)) :
    ¬ banda Fhat F c n ↔ c < Real.sqrt n * ksStat Fhat F := by
  rw [banda_iff_ksStat hn hbd]
  exact not_le

/-- `c_α`, el cuantil `1−α` de la ley límite `sup_{t∈[0,1]} |B(t)|` (la ley
de Kolmogorov): el ínfimo de los niveles que acumulan masa `≥ 1−α` bajo esa
ley (book: `ex:ch5-bandas`). Se toma la ley límite como parámetro `muKS`
porque el libro la obtiene del teorema de Donsker, que aquí no se formaliza. -/
noncomputable def ksQuantile (muKS : Measure ℝ) (alpha : ℝ) : ℝ :=
  sInf {c : ℝ | ENNReal.ofReal (1 - alpha) ≤ muKS (Set.Iic c)}

/-- book: capitulos/cap04_herramientas.typ:1676 (key: ex:ch5-bandas) —
**`c_α` es un cuantil `1−α`**: para todo `ε > 0`, el nivel `c_α + ε` ya
acumula masa `≥ 1−α` bajo la ley de Kolmogorov. Es la propiedad que hace que
la banda `F̂_n(x) ± c_α/√n` tenga cobertura límite `1−α` (la cobertura
asintótica completa es el límite de Donsker, que no se reproduce). -/
theorem ksQuantile_spec {muKS : Measure ℝ} {alpha : ℝ}
    (hne : ({c : ℝ | ENNReal.ofReal (1 - alpha) ≤ muKS (Set.Iic c)}).Nonempty) {ε : ℝ} (hε : 0 < ε) :
    ENNReal.ofReal (1 - alpha) ≤ muKS (Set.Iic (ksQuantile muKS alpha + ε)) := by
  by_contra h
  simp only [not_le] at h
  have hlb : ∀ c : ℝ, ENNReal.ofReal (1 - alpha) ≤ muKS (Set.Iic c) →
      ksQuantile muKS alpha + ε ≤ c := by
    intro c hc
    by_contra hlt
    simp only [not_le] at hlt
    have hle : muKS (Set.Iic c) ≤ muKS (Set.Iic (ksQuantile muKS alpha + ε)) :=
      measure_mono (Set.Iic_subset_Iic.mpr hlt.le)
    exact absurd h (not_lt.mpr (le_trans hc hle))
  have h2 : ksQuantile muKS alpha + ε ≤ ksQuantile muKS alpha := le_csInf hne hlb
  linarith

end BookCh5M5
