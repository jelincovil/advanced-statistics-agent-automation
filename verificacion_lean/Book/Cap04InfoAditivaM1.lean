import Mathlib
import Book.Cap04Suficiencia

/-!
# Book.Cap04InfoAditivaM1 — aditividad de la información de Fisher (caso finito iid)

Módulo auxiliar para la claim `prop:ch3-info-aditiva`
(`book: capitulos/cap04_herramientas.typ` — `#thm-env("proposition", name:
[Aditividad de la Información], key: "prop:ch3-info-aditiva")`).

El libro enuncia: si `X₁,…,Xₙ` son iid con información de Fisher `I₁(θ)` por
observación, entonces `Iₙ(θ) = n·I₁(θ)`. Su prueba tiene tres piezas:
(1) el score total es suma de scores individuales (factorización de la
verosimilitud conjunta);
(2) `Iₙ(θ) = Var_θ(Sₙ)`, es decir la información es la varianza del score;
(3) los términos cruzados `E_θ[SᵢSⱼ] = E_θ[Sᵢ]·E_θ[Sⱼ] = 0` para `i ≠ j`
(por independencia) y `E_θ[Sᵢ²] = I₁(θ)`, luego la varianza de la suma es la
suma de las varianzas.

Aquí se formaliza esa cadena en el marco finito del repositorio
(`Book.Cap04Suficiencia.score`/`fisherInfo`), donde la independencia se
realiza —como en el resto del proyecto— como **ley conjunta producto**:
`P_θ(z) = ∏ᵢ p_θ(zᵢ)` sobre `z : ι → X`, con `ι` un tipo de índices finito
arbitrario (`ι = Fin n` da el `n` del libro). La derivada de la ley conjunta
se construye con la regla del producto y se demuestra que es la derivada
(`hasDerivAt_jointLaw`), de modo que la «regularidad» (derivación bajo la
suma/producto finito) es aquí un teorema y no una hipótesis, igual que en
`Book.Cap04Suficiencia.hasDerivAt_mean`.

Fidelidad declarada: espacio muestral `X` finito y densidad estrictamente
positiva (para que el score `∂p/p` y `log p` estén definidos), `n` copias
independientes e idénticamente distribuidas. No se formaliza el caso
continuo ni la noción de independencia de la teoría de la medida (la ley
conjunta producto *es* la independencia en este marco discreto), ni la
existencia de densidades regulares.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

open Finset BigOperators

namespace Book.Cap04InfoAditivaM1

open Book.Cap04Suficiencia

variable {X : Type*} [Fintype X]
variable {p pd : ℝ → X → ℝ}

/-! ### El score como derivada del logaritmo de la densidad -/

/-- `∂_θ log p_θ(x) = S(θ,x)`: el score del libro es la derivada logarítmica
de la densidad. -/
theorem hasDerivAt_log_density {p pd : ℝ → X → ℝ}
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hpos : ∀ θ x, 0 < p θ x) (x : X) (θ : ℝ) :
    HasDerivAt (fun ξ => Real.log (p ξ x)) (score p pd θ x) θ := by
  have h := (hp x θ).log (ne_of_gt (hpos θ x))
  simpa [score] using h

/-- `E_θ[S(θ,·)] = 0`: la media del score se anula (derivando la
normalización `∑_x p_θ(x) = 1`). -/
theorem sum_score_mul (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) :
    ∑ x, score p pd θ x * p θ x = 0 := by
  have h : ∀ x : X, score p pd θ x * p θ x = pd θ x := by
    intro x
    rw [score, div_mul_cancel₀ _ (ne_of_gt (hpos x))]
  rw [Finset.sum_congr rfl (fun x _ => h x)]
  exact sum_pd_eq_zero p pd hp hnorm θ

/-- La información de Fisher es el segundo momento del score:
`I(θ) = E_θ[S²]`. -/
theorem fisherInfo_eq_secondMoment_score (p pd : ℝ → X → ℝ) (θ : ℝ) :
    fisherInfo p pd θ = secondMoment p (score p pd θ) θ := by
  rw [fisherInfo, secondMoment]

