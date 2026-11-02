"""
Script de prueba para el agente A/B Testing
"""
import sys
import os
import numpy as np

# Agregar directorio actual al path
sys.path.insert(0, os.getcwd())

from agent_graph import build_graph

print("=" * 70)
print("TEST: Agente A/B Testing - Ejecución Completa")
print("=" * 70)
print()

# 1. Construir grafo
print("1️⃣  Construyendo grafo...")
graph = build_graph()
print("✓ Grafo compilado correctamente")
print()

# 2. Ejecutar análisis
print("2️⃣  Inicializando estado inicial...")

# NOTA: En LangGraph con edges desde START, usamos llave=... para pasar estado adicional
# al nodo inicial
initial_state = {
    "rewards_policy_a": [],
    "rewards_policy_b": [],
    "rewards_other_policies": {},
}

print("3️⃣  Ejecutando análisis...")

# Pasamos el state a través de la clave 'threads' o directamente al invoke
# con config={'metadata': {'init_state': initial_state}}
result = graph.invoke(initial_state)
print("✓ Análisis completado")
print()

# 4. Mostrar resultados
print("4️⃣  Resultados del análisis:")
print("-" * 70)
print()
print(f"📊 ITERACIÓN 1: collect_data")
print(f"   - Muestras por política: {len(result['rewards_policy_a'])}")
print(f"   - Media π_A: {np.mean(result['rewards_policy_a']):.4f}")
print(f"   - Media π_B: {np.mean(result['rewards_policy_b']):.4f}")
print()

print(f"🔬 TEST DE WELCH")
test = result['test_result']
print(f"   - Estadístico t: {test['t_statistic']:.4f}")
print(f"   - p-valor: {test['p_value']:.4f}")
print(f"   - Cohen's d: {test['effect_size']:.4f}")
print(f"   - Grados de libertad: {test['nu']:.2f}")
print(f"   - Media π_A: {test['mean_a']:.4f}")
print(f"   - Media π_B: {test['mean_b']:.4f}")
print(f"   - Rechazar H₀ (α=0.05): {'Sí ✅' if test['reject_h0'] else 'No'}")
print()

print(f"📊 INTERVALO DE CONFIANZA 95%")
ci = result['confidence_intervals']
print(f"   - Diferencia (B-A): {ci['difference']:.4f}")
print(f"   - IC Inferior: {ci['ci_95_lower']:.4f}")
print(f"   - IC Superior: {ci['ci_95_upper']:.4f}")
print(f"   - Contiene cero: {'Sí' if ci['contains_zero'] else 'No'}")
print()

print(f"🎯 CORRECCIÓN FDR (Benjamini-Hochberg, q=0.10)")
fdr = result['fdr_decisions']
print(f"   - Total de tests: {fdr['total_tests']}")
print(f"   - Rechazados: {fdr['rejected_count']}")
print(f"   - Comparaciones significativas:")
for c in fdr['comparisons']:
    if c['p_value'] < 0.05:
        print(f"     * {c['pair']}: p={c['p_value']:.4f}, Δ={c['mean_diff']:.4f}")
print()

print(f"🤖 DECISIÓN FINAL")
print(f"   - {result['decision']}")
print()

print("=" * 70)
print("✅ TEST COMPLETADO EXITOSAMENTE")
print("=" * 70)
print()
print("Resumen:")
print(f"  ✓ Test de Welch ejecutado")
print(f"  ✓ Intervalo de confianza calculado")
print(f"  ✓ Corrección FDR aplicada (para {fdr['total_tests']} comparaciones)")
print(f"  ✓ Análisis LLM generado ({len(result['llm_analysis'])} caracteres)")
print(f"  ✓ Decisión final tomada")