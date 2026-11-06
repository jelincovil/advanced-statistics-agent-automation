# Plan completo con puertas de aceptación

## F0 — Reconocer y preservar
Inventario del repo real, git diff, baseline de tests pertinentes, fuentes Lean y libro. Entregables BASELINE.md y STATE.json. Puerta: ninguna modificación ajena perdida; HEAD y diferencias registrados; problemas heredados separados. Ejecutar tools/validate_package.py antes de usar fixtures.

## F1 — Contratos y entorno Rust
Construir workspace y CLI doctor; tipos serde con deny_unknown_fields donde corresponda; JSON Schema offline, claves duplicadas rechazadas; errores accionables. Resolver dependencias oficiales y fijar toolchain/Cargo.lock. Puerta: ejemplos positivos parsean; negativos fallan por razón esperada; cargo test --locked funciona. Añadir README de instalación Linux y limitaciones de otras plataformas.

## F2 — Checker independiente
IDs, DAG de soporte, AST exacta, reglas del registro, obligaciones, scope y estados derivados. Implementar invalidación transitiva y canonicalización con vectores de prueba. Puerta: todas las pruebas P01–P10 y N01–N18 aplicables pasan; no dependencia LLM/red en check. Property tests: cambiar evidencia nunca mantiene automáticamente estado vigente; permutar conjunto de entradas no cambia reporte canónico.

## F3 — Evidencias
Adaptadores Lean y Python; exporter de declaraciones y auditoría de axiomas; specs y receipts; cache con hashes. Piloto cuatro claves del capítulo 5 y SSCH exacto. Puerta: recomputación limpia, pruebas manipuladas rechazadas, alcance finito y correspondencias parciales declarados. No usar DR heredado como ancla sin corregir/verificar sus obligaciones científicas.

## F4 — Libro y render
Parser Typst, aliases, inventario de todas las fuentes incluidas, source maps y bloques generados. Puerta: etiquetas piloto mapeadas; fragmentos Unicode probados; render doble idéntico; macros desconocidas declaradas; prueba de cambios en hipótesis detectada en fixture.

## F5 — Agente GLM
Adaptador proveedor/replay, extracción con citas, candidatos y diff semántico. Puerta: replay determinista, salida malformada aislada, campos de aprobación del modelo rechazados. Prueba live solo con endpoint/modelo/credencial y presupuesto disponibles. Si falta, `LIVE_PROVIDER_PENDING` y continuar; no afirmar integración live terminada.

## F6 — Pickaxe
Proyección desde kernel; grounded; optional preferred con aceptación crédula/escéptica. Límites antes de grounding y durante ejecución. Puerta: fixtures pequeños contrastados con enumeración independiente; ausencia de extensiones/timeout manejados; informe no cambia estados Lean/Python. Exportar DOT/TGF y formato adicional solo si API real lo soporta. Archivar versión, parámetros y hashes de la proyección.

## F7 — Migración integral
Recorrer todas las afirmaciones objetivas candidatas del libro principal, no solo piloto. Crear argumentos, referencias y pendientes con razones. Vincular referencias existentes, sin formalizar todos los clásicos. Monografía M es corpus separado con IDs propios; incorporarla a un inventario secundario, no mezclar sus teoremas con los del libro español. Presentaciones se auditan como consumidores cuando haya correspondencia; prioridad libro. Registrar argumentos fuera de macros y cobertura de revisión por bloques. Puerta: cero candidatos descartados sin razón; cada bloque detectado tiene decisión o pendiente; no hay promoción de evidencia heredada no reproducida.

## F8 — Cierre reproducible
Ejecutar suite, lint y recuperación desde checkpoint. Reconstruir piloto desde checkout limpio. Emitir FINAL.md, manifest, trazabilidad, CLI help, ejemplo end-to-end y paquete de release local. Puerta: SOFTWARE_READY y PILOT_VERIFIED tienen evidencias; CORPUS_INDEXED se reporta con denominadores; CORPUS_CLOSED solo si todo alcance acordado está respaldado, de lo contrario pending_count explícito.

## No ampliar artificialmente
No dedicar el proyecto a demostrar nuevos resultados del libro para ocultar pendientes. El resultado correcto puede ser un sistema listo y una base con pendientes honestos. No declarar terminado si fallan los controles centrales o falta un adaptador requerido sin identificarlo como bloqueo.
