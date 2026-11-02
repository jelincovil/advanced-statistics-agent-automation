"""
test_sanity.py — Statistical sanity checks for the Wald agent.

Run with:    python -m pytest tests/ -v
Or simply:   python tests/test_sanity.py
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import numpy as np

from agent.losses import (
    bayes_threshold, expected_loss, worst_case_loss,
    risk_per_action, minimax_risk_per_action,
)
from agent.nodes import (
    riesgo_bayes, riesgo_minimax, meta_selector,
    _moment_match_beta,
)


def test_bayes_threshold_matches_closed_form():
    """L(good,reject)=1, L(bad,accept)=5  =>  threshold = 1/6."""
    assert abs(bayes_threshold() - 1.0/6.0) < 1e-9


def test_bayes_rule_decision_boundary():
    """
    For p_bad just below 1/6, Bayes should accept.
    For p_bad just above 1/6, Bayes should reject.
    """
    a, b = _moment_match_beta(0.15, 30.0)
    state = {"p_hat": 0.15, "alpha": a, "beta": b}
    out = riesgo_bayes(state)
    assert out["bayes_action"] == "accept"

    a, b = _moment_match_beta(0.20, 30.0)
    state = {"p_hat": 0.20, "alpha": a, "beta": b}
    out = riesgo_bayes(state)
    assert out["bayes_action"] == "reject"


def test_minimax_is_more_conservative_than_bayes():
    """
    For applicants whose posterior mean is near (just below) the Bayes
    threshold, the minimax rule should reject more often than the Bayes
    rule. Equivalently: the minimax rejection set contains the Bayes
    rejection set.
    """
    bayes_rejects = 0
    minimax_rejects = 0
    for p in np.linspace(0.05, 0.30, 200):
        a, b = _moment_match_beta(p, 30.0)
        state = {"p_hat": p, "alpha": a, "beta": b}
        if riesgo_bayes(state)["bayes_action"] == "reject":
            bayes_rejects += 1
        if riesgo_minimax(state)["minimax_action"] == "reject":
            minimax_rejects += 1
    assert minimax_rejects >= bayes_rejects


def test_meta_selector_escalates_under_disagreement_and_high_entropy():
    """
    Construct a state with high entropy and a contrived disagreement
    between the two rules. The meta-selector should escalate.
    """
    state = {
        "entropy_norm":   0.95,
        "bayes_action":   "accept",
        "minimax_action": "reject",
    }
    out = meta_selector(state)
    assert out["rule_used"] == "escalate"
    assert out["chosen_action"] == "escalate"


def test_meta_selector_uses_bayes_when_certain():
    """Low entropy + agreement => trust Bayes."""
    state = {
        "entropy_norm":   0.10,
        "bayes_action":   "accept",
        "minimax_action": "accept",
    }
    out = meta_selector(state)
    assert out["rule_used"] == "bayes"
    assert out["chosen_action"] == "accept"


def test_risk_linearity_in_p():
    """E[L|p,a] is linear in p; verify at the midpoint."""
    p_lo, p_hi = 0.1, 0.4
    p_mid = 0.5 * (p_lo + p_hi)
    for a in ["accept", "reject", "escalate"]:
        lin = 0.5 * (expected_loss(p_lo, a) + expected_loss(p_hi, a))
        assert abs(expected_loss(p_mid, a) - lin) < 1e-12


def test_worst_case_at_endpoints():
    """Linearity in p implies the max over [p_lo, p_hi] is at an endpoint."""
    p_lo, p_hi = 0.05, 0.50
    for a in ["accept", "reject", "escalate"]:
        wc = worst_case_loss(p_lo, p_hi, a)
        assert wc == max(expected_loss(p_lo, a), expected_loss(p_hi, a))


def _run_all():
    tests = [v for k, v in globals().items() if k.startswith("test_")]
    failed = []
    for t in tests:
        try:
            t()
            print(f"  OK  {t.__name__}")
        except AssertionError as e:
            failed.append(t.__name__)
            print(f"  FAIL {t.__name__}: {e}")
    print(f"\n{len(tests) - len(failed)}/{len(tests)} tests passed.")
    return 0 if not failed else 1


if __name__ == "__main__":
    sys.exit(_run_all())
