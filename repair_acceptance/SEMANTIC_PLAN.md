# Plan de revisión semántica de la v1

## Estado al iniciar

Se revisan 245 claims actuales. Después del lote secuencial:

- 5 `exact`, 5 `partial`, 1 `auxiliary`, 234 `pending`;
- 14 filas con comparación `agent_reviewed` y 231 `pending_review`;
- la verificación local produce 287 recibos y `283/283` argumentos aceptados/condicionales, sin ocultar las hipótesis y deudas.

El estado de ejecución no sustituye estos estados de revisión. La etiqueta local `v1.0.0` queda en su commit de referencia y estos nuevos cambios no la reasignan.

## Método por afirmación

1. Leer el bloque completo Typst y no solo el nombre de la clave. Identificar hipótesis, conjuntos de variables, cuantificadores y conclusiones.
2. Leer los tipos Lean de todas las declaraciones necesarias, así como definiciones e hipótesis ocultas en estructuras e instancias. Comparar el dominio real y el implícito.
3. Localizar posibles diferencias: supuestos retirados, ampliación de portadores, dependencia de un testigo único, cambio de soporte, regularidad, independencia, convergencia o negación débil.
4. Registrar `relation` = exact/partial/auxiliary/pending en `semantic_reviews.json`, con justificación específica, límite y fecha. No revisar la afirmación solo por respaldo formal ni el nombre del target.
5. Solo asignar `agent_reviewed` tras esa evaluación. El material recolectado de tipos/fuentes no es prueba de comparación; el resto sigue pendiente, sin estandar falso.
6. Regenerar `claim_review.json`, prohibir referencias rotas, repetir el runner de evidencia y hacer revisión tipo/axiomas focalizada. Para decisiones finales repetir todas las puertas en checkout limpio.

## Primer lote concluido

- `thm:ch9-secuencial`: la recursión exacta, cota y existencia (`cota` + `alcanza`) se contrastaron. Quedó documentado el caso finito, b ≥0, q ≥0, prior posterior arbitrario en predictiva cero y ausencia de conclusión frecuentista uniforme. **exact dentro de ese alcance**.
- `cor:ch9-bellman`: agrupa supremo -ell y recursión con máximo opuestos a min/riesgo como el libro. **exact dentro del alcance finito**.
- Se añadió `E.thm:ch9-secuencial.alcanza` con su target Lean, para que la prueba de existencia no quede oculta al revisor del kernel.

## Segundo lote (secuencial/Bellman, identificación/DR y deuda de mezcla)

### Mejora de políticas y terminación finita — verificación cerrada

Comprobado en el registro que las tres reviews existen con fecha real `2026-11-13T15:20:21.243527+00:00`, y que los siguientes targets están presentes en argumentos/kernel:

- `ch8_mejora`
- `ch8_pi_finita_sin_repeticion`
- `ch8_pi_finita_conteo`
- `ch8_pi_finita_optimo`
- `ch8_parada`

No se duplican las reviews al reordenar esta iteración. Las tres relaciones siguen siendo exactas dentro del MDP finito, no una equivalencia universal.

### Identificación/DR y mezcla — revisadas a la vez
- `thm:ch10-identificacion`: parcial por especialización estacionaria finita, no representación integral general. Añadido soporte de `ch10_identificacion_pdis` para peso hasta paso.
- `thm:ch10-is-insesgado` y `thm:ch10-curse`: parcial, versión iid/finita y acotada, sin confundir insesgadez con consistencia ni una cota superior con tasa exacta.
- `thm:ch10-dr`: parcial, identidad correcta con sesgo error producto y ambos corolarios de sesgo cero. Sesgo de DR cuando propensión o regresión es correcta conserva definición de trueReg y los supuestos estacionarios del libro.
- Gordin: Poisson, telescopía, borde, media nula, bracket y máximo principio son `auxiliary` revisados; no cierran el CLT funcional ni determinan σ²=∑Cov sin aperiodicidad. El CLT funcional y el resultado distribucional Ibragimov siguen pendientes. No se crea deuda extra por documentos auxiliares.
- Se añadieron las evidencias `ch8_pi_finita_conteo`, `ch8_pi_finita_optimo`, `ch10_identificacion_pdis`, `ch10_dr_sesgo_m`, `ch10_dr_sesgo_b`, `ch10_is_varianza`.

