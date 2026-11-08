import Mathlib

/-!
# Cap04 — lote m16 (enjambre smw82qi6q)

Formalizaciones nuevas para claves pendientes de
`capitulos/cap04_herramientas.typ`, en el idioma que ya usa
`Book/Cap04Herramientas.lean`: espacio muestral finito (`Fintype`),
densidades no negativas y, cuando hace falta una probabilidad, una
función abstracta `P : Set Ω → ℝ` con la desigualdad de Boole /
complementación y la independencia tomadas como hipótesis explícitas
(como en `thm:ch4-bonferroni`).

Claves cubiertas: `thm:ch4-neyman-pearson`, `prop:ch4-multiplicidad`,
`thm:ch4-holm`, `thm:ch4-mlr`.

Fidelidad declarada: todo es la versión finita/discreta. En el lema de
Neyman–Pearson la aleatorización se trata explícitamente con el valor
`γ ∈ [0,1]` sobre la frontera del cociente de verosimilitudes; en
`prop:ch4-multiplicidad` la independencia entra como hipótesis de
factorización sobre la familia de complementos; en `thm:ch4-holm` los
p-valores se dan ya ordenados (`p : Fin m → ℝ` monótona) y la
comparación "contiene a Bonferroni" es la parte determinista, mientras
que el control de FWER usa Boole sobre el conjunto de nulas verdaderas.
-/

open Finset BigOperators
open scoped Classical

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

namespace Cap04M16

/-! ## thm:ch4-neyman-pearson — óptimo del contraste de razón de verosimilitudes -/

section NeymanPearson

variable {X : Type*} [Fintype X]

/-- Contraste de razón de verosimilitudes con umbral `c` y aleatorización
`γ` en la frontera (base no enunciada en el libro). -/
noncomputable def lrTest (p₀ p₁ : X → ℝ) (c γ : ℝ) : X → ℝ :=
  fun x => if c * p₀ x < p₁ x then 1 else if p₁ x = c * p₀ x then γ else 0

