# PLAN MCP v2.1 — del libro al uso real por agentes

**Estado:** 2026-11-03 · decisiones del autor RESUELTAS (§9.5).
**Previos:** evaluación de viabilidad (chat), Plan v1, Plan v2 con feedback técnico
incorporado (stdout/stderr, path jail, outputs ≤10 filas, golden con tolerancia
1e-8, readOnlyHint, `uv run`, suite de protocolo, licencia OBD cerrada con
`LICENSE-zr-obp.txt` + `NOTICE.txt` en `monografia_M/labs/data_obd/`).
**Marcas:** [V] verificado en el repo · [S] supuesto declarado · [R] recomendación.

## 1. Resumen ejecutivo

Se construye: (a) **dos agentes LangGraph instrumentados** (`capitulo_09` → v1,
`capitulo_10_ope` → v2) que emiten episodios JSONL con propensiones **por
diseño** (ε-greedy por caso, por defecto 0.3; decisión en código, [V]);
(b) la librería **`agente-stats`** (OPE, comparación de versiones, ficha de
justificación automática; reusa código ya probado del repo); (c) **un servidor
MCP único** (`agente-stats`, 4 herramientas read-only, stdio, `uv run`) con
fichas como markdown primario y Resources como vía formal. Caso de uso:
comparar la versión nueva de un agente con los logs de la anterior y decidir
con un intervalo honesto si conviene desplegarla. Piloto ~semana 9 del curso
[S, queda pendiente la semana exacta por decisión del autor].

## 2. Decisiones de alcance (firmes)

- **Un servidor, 4 herramientas.** `ope_evaluate`, `compare_versions`,
  `justification_ficha`, `inspect_episodes`. Fase 5 puede añadir
  `monitor_sequence` (e-procesos) si el feedback la pide.
- **Sin herramienta en caps. 2,3,4,5,10,12**: demos/recursos de lectura.
- **Librería primero, capa MCP delgada sin estado**, sin matemática en el servidor.
- **Rechazos = error de herramienta con mensaje accionable**, nunca avisos en
  el texto de salida.
- **Golden con semilla fija + tolerancia relativa 1e-8 y float64 forzado**;
  bit-exact solo intra-plataforma.
- **Outputs = resumen + ≤10 filas + ruta**; descripciones ≤50 palabras;
  `readOnlyHint: true`; logs a stderr.

## 3. Los 12 agentes existentes: destino definitivo

| Agente | Cap. del libro | Destino |
|---|---|---|
| `capitulo_09_isomorfismo` | 5 | **Adecuar → agente v1** (decisión ya es código: `bayes_rule`) |
| `capitulo_10_ope` | 7 | **Adecuar → agente v2** (pipeline decide en código; ya codifica ε-greedy) |
| `capitulo_07_wald` | 2 | Conservar como demo |
| `capitulo_08_mdp` | 3 | Conservar como demo |
| `capitulo_04_tests_ic` | 4 | Conservar como demo |
| `capitulo_05_bootstrap` | 4 | Conservar como demo |
| `capitulo_06_semiparametrica` | 4/7 | Conservar como demo |
| `capitulo_11_inferencia_vp` | 8 | Conservar como demo |
| `capitulo_12_sintesis` | 9/12 | Conservar como demo |
| `agente_sesion_1/2/3` | (syllabus) | Conservar como demo |

**Instrumentación (pieza compartida `instrumentation/`):**
política ε-greedy por diseño con probabilidades calculadas y registradas por
código (nunca estimadas ex post); EpisodeLogger JSONL (unidad explícita,
semilla, `policy_version`, `propensity_recorded: true`); **ε por caso** —
por defecto 0.3 — con justificación obligatoria (ver §9.5-2): el logger
escribe en la cabecera del episodio $C_{max}=1+K(1-\varepsilon)/\varepsilon$
y la tasa de exploración ε, y la ficha la muestra automáticamente, así el
lector ve el compromiso declarado, no dogma.

## 4. Arquitectura

```
agente-stats/
  src/agente_stats/core/        # OPE, intervals, certificates, schemas (sin MCP)
  src/agente_stats_mcp/         # capa: path jail, llama core, resume, errores accionables
tests/  unit/ golden(tol 1e-8)/ adversarial/ coverage/ protocol_schema/
examples/ (JSONL: OBD [Apache-2.0 + NOTICE], langsmith-export si aplica, simulado)
fichas/    (markdown: vía primaria; Resources como canal formal)
docs/      (setup por cliente + smoke test 5 min)
```

Invariantes: stdout solo protocolo (test que lo impone); path jail
(`examples/` + workspace del alumno); sin estado de análisis entre llamadas;
`uv run agente-stats-mcp` como único comando de arranque.

## 5. Fases (curso de 12 semanas [S])

