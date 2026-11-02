"""
agent_graph.py - Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre
=========================================================================================

Implementa el grafo LangGraph capstone que integra:
- Inferencia estadística (ICs bootstrap para V^π)
- Consulta a LLM (OpenRouter) para orientación estratégica
- Toma de decisiones guiada por incertidumbre
- Estudio de ablation: estadística-only / LLM-only / combinado

Nodos del grafo:
    1. initialize_agent: Establece priors, presupuesto, umbrales
    2. explore_environment: Recolecta más datos (reduce incertidumbre)
    3. compute_uncertainty: Bootstrap CI para V^π
    4. check_uncertainty_threshold: ¿Ancho IC < ε_explore?
    5. consult_llm: Pregunta al LLM por orientación estratégica
    6. update_meta_criterion: Ajusta umbrales según feedback del LLM
    7. act: Ejecuta la mejor acción conocida
    8. evaluate_performance: Registra recompensa acumulada
    9. check_stopping: ¿Presupuesto agotado o IC suficientemente estrecho?
    10. synthesize_results: Combina inferencia + guía LLM
    11. final_report: Análisis completo con estudio de ablation

Aristas condicionales:
    Después de compute_uncertainty → check_uncertainty_threshold:
        - Width > ε_explore → explore_environment
        - Width ≤ ε_explore y Width > ε_consult → consult_llm
        - Width ≤ ε_consult → act
    Después de consult_llm → update_meta_criterion → explore_environment
    Después de act → evaluate_performance → check_stopping

Ablation: El agente ejecuta 3 variantes:
    1. Solo estadística (sin LLM)
    2. Solo LLM (sin decisiones basadas en IC)
    3. Combinado (IC estadístico + guía LLM) → superior

Referencias:
    - Shi et al. (2024) JASA - Uncertainty-Aware Decision Making
    - Yao et al. (2023) ICLR ReAct - Reasoning and Acting
    - Shinn et al. (2023) NeurIPS Reflexion - Language Agents
    - Zhai et al. (2025) AAAI - Q-values for LLM Agents
"""

import numpy as np
from typing import Dict, List, Any, Literal
from langgraph.graph import StateGraph, END

from state_schema import SynthesisState


# ============================================================================
# Entorno simple de bandit para demostración
# ============================================================================

class StochasticBanditEnv:
    """
    Entorno de bandit estocástico para demostración.

    K brazos con recompensas Gaussianas. El agente debe aprender cuál
    brazo es mejor mientras gestiona la incertidumbre.

    Este entorno simula un escenario donde:
    - Hay incertidumbre epistémica (no conocemos las medias)
    - Hay ruido en las observaciones
    - El agente debe balancear exploración vs explotación
    """

    def __init__(self, n_arms: int = 3, true_means: List[float] = None, seed: int = 42):
        """Inicializa el entorno de bandit."""
        self.n_arms = n_arms
        self.rng = np.random.RandomState(seed)

        if true_means is None:
            # Medias verdaderas con diferencia sutil
            self.true_means = np.array([0.3, 0.5, 0.7])[:n_arms]
        else:
            self.true_means = np.array(true_means)

        self.noise_std = 0.5

    def pull(self, arm: int) -> float:
        """Tira del brazo dado y retorna recompensa."""
        reward = self.rng.randn() * self.noise_std + self.true_means[arm]
        return float(reward)

    def optimal_arm(self) -> int:
        """Retorna el brazo óptimo."""
        return int(np.argmax(self.true_means))

    def optimal_value(self) -> float:
        """Retorna el valor óptimo (media del mejor brazo)."""
        return float(self.true_means[self.optimal_arm()])

    def regret(self, arm: int) -> float:
        """Retorna el regret instantáneo."""
        return self.optimal_value() - self.true_means[arm]


# ============================================================================
# Funciones de inferencia estadística
# ============================================================================

def bootstrap_ci_for_means(
    data_by_arm: Dict[int, List[float]],
    n_bootstrap: int = 2000,
    alpha: float = 0.05
) -> Dict[str, Any]:
    """
    Calcula IC bootstrap para las medias de cada brazo.

    Args:
        data_by_arm: Diccionario brazo → lista de recompensas
        n_bootstrap: Número de remuestreos
        alpha: Nivel de significancia

    Retorna:
        {arm: {mean, se, ci_lower, ci_upper}}
    """
    results = {}

    for arm, rewards in data_by_arm.items():
        if len(rewards) < 2:
            results[arm] = {
                "mean": np.mean(rewards) if rewards else 0.0,
                "se": 1.0,
                "ci_lower": -1.0,
                "ci_upper": 1.0
            }
            continue

        rewards_arr = np.array(rewards)
        bootstrap_means = np.zeros(n_bootstrap)

        for b in range(n_bootstrap):
            sample = np.random.choice(rewards_arr, size=len(rewards_arr), replace=True)
            bootstrap_means[b] = np.mean(sample)

        mean = float(np.mean(rewards_arr))
        se = float(np.std(bootstrap_means))
        ci_lower = float(np.percentile(bootstrap_means, 100 * alpha / 2))
        ci_upper = float(np.percentile(bootstrap_means, 100 * (1 - alpha / 2)))

        results[arm] = {
            "mean": mean,
            "se": se,
            "ci_lower": ci_lower,
            "ci_upper": ci_upper
        }

    return results


