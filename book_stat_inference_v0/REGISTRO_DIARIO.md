# Registro diario

## 2026-09-22

### Hecho
- Tarea 1: creada `exportacion_agente_v1/LITERATURA_2022_2026.md` con la ficha exacta de Shi, Zhu, Shen, Luo, Zhu & Song (2024, JASA), sin añadir `.bib`.
- Tarea 2: no completada. Se revisaron `PENDIENTES.md`, `AUDITORIA_FASE1.md` y `PLAN_AGENTICO_DIARIO_v2.md`; el esquema operativo de categorías `(a)/(b)/ambas/ninguna` del Apéndice A no quedó localizado. La búsqueda condujo a referencias del plan y a `apendice_demostraciones.typ`, que es un apéndice de demostraciones genéricas, no el catálogo solicitado. Bloqueada por criterio no localizado; no se borraron ni marcaron ítems.
- Tarea 3: no comprimida. El criterio de los 41 resultados vivos aparece mencionado en el plan, pero no se localizaron marcadores `COMPRIME` dentro de `capitulos/cap02_wald.typ`; no se inventaron cortes ni resultados.

### Hallazgos y verificación
- El archivo `cap02_wald.typ` figura además con tres secciones anexadas pendientes en `PENDIENTES.md` (línea 510), pero no se alteró por falta de instrucción `COMPRIME` aplicable.
- Preview de `main.typ`: **Compilation complete**.

## 2026-09-22 — complemento autonomía

- Apéndice A: localizado el criterio canónico en `PENDIENTES.md` (a = resultado vivo; b = material no reproducible desde referencia estándar); se marcaron los primeros 12 ítems, sin borrar. Conteo: (a) 11, (b) 0, ambas 0, ninguna 1.
- Cap. 2 Wald: no hay `COMPRIME` ni lista operable específica del capítulo; se dejó el bloque `AUTONOMIA` al final y se creó `INVENTARIO_CAP02_VIVOS.md`. No se podó prosa ni se alteraron teoremas.
- Compilación verificada: **Compilation complete**.

## 2026-09-23

### Hecho
- **T1 (V):** Ficha NSAVE arXiv:2505.13809 — S2 OK; OpenAlex OK (W4415020600, tras API key); PDF leído (abstract + Assumptions A.1–A.11 y Thm 5.1/5.6). Actualizados `LITERATURA_2022_2026.md`, `libro-hoy/2026-09-23/ficha-NSAVE-2026-09-23.md`, `COMPARE_SAVE_NSAVE.md` (también en `exportacion_agente_v1/`). **No** añadido a `.bib`. Código NSAVE no localizado.
- **T2 (D):** Ap. A segundo tercio (12 ítems: CLT Lindeberg-Lévy … Existencia y unicidad de V*): CLASIF 2026-09-23. Conteos: **(a) 10, (b) 2, ambas 0, ninguna 0**. Ítems (b): Consistencia del bootstrap; Ecuación de Bellman de expectación. **Sin borrar**.
- **T3 (D):** Cap. 3 MDP — sin `COMPRIME`; bloque `AUTONOMIA 2026-09-23` + inventario de keys vivos al final de `cap03_mdp.typ`. **Parcial** (criterio plan ≈41 no aplica a cap.3).
- **Comercial Día 2:** diferido — callouts `#monorepo` / caps 15+ no existen en este proyecto (12 caps); corresponde Causal AI `pN5Mz36hcZ4w3us1SoKxLv` sesión 11:00.

### No hecho / diferido
- Sync Typst.app: pendiente (sin subagente computerUse en este ejecutor); archivos listos en backup + `libro-hoy/2026-09-23/agentes/`.
- SuperGrok: no usado (opcional).

### Hallazgos
- Contraste SAVE/NSAVE verificable: muestreo (bidireccional vs muchas-episodios), DR alineada, no-unicidad.
- OpenAlex ayer rate-limit IP compartida; hoy OK con `OPENALEX_API_KEY`.

### Compile
- Local typst 0.13.1: **FAIL** en `capitulos/intro.typ:89` (`expected content, found array` en tabla con `$Value(policy; dot)$`) — error **preexistente**, no introducido por T1–T3. Archivos tocados hoy (Ap.A CLASIF / cap03 AUTONOMIA / md) no son la causa.
- Preview Typst.app: **pendiente de sync** (sin computerUse en este ejecutor).

## 2026-09-24

