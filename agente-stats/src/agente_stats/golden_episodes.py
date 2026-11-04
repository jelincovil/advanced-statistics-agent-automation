"""Generador de episodios dorados de los dos agentes instrumentados (Fase 0).

Produce los datasets de ejemplo del contrato:
  - agent_v1_episodes.jsonl — el agente del isomorfismo (Wald/Bernoulli-Beta):
    decisión en código por regla de Bayes con pérdida asimétrica; comportamiento
    ε-greedy por diseño (los números clave son variables abajo).
  - agent_v2_episodes.jsonl — el agente OPE tabular: ε-greedy alrededor de la
    política greedy del MDP tabular, H = 5 pasos por episodio.

Detalles: usa solo stdlib (random.Random), sin numpy; todo es determinista
dada la semilla; después de escribir, cada archivo se valida contra
`schemas.load_jsonl` (la regeneración se prueba a sí misma).
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path

from .schemas import load_jsonl

DEFAULT_EPSILON = 0.3
SEED_V1 = 20261103
SEED_V2 = 20261104

# ---------------------------------------------------------------------------
# Agente v1 — mundo Wald/Bernoulli-Beta (isomorfismo)
# ---------------------------------------------------------------------------
V1_LOSS_TREAT = 0.2  # c: tratar sin necesidad
V1_LOSS_SKIP = 1.0   # d: no tratar necesitándolo (falso negativo)
V1_THRESHOLD = V1_LOSS_TREAT / (V1_LOSS_TREAT + V1_LOSS_SKIP)  # 1/6


def v1_argmax_action(alpha: float, beta: float) -> int:
    """Regla de Bayes por minimización de pérdida posterior (código, no LLM)."""
    return int(alpha / (alpha + beta) > V1_THRESHOLD)


def _eps_greedy_probs(star: int, k: int, epsilon: float) -> dict[str, float]:
    base = epsilon / k
    return {str(a): (1 - epsilon + base) if a == star else base for a in range(k)}


def gen_agent_v1(n_episodes: int = 40, seed: int = SEED_V1,
                 epsilon: float = DEFAULT_EPSILON, n_draws: int = 10) -> list[dict]:
    """Episodios H=1: θ ~ Beta(2,2), s ~ Binomial(n_draws, θ), posterior Beta,
    acción argmax de Bayes mezclada con exploración ε por diseño; recompensa
    = −L(θ, a) (pérdida asimétrica de tratamiento)."""
    rng = random.Random(seed)
    K = 2
    c_max = 1 + K * (1 - epsilon) / epsilon
    episodes = []
    for i in range(n_episodes):
        theta = rng.betavariate(2.0, 2.0)
        s = sum(1 for _ in range(n_draws) if rng.random() < theta)
        alpha, beta = 1.0 + s, 1.0 + (n_draws - s)
        star = v1_argmax_action(alpha, beta)
        probs = _eps_greedy_probs(star, K, epsilon)
        a = 1 if rng.random() < probs["1"] else 0
        loss = (1 - theta) * V1_LOSS_TREAT if a == 1 else theta * V1_LOSS_SKIP
        episodes.append({
            "episode_id": f"v1-{i:04d}",
            "unit": {"kind": "simulated-post-decision", "id": f"u-{i:04d}"},
            "policy_version": f"isoagent-v1@1.0",
            "horizon": 1,
            "propensity_mode": "recorded",
            "meta": {"epsilon": epsilon, "exploration_rate": epsilon / K,
                     "c_max": c_max, "seed": seed,
                     "environment": "theta~Beta(2,2); s~Binomial(10,theta)"},
            "steps": [{
                "t": 0,
                "context": {"features": {"n": float(n_draws), "s": float(s),
                                        "alpha": alpha, "beta": beta}},
                "action": a,
                "action_probs": probs,
                "propensity": probs[str(a)],
                "reward": -loss,
            }],
        })
    return episodes


# ---------------------------------------------------------------------------
# Agente v2 — mundo OPE tabular (5 estados, 2 acciones, H=5)
# ---------------------------------------------------------------------------
V2_STATES = 5
V2_GAMMA = 0.9
V2_REWARD_SD = 0.1


def v2_transition(rng: random.Random, s: int, a: int) -> int:
    if a == 1:
        return min(s + 1, V2_STATES - 1) if rng.random() < 0.8 else s
    return max(s - 1, 0) if rng.random() < 0.8 else s


def v2_reward_mean(s: int, a: int) -> float:
    return (a * s) / (V2_STATES - 1) if a == 1 else 0.05


def v2_greedy_policy() -> dict[int, int]:
    """Q* por iteración de valor exacta del MDP tabular (define_target_policy
    ya calcula esto en el agente original; aquí se reimplementa mínimo)."""
    V = [0.0] * V2_STATES
    R = [[v2_reward_mean(s, a) for a in range(2)] for s in range(V2_STATES)]
    T = {0: lambda s: max(s - 1, 0), 1: lambda s: min(s + 1, V2_STATES - 1)}
    for _ in range(200):
        new = []
        for s in range(V2_STATES):
            q = [R[s][a] + V2_GAMMA * (0.8 * V[T[a](s)] + 0.2 * V[s]) for a in range(2)]
            new.append(max(q))
        if max(abs(a - b) for a, b in zip(new, V)) < 1e-12:
            break
        V = new
    return {s: int(max(range(2), key=lambda a: R[s][a] + V2_GAMMA * (0.8 * V[T[a](s)] + 0.2 * V[s])))
            for s in range(V2_STATES)}


def gen_agent_v2(n_episodes: int = 24, seed: int = SEED_V2,
                 epsilon: float = DEFAULT_EPSILON) -> list[dict]:
    """Episodios de H=5 con context.features = {"s": estado}, comportamiento
    ε-greedy alrededor de la política greedy exacta."""
    rng = random.Random(seed)
    K = 2
    c_max = 1 + K * (1 - epsilon) / epsilon
    greedy = v2_greedy_policy()
    episodes = []
    for i in range(n_episodes):
        s = rng.randrange(V2_STATES)
        steps = []
        for t in range(5):
            star = greedy[s]
            probs = _eps_greedy_probs(star, K, epsilon)
            a = 1 if rng.random() < probs["1"] else 0
            s_next = v2_transition(rng, s, a)
            r = rng.gauss(v2_reward_mean(s, a), V2_REWARD_SD)
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
            "policy_version": "opeagent-v2@1.0",
            "horizon": 5,
            "propensity_mode": "recorded",
            "meta": {"epsilon": epsilon, "exploration_rate": epsilon / K,
                     "c_max": c_max, "seed": seed, "gamma": V2_GAMMA,
                     "environment": "tabular 5x2; T: ±1 w.p. 0.8; R~N(mean,0.1)"},
            "steps": steps,
        })
    return episodes


def write_jsonl(episodes: list[dict], path) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        for e in episodes:
            fh.write(json.dumps(e, ensure_ascii=False) + "\n")
    return path


def main(outdir: str | Path = "examples") -> None:
    outdir = Path(outdir)
    v1 = gen_agent_v1()
    v2 = gen_agent_v2()
    p1 = outdir / "agent_v1_episodes.jsonl"
    p2 = outdir / "agent_v2_episodes.jsonl"
    write_jsonl(v1, p1)
    write_jsonl(v2, p2)
    # la regeneración se valida a sí misma contra el contrato
    load_jsonl(p1)
    load_jsonl(p2)
    print(f"OK: {len(v1)} episodios v1 -> {p1}; {len(v2)} episodios v2 -> {p2}")


if __name__ == "__main__":
    main()
