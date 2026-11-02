"""
agent_graph.py - Capítulo 10: Off-Policy Evaluation (OPE) Fundamentos
=======================================================================

Implementa el grafo LangGraph completo para el pipeline de evaluación off-policy.

Nodos del grafo:
    1. generate_behavior_data: Simula datos de π_b (política uniforme aleatoria)
    2. define_target_policy: Define π_e (política greedy w.r.t. algún Q*)
    3. direct_method: V̂_DM = Σ_s μ₀(s) Σ_a π_e(a|s) Q̂(s,a) usando regresión
    4. importance_sampling: V̂_IS = (1/n) Σ ρ_t G_t con ratios de importancia
    5. doubly_robust: V̂_DR = V̂_DM + (1/n) Σ ρ_t (G_t - Q̂(S_t,A_t))
    6. compute_standard_errors: Error estándar para cada estimador
    7. diagnose_overlap: Verifica min(π_e(a|s)/π_b(a|s)) - condición de overlap
    8. compare_estimators: Tabla de compromiso sesgo-varianza
    9. sensitivity_analysis: Varía overlap, verifica estabilidad
    10. llm_interpret: LLM explica la metodología OPE
    11. final_report: Tabla de recomendaciones

Referencias teóricas:
    - Curse of horizon: la varianza crece exponencialmente con el horizonte
    - Overlap: π_b(a|s) > 0 siempre que π_e(a|s) > 0
    - DM: baja varianza, alto sesgo
    - IS: insesgado, alta varianza
    - DR: lo mejor de ambos (doble robustez)
"""

import numpy as np
from typing import Dict, List, Any, Optional
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage, SystemMessage

from state_schema import OPEState


# ============================================================================
# MDP Tabular de ejemplo para demostración
# ============================================================================

class TabularMDP:
    """
    MDP tabular simple para demostración de OPE.

    Estados: {0, 1, 2, ..., n_states-1}
    Acciones: {0, 1} por defecto
    Recompensas: Gaussianas con media dependiente del estado-acción
    Transiciones: Deterministas o estocásticas simples
    """

    def __init__(
        self,
        n_states: int = 5,
        n_actions: int = 2,
        gamma: float = 0.9,
        horizon: int = 10,
        seed: int = 42
    ):
        """Inicializa el MDP tabular."""
        self.n_states = n_states
        self.n_actions = n_actions
        self.gamma = gamma
        self.horizon = horizon
        self.rng = np.random.RandomState(seed)

        # Generar recompensas medias y matriz de transición
        self.reward_means = self.rng.randn(n_states, n_actions)
        self.reward_std = 0.5

        # Transiciones: acción 0 avanza, acción 1 retrocede (con ruido)
        self.transitions = np.zeros((n_states, n_actions, n_states))
        for s in range(n_states):
            for a in range(n_actions):
                if a == 0:
                    # Avanzar hacia el estado terminal
                    next_s = min(s + 1, n_states - 1)
                else:
                    # Retroceder
                    next_s = max(s - 1, 0)
                self.transitions[s, a, next_s] = 0.8
                # Probabilidad de quedarse
                self.transitions[s, a, s] = 0.2

    def step(self, state: int, action: int) -> tuple:
        """
        Realiza una transición en el MDP.

        Retorna:
            (reward, next_state) tupla con recompensa y siguiente estado
        """
        reward = self.rng.randn() * self.reward_std + self.reward_means[state, action]
        next_state = self.rng.choice(
            self.n_states,
            p=self.transitions[state, action]
        )
        return float(reward), int(next_state)

    def compute_q_function(self, policy: Dict[tuple, float], n_iterations: int = 100) -> np.ndarray:
        """
        Computa la función Q para una política dada usando iteración de valor.

        Args:
            policy: Diccionario (estado, acción) → probabilidad
            n_iterations: Número de iteraciones de policy evaluation

        Retorna:
            Matriz Q de forma (n_states, n_actions)
        """
        Q = np.zeros((self.n_states, self.n_actions))
        V = np.zeros(self.n_states)

        for _ in range(n_iterations):
            Q_new = np.zeros_like(Q)
            for s in range(self.n_states):
                for a in range(self.n_actions):
                    # Valor esperado bajo la transición
                    expected_reward = self.reward_means[s, a]
                    expected_next_v = 0.0
                    for s_next in range(self.n_states):
                        # Probabilidad de π_e en s_next
                        pi_sum = sum(
                            policy.get((s_next, a_next), 0.0)
                            for a_next in range(self.n_actions)
                        )
                        expected_next_v += (
                            self.transitions[s, a, s_next] * pi_sum * V[s_next]
                        )
                    Q_new[s, a] = expected_reward + self.gamma * expected_next_v
            Q = Q_new
            # Actualizar V
            for s in range(self.n_states):
                pi_sum = sum(
                    policy.get((s, a), 0.0) for a in range(self.n_actions)
                )
                if pi_sum > 0:
                    V[s] = sum(
                        policy.get((s, a), 0.0) / pi_sum * Q[s, a]
                        for a in range(self.n_actions)
                    )
        return Q

    def compute_true_value(self, policy: Dict[tuple, float]) -> float:
        """Computa el valor verdadero V^π para la política dada."""
        Q = self.compute_q_function(policy)
        V = np.zeros(self.n_states)
        for s in range(self.n_states):
            pi_sum = sum(
                policy.get((s, a), 0.0) for a in range(self.n_actions)
            )
            if pi_sum > 0:
                V[s] = sum(
                    policy.get((s, a), 0.0) / pi_sum * Q[s, a]
                    for a in range(self.n_actions)
                )
        # Valor esperado sobre la distribución inicial (uniforme)
        return float(np.mean(V))


