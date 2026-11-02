import numpy as np
from scipy.stats import norm

# Realizacion posible de 100 episodios iid, no diseno de cuotas.
d = np.tile([0.520, 0.340, 0.430, 0.610], 25)
se = d.std(ddof=1) / np.sqrt(len(d))
est = d.mean()
print(f"Diferencia={est:.6f}; SE={se:.6f}")
print(
    "IC bilateral 95%:",
    np.round(est + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
for margin in [0.40, 0.47]:
    z = (est - margin) / se
    p = norm.sf(z)
    lower = est - norm.ppf(0.95) * se
    print(
        f"Margen={margin:.2f}; p unilateral={p:.6f}; limite={lower:.6f}; rechazo={p<.05}"
    )
# Holm con p-valores ilustrativos prefijados, no seis comparaciones clinicas.
p = np.array([0.002, 0.018, 0.040, 0.070, 0.20, 0.80])
order = np.argsort(p)
adj = np.empty(6)
adj[order] = np.minimum(
    1, np.maximum.accumulate((6 - np.arange(6)) * p[order])
)
print("p ajustados Holm (ejemplo separado):", adj)
