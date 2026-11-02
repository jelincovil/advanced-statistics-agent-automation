"""
Capítulo 4: Tests de Hipótesis e Intervalos de Confianza
========================================================

Agente Graph LangChain para A/B Testing de Políticas con Control Multiple Testing

Contiene:
- Nodos: collect_data, welch_test, compute_ci, benjamini_hochberg, llm_interpret, decide
- Integración con modelos LLM vía OpenRouter
- Reporte de resultados con análisis lingüístico

Ejecutar directamente (testing sin interface):
    python agent_graph_clean.py

Ejecutar con Chainlit (interfaz web):
    chainlit run app.py
"""

import os
from typing import Annotated, TypedDict

import numpy as np
from langchain_openai import ChatOpenAI
from langgraph.graph import END, StateGraph
from langgraph.graph.state import CompiledStateGraph


# Reducer para campos que se reemplazan (no se acumulan)
def replace(old, new) -> dict:
    """Reducer: reemplaza el valor anterior con el nuevo."""
    return new


# ==============================================================================
# DEFINICIÓN DEL ESTADO
# ==============================================================================
class AgentState(TypedDict):
    """
    Estado del agente A/B Testing.
    - rewards_policy_a: Sample de rewards bajo política A
    - rewards_policy_b: Sample de rewards bajo política B
    - rewards_other_policies: Dict de políticas adicionales para múltiples comparaciones
    - test_result: Diccionario con resultados del test de Welch
    - confidence_intervals: Diccionario con IC para diferencia de medias
    - fdr_decisions: Decisión de FDR (Benjamini-Hochberg)
    - llm_analysis: Interpretación lingüística de los resultados
    - decision: Decisión del agente
    """

    rewards_policy_a: Annotated[list[float], replace]
    rewards_policy_b: Annotated[list[float], replace]
    rewards_policy_c: Annotated[list[float], replace]
    rewards_policy_d: Annotated[list[float], replace]
    rewards_other_policies: Annotated[dict[str, list[float]], replace]
    q_value: Annotated[float, replace]
    alpha: Annotated[float, replace]
    test_result: Annotated[dict, replace]
    confidence_intervals: Annotated[dict, replace]
    fdr_decisions: Annotated[dict, replace]
    llm_analysis: Annotated[str, replace]
    decision: Annotated[str, replace]


# ==============================================================================
# LOGGING HELPER
# ==============================================================================
def log(level: str, message: str):
    """Helper para logging con decoración."""
    prefix = {
        "INFO": "===> ",
        "DEBUG": "  - ",
        "WARNING": "!- ",
        "ERROR": "XXX "
    }.get(level, "  ")
    print(f"{prefix}{message}{prefix}")


# ==============================================================================
# INICIALIZACIÓN DEL LLM (OpenRouter)
# ==============================================================================
def get_llm():
    """
    Instanciar LLM vía OpenRouter.
    """
    return ChatOpenAI(
        base_url="https://openrouter.ai/api/v1",
        model="openai/gpt-4o-mini",
        api_key=os.environ.get("OPENROUTER_API_KEY"),
        temperature=0.3,
    )


