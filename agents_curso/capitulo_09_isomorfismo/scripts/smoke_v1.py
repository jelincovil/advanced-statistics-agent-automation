"""Smoke test: el agente v1 arranca y produce resultados coherentes."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import numpy as np
from isomorphism_agent import build_agent, run_agent, WaldProblem, F, verify_isomorphism

np.random.seed(42)

# Datos Bernoulli(θ=0.4), n=100
data = np.random.binomial(1, 0.4, size=100)
print(f"Datos: n={len(data)}, sum={data.sum()}, x_bar={data.mean():.3f}")

# Ejecutar agente
result = run_agent(data, prior={"alpha": 2.0, "beta": 2.0},
                   loss_args={"cost_treat": 0.2, "cost_skip": 1.0})
print("\n--- Resultados del agente ---")
print(f"theta_hat = {result['theta_hat']:.4f}")
print(f"IC 95% theta = [{result['ic_theta'][0]:.4f}, {result['ic_theta'][1]:.4f}]")
print(f"Accion Bayes d* = {result['bayes_action']}")
print(f"Accion MDP   p* = {result['mdp_action']}")
print(f"Isomorfismo OK? {result['isomorphism_ok']}")
print(f"IC 95% V^pi = [{result['ic_V'][0]:.4f}, {result['ic_V'][1]:.4f}]")
print(f"Test z = {result['test_stat']:.3f}, p = {result['p_value']:.4f}, decision = {result['test_decision']}")
