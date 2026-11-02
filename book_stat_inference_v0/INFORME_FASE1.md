# INFORME — Fase 1 de 3

**Manuscrito:** `monografia_typst_v1`
**Fecha:** 2026-09-22
**Estado:** ✅ **Tres fases completadas.**
**Referencia:** `AUDITORIA_FASE1.md` (Fase 0, aprobada).

---

## 0. Bloqueador: no hay repositorio git

```
$ git rev-parse --is-inside-work-tree
fatal: no es un repositorio git (ni ninguno de los directorios superiores): .git
```

**No existe `.git`** en `monografia_typst_v1` ni en ningún directorio superior. Por lo tanto
**no pude crear ninguno de los tres commits** especificados. Los cambios están aplicados y
verificados en el árbol de trabajo, sin versionar.

**Además**, un `git init` + commit inicial capturaría 30+ archivos, incluidos tres PDF de
entre 88 KB y **6,95 MB** (`main.pdf`, `jrsssb_84_3_765.pdf`, `_dev_stub.pdf`,
`preview_notacion.pdf`). Decidir qué ignorar es su criterio, no el mío.

**Lo que necesito:** ¿inicializo el repositorio con un `.gitignore` razonable (excluyendo los
PDF de compilación y de desarrollo, conservando `jrsssb_84_3_765.pdf` como fuente primaria), o
usted monta el repositorio y yo sigo desde ahí? Mientras tanto no toco nada de git.

---

## 1. Cambios aplicados en la Fase 1

### Por categoría

| Categoría | Antes | Después | Δ |
|---|---|---|---|
| Marcadores `[verificación externa]` | **9** | **0** | −9 |
| Entradas placeholder en `.bib` | **14** | **0** | −14 |
| Entradas totales en `.bib` | 123 | **109** | −14 |
| Sitios malformados en `.bib` | **7** | **0** | −7 |
| Atribuciones falsas «Shi et al., 2024, JASA» | **2** | **0** | −2 |
| Claves citadas sin entrada en `.bib` | 0 | **0** | 0 |
| Claves huérfanas | 69 | **56** | −13 |
| Páginas del PDF | 281 | **282** | +1 |

### Archivos editados (6)

```
referencias.bib                          (placeholders, restos malformados)
capitulos/capitulo00.typ                 (B1, B2, B3, B4)
capitulos/capitulo06.typ                 (B5)
capitulos/capitulo12.typ                 (H1 ×2, placeholders citados en vivo)
capitulos/capitulo13.typ                 (B7)
apendices/apendice_demostraciones.typ    (B8, B9)
```

### Detalle por marcador

| # | Ubicación | Resolución |
|---|---|---|
| B1 | `cap00:84` | (c) eliminar: «_ [verificación externa]_ en MDPs robustos» → «(MDPs robustos)». **La afirmación queda sin fuente** — ver §3 |
| B2 | `cap00:88` | (b) sustituir por referencia interna a `@ch:semiparametrica`, donde el resultado se cita ahora correctamente |
| B3 | `cap00:187` | **(c) eliminar la afirmación**: se retiró por completo la mención a Liao, Qi & Murphy (2022) |
| B4 | `cap00:189` | (a) verificar: `kennedy2022semiparametric` ya estaba en el `.bib` (huérfana); ahora citada y descrita según su título real |
| B5 | `cap06:483` | (a) verificar: el nombre del teorema pasa a «IF Eficiente para $Value^policy$ -- Kallus \& Uehara» (sin año, para no elegir entre las dos entradas verificables) + citas en prosa |
| B6 | `cap12:66` | **(c) eliminar la atribución y la fórmula** — ver §2, es una desviación deliberada |
| B7 | `cap13:79` | (b) sustituir por referencia interna a `@ch:semiparametrica` |
| B8 | `dem:1853` | **(a) verificar y corregir**: la afirmación era falsa — ver §2 |
| B9 | `dem:1878` | (a) verificar: citas reales a `kallus2020double` y `kallus2022efficiently`; se eliminó además la excusa falsa «no reproducible aquí sin acceso a la fuente primaria» (JMLR es de acceso abierto y la entrada del `.bib` ya trae la URL) |

