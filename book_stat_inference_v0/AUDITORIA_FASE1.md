# AUDITORÍA FASE 1 — Integridad bibliográfica y reclamo central

**Manuscrito:** `monografia_typst_v1` — *Teoría Avanzada de Inferencia Estadística aplicado a
Decisión Secuencial y Agentes Inteligentes* (Dr. Jaime Lincovil)
**Fecha de auditoría:** 2026-09-22
**Estado:** Fase 0 completada. **No se editó ningún archivo del manuscrito.**
El único archivo creado es este informe.

---

## 0. Método, alcance y regla inviolable

**Alcance recorrido:** 26 archivos `.typ` (18 123 líneas) + `referencias.bib` (1 291 líneas).

- `main.typ`, `plantilla.typ`, `notacion.typ`, `prefacio.typ`, `_dev_stub.typ`
- `capitulos/capitulo00.typ` … `capitulo13.typ` (14 archivos)
- `apendices/*.typ` (8 archivos)
- `referencias.bib`

**Herramientas:** `grep` con números de línea, extracción de claves y diferencia de conjuntos
(`comm`) para el inventario D. Toda cifra de esta auditoría es reproducible con un comando
`grep` sobre el repositorio.

**Regla inviolable respetada:** no se inventó ni completó ninguna referencia, DOI, año, página
o resultado. Donde no pude verificar algo, figura como **PENDIENTE** y se indica qué haría falta.

**Línea base de compilación (no se recompiló):**
`main.pdf` existente — 281 páginas, A4, generado con Typst 0.15.1 (`pdfinfo`).
`typst` disponible: `/usr/local/bin/typst`, versión 0.15.1.

---

## Resumen ejecutivo

| # | Hallazgo | Severidad | Ubicación |
|---|---|---|---|
| 1 | Teorema nombrado **«Shi et al., 2024, JASA»** — atribución falsa: la obra real es JRSS-B 84(3), 2022 | **Crítica** | `capitulos/capitulo12.typ:66` |
| 2 | **125 reclamos de isomorfismo sobredimensionados** (de 222 líneas coincidentes), incl. el cierre de la única demostración del cap. 9 | **Crítica** | ver Inventario A |
| 3 | Epígrafe **apócrifa** que contradice lo que el capítulo demuestra | **Crítica** | `capitulos/capitulo09.typ:7` |
| 4 | **9 marcadores `[verificación externa]`**, dos de ellos **dentro del nombre de un teorema** | **Alta** | ver Inventario B |
| 5 | **5 teoremas de transferencia de garantías sin demostración** y una nota que niega su validez general | **Alta** | `capitulos/capitulo09.typ:353,364,414,423,397` |
| 6 | Sección **«Sección pendiente.»** en el cuerpo | **Alta** | `capitulos/capitulo07.typ:291` |
| 7 | **14 entradas placeholder** en el `.bib`, 2 de ellas **citadas en vivo** | **Alta** | ver Inventario C |
| 8 | El SSCH **nunca se declara sintético** en ninguna de sus 109 menciones | **Alta** | ver Inventario F |
| 9 | **69 claves bibliográficas huérfanas** (definidas, nunca citadas) | Media | ver Inventario D |
| 10 | **6 sitios malformados** en el `.bib` (restos de entradas borradas) | Media | ver Hallazgo H7 |
| 11 | Frase mecánica «conectándolo con el marco del isomorfismo» insertada antes de pruebas **ajenas al isomorfismo** (8×) | Media | ver Hallazgo H5 |

**Nota positiva verificada:** la entrada `shi2022statistical` del `.bib` ya es **correcta**
(84(3), 765–793, DOI `10.1111/rssb.12465`). El punto 2 de la Fase 1 es, por tanto, un **no-op**.
Ver Hallazgo H1.

---

## INVENTARIO A — Reclamo de isomorfismo

**222 líneas coincidentes** con `isomorf`/`isomórfic`/`isomorfismo` en archivos `.typ`
(0 en `referencias.bib`), en 24 archivos.

### A.1. Regla de clasificación aplicada

| Categoría | Criterio operativo |
|---|---|
| `CORRECTO` | El propio enunciado acota el alcance (menciona *incrustación fiel*, *un paso*, *determinista*, *alcance del `@thm:ch9-isomorfismo`*, o la condicionalidad), **o** documenta explícitamente un límite o fallo. |
| `SOBREDIMENSIONADO` | Usa el nombre fuerte como si denotara un resultado general establecido, **o** afirma transferencia de garantías sin las condiciones requeridas. |
| `AMBIGUO` | No se puede decidir sin criterio humano. |
| `IDENTIFICADOR` | **Desviación del esquema de tres categorías que solicito aprobar:** etiquetas (`<ch:isomorfismo>`), claves de tabla (`key: "tab:isomorfismo-completo"`), nombres de archivo, comentarios de porting y el archivo de desarrollo `_dev_stub.typ`. No son reclamos: son identificadores de código. Renombrarlos es una decisión de API interna del documento, no una corrección de tesis. Los listo aparte para que pueda autorizar o rechazar su renombrado. |

### A.2. Conteo

| Categoría | Ocurrencias |
|---|---|
| `SOBREDIMENSIONADO` | **125** |
| `CORRECTO` | **60** |
| `IDENTIFICADOR` | **34** |
| `AMBIGUO` | **3** |
| **Total** | **222** |

De los 125 `SOBREDIMENSIONADO`, distingo dos tipos de corrección, porque no cuestan lo mismo:

- **tipo N — solo el nombre (90):** la afirmación de fondo ya está correctamente acotada o
  condicionada; basta la sustitución léxica de la Fase 2.
- **tipo A — la afirmación misma excede (35):** además del nombre hay que **reescribir el
  enunciado**; no alcanza con sustituir palabras.

---

### A.3. `SOBREDIMENSIONADO` — tipo A (35) · requieren reescritura del enunciado

