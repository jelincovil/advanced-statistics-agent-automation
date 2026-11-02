#!/usr/bin/env python3
"""
TERCERA EVALUACIÓN — 28 datasets + 5 mejoras finales
Ejecuta y exporta resultados a tabla LaTeX.
"""
from __future__ import annotations

import importlib.util
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agente_asintotico import ConfiguracionAgente

# Importar evaluador base
from primera_evaluacion.evaluador_agente import (
    MetricasDataset,
    ResultadoEvaluacion,
    evaluar_dataset,
    generar_dataset_ar1_rho02,
    generar_dataset_ar1_rho05,
    generar_dataset_ar1_rho08,
    generar_dataset_ar1_rho095,
    generar_dataset_arma11,
    generar_dataset_delta_method,
    generar_dataset_iid_asimetrico,
    generar_dataset_iid_bernoulli,
    generar_dataset_iid_exponencial,
    generar_dataset_iid_lognormal,
    generar_dataset_iid_simple,
    generar_dataset_iid_tstudent,
    generar_dataset_iid_uniforme,
    generar_dataset_ma1_theta05,
    generar_dataset_ma2,
    generar_dataset_markov_2estados,
    generar_dataset_markov_4estados,
    generar_dataset_mdp_recompensas_correlacionadas,
    generar_dataset_mixtura_bimodal,
    generar_dataset_muestra_pequena,
    generar_dataset_policy_gradient,
    generar_dataset_random_walk,
)

# Importar datasets heterogéneos
_hetero_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'segunda_evaluacion', 'datasets_heterogeneos.py')
_hetero_spec = importlib.util.spec_from_file_location('dh', _hetero_path)
_hetero = importlib.util.module_from_spec(_hetero_spec)
_hetero_spec.loader.exec_module(_hetero)

generar_dataset_garch = _hetero.generar_dataset_garch
generar_dataset_switching = _hetero.generar_dataset_switching
generar_dataset_arfima = _hetero.generar_dataset_arfima
generar_dataset_estable = _hetero.generar_dataset_estable
generar_dataset_importance_sampling = _hetero.generar_dataset_importance_sampling
generar_dataset_periodico = _hetero.generar_dataset_periodico

NOMBRES = [
    "iid_normal","iid_chisquare","iid_tstudent","iid_uniforme",
    "iid_exponencial","iid_lognormal","iid_bernoulli",
    "ar1_rho02","ar1_rho05","ar1_rho08","ar1_rho095",
    "ma1_theta05","ma2","arma11",
    "markov_2estados","markov_4estados","random_walk",
    "delta_method","mdp_correlacionado","policy_gradient",
    "muestra_pequena","mixtura_bimodal",
    "garch","switching","arfima","estable","importance_sampling","periodico"
]

def main():
    cfg = ConfiguracionAgente(alpha=0.05, B=1000, epsilon_tolerancia=1.0, tipo_ic="percentil", semilla=42)
    datasets = [
        generar_dataset_iid_simple(n=200, semilla=42),
        generar_dataset_iid_asimetrico(n=200, semilla=42),
        generar_dataset_iid_tstudent(n=200, semilla=42),
        generar_dataset_iid_uniforme(n=200, semilla=42),
        generar_dataset_iid_exponencial(n=200, semilla=42),
        generar_dataset_iid_lognormal(n=200, semilla=42),
        generar_dataset_iid_bernoulli(n=500, semilla=42),
        generar_dataset_ar1_rho02(n=1000, semilla=42),
        generar_dataset_ar1_rho05(n=1000, semilla=42),
        generar_dataset_ar1_rho08(n=1000, semilla=42),
        generar_dataset_ar1_rho095(n=2000, semilla=42),
        generar_dataset_ma1_theta05(n=1000, semilla=42),
        generar_dataset_ma2(n=1000, semilla=42),
        generar_dataset_arma11(n=1000, semilla=42),
        generar_dataset_markov_2estados(n=2000, semilla=42),
        generar_dataset_markov_4estados(n=2000, semilla=42),
        generar_dataset_random_walk(n=500, semilla=42),
        generar_dataset_delta_method(n=500, semilla=42),
        generar_dataset_mdp_recompensas_correlacionadas(n=2000, semilla=42),
        generar_dataset_policy_gradient(n=1000, semilla=42),
        generar_dataset_muestra_pequena(n=20, semilla=42),
        generar_dataset_mixtura_bimodal(n=200, semilla=42),
        generar_dataset_garch(n=1000, semilla=42),
        generar_dataset_switching(n=1000, semilla=42),
        generar_dataset_arfima(n=1000, d=0.3, semilla=42),
        generar_dataset_estable(n=1000, alpha=1.5, semilla=42),
        generar_dataset_importance_sampling(n=1000, semilla=42),
        generar_dataset_periodico(n=1000, periodo=24, semilla=42),
    ]

    filas = []
    for ds in datasets:
        m = evaluar_dataset(ds, cfg)
        filas.append(m)
        sym = "✓" if m.cobertura else "✗"
        print(f"  {ds.nombre:22s} V={m.V_estimado:6.2f} IC=[{m.IC_L:7.3f},{m.IC_U:7.3f}] {sym} ancho={m.ancho_ic:.3f}")

    # Tabla LaTeX
    gt = "\\begin{longtable}{@{}lllll@{}}\n\\toprule\nDataset & $V_{\\text{true}}$ & $\\hat{V}$ & IC (95\\%) & ¿Cubre? \\\\\\midrule\n\\endhead\n"
    for i, (ds, m) in enumerate(zip(datasets, filas)):
        sym = "\\ok" if m.cobertura else "\\fail"
        gt += f"{ds.nombre:22s} & {ds.V_true:5.2f} & {m.V_estimado:5.2f} & [{m.IC_L:6.3f}, {m.IC_U:6.3f}] & {sym} \\\\\\\\\n"
    gt += "\\bottomrule\\end{longtable}"

    cov = np.mean([m.cobertura for m in filas])
    print(f"\n  Cobertura: {cov:.2%} ({int(cov*28)}/28)")
    print(f"\n  Tabla LaTeX lista en tabla_resultados.tex")

    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'tabla_resultados.tex'), 'w') as f:
        f.write(gt)

    # Métricas por categoría
    ids = {"A: iid": range(7), "B: AR(1)": range(7,11), "C: MA/ARMA": range(11,14),
           "D: Mixing": range(14,17), "E: RL": range(17,20), "F: Límite": range(20,22),
           "H: Heterog.": range(22,28)}
    print(f"\n  {'Categoría':15s} {'Cobertura':>10s} {'Ancho':>8s}")
    print(f"  {'-'*35}")
    for cat, r in ids.items():
        c = np.mean([filas[i].cobertura for i in r])
        a = np.mean([filas[i].ancho_ic for i in r])
        print(f"  {cat:15s} {c:8.2%} {a:8.3f}")

if __name__ == "__main__":
    main()
