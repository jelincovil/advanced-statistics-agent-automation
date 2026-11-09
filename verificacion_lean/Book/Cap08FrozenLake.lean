import Mathlib
import Book.Cap03MDP

/-!
# Book.Cap08FrozenLake — cap. 3 del libro (capitulos/cap03_mdp.typ:260):
`ex:ch8-frozenlake`, Value Iteration con modelo tabular explícito.

Modelo: FrozenLake-v1 `4x4` de Gymnasium con deslizamiento, acciones
0=izquierda, 1=abajo, 2=derecha, 3=arriba, recompensa 1 al alcanzar la meta
(estado 15) y 0 en otro caso, estados terminales absorbentes (agujeros
5,7,11,12 y meta 15), `γ = 99/100`. Se certifica numéricamente:

* el residuo `‖T* V − V‖_∞` de un vector explícito `V` de 25 decimales es
  `≤ 10⁻¹²` (el libro imprime `9.805e−13`);
* de ahí, con el certificado de parada `cor:ch8-parada` (Book.Cap03MDP),
  `‖V − V*‖_∞ ≤ 10⁻¹⁰` (el libro: «la cota de error del vector es menor
  que `10⁻¹⁰`»), y los valores impresos: `|V*(0) − 0.54202593| ≤ 10⁻⁸`,
  `|V*(14) − 0.86283743| ≤ 10⁻⁸`, `V*(15) = 0`;
* la política greedy `πFL` respecto de `V` es óptima-candidata: `T^π V = T* V`.

Fidelidad declarada: `V*` entra como punto fijo de `T*` (la forma del
capítulo, igual que en `thm:ch8-bellman-opt` y `cor:ch8-parada`); el
modelo es el del código Python del libro (transiciones 1/3 sobre la acción
pretendida y sus dos perpendiculares, recorte en la frontera); los valores
impresos por el libro se citan con 8 decimales y se certifican con
tolerancia 10⁻⁸. La comprobación empírica `k = 703` es una propiedad del
programa de punto flotante, no una afirmación matemática: aquí se
certifica el residuo alcanzado, que es lo que la cota usa.
-/

open Finset BigOperators

namespace Book.Ch8Bandits

set_option maxHeartbeats 2000000
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

/-- Acción anterior en el ciclo 0=izquierda, 1=abajo, 2=derecha, 3=arriba. -/
def pred4 : Fin 4 → Fin 4
  | 0 => 3
  | 1 => 0
  | 2 => 1
  | 3 => 2

/-- Acción siguiente en el ciclo. -/
def succ4 : Fin 4 → Fin 4
  | 0 => 1
  | 1 => 2
  | 2 => 3
  | 3 => 0

/-- Movimiento en el mapa 4x4 con recorte a la rejilla (sin envolver). -/
def delta : Fin 16 → Fin 4 → Fin 16
  | 0, 0 => 0
  | 0, 1 => 4
  | 0, 2 => 1
  | 0, 3 => 0
  | 1, 0 => 0
  | 1, 1 => 5
  | 1, 2 => 2
  | 1, 3 => 1
  | 2, 0 => 1
  | 2, 1 => 6
  | 2, 2 => 3
  | 2, 3 => 2
  | 3, 0 => 2
  | 3, 1 => 7
  | 3, 2 => 3
  | 3, 3 => 3
  | 4, 0 => 4
  | 4, 1 => 8
  | 4, 2 => 5
  | 4, 3 => 0
  | 5, 0 => 4
  | 5, 1 => 9
  | 5, 2 => 6
  | 5, 3 => 1
  | 6, 0 => 5
  | 6, 1 => 10
  | 6, 2 => 7
  | 6, 3 => 2
  | 7, 0 => 6
  | 7, 1 => 11
  | 7, 2 => 7
  | 7, 3 => 3
  | 8, 0 => 8
  | 8, 1 => 12
  | 8, 2 => 9
  | 8, 3 => 4
  | 9, 0 => 8
  | 9, 1 => 13
  | 9, 2 => 10
  | 9, 3 => 5
  | 10, 0 => 9
  | 10, 1 => 14
  | 10, 2 => 11
  | 10, 3 => 6
  | 11, 0 => 10
  | 11, 1 => 15
  | 11, 2 => 11
  | 11, 3 => 7
  | 12, 0 => 12
  | 12, 1 => 12
  | 12, 2 => 13
  | 12, 3 => 8
  | 13, 0 => 12
  | 13, 1 => 13
  | 13, 2 => 14
  | 13, 3 => 9
  | 14, 0 => 13
  | 14, 1 => 14
  | 14, 2 => 15
  | 14, 3 => 10
  | 15, 0 => 14
  | 15, 1 => 15
  | 15, 2 => 15
  | 15, 3 => 11
  | _, _ => 0