/-- El contraste de razón de verosimilitudes está en `[0,1]`. -/
theorem lrTest_mem {p₀ p₁ : X → ℝ} {c γ : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (x : X) :
    0 ≤ lrTest p₀ p₁ c γ x ∧ lrTest p₀ p₁ c γ x ≤ 1 := by
  unfold lrTest
  split_ifs with h1 h2
  · exact ⟨zero_le_one, le_refl 1⟩
  · exact ⟨hγ0, hγ1⟩
  · exact ⟨le_rfl, zero_le_one⟩

/-- Dominación puntual de cualquier contraste por el de razón de
verosimilitudes: `(φ* − φ)·(p₁ − c·p₀) ≥ 0` cuando `φ*` es el contraste
de razón de verosimilitudes y `0 ≤ φ ≤ 1`. Es el corazón del lema. -/
theorem lrTest_domination {p₀ p₁ : X → ℝ} {c γ : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hc : 0 ≤ c)
    (φ : X → ℝ) (hφ0 : ∀ x, 0 ≤ φ x) (hφ1 : ∀ x, φ x ≤ 1) (x : X) :
    0 ≤ (lrTest p₀ p₁ c γ x - φ x) * (p₁ x - c * p₀ x) := by
  unfold lrTest
  split_ifs with h1 h2
  · have h1' : 0 < p₁ x - c * p₀ x := by linarith
    have : 0 ≤ 1 - φ x := by linarith [hφ1 x]
    nlinarith
  · have hzero : p₁ x - c * p₀ x = 0 := by rw [h2, sub_self]
    rw [hzero, mul_zero]
  · have h1' : p₁ x - c * p₀ x < 0 := by
      have : p₁ x < c * p₀ x := lt_of_le_of_ne (not_lt.mp h1) h2
      linarith
    have : 0 - φ x ≤ 0 := by linarith [hφ0 x]
    nlinarith

/-- book: capitulos/cap04_herramientas.typ:1248 (key: thm:ch4-neyman-pearson) —
**Lema de Neyman–Pearson** (versión finita, niveles explícitos): si el
contraste de razón de verosimilitudes `φ*` con umbral `c ≥ 0` y
aleatorización `γ ∈ [0,1]` cumple `P₀(φ*) ≥ α`, entonces cualquier
contraste `φ` con `0 ≤ φ ≤ 1` y `P₀(φ) ≤ α` tiene potencia a lo sumo la
de `φ*`: `P₁(φ) ≤ P₁(φ*)`.

Prueba: la desigualdad puntual `(φ*(x) − φ(x))·(p₁(x) − c·p₀(x)) ≥ 0`
(dominación de `lrTest_domination`) sumada da
`P₁(φ*) − P₁(φ) ≥ c·(P₀(φ*) − P₀(φ)) ≥ 0`.

Fidelidad declarada: espacio muestral finito; densidades `p₀ p₁`
arbitrarias no negativas sobre `X` (`∑ p₀ = ∑ p₁ = 1` no interviene);
`P₀(ψ) := ∑_x p₀(x)·ψ(x)` es la probabilidad de rechazo del contraste
`ψ`. Que exista `γ` con `P₀(φ*) = α` exactamente es el paso de
aleatorización, que aquí queda como hipótesis `α ≤ P₀(φ*)` (es el
supuesto de que la aleatorización alcanzó el nivel); el enunciado del
libro para tests de nivel exacto `α` se recupera tomando `P₀(φ*) = α`.
Origen: enjambre smw82qi6q / m16 (nuevo; formalización de pendiente). -/
theorem ch4_neyman_pearson
    (p₀ p₁ : X → ℝ) (c γ α : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hc : 0 ≤ c)
    (φ : X → ℝ) (hφ0 : ∀ x, 0 ≤ φ x) (hφ1 : ∀ x, φ x ≤ 1)
    (hlevel : ∑ x, p₀ x * φ x ≤ α)
    (hlevelStar : α ≤ ∑ x, p₀ x * lrTest p₀ p₁ c γ x) :
    ∑ x, p₁ x * φ x ≤ ∑ x, p₁ x * lrTest p₀ p₁ c γ x := by
  set A : ℝ := ∑ x, lrTest p₀ p₁ c γ x * p₀ x with hA
  set B : ℝ := ∑ x, φ x * p₀ x with hB
  set C : ℝ := ∑ x, p₁ x * lrTest p₀ p₁ c γ x with hC
  set D : ℝ := ∑ x, p₁ x * φ x with hD
  have hBA : B ≤ A := by
    have h1 : ∑ x, p₀ x * φ x = B :=
      Finset.sum_congr rfl fun x _ => by ring
    have h2 : ∑ x, p₀ x * lrTest p₀ p₁ c γ x = A :=
      Finset.sum_congr rfl fun x _ => by ring
    rw [h1] at hlevel
    rw [h2] at hlevelStar
    linarith
  have hnn : 0 ≤ ∑ x, (lrTest p₀ p₁ c γ x - φ x) * (p₁ x - c * p₀ x) :=
    Finset.sum_nonneg fun x _ => lrTest_domination hγ0 hγ1 hc φ hφ0 hφ1 x
  have hdecomp : ∑ x, (lrTest p₀ p₁ c γ x - φ x) * (p₁ x - c * p₀ x)
      = (C - c * A) - (D - c * B) := by
    have hterm : ∀ x : X, (lrTest p₀ p₁ c γ x - φ x) * (p₁ x - c * p₀ x)
        = (p₁ x * lrTest p₀ p₁ c γ x - c * (lrTest p₀ p₁ c γ x * p₀ x))
          - (p₁ x * φ x - c * (φ x * p₀ x)) := fun x => by ring
    rw [Finset.sum_congr rfl fun x _ => hterm x,
      Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, hA, hB, hC, hD]
  have hprod : c * (B - A) ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos hc (by linarith)
  linarith [hdecomp ▸ hnn]

end NeymanPearson

/-! ## prop:ch4-multiplicidad — FWER de `m` tests independientes -/

/-- book: capitulos/cap04_herramientas.typ:1385 (key: prop:ch4-multiplicidad) —
**Problema de multiplicidad**: con `m` tests independientes de tamaño
exacto `α`, si todas las nulas son verdaderas,
`FWER = 1 − (1−α)^m`; en particular `FWER ≤ m·α` (la aproximación
`≈ mα` del libro), con igualdad sólo al primer orden en `α`.

Prueba: la FWER es `P(⋃_i A_i)` con `A_i` el suceso "falso positivo del
test `i`"; por complementación y la hipótesis de factorización sobre los
complementos, `P(⋃ A_i) = 1 − ∏_i P(A_iᶜ) = 1 − (1−α)^m`. La cota
`1 − (1−α)^m ≤ mα` es la suma geométrica
`1 − (1−α)^m = α·∑_{i<m}(1−α)^i ≤ α·m` para `α ∈ [0,1]`.

Fidelidad declarada: la probabilidad es una función `P : Set Ω → ℝ` con
complementación e independencia (factorización sobre productos finitos
de complementos) como hipótesis explícitas, exactamente como en
`thm:ch4-bonferroni`; `Ω` arbitrario, la finitud sólo se usa para que
`(A i)` esté indexada por `Fin m`. El "tamaño exacto α" es
`∀ i, P (A i) = α`.
Origen: enjambre smw82qi6q / m16 (nuevo; formalización de pendiente). -/
theorem ch4_multiplicidad {Ω : Type*} (P : Set Ω → ℝ) (m : ℕ) (α : ℝ)
    (A : Fin m → Set Ω)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hα : ∀ i, P (A i) = α)
    (hPcompl : ∀ E : Set Ω, P Eᶜ = 1 - P E)
    (hPindep : ∀ I : Finset (Fin m), P (⋂ i ∈ I, (A i)ᶜ) = ∏ i ∈ I, P ((A i)ᶜ)) :
    P (⋃ i, A i) = 1 - (1 - α) ^ m ∧ 1 - (1 - α) ^ m ≤ (m : ℝ) * α := by
  have hcompl : (⋂ i, (A i)ᶜ)ᶜ = ⋃ i, A i := by
    simp [Set.compl_iInter]
  have hprod : P (⋂ i, (A i)ᶜ) = (1 - α) ^ m := by
    have h1 : (⋂ i, (A i)ᶜ) = (⋂ i ∈ (Finset.univ : Finset (Fin m)), (A i)ᶜ) := by
      simp
    rw [h1, hPindep]
    have h2 : ∀ i, P ((A i)ᶜ) = 1 - α := fun i => by rw [hPcompl, hα i]
    rw [Finset.prod_congr rfl fun i _ => h2 i, Finset.prod_const, Finset.card_univ,
      Fintype.card_fin]
  have hfwer : P (⋃ i, A i) = 1 - (1 - α) ^ m := by
    rw [← hcompl, hPcompl, hprod]
  refine ⟨hfwer, ?_⟩
  -- `1 − (1−α)^m = α·∑_{i<m}(1−α)^i ≤ α·m`
  have hgeom : (1 - α) ^ m = 1 - α * ∑ i ∈ Finset.range m, (1 - α) ^ i := by
    have h := geom_sum_mul (1 - α) m
    have : (∑ i ∈ Finset.range m, (1 - α) ^ i) * ((1 - α) - 1)
        = ((1 - α) ^ m - 1) := h
    nlinarith
  have hterm : ∀ i ∈ Finset.range m, (1 - α) ^ i ≤ 1 := by
    intro i _
    have hb : (0 : ℝ) ≤ 1 - α := by linarith
    calc (1 - α) ^ i ≤ 1 ^ i := pow_le_pow_left₀ hb (by linarith) i
      _ = 1 := one_pow i
  have hsum : ∑ i ∈ Finset.range m, (1 - α) ^ i ≤ (m : ℝ) := by
    calc ∑ i ∈ Finset.range m, (1 - α) ^ i ≤ ∑ _i ∈ Finset.range m, (1 : ℝ) :=
          Finset.sum_le_sum hterm
      _ = (m : ℝ) := by rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
  nlinarith [mul_le_mul_of_nonneg_left hsum hα0]

