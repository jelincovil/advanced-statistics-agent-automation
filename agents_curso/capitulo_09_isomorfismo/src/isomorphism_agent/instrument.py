"""Emisión de episodios JSONL del contrato (Fase 0/Fase 1 del proyecto MCP).

El episodio es EXTERNO al grafo LangGraph (misma semántica que `run_agent`):
observa el estadístico Bernoulli, fija el posterior, calcula δ* por la misma
regla de código, y registra UNA acción ε-greedy por diseño como su registro
de comportamiento — así la propensión existe "por diseño" y no por
estimación ex post. Es el régimen más fuerte del libro aplicado al propio
material del curso.

`emit_agent_v1(...)` produce episodios H=1 del contrato
`agente_stats.schemas`, validados aquí mismo si `agente_stats` está visible.
La semilla del RNG nacional es compartida por episodio (determinista).
"""
from __future__ import annotations

import random

from .wald import WaldProblem

# Defaults del problema estándar del curso (cost_treat=0.2, cost_skip=1.0)
DEFAULT_COST_TREAT = 0.2
DEFAULT_COST_SKIP = 1.0
DEFAULT_EPSILON = 0.3
DEFAULT_SEED = 20261103


def emit_agent_v1(n_episodes: int = 40,
                  data_draws: int = 10,
                  prior: dict | None = None,
                  epsilon: float = DEFAULT_EPSILON,
                  seed: int = DEFAULT_SEED,
                  policy_version: str = "isoagent-v1@2.3.0",
                  validate: bool = True) -> list[dict]:
    """Genera episodios H=1 del agente isomorfismo (decisión en código).

    Mundo: θ ~ Beta(2,2); observación s ~ Binomial(n_draws, θ); el agente
    (como flujo): posterior Beta, δ* de Bayes por minimización de pérdida.
    Comportamiento registrado: ε-greedy(δ*).
    """
    prior = prior or {"alpha": 2.0, "beta": 2.0}
    problem = WaldProblem(cost_treat=DEFAULT_COST_TREAT, cost_skip=DEFAULT_COST_SKIP)
    from .wald import bayes_rule  # local import to keep module cheap

    from agente_stats.core.episode_logger import (
        c_max_epsilon_greedy, design_policy_epsilon_greedy,
    )

    rng = random.Random(seed)
    K = 2
    episodes = []
    for i in range(n_episodes):
        theta = rng.betavariate(2.0, 2.0)
        s = sum(1 for _ in range(data_draws) if rng.random() < theta)
        alpha = prior["alpha"] + s
        beta = prior["beta"] + data_draws - s
        delta_star = bayes_rule(alpha, beta, problem)
        probs = design_policy_epsilon_greedy(delta_star, K, epsilon)
        # acción del comportamiento según la distribución por diseño
        a = 1 if rng.random() < probs["1"] else 0
        post_mean = alpha / (alpha + beta)
        loss = ((1.0 - theta) * DEFAULT_COST_TREAT if a == 1
                else theta * DEFAULT_COST_SKIP)
        episode = {
            "episode_id": f"v1-{i:04d}",
            "unit": {"kind": "simulated-post-decision", "id": f"u-{i:04d}"},
            "policy_version": policy_version,
            "horizon": 1,
            "propensity_mode": "recorded",
            "meta": {
                "seed": seed,
                "environment": f"theta~Beta(2,2); s~Binomial({data_draws},theta)",
                "epsilon": epsilon,
                "exploration_rate": epsilon / K,
                "c_max": c_max_epsilon_greedy(epsilon, K),
                "decided_by": "code: bayes_rule (threshold c/(c+d))",
                "loss": {"cost_treat": DEFAULT_COST_TREAT,
                         "cost_skip": DEFAULT_COST_SKIP},
            },
            "steps": [{
                "t": 0,
                "context": {"features": {
                    "n": float(data_draws), "s": float(s),
                    "alpha": alpha, "beta": beta, "post_mean": post_mean}},
                "action": a,
                "action_probs": probs,
                "propensity": probs[str(a)],
                "reward": -loss,
            }],
        }
        episodes.append(episode)
    if validate:
        from agente_stats import validate_episode
        for e in episodes:
            issues = validate_episode(e)
            if issues:
                raise ValueError(f"episodio inválido generado: {e['episode_id']}: {issues[0]}")
    return episodes
