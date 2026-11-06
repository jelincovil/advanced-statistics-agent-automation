# Arquitectura a implementar

`argumentos/` contiene un workspace Cargo y datos independientes del código:
- crates/arg-model: tipos, lectura estricta y versiones de esquema.
- crates/arg-check: resolución de IDs, reglas, alcance, obligaciones, cálculo de estados e invalidación.
- crates/arg-evidence: runners Lean/Python y recibos emitidos por el verificador.
- crates/arg-book: lectura Typst, manifiesto editorial y render de fichas.
- crates/arg-extract: interfaz LLM, langextract opcional, replay de respuestas y propuestas.
- crates/arg-aspic: conversión explícita a pickaxe y análisis acotado.
- crates/arg-cli: CLI y reportes JSON/Markdown.
- kernel/claims, kernel/arguments, kernel/evidence_specs: archivos autoritativos.
- kernel/releases: snapshots inmutables aceptados, manifiestos y hashes.
- candidates: propuestas que aún no son autoridad.
- receipts: evidencia de ejecuciones; reports y generated: productos derivados.
- inventory, tests/fixtures, progress, docs: trazabilidad y mantenimiento.

No se impone que cada módulo sea un crate si eso duplica demasiado código. arg-check no depende de red, langextract o pickaxe. Su API recibe objetos ya cargados y emite un resultado reproducible con diagnósticos ordenados.

## Flujo
Captura del repo → inventario → propuesta GLM → validación estructural → obligaciones Lean/Python → chequeo de argumentos → snapshot → render/auditoría → análisis ASPIC+ → expediente.
La auditoría puede crear candidatos nuevos; no modifica silenciosamente un snapshot.

## Selección de dependencias
Base: serde, serde_json, jsonschema, petgraph, sha2, clap, thiserror. Test: proptest y tempfile si aportan casos reales. CLI orquesta procesos mediante std::process::Command, con argv separado, jamás eval/shell sobre contenido del corpus. typst-syntax se fija alineado con la versión de Typst del repo. langextract-rust es una feature optativa y reemplazable. pickaxe-rs usa inicialmente el backend SAT por defecto documentado, con un presupuesto explícito de grounding, argumentos, tiempo y memoria.

Las versiones observadas en documentación durante la preparación fueron pickaxe-rs 0.1.0, langextract-rust 0.5.0, techxt 0.1.1 y typst-syntax 0.15.1. Son observaciones, no una matriz de compatibilidad comprobada. Resolver versiones reales en F1, ejecutar pruebas y fijar Cargo.lock. No usar dependencias Git flotantes. Añadir licencias y versión/commit exactos a DEPENDENCIES.md.

## CLI contractual (interfaz propuesta, aún no implementada)
- argumentos doctor: entorno, rutas, versiones y disponibilidad, sin credenciales.
- argumentos inventory --repo PATH --out inventory.json
- argumentos propose --inventory PATH --provider-config PATH / --replay PATH
- argumentos check --kernel PATH --receipts PATH --json PATH
- argumentos evidence run --spec ID: ejecuta un experimento o wrapper autorizado.
- argumentos audit --book PATH --kernel PATH --mode structural|semantic
- argumentos render --kernel PATH --out generated/
- argumentos argue --kernel PATH --semantics grounded --budget PATH
- argumentos release --kernel PATH --receipts PATH --out releases/
- argumentos report --release PATH --out reports/

Exit codes: 0 operación válida; 2 entrada/contrato inválido; 3 obligaciones o dependencias bloqueantes; 4 fallo de ejecución; 5 timeout/recurso; 6 discrepancia editorial. Un `check` puede producir un reporte completo aunque termine 3. Una release de catálogo puede contener pendientes; se etiqueta `catalog`, nunca `verified_corpus`. `release --require-verified` falla si hay pendientes del alcance declarado.
