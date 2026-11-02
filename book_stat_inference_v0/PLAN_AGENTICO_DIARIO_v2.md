# Plan agéntico diario — `v0.2-base` → `v2.0`
### 22 de septiembre a 31 de octubre de 2026 · 40 días · 120 tareas

---

## 0 · Protocolo de sesión

**Al abrir cada sesión, el agente hace esto sin que se lo pidan:**

1. Lee `REGISTRO_DIARIO.md` (última entrada) y `PENDIENTES.md`.
2. Lee la fila del día en este archivo.
3. `git status` → si el árbol no está limpio, reporta y se detiene.
4. `typst compile main.typ main.pdf` → si falla, arreglarlo **es** la tarea 1
   del día y las demás se corren.

**Al cerrar cada sesión:**

1. Un commit por tarea completada, con mensaje descriptivo.
2. Entrada nueva en `REGISTRO_DIARIO.md`: fecha, tareas hechas, tareas no
   hechas y por qué, hallazgos, páginas del PDF.
3. Reporte al autor: **máximo diez líneas**, más lo que requiera decisión.

**Notación de las tareas:**

| | Significado |
|---|---|
| **A** | Del autor. El agente **prepara el insumo** y no escribe la prosa. |
| **D** | Delegada. El agente ejecuta. |
| **V** | Verificación: búsqueda, cotejo de citas, compilación, consistencia. |

**Si una tarea A está bloqueada** (el autor no la hizo): el agente deja
preparado el insumo, lo anota en el registro y adelanta la siguiente tarea D
del plan. Nunca escribe prosa de contribución en lugar del autor.

**Reglas permanentes** (vigentes desde la Fase 1, no se renegocian):

- Nunca se inventa una cita, un DOI, un año ni un resultado.
- Nada entra al `.bib` sin haberse leído al menos el abstract y las hipótesis.
- Si una fila de tabla invoca una garantía cuyas condiciones el libro no
  enumera, se marca `CONDICIONES SIN ESPECIFICAR`; no se rellena.
- Ante la duda entre afirmar más o menos, se afirma menos.
- Los cuadros `PENDIENTE` solo se retiran cuando el hueco está realmente
  cerrado.

---

## Semana 1 · 22–28 sep — Literatura y compresión

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 22** | **V** Fichar Shi, Zhu, Shen, Luo, Zhu & Song (2024, JASA), IC off-policy con MDP confundido. Ficha: qué supuesto sustituye al no-confounding, qué garantiza, qué exige. Crear `LITERATURA_2022_2026.md`. | **D** Apéndice A: clasificar el primer tercio en `(a)/(b)/ambas/ninguna`. **Reportar, no borrar.** | **D** Compresión `COMPRIME` del cap. 2 (Wald), criterio de los 41 resultados vivos. |
| **Mié 23** | **V** Fichar el trabajo sobre inferencia semiparamétrica para valores de política óptima bajo no-unicidad (arXiv 2505.13809, v5 jun-2026) y su procedimiento NSAVE. Comparar punto por punto con SAVE del cap. 8. | **D** Apéndice A: segundo tercio. | **D** Compresión del cap. 3 (MDPs). |
| **Jue 24** | **V** Fichar Luo, Fan & Wu (NeurIPS 2025), inferencia simultánea por sieves + bootstrap multiplicador. Anotar que usa OhioT1DM. | **D** Apéndice A: último tercio + informe consolidado con el conteo por categoría. | **D** Compresión del cap. 4, bloque de suficiencia. |
| **Vie 25** | **V** Mapear el survey de inferencia estadística en RL (arXiv 2502.16195). Cotejar su taxonomía de métodos de IC contra el catálogo ↔/↝ del libro; listar lo que el libro no cubre. | **D** Ejecutar las podas `ninguna` del apéndice A, previo visto bueno del autor. | **D** Compresión del cap. 4, bloque de asintótica. |
| **Sáb 26** | **V** Línea conformal: OPE conforme en MDPs (2304.02574) y PERRY (2507.20068). Ficha conjunta: qué tipo de garantía dan (cobertura en muestra finita) y dónde entra en el catálogo. | **D** Compresión del cap. 4, bloque semiparamétrico. | **D** Bibliografía comentada de la Parte I. |
| **Dom 27** | **V** Evaluación estadística de LLMs: position paper de ICML 2025 sobre el TLC con pocos datos (2503.01747) y trabajo sobre IC sistemáticamente estrechos. Ficha orientada al cap. 11. | **D** Cap. 10: reparto de los laboratorios F.1–F.12 a sus capítulos. | **D** Cap. 10: ordenar el hilo del SSCH cronológicamente. |
| **Lun 28** | **A** **Decisión del autor:** estado de cada problema abierto del cap. 12 (*abierto / parcialmente resuelto / resuelto*). El agente prepara la tabla comparativa problema × literatura como insumo. | **D** Bibliografía comentada de la Parte II. | **V** Citas en prosa sin entrada `.bib` (`PENDIENTES.md` §2.3): crear entrada o retirar la cita. |