/-! ## thm:ch4-holm — procedimiento de Holm: contención de Bonferroni y FWER -/

section Holm

/-- Umbral de Holm para el p-valor de rango `i` (0-indexado, de modo que
`i` es el rango `i+1` en la notación 1-indexada del libro): `α/(m−i)`. -/
noncomputable def holmThr (m : ℕ) (α : ℝ) (i : Fin m) : ℝ :=
  α / ((m : ℝ) - (i : ℝ))

/-- Criterio de rechazo de Holm (0-indexado): se rechaza el rango `i` si
*todos* los rangos `j ≤ i` están por debajo de su umbral. Equivale al
enunciado del libro `k = min{i : p_(i) > α/(m-i+1)}`, rechazar
`p_(1),…,p_(k-1)`: el rechazo es un segmento inicial, y `k` es el primer
índice que falla (o `m` si ninguno falla). -/
def holmRej (m : ℕ) (α : ℝ) (p : Fin m → ℝ) (i : Fin m) : Prop :=
  ∀ j : Fin m, j ≤ i → p j ≤ holmThr m α j

/-- El conjunto de rechazo de Holm es un segmento inicial. -/
theorem holmRej_mono {m : ℕ} {α : ℝ} {p : Fin m → ℝ} {i j : Fin m}
    (hi : holmRej m α p i) (hj : j ≤ i) : holmRej m α p j :=
  fun _ hl => hi _ (le_trans hl hj)