### Hecho
- **T1 (V):** Ficha Luo, Fan & Wu (NeurIPS 2025) — título *Simultaneous Statistical Inference for Off-Policy Evaluation in Reinforcement Learning*. OpenAlex **W7196936303**; S2 **582d13421439bfc04ccb3b0410d5f879168c964d**; DOI **10.52202/085713-2367**. Abstract leído (S2/OpenReview); **OhioT1DM** declarado en abstract. **Sin arXiv** localizado; PDF OpenReview no extraído como PDF en box. **No** añadido a `.bib`. Índice 24 sep → hecha.
- **T2 (D):** Ap. A último tercio (9 ítems caps. 9–11): CLASIF 2026-09-24. Conteos día: **(a) 8, (b) 1, ambas 0, ninguna 0**. Ítem (b): Curse-of-Horizon en IS. Informe consolidado `INFORME_APENDICE_A_CLASIF.md` (acumulado a:29 b:3 ninguna:1). **Sin borrar**.
- **T3 (D):** Cap. 4 — sin `COMPRIME`; bloque `AUTONOMIA 2026-09-24` + inventario suficiencia junto a §Criterios de Optimalidad. **Parcial**.
- **Extra:** `CITAS_PROSA_SIN_BIB_CAPS1-4.md` (barrido `#cite` + heurística Author(YEAR); sin tocar `.bib`).
- **Comercial Día 3:** diferido — callouts monorepo/caps 15+ / `frontmatter/portada.typ` modo comercial **no aplican** a este repo (12 caps, sin esos paths); corresponde Causal AI sesión 11:00.
- SuperGrok: **no usado**.

### Sync Typst.app
- **OK** (2026-09-24 ~09:21): LITERATURA, REGISTRO, PENDIENTES, Ap.A, cap04, INFORME_APENDICE_A_CLASIF.md, CITAS_PROSA_SIN_BIB_CAPS1-4.md. Preview: Compilation complete.

### No hecho / diferido
- Hipótesis formales Luo: pendientes (sin PDF libre usable hoy).
- Podas `ninguna` (Wilks): Vie 25.

### Compile
- Typst.app preview: **Compilation complete**.
- Local: error preexistente conocido `capitulos/intro.typ:89` (`$Value(policy; dot)$`); no tocado hoy.

## 2026-09-25

### Hecho
- **T1 (V):** Survey Shi (2025) arXiv:2502.16195 — S2 `f811e4b147239dee1d5d914766dae44a78222e58`; OpenAlex **W4414838671**; DOI preprint 10.48550/arXiv.2502.16195. Abstract + §5 Table 4.2 (taxonomía IC) + §6 leídos en PDF. Ficha + matriz huecos en `LITERATURA_2022_2026.md`. **No** `.bib`.
- **T2 (D):** Poda `ninguna` Wilks **NO ejecutada** (sin OK autor). Insumo: `PODA_NINGUNA_PROPUESTA.md`. DECISIÓN: ¿OK borrar `dem:ch4-wilks`?
- **T3 (D):** Cap. 4 bloque asintótica — sin `COMPRIME`; `// AUTONOMIA 2026-09-25` + inventario labels vivos antes de §Modelos Semiparamétricos. **Parcial**.
- **Extra:** matriz survey↔catálogo ($isoto$/$arrow.squiggly$) con huecos explícitos (misma ficha LITERATURA).
- **Comercial Día 4:** diferido — requiere `frontmatter/portada` modo comercial y `bibliografia/refs.yml` (no existen en `exportacion_agente_v1/`; 12 caps). Corresponde Causal AI / monorepo comercial sesión 11:00.
- SuperGrok: **omitido** — taxonomía Table 4.2 legible en PDF; sin ambigüedad que requiera grok.com.

### Sync Typst.app
- Pendiente al cierre del ejecutor (sin computerUse en este subagente). Archivos listos en backup + `libro-hoy/2026-09-25/agentes/`.

### Compile
- Local: error preexistente conocido `capitulos/intro.typ:89` — no tocado hoy.
- Typst.app preview: **pendiente de sync**.

### Decisión autor
- ¿Poda Wilks LRT (`apendice_demostraciones.typ` ~639–669, `dem:ch4-wilks`)? Ver `PODA_NINGUNA_PROPUESTA.md`.

## 2026-09-26