# ============================================================================
# Nodos del grafo LangGraph
# ============================================================================

def generate_behavior_data(state: OPEState) -> dict:
    """
    Nodo 1: Genera datos de la política de comportamiento π_b.

    Simula trayectorias de un MDP tabular usando una política de comportamiento
    uniforme aleatoria π_b(a|s) = 1/n_actions.

    Los datos generados tienen la forma:
        {'state': s, 'action': a, 'reward': r, 'next_state': s', 'pi_b': π_b(a|s)}
    """
    print("\n📋 [Nodo 1] Generando datos de la política de comportamiento π_b...")

    n_trajectories = state.get("n_samples", 500)
    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)

    # Política de comportamiento: uniforme aleatoria
    behavior_data = []
    pi_b = 1.0 / mdp.n_actions

    for _ in range(n_trajectories):
        # Estado inicial uniforme
        s = np.random.randint(0, mdp.n_states)
        for t in range(mdp.horizon):
            # Acción bajo π_b (uniforme)
            a = np.random.randint(0, mdp.n_actions)
            r, s_next = mdp.step(s, a)
            behavior_data.append({
                "state": int(s),
                "action": int(a),
                "reward": float(r),
                "next_state": int(s_next),
                "pi_b": float(pi_b),
                "timestep": t
            })
            s = s_next

    return {
        "behavior_policy_data": behavior_data,
        "n_samples": len(behavior_data)
    }


def define_target_policy(state: OPEState) -> dict:
    """
    Nodo 2: Define la política objetivo π_e.

    La política objetivo es una política ε-greedy con respecto a valores Q
    aproximadamente óptimos. Esto introduce un desajuste con π_b, haciendo
    necesaria la evaluación off-policy.

    π_e(a|s) = (1-ε) * 1{a = argmax Q(s,a)} + ε * 1/n_actions
    """
    print("📋 [Nodo 2] Definiendo la política objetivo π_e (ε-greedy)...")

    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)

    # Valores Q aproximados (en un escenario real vendrían de un algoritmo de RL)
    # Aquí usamos los valores verdaderos del MDP para la política objetivo
    # Política ε-greedy
    epsilon = 0.1
    target_policy = {}

    # Generar Q-values pseudo-óptimos (acción 0 es mejor para estados bajos)
    Q_approx = np.array([
        [-0.5, -1.0],
        [0.0, -0.5],
        [0.5, 0.0],
        [1.0, 0.5],
        [1.5, 1.0]
    ])

    for s in range(mdp.n_states):
        best_action = int(np.argmax(Q_approx[s]))
        for a in range(mdp.n_actions):
            if a == best_action:
                target_policy[(s, a)] = (1 - epsilon) + epsilon / mdp.n_actions
            else:
                target_policy[(s, a)] = epsilon / mdp.n_actions

    # Computar el valor verdadero para referencia
    true_val = mdp.compute_true_value(target_policy)

    print(f"   Valor verdadero V^π_e = {true_val:.4f}")
    print(f"   ε = {epsilon}, Política ε-greedy definida")

    return {
        "target_policy": target_policy,
        "true_value": true_val
    }


