"""
Evaluación en LangSmith Studio v2 — Lab F.2

Requiere:
  export LANGSMITH_API_KEY=lsv2_pt_...
  export LANGCHAIN_TRACING_V2=true       # activa tracing automático de LangGraph
  export LANGCHAIN_PROJECT=lab_F2_sufficient_state_agent

Flujo:
  1. Crea (o recupera) un dataset con ejemplos de evaluación.
  2. Define evaluadores: KL por debajo del umbral, convergencia de θ̂.
  3. Ejecuta `langsmith.evaluate()` sobre el agente target.
  4. Los resultados quedan disponibles en https://smith.langchain.com
"""

from __future__ import annotations

import os
from typing import Optional

import numpy as np


# ─── Configuración ────────────────────────────────────────────────────────────

DATASET_NAME = "lab_F2_sufficient_state_agent_eval"
DEFAULT_PROJECT = "lab_F2_sufficient_state_agent"


def _require_api_key() -> None:
    if not os.environ.get("LANGSMITH_API_KEY"):
        raise EnvironmentError(
            "\nFalta LANGSMITH_API_KEY.\n"
            "Defínala antes de ejecutar la evaluación:\n"
            "  export LANGSMITH_API_KEY=lsv2_pt_<tu_clave>\n"
            "  export LANGCHAIN_TRACING_V2=true\n"
            "  export LANGCHAIN_PROJECT=lab_F2_sufficient_state_agent\n"
        )


def _setup_env(project_name: str) -> None:
    _require_api_key()
    os.environ.setdefault("LANGCHAIN_TRACING_V2", "true")
    os.environ.setdefault("LANGCHAIN_PROJECT", project_name)


# ─── Dataset ──────────────────────────────────────────────────────────────────

_EXAMPLES = [
    # (inputs, expected_outputs)
    ({"n": 100,   "theta_true": 0.3, "seed": 42}, {"kl_max": 0.05,  "theta_ref": 0.3}),
    ({"n": 1000,  "theta_true": 0.3, "seed": 42}, {"kl_max": 0.005, "theta_ref": 0.3}),
    ({"n": 1000,  "theta_true": 0.7, "seed": 42}, {"kl_max": 0.005, "theta_ref": 0.7}),
    ({"n": 1000,  "theta_true": 0.5, "seed": 42}, {"kl_max": 0.005, "theta_ref": 0.5}),
    ({"n": 1000,  "theta_true": 0.1, "seed": 42}, {"kl_max": 0.005, "theta_ref": 0.1}),
    ({"n": 10000, "theta_true": 0.3, "seed": 42}, {"kl_max": 0.001, "theta_ref": 0.3}),
]


def _get_or_create_dataset(client, dataset_name: str):
    try:
        dataset = client.read_dataset(dataset_name=dataset_name)
        print(f"  Dataset existente: '{dataset_name}' (id={dataset.id})")
        return dataset
    except Exception:
        pass

    dataset = client.create_dataset(
        dataset_name=dataset_name,
        description=(
            "Lab F.2 — Estadístico Suficiente para Bernoulli(θ). "
            "Evalúa convergencia de θ̂ y divergencia KL."
        ),
    )
    inputs_list  = [ex[0] for ex in _EXAMPLES]
    outputs_list = [ex[1] for ex in _EXAMPLES]
    client.create_examples(
        inputs=inputs_list,
        outputs=outputs_list,
        dataset_id=dataset.id,
    )
    print(f"  Dataset creado: '{dataset_name}' ({len(_EXAMPLES)} ejemplos)")
    return dataset


# ─── Target functions ─────────────────────────────────────────────────────────

def _make_target(agent_type: str):
    """Devuelve la función que LangSmith llama por cada ejemplo del dataset."""
    if agent_type == "sufficient":
        from sufficient_agent import run_agent
        def target(inputs: dict) -> dict:
            rng = np.random.default_rng(inputs.get("seed", 42))
            obs = rng.binomial(1, inputs["theta_true"], inputs["n"]).tolist()
            result = run_agent(obs, theta_true=inputs["theta_true"])
            return {"theta_hat": result["theta_hat"], "kl": result["kl"]}
    else:
        from baseline_agent import run_baseline
        def target(inputs: dict) -> dict:
            rng = np.random.default_rng(inputs.get("seed", 42))
            obs = rng.binomial(1, inputs["theta_true"], inputs["n"]).tolist()
            result = run_baseline(obs, theta_true=inputs["theta_true"])
            return {"theta_hat": result["theta_hat"], "kl": result["kl"]}

    target.__name__ = f"{agent_type}_agent"
    return target


