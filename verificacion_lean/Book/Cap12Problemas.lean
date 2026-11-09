import Mathlib

/-!
# Book.Cap12Problemas — cap. 12 del libro (capitulos/cap12_problemas.typ)

Tres resultados del capítulo de problemas abiertos:

* `thm:ch12-pomdp-identification` — identificación en POMDPs: el peso
  `W_t = ∏_{u≤t} π_u(A_u|H_u)/b_u(A_u|H_u)` es la derivada de la ley objetivo
  de la historia respecto de la observada hasta `R_t`, de donde
  `J(π) = E_b[∑_t γ^t W_t R_t]`.
* `prop:ch12-logprobs` — la propensity de una acción textual calculada con
  log-probabilidades por token: `exp(∑_j logprob(t_j)) = ∏_j p(t_j|o,t_{<j})`,
  y su limitación (sirve solo para el modelo que generó los datos).
* `prop:ch12-sesgo-disc` — sesgo de discretización: `|J(π) − J(π_g)| ≤ ε` en una
  decisión con pesos que suman 1, y `|V^{π_g} − V^{π}| ≤ ε/(1−γ)` en horizonte
  infinito descontado mediante la identidad de diferencia de rendimiento.

## Fidelidad declarada

* **Parte 1** (POMDP). Espacios `S` (observación/estado observado) y `A`
  finitos; horizonte finito `H`; ley inicial `ν` (peso; no se normaliza) y un
  mismo kernel del entorno `K` bajo ambas políticas — la hipótesis «los mismos
  kernels del entorno bajo ambas políticas» del libro. Las políticas se
  codifican como `p : List (A × S) → A → ℝ`, es decir `p(prefijo_t)(a)` es
  `P(A_t = a | H_t)`: dependen del historial completo (observaciones y acciones
  anteriores), que es lo que el libro denota `π_t(a|H_t)`; la dependencia en `t`
  queda determinada por la longitud del prefijo y no se impone ninguna
  restricción de forma. La recompensa `R_t` es una función arbitraria de la
  historia hasta el paso `t` (admite recompensas que dependen de la acción y de
  toda la historia observada). «Soporte objetivo cubierto» se declara como
  `∀ h a, 0 < b h a` (positividad de la política observada), que es la
  condición que hace que el cociente esté definido. `ν`, `K`, `p` son pesos
  reales arbitrarios: la identidad es algebraica y no usa normalización ni
  `0 ≤ ·` (las cotas por sumas de probabilidades sí las usarán las Partes 2–3).
  Horizonte finito es el enunciado del libro; el paso al horizonte infinito
  descontado no forma parte de este teorema.
* **Parte 2** (log-probs). La acción textual `a = (t_1,…,t_K)` se representa por
  la sucesión `p : Fin K → ℝ` de probabilidades condicionales por token
  `p_j = p(t_j | o, t_{<j})` del muestreador efectivo (después de temperatura,
  filtros y restricciones, como exige el libro), con `0 < p_j` (el libro pide
  que el producto sea probabilidad de la acción completa; sin positividad el
  `log` no está definido). Se supone `lp j = log (p j)`, es decir que las
  log-probabilidades suministradas son las del modelo que generó los datos: es
  exactamente la «Limitación» que el libro declara, y el segundo teorema
  exhibe un testigo numérico de que sin ella el estimador no es la propensity.
* **Parte 3** (discretización). Primera cota: decisión a un paso con
  distribución del estado `d ≥ 0`, `∑ d = 1`, independiente de la acción (el
  estado se observa antes de decidir; «integrar la diferencia de recompensas»),
  política `p` con `p s ≥ 0`, `∑_a p s a = 1`, plantilla `g : A → A` y
  `sup_{s,a} |m(s,a) − m(s,g(a))| ≤ ε`. Segunda cota: MDP finito descontado con
  núcleo de transición normalizado `P ≥ 0`, `∑_{s'} P s a s' = 1`;
  `V` y `U` son los puntos fijos de Bellman de `π` y de la política agrupada
  `s ↦ g(π s)`. Por la ecuación de Bellman, ese punto fijo es la función de
  valor `V^π` (el lema `bellman_fixedPoint_unique` prueba su unicidad para
  `γ < 1`), de modo que la hipótesis `hQ` es literalmente
  `sup_{s,a} |Q^π(s,a) − Q^π(s,g(a))| ≤ ε`, la «condición análoga sobre Q^π,
  uniforme en estados y acciones» del libro. No se toma ningún límite: la
  cota `ε/(1−γ)` sale del argumento de contracción sobre
  `sup_s |U s − V s|`, que es la forma infinitesimal de la identidad de
  diferencia de rendimiento.

