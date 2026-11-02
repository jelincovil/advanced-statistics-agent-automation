"""
Capítulo 4: Tests de Hipótesis e Intervalos de Confianza en Agentes
=================================================================
Estado del Agente A/B Testing de Políticas con FDR

Conexión teórica (Silabo Semana 4):
- H₀: V^{π_A} = V^{π_B}  vs  H₁: V^{π_A} ≠ V^{π_B}
- Test de Welch (dos muestras, varianzas posiblemente diferentes)
- Dualidad test-IC: Rechazamos H₀ ⟺ 0 ∉ IC
- Procedimiento Benjamini-Hochberg para k > 2 políticas

Referencias:
- Lehmann & Romano (2005), Ch.3-5 - Two-sample problems
- Shi et al. (2022), §5 - Hypothesis testing for value functions
- Thomas et al. (2015) - High confidence off-policy evaluation
"""

from typing import TypedDict


class PolicyComparisonState(TypedDict):
    """
    Estado para comparación estadística de políticas con garantías formales.
    
    Análogo estadístico:
    - rewards_policy_* = muestras X ~ P_θ bajo cada política
    - test_result = estadístico del test φ(X) 
    - confidence_intervals = inversión del test (Teorema de inversión)
    - fdr_decisions = control de tasa de falsos descubrimientos (Teo. BH)
    """
    # Datos observados
    rewards_policy_a: list[float]    # Retornos bajo política A
    rewards_policy_b: list[float]    # Retornos bajo política B
    rewards_other_policies: dict     # {nombre: [rewards]} para k > 2
    
    # Resultados de inferencia
    test_result: dict               # {t_statistic, p_value, reject_h0, effect_size}
    confidence_intervals: dict       # {difference, ci_lower, ci_upper, contains_zero}
    fdr_decisions: dict             # {comparisons, adjusted_pvals, rejected, q_value}
    
    # Decisión final
    decision: str                   # "ADOPTAR_A", "ADOPTAR_B", "NO_EVIDENCIA"
    
    # Análisis LLM
    llm_analysis: str               # Interpretación del modelo de lenguaje
