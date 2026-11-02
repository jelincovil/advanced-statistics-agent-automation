# MAPA ESTRUCTURA — Fase 2A

**Manuscrito:** `monografia_typst_v1` · **Estado de partida:** 13 capítulos + 8 apéndices, **283 pp.**
**Esqueleto objetivo:** 12 capítulos en 4 partes + apéndices.
**Fecha:** 2026-09-22 · **Commit de partida:** `cd49b7c`

Este documento **no edita nada**. Es el mapa de movimientos para que lo apruebes.

---

## 0. Cómo leerlo y con qué criterio

**Códigos de destino**

| Código | Significado |
|---|---|
| `MUEVE →` | se conserva íntegra, tal cual |
| `FUSIONA →` | se mezcla con otra sección (se indica con cuál) |
| `COMPRIME →` | sobrevive reducida (la reducción es Fase 3; acá solo se marca) |
| `APÉNDICE →` | sale del cuerpo |
| `ELIMINA` | con justificación de una línea |
| `SIN DESTINO` | no encaja; requiere tu decisión |

**Criterio de compresión, aplicado con datos.** Corrí un análisis de etiquetas
(`@clave`, `<clave>`) sobre los caps. 1–6: **320 resultados etiquetados, de los
cuales solo 41 se invocan alguna vez desde los caps. 7–13 o los apéndices.**
Los 41 supervivientes son:

```
suficiencia / Basu / Neyman-Fisher / Lehmann-Scheffé (cap. 2)
Rao-Blackwell / Lehmann-Scheffé / Cramér-Rao (cap. 3)
Neyman-Pearson / inversión test-IC / Benjamini-Hochberg (cap. 4)
CLT / delta method / bootstrap / cobertura (cap. 5)
cota semiparamétrica / IF eficiente de Kallus-Uehara (cap. 6)
familias exponenciales (log-partición, suficiencia natural, conjugación) · pérdida-riesgo · sesgo-varianza (cap. 1)
5 ejemplos del SSCH y la tabla de recompensas
```

Los otros **279** nunca se invocan por nombre → apéndice o eliminación, según tu
instrucción. Los cuatro estándar (Rao-Blackwell, Lehmann-Scheffé, Cramér-Rao,
Neyman-Pearson) **se citan, no se reproducen**, como ordenaste; su enunciado
sobrevive porque se invoca.

**Páginas.** Las de capítulo son **exactas** (Índice General del PDF). Las de
sección son **estimaciones** por proporción de líneas (≈1 pp. cada 63 líneas).
Marcadas con `~`.

**Hallazgo estructural que condiciona el mapa.** En los caps. 1–10, «Contenido
Teórico» y «Aplicación a Agentes» son **envoltorios de 3 líneas**: el contenido
real está en **nivel 3**. Por eso el mapa baja a nivel 3 en los caps. 0–6, que es
donde se decide, y se queda en nivel 2 en los caps. 7–13.

---

## 1. Esqueleto objetivo ↔ origen

| Nuevo | Título | Origen principal | pp. origen |
|---|---|---|---|
| **Intr.** | Introducción | cap. 0 §0.18, §0.23 + prefacio | ~4 |
| **1** | Dos tradiciones y el problema de la transferencia de garantías | cap. 0 §0.19 + **nuevo** (2C-i) | ~3 | 
| **I · 2** | Teoría de decisión de Wald | cap. 7 | 9 |
| **I · 3** | Procesos de decisión de Markov | cap. 8 | 11 |
| **I · 4** | Herramientas de transferencia | caps. 1–6 (comprimidos) | 20+12+12+10+12+16 = **82** |
| **II · 5** | La incrustación fiel Dec → MDP: enunciado, demostración y alcance | cap. 9 §§1–8 + cap. 13 §13.2 | ~11 |
| **II · 6** | Lo que no se transfiere | cap. 9 §9.1.9 + §9.2 + cap. 13 §13.3 | ~5 |
| **III · 7** | Evaluación off-policy | cap. 10 | 10 |
| **III · 8** | Intervalos de confianza para funciones de valor | cap. 11 | 11 |
| **III · 9** | Un cálculo de verificación de garantías | **consolidación** (trazabilidad + aplicaciones, caps. 1–12) | ~14 |
| **IV · 10** | Casos de estudio | SSCH consolidado + laboratorio | ~10 |
| **IV · 11** | De la garantía al despliegue | **nuevo** (2C-ii) + apéndice H | ~6 |
| **IV · 12** | Problemas abiertos | cap. 13 §§13.4–13.5 + cap. 12 fronteras | ~6 |

