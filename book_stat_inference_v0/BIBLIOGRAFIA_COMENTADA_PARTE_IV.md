# Bibliografía comentada — Parte IV

**Fecha:** 2026-09-30 · **Alcance:** Parte IV = caps. **10–12** (`main.typ`: divisor «Parte IV» → `cap10_casos.typ`, `cap11_despliegue.typ`, `cap12_problemas.typ`).  
**Regla:** solo obras que aparecen en el manuscrito (listas «Lecturas Propuestas» / `#cite` / claves en `referencias.bib` citadas ahí). No se inventan títulos ni años.  
**Uso:** insumo para consolidar lecturas; **no** es prosa de contribución del capítulo.  
**Estilo:** imita `BIBLIOGRAFIA_COMENTADA_PARTE_III.md`.

---

## Cap. 10 — Casos / laboratorios (`cap10_casos.typ`)

| Obra (clave `.bib`) | Utilidad para el arco |
|---|---|
| **Hernán & Robins (2020)** `hernan2020causal` | Única `#cite` externa del capítulo: referencia a la Tabla 12.2 (estimador / NHEFS) en el laboratorio de datos. Ancla el caso empírico de inferencia causal clásica frente al hilo SSCH/OPE del libro. |

**Notas cap. 10.** No hay lista tipográfica «Lecturas Propuestas». El capítulo es depósito de laboratorios F.1–F.12 (índice 2026-09-27) con remisiones internas (`@thm:…`, `@ch:…`). Barrido 2026-09-30: **un** `#cite` externo (`hernan2020causal`). Menciones en prosa a Hernán & Robins (carga NHEFS) sin otras claves `.bib`.

### Enriquecimiento API — Hernán & Robins 2020

| Clave | OpenAlex | Semantic Scholar | DOI / URL verificable |
|---|---|---|---|
| `hernan2020causal` | **No resuelto de forma unívoca hoy** (búsqueda OA por DOI del `.bib` `10.1201/9781420057669` devolvió obra ajena; `title.search` no indexó el libro en la ventana de consulta) | **No resuelto hoy** (búsqueda S2 no devolvió el monográfico; rate-limit en match) | URL oficial del autor: https://miguelhernan.org/whatifbook · ISBN comercial observado en reseñas: **9781420076165** (CRC). El DOI del `.bib` queda como **deuda de integridad** (no corregido sin OK autor / Crossref explícita). |

---

## Cap. 11 — Despliegue (`cap11_despliegue.typ`)

| Obra | Utilidad para el arco |
|---|---|
| _(sin lista «Lecturas Propuestas» y sin `#cite(<…>)` externos)_ | Esqueleto Fase 2C: títulos + párrafos de alcance + protocolo de validación empírica aún no integrado. Barrido 2026-09-30: **cero** `#cite` a obras externas. Remisiones internas (`@ch:fallos`, `@tab:appE-*`). |

**Notas cap. 11.** Asimetría fuerte: fichas Bowyer et al. 2025 / Miller 2024 viven en `LITERATURA_2022_2026.md` orientadas a este capítulo, pero **no** están citadas en el `.typ` ni en `.bib` → **no** entran en esta bibliografía comentada (regla: solo lo citado en manuscrito). Integración editorial = deuda Fase 3 / decisión A.

---

## Cap. 12 — Problemas abiertos (`cap12_problemas.typ`)

| Obra (clave `.bib`) | Utilidad para el arco |
|---|---|
| **Shi, Zhang, Lu & Song (2022)** `shi2022statistical` | Lectura obligatoria + prosa (IC / mixing / OhioT1DM vs ejemplo sintético). Cierra el arco inferencial de Parte III hacia fronteras del curso. |
| **Kallus & Uehara (2022)** `kallus2022efficiently` | Lectura obligatoria: eficiencia / curse-of-horizon; puente a problemas abiertos de OPE. |
| **Hernán & Robins (2020)** `hernan2020causal` | Cuerpo: remisión a ponderación / IPW en el hilo de confounding. |

**Notas cap. 12.** Lista tipográfica «Lecturas Obligatorias» presente (Shi + Kallus). El capítulo apila fronteras + problemas abiertos (marcador `#pendiente`). Insumo de marcas abierto/parcial/resuelto: `INSUMO_CAP12_PROBLEMAS_x_LITERATURA.md` (aún PENDIENTE AUTOR).

### Enriquecimiento API (obras centrales) — 2026-09-30

Solo IDs devueltos por OpenAlex / Semantic Scholar; **no** se añadió nada al `.bib`.

| Clave | OpenAlex | Semantic Scholar | DOI / arXiv verificable |
|---|---|---|---|
| `shi2022statistical` | **W4200424214** (OA year 2021 / advance; bib year 2022) | **bcc378385c8d5a1d4cd5b78bce17879b1405f89c** (cit. S2 ≈104; arXiv 2001.04515) | DOI **10.1111/rssb.12465** (coincide con `.bib` y con ficha Parte III) |
| `kallus2022efficiently` | **W2994709386** | **f49cfdbc1052fd012242743c2da27ee8bb4f9277** (cit. S2 ≈124; year S2 2019 preprint) | DOI **10.1287/opre.2021.2249** · arXiv **1909.05850** · DBLP `journals/ior/KallusU22` |
| `hernan2020causal` | _(sin ID unívoco hoy — ver arriba)_ | _(sin ID unívoco hoy)_ | URL libro + deuda DOI `.bib` |

---

## Asimetrías documentadas

1. **Cap. 11 sin `#cite` / sin lecturas** — fiel al esqueleto actual; las fichas Bowyer/Miller (27-sep) **no** cuentan como citas del manuscrito.
2. **Cap. 10 casi sin bibliografía externa** — un solo `#cite` (Hernán); el peso es laboratorios + refs internas.
3. **Parte IV ≠ «solo problemas»:** en `main.typ` son caps. **10–12** (casos, despliegue, problemas).
4. **DOI dudoso / no revalidado en `hernan2020causal`:** ISBN comercial 9781420076165 vs DOI `.bib` `10.1201/9781420057669`; no se corrige a ciegas.
5. No se añadió ninguna entrada nueva a `.bib` en esta sesión.
6. Shi/Kallus ya enriquecidos en Parte III; se revalidan IDs aquí porque el cap. 12 los cita de nuevo.

---

## Notas de curación (para el autor)

1. Parte IV **no** incluye caps. 7–9 (Parte III).
2. Si se desea lista de lecturas en cap. 11, partir de Bowyer/Miller (fichas) + anclas Shi/Kallus — decisión **A**.
3. Resolver DOI/ISBN de `hernan2020causal` antes de mostrar el manuscrito afuera (§2 deuda integridad).
