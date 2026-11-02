"""
Transferencia de inferencia — Teoremas 9.7 y 9.8.

* `ic_transfer_delta`: IC para θ → IC para V^π vía delta-method.
* `test_transfer_ump`: test UMP para θ → test de política óptima.

Bajo el isomorfismo, ambas transferencias preservan nivel y cobertura
asintótica (Teoremas 9.7, 9.8).
"""
from __future__ import annotations
from typing import Callable
import numpy as np
from scipy.stats import norm


def ic_transfer_delta(theta_hat: float, var_theta: float,
                      V_fn: Callable[[float], float],
                      dV_dtheta: float | None = None,
                      level: float = 0.95) -> tuple:
    """IC para V^π por delta-method.

    $V^\\pi(\\hat\\theta)$ es un funcional suave de θ̂. Bajo CLT,
    $\\sqrt{n}(\\hat V - V) \\to N(0, (V'(\\theta))^2 \\sigma^2)$.

    Si V_fn es diferenciable, dV/dθ puede pasarse explícitamente o
    estimarse numéricamente.
    """
    V_hat = V_fn(theta_hat)
    if dV_dtheta is None:
        eps = 1e-6
        dV_dtheta = (V_fn(theta_hat + eps) - V_fn(theta_hat - eps)) / (2 * eps)
    var_V = (dV_dtheta ** 2) * var_theta
    se_V = np.sqrt(var_V)
    z = norm.ppf(1 - (1 - level) / 2)
    return (float(V_hat - z * se_V), float(V_hat + z * se_V), float(se_V))


def test_transfer_ump(theta_hat: float, n: int, theta0: float,
                      V_fn: Callable[[float], float],
                      dV_dtheta: float | None = None,
                      alpha: float = 0.05) -> dict:
    """Test $H_0: V^\\pi = V_0$ vs $H_1: V^\\pi \\ne V_0$ con V_0 = V_fn(θ_0).

    Bajo H_0, $Z = (\\hat V - V_0)/SE(\\hat V) \\sim N(0,1)$ asintóticamente.
    """
    V0 = V_fn(theta0)
    V_hat = V_fn(theta_hat)
    if dV_dtheta is None:
        eps = 1e-6
        dV_dtheta = (V_fn(theta_hat + eps) - V_fn(theta_hat - eps)) / (2 * eps)
    var_V = (dV_dtheta ** 2) * theta_hat * (1 - theta_hat) / n
    se_V = np.sqrt(var_V)
    if se_V == 0:
        z, p = 0.0, 1.0
    else:
        z = (V_hat - V0) / se_V
        p = 2 * (1 - norm.cdf(abs(z)))
    return {
        "V_hat": float(V_hat), "V_0": float(V0),
        "se": float(se_V), "z": float(z), "p_value": float(p),
        "reject": bool(p < alpha),
    }
