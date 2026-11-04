"""Lab B (cap. 8): mixture-grid confidence sequence for an OPE value under
designed support: whole-path validity, e-process mean at a stopping time,
and final width. Same stream as Lab A (defined identically there).

For each run: (i) does the path of the center-true mixture e-process ever
cross 1/alpha? (ii) its value at tau = first t where a wrong-center process
crosses (or T) — expectation must be <= 1; (iii) CS width at n = T.
numpy only; chunked vectorization with log-sum-exp; fixed seeds.
"""
import numpy as np

M_RUNS, T, ALPHA = 3000, 3000, 0.05
TRUE_J, C, B = 0.74, 1.8, 1.0
D2_OVER_8 = (2 * C * B) ** 2 / 8
GRID = np.exp(np.linspace(-3.0, 3.0, 81))
CHUNK = 50


def draw(rng, m, n):
    a = rng.integers(0, 2, (m, n))
    r = (rng.random((m, n)) < np.where(a == 1, 0.8, 0.2)).astype(float)
    w = np.where(a == 1, 0.9, 0.1) / 0.5
    return w * r


def log_mixture_path(x, center):
    t = np.arange(1, x.shape[1] + 1, dtype=float)
    s = np.cumsum(x - center, axis=1)
    out = np.empty(x.shape, dtype=float)
    for i in range(x.shape[0]):
        part = s[i][:, None] * GRID[None, :] - t[:, None] * GRID[None, :] ** 2 * D2_OVER_8
        mx = part.max(axis=1)
        out[i] = mx + np.log(np.exp(part - mx[:, None]).mean(axis=1))
    return out


def cs_width_matrix(x, centers):
    """Wide enough centers grid; inside(c) <=> final value of mixture < 1/alpha."""
    logs = np.stack([log_mixture_path(x, c)[:, -1] for c in centers], axis=0)
    inside = logs < np.log(1 / ALPHA)
    lo = centers[inside.any(axis=0)[None, :][0] if False else inside.argmax(axis=0)]
    widths = []
    for j in range(x.shape[0]):
        idx = np.flatnonzero(inside[:, j])
        widths.append(np.nan if len(idx) == 0 else centers[idx[-1]] - centers[idx[0]])
    return np.array(widths)


def run():
    rng = np.random.default_rng(20261111)
    viol, m_tau, widths = [], [], []
    centers = np.linspace(-0.2, 1.4, 65)
    for start in range(0, M_RUNS, CHUNK):
        m = min(CHUNK, M_RUNS - start)
        x = draw(rng, m, T)
        p_true = log_mixture_path(x, TRUE_J)
        p_wrong = log_mixture_path(x, 0.5)
        viol.append((p_true >= np.log(1 / ALPHA)).any(axis=1))
        crosses = np.argmax(p_wrong >= np.log(1 / ALPHA), axis=1)
        hit = (p_wrong >= np.log(1 / ALPHA)).any(axis=1)
        tau = np.where(hit, crosses, T - 1)
        m_tau.append(np.exp(p_true[np.arange(m), tau]))
        widths.append(cs_width_matrix(x, centers))
    viol = np.concatenate(viol)
    m_tau = np.concatenate(m_tau)
    widths = np.concatenate(widths)
    p = viol.mean()
    mcse = np.sqrt(p * (1 - p) / M_RUNS)
    em = m_tau.mean()
    em_se = m_tau.std(ddof=1) / np.sqrt(M_RUNS)
    print(f"runs={M_RUNS}, T={T}, alpha={ALPHA}, grid {len(GRID)} lambdas")
    print(f"P(whole CS path excludes the true value) = {p:.4f} (MCSE {mcse:.4f})  [guarantee: <= {ALPHA}]")
    print(f"E[M_tau] at wrong-center stopping time   = {em:.4f} (MCSE {em_se:.4f})  [must be <= 1]")
    print(f"CS width at n={T}: median {np.nanmedian(widths):.4f}, IQR {np.nanpercentile(widths, [25, 75]).round(4)}")
    assert p <= ALPHA + 0.005 + 2 * mcse, "CS path validity failed"
    assert em <= 1.0 + 3 * em_se, "e-process mean bound failed"


if __name__ == "__main__":
    run()
