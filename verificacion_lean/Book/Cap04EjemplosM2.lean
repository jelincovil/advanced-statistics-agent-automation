import Mathlib

/-!
# Book.Cap04EjemplosM2 — claves no reclamadas por ninguna dirección del enjambre

Cierra ocho claves de `argumentos/kernel/pendientes.json` que ninguna
dirección registrada del enjambre smw9820kx nombraba:

* `ex:ch6-parcialmente-lineal`, `ex:ch6-cox`, `ex:ch6-aipw-intro`,
  `ex:ch6-ope`, `ex:ch6-scores-canonicos`, `ex:ch6-dr-ssch`
  (`capitulos/cap04_herramientas.typ`),
* `ex:ssch-causal-cap06` (`capitulos/cap04_herramientas.typ:2061`),
* `ex:ssch-cap03-b` (`capitulos/cap10_casos.typ:98`).

Convención del proyecto (plan §6): cada teorema lleva su trazabilidad
`book: <archivo>:<línea> (key: <clave>)`, cero «s-o-r-r-y», y la fidelidad
declarada en el docstring cuando el libro enuncia un cálculo, una versión
continua o una propiedad asintótica y aquí se prueba el núcleo exacto que
se indica.  Los ejemplos numéricos se verifican en `ℚ` (valores exactos del
libro, sin coma flotante).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

namespace Book.Cap04EjemplosM2

/-! ## ex:ch6-dr-ssch — OPE de una decisión: cálculo completo -/

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
pesos de razón marginal del ejemplo: `π(1)/b(1) = 0.3/0.6 = 1/2` y
`π(2)/b(2) = 0.7/0.4 = 7/4`. Fidelidad declarada: contexto fijo de una sola
decisión; se verifica la aritmética exacta del libro. -/
theorem dr_ssch_pesos :
    ((3 : ℚ) / 10) / (3 / 5) = 1 / 2 ∧ ((7 : ℚ) / 10) / (2 / 5) = 7 / 4 := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
predicción bajo la política objetivo: `v̂ = 0.3·4 + 0.7·7 = 6.1`. -/
theorem dr_ssch_valor_objetivo : ((3 : ℚ) / 10) * 4 + ((7 : ℚ) / 10) * 7 = 61 / 10 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
pseudoresultados `v̂ + w·(R − q̂(A))` de los tres registros: `6.6`, `7.85`
y `5.6`. -/
theorem dr_ssch_pseudoresultados :
    ((61 : ℚ) / 10 + (1 / 2) * (5 - 4) = 33 / 5) ∧
    ((61 : ℚ) / 10 + (7 / 4) * (8 - 7) = 157 / 20) ∧
    ((61 : ℚ) / 10 + (1 / 2) * (3 - 4) = 28 / 5) := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
estimador aumentado `Ĵ = (6.6 + 7.85 + 5.6)/3 = 401/60`. -/
theorem dr_ssch_estimador :
    (((33 : ℚ) / 5) + (157 / 20) + (28 / 5)) / 3 = 401 / 60 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
estimador directo `v̂ = 6.1` y de importancia simple
`(0.5·5 + 1.75·8 + 0.5·3)/3 = 6`; los tres estimadores son distintos. -/
theorem dr_ssch_directo_ips :
    (((3 : ℚ) / 10) * 4 + ((7 : ℚ) / 10) * 7 = 61 / 10) ∧
    (((1 / 2 : ℚ) * 5 + (7 / 4) * 8 + (1 / 2) * 3) / 3 = 6) := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
las diferencias son muestrales: `401/60 ≠ 6.1` y `6.1 ≠ 6`. -/
theorem dr_ssch_tres_estimadores_distintos :
    ((401 : ℚ) / 60) ≠ 61 / 10 ∧ ((61 : ℚ) / 10) ≠ 6 := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