La revisión focalizada de axiomas está en `evidencia/repair/semantic_bellman_critico.log` y `semantic_ope_gordin.log`; todo indica `propext, Classical.choice, Quot.sound`.
Conteos: **8 exact / 9 partial / 7 auxiliary / 221 pending**. **27 agent_reviewed / 218 pending_review**. Regeneración local genera **293 recibos**, `283/283` argumentos respaldados y `semantic_gate True`, con errores negativos contemplados cero.

## Prioridades cerradas hasta ahora (en orden)

1. Secuencial bayesiano (`thm:ch9-secuencial`, `cor:ch9-bellman`).
2. **Mejora de políticas y terminación finita: CERRADO** — `thm:ch8-mejora`, `cor:ch8-pi-finita`, `cor:ch8-parada`; exactas solo en MDP finito con P estocástico, S/A no vacíos y γ<1, sin errores de evaluación numérica ni afirmación de contracción.
3. Identificación/insesgadez/varianza/DR (`thm:ch10-*`): revisados como parciales por especialización estacionaria finita; targets complementarios incluidos.
4. Deuda de mezcla: Gordin auxiliares revisados; Ibragimov distribucional y Gordin funcional **NO se cierran**.

## Tercer lote: eficiencia y despliegue (cerrado)

Se hizo un lote acotado de 11 reviews nuevas, reutilizando lectura completa de texto y códigos:

- `prop:ch10-dro-garantia` — `exact`, sobre conjuntos finitos no vacíos de modelos: en el evento de cobertura `P* ∈ cal(U)`, el ínfimo no excede a `J_P*`. La cobertura es premisa; no se promete construirla ni inferir que cualquier bola KL la cubra.
- `ex:ssch-dist-shift-cap10` — `exact` para los valores centrales (2.8, 4.8, pesos 0.375/3.5 y diferencia 2) **sin certificar el intervalo [4.4,5.2]**, no presente en su objetivo formal.
- `ex:ch10-shift-ssch` — `exact` del cálculo 3.4 vs 4.8 y diferencia 1.4 al cambiar la recompensa, sin afirmar MMD o invariancia transportable.
- `prop:ch10-is-shift` — `partial`: álgebra ν*s/νb e esperanza de razón 1 finito, sin la suma del cociente W general ya registrada a parte. No se prueba factorización de segundo momento conjunto.
- `thm:ch10-dr-eficiencia` — `partial`: funciones de influencia e igualdad de varianza bajo exactacies de nuisance; `dr_residual_orthogonal` verifica la condición de ortogonalidad. La expansión asintótica general y la cota semiparamétrica para aprendizajes **no están formalizadas** y no se presentan como cerradas.
- Seis ejemplos/contraejemplos — identidad explícita: observabilidad parcial, confounding, fallo mixing, confound SSCH, dist-shift; `ex:ch9-fallo-overlap` y `ex:ch6-tasas` son parciales: el primero verifica overlap débil, no identificación sin soporte; el otro cubre una tasa más rápida que el caso original, no el producto general de tasas.
- Se añadió `E.ex:ssch-confound.sesgo-signo` para el cambio de signo. `dr_residual_orthogonal` ya estaba enlazado anteriormente como `-1`, sin duplicación inventada fuentes.

`semantic_gate True`: **15 exact, 13 partial, 7 auxiliary, 210 pending; 38 agent_reviewed / 207 pending_review**. Verificación con 294 recibos generados: 283/283 y deudas no ocultas. Evidencia de tipos/axiomas `evidencia/repair/semantic_shift_efficiency.log`.