Verificado con el entorno del proyecto (Mathlib precompilado en `/opt/mathlib`,
`LEAN_PATH` del entorno), `#print axioms` ⊆ {propext, Classical.choice,
Quot.sound}. Origen: enjambre smw8gy947 (m12).
-/

open Finset BigOperators

noncomputable section

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

/-! ## Parte 1 — Identificación en POMDPs (`thm:ch12-pomdp-identification`) -/

/-- Historia observable de `n` decisiones: los estados observados
`σ 0, …, σ n` (con `σ 0` la observación inicial) y las acciones
`a 0, …, a (n-1)`. Codifica `H_t` para `t = n`: el historial antes de `A_t`
son los `n = t+1` pares acción/observación precedentes. -/
structure Hist (S A : Type*) (n : ℕ) where
  /-- Observaciones (estados observados) en los pasos `0 … n`. -/
  σ : Fin (n + 1) → S
  /-- Acciones en los pasos `0 … n-1`. -/
  a : Fin n → A
deriving Fintype

namespace Hist

variable {S A : Type*} [Fintype S] [Fintype A]

/-- Pares (acción, observación siguiente) del historial:
`[(a_0, σ_1), …, (a_{n-1}, σ_n)]`. -/
def pairs (h : Hist S A n) : List (A × S) :=
  List.ofFn fun j : Fin n => (h.a j, h.σ j.succ)

/-- Prefijo del historial antes de la acción `i`:
`[(a_0, σ_1), …, (a_{i-1}, σ_i)]`, es decir `H_i`. -/
def pfx (h : Hist S A n) (i : Fin n) : List (A × S) := (pairs h).take i

/-- Peso (densidad no normalizada) de la historia bajo la política `p`: ley
inicial por el producto de las probabilidades de acción y de los núcleos del
entorno, `ν · ∏_{u<n} p_u(a_u|H_u) · K(σ_{u+1} | σ_u, a_u)`. -/
def lawc (ν : ℝ) (K : S → A → S → ℝ) (p : List (A × S) → A → ℝ) (h : Hist S A n) : ℝ :=
  ν * ∏ i : Fin n, (p (pfx h i) (h.a i) * K (h.σ i.castSucc) (h.a i) (h.σ i.succ))

/-- Razón de importancia acumulada hasta el paso `n-1` (incluido), que es el
peso `W_t` del libro para `t = n-1`:
`W_t = ∏_{u=0}^{t} π_u(A_u|H_u)/b_u(A_u|H_u)`. -/
def isWeight (p b : List (A × S) → A → ℝ) (h : Hist S A n) : ℝ :=
  ∏ i : Fin n, (p (pfx h i) (h.a i) / b (pfx h i) (h.a i))

omit [Fintype S] [Fintype A] in
/-- El peso de la política objetivo factoriza como el peso observado por la
razón de importancia acumulada: `lawc π = lawc b · W_t` punto a punto. Los
núcleos del entorno `K` son los mismos bajo ambas políticas, así que se cancelan
(«se cancelan ν y los núcleos»); la positividad de `b` es la que permite dividir
paso a paso. -/
theorem lawc_eq_lawc_mul_isWeight (ν : ℝ) (K : S → A → S → ℝ)
    {p b : List (A × S) → A → ℝ} (hb : ∀ l a, 0 < b l a) (h : Hist S A n) :
    lawc ν K p h = lawc ν K b h * isWeight p b h := by
  have hbne : ∀ i : Fin n, b (pfx h i) (h.a i) ≠ 0 := fun i => ne_of_gt (hb _ _)
  have e1 : (∏ i : Fin n, (b (pfx h i) (h.a i) * K (h.σ i.castSucc) (h.a i) (h.σ i.succ)))
      = (∏ i : Fin n, b (pfx h i) (h.a i))
        * ∏ i : Fin n, K (h.σ i.castSucc) (h.a i) (h.σ i.succ) :=
    Finset.prod_mul_distrib
  have e2 : (∏ i : Fin n, (p (pfx h i) (h.a i) * K (h.σ i.castSucc) (h.a i) (h.σ i.succ)))
      = (∏ i : Fin n, p (pfx h i) (h.a i))
        * ∏ i : Fin n, K (h.σ i.castSucc) (h.a i) (h.σ i.succ) :=
    Finset.prod_mul_distrib
  have e3 : (∏ i : Fin n, (p (pfx h i) (h.a i) / b (pfx h i) (h.a i)))
      = (∏ i : Fin n, p (pfx h i) (h.a i)) / (∏ i : Fin n, b (pfx h i) (h.a i)) :=
    Finset.prod_div_distrib _ _
  have hbp : (∏ i : Fin n, b (pfx h i) (h.a i)) ≠ 0 :=
    Finset.prod_ne_zero_iff.mpr fun i _ => hbne i
  rw [lawc, lawc, isWeight, e1, e2, e3]
  field_simp

