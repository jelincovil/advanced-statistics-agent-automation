# INFORME FASE 2 — Estructura

**Manuscrito:** `monografia_typst_v1`
**Estado:** 2B (movimientos) ✅ · 2C-ii ✅ · 2C-i ❌ · 2D ❌ · apéndice A ❌ · bibliografías ❌
**Commit de cierre:** `7b4b785`

> **Estado posterior (al cerrar `v0.1-base`, 2026-09-22).** Este informe es la
> fotografía de la Fase 2 y se conserva como tal. Después de él, y antes de la
> etiqueta `v0.1-base`: 2C-i ✅ (advertencia terminológica en el cap. 1), 2D ✅
> (esqueleto del apéndice G, reproducibilidad), el cap. 4 quedó desapilado
> —un arranque, un bloque de ejercicios, una lista de lecturas, **restaurada**
> del historial porque 2B la había descartado— y 9 de las 12 transiciones
> rotas de §4 quedaron marcadas con cuadros `PENDIENTE` visibles en el PDF.
> La deuda vigente está en `PENDIENTES.md`, no aquí.

---

## 1. Resultado

El manuscrito pasó de **13 capítulos + Intro + 8 apéndices / 283 pp.** a
**12 capítulos + Intro + 6 apéndices / 269 pp.**, con el esqueleto aprobado en
`MAPA_ESTRUCTURA.md` implementado capítulo por capítulo.

```
Introducción
1  Dos tradiciones y el problema de la transferencia de garantías
2  Teoría de decisión de Wald
3  Procesos de decisión de Markov
4  Herramientas de transferencia
5  La incrustación fiel Dec → MDP: enunciado, demostración y alcance
6  Lo que no se transfiere
7  Evaluación off-policy
8  Intervalos de confianza para funciones de valor
9  Un cálculo de verificación de garantías
10 Casos de estudio
11 De la garantía al despliegue
12 Problemas abiertos
```

`capitulos/` contiene los 13 archivos nuevos. **14 archivos viejos y 2
apéndices absorbidos fueron borrados**, y el libro compila tras el borrado.

**`typst compile` → exit 0 en cada uno de los 14 commits**, sin una sola vez
dejar el árbol sin compilar. 0 warnings.

---

## 2. Páginas antes / después

| Bloque | Antes | Después | Origen → destino |
|---|---|---|---|
| Introducción | 9 | ~4 | cap. 0 §tesis + §guía de lectura |
| Parte I — Aparato mínimo | **102** | **70** | caps. 1–6 + cap. 7 + cap. 8 |
| Parte II — Correspondencia | ~14 | **19** | cap. 9 + cap. 13 §13.2 + apéndice G |
| Parte III — Inferencia para agentes | ~28 | **36** | caps. 10, 11 + aplicaciones y trazabilidades dispersas |
| Parte IV — Ejercicio y límites | ~54 | **46** | caps. 12, 13 + apéndices F y H |
| Apéndices | ~90 | ~80 | A, B, C, D, E, G + bibliografía |
| **Total** | **283** | **269** | **−14 pp.** |

Las cifras de «antes» son las páginas del índice del PDF original; las de
«después», las del índice actual.

---

## 3. Inventario de lo eliminado, con justificación

**Ejecutado (17 secciones):**

| # | Sección | Por qué |
|---|---|---|
| 1 | cap. 0 §Arquitectura del Libro (+3 subsecciones) | describía la estructura de tres actos, que dejó de existir |
| 2 | cap. 0 §Mapa de dependencias | ídem |
| 3–8 | 6 × §«Contexto Histórico y Motivación» (caps. 1–6) | arranques de capítulo superseded por el nuevo cap. 1, que es el capítulo histórico |
| 9–13 | 5 × §«Conexión con el `@ch:X`» | transiciones entre capítulos que dejaron de ser adyacentes |
| 14 | cap. 6 §«Donde Estamos» | cierre de capítulo que dejó de existir |
| 15 | cap. 9 §«Síntesis: Visión Unificada» | la síntesis es ahora el cap. 12 |
| 16 | cap. 9 §«Conexión con el `@ch:ope`» | transición obsoleta |
| 17 | `notacion.typ` §«Correspondencia Isomórfica Principal» | la tabla triplicada: decisión del autor de una sola tabla canónica |

**Diferido a Fase 3 (1 sección):**

- cap. 4 §«Tests de Hipótesis Bayesianos» — eliminación **aprobada** pero no
  ejecutada: hay una referencia viva a `@def:ch4-bayes-factor` en el texto que
  la citaba, y borrarla ahora rompe la compilación. Se elimina cuando Fase 3
  reescriba el párrafo que la referencia.

**Rescatado de `ELIMINA` por decisión del autor:**

- cap. 1 §«Estadísticos y su Clasificación» → `COMPRIME` (es definicional, y
  R2 —el estadístico suficiente como estado— lo necesita).
- Las cuatro filas definicionales (familias paramétricas, equivarianza,
  MCMC/VI ×2, tests UMPU) → `COMPRIME`.

**Criterio aplicado:** de los **320 resultados etiquetados** en los caps. 1–6,
solo **41 se invocan** alguna vez desde el resto del libro. Lo no invocado fue
a apéndice o a eliminación; lo definicional se evaluó por lo que sostiene, no
por cuántas veces se lo nombra.

