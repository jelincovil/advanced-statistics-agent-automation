"""
agent_graph.py - Capítulo 11: Inferencia Secuencial para Funciones de Valor (SAVE)
=====================================================================================

Implementa el grafo LangGraph completo para inferencia asintótica de V^π.

Nodos del grafo:
    1. generate_markov_trajectories: Genera trayectorias de cadena ergódica
    2. compute_v_hat: V̂ = (1/n) Σ G_i (retornos descontados)
    3. estimate_se: Estima SE contando dependencia temporal vía batch means
    4. asymptotic_ci: TCL para cadenas de Markov: √n(V̂-V*) →d N(0, σ²_∞)
    5. bootstrap_ci: Block bootstrap para datos dependientes
    6. verify_mixing: Diagnostica ergodicidad geométrica
    7. compute_batch_se: Estimador de varianza por batch means
    8. power_analysis: Calcula n_min para detectar δ con potencia 1-β
    9. design_experiment: Dado δ, α, β, calcula tamaño muestral requerido
    10. llm_interpret: LLM explica la metodología SAVE
    11. final_report: IC + potencia + recomendación de diseño

Referencias teóricas:
    - SAVE: Sequential Asymptotic Variance Estimation
    - σ²_∞ = Var_π(G₀) + 2 Σ_{k=1}^∞ Cov_π(G₀, G_k) (varianza espectral)
    - Batch means para estimación de σ²_∞
    - Block bootstrap para ICs
    - Condiciones de mezcla para validez del TCL
"""

import numpy as np
from typing import Dict, List, Any
from langgraph.graph import StateGraph, END

from state_schema import SAVEState


# ============================================================================
# MDP Ergódico de ejemplo
# ============================================================================

class ErgodicMDP:
    """
    MDP con cadena de Markov geométricamente ergódica para demostración.

    El MDP tiene estados {0, 1, ..., n_states-1} con transiciones que
    garantizan mezcla geométrica. La política es estacionaria π(a|s).

    Propiedades:
        - Irreducible y aperiódica (ergodicidad geométrica)
        - Retornos descontados con dependencia temporal
        - Distribución estacionaria bien definida
    """

    def __init__(
        self,
        n_states: int = 6,
        n_actions: int = 2,
        gamma: float = 0.95,
        seed: int = 42
    ):
        """Inicializa el MDP ergódico."""
        self.n_states = n_states
        self.n_actions = n_actions
        self.gamma = gamma
        self.rng = np.random.RandomState(seed)

        # Política estacionaria (no trivial, preferencia por acción 0)
        self.policy = np.array([
            [0.7, 0.3],
            [0.6, 0.4],
            [0.8, 0.2],
            [0.5, 0.5],
            [0.9, 0.1],
            [0.4, 0.6]
        ])

        # Recompensas medias por (estado, acción)
        self.reward_means = np.array([
            [1.0, -0.5],
            [0.5, 0.0],
            [1.5, -1.0],
            [0.0, 0.5],
            [2.0, -0.5],
            [-0.5, 1.0]
        ])
        self.reward_std = 0.3

        # Transiciones: mezcla geométrica garantizada
        # Diseñadas para ser irreducibles y aperiódicas
        self.transitions = np.zeros((n_states, n_actions, n_states))
        for s in range(n_states):
            for a in range(n_actions):
                # Auto-transición moderada + probabilidad de ir a vecinos
                self.transitions[s, a, s] = 0.4 + 0.2 * (a == 0)
                # Distribuir el resto entre vecinos
                remaining = 1.0 - self.transitions[s, a, s]
                neighbors = [(s - 1) % n_states, (s + 1) % n_states]
                self.transitions[s, a, neighbors[0]] = remaining * 0.6
                self.transitions[s, a, neighbors[1]] = remaining * 0.4

    def step(self, state: int) -> Dict[str, Any]:
        """
        Realiza un paso en el MDP bajo la política estacionaria.

        Retorna:
            Diccionario con 'state', 'action', 'reward', 'next_state'
        """
        # Muestrear acción según política
        action = self.rng.choice(self.n_actions, p=self.policy[state])

        # Recompensa con ruido
        reward = self.rng.randn() * self.reward_std + self.reward_means[state, action]

        # Siguiente estado
        next_state = self.rng.choice(
            self.n_states,
            p=self.transitions[state, action]
        )

        return {
            "state": int(state),
            "action": int(action),
            "reward": float(reward),
            "next_state": int(next_state)
        }

    def generate_trajectory(self, length: int, start_state: int = 0) -> List[Dict]:
        """Genera una trayectoria de longitud dada."""
        trajectory = []
        state = start_state
        for _ in range(length):
            transition = self.step(state)
            trajectory.append(transition)
            state = transition["next_state"]
        return trajectory

    def compute_true_value(self) -> float:
        """Computa el valor verdadero V^π usando iteración de valor."""
        V = np.zeros(self.n_states)

        for _ in range(1000):
            V_new = np.zeros(self.n_states)
            for s in range(self.n_states):
                for a in range(self.n_actions):
                    expected_reward = self.reward_means[s, a]
                    expected_next_v = np.sum(
                        self.transitions[s, a] * V
                    )
                    V_new[s] += self.policy[s, a] * (
                        expected_reward + self.gamma * expected_next_v
                    )
            if np.max(np.abs(V_new - V)) < 1e-10:
                break
            V = V_new

        # Valor esperado sobre distribución inicial (uniforme)
        return float(np.mean(V))

    def stationary_distribution(self, n_steps: int = 10000) -> np.ndarray:
        """Estima la distribución estacionaria por simulación."""
        state = 0
        counts = np.zeros(self.n_states)
        for _ in range(n_steps):
            state = self.rng.choice(
                self.n_states,
                p=self.transitions[state, 0]  # usar acción 0
            )
            counts[state] += 1
        return counts / counts.sum()