### Hecho
- **T1 (V):** Ficha conjunta línea conformal — Foffano et al. (2023) arXiv:2304.02574 + PERRY Mandyam et al. (2025) arXiv:2507.20068. OpenAlex Foffano CDC **W4391020688** / preprint **W4362679650**; PERRY **W6891744960**. S2 Foffano `3831a0318d9db98eac73a54a6b3e9e25a84aa2e2`; PERRY `ea2ee7a0e7cbe1c462eb45196f46a46ec559c867`. PDFs arXiv leídos (Assump./Thm). En `LITERATURA_2022_2026.md`. **No** `.bib`.
- **T2 (D):** Cap. 4 bloque semiparamétrico — sin `COMPRIME`; `// AUTONOMIA 2026-09-26` + inventario keys vivos antes de §Causalidad y Sensibilidad en `cap04_herramientas.typ`. **Parcial**.
- **T3 (D):** `BIBLIOGRAFIA_COMENTADA_PARTE_I.md` (Parte I = caps. 2–4 según `main.typ`); solo obras de lecturas/`#cite`/`.bib`. Sin inventar cites.
- **Extra:** `CONTEO_PAGINAS_2026-09-26.md` — compile FAIL → sin conteo por Parte; baseline histórico 274 pp. (`PENDIENTES` v0.2-base); delta vs ~110 **no medible**.
- **Comercial:** diferido (paths frontmatter/refs.yml no en este repo; Causal AI 11:00).
- SuperGrok: **omitido** — sin ambigüedad (Assumps./Thms legibles en PDF; AUTONOMIA estándar).

### Sync Typst.app
- Pendiente (sin computerUse en este ejecutor). Lista en `SYNC_PENDIENTE.md`.

### Compile
- Local typst 0.13.1: **FAIL** `capitulos/intro.typ:89` (preexistente). No tocado.
- Typst.app preview: pendiente de sync.

### Decisión autor (sigue abierta)
- ¿Poda Wilks LRT (`dem:ch4-wilks`)? Ver `PODA_NINGUNA_PROPUESTA.md` (desde 2026-09-25).

## 2026-09-27

### Hecho
- **T1 (V):** Fichas evaluación estadística LLMs → cap. 11. (A) Bowyer, Aitchison & Ivanova (2025) arXiv:2503.01747 — OpenAlex **W4416045832**; S2 **4ca76fd94f9227eb3c2cd717206734645932dc4e**; ICML (DBLP). (B) Miller (2024) arXiv:2411.00640 — OpenAlex **W4404345312**; S2 **4ba6a858d4c77b8b6dcd2bcf8b159eb8c1353e6b** (IC «too narrow»; citado por Bowyer). PDFs arXiv leídos. En `LITERATURA_2022_2026.md`. **No** `.bib`.
- **T2 (D):** Cap. 10 — comentarios `// REPARTO 2026-09-27: destino cap. X` en F.1–F.12; `#pendiente` reducido (índice hecho; queda andamiaje + movimiento físico Fase 3). F.12 afinado → **cap. 11** (AUTONOMIA).
- **T3 (D):** Hilo SSCH **ya cronológico** (keys cap01→cap02→cap03-b→cap04-b→cap05-b→cap06). Documentado `// AUTONOMIA 2026-09-27: hilo SSCH ya cronológico (cap1–6)`; **no** reordenado.
- **Extra:** `INDICE_LABORATORIOS_F1_F12.md` + tabla Typst `tab:lab-reparto-f1-f12` en cap. 10.
- **Comercial Día 6** (como_usar / Ap.E / CHANGELOG): **diferido** — paths `frontmatter/como_usar.typ`, `refs.yml`, modo curso/comercial **no existen** en `exportacion_agente_v1/` (12 caps). Corresponde monorepo Causal AI / plan comercial.
- SuperGrok: **omitido** — sin ambigüedad (títulos/IDs verificados OA+S2+PDF).

### Sync Typst.app
- **OK** (2026-09-27): `cap10_casos.typ`, `LITERATURA_2022_2026.md`, `INDICE_LABORATORIOS_F1_F12.md`, `REGISTRO_DIARIO.md`, `PENDIENTES.md`, `SYNC_PENDIENTE.md`. Preview: **Compilation complete** (sin `intro.typ:89` visible).

### Compile
- Local typst 0.13.1: **FAIL** `capitulos/intro.typ:89` (preexistente; `$Value(policy; dot)$`). No tocado.
- Smoke solo-cap10: falla en `cap10_casos.typ:310` (`$phi(...; ...)$`, mismo patrón `;` en math) — **preexistente**, no introducido por REPARTO/tabla.
- Typst.app preview: **Compilation complete**.

### Decisión autor (sigue cerrada)
- Wilks `dem:ch4-wilks`: **NO TOCAR** (decisión 2026-09-25).

## 2026-09-28 (Lun 28 — cierre Semana 1)

