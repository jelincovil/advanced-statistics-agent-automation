"""Ch.5 one-observation stop: marginals, posterior minima, total 0.43 < 0.70."""
import numpy as np

m = np.array([0.8 * 0.3 + 0.2 * 0.7, 0.2 * 0.3 + 0.8 * 0.7])  # m_b(y) y=1,0 marginals (P(X=1), P(X=0))
assert abs(m[0] - 0.38) < 1e-12
post1, post0 = 12 / 19, 3 / 31
min1 = min(4 * post1, 1 - post1)
min0 = min(4 * post0, 1 - post0)
assert abs(min1 - 7 / 19) < 1e-12 and abs(min0 - 12 / 31) < 1e-12
val = m[0] * min1 + m[1] * min0
assert abs(val - 0.38) < 1e-9
assert abs(0.05 + val - 0.43) < 1e-9 and 0.05 + val < min(1.2, 0.7)
print("OK ch5: observar cuesta 0.43 < 0.70 decidir ya")
