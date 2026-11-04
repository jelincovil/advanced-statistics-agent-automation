# PENDIENTES — deuda declarada al cerrar `v0.2-base`

**Fecha:** 2026-09-22 · **Etiqueta:** `v0.2-base` (`ac419e9` + los commits de cierre)
**Manuscrito:** 274 pp. · `typst compile main.typ main.pdf` → exit 0, 0 warnings

Esta versión **no es un libro terminado**. Es una base: compila, tiene la
estructura final, no afirma lo que no puede sostener y —sobre todo— **declara
sus huecos en lugar de disimularlos**. Los huecos visibles son los 16 cuadros
rojos `PENDIENTE` que hay repartidos por el PDF; la lista completa, incluida la
deuda que todavía no tiene marcador, es este archivo.

Un hueco marcado es un punto de partida. Un hueco rellenado con prosa plausible
es deuda invisible. Por eso acá no se escribe nada que no esté verificado: lo
que falta se enumera, no se improvisa.

**Cerrado en la primera fase de edición:** integridad bibliográfica · H8 —la
afirmación de equivalencia de la página de apertura— · **nueve epígrafes**, por
no poder nombrar autor, obra, año y pasaje (ver §2.1) · la guía de lectura de
la Introducción y la del Prefacio · las fugas meta-textuales del cap. 11 y del
laboratorio del cap. 10 · `deployment` → «despliegue» · el §0.2 del Prefacio,
reescrito como «Estructura del libro» con las cuatro partes · las referencias
numéricas obsoletas de la Introducción, el Prefacio, el cap. 2 y el cap. 11.

---

### Agencia diaria (actualizado 2026-10-04)
- **Semana 2 día 6 (Dom 4).** Wilks (`dem:ch4-wilks`): **NO TOCAR**. Comercial Día 13: **diferido** (Caps 13–15 monorepo Causal AI **no existen** en este repo de 12 caps). SuperGrok: **omitido** — cadencia semanal cubierta Vie 2.
- T1: `insumos/cap9_ejemplo_ssch.md` — protocolo×SSCH (`thm:ch6-dr` / `ex:ssch-trazability`) + ficha Nambiar et al. 2023 (OA W4385568106 / S2 `c6e7f5097e1073f164d4c580a0b2652b882cc34e`); **AUTONOMIA 2026-10-04**; sin prosa de contribución.
- T2: Iteración Fig.3 `fig:ch9-protocolo-verificacion` (espaciado/pastillas sí-no/caption Dom 4). Smoke `/tmp/smoke_fig_ch9_proto.pdf` + `/tmp/smoke_cap09.pdf` OK.
- T3: 0 marcadores `COMPRIME` operables → AUTONOMIA en `cap05_incrustacion.typ` + `AUTONOMIA_COMPRIME_2026-10-04.md` (parcial; sin cortes).
- Extra: `INVENTARIO_RESULTADOS.md` baseline (Σ keys caps 386; sin delta COMPRIME).
- Pendiente autor: prosa §1–§3 + walkthrough SSCH; label canónico del ejemplo; Estado ↔/↝; filas FALTA; retiro `#pendiente` solo con cierre real; preguntas del insumo ejemplo SSCH.
- Sync Typst.app: **pendiente** (ver `SYNC_PENDIENTE.md` 2026-10-04).
- Compile local: FAIL preexistente `intro.typ:89` (no tocar a ciegas).


## 1. Los 16 marcadores `PENDIENTE` del PDF

> **Nota de exactitud 2026-11-03.** Esta lista es de la foto `v0.2-base`. El
> barrido de fuentes de hoy encuentra solo **4** marcadores vivos, todos en
> `apendices/apendice_reproduccion.typ` (los ítems 13–16). De ellos se
> cerraron: ítem 1 (mantenida con remisión a la canónica), ítem 3 y 12
> (cerrados materialmente por trabajo previo — transición en `cap03` y un
> solo encabezado de nivel 1 en `cap12`), ítem 6 (sección eliminada; cero
> referencias externas), escenarios/métricas/versión del Apéndice G
> (transcritos y verificados contra el artículo y el commit `7533c28` del
> repo SAVE). Sigue vivo: el de resultados del Apéndice G, ahora puramente
> *ejecución* de Fase 4 (diseño fijado).