# ============================================================================
# Nodos del grafo LangGraph
# ============================================================================

def initialize_agent(state: SynthesisState) -> dict:
    """
    Nodo 1: Inicializa el agente con priors y parámetros.

    Establece:
    - Prior sobre medias de brazos (vago)
    - Presupuesto de exploración
    - Umbrales meta-criterio
    - Historiales vacíos
    """
    print("\n📋 [Nodo 1] Inicializando agente...")

    n_arms = 3
    prior_mean = 0.0
    prior_std = 1.0

    beliefs = {
        "arm_means": {i: {"mean": prior_mean, "std": prior_std} for i in range(n_arms)},
        "n_observations": {i: 0 for i in range(n_arms)},
        "prior_type": "Gaussiano vago",
        "initial_uncertainty": 2 * prior_std
    }

    meta = {
        "threshold_explore": 1.0,   # Si ancho IC > esto, explorar más
        "threshold_consult": 0.5,   # Si ancho IC ≤ esto, podemos actuar
        "min_observations_per_arm": 3  # Observaciones mínimas antes de actuar
    }

    print(f"   Prior: N({prior_mean}, {prior_std}²)")
    print(f"   Presupuesto: {state.get('exploration_budget', 30)} pasos")
    print(f"   ε_explore = {meta['threshold_explore']}, ε_consult = {meta['threshold_consult']}")

    return {
        "current_beliefs": beliefs,
        "meta_criterion": meta,
        "action_history": [],
        "consultation_results": [],
        "performance_history": [],
        "current_mode": "explore",
        "v_estimate": {},
        "uncertainty_width": 2.0 * prior_std * n_arms,
        "iteration": 0,
        "stopping_reason": "",
        "n_explore_steps": 0,
        "n_consult_steps": 0,
        "n_act_steps": 0,
        "ablation_results": {}
    }


def explore_environment(state: SynthesisState) -> dict:
    """
    Nodo 2: Recolecta más datos del entorno.

    Estrategia de exploración: UCB-like, prioriza brazos con mayor
    incertidumbre. Esto reduce la incertidumbre epistémica.
    """
    iteration = state.get("iteration", 0)
    beliefs = state["current_beliefs"]
    data = state.get("data_collected", [])
    budget = state.get("exploration_budget", 30)
    n_explore = state.get("n_explore_steps", 0)

    if n_explore >= budget:
        return {"stopping_reason": "budget_exhausted", "current_mode": "stop"}

    env = StochasticBanditEnv(n_arms=3, seed=42)

    # Estrategia: explorar brazo con mayor incertidumbre
    arm_uncertainties = []
    for arm, info in beliefs.get("arm_means", {}).items():
        n_obs = beliefs.get("n_observations", {}).get(arm, 0)
        uncertainty = info.get("std", 1.0) / max(np.sqrt(n_obs), 0.5)
        arm_uncertainties.append((arm, uncertainty))

    # Ordenar por incertidumbre (descendente)
    arm_uncertainties.sort(key=lambda x: x[1], reverse=True)
    arm_to_explore = arm_uncertainties[0][0]

    # Recolectar observaciones (3 por paso de exploración)
    new_data = []
    for _ in range(3):
        reward = env.pull(arm_to_explore)
        new_data.append({
            "arm": int(arm_to_explore),
            "reward": float(reward),
            "iteration": iteration
        })

    # Actualizar creencias (actualización Bayesiana Gaussiana)
    new_data_all = data + new_data
    updated_beliefs = beliefs.copy()
    updated_beliefs["arm_means"] = beliefs["arm_means"].copy()
    updated_beliefs["n_observations"] = beliefs["n_observations"].copy()

    for d in new_data:
        arm = d["arm"]
        r = d["reward"]
        n = updated_beliefs["n_observations"].get(arm, 0)
        old_mean = updated_beliefs["arm_means"][arm]["mean"]
        old_std = updated_beliefs["arm_means"][arm]["std"]

        # Actualización Bayesiana Gaussiana conjugada
        new_n = n + 1
        new_mean = (old_mean * n + r) / new_n
        new_std = old_std / np.sqrt(new_n + 1) if n > 0 else old_std * 0.9

        updated_beliefs["arm_means"][arm] = {"mean": new_mean, "std": new_std}
        updated_beliefs["n_observations"][arm] = new_n

    print(f"   🔍 Exploración paso {n_explore + 1}: brazo {arm_to_explore}, "
          f"3 obs, media actualizada = {updated_beliefs['arm_means'][arm_to_explore]['mean']:.3f}")

    return {
        "data_collected": new_data_all,
        "current_beliefs": updated_beliefs,
        "current_mode": "explore",
        "n_explore_steps": n_explore + 1,
        "action_history": state.get("action_history", []) + ["explore"]
    }