/-- La información de Fisher es la **varianza** del score:
`I(θ) = Var_θ(S)`. Es la pieza (2) de la prueba del libro. -/
theorem fisherInfo_eq_variance_score (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) :
    variance p (score p pd θ) θ = fisherInfo p pd θ := by
  have h0 : mean p (score p pd θ) θ = 0 := by
    rw [mean]
    exact sum_score_mul hp θ hpos hnorm
  rw [variance, fisherInfo_eq_secondMoment_score, h0]
  ring

/-! ### Ley conjunta producto de copias independientes -/

section Joint

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Ley conjunta de una familia indexada por `ι` de copias independientes:
`P_θ(z) = ∏ᵢ p_θ(zᵢ)`. En este marco discreto la ley conjunta producto *es*
la independencia (la densidad conjunta factoriza). -/
noncomputable def jointLaw (p : ℝ → X → ℝ) (θ : ℝ) (z : ι → X) : ℝ :=
  ∏ i, p θ (z i)

/-- Derivada de la ley conjunta respecto de `θ`: regla del producto, con un
término por coordenada «derivada» y el resto `p_θ`. -/
noncomputable def jointDeriv (p pd : ℝ → X → ℝ) (θ : ℝ) (z : ι → X) : ℝ :=
  ∑ i, pd θ (z i) * ∏ j ∈ (Finset.univ.erase i), p θ (z j)

/-- La ley conjunta es estrictamente positiva si las densidades lo son. -/
theorem jointLaw_pos (hpos : ∀ θ x, 0 < p θ x) (θ : ℝ) (z : ι → X) :
    0 < jointLaw p θ z :=
  Finset.prod_pos fun i _ => hpos θ (z i)