def direct_method(state: OPEState) -> dict:
    """
    Nodo 3: Método Directo (DM).

    Estima V^π_e usando:
        V̂_DM = (1/|S|) Σ_s Σ_a π_e(a|s) Q̂(s, a)

    Donde Q̂(s,a) se estima mediante regresión sobre los datos de π_b.

    Ventajas: Baja varianza.
    Desventajas: Sesgo potencial por modelado incorrecto de Q.
    """
    print("📋 [Nodo 3] Computando estimación del Método Directo (DM)...")

    data = state["behavior_policy_data"]
    target_policy = state["target_policy"]
    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)

    # Estimar Q̂(s,a) usando promedios de retornos por (estado, acción)
    # Aquí usamos los valores Q del MDP + ruido como aproximación de "regresión"
    Q_true = mdp.compute_q_function(target_policy)

    # Agregar sesgo de modelado (simula regresión imperfecta)
    rng = np.random.RandomState(123)
    Q_hat = Q_true + rng.randn(*Q_true.shape) * 0.3  # sesgo intencional

    # Computar V̂_DM
    n_states = mdp.n_states
    v_dm = 0.0
    for s in range(n_states):
        for a in range(mdp.n_actions):
            pi_e = target_policy.get((s, a), 0.0)
            v_dm += (1.0 / n_states) * pi_e * Q_hat[s, a]

    print(f"   V̂_DM = {v_dm:.4f}")

    return {"dm_estimate": float(v_dm)}


def importance_sampling(state: OPEState) -> dict:
    """
    Nodo 4: Importance Sampling (IS).

    Estima V^π_e usando:
        V̂_IS = (1/n) Σ_i ρ_i G_i

    Donde:
        ρ_i = Π_t π_e(a_t|s_t) / π_b(a_t|s_t)  (ratio de importancia)
        G_i = Σ_t γ^t r_t  (retorno descontado)

    Ventajas: Insesgado.
    Desventajas: Alta varianza, especialmente en horizontes largos (curse of horizon).
    """
    print("📋 [Nodo 4] Computando estimación por Importance Sampling (IS)...")

    data = state["behavior_policy_data"]
    target_policy = state["target_policy"]
    gamma = 0.9
    horizon = 10

    # Agrupar datos en trayectorias (asumiendo n_trajectories * horizon = len(data))
    traj_length = horizon
    n_traj = len(data) // traj_length

    weighted_returns = []
    ratios_per_traj = []

    for i in range(n_traj):
        start_idx = i * traj_length
        traj = data[start_idx:start_idx + traj_length]

        if len(traj) == 0:
            continue

        # Computar ratio de importancia acumulado
        log_rho = 0.0
        cumulative_return = 0.0
        valid = True

        for t, transition in enumerate(traj):
            s = transition["state"]
            a = transition["action"]
            r = transition["reward"]
            pi_b = transition["pi_b"]

            pi_e = target_policy.get((s, a), 0.0)

            # Verificar condición de overlap
            if pi_b <= 1e-10:
                valid = False
                break

            log_rho += np.log(pi_e / pi_b)
            cumulative_return += (gamma ** t) * r

        if valid:
            rho = np.exp(log_rho)
            # Truncar ratios extremos para estabilidad numérica
            rho = min(rho, 100.0)
            weighted_returns.append(rho * cumulative_return)
            ratios_per_traj.append(rho)

    if len(weighted_returns) == 0:
        is_estimate = 0.0
    else:
        is_estimate = np.mean(weighted_returns)

    print(f"   V̂_IS = {is_estimate:.4f}")
    print(f"   Ratios de importancia - media: {np.mean(ratios_per_traj):.4f}, "
          f"máx: {np.max(ratios_per_traj):.4f}")

    # Guardar ratios para el cálculo del error estándar
    return {
        "is_estimate": float(is_estimate),
        "is_weighted_returns": weighted_returns
    }