### Hecho
- **T1 (A):** `INSUMO_CAP12_PROBLEMAS_x_LITERATURA.md` — tabla problema × literatura (9 filas: confounding, POMDP, LLM-agents, agenda Teoría/Aplicación, sample-efficient OPE, Causal RL, e2e). Estados = `PENDIENTE AUTOR`. Cap. 12 **no** editado.
- **T2 (D):** `BIBLIOGRAFIA_COMENTADA_PARTE_II.md` (Parte II = caps. 5–6). Cap. 6 sin lista de lecturas/`#cite` externos → asimetría documentada.
- **T3 (V):** Resolución citas prosa §2.1 — 6 mapeos a claves existentes; 8 altas `.bib` con DOI/OA/Crossref verificados; 3 pendientes (Basu 1955, Billingsley 1995, Bertsekas 2012). Informe `CITAS_PROSA_RESOLUCION_2026-09-28.md`. Edits quirúrgicos en listas de lecturas: cap02, cap03, cap04, cap05, cap07, cap08 + `referencias.bib` (111→119 claves).
- **Extra (V):** `VALIDACION_FICHAS_LITERATURA_2026-09-28.md` — 8/8 OK; Luo sin arXiv (ya declarado). Encaje Shi JASA +cap. 12 en `LITERATURA_2022_2026.md`.
- **Comercial:** diferido (paths frontmatter/refs.yml no en este repo).
- SuperGrok: **omitido**.
- Wilks `dem:ch4-wilks`: **NO TOCAR**.

### Sync Typst.app
- **OK** (2026-09-28): 15/15 archivos (`referencias.bib`, 6 caps, 8 md). Preview: **Compilation complete**. `intro.typ` no tocado.

### Compile
- Local typst 0.13.x: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado (fix de `;` en math ambiguo respecto a intención tipográfica; no tocar a ciegas).

### Decisión autor
- Tabla cap. 12 lista para marcar *abierto / parcialmente resuelto / resuelto* en `INSUMO_CAP12_PROBLEMAS_x_LITERATURA.md`.

## 2026-09-29 (Mar 29 — Semana 2)

### Hecho
- **T1 (A) + Extra:** Autor aún no definió columnas → insumo `insumos/cap9_columnas.md` (esquema 7 columnas: Resultado / Componente / Garantía / Condiciones / Origen tabla / Estado ↔|↝|— / notas; alcance 9+4 tablas; 5 preguntas abiertas). **AUTONOMIA 2026-09-29**. Sin prosa de contribución.
- **T2 (D):** `LISTA_UNICA_TABLAS_TRAZABILIDAD_2026-09-29.md` — volcado de filas sin consolidar Typst ni borrar. Inventario: **9 tablas en cap09** + **4 hermanas** (ch7/ch8/ch9/ch11) = **13** (el «veinte» del `#pendiente` no cuadra; documentado). Filas **98**; duplicados (heurística token) **52**; `CONDICIONES SIN ESPECIFICAR` **80** (solo ch1–ch3 tienen columna Condiciones llena: 18 filas). Comentario `// AUTONOMIA 2026-09-29: lista única…` junto al `#pendiente` de `cap09_verificacion.typ`.
- **T3 (D):** `BIBLIOGRAFIA_COMENTADA_PARTE_III.md` (caps. 7–9). Cap. 9 sin `#cite`/lista de lecturas → asimetría documentada. Enriquecimiento OA+S2 (sin `.bib` nuevo): Jiang W2234859443 / S2 `2fdb536d…` (arXiv 1511.03722); Dudík W1809653203 / S2 `5ccf7658…` (arXiv 1103.4601); Thomas W2273088453 / S2 `a8bbcf5e…` (DOI 10.1609/aaai.v29i1.9541); Shi W4200424214 / S2 `bcc37838…` (DOI 10.1111/rssb.12465).
- **Comercial Día 8:** diferido — Caps. 3–4 monorepo Causal AI / paths frontmatter/refs.yml/callouts curso **no aplican** a `exportacion_agente_v1/` (12 caps).
- SuperGrok: **omitido** — sin ambigüedad D/V que lo requiera (inventario de tablas legible; IDs OA/S2 OK).
- Wilks `dem:ch4-wilks`: **NO TOCAR**.

### Sync Typst.app
- **OK** (2026-09-29 ~09:10): 7/7 (`cap09_verificacion.typ`, `insumos/cap9_columnas.md`, `LISTA_UNICA_…`, `BIBLIOGRAFIA_COMENTADA_PARTE_III.md`, REGISTRO, PENDIENTES, SYNC). Preview: **Compilation complete**. `intro.typ` no tocado.

### No hecho / diferido
- Tabla canónica Typst: **Mié 30** (no hoy).
- Corrección DOI dudoso `dudik2011doubly` en `.bib`: no tocado (deuda anotada en biblio Parte III).

### Hallazgos
- «Veinte tablas» del marcador cap. 9 = cifra no verificable; realidad = 13 de la familia trazabilidad. No existe `tab:ch10-trazabilidad`.
- Filas con condiciones explícitas solo en `tab:ch1|ch2|ch3-trazabilidad` (18); el resto CSE por columna ausente.

