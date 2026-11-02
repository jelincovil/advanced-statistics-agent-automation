#!/usr/bin/env python3
"""
================================================================================
EJEMPLO DE EJECUCIÓN: AGENTE ESTADÍSTICO — CASO SSCH
================================================================================

Este script demuestra cómo usar el Agente Estadístico Asintótico para evaluar
una política en el entorno SSCH (Sistema de Soporte para Decisiones Clínicas
de Hígado), tal como se describe en:

  - Lab F.5.1: Bootstrap de Políticas
  - Lab F.5.2: Incertidumbre Epistémica vs Aleatoria
  - ex:ssch-cap05: Ejemplo numérico del Capítulo 5

Configuración de entrada (según el enunciado del prompt):
  - 100 trayectorias simuladas
  - Política π_b (práctica habitual)
  - ε = 0.5 (tolerancia de ancho de IC)
  - α = 0.05 (nivel de confianza 95%)
  - IC objetivo: [4.08, 5.56] (del ejemplo del capítulo)

Uso:
    python ejemplo_ssch.py
================================================================================
"""

import numpy as np
from agente_asintotico import (
    AgenteEstadisticoAsintotico,
    ConfiguracionAgente,
    simular_trayectorias_ssch,
)


def main():
    print("=" * 75)
    print(" EJEMPLO SSCH — Agente Estadístico Asintótico (Capítulo 5)")
    print("=" * 75)

    # ------------------------------------------------------------------
    # CONFIGURACIÓN DE ENTRADA
    # ------------------------------------------------------------------
    print("\n[1] CONFIGURACIÓN DE ENTRADA")
    print("    • n_trayectorias  = 100")
    print("    • política        = π_b (práctica habitual)")
    print("    • α               = 0.05")
    print("    • ε_tolerancia    = 0.5")
    print("    • tipo IC         = percentil-t")
    print("    • B (réplicas)    = 1000")

    cfg = ConfiguracionAgente(
        alpha=0.05,
        B=1000,
        epsilon_tolerancia=0.5,
        tipo_ic="percentil-t",
        semilla=42,
    )

    # ------------------------------------------------------------------
    # GENERACIÓN DE DATOS
    # ------------------------------------------------------------------
    print("\n[2] GENERACIÓN DE TRAYECTORIAS SSCH")
    np.random.seed(42)
    retornos = simular_trayectorias_ssch(n=100, semilla=42)
    print(f"    • Media muestral V̂^π = {np.mean(retornos):.4f}")
    print(f"    • Desviación estándar = {np.std(retornos, ddof=1):.4f}")
    print(f"    • Rango               = [{np.min(retornos):.2f}, {np.max(retornos):.2f}]")

    # ------------------------------------------------------------------
    # EJECUCIÓN DEL AGENTE
    # ------------------------------------------------------------------
    print("\n[3] EJECUCIÓN DEL PIPELINE COMPLETO")
    print("    Módulos activos:")
    print("      ✓ Diagnóstico de Mixing (Prop 5.2)")
    print("      ✓ Bootstrap IC (Thm 5.7, Def 5.4)")
    print("      ✓ Descomposición de Incertidumbre (Lab F.5.2)")
    print("      ✓ Decisión Autónoma (Lab F.5.1)")
    print("-" * 75)

    agente = AgenteEstadisticoAsintotico(config=cfg)
    reporte = agente.evaluar_politica(retornos=retornos)

    # ------------------------------------------------------------------
    # RESULTADOS
    # ------------------------------------------------------------------
    print("\n" + reporte.__repr__())

    # ------------------------------------------------------------------
    # VALIDACIÓN CONTRA VALORES ESPERADOS DEL CAPÍTULO
    # ------------------------------------------------------------------
    print("\n" + "-" * 75)
    print("[4] VALIDACIÓN CONTRA VALORES DEL CAPÍTULO")
    print("-" * 75)

    # Valores del capítulo: IC bootstrap 95% = [4.08, 5.56], ancho = 1.48
    L_esperado, U_esperado = 4.08, 5.56
    ancho_esperado = U_esperado - L_esperado

    rb = reporte.resultado_bootstrap
    print(f"  IC esperado (capítulo) : [{L_esperado:.2f}, {U_esperado:.2f}] (ancho {ancho_esperado:.2f})")
    print(f"  IC obtenido (agente)   : [{rb.L:.4f}, {rb.U:.4f}] (ancho {rb.ancho:.4f})")

    tol = 0.5
    diff_L = abs(rb.L - L_esperado)
    diff_U = abs(rb.U - U_esperado)
    if diff_L < tol and diff_U < tol:
        print(f"  ✓ IC dentro de tolerancia ±{tol} de los valores del capítulo")
    else:
        print(f"  ⚠ IC difiere de valores del capítulo (diferencias: L={diff_L:.4f}, U={diff_U:.4f})")
        print(f"    Nota: Las trayectorias son simuladas; variabilidad esperada.")

    print(f"\n  Diagnóstico mixing:")
    if reporte.resultado_mixing:
        rm = reporte.resultado_mixing
        print(f"    ρ̂ estimado       = {rm.rho_estimado:.4f}")
        print(f"    Mixing OK        = {rm.mixing_ok}")
        if rm.mixing_ok:
            print(f"    ✓ CLT válido con varianza de largo plazo σ²_LR = {rm.varianza_largo_plazo:.4f}")
        else:
            print(f"    ⚠ Precaución: mixing no verificado; IC puede estar mal calibrado")

    print(f"\n  Decisión:")
    rd = reporte.resultado_decision
    print(f"    Acción           = {rd.decision.upper()}")
    print(f"    Ancho IC         = {rd.ancho_ic:.4f}")
    print(f"    Tolerancia ε     = {cfg.epsilon_tolerancia}")
    if rd.decision == "actuar":
        print(f"    ✓ Precisión suficiente según criterio del Lab F.5.1")
    else:
        print(f"    → Se recomiendan {rd.n_recomendado} trayectorias adicionales")

    print("\n" + "=" * 75)


if __name__ == "__main__":
    main()
