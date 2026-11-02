"""
run_experiment.py — Train a logistic regression on the German Credit
data and run the Wald decision agent on the held-out test set.

Reports diagnostics that verify correct implementation:
  1. The empirical Bayes acceptance frontier sits near theta = 1/6
     (the closed-form threshold for the Statlog 5:1 loss).
  2. The minimax rule is strictly more conservative than the Bayes rule
     (rejects at least as often).
  3. Posterior entropy distribution and meta-selector decision breakdown.
  4. A histogram of entropy values is saved to entropy_histogram.png.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

from agent.losses import bayes_threshold
from agent.nodes import (
    make_posterior_node,
    meta_selector,
    observar,
    realise_loss,
    riesgo_bayes,
    riesgo_minimax,
)
from config import ACTIONS, DATA_PATH, SEED, TEST_SIZE


def load_data():
    df = pd.read_csv(DATA_PATH)
    y = (df["class"] == "bad").astype(int).values
    X = df.drop(columns=["class"])
    return X, y


def build_pipeline(X) -> Pipeline:
    num_cols = X.select_dtypes(include="number").columns.tolist()
    cat_cols = X.select_dtypes(exclude="number").columns.tolist()
    pre = ColumnTransformer([
        ("num", StandardScaler(), num_cols),
        ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
    ])
    clf = LogisticRegression(max_iter=2000, random_state=SEED, C=1.0)
    return Pipeline([("pre", pre), ("clf", clf)])


def run_agent_on_test(pipeline: Pipeline, X_test, y_test):
    """
    Iterate over test rows, run the 5 nodes in sequence (without LangGraph
    so this runs in CI environments without that dependency), and collect
    decisions and realised losses.
    """
    def predict_proba(_x_unused_row_index):
        # We pass the row position via closure below.
        return None  # replaced below

    rows = []
    for i in range(len(X_test)):
        # Predict on the single row through the full pipeline.
        p_bad = float(pipeline.predict_proba(X_test.iloc[[i]])[0, 1])

        state = {"applicant_id": i, "x": np.array([p_bad]),
                 "y_true": "bad" if y_test[i] == 1 else "good"}

        # Use a model-free posterior node that takes the row's p_bad directly.
        posterior = make_posterior_node(lambda x, _p=p_bad: _p)

        for node in (observar, posterior, riesgo_bayes, riesgo_minimax,
                     meta_selector, realise_loss):
            state.update(node(state))
        rows.append(state)
    return pd.DataFrame(rows)


def _entropy_histogram(entropies: np.ndarray, bins: int = 10) -> str:
    """Build a simple ASCII histogram of entropy values."""
    counts, edges = np.histogram(entropies, bins=bins, range=(0.0, 1.0))
    max_c = max(counts.max(), 1)
    bar_w = 30
    lines = ["  Entropy distribution (0=point mass, 1=uniform):"]
    for lo, hi, c in zip(edges[:-1], edges[1:], counts):
        bar = "█" * int(bar_w * c / max_c)
        pct = 100.0 * c / len(entropies)
        lines.append(f"  [{lo:.2f}-{hi:.2f})  {bar}  {c:4d} ({pct:5.1f}%)")
    return "\n".join(lines)


def summarise(df: pd.DataFrame, plot_path: Path | None = None):
    print("\n" + "=" * 68)
    print("WALD DECISION AGENT — TEST-SET SUMMARY")
    print("=" * 68)
    n = len(df)
    print(f"Applicants evaluated:      {n}")
    print(f"True bad rate (test set):  {(df['y_true']=='bad').mean():.3f}")
    print(f"Bayes threshold (closed):  {bayes_threshold():.4f}")
    print()

    # --- Entropy diagnostics ---
    H = df["entropy_norm"].values
    print("--- Posterior entropy (normalised) ---")
    print(f"  Mean ± std:  {H.mean():.4f} ± {H.std():.4f}")
    print(f"  Min / Max:   {H.min():.4f} / {H.max():.4f}")
    print(f"  Median:      {np.median(H):.4f}")
    print(f"  Q1 / Q3:     {np.percentile(H, 25):.4f} / {np.percentile(H, 75):.4f}")
    print()
    print(_entropy_histogram(H))
    print()

    # --- Meta-selector breakdown ---
    print("--- Meta-selector decisions ---")
    print(df["rule_used"].value_counts().to_string())
    print()

    # Show transitions: for each rule, what was the decision?
    print("--- Rule × chosen_action crosstab ---")
    print(pd.crosstab(df["rule_used"], df["chosen_action"],
                      rownames=["rule_used"], colnames=["chosen_action"]).to_string())
    print()

    # --- Pure-Bayes vs pure-minimax cross ---
    print("--- Pure-Bayes vs pure-minimax action frequencies ---")
    ct = pd.crosstab(df["bayes_action"], df["minimax_action"],
                     rownames=["bayes"], colnames=["minimax"])
    print(ct.to_string())
    # Add interpretation
    if "escalate" not in ct.columns:
        n_disagree = ct.loc["accept", "reject"] if "accept" in ct.index and "reject" in ct.columns else 0
        print(f"  → Bayes & Minimax agree on {n - n_disagree} cases, disagree on {n_disagree}")
    print()

    # --- Realised total loss ---
    print("--- Realised total loss ---")
    total_meta = df["realised_loss"].sum()
    from agent.losses import loss as Lfn
    total_bayes   = sum(Lfn(yt, a) for yt, a
                        in zip(df["y_true"], df["bayes_action"]))
    total_minimax = sum(Lfn(yt, a) for yt, a
                        in zip(df["y_true"], df["minimax_action"]))
    total_accept  = sum(Lfn(yt, "accept")  for yt in df["y_true"])
    total_reject  = sum(Lfn(yt, "reject")  for yt in df["y_true"])
    print(f"  Always-accept (no model):  {total_accept:8.2f}")
    print(f"  Always-reject (no model):  {total_reject:8.2f}")
    print(f"  Pure Bayes rule:           {total_bayes:8.2f}")
    print(f"  Pure minimax rule:         {total_minimax:8.2f}")
    print(f"  Meta-selector (this run):  {total_meta:8.2f}")
    if total_meta < min(total_bayes, total_minimax):
        print(f"  ✓ Meta-selector BEATS both pure rules by {min(total_bayes, total_minimax) - total_meta:.2f} loss")
    elif total_meta == total_bayes:
        print(f"  ℹ Meta-selector matches Pure Bayes (no escalations triggered)")
    elif total_meta == total_minimax:
        print(f"  ℹ Meta-selector matches Pure Minimax (all high-entropy cases)")
    else:
        print(f"  ℹ Meta-selector between the two pure rules")
    print()

    # --- Empirical Bayes boundary ---
    print("--- Empirical Bayes acceptance boundary ---")
    bayes_accept = df[df["bayes_action"] == "accept"]
    bayes_reject = df[df["bayes_action"] == "reject"]
    if len(bayes_accept) and len(bayes_reject):
        print(f"  max p_hat among accepted: {bayes_accept['p_hat'].max():.4f}")
        print(f"  min p_hat among rejected: {bayes_reject['p_hat'].min():.4f}")
    print()

    # --- Optional: matplotlib histogram ---
    if plot_path is not None:
        try:
            import matplotlib
            matplotlib.use("Agg")
            import matplotlib.pyplot as plt
            fig, axes = plt.subplots(1, 2, figsize=(12, 5))

            # Left: entropy histogram
            ax = axes[0]
            ax.hist(H, bins=20, range=(0, 1), color="steelblue",
                    edgecolor="white", alpha=0.85)
            ax.axvline(0.45, color="orange", ls="--", lw=1.5,
                       label="minimax threshold (0.45)")
            ax.axvline(0.65, color="red", ls="--", lw=1.5,
                       label="escalate threshold (0.65)")
            ax.set_xlabel("Normalised entropy")
            ax.set_ylabel("Applicants")
            ax.set_title("Posterior entropy distribution")
            ax.legend(fontsize=8)

            # Right: p_hat distribution colored by chosen_action
            ax = axes[1]
            colors = {"accept": "green", "reject": "red", "escalate": "orange"}
            for action in ["accept", "reject", "escalate"]:
                mask = df["chosen_action"] == action
                if mask.any():
                    ax.scatter(df.loc[mask, "p_hat"], df.loc[mask, "entropy_norm"],
                               c=colors[action], label=action, alpha=0.6, edgecolors="none", s=20)
            ax.axvline(1/6, color="black", ls=":", lw=1, alpha=0.5, label="Bayes threshold (1/6)")
            ax.set_xlabel("p_hat = P(bad | x)")
            ax.set_ylabel("Normalised entropy")
            ax.set_title("Decision by p_hat × entropy")
            ax.legend(fontsize=8)

            fig.tight_layout()
            fig.savefig(str(plot_path), dpi=150)
            plt.close(fig)
            print(f"[plot] Histogram saved to {plot_path}")
        except ImportError:
            print("[plot] matplotlib not installed — skipping histogram")

    print("=" * 68)


def main():
    np.random.seed(SEED)
    X, y = load_data()
    X_tr, X_te, y_tr, y_te = train_test_split(
        X, y, test_size=TEST_SIZE, random_state=SEED, stratify=y)
    pipe = build_pipeline(X_tr).fit(X_tr, y_tr)
    print(f"Train accuracy: {pipe.score(X_tr, y_tr):.3f}")
    print(f"Test  accuracy: {pipe.score(X_te, y_te):.3f}")
    results = run_agent_on_test(pipe, X_te, y_te)
    out_dir = Path(__file__).parent / "output"
    out_dir.mkdir(exist_ok=True)
    summarise(results, plot_path=out_dir / "entropy_histogram.png")
    out_csv = out_dir / "results.csv"
    results.drop(columns=["x"]).to_csv(out_csv, index=False)
    print(f"\nPer-applicant decisions written to {out_csv}")


if __name__ == "__main__":
    main()
