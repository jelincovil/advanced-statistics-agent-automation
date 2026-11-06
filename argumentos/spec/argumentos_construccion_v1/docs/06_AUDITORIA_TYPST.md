# Auditoría del libro y extracción GLM

## Dos controles distintos
Control exacto: etiquetas, fórmulas canónicas, parámetros, enlaces a evidencia y bloques generados. Control semántico: si la prosa añade causalidad, elimina hipótesis, universaliza un ejemplo o cambia el objeto. El segundo produce hallazgos revisados por el agente con pasajes y razones, no un certificado matemático.

## Inventario sin pérdida
Recorrer los capítulos y apéndices incluidos por main.typ; registrar includes/imports y macros conocidas. Detectar entornos theorem/proposition/corollary/example/assumption, etiquetas y números de tablas. No contar títulos, índices o duplicados de aliases como argumentos nuevos. Incluir párrafos objetivos fuera de entornos mediante una cola de extracción GLM. Publicar cobertura: bloques detectados, procesados, candidatos sin resolver y zonas no interpretadas. No afirmar exhaustividad semántica solo por recorrer todas las líneas.

Adaptador inicial explícito para plantilla.typ y sus macros; si la evaluación dinámica de Typst impide resolver un bloque estáticamente, marcar dynamic_unresolved y conservar fuente. Puede utilizarse `typst query` para metadatos instrumentados, fijando versiones y manteniendo source map; no asumir que el AST es texto renderizado.

## Extracción
Contrato del proveedor: entrada con IDs de bloque y bytes exactos; salida JSON de candidatos con citas textuales y offsets. El alineador debe verificar text[start:end] == quote, distinguiendo offsets UTF-8 y caracteres. No permitir alineación aproximada automática como evidencia exacta. Citas repetidas requieren desambiguación.

GLM nunca escribe releases ni receipts. El prompt pide: separar premisas, reglas, conclusión, alcance, negaciones, cuantificadores, condiciones y fuentes; abstenerse cuando falte información. Los ejemplos few-shot incluyen una conclusión que cambia de signo, confusión entre episodios/pasos y una simulación generalizada incorrectamente.

## Diff
Comparación exacta de objetos formales/AST y alcance primero; diferencias de redacción después. Clasificar: missing_claim, unsupported_claim, missing_assumption, changed_quantifier, changed_scope, stale_evidence, numerical_mismatch, unresolved_mapping, harmless_wording. Cualquier clasificación del LLM conserva el fragmento y la respuesta original. Una decisión del agente puede aceptar una paráfrasis editorial, no cambiar el tipo de un teorema ni aprobar pruebas nuevas.

## Render
Render determinista de fichas y bloques canónicos a .typ con escape seguro; no ejecutar strings como código Typst. Fórmulas de presentación proceden de campos controlados, con mapa al objeto formal, y conservan revisión editorial. Generar a carpeta aparte y comparar hashes en dos ejecuciones. No reescribir todo el libro ni reemplazar la prosa docente para esconder discrepancias. Un comando apply opcional emite un patch revisable; cambios argumentales exigen nuevo kernel primero.

## Reproducibilidad del LLM
Guardar prompt, few-shot, endpoint sin secretos, modelo observado, parámetros, respuesta raw, fecha y hashes. Temperatura cero/seed no aseguran determinismo remoto. Modo replay debe reconstruir exactamente candidatos y reportes deterministas desde una respuesta archivada. No guardar tokens/API keys. Timeouts y rechazos se convierten en pendientes, nunca en aprobación por defecto.
