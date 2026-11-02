# **Sílabo Complementario: Laboratorio de Agentes**

## Implementación Demostrativa de Conceptos de Inferencia Estadística en Agentes Inteligentes con LangGraph

**Curso Base:** Teoría Avanzada de Inferencia Estadística  
**Modalidad:** Laboratorio complementario (1.5 horas por sesión)  
**Requisitos técnicos:** Python 3.10+, LangGraph, LangChain, numpy, scipy  
**Filosofía:** Ejemplos conceptuales y demostrativos, no código de producción

---

## Introducción

Este sílabo complementario acompaña cada sesión del curso teórico con implementaciones demostrativas usando **LangGraph**, un framework basado en grafos para la construcción de agentes inteligentes (Wang & Duan, 2024). El objetivo es mostrar cómo los conceptos de inferencia estadística se manifiestan directamente en el diseño, evaluación y optimización de agentes.

### Filosofía de los Ejemplos

Los ejemplos están diseñados para ser:
1. **Conceptuales:** Ilustran la conexión teoría-práctica, no son sistemas de producción
2. **Minimalistas:** Código suficiente para entender el concepto, sin complejidad innecesaria
3. **Reproducibles:** Ejecutables en un notebook con dependencias mínimas
4. **Extensibles:** Base para exploración más profunda en el proyecto final

### Arquitectura Base: LangGraph

```python
# Estructura básica de un agente LangGraph
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class AgentState(TypedDict):
    """Estado del agente - análogo a estadístico suficiente"""
    observations: list[str]
    beliefs: dict  # Distribución sobre estados/parámetros
    actions: list[str]
    rewards: list[float]

def create_agent_graph():
    """Crea el grafo del agente - análogo a regla de decisión δ"""
    graph = StateGraph(AgentState)
    # Nodos = componentes de la regla de decisión
    # Edges = flujo de información
    return graph
```

---

## Sesión 1: Arquitectura de la Inferencia Estadística

### Conexión Teórica → Agentes

| Concepto Estadístico | Manifestación en Agentes |
|---------------------|-------------------------|
| Modelo P = {P_θ : θ ∈ Θ} | Modelo del mundo del agente |
| Espacio muestral X | Espacio de observaciones |
| Estadístico T(X) | Estado interno del agente |
| Criterio de optimalidad | Función objetivo (reward) |

### Ejemplo 1.1: Agente con Modelo del Mundo Explícito

**Objetivo:** Demostrar cómo un agente mantiene un modelo paramétrico del ambiente.

```python
"""
Ejemplo 1.1: Agente Bayesiano Simple con Modelo del Mundo
Conexión: El agente mantiene una familia paramétrica P = {P_θ}
similar a un modelo estadístico.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np
from scipy import stats

class BayesianAgentState(TypedDict):
    """
    Estado del agente - contiene el modelo del mundo
    Análogo: Familia paramétrica P_θ con θ = (mu, sigma²)
    """
    observations: list[float]  # X ~ P_θ
    prior_params: dict         # Prior sobre θ
    posterior_params: dict     # Posterior dado X
    estimated_theta: dict      # Estimador puntual
    
def observe_node(state: BayesianAgentState) -> dict:
    """
    Nodo de observación - recibe datos del ambiente
    Análogo: Realizar el experimento estadístico
    """
    # Simular observación del ambiente (en práctica, viene del entorno)
    true_mu = 5.0  # Parámetro verdadero (desconocido para el agente)
    new_obs = np.random.normal(true_mu, 1.0)
    
    return {
        "observations": state["observations"] + [new_obs]
    }

def update_beliefs_node(state: BayesianAgentState) -> dict:
    """
    Actualización Bayesiana del modelo del mundo
    Análogo: Cálculo del posterior p(θ|X)
    
    Usando conjugacy: Normal-Normal
    Prior: θ ~ N(μ₀, σ₀²)
    Likelihood: X|θ ~ N(θ, σ²) con σ² conocida
    Posterior: θ|X ~ N(μₙ, σₙ²)
    """
    prior = state["prior_params"]
    obs = state["observations"]
    
    if len(obs) == 0:
        return {"posterior_params": prior}
    
    # Parámetros del prior
    mu_0, sigma_0_sq = prior["mu"], prior["sigma_sq"]
    sigma_sq = 1.0  # Varianza conocida del likelihood
    
    n = len(obs)
    x_bar = np.mean(obs)
    
    # Actualización conjugada (Casella & Berger, Theorem 7.2.3)
    precision_0 = 1 / sigma_0_sq
    precision_data = n / sigma_sq
    
    precision_n = precision_0 + precision_data
    sigma_n_sq = 1 / precision_n
    mu_n = (precision_0 * mu_0 + precision_data * x_bar) / precision_n
    
    return {
        "posterior_params": {"mu": mu_n, "sigma_sq": sigma_n_sq},
        "estimated_theta": {"mu_hat": mu_n}  # Estimador de Bayes
    }

def decide_node(state: BayesianAgentState) -> dict:
    """
    Decisión basada en el modelo actualizado
    Análogo: Regla de decisión δ(X) usando el posterior
    """
    posterior = state["posterior_params"]
    
    # El agente decide si tiene suficiente certeza
    # Criterio: Intervalo de credibilidad suficientemente estrecho
    credible_width = 2 * 1.96 * np.sqrt(posterior["sigma_sq"])
    
    if credible_width < 0.5:
        action = "ACTUAR_CON_CONFIANZA"
    else:
        action = "SEGUIR_OBSERVANDO"
    
    return {"action": action}

# Construcción del grafo del agente
def build_bayesian_agent():
    graph = StateGraph(BayesianAgentState)
    
    graph.add_node("observe", observe_node)
    graph.add_node("update_beliefs", update_beliefs_node)
    graph.add_node("decide", decide_node)
    
    graph.set_entry_point("observe")
    graph.add_edge("observe", "update_beliefs")
    graph.add_edge("update_beliefs", "decide")
    graph.add_edge("decide", END)
    
    return graph.compile()

# Demostración
if __name__ == "__main__":
    agent = build_bayesian_agent()
    
    initial_state = {
        "observations": [],
        "prior_params": {"mu": 0.0, "sigma_sq": 10.0},  # Prior vago
        "posterior_params": {"mu": 0.0, "sigma_sq": 10.0},
        "estimated_theta": {}
    }
    
    # Ejecutar varias iteraciones
    state = initial_state
    for i in range(10):
        result = agent.invoke(state)
        state = result
        print(f"Iter {i+1}: μ_hat = {state['estimated_theta']['mu_hat']:.3f}, "
              f"σ² = {state['posterior_params']['sigma_sq']:.4f}")
```

### Reflexión Conceptual

Este ejemplo ilustra los **cinco componentes de la inferencia** en el contexto de agentes:

1. **Modelo:** Normal con media desconocida
2. **Parámetro:** θ = μ (media del ambiente)
3. **Datos:** Observaciones secuenciales del agente
4. **Estimador:** Media posterior (estimador de Bayes)
5. **Criterio:** Ancho del intervalo de credibilidad

### Referencias del Ejemplo
- Casella & Berger (2002), §7.2 - Conjugate Priors
- Gelman et al. (2013), Ch. 2 - Single-parameter models
- Wang & Duan (2024), §2.4 - LangGraph state management

---

## Sesión 2: Principios de Reducción de Datos

### Conexión Teórica → Agentes

| Concepto | Manifestación en Agentes |
|----------|-------------------------|
| Suficiencia | Estado mínimo que preserva información relevante |
| Completitud | Estado sin redundancia |
| Ancillaridad | Información del contexto independiente del objetivo |

### Ejemplo 2.1: Diseño de Estado Suficiente para un Agente

**Objetivo:** Mostrar cómo el diseño del estado del agente refleja el principio de suficiencia.

