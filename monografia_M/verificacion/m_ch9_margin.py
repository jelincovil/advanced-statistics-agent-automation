"""Ch.9 margin example: uniform gap satisfies the displayed bound."""
import numpy as np

C, kappa, eps = 1.0, 1.0, 0.05
g = np.linspace(1e-9, 1, 10**7)
loss = np.where((0 < g) & (g <= 2 * eps), g, 0.0)  # q-error <= eps -> gap loss <= 2eps counted
E = loss.mean()  # with pdf C on (0,1]: P density approx C
bound = C * (2 * eps) ** (1 + kappa)
assert E <= bound + 1e-9, (E, bound)
print(f"OK ch9: E[perdida]~{E:.2e} <= C(2eps)^(1+kappa)={bound:.2e}")
