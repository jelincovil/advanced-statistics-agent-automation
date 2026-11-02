# Teoría Avanzada de Inferencia Estadística aplicada a la decisión secuencial y los agentes inteligentes

Material del curso de doctorado homónimo: un puente formal entre la teoría de
decisión de Wald, los procesos de decisión de Markov y la inferencia
semiparamétrica, con el objetivo de diseñar agentes con garantías estadísticas.
Doce semanas, 70 % teoría y 30 % laboratorio.

El repositorio se organiza en tres bloques independientes pero acoplados entre sí.

## Mapa del repositorio

| Ruta | Qué contiene | Herramienta |
|---|---|---|
| `book_stat_inference_v0/` | El manuscrito completo, con sus laboratorios | Typst, Python |
| `agents_curso/` | Laboratorios de agentes (LangGraph + Chainlit) por sesión y por capítulo | Python |
| `diapositivas/` | Sílabo, notas de clase y las presentaciones del curso | Typst, Markdown |

---

## 1. `book_stat_inference_v0/` — el libro

Monografía autónoma que compila sin configuración externa.

- **Entrada:** `main.typ` (ensambla portada, frontmatter, cuatro partes, apéndices y bibliografía).
- **Plantilla:** `plantilla.typ` — contadores, entornos de teorema, `#chapter-alias`, watermark.
- **Contenido:** introducción + 12 capítulos (`capitulos/`) y 7 apéndices A–G (`apendices/`).
- **Bibliografía:** `referencias.bib`.
- **Laboratorios:** `lab00`–`lab12` (14 scripts), uno o más por capítulo; `ejecutar_todos.py`
  los corre todos con semillas fijas y escribe `resultados_laboratorios.json` y `versiones.json`.
- **Hoja de ruta:** `PENDIENTES.md` lista los huecos declarados del manuscrito.
  Los cuadros rojos `PENDIENTE` del PDF son **deliberados**: declaran lo que falta
  en lugar de rellenarlo con prosa plausible.

La tesis del libro está acotada a lo que se demuestra: la incrustación fiel
`Dec → MDP`, un paso y determinista (cap. 5).

### Compilar el libro

```bash
cd book_stat_inference_v0
typst compile main.typ
```

Requiere [Typst](https://typst.app) (probado con 0.15.1). El paquete
`@preview/cetz:0.3.4`, usado en dos diagramas, se descarga solo en la primera
compilación. Todas las rutas del proyecto son relativas, así que la carpeta
también se puede subir tal cual a la app web de Typst (`main.typ` como archivo
de entrada).

### Ejecutar los laboratorios

```bash
cd book_stat_inference_v0
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt   # numpy, scipy, scikit-learn, gymnasium, pandas
python ejecutar_todos.py
```

Las versiones exactas del entorno de referencia están en `versiones.json`.

---

## 2. `agents_curso/` — laboratorios de agentes

Proyectos ejecutables que traducen cada resultado estadístico en un componente
de agente: estado, regla de decisión, estimador con cota de error, protocolo de
evaluación.

| Carpeta | Tema |
|---|---|
| `agente_sesion_1/` | Agente de diagnóstico local (LangGraph + OpenRouter) |
| `agente_sesion_2/` | Agente con memoria y evaluación en LangSmith |
| `agente_sesion_3/` | Laboratorio de estimación óptima (F3) |
| `capitulo_04_tests_ic/` | Tests de hipótesis e intervalos de confianza |
| `capitulo_05_bootstrap/` | Bootstrap, en dos variantes de implementación |
| `capitulo_06_semiparametrica/` | Estimadores semiparamétricos / doubly robust |
| `capitulo_07_wald/` | Decisión de Wald |
| `capitulo_08_mdp/` | Planificación determinista |
| `capitulo_09_isomorfismo/` | Isomorfismo `Dec → MDP` (paquete con `src/`, `tests/`, `scripts/`) |
| `capitulo_10_ope/` | Off-policy evaluation |
| `capitulo_11_inferencia_vp/` | Inferencia sobre `V^π` |
| `capitulo_12_sintesis/` | Síntesis |

Cada carpeta trae su propio `README.md` y su archivo de dependencias
(`environment.yml` o `requirements.txt`); algunas se levantan como app de
Chainlit:

```bash
cd agents_curso/capitulo_10_ope
pip install -r requirements.txt        # o: conda env create -f environment.yml
cp .env.example .env                   # completa tus claves
chainlit run app.py
```

> **Claves:** los `.env` reales **no se versionan** (ver `.gitignore`). Usa los
> `.env.example` como plantilla. Las claves de OpenRouter se obtienen gratis en
> openrouter.ai/keys.

---

## 3. `diapositivas/` — sílabo y presentaciones

| Archivo | Qué es |
|---|---|
| `silabo_estadistica_integrado_agentes.md` | Sílabo integrado: competencias estadísticas ↔ competencias de agente, semana a semana |
| `Silabo_Ejemplos_Agentes.md` | Ejemplos de agentes usados en clase |
| `el_punte_paso_paso.md` | Recorrido del curso paso a paso |
| `langgraph_ontology.ttl` | Ontología del grafo de agentes en Turtle |
| `presentaciones_typst/` | 17 archivos Typst: temas 01–13 (el 03 con dos versiones), tema de clase y prototipo, más sus PDF y versiones *handout* |

```bash
cd diapositivas/presentaciones_typst
typst compile 04_mdp.typ
```

---

## Convenciones de trabajo

- No inventar referencias, DOI, años, páginas ni resultados. Ante la duda, el
  manuscrito afirma **menos**, no más.
- Cada hueco que no se cierra se marca con `#pendiente[…]` en Typst, nunca se
  rellena con prosa plausible.
- La trazabilidad derivación ↔ implementación se mantiene explícita: cada
  resultado estadístico debe corresponder a un componente o garantía del agente.

## Licencia

Código bajo licencia MIT; texto, figuras y diapositivas bajo
CC BY-NC-SA 4.0. Detalle y textos legales en [`LICENSE`](LICENSE).
