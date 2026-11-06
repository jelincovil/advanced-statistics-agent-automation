# Cálculo de argumentos y estados

## Reglas admitidas en v1
1. LEAN_ANCHOR: importa una declaración comprobada y su tipo. Un exportador Lean usa el entorno elaborado para obtener nombre plenamente cualificado, tipo, dependencias y axiomas. La cadena informal que describe la declaración conserva estado editorial independiente.
2. LEAN_APPLY: wrapper Lean comprueba que premisas instanciadas producen la conclusión deseada. Prohibido aprobar solo porque `lean` compiló otro teorema del archivo. El wrapper esperado forma parte del spec.
3. AND_INTRO: de expresiones P y Q obtiene exactamente And(P,Q), conservando la unión de obligaciones. Si las entradas mezclan evidencia formal y empírica, la salida es un dossier mixto; no un teorema Lean.
4. MODUS_PONENS: solo sobre AST exacta P e Implies(P,Q). No interpreta conectores en español. En cadenas matemáticas se recomienda wrapper Lean; el checker comprueba únicamente esta composición proposicional declarada.
5. EMPIRICAL_RECORD: respalda la afirmación acotada de que el experimento E produjo el resultado R bajo el criterio preregistrado C. Exige recibo válido y alcance coincidente. No produce `forall` ni probabilidad verdadera por observación de frecuencias.
6. CONDITIONAL_APPLICATION: de un teorema bajo H y un escenario declarado compatible produce conclusión CONDICIONAL a H en ese escenario. La simulación puede aportar diagnósticos, no descargar por sí sola identificación causal o independencia poblacional. Para declarar H satisfecha por construcción, comprobar la propiedad correspondiente del generador o mantenerla asumida.
7. ALIAS_EXACT: solo mismo objeto formal/expresión y mismo alcance; correspondencia de traducción en lenguaje natural se evalúa aparte.

Cualquier otra regla queda UNSUPPORTED_RULE y pendiente. GLM no puede agregar una regla al registro durante una ejecución de auditoría. Cambiar reglas requiere cambio de software, test adversarial y revisión documentada.

## Criterio de validez
Un argumento es estructuralmente válido si IDs resuelven, las dependencias son acíclicas, la regla reconoce las expresiones y los alcances, y la conclusión no añade fuerza. Es formalmente respaldado solo con una cadena de evidencia Lean apropiada. Es empíricamente respaldado solo para su especificación experimental. Cuando faltan premisas se conserva un sequent H ⊢ C; nunca se elimina H por omisión.

## Estados ortogonales
structure: valid | invalid | pending.
formal: lean_checked | conditional | not_applicable | pending | failed | stale.
empirical: reproduced | conditional | not_applicable | pending | failed | stale.
editorial: exact_generated | agent_reviewed | pending | mismatch | stale.
argumentation: not_run | grounded_in | grounded_out | undecided | budget_exceeded; preferred usa campos de aceptación escéptica/crédula separados.

`agent_reviewed` no equivale a `exact_generated`. `reproduced` no implica `lean_checked`. Un resultado científico negativo puede tener reproducción exitosa y conclusión alternativa respaldada. Un hash stale invalida los descendientes pertinentes mediante recorrido de dependencias.

## Monotonicidad de obligaciones
Obligaciones de la salida = unión de obligaciones no descargadas de las entradas más las introducidas por la regla. La regla puede descargar una obligación solo con evidencia explícita del tipo requerido. Un cambio de escenario no hereda evidencia por similitud.

## ASPIC+ sin inflación de garantías
Generar una proyección de IDs de afirmación y reglas comprobadas. Distinguir apoyo, ataque y ausencia de evidencia. Un resultado empírico que no confirma un efecto no prueba su negación. Una contradicción entre dos enunciados Lean puede indicar supuestos distintos o una traducción errónea: no resolverla asignando prioridad al teorema más reciente.
Usar grounded como diagnóstico inicial. Preferred es opcional y deberá reportar aceptación crédula (alguna extensión) frente a escéptica (todas). Cero extensiones bajo una semántica no permite inferir universalmente aceptabilidad por vacuidad sin convención declarada. Al superar límites: INCOMPLETE, no ausencia de conflictos. Para frameworks pequeños comparar solver con enumeración independiente exhaustiva. No afirmar que SAT produjo un certificado Lean; SAT decide una codificación específica bajo su propia frontera de confianza.
