"""Emisión de episodios JSONL del contrato (Fase 1) para el agente OPE tabular
(agente v2), siguiendo EXACTAMENTE el TabularMDP canónico del laboratorio
(agent_graph.py): recompensas N(reward_means, 0.5), acción 0 avanza y acción 1
retrocede (0.8; queda 0.2), γ=0.9. La decisión es código: ε-greedy alrededor
del argmax del Q pseudo-óptimo que define_target_policy define allí.
"""
from __future__ import annotations

import random

import numpy as np

DEFAULT_EPSILON = 0.3
DEFAULT_SEED = 20261104
N_STATES, K, GAMMA = 5, 2, 0.9

# El mismo Q pseudo-óptimo que usa `define_target_policy` en agent_graph.py
Q_APPROX = np.array([
    [-0.5, -1.0],
    [0.0, -0.5],
    [0.5, 0.0],
    [1.0, 0.5],
    [1.5, 1.0],
])

# Medias de recompensa del TabularMDP del laboratorio (semilla canónica 42)
_REWARD_MEANS = np.random.RandomState(42).randn(N_STATES, K)


def transition(rng: random.Random, s: int, a: int) -> int:
    """a=0 avanza (w.p. 0.8), a=1 retrocede (0.8); queda 0.2."""
    if a == 0:
        nxt = min(s + 1, N_STATES - 1)
    else:
        nxt = max(s - 1, 0)
    return nxt if rng.random() < 0.8 else s


def emit_agent_v2(n_episodes: int = 24, horizon: int = 10,
                  epsilon: float = DEFAULT_EPSILON,
                  seed: int = DEFAULT_SEED,
                  policy_version: str = "opeagent-v2@1.0.0",
                  validate: bool = True) -> list[dict]:
    from agente_stats import validate_episode
    from agente_stats.core.episode_logger import c_max_epsilon_greedy, design_policy_epsilon_greedy

    rng = random.Random(seed)
    episodes = []
    for i in range(n_episodes):
        s = rng.randrange(N_STATES)
        steps = []
        for t in range(horizon):
            star = int(np.argmax(Q_APPROX[s]))
            probs = design_policy_epsilon_greedy(star, K, epsilon)
            a = 1 if rng.random() < probs["1"] else 0
            s_next = transition(rng, s, a)
            r = rng.gauss(_REWARD_MEANS[s, a], 0.5)
            steps.append({
                "t": t,
                "context": {"features": {"s": float(s)}},
                "action": a,
                "action_probs": probs,
                "propensity": probs[str(a)],
                "reward": r,
                "next_context": {"features": {"s": float(s_next)}},
            })
            s = s_next
        episodes.append({
            "episode_id": f"v2-{i:04d}",
            "unit": {"kind": "tabular-episode", "id": f"e-{i:04d}"},
            "policy_version": policy_version,
            "horizon": horizon,
            "propensity_mode": "recorded",
            "meta": {
                "seed": seed,
                "environment": "tabular 5x2; a0 avanza, a1 retrocede (0.8/0.2); R~N(mean(s,a),0.5)",
                "epsilon": epsilon,
                "exploration_rate": epsilon / K,
                "c_max": c_max_epsilon_greedy(epsilon, K),
                "decided_by": "code: argmax Q_APPROX (define_target_policy)",
                "gamma": GAMMA,
            },
            "steps": steps,
        })
    if validate:
        for e in episodes:
            issues = validate_episode(e)
            if issues:
                raise ValueError(f"episodio inválido generado: {e['episode_id']}: {issues[0]}")
    return episodes
