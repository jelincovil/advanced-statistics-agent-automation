# Reparación del checker / reconciliación del kernel — registro

Base auditada: **94b79cbd867de5fb9f49d3c1b717fa9e8b3271d7**. Paquete original conservado fuera del árbol en `evidencia/repair/paquete_original/` (copia del ZIP adjunto).
Cómo reproducir: `python3 evidencia/repair/paquete_original/verify_delivery.py --repo <checkout-limpio> --out <nueva-carpeta-externa>`. El `IN_PROGRESS` actual no es aceptación de entrega.

## Hallazgos

| id | situación y reparación evidenciada |
|---|---|
| F01 | AND/MP/ALIAS recibían specs sin validar recibo. Toda regla compuesta ahora exige respaldo de cada spec. C01–C03 fallaban en base y pasan. |
| F02 | Invalidación directa → propagación transitiva por dependencias, conservando alternativas acíclicas con soporte válido. C04 cadena/diamante. |
| F03 | Registro empírico y ejecución ya no confunden criterio. `scientific_criterion_met` determina compatibilidad acotada; no promueve positiva. C05. |
| F04 | `receipt_from_str` rebaja `locally_reproduced` a `UntrustedImport`; el CLI solo atestigua con commit ancestral e inputs actuales. C07. |
| F05 | Se conserva cada recibo; válidos contradictorios son ambiguos/pendientes, no selección por orden; renames no alteran decisión. C06. |
| F06 | `CheckReport.claim_states` separa ejecución del cierre de claims, incluyendo huérfanos, condicionales, parciales y pendientes. |
| F07 | Auditoría bidireccional; bloques sin claim son explícitos. Cuatro cajas `cap11-*` añadidas sin alterar su texto matemático. |
| F08 | `C.der:appD-ibragimov-cuantitativo` conserva covarianza/sumabilidad/varianza probadas; el CLT completo queda NO_FORMAL_PROOF sin argumento principal. |
| F09 | Recibo actualizado a commit real, commit ancestral, hash de librerías y fuentes Lean, tipo elaborado y axiomas efectivos. |
| F10 | `Book/ApendiceDHac_m1.lean` ahora compila dentro del runner normal; no se eliminó ni se sustituyó silenciosamente. |
| F11 | `lean-toolchain` y `lakefile.toml` reconocen efectivamente Lean/Mathlib 4.35.0, commit `56a005855ea17e0b0958f73ec801ae140b0a1679`. |
| F12 | 73 anclas reales conectan claims/spectra antes no enlazados; el spec duplicado inválido está archivado con sustituto válido; los 2 pendientes científicos quedan visibles. |
| F13 | `argumentos/README.md`, `STATE.json` y `FINAL.md` son vigentes. F8 queda íntegro en `argumentos/reports/historico-2026-11-06/`, con sustitución documentada. |
| F14 | Claves de alcance ausentes se rechazan; LEAN_APPLY contrasta objetivo, tipo, alcance y obligaciones; hipótesis abiertas pasan a condicional, no desaparecen. |

## Evidence of reproduction

- `evidencia/repair/inicial/verification.json`: BASELINE_ONLY. `external_probe.log` falla C01/C02/C03/C06; `acceptance.log` falta el adaptador.
- `evidencia/repair/regresion_inicial.log`: mismas pruebas añadidas, 10 fallos y 2 casos ya válidos en base (invalidación de spec y compatibilidad negativa).
- Nuevas pruebas ejecutan la API real del paquete, no reproducciones históricas. El probe externo se conserva sin cambios.
- Recibo actual: generado por `cargo run -- evidence --repo . --out <evidencia-externa>/receipts`; `check` debe aceptar todos los argumentos solo con archivos/commit coincidentes.

## Correspondencia matemática y deuda

`repair_acceptance/claim_review.json` incluye cada claim con texto Typst, hash, tipo elaborado Lean, alcance, hipótesis, targets y revisión `agent_reviewed`. `PARTIAL` no se confunde con `EXACT`, que no se concede por nombre.

**Deuda científica (no software oculto):**

- `thm:appD-gordin`: Poisson, descomposición, borde e incrementos como derivados auxiliares; falta D[0,1]/Skorokhod, tightness y CLT funcional de martingalas. No se exige resolver Skorokhod en esta entrega.
- `thm:appD-ibragimov`: núcleo covarianza/varianza probado; el límite distribucional normal sigue pendiente. La varianza HAC y los demás resultados cuantitativos no se debilitan ni eliminan.

## Validación pendiente de cierre

El orquestador de aceptación ejecuta `fmt`, `clippy`, suite, Lean, probe,
cobertura editorial y `repair_acceptance/verify.py`. El `COMPLETE_VERIFIED`
solo se registra después de reproducción desde commit limpio sin cambios
posteriores y con `C01–C12` + `G1–G10` en PASS. La falta de esa reproducción
está consignada en `STATE.json`.

La documentación F8 conservada en `argumentos/reports/historico-2026-11-06/` no mide esta entrega y no se usa como prueba importada.