/-- La derivada de la ley conjunta es exactamente `jointDeriv`: la
«regularidad» (derivar dentro del producto finito) es aquí un teorema. -/
theorem hasDerivAt_jointLaw (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (z : ι → X) :
    HasDerivAt (fun ξ => jointLaw p ξ z) (jointDeriv p pd θ z) θ := by
  have h := HasDerivAt.finsetProd (u := (Finset.univ : Finset ι))
    (f := fun i => fun ξ : ℝ => p ξ (z i)) (f' := fun i => pd θ (z i)) (x := θ)
    (fun i _ => hp (z i) θ)
  have hfun : (∏ i ∈ (Finset.univ : Finset ι), fun ξ : ℝ => p ξ (z i))
      = fun ξ => jointLaw p ξ z := by
    funext ξ
    simp [jointLaw]
  rw [hfun] at h
  have hval : (∑ i ∈ (Finset.univ : Finset ι),
        (∏ j ∈ (Finset.univ.erase i), p θ (z j)) • pd θ (z i)) = jointDeriv p pd θ z := by
    rw [jointDeriv]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [smul_eq_mul, mul_comm]
  rw [hval] at h
  exact h

/-- El score de la ley conjunta es la suma de los scores individuales: pieza
(1) de la prueba del libro (`Sₙ = ∑ᵢ ∂_θ log f(Xᵢ|θ)`). -/
theorem score_jointLaw (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (z : ι → X) :
    score (jointLaw p) (jointDeriv p pd) θ z = ∑ i, score p pd θ (z i) := by
  have hne : ∀ i : ι, (∏ j ∈ (Finset.univ.erase i), p θ (z j)) ≠ 0 :=
    fun i => ne_of_gt (Finset.prod_pos fun j _ => hpos (z j))
  simp only [score, jointDeriv, jointLaw]
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun i _ => ?_
  have hP : (∏ j, p θ (z j)) = p θ (z i) * ∏ j ∈ (Finset.univ.erase i), p θ (z j) :=
    (Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => p θ (z j))
      (Finset.mem_univ i)).symm
  rw [hP]
  exact mul_div_mul_right _ _ (hne i)

/-- Un producto sobre todas las coordenadas se factoriza como producto de
sumas («Fubini» discreto / independencia):

`∑_z ∏ᵢ gᵢ(zᵢ) = ∏ᵢ ∑_x gᵢ(x)`. -/
theorem sum_pi_prod (g : ι → X → ℝ) :
    ∑ z : ι → X, ∏ i, g i (z i) = ∏ i, ∑ x, g i x := by
  have h := Finset.sum_prod_piFinset (Finset.univ : Finset X) g
  simpa using h

/-- Marginal de una coordenada: `∑_z F(zᵢ)·P_θ(z) = ∑_x F(x)·p_θ(x)`. -/
theorem sum_coord (hnorm : ∀ θ, ∑ x, p θ x = 1) (θ : ℝ) (i : ι) (F : X → ℝ) :
    ∑ z : ι → X, F (z i) * jointLaw p θ z = ∑ x, F x * p θ x := by
  set a : ι → X → ℝ := Function.update (fun _ => p θ) i (fun x => F x * p θ x) with ha
  have hprod : ∀ z : ι → X, ∏ j, a j (z j) = F (z i) * jointLaw p θ z := by
    intro z
    have h1 : a i (z i) = F (z i) * p θ (z i) := by simp [ha]
    have h2 : (∏ j ∈ (Finset.univ.erase i), a j (z j))
        = ∏ j ∈ (Finset.univ.erase i), p θ (z j) := by
      refine Finset.prod_congr rfl fun j hj => ?_
      have hji : j ≠ i := (Finset.mem_erase.mp hj).1
      simp [ha, Function.update_of_ne hji]
    have hP : jointLaw p θ z = p θ (z i) * ∏ j ∈ (Finset.univ.erase i), p θ (z j) := by
      rw [jointLaw, ← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => p θ (z j))
        (Finset.mem_univ i)]
    rw [← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => a j (z j))
      (Finset.mem_univ i), h1, h2, hP]
    ring
  have hsum : (∏ j, ∑ x, a j x)
      = (∑ x, F x * p θ x) * ∏ j ∈ (Finset.univ.erase i), (∑ x, p θ x) := by
    rw [← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => ∑ x, a j x)
      (Finset.mem_univ i)]
    have h1 : (∑ x, a i x) = ∑ x, F x * p θ x := by simp [ha]
    have h2 : (∏ j ∈ (Finset.univ.erase i), ∑ x, a j x)
        = ∏ j ∈ (Finset.univ.erase i), (∑ x, p θ x) := by
      refine Finset.prod_congr rfl fun j hj => ?_
      have hji : j ≠ i := (Finset.mem_erase.mp hj).1
      simp [ha, Function.update_of_ne hji]
    rw [h1, h2]
  calc ∑ z : ι → X, F (z i) * jointLaw p θ z
      = ∑ z : ι → X, ∏ j, a j (z j) := Finset.sum_congr rfl fun z _ => (hprod z).symm
    _ = ∏ j, ∑ x, a j x := sum_pi_prod a
    _ = (∑ x, F x * p θ x) * ∏ j ∈ (Finset.univ.erase i), (∑ x, p θ x) := hsum
    _ = (∑ x, F x * p θ x) * 1 := by simp [hnorm θ]
    _ = ∑ x, F x * p θ x := mul_one _

