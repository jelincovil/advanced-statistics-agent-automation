import Mathlib
import Book.Foundation

/-!
# Book.Cap04Herramientas — cap. 1-4 del libro (cap04_herramientas.typ)

Familias exponenciales en espacio muestral finito: funcion de
particion `Z(η) = ∑_x h(x)·exp(η·T(x))`, log-particion `A(η) = log Z(η)`,
y la identidad derivada = media (`thm:ch1-logparticion`).
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

universe u

section ExpFam

variable {X : Type u} [Fintype X] [Nonempty X] (h : X → ℝ) (T : X → ℝ)

/-- Funcion de particion: `Z(η) = ∑_x h(x)·exp(η·T(x))`. -/
noncomputable def partFun (η : ℝ) : ℝ := ∑ x, h x * Real.exp (η * T x)

/-- Log-particion: `A(η) = log Z(η)`. -/
noncomputable def logPart (η : ℝ) : ℝ := Real.log (partFun h T η)

/-- Esperanza del estadistico `T` bajo la familia exponencial. -/
noncomputable def expMean (η : ℝ) : ℝ :=
  ∑ x, T x * (h x * Real.exp (η * T x)) / partFun h T η

/-- Varianza del estadistico `T` bajo la familia exponencial. -/
noncomputable def expVar (η : ℝ) : ℝ :=
  ∑ x, (T x - expMean h T η) ^ 2 * (h x * Real.exp (η * T x) / partFun h T η)

/-- Positividad de la funcion de particion (pesos positivos). -/
theorem partFun_pos (hpos : ∀ x, 0 < h x) (η : ℝ) : 0 < partFun h T η := by
  obtain ⟨x₀⟩ := ‹Nonempty X›
  refine Finset.sum_pos' (fun x _ => ?_) ⟨x₀, Finset.mem_univ x₀, ?_⟩
  · exact mul_nonneg (le_of_lt (hpos x)) (le_of_lt (Real.exp_pos (η * T x)))
  · exact mul_pos (hpos x₀) (Real.exp_pos (η * T x₀))

/-- Derivada de la funcion de particion (base no enunciada):
`Z'(η) = ∑_x h(x)·exp(η·T(x))·T(x)`. La prueba usa HasDerivAt.sum
sobre la forma suma-de-funciones (la igualdad con partFun es por
funext + Finset.sum_apply, aplicada como reescritura previa). -/
theorem hasDerivAt_partFun (η : ℝ) :
    HasDerivAt (partFun h T) (∑ x, h x * (Real.exp (η * T x) * T x)) η := by
  have h1 : ∀ x : X, HasDerivAt (fun y => h x * Real.exp (y * T x))
      (h x * (Real.exp (η * T x) * T x)) η := by
    intro x
    have hmul : HasDerivAt (fun y => y * T x) (T x) η := by
      simpa using (hasDerivAt_id η).mul_const (T x)
    exact hmul.exp.const_mul (h x)
  have hfun : partFun h T = (∑ x : X, fun y => h x * Real.exp (y * T x)) := by
    funext y
    simp [partFun, Finset.sum_apply]
  rw [hfun]
  exact HasDerivAt.sum fun x _ => h1 x

/-- book: capitulos/cap04_herramientas.typ:314 (key: thm:ch1-logparticion) —
propiedades de la funcion log-particion (parte 3: cumulantes): la
primera derivada de `A(η)` es la esperanza del estadistico natural:
`A'(η) = E_η[T(X)]`. La prueba es la regla de la cadena para
`log ∘ Z` con `Z'` de `hasDerivAt_partFun`, seguida de la
reorganizacion `Z'/Z = E_η[T]`.
Fidelidad declarada: version finita con estadistico y parametro
escalares; la convexidad y la diferenciabilidad infinita son
cualitativas y no se enuncian por separado.
Origen: F-correction 2026-11-07 (nuevo; formalizacion de pendiente). -/
theorem ch1_logparticion (hpos : ∀ x, 0 < h x) (η : ℝ) :
    HasDerivAt (logPart h T) (expMean h T η) η := by
  have hZ := hasDerivAt_partFun h T η
  have hZpos := partFun_pos h T hpos η
  have hlog := hZ.log (ne_of_gt hZpos)
  have heq : (∑ x, h x * (Real.exp (η * T x) * T x)) / partFun h T η
      = expMean h T η := by
    unfold expMean
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun x _ => by ring
  rw [heq] at hlog
  exact hlog

