import Mathlib

/-!
# Book.M9Pendientes — claves residuales (barrido complemento, enjambre smw9820kx / m9)

Dirección registrada: **d16 barrido libre (complemento)** (id de tablero `d14`).
Claves pendientes que ninguna otra dirección del enjambre reclama:

* `ex:ssch-causal-cap06`  — capitulos/cap04_herramientas.typ:2061
  (SSCH: confusión y estandarización; ejemplo sintético, cifras exactas).
* `ex:ch6-cox`            — capitulos/cap04_herramientas.typ:1840
  (modelo de Cox: la verosimilitud parcial no depende del riesgo basal).
* `ex:ssch-cap03-b`       — capitulos/cap10_casos.typ:98
  (SSCH: estimación de las probabilidades de transición y valor descontado).

Convenciones del proyecto: sin `sorry`, sin `native_decide`, cifras exactas en
`ℚ`/`ℝ` (nunca coma flotante), docstring `book: capitulos/<file>.typ:<línea>
(key: <clave>)` con fidelidad declarada, `#print axioms` ⊆ {propext,
Classical.choice, Quot.sound}. Namespace `M9` para no colisionar al integrarse
en `verificacion_lean/Book/`.
-/

open Finset BigOperators

namespace M9

/-! ## `ex:ssch-causal-cap06` — confusión y estandarización (cap04_herramientas.typ:2061)

Dos estratos `Z = 0,1` con `P(Z=z) = 1/2`; puntaje adverso (menos es mejor);
propensiones `e(0)=0.2, e(1)=0.8`; medias sin intervención `m₀=(10,20)` y con
intervención `m₁=(8,16)`. El libro obtiene `ψ = -3`, `E[Y|A=1] = 14.4`,
`E[Y|A=0] = 12` y una diferencia cruda `+2.4` de signo opuesto.
Fidelidad: se formaliza el mecanismo sintético completo para medias y
asignación (poblacional), tal como lo declara la fuente; no se afirma nada
sobre datos reales ni se añade un intervalo de confianza (la fuente no lo da). -/

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
peso poblacional de cada estrato: `P(Z=0) = P(Z=1) = 1/2`. -/
noncomputable def cap06W : Fin 2 → ℝ := fun _ => 1 / 2

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
propensiones `e(0) = 0.2 = 1/5`, `e(1) = 0.8 = 4/5`. -/
noncomputable def cap06E : Fin 2 → ℝ := ![1 / 5, 4 / 5]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
medias sin intervención `m₀ = (10, 20)`. -/
noncomputable def cap06M0 : Fin 2 → ℝ := ![10, 20]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
medias con intervención `m₁ = (8, 16)`. -/
noncomputable def cap06M1 : Fin 2 → ℝ := ![8, 16]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
efecto ajustado por estandarización:
`ψ = ∑_z P(Z=z) (m₁(z) − m₀(z)) = (8−10)/2 + (16−20)/2 = −3`. -/
theorem cap06_psi :
    (∑ z, cap06W z * (cap06M1 z - cap06M0 z)) = -3 := by
  rw [Fin.sum_univ_two]
  norm_num [cap06W, cap06M1, cap06M0]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
masa de tratamiento `P(A=1) = ∑_z P(Z=z) e(z) = 1/2`, de modo que la
distribución de `Z` entre tratados es `P(Z=z|A=1) = P(Z=z)e(z)/P(A=1)`. -/
theorem cap06_p_tratado :
    (∑ z, cap06W z * cap06E z) = 1 / 2 := by
  rw [Fin.sum_univ_two]
  norm_num [cap06W, cap06E]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
proporciones de estratos entre tratados: `(0.2, 0.8)`; es decir
`P(Z=0|A=1) = 1/5` y `P(Z=1|A=1) = 4/5`. -/
theorem cap06_estratos_tratados :
    (cap06W 0 * cap06E 0) / (∑ z, cap06W z * cap06E z) = 1 / 5 ∧
    (cap06W 1 * cap06E 1) / (∑ z, cap06W z * cap06E z) = 4 / 5 := by
  rw [cap06_p_tratado]
  constructor <;> norm_num [cap06W, cap06E]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