descomposición aumentada general: el promedio de los pseudoresultados
`v̂ + eᵢ` es `v̂` más el promedio de los residuos ponderados `eᵢ`. -/
theorem aumentado_descomposicion {ι : Type*} [Fintype ι] [Nonempty ι]
    (v : ℚ) (e : ι → ℚ) :
    (1 / (Fintype.card ι : ℚ)) * ∑ i, (v + e i)
      = v + (1 / (Fintype.card ι : ℚ)) * ∑ i, e i := by
  have hpos : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ‹Nonempty ι›
  have hcard : (Fintype.card ι : ℚ) ≠ 0 := by exact_mod_cast hpos.ne'
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1991 (key: ex:ch6-dr-ssch) —
el cálculo completo del libro como instancia de la descomposición: el
término muestral del estimador aumentado es `7/12`. -/
theorem dr_ssch_descomposicion :
    (1 / 3 : ℚ) * ((61 / 10 + (1 / 2) * (5 - 4))
        + (61 / 10 + (7 / 4) * (8 - 7)) + (61 / 10 + (1 / 2) * (3 - 4)))
      = 61 / 10 + (1 / 3) * ((1 / 2) * (5 - 4) + (7 / 4) * (8 - 7)
        + (1 / 2) * (3 - 4)) := by
  norm_num

/-! ## ex:ssch-causal-cap06 — confusión y estandarización -/

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
efecto ajustado por estratos: `ψ = (8−10)/2 + (16−20)/2 = −3`. -/
theorem ssch_psi : (1 / 2 : ℚ) * (8 - 10) + (1 / 2) * (16 - 20) = -3 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
propensiones por estrato: `e(0) = 0.2`, `e(1) = 0.8`, con `P(Z=z) = 1/2`. -/
theorem ssch_propensiones :
    ((1 / 2 : ℚ) * (1 / 5) = 1 / 10) ∧ ((1 / 2 : ℚ) * (4 / 5) = 2 / 5) := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
proporciones de estratos entre tratados `(0.2, 0.8)` y entre no tratados
`(0.8, 0.2)`: la mezcla de los tratados no es la poblacional. -/
theorem ssch_estratos_condicionales :
    (((1 / 2 : ℚ) * (4 / 5)) / ((1 / 2) * (1 / 5) + (1 / 2) * (4 / 5)) = 4 / 5) ∧
    (((1 / 2 : ℚ) * (1 / 5)) / ((1 / 2) * (1 / 5) + (1 / 2) * (4 / 5)) = 1 / 5) := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
medias observadas: `E[Y|A=1] = 0.2·8 + 0.8·16 = 14.4`,
`E[Y|A=0] = 0.8·10 + 0.2·20 = 12`. -/
theorem ssch_medias_observadas :
    ((1 / 5 : ℚ) * 8 + (4 / 5) * 16 = 72 / 5) ∧
    ((4 / 5 : ℚ) * 10 + (1 / 5) * 20 = 12) := by
  constructor <;> norm_num

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
diferencia cruda `14.4 − 12 = +2.4`, de signo opuesto al efecto ajustado
`−3`: la asociación observada no identifica el efecto. -/
theorem ssch_crudo_signo_opuesto :
    ((72 : ℚ) / 5 - 12 = 12 / 5) ∧ ((0 : ℚ) < 12 / 5) ∧ ((-3 : ℚ) < 0) := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
identidad general del sesgo de confusión en dos estratos: con
`p1 = P(Z=1)`, `qa = P(Z=1|A=a)`, la diferencia cruda menos el efecto
ajustado es `(q1 − p1)(m11 − m10) − (q0 − p1)(m01 − m00)`. -/
theorem sesgo_confusion (p1 q1 q0 m10 m11 m00 m01 : ℚ) :
    ((m10 + q1 * (m11 - m10)) - (m00 + q0 * (m01 - m00)))
        - (p1 * (m11 - m01) + (1 - p1) * (m10 - m00))
      = (q1 - p1) * (m11 - m10) - (q0 - p1) * (m01 - m00) := by
  ring

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
el sesgo de confusión del ejemplo vale `+5.4`: crudo `2.4` menos ajustado
`−3`. -/
theorem ssch_sesgo_confusion :
    (((8 : ℚ) + (4 / 5) * (16 - 8)) - (10 + (1 / 5) * (20 - 10))) - (-3) = 27 / 5 := by
  norm_num

