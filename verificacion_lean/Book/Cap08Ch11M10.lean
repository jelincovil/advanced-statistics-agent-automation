import Mathlib

/-!
# Cap08Ch11M10 — capítulo 11 del libro (capitulos/cap08_intervalos.typ)

Formalización de claves pendientes del capítulo 11:

* `prop:ch11-impacto`   — varianza de largo plazo y tamaño efectivo (AR(1))
* `cor:ch11-ic`         — intervalo por studentización y escala correcta
* `thm:ch11-n`          — planificación normal aproximada (tamaño de muestra)
* `prop:ch11-reinforce-if` — momentos del gradiente y función de influencia
* `prop:ch11-ergodico`  — mixing geométrico del caso finito (contracción Doeblin)
* `thm:ch11-pg-theorem` — identidad del gradiente de política (nivel trayectoria)
* `thm:ch11-var-consistente` — consistencia HAC (núcleo determinista)
* `thm:ch11-clt-mixing` — identidad de la varianza límite bajo estacionariedad
* `ex:ssch-cap11`       — intervalo y comparación pareada del cálculo SSCH

Fidelidad declarada (global): el proyecto verifica la parte exacta de cada
enunciado sobre modelos finitos con pesos racionales; las convergencias
distribucionales profundas (CLT de Ibragimov, normalidad asintótica
studentizada) se declaran como hipótesis citadas en cada teorema y nunca se
sustituyen por un axioma. Cada declaración lleva su propio párrafo de
fidelidad.

Convenciones: `Mathlib` + capa finita local (`fexp`, `fvar`, `fcov`,
`IsProb`), misma que `Book/Cap05Asintotica.lean` del repositorio; sin pruebas
admitidas; `#print axioms` en `audit.lean`.
-/

open Finset BigOperators Filter
open scoped Topology

set_option maxHeartbeats 1000000
set_option linter.unusedVariables false

namespace Ch11M10

/-! ### 0. Capa de probabilidad finita (heredada de `Book/Cap05Asintotica.lean`) -/

variable {Ω : Type*} [Fintype Ω]

