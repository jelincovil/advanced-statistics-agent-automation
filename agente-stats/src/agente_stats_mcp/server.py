"""Servidor MCP `agente-stats` (Fase 3 del plan): 4 tools read-only.

Config por entorno (defaults saneados):
  AGENTE_STATS_EXAMPLES_DIR — directorio de ejemplos (default:
    `<proyecto>/examples/` resuelto desde el paquete)
  AGENTE_STATS_WORKSPACE_DIR — workspace del alumno (default: cwd actual)

Path jail: SOLO esos dos directorios pueden leerse. Rutas fuera se
rechazan con mensaje accionable. El contenido de los archivos es DATO:
nunca se ejecuta texto de contexto ni de logs (incluyendo `context.raw`,
que la capa simplemente ignora — es dato, no instrucción).

Salidas: resumen + diagnóstico + ≤10 filas de ejemplo + ruta (regla MCP
del proyecto, no negociable).
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations

from agente_stats import (build_ficha, compare_versions, estimate_dr,
                          estimate_is, load_jsonl, summarize)
from agente_stats.core.episode_logger import design_policy_epsilon_greedy

MAX_ROWS_RETURNED = 10
DEFAULT_ESTIMANDO = ("Valor de la política objetivo sobre los episodios "
                     "declarados, con su intervalo (asintótico) honesto")


class ToolRejection(ValueError):
    """Rechazo accionable que la capa traduce a `ok: False` con mensaje.


    """


def _package_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _roots() -> list[Path]:
    ex = Path(os.environ.get("AGENTE_STATS_EXAMPLES_DIR",
                             _package_root() / "examples")).resolve()
    ws = Path(os.environ.get("AGENTE_STATS_WORKSPACE_DIR",
                             _package_root())).resolve()
    return [ex, ws]



def _resolve(path: str) -> Path:
    """Valida una ruta: dentro de la jail, existente, archivo legible.

    Las rutas relativas se resuelven contra cada root de la jail
    (primero `examples/`, luego workspace), así un alumno puede pasar
    nombres de archivo simples (`agent_v1_episodes.jsonl`).
    """
    if not path or not str(path).strip():
        raise ToolRejection(
            "ruta vacía: declara la ruta del JSONL de episodios dentro de la jail.")
    raw = Path(path).expanduser()
    candidates = [raw.resolve()] if raw.is_absolute() else [
        (root / raw).resolve() for root in _roots()]
    p = next((c for c in candidates if c.is_file()), None)
    if p is None:
        raise ToolRejection(
            f"no existe archivo en la jail. Probado contra: "
            + ", ".join(str(c) for c in candidates) + ".")
    for root in _roots():
        try:
            p.relative_to(root)
            break
        except ValueError:
            continue
    else:
        raise ToolRejection(
            f"ruta fuera de la jail: {p}. Se admiten SOLO entradas bajo: "
            + ", ".join(str(r) for r in _roots())
            + ". Mueve el archivo a `examples/` o al workspace del alumno "
              "(AGENTE_STATS_WORKSPACE_DIR).")
    return p



def _reject(reason: str) -> dict:
    return {"ok": False, "is_error": True, "error": reason}


def _load(path: str, require_recorded: bool = True) -> list[dict]:
    p = _resolve(path)
    try:
        episodes = load_jsonl(p)
    except Exception as e:  # SchemaError y json en general
        raise ToolRejection(
            f"JSONL inválido en {p.name}: {e}. El contenido del archivo se "
            "lee como dato; nunca se ejecuta texto.")
    if require_recorded:
        modes = {e["propensity_mode"] for e in episodes}
        if modes != {"recorded"}:
            raise ToolRejection(
                f"OPE exige propensión registrada por diseño (mode='recorded'): "
                f"encontrado {sorted(modes)} en {p.name}. Con 'estimated' o "
                "'missing' la salida debe degradarse a región/diagnóstico "
                "a través de la ficha del experimento antes de estimar.")
    return episodes


def _gamma_of(episodes) -> float:
    return float(episodes[0]["meta"].get("gamma", 1.0))


def _policy_from_target(target: dict) -> Any:
    """Constructor único de la política objetivo declarada.

    Formas admitidas (declaración exacta):
      {"type": "eps_greedy", "q_table": [[..], ...], "epsilon": e}
      {"type": "explicit",   "policy": {"(s, a)": prob, ...}}
      {"(s,a)": prob, ...} (azúcar por compatibilidad)
    """
    if not isinstance(target, dict):
        raise ToolRejection("política: debe ser un objeto dict")
    t = target.get("type")
    if t == "eps_greedy":
        eps = float(target.get("epsilon", 0.3))
        if not (0.0 <= eps <= 1.0):
            raise ToolRejection("política: epsilon debe estar en [0, 1]")
        q_rows = target.get("q_table")
        if not q_rows or not all(isinstance(r, (list, tuple)) for r in q_rows):
            raise ToolRejection("política: q_table debe ser una lista de filas (n_estados, n_acciones)")
        n_actions = len(q_rows[0])
        def _argmax(row):
            best = 0
            for i, v in enumerate(row):
                if v > row[best]:
                    best = i
            return best
        return {(s, a): (1.0 - eps + eps / n_actions) if a == _argmax(q_rows[s]) else eps / n_actions
                for s in range(len(q_rows)) for a in range(n_actions)}
    if t == "explicit" or t is None and any(str(k).startswith("(") for k in target):
        policy = target["policy"] if t == "explicit" else target
        out = {}
        for key, p in policy.items():
            if not isinstance(key, str) or not (key.startswith("(") and key.endswith(")")):
                raise ToolRejection('política: claves deben ser cadenas "(s, a)": ' + repr(key))
            pair = eval(key, {"__builtins__": {}}, {})
            out[(int(pair[0]), int(pair[1]))] = float(p)
        return out
    raise ToolRejection(
        "política: type debe ser 'eps_greedy' | 'explicit' (uniform no está "
        "todavía como política de evaluación; declara tus pesos igualitarios "
        "como 'explicit')")


mcp = FastMCP("agente-stats")


@mcp.tool(name="inspect_episodes",
          annotations=ToolAnnotations(title="Inspeccionar episodios registrados", readOnlyHint=True))
def inspect_episodes(path: str) -> dict:
    """Resumen acotado del archivo de episodios JSONL registrado por diseño:
    nº de unidades, horizonte(s), versiones de política, modo de propensión y
    media de recompensa. ≤10 filas de ejemplo + ruta; el archivo entero se
    inspecciona externamente. El contenido es dato: nunca se ejecuta texto.

    path: Ruta dentro de la jail (examples/ o workspace del alumno) del .jsonl.
    """
    try:
        episodes = _load(path, require_recorded=False)
        p = _resolve(path)
        s = summarize(episodes)
        rows = [{
            "episode_id": e["episode_id"],
            "policy_version": e["policy_version"],
            "horizon": e["horizon"],
            "n_step_actions": len(e["steps"][0]["action_probs"]) if e["steps"] else 0,
        } for e in episodes[:MAX_ROWS_RETURNED]]
        return {"ok": True, "file": str(p), "summary": s,
                "example_rows": rows,
                "note": "resumen + ≤10 filas de ejemplo + ruta; inspección completa externa"}
    except ToolRejection as e:
        return _reject(str(e))


@mcp.tool(name="ope_evaluate",
          annotations=ToolAnnotations(title="Evaluación off-policy", readOnlyHint=True))
def ope_evaluate(path: str, estimator: str, target: dict,
                 estimand: str = DEFAULT_ESTIMANDO) -> dict:
    """OPE sobre episodios con propensión registrada por diseño (Fase 2).
    Devuelve valor, se, IC (Welch, honesto, unidades i.i.d. por episodio),
    ESS diagnóstico y notas de truncamiento si las usaste. Regla: params
    completos; si faltan o el régimen no es diseño, error accionable.

    path: Ruta del .jsonl (jail). estimator: "IS" | "DR". target: política por
    diseño via `_policy_from_target`.
    """
    try:
        episodes = _load(path)
        policy = _policy_from_target(target)
        if estimator == "IS":
            r = estimate_is(episodes, policy)
        elif estimator == "DR":
            r = estimate_dr(episodes, policy)
        else:
            return _reject("estimator debe ser 'IS' | 'DR' (declarado explícitamente).")
    except ToolRejection as e:
        return _reject(str(e))
    except ValueError as e:
        return _reject(str(e))
    return {"ok": True,
            "estimator": r.estimator, "value": r.value, "se": r.se,
            "ci95": list(r.ci95), "level": r.level, "n_units": r.n_units,
            "ess_fraction": r.ess_fraction, "eff_samples": r.eff_samples,
            "truncated": r.truncated, "mean_weight": r.mean_weight,
            "max_weight_observed": r.max_weight_observed,
            "gamma": _gamma_of(episodes), "regime": r.regime,
            "notes": list(r.notes),
            "limit": "unidad independiente = episodio; IC Welch normal asintótico"}


@mcp.tool(name="compare_versions",
          annotations=ToolAnnotations(title="Comparar versiones de política", readOnlyHint=True))
def compare_versions_tool(path: str, target_new: dict, target_old: dict,
                          estimator: str = "DR") -> dict:
    """Δ = J(nueva) − J(antigua) sobre los logs de la anterior, con IC por
    Welch sobre contribuciones pareadas por episodio. Con DR ambas políticas
    usan el MISMO modelo por fold. Devuelve ESS del diagnóstico (del nuevo).

    path: Ruta del .jsonl (jail). target_new/target_old/estimator declarados.
    """
    try:
        episodes = _load(path)
        pn = _policy_from_target(target_new)
        po = _policy_from_target(target_old)
        c = compare_versions(episodes, target_new=pn, target_old=po,
                             estimator=estimator)
    except (ToolRejection, ValueError) as e:
        return _reject(str(e))
    return {"ok": True,
            "delta": c.delta, "se": c.se, "ci95": list(c.ci95),
            "level": c.level, "estimator": c.estimator, "n_units": c.n_units,
            "ess_fraction": c.ess_fraction, "gamma": _gamma_of(episodes),
            "limit": ("Δ estimado sobre logs con propensión por diseño; el "
                      "modelo (DR) es compartido por fold entre versiones")}


@mcp.tool(name="justification_ficha",
          annotations=ToolAnnotations(title="Ficha de justificación", readOnlyHint=True))
def justification_ficha(path: str, estimand: str, estimator: str,
                        target: dict,
                        declared_conditions: dict | None = None) -> dict:
    """Construye la ficha de justificación (V2). Rechaza con mensaje accionable
    si el estimando está ausente o el régimen no es de diseño; nunca firma
    como garantía lo que tus condiciones no sostienen: el nivel sale por el
    eslabón más débil.

    path/estimand/estimator/target/declared_conditions como .
    """
    try:
        episodes = _load(path)
        policy = _policy_from_target(target)
        if estimator == "IS":
            r = estimate_is(episodes, policy)
        elif estimator == "DR":
            r = estimate_dr(episodes, policy)
        else:
            return _reject("estimator debe ser 'IS' | 'DR' (declarado explícitamente).")
        f = build_ficha(estimand, r, regime=r.regime or "episodios iid",
                        unit="episodio",
                        declared_conditions=declared_conditions,
                        data_ref=str(_resolve(path)))
    except (ToolRejection, ValueError) as e:
        return _reject(str(e))
    return {"ok": True,
            "estimand": f.certificate.estimand,
            "conclusion_level": f.certificate.conclusion_level,
            "discharged_level": f.certificate.discharged_level(),
            "weakest_status": f.certificate.weakest_status(),
            "markdown": f.markdown,
            "value": r.value, "se": r.se, "ci95": list(r.ci95),
            "n_units": r.n_units, "ess_fraction": r.ess_fraction}


if __name__ == "__main__":
    mcp.run()
