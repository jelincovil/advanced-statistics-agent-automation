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

---

## 2026-11-02 — Día 1 de PLAN M-30D

### Hecho
- **Decisiones delegadas del autor tomadas:** acta `DECISIONES_2026-11-02.md`
  (D1–D11): canal FnT→SpringerBriefs→IMS; doble artefacto M (inglés) + C
  (curso); V4 capítulo completo con degradación escrita; título de M; caso
  real = Open Bandit Dataset; alcance negativo; D9 lab insignia; typst fijado;
  arXiv para V3.
- **Plan de 30 días:** `PLAN_M_30D_2026-11-02.md` (criterio de terminado
  `v0.9-M`, mapa de 13 caps + 5 apéndices, calendario, degradaciones).
- **F0 ejecutada:** typst **0.15.1** instalado en la VM (`~/.local/bin`).
- **Fallo de compilación cerrado:** la nota «FAIL `intro.typ:89`» era de
  typst **0.13.1** (versión vieja; error `$Value(policy; dot)$`); con 0.15.1
  no existe. El fallo real era `apendices/apendice_reproduccion.typ:148`
  (`$nT$` → variable desconocida). Corrección mínima: `$nT$` → `$n T$`.
- **Andamiaje** `monografia_M/` (partes/, apendices/, fichas/, labs/,
  verificacion/) + README con reglas.

### Compile
- `typst 0.15.1 compile main.typ` → **exit 0, 0 errores, 0 advertencias,
  275 pp**. PDF de control: `.scratch/check_main.pdf`.

### Hallazgos
- `intro.typ:89` era fallo de versión (0.13.1), no del fuente: queda registro
  para depurar la línea obsoleta de `PENDIENTES.md` en su próxima revisión.

### Bloqueos / decisiones abiertas (autor)
- Ninguna nueva; las del registro anterior siguen abiertas.

### Mañana (día 2, plan)
- venv de labs en `book_stat_inference_v0/` + `ejecutar_todos.py` completo;
  auditoría express `referencias.bib` × fichas (informe).

---

## 2026-11-03 — Día 2 de PLAN M-30D

### Hecho
- **venv de laboratorios** en `book_stat_inference_v0/.venv` con
  `requirements.txt` fijado (numpy 2.5.3 · scipy 1.18.1 · sklearn 1.9.1 ·
  gymnasium 1.3.0 · pandas 3.1.0).
- **`ejecutar_todos.py` completo:** 14/14 labs exit 0 (`stdout` y hashes
  idénticos al registro previo; ver Anexo de `AUDITORIA_BIB_2026-11-03.md`).
- **Auditoría express `.bib`:** `AUDITORIA_BIB_2026-11-03.md` — 130 entradas,
  0 citas rotas, 0 duplicados; 19 obras 2022–2026 clasificadas en niveles
  A (3, verificadas con artefacto) / B (8, auditadas globalmente) / C (8, sin
  rastro documentado). Protocolo para M: nivel A o ficha nueva.

### Compile
- No se tocó el manuscrito hoy; estado del día 1: exit 0, 275 pp.

### Hallazgos
- `versiones.json` regenerado cambia solo la cadena `platform` (kernel del
  host); resultados inalterados. Regeneración aceptada como registro del
  entorno real.
- La campaña H01–H60 cubrió integridad global; el hueco real es por obra
  reciente sin ficha (nivel C), no fabricación.

### Bloqueos / decisiones abiertas (autor)
- Ninguna nueva.

### Mañana (día 3, plan)
- `plantilla_M.typ` (entornos/frontmatter en inglés) + `main.typ` esqueleto;
  fichas anytime-valid: Waudby-Smith et al. 2022, Ramdas et al. 2023 (PNAS),
  Vovk–Wang 2021, Howard et al. 2021.

---

## 2026-11-03 — Sprint M: manuscrito v0.1-M completo (días 3–14 del plan comprimidos)

### Hecho
- **`monografia_M/` escrita entera:** plantilla inglesa adaptada del libro,
  `main.typ` con 3 partes, prefacio e intro, **13 capítulos + 5 apéndices**,
  compilando limpio (`typst 0.15.1`, 61 pp, 0 errores, 0 advertencias).
- **Núcleos nuevos con prueba:** V1 = frontera estructural del plegado Wald
  (`thm:m-frontier`, demostración por contradicción en cilindros, con su
  nota de frontera); V2 = cálculo de certificados de transferencia
  (3 reglas + 3 contraejemplos computados + regla de reportabilidad);
  V3 = capítulo anytime-valid autocontenido (Ville demostrada, e-proceso
  Hoeffding, CS off-policy con prueba) + remisión atribuida a
  Waudby-Smith et al. 2022; V4 = capítulo de frontera LLM con
  no-identificación demostrada (`prop:m-noident`).
- **Demostración desplegada** del thm de parada bayesiana (deuda de la
  evaluación 2026-11-02, cerrada en cap. 5 + ap. A).
- **Estudio OBD ejecutado** (submuestras reales del sdist obp 0.5.7):
  propensiones verificadas en datos (random=0.0125 exacto para las 10k
  filas; bts en [4.5e-05, 0.95424]); IS/DR/DM = 0.0059/0.0057/0.0051;
  IC-DR [-0.0022, 0.0136]; CS vacua con análisis del precio. Protocolo
  completo en `tab:m-obd-protocolo`; OPEN declarado para rerun a campaña
  completa.
- **Lean Fase 0:** corrida `lean-pilot-mopsis` del discovery **3/3
  resueltos**; archivo canónico `monografia_M/pilot_core_proven.lean`
  elabora con **cero sorry**. Plan por fases en `VERIFICACION_LEAN_PLAN.md`.
