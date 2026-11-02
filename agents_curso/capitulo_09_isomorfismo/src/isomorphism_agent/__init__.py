"""
Isomorphism Agent — v2
======================
Agente estadístico que operacionaliza el isomorfismo Wald-MDP
del Capítulo 9 (Cap.~\ref{ch:isomorfismo}) con:

* Nodos LangGraph: observation → state → inference → decision
  → isomorphism → transfer → test → verify → END
* Funtor F con estado terminal (corrige bug de v1).
* Trazabilidad estructurada (tabla Teorema→Componente→Garantía).
* Protocolo de verificación Prop.~9.14 antes de invocar garantías.
* Bootstrap secuencial con corrección por mixing (Liao 2021).
* OPE con clipping adaptativo (Su et al. 2020).

Referencias: Wald (1950), Bellman (1957), Puterman (2005),
Berger (1985), Athey & Wager (2021), Su et al. (2020),
Liao et al. (2021), Chernozhukov et al. (2018).
"""
from .agent import build_agent, run_agent
from .bootstrap import block_bootstrap_v
from .functor import F, F_inv, verify_isomorphism
from .mdp import MDP, optimal_policy, policy_evaluation, value_iteration
from .ope import (
    CrossFittedDoublyRobust,
    DirectMethod,
    DoublyRobust,
    ImportanceSampling,
    OPEResult,
)
from .state import AgentState, MDPState, WaldState
from .trace import TraceEntry, TraceLog
from .transfer import ic_transfer_delta, test_transfer_ump
from .verify import VerificationResult, verify_guarantee
from .wald import (
    BernoulliDistribution,
    Distribution,
    WaldProblem,
    bayes_rule,
    minimax_rule,
    posterior_ic,
    wald_test,
)

__all__ = [
    "WaldState", "MDPState", "AgentState",
    "WaldProblem", "Distribution", "BernoulliDistribution",
    "bayes_rule", "minimax_rule", "posterior_ic", "wald_test",
    "MDP", "value_iteration", "optimal_policy", "policy_evaluation",
    "F", "F_inv", "verify_isomorphism",
    "ic_transfer_delta", "test_transfer_ump",
    "DirectMethod", "ImportanceSampling", "DoublyRobust", "CrossFittedDoublyRobust", "OPEResult",
    "verify_guarantee", "VerificationResult",
    "block_bootstrap_v",
    "TraceLog", "TraceEntry",
    "build_agent", "run_agent",
]

__version__ = "2.1.0"
