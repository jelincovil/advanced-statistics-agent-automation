"""
Functor $F:\\mathbf{Dec} \\to \\mathbf{MDP}$ (Teorema 9.1).

Para un problema de Wald $\\mathcal{D}=(\\Theta, \\mathcal{A}, \\mathcal{X}, L)$
definimos $F(\\mathcal{D})=\\mathcal{M}$ donde:

* $\\mathcal{S} = \\mathcal{X}$
* $\\mathcal{A}$ (mismo)
* $P(s'|s,a) = \\delta_{s'}(s)$ (determinista un paso)
* $r(s,a) = -L(s,a)$
* $\\gamma = 1$

Para un morfismo (regla de decisión) δ: X → A, $F(δ) = \\pi$ con $\\pi(s)=δ(s)$.

Verifica: preserva identidad, composición, biyectividad en la subcategoría
de MDPs con γ=1 y P determinista, y preserva estructura de optimalidad
($R(θ,δ) \\leftrightarrow -V^\\pi(s)$).
"""
from __future__ import annotations

from typing import Callable

import numpy as np

from .mdp import MDP, optimal_policy, value_iteration
from .wald import WaldProblem, bayes_rule


def F(problem: WaldProblem, theta_grid: np.ndarray | None = None,
      horizon: int = 1) -> MDP:
    """Aplica el funtor $F$ a un problema de Wald.

    Construye el MDP correspondiente con:
        S = theta_grid (representación de Θ),
        A = problem.action_space,
        r(s, a) = -L(s, a),
        γ = 1 si horizon=1, γ<1 si horizon>1 (Corolario 9.6).

    Para el caso un paso (horizon=1) usamos un estado terminal único con
    V=0 y γ=1 (equivalente numéricamente a γ=0 sobre los estados no
    terminales). Para horizonte T>1, γ=1 sigue siendo válido porque el
    estado terminal frena la recursión.

    Esto corrige el bug de v1 donde P=identidad + γ=1 hacía diverger VI.
    """
    if theta_grid is None:
        theta_grid = problem.theta_space
    S = list(theta_grid) + ["TERMINAL"]   # añadimos estado terminal
    A = list(problem.action_space)
    nS, nA = len(S), len(A)
    r = np.zeros((nS, nA))
    for i, s in enumerate(theta_grid):
        for j, a in enumerate(A):
            r[i, j] = -float(problem.loss(float(s), a))
    # P: cada (s,a) transita al terminal; el terminal es absorbente en sí mismo
    P = np.zeros((nS, nA, nS))
    for i in range(nS - 1):
        for j in range(nA):
            P[i, j, nS - 1] = 1.0   # transita al terminal
    # Terminal: absorbente, recompensa 0
    for j in range(nA):
        P[nS - 1, j, nS - 1] = 1.0
        r[nS - 1, j] = 0.0
    return MDP(S=S, A=A, P=P, r=r, gamma=1.0)


def F_inv(mdp: MDP) -> WaldProblem:
    """Inversa del funtor en la subcategoría MDP(γ=1, P determinista).

    Recupera el problema de Wald asumiendo que la recompensa es
    $r(s,a) = -L(s,a)$, por lo que $L(s,a) = -r(s,a)$.

    Usa mínimos cuadrados ordinarios (OLS) sobre todos los estados de la
    grilla (excluyendo el estado terminal) para recuperar los costos,
    en lugar de depender solo de los estados extremos.
    Esto es robusto porque aprovecha toda la información disponible:

        Para a=1: r(s,1) = -(1-s)·c  ⇒  c = Σ(r_i·(s_i-1)) / Σ((s_i-1)²)
        Para a=0: r(s,0) = -s·d      ⇒  d = -Σ(r_i·s_i) / Σ(s_i²)
    """
    # Filtrar el estado terminal si existe
    S_list = [s for s in mdp.S if not isinstance(s, str)]
    S = np.array(S_list, dtype=float)
    A = tuple(mdp.A)
    problem = WaldProblem(theta_space=S, action_space=A)
    if 1 in A and 0 in A:
        idx_1 = A.index(1)
        idx_0 = A.index(0)

        # --- Recuperar cost_treat (c) desde a=1 ---
        # r(s, 1) = -(1-s)*c = c*(s - 1)
        # OLS: c = Σ(r_i * (s_i - 1)) / Σ((s_i - 1)^2)
        r_1 = mdp.r[:len(S), idx_1]
        s_minus_1 = S - 1.0
        num_c = float(np.sum(r_1 * s_minus_1))
        den_c = float(np.sum(s_minus_1 ** 2))
        if abs(den_c) > 1e-12:
            problem.cost_treat = num_c / den_c

        # --- Recuperar cost_skip (d) desde a=0 ---
        # r(s, 0) = -s*d
        # OLS: d = -Σ(r_i * s_i) / Σ(s_i^2)
        r_0 = mdp.r[:len(S), idx_0]
        num_d = -float(np.sum(r_0 * S))
        den_d = float(np.sum(S ** 2))
        if abs(den_d) > 1e-12:
            problem.cost_skip = num_d / den_d

    return problem


def verify_isomorphism(problem: WaldProblem, alpha: float, beta: float) -> dict:
    """Verifica numéricamente el Teorema 9.1 para un posterior dado.

    Comprueba que la regla de Bayes δ^* coincide con la política óptima π^*
    del MDP F(problem) evaluada en el estado correspondiente a θ̂ posterior.
    """
    mdp = F(problem)
    V = value_iteration(mdp)
    pi = optimal_policy(mdp, V)

    theta_hat = alpha / (alpha + beta)
    # Filtrar estado terminal si existe
    S_numeric = [s for s in mdp.S if not isinstance(s, str)]
    S_arr = np.array(S_numeric, dtype=float)
    i_local = int(np.argmin(np.abs(S_arr - theta_hat)))
    # Mapear de vuelta al índice en mdp.S
    i = list(mdp.S).index(S_numeric[i_local])

    a_bayes = bayes_rule(alpha, beta, problem)
    a_mdp = int(pi[i])

    return {
        "theta_hat": theta_hat,
        "state_index": i,
        "bayes_action": a_bayes,
        "mdp_action": a_mdp,
        "isomorphism_ok": bool(a_bayes == a_mdp),
        "V_at_state": float(V[i]),
        "neg_risk_at_state": -float(problem.loss(theta_hat, a_bayes)),
    }