## Prioridades reales siguientes

1. **Eficiencia e identificación restantes de capítulos 6–11:** continuar OPE/herramientas causales (DM, normalización, contraejemplos no formalizados) con los límites apuntados. Diferenciar aplicación algebraica y condiciones de aprendizaje/comparación no paramétrica faltantes.
2. **Apéndices auxiliares y ejemplos innecesarios al núcleo:** revisarlos por temas sin separar deuda artificial. Los `der:` son auxiliares, no cajas científicas cerradas.
3. **No desarrollar Skorokhod ni fabricar conclusión Ibragimov distribucional:** conservar los pendientes, incluida la expansión eficiente DR general, el rango de sensibilidad [4.4,5.2], overlap nulo y la evaluación general de identificación de políticas.

## Cuarto lote: DM y transporte/horizonte (cerrado)

**5 revisiones nuevas**, no doce: solo cinco claves principales contadas, sin inflar el conteo por targets auxiliares.

- `prop:ch10-dm` — `exact`: sesgo condicional acotado y Var_ν(v̂)/n para contribuciones iid. El entrenamiento sigue tratado como objeto fijo, como en el pasaje.
- `thm:ch10-truncamiento` — `exact`: la fórmula de sesgo cola y B²min(M²,M)/n completa; umbral fijo, sin percentiles adaptativos no formalizados.
- `ex:ch6-horizonte-pesos` — `partial`: esperanza, varianza exacta c^H−1, b=1/5 y b=1/2 y explosión geométrica; sin el promedio de n ni recompensa variable.
- `cap11-truncamiento` — `partial`: certifica H=46 contra H=45 en las potencias naturales, sin el bound de cola general ni cobertura directa del infinito.
- `ex:ch9-fallo-noest` — `partial`: momentos exactos de dos bloques correctos y tender al promedio de regímenes, sin un CLT general no estacionario (enunciado de biblio) ni no-estabilidad arbitraria.

Se incluyeron 4 targets complementarios del horizonte (esperanza, mitad, quinto, explosion); `dr_residual_orthogonal` sigue deduplicado. El exporter necesitaba anadir esos names, namespace Cap06M5 completo. Verificación posterior: **298 recibos, 283/283**, semantic_gate True.

**Conteos breves: 17 exact, 16 partial, 7 auxiliary, 205 pending; 43 agent_reviewed / 202 pending_review.**

Error recuperable clasificado: target mal namespace (`Cap06M5` inicial no caratérized), se corrigió agregando los cuatro objetivos; no se afirmó revisión sin export. Evidencia `evidencia/repair/semantic_dm_verify.log`.

## Prioridades siguientes reales

1. **Herramientas causales/restante de capítulos 6–11:** a partir de dr/engines y pesos efectivos; no confundir ejemplos algebraicos con inferencia general nonparametric. Revisar integrabilidad general y supuestos no tratados aún.
2. **Apéndices auxiliares y ejemplos innecesarios al núcleo:** `der:` siguen auxiliares sin caja; no se propone cierre de Skorokhod o distribucional Ibragimov.

## Quinto lote: herramientas de DML (cerrado)

**6 revisiones nuevas; 196 pendientes**. Clasificación completa: **19 exact / 20 partial / 7 auxiliary / 199 pending**, **49 agent_reviewed / 196 pending_review**.

- `prop:ch10-var-dr` — `exact` como contraejemplo numérico (D varianza uno y IS varianza cero), no ley universal.
- `prop:ch6-descomposicion` — `partial`: descomposición geométrica correcta, en dimensión finita; no se construyen los subespacios tangente y nuisance completos.
- `cor:ch6-varianza-minima` — `partial`: forma aritmética σ²/n, sin construir estimador eficiente ni momentos/diferenciabilidad.
- `thm:ch6-neyman` — `exact`: error de segundo orden con ortogonalidad $D=0$, sin afirmar eficiencia global.
- `thm:ch6-dml` — `partial`: CLT genérico válido para expansión con resto y Slutsky, y demostración local del producto de errores; no se prueba la expansión específica de cross-fitting, la consistencia de varianza empírica ni el caso de varianza nula.
- `thm:ch6-crossfit` — `partial`: la suma por particiones devuelve el total, sin independencia i.i.d de pacientes/episodios ni bloques temporales.