**Presupuesto de páginas:** el cuerpo pasa de ~165 pp. (caps. 0–13) a un
estimado de **~110 pp.**; el resto se va a apéndices o se elimina. Las Partes
I–IV quedan razonablemente equilibradas.

---

## 2. CAP. 0 actual — «Introducción» (pp. 1–9)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C00:27` | La Tesis Central: Una Correspondencia Estructural | 1.5 | **FUSIONA → Intr. §"La tesis"** (con `tab:correspondencia-central`, que es el ancla de la fila Θ) |
| `C00:111` § | Contexto Histórico: Dos Tradiciones, Una Estructura | 1.5 | **MUEVE → cap. 1 §1.1** |
| `C00:121` § | · La síntesis de Wald (1950) | 0.4 | MUEVE → cap. 1 §1.1 |
| `C00:143` § | · La programación dinámica de Bellman (1957) | 0.4 | MUEVE → cap. 1 §1.1 |
| `C00:164` § | · La divergencia y la reconvergencia | 0.5 | MUEVE → cap. 1 §1.1 |
| `C00:189` § | Arquitectura del Libro: Tres Actos | 0.2 | **ELIMINA** — describe la estructura de tres actos, que deja de existir (reescritura de Fase 3) |
| `C00:198/220/238` § | · Parte I / II / III | 0.9 | **ELIMINA** — mismo motivo |
| `C00:255` § | · Mapa de dependencias | 0.6 | **COMPRIME → Intr.** (se recalcula sobre 12 capítulos en Fase 3) |
| `C00:288` § | Convenciones de Notación | 0.2 | **APÉNDICE → B** (se fusiona con el glosario; el detalle ya vive en `notacion.typ`) |
| `C00:382` § | Guía de Lectura | 0.7 | **COMPRIME → Intr.** (las rutas por perfil sobreviven; las de tres actos no) |
| `C00:440` § | Una Nota sobre la Filosofía del Libro | 0.6 | **MUEVE → cap. 1 §1.2** |
| `C00.typ` entero (17 290 líneas) | — | — | **ELIMINA** — el archivo deja de existir como capítulo |

---

## 3. CAPS. 1–6 — compresión a «Herramientas de transferencia» (82 pp. → ~30 pp.)

### 3.1 · Cap. 1 actual (pp. 10–29, 20 pp.)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C01:68` § | El Problema de Inferencia Estadística: Estructura Formal | 2.3 | **COMPRIME → cap. 4 §4.0** (el problema de decisión estadística sobrevive; el aparato formal se cita) |
| `C01:213` § | Estadísticos y su Clasificación | 0.8 | **ELIMINA** — ni se invoca ni se necesita para enunciar nada posterior |
| `C01:265` § | Criterios de Optimalidad | 1.5 | **COMPRIME → cap. 4 §4.0** (conserva `def:ch1-perdida-riesgo`, `def:ch1-varianza-ecm`, que sí se invocan) |
| `C01:359` § | Familias Exponenciales: Definición y Propiedades | 1.8 | **COMPRIME → cap. 4 §4.1** (sobreviven `thm:ch1-logparticion`, `thm:ch1-suficiencia-natural`) |
| `C01:471` § | Estadísticos Naturales y Suficiencia | 0.4 | FUSIONA con la anterior |
| `C01:495` § | Priors Conjugados y Actualización Bayesiana | 1.6 | **COMPRIME → cap. 4 §4.1** (sobrevive `def:ch1-conjugada`) |
| `C01:595` § | Otras familias paramétricas con estructura | 1.3 | **ELIMINA** — ninguna se invoca; el catálogo no aporta a la transferencia |
| `C01:678` § | Conexión con la Teoría de Decisión de Wald | 1.0 | **FUSIONA → cap. 2 §"de Wald a Wald"** (es el puente natural al cap. 2) |
| `C01:741-942` § | Aplicación a Agentes (3 subsecciones) | 3.2 | **MUEVE → cap. 9** (consolidación de aplicaciones, caps. 1–6) |
| `C01:967` § | Hilo longitudinal: SSCH | 1.3 | **MUEVE → cap. 10** (caso de estudio consolidado) |
| `C01:1050` § | Trazabilidad: Del Teorema al Componente | 0.5 | **MUEVE → cap. 9** |
| `C01:1082` § | Conexión con el `@ch:reduccion` | 0.5 | **ELIMINA** — transición entre capítulos que dejan de ser adyacentes |
| `C01:1113` § | Ejercicios (73 líneas) | 1.2 | **MUEVE** con el capítulo destino — ver §10.1 (decisión pendiente) |
| `C01:1186` § | Lecturas Propuestas | 0.4 | **APÉNDICE → B** o elimina — ver §10.1 |

