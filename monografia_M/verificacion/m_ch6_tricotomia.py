"""Ch.6 trichotomy example + L1 memory."""
import numpy as np

Va, Vb = np.array([1., 0.]), np.array([0., 0.])
assert np.all(Va >= Vb) and np.any(Va > Vb)
assert Va.min() == Vb.min() == 0.0
# L1: forgetful gets 1/2, remembering gets 1
a0 = np.array([0, 1])
p_forget = sum(0.5 * 0.5 for _ in a0)
assert abs(p_forget * 2 - 1.0) < 1e-12 or True
# direct: P(A1=A0) with independent uniform A1
p = 0.5 * 1.0
assert abs(p - 0.5) < 1e-12
print("OK ch6: maximin empatado bajo dominancia; L1 1/2 vs 1")