Añadido `E.thm:ch6-dml.resto-pequeno` para la prueba del producto de errores. La verificación posterior produce **299 recibos**, `283/283` y `semantic_gate True`. Evidencia en `evidencia/repair/semantic_tools_verify.log` y axiomas en `semantic_dml_tools.log`.

No se debilitan las limitaciones del libro: normalmente se demuestra exactitud local o formal parcial. Conteo por clave, nunca por número de helpers o tipos del exporter.

## Próximas prioridades reales

1. Continuar herramientas causales y capítulos 6–11: cota semiparamétrica, condiciones causal/backdoor, pesos y diagnósticos efectivos.
2. Revisar derivaciones `der:` sin volverlas claims autónomos de Gordin.
3. Repetir únicamente archivos afectados y el runner de evidencia; no aumentar conteos sin justificación concreta.

## Cierre por lote

- registrar fecha y tipo/tipos reales atento a `#print axioms` cuando proceda;
- comprobar que el cambio en el archivo de revisión no sea solo textual —la revisión debe comparar contenido—;
- actualizar conteos y revisiones pendientes;
- añadir controles para el fallo de especialización detectado y reproducir la puerta afectada;
- establecer nuevo resultado de aceptación solo si las puertas del contrato pasan realmente. No borrar claims ni recuentos secundarios para mejorar la métrica.

## Cobertura

Se conservan 398 bloques: 224 con claim, 174 exclusiones de definiciones/notas/problemas editoriales. No se eliminan exclusiones justificadas para falsificar inclusión total. Ninguna nueva afirmación queda en general `pending_review` como etiqueta de éxito: describe revisión no hecha, no una contaminación por verde general.

## Enjambre extenso (smwh89c1q) — primera integración de cinco entregas

Se integraron únicamente soluciones revisadas y aceptadas individualmente, sin aplicar `kernel_patch.json` externos ni reescribir hechos previos.

- m8/cap04: 11 filas (4 exact, 7 partial) comparadas con fuente y axiomas reproducidos.
- m11/cap02_wald: 10 filas (5 exact, 5 partial).
- m2/cap03_mdp: 9 filas (2 exact, 6 partial, 1 pending); UCB1 sin garantía no se cierra.
- m16/auditoría: 299 targets existentes, 299 con axiomas permitidos; dos hipótesis ambiente conservadas como pending y no obligadas como claims cerrados.
- m9/cap04 frontera: 11 filas (2 exact, 6 partial, 3 auxiliary), incluidos los límites auxiliares de MLE/mixing/bootstrap, ninguna falsa equivalencia general.

Programa anterior: 49 `agent_reviewed` y 196 pending. **Nuevas filas verificadas: 43 (13 exact / 24 partial / 3 auxiliary / 3 pending). Faltan: 153 reviews.**
Matriz generada: **32 exact, 44 partial, 10 auxiliary, 159 pending (3 pendientes ya revisados)**, **92 agent_reviewed / 153 pending_review**, semantic_gate True.

El aviso de m8 sobre thm:ch6-rubin-dag corresponde a un desajuste de slots, no a un hueco en el reparto: pertenece al bloque d10. Mientras los demás miembros trabajan, no se neutraliza ninguna conclusión pendiente ni se cambia la etiqueta v1.0.0 ni se publica.

Siguientes: leer restantes aportaciones de m1/m3/m7/m10/m15, comprobar independencia del scope y del modelo de revisión del agente, integrar solo filas con evidencia target y fuente exactas. Cerrar los 153 es trabajo real, no máscara de compilación.

