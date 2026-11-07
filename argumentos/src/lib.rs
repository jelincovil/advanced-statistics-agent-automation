//! ARGUMENTOS — canon de argumentos verificables del libro.
//!
//! Capas (docs/02_ARQUITECTURA.md, consolidadas en un crate con fronteras
//! por módulo — ADR-11 del proyecto):
//! - [`strict_json`]: JSON estricto (claves duplicadas, NaN/Infinity y
//!   números no finitos rechazados; posiciones en errores).
//! - [`model`]: tipos del kernel v1 y carga estricta en tres capas
//!   (JSON estricto → JSON Schema → serde tipado → unicidad de IDs).
//! - [`receipt`]: recibos de evidencia con consistencia código+esquema.
//!
//! Frontera de confianza (docs/01): el checker Rust administra referencias,
//! alcance y reglas declaradas; la matemática vive en Lean y la evidencia
//! empírica en experimentos con recibo. Ningún campo de estos tipos
//! representa un estado de aprobación aceptado por entrada: los estados
//! son salidas del checker (fase F2).

pub mod book;
pub mod check;
pub mod extract;
pub mod model;
pub mod receipt;
pub mod strict_json;

/// Versión del checker (parte del entorno de un recibo).
pub const CHECKER_VERSION: &str = env!("CARGO_PKG_VERSION");
