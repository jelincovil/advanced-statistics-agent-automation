"""
Experimentos del Laboratorio F.2

1. Benchmark de complejidad temporal: O(1) vs O(n²)
   - Estrategia suficiente: mantiene (count, total), actualización O(1)
   - Estrategia full-recompute: mantiene historial completo, recálculo O(n) por paso

2. Pérdida de información: D_KL(Bin(100,θ̂) || Bin(100,θ)) para ambos agentes.

Nota: el benchmark usa Python puro para medir complejidad algorítmica sin
overhead de LangGraph (los agentes LangGraph demuestran la arquitectura correcta;
estas funciones miden la diferencia asintótica).
"""

from __future__ import annotations

import time
from dataclasses import dataclass
from typing import List, Dict, Optional

import numpy as np


# ─── Benchmark: complejidad temporal ─────────────────────────────────────────

@dataclass
class BenchmarkResult:
    n: int
    t_suf: float           # segundos — agente suficiente O(n) total
    t_full: float          # segundos — recálculo completo O(n²) total
    theta_hat_suf: float   # estimación final (agente suficiente)
    theta_hat_full: float  # estimación final (recálculo)
    speedup: float         # t_full / t_suf


def _strategy_sufficient(obs: List[int]) -> tuple[float, float]:
    """O(n) total: dos sumas escalares por paso, O(1) por observación."""
    count, total = 0, 0
    t0 = time.perf_counter()
    for x in obs:
        count += 1
        total += x
    elapsed = time.perf_counter() - t0
    theta_hat = total / count if count > 0 else 0.5
    return theta_hat, elapsed


def _strategy_full_recompute(obs: List[int]) -> tuple[float, float]:
    """O(n²) total: recalcula sum(history)/len(history) en cada paso (O(n) por paso)."""
    history: List[int] = []
    theta_hat = 0.5
    t0 = time.perf_counter()
    for x in obs:
        history.append(x)
        theta_hat = sum(history) / len(history)
    elapsed = time.perf_counter() - t0
    return theta_hat, elapsed


def run_benchmark(
    sample_sizes: Optional[List[int]] = None,
    theta_true: float = 0.3,
    seed: int = 42,
    skip_large: bool = False,
) -> List[BenchmarkResult]:
    """
    Ejecuta el benchmark de complejidad temporal para los tamaños dados.

    Args:
        sample_sizes: Lista de n valores. Por defecto [100, 1000, 10000, 100000].
        theta_true:   Parámetro de la distribución generadora.
        seed:         Semilla aleatoria para reproducibilidad.
        skip_large:   Si True, omite n > 10000 (el full-recompute para n=100000
                      puede tardar ~4 minutos).
    """
    if sample_sizes is None:
        sample_sizes = [100, 1000, 10000, 100000]

    rng = np.random.default_rng(seed)
    results: List[BenchmarkResult] = []

    for n in sample_sizes:
        if skip_large and n > 10_000:
            print(f"  n={n:>7}: omitido (--skip-large). "
                  "El recálculo O(n²) puede tardar varios minutos.")
            continue

        obs = rng.binomial(1, theta_true, n).tolist()
        theta_suf, t_suf = _strategy_sufficient(obs)
        theta_full, t_full = _strategy_full_recompute(obs)
        speedup = t_full / t_suf if t_suf > 0 else float("inf")

        results.append(BenchmarkResult(
            n=n,
            t_suf=t_suf,
            t_full=t_full,
            theta_hat_suf=theta_suf,
            theta_hat_full=theta_full,
            speedup=speedup,
        ))

    return results


# ─── Pérdida de información: D_KL ─────────────────────────────────────────────

def run_info_loss_experiment(
    n: int = 1000,
    theta_true: float = 0.3,
    seed: int = 42,
) -> Dict:
    """
    Tras n observaciones, compara D_KL de ambos agentes respecto a theta_true.

    Usa los agentes LangGraph para calcular las estimaciones; KL se calcula
    con distribución predictiva Bin(100, θ̂).

    Returns:
        Diccionario con resultados de ambos agentes: theta_hat y kl.
    """
    from sufficient_agent import run_agent
    from baseline_agent import run_baseline

    rng = np.random.default_rng(seed)
    obs = rng.binomial(1, theta_true, n).tolist()

    result_suf = run_agent(obs, theta_true=theta_true)
    result_bas = run_baseline(obs, theta_true=theta_true)

    return {
        "n": n,
        "theta_true": theta_true,
        "sufficient": {
            "theta_hat": result_suf["theta_hat"],
            "kl": result_suf["kl"],
            "count": result_suf["count"],
            "total": result_suf["total"],
        },
        "insufficient": {
            "theta_hat": result_bas["theta_hat"],
            "kl": result_bas["kl"],
            "n": result_bas["n"],
            "mean": result_bas["mean"],
        },
        "delta_kl": (result_bas["kl"] or 0.0) - (result_suf["kl"] or 0.0),
    }