```
main.typ:119                    «El isomorfismo está demostrado. Los tres capítulos que siguen lo ponen a trabajar»
prefacio.typ:28                 «no es una mera analogía pedagógica; es un resultado matemático formal que permite transferir sistemáticamente los poderosos resultados»
capitulos/capitulo00.typ:407    «Capítulo~9 dará entonces el isomorfismo en toda su fuerza.»
capitulos/capitulo00.typ:456    «El isomorfismo Wald-MDP hace posible una alternativa: agentes cuyas decisiones estén respaldadas por teoremas estadísticos»
capitulos/capitulo01.typ:729    «será formalizada como un isomorfismo de categorías en el @ch:isomorfismo»
capitulos/capitulo01.typ:1059   «existe un isomorfismo matemático riguroso que permite transferir garantías teóricas del ámbito estadístico al diseño de agentes»
capitulos/capitulo02.typ:90     «el resultado es válido, conectándolo con el marco del isomorfismo.» (frase mecánica; ver H5)
capitulos/capitulo02.typ:316    idem
capitulos/capitulo03.typ:105    idem
capitulos/capitulo03.typ:161    idem
capitulos/capitulo03.typ:231    idem
capitulos/capitulo03.typ:347    «Los resultados de estimación óptima se traducen directamente al contexto de MDPs y agentes mediante el isomorfismo del curso.»
capitulos/capitulo04.typ:185    «el resultado es válido, conectándolo con el marco del isomorfismo.» (frase mecánica; ver H5)
capitulos/capitulo04.typ:298    idem
capitulos/capitulo04.typ:345    idem
capitulos/capitulo07.typ:70     «isomorfismo que el @ch:isomorfismo demostrará en toda su generalidad»
capitulos/capitulo07.typ:185    «el resultado es válido, conectándolo con el marco del isomorfismo.» (frase mecánica; ver H5)
capitulos/capitulo07.typ:227    idem
capitulos/capitulo07.typ:275    idem
capitulos/capitulo07.typ:350    «El isomorfismo se extiende a problemas secuenciales mediante la ecuación de Bellman» (corolario sin prueba)
capitulos/capitulo08.typ:627    «sus garantías se transfieren directamente al contexto secuencial mediante el isomorfismo.»
capitulos/capitulo09.typ:200    «*Conclusión:* $F$ es un isomorfismo de categorías que preserva la estructura de optimalidad, consistencia y eficiencia.» ← cierre de la única demostración del capítulo
capitulos/capitulo09.typ:323    «#thm-env("theorem", name: [Isomorfismo Secuencial])» + enunciado «es isomorfo al MDP con horizonte finito $T$»
capitulos/capitulo09.typ:325    «isomorfo al MDP con horizonte finito $T$.»
capitulos/capitulo09.typ:355    «Bajo el isomorfismo, el IC para $Value^policy$ [...] tiene cobertura asintótica $1-alpha$.» (teorema sin prueba)
capitulos/capitulo11.typ:378    «el resultado es válido, conectándolo con el marco del isomorfismo.» (frase mecánica; ver H5)
capitulos/capitulo11.typ:590    «¿Cómo extendemos el isomorfismo a contextos más generales — horizontes infinitos sin descuento, espacios de estados continuos [...]?»
capitulos/capitulo12.typ:713    «*Isomorfismo Wald-MDP:* Hemos establecido un isomorfismo formal entre»
capitulos/capitulo13.typ:56     tabla: «[Espacio de parámetros] isoto [Estado oculto del entorno (POMDP) / índice de modelo]» ← el estatus `isoto` (exacto) no cubre el caso POMDP
capitulos/capitulo13.typ:70     tabla: «[Estadístico suficiente $T(X)$] isoto [Estado del agente $s_t$]» ← el cap. 0 dice «Vía el supuesto de Markov (MA), no "s estima $theta$"»
capitulos/capitulo13.typ:183    «el isomorfismo se extiende a POMDPs (_partially observable MDPs_), pero»
apendices/apendice_demostraciones.typ:1377  «el isomorfismo se extiende naturalmente: $StateSpace = SampleSpace^T$» ← extensión afirmada como natural
apendices/apendice_tablas.typ:20            caption: «Isomorfismo Wald $arrow.l.r$ MDP: Correspondencia Completa»
apendices/apendice_tablas.typ:99            «[Isomorfismo Wald-MDP], [@ch:isomorfismo], [Arquitectura completa], [Transferencia de resultados]»
```

---

### A.4. `SOBREDIMENSIONADO` — tipo N (90) · basta sustitución léxica

**`prefacio.typ`**
```
43   «sin revelar aún el isomorfismo completo.»
86   «El isomorfismo Wald--MDP hace posible, _bajo las condiciones de regularidad verificables..._»  (sustancia acotada; nombre fuerte)
```
**`notacion.typ`**
```
193  «La siguiente tabla resume las correspondencias fundamentales del isomorfismo»
```
**`capitulos/capitulo00.typ`** (12)
```
27   «== La Tesis Central: Un Isomorfismo Estructural»            (título de sección)
69   caption: «Correspondencias centrales del isomorfismo Wald--MDP (versión revisada)»  (+ marcador B en 84 y 88)
100  «El isomorfismo convierte ese patrimonio en un _recurso transferible_»
116  «Para apreciar la profundidad del isomorfismo, conviene reconstruir»
296  «explícitas las correspondencias del isomorfismo. Cada símbolo tiene una»
366  «=== Notación del isomorfismo»                                (título de sección)
372  «bajo el isomorfismo del @ch:isomorfismo — al negativo de la función de valor»
400  «isomorfismo» que aparecen al final de cada uno»              (guía de lectura)
402  «Capítulo~9 para el isomorfismo, y finalmente los Capítulos~10--12»
415  «isomorfismo para entender de dónde vienen las garantías)»
234  «Policy Iteration y sus garantías de convergencia. El @ch:isomorfismo»
```
**`capitulos/capitulo01.typ`** (5)
```
13   «isomorfismo entre la teoría de Wald y los procesos de decisión de Markov que es la columna vertebral»
61   «complete este capítulo habrá trazado el primer lado del isomorfismo y»
916  «en el @ch:isomorfismo se mostrará su isomorfismo con un»
```
**`capitulos/capitulo02.typ`** (4)
```
54   «traducir esta jerarquía al isomorfismo, obtenemos un principio de diseño de»
437  «=== Conexión con el Isomorfismo Estructural»                 (título de sección)
628  «rendimiento del agente a través del isomorfismo que se formalizará en el @ch:isomorfismo»
659  «este capítulo es, visto desde el isomorfismo, el mismo balance»
```
**`capitulos/capitulo03.typ`** (3)
```
67   «este capítulo es, visto desde el isomorfismo, el mismo balance»
343  «=== Conexión con el Isomorfismo Estructural»                 (título de sección)
```
**`capitulos/capitulo06.typ`** (1)
```
876  «identificación prepara el terreno para el isomorfismo Wald-MDP del @ch:isomorfismo»
```
**`capitulos/capitulo07.typ`** (6)
```
49   «El isomorfismo Wald-MDP que desarrollaremos en el @ch:isomorfismo demostrará que esta no es una»
50   (continuación de la oración anterior)
293  «=== El Isomorfismo Wald-MDP»                                 (título de sección)
296  «Esta sección desarrolla formalmente el isomorfismo central del curso»
445  «esta es la primera manifestación concreta del isomorfismo que formalizamos en el @ch:isomorfismo»
505  «no es accidente, y el @ch:isomorfismo lo demostrará formalmente.»
510  «prepara el terreno para el isomorfismo Wald-MDP del @ch:isomorfismo.»
```
**`capitulos/capitulo08.typ`** (7)
```
52   «El isomorfismo Wald-MDP que desarrollaremos en el @ch:isomorfismo demostrará que esta no es una analogía pedagógica, sino»
53   (continuación de la oración anterior)
65   «Este capítulo es el lado derecho del isomorfismo.»
73   «accidente, y el @ch:isomorfismo lo demostrará formalmente.»
261  «$k=1$ del isomorfismo Wald-MDP. La función de valor es»
355  «En el isomorfismo Wald--MDP que se establecerá formalmente en el @ch:isomorfismo (@thm:ch9-isomorfismo revisado), la ecuación de»
561  «Para el diseñador de agentes inteligentes, este isomorfismo es»
572  «El lector que complete el @ch:isomorfismo comprenderá que la teoría de»
618  «El isomorfismo Wald--MDP que demostraremos en el @ch:isomorfismo tiene»
```
**`capitulos/capitulo09.typ`** (15)
```
4    «= El Isomorfismo Estructural: Teoría de Decisión y MDPs»      (título — renombrar en Fase 2)
34   «El isomorfismo que demostramos en este capítulo no es una curiosidad matemática»
52   «Saber cuándo aplica el isomorfismo es tan importante»
93   «=== El Isomorfismo Fundamental»                               (título de sección)
207  «El isomorfismo Wald-MDP es un resultado poderoso, pero tiene límites importantes.»
342  «El isomorfismo secuencial permite reformular el principio de»
361  «isomorfismo. El siguiente resultado extiende la correspondencia al contraste de hipótesis.»
401  «Bajo el isomorfismo, la admisibilidad en el sentido de Wald equivale a»
410  «isomorfismo. El siguiente teorema muestra que la eficiencia estadística»
578  «#thm-env("example", name: [SSCH --- El Isomorfismo en Acción])»  (además: marcador sintético, Inventario F)
580  «isomorfismo de forma concreta.»
603  «isomorfismo, esto equivale a: la política que maximiza el valor»
665  «El isomorfismo Wald-MDP nos da un marco preciso para abordar OPE.»
683  «transferida al contexto secuencial mediante el isomorfismo.»
687  «manifestación natural del isomorfismo Wald-MDP en el contexto de datos»
```
**`capitulos/capitulo10.typ`** (3)
```
60   «El isomorfismo Wald-MDP da un marco»
575  «El isomorfismo Wald-MDP nos da un marco preciso para abordar este»
595  «isomorfismo Wald-MDP proporciona el marco matemático para desarrollar»
```
**`capitulos/capitulo11.typ`** (1)
```
583  «teoría de decisión de Wald del @ch:wald y el isomorfismo Wald-MDP del @ch:isomorfismo, hemos construido un marco matemático unificado»
```
**`capitulos/capitulo12.typ`** (3)
```
11   «I, el isomorfismo formal Wald-MDP de la Parte II, y la maquinaria de»
540  tabla: «[9], [Isomorfismo], [$R(theta,pi) isoto -Value^pi (s)$; límite: confounders ocultos rompen Markov]»  (además: SSCH sintético)
548  «*Lo que el isomorfismo hizo posible.* Sin el marco unificado, cada»
578  «[Operador Bellman], [Isomorfismo Wald-MDP], [Optimalidad], [@ch:isomorfismo]»
```
**`capitulos/capitulo13.typ`** (6)
```
4    «= Conclusiones: El Isomorfismo como Legado y como Programa»   (título — renombrar en Fase 2)
17   «Comenzamos con el mapa completo del isomorfismo Wald-MDP, ahora con»
26   «== El Mapa Completo del Isomorfismo»                          (título de sección)
32   «presentó el isomorfismo de forma anticipada y necesariamente informal,»
327  «*La estadística como lenguaje de diseño de agentes.* El isomorfismo»
401  «El isomorfismo Wald-MDP es la estructura matemática que hace posible»
```
**`apendices/apendice_demostraciones.typ`** (8)
```
1310 «=== Isomorfismo Wald–MDP»                                     (título de sección)
1384 «Clínico para Hipertensión, este isomorfismo formaliza la equivalencia»   (además: SSCH sintético)
1395 «política $policy$ desde el estado de salud $s$. El isomorfismo»
1408 «isomorfismo Wald-MDP, existe un MDP $cal(M) = (StateSpace,»
1422 «*Paso 1: Conexión entre riesgo y valor.* Por el isomorfismo:»
1481 «problema de decisión y $T(X)$ un estadístico. Por el isomorfismo»
1513 «*Paso 3: Formalización del isomorfismo.* En el contexto del»
1514 «isomorfismo Wald-MDP:»
1531 «El isomorfismo identifica $theta$ con el estado futuro y $X$ con la»
```
**`apendices/apendice_laboratorio.typ`** (5)
```
25   «cosmética: es la manifestación operativa del isomorfismo Wald-MDP que»
141  «@ch:isomorfismo se exhibe su isomorfismo con un MDP médico.»
969  «== Laboratorio F.9: Demostración del Isomorfismo»             (título de sección)
977  «Demostrar computacionalmente el isomorfismo Wald-MDP en sus tres»
1013 caption: «Lab F.9: Isomorfismo Wald-MDP en problema de diagnostico.»
```
**`apendices/apendice_glosario.typ`** (3)
```
15   «del isomorfismo Wald–MDP.»
163  «== Isomorfismo Wald–MDP»                                      (título de sección)
167  caption: «Correspondencias del isomorfismo»
```
**`apendices/apendice_tablas.typ`** (6)
```
11   «== Isomorfismo Wald $arrow.l.r$ MDP»                          (título de sección)
39   «[Regla de decisión $delta$], [Política $pi$], [Mapeo observación $arrow.r$ acción]»
41   «[Regla aleatorizada], [Política estocástica], [$pi(a mid(|) s)$]»
42   «[Regla de Bayes $delta^*$], [Política óptima $pi^*$], [Minimiza riesgo esperado]»
46   «[Teorema de clase completa], [Principio de Bellman], [Optimalidad recursiva]»
308  «[$Psi: "Wald" -> "MDP"$], [Isomorfismo], [@sec:ch9-isomorfismo]»
```