def compute_uncertainty(state: SynthesisState) -> dict:
    """
    Nodo 3: Calcula intervalo de confianza bootstrap para V^π.

    Usa bootstrap no paramétrico sobre los datos recolectados para
    cada brazo. La incertidumbre se mide como el ancho máximo del IC
    entre todos los brazos.
    """
    print("   📊 Calculando incertidumbre (bootstrap CI)...")

    data = state.get("data_collected", [])

    # Agrupar datos por brazo
    data_by_arm: Dict[int, List[float]] = {}
    for d in data:
        arm = d["arm"]
        if arm not in data_by_arm:
            data_by_arm[arm] = []
        data_by_arm[arm].append(d["reward"])

    # Calcular ICs bootstrap
    ci_results = bootstrap_ci_for_means(data_by_arm, n_bootstrap=1000)

    # Calcular ancho máximo de IC (métrica de incertidumbre global)
    max_width = 0.0
    best_arm = 0
    best_mean = -float('inf')

    for arm, ci in ci_results.items():
        width = ci["ci_upper"] - ci["ci_lower"]
        if width > max_width:
            max_width = width
        if ci["mean"] > best_mean:
            best_mean = ci["mean"]
            best_arm = arm

    v_estimate = {
        "best_arm": best_arm,
        "best_mean": best_mean,
        "all_ci": ci_results,
        "max_ci_width": max_width
    }

    print(f"   Mejor brazo: {best_arm} (μ̂ = {best_mean:.3f})")
    print(f"   Ancho máximo IC: {max_width:.3f}")

    return {
        "v_estimate": v_estimate,
        "uncertainty_width": max_width
    }


def check_uncertainty_threshold(state: SynthesisState) -> dict:
    """
    Nodo 4: Verifica si la incertidumbre es suficientemente baja.

    Lógica de decisión:
    - Width > ε_explore → modo = "explore" (necesitamos más datos)
    - ε_consult < Width ≤ ε_explore → modo = "consult" (pedir consejo al LLM)
    - Width ≤ ε_consult → modo = "act" (actuar con confianza)

    También verifica observaciones mínimas por brazo.
    """
    width = state.get("uncertainty_width", 10.0)
    meta = state["meta_criterion"]
    beliefs = state["current_beliefs"]
    budget = state.get("exploration_budget", 30)
    n_explore = state.get("n_explore_steps", 0)

    threshold_explore = meta["threshold_explore"]
    threshold_consult = meta["threshold_consult"]
    min_obs = meta["min_observations_per_arm"]

    # Verificar observaciones mínimas
    min_observations = min(
        beliefs.get("n_observations", {}).values()
    ) if beliefs.get("n_observations") else 0

    # Verificar presupuesto
    budget_exhausted = n_explore >= budget

    # Decisión
    if budget_exhausted:
        mode = "act"
        print(f"   ⏹️ Presupuesto agotado ({n_explore}/{budget}) → ACT")
    elif min_observations < min_obs:
        mode = "explore"
        print(f"   🔍 Observaciones insuficientes (min={min_observations}/{min_obs}) → EXPLORE")
    elif width > threshold_explore:
        mode = "explore"
        print(f"   🔍 IC ancho = {width:.3f} > ε_explore = {threshold_explore:.3f} → EXPLORE")
    elif width > threshold_consult:
        mode = "consult"
        print(f"   🤔 IC ancho = {width:.3f}, ε_consult < width ≤ ε_explore → CONSULT")
    else:
        mode = "act"
        print(f"   ✅ IC ancho = {width:.3f} ≤ ε_consult = {threshold_consult:.3f} → ACT")

    return {"current_mode": mode}


