import math
from collections import defaultdict
from agent.state import AgentState

N_STATES = 16
N_ACTIONS = 4


async def estimate_node(state: AgentState) -> AgentState:
    counts: dict = state.get("counts", {})
    trajectories: list = state.get("trajectories", [])
    gamma: float = state.get("gamma", 0.95)

    # --- UMVUE: θ̂(s,a,s') = N(s,a,s') / N(s,a)  [Lehmann-Scheffé] ---
    # Primero construir N(s,a) = Σ_s' N(s,a,s')
    n_sa: dict[tuple, int] = defaultdict(int)
    for (s, a, sp), cnt in counts.items():
        n_sa[(s, a)] += cnt

    theta_hat: dict[tuple, float] = {}
    for (s, a, sp), cnt in counts.items():
        total = n_sa[(s, a)]
        if total > 0:
            theta_hat[(s, a, sp)] = cnt / total

    # --- Estimador Monte Carlo bruto Q̂_MC(s,a) ---
    # Para cada par (s,a) recogemos todos los retornos descontados de trayectorias
    # que pasen por (s,a) (first-visit)
    returns_sa: dict[tuple, list[float]] = defaultdict(list)

    for episode in trajectories:
        visited = set()
        for t, (s, a, r, sp) in enumerate(episode):
            if (s, a) not in visited:
                visited.add((s, a))
                # Calcular retorno descontado desde el paso t
                G = 0.0
                for k, (_, _, r_k, _) in enumerate(episode[t:]):
                    G += (gamma ** k) * r_k
                returns_sa[(s, a)].append(G)

    q_mc: dict[tuple, float] = {}
    for (s, a), rets in returns_sa.items():
        q_mc[(s, a)] = float(sum(rets) / len(rets)) if rets else 0.0

    # --- Función de valor V̂^π(s) bajo política uniforme π(a|s) = 1/|A| ---
    value_hat: dict[int, float] = {}
    value_se: dict[int, float] = {}

    for s in range(N_STATES):
        returns_s: list[float] = []
        for a in range(N_ACTIONS):
            returns_s.extend(returns_sa.get((s, a), []))

        if returns_s:
            mean_v = sum(returns_s) / len(returns_s)
            if len(returns_s) > 1:
                std_v = math.sqrt(
                    sum((r - mean_v) ** 2 for r in returns_s) / (len(returns_s) - 1)
                )
                se_v = std_v / math.sqrt(len(returns_s))
            else:
                se_v = 0.0
            value_hat[s] = mean_v
            value_se[s] = se_v
        else:
            value_hat[s] = 0.0
            value_se[s] = 0.0

    return {
        **state,
        "theta_hat": theta_hat,
        "q_mc": q_mc,
        "value_hat": value_hat,
        "value_se": value_se,
    }