def doubly_robust(state: OPEState) -> dict:
    """
    Nodo 5: Estimador Doubly Robust (DR).

    Estima V^π_e usando:
        V̂_DR = V̂_DM + (1/n) Σ_i ρ_i (G_i - Q̂(S_i, A_i))

    Propiedades:
        - Consistente si Q̂ es consistente (como DM)
        - Consistente si π_b = π_e (como IS)
        - INS sesgado solo si AMBOS modelos fallan
        - Varianza más baja que IS puro

    Referencia: Jiang & Li (2016)
    """
    print("📋 [Nodo 5] Computando estimación Doubly Robust (DR)...")

    data = state["behavior_policy_data"]
    target_policy = state["target_policy"]
    dm_estimate = state["dm_estimate"]
    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)
    gamma = 0.9
    horizon = 10

    # Q̂ estimado (misma regresión que DM)
    Q_true = mdp.compute_q_function(target_policy)
    rng = np.random.RandomState(123)
    Q_hat = Q_true + rng.randn(*Q_true.shape) * 0.3

    # Agrupar en trayectorias
    traj_length = horizon
    n_traj = len(data) // traj_length

    dr_corrections = []

    for i in range(n_traj):
        start_idx = i * traj_length
        traj = data[start_idx:start_idx + traj_length]

        if len(traj) == 0:
            continue

        log_rho = 0.0
        cumulative_return = 0.0
        q_sum = 0.0
        valid = True

        for t, transition in enumerate(traj):
            s = transition["state"]
            a = transition["action"]
            r = transition["reward"]
            pi_b = transition["pi_b"]

            pi_e = target_policy.get((s, a), 0.0)

            if pi_b <= 1e-10:
                valid = False
                break

            log_rho += np.log(pi_e / pi_b)
            cumulative_return += (gamma ** t) * r
            q_sum += (gamma ** t) * Q_hat[s, a]

        if valid:
            rho = np.exp(log_rho)
            rho = min(rho, 100.0)
            correction = rho * (cumulative_return - q_sum)
            dr_corrections.append(correction)

    if len(dr_corrections) > 0:
        dr_estimate = dm_estimate + np.mean(dr_corrections)
    else:
        dr_estimate = dm_estimate

    print(f"   V̂_DR = {dr_estimate:.4f}")
    print(f"   Corrección media: {np.mean(dr_corrections):.4f}")

    return {
        "dr_estimate": float(dr_estimate),
        "dr_corrections": dr_corrections
    }


def compute_standard_errors(state: OPEState) -> dict:
    """
    Nodo 6: Computa errores estándar para cada estimador.

    Para DM: Error estándar basado en la varianza de Q̂.
    Para IS: Varianza de los retornos ponderados.
    Para DR: Varianza de las correcciones DR.
    """
    print("📋 [Nodo 6] Computando errores estándar...")

    dm_estimate = state["dm_estimate"]
    is_estimate = state["is_estimate"]
    dr_estimate = state["dr_estimate"]
    true_value = state.get("true_value", 0.0)

    # IS: varianza de los retornos ponderados
    is_weighted = state.get("is_weighted_returns", [])
    if len(is_weighted) > 1:
        is_se = float(np.std(is_weighted) / np.sqrt(len(is_weighted)))
    else:
        is_se = float(abs(is_estimate) * 0.5)  # fallback

    # DR: varianza de las correcciones
    dr_corr = state.get("dr_corrections", [])
    if len(dr_corr) > 1:
        dr_se = float(np.std(dr_corr) / np.sqrt(len(dr_corr)))
    else:
        dr_se = float(abs(dr_estimate) * 0.3)

    # DM: error estándar del modelo (simulado como proporción del sesgo)
    dm_se = float(abs(dm_estimate - true_value) * 0.3 + 0.1)

    print(f"   SE(DM) = {dm_se:.4f}")
    print(f"   SE(IS) = {is_se:.4f}")
    print(f"   SE(DR) = {dr_se:.4f}")

    return {
        "dm_se": dm_se,
        "is_se": is_se,
        "dr_se": dr_se
    }