/-! ## ex:ch6-scores-canonicos — scores de perturbaciones concretas -/

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
herramienta: derivada de `t ↦ log(c + t·m)` en `0`. La perturbación
`g_t = g + t·h` del submodelo normal y `e_t = e + t·h` del Bernoulli son
de esta forma afín. -/
theorem hasDerivAt_log_affine (c m : ℝ) (hc : c ≠ 0) :
    HasDerivAt (fun t : ℝ => Real.log (c + t * m)) (m / c) 0 := by
  have hinner : HasDerivAt (fun t : ℝ => c + t * m) m 0 := by
    simpa [mul_comm] using ((hasDerivAt_id (0 : ℝ)).const_mul m).const_add c
  have := hinner.log (by simpa using hc)
  simpa using this

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
herramienta: derivada de `t ↦ log(c − t·m)` en `0`. -/
theorem hasDerivAt_log_affine_sub (c m : ℝ) (hc : c ≠ 0) :
    HasDerivAt (fun t : ℝ => Real.log (c - t * m)) (-m / c) 0 := by
  have hinner : HasDerivAt (fun t : ℝ => c + t * (-m)) (-m) 0 := by
    simpa [mul_comm] using ((hasDerivAt_id (0 : ℝ)).const_mul (-m)).const_add c
  have hsub : (fun t : ℝ => c + t * (-m)) = (fun t : ℝ => c - t * m) := by
    funext t; ring
  rw [hsub] at hinner
  have := hinner.log (by simpa using hc)
  simpa using this

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
herramienta: desarrollo exacto en `t` de la log-densidad normal bajo
`μ_t = g + t·h`, con `ε = y − g`:
`−(y − (g + t h))²/(2σ²) = −ε²/(2σ²) + t·(ε·h/σ²) − t²h²/(2σ²)`. El
coeficiente lineal es el score `S_g = ε·h/σ²`. -/
theorem lognormal_expansion (g h y σ t : ℝ) (hσ : σ ≠ 0) :
    -(y - (g + t * h)) ^ 2 / (2 * σ ^ 2)
      = -(y - g) ^ 2 / (2 * σ ^ 2) + t * ((y - g) * h / σ ^ 2)
        - t ^ 2 * h ^ 2 / (2 * σ ^ 2) := by
  have hσ2 : (2 * σ ^ 2) ≠ 0 := by
    have : σ ^ 2 ≠ 0 := pow_ne_zero 2 hσ
    positivity
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
en la regresión parcialmente lineal con error normal de varianza conocida,
perturbar `g` como `g_t = g + t·h` produce `S_g = h(Z)·ε/σ²` con
`ε = y − g(Z)`: la derivada en `t = 0` de la log-verosimilitud normal
(parte que depende de la media; `−log(σ√(2π))` es constante en `t`).
Fidelidad declarada: se deriva la parte de la log-densidad que depende de
la media. -/
theorem score_normal (g h y σ : ℝ) (hσ : σ ≠ 0) :
    HasDerivAt (fun t : ℝ => -(y - (g + t * h)) ^ 2 / (2 * σ ^ 2))
      ((y - g) * h / σ ^ 2) 0 := by
  have hfun : (fun t : ℝ => -(y - (g + t * h)) ^ 2 / (2 * σ ^ 2))
      = (fun t : ℝ => -(((y - g) - t * h) ^ 2) / (2 * σ ^ 2)) := by
    funext t; ring
  rw [hfun]
  have hbase : HasDerivAt (fun t : ℝ => (y - g) + t * (-h)) (-h) 0 := by
    simpa [mul_comm] using ((hasDerivAt_id (0 : ℝ)).const_mul (-h)).const_add (y - g)
  have hsq : HasDerivAt (fun t : ℝ => ((y - g) + t * (-h)) ^ 2)
      ((-h) * ((y - g) + 0 * (-h)) + ((y - g) + 0 * (-h)) * (-h)) 0 := by
    have hm := hbase.mul hbase
    have hfun : (fun t : ℝ => ((y - g) + t * (-h)) ^ 2)
        = ((fun t : ℝ => (y - g) + t * (-h)) * fun t => (y - g) + t * (-h)) := by
      funext t
      simp only [Pi.mul_apply]
      ring
    rw [hfun]
    exact hm
  have hquad : HasDerivAt
      (fun t : ℝ => ((y - g) + t * (-h)) ^ 2 * (-(2 * σ ^ 2))⁻¹)
      (((-h) * ((y - g) + 0 * (-h)) + ((y - g) + 0 * (-h)) * (-h)) * (-(2 * σ ^ 2))⁻¹) 0 :=
    hsq.mul_const (-(2 * σ ^ 2))⁻¹
  have hval : ((-h) * ((y - g) + 0 * (-h)) + ((y - g) + 0 * (-h)) * (-h)) * (-(2 * σ ^ 2))⁻¹
      = (y - g) * h / σ ^ 2 := by
    have hσ2 : σ ^ 2 ≠ 0 := pow_ne_zero 2 hσ
    field_simp
    ring
  rw [← hval]
  have hsimp : (fun t : ℝ => -(((y - g) - t * h) ^ 2) / (2 * σ ^ 2))
      = (fun t : ℝ => ((y - g) + t * (-h)) ^ 2 * (-(2 * σ ^ 2))⁻¹) := by
    funext t
    field_simp
    ring
  rw [hsimp]
  exact hquad

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
valor de la derivada normal: `−(−2(y−g)h)/(2σ²) = (y−g)h/σ²`; de ahí la
fórmula `S_g = h(Z)ε/σ²` del libro. -/
theorem score_normal_valor (g h y σ : ℝ) (hσ : σ ≠ 0) :
    -(-2 * (y - g) * h) / (2 * σ ^ 2) = (y - g) * h / σ ^ 2 := by
  have hσ2 : σ ^ 2 ≠ 0 := pow_ne_zero 2 hσ
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
Bernoulli condicional: con `A ∈ {0,1}` escrito como peso real `a` y
`e_t = e + t·h`, la perturbación admisible produce
`S_e = h·(a − e)/(e(1 − e))` como derivada de
`a·log(e_t) + (1−a)·log(1 − e_t)`. -/
theorem score_bernoulli (e h a : ℝ) (he : e ≠ 0) (he1 : 1 - e ≠ 0) :
    HasDerivAt (fun t : ℝ => a * Real.log (e + t * h) + (1 - a) * Real.log (1 - e - t * h))
      (h * (a - e) / (e * (1 - e))) 0 := by
  have h1 : HasDerivAt (fun t : ℝ => a * Real.log (e + t * h)) (a * (h / e)) 0 :=
    (hasDerivAt_log_affine e h he).const_mul a
  have h2 : HasDerivAt (fun t : ℝ => (1 - a) * Real.log (1 - e - t * h))
      ((1 - a) * (-h / (1 - e))) 0 :=
    (hasDerivAt_log_affine_sub (1 - e) h he1).const_mul (1 - a)
  have hsum := h1.add h2
  have hval : a * (h / e) + (1 - a) * (-h / (1 - e)) = h * (a - e) / (e * (1 - e)) := by
    field_simp
    ring
  rw [← hval]
  exact hsum

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
la media condicional del score Bernoulli dado `X` es cero:
`e·S(1) + (1−e)·S(0) = 0`. -/
theorem score_bernoulli_media_cero (e h : ℝ) (he : e ≠ 0) (he1 : 1 - e ≠ 0) :
    e * (h * (1 - e) / (e * (1 - e))) + (1 - e) * (h * (0 - e) / (e * (1 - e))) = 0 := by
  field_simp
  ring

