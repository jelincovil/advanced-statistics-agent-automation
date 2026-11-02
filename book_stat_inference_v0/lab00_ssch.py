import numpy as np
from scipy.stats import norm

GAMMA = 0.9
R = np.array(
    [
        [1, 0.9, 0.7, 0.5],
        [0.5, 0.7, 0.6, 0.4],
        [0, 0.3, 0.6, 0.5],
        [-0.5, 0, 0.4, 0.7],
        [-2, -1.5, -0.5, 0.2],
    ]
)
DRIFT = np.array([0.45, 0, -0.45, -0.8])


def model():
    s = np.arange(5)[:, None, None]
    j = np.arange(5)[None, None, :]
    w = np.exp(-np.abs(j - (s + DRIFT[None, :, None])) / 0.7)
    return 0.98 * w / w.sum(axis=2, keepdims=True) + 0.02 / 5


def evaluate(P, pi):
    pp = np.einsum("sa,saj->sj", pi, P)
    rr = (pi * R).sum(axis=1)
    inv = np.linalg.inv(np.eye(5) - GAMMA * pp)
    return inv @ rr, inv


def gradient(P, pi, initial=2):
    v, inv = evaluate(P, pi)
    return (
        GAMMA
        * inv[initial, :, None, None]
        * pi[:, :, None]
        * v[None, None, :]
    )


def delta_variance(P, grad, m):
    return float(
        np.sum(
            (np.sum(P * grad**2, axis=2) - np.sum(P * grad, axis=2) ** 2)
            / m
        )
    )


def main():
    P = model()
    rng = np.random.default_rng(20261027)
    m = 80
    counts = np.array(
        [
            [rng.multinomial(m, P[s, a]) for a in range(4)]
            for s in range(5)
        ]
    )
    phat = counts / m
    policies = [np.eye(4)[np.full(5, a)] for a in range(4)]
    vals = [evaluate(phat, pi)[0][2] for pi in policies]
    true = [evaluate(P, pi)[0][2] for pi in policies]
    g = gradient(phat, policies[2]) - gradient(phat, policies[1])
    se = np.sqrt(delta_variance(phat, g, m))
    diff = vals[2] - vals[1]
    print("Diseno: 80 transiciones independientes por fila; total 1600")
    print("Valores verdaderos desde s3:", np.round(true, 6))
    print("Valores estimados desde s3:", np.round(vals, 6))
    print(f"Diferencia a3-a2={diff:.6f}; SE delta={se:.6f}")
    print(
        "IC normal 95%:",
        np.round(diff + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
    )
    print(f"p unilateral normal={norm.sf(diff/se):.6g}")
    boot = []
    for _ in range(1000):
        pb = np.array(
            [
                [rng.multinomial(m, phat[s, a]) / m for a in range(4)]
                for s in range(5)
            ]
        )
        boot.append(
            evaluate(pb, policies[2])[0][2]
            - evaluate(pb, policies[1])[0][2]
        )
    print(
        "IC bootstrap parametrico 95%:",
        np.round(np.quantile(boot, [0.025, 0.975]), 6),
    )
    # Comprobacion direccional de la derivada, dentro del simplex.
    d = np.zeros_like(P)
    d[2, 2, 0] = 1
    d[2, 2, 1] = -1
    h = 1e-6
    gd = gradient(P, policies[2])
    fd = (
        evaluate(P + h * d, policies[2])[0][2]
        - evaluate(P - h * d, policies[2])[0][2]
    ) / (2 * h)
    assert np.isclose(fd, np.sum(gd * d), rtol=1e-5)
    assert np.allclose(P.sum(axis=2), 1) and np.min(P) > 0
    print("Filas estocasticas y derivada direccional: OK")


if __name__ == "__main__":
    main()
