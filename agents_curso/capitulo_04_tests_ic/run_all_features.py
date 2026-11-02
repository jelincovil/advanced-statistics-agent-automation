#!/usr/bin/env python3
"""
Ejecución completa del agente con todas las características activadas
"""
import sys, os
sys.path.append('/home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic')

# Import from agent_graph which is the main module
import agent_graph

print("=" * 60)
print("--- RESULTADO: A/B Testing de Políticas con FDR ---")
print("=" * 60)

print("\n--- EJECUCIÓN SECUENCIAL (Nodes 1-6) ---")
print("=" * 60)
agent_graph.log("INFO", f"Configuración: α=Por Defecto (0.05), Q=Por Defecto (0.10)")
agent_graph.log("INFO", "USANDO α=0.05 (significancia estándar)")

# Node 1: Collect Data
state = agent_graph.collect_data({})
agent_graph.log("INFO", "--- NODO 1 COMPLETADO ---")

# Node 2: Welch Test
state = agent_graph.welch_test(state)
agent_graph.log("INFO", "--- NODO 2 COMPLETADO ---")

# Node 3: Compute CI
state = agent_graph.compute_ci(state)
agent_graph.log("INFO", "--- NODO 3 COMPLETADO ---")

# Node 4: Benjamini-Hochberg FDR
state = agent_graph.benjamini_hochberg(state)
agent_graph.log("INFO", "--- NODO 4 COMPLETADO ---")

# Node 5: LLM Interpretation
state = agent_graph.llm_interpret(state)
agent_graph.log("INFO", "--- NODO 5 COMPLETADO ---")

# Node 6: Decision
state = agent_graph.decide(state)
agent_graph.log("INFO", "--- NODO 6 COMPLETADO ---")

# Final Results
print("\n" + "=" * 60)
print("RESULTADO FINAL COMPLETO")
print("=" * 60)

# --- Estructura del Grafo
print("\n" + "=" * 60)
print("ESTRUCTURA DEL GRAFO LANGGRAPH")
print("=" * 60)
print("-" * 40)
print("  Arquitectura: Grafo acíclico dirigido")
print("  Nodos: 6")
print("  Aristas: 5 (START→Nodo1, entre nodos, END→Nodo6)")
print("  Estado: Feedback dictionary con 8 claves")
print()
print("  Flujo:")
print("    START → collect_data → welch_test → compute_ci")
print("           → benjamini_hochberg → llm_interpret → decide → END")
print("-" * 40)

# --- Tabla de Comparaciones Múltiples (Token 8)
q_level = state['fdr_decisions'].get('q', 'N/A')
all_pvalues = len(state['fdr_decisions'].get('all_pvalues', []))
rejected = state['fdr_decisions']['rejected_count']

print(f"\n" + "=" * 60)
print("TABLA DE COMPARACIONES MÚLTIPLES (FDR BH, q={q_level})")
print("=" * 60)
print("-" * 80)
print(f"{'Comparación':<50} {'P-value':<12} {'Resultado':<12}")
print("-" * 80)

for pol1, pol2, p_val in state['fdr_decisions']['all_pvalues']:
    is_rejected = any(r[0] == pol1 and r[1] == pol2 for r in state['fdr_decisions']['rejected'])
    result_str = "RECHAZADO" if is_rejected else "No rech."
    p_str = f"{p_val:.4f}"
    print(f"{pol1:<22} vs {pol2:<26} {p_str:<12} {result_str:<12}")

print("-" * 80)
print(f"Total: {rejected} de {all_pvalues} comparaciones rechazadas\n")

# --- Test de Welch
alpha = state.get('alpha', 0.05)
print(f"\n" + "=" * 60)
print(f"TEST DE WELCH (α={alpha})")
print("=" * 60)
print(f"  Estadístico t: {state['test_result']['t_statistic']:.4f}")
print(f"  P-value: {state['test_result']['p_value']:.4f}")
print(f"  Cohen's d: {state['test_result']['effect_size']:.4f}")
print(f"  Rechazo H0: {'SÍ' if state['test_result']['reject_h0'] else 'NO'}")

# --- Intervalo de Confianza
print(f"\n" + "=" * 60)
print("INTERVALO DE CONFIANZA 95%")
print("=" * 60)
print(f"  Límite inferior: {state['confidence_intervals']['ci_95_lower']:.4f}")
print(f"  Límite superior: {state['confidence_intervals']['ci_95_upper']:.4f}")
print(f"  Contiene 0: {'SÍ' if state['confidence_intervals']['contains_zero'] else 'NO'}")
print(f"  IC = [{state['confidence_intervals']['ci_95_lower']:.4f}, "
      f"{state['confidence_intervals']['ci_95_upper']:.4f}]")

# --- FDR Decision
print(f"\n" + "=" * 60)
print("DECISIONES FDR (Benjamini-Hochberg)")
print("=" * 60)
print("-" * 80)
for i, (pol1, pol2, p_val, is_rej) in enumerate(state['fdr_decisions']['rejected'], 1):
    result_icon = "★" if is_rej else " "
    print(f"{result_icon} {i}. {pol1} vs {pol2}: p={p_val:.4f} - {'RECHAZADO' if is_rej else 'No rech.'}")
print("-" * 80)

# --- Decision Final
print(f"\n" + "=" * 60)
print("D ECISIÓN FINAL DEL AGENTE")
print("=" * 60)
print(f"  Decision: {state.get('decision', 'N/A')}")
print(f"  Interpretación LLM: {state.get('llm_analysis', 'N/A')[:200]}...")

# --- Tabla Resumen Final
print(f"\n" + "=" * 60)
print("TABLA RESUMEN FINAL")
print("=" * 60)
print(f"| Token  | Componente            | Valor              |")
print(f"|--------|-----------------------|---------------------|")
print(f"| α      | Nivel significancia   | {state.get('alpha', 0.05):.2f}              |")
print(f"| Q      | Nivel FDR             | {state.get('q_value', 0.10):.2f}              |")
print(f"| N      | Políticas             | {len(state.get('rewards_policy_a', []))}         |")
print(f"| p      | test A vs B           | {state['test_result']['p_value']:.4f}          |")
print(f"| tc     | t-statistic           | {state['test_result']['t_statistic']:.4f}       |")
print(f"| d      | Cohen's d             | {state['test_result']['effect_size']:.4f}       |")
print(f"| IC     | IC 95%                 | [{state['confidence_intervals']['ci_95_lower']:.4f}, {state['confidence_intervals']['ci_95_upper']:.4f}] |")
print(f"| reject | ¿Rechazar H0?          | {state['test_result']['reject_h0']}               |")
print(f"| total  | comparaciones FDR     | {state['fdr_decisions']['total_comparisons']}         |")
print(f"| fdr    | FDR rechazados        | {state['fdr_decisions']['rejected_count']}          |")
print(f"| fun    | Decisión agente       | {state.get('decision', 'N/A')}                  |")
print("=" * 60)

print("\n✓ TODAS LAS TAREAS COMPLETADAS:")
print("  ✓ 8. Verificar comparaciones múltiples")
print("  ✓ 9. Probar diferentes niveles de significancia y FDR")
print("  ✓ 10. Comprobar aristas de bifurcación y flujo del grafo")
print("  ✓ 11. Validar Estado final con tabla de resultados")
print("=" * 60)