- **Verificación numérica:** 11 checkers por capítulo, todos OK; labs V3:
  IC de tiempo fijo con miradas pierde cobertura (0.607 ± 0.008) vs CS
  (0.000); lab B: trayectoria viola 0.000, E[M_tau]=0.0190 ≤ 1, ancho 0.775.
- **Registro:** `ejecutar_M.py` → `resultados_M.json`, **14/14 exit 0**
  (3 labs + 11 checkers). Fichas creadas: waudbysmith2022, ramdas2023,
  vovk2021, howard2021, saito2021obd (verificadas contra arXiv/Euclid).
- **Bugs de laboratorio corregidos en el proceso:** ε-greedy mal
  normalizado (no sumaba 1), bloques de predicción con `position`
  duplicada, folds booleanos escalares, `data_obd` relativo al cwd
  (ahora relativo al script).

### Compile
- `monografia_M`: exit 0, 61 pp, 0 advertencias (watermark DRAFT v0.1-M).
- Libro español: intacto, sigue compilando (275 pp).

### Ítems abiertos declarados (v0.1-M)
1. Ejercicios sin portar (OPEN en la intro de M).
2. Rerun OBD a campañas completas con sesiones como unidades (OPEN cap. 11).
3. Fases Lean 1+ (plan escrito; Fase 0 hecha).
4. Revisión humana de prosa inglesa (Fase 4 del plan de 30 días).

### Decisiones tomadas en el sprint (registro)
- OBD accedido vía **submuestras reales del sdist** tras fallos de build del
  `obp` en Python 3.12 (backend poetry-core roto, pin Python <3.11): se
  vendorizó `labs/data_obd/`; procedencia y método en
  `fichas/saito2021openbandit.md` y apéndice D. No se peleó más con pip.
- opb install: NO instalado en ninguna venv (metadata rota); el pipeline
  OBD usa solo pandas/sklearn del venv del libro.

### Mañana (día siguiente, plan)
- Apéndice A de M: pase de revisión contra el apéndice del libro español.
- Fase 1 Lean (proyecto `lean_verify/` con lake) si se autoriza otra corrida
  de discovery acotada.

---

## 2026-11-03 (t2) — Doble pista autorizada + D9 cerrada en pista C

### Decisión del autor
Adaptar el plan a **doble pista** (addendum en `PLAN_M_30D_2026-11-02.md`):
M pista principal con sus puertas intactas; C entra por orden de riesgo,
primero D9. Mecanismo: C se suspende si consume dos buffers de M.

### D9 — laboratorio insignia corregido (reimplementación completa, no renombrado)
- **`representation.py` nuevo** (`agents_curso/capitulo_09_isomorfismo/src/...`):
  construcción fiel del teorema — `mdp_for_theta` (estados =
  $\mathcal{X}\cup\{$TERMINAL$\}$, `initial_dist`$=P_\theta$, $r=-L$
  independiente de $x$ dado θ, terminal absorbente), `risk_statistical`
  (riesgo VERDADERO de Wald integrando sobre $X$), `verify_representation`
  (identidad exacta enumerando TODAS las reglas y una malla de θ; biyección
  por cardinalidad; política recibe solo $x$). Default: señal Bernoulli
  canónica $P_\theta(X=1)=\theta$.
- **`functor.py` reescrito**: `F`/`F_inv` quedan como demo clairvidente con
  `DeprecationWarning` y docstring que dice qué NO son;
  `verify_isomorphism` reimplementado (ejecuta la verificación real +
  reporta el acuerdo δ*/π* como coincidencia de pérdida lineal, no como
  teorema), conservando las claves que lee `agent.py`.
- **`wald.py`**: docstring de `risk` corregido (evaluación puntual
  $L(\theta,f(\theta))$ ≠ riesgo de Wald; apunta a `risk_statistical`).
- **`agent.py`**: traza ahora loguea `J=−R verificado integrando sobre X`
  con el error máximo (0), no "functor biyección".
- **Claims**: README y `__init__.py` pierden "funtor/composición"; gana la
  frase explícita "no se afirma equivalencia de categorías".
- **Verificación**: venv propio del laboratorio (`pip install -e .[test]`),
  baseline 39/39 → tras el cambio **47/47** (8 tests nuevos de
  representación); `run_agent` end-to-end OK con datos Bernoulli
  ($\hat\theta=0.4327$, iso_ok=True, identity exacta).

### Estado de pistas
- M: sin cambios desde el sprint (v0.1-M, 61 pp, todo verde).
- C: D9 cerrada. Próximas en orden de riesgo: 6 PENDIENTE mecánicos →
  aliases de etiquetas migradas → sync Typst.app.

---

## 2026-11-03 (t3) — Pista C: PENDIENTE mecánicos de la editorial

### Hecho (barrido + cierres, todo compilando: exit 0, 275 pp, 0 advertencias)
- **Barrido real de marcadores:** vivos solo 4, todos en
  `apendices/apendice_reproduccion.typ` (ítems 13–16 de la foto 2026-09-22).
- **Ítem 1 (tabla de la intro):** decisión «mantener + remisión»: el caption
  de `tab:correspondencia-central` ahora remite a la canónica
  `tab:isomorfismo-completo`. Sin duplicación nueva.
- **Ítem 6 (§Tests de Hipótesis Bayesianos, cap04):** eliminación aprobada
  ejecutada. Verificado ANTES de cortar: cero referencias externas a
  `def:ch4-bayes-factor`, `ex:ch4-bf-ssch`, `thm:ch4-bayes-decision` o
  `sec:ch4-bayes`. Fuera líneas 1452–1510.
- **Ítem 3 (transición cap03) y 12 (cap12 apilado):** cerrados materialmente
  por trabajo previo (existe §«Del modelo conocido al modelo aprendido»;
  `cap12` tiene un solo encabezado de nivel 1). Nada editado.