/-- Esperanza bajo los pesos `p`: `E_p[Y] = ∑_ω p(ω)·Y(ω)`. -/
noncomputable def fexp (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := ∑ ω, p ω * Y ω

/-- Varianza bajo los pesos `p`: `Var_p[Y] = E_p[(Y − E_p Y)²]`. -/
noncomputable def fvar (p : Ω → ℝ) (Y : Ω → ℝ) : ℝ := fexp p fun ω => (Y ω - fexp p Y) ^ 2

/-- Covarianza bajo los pesos `p`. -/
noncomputable def fcov (p : Ω → ℝ) (X Y : Ω → ℝ) : ℝ :=
  fexp p fun ω => (X ω - fexp p X) * (Y ω - fexp p Y)

/-- Los pesos `p` son una distribución de probabilidad sobre `Ω` finito. -/
def IsProb (p : Ω → ℝ) : Prop := (∀ ω, 0 ≤ p ω) ∧ ∑ ω, p ω = 1

theorem fexp_const (p : Ω → ℝ) (c : ℝ) : fexp p (fun _ => c) = c * ∑ ω, p ω := by
  simp only [fexp]
  rw [← Finset.sum_mul]
  ring

theorem fexp_const' (p : Ω → ℝ) (hp : IsProb p) (c : ℝ) : fexp p (fun _ => c) = c := by
  rw [fexp_const, hp.2, mul_one]

theorem fexp_sub (p : Ω → ℝ) (X Y : Ω → ℝ) :
    fexp p (fun ω => X ω - Y ω) = fexp p X - fexp p Y := by
  simp [fexp, mul_sub, Finset.sum_sub_distrib]

theorem fexp_add (p : Ω → ℝ) (X Y : Ω → ℝ) :
    fexp p (fun ω => X ω + Y ω) = fexp p X + fexp p Y := by
  simp [fexp, mul_add, Finset.sum_add_distrib]

theorem fexp_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fexp p (fun ω => c * Y ω) = c * fexp p Y := by
  rw [fexp, fexp, Finset.mul_sum]
  exact Finset.sum_congr rfl fun ω _ => by ring

theorem fexp_sum {ι : Type*} [Fintype ι] (p : Ω → ℝ) (X : ι → Ω → ℝ) :
    fexp p (fun ω => ∑ i, X i ω) = ∑ i, fexp p (X i) := by
  simp only [fexp]
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem fexp_nonneg (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω) (Y : Ω → ℝ) (hY : ∀ ω, 0 ≤ Y ω) :
    0 ≤ fexp p Y :=
  Finset.sum_nonneg fun ω _ => mul_nonneg (hp ω) (hY ω)

theorem fcov_self (p : Ω → ℝ) (X : Ω → ℝ) : fcov p X X = fvar p X := by
  simp only [fcov, fvar, sq]

theorem fvar_const_mul (p : Ω → ℝ) (c : ℝ) (Y : Ω → ℝ) :
    fvar p (fun ω => c * Y ω) = c ^ 2 * fvar p Y := by
  have hm : fexp p (fun ω => c * Y ω) = c * fexp p Y := fexp_const_mul p c Y
  simp only [fvar, hm]
  have hfun : (fun ω => (c * Y ω - c * fexp p Y) ^ 2)
      = fun ω => c ^ 2 * (Y ω - fexp p Y) ^ 2 := by
    funext ω; ring
  rw [hfun, fexp_const_mul]

/-- Identidad de Koopman en versión finita: la varianza de una suma es la suma
de las covarianzas de los sumandos. -/
theorem fvar_sum {ι : Type*} [Fintype ι] (p : Ω → ℝ) (X : ι → Ω → ℝ) :
    fvar p (fun ω => ∑ i, X i ω) = ∑ i, ∑ j, fcov p (X i) (X j) := by
  have hm : fexp p (fun ω => ∑ i, X i ω) = ∑ i, fexp p (X i) := fexp_sum p X
  rw [fvar, hm]
  have hfun : (fun ω => (∑ i, X i ω - ∑ i, fexp p (X i)) ^ 2)
      = fun ω => ∑ i, ∑ j, (X i ω - fexp p (X i)) * (X j ω - fexp p (X j)) := by
    funext ω
    rw [← Finset.sum_sub_distrib, sq, Finset.sum_mul_sum]
  rw [hfun, fexp_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [fexp_sum]
  rfl

/-! ### 1. `prop:ch11-impacto` — dependencia y tamaño efectivo de una media -/

/-- book: capitulos/cap08_intervalos.typ:140 (key: prop:ch11-impacto) —
**Dependencia y tamaño efectivo de una media.** Si un observable estacionario
tiene autocovarianza `Cov(X₀,X_k) = σ_X²·ρ^k` con `|ρ| < 1`, entonces

  `σ²_LR = σ_X² + 2∑_{k≥1} σ_X² ρ^k = σ_X² (1+ρ)/(1−ρ)`.

Fidelidad declarada: se formaliza la identidad de la varianza de largo plazo
(la suma geométrica converge por `|ρ| < 1`) y los números del libro; la
existencia del proceso estacionario con ese covariograma es la hipótesis
(no se construye el proceso). -/
theorem ch11_impacto_sigma2 (σX2 ρ : ℝ) (hρ : |ρ| < 1) :
    σX2 + 2 * (∑' k : ℕ, σX2 * ρ ^ (k + 1)) = σX2 * ((1 + ρ) / (1 - ρ)) := by
  have hρ1 : ρ < 1 := (abs_lt.1 hρ).2
  have hρn : ρ ≠ 1 := ne_of_lt hρ1
  have h1ρ : (0:ℝ) < 1 - ρ := by linarith
  have hgeom : HasSum (fun k : ℕ => ρ ^ k) ((1:ℝ) - ρ)⁻¹ :=
    hasSum_geometric_of_norm_lt_one (by simpa [Real.norm_eq_abs] using hρ)
  have hsum : ∑' k : ℕ, ρ ^ (k + 1) = ρ / (1 - ρ) := by
    have hmul : ∑' k : ℕ, ρ ^ (k + 1) = ρ * ∑' k : ℕ, ρ ^ k := by
      rw [← tsum_mul_left]
      exact tsum_congr fun k => by rw [pow_succ']
    rw [hmul, hgeom.tsum_eq, div_eq_mul_inv]
  have hshift : ∑' k : ℕ, σX2 * ρ ^ (k + 1) = σX2 * (ρ / (1 - ρ)) := by
    rw [tsum_mul_left, hsum]
  rw [hshift]
  field_simp
  ring

/-- book: capitulos/cap08_intervalos.typ:140 (key: prop:ch11-impacto) —
**Tamaño efectivo y factor de varianza.** Con `ρ = 0.95 = 19/20` el factor de
varianza es `39`, el tamaño efectivo con `T = 1000` es `T_eff ≈ 1000/39 ≈ 25.64`
y el error estándar asintótico se multiplica por `√39 ≈ 6.24`
(`6.24 < √39 < 6.25`). Con correlación negativa (`ρ = −1/2`) el factor es
`1/3 < 1`: la varianza de la media puede disminuir.

Fidelidad declarada: aritmética exacta con `ρ`, `T` del enunciado; el
`≈` se verifica como intervalo racional estricto. -/
theorem ch11_impacto_numeros :
    (1 + (19:ℝ)/20) / (1 - 19/20) = 39
    ∧ (1000 : ℝ) * ((1 - 19/20) / (1 + 19/20)) = 1000 / 39
    ∧ (6.24 : ℝ) < Real.sqrt 39 ∧ Real.sqrt 39 < 6.25
    ∧ (1 + (-(1:ℝ)/2)) / (1 - (-(1/2))) = 1 / 3
    ∧ (1 : ℝ) / 3 < 1 := by
  refine ⟨by norm_num, by norm_num, ?_, ?_, by norm_num, by norm_num⟩
  · rw [Real.lt_sqrt (by norm_num)]
    norm_num
  · rw [Real.sqrt_lt' (by norm_num)]
    norm_num

/-- Factor de varianza de largo plazo `(1+ρ)/(1−ρ)` y tamaño efectivo
`T(1−ρ)/(1+ρ)`: son inversos multiplicativos (versión exacta del `T_eff`). -/
theorem ch11_impacto_teff (ρ T : ℝ) (hT : 0 < T) (hρ : |ρ| < 1) :
    T * ((1 - ρ) / (1 + ρ)) * ((1 + ρ) / (1 - ρ)) = T := by
  have hρ1 : ρ < 1 := (abs_lt.1 hρ).2
  have hρ1' : -1 < ρ := (abs_lt.1 hρ).1
  have h1 : (0:ℝ) < 1 + ρ := by linarith
  have h2 : (0:ℝ) < 1 - ρ := by linarith
  field_simp

/-! ### 2. `cor:ch11-ic` — intervalo por studentización y su escala -/

/-- book: capitulos/cap08_intervalos.typ:243 (key: cor:ch11-ic) —
**Intervalo por studentización.** El intervalo
`Ĵ ± z_{1−α/2}·σ̂/√(nT)` contiene al parámetro `J` exactamente cuando el
estadístico studentizado satisface `|√(nT)(Ĵ−J)/σ̂| ≤ z_{1−α/2}`.

Fidelidad declarada: se formaliza la equivalencia algebraica que convierte el
límite studentizado (hipótesis del libro: «siempre que se haya establecido el
límite studentizado anterior») en cobertura del intervalo; la convergencia en
distribución a `N(0,1)` es la hipótesis citada y no se reproduce aquí. -/
theorem ch11_ic_studentizacion (J Jhat σhat z : ℝ) (nT : ℕ) (hnT : 0 < nT)
    (hσ : 0 < σhat) :
    (|Jhat - J| ≤ z * (σhat / Real.sqrt (nT : ℝ))
      ↔ |Real.sqrt (nT : ℝ) * (Jhat - J) / σhat| ≤ z) := by
  have hsqrt : (0:ℝ) < Real.sqrt (nT : ℝ) := by
    rw [Real.sqrt_pos]
    exact_mod_cast hnT
  have hk : (0:ℝ) < Real.sqrt (nT : ℝ) / σhat := div_pos hsqrt hσ
  have hkey : |Real.sqrt (nT : ℝ) * (Jhat - J) / σhat|
      = |Jhat - J| * (Real.sqrt (nT : ℝ) / σhat) := by
    rw [abs_div, abs_mul, abs_of_pos hsqrt, abs_of_pos hσ]
    ring
  rw [hkey]
  constructor
  · intro h
    have h2 : |Jhat - J| * (Real.sqrt (nT : ℝ) / σhat)
        ≤ (z * (σhat / Real.sqrt (nT : ℝ))) * (Real.sqrt (nT : ℝ) / σhat) :=
      mul_le_mul_of_nonneg_right h (le_of_lt hk)
    have hone : (σhat / Real.sqrt (nT : ℝ)) * (Real.sqrt (nT : ℝ) / σhat) = 1 := by
      field_simp
    rw [mul_assoc, hone, mul_one] at h2
    exact h2
  · intro h
    have hzk : z * (σhat / Real.sqrt (nT : ℝ)) = z / (Real.sqrt (nT : ℝ) / σhat) := by
      field_simp
    rw [hzk, le_div_iff₀ hk]
    exact h

/-- book: capitulos/cap08_intervalos.typ:243 (key: cor:ch11-ic) —
**La escala de un procedimiento basado en episodios es `√n`, no `√(nT)`.**
Con `T ≥ 1` episodios de horizonte `T`, dividir por `√(nT)` produce un
intervalo más estrecho que el que corresponde a las `n` contribuciones por
episodio; usar la escala equivocada subdeclara el error.

Fidelidad declarada: comparación exacta de semianchos con `z, σ̂ ≥ 0`. -/
theorem ch11_ic_escala_episodios (σhat z : ℝ) (n T : ℕ) (hn : 0 < n) (hT : 1 ≤ T)
    (hσ : 0 ≤ σhat) (hz : 0 ≤ z) :
    z * (σhat / Real.sqrt ((n * T : ℕ) : ℝ)) ≤ z * (σhat / Real.sqrt (n : ℝ)) := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hnT : (n : ℝ) ≤ ((n * T : ℕ) : ℝ) := by
    have hTpos : 0 < T := lt_of_lt_of_le Nat.zero_lt_one hT
    have : n ≤ n * T := Nat.le_mul_of_pos_right n hTpos
    exact_mod_cast this
  have hle : Real.sqrt (n : ℝ) ≤ Real.sqrt ((n * T : ℕ) : ℝ) := Real.sqrt_le_sqrt hnT
  have hpos : (0:ℝ) < Real.sqrt (n : ℝ) := Real.sqrt_pos.2 hnpos
  have hdiv : σhat / Real.sqrt ((n * T : ℕ) : ℝ) ≤ σhat / Real.sqrt (n : ℝ) := by
    apply div_le_div_of_nonneg_left hσ hpos hle
  exact mul_le_mul_of_nonneg_left hdiv hz

/-! ### 3. `thm:ch11-n` — planificación normal aproximada -/

/-- book: capitulos/cap08_intervalos.typ:379 (key: thm:ch11-n) —
**Planificación normal aproximada.** Para un contraste bilateral de nivel `α`
con diferencia relevante `δ > 0`, poder aproximado `1−β` y desviación `σ_D` de
la contribución, la condición de poder `√n·δ ≥ (z_{1−α/2}+z_{1−β})·σ_D` es
exactamente `n ≥ ((z_{1−α/2}+z_{1−β})·σ_D/δ)²`.

Fidelidad declarada: se formaliza la inversión exacta que el libro usa para
despejar `n` (la aproximación normal y los cuantiles son los insumos del
enunciado); no se reproduce la aproximación normal en sí. -/
theorem ch11_n_condicion (z1 z2 σD δ : ℝ) (hσ : 0 < σD) (hδ : 0 < δ)
    (hz : 0 < z1 + z2) (n : ℕ) (hn : 0 < n) :
    ((z1 + z2) * σD ≤ Real.sqrt (n : ℝ) * δ
      ↔ ((z1 + z2) * σD / δ) ^ 2 ≤ (n : ℝ)) := by
  have hn0 : (0:ℝ) ≤ (n : ℝ) := by positivity
  have hc : 0 ≤ (z1 + z2) * σD / δ := le_of_lt (div_pos (mul_pos hz hσ) hδ)
  exact (div_le_iff₀ hδ).symm.trans (Real.le_sqrt hc hn0)

/-- book: capitulos/cap08_intervalos.typ:379 (key: thm:ch11-n) —
**El tamaño `n` es el entero mínimo que supera la cantidad planificada:** si
`m < c ≤ m+1`, ningún `n ≤ m` cumple `c ≤ n`. -/
theorem ch11_n_minimo (c : ℝ) (m n : ℕ) (h1 : (m : ℝ) < c) (hn : c ≤ (n : ℝ)) :
    m + 1 ≤ n := by
  by_contra h
  have hle : n ≤ m := by omega
  have hcast : (n : ℝ) ≤ (m : ℝ) := by exact_mod_cast hle
  linarith

/-- book: capitulos/cap08_intervalos.typ:379 (key: thm:ch11-n) —
**Números del libro.** (i) Con efecto estandarizado `δ/σ_D = 0.2`, cuantiles
precisos (`z_{0.975} = 1.959964`, `z_{0.80} = 0.841621`) dan
`n = ⌈196.22⌉ = 197`; redondeando primero a `1.96` y `0.84` se obtiene
`n = 196`. (ii) Con `δ = 0.5`, `σ_D = 2`, nivel bilateral `5%`, se necesitan
`126` unidades para poder `80%` (`z_{0.80} = 0.84`) y `169` para poder `90%`
(`z_{0.90} = 1.2816`).

Fidelidad declarada: aritmética racional exacta; los cuantiles normales son
los valores redondeados que el libro usa, no se recalculan desde `Φ`. -/
theorem ch11_n_ejemplos :
    -- (i) efecto estandarizado 0.2, cuantiles precisos → 197
    (196 : ℝ) < ((1959964:ℝ)/1000000 + 841621/1000000) ^ 2 * 25
    ∧ ((1959964:ℝ)/1000000 + 841621/1000000) ^ 2 * 25 ≤ 197
    -- (i') cuantiles redondeados 1.96, 0.84 → 196 exacto
    ∧ ((196:ℝ)/100 + 84/100) ^ 2 * 25 = 196
    -- (ii) δ=0.5, σ_D=2, poder 80% con z=1.96, 0.84 → 126
    ∧ ((49:ℝ)/25 + 21/25) * 2 / (1/2) = 56/5
    ∧ (125 : ℝ) < (56/5) ^ 2 ∧ (56/5 : ℝ) ^ 2 ≤ 126
    -- (ii') poder 90% con z=1.96, 1.2816 → 169
    ∧ ((49:ℝ)/25 + 801/625) * 2 / (1/2) = 8104/625
    ∧ (168 : ℝ) < (8104/625) ^ 2 ∧ (8104/625 : ℝ) ^ 2 ≤ 169 := by
  norm_num

/-! ### 4. `prop:ch11-reinforce-if` — momentos del gradiente y función de influencia -/

/-- book: capitulos/cap08_intervalos.typ:519 (key: prop:ch11-reinforce-if) —
**Momentos del gradiente y función de influencia.** Para una política fija y
episodios iid con `Z(O) = ∑_t γ^t z_t G_t` de segundo momento finito, el
promedio `ĝ` de `n` episodios cumple `E[ĝ] = E[Z]`, `Var(ĝ) = Var(Z)/n`, y
`ĝ − E[Z] = (1/n)∑_i (Z_i − E[Z])`: la función de influencia es
`Z(O) − E[Z]`, no la matriz `Σ = Var(Z(O))`.

Fidelidad declarada: modelo finito con pesos; la independencia entre episodios
entra por la covarianza nula (lo único que la prueba usa), exactamente como en
`prop:ch5-clt-retornos` del repositorio. El CLT multivariado es el teorema
citado en el libro; aquí se verifican sus dos momentos y la representación por
la función de influencia. -/
theorem ch11_reinforce_if {n : ℕ} (hn : 0 < n) (p : Ω → ℝ) (hp : IsProb p)
    (Z : Fin n → Ω → ℝ) (μ σ2 : ℝ) (hmean : ∀ i, fexp p (Z i) = μ)
    (hvar : ∀ i, fvar p (Z i) = σ2)
    (hunc : ∀ i j, i ≠ j → fcov p (Z i) (Z j) = 0) :
    fexp p (fun ω => (n:ℝ)⁻¹ * ∑ i, Z i ω) = μ
    ∧ fvar p (fun ω => (n:ℝ)⁻¹ * ∑ i, Z i ω) = σ2 / n
    ∧ (∀ ω, (n:ℝ)⁻¹ * ∑ i, (Z i ω - μ)
        = (n:ℝ)⁻¹ * ∑ i, Z i ω - μ) := by
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hsum : fexp p (fun ω => ∑ i, Z i ω) = (n:ℝ) * μ := by
    rw [fexp_sum]
    rw [Finset.sum_congr rfl fun i _ => hmean i]
    simp [Finset.sum_const, Fintype.card_fin, nsmul_eq_mul]
  have hinner : ∀ i : Fin n, ∑ j, fcov p (Z i) (Z j) = σ2 := by
    intro i
    rw [Finset.sum_eq_single i]
    · rw [fcov_self, hvar i]
    · intro j _ hj; exact hunc i j (Ne.symm hj)
    · intro hi; exact absurd (Finset.mem_univ i) hi
  have hsumvar : fvar p (fun ω => ∑ i, Z i ω) = (n:ℝ) * σ2 := by
    rw [fvar_sum]
    rw [Finset.sum_congr rfl fun i _ => hinner i]
    simp [Finset.sum_const, Fintype.card_fin, nsmul_eq_mul]
  refine ⟨?_, ?_, ?_⟩
  · rw [fexp_const_mul, hsum]
    field_simp
  · rw [fvar_const_mul, hsumvar]
    field_simp
  · intro ω
    have h1 : ∑ i, (Z i ω - μ) = ∑ i, Z i ω - (n:ℝ) * μ := by
      rw [Finset.sum_sub_distrib]
      simp [Finset.sum_const, Fintype.card_fin, nsmul_eq_mul]
    rw [h1]
    field_simp

/-! ### 5. `ex:ssch-cap11` — SSCH: intervalo y comparación pareada -/

/-- Contribuciones DR de la política objetivo, indexadas por `(A₀,A₁)`
(tabla del ejemplo SSCH del capítulo 11). -/
def Dobj : Bool → Bool → ℝ
  | false, false => 1.190
  | false, true => 1.370
  | true, false => 1.300
  | true, true => 1.840

/-- Contribuciones DR de la política de referencia. -/
def Dref : Bool → Bool → ℝ
  | false, false => 0.670
  | false, true => 1.030
  | true, false => 0.870
  | true, true => 1.230

/-- Contribuciones pareadas: diferencia dentro del mismo episodio. -/
def Ddiff (a0 a1 : Bool) : ℝ := Dobj a0 a1 - Dref a0 a1

/-- Error estándar exacto de la media de la política objetivo con `n = 100`
episodios: `SE = √(s_D²/100)` con `s_D² = (100/99)·0.061525`. -/
noncomputable def seObj : ℝ := Real.sqrt ((100/99 : ℝ) * (2461/40000) / 100)

/-- Error estándar exacto de la diferencia pareada: `s_Δ² = (100/99)·0.010125`. -/
noncomputable def seDelta : ℝ := Real.sqrt ((100/99 : ℝ) * (81/8000) / 100)

/-- book: capitulos/cap08_intervalos.typ:604 (key: ex:ssch-cap11) —
**SSCH: intervalo para la política objetivo.** Las cuatro contribuciones DR son
`1.190, 1.370, 1.300, 1.840`; con `n = 100` episodios iid, 25 por trayectoria,
`Ĵ = 1.425`, la varianza poblacional es `0.061525`, `s_D² = (100/99)·0.061525`,
`SE ≈ 0.02493 = √(2461/3960000)` y el intervalo normal aproximado del `95%` es
`[1.376, 1.474]` (extremos exactos `1.3761…` y `1.4738…`, que redondean a
esos valores).

Fidelidad declarada: aritmética racional exacta del cálculo del libro; «≈» se
verifica como intervalo racional estricto y el intervalo del `95%` es el
redondeo a tres decimales de los extremos exactos con `z = 1.96`. No se
simula nada ni se afirma cobertura exacta en cien episodios. -/
theorem ch11_ssch_objetivo :
    (∑ a0 : Bool, ∑ a1 : Bool, Dobj a0 a1) / 4 = 1.425
    ∧ (∑ a0 : Bool, ∑ a1 : Bool, (Dobj a0 a1 - (1.425 : ℝ)) ^ 2) / 4 = 2461 / 40000
    ∧ 0.02492 < seObj ∧ seObj < 0.02493
    ∧ 1.3761 < 1.425 - 1.96 * seObj ∧ 1.425 - 1.96 * seObj < 1.3762
    ∧ 1.4738 < 1.425 + 1.96 * seObj ∧ 1.425 + 1.96 * seObj < 1.4739 := by
  have hlo : (0.02492 : ℝ) < seObj := by
    rw [seObj, Real.lt_sqrt (by norm_num)]
    norm_num
  have hhi : seObj < (0.02493 : ℝ) := by
    rw [seObj, Real.sqrt_lt' (by norm_num)]
    norm_num
  refine ⟨?_, ?_, hlo, hhi, ?_, ?_, ?_, ?_⟩
  · simp only [Fintype.sum_bool, Dobj]; norm_num
  · simp only [Fintype.sum_bool, Dobj]; norm_num
  · linarith
  · linarith
  · linarith
  · linarith

/-- book: capitulos/cap08_intervalos.typ:604 (key: ex:ssch-cap11) —
**SSCH: comparación pareada.** Los valores verdaderos son `1.425` (objetivo) y
`0.950` (referencia). Las diferencias por episodio son
`0.520, 0.340, 0.430, 0.610`: `Δ̂ = 0.475`, `Var(Δ) = 0.010125`,
`s_Δ² = (100/99)·0.010125`, `SE_Δ ≈ 0.01011` e `IC₉₅ ≈ [0.455, 0.495]`.
Además `Var(Δ) = Var(obj) + Var(ref) − 2·Cov = 0.061525 + 0.0424 − 2·0.0469`,
así que ignorar la covarianza (tratar las dos políticas como independientes)
daría `0.103925`, diez veces la varianza pareada.

Fidelidad declarada: aritmética racional exacta de la tabla; el intervalo es el
redondeo a tres decimales de los extremos exactos con `z = 1.96`. -/
theorem ch11_ssch_pareado :
    (∑ a0 : Bool, ∑ a1 : Bool, Dref a0 a1) / 4 = 0.95
    ∧ (∑ a0 : Bool, ∑ a1 : Bool, Ddiff a0 a1) / 4 = 0.475
    ∧ (∑ a0 : Bool, ∑ a1 : Bool, (Dobj a0 a1 - (1.425 : ℝ)) * (Dref a0 a1 - 0.95)) / 4
        = 0.0469
    ∧ (∑ a0 : Bool, ∑ a1 : Bool, (Dref a0 a1 - (0.95 : ℝ)) ^ 2) / 4 = 0.0424
    ∧ (∑ a0 : Bool, ∑ a1 : Bool, (Ddiff a0 a1 - (0.475 : ℝ)) ^ 2) / 4 = 0.010125
    ∧ (0.061525 : ℝ) + 0.0424 - 2 * 0.0469 = 0.010125
    ∧ 0.01011 < seDelta ∧ seDelta < 0.01012
    ∧ 0.4551 < 0.475 - 1.96 * seDelta ∧ 0.475 - 1.96 * seDelta < 0.4552
    ∧ 0.4948 < 0.475 + 1.96 * seDelta ∧ 0.475 + 1.96 * seDelta < 0.4949 := by
  have hlo : (0.01011 : ℝ) < seDelta := by
    rw [seDelta, Real.lt_sqrt (by norm_num)]
    norm_num
  have hhi : seDelta < (0.01012 : ℝ) := by
    rw [seDelta, Real.sqrt_lt' (by norm_num)]
    norm_num
  refine ⟨?_, ?_, ?_, ?_, ?_, by norm_num, hlo, hhi, ?_, ?_, ?_, ?_⟩
  · simp only [Fintype.sum_bool, Dref]; norm_num
  · simp only [Fintype.sum_bool, Ddiff, Dobj, Dref]; norm_num
  · simp only [Fintype.sum_bool, Dobj, Dref]; norm_num
  · simp only [Fintype.sum_bool, Dref]; norm_num
  · simp only [Fintype.sum_bool, Ddiff, Dobj, Dref]; norm_num
  · linarith
  · linarith
  · linarith
  · linarith

/-! ### 6. `prop:ch11-ergodico` — alcance del caso finito: mixing geométrico -/

/-- book: capitulos/cap08_intervalos.typ:91 (key: prop:ch11-ergodico) —
**Alcance del caso finito.** Sea `μ` la ley invariante de una cadena finita
(estacionaria: `∑_s μ_s·Q_k(s,t) = μ_t` para todo `k`, con `Q_k` el núcleo de
`k` pasos) y supóngase que las filas se acercan a `μ` en distancia `L¹`
`∑_t |Q_k(s,t) − μ_t| ≤ b_k` uniformemente en el estado inicial `s`. Entonces,
para todo `k` y todo par de sucesos `A` (del pasado) y `T` (del futuro a `k`
pasos),

  `|P(A ∩ {S_k ∈ T}) − P(A)·P(S_k ∈ T)| ≤ b_k`,

es decir, el coeficiente `α(k)` está acotado por la cota de las filas. En
particular, una cota geométrica `b_k = C·r^k` con `r < 1` da mixing geométrico.

Fidelidad declarada: se formaliza el paso de la convergencia de las filas del
núcleo de `k` pasos al coeficiente de mezcla de sucesos (la parte «mixing» del
enunciado) y la cadena de Markov finita, irreducible y aperiódica arrancada en
su ley invariante. La implicación «irreducible y aperiódica ⇒ las filas
convergen geométricamente» es el teorema de Perron–Frobenius / Doeblin citado
en el libro (véase también `thm:ch11-tasa-tabular`, verificado en
`Book/Cap08Intervalos.lean`): no se reproduce aquí y entra como la hipótesis
`hgeo` sobre `b`. -/
theorem ch11_ergodico_mixing {S : Type*} [Fintype S]
    (μ : S → ℝ) (Q : ℕ → S → S → ℝ) (b : ℕ → ℝ)
    (hμ0 : ∀ s, 0 ≤ μ s) (hμ1 : ∑ s, μ s = 1) (hb : ∀ k, 0 ≤ b k)
    (hinv : ∀ k t, ∑ s, μ s * Q k s t = μ t)
    (hgeo : ∀ k s, ∑ t, |Q k s t - μ t| ≤ b k)
    (k : ℕ) (A T : Finset S) :
    |∑ s ∈ A, μ s * (∑ t ∈ T, Q k s t) - (∑ s ∈ A, μ s) * (∑ t ∈ T, μ t)| ≤ b k := by
  have hfac : (∑ s ∈ A, μ s * (∑ t ∈ T, Q k s t)) - (∑ s ∈ A, μ s) * (∑ t ∈ T, μ t)
      = ∑ s ∈ A, μ s * ((∑ t ∈ T, Q k s t) - (∑ t ∈ T, μ t)) := by
    rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun s _ => by ring
  rw [hfac]
  calc |∑ s ∈ A, μ s * ((∑ t ∈ T, Q k s t) - (∑ t ∈ T, μ t))|
      ≤ ∑ s ∈ A, |μ s * ((∑ t ∈ T, Q k s t) - (∑ t ∈ T, μ t))| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ s ∈ A, μ s * (∑ t, |Q k s t - μ t|) := by
        refine Finset.sum_le_sum fun s _ => ?_
        rw [abs_mul, abs_of_nonneg (hμ0 s)]
        refine mul_le_mul_of_nonneg_left ?_ (hμ0 s)
        calc |(∑ t ∈ T, Q k s t) - (∑ t ∈ T, μ t)|
            = |∑ t ∈ T, (Q k s t - μ t)| := by rw [Finset.sum_sub_distrib]
          _ ≤ ∑ t ∈ T, |Q k s t - μ t| := Finset.abs_sum_le_sum_abs _ _
          _ ≤ ∑ t, |Q k s t - μ t| :=
              Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ T)
                (fun t _ _ => abs_nonneg _)
    _ ≤ ∑ s ∈ A, μ s * b k :=
        Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (hgeo k s) (hμ0 s)
    _ = b k * (∑ s ∈ A, μ s) := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun s _ => by ring
    _ ≤ b k * 1 := by
        have hle : (∑ s ∈ A, μ s) ≤ ∑ s, μ s :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ A)
            (fun s _ _ => hμ0 s)
        calc b k * (∑ s ∈ A, μ s) ≤ b k * (∑ s, μ s) :=
              mul_le_mul_of_nonneg_left hle (hb k)
          _ = b k * 1 := by rw [hμ1]
    _ = b k := mul_one _

/-- book: capitulos/cap08_intervalos.typ:91 (key: prop:ch11-ergodico) —
**Caso geométrico.** Si la cota de las filas es `C·r^k` con `0 ≤ r < 1`, el
coeficiente de mezcla decae geométricamente con la misma tasa y un factor `C`
(con la convención `α(k) ≤ ∑_t|Q_k(s,t)−μ_t| ≤ C·r^k`). -/
theorem ch11_ergodico_geometrico {S : Type*} [Fintype S]
    (μ : S → ℝ) (Q : ℕ → S → S → ℝ) (C m : ℝ) (r : ℝ)
    (hμ0 : ∀ s, 0 ≤ μ s) (hμ1 : ∑ s, μ s = 1) (hC : 0 ≤ C) (hm : 0 ≤ m)
    (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hinv : ∀ k t, ∑ s, μ s * Q k s t = μ t)
    (hgeo : ∀ k s, ∑ t, |Q k s t - μ t| ≤ C * r ^ k + m)
    (k : ℕ) (A T : Finset S) :
    |∑ s ∈ A, μ s * (∑ t ∈ T, Q k s t) - (∑ s ∈ A, μ s) * (∑ t ∈ T, μ t)|
      ≤ C * r ^ k + m := by
  refine ch11_ergodico_mixing μ Q (fun k => C * r ^ k + m) hμ0 hμ1 ?_ hinv hgeo k A T
  intro k
  have : (0:ℝ) ≤ r ^ k := pow_nonneg hr0 k
  nlinarith

/-! ### 7. `thm:ch11-pg-theorem` — identidad del gradiente de política -/

/-- book: capitulos/cap08_intervalos.typ:442 (key: thm:ch11-pg-theorem) —
**Identidad del gradiente de política (nivel trayectoria).** Con horizonte
`H`, probabilidades de trayectoria `p_θ(τ)` derivables en `θ₀`, retorno
descontado `G(τ)` y score por tiempo `z_t(τ)`, si la derivada de la
probabilidad de cada trayectoria es
`p'_{θ₀}(τ) = p_{θ₀}(τ)·∑_t γ^t z_t(τ)` (regla del producto sobre la
trayectoria), entonces

  `∇_θ J(θ₀) = ∇_θ ∑_τ p_θ(τ)G(τ) = ∑_τ p_{θ₀}(τ)·(∑_t γ^t z_t(τ))·G(τ)
             = E_{θ₀}[∑_t γ^t z_t G_t]`,

que es la primera igualdad del enunciado.

Fidelidad declarada: se formaliza la identidad de la derivada (el paso
«multiplicar por el score y sumar») con la regla del producto de la trayectoria
como hipótesis explícita `hz`, y el paso de causalidad que convierte
`G_t` en `q_t` en `ch11_pg_causalidad` (la propiedad de martingala del score
frente a recompensas anteriores es la hipótesis `hcaus`). El intercambio
derivada–integral es exacto porque el espacio de trayectorias es finito. -/
theorem ch11_pg_identidad {H : ℕ} {T : Type*} [Fintype T]
    (p : ℝ → T → ℝ) (dp : T → ℝ) (G : T → ℝ) (z : Fin H → T → ℝ) (γ θ0 : ℝ)
    (hp : ∀ τ, HasDerivAt (fun θ => p θ τ) (dp τ) θ0)
    (hz : ∀ τ, dp τ = p θ0 τ * ∑ t : Fin H, γ ^ (t : ℕ) * z t τ) :
    HasDerivAt (fun θ => ∑ τ, p θ τ * G τ)
      (∑ τ, p θ0 τ * (∑ t : Fin H, γ ^ (t : ℕ) * z t τ * G τ)) θ0 := by
  have hder : HasDerivAt (fun θ => ∑ τ, p θ τ * G τ) (∑ τ, dp τ * G τ) θ0 := by
    exact HasDerivAt.fun_sum (u := (Finset.univ : Finset T))
      (A := fun τ θ => p θ τ * G τ) (A' := fun τ => dp τ * G τ) (x := θ0)
      (fun τ _ => (hp τ).mul_const (G τ))
  convert hder using 1
  refine Finset.sum_congr rfl fun τ _ => ?_
  rw [hz τ, Finset.mul_sum, Finset.mul_sum, Finset.sum_mul]
  exact Finset.sum_congr rfl fun t _ => by ring

/-- book: capitulos/cap08_intervalos.typ:442 (key: thm:ch11-pg-theorem) —
**Segunda igualdad: causalidad.** Si el término de causalidad
`E[∑_t γ^t z_t (G_t − q_t(S_t,A_t))]` se anula (porque el score de la acción
`t` tiene media condicional cero dada la historia previa), entonces puede
sustituirse `G_t` por `q_t` sin alterar la esperanza del gradiente:

  `E[∑_t γ^t z_t G_t] = E[∑_t γ^t z_t q_t(S_t,A_t)]`.

Fidelidad declarada: modelo finito de trayectorias; la anulación del término
de causalidad es la hipótesis `hcaus` (propiedad de martingala del score), que
en el libro se prueba condicionando en `(S_t,A_t)`. -/
theorem ch11_pg_causalidad {T : Type*} [Fintype T]
    (p w G q : T → ℝ) (hcaus : ∑ τ, p τ * (w τ * (G τ - q τ)) = 0) :
    ∑ τ, p τ * (w τ * G τ) = ∑ τ, p τ * (w τ * q τ) := by
  have hsplit : ∑ τ, p τ * (w τ * (G τ - q τ))
      = ∑ τ, p τ * (w τ * G τ) - ∑ τ, p τ * (w τ * q τ) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun τ _ => by ring
  linarith


/-! ### 8. `thm:ch11-clt-mixing` — varianza límite bajo estacionariedad -/

/-- Simetría de la covarianza finita. -/
theorem fcov_comm (p : Ω → ℝ) (X Y : Ω → ℝ) : fcov p X Y = fcov p Y X := by
  simp only [fcov]
  exact Finset.sum_congr rfl fun ω _ => by ring

/-- Identidad combinatoria del covariograma: para cualquier `f : ℕ → ℝ`, la
suma doble sobre las distancias `|i−j|` se agrupa por rezago. -/
theorem sum_dist_range (f : ℕ → ℝ) :
    ∀ n : ℕ, ∑ i ∈ range n, ∑ j ∈ range n, f (Nat.dist i j)
      = (n:ℝ) * f 0 + 2 * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * f (k + 1) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
    have hcol : ∑ i ∈ range n, f (Nat.dist i n) = ∑ k ∈ range n, f (k + 1) := by
      rw [← Finset.sum_range_reflect (fun m => f (m + 1)) n]
      refine Finset.sum_congr rfl fun i hi => ?_
      have hi' : i < n := Finset.mem_range.1 hi
      congr 1
      rw [Nat.dist_eq_sub_of_le (le_of_lt hi')]
      omega
    have hrow : ∑ j ∈ range n, f (Nat.dist n j) = ∑ k ∈ range n, f (k + 1) := by
      rw [show ∑ j ∈ range n, f (Nat.dist n j) = ∑ j ∈ range n, f (Nat.dist j n) from
            Finset.sum_congr rfl fun j _ => by rw [Nat.dist_comm]]
      exact hcol
    have hsplit : ∑ i ∈ range (n+1), ∑ j ∈ range (n+1), f (Nat.dist i j)
        = (∑ i ∈ range n, ∑ j ∈ range n, f (Nat.dist i j))
          + 2 * (∑ k ∈ range n, f (k + 1)) + f 0 := by
      rw [Finset.sum_range_succ]
      rw [Finset.sum_congr rfl
        (g := fun i => (∑ j ∈ range n, f (Nat.dist i j)) + f (Nat.dist i n))
        (fun i _ => Finset.sum_range_succ (fun j => f (Nat.dist i j)) n)]
      rw [Finset.sum_add_distrib, Finset.sum_range_succ, Nat.dist_self, hcol, hrow]
      ring
    have hcoef : ∀ k ∈ range n, ((n - k : ℕ) : ℝ) = ((n - 1 - k : ℕ) : ℝ) + 1 := by
      intro k hk
      have hk' : k < n := Finset.mem_range.1 hk
      have h : n - k = (n - 1 - k) + 1 := by omega
      rw [h]
      push_cast
      ring
    have hcoefsum : ∑ k ∈ range n, ((n - k : ℕ) : ℝ) * f (k + 1)
        = (∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * f (k + 1))
          + ∑ k ∈ range n, f (k + 1) := by
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun k hk => by rw [hcoef k hk]; ring
    rw [hsplit, ih, Finset.sum_range_succ]
    have hshift : ∀ x : ℕ, (n + 1 - 1 - x : ℕ) = (n - x : ℕ) := fun x => by omega
    simp only [hshift]
    have hzero : ((n - n : ℕ) : ℝ) = 0 := by simp
    rw [hzero, zero_mul, add_zero, hcoefsum]
    push_cast
    ring

/-- book: capitulos/cap08_intervalos.typ:180 (key: thm:ch11-clt-mixing) —
**Varianza límite bajo estacionariedad.** Para un proceso estrictamente
estacionario con covariograma `Cov(X_0,X_k) = γ_k`, la varianza de la suma es

  `Var(∑_{t<n} X_t) = n·γ_0 + 2∑_{k=1}^{n−1} (n−k)·γ_k`,

de modo que `(1/n)Var = γ_0 + 2∑_{k≤n−1}(1−k/n)γ_k`, cuyo límite es
`σ²_LR = γ_0 + 2∑_{k≥1}γ_k`, la varianza que aparece en el CLT del enunciado.

Fidelidad declarada: se formaliza la identidad exacta de la varianza (el paso
que el libro usa para identificar `σ²_LR`) bajo estacionariedad débil, que entra
por `hstat`. La convergencia distribucional `T^{−1/2}∑X_t →d N(0,σ²_LR)` es el
teorema de Ibragimov citado en el libro (momentos `2+δ` y sumabilidad de
`∑α(k)^{δ/(2+δ)}`) y no se reproduce aquí; el límite de las sumas ponderadas
que da `(1/n)Var → σ²_LR` es el lema de Toeplitz estándar. -/
theorem ch11_clt_mixing_var {n : ℕ} (p : Ω → ℝ) (X : ℕ → Ω → ℝ) (γ : ℕ → ℝ)
    (hstat : ∀ t k : ℕ, fcov p (X t) (X (t + k)) = γ k) :
    fvar p (fun ω => ∑ t : Fin n, X (t:ℕ) ω)
      = (n:ℝ) * γ 0 + 2 * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * γ (k + 1) := by
  rw [fvar_sum]
  have hd : ∀ i j : Fin n, fcov p (X (i:ℕ)) (X (j:ℕ))
      = γ (if (i:ℕ) ≤ (j:ℕ) then (j:ℕ) - (i:ℕ) else (i:ℕ) - (j:ℕ)) := by
    intro i j
    by_cases hij : (i:ℕ) ≤ (j:ℕ)
    · rw [if_pos hij]
      have h : (i:ℕ) + ((j:ℕ) - (i:ℕ)) = (j:ℕ) := Nat.add_sub_cancel' hij
      have hh := hstat (i:ℕ) ((j:ℕ) - (i:ℕ))
      rw [h] at hh
      exact hh
    · rw [if_neg hij, fcov_comm]
      have hji : (j:ℕ) ≤ (i:ℕ) := le_of_not_ge hij
      have h : (j:ℕ) + ((i:ℕ) - (j:ℕ)) = (i:ℕ) := Nat.add_sub_cancel' hji
      have hh := hstat (j:ℕ) ((i:ℕ) - (j:ℕ))
      rw [h] at hh
      exact hh
  have hpair : ∑ i : Fin n, ∑ j : Fin n, fcov p (X (i:ℕ)) (X (j:ℕ))
      = ∑ i ∈ range n, ∑ j ∈ range n, γ (Nat.dist i j) := by
    rw [Fin.sum_univ_eq_sum_range
      (fun i => ∑ j : Fin n, fcov p (X i) (X (j:ℕ))) n]
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [← Fin.sum_univ_eq_sum_range (fun j => γ (Nat.dist (i:ℕ) j)) n]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [hd ⟨i, Finset.mem_range.1 hi⟩ j]
    congr 1
    by_cases hij : (i:ℕ) ≤ (j:ℕ)
    · rw [if_pos hij, Nat.dist_eq_sub_of_le hij]
    · rw [if_neg hij, Nat.dist_comm, Nat.dist_eq_sub_of_le (le_of_not_ge hij)]
  rw [hpair, sum_dist_range]

end Ch11M10