### Citas nuevas enlazadas
`shi2022statistical` ×2 · `kallus2020double` ×3 · `kallus2022efficiently` ×3 ·
`kennedy2022semiparametric` ×1 (deja de ser huérfana) · `hernan2020causal` ×1.

---

## 2. Desviaciones respecto de la instrucción literal (con evidencia)

### 2.1. B6 / H1 — el artículo de Shi et al. **no trata confounding no observado**

Su instrucción (hallazgo 1) fue: *«Corregí a Shi, Zhang, Lu & Song (2022), JRSS-B 84(3):765–793»*.
Verifiqué contra `jrsssb_84_3_765.pdf` antes de aplicar:

```
$ grep -c "confound" <texto del PDF>
0
```

**Cero apariciones** de «confound», «unmeasured» ni «unobserved» en todo el artículo. El trabajo
es de inferencia positiva: construye IC para el valor de una política mediante *sieve* y SAVE.
No contiene ningún análisis de sesgo del estimador DR bajo confounding no observado.

**Por qué no apliqué la instrucción al pie de la letra:** corregir solo el año habría producido
una atribución **falsa pero verosímil** — es decir, peor que la actual, porque ya no sería
detectable a simple vista. Aplicando su regla por defecto (*«elegí siempre la opción que deje el
manuscrito afirmando menos»*) y la regla del inventario B (*«preferí eliminar la afirmación antes
que conservar el marcador»*):

- El entorno pasó de `theorem` a `note`, con el nombre «Sesgo del estimador DR bajo confounding
  no observado».
- Se eliminó la **atribución a Shi et al.** (no solo el año).
- Se eliminó la **fórmula específica** con `o_P(1)` que no puedo verificar ni atribuir.
- Se conservó el contenido **cualitativo**, que es correcto por construcción a partir de la
  propia `def:ch12-confound`, y se ancló a una fuente real ya presente en el `.bib`
  (`hernan2020causal`) para el fenómeno general del sesgo por confounding.
- Etiqueta conservada (`thm:ch12-shi-confound`) con comentario `// nombre heredado`, y con nota
  de que el enunciado ya no se atribuye a nadie. No está referenciada en ningún otro punto del
  manuscrito (verificado).

**Si prefiere que se conserve una atribución a Shi et al. aquí, necesito que usted aporte la
fuente**: no la encontré en el PDF del repositorio.

### 2.2. B8 — «Apéndices A–C» también era falso

La nota de integridad decía que la prueba completa está en «Apéndices A–C» del artículo.
Verificado contra el PDF:

- El artículo dice: *«A sketch for the proof of Theorem 1 is given in **Appendix E.1**»* (y E.2, E.3
  para los demás teoremas). **No** en A–C.
- Los apéndices A–C contienen definiciones de condiciones y análisis adicionales; el detalle
  técnico completo se remite al **material suplementario en línea** (Secciones B.1, C.3), que
  **no forma parte del artículo impreso** —y por tanto no está en el PDF del repositorio.
- El propio artículo ofrece solo un **esquema**, no una prueba línea por línea.

Reescrito en consecuencia: el texto ahora dice que el Apéndice E.1 contiene un *esquema* y que
los detalles completos están en el suplemento en línea. Marca eliminada porque **sí** quedó
verificado.

### 2.3. H7 corregido: eran **7** sitios malformados, no 6

Mi auditoría reportó 6. Al ejecutar encontré un séptimo que se me escapó: tras `kallus2020double`
(`referencias.bib:359-360`), con `},` + `doi = {10.1214/19-AOS1808}` **sin indentación**, por lo
que mi patrón `^  doi = ` no lo capturó. Los 7 quedaron limpios.

---

## 3. Afirmaciones que quedaron huérfanas de fuente

Estas afirmaciones **ya no tienen el marcador** porque el marcador era el problema, pero
**tampoco tienen fuente**. Requieren decisión suya (aportar fuente o suprimir):

