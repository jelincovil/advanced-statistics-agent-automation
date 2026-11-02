"""
state_schema.py - Capítulo 11: Inferencia Secuencial para Funciones de Valor (SAVE)
====================================================================================

Define el esquema de estado para el agente LangGraph de inferencia asintótica
para funciones de valor V^π con dependencia temporal.

El estado contiene las trayectorias generadas, la estimación puntual de V^π,
los intervalos de confianza (asintótico y bootstrap), diagnósticos de mezcla,
análisis de potencia, y el análisis del LLM.

Referencias:
    - Shi et al. (2022) JRSSB: "Sequential Inference for Value Functions"
    - Kallus & Uehara (2020/2022): "Double/Debiased Machine Learning for Offline RL"
"""

from typing import TypedDict, List, Dict, Any


class SAVEState(TypedDict):
    """
    Estado del agente de Inferencia Asintótica para V^π (SAVE).

    Este TypedDict define la estructura completa del estado para el pipeline
    de SAVE que incluye estimación puntual, inferencia asintótica vía TCL
    para cadenas de Markov, bootstrap por bloques, diagnósticos de mezcla,
    y análisis de potencia.

    Atributos:
        trajectories: Lista de trayectorias. Cada trayectoria es una lista
            de diccionarios con claves: 'state', 'action', 'reward', 'next_state'.
        v_hat: Estimación puntual del valor V^π.
        se_estimate: Error estándar estimado (cuenta por dependencia temporal).
        asymptotic_ci: Intervalo de confianza asintótico basado en TCL:
            {'lower': float, 'upper': float, 'level': float}.
        bootstrap_ci: Intervalo de confianza vía block bootstrap:
            {'lower': float, 'upper': float, 'level': float, 'n_bootstrap': int}.
        mixing_diagnostics: Diagnósticos de ergodicidad geométrica:
            {'is_mixed': bool, 'autocorrelation': list, 'effective_sample_size': float}.
        temporal_dependence: Medidas de dependencia temporal:
            {'spectral_variance': float, 'integrated_autocorrelation': float}.
        power_analysis: Resultados del análisis de potencia:
            {'delta': float, 'alpha': float, 'power': float, 'n_required': int}.
        n_min_for_delta: Tamaño muestral mínimo para detectar δ con potencia 1-β.
        n_trajectories: Número de trayectorias generadas.
        trajectory_length: Longitud de cada trayectoria.
        gamma: Factor de descuento utilizado.
        true_value: Valor verdadero de V^π (para simulación/comparación).
        llm_analysis: Análisis interpretativo generado por el LLM.
        report: Reporte final consolidado.
        batch_sizes: Lista de tamaños de lote para batch means.
        batch_se_estimates: Estimaciones de SE por batch means.
        bootstrap_samples: Muestras de bootstrap para histograma.
    """

    # Datos de entrada
    trajectories: List[List[Dict[str, Any]]]

    # Estimaciones puntuales
    v_hat: float
    se_estimate: float

    # Intervalos de confianza
    asymptotic_ci: Dict[str, float]
    bootstrap_ci: Dict[str, Any]

    # Diagnósticos
    mixing_diagnostics: Dict[str, Any]
    temporal_dependence: Dict[str, Any]

    # Análisis de potencia
    power_analysis: Dict[str, Any]
    n_min_for_delta: int

    # Parámetros de la simulación
    n_trajectories: int
    trajectory_length: int
    gamma: float
    true_value: float

    # Internos
    batch_sizes: List[int]
    batch_se_estimates: List[float]
    bootstrap_samples: List[float]

    # Análisis del LLM
    llm_analysis: str

    # Reporte final
    report: Dict[str, Any]


def add_messages(left: List, right: List) -> List:
    """Combina dos listas de mensajes."""
    if left is None:
        left = []
    if right is None:
        right = []
    return left + right
