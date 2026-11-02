# 📐 Capítulo 11: Inferencia Secuencial para Funciones de Valor (SAVE)

## Descripción

Este agente realiza **inferencia estadística asintótica** para funciones de valor V^π, abordando el desafío fundamental de la **dependencia temporal** en los datos de aprendizaje por refuerzo.

### Problema Central

Los retornos descontados G₁, G₂, ..., G_n de una cadena de Markov **no son independientes**. Esto invalida el TCL estándar y requiere herramientas especializadas:

| Concepto | Fórmula | Descripción |
|----------|---------|-------------|
| **Varianza Espectral** | σ²_∞ = Var(G₀) + 2 Σ_{k=1}^∞ Cov(G₀, G_k) | Varianza asintótica del promedio |
| **TCL Markov** | √n(V̂-V*) →d N(0, σ²_∞) | Bajo ergodicidad geométrica |
| **ESS** | n_eff = n / τ_int | Muestras "reales" de información |
| **τ_int** | 1 + 2 Σ ρ(k) | Tiempo de autocorrelación integrado |

## Métodos Implementados

### 1. Varianza Espectral
Estima σ²_∞ usando la suma de autocovarianzas con ventana de Bartlett:
```
σ̂²_∞ = Var̂(G) + 2 Σ_{k=1}^{K} (1 - k/K) Ĉov(G₀, G_k)
```

### 2. Batch Means
Divide los datos en k lotes de tamaño m = n/k y usa:
```
SE = std(batch_means) / √k
```
La convergencia al aumentar m verifica la validez del TCL.

### 3. Block Bootstrap
Remuestrea bloques consecutivos de tamaño b para preservar la dependencia:
```
G*₁,...,G*_{kb} = concat(B_{I₁}, ..., B_{Ik}), I_j ~ Uniform(1,...,n/b)
```

## Arquitectura

```
generate_markov_trajectories → compute_v_hat → estimate_se
    → asymptotic_ci → bootstrap_ci → verify_mixing
    → compute_batch_se → power_analysis → design_experiment
    → llm_interpret → final_report
```

### Nodos del Grafo

1. **generate_markov_trajectories**: Genera trayectorias de cadena ergódica
2. **compute_v_hat**: V̂ = (1/n) Σ G_i (promedio de retornos descontados)
3. **estimate_se**: SE vía varianza espectral σ²_∞
4. **asymptotic_ci**: IC basado en TCL para cadenas de Markov
5. **bootstrap_ci**: Block bootstrap para datos dependientes
6. **verify_mixing**: Diagnostica ergodicidad geométrica (ACF, ESS, τ_int)
7. **compute_batch_se**: Múltiples tamaños de lote para verificar convergencia
8. **power_analysis**: n_min para detectar δ con potencia 1-β
9. **design_experiment**: Recomendación de tamaño muestral
10. **llm_interpret**: LLM explica resultados
11. **final_report**: Consolidación de IC + potencia + diseño

## Instalación y Ejecución

### 1. Crear entorno
```bash
conda env create -f environment.yml
conda activate cap11_save
```

### 2. Configurar API Key
```bash
export OPENROUTER_API_KEY="sk-or-v1-tu-clave-aqui"
```

### 3. Ejecutar
```bash
chainlit run app.py
```

### 4. Abrir en navegador
```
http://localhost:8000
```

## Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `ejecutar pipeline` | Análisis SAVE completo |
| `explicar SAVE` | Teoría del framework SAVE |
| `explicar TCL Markov` | TCL para cadenas de Markov |
| `explicar varianza espectral` | σ²_∞ y dependencia temporal |
| `explicar batch means` | Método de lotes |
| `explicar block bootstrap` | Bootstrap por bloques |
| `análisis de potencia` | Tabla n_min vs δ |
| `diseño experimental` | Recomendación de n |
| `mezcla` / `autocorrelación` | Diagnósticos de mezcla |
| `comparar ICs` | Asintótico vs bootstrap |
| *Cualquier pregunta* | LLM responde sobre SAVE |

## Estructura de Archivos

```
capitulo_11_inferencia_vp/
├── state_schema.py       # TypedDict SAVEState
├── agent_graph.py        # Grafo LangGraph con 11 nodos
├── app.py                # Interfaz Chainlit
├── environment.yml       # Dependencias
└── README.md             # Este archivo
```

## Referencias

- **Shi et al. (2022) JRSSB**: "Sequential Inference for Value Functions"
- **Kallus & Uehara (2020)**: "Double/Debiased Machine Learning for Offline Reinforcement Learning"
- **Kallus & Uehara (2022)**: "Efficiently Breaking the Curse of Horizon in Off-Policy Evaluation"
- **Jones et al. (2006)**: "Batch Means and Spectral Variance Estimation"

## Notas Pedagógicas

Este agente demuestra que **ignorar la dependencia temporal** puede llevar a:
- Intervalos de confianza que no cubren el valor verdadero
- Tests de hipótesis con tasa de error inflated
- Tamaños muestrales insuficientes

El análisis SAVE es esencial para cualquier inferencia rigurosa en RL.
