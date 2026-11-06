# CHANGELOG — argumentos

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
