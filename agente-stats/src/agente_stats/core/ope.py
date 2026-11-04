"""OPE del núcleo del proyecto (Fase 2), sobre episodios del contrato v1/v2.

Decisiones de diseño (alignadas con el libro y el plan v2.1):
- Las políticas se declare como FUNCIONES/DICTS de probabilidades completas.
  Con `propensity_mode='recorded'` la política de comportamiento existe por
  diseño; aquí no se estima ninguna (eso queda para régimen degradado).
- IS: J = (1/n) Σ W_trayectoria · G con los pesos producto exactos.
- DR secuencial PDIS-aumentado: contribución D_i = v̂(S₀) + Σ_t γᵗ W_t Δ_t
  con W producto y el modelo de valor entrenado FUERA del episodio
  evaluado si cross_fit=True. Una episode es una unidad indep. Todo truncamiento
  y decisión de régimen produce una nota DATA (sale en la ficha).

Devuelve siempre el resumen acotado (regla MCP): estimador, se, IC Welch
sobre unidades independientes, ESS diagnóstico y notas — nunca filas
crudas de logging.
"""
from __future__ import annotations

import math
import statistics
from dataclasses import dataclass
from typing import Callable

MAX_WEIGHT_DEFAULT = 10.0


@dataclass
class OpeResult:
    estimator: str
    value: float
    se: float
    ci95: tuple[float, float]
    level: float
    n_units: int
    ess_fraction: float
    eff_samples: float
    truncated: bool
    max_weight_used: float | None
    mean_weight: float
    max_weight_observed: float
    regime: str
    notes: tuple[str, ...]


# ----------------------------------------------------------------------
# Extracción y validación
# ----------------------------------------------------------------------
def _validate(episodes: list[dict], target: Callable | dict) -> None:
    if not episodes:
        raise ValueError("episodes: lista vacía (declara al menos una unidad)")
    modes = {e["propensity_mode"] for e in episodes}
    if modes != {"recorded"}:
        raise ValueError(
            f"OPE de este núcleo exige propensión registrada por diseño "
            f"(mode='recorded'). Encontrado: {sorted(modes)}. "
            "Con 'estimated' o 'missing' la salida debe degradarse a región/"
            "diagnóstico — declara el régimen en la ficha antes de estimar.")


def _target_prob(target: Callable | dict, a, ctx: dict, t_idx: int) -> float:
    if callable(target):
        p = target(a, ctx)
    else:
        s = ctx.get("features", {}).get("s")
        p = target.get((int(s) if s is not None else None, a))
    if p is None:
        raise ValueError(f"política target no cubre (a={a}, contexto={ctx.get('features')}); "
                         "declara la distribución completa de acciones para los pasos registrados")
    p = float(p)
    if not (0.0 <= p <= 1.0):
        raise ValueError(f"probabilidad target fuera de [0,1]: {p!r}")
    return p


def _weights(episodes: list[dict], target: Callable | dict) -> tuple[list[float], list[list[float]]]:
    w_trajs, w_steps_all = [], []
    for i, e in enumerate(episodes):
        w = 1.0
        w_hold = []
        for t, step in enumerate(e["steps"]):
            p_e = _target_prob(target, step["action"], step["context"], t)
            b_p = float(step["propensity"])
            if b_p <= 0:
                raise ValueError(
                    f"propensity {b_p} no positiva en {e['episode_id']}, t={t}; "
                    "la identificación requiere probabilidad de registro positiva en soporte de pasos")
            w *= p_e / b_p
            w_hold.append(w)
        w_trajs.append(w)
        w_steps_all.append(w_hold)
    return w_trajs, w_steps_all


def _weights_summary(w: list[float]) -> tuple[float, float, float, float]:
    n = len(w)
    m = statistics.mean(w)
    den = sum(x * x for x in w)
    if den <= 0:
        raise ValueError(
            "OPE no identificada: la política objetivo tiene masa nula en el log "
            "(todos los pesos son 0). Declara una target con soporte cubierto por "
            "el comportamiento antes de estimar (ESS=0).")
    ess = (sum(w) ** 2) / (n * den)
    return m, max(w), ess, n * ess


def _ci_welch(xs: list[float], level: float) -> tuple[float, float, float, float]:
    n = len(xs)
    m = statistics.mean(xs)
    if n < 2:
        return m, float("nan"), (float("nan"), float("nan")), float("nan")
    sd = statistics.stdev(xs)
    se = sd / math.sqrt(n)
    z = 1.959963984540054 if abs(level - 0.95) < 1e-9 else 2.575829303548901
    return m, se, (m - z * se, m + z * se), z


