# FINAL — proyecto ARGUMENTOS, estado al cierre F8

Fecha: 2026-11-06. Commits locales: F0 `eb4832e` → F7 `e42ede2` + este F8.

## Qué se construyó

Un sistema Rust (`argumentos/`) que implementa el canon de argumentos
verificables del libro *Teoría Avanzada de Inferencia Estadística*,
según el paquete `argumentos_construccion_v1` (contratos, reglas y plan
F0–F8). El kernel JSON es la fuente maestra de afirmaciones, argumentos
y evidencias; el checker Rust administra referencias, alcance, reglas y
estados; la matemática vive en Lean y la evidencia empírica en
experimentos Python con recibo.

| Componente | Archivo | Descripción |
|---|---|---|
| JSON estricto | `src/strict_json.rs` | Parser propio: claves duplicadas, NaN, Infinity, BOM, comas finales, no finitos rechazados |
| Modelo del kernel | `src/model.rs` | Tipos v1 + carga en capas (estricto → esquema → serde → unicidad de IDs) |
| Recibos | `src/receipt.rs` | 20 campos + consistencia `execution_passed ⇒ completed ∧ exit=0` |
| Checker | `src/check.rs` | IDs, DAG petgraph, AST exacta, 7 reglas, obligaciones, alcance, estados, invalidación transitiva |
| Exporter Lean | `evidence/lean_export.lean` | `collectAxioms`, `getUsedConstants`, `ppExpr` — nada de regex |
| Runner SSCH | `runners/ssch_bayes_racional.py` | Enumeración racional exacta: Bayes 19/50 |
| Parser Typst | `src/book.rs` | typst-syntax 0.15.1 (alineada con el binario del repo) |
| Extracción GLM | `src/extract.rs` | Trait `Extractor` con replay determinista y live stub |
| ASPIC+ | `src/aspic.rs` | Fixpoint de F(E), preferred exhaustivo, presupuesto |
| CLI | `src/main.rs` | doctor, inventory, check, evidence, render, audit, argue, propose |

## Validaciones realmente ejecutadas

| Control | Comando | Resultado |
|---|---|---|
| Paquete | `python3 tools/validate_package.py` | PASS (11 fixtures) |
| Esquemas | `python3 tools/check_schema.py` | PASS |
| Lean | `./verificar.sh` | EXIT 0: 9 módulos, 66 teoremas, 0 sorry |
| Libro (hallazgos) | `python3 verificacion/comprobar_hallazgos.py` | OK |
| Libro (identidades) | `python3 verificacion/comprobar_identidades.py` | OK |
| Libro (secundarios) | `python3 verificacion/comprobar_secundarios.py` | OK |
| Compilación libro | `typst compile main.typ` | EXIT 0, 275 pp, 6.1 MB |
| Rust fmt | `cargo fmt --check` | OK |
| Rust clippy | `cargo clippy --all-targets --locked -- -D warnings` | OK |
| Rust tests | `cargo test --locked` | **65 tests** (21 lib + 21 checker + 5 contratos + 8 ASPIC+ + 10 extractor) |
| Rust offline | `cargo build --locked --offline` | OK |
| Doctor | `cargo run -- doctor --repo ..` | 12 sondas OK, exit 0 |
| Inventory | `cargo run -- inventory` | 23 archivos, 394 bloques, 0 macros desconocidas |
| Evidence (piloto) | `cargo run -- evidence --repo ..` | 6 recibos generados |
| Check (piloto) | `cargo run -- check --kernel kernel/piloto_ch5_ssch.json --receipts receipts/` | **6 ACEPTADOS** (5 LeanChecked + 1 Reproduced), exit 0 |
| Audit | `cargo run -- audit` | Sin discrepancias (6 claims vs 394 bloques) |
| Render | `cargo run -- render` | 6 fichas, determinismo verificado |
| Argue | `cargo run -- argue` | 6 argumentos, 0 ataques, todos grounded_in |
| Check (corpus) | `cargo run -- check --kernel kernel/libro_completo.json` | 35 PENDIENTE (sin recibo), 0 RECHAZADO, exit 3 |

