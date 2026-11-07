# CHANGELOG — argumentos

## F6 — ASPIC+ y argumentación (2026-11-06)

- **Decisión arquitectónica**: pickaxe-rs se evaluó (compiló con
  pickaxe-rs 0.1.0) pero devolvía extensiones grounded vacías para
  sistemas de solo premisas sin reglas — su pipeline ASPIC+ construye
  argumentos encadenando reglas, no desde premisas desnudas. Se eliminó
  la dependencia y se implementó el **evaluador de referencia** como
  método primario (docs/12: "el verificador de referencia enumera
  conjuntos conflict-free y defensa para ≤8 argumentos"). Es más simple,
  revisable y correcto para el caso del piloto.
- **`src/aspic.rs`**: proyección del kernel al grafo de ataque abstracto;
  grounded por **fixpoint de la función característica** F(E) = {a :
  todo atacante de a es atacado por algún miembro de E} (Dung 1995);
  preferred por enumeración exhaustiva de subconjuntos conflict-free
  maximales (≤8 argumentos). Presupuesto: 64 argumentos máximo, al
  exceder marca `BudgetExceeded` / INCOMPLETE.
- **Estados de argumentación** (docs/04, eje `argumentation`):
  `grounded_in`, `grounded_out`, `undecided`, `budget_exceeded`, `not_run`.
- **Aceptación crédula** (alguna extensión) vs **escéptica** (todas)
  reportadas por separado (docs/04).
- **La proyección NO eleva fuerza** (ADR-06): `grounded_in` ≠
  `lean_checked`; el eje formal lo decide el checker.
- CLI `argue --kernel PATH [--preferred]`.

Pruebas: **8 tests ASPIC+** — casos de referencia docs/12 (sin ataques
→ grounded incluye; ataque mutuo → grounded vacío; cadena A→B→C →
grounded {A,C}; autataque → grounded vacío), proyección del piloto
(todos grounded_in, referencia coincide), preferred (crédula =
escéptica sin ataques), presupuesto excedido (INCOMPLETE), proyección
no eleva fuerza.

Puerta F6: `cargo fmt --check` ✓ · `cargo clippy -D warnings` ✓ ·
`cargo test --locked` ✓ (**65 tests**) · `argue` → 6 argumentos, 0
ataques, todos grounded_in, referencia COINCIDE ✓. **PASSED.**

## F5 — Agente GLM: replay determinista (2026-11-06)

- **Trait `Extractor`** (docs/12: no acoplar a langextract): entrada con
  bloques y bytes exactos, salida con candidatos citados. Errores tipados.
- **`ReplayExtractor`**: reproduce exactamente una respuesta archivada.
  Determinista: la misma entrada produce la misma salida. Sin red.
- **`LiveExtractor`**: stub que devuelve `ProviderUnavailable` sin
  endpoint configurado. `LIVE_PROVIDER_PENDING` (docs/09 salida
  alternativa) — no se afirma integración live terminada.
- **`ProviderConfig`**: configuración del proveedor según
  templates/provider.example.json (replay por defecto, sin credenciales).
- **Alineador** (`verify_quote`): `text[start:end] == quote` con offsets
  UTF-8 de BYTES (docs/06). Probado con «cañón» (2 bytes por carácter).
- **Diff semántico**: comparación exacta de scope/kind/assumptions
  primero, redacción después (docs/06). Clasificación en 9 tipos.
- **`ClaimDraft`** con `deny_unknown_fields`: campos de aprobación del
  modelo rechazados (ADR-10, N10).
- CLI `propose`: construye la solicitud de extracción, ejecuta el
  extractor, valida citas y escribe candidatos.

Pruebas: **10 tests del extractor** — P08 (replay determinista dos veces,
sin archivo → error claro), salida malformada aislada (JSON duplicado y
estructura incorrecta), campos de aprobación rechazados, alineador con
UTF-8 bytes («cañón»), rangos fuera de límites, LiveExtractor sin
endpoint → ProviderUnavailable, configuración replay por defecto.

Puerta F5: `cargo fmt --check` ✓ · `cargo clippy -D warnings` ✓ ·
`cargo test --locked` ✓ (**57 tests**: 21 lib + 21 checker + 5 contratos
+ 10 extractor). **PASSED.** `LIVE_PROVIDER_PENDING` — sin endpoint GLM
en esta VM.

## F4 — Libro y render (2026-11-06)

- **Parser Typst** (`src/book.rs`): typst-syntax 0.15.1 (alineada con el
  binario del repo). `scan_book` recorre `main.typ`, sigue los
  `#include` (detectados como `ModuleInclude` en el AST) y escanea cada
  archivo incluido. Extracción de bloques `thm-env` navegando el árbol
  sintáctico (nada de regex): `FuncCall → Args → [Str(kind), Named(name),
  Named(key), ContentBlock(body)]`. Rangos de bytes UTF-8 del contenido
  sin corchetes. SHA-256 de cada archivo fuente.
- **Inventario**: 23 archivos, **394 bloques thm-env**, 392 etiquetas
  `<...>`, **0 macros desconocidas** (las estándar de Typst y las del
  libro documentadas en el código). Inventario JSON serializable.
- **Source maps**: cada bloque registra archivo, rango de bytes
  [start, end) del contenido, y SHA-256 del archivo (docs/03).
- **Render determinista**: fichas .typ por claim del kernel con
  enunciado, alcance, supuestos y referencia al bloque del libro.
  Verificado con doble render idéntico.
- **Auditoría estructural**: cada `book_key` del kernel debe existir en
  el inventario. Las 5 claves del piloto mapean; sin discrepancias.
- CLI: `inventory`, `render`, `audit`.

Puerta F4: `cargo fmt --check` ✓ · `cargo clippy -D warnings` ✓ ·
`cargo test --locked` ✓ (47 tests) · `inventory` → 394 bloques, 0
desconocidas ✓ · `render` → 6 fichas, determinismo ✓ · `audit` → sin
discrepancias, exit 0 ✓. **PASSED.**

## F3 — Evidencias Lean y Python (2026-11-06)

- **Exporter Lean** (`evidence/lean_export.lean`): consulta el entorno
  elaborado vía APIs públicas (`Lean.collectAxioms`,
  `Lean.ConstantInfo.getUsedConstantsAsSet`, `Meta.ppExpr`) — nada de
  regex sobre consola. Emite JSONL a stdout: nombre fully-qualified, tipo
  elaborado serializado estable, dependencias directas y axiomas
  transitivos. Los 5 objetivos del piloto exportan con los 3 axiomas
  estándar del proyecto y 44–120 dependencias directas cada uno.
- **Runner Python SSCH** (`runners/ssch_bayes_racional.py`): enumeración
  racional exacta con `fractions.Fraction`; riesgo de Bayes 19/50, R(0)
  = 1/5, R(1) = 4/5; criterio preregistrado bayes == 19/50.
- **Kernel del piloto** (`kernel/piloto_ch5_ssch.json`): 6 claims (5
  formales del cap. 5 + 1 empírico SSCH), 6 argumentos (5 LEAN_ANCHOR +
  1 EMPIRICAL_RECORD), 6 evidence_specs con scopes declarados
  (finite_specialization, statement_scope por teorema, lean_axioms).
- **CLI `evidence`**: ejecuta ambos runners, parsea las salidas, genera
  recibos con hashes SHA-256 (spec_hash, stdout_sha, input_hashes de los
  fuentes) y los escribe a `receipts/`.
- **CLI `check --receipts`**: valida el kernel completo contra los
  recibos. Los 6 argumentos ACEPTADOS: 5 formal=LeanChecked +
  1 empirical=Reproduced. Exit 0.

Puerta F3: `cargo fmt --check` ✓ · `cargo clippy -D warnings` ✓ ·
`cargo test --locked` ✓ (47 tests) · `evidence --repo ..` genera 6
recibos ✓ · `check --kernel kernel/piloto_ch5_ssch.json --receipts
receipts/` → 6 ACEPTADOS exit 0 ✓ · los 6 recibos son JSON válido ✓.
**PASSED.**

## F2 — Checker independiente (2026-11-06)

`src/check.rs` (~470 líneas): el motor del canon. Sin red, sin LLM, sin
procesos — recibe objetos cargados y emite un reporte reproducible.

- **Resolución de IDs** (N06): conclusión, premisas, specs y supuestos
  deben referenciar afirmaciones existentes.
- **Grafo de dependencia** (petgraph, DiGraphMap + Dfs): dos familias de
  aristas — conclusión→premisa (argumentos) y afirmación→supuesto
  (docs/03: los supuestos referencian otras afirmaciones). Ciclo
  per-argumento (N07): si la conclusión es alcanzable desde las premisas
  del propio argumento, la derivación es circular; las reglas
  alternativas acíclicas siguen válidas (N19).
- **Reglas del registro** (docs/04): LEAN_ANCHOR (spec lean + alcance
  compatible + axiomas estándar + recibo reproducido), LEAN_APPLY (el
  wrapper esperado es parte del spec — prohibido aprobar porque `lean`
  compiló otro teorema), AND_INTRO (AST exacta And(P,Q)), MODUS_PONENS
  (AST exacta: una premisa Implies(A,B), la otra A, conclusión B —
  contrato del paquete), EMPIRICAL_RECORD (solo afirmaciones empíricas;
  N08: sin promoción a teorema), CONDITIONAL_APPLICATION (conclusión
  condicional; H queda abierta), ALIAS_EXACT (misma expresión y alcance).
- **Obligaciones**: unión sin duplicados (docs/04); monótonas — la regla
  solo descarga con evidencia del tipo requerido (P06, N18).
- **Alcance** (N03): igualdad exacta premisa↔conclusión, con la excepción
  de CONDITIONAL_APPLICATION que puede añadir claves (el escenario,
  docs/04.6) pero nunca cambiar las existentes.
- **Estados ortogonales** (docs/04): structure/formal/empirical/editorial
  derivados de la decisión — `reproduced` no implica `lean_checked`.
- **Invalidación transitiva** (N05): recibo con `spec_hash` distinto al
  hash canónico del spec → stale y ejes stale.
- **Canonicalización** (P07): reporte con IDs ordenados, arrays ordenados
  y hash SHA-256 determinista; permutar entradas no lo cambia.
- **Guarda de rutas** (N12): `..` y symlinks rechazados.
- CLI `argumentos check --kernel PATH [--receipts PATH]`: reporte humano
  por argumento con los cuatro ejes; exit 0/2/3 contractuales.

Decisiones documentadas: (1) los supuestos referencian afirmaciones y son
aristas de dependencia — semántica del validador del paquete, confirmada
por su fixture de ciclo; (2) igualdad de alcance premisa↔conclusión
salvo la regla condicional — el validador del paquete usa igualdad
estricta, docs/04.6 exige poder declarar el escenario; (3) MODUS_PONENS
alineado al contrato exacto del paquete (una premisa es Implies(A,B)).

Pruebas: **21 tests del checker** — P01–P07 (P01–P05 como fixtures
estructurales del piloto: alcance finito registrado, optimizadores no
afirmados sin wrapper, dominancia par a par, hipótesis
Nonempty/Fintype conservadas, SSCH empírico acotado) y N01, N02, N03,
N04, N05, N06, N07, N08, N10, N11, N12, N18, N19 + contraste directo
con los fixtures del paquete (el positivo aceptado en estructura; los
seis negativos de reglas rechazados por su razón clasificada). Las dos
propiedades del plan (cambiar evidencia nunca mantiene estado vigente;
permutar entradas no cambia el reporte canónico) están cubiertas como
tests deterministas dirigidos (N05 y P07) — proptest no aporta valor
adicional sobre estos casos y no se añadió.

Puerta F2: `cargo fmt --check` ✓ · `cargo clippy --all-targets --locked
-- -D warnings` ✓ · `cargo test --locked` ✓ (47 tests: 21 lib + 21
checker + 5 contratos) · smoke CLI: fixture positivo →
ACEPTADO_CONDICIONAL exit 0; `invalid_scope` → RECHAZADO exit 3.
**PASSED.** Subconjunto no aplicable a F2 (puertas de F3–F6): P08–P10,
N09, N13–N17, N20–N24.

## F1 — Contratos y entorno Rust (2026-11-06)

Workspace Cargo `argumentos/` (crate único con fronteras por módulo,
ADR-11) con:

- `src/strict_json.rs`: parser JSON estricto propio (~300 líneas):
  claves duplicadas, `NaN`/`Infinity`, números no finitos (`1e999`),
  ceros iniciales, comas finales, BOM, controles sin escapar y contenido
  tras la raíz rechazados; errores con línea y columna; enteros exactos
  conservados (2^53+1 no pasa por f64); pares sustitutos UTF-16.
- `src/model.rs`: tipos del kernel v1 (Kernel/Claim/Argument/EvidenceSpec,
  AST `atom/implies/and`, 7 reglas del registro) y carga en capas:
  JSON estricto → JSON Schema embebido (`additionalProperties: false`
  en todos los niveles) → serde tipado → unicidad de IDs. Sin campos de
  aprobación (ADR-10).
- `src/receipt.rs`: recibos con el esquema del paquete + consistencia en
  código: `execution_passed ⇒ termination=completed ∧ exit_status=0`.
- `src/main.rs`: CLI `argumentos doctor` — 12 sondas (rutas del repo,
  versiones de rustc/cargo/typst/lean/python3, smoke de typst-syntax,
  verificación SHA-256 del manifiesto del spec). Exit codes
  contractuales.
- Tests: 21 unitarios + 5 de contrato contra los fixtures del paquete
  (positivos cargan; `invalid_duplicate_id` → DuplicateId;
  `invalid_self_approval` → Schema; los 6 negativos de reglas cargan
  estructuralmente — su rechazo es la puerta de F2; ida y vuelta
  canónica).
- Dependencias resueltas y fijadas (`Cargo.lock`, 103 paquetes):
  serde 1.0.229, serde_json 1.0.154, jsonschema 0.60.2 (sin features de
  red), clap 4.6.7, thiserror 2.0.21, sha2 0.10.9, typst-syntax 0.15.1
  (coincide con el binario typst del repo), petgraph 0.8.3 (para F2).
- Toolchain: rustup estable 1.99.1 instalada (perfil minimal + rustfmt +
  clippy; el Rust de sistema 1.93.1 carecía de ambos componentes y la
  puerta los exige), pineada en `rust-toolchain.toml`.

Puerta F1: `cargo fmt --check` ✓ · `cargo clippy --all-targets --locked
-- -D warnings` ✓ · `cargo test --locked` ✓ (26 tests) · build y test
offline ✓ · `doctor` exit 0 con 12 sondas OK. **PASSED.**

## F0 — Reconocer y preservar (2026-11-06)

Baseline completo en `BASELINE.md`: HEAD real vs `0460b3f` del paquete
documentado (no se restaura), inventario del árbol, herramientas
verificadas (Rust, typst 0.15.1, Lean 4.33.1, Python 3.12.14), controles
de línea base ejecutados (validate_package PASS, check_schema PASS,
verificar.sh exit 0 con 9 módulos/66 teoremas/0 sorry, comprobar_*.py OK,
typst compile exit 0 275 pp), riesgos de docs/10 re-verificados, trabajo
ajeno preservado (t27+t28 commiteados como `1c98d6b` antes de crear
`argumentos/`). Paquete copiado a `spec/` con manifiesto verificado.
**PASSED.**
