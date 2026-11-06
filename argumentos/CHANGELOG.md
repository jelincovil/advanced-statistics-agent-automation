# CHANGELOG — argumentos

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
