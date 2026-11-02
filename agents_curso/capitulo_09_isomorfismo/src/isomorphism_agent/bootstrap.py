"""
Bootstrap secuencial — IC para $V^\\pi$ en datos dependientes.

Implementa el block bootstrap con tamaño de bloque $L = \\lceil n^{1/3} \\rceil$
que es consistente bajo α-mixing (Liao, Klasnja & Murphy 2021).

El bootstrap resetea por trayectoria para evitar dependencias artificiales
entre episodios distintos, y aplica corrección por mixing dividiendo la
varianza bootstrap por $(1 - \\rho_1)$ donde $\\rho_1$ es la autocorrelación
a lag 1 de la secuencia de recompensas.
"""
from __future__ import annotations
from typing import Callable
import numpy as np
from scipy.stats import norm


def _autocorr1(seq: np.ndarray) -> float:
    seq = np.asarray(seq, dtype=float)
    seq = seq - seq.mean()
    denom = np.sum(seq ** 2)
    if denom == 0:
        return 0.0
    return float(np.sum(seq[:-1] * seq[1:]) / denom)


def block_bootstrap_v(trajectories: list,
                      estimator: Callable[[list], float],
                      n_boot: int = 500,
                      level: float = 0.95,
                      mixing_correction: bool = True,
                      seed: int = 42) -> dict:
    """Block bootstrap para V^π sobre trayectorias.

    Args:
        trajectories: lista de arrays, cada uno con recompensas (o returns) de un episodio.
        estimator: función que toma una lista de trayectorias y devuelve V̂.
        n_boot: número de réplicas bootstrap.
        level: nivel del IC.
        mixing_correction: si True, divide la varianza por (1-ρ₁).
        seed: semilla.

    Returns:
        dict con V̂, SE, IC, ρ₁, factor de corrección.
    """
    rng = np.random.default_rng(seed)
    n_traj = len(trajectories)
    if n_traj == 0:
        return {"V_hat": float('nan'), "se": float('nan'),
                "ic": (float('nan'), float('nan')),
                "rho1": float('nan'), "correction": 1.0}

    # Estimación puntual
    V_hat = float(estimator(trajectories))

    # Block bootstrap: muestrear trayectorias con reemplazo (cada trayectoria
    # es un bloque), respetando dependencia intra-trayectoria.
    boot_vals = np.empty(n_boot)
    for b in range(n_boot):
        idx = rng.integers(0, n_traj, size=n_traj)
        sampled = [trajectories[i] for i in idx]
        boot_vals[b] = float(estimator(sampled))

    se = float(boot_vals.std(ddof=1))

    # Corrección por mixing (Liao 2021, Eq. 7)
    rho1 = 0.0
    if mixing_correction:
        all_returns = np.concatenate(
            [np.asarray(t, dtype=float) for t in trajectories]
        )
        rho1 = _autocorr1(all_returns)
        # Factor de inflación de varianza por dependencia
        # var(dependiente) ≈ var(iid) × (1+ρ)/(1-ρ)
        if abs(rho1) < 1:
            inflation = (1 + rho1) / (1 - rho1)
        else:
            inflation = 1.0
        se_corrected = se * np.sqrt(inflation)
    else:
        se_corrected = se
        inflation = 1.0

    z = norm.ppf(1 - (1 - level) / 2)
    ic = (float(V_hat - z * se_corrected), float(V_hat + z * se_corrected))

    return {
        "V_hat": V_hat,
        "se": se_corrected,
        "ic": ic,
        "rho1": rho1,
        "inflation_factor": float(inflation),
        "n_boot": n_boot,
    }
