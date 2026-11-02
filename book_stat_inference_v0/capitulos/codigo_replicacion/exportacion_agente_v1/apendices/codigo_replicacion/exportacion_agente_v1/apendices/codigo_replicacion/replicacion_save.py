"""Esqueleto de la replicación del estudio de simulación de Shi et al. (Ap. G).

ESTADO: esqueleto (2026-10-13). No contiene definiciones de escenarios ni
resultados: los generadores A/B/C se copian de la fuente primaria antes de
la primera corrida (ver #pendiente de §Escenarios).
Implementación de referencia: SAVE (licencia MIT), commit fijado en
FUENTES.md / REGISTRO_DIARIO.md (2026-10-13).
"""
import math
import numpy as np

N_GRID = (25, 50, 100)        # trayectorias por réplica (def:appG-grid)
T_GRID = (30, 50, 70)         # horizonte (def:appG-grid)
GAMMA = 0.5                   # factor de descuento (def:appG-grid)
N_REPLICAS = None             # por verificar en la fuente primaria
ESCENARIOS = ("A", "B", "C")


def ancho_banda(n: int, T: int) -> int:
    """L = floor((nT)^(3/7)) (def:appG-grid)."""
    return math.floor((n * T) ** (3 / 7))


def generar_datos(escenario: str, n: int, T: int, rng: np.random.Generator):
    """Proceso generador del escenario. Por copiar de la fuente."""
    raise NotImplementedError("Escenarios A/B/C no transcritos (Ap. G §Escenarios)")


def valor_verdadero(escenario: str, gamma: float = GAMMA) -> float:
    """Valor verdadero de la política objetivo (Monte Carlo largo)."""
    raise NotImplementedError


def estimar_ic_save(datos, L: int, gamma: float = GAMMA, alpha: float = 0.05):
    """Llamada a la implementación pública de SAVE (src/AGENT.py)."""
    raise NotImplementedError


def metricas(ics, estimaciones, v_true):
    """ECP, AL y log(MSE) (§Métricas). Definición exacta: por verificar en la fuente."""
    raise NotImplementedError


def correr_celda(escenario: str, n: int, T: int, semilla: int):
    rng = np.random.default_rng(semilla)
    L = ancho_banda(n, T)
    ...  # bucle de réplicas: generar_datos -> estimar_ic_save -> metricas


if __name__ == "__main__":
    for esc in ESCENARIOS:
        for n in N_GRID:
            for T in T_GRID:
                print(esc, n, T, "L =", ancho_banda(n, T))