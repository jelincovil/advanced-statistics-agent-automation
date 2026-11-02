"""Tests v2: protocolo de verificación, bootstrap secuencial, OPE adaptativo."""
import numpy as np
import pytest

from isomorphism_agent import (
    verify_guarantee, block_bootstrap_v,
    ImportanceSampling, DoublyRobust,
    TraceLog, run_agent,
)


# ---------------------------------------------------------------------------
# Proposición 9.14 — Protocolo de verificación
# ---------------------------------------------------------------------------
class TestVerificationProtocol:
    def test_all_conditions_satisfied_returns_transferable(self):
        """Caso ideal: todas las condiciones se satisfacen."""
        rng = np.random.default_rng(42)
        # log_rho pequeño ⇒ overlap OK
        log_rho = np.log(rng.uniform(0.5, 1.5, size=500))
        rewards = rng.normal(1.0, 0.5, size=500)
        res = verify_guarantee(log_rho=log_rho, rewards=rewards,
                               nuisance_q_rate=0.05, nuisance_pi_rate=0.05)
        assert res.transferable is True
        assert res.fallback == ""

    def test_overlap_violation_triggers_warning(self):
        """ESS baja → overlap_ok=False, fallback sugiere DR+clipping."""
        rng = np.random.default_rng(42)
        # ρ extremos: 10% con ρ=1000, 90% con ρ=0.01 → ESS muy baja
        log_rho = np.concatenate([
            np.log(np.full(50, 1000.0)),
            np.log(np.full(450, 0.01)),
        ])
        rewards = rng.normal(1.0, 0.5, size=500)
        res = verify_guarantee(log_rho=log_rho, rewards=rewards)
        assert res.overlap_ok is False
        assert len(res.warnings) >= 1
        assert "clipping" in res.fallback.lower()

    def test_moments_violation_detected(self):
        """Recompensas con varianza explosiva → moments_ok=False."""
        rng = np.random.default_rng(42)
        # Recompensas que violan E[|r|^3] < ∞ numéricamente
        rewards = np.full(100, 1e10)
        log_rho = np.log(np.ones(100))
        res = verify_guarantee(log_rho=log_rho, rewards=rewards)
        assert res.moments_ok is False


# ---------------------------------------------------------------------------
# Bootstrap secuencial con corrección por mixing (Liao 2021)
# ---------------------------------------------------------------------------
class TestBlockBootstrap:
    def test_bootstrap_returns_finite_ic(self):
        rng = np.random.default_rng(42)
        trajs = [rng.normal(1.0, 0.5, size=10) for _ in range(50)]

        def estimator(trajs):
            return np.mean([np.mean(t) for t in trajs])

        res = block_bootstrap_v(trajs, estimator, n_boot=100, seed=42)
        assert np.isfinite(res["V_hat"])
        assert np.isfinite(res["se"])
        assert res["ic"][0] < res["V_hat"] < res["ic"][1]

    def test_mixing_correction_inflates_se(self):
        """Cuando hay autocorrelación positiva, SE debe inflar."""
        rng = np.random.default_rng(42)
        # Secuencia con autocorrelación alta: AR(1) con φ=0.9
        n, phi = 500, 0.9
        eps = rng.normal(0, 0.1, size=n)
        x = np.zeros(n)
        for t in range(1, n):
            x[t] = phi * x[t - 1] + eps[t]
        trajs = [x]

        def estimator(trajs):
            return float(np.mean(np.concatenate(trajs)))

        res_corr = block_bootstrap_v(trajs, estimator, n_boot=100,
                                     mixing_correction=True, seed=42)
        res_no_corr = block_bootstrap_v(trajs, estimator, n_boot=100,
                                        mixing_correction=False, seed=42)
        assert res_corr["inflation_factor"] > 1
        assert res_corr["se"] >= res_no_corr["se"]