proporciones de estratos entre no tratados: `(0.8, 0.2)`. -/
theorem cap06_estratos_no_tratados :
    (cap06W 0 * (1 - cap06E 0)) / (∑ z, cap06W z * (1 - cap06E z)) = 4 / 5 ∧
    (cap06W 1 * (1 - cap06E 1)) / (∑ z, cap06W z * (1 - cap06E z)) = 1 / 5 := by
  have h : (∑ z, cap06W z * (1 - cap06E z)) = 1 / 2 := by
    rw [Fin.sum_univ_two]
    norm_num [cap06W, cap06E]
  rw [h]
  constructor <;> norm_num [cap06W, cap06E]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
media entre tratados: `E[Y|A=1] = 0.2·8 + 0.8·16 = 14.4 = 72/5`. -/
theorem cap06_media_tratados :
    (∑ z, ((cap06W z * cap06E z) / (∑ z', cap06W z' * cap06E z')) * cap06M1 z)
      = 72 / 5 := by
  rw [cap06_p_tratado, Fin.sum_univ_two]
  norm_num [cap06W, cap06E, cap06M1]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
media entre no tratados: `E[Y|A=0] = 0.8·10 + 0.2·20 = 12`. -/
theorem cap06_media_no_tratados :
    (∑ z, ((cap06W z * (1 - cap06E z)) / (∑ z', cap06W z' * (1 - cap06E z')))
        * cap06M0 z) = 12 := by
  have h : (∑ z, cap06W z * (1 - cap06E z)) = 1 / 2 := by
    rw [Fin.sum_univ_two]
    norm_num [cap06W, cap06E]
  rw [h, Fin.sum_univ_two]
  norm_num [cap06W, cap06E, cap06M0]

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
diferencia cruda `E[Y|A=1] − E[Y|A=0] = 72/5 − 12 = 12/5 = 2.4`, de signo
opuesto al efecto ajustado `ψ = −3`. -/
theorem cap06_diferencia_cruda :
    (72 / 5 : ℝ) - 12 = 12 / 5 ∧ (0 : ℝ) < 12 / 5 ∧ (-3 : ℝ) < 0 := by
  norm_num

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
descomposición exacta de la diferencia cruda en efecto ajustado más sesgo de
confusión: `crudo = ψ + (sesgo₁ + sesgo₀)`, donde
`sesgo₁ = ∑_z (P(Z=z|A=1) − P(Z=z)) m₁(z)` y
`sesgo₀ = ∑_z (P(Z=z) − P(Z=z|A=0)) m₀(z)`.
Es una identidad algebraica punto a punto: no requiere normalización alguna.
Fidelidad: la fuente enuncia el contraste numérico, no esta descomposición;
se formaliza la razón estructural que el ejemplo ilustra (el sesgo de
confusión es no nulo cuando la distribución de `Z` difiere entre brazos). -/
theorem cap06_descomposicion (Z : Type*) [Fintype Z]
    (p q₁ q₀ m₀ m₁ : Z → ℝ) :
    (∑ z, q₁ z * m₁ z) - (∑ z, q₀ z * m₀ z)
      = (∑ z, p z * (m₁ z - m₀ z))
        + ((∑ z, (q₁ z - p z) * m₁ z) + ∑ z, (p z - q₀ z) * m₀ z) := by
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
  congr 1
  ext z
  ring

/-- book: capitulos/cap04_herramientas.typ:2061 (key: ex:ssch-causal-cap06) —
sesgo de confusión del ejemplo: `crudo − ψ = 12/5 − (−3) = 27/5 = 5.4`; la
diferencia cruda es el efecto ajustado más ese sesgo. -/
theorem cap06_sesgo_confusion :
    (12 / 5 : ℝ) - (-3) = 27 / 5 := by
  norm_num

/-! ## `ex:ch6-cox` — modelo de Cox: la verosimilitud parcial no depende del riesgo basal

`h(t|Z) = h₀(t)·exp(Zᵀβ)` (cap04_herramientas.typ:1840). Se formaliza el
argumento que la fuente usa para justificar que la verosimilitud parcial
«evita estimar directamente `h₀`»: condicionado a que ocurra *un* fallo en el
conjunto de riesgo `R(t)`, la probabilidad de que el fallo sea del individuo
`i` es `h_i(t)/∑_{j∈R(t)} h_j(t) = exp(η_i)/∑_j exp(η_j)`, independiente de
`h₀(t)`. Fidelidad: se formaliza el cociente condicional y su invariancia
(el paso que elimina `h₀`); no se formalizan aquí las condiciones de censura
ni la proporcionalidad de riesgos, que la fuente explícitamente mantiene como
supuestos no eliminados por la verosimilitud parcial. -/

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) — riesgo
instantáneo del modelo de Cox: `h(t|Z) = h₀(t)·exp(η)` con `η = Zᵀβ`. -/
noncomputable def coxHazard (h0 eta : ℝ) : ℝ := h0 * Real.exp eta

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) —
probabilidad de que el fallo en `t` sea del individuo `i`, condicionada a que
ocurra exactamente un fallo en el conjunto de riesgo `R`: `h_i/∑_j h_j`.
Fidelidad: el modelo de un solo fallo en `R` con riesgos proporcionales es el
que la fuente describe; no se modela aquí el proceso de conteo completo. -/
noncomputable def coxProbFallo {R : Type*} [Fintype R] (h0 : ℝ) (eta : R → ℝ)
    (i : R) : ℝ :=
  coxHazard h0 (eta i) / ∑ j, coxHazard h0 (eta j)

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) — la
probabilidad condicional de fallo no depende del riesgo basal: con
`h_j = h₀·exp(η_j)` y `h₀ ≠ 0`,
`h_i/∑_j h_j = exp(η_i)/∑_j exp(η_j)`. Es el paso que elimina `h₀`. -/
theorem cox_prob_independiente_del_basal {R : Type*} [Fintype R] (eta : R → ℝ)
    (h0 : ℝ) (hh0 : h0 ≠ 0) (i : R) :
    coxProbFallo h0 eta i = Real.exp (eta i) / ∑ j, Real.exp (eta j) := by
  unfold coxProbFallo coxHazard
  rw [show (∑ j, h0 * Real.exp (eta j)) = h0 * ∑ j, Real.exp (eta j) from
    (Finset.mul_sum Finset.univ (fun j => Real.exp (eta j)) h0).symm]
  exact mul_div_mul_left _ _ hh0

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) — el
denominador del cociente es estrictamente positivo (suma de exponenciales),
de modo que la probabilidad condicional está bien definida. -/
theorem cox_denominador_pos {R : Type*} [Fintype R] [Nonempty R] (eta : R → ℝ) :
    0 < ∑ j, Real.exp (eta j) :=
  Finset.sum_pos (fun j _ => Real.exp_pos _) Finset.univ_nonempty

/-- book: capitulos/cap04_herramientas.typ:1840 (key: ex:ch6-cox) — la
verosimilitud parcial de una secuencia de fallos, `∏_t exp(η_{i(t)})/∑_{j∈R(t)}
exp(η_j)`, es la misma para cualquier perfil de riesgo basal `h₀ : T → ℝ` no
nulo: `β` se estima sin estimar `h₀`. -/
theorem cox_parcial_invariante {T R : Type*} [Fintype T] [Fintype R]
    (h0 : T → ℝ) (eta : T → R → ℝ) (i : T → R) (hh0 : ∀ t, h0 t ≠ 0) :
    (∏ t, coxProbFallo (h0 t) (eta t) (i t))
      = ∏ t, Real.exp (eta t (i t)) / ∑ j, Real.exp (eta t j) := by
  exact Finset.prod_congr rfl (fun t _ => cox_prob_independiente_del_basal (eta t) (h0 t) (hh0 t) (i t))

/-! ## `ex:ch6-ope` — objetivo de OPE: el escalar `J^π` frente al funcional `V^π`

(cap04_herramientas.typ:1848). Se formalizan las tres afirmaciones de la
fuente: (i) `J^π` es un escalar, media de `V^π` bajo la distribución inicial;
(ii) con tablas finitas el problema es finito-dimensional, es decir `J^π`
queda determinado por las tablas; (iii) `V^π` (un funcional sobre todos los
estados) no se recupera del escalar `J^π`, así que son objetivos distintos.
Se añade la unicidad de la ecuación de Bellman descontada con `0 ≤ γ < 1`,
que es lo que hace de `V^π` un objeto bien definido (la fuente la escribe
como `V^π = (I − γP^π)^{-1} r^π`). -/

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) — objetivo
escalar de OPE: `J^π = ∑_s μ₀(s)·V^π(s)`, media del valor bajo la
distribución inicial `μ₀`. -/
noncomputable def opeJ {S : Type*} [Fintype S] (mu0 V : S → ℝ) : ℝ :=
  ∑ s, mu0 s * V s

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) — con
estados finitos y tablas finitas el objetivo es finito-dimensional: `J^π`
sólo depende de las tablas `μ₀` y `V` (de sus entradas). -/
theorem ope_determinado_por_tablas {S : Type*} [Fintype S] (mu0 mu0' V V' : S → ℝ)
    (hmu : ∀ s, mu0 s = mu0' s) (hV : ∀ s, V s = V' s) :
    opeJ mu0 V = opeJ mu0' V' := by
  unfold opeJ
  exact Finset.sum_congr rfl (fun s _ => by rw [hmu s, hV s])

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) — el escalar
`J^π` no determina el funcional `V^π`: con `μ₀` concentrada en el estado `0`,
dos valores distintos tienen el mismo `J^π`. Por eso «un valor `V^π(s)` para
todo `s`» es un objetivo funcional distinto del escalar `J^π`. -/
theorem ope_escalar_no_determina_funcional :
    ∃ (mu0 V V' : Fin 2 → ℝ), opeJ mu0 V = opeJ mu0 V' ∧ V ≠ V' := by
  refine ⟨![1, 0], ![0, 0], ![0, 1], ?_, ?_⟩
  · unfold opeJ
    rw [Fin.sum_univ_two, Fin.sum_univ_two]
    norm_num
  · intro h
    have := congrFun h 1
    simp at this

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) — unicidad
del valor descontado: si `P` tiene entradas no negativas y filas que suman 1
(matriz estocástica) y `0 ≤ γ < 1`, la ecuación
`V(s) = r(s) + γ·∑_j P(s,j)·V(j)` tiene a lo sumo una solución. Prueba por el
argumento del estado de máximo módulo: `|Z(i)| ≤ γ·|Z(i)|` obliga a `Z = 0`.
Fidelidad: la fuente escribe la solución como `(I − γP^π)^{-1} r^π`; aquí se
formaliza la unicidad (el contenido que hace bien definido a `V^π`), y la
existencia se verifica en el ejemplo exacto de `ex:ssch-cap03-b`. -/
theorem bellman_unique {S : Type*} [Fintype S] [Nonempty S]
    (P : S → S → ℝ) (r : S → ℝ) (γ : ℝ) (hP : ∀ i j, 0 ≤ P i j)
    (hrow : ∀ i, ∑ j, P i j = 1) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1)
    {V W : S → ℝ}
    (hV : ∀ s, V s = r s + γ * ∑ j, P s j * V j)
    (hW : ∀ s, W s = r s + γ * ∑ j, P s j * W j) : V = W := by
  set Z : S → ℝ := fun s => V s - W s with hZdef
  have hZeq : ∀ s, Z s = γ * ∑ j, P s j * Z j := by
    intro s
    have hVs := hV s
    have hWs := hW s
    simp only [hZdef]
    rw [hVs, hWs]
    have : (∑ j, P s j * (V j - W j)) = (∑ j, P s j * V j) - ∑ j, P s j * W j := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun j _ => by ring)
    rw [this]
    ring
  obtain ⟨i, -, hi⟩ :=
    Finset.exists_max_image (Finset.univ : Finset S) (fun s => |Z s|)
      ⟨Classical.arbitrary S, Finset.mem_univ _⟩
  have hmax : ∀ j, |Z j| ≤ |Z i| := fun j => hi j (Finset.mem_univ j)
  have hbound : |∑ j, P i j * Z j| ≤ |Z i| := by
    calc |∑ j, P i j * Z j| ≤ ∑ j, |P i j * Z j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ j, P i j * |Z i| := by
        refine Finset.sum_le_sum (fun j _ => ?_)
        rw [abs_mul, abs_of_nonneg (hP i j)]
        exact mul_le_mul_of_nonneg_left (hmax j) (hP i j)
      _ = |Z i| := by rw [← Finset.sum_mul, hrow i, one_mul]
  have hZi : |Z i| ≤ γ * |Z i| := by
    calc |Z i| = γ * |∑ j, P i j * Z j| := by
          rw [hZeq i, abs_mul, abs_of_nonneg hγ0]
      _ ≤ γ * |Z i| := mul_le_mul_of_nonneg_left hbound hγ0
  have hzero : |Z i| = 0 := by
    by_contra hne
    have hpos : 0 < |Z i| := lt_of_le_of_ne (abs_nonneg _) (Ne.symm hne)
    nlinarith
  funext s
  have hZs : |Z s| = 0 := le_antisymm (by rw [← hzero]; exact hmax s) (abs_nonneg _)
  have hZs0 : Z s = 0 := abs_eq_zero.mp hZs
  simp only [hZdef] at hZs0
  linarith