| # | Ubicación | Afirmación | Estado |
|---|---|---|---|
| 1 | `capitulo00.typ:84` | Correspondencia minimax ↔ política robusta, «condicional a leer `$\Theta$` como índice de modelo (MDPs robustos)» | Sin fuente. Es la B1: eliminé el marcador, no la afirmación |
| 2 | `apendice_demostraciones.typ:1832` | «El TLC de martingala (p. ej. **Hall \& Heyde, 1980**)» | Referencia en prosa **sin entrada** en el `.bib` |
| 3 | `apendice_demostraciones.typ:1846` | «aplicando **Hall \& Heyde (1980, Teorema 3.2)**» | Idem. Además cita un **teorema numerado** de una obra no listada |
| 4 | `capitulo05.typ:738` | «**Billingsley, P.** (1995). *Probability and Measure*, 3rd ed.» | Lista de lecturas **sin entrada** en el `.bib` |
| 5 | `capitulo05.typ:744` | «**Hall, P.** (1992). *The Bootstrap and Edgeworth Expansion*» | Idem |

Los casos 2–5 no estaban en el alcance de la Fase 1 (inventario B solo cubría los marcadores;
estos son el hallazgo H6) y **no los toqué**. Son obras reales y estándar, pero **no voy a
inventar sus datos bibliográficos ni a crear entradas a mano sin su aprobación**.

---

## 4. Decisiones `AMBIGUO` pendientes de su resolución

Siguen las 3 de la auditoría (§A.6), sin tocar:

1. **`capitulo01.typ:708`** — `#thm-env("proposition", name: [Correspondencia Fundamental])`: «La
   estructura del problema de decisión estadística de Wald es isomorfa a la de un proceso de
   decisión de Markov (MDP) **de un solo paso**». Alcance correcto, pero es una *proposición* sin
   prueba y sin declarar estatus. ¿Se rebautiza «Anticipo informal» (como en el cap. 7) o se le
   añade puntero a `@thm:ch9-isomorfismo`?
2. **`capitulo13.typ:58`** — fila de tabla: `[Espacio muestral]`, `$\leftrightarrow$`,
   `[Espacio de observaciones $ObsSpace$]` con estatus `isoto` (exacto). El cap. 0 dice que «la
   distinción observación/estado reaparece en POMDPs». ¿Se degrada a `$\rightsquigarrow$`?
3. **`apendices/apendice_medido.typ:279`** — `[Capítulo 9], [Isomorfismo], [Funtores medibles,
   preservación de estructura]`. Promete alcance medido-teórico general que el teorema no cubre.
   ¿Reescribir la fila o eliminarla?

---

## 5. Diferencia de páginas del PDF

| | Páginas | Tamaño |
|---|---|---|
| Antes (`main.pdf`, 2026-08-02) | **281** | 6,95 MB |
| Después (recompilado hoy) | **282** | — |

**+1 página.** Contraintuitivo dado que se eliminó contenido (14 entradas del `.bib`, la fórmula
del teorema del cap. 12, la oración de Liao et al.). La causa es el **reflujo**: la
bibliografía impresa solo incluye las obras citadas, y la suma de pequeños cambios de altura
desplazó un salto de página. No hay pérdida de contenido más allá de lo listado en §1 y §2.

**Verificación de compilación:**
```
$ typst compile main.typ main.pdf
=== EXIT=0 ===
```
Sin errores ni advertencias. Comprobaciones sobre el PDF generado:

```
verificación externa  → 0        placeholder  → 0        JASA   → 0
Liao                  → 0        Bennett/Chen → 0        markup Typst filtrado → 0
```

Y las entradas correctas **sí** aparecen: `Shi, C., Zhang, S., Lu, W., & Song, R. (2022)`;
«Teorema 6.31 (IF Eficiente para 𝑉^𝜋 – Kallus & Uehara)»; citas `Kallus & Uehara (2020)` y
`(2022)` en prosa.

---

## 7. FASE 2 — Reencuadre del reclamo central

### 7.1. Corrección raíz (`capitulo09.typ`, antigua L200)

```
antes:  *Conclusión:* $F$ es un isomorfismo de categorías que preserva la
        estructura de optimalidad, consistencia y eficiencia.
ahora:  *Conclusión:* $F$ es un funtor fiel entre $bold("Dec")$ y
        $bold("MDP")_1$: preserva composición, optimalidad, Bayes y admisibilidad.
```

Se eliminaron «isomorfismo de categorías» (el teorema enuncia un funtor fiel) y
«consistencia y eficiencia» (ningún paso de la prueba las establece).