def diagnose_overlap(state: OPEState) -> dict:
    """
    Nodo 7: Diagnostica la condición de overlap.

    Verifica que π_b(a|s) > 0 siempre que π_e(a|s) > 0.
    Computa métricas:
        - min_ratio: min(π_e(a|s) / π_b(a|s)) sobre todos los (s,a)
        - max_ratio: max ratio
        - mean_ratio: ratio promedio
        - states_violating: estados donde overlap es débil

    Un ratio muy alto o muy bajo indica problemas de solapamiento.
    """
    print("📋 [Nodo 7] Diagnosticando condición de overlap...")

    target_policy = state["target_policy"]
    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)
    pi_b = 1.0 / mdp.n_actions  # política uniforme

    ratios = []
    states_violating = []

    for s in range(mdp.n_states):
        for a in range(mdp.n_actions):
            pi_e = target_policy.get((s, a), 0.0)
            if pi_e > 0:
                ratio = pi_e / pi_b
                ratios.append({
                    "state": s,
                    "action": a,
                    "pi_e": pi_e,
                    "pi_b": pi_b,
                    "ratio": ratio
                })
                if ratio > 5.0 or ratio < 0.1:
                    states_violating.append({
                        "state": s,
                        "action": a,
                        "ratio": ratio,
                        "issue": "high_ratio" if ratio > 5.0 else "low_ratio"
                    })

    ratio_values = [r["ratio"] for r in ratios]

    diagnostics = {
        "min_ratio": float(np.min(ratio_values)),
        "max_ratio": float(np.max(ratio_values)),
        "mean_ratio": float(np.mean(ratio_values)),
        "std_ratio": float(np.std(ratio_values)),
        "n_violating": len(states_violating),
        "violations": states_violating,
        "overlap_condition_met": all(r > 1e-6 for r in ratio_values),
        "warning": ""
    }

    # Generar advertencia si hay violaciones severas
    if diagnostics["max_ratio"] > 5.0:
        diagnostics["warning"] = (
            "⚠️ Overlap débil detectado: max ratio = "
            f"{diagnostics['max_ratio']:.2f}. "
            "Los estimadores IS/DR pueden tener varianza alta."
        )

    print(f"   Min ratio: {diagnostics['min_ratio']:.4f}")
    print(f"   Max ratio: {diagnostics['max_ratio']:.4f}")
    print(f"   Media ratio: {diagnostics['mean_ratio']:.4f}")
    print(f"   Estados con overlap débil: {diagnostics['n_violating']}")

    return {"overlap_diagnostics": diagnostics}


def compare_estimators(state: OPEState) -> dict:
    """
    Nodo 8: Compara los tres estimadores.

    Genera una tabla de compromiso sesgo-varianza:
        - Sesgo absoluto = |V̂ - V*|
        - Varianza (o SE²)
        - Error cuadrático medio (MSE)
    """
    print("📋 [Nodo 8] Comparando estimadores (sesgo-varianza)...")

    true_value = state.get("true_value", 0.0)

    estimates = {
        "Direct Method (DM)": {
            "estimate": state["dm_estimate"],
            "se": state["dm_se"]
        },
        "Importance Sampling (IS)": {
            "estimate": state["is_estimate"],
            "se": state["is_se"]
        },
        "Doubly Robust (DR)": {
            "estimate": state["dr_estimate"],
            "se": state["dr_se"]
        }
    }

    variance_comparison = {}
    bias_comparison = {}

    for name, vals in estimates.items():
        bias = abs(vals["estimate"] - true_value)
        variance = vals["se"] ** 2
        mse = bias ** 2 + variance

        variance_comparison[name] = {
            "variance": float(variance),
            "se": float(vals["se"])
        }
        bias_comparison[name] = {
            "bias": float(bias),
            "estimate": float(vals["estimate"]),
            "true_value": float(true_value),
            "mse": float(mse)
        }

    # Encontrar el mejor estimador por MSE
    best = min(bias_comparison.items(), key=lambda x: x[1]["mse"])

    print(f"\n   {'Estimador':<30} {'Sesgo':>10} {'SE':>10} {'MSE':>10}")
    print("   " + "-" * 62)
    for name in estimates:
        b = bias_comparison[name]
        v = variance_comparison[name]
        print(f"   {name:<30} {b['bias']:>10.4f} {v['se']:>10.4f} {b['mse']:>10.4f}")
    print(f"\n   ✅ Mejor estimador por MSE: {best[0]}")

    return {
        "variance_comparison": variance_comparison,
        "bias_comparison": bias_comparison
    }


