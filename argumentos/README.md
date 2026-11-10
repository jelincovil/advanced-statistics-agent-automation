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

Linux: Rust 1.99.1 de sistema, sin servicios externos. Lean 4.35.0 y
Mathlib 4.35.0 precompilada (`56a005855ea17e0b0958f73ec801ae140b0a1679`).
Offline: tras una build con red, `cargo build --locked --offline`.

## CLI y puerta completa

```bash
cargo run -- doctor --repo ..
cargo run -- evidence --repo .. --out ../evidencia/recibos
cargo run -- check --kernel kernel/libro_completo.json --receipts ../evidencia/recibos
cargo run -- inventory --book ../book_stat_inference_v0 --out ../evidencia/libro.json
cargo run -- audit --kernel kernel/libro_completo.json --book ../book_stat_inference_v0
```

Exit codes (contractuales): 0 válido · 2 entrada inválida · 3 dependencia
bloqueante · 4 fallo de ejecución · 5 timeout/recurso · 6 discrepancia
editorial. `check` distingue el estado de cada argumento del cierre
científico por claim. La puerta de aceptación es
`python3 ../repair_acceptance/verify.py --repo .. --out acceptance.json`.

## Capas de carga y confianza

1. `strict_json`: claves duplicadas, NaN/Infinity, no finitos, comas finales,
   BOM y controles sin escapar son rechazados.
2. JSON Schema del paquete, embebido en el binario.
3. Deserialización serde y unicidad de IDs.
4. Recibos: `execution_passed ⇒ termination=completed ∧ exit_status=0`.
   Un JSON importado entra como `UntrustedImport` aunque diga
   `locally_reproduced`. En el CLI solo se convierte en
   `AttestedByConfiguredPolicy` si el commit es ancestral y todos los hashes
   de los inputs actuales coinciden. El runner nuevo genera recibos
   `LocallyReproduced` con commit real, tipo elaborado, axiomas observados y
   hashes de todas las fuentes Lean. Cambiar una fuente invalida esa
   procedencia hasta regenerarla.

Las reglas proposicionales no prueban evidencia: AND, MP y ALIAS exigen
recibos válidos para toda especificación aportada. La invalidación se propaga
por dependencias hasta punto fijo sin eliminar alternativas independientes.
Los resultados negativos empíricos solo respaldan afirmaciones acotadas
compatibles (`claim_polarity=negative`), nunca la promoción positiva.

## Corpus actual

El kernel incluye enlaces efectivos para todas las specs; una duplicada no
válida está archivada en `archive/evidence_specs.json` con su sustitución.
Los dos pendientes científicos son `thm:appD-ibragimov` (solo núcleo
cuantitativo) y `thm:appD-gordin` (sin CLT funcional/Skorokhod). No se
consideran cerrados por tener argumentos auxiliares.

Documentación histórica F8: `reports/historico-2026-11-06/`, trazabilidad en
`reports/ARCHIVE.md`. Revisiones: `../repair_acceptance/claim_review.json`.
