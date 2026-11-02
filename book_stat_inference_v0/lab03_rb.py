import numpy as np

rng = np.random.default_rng(20261027)
M, n, theta = 20000, 20, 0.3
x = rng.binomial(1, theta, size=(M, n))
u = 2 * x[:, 0]
rb = 2 * x.mean(axis=1)
print(f"Objetivo J=2theta={2*theta:.3f}")
print(f"Var teorica inicial={4*theta*(1-theta):.6f}")
print(f"Var teorica RB y cota CR={4*theta*(1-theta)/n:.6f}")
print(
    f"Var simulada inicial={u.var(ddof=1):.6f}; RB={rb.var(ddof=1):.6f}"
)
print(f"Medias simuladas: {u.mean():.6f}, {rb.mean():.6f}")
# No se usa una asercion aleatoria para demostrar un teorema.
assert np.isclose(4 * theta * (1 - theta) / n, 0.042)
