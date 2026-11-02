#!/usr/bin/env python3
"""
================================================================================
SEGUNDA EVALUACIÓN — 6 NUEVOS DATASETS CON HETEROGENEIDAD
Capítulo 5: Teoría Asintótica y Métodos de Remuestreo
================================================================================

Generadores de datasets con:
  - GARCH(1,1): heteroscedasticidad condicional
  - Markov Switching: cambios de régimen
  - ARFIMA(0,d,0): memoria larga (decaimiento hiperbólico)
  - α-Estable(α=1.5): varianza infinita
  - Importance Sampling: pesos desiguales
  - Periódico: estacionalidad

Uso:
    from datasets_heterogeneos import *
    ds = generar_dataset_garch(n=1000)
================================================================================
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass
from typing import List, Tuple, Union

import numpy as np
from scipy import stats

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from primera_evaluacion.evaluador_agente import Dataset

# =============================================================================
# 1. GARCH(1,1) — Heteroscedasticidad Condicional
# =============================================================================

def generar_dataset_garch(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """
    GARCH(1,1): X_t = 5 + ε_t, ε_t = σ_t·w_t, σ²_t = ω + α·ε²_{t-1} + β·σ²_{t-1}
    ω=0.05, α=0.1, β=0.85 (persistencia alta pero estacionaria en varianza).
    V_true = 5.0. Los w_t son iid N(0,1) → no hay dependencia lineal.

    La varianza condicional cambia en el tiempo, pero incondicionalmente
    es constante: σ² = ω / (1 - α - β) = 0.05 / 0.05 = 1.0
    """
    rng = np.random.default_rng(semilla)
    omega, alpha, beta = 0.05, 0.1, 0.85
    V_true = 5.0
    w = rng.normal(0, 1, n)
    sigma2 = np.ones(n) * (omega / (1 - alpha - beta))  # varianza incondicional
    epsilon = np.zeros(n)
    epsilon[0] = np.sqrt(sigma2[0]) * w[0]
    for t in range(1, n):
        sigma2[t] = omega + alpha * epsilon[t-1]**2 + beta * sigma2[t-1]
        epsilon[t] = np.sqrt(sigma2[t]) * w[t]
    retornos = V_true + epsilon
    sigma2_empirica = float(np.var(retornos, ddof=1))
    return Dataset(
        nombre="garch",
        descripcion=f"GARCH(1,1) ω={omega} α={alpha} β={beta} n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=sigma2_empirica,
        es_dependiente=False, rho_true=0.0,
        sigma2_LR_true=sigma2_empirica,
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# 2. Markov Switching — Cambio de Régimen
# =============================================================================

def generar_dataset_switching(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """
    Dos regímenes: R1 ~ N(2, 1), R2 ~ N(8, 4).
    Matriz de transición: P = [[0.97, 0.03], [0.03, 0.97]].

    Distribución estacionaria: π = [0.5, 0.5]
    V_true = 0.5·2 + 0.5·8 = 5.0

    Los datos tienen dependencia temporal fuerte (persistencia de régimen).
    σ²_LR >> σ²_inst por la correlación inducida por los regímenes.
    """
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    medias = np.array([2.0, 8.0])
    desvios = np.array([1.0, 2.0])
    P = np.array([[0.97, 0.03], [0.03, 0.97]])

    regimenes = np.zeros(n, dtype=int)
    retornos = np.zeros(n)
    regimenes[0] = 1 if rng.random() < 0.5 else 0
    retornos[0] = rng.normal(medias[regimenes[0]], desvios[regimenes[0]])
    for t in range(1, n):
        regimenes[t] = 1 if rng.random() < P[regimenes[t-1], 1] else 0
        retornos[t] = rng.normal(medias[regimenes[t]], desvios[regimenes[t]])

    sigma2_inst = 0.5 * (1.0 + 4.0) + 0.5 * 0.5 * (8.0 - 2.0)**2  # ≈ 11.5
    sigma2_inst = float(np.var(retornos, ddof=1))

    # Varianza de largo plazo: la dependencia la multiplica ~ (1+ρ)/(1-ρ)
    # Con ρ_approx = 0.94 (P[0,0]-P[0,1]≈0.94): σ²_LR ≈ 11.5 * (1.94/0.06) ≈ 372
    autocov = np.mean((retornos[:-1] - V_true) * (retornos[1:] - V_true))
    rho_empirico = autocov / sigma2_inst if sigma2_inst > 0 else 0.0

    return Dataset(
        nombre="switching",
        descripcion=f"Markov Switching 2 regímenes n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=float(sigma2_inst),
        es_dependiente=True,
        rho_true=float(min(0.99, abs(rho_empirico))),
        sigma2_LR_true=float(sigma2_inst + 2 * autocov / (1 - abs(rho_empirico))) if abs(rho_empirico) < 1 else float(sigma2_inst) * 100,
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# 3. ARFIMA(0, d, 0) — Memoria Larga
# =============================================================================

def generar_dataset_arfima(
    n: int = 1000, d: float = 0.3, semilla: int = 42
) -> Dataset:
    """
    ARFIMA(0, d, 0): (1-B)^d X_t = w_t, w_t ~ N(0, 1).
    d=0.3 → estacionario, memoria larga.

    Las autocorrelaciones decaen como k^{2d-1} = k^{-0.4} (hiperbólico).
    El mixing geométrico NO se cumple (ρ no está definido).

    V_true = 5.0
    """
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    w = rng.normal(0, 1, n + 500)

    # Aproximación truncada de la representación MA(∞):
    # X_t = Σ ψ_k · w_{t-k}, donde ψ_k = Γ(k+d) / (Γ(d)·Γ(k+1))
    from math import gamma as gamma_func
    K = min(n, 500)
    psi = np.zeros(K)
    psi[0] = 1.0
    for k in range(1, K):
        psi[k] = psi[k-1] * (k - 1 + d) / k

    x = np.zeros(n + 500)
    for t in range(n + 500):
        for k in range(min(t + 1, K)):
            x[t] += psi[k] * w[t - k]

    retornos = V_true + x[-n:]  # descartar burn-in

    # Varianza teórica: γ₀ = Γ(1-2d) / Γ(1-d)²
    from math import gamma as gamma_func
    gamma0 = gamma_func(1 - 2*d) / (gamma_func(1 - d)**2) if 1 - 2*d > 0 else float(np.var(retornos, ddof=1))
    sigma2_emp = float(np.var(retornos, ddof=1))

    return Dataset(
        nombre="arfima",
        descripcion=f"ARFIMA(0,{d},0) memoria larga n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=sigma2_emp,
        es_dependiente=True,
        rho_true=0.95,  # la regresión log-lineal da ~1
        sigma2_LR_true=float(max(sigma2_emp * 10, gamma0 * 10)),  # la LR es enorme
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# 4. α-Estable(α=1.5) — Varianza Infinita
# =============================================================================

def generar_dataset_estable(
    n: int = 1000, alpha: float = 1.5, semilla: int = 42
) -> Dataset:
    """
    Distribución α-Estable con α=1.5, β=0 (simétrica), γ=1 (escala), δ=5 (locación).

    Media = δ = 5.0 (para α > 1).
    Varianza = ∞ (para α < 2).

    Viola el supuesto E[G²] < ∞ del Thm 5.7 (consistencia bootstrap).
    El bootstrap NO converge teóricamente.

    Generación usando algoritmo de Chambers-Mallows-Stuck.
    """
    rng = np.random.default_rng(semilla)
    delta = 5.0  # locación = media (para α > 1)
    gamma = 1.0  # escala
    beta = 0.0   # simétrico

    # Chambers-Mallows-Stuck
    u = rng.uniform(-np.pi/2, np.pi/2, n)
    w = rng.exponential(1, n)

    if abs(alpha - 1.0) > 0.01:
        b = beta * np.tan(np.pi * alpha / 2) / alpha
        v = np.sin(alpha * (u + b)) / (np.cos(u) ** (1/alpha))
        v = v * (np.cos(u - alpha * (u + b)) / w) ** ((1 - alpha) / alpha)
    else:
        # α=1 (Cauchy) - caso especial
        v = np.tan(u)

    retornos = delta + gamma * v
    V_true = delta  # media = δ para α > 1

    sigma2_emp = float(np.var(retornos, ddof=1))  # NO converge al aumentar n

    return Dataset(
        nombre="estable",
        descripcion=f"α-Estable(α={alpha}) varianza infinita n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=sigma2_emp,
        es_dependiente=False, rho_true=0.0,
        sigma2_LR_true=sigma2_emp * 10,  # la varianza muestral es engañosa
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# 5. Importance Sampling — Pesos Desiguales
# =============================================================================

def generar_dataset_importance_sampling(
    n: int = 1000, semilla: int = 42
) -> Dataset:
    """
    Simula retornos de重要性 muestreo (off-policy evaluation).

    30% de las trayectorias vienen de una política de exploración (alta varianza),
    70% de una política de explotación (baja varianza).

    Los pesos IS hacen que la distribución efectiva sea una mixtura.
    El bootstrap iid no captura la estructura de pesos.
    """
    rng = np.random.default_rng(semilla)
    V_true = 3.0

    # Política de comportamiento (exploración): retornos ~ N(3, 9)
    # Política objetivo (explotación): retornos ~ N(3, 1)
    n_exploracion = int(0.3 * n)
    n_explotacion = n - n_exploracion

    retornos_exploracion = rng.normal(3.0, 3.0, n_exploracion)
    retornos_explotacion = rng.normal(3.0, 1.0, n_explotacion)

    # Pesos de importance sampling (no uniformes)
    # La razón de verosimilitud es w(x) = N(x|3,1) / N(x|3,9)
    todos = np.concatenate([retornos_exploracion, retornos_explotacion])
    pesos = np.ones(n)
    pesos[:n_exploracion] = np.exp(
        -0.5 * (retornos_exploracion - 3.0)**2 * (1/1 - 1/9)
    ) * (1/3)  # razón de desviaciones estándar
    pesos = pesos / np.mean(pesos)  # normalizar

    # Muestrear con reemplazo usando los pesos
    idx = rng.choice(n, size=n, p=pesos / np.sum(pesos))
    retornos = todos[idx]

    sigma2_emp = float(np.var(retornos, ddof=1))

    return Dataset(
        nombre="importance_sampling",
        descripcion=f"Importance Sampling 30/70 n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=sigma2_emp,
        es_dependiente=False, rho_true=0.0,
        sigma2_LR_true=sigma2_emp,
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# 6. Periódico — Estacionalidad
# =============================================================================

def generar_dataset_periodico(
    n: int = 1000, periodo: int = 24, semilla: int = 42
) -> Dataset:
    """
    X_t = 5 + sin(2π·t/periodo) + ε_t, ε_t ~ AR(1) con φ=0.3.

    La función seno introduce autocorrelación con picos en lags múltiplos
    del periodo. V_true = 5.0.

    Prueba si max_lag_mixing=20 es suficiente para detectar la dependencia
    cuando el periodo es 24 (mayor que el max_lag).
    """
    rng = np.random.default_rng(semilla)
    V_true = 5.0
    t = np.arange(n)
    tendencia = np.sin(2 * np.pi * t / periodo)

    # Ruido AR(1)
    phi = 0.3
    w = rng.normal(0, 1, n)
    ruido = np.zeros(n)
    ruido[0] = w[0] / np.sqrt(1 - phi**2)
    for i in range(1, n):
        ruido[i] = phi * ruido[i-1] + w[i]

    retornos = V_true + tendencia + ruido

    sigma2_emp = float(np.var(retornos, ddof=1))

    # Autocorrelación en lag=periodo
    acf_periodo = np.corrcoef(retornos[:-periodo], retornos[periodo:])[0, 1] if n > periodo else 0.0

    return Dataset(
        nombre="periodico",
        descripcion=f"Periódico periodo={periodo} + AR(1) φ={phi} n={n}",
        retornos=retornos, V_true=V_true,
        sigma2_retornos=sigma2_emp,
        es_dependiente=True,
        rho_true=float(max(phi, abs(acf_periodo))),
        sigma2_LR_true=float(sigma2_emp * (1 + phi) / (1 - phi)) if phi < 1 else sigma2_emp * 10,
        Q_estimates=None, policy=None, Sigma_Q_true=None, V_delta_true=None,
    )


# =============================================================================
# CATÁLOGO COMPLETO
# =============================================================================

DATASETS_HETEROGENEOS = {
    "garch": generar_dataset_garch,
    "switching": generar_dataset_switching,
    "arfima": generar_dataset_arfima,
    "estable": generar_dataset_estable,
    "importance_sampling": generar_dataset_importance_sampling,
    "periodico": generar_dataset_periodico,
}