/-- Marginal de dos coordenadas distintas (`i ≠ k`): el producto de las
esperanzas, que es el contenido de la independencia:
`∑_z F(zᵢ)G(z_k)·P_θ(z) = (∑_x F(x)p_θ(x))·(∑_y G(y)p_θ(y))`. -/
theorem sum_coord_pair (hnorm : ∀ θ, ∑ x, p θ x = 1) (θ : ℝ) {i k : ι} (hik : i ≠ k)
    (F G : X → ℝ) :
    ∑ z : ι → X, F (z i) * G (z k) * jointLaw p θ z
      = (∑ x, F x * p θ x) * (∑ y, G y * p θ y) := by
  set a : ι → X → ℝ :=
    Function.update (Function.update (fun _ => p θ) k (fun x => G x * p θ x)) i
      (fun x => F x * p θ x) with ha
  have hk : k ∈ (Finset.univ.erase i : Finset ι) :=
    Finset.mem_erase.mpr ⟨Ne.symm hik, Finset.mem_univ k⟩
  have hprod : ∀ z : ι → X, ∏ j, a j (z j) = F (z i) * G (z k) * jointLaw p θ z := by
    intro z
    have hai : a i (z i) = F (z i) * p θ (z i) := by simp [ha]
    have hak : a k (z k) = G (z k) * p θ (z k) := by
      simp only [ha]
      rw [Function.update_of_ne (Ne.symm hik)]
      simp
    have hmid : (∏ j ∈ (Finset.univ.erase i), a j (z j))
        = (G (z k) * p θ (z k)) * ∏ j ∈ ((Finset.univ.erase i).erase k), p θ (z j) := by
      rw [← Finset.mul_prod_erase ((Finset.univ.erase i) : Finset ι) (fun j => a j (z j)) hk,
        hak]
      congr 1
      refine Finset.prod_congr rfl fun j hj => ?_
      have hji : j ≠ i := (Finset.mem_erase.mp (Finset.mem_erase.mp hj).2).1
      have hjk : j ≠ k := (Finset.mem_erase.mp hj).1
      simp [ha, Function.update_of_ne hji, Function.update_of_ne hjk]
    have hP : jointLaw p θ z
        = p θ (z i) * (p θ (z k) * ∏ j ∈ ((Finset.univ.erase i).erase k), p θ (z j)) := by
      rw [jointLaw,
        ← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => p θ (z j)) (Finset.mem_univ i),
        ← Finset.mul_prod_erase ((Finset.univ.erase i) : Finset ι) (fun j => p θ (z j)) hk]
    rw [← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => a j (z j))
      (Finset.mem_univ i), hai, hmid, hP]
    ring
  have hsum : (∏ j, ∑ x, a j x)
      = (∑ x, F x * p θ x) * (∑ x, G x * p θ x)
        * ∏ j ∈ ((Finset.univ.erase i).erase k), (∑ x, p θ x) := by
    rw [← Finset.mul_prod_erase (Finset.univ : Finset ι) (fun j => ∑ x, a j x)
      (Finset.mem_univ i),
      ← Finset.mul_prod_erase ((Finset.univ.erase i) : Finset ι) (fun j => ∑ x, a j x) hk]
    have hai : (∑ x, a i x) = ∑ x, F x * p θ x := by simp [ha]
    have hak : (∑ x, a k x) = ∑ x, G x * p θ x := by
      simp only [ha]
      rw [Function.update_of_ne (Ne.symm hik)]
      simp
    have htail : (∏ j ∈ ((Finset.univ.erase i).erase k), ∑ x, a j x)
        = ∏ j ∈ ((Finset.univ.erase i).erase k), (∑ x, p θ x) := by
      refine Finset.prod_congr rfl fun j hj => ?_
      have hji : j ≠ i := (Finset.mem_erase.mp (Finset.mem_erase.mp hj).2).1
      have hjk : j ≠ k := (Finset.mem_erase.mp hj).1
      simp [ha, Function.update_of_ne hji, Function.update_of_ne hjk]
    rw [hai, hak, htail]
    ring
  calc ∑ z : ι → X, F (z i) * G (z k) * jointLaw p θ z
      = ∑ z : ι → X, ∏ j, a j (z j) := Finset.sum_congr rfl fun z _ => (hprod z).symm
    _ = ∏ j, ∑ x, a j x := sum_pi_prod a
    _ = (∑ x, F x * p θ x) * (∑ x, G x * p θ x)
          * ∏ j ∈ ((Finset.univ.erase i).erase k), (∑ x, p θ x) := hsum
    _ = (∑ x, F x * p θ x) * (∑ y, G y * p θ y) := by
        simp [hnorm θ]


/-- La log-verosimilitud conjunta es la suma de las log-verosimilitudes
individuales (`log ∏ᵢ p_θ(zᵢ) = ∑ᵢ log p_θ(zᵢ)`), como en el libro. -/
theorem log_jointLaw (ξ : ℝ) (hpos : ∀ x, 0 < p ξ x) (z : ι → X) :
    Real.log (jointLaw p ξ z) = ∑ i, Real.log (p ξ (z i)) := by
  rw [jointLaw, Real.log_prod]
  intro i _
  exact ne_of_gt (hpos (z i))