## Integración de las 16 entregas y cola focalizada

- Se juzgaron los 16 miembros de smwh89c1q individualmente: aceptados solo tras chequeo manual de tipos y axiomas. En total, semantic_reviews.json pasa de 49 a **232 agent_reviewed / 13 pending_review**.
- Se aplicó no-overwrite: registro de los tres duplicados en `repair_acceptance/historical/duplicates_smwh89c1q.json` (same-claim preserve-first source, no reescribir "partial" con otra nota distinta).
- Recuento completo actual: **74 exact, 124 partial, 25 auxiliary, 22 pending** (242? ASCII output lib semantic_gate: total is 245, sum matches); por supuesto el conteo de argumentos/recibos no es el de revisión matte.
- Todas las deudas completas Ibragimov CLT y Gordin funcional/Skorokhod siguen conservadas sin promotion. C.clt-agentes, C.ch11-mixing también pending según oficio review, no por compilación.
- Primer lote integra 43 filas; siguientes integra 111 (descartada delta-q duplicate); final aporta 29 (restar medible y A.* conservados no_overwrite). Pendientes reales del scope original: 13, lista explícita en claim_review.json (13/245).

Nuevo flujo `smwh97qkh` (4 miembros, 500 steps cada uno, 240 min, fixed model), por groups: ancilar-localizacion+gauss/mp+bonferroni, no-param/bootstrap/if media/cociente, CLT+qdelta, bandas+cox+aipw-intro. Reglas exactas: lectura fuente/tipo real, limitaciones explícitas, auxiliary solos si derivaciones internas; no cierre artificial asintótico.

Al integrar este último grupo se comprobará `verify.py` completo soportado por witness, no una variante de acceptance artificial ingenua. Sin publicar la rama, no move v1.0.0, mantener reproduc result evidence by dir. Continuar bajo últimos reports only after proof contents. No recasting good helper into general.

## Lote final `smwh97qkh`: revisión del lote completa, deuda específica no demostrada

Se integraron las 13 filas pendientes originales como `partial`, sin reescribir ninguna revisión existente y sin elevar una comprobación numérica a prueba formal:

- **m4:** `ex:ch5-bandas`, `ex:ch6-cox` y `ex:ch6-aipw-intro`: equivalencia de sucesos con una hipótesis de acotación, cancelación del basal e identificación finita/AIPW por mano observada. No prueban Donsker–Kolmogorov, censura y verosimilitud parcial completa ni inferencia semiparamétrica general.
- **m2 (aceptado como juez):** `ex:ch4-no-parametrico`, `ex:ch4-bootstrap-unidad`, `ex:ch4-if-media-cuantil` y `ex:ch5-cociente`. Valores, conteos e identidades exactas no derivan órdenes estocásticos, convergencia bootstrap, una expansión del cuantil con estimador/CLT, ni el método delta que identifica la varianza asintótica. Se recompiló `audit_d2.lean`: 23 controles de axiomas limpios (`.scratch/smwh97_m2_check_rerun.log`). La simulación queda fuera del respaldo formal.
- **m3 (aceptado como juez):** `thm:ch5-clt` y `ex:ch5-qdelta`, ambos parciales. En el primero, `[Fintype Ω]` está en el target actual pero no en el libro; es una restricción añadida, no una propiedad heredada de Mathlib. La variante auxiliar sin ese binder elaboró correctamente, pero no se aplicó al repositorio. Tampoco se formalizó la forma studentizada. En el segundo falta transportar la convergencia gaussiana conjunta y demostrar la cobertura asintótica del IC: la forma cuadrática y los números no bastan. `check_m3.lean` reelaboró con 11 controles de axiomas limpios (`.scratch/smwh97_m3_check.log`).
- **m1 (aceptado como juez tras recibir el envío formal):** `ex:ch2-ancilar-localizacion`, `ex:ch4-regularidad`, `ex:ch4-mp-normal` y `ex:ch4-bonferroni-ssch`. Se conservaron como parciales porque ancilaridad/no-suficiencia, sándwich general/ley del máximo, optimalidad MP y cuantil normal/FWER no están cubiertos por los targets registrados del árbol del libro. Sus módulos auxiliares no se importaron al `Book/` ni se promovieron a `exact`: están fuera del grafo de evidencia. El envío final recompiló cinco módulos y 38 controles de axiomas permitidos (`.scratch/smwh97_m1_final_check.log`), incluidos los cuatro teoremas de `D4Uniforme`; `verify_tipos.py` confirmó los 7/7 tipos. El máximo estandarizado y su límite CDF se reconocen como auxiliar externo, no como el sándwich general ni como registro cerrado en el libro. Se preservó la revisión ingerida en vez de duplicar IDs o sobreescribirla con cada nueva marca temporal del borrador.

