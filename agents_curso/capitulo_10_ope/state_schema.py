"""
state_schema.py - Capítulo 10: Off-Policy Evaluation (OPE) Fundamentos
=========================================================================

Define el esquema de estado para el agente LangGraph de evaluación off-policy.

El estado contiene los datos de la política de comportamiento, la política objetivo,
las estimaciones de los tres estimadores (DM, IS, DR), diagnósticos de overlap,
comparaciones de sesgo-varianza, y el análisis del LLM.

Referencias:
    - Jiang & Li (2016): "Doubly Robust Off-Policy Value Evaluation for Reinforcement Learning"
    - Dudík et al. (2011): "Optimally Solving MDPs with Continuous Actions"
    - Thomas et al. (2015): "High Confidence Policy Improvement"
"""

from typing import TypedDict, List, Dict, Any
from typing_extensions import Annotated


class OPEState(TypedDict):
    """
    Estado del agente de Evaluación Off-Policy (OPE).

    Este TypedDict define la estructura completa del estado para el pipeline
    de OPE que incluye los estimadores Direct Method (DM), Importance Sampling (IS)
    y Doubly Robust (DR), junto con diagnósticos de solapamiento (overlap) y
    comparaciones de sesgo-varianza.

    Atributos:
        behavior_policy_data: Lista de transiciones recolectadas bajo la política
            de comportamiento π_b. Cada transición es un diccionario con las claves:
            'state', 'action', 'reward', 'next_state', 'pi_b' (probabilidad bajo π_b).
        target_policy: Política de evaluación π_e(a|s). Diccionario que mapea
            (estado, acción) → probabilidad.
        dm_estimate: Estimación puntual del valor usando el Método Directo.
        dm_se: Error estándar de la estimación DM.
        is_estimate: Estimación puntual del valor usando Importance Sampling.
        is_se: Error estándar de la estimación IS.
        dr_estimate: Estimación puntual del valor usando el estimador Doubly Robust.
        dr_se: Error estándar de la estimación DR.
        overlap_diagnostics: Diagnósticos de la condición de solapamiento:
            min_ratio, max_ratio, mean_ratio, states_violating_overlap.
        variance_comparison: Comparación de varianzas entre los tres estimadores.
        bias_comparison: Comparación de sesgos entre los tres estimadores.
        llm_analysis: Análisis interpretativo generado por el LLM sobre los
            resultados de OPE y las implicaciones metodológicas.
        true_value: Valor verdadero de V^π_e (para simulación/comparación).
        n_samples: Número de muestras utilizadas.
        sensitivity_results: Resultados del análisis de sensibilidad al overlap.
        confidence_level: Nivel de confianza para los intervalos (por defecto 0.95).
        report: Reporte final consolidado.
    """

    # Datos de entrada
    behavior_policy_data: List[Dict[str, Any]]
    target_policy: Dict[str, float]

    # Estimaciones puntuales
    dm_estimate: float
    dm_se: float
    is_estimate: float
    is_se: float
    dr_estimate: float
    dr_se: float

    # Diagnósticos
    overlap_diagnostics: Dict[str, Any]
    variance_comparison: Dict[str, Any]
    bias_comparison: Dict[str, Any]
    sensitivity_results: Dict[str, Any]

    # Parámetros de la simulación
    true_value: float
    n_samples: int
    confidence_level: float

    # Análisis del LLM
    llm_analysis: str

    # Reporte final
    report: Dict[str, Any]


# Funciones auxiliares para anotaciones de estado
def add_messages(left: List, right: List) -> List:
    """Combina dos listas (para manejo de mensajes en el estado)."""
    if left is None:
        left = []
    if right is None:
        right = []
    return left + right


def merge_dicts(left: Dict, right: Dict) -> Dict:
    """Fusiona dos diccionarios (el derecho sobreescribe al izquierdo)."""
    if left is None:
        left = {}
    if right is None:
        right = {}
    result = left.copy()
    result.update(right)
    return result
