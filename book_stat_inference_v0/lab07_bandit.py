import numpy as np

THETA = np.array([0.1, 0.3, 0.5, 0.7, 0.9])
K = len(THETA)


def run(method, seed, T=2000):
    rng = np.random.default_rng(seed)
    counts = np.zeros(K, int)
    sums = np.zeros(K)
    regret = 0.0
    for t in range(T):
        if method == "TS":
            a = int(np.argmax(rng.beta(1 + sums, 1 + counts - sums)))
        elif method == "UCB1":
            a = (
                t
                if t < K
                else int(
                    np.argmax(
                        sums / counts
                        + np.sqrt(2 * np.log(t + 1) / counts)
                    )
                )
            )
        else:
            a = (
                int(rng.integers(K))
                if rng.random() < 0.1
                else int(np.argmax(sums / np.maximum(counts, 1)))
            )
        y = rng.binomial(1, THETA[a])
        counts[a] += 1
        sums[a] += y
        regret += THETA.max() - THETA[a]  # Incluye las rondas iniciales.
    assert counts.sum() == T
    return regret


if __name__ == "__main__":
    for method in ["TS", "UCB1", "epsilon-greedy"]:
        values = np.array([run(method, 20261027 + j) for j in range(100)])
        print(
            f"{method}: pseudo-regret medio={values.mean():.3f}; MCSE={values.std(ddof=1)/10:.3f}"
        )
    # Una decision restante: Bayes elige la mayor media posterior.
    means = np.array([3 / 4, 5 / 10])
    print("Bayes con una ronda restante:", int(np.argmax(means)))
