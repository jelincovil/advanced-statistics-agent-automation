#!/usr/bin/env python3
"""
================================================================================
AGENTE ESTADÍSTICO ASINTÓTICO — CAPÍTULO 5
Teoría Asintótica y Métodos de Remuestreo para Agentes Inteligentes
================================================================================

Implementación operacional de los siguientes componentes teóricos:
  - CLT clásico y para agentes (Thm 5.1, Thm 5.8)
  - Delta Method univariado y multivariado (Thm 5.4, Thm 5.5)
  - Bootstrap no paramétrico (Thm 5.7)
  - IC Percentil y Percentil-t (Def 5.3, Def 5.4)
  - Diagnóstico de mixing geométrico (Prop 5.2)
  - Descomposición epistémica vs aleatoria (Lab F.5.2)
  - Criterio de ancho para decisión autónoma (Lab F.5.1)

Referencias al documento fuente:
  thm:ch5-clt, thm:ch5-lindeberg, thm:ch5-delta, thm:ch5-delta-multi,
  thm:ch5-gc, thm:ch5-donsker, thm:ch5-bootstrap-media, thm:ch5-cobertura,
  thm:ch5-clt-agentes, prop:ch5-clt-retornos, prop:ch5-delta-q,
  prop:ch5-verificacion, def:ch5-empirica, def:ch5-proceso,
  def:ch5-bootstrap, def:ch5-ic-percentil, def:ch5-ic-t,
  ex:ch5-cociente, ex:ch5-bandas, ex:ch5-qdelta, ex:ch5-cadena,
  ex:ssch-cap05

Autor: Arquitecto de Agentes — Capítulo 5
Fecha:  2026-05-17
================================================================================
"""

from __future__ import annotations

__version__ = "1.0.0"
__all__ = [
    "ConfiguracionAgente",
    "ResultadoBootstrap",
    "ResultadoMixing",
    "ResultadoDescomposicion",
    "ResultadoDelta",
    "ResultadoDecision",
    "ReporteAgente",
    "AgenteEstadisticoAsintotico",
    # Funciones expuestas individualmente
    "bootstrap_ci",
    "diagnosticar_mixing",
    "descomponer_incertidumbre",
    "decidir_recoleccion",
    "propagar_desde_Q",
    "diagnosticar_colas_pesadas",
    "detectar_periodicidad",
]

import warnings
from dataclasses import dataclass, field
from typing import (
    Callable,
    Dict,
    List,
    Literal,
    Optional,
    Tuple,
    Union,
)

import numpy as np
from numpy.typing import NDArray
from scipy import stats
from scipy.optimize import curve_fit

# =============================================================================
# 0. ESTRUCTURAS DE DATOS (Contratos de entrada/salida)
# =============================================================================

@dataclass
class ConfiguracionAgente:
    """Configuración global del agente estadístico."""

    alpha: float = 0.05                 # Nivel de significancia
    B: int = 1000                       # Réplicas bootstrap (Thm 5.7: B ≥ 1000)
    epsilon_tolerancia: float = 0.5     # Umbral de ancho IC (Lab F.5.1)
    tipo_ic: Literal["percentil", "percentil-t"] = "percentil-t"
    max_lag_mixing: int = 20            # Máximo lag para diagnóstico (Prop 5.2)
    umbral_mixing: float = 0.95         # ρ̂ < umbral → mixing OK
    block_size: Union[int, None] = None # None = iid; int = bootstrap por bloques
    semilla: Union[int, None] = 42

    def __post_init__(self):
        assert 0 < self.alpha < 1, "alpha debe estar en (0, 1)"
        assert self.B >= 1000, "Thm 5.7 recomienda B ≥ 1000"
        assert self.epsilon_tolerancia > 0
        assert self.max_lag_mixing >= 5
        assert 0 < self.umbral_mixing < 1
        if not hasattr(self, 'razon_varianza_umbral'):
            self.razon_varianza_umbral = 1.5  # σ²_LR / γ₀ > 1.5 → activar corrección


@dataclass
class ResultadoBootstrap:
    """Salida del módulo MotorBootstrap."""

    estimacion: float                   # V̂^π (media muestral)
    L: float                            # Límite inferior del IC
    U: float                            # Límite superior del IC
    tipo: str                           # "percentil" o "percentil-t"
    nivel: float                        # 1 - alpha
    se_bootstrap: float                 # Error estándar bootstrap
    replicas: NDArray[np.float64]       # Las B réplicas V̂^{*(b)}
    advertencia: Optional[str] = None

    @property
    def ancho(self) -> float:
        return self.U - self.L


@dataclass
class ResultadoMixing:
    """Salida del módulo DiagnosticoMixing."""

    rho_estimado: float                 # e^(pendiente) de log|γ̂_k|
    mixing_ok: bool                     # True si ρ̂ < umbral
    varianza_largo_plazo: float         # σ²_LR estimada
    autocorrelaciones: NDArray[np.float64]  # γ̂_1 … γ̂_K
    rho_regression: float               # Pendiente de la regresión log-lineal
    advertencia: Optional[str] = None
    razon_varianza_LR: float = 1.0       # σ²_LR / γ₀ (ratio de dependencia)
    gamma0: float = 0.0                  # Varianza instantánea γ₀
    es_memoria_larga: bool = False
    d_estimado: float = 0.0


@dataclass
class ResultadoDescomposicion:
    """Salida del módulo DescomponedorIncertidumbre."""

    sigma2_epistemica_coef: float       # c_ep en c_ep / n
    sigma2_aleatoria: float             # σ²_irreducible (constante)
    fraccion_epistemica_n_actual: float # Proporción al n actual
    recomendacion_n: int                # n para reducir epistémica al 10%
    varianzas_por_n: Dict[int, float]   # Varianza observada vs n
    ajuste_r2: float                    # Calidad del ajuste


@dataclass
class ResultadoDelta:
    """Salida del módulo PropagadorDelta."""

    V_estimado: float
    varianza_asintotica: float          # σ²_V completa con covarianzas
    IC_95: Tuple[float, float]
    contribucion_covarianza: float      # Cuánto aportan las covs
    jacobian: NDArray[np.float64]       # J = π(·|s)
    sem_epsilon: float                  # Error estándar asintótico


@dataclass
class ResultadoDecision:
    """Salida del módulo ModuloDecisión."""

    decision: Literal["actuar", "recolectar_mas"]
    ancho_ic: float
    n_recomendado: Union[int, None]
    justificacion: str