/-- **Contención de Bonferroni**: si el p-valor de rango `i` está por
debajo de `α/m`, Holm rechaza `i` (y por tanto todos los rangos
`j ≤ i`). Prueba: `p j ≤ p i ≤ α/m ≤ α/(m−j)` porque `m−j ≤ m` y
`α ≥ 0`. -/
theorem holm_contains_bonferroni {m : ℕ} (hm : 0 < m) {α : ℝ} (hα0 : 0 ≤ α)
    {p : Fin m → ℝ} (hmono : Monotone p) {i : Fin m}
    (hi : p i ≤ α / (m : ℝ)) : holmRej m α p i := by
  intro j hj
  have hpj : p j ≤ p i := hmono hj
  have hjlt : (j : ℝ) < (m : ℝ) := by exact_mod_cast j.isLt
  have hstep : α / (m : ℝ) ≤ α / ((m : ℝ) - (j : ℝ)) := by
    gcongr
    linarith
  calc p j ≤ p i := hpj
    _ ≤ α / (m : ℝ) := hi
    _ ≤ α / ((m : ℝ) - (j : ℝ)) := hstep

/-- book: capitulos/cap04_herramientas.typ:1431 (key: thm:ch4-holm) —
**Procedimiento de Holm**: controla la FWER bajo dependencia arbitraria
y su conjunto de rechazos contiene al de Bonferroni.

Formalización (dos partes, ambas en el mismo teorema):
1. *Contención* (`holm_contains_bonferroni`): con p-valores ordenados
   (`Monotone p`) y `α ≥ 0`, `p i ≤ α/m` implica que Holm rechaza `i`.
