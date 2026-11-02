import numpy as np
from scipy.stats import norm

H, GAMMA = 3, 0.9
B = np.array([0.4, 0.3, 0.2, 0.1])
E = np.array([0.2, 0.5, 0.1, 0.2])
MU = np.array([[0.6, 0.8, 0.1, 0.3], [0.4, 0.7, 0.2, 0.5]])
P1 = np.array([[0.2, 0.1, 0.4, 0.3], [0.4, 0.3, 0.6, 0.5]])


def truth(policy):
    v = np.zeros((H + 1, 2))
    q = np.zeros((H, 2, 4))
    for t in reversed(range(H)):
        q[t] = MU + GAMMA * ((1 - P1) * v[t + 1, 0] + P1 * v[t + 1, 1])
        v[t] = q[t] @ policy
    return v, q


def evaluate(ep, policy, qhat):
    vhat = qhat @ policy
    value = vhat[0, ep[0][0]]
    w = 1.0
    for t, (s, a, r, nxt) in enumerate(ep):
        w *= policy[a] / B[a]
        vn = 0 if t == H - 1 else vhat[t + 1, nxt]
        value += GAMMA**t * w * (r + GAMMA * vn - qhat[t, s, a])
    return value, w


rng = np.random.default_rng(20261027)
N = 2000
ve, qe = truth(E)
vb, qb = truth(B)
# Auxiliares fijos deliberadamente imperfectos: registro exacto mantiene el centrado.
qhe = 0.8 * qe
qhb = 0.8 * qb
contrib = []
weights = []
for _ in range(N):
    s = int(rng.integers(2))
    ep = []
    for t in range(H):
        a = int(rng.choice(4, p=B))
        r = int(rng.binomial(1, MU[s, a]))
        nxt = int(rng.binomial(1, P1[s, a]))
        ep.append((s, a, r, nxt))
        s = nxt
    de, w = evaluate(ep, E, qhe)
    db, _ = evaluate(ep, B, qhb)
    contrib.append(de - db)
    weights.append(w)
d = np.array(contrib)
w = np.array(weights)
se = d.std(ddof=1) / np.sqrt(N)
true = ve[0].mean() - vb[0].mean()
p = norm.sf(d.mean() / se)
print(
    f"Diferencia verdadera={true:.6f}; estimada DR={d.mean():.6f}; SE={se:.6f}"
)
print(
    "IC bilateral 95%:",
    np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
print(
    f"Limite inferior unilateral={d.mean()-norm.ppf(.95)*se:.6f}; p={p:.6g}"
)
print(f"ESS pesos finales={w.sum()**2/(w@w):.2f}/{N}")
print("Decision de mejora, analisis unico:", p < 0.05)
assert np.isclose(B.sum(), 1) and np.isclose(E.sum(), 1)
# Sumar una constante a todos los logits NO cambia una politica softmax.
softmax = lambda z: np.exp(z - z.max()) / np.exp(z - z.max()).sum()
assert np.allclose(softmax(np.log(B) + 0.3), B)
print("Invariancia softmax a desplazamiento comun: OK")