# ─── Evaluadores ─────────────────────────────────────────────────────────────

def evaluator_kl_threshold(run, example) -> dict:
    """Score=1 si D_KL ≤ umbral definido en el ejemplo; Score=0 si lo supera."""
    kl = (run.outputs or {}).get("kl") or 0.0
    kl_max = (example.outputs or {}).get("kl_max", 0.05)
    passed = float(kl <= kl_max)
    return {
        "key": "kl_below_threshold",
        "score": passed,
        "comment": f"KL={kl:.8f}  umbral={kl_max}  {'OK' if passed else 'FAIL'}",
    }


def evaluator_theta_convergence(run, example) -> dict:
    """
    Score=1 si |θ̂ - θ_true| ≤ 3/√n (dentro de 3 errores estándar de Bernoulli).
    Verifica convergencia estadística de la estimación.
    """
    theta_hat  = (run.outputs or {}).get("theta_hat", 0.5)
    theta_true = (example.inputs or {}).get("theta_true", 0.3)
    n          = (example.inputs or {}).get("n", 100)
    tol  = 3.0 / np.sqrt(n)
    err  = abs(theta_hat - theta_true)
    passed = float(err <= tol)
    return {
        "key": "theta_convergence",
        "score": passed,
        "comment": f"|θ̂-θ|={err:.5f}  tol={tol:.5f}  n={n}  {'OK' if passed else 'FAIL'}",
    }


def evaluator_kl_ratio(run, example) -> dict:
    """
    Requiere ejecuciones guardadas de ambos agentes para comparar KL.
    Score continuo: 1/(1 + KL) — mayor score = mejor estimación.
    """
    kl = (run.outputs or {}).get("kl") or 0.0
    return {
        "key": "kl_score",
        "score": 1.0 / (1.0 + kl),
        "comment": f"KL={kl:.8f}",
    }


# ─── Punto de entrada de evaluación ──────────────────────────────────────────

def run_evaluation(
    agent_type: str = "sufficient",
    dataset_name: str = DATASET_NAME,
    project_name: str = DEFAULT_PROJECT,
    experiment_prefix: Optional[str] = None,
) -> object:
    """
    Ejecuta la evaluación completa en LangSmith Studio v2.

    Args:
        agent_type:          "sufficient" | "baseline"
        dataset_name:        Nombre del dataset en LangSmith.
        project_name:        Nombre del proyecto en LangSmith.
        experiment_prefix:   Prefijo del experimento (se añade timestamp automático).

    Returns:
        Resultados de langsmith.evaluate() (ExperimentResults).
    """
    from langsmith import Client
    from langsmith import evaluate as ls_evaluate

    _setup_env(project_name)
    client = Client()

    print(f"\n{'='*60}")
    print(f"  LangSmith Studio v2 — Lab F.2  ({agent_type} agent)")
    print(f"{'='*60}")
    print(f"  Proyecto : {project_name}")
    print(f"  Dataset  : {dataset_name}")

    dataset = _get_or_create_dataset(client, dataset_name)
    target  = _make_target(agent_type)
    prefix  = experiment_prefix or f"lab_F2_{agent_type}"

    print(f"\n  Iniciando evaluación (experimento: {prefix})...\n")

    results = ls_evaluate(
        target,
        data=dataset_name,
        evaluators=[
            evaluator_kl_threshold,
            evaluator_theta_convergence,
            evaluator_kl_ratio,
        ],
        experiment_prefix=prefix,
        metadata={
            "agent_type": agent_type,
            "lab": "F.2",
            "chapter": 2,
            "theorems": ["Neyman-Fisher", "Lehmann-Scheffé"],
            "version": "1.0.0",
        },
        num_repetitions=1,
    )

    print(f"\n  Evaluación completada.")
    print(f"  Ver resultados en: https://smith.langchain.com")
    print(f"  Proyecto: {project_name} / Experimento: {prefix}_*\n")
    return results


# ─── Comparación suficiente vs insuficiente ───────────────────────────────────

def run_comparative_evaluation(
    dataset_name: str = DATASET_NAME,
    project_name: str = DEFAULT_PROJECT,
) -> None:
    """Evalúa ambos agentes en el mismo dataset para comparar sus métricas en Studio."""
    for agent_type in ("sufficient", "baseline"):
        run_evaluation(
            agent_type=agent_type,
            dataset_name=dataset_name,
            project_name=project_name,
        )