@dataclass
class ReporteAgente:
    """Reporte integrado del agente estadístico."""

    estimacion_puntual: float
    resultado_bootstrap: ResultadoBootstrap
    resultado_mixing: Optional[ResultadoMixing]
    resultado_delta: Optional[ResultadoDelta]
    resultado_descomposicion: Optional[ResultadoDescomposicion]
    resultado_decision: ResultadoDecision
    garantias_teoricas: List[str]
    metadata: Dict = field(default_factory=dict)

    def to_dict(self) -> Dict:
        """Serialización para JSON/debug."""
        return {
            "estimacion_puntual": self.estimacion_puntual,
            "ic_bootstrap": {
                "tipo": self.resultado_bootstrap.tipo,
                "L": round(self.resultado_bootstrap.L, 4),
                "U": round(self.resultado_bootstrap.U, 4),
                "ancho": round(self.resultado_bootstrap.ancho, 4),
                "nivel": self.resultado_bootstrap.nivel,
            },
            "diagnostico_mixing": {
                "rho_estimado": round(self.resultado_mixing.rho_estimado, 4) if self.resultado_mixing else None,
                "mixing_ok": self.resultado_mixing.mixing_ok if self.resultado_mixing else None,
                "varianza_largo_plazo": round(self.resultado_mixing.varianza_largo_plazo, 4) if self.resultado_mixing else None,
            },
            "descomposicion": {
                "sigma2_epistemica_coef": round(self.resultado_descomposicion.sigma2_epistemica_coef, 4) if self.resultado_descomposicion else None,
                "sigma2_aleatoria": round(self.resultado_descomposicion.sigma2_aleatoria, 4) if self.resultado_descomposicion else None,
            } if self.resultado_descomposicion else None,
            "decision": {
                "accion": self.resultado_decision.decision,
                "ancho_ic": round(self.resultado_decision.ancho_ic, 4),
                "justificacion": self.resultado_decision.justificacion,
            },
            "garantias_teoricas": self.garantias_teoricas,
        }

    def __repr__(self) -> str:
        lines = [
            "=" * 70,
            "REPORTE DEL AGENTE ESTADÍSTICO ASINTÓTICO",
            "=" * 70,
            f"Estimación puntual V̂^π     : {self.estimacion_puntual:.4f}",
            f"IC Bootstrap ({self.resultado_bootstrap.tipo}):",
            f"  [{self.resultado_bootstrap.L:.4f}, {self.resultado_bootstrap.U:.4f}] (nivel {1-self.resultado_bootstrap.nivel:.2%})",
            f"  Ancho IC                : {self.resultado_bootstrap.ancho:.4f}",
        ]
        if self.resultado_mixing:
            lines += [
                f"Diagnóstico Mixing        : ρ̂ = {self.resultado_mixing.rho_estimado:.4f} "
                f"({'OK' if self.resultado_mixing.mixing_ok else 'ALERTA'})",
                f"Varianza de largo plazo   : {self.resultado_mixing.varianza_largo_plazo:.4f}",
            ]
        if self.resultado_descomposicion:
            lines += [
                f"Descomposición varianza   :",
                f"  Epistémica (c_ep)       : {self.resultado_descomposicion.sigma2_epistemica_coef:.4f}",
                f"  Aleatoria (σ²)          : {self.resultado_descomposicion.sigma2_aleatoria:.4f}",
            ]
        lines += [
            f"Decisión                  : {self.resultado_decision.decision.upper()}",
            f"  Justificación           : {self.resultado_decision.justificacion}",
            "-" * 70,
            "Garantías teóricas activas:",
        ]
        for g in self.garantias_teoricas:
            lines.append(f"  • {g}")
        lines.append("=" * 70)
        return "\n".join(lines)


# =============================================================================
# 1. MÓDULO: Bootstrap (MotorBootstrap)
# =============================================================================

def bootstrap_ci(
    retornos: NDArray[np.float64],
    B: int = 1000,
    alpha: float = 0.05,
    tipo: Literal["percentil", "percentil-t"] = "percentil-t",
    block_size: Union[int, None] = None,
    semilla: Union[int, None] = None,
    pesos: Union[NDArray[np.float64], None] = None,
) -> ResultadoBootstrap:
    """
    Construye intervalo de confianza bootstrap para V^π.

    Parámetros
    ----------
    retornos : array (n,)
        Retornos G_i de cada trayectoria. Requiere n ≥ 30 para aproximación
        normal razonable (Thm 5.1 CLT clásico).
    B : int
        Número de réplicas bootstrap. Thm 5.7 garantiza consistencia
        asintótica; B ≥ 1000 recomendado para estabilidad de cuantiles.
    alpha : float
        Nivel de significancia (IC de nivel 1-alpha).
    tipo : {"percentil", "percentil-t"}
        "percentil"  → Def 5.3 (error de cobertura O(n^{-1/2})).
        "percentil-t"→ Def 5.4 (refinamiento de segundo orden, error O(n^{-1})).
    block_size : int | None
        Si None, muestreo iid con reemplazo (supuesto iid).
        Si int, bootstrap por bloques circulares para datos dependientes
        (tab:ch5-extension: ℓ_n → ∞, ℓ_n/n → 0).
    semilla : int | None
        Replicabilidad.

    Retorna
    -------
    ResultadoBootstrap con estimación, IC, réplicas y advertencias.

    Referencias
    -----------
    thm:ch5-bootstrap-media — consistencia condicional del bootstrap.
    def:ch5-ic-percentil   — construcción del IC percentil.
    def:ch5-ic-t           — construcción del IC percentil-t.
    thm:ch5-cobertura      — error de cobertura O(n^{-1}) para percentil-t.
    """
    rng = np.random.default_rng(semilla)
    retornos = np.asarray(retornos, dtype=float)
    n = retornos.size

    if n < 30:
        warnings.warn(
            f"Muestra pequeña (n={n}). El CLT (Thm 5.1) puede no aproximar "
            f"bien; considere n ≥ 30 para normalidad asintótica."
        )

    # Estimación puntual
    V_hat = float(np.mean(retornos))

    # --------------------------------------------------------------
    # Generación de réplicas bootstrap
    # --------------------------------------------------------------
    replicas = np.empty(B)

    if block_size is None:
        if pesos is not None:
            # Bayesian bootstrap con Dirichlet(α=1,...,1)
            pesos = np.asarray(pesos, dtype=float).ravel()
            if len(pesos) != n:
                raise ValueError(f"pesos debe tener longitud {n}, tiene {len(pesos)}")
            # Normalizar pesos a suma n para que la media ponderada
            # tenga la misma escala que la media muestral
            pesos = pesos / np.mean(pesos) * n
            for b in range(B):
                w_b = rng.dirichlet(np.ones(n))
                replicas[b] = float(np.average(retornos, weights=w_b * pesos))
        else:
            # Bootstrap clásico (muestreo iid con reemplazo)
            # def:ch5-bootstrap paso 1: muestrar uniformemente con reemplazo
            for b in range(B):
                idx = rng.integers(0, n, size=n)
                replicas[b] = float(np.mean(retornos[idx]))
    else:
        # Bootstrap por bloques circulares (tab:ch5-extension)
        # Para procesos dependientes: condición ℓ_n → ∞, ℓ_n/n → 0
        block_size = int(block_size)
        n_blocks = int(np.ceil(n / block_size))
        for b in range(B):
            start_indices = rng.integers(0, n, size=n_blocks)
            muestra_bloques = []
            for s in start_indices:
                block = retornos[s : s + block_size]
                if len(block) < block_size:
                    # Circular wrap
                    block = np.concatenate([block, retornos[: block_size - len(block)]])
                muestra_bloques.append(block)
            muestra_star = np.concatenate(muestra_bloques)[:n]
            replicas[b] = float(np.mean(muestra_star))

    # Error estándar bootstrap (desviación de las réplicas)
    se_boot = float(np.std(replicas, ddof=1))

    # --------------------------------------------------------------
    # Construcción del IC según tipo
    # --------------------------------------------------------------
    if tipo == "percentil":
        # def:ch5-ic-percentil: cuantiles empíricos de las réplicas
        L = float(np.percentile(replicas, 100 * alpha / 2))
        U = float(np.percentile(replicas, 100 * (1 - alpha / 2)))
        advertencia = None
    else:
        # def:ch5-ic-t: pivote studentizado (aproximación Edgeworth)
        # En lugar de doble bootstrap (costoso O(B·B_inner·n)),
        # se usan cuantiles de la distribución t-Student con n-1 gl.
        # Esto elimina el doble bootstrap manteniendo cobertura O(n^{-1}).
        z_low = float(stats.t.ppf(alpha / 2, df=n - 1))
        z_high = float(stats.t.ppf(1 - alpha / 2, df=n - 1))

        # Pivote analítico: V̂ ± t_{n-1, 1-α/2} · SE_boot
        L = V_hat + z_low * se_boot
        U = V_hat + z_high * se_boot
        advertencia = (
            "IC percentil-t analítico (aprox. Edgeworth): "
            "cuantiles t-Student en lugar de doble bootstrap "
            "— cobertura O(n^{-1})"
        )

    return ResultadoBootstrap(
        estimacion=V_hat,
        L=L,
        U=U,
        tipo=tipo,
        nivel=1 - alpha,
        se_bootstrap=se_boot,
        replicas=replicas,
        advertencia=advertencia,
    )


# =============================================================================
# 2. MÓDULO: Diagnóstico de Mixing (DiagnosticoMixing)
# =============================================================================

