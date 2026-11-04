# PROPUESTA DE REFORMULACIÓN — de texto de curso a monografía publicable

**Fecha:** 2026-11-02 · **Estado base:** `v0.2-base`, 274 pp., compila con deuda declarada
**Objetivo del autor:** publicable, alto nivel, vanguardista
**Origen:** evaluación de rigor 2026-11-02 + lectura de `MAPA_ESTRUCTURA.md`,
`PENDIENTES.md`, `LITERATURA_2022_2026.md`, caps. 0–12 y apéndices.

Este documento propone. No edita capítulos, no toca el `.bib`, no mueve código.

---

## 1. Diagnóstico: tres distancias al objetivo

**D1 — Tesis.** El libro actual es una *síntesis disciplinada* (excelente como
curso): su teorema central es elemental y sus capítulos fuertes (evaluación
off-policy, intervalos, fronteras) exponen literatura ajena con buena
atribución. Una monografía de alto nivel necesita además *contribuciones
propias*, aunque sean del tamaño de dos o tres teoremas bien delimitados.

**D2 — Idioma y canal.** Español sirve al curso doctoral en Lima; el nivel
editorial que se pide (Springer / Cambridge–IMS / Foundations & Trends)
exige inglés y un contrato distinto: menos recorrido docente, más tesis.

**D3 — Estado interno.** 16 marcadores `PENDIENTE` abiertos, capítulos
fusionados con etiquetas migradas (`ch9-*` vive en el cap. 5, `ch10-*` en el
cap. 7), fallo declarado en `intro.typ:89`, el laboratorio insignia
(`agents_curso/capitulo_09_isomorfismo`) implementa un objeto distinto del
que demuestra el cap. 5, y no hay ningún estudio con datos reales.

**Lo que ya es de nivel publicable y se conserva intacto:** la disciplina de
alcance (ningún resultado afirma más de lo que demuestra), el protocolo de
fichas bibliográficas, los laboratorios con semillas fijas que reproducen lo
registrado, y los tres scripts de `verificacion/` que comprueban las
afirmaciones numéricas del texto. Estas convenciones *son* la marca del libro.

---

## 2. Propuesta central: dos artefactos, no uno

Un solo libro no puede cumplir los dos contratos (curso doctoral en español ↔
monografía de investigación en inglés). Reformulación en doble vía:

| Artefacto | Idioma | Extensión | Canal | Función |
|---|---|---|---|---|
| **M — monografía** | Inglés | 150–190 pp | Propuesta a *Foundations & Trends in Machine Learning/Statistics*; respaldo: *SpringerBriefs in Statistics*, *IMS Monographs* (CUP) | Publicación de alto nivel |
| **C — libro de curso** | Español | ~280 pp (actual) | Auto-publicación del curso, `v1.0-curso` | Docencia doctoral |

Título de trabajo de **M**: *Statistical Guarantees for Sequential Decision
Agents: Risk, Representation, and Verification*.
**C** conserva su título actual.

El costo incremental es menor de lo que parece: los caps. 1–9 actuales (los
bien cerrados) se traducen con revisión humana; el contenido nuevo se escribe
una sola vez, en inglés; **C** hereda de M lo que le convenga como apéndices.

---

## 3. El núcleo vanguardista (lo que M afirma y el curso no tiene)

Cuatro piezas, ordenadas por riesgo creciente. Cada una con su plan de
degradación: si una falla su chequeo de literatura, se degrada a nota con
atribución en lugar de afirmarse como contribución.

### V1 · Teorema de estructura de la representación (riesgo medio)

