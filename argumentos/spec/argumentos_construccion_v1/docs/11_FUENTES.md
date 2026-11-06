# Fuentes primarias y procedencia
Consultadas para decidir la arquitectura el 2026-11-04. Verificar versiones/APIs al implementar; la documentación describe capacidades, no una prueba de integración local.

- https://docs.rs/pickaxe-rs/0.1.0/pickaxe_rs/ — ASPIC+, fragmento finito sin funciones, pipeline, SAT, exportaciones. Repositorio: https://github.com/alexjackson1/pickaxe
- https://docs.rs/langextract-rust/0.5.0/langextract_rust/ — extracción, providers y alineación. No se ha probado GLM 5.3. Repositorio documentado: https://github.com/modularflow/langextract-rust
- https://docs.rs/techxt/0.1.1/techxt/ — LaTeX-like a texto, no elegido para Typst.
- https://docs.rs/typst-syntax/0.15.1/typst_syntax/ — AST, Source, spans y parsing de Typst.
- https://docs.rs/jsonschema/latest/jsonschema/ — validación de estructura JSON; fijar versión en implementación.
- https://docs.rs/petgraph/latest/petgraph/ — grafos y algoritmos; no verificación lógica por sí solo.
- https://github.com/jelincovil/advanced-statistics-agent-automation/tree/0460b3f29f35eb0cb2b553712b9c7adb1e37ae77 — base del proyecto.

No se han compilado los crates como conjunto en esta entrega. No se ha certificado el proveedor GLM ni se han vuelto a ejecutar Lean/Python del repositorio al elaborar el paquete. El agente deberá producir esa evidencia durante F1–F8.
