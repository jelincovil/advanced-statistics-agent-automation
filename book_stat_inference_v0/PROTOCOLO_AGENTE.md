# Protocolo del agente — Agentes Estadísticos con Garantías

Documento operativo para sesiones diarias en Typst. Complementa el plan `PLAN_v0.2_a_v2.0.md`.

## 1. Apertura de sesión
1. Leer última entrada de `REGISTRO_DIARIO.md` y `PENDIENTES.md`.
2. Leer la fila del día en el plan.
3. Verificar que el preview compile (`Compilation complete`). Si falla, arreglar es la tarea 1.

## 2. Tipos de tarea
| Tipo | Quién | Qué hace el agente |
|------|-------|--------------------|
| **A** | Autor | Prepara insumo; **no** escribe prosa de contribución |
| **D** | Agente | Ejecuta en el manuscrito |
| **V** | Agente | Fichar literatura, cotejar citas, compilar, consistencia |

Si una **A** está bloqueada: dejar el insumo, anotar en el registro, adelantar la siguiente **D**.

## 3. Reglas permanentes
- No inventar citas, DOI, años ni resultados.
- Nada entra a `referencias.bib` sin leer al menos abstract e hipótesis.
- Condiciones de garantía no enumeradas → `CONDICIONES SIN ESPECIFICAR` (no rellenar).
- Ante duda, afirmar menos.
- `PENDIENTE` solo se retira cuando el hueco está cerrado de verdad.
- Autonomía: si falta un criterio o marcador, **decidir, documentar aquí/registro y avanzar**. Escalar solo si se invalida un resultado o hay riesgo real al manuscrito.

## 4. Criterio Apéndice A — `(a)/(b)/ambas/ninguna`
Adoptado 2026-09-22 (no estaba en el manuscrito; no re-negociar salvo el autor):

- **(a)** sostiene un teorema/lema/resultado **aún citado** en el cuerpo
- **(b)** material técnico auxiliar **no citado** en el cuerpo
- **ambas** mezcla (a) y (b)
- **ninguna** no sostiene nada vivo ni es auxiliar útil → **candidato a poda**; reportar, **no borrar** hasta visto bueno (tarea prevista Vie 25)

Marcar en comentarios Typst junto al ítem, p. ej. `// CLASIF: (a)` o en tabla de `REGISTRO_DIARIO.md`.

## 5. Compresión `COMPRIME`
1. Buscar el marcador literal `COMPRIME` en el archivo del capítulo.
2. Si **existe**: comprimir solo el bloque marcado; preservar resultados vivos citados.
3. Si **no existe**: no inventar cortes. Añadir nota `// AUTONOMIA YYYY-MM-DD:` + inventario de resultados vivos (labels/nombres) y registrar parcial en `REGISTRO_DIARIO.md`.

## 6. Literatura
- Fichas en `LITERATURA_2022_2026.md` (una sección por paper).
- Plantilla mínima: citar, DOI/arXiv, supuesto clave, qué garantiza, qué exige, enlace al capítulo del libro, estado (`ficha` / `en .bib` / `integrado`).

## 7. Cierre
1. Entrada nueva en `REGISTRO_DIARIO.md` (fecha, hecho / no hecho + por qué, hallazgos, compile OK/FAIL).
2. Actualizar `PENDIENTES.md` si aplica.
3. Reporte al autor ≤10 líneas.