---

### A.5. `CORRECTO` (60) — se conservan sin cambios

Estas ocurrencias ya acotan el alcance o documentan límites. Lista completa:

```
prefacio.typ:15                       «_incrustación fiel_ —no un isomorfismo completo—»
capitulos/capitulo00.typ:17           «Descubrir este isomorfismo, demostrar sus alcances y catalogar honestamente sus límites»
capitulos/capitulo00.typ:93           «*Sobre el nombre.* "Isomorfismo" se usa en el sentido de incrustación fiel [...] no de biyección objeto a objeto»
capitulos/capitulo00.typ:105          «El isomorfismo es _estructural_: preserva las operaciones de composición y»
capitulos/capitulo00.typ:106          «No es, sin embargo, un isomorfismo _incondicional_»
capitulos/capitulo04.typ:86           «La conexión con el isomorfismo que desarrollamos en este capítulo es especialmente iluminadora [...] anticipa el @ch:wald»
capitulos/capitulo07.typ:299          «#thm-env("note", name: [Anticipo del isomorfismo, informal]) [...] *No debe citarse como resultado demostrado hasta ese punto.*»
capitulos/capitulo07.typ:326          «donde se establece la incrustación fiel $bold("Dec") arrow.hook bold("MDP")_1$ con sus condiciones de validez explícitas»
capitulos/capitulo07.typ:467          «[Isomorfismo (Nota~@thm:ch7-isomorfismo, anticipo informal)], [Conexión con MDP]»
capitulos/capitulo08.typ:365          «@thm:ch9-isomorfismo. La extensión al caso general es un problema»
capitulos/capitulo08.typ:551          «El @ch:isomorfismo responde esta pregunta demostrando que existe una incrustación fiel [...] para el caso de un paso y determinista (Teorema 9.3)»
capitulos/capitulo08.typ:645          «Bajo el isomorfismo Wald--MDP (@ch:isomorfismo), el regret es el riesgo frecuentista de Wald»  [MAB = MDP de un paso: dentro del alcance]
capitulos/capitulo09.typ:96           «#thm-env("theorem", name: [Incrustación fiel Wald$->$MDP, caso de un paso])»
capitulos/capitulo09.typ:144          «conectándolo con el marco del isomorfismo.»  [apto: es el capítulo del isomorfismo]
capitulos/capitulo09.typ:204          «=== Límites del Isomorfismo: Contraejemplos»
capitulos/capitulo09.typ:218          «*Fallo del isomorfismo:*»  [dentro del contraejemplo 9.1]
capitulos/capitulo09.typ:225          «isomorfismo exacto falla. Se requieren extensiones»
capitulos/capitulo09.typ:241          «*Fallo del isomorfismo:*»  [contraejemplo 9.2]
capitulos/capitulo09.typ:248          «el isomorfismo [falla]»  [confounders no observados]
capitulos/capitulo09.typ:265          «*Fallo del isomorfismo:*»  [contraejemplo 9.3]
capitulos/capitulo09.typ:272          «El isomorfismo secuencial requiere»
capitulos/capitulo09.typ:278          «el isomorfismo se quiebra si variables no observadas»
capitulos/capitulo09.typ:289          «*Fallo del isomorfismo:*»  [contraejemplo 9.4]
capitulos/capitulo09.typ:296          «el isomorfismo falla.»
capitulos/capitulo09.typ:451          «=== Límites del Isomorfismo: Cuándo NO se Transfieren Garantías»
capitulos/capitulo09.typ:454          «no es una licencia para invocar garantías estadísticas sin verificación»
capitulos/capitulo09.typ:629          «[Isomorfismo (@thm:ch9-isomorfismo)], [Justificación de arquitectura], [Formal, alcance acotado (un paso, determinista) --- ver Nota~@note:ch9-extension-no-demostrada]»  [ejemplar]
capitulos/capitulo12.typ:33           «explícita a tres fronteras donde el isomorfismo se tensiona»
capitulos/capitulo12.typ:340          «isomorfismo Wald-MDP se tensiona y donde la investigación futura es»
capitulos/capitulo13.typ:43           caption con «$arrow.squiggly$ denota transferencia condicional (requiere hipótesis adicionales)»
capitulos/capitulo13.typ:45           «preserva estructura en el alcance del @thm:ch9-isomorfismo (un paso, determinista)»
capitulos/capitulo13.typ:57,59,60,61,64,65,66,67   filas de tabla dentro del alcance demostrado
capitulos/capitulo13.typ:75           «[Información de Fisher] $arrow.squiggly$ [...]»  [usa el símbolo condicional]
capitulos/capitulo13.typ:89           «incrustación fiel _demostrada_ del @ch:isomorfismo: preservan composición y optimización dentro del alcance»
capitulos/capitulo13.typ:109          «*R1 (revisado). La incrustación fiel entre $bold("Dec")$ y $bold("MDP")$»
capitulos/capitulo13.typ:112          «problema abierto (@sec:ch9-isomorfismo, nota sobre extensión no demostrada)»
capitulos/capitulo13.typ:158          «== Limitaciones del Isomorfismo»
capitulos/capitulo13.typ:163          «isomorfismo Wald-MDP con el mismo rigor con que se presentaron sus [límites]»
capitulos/capitulo13.typ:166          «=== Límites del isomorfismo estricto»
capitulos/capitulo13.typ:168          «*L1. La propiedad de Markov.* El isomorfismo establece correspondencia»
capitulos/capitulo13.typ:175          «el isomorfismo requiere»
capitulos/capitulo13.typ:258          «La extensión del isomorfismo a POMDPs (L2) enfrenta el obstáculo de que»
capitulos/capitulo13.typ:386          «que transfiere resultados del isomorfismo sin verificar la [condición]»  [crítica interna]
apendices/apendice_demostraciones.typ:1372  «+ Horizonte de un paso (para isomorfismo exacto)»
apendices/apendice_demostraciones.typ:1456  «+ El isomorfismo Wald-MDP es válido (horizonte de un paso, espacios [...]»  [chequeo de hipótesis]
apendices/apendice_demostraciones.typ:1535  «+ El isomorfismo Wald-MDP es válido»
apendices/apendice_laboratorio.typ:972      «Teoremas clave: #ref(<thm:ch9-isomorfismo>, supplement: none)»
apendices/apendice_laboratorio.typ:1104     «tratar, confirmando el @thm:ch9-isomorfismo.»
apendices/apendice_laboratorio.typ:1111     «+ Extienda el isomorfismo a un horizonte $H=3$»  [ejercicio]
apendices/apendice_tablas.typ:16            «alcance demostrado en el @ch:isomorfismo (@thm:ch9-isomorfismo y [...]»
apendices/apendice_tablas.typ:242           «"Isomorfismo (en este libro)": Incrustación fiel que preserva [...]»
apendices/apendice_tablas.typ:245           «(@thm:ch9-isomorfismo), con la generalización estocástica como [problema abierto]»
apendices/apendice_langgraph.typ:36         «@thm:ch9-isomorfismo (Cap. 9) se restringe al caso determinista sin»
```

