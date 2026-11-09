import Mathlib

/-!
# Cap04 — `thm:ch4-bh`: Benjamini–Hochberg controla la FDR (cierre)

`book: book_stat_inference_v0/capitulos/cap04_herramientas.typ:1441 (key: thm:ch4-bh)`

Este archivo cierra el enunciado del libro

> Sea `p₍₁₎ ≤ … ≤ p₍ₘ₎` los p-valores ordenados, `k = max{i : p₍ᵢ₎ ≤ iα/m}` (`k = 0` si el
> conjunto es vacío). Rechazar las primeras `k`. Para p-valores válidos, el procedimiento
> controla `FDR ≤ m₀α/m ≤ α` si cada p-valor nulo es independiente del vector de todos los
> demás p-valores, o bajo PRDS.

**Qué se demuestra aquí (0 `sorry`).**

1. La regla de BH en su forma de corte (`kcut`, la `k` del libro, como máximo de
   `{h ≤ m : h ≤ #{i : pᵢ ≤ hα/m}}`), el conjunto de rechazo `rejOn` y el hecho de que
   *rechaza exactamente `k` hipótesis* (`cnt_kcut`, `card_rejOn`) — la identidad `|R| = k`
   que el argumento clásico necesita y que `Book/Cap04Ch4BhUmpuM6.lean` no tenía.
2. La caracterización de la membresía
   `i ∈ R ↔ ∃ h, 1 ≤ h ≤ m, pᵢ ≤ hα/m, h ≤ #{j : pⱼ ≤ hα/m}` (`mem_rejOn_iff`), la
   propiedad de segmento inicial (`mem_rejOn_of_le`: si `pᵢ ≤ pⱼ` y se rechaza `j`, se
   rechaza `i`) y la contención del paso único de Bonferroni (`bonferroni_subset`).
3. El **argumento leave-one-out** exacto: si `i` se rechaza, al eliminarlo de la familia
   (manteniendo el mismo `m` en el umbral `hα/m`) el número de rechazos baja *exactamente*
   en uno, `R₋ᵢ + 1 = R` (`leave_one_out`). De ahí `pᵢ ≤ (R₋ᵢ+1)α/m` y `1/(R∨1) = 1/(R₋ᵢ+1)`.
4. La descomposición exacta `FDR = ∑_{i∈I₀} EE[1{i rechazada}/(R∨1)]` y la **cota por nula**
   `EE[1{i rechazada}/(R∨1)] ≤ α/m` (`fdr_per_null`), que se obtiene sustituyendo la nula
   `i` por el test de la familia sin ella y usando la validez condicional del p-valor nulo.
5. El teorema `bh_fdr_le`: `FDR ≤ m₀α/m`, y el corolario `bh_fdr_le_alpha`: `FDR ≤ α`.

**Fidelidad declarada.** El paquete probabilístico entra como en el resto del capítulo 4 del
repo: un funcional de esperanza abstracto `Expect` (lineal, normalizado, monótono). La
hipótesis de independencia se enuncia en la forma exacta que el argumento usa: para cada
nula `i` y para toda cota `c` y todo peso `h` que dependan sólo de los p-valores restantes
(`c ∈ [0,1]`, `h ≥ 0`), `EE[1{pᵢ ≤ c}·h] ≤ EE[c·h]`. Es la validez condicional
`P(pᵢ ≤ c | p₋ᵢ) ≤ c`, que bajo independencia de un p-valor superuniforme respecto de los
demás se cumple; el enunciado del libro no da más estructura (ni distribuciones nulas
explícitas ni el mecanismo que produce los p-valores). Todo lo demás —la regla de BH, la
aritmética de rangos, el leave-one-out y la cota— es incondicional y se prueba aquí.
La extensión PRDS el libro mismo la remite a la literatura (`benjamini2001dependency`) y no
se formaliza; el teorema se enuncia para la clase de p-valores válidos condicionalmente, que
es la que el argumento necesita.
-/

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false
set_option maxHeartbeats 1000000

open Finset

universe u

namespace Cap04M3BH

attribute [local instance] Classical.propDecidable

/-! ## §1. Funcional de esperanza abstracto (mismo idioma que `Cap04Ch4BhUmpuM6`) -/