/-- La derivada de la log-verosimilitud **conjunta** es el score conjunto
(`∂_θ log P_θ(z) = S_n(θ,z)`), que a su vez es la suma de los scores
individuales: la cadena `∂log f` ↔ `score` del libro, ya sobre `P_θ`. -/
theorem hasDerivAt_log_jointLaw (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hpos : ∀ θ x, 0 < p θ x) (θ : ℝ) (z : ι → X) :
    HasDerivAt (fun ξ => Real.log (jointLaw p ξ z))
      (score (jointLaw (ι := ι) p) (jointDeriv (ι := ι) p pd) θ z) θ :=
  hasDerivAt_log_density (p := jointLaw (ι := ι) p) (pd := jointDeriv (ι := ι) p pd)
    (fun z ξ => hasDerivAt_jointLaw (p := p) (pd := pd) hp ξ z)
    (fun ξ z => jointLaw_pos (p := p) hpos ξ z) z θ

/-- La ley conjunta producto está normalizada si las densidades lo están:
`∑_z ∏ᵢ p_θ(zᵢ) = 1` (producto de sumas que valen `1`). -/
theorem jointLaw_sum_eq_one (hnorm : ∀ θ, ∑ x, p θ x = 1) (θ : ℝ) :
    ∑ z : ι → X, jointLaw p θ z = 1 := by
  simp only [jointLaw]
  rw [sum_pi_prod (fun _ => p θ)]
  simp [hnorm θ]

/-- Reordenación `z`, `i`, `k` en una suma triple (para la expansión del
cuadrado del score total). -/
theorem sum_comm_three (f : ι → ι → (ι → X) → ℝ) :
    ∑ z : ι → X, ∑ i, ∑ k, f i k z = ∑ i, ∑ k, ∑ z : ι → X, f i k z := by
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_comm

/-- Términos del score total dos a dos: la diagonal vale `I(θ)` y los cruces
se anulan por independencia,
`∑_z S(zᵢ)S(z_k)·P_θ(z) = δ_{ik}·I(θ)`. -/
theorem sum_score_pair (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) (i k : ι) :
    ∑ z : ι → X, score p pd θ (z i) * score p pd θ (z k) * jointLaw p θ z
      = if i = k then fisherInfo p pd θ else 0 := by
  by_cases h : i = k
  · subst h
    rw [ite_eq_left rfl]
    rw [sum_coord (p := p) hnorm θ i (fun x => score p pd θ x * score p pd θ x)]
    rw [fisherInfo]
    exact Finset.sum_congr rfl fun x _ => by ring
  · rw [ite_eq_right h]
    rw [sum_coord_pair (p := p) hnorm θ h (fun x => score p pd θ x) (fun y => score p pd θ y)]
    rw [sum_score_mul (p := p) (pd := pd) hp θ hpos hnorm, mul_zero]

/-- book: capitulos/cap04_herramientas.typ:1027 (key: prop:ch3-info-aditiva) —
**Aditividad de la información de Fisher** (caso finito iid).

Sea `p_θ` una densidad estrictamente positiva y normalizada sobre un espacio
muestral finito `X`, derivable en `θ` con derivada `∂_θ p_θ`, y sea `ι` un
conjunto finito de índices con `card ι = n`. La ley conjunta de las `n`
copias independientes es `P_θ(z) = ∏ᵢ p_θ(zᵢ)`, con derivada `jointDeriv`
(regla del producto). Entonces

`I_n(θ) = I(P_θ) = card ι · I(θ)`.

Prueba: el score de `P_θ` es `∑ᵢ S(θ,zᵢ)` (`score_jointLaw`), luego
`I_n = E[S_n²] = ∑ᵢ∑_k E[SᵢS_k]`; la diagonal vale `I(θ)`
(`sum_coord`) y cada cruce `(i≠k)` vale `E[Sᵢ]·E[S_k] = 0`
(`sum_coord_pair` y `sum_score_mul`), ambas por factorización de la ley
conjunta, que es la independencia. Además `I(θ) = Var_θ(S)` está probado
(`fisherInfo_eq_variance_score`), de modo que la igualdad `I_n = Var(S_n)`
del libro es también un teorema.

