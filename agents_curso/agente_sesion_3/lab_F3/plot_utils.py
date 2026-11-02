import io
import math
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def make_convergence_plot(history: list[dict], value_hat: dict, value_se: dict) -> bytes:
    """3 subplots: varianzas vs n, reducción RB, V̂^π con IC."""
    ns = [h["n"] for h in history if h.get("var_mc_mean") is not None]
    var_mc_vals = [h["var_mc_mean"] for h in history if h.get("var_mc_mean") is not None]
    var_rb_vals = [h["var_rb_mean"] for h in history if h.get("var_rb_mean") is not None]
    cr_vals = [h.get("cr_bound_mean", None) for h in history if h.get("var_mc_mean") is not None]

    fig, axes = plt.subplots(1, 3, figsize=(14, 5))
    fig.suptitle("Lab F3 — Estimación Óptima en FrozenLake-v1", fontsize=13, fontweight="bold")

    # --- Subplot 1: Varianza MC vs RB vs CR bound ---
    ax1 = axes[0]
    if ns:
        ax1.semilogy(ns, var_mc_vals, "r-o", markersize=4, label="Var MC")
        ax1.semilogy(ns, var_rb_vals, "g-o", markersize=4, label="Var RB")
        cr_clean = [c for c in cr_vals if c is not None]
        ns_cr = [n for n, c in zip(ns, cr_vals) if c is not None]
        if cr_clean:
            ax1.semilogy(ns_cr, cr_clean, "b--", linewidth=1.5, label="CR bound")
    ax1.set_xlabel("n (episodios)")
    ax1.set_ylabel("varianza promedio")
    ax1.set_title("MC vs Rao-Blackwell vs Cramér-Rao")
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # --- Subplot 2: Reducción de varianza (%) ---
    ax2 = axes[1]
    if ns and len(var_mc_vals) == len(var_rb_vals):
        reduction = []
        for vm, vr in zip(var_mc_vals, var_rb_vals):
            if vm > 0:
                reduction.append((vm - vr) / vm * 100.0)
            else:
                reduction.append(0.0)
        ax2.plot(ns, reduction, "purple", marker="s", markersize=4)
        ax2.axhline(0, color="black", linewidth=0.8, linestyle="--")
    ax2.set_xlabel("n")
    ax2.set_ylabel("(Var_MC − Var_RB) / Var_MC · 100%")
    ax2.set_title("Reducción de varianza por Rao-Blackwell")
    ax2.grid(True, alpha=0.3)

    # --- Subplot 3: V̂^π(s) con IC 95% (top 8 estados más visitados) ---
    ax3 = axes[2]
    states = sorted(value_hat.keys(), key=lambda s: -abs(value_hat[s]))[:8]
    if states:
        vals = [value_hat[s] for s in states]
        ses = [value_se.get(s, 0.0) * 1.96 for s in states]
        x_pos = np.arange(len(states))
        ax3.bar(x_pos, vals, yerr=ses, color="steelblue", alpha=0.75,
                capsize=4, error_kw={"linewidth": 1.5})
        ax3.set_xticks(x_pos)
        ax3.set_xticklabels([str(s) for s in states])
        ax3.set_xlabel("estado s")
        ax3.set_ylabel("V̂^π(s)")
        ax3.set_title("Función de valor con IC 95%")
        ax3.grid(True, alpha=0.3, axis="y")

    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    return buf.read()


def make_comparison_plot(results: list[dict]) -> bytes:
    """Multi-run: var_mc, var_rb y CR_bound en función de n_episodes."""
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.set_title("Comparación multi-run: MC vs RB vs CR bound", fontweight="bold")

    for r in results:
        n = r["n_episodes"]
        ax.scatter(n, r.get("mean_var_mc", 0), color="red", marker="o", s=60, zorder=3)
        ax.scatter(n, r.get("mean_var_rb", 0), color="green", marker="s", s=60, zorder=3)
        ax.scatter(n, r.get("mean_cr_bound", 0), color="blue", marker="^", s=60, zorder=3)

    ax.plot(
        [r["n_episodes"] for r in results],
        [r.get("mean_var_mc", 0) for r in results],
        "r-", label="Var MC", alpha=0.7,
    )
    ax.plot(
        [r["n_episodes"] for r in results],
        [r.get("mean_var_rb", 0) for r in results],
        "g-", label="Var RB", alpha=0.7,
    )
    ax.plot(
        [r["n_episodes"] for r in results],
        [r.get("mean_cr_bound", 0) for r in results],
        "b--", label="CR bound", alpha=0.7,
    )
    ax.set_xlabel("n_episodes")
    ax.set_ylabel("varianza promedio")
    ax.set_yscale("log")
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    return buf.read()


def make_sample_planning_plot(mean_I: float, epsilons: list[float] = None) -> bytes:
    """Curva n_min(ε) = 1 / (ε² · I_mean) con puntos marcados."""
    if epsilons is None:
        epsilons = [0.1, 0.05, 0.01]

    if mean_I <= 0:
        mean_I = 1.0

    eps_range = np.linspace(0.005, 0.2, 300)
    n_min_curve = 1.0 / (eps_range ** 2 * mean_I)

    fig, ax = plt.subplots(figsize=(7, 4))
    ax.set_title("Sample planning: n_min(ε) = 1 / (ε² · Ī(θ))", fontweight="bold")
    ax.semilogy(eps_range, n_min_curve, "steelblue", linewidth=2)

    for eps in epsilons:
        n_pt = 1.0 / (eps ** 2 * mean_I)
        ax.scatter(eps, n_pt, zorder=5, s=80)
        ax.annotate(
            f"ε={eps}\nn={int(n_pt)+1:,}",
            xy=(eps, n_pt),
            xytext=(eps + 0.005, n_pt * 1.5),
            fontsize=8,
        )

    ax.set_xlabel("ε (tolerancia de error estándar)")
    ax.set_ylabel("n_min (episodios requeridos)")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    return buf.read()