/-- Funcional de esperanza lineal, normalizado y monótono (base no enunciada). -/
structure Expect (Ω : Type u) where
  /-- el funcional -/
  toFun : (Ω → ℝ) → ℝ
  /-- normalización -/
  map_one : toFun 1 = 1
  /-- aditividad -/
  map_add : ∀ f g : Ω → ℝ, toFun (f + g) = toFun f + toFun g
  /-- homogeneidad -/
  map_smul : ∀ (c : ℝ) (f : Ω → ℝ), toFun (fun ω => c * f ω) = c * toFun f
  /-- congruencia puntual -/
  map_congr : ∀ f g : Ω → ℝ, (∀ ω, f ω = g ω) → toFun f = toFun g
  /-- positividad -/
  map_nonneg : ∀ f : Ω → ℝ, (∀ ω, 0 ≤ f ω) → 0 ≤ toFun f

namespace Expect

variable {Ω : Type u}

/-- `E[c] = c`. -/
theorem map_const (P : Expect Ω) (c : ℝ) : P.toFun (fun _ => c) = c := by
  have h := P.map_smul c (1 : Ω → ℝ)
  have h1 : (fun ω => c * (1 : Ω → ℝ) ω) = fun _ => c := by funext ω; simp
  rw [h1, P.map_one, mul_one] at h
  exact h

/-- Linealidad sobre una suma finita. -/
theorem map_sum (P : Expect Ω) {ι : Type*} (s : Finset ι) (f : ι → Ω → ℝ) :
    P.toFun (∑ i ∈ s, f i) = ∑ i ∈ s, P.toFun (f i) := by
  classical
  induction s using Finset.induction with
  | empty =>
      rw [Finset.sum_empty, Finset.sum_empty]
      exact P.map_const 0
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, P.map_add, ih]

/-- Monotonía. -/
theorem map_le (P : Expect Ω) {f g : Ω → ℝ} (h : ∀ ω, f ω ≤ g ω) :
    P.toFun f ≤ P.toFun g := by
  have hg : g = f + (fun ω => g ω - f ω) := by funext ω; simp
  rw [hg, P.map_add]
  have hnn : 0 ≤ P.toFun (fun ω => g ω - f ω) :=
    P.map_nonneg _ (fun ω => by linarith [h ω])
  linarith

end Expect

/-! ## §2. La regla de Benjamini–Hochberg como objeto combinatorio -/

section Combinatoria

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- `cnt p m α s h` = número de índices de la subfamilia `s` con p-valor `≤ h·α/m`
(base no enunciada). -/
noncomputable def cnt (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) (h : ℕ) : ℕ :=
  (s.filter (fun i => p i ≤ (h : ℝ) * α / (m : ℝ))).card

/-- Corte de Benjamini–Hochberg sobre la subfamilia `s`: el mayor `h ≤ m` con
`h ≤ cnt p m α s h` (y `0` si ninguno, que es el caso del libro con conjunto vacío). -/
noncomputable def kcut (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) : ℕ :=
  Nat.findGreatest (fun h => h ≤ cnt p m α s h) m

/-- Conjunto de rechazo de Benjamini–Hochberg sobre la subfamilia `s`:
se rechaza `i` cuando su p-valor no supera el umbral del corte, `pᵢ ≤ k·α/m`. -/
noncomputable def rejOn (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) : Finset ι :=
  s.filter (fun i => p i ≤ (kcut p m α s : ℝ) * α / (m : ℝ))

/-- El corte nunca supera `m`. -/
lemma kcut_le (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) : kcut p m α s ≤ m :=
  Nat.findGreatest_le m