2. *Control de FWER*: para p-valores válidos (`P{p_i ≤ t} ≤ t` para cada
   nula verdadera, con `m₀ = |I₀|` nulas verdaderas) y `I₀` no vacío,
   `P(∃ i ∈ I₀ rechazada) ≤ α`. Prueba: si `i*` es el **menor** índice
   verdadero rechazado, todos los `j < i*` son rechazados y ninguno es
   nula verdadera (minimalidad), luego `i* ≤ m − m₀` por conteo
   (`{j < i*} ⊆ univ \ I₀`), de donde
   `p_{i*} ≤ α/(m−i*) ≤ α/m₀`; el suceso "alguna nula rechazada" queda
   contenido en `⋃_{i∈I₀}{p_i ≤ α/m₀}` y Boole da
   `P ≤ m₀·α/m₀ = α`.

Fidelidad declarada: versión finita con `m` tests y p-valores aleatorios
`p : Ω → Fin m → ℝ` ya ordenados ω a ω (`∀ ω, Monotone (p ω)`); `P` es
una probabilidad abstracta con monotonía y desigualdad de Boole como
hipótesis explícitas (mismo idioma que `thm:ch4-bonferroni`); "p-valores
válidos" entra como `P{p_i ≤ t} ≤ t` en el umbral `t = α/m₀` que usa la
prueba, que es exactamente lo que necesita el argumento. La parte 1 no
usa probabilidad.
Origen: enjambre smw82qi6q / m16 (nuevo; formalización de pendiente). -/
theorem ch4_holm {Ω : Type*} (P : Set Ω → ℝ) {m : ℕ} (hm : 0 < m) {α : ℝ}
    (hα0 : 0 ≤ α) (p : Ω → Fin m → ℝ) (hmono : ∀ ω, Monotone (p ω))
    (I₀ : Finset (Fin m)) (hm₀ : 0 < I₀.card)
    (hmonoP : ∀ E F : Set Ω, E ⊆ F → P E ≤ P F)
    (hsubadd : ∀ (F : Finset (Fin m)) (G : Fin m → Set Ω),
        P (⋃ i ∈ F, G i) ≤ ∑ i ∈ F, P (G i))
    (hvalid : ∀ i ∈ I₀, P {ω | p ω i ≤ α / (I₀.card : ℝ)} ≤ α / (I₀.card : ℝ)) :
    P {ω | ∃ i ∈ I₀, holmRej m α (p ω) i} ≤ α := by
  have hm₀pos : (0 : ℝ) < (I₀.card : ℝ) := by exact_mod_cast hm₀
  have hcardle : I₀.card ≤ m := by
    simpa using Finset.card_le_univ I₀
  -- inclusión: alguna nula rechazada ⇒ algún p-valor nulo ≤ α/m₀
  have hincl : {ω | ∃ i ∈ I₀, holmRej m α (p ω) i}
      ⊆ ⋃ i ∈ I₀, {ω | p ω i ≤ α / (I₀.card : ℝ)} := by
    intro ω hω
    obtain ⟨i, hiI, hirej⟩ := hω
    set S : Finset (Fin m) := I₀.filter (fun i => holmRej m α (p ω) i) with hS
    have hSne : S.Nonempty := ⟨i, by rw [hS]; exact Finset.mem_filter.mpr ⟨hiI, hirej⟩⟩
    set i₀ : Fin m := S.min' hSne with hi₀
    have hi₀S : i₀ ∈ S := Finset.min'_mem S hSne
    have hi₀I : i₀ ∈ I₀ := (Finset.mem_filter.mp (by rw [← hS]; exact hi₀S)).1
    have hi₀rej : holmRej m α (p ω) i₀ :=
      (Finset.mem_filter.mp (by rw [← hS]; exact hi₀S)).2
    have hbelow : ∀ j : Fin m, j < i₀ → holmRej m α (p ω) j :=
      fun j hj => holmRej_mono hi₀rej (le_of_lt hj)
    have hnotI : ∀ j : Fin m, j < i₀ → j ∉ I₀ := by
      intro j hj hjI
      have hmem : j ∈ S := by
        rw [hS]; exact Finset.mem_filter.mpr ⟨hjI, hbelow j hj⟩
      exact absurd (Finset.min'_le S j hmem) (not_le.mpr hj)
    -- conteo: {j < i₀} ⊆ univ \ I₀
    have hsub : (Finset.univ.filter (fun j : Fin m => j < i₀)) ⊆ Finset.univ \ I₀ := by
      intro j hj
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj
      exact Finset.mem_sdiff.mpr ⟨Finset.mem_univ j, hnotI j hj⟩
    have hcard1 : (Finset.univ.filter (fun j : Fin m => j < i₀)).card = (i₀ : ℕ) := by
      rw [← Finset.card_range (i₀ : ℕ)]
      refine Finset.card_bij (fun (j : Fin m) _ => (j : ℕ)) ?_ ?_ ?_
      · intro j hj
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hj
        simpa using hj
      · intro j1 _ j2 _ heq
        exact Fin.ext heq
      · intro b hb
        simp only [Finset.mem_range] at hb
        refine ⟨⟨b, by omega⟩, ?_, rfl⟩
        simp only [Finset.mem_filter, Finset.mem_univ, true_and, Fin.lt_def]
        exact hb
    have hcard2 : (Finset.univ \ I₀).card = m - I₀.card := by
      have hdisj : Disjoint (Finset.univ \ I₀) I₀ := Finset.disjoint_sdiff.symm
      have hcover : (Finset.univ \ I₀) ∪ I₀ = (Finset.univ : Finset (Fin m)) :=
        Finset.sdiff_union_of_subset (Finset.subset_univ I₀)
      have hcard := Finset.card_union_of_disjoint hdisj
      rw [hcover, Finset.card_univ, Fintype.card_fin] at hcard
      omega
    have hcount : (i₀ : ℕ) ≤ m - I₀.card := by
      rw [← hcard1, ← hcard2]
      exact Finset.card_le_card hsub
    -- el umbral de Holm en i₀ queda por debajo de α/m₀
    have hden : (I₀.card : ℝ) ≤ (m : ℝ) - (i₀ : ℝ) := by
      have h1 : (i₀ : ℕ) + I₀.card ≤ m := by omega
      have h2 : ((i₀ : ℕ) : ℝ) + (I₀.card : ℝ) ≤ (m : ℝ) := by exact_mod_cast h1
      linarith
    have hr : p ω i₀ ≤ holmThr m α i₀ := hi₀rej i₀ le_rfl
    have hthr : holmThr m α i₀ ≤ α / (I₀.card : ℝ) := by
      unfold holmThr
      exact div_le_div_of_nonneg_left hα0 hm₀pos hden
    refine Set.mem_iUnion.mpr ⟨i₀, ?_⟩
    exact Set.mem_iUnion.mpr ⟨hi₀I, le_trans hr hthr⟩
  -- Boole y validez de los p-valores
  calc P {ω | ∃ i ∈ I₀, holmRej m α (p ω) i}
      ≤ P (⋃ i ∈ I₀, {ω | p ω i ≤ α / (I₀.card : ℝ)}) := hmonoP _ _ hincl
    _ ≤ ∑ i ∈ I₀, P {ω | p ω i ≤ α / (I₀.card : ℝ)} := hsubadd _ _
    _ ≤ ∑ _i ∈ I₀, α / (I₀.card : ℝ) := Finset.sum_le_sum fun i hi => hvalid i hi
    _ = α := by
        rw [Finset.sum_const, nsmul_eq_mul]
        have hne : (I₀.card : ℝ) ≠ 0 := ne_of_gt hm₀pos
        field_simp

end Holm

/-! ## thm:ch4-mlr — familias MLR: el test MP es de la forma `T > k` -/

section MLR

variable {X : Type*} [Fintype X]

/-- **Cociente de verosimilitudes monótono (MLR)** en `T` para una familia
exponencial canónica finita: con `q_η(x) = h(x)·exp(η·T(x))` y `h > 0`, la
razón `q_{η₁}(x)/q_{η₀}(x) = exp((η₁−η₀)·T(x))` es estrictamente creciente
en `T(x)`; en forma de multiplicación cruzada (sin dividir):
`q_{η₀}(y)·q_{η₁}(x) ≤ q_{η₀}(x)·q_{η₁}(y)` siempre que `T x ≤ T y`. -/
theorem mlr_cross {h T : X → ℝ} (hh : ∀ x, 0 < h x) {η₀ η₁ : ℝ} (hη : η₀ < η₁)
    {x y : X} (hT : T x ≤ T y) :
    (h y * Real.exp (η₀ * T y)) * (h x * Real.exp (η₁ * T x))
      ≤ (h x * Real.exp (η₀ * T x)) * (h y * Real.exp (η₁ * T y)) := by
  have hpos : (0:ℝ) < h x * h y := mul_pos (hh x) (hh y)
  have hlhs : (h y * Real.exp (η₀ * T y)) * (h x * Real.exp (η₁ * T x))
      = (h x * h y) * Real.exp (η₀ * T y + η₁ * T x) := by
    rw [Real.exp_add]; ring
  have hrhs : (h x * Real.exp (η₀ * T x)) * (h y * Real.exp (η₁ * T y))
      = (h x * h y) * Real.exp (η₀ * T x + η₁ * T y) := by
    rw [Real.exp_add]; ring
  rw [hlhs, hrhs]
  exact mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr (by nlinarith)) (le_of_lt hpos)