Fidelidad declarada: espacio muestral `X` **finito**, densidades
**estrictamente positivas** (para que `S = ∂p/p` y `log p` existan) y
normalizadas, y la independencia realizada como **ley conjunta producto**
sobre `ι → X` (en este marco discreto la densidad conjunta factorizada *es*
la independencia); `ι = Fin n` recupera el `n` del enunciado
(`fisherInfo_jointLaw_fin`, `fisherInfo_jointLaw_fin_nsmul`). La regularidad
(derivar dentro de la suma finita y del producto finito) es aquí **teorema**
(`hasDerivAt_mean` de `Cap04Suficiencia`, `hasDerivAt_jointLaw`), no
hipótesis. NO se formaliza: el caso de espacio muestral continuo o
numerable-infinito (donde la información es una integral), ni la noción de
independencia de la teoría de la medida, ni la existencia de densidades
regulares. El enunciado del libro es general; esto es su especialización
finita exacta.
Origen: enjambre smwi1z2xl, dirección d1 (aditividad de Fisher iid). -/
theorem fisherInfo_jointLaw (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) :
    fisherInfo (jointLaw (ι := ι) p) (jointDeriv (ι := ι) p pd) θ
      = (Fintype.card ι : ℝ) * fisherInfo p pd θ := by
  have hscore : ∀ z : ι → X,
      score (jointLaw (ι := ι) p) (jointDeriv (ι := ι) p pd) θ z = ∑ i, score p pd θ (z i) :=
    fun z => score_jointLaw (p := p) (pd := pd) θ hpos z
  calc fisherInfo (jointLaw (ι := ι) p) (jointDeriv (ι := ι) p pd) θ
      = ∑ z : ι → X, (score (jointLaw (ι := ι) p) (jointDeriv (ι := ι) p pd) θ z) ^ 2
          * jointLaw p θ z := rfl
    _ = ∑ z : ι → X, (∑ i, score p pd θ (z i)) ^ 2 * jointLaw p θ z := by
        refine Finset.sum_congr rfl fun z _ => ?_
        rw [hscore z]
    _ = ∑ z : ι → X, (∑ i, ∑ k, score p pd θ (z i) * score p pd θ (z k))
          * jointLaw p θ z := by
        refine Finset.sum_congr rfl fun z _ => ?_
        rw [pow_two, Finset.sum_mul_sum]
    _ = ∑ z : ι → X, ∑ i,
          (∑ k, score p pd θ (z i) * score p pd θ (z k)) * jointLaw p θ z := by
        refine Finset.sum_congr rfl fun z _ => ?_
        exact Finset.sum_mul Finset.univ
          (fun i => ∑ k, score p pd θ (z i) * score p pd θ (z k)) (jointLaw p θ z)
    _ = ∑ z : ι → X, ∑ i, ∑ k,
          score p pd θ (z i) * score p pd θ (z k) * jointLaw p θ z := by
        refine Finset.sum_congr rfl fun z _ => Finset.sum_congr rfl fun i _ => ?_
        exact Finset.sum_mul Finset.univ
          (fun k => score p pd θ (z i) * score p pd θ (z k)) (jointLaw p θ z)
    _ = ∑ i, ∑ k, ∑ z : ι → X,
          score p pd θ (z i) * score p pd θ (z k) * jointLaw p θ z :=
        sum_comm_three
          (fun i k z => score p pd θ (z i) * score p pd θ (z k) * jointLaw p θ z)
    _ = ∑ i, ∑ k, (if i = k then fisherInfo p pd θ else 0) :=
        Finset.sum_congr rfl fun i _ =>
          Finset.sum_congr rfl fun k _ => sum_score_pair (p := p) (pd := pd) hp θ hpos hnorm i k
    _ = ∑ _i : ι, fisherInfo p pd θ := by
        refine Finset.sum_congr rfl fun i _ => ?_
        simp
    _ = (Fintype.card ι : ℝ) * fisherInfo p pd θ := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- book: capitulos/cap04_herramientas.typ:1027 (key: prop:ch3-info-aditiva) —
