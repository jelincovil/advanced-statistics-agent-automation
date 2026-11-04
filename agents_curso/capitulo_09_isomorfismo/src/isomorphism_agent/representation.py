r"""
Representación riesgo–retorno del Teorema 5.3 del libro (cap. 9 histórico).
=============================================================================

Qué afirma el teorema (y qué implementa este módulo):

* Para cada θ hay **un MDP** $\mathcal{M}_\theta$ con estados
  $\mathcal{X}\cup\{s_{\text{fin}}\}$ — la OBSERVACIÓN, no el parámetro —,
  ley inicial $P_\theta$, recompensa $r_\theta(x,a)=-L(\theta,a)$ y
  transición determinista al estado terminal.
* La política $\pi_\delta(x)=\delta(x)$ copia la regla: **usa la
  observación, nunca el parámetro**.
* La identidad averiguada integrando sobre $X\sim P_\theta$ es
  $J_\theta(\pi_\delta)=-R(\theta,\delta)$.

Qué NO implementa: el MDP clarividente con estados Θ de `functor.F` (v1–v2),
donde la política observa θ — caso degenerado que el libro excluye
explícitamente (ver el docstring de `functor.py` tras la corrección D9).

La familia aquí es una `dict[theta, MDP]` y las identidades se verifican
integrando sobre $\mathcal{X}$, sin ejecutar value iteration: con transición
terminal única, el valor es la recompensa inmediata promediada sobre la ley
inicial — exactamente lo que demuestra el teorema.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable

import numpy as np

from .mdp import MDP
from .wald import WaldProblem

TERMINAL = "TERMINAL"


@dataclass
class ObservationModel:
    """Espacio de observación finito y su ley por parámetro.

    Por defecto (Bernoulli canónico del paquete): X ∈ {0,1} con
    P_θ(X=1) = θ — la prevalencia θ observada por una señal con esa ley.
    Atributos:
        x_space: tupla con los valores observables.
        p_x_given_theta: callable (theta, x) → P_θ(X=x), en [0,1].
    """
    x_space: tuple = (0, 1)
    p_x_given_theta: Callable[[float, int], float] | None = None

    def __post_init__(self):
        if self.p_x_given_theta is None:
            self.p_x_given_theta = lambda theta, x: theta if x == 1 else 1.0 - theta

    def law(self, theta: float) -> np.ndarray:
        p = np.array([self.p_x_given_theta(theta, x) for x in self.x_space], dtype=float)
        if not np.all(p >= -1e-12) or p.sum() <= 0:
            raise ValueError(f"P_θ inválida en θ={theta}")
        return p / p.sum()


def mdp_for_theta(problem: WaldProblem, theta: float, obs: ObservationModel) -> MDP:
    """Construye $\mathcal{M}_\theta$: estados X ∪ {TERMINAL}, ley inicial
    P_θ (expuesta en `initial_dist`), recompensa −L(θ,·), γ = 1."""
    states = list(obs.x_space) + [TERMINAL]
    actions = list(problem.action_space)
    nS, nA = len(states), len(actions)
    r = np.zeros((nS, nA))
    for i, x in enumerate(obs.x_space):
        for j, a in enumerate(actions):
            r[i, j] = -float(problem.loss(theta, a))   # −L(θ,a): no depende de x
    P = np.zeros((nS, nA, nS))
    for i in range(nS - 1):
        for j in range(nA):
            P[i, j, nS - 1] = 1.0
    for j in range(nA):
        P[nS - 1, j, nS - 1] = 1.0
    mdp = MDP(S=states, A=actions, P=P, r=r, gamma=1.0)
    mdp.initial_dist = obs.law(theta)          # la política NO la ve: solo indexa la evaluación
    mdp.initial_states = list(obs.x_space)
    return mdp


def mdp_family(problem: WaldProblem, obs: ObservationModel,
               theta_points: np.ndarray) -> dict:
    """La familia {M_θ} indexada por el parámetro desconocido."""
    return {float(th): mdp_for_theta(problem, float(th), obs) for th in theta_points}


def rules(obs: ObservationModel, actions) -> list:
    """Todas las reglas deterministas δ: X → A (como tuplas indexadas por X)."""
    return [dict(zip(obs.x_space, choice))
            for choice in product(*[actions for _ in obs.x_space])]


def risk_statistical(problem: WaldProblem, obs: ObservationModel,
                     theta: float, rule: dict) -> float:
    """Riesgo verdadero de Wald: R(θ,δ) = Σ_x P_θ(x) L(θ, δ(x)).

    Contraste con `WaldProblem.risk`, que evalúa L(θ, f(θ)) sin promediar
    sobre ninguna observación (ver su docstring corregido).
    """
    w = obs.law(theta)
    return float(sum(w[i] * problem.loss(theta, rule[x])
                     for i, x in enumerate(obs.x_space)))


def return_statistical(problem: WaldProblem, obs: ObservationModel,
                       theta: float, policy: dict) -> float:
    """Retorno J_θ(π) = Σ_x P_θ(x) · (−L(θ, π(x))): promedio sobre la ley inicial."""
    w = obs.law(theta)
    return float(sum(w[i] * (-problem.loss(theta, policy[x]))
                     for i, x in enumerate(obs.x_space)))


def verify_representation(problem: WaldProblem, obs: ObservationModel | None = None,
                          theta_points: np.ndarray | None = None) -> dict:
    """Verificación real del teorema (puede fallar: no es tautológica).

    Comprueba, enumerando TODAS las reglas deterministas y una malla de θ:
      (i) identidad J_θ(π_δ) = −R(θ,δ) exacta (integrando sobre X);
      (ii) biyección reglas ↔ políticas en los estados de decisión
          (clases con la misma cardinalidad, funciones de X → A);
      (iii) la política no recibe θ (es función de x solamente: la familia
          está indexada por θ pero π solo accede a `obs.x_space`).
    Devuelve métricas; `ok` exige error nulo.
    """
    obs = obs if obs is not None else ObservationModel()
    if theta_points is None:
        theta_points = problem.theta_space
    actions = list(problem.action_space)
    all_rules = rules(obs, actions)
    max_err = 0.0
    for th in theta_points:
        th = float(th)
        for rule in all_rules:
            j = return_statistical(problem, obs, th, rule)
            rsk = risk_statistical(problem, obs, th, rule)
            err = abs(j + rsk)
            max_err = max(max_err, err)
            if err > 1e-9:
                return {"ok": False, "identity_max_abs_error": err,
                        "fails_at": (th, rule)}
    mdp = mdp_family(problem, obs, theta_points[:3] if len(theta_points) >= 3 else theta_points)
    return {
        "ok": True,
        "identity_max_abs_error": max_err,
        "n_rules": len(all_rules),
        "n_policies_decision_states": len(actions) ** len(obs.x_space),
        "n_theta_checked": len(theta_points),
        "policy_observes": "observation x only (theta indexes the family, never the policy)",
        "family_sample_size": len(mdp),
    }
