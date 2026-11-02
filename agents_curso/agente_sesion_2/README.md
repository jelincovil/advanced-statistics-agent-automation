# Lab F.2 — Agente de Estadístico Suficiente para Bernoulli(θ)

Implementación de dos agentes LangGraph que comparan el uso de un **estadístico suficiente** (óptimo) frente a un estadístico insuficiente (Welford) para estimar el parámetro θ de una distribución Bernoulli.

## Fundamento teórico

Dada una secuencia de observaciones i.i.d. $x_1, x_2, \ldots, x_n \sim \text{Bernoulli}(\theta)$, el teorema de **Neyman-Fisher** establece que:

$$T_n = \left(n,\ \sum_{i=1}^n x_i\right)$$

es el **estadístico suficiente minimal** para θ. Esto significa que $T_n$ captura *toda* la información de los datos relevante para estimar θ, sin importar el tamaño del stream.

El estimador $\hat{\theta} = \frac{\sum x_i}{n}$ es el **UMVUE** (Estimador Insesgado de Varianza Mínima Uniformemente) por el teorema de **Lehmann-Scheffé**.

La **divergencia KL** $D_{KL}(\text{Bin}(k, \hat{\theta}) \,\|\, \text{Bin}(k, \theta))$ cuantifica la pérdida de información respecto al θ verdadero.

## Arquitectura

El proyecto contiene dos agentes LangGraph con la misma topología de grafo:

```
observe → update → decide → (observe | END)
```

### Agente Suficiente (`sufficient_agent.py`)

Estado: `SufficientState`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `count` | int | n — número de observaciones acumuladas |
| `total` | int | Σxᵢ — suma exacta de observaciones |
| `theta_hat` | float | Estimador UMVUE: total / count |
| `kl` | float | D_KL respecto a θ_true (opcional) |

**Actualización:** `count += 1`, `total += x` — O(1) por observación, O(n) total. El estadístico tiene dimensión fija O(2) independientemente de n.

### Agente Insuficiente / Baseline (`baseline_agent.py`)

Estado: `InsufficientState`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `n` | int | Número de observaciones |
| `mean` | float | Media de Welford (acumulación con pérdida) |
| `theta_hat` | float | Estimador: mean |
| `kl` | float | D_KL respecto a θ_true (opcional) |

**Actualización:** $\bar{x}_n = \bar{x}_{n-1} + \frac{x - \bar{x}_{n-1}}{n}$ — introduce error de punto flotante que impide recuperar Σxᵢ exactamente. Estadístico **no suficiente**.

### Comparación

| Propiedad | Suficiente | Insuficiente (Welford) |
|-----------|-----------|------------------------|
| Estadístico | (count, total) | (n, mean) |
| Recupera Σxᵢ | Sí (exacto) | No (pérdida de precisión flotante) |
| Complejidad total | O(n) | O(n) |
| D_KL | Mínima posible | Mayor (pérdida de información) |

## Instalación

```bash
pip install -r requirements.txt
```

Dependencias: `numpy`, `scipy`, `langgraph`, `langsmith`, `langchain-core`.

## Uso

### `run` — Ejecutar el agente

```bash
python main.py run
python main.py run --n 5000 --theta-true 0.4 --agent sufficient
python main.py run --n 5000 --agent baseline
```

Opciones:

| Flag | Default | Descripción |
|------|---------|-------------|
| `--n` | 1000 | Número de observaciones |
| `--theta-true` | 0.3 | Parámetro verdadero θ |
| `--seed` | 42 | Semilla aleatoria |
| `--agent` | `sufficient` | `sufficient` o `baseline` |

### `benchmark` — Comparar complejidad O(1) vs O(n²)

```bash
python main.py benchmark
python main.py benchmark --skip-large   # omite n > 10 000
python main.py benchmark --sizes 500,5000,50000
```

Mide la diferencia de velocidad entre la estrategia de actualización O(1) (estadístico suficiente) y un recálculo ingenuo O(n) por paso (O(n²) total).

### `kl-compare` — Comparar pérdida de información

```bash
python main.py kl-compare
python main.py kl-compare --n 2000 --theta-true 0.7
```

Ejecuta ambos agentes sobre los mismos datos y reporta D_KL de cada uno, más la diferencia ΔD_KL.

### `evaluate` — Evaluación en LangSmith Studio v2

```bash
export LANGSMITH_API_KEY=lsv2_pt_...
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_PROJECT=lab_F2_sufficient_state_agent

python main.py evaluate --agent sufficient
python main.py evaluate --agent baseline
```

Crea (o reutiliza) un dataset con 6 escenarios de evaluación y ejecuta tres evaluadores:

- **`kl_below_threshold`**: D_KL ≤ umbral por escenario (score binario).
- **`theta_convergence`**: |θ̂ - θ| ≤ 3/√n — convergencia a 3 desviaciones estándar (score binario).
- **`kl_score`**: 1/(1 + D_KL) — score continuo para comparación directa.

### `compare` — Comparación directa en LangSmith

```bash
python main.py compare
```

Evalúa ambos agentes sobre el mismo dataset y los registra en el mismo proyecto de LangSmith para comparación side-by-side en Studio.

## Estructura del proyecto

```
agente_sesion_2/
├── main.py               # CLI principal (entry point)
├── sufficient_agent.py   # Agente suficiente — LangGraph + T_n = (count, total)
├── baseline_agent.py     # Agente insuficiente — LangGraph + Welford
├── experiments.py        # Benchmark de complejidad y experimento de pérdida KL
├── evaluate_langsmith.py # Integración con LangSmith Studio v2
└── requirements.txt      # Dependencias Python
```
