from math import sqrt


def update(a, b, y):
    if y not in (0, 1):
        raise ValueError("Se requiere estado binario confirmado")
    return a + y, b + 1 - y


a, b = 1.0, 1.0
for y in [1] * 12 + [0] * 88:
    a, b = update(a, b, y)
p = a / (a + b)
sd = sqrt(a * b / ((a + b) ** 2 * (a + b + 1)))
c, d = 1.0, 9.0
losses = {"tratar": c * (1 - p), "no_tratar": d * p}
action = min(losses, key=losses.get)
print(f"Posterior Beta({a:.0f},{b:.0f}); p={p:.6f}; SD={sd:.6f}")
print(f"Umbral={c/(c+d):.3f}; accion de dos opciones={action}")
print("Regla adicional SD<=0.03:", action if sd <= 0.03 else "consultar")
assert action == "tratar" and sd > 0.03
