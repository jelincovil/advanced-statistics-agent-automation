# 🎯 Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre

## Descripción

Este es el **agente capstone** que integra todos los conceptos del libro en un framework unificado de decisión bajo incertidumbre con asistencia de LLM.

### Paradigma Central

El agente opera en **tres modos** adaptativos:

| Modo | Trigger | Acción | Fundamento Estadístico |
|------|---------|--------|----------------------|
| 🔍 **EXPLORE** | IC ancho > ε_explore | Recolectar datos | Reducir incertidumbre epistémica |
| 🤖 **CONSULT** | ε_consult < IC ≤ ε_explore | Preguntar al LLM | Orientación estratégica |
| 🎯 **ACT** | IC ancho ≤ ε_consult | Ejecutar mejor acción | Decisiones informadas |

### Flujo de Decisión

```
                    ┌─────────────────────┐
                    │   initialize_agent   │
                    └──────────┬──────────┘
                               ▼
                    ┌─────────────────────┐
                    │ explore_environment  │◄──────────────────┐
                    └──────────┬──────────┘                   │
                               ▼                              │
                  ┌─────────────────────────┐                 │
                  │  compute_uncertainty    │                 │
                  └──────────┬──────────────┘                 │
                             ▼                               │
           ┌──────────────────────────────────┐               │
           │  check_uncertainty_threshold     │               │
           └──┬──────────┬──────────┬─────────┘               │
              │          │          │                         │
         width > ε   ε_consult  width ≤ ε_consult             │
              │       < width        │                        │
              ▼          ▼          ▼                         │
       ┌──────────┐ ┌──────────┐ ┌──────┐                    │
       │ EXPLORE  │ │ CONSULT  │ │ ACT  │                    │
       └────┬─────┘ └────┬─────┘ └──┬───┘                    │
            │            │          │                        │
            │            ▼          ▼                        │
            │   ┌──────────────┐ ┌─────────────┐            │
            │   │update_meta   │ │evaluate_perf │            │
            │   │_criterion    │ └──────┬──────┘            │
            │   └──────┬───────┘        │                   │
            │          │           ┌────▼────┐              │
            │          │           │  check  │──no──┐       │
            │          │           │ stopping│      │       │
            │          │           └────┬────┘      │       │
            │          │                │yes        │       │
            │          │                ▼           │       │
            │          │         ┌──────────────┐   │       │
            │          │         │run_ablation  │   │       │
            │          │         └──────┬───────┘   │       │
            │          │                ▼           │       │
            │          │         ┌──────────────┐   │       │
            │          │         │llm_interpret │   │       │
            │          │         └──────┬───────┘   │       │
            │          │                ▼           │       │
            │          │         ┌──────────────┐   │       │
            │          │         │ final_report │   │       │
            │          │         └──────┬───────┘   │       │
            │          │                ▼           │       │
            │          │               END          │       │
            │          │                            │       │
            └──────────┴────────────────────────────┘       │
                                        (bucle) ───────────┘
```

## Estudio de Ablation

El agente ejecuta tres variantes para cuantificar la contribución de cada componente:

| Variante | Componente Activo | Estrategia |
|----------|------------------|------------|
| 📊 **Solo Estadística** | ICs + UCB | Exploración guiada por varianza |
| 🤖 **Solo LLM** | Heurísticas del LLM | Exploración heurística |
| 🔗 **Combinado** | IC + LLM | Exploración adaptativa con meta-criterio |

### Resultados Esperados

- **Solo Estadística**: Correcto pero conservador. Puede no explorar eficientemente.
- **Solo LLM**: Rápido pero sin garantías estadísticas.
- **Combinado**: **Superior** — explora eficientemente con garantías formales.

## Arquitectura Técnica

### Nodos del Grafo LangGraph

1. **initialize_agent**: Priors, presupuesto, umbrales
2. **explore_environment**: UCB-like, prioriza brazos con mayor incertidumbre
3. **compute_uncertainty**: Bootstrap CI para medias de cada brazo
4. **check_uncertainty_threshold**: Decisión EXPLORE/CONSULT/ACT
5. **consult_llm**: Prompt estructurado → recomendación del LLM
6. **update_meta_criterion**: Ajusta ε dinámicamente según presupuesto
7. **act**: Selecciona y ejecuta mejor brazo
8. **evaluate_performance**: Registra recompensa acumulada
9. **check_stopping**: Budget agotado / IC estrecho / max iteraciones
10. **synthesize_results**: Combina inferencia + guía LLM
11. **run_ablation**: Ejecuta 3 variantes y compara
12. **llm_interpret**: LLM explica resultados
13. **final_report**: Reporte consolidado

### Aristes Condicionales

- `check_uncertainty_threshold` → `explore | consult | act | ablation`
- `check_stopping` → `compute_uncertainty | ablation`

## Instalación y Ejecución

### 1. Crear entorno
```bash
conda env create -f environment.yml
conda activate cap12_sintesis
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
| `ejecutar agente` | Ejecución completa con ablation |
| `explicar paradigma` | Marco conceptual de decisión + LLM |
| `explicar ablation` | Qué muestra el estudio de ablation |
| `explicar meta-criterio` | Umbrales adaptativos |
| `explicar ReAct` | Framework Reasoning and Acting |
| `explicar Reflexion` | Framework de reflexión verbal |
| `diagnosticar decisión` | Paso a paso del proceso |
| `comparar variantes` | Tabla de ablation |
| `ver ICs` | Intervalos de confianza por brazo |
| `contribución LLM` | Detalle de consultas al LLM |
| *Cualquier pregunta* | LLM responde sobre síntesis |

## Estructura de Archivos

```
capitulo_12_sintesis/
├── state_schema.py       # TypedDict SynthesisState
├── agent_graph.py        # Grafo con aristas condicionales
├── app.py                # Interfaz Chainlit
├── environment.yml       # Dependencias
└── README.md             # Este archivo
```

## Integración con Capítulos Anteriores

| Concepto | Cap. 10 (OPE) | Cap. 11 (SAVE) | Cap. 12 (Síntesis) |
|----------|--------------|----------------|-------------------|
| **Intervalos de Confianza** | IC para DM/IS/DR | IC asintótico + bootstrap | IC bootstrap para brazos |
| **Varianza Espectral** | Varianza de IS | σ²_∞ con dependencia | Incertidumbre como ancho de IC |
| **Overlap** | π_b(a\|s) > 0 | Mezcla Markoviana | Exploración suficiente |
| **Doble Robustez** | DR estimator | N/A | Estadística + LLM = doble respaldo |
| **LLM** | Interpreta OPE | Explica SAVE | Guía decisiones activamente |

## Referencias

- **Shi et al. (2024) JASA**: "Uncertainty-Aware Decision Making with Language Agents"
- **Yao et al. (2023) ICLR ReAct**: "ReAct: Synergizing Reasoning and Acting in Language Models"
- **Shinn et al. (2023) NeurIPS Reflexion**: "Reflexion: Language Agents with Verbal Reinforcement Learning"
- **Zhai et al. (2025) AAAI**: "Q-Values for LLM Agents"

## Notas Pedagógicas

Este agente demuestra que la **inferencia estadística formal** y los **LLM agents** no son paradigmas opuestos, sino **complementarios**:

1. Los **ICs** proporcionan garantías formales sobre la incertidumbre
2. El **LLM** aporta intuición, razonamiento y estrategia
3. La **combinación** produce decisiones más robustas que cualquiera solo

Este es el mensaje central del libro: la estadística rigurosa y los modelos de lenguaje pueden trabajar juntos para mejorar la toma de decisiones.
