"""Comparación de versiones de política (Fase 2).

Δ = J(nuevo) − J(viejo) sobre los logs del comportamiento registrado, con
IC por Welch sobre contribuciones pareadas por episodio. Con DR, ambos
targets usan el MISMO modelo entrenado POR FOLD: la comparación no queda
dominada por un modelo distinto entre versiones.
"""
from __future__ import annotations

import statistics
from dataclasses import dataclass
from typing import Callable

from .ope import fit_value_model

DEFAULT_LEVEL = 0.95
DEFAULT_ESTIMATOR = "DR"


@dataclass
class VersionComparison:
    delta: float
    se: float
    ci95: tuple[float, float]
    level: float
    estimator: str
    n_units: int
    ess_fraction: float
    value_new: float | None
    value_old: float | None
    notes: tuple[str, ...]


def _v_from(target: dict, m, s: int) -> float:
    return sum(float(target.get((s, a), 0.0)) * m(s, a) for a in range(2))


def _target_prob(target: Callable | dict, a, ctx: dict) -> float:
    if callable(target):
        return float(target(a, ctx))
    s = ctx.get("features", {}).get("s")
    p = target.get((int(s) if s is not None else None, a))
    if p is None:
        raise ValueError(f"política target no cubre a={a}, contexto={ctx.get('features')}")
    return float(p)


def _weights(episodes: list[dict], target: Callable | dict):
    w_trajs, w_steps_all = [], []
    for e in episodes:
        w = 1.0
        hold = []
        for t, step in enumerate(e["steps"]):
            p_e = _target_prob(target, step["action"], step["context"])
            b_p = float(step["propensity"])
            if b_p <= 0:
                raise ValueError(f"propensity no positiva en {e['episode_id']}, t={t}")
            w *= p_e / b_p
            hold.append(w)
        w_trajs.append(w)
        w_steps_all.append(hold)
    return w_trajs, w_steps_all


def _eff_fraction(w):
    n = len(w)
    return (sum(w) ** 2) / (n * sum(x * x for x in w))


def _ci_welch(xs, level):
    n = len(xs)
    m = statistics.mean(xs)
    if n < 2:
        return m, float("nan"), (float("nan"), float("nan"))
    se = statistics.stdev(xs) / (n ** 0.5)
    z = 1.959963984540054 if abs(level - 0.95) < 1e-9 else 2.575829303548901
    return m, se, (m - z * se, m + z * se)


def compare_versions(episodes: list[dict],
                     target_new: Callable | dict,
                     target_old: Callable | dict,
                     estimator: str = DEFAULT_ESTIMATOR,
                     level: float = DEFAULT_LEVEL,
                     cross_fit: bool = True) -> VersionComparison:
    if not episodes:
        raise ValueError("episodes: lista vacía")
    modes = {e["propensity_mode"] for e in episodes}
    if modes != {"recorded"}:
        raise ValueError(f"comparación exige mode='recorded': {sorted(modes)}")
    gamma = episodes[0]["meta"].get("gamma", 1.0)
    n = len(episodes)
    w_new_trajs, w_new_steps = _weights(episodes, target_new)
    w_old_trajs, w_old_steps = _weights(episodes, target_old)

    if estimator == "IS":
        gs = [sum((gamma ** t) * s["reward"] for t, s in enumerate(e["steps"])) for e in episodes]
        xs = [(w_new_trajs[i] - w_old_trajs[i]) * gs[i] for i in range(n)]
        value, se, ci = _ci_welch(xs, level)
        return VersionComparison(value, se, ci, level, estimator, n,
                                 _eff_fraction(w_new_trajs),
                                 _ci_welch([w_new_trajs[i] * gs[i] for i in range(n)], level)[0],
                                 _ci_welch([w_old_trajs[i] * gs[i] for i in range(n)], level)[0],
                                 tuple())

    if not (isinstance(target_new, dict) and isinstance(target_old, dict)):
        raise ValueError("DR con este núcleo espera dicts {(s,a): p} (laboratorio tabular)")
    folds = [list(range(k, n, 2)) for k in range(2)] if cross_fit else [list(range(n))]
    xs = []
    for fold in folds:
        train_idx = [i for i in range(n) if i not in fold] if cross_fit else list(range(n))
        m = fit_value_model([episodes[i] for i in train_idx])
        for i in fold:
            s0 = int(episodes[i]["steps"][0]["context"]["features"]["s"])
            Dn = _v_from(target_new, m, s0)
            Do = _v_from(target_old, m, s0)
            for t, st in enumerate(episodes[i]["steps"]):
                s_t = int(st["context"]["features"]["s"])
                s_next = int(st.get("next_context", {}).get("features", {}).get("s", s_t))
                q_now = m(s_t, st["action"])
                va_next = _v_from(target_new, m, s_next)
                vb_next = _v_from(target_old, m, s_next)
                delta = st["reward"]
                Dn += (gamma ** t) * w_new_steps[i][t] * (delta + va_next - q_now)
                Do += (gamma ** t) * w_old_steps[i][t] * (delta + vb_next - q_now)
            xs.append(Dn - Do)
    value, se, ci = _ci_welch(xs, level)
    return VersionComparison(value, se, ci, level, estimator, n,
                             _eff_fraction(w_new_trajs), None, None, tuple())
