"""
Nodo LLM analyst para el grafo LangGraph — Lab F.2 Chainlit.

Topología extendida: observe → update → decide → (observe | analyst) → END
El nodo analyst se activa cuando se agotan las observaciones.
"""

from __future__ import annotations

import os
from pathlib import Path

from langgraph.graph import StateGraph, END

from sufficient_agent import (
    SufficientState,
    node_observe,
    node_update,
    node_decide,
)

_SYSTEM_PROMPT_PATH = Path(__file__).parent / "prompts" / "analyst_system.md"


async def analyst_node(state: SufficientState) -> dict:
    """Llama al modelo via OpenRouter para interpretar los resultados del run."""
    from llm_client import get_client, has_api_key, DEFAULT_MODEL

    if not has_api_key():
        return {"analysis_text": "⚠️ OPENROUTER_API_KEY no configurada. Sin análisis LLM."}

    theta_true = state.get("theta_true") or 0.3
    theta_hat = state["theta_hat"]
    abs_error = abs(theta_hat - theta_true)
    kl = state.get("kl") or 0.0

    system_prompt = (
        _SYSTEM_PROMPT_PATH.read_text(encoding="utf-8")
        if _SYSTEM_PROMPT_PATH.exists()
        else "Eres un estadístico experto. Interpreta resultados de estimación con precisión."
    )

    user_msg = (
        f"Analiza estos resultados de estimación Bernoulli(θ):\n"
        f"- n observaciones: {state['count']}\n"
        f"- θ verdadero: {theta_true}\n"
        f"- θ̂ estimado: {theta_hat:.6f}\n"
        f"- Error absoluto: {abs_error:.6f}\n"
        f"- D_KL final: {kl:.8f}\n"
        f"- Tipo de agente: sufficient (estadístico suficiente T_n = (count, total))\n\n"
        f"Responde en 3-4 oraciones: qué implica la D_KL obtenida, si la convergencia fue "
        f"la esperada por CLT, y qué ventaja concreta dio el estadístico suficiente."
    )

    client = get_client()
    response = await client.chat.completions.create(
        model=DEFAULT_MODEL,
        max_tokens=300,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_msg},
        ],
    )
    return {"analysis_text": response.choices[0].message.content}


def _route_with_analyst(state: SufficientState) -> str:
    """Enruta al analyst cuando se agotan observaciones; si no, sigue a observe."""
    if state["pos"] >= len(state["observations"]):
        return "analyst"
    return "observe"


def build_sufficient_agent_with_analyst():
    """
    Grafo extendido: observe → update → decide → (observe | analyst) → END
    """
    g = StateGraph(SufficientState)
    g.add_node("observe", node_observe)
    g.add_node("update", node_update)
    g.add_node("decide", node_decide)
    g.add_node("analyst", analyst_node)
    g.set_entry_point("observe")
    g.add_edge("observe", "update")
    g.add_edge("update", "decide")
    g.add_conditional_edges(
        "decide",
        _route_with_analyst,
        {"observe": "observe", "analyst": "analyst"},
    )
    g.add_edge("analyst", END)
    return g.compile()