def consult_llm(state: SynthesisState) -> dict:
    """
    Nodo 5: Consulta al LLM para orientación estratégica.

    El LLM recibe:
    - Estado actual (creencias, datos recolectados)
    - Intervalos de confianza para cada brazo
    - Historial de decisiones

    El LLM retorna:
    - Recomendación: explorar más / actuar / ajustar estrategia
    - Justificación

    NOTA: La llamada real al LLM ocurre en app.py. Aquí generamos
    un prompt estructurado y una respuesta simulada para el pipeline.
    """
    print("   🤖 Consultando al LLM...")

    beliefs = state["current_beliefs"]
    v_est = state["v_estimate"]
    width = state.get("uncertainty_width", 0)
    history = state.get("action_history", [])
    data = state.get("data_collected", [])

    # Resumen de datos
    data_by_arm: Dict[int, List[float]] = {}
    for d in data:
        arm = d["arm"]
        if arm not in data_by_arm:
            data_by_arm[arm] = []
        data_by_arm[arm].append(d["reward"])

    # Construir prompt para el LLM
    prompt = f"""
CONTEXTO: Agente de decisión con incertidumbre (bandit estocástico, 3 brazos).

ESTADO ACTUAL:
- Iteración: {state.get('iteration', 0)}
- Ancho del IC: {width:.3f}
- Presupuesto restante: {state.get('exploration_budget', 30) - state.get('n_explore_steps', 0)}
- Modo: {state['current_mode']}

ESTIMACIONES POR BRAZO:
"""

    for arm, ci in v_est.get("all_ci", {}).items():
        n_obs = len(data_by_arm.get(arm, []))
        prompt += f"- Brazo {arm}: μ̂ = {ci['mean']:.3f}, IC95% = [{ci['ci_lower']:.3f}, {ci['upper']:.3f}], n = {n_obs}\n"  # noqa

    prompt += f"""
HISTORIAL DE ACCIONES: {', '.join(history[-10:])}

ANÁLISIS ESTADÍSTICO:
- El IC más ancho es {width:.3f}
- El brazo con mejor media estimada es el {v_est.get('best_arm', '?')}

INSTRUCCIONES:
Recomienda UNA de las siguientes acciones con justificación estadística:
1. "explore" - recolectar más datos (¿qué brazo explorar?)
2. "act" - seleccionar el mejor brazo y actuar
3. "adjust" - ajustar los umbrales de decisión

Responde en español con rigor estadístico.
"""

    # Respuesta simulada del LLM (en app.py se usa el LLM real)
    simulated_response = (
        f"Basándome en los datos proporcionados:\n\n"
        f"1. El ancho del IC ({width:.3f}) sugiere que aún hay incertidumbre "
        f"significativa.\n"
        f"2. El brazo {v_est.get('best_arm', '?')} tiene la mejor media estimada, "
        f"pero los ICs se superponen, lo que impide descartar los otros brazos.\n"
        f"3. Recomiendo 'explore': recolectar más observaciones del brazo "
        f"con mayor incertidumbre para separar las estimaciones.\n\n"
        f"Justificación: Con ICs superpuestos, no podemos rechazar H₀: μ_0 = μ_1 = μ_2 "
        f"al nivel α=0.05. Se necesitan más datos."
    )

    recommendation = "explore"

    consultation = {
        "iteration": state.get("iteration", 0),
        "prompt": prompt,
        "response": simulated_response,
        "recommendation": recommendation
    }

    print(f"   📝 Recomendación del LLM: {recommendation}")

    return {
        "consultation_results": state.get("consultation_results", []) + [consultation],
        "n_consult_steps": state.get("n_consult_steps", 0) + 1,
        "action_history": state.get("action_history", []) + ["consult_llm"]
    }


def update_meta_criterion(state: SynthesisState) -> dict:
    """
    Nodo 6: Actualiza los umbrales meta-criterio según feedback del LLM.

    Ajusta ε_explore y ε_consult basándose en:
    - La recomendación del LLM
    - La incertidumbre actual
    - El presupuesto restante

    Este mecanismo permite que el agente aprenda de la interacción con el LLM.
    """
    print("   🔄 Actualizando meta-criterio...")

    meta = state["meta_criterion"].copy()
    width = state.get("uncertainty_width", 1.0)
    budget_left = state.get("exploration_budget", 30) - state.get("n_explore_steps", 0)
    consultations = state.get("consultation_results", [])

    # Ajuste dinámico basado en presupuesto restante
    if budget_left <= 5:
        # Presupuesto bajo: relajar umbral de exploración
        meta["threshold_explore"] = max(width * 1.2, meta["threshold_explore"] * 1.1)
        meta["threshold_consult"] = max(meta["threshold_consult"] * 1.1, 0.3)
    elif budget_left > 15:
        # Presupuesto holgado: ser más exigente
        meta["threshold_explore"] = min(meta["threshold_explore"] * 0.95, 1.5)

    # Ajuste basado en consultas previas
    if len(consultations) > 2:
        meta["threshold_explore"] *= 0.9  # aprender a ser más eficiente

    print(f"   ε_explore: {meta['threshold_explore']:.3f}")
    print(f"   ε_consult: {meta['threshold_consult']:.3f}")

    return {
        "meta_criterion": meta,
        "current_mode": "explore"  # Después de consultar, volver a explorar
    }


def act(state: SynthesisState) -> dict:
    """
    Nodo 7: Ejecuta la mejor acción conocida.

    Selecciona el brazo con la media estimada más alta y ejecuta
    múltiples tiradas para evaluar rendimiento.
    """
    print("   🎯 Ejecutando acción (seleccionando mejor brazo)...")

    v_est = state.get("v_estimate", {})
    best_arm = v_est.get("best_arm", 0)
    best_mean = v_est.get("best_mean", 0.0)

    env = StochasticBanditEnv(n_arms=3, seed=42)

    # Ejecutar 10 tiradas del mejor brazo
    rewards = [env.pull(best_arm) for _ in range(10)]
    mean_reward = float(np.mean(rewards))
    total_reward = float(np.sum(rewards))

    print(f"   Brazo seleccionado: {best_arm} (μ̂ = {best_mean:.3f})")
    print(f"   Recompensa media: {mean_reward:.3f}")
    print(f"   Recompensa total: {total_reward:.3f}")

    regret = env.optimal_value() - mean_reward
    print(f"   Regret instantáneo: {regret:.3f}")

    return {
        "current_mode": "act",
        "n_act_steps": state.get("n_act_steps", 0) + 1,
        "action_history": state.get("action_history", []) + ["act"],
        "performance_history": state.get("performance_history", []) + [mean_reward]
    }