/-- La región de rechazo del test de razón de verosimilitudes de una
familia exponencial es un umbral en `T`: existe `k` con
`c·q_{η₀}(x) < q_{η₁}(x) ↔ T x > k`. -/
theorem lr_threshold {h T : X → ℝ} (hh : ∀ x, 0 < h x) {η₀ η₁ : ℝ} (hη : η₀ < η₁)
    {c : ℝ} (hc : 0 < c) :
    ∃ k : ℝ, ∀ x : X, (c * (h x * Real.exp (η₀ * T x)) < h x * Real.exp (η₁ * T x)) ↔ T x > k := by
  have hd : 0 < η₁ - η₀ := by linarith
  refine ⟨Real.log c / (η₁ - η₀), fun x => ?_⟩
  have hhx : 0 < h x := hh x
  have he₀ : (0:ℝ) < Real.exp (η₀ * T x) := Real.exp_pos _
  have hq : h x * Real.exp (η₁ * T x)
      = h x * Real.exp (η₀ * T x) * Real.exp ((η₁ - η₀) * T x) := by
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    ring
  rw [hq, mul_comm c (h x * Real.exp (η₀ * T x)),
    mul_lt_mul_iff_of_pos_left (mul_pos hhx he₀), ← Real.log_lt_iff_lt_exp hc]
  have hkey : Real.log c < (η₁ - η₀) * T x ↔ Real.log c / (η₁ - η₀) < T x := by
    rw [div_lt_iff₀ hd]
    constructor <;> intro h <;> nlinarith
  exact hkey

