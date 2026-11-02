"""
Agente LangGraph v2 — orquestación de nodos con verificación y trazabilidad.

Arquitectura del Cap.~9 (Sección 9.3.1) + Protocolo Prop.~9.14:

    observation -> state -> inference -> decision
                                          |
                                          v
                                  isomorphism -> transfer -> test -> verify -> END

El nodo `verify` ejecuta el Protocolo 9.14 antes de emitir cualquier
garantía. Si alguna condición falla, marca `transferable=False` y
sugiere un estimador fallback. La traza completa se acumula en
`state["trace_log"]` para auditoría.
"""
from __future__ import annotations

from typing import Optional

import numpy as np
from langgraph.graph import END, START, StateGraph

from .functor import F, verify_isomorphism
from .mdp import MDP, optimal_policy, value_iteration
from .state import AgentState, MDPState, WaldState
from .trace import TraceLog
from .transfer import ic_transfer_delta, test_transfer_ump
from .wald import WaldProblem, bayes_rule, posterior_ic, wald_test


# ---------------------------------------------------------------------------
# Helper para construir el problema de Wald desde el estado
# ---------------------------------------------------------------------------
def _make_problem(state: AgentState) -> WaldProblem:
    la = state.get("loss_args", {}) or {}
    return WaldProblem(cost_treat=la.get("cost_treat", 0.2),
                       cost_skip=la.get("cost_skip", 1.0))


# ---------------------------------------------------------------------------
# Nodos (cada uno registra su teorema en la traza)
# ---------------------------------------------------------------------------
def observation_node(state: AgentState) -> dict:
    """Nodo de observación: $X \\sim P_\\theta$."""
    data = np.asarray(state["data"])
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Def 9.1", "observation_node", "Muestreo",
            value=f"n={len(data)}", notes="X ~ P_θ")
    return {"wald": WaldState(n=len(data), sum_x=float(data.sum()),
                              sum_x2=float((data ** 2).sum())),
            "trace_log": log}


def state_node(state: AgentState) -> dict:
    """Nodo de estadístico suficiente: actualiza (α, β)."""
    wald = state["wald"]
    prior = state.get("prior", {"alpha": 2.0, "beta": 2.0})
    alpha = prior["alpha"] + wald.sum_x
    beta = prior["beta"] + wald.n - wald.sum_x
    wald.alpha = alpha
    wald.beta = beta
    wald.theta_hat = alpha / (alpha + beta)
    wald.var_theta = (alpha * beta) / ((alpha + beta) ** 2 * (alpha + beta + 1))
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.10", "state_node", "Información completa",
            value=f"α={alpha:.2f}, β={beta:.2f}",
            notes="StateSchema ≅ T(X)")
    return {"wald": wald, "trace_log": log}


def inference_node(state: AgentState) -> dict:
    """Nodo de inferencia: IC posterior para θ."""
    wald = state["wald"]
    ic = posterior_ic(wald.alpha, wald.beta, level=0.95)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.5", "inference_node", "Cobertura",
            value=f"IC=[{ic[0]:.3f},{ic[1]:.3f}]",
            notes="Posterior Beta(α,β)")
    return {"wald": wald, "theta_hat": wald.theta_hat, "ic_theta": ic,
            "trace_log": log}


def decision_node(state: AgentState) -> dict:
    """Nodo de decisión: regla de Bayes δ^*."""
    wald = state["wald"]
    problem = _make_problem(state)
    a = bayes_rule(wald.alpha, wald.beta, problem)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.9", "decision_node", "Optimalidad",
            value=f"δ*={a}", notes="R(θ,δ) ↔ -V^π(s)")
    return {"bayes_action": a, "wald": wald, "trace_log": log}


def isomorphism_node(state: AgentState) -> dict:
    """Nodo del funtor F: aplica F y verifica δ^* == π^*."""
    wald = state["wald"]
    problem = _make_problem(state)
    result = verify_isomorphism(problem, wald.alpha, wald.beta)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.1", "isomorphism_node", "Formal",
            value=f"δ*={result['bayes_action']}, π*={result['mdp_action']}, "
                  f"ok={result['isomorphism_ok']}",
            notes="F: Dec → MDP biyección")
    return {"mdp_action": result["mdp_action"],
            "isomorphism_ok": result["isomorphism_ok"],
            "trace_log": log}


def transfer_node(state: AgentState) -> dict:
    """Nodo de transferencia: IC para V^π vía delta-method (Teorema 9.7)."""
    wald = state["wald"]
    a = state["bayes_action"]
    problem = _make_problem(state)

    def V_fn(theta: float) -> float:
        return -float(problem.loss(theta, a))

    if a == 1:
        dV = problem.cost_treat
    else:
        dV = -problem.cost_skip
    ic = ic_transfer_delta(wald.theta_hat, wald.var_theta, V_fn, dV_dtheta=dV)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.7", "transfer_node", "Cobertura",
            value=f"IC V=[{ic[0]:.4f},{ic[1]:.4f}], SE={ic[2]:.4f}",
            notes="delta-method")
    return {"ic_V": (ic[0], ic[1]), "trace_log": log}


def test_node(state: AgentState) -> dict:
    """Nodo de test: UMP para θ ↔ test de política (Teorema 9.8)."""
    wald = state["wald"]
    problem = _make_problem(state)
    theta0 = problem.cost_treat / (problem.cost_treat + problem.cost_skip)
    res = wald_test(wald.theta_hat, wald.n, theta0, alpha=0.05)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Thm 9.8", "test_node", "Control de error",
            value=f"z={res['z']:.3f}, p={res['p_value']:.4f}, "
                  f"dec={res['decision']}",
            notes="UMP ↔ política test")
    return {"test_stat": res["z"], "p_value": res["p_value"],
            "test_decision": res["decision"], "trace_log": log}


