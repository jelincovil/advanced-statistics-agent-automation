# Matriz de fuentes y evidencia para reconstruir las presentaciones

Fecha de inventario: 2026-10-30. Ruta fuente: book_stat_inference_v0/capitulos/. Los SHA-256 fijan el contenido leído; no implican revisión matemática completa.

El archivo PENDIENTES.md documenta una etapa de septiembre–octubre de 2026 y no coincide necesariamente con el texto vigente. Por ejemplo, cap09_verificacion.typ hoy desarrolla el protocolo aunque ese registro lo describa como parcial. Se cotejará cada afirmación con el archivo actual y con la fuente primaria cuando corresponda.

| Clase | Fuente (SHA-256 inicial) | Núcleo docente | Ancla de lectura | Estado/riesgo |
|---:|---|---|---|---|
| 1 | `intro.typ` (`4fcc2d7ba0fb`) | Observación, acción, estimando, caso SSCH sintético y mapa del curso | def:isomorfismo-informal; tab:correspondencia-central | Conceptual; no convertir caso sintético en evidencia clínica. |
| 2 | `cap01_dos_tradiciones.typ` (`d0b9289a40d7`) | Riesgo de Wald, valor de Bellman y alcance de la correspondencia | Secciones Wald y Bellman; remitir a thm:ch9-isomorfismo | Conceptual; identidad formal solo se enseña con hipótesis de cap. 5. |
| 3 | `cap02_wald.typ` (`03ea28404565`) | Definición de riesgo, dominancia, Bayes, minimax y prueba finita | def:ch7-problema; def:ch7-regla; thm:ch7-bayes | Resultados demostrados en texto y ejemplos; cotejar prueba/condiciones por etiqueta. |
| 4 | `cap03_mdp.typ` (`783c165ab154`) | V/Q, Bellman, contracción, iteraciones y cota residual | def:ch8-mdp; def:ch8-V; thm:ch8-bellman-pi | Teoremas y algoritmos con prueba textual; verificar horizonte y descuento. |
| 5 | `cap04_herramientas.typ` (`bc6e447bc012`) | Selección de suficiencia, estimación, tests, asintótica e influencia | Etiquetas de los resultados seleccionados tras curar el capítulo | Mezcla extensa; seleccionar resultados vivos y depurar ejercicios y citas. |
| 6 | `cap05_incrustacion.typ` (`2c9d2cfd8891`) | Construcción terminal, prueba Jθ=−Rθ y extensión bayesiana separada | thm:ch9-isomorfismo; note:ch9-extension-no-demostrada; thm:ch9-secuencial | Teorema con prueba explícita; extensión secuencial tiene hipótesis distintas. |
| 7 | `cap06_fallos.typ` (`795a70849b67`) | Contraejemplos de soporte, identificación, confusión y dependencia | tab:ch9-contraejemplos; def:ch9-transferible | Contraejemplos y límites; ninguna analogía sirve como garantía inferencial. |
| 8 | `cap07_ope.typ` (`6fed76a31d4e`) | Objetivo J(e), supuestos de identificación, DM, IS, PDIS y DR | def:ch10-ope; ass:ch10-overlap; thm:ch10-identificacion | Identificación y estimadores con hipótesis distintas; cotejar literatura primaria. |
| 9 | `cap08_intervalos.typ` (`ed5d6adbd9be`) | Unidad muestral, CLT, HAC/bloques, cobertura y alcance de SAVE | def:ch11-alpha; thm:ch11-clt-mixing; def:ch11-save | Inferencia por episodios iid versus trayectoria dependiente; SAVE requiere validación específica. |
| 10 | `cap09_verificacion.typ` (`8a31d6a7c1c1`) | Ficha de objetivo, resultado, hipótesis, evidencia y dictamen | fig:ch9-protocolo-verificacion; tabla canónica | Protocolo y tabla; dictamen condicionado, nunca certificación automática. |
| 11 | `cap10_casos.typ` (`99e5b21261e7`) | SSCH y 14 laboratorios: diseño, semillas, estimandos y salidas | tab:ssch-recompensas; tab:lab-reparto-f1-f12 | Resultado empírico solo si hay log/semilla/versión; SSCH sintético. |
| 12 | `cap11_despliegue.typ` (`5c3f1214d4dd`) | Cuantización, latencia, cambio de política y validación de ejecución | fig:ch11-dos-capas; protocolos appE | Protocolo de diseño; no declarar rendimiento de despliegue sin medición. |
| 13 | `cap12_problemas.typ` (`6aabdb1895c1`) | Confusión, POMDP, acciones textuales y preguntas abiertas | def:ch12-confound; def:ch12-pomdp; def:ch12-llm | Resultados y preguntas abiertas mezclados; separar teorema, ejemplo e hipótesis. |

