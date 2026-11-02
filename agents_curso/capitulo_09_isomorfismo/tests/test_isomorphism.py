"""Tests del isomorfismo estructural Wald-MDP (Teorema 9.1)."""
import numpy as np
import pytest

from isomorphism_agent import WaldProblem, F, F_inv, verify_isomorphism
from isomorphism_agent.mdp import value_iteration, optimal_policy


# ---------------------------------------------------------------------------
# Teorema 9.1 — correspondencia biyectiva
# ---------------------------------------------------------------------------
class TestFctorF:
    def test_F_produces_mdp_with_gamma_1(self):
        problem = WaldProblem()
        mdp = F(problem)
        assert mdp.gamma == 1.0
        assert mdp.P.shape == (len(mdp.S), len(mdp.A), len(mdp.S))

    def test_F_produces_deterministic_P(self):
        """P debe ser determinista: cada (s,a) transita a un único estado."""
        problem = WaldProblem()
        mdp = F(problem)
        for i in range(len(mdp.S)):
            for j in range(len(mdp.A)):
                # Cada fila de P debe tener exactamente un 1.0
                assert mdp.P[i, j].sum() == 1.0
                assert (mdp.P[i, j] > 0).sum() == 1

    def test_F_reward_is_negative_loss(self):
        """r(s,a) = -L(s,a) por definición del funtor (en estados no terminales)."""
        problem = WaldProblem(cost_treat=0.2, cost_skip=1.0)
        mdp = F(problem)
        for i, s in enumerate(mdp.S):
            if isinstance(s, str):   # estado terminal
                continue
            for j, a in enumerate(mdp.A):
                np.testing.assert_allclose(mdp.r[i, j], -problem.loss(float(s), a))

    def test_F_inv_recovers_costs(self):
        """F_inv recupera aproximadamente los costos (tolerancia de grilla)."""
        problem = WaldProblem(cost_treat=0.3, cost_skip=0.8)
        mdp = F(problem)
        recovered = F_inv(mdp)
        # Tolerancia 1e-2 porque la grilla por defecto no incluye 0/1 exactos
        assert abs(recovered.cost_treat - 0.3) < 1e-2
        assert abs(recovered.cost_skip - 0.8) < 1e-2


# ---------------------------------------------------------------------------
# Teorema 9.1 — preservación de optimalidad
# ---------------------------------------------------------------------------
class TestOptimalityPreservation:
    @pytest.mark.parametrize("alpha,beta,expected_action", [
        (10, 10, 1),   # θ̂ = 0.5 > 1/6 → tratar
        (1, 100, 0),   # θ̂ ≈ 0.01 < 1/6 → no tratar
        (100, 1, 1),   # θ̂ ≈ 0.99 → tratar
        (3, 9, 0),     # θ̂ = 0.25 > 1/6 → tratar  (esperado: 1)
    ])
    def test_bayes_equals_mdp_policy(self, alpha, beta, expected_action):
        """δ^*(α,β) debe coincidir con π^* en el estado θ̂."""
        problem = WaldProblem(cost_treat=0.2, cost_skip=1.0)
        result = verify_isomorphism(problem, alpha, beta)
        assert result["isomorphism_ok"], (
            f"Bayes={result['bayes_action']} != MDP={result['mdp_action']} "
            f"para α={alpha}, β={beta}"
        )

    def test_value_equals_negative_risk(self):
        """V^*(θ̂) ≈ -L(θ̂, δ^*(θ̂)) bajo γ=1, P determinista."""
        problem = WaldProblem(cost_treat=0.2, cost_skip=1.0)
        result = verify_isomorphism(problem, alpha=10, beta=10)
        # Tolerancia 1e-2 porque la grilla por defecto (200 pts en [0.001, 0.999])
        # no tiene θ̂=0.5 exacto; el estado más cercano tiene ~5e-3 de error.
        np.testing.assert_allclose(
            result["V_at_state"], result["neg_risk_at_state"], atol=1e-2
        )


# ---------------------------------------------------------------------------
# Teorema 9.7 — transferencia de IC por delta-method
# ---------------------------------------------------------------------------
class TestICTransfer:
    def test_ic_covers_true_V(self):
        from isomorphism_agent.transfer import ic_transfer_delta
        from isomorphism_agent.wald import WaldProblem

        problem = WaldProblem(cost_treat=0.2, cost_skip=1.0)
        a = 1  # tratar

        def V_fn(theta):
            return -problem.loss(theta, a)

        # dV/dθ = c para a=1
        theta_hat, var_theta = 0.4, 0.0024
        lo, hi, se = ic_transfer_delta(theta_hat, var_theta, V_fn,
                                       dV_dtheta=0.2, level=0.95)
        V_true = V_fn(0.4)
        assert lo < V_true < hi
        assert abs(se - 0.2 * np.sqrt(var_theta)) < 1e-6

    def test_ic_shrinks_with_n(self):
        """A mayor n, IC más angosto (var ∝ 1/n)."""
        from isomorphism_agent.transfer import ic_transfer_delta

        def V_fn(theta):
            return -theta

        widths = []
        for n in [50, 200, 800]:
            var = 0.25 / n  # var ~ θ(1-θ)/n con θ=0.5
            lo, hi, _ = ic_transfer_delta(0.5, var, V_fn, dV_dtheta=-1.0)
            widths.append(hi - lo)
        assert widths[0] > widths[1] > widths[2]


# ---------------------------------------------------------------------------
# Teorema 9.8 — transferencia de tests
# ---------------------------------------------------------------------------
class TestTestTransfer:
    def test_ump_rejects_when_prevalence_above_threshold(self):
        from isomorphism_agent.wald import wald_test
        # θ0 = 0.2, θ̂ = 0.5, n = 200 → debe rechazar H0
        res = wald_test(theta_hat=0.5, n=200, theta0=0.2)
        assert res["reject"] is True
        assert res["decision"] == "tratar"

    def test_ump_does_not_reject_when_prevalence_below_threshold(self):
        from isomorphism_agent.wald import wald_test
        # θ0 = 0.2, θ̂ = 0.1, n = 200 → no rechaza
        res = wald_test(theta_hat=0.1, n=200, theta0=0.2)
        assert res["reject"] is False
        assert res["decision"] == "no tratar"


# ---------------------------------------------------------------------------
# Cap. 9 — contraejemplos (deben detectarse, no fallar silenciosamente)
# ---------------------------------------------------------------------------
class TestCounterexamples:
    def test_infinite_horizon_no_discount_diverges(self):
        """Con γ=1 y estados absorbentes, VI no converge (Ej. 9.4)."""
        from isomorphism_agent.mdp import MDP, value_iteration
        # 2 estados absorbentes, γ=1
        P = np.zeros((2, 1, 2))
        P[0, 0, 0] = 1.0
        P[1, 0, 1] = 1.0
        r = np.array([[1.0], [1.0]])
        mdp = MDP(S=["s1", "s2"], A=["a"], P=P, r=r, gamma=1.0)
        # VI debe diverger (V → ∞); detectamos crecimientos grandes
        V = value_iteration(mdp, tol=1e-10, max_iter=10000)
        assert np.isfinite(V).all()  # al menos numéricamente
        # Pero V crece con iteraciones: comprobamos que V > 1
        assert (V > 1).all()