/-- book: capitulos/cap04_herramientas.typ:1848 (key: ex:ch6-ope) — expansión
del horizonte: toda solución de la ecuación de Bellman descontada cumple
`V = r + γ·P r + γ²·P² V` (un paso de horizonte finito), es decir el objetivo
depende de la dinámica `P` y de la recompensa `r` a través de las tablas. -/
theorem ope_expansion_dos_pasos {S : Type*} [Fintype S]
    (P : S → S → ℝ) (r : S → ℝ) (γ : ℝ) {V : S → ℝ}
    (hV : ∀ s, V s = r s + γ * ∑ j, P s j * V j) (s : S) :
    V s = r s + γ * (∑ j, P s j * r j)
      + γ ^ 2 * ∑ k, (∑ j, P s j * P j k) * V k := by
  rw [hV s]
  have hstep : (∑ j, P s j * V j)
      = (∑ j, P s j * r j) + γ * ∑ j, P s j * (∑ k, P j k * V k) := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun j _ => by rw [hV j]; ring)
  rw [hstep]
  have hfold : (∑ j, P s j * (∑ k, P j k * V k))
      = ∑ k, (∑ j, P s j * P j k) * V k := by
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun k _ => ?_)
    have : (∑ x, P s x * (P x k * V k)) = ∑ x, (P s x * P x k) * V k :=
      Finset.sum_congr rfl (fun x _ => by ring)
    rw [this, Finset.sum_mul]
  rw [hfold]
  ring



