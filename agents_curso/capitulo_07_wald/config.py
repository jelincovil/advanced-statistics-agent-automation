"""
config.py — Central configuration for the Wald credit-decision agent.

ALL tunable parameters live here so that adapting the agent to a local
setup means editing a single file.
"""
from pathlib import Path

# --- Paths ----------------------------------------------------------------
ROOT       = Path(__file__).parent.resolve()
DATA_PATH  = ROOT / "data" / "german_credit.csv"

# --- Reproducibility ------------------------------------------------------
SEED = 42

# --- Wald loss matrix (Statlog convention) --------------------------------
# Rows are true class, columns are action.
# L(good, accept) = 0
# L(bad,  accept) = 5    <-- 5x more costly than a wrongful rejection
# L(good, reject) = 1
# L(bad,  reject) = 0
# Action "escalate" sends the application to a human analyst at a fixed
# operational cost (independent of the true class).
LOSS = {
    ("good", "accept"):   0.0,
    ("bad",  "accept"):   5.0,
    ("good", "reject"):   1.0,
    ("bad",  "reject"):   0.0,
    # Escalate cost is set so that it is strictly DOMINATED by the better
    # of {accept, reject} for every p in [0,1]. This guarantees that pure
    # Bayes and pure minimax never pick 'escalate'; only the meta-selector
    # can trigger escalation, based on posterior entropy and rule
    # disagreement. (For Statlog: max p of min(5p, 1-p) is at p=1/6 with
    # value 5/6 ~ 0.833, so any cost > 5/6 works; 1.5 leaves a safe margin.)
    ("good", "escalate"): 1.5,
    ("bad",  "escalate"): 1.5,
}
ACTIONS = ["accept", "reject", "escalate"]

# --- Posterior concentration -----------------------------------------------
# We treat the logistic-regression output p_hat(bad|x) as the posterior
# mean of theta = P(bad|x), and place a Beta(alpha, beta) posterior with
# concentration kappa = alpha + beta. Larger kappa => sharper posterior.
# kappa = sqrt(n_train) roughly mimics the rate at which empirical Bayes
# would concentrate.
POSTERIOR_KAPPA = 5.0    # Baja concentración -> más entropía -> el meta-selector se activa
                           # (kappa=30 lo desactiva completamente; 5 revela la meta-selección)

# --- Meta-selector thresholds ---------------------------------------------
# The meta-selector switches between the Bayes rule and the minimax rule
# based on posterior entropy of theta. High entropy => high epistemic
# uncertainty => use minimax (robust). Low entropy => use Bayes.
# Beta entropy maxes out at ~log(B(a,b)) for a=b small. We normalise.
ENTROPY_THRESHOLD = 0.45     # in [0, 1]; above this -> minimax
                           # Bajado de 0.55 para que con kappa=5 veamos más minimax

# Credibility level for the minimax worst-case interval.
MINIMAX_CRED_LEVEL = 0.90

# Escalate to a human when the chosen rule disagrees with the alternative
# AND posterior entropy exceeds this (stricter) threshold.
ESCALATE_ENTROPY_THRESHOLD = 0.65  # Bajado para ver escalaciones con kappa=5

# --- Train/test split -----------------------------------------------------
TEST_SIZE = 0.20