/-- Estados terminales: agujeros 5,7,11,12 y meta 15. -/
def flTerm (s : Fin 16) : Prop :=
  s = 5 ∨ s = 7 ∨ s = 11 ∨ s = 12 ∨ s = 15

instance : DecidablePred flTerm := fun s => by unfold flTerm; infer_instance

/-- Kernel del FrozenLake-v1 4x4 con deslizamiento: en un estado no
terminal, la acción pretendida y las dos perpendiculares ocurren con
probabilidad `1/3` cada una; los terminales son absorbentes. -/
noncomputable def PFL (s : Fin 16) (a : Fin 4) (s' : Fin 16) : ℝ :=
  if flTerm s then (if s' = s then 1 else 0)
  else (if s' = delta s (pred4 a) then 1/3 else 0)
    + (if s' = delta s a then 1/3 else 0)
    + (if s' = delta s (succ4 a) then 1/3 else 0)

/-- Recompensa esperada de un paso: probabilidad de alcanzar la meta. -/
noncomputable def rFL (s : Fin 16) (a : Fin 4) : ℝ := if s = 15 then 0 else PFL s a 15

/-- Descuento del ejemplo. -/
noncomputable def γFL : ℝ := 99/100

/-- Vector de value iteration del libro (25 decimales; el libro imprime 8). -/
noncomputable def VFL : Fin 16 → ℝ
  | 0 => 0.5420259320004729215381607
  | 1 => 0.4988031872294616418226614
  | 2 => 0.4706956905563128361017881
  | 3 => 0.4568516996575977526870296
  | 4 => 0.5584509602429114949181050
  | 5 => 0.0000000000000000000000000
  | 6 => 0.3583480719830338303775219
  | 7 => 0.0000000000000000000000000
  | 8 => 0.5917987448563473863258706
  | 9 => 0.6430798247684604712586627
  | 10 => 0.6152075578771230135270661
  | 11 => 0.0000000000000000000000000
  | 12 => 0.0000000000000000000000000
  | 13 => 0.7417204389891370888096774
  | 14 => 0.8628374301488784666276520
  | 15 => 0.0000000000000000000000000
  | _ => 0

/-- Política greedy respecto de `VFL` en cada estado. -/
def piFL : Fin 16 → Fin 4
  | 0 => 0
  | 1 => 3
  | 2 => 3
  | 3 => 3
  | 4 => 0
  | 5 => 0
  | 6 => 0
  | 7 => 0
  | 8 => 3
  | 9 => 1
  | 10 => 0
  | 11 => 0
  | 12 => 0
  | 13 => 2
  | 14 => 1
  | 15 => 0
  | _ => 0

/-! ## Lemas auxiliares de sumas con indicadores -/

private theorem sum_ite_const {ι : Type*} [Fintype ι] [DecidableEq ι] (d : ι) (c : ℝ) :
    (∑ i : ι, (if i = d then c else 0)) = c := by
  simp [Finset.sum_ite_eq']

private theorem sum_ite_mul {ι : Type*} [Fintype ι] [DecidableEq ι] (V : ι → ℝ) (d : ι) (c : ℝ) :
    (∑ i : ι, (if i = d then c else 0) * V i) = c * V d := by
  have h : ∀ i : ι, (if i = d then c else 0) * V i = (if i = d then c * V i else 0) := by
    intro i
    split <;> simp
  simp only [h, Finset.sum_ite_eq']
  simp

/-! ## Estocasticidad del modelo -/

/-- Cada fila de `PFL` suma 1. -/
theorem PFL_row (s : Fin 16) (a : Fin 4) : ∑ s', PFL s a s' = 1 := by
  fin_cases s <;> fin_cases a <;>
    simp [PFL, flTerm, delta, pred4, succ4, Finset.sum_add_distrib] <;>
    norm_num

private theorem ite_one_nonneg (c : Prop) [Decidable c] : (0:ℝ) ≤ (if c then 1 else 0) := by
  split <;> norm_num

private theorem ite_third_nonneg (c : Prop) [Decidable c] : (0:ℝ) ≤ (if c then 1/3 else 0) := by
  split <;> norm_num

/-- Las entradas de `PFL` son no negativas. -/
theorem PFL_nonneg (s : Fin 16) (a : Fin 4) (s' : Fin 16) : 0 ≤ PFL s a s' := by
  unfold PFL
  split
  · exact ite_one_nonneg _
  · exact add_nonneg (add_nonneg (ite_third_nonneg _) (ite_third_nonneg _))
      (ite_third_nonneg _)

/-! ## Expresión de Bellman y política greedy -/

/-- Expresión de Bellman de la acción `a` en el estado `s` para el vector `V`. -/
noncomputable def qFL (V : Fin 16 → ℝ) (s : Fin 16) (a : Fin 4) : ℝ :=
  rFL s a + γFL * ∑ s', PFL s a s' * V s'

/-- La acción `piFL s` maximiza la expresión de Bellman evaluada en `VFL`. -/
theorem piFL_greedy (s : Fin 16) (a : Fin 4) : qFL VFL s a ≤ qFL VFL s (piFL s) := by
  fin_cases s <;> fin_cases a <;>
    simp [qFL, rFL, PFL, flTerm, delta, pred4, succ4, piFL, VFL, γFL, add_mul, Finset.sum_add_distrib, sum_ite_mul] <;>
    norm_num

/-- El operador óptimo en `VFL` es la expresión de la acción greedy. -/
theorem Topt_VFL (s : Fin 16) : Topt rFL PFL γFL VFL s = qFL VFL s (piFL s) := by
  refine le_antisymm ?_ ?_
  · rw [Topt]
    exact Finset.sup'_le _ _ (fun a _ => piFL_greedy s a)
  · rw [Topt]
    exact Finset.le_sup'
      (f := fun a => rFL s a + γFL * ∑ s', PFL s a s' * VFL s') (mem_univ (piFL s))

/-- El operador de la política `piFL` coincide con el óptimo en `VFL`: `piFL` es
greedy respecto de `VFL`. -/
theorem Tpol_VFL (s : Fin 16) : Tpol rFL PFL γFL piFL VFL s = Topt rFL PFL γFL VFL s := by
  rw [Topt_VFL s]
  simp [Tpol, rvec, mvec, pmat, qFL]

/-- Residuo punto a punto del vector de value iteration. -/
theorem fl_residual_pt (s : Fin 16) :
    |Topt rFL PFL γFL VFL s - VFL s| ≤ 1/10^12 := by
  rw [Topt_VFL s]
  fin_cases s <;>
    simp [qFL, rFL, PFL, flTerm, delta, pred4, succ4, piFL, VFL, γFL, add_mul, Finset.sum_add_distrib, sum_ite_mul] <;>
    norm_num

/-- Residuo en norma supremo: `‖T* V − V‖_∞ ≤ 10⁻¹²`. -/
theorem fl_residual :
    snorm (fun s => Topt rFL PFL γFL VFL s - VFL s) ≤ 1/10^12 := by
  show (univ : Finset (Fin 16)).sup' univ_nonempty
    (fun s => |Topt rFL PFL γFL VFL s - VFL s|) ≤ 1/10^12
  exact Finset.sup'_le _ _ (fun s _ => fl_residual_pt s)

/-! ## El ejemplo: certificado numérico -/

/-- book: capitulos/cap03_mdp.typ:260 (key: ex:ch8-frozenlake) — Value
Iteration con modelo tabular explícito (FrozenLake-v1 4x4 con deslizamiento,
`γ = 99/100`). El vector `VFL` (25 decimales) tiene residuo
`‖T* V − V‖_∞ ≤ 10⁻¹²` (el libro imprime `9.805·10⁻¹³`); por el certificado de
parada `cor:ch8-parada`, el valor óptimo `V*` (punto fijo de `T*`, la forma del
capítulo) satisface `‖V − V*‖_∞ ≤ 10⁻¹⁰` (el libro: «la cota de error del
vector es menor que 10⁻¹⁰») y los valores impresos `V*(0) ≈ 0.54202593`,
`V*(14) ≈ 0.86283743`, `V*(15) = 0`, con tolerancia `10⁻⁸` (8 decimales
impresos). Fidelidad declarada: se certifica el residuo y sus consecuencias;
el número de iteraciones `k = 703` y el residuo exacto de punto flotante son
propiedades del programa, no del enunciado matemático. -/
theorem ex_ch8_frozenlake (W : Fin 16 → ℝ) (hW : ∀ s, Topt rFL PFL γFL W s = W s) :
    (snorm (fun s => Topt rFL PFL γFL VFL s - VFL s) ≤ 1/10^12) ∧
    (∀ s, |W s - VFL s| ≤ 1/10^10) ∧
    (|W 0 - 0.54202593| ≤ 1/10^8) ∧
    (|W 14 - 0.86283743| ≤ 1/10^8) ∧
    (W 15 = 0) := by
  have hγ0 : (0:ℝ) ≤ γFL := by norm_num [γFL]
  have hγ1 : γFL < 1 := by norm_num [γFL]
  have hgreedy : ∀ s a, rFL s (piFL s) + γFL * ∑ s', PFL s (piFL s) s' * VFL s'
      ≥ rFL s a + γFL * ∑ s', PFL s a s' * VFL s' := fun s a => piFL_greedy s a
  have hpar := (ch8_parada rFL PFL γFL piFL VFL W PFL_nonneg PFL_row hγ0 hγ1 hW hgreedy).1
  have he : snorm (fun s => Topt rFL PFL γFL VFL s - VFL s) ≤ 1/10^12 := fl_residual
  have hdiv : snorm (fun s => Topt rFL PFL γFL VFL s - VFL s) / (1 - γFL) ≤ 1/10^10 := by
    have hg : 1 - γFL = (1/100 : ℝ) := by norm_num [γFL]
    have h1 : (1/100 : ℝ)⁻¹ = 100 := by norm_num
    rw [hg, div_eq_mul_inv, h1]
    have h2 := mul_le_mul_of_nonneg_right he (by norm_num : (0:ℝ) ≤ 100)
    have h3 : (1/10^12 : ℝ) * 100 = 1/10^10 := by norm_num
    linarith [h2, h3]
  have hVW : ∀ s, |W s - VFL s| ≤ 1/10^10 := by
    intro s
    have h := hpar s
    rw [abs_sub_comm]
    linarith [hdiv]
  have hW0 : |W 0 - 0.54202593| ≤ 1/10^8 := by
    have hnum : |VFL 0 - 0.54202593| ≤ 3/10^9 := by norm_num [VFL]
    calc |W 0 - 0.54202593| = |(W 0 - VFL 0) + (VFL 0 - 0.54202593)| := by ring_nf
      _ ≤ |W 0 - VFL 0| + |VFL 0 - 0.54202593| := abs_add_le _ _
      _ ≤ 1/10^10 + 3/10^9 := add_le_add (hVW 0) hnum
      _ ≤ 1/10^8 := by norm_num
  have hW14 : |W 14 - 0.86283743| ≤ 1/10^8 := by
    have hnum : |VFL 14 - 0.86283743| ≤ 3/10^9 := by norm_num [VFL]
    calc |W 14 - 0.86283743| = |(W 14 - VFL 14) + (VFL 14 - 0.86283743)| := by ring_nf
      _ ≤ |W 14 - VFL 14| + |VFL 14 - 0.86283743| := abs_add_le _ _
      _ ≤ 1/10^10 + 3/10^9 := add_le_add (hVW 14) hnum
      _ ≤ 1/10^8 := by norm_num
  have hW15 : W 15 = 0 := by
    have hconst : ∀ a : Fin 4, rFL 15 a + γFL * ∑ s', PFL 15 a s' * W s' = γFL * W 15 := by
      intro a
      fin_cases a <;> simp [rFL, PFL, flTerm, delta, pred4, succ4, γFL, add_mul, Finset.sum_add_distrib, sum_ite_mul]
    have hT : Topt rFL PFL γFL W 15 = γFL * W 15 := by
      rw [Topt]
      have hf : (fun a : Fin 4 => rFL 15 a + γFL * ∑ s', PFL 15 a s' * W s')
          = (fun _ => γFL * W 15) := funext hconst
      rw [hf, Finset.sup'_const]
    have hfix := hW 15
    rw [hT] at hfix
    have hg : γFL = 99/100 := by norm_num [γFL]
    rw [hg] at hfix
    linarith
  exact ⟨he, hVW, hW0, hW14, hW15⟩

end Book.Ch8Bandits