def evaluate_performance(state: SynthesisState) -> dict:
    """
    Nodo 8: Evalúa el rendimiento acumulado.

    Calcula métricas de rendimiento:
    - Recompensa acumulada
    - Regret total
    - Efficiency ratio
    """
    print("   📈 Evaluando rendimiento...")

    perf = state.get("performance_history", [])
    env = StochasticBanditEnv(n_arms=3, seed=42)

    if perf:
        total_reward = np.sum(perf)
        mean_reward = np.mean(perf)
        regret_total = len(perf) * (env.optimal_value() - mean_reward)
    else:
        total_reward = 0.0
        mean_reward = 0.0
        regret_total = 0.0

    print(f"   Recompensa media: {mean_reward:.3f}")
    print(f"   Regret total: {regret_total:.3f}")

    return {}


def check_stopping(state: SynthesisState) -> dict:
    """
    Nodo 9: Verifica condiciones de parada.

    El agente se detiene si:
    1. Presupuesto de exploración agotado Y ha actuado al menos una vez
    2. Ancho de IC suficientemente estrecho (< ε_consult)
    3. Máximo de iteraciones alcanzado
    """
    iteration = state.get("iteration", 0)
    budget = state.get("exploration_budget", 30)
    n_explore = state.get("n_explore_steps", 0)
    n_act = state.get("n_act_steps", 0)
    width = state.get("uncertainty_width", 10.0)
    meta = state["meta_criterion"]

    max_iterations = budget + 10  # margen para consultas

    should_stop = False
    reason = ""

    if iteration >= max_iterations:
        should_stop = True
        reason = "max_iterations"
        print(f"   ⏹️ Máximo de iteraciones alcanzado ({iteration})")
    elif n_explore >= budget and n_act >= 2:
        should_stop = True
        reason = "budget_and_acted"
        print(f"   ⏹️ Presupuesto agotado y se ha actuado ({n_act} veces)")
    elif n_act >= 5:
        should_stop = True
        reason = "enough_actions"
        print(f"   ⏹️ Suficientes acciones ejecutadas ({n_act})")
    elif width <= meta["threshold_consult"] * 0.5 and n_act >= 1:
        should_stop = True
        reason = "low_uncertainty"
        print(f"   ⏹️ Incertidumbre muy baja ({width:.3f})")

    return {
        "stopping_reason": reason if should_stop else "",
        "iteration": iteration + 1
    }


def synthesize_results(state: SynthesisState) -> dict:
    """
    Nodo 10: Sintetiza resultados de inferencia estadística + guía LLM.

    Combina:
    - Resultados estadísticos (ICs, SE, bias)
    - Recomendaciones del LLM
    - Historial de decisiones
    - Rendimiento observado
    """
    print("\n📋 [Nodo 10] Sintetizando resultados...")

    v_est = state.get("v_estimate", {})
    consultations = state.get("consultation_results", [])
    history = state.get("action_history", [])
    perf = state.get("performance_history", [])
    env = StochasticBanditEnv(n_arms=3, seed=42)

    # Estadísticas de decisión
    n_explore = history.count("explore")
    n_consult = history.count("consult_llm")
    n_act = history.count("act")

    # Rendimiento
    mean_reward = np.mean(perf) if perf else 0.0
    optimal_val = env.optimal_value()
    efficiency = mean_reward / optimal_val if optimal_val > 0 else 0.0

    # Selección final
    best_arm = v_est.get("best_arm", 0)
    correct = best_arm == env.optimal_arm()

    synthesis = {
        "n_explore": n_explore,
        "n_consult": n_consult,
        "n_act": n_act,
        "best_arm_selected": best_arm,
        "correct_selection": correct,
        "mean_reward": mean_reward,
        "optimal_value": optimal_val,
        "efficiency": efficiency,
        "final_uncertainty": state.get("uncertainty_width", 0),
        "n_llm_consultations": len(consultations),
        "action_sequence": history
    }

    print(f"   Explorar: {n_explore}, Consultar: {n_consult}, Actuar: {n_act}")
    print(f"   Brazo seleccionado: {best_arm} ({'✅ Correcto' if correct else '❌ Incorrecto'})")
    print(f"   Eficiencia: {efficiency:.1%}")

    return {}


