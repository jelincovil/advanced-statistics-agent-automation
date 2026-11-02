# Lab F3 — Estimación Óptima en Agentes

Prototipo LangGraph + Chainlit que demuestra empíricamente tres teoremas de estimación óptima en el entorno **FrozenLake-v1** (Gymnasium).

## Teoremas implementados

| Teorema | Fórmula | Implementación |
|---|---|---|
| **Rao-Blackwell** | Var(E[Q_MC \| T]) ≤ Var(Q_MC) | Value iteration con modelo θ̂ como estimador condicional |
| **Cramér-Rao** | Var(θ̂) ≥ 1 / (n · I(θ)) | I(θ) = 1/(θ(1−θ)) para transiciones Bernoulli |
| **UMVUE** | θ̂(s,a,s') = N(s,a,s') / N(s,a) | Frecuencia empírica — UMVUE por Lehmann-Scheffé |

## Requisitos

- Python >= 3.11
- `ANTHROPIC_API_KEY`

## Instalación

```bash
pip install -r requirements.txt
cp .env.example .env
# Editar .env y añadir: ANTHROPIC_API_KEY=sk-ant-...
```

## Ejecución

```bash
chainlit run chainlit_app.py -w --port 8000
```

Abrir [http://localhost:8000](http://localhost:8000).

## Comandos disponibles

| Comando | Descripción | Ejemplo |
|---|---|---|
| `/run [n] [gamma]` | Ejecuta experimento completo | `/run 500 0.95` |
| `/compare` | Compara MC vs RB vs CR con n=100,200,500,1000 | `/compare` |
| `/sample_plan [ε]` | Calcula episodios mínimos para Var(V̂) ≤ ε² | `/sample_plan 0.05` |
| `/explain [concepto]` | Explica teorema con datos del experimento | `/explain rao-blackwell` |
| *(pregunta libre)* | El agente responde usando los resultados actuales | `¿Por qué var_rb < var_mc?` |

Conceptos disponibles para `/explain`: `rao-blackwell`, `cramer-rao`, `umvue`, `fisher`, `sample-planning`.

## Flujo del grafo

```
collect → (decide) → collect        ← loop hasta n_episodes
                   → estimate
                     → rao_blackwell
                       → cramer_rao
                         → analyst → END
```

## Estructura del proyecto

```
lab_F3/
├── chainlit_app.py          # Entry point y routing de comandos
├── stream_handler.py        # Updates en tiempo real a la UI
├── plot_utils.py            # Gráficas de convergencia, comparación y sample planning
├── requirements.txt
├── .env.example
├── prompts/
│   ├── analyst_system.md    # System prompt del nodo analyst
│   └── cramer_rao_template.txt
└── agent/
    ├── state.py             # AgentState TypedDict
    ├── graph.py             # Construcción y compilación del grafo
    └── nodes/
        ├── collect_node.py       # Ejecuta episodios, acumula N(s,a,s')
        ├── decide_node.py        # Router condicional
        ├── estimate_node.py      # UMVUE, Q_MC, V̂^π
        ├── rao_blackwell_node.py # Estimador RB + comparación de varianzas
        ├── cramer_rao_node.py    # Cota CR + sample planning
        └── analyst_node.py       # Interpretación LLM con streaming
```

## Limitaciones conocidas

- Bootstrap para varianza empírica es aproximado (~5% error con n=500)
- La Rao-Blackwell se aproxima vía value iteration con θ̂, no con la integral E[Q|T] exacta
- FrozenLake con `is_slippery=True` genera trayectorias cortas frecuentes que sesgan V̂ en estados distales
- La cota de Cramér-Rao aplica estrictamente a estimadores insesgados; Q_MC puede tener sesgo pequeño por γ < 1
- Sin checkpointer persistente — el estado se reinicia al cerrar el servidor