| # | ubicación | qué falta ahí | §INFORME_FASE2 |
|---|---|---|---|
| 1 | `capitulos/intro.typ:100` | La Tabla 0.1 es el anticipo que queda de las tres versiones de la tabla de correspondencias (la canónica es la del cap. 5). Decidir si se mantiene o se reduce a una remisión. | §4.9 |
| 2 | `capitulos/cap02_wald.typ:510` | El capítulo termina con **tres** secciones anexadas que no son de su arco: dos anticipos de la correspondencia (desde los caps. 1 y 4 originales) y «El Modelo Estadístico como Modelo del Mundo», que pertenece al cap. 9. | §4.10 |
| 3 | `capitulos/cap03_mdp.typ:539` | El capítulo perdió su §«Conexión con el `@ch:isomorfismo`» (viajó al cap. 5) y quedó **sin transición de cierre**. | §4.11 |
| 4 | `capitulos/cap04_herramientas.typ:2828` | Un solo bloque de ejercicios, pero **sin curar**: siguen los de los seis capítulos fusionados, incluidos los que apuntan a resultados que ya no están en el cuerpo. | §4.3 |
| 5 | `capitulos/cap04_herramientas.typ:3097` | Una sola lista de lecturas, pero **sin depurar**: concatenación de las seis listas, con citas en prosa sin entrada en el `.bib`. | §4.2 |
| 6 | `capitulos/cap04_herramientas.typ:3247` | §«Tests de Hipótesis Bayesianos»: eliminación **aprobada** y diferida. No se puede borrar todavía porque el texto cita `@def:ch4-bayes-factor`. | §3 |
| 7 | `capitulos/cap05_incrustacion.typ:238` | §«Transferencia de Resultados» y §«Preservación de Propiedades» **mezclan teoremas y conjeturas**; el reparto fino exige cortar dentro de las secciones. | §4.8 |
| 8 | `capitulos/cap06_fallos.typ:14` | El capítulo no desarrolla los «seis mecanismos de fallo» ni la degeneración de la tricotomía bajo MA+CMIA que anuncia su título. | §4.7 | **CERRADO 2026-11-04:** los mecanismos L1–L6 desarrollaban con ejemplos computados (L1 memoria, L2 filtro oculto, L3 horizonte, L4 confusión, L5 overlap, L6 auxiliares) y la tricotomía con un ejemplo de dominancia igual. MA/CMIA quedaban como siglas antiguas no formales; la desambiguación aplicada dice exactamente eso y formaliza las dos formulaciones explícitas, no la sigla. |
| 9 | `capitulos/cap09_verificacion.typ:15` | **Veinte tablas…** — estado **parcial** (2026-10-02): `tab:trazabilidad-canonica` ya existe (`#include`); inventario real = 13 ≠ 20; faltan andamiaje §1–§2, depuración de tablas fuente, Estados ↔/↝ y cierre FALTA 28. `#pendiente` **no** retirado. | §4.4 | **CERRADO 2026-11-04:** el protocolo define el dictamen de cuatro estados; las marcas de filas («↔»/«↝»/no marcada) se explican honestamnte como acompañantes del lector, nunca sustituyéndola. La tutela canónica con sus 13 filas queda con la nota de nomenclatura efectiva. |
| 10 | `capitulos/cap10_casos.typ` | Índice destino F.1–F.12 **hecho** (2026-09-27). Queda: andamiaje narrativo SSCH + *movimiento físico* labs → caps (Fase 3). | §4.5 | **SIN CAMBIO 2026-11-04:** el capítulo ya contiene la arquitectura SSCH, los doce laboratorios numerados `lab:F1…` y el índice de rutas; el "movimiento físico" de labs es decisión editorial no deudora. |
| 11 | `capitulos/cap11_despliegue.typ:18` | **Esqueleto**: solo títulos y párrafos de alcance. | §4.12 | **CERRADO 2026-11-04:** era foto obsoleta; el capítulo actual tiene cuatro protocolos, un MDP de validación con números verificados (V_inf y v_0 verificados a mano), tabla de cobertura con MCSE, monocado mixing con remisión `@lab:F11`→`ex:ch9-fallo-mixing`, y cierre de ficha. Las cifras del texto verifican exactamente. |
| 12 | `capitulos/cap12_problemas.typ:21` | **Dos capítulos apilados** (fronteras + problemas abiertos), con dos cierres. | §4.6 |
| 13-16 | `apendices/apendice_reproduccion.typ:64, 86, 94, 183` | Apéndice G (reproducibilidad): definición de los escenarios A/B/C, definición exacta de las métricas y número de réplicas, tablas de resultados vacías, y la versión exacta de la implementación pública de `SAVE` (el repositorio ya está verificado: `https://github.com/shengzhang37/SAVE`). | 2D |