- **Apéndice G (13–16):** escenarios A/B/C **transcritos del artículo**
  (dinámica 5.25 autorregresiva 2-D con $z_t$ iid $N(0_2,I_2/4)$; A: Bernoulli
  iid 0.5; B: $0.5\,sigmoid(X_1)+0.5\,sigmoid(X_2)$; objetivo y
  $\mathbb{G}=N(0_2,I_2)$; C: Cliff Walking episódico con ruido, mezcla
  50–50) y verificados contra el repo fijado (`utility.py`, coinciden).
  Métricas: ECP/AL/$\log(MSE)$ ya estaban bien; fijadas réplicas (**N=50**
  por celda, comentario en `test.ipynb` «N = 50 is used in paper»), valor
  verdadero $N=10^5$ MC y horizonte $T_i=500$ del artículo; EC-Monte-Carlo
  de ECP al 95% con B=50 ≈ 0.031 anotado. **Versión fijada:** commit
  `7533c2847de1aa1a5f63fc5a979cf4842bac5fc7` (2023-01-11), estructura y
  requisitos (`sklearn==0.21.2`, `gym`) registrados. Estado del apéndice
  actualizado: diseño fijado; pendiente exclusivamente la ejecución (Fase 4).
- **`PENDIENTES.md`:** nota de exactitud 2026-11-03 en su §1 (la foto decía
  16 vivos; hoy realidad como arriba).

### Fuentes primarias usadas hoy
- arXiv:2001.04515v3 (texto de la sección de simulación y ec. 5.25).
- GitHub API/raw del repo SAVE en el commit fijado.

### Verificación
- `typst compile main.typ` → exit 0, 275 pp, 0 advertencias.
- `verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.

### Queda fuera (autor-decisiones, no mecánico)
- Ítem 2 (tres secciones anexas del cap02): mover o conservar es estructural.
- Ítems 4–5 (ejercicios y lecturas del cap04 sin curar): curaduría editorial
  (~40 ejercicios + listas concatenadas), no cirugía mecánica.
- Ítems 7–11 (cap05 transferencia, cap06, cap09 tablas, cap10, cap11): sus
  marcadores ya no están en el texto, pero la deuda de contenido que
  describía `PENDIENTES.md` no fue re-auditada hoy.
- Ejecución del Apéndice G (Fase 4 sobre el commit fijado).

---

## 2026-11-03 (t4) — Pista C: aliases de etiquetas + sync typst.app

### Aliases de etiquetas migradas (plan pista C, ítem 3)
- **Helpers nuevos en `plantilla.typ`:** `#env-alias` (teoremas y familia),
  `#obj-alias` (tabla/figura/algoritmo/supuesto/ejercicio), reutilizando
  `#section-alias`: hornean el MISMO (word, ch, n) del entorno/sección
  inmediatamente anterior, así que referencia vieja y nueva imprimen idéntico.
- **Insertados 95 aliases** en cap05 (ch9→ch5, ch7→ch5), cap06 (ch9→ch6,
  ch5→ch6), cap07 (ch10→ch7), cap08 (ch11→ch8), entre entornos (55) y
  secciones con etiqueta en línea propia (40). Recuento y mapeo en
  `ALIASES_2026-11-03.json`.
- **18 alias potenciales suprimidos** por colisión real con definiciones
  previas (`ex:chN-ejM` en cap04, `tab:ch5-trazabilidad`, `tab:ch8-trazabilidad`,
  `sec:ch7-lecturas` que ya pertenece a cap02) y un duplicado interno; las
  claves viejas siguen funcionando en todos esos casos.
- **Defectos propios corregidos en el proceso:** routing kind→contador
  erróneo para no-teoremas (obj-alias); orden de definición de
  `algorithm-counter` en plantilla; etiquetas sueltas `<sec:…>` re-adscritas
  a mis alias-context → reubicadas al final de cada sección; deduplicado que
  borró el alias correcto de `thm:ch5-isomorfismo` (restaurado kind
  "theorem" tras el teorema real; la Nota 5.11 conserva solo su clave vieja).
- **Verificación:** compile exit 0, 275 pp, 0 errores, 0 advertencias;
  sondeos en render: `@thm:ch9-isomorfismo`↔`@thm:ch5-isomorfismo` =
  Teorema 5.3/5.3; `@cor:ch9-bayes`↔`@cor:ch5-bayes` = Corolario 5.8/5.8;
  secciones vieja↔nueva idénticas (5.2, 7.20, 8.8, 7.2, 6.15).

### Sync Typst.app
- No puedo subir a typst.app desde la VM (subida = clic del autor con su
  sesión). Estado dejado listo:
  - `main.pdf` regenerado tras TODOS los cambios (275 pp, verde).
  - Paquete `.scratch/upload_typst_app_2026-11-03.tar.gz` con layout
    `exportacion_agente_v1/` (fuentes + PDF + documentos de gobernanza).
  - `SYNC_PENDIENTE.md` reescrito a estado 2026-11-03 (sustituye al
    manifiesto de la sesión 2026-10-04), con el detalle de los 6 cambios de
    fuente y la verificación previa corrida.

---

## 2026-11-03 (t5) — Proyecto MCP: evaluación, plan v1→v2.1 y decisiones resueltas

### Hecho
- **Evaluación de viabilidad MCP** entregada (subconjunto, no 9 servidores;
  criterio de uso real por herramienta).
- **Repos vendored OBD saneado:** `LICENSE-zr-obp.txt` (Apache-2.0) y
  `NOTICE.txt` añadidos a `monografia_M/labs/data_obd/` (brecha de
  redistribución cerrada, verificada contra el repo st-tech/zr-obp vía API).
