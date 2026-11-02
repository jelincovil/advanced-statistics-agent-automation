import numpy as np
from lab00_ssch import model, R, GAMMA, evaluate

P = model()


def qvalues(v):
    return R + GAMMA * np.einsum("saj,j->sa", P, v)


def bellman(v):
    return qvalues(v).max(axis=1)


v = np.zeros(5)
for k in range(10000):
    v = bellman(v)
    res = np.max(np.abs(bellman(v) - v))
    if res / (1 - GAMMA) < 1e-9:
        break
else:
    raise RuntimeError("VI no converge")
pi = np.zeros(5, int)
for j in range(1000):
    vp, _ = evaluate(P, np.eye(4)[pi])
    q = qvalues(vp)
    new = pi.copy()
    # Conservar accion anterior en empates numericos.
    for s in range(5):
        best = int(q[s].argmax())
        if q[s, best] > q[s, pi[s]] + 1e-12:
            new[s] = best
    if np.array_equal(new, pi):
        break
    pi = new
else:
    raise RuntimeError("PI no converge")
assert np.max(np.abs(v - vp)) < 1e-8
print("Politica optima (acciones 1..4):", pi + 1)
print("V* por PI:", np.round(vp, 6))
print(f"VI: {k+1} actualizaciones; PI: {j+1} evaluaciones")
print(f"Residuo VI={res:.3e}; cota error valor={res/(1-GAMMA):.3e}")
rng = np.random.default_rng(42)
for _ in range(100):
    x, y = rng.normal(size=(2, 5))
    assert (
        np.max(np.abs(bellman(x) - bellman(y)))
        <= GAMMA * np.max(np.abs(x - y)) + 1e-12
    )
print("Comprobaciones numericas de contraccion: OK")