**Resolución de las 12 transiciones de `INFORME_FASE2.md` §4:** 1 resuelta
(§4.1, los seis arranques del cap. 4 → una epígrafe y un párrafo), 2 resueltas
a medias y marcadas (§4.2, §4.3) y 9 marcadas (§4.4-§4.12).

---

## 2. Deuda de integridad (revisar **antes** de mostrar el manuscrito afuera)

### 2.1 Epígrafes y atribuciones

Regla aplicada: **un epígrafe se queda solo si se puede nombrar autor, obra y
año y localizar el pasaje.** Estado tras el barrido.

**Se retiraron (nueve):** Pearson, 1892 · Mac Lane, 1971 · Shi, Zhang, Lu &
Song, 2022 · Kant («Adaptado de», cap. 12) · dos de Yogi Berra duplicadas
(cap. 10) · la frase del cap. 11 atribuida a «Adaptado; véase la nota
metodológica del prefacio» (pasó a la prosa del capítulo) · la cita de Dudík,
Langford & Li en la divisoria de la Parte III (el cap. 7 ya la lleva) · el
epígrafe apócrifo del cap. 9 («Adaptado de Wald-Bellman-Puterman», Fase 1).

**Quedan cinco sitios, con tres obras.** Todos enlazados al `.bib` (antes
estaban en prosa y no aparecían en la bibliografía):

| obra | sitios | estado |
|---|---|---|
| Bellman (1957), *Dynamic Programming* | `main.typ` (frontmatter), `cap03_mdp.typ:11` | **canónico y trazable.** Entrada `.bib` creada: `bellman1957dynamic` |
| Wald (1950), *Statistical Decision Functions* | `cap02_wald.typ:10`, `cap04_herramientas.typ:30` | **pasaje no localizado** — ver abajo |
| Dudík, Langford & Li (2011) | `cap07_ope.typ:10` | **pasaje no localizado** — ver abajo |

**Dos banderas nuevas, levantadas al verificar los epígrafes que se
conservaban** (decisión del autor: conservarlos y enlazarlos; la evidencia que
sigue no los retira, pero conviene saberla):

- **Dudík et al. (2011).** La oración del epígrafe —«The doubly robust
  estimator combines the best of both worlds: low variance from the model,
  unbiasedness from importance sampling»— no aparece en el artículo. Su texto
  real dice otra cosa («Doubly robust estimators take advantage of both the
  estimate of the expected reward…», «DR can effectively take advantage of both
  sources of information for better estimation»), y la fórmula «gets the best
  of both worlds» es de Jiang & Li (2016). Es una glosa entre comillas: el
  mismo vicio que el epígrafe del cap. 8.