| Fase | Entregable | Aceptación medible | h |
|---|---|---|---|
| 0 · Contrato (s3) | `schemas.py` + certificado + 3 JSONL ejemplo | validan; campo ficha en salida | 16 |
| 1 · Instrumentación (s4–5) | agentes v1/v2 + `instrumentation/` | tests de cada agente verdes; JSONL dorado, propensiones suman 1, $C_{max}$ registrada | 30 |
| 2 · Núcleo (s5–7) | `core`: OPE, comparación, fichas | 4 suites verdes; OBD reproduce números (tol 1e-8) | 40 |
| 3 · Capa MCP (s8) | servidor + 4 tools + fichas md | protocolo/esquema verde; adversarial ≥95% rechazos correctos, 0 falsos aceptados; smoke 5 min | 24 |
| 4 · Piloto (s9 [S]) | sesión 3 h + issues | rúbrica: ≥80% de fichas con checklist completo como objetivo, no como barrera (ver §9.5-3) | — |
| 5 · Endurecido (s10–12) | `monitor_sequence` si el feedback la pide; `v1.0-mcp` | criterios medidos + acta | 24–40 |

## 6. Riesgos priorizados (v2.1)

| Riesgo | Prob | Imp | Mitigación |
|---|---|---|---|
| Entorno de alumnos | Alta | Alto | `uv run` único + humo 5 min + uv.lock + docs Windows |
| Propensiones ausentes | Alta | Alto | instrumentación por diseño (ya la vía confirmada) |
| Mal uso inferencial | Media | Alto | ficha obligatoria; rechazo accionable; lab 60.7% como material |
| stdout/stdio roto | Media | Alto | invariante + test + smoke |
| Privacidad logs reales | Media | Alto | regla de anonimización escrita pre-piloto; ejemplos solo OBD/sintéticos hasta Q3 |
| Cambios API clientes | Media | Medio | pin de cliente; matriz de clientes; CI con SDK oficial |
| Overhead de tools/contexto | Cierta | Bajo | ≤50 palabras, salidas resumidas, readOnly, 4 tools |
| Sostenibilidad | Media | Medio | alcance mínimo, semver, mantenedor según §9.5-4 |

## 7. Verificaciones [V]

47/47 tests del paquete isomorfismo · 14/14 labs del libro reproducen bit a
bit · cobertura peeking 0.6072±0.0077 · OBD 10 000 filas, propensión 0.0125
constante en todas · `obp` 0.5.7 incompatible con Python 3.12 (fuera del MCP)
· licencia zr-obp Apache-2.0 (LICENSE+NOTICE incluidos) · decisión en código
en ambos agentes instrumentados. Pendiente sin impacto: límite exacto de
herramientas por cliente (diseño ya conservador), LangSmith y propensiones.

## 8. Bloqueantes restantes

1. **Q3 (PII en logs reales y autorización)** — bloquea solo el uso de logs
   de alumnos en el repo público; el piloto puede ir con OBD + agentes
   instrumentados mientras tanto.
2. **Semana exacta del piloto** — pendiente por decisión del autor (§9.5-5);
   el plan no se detiene: hitos se asientan al cerrar Fase 3.

## 9. Decisiones del autor — RESUELTAS 2026-11-03

9.5-1 **Sílabo.** El plan viejo (descripción de "familia exponencial y
bayesiana conjugada" como curso aparte) queda **superseded**: el documento de
referencia es el libro de 275 pp (la familia exponencial vive en cap. 4, la
conjugación Beta–Bernoulli en cap. 2 y sus labs). El sílabo se adecua al
nuevo plan, no al revés.

9.5-2 **ε.** Sin justificación teórico-empírico-metodológica, nada es dogma:
ε se elige **por caso** (defecto 0.3) y **se informa al lector** — el logger
registra $C_{max}$ y la tasa de exploración por episodio, y la ficha los
muestra automáticamente. Alternativa documentada: ε alto solo en ventanas de
evaluación declaradas, con cambio de régimen en la ficha.

9.5-3 **Umbral del piloto.** Rúbrica inteligente, no barrera: objetivo ≥80%
de fichas con checklist completo; si se queda corto, el piloto itera el
material y se repite (convalecencia metodológica del curso), no "falla". Se
reporta la distribución de completitud, no solo el porcentaje.

9.5-4 **Gobernanza del feedback.** El estándar de la casa: código MIT, texto
CC BY-NC-SA 4.0; mantenedor = el autor del curso; issues triados semanalmente
durante el curso con plantilla estándar.

9.5-5 **Calendario y carga.** Avanzar sin fecha exacta de piloto; las horas
siguen como supuesto declarado (5–6 h efectivas/día, ~120–150 h total) y se
revisan al cierre de Fase 3.