/-! ## `ex:ssch-cap03-b` — estimar la dinámica y calcular el valor (cap10_casos.typ:98)

La fuente describe el diseño generativo por filas (tamaño fijo `m = 80` por
fila), la estimación `P̂ = N/m` con `Cov(P̂) = (1/m)(diag(P) − PPᵀ)`, y la
ecuación de valor `V^π = (I − γP^π)^{-1} r^π`. Se formalizan dos piezas
exactas: (i) la covarianza de una fila —la matriz `diag(P) − PPᵀ` que la
fuente promedia con `1/m`—; (ii) la ecuación de valor para una cadena de tres
estados con racionales exactos, junto con su unicidad. Fidelidad declarada:
las cifras `0.964091` y `5.570888` del simulador no se reproducen (dependen
del generador y la semilla del programa, no del enunciado); lo que se verifica
es la ecuación que el programa resuelve y el cálculo de una fila. -/

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — covarianza de
una fila multinomial: con `P(X=j) = p_j = P(s,a,j)`, la covarianza de los
indicadores `1{X=j}, 1{X=k}` es `δ_{jk} p_j − p_j p_k`, es decir la entrada
`(j,k)` de `diag(P) − PPᵀ`. Fidelidad: es la matriz que la fuente divide por
`m` para las frecuencias `P̂ = N/m` del diseño de filas independientes. -/
theorem multinomial_cov_fila {ι : Type*} [Fintype ι] [DecidableEq ι]
    (p : ι → ℝ) (j k : ι) :
    (∑ x, p x * (if x = j then (1 : ℝ) else 0) * (if x = k then (1 : ℝ) else 0))
        - p j * p k
      = (if j = k then p j else 0) - p j * p k := by
  have h : (∑ x, p x * (if x = j then (1 : ℝ) else 0) * (if x = k then (1 : ℝ) else 0))
      = if j = k then p j else 0 := by
    by_cases hjk : j = k
    · subst hjk
      rw [if_pos rfl]
      rw [Finset.sum_eq_single j]
      · simp
      · intro b _ hb
        simp [hb]
      · intro hj
        exact absurd (Finset.mem_univ j) hj
    · rw [if_neg hjk]
      refine Finset.sum_eq_zero (fun x _ => ?_)
      by_cases hxj : x = j
      · subst hxj
        simp [hjk]
      · simp [hxj]
  rw [h]

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — cadena de tres
estados del cálculo de valor: `P(s,a,·)` con filas que suman uno y entradas no
negativas (tabla finita; la fuente usa tablas y matrices compatibles). -/
noncomputable def sschP : Fin 3 → Fin 3 → ℝ :=
  ![![1 / 2, 1 / 2, 0], ![0, 1 / 2, 1 / 2], ![1 / 2, 0, 1 / 2]]

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — recompensa
`r^π` de la política fija del cálculo de valor. -/
noncomputable def sschR : Fin 3 → ℝ := ![1, 2, 3]

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — factor de
descuento `γ = 0.9 = 9/10`. -/
noncomputable def sschGamma : ℝ := 9 / 10

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — valor
`V^π = (I − γP^π)^{-1} r^π` calculado exactamente (racionales): cada componente
satisface la ecuación de valor. Las filas suman uno y las entradas son no
negativas, así que el núcleo es estocástico como exige la fuente. -/
theorem ssch_estocastica :
    (∀ i j, 0 ≤ sschP i j) ∧ (∀ i, ∑ j, sschP i j = 1) := by
  constructor
  · intro i j
    fin_cases i <;> fin_cases j <;> norm_num [sschP]
  · intro i
    fin_cases i <;> norm_num [sschP, Fin.sum_univ_three]

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — el vector
`V = (5620/301, 6200/301, 6240/301)` resuelve `V = r + γ P V`, es decir
`(I − γP)V = r`: es la ecuación que el programa resuelve para el valor
plug-in. -/
theorem ssch_valor_bellman :
    ∀ s, (![5620 / 301, 6200 / 301, 6240 / 301] : Fin 3 → ℝ) s
      = sschR s + sschGamma * ∑ j, sschP s j * (![5620 / 301, 6200 / 301, 6240 / 301] : Fin 3 → ℝ) j := by
  intro s
  fin_cases s <;>
    simp [sschP, sschR, sschGamma, Fin.sum_univ_three] <;> norm_num

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — el valor
plug-in es único: toda solución de la ecuación de valor coincide con
`(5620/301, 6200/301, 6240/301)`, porque `γ = 9/10 < 1` y `P` es estocástica. -/
theorem ssch_valor_unico (W : Fin 3 → ℝ)
    (hW : ∀ s, W s = sschR s + sschGamma * ∑ j, sschP s j * W j) :
    W = ![5620 / 301, 6200 / 301, 6240 / 301] := by
  refine bellman_unique sschP sschR sschGamma ?_ ?_ (by norm_num [sschGamma])
    (by norm_num [sschGamma]) hW ?_
  · exact ssch_estocastica.1
  · exact ssch_estocastica.2
  · exact ssch_valor_bellman

/-- book: capitulos/cap10_casos.typ:98 (key: ex:ssch-cap03-b) — objetivo
escalar de la decisión: con distribución inicial uniforme `μ₀ = (1/3,1/3,1/3)`,
`J^π = ∑_s μ₀(s)V^π(s) = 20` exacto. -/
theorem ssch_J :
    opeJ (![1 / 3, 1 / 3, 1 / 3] : Fin 3 → ℝ) ![5620 / 301, 6200 / 301, 6240 / 301]
      = 20 := by
  unfold opeJ
  rw [Fin.sum_univ_three]
  norm_num

end M9