La aditividad en la forma del libro, `Iₙ(θ) = n·I₁(θ)`, para las `n` copias
indexadas por `Fin n` (fidelidad declarada en `fisherInfo_jointLaw`).
Origen: enjambre smwi1z2xl, dirección d1. -/
theorem fisherInfo_jointLaw_fin (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) (n : ℕ) :
    fisherInfo (jointLaw (ι := Fin n) p) (jointDeriv (ι := Fin n) p pd) θ
      = (n : ℝ) * fisherInfo p pd θ := by
  simpa using fisherInfo_jointLaw (ι := Fin n) p pd hp θ hpos hnorm

/-- book: capitulos/cap04_herramientas.typ:1027 (key: prop:ch3-info-aditiva) —
La misma identidad con la notación `n • I₁` del enunciado del libro
(`Iₙ(θ) = n • I₁(θ)`), y con `card (Fin n) = n` en forma de `n` suma de
constantes: es la forma exacta que usaba el target antiguo
`prop_ch3_info_aditiva`, pero ahora con `I₁` siendo una información de
Fisher real, no un real arbitrario.
Origen: enjambre smwi1z2xl, dirección d1. -/
theorem fisherInfo_jointLaw_fin_nsmul (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) (n : ℕ) :
    fisherInfo (jointLaw (ι := Fin n) p) (jointDeriv (ι := Fin n) p pd) θ
      = n • fisherInfo p pd θ := by
  rw [fisherInfo_jointLaw_fin (p := p) (pd := pd) hp θ hpos hnorm n, nsmul_eq_mul]

