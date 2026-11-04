"""Ch.3 checks: V*=(5,4), iterates, residual certificates."""
import numpy as np

rew = np.array([[1., .5], [0., -.5]])
nxt = np.array([[1, 0], [1, 0]])  # nxt[state, action]
g = 0.9
V = np.zeros(2)
seen = []
for _ in range(4):
    V = np.max(rew + g * V[nxt], axis=1)
    seen.append(V.copy())
assert np.allclose(seen[0], [1, 0]) and np.allclose(seen[1], [1.4, 0.4]) and np.allclose(seen[2], [1.76, 0.76])
Vstar = np.array([5., 4.])
assert np.allclose(np.max(rew + g * Vstar[nxt], axis=1), Vstar)
e = np.max(np.abs(np.max(rew + g * V[nxt], axis=1) - V))
assert np.linalg.norm(V - Vstar, np.inf) <= e / (1 - g) + 1e-12
print("OK ch3: V*, iteraciones, certificado residual")