---

### A.6. `AMBIGUO` (3) — **requieren su decisión**

| Ubicación | Fragmento | Por qué es ambiguo |
|---|---|---|
| `capitulos/capitulo01.typ:708` | `#thm-env("proposition", name: [Correspondencia Fundamental])` → «La estructura del problema de decisión estadística de Wald es isomorfa a la de un proceso de decisión de Markov (MDP) de un solo paso» | El **alcance** es correcto (un solo paso), pero se presenta como *proposición* sin prueba y sin declarar su estatus. ¿Se rebautiza «Anticipo informal» (como en cap. 7) o se le añade puntero a la demostración del cap. 9? |
| `capitulos/capitulo13.typ:58` | tabla: `[Espacio muestral $SampleSpace$]`, `isoto`, `[Espacio de observaciones $ObsSpace$]` | El cap. 0 dice «La distinción observación/estado reaparece en POMDPs», lo que sugiere que aquí el estatus `isoto` (exacto) es discutible. Consistencia interna a resolver por usted. |
| `apendices/apendice_medido.typ:279` | `[Capítulo 9], [Isomorfismo], [Funtores medibles, preservación de estructura]` | Afirma «funtores medibles» en un contexto medido-teórico. El teorema probado trabaja con espacios finitos/numerables; el estatus medible general no lo está. No sé si es una promesa de alcance o un error de categoría. |

---

### A.7. `IDENTIFICADOR` (34) — no son reclamos · **solicito autorización para tratarlos aparte**

```
plantilla.typ:59                    // Isomorfismo                       [comentario de macros]
_dev_stub.typ:20                    = El Isomorfismo Estructural <ch:isomorfismo>
_dev_stub.typ:44                    #heading(level: 1)[Tablas: isomorfismo] <app:tab-isomorfismo>
capitulos/capitulo00.typ:33         key: "def:isomorfismo-informal"
capitulos/capitulo00.typ:64         @def:isomorfismo-informal ... @ch:isomorfismo
capitulos/capitulo00.typ:234        «El @ch:isomorfismo»
capitulos/capitulo01.typ:1058       @ch:isomorfismo
capitulos/capitulo02.typ:438        <sec:ch2-isomorfismo>
capitulos/capitulo02.typ:629        @ch:isomorfismo
capitulos/capitulo03.typ:344        <sec:ch3-isomorfismo>
capitulos/capitulo06.typ:877        @ch:isomorfismo
capitulos/capitulo07.typ:294        <sec:ch7-isomorfismo>
capitulos/capitulo07.typ:305        @thm:ch9-isomorfismo revisado
capitulos/capitulo07.typ:446        @ch:isomorfismo
capitulos/capitulo08.typ:356        @thm:ch9-isomorfismo revisado
capitulos/capitulo08.typ:538        === Conexión con el @ch:isomorfismo
capitulos/capitulo08.typ:646        @ch:isomorfismo
capitulos/capitulo09.typ:1          // Puerto de capitulos/capitulo09.tex — El Isomorfismo Estructural...
capitulos/capitulo09.typ:5          <ch:isomorfismo>
capitulos/capitulo09.typ:94         <sec:ch9-isomorfismo>
capitulos/capitulo11.typ:584        @ch:isomorfismo
capitulos/capitulo12.typ:18         @ch:isomorfismo
capitulos/capitulo13.typ:1          // Puerto de capitulos/capitulo13.tex — ...
capitulos/capitulo13.typ:29         @tab:isomorfismo-completo
capitulos/capitulo13.typ:48         key: "tab:isomorfismo-completo"
capitulos/capitulo13.typ:90         @thm:ch9-isomorfismo
apendices/apendice_demostraciones.typ:1311  <dem:ch9-isomorfismo>
apendices/apendice_demostraciones.typ:1313  @thm:ch9-isomorfismo
apendices/apendice_demostraciones.typ:1405  @thm:ch9-isomorfismo
apendices/apendice_laboratorio.typ:971      @ch:isomorfismo
apendices/apendice_glosario.typ:164         <sec:appB-isomorfismo>
apendices/apendice_glosario.typ:168         key: "tab:appB-isomorfismo"
apendices/apendice_tablas.typ:12            <app:tab-isomorfismo>
apendices/apendice_tablas.typ:21            key: "tab:app-isomorfismo-completo"
```

⚠️ **Aviso:** renombrar etiquetas rompe referencias cruzadas. La instrucción de la Fase 2 es
«actualizá la etiqueta, no el enlace roto»; eso implica actualizar los ~90 sitios que citan
`@ch:isomorfismo`, `@thm:ch9-isomorfismo`, `@sec:ch9-isomorfismo`, `@tab:isomorfismo-completo`
y `@sec:ch2/ch3/ch7-isomorfismo`. **No lo haré sin su aprobación explícita.**

---

## INVENTARIO B — Citas no verificadas (`[verificación externa`)

**9 marcadores** (el prompt estimaba ~8). Los listo con la obra citada y el estado de
verificabilidad:

