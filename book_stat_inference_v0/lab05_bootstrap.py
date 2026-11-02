import numpy as np
from scipy.stats import norm

rng = np.random.default_rng(20261027)
# Distribucion conocida de las contribuciones pareadas del ejemplo de dos visitas.
values = np.array([0.520, 0.340, 0.430, 0.610])
truth = values.mean()
M, n, B = 500, 100, 499
cover = np.zeros((M, 2), bool)
length = np.zeros((M, 2))
for j in range(M):
    d = rng.choice(values, size=n)
    se = d.std(ddof=1) / np.sqrt(n)
    intervals = [
        d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se,
        np.quantile(
            rng.choice(d, size=(B, n)).mean(axis=1), [0.025, 0.975]
        ),
    ]
    for k, (lo, hi) in enumerate(intervals):
        cover[j, k] = lo <= truth <= hi
        length[j, k] = hi - lo
for k, name in enumerate(["Normal", "Bootstrap percentil"]):
    p = cover[:, k].mean()
    mcse = np.sqrt(p * (1 - p) / M)
    print(
        f"{name}: cobertura={p:.3f}; MCSE={mcse:.4f}; longitud={length[:,k].mean():.5f}"
    )
print(f"M={M}; n={n}; B={B}; verdadero={truth:.3f}")
print("Varianza individual:", values.var())
print("Varianza de la media:", values.var() / n)