/-- Numerador de la media: `N(ξ) = ∑_x T(x)·h(x)·exp(ξ·T(x))` (base no enunciada). -/
noncomputable def expNum (ξ : ℝ) : ℝ := ∑ x, T x * (h x * Real.exp (ξ * T x))

/-- Derivada del numerador: `N'(η) = ∑_x T(x)²·h(x)·exp(η·T(x))` (con un T extra). -/
theorem hasDerivAt_expNum (η : ℝ) :
    HasDerivAt (expNum h T) (∑ x, T x * (h x * (Real.exp (η * T x) * T x))) η := by
  have h1 : ∀ x : X, HasDerivAt (fun y => T x * (h x * Real.exp (y * T x)))
      (T x * (h x * (Real.exp (η * T x) * T x))) η := by
    intro x
    have hmul : HasDerivAt (fun y => y * T x) (T x) η := by
      simpa using (hasDerivAt_id η).mul_const (T x)
    exact (hmul.exp.const_mul (h x)).const_mul (T x)
  have hfun : expNum h T = (∑ x : X, fun y => T x * (h x * Real.exp (y * T x))) := by
    funext y
    simp [expNum, Finset.sum_apply]
  rw [hfun]
  exact HasDerivAt.sum fun x _ => h1 x

/-- book: capitulos/cap04_herramientas.typ:322 (key: cor:ch1-covarianza-hessiano) —
la segunda derivada de la log-partición es la varianza del estadístico
natural: `A''(η) = Var_η[T(X)] = E[T²] − E[T]²`. La prueba es la regla
del cociente para `N/Z` (con `N' = ∑T²·h·exp`, `Z' = N`), seguida de
la descomposición en denominador común:
`(N'·Z − N²)/Z² = N'/Z − (N/Z)² = E[T²] − E[T]²`.
Fidelidad declarada: versión finita con estadístico y parámetro
escalares; «la matriz de covarianzas es semidefinida positiva» sigue
de `A'' ≥ 0` (que es `Var ≥ 0`); «en familias minimales es definida
positiva» no se enuncia; la forma `∑(T−E)²·p` de la varianza es
equivalente (descomposición estándar) y se declara en el docstring.
Origen: F-correction 2026-11-07 (nuevo; formalización de pendiente). -/
theorem cor_ch1_covarianza_hessiano (hpos : ∀ x, 0 < h x) (η : ℝ) :
    HasDerivAt (fun ξ => expMean h T ξ)
      ((∑ x, T x * T x * (h x * Real.exp (η * T x))) / partFun h T η
       - (expNum h T η / partFun h T η)^2) η := by
  -- Setup
  have hZpos : (0:ℝ) < partFun h T η := partFun_pos h T hpos η
  have hZne : partFun h T η ≠ 0 := ne_of_gt hZpos
  -- (i) N' = ∑T²·h·exp (reordenando factores)
  have hN' : (∑ x, T x * (h x * (Real.exp (η * T x) * T x)))
      = (∑ x, T x * T x * (h x * Real.exp (η * T x))) := by
    exact Finset.sum_congr rfl fun x _ => by ring
  -- (ii) Z' = N (reordenando factores)
  have hZ' : (∑ x, h x * (Real.exp (η * T x) * T x)) = expNum h T η := by
    unfold expNum
    exact Finset.sum_congr rfl fun x _ => by ring
  -- (iii) Regla del cociente
  have hN := hasDerivAt_expNum h T η
  have hD := hasDerivAt_partFun h T η
  have hdiv := HasDerivAt.div hN hD hZne
  -- (iv) Reescribir expMean como N/Z
  have hEq : (fun ξ => expMean h T ξ) = (fun ξ => expNum h T ξ / partFun h T ξ) := by
    funext ξ
    unfold expMean expNum
    rw [Finset.sum_div]
  rw [hN', hZ'] at hdiv
  -- hdiv : HasDerivAt (N/Z) ((∑T²·h·exp * Z - N²)/Z²) η
  -- (v) Denominador común: (A·Z - N²)/Z² = A/Z - (N/Z)²
  have h1 : ∀ a b c : ℝ, c ≠ 0 → (a * c - b * b) / c ^ 2 = a / c - (b / c) ^ 2 := by
    intro a b c hc
    field_simp
  have hval : ((∑ x, T x * T x * (h x * Real.exp (η * T x))) * partFun h T η
      - expNum h T η * expNum h T η) / partFun h T η ^ 2
      = (∑ x, T x * T x * (h x * Real.exp (η * T x))) / partFun h T η
        - (expNum h T η / partFun h T η)^2 :=
    h1 _ _ _ hZne
  rw [hval] at hdiv
  rw [hEq]
  exact hdiv