/-- Cambio de medida sobre historias de longitud `n`: para toda función `f` de
la historia hasta el paso `n-1` (la recompensa `R_t` «hecha observable»),
`E_π[f] = E_b[W_t · f]`, donde `W_t` es el producto de razones paso a paso. -/
theorem change_of_measure (ν : ℝ) (K : S → A → S → ℝ)
    {p b : List (A × S) → A → ℝ} (hb : ∀ l a, 0 < b l a) (f : Hist S A n → ℝ) :
    (∑ h : Hist S A n, lawc ν K p h * f h)
      = ∑ h : Hist S A n, lawc ν K b h * isWeight p b h * f h :=
  Finset.sum_congr rfl fun h _ => by rw [lawc_eq_lawc_mul_isWeight ν K hb h]

end Hist

open Hist in
/-- book: capitulos/cap12_problemas.typ:130 (key: thm:ch12-pomdp-identification) —
Identificación en POMDPs. En horizonte finito `H`, con la misma ley inicial `ν`
y los mismos kernels del entorno `K` bajo ambas políticas, política observada
`b` con soporte positivo (`∀ h a, 0 < b h a`, «soporte objetivo cubierto»), y
recompensas `R t : Hist S A (t+1) → ℝ` que dependen de la historia observable
hasta `R_t`, se tiene
`J(π) = ∑_{t<H} γ^t E_π[R_t] = ∑_{t<H} γ^t E_b[W_t R_t]`,
`W_t = ∏_{u≤t} π_u(A_u|H_u)/b_u(A_u|H_u)`.
La igualdad es término a término: `W_t` es la derivada de la ley objetivo de la
historia hasta `R_t` respecto de la observada. Fidelidad declarada en la
cabecera del módulo (finita, `K` de Markov común a ambas políticas, `R_t`
función de la historia, soporte positivo de `b`). -/
theorem ch12_pomdp_identification {S A : Type*} [Fintype S] [Fintype A]
    (H : ℕ) (ν : ℝ) (K : S → A → S → ℝ) (γ : ℝ)
    (π b : List (A × S) → A → ℝ) (hb : ∀ l a, 0 < b l a)
    (R : (t : ℕ) → Hist S A (t + 1) → ℝ) :
    (∑ t : Fin H, γ ^ (t : ℕ) * ∑ h : Hist S A (t.1 + 1), Hist.lawc ν K π h * R t.1 h)
      = ∑ t : Fin H, γ ^ (t : ℕ) *
          ∑ h : Hist S A (t.1 + 1), Hist.lawc ν K b h * Hist.isWeight π b h * R t.1 h := by
  refine Finset.sum_congr rfl fun t _ => ?_
  rw [show (∑ h : Hist S A (t.1 + 1), Hist.lawc ν K π h * R t.1 h)
      = ∑ h : Hist S A (t.1 + 1), Hist.lawc ν K b h * Hist.isWeight π b h * R t.1 h
      from Hist.change_of_measure ν K hb (R t.1)]

/-! ## Parte 2 — Propensity vía log-probs (`prop:ch12-logprobs`) -/

/-- book: capitulos/cap12_problemas.typ:189 (key: prop:ch12-logprobs) —
Propensity de una acción textual: producto de las probabilidades condicionales
por token del muestreador efectivo (`def:ch12-propensity`),
`π_b(a|o) = ∏_{j<K} p(t_j | o, t_{<j})`. -/
def propensity {K : ℕ} (p : Fin K → ℝ) : ℝ := ∏ j, p j