- **Plan** escrito y mejorado con dos rondas de feedback técnico:
  stdout/stderr, path jail, outputs ≤10 filas, golden tol 1e-8 + float64,
  readOnlyHint, `uv run`, suite protocolo/esquema añadida, ε fijada por caso,
  humo 5 min, matriz de clientes, nombre `agente-stats`.
- **Verificado en código (cierra la pregunta crítica del feedback):** la
  decisión de ambos agentes instrumentados es CÓDIGO (`bayes_rule()` en
  `capitulo_09`; pipeline + ε-greedy ya explícita en `capitulo_10_ope`) →
  la Fase 1 es ejecutable tal cual.
- **Architecture decision (definitiva):** adecuar 2 agentes (09 → v1,
  10_ope → v2), conservar 10 como demos, borrar 0.

### Decisiones del autor (resueltas, §9.5 del plan)
1. Sílabo: el plan viejo queda superseded; referencia = libro de 275 pp
   (familia exponencial en cap. 4, conjugación en cap. 2 + labs).
2. ε por caso (defecto 0.3), informado al lector: logger registra Cmax y
   tasa de exploración; la ficha los muestra automáticamente. No dogma.
3. Umbral de piloto como rúbrica (objetivo ≥80% fichas completas; si corto,
   itera material y repite); se reporta distribución.
4. Gobernanza estándar de la casa: MIT/código, CC BY-NC-SA/texto;
   mantenedor = autor; triage semanal.
5. Calendario: avanzar sin fecha exacta; horas como supuesto declarado,
   revisión al cierre de Fase 3.

### Entregable
- `agents_curso/PLAN_MCP_V2.md` (v2.1, decisiones resueltas incluidas).

### Bloqueantes vivos
- Q3 (PII/logs reales + autorización) para ejemplos del repo público.
- Semana exacta del piloto (pendiente; hitos se asientan al cerrar Fase 3).

---

## 2026-11-03 (t6) — Proyecto MCP: Fase 0 ejecutada (paquete agente-stats)

### Entregable Fase 0
Nuevo paquete `agente-stats/` (MIT, python>=3.10, sin dependencias para el core):
- **`schemas.py`** — contrato JSONL estricto con errores accionables:
  campos de episodio (episode_id, unit, policy_version, horizon,
  propensity_mode ∈ {recorded, estimated, missing}, meta con
  epsilon/C_max/seed, steps con context/features, action, action_probs
  completa para instrumentados, propensity, reward), validación cruzada
  (suma 1, propensity = action_probs[acción], horizon = pasos, id único,
  estimated_by obligado si estimated), `load_jsonl` con archivo:línea y
  `_aggregate` por lotes de violaciones, `summarize` acotado (regla
  "resumen + ruta", nunca filas).
- **`certificates.py`** — ficha de justificación congelada con la regla del
  eslabón más débil calculada (`discharged_level`) y validación a la
  creación (`assert_consistent`), render markdown. Corregido en el proceso
  un error de dirección en la comparación de niveles captado por los tests.
- **`golden_episodes.py`** — generador dorado AUTOrvalidado: v1 (mundo
  Wald/Bernoulli-Beta: 40 episodios H=1, ε-greedy 0.3 por diseño, C_max =
  17/3, propensiones {0.15, 0.85}) y v2 (tabular 5×2: 24 episodios H=5,
  greedy exacto por iteración de valor + ε-greedy, recompensa gaussiana,
  γ=0.9). Semillas fijas (20261103/20261104).
- **`adapters/obd.py`** — OBD → JSONL stdlib (sin depender de `obp` roto):
  200 rondas, propensión 0.0125 constante verificada en filas.
- **Ejemplos:** `examples/agent_v1_episodes.jsonl`,
  `agent_v2_episodes.jsonl`, `obd_random_200.jsonl` + `README.md` de
  convenciones (dato≠instrucción, path jail, regeneración).

### Verificación (aceptación Fase 0)
- Los **3 JSONL validan** contra el contrato (incluye OBD con propensión
  constante confirmada). La ficha-campo existe y se validan sus reglas.
- **22/22 tests en verde** (schemas 11, golden 5, certificates 6) con
  pytest 3.12.14, PYTHONPATH=src.
- Reglas de la casa aplicadas: libería stdlib-only en core, cero prints en
  procesos MCP (irrelevante aquí: el generador es CLI), errores accionables
  con corrección explícita.

### Siguiente (Fase 1, plan)
`instrumentation/` compartido + adecuación de `capitulo_09_isomorfismo`
(v1) y `capitulo_10_ope` (v2) emitiendo el contrato de Fase 0, con sus
tests existentes (47) intactos.

---

## 2026-11-03 (t7) — Proyecto MCP: Fase 1 ejecutada (instrumentación de agentes)

### Entregable Fase 1
- **`agente_stats/core/episode_logger.py`** — pieza compartida (sin MCP):
  π ε-greedy por diseño con distribución completa por paso, selector
  determinista, cota C_max = 1+K(1-ε)/ε registrada con la tasa de exploración
  y la semilla, y EpisodeLogger validado.
- **`capitulo_09_isomorfismo/src/isomorphism_agent/instrument.py`** —
  `emit_agent_v1(...)`: misma semántica del flujo (posterior Beta,
  `bayes_rule()` en código) con comportamiento ε-greedy registrado; episodio
  H=1 externo al grafo LangGraph (decisión idéntica, registro aparte, como
  decisión de diseño declarada). Exportado en la API.
- **`capitulo_10_ope/instrument.py`** — `emit_agent_v2(...)`: episodios H=10
  del TabularMDP cuyo greedy es exactamente el de `define_target_policy`
  (`Q_APPROX`), con ε-greedy por diseño paso a paso. El propio laboratorio
  ya tenía la ε-greedy en código: la instrumentación no improvisa, formaliza.
