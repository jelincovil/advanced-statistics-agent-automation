import numpy as np
import gymnasium as gym
from scipy.special import expit
from scipy.stats import norm

H, GAMMA = 20, 0.99


def target(s):
    p = 0.2 + 0.6 * expit(4 * s[2] + s[3])
    return np.array([1 - p, p])


def collect(n, seed, on_target=False):
    rng = np.random.default_rng(seed)
    env = gym.make("CartPole-v1")
    data = []
    for _ in range(n):
        s, _ = env.reset(seed=int(rng.integers(2**31 - 1)))
        episode = []
        for t in range(H):
            probs = target(s) if on_target else np.array([0.5, 0.5])
            a = int(rng.choice(2, p=probs))
            nxt, r, terminated, truncated, _ = env.step(a)
            end = bool(terminated or truncated or t == H - 1)
            episode.append(
                (s.copy(), a, float(r), nxt.copy(), end, float(probs[a]))
            )
            s = nxt
            if end:
                break
        data.append(episode)
    env.close()
    return data


def features(s, a):
    return np.r_[1.0, s, s * s, float(a), a * s]


def fit_q(train):
    beta = [np.zeros(14) for _ in range(H)]

    def value(t, s):
        if t >= H:
            return 0.0
        return sum(
            target(s)[a] * (features(s, a) @ beta[t]) for a in range(2)
        )

    for t in reversed(range(H)):
        rows = [ep[t] for ep in train if len(ep) > t]
        if not rows:
            raise ValueError(
                "Sin datos de entrenamiento para este tiempo"
            )
        X = np.array([features(s, a) for s, a, r, nxt, end, b in rows])
        y = np.array(
            [
                r + (0 if end else GAMMA * value(t + 1, nxt))
                for s, a, r, nxt, end, b in rows
            ]
        )
        beta[t] = np.linalg.solve(X.T @ X + 0.1 * np.eye(14), X.T @ y)
    return beta


def scores(episode, beta):
    def q(t, s, a):
        return float(features(s, a) @ beta[t]) if t < H else 0.0

    def v(t, s):
        return (
            sum(target(s)[a] * q(t, s, a) for a in range(2))
            if t < H
            else 0.0
        )

    dm = v(0, episode[0][0])
    dr = dm
    w = 1.0
    pdis = 0.0
    ret = 0.0
    for t, (s, a, r, nxt, end, b) in enumerate(episode):
        if not (0 < b <= 1):
            raise ValueError("Propension registrada no valida")
        w *= target(s)[a] / b
        ret += GAMMA**t * r
        pdis += GAMMA**t * w * r
        dr += (
            GAMMA**t
            * w
            * (r + (0 if end else GAMMA * v(t + 1, nxt)) - q(t, s, a))
        )
    return dm, w * ret, pdis, dr, w, ret


def pipeline():
    train = collect(600, 20261027)
    evaluation = collect(1000, 20261028)
    beta = fit_q(train)
    out = np.array([scores(ep, beta) for ep in evaluation])
    for k, name in enumerate(["DM", "IS", "PDIS", "DR"]):
        est = out[:, k].mean()
        se = out[:, k].std(ddof=1) / np.sqrt(len(out))
        print(f"{name}: media={est:.5f}; SE entre episodios={se:.5f}")
    # El SE de DM no contempla el sesgo de aproximacion ni todo el entrenamiento.
    d = out[:, 3]
    se = d.std(ddof=1) / np.sqrt(len(d))
    print(
        "IC DR normal 95%:",
        np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 5),
    )
    w = out[:, 4]
    print(
        f"ESS pesos finales={w.sum()**2/(w@w):.2f}/1000; max={w.max():.3f}"
    )
    # Referencia independiente on-policy: estimacion MC, no verdad exacta.
    reference = collect(5000, 20261029, on_target=True)
    g = np.array(
        [
            sum(GAMMA**t * row[2] for t, row in enumerate(ep))
            for ep in reference
        ]
    )
    print(
        f"Referencia on-policy={g.mean():.5f}; SE={g.std(ddof=1)/np.sqrt(len(g)):.5f}"
    )
    assert np.isfinite(out).all() and np.all(w > 0)
    return {
        "n_evaluation": len(out),
        "horizon": H,
        "dr": float(d.mean()),
        "se": float(se),
    }


if __name__ == "__main__":
    pipeline()
