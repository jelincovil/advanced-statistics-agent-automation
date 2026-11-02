# Presentaciones del curso

## Estado de reconstrucción
Las clases 1 y 2 están reconstruidas y verificadas; las clases 3–13 siguen siendo borradores. Véase `ESTADO_RECONSTRUCCION.md`. El ZIP `presentaciones_typst.zip` es una instantánea anterior; use `clases1y2_reconstruidas.zip` para las clases actualizadas.

## Archivos
- 13 fuentes numeradas `.typ` y `tema.typ`.
- 13 PDF de exposición y 13 PDF `_handout.pdf`.
- `REVISION_PRESENTACIONES.md`: revisión, cambios y límites.
- `manifest.json`: inventario y sumas SHA-256.

## Compilar
Desde esta carpeta:
```sh
typst compile 03_wald.typ 03_wald.pdf
typst compile --input handout=true 03_wald.typ 03_wald_handout.pdf
```
Probado con Typst 0.15.1. El tema es autocontenido y no requiere descargar paquetes. Conserva formato 16:9 y estilo académico; no utiliza Touying.

## Uso docente
Cada presentación contiene objetivos, ocho núcleos temáticos, preguntas con respuestas, ejemplos, pausa, taller, discusión y síntesis. Los talleres de cálculo incluyen datos y solución en las notas. El SSCH se identifica como sintético; SAVE y el agente operativo no se presentan como validados.

Esta versión requiere cotejo integral con la edición vigente del manuscrito y ensayo real de duración. Las demostraciones largas y evidencia empírica deben prepararse desde sus fuentes antes de enseñar; el conteo de diapositivas no acredita una clase de tres horas.