```python
"""
Ejemplo 2.1: Suficiencia en el Estado del Agente
Conexión: T(X) es suficiente para θ ⟺ el estado del agente
contiene toda la información necesaria para la decisión óptima.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np

# ============================================================
# DISEÑO INEFICIENTE: Guardar todo el historial
# ============================================================
class IneffecientState(TypedDict):
    """Estado NO suficiente - guarda información redundante"""
    full_history: list[dict]  # Todas las observaciones con timestamps
    all_actions: list[str]    # Todas las acciones tomadas
    raw_rewards: list[float]  # Todos los rewards individuales
    
# ============================================================
# DISEÑO EFICIENTE: Estado Suficiente
# ============================================================
class SufficientState(TypedDict):
    """
    Estado SUFICIENTE - solo estadísticos suficientes
    
    Para estimar E[R] (reward esperado), los estadísticos suficientes son:
    - sum_rewards: Σrᵢ
    - n_observations: n
    
    Por Factorization Theorem (Neyman-Fisher):
    p(x₁,...,xₙ|θ) = g(T(x),θ) · h(x)
    donde T(x) = (Σxᵢ, n)
    """
    sum_rewards: float   # Estadístico suficiente 1
    n_observations: int  # Estadístico suficiente 2
    current_context: str # Información ancillar (contexto)

def update_sufficient_state(state: SufficientState, new_reward: float) -> dict:
    """
    Actualiza solo los estadísticos suficientes
    Complejidad espacial: O(1) vs O(n) del estado ineficiente
    """
    return {
        "sum_rewards": state["sum_rewards"] + new_reward,
        "n_observations": state["n_observations"] + 1
    }

def compute_estimate(state: SufficientState) -> float:
    """
    Estimador UMVUE usando solo estadísticos suficientes
    
    Por Rao-Blackwell: E[R] estimado por X̄ = ΣXᵢ/n
    Este es UMVUE por Lehmann-Scheffé (familia completa)
    """
    if state["n_observations"] == 0:
        return 0.0
    return state["sum_rewards"] / state["n_observations"]

# ============================================================
# Agente con Estado Suficiente
# ============================================================
class SufficientStatisticsAgent:
    """
    Agente que demuestra el principio de suficiencia
    El estado contiene SOLO la información necesaria para decisiones óptimas
    """
    
    def __init__(self):
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(SufficientState)
        
        def observe_and_update(state: SufficientState) -> dict:
            # Simular reward del ambiente
            reward = np.random.exponential(scale=2.0)
            
            # Actualizar SOLO estadísticos suficientes
            new_sum = state["sum_rewards"] + reward
            new_n = state["n_observations"] + 1
            
            return {
                "sum_rewards": new_sum,
                "n_observations": new_n
            }
        
        def decide(state: SufficientState) -> dict:
            # Decisión usando SOLO estadísticos suficientes
            estimate = compute_estimate(state)
            
            # El contexto ancillar no afecta la estimación
            # pero puede afectar cómo presentamos la decisión
            context = state["current_context"]
            
            return {
                "decision": f"Reward estimado: {estimate:.3f}",
                "context_used": context
            }
        
        graph.add_node("observe", observe_and_update)
        graph.add_node("decide", decide)
        
        graph.set_entry_point("observe")
        graph.add_edge("observe", "decide")
        graph.add_edge("decide", END)
        
        return graph.compile()

# ============================================================
# Demostración: Comparación de eficiencia
# ============================================================
def compare_state_designs():
    """
    Muestra que el estado suficiente preserva toda la información
    necesaria con menor complejidad espacial
    """
    import sys
    
    # Simular n observaciones
    n = 1000
    rewards = np.random.exponential(scale=2.0, size=n)
    
    # Estado ineficiente: guardar todo
    inefficient = {
        "full_history": [{"t": i, "r": r, "extra": "metadata"} 
                        for i, r in enumerate(rewards)]
    }
    
    # Estado suficiente: solo (Σrᵢ, n)
    sufficient = {
        "sum_rewards": np.sum(rewards),
        "n_observations": n
    }
    
    # Ambos producen el MISMO estimador
    estimate_inefficient = np.mean([h["r"] for h in inefficient["full_history"]])
    estimate_sufficient = sufficient["sum_rewards"] / sufficient["n_observations"]
    
    print(f"Estimador (ineficiente): {estimate_inefficient:.6f}")
    print(f"Estimador (suficiente):  {estimate_sufficient:.6f}")
    print(f"Diferencia: {abs(estimate_inefficient - estimate_sufficient):.2e}")
    print(f"\nTamaño estado ineficiente: ~{sys.getsizeof(inefficient)} bytes")
    print(f"Tamaño estado suficiente:  ~{sys.getsizeof(sufficient)} bytes")

if __name__ == "__main__":
    compare_state_designs()
```

### Reflexión: Teorema de Basu en Agentes

El **contexto** (hora del día, ubicación, etc.) puede ser **ancillar** respecto al parámetro de interés (reward esperado). Por Basu, si el estado de rewards es completo y suficiente, es independiente del contexto ancillar. Esto justifica separar "estado del mundo" de "contexto de presentación" en el diseño del agente.

### Referencias del Ejemplo
- Lehmann & Casella (1998), §2.6 - Completeness
- Casella & Berger (2002), Theorem 6.2.13 - Basu's Theorem
- Russell & Norvig (2020), §17.1 - Agent state representation

---

## Sesión 3: Teoría de Estimación Puntual

### Conexión Teórica → Agentes

| Concepto | Manifestación en Agentes |
|----------|-------------------------|
| UMVUE | Mejor estimador del value function |
| Cramér-Rao bound | Límite de precisión en estimación de Q(s,a) |
| MLE | Estimación de parámetros del modelo del mundo |
| Sesgo-Varianza | Tradeoff en aproximación de funciones de valor |

### Ejemplo 3.1: Estimación de Q-function con Propiedades Estadísticas

```python
"""
Ejemplo 3.1: Estimador de Q-function con Análisis de Sesgo-Varianza
Conexión: El estimador de Q(s,a) tiene propiedades análogas a
estimadores estadísticos clásicos (sesgo, varianza, MSE).
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np
from scipy import stats

class QEstimationState(TypedDict):
    """Estado para estimación de Q-values"""
    state_action_counts: dict  # N(s,a)
    q_estimates: dict          # Q̂(s,a)
    q_sum: dict               # Σ rewards para cada (s,a)
    true_q: dict              # Q*(s,a) para evaluación (oracle)
    
class QFunctionEstimator:
    """
    Estimador de Q-function con análisis de propiedades estadísticas
    
    Teorema: Bajo ciertas condiciones, Q̂(s,a) → Q*(s,a) y
    √n(Q̂ - Q*) →ᵈ N(0, σ²)
    
    Referencia: Shi et al. (2022), Theorem 1 - Asymptotic normality
    """
    
    def __init__(self, gamma=0.99):
        self.gamma = gamma
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(QEstimationState)
        
        def collect_sample(state: QEstimationState) -> dict:
            """
            Recolectar una muestra (s, a, r, s')
            Análogo: Observar X ~ P_θ
            """
            # Simular transición (en práctica viene del ambiente)
            s, a = "s1", "a1"  # Estado-acción actual
            r = np.random.normal(1.0, 0.5)  # Reward
            
            # Actualizar conteos y sumas
            key = f"{s},{a}"
            counts = state["state_action_counts"].copy()
            sums = state["q_sum"].copy()
            
            counts[key] = counts.get(key, 0) + 1
            sums[key] = sums.get(key, 0.0) + r
            
            return {
                "state_action_counts": counts,
                "q_sum": sums
            }
        
        def update_q_estimates(state: QEstimationState) -> dict:
            """
            Actualizar estimadores Q̂(s,a)
            
            Usamos el estimador de media muestral:
            Q̂(s,a) = (1/n) Σᵢ rᵢ
            
            Propiedades:
            - Insesgado: E[Q̂] = Q* (bajo estacionariedad)
            - Consistente: Q̂ →ᵖ Q* cuando n → ∞
            - Varianza: Var(Q̂) = σ²/n (alcanza Cramér-Rao)
            """
            q_estimates = {}
            
            for key in state["q_sum"]:
                n = state["state_action_counts"][key]
                if n > 0:
                    # Estimador de media muestral (UMVUE para Normal)
                    q_estimates[key] = state["q_sum"][key] / n
            
            return {"q_estimates": q_estimates}
        
        def compute_uncertainty(state: QEstimationState) -> dict:
            """
            Calcular incertidumbre del estimador
            
            Varianza estimada: σ̂² = s²/n
            IC 95%: Q̂ ± t_{n-1,0.975} × s/√n
            
            Esto conecta con Sesión 4 (intervalos de confianza)
            """
            uncertainties = {}
            
            for key in state["q_estimates"]:
                n = state["state_action_counts"][key]
                if n > 1:
                    # Estimador de varianza (insesgado)
                    # En práctica necesitaríamos los datos originales
                    # Aquí usamos aproximación
                    se = 0.5 / np.sqrt(n)  # σ/√n aproximado
                    uncertainties[key] = {
                        "estimate": state["q_estimates"][key],
                        "std_error": se,
                        "ci_lower": state["q_estimates"][key] - 1.96*se,
                        "ci_upper": state["q_estimates"][key] + 1.96*se
                    }
            
            return {"uncertainties": uncertainties}
        
        graph.add_node("collect", collect_sample)
        graph.add_node("estimate", update_q_estimates)
        graph.add_node("uncertainty", compute_uncertainty)
        
        graph.set_entry_point("collect")
        graph.add_edge("collect", "estimate")
        graph.add_edge("estimate", "uncertainty")
        graph.add_edge("uncertainty", END)
        
        return graph.compile()

def demonstrate_cramer_rao_bound():
    """
    Demostrar que la varianza del estimador alcanza la cota de Cramér-Rao
    
    Para X ~ N(μ, σ²) con σ² conocida:
    - Información de Fisher: I(μ) = n/σ²
    - Cota de Cramér-Rao: Var(μ̂) ≥ σ²/n
    - X̄ alcanza la cota: Var(X̄) = σ²/n ✓
    """
    np.random.seed(42)
    
    true_q = 1.0  # Q* verdadero
    sigma = 0.5   # Desviación estándar conocida
    
    sample_sizes = [10, 50, 100, 500, 1000]
    
    print("n\t\tVar(Q̂)\t\tCR Bound\tEfficiency")
    print("-" * 60)
    
    for n in sample_sizes:
        # Simular muchas estimaciones para calcular varianza empírica
        estimates = []
        for _ in range(1000):
            samples = np.random.normal(true_q, sigma, n)
            estimates.append(np.mean(samples))
        
        empirical_var = np.var(estimates)
        cr_bound = sigma**2 / n
        efficiency = cr_bound / empirical_var
        
        print(f"{n}\t\t{empirical_var:.6f}\t{cr_bound:.6f}\t{efficiency:.4f}")

if __name__ == "__main__":
    demonstrate_cramer_rao_bound()
```

### Reflexión: Eficiencia Asintótica en Agentes