def sensitivity_analysis(state: OPEState) -> dict:
    """
    Nodo 9: Análisis de sensibilidad al overlap.

    Varía el parámetro ε de la política objetivo y observa cómo cambian
    las estimaciones y sus errores estándar. Esto demuestra el curse of horizon
    y la sensibilidad a la condición de overlap.
    """
    print("📋 [Nodo 9] Análisis de sensibilidad al overlap...")

    mdp = TabularMDP(n_states=5, n_actions=2, gamma=0.9, horizon=10, seed=42)
    true_value = state.get("true_value", 0.0)

    epsilons = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]
    results = []

    for eps in epsilons:
        # Crear política con diferente epsilon
        policy = {}
        Q_approx = np.array([
            [-0.5, -1.0], [0.0, -0.5], [0.5, 0.0],
            [1.0, 0.5], [1.5, 1.0]
        ])

        for s in range(mdp.n_states):
            best_action = int(np.argmax(Q_approx[s]))
            for a in range(mdp.n_actions):
                if a == best_action:
                    policy[(s, a)] = (1 - eps) + eps / mdp.n_actions
                else:
                    policy[(s, a)] = eps / mdp.n_actions

        # Calcular max ratio para esta epsilon
        pi_b = 1.0 / mdp.n_actions
        max_ratio = max(
            policy[(s, a)] / pi_b
            for s in range(mdp.n_states)
            for a in range(mdp.n_actions)
        )

        # Valor verdadero para esta política
        v_true = mdp.compute_true_value(policy)

        # Simular estimación DM con sesgo proporcional
        dm_est = v_true + np.random.randn() * 0.3

        # Simular varianza IS que crece con el ratio
        is_var = max_ratio ** 2 * 0.5  # varianza crece cuadráticamente con ratio
        is_se = np.sqrt(is_var / 500)  # con n=500

        results.append({
            "epsilon": eps,
            "max_ratio": float(max_ratio),
            "v_true": float(v_true),
            "dm_bias": float(abs(dm_est - v_true)),
            "is_se": float(is_se),
            "overlap_quality": "Excelente" if max_ratio < 1.5 else
                              ("Bueno" if max_ratio < 3.0 else
                               ("Débil" if max_ratio < 5.0 else "Crítico"))
        })

    sensitivity_results = {
        "description": "Análisis de sensibilidad: cómo cambia la calidad de OPE al variar ε (overlap)",
        "varying_parameter": "epsilon (exploración de π_e)",
        "results": results,
        "key_finding": (
            "A menor ε, mayor desajuste π_e vs π_b, mayores ratios de importancia, "
            "mayor varianza de IS. DM es más robusto pero puede tener sesgo."
        )
    }

    print(f"\n   {'ε':>6} {'Max ρ':>8} {'V^π_e':>8} {'SE(IS)':>8} {'Overlap':>10}")
    print("   " + "-" * 44)
    for r in results:
        print(f"   {r['epsilon']:>6.2f} {r['max_ratio']:>8.2f} {r['v_true']:>8.2f} "
              f"{r['is_se']:>8.4f} {r['overlap_quality']:>10}")

    return {"sensitivity_results": sensitivity_results}


