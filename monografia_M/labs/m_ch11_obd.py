"""Case study (cap. 11): off-policy evaluation on real logged bandit data —
Open Bandit Dataset subsamples bundled with the obp sdist (zr-obp 0.5.7).

Protocol executed exactly as Chapter 10 requires:
  estimand declared first; independent unit; conditions BY DESIGN verified in
  the data where possible (recorded propensities, exact overlap); conditions
  that only have diagnostic support declared as such; proportional
  conclusions.

Experiment: campaign `all` (10,000 logged rounds per behavior policy).
  - behavior b = `random` (uniform over 80 items; recorded propensity 1/80).
  - reward R = click in {0,1}; position retained as part of the mechanism
    (the target policy intervenes on the ITEM, not on the position: this is
    stated as the intervention).
  - target e = epsilon-greedy (eps=0.5) on the argmax of a click model fitted
    on the SEPARATE `bts` campaign log (so the target is frozen before any
    evaluation data is seen). Ratio bound C = 0.50625/0.0125 = 40.5, known by
    construction, never estimated.
Estimators on the random log: DM, IS (true recorded weights), DR (2-fold
  cross-fitted logistic regressions), plus the mixture Hoeffding confidence
  sequence of Chapter 8 (C = 40.5, true weights).
Reports printed as JSON lines; every figure feeds Chapter 11 tables.
"""
import json
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression

GRID = np.exp(np.linspace(-3.5, 3.5, 161))
ALPHA = 0.05
DATA = Path(__file__).resolve().parent / "data_obd"


def load():
    rnd = pd.read_csv(f"{DATA}/random/all/all.csv").sample(frac=1.0, random_state=7).reset_index(drop=True)
    bts = pd.read_csv(f"{DATA}/bts/all/all.csv")
    items = pd.read_csv(f"{DATA}/random/all/item_context.csv")
    return rnd, bts, items


def build_features(df, items, pos_levels):
    """Design matrix: logged row = (context affinity floats, position, item features)."""
    n = len(df)
    aff_cols = [c for c in df.columns if c.startswith("user-item_affinity_")]
    pos = pd.get_dummies(df["position"], prefix="pos").astype(float)
    pos = pos.reindex(columns=[f"pos_{p}" for p in pos_levels], fill_value=0.0)
    X = np.hstack([df[aff_cols].to_numpy(float), pos.to_numpy()])
    it = items.set_index("item_id").sort_index()
    it = pd.concat(
        [it[["item_feature_0"]].astype(float),
         pd.get_dummies(it[["item_feature_1", "item_feature_2", "item_feature_3"]]).astype(float)],
        axis=1)
    item_feat = it.to_numpy(float)
    weig = item_feat[df["item_id"].to_numpy()]
    Xlog = np.hstack([X, weig])
    return X, pos.to_numpy(), item_feat, Xlog


def fit_click(Xlog, y, seed):
    clf = LogisticRegression(max_iter=2000, C=1.0, random_state=seed)
    clf.fit(Xlog, y)
    return clf


def policy_probs(clf, Xbase, pos_block, item_feat, n_items, e_greedy=0.5):
    """e-greedy around argmax predicted click-prob: returns (argmax, e(a*), e(other), probs).
    Xbase already carries the position columns: blocks are [context, item features]."""
    blocks = [np.hstack([Xbase, np.tile(item_feat[a], (len(Xbase), 1))]) for a in range(n_items)]
    probs = np.column_stack([clf.predict_proba(b)[:, 1] for b in blocks])
    star = probs.argmax(axis=1)
    n = len(Xbase)
    e_star = 1 - e_greedy + e_greedy / n_items
    e_other = e_greedy / n_items
    return star, e_star, e_other, probs


def dr_estimate(Y, star, e_star, e_other, b_prop, click_hat_all, clicks):
    """One-decision DR with cross-fitted regression (models given)."""
    n = len(Y)
    a = Y["item_id"].to_numpy()
    r = Y["click"].to_numpy(float)
    e_a = np.where(a == star, e_star, e_other)
    w = e_a / b_prop
    m_hat_rows = click_hat_all[np.arange(n), a]
    v_hat = click_hat_all[:, star] * e_star + (click_hat_all.sum(axis=1) - click_hat_all[:, star]) * e_other
    D = v_hat + w * (r - m_hat_rows)
    return D, w