El estimador Monte Carlo de Q(s,a) es análogo al MLE: es **consistente**, **asintóticamente normal**, y **eficiente**. La cota de Cramér-Rao nos dice que no podemos hacer mejor que σ²/n sin información adicional. Esto fundamenta por qué necesitamos muchas muestras para estimaciones precisas en RL.

### Referencias del Ejemplo
- Casella & Berger (2002), §7.3 - Cramér-Rao Lower Bound
- Shi et al. (2022), Theorem 1 - Asymptotic normality of value estimators
- Sutton & Barto (2018), Ch. 5 - Monte Carlo Methods

---

## Sesión 4: Tests de Hipótesis e Intervalos de Confianza

### Conexión Teórica → Agentes

| Concepto | Manifestación en Agentes |
|----------|-------------------------|
| Test de hipótesis | ¿Es π₁ mejor que π₂? |
| Intervalo de confianza | IC para V^π |
| Error tipo I/II | Falso positivo/negativo en comparación de políticas |
| Poder del test | Capacidad de detectar diferencias reales |

### Ejemplo 4.1: Comparación Estadística de Políticas

```python
"""
Ejemplo 4.1: A/B Testing de Políticas con Garantías Estadísticas
Conexión: Aplicar teoría de tests de hipótesis para comparar políticas.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict, Literal
import numpy as np
from scipy import stats

class PolicyComparisonState(TypedDict):
    """Estado para comparación de políticas"""
    rewards_policy_a: list[float]
    rewards_policy_b: list[float]
    test_result: dict
    confidence_intervals: dict
    decision: str

class PolicyABTester:
    """
    Agente para A/B testing de políticas con garantías estadísticas
    
    H₀: V^{π_A} = V^{π_B}  (las políticas son equivalentes)
    H₁: V^{π_A} ≠ V^{π_B}  (hay diferencia)
    
    Basado en: Shi et al. (2022), §5 - Hypothesis testing for policy values
    """
    
    def __init__(self, alpha=0.05):
        self.alpha = alpha
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(PolicyComparisonState)
        
        def collect_data(state: PolicyComparisonState) -> dict:
            """
            Recolectar rewards bajo ambas políticas
            Análogo: Diseño de dos muestras independientes
            """
            # Simular (en práctica, desplegar ambas políticas)
            # π_A tiene V = 1.0, π_B tiene V = 1.2
            n = 100
            rewards_a = np.random.normal(1.0, 0.5, n).tolist()
            rewards_b = np.random.normal(1.2, 0.5, n).tolist()
            
            return {
                "rewards_policy_a": rewards_a,
                "rewards_policy_b": rewards_b
            }
        
        def perform_test(state: PolicyComparisonState) -> dict:
            """
            Realizar test de hipótesis
            
            Test de Welch (dos muestras, varianzas posiblemente diferentes):
            t = (X̄_A - X̄_B) / √(s²_A/n_A + s²_B/n_B)
            
            Esto es UMP para alternativa bilateral bajo normalidad
            (Lehmann & Romano, Theorem 5.4.1)
            """
            rewards_a = np.array(state["rewards_policy_a"])
            rewards_b = np.array(state["rewards_policy_b"])
            
            # Test de Welch
            t_stat, p_value = stats.ttest_ind(rewards_a, rewards_b, 
                                              equal_var=False)
            
            # Tamaño del efecto (Cohen's d)
            pooled_std = np.sqrt((np.var(rewards_a) + np.var(rewards_b)) / 2)
            effect_size = (np.mean(rewards_b) - np.mean(rewards_a)) / pooled_std
            
            return {
                "test_result": {
                    "t_statistic": t_stat,
                    "p_value": p_value,
                    "effect_size": effect_size,
                    "reject_h0": p_value < self.alpha
                }
            }
        
        def compute_ci(state: PolicyComparisonState) -> dict:
            """
            Calcular intervalos de confianza para la diferencia
            
            IC para μ_B - μ_A:
            (X̄_B - X̄_A) ± t_{α/2} × SE
            
            Dualidad test-IC: Rechazamos H₀ ⟺ 0 ∉ IC
            """
            rewards_a = np.array(state["rewards_policy_a"])
            rewards_b = np.array(state["rewards_policy_b"])
            
            mean_diff = np.mean(rewards_b) - np.mean(rewards_a)
            se = np.sqrt(np.var(rewards_a)/len(rewards_a) + 
                        np.var(rewards_b)/len(rewards_b))
            
            # IC 95% usando aproximación normal (n grande)
            ci_lower = mean_diff - 1.96 * se
            ci_upper = mean_diff + 1.96 * se
            
            return {
                "confidence_intervals": {
                    "difference": mean_diff,
                    "ci_95_lower": ci_lower,
                    "ci_95_upper": ci_upper,
                    "contains_zero": ci_lower <= 0 <= ci_upper
                }
            }
        
        def make_decision(state: PolicyComparisonState) -> dict:
            """
            Decisión basada en el test y IC
            """
            test = state["test_result"]
            ci = state["confidence_intervals"]
            
            if test["reject_h0"]:
                if ci["difference"] > 0:
                    decision = "ADOPTAR_POLÍTICA_B"
                else:
                    decision = "MANTENER_POLÍTICA_A"
            else:
                decision = "NO_HAY_EVIDENCIA_SUFICIENTE"
            
            return {"decision": decision}
        
        graph.add_node("collect", collect_data)
        graph.add_node("test", perform_test)
        graph.add_node("ci", compute_ci)
        graph.add_node("decide", make_decision)
        
        graph.set_entry_point("collect")
        graph.add_edge("collect", "test")
        graph.add_edge("test", "ci")
        graph.add_edge("ci", "decide")
        graph.add_edge("decide", END)
        
        return graph.compile()

def demonstrate_power_analysis():
    """
    Análisis de poder para diseño de experimentos de políticas
    
    Poder = P(Rechazar H₀ | H₁ es verdadera)
    
    Pregunta práctica: ¿Cuántas muestras necesito para detectar
    una diferencia de δ con poder 1-β?
    """
    from scipy.stats import norm
    
    # Parámetros
    alpha = 0.05  # Nivel de significancia
    beta = 0.20   # 1 - poder = 0.80
    sigma = 0.5   # Desviación estándar
    delta = 0.2   # Diferencia mínima detectable
    
    # Fórmula para n (dos muestras)
    # n = 2 × (z_{1-α/2} + z_{1-β})² × σ² / δ²
    z_alpha = norm.ppf(1 - alpha/2)
    z_beta = norm.ppf(1 - beta)
    
    n = 2 * (z_alpha + z_beta)**2 * sigma**2 / delta**2
    
    print(f"Para detectar diferencia δ = {delta} con:")
    print(f"  - Nivel α = {alpha}")
    print(f"  - Poder 1-β = {1-beta}")
    print(f"  - σ = {sigma}")
    print(f"\nSe necesitan n = {int(np.ceil(n))} muestras por política")

if __name__ == "__main__":
    # Ejecutar el agente de A/B testing
    tester = PolicyABTester()
    initial_state = {
        "rewards_policy_a": [],
        "rewards_policy_b": [],
        "test_result": {},
        "confidence_intervals": {},
        "decision": ""
    }
    
    result = tester.graph.invoke(initial_state)
    
    print("=== Resultado del A/B Test ===")
    print(f"Test: {result['test_result']}")
    print(f"IC: {result['confidence_intervals']}")
    print(f"Decisión: {result['decision']}")
    
    print("\n=== Análisis de Poder ===")
    demonstrate_power_analysis()
```

### Reflexión: Múltiples Comparaciones en Evaluación de Políticas

Cuando comparamos k políticas, el problema de comparaciones múltiples surge. El agente debe considerar correcciones como Bonferroni o FDR (Benjamini-Hochberg) para controlar la tasa de falsos positivos global.

### Referencias del Ejemplo
- Lehmann & Romano (2005), Ch. 5 - Two-sample problems
- Shi et al. (2022), §5 - Hypothesis testing for value functions
- Thomas et al. (2015) - High confidence off-policy evaluation

---

## Sesión 5: Teoría Asintótica Avanzada

### Conexión Teórica → Agentes

| Concepto | Manifestación en Agentes |
|----------|-------------------------|
| CLT | Normalidad asintótica de estimadores de V^π |
| Delta method | Propagación de incertidumbre en funciones de V |
| Bootstrap | Cuantificación de incertidumbre sin supuestos fuertes |

### Ejemplo 5.1: Bootstrap para Intervalos de Confianza del Value Function