/-- book: capitulos/cap04_herramientas.typ:1292 (key: thm:ch4-mlr) —
**Existencia de UMP en familias MLR** (parte formalizada: la *forma* del
test). En una familia exponencial canónica finita
`q_η(x) = h(x)·exp(η·T(x))` con `h > 0`, la familia tiene MLR en `T`
(`mlr_cross`: el cociente de verosimilitudes es creciente en `T`), y por
tanto el test de razón de verosimilitudes entre `η₀ < η₁` — el test MP
de nivel `α` por `thm:ch4-neyman-pearson` — es exactamente de la forma
anunciada: rechaza cuando `T(X) > k`, con `k = log(c)/(η₁−η₀)` y
aleatorización `γ` sobre la frontera `T = k` (`lr_threshold`).

El enunciado del libro añade que, al ser la *misma forma* para todo par
`(η₀, η₁)` con `η₁ > η₀`, el test es UMP para `H₀ : θ ≤ θ₀` frente a
`H₁ : θ > θ₀` y que el orden estocástico inducido por MLR controla el
nivel sobre la nula compuesta.

Fidelidad declarada: se formalizan (a) MLR en forma de multiplicación
cruzada, (b) la identificación de la región de rechazo MP con un umbral
en `T`, y (c) la optimalidad MP **para cada par fijo** `(η₀,η₁)`, que es
`thm:ch4-neyman-pearson` aplicado a `p_i = q_{η_i}`. **No** se formaliza
el paso de "MP para cada par" a "UMP para la nula compuesta" (control
del nivel sobre `{θ ≤ θ₀}` vía orden estocástico monótono en `θ`); ese
paso requeriría la monotonía de `η ↦ E_η[φ(T)]` para `φ` creciente
(desigualdad de Chebyshev para integrales / doble suma simetrizada) y
queda declarado como deuda. Versión finita con estadístico escalar.
Origen: enjambre smw82qi6q / m16 (nuevo; formalización de pendiente). -/
theorem ch4_mlr (h T : X → ℝ) (hh : ∀ x, 0 < h x) {η₀ η₁ : ℝ} (hη : η₀ < η₁) :
    (∃ k : ℝ, ∀ x : X,
        (1 * (h x * Real.exp (η₀ * T x)) < h x * Real.exp (η₁ * T x)) ↔ T x > k)
    ∧ (∀ x y : X, T x ≤ T y →
        (h y * Real.exp (η₀ * T y)) * (h x * Real.exp (η₁ * T x))
          ≤ (h x * Real.exp (η₀ * T x)) * (h y * Real.exp (η₁ * T y))) := by
  refine ⟨?_, fun x y hT => mlr_cross hh hη hT⟩
  obtain ⟨k, hk⟩ := lr_threshold (h := h) (T := T) hh hη (c := 1) one_pos
  exact ⟨k, fun x => by simpa using hk x⟩

