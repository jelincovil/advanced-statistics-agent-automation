"""
graph.py — Assemble the LangGraph StateGraph.

Topology:

      observar -> posterior -> riesgo_bayes -> riesgo_minimax -> meta_selector -> END

The two risk nodes could run in parallel; we keep them sequential for
clarity. Replace with `add_edge(..., parallel=True)` in production.
"""
from typing import Callable
import numpy as np

# LangGraph is imported lazily so this module can be imported even if the
# user has not installed it yet (useful for running the test suite, which
# exercises the node functions directly without going through the graph).
try:
    from langgraph.graph import StateGraph, END
    HAS_LANGGRAPH = True
except ImportError:                                     # pragma: no cover
    HAS_LANGGRAPH = False
    StateGraph, END = None, None                        # type: ignore

from .state import AgentState
from .nodes import (
    observar, riesgo_bayes, riesgo_minimax, meta_selector,
    make_posterior_node,
)


def build_graph(predict_proba: Callable[[np.ndarray], float]):
    """
    Build and compile the LangGraph agent. `predict_proba(x) -> p_bad`
    is injected so the graph stays decoupled from any specific model.
    """
    if not HAS_LANGGRAPH:
        raise ImportError(
            "langgraph is not installed. Run `pip install langgraph` "
            "or use the node functions directly (see tests/test_sanity.py)."
        )

    posterior = make_posterior_node(predict_proba)

    g = StateGraph(AgentState)
    g.add_node("observar",       observar)
    g.add_node("posterior",      posterior)
    g.add_node("riesgo_bayes",   riesgo_bayes)
    g.add_node("riesgo_minimax", riesgo_minimax)
    g.add_node("meta_selector",  meta_selector)

    g.set_entry_point("observar")
    g.add_edge("observar",       "posterior")
    g.add_edge("posterior",      "riesgo_bayes")
    g.add_edge("riesgo_bayes",   "riesgo_minimax")
    g.add_edge("riesgo_minimax", "meta_selector")
    g.add_edge("meta_selector",  END)
    return g.compile()