### Compile
- Local typst 0.13.1: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas.
- Typst.app preview: **Compilation complete**.

### Decisión autor (abiertas)
- Columnas/alcance de la canónica: ver preguntas 1–5 en `insumos/cap9_columnas.md`.
- Insumo cap. 12 (28-sep) sigue pendiente de marcas abierto/parcial/resuelto.

## 2026-09-30 (Mié 30 — Semana 2)

### Hecho
- **T1 (A):** `insumos/CSE_RESOLUCION_2026-09-30.md` — de 80 CSE: **31 propuestas** desde cuerpos `#thm-env` del manuscrito; **49 CSE** siguen; 18 `ya-tenía` (ch1–ch3). Actualizado `insumos/cap9_columnas.md` §5 con decisiones AUTONOMIA 2026-09-30 (preguntas 1–5; no OK autor).
- **T2 (D):** Tabla canónica `tab:trazabilidad-canonica` — 98 filas × 7 columnas en `capitulos/cap09_tabla_canonica.typ` (`#include` desde `cap09_verificacion.typ`). Comentario AUTONOMIA junto al `#pendiente` (inventario 13 ≠ veinte; sin borrar fuentes; `#pendiente` no retirado). Celdas en `raw(...)` para compilar (refinamiento tipográfico diferido). Estado default `—`. Smoke local tabla: **OK** (`/tmp/smoke_canonica.pdf`).
- **T3 (D):** `BIBLIOGRAFIA_COMENTADA_PARTE_IV.md` (caps. 10–12). Cap. 11 sin `#cite`; cap. 10 solo `hernan2020causal`. Enriquecimiento OA+S2: Shi W4200424214 / S2 `bcc37838…`; Kallus W2994709386 / S2 `f49cfdbc…` (arXiv 1909.05850); Hernán sin ID unívoco (deuda DOI `.bib`). **No** `.bib` nuevo.
- **Extra (V):** `DIFF_DUPLICADOS_TRAZABILIDAD_2026-09-30.md` — 21 grupos; recomendaciones de poda **sin ejecutar**.
- **Comercial Día 9:** diferido — Caps. 5–6 monorepo Causal AI / paths frontmatter/refs.yml **no aplican** a este repo (12 caps).
- SuperGrok: **omitido** — sin ambigüedad que lo requiera.
- Wilks `dem:ch4-wilks`: **NO TOCAR**.

### Sync Typst.app
- **OK** (2026-09-30 ~09:22): 9/9 (`cap09_verificacion.typ`, `cap09_tabla_canonica.typ`, insumos CSE/columnas, BIBLIO Parte IV, DIFF duplicados, REGISTRO, PENDIENTES, SYNC). Preview: **Compilation complete**. `intro.typ` no tocado.

### Hallazgos
- AUTONOMIA aplicada ante silencio del autor en preguntas 1–5 del 29-sep.
- 31/80 CSE resolubles por evidencia textual; el resto (sin label o definición pura / filas mapa) permanece CSE.
- Smoke de la canónica OK; `main.typ` sigue FAIL en `intro.typ:89` (preexistente).

### Compile
- Local typst: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas.
- Smoke `cap09_tabla_canonica.typ`: **OK**.

### Decisión autor (abiertas)
- Rellenar Estado ↔/↝ de la canónica; OK o ajuste de columnas AUTONOMIA; poda de duplicados (ver DIFF); marcas cap. 12; DOI `hernan2020causal`.

## 2026-10-01 (Jue 1 — Semana 2)

### Hecho
- **T1 (A):** `insumos/cap9_sec1_auditar_garantia.md` — objetivo §1, esqueleto 5 subsecciones, anclas (`thm:ch9-isomorfismo`, `tab:trazabilidad-canonica`, `fig:ch9-incrustacion-dec-mdp`, defs Dec/MDP, tricotomía ↔/↝/—), 5 preguntas autor, ficha Landers & Doryab 2023 (OA W4372353038; S2 `0860b142a9e6c71974ffbbcb291f5d09d4b48142`; DOI 10.1145/3596444). **AUTONOMIA 2026-10-01**. Sin prosa de contribución. Sin `.bib` nuevo.
- **T2 (D):** Borrador CeTZ `fig:ch9-incrustacion-dec-mdp` en `capitulos/cap05_incrustacion.typ` tras la construcción del funtor; correspondencias = solo tabla del `@thm:ch9-isomorfismo`. Comentario `// AUTONOMIA 2026-10-01: borrador Fig.1 CeTZ; iteración Vie 2`. Import `@preview/cetz:0.3.4`. Smoke `/tmp/smoke_fig_ch9.pdf` **OK**.
- **T3 (V):** `BARRIDO_GARANTIAS_CANONICA_2026-10-01.md` — citas vivas 69 labels; **OK 41** / **FALTA 28** / **canónica sin cita viva 0**. Destacado: `thm:ch9-secuencial` FALTA; near-misses DR/CLT/Lehmann-Scheffé. Canónica **no** editada.
- **Extra (V):** `GARANTIAS_FUERA_CAP9_2026-10-01.md` — 108 líneas con «garantía»/Teorema fuera de `cap09_*` y `cap05_incrustacion.typ`.
- **Comercial Día 10:** diferido — paths Caps 7–8 / checklist curso del monorepo Causal AI **no existen** en `exportacion_agente_v1/` (12 caps).
- SuperGrok: **omitido** — sin ambigüedad D/V que lo requiera (figura = tabla del teorema; barrido mecánico).
- Wilks `dem:ch4-wilks`: **NO TOCAR**.
- Ficha también anotada en `LITERATURA_2022_2026.md`.