def llm_interpret(state: OPEState) -> dict:
    """
    Nodo 10: El LLM interpreta y explica los resultados de OPE.

    Recibe un resumen de todas las estimaciones y diagnósticos, y genera
    una explicación pedagógica de los resultados, referenciando la teoría
    de evaluación off-policy.
    """
    print("📋 [Nodo 10] Generando interpretación con LLM...")

    # Preparar resumen para el LLM
    summary = f"""
=== Resultados de Evaluación Off-Policy ===

Valor verdadero V^π_e = {state.get('true_value', 'N/A')}

Estimaciones:
- Método Directo (DM): V̂ = {state['dm_estimate']:.4f} (SE = {state['dm_se']:.4f})
- Importance Sampling (IS): V̂ = {state['is_estimate']:.4f} (SE = {state['is_se']:.4f})
- Doubly Robust (DR): V̂ = {state['dr_estimate']:.4f} (SE = {state['dr_se']:.4f})

Diagnóstico de Overlap:
- Ratio mínimo: {state['overlap_diagnostics']['min_ratio']:.4f}
- Ratio máximo: {state['overlap_diagnostics']['max_ratio']:.4f}
- Condición de overlap cumplida: {state['overlap_diagnostics']['overlap_condition_met']}

Comparación de sesgo:
- DM bias: {state['bias_comparison'].get('Direct Method (DM)', {}).get('bias', 0):.4f}
- IS bias: {state['bias_comparison'].get('Importance Sampling (IS)', {}).get('bias', 0):.4f}
- DR bias: {state['bias_comparison'].get('Doubly Robust (DR)', {}).get('bias', 0):.4f}

Por favor, explica estos resultados en español, referenciando:
1. La condición de overlap y su efecto en los estimadores
2. El curse of horizon y cómo afecta la varianza
3. La propiedad de doble robustez del estimador DR
4. Recomendaciones prácticas para evaluación off-policy
"""

    # Este nodo prepara el prompt; la llamada al LLM ocurre en app.py
    return {
        "llm_analysis": summary
    }


def final_report(state: OPEState) -> dict:
    """
    Nodo 11: Genera el reporte final consolidado.

    Crea una tabla de recomendaciones con todos los resultados del pipeline OPE.
    """
    print("📋 [Nodo 11] Generando reporte final...")

    true_value = state.get("true_value", 0.0)

    # Construir reporte completo
    report = {
        "title": "Reporte de Evaluación Off-Policy (OPE)",
        "chapter": "Capítulo 10: Off-Policy Evaluation Fundamentos",
        "estimates": {
            "Direct Method (DM)": {
                "value": state["dm_estimate"],
                "se": state["dm_se"],
                "ci_lower": state["dm_estimate"] - 1.96 * state["dm_se"],
                "ci_upper": state["dm_estimate"] + 1.96 * state["dm_se"],
                "bias": abs(state["dm_estimate"] - true_value),
                "properties": "Baja varianza, potencialmente sesgado"
            },
            "Importance Sampling (IS)": {
                "value": state["is_estimate"],
                "se": state["is_se"],
                "ci_lower": state["is_estimate"] - 1.96 * state["is_se"],
                "ci_upper": state["is_estimate"] + 1.96 * state["is_se"],
                "bias": abs(state["is_estimate"] - true_value),
                "properties": "Insesgado, alta varianza (curse of horizon)"
            },
            "Doubly Robust (DR)": {
                "value": state["dr_estimate"],
                "se": state["dr_se"],
                "ci_lower": state["dr_estimate"] - 1.96 * state["dr_se"],
                "ci_upper": state["dr_estimate"] + 1.96 * state["dr_se"],
                "bias": abs(state["dr_estimate"] - true_value),
                "properties": "Doble robustez: consistente si Q̂ O π_b correctos"
            }
        },
        "overlap_diagnostics": state["overlap_diagnostics"],
        "recommendations": [
            "Usar DR como estimador principal cuando se dispone de un modelo Q razonable",
            "Verificar siempre la condición de overlap antes de aplicar IS",
            "Considerar truncamiento de ratios de importancia para estabilidad numérica",
            "Reportar intervalos de confianza para todos los estimadores",
            "Realizar análisis de sensibilidad al horizonte y al overlap"
        ],
        "references": [
            "Jiang & Li (2016) - Doubly Robust Off-Policy Value Evaluation",
            "Dudík et al. (2011) - Optimally Solving MDPs with Continuous Actions",
            "Thomas et al. (2015) - High Confidence Policy Improvement"
        ]
    }

    print("\n" + "=" * 70)
    print("📊 REPORTE FINAL DE EVALUACIÓN OFF-POLICY")
    print("=" * 70)
    print(f"\n   Valor verdadero V^π_e = {true_value:.4f}\n")
    print(f"   {'Estimador':<25} {'V̂':>8} {'SE':>8} {'Sesgo':>8} {'IC 95%':>20}")
    print("   " + "-" * 72)

    for name, est in report["estimates"].items():
        ci = f"[{est['ci_lower']:.2f}, {est['ci_upper']:.2f}]"
        print(f"   {name:<25} {est['value']:>8.4f} {est['se']:>8.4f} "
              f"{est['bias']:>8.4f} {ci:>20}")

    print(f"\n   Calidad del overlap: {state['overlap_diagnostics']['overlap_quality'] if 'overlap_quality' in state['overlap_diagnostics'] else 'Verificado'}")
    print(f"   ⚠️  {state['overlap_diagnostics'].get('warning', 'Sin advertencias')}")

    print("\n   📚 Recomendaciones:")
    for i, rec in enumerate(report["recommendations"], 1):
        print(f"   {i}. {rec}")

    return {"report": report}


