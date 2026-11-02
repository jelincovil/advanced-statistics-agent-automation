"""Tests del agente LangGraph end-to-end."""
import numpy as np
import pytest

from isomorphism_agent import run_agent, build_agent


class TestAgentEnd2End:
    def setup_method(self):
        np.random.seed(42)

    def test_agent_runs_and_returns_all_fields(self):
        data = np.random.binomial(1, 0.4, size=100)
        result = run_agent(data)
        for key in ["theta_hat", "ic_theta", "bayes_action", "mdp_action",
                    "isomorphism_ok", "ic_V", "test_stat", "p_value",
                    "test_decision"]:
            assert key in result, f"Falta campo {key}"

    def test_isomorphism_holds_in_typical_case(self):
        """Caso típico: δ^* y π^* coinciden."""
        data = np.random.binomial(1, 0.5, size=200)
        result = run_agent(data)
        assert result["isomorphism_ok"] is True

    def test_agent_handles_low_prevalence(self):
        """Prevalencia baja: la acción óptima es no tratar."""
        data = np.random.binomial(1, 0.05, size=200)
        result = run_agent(data)
        assert result["bayes_action"] == 0
        assert result["mdp_action"] == 0
        assert result["isomorphism_ok"] is True

    def test_agent_handles_high_prevalence(self):
        """Prevalencia alta: la acción óptima es tratar."""
        data = np.random.binomial(1, 0.8, size=200)
        result = run_agent(data)
        assert result["bayes_action"] == 1
        assert result["mdp_action"] == 1
        assert result["isomorphism_ok"] is True

    def test_ic_theta_has_correct_coverage_structure(self):
        """IC 95% para θ contiene θ̂."""
        data = np.random.binomial(1, 0.3, size=300)
        result = run_agent(data)
        lo, hi = result["ic_theta"]
        assert lo < result["theta_hat"] < hi

    def test_test_decision_matches_bayes_action(self):
        """Test UMP y regla de Bayes coinciden (Teorema 9.8)."""
        data = np.random.binomial(1, 0.5, size=200)
        result = run_agent(data)
        if result["bayes_action"] == 1:
            assert result["test_decision"] == "tratar"
        else:
            assert result["test_decision"] == "no tratar"

    def test_trace_is_populated(self):
        """El agente deja traza para auditoría (v2: trace_log)."""
        data = np.random.binomial(1, 0.5, size=100)
        result = run_agent(data)
        # v2: trace_log es un TraceLog object
        log = result.get("trace_log")
        if log is not None:
            assert len(log.entries) >= 1
        else:
            # v1 fallback: trace como lista
            assert len(result.get("trace", [])) >= 1