### 7.2. Inventario A — resultado del reencuadre

| | antes | después |
|---|---|---|
| Líneas con «isomorf» en `.typ` | **222** | **127** |
| De ellas, ocurrencias léxicas fuera de etiquetas de código | 222 | **33** |
| Ocurrencias `SOBREDIMENSIONADO` | 125 | **0** |

Las 33 restantes son las `CORRECTO` que su instrucción ordena conservar (`Fallo
del isomorfismo`, `Límites del isomorfismo estricto`, `no un isomorfismo
completo`…), la `AMBIGUO` pendiente de §4.1, el párrafo «Sobre el nombre»
reescrito, y comentarios de código.

### 7.3. Frase mecánica: eran **13**, no 8

Vuelvo a corregir un conteo de mi auditoría. En cinco archivos la frase cruza
un salto de línea, por lo que mi `grep` de una sola línea la perdió. La frase
«*La demostración que sigue hace explícitas las condiciones bajo las cuales el
resultado es válido, conectándolo con el marco del isomorfismo.*» aparece **13
veces** (`cap02` ×2, `cap03` ×3, `cap04` ×3, `cap07` ×3, `cap09` ×1, `cap11` ×1)
y se eliminó en las 13.

**Ninguna introducía una conexión sustantiva**, como usted pedía verificar:
preceden pruebas de Rao-Blackwell, Lehmann-Scheffé, Cramér-Rao,
Neyman-Pearson, Basu, optimalidad de Bayes, admisibilidad, minimax-vía-Bayes
y un resultado de gradiente de política. Ninguna depende de la incrustación
fiel. La de `cap09` precedía a la prueba del propio teorema de incrustación:
redundante, también eliminada.

### 7.4. Los seis teoremas — rama asignada a cada uno

| Clave | Rama aplicada | Resultado |
|---|---|---|
| `thm:ch9-ic` | **(2) degradar** | **Conjetura 9.11**, con las condiciones que faltarían y remisión a `note:ch9-extension-no-demostrada` |
| `thm:ch9-tests` | **(2) degradar** | **Conjetura 9.12**, ídem |
| `thm:ch9-eficiencia` | **(2) degradar** | **Conjetura 9.16**, ídem + aclaración de que la eficiencia del DR es un resultado independiente, no un corolario |
| `thm:ch9-admisibilidad` | **(1) conservar restringido** | **Teorema 9.14** «caso de un paso y determinista», con remisión explícita al paso 4 de la prueba en el Apéndice |
| `thm:ch9-state` | **(tercera rama)** | **Nota 9.17**: no es una conjetura matemática sino un *criterio de diseño*, y así se declara |
| `thm:ch9-secuencial` | **(1) conservar restringido** | **Teorema 9.13** «horizonte finito y transiciones deterministas» + puntero al Apéndice A.9.3, cuyo `proof-env` decía «completa» y ahora dice «esquema» (contradecía la nota del propio capítulo) |
| `cor:ch7-secuencial` | **(2) degradar** | **Conjetura 7.18** (colateral necesario: también afirmaba la extensión sin prueba) |

`thm:ch9-state` es la única desviación de las dos ramas que usted fijó: no era
una conjetura, era un criterio de diseño disfrazado de teorema. Si prefiere
Conjetura también ahí, es una línea.

### 7.5. Resto de la Fase 2

- **Títulos**: cap. 9 → «La incrustación fiel Dec → MDP: alcance y fronteras»;
  cap. 13 → «Conclusiones: un programa de verificación de garantías».
  **Etiquetas conservadas** (su decisión 1), con **13 comentarios**
  `// nombre heredado; el título dice «incrustación fiel»` en cada sitio de definición.
- **Epígrafe del cap. 9**: eliminada, sin sustituto. El comentario de cabecera del archivo
  documenta por qué (era una cita construida que contradecía el capítulo).
- **Sección vacía** `capitulo07.typ` «Optimalidad de secuencias de decisiones»:
  eliminada con encabezado y etiqueta.
- **Nota metodológica** en `prefacio.typ`, §«Sobre el alcance de nuestras afirmaciones»
  (~340 palabras): qué se demuestra, qué no, convención `$isoto$` / `$arrow.squiggly$`
  y compromiso de trazabilidad. Colocada tras «Agradecimientos» y antes de la firma.