### Sync Typst.app
- **OK** (2026-10-01 ~09:10): 8/8 (`cap05_incrustacion.typ`, insumos §1, BARRIDO, GARANTIAS_FUERA, LITERATURA, REGISTRO, PENDIENTES, SYNC). Preview: **Compilation complete**. Copia accidental raíz del insumo eliminada. `intro.typ` / Wilks / canónica no tocados.

### Hallazgos
- Smoke CeTZ: nombres de nodo no pueden contener `.` (CeTZ 0.3.4) — corregido con ids `param|sample|…`.
- Barrido: muchas FALTA viven en apéndice de demostraciones o ejercicios cap. 4; deuda de aliases vs. labels canónicos.

### Compile
- Local typst 0.13.1 `main.typ`: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas.
- Smoke Fig.1 CeTZ: **OK** (`/tmp/smoke_fig_ch9.pdf`).

### Decisión autor (abiertas)
- Prosa §1 / ubicación respecto del `#include` canónica (preguntas 1–5 del insumo).
- Rellenar Estado ↔/↝; filas FALTA (p.ej. `thm:ch9-secuencial`); `#pendiente` veinte tablas → Vie 2.

## 2026-10-02 (Vie 2 — Semana 2)

### Hecho
- **T1 (A):** `insumos/cap9_sec2_protocolo.md` — objetivo §2, protocolo 8 pasos, anclas (reuso §1 + `ch:fallos` / barrido), 5 preguntas autor, ficha Prudencio, Máximo & Colombini 2023 (OA W4360584316; S2 `61e7a3d5606043594a8ce377870479f77a6b58c2`; DOI 10.1109/TNNLS.2023.3250269; arXiv 2203.01387). **AUTONOMIA 2026-10-02**. Sin prosa de contribución. Sin `.bib` nuevo. Candidato Patterson arXiv:2304.01315 (OA W4362655362) anotado; S2 `paperId` diferido (HTTP 429).
- **T2 (D):** Iteración CeTZ `fig:ch9-incrustacion-dec-mdp` en `capitulos/cap05_incrustacion.typ` — espaciado filas 1.5, `isoto` centrado en flecha, stroke/fill consistentes, tipografía 8/7.5/11pt, nota de alcance en caja, caption sin «Borrador» («Iteración Vie 2 — AUTONOMIA 2026-10-02»). Smoke `/tmp/smoke_fig_ch9.pdf` **OK**.
- **T3 (D):** `#pendiente` L15–18 **NO retirado** (andamiaje §1–§2 ausente; tablas fuente intactas; Estado —; FALTA 28). Comentario `// AUTONOMIA 2026-10-02: NO se retira…` bajo el marcador. `PENDIENTES.md` agencia diaria + marcador 9 actualizado a estado parcial.
- **Extra (D):** `FIGURAS.md` checklist CeTZ; puntero en notes `COMPRIME_CONVENCION.md` + `COMPRIME_CONVENCION.md` local.
- **Comercial Día 11:** diferido — Caps 9–10 / checklist curso del monorepo Causal AI **no existen** en `exportacion_agente_v1/` (12 caps).
- SuperGrok: **OK** (2026-10-02 ~09:19, grok.com) — brief §2 + Fig.1; 3 APLICAR-ahora (paso 0 origen; fusionar verificar→degradar; cierre fila+hash) aplicadas al insumo; 2 BACKLOG Fig.1 en `FIGURAS.md`; 1 DESCARTAR (justificación textual). Cadencia semanal cubierta.
- Wilks `dem:ch4-wilks`: **NO TOCAR**.
- Ficha también en `LITERATURA_2022_2026.md`.

