"""Ch.7 curse of horizon: exact c and full H table + identity c = 1+(p-b)^2/(b(1-b))."""
import numpy as np

p = 0.8
for b, c_expect in [(0.5, 1.36), (0.2, 3.25), (0.8, 1.0)]:
    c = p**2 / b + (1 - p)**2 / (1 - b)
    assert abs(c - c_expect) < 1e-12 and abs(c - (1 + (p - b) ** 2 / (b * (1 - b)))) < 1e-12
tab = {0.8: [0, 0, 0], 0.5: [0.36, 3.65, 20.65], 0.2: [2.25, 361.59, 131471.10]}
for b, vals in tab.items():
    c = p**2 / b + (1 - p)**2 / (1 - b)
    for H, v_exp in zip([1, 5, 10], vals):
        v = c**H - 1
        assert abs(v - v_exp) / max(v_exp, 1) < 5e-3 or v == 0 == v_exp, (b, H, v, v_exp)
print("OK ch7: c exacto y tabla H=1,5,10")
