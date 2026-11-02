import math
import os
from typing import Annotated, Literal, TypedDict

from dotenv import load_dotenv
from langchain_core.messages import AIMessage, BaseMessage
from langchain_core.utils import convert_to_secret_str
from langchain_openrouter import ChatOpenRouter
from langgraph.graph import END, StateGraph
from langgraph.graph.message import add_messages
from langgraph.types import interrupt

load_dotenv()

llm = ChatOpenRouter(
    model=os.getenv("OPENROUTER_MODEL", "z-ai/glm-4.7-flash"),
    api_key=convert_to_secret_str(os.getenv("OPENROUTER_API_KEY", "")),
    temperature=0.3,
    streaming=True,
)


class EstadoDiagnostico(TypedDict):
    alpha: int
    beta: int
    messages: Annotated[list[BaseMessage], add_messages]
    next_action: Literal["continuar", "finalizar", "consultar"]
    decision_medico: Literal["R", "D", ""]  # respuesta del médico en consultar_medico
    sigma_post: float
    umbral_incertidumbre: float
    x: int  # última observación
    c: float  # costo de tratar a un sano
    d: float  # costo de no tratar a un enfermo


def inicializar(state: EstadoDiagnostico) -> dict:
    return {
        "alpha": 1,
        "beta": 1,
        "umbral_incertidumbre": 0.15,
        "sigma_post": 1.0,
        "next_action": "continuar",
        "decision_medico": "",
        "c": 1.0,
        "d": 3.0,
        "messages": [AIMessage(
            content=(
                "Sistema de diagnóstico bayesiano iniciado.\n"
                "Prior: Beta(α=1, β=1) — distribución uniforme sobre θ (prob. patología).\n"
                "Umbral de parada Wald: σ_post < 0.15\n"
                "Costos: c=1.0 (tratar sano)  d=3.0 (no tratar enfermo)\n"
                "Umbral Bayes: d/(c+d) = 0.75\n"
                "→ Se recomienda TRATAR si E[θ] > 0.75 con σ < 0.15"
            )
        )],
    }


def observar_prueba(state: EstadoDiagnostico) -> dict:
    n = state.get("alpha", 1) + state.get("beta", 1) - 2  # pruebas ya procesadas
    alpha, beta = state.get("alpha", 1), state.get("beta", 1)
    theta = alpha / (alpha + beta)
    sigma = state.get("sigma_post", 1.0)
    prompt = (
        f"OBS #{n + 1} | E[θ]={theta:.3f}  σ={sigma:.4f}\n"
        f"Resultado de la prueba clínica:\n"
        f"  1 → positivo  (presencia de hipotensión/patología)\n"
        f"  0 → negativo  (paciente sano / sin patología)\n"
        f"Ingrese 0 o 1:"
    )
    x_raw = interrupt(prompt)
    try:
        x = int(str(x_raw).strip())
        if x not in {0, 1}:
            x = 0
    except (ValueError, TypeError):
        x = 0
    return {"x": x}


def actualizar_estado(state: EstadoDiagnostico) -> dict:
    alpha = max(state["alpha"], 1)
    beta  = max(state["beta"],  1)
    x     = state.get("x", 0)
    a_new, b_new = alpha + x, beta + (1 - x)
    n = a_new + b_new
    theta = a_new / n
    return {
        "alpha": a_new,
        "beta":  b_new,
        "messages": [AIMessage(content=(
            f"Observación x={x} {'(positivo ●)' if x else '(negativo ○)'} incorporada.\n"
            f"Posterior: Beta(α={a_new}, β={b_new})  |  E[θ]={theta:.4f}  |  n={n - 2} pruebas"
        ))],
    }


def calcular_incertidumbre(state: EstadoDiagnostico) -> dict:
    alpha, beta = state["alpha"], state["beta"]
    n = alpha + beta
    if alpha <= 0 or beta <= 0:
        return {"sigma_post": 1.0, "messages": [AIMessage(content="σ = 1.0 (error: parámetros inválidos)")]}
    var   = (alpha * beta) / (n * n * (n + 1)) if n > 0 else 1.0
    sigma = math.sqrt(var)
    eps   = state.get("umbral_incertidumbre", 0.15)
    estado = "✅ convergió (σ < ε)" if sigma < eps else f"⚠ σ ≥ ε — se necesitan más pruebas"
    return {
        "sigma_post": sigma,
        "messages": [AIMessage(content=f"σ_post = {sigma:.4f}  (ε = {eps})  →  {estado}")],
    }