end MLR

/-! ## ex:ch4-bonferroni-ssch — cálculo concreto de multiplicidad -/

/-- book: capitulos/cap04_herramientas.typ:1398 (key: ex:ch4-bonferroni-ssch) —
**Pruebas múltiples en SSCH con corrección de Bonferroni** (cálculo
concreto del libro): con `m = 4` tratamientos y p-valores observados
`0.03, 0.01, 0.08, 0.04`, al nivel `α = 0.05`, sin corrección se
rechazan 3 nulas (los de p < 0.05) y la FWER bajo nulas verdaderas
independientes sería `1 − 0.95⁴ ≈ 0.185`; con Bonferroni
(`α/m = 0.0125`) se rechaza sólo el tratamiento 2, y `0.0125 ≤ 0.05`
mantiene la FWER controlada.

Fidelidad declarada: la parte aritmética del ejemplo; el valor exacto
`1 − 0.95⁴` se da como cota (`> 0.18`), que es lo que el libro usa para
ilustrar la inflación del error.
Origen: enjambre smw82qi6q / m16 (nuevo; formalización de pendiente). -/
theorem ex_ch4_bonferroni_ssch :
    (List.filter (fun p : ℝ => p < 0.05) [0.03, 0.01, 0.08, 0.04]).length = 3
    ∧ (List.filter (fun p : ℝ => p < 0.05 / 4) [0.03, 0.01, 0.08, 0.04]).length = 1
    ∧ 0.0125 < (0.05 : ℝ)
    ∧ (0.18 : ℝ) < 1 - (1 - 0.05) ^ 4 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

end Cap04M16