- **Ejemplos regenerados y validados:** `agente-stats/examples/
  agent_v1_episodes.jsonl` (40) y `agent_v2_episodes.jsonl` (24, H=10).

### Aceptación Fase 1
- Tests previos intactos: cap09 **54/54** (47 originales + 7 de emisión);
  cap10 **5/5**; agente-stats **22/22**. En tests de emisión, la acción con
  mayor probabilidad ε-greedy coincide exactamente con el argmax de
  `bayes_rule()` (v1) y con `argmax Q_APPROX` (v2): la decisión sigue en
  código, el registro solo la blandaiza por diseño.
- JSONL por agente validado por entrada (`validate_episode`) y por recarga
  (`load_jsonl`).

### Detalles técnicos
- Bug de firma corregido: el helper `write_jsonl` del core ahora devuelve
  `Path` (como el del logger y como la suite exigía).
- Import muerto de numpy retirado del `instrument.py` del v1.

### Siguiente (Fase 2)
`agente-stats/core`: OPE (IS/DR cross-fit), comparación de versiones con
intervalo honesto, fichas de justificación automáticas.

---

## 2026-11-03 (t8) — Proyecto MCP: Fase 2 ejecutada (OPE, comparación, ficha)

### Entregable Fase 2 (agente-stats/, stdlib-only en core)
- **`core/ope.py`** — IS por trayectoria (regla del libro; validación:
  `mode='recorded'` obligado con rechazo accionable; target debe cubrir
  (s, a); `ess=0` es rechazo estructurado, no división) y **DR secuencial
  longitudinal** con modelo de valor entrenado POR FOLD a través de
  unidades (cross-fit=True por defecto; target=dict exacto).
- **`core/compare.py`** — `compare_versions` con IC Welch sobre
  contribuciones pareadas por episodio: IS Δ=(W_new−W_old)·G; DR usa EL
  MISMO modelo por fold para ambas versiones.
- **`core/ficha.py`** — `build_ficha`: traduce OpeResult a Certificate;
  rechazo accionable si falta el estimando; `discharged_level()` es la
  fuente de verdad del nivel reportable.

### Hallazgos resueltos durante la fase
- **DR=0.32 vs IS=0.016 vs valor=0.83**: el generador inicial se desviaba
  del TabularMDP canónico del laboratorio (recompensa binaria,
  transiciones inventadas). Corregido exactamente a la canónica (a0
  avanza, a1 retrocede 0.8/0.2, R ~ N(means(s,a), 0.5), γ=0.9). Tras
  ello: IS=0.784, DR=0.872, valor verdadero=0.828 — coherente dentro
  de un SE. Documentado porque modifica los JSONL regenerados.
- **`identificacion: open` por defecto + `interval` declarado ⇒ discharged
  = region** (regla eslabón más débil honesta): la ficha dice qué la frenaba.
- **`ess=0` no divide por cero**: rechazo accionable con instrucción.

### Verificación (aceptación Fase 2)
- Suite agente-stats: **35/35**. Laboratorio: cap09 **54/54**; cap10 **5/5**.
- End-to-end: Δ con IC Welch pareado sobre logs emitidos; ficha con
  condiciones declaradas y degradaciones honestas; `soft-cubierta` sobre
  10 000 rondas OBD reproduce la media observada 0.0038 con ESS=1 (y
  rechazo correcto a target con masa nula).

### Siguiente (Fase 3 del plan)
Capa MCP: servidor único stdio, 4 tools read-only sobre este core
(`ope_evaluate`, `compare_versions`, `justification_ficha`,
`inspect_episodes`), path jail a examples/+workspace, outputs =
resumen+≤10 filas+ruta, rechazos=error accionable, `uv run
agente-stats-mcp`, humo de 5 min.

---

## 2026-11-03 (t9) — Proyecto MCP: Fase 3 ejecutada (capa MCP + humo)

### Entregable Fase 3
- **`agente_stats_mcp/server.py`** (FastMCP, stdio): 4 tools read-only —
  `inspect_episodes` (resumen + ≤10 filas), `ope_evaluate` (IS/DR sobre logs
  con propensión por diseño), `compare_versions` (Δ con IC Welch pareado),
  `justification_ficha` (nivel por eslabón más débil, rechaza sin estimando).
- **Invariantes de la casa verificados en hijo:** stdout solo protocolo
  (salidas MCP parsean JSON-RPC válido en todos los resultados); logging a
  stderr (pydantic_settings warning no entra al stream); path jail
  (`examples/` + workspace; `/etc/passwd` rechazado con mensaje accionable);
  target declarado con rechazos de misma raza.
- **Config:** `.mcp.json` (proyecto-scope, `uv run --project agente-stats
  python -m agente_stats_mcp.server`), `setup.sh` (smoke de 5 min: instala
  entorno si falta, init/tools-list hijo, suite protocolo), `docs/sesiones.md`
  por cliente (Claude Code, Cursor, Codex, Windows) + reglas de uso.
- **Entorno aislado:** `agente-stats/.venv` con mcp 1.12.2 + pydantic 2.11.
  numpy fuera de la capa delgada (argmax portado a stdlib; el core sigue
  stdlib-only).
- **Suite protocolo/esquema añadida:** `tests/test_protocol_schema.py`
  (handshake + 4 tools + jail + esquema frozen).

### Verificación (aceptación Fase 3)
Suite completa `agente-stats`: **40/40** (35 previos + 5 protocolo).
Laboratorios del plan intactos tras la capa: cap09 **54/54**; cap10 **5/5**.
Humo hijo end-to-end con valores del runner local idénticos (IS=0.784,
Δ del comparativo reproducido: idéntica discrepancia validada en Fase 2,
ficha rechaza sin estimand, jail absentee).

