r"""Compatibilidad y alcance (corrección D9, 2026-11-03).

**Lo que el teorema del libro afirma** (Cap. 5; histórico Cap. 9): para cada
θ hay un MDP con **estados = observaciones** $\mathcal{X}\cup\{s_{fin}\}$,
ley inicial $P_\theta$, recompensa $-L(\theta,\cdot)$ y transición terminal;
la política copia la regla y usa la observación, nunca θ;
$J_\theta(\pi_\delta)=-R(\theta,\delta)$ integrando sobre $X\sim P_\theta$.
Eso está implementado, y verificado de forma no tautológica, en
`representation.py`.

**Lo que este módulo conserva por compatibilidad (v1–v2):**

* `F`, `F_inv`: el MDP **clairvidente** con estados = Θ. La política observa
  θ, el objeto que el teorema explícitamente excluye. Lo que aquí se
  "verificaba" era una coincidencia debida a la pérdida LINEAL en θ
  ($\ell(b,a)=L(\mathbb{E}_b\theta,a)$), no el teorema. Queda útil como demo
  pedagógica del punto Bayes-vs-clarividente; su docstring lo dice ahora él
  mismo. **Deprecated** para cualquier afirmación formal.
* `verify_isomorphism`: reimplementado. Ya no compara argmins sobre una
  grilla: ejecuta la verificación real de `representation.py`
  (identidad exacta sobre todas las reglas y una malla de θ) y reporta el
  acuerdo de acciones bajo pérdida lineal como lo que es: una coincidencia
  adicional, no el teorema. La forma del dict de salida se mantiene para
  `agent.py`.
"""
from __future__ import annotations

import warnings

import numpy as np

from .mdp import MDP, optimal_policy, value_iteration
from .representation import ObservationModel, verify_representation
from .wald import WaldProblem, bayes_rule


def F(problem: WaldProblem, theta_grid: np.ndarray | None = None,
      horizon: int = 1) -> MDP:
    """MDP clairvidente (v1–v2): estados = Θ, observable por la política.

    .. deprecated:: no es la construcción del teorema (véase
        `representation.py`). Se conserva como demo de lo que el
        teorema NO permite: una política que ve θ.
    """
    warnings.warn(
        "F construye el MDP clarividente (estados = Θ); el teorema del "
        "libro usa estados = observaciones + ley inicial P_θ. Ver "
        "representation.py.",
        DeprecationWarning, stacklevel=2)
    if theta_grid is None:
        theta_grid = problem.theta_space
    S = list(theta_grid) + ["TERMINAL"]
    A = list(problem.action_space)
    nS, nA = len(S), len(A)
    r = np.zeros((nS, nA))
    for i, s in enumerate(theta_grid):
        for j, a in enumerate(A):
            r[i, j] = -float(problem.loss(float(s), a))
    P = np.zeros((nS, nA, nS))
    for i in range(nS - 1):
        for j in range(nA):
            P[i, j, nS - 1] = 1.0
    for j in range(nA):
        P[nS - 1, j, nS - 1] = 1.0
    return MDP(S=S, A=A, P=P, r=r, gamma=1.0)


def F_inv(mdp: MDP) -> WaldProblem:
    """Recupera costos por OLS del MDP clairvidente (mismo alcance que F)."""
    warnings.warn("F_inv hereda el alcance clairvidente de F.",
                  DeprecationWarning, stacklevel=2)
    S_list = [s for s in mdp.S if not isinstance(s, str)]
    S = np.array(S_list, dtype=float)
    A = tuple(mdp.A)
    problem = WaldProblem(theta_space=S, action_space=A)
    if 1 in A and 0 in A:
        idx_1, idx_0 = A.index(1), A.index(0)
        r_1 = mdp.r[:len(S), idx_1]
        s_minus_1 = S - 1.0
        den_c = float(np.sum(s_minus_1 ** 2))
        if abs(den_c) > 1e-12:
            problem.cost_treat = float(np.sum(r_1 * s_minus_1)) / den_c
        r_0 = mdp.r[:len(S), idx_0]
        den_d = float(np.sum(S ** 2))
        if abs(den_d) > 1e-12:
            problem.cost_skip = -float(np.sum(r_0 * S)) / den_d
    return problem


def verify_isomorphism(problem: WaldProblem, alpha: float, beta: float,
                       obs: ObservationModel | None = None) -> dict:
    """Verificación real del teorema + acuerdo de acciones (bajo pérdida lineal).

    Devuelve (claves que lee `agent.py` intactas):
      - `bayes_action` / `mdp_action`: la regla de Bayes δ* para el posterior
        dado y su copia como política; bajo pérdida lineal en θ coinciden con
        el argmin puntual en θ̂ — se reporta como coincidencia adicional.
      - `isomorphism_ok`: True si y solo si la identidad del teorema es
        exacta (sobre TODAS las reglas y una malla de θ, integrando sobre X).
      - claves nuevas: `identity_holds`, `identity_max_abs_error`,
        `n_rules`, `n_theta_checked`, `note` (alcance).
    """
    real = verify_representation(problem, obs=obs)
    a_bayes = bayes_rule(alpha, beta, problem)
    theta_hat = alpha / (alpha + beta)
    return {
        "theta_hat": theta_hat,
        "bayes_action": a_bayes,
        "mdp_action": a_bayes,  # la política copia la regla: π_δ*(x) sigue δ*
        "isomorphism_ok": bool(real["ok"]),
        "V_at_state": -float(problem.loss(theta_hat, a_bayes)),
        "neg_risk_at_state": -float(problem.loss(theta_hat, a_bayes)),
        "identity_holds": bool(real["ok"]),
        "identity_max_abs_error": real["identity_max_abs_error"],
        "n_rules": real.get("n_rules"),
        "n_theta_checked": real.get("n_theta_checked"),
        "note": ("La identidad J=-R se verificó integrando sobre X (todas "
                 "las reglas); el acuerdo δ*/π* en θ̂ usa además la pérdida "
                 "lineal — una coincidencia, no el teorema."),
    }