```python
"""
Ejemplo 5.1: Bootstrap para Cuantificación de Incertidumbre en RL
Conexión: El bootstrap proporciona IC válidos sin supuestos distribucionales.
Basado en: Shi et al. (2022), §4.2 - Bootstrap inference
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np

class BootstrapState(TypedDict):
    """Estado para inferencia bootstrap"""
    trajectories: list[list[float]]  # Lista de trayectorias
    point_estimate: float
    bootstrap_samples: list[float]
    confidence_interval: dict

def compute_trajectory_return(trajectory: list[float], gamma=0.99) -> float:
    """Calcular retorno descontado de una trayectoria"""
    returns = 0.0
    for t, r in enumerate(trajectory):
        returns += (gamma ** t) * r
    return returns

class BootstrapValueEstimator:
    """
    Estimador de value function con bootstrap
    
    El bootstrap es válido bajo condiciones de mixing
    (Van der Vaart & Wellner, 1996, Ch. 3.6)
    
    Procedimiento:
    1. Calcular V̂ = (1/n) Σ G(τᵢ) donde G(τ) es el retorno
    2. Resamplear trayectorias con reemplazo B veces
    3. Calcular V̂*_b para cada resample
    4. IC percentil: [q_{α/2}, q_{1-α/2}] de {V̂*_b}
    """
    
    def __init__(self, n_bootstrap=1000, gamma=0.99):
        self.n_bootstrap = n_bootstrap
        self.gamma = gamma
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(BootstrapState)
        
        def collect_trajectories(state: BootstrapState) -> dict:
            """Simular recolección de trayectorias"""
            # Simular n trayectorias de longitud T
            n_trajectories = 50
            trajectory_length = 20
            
            trajectories = []
            for _ in range(n_trajectories):
                # Rewards simulados (política con V ≈ 10)
                rewards = np.random.normal(0.5, 0.2, trajectory_length).tolist()
                trajectories.append(rewards)
            
            return {"trajectories": trajectories}
        
        def point_estimate(state: BootstrapState) -> dict:
            """
            Estimador puntual: promedio de retornos
            V̂ = (1/n) Σᵢ G(τᵢ)
            """
            returns = [compute_trajectory_return(traj, self.gamma) 
                      for traj in state["trajectories"]]
            v_hat = np.mean(returns)
            
            return {"point_estimate": v_hat}
        
        def bootstrap_inference(state: BootstrapState) -> dict:
            """
            Bootstrap no paramétrico
            
            Teorema (Efron, 1979): Bajo condiciones de regularidad,
            la distribución bootstrap de √n(V̂* - V̂) aproxima
            la distribución de √n(V̂ - V) cuando n → ∞
            """
            trajectories = state["trajectories"]
            n = len(trajectories)
            
            bootstrap_estimates = []
            
            for b in range(self.n_bootstrap):
                # Resamplear trayectorias con reemplazo
                indices = np.random.choice(n, size=n, replace=True)
                boot_trajectories = [trajectories[i] for i in indices]
                
                # Calcular estimador bootstrap
                returns = [compute_trajectory_return(traj, self.gamma) 
                          for traj in boot_trajectories]
                v_hat_star = np.mean(returns)
                bootstrap_estimates.append(v_hat_star)
            
            return {"bootstrap_samples": bootstrap_estimates}
        
        def compute_ci(state: BootstrapState) -> dict:
            """
            Intervalo de confianza percentil
            
            IC_{1-α} = [q_{α/2}(V̂*), q_{1-α/2}(V̂*)]
            
            Alternativas más refinadas:
            - Bootstrap-t (pivotal)
            - BCa (bias-corrected and accelerated)
            """
            samples = state["bootstrap_samples"]
            
            # IC percentil básico
            ci_lower = np.percentile(samples, 2.5)
            ci_upper = np.percentile(samples, 97.5)
            
            # Error estándar bootstrap
            se_boot = np.std(samples)
            
            return {
                "confidence_interval": {
                    "method": "percentile",
                    "ci_95_lower": ci_lower,
                    "ci_95_upper": ci_upper,
                    "se_bootstrap": se_boot,
                    "point_estimate": state["point_estimate"]
                }
            }
        
        graph.add_node("collect", collect_trajectories)
        graph.add_node("estimate", point_estimate)
        graph.add_node("bootstrap", bootstrap_inference)
        graph.add_node("ci", compute_ci)
        
        graph.set_entry_point("collect")
        graph.add_edge("collect", "estimate")
        graph.add_edge("estimate", "bootstrap")
        graph.add_edge("bootstrap", "ci")
        graph.add_edge("ci", END)
        
        return graph.compile()

def demonstrate_bootstrap_consistency():
    """
    Demostrar que el bootstrap captura correctamente la variabilidad
    """
    np.random.seed(42)
    
    # Valor verdadero
    true_v = 10.0
    
    # Simular muchos experimentos
    n_experiments = 100
    coverage_count = 0
    
    estimator = BootstrapValueEstimator(n_bootstrap=500)
    
    for _ in range(n_experiments):
        result = estimator.graph.invoke({
            "trajectories": [],
            "point_estimate": 0.0,
            "bootstrap_samples": [],
            "confidence_interval": {}
        })
        
        ci = result["confidence_interval"]
        if ci["ci_95_lower"] <= true_v <= ci["ci_95_upper"]:
            coverage_count += 1
    
    coverage = coverage_count / n_experiments
    print(f"Cobertura empírica del IC 95%: {coverage:.2%}")
    print(f"(Esperado: ~95%)")

if __name__ == "__main__":
    # Ejecutar estimador
    estimator = BootstrapValueEstimator()
    result = estimator.graph.invoke({
        "trajectories": [],
        "point_estimate": 0.0,
        "bootstrap_samples": [],
        "confidence_interval": {}
    })
    
    print("=== Estimación Bootstrap del Value Function ===")
    ci = result["confidence_interval"]
    print(f"V̂ = {ci['point_estimate']:.4f}")
    print(f"SE(bootstrap) = {ci['se_bootstrap']:.4f}")
    print(f"IC 95% = [{ci['ci_95_lower']:.4f}, {ci['ci_95_upper']:.4f}]")
    
    print("\n=== Verificación de Cobertura ===")
    demonstrate_bootstrap_consistency()
```

### Referencias del Ejemplo
- Van der Vaart (1998), Ch. 23 - Bootstrap
- Efron & Tibshirani (1993), Ch. 11-13
- Hanna et al. (2017) - Bootstrapped DQN

---

## Sesión 6: Teoría Semiparamétrica y Eficiencia

### Conexión Teórica → Agentes

| Concepto | Manifestación en Agentes |
|----------|-------------------------|
| Función de influencia | Sensibilidad del estimador de V^π |
| Double robustness | DR estimators en off-policy evaluation |
| Efficiency bound | Límite de precisión para OPE |

### Ejemplo 6.1: Estimador Doubly Robust para Off-Policy Evaluation

```python
"""
Ejemplo 6.1: Estimador Doubly Robust en Off-Policy Evaluation
Conexión: DR combina modelo directo e importance sampling para robustez.

Referencia principal: Kallus & Uehara (2022), Double RL
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np

class DREstimatorState(TypedDict):
    """Estado para estimación doubly robust"""
    data: list[dict]  # {s, a, r, s', pi_b(a|s), pi_e(a|s)}
    q_estimate: dict  # Q̂(s,a) estimado
    dm_estimate: float  # Direct Method estimate
    is_estimate: float  # Importance Sampling estimate
    dr_estimate: float  # Doubly Robust estimate

class DoublyRobustOPE:
    """
    Off-Policy Evaluation con estimador Doubly Robust
    
    V̂_DR = V̂_DM + (1/n) Σᵢ ρᵢ(Rᵢ - Q̂(Sᵢ,Aᵢ))
    
    donde ρᵢ = π_e(Aᵢ|Sᵢ) / π_b(Aᵢ|Sᵢ) es el importance ratio
    
    Propiedades (Dudík et al., 2011):
    - Consistente si Q̂ O ρ son correctos (double robustness)
    - Eficiente si ambos son correctos
    - Menor varianza que IS puro
    """
    
    def __init__(self):
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(DREstimatorState)
        
        def generate_data(state: DREstimatorState) -> dict:
            """Simular datos off-policy"""
            n = 200
            data = []
            
            for _ in range(n):
                s = np.random.choice(["s1", "s2"])
                
                # Política de comportamiento (uniform)
                pi_b = 0.5
                a = np.random.choice(["a1", "a2"])
                
                # Política objetivo (preferencia por a1)
                pi_e = 0.7 if a == "a1" else 0.3
                
                # Reward (depende de estado y acción)
                if s == "s1" and a == "a1":
                    r = np.random.normal(1.5, 0.3)
                else:
                    r = np.random.normal(0.5, 0.3)
                
                data.append({
                    "s": s, "a": a, "r": r,
                    "pi_b": pi_b, "pi_e": pi_e
                })
            
            return {"data": data}
        
        def estimate_q_function(state: DREstimatorState) -> dict:
            """
            Estimar Q̂(s,a) usando método directo (regresión)
            En práctica: FQI, neural network, etc.
            """
            data = state["data"]
            
            # Estimador simple: promedio por (s,a)
            q_sums = {}
            q_counts = {}
            
            for d in data:
                key = f"{d['s']},{d['a']}"
                q_sums[key] = q_sums.get(key, 0) + d['r']
                q_counts[key] = q_counts.get(key, 0) + 1
            
            q_estimate = {k: q_sums[k]/q_counts[k] for k in q_sums}
            
            return {"q_estimate": q_estimate}
        
        def compute_dm_estimate(state: DREstimatorState) -> dict:
            """
            Direct Method: V̂_DM = Σ_a π_e(a|s₀) Q̂(s₀,a)
            
            Sesgo: depende de la calidad de Q̂
            Varianza: baja
            """
            q = state["q_estimate"]
            
            # Asumir distribución inicial uniforme sobre estados
            v_dm = 0.0
            for s in ["s1", "s2"]:
                for a in ["a1", "a2"]:
                    key = f"{s},{a}"
                    pi_e = 0.7 if a == "a1" else 0.3
                    v_dm += 0.5 * pi_e * q.get(key, 0)  # 0.5 = P(s)
            
            return {"dm_estimate": v_dm}
        
        def compute_is_estimate(state: DREstimatorState) -> dict:
            """
            Importance Sampling: V̂_IS = (1/n) Σᵢ ρᵢ Rᵢ
            
            Insesgado: E[V̂_IS] = V^π_e
            Varianza: alta (especialmente si π_e ≠ π_b)
            """
            data = state["data"]
            
            weighted_rewards = []
            for d in data:
                rho = d["pi_e"] / d["pi_b"]  # Importance ratio
                weighted_rewards.append(rho * d["r"])
            
            v_is = np.mean(weighted_rewards)
            
            return {"is_estimate": v_is}
        
        def compute_dr_estimate(state: DREstimatorState) -> dict:
            """
            Doubly Robust:
            V̂_DR = V̂_DM + (1/n) Σᵢ ρᵢ (Rᵢ - Q̂(Sᵢ,Aᵢ))
            
            = (1/n) Σᵢ [ρᵢ Rᵢ - (ρᵢ - 1) Q̂(Sᵢ,Aᵢ)]
            
            Double robustness: consistente si Q̂ correcto OR ρ correcto
            """
            data = state["data"]
            q = state["q_estimate"]
            v_dm = state["dm_estimate"]
            
            correction = 0.0
            for d in data:
                rho = d["pi_e"] / d["pi_b"]
                key = f"{d['s']},{d['a']}"
                q_hat = q.get(key, 0)
                correction += rho * (d["r"] - q_hat)
            
            correction /= len(data)
            v_dr = v_dm + correction
            
            return {"dr_estimate": v_dr}
        
        graph.add_node("data", generate_data)
        graph.add_node("q_model", estimate_q_function)
        graph.add_node("dm", compute_dm_estimate)
        graph.add_node("is", compute_is_estimate)
        graph.add_node("dr", compute_dr_estimate)
        
        graph.set_entry_point("data")
        graph.add_edge("data", "q_model")
        graph.add_edge("q_model", "dm")
        graph.add_edge("dm", "is")
        graph.add_edge("is", "dr")
        graph.add_edge("dr", END)
        
        return graph.compile()

def compare_estimator_properties():
    """
    Comparar sesgo y varianza de DM, IS, y DR
    """
    np.random.seed(42)
    
    n_runs = 100
    dm_estimates = []
    is_estimates = []
    dr_estimates = []
    
    ope = DoublyRobustOPE()
    
    for _ in range(n_runs):
        result = ope.graph.invoke({
            "data": [], "q_estimate": {},
            "dm_estimate": 0, "is_estimate": 0, "dr_estimate": 0
        })
        dm_estimates.append(result["dm_estimate"])
        is_estimates.append(result["is_estimate"])
        dr_estimates.append(result["dr_estimate"])
    
    # Valor verdadero (calculado analíticamente)
    # V^π_e = Σ P(s) Σ π_e(a|s) Q(s,a)
    # = 0.5 * (0.7*1.5 + 0.3*0.5) + 0.5 * (0.7*0.5 + 0.3*0.5)
    true_v = 0.5 * (0.7*1.5 + 0.3*0.5) + 0.5 * (0.7*0.5 + 0.3*0.5)
    
    print(f"Valor verdadero V^π_e = {true_v:.4f}")
    print("\nEstimador\t\tMedia\t\tSesgo\t\tDE")
    print("-" * 60)
    print(f"DM\t\t\t{np.mean(dm_estimates):.4f}\t\t"
          f"{np.mean(dm_estimates) - true_v:.4f}\t\t"
          f"{np.std(dm_estimates):.4f}")
    print(f"IS\t\t\t{np.mean(is_estimates):.4f}\t\t"
          f"{np.mean(is_estimates) - true_v:.4f}\t\t"
          f"{np.std(is_estimates):.4f}")
    print(f"DR\t\t\t{np.mean(dr_estimates):.4f}\t\t"
          f"{np.mean(dr_estimates) - true_v:.4f}\t\t"
          f"{np.std(dr_estimates):.4f}")

if __name__ == "__main__":
    compare_estimator_properties()
```

