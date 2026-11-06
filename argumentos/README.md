# argumentos — canon de argumentos verificables del libro

Implementación del paquete `spec/argumentos_construccion_v1/` (contratos,
reglas y plan F0–F8). El kernel JSON es la fuente maestra de afirmaciones,
argumentos y evidencias; este crate es el checker local: administra
referencias, alcance y reglas declaradas. No interpreta matemática (eso
vive en Lean, `../verificacion_lean/`) ni produce teoremas desde
experimentos (eso son recibos Python).

## Compilar y probar

```bash
cd argumentos
cargo build --locked          # la primera vez descarga de crates.io
cargo test  --locked
cargo fmt --check
cargo clippy --all-targets --locked -- -D warnings
```

Linux: Rust 1.93 (de sistema o vía rustup), sin servicios externos.
Offline: tras una build con red, `cargo build --locked --offline`.
Otras plataformas: sin probar; no hay código específico de Unix más allá
de subprocesos (`Command`) en `doctor`.

## CLI

```bash
cargo run -- doctor --repo ..   # entorno: rutas, versiones, manifiesto del spec
```

Exit codes (contractuales): 0 válido · 2 entrada inválida · 3 dependencia
bloqueante · 4 fallo de ejecución · 5 timeout/recurso · 6 discrepancia
editorial. Los comandos `inventory/propose/check/evidence/audit/render/
argue/release/report` se añaden en F2–F6.

## Capas de carga (ninguna decide verdad)

1. `strict_json`: parser propio — claves duplicadas, `NaN`/`Infinity`,
   números no finitos (`1e999`), comas finales, BOM y controles sin
   escapar son rechazados con línea y columna.
2. `jsonschema` (sin red) contra los esquemas del paquete, embebidos en
   el binario (`KERNEL_SCHEMA`, `RECEIPT_SCHEMA`).
3. serde tipado (`deny_unknown_fields`) + unicidad de IDs.
4. Recibos: consistencia en código además de esquema
   (`execution_passed ⇒ termination=completed ∧ exit_status=0`).

## Estado

F0 PASSED (baseline en `BASELINE.md`, STATE en `progress/STATE.json`).
F1: workspace + `doctor` + tipos + JSON estricto + pruebas de contrato.
Fases F2–F8: ver `spec/argumentos_construccion_v1/docs/07_PLAN.md`.