---

## Semana 2 · 29 sep – 5 oct — El capítulo 9

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 29** | **A** Cap. 9: definir columnas y alcance de la tabla canónica. | **D** Volcar las 20 tablas a una lista única, marcando duplicados y filas `CONDICIONES SIN ESPECIFICAR`. | **D** Bibliografía comentada de la Parte III. |
| **Mié 30** | **A** Resolver las filas `CONDICIONES SIN ESPECIFICAR`. | **D** Construir la tabla canónica en Typst. | **D** Bibliografía comentada de la Parte IV. |
| **Jue 1** | **A** Cap. 9 §1: el problema de auditar una garantía. | **D** Figura 1 — diagrama de la incrustación $F:\mathbf{Dec}\to\mathbf{MDP}_1$ en CeTZ. Borrador. | **V** Barrido: toda garantía citada en el libro debe existir en la tabla canónica. |
| **Vie 2** | **A** Cap. 9 §2: el protocolo paso a paso. | **D** Figura 1, iteración sobre comentarios. | **D** Actualizar `PENDIENTES.md`; retirar el marcador del cap. 9 si corresponde. |
| **Sáb 3** | **A** Cap. 9 §3: qué hacer cuando una condición no es verificable. | **D** Figura 3 — flujo del protocolo de verificación. | **V** Compilación + referencias cruzadas del cap. 9. |
| **Dom 4** | **A** Cap. 9: ejemplo trabajado del protocolo sobre el SSCH. | **D** Figura 3, iteración. | **D** Compresiones `COMPRIME` restantes. |
| **Lun 5** | **A** Cap. 9: cierre y conexión con el cap. 6. | **D** Inventario del cap. 6: qué material de L1–L6 existe y dónde. | **V** Páginas por Parte contra el objetivo (~110 pp. de cuerpo). |

---

## Semana 3 · 6–12 oct — El capítulo 6

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 6** | **A** Cap. 6: arquitectura del capítulo — por qué seis mecanismos, cómo se agrupan. | **D** Reunir el material disperso de L1–L6 en el archivo del cap. 6. | **V** ¿Alguno de los seis mecanismos fue caracterizado en la literatura 2022–2026? |
| **Mié 7** | **A** L1 (propiedad de Markov) y L2 (observabilidad). | **D** Figura 2 — mapa de los seis mecanismos por punto de ruptura. Borrador. | **V** Compilación. |
| **Jue 8** | **A** L3 (estacionariedad y horizonte infinito). | **D** Figura 2, iteración. | **D** Retirar el marcador del cap. 2 (secciones anexadas). |
| **Vie 9** | **A** L4 (confounding) — **incorporar el resultado de 2024**. | **D** Volcar al `.bib` las fichas del bloque de literatura. | **V** Verificar cada cita nueva contra su fuente. |
| **Sáb 10** | **A** L5 (overlap). | **D** Figura 6 — varianza de IS contra el horizonte $H$ (matplotlib). | **D** Retirar el marcador del cap. 3 (transición de cierre). |
| **Dom 11** | **A** L6 (tasas de convergencia de los nuisance). | **D** Figura 4 — degeneración de la tricotomía. Borrador. | **V** Compilación. |
| **Lun 12** | **A** La degeneración de la tricotomía bajo MA+CMIA: la sección conceptual del capítulo. | **D** Figura 4, iteración. | **V** Consistencia cap. 5 ↔ cap. 6: nada afirmado dos veces con distinto alcance. |

---