### Sync Typst.app
- **OK** (2026-10-02 ~09:18): 9/9 (`cap05_incrustacion.typ`, `cap09_verificacion.typ`, `insumos/cap9_sec2_protocolo.md`, `LITERATURA_2022_2026.md`, `FIGURAS.md`, `COMPRIME_CONVENCION.md`, `REGISTRO_DIARIO.md`, `PENDIENTES.md`, `SYNC_PENDIENTE.md`). Preview: **Compilation complete**. Temporales raíz eliminados. `intro.typ` / Wilks / canónica no tocados.

### Hallazgos
- CeTZ 0.3.4: ids sin `.` (reconfirmado); `isoto` legible si comparte `y` con la flecha.
- Hueco del `#pendiente` cap.9 sigue abierto pese a canónica existente — regla dura respetada.

### Compile
- Local typst 0.13.1 `main.typ`: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas.
- Smoke Fig.1 CeTZ: **OK** (`/tmp/smoke_fig_ch9.pdf`).

### Decisión autor (abiertas)
- Prosa §1–§2 / ubicación vs `#include` canónica (preguntas de ambos insumos).
- Rellenar Estado ↔/↝; filas FALTA; retiro `#pendiente` solo con cierre real.
- ¿Walkthrough único vs tres mini-ejemplos en §2? (preg. 2 del insumo sec2).

## 2026-10-03 (Sáb 3 — Semana 2)

### Hecho
- **T1 (A):** `insumos/cap9_sec3_no_verificable.md` — objetivo §3, árbol NV (NV-obs / NV-test / NV-id / CSE), anclas (`tab:trazabilidad-canonica`, ↔/↝/—, `ch:fallos`, CSE, `note:ch9-extension-no-demostrada`, puente cap. 11, insumos §1–§2, Fig.3), 5 preguntas autor, ficha Khan, Saveski & Ugander 2023 (OA W4377372456; S2 `d186f3787e1679211eee8b9b8b37f9228c063764`; DOI 10.48550/arXiv.2305.11812; arXiv 2305.11812). Nota hermano Bruns-Smith & Zhou 2023 (OA W4320351330; S2 `71a5ece57b39f098762d6123660ecb597886057a`). **AUTONOMIA 2026-10-03**. Sin prosa de contribución. Sin `.bib` nuevo.
- **T2 (D):** CeTZ `fig:ch9-protocolo-verificacion` en `capitulos/cap09_verificacion.typ` tras `#include` canónica; import `@preview/cetz:0.3.4`; flujo pasos 0–8 + rama §3 / ↝ / `ch:fallos`; comentario AUTONOMIA 2026-10-03. Smoke `/tmp/smoke_fig_ch9_proto.pdf` **OK**; smoke canónica+Fig.3 `/tmp/smoke_cap09.pdf` **OK**. `FIGURAS.md` actualizado.
- **T3 (V):** `typst compile main.typ` → **FAIL** preexistente `intro.typ:89` (no tocado). `REFS_CAP9_2026-10-03.md` — barrido `@`/`#ref` en cap09+tabla.
- **Extra (V):** único roto seguro `@ch:mdp` → `@ch:mdp-bellman` (L849). Puntos finales (`@ch:isomorfismo.`) = falsos positivos Typst 0.13. Tras fix: **0 rotos**.
- **Comercial Día 12:** diferido — Caps 11–12 / checklist / refs.yml del monorepo Causal AI **no existen** en `exportacion_agente_v1/` (12 caps).
- SuperGrok: **omitido** — cadencia semanal cubierta Vie 2.
- Wilks `dem:ch4-wilks`: **NO TOCAR**.
- Ficha también en `LITERATURA_2022_2026.md`.

### Sync Typst.app
- **OK** (2026-10-03 ~09:05): 8/8 (`cap09_verificacion.typ`, `insumos/cap9_sec3_no_verificable.md`, `LITERATURA_2022_2026.md`, `FIGURAS.md`, `REFS_CAP9_2026-10-03.md`, REGISTRO, PENDIENTES, SYNC). Preview: **Compilation complete**. `intro.typ` / Wilks / canónica no tocados.

### Hallazgos
- Overlap / partial ID (Khan et al.) es el arquetipo literario de NV-id para el paso 5b → §3.
- CeTZ 0.3.4: ids sin `.` (reconfirmado); `$leadsto$` no es símbolo Typst → unicode `↝` en caption.
- Refs cap. 9 sanas tras un solo typo de alias MDP.

### Compile
- Local typst 0.13.1 `main.typ`: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas.
- Smoke Fig.3 CeTZ: **OK** (`/tmp/smoke_fig_ch9_proto.pdf`).
- Smoke canónica + Fig.3: **OK** (`/tmp/smoke_cap09.pdf`).

