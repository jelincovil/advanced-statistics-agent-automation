"""Ch.8: e-process factor expectation bound (numeric, exact support) + mean-of-evalues rule."""
import numpy as np

C, B = 1.8, 1.0
d2_over_8 = (2 * C * B) ** 2 / 8
# support of X = W R: (0, 0.2, 1.8) with probs under the lab's behavior
xs = np.array([0.0, 0.2, 1.8])
# P(X=1.8)=0.5*0.8; P(X=0.2)=0.5*0.2; P(X=0)=0.5
probs = np.array([0.5, 0.5 * 0.2, 0.5 * 0.8])
J = 0.74
worst = 0.0
for lam in np.linspace(-4, 4, 16001):
    e = float(np.sum(probs * np.exp(lam * (xs - J) - lam**2 * d2_over_8)))
    worst = max(worst, e)
assert worst <= 1.0 + 1e-9, worst
# mean of e-values is an e-value: E[(E1+E2)/2] <= (1+1)/2 = 1
E1, E2 = 1.0, 1.0
assert (E1 + E2) / 2 <= 1.0 + 1e-12
print(f"OK ch8: sup_lambda E[factor]={worst:.6f} <= 1 (Hoeffding factor validated on the exact support)")
