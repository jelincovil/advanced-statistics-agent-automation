# DEPENDENCIES — argumentos

Resueltas contra crates.io en F1 (2026-11-06) con `cargo add` y fijadas en
`Cargo.lock` (103 paquetes). **Toolchain: rustup estable 1.99.1** (perfil
minimal + rustfmt + clippy), pineada en `rust-toolchain.toml` — el Rust de
sistema (1.93.1) carece de rustfmt/clippy y la puerta de calidad los
exige; se mantiene instalado pero el proyecto usa la versión pineada.
Reconstrucción offline: tras materializar dependencias (`cargo build` una
vez con red), `cargo build --locked --offline` funciona sin red (verificado).

## Directas

| Crate | Versión fijada | Uso | Nota |
|---|---|---|---|
| serde | 1.0.229 (+derive) | tipos del kernel | `deny_unknown_fields` en structs |
| serde_json | 1.0.154 | árbol de valores, serialización | el parser estricto es propio (`src/strict_json.rs`) |
| jsonschema | 0.60.2 (**sin features por defecto**) | validación de forma contra los esquemas del paquete | sin red: los esquemas no tienen referencias externas; la observación del paquete (docs/11) apuntaba a `latest`, se resolvió a 0.60.2 |
| clap | 4.6.7 (+derive) | CLI | códigos de salida contractuales |
| thiserror | 2.0.21 | errores tipados | |
| sha2 | 0.10.9 | hashes SHA-256 (doctor: manifiesto del spec; F3: recibos) | detecta cambio de bytes, no veracidad |
| typst-syntax | **0.15.1** | parser de fuente Typst (F4) | coincide exactamente con el binario `typst 0.15.1` del repo — la alineación que exigía docs/02 |
| petgraph | 0.8.3 | DAG de soporte (F2) | sin uso en F1; se añadió para fijar el lock completo |

## Observaciones

- El paquete (docs/11) observó pickaxe-rs 0.1.0, langextract-rust 0.5.0,
  techxt 0.1.1 y typst-syntax 0.15.1 «como documentación, no matriz
  comprobada». F1 comprobó typst-syntax; pickaxe/langextract se resuelven
  en F5/F6 cuando su fase lo exija, o se aplica la salida alternativa de
  docs/09 (interfaz propia + replay / diagnóstico con enumeración de
  referencia).
- Sin dependencias Git flotantes; todo desde crates.io con versión fijada.
- Licencias: MIT (serde/serde_json/clap/thiserror/petgraph/typst-syntax),
  MIT/Apache-2.0 (jsonschema, sha2/RustCrypto). Sin dependencias copyleft.
