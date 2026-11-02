from typing import TypedDict

class DREstimatorState(TypedDict):
    """
    Capítulo 6: Estado AIPW Doubly Robust para OPE
    Referencias: Bickel et al. (1993), Kennedy (2016), Kallus & Uehara (2020)
    """
    data: list[dict]
    q_estimate: dict
    dm_estimate: float
    is_estimate: float
    dr_estimate: float
    influence_scores: list[float]
    ci: dict
    robustness_check: dict
    llm_analysis: str
