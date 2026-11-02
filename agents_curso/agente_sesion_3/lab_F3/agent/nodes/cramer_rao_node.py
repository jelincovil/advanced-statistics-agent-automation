from collections import defaultdict
from agent.state import AgentState

EPSILON_TARGETS = [0.1, 0.05, 0.01]


async def cramer_rao_node(state: AgentState) -> AgentState:
    theta_hat: dict = state.get("theta_hat", {})
    counts: dict = state.get("counts", {})
    var_rb: dict = state.get("var_rb", {})
    history: list = list(state.get("history", []))

    # N(s,a) = Σ_s' N(s,a,s')
    n_sa: dict[tuple, int] = defaultdict(int)
    for (s, a, sp), cnt in counts.items():
        n_sa[(s, a)] += cnt

    # --- Fisher information I(θ̂) = 1 / (θ̂(1−θ̂)) ---
    # Con suavizado Laplace si θ̂ ∈ {0,1}
    fisher_info: dict[tuple, float] = {}
    cramer_rao_bound: dict[tuple, float] = {}

    for (s, a, sp), cnt in counts.items():
        theta = theta_hat.get((s, a, sp), 0.0)

        # Suavizado Laplace para evitar división por cero
        if theta <= 0.0 or theta >= 1.0:
            n_total = n_sa.get((s, a), 0)
            theta = (cnt + 1) / (n_total + 2)

        I_theta = 1.0 / (theta * (1.0 - theta))
        fisher_info[(s, a, sp)] = I_theta

        n_total = n_sa.get((s, a), 1)
        cramer_rao_bound[(s, a, sp)] = 1.0 / (n_total * I_theta)

    # --- Verificación empírica: var_rb[(s,a)] >= CR_bound[(s,a)] * 0.95 ---
    # Agrupamos CR bound por (s,a): usamos el mínimo CR_bound sobre s' (el más restrictivo)
    cr_by_sa: dict[tuple, float] = {}
    for (s, a, sp), cr in cramer_rao_bound.items():
        key = (s, a)
        cr_by_sa[key] = max(cr_by_sa.get(key, 0.0), cr)

    violations = 0
    checked = 0
    for (s, a), var in var_rb.items():
        cr = cr_by_sa.get((s, a), 0.0)
        if cr > 0:
            checked += 1
            if var < cr * 0.95:
                violations += 1

    violation_rate = violations / checked if checked > 0 else 0.0

    # --- Sample planning: n_min(ε) = 1 / (ε² · mean_I(θ)) ---
    all_fisher = list(fisher_info.values())
    mean_I = sum(all_fisher) / len(all_fisher) if all_fisher else 1.0

    min_episodes_for_target: dict[str, int] = {}
    for eps in EPSILON_TARGETS:
        n_min = int(1.0 / (eps ** 2 * mean_I)) + 1
        key = f"eps_{str(eps).replace('.', '_')}"
        min_episodes_for_target[key] = n_min

    # --- Actualizar historial con CR bound ---
    mean_cr = sum(cramer_rao_bound.values()) / len(cramer_rao_bound) if cramer_rao_bound else 0.0
    for snap in history:
        if snap.get("cr_bound_mean") is None:
            snap["cr_bound_mean"] = mean_cr

    return {
        **state,
        "fisher_info": fisher_info,
        "cramer_rao_bound": cramer_rao_bound,
        "min_episodes_for_target": min_episodes_for_target,
        "history": history,
        "_violation_rate": violation_rate,  # campo auxiliar para el analyst
    }
