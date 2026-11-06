# Decisiones y alcance

## Mandato del autor
Se incluyen demostraciones, resultados formales, argumentos, ejemplos numéricos e implicaciones objetivas del libro. Un argumento consta de premisas, una cadena de pasos y conclusión. El kernel es autoridad de auditoría. Lo no respaldado se conserva pendiente. Las implicaciones de simulaciones no se convierten en afirmaciones universales o clínicas. GLM construye y mantiene el corpus con aprobación automática solo dentro de reglas comprobables.

## Decisiones técnicas
ADR-01: JSON tipado propio como fuente maestra; la proyección ASPIC+ es derivada. El JSON simple de pickaxe no puede portar por sí solo todo el contrato científico.
ADR-02: Lean sigue siendo la frontera de confianza matemática. Rust no interpreta matemática arbitraria ni decide equivalencia de fórmulas escritas en prosa.
ADR-03: Python produce evidencia de experimentos, no teoremas. Los recibos reproducibles y los resultados científicos son objetos diferentes.
ADR-04: Typst es el formato principal; no hay conversión obligatoria Typst→LaTeX→texto.
ADR-05: extracción y equivalencia editorial con LLM se etiquetan como revisión semántica no certificada. La generación canónica tiene comprobación exacta.
ADR-06: pickaxe analiza conflictos/aceptabilidad; esa salida no eleva la fuerza de una evidencia. Una regla strict de ASPIC+ no es automáticamente un teorema verdadero.
ADR-07: no se crean preferencias por prestigio, mayoría, longitud de una prueba o confianza del LLM. Sin preferencias justificadas, no se inventan.
ADR-08: kernel versionado por archivos y manifiesto, no un JSON gigante editado por varias tareas. El `theory.json` de exportación es un snapshot derivado y estable.
ADR-09: primera versión sin base vectorial ni servicio de base de datos. Git y JSON bastan; índices son reconstruibles.
ADR-10: los campos de estado son salidas del checker. Un importador ignora/rechaza cualquier intento de insertar un estado aprobado.

## Fuera de alcance inicial
Publicar servicios; sustituir el texto completo por generación automática; demostrar toda la matemática clásica; certificar validez externa de un simulador; probar formalmente el compilador Rust o Python; desarrollar un nuevo solver SAT; garantizar que la extracción LLM sea exhaustiva.

## Frontera de confianza
Confiamos en el kernel Lean y sus axiomas explícitos para el enunciado formal; en el runtime y código del experimento para observaciones computadas; en un checker Rust pequeño revisable para la trazabilidad y las reglas administrativas. El checker Rust no estará formalmente verificado en v1. Se documentan estas dependencias, sin llamarlo equivalente a Lean en fuerza de garantía. Un SHA-256 detecta cambio de bytes; no prueba veracidad, autoría o ejecución legítima.