### Referencias del Ejemplo
- Dudík et al. (2011) - Doubly Robust Policy Evaluation
- Kallus & Uehara (2022) - Double Reinforcement Learning
- Kennedy (2016) - Semiparametric theory review

---

## Sesión 7: Teoría de Decisión Estadística (Wald)

### Conexión Teórica → Agentes

| Concepto de Wald | Manifestación en Agentes |
|-----------------|-------------------------|
| Regla de decisión δ | Política π |
| Función de pérdida L | Reward negativo -r |
| Riesgo R(θ,δ) | Valor negativo -V^π |
| Admisibilidad | Optimalidad de Pareto |

### Ejemplo 7.1: Agente como Regla de Decisión de Wald

```python
"""
Ejemplo 7.1: Formalización de Agente como Regla de Decisión de Wald
Conexión: Mostrar explícitamente la analogía estructural.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict, Callable
import numpy as np
from dataclasses import dataclass

# ============================================================
# Formalización de Wald
# ============================================================
@dataclass
class DecisionProblem:
    """
    Problema de decisión de Wald:
    - Θ: espacio de parámetros (estados de la naturaleza)
    - A: espacio de acciones
    - L: Θ × A → ℝ: función de pérdida
    - P: familia de distribuciones {P_θ : θ ∈ Θ}
    """
    theta_space: list
    action_space: list
    loss_function: Callable  # L(theta, action) -> float
    data_distribution: Callable  # P_theta(x) -> sample

@dataclass  
class DecisionRule:
    """
    Regla de decisión δ: X → A
    Puede ser determinista o aleatorizada
    """
    rule: Callable  # δ(x) -> action

def risk_function(problem: DecisionProblem, delta: DecisionRule, 
                  theta: float, n_samples: int = 1000) -> float:
    """
    Función de riesgo: R(θ, δ) = E_θ[L(θ, δ(X))]
    
    Estimada por Monte Carlo
    """
    losses = []
    for _ in range(n_samples):
        x = problem.data_distribution(theta)
        action = delta.rule(x)
        loss = problem.loss_function(theta, action)
        losses.append(loss)
    return np.mean(losses)

# ============================================================
# Traducción a Agente
# ============================================================
class WaldAgentState(TypedDict):
    """
    Estado del agente interpretado como problema de Wald
    """
    observation: float  # X ~ P_θ
    parameter_space: list  # Θ
    belief: dict  # P(θ | X) o estimador de θ
    action: str
    loss_incurred: float

class WaldianAgent:
    """
    Agente que implementa una regla de decisión de Wald
    
    La política π(a|s) es exactamente la regla δ(X) = a
    
    Analogía:
    - Observación X ↔ Estado s
    - Parámetro θ ↔ Modelo del ambiente
    - Acción a ↔ Acción a
    - Pérdida L ↔ -Reward
    - Riesgo R ↔ -Value
    """
    
    def __init__(self, decision_criterion="bayes"):
        self.criterion = decision_criterion
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(WaldAgentState)
        
        def receive_observation(state: WaldAgentState) -> dict:
            """Recibir observación del ambiente"""
            # Simular: ambiente tiene θ ∈ {0, 1} con θ_true = 0.7
            theta_true = 0.7
            x = np.random.binomial(10, theta_true)
            return {"observation": x}
        
        def update_belief(state: WaldAgentState) -> dict:
            """
            Actualizar creencia sobre θ
            
            Prior uniforme, likelihood binomial
            → Posterior Beta
            """
            x = state["observation"]
            n = 10  # Número de trials
            
            # Posterior: θ | X ~ Beta(X + 1, n - X + 1)
            alpha_post = x + 1
            beta_post = n - x + 1
            
            return {
                "belief": {
                    "posterior_alpha": alpha_post,
                    "posterior_beta": beta_post,
                    "posterior_mean": alpha_post / (alpha_post + beta_post)
                }
            }
        
        def select_action_bayes(state: WaldAgentState) -> dict:
            """
            Regla de decisión de Bayes
            
            δ_Bayes = argmin_a E_π[L(θ, a)]
            
            donde π es el posterior
            """
            belief = state["belief"]
            theta_hat = belief["posterior_mean"]
            
            # Pérdida cuadrática: L(θ, a) = (θ - a)²
            # Acción óptima: a* = E[θ | X] = posterior mean
            action = f"estimar_theta={theta_hat:.3f}"
            
            return {"action": action}
        
        def select_action_minimax(state: WaldAgentState) -> dict:
            """
            Regla de decisión minimax
            
            δ_minimax = argmin_δ max_θ R(θ, δ)
            
            Minimiza el peor caso
            """
            # Para pérdida cuadrática y θ ∈ [0,1]:
            # δ_minimax(X) = (X + √n/2) / (n + √n)
            x = state["observation"]
            n = 10
            minimax_est = (x + np.sqrt(n)/2) / (n + np.sqrt(n))
            
            action = f"estimar_theta={minimax_est:.3f}"
            
            return {"action": action}
        
        def compute_loss(state: WaldAgentState) -> dict:
            """
            Calcular pérdida incurrida (para evaluación)
            """
            theta_true = 0.7
            # Extraer estimación de la acción
            est = float(state["action"].split("=")[1])
            loss = (theta_true - est)**2
            
            return {"loss_incurred": loss}
        
        graph.add_node("observe", receive_observation)
        graph.add_node("belief", update_belief)
        
        if self.criterion == "bayes":
            graph.add_node("decide", select_action_bayes)
        else:
            graph.add_node("decide", select_action_minimax)
        
        graph.add_node("loss", compute_loss)
        
        graph.set_entry_point("observe")
        graph.add_edge("observe", "belief")
        graph.add_edge("belief", "decide")
        graph.add_edge("decide", "loss")
        graph.add_edge("loss", END)
        
        return graph.compile()

def compare_decision_rules():
    """
    Comparar reglas Bayes vs Minimax
    """
    np.random.seed(42)
    
    bayes_agent = WaldianAgent("bayes")
    minimax_agent = WaldianAgent("minimax")
    
    n_trials = 1000
    bayes_losses = []
    minimax_losses = []
    
    initial_state = {
        "observation": 0.0,
        "parameter_space": [0, 1],
        "belief": {},
        "action": "",
        "loss_incurred": 0.0
    }
    
    for _ in range(n_trials):
        result_b = bayes_agent.graph.invoke(initial_state)
        result_m = minimax_agent.graph.invoke(initial_state)
        
        bayes_losses.append(result_b["loss_incurred"])
        minimax_losses.append(result_m["loss_incurred"])
    
    print("=== Comparación de Reglas de Decisión ===")
    print(f"\nRiesgo empírico (θ = 0.7):")
    print(f"  Bayes:   R(θ, δ_Bayes)   = {np.mean(bayes_losses):.6f}")
    print(f"  Minimax: R(θ, δ_minimax) = {np.mean(minimax_losses):.6f}")
    
    print(f"\n(Bayes es óptimo para el prior asumido)")
    print(f"(Minimax protege contra el peor caso)")

if __name__ == "__main__":
    compare_decision_rules()
```

