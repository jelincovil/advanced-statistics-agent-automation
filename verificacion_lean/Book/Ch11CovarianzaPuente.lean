import Mathlib
import Book.Ch5CltAgentesCovarianza

/-!
# Book.Ch11CovarianzaPuente — el paso «Toeplitz estándar» del capítulo 11

Módulo auxiliar del miembro m4 (swarm `smwi1z2xl`). **No modifica**
`Book/Cap08Ch11M10.lean` ni reabre la revisión de `thm:ch11-clt-mixing`, que
sigue siendo responsabilidad de su propia dirección.

`Ch11M10.ch11_clt_mixing_var` demuestra la identidad de conteo

  `Var_p(∑_{t<n}X_t) = n·γ_0 + 2∑_{k<n}(n−1−k)·γ_{k+1}`

y su docstring deja explícito que «el límite de las sumas ponderadas que da
`(1/n)Var → σ²_LR` es el lema de Toeplitz estándar», sin formalizarlo. Este
archivo cierra exactamente ese paso con
`BookCh5CltAgentesCov.toeplitz_weighted_shift`, para comprobar que el lema
general de la dirección de `thm:ch5-clt-agentes` **aplica** a la estructura
homóloga del capítulo 11: `(1/n)·Var_p(∑_{t<n}X_t) → γ_0 + 2∑_{k≥1}γ_k`.

Fidelidad declarada: `Ω` finito (`Fintype Ω`, convención del proyecto),
estacionariedad débil `Cov_p(X_t,X_{t+k}) = γ_k` y `∑_k|γ_k| < ∞` como
hipótesis explícita. No se prueba nada distribucional ni de mixing.
-/

open Finset BigOperators Filter
open scoped Topology

set_option maxHeartbeats 800000

namespace Ch11CovPuente

variable {Ω : Type*} [Fintype Ω]

/-- book: capitulos/cap08_intervalos.typ:180 (key: thm:ch11-clt-mixing) —
**Paso cuantitativo/Cesàro, no el CLT:** la varianza de la suma dividida por n
converge a γ(0)+2∑γ(k), bajo estacionariedad y covarianzas sumables. Queda fuera
la convergencia distribucional y la definición general de mezcla.

**Límite de la varianza media en la estructura del capítulo 11.** A partir
de la identidad de conteo de `Ch11M10.ch11_clt_mixing_var` y del lema de
Toeplitz de `BookCh5CltAgentesCov`, la varianza de la media (con la escala
`1/n`) converge a la varianza de largo plazo `γ_0 + 2∑_{k≥1}γ_k`. -/
theorem ch11_var_media_limite (p : Ω → ℝ) (X : ℕ → Ω → ℝ) (γ : ℕ → ℝ)
    (hstat : ∀ t k : ℕ, Ch11M10.fcov p (X t) (X (t + k)) = γ k)
    (habs : Summable fun k => |γ k|) :
    Tendsto (fun n : ℕ => (n : ℝ)⁻¹ * Ch11M10.fvar p (fun ω => ∑ t : Fin n, X (t : ℕ) ω))
      atTop (𝓝 (γ 0 + 2 * ∑' k : ℕ, γ (k + 1))) := by
  have htoep := BookCh5CltAgentesCov.toeplitz_weighted_shift (fun k : ℕ => γ (k + 1))
    (BookCh5CltAgentesCov.summable_tail habs)
  have hlim : Tendsto
      (fun n : ℕ => γ 0 + 2 * ((n : ℝ)⁻¹ * ∑ k ∈ range n, ((n - 1 - k : ℕ) : ℝ) * γ (k + 1)))
      atTop (𝓝 (γ 0 + 2 * ∑' k : ℕ, γ (k + 1))) := (htoep.const_mul 2).const_add (γ 0)
  refine hlim.congr' ?_
  filter_upwards [Ici_mem_atTop 1] with n hn
  have hn0 : (n : ℝ) ≠ 0 := by
    have hpos : (0 : ℕ) < n := hn
    exact_mod_cast Nat.pos_iff_ne_zero.mp hpos
  rw [Ch11M10.ch11_clt_mixing_var p X γ hstat]
  field_simp

end Ch11CovPuente