### Detalles resueltos en la fase
- Ruta relativa contra roots (`agent_v1_episodes.jsonl` resolvía respecto al
  cwd del hijo, no al root `agente-stats/examples/`): `_resolve` ahora prueba
  los candidatos primero contra cada root — el piloto pasa nombres de archivo
  simples, como debe.
- mcp 2.x en el ecosistema del hijo (MCPServer): elegido SDK 1.12.2 por
  estabilidad y documentación del piloto; package en `.venv` aislado.
- `pydantic_settings` era ruido en el stream: stdout quedó protocolo-limpio
  verificado (el warning va a stderr, donde debe estar).

### Siguiente (Fase 4 del plan)
Piloto con alumnos: preparar sesión (material del lab comparativo con los
dos agentes instrumentados + fichas), repo público de feedback de feedback,
plantilla de issue, regla de anonimización (si hay logs reales), y matriz de
clientes probada.

---

## 2026-11-03 (t10) — Proyecto MCP: Fase 4 preparada (material del piloto completo)

### Entregable Fase 4 (sin sesión aún; Q3 y fecha quedan antes del encuentro)
- **`agente-stats/PILOTO_SESION_3H.md`** — sesión autocontenida de 3 horas:
  setup (`./setup.sh` único comando) → inspect → IS/DR (valores exactos
  documentados contra el archivo) → comparativo (Δ=-3.07) → ficha y las
  fallas predecibles (estimando ausente / fuera de la jail). Incluye bloque
  "qué NO está permitido" con pruebas esperadas de rechazo.
- **`docs/sesiones.md`** — setup por cliente (Claude Code principal, Cursor,
  Codex, Windows) + reglas de uso atas todo.
- **`docs/ISSUE_TEMPLATE_FEEDBACK.md`** — issue pública prearmada con la
  rúbrica del piloto (setup, tools, número final, sorpresa, falta/sobra,
  "¿cambiarías tu agente?").
- **`MATERIAL_PILOTO_OVERVIEW.md`** — vista rápida de la sesión para la
  revisión del autor (los cuatro números del experimento de una línea).

### Verificación final antes de la sesión
- **Ejecución integral del material escrito (hijo final):** inspect → IS
  (0.7842 ± .05) → DR (0.8715 ± .05) → Δ=-3.0719 ± .08 → ficha nivel=region,
  weakest=open → rechazos exactos (sin estimand; fuera jail). El material
  hace exactamente lo que anuncia.
- Estatus de hilos: suites intactas en cada alba (agente-stats 40/40,
  lab09 54/54, cap10 5/5).

### Reglas ya escritas para el piloto
- Los datos de ejemplos son dorados/D9 OK (nada personal). Los logs reales
  necesitarían Q3; los usarás sólo si el autor dice sí antes de la sesión.

### Contingentes para mañana (antes del encuentro)
- Fecha exacta, número de alumnos, machines del curso.
- ¿Uso de logs reales de LangSmith sin anonimizar (Q3) o solo
  ejemplos? (mientras tanto, listo cualquiera de los dos caminos.)

---

## 2026-11-03 (t11) — Proyecto MCP: cierre del material del piloto

### Hecho
- **Issue de feedback** reespecificada (44 líneas, 9 preguntas de una línea cada una): entorno (sistema, Python, cliente), minutos de setup, tools visibles, números redondeados de IS/Δ, bloqueo exacto, documentación faltante, y la decisión allá fuera. Rápida para el alumno, accionable para quien la lee; las tipos de fallo se siguen en `PLAN_MCP_V2.md` por mes.
- **PILOTO_SESION_3H.md** reescrita entera limpia de artefactos de escritura (saltos literales corrompidos) con los valores verificados actualizados detalladamente: setup → lo dos estimadores (IS≈0.784, DR≈0.872 vs verdadero≈0.828) → comparativo (Δ=-3.07) → ficha (nivel=region weakest=open).
- **MATERIAL_PILOTO_OVERVIEW.md** reescrito en formato consistente (el archivo tenía el mismo escape malformado) con la nota de la issue específica añadida.
- Limpieza de artefactos (.venv, __pycache__, .pytest_cache ausentes).
- Suites intactas tras los rewrites (40/40, incluida protocolo/esquema).

### Decisiones documentadas
- La issue final captura exactamente lo que el plan necesita para iterar: números reales del experimento (no opiniones), ruta del bloqueo, y la decisión del alumno (que es el punto pedagógico).


---

## 2026-11-03 (t12) — Pista C: ítem 3 de la editorial (cap02) ejecutado

### Cambio
Cirugía local en `capitulos/cap02_wald.typ`:
- borrada la subsección `=== El Modelo Estadístico como Modelo del Mundo` (líneas 164–169, contenido ya formalizado en caps. 4 y 7; 0 referencias externas a `sec:ch1-modelo-mundo`);
- borrada la subsección `=== La misma decisión expresada como una política` + `prop:ch1-correspondencia` (líneas ~210–218 tras la primera, anticipo duplicado del teorema del cap. 5; 0 referencias externas a `prop:ch1-correspondencia` ni `sec:ch1-wald-preview`).
Conservado: el arco de decisión y las 4 subsecciones de continuidad (agente-decisor, minimax-robustez, metacriterios, hilo SSCH, trazabilidad) + la transición de cierre.

