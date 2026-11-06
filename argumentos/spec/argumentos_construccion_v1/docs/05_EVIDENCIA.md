# Evidencia Lean y Python

## Adaptador Lean
Respetar el entorno del repo: el runner existente usa Lean directo y LEAN_PATH. Inspeccionar toolchain y Mathlib reales, no actualizar para facilitar una prueba. Escribir un exporter pequeño en Lean o usar una interfaz que consulte declaraciones elaboradas; no extraer tipos por regex ni aceptar solo mensajes de consola como vínculo semántico.

Para cada ancla: nombre fully-qualified, tipo elaborado serializado de manera estable para ese entorno, fuentes/hash, imports, Lean version, Mathlib revision, axiomas transitivos y resultado del wrapper. Rechazar sorryAx y axiomas añadidos no aprobados; permitir explícitamente los axiomas estándar documentados del proyecto. Auditar auxiliares transitivos. No confundir código que usa `axiom target : P` con demostración. No aceptar unsafe/native_decide como atajo fuera de política.

El piloto existente prueba identidades finitas con pesos reales. El libro incluye observaciones numerables. Registrar exactamente `finite_specialization`, no `full_statement_verified`. `ch9_admisibilidad` prueba equivalencia de dominancia entre dos reglas, no una declaración explícita de admisibilidad cuantificada; esta última puede añadirse mediante wrapper Lean. `ch9_bayes` prueba igualdad de promedios, no directamente el conjunto de optimizadores. Inventariar esas diferencias antes de elevar cobertura.

## Adaptador Python
No ejecutar código propuesto libremente desde JSON. El spec contiene un runner_id del registro autorizado y parámetros validados; los comandos son plantillas de argv del programa. Entorno aislado con límites de tiempo, memoria y red según posibilidades del host; si no hay aislamiento real, declararlo, sin fingir sandbox.

Separar tres clases: (a) identidad exacta computable con enteros/racionales; (b) test numérico determinista con tolerancia justificada; (c) experimento Monte Carlo. Solo (a) verifica una instancia exacta, no una familia infinita. (b) exige escala de error y referencia independiente. (c) exige diseño, semillas, réplicas, política, unidad independiente, estimando y error Monte Carlo.

Para cobertura, registrar éxitos/B, intervalo binomial o MCSE y criterio previo. No aprobar un teorema asintótico mediante B simulaciones. Registros de resultados anteriores deben importarse como legacy_unreproduced hasta reproducirlos. Semilla fija no garantiza identidad de floats entre plataformas. Comparar con tolerancias predefinidas; registrar BLAS, CPU, dependencias y contenedor cuando importen. Los metadatos temporales pueden variar sin cambiar el resultado científico.

## Experimento piloto recomendado
Usar el riesgo SSCH de una decisión y cuatro reglas, computado por enumeración racional: P0(X=1)=1/5, P1(X=1)=4/5; pérdida falso positivo 1 y falso negativo 4; prior de theta=1 igual a 3/10. Riesgos de seguir señal: (1/5,4/5), riesgo de Bayes 19/50. Comparar sumas independientes de pérdida y recompensa. Este ejemplo es sintético y exacto, no evidencia clínica.
Añadir una simulación separada opcional con B y n prefijados para estudiar convergencia a 19/50, reportando incertidumbre. No confundir ese experimento con el de cinco estados ni con el módulo DR heredado.

## Comparabilidad de versiones
Al cambiar código, datos, semilla, política, horizonte, criterio o entorno relevante se invalida el recibo. Al cambiar solo prosa se invalida la revisión editorial, no necesariamente la prueba. El manifiesto expresa estas dependencias de forma granular.