# ----------------------------------------------------------------------
# IS por trayectoria
# ----------------------------------------------------------------------
def estimate_is(episodes: list[dict], target: Callable | dict,
                level: float = 0.95, truncate: bool = False,
                max_weight: float = MAX_WEIGHT_DEFAULT) -> OpeResult:
    """IS por trayectoria: J = (1/n) Σ W G, G = Σ γᵗ R_t con γ del meta (1 por defecto).
    truncate = reclaiming capped weights (sesgo introducido; certified abajo).
    """
    _validate(episodes, target)
    gamma = episodes[0]["meta"].get("gamma", 1.0)
    w_trajs, _ = _weights(episodes, target)
    if truncate:
        w_trajs = [min(w, max_weight) for w in w_trajs]
    gs = [sum((gamma ** t) * s["reward"] for t, s in enumerate(e["steps"])) for e in episodes]
    xs = [w_trajs[i] * gs[i] for i in range(len(episodes))]
    value, se, ci, _ = _ci_welch(xs, level=level)
    mean_w, max_w, ess, eff = _weights_summary(w_trajs)
    notes = [f"pesos truncados a max={max_weight}: sesgo introducido, declarado"] if truncate else []
    return OpeResult("IS", value, se, ci, level, len(episodes),
                     ess, eff, truncate, max_weight if truncate else None,
                     mean_w, max_w, episodes[0]["meta"].get("environment", ""),
                     tuple(notes))


# ----------------------------------------------------------------------
# Modelo de valor tabular (laboratorio v2), entrenado POR FOLD
# ----------------------------------------------------------------------
def fit_value_model(train_episodes: list[dict]):
    """m(s, a) = media de recompensa en (s, a) por frecuencias; el llamante
    decide qué episodios componen el entrenamiento (cruza por unidades,
    nunca por pasos).
    """
    from collections import defaultdict
    bucket: dict = defaultdict(list)
    for e in train_episodes:
        for s in e["steps"]:
            bucket[(int(s["context"]["features"]["s"]), s["action"])].append(s["reward"])
    means = {k: statistics.mean(v) for k, v in bucket.items() if v}
    fallback = statistics.mean(v for v in means.values()) if means else 0.0

    def m(s: int, a) -> float:
        return means.get((s, a), fallback)
    return m


def _v_from_m(target: dict, m, s: int, n_actions: int = 2) -> float:
    return sum(float(target.get((s, a), 0.0)) * m(s, a) for a in range(n_actions))


# ----------------------------------------------------------------------
# DR secuencial (una decisión si H=1, longitudinal si H>1)
# ----------------------------------------------------------------------
def estimate_dr(episodes: list[dict], target: Callable | dict,
                level: float = 0.95, cross_fit: bool = True,
                n_folds: int = 2) -> OpeResult:
    """DR por trayectoria con contribución
    D_i = v̂(S₀) + Σ_t γᵗ W_{i,t} (R_t + γ v̂(S_{t+1}) − q̂(S_t, A_t)).
    (q̂ comes de m, y el modelo se entrena fuera del episodio evaluado si
    cross_fit=True). Requiere target=dict para espacios tabulares (dict global)."""
    _validate(episodes, target)
    if not isinstance(target, dict):
        raise ValueError("DR secuencial con este núcleo espera target=dict {(s,a): p}: "
                         "con el modelo tabular del laboratorio; para funciones "
"hablar con la lwunción vague se pierde la garantía exacta de W por trayectoria")
    gamma = episodes[0]["meta"].get("gamma", 1.0)
    w_trajs, w_steps_all = _weights(episodes, target)
    n = len(episodes)
    folds = [list(range(k, n, n_folds)) for k in range(n_folds)] if cross_fit else [list(range(n))]
    xs = []
    for fold in folds:
        train_idx = [i for i in range(n) if i not in fold] if cross_fit else list(range(n))
        m = fit_value_model([episodes[i] for i in train_idx])
        for i in fold:
            s0 = int(episodes[i]["steps"][0]["context"]["features"]["s"])
            total = _v_from_m(target, m, s0)
            for t, step in enumerate(episodes[i]["steps"]):
                s_t = int(step["context"]["features"]["s"])
                s_next = int(step.get("next_context", {}).get("features", {}).get("s", s_t))
                q_now = m(s_t, step["action"])
                v_next = _v_from_m(target, m, s_next)
                delta = step["reward"] + gamma * v_next - q_now
                total += (gamma ** t) * w_steps_all[i][t] * delta
            xs.append(total)
    value, se, ci, _ = _ci_welch(xs, level=level)
    mean_w, max_w, ess, eff = _weights_summary(w_trajs)
    notes = [] if cross_fit else ["cross_fit=False: modelo entrenado con la misma data; sesgo declarado"]
    return OpeResult("DR", value, se, ci, level, len(xs),
                     ess, eff, False, None, mean_w, max_w,
                     episodes[0]["meta"].get("environment", ""), tuple(notes))
