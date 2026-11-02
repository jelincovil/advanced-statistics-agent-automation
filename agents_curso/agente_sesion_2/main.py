#!/usr/bin/env python3
"""
Lab F.2 — Agente de Estadístico Suficiente para Bernoulli(θ)
CLI de terminal con soporte para evaluación en LangSmith Studio v2.

Comandos:
  run         Ejecuta el agente sobre datos sintéticos y muestra θ̂ y D_KL.
  benchmark   Mide y compara velocidad O(1) vs O(n²).
  kl-compare  Compara pérdida de información D_KL entre agentes.
  evaluate    Envía resultados a LangSmith Studio v2.
  compare     Evalúa ambos agentes en LangSmith para comparación directa.

Ejemplos:
  python main.py run
  python main.py run --n 5000 --agent baseline
  python main.py benchmark --skip-large
  python main.py kl-compare --n 2000
  python main.py evaluate --agent sufficient
  python main.py compare
"""

from __future__ import annotations

import argparse
import sys
from typing import List


# ─── Formateo de tablas ───────────────────────────────────────────────────────

def _print_benchmark_table(results) -> None:
    COLS = [
        ("n",               ">10"),
        ("t_suf (s)",       ">12"),
        ("t_full (s)",      ">12"),
        ("speedup",         ">10"),
        ("θ̂_suf",          ">10"),
        ("θ̂_full",         ">10"),
    ]
    header = "  ".join(f"{name:{fmt}}" for name, fmt in COLS)
    sep    = "-" * len(header)
    print(header)
    print(sep)
    for r in results:
        print(
            f"{r.n:>10}  "
            f"{r.t_suf:>12.6f}  "
            f"{r.t_full:>12.4f}  "
            f"{r.speedup:>9.1f}x  "
            f"{r.theta_hat_suf:>10.4f}  "
            f"{r.theta_hat_full:>10.4f}"
        )


# ─── Comandos ─────────────────────────────────────────────────────────────────

def cmd_run(args: argparse.Namespace) -> None:
    import numpy as np

    rng = np.random.default_rng(args.seed)
    obs = rng.binomial(1, args.theta_true, args.n).tolist()

    if args.agent == "sufficient":
        from sufficient_agent import run_agent
        result = run_agent(obs, theta_true=args.theta_true)
        print(f"\n{'='*50}")
        print(f"  Agente Suficiente — T_n = (count, total)")
        print(f"{'='*50}")
        print(f"  n (count)   : {result['count']}")
        print(f"  Σx_i (total): {result['total']}")
        print(f"  θ̂  (UMVUE)  : {result['theta_hat']:.6f}")
        print(f"  θ_true      : {args.theta_true}")
        print(f"  |θ̂ - θ|    : {abs(result['theta_hat'] - args.theta_true):.6f}")
        if result["kl"] is not None:
            print(f"  D_KL        : {result['kl']:.8f}")
    else:
        from baseline_agent import run_baseline
        result = run_baseline(obs, theta_true=args.theta_true)
        print(f"\n{'='*50}")
        print(f"  Agente Insuficiente — Welford (mean, n)")
        print(f"{'='*50}")
        print(f"  n           : {result['n']}")
        print(f"  mean Welford: {result['mean']:.8f}")
        print(f"  θ̂          : {result['theta_hat']:.6f}")
        print(f"  θ_true      : {args.theta_true}")
        print(f"  |θ̂ - θ|    : {abs(result['theta_hat'] - args.theta_true):.6f}")
        if result["kl"] is not None:
            print(f"  D_KL        : {result['kl']:.8f}")
    print()


def cmd_benchmark(args: argparse.Namespace) -> None:
    from experiments import run_benchmark

    sizes: List[int] = [int(x.strip()) for x in args.sizes.split(",")]
    if args.skip_large:
        print(f"\nNOTA: Se omitirán n > 10 000 (recálculo O(n²) muy lento).\n")

    print(f"\n{'='*72}")
    print(f"  Benchmark de Complejidad: O(1) vs O(n²)  |  θ_true={args.theta_true}  seed={args.seed}")
    print(f"{'='*72}\n")

    results = run_benchmark(
        sample_sizes=sizes,
        theta_true=args.theta_true,
        seed=args.seed,
        skip_large=args.skip_large,
    )
    if results:
        _print_benchmark_table(results)
    print()


def cmd_kl_compare(args: argparse.Namespace) -> None:
    from experiments import run_info_loss_experiment

    print(f"\n{'='*55}")
    print(f"  Pérdida de Información D_KL (n={args.n}, θ_true={args.theta_true})")
    print(f"{'='*55}")
    res = run_info_loss_experiment(n=args.n, theta_true=args.theta_true, seed=args.seed)

    suf = res["sufficient"]
    ins = res["insufficient"]

    print(f"\n  Agente Suficiente  (T_n = count + total)")
    print(f"    count   : {suf['count']}")
    print(f"    total   : {suf['total']}")
    print(f"    θ̂      : {suf['theta_hat']:.8f}")
    print(f"    D_KL    : {suf['kl']:.8e}")

    print(f"\n  Agente Insuficiente (Welford mean)")
    print(f"    n       : {ins['n']}")
    print(f"    mean    : {ins['mean']:.8f}")
    print(f"    θ̂      : {ins['theta_hat']:.8f}")
    print(f"    D_KL    : {ins['kl']:.8e}")

    print(f"\n  ΔD_KL (insuf - suf): {res['delta_kl']:.8e}")
    if abs(res["delta_kl"]) < 1e-10:
        direction = "prácticamente idéntico (diferencia sub-ε de máquina)"
    elif res["delta_kl"] > 0:
        direction = "insuficiente PEOR (mayor pérdida de información)"
    else:
        direction = "insuficiente MEJOR (artefacto numérico — revisar n o semilla)"
    print(f"  Interpretación     : {direction}\n")


