# FIGURAS.md — checklist estilo CeTZ (Agentes)

**Creado:** 2026-10-02 · **AUTONOMIA** (Extra Vie 2)  
**Fuente de aprendizaje:** `fig:ch9-incrustacion-dec-mdp` en `capitulos/cap05_incrustacion.typ` (CeTZ 0.3.4).

## Checklist antes de dar por lista una figura

### Paleta
- [ ] Dos familias de color como máximo (p. ej. Dec = azul claro, MDP = naranja claro).
- [ ] Headers un poco más saturados / stroke más oscuro que nodos de fila.
- [ ] Texto secundario (`isoto`, notas) en `luma(60–90)`, no negro puro.
- [ ] Fondo de nota de alcance: `luma(245)` + stroke fino `luma(180)`.

### Grosores
- [ ] Caja nodo: stroke ≈ 0.55–0.8pt.
- [ ] Flecha de funtor / eje principal: ≈ 1.2pt, mark `>` con fill.
- [ ] Flechas de correspondencia fila: ≈ 0.85pt, paint `luma(90)`.

### Tipografía
- [ ] Labels de nodo: ≈ 8pt.
- [ ] Símbolo de correspondencia (`$isoto$`): ≈ 7.5pt, centrado **sobre** el segmento (misma `y` que la flecha).
- [ ] Título de funtor (`$F$`): ≈ 11pt bold, ligeramente por encima de la flecha header.
- [ ] Nota de alcance: ≈ 7pt.

### Ids de nodo (CeTZ 0.3.4)
- [ ] **Sin `.` en `name:`** (falla en 0.3.4). Usar `param`, `sample`, `L-risk`, `hdr-dec`, etc.
- [ ] Prefijos consistentes: `hdr-` headers, `L-` / `R-` columnas.

### Caption / key
- [ ] `key:` estable (`fig:ch9-…`); no renombrar sin actualizar citas.
- [ ] Caption: remite al teorema/tabla fuente; indica alcance; **sin** la palabra «Borrador» si ya pasó primera iteración (marcar «iteración Vie N» o fecha AUTONOMIA).
- [ ] Correspondencias = solo las del resultado citado (no inventar filas).

### Smoke
- [ ] Compilar fragmento aislado → PDF en `/tmp/smoke_fig_….pdf` **OK** antes de sync.
- [ ] Verificar que `main.typ` no empeora por la figura (el FAIL `intro.typ:89` es preexistente; no «arreglar» a ciegas).
- [ ] Import: `#import "@preview/cetz:0.3.4": canvas, draw` una sola vez al tope del capítulo.

### No hacer
- No tocar `dem:ch4-wilks` ni `intro.typ` al iterar figuras.
- No mezclar este checklist en `COMPRIME_CONVENCION.md` (solo puntero de una línea).

## BACKLOG SuperGrok (2026-10-02) — próxima iteración Fig.1
- [ ] Unificar anchos de columna de las 6 filas (grid/table `columns: (auto, 1fr, auto)`, `align: horizon`) para alinear `↔`/`isoto`.
- [ ] Uniformar stroke/fill/inset/radius de nodos Dec y MDP₁ y mark/grosor de todas las flechas (eliminar micro-variaciones del PDF).
- **Descartado:** pedir justificación textual en el protocolo de figura (viola insumo A / sin prosa).


## Inventario de figuras CeTZ

| Key | Archivo | Estado | Notas |
|---|---|---|---|
| `fig:ch9-incrustacion-dec-mdp` | `capitulos/cap05_incrustacion.typ` | Iteración Vie 2 | Funtor $F$; BACKLOG SuperGrok en §arriba |
| `fig:ch9-protocolo-verificacion` | `capitulos/cap09_verificacion.typ` | Iteración Dom 4 (AUTONOMIA 2026-10-04) | Flujo pasos 0–8 + rama §3 / ↝ / `ch:fallos`; espaciado Δy=1.55; pastillas sí/no; smoke `/tmp/smoke_fig_ch9_proto.pdf` OK |

### Checklist Fig.3 (2026-10-03) — aplicado
- [x] Paleta: azul (pasos) / naranja (rama no-verificable); máx. 2 familias.
- [x] Grosores: nodos ≈ 0.55pt; decisión 0.75pt; flecha rama ≈ 1.0pt; rejoin dashed 0.7pt.
- [x] Tipografía nodos ≈ 7.5pt; etiquetas sí/no ≈ 7pt; nota ≈ 6.5pt.
- [x] Ids sin `.` (`p0`…`p8`, `deg-sec`, `deg-state`, `deg-fallos`).
- [x] Caption con key estable; sin «Borrador» en el sentido de descarte — marca «Borrador Sáb 3» + AUTONOMIA (primera iteración).
- [x] Smoke aislado OK.


### Checklist Fig.3 (2026-10-04) — iteración Dom 4
- [x] Caption: sin «Borrador»; «Iteración Dom 4 — AUTONOMIA 2026-10-04».
- [x] Espaciado vertical uniforme Δy = 1.55 (p0…p8).
- [x] Rama NV alineada a ys de p5/p6/p7.
- [x] Etiquetas sí/no en pastilla (7.5pt bold).
- [x] Nota de alcance alineada; tipografía secundaria `luma(60)`.
- [x] Ids sin `.` (sin cambio de nombres).
- [x] Smoke aislado `/tmp/smoke_fig_ch9_proto.pdf` OK; smoke canónica+fig `/tmp/smoke_cap09.pdf` OK.
