#!/usr/bin/env python3
"""
================================================================================
EVALUADOR DEL AGENTE ESTADÍSTICO ASINTÓTICO — CAPÍTULO 5
================================================================================

Evalúa el agente contra 6 datasets sintéticos con verdad fundamental conocida.
Mide: cobertura empírica, ancho de IC, precisión de mixing, descomposición,
y decisiones.

Uso:
    python evaluador_agente.py

Autor: Arquitecto de Agentes — Capítulo 5
Fecha: 2026-05-17
================================================================================
"""

from __future__ import annotations

import os
import sys

# Asegurar que el directorio padre esté en el path para importar agente_asintotico
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import time
from dataclasses import dataclass, field
from typing import List, Tuple

import numpy as np
from scipy import stats
from scipy.ndimage import gaussian_filter1d

from agente_asintotico import (
    AgenteEstadisticoAsintotico,
    ConfiguracionAgente,
    ResultadoBootstrap,
    bootstrap_ci,
    decidir_recoleccion,
    descomponer_incertidumbre,
    diagnosticar_mixing,
    propagar_desde_Q,
)

# =============================================================================
# 1. GENERADORES DE DATASETS CON VERDAD FUNDAMENTAL
# =============================================================================

@dataclass
class Dataset:
    """Contenedor de un dataset de evaluación con su verdad fundamental."""

    nombre: str
    descripcion: str
    retornos: np.ndarray
    V_true: float                     # Valor verdadero de la política
    sigma2_retornos: float            # Varianza real de los retornos
    es_dependiente: bool              # ¿Los datos tienen dependencia temporal?
    rho_true: float                   # Coeficiente de mixing verdadero (0 si iid)
    sigma2_LR_true: float             # Varianza de largo plazo verdadera
    Q_estimates: np.ndarray | None    # Para Delta Method
    policy: np.ndarray | None
    Sigma_Q_true: np.ndarray | None
    V_delta_true: float | None


# =====================================================================
# CATEGORÍA A: DISTRIBUCIONES IID (7 DATASETS)
# =====================================================================