La matriz regenerada desde el inventario Tipst, el exporter y `semantic_reviews.json` es **74 exact / 137 partial / 25 auxiliary / 9 pending**, con **245 `agent_reviewed` y 0 `pending_review`**. `semantic_gate` = True sobre 245 filas y 398 bloques. Las nueve relaciones `pending` son deuda explicitada y revisada, no cola de lectura ni pruebas completas. En particular permanecen `C.thm:appD-ibragimov` y `C.thm:appD-gordin`; no se intentó cerrar Skorokhod ni una versión distribucional inexistente.

Se contrastó que, salvo las filas recién integradas, las anteriores conservan idénticas fuente, fragmento, targets, tipo y fecha de revisión. El exporter tiene 324 entradas/315 nombres únicos, con 299 vinculados por specs Lean actualmente; no se añadieron recibos para las pruebas auxiliares externas de m1 ni para los complementos qdelta mencionados, pues hacerlo requeriría decidir y registrar su evidencia, no afirmarla en un comentario.

Este estado describe revisión semántica completa del lote, **no demostración matemática completa del libro**. `smwh97qkh` quedó `solved` con cuatro soluciones aceptadas individualmente. Ese cierre y `semantic_gate` no son la aceptación de software ni la reproducción limpia del commit final, que se comprueban aparte. En el árbol de trabajo quedaron verdes `cargo fmt`, Clippy con `-D warnings`, las 80 pruebas Rust y `verificar.sh`: 66 módulos activos, 2699 teoremas auditados sin axiomas prohibidos, y dashboard 35/35. `argumentos verify` elaboró los targets actuales y produjo 299 recibos, 283/283 argumentos respaldados, sin convertir en aprobados los claims ambientales ni Ibragimov/Gordin. Falta repetir la puerta completa en el worktree limpio del commit.

## Avance de pruebas y reparaciones (`smwi1z2xl`)

Se juzgaron las ocho direcciones y se integró un lote independiente, sin aplicar automáticamente los JSON propuestos por los miembros. Cada módulo se leyó, re-elaboró y audió contra Mathlib 4.35.0; después se repitió todo en el repositorio real.

