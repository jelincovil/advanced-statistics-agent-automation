"""Lab A (cap. 8): optional stopping breaks the fixed-time interval; the
confidence sequence keeps its guarantee.

Stream (single-decision OPE): behavior b uniform over {0,1}; target e = (0.1, 0.9);
reward R ~ Bernoulli(mu_a) with mu = (0.2, 0.8). True value J = 0.74.
Contribution X = W R, W = e(A)/b(A) in {0.2, 1.8}, so X in [0, 1.8] and the
e-process width parameter is d = 2 * 1.8 * 1 = 3.6 (C=1.8, B=1).

Fixed-time object: normal CI recomputed after every t >= BURN_IN (analysts do
not publish one-observation intervals; the check starts at t=BURN_IN — no
degenerate zero-variance intervals). CS object: mixture Hoeffding e-process
over a signed lambda grid, rejected when M_t(c) >= 1/alpha (alpha = 0.05).

Reported: probability, over M runs, that each object ever excludes a center c,
for c = true J (guarantee: CS <= alpha, peeked CI >> alpha) and for a wrong
value J0 = 0.5 (power indicator), each with its Monte Carlo standard error.
numpy only; chunked vectorization; fixed seeds.
"""
import numpy as np

M_RUNS, T, BURN_IN, ALPHA = 4000, 4000, 10, 0.05
TRUE_J, WRONG_J0 = 0.74, 0.5
C, B = 1.8, 1.0
D2_OVER_8 = (2 * C * B) ** 2 / 8
GRID = np.exp(np.linspace(-3.0, 3.0, 121))
Z = 1.959963984540054
CHUNK = 50


def draw(rng, m, n):
    a = rng.integers(0, 2, (m, n))
    r = (rng.random((m, n)) < np.where(a == 1, 0.8, 0.2)).astype(float)
    w = np.where(a == 1, 0.9, 0.1) / 0.5
    return w * r


def peek_ci_ever_excludes(x, center):
    t = np.arange(1, x.shape[1] + 1, dtype=float)
    mean = np.cumsum(x, axis=1) / t
    var = np.maximum(np.cumsum(x * x, axis=1) / t - mean**2, 0.0)
    hit = np.abs(mean - center) > Z * np.sqrt(var / t)
    hit[:, :BURN_IN - 1] = False
    return hit.any(axis=1)


def log_mixture_path(x, center):
    """log-mixture e-process path, shape (m, T), via log-sum-exp."""
    t = np.arange(1, x.shape[1] + 1, dtype=float)
    s = np.cumsum(x - center, axis=1)
    out = np.empty(x.shape, dtype=float)
    for i in range(x.shape[0]):
        part = s[i][:, None] * GRID[None, :] - t[:, None] * GRID[None, :] ** 2 * D2_OVER_8
        mx = part.max(axis=1)
        out[i] = mx + np.log(np.exp(part - mx[:, None]).mean(axis=1))
    return out


def cs_ever_excludes(x, center):
    return (log_mixture_path(x, center) >= np.log(1 / ALPHA)).any(axis=1)


def batch(seed, center):
    rng = np.random.default_rng(seed)
    ci, cs = [], []
    for start in range(0, M_RUNS, CHUNK):
        m = min(CHUNK, M_RUNS - start)
        x = draw(rng, m, T)
        ci.append(peek_ci_ever_excludes(x, center))
        cs.append(cs_ever_excludes(x, center))
    return float(np.concatenate(ci).mean()), float(np.concatenate(cs).mean())


def mcse(p):
    return float(np.sqrt(p * (1 - p) / M_RUNS))


if __name__ == "__main__":
    print(f"runs={M_RUNS}, horizon T={T}, burn-in={BURN_IN}, alpha={ALPHA}, grid {len(GRID)} lambdas")
    for k, (name, c) in enumerate([("c = true value 0.74", TRUE_J), ("c = wrong value 0.50", WRONG_J0)]):
        ci, cs = batch(20261103 + 97 * k, c)
        print(f"{name}: P(peeked fixed-time CI excludes c) = {ci:.4f} (MCSE {mcse(ci):.4f})")
        print(f"{'.' * len(name)}  P(CS excludes c)                   = {cs:.4f} (MCSE {mcse(cs):.4f})")