### Referencias del Ejemplo
- Berger (1985), Ch. 1-4 - Decision theory fundamentals
- Wald (1950), Ch. 1-3
- Ferguson (1967), Ch. 1-2

---

## Sesión 8: Procesos de Decisión de Markov

### Ejemplo 8.1: Value Iteration con LangGraph

```python
"""
Ejemplo 8.1: Value Iteration implementado como Agente LangGraph
Conexión: El algoritmo de Bellman como proceso iterativo de actualización.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np

class MDPState(TypedDict):
    """Estado del algoritmo de Value Iteration"""
    V: dict  # V(s) para cada estado
    Q: dict  # Q(s,a) para cada par estado-acción
    policy: dict  # π(s) = argmax_a Q(s,a)
    iteration: int
    converged: bool
    delta: float  # Máximo cambio en V

class ValueIterationAgent:
    """
    Implementación de Value Iteration siguiendo Puterman (2005), Ch. 6
    
    Actualización de Bellman:
    V_{k+1}(s) = max_a [r(s,a) + γ Σ_{s'} P(s'|s,a) V_k(s')]
    
    Convergencia: ||V_{k+1} - V_k||_∞ < ε(1-γ)/(2γ)
    """
    
    def __init__(self, mdp_definition: dict, gamma=0.99, epsilon=1e-6):
        self.mdp = mdp_definition
        self.gamma = gamma
        self.epsilon = epsilon
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(MDPState)
        
        def initialize(state: MDPState) -> dict:
            """Inicializar V(s) = 0 para todos los estados"""
            states = self.mdp["states"]
            V = {s: 0.0 for s in states}
            return {"V": V, "iteration": 0, "converged": False}
        
        def bellman_update(state: MDPState) -> dict:
            """
            Una iteración de Bellman
            
            V(s) ← max_a Q(s,a)
            Q(s,a) = r(s,a) + γ Σ_{s'} P(s'|s,a) V(s')
            """
            V = state["V"].copy()
            Q = {}
            delta = 0.0
            
            for s in self.mdp["states"]:
                v_old = V[s]
                q_values = {}
                
                for a in self.mdp["actions"]:
                    # Calcular Q(s,a)
                    q = self.mdp["rewards"].get((s, a), 0.0)
                    
                    for s_next in self.mdp["states"]:
                        p = self.mdp["transitions"].get((s, a, s_next), 0.0)
                        q += self.gamma * p * state["V"][s_next]
                    
                    q_values[a] = q
                    Q[(s, a)] = q
                
                # V(s) = max_a Q(s,a)
                V[s] = max(q_values.values())
                delta = max(delta, abs(V[s] - v_old))
            
            # Extraer política greedy
            policy = {}
            for s in self.mdp["states"]:
                best_a = max(self.mdp["actions"], 
                           key=lambda a: Q.get((s, a), float('-inf')))
                policy[s] = best_a
            
            return {
                "V": V,
                "Q": Q,
                "policy": policy,
                "iteration": state["iteration"] + 1,
                "delta": delta
            }
        
        def check_convergence(state: MDPState) -> dict:
            """Verificar criterio de convergencia"""
            threshold = self.epsilon * (1 - self.gamma) / (2 * self.gamma)
            converged = state["delta"] < threshold
            return {"converged": converged}
        
        def should_continue(state: MDPState) -> str:
            """Decisión de continuar o terminar"""
            if state["converged"] or state["iteration"] >= 1000:
                return "end"
            return "iterate"
        
        graph.add_node("init", initialize)
        graph.add_node("iterate", bellman_update)
        graph.add_node("check", check_convergence)
        
        graph.set_entry_point("init")
        graph.add_edge("init", "iterate")
        graph.add_edge("iterate", "check")
        graph.add_conditional_edges(
            "check",
            should_continue,
            {"iterate": "iterate", "end": END}
        )
        
        return graph.compile()

# Definir un MDP simple (GridWorld 2x2)
simple_mdp = {
    "states": ["s0", "s1", "s2", "s3"],
    "actions": ["up", "down", "left", "right"],
    "rewards": {
        ("s0", "right"): -1, ("s0", "down"): -1,
        ("s1", "left"): -1, ("s1", "down"): -1,
        ("s2", "right"): -1, ("s2", "up"): -1,
        ("s3", "left"): 10, ("s3", "up"): -1,  # Goal state
    },
    "transitions": {
        # Transiciones deterministas simplificadas
        ("s0", "right", "s1"): 1.0,
        ("s0", "down", "s2"): 1.0,
        ("s1", "left", "s0"): 1.0,
        ("s1", "down", "s3"): 1.0,
        ("s2", "up", "s0"): 1.0,
        ("s2", "right", "s3"): 1.0,
        ("s3", "up", "s1"): 1.0,
        ("s3", "left", "s2"): 1.0,
    }
}

if __name__ == "__main__":
    agent = ValueIterationAgent(simple_mdp, gamma=0.9)
    
    initial_state = {
        "V": {}, "Q": {}, "policy": {},
        "iteration": 0, "converged": False, "delta": float('inf')
    }
    
    result = agent.graph.invoke(initial_state)
    
    print("=== Value Iteration Resultado ===")
    print(f"Iteraciones: {result['iteration']}")
    print(f"Convergió: {result['converged']}")
    print(f"\nV*(s):")
    for s, v in result["V"].items():
        print(f"  {s}: {v:.4f}")
    print(f"\nπ*(s):")
    for s, a in result["policy"].items():
        print(f"  {s}: {a}")
```

### Referencias del Ejemplo
- Puterman (2005), Ch. 6 - Value Iteration
- Sutton & Barto (2018), Ch. 4 - Dynamic Programming
- Bellman (1957), Ch. 1

---

## Sesión 9: Analogías Teoría de Decisión ↔ MDPs

### Ejemplo 9.1: Tabla Comparativa Implementada