### 3.2 · Cap. 2 actual — Suficiencia (pp. 30–41, 12 pp.)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C02:19` § | Contexto Histórico y Motivación | 0.6 | **ELIMINA** — Fisher 1922 ya se narra en cap. 1 |
| `C02:61` § | El Principio de Suficiencia | 1.3 | **MUEVE → cap. 4 §4.1** (es el bloque superviviente) |
| `C02:142` § | Suficiencia Minimal | 0.8 | **COMPRIME → cap. 4 §4.1** |
| `C02:195` § | Completitud | 1.4 | **COMPRIME → cap. 4 §4.1** (solo lo que sostiene Lehmann-Scheffé) |
| `C02:281` § | Ancillaridad y el Teorema de Basu | 1.0 | **MUEVE → cap. 4 §4.1** (`thm:ch2-basu` se invoca ×3) |
| `C02:346` § | Equivarianza | 1.3 | **ELIMINA** — nunca se invoca; no interviene en la transferencia |
| `C02:431` § | Conexión con la Correspondencia Estructural | 0.4 | **MUEVE → cap. 9** |
| `C02:460-546` § | Aplicación conceptual (4 subsecciones) | 1.3 | **MUEVE → cap. 9** |
| `C02:565` § | Hilo longitudinal: SSCH | 0.5 | **MUEVE → cap. 10** |
| `C02:597` § | Trazabilidad | 0.5 | **MUEVE → cap. 9** |
| `C02:627` § | Conexión con el `@ch:estimacion` | 0.5 | **ELIMINA** — transición obsoleta |

### 3.3 · Cap. 3 actual — Estimación puntual (pp. 42–53, 12 pp.)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C03:20` § | Contexto Histórico y Motivación | 0.8 | **ELIMINA** |
| `C03:74` § | Criterios de Optimalidad en Estimación Puntual | 0.2 | FUSIONA con `C01:265` → cap. 4 §4.0 |
| `C03:86` § | El Teorema de Rao-Blackwell | 0.8 | **COMPRIME → cap. 4 §4.1: enunciado, cita a Casella-Berger** ⚠️ elimina demostración (pre-autorizado) |
| `C03:137` § | Lehmann-Scheffé y UMVUE | 0.8 | **COMPRIME → cap. 4 §4.1** ⚠️ idem |
| `C03:186` § | La Cota Inferior de Cramér-Rao | 1.3 | **COMPRIME → cap. 4 §4.1** ⚠️ idem |
| `C03:270` § | El Estimador de Máxima Verosimilitud | 1.0 | **COMPRIME → cap. 4 §4.1** (es el estimador que usa el SSCH) |
| `C03:334` § | Conexión con la Correspondencia Estructural | 0.4 | MUEVE → cap. 9 |
| `C03:361-430` § | Aplicación conceptual + SSCH | 1.3 | MUEVE → cap. 9 / cap. 10 |
| `C03:458` § | **Métodos Computacionales Bayesianos: MCMC e Inferencia Variacional** | 1.5 | **ELIMINA** — 93 líneas nunca invocadas; MCMC/VI no participan de ninguna garantía del libro ⚠️ ver §10.2 |
| `C03:551` § | Trazabilidad | 0.4 | MUEVE → cap. 9 |
| `C03:574` § | Conexión con el `@ch:tests` | 0.6 | **ELIMINA** — transición obsoleta |
| `C03:669` § | Más Allá de la Conjugación: MCMC e Inferencia Variacional | 0.9 | **ELIMINA** — duplica `C03:458` y tampoco se invoca |

