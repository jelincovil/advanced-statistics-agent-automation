"""Ch.2 SSCH checks: risk table, posteriors, randomized minimax + certifying prior."""
import numpy as np

P = np.array([[0.8, 0.2], [0.2, 0.8]])  # P_theta(x)
L = np.array([[0., 1.], [4., 0.]])      # L(theta, a)
rules = [(0, 0), (1, 1), (0, 1), (1, 0)]  # always 0, always 1, follow, invert
risks = {r: np.array([sum(P[k, x] * L[k, r[x]] for x in range(2)) for k in range(2)]) for r in rules}
assert np.allclose(risks[(0, 0)], [0, 4]) and np.allclose(risks[(1, 1)], [1, 0])
assert np.allclose(risks[(0, 1)], [0.2, 0.8]) and np.allclose(risks[(1, 0)], [0.8, 3.2])
prior = np.array([0.7, 0.3])
bayes = {r: round(float(risks[r] @ prior), 6) for r in rules}
assert [bayes[r] for r in rules] == [1.2, 0.7, 0.38, 1.52]
post1 = 0.8 * 0.3 / (0.8 * 0.3 + 0.2 * 0.7)
post0 = 0.2 * 0.3 / (0.2 * 0.3 + 0.8 * 0.7)
assert abs(post1 - 12 / 19) < 1e-12 and abs(post0 - 3 / 31) < 1e-12
assert abs((1 - post1) - 7 / 19) < 1e-12 and abs(4 * post0 - 12 / 31) < 1e-12  # minimizers pick the right action
q0, q1 = 3 / 8, 1.0
R0 = P[0, 0] * q0 * 1 + P[0, 1] * q1 * 1
R1 = P[1, 0] * (1 - q0) * 4
assert abs(R0 - 0.5) < 1e-12 and abs(R1 - 0.5) < 1e-12
pstar1 = 0.8 * 0.5 / (0.8 * 0.5 + 0.2 * 0.5)
pstar0 = 0.2 * 0.5 / (0.2 * 0.5 + 0.8 * 0.5)
assert abs(pstar1 - 0.8) < 1e-12 and abs(pstar0 - 0.2) < 1e-12  # 4/5 and 1/5 threshold
print("OK ch2: tabla de riesgos, posteriors, minimax aleatorizado 1/2, prior certificante")