/-- book: capitulos/cap12_problemas.typ:189 (key: prop:ch12-logprobs) —
Estimador de la propensity a partir de las log-probabilidades por token que
devuelve el modelo: `π̂_b(a|o) = exp(∑_j logprob(t_j))`. -/
def logprobEst {K : ℕ} (lp : Fin K → ℝ) : ℝ := Real.exp (∑ j, lp j)

/-- book: capitulos/cap12_problemas.typ:189 (key: prop:ch12-logprobs) —
Si el modelo proporciona las log-probabilidades por token del muestreador
efectivo (`lp j = log (p j)`, con `p j > 0`), entonces
`π̂_b(a|o) = exp(∑_j logprob(t_j)) = ∏_j p(t_j|o,t_{<j}) = π_b(a|o)`.
Fidelidad declarada: `K = |a|` tokens; la condición sobre `o` y los tokens
anteriores entra en las probabilidades condicionales `p j`; la positividad es
necesaria para que `log` esté definido. -/
theorem ch12_logprobs {K : ℕ} (p lp : Fin K → ℝ) (hp : ∀ j, 0 < p j)
    (hlp : ∀ j, lp j = Real.log (p j)) :
    logprobEst lp = propensity p := by
  simp only [logprobEst, propensity, hlp]
  rw [Real.exp_sum]
  exact Finset.prod_congr rfl fun j _ => Real.exp_log (hp j)

/-- book: capitulos/cap12_problemas.typ:189 (key: prop:ch12-logprobs) —
Limitación: si las log-probabilidades suministradas no son las del muestreador
efectivo, el estimador no es la propensity. Testigo: con `K = 1` token, una
política que muestrea con probabilidad `1/2` y un modelo base que declara
`log (1/5)` dan `π̂_b = 1/5 ≠ 1/2 = π_b` (temperatura/filtros cambian las
probabilidades sin cambiar el texto de la acción). -/
theorem ch12_logprobs_limite :
    logprobEst (fun _ : Fin 1 => Real.log (1 / 5)) ≠ propensity (fun _ : Fin 1 => (1 / 2 : ℝ)) := by
  simp only [logprobEst, propensity, Fin.sum_univ_one, Fin.prod_univ_one,
    Real.exp_log (by norm_num : (0 : ℝ) < 1 / 5)]
  norm_num

/-! ## Parte 3 — Sesgo de discretización (`prop:ch12-sesgo-disc`) -/

open Hist in
/-- book: capitulos/cap12_problemas.typ:230 (key: prop:ch12-sesgo-disc) —
Sesgo de discretización en una decisión. Con el estado observado antes de
decidir (`d ≥ 0`, `∑ d = 1`, independiente de la acción) y plantilla
`g : A → A` que agrupa acciones, si `sup_{s,a} |m(s,a) − m(s,g(a))| ≤ ε`,
entonces integrar la diferencia de recompensas da
`|J(π) − J(π_g)| ≤ ε`, donde `J(π) = ∑_s d s ∑_a p s a m s a` y la política
agrupada es la imagen `π_g = g ∘ π`, es decir `J(π_g) = ∑_s d s ∑_a p s a m s (g a)`.
Fidelidad declarada: decisión a un paso, `p s` probabilidad sobre `A` para cada
`s` (admite políticas aleatorizadas); `ε ≥ 0`. -/
theorem ch12_sesgo_disc_finito {S A : Type*} [Fintype S] [Fintype A]
    (d : S → ℝ) (p : S → A → ℝ) (m : S → A → ℝ) (g : A → A) (ε : ℝ)
    (hd0 : ∀ s, 0 ≤ d s) (hd1 : ∑ s, d s = 1)
    (hp0 : ∀ s a, 0 ≤ p s a) (hp1 : ∀ s, ∑ a, p s a = 1)
    (hε : 0 ≤ ε) (hsup : ∀ s a, |m s a - m s (g a)| ≤ ε) :
    |(∑ s, d s * ∑ a, p s a * m s a) - (∑ s, d s * ∑ a, p s a * m s (g a))| ≤ ε := by
  -- La diferencia es la integral de `m(s,a) − m(s,g(a))`.
  have hsplit : (∑ s, d s * ∑ a, p s a * m s a) - (∑ s, d s * ∑ a, p s a * m s (g a))
      = ∑ s, d s * ∑ a, p s a * (m s a - m s (g a)) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun s _ => ?_
    have h1 : (∑ a, p s a * m s a) - (∑ a, p s a * m s (g a))
        = ∑ a, p s a * (m s a - m s (g a)) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun a _ => by ring
    rw [← mul_sub, h1, Finset.mul_sum]
  rw [hsplit]
  -- Cota: `|∑ d · ∑ p · (m − m∘g)| ≤ ε · ∑ d · ∑ p = ε`.
  calc |∑ s, d s * ∑ a, p s a * (m s a - m s (g a))|
      ≤ ∑ s, |d s * ∑ a, p s a * (m s a - m s (g a))| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ s, d s * ε := by
        refine Finset.sum_le_sum fun s _ => ?_
        rw [abs_mul, abs_of_nonneg (hd0 s)]
        have hinner : |∑ a, p s a * (m s a - m s (g a))| ≤ ∑ a, p s a * ε :=
          calc |∑ a, p s a * (m s a - m s (g a))|
              ≤ ∑ a, |p s a * (m s a - m s (g a))| := Finset.abs_sum_le_sum_abs _ _
            _ ≤ ∑ a, p s a * ε := by
                refine Finset.sum_le_sum fun a _ => ?_
                rw [abs_mul, abs_of_nonneg (hp0 s a)]
                exact mul_le_mul_of_nonneg_left (hsup s a) (hp0 s a)
        calc d s * |∑ a, p s a * (m s a - m s (g a))|
            ≤ d s * (∑ a, p s a * ε) := mul_le_mul_of_nonneg_left hinner (hd0 s)
          _ = d s * ε := by rw [← Finset.sum_mul, hp1, one_mul]
    _ = ε := by rw [← Finset.sum_mul, hd1, one_mul]

