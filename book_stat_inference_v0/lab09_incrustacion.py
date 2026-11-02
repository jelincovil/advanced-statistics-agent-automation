import numpy as np
from itertools import product

# Experimento finito: theta indexa modelos, x es el estado observado.
theta = np.array([0.2, 0.8])
prior = np.array([0.5, 0.5])
PX = np.array([[0.8, 0.2], [0.2, 0.8]])  # Filas theta; columnas x=0,1.
L = np.array([[0, 1], [3, 0.0]])  # Filas theta; acciones 0,1.
rules = list(product([0, 1], repeat=2))
risks = []
for rule in rules:
    risk = np.array(
        [
            sum(PX[k, x] * L[k, rule[x]] for x in range(2))
            for k in range(2)
        ]
    )
    ret = np.array(
        [
            sum(PX[k, x] * (-L[k, rule[x]]) for x in range(2))
            for k in range(2)
        ]
    )
    assert np.allclose(risk, -ret)
    risks.append(risk)
    print(f"regla={rule}; riesgo={risk}; retorno={ret}")
risks = np.array(risks)
bayes = risks @ prior
best = int(bayes.argmin())
print("Regla Bayes:", rules[best], "; riesgo Bayes:", bayes[best])
assert rules[best] == (0, 1)
# Imagen exacta de un conjunto: objetivo de una accion fijada, no optimizada.
C = np.array([0.25, 0.55])
c = 0.2
print("Imagen por g(theta)=-c*(1-theta):", -c * (1 - C))
print("Todas las reglas enumeradas satisfacen J=-R: OK")
