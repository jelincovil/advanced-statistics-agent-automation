"""
Agente de referencia — estadístico INSUFICIENTE (actualización de Welford).

La media de Welford (mean, n) NO es estadístico suficiente para Bernoulli(θ):
  - No permite recuperar Σx_i con precisión exacta de punto flotante.
  - Introduce error de redondeo acumulado que crece con n.
  - Resulta en mayor D_KL vs theta_true comparado con el agente suficiente.

Propósito: cuantificar la penalización informacional por estadístico insuficiente.
"""

from __future__ import annotations

from typing import TypedDict, Optional, List

from langgraph.graph import StateGraph, END

from sufficient_agent import kl_binomial


# ─── State Schema ─────────────────────────────────────────────────────────────

class InsufficientState(TypedDict):
    """
    Estado Welford: (mean, n) — estadístico NO suficiente para Bernoulli(θ).
    La suma exacta Σx_i no es recuperable desde (mean, n) con precisión flotante.
    """
    mean: float                  # media de Welford (acumulación con pérdida)
    n: int                       # contador de observaciones
    observations: List[int]      # stream de entrada
    pos: int                     # puntero de posición
    current_x: Optional[int]     # observación actual
    theta_hat: float             # estimador puntual
    kl: Optional[float]          # D_KL respecto a theta_true
    theta_true: Optional[float]  # parámetro verdadero (solo evaluación)


# ─── Nodos ────────────────────────────────────────────────────────────────────

def node_observe(state: InsufficientState) -> dict:
    pos = state["pos"]
    return {"current_x": state["observations"][pos], "pos": pos + 1}


def node_update(state: InsufficientState) -> dict:
    """
    Actualización de Welford — pierde la suma exacta por aritmética flotante.
    mean_n = mean_{n-1} + (x - mean_{n-1}) / n
    Estadístico insuficiente: no permite reconstruir Σx_i exactamente.
    """
    n = state["n"] + 1
    mean = state["mean"] + (state["current_x"] - state["mean"]) / n
    return {"n": n, "mean": mean}


def node_decide(state: InsufficientState) -> dict:
    theta_hat = state["mean"] if state["n"] > 0 else 0.5
    kl: Optional[float] = None
    if (theta_true := state.get("theta_true")) is not None:
        kl = kl_binomial(theta_hat, theta_true)
    return {"theta_hat": theta_hat, "kl": kl}


def _route(state: InsufficientState) -> str:
    return "observe" if state["pos"] < len(state["observations"]) else END


# ─── Grafo LangGraph ──────────────────────────────────────────────────────────

def build_baseline_agent():
    g = StateGraph(InsufficientState)
    g.add_node("observe", node_observe)
    g.add_node("update", node_update)
    g.add_node("decide", node_decide)
    g.set_entry_point("observe")
    g.add_edge("observe", "update")
    g.add_edge("update", "decide")
    g.add_conditional_edges("decide", _route, {"observe": "observe", END: END})
    return g.compile()


# ─── API pública ──────────────────────────────────────────────────────────────

def run_baseline(
    observations: List[int],
    theta_true: Optional[float] = None,
) -> InsufficientState:
    """
    Ejecuta el agente insuficiente (Welford) sobre observaciones Bernoulli.

    Args:
        observations: Lista de {0,1}
        theta_true:   θ verdadero para calcular D_KL

    Returns:
        Estado final con mean, n, theta_hat y, opcionalmente, kl.
    """
    app = build_baseline_agent()
    n = len(observations)
    if n == 0:
        raise ValueError("observations no puede estar vacío")
    init: InsufficientState = {
        "mean": 0.5,
        "n": 0,
        "observations": observations,
        "pos": 0,
        "current_x": None,
        "theta_hat": 0.5,
        "kl": None,
        "theta_true": theta_true,
    }
    return app.invoke(init, config={"recursion_limit": n * 3 + 10})