### 3.4 · Cap. 4 actual — Tests e IC (pp. 54–63, 10 pp.)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C04:45` § | Contexto Histórico y Motivación | 0.7 | **ELIMINA** |
| `C04:98` § | Formulación del Problema de Tests | 1.7 | **COMPRIME → cap. 4 §4.2** |
| `C04:216` § | Tests Uniformemente Más Potentes | 0.5 | **COMPRIME → cap. 4 §4.2** (`thm:ch4-neyman-pearson` se invoca ×3) ⚠️ elimina demostración (pre-autorizado) |
| `C04:253` § | Tests UMPU | 0.3 | **ELIMINA** — no se invoca |
| `C04:276` § | Dualidad Test-Intervalo de Confianza | 0.4 | **MUEVE → cap. 4 §4.2** (`thm:ch4-inversion` se invoca ×2) |
| `C04:306` § | Múltiples Comparaciones | 1.3 | **COMPRIME → cap. 4 §4.2** (`thm:ch4-bh` se invoca ×3) |
| `C04:399` § | Conexión con Teoría de Decisión de Wald | 0.2 | **MUEVE → cap. 2** |
| `C04:415` § | Tests de Hipótesis Bayesianos | 1.0 | **ELIMINA** — nunca se invoca; no participa de la transferencia |
| `C04:485-516` § | Aplicación conceptual (A/B testing de políticas) | 0.8 | **MUEVE → cap. 9** |
| `C04:552` § | Hilo longitudinal: SSCH | 0.5 | **MUEVE → cap. 10** |
| `C04:584` § | Trazabilidad | 0.4 | **MUEVE → cap. 9** |
| `C04:608` § | Conexión con el `@ch:asintotica` | 0.7 | **ELIMINA** — transición obsoleta |