- **Wald (1950), los dos.** Ninguna búsqueda del texto exacto de las dos
  oraciones encuentra la fuente; lo que se encuentra son paráfrasis modernas
  del marco de Wald (Manski, 2019, entre otras). No son verificables como citas
  textuales con los medios usados. Evidencia más débil que la del caso anterior
  (los libros de 1950 no están indexados palabra por palabra).

**Corrección de método (importante).** La verificación que retiró el epígrafe
del cap. 8 se apoyaba en un **falso negativo**: se buscó literalmente
«infinite-horizon» sobre el texto de `pdftotext` y dio 0 ocurrencias cuando la
palabra está en el título del artículo. Causa: el PDF corta palabras con guion
al final de línea, de modo que la cadena literal no existe en el texto
extraído. La conclusión no cambia —la oración sigue sin estar en el artículo—
pero la evidencia se rehízo con normalización (unir palabras cortadas, colapsar
espacios, ignorar mayúsculas) y prueba de control:
`infinite-horizon` → 4 · `reinforcement learning` → 22 · la oración del
epígrafe → 0. La herramienta queda en `tools/verificar_cita.py` para no repetir
el error en la dirección contraria (dar por inexistente una cita que sí existe).

**Citas en prosa en las listas de lecturas** (mismo problema, en otro formato):
Basu (1955) · Schervish (1995) · Cramér (1946) · Holm (1979) · Billingsley
(1995) · Hall (1992) · Dudík et al. (2011) · DeGroot (1970) · Bellman (1957) ·
Bertsekas (2012) · Rust (1994) · Athey & Wager (2021) · Jiang & Li (2016) ·
Thomas et al. (2015) · Liu et al. (2018) · Newey & West (1987) · Bradley
(2005). Varias **duplican** obras que sí están en el `.bib` bajo otra clave.

### 2.2 Referencias numéricas obsoletas

Corregidas (todas reemplazadas por referencias cruzadas, que Typst renumera
solas si la estructura vuelve a cambiar):

- `intro.typ` — la guía de lectura entera (5 bloques) y «Capítulo~11» → el
  capítulo de intervalos y el catálogo A1-A5 del apéndice E.
- `prefacio.typ` — la guía de navegación, «(Teorema~9.3)» → `@thm:ch9-isomorfismo`
  y «Capítulo~9 (§9.1.9)» → el capítulo que cataloga los fallos.
- `main.typ` — «Capítulo 9» de la divisoria de la Parte III.

Pendientes (fuera del alcance de esta fase, sin tocar):

- `cap01_dos_tradiciones.typ:137,139` — «(Capítulos~12--13)» y «§13.3--13.4».
- `cap03_mdp.typ:369`, `cap05_incrustacion.typ:139` — «§13.4».
- `apendices/apendice_tablas.typ:131` — «§11.2».
- **Nueve rótulos de tabla** «Trazabilidad Capítulo~N» (`cap02:375`,
  `cap03:521`, `cap05:637`, `cap09:235,390,509,595,658,722`): usan la
  numeración vieja para identificar tablas que hoy viven en otros capítulos.
  Se resuelven al consolidar las veinte tablas (§1, marcador 9).

### 2.3 Claves huérfanas del `.bib`

Medición de `v0.2-base` (regex sobre `#cite(<…>)` y `@clave` en todos los
`.typ`): **111 claves en el `.bib`, 56 citadas, 55 huérfanas.** La cifra no es
comparable con la de la Fase 1 (69 de 123) porque allí el `.bib` tenía 14
entradas más —los placeholders eliminados— y el conteo se hizo con otro
método. La decisión sigue siendo no tocarlas: una bibliografía más amplia que
las citas es aceptable en una monografía. Al enlazar los epígrafes, una huérfana
menos (`dudik2011doubly`).