## Cobertura exacta con denominadores

| Métrica | Numerador | Denominador | Estado |
|---|---|---|---|
| Bloques thm-env en el libro | 394 | 394 | inventariados |
| Afirmaciones objetivas | 219 | 219 | clasificadas |
| Claims en el kernel | 218 | 219 | 1 sin key → SEMANTIC_MAPPING_UNRESOLVED |
| Con respaldo Lean | 35 | 219 | 16% del corpus objetivo |
| Pendientes NO_FORMAL_PROOF | 183 | 219 | 84% pendiente |
| Argumentos en el kernel | 35 | 35 | todos LEAN_ANCHOR |
| Recibos generados (piloto) | 6 | 35 | 29 faltan (exporter Lean no corrido para todos) |
| Claims verificados end-to-end | 6 | 219 | PILOT_VERIFIED |

## Estados del proyecto

| Estado | Valor | Justificación |
|---|---|---|
| SOFTWARE_READY | **SÍ** | Workspace Cargo con CLI completa, 65 tests verdes, fmt/clippy/offline en verde |
| CORPUS_INDEXED | **SÍ** | 394 bloques inventariados, 219 clasificados, 218 en kernel |
| PILOT_VERIFIED | **SÍ** | 6 claims del piloto verificados end-to-end: exporter Lean + runner SSCH + receipts + checker + argue |
| CORPUS_CLOSED | **NO** | 183/219 pendientes NO_FORMAL_PROOF; 29/35 sin receipts del exporter Lean |

## Pendientes explícitos

1. **29 theoremas sin receipts**: el exporter Lean se corrió solo para los 5
   del piloto. Para los otros 30 (35 total en el kernel), se necesita
   correr el exporter y generar los recibos correspondientes.

2. **183 claims sin respaldo Lean**: la mayoría son examples y proposiciones
   del libro que no han sido formalizadas. Cada uno tiene su entrada en
   `kernel/pendientes.json` con razón, fuente e impacto.

3. **1 bloque sin key**: un example en `cap04_herramientas.typ` sin clave
   de referencia (`SEMANTIC_MAPPING_UNRESOLVED`).

4. **GLM**: `LIVE_PROVIDER_PENDING` — sin endpoint configurado en esta VM.
   El adaptador con replay determinista está implementado y probado.

## Comandos de uso

```bash
cd argumentos

# Diagnóstico del entorno (12 sondas)
cargo run -- doctor --repo ..

# Inventario del libro (394 bloques)
cargo run -- inventory --book ../book_stat_inference_v0 --out inventory/libro.json

# Evidencia del piloto (6 recibos)
cargo run -- evidence --repo ..

# Verificación del piloto (6 ACEPTADOS)
cargo run -- check --kernel kernel/piloto_ch5_ssch.json --receipts receipts/

# Auditoría estructural
cargo run -- audit --kernel kernel/piloto_ch5_ssch.json --book ../book_stat_inference_v0

# Render de fichas (determinista)
cargo run -- render --kernel kernel/piloto_ch5_ssch.json --inventory inventory/libro.json --out generated/

# Análisis ASPIC+
cargo run -- argue --kernel kernel/piloto_ch5_ssch.json

# Corpus completo (35 PENDIENTE — esperado)
cargo run -- check --kernel kernel/libro_completo.json
```

## Límites declarados

- El checker Rust administra referencias y reglas declaradas; no
  interpreta matemática arbitraria (ADR-02).
- La proyección ASPIC+ no eleva la fuerza de una evidencia (ADR-06):
  `grounded_in` ≠ `lean_checked`.
- Un LLM no puede certificar equivalencia semántica de toda la prosa
  (ADR-05); la extracción se etiqueta como revisión semántica no
  certificada.
- Las pruebas matemáticas nuevas y las aplicaciones no triviales de
  teoremas deben comprobarse en Lean; no se implementa un demostrador
  matemático improvisado basado en coincidencias de palabras.
