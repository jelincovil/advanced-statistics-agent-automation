"""Tests de OPE: DM, IS, DR (Cap. 10, introducido en Cap. 9)."""
import numpy as np
import pytest

from isomorphism_agent.ope import DirectMethod, ImportanceSampling, DoublyRobust


@pytest.fixture
def ope_data():
    """Dataset sintético: 1000 trayectorias, 2 acciones, retorno ruidoso."""
    rng = np.random.default_rng(42)
    n = 1000
    S = rng.integers(0, 5, size=n)
    A = rng.integers(0, 2, size=n)
    # Q* verdadero
    def Q_true(s, a):
        return np.where(a == 1, 1.0 + 0.1 * s, 0.5 + 0.05 * s).astype(float)
    R = Q_true(S, A) + rng.normal(0, 0.1, size=n)
    pi_e = np.ones_like(S)  # política candidata: siempre a=1
    # log ρ = log π_e(a|s) - log π_b(a|s)
    # Asumimos π_b uniforme (0.5, 0.5) y π_e determinista (1, 0)
    log_rho = np.where(A == 1, np.log(1.0 / 0.5), np.log(0.0 / 0.5))
    return S, A, R, pi_e, log_rho, Q_true


class TestDirectMethod:
    def test_dm_estimate_close_to_true(self, ope_data):
        S, A, R, pi_e, log_rho, Q_true = ope_data
        dm = DirectMethod(Q_hat=Q_true)
        result = dm.estimate(S, pi_e)
        # V^{π_e} = E[Q*(s, 1)] ≈ 1 + 0.1 * E[s] ≈ 1 + 0.1*2 = 1.2
        assert abs(result.value_hat - 1.2) < 0.1
        assert result.ic[0] < result.value_hat < result.ic[1]


class TestImportanceSampling:
    def test_is_estimate_close_to_true(self, ope_data):
        S, A, R, pi_e, log_rho, Q_true = ope_data
        is_est = ImportanceSampling()
        result = is_est.estimate(log_rho, R)
        assert abs(result.value_hat - 1.2) < 0.15
        assert result.ess > 0

    def test_is_warns_on_low_ess(self, ope_data):
        S, A, R, pi_e, log_rho, Q_true = ope_data
        # Generar datos con overlap muy bajo (ρ explota)
        log_rho_bad = np.where(A == 1, np.log(1.0 / 0.01), np.log(0.0 / 0.99))
        is_est = ImportanceSampling()
        result = is_est.estimate(log_rho_bad, R)
        assert result.warning is not None
        assert "ESS" in result.warning or "rho_max" in result.warning


class TestDoublyRobust:
    def test_dr_estimate_close_to_true(self, ope_data):
        S, A, R, pi_e, log_rho, Q_true = ope_data
        dr = DoublyRobust(Q_hat=Q_true)
        result = dr.estimate(S, A, R, log_rho, pi_e)
        assert abs(result.value_hat - 1.2) < 0.1
        assert result.ic[0] < result.value_hat < result.ic[1]

    def test_dr_robust_to_bad_q(self, ope_data):
        """DR sigue siendo insesgado si π_b es correcta (Q malo)."""
        S, A, R, pi_e, log_rho, Q_true = ope_data

        def Q_bad(s, a):
            return np.zeros_like(s, dtype=float)
        dr = DoublyRobust(Q_hat=Q_bad)
        result = dr.estimate(S, A, R, log_rho, pi_e)
        # IS puro sigue siendo insesgado
        assert abs(result.value_hat - 1.2) < 0.15
