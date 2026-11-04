# Piloto MCP — evaluar una nueva versión del agente con los logs de la anterior

**Sesión:** ~3 horas · audiencia: alumnos del doctorado con los laboratorios LangGraph ya construidos (agents_curso/)
**Requisito:** una máquina con `uv` instalado y un cliente MCP (Claude Code sugerido)
**Dato:** `agente-stats/examples/` (episodios instrumentados golden, nada personal)

## Lo que vas a hacer hoy

Das de alta el servidor en tu cliente, calculas el valor de la política nueva (ε-greedy 0.3
alrededor del argmax del MDP tabular) sobre los logs de la versión anterior (con la cual fue
recogida), la comparación de la diferencia entre ambos con un intervalo pareado, y llenas con
la herramienta misma al final la ficha de justificación que vive en el capítulo 6 del libro.

## 0. Preparación (5 min, comando único)

```bash
cd agente-stats
./setup.sh
```

Esto (a) verifica el entorno (b) hace init/tools-list con el servidor (c) corre la suite
de protocolo — sigue con tus cliente si todo está verde.

## 1. Flujo en tu cliente MCP

Añade el servidor (`docs/sesiones.md`) y aprueba una vez. Éstas aparecerán:

- `inspect_episodes(path)` — resumen acotado del archivo de episodios (diseño).
- `ope_evaluate(path, estimator, target)` — valor de tu política sobre los logs.
- `compare_versions(path, target_new, target_old)` — la diferencia con IC pareado.
- `justification_ficha(path, estimand, estimator, target)` — tu ficha.

## 2. El experimento, por pasos

### Paso A — Inspección

```
inspect_episodes(path="agent_v2_episodes.jsonl")
```
Esperado: 24 episodios, horizonte [10], versión `opeagent-v2@1.0.0`, modo `recorded`.

### Paso B — Valor de la política nueva (dos estimadores)

```
ope_evaluate(path, estimator="IS", target={"type": "eps_greedy",
  "q_table": [[-0.5,-1.0],[0.0,-0.5],[0.5,0.0],[1.0,0.5],[1.5,1.0]], "epsilon": 0.3})
ope_evaluate(path, estimator="DR", target=mismo target)
```

Números del archivo (verde-convergentes internamente por la semilla):
- **Valor verdadero** (analítico sobre estos s0): **0.8277**
- **IS:** J ≈ **0.784** (se ≈ 0.41)
- **DR:** J ≈ **0.872** (se ≈ 0.38)

Ambas dentro de un SE de la verdad — y eso es lo que debes observar. Lección: DR tiende es arriba
(volátil localmente por su derivaciónDR's action of what similar to hoy), y el ESS diagnóstico
te dice cuánta información útil hubo, no la cobertura (no es el índice T).

### Paso C — Cambiario (comparación de versiones)

```
compare_versions(path, estimator="DR",
  target_new={"type": "eps_greedy", "q_table": [[-0.5,-1.0],[0.0,-0.5],[0.5,0.0],[1.0,0.5],[1.5,1.0]], "epsilon": 0.3},
  target_old={"type": "explicit", "policy": {
    "(0,0)": 0.5, "(0,1)": 0.5, "(1,0)": 0.5, "(1,1)": 0.5,
    "(2,0)": 0.5, "(2,1)": 0.5, "(3,0)": 0.5, "(3,1)": 0.5, "(4,0)": 0.5, "(4,1)": 0.5}})
```

**Resultado:** Δ ≈ **−3.07** (se ≈ 1.19), CI95 = [−5.41, −0.73].

La ε-greedy del argmax del Q pseudo-óptimo rinde peor que la uniforme simple aquí; no por una
trampa del estimador, sino porque el entorno del laboratorio favorece solución balanceada en este
régimen. Tu ficha documenta: **cuidado con el comparativo a posteriori** (es el capítulo 6).

### Paso D — Tu ficha

```
justification_ficha(path,
  estimand="Valor de la política ε-greedy (0.3) sobre el tabular 5×2 logueado por ε-greedy por diseño",
  estimator="DR",
  target={"type": "eps_greedy", "q_table": [[-0.5,-1.0],[0.0,-0.5],[0.5,0.0],[1.0,0.5],[1.5,1.0]], "epsilon": 0.3},
  declared_conditions={"identificacion": "design",
                       "overlap": "design",
                       "propensions_recorded": "design"})
```

Te dirá: nivel = **region**, weakest = **open**. No una garantía bonita con asterisco: la
herramienta te dice EXACTAMENTE qué condición frenó la respuesta más fuerte.

## 3. Qué NO está permitido (y va a fallar)

- Pasa `estimand=""` en la ficha: rechazo exacto con el mandato (`estimand ausente`).
- Pasa una ruta fuera de la jail (`/etc/passwd`, `../..`): rechazada y te dice la razón concreta.
- Pide OPE a un archivo con `propensity_mode='estimated'`: te dice honestamente que debe
  degradarse a región/diagnóstico ([Fase 6 del librobefitirtd no funció analizar).
- Tratar el ESS como certificado de cobertura (se marca diagnóstico).

## 4. Feedback (issue pública)

Cierra la sesión respondiendo la issue de `docs/ISSUE_TEMPLATE_FEEDBACK.md` (ver versión
específica: 9 preguntas, una línea por respuesta; dos datos útil: sistema y cliente,
y los dos valores redondeados de IS/Δ).

## 5. Licencia/datos

- Subsample OBD adaptado (random): Apache 2.0 del `zr-obp` (NOTICE allí).
- Datos golden (v1/v2): determinísticos por semilla.
- Nada con datos personales entra al repo público en este piloto.
