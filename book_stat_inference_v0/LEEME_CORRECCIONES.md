# Estado de la edición corregida

Esta entrega está en progreso. Se aplicaron cambios en 16 fuentes Typst y se preparó el paquete de laboratorios. El archivo `main.pdf` del directorio original corresponde a la versión anterior: no representa todavía las fuentes corregidas y se excluye del ZIP de esta entrega.

## Verificación realizada

- Los 14 laboratorios se ejecutaron sin errores y sus salidas coinciden con los bloques publicados del capítulo 10, normalizando espacios.
- `resultados_laboratorios.json` registra salidas, errores, tiempos y hashes; `versiones.json` registra el entorno efectivo.
- Pasaron `verificacion/comprobar_identidades.py`, `verificacion/comprobar_secundarios.py` y `verificacion/comprobar_hallazgos.py`.
- La plantilla corregida compiló en una prueba local y no se encontraron referencias nuevas sin etiqueta correspondiente. Esto no sustituye compilar el libro completo.

## Uso del paquete

Desde esta carpeta, en un entorno con las versiones de `requirements.txt`, ejecutar `python ejecutar_todos.py`. `extraer_laboratorios.py` extrae los 14 listados del capítulo 10 mediante un parser por líneas y comprueba su sintaxis. Se niega a sobrescribir un programa que difiera del listado para evitar perder cambios manuales.

## Pendientes

- La compilación completa necesita CeTZ 0.3.4. La solicitud de acceso a su servidor no pudo presentarse porque la aplicación no tenía un cliente de aprobaciones disponible; no se concedió acceso de red.
- La reproducción SAVE sigue incompleta: faltan una versión verificable del repositorio y detalles del escenario C, incluido el ruido añadido. Se corrigió la confusión entre número de bases y ancho de banda, así como la grilla C; no se inventaron resultados.
- `agente_secuencial.py` es un prototipo preparado, pendiente de integración y validación como paso del plan.
- Los estados de `CORRECCIONES_H01_H60.md` distinguen cambios aplicados de cierre validado. No se declara resueltos los 60 hallazgos ni completado el plan.