/-- book: capitulos/cap04_herramientas.typ:1393 (key: thm:ch4-bonferroni) —
corrección de Bonferroni: para p-valores válidos (superuniformes bajo
sus nulas) y una familia fijada de `m` tests, para controlar
`FWER ≤ α`, rechazar `H_{0,i}` solo si `p_i ≤ α/m`. La prueba es la
desigualdad de Boole (cota de unión, aquí como hipótesis `hsubadd`):
`P(∪_{i∈I₀} E_i) ≤ ∑ P(E_i) ≤ |I₀|·α/m ≤ α`.
Fidelidad declarada: la subaditividad de la probabilidad (Boole) se
toma como hipótesis — en un espacio de probabilidad estándar sigue de
la teoría de la medida; la superuniformidad `P(p_i ≤ t) ≤ t` también
se toma como hipótesis (es la definición de p-valores válidos);
`I₀` es el conjunto de hipótesis nulas verdaderas con `|I₀| ≤ m`.
Origen: F-correction 2026-11-07 (nuevo; formalización de pendiente). -/
theorem ch4_bonferroni {ι : Type*} [Fintype ι]
    {m : ℕ} (hm : 0 < m) (α : ℝ) (hα : 0 ≤ α)
    (I₀ : Finset ι) (hcard : I₀.card ≤ m)
    {Ω : Type*} (P : Set Ω → ℝ) (E : ι → Set Ω)
    (hsubadd : ∀ (F : Finset ι) (G : ι → Set Ω),
        P (⋃ i ∈ F, G i) ≤ ∑ i ∈ F, P (G i))
    (hE : ∀ i ∈ I₀, P (E i) ≤ α / m) :
    P (⋃ i ∈ I₀, E i) ≤ α := by
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  have hcardR : (I₀.card : ℝ) ≤ m := by exact_mod_cast hcard
  have hαm : (0:ℝ) ≤ α / m := div_nonneg hα (le_of_lt hmR)
  calc P (⋃ i ∈ I₀, E i) ≤ ∑ i ∈ I₀, P (E i) := hsubadd I₀ E
    _ ≤ ∑ i ∈ I₀, α / m := Finset.sum_le_sum fun i hi => hE i hi
    _ ≤ α := by
        have h1 : ∑ i ∈ I₀, α / m = (I₀.card : ℝ) * (α / m) := by
          rw [Finset.sum_const]
          simp
        have h2 : (I₀.card : ℝ) * (α / m) ≤ (m : ℝ) * (α / m) :=
          mul_le_mul_of_nonneg_right hcardR hαm
        have h3 : (m : ℝ) * (α / m) = α := by
          field_simp
        exact le_trans (le_of_eq h1) (le_trans h2 (le_of_eq h3))


