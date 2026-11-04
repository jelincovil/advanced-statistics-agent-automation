"""Registro de episodios JSONL del contrato de Fase 0 (instrumentación por diseño).

Pieza compartida entre los dos agentes adecuados del proyecto MCP:
`capitulo_09_isomorfismo` (agente v1) y `capitulo_10_ope` (agente v2).

- `design_policy_epsilon_greedy(star, k, epsilon)` devuelve la distribución
  completa por paso tal como pedía el contrato del plan (para registrarla,
  no para estimarla después).
- `sample_action(rng, probs)` elige una acción según la distribución.
- `c_max_epsilon_greedy(epsilon, k)` es la cota de pesos IS por construcción,
  que el logger deja en la cabecera del episodio (`meta.c_max`) junto con la
  tasa de exploración: la ficha la mostrará automáticamente (plan v2.1, §9.5-2).
- `EpisodeLogger` acumula pasos y emite una línea JSONL validable con
  `agente_stats.schemas.load_jsonl`.

Todo es determinista dada la semilla y stdlib-only.
"""
from __future__ import annotations

import json
import random
from pathlib import Path

SCHEMA_VERSION = "0.1.0"


def design_policy_epsilon_greedy(star: int, k: int, epsilon: float) -> dict[str, float]:
    """π_b por diseño: (1-ε) en la acción estrella, ε/K en cada una."""
    if not (0 < k and isinstance(k, int)):
        raise ValueError("k debe ser entero positivo")
    if not (0.0 <= epsilon <= 1.0):
        raise ValueError("epsilon debe estar en [0,1]")
    if not (0 <= star < k):
        raise ValueError("star fuera del rango de acciones")
    base = epsilon / k
    return {str(a): (1.0 - epsilon + base) if a == star else base for a in range(k)}


def sample_action(rng: random.Random, probs: dict[str, float]) -> str:
    """Elige una acción según la distribución (rng.compartido por episodio)."""
    items = sorted(probs.items(), key=lambda kv: kv[0])
    u = rng.random()
    acc = 0.0
    for a, p in items:
        acc += p
        if u <= acc + 1e-15:
            return a
    return items[-1][0]


def c_max_epsilon_greedy(epsilon: float, k: int) -> float:
    """C_max = 1 + K(1-ε)/ε: cota uniforme de la razón e/b Δ-greedy."""
    if epsilon <= 0:
        return float("inf")
    return 1.0 + k * (1.0 - epsilon) / epsilon


class EpisodeLogger:
    """Acumula un episodio del contrato y lo valida contra `agente_stats.schemas`.

    La política se declara una vez congelada por episodio (`policy_version`);
    la UNIDAD estadística es la tupla (kind, id) elegida por el llamante.
    """

    def __init__(self, episode_id: str, unit: dict, policy_version: str,
                 horizon: int, environment: str, seed: int,
                 epsilon: float, k: int,
                 propensity_mode: str = "recorded",
                 estimated_by: str | None = None):
        self.episode = {
            "episode_id": episode_id,
            "unit": unit,
            "policy_version": policy_version,
            "horizon": horizon,
            "propensity_mode": propensity_mode,
            "meta": {
                "schema_version": SCHEMA_VERSION,
                "seed": seed,
                "environment": environment,
                "epsilon": epsilon,
                "exploration_rate": epsilon / k if k else None,
                "c_max": c_max_epsilon_greedy(epsilon, k),
            },
            "steps": [],
        }
        if estimated_by is not None:
            self.episode["meta"]["estimated_by"] = estimated_by

    def log_step(self, t: int, context: dict, action, probs: dict | None,
                 reward: float, next_context: dict | None = None) -> None:
        """Registra un paso. `probs` es la distribución por diseño completa
        (obligatoria en agentes instrumentados)."""
        step = {
            "t": t,
            "context": context,
            "action": action,
            "reward": reward,
        }
        if probs is not None:
            step["action_probs"] = probs
            step["propensity"] = probs[str(action)]
        if next_context is not None:
            step["next_context"] = next_context
        self.episode["steps"].append(step)

    def to_dict(self) -> dict:
        if not self.episode["steps"]:
            raise ValueError(f"episodio {self.episode['episode_id']}: sin pasos")
        if len(self.episode["steps"]) != self.episode["horizon"]:
            raise ValueError(f"episodio {self.episode['episode_id']}: "
                             f"horizon={self.episode['horizon']} pero "
                             f"{len(self.episode['steps'])} pasos")
        return self.episode


def write_jsonl(episodes: list[dict], path: str | Path) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as fh:
        for e in episodes:
            fh.write(json.dumps(e, ensure_ascii=False) + "\n")
    return path
