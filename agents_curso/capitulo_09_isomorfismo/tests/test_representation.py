"""Tests de la representación fiel al teorema (D9): construcción sobre X,
identidad exacta J=-R integrando sobre la observación, y verificación no
tautológica."""
import numpy as np
import pytest

from isomorphism_agent import WaldProblem, verify_isomorphism
from isomorphism_agent.representation import (
    ObservationModel,
    mdp_family,
    mdp_for_theta,
    return_statistical,
    risk_statistical,
    rules,
    verify_representation,
)


@pytest.fixture
def problem():
    return WaldProblem(cost_treat=0.2, cost_skip=1.0)


class TestConstruction:
    def test_states_are_observations_not_parameters(self, problem):
        obs = ObservationModel()
        mdp = mdp_for_theta(problem, 0.3, obs)
        assert set(mdp.S) == {0, 1, "TERMINAL"}
        assert not any(isinstance(s, float) and 0 != s != 1 for s in mdp.S)

    def test_initial_law_is_P_theta_and_sums_to_one(self, problem):
        obs = ObservationModel()
        mdp = mdp_for_theta(problem, 0.3, obs)
        assert np.isclose(mdp.initial_dist.sum(), 1.0)
        np.testing.assert_allclose(mdp.initial_dist, [0.7, 0.3])

    def test_reward_is_minus_loss_and_terminal_absorbing(self, problem):
        obs = ObservationModel()
        mdp = mdp_for_theta(problem, 0.3, obs)
        for j, a in enumerate(mdp.A):
            for i in range(len(mdp.S) - 1):
                np.testing.assert_allclose(mdp.r[i, j], -problem.loss(0.3, a))
        # terminal absorbente con recompensa nula
        for j in range(len(mdp.A)):
            np.testing.assert_allclose(mdp.P[-1, j, -1], 1.0)


class TestIdentity:
    def test_identity_is_exact_for_every_rule_and_theta(self, problem):
        obs = ObservationModel()
        thetas = np.array([0.0, 0.25, 0.5, 0.74, 1.0])
        for th in thetas:
            for rule in rules(obs, list(problem.action_space)):
                j = return_statistical(problem, obs, th, rule)
                r = risk_statistical(problem, obs, th, rule)
                np.testing.assert_allclose(j, -r, atol=1e-12)

    def test_bijection_counts_and_information(self, problem):
        obs = ObservationModel()
        rs = rules(obs, list(problem.action_space))
        assert len(rs) == 2 ** len(obs.x_space)

    def test_verify_representation_ok(self, problem):
        out = verify_representation(problem)
        assert out["ok"] and out["identity_max_abs_error"] <= 1e-9
        assert "theta indexes the family" in out["policy_observes"]

    def test_family_is_indexed_by_theta(self, problem):
        obs = ObservationModel()
        fam = mdp_family(problem, obs, np.array([0.2, 0.8]))
        assert set(fam) == {0.2, 0.8}


class TestCompatibilityVerify:
    def test_verify_isomorphism_reports_real_identity(self, problem):
        result = verify_isomorphism(problem, alpha=10, beta=10)
        assert result["identity_holds"] and result["isomorphism_ok"]
        assert result["identity_max_abs_error"] <= 1e-9
        np.testing.assert_allclose(result["V_at_state"],
                                   result["neg_risk_at_state"], atol=1e-12)
        assert "no el teorema" in result["note"] or "coincidencia" in result["note"]
