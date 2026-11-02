"""
losses.py — Wald loss matrix utilities for credit approval.

The loss matrix is the asymmetric cost matrix from the Statlog German
Credit dataset: classifying a bad applicant as good costs 5x more than
classifying a good applicant as bad.
"""
from typing import Dict
import numpy as np
from config import LOSS, ACTIONS


def loss(theta: str, action: str) -> float:
    """Wald loss L(theta, a). theta in {'good','bad'}, action in ACTIONS."""
    return LOSS[(theta, action)]


def expected_loss(p_bad: float, action: str) -> float:
    """
    Expected loss under a Bernoulli belief P(bad) = p_bad.

        E[L | a] = p_bad * L(bad, a) + (1 - p_bad) * L(good, a)
    """
    return p_bad * loss("bad", action) + (1.0 - p_bad) * loss("good", action)


def worst_case_loss(p_lo: float, p_hi: float, action: str) -> float:
    """
    Minimax loss: sup_{p in [p_lo, p_hi]} E[L | p, a].

    Since E[L | p, a] is linear in p, the supremum is attained at one of
    the endpoints of the credibility interval.
    """
    return max(expected_loss(p_lo, action),
               expected_loss(p_hi, action))


def bayes_threshold() -> float:
    """
    Closed-form Bayes threshold for {accept, reject}:

        reject  if  E[L|reject] < E[L|accept]
                <=> L(good, reject)(1 - p) < L(bad, accept) * p
                <=> p > L(good, reject) / (L(good, reject) + L(bad, accept))

    For Statlog (L(good,reject)=1, L(bad,accept)=5) this gives 1/6 ~ 0.167.
    """
    num = loss("good", "reject")
    den = loss("good", "reject") + loss("bad", "accept")
    return num / den


def risk_per_action(p_bad: float) -> Dict[str, float]:
    """Bayes risk for each action under belief p_bad."""
    return {a: expected_loss(p_bad, a) for a in ACTIONS}


def minimax_risk_per_action(p_lo: float, p_hi: float) -> Dict[str, float]:
    """Minimax risk for each action under credibility interval [p_lo, p_hi]."""
    return {a: worst_case_loss(p_lo, p_hi, a) for a in ACTIONS}