El cap. 5 demuestra que toda decisión de Wald se representa preservando
riesgo en una familia de MDP *de un paso con transición terminal*. La pregunta
inversa no está respondida: **¿qué MDPs admiten una reducción
riesgo-preservante a un experimento estadístico?** Se conjetura una
caracterización necesaria-y-suficiente de la forma
*un-paso + terminal + recompensa indexada por parámetro* (modulo
reparametrización de Blackwell), en el lenguaje de comparación de
experimentos (Blackwell/Le Cam *deficiency*; Torgersen). Si el chequeo de
literatura muestra que es conocido, se degrada a "nota expositiva con la
demostración completa" — que el campo igualmente no tiene escrita en un solo
lugar. Es la pieza que convierte el cap. 5 de "identidad de una línea" en
"estructura con recíproco".

### V2 · Cálculo de certificados de transferencia (riesgo bajo-medio)

Los caps. 6 y 9 ya contienen el material en prosa: los seis mecanismos
L1–L6, la tabla de correspondencias con respaldo, y el protocolo de ficha.
La contribución es formalizarlo: un **certificado de transferencia** es una
tripleta (afirmación, régimen muestral, condiciones) con reglas de
composición explícitas (cuándo certificados encadenan, cuándo la composición
es inválida — con contraejemplos demostados, no retórica). Es un resultado
metodológico propio, de tamaño honesto, y es la tesis que el libro ya anuncia
sin haberla formalizado: *la verificación es un objeto matemático, no un
comentario editorial*.

### V3 · Inferencia anytime-valid para evaluación de políticas (riesgo bajo)

**El hueco está medido:** el corpus actual no contiene e-values, secuencias
de confianza ni desigualdad de Ville (solo una mención al SPRT en
`cap09_verificacion.typ:469`). El puente narrativo es inmejorable para este
libro: Wald (1945) → Robbins → Ville → e-procesos → Ramdas et al. (2023,
*PNAS*) → Waudby-Smith, Wu, Ramdas, Karampatziakis & Mineiro (2022,
*anytime-valid off-policy inference*). Capítulo nuevo en M: secuencias de
confianza y e-procesos para el valor de una política, con la misma disciplina
de condiciones del resto del libro y dos laboratorios (un contextual bandit
con monitorización continua; comparación contra el IC de tiempo fijo del
cap. 8 actual). Los teoremas son de la literatura y se atribuyen como tal —
la contribución es la integración rigurosa, el capítulo que ningún texto
reúne, y la verificación computacional independiente. Degradación permitida:
de "capítulo" a "sección avanzada" si el plazo aprieta; nunca se elimina.

### V4 · Evaluación sin la política: agentes de lenguaje (riesgo alto)

El cap. 12 actual ya formula el problema con calidad (evaluar políticas
cuyas probabilidades de acción no son observables: texto como acción). M lo
convierte en capítulo de frontera: análisis de identificación parcial para
estimandos de acciones textuales (qué sobrevive sin logprobs; qué exige una
envoltura que registre probabilidades; teorema de no-identificación con su
contraexemplo, siguiendo el patrón del cap. 6). Resultados **parciales y
etiquetados como tales**. Si no se consolidan, el capítulo se mantiene como
"problemas abiertos formulados con precisión" — que ya es superior a lo que
existe en la literatura de evaluación de agentes LLM.

### Lo que deliberadamente NO entra

- Q-learning, DQN, PPO ni algoritmos de RL de aprendizaje: fuera de la tesis
  (planificación con modelo conocido y evaluación estadística sí; optimizar
  políticas con redes neuronales, no).
- Predicción conforme: hueco real, pero abrir ese frente diluye; se nombra
  un párrafo en V4 como problema abierto.
- Los 279 resultados del cap. 4 actual que nunca se invocan aguas abajo
  (cómputo de `MAPA_ESTRUCTURA.md`: 41/320 supervivientes): en M van a un
  apéndice de herramientas de referencia; no al cuerpo.

---

## 4. Arquitectura de M y su trazabilidad con el estado actual

