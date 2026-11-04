"""Ch.9 policy gradient: baseline variance trio + continuous-state gradient numbers."""
import numpy as np

p = 0.75
grad = p * (1 - p)
assert abs(grad - 0.1875) < 1e-12
v_nob = p * (0 * (1 - p)) ** 2  # placeholder
# contributions: A(A-p): values (1-p)*1 (a=1) subtract var
c1 = (1 - p) * 1.0  # a=1
vals = {1: c1, 0: 0.0}
mean1 = p * c1
v1 = p * (c1 - mean1) ** 2 + (1 - p) * (0 - mean1) ** 2
assert abs(v1 - 0.01171875) < 1e-12
vA = 0.01171875
# baseline b=p: contributions (A-p)*A - ... contribution z*(G-b), G=A
for b, expect in [(0.75, 0.046875), (0.25, 0.0)]:
    cc = {1: (1 - p) * (1 - b), 0: -p * (0 - b)}
    m = p * cc[1] + (1 - p) * cc[0]
    v = p * (cc[1] - m) ** 2 + (1 - p) * (cc[0] - m) ** 2
    assert abs(v - expect) < 1e-9, (b, v, expect)
# continuous state: S uniform [-1,1]
ES2, ES4 = 1 / 3, 1 / 5
grad_c = ES2 / 4
assert abs(grad_c - 1 / 12) < 1e-12
Z = 0.5  # contribution Z = A S^2/2; compute variance analytically: E[A]=.5 indep
# E[Z^2] = E[A]E[S^4]/4 = (1/2)(1/5)/4 = 1/40; E[Z]^2 = (1/2 * ES2/2)^2 = (1/12)^2? careful
EZ = 0.5 * ES2 / 2  # E[A S^2 /2] = E[A] E[S^2] / 2 = (1/2)(1/3)/2 = 1/12 (the gradient)
var0 = 0.5 * ES4 / 4 - EZ ** 2
assert abs(var0 - 13 / 720) < 1e-9, var0
varb = ES4 / 16 - (ES2 / 4) ** 2
assert abs(varb - 1 / 180) < 1e-9, varb
assert abs((var0 - varb) / var0 - 9 / 13) < 1e-9
print("OK ch9: varianzas baseline 0.01171875/0.046875/0; grad 1/12; 13/720 y 1/180 (69.2%)")
