# Kernel de argumentos — versión 1, estado de trabajo

**Base:** `893d19aa04fc85f58aeec387d74a57cfa3593d3e`. El informe anterior está en `repair_acceptance/historical/`; no se reutilizan sus afirmaciones globales de cierre.

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
- **Gordin:** Poisson, descomposición y borde son auxiliares. No se demuestran el CLT funcional de martingalas en D[0,1], tightness/Skorokhod ni la bracket c.s. La serie de covarianzas no se sigue sin aperiodicidad adicional.

El verificador evalúa 245 claims y 283 argumentos con 286 specs; estas cifras son inventario actual, **no** contadores de teoremas del libro cerrados. La matriz distingue `exact`, `partial`, `auxiliary` y `pending`, junto a `agent_reviewed` o `pending_review`, y cuantifica la revisión pendiente en vez de disimularla.

## Validación pendiente

`STATE.json` pasa de `IN_PROGRESS` a `COMPLETE_VERIFIED` únicamente cuando el driver reproducido confirma C01–C12 y G1–G10. La referencia y hashes finales se añadirán tras esa ejecución. No se creó ninguna etiqueta ni se realizó push en esta fase.