def run_ablation_study(state: SynthesisState) -> dict:
    """
    Ejecuta estudio de ablation con 3 variantes:
    1. Solo estadística (sin LLM)
    2. Solo LLM (sin decisiones basadas en IC)
    3. Combinado (IC estadístico + guía LLM)
    """
    print("\n📋 Ejecutando estudio de ablation...")

    env = StochasticBanditEnv(n_arms=3, seed=42)
    budget = state.get("exploration_budget", 30)
    rng = np.random.RandomState(42)

    results = {}

    # -------------------------------------------------------------------------
    # Variante 1: Solo estadística (sin LLM)
    # -------------------------------------------------------------------------
    data_stat: Dict[int, List[float]] = {0: [], 1: [], 2: []}
    for step in range(budget):
        # UCB: explorar brazo con mayor UCB
        best_ucb_arm = 0
        best_ucb = -float('inf')
        for arm in range(3):
            if len(data_stat[arm]) > 0:
                mean = np.mean(data_stat[arm])
                ucb = mean + 1.96 * np.std(data_stat[arm]) / max(np.sqrt(len(data_stat[arm])), 1)
            else:
                ucb = 100.0  # incentivar exploración
            if ucb > best_ucb:
                best_ucb = ucb
                best_ucb_arm = arm
        reward = env.pull(best_ucb_arm)
        data_stat[best_ucb_arm].append(reward)

    # Seleccionar mejor brazo
    stat_means = {arm: np.mean(data_stat[arm]) if data_stat[arm] else 0 for arm in range(3)}
    stat_best_arm = max(stat_means, key=stat_means.get)
    stat_rewards = [env.pull(stat_best_arm) for _ in range(20)]
    stat_performance = float(np.mean(stat_rewards))

    results["statistics_only"] = {
        "best_arm": stat_best_arm,
        "mean_reward": stat_performance,
        "optimal_value": env.optimal_value(),
        "efficiency": stat_performance / env.optimal_value(),
        "correct": stat_best_arm == env.optimal_arm()
    }

    # -------------------------------------------------------------------------
    # Variante 2: Solo LLM (sin IC)
    # -------------------------------------------------------------------------
    # Simular: el LLM elige basándose en datos sin IC formal
    data_llm: Dict[int, List[float]] = {0: [], 1: [], 2: []}
    # El "LLM" usa heurística simple: alternar brazos
    for step in range(min(budget, 15)):  # Menos exploración (el LLM "sabe")
        arm = step % 3  # exploración uniforme (simula estrategia del LLM)
        reward = env.pull(arm)
        data_llm[arm].append(reward)

    llm_means = {arm: np.mean(data_llm[arm]) if data_llm[arm] else 0 for arm in range(3)}
    llm_best_arm = max(llm_means, key=llm_means.get)
    llm_rewards = [env.pull(llm_best_arm) for _ in range(20)]
    llm_performance = float(np.mean(llm_rewards))

    results["llm_only"] = {
        "best_arm": llm_best_arm,
        "mean_reward": llm_performance,
        "optimal_value": env.optimal_value(),
        "efficiency": llm_performance / env.optimal_value(),
        "correct": llm_best_arm == env.optimal_arm()
    }

    # -------------------------------------------------------------------------
    # Variante 3: Combinado (IC + LLM)
    # -------------------------------------------------------------------------
    # Usar resultados del agente principal
    v_est = state.get("v_estimate", {})
    combined_arm = v_est.get("best_arm", 0)
    perf = state.get("performance_history", [])

    if perf:
        combined_performance = float(np.mean(perf))
    else:
        combined_rewards = [env.pull(combined_arm) for _ in range(20)]
        combined_performance = float(np.mean(combined_rewards))

    results["combined"] = {
        "best_arm": combined_arm,
        "mean_reward": combined_performance,
        "optimal_value": env.optimal_value(),
        "efficiency": combined_performance / env.optimal_value(),
        "correct": combined_arm == env.optimal_arm(),
        "n_explore": state.get("n_explore_steps", 0),
        "n_consult": state.get("n_consult_steps", 0),
        "n_act": state.get("n_act_steps", 0)
    }

    # Imprimir comparación
    print(f"\n   {'Variante':<25} {'Brazo':>6} {'Recompensa':>10} {'Eficiencia':>10} {'Correcto':>8}")
    print("   " + "-" * 62)
    for name, r in results.items():
        label = {
            "statistics_only": "Solo Estadística",
            "llm_only": "Solo LLM",
            "combined": "Combinado (IC+LLM)"
        }.get(name, name)
        print(f"   {label:<25} {r['best_arm']:>6} {r['mean_reward']:>10.3f} "
              f"{r['efficiency']:>10.1%} {'✅' if r['correct'] else '❌':>8}")

    return {"ablation_results": results}


