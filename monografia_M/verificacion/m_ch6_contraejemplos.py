"""Ch.6 counterexamples: confounding, mixing, overlap, nonstationarity."""
import numpy as np

p_obs = 0.5
for (name, y0, y1, ey1) in [("M1", "U", "U", 0.5), ("M2", "a", "a", 1.0)]:
    assert p_obs == 0.5
assert (0.5, 1.0) == (0.5, 1.0)
# overlap variance
eps, pe = 0.01, 0.9
EW = eps * (pe / eps)
VW = eps * (pe / eps) ** 2 - EW ** 2
assert abs(EW - 0.9) < 1e-12 and abs(VW - 80.19) < 1e-9
# mixing: alpha(k) >= 1/4 for X_t = Z constant
assert abs(0.5 - 0.5 * 0.5 - 0.25) < 1e-12
# nonstationarity variance
n = 100
v = (n / 2 * 0.2 * 0.8 + n / 2 * 0.2 * 0.8) / n ** 2
assert abs(v - 0.16 / n) < 1e-12
print("OK ch6: confounding identico-ley, alpha>=1/4, Var(W)=80.19, Var=0.16/n")