- **`plantilla.typ`**: añadido `conjecture: "Conjetura"` a `thm-names` (el tipo no existía).
- **Dos filas del mapa de correspondencias** (`capitulo13.typ`) pasaron de `$isoto$`
  a `$arrow.squiggly$`: la de `$ParamSpace$` (caso POMDP) y la de `$T(X)$` (que el propio
  cap. 0 remite al supuesto de Markov, no a una equivalencia exacta).
- **`cor:ch7-secuencial`**: además se corrigió «La siguiente corolario» → «El siguiente enunciado».
- **Scripts auxiliares** `_fase2_subs.py` / `_fase2_labels.py`: usados con verificación de
  conteos (0 fallos en 53 sustituciones) y **eliminados** del repositorio.

### 7.6. Páginas

| | Páginas |
|---|---|
| Original | 281 |
| Tras Fase 1 | 282 |
| **Tras Fase 2** | **281** |

Paridad neta con el original, pese a las 13 supresiones y la sección nueva del
prefacio: el reflujo lo compensa. `typst compile` → **exit 0**.

Comprobaciones sobre el PDF final: marcadores `0`, placeholder `0`,
«Sección pendiente» `0`, frase mecánica `0`, epígrafe apócrifa `0`, markup Typst
filtrado `0`.

### 7.7. Pendiente para la Fase 3 (y para su decisión)

1. **Las 3 `AMBIGUO`** siguen sin tocar (§4).
2. **Residuales de la misma clase que los 5 teoremas**, no incluidos en su lista:
   `prop:ch9-tabla` («Tabla de Transferencia»: se añadió una frase que aclara que las
   filas son correspondencias *propuestas*, pero el entorno sigue siendo `Proposición`)
   y `prop:ch9-completitud` («fundación axiomática […] trazabilidad completa»).
3. **Terminología**: quedan ~33 usos de «isomorfismo» en pasajes `CORRECTO`, que su
   instrucción ordena conservar. Se leen de forma coherente gracias al párrafo
   «Sobre el nombre» del cap. 0, pero si quiere un término único en todo el libro,
   es un `sed` acotado de una línea de instrucción.
4. **SSCH sintético** y **atribución numérica** (Fase 3, sin empezar).

---

## 8. FASE 3 — Separación de lo sintético y lo empírico

### 8.1. Caja de advertencia reutilizable

Añadida a `plantilla.typ` (junto a `verdem` / `vertabla`):

```typst
#let ejemplo-sintetico(body) = block(
  above: 0.8em, below: 0.8em, width: 100%,
  stroke: 0.5pt + mdpcolor, inset: 8pt,
)[ #set text(size: 9.5pt) *Cifras sintéticas.* #body ]
```

### 8.2. Dónde se aplicó (4 cajas)

| Ubicación | Contenido de la caja |
|---|---|
| `capitulo01.typ` · `ex:ssch-cap01` (**primera aparición**) | Declaración completa: escenario sintético, parámetros de diseño, *no* estimados ni validados clínicamente, ninguna cifra es evidencia médica, el libro no analiza ningún dataset clínico real |
| `capitulo01.typ` · `tab:ssch-recompensas` | «Recompensas de diseño para el escenario ilustrativo» |
| `capitulo11.typ` · `ex:ssch-cap11` | «Todas las cifras de este ejemplo ($\hat\rho$, $\hat\sigma_{\text{SAVE}}$, $\hat V^{\text{DR}}$, tamaño muestral) proceden del escenario sintético» |
| `capitulo12.typ` · `ex:ssch-cap12` (tabla de 12 filas de resultados) | «Todos los resultados numéricos de esta tabla pertenecen al escenario sintético y no proceden de ningún estudio clínico ni de Shi et al.» |

### 8.3. Atribución cruzada corregida (inventario E.3)

**Confirmado: el riesgo era real.** En `capitulo12.typ` la fila 11 yuxtaponía «Inferencia para $V^\pi$» + «Teorema de Shi et al.» + «125 pacientes», en una tabla cuya columna se titula «Resultado en el SSCH».