# ============================================================================
# Funciones auxiliares estadísticas
# ============================================================================

def compute_discounted_return(trajectory: List[Dict], gamma: float) -> float:
    """
    Computa el retorno descontado G = Σ_t γ^t r_t.

    Args:
        trajectory: Lista de transiciones
        gamma: Factor de descuento

    Retorna:
        Retorno descontado
    """
    return sum(
        (gamma ** t) * transition["reward"]
        for t, transition in enumerate(trajectory)
    )


def spectral_variance(returns: np.ndarray, max_lag: int = 50) -> float:
    """
    Estima la varianza espectral σ²_∞.

    σ²_∞ = Var(G₀) + 2 Σ_{k=1}^∞ Cov(G₀, G_k)

    Usamos truncamiento en max_lag con ventana de Bartlett.

    Args:
        returns: Array de retornos descontados
        max_lag: Truncamiento para la suma de autocovarianzas

    Retorna:
        Estimación de σ²_∞
    """
    n = len(returns)
    if n < 2:
        return float(np.var(returns))

    mean = np.mean(returns)
    var = np.var(returns, ddof=1)

    # Suma de autocovarianzas con ventana de Bartlett
    autocov_sum = 0.0
    for lag in range(1, min(max_lag, n // 2)):
        cov = np.mean((returns[:n - lag] - mean) * (returns[lag:] - mean))
        # Ventana de Bartlett: w_k = 1 - k/max_lag
        weight = 1.0 - lag / max_lag
        autocov_sum += 2 * cov * weight

    return float(var + autocov_sum)


def batch_means_se(returns: np.ndarray, n_batches: int = 30) -> tuple:
    """
    Estima el error estándar usando batch means.

    Divide los datos en k lotes, computa la media de cada lote,
    y usa la desviación estándar de las medias de lote.

    Args:
        returns: Array de retornos
        n_batches: Número de lotes

    Retorna:
        (se, batch_size, batch_means) tupla
    """
    n = len(returns)
    batch_size = max(n // n_batches, 1)
    actual_batches = n // batch_size

    if actual_batches < 2:
        return float(np.std(returns) / np.sqrt(n)), batch_size, [np.mean(returns)]

    # Recortar para tener lotes completos
    trimmed = returns[:actual_batches * batch_size].reshape(actual_batches, batch_size)
    batch_means_list = np.mean(trimmed, axis=1)

    # SE = std(batch_means) / sqrt(n_batches)
    se = float(np.std(batch_means_list, ddof=1) / np.sqrt(actual_batches))

    return se, batch_size, batch_means_list.tolist()


def block_bootstrap_ci(
    returns: np.ndarray,
    block_size: int = 10,
    n_bootstrap: int = 1000,
    alpha: float = 0.05
) -> tuple:
    """
    Calcula intervalo de confianza vía block bootstrap.

    El block bootstrap preserva la estructura de dependencia temporal
    muestreando bloques consecutivos de datos.

    Args:
        returns: Array de retornos dependientes
        block_size: Tamaño del bloque
        n_bootstrap: Número de remuestreos
        alpha: Nivel de significancia (para IC 1-α)

    Retorna:
        (ci_lower, ci_upper, bootstrap_means) tupla
    """
    n = len(returns)
    n_blocks = n // block_size

    if n_blocks < 2:
        mean = np.mean(returns)
        se = np.std(returns) / np.sqrt(n) if n > 1 else 1.0
        return (mean - 1.96 * se, mean + 1.96 * se, [mean])

    bootstrap_means = np.zeros(n_bootstrap)

    for b in range(n_bootstrap):
        # Muestrear bloques con reemplazo
        block_starts = np.random.randint(0, n_blocks, size=n_blocks)
        sampled = np.concatenate([
            returns[start * block_size:(start + 1) * block_size]
            for start in block_starts
        ])
        bootstrap_means[b] = np.mean(sampled)

    ci_lower = float(np.percentile(bootstrap_means, 100 * alpha / 2))
    ci_upper = float(np.percentile(bootstrap_means, 100 * (1 - alpha / 2)))

    return ci_lower, ci_upper, bootstrap_means.tolist()


# ============================================================================
# Nodos del grafo LangGraph
# ============================================================================

def generate_markov_trajectories(state: SAVEState) -> dict:
    """
    Nodo 1: Genera trayectorias de la cadena de Markov ergódica.

    Genera n_trayectorias trayectorias de longitud trajectory_length cada una,
    usando la política estacionaria del MDP ergódico.

    La cadena es geométricamente ergódica por construcción, garantizando
    la validez del TCL para Markov chains.
    """
    print("\n📋 [Nodo 1] Generando trayectorias de la cadena de Markov ergódica...")

    n_traj = state.get("n_trajectories", 200)
    traj_len = state.get("trajectory_length", 50)
    gamma = state.get("gamma", 0.95)

    mdp = ErgodicMDP(n_states=6, n_actions=2, gamma=gamma, seed=42)

    trajectories = []
    for i in range(n_traj):
        start_state = i % mdp.n_states  # variedad de estados iniciales
        traj = mdp.generate_trajectory(traj_len, start_state)
        trajectories.append(traj)

    true_value = mdp.compute_true_value()

    print(f"   {n_traj} trayectorias × {traj_len} pasos = {n_traj * traj_len} transiciones")
    print(f"   Valor verdadero V^π = {true_value:.4f}")
    print(f"   γ = {gamma}")

    return {
        "trajectories": trajectories,
        "true_value": true_value,
        "n_trajectories": n_traj,
        "trajectory_length": traj_len,
        "gamma": gamma
    }


def compute_v_hat(state: SAVEState) -> dict:
    """
    Nodo 2: Calcula la estimación puntual V̂.

    V̂ = (1/n) Σ_{i=1}^n G_i

    Donde G_i = Σ_{t=0}^{T-1} γ^t r_{i,t} es el retorno descontado
    de la i-ésima trayectoria.
    """
    print("📋 [Nodo 2] Calculando estimación puntual V̂...")

    trajectories = state["trajectories"]
    gamma = state["gamma"]

    returns = np.array([
        compute_discounted_return(traj, gamma)
        for traj in trajectories
    ])

    v_hat = float(np.mean(returns))

    print(f"   V̂ = {v_hat:.4f}")
    print(f"   V verdadero = {state['true_value']:.4f}")
    print(f"   Desviación = {abs(v_hat - state['true_value']):.4f}")

    return {"v_hat": v_hat}


def estimate_se(state: SAVEState) -> dict:
    """
    Nodo 3: Estima el error estándar contando la dependencia temporal.

    Usa la varianza espectral:
        σ²_∞ = Var(G₀) + 2 Σ_{k=1}^∞ Cov(G₀, G_k)

    que captura la dependencia serial entre retornos.
    """
    print("📋 [Nodo 3] Estimando error estándar (dependencia temporal)...")

    trajectories = state["trajectories"]
    gamma = state["gamma"]

    returns = np.array([
        compute_discounted_return(traj, gamma)
        for traj in trajectories
    ])

    # Varianza espectral
    sigma2_inf = spectral_variance(returns, max_lag=min(50, len(returns) // 3))
    se = float(np.sqrt(sigma2_inf / len(returns)))

    # Varianza iid (para comparación)
    iid_var = float(np.var(returns, ddof=1))
    iid_se = float(np.sqrt(iid_var / len(returns)))

    # Ratio de inflación
    inflation_ratio = se / iid_se if iid_se > 0 else 1.0

    temporal_dep = {
        "spectral_variance": sigma2_inf,
        "iid_variance": iid_var,
        "inflation_ratio": inflation_ratio,
        "interpretation": (
            f"La dependencia temporal inflama el SE por un factor de {inflation_ratio:.2f}. "
            "Esto ocurre porque los retornos consecutivos no son independientes."
        )
    }

    print(f"   SE (varianza espectral) = {se:.4f}")
    print(f"   SE (iid, ignorando dependencia) = {iid_se:.4f}")
    print(f"   Factor de inflación = {inflation_ratio:.2f}x")

    return {
        "se_estimate": se,
        "temporal_dependence": temporal_dep
    }


def asymptotic_ci(state: SAVEState) -> dict:
    """
    Nodo 4: Calcula el intervalo de confianza asintótico.

    Basado en el TCL para cadenas de Markov:
        √n(V̂ - V*) →d N(0, σ²_∞)

    IC = V̂ ± z_{α/2} × SE

    Válido bajo condiciones de ergodicidad geométrica.
    """
    print("📋 [Nodo 4] Calculando intervalo de confianza asintótico...")

    v_hat = state["v_hat"]
    se = state["se_estimate"]
    confidence = 0.95
    z = 1.96  # para α = 0.05

    ci_lower = v_hat - z * se
    ci_upper = v_hat + z * se

    # Verificar cobertura del valor verdadero
    true_val = state.get("true_value", 0.0)
    covers = ci_lower <= true_val <= ci_upper

    ci = {
        "lower": float(ci_lower),
        "upper": float(ci_upper),
        "level": confidence,
        "z_value": z,
        "covers_true": bool(covers),
        "width": float(ci_upper - ci_lower)
    }

    print(f"   IC asintótico 95%: [{ci_lower:.4f}, {ci_upper:.4f}]")
    print(f"   Ancho del IC: {ci_upper - ci_lower:.4f}")
    print(f"   Cubre V* = {true_val:.4f}: {'✅ Sí' if covers else '❌ No'}")

    return {"asymptotic_ci": ci}


def bootstrap_ci(state: SAVEState) -> dict:
    """
    Nodo 5: Calcula intervalo de confianza vía block bootstrap.

    El block bootstrap preserva la dependencia temporal muestreando
    bloques consecutivos de datos. Esto produce ICs válidos incluso
    cuando la forma funcional de la distribución no se conoce.
    """
    print("📋 [Nodo 5] Calculando IC vía block bootstrap...")

    trajectories = state["trajectories"]
    gamma = state["gamma"]
    n_traj = state["n_trajectories"]

    returns = np.array([
        compute_discounted_return(traj, gamma)
        for traj in trajectories
    ])

    # Tamaño de bloque: regla práctica √n
    block_size = max(int(np.sqrt(n_traj)), 2)
    n_bootstrap = 1000

    ci_lower, ci_upper, bootstrap_samples = block_bootstrap_ci(
        returns,
        block_size=block_size,
        n_bootstrap=n_bootstrap,
        alpha=0.05
    )

    true_val = state.get("true_value", 0.0)
    covers = ci_lower <= true_val <= ci_upper

    ci = {
        "lower": float(ci_lower),
        "upper": float(ci_upper),
        "level": 0.95,
        "block_size": block_size,
        "n_bootstrap": n_bootstrap,
        "covers_true": bool(covers),
        "width": float(ci_upper - ci_lower)
    }

    print(f"   Block bootstrap (bloque={block_size}, B={n_bootstrap})")
    print(f"   IC bootstrap 95%: [{ci_lower:.4f}, {ci_upper:.4f}]")
    print(f"   Ancho del IC: {ci_upper - ci_lower:.4f}")
    print(f"   Cubre V* = {true_val:.4f}: {'✅ Sí' if covers else '❌ No'}")

    return {
        "bootstrap_ci": ci,
        "bootstrap_samples": bootstrap_samples
    }


def verify_mixing(state: SAVEState) -> dict:
    """
    Nodo 6: Diagnostica ergodicidad geométrica.

    Verifica que la cadena de Markov cumple condiciones de mezcla necesarias
    para la validez del TCL. Computa:
        - Autocorrelación de retornos
        - Tamaño efectivo de muestra (ESS)
        - Tiempo de autocorrelación integrada (τ_int)
    """
    print("📋 [Nodo 6] Verificando condiciones de mezcla...")

    trajectories = state["trajectories"]
    gamma = state["gamma"]

    returns = np.array([
        compute_discounted_return(traj, gamma)
        for traj in trajectories
    ])

    n = len(returns)
    mean = np.mean(returns)
    var = np.var(returns, ddof=1) if n > 1 else 1.0

    # Autocorrelación para varios rezagos
    max_lag = min(30, n // 4)
    autocorrelations = []
    for lag in range(max_lag + 1):
        if lag == 0:
            acf = 1.0
        elif n - lag > 0:
            acf = float(np.mean((returns[:n - lag] - mean) * (returns[lag:] - mean)) / var)
        else:
            acf = 0.0
        autocorrelations.append({"lag": lag, "acf": acf})

    # Tiempo de autocorrelación integrada
    # τ_int = 1 + 2 Σ_{k=1}^K ρ(k), truncando cuando ρ(k) ≈ 0
    tau_int = 1.0
    for k in range(1, len(autocorrelations)):
        if autocorrelations[k]["acf"] < 0.05:
            break
        tau_int += 2 * autocorrelations[k]["acf"]

    # Tamaño efectivo de muestra
    ess = n / tau_int

    mixing = {
        "is_mixed": tau_int < n / 2,  # criterio práctico
        "autocorrelations": autocorrelations[:15],  # primeros 15 rezagos
        "tau_integrated": float(tau_int),
        "effective_sample_size": float(ess),
        "raw_sample_size": n,
        "interpretation": (
            f"τ_int = {tau_int:.2f}, ESS = {ess:.1f} (de {n}). "
            f"La dependencia reduce la información efectiva por un factor de {n/ess:.2f}."
        )
    }

    print(f"   τ_int = {tau_int:.2f}")
    print(f"   ESS = {ess:.1f} (de {n} muestras)")
    print(f"   Mezcla adecuada: {'✅ Sí' if mixing['is_mixed'] else '⚠️ Dudosa'}")

    return {"mixing_diagnostics": mixing}


def compute_batch_se(state: SAVEState) -> dict:
    """
    Nodo 7: Estima SE por batch means con múltiples tamaños de lote.

    Batch means divide los datos en k lotes de tamaño m = n/k y usa
    la desviación estándar de las medias de lote como estimación del SE.

    La convergencia del estimador de batch means al aumentar m verifica
    la validez del TCL.
    """
    print("📋 [Nodo 7] Estimando SE por batch means...")

    trajectories = state["trajectories"]
    gamma = state["gamma"]

    returns = np.array([
        compute_discounted_return(traj, gamma)
        for traj in trajectories
    ])

    n = len(returns)

    # Probar múltiples tamaños de lote
    batch_numbers = [5, 10, 20, 30, 50]
    batch_sizes = []
    batch_se_list = []

    for nb in batch_numbers:
        if n // nb >= 2:
            se, bs, _ = batch_means_se(returns, n_batches=nb)
            batch_sizes.append(bs)
            batch_se_list.append(se)

    print(f"\n   {'N. lotes':>8} {'Tamaño lote':>12} {'SE':>10}")
    print("   " + "-" * 34)
    for i, nb in enumerate(batch_numbers):
        if i < len(batch_se_list):
            print(f"   {nb:>8} {batch_sizes[i]:>12} {batch_se_list[i]:>10.4f}")

    # Verificar convergencia: ¿el SE se estabiliza?
    if len(batch_se_list) >= 3:
        se_variation = (max(batch_se_list[-3:]) - min(batch_se_list[-3:])) / \
                       np.mean(batch_se_list[-3:])
        converged = se_variation < 0.2
    else:
        converged = True
        se_variation = 0.0

    print(f"\n   Convergencia del SE: {'✅ Estable' if converged else '⚠️ Inestable'}")
    print(f"   Variación relativa: {se_variation:.2%}")

    return {
        "batch_sizes": batch_sizes,
        "batch_se_estimates": batch_se_list
    }


def power_analysis(state: SAVEState) -> dict:
    """
    Nodo 8: Calcula potencia para detectar una diferencia δ.

    Dado:
        - δ: efecto mínimo a detectar (V^π_1 - V^π_0)
        - α: nivel de significancia
        - 1-β: potencia deseada
        - σ²_∞: varianza espectral

    Calcula el tamaño muestral mínimo n_min.

    Fórmula: n_min = (σ²_∞ / δ²) × (z_{1-α/2} + z_{1-β})²
    """
    print("📋 [Nodo 8] Realizando análisis de potencia...")

    se = state["se_estimate"]
    n = state["n_trajectories"]
    v_hat = state["v_hat"]
    true_val = state.get("true_value", 0.0)

    # Parámetros del análisis
    alpha = 0.05
    z_alpha = 1.96  # z_{0.975}
    desired_power = 0.80
    z_beta = 0.84  # z_{0.80}

    # σ²_∞ estimada
    sigma2 = (se * np.sqrt(n)) ** 2

    # Efectos mínimos a detectar
    deltas = [0.05, 0.1, 0.2, 0.3, 0.5]
    power_results = []

    for delta in deltas:
        n_required = int(np.ceil(
            (sigma2 / delta ** 2) * (z_alpha + z_beta) ** 2
        ))
        power_results.append({
            "delta": delta,
            "n_required": n_required,
            "ratio_to_current": n_required / n if n > 0 else float('inf')
        })

    # n_min para el efecto mínimo más pequeño
    n_min = power_results[0]["n_required"]

    analysis = {
        "alpha": alpha,
        "desired_power": desired_power,
        "sigma2_infinity": sigma2,
        "current_n": n,
        "results": power_results,
        "interpretation": (
            f"Para detectar δ = {deltas[0]} con potencia {desired_power} "
            f"a nivel α = {alpha}, se necesitan {n_min} trayectorias "
            f"(actualmente hay {n})."
        )
    }

    print(f"\n   {'δ':>6} {'n_min':>8} {'Ratio':>8}")
    print("   " + "-" * 26)
    for r in power_results:
        print(f"   {r['delta']:>6.2f} {r['n_required']:>8} {r['ratio_to_current']:>8.1f}x")

    return {
        "power_analysis": analysis,
        "n_min_for_delta": n_min
    }


def design_experiment(state: SAVEState) -> dict:
    """
    Nodo 9: Diseña el experimento dado δ, α, β.

    Produce una recomendación de tamaño muestral basada en el análisis
    de potencia y las condiciones de mezcla.
    """
    print("📋 [Nodo 9] Diseñando experimento...")

    power = state["power_analysis"]
    mixing = state["mixing_diagnostics"]
    se = state["se_estimate"]
    true_val = state.get("true_value", 0.0)
    v_hat = state["v_hat"]

    # Usar delta por defecto de 0.2
    delta_target = 0.2
    alpha = 0.05
    target_power = 0.80
    z_alpha = 1.96
    z_beta = 0.84

    sigma2 = power.get("sigma2_infinity", (se * np.sqrt(state["n_trajectories"])) ** 2)

    n_required = int(np.ceil(
        (sigma2 / delta_target ** 2) * (z_alpha + z_beta) ** 2
    ))

    # Ajustar por ESS
    ess_ratio = mixing.get("effective_sample_size", state["n_trajectories"]) / \
                max(state["n_trajectories"], 1)
    n_adjusted = int(np.ceil(n_required / max(ess_ratio, 0.1)))

    design = {
        "target_delta": delta_target,
        "alpha": alpha,
        "target_power": target_power,
        "n_raw_required": n_required,
        "ess_ratio": float(ess_ratio),
        "n_adjusted_required": n_adjusted,
        "current_n": state["n_trajectories"],
        "recommendation": (
            f"Para detectar δ = {delta_target} con potencia {target_power} "
            f"y α = {alpha}:\n"
            f"   • n requerido (iid): {n_required}\n"
            f"   • n ajustado por dependencia: {n_adjusted}\n"
            f"   • n actual: {state['n_trajectories']}\n"
            f"   • {'✅ Suficiente' if n_adjusted <= state['n_trajectories'] * 2 else '⚠️ Insuficiente — aumentar n'}"
        )
    }

    print(f"\n   Diseño experimental:")
    print(f"   • δ objetivo: {delta_target}")
    print(f"   • Potencia: {target_power}")
    print(f"   • α: {alpha}")
    print(f"   • n requerido (iid): {n_required}")
    print(f"   • n ajustado (dependencia): {n_adjusted}")
    print(f"   • n actual: {state['n_trajectories']}")

    return {}


def llm_interpret(state: SAVEState) -> dict:
    """
    Nodo 10: El LLM interpreta los resultados de SAVE.

    Genera una explicación pedagógica de los intervalos de confianza,
    diagnósticos de mezcla y análisis de potencia.
    """
    print("📋 [Nodo 10] Generando interpretación con LLM...")

    summary = f"""
=== Resultados de Inferencia Asintótica para V^π (SAVE) ===

Valor verdadero V^π = {state.get('true_value', 'N/A')}

Estimación:
- V̂ = {state['v_hat']:.4f}
- SE = {state['se_estimate']:.4f}

Intervalos de Confianza (95%):
- Asintótico: [{state['asymptotic_ci']['lower']:.4f}, {state['asymptotic_ci']['upper']:.4f}]
- Bootstrap: [{state['bootstrap_ci']['lower']:.4f}, {state['bootstrap_ci']['upper']:.4f}]

Dependencia Temporal:
- Varianza espectral σ²_∞ = {state['temporal_dependence']['spectral_variance']:.4f}
- Factor de inflación = {state['temporal_dependence']['inflation_ratio']:.2f}x
- τ_int = {state['mixing_diagnostics']['tau_integrated']:.2f}
- ESS = {state['mixing_diagnostics']['effective_sample_size']:.1f}

Análisis de Potencia:
- n_min para δ=0.05: {state['n_min_for_delta']}

Por favor, explica estos resultados en español, referenciando:
1. El TCL para cadenas de Markov y la varianza espectral
2. Batch means vs block bootstrap
3. La importancia de corregir por dependencia temporal
4. Cómo interpretar el análisis de potencia en este contexto
"""

    return {"llm_analysis": summary}


def final_report(state: SAVEState) -> dict:
    """
    Nodo 11: Genera el reporte final consolidado.

    Combina ICs, potencia y recomendaciones de diseño en un reporte completo.
    """
    print("📋 [Nodo 11] Generando reporte final...")

    true_val = state.get("true_value", 0.0)

    report = {
        "title": "Reporte de Inferencia Asintótica para V^π (SAVE)",
        "chapter": "Capítulo 11: Inferencia Secuencial para Funciones de Valor",
        "estimation": {
            "v_hat": state["v_hat"],
            "se": state["se_estimate"],
            "true_value": true_val,
            "bias": abs(state["v_hat"] - true_val)
        },
        "confidence_intervals": {
            "asymptotic": state["asymptotic_ci"],
            "bootstrap": state["bootstrap_ci"]
        },
        "mixing": state["mixing_diagnostics"],
        "temporal_dependence": state["temporal_dependence"],
        "power": state["power_analysis"],
        "recommendations": [
            "Siempre verificar condiciones de mezcla antes de aplicar el TCL",
            "Usar batch means o block bootstrap para corregir por dependencia",
            "Reportar tanto SE naive como SE corregido por dependencia",
            "Realizar análisis de potencia antes de recolectar datos",
            "Considerar el ESS (tamaño efectivo de muestra) en el diseño"
        ],
        "references": [
            "Shi et al. (2022) JRSSB - Sequential Inference for Value Functions",
            "Kallus & Uehara (2020) - Double/Debiased ML for Offline RL",
            "Kallus & Uehara (2022) - Efficiently Breaking the Curse of Horizon"
        ]
    }

    print("\n" + "=" * 70)
    print("📊 REPORTE FINAL DE INFERENCIA ASINTÓTICA (SAVE)")
    print("=" * 70)
    print(f"\n   V^π verdadero = {true_val:.4f}")
    print(f"   V̂ = {state['v_hat']:.4f} ± {state['se_estimate']:.4f}")
    print(f"\n   IC Asintótico: [{state['asymptotic_ci']['lower']:.4f}, "
          f"{state['asymptotic_ci']['upper']:.4f}]")
    print(f"   IC Bootstrap:  [{state['bootstrap_ci']['lower']:.4f}, "
          f"{state['bootstrap_ci']['upper']:.4f}]")
    print(f"\n   ESS = {state['mixing_diagnostics']['effective_sample_size']:.1f} "
          f"(de {state['mixing_diagnostics']['raw_sample_size']})")
    print(f"   τ_int = {state['mixing_diagnostics']['tau_integrated']:.2f}")
    print(f"   n_min (δ=0.05, 80% potencia) = {state['n_min_for_delta']}")

    print("\n   📚 Recomendaciones:")
    for i, rec in enumerate(report["recommendations"], 1):
        print(f"   {i}. {rec}")

    return {"report": report}


# ============================================================================
# Construcción del grafo LangGraph
# ============================================================================

def build_save_graph():
    """
    Construye el grafo LangGraph para el pipeline completo de SAVE.

    El flujo es secuencial:
        generate_markov_trajectories → compute_v_hat → estimate_se →
        asymptotic_ci → bootstrap_ci → verify_mixing → compute_batch_se →
        power_analysis → design_experiment → llm_interpret → final_report
    """
    workflow = StateGraph(SAVEState)

    # Agregar nodos
    workflow.add_node("generate_markov_trajectories", generate_markov_trajectories)
    workflow.add_node("compute_v_hat", compute_v_hat)
    workflow.add_node("estimate_se", estimate_se)
    workflow.add_node("asymptotic_ci", asymptotic_ci)
    workflow.add_node("bootstrap_ci", bootstrap_ci)
    workflow.add_node("verify_mixing", verify_mixing)
    workflow.add_node("compute_batch_se", compute_batch_se)
    workflow.add_node("power_analysis", power_analysis)
    workflow.add_node("design_experiment", design_experiment)
    workflow.add_node("llm_interpret", llm_interpret)
    workflow.add_node("final_report", final_report)

    # Flujo secuencial
    workflow.set_entry_point("generate_markov_trajectories")
    workflow.add_edge("generate_markov_trajectories", "compute_v_hat")
    workflow.add_edge("compute_v_hat", "estimate_se")
    workflow.add_edge("estimate_se", "asymptotic_ci")
    workflow.add_edge("asymptotic_ci", "bootstrap_ci")
    workflow.add_edge("bootstrap_ci", "verify_mixing")
    workflow.add_edge("verify_mixing", "compute_batch_se")
    workflow.add_edge("compute_batch_se", "power_analysis")
    workflow.add_edge("power_analysis", "design_experiment")
    workflow.add_edge("design_experiment", "llm_interpret")
    workflow.add_edge("llm_interpret", "final_report")
    workflow.add_edge("final_report", END)

    return workflow.compile()


# ============================================================================
# Punto de entrada para pruebas
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("🚀 Iniciando Pipeline de Inferencia Asintótica (SAVE)")
    print("=" * 70)

    initial_state = {
        "trajectories": [],
        "v_hat": 0.0,
        "se_estimate": 0.0,
        "asymptotic_ci": {},
        "bootstrap_ci": {},
        "mixing_diagnostics": {},
        "temporal_dependence": {},
        "power_analysis": {},
        "n_min_for_delta": 0,
        "n_trajectories": 200,
        "trajectory_length": 50,
        "gamma": 0.95,
        "true_value": 0.0,
        "batch_sizes": [],
        "batch_se_estimates": [],
        "bootstrap_samples": [],
        "llm_analysis": "",
        "report": {}
    }

    graph = build_save_graph()
    result = graph.invoke(initial_state)

    print("\n✅ Pipeline completado exitosamente.")
    print(f"   V̂ = {result['v_hat']:.4f} ± {result['se_estimate']:.4f}")
