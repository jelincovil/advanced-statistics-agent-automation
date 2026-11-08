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

end ExpFam
