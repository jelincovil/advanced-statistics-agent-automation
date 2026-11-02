from agent.state import AgentState


def decide_node(state: AgentState) -> str:
    if state.get("n_collected", 0) < state.get("n_episodes", 500):
        return "collect"
    elif state.get("mode") == "estimate":
        return "estimate"
    else:
        return "done"