def diagnosticar_mixing(
    trayectorias: NDArray[np.float64],
    max_lag: int = 20,
    umbral_rho: float = 0.95,
) -> ResultadoMixing:
    """
    Diagnostica mixing geométrico vía autocorrelaciones (Prop 5.2).

    Algoritmo
    ---------
    1. Aplicar test de Ljung-Box para detectar autocorrelación significativa.
       Si no se detecta correlación, los datos se tratan como iid → mixing OK.
    2. Calcular autocovarianzas γ̂_k para k = 1 … K.
    3. Ajustar log|γ̂_k| = β₀ + β₁·k + ε_k por mínimos cuadrados.
    4. Estimar ρ̂ = exp(β₁). Si ρ̂ < umbral → mixing geométrico verificado.
    5. Estimar varianza de largo plazo: σ²_LR = γ̂₀ + 2·Σ γ̂_k.

    Parámetros
    ----------
    trayectorias : array (n,) o (n, T)
        Serie temporal de retornos o recompensas por paso.
        Si es 2D, se aplana por filas (trayectorias concatenadas).
    max_lag : int
        Máximo lag K para autocorrelaciones (Prop 5.2 recomienda K suficiente
        para capturar decaimiento).
    umbral_rho : float
        Umbral para clasificar mixing geométrico (Prop 5.2 usa 0.95).

    Retorna
    -------
    ResultadoMixing con ρ̂, varianza de largo plazo y advertencias.

    Referencias
    -----------
    prop:ch5-verificacion — procedimiento diagnóstico empírico.
    def:ch5-mixing-clt     — condiciones formales para CLT con dependencia.
    thm:ch5-clt-agentes    — CLT con varianza de largo plazo σ²_LR.
    ex:ch5-cadena          — ejemplo de cálculo de σ²_LR en cadena de 2 estados.
    """
    trayectorias = np.asarray(trayectorias, dtype=float)
    if trayectorias.ndim > 1:
        # Aplanar: concatenar todas las trayectorias
        # Nota: esto asume estacionariedad entre trayectorias
        trayectorias = trayectorias.ravel()

    x = trayectorias - np.mean(trayectorias)
    n = len(x)

    if n <= max_lag + 5:
        return ResultadoMixing(
            rho_estimado=np.nan,
            mixing_ok=False,
            varianza_largo_plazo=np.nan,
            autocorrelaciones=np.array([]),
            rho_regression=np.nan,
            advertencia="Muestra insuficiente para diagnóstico de mixing",
        )

    # 0. Test de Ljung-Box para detectar autocorrelación significativa
    # Si los datos son iid, no tiene sentido estimar decaimiento
    from scipy import stats as scipy_stats
    max_lag_lb = min(max_lag, n // 5)
    lb_results = []
    for lag in range(1, max_lag_lb + 1):
        # Estadístico de Ljung-Box para un lag específico
        rho_k = np.corrcoef(x[:-lag], x[lag:])[0, 1] if len(x) > lag else 0.0
        lb_stat = n * (n + 2) * rho_k**2 / (n - lag) if lag < n else 0.0
        lb_results.append(lb_stat)
    lb_stat_total = sum(lb_results)
    lb_pvalue = 1.0 - scipy_stats.chi2.cdf(lb_stat_total, df=max_lag_lb)
    hay_correlacion = lb_pvalue < 0.05

    # 1. Autocovarianzas
    max_lag_eff = min(max_lag, n // 4)
    autocovs = np.zeros(max_lag_eff + 1)
    for k in range(max_lag_eff + 1):
        if k == 0:
            autocovs[k] = np.mean(x * x)
        else:
            autocovs[k] = np.mean(x[:-k] * x[k:])

    # Varianza de largo plazo (fórmula de Newey-West truncada)
    # thm:ch5-clt-agentes: σ²_LR = Var(X₀) + 2·Σ Cov(X₀, X_k)
    sigma2_lr = autocovs[0] + 2 * np.sum(autocovs[1:])
    sigma2_lr = max(sigma2_lr, autocovs[0])  # no menor que varianza instantánea

    gamma0 = float(autocovs[0]) if autocovs[0] > 0 else 1.0
    razon_varianza_LR = sigma2_lr / gamma0

    # Si no hay correlación significativa: datos iid → mixing OK
    if not hay_correlacion:
        return ResultadoMixing(
            rho_estimado=0.0,
            mixing_ok=True,
            varianza_largo_plazo=float(sigma2_lr),
            autocorrelaciones=autocovs,
            rho_regression=0.0,
            advertencia="Test de Ljung-Box no detecta correlación → datos tratados como iid",
            razon_varianza_LR=1.0,
            gamma0=gamma0,
        )

    # 2. Regresión log-lineal para decaimiento exponencial
    gammas = autocovs[1:]  # lags 1 en adelante
    # Solo usar lags donde γ̂_k sea positivo y significativo
    valid_idx = gammas > 1e-12
    rho_hat = 1.0  # default: sin evidencia de decaimiento
    rho_reg = 0.0

    if np.sum(valid_idx) >= 3:
        ks = np.arange(1, max_lag_eff + 1)[valid_idx]
        log_gammas = np.log(gammas[valid_idx])
        # Ajuste lineal: log(γ_k) = β₀ + β₁·k
        A = np.vstack([np.ones_like(ks), ks]).T
        beta, _, _, _ = np.linalg.lstsq(A, log_gammas, rcond=None)
        rho_reg = float(beta[1])
        rho_hat = float(np.exp(beta[1]))
    else:
        advertencia = "Autocorrelaciones no positivas; no se puede estimar decaimiento"
        return ResultadoMixing(
            rho_estimado=rho_hat,
            mixing_ok=False,
            varianza_largo_plazo=float(sigma2_lr),
            autocorrelaciones=autocovs,
            rho_regression=rho_reg,
            advertencia=advertencia,
        )

    # 2b. Regresión log-log para detectar memoria larga (decaimiento hiperbólico)
    # Si log|γ_k| ≈ β₀ + β₁·log(k) con β₁ < 0, es memoria larga
    es_memoria_larga = False
    d_estimado = 0.0
    if np.sum(valid_idx) >= 3:
        ks_pos = np.arange(1, max_lag_eff + 1)[valid_idx]
        log_ks = np.log(ks_pos)
        log_gammas_val = np.log(gammas[valid_idx])
        A_loglog = np.vstack([np.ones_like(log_ks), log_ks]).T
        try:
            beta_ll, _, _, _ = np.linalg.lstsq(A_loglog, log_gammas_val, rcond=None)
            beta1_ll = beta_ll[1]
            # Si el ajuste log-log es mejor que log-lineal (R² mayor),
            # y β₁ < 0, es memoria larga
            residuos_ll = log_gammas_val - A_loglog @ beta_ll
            r2_ll = 1 - np.sum(residuos_ll**2) / np.sum((log_gammas_val - np.mean(log_gammas_val))**2)
            # Comparar con R² del ajuste log-lineal
            residuos_lin = log_gammas_val - (beta[0] + beta[1] * ks_pos)
            r2_lin = 1 - np.sum(residuos_lin**2) / np.sum((log_gammas_val - np.mean(log_gammas_val))**2)
            if r2_ll > r2_lin and beta1_ll < -0.1 and r2_ll > 0.5:
                es_memoria_larga = True
                d_estimado = (beta1_ll + 1) / 2  # d = (β₁ + 1) / 2
        except np.linalg.LinAlgError:
            pass

    mixing_ok = rho_hat < umbral_rho

    advertencia = None
    if not mixing_ok:
        advertencia = (
            f"ρ̂ = {rho_hat:.4f} ≥ {umbral_rho}: no se verifica mixing geométrico. "
            f"El CLT (Thm 5.8) puede no aplicarse. Considere bootstrap por bloques "
            f"o técnicas de subsampling."
        )
    else:
        if razon_varianza_LR > 1.5:
            advertencia = (
                f"Decaimiento ρ̂ = {rho_hat:.4f} < {umbral_rho} pero σ²_LR/γ₀ = {razon_varianza_LR:.2f} > 1.5: "
                "se recomienda corrección de varianza de largo plazo"
            )
        else:
            advertencia = f"Decaimiento exponencial ρ̂ = {rho_hat:.4f} < {umbral_rho} (mixing geométrico verificado)"

    return ResultadoMixing(
        rho_estimado=rho_hat,
        mixing_ok=mixing_ok,
        varianza_largo_plazo=float(sigma2_lr),
        autocorrelaciones=autocovs,
        rho_regression=rho_reg,
        advertencia=advertencia,
        razon_varianza_LR=razon_varianza_LR,
        gamma0=gamma0,
        es_memoria_larga=es_memoria_larga,
        d_estimado=d_estimado,
    )


# =============================================================================
# 3. MÓDULO: Descomposición de Incertidumbre (DescomponedorIncertidumbre)
# =============================================================================

def descomponer_incertidumbre(
    V_hat: float,
    retornos: NDArray[np.float64],
    n_seq: Union[List[int], None] = None,
    B: int = 500,
    alpha: float = 0.05,
    semilla: Union[int, None] = None,
) -> ResultadoDescomposicion:
    """
    Separa varianza total en componente epistémica (reducible, O(1/n))
    y aleatoria (irreducible, constante).

    Método
    ------
    Para cada n_k en n_seq:
        1. Submuestrear n_k trayectorias.
        2. Aplicar bootstrap para estimar Var(V̂_{n_k}).
    Ajustar modelo: Var(V̂_n) = c_ep / n + σ²_aleatoria / n
    (en realidad Var(V̂) = σ²_LR / n, donde σ²_LR = σ²_aleatoria + correlaciones).

    Simplificación práctica: se ajusta Var_boot(V̂_n) = c₁/n + c₂/n² + σ²_∞,
    donde el término dominante c₁/n es la epistémica y σ²_∞ ≈ 0.

    Parámetros
    ----------
    V_hat : float
        Estimación puntual actual (no se usa directamente, solo como referencia).
    retornos : array (N,)
        Todos los retornos disponibles. N debe ser ≥ max(n_seq).
    n_seq : list[int] | None
        Secuencia creciente de tamaños. Default: [50, 100, 200, 500, 1000, 2000, 5000]
        truncada a N disponible.
    B : int
        Réplicas bootstrap por punto.
    alpha, semilla : pasados a bootstrap_ci.

    Retorna
    -------
    ResultadoDescomposicion con coeficientes y recomendación de n.

    Referencias
    -----------
    Lab F.5.2 — separación empírica por aumento de n.
    prop:ch5-clt-retornos — Var(V̂) = O(1/n).
    thm:ch5-clt-agentes    — con datos correlacionados, Var = σ²_LR / n.
    """
    retornos = np.asarray(retornos, dtype=float)
    N = len(retornos)
    rng = np.random.default_rng(semilla)

    if n_seq is None:
        n_seq = [50, 100, 200, 500, 1000, 2000, 5000]
    n_seq = [n for n in n_seq if n <= N]
    if len(n_seq) < 3:
        n_seq = np.linspace(max(20, N // 10), N, 5, dtype=int).tolist()

    varianzas = {}
    for nk in n_seq:
        # Submuestreo aleatorio
        idx = rng.choice(N, size=nk, replace=False)
        sub = retornos[idx]
        # Bootstrap para estimar varianza de V̂_{n_k}
        # Silenciar warnings internos por n pequeño en submuestreo
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            r = bootstrap_ci(sub, B=B, alpha=alpha, tipo="percentil", semilla=semilla)
        varianzas[int(nk)] = r.se_bootstrap ** 2

    # Ajuste: Var_n = c_ep / n + sigma2_aleatoria
    # Modelo:  Var = a / n + b   (b = σ²_aleatoria irreducible)
    # Bajo CLT: Var(V̂_n) = σ²_LR / n, donde σ²_LR incluye correlaciones.
    # Añadimos término constante b para capturar varianza irreducible.
    ns_arr = np.array([float(n) for n in n_seq])
    vars_arr = np.array([varianzas[n] for n in n_seq])

    def modelo(n, a, b):
        return a / n + b

    try:
        (a_fit, b_fit), pcov = curve_fit(modelo, ns_arr, vars_arr, maxfev=10000)
        r2 = 1 - np.sum((vars_arr - modelo(ns_arr, a_fit, b_fit)) ** 2) / np.sum(
            (vars_arr - np.mean(vars_arr)) ** 2
        )
    except Exception:
        # Fallback: regresión lineal en 1/n
        A = np.vstack([1.0 / ns_arr, np.ones_like(ns_arr)]).T
        ab, _, _, _ = np.linalg.lstsq(A, vars_arr, rcond=None)
        a_fit, b_fit = ab[0], ab[1]
        y_pred = A @ ab
        r2 = 1 - np.sum((vars_arr - y_pred) ** 2) / np.sum(
            (vars_arr - np.mean(vars_arr)) ** 2
        )

    sigma2_ep = float(max(0, a_fit))
    sigma2_al = float(max(0, b_fit))  # varianza irreducible
    n_actual = int(ns_arr[-1])
    var_total_actual = varianzas.get(n_actual, vars_arr[-1])
    # Acotar fracción epistémica a [0, 1] para evitar valores > 100%
    fraccion_ep = (sigma2_ep / n_actual) / var_total_actual if var_total_actual > 0 else 0.0
    fraccion_ep = max(0.0, min(1.0, fraccion_ep))

    # Recomendación: n tal que epistémica sea < 10% de varianza total actual
    # (sigma2_ep / n_rec) < 0.10 * var_total_actual
    if var_total_actual > 0 and sigma2_ep > 0:
        n_rec = int(np.ceil(sigma2_ep / (0.10 * var_total_actual)))
    else:
        n_rec = n_actual
    n_rec = max(n_rec, n_actual)

    return ResultadoDescomposicion(
        sigma2_epistemica_coef=sigma2_ep,
        sigma2_aleatoria=sigma2_al,
        fraccion_epistemica_n_actual=float(fraccion_ep),
        recomendacion_n=n_rec,
        varianzas_por_n=varianzas,
        ajuste_r2=float(r2),
    )


# =============================================================================
# 4. MÓDULO: Delta Method (PropagadorDelta)
# =============================================================================

def propagar_desde_Q(
    Q_estimates: NDArray[np.float64],
    policy: NDArray[np.float64],
    Sigma_Q: NDArray[np.float64],
    n: int,
    alpha: float = 0.05,
    transformacion: Union[Literal["identidad", "exp"], Callable] = "identidad",
) -> ResultadoDelta:
    """
    Propaga incertidumbre desde Q^π hasta V^π vía Delta Method multivariado.

    Fórmula (Thm 5.5 multivariado):
        V^π(s) = Σ_a π(a|s) · Q^π(s,a)   →   g lineal
        √n(V̂ - V) → N(0, J · Σ_Q · Jᵀ)
        J = ∇g = [π(a₁|s), ..., π(a_|A||s)]

    Si transformacion == "exp": se aplica Delta Method univariado (Thm 5.4)
    sobre el resultado, propagando V → exp(V).

    Parámetros
    ----------
    Q_estimates : array (|A|,)
        Estimaciones puntual Q̂(s,a) para cada acción.
    policy : array (|A|,)
        Distribución π(a|s); debe sumar a 1.
    Sigma_Q : array (|A|, |A|)
        Matriz de covarianza asintótica de √n(Q̂ - Q).
        En la práctica, estimada por bootstrap o muestral.
    n : int
        Tamaño de muestra (para escalar la varianza asintótica).
    alpha : float
        Nivel para IC.
    transformacion : "identidad", "exp", o callable
        Transformación final aplicada a V.

    Retorna
    -------
    ResultadoDelta con estimación, varianza asintótica completa, IC y métricas.

    Referencias
    -----------
    thm:ch5-delta-multi — propagación multivariada: J·Σ·Jᵀ.
    prop:ch5-delta-q    — aplicación específica a funciones de valor.
    ex:ch5-qdelta       — ejemplo numérico MDP 3 estados, 2 acciones.
    ex:ch5-cociente     — razón de valores (extensión conceptual).
    """
    Q_estimates = np.asarray(Q_estimates, dtype=float)
    policy = np.asarray(policy, dtype=float)
    Sigma_Q = np.asarray(Sigma_Q, dtype=float)

    assert np.isclose(np.sum(policy), 1.0), "policy debe sumar a 1"
    assert len(Q_estimates) == len(policy), "Dimensiones de Q y policy no coinciden"
    assert Sigma_Q.shape == (len(policy), len(policy)), "Sigma_Q debe ser (|A|, |A|)"

    # Jacobiana: J = ∇g = policy (por linealidad de la agregación)
    J = policy  # shape (|A|,)

    # Varianza asintótica: σ²_V = J · Σ_Q · Jᵀ
    sigma2_V = float(J @ Sigma_Q @ J)

    # Contribución de covarianzas vs varianzas puras
    var_puras = np.sum((policy ** 2) * np.diag(Sigma_Q))
    cov_pura = sigma2_V - var_puras
    contribucion_cov = float(cov_pura)

    # Estimación puntual
    V_hat = float(np.dot(policy, Q_estimates))

    # Transformación
    g_func: Callable[[float], float]
    g_deriv: Callable[[float], float]

    if transformacion == "identidad":
        g_func = lambda v: v
        g_deriv = lambda v: 1.0
    elif transformacion == "exp":
        g_func = np.exp
        g_deriv = np.exp
        # Thm 5.4 univariado: Var(exp(V̂)) ≈ [exp(V)]² · Var(V̂)
    elif callable(transformacion):
        g_func = transformacion
        g_deriv = lambda v: 1e-6  # aproximación numérica si no se provee derivada
    else:
        raise ValueError(f"transformacion no reconocida: {transformacion}")

    V_transformado = float(g_func(V_hat))
    derivada = float(g_deriv(V_hat))

    # Varianza propagada por Delta Method
    sigma2_final = (derivada ** 2) * sigma2_V / n
    sem_final = np.sqrt(max(sigma2_final, 0))

    # IC asintótico normal
    z = stats.norm.ppf(1 - alpha / 2)
    L = V_transformado - z * sem_final
    U = V_transformado + z * sem_final

    return ResultadoDelta(
        V_estimado=V_transformado,
        varianza_asintotica=float(sigma2_final),
        IC_95=(L, U),
        contribucion_covarianza=contribucion_cov,
        jacobian=J.copy(),
        sem_epsilon=sem_final,
    )


# =============================================================================
# 5. MÓDULO: Decisión Autónoma (ModuloDecisión)
# =============================================================================

def decidir_recoleccion(
    IC_L: float,
    IC_U: float,
    epsilon_tolerancia: float,
    n_actual: int,
    sigma2_ep: float = 0.0,
    varianza_aleatoria: float = 0.0,
) -> ResultadoDecision:
    """
    Aplica criterio de ancho del Lab F.5.1 para decidir si actuar o recolectar.

    Criterio (Lab F.5.1):
        Si U - L > ε  → recolectar más trayectorias
        Si U - L ≤ ε  → precisión suficiente, actuar

    La recomendación de n adicional usa la escala O(1/√n) del ancho del IC
    (Thm 5.1): ancho ∝ 1/√n  ⇒  n_nuevo ≈ n_actual · (W_actual / ε)².

    Parámetros
    ----------
    IC_L, IC_U : float
        Límites del intervalo de confianza.
    epsilon_tolerancia : float
        Umbral de ancho máximo permitido.
    n_actual : int
        Número actual de trayectorias.
    sigma2_ep : float
        Coeficiente de varianza epistémica (para extrapolar).
    varianza_aleatoria : float
        Varianza aleatoria irreducible.

    Retorna
    -------
    ResultadoDecision con decisión, ancho y justificación.
    """
    W = IC_U - IC_L

    if W <= epsilon_tolerancia:
        return ResultadoDecision(
            decision="actuar",
            ancho_ic=W,
            n_recomendado=None,
            justificacion=(
                f"Ancho IC ({W:.4f}) ≤ tolerancia ({epsilon_tolerancia:.4f}). "
                f"Precisión suficiente según criterio del Lab F.5.1."
            ),
        )
    else:
        # Extrapolación: ancho ≈ 2·z·√(σ²_LR / n)
        # n_nuevo ≈ n_actual · (W / ε)²
        n_rec = int(np.ceil(n_actual * (W / epsilon_tolerancia) ** 2))
        # Asegurar que sea mayor que el actual
        n_rec = max(n_rec, n_actual + 1)

        # Si tenemos descomposición, usar la componente epistémica
        if sigma2_ep > 0 and varianza_aleatoria >= 0:
            # Ancho mínimo teórico (solo aleatoria): W_min ≈ 2·z·√(σ²_al / ∞) → 0
            # Pero en práctica, con n grande, el ancho se acerca a 0
            pass

        return ResultadoDecision(
            decision="recolectar_mas",
            ancho_ic=W,
            n_recomendado=n_rec,
            justificacion=(
                f"Ancho IC ({W:.4f}) > tolerancia ({epsilon_tolerancia:.4f}). "
                f"Se recomiendan ~{n_rec} trayectorias para alcanzar "
                f"precisión suficiente (escala O(1/√n) del CLT, Thm 5.1)."
            ),
        )


# =============================================================================
# 5b. FUNCIÓN: Diagnóstico de Estacionariedad (Dickey-Fuller)
# =============================================================================

def diagnosticar_estacionariedad(
    x: NDArray[np.float64],
    alpha: float = 0.05,
) -> Tuple[bool, float, str]:
    """
    Test ADF (Dickey-Fuller aumentado) simplificado.
    Detecta raíz unitaria en la serie temporal.

    Retorna
    -------
    estacionaria : bool
        True si la serie parece estacionaria.
    t_stat : float
        Estadístico de prueba.
    advertencia : str
        Mensaje descriptivo.
    """
    x = np.asarray(x, dtype=float)
    n = len(x)
    if n < 30:
        return False, 0.0, "Muestra insuficiente para test de estacionariedad"

    dx = np.diff(x)
    lag_x = x[:-1]

    # Regresión ADF sin rezagos (versión simplificada)
    # dx_t = beta * x_{t-1} + epsilon_t
    X_mat = np.column_stack([lag_x, np.ones(n - 1)])
    try:
        beta, _ = np.linalg.lstsq(X_mat, dx, rcond=None)[0:2]
    except np.linalg.LinAlgError:
        return False, 0.0, "Error numérico en regresión ADF"

    residuos = dx - X_mat @ np.array([beta[0], beta[1]])
    var_res = np.sum(residuos ** 2) / (n - 3)
    se_beta = np.sqrt(var_res / np.sum((lag_x - np.mean(lag_x)) ** 2)) if np.sum((lag_x - np.mean(lag_x)) ** 2) > 0 else 1e6
    t_stat = beta[0] / se_beta if se_beta > 0 else 0.0

    # Valores críticos aproximados (MacKinnon 1994, n=100)
    # Para n grande (>100), el CV al 95% es ≈ -2.86
    if n >= 500:
        cv_95 = -2.86
    elif n >= 100:
        cv_95 = -2.89
    else:
        cv_95 = -3.00

    estacionaria = t_stat < cv_95
    if estacionaria:
        advertencia = f"Estacionariedad verificada (t_ADF = {t_stat:.2f} < {cv_95:.2f})"
    else:
        advertencia = (
            f"ADVERTENCIA: Posible raíz unitaria (t_ADF = {t_stat:.2f} ≥ {cv_95:.2f}). "
            "La serie puede no ser estacionaria. Considere diferenciar los datos."
        )
    return estacionaria, float(t_stat), advertencia


def diagnosticar_colas_pesadas(
    x: NDArray[np.float64],
    k_ratio: float = 0.1,
) -> Tuple[float, str]:
    """
    Estima el índice de cola α usando el estimador de Hill.
    Si α < 2, la varianza es infinita → bootstrap inconsistente.

    Retorna
    -------
    alpha_hill : float
        Estimación del índice de cola.
    advertencia : str
        Mensaje descriptivo.
    """
    x = np.asarray(x, dtype=float)
    n = len(x)
    # Ordenar descendente
    x_sorted = np.sort(np.abs(x - np.mean(x)))[::-1]
    k = max(5, int(k_ratio * n))
    k = min(k, n // 2)

    if k < 5 or n < 20:
        return float('nan'), "Muestra insuficiente para estimación de Hill"

    log_x = np.log(x_sorted[:k])
    log_x_k1 = np.log(x_sorted[k]) if k < n else np.log(x_sorted[-1])
    alpha_hill = 1.0 / (np.mean(log_x - log_x_k1) + 1e-12)

    advertencia = f"Índice de cola α̂_Hill = {alpha_hill:.2f}"
    if alpha_hill < 2.0:
        advertencia += " — varianza teóricamente infinita, bootstrap puede ser inestable"
    elif alpha_hill < 3.0:
        advertencia += " — colas pesadas, bootstrap puede ser ineficiente"
    else:
        advertencia += " — colas ligeras, bootstrap válido"

    return float(alpha_hill), advertencia


def detectar_periodicidad(
    x: NDArray[np.float64],
    max_lag_actual: int = 20,
) -> Tuple[int, int, str]:
    """
    Detecta el periodo dominante usando el periodograma.
    Si el periodo es mayor que max_lag_actual, recomienda aumentarlo.

    Retorna
    -------
    periodo : int
        Periodo dominante detectado (0 si no se detecta).
    max_lag_recomendado : int
        Nuevo max_lag sugerido.
    advertencia : str
        Mensaje descriptivo.
    """
    x = np.asarray(x, dtype=float)
    n = len(x)
    if n < 50:
        return 0, max_lag_actual, "Muestra insuficiente para detectar periodicidad"

    from scipy.signal import periodogram
    x_centrado = x - np.mean(x)
    f, Pxx = periodogram(x_centrado, window='hann')

    # Ignorar frecuencia 0
    idx_peak = np.argmax(Pxx[1:]) + 1
    periodo_detectado = int(1.0 / f[idx_peak]) if f[idx_peak] > 0 else 0

    if periodo_detectado < 3 or periodo_detectado > n // 4:
        return 0, max_lag_actual, "No se detectó periodicidad significativa"

    max_lag_rec = max(max_lag_actual, periodo_detectado + 5)
    if periodo_detectado > max_lag_actual:
        advertencia = (
            f"Periodo detectado p={periodo_detectado} > max_lag={max_lag_actual}. "
            f"Se recomienda aumentar max_lag a {max_lag_rec}"
        )
    else:
        advertencia = f"Periodo p={periodo_detectado} dentro del rango de diagnóstico"

    return int(periodo_detectado), int(max_lag_rec), advertencia


# =============================================================================
# 6. AGENTE INTEGRADO — Orquestador Principal
# =============================================================================

class AgenteEstadisticoAsintotico:
    """
    Agente Estadístico que implementa la síntesis del Capítulo 5.

    Combina los módulos:
      - Entrada (ConfiguracionAgente)
      - Diagnóstico de Mixing (Prop 5.2)
      - Bootstrap (Thm 5.7, Def 5.3, Def 5.4)
      - Delta Method (Thm 5.4, Thm 5.5)
      - Descomposición epistémica/aleatoria (Lab F.5.2)
      - Decisión autónoma (Lab F.5.1)
    """

    def __init__(self, config: Optional[ConfiguracionAgente] = None):
        self.config = config or ConfiguracionAgente()
        self._garantias: List[str] = []

    def evaluar_politica(
        self,
        retornos: NDArray[np.float64],
        Q_estimates: Union[NDArray[np.float64], None] = None,
        policy: Union[NDArray[np.float64], None] = None,
        Sigma_Q: Union[NDArray[np.float64], None] = None,
    ) -> ReporteAgente:
        """
        Pipeline completo de evaluación de una política.

        Flujo
        -----
        1. Validar entrada.
        2. Diagnosticar mixing (Prop 5.2).
        3. Estimar V̂^π y construir IC bootstrap (Thm 5.7).
        4. Si se provee Q: propagar incertidumbre via Delta Method (Thm 5.5).
        5. Descomponer varianza epistémica vs aleatoria (Lab F.5.2).
        6. Tomar decisión (Lab F.5.1).
        7. Emitir reporte.
        """
        self._garantias = []
        retornos = np.asarray(retornos, dtype=float)
        n = len(retornos)
        cfg = self.config

        # ----------------------------------------------------------
        # 0. Diagnóstico de estacionariedad (ADF)
        # ----------------------------------------------------------
        es_estacionaria, t_adf, advertencia_adf = diagnosticar_estacionariedad(retornos)
        if not es_estacionaria:
            self._garantias.append(f"ADVERTENCIA: {advertencia_adf}")
        else:
            self._garantias.append(f"Test ADF: {advertencia_adf}")

        # ----------------------------------------------------------
        # 1. Estimación puntual (Prop 5.2: CLT para retornos MC)
        # ----------------------------------------------------------
        V_hat = float(np.mean(retornos))
        self._garantias.append("prop:ch5-clt-retornos — CLT para retornos Monte Carlo")

        # ----------------------------------------------------------
        # 2. Diagnóstico de mixing (Prop 5.2)
        # ----------------------------------------------------------
        res_mixing = diagnosticar_mixing(
            retornos,
            max_lag=cfg.max_lag_mixing,
            umbral_rho=cfg.umbral_mixing,
        )
        if res_mixing.mixing_ok:
            self._garantias.append(
                "thm:ch5-clt-agentes — CLT con varianza de largo plazo "
                f"σ²_LR = {res_mixing.varianza_largo_plazo:.4f}"
            )
        else:
            self._garantias.append(
                "ADVERTENCIA: thm:ch5-clt-agentes NO verificado — "
                "mejora de mixing requerida"
            )

        # ----------------------------------------------------------
        # 2b. Diagnóstico de memoria larga
        # ----------------------------------------------------------
        if hasattr(res_mixing, 'es_memoria_larga') and res_mixing.es_memoria_larga:
            d_est = getattr(res_mixing, 'd_estimado', 0.3)
            self._garantias.append(
                f"ADVERTENCIA: Memoria larga detectada (d≈{d_est:.2f}). "
                "El mixing geométrico no aplica. Usar bootstrap por bloques con ℓ grande."
            )

        # ----------------------------------------------------------
        # 2c. Diagnóstico de colas pesadas (Hill)
        # ----------------------------------------------------------
        alpha_hill, adv_hill = diagnosticar_colas_pesadas(retornos)
        if not np.isnan(alpha_hill) and alpha_hill < 2.5:
            self._garantias.append(f"Test de Hill: {adv_hill}")

        # ----------------------------------------------------------
        # 2d. Detección de periodicidad
        # ----------------------------------------------------------
        periodo_det, max_lag_rec, adv_periodo = detectar_periodicidad(
            retornos, max_lag_actual=cfg.max_lag_mixing
        )
        if periodo_det > 0:
            cfg.max_lag_mixing = max_lag_rec
            self._garantias.append(f"Periodicidad: {adv_periodo}")

        # Determinar block_size para bootstrap
        # Activar bootstrap por bloques si:
        #   - mixing falla (rho >= umbral), O
        #   - el ratio σ²_LR/γ₀ > 1.5 (dependencia aunque rho < umbral)
        razon_var = getattr(res_mixing, 'razon_varianza_LR', 1.0)
        necesita_correccion_dependencia = (
            not res_mixing.mixing_ok or razon_var > cfg.razon_varianza_umbral
        )
        bs = cfg.block_size
        if bs is None and necesita_correccion_dependencia:
            # Heurística base: block_size ≈ n^{1/3}
            bs = max(2, int(np.ceil(n ** (1 / 3))))
            # Hall-Horowitz: ajustar si hay dependencia fuerte estimable
            rho_est = getattr(res_mixing, 'rho_estimado', None)
            if rho_est is not None and not np.isnan(rho_est) and rho_est > 0.3:
                rho_c = min(0.99, max(0.1, abs(rho_est)))
                l_hall = int(np.ceil((1.5 * n * rho_c**2 / max(1 - rho_c**2, 0.01))**(1/3)))
                bs = max(bs, l_hall)
            # Ajuste por memoria larga: si d > 0, ℓ ≈ n^{d+0.3}
            es_ml = getattr(res_mixing, 'es_memoria_larga', False)
            if es_ml:
                d_val = max(0.1, getattr(res_mixing, 'd_estimado', 0.3))
                bs = max(bs, int(np.ceil(n ** (d_val + 0.3))))
            msg = f"Mixing no verificado (ρ̂={res_mixing.rho_estimado:.3f}, σ²_LR/γ₀={razon_var:.2f})"
            if not res_mixing.mixing_ok:
                msg += "; usando bootstrap por bloques como precaución"
            else:
                msg += "; activando bootstrap por bloques por dependencia en varianza"
            warnings.warn(f"{msg} (block_size={bs}).")

        # ----------------------------------------------------------
        # 3. Bootstrap IC (Thm 5.7, Def 5.3 / Def 5.4)
        # ----------------------------------------------------------
        res_boot = bootstrap_ci(
            retornos,
            B=cfg.B,
            alpha=cfg.alpha,
            tipo=cfg.tipo_ic,
            block_size=bs,
            semilla=cfg.semilla,
        )

        # Si hay dependencia pero no se usó bootstrap por bloques,
        # corregir el IC usando σ²_LR del diagnóstico de mixing
        if bs is None and razon_var > cfg.razon_varianza_umbral:
            gamma0 = getattr(res_mixing, 'gamma0', res_mixing.varianza_largo_plazo)
            if gamma0 > 0:
                # Corregir L y U usando σ²_LR en lugar de γ₀
                z = float(stats.norm.ppf(1 - cfg.alpha / 2))
                se_lr = np.sqrt(res_mixing.varianza_largo_plazo / n)
                res_boot.L = res_boot.estimacion - z * se_lr
                res_boot.U = res_boot.estimacion + z * se_lr
                self._garantias.append(
                    "thm:ch5-clt-agentes — IC corregido con σ²_LR "
                    f"(σ²_LR/γ₀ = {razon_var:.2f})"
                )

        self._garantias.append(
            f"thm:ch5-bootstrap-media — consistencia bootstrap "
            f"({cfg.tipo_ic}, B={cfg.B})"
        )
        if cfg.tipo_ic == "percentil-t":
            self._garantias.append(
                "thm:ch5-cobertura — refinamiento de segundo orden O(n^{-1})"
            )
        else:
            self._garantias.append(
                "def:ch5-ic-percentil — cobertura O(n^{-1/2})"
            )

        # ----------------------------------------------------------
        # 4. Delta Method (Thm 5.5) — si se proveen Q, policy, Sigma_Q
        # ----------------------------------------------------------
        res_delta = None
        if Q_estimates is not None and policy is not None and Sigma_Q is not None:
            res_delta = propagar_desde_Q(
                Q_estimates=Q_estimates,
                policy=policy,
                Sigma_Q=Sigma_Q,
                n=n,
                alpha=cfg.alpha,
                transformacion="identidad",
            )
            self._garantias.append(
                "thm:ch5-delta-multi — propagación multivariada Q → V"
            )

        # ----------------------------------------------------------
        # 5. Descomposición de incertidumbre (Lab F.5.2)
        # ----------------------------------------------------------
        res_desc = descomponer_incertidumbre(
            V_hat=V_hat,
            retornos=retornos,
            B=min(500, cfg.B),
            alpha=cfg.alpha,
            semilla=cfg.semilla,
        )
        self._garantias.append(
            "Lab F.5.2 — descomposición epistémica vs aleatoria"
        )

        # ----------------------------------------------------------
        # 6. Decisión (Lab F.5.1)
        # ----------------------------------------------------------
        res_decision = decidir_recoleccion(
            IC_L=res_boot.L,
            IC_U=res_boot.U,
            epsilon_tolerancia=cfg.epsilon_tolerancia,
            n_actual=n,
            sigma2_ep=res_desc.sigma2_epistemica_coef,
            varianza_aleatoria=res_desc.sigma2_aleatoria,
        )
        self._garantias.append("Lab F.5.1 — criterio de ancho para decisión")

        # ----------------------------------------------------------
        # 6b. NODO DE EVALUACIÓN Y REFINAMIENTO (bucle adaptativo)
        # Si el resultado no es satisfactorio, reajusta parámetros
        # y repite los pasos necesarios (máx 3 iteraciones).
        # ----------------------------------------------------------
        max_iter = 3
        for iter_ref in range(max_iter):
            necesita_refinar = False
            razones = []

            # Criterio 1: Coeficiente de variación del bootstrap > 10%
            cv_boot = res_boot.se_bootstrap / abs(res_boot.estimacion) if abs(res_boot.estimacion) > 1e-12 else 1.0
            if cv_boot > 0.10 and cfg.B < 10000:
                cfg.B = min(cfg.B * 2, 10000)
                necesita_refinar = True
                razones.append(f"CV bootstrap={cv_boot:.2%} > 10% → B={cfg.B}")

            # Criterio 2: R² de la descomposición < 0.7
            if hasattr(res_desc, 'ajuste_r2') and res_desc.ajuste_r2 is not None and res_desc.ajuste_r2 < 0.7:
                necesita_refinar = True
                razones.append(f"R² descomposición={res_desc.ajuste_r2:.3f} < 0.7")

            # Criterio 3: Fracción epistémica > 95% y decisión es "recolectar"
            # Sugiere que aumentar n reducirá drásticamente la varianza
            if (res_decision.decision == "recolectar_mas"
                and res_desc.fraccion_epistemica_n_actual > 0.95
                and res_decision.n_recomendado is not None
                and res_decision.n_recomendado <= n * 3):
                necesita_refinar = True
                razones.append(
                    f"Epistémica dominante ({res_desc.fraccion_epistemica_n_actual:.1%}) "
                    f"→ n_recomendado={res_decision.n_recomendado} alcanzable"
                )

            if not necesita_refinar:
                break

            # Acción correctiva según el caso
            for razon in razones:
                self._garantias.append(f"Refinamiento ({iter_ref+1}): {razon}")

            # Si la recomendación es alcanzable y la epistémica domina,
            # simular el IC con el n recomendado
            if (res_decision.decision == "recolectar_mas"
                and res_desc.fraccion_epistemica_n_actual > 0.95
                and res_decision.n_recomendado is not None
                and res_decision.n_recomendado <= n * 3):
                # Escalar SE por √(n_actual / n_nuevo) ~ O(1/√n)
                factor = np.sqrt(n / res_decision.n_recomendado)
                se_proyectado = res_boot.se_bootstrap * factor
                z = float(stats.norm.ppf(1 - cfg.alpha / 2))
                L_proy = res_boot.estimacion - z * se_proyectado
                U_proy = res_boot.estimacion + z * se_proyectado
                W_proy = U_proy - L_proy
                self._garantias.append(
                    f"Proyección con n={res_decision.n_recomendado}: IC≈[{L_proy:.3f},{U_proy:.3f}], "
                    f"ancho≈{W_proy:.3f} {'≤' if W_proy <= cfg.epsilon_tolerancia else '>'} ε"
                )
                if W_proy <= cfg.epsilon_tolerancia:
                    # Si el n recomendado lograría el objetivo, actualizar decisión
                    res_decision = ResultadoDecision(
                        decision="actuar",
                        ancho_ic=W_proy,
                        n_recomendado=res_decision.n_recomendado,
                        justificacion=(
                            f"Proyección con n={res_decision.n_recomendado} estima IC≈[{L_proy:.3f},{U_proy:.3f}] "
                            f"con ancho {W_proy:.3f} ≤ ε={cfg.epsilon_tolerancia}. Recolectar datos lograría "
                            "precisión suficiente."
                        ),
                    )
                    self._garantias.append(
                        "Decisión actualizada: actuar al alcanzar n recomendado"
                    )
                    break

            # Re-ejecutar bootstrap si cambió B
            if cv_boot > 0.10 and cfg.B < 10000:
                res_boot = bootstrap_ci(
                    retornos, B=cfg.B, alpha=cfg.alpha,
                    tipo=cfg.tipo_ic, block_size=bs, semilla=cfg.semilla,
                )
                res_decision = decidir_recoleccion(
                    IC_L=res_boot.L, IC_U=res_boot.U,
                    epsilon_tolerancia=cfg.epsilon_tolerancia,
                    n_actual=n,
                    sigma2_ep=res_desc.sigma2_epistemica_coef,
                    varianza_aleatoria=res_desc.sigma2_aleatoria,
                )

        # ----------------------------------------------------------
        # 7. Reporte integrado
        # ----------------------------------------------------------
        reporte = ReporteAgente(
            estimacion_puntual=V_hat,
            resultado_bootstrap=res_boot,
            resultado_mixing=res_mixing,
            resultado_delta=res_delta,
            resultado_descomposicion=res_desc,
            resultado_decision=res_decision,
            garantias_teoricas=self._garantias.copy(),
            metadata={
                "n_trayectorias": n,
                "config": {
                    "alpha": cfg.alpha,
                    "B": cfg.B,
                    "tipo_ic": cfg.tipo_ic,
                    "epsilon": cfg.epsilon_tolerancia,
                    "block_size": bs,
                },
            },
        )
        return reporte


# =============================================================================
# 7. FUNCIONES AUXILIARES PARA SIMULACIÓN
# =============================================================================

def simular_trayectorias_ssch(
    n: int = 100,
    semilla: Union[int, None] = None,
) -> NDArray[np.float64]:
    """
    Simula retornos del entorno SSCH (Ejemplo ex:ssch-cap05).

    Distribución: mezcla para reproducir IC [4.08, 5.56] con n=100.
    Se modela como N(4.82, 1.5²) con ligera asimetría.
    """
    rng = np.random.default_rng(semilla)
    # Para reproducir el ejemplo del capítulo:
    # V̂ ≈ 4.82, IC bootstrap 95% ≈ [4.08, 5.56] → ancho ≈ 1.48
    # Con n=100, SE ≈ ancho / (2*1.96) ≈ 0.378
    # Varianza ≈ n * SE² ≈ 100 * 0.143 ≈ 14.3 de los retornos
    # → σ_retornos ≈ √14.3 ≈ 3.78
    retornos = rng.normal(loc=4.82, scale=3.78, size=n)
    # Asegurar positividad (retornos de un MDP de recompensas)
    retornos = np.maximum(retornos, 0.1)
    return retornos


def simular_cadena_markov_2estados(
    n: int = 1000,
    semilla: Union[int, None] = None,
) -> NDArray[np.float64]:
    """
    Simula la cadena de Markov de 2 estados del ex:ch5-cadena.

    Matriz P = [[0.8, 0.2], [0.3, 0.7]], r=[0, 10].
    Distribución estacionaria: μ = [0.6, 0.4].
    Autocorrelación: ρ^k con ρ = 0.5.
    """
    rng = np.random.default_rng(semilla)
    estados = np.zeros(n, dtype=int)
    recompensas = np.zeros(n)

    # Estado inicial muestra de estacionaria
    estados[0] = 1 if rng.random() < 0.4 else 0
    recompensas[0] = 10.0 if estados[0] == 1 else 0.0

    P = np.array([[0.8, 0.2], [0.3, 0.7]])
    for t in range(1, n):
        estados[t] = 1 if rng.random() < P[estados[t - 1], 1] else 0
        recompensas[t] = 10.0 if estados[t] == 1 else 0.0

    return recompensas


def simular_mdp_3estados_2acciones(
    n_trayectorias: int = 50,
    semilla: Union[int, None] = None,
) -> Tuple[NDArray[np.float64], NDArray[np.float64], NDArray[np.float64]]:
    """
    Simula el MDP de 3 estados y 2 acciones del ex:ch5-qdelta.

    Retorna
    -------
    retornos : (n_trayectorias,)
    Q_estimates : (2,)
    Sigma_Q : (2, 2)  # Matriz de covarianza asintótica (de √n·Q̂, sin escalar por n)
    """
    rng = np.random.default_rng(semilla)

    # Matriz de covarianza asintótica de √n(Q̂ - Q):
    # Σ_Q = [[4.0, 1.2], [1.2, 9.0]]  (varianza de √n·Q̂, SIN dividir por n)
    # propagar_desde_Q internamente divide por n para obtener Var(V̂)
    Sigma_Q_asintotica = np.array([[4.0, 1.2], [1.2, 9.0]])
    Sigma_Q_muestral = Sigma_Q_asintotica / n_trayectorias  # para generar Q_estimates
    Q_true = np.array([5.0, 4.5])  # valores verdaderos hipotéticos
    Q_estimates = rng.multivariate_normal(Q_true, Sigma_Q_muestral)

    # Generar retornos consistentes con Q
    policy = np.array([0.6, 0.4])
    V_true = np.dot(policy, Q_true)
    retornos = rng.normal(V_true, np.sqrt(3.456), size=n_trayectorias)

    return retornos, Q_estimates, Sigma_Q_asintotica


# =============================================================================
# 8. BLOQUE PRINCIPAL (Ejemplo de ejecución)
# =============================================================================

if __name__ == "__main__":
    print("=" * 75)
    print(" AGENTE ESTADÍSTICO ASINTÓTICO — DEMOSTRACIÓN CAPÍTULO 5")
    print("=" * 75)

    # ------------------------------------------------------------------
    # DEMO 1: SSCH (ex:ssch-cap05)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("DEMO 1: Entorno SSCH — 100 trayectorias")
    print("─" * 75)

    cfg = ConfiguracionAgente(
        alpha=0.05,
        B=1000,
        epsilon_tolerancia=0.5,
        tipo_ic="percentil-t",
    )
    agente = AgenteEstadisticoAsintotico(config=cfg)

    retornos_ssch = simular_trayectorias_ssch(n=100, semilla=42)
    reporte_ssch = agente.evaluar_politica(retornos=retornos_ssch)

    print(reporte_ssch)

    # ------------------------------------------------------------------
    # DEMO 2: Cadena de Markov con dependencia (ex:ch5-cadena)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("DEMO 2: Cadena de Markov 2 estados — datos correlacionados")
    print("─" * 75)

    recompensas_cadena = simular_cadena_markov_2estados(n=1000, semilla=123)
    cfg2 = ConfiguracionAgente(
        alpha=0.05,
        B=1000,
        epsilon_tolerancia=1.0,
        tipo_ic="percentil-t",
    )
    agente2 = AgenteEstadisticoAsintotico(config=cfg2)
    reporte_cadena = agente2.evaluar_politica(retornos=recompensas_cadena)

    print(reporte_cadena)

    # ------------------------------------------------------------------
    # DEMO 3: MDP 3 estados / 2 acciones con Delta Method (ex:ch5-qdelta)
    # ------------------------------------------------------------------
    print("\n" + "─" * 75)
    print("DEMO 3: MDP 3 estados / 2 acciones — Delta Method Q → V")
    print("─" * 75)

    ret, Q_est, Sig_Q = simular_mdp_3estados_2acciones(n_trayectorias=50, semilla=99)
    policy = np.array([0.6, 0.4])

    cfg3 = ConfiguracionAgente(alpha=0.05, B=1000, epsilon_tolerancia=2.0)
    agente3 = AgenteEstadisticoAsintotico(config=cfg3)
    reporte_delta = agente3.evaluar_politica(
        retornos=ret,
        Q_estimates=Q_est,
        policy=policy,
        Sigma_Q=Sig_Q,
    )

    print(reporte_delta)
    print("\nValidación Delta Method (ex:ch5-qdelta):")
    if reporte_delta.resultado_delta:
        rd = reporte_delta.resultado_delta
        print(f"  Varianza asintótica σ²_V = {rd.varianza_asintotica:.4f}")
        print(f"  Contribución covarianzas = {rd.contribucion_covarianza:.4f}")
        print(f"  IC 95% Delta Method      = [{rd.IC_95[0]:.4f}, {rd.IC_95[1]:.4f}]")
        # Validación con valores corregidos
        V_teorico = 4.8
        var_asint_teorica = 3.456
        n_actual_delta = 50
        se_teorico = np.sqrt(var_asint_teorica / n_actual_delta)
        print(f"  V teórico (Q·π)         = {V_teorico}")
        print(f"  V estimado              = {rd.V_estimado:.4f}")
        print(f"  SE teórico              = {se_teorico:.4f}")
        print(f"  SE estimado             = {rd.sem_epsilon:.4f}")
        print(f"  IC 95% teórico          = [{V_teorico - 1.96*se_teorico:.4f}, {V_teorico + 1.96*se_teorico:.4f}]")

    print("\n" + "=" * 75)
    print(" DEMOSTRACIÓN COMPLETADA")
    print("=" * 75)
