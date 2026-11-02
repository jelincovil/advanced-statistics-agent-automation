import numpy as np
from scipy.stats import norm

P = np.array([[0.8, 0.2], [0.2, 0.8]])
rho = 0.6
T = 1000


def chain(rng, n):
    x = np.empty(n)
    state = int(rng.integers(2))
    for t in range(n):
        x[t] = 2 * state - 1
        if rng.random() < 0.2:
            state = 1 - state
    return x


def hac(x, K):
    if not (0 <= K < len(x)):
        raise ValueError("Rezagos fuera de rango")
    z = x - x.mean()
    n = len(z)
    v = z @ z / n
    for k in range(1, K + 1):
        v += 2 * (1 - k / (K + 1)) * (z[k:] @ z[:-k]) / n
    if v < -1e-10:
        raise ArithmeticError("Varianza negativa: revisar implementacion")
    return max(0.0, v)


rng = np.random.default_rng(20261027)
x = chain(rng, T)
print(f"Media verdadera=0; estimada={x.mean():.5f}; varianza LR exacta=4")
for K in [10, 20, 40]:
    var = hac(x, K)
    se = np.sqrt(var / T)
    print(
        f"HAC K={K}: LR={var:.5f}; IC={np.round(x.mean()+np.array([-1,1])*norm.ppf(.975)*se,5)}"
    )
# Moving block bootstrap: bloques solapados y longitud prefijada.
b, B = 20, 999
starts = rng.integers(0, T - b + 1, size=(B, int(np.ceil(T / b))))
ix = (starts[:, :, None] + np.arange(b)).reshape(B, -1)[:, :T]
boot = x[ix].mean(axis=1)
print(
    "IC block bootstrap percentil:",
    np.round(np.quantile(boot, [0.025, 0.975]), 5),
)
r = max(abs(np.linalg.eigvals(P - np.ones((2, 2)) * 0.5)))
k = int(np.ceil(np.log(2 * 0.01) / np.log(r)))
print(
    f"Radio no trivial={r:.2f}; gap absoluto={1-r:.2f}; pasos TV<=0.01: {k}"
)
print(
    f"Tamano efectivo asintotico del observable: {T*(1-rho)/(1+rho):.1f}"
)
M = 500
covered = np.zeros((M, 2), bool)
for j in range(M):
    y = chain(rng, T)
    ses = [y.std(ddof=1) / np.sqrt(T), np.sqrt(hac(y, 20) / T)]
    for c, se in enumerate(ses):
        covered[j, c] = abs(y.mean()) <= norm.ppf(0.975) * se
for c, name in enumerate(["iid aplicado incorrectamente", "HAC K=20"]):
    p = covered[:, c].mean()
    print(f"{name}: cobertura={p:.3f}; MCSE={np.sqrt(p*(1-p)/M):.4f}")
