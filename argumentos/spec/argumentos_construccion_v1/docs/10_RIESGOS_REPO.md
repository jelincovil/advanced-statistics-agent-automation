# Hallazgos de contexto que el agente debe volver a comprobar

Base de esta entrega: 0460b3f29f35eb0cb2b553712b9c7adb1e37ae77. Árbol de main comprobado durante la preparación. Estas observaciones son entradas de auditoría, no órdenes de modificar indiscriminadamente el repositorio.

1. README raíz describe tres bloques, pero hay monografia_M, agente-stats y verificacion_lean adicionales. El inventario se obtiene del árbol real.
2. Dashboard Lean registra cinco teoremas públicos para cuatro claves y 4/35 entradas del plan. No convertir cinco declaraciones en cinco capítulos comprobados.
3. Foundation define sumas finitas con pesos reales sin exigir probabilidades; es suficiente para identidades algebraicas, pero la interpretación probabilística exige hipótesis adicionales.
4. El runner Lean busca sorry y audita axiomas. No basta copiar su reporte: comprobar tipo y dependencias de cada declaración y alcance de su uso.
5. Informe de sesión anuncia escenario A completo de SAVE, mientras el Typst consultado mantiene varias celdas vacías. Preservar discrepancia, verificar fuentes/resultados y no rellenar números por inferencia.
6. En agente-stats/core/ope.py el DR no impone explícitamente v_H=0. En compare.py el término de continuación consultado carece de gamma. Los tests de mera ejecución no justifican la fórmula. No usar esos módulos como ancla empírica aprobada sin revisión y regresiones independientes.
7. certificates.py puede devolver region con condiciones abiertas, pero una región de identificación exige una construcción matemática. El nuevo kernel no copiará esa promoción automática.
8. Monografía M incluye inferencia anytime y OBD; sus pruebas Lean son piloto compartido, no verificación de e-procesos. Las fórmulas nuevas y las interpretaciones de intervalos requieren revisión independiente.
9. Fuentes de pruebas existentes contienen algunas aserciones débiles; tomar el recuento de tests verdes como registro técnico, no como evidencia científica suficiente.
10. No son autorización para limpiar artefactos masivos ni borrar históricos. La tarea es construir la capa de argumentos sin pérdida de información.