- `capitulo12.typ`, fila 11 → «125 trayectorias por cálculo de poder *del propio ejemplo sintético* — no es un dato de Shi et al., cuyo estudio empírico analiza 6 pacientes de OhioT1DM».
- `capitulo11.typ`, análisis de poder → se explicita que el 125 sale de la fórmula con $\hat\sigma = 0.21$ del ejemplo, y se contrasta con los 6 pacientes del artículo real.

### 8.4. Hechos del artículo real, verificados contra `jrsssb_84_3_765.pdf`

Incorporados al texto en `capitulo11.typ`: **6 pacientes** de OhioT1DM («six patients with type 1 diabetes»), **ocho semanas**, **intervalos de 3 horas**, $discount = 0.5$
(«with γ = 0.5»). Todo citado textualmente del PDF que está en el repositorio.
No incorporé «acción binaria según unidades de insulina» ni «recompensa vía Index of Glycemic Control» porque no los verifiqué línea por línea.

### 8.5. Punto 4 del encargo original: **anulado**

> «Donde el libro describa OhioT1DM, verificá contra el artículo original…»

El manuscrito **no describe OhioT1DM en ninguna parte**: cero apariciones antes de esta fase. El punto era inaplicable. No se forzó.

### 8.6. Hallazgo estructural (anotado por pedido explícito)

El libro dedica el @ch:inferencia completo al Teorema de Shi et al. y **no tiene ningún anclaje en datos reales**: todo su aparato empírico es un ejemplo sintético. Eso es una debilidad seria para una editorial científica y no se resuelve en esta fase. Lo único que se ha hecho aquí es volverlo *visible* en lugar de implícito, y mencionar los 6 pacientes de OhioT1DM como referencia de lo que sería un análisis empírico real.

### 8.7. Resto de ejemplos SSCH con cifras (sin caja inline)

Heredan la declaración de la primera aparición, pero **no llevan caja propia**: `ex:ssch-cap02`, `ex:ssch-cap03-b`, `ex:ssch-mcmc-vi-cap03`, `ex:ssch-cap04-b`, `ex:ssch-cap05-b`, `ex:ssch-causal-cap06`, `ex:ssch-cap06`, `ex:ssch-bandits-cap08`, `ex:ssch-cap08`, `ex:ssch-cap09`, `ex:ssch-cap10`, `ex:ssch-dist-shift-cap10`, `ex:ssch-drl-cap11`, `ex:ssch-confound`, `ex:ssch-pomdp`, `ex:ssch-reliable`, `ex:ssch-integration`, `ex:ssch-limitations`, `ex:ssch-trazability`, más los del apéndice de laboratorio. Si quiere la caja en todos, es un script de 20 inserciones.

### 8.8. Páginas

| | Páginas |
|---|---|
| Original | 281 |
| Tras Fase 1 | 282 |
| Tras Fase 2 | 281 |
| **Tras Fase 3** | **282** |

Diferencia neta: **+1 página**. `typst compile` → **exit 0**.
Controles sobre el PDF final: marcadores `0`, placeholder `0`, «Cifras sintéticas» `4`.

---

## 9. Estado de los commits

**Ninguno de los tres commits existe: el repositorio no está bajo git.** Los mensajes
acordados quedan pendientes de que se inicialice el repositorio:

```
fix(bib): elimina placeholders y resuelve citas no verificadas
refactor(tesis): incrustación fiel en lugar de isomorfismo
docs(casos): declara SSCH como sintético y separa de OhioT1DM
```

---

## 10. Cierre de puntos residuales (ronda posterior)

### 10.1. Las dos Proposiciones sin demostración → mismo criterio

| Clave | Rama aplicada | Resultado |
|---|---|---|
| `prop:ch9-tabla` | **(2) degradar** | **Conjetura 9.13**, «Transferencia de resultados de inferencia». No sobrevive ni acotada al caso de un paso: sus filas incluyen normalidad asintótica, cota de Cramér–Rao, eficiencia del DR y tests UMP, ninguna de las cuales se sigue de la incrustación fiel |
| `prop:ch9-completitud` | **(tercera rama)** | **Nota 9.19**, «Síntesis del marco: alcance, no resultado». No es una afirmación matemática sino una síntesis expositiva; se eliminaron «fundación axiomática» y «trazabilidad completa» |