| # | Ubicación | Obra que se cita | Ubic./contexto | Comentario de auditoría |
|---|---|---|---|---|
| B1 | `capitulos/capitulo00.typ:84` | «MDPs robustos» (sin autor/año) | fila de tabla `tab:correspondencia-central`, columna Estatus | No nombra obra concreta → **no verificable como está**; salida (c) suprimir la marca, o (b) sustituir por una fuente de MDP robustos |
| B2 | `capitulos/capitulo00.typ:88` | línea DRL de **Kallus–Uehara** | fila de tabla (FIE) | **Resoluble**: `kallus2020double` y `kallus2022efficiently` ya están en el `.bib` y verificables |
| B3 | `capitulos/capitulo00.typ:187` | **Liao, Qi & Murphy (2022)**, OPE con datos observacionales | prosa, §contexto | **No está en el `.bib`**. Requiere verificación externa (a)/(b), o supresión (c) |
| B4 | `capitulos/capitulo00.typ:189` | **Kennedy (2022)**, estimación semiparamétrica robusta para políticas dinámicas | prosa, §contexto | **Resoluble**: `kennedy2022semiparametric` está en el `.bib` (y es **huérfana**: nunca se cita) |
| B5 | `capitulos/capitulo06.typ:483` | **Kallus & Uehara, 2022** — dentro del **nombre de un teorema** | `#thm-env("theorem", name: [IF Eficiente para $Value^policy$ -- Kallus \& Uehara, 2022 _[verificación externa: año a confirmar]_])` | El año 2022 **coincide** con `kallus2022efficiently`. Marca probablemente eliminable tras confirmar la atribución |
| B6 | `capitulos/capitulo12.typ:66` | **«Shi et al., 2024, JASA»** — dentro del **nombre de un teorema** | `#thm-env("theorem", name: [Shi et al., 2024, JASA], key: "thm:ch12-shi-confound")` | 🔴 **NO es un simple marcador: es una atribución falsa.** Shi, Zhang, Lu & Song (2022) es **JRSS-B 84(3):765–793**, no JASA 2024. Ver Hallazgo H1 |
| B7 | `capitulos/capitulo13.typ:79` | línea DRL de **Kallus–Uehara** (Cap. 6) | fila de tabla `tab:isomorfismo-completo` | **Resoluble** contra `kallus2022efficiently` |
| B8 | `apendices/apendice_demostraciones.typ:1853` | **Shi, Zhang, Lu & Song (2022), Apéndices A–C** | esquema de demostración A.11.1 | **Verificable contra el PDF del repo** (`jrsssb_84_3_765.pdf`) |
| B9 | `apendices/apendice_demostraciones.typ:1878` | **Kallus & Uehara**, «años a confirmar» | esquema de demostración A.11.2 (eficiencia DRL) | **Resoluble** contra `kallus2022efficiently` |

**Lectura de conjunto:** de los 9 marcadores, **6 son resolubles sin salir del repositorio**
(B2, B4, B5, B7, B8, B9) contra entradas ya presentes en `referencias.bib` o contra el PDF
`jrsssb_84_3_765.pdf`. Solo B1, B3 y B6 requieren decisión editorial o verificación externa.

---

## INVENTARIO C — Placeholders bibliográficos

Bloque marcado como `ALIAS / PLACEHOLDER ENTRIES (temporal)` en `referencias.bib:658`.
**14 entradas** con `(placeholder)` en el título y `note = {Placeholder entry — complete
bibliographic data needed}`:

| Clave | Línea | Autor declarado | ¿Citada en el `.typ`? |
|---|---|---|---|
| `Shao1995` | 660 | Shao, Jun | No (huérfana) |
| `VanDerLaan2011` | 667 | van der Laan & Rose | No (huérfana) |
| `Robert2007` | 674 | Robert, Christian P. | No (huérfana) |
| `Bertsekas2012` | 681 | Bertsekas, Dimitri P. | No (huérfana) |
| `Bellman1957` | 688 | Bellman, Richard | No (huérfana) |
| `DeGroot1970` | 695 | DeGroot, Morris H. | No (huérfana) |
| `VogelsteinLi2021` | 702 | «Vogelstein, Joshua and Li, Author» ← **autor ficticio** | No (huérfana) |
| `NeweyWest1987` | 709 | Newey & West | No (huérfana) |
| `Andrews1991` | 716 | Andrews, Donald W. K. | No (huérfana) |
| `Kosorok2008` | 723 | Kosorok, Michael R. | No (huérfana) |
| `Hauskrecht2000` | 730 | Hauskrecht, Milos | No (huérfana) |
| `Ouyang2022` | 737 | «Ouyang, Long and others» | No (huérfana) |
| **`bennett2022efficient`** | 744 | «Bennett, Andrew and others» | ✅ **SÍ — `capitulos/capitulo12.typ:696`** |
| **`chen2023llm`** | 751 | «Chen, Mark and others» | ✅ **SÍ — `capitulos/capitulo12.typ:699`** |

**Consecuencia operativa clave:** 12 de las 14 entradas son **también huérfanas** (ver Inventario D),
por lo que su borrado es de riesgo cero. Solo **2 entradas placeholder están citadas en vivo**, y
ambas en el mismo lugar: la lista de «Lecturas Complementarias» del cap. 12 (`capitulo12.typ:696,699`),
donde sostienen únicamente un título de lectura:

```
capitulos/capitulo12.typ:696  + #cite(<bennett2022efficient>, form: "prose")*, "Efficient Offline RL".
capitulos/capitulo12.typ:699  + #cite(<chen2023llm>, form: "prose")*, "LLMs as Decision Makers".
```

**Nota adicional:** `bennett2022efficient` es sospechosamente parecida a la obra real de
**Bennett, Kallus & Mao (2021), «Off-policy evaluation in infinite-horizon MDPs»** — pero **no
la voy a corregir por conjetura**. Y `chen2023llm` («Chen, Mark and others», «LLMs as Decision
Makers») no la puedo verificar. Las tres salidas honestas son: (a) verificar y completar,
(b) sustituir por una lectura equivalente verificable, (c) eliminar el ítem de la lista.

**Otras autorías truncadas con `and others`** (no son placeholders formales, los títulos y
identificadores son reales; los reporto por completitud):
`wang2024survey:464`, `wang2024llm:504`, `liu2023agentbench:504`.

---

## INVENTARIO D — Integridad de citación cruzada

Método: claves definidas = `^@tipo{clave,` en `referencias.bib` → **123 claves**.
Claves citadas = todas las apariciones de `<clave>` en los `.typ` (las etiquetas con `:` se
excluyen automáticamente) → **54 claves reales**.

### D(i) Claves definidas que **nunca se citan** — 69 claves

```
Andrews1991            astrom1965optimal      bang2005doubly         Bellman1957
bertsekas1996neuro     Bertsekas2012          blackwell1953equivalent blei2017
cassandra1998survey    cover2006elements      cramer1946mathematical davison1997bootstrap
DeGroot1970            dickey1971weighted     duchi2021              dudik2011doubly
efron1987better        fisher1922mathematical hajek1970characterization halmos1949application
Hauskrecht2000         hernan2020             hodges1951use          holm1979simple
huber1964robust        imbens2015             imbens2015causal       jeffreys1961theory
jiang2016doubly        kaelbling1998planning  kennedy2016semiparametric  kennedy2022semiparametric
komorowski2018artificial  Kosorok2008         kunsch1989jackknife     langchain2024
lattimore2020          lecam2000asymptotics   liu2023agentbench      mclachlan2000finite
NeweyWest1987          neyman1933testing      Ouyang2022             pearl2009causality
precup2000eligibility  pydantic2024           rao1945information     Robert2007
robins1994estimation   robinson1988root       russo2018tutorial      sarkka2013bayesian
schwarz1978estimating  shani2013              shani2013optimizing    Shao1995
shinn2023reflexion     sugiyama2012           szepesvari2010algorithms  tang2020doubly
thomas2016data         tikz2021               VanDerLaan2011         VogelsteinLi2021
wald1949note           wang2024llm            wang2024survey         wilks1938large
yao2023react
```

