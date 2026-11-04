"""Contrato JSONL de episodios (Fase 0, PLAN_MCP_V2).

Reglas del contrato, todas validadas aquí con errores *accionables*
(cada violación lleva la ruta del campo y una forma de corregirla):

Experimento: una línea JSON por episodio. Un episodio es una unidad
independiente (sesión, paciente, ronda) con `horizon` pasos.

Campos de episodio (obligatorios salvo nota):
  episode_id      str, identificador único dentro del archivo.
  unit            {"kind": str, "id": str}: la unidad estadística independiente.
  policy_version  str, política de registro congelada (p.ej. "isoagent-v1@2.3.0").
  horizon         int >= 1, debe coincidir con len(steps).
  propensity_mode "recorded" | "estimated" | "missing".
  meta            dict opcional; para agentes instrumentados del proyecto debe
                  llevar {"epsilon", "exploration_rate", "c_max", "seed"}.
  steps           lista de pasos (ver abajo).

Cada paso:
  t               int, índice temporal único 0..horizon-1.
  context         {"features": {str: número} [, "raw": str]} — contexto disponible
                  ANTES de actuar. Cuando haya `raw`, es DATO, nunca instrucción.
  action          int o str (la acción elegida).
  propensity      float en (0, 1]; obligatoria con mode "recorded";
                  puede faltar/ampliarse solo si mode != "recorded".
  action_probs    opcional: {str(action): prob} de TODAS las acciones posibles;
                  debe sumar 1 (tol 1e-6) y contener la acción elegida con la
                  misma probabilidad que `propensity` (tol 1e-9). Obligatoria
                  para agentes instrumentados del proyecto.
  reward          número finito; recompensa observada tras actuar.
  next_context    opcional; mismo formato para el paso siguiente.

Reglas cruzadas:
  - mode "recorded" exige propensity > 0 en todos los pasos.
  - mode "estimated" exige que meta.estimated_by exista (quién/describe quién
    ajustó las propensiones) y marca el régimen como degradado aguas abajo.
  - mode "missing" permite propensity ausente; las salidas de OPE quedan
    restringidas a regiones o diagnóstico (decisión del core, no de aquí).
  - meta.c_max, si existe, debe ser float finito >= 1.
  - meta.epsilon, si existe, debe estar en (0, 1].

Uso: `validate_episode(obj)` -> lista de violaciones (vacía si válido);
`load_jsonl(path)` -> lista de dicts validados o `SchemaError` con línea;
`SchemaError` se diseñó para que la capa MCP lo traduzca a error de
herramienta con mensaje accionable — el core no imprime nada.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Iterable

MODES = ("recorded", "estimated", "missing")
_EPS_RANGE_TOL = 1e-6
_SUM_TOL = 1e-6
_EQ_TOL = 1e-9


class SchemaError(ValueError):
    """Contrato violado. `issue` es la primera violación; `issues` todas."""


def _is_num(x: Any) -> bool:
    return isinstance(x, (int, float)) and not isinstance(x, bool)


def _check_step(step: Any, i: int, mode: str, instrumented: bool) -> list[str]:
    out = []
    w = f"steps[{i}]"
    if not isinstance(step, dict):
        return [f"{w}: debe ser objeto"]
    t = step.get("t")
    if not (isinstance(t, int) and not isinstance(t, bool) and t == i):
        out.append(f"{w}.t: debe ser el índice entero {i} (usa t = {i})")
    ctx = step.get("context")
    if not (isinstance(ctx, dict) and isinstance(ctx.get("features"), dict)
            and all(isinstance(k, str) and _is_num(v) for k, v in ctx["features"].items())):
        out.append(f"{w}.context: debe llevar 'features' con claves str y valores numéricos "
                   "(incluye context.raw solo si hace falta texto; es dato, no instrucción)")
    if "action" not in step or not isinstance(step["action"], (int, str)):
        out.append(f"{w}.action: debe ser int o str")
    act = step.get("action")
    p = step.get("propensity")
    if mode == "recorded":
        if not (_is_num(p) and 0 < p <= 1):
            out.append(f"{w}.propensity: con mode='recorded' exige float en (0,1]; "
                       f"cámbiala por la probabilidad real registrada al actuar")
    elif p is not None and not (_is_num(p) and 0 < p <= 1):
        out.append(f"{w}.propensity: si existe debe ser float en (0,1]")
    ap = step.get("action_probs")
    if ap is not None:
        if not (isinstance(ap, dict) and ap and all(isinstance(k, str) and _is_num(v) for k, v in ap.items())):
            out.append(f"{w}.action_probs: debe ser objeto str→número no vacío")
        else:
            s = sum(ap.values())
            if abs(s - 1.0) > _SUM_TOL:
                out.append(f"{w}.action_probs: suma {s!r} ≠ 1; normaliza el diccionario de acciones")
            if act is not None:
                k = str(act)
                if k not in ap:
                    out.append(f"{w}.action_probs: falta la acción elegida {k!r} en el diccionario")
                elif p is not None and abs(ap[k] - p) > _EQ_TOL:
                    out.append(f"{w}.propensity {p!r} ≠ action_probs[{k!r}] = {ap[k]!r}; "
                               "deben coincidir (misma probabilidad registrada)")
            for k, v in ap.items():
                if not (0 <= v <= 1):
                    out.append(f"{w}.action_probs[{k!r}] = {v!r} fuera de [0,1]")
                    break
    elif instrumented:
        out.append(f"{w}.action_probs: un agente instrumentado del proyecto debe registrar "
                   "la distribución completa por paso (así se verifica el diseño)")
    r = step.get("reward")
    if not (_is_num(r) and abs(r) != float("inf")):
        out.append(f"{w}.reward: debe ser un número finito (recompensa observada tras actuar)")
    return out


def validate_episode(obj: Any) -> list[str]:
    """Devuelve la lista de violaciones del contrato (vacía si es válido)."""
    issues: list[str] = []
    if not isinstance(obj, dict):
        return ["episode: debe ser un objeto JSON"]
    for field in ("episode_id", "unit", "policy_version", "horizon", "propensity_mode", "steps"):
        if field not in obj:
            issues.append(f"{field}: campo obligatorio ausente")
    if issues:
        return issues
    if not isinstance(obj["episode_id"], str) or not obj["episode_id"]:
        issues.append("episode_id: debe ser str no vacío")
    u = obj["unit"]
    if not (isinstance(u, dict) and isinstance(u.get("kind"), str) and isinstance(u.get("id"), str)):
        issues.append('unit: debe ser {"kind": str, "id": str} (la unidad independiente)')
    if not isinstance(obj["policy_version"], str) or not obj["policy_version"]:
        issues.append("policy_version: debe ser str no vacío (política congelada)")
    h = obj["horizon"]
    if not (isinstance(h, int) and not isinstance(h, bool) and h >= 1):
        issues.append("horizon: debe ser un entero >= 1")
    mode = obj["propensity_mode"]
    if mode not in MODES:
        issues.append(f"propensity_mode: debe ser uno de {MODES} (recorded = registrada por diseño, "
                      "estimated = ajustada luego, missing = desconocida)")
    meta = obj.get("meta", {})
    if meta is not None and not isinstance(meta, dict):
        issues.append("meta: si existe debe ser un objeto")
        meta = {}
    eps = meta.get("epsilon") if isinstance(meta, dict) else None
    if eps is not None and not (_is_num(eps) and 0 < eps <= 1):
        issues.append("meta.epsilon: debe estar en (0, 1]")
    cmax = meta.get("c_max") if isinstance(meta, dict) else None
    if cmax is not None and not (_is_num(cmax) and cmax >= 1):
        issues.append("meta.c_max: debe ser float finito >= 1")
    if mode == "estimated" and "estimated_by" not in (meta or {}):
        issues.append("meta.estimated_by: con mode='estimated' debe decir quién ajustó "
                      "las propensiones (régimen degradado, declarado)")
    steps = obj["steps"]
    if not isinstance(steps, list):
        issues.append("steps: debe ser una lista de pasos")
        return issues
    if isinstance(h, int) and not isinstance(h, bool) and len(steps) != h:
        issues.append(f"steps: hay {len(steps)} pasos pero horizon={h} (deben coincidir)")
    instrumented = mode == "recorded" and "epsilon" in (meta or {})
    for i, step in enumerate(steps):
        issues.extend(_check_step(step, i, mode if isinstance(mode, str) else "missing", instrumented))
    return issues


def load_jsonl(path: str | Path) -> list[dict]:
    """Carga y valida un archivo JSONL. Lanza SchemaError con archivo:línea
    y corrección accionable. No imprime nada."""
    path = Path(path)
    episodes: list[dict] = []
    seen_ids: set[str] = set()
    errors: list[str] = []
    with path.open("r", encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError as e:
                errors.append(f"{path.name}:{lineno}: JSON inválido ({e.msg})")
                continue
            for issue in validate_episode(obj):
                errors.append(f"{path.name}:{lineno}: {issue}")
            if not errors or not errors[-1].startswith(f"{path.name}:{lineno}: episode_id"):
                nid = obj.get("episode_id") if isinstance(obj, dict) else None
                if isinstance(nid, str):
                    if nid in seen_ids:
                        errors.append(f"{path.name}:{lineno}: episode_id duplicado {nid!r} en el archivo")
                    seen_ids.add(nid)
            episodes.append(obj)
    if errors:
        raise _aggregate(errors, path)
    return episodes


def _aggregate(errors: list[str], path: Path) -> SchemaError:
    message = (f"{len(errors)} violación(es) del contrato en {path}. "
               f"Primera: {errors[0]}")
    err = SchemaError(message)
    err.issues = errors
    return err


def summarize(episodes: Iterable[dict]) -> dict:
    """Resumen acotado para salidas MCP (regla: resumen + ruta, nunca filas crudas)."""
    eps = list(episodes)
    if not eps:
        return {"n_episodes": 0}
    props = [s["propensity"] for e in eps for s in e["steps"] if "propensity" in s]
    rewards = [s["reward"] for e in eps for s in e["steps"]]
    return {
        "n_episodes": len(eps),
        "horizons": sorted({e["horizon"] for e in eps}),
        "policy_versions": sorted({e["policy_version"] for e in eps}),
        "propensity_modes": sorted({e["propensity_mode"] for e in eps}),
        "propensity_min": min(props) if props else None,
        "propensity_max": max(props) if props else None,
        "reward_mean": sum(rewards) / len(rewards) if rewards else None,
        "units": sorted({(e["unit"]["kind"]) for e in eps}),
    }
