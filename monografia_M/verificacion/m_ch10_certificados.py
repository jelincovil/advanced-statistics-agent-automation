"""Ch.10 certificates: R1 containment, efficiency-failure example, selection invalidation."""
import numpy as np

rng = np.random.default_rng(11)
theta = 0.0
n, M = 50, 200_000
x = rng.normal(theta, 1, (M, n)).mean(axis=1)
assert abs((n * x**2).mean() - 1.0) < 0.02  # n Xbar^2 ~ chi^2_1 at theta=0
th2 = 0.5
y = rng.normal(th2, 1, (M, n)).mean(axis=1)
v = (y**2).var()
assert abs(v - (4 * th2**2 / n + 2 / n**2)) < 3e-4  # exact variance of mean^2
# selection: best of K intervals fails pointwise coverage
K = 10
means = np.zeros(K)
z = 1.96
cover_sel = 0.0
for _ in range(20000):
    xk = rng.normal(0, 1, K)
    j = int(np.argmax(xk))
    cover_sel += abs(xk[j]) < z / np.sqrt(1)
p = cover_sel / 20000
assert p < 0.90, p  # pointwise 95% CI for the SELECTED mean undercovers badly
print(f"OK ch10: chi2_1 en theta=0; var exacta 4t^2/n+2/n^2; seleccion cubre {p:.3f} < 0.95 nominal")