# ==============================================================================
# NODO 1: Collect Data
# ==============================================================================
def collect_data(state: AgentState) -> AgentState:
    """Simular rewards bajo múltiples políticas.

    Análogo estadístico: Realizar el experimento estadístico X ~ P_θ.
    Cada política tiene un V^π que el agente intenta estimar.

    Distribuciones simuladas:
        rewards_policy_A ~ N(V^π_A, σ²) con V^π_A = 1.0
        rewards_policy_B ~ N(V^π_B, σ²) con V^π_B = 0.5
        rewards_policy_C ~ N(V^π_C, σ²) con V^π_C = 0.3 (alta variabilidad)
        rewards_policy_D ~ N(V^π_D, σ²) con V^π_D = 0.1

    Returns:
        dict: State con rewards_policy_a y rewards_other_policies
    """
    log("INFO", "NODO 1: collect_data - Generando datos de rewards")
    # Sin semilla fija: cada /run produce datos diferentes

    n_samples = 200  # Tamaño muestral del laboratorio

    # Política A: más efectiva (μ = 1.0)
    rewards_policy_a = np.random.normal(loc=1.0, scale=1.5, size=n_samples)
    rewards_policy_a = np.clip(rewards_policy_a, -5, 5)

    # Política B: menos efectiva (μ = 0.5)
    rewards_policy_b = np.random.normal(loc=0.5, scale=1.5, size=n_samples)
    rewards_policy_b = np.clip(rewards_policy_b, -5, 5)

    # Otras políticas para testing de comparaciones múltiples
    rewards_policy_c = np.random.normal(loc=0.3, scale=1.5, size=n_samples)  # Más ruido
    rewards_policy_c = np.clip(rewards_policy_c, -5, 5)

    rewards_policy_d = np.random.normal(loc=0.1, scale=1.5, size=n_samples)  # Muy poco efecto
    rewards_policy_d = np.clip(rewards_policy_d, -5, 5)

    rewards_other_policies = {
        "Politica_B": rewards_policy_b.tolist(),
        "Politica_C": rewards_policy_c.tolist(),
        "Politica_D": rewards_policy_d.tolist(),
    }

    result = {
        "rewards_policy_a": rewards_policy_a.tolist(),
        "rewards_policy_b": rewards_policy_b.tolist(),
        "rewards_policy_c": rewards_policy_c.tolist(),
        "rewards_policy_d": rewards_policy_d.tolist(),
        "rewards_other_policies": rewards_other_policies,
        "q_value": state.get("q_value", 0.10),  # FDR level
        "alpha": state.get("alpha", 0.05),  # Significance level
    }

    log("INFO", f"Generado {len(rewards_policy_a)} rewards para cada política")
    log("DEBUG", f"Media A: {np.mean(rewards_policy_a):.3f}, B: {np.mean(rewards_policy_b):.3f}")
    log("DEBUG", f"Media C: {np.mean(rewards_policy_c):.3f}, D: {np.mean(rewards_policy_d):.3f}")

    return result  # LangGraph mergea con el estado usando los reducers


# ==============================================================================
# NODO 2: Z-Test (Normal Asintótico) — Unilateral Superioridad
# ==============================================================================
# Laboratorio F.4.2: "Por la normalidad asintótica de V^π:"
#   Z = (V^π_B - V^π_A) / σ_diff  →  N(0,1) bajo H0
# H0: μ_B ≤ μ_A   vs   H1: μ_B > μ_A  (superioridad unilateral)
def welch_test(state: AgentState) -> AgentState:
    """Z-test unilateral (asintótico) para comparación de dos políticas.

    H0: V^{π_B} ≤ V^{π_A}  (política B no es mejor que A)
    H1: V^{π_B} > V^{π_A}  (política B es superior)

    Por normalidad asintótica: Z → N(0,1) bajo H0.
    """
    log("INFO", "NODO 2: z_test - Ejecutando Z-test unilateral (superioridad)")

    rewards_a = np.array(state["rewards_policy_a"])
    rewards_b = np.array(state["rewards_policy_b"])

    mean_a = np.mean(rewards_a)
    mean_b = np.mean(rewards_b)
    dif_mean = mean_b - mean_a

    n_a = len(rewards_a)
    n_b = len(rewards_b)

    var_a = np.var(rewards_a, ddof=1)
    var_b = np.var(rewards_b, ddof=1)

    se = np.sqrt(var_a / n_a + var_b / n_b)  # Error estándar de la diferencia

    # Estadístico Z (asintóticamente N(0,1) bajo H0)
    z_stat = dif_mean / se if se > 0 else 0.0

    from scipy import stats

    # P-value unilateral: P(Z > z_obs) = 1 - Φ(z_obs)
    # Bajo H0: μ_B ≤ μ_A, rechazamos si Z es suficientemente grande
    p_value = 1.0 - stats.norm.cdf(z_stat)

    # Cohen's d (tamaño del efecto)
    pooled_sd = np.sqrt(((n_a - 1)*var_a + (n_b - 1)*var_b) / (n_a + n_b - 2))
    cohens_d = dif_mean / pooled_sd if pooled_sd > 0 else 0.0

    # Decisión unilateral: rechazar H0 si Z > z_α
    alpha = 0.05
    z_critical = stats.norm.ppf(1 - alpha)  # z_0.05 = 1.645
    reject_h0 = z_stat > z_critical

    test_result = {
        "z_statistic": z_stat,
        "p_value": p_value,
        "effect_size": cohens_d,
        "reject_h0": reject_h0,
        "mean_a": mean_a,
        "mean_b": mean_b,
        "difference": dif_mean,
        "n_a": n_a,
        "n_b": n_b,
        "se": se,
        "z_critical": z_critical,
        "alpha": alpha,
    }

    log("DEBUG", f"  Z = {z_stat:.4f}, z_crit = {z_critical:.4f}")
    log("DEBUG", f"  p (unilateral) = {p_value:.4f}, rechazado H0: {reject_h0}")
    log("DEBUG", f"  Cohen's d = {cohens_d:.4f}")

    # LangGraph mergea automáticamente: solo devolvemos los campos nuevos
    return {"test_result": test_result}


