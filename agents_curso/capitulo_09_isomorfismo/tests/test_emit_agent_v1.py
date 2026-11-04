"""Tests de la emisión instrumentada del agente v1 (Fase 1).

Criterio: la semántica del flujo se conserva (argmax de código), el registro
es por diseño (ε-greedy, propensión válida y completa) y la aceptación es
validate_episode sin issues con los tests previos (47) intactos.
"""
import pytest

pytest.importorskip("agente_stats", reason="paquete agente-stats no en PYTHONPATH")

from isomorphism_agent import emit_agent_v1
from agente_stats import load_jsonl, validate_episode
from agente_stats.golden_episodes import write_jsonl


PARAMS = dict(n_episodes=200, data_draws=10, epsilon=0.3, seed=20261103)


class TestEmission:
    def test_validates_against_contract(self):
        eps = emit_agent_v1(**PARAMS)
        for e in eps:
            assert validate_episode(e) == []

    def test_star_action_gets_higher_probability(self):
        eps = emit_agent_v1(**PARAMS)
        for e in eps:
            ctx = e["steps"][0]["context"]["features"]
            mean = ctx["alpha"] / (ctx["alpha"] + ctx["beta"])
            expected_star = 1 if mean > (0.2 / 1.2) else 0
            assert e["steps"][0]["action_probs"][str(expected_star)] == 0.85, \
                f"ε-greedy debió asignar 0.85 a δ*; media posterior={mean}, s={ctx['s']}"

    def test_behavior_action_probs_are_valid(self):
        eps = emit_agent_v1(**PARAMS)
        for e in eps:
            p = e["steps"][0]["action_probs"]
            assert abs(sum(p.values()) - 1.0) < 1e-9
            assert all(v > 0 for v in p.values())

    def test_propensity_bounded_by_design(self):
        eps = emit_agent_v1(**PARAMS)
        for e in eps:
            for st in e["steps"]:
                assert st["propensity"] in (0.15, 0.85)

    def test_deterministic_given_seed(self):
        assert emit_agent_v1(**PARAMS) == emit_agent_v1(**PARAMS)

    def test_metadata_carries_governance(self):
        eps = emit_agent_v1(**PARAMS)
        e0 = eps[0]["meta"]
        assert e0["decided_by"].startswith("code:")
        assert "epsilon" in e0 and "c_max" in e0 and "seed" in e0
        assert e0["exploration_rate"] == pytest.approx(0.15)
        assert e0["c_max"] == pytest.approx(1 + 2 * (1 - 0.3) / 0.3)

    def test_write_and_reload_validates(self, tmp_path):
        eps = emit_agent_v1(n_episodes=8, seed=20261103)
        p = write_jsonl(eps, tmp_path / "v1.jsonl")
        assert len(load_jsonl(p)) == 8