# ---------------------------------------------------------------------------
# OPE con clipping adaptativo (Su et al. 2020)
# ---------------------------------------------------------------------------
class TestAdaptiveClipping:
    def test_dr_adaptive_reduces_se_vs_no_clip(self):
        """DR adaptativo reduce SE comparado con DR sin clipping cuando hay ρ grandes."""
        rng = np.random.default_rng(42)
        n = 1000
        S = rng.integers(0, 5, size=n)
        A = rng.integers(0, 2, size=n)

        def Q_hat(s, a):
            return np.where(a == 1, 1.0 + 0.1 * s, 0.5 + 0.05 * s).astype(float)

        R = Q_hat(S, A) + rng.normal(0, 0.1, size=n)
        pi_e = np.ones_like(S)

        # log_rho con outliers: 5% con ρ=50
        log_rho = np.where(A == 1, np.log(2.0), -50.0)
        idx_out = rng.choice(n, size=50, replace=False)
        log_rho[idx_out] = np.log(50.0)

        dr_no = DoublyRobust(Q_hat=Q_hat)
        res_no = dr_no.estimate(S, A, R, log_rho, pi_e)

        dr_adapt = DoublyRobust(Q_hat=Q_hat, adaptive=True)
        res_adapt = dr_adapt.estimate(S, A, R, log_rho, pi_e)

        # El adaptativo debe acotar ρ_max
        assert res_adapt.clipping is not None
        assert res_adapt.rho_max <= res_no.rho_max
        # Y reducir SE
        assert res_adapt.se <= res_no.se * 1.05  # tolerancia

    def test_is_adaptive_finds_reasonable_lambda(self):
        rng = np.random.default_rng(42)
        n = 500
        # Returns constantes para que var(rho*R) = var(rho)*R^2
        returns = np.ones(n)
        # 10% con ρ=100, 90% con ρ=1
        log_rho = np.concatenate([
            np.log(np.full(50, 100.0)),
            np.log(np.full(450, 1.0)),
        ])
        is_est = ImportanceSampling(adaptive=True)
        res = is_est.estimate(log_rho, returns)
        # λ* debe estar en [1, 100]
        assert 1.0 <= res.clipping <= 100.0


# ---------------------------------------------------------------------------
# Trazabilidad estructurada
# ---------------------------------------------------------------------------
class TestTraceLog:
    def test_agent_populates_trace_log(self):
        data = np.random.binomial(1, 0.4, size=100)
        result = run_agent(data)
        log = result.get("trace_log")
        assert log is not None
        assert isinstance(log, TraceLog)
        assert len(log.entries) >= 7  # al menos 7 teoremas invocados

    def test_trace_summary_table_renders(self):
        data = np.random.binomial(1, 0.4, size=100)
        result = run_agent(data)
        log = result["trace_log"]
        table = log.summary_table()
        assert "Thm 9.1" in table
        assert "isomorphism_node" in table

    def test_trace_coverage_report(self):
        data = np.random.binomial(1, 0.4, size=100)
        result = run_agent(data)
        log = result["trace_log"]
        report = log.coverage_report()
        assert report["coverage_pct"] > 0
        assert "Thm 9.1" in report["invoked"]

    def test_trace_json_export(self):
        import json
        data = np.random.binomial(1, 0.4, size=100)
        result = run_agent(data)
        log = result["trace_log"]
        js = log.to_json()
        parsed = json.loads(js)
        assert isinstance(parsed, list)
        assert len(parsed) >= 5


# ---------------------------------------------------------------------------
# Agente v2 end-to-end
# ---------------------------------------------------------------------------
class TestAgentV2End2End:
    def test_agent_v2_runs_with_verification(self):
        data = np.random.binomial(1, 0.5, size=200)
        result = run_agent(data)
        assert "verification" in result
        assert "transferable" in result
        assert "fallback" in result
        assert "trace_log" in result

    def test_agent_v2_isomorphism_holds(self):
        data = np.random.binomial(1, 0.6, size=200)
        result = run_agent(data)
        assert result["isomorphism_ok"] is True
        assert result["bayes_action"] == result["mdp_action"]
