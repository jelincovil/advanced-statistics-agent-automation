"""
nodes.py — The five functional nodes of the Wald decision agent.

Each node is a pure function:  AgentState -> AgentState (partial update).
This purity is what lets LangGraph compose them into a graph and lets us
unit-test each node in isolation.

Mapping to Chapter 7:
  observar        -> sets up X (data x in the sample space)
  posterior       -> Bayes update: produces Beta(alpha, beta) over theta
  riesgo_bayes    -> Risk function under the prior: R_bayes(a) = E[L|a]
  riesgo_minimax  -> Worst-case risk over posterior credibility region
  meta_selector   -> Picks {bayes, minimax, escalate} from entropy
"""
from __future__ import annotations
import numpy as np
from scipy.stats import beta as beta_dist
from typing import Callable

from .state import AgentState
from .losses import (
    risk_per_action, minimax_risk_per_action,
    expected_loss, loss as Lfn,
)
from config import (
    POSTERIOR_KAPPA, MINIMAX_CRED_LEVEL,
    ENTROPY_THRESHOLD, ESCALATE_ENTROPY_THRESHOLD,
    ACTIONS,
)


# --- Helpers ---------------------------------------------------------------

def _moment_match_beta(mean: float, kappa: float) -> tuple[float, float]:
    """
    Convert (posterior mean, concentration) to (alpha, beta) of Beta.
    alpha + beta = kappa, alpha / (alpha + beta) = mean.
    """
    mean = float(np.clip(mean, 1e-4, 1 - 1e-4))
    alpha = mean * kappa
    beta_ = (1.0 - mean) * kappa
    return alpha, beta_


def _normalised_beta_entropy(a: float, b: float) -> float:
    """
    Differential entropy of Beta(a,b), rescaled to ~[0, 1].

    H_max = log(B(1,1)) - 0 = 0 for Beta(1,1) = Uniform; H -> -inf as
    the Beta becomes a point mass. We rescale via 1 - exp(H_relative),
    where H_relative = H(a,b) - H(Uniform).  Uniform => 1, point mass => 0.
    """
    H = beta_dist.entropy(a, b)        # in nats; <= 0 (Uniform has H=0)
    return float(np.clip(np.exp(H), 0.0, 1.0))


# --- Node 1: observar ------------------------------------------------------

def observar(state: AgentState) -> AgentState:
    """
    Loads the feature vector x for the current applicant. In a streaming
    setting this would read from a queue; here x is already injected into
    state by the runner.
    """
    # Validation only: ensure x is present.
    if "x" not in state:
        raise ValueError("observar: state must contain 'x'.")
    return {}   # no-op update; included for graph symmetry


# --- Node 2: posterior -----------------------------------------------------

def make_posterior_node(predict_proba: Callable[[np.ndarray], float]):
    """
    Factory: closes over a trained classifier and returns the posterior node.

    predict_proba(x) -> P(bad | x) in [0, 1].

    Posterior representation: Beta(alpha, beta) with mean = p_hat and
    concentration kappa fixed by config. This is a deliberate
    approximation -- the "Laplace-Beta" trick (Cap. 1, ex. 1.4) -- and
    keeps the Wald framing exact while avoiding the cost of full
    Bayesian logistic regression.
    """
    def posterior(state: AgentState) -> AgentState:
        x = state["x"]
        p_hat = float(predict_proba(x))
        a, b = _moment_match_beta(p_hat, POSTERIOR_KAPPA)
        H = _normalised_beta_entropy(a, b)
        return {"p_hat": p_hat, "alpha": a, "beta": b, "entropy_norm": H}
    return posterior


# --- Node 3: riesgo_bayes --------------------------------------------------

def riesgo_bayes(state: AgentState) -> AgentState:
    """
    Compute Bayes risk for each action and pick the argmin.

        R_bayes(a) = E_{theta | x}[L(theta, a)] = p_hat * L(bad,a) +
                                                 (1 - p_hat) * L(good,a)

    The Bayes rule is delta_B(x) = argmin_a R_bayes(a).
    """
    risks = risk_per_action(state["p_hat"])
    best = min(risks, key=risks.get)
    return {"bayes_risk": risks, "bayes_action": best}


# --- Node 4: riesgo_minimax ------------------------------------------------

def riesgo_minimax(state: AgentState) -> AgentState:
    """
    Compute the worst-case risk for each action over the posterior
    credibility interval, then pick the argmin (minimax rule).

    The credibility interval is the central (MINIMAX_CRED_LEVEL) interval
    of Beta(alpha, beta).
    """
    a, b = state["alpha"], state["beta"]
    lo = (1.0 - MINIMAX_CRED_LEVEL) / 2.0
    hi = 1.0 - lo
    p_lo = float(beta_dist.ppf(lo, a, b))
    p_hi = float(beta_dist.ppf(hi, a, b))
    risks = minimax_risk_per_action(p_lo, p_hi)
    best = min(risks, key=risks.get)
    return {"minimax_risk": risks, "minimax_action": best}


# --- Node 5: meta_selector -------------------------------------------------

def meta_selector(state: AgentState) -> AgentState:
    """
    Pick between Bayes, minimax, and human escalation based on posterior
    entropy and rule agreement.

    Logic:
      * Low entropy             -> trust Bayes (efficient).
      * High entropy            -> use minimax (robust).
      * Very high entropy AND   -> escalate to human analyst.
        rules disagree
    """
    H        = state["entropy_norm"]
    a_bayes  = state["bayes_action"]
    a_minmax = state["minimax_action"]

    if H >= ESCALATE_ENTROPY_THRESHOLD and a_bayes != a_minmax:
        return {"chosen_action": "escalate", "rule_used": "escalate"}
    if H >= ENTROPY_THRESHOLD:
        return {"chosen_action": a_minmax, "rule_used": "minimax"}
    return {"chosen_action": a_bayes, "rule_used": "bayes"}


# --- Optional: realised-loss bookkeeping (off-graph) -----------------------

def realise_loss(state: AgentState) -> AgentState:
    """Compute the realised loss against ground truth, if available."""
    if state.get("y_true") is None:
        return {}
    return {"realised_loss": Lfn(state["y_true"], state["chosen_action"])}