def mixture_cs(x, center_grid=None, C=40.5, B=1.0, alpha=ALPHA):
    d2 = (2 * C * B) ** 2 / 8
    t = np.arange(1, len(x) + 1, dtype=float)
    centers = center_grid if center_grid is not None else np.linspace(-0.2, 1.0, 241)
    inside = []
    for c in centers:
        s = np.cumsum(x - c)
        part = s[:, None] * GRID[None, :] - t[:, None] * GRID[None, :] ** 2 * d2
        inside.append(np.exp(part).mean(axis=1)[-1] < 1 / alpha)
    centers = np.asarray(centers)
    return centers[np.asarray(inside)] if any(inside) else np.array([np.nan])


def main():
    rnd, bts, items = load()
    n_items = rnd["item_id"].nunique()
    out = {"n": len(rnd), "n_items": n_items}
    out["propensity_random_unique"] = sorted(rnd["propensity_score"].unique().tolist())
    out["propensity_bts_range"] = [float(bts["propensity_score"].min()), float(bts["propensity_score"].max())]
    assert len(out["propensity_random_unique"]) == 1, "random campaign propensity is not constant"

    pos_levels = sorted(set(rnd["position"]).union(bts["position"]))
    X_all, pos_all, item_feat, Xlog_all = build_features(rnd, items, pos_levels)
    _, _, _, Xlog_bts = build_features(bts, items, pos_levels)
    y_bts = bts["click"].to_numpy(float)
    out["mean_click_bts_campaign"] = float(y_bts.mean())
    out["mean_click_random_campaign"] = float(rnd["click"].mean())

    # Freeze the target policy from the bts campaign (seen before evaluation data)
    clf_target = fit_click(Xlog_bts, y_bts, seed=1)
    star, e_star, e_other, _ = policy_probs(clf_target, X_all, pos_all, item_feat, n_items)
    a_logged = rnd["item_id"].to_numpy()
    b_prop = rnd["propensity_score"].to_numpy()
    e_a = np.where(a_logged == star, e_star, e_other)
    w = e_a / b_prop
    out["e_star"], out["e_other"] = float(e_star), float(e_other)
    out["C_ratio_bound"] = float(np.max(e_a) / out["propensity_random_unique"][0])
    ess = float((w.sum() ** 2) / (len(w) * (w ** 2).sum()))
    out["ESS_fraction_diagnostic_only"] = ess

    r = rnd["click"].to_numpy(float)
    out["IS"] = float(np.mean(w * r))

    # DM with a model fitted on HALF the random log (cross-fitted below for DR);
    folds = np.arange(len(rnd)) % 2
    D_dr = np.zeros(len(rnd))
    m_all = np.zeros((len(rnd), n_items))
    for fold in (0, 1):
        te, tr = folds == fold, folds == (1 - fold)
        clf_m = fit_click(Xlog_all[tr], r[tr], seed=10 + fold)
        blocks = [np.hstack([X_all[te], np.tile(item_feat[a_], (int(te.sum()), 1))]) for a_ in range(n_items)]
        m_all[te] = np.column_stack([clf_m.predict_proba(b_)[:, 1] for b_ in blocks])
    D_dr, _ = dr_estimate(rnd, star, e_star, e_other, b_prop, m_all, r)
    out["DR"] = float(D_dr.mean())
    se = float(D_dr.std(ddof=1) / np.sqrt(len(D_dr)))
    z = 1.959963984540054
    out["DR_CI95_normal"] = [round(D_dr.mean() - z * se, 5), round(D_dr.mean() + z * se, 5)]
    out["DR_SE"] = se
    m1 = m_all[np.arange(len(rnd)), a_logged]
    v1 = m_all[np.arange(len(rnd)), star] * e_star + (m_all.sum(axis=1) - m_all[np.arange(len(rnd)), star]) * e_other
    out["DM_crossfit"] = float(v1.mean())
    inside = mixture_cs(w * r, C=out["C_ratio_bound"])
    out["CS_at_n"] = [round(float(np.min(inside)), 5), round(float(np.max(inside)), 5)]
    out["CS_width_at_n"] = round(float(np.max(inside) - np.min(inside)), 5)
    out["note"] = ("ESS is diagnostic only; C is by construction; CS uses true weights. "
                   "DR_CI is asymptotic under the one-decision efficiency theorem; sanity "
                   "references are the on-policy means of both campaigns (different policies).")
    for k, v in out.items():
        print(json.dumps({k: v}))


if __name__ == "__main__":
    main()