def verify_node(state: AgentState) -> dict:
    """Nodo de verificación: Protocolo Prop. 9.14 antes de garantizar."""
    from .verify import verify_guarantee
    wald = state["wald"]
    rewards = np.asarray(state["data"], dtype=float)
    # Leer trajectories y log_rho si están disponibles
    trajectories = state.get("trajectories", None)
    log_rho = state.get("log_rho", None)
    res = verify_guarantee(rewards=rewards,
                           trajectories=trajectories,
                           log_rho=log_rho)
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Prop 9.14", "verify_node", "Protocolo",
            value=f"transferable={res.transferable}, "
                  f"warnings={len(res.warnings)}",
            notes="; ".join(res.warnings) if res.warnings else "OK")
    return {"verification": res.as_dict(),
            "transferable": res.transferable,
            "fallback": res.fallback,
            "trace_log": log}


# ---------------------------------------------------------------------------
# Nodos de respaldo (fallback) — routing condicional desde verify_node
# ---------------------------------------------------------------------------
def fallback_conservative_node(state: AgentState) -> dict:
    """Nodo de respaldo: reporta que no se pueden emitir garantías
    y sugiere el estimador conservador identificado por Prop. 9.14."""
    fallback = state.get("fallback", "No disponible")
    log: TraceLog = state.get("trace_log", TraceLog())
    log.log("Prop 9.14", "fallback_conservative_node", "Protocolo",
            value=f"fallback={fallback}",
            notes="Garantías no invocadas; usando estrategia conservadora.")
    return {
        "fallback_activated": True,
        "fallback_strategy": fallback,
        "transferable": False,
        "trace_log": log,
    }


def fallback_robust_node(state: AgentState) -> dict:
    """Nodo de respaldo con IC robusto usando bootstrap.

    Cuando Prop. 9.14 detecta violación de mixing, usa block bootstrap
    para proveer un IC corregido por dependencia temporal."""
    from .bootstrap import block_bootstrap_v
    log: TraceLog = state.get("trace_log", TraceLog())
    trajectories = state.get("trajectories", None)

    if trajectories is not None and len(trajectories) > 0:
        def estimator(trajs):
            return float(np.mean([np.mean(t) for t in trajs]))
        boot_res = block_bootstrap_v(trajectories, estimator, n_boot=500)
        log.log("Prop 9.14", "fallback_robust_node", "Protocolo",
                value=f"ic_V={boot_res['ic']}, se={boot_res['se']:.4f}",
                notes="Block bootstrap (Liao et al. 2021) como fallback.")
        return {
            "ic_V": boot_res["ic"],
            "se_V_bootstrap": boot_res["se"],
            "fallback_activated": True,
            "fallback_strategy": "Block bootstrap + IC conservador",
            "trace_log": log,
        }
    else:
        log.log("Prop 9.14", "fallback_robust_node", "Protocolo",
                value="Sin trayectorias para bootstrap",
                notes="Usando fallback conservador genérico.")
        return fallback_conservative_node(state)


# ---------------------------------------------------------------------------
# Función de enrutamiento condicional
# ---------------------------------------------------------------------------
def route_after_verify(state: AgentState) -> str:
    """Enruta al nodo de respaldo apropiado según el resultado de la verificación.

    Returns:
        "end" si transferable=True,
        "fallback_conservative" si fallback genérico,
        "fallback_robust" si hay violación de mixing.
    """
    transferable = state.get("transferable", True)
    if transferable:
        return "end"
    fallback = state.get("fallback", "")
    # Si mixing falla, intentar bootstrap como respaldo
    if "mixing" in fallback.lower() or "bootstrap" in fallback.lower():
        return "fallback_robust"
    return "fallback_conservative"


# ---------------------------------------------------------------------------
# Construcción del grafo
# ---------------------------------------------------------------------------
def build_agent():
    """Construye el grafo LangGraph del agente v2."""
    g = StateGraph(AgentState)
    g.add_node("observation", observation_node)
    g.add_node("state", state_node)
    g.add_node("inference", inference_node)
    g.add_node("decision", decision_node)
    g.add_node("isomorphism", isomorphism_node)
    g.add_node("transfer", transfer_node)
    g.add_node("test", test_node)
    g.add_node("verify", verify_node)

    g.add_edge(START, "observation")
    g.add_edge("observation", "state")
    g.add_edge("state", "inference")
    g.add_edge("inference", "decision")
    g.add_edge("decision", "isomorphism")
    g.add_edge("isomorphism", "transfer")
    g.add_edge("transfer", "test")
    g.add_edge("test", "verify")
    g.add_node("fallback_conservative", fallback_conservative_node)
    g.add_node("fallback_robust", fallback_robust_node)

    g.add_conditional_edges(
        "verify",
        route_after_verify,
        {
            "end": END,
            "fallback_conservative": "fallback_conservative",
            "fallback_robust": "fallback_robust",
        }
    )
    g.add_edge("fallback_conservative", END)
    g.add_edge("fallback_robust", END)
    return g.compile()


def run_agent(data: np.ndarray,
              prior: Optional[dict] = None,
              loss_args: Optional[dict] = None,
              trajectories: Optional[list] = None,
              log_rho: Optional[np.ndarray] = None) -> AgentState:
    """Ejecuta el agente v2 sobre `data`."""
    agent = build_agent()
    initial = {"data": np.asarray(data),
               "prior": prior or {"alpha": 2.0, "beta": 2.0},
               "loss_args": loss_args or {"cost_treat": 0.2, "cost_skip": 1.0},
               "trace_log": TraceLog()}
    if trajectories is not None:
        initial["trajectories"] = trajectories
    if log_rho is not None:
        initial["log_rho"] = log_rho
    return agent.invoke(initial)
