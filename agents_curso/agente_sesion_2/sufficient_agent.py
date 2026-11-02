"""
Agente de Compresión de Estado por Estadístico Suficiente
Laboratorio F.2 — Capítulo 2: Reducción de Datos y Suficiencia

Teoremas implementados:
  - Neyman-Fisher:   T_n = (n, Σx_i) es suficiente minimal para Bernoulli(θ)
  - Lehmann-Scheffé: θ̂ = Σx_i / n es UMVUE
  - KL:              D_KL(Bin(k,θ̂) || Bin(k,θ)) mide pérdida de información

Complejidad: O(2) espacio, O(1) por observación.
"""

from __future__ import annotations

import numpy as np
from scipy.stats import binom as binom_dist
from typing import TypedDict, Optional, List, Dict

from langgraph.graph import StateGraph, END


# ─── State Schema ─────────────────────────────────────────────────────────────

class SufficientState(TypedDict):
    """
    T_n = (count, total) — estadístico suficiente minimal para Bernoulli(θ).
    Dimensión fija O(2) independiente de n.
    """
    count: int                   # n — número de observaciones acumuladas
    total: int                   # Σx_i — suma de observaciones
    observations: List[int]      # stream de entrada (no parte del estadístico)
    pos: int                     # puntero de posición en el stream
    current_x: Optional[int]     # observación actual (x_t)
    theta_hat: float             # estimador puntual (UMVUE por Lehmann-Scheffé)
    kl: Optional[float]          # D_KL (solo en modo evaluación)
    theta_true: Optional[float]  # θ verdadero (solo para evaluación externa)
    # Campos opcionales para la UI Chainlit
    history: List[Dict]          # snapshots de convergencia (acumulados externamente)
    n_total: Optional[int]       # observaciones totales esperadas (routing al analyst)
    analysis_text: Optional[str] # salida del nodo analyst LLM


# ─── Utilidades ───────────────────────────────────────────────────────────────

def kl_binomial(
    theta_hat: float,
    theta_true: float,
    k: int = 100,
    eps: float = 1e-15,
) -> float:
    """D_KL(Bin(k, θ̂) || Bin(k, θ_true)) con suavizado eps para estabilidad numérica."""
    xs = np.arange(k + 1)
    p = np.clip(binom_dist.pmf(xs, k, theta_hat), eps, None)
    q = np.clip(binom_dist.pmf(xs, k, theta_true), eps, None)
    return float(np.sum(p * np.log(p / q)))


# ─── Nodos ────────────────────────────────────────────────────────────────────

def node_observe(state: SufficientState) -> dict:
    """Recibe x_t del stream. Complejidad O(1)."""
    pos = state["pos"]
    return {
        "current_x": state["observations"][pos],
        "pos": pos + 1,
    }


def node_update(state: SufficientState) -> dict:
    """
    Regla aditiva del estadístico suficiente: T_{n+1} = T_n + t(x_{n+1}).
    Propiedad de familia exponencial. Complejidad O(1).
    Invariantes: count >= 0, 0 <= total <= count.
    """
    return {
        "count": state["count"] + 1,
        "total": state["total"] + state["current_x"],
    }


def node_decide(state: SufficientState) -> dict:
    """
    θ̂ = total / count (UMVUE por Lehmann-Scheffé).
    Calcula D_KL si theta_true está disponible. Complejidad O(k) para KL, O(1) para θ̂.
    """
    n, s = state["count"], state["total"]
    theta_hat = s / n if n > 0 else 0.5
    kl: Optional[float] = None
    if (theta_true := state.get("theta_true")) is not None:
        kl = kl_binomial(theta_hat, theta_true)
    return {"theta_hat": theta_hat, "kl": kl}


def _route(state: SufficientState) -> str:
    """Continúa si quedan observaciones; termina si el stream se agotó."""
    return "observe" if state["pos"] < len(state["observations"]) else END


# ─── Grafo LangGraph ──────────────────────────────────────────────────────────

def build_sufficient_agent():
    """
    Topología: observe → update → decide → (observe | END)
    Lineal-cíclica hasta agotar el stream.
    """
    g = StateGraph(SufficientState)
    g.add_node("observe", node_observe)
    g.add_node("update", node_update)
    g.add_node("decide", node_decide)
    g.set_entry_point("observe")
    g.add_edge("observe", "update")
    g.add_edge("update", "decide")
    g.add_conditional_edges(
        "decide",
        _route,
        {"observe": "observe", END: END},
    )
    return g.compile()


# ─── API pública ──────────────────────────────────────────────────────────────

def run_agent(
    observations: List[int],
    theta_true: Optional[float] = None,
) -> SufficientState:
    """
    Ejecuta el agente suficiente sobre una secuencia de observaciones Bernoulli.

    Args:
        observations: Lista de {0,1} i.i.d. ~ Bernoulli(θ)
        theta_true:   θ verdadero para calcular D_KL (modo evaluación)

    Returns:
        Estado final con count, total, theta_hat y, opcionalmente, kl.
    """
    app = build_sufficient_agent()
    n = len(observations)
    if n == 0:
        raise ValueError("observations no puede estar vacío")
    init: SufficientState = {
        "count": 0,
        "total": 0,
        "observations": observations,
        "pos": 0,
        "current_x": None,
        "theta_hat": 0.5,
        "kl": None,
        "theta_true": theta_true,
        "history": [],
        "n_total": None,
        "analysis_text": None,
    }
    # Cada observación consume 3 pasos de nodo (observe→update→decide)
    return app.invoke(init, config={"recursion_limit": n * 3 + 10})