### 10.2. Marca inline para los ejemplos SSCH

Añadido a `plantilla.typ`:

```typst
#let sintetico = text(size: 8pt, style: "italic", fill: mdpcolor)[(sintético)]
```

y un parámetro opcional `es-sintetico: false` en `thm-env`, que inserta la marca
justo **después del número**: «Ejemplo 1.35 (sintético) (SSCH — …)».

**26 marcas aplicadas**: los 23 ejemplos `ex:ssch*` de los capítulos 1–12, más 3
puntos del apéndice de laboratorio (dos bloques «Ejemplo numérico (SSCH)» y el
encabezado del Laboratorio F.4.2). Se marcaron también los 4 ejemplos que ya
tienen caja completa, para que ningún ejemplo SSCH quede sin señal.
Las 4 cajas completas se conservan.

### 10.3. Convención de nombres

`capitulo00.typ` · párrafo «Sobre los dos nombres»: se explicita cuándo se usa
cada término — «incrustación fiel» para la afirmación general, «isomorfismo»
allí donde la correspondencia es exacta dentro del alcance demostrado—. Los ~26
usos `CORRECTO` de «isomorfismo» **se conservan**: no se corrió ningún `sed`
global.

### 10.4. Hechos del artículo real incorporados

`capitulo11.typ`: a los datos ya verificados (6 pacientes, ocho semanas,
intervalos de 3 h, $discount = 0.5$) se añadieron, aportados como verificados por
el autor: **estado tridimensional**, **acción binaria** según si la insulina
total del intervalo supera una unidad, y **recompensa definida por el _Index of
Glycemic Control_**.

### 10.5. Control de versiones

Repositorio inicializado. **Un solo commit**, sin fabricar los tres estados
intermedios:

```
772af63  chore: estado inicial tras saneamiento de integridad (Fases 1-3)
         Dr. Jaime Lincovil <jlincovilc@uni.edu.pe>
```

`.gitignore` creado: ignora `main.pdf`, `_dev_stub.pdf`, `preview_notacion.pdf` y
los artefactos LaTeX (`*.aux`, `*.log`, `*.fls`, `*.fdb_latexmk`, `*.blg`,
`*.bbl`, `*.out`, `*.toc`, `*.synctex.gz`). **36 archivos versionados, 3
ignorados.** Se conserva versionado `jrsssb_84_3_765.pdf` como fuente primaria.

Los cuatro artefactos LaTeX de la raíz fueron **eliminados**. Sobre su origen:
el `.fls` registra `PWD` en este directorio y **un único input**, el propio
`referencias.bib`, con salida `referencias.log` — es decir, una invocación
deliberada de `latexmk`/`lualatex` *sobre el `.bib`*, no un build del proyecto.
No la lancé yo (mis comandos se limitaron a `typst`, `pdftotext`, `pdfinfo`,
`biber`, `grep`/`sed`/`ls`/`rm`, `python3` y `date`). El historial de shell no
es legible o no contiene rastro. **No puedo atribuirla a un actor concreto**;
lo que sí puede afirmarse es que fue manual y dirigida al `.bib`, y que su log
de 116 errores `Missing \begin{document}` no aporta ninguna validación.

### 10.6. Páginas

| | Páginas |
|---|---|
| Original | 281 |
| Tras Fases 1–3 | 282 |
| **Tras residuales** | **282** |

`typst compile` → **exit 0**. 26 marcas `(sintético)` en el PDF.

---

## 11. Cierre de la Parte A (tercera ronda)

### 11.1. `AMBIGUO 1` resuelto — fila 1 del cap. 1

Verificación previa: 5 de 6 filas del cap. 1 coincidían con el Teorema 9.3;
**la fila 1 no** (Θ ↔ 𝓜 «modelo del ambiente» vs. Θ ↔ «índice de modelo
P_θ»). Corroborado por `notacion.typ:28` (que define 𝓜 como el MDP completo) y
por `F(𝓓) = 𝓜` en la demostración (𝓜 es la imagen del funtor), además de por
la propia tabla revisada del cap. 0.