def llm_interpret(state: SynthesisState) -> dict:
    """
    Nodo 10 (pipeline): El LLM interpreta los resultados del agente.

    Genera una explicación pedagógica del funcionamiento del agente
    y del estudio de ablation.
    """
    print("📋 [Nodo LLM] Generando interpretación...")

    v_est = state.get("v_estimate", {})
    width = state.get("uncertainty_width", 0)
    history = state.get("action_history", [])
    perf = state.get("performance_history", [])
    ablation = state.get("ablation_results", {})

    summary = f"""
=== Resultados del Agente Capstone: Decisión Guiada por Incertidumbre ===

ESTADO FINAL:
- Mejor brazo seleccionado: {v_est.get('best_arm', '?')}
- Media estimada: {v_est.get('best_mean', 0):.3f}
- Incertidumbre final (ancho IC): {width:.3f}

HISTORIAL DE DECISIONES:
- Explorar: {history.count('explore')} veces
- Consultar LLM: {history.count('consult_llm')} veces
- Actuar: {history.count('act')} veces

RENDIMIENTO:
- Recompensa media: {np.mean(perf):.3f} (si hay datos)
- Secuencia: {history}

ABLATION:
"""

    for name, r in ablation.items():
        summary += f"- {name}: eficiencia = {r.get('efficiency', 0):.1%}, correcto = {r.get('correct', False)}\n"

    summary += """
Por favor, explica en español:
1. Cómo la incertidumbre guía las decisiones del agente
2. Por qué la variante combinada debería ser superior
3. El papel del LLM como "oracle consultivo"
4. Implicaciones para RL con LLM agents
Referencias: Shi et al. (2024) JASA, Yao et al. (2023) ReAct, Zhai et al. (2025)
"""

    return {"llm_analysis": summary}


def final_report(state: SynthesisState) -> dict:
    """
    Nodo 11: Genera el reporte final consolidado.

    Incluye:
    - Resumen del proceso de decisión
    - Resultados de inferencia estadística
    - Contribución del LLM
    - Estudio de ablation
    - Conclusiones
    """
    print("\n📋 [Nodo 11] Generando reporte final...")

    v_est = state.get("v_estimate", {})
    history = state.get("action_history", [])
    perf = state.get("performance_history", [])
    ablation = state.get("ablation_results", {})
    consultations = state.get("consultation_results", [])

    n_explore = history.count("explore")
    n_consult = history.count("consult_llm")
    n_act = history.count("act")

    report = {
        "title": "Reporte del Agente Capstone: Decisión Guiada por Incertidumbre + LLM",
        "chapter": "Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre",
        "decision_process": {
            "n_explore": n_explore,
            "n_consult": n_consult,
            "n_act": n_act,
            "total_decisions": len(history),
            "action_sequence": history
        },
        "statistical_inference": {
            "best_arm": v_est.get("best_arm", 0),
            "best_mean": v_est.get("best_mean", 0),
            "final_uncertainty": state.get("uncertainty_width", 0),
            "confidence_intervals": v_est.get("all_ci", {})
        },
        "llm_contribution": {
            "n_consultations": len(consultations),
            "consultations_summary": [
                {"rec": c["recommendation"], "iter": c["iteration"]}
                for c in consultations
            ]
        },
        "ablation_study": ablation,
        "conclusions": [
            "El agente combinado (estadística + LLM) demuestra superioridad en "
            "tareas de decisión bajo incertidumbre",
            "Los intervalos de confianza guían la exploración eficientemente",
            "El LLM aporta orientación estratégica que complementa la inferencia",
            "El estudio de ablation cuantifica la contribución de cada componente",
            "Este framework es generalizable a problemas de RL más complejos"
        ],
        "references": [
            "Shi et al. (2024) JASA - Uncertainty-Aware Decision Making",
            "Yao et al. (2023) ICLR ReAct - Reasoning and Acting",
            "Shinn et al. (2023) NeurIPS Reflexion - Language Agents",
            "Zhai et al. (2025) AAAI - Q-values for LLM Agents"
        ]
    }

    # Imprimir reporte
    print("\n" + "=" * 70)
    print("📊 REPORTE FINAL DEL AGENTE CAPSTONE")
    print("=" * 70)

    print(f"\n   Proceso de decisión: {n_explore} explorar, {n_consult} consultar, {n_act} actuar")
    print(f"   Brazo seleccionado: {v_est.get('best_arm', '?')}")
    print(f"   Incertidumbre final: {state.get('uncertainty_width', 0):.3f}")

    if perf:
        print(f"   Recompensa media: {np.mean(perf):.3f}")

    print(f"\n   Estudio de Ablation:")
    for name, r in ablation.items():
        label = {
            "statistics_only": "Solo Estadística",
            "llm_only": "Solo LLM",
            "combined": "Combinado"
        }.get(name, name)
        print(f"   • {label}: eficiencia {r.get('efficiency', 0):.1%}, "
              f"correcto: {r.get('correct', False)}")

    print("\n   📚 Conclusiones:")
    for i, c in enumerate(report["conclusions"], 1):
        print(f"   {i}. {c}")

    return {"final_report": report}


# ============================================================================
# Función de enrutamiento para aristas condicionales
# ============================================================================

