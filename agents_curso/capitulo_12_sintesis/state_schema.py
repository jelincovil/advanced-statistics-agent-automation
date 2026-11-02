"""
state_schema.py - Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre
==========================================================================================

Define el esquema de estado para el agente capstone que integra inferencia
estadística con guía de LLM para la toma de decisiones bajo incertidumbre.

El agente opera en tres modos:
    - EXPLORE: Recolectar más datos para reducir incertidumbre epistémica
    - CONSULT: Consultar al LLM para orientación estratégica
    - ACT: Ejecutar la mejor acción conocida

Referencias:
    - Shi et al. (2024) JASA: "Uncertainty-Aware Decision Making"
    - Yao et al. (2023) ICLR ReAct: "Reasoning and Acting"
    - Shinn et al. (2023) NeurIPS Reflexion: "Language Agents"
    - Zhai et al. (2025) AAAI: "Q-values for LLM Agents"
"""

from typing import TypedDict, List, Dict, Any


class SynthesisState(TypedDict):
    """
    Estado del agente Capstone de Síntesis.

    Este TypedDict define la estructura completa del estado para el agente
    end-to-end que integra:
    - Inferencia estadística (ICs para V^π)
    - Consulta a LLM (via OpenRouter)
    - Toma de decisiones guiada por incertidumbre
    - Estudio de ablation (solo estadística / solo LLM / combinado)

    Atributos:
        current_beliefs: Posterior sobre parámetros de interés.
            Incluye media, varianza, y datos observados.
        data_collected: Lista de observaciones {(s, a, r)} recolectadas.
        v_estimate: Estimación de V^π con IC:
            {mean, se, ci_lower, ci_upper}.
        uncertainty_width: Ancho del intervalo de confianza.
        exploration_budget: Número máximo de pasos de exploración.
        action_history: Historial de acciones del agente:
            ["explore", "consult_llm", "act", ...]
        consultation_results: Lista de respuestas del LLM:
            [{prompt, response, recommendation}, ...]
        performance_history: Recompensa acumulada en cada paso.
        current_mode: Modo actual del agente: "explore" | "consult" | "act".
        meta_criterion: Umbrales para cambio de modo:
            {threshold_explore, threshold_consult}.
        llm_analysis: Análisis consolidado del LLM.
        final_report: Reporte final con resultados de ablation.
        iteration: Número de iteración actual.
        ablation_results: Resultados del estudio de ablation:
            {statistics_only, llm_only, combined}.
        stopping_reason: Razón de detención del agente.
        n_explore_steps: Contador de pasos de exploración.
        n_consult_steps: Contador de consultas al LLM.
        n_act_steps: Contador de pasos de actuación.
    """

    # Creencias y datos
    current_beliefs: Dict[str, Any]
    data_collected: List[Dict[str, Any]]

    # Estimación de V^π
    v_estimate: Dict[str, float]
    uncertainty_width: float

    # Presupuesto de exploración
    exploration_budget: int

    # Historiales
    action_history: List[str]
    consultation_results: List[Dict[str, Any]]
    performance_history: List[float]

    # Control del agente
    current_mode: str
    meta_criterion: Dict[str, float]

    # Análisis
    llm_analysis: str
    final_report: Dict[str, Any]

    # Iteración
    iteration: int

    # Ablation
    ablation_results: Dict[str, Any]

    # Parámetros de control
    stopping_reason: str
    n_explore_steps: int
    n_consult_steps: int
    n_act_steps: int
