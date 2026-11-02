"""Generación de gráficas de convergencia (matplotlib) — Lab F.2 Chainlit."""

from __future__ import annotations

import io
from typing import List, Dict

import numpy as np
import matplotlib
matplotlib.use("Agg")  # backend sin pantalla, compatible con servidores
import matplotlib.pyplot as plt


def _setup_style() -> None:
    try:
        plt.style.use("seaborn-v0_8-whitegrid")
    except OSError:
        try:
            plt.style.use("seaborn-whitegrid")
        except OSError:
            pass  # matplotlib sin seaborn — usa estilo por defecto


def make_convergence_plot(
    history: List[Dict],
    theta_true: float,
    agent_name: str = "sufficient",
) -> bytes:
    """
    Genera PNG (bytes) con dos subplots:
      1. Convergencia de θ̂(n) con banda ± 3/√n
      2. Divergencia KL(n)
    """
    if not history:
        return b""

    _setup_style()
    ns = [h["n"] for h in history]
    thetas = [h["theta_hat"] for h in history]
    kls = [h["kl"] for h in history]
    ns_arr = np.array(ns, dtype=float)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))
    fig.suptitle(f"Agente: {agent_name}  |  θ_true = {theta_true}", fontsize=12)

    # ── subplot 1: convergencia θ̂ ──
    ax1.plot(ns, thetas, color="#1D9E75", linewidth=1.5, label="θ̂(n)")
    ax1.axhline(theta_true, color="coral", linestyle="--", linewidth=1.5,
                label=f"θ_true = {theta_true}")
    band = 3.0 / np.sqrt(ns_arr)
    ax1.fill_between(ns, theta_true - band, theta_true + band,
                     alpha=0.15, color="coral", label="θ ± 3/√n")
    ax1.set_xlabel("n (observaciones)")
    ax1.set_ylabel("θ̂")
    ax1.set_title("Convergencia de θ̂")
    ax1.legend(fontsize=8)

    # ── subplot 2: D_KL ──
    ax2.plot(ns, kls, color="#5578A4", linewidth=1.5)
    if kls and max(kls) > 0.1:
        ax2.set_yscale("log")
    ax2.set_xlabel("n")
    ax2.set_ylabel("D_KL")
    ax2.set_title("Divergencia KL acumulada")

    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    return buf.read()


def make_compare_plot(
    history_suf: List[Dict],
    history_bas: List[Dict],
    theta_true: float,
) -> bytes:
    """
    Superpone las curvas de ambos agentes en los mismos subplots.
    Verde (#1D9E75) = suficiente, naranja-rojo (#D85A30) = insuficiente.
    """
    _setup_style()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))
    fig.suptitle(
        f"Suficiente vs Insuficiente  |  θ_true = {theta_true}", fontsize=12
    )

    COLOR_SUF = "#1D9E75"
    COLOR_BAS = "#D85A30"

    def _plot_series(hist: List[Dict], color: str, label: str) -> None:
        if not hist:
            return
        ns = [h["n"] for h in hist]
        thetas = [h["theta_hat"] for h in hist]
        kls = [h["kl"] for h in hist]
        ax1.plot(ns, thetas, color=color, linewidth=1.5, label=label)
        ax2.plot(ns, kls, color=color, linewidth=1.5, label=label)

    _plot_series(history_suf, COLOR_SUF, "Suficiente")
    _plot_series(history_bas, COLOR_BAS, "Insuficiente (Welford)")

    # Banda de confianza global
    ns_max = max(
        history_suf[-1]["n"] if history_suf else 0,
        history_bas[-1]["n"] if history_bas else 0,
    )
    if ns_max > 0:
        ns_arr = np.linspace(1, ns_max, 300)
        ax1.fill_between(
            ns_arr,
            theta_true - 3 / np.sqrt(ns_arr),
            theta_true + 3 / np.sqrt(ns_arr),
            alpha=0.10, color="coral",
        )

    ax1.axhline(theta_true, color="coral", linestyle="--", linewidth=1.5,
                label=f"θ_true = {theta_true}")
    ax1.set_xlabel("n"); ax1.set_ylabel("θ̂"); ax1.set_title("Convergencia de θ̂")
    ax1.legend(fontsize=8)
    ax2.set_xlabel("n"); ax2.set_ylabel("D_KL"); ax2.set_title("Divergencia KL acumulada")
    ax2.legend(fontsize=8)

    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format="png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    buf.seek(0)
    return buf.read()


def compute_history(
    obs: list,
    theta_true: float,
    agent_type: str = "sufficient",
    stream_every: int = 50,
) -> List[Dict]:
    """
    Calcula snapshots de convergencia sin usar LangGraph (rápido).
    Útil para el modo /compare donde necesitamos history de ambos agentes.
    """
    from sufficient_agent import kl_binomial

    history: List[Dict] = []

    if agent_type == "sufficient":
        count, total = 0, 0
        for x in obs:
            count += 1
            total += x
            if count % stream_every == 0:
                theta_hat = total / count
                history.append({
                    "n": count,
                    "theta_hat": theta_hat,
                    "kl": kl_binomial(theta_hat, theta_true),
                    "error": abs(theta_hat - theta_true),
                })
    else:  # baseline / Welford
        mean, n = 0.5, 0
        for x in obs:
            n += 1
            mean = mean + (x - mean) / n
            if n % stream_every == 0:
                theta_hat = mean
                history.append({
                    "n": n,
                    "theta_hat": theta_hat,
                    "kl": kl_binomial(theta_hat, theta_true),
                    "error": abs(theta_hat - theta_true),
                })

    return history
