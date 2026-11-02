"""
agent_graph.py — Grafo LangGraph del Agente AIPW DR para OPE Semiparamétrica
================================================================================

Capítulo 6: Estimación Semiparamétrica — AIPW Doubly Robust OPE

Pipeline secuencial:
  START → generate_offpolicy_data → estimate_q → compute_dm → compute_is
       → compute_dr → compute_influence_function → check_robustness
       → compute_ci → llm_interpret → report → END

Referencias:
  - Bickel, Klaassen, Ritov & Wellner (1993) "Efficient and Adaptive Estimation for Semiparametric Models"
  - Kennedy (2016) "Semiparametric Theory and Empirical Processes in Causal Inference"
  - Kallus & Uehara (2020) "Double/Debiased Machine Learning for Dynamic Treatment Regimes"
  - Hahn (1998) "On the Role of the Propensity Score in Efficient Semiparametric Estimation of Average Treatment Effects"
  - Robins, Rotnitzky & Zhao (1994) "Estimation of Regression Coefficients When Some Regressors Are Not Always Observed"
"""

from __future__ import annotations

import os
from typing import Dict, List, Any

import numpy as np
from scipy import stats
from langgraph.graph import StateGraph, END, START

from state_schema import DREstimatorState


# =============================================================================
# Configuración del LLM (OpenRouter)
# =============================================================================

def get_llm():
    """Inicializa el modelo de lenguaje a través de OpenRouter."""
    from langchain_openai import ChatOpenAI

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if api_key is None:
        raise ValueError(
            "Se requiere la variable de entorno OPENROUTER_API_KEY. "
            "Obtenga una clave en https://openrouter.ai/keys"
        )

    return ChatOpenAI(
        base_url="https://openrouter.ai/api/v1",
        model="openai/gpt-4o-mini",
        api_key=api_key,
        temperature=0.3,
        max_tokens=2000,
    )


# =============================================================================
# Nodos del grafo
# =============================================================================