🔴 **Observación grave de contenido (no solo bibliográfica):** entre las huérfanas hay obras
que el texto **discute explícitamente sin citarlas**: `neyman1933testing` («No test based on a
theory of probability...», epígrafe del cap. 4), `fisher1922mathematical` (epígrafes de los
caps. 2 y 3), `rao1945information` y `cramer1946mathematical` (cota de Cramér–Rao),
`wald1949note`, `holm1979simple`, `dudik2011doubly` (epígrafe de la Parte III y cita destacada
del cap. 10), `sutton2018reinforcement`. Las epígrafes del manuscrito **atribuyen frases a
autores cuyas entradas existen en el `.bib` pero no están enlazadas**. No las enlacé: hacerlo
requiere decisión suya (¿epígrafes citados o no?).

🔴 **Además, tres obras se citan en prosa sin entrada en el `.bib`:** ver Hallazgo H6
(`Hall & Heyde, 1980`; `Hall, 1992`; `Billingsley, 1995`; `Liao, Qi & Murphy, 2022`).

### D(ii) Claves citadas que **no existen** en el `.bib` — **0 reales**

Los únicos aciertos son **4 falsos positivos**, todos ellos texto de plantilla/comentario y
**no** citas:

```
prefacio.typ:6      <prefacio>                                      [etiqueta de sección]
notacion.typ:6      <notacion>                                      [etiqueta de sección]
plantilla.typ:71    // Uso: #verdem(<label-de-la-demostracion-en-el-apendice>)   [placeholder de macro]
plantilla.typ:85    // Uso: #vertabla(<label-de-la-tabla-en-el-apendice>)        [placeholder de macro]
```

**Veredicto D:** el aparato de citación está **bien conectado** (cero referencias rotas). El
problema no es la coherencia interna, es que **56 % del `.bib` (69/123) es decorativo** y que
las fuentes realmente discutidas en el texto no siempre están enlazadas.

---

## INVENTARIO E — Atribución numérica (Shi et al. / SZLS / SAVE / OhioT1DM)

### E.1. El artículo real

`referencias.bib:339` `shi2022statistical` — Shi, C., Zhang, S., Lu, W., & Song, R. (2022),
*Statistical Inference of the Value Function for Reinforcement Learning in Infinite Horizon
Settings*, JRSS-B 84(3):765–793, DOI `10.1111/rssb.12465`. **La entrada ya es exacta.**

PDF de la fuente en el repositorio: `jrsssb_84_3_765.pdf`.

### E.2. Rastreo de cada cifra atribuible

| Cifra | Ubicación | Origen real | ¿Presentada como del artículo? |
|---|---|---|---|
| `n ≥ ((1.96+0.84)² × 2 × 0.21²)/0.5² ≈ 125` | `capitulos/capitulo11.typ:558` | **Cálculo sintético del SSCH**: fórmula de tamaño muestral con σ̂=0.21 calculado en el propio ejemplo | **No.** Derivada en el texto |
| «el hospital necesita al menos **125 trayectorias** de pacientes» | `capitulos/capitulo11.typ:559` | idem | **No** (pero ver E.3) |
| «Mixing ρ̂=0.73; SAVE; IC [4.81, 4.85]; **125 pacientes suficientes**» | `capitulos/capitulo12.typ:542` | SSCH | **⚠️ Zona de riesgo** — ver E.3 |
| `σ̂_SAVE = 0.21`, `K = ⌊500^(1/3)⌋ = 7` | `capitulos/capitulo11.typ:546-547` | SSCH (n=500 trayectorias sintéticas) | No |
| IC `[4.81, 4.85]`, `Value^DR = 4.83` | `capitulos/capitulo11.typ:551` | SSCH | No |
| «IS inútil (3²⁴); DR estable, Value^DR = 4.83» | `capitulos/capitulo12.typ:541` | SSCH | No |
| `Value^(pi_3)(s_3) = 4.82 ± 0.38`, `p = 0.008`, IC `[0.16,1.66]`, BH en 6 comparaciones, bootstrap `[4.08,5.56]`, 87 iteraciones | `capitulos/capitulo12.typ:534-539` | SSCH | No |
| `n = 200 pacientes` | `capitulos/capitulo03.typ:454,464,532`; `capitulos/capitulo06.typ:728`; `apendices/apendice_laboratorio.typ:407,456` | SSCH | No |
| `T = 50 pacientes`, `20 pacientes consecutivos` | `capitulos/capitulo08.typ:318,676` | SSCH | No |
| `R̂ = 1.002`, `tamaño efectivo ≈ 418 < 500` | `capitulos/capitulo03.typ:535`; `apendices/apendice_laboratorio.typ:1402` | SSCH | No |
| **6 pacientes**, 8 semanas, intervalos de 3 h, estado 3-dim, acción binaria, IGC, γ=0.5 | — | artículo real | **NO APARECE EN EL MANUSCRITO** (ver E.4) |

### E.3. El punto crítico: `capitulo12.typ:542` — **sí, es confundible**

```
capitulos/capitulo12.typ:542
  [11], [Inferencia para $Value^pi$], [Mixing $hat(rho)=0.73$; SAVE; IC $[4.81, 4.85]$; 125 pacientes suficientes],
```

La fila está en una tabla cuya cabecera de columna 3 es **«Resultado en el SSCH»**
(`capitulo12.typ:530`), y la fila 11 tiene como concepto «Inferencia para `$Value^pi$`», que es
precisamente el resultado de **Shi et al.** Además, el párrafo inmediatamente siguiente
(`capitulo12.typ:552`) dice: *«el IC es válido por el **Teorema de Shi et al.**»*.

**Diagnóstico:** la atribución correcta **está** (columna «Resultado en el SSCH»), pero la
yuxtaposición «fila 11 / `Value^pi` / Teorema de Shi et al. / 125 pacientes» **permite
perfectamente** que un árbitro lea «125 pacientes» como un dato del artículo. El artículo real
trabaja con **6 pacientes de OhioT1DM**, no 125. Confirmo el riesgo señalado en el prompt.

**Recomendación:** al reescribir la fila, explicitar «(SSCH sintético, n=125 calculado por
análisis de poder; **no** es un dato de Shi et al., que usa 6 pacientes de OhioT1DM)».

### E.4. OhioT1DM — **el manuscrito no describe el dataset**

Búsqueda exhaustiva de `OhioT1DM`, `Ohio`, `diabetes`, `insulina`, `gluc`, `glyc`, `T1DM`,
`6 pacientes`, `seis pacientes` en los 26 `.typ`: **cero apariciones**.

**Consecuencia:** el punto 4 de la Fase 3 («donde el libro describa OhioT1DM, verificá contra el
artículo original: 6 pacientes, ocho semanas, intervalos de 3 h, estado 3-dim, acción binaria
según unidades de insulina, recompensa vía IGC, γ=0.5») **es inaplicable: no hay tal descripción**.
La verificación sería sobre contenido inexistente. Los hechos que usted enumera coinciden con mi
conocimiento del artículo, pero **no los incorporé a ningún lado** porque no hay dónde.

Sí hay **datasets reales mencionados** en `apendices/apendice_tablas.typ:449-460` (NHANES, NHEFS,
California Housing, NASA CMAPSS) con notas éticas — ese bloque está bien y **no** se toca.

### E.5. Otros puntos numéricos a revisar

- `capitulos/capitulo11.typ:544`: «coeficiente β̂ = 1/(1−0.73) ≈ **3.7** pasos de mezcla
  efectivos». 1/0.27 = 3.703… → aritmética correcta. Sin objeción.
- `capitulos/capitulo11.typ:546`: ⌊500^(1/3)⌋ = ⌊7.937⌋ = 7 ✓.
- `capitulos/capitulo11.typ:551`: 1.96 × 0.21/√500 = 1.96 × 0.009391 = 0.01841 ≈ 0.018 ✓.
- `apendices/apendice_demostraciones.typ:1846`: cita **«Hall & Heyde (1980, Teorema 3.2)»** —
  referencia específica a un teorema de una obra **sin entrada bibliográfica**. Ver H6.