# ==============================================================================
# NODO 3: Compute Confidence Intervals
# ==============================================================================
def compute_ci(state: AgentState) -> AgentState:
    """Construir IC 95% para la diferencia V^{π_B} - V^{π_A}."""
    log("INFO", "NODO 3: compute_ci - Construindo intervalo de confianza")

    test = state["test_result"]
    rewards_a = np.array(state["rewards_policy_a"])
    rewards_b = np.array(state["rewards_policy_b"])
    mean_a = test["mean_a"]
    mean_b = test["mean_b"]

    n_a = test["n_a"]
    n_b = test["n_b"]

    var_a = np.var(rewards_a, ddof=1)
    var_b = np.var(rewards_b, ddof=1)

    s_a = np.sqrt(var_a / n_a)
    s_b = np.sqrt(var_b / n_b)

    dif_mean = mean_b - mean_a
    se = np.sqrt(s_a**2 + s_b**2)

    from scipy import stats
    z = stats.norm.ppf(1 - 0.025)

    ci_lower = dif_mean - z * se
    ci_upper = dif_mean + z * se

    contains_zero = ci_lower <= 0 <= ci_upper

    confidence_intervals = {
        "ci_95_lower": ci_lower,
        "ci_95_upper": ci_upper,
        "contains_zero": contains_zero,
        "difference": dif_mean,
        "se": se,
        "z": z,
    }

    log("DEBUG", f"  IC [95%] = [{ci_lower:.4f}, {ci_upper:.4f}]")
    log("DEBUG", f"  Contiene cero: {contains_zero}")

    # LangGraph mergea automáticamente: solo devolvemos los campos nuevos
    return {"confidence_intervals": confidence_intervals}


# ==============================================================================
# NODO 4: Benjamini-Hochberg FDR
# ==============================================================================
def benjamini_hochberg(state: AgentState) -> AgentState:
    """Procedimiento Benjamini-Hochberg para comparaciones múltiples.

    Cuando analizamos k=4 políticas, se realizan C(4,2)=6 tests simultáneos.
    El procedimiento BH mantiene el FDR controlado a nivel Q.

    Incluye TODAS las comparaciones entre pares (A, B, C, D).
    """
    log("INFO", "NODO 4: benjamini_hochberg - Ejecutando corrección FDR")

    from scipy import stats

    # Incluir TODAS las políticas: A, B, C, D
    policies = ["Politica_A", "Politica_B", "Politica_C", "Politica_D"]

    # Mapa de nombres a datos
    rewards_map = {
        "Politica_A": np.array(state["rewards_policy_a"]),
        "Politica_B": np.array(state["rewards_policy_b"]),
        "Politica_C": np.array(state["rewards_policy_c"]),
        "Politica_D": np.array(state["rewards_policy_d"]),
    }

    m = len(policies)  # 4

    # Comparaciones múltiples: C(4,2) = 6 pares
    comparisons = []
    for i in range(m):
        for j in range(i + 1, m):
            p1 = rewards_map[policies[i]]
            p2 = rewards_map[policies[j]]

            # Z-test bilateral para cada par
            mean1 = np.mean(p1)
            mean2 = np.mean(p2)
            var1 = np.var(p1, ddof=1)
            var2 = np.var(p2, ddof=1)
            n1 = len(p1)
            n2 = len(p2)

            se = np.sqrt(var1 / n1 + var2 / n2)
            z = (mean2 - mean1) / se if se > 0 else 0.0

            # P-value bilateral para FDR (detectar cualquier diferencia)
            p_value = 2.0 * (1.0 - stats.norm.cdf(abs(z)))

            comparisons.append([policies[i], policies[j], p_value])

    # BH Procedure con control de FDR
    q = state.get("q_value", 0.10)  # Nivel de FDR por defecto 0.10
    comparisons.sort(key=lambda x: x[2])

    rejected = []
    critical_threshold = 0

    m_k = m * (m - 1) / 2  # Total = 6

    for rank, (pol1, pol2, p_val) in enumerate(comparisons, 1):
        critical_value = rank / m_k * q

        if p_val <= critical_value:
            rejected.append([pol1, pol2, p_val, True])
        else:
            critical_threshold = critical_value
            break

    rejected_count = sum(1 for r in rejected if r[3])

    fdr_decisions = {
        "rejected": rejected,
        "rejected_count": rejected_count,
        "q": q,
        "all_pvalues": comparisons,
        "total_comparisons": int(m_k),
    }

    log("INFO", f"rejected {rejected_count}/{len(comparisons)} hypotheses (C({int(m)},2)={int(m_k)} tests)")
    log("INFO", f"FDR level (Q) = {q}")

    # LangGraph mergea automáticamente: solo devolvemos los campos nuevos
    return {"fdr_decisions": fdr_decisions}