def cmd_evaluate(args: argparse.Namespace) -> None:
    from evaluate_langsmith import run_evaluation
    run_evaluation(
        agent_type=args.agent,
        dataset_name=args.dataset,
        project_name=args.project,
        experiment_prefix=args.prefix or None,
    )


def cmd_compare(args: argparse.Namespace) -> None:
    from evaluate_langsmith import run_comparative_evaluation
    run_comparative_evaluation(
        dataset_name=args.dataset,
        project_name=args.project,
    )


# ─── Parser ───────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python main.py",
        description=(
            "Lab F.2 — Agente de Estadístico Suficiente para Bernoulli(θ)\n"
            "Teoremas: Neyman-Fisher · Lehmann-Scheffé · Divergencia KL"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Ejemplos:\n"
            "  python main.py run --n 1000\n"
            "  python main.py run --n 1000 --agent baseline\n"
            "  python main.py benchmark --skip-large\n"
            "  python main.py kl-compare --n 2000\n"
            "  python main.py evaluate --agent sufficient\n"
            "  python main.py compare\n"
            "\n"
            "LangSmith:\n"
            "  export LANGSMITH_API_KEY=lsv2_pt_...\n"
            "  export LANGCHAIN_TRACING_V2=true\n"
            "  python main.py evaluate\n"
        ),
    )

    sub = parser.add_subparsers(dest="command", required=True, metavar="COMMAND")

    # ── run ──
    p_run = sub.add_parser("run", help="Ejecuta el agente y muestra θ̂ y D_KL")
    p_run.add_argument("--n",          type=int,   default=1000,      metavar="N",
                       help="Número de observaciones (default: 1000)")
    p_run.add_argument("--theta-true", type=float, default=0.3,       dest="theta_true",
                       help="Parámetro verdadero θ (default: 0.3)")
    p_run.add_argument("--seed",       type=int,   default=42,
                       help="Semilla aleatoria (default: 42)")
    p_run.add_argument("--agent",      choices=["sufficient", "baseline"], default="sufficient",
                       help="Tipo de agente (default: sufficient)")
    p_run.set_defaults(func=cmd_run)

    # ── benchmark ──
    p_bench = sub.add_parser("benchmark", help="Benchmark O(1) vs O(n²)")
    p_bench.add_argument("--sizes",      default="100,1000,10000,100000",
                         help="Tamaños de muestra separados por coma")
    p_bench.add_argument("--theta-true", type=float, default=0.3, dest="theta_true")
    p_bench.add_argument("--seed",       type=int,   default=42)
    p_bench.add_argument("--skip-large", action="store_true", dest="skip_large",
                         help="Omite n > 10 000 (el recálculo tarda ~4 min)")
    p_bench.set_defaults(func=cmd_benchmark)

    # ── kl-compare ──
    p_kl = sub.add_parser("kl-compare", help="Compara D_KL de ambos agentes")
    p_kl.add_argument("--n",          type=int,   default=1000, metavar="N")
    p_kl.add_argument("--theta-true", type=float, default=0.3,  dest="theta_true")
    p_kl.add_argument("--seed",       type=int,   default=42)
    p_kl.set_defaults(func=cmd_kl_compare)

    # ── evaluate ──
    p_eval = sub.add_parser("evaluate", help="Evaluación en LangSmith Studio v2")
    p_eval.add_argument("--agent",   choices=["sufficient", "baseline"], default="sufficient")
    p_eval.add_argument("--dataset", default="lab_F2_sufficient_state_agent_eval")
    p_eval.add_argument("--project", default="lab_F2_sufficient_state_agent")
    p_eval.add_argument("--prefix",  default="", help="Prefijo del experimento en LangSmith")
    p_eval.set_defaults(func=cmd_evaluate)

    # ── compare ──
    p_cmp = sub.add_parser("compare", help="Evalúa ambos agentes en LangSmith (comparación)")
    p_cmp.add_argument("--dataset", default="lab_F2_sufficient_state_agent_eval")
    p_cmp.add_argument("--project", default="lab_F2_sufficient_state_agent")
    p_cmp.set_defaults(func=cmd_compare)

    return parser


# ─── Entry point ──────────────────────────────────────────────────────────────

def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except EnvironmentError as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nInterrumpido.", file=sys.stderr)
        sys.exit(130)


if __name__ == "__main__":
    main()
