# Operación, recuperación y límites

## Autonomía segura y útil
Autorizadas: implementación local, lectura del repo, tests, generación de candidatos, commits locales y correcciones acotadas con evidencia. No autorizado por este paquete: push/merge/publicación, envío de datos privados, pagos nuevos o borrado de trabajo ajeno. No detenerse para cada decisión rutinaria. Las credenciales se leen por entorno y nunca se copian al kernel.

## Recuperación
STATE.json contiene phase, base_commit, implementation_commit, completed_gates, pending_gates, blockers, commands_run y next_action. Al reanudar: inspeccionar git status y hashes antes de reutilizar resultados. Guardar checkpoint antes de experimentos costosos. Los logs grandes viven fuera del repositorio si son reconstruibles; los resúmenes y hashes se versionan. No confundir log faltante con prueba fallida; marcar evidence_unavailable y reproducir si es posible.

## Salidas alternativas
- Dependencia langextract incompatible: mantener interfaz Extractor y usar un adaptador directo al endpoint configurado; conservar formato de candidatos y replay. Documentar ADR y pruebas. No sustituir GLM sin aprobación.
- pickaxe no compila o excede recursos: mantener core; diagnosticar en framework pequeño con evaluador exhaustivo de referencia y marcar producción ASPIC bloqueada. No reportar SAT verificado.
- Lean no disponible: crear wrappers y specs como pendientes; continuar esquema, auditoría y tests puros. No reutilizar un dashboard como recibo nuevo.
- Tipos no exportables de manera estable: fijar serialización específica al entorno Lean y su versión; no degradar a regex como prueba de equivalencia.
- Typst dinámico: usar metadatos/query controlados o marcar bloque pendiente con fuente exacta; nunca omitir silenciosamente.
- Experimento no reproduce: conservar ambas salidas, comparar entorno y diseño; corregir solo con causa identificada, no ajustar tolerancia a posteriori.
- Corpus demasiado grande para un turno: checkpoint y continuar en siguiente sesión con la misma cola; no reducir alcance sin declararlo.

## Tiempo y recursos
Cada spec declara timeout y límites. Las pruebas piloto son pequeñas. No ejecutar todos los experimentos pesados heredados para construir un inventario. GLM tiene presupuesto de tokens/coste configurado; sin presupuesto, usar replay y el agente local sin llamadas auxiliares. Dos intentos fallidos razonados activan diagnóstico y alternativa, no abandono del trabajo independiente.

## Exportación
Expediente contiene snapshot kernel, reglas/checker version, Cargo.lock, versiones Lean/Mathlib/Python, specs, receipts, source references, logs o referencias persistentes a ellos, resultados y límites. Un paquete público excluye secretos y datos personales; la exportación local es la salida por defecto. Cada snapshot publicado recibe hash y no se sobreescribe.