variable {S A : Type*} [Fintype S] [Fintype A]

/-- book: capitulos/cap12_problemas.typ:230 (key: prop:ch12-sesgo-disc) —
Función de valor-acción `Q^π(s,a) = m(s,a) + γ ∑_{s'} P(s,a,s') V^π(s')` a
partir de la función de valor `V` (que en los teoremas siguientes es el punto
fijo de Bellman de `π`, es decir `V^π`). -/
def Qfun (P : S → A → S → ℝ) (m : S → A → ℝ) (V : S → ℝ) (γ : ℝ) (s : S) (a : A) : ℝ :=
  m s a + γ * ∑ s', P s a s' * V s'

/-- book: capitulos/cap12_problemas.typ:230 (key: prop:ch12-sesgo-disc) —
Sesgo de discretización en horizonte infinito descontado: si `V` y `U` son los
puntos fijos de Bellman de `π` y de la política agrupada `g ∘ π` (es decir
`V^π` y `V^{π_g}`, por `bellman_fixedPoint_unique`) y
`sup_{s,a} |Q^π(s,a) − Q^π(s,g(a))| ≤ ε` uniforme en estados y acciones,
entonces `|V^{π_g}(s) − V^π(s)| ≤ ε/(1−γ)` en todo estado. El libro lo obtiene
de la identidad de diferencia de rendimiento; aquí es el argumento de
contracción `C ≤ ε + γC` sobre `C = sup_s |U s − V s|`, sin tomar límites.

