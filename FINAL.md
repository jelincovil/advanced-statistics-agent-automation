# Kernel de argumentos — versión 1, estado de trabajo

> **Documento histórico (fase de revisión v1).** El estado vigente está en `STATE.json`
> (251/293/330, `COMPLETE_VERIFIED`), `repair_acceptance/claim_review.json`
> (75 exact / 139 partial / 31 auxiliary / 6 pending, 0 `pending_review`) y en la
> reproducción limpia de `1bbc20d` (`evidencia/repair/smwi7ezya/clean-reproduction/`,
> C01–C12 y G1–G10 PASS, `source_commit=1bbc20d`). Ver `PLAN_KERNEL_CIERRE_2026-11-17.md`.
> Las cifras y la base `893d19a` de esta página describen la fase en la que se escribió.

## Mejoras aplicadas y reproducción

- **Confianza:** `receipt_from_str` rebaja ambos `locally_reproduced` y `attested_by_configured_policy`. Un JSON con aspecto completo y hashes correctos sigue no confiable. Se retiró la atestación por commit ancestral y hashes autodeclarados. `argumentos verify` reejecuta la evidencia con los runners permitidos y evalúa en memoria.
- **Entradas obligatorias:** `required_input_paths` deriva las del runner/spec. El mapa vacío o una omisión bloquea; no se creen confianza por el campo importado. Fuentes Lean, tipo elaborado y axiomas se comprueban contra la ejecución actual. Cambios documentales independientes no invalidan por sí mismos la identidad de ejecución.
- **Revisión corpus:** `repair_acceptance/semantic_reviews.json` documenta las comparaciones sustantivas hechas, limitación y fecha. `claim_review.json` se regenera con Typst, hash, pasaje, tipo elaborado, alcance, dependencias, hipótesis y próxima revisión. No se asigna `partial` por tener respaldo.
- **Casos:** C01–C12 tienen comandos y conteos de prueba explícitos en `case_driver.py`. Se implementaron mutantes negativos de importación autoconfiada, inputs incompletos, soporte perdido, tipo/fuente cambiado, experimento opuesto, módulo activo omitido y axioma prohibido.
- **Cobertura:** los 398 bloques tienen clasificación explícita. Las 174 no incluidas son definiciones/notas/problemas de apoyo editorial, no objetivos de prueba borrados. Un bloque teorema sin claim queda `included_pending`; un tipo desconocido falla.
- **Reproducción:** el driver versionado `reproduce.sh` comprueba estado limpio, HEAD y hash propio. Ver [REPRODUCE.md](REPRODUCE.md). La evidencia va afuera del checkout.

## Alcance y deudas

Se admiten pendientes explícitos, no se presentan como pruebas cerradas. La cuantificación exacta se evalúa por claim, no por nombre de target.

- **Ibragimov:** covarianza, sumabilidad y varianza de largo plazo están probadas en estado finito como `auxiliary`. No se demuestra la conclusión distribucional normal del CLT completo, que queda `pending`.
- **Gordin:** Poisson, descomposición y borde son auxiliares. Bajo `Matrix.IsPrimitive` y centrado se formalizan ahora la serie centrada de Poisson, su unicidad, `σ²=γ(0)+2∑_{k≥1}γ(k)` y el límite de las marginales algebraicas de dos tiempos bajo covarianzas absolutamente sumables. Se incluyen pruebas de irreducibilidad/primitividad y modelos espectrales. La medida de trayectorias y la forma bilateral no se construyen. **No** se demuestran el CLT funcional de martingalas en D[0,1], tightness/Skorokhod ni la bracket c.s.; `C.thm:appD-gordin` sigue `pending`.

El verificador evalúa 251 claims y 293 argumentos con 330 specs; estas cifras son inventario actual, **no** contadores de teoremas del libro cerrados. La revisión semántica queda completa en las 251 filas: 75 `exact` dentro del alcance declarado, 139 `partial`, 31 `auxiliary` y 6 `pending` científicos explícitos; no hay filas `pending_review`. Esto no elimina las limitaciones parciales ni las deudas conservadas.

## Validación pendiente

`STATE.json` pasa de `IN_PROGRESS` a `COMPLETE_VERIFIED` únicamente cuando el driver reproducido confirma C01–C12 y G1–G10. La referencia y hashes finales se añadirán tras esa ejecución. No se creó ninguna etiqueta ni se realizó push en esta fase.

## Validación a realizar sobre este commit

La reproducción de `bbbe69da` dejó C01–C12 y G1–G8, G10 correctos; G9 fallaba porque `current_commit` y `status` no representaban ese checkout. Se corrigió para resolver HEAD realmente en la reproducción; la etiqueta se decide solo tras verificar el commit completo final. Consultar [NOTES_V1.md](NOTES_V1.md) para el alcance: `pending_review` no se confunde con prueba terminada. Logs previos en `evidencia/repair/v1_mid2/verification`.