---

## INVENTARIO F — Estatus del SSCH

**109 menciones de `SSCH`** en 15 archivos. **Ninguna** lo declara **sintético** ni
**ilustrativo**. Las únicas palabras cercanas en todo el manuscrito son «simulado/a»
(aplicadas a *otros* contextos: laboratorios con datos Bernoulli, ambiente del cap. 11) y una
nota ética sobre NASA CMAPSS en `apendice_tablas.typ:459`.

### F.1. Primera aparición (la crítica)

```
capitulos/capitulo01.typ:965-973
=== Hilo longitudinal: Sistema de Soporte Clínico para Hipertensión (SSCH)
#thm-env("example", name: [SSCH --- El MDP Clínico como Modelo Paramétrico], key: "ex:ssch-cap01")[
  A lo largo de los doce capítulos de esta monografía seguiremos un único
  ejemplo que acumula sofisticación estadística en cada paso: el _Sistema
  de Soporte Clínico para Hipertensión_ (SSCH), un agente secuencial que
  gestiona pacientes con hipertensión arterial.
```

El comentario interno de `capitulo01.typ:996-1004` confirma que en el LaTeX original este
ejemplo es el **Ejemplo 1.35**. **No se declara sintético, ni ilustrativo, ni que sus
parámetros no provienen de ningún estudio clínico.** Se presenta con anclaje normativo real
(«guías ACC/AHA 2017», `capitulo01.typ:976`), lo que **agrava** la impresión de dato clínico.

### F.2. Menciones donde el SSCH se presenta con apariencia empírica (sin declaración)

Muestreo de las que más riesgo reputacional tienen, por contener **cifras**:

```
capitulos/capitulo03.typ:454    «Con $n = 200$ pacientes y $N(s_3,a_3) = 80$ transiciones observadas»
capitulos/capitulo03.typ:535    «$hat(R) = 1.002$ para todos los parámetros (convergencia adecuada)»
capitulos/capitulo08.typ:318    «*Simulación.* Sobre 20 pacientes consecutivos, comparamos tres»
capitulos/capitulo08.typ:335    «tras solo 20 pacientes, frente al 38% de la aleatorización»
capitulos/capitulo11.typ:541-559  «los datos históricos», «mixing geométrico: ρ̂ = 0.73», «IC [4.81,4.85]», «125 trayectorias»
capitulos/capitulo12.typ:532-543  tabla completa de resultados numéricos por capítulo
capitulos/capitulo12.typ:599    «#thm-env("example", name: [Trazabilidad en SSCH])»
capitulos/capitulo12.typ:692    «episodios simulados del SSCH, la política converge a seleccionar el»
apendices/apendice_laboratorio.typ:407  «Disponemos de $T(X) = {N(s,a,s')}$ con 200 pacientes»
apendices/apendice_demostraciones.typ:1384  «Clínico para Hipertensión, este isomorfismo formaliza la equivalencia»
```

### F.3. Menciones que SÍ acotan correctamente (parcial)

```
capitulos/capitulo03.typ:553    «ambos métodos en el SSCH, pero una implementación completa requeriría:»  [acota el alcance del cómputo]
capitulos/capitulo06.typ:743    «presentada es ilustrativa. Una implementación completa requeriría:»     [dice "ilustrativa" pero NO sobre el SSCH como dato]
capitulos/capitulo11.typ:433    «*Ambiente simulado.* Usamos las probabilidades de transición»          [la palabra "simulado" aparece, pero dentro del ejemplo, no en la primera aparición]
```

**Veredicto F:** el SSCH **nunca se declara sintético en su primera aparición ni en ninguna
otra**, y varias de sus cifras (n=200, n=500, ρ̂=0.73, IC [4.81,4.85], 125 trayectorias,
20 pacientes, 87 iteraciones) están redactadas como resultados observados. Es exactamente la
bandera roja que el prompt anticipa.

---

## HALLAZGOS ADICIONALES (no solicitados, encontrados en el recorrido)

### H1 · 🔴 Atribución falsa dentro de un nombre de teorema — `capitulo12.typ:66`
```
#thm-env("theorem", name: [Shi et al., 2024, JASA], key: "thm:ch12-shi-confound")[
```
«Shi et al., **2024, JASA**» no existe. La obra real de Shi, Zhang, Lu & Song es **2022,
JRSS-B 84(3):765–793**. Un árbitro de JRSS-B detecta esto de inmediato. Requiere corrección
de la atribución **y** decisión sobre si el enunciado (sesgo del DR bajo confounding no
observado) corresponde realmente a esa fuente — no lo puedo verificar sin leer el PDF.

### H2 · 🔴 Sección vacía en el cuerpo — `capitulo07.typ:288-291`
```
=== Optimalidad de secuencias de decisiones
<sec:ch7-secuencias>

Sección pendiente.
```
Cero contenido. Es la sección que debía **preparar** el §`sec:ch7-isomorfismo` que viene
inmediatamente después (línea 293).

### H3 · 🔴 Teoremas de transferencia sin demostración
En `capitulo09.typ` hay cinco resultados de transferencia **sin prueba en el cuerpo ni en el
apéndice** (verifiqué las claves `<dem:...>` del apéndice: solo existen `dem:ch9-isomorfismo`
y `dem:ch9-suficiencia-markov`):

| Clave | Línea | Enunciado |
|---|---|---|
| `thm:ch9-ic` | 353 | «el IC para `$Value^policy$` [...] tiene cobertura asintótica `$1-alpha$`» |
| `thm:ch9-tests` | 364 | «preservando nivel y poder» |
| `thm:ch9-admisibilidad` | 397 | «`$decrule$` es admisible `<=>` `policy` es Pareto-óptima» |
| `thm:ch9-eficiencia` | 414 | «Si `hat(theta)` alcanza la cota de Cramér-Rao [...] El estimador DR alcanza la cota semiparamétrica» |
| `thm:ch9-state` | 423 | «Un `StateSchema` tipado implementa un estadístico suficiente minimal» |
| `cor:ch7-secuencial` | `capitulo07.typ:349` | «El isomorfismo se extiende a problemas secuenciales» |

Esto **contradice directamente** la nota `note:ch9-extension-no-demostrada`
(`capitulo09.typ:127-140`), que declara la extensión como *problema abierto*. La honestidad ya
está escrita en el libro; estos teoremas la desmienten trescientas líneas más abajo.

### H4 · 🔴 El cierre de la única demostración excede el teorema
`capitulo09.typ:200`: «*Conclusión:* $F$ es un **isomorfismo de categorías** que preserva la
estructura de optimalidad, **consistencia y eficiencia**.»
El teorema (línea 96) enuncia un **funtor fiel** («incrustación fiel»), y los 4 pasos de la
prueba verifican composición, optimalidad, Bayes y admisibilidad. **Nunca** se demuestra
«consistencia» ni «eficiencia», y un funtor fiel no es un isomorfismo de categorías. Esta única
frase es el origen textual de buena parte de los 125 reclamos sobredimensionados.

### H5 · Frase mecánica insertada antes de pruebas ajenas al isomorfismo (8×)
Variante de H4, pero estructural: la **misma oración** precede demostraciones de teoremas que
**no tienen relación con el isomorfismo** — Rao-Blackwell, Lehmann-Scheffé, Cramér-Rao,
Neyman–Pearson, teorema de política bayesiana, maximización de `$Value$` por gradiente de
política:

```
capitulos/capitulo02.typ:90     capitulos/capitulo03.typ:105
capitulos/capitulo02.typ:316    capitulos/capitulo03.typ:161
capitulos/capitulo04.typ:185    capitulos/capitulo03.typ:231
capitulos/capitulo04.typ:298    capitulos/capitulo04.typ:345
capitulos/capitulo07.typ:185    capitulos/capitulo07.typ:227
capitulos/capitulo07.typ:275    capitulos/capitulo11.typ:378
```
Texto: «*La demostración que sigue hace explícitas las condiciones bajo las cuales el resultado
es válido, **conectándolo con el marco del isomorfismo**.*» Es un artefacto de generación: la
validez de la cota de Cramér-Rao no depende del isomorfismo Wald–MDP.

