# argumentos — canon de argumentos verificables del libro

El kernel JSON es la fuente maestra de afirmaciones, argumentos y evidencias; este crate calcula referencias, alcance, reglas y estados. Lean está en `../verificacion_lean/`; los experimentos Python tienen runners explícitos. **No se infiere equivalencia matemática por ejecución verde.**

## Compilar y probar

```bash
cd argumentos
cargo test --locked
cargo fmt --check
cargo clippy --all-targets --locked -- -D warnings
```

Probado con Rust 1.99.1; Lean 4.35.0 y Mathlib 4.35.0 (`56a005855ea17e0b0958f73ec801ae140b0a1679`). Crates en cache compatible permiten `--offline`.

## Flujo normal

```bash
cargo run -- verify --repo .. --out ../evidencia/recibos
cargo run -- inventory --book ../book_stat_inference_v0 --out ../evidencia/libro.json
cargo run -- audit --kernel kernel/libro_completo.json --book ../book_stat_inference_v0
```

`verify` ejecuta los runners permitidos genera recibos locales con entradas, tipos y axiomas observados, y evalúa en esa misma ejecución. Las premisas respaldadas son distintas de no confiabilidad importada. `check --receipts DIR` importa estrictamente; cualquier JSON, incluso con `locally_reproduced` o `attested_by_configured_policy`, pasa a `UntrustedImport`. **Un recibo importado es candidato, no confianza.** No hay atestación mediante commit o hashes aislados.

La puerta total versionada es `bash ../repair_acceptance/reproduce.sh --out /ruta-externa/nueva`.

## Reglas, obligaciones y estados

- `strict_json` → JSON Schema → serde → unicidad de IDs. Recibo: ejecución completa con código 0 si `execution_passed`.
- Toda spec aportada necesita procedencia reproducida en el flujo directo: mapa obligatorio, runner, objetivo y tipo, entorno y axiomas.
- AND_INTRO, MODUS_PONENS y ALIAS_EXACT no aprueban sin recibos. LEAN_APPLY preserva obligaciones. MP exacto no confunde estructura con evidencia.
- Invalidación transitiva por dependencias; alternativas válidas independientes permanecen.
- EMPIRICAL_RECORD enlaza criterio: negativo solo respalda una afirmación negativa acotada explícita, no promueve positiva.
- Duplicados válidos contradictorios son ambiguos/pendientes; orden o nombre del artifacto no decide.
- El estado se computa por `claim`, además del argumento: huérfanos, condicionales y pendientes son explícitos.

El estado científico y matriz están en `../repair_acceptance/claim_review.json` y `semantic_reviews.json` (colección automática distinta de `agent_reviewed`). Dos deudas permanecen: conclusión distribucional de Ibragimov y CLT funcional/Skorokhod de Gordin.
