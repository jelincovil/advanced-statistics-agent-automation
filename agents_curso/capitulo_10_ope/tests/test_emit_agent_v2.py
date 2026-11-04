"""Tests de la emisión instrumentada del agente v2 (Fase 1)."""
import pytest

pytest.importorskip("agente_stats", reason="paquete agente-stats no en PYTHONPATH")
pytest.importorskip("numpy", reason="numpy requerido")

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from agente_stats import load_jsonl, validate_episode
from agente_stats.golden_episodes import write_jsonl
from instrument import emit_agent_v2


PARAMS = dict(n_episodes=40, horizon=5, epsilon=0.3, seed=20261104)


class TestEmission:
    def test_validates_against_contract(self):
        eps = emit_agent_v2(**PARAMS)
        for e in eps:
            assert validate_episode(e) == []

    def test_steps_have_expected_coherence(self):
        eps = emit_agent_v2(**PARAMS)
        for e in eps:
            assert len(e["steps"]) == PARAMS["horizon"]
            for t, st in enumerate(e["steps"]):
                assert st["t"] == t
                assert abs(sum(st["action_probs"].values()) - 1.0) < 1e-9
                assert st["propensity"] in (0.15, 0.85)

    def test_star_matches_argmax_of_q_approx_canonical(self):
        import numpy as np
        from instrument import Q_APPROX
        eps = emit_agent_v2(**PARAMS)
        for e in eps:
            for st in e["steps"]:
                s = int(st["context"]["features"]["s"])
                star = int(np.argmax(Q_APPROX[s]))
                assert st["action_probs"][str(star)] == 0.85

    def test_deterministic_given_seed(self):
        assert emit_agent_v2(**PARAMS) == emit_agent_v2(**PARAMS)

    def test_write_and_reload_validates(self, tmp_path):
        eps = emit_agent_v2(n_episodes=6, seed=20261104)
        p = write_jsonl(eps, tmp_path / "v2.jsonl")
        assert len(load_jsonl(p)) == 6