### Decisión autor (abiertas)
- Prosa §1–§3 / ubicación vs `#include` canónica (preguntas de los tres insumos).
- ¿Degradación `↝` ante NV automática o visto bueno fila a fila?
- ¿Mini-ejemplo NV-id (overlap OPE) + Bruns-Smith en prosa o solo LITERATURA?
- Rellenar Estado ↔/↝; filas FALTA; retiro `#pendiente` solo con cierre real.

## 2026-10-04 (Dom 4 — Semana 2)

### Hecho
- **T1 (A):** `insumos/cap9_ejemplo_ssch.md` — walkthrough protocolo 0–8 sobre SSCH × `@thm:ch6-dr` (gancho `@ex:ssch-trazability` / `@ex:ch6-dr-ssch`; anclas `tab:trazabilidad-canonica`, `fig:ch9-protocolo-verificacion`, `ch:fallos`, `sec:ssch-intro`); rama NV → `insumos/cap9_sec3_no_verificable.md`; 5 preguntas autor; ficha Nambiar et al. 2023 (OA W4385568106; S2 `c6e7f5097e1073f164d4c580a0b2652b882cc34e`; DOI 10.1145/3580305.3599800; arXiv 2302.07549; KDD '23). **AUTONOMIA 2026-10-04**. Sin prosa de contribución. Sin `.bib` nuevo.
- **T2 (D):** Iteración CeTZ `fig:ch9-protocolo-verificacion` en `capitulos/cap09_verificacion.typ` — caption sin «Borrador»; espaciado Δy=1.55; pastillas sí/no; nota de alcance; comentario AUTONOMIA 2026-10-04. Smoke `/tmp/smoke_fig_ch9_proto.pdf` **OK**; smoke canónica+Fig.3 `/tmp/smoke_cap09.pdf` **OK**. `FIGURAS.md` → Iteración Dom 4.
- **T3 (D):** Búsqueda `COMPRIME` / `COMPRIME-BEGIN`/`END` en `*.typ` → **0 marcadores operables**. No se inventaron cortes. Nota `// AUTONOMIA 2026-10-04` + inventario breve en `cap05_incrustacion.typ`. Doc `AUTONOMIA_COMPRIME_2026-10-04.md`. **Parcial**.
- **Extra (V):** `INVENTARIO_RESULTADOS.md` — baseline caps (Σ keys 386; thm/cor/prop/lem 137; def 113; ex 136) + nota «sin delta COMPRIME Dom 4». Ref. `INVENTARIO_CAP02_VIVOS.md` / AUTONOMIA previas.
- **Comercial Día 13:** diferido — Caps 13–15 (árboles / validación / despliegue servicio) del monorepo Causal AI **no existen** en este repo de 12 caps (`exportacion_agente_v1/`).
- SuperGrok: **omitido** — cadencia semanal cubierta Vie 2.
- Wilks `dem:ch4-wilks`: **NO TOCAR**.
- Ficha también en `LITERATURA_2022_2026.md`.

### Sync Typst.app
- Pendiente (padre): ver `SYNC_PENDIENTE.md` 2026-10-04.

### Hallazgos
- Garantía DR (`thm:ch6-dr`) es el ancla más limpia del hilo SSCH×canónica; overlap/no-confounding clínico → NV-id (§3) sin rellenar CSE.
- Nambiar et al. (KDD '23) aporta contraste offline RL clínico real (diabetes/sepsis) vs. SSCH sintético hipertensión.
- COMPRIME restantes: mapa histórico ≠ marcadores en `.typ`; compresión real sigue bloqueada a Fase 3 / marcadores explícitos.

### Compile
- Local typst 0.13.1 `main.typ`: **FAIL** `capitulos/intro.typ:89` (`$Value(policy; dot)$` → expected content, found array). Preexistente; **no** arreglado a ciegas. TYPST_EXIT=1.
- Smoke Fig.3 CeTZ: **OK** (`/tmp/smoke_fig_ch9_proto.pdf`).
- Smoke canónica + Fig.3: **OK** (`/tmp/smoke_cap09.pdf`).

### Decisión autor (abiertas)
- Prosa §1–§3 + ubicación del walkthrough SSCH (cap. 9 vs 10).
- ¿Label canónico del ejemplo = `thm:ch6-dr` u otro (`thm:ch11-shi` / `thm:ch6-kallus`)?
- ¿Degradación `↝` ante NV automática o visto bueno fila a fila?
- Rellenar Estado ↔/↝; filas FALTA; retiro `#pendiente` solo con cierre real.
- ¿Nambiar en prosa del walkthrough o solo LITERATURA?
