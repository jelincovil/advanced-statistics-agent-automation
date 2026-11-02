import numpy as np

rng = np.random.default_rng(20261027)
x = rng.binomial(1, 0.3, size=1000)
n = total = 0
online = 0.0
for y in x:
    n += 1
    total += int(y)
    online += (y - online) / n
assert np.isclose(total / n, online) and np.isclose(x.mean(), online)
print(f"n={n}; exitos={total}; media={online:.6f}")
print("Conteos, historial y (n,media) coinciden: OK")
# Un resumen realmente insuficiente: el ultimo dato.
# Estas muestras tienen mismo ultimo dato y razones de verosimilitud distintas.
a = np.array([0, 0, 0, 1])
b = np.array([1, 1, 0, 1])
for theta in [0.2, 0.7]:
    ratio = (theta / (1 - theta)) ** (a.sum() - b.sum())
    print(f"Razón L(a)/L(b) en theta={theta}: {ratio:.6f}")
print("Operaciones suma completa a cada llegada:", n * (n + 1) // 2)
print("Actualizaciones incrementales:", n)