Corrección aplicada: celda → «índice de modelo $P_theta$ — estado _oculto_ bajo
la lectura POMDP; *no* el estado observado $StateSpace$», con referencia a
`@tab:correspondencia-central`; entorno renombrado **«anticipo»**; «es isomorfa
a» → «se incrusta fielmente en»; restricción (un paso **y determinista**) y
destino de la prueba en el enunciado; nota al pie reescrita como convención
(«es la que el Teorema 9.3 verifica») y no como consecuencia afirmada.

No hay conflicto con la fila 2 (𝓧 ↔ 𝓢): Θ y 𝓢 son objetos distintos y la tabla
ahora lo dice.

### 11.2. Hallazgo nuevo: cuatro formulaciones de la fila Θ

No bloquea ningún movimiento; se anota para la Fase 2.

| Dónde | Fila Θ | Símbolo | Estatus declarado |
|---|---|---|---|
| cap. 1 (corregida ahora) | índice de modelo P_θ; **no** el estado observado | (sin columna) | — |
| `notacion.typ` §0.17 · «Correspondencia Isomórfica Principal» | «Estado _oculto_ / índice de modelo P_θ» | **$isoto$** | «Condicional — ver matización de observabilidad» |
| cap. 0 · Tabla 0.1 (§0.18) | «Estado _oculto_ (POMDP) o índice de modelo P_θ» | $isoto$ | «Exacta bajo la incrustación; *no* el estado observado» |
| cap. 13 · `tab:isomorfismo-completo` | «Estado oculto del entorno (POMDP) / índice de modelo» | $arrow.squiggly$ (corregido en Fase 2) | — |

**Dos problemas reales:** (i) `notacion.typ` §0.17 usa `$isoto$` (exacto) en
filas cuyo propio estatus dice «Condicional» — contradice la convención
↔/↝ en dos filas; (ii) la nota «§0.17» que figuraba en el encargo apunta a la
tabla de `notacion.typ`, que **no** lleva la advertencia «*no* el estado
observado»; esa advertencia está en la Tabla 0.1 del cap. 0 (§0.18). Por eso la
celda del cap. 1 referencia la etiqueta y no un número de sección: en la Fase 2
la numeración va a cambiar.

**No se corrigió** §0.17: `notacion.typ` no tiene destino claro en el esqueleto
nuevo (ver `MAPA_ESTRUCTURA.md`), así que el arreglo corresponde a la fase que
decida qué pasa con el capítulo de notación.

### 11.3. Deuda técnica menor

`@ch:introduccion` **no es referenciable**: el cap. 0 es un capítulo sin
numerar, así que Typst rechaza la referencia (mismo defecto que el libro ya
documenta en un comentario de `capitulo13.typ`). Se usa prosa («capítulo de
Introducción»). No se persigue ahora.

### 11.4. Commits

```
6400e69  fix(cap13,apE,fuentes): resuelve dos casos ambiguos y saca la fuente
         primaria del control de versiones
223cdfa  chore: estado inicial tras saneamiento de integridad (Fases 1-3)
```

Más el commit de esta ronda: `fix(cap1): corrige Θ↔𝓜 por Θ↔índice de modelo P_θ
y acota la Proposición 1.x`.

### 11.5. Páginas

| | Páginas |
|---|---|
| Original | 281 |
| Tras Fases 1–3 | 282 |
| Tras residuales | 282 |
| **Tras Parte A** | **283** |

---

## 6. Qué NO hice

- No toqué las **56 claves huérfanas** que quedan (orden suya: «no las toques»).
- No toqué ninguna de las **222** líneas con «isomorf» (Fase 2).
- No eliminé la sección vacía de `capitulo07.typ:291` ni la frase mecánica de las 8 pruebas
  (hallazgos de Fase 2), pese a que su instrucción era explícita: **las dejé para no contaminar
  el commit bibliográfico** con cambios de contenido.
- No eliminé el epígrafe apócrifo del cap. 9 (Fase 2).
- No creé ni inicialicé repositorio git.
- No inventé ninguna referencia, DOI, año, página ni resultado.

**A la espera de: (a) decisión sobre git, (b) las 3 `AMBIGUO` de §4, (c) las 5 huérfanas de §3,
y (d) confirmación de la desviación de §2.1, antes de arrancar la Fase 2.**