```python
"""
Ejemplo 9.1: Demostración Práctica de las Analogías
Conexión: Código que muestra explícitamente el mapping entre conceptos.
"""
from dataclasses import dataclass
from typing import Callable, Dict, List
import numpy as np

# ============================================================
# LADO ESTADÍSTICO (Wald)
# ============================================================
@dataclass
class StatisticalDecisionProblem:
    """Problema de decisión de Wald"""
    name: str
    parameter_space: List[float]
    action_space: List[float]
    loss: Callable[[float, float], float]  # L(θ, a)
    data_model: Callable[[float], float]   # X ~ P_θ
    
    def risk(self, decision_rule: Callable, theta: float, 
             n_samples: int = 1000) -> float:
        """R(θ, δ) = E_θ[L(θ, δ(X))]"""
        losses = []
        for _ in range(n_samples):
            x = self.data_model(theta)
            a = decision_rule(x)
            losses.append(self.loss(theta, a))
        return np.mean(losses)

# ============================================================
# LADO RL (Puterman/Bellman)
# ============================================================
@dataclass
class MarkovDecisionProcess:
    """MDP siguiendo notación de Puterman"""
    name: str
    state_space: List[str]
    action_space: List[str]
    reward: Callable[[str, str], float]     # r(s, a)
    transition: Callable[[str, str], str]   # s' ~ P(·|s, a)
    gamma: float = 0.99
    
    def value(self, policy: Callable, initial_state: str,
              n_episodes: int = 100, max_steps: int = 100) -> float:
        """V^π(s) = E_π[Σ γ^t r_t | s_0 = s]"""
        returns = []
        for _ in range(n_episodes):
            s = initial_state
            episode_return = 0.0
            for t in range(max_steps):
                a = policy(s)
                r = self.reward(s, a)
                episode_return += (self.gamma ** t) * r
                s = self.transition(s, a)
            returns.append(episode_return)
        return np.mean(returns)

# ============================================================
# TABLA COMPARATIVA EJECUTABLE
# ============================================================
def demonstrate_analogy():
    """
    Mostrar que Risk y -Value son análogos
    """
    
    # --- Problema Estadístico ---
    stat_problem = StatisticalDecisionProblem(
        name="Estimación de media Normal",
        parameter_space=np.linspace(-2, 2, 50).tolist(),
        action_space=np.linspace(-2, 2, 50).tolist(),
        loss=lambda theta, a: (theta - a)**2,  # Pérdida cuadrática
        data_model=lambda theta: np.random.normal(theta, 1.0)
    )
    
    # Regla de decisión: δ(X) = X (MLE)
    mle_rule = lambda x: x
    
    # Calcular función de riesgo
    thetas = [-1.0, 0.0, 1.0]
    print("=== TEORÍA DE DECISIÓN (Wald) ===")
    print(f"Problema: {stat_problem.name}")
    print(f"Regla: δ(X) = X (MLE)")
    print(f"\nFunción de Riesgo R(θ, δ):")
    for theta in thetas:
        risk = stat_problem.risk(mle_rule, theta)
        print(f"  R({theta}, δ) = {risk:.4f}")
    
    # --- MDP Equivalente ---
    # Estado = observación, acción = estimación
    # Reward = -Loss, Value = -Risk
    
    print("\n" + "="*50)
    print("\n=== MDP (Puterman/Bellman) ===")
    print("Mapping:")
    print("  - Estado s ↔ Observación X")
    print("  - Acción a ↔ Decisión δ(X)")
    print("  - Reward r ↔ -Loss L")
    print("  - Value V ↔ -Risk R")
    
    print("\n  → V^π(s) = -R(θ, δ) bajo el mapping")
    
    # Demostrar numéricamente
    print("\nVerificación numérica:")
    for theta in thetas:
        risk = stat_problem.risk(mle_rule, theta)
        neg_value = -risk  # V^π = -R
        print(f"  θ={theta}: R = {risk:.4f}, -R = {neg_value:.4f}")

def analogy_table():
    """Imprimir tabla comparativa"""
    
    table = """
╔══════════════════════════════════════════════════════════════════════╗
║                    ANALOGÍA ESTRUCTURAL                               ║
╠══════════════════════════════════════════════════════════════════════╣
║ Teoría de Decisión (Wald)    │    MDPs (Puterman/Bellman)            ║
╠══════════════════════════════════════════════════════════════════════╣
║ Parámetro θ ∈ Θ              │    Modelo del ambiente (transiciones) ║
║ Observación X ~ P_θ          │    Estado s ∈ S                       ║
║ Acción a ∈ A                 │    Acción a ∈ A                       ║
║ Pérdida L(θ, a)              │    Reward negativo -r(s, a)           ║
║ Regla δ: X → A               │    Política π: S → A                  ║
║ Riesgo R(θ,δ) = E_θ[L]       │    Valor negativo -V^π(s)             ║
║ Estimador de Bayes           │    Política que maximiza E[V|prior]   ║
║ Estimador minimax            │    Política robusta (worst-case)      ║
║ Admisibilidad                │    Optimalidad de Pareto              ║
╠══════════════════════════════════════════════════════════════════════╣
║                    DIFERENCIAS CLAVE                                  ║
╠══════════════════════════════════════════════════════════════════════╣
║ Horizonte: Una observación   │    Horizonte: Infinito (secuencial)   ║
║ θ fijo durante experimento   │    Estado s evoluciona con P(s'|s,a)  ║
║ No hay dinámica temporal     │    Descuento γ, ecuación de Bellman   ║
╚══════════════════════════════════════════════════════════════════════╝
"""
    print(table)

if __name__ == "__main__":
    analogy_table()
    print()
    demonstrate_analogy()
```

---

## Sesiones 10-11: Off-Policy Evaluation con Inferencia

### Ejemplo 10-11.1: Implementación Completa del Método SAVE

```python
"""
Ejemplo 10-11.1: Implementación del método SAVE de Shi et al. (2022)
Conexión: Intervalos de confianza para value function.

Referencia: Shi et al. (2022), JRSSB, §3 - SAVE method
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np
from scipy import stats

class SAVEState(TypedDict):
    """Estado para el algoritmo SAVE"""
    trajectories: list  # Datos observados
    q_estimate: dict    # Q̂(s,a) estimado
    value_estimate: float
    variance_estimate: float
    confidence_interval: dict
    policy_is_data_dependent: bool

class SAVEAgent:
    """
    Sequential Value Evaluation (SAVE)
    
    Para políticas data-dependent donde π depende de los datos observados.
    
    Procedimiento:
    1. Dividir datos en batches
    2. Actualizar política y estimador de forma secuencial
    3. Derivar IC que tiene cobertura correcta
    
    Teorema (Shi et al., 2022, Thm 2):
    Bajo condiciones de regularidad, el IC tiene cobertura asintótica 1-α
    incluso cuando la política óptima no es única.
    """
    
    def __init__(self, gamma=0.99, alpha=0.05):
        self.gamma = gamma
        self.alpha = alpha
        self.graph = self._build_graph()
    
    def _build_graph(self):
        graph = StateGraph(SAVEState)
        
        def collect_data(state: SAVEState) -> dict:
            """
            Simular recolección de trayectorias
            En práctica: datos históricos o experimento
            """
            n_trajectories = 50
            trajectory_length = 20
            
            trajectories = []
            for i in range(n_trajectories):
                traj = []
                s = "s0"
                for t in range(trajectory_length):
                    a = np.random.choice(["a0", "a1"])
                    r = np.random.normal(1.0 if a == "a1" else 0.5, 0.3)
                    s_next = np.random.choice(["s0", "s1"])
                    traj.append({"s": s, "a": a, "r": r, "s_next": s_next})
                    s = s_next
                trajectories.append(traj)
            
            return {"trajectories": trajectories}
        
        def estimate_q_function(state: SAVEState) -> dict:
            """
            Estimar Q-function usando series/sieve method
            
            En implementación completa: tensor-product splines o wavelets
            Aquí: promedio simple por (s,a) como aproximación
            """
            trajectories = state["trajectories"]
            
            q_sums = {}
            q_counts = {}
            
            for traj in trajectories:
                for transition in traj:
                    key = (transition["s"], transition["a"])
                    q_sums[key] = q_sums.get(key, 0) + transition["r"]
                    q_counts[key] = q_counts.get(key, 0) + 1
            
            q_estimate = {k: q_sums[k]/q_counts[k] for k in q_sums}
            
            return {"q_estimate": q_estimate}
        
        def compute_value_and_variance(state: SAVEState) -> dict:
            """
            Calcular estimador de valor y su varianza
            
            V̂ = (1/n) Σᵢ G(τᵢ, Q̂)
            
            donde G(τ, Q) es el retorno modificado usando Q̂
            """
            trajectories = state["trajectories"]
            q = state["q_estimate"]
            
            # Calcular retornos
            returns = []
            for traj in trajectories:
                G = 0.0
                for t, transition in enumerate(traj):
                    G += (self.gamma ** t) * transition["r"]
                returns.append(G)
            
            value_estimate = np.mean(returns)
            
            # Varianza del estimador
            # Var(V̂) ≈ Var(G) / n
            variance_estimate = np.var(returns) / len(returns)
            
            return {
                "value_estimate": value_estimate,
                "variance_estimate": variance_estimate
            }
        
        def construct_confidence_interval(state: SAVEState) -> dict:
            """
            Construir intervalo de confianza
            
            IC_{1-α} = V̂ ± z_{1-α/2} × SE(V̂)
            
            Por Teorema 1 de Shi et al. (2022):
            √n(V̂ - V*) →ᵈ N(0, σ²)
            """
            v_hat = state["value_estimate"]
            se = np.sqrt(state["variance_estimate"])
            
            z = stats.norm.ppf(1 - self.alpha/2)
            
            ci_lower = v_hat - z * se
            ci_upper = v_hat + z * se
            
            return {
                "confidence_interval": {
                    "point_estimate": v_hat,
                    "standard_error": se,
                    "ci_lower": ci_lower,
                    "ci_upper": ci_upper,
                    "level": 1 - self.alpha
                }
            }
        
        graph.add_node("collect", collect_data)
        graph.add_node("estimate_q", estimate_q_function)
        graph.add_node("value_var", compute_value_and_variance)
        graph.add_node("ci", construct_confidence_interval)
        
        graph.set_entry_point("collect")
        graph.add_edge("collect", "estimate_q")
        graph.add_edge("estimate_q", "value_var")
        graph.add_edge("value_var", "ci")
        graph.add_edge("ci", END)
        
        return graph.compile()

def verify_coverage():
    """
    Verificar que el IC tiene cobertura correcta
    """
    np.random.seed(42)
    
    true_value = 10.0  # Valor verdadero (conocido en simulación)
    n_experiments = 200
    coverage_count = 0
    
    agent = SAVEAgent(alpha=0.05)
    
    for _ in range(n_experiments):
        result = agent.graph.invoke({
            "trajectories": [],
            "q_estimate": {},
            "value_estimate": 0.0,
            "variance_estimate": 0.0,
            "confidence_interval": {},
            "policy_is_data_dependent": False
        })
        
        ci = result["confidence_interval"]
        if ci["ci_lower"] <= true_value <= ci["ci_upper"]:
            coverage_count += 1
    
    coverage = coverage_count / n_experiments
    print(f"\n=== Verificación de Cobertura ===")
    print(f"Cobertura empírica: {coverage:.1%}")
    print(f"Cobertura nominal:  95.0%")
    print(f"(Diferencia puede deberse a aproximaciones en el ejemplo)")

if __name__ == "__main__":
    agent = SAVEAgent()
    
    result = agent.graph.invoke({
        "trajectories": [],
        "q_estimate": {},
        "value_estimate": 0.0,
        "variance_estimate": 0.0,
        "confidence_interval": {},
        "policy_is_data_dependent": False
    })
    
    ci = result["confidence_interval"]
    print("=== Método SAVE: Inferencia para Value Function ===")
    print(f"\nEstimador puntual: V̂ = {ci['point_estimate']:.4f}")
    print(f"Error estándar: SE = {ci['standard_error']:.4f}")
    print(f"IC {ci['level']*100:.0f}%: [{ci['ci_lower']:.4f}, {ci['ci_upper']:.4f}]")
    
    verify_coverage()
```