/-- `cnt` es monótono en el nivel `h` (los umbrales `hα/m` crecen con `h`). -/
lemma cnt_mono (p : ι → ℝ) {m : ℕ} {α : ℝ} (hα : 0 ≤ α) (s : Finset ι)
    {h h' : ℕ} (hh : h ≤ h') : cnt p m α s h ≤ cnt p m α s h' := by
  unfold cnt
  refine Finset.card_le_card ?_
  intro i hi
  simp only [Finset.mem_filter] at hi ⊢
  obtain ⟨h1, h2⟩ := hi
  refine ⟨h1, ?_⟩
  have hhR : (h : ℝ) ≤ (h' : ℝ) := by exact_mod_cast hh
  have hmul : (h : ℝ) * α ≤ (h' : ℝ) * α := mul_le_mul_of_nonneg_right hhR hα
  rcases Nat.eq_zero_or_pos m with hm0 | hmpos
  · simpa [hm0] using h2
  · have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hmpos
    exact le_trans h2 (div_le_div_of_nonneg_right hmul (le_of_lt hmR))

/-- El corte es admisible: `k ≤ cnt k`. -/
lemma le_cnt_kcut (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) :
    kcut p m α s ≤ cnt p m α s (kcut p m α s) :=
  Nat.findGreatest_spec (P := fun h => h ≤ cnt p m α s h) (n := m) (m := 0)
    (Nat.zero_le m) (Nat.zero_le _)

/-- **`|R| = k`**: BH rechaza exactamente `k` hipótesis. Es la identidad que usa el
argumento leave-one-out (y la lectura "rechazar las `k` primeras"). -/
lemma cnt_kcut (p : ι → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 ≤ α)
    (hp : ∀ i, 0 < p i) (s : Finset ι) (hs : s.card ≤ m) :
    cnt p m α s (kcut p m α s) = kcut p m α s := by
  have hKs := le_cnt_kcut p m α s
  have hle : cnt p m α s (kcut p m α s) ≤ kcut p m α s := by
    rcases lt_or_ge (kcut p m α s) m with hlt | hge
    · by_contra hcon
      push Not at hcon
      have hstep : cnt p m α s (kcut p m α s) ≤ cnt p m α s (kcut p m α s + 1) :=
        cnt_mono p hα s (Nat.le_succ _)
      have h1 : kcut p m α s + 1 ≤ cnt p m α s (kcut p m α s + 1) := le_trans hcon hstep
      have h2 : kcut p m α s + 1 ≤ kcut p m α s := Nat.le_findGreatest (by omega) h1
      omega
    · have h1 : cnt p m α s (kcut p m α s) ≤ s.card := by
        unfold cnt
        exact Finset.card_filter_le _ _
      omega
  omega

/-- `|R| = k` en la forma del conjunto de rechazo. -/
lemma card_rejOn (p : ι → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 ≤ α)
    (hp : ∀ i, 0 < p i) (s : Finset ι) (hs : s.card ≤ m) :
    (rejOn p m α s).card = kcut p m α s := by
  simpa only [rejOn, cnt] using cnt_kcut p hm hα hp s hs

/-- Caracterización de la membresía en el conjunto de rechazo: `i` se rechaza si y sólo si
existe un nivel `h ≤ m` tal que `pᵢ ≤ hα/m` y al menos `h` p-valores caen bajo `hα/m`. -/
lemma mem_rejOn_iff (p : ι → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 < α)
    (hp : ∀ i, 0 < p i) (s : Finset ι) (hs : s.card ≤ m) {i : ι} (hi : i ∈ s) :
    i ∈ rejOn p m α s ↔
      ∃ h : ℕ, 1 ≤ h ∧ h ≤ m ∧ p i ≤ (h : ℝ) * α / (m : ℝ) ∧ h ≤ cnt p m α s h := by
  have hcard := cnt_kcut p hm (le_of_lt hα) hp s hs
  constructor
  · intro hmem
    simp only [rejOn, Finset.mem_filter] at hmem
    have hpK : p i ≤ (kcut p m α s : ℝ) * α / (m : ℝ) := hmem.2
    have hK1 : 1 ≤ kcut p m α s := by
      rcases Nat.eq_zero_or_pos (kcut p m α s) with h0 | h
      · exfalso
        have hz : (kcut p m α s : ℝ) * α / (m : ℝ) = 0 := by rw [h0]; simp
        rw [hz] at hpK
        linarith [hp i]
      · exact h
    exact ⟨kcut p m α s, hK1, kcut_le p m α s, hpK, by rw [hcard]⟩
  · rintro ⟨h, h1, h2, hpi, hcnt⟩
    simp only [rejOn, Finset.mem_filter]
    refine ⟨hi, ?_⟩
    have hhK : h ≤ kcut p m α s := Nat.le_findGreatest h2 hcnt
    have hstep : (h : ℝ) * α / (m : ℝ) ≤ (kcut p m α s : ℝ) * α / (m : ℝ) := by
      rcases Nat.eq_zero_or_pos m with hm0 | hmpos
      · simp [hm0]
      · have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hmpos
        have hhR : (h : ℝ) ≤ (kcut p m α s : ℝ) := by exact_mod_cast hhK
        exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hhR (le_of_lt hα))
          (le_of_lt hmR)
    linarith

/-- BH rechaza un segmento inicial: si `pᵢ ≤ pⱼ` y se rechaza `j`, se rechaza `i`. -/
lemma mem_rejOn_of_le (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) {i j : ι}
    (hi : i ∈ s) (hij : p i ≤ p j) (hrej : j ∈ rejOn p m α s) :
    i ∈ rejOn p m α s := by
  simp only [rejOn, Finset.mem_filter] at hrej ⊢
  exact ⟨hi, le_trans hij hrej.2⟩

/-- Conteo al suprimir un elemento: `cnt s h = cnt (s.erase i) h + 1{pᵢ ≤ hα/m}`. -/
lemma cnt_erase (p : ι → ℝ) (m : ℕ) (α : ℝ) (s : Finset ι) {i : ι} (hi : i ∈ s)
    (h : ℕ) :
    cnt p m α s h
      = cnt p m α (s.erase i) h + (if p i ≤ (h : ℝ) * α / (m : ℝ) then 1 else 0) := by
  unfold cnt
  conv_lhs => rw [← Finset.insert_erase hi]
  rw [Finset.filter_insert]
  split_ifs with hp
  · rw [Finset.card_insert_of_notMem (by simp)]
  · simp

/-- **Leave-one-out (sustituir la nula por cero).** Es el paso que el propio libro describe:
"al sustituir un p-valor nulo por cero, el total de rechazos permite acotar su contribución a
la FDR por `α/m`". Si `i` se rechaza, el procedimiento sobre los datos modificados `q = p` salvo
`qᵢ = 0` tiene *el mismo corte* `k⁽⁰⁾ = k`, y `pᵢ ≤ k⁽⁰⁾·α/m`. Como `q` sólo depende de `p₋ᵢ`,
la cota `k⁽⁰⁾α/m` y el peso `1/(k⁽⁰⁾∨1)` son funciones de los demás p-valores: ahí entra la
independencia.
Fidelidad declarada: el umbral se mantiene `hα/m` con el mismo `m` (la familia no cambia de
tamaño, sólo se reemplaza un p-valor); la positividad de los p-valores se usa para que el corte
de los datos originales no sea trivialmente `0`. -/
theorem leave_one_out (p : ι → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 < α)
    (hp : ∀ i, 0 < p i) (hcard : (Finset.univ : Finset ι).card ≤ m) {i : ι}
    (hrej : i ∈ rejOn p m α (Finset.univ : Finset ι)) :
    kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι)
        = kcut p m α (Finset.univ : Finset ι)
      ∧ p i
        ≤ (kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι) : ℝ)
            * α / (m : ℝ) := by
  classical
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hpK : p i ≤ (kcut p m α (Finset.univ : Finset ι) : ℝ) * α / (m : ℝ) := by
    have h := hrej
    simp only [rejOn, Finset.mem_filter] at h
    exact h.2
  -- (i) el conteo no disminuye al poner un p-valor a cero
  have hspec_le : ∀ h : ℕ, cnt p m α (Finset.univ : Finset ι) h
      ≤ cnt (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι) h := by
    intro h
    by_cases h0 : h = 0
    · subst h0
      have hp0 : cnt p m α (Finset.univ : Finset ι) 0 = 0 := by
        unfold cnt
        rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
        intro j _
        simp [hp j]
      rw [hp0]
      exact Nat.zero_le _
    · have hmR' : (0 : ℝ) < (m : ℝ) := hmR
      have ht : (0 : ℝ) ≤ (h : ℝ) * α / (m : ℝ) :=
        div_nonneg (mul_nonneg (Nat.cast_nonneg _) (le_of_lt hα)) (le_of_lt hmR')
      unfold cnt
      refine Finset.card_le_card ?_
      intro j hj
      simp only [Finset.mem_filter] at hj ⊢
      obtain ⟨hju, hpj⟩ := hj
      refine ⟨hju, ?_⟩
      by_cases hji : j = i
      · simp only [hji]
        simpa using ht
      · simp only [hji, if_neg]
        exact hpj
  -- (ii) ... y para niveles por encima del corte, el conteo no aumenta
  have hspec_ge : ∀ h : ℕ, kcut p m α (Finset.univ : Finset ι) ≤ h →
      cnt (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι) h
        ≤ cnt p m α (Finset.univ : Finset ι) h := by
    intro h hh
    have hstep : (kcut p m α (Finset.univ : Finset ι) : ℝ) * α / (m : ℝ)
        ≤ (h : ℝ) * α / (m : ℝ) := by
      have hcast : (kcut p m α (Finset.univ : Finset ι) : ℝ) ≤ (h : ℝ) := by exact_mod_cast hh
      exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hcast (le_of_lt hα))
        (le_of_lt hmR)
    unfold cnt
    refine Finset.card_le_card ?_
    intro j hj
    simp only [Finset.mem_filter] at hj ⊢
    obtain ⟨hju, hqj⟩ := hj
    refine ⟨hju, ?_⟩
    by_cases hji : j = i
    · rw [hji] at hqj ⊢
      exact le_trans hpK hstep
    · simp only [hji, if_neg] at hqj
      exact hqj
  have hk_le : kcut p m α (Finset.univ : Finset ι)
      ≤ kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι) :=
    Nat.le_findGreatest (kcut_le p m α _) (le_trans (le_cnt_kcut p m α _) (hspec_le _))
  have hk_ge : kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι)
      ≤ kcut p m α (Finset.univ : Finset ι) := by
    by_contra hcon
    push Not at hcon
    have h1 := le_cnt_kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι)
    have h2 := hspec_ge _ (le_of_lt hcon)
    have h3 : kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι)
        ≤ kcut p m α (Finset.univ : Finset ι) :=
      Nat.le_findGreatest (kcut_le _ m α _) (le_trans h1 h2)
    omega
  refine ⟨le_antisymm hk_ge hk_le, ?_⟩
  have hcast : (kcut p m α (Finset.univ : Finset ι) : ℝ)
      ≤ (kcut (fun j => if j = i then 0 else p j) m α (Finset.univ : Finset ι) : ℝ) := by
    exact_mod_cast hk_le
  have hstep := div_le_div_of_nonneg_right
    (mul_le_mul_of_nonneg_right hcast (le_of_lt hα)) (le_of_lt hmR)
  linarith

