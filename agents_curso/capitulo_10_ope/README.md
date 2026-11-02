# 🧮 Capítulo 10: Off-Policy Evaluation (OPE) Fundamentos

## Descripción

Este agente implementa un **pipeline completo de evaluación off-policy** para aprendizaje por refuerzo. El agente simula datos de una política de comportamiento π_b y estima el valor de una política objetivo π_e utilizando tres estimadores fundamentales:

| Estimador | Fórmula | Sesgo | Varianza |
|-----------|---------|-------|----------|
| **Direct Method (DM)** | V̂_DM = Σ_s μ₀(s) Σ_a π_e(a\|s) Q̂(s,a) | Alto (model bias) | Baja |
| **Importance Sampling (IS)** | V̂_IS = (1/n) Σ ρ_t G_t | Cero (insesgado) | Alta |
| **Doubly Robust (DR)** | V̂_DR = V̂_DM + (1/n) Σ ρ_t(G_t - Q̂(S_t,A_t)) | Bajo | Media |

## Conceptos Clave

### Condición de Overlap
La evaluación off-policy requiere que:
> π_b(a|s) > 0 siempre que π_e(a|s) > 0

Si esta condición se viola, los estimadores IS y DR pueden tener varianza infinita.

### Curse of Horizon
La varianza del estimador IS crece **exponencialmente** con el horizonte H:
```
Var(V̂_IS) ∝ (max ρ)^{2H}
```

### Doble Robustez (Jiang & Li, 2016)
El estimador DR es consistente si:
- El modelo Q̂ es consistente (como DM), **O**
- π_b = π_e (como IS)

→ Solo es insesgado si **ambos** modelos fallan simultáneamente.

## Arquitectura

```
generate_behavior_data → define_target_policy → direct_method
    → importance_sampling → doubly_robust → compute_standard_errors
    → diagnose_overlap → compare_estimators → sensitivity_analysis
    → llm_interpret → final_report
```

### Nodos del Grafo LangGraph

1. **generate_behavior_data**: Simula datos de π_b (política uniforme) en un MDP tabular
2. **define_target_policy**: Define π_e como política ε-greedy
3. **direct_method**: Regresión para estimar Q̂(s,a), luego V̂_DM
4. **importance_sampling**: Ratios de importancia ρ = π_e/π_b
5. **doubly_robust**: Combinación DM + corrección IS
6. **compute_standard_errors**: SE para cada estimador
7. **diagnose_overlap**: Verifica condición π_b > 0
8. **compare_estimators**: Tabla sesgo-varianza-MSE
9. **sensitivity_analysis**: Varía ε, observa estabilidad
10. **llm_interpret**: LLM explica resultados
11. **final_report**: Reporte consolidado

## Instalación y Ejecución

### 1. Crear entorno con Conda
```bash
conda env create -f environment.yml
conda activate cap10_ope
```

### 2. Configurar API Key
```bash
export OPENROUTER_API_KEY="sk-or-v1-tu-clave-aqui"
```

### 3. Ejecutar el agente
```bash
chainlit run app.py
```

### 4. Abrir en el navegador
```
http://localhost:8000
```

## Comandos Disponibles en el Chat

| Comando | Descripción |
|---------|-------------|
| `ejecutar pipeline` | Ejecuta el análisis OPE completo |
| `explicar OPE` | El LLM explica la teoría de OPE |
| `explicar overlap` | Explica la condición de solapamiento |
| `explicar curse of horizon` | Explica la varianza exponencial |
| `análisis de sensibilidad` | Varía ε y muestra estabilidad |
| `explicar doble robustez` | Explica la propiedad del estimador DR |
| `comparar estimadores` | Tabla de sesgo-varianza |
| *Cualquier pregunta* | El LLM responde sobre OPE |

## Estructura de Archivos

```
capitulo_10_ope/
├── state_schema.py      # Definición TypedDict del estado OPE
├── agent_graph.py        # Grafo LangGraph con todos los nodos
├── app.py                # Interfaz Chainlit con OpenRouter
├── environment.yml       # Dependencias Conda
└── README.md             # Este archivo
```

## Referencias

- **Jiang & Li (2016)**: "Doubly Robust Off-Policy Value Evaluation for Reinforcement Learning"
- **Dudík et al. (2011)**: "Optimally Solving MDPs with Continuous Actions, Rewards, and Transition Probabilities"
- **Thomas et al. (2015)**: "High Confidence Policy Improvement"
- **Precup et al. (2000)**: "Eligibility Traces for Off-Policy Policy Evaluation"

## Notas Pedagógicas

Este agente está diseñado como herramienta educativa para un texto a nivel doctoral. Los datos son simulados y las estimaciones incluyen sesgo intencional en DM para demostrar las diferencias entre estimadores. En producción, se usarían estimadores más sofisticados como weighted IS o PDIS.