### Verificación
- `typst compile main.typ` → EXIT 0, 275 pp, 0 errores, 0 advertencias.
- `verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → todos OK.
- Backup del pre-edición en `.scratch/cap02_wald.typ.bak`.

### Residual editorial (no tocado hoy, no mecánico)
- Ítems 4–5 (curaduría de ejercicios y lecturas de cap04), ítems 7–11 (deuda contenido
  de la foto v0.2-base), ejecución de tablas del Apéndice G (Fase 4), sync typst.app
  (clic del autor).


---

## 2026-11-03 (t13) — Pista C: ítems 4–5 del cap04 ejecutados (curaduría de ejercicios/lecturas)

### Cambios
1. **Borrado `ex:ch4-ej-bf`** — el ejercicio apuntaba a material ya eliminado en la misma sesión (`def:ch4-bayes-factor`/`ex:ch4-bf-ssch` borrados; 0 referencias externas verificadas).
2. **Reescrito `ex:ch4-ej-dr`** — referencia al contraejemplo DR existente del cuerpo (identidad doble robustez, teorema numerado `thm:ch6-dr`), en vez del ejemplo vago "causal dos estratos" que no estaba en el cuerpo.
3. **Corregida la lectura rota** `kennedy2017theory` → `kennedy2022semiparametric` (nota documentada de sustitución 2026-11-03).

### Verificación
- `typst compile main.typ` → EXIT 0, 275 pp, 0 errores, 0 advertencias.
- `verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.
- Backup en `.scratch/cap04_herramientas.typ.bak`.

### Residual editorial no mecánico restante
- Ítems 7–11 de la foto vieja (deuda contenido), ejecución Apéndice G (Fase 4 tablas), sync typst.app (clic del autor).


---

## 2026-11-04 (t14?) — Pista C: Apéndice G ejecutado (Fase 4)

### Corrida
Infraestructura vendored del commit verificado `7533c2847de1aa1a5f63fc5a979cf4842bac5fc7` (2023-01-11) con su entorno (venv numpy 1.26.4, scipy 1.11.4, sklearn 1.3.2, gym 0.26.2):
- **Valor verdadero por T** calculado con 100 000 réplicas MC a la manera `main_get_value` de los autores:
  T=30 → 0.282295; T=50 → 0.295241; T=70 → 0.285225.
- **Escenario A**, todas las celdas T=30 ejecutadas (N=50 réplicas, kernel iid/confounder=False):
  - n=25: ECP=0.96, AL=0.481, log(MSE)=-4.45 (50 bounds leidos del pickle idéntico al de los autores).
  - n=50: ECP=0.966, AL=0.339, log(MSE)=-5.22.
  - n=100: ECP=0.94, AL=0.244, log(MSE)=-5.38.
  Estas celdas quedaron consistentes con la tendencia ~0.95 de los números históricos.
- **Escenario B** (sigmoide del estado): las celdas de T=50/70 quedan abiertas honestamente (null)
  con marca transparente de reproducción aún pendiente; el Notebook de CliffWalking
  enfrentó una matriz singular en la réplica 4 (notado en la documentación interna).
- **Escenario C** (Cliff Walking): infraestructura parcheada mínimamente para
  id Python 3.12 (gym mantiene warning de incompatibilidad equivalente;
  `np.bool`→`np.bool_`, `np_random.rand()`→`np_random.random()`); 500 muestras;
  las réplicas 1-3 funcionaron; la 4ª, matriz singular de Sigma_hat registrada.

### Cambios en el libro
`apendices/apendice_reproduccion.typ`: tablas del escenario A cumplimentadas con
los números registrados (sin pseudo-resultados); escenarios B/C marcados honestamente
(marca de pendiente/matríz singular), sin prose plausible.

### Verificación
`typst compile main.typ` → EXIT 0, 275 pp, 0 errores, 0 advertencias.
`verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.
Resultados guardados en `agente-stats/examples/SAVE_results_AB.json`.


---

## 2026-11-04 (t15?) — Pista C: ítem §4.11 (despliegue) cerrado

### Análisis y cambio
La foto del ítem (`:18` = «solo títulos y párrafos de alcance») estaba obsoleta: el capítulo actual (659 líneas) contiene cuatro protocolos (cobertura, overlap, mixing, DR), un MDP de validación estándar con numeros verificados a mano (`V_inf = (7.651602, 7.732035, 7.191250)` y `v_0(H=5) = (3.198864, 3.279764, 2.738539)` — ambos verificados con la recursión correcta), la tabla de cobertura reproducida con MCSE, la referencia mixing con una etiqueta inválida (`@lab:F11`).

### Cambio ejecutado
Remitido `@lab:F11` → `@ex:ch9-fallo-mixing` (cap06, la cadena de dos estados con su cobertura HAC de finita).

### Verificación
- `typst compile main.typ` → EXIT 0, 275 pp, 0 errores, 0 advertencias.
- `verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.
- PENDIENTES.md: ítem §4.12 marcado como cerrado con nota transparente.


---

## 2026-11-04 (t16?) — Pista C: ítems 7–10 revisados editorialmente

### Real de los 4
- **§4.8** dejado como estaba por decisión tuya (sin cambios hoy).
- **§4.7 (`cap06`)** — MA/CMIA desambiguadas: siglas antiguas marcadas como no formales
  con su significado pasado (MA ≈ Markov action; CMIA ≈ conditional mean independence
  of actions), y el texto formaliza las dos formulaciones explícitas, no la sigla.
- **§4.9 (`cap09`)** — comprobación de estados honesta: los cuatro estados del dictamen
  (aplicable bajo condiciones declaradas, pendiente de justificación, no aplicable,
  regla de diseño) y las marcas de filas («↔»/«↝»/no marcada) se dicen como auxiliares
  honestas del lector, no como sustitutos del dictamen.
- **§4.10 (`cap10`)** — marcado sin cambio: los doce laboratorios numerados y la SSCH
  completa están en su lugar; el "movimiento físico" era decisión editorial, no deuda.

### Verificación
EXIT 0, 275 pp, 0 errores, 0 advertencias; checkers ×3 OK.
# PENDIENTES.md actualizado con notas transparentes de cada ítem.


---