### H6 · Referencias en prosa sin entrada bibliográfica
```
apendices/apendice_demostraciones.typ:1832  «El TLC de martingala (p. ej. Hall \& Heyde, 1980) aplicado a esta»
apendices/apendice_demostraciones.typ:1846  «aplicando Hall \& Heyde (1980, Teorema 3.2)»
capitulos/capitulo05.typ:738                «*Billingsley, P.* (1995). _Probability and Measure_, 3rd ed.»
capitulos/capitulo05.typ:744                «*Hall, P.* (1992). _The Bootstrap and Edgeworth Expansion_.»
capitulos/capitulo00.typ:186                «el de Liao, Qi y Murphy (2022) sobre evaluación off-policy»   (marcador B3)
```
Ninguna de estas obras (`Hall & Heyde 1980`, `Billingsley 1995`, `Hall 1992`, `Liao-Qi-Murphy 2022`)
tiene entrada en `referencias.bib`. Las tres primeras son obras reales y estándar, pero
**no voy a inventar sus datos bibliográficos**: quedan como PENDIENTE de verificación.

### H7 · `.bib` malformado: restos de entradas borradas (6 sitios)
El comentario `},` o un `doi = {...}` colgando quedó pegado a un banner de comentario. Son
residuos de entradas eliminadas en una revisión previa:
```
referencias.bib:177-178   },  +  doi = {10.5705/ss.202015.0345}
referencias.bib:302-303   },  +  doi = {10.1613/jair.4612}
referencias.bib:336-337   % ---------------...,   +  doi = {10.1613/jair.713}
referencias.bib:387-388   % ---------------...,   +  doi = {10.1080/01621459.2019.1604369}
referencias.bib:492-493   % ---------------...,   +  doi = {10.1613/jair.487}
referencias.bib:635-636   % ---------------...,   +  doi = {10.1098/rspa.1945.0007}
```
El `.bib` compila porque Typst los ignora, pero son **basura visible para un árbitro que abra
el archivo fuente**. Señales de que hubo borrados sin limpieza: los `doi` huérfanos 10.1613/jair.713
y 10.1613/jair.487 sugerirían fuentes del JAIR que se retiraron.

### H8 · Afirmación de equivalencia en la Introducción — `capitulo00.typ:16`
«[...] son, en un sentido matemático preciso, **teoría equivalentes** escrita en dos lenguajes
distintos.» Dos problemas: (i) error gramatical (`teoría equivalentes` → `teóricamente
equivalentes`); (ii) la afirmación «equivalentes» es **más fuerte** que el teorema que el propio
libro demuestra (incrustación de un caso acotado). Esta frase está en la página de apertura.

> **Resuelta — v0.2-base (2026-09-22).** El pasaje se sustituyó por texto que declara el
alcance real: las dos tradiciones «comparten […] una misma estructura de decisión», y «esa
correspondencia no es una equivalencia entre teorías: se demuestra como una incrustación fiel
del marco de Wald en los procesos de decisión de Markov, para el caso de un paso y
determinista, y su extensión al caso estocástico general permanece abierta». El error de
concordancia desaparece con la reescritura. Ubicación actual: `capitulos/intro.typ`, párrafo de
apertura.

### H9 · Artefactos de desarrollo en la raíz del repositorio
- `_dev_stub.typ` (50 líneas) — stub de desarrollo con etiquetas dummy. **No está incluido en
  `main.typ`**: es código muerto en el repositorio. Contiene `= El Isomorfismo Estructural
  <ch:isomorfismo>` (entrada A.7).
- `_dev_stub.pdf` (88 KB), `preview_notacion.pdf` (134 KB) — PDFs de desarrollo.
- `main.pdf` (6.95 MB) — artefacto de compilación versionado.
- `jrsssb_84_3_765.pdf` (2.1 MB) — fuente primaria, correcta de tener.

### H10 · Estado de revisión interna inconsistente
El manuscrito ya contiene marcas de una **campaña de corrección previa** que no se propagó a
todo el texto: `// Fix M4 (Entrega 8.A)`, `// Fix J4 (Entrega 5.B)`, `// Fix K4 (Entrega 6.B.ii)`,
`// Fix L2 (Entrega 7.B.ii)`, «R1 **(revisado)**», «(@thm:ch9-isomorfismo **revisado**)»,
«(versión revisada)». Hay además comentarios `// NOTA DE INTEGRIDAD` en `capitulo01.typ:996`,
`capitulo13.typ:35` y `apendice_demostraciones.typ:829`.

**Diagnóstico:** el régimen honesto (nota sobre extensión no demostrada, columna «Estatus»,
símbolo `$arrow.squiggly$` para transferencia condicional, R1 revisado) **convive con** el
régimen sobredimensionado (título del cap. 9, epígrafe apócrifa, «el isomorfismo está
demostrado», 35 afirmaciones tipo A). La Fase 2 no inventa una tesis nueva: **termina de
propagar una corrección que el propio autor ya empezó y dejó a medias.** Eso es, con diferencia,
la observación más importante de esta auditoría.

---

## DECISIONES QUE NECESITO DE USTED ANTES DE LA FASE 1

1. **¿Autoriza renombrar las etiquetas** (`<ch:isomorfismo>`, `@thm:ch9-isomorfismo`,
   `@sec:ch9-isomorfismo`, `@tab:isomorfismo-completo`, `<sec:ch2/ch3/ch7-isomorfismo>`) y sus
   ~90 puntos de referencia? Si no, el título del cap. 9 cambia pero las etiquetas quedan con el
   nombre viejo (opción que **recomiendo**, por ser la de menor riesgo).
2. **Los 3 casos `AMBIGUO`** (A.6): `capitulo01.typ:708`, `capitulo13.typ:58`,
   `apendice_medido.typ:279`. ¿Cómo los resuelvo?
3. **¿La epígrafe del cap. 9** (`capitulo09.typ:7`) se **elimina** o se **sustituye**? No
   conozco una cita real y verificable que afirme la incrustación fiel; una cita genuina de Wald
   o de Puterman sobre la relación entre ambos marcos sería honesta, pero requeriría que usted
   elija la fuente (no quiero fabricar una atribución).
4. **Los 5 teoremas sin prueba de H3**: ¿los degrado a *Nota/Conjetura* (cambio de entorno, bajo
   riesgo), los marco con `// PENDIENTE` (mínimo cambio), o los dejo como están? Mi recomendación
   es **degradarlos**, porque contradicen la nota de extensión no demostrada.
5. **La sección vacía de H2** (`capitulo07.typ:291`): ¿la elimino, o la dejo con un `// PENDIENTE`
   visible?
6. **`Liao, Qi & Murphy (2022)`** (B3) y **`bennett2022efficient`/`chen2023llm`** (C): ¿quiere
   que intente verificarlas externamente, que las sustituya por fuentes equivalentes del propio
   `.bib`, o que suprima las afirmaciones/lecturas que dependen de ellas?
7. **Las epígrafes de Fisher, Neyman–Pearson, Wald, Efron, Kant, Mac Lane** cuyas obras están en
   el `.bib` pero sin enlazar (D(i)): ¿las convierto en citas enlazadas o las dejo como prosa?

---

## LO QUE NO HICE (por disciplina de fase)

- No toqué ningún `.typ` ni `referencias.bib`.
- No recompilé (`main.pdf` sigue siendo el de 281 páginas, fecha 2026-08-02).
- No escribí ni completé ninguna referencia, DOI, año, página o resultado.
- No modifiqué títulos, epígrafes, etiquetas ni notación.
- No borré los placeholders ni las claves huérfanas: están inventariados, intactos.

**Esperando su aprobación para proceder a la Fase 1 (integridad bibliográfica).**