---

## 4. Transiciones rotas que Fase 3 debe reescribir

Ordenadas por gravedad. Ninguna impide compilar; todas se leen mal.

1. **Los seis arranques de capítulo del cap. 4** (prosa + epígrafe) están
   apilados al inicio del capítulo. Fase 3 elige cuál sobrevive.
2. **Las seis listas de lecturas del cap. 4** están apiladas. Fase 3 las
   consolida en la bibliografía comentada de la Parte I.
3. **Los seis bloques de ejercicios del cap. 4** están apilados. Fase 3 los
   fusiona y elimina duplicados.
4. **El cap. 9 reúne veinte tablas de trazabilidad superpuestas** procedentes
   de los caps. 1–6, del cap. 12 y del apéndice E. Necesita una sola tabla
   canónica.
5. **El cap. 10 son seis bloques del SSCH en secuencia** más el laboratorio
   completo. Necesita andamiaje narrativo y el reparto de los laboratorios
   F.1–F.12 entre sus capítulos.
6. **El cap. 12 son dos capítulos apilados** (fronteras + problemas abiertos).
   Necesita el andamiaje de «problemas abiertos».
7. **El cap. 6 no tiene el andamiaje que su título promete**: «seis mecanismos
   de fallo» y «la degeneración de la tricotomía bajo MA+CMIA» son redacción.
8. **El cap. 5 mezcla teoremas y conjeturas** en §«Transferencia de resultados»
   y §«Preservación de propiedades»; el reparto fino teorema→cap. 5 y
   conjetura→cap. 6 exige cortar dentro de las secciones.
9. **Residuo de la tabla triplicada en la Introducción**: la Tabla 0.1 sigue
   siendo el ancla de la matización de la fila Θ del cap. 1.
10. **El cap. 2 termina con dos secciones anexadas** (los anticipos de la
    correspondencia que se movieron desde los caps. 1 y 4).
11. **El cap. 3 perdió su §«Conexión con el `@ch:isomorfismo`»** (viajó al
    cap. 5) sin transición de cierre.
12. **El cap. 11 es un esqueleto**: solo títulos y párrafos de alcance.

---

## 5. Decisiones de arquitectura tomadas en esta fase

- **La tabla de correspondencias canónica es la del cap. 5.** La de
  `notacion.typ` se eliminó; la del cap. 0 queda como anticipo en la
  Introducción.
- **Las etiquetas se conservan y los capítulos que se funden dejan aliases.**
  El cap. 4 lleva seis `#chapter-alias` (sus ~92 referencias siguen
  resolviendo); el cap. 5 tomó `<ch:isomorfismo>`; el cap. 10 tomó
  `<app:laboratorio>`; el cap. 12 tomó `<ch:sintesis>` y `<ch:conclusiones>`.
- **Las secciones `COMPRIME` se movieron enteras**, como se indicó: la
  compresión es Fase 3.
- **`apendice_langgraph.typ` queda marcado `PENDIENTE-CAP11`**: el cap. 11 se
  redactó en términos agnósticos (cuantización, latencia, evaluabilidad), lo
  que inclina la decisión hacia no citarlo.

---

## 6. Entregables de la fase: estado

| Entregable | Estado |
|---|---|
| `MAPA_ESTRUCTURA.md` | ✅ aprobado y ejecutado |
| 2B — movimientos mecánicos | ✅ cerrado (14 commits) |
| 2C-ii — esqueleto del cap. 11 | ✅ hecho |
| `INFORME_FASE2.md` | ✅ este documento |
| 2C-i — advertencia terminológica | ❌ pendiente |
| 2D — apéndice de reproducibilidad | ❌ pendiente |
| Apéndice A — clasificación `(a)/(b)/ambas/ninguna` | ❌ pendiente |
| Cuatro bibliografías comentadas por Parte | ❌ pendiente |

---

## 7. Cómo se hizo (trazabilidad)

Los scripts de migración están **versionados** (en la raíz al ejecutarse;
**hoy viven en `tools/`**, ver su `README.md`): `_build2b.py`
(Intro + caps. 2 y 3), `_build2b_b.py` (notación → apéndice B),
`_build2b_c4.py`, `_build2b_c5.py`, `_build2b_c78.py`, `_build2b_c9.py`,
`_build2b_c10.py`, `_build2b_c11.py`, `_build2b_c12.py`. Producen exactamente
los movimientos commiteados: son el registro reproducible de qué se movió y
qué no.

**Dos errores de método que vale la pena dejar anotados:**

1. El extractor de bloques falló tres veces. La causa última fue buscar la
   frontera de cada bloque en los **encabezados**: los bloques empiezan con el
   envoltorio `#[` + `#set heading(...)` y contienen encabezados internos, de
   modo que el corte se detenía antes de tiempo y dejaba delimitadores
   huérfanos. **La solución fue usar las marcas `// -> cap. N` como fronteras**,
   que es información que ya estaba en el archivo.
2. Un `git checkout` restauró un estado intermedio y hubo que rehacer un
   movimiento; y una vez se leyó el código de salida de `head` en lugar del de
   `typst` al verificar una compilación. Ambos quedaron corregidos y
   verificados.