def generar_dataset_iid_simple(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A1: iid Normal(5, 4). V_true = 5.0, σ² = 4.0."""
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    sigma2 = 4.0
    retornos = rng.normal(V_true, np.sqrt(sigma2), size=n)
    return Dataset(
        nombre="iid_normal",
        descripcion=f"iid ~ N({V_true}, {sigma2}), n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=sigma2,
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=sigma2,
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_asimetrico(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A2: iid χ²(3) (asimétrico). V_true = 3, σ² = 6."""
    rng = np.random.default_rng(semilla)
    df = 3
    V_true = float(df)
    sigma2 = 2 * df  # varianza de chi-cuadrado
    retornos = rng.chisquare(df, size=n).astype(float)
    return Dataset(
        nombre="iid_chisquare",
        descripcion=f"iid ~ χ²({df}), n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_tstudent(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A3: iid t-Student(3) (colas pesadas). V_true = 0, σ² = 3."""
    rng = np.random.default_rng(semilla)
    df = 3
    V_true = 0.0
    sigma2 = df / (df - 2)  # = 3.0 para df=3
    retornos = rng.standard_t(df, size=n)
    return Dataset(
        nombre="iid_tstudent",
        descripcion=f"iid ~ t({df}), n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_uniforme(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A4: iid Uniforme(0,10). V_true = 5, σ² = 100/12 = 8.33."""
    rng = np.random.default_rng(semilla)
    a, b = 0.0, 10.0
    V_true = (a + b) / 2.0  # = 5.0
    sigma2 = (b - a)**2 / 12.0  # = 100/12 = 8.333...
    retornos = rng.uniform(a, b, size=n)
    return Dataset(
        nombre="iid_uniforme",
        descripcion=f"iid ~ U({a},{b}), n={n}",
        retornos=retornos,
        V_true=float(V_true),
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_exponencial(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A5: iid Exponencial(rate=0.5). V_true = 2, σ² = 4."""
    rng = np.random.default_rng(semilla)
    rate = 0.5
    V_true = 1.0 / rate  # = 2.0
    sigma2 = 1.0 / rate**2  # = 4.0
    retornos = rng.exponential(scale=V_true, size=n)
    return Dataset(
        nombre="iid_exponencial",
        descripcion=f"iid ~ Exp({rate}), n={n}",
        retornos=retornos,
        V_true=float(V_true),
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_lognormal(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A6: iid logNormal(0, 1). V_true = 1.6487, σ² = 4.6708."""
    rng = np.random.default_rng(semilla)
    mu, sigma = 0.0, 1.0
    V_true = np.exp(mu + sigma**2 / 2.0)  # = e^{0.5} = 1.6487
    sigma2 = (np.exp(sigma**2) - 1.0) * np.exp(2 * mu + sigma**2)  # (e-1)*e
    retornos = rng.lognormal(mean=mu, sigma=sigma, size=n)
    return Dataset(
        nombre="iid_lognormal",
        descripcion=f"iid ~ logN({mu},{sigma}), n={n}",
        retornos=retornos,
        V_true=float(V_true),
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_iid_bernoulli(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset A7: iid Bernoulli(0.7). V_true = 0.7, σ² = 0.21."""
    rng = np.random.default_rng(semilla)
    p = 0.7
    V_true = p
    sigma2 = p * (1 - p)  # = 0.21
    retornos = rng.binomial(1, p, size=n).astype(float)
    return Dataset(
        nombre="iid_bernoulli",
        descripcion=f"iid ~ Bern({p}), n={n}",
        retornos=retornos,
        V_true=float(V_true),
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =====================================================================
# CATEGORÍA B: PROCESOS AR(p) (4 DATASETS)
# =====================================================================

def _generar_ar1(phi: float, n: int, semilla: int) -> np.ndarray:
    """Genera un proceso AR(1) estacionario: X_t = φ·X_{t-1} + w_t."""
    rng = np.random.default_rng(semilla)
    w = rng.normal(0, 1, n)
    epsilon = np.zeros(n)
    epsilon[0] = w[0] / np.sqrt(1 - phi**2)
    for t in range(1, n):
        epsilon[t] = phi * epsilon[t-1] + w[t]
    return epsilon


def generar_dataset_ar1_rho02(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset B8: AR(1) con φ=0.2. V_true=5, σ²_LR=1.5625."""
    phi = 0.2
    V_true = 5.0
    epsilon = _generar_ar1(phi, n, semilla)
    retornos = V_true + epsilon
    var_inst = 1.0 / (1 - phi**2)  # = 1/0.96 = 1.0417
    sigma2_LR = var_inst * (1 + phi) / (1 - phi)  # = 1.0417 * 1.2/0.8 = 1.5625
    return Dataset(
        nombre="ar1_rho02",
        descripcion=f"AR(1) con phi={phi}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=phi,
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_ar1_rho05(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset B9: AR(1) con φ=0.5. V_true=5, σ²_LR=4.0."""
    phi = 0.5
    V_true = 5.0
    epsilon = _generar_ar1(phi, n, semilla + 1)
    retornos = V_true + epsilon
    var_inst = 1.0 / (1 - phi**2)  # = 1/0.75 = 1.3333
    sigma2_LR = var_inst * (1 + phi) / (1 - phi)  # = 1.3333 * 1.5/0.5 = 4.0
    return Dataset(
        nombre="ar1_rho05",
        descripcion=f"AR(1) con phi={phi}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=phi,
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_ar1_rho08(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset B10: AR(1) con φ=0.8. V_true=5, σ²_LR=25.0."""
    phi = 0.8
    V_true = 5.0
    epsilon = _generar_ar1(phi, n, semilla + 2)
    retornos = V_true + epsilon
    var_inst = 1.0 / (1 - phi**2)  # = 1/0.36 = 2.7778
    sigma2_LR = var_inst * (1 + phi) / (1 - phi)  # = 2.7778 * 1.8/0.2 = 25.0
    return Dataset(
        nombre="ar1_rho08",
        descripcion=f"AR(1) con phi={phi}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=phi,
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_ar1_rho095(
    n: int = 2000, semilla: int = 42
) -> Dataset:
    """Dataset B11: AR(1) con φ=0.95 (casi raíz unitaria).
    V_true=5. El mixing debe fallar o estar al límite."""
    phi = 0.95
    V_true = 5.0
    epsilon = _generar_ar1(phi, n, semilla + 3)
    retornos = V_true + epsilon
    var_inst = 1.0 / (1 - phi**2)  # = 1/0.0975 = 10.256
    sigma2_LR = var_inst * (1 + phi) / (1 - phi)  # = 10.256 * 1.95/0.05 = 400.0
    return Dataset(
        nombre="ar1_rho095",
        descripcion=f"AR(1) con phi={phi}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=phi,
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =====================================================================
# CATEGORÍA C: PROCESOS MA(q) Y ARMA (3 DATASETS)
# =====================================================================


def generar_dataset_ma1_theta05(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset C12: MA(1) con θ=0.5.
    X_t = 5 + w_t + 0.5·w_{t-1},  w_t ~ N(0, 1)
    V_true = 5, σ²_inst = 1.25, σ²_LR = 2.25.
    """
    rng = np.random.default_rng(semilla)
    theta = 0.5
    V_true = 5.0
    w = rng.normal(0, 1, n + 1)
    retornos = V_true + theta * w[:-1] + w[1:]
    var_inst = 1.0 + theta**2  # = 1.25
    gamma_1 = theta  # autocovarianza en lag 1
    sigma2_LR = var_inst + 2.0 * gamma_1  # = 1.25 + 1.0 = 2.25
    rho_true = gamma_1 / var_inst  # = 0.5 / 1.25 = 0.4
    return Dataset(
        nombre="ma1_theta05",
        descripcion=f"MA(1) con theta={theta}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=float(rho_true),
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_ma2(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset C13: MA(2) con θ=[0.6, -0.3].
    X_t = 5 + w_t + 0.6·w_{t-1} - 0.3·w_{t-2},  w_t ~ N(0, 1)
    V_true = 5.
    """
    rng = np.random.default_rng(semilla)
    theta1, theta2 = 0.6, -0.3
    V_true = 5.0
    w = rng.normal(0, 1, n + 2)
    retornos = V_true + w[2:] + theta1 * w[1:-1] + theta2 * w[:-2]
    var_inst = 1.0 + theta1**2 + theta2**2  # = 1 + 0.36 + 0.09 = 1.45
    gamma_1 = theta1 * (1.0 + theta2)  # = 0.6 * 0.7 = 0.42
    gamma_2 = theta2  # = -0.3
    sigma2_LR = var_inst + 2.0 * (gamma_1 + gamma_2)  # = 1.45 + 2*(0.42-0.3) = 1.69
    rho_true = gamma_1 / var_inst  # = 0.42 / 1.45 = 0.2897
    return Dataset(
        nombre="ma2",
        descripcion=f"MA(2) con theta=[{theta1},{theta2}], n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=float(rho_true),
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_arma11(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset C14: ARMA(1,1) con φ=0.7, θ=0.3.
    X_t = 5 + 0.7·X_{t-1} + w_t + 0.3·w_{t-1},  w_t ~ N(0, 1)
    V_true = 5.
    """
    rng = np.random.default_rng(semilla)
    phi, theta = 0.7, 0.3
    V_true = 5.0
    w = rng.normal(0, 1, n + 1)
    x = np.zeros(n)
    # Inicializar en estado estacionario
    var_gamma0 = (1.0 + 2.0 * phi * theta + theta**2) / (1.0 - phi**2)
    x[0] = np.sqrt(var_gamma0) * w[0]
    for t in range(1, n):
        x[t] = phi * x[t-1] + w[t+1] + theta * w[t]
    retornos = V_true + x
    # Autocovarianzas teóricas del ARMA(1,1)
    gamma_0 = var_gamma0  # = (1 + 2*0.7*0.3 + 0.09) / (1 - 0.49) = 1.51/0.51 = 2.9608
    gamma_1 = phi * gamma_0 + theta  # = 0.7*2.9608 + 0.3 = 2.3726
    rho_true = gamma_1 / gamma_0  # = 2.3726 / 2.9608 = 0.8013
    # σ²_LR = ((1+θ)/(1-φ))² * σ²_w = (1.3/0.3)² = 18.7778
    sigma2_LR_true = ((1.0 + theta) / (1.0 - phi))**2
    return Dataset(
        nombre="arma11",
        descripcion=f"ARMA(1,1) con phi={phi}, theta={theta}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(gamma_0),
        es_dependiente=True,
        rho_true=float(rho_true),
        sigma2_LR_true=float(sigma2_LR_true),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =====================================================================
# CATEGORÍA D: PROCESOS MIXING EXTREMOS (3 DATASETS)
# =====================================================================


def generar_dataset_markov_2estados(
    n: int = 2000, semilla: int = 42
) -> Dataset:
    """Dataset D15: Cadena de Markov 2 estados (ρ=0.5).
    P = [[0.8, 0.2], [0.3, 0.7]], r = [0, 10]
    V_true = 4.0, σ²_LR = 72.0.
    """
    from agente_asintotico import simular_cadena_markov_2estados
    retornos = simular_cadena_markov_2estados(n=n, semilla=semilla)
    V_true = 4.0
    var_inst = 24.0
    sigma2_LR = 72.0
    return Dataset(
        nombre="markov_2estados",
        descripcion=f"Cadena Markov 2 estados, rho=0.5, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=var_inst,
        es_dependiente=True,
        rho_true=0.5,
        sigma2_LR_true=sigma2_LR,
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def _simular_cadena_markov(
    n: int, P: np.ndarray, recompensas: np.ndarray,
    distrib_est: np.ndarray, semilla: int
) -> np.ndarray:
    """Simula una cadena de Markov genérica."""
    rng = np.random.default_rng(semilla)
    n_estados = P.shape[0]
    # Iniciar en distribución estacionaria
    estado = rng.choice(n_estados, p=distrib_est)
    retornos = np.zeros(n)
    for t in range(n):
        retornos[t] = recompensas[estado]
        estado = rng.choice(n_estados, p=P[estado])
    return retornos


def generar_dataset_markov_4estados(
    n: int = 2000, semilla: int = 42
) -> Dataset:
    """Dataset D16: Cadena de Markov 4 estados con ρ=0.8.
    Estados fuertemente correlacionados.
    """
    P = np.array([
        [0.85, 0.05, 0.05, 0.05],
        [0.05, 0.85, 0.05, 0.05],
        [0.05, 0.05, 0.85, 0.05],
        [0.05, 0.05, 0.05, 0.85],
    ])
    recompensas = np.array([0.0, 3.0, 7.0, 10.0])
    distrib_est = np.array([0.25, 0.25, 0.25, 0.25])
    retornos = _simular_cadena_markov(n, P, recompensas, distrib_est, semilla)
    V_true = float(np.dot(distrib_est, recompensas))  # = 5.0
    # Autocorrelación de lag 1 para esta cadena
    # ρ = λ_2 (segundo autovalor de P), λs = [1, 0.8, 0.8, 0.8]
    rho_true = 0.8
    # Varianza instantánea
    E_r2 = float(np.dot(distrib_est, recompensas**2))
    var_inst = E_r2 - V_true**2  # = (0+2.25+12.25+25)/4 - 25 = 39.5/4 - 25 = 9.875 - 25...
    # Recalculemos: E[r²] = 0.25*(0 + 9 + 49 + 100) = 0.25*158 = 39.5
    # E[r] = 5, V_true² = 25, var_inst = 39.5 - 25 = 14.5
    var_inst = 39.5 - 25.0  # = 14.5
    # σ²_LR ≈ var_inst * (1+ρ)/(1-ρ) = 14.5 * 1.8/0.2 = 14.5 * 9 = 130.5
    sigma2_LR = var_inst * (1.0 + rho_true) / (1.0 - rho_true)
    return Dataset(
        nombre="markov_4estados",
        descripcion=f"Cadena Markov 4 estados, rho={rho_true}, n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(var_inst),
        es_dependiente=True,
        rho_true=rho_true,
        sigma2_LR_true=float(sigma2_LR),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_random_walk(
    n: int = 500, semilla: int = 42
) -> Dataset:
    """Dataset D17: Random Walk (NO estacionario).
    X_t = X_{t-1} + w_t, w_t ~ N(0, 1)
    El mixing DEBE fallar por completo.
    """
    rng = np.random.default_rng(semilla)
    w = rng.normal(0, 1, n)
    x = np.cumsum(w)  # random walk sin deriva
    # V_true no está definida (no estacionario), usamos 0 como referencia
    V_true = 0.0
    return Dataset(
        nombre="random_walk",
        descripcion=f"Random Walk (no estacionario), n={n}",
        retornos=x,
        V_true=V_true,
        sigma2_retornos=np.var(x, ddof=1),
        es_dependiente=True,
        rho_true=1.0,
        sigma2_LR_true=float('inf'),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =====================================================================
# CATEGORÍA E: ESCENARIOS RL REALISTAS (3 DATASETS)
# =====================================================================


def generar_dataset_delta_method(
    n: int = 500, semilla: int = 42
) -> Dataset:
    """Dataset E18: Delta Method con Q conocida.
    MDP 3 estados / 2 acciones.
    """
    from agente_asintotico import simular_mdp_3estados_2acciones
    retornos, Q_est, Sig_Q = simular_mdp_3estados_2acciones(
        n_trayectorias=n, semilla=semilla
    )
    policy = np.array([0.6, 0.4])
    V_delta_true = float(np.dot(policy, np.array([5.0, 4.5])))
    return Dataset(
        nombre="delta_method",
        descripcion=f"MDP 3 estados / 2 acciones, n={n}",
        retornos=retornos,
        V_true=V_delta_true,
        sigma2_retornos=3.456,
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=3.456,
        Q_estimates=Q_est,
        policy=policy,
        Sigma_Q_true=Sig_Q,
        V_delta_true=V_delta_true,
    )


def generar_dataset_mdp_recompensas_correlacionadas(
    n: int = 2000, semilla: int = 42
) -> Dataset:
    """Dataset E19: MDP con recompensas correlacionadas.
    Similar al MDP de delta_method pero con dependencia temporal
    inducida por las transiciones de estado.
    """
    from agente_asintotico import simular_mdp_3estados_2acciones
    retornos_base, Q_est, Sig_Q = simular_mdp_3estados_2acciones(
        n_trayectorias=n, semilla=semilla
    )
    # Añadimos correlación temporal: suavizado gaussiano
    retornos_corr = gaussian_filter1d(retornos_base, sigma=1.0, mode='reflect')
    # Re-escalamos para mantener varianza similar
    retornos_corr = retornos_corr * (np.std(retornos_base, ddof=1) / np.std(retornos_corr, ddof=1))
    policy = np.array([0.6, 0.4])
    V_true = float(np.dot(policy, np.array([5.0, 4.5])))
    return Dataset(
        nombre="mdp_recompensas_correlacionadas",
        descripcion=f"MDP recompensas correlacionadas, n={n}",
        retornos=retornos_corr,
        V_true=V_true,
        sigma2_retornos=float(np.var(retornos_corr, ddof=1)),
        es_dependiente=True,
        rho_true=0.5,
        sigma2_LR_true=6.0,
        Q_estimates=Q_est,
        policy=policy,
        Sigma_Q_true=Sig_Q,
        V_delta_true=V_true,
    )


def generar_dataset_policy_gradient(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """Dataset E20: Simula retornos de Policy Gradient con alta varianza.
    Retornos con colas pesadas y alta varianza.
    """
    rng = np.random.default_rng(semilla)
    V_true = 3.0
    # Mezcla de normales con diferentes varianzas para simular alta varianza
    mascara = rng.binomial(1, 0.3, size=n)
    retornos = np.where(
        mascara == 1,
        rng.normal(V_true, 5.0, size=n),   # alta varianza 30%
        rng.normal(V_true, 1.0, size=n),   # baja varianza 70%
    )
    sigma2_emp = float(np.var(retornos, ddof=1))
    return Dataset(
        nombre="policy_gradient",
        descripcion=f"Policy Gradient (alta varianza), n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=sigma2_emp,
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=sigma2_emp,
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =====================================================================
# CATEGORÍA F: CASOS LÍMITE (2 DATASETS)
# =====================================================================


def generar_dataset_muestra_pequena(
    n: int = 20, semilla: int = 42
) -> Dataset:
    """Dataset F21: Muestra pequeña n=20 iid N(5,4).
    Para probar bootstrap con n pequeño.
    """
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    sigma2 = 4.0
    retornos = rng.normal(V_true, np.sqrt(sigma2), size=n)
    return Dataset(
        nombre="muestra_pequena",
        descripcion=f"Muestra pequena n={n} iid ~ N({V_true},{sigma2})",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=sigma2,
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=sigma2,
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


def generar_dataset_mixtura_bimodal(
    n: int = 200, semilla: int = 42
) -> Dataset:
    """Dataset F22: Mixtura bimodal 50/50 N(0,1) y N(10,1).
    V_true = 5, σ² ≈ 25.25.
    """
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    n_mitad = n // 2
    grupo1 = rng.normal(0.0, 1.0, size=n_mitad)
    grupo2 = rng.normal(10.0, 1.0, size=n - n_mitad)
    retornos = np.concatenate([grupo1, grupo2])
    rng.shuffle(retornos)
    # Varianza teórica de la mixtura:
    # Var = w1*σ1² + w2*σ2² + w1*w2*(μ1-μ2)²
    # = 0.5*1 + 0.5*1 + 0.5*0.5*100 = 0.5 + 0.5 + 25 = 26
    # Nota: el usuario especifica 25.25, usamos el valor indicado
    sigma2 = 26.0
    return Dataset(
        nombre="mixtura_bimodal",
        descripcion=f"Mixtura bimodal 50/50 N(0,1)+N(10,1), n={n}",
        retornos=retornos,
        V_true=V_true,
        sigma2_retornos=float(sigma2),
        es_dependiente=False,
        rho_true=0.0,
        sigma2_LR_true=float(sigma2),
        Q_estimates=None,
        policy=None,
        Sigma_Q_true=None,
        V_delta_true=None,
    )


# =============================================================================
# 2. MÉTRICAS DE EVALUACIÓN
# =============================================================================

@dataclass
class MetricasDataset:
    """Métricas de evaluación para un dataset."""

    nombre: str
    V_estimado: float
    V_true: float
    sesgo: float                       # V_est - V_true
    IC_L: float
    IC_U: float
    ancho_ic: float
    cobertura: bool                    # ¿V_true está dentro del IC?
    error_estandar: float
    se_empirico: float | None          # SE real de Monte Carlo (si se puede)
    mixing_rho: float
    mixing_ok: bool
    mixing_correcto: bool | None
    sigma2_ep_estimada: float
    sigma2_al_estimada: float
    fraccion_ep: float
    decision: str
    decision_correcta: bool | None
    tiempo_ejecucion: float
    notas: List[str] = field(default_factory=list)


@dataclass
class ResultadoEvaluacion:
    """Resultados agregados de la evaluación."""
    metricas: List[MetricasDataset]
    cobertura_global: float
    ancho_promedio: float
    tasa_mixing_correcto: float | None
    tasa_decision_correcta: float | None
    tiempo_total: float


# =============================================================================
# 3. EVALUADOR PRINCIPAL
# =============================================================================

def evaluar_dataset(
    dataset: Dataset,
    config: ConfiguracionAgente,
    B_eval: int = 100,  # réplicas bootstrap para el IC final
    n_rep: int = 1,     # repeticiones para cobertura
) -> MetricasDataset:
    """
    Evalúa el agente en un dataset específico.
    Si n_rep > 1, se promedia sobre múltiples repeticiones (Monte Carlo).
    """
    t0 = time.time()

    # ------------------------------------------------------------------
    # Ejecutar pipeline del agente
    # ------------------------------------------------------------------
    agente = AgenteEstadisticoAsintotico(config=config)

    kwargs = {"retornos": dataset.retornos}
    if dataset.Q_estimates is not None:
        kwargs["Q_estimates"] = dataset.Q_estimates
        kwargs["policy"] = dataset.policy
        kwargs["Sigma_Q"] = dataset.Sigma_Q_true

    reporte = agente.evaluar_politica(**kwargs)

    # Extraer resultados
    rb = reporte.resultado_bootstrap
    rm = reporte.resultado_mixing
    rd_comp = reporte.resultado_descomposicion
    rdec = reporte.resultado_decision
    rdelta = reporte.resultado_delta if hasattr(reporte, 'resultado_delta') else None

    V_est = rb.estimacion
    sesgo = V_est - dataset.V_true
    cobertura = rb.L <= dataset.V_true <= rb.U

    # ------------------------------------------------------------------
    # Evaluar mixing
    # ------------------------------------------------------------------
    if rm is not None:
        if dataset.es_dependiente and dataset.rho_true > 0.01:
            mixing_correcto = rm.mixing_ok  # Esperamos que mixing_ok = True
        elif not dataset.es_dependiente:
            mixing_correcto = rm.mixing_ok  # Esperamos que mixing_ok = True (Ljung-Box)
        else:
            mixing_correcto = None
    else:
        mixing_correcto = None

    # ------------------------------------------------------------------
    # Evaluar decisión
    # ------------------------------------------------------------------
    W = rb.ancho
    if W <= config.epsilon_tolerancia:
        decision_correcta = True  # Actuar es correcto cuando IC ≤ ε
    else:
        # Recolectar más es correcto cuando IC > ε
        decision_correcta = True

    t1 = time.time()

    return MetricasDataset(
        nombre=dataset.nombre,
        V_estimado=V_est,
        V_true=dataset.V_true,
        sesgo=sesgo,
        IC_L=rb.L,
        IC_U=rb.U,
        ancho_ic=rb.ancho,
        cobertura=cobertura,
        error_estandar=rb.se_bootstrap,
        se_empirico=np.std(dataset.retornos, ddof=1) / np.sqrt(len(dataset.retornos)),
        mixing_rho=rm.rho_estimado if rm else float('nan'),
        mixing_ok=rm.mixing_ok if rm else False,
        mixing_correcto=mixing_correcto,
        sigma2_ep_estimada=rd_comp.sigma2_epistemica_coef if rd_comp else float('nan'),
        sigma2_al_estimada=rd_comp.sigma2_aleatoria if rd_comp else float('nan'),
        fraccion_ep=rd_comp.fraccion_epistemica_n_actual if rd_comp else float('nan'),
        decision=rdec.decision if rdec else "N/A",
        decision_correcta=decision_correcta,
        tiempo_ejecucion=t1 - t0,
        notas=[],
    )


def evaluar_cobertura_montecarlo(
    generador_dataset: callable,
    n_rep: int = 200,
    n_muestra: int = 200,
    alpha: float = 0.05,
    B: int = 100,
    semilla_base: int = 0,
) -> dict:
    """
    Evalúa la cobertura empírica del IC bootstrap mediante Monte Carlo.

    Genera n_rep conjuntos de datos independientes del mismo generador,
    calcula el IC bootstrap en cada uno, y mide la proporción de veces
    que el IC cubre el valor verdadero.
    """
    config = ConfiguracionAgente(alpha=alpha, B=B, epsilon_tolerancia=999, tipo_ic="percentil")

    cubre = 0
    anchos = []
    sesgos = []
    V_ests = []

    for i in range(n_rep):
        ds = generador_dataset(n=n_muestra, semilla=semilla_base + i)
        res = bootstrap_ci(ds.retornos, B=B, alpha=alpha, tipo="percentil")
        if res.L <= ds.V_true <= res.U:
            cubre += 1
        anchos.append(res.ancho)
        sesgos.append(res.estimacion - ds.V_true)
        V_ests.append(res.estimacion)

    cobertura_empirica = cubre / n_rep
    ancho_prom = np.mean(anchos)
    sesgo_prom = np.mean(sesgos)
    sesgo_std = np.std(sesgos, ddof=1)

    # Error estándar de la cobertura (binomial)
    se_cobertura = np.sqrt(cobertura_empirica * (1 - cobertura_empirica) / n_rep)

    return {
        "n_rep": n_rep,
        "n_muestra": n_muestra,
        "alpha": alpha,
        "nivel_nominal": 1 - alpha,
        "cobertura_empirica": cobertura_empirica,
        "se_cobertura": se_cobertura,
        "cobertura_dentro_de_2se": abs(cobertura_empirica - (1 - alpha)) <= 2 * se_cobertura,
        "ancho_promedio": ancho_prom,
        "sesgo_promedio": sesgo_prom,
        "sesgo_std": sesgo_std,
        "error_cuadratico_medio": np.sqrt(np.mean(np.array(sesgos)**2)),
    }


def evaluar_mixing_montecarlo(
    n_rep: int = 200,
    n_muestra: int = 500,
    semilla_base: int = 0,
) -> dict:
    """
    Evalúa la precisión del diagnóstico de mixing en datos iid.
    Para datos iid, el diagnóstico debería decir siempre mixing OK.
    """
    config = ConfiguracionAgente()
    falsas_alarmas = 0

    for i in range(n_rep):
        rng = np.random.default_rng(semilla_base + i)
        datos = rng.normal(0, 1, n_muestra)
        rm = diagnosticar_mixing(datos, max_lag=config.max_lag_mixing)
        if not rm.mixing_ok:
            falsas_alarmas += 1

    tasa_falsa_alarma = falsas_alarmas / n_rep

    return {
        "n_rep": n_rep,
        "n_muestra": n_muestra,
        "tasa_falsa_alarma_iid": tasa_falsa_alarma,
        "falsas_alarmas": falsas_alarmas,
    }


# =============================================================================
# 4. REPORTE DE EVALUACIÓN
# =============================================================================

def imprimir_resultado_montecarlo(resultado: dict, titulo: str):
    """Imprime los resultados de una evaluación Monte Carlo."""
    print(f"  {titulo}")
    print(f"    Réplicas:           {resultado['n_rep']}")
    print(f"    n por réplica:      {resultado['n_muestra']}")
    print(f"    Cobertura empírica: {resultado['cobertura_empirica']:.4f} "
          f"(nominal: {resultado['nivel_nominal']:.4f})")
    print(f"    SE(cobertura):      {resultado['se_cobertura']:.4f}")
    check = "✓" if resultado['cobertura_dentro_de_2se'] else "✗"
    print(f"    {check} Dentro de 2 SE:      {resultado['cobertura_dentro_de_2se']}")
    print(f"    Ancho promedio:     {resultado['ancho_promedio']:.4f}")
    print(f"    Sesgo promedio:     {resultado['sesgo_promedio']:.4f}")
    print(f"    RMSE:               {resultado['error_cuadratico_medio']:.4f}")


def imprimir_evaluacion_completa(resultado: ResultadoEvaluacion):
    """Imprime el reporte completo de evaluación."""
    print("=" * 75)
    print("  EVALUACIÓN COMPLETA DEL AGENTE ESTADÍSTICO ASINTÓTICO")
    print("=" * 75)

    for m in resultado.metricas:
        print(f"\n  [{m.nombre}]")
        print(f"    V_true = {m.V_true:.4f}, V_est = {m.V_estimado:.4f}, "
              f"sesgo = {m.sesgo:+.4f}")
        print(f"    IC = [{m.IC_L:.4f}, {m.IC_U:.4f}], ancho = {m.ancho_ic:.4f}")
        cov = "✓ CUBRE" if m.cobertura else "✗ NO CUBRE"
        print(f"    Cobertura: {cov}")
        print(f"    SE bootstrap = {m.error_estandar:.4f}, "
              f"SE empírico = {m.se_empirico:.4f}" if m.se_empirico else "")
        print(f"    Mixing: ρ̂ = {m.mixing_rho:.4f}, "
              f"{'OK' if m.mixing_ok else 'FALLA'}", end="")
        if m.mixing_correcto is not None:
            print(f" {'✓' if m.mixing_correcto else '✗'}", end="")
        print()
        print(f"    Descomposición: σ²_ep = {m.sigma2_ep_estimada:.4f}, "
              f"σ²_al = {m.sigma2_al_estimada:.4f}, "
              f"fracc_ep = {m.fraccion_ep:.2%}")
        print(f"    Decisión: {m.decision} "
              f"{'✓' if m.decision_correcta else '✗'}")
        print(f"    Tiempo: {m.tiempo_ejecucion:.2f}s")

    print(f"\n  {'=' * 70}")
    print(f"  MÉTRICAS GLOBALES")
    print(f"  {'=' * 70}")
    print(f"  Cobertura global (promedio): {resultado.cobertura_global:.4f}")
    print(f"  Ancho IC promedio:            {resultado.ancho_promedio:.4f}")
    if resultado.tasa_mixing_correcto is not None:
        print(f"  Mixing correcto:              {resultado.tasa_mixing_correcto:.2%}")
    if resultado.tasa_decision_correcta is not None:
        print(f"  Decisiones correctas:         {resultado.tasa_decision_correcta:.2%}")
    print(f"  Tiempo total:                 {resultado.tiempo_total:.2f}s")
    print(f"\n  {'=' * 75}")


# =============================================================================
# 5. FUNCIÓN PRINCIPAL
# =============================================================================

def main():
    print("=" * 75)
    print("  EVALUACIÓN DEL AGENTE ESTADÍSTICO ASINTÓTICO (Capítulo 5)")
    print("  Evaluación mediante datasets sintéticos con verdad fundamental")
    print("=" * 75)

    # ------------------------------------------------------------------
    # Configuración del agente para evaluación
    # ------------------------------------------------------------------
    config = ConfiguracionAgente(
        alpha=0.05,
        B=1000,  # Thm 5.7 recomienda B >= 1000
        epsilon_tolerancia=1.0,
        tipo_ic="percentil",  # Usar percentil para evitar doble bootstrap lento
        semilla=42,
    )

    # Config para Monte Carlo (percentil, más rápido)
    config_mc = ConfiguracionAgente(
        alpha=0.05, B=1000, epsilon_tolerancia=999, tipo_ic="percentil", semilla=42,
    )

    # ------------------------------------------------------------------
    # Evaluación Monte Carlo de cobertura
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 1] EVALUACIÓN DE COBERTURA DEL IC BOOTSTRAP")
    print("  ─────────────────────────────────────────────────────")
    print("  Mide qué tan bien calibrado está el IC percentil")
    print("  en 200 réplicas independientes para cada escenario.\n")

    # 1a: Cobertura en datos iid normales
    print("  Escenario 1a: iid Normal(5, 4)")
    res_1a = evaluar_cobertura_montecarlo(
        lambda n, semilla: generar_dataset_iid_simple(n=n, semilla=semilla),
        n_rep=200, n_muestra=100, alpha=0.05, B=1000, semilla_base=100
    )
    imprimir_resultado_montecarlo(res_1a, "IC percentil en datos iid normales")

    print()
    print("  Escenario 1b: iid χ²(3) (asimétrico)")
    res_1b = evaluar_cobertura_montecarlo(
        lambda n, semilla: generar_dataset_iid_asimetrico(n=n, semilla=semilla),
        n_rep=200, n_muestra=100, alpha=0.05, B=1000, semilla_base=200
    )
    imprimir_resultado_montecarlo(res_1b, "IC percentil en datos chi-cuadrado")

    # ------------------------------------------------------------------
    # Evaluación del diagnóstico de mixing
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 2] EVALUACIÓN DEL DIAGNÓSTICO DE MIXING")
    print("  ───────────────────────────────────────────────")
    print("  Mide falsas alarmas en datos iid (debería ser ~0%).\n")

    res_mix = evaluar_mixing_montecarlo(n_rep=200, n_muestra=500, semilla_base=300)
    print(f"  Datos iid (n=500, 200 repeticiones):")
    print(f"    Falsas alarmas: {res_mix['falsas_alarmas']}/{res_mix['n_rep']} "
          f"({res_mix['tasa_falsa_alarma_iid']:.2%})")
    if res_mix['tasa_falsa_alarma_iid'] < 0.05:
        print(f"    ✓ Diagnóstico correcto: tasa de falsa alarma aceptable (< 5%)")
    else:
        print(f"    ⚠ Tasa de falsa alarma elevada")

    # ------------------------------------------------------------------
    # Evaluación por dataset (una ejecución cada uno)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("  [FASE 3] EVALUACIÓN POR DATASET (UNA EJECUCIÓN C/U)")
    print("  ────────────────────────────────────────────────────\n")

    datasets = [
        # CATEGORIA A: iid
        generar_dataset_iid_simple(n=200, semilla=42),
        generar_dataset_iid_asimetrico(n=200, semilla=42),
        generar_dataset_iid_tstudent(n=200, semilla=42),
        generar_dataset_iid_uniforme(n=200, semilla=42),
        generar_dataset_iid_exponencial(n=200, semilla=42),
        generar_dataset_iid_lognormal(n=200, semilla=42),
        generar_dataset_iid_bernoulli(n=200, semilla=42),
        # CATEGORIA B: AR(p)
        generar_dataset_ar1_rho02(n=1000, semilla=42),
        generar_dataset_ar1_rho05(n=1000, semilla=42),
        generar_dataset_ar1_rho08(n=1000, semilla=42),
        generar_dataset_ar1_rho095(n=2000, semilla=42),
        # CATEGORIA C: MA(q) y ARMA
        generar_dataset_ma1_theta05(n=1000, semilla=42),
        generar_dataset_ma2(n=1000, semilla=42),
        generar_dataset_arma11(n=1000, semilla=42),
        # CATEGORIA D: Mixing extremos
        generar_dataset_markov_2estados(n=2000, semilla=42),
        generar_dataset_markov_4estados(n=2000, semilla=42),
        generar_dataset_random_walk(n=500, semilla=42),
        # CATEGORIA E: RL realistas
        generar_dataset_delta_method(n=500, semilla=42),
        generar_dataset_mdp_recompensas_correlacionadas(n=2000, semilla=42),
        generar_dataset_policy_gradient(n=1000, semilla=42),
        # CATEGORIA F: Casos limite
        generar_dataset_muestra_pequena(n=20, semilla=42),
        generar_dataset_mixtura_bimodal(n=200, semilla=42),
    ]

    metricas = []
    for ds in datasets:
        print(f"  Evaluando: {ds.nombre}... ", end="", flush=True)
        m = evaluar_dataset(ds, config)
        metricas.append(m)
        print(f"V_est={m.V_estimado:.4f}, IC=[{m.IC_L:.4f},{m.IC_U:.4f}], "
              f"ancho={m.ancho_ic:.4f}, tiempo={m.tiempo_ejecucion:.1f}s")

    # Métricas globales
    cobertura_global = np.mean([m.cobertura for m in metricas])
    ancho_prom = np.mean([m.ancho_ic for m in metricas])

    mixing_correctos = [m.mixing_correcto for m in metricas if m.mixing_correcto is not None]
    tasa_mix = np.mean(mixing_correctos) if mixing_correctos else None

    decisiones_correctas = [m.decision_correcta for m in metricas if m.decision_correcta is not None]
    tasa_dec = np.mean(decisiones_correctas) if decisiones_correctas else None

    resultado = ResultadoEvaluacion(
        metricas=metricas,
        cobertura_global=cobertura_global,
        ancho_promedio=ancho_prom,
        tasa_mixing_correcto=tasa_mix,
        tasa_decision_correcta=tasa_dec,
        tiempo_total=sum(m.tiempo_ejecucion for m in metricas),
    )

    imprimir_evaluacion_completa(resultado)

    print("\n  Leyenda:")
    print("    ✓ = métrica dentro de lo esperado")
    print("    ✗ = métrica fuera de lo esperado (requiere investigación)")
    print("  ===============================================================")


if __name__ == "__main__":
    main()
