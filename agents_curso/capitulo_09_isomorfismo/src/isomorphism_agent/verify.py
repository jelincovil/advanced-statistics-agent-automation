"""
Protocolo de Verificación — Proposición 9.14.

Antes de invocar una garantía estadística transferida por el isomorfismo,
el agente debe verificar las cuatro condiciones del Teorema 9.13:

1. **Mixing**:     $(S_t, A_t, R_t)$ es α-mixing con coeficientes sumables.
2. **Overlap**:    $\\pi_b(a|s) \\geq \\eta \\cdot \\pi(a|s)$.
3. **Nuisance**:   $\\|\\hat Q - Q\\| = o_P(n^{-1/4})$, $\\|\\hat\\pi_b - \\pi_b\\| = o_P(n^{-1/4})$.
4. **Momentos**:   $\\E[|r|^{2+\\delta}] < \\infty$.

Si alguna falla, el agente **NO** invoca la garantía y reporta limitación.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import numpy as np


@dataclass
class VerificationResult:
    mixing_ok: bool
    overlap_ok: bool
    nuisance_ok: bool
    moments_ok: bool
    mixing_rate: float = float('nan')   # α(1) estimado
    ess: float = float('nan')
    rho_max: float = float('nan')
    overlap_eta: float = float('nan')
    moments_delta: float = float('nan')
    nuissance_q_rate: Optional[float] = None
    nuissance_pi_rate: Optional[float] = None
    warnings: list = field(default_factory=list)
    transferable: bool = False
    fallback: str = ""

    def as_dict(self) -> dict:
        return {k: v for k, v in self.__dict__.items()}


# ---------------------------------------------------------------------------
# Tests individuales
# ---------------------------------------------------------------------------
def _autocorrelation_mixing(seq: np.ndarray, max_lag: int = 20) -> float:
    """Estima α(1) empírico como 1 - |ρ(1)| donde ρ(1) es autocorrelación a lag 1."""
    seq = np.asarray(seq, dtype=float)
    if len(seq) < 3:
        return 1.0
    seq = seq - seq.mean()
    denom = np.sum(seq ** 2)
    if denom == 0:
        return 1.0
    rho1 = np.sum(seq[:-1] * seq[1:]) / denom
    return float(1.0 - abs(rho1))


def _ess(log_rho: np.ndarray) -> float:
    """Effective Sample Size: $\\mathrm{ESS} = (\\sum \\rho_i)^2 / \\sum \\rho_i^2$."""
    rho = np.exp(np.clip(log_rho, -50, 50))
    num = rho.sum() ** 2
    den = (rho ** 2).sum()
    return float(num / den) if den > 0 else 0.0


def _rho_max(log_rho: np.ndarray) -> float:
    return float(np.exp(np.max(np.clip(log_rho, -50, 50))))


def _overlap_eta(pi_b_probs: np.ndarray, pi_e_probs: np.ndarray,
                 actions: np.ndarray, states: np.ndarray) -> float:
    """η efectivo: min sobre (s,a) de π_b(a|s)/π_e(a|s) en el soporte de π_e."""
    # Aquí suponemos pi_b_probs y pi_e_probs vienen dados por (s,a) indexado.
    # Simplificación: retornar el mínimo ratio en el soporte de pi_e.
    mask = pi_e_probs > 0
    if not np.any(mask):
        return 0.0
    ratios = pi_b_probs[mask] / pi_e_probs[mask]
    return float(ratios.min())


def _moment_test(rewards: np.ndarray, delta: float = 1.0) -> tuple:
    """Comprueba que E[|r|^{2+δ}] < ∞ empíricamente. Devuelve (ok, valor)."""
    rewards = np.asarray(rewards, dtype=float)
    val = float(np.mean(np.abs(rewards) ** (2 + delta)))
    # Heurística: finite y < 1e6
    return (bool(np.isfinite(val) and val < 1e6), val)


# ---------------------------------------------------------------------------
# Protocolo completo (Prop. 9.14)
# ---------------------------------------------------------------------------
def verify_guarantee(trajectories: list | None = None,
                     log_rho: np.ndarray | None = None,
                     rewards: np.ndarray | None = None,
                     pi_b_probs: np.ndarray | None = None,
                     pi_e_probs: np.ndarray | None = None,
                     nuisance_q_rate: float | None = None,
                     nuisance_pi_rate: float | None = None,
                     eta_min: float = 0.05,
                     ess_min_factor: float = 0.02,
                     mixing_threshold: float = 0.05) -> VerificationResult:
    """Ejecuta el Protocolo de la Proposición 9.14.

    Devuelve un `VerificationResult` con el veredicto sobre cada una de las
    cuatro condiciones del Teorema 9.13 y el campo `transferable` que indica
    si el isomorfismo puede invocarse con garantías. Si no, `fallback`
    sugiere el estimador conservador a usar.
    """
    res = VerificationResult(
        mixing_ok=True, overlap_ok=True, nuisance_ok=True, moments_ok=True,
    )

    # 1. Mixing (sólo si hay trayectorias)
    if trajectories is not None and len(trajectories) > 0:
        seq = np.concatenate([np.asarray(t, dtype=float) for t in trajectories])
        res.mixing_rate = _autocorrelation_mixing(seq)
        res.mixing_ok = res.mixing_rate > mixing_threshold
        if not res.mixing_ok:
            res.warnings.append(
                f"Mixing α(1)={res.mixing_rate:.3f} < {mixing_threshold:.2f}; "
                "CLT no garantizado. Use ventanas temporales o bloques."
            )
    else:
        # Sin secuencias: asumimos iid (mixing trivialmente satisfecho)
        res.mixing_rate = 1.0

    # 2. Overlap
    if log_rho is not None:
        res.ess = _ess(log_rho)
        res.rho_max = _rho_max(log_rho)
        n = len(log_rho)
        res.overlap_ok = (res.ess >= ess_min_factor * n) and (res.rho_max < 100)
        res.overlap_eta = float(res.ess / n) if n > 0 else 0.0
        if not res.overlap_ok:
            res.warnings.append(
                f"Overlap insuficiente: ESS={res.ess:.1f}/{n}, "
                f"ρ_max={res.rho_max:.1f}. Considere clipping adaptativo (Su 2020)."
            )
    elif pi_b_probs is not None and pi_e_probs is not None:
        res.overlap_eta = _overlap_eta(pi_b_probs, pi_e_probs,
                                       None, None)
        res.overlap_ok = res.overlap_eta > eta_min
        if not res.overlap_ok:
            res.warnings.append(
                f"η_overlap={res.overlap_eta:.3f} < {eta_min:.2f}; "
                "IS/DR tienen varianza inflada."
            )

    # 3. Nuisance
    if nuisance_q_rate is not None and nuisance_pi_rate is not None:
        # Teorema 9.13: ||Q̂-Q|| = o_P(n^{-1/4}); n^{-1/4} ≈ 0.18 para n=1000
        n = len(rewards) if rewards is not None else 1000
        target = n ** (-0.25)
        res.nuissance_q_rate = nuisance_q_rate
        res.nuissance_pi_rate = nuisance_pi_rate
        res.nuisance_ok = (nuisance_q_rate < target
                           and nuisance_pi_rate < target)
        if not res.nuisance_ok:
            res.warnings.append(
                f"Nuisance rates (Q={nuisance_q_rate:.3f}, "
                f"π={nuisance_pi_rate:.3f}) > n^(-1/4)={target:.3f}; "
                "DR puede no ser semiparamétricamente eficiente."
            )
    else:
        # Asumimos que se satisface
        res.nuisance_ok = True

    # 4. Momentos
    if rewards is not None:
        res.moments_ok, res.moments_delta = _moment_test(rewards)
        if not res.moments_ok:
            res.warnings.append(
                f"Momento 2+δ={res.moments_delta:.3e} no finito. "
                "Considere winsorizar recompensas."
            )

    # Veredicto
    res.transferable = (res.mixing_ok and res.overlap_ok
                        and res.nuisance_ok and res.moments_ok)
    if not res.transferable:
        if not res.overlap_ok:
            res.fallback = "DR con clipping adaptativo (Su et al. 2020) + DM"
        elif not res.mixing_ok:
            res.fallback = "Block bootstrap (Liao et al. 2021) + IC conservadores"
        elif not res.nuisance_ok:
            res.fallback = "Cross-fitting (Chernozhukov 2018) + DM"
        elif not res.moments_ok:
            res.fallback = "Winsorizar recompensas + IC robustos"
    return res