/-- book: capitulos/cap04_herramientas.typ:1862 (key: ex:ch6-scores-canonicos) —
supervivencia: perturbar la intensidad basal como
`λ₀,t(u) = λ₀(u)·exp(t·b(u))` da el score `∑_u b(u)·dM(u)` con
`dM(u) = dN(u) − λ₀(u)·du` el incremento del martingala de conteo
compensado. Fidelidad declarada: versión discreta en tiempo finito
(`u` en `Fin n`) de la integral estocástica `∫ b dM`; se deriva la
log-verosimilitud de intensidad sin sustituir la intensidad por una
distribución empírica. -/
theorem score_conteo {n : ℕ} (b lam0 dN : Fin n → ℝ) (du : ℝ) :
    HasDerivAt
      (fun t : ℝ => (∑ u, t * b u * dN u) - ∑ u, lam0 u * Real.exp (t * b u) * du)
      (∑ u, b u * (dN u - lam0 u * du)) 0 := by
  have hterm_lin : ∀ u : Fin n,
      HasDerivAt (fun t : ℝ => t * b u * dN u) (b u * dN u) 0 := by
    intro u
    have h : HasDerivAt (fun t : ℝ => t) 1 0 := hasDerivAt_id 0
    simpa [mul_comm, mul_assoc, mul_left_comm] using (h.mul_const (b u)).mul_const (dN u)
  have hlin : HasDerivAt (fun t : ℝ => ∑ u, t * b u * dN u) (∑ u, b u * dN u) 0 := by
    have := HasDerivAt.sum (u := (Finset.univ : Finset (Fin n)))
      (A := fun u t => t * b u * dN u) (A' := fun u => b u * dN u)
      (fun u _ => hterm_lin u)
    have heq : (∑ i : Fin n, (fun t : ℝ => t * b i * dN i))
        = (fun t => ∑ i, t * b i * dN i) := by
      funext t; simp
    rw [heq] at this
    exact this
  have hterm_exp : ∀ u : Fin n,
      HasDerivAt (fun t : ℝ => lam0 u * Real.exp (t * b u) * du) (lam0 u * b u * du) 0 := by
    intro u
    have hin : HasDerivAt (fun t : ℝ => t * b u) (b u) 0 := by
      simpa [mul_comm] using (hasDerivAt_id (0 : ℝ)).const_mul (b u)
    have he : HasDerivAt (fun t : ℝ => Real.exp (t * b u)) (b u) 0 := by
      have := hin.exp
      simpa using this
    have he2 : HasDerivAt (fun t : ℝ => lam0 u * Real.exp (t * b u)) (lam0 u * b u) 0 := by
      simpa using he.const_mul (lam0 u)
    simpa [mul_assoc] using he2.mul_const du
  have hexp : HasDerivAt (fun t : ℝ => ∑ u, lam0 u * Real.exp (t * b u) * du)
      (∑ u, lam0 u * b u * du) 0 := by
    have := HasDerivAt.sum (u := (Finset.univ : Finset (Fin n)))
      (A := fun u t => lam0 u * Real.exp (t * b u) * du) (A' := fun u => lam0 u * b u * du)
      (fun u _ => hterm_exp u)
    have heq : (∑ i : Fin n, (fun t : ℝ => lam0 i * Real.exp (t * b i) * du))
        = (fun t => ∑ i, lam0 i * Real.exp (t * b i) * du) := by
      funext t; simp
    rw [heq] at this
    exact this
  have hsub := hlin.sub hexp
  have hval : (∑ u, b u * dN u) - (∑ u, lam0 u * b u * du)
      = ∑ u, b u * (dN u - lam0 u * du) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun u _ => by ring)
  rw [← hval]
  exact hsub

/-! ## ex:ch6-cox — el modelo de Cox y la verosimilitud parcial -/

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) —
cancelación del riesgo basal: en un tiempo de evento, la contribución
`h₀(t)·HR(i)` dividida entre `∑_{j∈R} h₀(t)·HR(j)` es
`HR(i)/∑_{j∈R} HR(j)`, sin `h₀`. -/
theorem cox_cancelacion {κ : Type*} (R : Finset κ) (HR : κ → ℝ) (h0 : ℝ)
    (hh0 : h0 ≠ 0) (i : κ) :
    (h0 * HR i) / (∑ j ∈ R, h0 * HR j) = HR i / (∑ j ∈ R, HR j) := by
  rw [← Finset.mul_sum]
  exact mul_div_mul_left (HR i) (∑ j ∈ R, HR j) hh0

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) —
verosimilitud parcial: el producto de las contribuciones por tiempo de
evento no depende de la función basal `h₀`. Dos basales distintas dan la
misma verosimilitud parcial (por eso «evita estimar `h₀`»). -/
theorem cox_pl_independiente_basal {ι κ : Type*} [Fintype ι] [DecidableEq κ]
    (ev : ι → κ) (R : ι → Finset κ) (HR : κ → ℝ) (h0 h0' : ι → ℝ)
    (hh0 : ∀ i, h0 i ≠ 0) (hh0' : ∀ i, h0' i ≠ 0) :
    (∏ i, (h0 i * HR (ev i)) / (∑ j ∈ R i, h0 i * HR j))
      = ∏ i, (h0' i * HR (ev i)) / (∑ j ∈ R i, h0' i * HR j) := by
  rw [Finset.prod_congr rfl (fun i _ => cox_cancelacion (R i) HR (h0 i) (hh0 i) (ev i))]
  rw [Finset.prod_congr rfl (fun i _ => cox_cancelacion (R i) HR (h0' i) (hh0' i) (ev i))]

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) —
la verosimilitud parcial depende sólo de los cocientes de riesgos: escala
común `c ≠ 0` en todas las `HR` deja el producto invariante. -/
theorem cox_invariancia_escala {ι κ : Type*} [Fintype ι] [DecidableEq κ]
    (ev : ι → κ) (R : ι → Finset κ) (HR : κ → ℝ) (c : ℝ) (hc : c ≠ 0) :
    (∏ i, (c * HR (ev i)) / (∑ j ∈ R i, c * HR j))
      = ∏ i, HR (ev i) / (∑ j ∈ R i, HR j) :=
  Finset.prod_congr rfl (fun i _ => cox_cancelacion (R i) HR c hc (ev i))