### 2.4 `@ch:introduccion` no es referenciable

El capítulo 0 no está numerado, así que su etiqueta no resuelve. Donde haga
falta referirlo, usar prosa («la Introducción»).

---

## 3. Deuda de contenido, por fase

### Fase 3 — redacción y compresión (el trabajo grande)

- **Apéndice A** (`apendices/apendice_demostraciones.typ`, 1 883 líneas):
  clasificar cada demostración en `(a)` demuestra un resultado vivo / `(b)` no
  reproducible desde una referencia estándar / `ambas` / `ninguna`, y ejecutar
  solo las `ninguna`. Ante duda: marcar `(b)` y conservar. Las pruebas de
  Rao-Blackwell, Lehmann-Scheffé, Cramér-Rao y Neyman-Pearson están
  pre-autorizadas para eliminación (están en Casella-Berger).
- **Cuatro bibliografías comentadas por Parte** (enmienda del autor: una por
  Parte, al cierre de cada una; no doce listas de tres ítems). Incluye verificar
  que ninguna apunte a obras dadas de baja en Fase 1 y absorber las listas
  actuales de capítulos 2, 3, 4, 5, 7, 8 y 12.
- **Compresiones `COMPRIME`**: las secciones marcadas así en
  `MAPA_ESTRUCTURA.md` se movieron enteras y todavía no se comprimieron.
  Criterio: sobrevive lo que se usa después. De 320 resultados etiquetados en
  los caps. 1-6, solo 41 se invocan desde el resto del libro.
- **Transiciones de los 16 marcadores** (sección 1 de este archivo).
- **Bloques «PENDIENTE DE EXTRACCIÓN»** que quedaron en los capítulos:
  `cap04_herramientas.typ:3238` (la §bayesiana, ya marcada),
  `cap05_incrustacion.typ:596` (cuatro secciones al final: Arquitectura
  Trazable, Garantías Heredadas, Trazabilidad, Hilo SSCH) y
  `cap06_fallos.typ:227` y `:340`. Decidir si el destino anotado es el archivo
  donde ya están (y retirar la marca) o si hay que moverlos.
- **`apendices/apendice_langgraph.typ`**: marcado `PENDIENTE-CAP11`. La
  inclinación del autor es no citarlo (atarse a la API de una biblioteca es
  comprarse obsolescencia), pero se decide cuando el cap. 11 tenga forma.
- **Duplicación Prefacio ↔ Introducción**: el Prefacio repite la tesis, los
  prerrequisitos, la filosofía y una guía de lectura. El §0.2 ya está
  reescrito; la decisión de fondo —si el Prefacio conserva sus secciones o
  queda reducido a lo que no está en la Introducción— sigue abierta.
- **Laboratorio del cap. 10**: el `#chapter-alias("app:laboratorio")` conserva
  la etiqueta heredada y los rótulos internos (`F.1-F.12`) son del apéndice
  absorbido. Se resuelve al repartirlo.

### Fase 4 — evidencia numérica

- **Apéndice G**: escribir el código de la replicación y llenar las tres tablas
  (escenarios A, B, C; ECP, AL, log(MSE); grilla $n \in \{25,50,100\}$,
  $T \in \{30,50,70\}$, $\gamma = 0.5$, $L = \lfloor (nT)^{3/7}\rfloor$).
  Ver `FUENTES.md` para la fuente primaria.

### Hallazgo estructural (decisión de fondo, no de redacción)

El libro dedica un capítulo al teorema de Shi et al. y **no tiene ningún
anclaje en datos reales**: todo su aparato empírico es el ejemplo sintético
SSCH. La solución adoptada es el apéndice G (replicación de simulación
reproducible, sin problemas de gobernanza de datos). El reanálisis del dataset
real queda descartado: exige un acuerdo de uso con la institución que lo
mantiene.

---

## 4. Deuda menor / higiene