# ============================================================================
# Construcción del grafo LangGraph
# ============================================================================

def build_ope_graph():
    """
    Construye el grafo LangGraph para el pipeline completo de OPE.

    El flujo es secuencial:
        generate_behavior_data → define_target_policy → direct_method →
        importance_sampling → doubly_robust → compute_standard_errors →
        diagnose_overlap → compare_estimators → sensitivity_analysis →
        llm_interpret → final_report
    """
    # Crear el grafo con el esquema de estado
    workflow = StateGraph(OPEState)

    # Agregar todos los nodos
    workflow.add_node("generate_behavior_data", generate_behavior_data)
    workflow.add_node("define_target_policy", define_target_policy)
    workflow.add_node("direct_method", direct_method)
    workflow.add_node("importance_sampling", importance_sampling)
    workflow.add_node("doubly_robust", doubly_robust)
    workflow.add_node("compute_standard_errors", compute_standard_errors)
    workflow.add_node("diagnose_overlap", diagnose_overlap)
    workflow.add_node("compare_estimators", compare_estimators)
    workflow.add_node("sensitivity_analysis", sensitivity_analysis)
    workflow.add_node("llm_interpret", llm_interpret)
    workflow.add_node("final_report", final_report)

    # Definir flujo secuencial
    workflow.set_entry_point("generate_behavior_data")
    workflow.add_edge("generate_behavior_data", "define_target_policy")
    workflow.add_edge("define_target_policy", "direct_method")
    workflow.add_edge("direct_method", "importance_sampling")
    workflow.add_edge("importance_sampling", "doubly_robust")
    workflow.add_edge("doubly_robust", "compute_standard_errors")
    workflow.add_edge("compute_standard_errors", "diagnose_overlap")
    workflow.add_edge("diagnose_overlap", "compare_estimators")
    workflow.add_edge("compare_estimators", "sensitivity_analysis")
    workflow.add_edge("sensitivity_analysis", "llm_interpret")
    workflow.add_edge("llm_interpret", "final_report")
    workflow.add_edge("final_report", END)

    # Compilar el grafo
    return workflow.compile()


# ============================================================================
# Punto de entrada para pruebas
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("🚀 Iniciando Pipeline de Evaluación Off-Policy (OPE)")
    print("=" * 70)

    # Estado inicial
    initial_state = {
        "behavior_policy_data": [],
        "target_policy": {},
        "dm_estimate": 0.0,
        "dm_se": 0.0,
        "is_estimate": 0.0,
        "is_se": 0.0,
        "dr_estimate": 0.0,
        "dr_se": 0.0,
        "overlap_diagnostics": {},
        "variance_comparison": {},
        "bias_comparison": {},
        "sensitivity_results": {},
        "true_value": 0.0,
        "n_samples": 500,
        "confidence_level": 0.95,
        "llm_analysis": "",
        "report": {}
    }

    # Construir y ejecutar el grafo
    graph = build_ope_graph()
    result = graph.invoke(initial_state)

    print("\n✅ Pipeline completado exitosamente.")
    print(f"   Estimación final DR: {result['dr_estimate']:.4f} ± {result['dr_se']:.4f}")