Un punto fijo de Bellman (para `γ < 1` el punto fijo es único: la función de
valor `V^π`) dista de otro punto fijo como mucho `ε/(1−γ)` cuando las
`Q` asociadas difieren en a lo sumo `ε` al sustituir `a` por `g a`. Es el
argumento de contracción en norma sup: si `C = sup_s |U s − V s|`, entonces
`C ≤ ε + γ C`. -/
theorem ch12_sesgo_disc_descontado [Nonempty S]
    (P : S → A → S → ℝ) (m : S → A → ℝ) (π : S → A) (g : A → A) (γ ε : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (hε : 0 ≤ ε)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    {V U : S → ℝ}
    (hV : ∀ s, V s = Qfun P m V γ s (π s))
    (hU : ∀ s, U s = Qfun P m U γ s (g (π s)))
    (hQ : ∀ s a, |Qfun P m V γ s a - Qfun P m V γ s (g a)| ≤ ε) :
    ∀ s, |U s - V s| ≤ ε / (1 - γ) := by
  classical
  -- Paso 1: descomposición de la diferencia en la diferencia de `Q` más el
  -- término de continuación con el núcleo de la política agrupada.
  have hd : ∀ (s : S) (a : A),
      (∑ s', P s a s' * (U s' - V s'))
        = (∑ s', P s a s' * U s') - ∑ s', P s a s' * V s' := by
    intro s a
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun s' _ => by ring
  have hstep : ∀ s, U s - V s
      = (Qfun P m V γ s (g (π s)) - Qfun P m V γ s (π s))
        + γ * ∑ s', P s (g (π s)) s' * (U s' - V s') := by
    intro s
    rw [hU s, hV s]
    simp only [Qfun]
    rw [hd s (g (π s))]
    ring
  -- Paso 2: cota uniforme con el término de continuación.
  have hbound : ∀ s, |U s - V s|
      ≤ ε + γ * ∑ s', P s (g (π s)) s' * |U s' - V s'| := by
    intro s
    rw [hstep s]
    have h1 : |Qfun P m V γ s (g (π s)) - Qfun P m V γ s (π s)| ≤ ε := by
      rw [abs_sub_comm]
      exact hQ s (π s)
    have h2 : |γ * ∑ s', P s (g (π s)) s' * (U s' - V s')|
        ≤ γ * ∑ s', P s (g (π s)) s' * |U s' - V s'| := by
      rw [abs_mul, abs_of_nonneg hγ0]
      refine mul_le_mul_of_nonneg_left ?_ hγ0
      calc |∑ s', P s (g (π s)) s' * (U s' - V s')|
          ≤ ∑ s', |P s (g (π s)) s' * (U s' - V s')| := Finset.abs_sum_le_sum_abs _ _
        _ = ∑ s', P s (g (π s)) s' * |U s' - V s'| := by
            refine Finset.sum_congr rfl fun s' _ => ?_
            rw [abs_mul, abs_of_nonneg (hP0 s (g (π s)) s')]
    calc |(Qfun P m V γ s (g (π s)) - Qfun P m V γ s (π s))
          + γ * ∑ s', P s (g (π s)) s' * (U s' - V s')|
        ≤ |Qfun P m V γ s (g (π s)) - Qfun P m V γ s (π s)|
          + |γ * ∑ s', P s (g (π s)) s' * (U s' - V s')| := abs_add_le _ _
      _ ≤ ε + γ * ∑ s', P s (g (π s)) s' * |U s' - V s'| := add_le_add h1 h2
  -- Paso 3: el máximo de `|U − V|` sobre el espacio finito de estados.
  obtain ⟨smax, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset S) (fun s => |U s - V s|)
      (Finset.univ_nonempty)
  have hC : ∀ s, |U s - V s| ≤ |U smax - V smax| := fun s => hmax s (Finset.mem_univ s)
  have hkey : |U smax - V smax| ≤ ε + γ * |U smax - V smax| := by
    refine (hbound smax).trans ?_
    have hsum : (∑ s', P smax (g (π smax)) s' * |U s' - V s'|)
        ≤ ∑ s', P smax (g (π smax)) s' * |U smax - V smax| :=
      Finset.sum_le_sum fun s' _ =>
        mul_le_mul_of_nonneg_left (hC s') (hP0 smax (g (π smax)) s')
    have hsum' : (∑ s', P smax (g (π smax)) s' * |U smax - V smax|)
        = |U smax - V smax| := by
      rw [← Finset.sum_mul, hP1, one_mul]
    calc ε + γ * ∑ s', P smax (g (π smax)) s' * |U s' - V s'|
        ≤ ε + γ * ∑ s', P smax (g (π smax)) s' * |U smax - V smax| := by
          have := mul_le_mul_of_nonneg_left hsum hγ0
          linarith
      _ = ε + γ * |U smax - V smax| := by rw [hsum']
  have hfinal : |U smax - V smax| ≤ ε / (1 - γ) := by
    have h1γ : 0 < 1 - γ := by linarith
    rw [le_div_iff₀ h1γ]
    nlinarith [hkey]
  exact fun s => (hC s).trans hfinal

/-- La función de valor es el único punto fijo de Bellman para `γ < 1`: dos
soluciones de `V = m(·,π) + γ P_π V` coinciden. Justifica que en
`ch12_sesgo_disc_descontado` las funciones `V` y `U` son `V^π` y `V^{π_g}`. -/
theorem bellman_fixedPoint_unique [Nonempty S]
    (P : S → A → S → ℝ) (m : S → A → ℝ) (π : S → A) (γ : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    {V W : S → ℝ}
    (hV : ∀ s, V s = m s (π s) + γ * ∑ s', P s (π s) s' * V s')
    (hW : ∀ s, W s = m s (π s) + γ * ∑ s', P s (π s) s' * W s') :
    V = W := by
  classical
  have hd : ∀ (s : S) (a : A),
      (∑ s', P s a s' * (V s' - W s'))
        = (∑ s', P s a s' * V s') - ∑ s', P s a s' * W s' := by
    intro s a
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun s' _ => by ring
  have hstep : ∀ s, V s - W s = γ * ∑ s', P s (π s) s' * (V s' - W s') := by
    intro s
    rw [hV s, hW s, hd s (π s)]
    ring
  have hbound : ∀ s, |V s - W s| ≤ γ * ∑ s', P s (π s) s' * |V s' - W s'| := by
    intro s
    rw [hstep s, abs_mul, abs_of_nonneg hγ0]
    refine mul_le_mul_of_nonneg_left ?_ hγ0
    calc |∑ s', P s (π s) s' * (V s' - W s')|
        ≤ ∑ s', |P s (π s) s' * (V s' - W s')| := Finset.abs_sum_le_sum_abs _ _
      _ = ∑ s', P s (π s) s' * |V s' - W s'| := by
          refine Finset.sum_congr rfl fun s' _ => ?_
          rw [abs_mul, abs_of_nonneg (hP0 s (π s) s')]
  obtain ⟨smax, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset S) (fun s => |V s - W s|)
      (Finset.univ_nonempty)
  have hC : ∀ s, |V s - W s| ≤ |V smax - W smax| := fun s => hmax s (Finset.mem_univ s)
  have hkey : |V smax - W smax| ≤ γ * |V smax - W smax| := by
    refine (hbound smax).trans ?_
    have hsum : (∑ s', P smax (π smax) s' * |V s' - W s'|)
        ≤ ∑ s', P smax (π smax) s' * |V smax - W smax| :=
      Finset.sum_le_sum fun s' _ =>
        mul_le_mul_of_nonneg_left (hC s') (hP0 smax (π smax) s')
    have hsum' : (∑ s', P smax (π smax) s' * |V smax - W smax|)
        = |V smax - W smax| := by
      rw [← Finset.sum_mul, hP1, one_mul]
    calc γ * ∑ s', P smax (π smax) s' * |V s' - W s'|
        ≤ γ * ∑ s', P smax (π smax) s' * |V smax - W smax| :=
          mul_le_mul_of_nonneg_left hsum hγ0
      _ = γ * |V smax - W smax| := by rw [hsum']
  have hzero : |V smax - W smax| = 0 := by nlinarith [hkey, abs_nonneg (V smax - W smax)]
  funext s
  have hs : |V s - W s| = 0 := le_antisymm ((hC s).trans hzero.le) (abs_nonneg _)
  exact sub_eq_zero.mp (abs_eq_zero.mp hs)

/-- Cota uniforme integrada contra una distribución: si `|U s − V s| ≤ c` para todo
estado y `d ≥ 0`, `∑ d = 1`, entonces `|∑_s d s (U s − V s)| ≤ c`. Es el paso
«integrar la cota» con el que el libro pasa de la condición uniforme a la
diferencia de valores `|J(π) − J(π_g)|`. -/
theorem uniform_bound_integral {S : Type*} [Fintype S]
    (d V U : S → ℝ) (c : ℝ) (hd0 : ∀ s, 0 ≤ d s) (hd1 : ∑ s, d s = 1)
    (hc : 0 ≤ c) (hVU : ∀ s, |U s - V s| ≤ c) :
    |∑ s, d s * (U s - V s)| ≤ c := by
  calc |∑ s, d s * (U s - V s)|
      ≤ ∑ s, |d s * (U s - V s)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ s, d s * c := by
        refine Finset.sum_le_sum fun s _ => ?_
        rw [abs_mul, abs_of_nonneg (hd0 s)]
        exact mul_le_mul_of_nonneg_left (hVU s) (hd0 s)
    _ = c := by rw [← Finset.sum_mul, hd1, one_mul]

/-- book: capitulos/cap12_problemas.typ:230 (key: prop:ch12-sesgo-disc) —
Forma `|J(π) − J(π_g)| ≤ ε/(1−γ)` en horizonte infinito descontado: con las
mismas hipótesis que `ch12_sesgo_disc_descontado` y cualquier distribución
inicial `d ≥ 0` con `∑ d = 1`, la diferencia de valores esperados está acotada
por `ε/(1−γ)`. -/
theorem ch12_sesgo_disc_descontado_valor [Nonempty S]
    (P : S → A → S → ℝ) (m : S → A → ℝ) (π : S → A) (g : A → A) (γ ε : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (hε : 0 ≤ ε)
    (hP0 : ∀ s a s', 0 ≤ P s a s') (hP1 : ∀ s a, ∑ s', P s a s' = 1)
    {V U : S → ℝ}
    (hV : ∀ s, V s = Qfun P m V γ s (π s))
    (hU : ∀ s, U s = Qfun P m U γ s (g (π s)))
    (hQ : ∀ s a, |Qfun P m V γ s a - Qfun P m V γ s (g a)| ≤ ε)
    (d : S → ℝ) (hd0 : ∀ s, 0 ≤ d s) (hd1 : ∑ s, d s = 1) :
    |∑ s, d s * (U s - V s)| ≤ ε / (1 - γ) :=
  uniform_bound_integral d V U (ε / (1 - γ)) hd0 hd1
    (div_nonneg hε (by linarith))
    (ch12_sesgo_disc_descontado P m π g γ ε hγ0 hγ1 hε hP0 hP1 hV hU hQ)

/-! ## Parte 1b — La razón de un solo paso no corrige la historia previa

El libro cierra `thm:ch12-pomdp-identification` con una advertencia: «Una razón
solo del tiempo `t` no corrige la distribución de historias inducida por las
acciones anteriores». Aquí se formaliza el testigo: en la instancia trivial
(estado de un punto, dos acciones, entorno sin efecto) la razón de importancia
completa reproduce la expectativa objetivo, y la razón del último paso aislada
no. -/

namespace Contrajemplo

/-- Entorno sin efecto: `K ≡ 1`. -/
def K1 : Unit → Bool → Unit → ℝ := fun _ _ _ => 1

/-- Política objetivo: siempre la misma acción con probabilidad `1`. -/
def polPi : List (Bool × Unit) → Bool → ℝ := fun _ _ => 1

/-- Política observada: uniforme, `b ≡ 1/2`. -/
def polB : List (Bool × Unit) → Bool → ℝ := fun _ _ => 1 / 2

/-- Peso «de un solo paso»: solo la razón del último paso
(`u = t = 1`), sin el producto de los pasos anteriores. -/
def naiveWeight (h : Hist Unit Bool 2) : ℝ :=
  polPi (Hist.pfx h 1) (h.a 1) / polB (Hist.pfx h 1) (h.a 1)

/-- En la instancia, el peso completo `W_1` sí reproduce la expectativa
objetivo del último paso (caso `f ≡ 1` de `Hist.change_of_measure`). -/
theorem isWeight_corrige :
    (∑ h : Hist Unit Bool 2, Hist.lawc 1 K1 polPi h)
      = ∑ h : Hist Unit Bool 2, Hist.lawc 1 K1 polB h * Hist.isWeight polPi polB h :=
  by
    have h := Hist.change_of_measure (n := 2) (p := polPi) (b := polB) 1 K1
      (fun _ _ => by simp only [polB]; norm_num) (fun _ => (1 : ℝ))
    simpa using h

/-- Y la razón del último paso aislada **no** la reproduce: `E_π[R_1] = 4`
mientras que `E_b[(π_1/b_1)·R_1] = 2`. Por tanto la razón por paso suelta no
identifica el valor: hace falta el producto `W_t`. -/
theorem naiveWeight_falla :
    (∑ h : Hist Unit Bool 2, Hist.lawc 1 K1 polPi h)
      ≠ ∑ h : Hist Unit Bool 2, Hist.lawc 1 K1 polB h * naiveWeight h := by
  have hL : ∀ h : Hist Unit Bool 2, Hist.lawc 1 K1 polPi h = 1 := by
    intro h
    simp [Hist.lawc, K1, polPi]
  have hR : ∀ h : Hist Unit Bool 2, Hist.lawc 1 K1 polB h * naiveWeight h = 1 / 2 := by
    intro h
    simp only [Hist.lawc, naiveWeight, K1, polPi, polB, mul_one, Finset.prod_const,
      Finset.card_univ]
    norm_num
  rw [Finset.sum_congr rfl fun h _ => hL h, Finset.sum_congr rfl fun h _ => hR h,
    Finset.sum_const, Finset.sum_const, Finset.card_univ,
    show Fintype.card (Hist Unit Bool 2) = 4 from by decide]
  norm_num

end Contrajemplo

end