- `referencias.aux|.log|.fls|.fdb_latexmk` en la raíz: residuos de una
  verificación externa con LaTeX. Están en `.gitignore`; se pueden borrar del
  disco cuando molesten.
- `_dev_stub.typ` / `_dev_stub.pdf`: stub de desarrollo, no incluido en
  `main.typ`. Versionado a propósito (ver `.gitignore`).
- `main.pdf`: artefacto de compilación, ignorado por git.
- Los scripts de migración y el verificador de citas viven en `tools/`
  (ver su `README.md`).
- Apellido de Yogi Berra: las dos epígrafes se retiraron, pero si vuelve a
  usarse una cita suya, la atribución a Berra está **disputada** (suele
  asignarse a Jan van de Snepscheut).

---

## 5. Registro de lo verificado (no hace falta re-verificar)

- **Shi, C., Zhang, S., Lu, W. & Song, R. (2022).** *Statistical inference of
  the value function for reinforcement learning in infinite-horizon settings.*
  JRSS-B 84(3):765-793. DOI `10.1111/rssb.12465` (confirmado en la cabecera del
  PDF: recibido 28-nov-2019, aceptado 17-jun-2021). Ver `FUENTES.md`.
  Datos verificados: 6 pacientes de OhioT1DM · ocho semanas · intervalos de 3 h
  · estado tridimensional · acción binaria (insulina > 1 unidad) · recompensa
  vía *Index of Glycemic Control* (Rodbard 2009) · $\gamma = 0.5$. Las pruebas
  del Teorema 1 en el artículo impreso son un **esquema** (Apéndice E.1); el
  detalle está en el suplemento en línea. El artículo **no** trata confounding
  no observado, y **no** contiene la oración que el cap. 8 le atribuía.
- **Implementación pública de `SAVE`** (dato verificado en el resumen del
  artículo, disponible para cerrar el marcador 16 del apéndice G):
  «A Python implementation of the proposed procedure is available at
  https://github.com/shengzhang37/SAVE». Del texto extraído del PDF hay que
  quitar los caracteres de ancho cero que introduce el corte de línea
  (`sheng\u200bzhang\u200b37` → `shengzhang37`).
- **El SSCH es sintético**: declaración completa en su primera aparición
  (`cap01_dos_tradiciones.typ`), cuatro cajas `#ejemplo-sintetico` y 26 marcas
  inline `(sintético)` en el PDF.
- **Convención de símbolos**: `↔` exacto dentro del alcance demostrado, `↝`
  transferencia condicional, `---` sin correspondencia.
- **El alcance de la tesis**: incrustación fiel `Dec → MDP`, **un paso y
  determinista** (Teorema 9.3 de la numeración antigua). La extensión
  estocástica general es problema abierto declarado (Nota 9.4).
- **Letras de los apéndices** (verificadas en el índice del PDF): A
  Demostraciones · B Glosario · C LangGraph · D Fundamentos medido-teóricos ·
  E Tablas de correspondencia · F Condiciones de regularidad y mixing ·
  G Reproducibilidad.
- **Estructura**: cuatro partes. Introducción y cap. 1 antes de la Parte I;
  Parte I = caps. 2-4 · Parte II = caps. 5-6 · Parte III = caps. 7-9 ·
  Parte IV = caps. 10-12.


## Cerrados recientes
- [x] 2026-09-25: survey 2502.16195 ficha+matriz; PODA_NINGUNA_PROPUESTA (Wilks no borrado); cap4 asintótica AUTONOMIA; Comercial D4 diferido
- [x] 2026-09-24: Luo NeurIPS2025 ficha + Ap.A último tercio (a:8 b:1) + informe consolidado + cap4 AUTONOMIA suficiencia + CITAS_PROSA caps1-4
- [x] 2026-09-23: NSAVE + Ap.A segundo tercio + cap3 AUTONOMIA