- **Fisher aditiva:** `Cap04InfoAditivaM1` demuestra la identidad `I_n = n·I₁` para densidades positivas, normalizadas y derivables sobre un espacio finito. La ley conjunta producto hace explícita la independencia; las cruces se anulan y hay un testigo Bernoulli. `cor_ch3_cr_iid_joint` deriva la aditividad en vez de suponerla. No se promete el caso continuo ni independencia general. El antiguo `prop_ch3_info_aditiva` queda documentado como identidad aritmética auxiliar, no como prueba probabilística.
- **CLT iid:** se retiró `[Fintype Ω]` con `omit [Fintype Ω] in`, sin cambiar el cuerpo. `BookCap05M2` demuestra la variante studentizada, incluida la conclusión con un solo testigo standard normal, y da una instancia gaussiana con varianza 1. El dominio del claim y del spec es ahora probabilístico, no finite. Esto no altera Ibragimov ni ningún CLT de mezcla.
- **Medibilidad:** `Cap04MedibleIntuicionM10Ext` añade transporte de momentos, ley por composición y un contraejemplo en un espacio de probabilidad. Los supuestos `A.medible-borel` y `A.probabilidad-datos` permanecen como obligaciones abiertas y no se promueven a auxiliary sin evidencia autónoma.
- **Covarianza temporal e intervalos:** `Ch5CltAgentesCovarianza` demuestra Toeplitz/Cesàro bajo covarianzas absolutamente sumables y `Ch5StudentizadoM6` demuestra cobertura studentizada bajo `hclt` y consistencia explícitas. Los dos claims de la contribución estacionaria/autocovarianzas no obtienen el CLT de mezcla por ello. El alcance de las evidencias de intervalo marca esa premisa externa y no descargada.
- **α-mixing finito:** `IbraComplexM5` prueba la desigualdad y el lema de bloqueo complejos, útiles para funciones características. También refuta la subaditividad sobre joins mediante el acoplamiento XOR. `DEUDA.md` ya no prescribe esa vía inválida; la monotonía sólo queda demostrada en el caso finito de coordenada producto.
- **UCB1:** `Cap08Ucb1M7` reduce el esqueleto determinista a conteo, índices y brechas positivas, y deja explícita la interfaz de esperanza con μ(Gᶜ)≤p. La fila auxiliar `C.der:ch8-ucb1-esqueleto` contiene cuatro evidencias con el mismo alcance declared (`domain`, `carriers`) que su claim. El teorema citado de Auer sigue `pending` y no se demostró la ley del bandido ni la desigualdad de concentración.
- **Gordin:** `GordinDoeblin` demuestra el decaimiento geométrico de una potencia primitiva sobre funciones π-centradas. Es auxiliar, no la identificación de σ² ni Skorokhod. `GordinCoreM8.lean` ya no presenta como declarada la convergencia de bracket que no prueba. Gordin e Ibragimov distribucionales siguen en deuda.

La matriz resultante leída con `lib.build_corpus` es **75 exact / 139 partial / 27 auxiliary / 6 pending**, sobre 247 claims actuales, con `semantic_gate=True` y 398 bloques Tipst. Los pending son UCB1, el CLT de mezcla de capítulo 11, Ibragimov, Gordin y los dos supuestos ambientales. La nueva auxiliary de UCB1 y la de Doeblin no los eliminan ni cambian sus fundamentos.

Se preservaron las revisiones previas en `repair_acceptance/historical/progreso_smwi1z2xl.json`; las nuevas revisiones se añaden cronológicamente, y `build_corpus` utiliza la más reciente por claim_id. Los conteos de listas de revisiones históricas no se confunden con el número de claims activos.

### Validación integrada antes del commit

- Runner real en `verificacion_lean`: 75 módulos active, **2956 teoremas**, 0 con axiomas no permitidos; dashboard 727/727, 35/35.
- Rust: formato, clippy y **80 pruebas**.
- Exportación real: 341 entradas / 332 nombres únicos; los 17 nuevos targets de la integración están presentes.
- `argumentos verify`: **317 recibos** generados, **289/289 argumentos** respaldados localmente. Las dos hipótesis ambientales permanecen condicionales; Gordin e Ibragimov siguen pendientes.
- `lakefile.toml` quedó con comentarios TOML válidos y fue leído con `tomllib`; Mathlib sigue fijada en `56a005855ea17e0b0958f73ec801ae140b0a1679`. No se aplicó `lake build` sobre `/opt/mathlib`.
- El dashboard incluye la relación semántica de cada fila para que OK sólo signifique axiomas permitidos, no que la afirmación sea exacta.

No se realizó push ni se reasignó una etiqueta. Queda repetir el adapter `repair_acceptance/reproduce.sh` completo desde un worktree limpio del commit integrado; el estado `COMPLETE_VERIFIED` no certifica equivalencia matemática general.