# ==============================================================================
# NODO 5: LLM Interpretation
# ==============================================================================
def llm_interpret(state: AgentState) -> AgentState:
    """Consultar LLM para interpretar los resultados estadísticos."""
    log("INFO", "NODO 5: llm_interpret - Generando interpretación LLM")

    test = state.get("test_result", {})
    ci = state.get("confidence_intervals", {})
    fdr = state.get("fdr_decisions", {})

    system_prompt = """
    Eres un análisis de datos estadísticos experto. Tu tarea es interpretar
    los resultados de un test A/B y dar recomendaciones en lenguaje natural.

    Estructura de la respuesta:
    1. Resumen corto del experimento
    2. Interpretación del test de Welch (t, p-value, significancia)
    3. Interpretación del intervalo de confianza (si contiene cero o no)
    4. Discusión del control de FDR (qué comparaciones fueron significativas)
    5. Conclusión clara: ¿Qué hacer? ¿Adoptar B, mantener A, o no hay evidencia?

    Usa tono académico pero accesible.
    """

    user_prompt = f"""
    RESULTADOS A/B TESTING

    Test de Welch:
    - Estadístico t: {test.get('t_statistic', 0):.4f}
    - P-value: {test.get('p_value', 0):.4f}
    - Tamaño de efecto Cohen's d: {test.get('effect_size', 0):.4f}
    - Rechazo H0 (α=0.05): {'SÍ' if test.get('reject_h0', False) else 'NO'}

    Intervalo de Confianza 95%:
    - Límite inferior: {ci.get('ci_95_lower', 0):.4f}
    - Límite superior: {ci.get('ci_95_upper', 0):.4f}
    - Contiene cero: {'SÍ' if ci.get('contains_zero', True) else 'NO'}

    Control FDR (BH, q=0.10):
    - Comparaciones evaluadas: {len(fdr.get('all_pvalues', []))}
    - Rechazadas: {fdr.get('rejected_count', 0)}/{len(fdr.get('all_pvalues', []))}

    Por favor, interpreta estos resultados y da una recomendación clara.
    """

    llm_analysis = "No disponible sin API key de LLM"

    try:
        llm = get_llm()
        response = llm.invoke([
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ])
        llm_analysis = response.content
    except Exception as e:
        log("INFO", f"LLM falló: {e}. Usando fallback.")

    # LangGraph mergea automáticamente: solo devolvemos los campos nuevos
    return {"llm_analysis": llm_analysis}