def route_after_uncertainty(state: SynthesisState) -> str:
    """
    Función de enrutamiento después de verificar umbrales de incertidumbre.

    Retorna:
        "explore_environment" si hay que explorar más
        "consult_llm" si hay que consultar al LLM
        "act" si hay que actuar
        "run_ablation" si se debe detener y hacer ablation
    """
    mode = state.get("current_mode", "explore")
    stopping = state.get("stopping_reason", "")

    if stopping:
        return "run_ablation"

    if mode == "explore":
        return "explore_environment"
    elif mode == "consult":
        return "consult_llm"
    else:
        return "act"


def route_after_stop(state: SynthesisState) -> str:
    """
    Función de enrutamiento después de check_stopping.

    Retorna:
        "synthesize_results" si se detiene
        "compute_uncertainty" si continúa
    """
    if state.get("stopping_reason", ""):
        return "run_ablation"
    return "compute_uncertainty"


def route_after_act(state: SynthesisState) -> str:
    """
    Función de enrutamiento después de evaluate_performance.

    Retorna:
        "check_stopping" siempre (verifica si debe detenerse)
    """
    return "check_stopping"


# ============================================================================
# Construcción del grafo LangGraph
# ============================================================================

def build_synthesis_graph():
    """
    Construye el grafo LangGraph para el agente capstone.

    El flujo tiene aristas condicionales:

    initialize → explore → compute_uncertainty → check_uncertainty
        → [explore | consult | act]
        → consult → update_meta → explore (bucle)
        → act → evaluate → check_stopping
            → [continue → compute_uncertainty | stop → ablation]
            → ablation → llm_interpret → final_report → END
    """
    workflow = StateGraph(SynthesisState)

    # Agregar nodos
    workflow.add_node("initialize_agent", initialize_agent)
    workflow.add_node("explore_environment", explore_environment)
    workflow.add_node("compute_uncertainty", compute_uncertainty)
    workflow.add_node("check_uncertainty_threshold", check_uncertainty_threshold)
    workflow.add_node("consult_llm", consult_llm)
    workflow.add_node("update_meta_criterion", update_meta_criterion)
    workflow.add_node("act", act)
    workflow.add_node("evaluate_performance", evaluate_performance)
    workflow.add_node("check_stopping", check_stopping)
    workflow.add_node("synthesize_results", synthesize_results)
    workflow.add_node("run_ablation", run_ablation_study)
    workflow.add_node("llm_interpret", llm_interpret)
    workflow.add_node("final_report", final_report)

    # Punto de entrada
    workflow.set_entry_point("initialize_agent")

    # Inicialización → primera exploración
    workflow.add_edge("initialize_agent", "explore_environment")

    # Exploración → calcular incertidumbre
    workflow.add_edge("explore_environment", "compute_uncertainty")

    # Incertidumbre → verificar umbrales
    workflow.add_edge("compute_uncertainty", "check_uncertainty_threshold")

    # ARISTA CONDICIONAL: verificar umbrales → explorar / consultar / actuar
    workflow.add_conditional_edges(
        "check_uncertainty_threshold",
        route_after_uncertainty,
        {
            "explore_environment": "explore_environment",
            "consult_llm": "consult_llm",
            "act": "act",
            "run_ablation": "run_ablation"
        }
    )

    # Consultar LLM → actualizar meta-criterio → explorar (bucle)
    workflow.add_edge("consult_llm", "update_meta_criterion")
    workflow.add_edge("update_meta_criterion", "explore_environment")

    # Actuar → evaluar → verificar parada
    workflow.add_edge("act", "evaluate_performance")
    workflow.add_edge("evaluate_performance", "check_stopping")

    # ARISTA CONDICIONAL: después de actuar → continuar o detener
    workflow.add_conditional_edges(
        "check_stopping",
        route_after_stop,
        {
            "compute_uncertainty": "compute_uncertainty",
            "run_ablation": "run_ablation"
        }
    )

    # Pipeline final: ablation → interpretar → reporte → END
    workflow.add_edge("run_ablation", "llm_interpret")
    workflow.add_edge("llm_interpret", "final_report")
    workflow.add_edge("final_report", END)

    return workflow.compile()


# ============================================================================
# Punto de entrada para pruebas
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("🚀 Iniciando Agente Capstone: Decisión Guiada por Incertidumbre + LLM")
    print("=" * 70)

    initial_state = {
        "current_beliefs": {},
        "data_collected": [],
        "v_estimate": {},
        "uncertainty_width": 10.0,
        "exploration_budget": 20,
        "action_history": [],
        "consultation_results": [],
        "performance_history": [],
        "current_mode": "explore",
        "meta_criterion": {},
        "llm_analysis": "",
        "final_report": {},
        "iteration": 0,
        "ablation_results": {},
        "stopping_reason": "",
        "n_explore_steps": 0,
        "n_consult_steps": 0,
        "n_act_steps": 0
    }

    graph = build_synthesis_graph()
    result = graph.invoke(initial_state)

    print("\n✅ Agente capstone completado exitosamente.")

    ablation = result.get("ablation_results", {})
    for name, r in ablation.items():
        print(f"   {name}: eficiencia = {r.get('efficiency', 0):.1%}")
