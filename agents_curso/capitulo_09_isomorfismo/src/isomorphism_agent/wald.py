r"""
Wald — problema de decisión estadística $(\Theta, \mathcal{A}, \mathcal{X}, L)$.

Definición 9.1 del capítulo. Implementa:
* familia Bernoulli con prior Beta (caso canónico del Lab F.9),
* función de pérdida asimétrica para tratamiento,
* regla de Bayes δ^* y regla minimax.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Protocol, Sequence, runtime_checkable

import numpy as np
from scipy.stats import beta as beta_dist
from scipy.stats import norm


# ---------------------------------------------------------------------------
# Distribution Protocol e implementación Bernoulli
# ---------------------------------------------------------------------------
@runtime_checkable
class Distribution(Protocol):
    """Protocolo para una familia paramétrica P_θ.

    Un `Distribution` debe poder:
    - Calcular el estadístico suficiente a partir de datos,
    - Actualizar un prior conjugado,
    - Proporcionar IC para θ,
    - Realizar tests para θ.
    """
    def sufficient_stat(self, data: np.ndarray) -> dict:
        """Devuelve T(X): estadístico suficiente minimal."""
        ...

    def posterior_update(self, prior: dict, data: np.ndarray) -> tuple:
        """Actualiza los parámetros del posterior conjugado.
        Devuelve (alpha, beta) o (mu, sigma) según la familia."""
        ...

    def posterior_ic(self, alpha: float, beta: float, level: float = 0.95) -> tuple:
        """IC para θ del posterior."""
        ...

    def wald_test(self, theta_hat: float, n: int, theta0: float,
                  alpha: float = 0.05) -> dict:
        """Test de Wald para H_0: θ = θ_0."""
        ...


class BernoulliDistribution:
    """Familia Bernoulli(θ) con prior conjugado Beta(α,β).

    Es el caso canónico del Lab F.9 del libro.
    """

    def sufficient_stat(self, data: np.ndarray) -> dict:
        data = np.asarray(data)
        return {"n": len(data), "sum_x": float(data.sum()),
                "sum_x2": float((data ** 2).sum())}

    def posterior_update(self, prior: dict, data: np.ndarray) -> tuple:
        stats = self.sufficient_stat(data)
        alpha = prior.get("alpha", 2.0) + stats["sum_x"]
        beta = prior.get("beta", 2.0) + stats["n"] - stats["sum_x"]
        return alpha, beta

    def posterior_ic(self, alpha: float, beta: float, level: float = 0.95) -> tuple:
        lo = (1 - level) / 2
        hi = 1 - lo
        return (float(beta_dist.ppf(lo, alpha, beta)),
                float(beta_dist.ppf(hi, alpha, beta)))

    def wald_test(self, theta_hat: float, n: int, theta0: float,
                  alpha: float = 0.05) -> dict:
        se = np.sqrt(theta_hat * (1 - theta_hat) / n)
        z = (theta_hat - theta0) / se
        p = 1 - norm.cdf(z)
        return {"z": float(z), "p_value": float(p),
                "reject": bool(p < alpha),
                "decision": "tratar" if p < alpha else "no tratar"}


@dataclass
class WaldProblem:
    r"""Cuádrupla de Wald $(\Theta, \mathcal{A}, \mathcal{X}, L)$.

    Por defecto modela el caso Bernoulli: θ ∈ [0,1] es la prevalencia,
    A = {0=no tratar, 1=tratar}, X ∈ {0,1}^{n}, L asimétrica.
    """
    theta_space: np.ndarray = None  # Θ
    action_space: tuple = (0, 1)    # A
    cost_treat: float = 0.2         # costo de tratar innecesariamente
    cost_skip: float = 1.0          # costo de NO tratar a un enfermo
    distribution: object = None     # Distribution protocol

    def __post_init__(self):
        if self.theta_space is None:
            self.theta_space = np.linspace(0.001, 0.999, 200)
        if self.distribution is None:
            self.distribution = BernoulliDistribution()

    # -- función de pérdida L(θ, a) --
    def loss(self, theta: float | np.ndarray, a: int) -> float | np.ndarray:
        """L(θ, a) asimétrica:
            a=1 (tratar):   (1-θ) · c     # tratamiento innecesario
            a=0 (no tratar): θ · d          # falso negativo
        """
        c, d = self.cost_treat, self.cost_skip
        if a == 1:
            return (1.0 - theta) * c
        return theta * d

    def risk(self, theta: float, delta: Callable) -> float:
        """Evaluación puntual L(θ, f(θ)) de un mapa indexado por θ.

        NO es el riesgo de Wald R(θ,δ) = E_X[L(θ, δ(X))]: aquí no hay
        observación ni esperanza sobre P_θ. El riesgo estadístico real,
        integrado sobre la observación, está en
        `representation.risk_statistical`. Se conserva por compatibilidad
        con el demo clairvidente (D9, 2026-11-03).
        """
        a_star = delta(theta)
        return self.loss(theta, a_star)


# ---------------------------------------------------------------------------
# Reglas de decisión
# ---------------------------------------------------------------------------
def bayes_rule(alpha: float, beta: float, problem: WaldProblem) -> int:
    """Regla de Bayes δ^* que minimiza el riesgo posterior esperado.

    $\\delta^\\pi = \\arg\\min_a \\E_{\\theta|X}[L(\\theta, a)]$.

    Para L asimétrica con costos (c, d), el umbral es θ* = c/(c+d):
        δ^* = 1  si  E[θ|X] > c/(c+d),  else 0.
    """
    theta_post_mean = alpha / (alpha + beta)  # media posterior Beta
    threshold = problem.cost_treat / (problem.cost_treat + problem.cost_skip)
    return int(theta_post_mean > threshold)


def minimax_rule(alpha: float, beta: float, problem: WaldProblem) -> int:
    """Regla minimax: minimiza el peor riesgo sobre Θ.

    Resuelve δ_minimax = argmin_{a ∈ {0,1}} max_{θ ∈ Θ} L(θ, a)
    evaluando numéricamente el peor riesgo sobre la grilla theta_space.

    Para L asimétrica:
    - a=1: max_θ L(θ,1) = max_θ (1-θ)·c = c (en θ=0)
    - a=0: max_θ L(θ,0) = max_θ θ·d = d (en θ=1)

    La regla minimax elige la acción con menor peor pérdida.
    """
    theta_grid = (problem.theta_space
                  if problem.theta_space is not None
                  else np.linspace(0.001, 0.999, 200))

    worst_loss = {}
    for a in problem.action_space:
        worst_loss[a] = max(problem.loss(float(theta), a) for theta in theta_grid)

    return int(min(worst_loss, key=worst_loss.get))


def posterior_ic(alpha: float, beta: float, level: float = 0.95) -> tuple:
    """IC del (1-α) para θ a partir del posterior Beta(α,β)."""
    lo = (1 - level) / 2
    hi = 1 - lo
    return (float(beta_dist.ppf(lo, alpha, beta)),
            float(beta_dist.ppf(hi, alpha, beta)))


def wald_test(theta_hat: float, n: int, theta0: float, alpha: float = 0.05) -> dict:
    """Test UMP unilateral H_0: θ ≤ θ_0 vs H_1: θ > θ_0 (Wald, score)."""
    se = np.sqrt(theta_hat * (1 - theta_hat) / n)
    z = (theta_hat - theta0) / se
    p = 1 - norm.cdf(z)
    return {"z": float(z), "p_value": float(p),
            "reject": bool(p < alpha), "decision": "tratar" if p < alpha else "no tratar"}
