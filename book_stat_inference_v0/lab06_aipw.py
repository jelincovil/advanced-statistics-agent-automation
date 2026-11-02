import numpy as np
from scipy.special import expit
from scipy.stats import norm
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.model_selection import KFold

rng = np.random.default_rng(20261027)
n = 2000
x = rng.uniform(-1, 1, size=n)
X = x[:, None]
e = expit(0.6 * x)
a = rng.binomial(1, e)
m0 = x + x * x
m1 = m0 + 1 + 0.5 * x
y = m0 + a * (1 + 0.5 * x) + rng.normal(size=n)
eh = np.zeros(n)
h0 = np.zeros(n)
h1 = np.zeros(n)
for train, test in KFold(5, shuffle=True, random_state=42).split(X):
    ps = LogisticRegression(C=1e6, max_iter=1000).fit(X[train], a[train])
    eh[test] = ps.predict_proba(X[test])[:, 1]
    for arm, out in [(0, h0), (1, h1)]:
        ix = train[a[train] == arm]
        design = np.column_stack([x[ix], x[ix] ** 2])
        model = LinearRegression().fit(design, y[ix])
        out[test] = model.predict(
            np.column_stack([x[test], x[test] ** 2])
        )
assert np.all((eh > 0) & (eh < 1))
d = h1 - h0 + a * (y - h1) / eh - (1 - a) * (y - h0) / (1 - eh)
se = d.std(ddof=1) / np.sqrt(n)
print(f"ATE verdadero=1; AIPW={d.mean():.6f}; SE={se:.6f}")
print(
    "IC normal 95%:",
    np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
print(
    "Propensiones ajustadas min,max:", np.round([eh.min(), eh.max()], 6)
)
# Identidad poblacional DR comprobada por cuadratura, no por una sola muestra.
z, w = np.polynomial.legendre.leggauss(80)
w = w / 2
true_e = expit(0.6 * z)
t0 = z + z * z
t1 = t0 + 1 + 0.5 * z
for name, ee, u0, u1 in [
    ("ambos correctos", true_e, t0, t1),
    ("solo propension", true_e, np.zeros_like(z), np.zeros_like(z)),
    ("solo resultado", np.full_like(z, 0.5), t0, t1),
    (
        "ambos incorrectos",
        np.full_like(z, 0.5),
        np.zeros_like(z),
        np.zeros_like(z),
    ),
]:
    expected = (
        u1
        - u0
        + true_e * (t1 - u1) / ee
        - (1 - true_e) * (t0 - u0) / (1 - ee)
    )
    print(f"Esperanza AIPW, {name}: {w@expected:.6f}")