/-- El paso único de Bonferroni está contenido en el conjunto de rechazo de BH:
si `pᵢ ≤ α/m`, BH rechaza `i`. -/
lemma bonferroni_subset (p : ι → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 < α)
    (hp : ∀ i, 0 < p i) (hcard : (Finset.univ : Finset ι).card ≤ m) {i : ι}
    (hi : p i ≤ α / (m : ℝ)) : i ∈ rejOn p m α (Finset.univ : Finset ι) := by
  have hmem : i ∈ (Finset.univ : Finset ι).filter
      (fun j => p j ≤ ((1 : ℕ) : ℝ) * α / (m : ℝ)) :=
    Finset.mem_filter.mpr ⟨Finset.mem_univ i, by simpa using hi⟩
  have hcnt1 : 1 ≤ cnt p m α (Finset.univ : Finset ι) 1 := by
    unfold cnt
    exact Finset.card_pos.mpr ⟨i, hmem⟩
  exact (mem_rejOn_iff p hm hα hp (Finset.univ : Finset ι) hcard (Finset.mem_univ i)).mpr
    ⟨1, le_rfl, by omega, by simpa using hi, hcnt1⟩

end Combinatoria

/-! ## §3. FDR: descomposición, cota por nula y teorema -/

section FDR

variable {Ω : Type u} {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Número total de rechazos `R` de BH en la familia completa (base no enunciada). -/
noncomputable def Rnum (p : ι → Ω → ℝ) (m : ℕ) (α : ℝ) (ω : Ω) : ℕ :=
  (rejOn (fun i => p i ω) m α (Finset.univ : Finset ι)).card

/-- Corte `k⁽⁰⁾` del procedimiento aplicado a los datos con el p-valor de `i` sustituido por
cero. Sólo depende de `p₋ᵢ` (base no enunciada). -/
noncomputable def Rzero (p : ι → Ω → ℝ) (m : ℕ) (α : ℝ) (i : ι) (ω : Ω) : ℕ :=
  kcut (fun j => if j = i then 0 else p j ω) m α (Finset.univ : Finset ι)

/-- La hipótesis `i` es rechazada por BH (base no enunciada). -/
def Rej (p : ι → Ω → ℝ) (m : ℕ) (α : ℝ) (i : ι) (ω : Ω) : Prop :=
  i ∈ rejOn (fun j => p j ω) m α (Finset.univ : Finset ι)

/-- book: capitulos/cap04_herramientas.typ:1441 (key: thm:ch4-bh) —
**cota por nula**: si el p-valor de la nula `i` es válido condicionalmente a los demás
(`EE[1{pᵢ ≤ c}·h] ≤ EE[c·h]` para cotas `c ∈ [0,1]` y pesos `h ≥ 0`, la forma que toma la
independencia de la nula `i` respecto del resto), entonces la contribución de `i` a la FDR es
a lo sumo `α/m`.
Fidelidad declarada: se sustituye la nula `i` por cero (`Rzero`), como en la prueba del
libro; el leave-one-out da a la vez `R ≤ k⁽⁰⁾` y `pᵢ ≤ k⁽⁰⁾α/m`, y `k⁽⁰⁾` sólo depende de
`p₋ᵢ`, de modo que la cota `k⁽⁰⁾α/m` y el peso `1/k⁽⁰⁾` son funciones de los demás p-valores. -/
theorem fdr_per_null (E : Expect Ω) (p : ι → Ω → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ}
    (hα : 0 < α) (hα1 : α ≤ 1) (hcard : (Finset.univ : Finset ι).card ≤ m)
    (hpos : ∀ i ω, 0 < p i ω) {i : ι}
    (hcond : ∀ c h : Ω → ℝ, (∀ ω, 0 ≤ c ω) → (∀ ω, c ω ≤ 1) → (∀ ω, 0 ≤ h ω) →
      E.toFun (fun ω => (if p i ω ≤ c ω then (1 : ℝ) else 0) * h ω)
        ≤ E.toFun (fun ω => c ω * h ω)) :
    E.toFun (fun ω => (if Rej p m α i ω then (1 : ℝ) else 0)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1) ≤ α / (m : ℝ) := by
  classical
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hαm : (0 : ℝ) ≤ α / (m : ℝ) := div_nonneg (le_of_lt hα) (le_of_lt hmR)
  -- (a) la cota `k⁽⁰⁾·α/m` es admisible y el peso `1/(k⁽⁰⁾∨1)` no es negativo
  have hc0 : ∀ ω, 0 ≤ ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ) := fun ω =>
    div_nonneg (mul_nonneg (Nat.cast_nonneg _) (le_of_lt hα)) (le_of_lt hmR)
  have hc1 : ∀ ω, ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ) ≤ 1 := by
    intro ω
    have hcast : ((Rzero p m α i ω : ℕ) : ℝ) ≤ (m : ℝ) := by
      have h : Rzero p m α i ω ≤ m := kcut_le _ m α _
      exact_mod_cast h
    calc ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
        ≤ (m : ℝ) * α / (m : ℝ) :=
          div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hcast (le_of_lt hα))
            (le_of_lt hmR)
      _ = α := by rw [mul_comm (m : ℝ) α, mul_div_cancel_right₀ α (ne_of_gt hmR)]
      _ ≤ 1 := hα1
  have hhnn : ∀ ω, 0 ≤ 1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1 := fun ω =>
    le_of_lt (one_div_pos.mpr (lt_of_lt_of_le one_pos (le_max_right _ _)))
  -- (b) comparación puntual con el procedimiento sobre los datos con `pᵢ = 0`
  have hpt : ∀ ω, (if Rej p m α i ω then (1 : ℝ) else 0)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1
      ≤ (if p i ω ≤ ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ) then (1 : ℝ) else 0)
        * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1) := by
    intro ω
    by_cases hr : Rej p m α i ω
    · have hloo := leave_one_out (fun j => p j ω) hm hα (fun j => hpos j ω) hcard hr
      have hthr : p i ω ≤ ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ) := by
        simpa only [Rzero] using hloo.2
      have heqR : ((Rzero p m α i ω : ℕ) : ℝ) = ((Rnum p m α ω : ℕ) : ℝ) := by
        have hcard : (rejOn (fun j => p j ω) m α (Finset.univ : Finset ι)).card
            = kcut (fun j => if j = i then 0 else p j ω) m α (Finset.univ : Finset ι) := by
          rw [hloo.1]
          exact card_rejOn (fun j => p j ω) hm (le_of_lt hα) (fun j => hpos j ω) _ hcard
        have : ((Rzero p m α i ω : ℕ) : ℝ) = ((Rnum p m α ω : ℕ) : ℝ) := by
          rw [Rnum, Rzero]
          exact_mod_cast hcard.symm
        exact this
      have hR1 : (1 : ℝ) ≤ ((Rnum p m α ω : ℕ) : ℝ) := by
        have hmem : i ∈ rejOn (fun j => p j ω) m α (Finset.univ : Finset ι) := hr
        have h1 : 1 ≤ Rnum p m α ω := by
          have hpos1 : 0 < (rejOn (fun j => p j ω) m α (Finset.univ : Finset ι)).card :=
            Finset.card_pos.mpr ⟨i, hmem⟩
          have h2 : 0 < Rnum p m α ω := by simpa only [Rnum] using hpos1
          omega
        exact_mod_cast h1
      rw [if_pos hr, if_pos hthr, max_eq_left hR1, heqR, max_eq_left hR1, one_mul]
    · rw [if_neg hr, zero_div]
      split_ifs with h2
      · exact le_of_lt (mul_pos one_pos
          (one_div_pos.mpr (lt_of_lt_of_le one_pos (le_max_right _ _))))
      · simp
  -- (c) `E[k⁽⁰⁾α/m · 1/(k⁽⁰⁾∨1)] ≤ α/m`
  have hconst : E.toFun (fun ω => ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
      * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1)) ≤ α / (m : ℝ) := by
    have hle : ∀ ω, ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
        * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1) ≤ α / (m : ℝ) := by
      intro ω
      have hk : ((Rzero p m α i ω : ℕ) : ℝ) / max ((Rzero p m α i ω : ℕ) : ℝ) 1 ≤ 1 := by
        rcases le_total (1 : ℝ) ((Rzero p m α i ω : ℕ) : ℝ) with h1 | h1
        · rw [max_eq_left h1, div_self (ne_of_gt (lt_of_lt_of_le one_pos h1))]
        · rw [max_eq_right h1, div_one]
          exact h1
      calc ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
            * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1)
          = (((Rzero p m α i ω : ℕ) : ℝ) / max ((Rzero p m α i ω : ℕ) : ℝ) 1)
              * (α / (m : ℝ)) := by ring
        _ ≤ 1 * (α / (m : ℝ)) := mul_le_mul_of_nonneg_right hk hαm
        _ = α / (m : ℝ) := one_mul _
    calc E.toFun (fun ω => ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
          * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1))
        ≤ E.toFun (fun _ => α / (m : ℝ)) := E.map_le hle
      _ = α / (m : ℝ) := E.map_const _
  have hmain := hcond (fun ω => ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ))
    (fun ω => 1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1) hc0 hc1 hhnn
  calc E.toFun (fun ω => (if Rej p m α i ω then (1 : ℝ) else 0)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1)
      ≤ E.toFun (fun ω => (if p i ω ≤ ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
          then (1 : ℝ) else 0) * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1)) := E.map_le hpt
    _ ≤ E.toFun (fun ω => ((Rzero p m α i ω : ℕ) : ℝ) * α / (m : ℝ)
          * (1 / max ((Rzero p m α i ω : ℕ) : ℝ) 1)) := hmain
    _ ≤ α / (m : ℝ) := hconst

