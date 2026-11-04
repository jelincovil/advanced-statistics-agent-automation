"""Ch.3 Thompson vs Bayes: P(Beta(4,1) > U) = E[Beta(4,1)] = 0.8; predictive 0.74 vs 0.8."""
import numpy as np

rng = np.random.default_rng(7)
x = rng.beta(4, 1, 2_000_000)
y = rng.random(2_000_000)
p = float((x > y).mean())
assert abs(p - 0.8) < 0.002, p
pred_ts = 0.8 * 0.8 + 0.2 * 0.5
assert abs(pred_ts - 0.74) < 1e-12
print("OK ch3: Thompson 0.8 selecta el brazo 1; predictivo 0.74 < 0.8 Bayes")
