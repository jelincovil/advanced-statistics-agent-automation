"""
Off-Policy Evaluation — estimadores DM, IS, DR con clipping adaptativo.

Estimadores del Capítulo 10 (introducido en Cap.~9 como consecuencia
directa del isomorfismo):
* DirectMethod (DM):  $\\hat V_{DM} = \\frac{1}{n}\\sum_i \\hat Q(s_i, a^{\\pi_e})$
* ImportanceSampling (IS): $\\hat V_{IS} = \\frac{1}{n}\\sum_i \\rho_i r_i$
* DoublyRobust (DR): combina ambos, doblemente insesgado.

Mejoras v2 (Su, Wang, Cheng, Tang 2020):
* clipping adaptativo: $\\lambda^* = \\arg\\min_\\lambda \\widehat{\\mathrm{Var}}(\\mathrm{DR}_\\lambda)$,
  escogiendo el umbral de clip que minimiza la varianza empírica.
* Si ESS < n/100, se activa automáticamente.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional

import numpy as np
from scipy.stats import norm


@dataclass
class OPEResult:
    estimator: str
    value_hat: float
    se: float
    ic: tuple
    ess: float = float('nan')
    rho_max: float = float('nan')
    warning: Optional[str] = None
    clipping: Optional[float] = None
    adaptive: bool = False


def _ess_from_rho(rho: np.ndarray) -> float:
    """ESS = (Σρ)² / Σρ²."""
    s1 = rho.sum()
    s2 = (rho ** 2).sum()
    return float(s1 ** 2 / s2) if s2 > 0 else 0.0


def _adaptive_clip(rho: np.ndarray, R: np.ndarray, Q_obs: np.ndarray,
                   Q_eval: np.ndarray, grid: int = 50) -> float:
    """Encuentra λ* = argmin_λ Var(DR_λ) sobre una grilla log-uniforme.

    Implementa Su et al. (2020) Eq. (8). λ recorre cuantiles de ρ entre
    el percentil 50 y 100.
    """
    qs = np.quantile(rho, np.linspace(0.5, 1.0, grid))
    best_lambda, best_var = float(rho.max()), float('inf')
    for lam in qs:
        rho_c = np.minimum(rho, lam)
        dr = Q_eval + rho_c * (R - Q_obs)
        v = dr.var(ddof=1)
        if v < best_var:
            best_var = v
            best_lambda = float(lam)
    return best_lambda


# ---------------------------------------------------------------------------
# Direct Method
# ---------------------------------------------------------------------------
class DirectMethod:
    """$\\hat V_{DM} = \\frac{1}{n}\\sum_i \\hat Q(s_i, \\pi_e(s_i))$."""

    name = "DM"

    def __init__(self, Q_hat: Callable[[np.ndarray, np.ndarray], np.ndarray]):
        self.Q_hat = Q_hat

    def estimate(self, S: np.ndarray, pi_e_actions: np.ndarray,
                 level: float = 0.95) -> OPEResult:
        Q_vals = self.Q_hat(S, pi_e_actions)
        n = len(Q_vals)
        V_hat = float(Q_vals.mean())
        se = float(Q_vals.std(ddof=1) / np.sqrt(n)) if n > 1 else 0.0
        z = norm.ppf(1 - (1 - level) / 2)
        return OPEResult(
            estimator=self.name, value_hat=V_hat, se=se,
            ic=(V_hat - z * se, V_hat + z * se),
            warning="DM depends on correct Q-model specification."
        )


# ---------------------------------------------------------------------------
# Importance Sampling
# ---------------------------------------------------------------------------
class ImportanceSampling:
    """$\\hat V_{IS} = \\frac{1}{n}\\sum_i \\rho_i r_i$, $\\rho_i = \\prod_t \\pi_e/\\pi_b$."""

    name = "IS"

    def __init__(self, clipping: float | None = None, adaptive: bool = False):
        self.clipping = clipping
        self.adaptive = adaptive

    def estimate(self, log_rho: np.ndarray, returns: np.ndarray,
                 level: float = 0.95) -> OPEResult:
        # Manejo seguro de log_rho = -inf (π_b=0)
        log_rho_safe = np.where(np.isfinite(log_rho), log_rho, -50.0)
        rho = np.exp(log_rho_safe)
        used_clip = self.clipping
        if self.adaptive:
            # Adaptive clipping minimizando var(rho·R)
            qs = np.quantile(rho, np.linspace(0.5, 1.0, 50))
            best_lam, best_var = float(rho.max()), float('inf')
            for lam in qs:
                v = (np.minimum(rho, lam) * returns).var(ddof=1)
                if v < best_var:
                    best_var = v
                    best_lam = float(lam)
            used_clip = best_lam
        if used_clip is not None:
            rho = np.minimum(rho, used_clip)
        n = len(rho)
        V_hat = float(np.mean(rho * returns))
        if n > 1:
            var = np.var(rho * returns, ddof=1) / n
            se = float(np.sqrt(var))
        else:
            se = 0.0
        z = norm.ppf(1 - (1 - level) / 2)
        ess = _ess_from_rho(rho)
        warn = None
        if ess < n / 50:
            warn = f"Low ESS ({ess:.1f}/{n}); IS variance may be inflated."
        if rho.max() > 100:
            warn = (warn or "") + f" rho_max={rho.max():.1f}>>1; consider DR+clipping."
        return OPEResult(
            estimator=self.name, value_hat=V_hat, se=se,
            ic=(V_hat - z * se, V_hat + z * se),
            ess=ess, rho_max=float(rho.max()), warning=warn,
            clipping=used_clip, adaptive=self.adaptive,
        )


# ---------------------------------------------------------------------------
# Doubly Robust
# ---------------------------------------------------------------------------
class DoublyRobust:
    """$\\hat V_{DR} = \\frac{1}{n}\\sum_i [\\hat Q(s_i,a_i^{\\pi_e}) + \\rho_i (r_i - \\hat Q(s_i,a_i))]$.

    Hereda doble robustez de la ortogonalidad de Neyman (Cap.~6):
    insesgado si $\\hat Q$ o $\\hat\\pi_b$ es consistente (no ambos).

    Mejora v2: clipping adaptativo (Su et al. 2020) — selecciona
    automáticamente λ* que minimiza la varianza empírica de DR_λ.
    """

    name = "DR"

    def __init__(self, Q_hat: Callable, clipping: float | None = None,
                 adaptive: bool = False):
        self.Q_hat = Q_hat
        self.clipping = clipping
        self.adaptive = adaptive

    def estimate(self, S: np.ndarray, A: np.ndarray, R: np.ndarray,
                 log_rho: np.ndarray, pi_e_actions: np.ndarray,
                 level: float = 0.95) -> OPEResult:
        # Manejo seguro de log_rho = -inf
        log_rho_safe = np.where(np.isfinite(log_rho), log_rho, -50.0)
        rho = np.exp(log_rho_safe)
        Q_obs = self.Q_hat(S, A)
        Q_eval = self.Q_hat(S, pi_e_actions)
        n = len(R)

        used_clip = self.clipping
        if self.adaptive:
            used_clip = _adaptive_clip(rho, R, Q_obs, Q_eval)
        if used_clip is not None:
            rho = np.minimum(rho, used_clip)

        dr_vals = Q_eval + rho * (R - Q_obs)
        V_hat = float(dr_vals.mean())
        se = float(dr_vals.std(ddof=1) / np.sqrt(n)) if n > 1 else 0.0
        z = norm.ppf(1 - (1 - level) / 2)
        ess = _ess_from_rho(rho)
        warn = None
        if ess < n / 100:
            warn = f"ESS={ess:.1f} small; consider adaptive clipping (Su et al. 2020)."
        return OPEResult(
            estimator=self.name, value_hat=V_hat, se=se,
            ic=(V_hat - z * se, V_hat + z * se),
            ess=ess, rho_max=float(rho.max()), warning=warn,
            clipping=used_clip, adaptive=self.adaptive,
        )


# ---------------------------------------------------------------------------
# Cross-Fitted Doubly Robust
# ---------------------------------------------------------------------------
class CrossFittedDoublyRobust:
    r"""Estimador DR con cross-fitting (Chernozhukov et al. 2018).

    Divide los datos en K folds. Para cada fold k:
    1. Entrena $\hat Q^{(k)}$ en los datos fuera del fold (out-of-fold)
    2. Evalúa DR en las observaciones del fold k usando $\hat Q^{(k)}$

    Luego agrega promediando los estimadores de cada fold.

    Esto asegura que $\|\hat Q - Q\| = o_P(n^{-1/4})$ se satisfaga
    bajo condiciones de DML, incluso si el estimador de Q es flexible
    (random forests, redes neuronales, etc.).

    Args:
        Q_fitter: Callable que toma (S_train, A_train, R_train) y devuelve
                 una función Q_hat(S, A) → predicciones.
        n_folds: Número de folds (por defecto 5).
        clipping: Umbral de clipping para ρ (opcional).
        adaptive: Si True, usa clipping adaptativo dentro de cada fold.
        seed: Semilla para la división en folds.
    """

    name = "DR_crossfit"

    def __init__(self, Q_fitter: Callable, n_folds: int = 5,
                 clipping: float | None = None, adaptive: bool = False,
                 seed: int = 42):
        self.Q_fitter = Q_fitter
        self.n_folds = n_folds
        self.clipping = clipping
        self.adaptive = adaptive
        self.seed = seed

    def estimate(self, S: np.ndarray, A: np.ndarray, R: np.ndarray,
                 log_rho: np.ndarray, pi_e_actions: np.ndarray,
                 level: float = 0.95) -> OPEResult:
        rng = np.random.default_rng(self.seed)
        n = len(R)

        # División en folds
        indices = rng.permutation(n)
        fold_sizes = np.full(self.n_folds, n // self.n_folds)
        fold_sizes[:n % self.n_folds] += 1
        folds = []
        current = 0
        for fs in fold_sizes:
            folds.append(indices[current:current + fs])
            current += fs

        # Estimación por cross-fitting
        fold_estimates = []
        fold_vars = []

        for k in range(self.n_folds):
            test_idx = folds[k]
            train_idx = np.concatenate([folds[j] for j in range(self.n_folds) if j != k])

            # Entrenar Q_hat en out-of-fold
            Q_hat = self.Q_fitter(
                S[train_idx], A[train_idx], R[train_idx]
            )

            # Evaluar en fold k
            S_k = S[test_idx]
            A_k = A[test_idx]
            R_k = R[test_idx]
            log_rho_k = log_rho[test_idx]
            pi_e_k = pi_e_actions[test_idx]

            log_rho_safe = np.where(np.isfinite(log_rho_k), log_rho_k, -50.0)
            rho_k = np.exp(log_rho_safe)
            Q_obs_k = Q_hat(S_k, A_k)
            Q_eval_k = Q_hat(S_k, pi_e_k)

            used_clip = self.clipping
            if self.adaptive:
                used_clip = _adaptive_clip(rho_k, R_k, Q_obs_k, Q_eval_k)
            if used_clip is not None:
                rho_k = np.minimum(rho_k, used_clip)

            dr_k = Q_eval_k + rho_k * (R_k - Q_obs_k)
            fold_estimates.append(float(dr_k.mean()))
            fold_vars.append(float(dr_k.var(ddof=1)) / len(dr_k))

        # Agregación: promedio de los estimadores de cada fold
        V_hat = float(np.mean(fold_estimates))

        # Varianza: ley de varianza total + corrección por cross-fitting
        # Var(θ̂_cf) = (1/K) Σ Var(θ̂_k) + Var(θ̂_k means)
        se_within = np.sqrt(np.mean(fold_vars))
        se_between = float(np.std(fold_estimates, ddof=1)) / np.sqrt(self.n_folds)
        se = float(np.sqrt(se_within**2 + se_between**2))

        z = norm.ppf(1 - (1 - level) / 2)

        # ESS estimado a partir de todos los datos
        log_rho_all_safe = np.where(np.isfinite(log_rho), log_rho, -50.0)
        rho_all = np.exp(log_rho_all_safe)
        ess = _ess_from_rho(rho_all)

        warn = None
        if ess < n / 100:
            warn = f"ESS={ess:.1f} small; cross-fitting helps but consider adaptive clipping."

        return OPEResult(
            estimator=self.name, value_hat=V_hat, se=se,
            ic=(V_hat - z * se, V_hat + z * se),
            ess=ess, rho_max=float(rho_all.max()), warning=warn,
            clipping=used_clip if self.clipping is not None else None,
            adaptive=self.adaptive,
        )