/-! ## ex:ch6-aipw-intro — el ATE como funcional de la ley observada -/

/-- book: capitulos/cap04_herramientas.typ:1843 (key: ex:ch6-aipw-intro) —
identidad poblacional que hace del ATE un funcional de la ley observada:
con `m_a(z) = E[Y|A=a,Z=z]` y `e(z) = P(A=1|Z=z)`, la forma de
estandarización y la forma inversa de probabilidad coinciden:
`∑_z p(z)(m₁ − m₀) = ∑_z p(z)·(e/e)·m₁ − ∑_z p(z)·((1−e)/(1−e))·m₀`, es
decir `E[m₁(X) − m₀(X)] = E[A·Y/e(X)] − E[(1−A)·Y/(1−e(X))]`.
Fidelidad declarada: versión condensada en medias condicionales (la
descomposición por fibras que convierte `E[A·Y/e(X)]` en
`∑_z p(z)m₁(z)` es la misma que `thm:ch6-rubin-dag` ya formaliza en
`Book/Cap04Ch6.lean`; aquí se fija la identidad funcional y se exige
positividad `e(z) ∉ {0,1}`). -/
theorem aipw_identificacion {ι : Type*} [Fintype ι] (p e m1 m0 : ι → ℝ)
    (he : ∀ z, e z ≠ 0) (he1 : ∀ z, 1 - e z ≠ 0) :
    ∑ z, p z * (e z * m1 z / e z) - ∑ z, p z * ((1 - e z) * m0 z / (1 - e z))
      = ∑ z, p z * (m1 z - m0 z) := by
  have h1 : ∀ z, p z * (e z * m1 z / e z) = p z * m1 z := by
    intro z
    have hz : e z ≠ 0 := he z
    field_simp
  have h0 : ∀ z, p z * ((1 - e z) * m0 z / (1 - e z)) = p z * m0 z := by
    intro z
    have hz : 1 - e z ≠ 0 := he1 z
    field_simp
  simp only [h1, h0]
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl (fun z _ => ?_)
  ring