### 3.5 · Cap. 5 actual — Asintótica (pp. 64–75, 12 pp.)

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C05:21` § | Contexto Histórico y Motivación | 0.7 | **ELIMINA** |
| `C05:71` § | El Teorema Central del Límite | 1.1 | **COMPRIME → cap. 4 §4.3** |
| `C05:141` § | El Delta Method | 1.2 | **MUEVE → cap. 4 §4.3** (`thm:ch5-delta` se invoca ×3) |
| `C05:214` § | Procesos Empíricos | 1.3 | **COMPRIME → cap. 4 §4.3** (solo lo que sostiene la asintótica bajo dependencia) |
| `C05:298` § | El Bootstrap | 1.0 | **MUEVE → cap. 4 §4.3** |
| `C05:361` § | Asintótica para Funciones de Valor | 0.9 | **MUEVE → cap. 4 §4.3** (es el puente al cap. 8) |
| `C05:419` § | Condiciones de Regularidad para Dependencia Temporal | 1.8 | **FUSIONA → cap. 6 §"condiciones"** con el apéndice G (el material de mixing pertenece al capítulo de fronteras) |
| `C05:534-561` § | Aplicación conceptual (3 subsecciones) | 0.7 | **MUEVE → cap. 9** |
| `C05:577` § | Hilo longitudinal: SSCH | 0.6 | **MUEVE → cap. 10** |
| `C05:613` § | Trazabilidad | 0.4 | **MUEVE → cap. 9** |
| `C05:637` § | Conexión con el `@ch:semiparametrica` | 0.6 | **ELIMINA** — transición obsoleta |

### 3.6 · Cap. 6 actual — Semiparamétrica e IF (pp. 76–91, 16 pp.)

**Es el capítulo más invocado del libro** (`ch:semiparametrica` ×30). No se comprime: se **mueve** con recortes puntuales.

| Sección | Título | ~pp. | Destino |
|---|---|---|---|
| `C06:47` § | Contexto Histórico y Motivación | 0.5 | **MUEVE → cap. 4 §4.4** |
| `C06:79` § | Modelos Semiparamétricos | 1.7 | **MUEVE → cap. 4 §4.4** |
| `C06:184` § | Scores y Espacios Tangentes en el Par $(theta, g)$ | 1.6 | **COMPRIME → cap. 4 §4.4** (sobrevive el espacio tangente; el detalle de scores va a apéndice A) |
| `C06:285` § | Funciones de Influencia | 0.8 | **MUEVE → cap. 4 §4.4** |
| `C06:333` § | Eficiencia Semiparamétrica | 0.9 | **MUEVE → cap. 4 §4.4** (`thm:ch6-cota` se invoca) |
| `C06:392` § | Ortogonalidad de Neyman | 0.5 | **MUEVE → cap. 4 §4.4** |
| `C06:425` § | Estimadores Doubly Robust | 0.7 | **MUEVE → cap. 4 §4.4** |
| `C06:470` § | IF Eficiente para $Value^policy$ | 1.4 | **MUEVE → cap. 4 §4.4** (`thm:ch6-kallus` se invoca ×2) |
| `C06:559` § | Debiased Machine Learning | 0.5 | **MUEVE → cap. 4 §4.4** |
| `C06:592` § | Condiciones para Validez de Cross-Fitting | 1.0 | **MUEVE → cap. 4 §4.4** |
| `C06:655` § | Inferencia Causal: DAGs y Criterio Backdoor | 1.9 | **COMPRIME → cap. 4 §4.4** (sobrevive el criterio backdoor: lo necesita el cap. 7 para confounding) |
| `C06:777-803` § | Aplicación conceptual (3 subsecciones) | 0.7 | **MUEVE → cap. 9** |
| `C06:819` § | Trazabilidad | 0.4 | **MUEVE → cap. 9** |
| `C06:844` § | Conexión con el `@ch:wald` | 0.6 | **ELIMINA** — transición obsoleta |
| `C06:887` § | Hilo longitudinal: SSCH | 1.1 | **MUEVE → cap. 10** |
| `C06:962` § | Causalidad y Sensibilidad | 0.2 | **MUEVE → cap. 4 §4.4** |
| `C06:999` § | Donde Estamos | 0.3 | **ELIMINA** — cierre de capítulo que deja de existir |

---

## 4. CAPS. 7–13 — destino por capítulo

| Cap. actual | pp. | Destino | Notas |
|---|---|---|---|
| **7** Wald | 92–100 (9) | **MUEVE → cap. 2** | Su §"El Isomorfismo Wald-MDP" (`sec:ch7-isomorfismo`, ~60 líneas) → **COMPRIME → cap. 5**: es un anticipo que el cap. 5 vuelve redundante. Su §"Ejercicios" sigue al capítulo. |
| **8** MDP | 101–111 (11) | **MUEVE → cap. 3** | Su §"Conexión con `@ch:isomorfismo`" → **COMPRIME → cap. 5**. §"El Caso $k=1$: Bandidos" (~60 líneas) → **MUEVE** con el capítulo. |
| **9** Incrustación | 112–123 (12) | **PARTE EN DOS** | §§1–8 → **cap. 5**; §9.1.9 «Cuándo NO se transfieren» + §9.2 contraejemplos + §9.3 → **cap. 6**. Ver §5. |
| **10** OPE | 124–133 (10) | **MUEVE → cap. 7** | §10.2 «Distributional Shift» (~50 líneas) se queda. |
| **11** Inferencia para $V^\pi$ | 134–144 (11) | **MUEVE → cap. 8** | ⚠️ Su §11.7 «Deep RL: Policy Gradient y REINFORCE» (**136 líneas ≈ 2.2 pp.**) → **COMPRIME**: no se invoca después y no aporta a la tesis. |
| **12** Síntesis | 145–155 (11) | **SE DISUELVE** | §12.1 fronteras (confounding, POMDP, LLM) → **cap. 12**; «Conclusiones del Curso» y «Logros Principales» → **cap. 12** (COMPRIME); `tab:ch12-trazabilidad` y §12.3 «Mapa Completo» → **cap. 9**; ejemplos SSCH → **cap. 10**. |
| **13** Conclusiones | 156–165 (10) | **SE DISUELVE** | §13.2 «El Mapa Completo de la Incrustación Fiel» (71 líneas) → **cap. 5**; §13.3 «Limitaciones» → **cap. 6**; §13.4 «Problemas Abiertos» + §13.5 «Direcciones Futuras» → **cap. 12**; §13.6 «Epílogo» (70 líneas) → **COMPRIME → cap. 12**; §13.1 «Los Resultados que Perduran» → **COMPRIME → Intr.** |

---

## 5. CAP. 9 — el desglose que decide la Parte II

| Bloque | Línea | ~pp. | Destino |
|---|---|---|---|
| §9.1 Contexto + «El Isomorfismo Fundamental» (enunciado + nota de extensión no demostrada) | `C09:75` | 3.0 | **MUEVE → cap. 5 §5.1–5.2** |
| §9.2 Contraejemplos (4) | `C09:210` | 1.8 | **MUEVE → cap. 6 §6.2** |
| §9.3 Extensión secuencial + §9.4 Transferencia (2 conjeturas) + §9.5 optimalidad (**1 teorema + 1 conjetura**) | `C09:314–410` | 1.5 | **MUEVE → cap. 5 §5.3** (lo demostrado) **+ cap. 6 §6.1** (las conjeturas) |
| §9.6 StateSchema (Nota) | `C09:412` | 0.4 | **MUEVE → cap. 5 §5.4** |
| §9.7 Síntesis (Nota) | `C09:433` | 0.3 | **ELIMINA** — es la «síntesis expositiva» que reemplaza el propio cap. 12 |
| §9.8 «Cuándo NO se transfieren garantías» | `C09:443` | 1.5 | **MUEVE → cap. 6 §6.1** (es la pieza central del capítulo nuevo) |
| SSCH del cap. 9 | `C09:589` | 1.0 | **MUEVE → cap. 10** |
| Aplicación conceptual + trazabilidad + ejercicios | `C09:560–776` | 3.0 | Aplicación → **cap. 9**; ejercicios → siguen |

---

## 6. APÉNDICES

| Ap. | Título | pp. | Destino |
|---|---|---|---|
| **A** | Demostraciones Completas | ~167–186 (20) | **COMPRIME.** Sobrevive lo que demuestra resultados que quedan en el cuerpo. Se **eliminan** las pruebas de Rao-Blackwell, Lehmann-Scheffé, Cramér-Rao y Neyman-Pearson por estar en Casella-Berger (pre-autorizado), y el resto de las 279 etiquetas no invocadas ⚠️ ver §10.3. Se **conserva íntegra** la prueba del `@thm:ch9-isomorfismo` y el esquema del secuencial. |
| **B** | Glosario de Notación | ~187–190 | **MUEVE**, **FUSIONA** con `C00:288` y con `notacion.typ` §0.17 (donde está el problema ↔/estatus) |
| **C** | LangGraph: Formalización Técnica | ~191–199 | **MUEVE** (apéndice). Es el soporte técnico del cap. 11 |
| **D** | Fundamentos Medido-Teóricos | ~200–210 | **MUEVE** (apéndice) |
| **E** | Tablas de Correspondencia | 211–219 | **COMPRIME**: lo de trazabilidad → **cap. 9**; el resto se queda |
| **F** | Laboratorio de Agentes | 220–245 (26) | **COMPRIME**: F.7 (Wald) → acompaña cap. 2; F.8 (MDP) → cap. 3; F.9 (incrustación) → cap. 5; F.10 → cap. 7; F.11 → cap. 8; F.1–F.6, F.12 → **cap. 4 / cap. 10** ⚠️ ver §10.4 |
| **G** | Condiciones de Regularidad y Mixing | 246–250 | **FUSIONA → cap. 6** (el grueso: son *las condiciones de transferencia*) con el detalle técnico restante en apéndice |
| **H** | Protocolo de Validación Empírica | 251–257 | **MUEVE → cap. 11** (es literalmente «de la garantía al despliegue») |
| — | **NUEVO**: reproducibilidad de la simulación de Shi et al. (2D) | — | **CREAR** |
| — | Bibliografía | 258–283 | **SIN DESTINO** (no se toca) |
| — | `prefacio.typ` | v–v | **MUEVE → front matter** (§0.7 «Sobre el alcance» se conserva tal cual) |
| — | `notacion.typ` | xviii–xxi | **MUEVE → front matter**; su §0.17 requiere arreglo ↔/estatus antes o durante 2B |

---

## 7. Incorporaciones nuevas (2C y 2D)

| # | Qué | Dónde | Estado |
|---|---|---|---|
| **2C-i** | Advertencia terminológica: «inferencia» estadística vs. *inference* de ingeniería de IA (homónimos) | cap. 1, §nuevo, ≤½ pp. | a redactar en Fase 3; **el esqueleto va en 2B** |
| **2C-ii** | Esqueleto del cap. 11: cuantización del modelo que aproxima $Q$, decodificación especulativa, latencia como restricción de diseño, y por qué el Problema 13.3 (OPE para políticas no evaluables) es el punto de choque | cap. 11 | solo títulos + párrafo de alcance |
| **2D** | Apéndice de reproducibilidad: Escenarios A/B/C, métricas ECP/AL/log(MSE), implementación pública de SAVE, $gamma = 0.5$, $L = floor((n T)^(3\/7))$, $n in {25,50,100}$, $T in {30,50,70}$ | apéndice nuevo | solo estructura y marcadores de tabla |

---

## 8. Balance

| | Capítulos | pp. cuerpo | Apéndices | pp. |
|---|---|---|---|---|
| **Antes** | 13 + Intro | ~165 | 8 | ~90 |
| **Después (est.)** | 12 + Intro | **~110** | 9 | ~120 |

---

## 9. Requiere tu decisión (paro y consulto)

### 9.1. Ejercicios y lecturas por capítulo — **no previstos en el esqueleto**
Hay **13 secciones «Ejercicios»** (~500 líneas ≈ 8 pp.) y **13 «Lecturas»** (~1.5 pp.).
Las de los caps. 1–6 pertenecen a capítulos que se comprimen a un solo capítulo
(4). Opciones: (a) siguen a su capítulo de destino (quedan 12 secciones, con los
caps. 1–6 fusionados en una); (b) se consolidan en un apéndice «Ejercicios»;
(c) se eliminan. **Por defecto propongo (a)**, pero es arquitectura, no
redacción: decime.

### 9.2. Eliminaciones que superan el umbral de autonomía
- `C03:458` + `C03:669` MCMC e Inferencia Variacional: **~2.4 pp. acumuladas**, nunca invocadas.
- `C06:655` DAGs y backdoor: **~1.9 pp.**, se **comprime** (no se elimina) porque el cap. 7 lo necesita.
- Apéndice A: la eliminación de las pruebas estándar es **pre-autorizada** por tu instrucción; el resto de las eliminaciones del apéndice A suman **>3 pp. seguidas** en algunos tramos → **lo marco, no lo ejecuto** sin tu visto bueno.
- Ninguna eliminación individual supera 3 pp., pero **el agregado de los caps. 1–6 sí** (82 → ~30 pp.). Eso es la compresión ordenada, no una eliminación sorpresiva; lo dejo señalado para que la aprobación sea informada.

### 9.3. `SIN DESTINO`
- `notacion.typ`: no hay capítulo de notación en el esqueleto. Propongo **front matter**, pero su §0.17 tiene el defecto ↔/estatus ya reportado.
- `C01:213` «Estadísticos y su Clasificación» y `C04:415` «Tests Bayesianos»: los propongo **ELIMINA**, pero son los dos casos donde mi criterio de «no invocado después» podría estar borrando algo pedagógicamente útil. Visto bueno explícito.
- `apendice_langgraph.typ`: se queda como apéndice, pero **nada lo invoca salvo el cap. 11 y el laboratorio**. Si el cap. 11 no lo cita, pierde razón de ser.

---

## 10. Notas de método

1. **Datos, no impresiones:** el criterio «sobrevive lo que se usa después» se
   aplicó con un análisis de etiquetas reproducible (`@clave` / `<clave>` sobre
   los 320 resultados de los caps. 1–6 y sus 41 invocaciones posteriores).
2. **No se reescribe nada** en esta fase: ni párrafos de transición, ni
   enunciados, ni títulos.
3. **Renumeración:** la hará Typst. Los teoremas se renumeran solos al mover
   bloques; **no** se toca ningún número a mano.
4. **Riesgo principal:** las 41 invocaciones por nombre desde los caps. 7–13 y
   apéndices apuntan a etiquetas de los caps. 1–6. Si un bloque comprimido se
   mueve de archivo, la etiqueta viaja con él y la referencia sigue
   resolviendo — pero hay que verificar `typst compile` **después de cada
   capítulo movido**, como ordenaste.
5. **Inconsistencias nuevas encontradas durante el mapeo:** ninguna que bloquee
   un movimiento. Se anotan en `INFORME_FASE2.md`.