## Semana 4 · 13–19 oct — Capítulos 5, 12 y 11

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 13** | **A** Cap. 5: corte teorema/conjetura en §Transferencia de resultados. | **D** Mover al cap. 6 lo que el corte determine. | **V** Compilación + referencias. |
| **Mié 14** | **A** Cap. 5: §Preservación de propiedades. | **D** Mover lo que corresponda. | **V** Ningún `Teorema` sin demostración localizable. |
| **Jue 15** | **A** Cap. 5: cierre y tabla canónica de correspondencias. | **D** Figura 5 — árbol de estimadores de OPE con supuestos en las aristas. | **V** Compilación. |
| **Vie 16** | **A** Cap. 12: reescritura con los estados decididos el 28 de septiembre. | **D** Figura 5, iteración. | **D** Retirar el marcador del cap. 12. |
| **Sáb 17** | **A** Cap. 12: los problemas que siguen abiertos, reformulados. | **D** Apéndice G: esqueleto de código de la replicación. | **V** Verificar disponibilidad de la implementación pública de SAVE. |
| **Dom 18** | **A** Cap. 11 §1: las dos capas de «inferencia». | **D** Figura 9 — las dos capas. | **V** Compilación. |
| **Lun 19** | **A** Cap. 11 §2: cuantización y aproximación de $Q$. | **D** Apéndice G: escenario A. | **V** Primera corrida; contrastar con el artículo. |

---

## Semana 5 · 20–26 oct — Evidencia numérica y cierre de capítulos

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 20** | **A** Cap. 11 §3: latencia como restricción de diseño. | **D** Apéndice G: escenario B. | **V** Corrida y registro de resultados. |
| **Mié 21** | **A** Cap. 11 §4: evaluabilidad de la política (Problema 13.3). | **D** Apéndice G: escenario C. | **V** Corrida y registro. |
| **Jue 22** | **A** Cap. 11: cierre y **decisión sobre `apendice_langgraph.typ`**. | **D** Apéndice G: llenar las tres tablas de resultados. | **V** Comparar ECP/AL/log(MSE) contra los del artículo; reportar discrepancias. |
| **Vie 23** | **A** Cap. 10: andamiaje narrativo, primera mitad. | **D** Figura 7 — cobertura empírica contra $nT$. | **V** Compilación. |
| **Sáb 24** | **A** Cap. 10: segunda mitad. | **D** **Escenario propio:** una condición del libro que falla (mixing débil u overlap insuficiente) y la cobertura degradándose. | **V** Corrida del escenario propio. |
| **Dom 25** | **A** Introducción reescrita sobre el libro que quedó. | **D** Figura 8 — el hilo del SSCH como línea temporal. | **V** Consistencia introducción ↔ capítulos. |
| **Lun 26** | **A** Prefacio revisado. | **D** Cerrar los marcadores `PENDIENTE` restantes. | **V** Inventario final de `PENDIENTES.md`: lo que quede, con justificación. |

---

## Semana 6 · 27–31 oct — Prosa y cierre

| Día | Tarea 1 | Tarea 2 | Tarea 3 |
|---|---|---|---|
| **Mar 27** | **D** Pasada de estilo, Partes I–II: quitar paralelismos, enumeraciones de tres y transiciones mecánicas. | **D** Ídem, Partes III–IV. | **V** Barrido de muletillas y de vocabulario en inglés sin traducir. |
| **Mié 28** | **A** Abstract en inglés. | **D** Sinopsis editorial (mercado, competencia, público). | **V** Verificación final de los epígrafes supervivientes. |
| **Jue 29** | **V** Auditoría final de citas: cada una contra su fuente. | **D** Índice, numeración y referencias cruzadas. | **D** Consistencia visual de las figuras: una paleta, una tipografía. |
| **Vie 30** | **V** Lectura completa del PDF, anotando sin corregir. | **A** Resolver las anotaciones que requieran criterio. | **D** Aplicar las correcciones. |
| **Sáb 31** | **D** Compilación final y revisión del PDF. | **D** `PENDIENTES.md` final e `INFORME_V2.md`. | **D** `git tag -a v2.0`. |

---

## 1 · Holgura y qué se sacrifica primero

No hay días de reserva. Si el plan se atrasa, se recorta **en este orden**:

1. El escenario propio del 24 de octubre (deseable, no necesario).
2. Las figuras 8 y 9 (las últimas de la lista de valor).
3. La sinopsis editorial (se escribe después, fuera del manuscrito).
4. La pasada de estilo de las Partes III–IV.

**Nunca se recorta:** la auditoría de citas del 29 de octubre, la tabla
canónica del cap. 9, ni la decisión sobre los problemas abiertos del 28 de
septiembre. Sin esas tres, `v2.0` no es enviable.

## 2 · Señales de alarma

El agente interrumpe el plan y escala al autor si:

- Una ficha de literatura invalida un resultado del libro, no solo un
  problema abierto.
- La compresión deja un capítulo por debajo de ~8 páginas (señal de que el
  criterio se aplicó mal).
- El apéndice G no reproduce las coberturas del artículo dentro de un margen
  razonable: eso es un hallazgo, no un fallo de implementación, y se investiga
  antes de seguir.