/-- book: capitulos/cap04_herramientas.typ:600 (key: thm:ch2-neyman-fisher) —
factorización de Neyman-Fisher (caso discreto, dirección directa): si
las densidades factorizan como `P_θ(x) = g_θ(T(x))·h(x)`, entonces la
distribución condicional `P_θ(x₀ | T(X) = T(x₀))` no depende de `θ`.
Enunciado en forma de multiplicación cruzada (evita división):
`P_θ(x₀)·P_θ'(T = t) = P_θ'(x₀)·P_θ(T = t)` para todo par `θ, θ'`.
Prueba: la marginal de `T` bajo la factorización es
`∑_{T(x')=t} P_θ(x') = g_θ(t)·∑_{T(x')=t} h(x')` (el `g_θ(t)` se
factoriza como constante en la fibra); al sustituir, ambos lados de
la multiplicación cruzada son `g_θ(t)·g_θ'(t)·h(x₀)·∑h`.
Fidelidad declarada: solo la dirección directa (factorización ⟹
suficiencia); la conversa requiere distribución condicional regular;
el caso continuo del libro (espacios de Borel, Radon–Nikodym) no se
formaliza.
Origen: F-correction 2026-11-07 (nuevo; formalización de pendiente). -/
theorem ch2_neyman_fisher {Θ : Type*} [Fintype Θ]
    (p : Θ → X → ℝ) (hbase : X → ℝ) (g : Θ → ℝ → ℝ)
    (hfac : ∀ θ x, p θ x = g θ (T x) * hbase x)
    (x₀ : X) :
    ∀ θ θ' : Θ,
      p θ x₀ * (∑ x', if T x' = T x₀ then p θ' x' else 0)
      = p θ' x₀ * (∑ x', if T x' = T x₀ then p θ x' else 0) := by
  -- Lema clave: la marginal de T bajo la factorización
  have hsum : ∀ θ : Θ, (∑ x', if T x' = T x₀ then p θ x' else 0)
      = g θ (T x₀) * (∑ x', if T x' = T x₀ then hbase x' else 0) := by
    intro θ
    have step1 : ∀ x' : X, (if T x' = T x₀ then p θ x' else 0)
        = g θ (T x₀) * (if T x' = T x₀ then hbase x' else 0) := by
      intro x'
      by_cases hx : T x' = T x₀
      · simp [hx, hfac θ x']
      · simp [hx]
    rw [Finset.sum_congr rfl fun x' _ => step1 x']
    rw [← Finset.mul_sum]
  -- Sustituir y cerrar por conmutatividad
  intro θ θ'
  rw [hfac θ x₀, hfac θ' x₀, hsum θ, hsum θ']
  ring



/-- book: capitulos/cap04_herramientas.typ:680 (key: thm:ch2-completitud-exponencial) --
completitud en familias exponenciales (caso minimo, T constante): si el
estadistico natural es constante (un solo valor c) y E[g(T)] = 0 para
todo eta, entonces g(c) = 0. El caso general usa Vandermonde kxk
(exp inyectiva, det no nulo para valores distintos).
Fidelidad: caso minimo (constante) -- el general usa Vandermonde kxk
y queda como extension documentada.
Origen: F-correction 2026-11-07 (nuevo; formalizacion de pendiente). -/
theorem ch2_completitud_const (hpos : ∀ x, 0 < h x) (c : ℝ) (hT : ∀ x : X, T x = c)
    (g : ℝ → ℝ) (hvan : ∀ η : ℝ, ∑ x : X, g (T x) * h x * Real.exp (η * T x) = 0) :
    g c = 0 := by
  have h0 := hvan 0
  simp only [zero_mul, Real.exp_zero, mul_one] at h0
  have h1 : ∑ x : X, g (T x) * h x = g c * ∑ x : X, h x := by
    rw [Finset.sum_congr rfl fun x _ => by rw [hT x]]
    rw [← Finset.mul_sum]
  rw [h1] at h0
  have hsum_pos : 0 < ∑ x : X, h x := Finset.sum_pos (fun x _ => hpos x) Finset.univ_nonempty
  exact (mul_eq_zero.mp h0).resolve_right (ne_of_gt hsum_pos)

open Filter

/-- Para `a < 0` se tiene `exp (η * a) → 0` cuando `η → +∞`. -/
theorem tendsto_exp_mul_neg {a : ℝ} (ha : a < 0) :
    Tendsto (fun η : ℝ => Real.exp (η * a)) atTop (nhds 0) := by
  have hb : 0 < -a := by linarith
  have h1 : Tendsto (fun η : ℝ => η * (-a)) atTop atTop :=
    Tendsto.atTop_mul_const hb tendsto_id
  have h2 : Tendsto (fun η : ℝ => Real.exp (η * (-a))) atTop atTop :=
    Real.tendsto_exp_atTop.comp h1
  have h3 : Tendsto (fun η : ℝ => (Real.exp (η * (-a)))⁻¹) atTop (nhds 0) :=
    tendsto_inv_atTop_zero.comp h2
  simpa [mul_neg, Real.exp_neg] using h3

section ExpFam

variable {X : Type u} [Fintype X] [Nonempty X] (h : X → ℝ) (T : X → ℝ)

/-- book: capitulos/cap04_herramientas.typ:680 (key: thm:ch2-completitud-exponencial) —
completitud en familias exponenciales (caso general): si `h > 0` y la
identidad `∑_x g(T x)·h x·exp(η·T x) = 0` vale para todo `η : ℝ`,
entonces `g` se anula sobre todo valor de `T`.

Prueba (argumento de dominancia, sin Vandermonde): supongamos que algún
valor del soporte `B = {x : g(T x) ≠ 0}` sobrevive. Sea `m` el máximo de
`T` sobre `B`; el término `x` con `T x = m` domina. Como la identidad vale
para todo `η`, también vale la versión desplazada
`∑_x g(T x)·h x·exp(η·(T x − m)) = 0`. Al hacer `η → +∞` cada `x` con
`T x < m` tiende a `0`, y los de la fibra `T x = m` son constantes; el
límite es `g m · ∑_{x ∈ B, T x = m} h x = 0`. El segundo factor es
estrictamente positivo (suma no vacía de `h > 0`), luego `g m = 0`,
contradiciendo `m ∈ T '' B`. -/
theorem ch2_completitud_exponencial (hpos : ∀ x, 0 < h x) (g : ℝ → ℝ)
    (hvan : ∀ η : ℝ, ∑ x : X, g (T x) * h x * Real.exp (η * T x) = 0) :
    ∀ t ∈ (Finset.univ : Finset X).image T, g t = 0 := by
  classical
  intro t₀ ht₀
  by_contra hg₀
  -- un `x₀` con `T x₀ = t₀`
  obtain ⟨x₀, -, hx₀⟩ := Finset.mem_image.mp ht₀
  -- soporte de `x ↦ g (T x)`
  set B : Finset X := Finset.univ.filter (fun x => g (T x) ≠ 0) with hB
  have hBne : B.Nonempty := ⟨x₀, by simp [hB, hx₀, hg₀]⟩
  -- el máximo valor de `T` sobre el soporte
  set m : ℝ := (B.image T).max' (hBne.image T) with hm
  have hmem : m ∈ B.image T := Finset.max'_mem _ _
  obtain ⟨xb, hxbB, hxbm⟩ := Finset.mem_image.mp hmem
  -- `g m ≠ 0`
  have hgm : g m ≠ 0 := by
    have h1 : g (T xb) ≠ 0 := by simpa [hB] using hxbB
    rwa [hxbm] at h1
  -- identidad desplazada por `m`
  have hshift : ∀ η : ℝ,
      ∑ x : X, (g (T x) * h x) * Real.exp (η * (T x - m)) = 0 := by
    intro η
    calc ∑ x : X, (g (T x) * h x) * Real.exp (η * (T x - m))
        = ∑ x : X, (g (T x) * h x) * Real.exp (η * T x) / Real.exp (η * m) := by
          refine Finset.sum_congr rfl (fun x _ => ?_)
          rw [mul_sub, Real.exp_sub]
          ring
      _ = (∑ x : X, (g (T x) * h x) * Real.exp (η * T x)) / Real.exp (η * m) := by
          rw [Finset.sum_div]
      _ = 0 := by rw [hvan η]; simp
  -- la misma identidad restringida al soporte
  have hzero : ∀ η : ℝ,
      ∑ x ∈ B, (g (T x) * h x) * Real.exp (η * (T x - m)) = 0 := by
    intro η
    rw [Finset.sum_subset (Finset.subset_univ B) ?_]
    · simpa using hshift η
    · intro x _ hx
      have h1 : g (T x) = 0 := by
        by_contra hc
        exact hx (by simp [hB, hc])
      simp [h1]
  -- límite término a término
  have hterm : ∀ x ∈ B, Tendsto
      (fun η : ℝ => (g (T x) * h x) * Real.exp (η * (T x - m))) atTop
      (nhds (if T x = m then g (T x) * h x else 0)) := by
    intro x hx
    by_cases hxm : T x = m
    · have hconst : (fun η : ℝ => (g (T x) * h x) * Real.exp (η * (T x - m)))
          = fun _ => g (T x) * h x := by
        funext η
        rw [hxm, sub_self, mul_zero, Real.exp_zero, mul_one]
      rw [hconst, if_pos hxm]
      exact tendsto_const_nhds
    · have hlt : T x - m < 0 := by
        have hle : T x ≤ m :=
          Finset.le_max' _ _ (Finset.mem_image_of_mem T hx)
        have hlt : T x < m := lt_of_le_of_ne hle hxm
        linarith
      have h0 := tendsto_exp_mul_neg hlt
      have h1 := h0.const_mul (g (T x) * h x)
      rw [mul_zero] at h1
      simpa [hxm] using h1
  have hlim := tendsto_finsetSum B hterm
  -- el valor del límite es `g m` por la masa de la fibra
  have hval : (∑ x ∈ B, (if T x = m then g (T x) * h x else 0))
      = g m * ∑ x ∈ B.filter (fun x => T x = m), h x := by
    rw [← Finset.sum_filter, Finset.mul_sum]
    refine Finset.sum_congr rfl (fun x hx => ?_)
    have hx' : T x = m := (Finset.mem_filter.mp hx).2
    rw [hx']
  have hzeroT : Tendsto
      (fun η : ℝ => ∑ x ∈ B, (g (T x) * h x) * Real.exp (η * (T x - m))) atTop (nhds 0) := by
    have hfun : (fun η : ℝ => ∑ x ∈ B, (g (T x) * h x) * Real.exp (η * (T x - m)))
        = fun _ => 0 := by
      funext η
      exact hzero η
    rw [hfun]
    exact tendsto_const_nhds
  rw [hval] at hlim
  have huniq : (0 : ℝ) = g m * ∑ x ∈ B.filter (fun x => T x = m), h x :=
    tendsto_nhds_unique hzeroT hlim
  -- la masa de la fibra es estrictamente positiva
  have hwpos : 0 < ∑ x ∈ B.filter (fun x => T x = m), h x := by
    exact Finset.sum_pos' (fun x _ => le_of_lt (hpos x))
      ⟨xb, Finset.mem_filter.mpr ⟨hxbB, hxbm⟩, hpos xb⟩
  have hgm0 : g m = 0 :=
    (mul_eq_zero.mp huniq.symm).resolve_right (ne_of_gt hwpos)
  exact hgm hgm0

/-- La masa de una fibra no vacía de `T` es estrictamente positiva: la
suma de `h > 0` sobre `{x : T x = m}` es `> 0` si `m` es un valor de `T`. -/
theorem fiber_weight_pos (hpos : ∀ x, 0 < h x) {m : ℝ}
    (hm : m ∈ (Finset.univ : Finset X).image T) :
    0 < ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = m), h x := by
  classical
  obtain ⟨x₀, -, hx₀⟩ := Finset.mem_image.mp hm
  exact Finset.sum_pos' (fun x _ => le_of_lt (hpos x))
    ⟨x₀, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hx₀⟩, hpos x₀⟩

/-- Forma punto a punto de la completitud: `g (T x) = 0` para todo `x`. -/
theorem ch2_completitud_exponencial_pointwise (hpos : ∀ x, 0 < h x) (g : ℝ → ℝ)
    (hvan : ∀ η : ℝ, ∑ x : X, g (T x) * h x * Real.exp (η * T x) = 0) :
    ∀ x : X, g (T x) = 0 :=
  fun x => ch2_completitud_exponencial h T hpos g hvan (T x)
    (Finset.mem_image_of_mem T (Finset.mem_univ x))

/-- El caso general recupera el caso mínimo `ch2_completitud_const`
(estadístico constante): comprobación de que el enunciado general es la
generalización correcta. -/
theorem ch2_completitud_const_of_general (hpos : ∀ x, 0 < h x) (c : ℝ)
    (hT : ∀ x : X, T x = c) (g : ℝ → ℝ)
    (hvan : ∀ η : ℝ, ∑ x : X, g (T x) * h x * Real.exp (η * T x) = 0) :
    g c = 0 :=
  ch2_completitud_exponencial h T hpos g hvan c
    (Finset.mem_image.mpr ⟨Classical.arbitrary X, Finset.mem_univ _, hT _⟩)



/-! ### Independencia lineal de exponenciales (Vandermonde k×k) -/

/-- Independencia lineal de exponenciales reales en un parámetro real
(infraestructura para `thm:ch2-completitud-exponencial`). Si los puntos
`t i` son distintos y `∑_i c_i·exp(η·t_i) = 0` para todo `η : ℝ`,
entonces todos los `c_i` son cero. Prueba: evaluando en `η = 0,1,…,k-1`
queda el sistema de Vandermonde `∑_i c_i·(exp(t_i))^j = 0`, cuya matriz
tiene determinante no nulo porque `exp` es inyectiva. -/
theorem exp_linear_independent {k : ℕ} (t : Fin k → ℝ) (ht : Function.Injective t)
    (c : Fin k → ℝ) (hc : ∀ η : ℝ, ∑ i, c i * Real.exp (η * t i) = 0) : ∀ i, c i = 0 := by
  have hx_inj : Function.Injective (fun i : Fin k => Real.exp (t i)) :=
    fun i j hij => ht (Real.exp_injective hij)
  have hpow : ∀ j : Fin k, ∑ i : Fin k, c i * Real.exp (t i) ^ (j : ℕ) = 0 := by
    intro j
    simpa [Real.exp_nat_mul] using hc (j : ℝ)
  have hzero : c = 0 := Matrix.eq_zero_of_forall_pow_sum_mul_pow_eq_zero hx_inj hpow
  intro i
  simpa using congrFun hzero i

/-- Independencia lineal de exponenciales para un tipo índice finito
arbitrario: se enumera con `Fintype.equivFin` y se aplica
`exp_linear_independent`. -/
theorem exp_linear_independent_fintype {ι : Type*} [Fintype ι] (t : ι → ℝ)
    (ht : Function.Injective t) (c : ι → ℝ)
    (hc : ∀ η : ℝ, ∑ i, c i * Real.exp (η * t i) = 0) : ∀ i, c i = 0 := by
  classical
  set e := Fintype.equivFin ι with he
  have ht' : Function.Injective (fun i : Fin (Fintype.card ι) => t (e.symm i)) :=
    fun i j hij => e.symm.injective (ht hij)
  have hc' : ∀ η : ℝ,
      ∑ i : Fin (Fintype.card ι), c (e.symm i) * Real.exp (η * t (e.symm i)) = 0 := by
    intro η
    exact (Equiv.sum_comp e.symm (fun i : ι => c i * Real.exp (η * t i))).trans (hc η)
  have hzero := exp_linear_independent (fun i : Fin (Fintype.card ι) => t (e.symm i)) ht'
    (fun i => c (e.symm i)) hc'
  intro i
  simpa using hzero (e i)

/-- book: capitulos/cap04_herramientas.typ:680 (key: thm:ch2-completitud-exponencial) —
completitud de una familia exponencial finita sobre el estadístico `T`
(caso GENERAL, no necesariamente inyectivo), **segunda prueba independiente**
(ruta Vandermonde; la ruta de dominancia/límite queda en
`ch2_completitud_exponencial`): si los pesos son positivos
(`0 < h x` para todo `x`) y `E_η[g(T)] = ∑_x g(T x)·h(x)·exp(η·T x) = 0`
para todo `η : ℝ`, entonces `g` se anula en todo valor alcanzado por `T`,
i.e. `g t = 0` para todo `t ∈ (univ : Finset X).image T`.

Prueba: (1) se agrupa la suma por fibras de `T`
(`Finset.sum_fiberwise_of_maps_to`), de modo que cada término es
`(g t · w t)·exp(η·t)` con `w t = ∑_{x : T x = t} h x > 0`;
(2) se enumera la imagen `s = univ.image T` por `↥s ≃ Fin s.card` y se
aplica la independencia lineal de exponenciales
(`exp_linear_independent_fintype`, vía Vandermonde), que da
`g t · w t = 0` para todo `t ∈ s`;
(3) como `w t > 0` en la imagen (suma de pesos positivos sobre una fibra
no vacía), se concluye `g t = 0`.

Fidelidad declarada: versión finita con estadístico escalar
`T : X → ℝ` y parámetro escalar `η : ℝ`; los pesos `h` son positivos
pero no se exige normalización (`∑ h = 1` no interviene). El caso
`T` constante ya estaba cubierto por `ch2_completitud_const`, que queda
como caso particular. Extiende la formalización de pendiente
(F-correction 2026-11-07).
Origen: F-correction 2026-11-08 (caso general; cierra la brecha de ch2_completitud_const). -/
theorem ch2_completitud_exponencial_vandermonde (hpos : ∀ x, 0 < h x) (g : ℝ → ℝ)
    (hvan : ∀ η : ℝ, ∑ x : X, g (T x) * h x * Real.exp (η * T x) = 0) :
    ∀ t ∈ (Finset.univ : Finset X).image T, g t = 0 := by
  classical
  set s : Finset ℝ := (Finset.univ : Finset X).image T with hs
  set w : ℝ → ℝ :=
    fun t => ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t), h x with hw
  -- (1) agrupación por fibras de T
  have hgrp : ∀ η : ℝ, ∑ t ∈ s, (g t * w t) * Real.exp (η * t) = 0 := by
    intro η
    have hmap : ∀ x ∈ (Finset.univ : Finset X), T x ∈ s :=
      fun x _ => Finset.mem_image_of_mem T (Finset.mem_univ x)
    have hfiber : ∑ t ∈ s,
          ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
            g (T x) * h x * Real.exp (η * T x)
        = ∑ x : X, g (T x) * h x * Real.exp (η * T x) :=
      Finset.sum_fiberwise_of_maps_to hmap
        (fun x : X => g (T x) * h x * Real.exp (η * T x))
    have hstep : ∑ t ∈ s, (g t * w t) * Real.exp (η * t)
        = ∑ t ∈ s,
          ∑ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
            g (T x) * h x * Real.exp (η * T x) := by
      refine Finset.sum_congr rfl ?_
      intro t _
      rw [hw]
      have hterms : ∀ x ∈ (Finset.univ : Finset X).filter (fun x => T x = t),
          g (T x) * h x * Real.exp (η * T x) = (g t * Real.exp (η * t)) * h x := by
        intro x hx
        rw [Finset.mem_filter] at hx
        rw [hx.2]
        ring
      rw [Finset.sum_congr rfl hterms, ← Finset.mul_sum]
      ring
    rw [hstep, hfiber, hvan η]
  -- (2) independencia lineal de exponenciales sobre la imagen de T
  have hprod : ∀ t : ↥s, g (t : ℝ) * w (t : ℝ) = 0 := by
    intro t
    refine exp_linear_independent_fintype (fun t : ↥s => (t : ℝ)) Subtype.val_injective
      (fun t : ↥s => g (t : ℝ) * w (t : ℝ)) ?_ t
    intro η
    exact (Finset.sum_coe_sort s (fun t : ℝ => (g t * w t) * Real.exp (η * t))).trans (hgrp η)
  -- (3) el peso de una fibra no vacía es positivo
  have hwpos : ∀ t, t ∈ s → 0 < w t := by
    intro t ht
    rw [Finset.mem_image] at ht
    obtain ⟨x₀, _, hx₀⟩ := ht
    rw [hw]
    exact Finset.sum_pos (fun x _ => hpos x)
      ⟨x₀, Finset.mem_filter.mpr ⟨Finset.mem_univ x₀, hx₀⟩⟩
  intro t ht
  rcases mul_eq_zero.mp (hprod ⟨t, ht⟩) with h | h
  · exact h
  · exact absurd h (ne_of_gt (hwpos t ht))

end ExpFam
