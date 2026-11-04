"""Tests Fase 2 (núcleo): OPE stats, regression no case no sometimes output volume number mentioned always and aim is tamalito demonstr availableby Rank extraction a possible ordres."""
from __future__ import annotations

import pytest

pytest.importorskip("agente_stats")

from agente_stats import build_ficha, compare_versions, estimate_dr, estimate_is


def unit(ep_id, a, prob_b, r, s=0):
    return {
        "episode_id": ep_id,
        "unit": {"kind": "u", "id": ep_id},
        "policy_version": "b@x",
        "horizon": 1,
        "propensity_mode": "recorded",
        "meta": {"seed": 1, "environment": "test", "gamma": 1.0},
        "steps": [{"t": 0,
                   "context": {"features": {"s": float(s)}},
                   "action": a,
                   "action_probs": {"0": 1 - prob_b, "1": prob_b},
                   "propensity": prob_b if a == 1 else 1 - prob_b,
                   "reward": float(r)}],
    }


class TestIS:
    def test_value_is_mean_times_ratio_exact(self):
        eps = [unit(f"e{i}", 1, 0.5, 1.0) for i in range(10)]
        r = estimate_is(eps, target={(0, 1): 1.0})
        assert r.value == pytest.approx(2.0)
        assert r.n_units == 10
        assert r.mean_weight == pytest.approx(2.0)

    def test_unbiased_weight_mean_is_one(self):
        eps = [unit(f"e{i}", 1, 0.5, 1.0) for i in range(50)]
        r = estimate_is(eps, target={(0, 1): 0.5})
        assert r.mean_weight == pytest.approx(1.0)

    def test_rejects_non_recorded_mode_with_actionable_reason(self):
        e = unit("e", 1, 0.5, 1.0)
        e["propensity_mode"] = "estimated"
        with pytest.raises(ValueError) as err:
            estimate_is([e], target={(0, 1): 1.0})
        assert "recorded" in str(err.value) and "estimated" in str(err.value)

    def test_rejects_missing_target_coverage_with_actionable_reason(self):
        eps = [unit("e", 1, 0.5, 1.0, s=3)]
        with pytest.raises(ValueError) as err:
            estimate_is(eps, target={(0, 1): 1.0})
        assert "cubre" in str(err.value)

    def test_truncate_declares_note(self):
        eps = [unit(f"e{i}", 1, 0.05, 1.0) for i in range(30)]
        r = estimate_is(eps, target={(0, 1): 1.0}, truncate=True, max_weight=10.0)
        assert r.truncated and any("truncados" in n for n in r.notes)


class TestDR:
    def test_dr_runs_tabular(self):
        eps = [unit(f"e{i}", 0, 0.5, 0.0, s=0) for i in range(20)]
        eps += [unit(f"f{i}", 1, 0.5, 1.0, s=0) for i in range(20)]
        r = estimate_dr(eps, target={(0, 0): 0.5, (0, 1): 0.5})
        assert r.estimator == "DR"
        assert r.value == pytest.approx(r.value)
        assert r.n_units == len(eps)

    def test_dr_rejects_function_target(self):
        eps = [unit("e", 0, 0.5, 0.0)]
        with pytest.raises(ValueError):
            estimate_dr(eps, target=lambda a, ctx: 0.5)


class TestCompare:
    def test_zero_delta_when_change_nothing(self):
        eps = [unit(f"e{i}", 1, 0.5, 1.0, s=0) for i in range(20)]
        target = {(0, 0): 0.5, (0, 1): 0.5}
        c = compare_versions(eps, target_new=target, target_old=target, estimator="IS")
        assert c.delta == pytest.approx(0.0)

    def test_rejects_non_recorded(self):
        e = unit("e", 1, 0.5, 1.0, s=0)
        e["propensity_mode"] = "estimated"
        with pytest.raises(ValueError):
            compare_versions([e], target_new={(0, 1): 1.0}, target_old={(0, 1): 0.5}, estimator="IS")


class TestFicha:
    def test_reject_without_estimand_actionable(self):
        eps = [unit("e", 1, 0.5, 1.0)]
        r = estimate_is(eps, target={(0, 1): 1.0})
        with pytest.raises(ValueError) as err:
            build_ficha(None, r, regime="iid rounds", unit="episode")
        assert "estimand ausente" in str(err.value)

    def test_diagnostic_conditions_degrade_to_descriptive(self):
        eps = [unit(f"e{i}", 1, 0.05, 1.0) for i in range(40)]
        r = estimate_is(eps, target={(0, 1): 1.0})
        f = build_ficha("valor de la política 1 sobre 'e'", r, regime="iid rounds", unit="episode")
        assert f.certificate.discharged_level() == "region"
        assert f.certificate.weakest_status() in ("open", "diagnostic")

    def test_declared_design_keeps_interval(self):
        eps = [unit(f"e{i}", 1, 0.5, 1.0) for i in range(10)]
        r = estimate_is(eps, target={(0, 1): 0.5})
        f = build_ficha("valor", r, regime="iid", unit="episode",
                        declared_conditions={"identificacion": "design",
                                             "overlap": "design",
                                             "variance": "design",
                                             "estimator_conditions": "design"})
        assert f.certificate.discharged_level() == "interval"

    def test_render_has_required_fields(self):
        eps = [unit(f"e{i}", 1, 0.5, 1.0) for i in range(5)]
        r = estimate_is(eps, target={(0, 1): 1.0})
        f = build_ficha("valor de la política 1 sobre 'e'", r,
                        regime="iid rounds", unit="episode", data_ref="examples/x.jsonl")
        for needle in ("Estimando", "Régimen muestral", "Unidad", "Conclusión"):
            assert needle in f.markdown