/-- book: capitulos/cap04_herramientas.typ:1027 (key: prop:ch3-info-aditiva) —
Forma-puente con el target antiguo: la identidad verdadera escrita con el
miembro derecho en la forma `∑ _i ∈ Finset.range n, I₁` que usaba
`prop_ch3_info_aditiva`. El lado izquierdo es la información real del modelo
producto, no un real arbitrario: lo que el target antiguo probaba es
exactamente el miembro derecho de esta igualdad.
Origen: enjambre smwi1z2xl, dirección d1. -/
theorem fisherInfo_jointLaw_fin_range (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (θ : ℝ) (hpos : ∀ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1) (n : ℕ) :
    fisherInfo (jointLaw (ι := Fin n) p) (jointDeriv (ι := Fin n) p pd) θ
      = ∑ _i ∈ Finset.range n, fisherInfo p pd θ := by
  rw [fisherInfo_jointLaw_fin_nsmul (p := p) (pd := pd) hp θ hpos hnorm n,
    Finset.sum_const, Finset.card_range]

/-- Cota de Cramér-Rao para la muestra iid con la aditividad **derivada** (no
supuesta): la información del modelo producto se calcula con
`fisherInfo_jointLaw`, de modo que la cota `(d/dθ Eδ)² / (n·I₁) ≤ Var δ` vale
sin tomar `I_n = n·I₁` como hipótesis.
Origen: enjambre smwi1z2xl, dirección d1. -/
theorem cor_ch3_cr_iid_joint (p pd : ℝ → X → ℝ)
    (hp : ∀ x θ, HasDerivAt (fun ξ => p ξ x) (pd θ x) θ)
    (hpos : ∀ θ x, 0 < p θ x) (hnorm : ∀ θ, ∑ x, p θ x = 1)
    (θ : ℝ) (hI : 0 < fisherInfo p pd θ) (hcard : 0 < Fintype.card ι)
    (δ : (ι → X) → ℝ) :
    (∑ z : ι → X, δ z * jointDeriv p pd θ z) ^ 2
        / ((Fintype.card ι : ℝ) * fisherInfo p pd θ) ≤ variance (jointLaw p) δ θ := by
  have hCR := ch3_cramer_rao (jointLaw p) (jointDeriv p pd)
    (fun z ξ => hasDerivAt_jointLaw (p := p) (pd := pd) hp ξ z)
    (fun ξ z => jointLaw_pos (p := p) hpos ξ z)
    (fun ξ => jointLaw_sum_eq_one (p := p) hnorm ξ) δ θ
  rw [fisherInfo_jointLaw (p := p) (pd := pd) hp θ (fun x => hpos θ x) hnorm] at hCR
  have hcardR : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast hcard
  have hpos' : 0 < (Fintype.card ι : ℝ) * fisherInfo p pd θ := mul_pos hcardR hI
  rw [div_le_iff₀ hpos']
  exact hCR

end Joint

/-! ### Comprobación de no vacuidad: dos observaciones Bernoulli

El teorema anterior no es una identidad aritmética disfrazada: aquí se
instancia en el modelo Bernoulli(θ) sobre `Bool`, se calcula `I₁(θ)` por suma
directa sobre los dos puntos (`1/θ + 1/(1-θ)`) y se aplica la aditividad para
obtener `I₂(θ) = 2·I₁(θ)`. Que la conclusión sea un valor concreto y correcto
(no `0 = 0`) es lo que separa este target de la sombra `∑ I₁ = n • I₁` que
figureaba antes como `prop_ch3_info_aditiva`. -/

section EjemploBernoulli

/-- Densidad Bernoulli(θ) sobre `Bool`: `p_θ(true) = θ`, `p_θ(false) = 1-θ`. -/
noncomputable def bernP : ℝ → Bool → ℝ := fun θ b => if b then θ else 1 - θ

/-- Derivada de la densidad Bernoulli respecto de `θ`. -/
noncomputable def bernPd : ℝ → Bool → ℝ := fun _ b => if b then 1 else -1

/-- La derivada de `bernP` es `bernPd`. -/
theorem bernP_hasDerivAt (b : Bool) (θ : ℝ) :
    HasDerivAt (fun ξ => bernP ξ b) (bernPd θ b) θ := by
  cases b
  · have h : HasDerivAt (fun ξ : ℝ => (1 : ℝ) - ξ) (-1) θ := by
      have h' : HasDerivAt (fun ξ : ℝ => (1 : ℝ) - ξ) (0 - 1) θ :=
        (hasDerivAt_const (c := (1 : ℝ)) θ).sub (hasDerivAt_id θ)
      simpa using h'
    simpa [bernP, bernPd] using h
  · have h : HasDerivAt (fun ξ : ℝ => ξ) 1 θ := hasDerivAt_id θ
    simpa [bernP, bernPd] using h

/-- Positividad de la densidad Bernoulli en `0 < θ < 1`. -/
theorem bernP_pos (θ : ℝ) (h0 : 0 < θ) (h1 : θ < 1) : ∀ b, 0 < bernP θ b := by
  intro b
  cases b
  · simp [bernP]
    linarith
  · simpa [bernP] using h0

/-- Normalización de la densidad Bernoulli: `θ + (1-θ) = 1`. -/
theorem bernP_sum (θ : ℝ) : ∑ b, bernP θ b = 1 := by
  rw [Fintype.sum_bool]
  simp [bernP]

/-- `I₁(θ) = 1/θ + 1/(1-θ)` para el modelo Bernoulli, por suma directa sobre
los dos puntos: `(1/θ)²·θ + (1/(1-θ))²·(1-θ)`. -/
theorem bernP_fisherInfo (θ : ℝ) (h0 : 0 < θ) (h1 : θ < 1) :
    fisherInfo bernP bernPd θ = 1 / θ + 1 / (1 - θ) := by
  rw [fisherInfo, Fintype.sum_bool]
  simp [score, bernP, bernPd]
  field_simp

/-- book: capitulos/cap04_herramientas.typ:1027 (key: prop:ch3-info-aditiva) —
Dos observaciones Bernoulli independientes: `I₂(θ) = 2·I₁(θ)`, con `I₁`
calculado aparte (`bernP_fisherInfo`) y la identidad del libro aplicada como
teorema (`fisherInfo_jointLaw`).
Origen: enjambre smwi1z2xl, dirección d1. -/
theorem bernP_fisherInfo_dos (θ : ℝ) (h0 : 0 < θ) (h1 : θ < 1) :
    fisherInfo (jointLaw (ι := Bool) bernP) (jointDeriv (ι := Bool) bernP bernPd) θ
      = 2 * (1 / θ + 1 / (1 - θ)) := by
  rw [fisherInfo_jointLaw (ι := Bool) bernP bernPd bernP_hasDerivAt θ (bernP_pos θ h0 h1)
    bernP_sum, Fintype.card_bool, bernP_fisherInfo θ h0 h1]
  norm_num

end EjemploBernoulli

end Book.Cap04InfoAditivaM1
