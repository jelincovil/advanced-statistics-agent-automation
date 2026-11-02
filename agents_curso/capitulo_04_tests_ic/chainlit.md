# Agente A/B Testing con Control FDR
====================================================

## 🚀 Interfaz Chainlit - Guía de Visualización

### 📊 Imágenes en el Chat

Chainlit muestra automáticamente las imágenes adjuntas (PNG, JPG, SVG) en el chat. Cada resultado incluye:

- **Resultados estadísticos** en formato markdown optimizado
- **Grafo visual** del flujo del agente LangGraph

---

## 📈 Navegación del Agente

### Flujo secuencial: 6 nodos + inicialización

```
      (nodos de conversión)
  ┌───────┴────────┐
  ↓                ↓
 ✓ INICIO     init (estado inicial)
  ↓
 collect_data
  ↓
welch_test
  ↓
compute_ci
  ↓
benjamini_hochberg
  ↓
llm_interpret
  ↓
decide
  ↓
ΕΟΝ (FIN)
```

---

## 🗂️ Archivos del Proyecto

| Archivo | Propósito |
|---------|-----------|
| **`app.py`** | Interfaz Chainlit principal (with grafo visual) |
| **`agent_graph_clean.py`** | Definición del grafo LangGraph |
| **`run_simulation.py`** | Wrapper de ejecución |
| **`show_help.py`** | Script de ayuda |
| **`.env`** | Configuración API key OpenRouter |
| **`chainlit.md`** | Documentación de Chainlit |
| **`environment.yml`** | Dependencias detalladas |

---

## 💬 Comandos Disponibles

### Operación del análisis

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/run` | Ejecutar análisis completo A/B Testing | `/run` |
| `/reset` | Reiniciar estado del agente | `/reset` |

### Parámetros de configuración

| Comando | Descripción | Rango | Ejemplo |
|---------|-------------|-------|---------|
| `/alpha <valor>` | Nivel de significancia α | 0.01 - 0.10 | `/alpha 0.01` |
| `/policies <n>` | Número de políticas a comparar | 2 - 6 | `/policies 4` |
| `/samples <n>` | Tamaño de muestra por política | 50 - 1000 | `/samples 200` |
| `/q_level <valor>` | Nivel FDR para BH | 0.01 - 0.50 | `/q_level 0.10` |

---

## 📊 Tipos de Resultados

Responderán con tres decisiones:

| Decisión | Interpretación |
|----------|----------------|
| **ADOPTAR_B** | Política B tiene evidencia de ser mejor que A (α < 0.05) |
| **MANTENER_A** | Política A muestra evidencia de ser mejor que B |
| **NO_HAY_EVIDENCIA** | Sin conclusiones estadísticas significativas |

---

## ⚙️ Dependencias

```bash
mamba install -n env_graph3:
  - numpy scipy
  - langgraph
  - langchain-openai
  - python-graphviz
  - chainlit
  - python-dotenv
```

---

## 🔑 Configuración API Key

Para habilitar interpretación adicional con IA OpenRouter, configure:

```bash
export OPENROUTER_API_KEY=sk-or-v1-YOUR_KEY_HERE
```

Sin API key, el fallback genera un análisis básico.

---

## 💡 Diagrama del Flujo de Datos

```
--------- INPUT ----------
|   State (dict)         |
|   - alpha: float       |
|   - q_value: float     |
--------------------------
           ↓
--------- NODO 1 ----------
| collect_data()         |
| Genera rewards [A,B,C,D]|
| Rango: ~100-1000       |
--------------------------
           ↓
--------- NODO 2 ----------
| welch_test()           |
| Compara π_A vs π_B     |
| Métricas: t, p, d, d²  |
--------------------------
           ↓
--------- NODO 3 ----------
| compute_ci()           |
| Intervalo 95%         |
| Contiene 0?           |
--------------------------
           ↓
--------- NODO 4 ----------
| benjamini_hochberg()  |
| FDR para m-1 comparaciones|
| Rechaza 0/N hypotheses|
--------------------------
           ↓
--------- NODO 5 ----------
| llm_interpret()       |
| LLM (fallback básico)|
| O interpretación IA   |
--------------------------
           ↓
--------- NODO 6 ----------
| decide()               |
| ADOPTAR_B / MANTENER_A / NO_HAY_EVIDENCIA|
--------------------------
           ↓
--------- END ----------
```

---

Built on **LangGraph** + **Chainlit**  
Capítulo 4: Statistical Learning