"""
state.py — StateSchema for the Wald decision agent.

The state is the "sufficient statistic" of the agent's belief about
the current applicant. Every node consumes a state and returns a
(partial) state update; LangGraph merges them automatically.
"""
from typing import TypedDict, Optional
import numpy as np


class AgentState(TypedDict, total=False):
    # --- Input ----------------------------------------------------------
    applicant_id: int
    x: np.ndarray            # feature vector (already preprocessed)
    y_true: Optional[str]    # ground truth ('good'/'bad') if available

    # --- Posterior over theta = P(bad | x) ------------------------------
    p_hat: float             # posterior mean
    alpha: float             # Beta(alpha, beta) posterior
    beta:  float
    entropy_norm: float      # normalised posterior entropy in [0, 1]

    # --- Risk per action ------------------------------------------------
    bayes_risk:   dict       # {action -> E_{theta|x}[L(theta, a)]}
    minimax_risk: dict       # {action -> sup_{theta in CR} L(theta, a)}

    # --- Decision -------------------------------------------------------
    bayes_action:    str     # argmin of bayes_risk
    minimax_action:  str     # argmin of minimax_risk
    chosen_action:   str     # what the meta-selector picked
    rule_used:       str     # 'bayes' | 'minimax' | 'escalate'
    realised_loss:   Optional[float]