/-! ## ex:ch6-ope — el objetivo `J^π` y el valor `V^π` -/

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) —
el objetivo escalar no determina la función de valor: si la ley inicial
carga `s₀` y hay otro estado `s₁`, existen `v ≠ w` con
`∑_s μ(s)v(s) = ∑_s μ(s)w(s)`. Por eso `J^π` es un funcional de `V^π`
(no la misma información). -/
theorem ope_escalar_no_determina_valor {S : Type*} [Fintype S]
    (μ : S → ℝ) {s0 s1 : S} (hμ : μ s0 ≠ 0) (hne : s1 ≠ s0) :
    ∃ v w : S → ℝ, v ≠ w ∧ ∑ s, μ s * v s = ∑ s, μ s * w s := by
  classical
  refine ⟨fun s => if s = s1 then 1 else 0,
    fun s => if s = s0 then μ s1 / μ s0 else 0, ?_, ?_⟩
  · intro h
    have h1 : (if s1 = s1 then (1 : ℝ) else 0) = (if s1 = s0 then μ s1 / μ s0 else 0) := by
      simpa using congrFun h s1
    rw [if_pos rfl, if_neg hne] at h1
    exact one_ne_zero h1
  · have hleft : ∑ s, μ s * (if s = s1 then (1 : ℝ) else 0) = μ s1 := by
      rw [Finset.sum_eq_single s1]
      · simp
      · intro b _ hb; simp [hb]
      · intro h; exact absurd (Finset.mem_univ s1) h
    have hright : ∑ s, μ s * (if s = s0 then μ s1 / μ s0 else 0) = μ s1 := by
      rw [Finset.sum_eq_single s0]
      · rw [if_pos rfl]; field_simp
      · intro b _ hb; simp [hb]
      · intro h; exact absurd (Finset.mem_univ s0) h
    rw [hleft, hright]

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) —
`J^π = ∑_s μ(s)V^π(s)` es un escalar construido a partir de la función de
valor y de la ley inicial: si `V^π` satisface la ecuación de Bellman
`V^π(s) = r^π(s) + γ∑_{s'} P^π(s,s')V^π(s')`, entonces
`J^π = ∑_s μ(s)r^π(s) + γ∑_s μ(s)∑_{s'}P^π(s,s')V^π(s')`. -/
theorem ope_objetivo_escalar {S : Type*} [Fintype S] (μ v rπ : S → ℝ)
    (Pπ : S → S → ℝ) (γ : ℝ)
    (hbell : ∀ s, v s = rπ s + γ * ∑ s', Pπ s s' * v s') :
    ∑ s, μ s * v s
      = ∑ s, μ s * rπ s + γ * ∑ s, μ s * (∑ s', Pπ s s' * v s') := by
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl (fun s _ => by rw [hbell s]; ring)

/-! ## ex:ch6-parcialmente-lineal — residualizar resultado y exposición -/

/-- book: capitulos/cap04_herramientas.typ:1833 (key: ex:ch6-parcialmente-lineal) —
identidad de residualización: con `Y = X·β + g(Z) + ε` y
`ℓ(z) = m(z)·β + g(z)` (donde `m(z) = E[X|Z=z]`, `ℓ(z) = E[Y|Z=z]`),
resulta `Y − ℓ(Z) = (X − m(Z))·β + ε`: residualizar resultado y exposición
elimina `g`. -/
theorem parcialmente_lineal_residual {Ω ι : Type*} (X : Ω → ℝ) (Z : Ω → ι)
    (Y ε : Ω → ℝ) (g m ℓ : ι → ℝ) (β : ℝ)
    (hest : ∀ ω, Y ω = X ω * β + g (Z ω) + ε ω)
    (hℓ : ∀ z, ℓ z = m z * β + g z) :
    ∀ ω, Y ω - ℓ (Z ω) = (X ω - m (Z ω)) * β + ε ω := by
  intro ω
  rw [hest ω, hℓ (Z ω)]
  ring

/-- book: capitulos/cap04_herramientas.typ:1833 (key: ex:ch6-parcialmente-lineal) —
si `M = E[(X − m(Z))²] ≠ 0` y `E[(X − m(Z))·ε] = 0` (consecuencia de
`E[ε|X,Z] = 0`), entonces
`β = M⁻¹·E[(X − m(Z))·(Y − ℓ(Z))]`: la fórmula del libro. Fidelidad
declarada: versión finita con pesos `p` sobre `Ω`; el paso de torre
`E[ε|X,Z] = 0 ⟹ E[(X − m(Z))ε] = 0` se toma como la hipótesis `hε`, y el
paso `E[Y|Z] = m(Z)β + g(Z)` como `hℓ` (misma descomposición por fibras
que `thm:ch6-rubin-dag`). El caso vectorial `X ∈ ℝ^d` es la versión
matricial con `M` invertible. -/
theorem parcialmente_lineal_beta {Ω ι : Type*} [Fintype Ω]
    (p : Ω → ℝ) (X : Ω → ℝ) (Z : Ω → ι) (Y ε : Ω → ℝ) (g m ℓ : ι → ℝ)
    (β M : ℝ)
    (hest : ∀ ω, Y ω = X ω * β + g (Z ω) + ε ω)
    (hℓ : ∀ z, ℓ z = m z * β + g z)
    (hε : ∑ ω, p ω * ((X ω - m (Z ω)) * ε ω) = 0)
    (hM : M = ∑ ω, p ω * (X ω - m (Z ω)) ^ 2) (hM0 : M ≠ 0) :
    β = (∑ ω, p ω * ((X ω - m (Z ω)) * (Y ω - ℓ (Z ω)))) / M := by
  have hnum : ∑ ω, p ω * ((X ω - m (Z ω)) * (Y ω - ℓ (Z ω))) = M * β := by
    have hstep : ∀ ω, p ω * ((X ω - m (Z ω)) * (Y ω - ℓ (Z ω)))
        = p ω * (X ω - m (Z ω)) ^ 2 * β + p ω * ((X ω - m (Z ω)) * ε ω) := by
      intro ω
      rw [parcialmente_lineal_residual X Z Y ε g m ℓ β hest hℓ ω]
      ring
    rw [Finset.sum_congr rfl (fun ω _ => hstep ω), Finset.sum_add_distrib, hε]
    rw [hM, ← Finset.sum_mul]
    ring
  rw [hnum]
  field_simp

/-! ## ex:ssch-cap03-b — estimación de las probabilidades de transición -/

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) —
las frecuencias `N(s,a,j)/m` de un diseño de tamaño fijo `m` por fila son
una distribución: suman uno. -/
theorem cap03b_frecuencias_suman_uno {κ : Type*} [Fintype κ] (N : κ → ℕ) (m : ℕ)
    (hN : ∑ j, N j = m) (hm : m ≠ 0) :
    ∑ j, (N j : ℚ) / m = 1 := by
  rw [← Finset.sum_div]
  have hcast : ∑ j, (N j : ℚ) = (m : ℚ) := by exact_mod_cast hN
  rw [hcast]
  have hm' : (m : ℚ) ≠ 0 := by exact_mod_cast hm
  field_simp

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) —
insesgadez de la frecuencia en el diseño de tamaño fijo: si cada una de las
`m` transiciones de una fila tiene marginal correcta
`E[1{Xᵢ = j}] = P(s,a,j)`, entonces `E[N(s,a,j)/m] = P(s,a,j)`.
Fidelidad declarada: sólo se usan las marginales (no se necesita
independencia para la media), que es exactamente el alcance que el libro
reclama para el diseño por filas; no se afirma nada de cocientes de una
trayectoria adaptativa. -/
theorem cap03b_frecuencia_insesgada {Ω κ : Type*} [Fintype Ω] [Fintype κ] [DecidableEq κ]
    (m : ℕ) (hm : 0 < m) (w : Ω → ℝ) (X : Fin m → Ω → κ) (p : κ → ℝ)
    (hmarg : ∀ (i : Fin m) (j : κ),
      ∑ ω, w ω * (if X i ω = j then (1 : ℝ) else 0) = p j)
    (j : κ) :
    (1 / (m : ℝ)) * ∑ ω, w ω * (∑ i : Fin m, (if X i ω = j then (1 : ℝ) else 0))
      = p j := by
  have hswap : ∑ ω, w ω * (∑ i : Fin m, (if X i ω = j then (1 : ℝ) else 0))
      = ∑ i : Fin m, ∑ ω, w ω * (if X i ω = j then (1 : ℝ) else 0) := by
    simp only [Finset.mul_sum]
    exact Finset.sum_comm
  rw [hswap]
  have hconst : ∑ i : Fin m, ∑ ω, w ω * (if X i ω = j then (1 : ℝ) else 0)
      = (m : ℝ) * p j := by
    simp only [hmarg]
    simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [hconst]
  have hm' : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
  field_simp

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) —
para una política fija, el valor resuelve `V^π = (I − γP^π)⁻¹ r^π`: si `v`
satisface la ecuación `v = r + C·v` y `1 − C` es invertible (con
`C = γP^π`), entonces `v = (1 − C)⁻¹·r`. Es la ecuación que el programa
del libro usa con matrices compatibles. -/
theorem cap03b_valor_ecuacion {S : Type*} [Fintype S] [DecidableEq S]
    (C : Matrix S S ℝ) (r v : S → ℝ) (h1 : IsUnit (1 - C))
    (hv : v = r + C.mulVec v) :
    v = Matrix.mulVec (↑h1.unit⁻¹ : Matrix S S ℝ) r := by
  have hkey : (1 - C).mulVec v = r := by
    rw [Matrix.sub_mulVec, Matrix.one_mulVec]
    nth_rewrite 1 [hv]
    abel
  have hunit : (↑h1.unit⁻¹ : Matrix S S ℝ) * (1 - C) = 1 := by
    simpa only [IsUnit.unit_spec h1] using Units.inv_mul h1.unit
  calc v = Matrix.mulVec (1 : Matrix S S ℝ) v := by rw [Matrix.one_mulVec]
    _ = Matrix.mulVec ((↑h1.unit⁻¹ : Matrix S S ℝ) * (1 - C)) v := by rw [hunit]
    _ = Matrix.mulVec (↑h1.unit⁻¹ : Matrix S S ℝ) ((1 - C).mulVec v) := by
          rw [Matrix.mulVec_mulVec]
    _ = Matrix.mulVec (↑h1.unit⁻¹ : Matrix S S ℝ) r := by rw [hkey]

end Book.Cap04EjemplosM2