## Comprobaciones de inventario

- 13 fuentes de clase, 7 apéndices Typst y 14 scripts de laboratorio `lab*.py` presentes.
- Los conteos de `#proof-env` señalan pruebas textuales, pero no establecen por sí solos qué teorema queda probado. La atribución se hará por resultado al reconstruir cada clase.
- Los resultados simulados se tratarán como evidencia del escenario ejecutado. Ningún ejemplo SSCH se convertirá en afirmación clínica.
- SAVE se explicará con el procedimiento y condiciones del artículo original; el libro actual no autoriza presentar una reproducción independiente como terminada.

## Estado por clase (conteo de reconocimiento, no garantía de validez)

| Clase | Secciones nivel 2 | Entornos de resultado | Bloques de prueba | SHA-256 completo |
|---:|---:|---:|---:|---|
| 1 | 4 | 1 | 0 | `4fcc2d7ba0fb2916e87742cfb21317ff8d3da088791b6103748fcdad9f6d35d9` |
| 2 | 6 | 0 | 0 | `d0b9289a40d705d6a1c63d272a5f4e6acb5aa2796c1d7d80b25e7404ea16bc98` |
| 3 | 20 | 19 | 3 | `03ea28404565e1e0f92e02b4f1acb76d3e4a56a708d5f93fded74c6d7f013a0a` |
| 4 | 22 | 32 | 4 | `783c165ab1543657982ad002f31c56172466b177146404a260c187ec50aed8f8` |
| 5 | 50 | 157 | 17 | `bc6e447bc012165ee063d964cdbbced118baea9d0275de4d266a112145c3cfd1` |
| 6 | 16 | 14 | 1 | `2c9d2cfd8891ce23e26cb0acf68b1f24919e899a80e41b8f4d48b4f0cfc905f0` |
| 7 | 12 | 25 | 0 | `795a70849b67789e8c009c4ad11f4011a893634e0783df06b01e7da21fcd1d22` |
| 8 | 20 | 32 | 5 | `6fed76a31d4ee072614e30497174cb417c6a7dc11ba5c812c071821dc765af1d` |
| 9 | 22 | 25 | 3 | `ed5d6adbd9be0be4d6e014621a38d5fe8d8625bad0785fdf65f1d6dc3fafbcf0` |
| 10 | 38 | 5 | 3 | `8a31d6a7c1c1586d52fe664eb71cc8bd9c19537a9cfbd9c4b1151c48e9ff1d8f` |
| 11 | 89 | 6 | 0 | `99e5b21261e74d9b4c067064264a4913aad306b52154f05ffaf1dac0d2db45d5` |
| 12 | 25 | 1 | 0 | `5c3f1214d4dd7e840cf07c6e854f96c3a16a51d6e81eaac0f38968eb48fad967` |
| 13 | 31 | 30 | 0 | `6aabdb1895c191744ddd221ec42055c7842ce90da5c4023b7c9e7c30d886476f` |

## Material auxiliar

- Apéndices A–G: usar demostraciones largas, notación, regularidad y material de reproducción como respaldo, con procedencia por diapositiva.
- Laboratorios: `lab00_ssch.py`, `lab01a_beta.py`, `lab01b_ctr.py`, `lab02_suficiencia.py`, `lab03_rb.py`, `lab04_comparacion.py`, `lab05_bootstrap.py`, `lab06_aipw.py`, `lab07_bandit.py`, `lab08_bellman.py`, `lab09_incrustacion.py`, `lab10_cartpole.py`, `lab11_dependencia.py`, `lab12_dialogos.py`.
- Bibliografía: `referencias.bib`; verificar cada cita de literatura antes de incorporarla a una diapositiva.

## Criterio de triage para la reconstrucción

**Demostrado:** resultado con enunciado, hipótesis y prueba cotejados en la fuente vigente. **Empírico:** salida ejecutada con versión, semilla y datos identificados. **Pendiente:** condición, resultado o procedencia aún sin comprobar; se enseña como pregunta o límite. Este inventario da una clasificación inicial por bloque; la clasificación final por afirmación se registra en cada clase.