# ==============================================================================
# NODO 6: Decision
# ==============================================================================
def decide(state: AgentState) -> AgentState:
    """Decisión basada en la dualidad test-IC (Teorema de Inversión).

    Dualidad: Rechazar H0 al nivel α  ⟺  0 ∉ IC al nivel 1-α.
    - Si Z > z_α  Y  el IC no contiene 0 → ADOPTAR_B
    - Si no hay evidencia → NO_HAY_EVIDENCIA
    """
    log("INFO", "NODO 6: decide - Generando decision final (dualidad test-IC)")

    test = state["test_result"]
    ci = state.get("confidence_intervals", {})
    fdr = state.get("fdr_decisions", {})

    # Dualidad: test unilateral + IC 95%
    reject_by_test = test.get("reject_h0", False)
    contains_zero = ci.get("contains_zero", True)
    diff = test.get("difference", 0.0)

    # Coherencia: rechazar H0 ⟺ 0 ∉ IC
    if reject_by_test and not contains_zero and diff > 0:
        decision = "ADOPTAR_B"
    elif reject_by_test and not contains_zero and diff < 0:
        decision = "MANTENER_A"
    else:
        decision = "NO_HAY_EVIDENCIA"

    log("INFO", f"Decision: {decision}")
    log("DEBUG", f"  test.reject_H0={reject_by_test}, IC.contains_zero={contains_zero}")

    # LangGraph mergea automáticamente: solo devolvemos los campos nuevos
    return {"decision": decision}


# ==============================================================================
# CONSTRUCCIÓN DEL GRAFO
# ==============================================================================
def build_graph() -> CompiledStateGraph:
    """Construir el grafo LangGraph del agente A/B Testing."""
    log("INFO", "--- COMENZANDO CONSTRUCCIÓN DEL GRAFO LANGGRAPH ---")

    graph = StateGraph(AgentState)

    # Agregar nodos
    graph.add_node("collect_data", collect_data)
    graph.add_node("welch_test", welch_test)
    graph.add_node("compute_ci", compute_ci)
    graph.add_node("benjamini_hochberg", benjamini_hochberg)
    graph.add_node("llm_interpret", llm_interpret)
    graph.add_node("decide", decide)

    # Definir flujo (edges)
    graph.set_entry_point("collect_data")
    graph.add_edge("collect_data", "welch_test")
    graph.add_edge("welch_test", "compute_ci")
    graph.add_edge("compute_ci", "benjamini_hochberg")
    graph.add_edge("benjamini_hochberg", "llm_interpret")
    graph.add_edge("llm_interpret", "decide")
    graph.add_edge("decide", END)

    # Compilar grafo
    compiled_graph = graph.compile()

    log("INFO", "Grafo construido exitosamente")
    log("INFO", "  START -> collect_data -> z_test -> compute_ci")
    log("INFO", "  benjamini_hochberg -> llm_interpret -> decide -> END")

    return compiled_graph


# ==============================================================================
# EJECUCIÓN DIRECTA (MODO TEST)
# ==============================================================================
if __name__ == "__main__":
    # Ejecución secuencial (modo debugging)
    print("=" * 60)
    print("--- RESULTADO: A/B Testing de Políticas con FDR ---")
    print("=" * 60)
    print("\n--- EJECUCIÓN SECUENCIAL (Nodes 1-6) ---")
    print("=" * 60)

    graph = build_graph()
    state = graph.invoke({"alpha": 0.05, "q_value": 0.10})

    # RESULTADOS
    print("\n" + "=" * 60)
    print("RESULTADO FINAL")
    print("=" * 60)

    print(f"\nZ-Test Unilateral α={state.get('alpha', 0.05)}:")
    print(f"  Z = {state['test_result']['z_statistic']:.4f}")
    print(f"  Z crítico = {state['test_result']['z_critical']:.4f}")
    print(f"  p (unilateral) = {state['test_result']['p_value']:.4f}")
    print(f"  Cohen's d = {state['test_result']['effect_size']:.4f}")
    print(f"  Rechazar H0: {state['test_result']['reject_h0']}")

    print(f"\nIC 95%: [{state['confidence_intervals']['ci_95_lower']:.4f}, "
          f"{state['confidence_intervals']['ci_95_upper']:.4f}]")
    print(f"Contiene cero: {state['confidence_intervals']['contains_zero']}")

    print(f"\nFDR (BH, q={state.get('q_value', 0.10)}): {state['fdr_decisions']['rejected_count']}/"
          f"{state['fdr_decisions']['total_comparisons']}")
    print("Tabla decisiones FDR:")
    for i, (pol1, pol2, p_val, is_rej) in enumerate(state['fdr_decisions']['rejected'], 1):
        print(f"  {i}. {pol1} vs {pol2}: p={p_val:.4f} - {'RECHAZADO' if is_rej else 'No rech.'}")

    print(f"\nDecisión: {state.get('decision', 'N/A')}")
    print(f"\nAnálisis LLM: {state.get('llm_analysis', 'N/A')[:200]}...")
