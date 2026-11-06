# Contratos de datos v1

El esquema adjunto define el intercambio inicial del piloto. No pretende representar toda la lógica matemática. Los futuros cambios requieren schema_version, migración y prueba de ida/vuelta. Un validador JSON Schema comprueba forma; el checker comprueba referencias, alcance y reglas. Ningún schema decide verdad.

## Afirmaciones
ID estable independiente de numeración de capítulos; book_key conserva claves históricas. kind = formal | empirical | conditional | factual. statement es prosa no confiable como lógica. expression es una AST mínima: atom, implies, and. Cada átomo tiene ID con significado registrado; dos IDs no son iguales por similitud textual. No se comparan fórmulas matemáticas por normalización de strings.

scope enumera experimento, población, escenario, horizonte, unidad y dominio cuando correspondan. `assumptions` referencia otras afirmaciones. Los supuestos son obligaciones, no verdades concedidas universalmente. La cuantificación matemática reside en un enunciado Lean tipado; no se deduce de un campo escrito por el agente.

## Argumentos
conclusion referencia una afirmación. premises, rule y evidence_specs determinan cómo verificarla. Cada argumento es una derivación finita. Dos argumentos pueden concluir la misma afirmación; se evalúan por separado. Una dependencia circular no se acepta como prueba, aunque un framework de ataques permita ciclos.

## Evidencia y recibos
El spec define lo que se va a ejecutar y qué afirmación exacta respalda. `source_commit`, `inputs`, `environment`, `criterion` y límites forman parte del spec. Un recibo contiene spec_hash, input_hashes, environment_hash, command_argv, working_directory, start/end, exit_status, stdout/stderr hashes, artifacts, observed_checks y checker_version. Distinguir `execution_passed` de `scientific_criterion_met` y de `claim_supported`.

Un recibo ingresado por el agente es candidato. Para certificar en una máquina nueva se reproduce o se verifica bajo una política explícita de atestación; no basta el JSON ni su hash. Estado de caché válido requiere coincidencia de todos los hashes y validador. Tiempo de ejecución no entra en el hash del núcleo semántico.

## Posiciones y texto
source_ref = commit, path, file_sha256, book_key y rango de bytes UTF-8 [start,end). Se conserva fragmento exacto y su hash. Si se transforma a texto limpio, almacenar mapa de posiciones hacia la fuente. Un offset del texto limpio no es un offset de Typst. No sustituir bytes por índices de caracteres Unicode. Si el mapeo es ambiguo, editorial = pending.

## Canonicalización
Para v1 usar JSON UTF-8 con orden fijo de claves, orden de arrays semánticos conservado y arrays de conjuntos explícitos ordenados por ID. Prohibir IDs duplicados, claves JSON duplicadas, NaN/Infinity y rutas que escapen del repo. Números matemáticos exactos se expresan como racionales o strings de términos, no floats JSON. Medidas empíricas usan valores finitos y metadatos de precisión. Publicar la especificación y vectores de prueba del serializer Rust; no afirmar compatibilidad RFC 8785 sin implementarla.

Hash de release = manifiesto de rutas relativas y SHA-256 de bytes canónicos. Git commit añade procedencia, pero no sustituye los hashes de datos y entorno. Las evidencias derivadas de un corpus diferente son stale incluso si comparten nombre.