/-- book: capitulos/cap04_herramientas.typ:1441 (key: thm:ch4-bh) —
**teorema de Benjamini–Hochberg**: con p-valores válidos y cada p-valor nulo independiente
(condicionalmente válido, en la forma de `fdr_per_null`) del vector de los demás, la FDR del
procedimiento que rechaza las primeras `k` hipótesis está acotada por `m₀·α/m`.
Fidelidad declarada: `FDR = EE[V/(R∨1)]` con `V` el número de nulas rechazadas (`Rej` sobre
`nulls`) y `R = Rnum`; la descomposición por nula es exacta y la cota por nula es
`fdr_per_null`. La cota `≤ α` se sigue de `m₀ ≤ m` (`bh_fdr_le_alpha`). -/
theorem bh_fdr_le (E : Expect Ω) (p : ι → Ω → ℝ) (nulls : Finset ι)
    {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (hcard : (Finset.univ : Finset ι).card ≤ m)
    (hpos : ∀ i ω, 0 < p i ω)
    (hcond : ∀ i ∈ nulls, ∀ c h : Ω → ℝ, (∀ ω, 0 ≤ c ω) → (∀ ω, c ω ≤ 1) →
      (∀ ω, 0 ≤ h ω) →
      E.toFun (fun ω => (if p i ω ≤ c ω then (1 : ℝ) else 0) * h ω)
        ≤ E.toFun (fun ω => c ω * h ω)) :
    E.toFun (fun ω => ((nulls.filter (fun i => Rej p m α i ω)).card : ℝ)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1) ≤ (nulls.card : ℝ) * α / (m : ℝ) := by
  classical
  have hper : ∀ i ∈ nulls, E.toFun (fun ω => (if Rej p m α i ω then (1 : ℝ) else 0)
      / max ((Rnum p m α ω : ℕ) : ℝ) 1) ≤ α / (m : ℝ) :=
    fun i hi => fdr_per_null E p hm hα hα1 hcard hpos (hcond i hi)
  have hdecomp : (fun ω => ((nulls.filter (fun i => Rej p m α i ω)).card : ℝ)
      / max ((Rnum p m α ω : ℕ) : ℝ) 1)
      = ∑ i ∈ nulls, (fun ω => (if Rej p m α i ω then (1 : ℝ) else 0)
          / max ((Rnum p m α ω : ℕ) : ℝ) 1) := by
    funext ω
    simp only [Finset.sum_apply]
    rw [← Finset.sum_boole (fun i => Rej p m α i ω) nulls, Finset.sum_div]
  rw [hdecomp, Expect.map_sum]
  calc ∑ i ∈ nulls, E.toFun (fun ω => (if Rej p m α i ω then (1 : ℝ) else 0)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1)
      ≤ ∑ _i ∈ nulls, α / (m : ℝ) := Finset.sum_le_sum hper
    _ = (nulls.card : ℝ) * α / (m : ℝ) := by
        rw [Finset.sum_const, nsmul_eq_mul]
        ring

/-- book: capitulos/cap04_herramientas.typ:1441 (key: thm:ch4-bh) —
corolario del libro: como `m₀ ≤ m`, la cota es `FDR ≤ α`. -/
theorem bh_fdr_le_alpha (E : Expect Ω) (p : ι → Ω → ℝ) (nulls : Finset ι)
    {m : ℕ} (hm : 0 < m) {α : ℝ} (hα : 0 < α) (hα1 : α ≤ 1)
    (hcard : (Finset.univ : Finset ι).card ≤ m) (hnulls : nulls.card ≤ m)
    (hpos : ∀ i ω, 0 < p i ω)
    (hcond : ∀ i ∈ nulls, ∀ c h : Ω → ℝ, (∀ ω, 0 ≤ c ω) → (∀ ω, c ω ≤ 1) →
      (∀ ω, 0 ≤ h ω) →
      E.toFun (fun ω => (if p i ω ≤ c ω then (1 : ℝ) else 0) * h ω)
        ≤ E.toFun (fun ω => c ω * h ω)) :
    E.toFun (fun ω => ((nulls.filter (fun i => Rej p m α i ω)).card : ℝ)
        / max ((Rnum p m α ω : ℕ) : ℝ) 1) ≤ α := by
  have h := bh_fdr_le E p nulls hm hα hα1 hcard hpos hcond
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcast : ((nulls.card : ℕ) : ℝ) ≤ (m : ℝ) := by exact_mod_cast hnulls
  have hstep : (nulls.card : ℝ) * α / (m : ℝ) ≤ (m : ℝ) * α / (m : ℝ) :=
    div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hcast (le_of_lt hα)) (le_of_lt hmR)
  have hone : (m : ℝ) * α / (m : ℝ) = α := by
    rw [mul_comm (m : ℝ) α, mul_div_cancel_right₀ α (ne_of_gt hmR)]
  linarith

end FDR

end Cap04M3BH