def decidir_estadistico(state: EstadoDiagnostico) -> dict:
    sigma = state["sigma_post"]
    eps   = state["umbral_incertidumbre"]
    # Regla de parada de Wald: finalizar solo si σ_post < ε.
    # La decisión tratar/no tratar la toma recomendar_tratamiento.
    if sigma < eps:
        return {"next_action": "finalizar",
                "messages": [AIMessage(content=f"Regla de Wald: σ={sigma:.4f} < ε={eps} → PARAR y recomendar.")]}
    else:
        return {"next_action": "consultar",
                "messages": [AIMessage(content=f"Regla de Wald: σ={sigma:.4f} ≥ ε={eps} → pedir evaluación médica.")]}


def consultar_medico(state: EstadoDiagnostico) -> dict:
    msg = f"Incertidumbre = {state['sigma_post']:.4f}. ¿Repetir prueba (R) o diagnosticar ya (D)?"
    decision = interrupt(msg)
    # Guarda la decisión en estado; add_conditional_edges hace el enrutamiento.
    decision = decision if decision in ("R", "D") else "R"
    extra = {} if decision == "R" else {
        "next_action": "finalizar",
        "messages": [AIMessage(content="Decisión forzada por médico (incertidumbre alta).")],
    }
    return {"decision_medico": decision, **extra}


def recomendar_tratamiento(state: EstadoDiagnostico) -> dict:
    alpha, beta = state["alpha"], state["beta"]
    c, d = state.get("c", 1.0), state.get("d", 1.0)
    theta_hat = alpha / (alpha + beta)
    umbral_bayes = d / (c + d)

    if theta_hat > umbral_bayes:
        msg = f"TRATAR: θ̂={theta_hat:.3f} > {umbral_bayes:.3f} (σ < ε)"
    else:
        msg = f"NO TRATAR: θ̂={theta_hat:.3f} ≤ {umbral_bayes:.3f} (σ < ε)"
    return {"messages": [AIMessage(content=msg)]}


def forzar_tratamiento(state: EstadoDiagnostico) -> dict:
    return {"messages": [AIMessage(content="Tratamiento forzado (baja confianza).")]}


def registrar_advertencia(state: EstadoDiagnostico) -> dict:
    # Registrar advertencia solo si la incertidumbre es alta
    if state["sigma_post"] >= state["umbral_incertidumbre"]:
        return {
            "messages": [
                AIMessage(
                    content="Advertencia registrada: decisión con incertidumbre alta."
                )
            ]
        }
    else:
        return {
            "messages": [AIMessage(content="Proceso completado con alta confianza.")]
        }


builder = StateGraph(EstadoDiagnostico)
builder.add_node("inicializar", inicializar)
builder.add_node("observar_prueba", observar_prueba)
builder.add_node("actualizar", actualizar_estado)
builder.add_node("calcular_incertidumbre", calcular_incertidumbre)
builder.add_node("decidir_estadistico", decidir_estadistico)
builder.add_node("consultar_medico", consultar_medico)
builder.add_node("recomendar_tratamiento", recomendar_tratamiento)
builder.add_node("forzar_tratamiento", forzar_tratamiento)
builder.add_node("registrar_advertencia", registrar_advertencia)

builder.set_entry_point("inicializar")
builder.add_edge("inicializar", "observar_prueba")
builder.add_edge("observar_prueba", "actualizar")
builder.add_edge("actualizar", "calcular_incertidumbre")
builder.add_edge("calcular_incertidumbre", "decidir_estadistico")
builder.add_conditional_edges(
    "decidir_estadistico",
    lambda s: s["next_action"],
    {"finalizar": "recomendar_tratamiento", "consultar": "consultar_medico"},
)
# Aristas estáticas desde consultar_medico: hace visible el ciclo en LangGraph Studio.
builder.add_conditional_edges(
    "consultar_medico",
    lambda s: s["decision_medico"],
    {"R": "observar_prueba", "D": "forzar_tratamiento"},
)
builder.add_edge("recomendar_tratamiento", "registrar_advertencia")
builder.add_edge("forzar_tratamiento", "registrar_advertencia")
builder.add_edge("registrar_advertencia", END)

graph = builder.compile()