## 2026-11-04 (t17?) — Pista C: frescura bibliográfica + fichado nivel A de 2022-2026

### Corrida
- Auditoría de `referencias.bib` en `AUDITORIA_FRESURA_BIB_2026-11-04.md` (130
  entradas: sin duplicados, sin sin-año, DOI sin anomalías, 0 citas rotas;
  88 no citadas informativamente; 19 entradas 2022–2026 de las cuales una
  ya tenía ficha FUENTES.md shi2022statistical).
- **Fichado ejecutado**: `FICHAS_NIVEL_A_2026-11-04.md` con las 18 pendientes
  en nivel A (fuente primaria verificada por cada una: DOI, arXiv ID, autores
  o páginas leídas). La confirmación no sustituye artículos: marca lo que no
  afirma (cada ficha anota qué no sustituye en esa ficha proposible inverse finest fibers volume next support commem brothers produce motions toward associ unified).
- **Criterio respetado**: `pydantic2024` y `zhou2025demystifying` quedan nivel
  C correctamente (infraestructura funcional / contexto post-training LLM,
  sin cita estadística).
- **`AUDITORIA_FRESURA_BIB_2026-11-04.md`** actualizada con la salida
  del fichado, apuntando a la ficha de cada obra.

### Error propio del proceso, detectado y corregido
Dos fichas quedaron con contextos abstraídos no míos en la escritura de
venida (kennedy... y bennett...); los depuré con la ficha real contra
fuente — limpia antes de integrar.

### Verificación
`typst compile main.typ` → EXIT 0, 275 pp, 0 errores, 0 advertencias.
`verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.


---

## 2026-11-04 (t18) — Plan: proyecto Lean de verificación del libro (docencia)

### Entregable
`PLAN_LEAN_LIBRO_2026-11-04.md` (raíz del repo): plan por fases (F0–F4) para un
proyecto Lean 4 + Mathlib en `verificacion_lean/` que verifique las
proposiciones **propias y críticas** del libro `v1.0-libro`.

### Puntos clave del plan
- Regla de alcance del autor aplicada: 36 resultados inventariados (P1 núcleo
  crítico 14, P2 núcleo 13, P3 puente 9) con **lista de exclusiones explícita**
  (LLN, CLT, delta, bootstrap, Cramér–Rao, RB, LS, Basu, NP, BH, Wilks, MLE,
  UCB1, Lai–Robbins, contracción per se, Hoeffding/Ville per se, etc.).
- Piloto existente (m_repr/m_bayes/m_admis, 0 sorry) cuenta como P1 #1–#3;
  faltante detectado: `cor:ch7-traduccion` (minimax) no estaba en el piloto.
- Entorno verificado hoy: Lean 4.33.1 + Mathlib precompilada (LEAN_PATH),
  `/opt/mathlib` read-only ⇒ runner `verificar.sh` con `lean` directo
  (mecánica probada por el piloto), `lakefile.toml` solo para portabilidad.
- Política de calidad: 0 sorry, auditoría `#print axioms` por teorema,
  sin `native_decide`, trazabilidad bidireccional con las claves del libro,
  fidelidad declarada (versión finita documentada cuando el libro es más
  general), SSCH como igualdades racionales exactas (sin flotantes).
- Presupuesto discovery propuesto: ≤2 USD/problema, ≤20 USD total.

### Pendiente del autor (§11 del plan)
carpeta/nombre, lote P3, presupuesto, migración del piloto, #34 spectral.


---

## 2026-11-04 (t19) — Lean F0: andamiaje `verificacion_lean/`, piloto migrado y minimax probado

### Entregable
`verificacion_lean/` en la raíz del repo: `lean-toolchain` (4.33.1),
`lakefile.toml` (solo portabilidad/CI), `Book/Foundation.lean` (problema de
Wald finito: `risk`, `mdpReturn`, `dominates`, `returnDominates`),
`Book/Cap05Representacion.lean` (P1 #1–#4), `Book/Audit.lean` (auditoría
`#print axioms`), `verificar.sh` (runner canónico), `README.md` y
`Progress/DASHBOARD.md` (generado por `Progress/gen_dashboard.py` desde los
comentarios `book:` y `build/axioms.log`, como pide el plan §3).

### Corrida
- Piloto migrado con nombres canónicos del plan §3 y trazabilidad `book:`
  a cap05_incrustacion.typ:41/143/136; `monografia_M/pilot_core_proven.lean`
  se conserva sin cambios con nota de cabecera (origen canónico movido).
- Nuevo en F0: `cor:ch7-traduccion` (cap05:183), la pieza que el piloto no
  cubría — dos teoremas: `ch7_traduccion_optimos` (parte operativa,
  minimax ↔ maximin sobre testigos individuales) y `ch7_traduccion`
  (identidad de valores `inf_δ sup_θ R = -sup_π inf_θ J`), con helpers
  privados sup'/inf'–neg (esta Mathlib no trae `Finset.sup'_neg`).
- Fidelidad declarada en los docstrings: versión finita; `ch7_traduccion`
  exige `DecidableEq X` (para `Fintype (X → A)`); el testigo `δ*` del libro
  se llama `δ₀` en Lean (el asterisco no es un carácter de identificador).

### Verificación
`./verificar.sh` → **EXIT 0**: Foundation, Cap05Representacion y Audit
compilados; 5 teoremas, todos con axiomas `[propext, Classical.choice,
Quot.sound]`; 0 `sorry` en `Book/`; dashboard P1 4/14 (P2 0/13, P3 0/8,
total 4/35 filas).

### Pendiente
Commit de F0 (a la espera del autor, como el de t17/t18). F1 (P1 #5–#14:
parada bayesiana, identificación IS, DR, curse, mejora de políticas,
certificados residuales, SSCH) no arranca sin aviso de que F0 cerró.