```
Parte I — Representación (≈55 pp)
  1. Experimentos estadísticos y comparación (Blackwell, suficiencia)
  2. Decisión de Wald              [← cap. 2 actual]
  3. MDP con modelo conocido       [← cap. 3 actual, sin bandits↦apéndice]
  4. Representación riesgo↔retorno [← cap. 5 actual + V1 (recíproco)]
  5. Parada bayesiana y estados de información [← cap. 5 §secuencial]

Parte II — Estimación con datos ajenos (≈65 pp)
  6. Identificación y contradicciones observables [← caps. 6,7]
  7. DM / IS / DR y eficiencia semiparamétrica     [← caps. 7,8 + Kallus–Uehara]
  8. Inferencia anytime-valid para políticas       [V3, nuevo]
  9. Políticas aprendidas: SAVE y organización secuencial [← cap. 8 actual]

Parte III — Transferencia y verificación (≈55 pp)
  10. El cálculo de certificados    [V2, formaliza caps. 6 y 9]
  11. Estudio de caso con datos reales [nuevo, §5 abajo]
  12. Frontera: agentes de lenguaje    [V4 ← cap. 12 actual]
  13. Problemas abiertos (tabla-consolidado)

Apéndices
  A. Demostraciones completas     [← apéndice actual + nuevas]
  B. Herramientas (referencia)    [← cap. 4 actual comprimido 82→~30 pp]
  C. Caso SSCH sintético completo [← caps. 2,3,5,6,7: hilo pedagógico]
  D. Protocolos de reproducción y tablas de trazabilidad código↔teorema
  E. Notación y glosario bilingüe
```

Las partes IV actuales (casos 10, despliegue 11, problemas 12) se redistribuyen:
el despliegue vive dentro del cap. 11 de M; el resto, mapeado arriba.

---

## 5. El estudio de caso con datos reales (obligatorio para "publicable")

**Open Bandit Dataset (ZOZOTOWN)**, el benchmark público estándar de
evaluación off-policy en bandits contextuales: campañas registradas con
propensiones conocidas (garantiza overlap y truth de comportamiento por
diseño), tamaño suficiente para IC serios, y comparación directa DM/IS/DR +
el estimador anytime-valid de V3. El capítulo 11 de M ejecuta el protocolo
completo que el libro predica: estimando declarado, unidad de muestreo,
condiciones conocidas por diseño vs. diagnóstico, tabla de verificación de
V2, conclusión proporcional. Sin este capítulo, M predica un protocolo que
nunca practica; con él, el capítulo es el demostrador del método.
Alternativa de respaldo: Diabetes 130-US (ya usado en `capitulo_09_isomorfismo`).

---

## 6. Reforma de C (el libro de curso) — congelar `v1.0-curso`

1. Diagnosticar y cerrar `intro.typ:89` (preexistente; PENDIENTES ordena no
   tocarlo a ciegas: se diagnostica primero).
2. Los 16 `PENDIENTE`: cerrar los 6 que son trabajo editorial mecánico
   (tablas, transiciones, apéndice G); los demás se convierten en "ítem
   abierto" con el mismo formato honesto — la convención no se abandona.
3. Unificación de etiquetas con aliases (`plantilla.typ` ya soporta
   `#chapter-alias`/`#dem-alias`): sin reescribir el cuerpo.
4. **Corregir el laboratorio insignia** `capitulo_09_isomorfismo`:
   reimplementar `functor.py` sobre la construcción del teorema (estados
   $\mathcal{X}\cup\{s_{\text{fin}}\}$, distribución inicial $P_\theta$,
   políticas $\pi:\mathcal{X}\to\mathcal{A}$, verificación integrando sobre
   $X$), o —mínimo aceptable— renombrar afirmaciones: fuera "funtor" y
   "preserva composición"; dentro "correspondencia puntual clarividente".
   La versión actual contradice el cap. 5 y verifica una tautología
   (coincidencia por pérdida lineal en θ).
5. Release `v1.0-curso` con PDF compilado limpio como puerta de salida.

---

## 7. Contrato libro ↔ código (se formaliza lo que ya funciona)

