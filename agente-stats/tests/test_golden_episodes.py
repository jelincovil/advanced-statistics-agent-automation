"""Tests del generador dorado: determinismo, contrato y constantes de diseño."""
import math

from agente_stats import load_jsonl, validate_episode
from agente_stats.golden_episodes import (
    SEED_V1, V1_THRESHOLD, gen_agent_v1, gen_agent_v2, v2_greedy_policy,
)


def check(episodes):
    for e in episodes:
        assert validate_episode(e) == []


def test_v1_validates_and_design_numbers():
    eps = gen_agent_v1(n_episodes=8, seed=SEED_V1)
    check(eps)
    for e in eps:
        meta = e["meta"]
        assert math.isclose(meta["c_max"], 1 + 2 * (1 - 0.3) / 0.3, rel_tol=1e-9)
        assert e["propensity_mode"] == "recorded"
        p = e["steps"][0]
        assert p["propensity"] in (0.15, 0.85)
        assert abs(sum(p["action_probs"].values()) - 1.0) < 1e-9
        assert meta["exploration_rate"] == 0.15


def test_v1_argmax_matches_threshold():
    eps = gen_agent_v1(n_episodes=200, seed=SEED_V1)
    highs = sum(1 for e in eps if e["steps"][0]["action_probs"]["1"] == 0.85)
    lows = sum(1 for e in eps if e["steps"][0]["action_probs"]["1"] == 0.15)
    both = sum(1 for e in eps if len(e["steps"][0]["action_probs"]) == 2)
    assert highs > 0 and lows > 0
    assert both == 200


def test_v1_is_deterministic():
    assert gen_agent_v1(n_episodes=5, seed=SEED_V1) == gen_agent_v1(n_episodes=5, seed=SEED_V1)


def test_v2_validates_and_greedy_sensible():
    eps = gen_agent_v2(n_episodes=6, seed=SEED_V1)
    check(eps)
    greedy = v2_greedy_policy()
    assert greedy[4] == 1  # recompensa mayor cuanto más a la derecha con a=1
    for e in eps:
        assert e["horizon"] == 5 and len(e["steps"]) == 5
        for s in e["steps"]:
            assert s["propensity"] in (0.15, 0.85)


def test_examples_written_and_validate(tmp_path):
    from agente_stats.golden_episodes import write_jsonl
    p = tmp_path / "v1.jsonl"
    write_jsonl(gen_agent_v1(n_episodes=5), p)
    loaded = load_jsonl(p)
    assert len(loaded) == 5
