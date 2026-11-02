# Insumo A — Columnas y alcance de la tabla canónica (cap. 9)

**Fecha:** 2026-09-29 · **Estado:** propuesta **AUTONOMIA 2026-09-29** (el autor aún no definió columnas; por protocolo A no se escribe prosa de contribución).  
**Tarea plan:** Mar 29 T1 (A) + Extra (D) · **No** construir aún la tabla Typst canónica (Mié 30).

---

## 1. Columnas candidatas (solo esquema)

| # | Columna | Tipo / valores | Notas |
|---|---|---|---|
| 1 | **Resultado** | texto + label Typst opcional (`thm:…` / `def:…`) | Nombre del teorema/definición/resultado teórico. |
| 2 | **Componente** | texto | Pieza del agente / LangGraph / estimador donde se materializa. |
| 3 | **Garantía** | texto corto | Qué queda garantizado si las condiciones valen (p.ej. UMVUE, cobertura $1-\alpha$). |
| 4 | **Condiciones** | texto o `CONDICIONES SIN ESPECIFICAR` | Hipótesis verificables; **no inventar**. Si el libro no las enumera → marca CSE. |
| 5 | **Origen tabla** | key Typst (`tab:ch3-trazabilidad`, …) | De qué tabla superpuesta proviene la fila (trazabilidad de consolidación). |
| 6 | **Estado** | `↔` \| `↝` \| `—` | `↔` = transferencia fiel bajo condiciones; `↝` = analogía / extensión frágil; `—` = sin clasificación aún. Alineado al catálogo del libro. |
| 7 | **Notas** | texto libre (opcional) | Duplicados, remisiones a ap. A/E, deuda de verificación. |

Opcionales (solo si el autor las pide el Mié 30+):

- **Cap. canónico** (dónde vive el resultado en la numeración actual 1–12).
- **Parte** (I–IV).
- **Token duplicado** (grupo de la lista única del 29-sep).

---

## 2. Alcance propuesto (qué entra)

**Entran (familia trazabilidad):**

1. Las **9** `#mi-tabla` ya reunidas en `cap09_verificacion.typ`:
   - `tab:ch1-nodos-diagnostico-b`
   - `tab:ch1-trazabilidad` … `tab:ch6-trazabilidad`
   - `tab:ch12-trazabilidad` (mapa)
   - `tab:app-trazabilidad` (alias histórico `tab:trazabilidad-completa`; el `#pendiente` la llama «apéndice E»)
2. Las **4 hermanas** que aún viven fuera del cap. 9 (decidir si se mueven o solo se referencian):
   - `tab:ch7-trazabilidad` → `cap02_wald.typ`
   - `tab:ch8-trazabilidad` → `cap03_mdp.typ`
   - `tab:ch9-trazabilidad` → `cap05_incrustacion.typ`
   - `tab:ch11-trazabilidad` → `cap08_intervalos.typ`

**No inventar:** el marcador habla de «veinte» tablas; el inventario verificable es **13** (9+4). No existe `tab:ch10-trazabilidad` en el árbol actual.

**Quedan fuera de la canónica (salvo decisión explícita del autor):** tablas de correspondencia/laboratorio/contraejemplos (`tab:correspondencia-central`, `tab:ch9-contraejemplos`, `tab:lab-reparto-f1-f12`, etc.) — no son de la familia «Teorema → Componente → Garantía».

Volcado crudo de filas: `LISTA_UNICA_TABLAS_TRAZABILIDAD_2026-09-29.md`.

---

## 3. Preguntas abiertas para el autor (1–5)

1. ¿Confirmas el set de **7 columnas** de §1, o prefieres fusionar Origen/Notas / añadir Cap. canónico?
2. ¿Las 4 tablas hermanas (ch7/ch8/ch9/ch11) **entran** en la canónica del cap. 9 o se dejan en sus capítulos con remisión?
3. ¿Cómo interpretar el «**veinte**» del `#pendiente`? ¿Es cifra histórica a corregir a 13, o faltan tablas por mover desde otros archivos?
4. Para filas sin columna Condiciones (ch4–ch6, ch7–ch9, ch11, ch12, app, nodos-b): ¿default `CONDICIONES SIN ESPECIFICAR` hasta el pase A del Mié 30, o priorizar un subconjunto?
5. El símbolo de **Estado** (`↔`/`↝`/`—`): ¿lo rellena el autor fila a fila, o aceptas un default `—` en la primera canónica Typst?

---

## 4. Qué no hace este insumo

- No escribe prosa de contribución del cap. 9.
- No construye la tabla Typst canónica.
- No borra filas de las tablas existentes.
- No toca `dem:ch4-wilks`.


---

## 5. Decisiones AUTONOMIA 2026-09-30

El autor **no respondió** las preguntas 1–5 el Mar 29. Por protocolo de autonomía se aplican y documentan (marcadas **AUTONOMIA**, no como OK autor):

| # | Pregunta | Decisión AUTONOMIA 2026-09-30 |
|---|---|---|
| 1 | ¿Set de 7 columnas? | **Sí.** Columnas canónicas = Resultado, Componente, Garantía, Condiciones, Origen tabla, Estado, Notas (sin Cap. canónico / Parte / Token como columnas propias; el token de duplicado va en Notas). |
| 2 | ¿Hermanas ch7/ch8/ch9/ch11 entran? | **Sí, entran** en la canónica con Origen = su key. **No** se borran las tablas hermanas de sus capítulos hoy (solo remisión/comentario implícito vía Origen). |
| 3 | ¿«Veinte» del `#pendiente`? | Inventario verificable = **13**. Comentario Typst en cap. 9: no inventar tablas. El `#pendiente` **no** se retira aún (plan: Vie 2). |
| 4 | ¿Default CSE / subconjunto? | Si el `thm:`/`def:`/`cor:` citado **enumera** hipótesis en el manuscrito → copiar formulación breve a Condiciones; si no → literal `CONDICIONES SIN ESPECIFICAR`. Nunca inventar. Ver `CSE_RESOLUCION_2026-09-30.md`. |
| 5 | ¿Estado ↔/↝/—? | Default **`—`** en todas las filas de la primera canónica (el autor rellenará ↔/↝). |

**Extras AUTONOMIA del día:**

- Filas marcadas duplicado: **incluir todas** en la canónica; Notas lleva `duplicado(…)`; no borrar tablas antiguas hoy.
- `tab:ch1-nodos-diagnostico-b`: incluir con Origen; mapeo documentado Componente→Resultado, Operación→Componente, Concepto→Garantía (como en la lista única del 29).
- Tabla Typst: `tab:trazabilidad-canonica` vía `capitulos/cap09_tabla_canonica.typ` (`#include` desde `cap09_verificacion.typ`).