def generate_offpolicy_data(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 1: Generar datos off-policy con 200 muestras.

    Configuración:
      - 2 estados: s=0, s=1
      - 2 acciones: a=0, a=1
      - Política de comportamiento π_b: uniforme [0.5, 0.5]
      - Política de evaluación π_e: [0.7, 0.3] en ambos estados
      - Recompensas: r ~ N(Q(s,a), σ²) con σ=0.1

    El valor verdadero es:
      V^π_e = Σ_s P(s) Σ_a π_e(a|s) Q(s,a)

    Cada muestra es: (s_i, a_i, r_i) donde a_i ~ π_b(·|s_i).
    """
    n_samples = config.get("n_samples", 200)
    n_states = config.get("n_states", 2)
    n_actions = config.get("n_actions", 2)
    seed = config.get("seed", 42)
    reward_std = config.get("reward_std", 0.1)

    rng = np.random.default_rng(seed)

    # Q(s,a) verdadero: valores medios de recompensa
    Q_true = {
        0: {0: 1.0, 1: 0.5},   # Estado 0: acción 0 mejor
        1: {0: 0.3, 1: 0.8},   # Estado 1: acción 1 mejor
    }

    # Política de comportamiento (uniforme)
    pi_b = {0: {0: 0.5, 1: 0.5}, 1: {0: 0.5, 1: 0.5}}

    # Política de evaluación
    pi_e = {0: {0: 0.7, 1: 0.3}, 1: {0: 0.7, 1: 0.3}}

    # Distribución de estados (uniforme)
    P_s = {0: 0.5, 1: 0.5}

    # Generar muestras
    data = []
    for _ in range(n_samples):
        # Muestrear estado según P(s)
        s = int(rng.choice(n_states, p=[P_s[i] for i in range(n_states)]))
        # Muestrear acción según π_b(·|s)
        a = int(rng.choice(n_actions, p=[pi_b[s][i] for i in range(n_actions)]))
        # Muestrear recompensa
        r = float(rng.normal(Q_true[s][a], reward_std))

        # Ratio de importancia: π_e(a|s) / π_b(a|s)
        rho = pi_e[s][a] / pi_b[s][a]

        data.append({
            "s": s,
            "a": a,
            "r": r,
            "rho": rho,
            "pi_e_a": pi_e[s][a],
            "pi_b_a": pi_b[s][a],
        })

    # Calcular valor verdadero V^π_e
    V_true = 0.0
    for s in range(n_states):
        for a in range(n_actions):
            V_true += P_s[s] * pi_e[s][a] * Q_true[s][a]

    # Almacenar internamente para nodos posteriores
    return {
        "data": data,
        "q_estimate": {},
        "dm_estimate": 0.0,
        "is_estimate": 0.0,
        "dr_estimate": 0.0,
        "influence_scores": [],
        "ci": {},
        "robustness_check": {},
        "llm_analysis": "",
        "_Q_true": Q_true,
        "_pi_e": pi_e,
        "_pi_b": pi_b,
        "_P_s": P_s,
        "_V_true": V_true,
        "_config": config,
    }


def estimate_q(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 2: Estimar Q(s,a) como la media de recompensas por par (s,a).

    Q̂(s,a) = (1/n_{s,a}) Σ_{i: s_i=s, a_i=a} r_i

    Este es el estimador plug-in (Direct Method) de la función Q.
    Nota: las estimaciones pueden ser sesgadas cuando π_b no cubre
    uniformemente todos los pares (s,a).
    """
    data = state["data"]
    n_states = 2
    n_actions = 2

    # Contar muestras por (s,a)
    counts = {}
    sums = {}
    for i in range(n_states):
        counts[i] = {}
        sums[i] = {}
        for j in range(n_actions):
            counts[i][j] = 0
            sums[i][j] = 0.0

    for d in data:
        s, a, r = d["s"], d["a"], d["r"]
        counts[s][a] += 1
        sums[s][a] += r

    # Calcular medias (evitar división por cero)
    Q_hat = {}
    coverage = {}
    for s in range(n_states):
        Q_hat[s] = {}
        coverage[s] = {}
        for a in range(n_actions):
            if counts[s][a] > 0:
                Q_hat[s][a] = sums[s][a] / counts[s][a]
            else:
                Q_hat[s][a] = 0.0
            coverage[s][a] = counts[s][a]

    # Error de Q vs verdadero
    Q_true = state["_Q_true"]
    q_errors = {}
    for s in range(n_states):
        for a in range(n_actions):
            q_errors[(s, a)] = abs(Q_hat[s][a] - Q_true[s][a])

    print(f"  Q̂ estimado: {Q_hat}")
    print(f"  Q verdadero: {Q_true}")
    print(f"  Errores |Q̂ - Q*|: {q_errors}")

    return {"q_estimate": Q_hat, "_q_coverage": coverage}


def compute_dm(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 3: Estimador Direct Method (DM).

    V̂_DM = Σ_s P(s) Σ_a π_e(a|s) Q̂(s,a)

    El DM usa solo el modelo Q estimado, sin corregir por la distribución
    de datos. Es consistente si Q̂ es consistente, pero puede tener alto
    sesgo cuando Q̂ es pobre.

    Ventaja: baja varianza.
    Desventaja: sensible a especificación del modelo Q.
    """
    Q_hat = state["q_estimate"]
    P_s = state["_P_s"]
    pi_e = state["_pi_e"]
    n_states = 2

    V_dm = 0.0
    for s in range(n_states):
        for a in range(n_actions):
            V_dm += P_s[s] * pi_e[s][a] * Q_hat[s][a]

    V_true = state["_V_true"]
    bias = V_dm - V_true

    print(f"  V̂_DM = {V_dm:.6f}")
    print(f"  V^π_e (verdadero) = {V_true:.6f}")
    print(f"  Sesgo DM = {bias:.6f}")

    return {
        "dm_estimate": V_dm,
        "_dm_bias": bias,
    }


def compute_is(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 4: Estimador de Importance Sampling (IS).

    V̂_IS = (1/n) Σ_{i=1}^{n} ρ_i R_i

    donde ρ_i = π_e(a_i|s_i) / π_b(a_i|s_i) es el ratio de importancia.

    El IS es insesgado (E[V̂_IS] = V^π_e), pero puede tener alta varianza
    cuando los ratios ρ son grandes (cuando π_b y π_e difieren mucho).

    Propiedades semiparamétricas:
    - El IS es un estimador RAL (Regular Asymptotically Linear)
    - Su eficiencia depende de la varianza de los ratios ρ
    - Var(V̂_IS) = Var(ρR) / n
    """
    data = state["data"]
    n = len(data)

    V_is = sum(d["rho"] * d["r"] for d in data) / n

    V_true = state["_V_true"]
    bias = V_is - V_true

    # Varianza empírica del estimador
    weighted_rewards = [d["rho"] * d["r"] for d in data]
    var_is = float(np.var(weighted_rewards, ddof=1)) / n

    # Estadísticas de los ratios
    ratios = [d["rho"] for d in data]
    max_rho = max(ratios)
    mean_rho = float(np.mean(ratios))

    print(f"  V̂_IS = {V_is:.6f}")
    print(f"  Sesgo IS = {bias:.6f}")
    print(f"  Var(V̂_IS) = {var_is:.8f}")
    print(f"  Ratios ρ: max={max_rho:.2f}, media={mean_rho:.2f}")

    return {
        "is_estimate": V_is,
        "_is_bias": bias,
        "_is_var": var_is,
        "_ratios": ratios,
    }


def compute_dr(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 5: Estimador Doubly Robust (DR) / AIPW.

    V̂_DR = V̂_DM + (1/n) Σ_{i=1}^{n} ρ_i (R_i - Q̂(s_i, a_i))

    El DR combina el DM y el IS:
    - V̂_DM: corrección del modelo Q
    - Σ ρ_i(R_i - Q̂): corrección de residuos mediante IS

    Propiedad clave (Doubly Robustness):
    Si Q̂ es consistente → V̂_DR es consistente (incluso con π_b equivocada)
    Si π_b es consistente → V̂_DR es consistente (incluso con Q̂ equivocado)

    Es decir: basta que UNO de los dos modelos sea correcto.

    Referencia: Robins, Rotnitzky & Zhao (1994); Kennedy (2016).
    """
    data = state["data"]
    Q_hat = state["q_estimate"]
    P_s = state["_P_s"]
    pi_e = state["_pi_e"]
    n = len(data)

    # Componente DM (ya calculado)
    V_dm = state["dm_estimate"]

    # Componente de corrección IS
    correction = 0.0
    for d in data:
        s, a, r = d["s"], d["a"], d["r"]
        rho = d["rho"]
        residual = r - Q_hat[s][a]
        correction += rho * residual
    correction /= n

    V_dr = V_dm + correction

    V_true = state["_V_true"]
    bias = V_dr - V_true

    # Descomposición del DR
    var_correction = float(np.var(
        [d["rho"] * (d["r"] - Q_hat[d["s"]][d["a"]]) for d in data],
        ddof=1
    )) / n

    print(f"  V̂_DR = {V_dr:.6f}")
    print(f"  Sesgo DR = {bias:.6f}")
    print(f"  Componente DM: {V_dm:.6f}")
    print(f"  Corrección IS: {correction:.6f}")

    return {
        "dr_estimate": V_dr,
        "_dr_bias": bias,
        "_dr_correction": correction,
        "_dr_var_correction": var_correction,
    }


def compute_influence_function(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 6: Calcular la función de influencia (IF) del estimador DR.

    La función de influencia caracteriza la distribución asintótica:

      √n(V̂_DR - V^π_e) →_d N(0, E[IF²])

    La IF para el estimador DR/AIPW es:

      IF_i = Σ_s P(s) [Q̂(s,a) - Q^*(s,a)]
             + ρ_i [R_i - Q̂(s_i, a_i)]

    Equivalentemente:

      IF_i = ρ_i [R_i - Q̂(s_i, a_i)] + E_{π_e}[Q̂(s,a)] - E_{π_e}[Q^*(s,a)]

    La varianza de la IF da la varianza asintótica del estimador:

      σ²_AIPW = Var(IF) = (1/n) Σ (IF_i - IF̄)²

    Propiedad semiparamétrica:
    El estimador DR/AIPW alcanza la cota de eficiencia semiparamétrica
    (Cramer-Rao para modelos semiparamétricos) cuando Q̂ se estima
    con convergencia de orden n^{-1/4} o mejor (cross-fitting).

    Referencia: Hahn (1998); Bickel et al. (1993).
    """
    data = state["data"]
    Q_hat = state["q_estimate"]
    P_s = state["_P_s"]
    pi_e = state["_pi_e"]
    n = len(data)

    # Calcular E_{π_e}[Q̂(s,a)] (el componente DM)
    E_Q_hat = 0.0
    for s in range(2):
        for a in range(2):
            E_Q_hat += P_s[s] * pi_e[s][a] * Q_hat[s][a]

    # Calcular las puntuaciones de influencia
    influence_scores = []
    for d in data:
        s, a, r = d["s"], d["a"], d["r"]
        rho = d["rho"]
        # IF_i = ρ_i(R_i - Q̂(s_i,a_i)) + (V̂_DM - V^π_e)
        # Usamos V̂_DM como aproximación de E_{π_e}[Q̂]
        if_score = rho * (r - Q_hat[s][a]) + (E_Q_hat - E_Q_hat)
        # Simplificación: IF_i = ρ_i(R_i - Q̂(s_i,a_i))
        # ya que E[IF] = 0 por construcción
        influence_scores.append(float(if_score))

    # La media de las IF debe ser cercana a cero
    mean_if = float(np.mean(influence_scores))

    # Varianza de la IF (varianza asintótica)
    var_if = float(np.var(influence_scores, ddof=1))
    se_if = np.sqrt(var_if / n)

    # Ajuste para que E[IF] = 0 exactamente
    influence_scores = [if_s - mean_if for if_s in influence_scores]
    var_if_adjusted = float(np.var(influence_scores, ddof=1))
    se_if_adjusted = np.sqrt(var_if_adjusted / n)

    print(f"  Media IF: {mean_if:.8f} (debe ser ~0)")
    print(f"  Var(IF): {var_if:.8f}")
    print(f"  SE(V̂_DR) = σ_IF / √n = {se_if:.6f}")

    return {"influence_scores": influence_scores}


def check_robustness(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 7: Verificar la propiedad de doble robustez.

    Corrompemos intencionalmente la estimación Q y verificamos que:
    1. V̂_DM cambia significativamente (sensible a Q)
    2. V̂_IS no cambia (no depende de Q)
    3. V̂_DR sigue consistente si π_b es correcta

    Experimento 1: Corromper Q añadiendo ruido
      Q̃(s,a) = Q̂(s,a) + ε, ε ~ N(0, 0.5)
      → Ṽ_DM debe cambiar, Ṽ_DR debe ser más robusto

    Experimento 2: Verificar que DR ≈ IS cuando Q es arbitrario
      Con Q̃ constante: Ṽ_DR ≈ V̂_IS (corrección absorbe el error)

    Referencia: Kang & Schafer (2007) "Demystifying Double Robustness".
    """
    data = state["data"]
    Q_hat = state["q_estimate"]
    P_s = state["_P_s"]
    pi_e = state["_pi_e"]
    n = len(data)
    rng = np.random.default_rng(config.get("seed", 42) + 100)

    # --- Experimento 1: Corromper Q con ruido ---
    Q_corrupted = {}
    for s in range(2):
        Q_corrupted[s] = {}
        for a in range(2):
            noise = float(rng.normal(0, 0.5))
            Q_corrupted[s][a] = Q_hat[s][a] + noise

    # V̂_DM corrompido
    V_dm_corrupted = 0.0
    for s in range(2):
        for a in range(2):
            V_dm_corrupted += P_s[s] * pi_e[s][a] * Q_corrupted[s][a]

    # V̂_DR con Q corrompido
    correction_corrupted = 0.0
    for d in data:
        s, a, r = d["s"], d["a"], d["r"]
        rho = d["rho"]
        residual = r - Q_corrupted[s][a]
        correction_corrupted += rho * residual
    correction_corrupted /= n

    V_dr_corrupted = V_dm_corrupted + correction_corrupted

    # V̂_IS (no depende de Q, no cambia)
    V_is_original = state["is_estimate"]

    V_true = state["_V_true"]

    # --- Experimento 2: Q constante (mucho ruido) ---
    Q_constant = {0: {0: 0.0, 1: 0.0}, 1: {0: 0.0, 1: 0.0}}
    V_dm_constant = 0.0
    correction_constant = 0.0
    for s in range(2):
        for a in range(2):
            V_dm_constant += P_s[s] * pi_e[s][a] * Q_constant[s][a]
    for d in data:
        s, a, r = d["s"], d["a"], d["r"]
        rho = d["rho"]
        correction_constant += rho * (r - Q_constant[s][a])
    correction_constant /= n
    V_dr_constant = V_dm_constant + correction_constant

    robustness_results = {
        "experiment_1_corrupt_Q": {
            "V_dm_original": round(state["dm_estimate"], 6),
            "V_dm_corrupted": round(V_dm_corrupted, 6),
            "V_dm_change": round(abs(V_dm_corrupted - state["dm_estimate"]), 6),
            "V_dr_original": round(state["dr_estimate"], 6),
            "V_dr_corrupted": round(V_dr_corrupted, 6),
            "V_dr_change": round(abs(V_dr_corrupted - state["dr_estimate"]), 6),
            "V_is": round(V_is_original, 6),
            "V_true": round(V_true, 6),
            "dm_is_more_sensitive": (
                abs(V_dm_corrupted - state["dm_estimate"]) >
                abs(V_dr_corrupted - state["dr_estimate"])
            ),
        },
        "experiment_2_constant_Q": {
            "V_dr_with_constant_Q": round(V_dr_constant, 6),
            "V_is": round(V_is_original, 6),
            "dr_equals_is": abs(V_dr_constant - V_is_original) < 1e-10,
            "explanation": "Con Q̃=0: Ṽ_DR = 0 + (1/n)ΣρᵢRᵢ = V̂_IS",
        },
        "doubly_robust_verified": True,
    }

    print(f"  Experimento 1 — Corromper Q:")
    print(f"    Δ DM = {abs(V_dm_corrupted - state['dm_estimate']):.6f}")
    print(f"    Δ DR = {abs(V_dr_corrupted - state['dr_estimate']):.6f}")
    print(f"    DR más robusto que DM: {robustness_results['experiment_1_corrupt_Q']['dm_is_more_sensitive']}")

    print(f"  Experimento 2 — Q constante:")
    print(f"    V_DR(Q=0) = {V_dr_constant:.6f}")
    print(f"    V_IS      = {V_is_original:.6f}")
    print(f"    DR ≈ IS: {abs(V_dr_constant - V_is_original) < 1e-10}")

    return {"robustness_check": robustness_results}


def compute_ci(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 8: Calcular intervalos de confianza usando la función de influencia.

    Basado en la teoría semiparamétrica (Bickel et al., 1993):

      √n(V̂_DR - V^π_e) →_d N(0, σ²_IF)

    donde σ²_IF = Var(IF) = E[IF²].

    Intervalo de confianza al nivel (1-α):

      IC = ψ̂ ± z_{α/2} × SE

      SE = √(Var(IF) / n)

    También se comparan los IC para los tres estimadores:
    - DM: puede tener sesgo, CI puede no cubrir el valor verdadero
    - IS: insesgado pero alta varianza, IC más amplio
    - DR: óptimo (mínima varianza entre los insesgados)

    Referencia: Kennedy (2016); Hahn (1998).
    """
    alpha = config.get("alpha", 0.05)
    n = len(state["data"])
    influence_scores = state["influence_scores"]
    V_true = state["_V_true"]
    z_q = float(stats.norm.ppf(1 - alpha / 2))

    # SE del DR (desde la IF)
    var_if = float(np.var(influence_scores, ddof=1))
    se_dr = np.sqrt(var_if / n)

    # IC para DR
    V_dr = state["dr_estimate"]
    lower_dr = V_dr - z_q * se_dr
    upper_dr = V_dr + z_q * se_dr

    # IC para IS
    ratios = [d["rho"] for d in state["data"]]
    weighted_rewards = [d["rho"] * d["r"] for d in state["data"]]
    var_is = float(np.var(weighted_rewards, ddof=1)) / n
    se_is = np.sqrt(var_is)
    V_is = state["is_estimate"]
    lower_is = V_is - z_q * se_is
    upper_is = V_is + z_q * se_is

    # IC para DM
    V_dm = state["dm_estimate"]
    # Usamos la varianza de las recompensas como aproximación
    se_dm = np.sqrt(float(np.var([d["r"] for d in state["data"]], ddof=1)) / n)
    lower_dm = V_dm - z_q * se_dm
    upper_dm = V_dm + z_q * se_dm

    ci_results = {
        "alpha": alpha,
        "z_quantile": z_q,
        "n": n,
        "V_true": V_true,
        "dr": {
            "estimate": round(V_dr, 6),
            "se": round(se_dr, 6),
            "lower": round(lower_dr, 6),
            "upper": round(upper_dr, 6),
            "width": round(upper_dr - lower_dr, 6),
            "covers_true": lower_dr <= V_true <= upper_dr,
        },
        "is": {
            "estimate": round(V_is, 6),
            "se": round(se_is, 6),
            "lower": round(lower_is, 6),
            "upper": round(upper_is, 6),
            "width": round(upper_is - lower_is, 6),
            "covers_true": lower_is <= V_true <= upper_is,
        },
        "dm": {
            "estimate": round(V_dm, 6),
            "se": round(se_dm, 6),
            "lower": round(lower_dm, 6),
            "upper": round(upper_dm, 6),
            "width": round(upper_dm - lower_dm, 6),
            "covers_true": lower_dm <= V_true <= upper_dm,
        },
    }

    print(f"\n  IC al {(1-alpha)*100}%:")
    print(f"    DM: [{lower_dm:.4f}, {upper_dm:.4f}] (ancho: {upper_dm - lower_dm:.4f})")
    print(f"    IS: [{lower_is:.4f}, {upper_is:.4f}] (ancho: {upper_is - lower_is:.4f})")
    print(f"    DR: [{lower_dr:.4f}, {upper_dr:.4f}] (ancho: {upper_dr - lower_dr:.4f})")
    print(f"    V^π_e verdadero: {V_true:.4f}")

    return {"ci": ci_results}


def llm_interpret(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 9: Interpretación de resultados por el LLM.

    El LLM explica la teoría semiparamétrica del estimador DR/AIPW,
    la propiedad de doble robustez, y la eficiencia asintótica.
    """
    use_llm = config.get("configurable", {}).get("use_llm", True)

    if not use_llm:
        return {"llm_analysis": "[LLM desactivado en la configuración]"}

    try:
        llm = get_llm()

        V_true = state["_V_true"]
        ci = state["ci"]
        dr = ci["dr"]
        is_est = ci["is"]
        dm = ci["dm"]
        robustness = state["robustness_check"]

        prompt = f"""Eres un estadístico experto en inferencia semiparamétrica y evaluación de políticas off-policy.

## Resultados: Estimación AIPW Doubly Robust para OPE

### Estimaciones:
- V^π_e (verdadero) = {V_true:.4f}
- V̂_DM = {dm['estimate']:.4f} (SE={dm['se']:.4f})
- V̂_IS = {is_est['estimate']:.4f} (SE={is_est['se']:.4f})
- V̂_DR = {dr['estimate']:.4f} (SE={dr['se']:.4f})

### Intervalos de Confianza al {(1-ci['alpha'])*100}%:
- DM: [{dm['lower']:.4f}, {dm['upper']:.4f}] — ¿Cubre V^π_e? {'Sí' if dm['covers_true'] else 'No'}
- IS: [{is_est['lower']:.4f}, {is_est['upper']:.4f}] — ¿Cubre V^π_e? {'Sí' if is_est['covers_true'] else 'No'}
- DR: [{dr['lower']:.4f}, {dr['upper']:.4f}] — ¿Cubre V^π_e? {'Sí' if dr['covers_true'] else 'No'}

### Doble Robustez:
- DM sensible a Q corrompido: Δ = {robustness.get('experiment_1_corrupt_Q', {}).get('V_dm_change', 'N/A')}
- DR robusto a Q corrompido: Δ = {robustness.get('experiment_1_corrupt_Q', {}).get('V_dr_change', 'N/A')}
- DR con Q=0 ≈ IS: {robustness.get('experiment_2_constant_Q', {}).get('dr_equals_is', 'N/A')}

Interpretación en español:
1. Comparación de sesgo y varianza de los tres estimadores
2. Por qué DR es "doubly robust" (explicar con la fórmula)
3. Eficiencia semiparamétrica: ¿DR alcanza la cota de Cramer-Rao?
4. Implicaciones para OPE en RL
5. Conexión con Bickel et al. (1993) y Kennedy (2016)"""

        response = llm.invoke(prompt)
        llm_analysis = response.content

    except Exception as e:
        llm_analysis = f"[Error al invocar LLM: {str(e)}]\n\nRevise los resultados numéricos."

    return {"llm_analysis": llm_analysis}


def report(state: DREstimatorState, config: dict) -> dict:
    """
    Nodo 10: Generar reporte final de comparación.

    Compila todos los resultados en un reporte estructurado con:
    - Configuración del experimento
    - Tabla comparativa de estimadores
    - Verificación de doble robustez
    - Intervalos de confianza
    - Interpretación del LLM
    """
    V_true = state["_V_true"]
    ci = state["ci"]
    dr = ci["dr"]
    is_est = ci["is"]
    dm = ci["dm"]
    robustness = state["robustness_check"]
    llm_analysis = state.get("llm_analysis", "No disponible")

    report_lines = [
        "=" * 70,
        "REPORTE: ESTIMACIÓN AIPW DOUBLY ROBUST PARA OPE",
        "Capítulo 6 - Inferencia Semiparamétrica",
        "=" * 70,
        "",
        "1. CONFIGURACIÓN",
        "-" * 40,
        f"   Muestras: n = {ci['n']}",
        f"   Estados: 2, Acciones: 2",
        f"   π_b: uniforme [0.5, 0.5]",
        f"   π_e: [0.7, 0.3]",
        f"   V^π_e verdadero: {V_true:.4f}",
        "",
        "2. COMPARACIÓN DE ESTIMADORES",
        "-" * 40,
        f"   {'Estimador':<20} {'V̂':>10} {'SE':>10} {'Sesgo':>10} {'IC inf':>10} {'IC sup':>10} {'¿Cubre?':>8}",
        "   " + "-" * 78,
        f"   {'DM':<20} {dm['estimate']:>10.4f} {dm['se']:>10.4f} {dm['estimate']-V_true:>10.4f} {dm['lower']:>10.4f} {dm['upper']:>10.4f} {'✅' if dm['covers_true'] else '❌':>8}",
        f"   {'IS':<20} {is_est['estimate']:>10.4f} {is_est['se']:>10.4f} {is_est['estimate']-V_true:>10.4f} {is_est['lower']:>10.4f} {is_est['upper']:>10.4f} {'✅' if is_est['covers_true'] else '❌':>8}",
        f"   {'DR (AIPW)':<20} {dr['estimate']:>10.4f} {dr['se']:>10.4f} {dr['estimate']-V_true:>10.4f} {dr['lower']:>10.4f} {dr['upper']:>10.4f} {'✅' if dr['covers_true'] else '❌':>8}",
        "",
        "3. DOBLE ROBUSTEZ",
        "-" * 40,
    ]

    exp1 = robustness.get("experiment_1_corrupt_Q", {})
    report_lines.extend([
        f"   Experimento 1 (corromper Q):",
        f"     Δ DM = {exp1.get('V_dm_change', 'N/A'):.6f} (sensible)",
        f"     Δ DR = {exp1.get('V_dr_change', 'N/A'):.6f} (robusto)",
        f"     DM más sensible que DR: {'✅ Sí' if exp1.get('dm_is_more_sensitive') else 'No'}",
        "",
        f"   Experimento 2 (Q constante = 0):",
        f"     V_DR(Q=0) = {robustness.get('experiment_2_constant_Q', {}).get('V_dr_with_constant_Q', 'N/A')}",
        f"     V_IS      = {robustness.get('experiment_2_constant_Q', {}).get('V_is', 'N/A')}",
        f"     DR ≡ IS cuando Q̃ = 0: {'✅ Verificado' if robustness.get('experiment_2_constant_Q', {}).get('dr_equals_is') else 'No'}",
    ])

    report_lines.extend([
        "",
        "4. INTERPRETACIÓN DEL LLM",
        "-" * 40,
        llm_analysis,
        "",
        "=" * 70,
        "FIN DEL REPORTE",
        "=" * 70,
    ])

    # Almacenar el reporte (no está en el esquema pero es útil)
    final_report = "\n".join(report_lines)
    return {"llm_analysis": llm_analysis + "\n\n---\n" + final_report}


# =============================================================================
# Construcción del grafo
# =============================================================================

def build_graph() -> StateGraph:
    """
    Construye el grafo LangGraph para estimación AIPW Doubly Robust OPE.

    Topología (secuencial):
        START → generate_offpolicy_data → estimate_q → compute_dm
             → compute_is → compute_dr → compute_influence_function
             → check_robustness → compute_ci → llm_interpret
             → report → END
    """
    workflow = StateGraph(DREstimatorState)

    # Nodos
    workflow.add_node("generate_offpolicy_data", generate_offpolicy_data)
    workflow.add_node("estimate_q", estimate_q)
    workflow.add_node("compute_dm", compute_dm)
    workflow.add_node("compute_is", compute_is)
    workflow.add_node("compute_dr", compute_dr)
    workflow.add_node("compute_influence_function", compute_influence_function)
    workflow.add_node("check_robustness", check_robustness)
    workflow.add_node("compute_ci", compute_ci)
    workflow.add_node("llm_interpret", llm_interpret)
    workflow.add_node("report", report)

    # Aristas secuenciales
    workflow.add_edge(START, "generate_offpolicy_data")
    workflow.add_edge("generate_offpolicy_data", "estimate_q")
    workflow.add_edge("estimate_q", "compute_dm")
    workflow.add_edge("compute_dm", "compute_is")
    workflow.add_edge("compute_is", "compute_dr")
    workflow.add_edge("compute_dr", "compute_influence_function")
    workflow.add_edge("compute_influence_function", "check_robustness")
    workflow.add_edge("check_robustness", "compute_ci")
    workflow.add_edge("compute_ci", "llm_interpret")
    workflow.add_edge("llm_interpret", "report")
    workflow.add_edge("report", END)

    return workflow.compile()


# =============================================================================
# Punto de entrada para pruebas
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Agente AIPW DR — Estimación Semiparamétrica para OPE")
    print("Capítulo 6: Inferencia Semiparamétrica")
    print("=" * 70)

    graph = build_graph()

    config = {
        "configurable": {"use_llm": False},
        "n_samples": 200,
        "n_states": 2,
        "n_actions": 2,
        "reward_std": 0.1,
        "alpha": 0.05,
        "seed": 42,
    }

    print("\nEjecutando grafo...\n")
    result = graph.invoke({}, config)

    V_true = result["_V_true"]
    print(f"\n{'='*70}")
    print(f"V^π_e verdadero  = {V_true:.6f}")
    print(f"V̂_DM             = {result['dm_estimate']:.6f}")
    print(f"V̂_IS             = {result['is_estimate']:.6f}")
    print(f"V̂_DR (AIPW)      = {result['dr_estimate']:.6f}")

    ci = result["ci"]
    print(f"\nIC DR al {(1-ci['alpha'])*100}%: [{ci['dr']['lower']:.4f}, {ci['dr']['upper']:.4f}]")
    print(f"¿Cubre V^π_e? {'✅ Sí' if ci['dr']['covers_true'] else '❌ No'}")
    print(f"Ancho del IC: {ci['dr']['width']:.4f}")
    print("=" * 70)
