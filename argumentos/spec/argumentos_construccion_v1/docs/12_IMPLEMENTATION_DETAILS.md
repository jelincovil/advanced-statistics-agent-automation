# Detalles de implementación que evitan falsos positivos

## Modelo de derivación
Mantener un grafo bipartito: nodos de afirmación y nodos de aplicación de regla. Un argumento alternativo no invalida todos los demás. Buscar una derivación finita elegible; conservar todas las rechazadas con su causa. No usar mera alcanzabilidad como demostración: cada arista de apoyo corresponde a una aplicación cuyo contrato debe comprobarse. El grafo de ataques de pickaxe es diferente y admite ciclos.

## Políticas de estado
El resultado del checker incluye `decision`, `obligations`, `evidence_used`, `scope`, `diagnostics` y los cuatro ejes de evidencia. `decision=accepted_conditional` conserva hipótesis abiertas. Para una afirmación matemática, estructura válida sin recibo Lean no produce `lean_checked`. Para un dato observado, el recibo Python apoya una proposición sobre la ejecución; una interpretación científica adicional necesita argumento propio. El nivel de respaldo no se calcula por promedio, votos ni score de confianza del LLM.

## Evolución de versiones
Cada objeto tiene ID estable y revisión por contenido. Cambiar solo statement puede requerir revisión editorial aunque expression sea idéntica. Cambiar expression, hipótesis, alcance o spec invalida dependencias semánticas. Reglas de migración de schema son funciones versionadas; conservar el original y reporte de migración. Nunca usar timestamps como única invalidación.

## API del adaptador de evidencia
Entrada: spec validado, registro de runners, root permitido, presupuesto y dependencias resueltas.
Salida: recibo factual de ejecución + artefactos. El checker, no el runner ni el LLM, decide su compatibilidad con la afirmación. Separar proceso fallido, experimento con resultado adverso y evidencia insuficiente. El timeout no es refutación.
El esquema receipt.schema.json es una base estricta. `source_commit` se verifica contra el repo real; si hay working tree dirty, registrar hashes de todas las fuentes relevantes y marcar dirty explícitamente en el entorno. Reproducir en checkout limpio para la release final. `execution_passed=true` exige termination=completed y exit_status=0; esa consistencia se comprueba en código además de Schema.

## Integración de librerías
No acoplar los tipos del dominio a los tipos privados de pickaxe o langextract. Definir traits Extractor y ArgumentationEvaluator con errores tipados. Serializar una proyección auditable antes de llamar al solver. En pickaxe usar API documentada o CLI comprobada; no confiar en un comando sugerido sin `--help` del binario instalado. La representación de una negación, un ataque o una regla se valida con fixtures independientes.

## Pruebas de referencia para el solver
Un argumento sin ataques: grounded incluye ese argumento. Ataque mutuo A↔B: grounded vacío y preferred {A},{B}; aceptación de A crédula sí, escéptica no. Cadena A→B→C: grounded {A,C}. Autataque A→A: grounded vacío; semántica stable sin extensiones. Documentar si la API representa autataques y cómo se exportan. El verificador de referencia enumera conjuntos conflict-free y defensa para <=8 argumentos; no se usa como motor de producción grande.

## Prompts versionados
El prompt del agente autor y el del auditor se conservan separados. Un segundo pase del mismo modelo mejora detección, pero no constituye independencia estadística ni prueba de corrección. El agente puede arbitrar paráfrasis; la API de promoción de evidencia no está expuesta a esas decisiones. Conservar razones y citas exactas del arbitraje.

## Registro de pendientes
Cada pendiente requiere reason_code, fuente, obligación faltante, impacto y próxima acción. Códigos mínimos: NO_FORMAL_PROOF, EMPIRICAL_NOT_REPRODUCED, SCOPE_NOT_JUSTIFIED, SEMANTIC_MAPPING_UNRESOLVED, PROVIDER_UNAVAILABLE, DYNAMIC_TYPST, LEGACY_CONFLICT, RESOURCE_LIMIT. La lista tiene que poder filtrarse por capítulo y dependencia.

## Regla final de alcance
El agente construye la infraestructura y migra el corpus. No queda autorizado a afirmar nuevas garantías matemáticas o clínicas para cerrar pendientes. Los datos de simulación autorizan conclusiones condicionadas al experimento; la transferibilidad a otro mundo requiere un argumento nuevo.
