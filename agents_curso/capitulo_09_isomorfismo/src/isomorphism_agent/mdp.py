"""
MDP — Proceso de Decisión de Markov $(\\mathcal{S}, \\mathcal{A}, P, r, \\gamma)$.

Definición 9.2. Implementa Value Iteration (operador de Bellman como
contracción) y Policy Iteration con sus garantías de convergencia
$L_\\infty$ (Teoremas del Capítulo 8).
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional
import numpy as np


@dataclass
class MDP:
    """Quíntupla $\\mathcal{M} = (\\mathcal{S}, \\mathcal{A}, P, r, \\gamma)$."""
    S: list
    A: list
    P: np.ndarray   # shape (|S|, |A|, |S|)
    r: np.ndarray   # shape (|S|, |A|)
    gamma: float

    def __post_init__(self):
        assert self.P.shape == (len(self.S), len(self.A), len(self.S))
        assert self.r.shape == (len(self.S), len(self.A))
        assert 0 <= self.gamma <= 1
        # verificar que P sea un kernel estocástico
        np.testing.assert_allclose(self.P.sum(axis=-1), 1.0, atol=1e-9)

    # -- operador de Bellman (contracción módulo γ) --
    def bellman_update(self, V: np.ndarray) -> np.ndarray:
        """$T V(s) = \\max_a [r(s,a) + \\gamma \\sum_{s'} P(s'|s,a) V(s')]$."""
        Q = self.r + self.gamma * np.einsum('sas,s->sa', self.P, V)
        return Q.max(axis=1)

    def bellman_q(self, V: np.ndarray) -> np.ndarray:
        """Q(s,a) asociado al update."""
        return self.r + self.gamma * np.einsum('sas,s->sa', self.P, V)


def value_iteration(mdp: MDP, tol: float = 1e-10, max_iter: int = 10000,
                    return_history: bool = False):
    """Value Iteration. Convergencia geométrica con tasa γ (Puterman Thm 6.3.1).

    Devuelve V* (y opcionalmente la historia de ||V_{k+1}-V_k||).
    """
    V = np.zeros(len(mdp.S))
    history = []
    for k in range(max_iter):
        V_new = mdp.bellman_update(V)
        err = np.abs(V_new - V).max()
        history.append(err)
        V = V_new
        if err < tol:
            break
    if return_history:
        return V, np.array(history)
    return V


def optimal_policy(mdp: MDP, V: Optional[np.ndarray] = None) -> np.ndarray:
    """$\\pi^*(s) = \\arg\\max_a Q^*(s,a)$."""
    if V is None:
        V = value_iteration(mdp)
    Q = mdp.bellman_q(V)
    return Q.argmax(axis=1)


def policy_evaluation(mdp: MDP, pi: np.ndarray, tol: float = 1e-10,
                      max_iter: int = 10000) -> np.ndarray:
    """$V^\\pi$ resuelto como sistema lineal V = r^π + γ P^π V."""
    S = len(mdp.S)
    r_pi = np.array([mdp.r[s, pi[s]] for s in range(S)])
    P_pi = np.array([mdp.P[s, pi[s], :] for s in range(S)])
    V = np.zeros(S)
    for _ in range(max_iter):
        V_new = r_pi + mdp.gamma * P_pi @ V
        if np.abs(V_new - V).max() < tol:
            break
        V = V_new
    return V