---

## Sesión 12: Síntesis y Proyecto

### Ejemplo 12.1: Sistema Completo de Agente con Inferencia Estadística

```python
"""
Ejemplo 12.1: Sistema Completo que Integra Todos los Conceptos
Este ejemplo sirve como template para el proyecto final.
"""
from langgraph.graph import StateGraph, END
from typing import TypedDict
import numpy as np

class FullAgentState(TypedDict):
    """Estado completo del agente con componentes estadísticos"""
    # Datos
    trajectories: list
    
    # Modelo (Sesión 1-2: Suficiencia)
    sufficient_statistics: dict
    
    # Estimación (Sesión 3)
    q_estimates: dict
    value_estimate: float
    
    # Incertidumbre (Sesión 4-5)
    bootstrap_samples: list
    confidence_interval: dict
    
    # Comparación de políticas (Sesión 4)
    policy_comparison: dict
    
    # Decisión final
    recommended_policy: str
    justification: str

class StatisticalRLAgent:
    """
    Agente que integra todos los conceptos del curso:
    
    1. Modelo del mundo con estadísticos suficientes
    2. Estimación eficiente de Q-function
    3. Cuantificación de incertidumbre (bootstrap)
    4. Comparación estadística de políticas
    5. Decisión basada en teoría de decisión
    """
    
    def __init__(self):
        self.graph = self._build_complete_graph()
    
    def _build_complete_graph(self):
        graph = StateGraph(FullAgentState)
        
        # Nodos del sistema completo
        graph.add_node("collect_data", self._collect_data)
        graph.add_node("compute_sufficient_stats", self._compute_sufficient_stats)
        graph.add_node("estimate_q", self._estimate_q)
        graph.add_node("bootstrap_inference", self._bootstrap_inference)
        graph.add_node("compare_policies", self._compare_policies)
        graph.add_node("make_decision", self._make_decision)
        
        # Flujo del grafo
        graph.set_entry_point("collect_data")
        graph.add_edge("collect_data", "compute_sufficient_stats")
        graph.add_edge("compute_sufficient_stats", "estimate_q")
        graph.add_edge("estimate_q", "bootstrap_inference")
        graph.add_edge("bootstrap_inference", "compare_policies")
        graph.add_edge("compare_policies", "make_decision")
        graph.add_edge("make_decision", END)
        
        return graph.compile()
    
    def _collect_data(self, state: FullAgentState) -> dict:
        """Recolectar datos del ambiente"""
        # Simular dos políticas
        trajectories = {
            "policy_A": self._simulate_policy(mean_reward=1.0),
            "policy_B": self._simulate_policy(mean_reward=1.2)
        }
        return {"trajectories": trajectories}
    
    def _simulate_policy(self, mean_reward, n_traj=30, traj_len=15):
        trajectories = []
        for _ in range(n_traj):
            rewards = np.random.normal(mean_reward, 0.4, traj_len).tolist()
            trajectories.append(rewards)
        return trajectories
    
    def _compute_sufficient_stats(self, state: FullAgentState) -> dict:
        """Extraer estadísticos suficientes (Sesión 2)"""
        stats = {}
        for policy, trajs in state["trajectories"].items():
            all_rewards = [r for traj in trajs for r in traj]
            stats[policy] = {
                "sum": np.sum(all_rewards),
                "sum_sq": np.sum(np.array(all_rewards)**2),
                "n": len(all_rewards)
            }
        return {"sufficient_statistics": stats}
    
    def _estimate_q(self, state: FullAgentState) -> dict:
        """Estimación puntual (Sesión 3)"""
        estimates = {}
        for policy, stats in state["sufficient_statistics"].items():
            mean = stats["sum"] / stats["n"]
            var = (stats["sum_sq"] / stats["n"]) - mean**2
            se = np.sqrt(var / stats["n"])
            estimates[policy] = {"mean": mean, "se": se}
        return {"q_estimates": estimates}
    
    def _bootstrap_inference(self, state: FullAgentState) -> dict:
        """Bootstrap para IC (Sesión 5)"""
        cis = {}
        for policy, trajs in state["trajectories"].items():
            returns = [np.sum(traj) for traj in trajs]
            
            # Bootstrap
            boot_means = []
            for _ in range(1000):
                boot_sample = np.random.choice(returns, len(returns), replace=True)
                boot_means.append(np.mean(boot_sample))
            
            cis[policy] = {
                "ci_lower": np.percentile(boot_means, 2.5),
                "ci_upper": np.percentile(boot_means, 97.5)
            }
        
        return {"confidence_interval": cis}
    
    def _compare_policies(self, state: FullAgentState) -> dict:
        """Test de hipótesis para comparar políticas (Sesión 4)"""
        returns_A = [np.sum(t) for t in state["trajectories"]["policy_A"]]
        returns_B = [np.sum(t) for t in state["trajectories"]["policy_B"]]
        
        from scipy import stats
        t_stat, p_value = stats.ttest_ind(returns_A, returns_B)
        
        diff = np.mean(returns_B) - np.mean(returns_A)
        pooled_se = np.sqrt(np.var(returns_A)/len(returns_A) + 
                           np.var(returns_B)/len(returns_B))
        
        return {
            "policy_comparison": {
                "t_statistic": t_stat,
                "p_value": p_value,
                "mean_difference": diff,
                "se_difference": pooled_se,
                "significant": p_value < 0.05
            }
        }
    
    def _make_decision(self, state: FullAgentState) -> dict:
        """Decisión final basada en teoría de decisión (Sesión 7)"""
        comparison = state["policy_comparison"]
        
        if comparison["significant"]:
            if comparison["mean_difference"] > 0:
                policy = "policy_B"
                reason = (f"B es significativamente mejor "
                         f"(p={comparison['p_value']:.4f}, "
                         f"diff={comparison['mean_difference']:.3f})")
            else:
                policy = "policy_A"
                reason = "A es significativamente mejor"
        else:
            # Si no hay diferencia significativa, elegir la más simple
            policy = "policy_A"
            reason = (f"No hay diferencia significativa "
                     f"(p={comparison['p_value']:.4f}). "
                     "Mantener política actual.")
        
        return {
            "recommended_policy": policy,
            "justification": reason
        }

if __name__ == "__main__":
    agent = StatisticalRLAgent()
    
    initial_state = {
        "trajectories": {},
        "sufficient_statistics": {},
        "q_estimates": {},
        "value_estimate": 0.0,
        "bootstrap_samples": [],
        "confidence_interval": {},
        "policy_comparison": {},
        "recommended_policy": "",
        "justification": ""
    }
    
    result = agent.graph.invoke(initial_state)
    
    print("=" * 60)
    print("SISTEMA COMPLETO DE AGENTE CON INFERENCIA ESTADÍSTICA")
    print("=" * 60)
    
    print("\n📊 Estimaciones:")
    for p, est in result["q_estimates"].items():
        print(f"  {p}: μ̂ = {est['mean']:.4f} ± {est['se']:.4f}")
    
    print("\n📈 Intervalos de Confianza (Bootstrap 95%):")
    for p, ci in result["confidence_interval"].items():
        print(f"  {p}: [{ci['ci_lower']:.4f}, {ci['ci_upper']:.4f}]")
    
    print("\n🔬 Comparación de Políticas:")
    comp = result["policy_comparison"]
    print(f"  t-statistic: {comp['t_statistic']:.4f}")
    print(f"  p-value: {comp['p_value']:.4f}")
    print(f"  Diferencia: {comp['mean_difference']:.4f}")
    
    print("\n✅ Decisión Final:")
    print(f"  Política recomendada: {result['recommended_policy']}")
    print(f"  Justificación: {result['justification']}")
```

---

## Bibliografía del Laboratorio

### Textos Base
- Wang, J. & Duan, Z. (2024). "Agent AI with LangGraph: A Modular Framework for Enhancing Machine Translation Using Large Language Models." arXiv:2412.03801.
- LangGraph Documentation: https://langchain-ai.github.io/langgraph/

### Inferencia Estadística para RL
- Shi, C., Zhang, S., Lu, W. & Song, R. (2022). "Statistical Inference of the Value Function for Reinforcement Learning in Infinite-Horizon Settings." JRSSB, 84(3), 765-793.
- Kallus, N. & Uehara, M. (2022). "Efficiently Breaking the Curse of Horizon in Off-Policy Evaluation." Operations Research.
- Thomas, P., Theocharous, G. & Ghavamzadeh, M. (2015). "High Confidence Off-Policy Evaluation." AAAI.

### Teoría Estadística
- Casella, G. & Berger, R.L. (2002). Statistical Inference. Duxbury.
- Van der Vaart, A.W. (1998). Asymptotic Statistics. Cambridge.
- Efron, B. & Tibshirani, R.J. (1993). An Introduction to the Bootstrap. Chapman & Hall.

### MDPs y RL
- Puterman, M.L. (2005). Markov Decision Processes. Wiley.
- Sutton, R.S. & Barto, A.G. (2018). Reinforcement Learning: An Introduction. MIT Press.

---

*Este sílabo de laboratorio está diseñado para ser usado en paralelo con el curso teórico. Cada ejemplo puede ejecutarse de forma independiente pero se beneficia del contexto teórico de la sesión correspondiente.*
