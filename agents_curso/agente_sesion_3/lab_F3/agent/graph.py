from langgraph.graph import StateGraph, END

from agent.state import AgentState
from agent.nodes.collect_node import collect_node
from agent.nodes.decide_node import decide_node
from agent.nodes.estimate_node import estimate_node
from agent.nodes.rao_blackwell_node import rao_blackwell_node
from agent.nodes.cramer_rao_node import cramer_rao_node
from agent.nodes.analyst_node import analyst_node


def build_graph():
    builder = StateGraph(AgentState)

    # decide_node es un router (devuelve str) — no se añade como nodo
    builder.add_node("collect", collect_node)
    builder.add_node("estimate", estimate_node)
    builder.add_node("rao_blackwell", rao_blackwell_node)
    builder.add_node("cramer_rao", cramer_rao_node)
    builder.add_node("analyst", analyst_node)

    builder.set_entry_point("collect")

    # collect → decide_node (router) → collect | estimate | END
    builder.add_conditional_edges(
        "collect",
        decide_node,
        {
            "collect": "collect",
            "estimate": "estimate",
            "done": END,
        },
    )
    builder.add_edge("estimate", "rao_blackwell")
    builder.add_edge("rao_blackwell", "cramer_rao")
    builder.add_edge("cramer_rao", "analyst")
    builder.add_edge("analyst", END)

    return builder.compile()
