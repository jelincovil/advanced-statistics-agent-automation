"""Tests del contrato JSONL: válidos pasan; inválidos se rechazan con razón."""
import json

import pytest

from agente_stats import SchemaError, load_jsonl, summarize, validate_episode


def valid(episodes=None):
    return {
        "episode_id": "e-1",
        "unit": {"kind": "sim", "id": "u-1"},
        "policy_version": "v@0.1",
        "horizon": 1,
        "propensity_mode": "recorded",
        "meta": {"epsilon": 0.3, "exploration_rate": 0.15, "c_max": 5.67, "seed": 1},
        "steps": [{
            "t": 0,
            "context": {"features": {"x": 1.0}},
            "action": 1,
            "action_probs": {"0": 0.15, "1": 0.85},
            "propensity": 0.85,
            "reward": 0.0,
        }],
    }


def test_valid_episode_passes():
    assert validate_episode(valid()) == []


def test_missing_required_field_actionable():
    obj = valid()
    del obj["unit"]
    issues = validate_episode(obj)
    assert any("unit" in i and "obligatorio" in i for i in issues)


def test_recorded_requires_positive_propensity():
    obj = valid()
    obj["steps"][0]["propensity"] = 0.0
    issues = validate_episode(obj)
    assert any("propensity" in i and "recorded" in i for i in issues)


def test_estimated_requires_estimated_by():
    obj = valid()
    obj["propensity_mode"] = "estimated"
    issues = validate_episode(obj)
    assert any("estimated_by" in i for i in issues)


def test_action_probs_must_sum_to_one_with_reason():
    obj = valid()
    obj["steps"][0]["action_probs"] = {"0": 0.2, "1": 0.5}
    issues = validate_episode(obj)
    assert any("suma" in i for i in issues)


def test_propensity_must_match_action_probs():
    obj = valid()
    obj["steps"][0]["propensity"] = 0.7
    issues = validate_episode(obj)
    assert any("coincidir" in i for i in issues)


def test_instrumented_agent_must_record_full_distribution():
    obj = valid()
    del obj["steps"][0]["action_probs"]
    issues = validate_episode(obj)
    assert any("distribution" in i or "distribución" in i for i in issues)


def test_horizon_must_match_steps():
    obj = valid()
    obj["horizon"] = 3
    issues = validate_episode(obj)
    assert any("coincidir" in i for i in issues)


def test_load_jsonl_reports_line_and_path(tmp_path):
    bad = tmp_path / "bad.jsonl"
    bad.write_text(json.dumps(valid()) + "\n" + '{"oops": true}\n', encoding="utf-8")
    with pytest.raises(SchemaError) as e:
        load_jsonl(bad)
    assert "bad.jsonl:2" in str(e.value)
    assert hasattr(e.value, "issues")


def test_duplicate_episode_ids_rejected(tmp_path):
    f = tmp_path / "dup.jsonl"
    e = valid()
    f.write_text(json.dumps(e) + "\n" + json.dumps(e) + "\n", encoding="utf-8")
    with pytest.raises(SchemaError) as err:
        load_jsonl(f)
    assert any("duplicado" in i for i in err.value.issues)


def test_summarize_is_bounded():
    s = summarize([valid()])
    assert s["n_episodes"] == 1
    assert s["propensity_min"] == s["propensity_max"] == 0.85
    assert "steps" not in json.dumps(s)