1. Toda afirmación numérica del texto tiene un script en `verificacion/`
   (convención existente; se extiende a V1–V4).
2. Todo laboratorio corre con semilla fija en `ejecutar_todos.py`;
   `resultados_laboratorios.json` se regenera y se compara, no se respeta
   por antigüedad.
3. Prohibido el laboratorio tautológico: una "verificación" debe poder
   fallar hipotéticamente (la actual `verify_isomorphism` no puede).
4. Salud del repo = `typst compile main.typ` exit 0 + `ejecutar_todos.py`
   exit 0 + `verificacion/*.py` OK; se corre antes de cada cierre de fase.

---

## 8. Plan por fases, con puertas de decisión (la parte adaptativa)

Cadencia compatible con `PLAN_AGENTICO_DIARIO_v2.md` y `REGISTRO_DIARIO.md`.

| Fase | Semanas | Contenido | Puerta de salida |
|---|---|---|---|
| **F0 — Fundación** | 1 | Instalar Typst; diagnosticar `intro.typ:89`; auditoría `.bib` contra fichas; regenerar labs en entorno fijado | Compila limpio; si no, nada sigue |
| **F1 — Canal** | 1–3 | Kit de propuesta M (6 pp + capítulo muestra V3) a FnT; en paralelo, consulta SpringerBriefs | Interés editorial → contrato FnT; sin interés en 4 sem. → SpringerBriefs; sin respaldo → ims-text/IMS |
| **F2 — Núcleo nuevo** | 2–6 | V3 completo (inglés, con labs); V2 formalizado; chequeo de literatura de V1 (2 sem. acotadas) | V1 se confirma novel → teorema propio; si es conocido → nota expositiva (decisión escrita en `REGISTRO_DIARIO`) |
| **F3 — Caso real** | 5–9 | Open Bandit Dataset: pipeline + informe cap. 11 | El informe pasa el propio checklist de V2 o no se publica la tabla |
| **F4 — Traducción** | 8–14 | Caps. 1–9 actuales → inglés, revisión humana por capítulo (el glosario bilingüe existe) | Dos lectores externos por parte |
| **F5 — Cierres** | 13–16 | `v1.0-curso` (C); envío de M | M enviada; C con PDF limpio |

**Puntos de decisión del autor (responder antes de F1):**
1. ¿Canal primario FnT (largo, prestigio, por invitación) o SpringerBriefs
   (rápido, techo ~125 pp)? La propuesta funciona para ambos.
2. ¿Confirma la doble vía (M en inglés + C en español) o prefiere
   traducir todo el curso a la larga?
3. ¿Ambición de V4: capítulo completo o sección de problemas abiertos?
4. ¿Autoriza F0 (instalar Typst en la VM y diagnosticar el fallo)?

---

## 9. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| V1 resulta conocido | Chequeo de literatura acotado a 2 semanas antes de escribir nada; degradación predefinida |
| Traducción degrada el texto | Glosario bilingüe ya existe; revisión humana obligatoria; prohibida la traducción automática desnuda |
| Rechazo editorial en cascada | Tres canales escalonados; el contenido de V2–V3 también sirve como artículos separados (arXiv) |
| Creep de alcance | La lista "lo que NO entra" (§3) es contractual; cada cambio entra por decisión escrita en `PENDIENTES.md` |
| Deuda de compilación crece con capítulos nuevos | Cada capítulo nuevo entra con su `smoke compile` (convención ya usada: `/tmp/smoke_*.pdf`) |

## 10. Criterios de éxito

- M aceptada o en segunda ronda con informes favorables a 6 meses del envío.
- C `v1.0-curso` publicada con cero `PENDIENTE` editoriales (los matemáticos
  abiertos se declaran, como siempre).
- Toda afirmación central de M con demostración en apéndice o cita verificada
  por ficha; cero prosa plausible (la regla del repo, elevada a contrato).
