#!/usr/bin/env python3
"""
================================================================================
SEGUNDA EVALUACIÓN — 28 DATASETS (22 originales + 6 heterogéneos)
Capítulo 5: Teoría Asintótica y Métodos de Remuestreo
================================================================================

Evalúa el agente con las 5 mejoras aplicadas contra 28 datasets.

Uso:
    python segunda_evaluacion.py
================================================================================
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Importar los 6 generadores heterogéneos
# (import directo porque segunda_evaluacion no es un paquete)
import importlib.util
import time
from dataclasses import dataclass, field
from typing import Callable, List, Tuple

import numpy as np
from scipy import stats

from agente_asintotico import (
    AgenteEstadisticoAsintotico,
    ConfiguracionAgente,
    bootstrap_ci,
    diagnosticar_estacionariedad,
    diagnosticar_mixing,
)

# Importar los 22 generadores originales
from primera_evaluacion.evaluador_agente import (
    Dataset,
    MetricasDataset,
    ResultadoEvaluacion,
    evaluar_cobertura_montecarlo,
    evaluar_dataset,
    evaluar_mixing_montecarlo,
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
    imprimir_evaluacion_completa,
    imprimir_resultado_montecarlo,
)

_hetero_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'datasets_heterogeneos.py')
_spec = importlib.util.spec_from_file_location('datasets_heterogeneos', _hetero_path)
_hetero = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_hetero)

generar_dataset_garch = _hetero.generar_dataset_garch
generar_dataset_switching = _hetero.generar_dataset_switching
generar_dataset_arfima = _hetero.generar_dataset_arfima
generar_dataset_estable = _hetero.generar_dataset_estable
generar_dataset_importance_sampling = _hetero.generar_dataset_importance_sampling
generar_dataset_periodico = _hetero.generar_dataset_periodico


def main():
    print("=" * 75)
    print("  SEGUNDA EVALUACIÓN — 28 DATASETS (Con mejoras del agente)")
    print("  ============================================================")
    print("  22 datasets originales + 6 heterogéneos")
    print("  5 mejoras activas: ADF, σ²_LR, bloques automáticos, fracción [0,1], t analítico")
    print("=" * 75)

    config = ConfiguracionAgente(
        alpha=0.05, B=1000, epsilon_tolerancia=1.0,
        tipo_ic="percentil", semilla=42,
    )

    # ------------------------------------------------------------------
    # FASE 1: Cobertura Monte Carlo (solo en iid normal para referencia)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 1] COBERTURA MONTE CARLO (200 réplicas)")
    res_mc = evaluar_cobertura_montecarlo(
        lambda n, semilla: generar_dataset_iid_simple(n=n, semilla=semilla),
        n_rep=200, n_muestra=100, alpha=0.05, B=1000, semilla_base=100,
    )
    imprimir_resultado_montecarlo(res_mc, "IC percentil — iid Normal(5,4)")

    # ------------------------------------------------------------------
    # FASE 2: Mixing (tasa de falsa alarma en iid)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 2] DIAGNÓSTICO DE MIXING")
    res_mix = evaluar_mixing_montecarlo(n_rep=200, n_muestra=500, semilla_base=300)
    print(f"  Falsas alarmas en iid: {res_mix['falsas_alarmas']}/{res_mix['n_rep']} "
          f"({res_mix['tasa_falsa_alarma_iid']:.2%})")
    print(f"  {'✓' if res_mix['tasa_falsa_alarma_iid'] < 0.05 else '✗'} "
          f"Aceptable (< 5%)")

    # ------------------------------------------------------------------
    # FASE 3: Evaluación individual de cada dataset
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 3] EVALUACIÓN INDIVIDUAL — 28 DATASETS")
    print("  ───────────────────────────────────────────────────────\n")

    datasets = [
        # A: iid (7)
        generar_dataset_iid_simple(n=200, semilla=42),
        generar_dataset_iid_asimetrico(n=200, semilla=42),
        generar_dataset_iid_tstudent(n=200, semilla=42),
        generar_dataset_iid_uniforme(n=200, semilla=42),
        generar_dataset_iid_exponencial(n=200, semilla=42),
        generar_dataset_iid_lognormal(n=200, semilla=42),
        generar_dataset_iid_bernoulli(n=500, semilla=42),
        # B: AR(1) (4)
        generar_dataset_ar1_rho02(n=1000, semilla=42),
        generar_dataset_ar1_rho05(n=1000, semilla=42),
        generar_dataset_ar1_rho08(n=1000, semilla=42),
        generar_dataset_ar1_rho095(n=2000, semilla=42),
        # C: MA/ARMA (3)
        generar_dataset_ma1_theta05(n=1000, semilla=42),
        generar_dataset_ma2(n=1000, semilla=42),
        generar_dataset_arma11(n=1000, semilla=42),
        # D: Mixing extremo (3)
        generar_dataset_markov_2estados(n=2000, semilla=42),
        generar_dataset_markov_4estados(n=2000, semilla=42),
        generar_dataset_random_walk(n=500, semilla=42),
        # E: RL (3)
        generar_dataset_delta_method(n=500, semilla=42),
        generar_dataset_mdp_recompensas_correlacionadas(n=2000, semilla=42),
        generar_dataset_policy_gradient(n=1000, semilla=42),
        # F: Límite (2)
        generar_dataset_muestra_pequena(n=20, semilla=42),
        generar_dataset_mixtura_bimodal(n=200, semilla=42),
        # ===== NUEVOS: Heterogeneidad (6) =====
        generar_dataset_garch(n=1000, semilla=42),
        generar_dataset_switching(n=1000, semilla=42),
        generar_dataset_arfima(n=1000, d=0.3, semilla=42),
        generar_dataset_estable(n=1000, alpha=1.5, semilla=42),
        generar_dataset_importance_sampling(n=1000, semilla=42),
        generar_dataset_periodico(n=1000, periodo=24, semilla=42),
    ]

    metricas = []
    for ds in datasets:
        print(f"  {ds.nombre:22s}... ", end="", flush=True)
        t0 = time.time()
        m = evaluar_dataset(ds, config)
        dt = time.time() - t0
        metricas.append(m)
        cov = "✓" if m.cobertura else "✗"
        mix = "✓" if m.mixing_ok else "✗"
        print(f"V={m.V_estimado:6.2f}  IC=[{m.IC_L:6.2f},{m.IC_U:6.2f}]  "
              f"W={m.ancho_ic:5.2f}  {cov}cubre  {mix}mix  {dt:.1f}s")

    # Métricas globales
    cobertura_global = np.mean([m.cobertura for m in metricas])
    ancho_prom = np.mean([m.ancho_ic for m in metricas])

    # Separar métricas por grupo
    ids_originales = list(range(22))
    ids_nuevos = list(range(22, 28))

    cov_original = np.mean([metricas[i].cobertura for i in ids_originales])
    cov_nuevos = np.mean([metricas[i].cobertura for i in ids_nuevos])
    ancho_original = np.mean([metricas[i].ancho_ic for i in ids_originales])
    ancho_nuevos = np.mean([metricas[i].ancho_ic for i in ids_nuevos])

    print(f"\n  {'=' * 70}")
    print(f"  MÉTRICAS GLOBALES — 28 DATASETS")
    print(f"  {'=' * 70}")
    print(f"  Cobertura global:           {cobertura_global:.2%} ({int(cobertura_global*28)}/28)")
    print(f"  Cobertura originales (22):  {cov_original:.2%}")
    print(f"  Cobertura nuevos (6):       {cov_nuevos:.2%}")
    print(f"  Ancho IC promedio:          {ancho_prom:.4f}")
    print(f"  Ancho originales:           {ancho_original:.4f}")
    print(f"  Ancho nuevos:               {ancho_nuevos:.4f}")
    print(f"  Tiempo total:               {sum(m.tiempo_ejecucion for m in metricas):.2f}s")

    # Tabla de resultados nueva
    print(f"\n")
    print(f"  {'=' * 70}")
    print(f"  RESULTADOS — 6 NUEVOS DATASETS HETEROGÉNEOS")
    print(f"  {'=' * 70}")
    headers = ["Dataset", "V_true", "V_est", "IC inf", "IC sup", "Ancho", "Cubre", "Mixing", "ADF"]
    print(f"  {headers[0]:22s} {headers[1]:>6s} {headers[2]:>6s} {headers[3]:>7s} {headers[4]:>7s} {headers[5]:>6s} {headers[6]:>5s} {headers[7]:>5s} {headers[8]:>5s}")
    print(f"  {'-' * 70}")
    for i in ids_nuevos:
        m = metricas[i]
        print(f"  {m.nombre:22s} {m.V_true:6.2f} {m.V_estimado:6.2f} {m.IC_L:7.2f} {m.IC_U:7.2f} {m.ancho_ic:6.2f} {'✓' if m.cobertura else '✗':>5s} {'✓' if m.mixing_ok else '✗':>5s} {'✓' if m.mixing_ok else '✗':>5s}")

    print(f"\n  {'=' * 75}")
    print(f"  EVALUACIÓN COMPLETADA")
    print(f"  {'=' * 75}")


if __name__ == "__main__":
    main()
