"""
State — implementación del estadístico suficiente (Teorema 9.10).

En el isomorfismo Wald-MDP, el StateSchema es la contrapartida operativa
del estadístico suficiente minimal $T(X)$: contiene exactamente la
información necesaria para que el nodo de decisión compute la acción
óptima, ni más (ineficiente) ni menos (viola Markov).
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Optional, Sequence

import numpy as np

try:
    from typing_extensions import TypedDict
except ImportError:  # pragma: no cover
    from typing import TypedDict


# ---------------------------------------------------------------------------
# Estado de Wald: cuádrupla (Θ, A, X, L) + estimadores
# ---------------------------------------------------------------------------
@dataclass
class WaldState:
    """Estado del lado Wald.

    Atributos:
        theta_hat: estimador puntual de θ.
        var_theta: varianza asintótica de θ̂ (n^{-1} σ²).
        alpha, beta: hiperparámetros del prior conjugado (familia exponencial).
        n: tamaño muestral acumulado.
        sum_x: Σ x_i  (estadístico suficiente para Bernoulli / Poisson).
        sum_x2: Σ x_i² (estadístico suficiente para Normal).
        loss_args: parámetros de la función de pérdida L(θ, a).
        posterior_sample: muestra del posterior (opcional, para Bayes robusto).
    """
    theta_hat: float = 0.0
    var_theta: float = 0.0
    alpha: float = 1.0
    beta: float = 1.0
    n: int = 0
    sum_x: float = 0.0
    sum_x2: float = 0.0
    loss_args: dict = field(default_factory=lambda: {"cost_treat": 0.2})
    posterior_sample: Optional[np.ndarray] = None


# ---------------------------------------------------------------------------
# Estado del MDP: quíntupla (S, A, P, r, γ) + política
# ---------------------------------------------------------------------------
@dataclass
class MDPState:
    """Estado del lado MDP bajo el funtor F.

    Por el Teorema 9.1, con γ=1 y P determinista un paso, todo problema de
    Wald se mapea biunívocamente a un MDP. Guardamos aquí el MDP resultante
    y la política óptima calculada.
    """
    S: list = field(default_factory=list)         # espacio de estados
    A: list = field(default_factory=list)         # espacio de acciones
    P: Optional[np.ndarray] = None                # kernel [S,A,S]
    r: Optional[np.ndarray] = None                # rewards [S,A]
    gamma: float = 1.0
    V: Optional[np.ndarray] = None                # value function [S]
    pi: Optional[np.ndarray] = None               # optimal policy [S]


# ---------------------------------------------------------------------------
# Estado del agente LangGraph
# ---------------------------------------------------------------------------
class AgentState(TypedDict, total=False):
    """Esquema compartido por todos los nodos del grafo LangGraph.

    Este TypedDict es el *canal de comunicación* entre nodos y
    materializa la trazabilidad: cada nodo lee campos y escribe
    campos, de modo que la ejecución entera es auditable.
    """
    # Datos de entrada
    data: np.ndarray
    prior: dict
    loss_args: dict
    actions: list

    # Salidas intermedias
    wald: WaldState
    mdp: MDPState

    # Resultados
    theta_hat: float
    ic_theta: tuple
    ic_V: tuple
    bayes_action: int
    mdp_action: int
    isomorphism_ok: bool
    test_stat: float
    p_value: float
    test_decision: str

    # Trazabilidad y verificación (v2)
    trace: list
    trace_log: Any           # TraceLog object (propagado entre nodos)
    verification: dict       # VerificationResult.as_dict()
    transferable: bool
    fallback: str

    # Datos de verificación avanzada (Prop. 9.14)
    trajectories: list       # Lista de arrays, cada array = rewards de un episodio
    log_rho: np.ndarray      # Log importance ratios
