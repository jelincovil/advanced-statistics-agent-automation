#!/usr/bin/env python3
"""
Test con diferentes configuacion de α y Q
"""
import sys, os
sys.path.append('/home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic')

import agent_graph

# Test 1: α=0.05 (default), Q=0.10
print("=" * 60)
print("TEST 1: α=0.05, Q=0.10")
print("=" * 60)
state = {}
state["alpha"] = 0.05
state["q_value"] = 0.10
state = agent_graph.collect_data(state)
state = agent_graph.welch_test(state)
state = agent_graph.compute_ci(state)
state = agent_graph.benjamini_hochberg(state)
state = agent_graph.decide(state)

print(f"\nTest de Welch α={state['alpha']}: p={state['test_result']['p_value']:.4f} (rechazar H0: {state['test_result']['reject_h0']})")
print(f"FDR Q={state['q_value']}: {state['fdr_decisions']['rejected_count']} de {state['fdr_decisions']['total_comparisons']} rechazados")

# Test 2: α=0.01 (más estricto), Q=0.05
print("\n" + "=" * 60)
print("TEST 2: α=0.01, Q=0.05 (más estricto)")
print("=" * 60)
state = {}
state["alpha"] = 0.01
state["q_value"] = 0.05
state = agent_graph.collect_data(state)
state = agent_graph.welch_test(state)
state = agent_graph.compute_ci(state)
state = agent_graph.benjamini_hochberg(state)
state = agent_graph.decide(state)

print(f"\nTest de Welch α={state['alpha']}: p={state['test_result']['p_value']:.4f} (rechazar H0: {state['test_result']['reject_h0']})")
print(f"FDR Q={state['q_value']}: {state['fdr_decisions']['rejected_count']} de {state['fdr_decisions']['total_comparisons']} rechazados")

# Test 3: α=0.10 (más laxo), Q=0.01 (muy conservador)
print("\n" + "=" * 60)
print("TEST 3: α=0.10, Q=0.01 (más laxo)")
print("=" * 60)
state = {}
state["alpha"] = 0.10
state["q_value"] = 0.01
state = agent_graph.collect_data(state)
state = agent_graph.welch_test(state)
state = agent_graph.compute_ci(state)
state = agent_graph.benjamini_hochberg(state)
state = agent_graph.decide(state)

print(f"\nTest de Welch α={state['alpha']}: p={state['test_result']['p_value']:.4f} (rechazar H0: {state['test_result']['reject_h0']})")
print(f"FDR Q={state['q_value']}: {state['fdr_decisions']['rejected_count']} de {state['fdr_decisions']['total_comparisons']} rechazados")
print("=" * 60)