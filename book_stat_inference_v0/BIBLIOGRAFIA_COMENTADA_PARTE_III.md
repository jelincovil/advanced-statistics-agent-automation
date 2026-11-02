# Bibliografía comentada — Parte III

**Fecha:** 2026-09-29 · **Alcance:** Parte III = caps. **7–9** (`main.typ`: divisor «Parte III» → `cap07_ope.typ`, `cap08_intervalos.typ`, `cap09_verificacion.typ`).  
**Regla:** solo obras que aparecen en el manuscrito (listas «Lecturas Propuestas» / `#cite` / claves en `referencias.bib` citadas ahí). No se inventan títulos ni años.  
**Uso:** insumo para consolidar lecturas; **no** es prosa de contribución del capítulo.  
**Estilo:** imita `BIBLIOGRAFIA_COMENTADA_PARTE_II.md`.

---

## Cap. 7 — OPE (`cap07_ope.typ`)

| Obra (clave `.bib`) | Utilidad para el arco |
|---|---|
| **Jiang & Li (2016)** `jiang2016doubly` | Lectura obligatoria: DR para evaluación off-policy del valor en RL (ICML). Ancla el estimador DR del capítulo frente a DM/IS. |
| **Dudík, Langford & Li (2011)** `dudik2011doubly` | Lectura obligatoria + epígrafe: DR para evaluación/aprendizaje de políticas (ICML). Puente contextual-bandit → OPE del libro. |
| **Thomas, Theocharous & Ghavamzadeh (2015)** `thomas2015high` | Lectura obligatoria: OPE con alta confianza (AAAI); anticipa garantías finitas antes del arco de IC del cap. 8. |
| **Liu et al. (2018)** `liu2018breaking` | Lectura complementaria: romper el *curse-of-horizon* (NeurIPS); dialoga con `@thm:ch10-curse` / IS truncado. |
| **Kallus & Uehara (2022)** `kallus2022efficiently` | Lectura complementaria: eficiencia / curse-of-horizon (*Operations Research*); puente a semiparamétrica e IC. |
| **Duchi & Namkoong (2021)** `duchi2021learning` | Cuerpo (DRO bajo distributional shift). |
| **Gretton et al. (2012)** `gretton2012kernel` / `gretton2012` | Cuerpo + ejemplo shift: MMD para detectar cambio de distribución. *(Dos claves en `.bib` apuntan al mismo hilo MMD; no fusionar hoy.)* |
| **Sugiyama & Kawanabe (2012)** `sugiyama2012machine` | Cuerpo: monografía de shift; contexto del ejemplo SSCH post-pandemia. |
| **Sugiyama et al. (2008)** `sugiyama2008` | Cuerpo (KLIEP) en el ejemplo de covariate shift. |
| **Quionero-Candela et al. (2009)** `quinonero2009dataset` | Cuerpo: dataset shift (antología). |

**Notas cap. 7.** Lista tipográfica «Lecturas Obligatorias/Complementarias» presente. El bloque «OPE bajo Distributional Shift» vive *dentro* de «Lecturas Propuestas» (deuda de integridad ya anotada en el `.typ`); no se reordenó hoy.

### Enriquecimiento API (2–4 obras centrales) — 2026-09-29

Solo IDs devueltos por OpenAlex / Semantic Scholar; no se añadió nada al `.bib`.

| Clave | OpenAlex | Semantic Scholar | DOI / arXiv verificable |
|---|---|---|---|
| `jiang2016doubly` | **W2234859443** (preprint year OA 2015; venue ICML en S2) | **2fdb536da39a014c598ea67b0db88431fcd852a8** (cit. S2 ≈753) | arXiv **1511.03722** · DBLP `conf/icml/JiangL16` |
| `dudik2011doubly` | **W1809653203** | **5ccf7658018981bf492d0c8d66277d22ebaac815** (cit. S2 ≈846) | arXiv **1103.4601** · *(el DOI del `.bib` `10.1145/3106426.3106468` no se revalidó hoy; no se corrige a ciegas)* |
| `thomas2015high` | **W2273088453** | **a8bbcf5ea723b1f9b7d2257dd6fd492cd280f0af** (cit. S2 ≈331) | DOI **10.1609/aaai.v29i1.9541** |

---

## Cap. 8 — Intervalos / inferencia (`cap08_intervalos.typ`)

| Obra (clave `.bib`) | Utilidad para el arco |
|---|---|
| **Shi, Zhang, Lu & Song (2022)** `shi2022statistical` | Lectura obligatoria + prosa de apertura: IC para la función de valor en horizonte infinito (JRSS-B); teorema central del capítulo (`@thm:ch11-shi`). |
| **Kallus & Uehara (2020)** `kallus2020double` | Lectura obligatoria: Double RL / OPE eficiente (JMLR); conecta DR del cap. 7 con validez inferencial. |
| **Kallus & Uehara (2022)** `kallus2022efficiently` | Lectura obligatoria (también en cap. 7): eficiencia y horizonte. |
| **Newey & West (1987)** `newey1987hac` | Lectura complementaria: HAC; sostiene `@def:ch11-hac`. |
| **Bradley (2005)** `bradley2005basic` | Lectura complementaria: condiciones de *strong mixing*. |
| **Mnih et al. (2016)** `mnih2016asynchronous` | Cuerpo (A3C / varianza en PG). |
| **Schulman et al. (2017)** `schulman2017proximal` | Cuerpo (PPO; estabilidad). |
| **Levine et al. (2020)** `levine2020offline` | Cuerpo: survey offline RL enlazado al `@ch:ope`. |
| **Villar, Bowden & Wason (2015)** `villar2015multi` | Cuerpo: multi-armed bandits en ensayos clínicos (contexto SSCH). |
| **Rodbard (2009)** `rodbard2009interpretation` | Cuerpo: interpretación CGM; citado junto al ejemplo sintético (no es dato de Shi). |

**Notas cap. 8.** Lista de lecturas tipográfica presente. El capítulo concentra el peso teórico de Parte III (Shi + mixing + SAVE).

### Enriquecimiento API — Shi 2022

| Clave | OpenAlex | Semantic Scholar | DOI |
|---|---|---|---|
| `shi2022statistical` | **W4200424214** (OA year 2021 / advance; bib year 2022) | **bcc378385c8d5a1d4cd5b78bce17879b1405f89c** (cit. S2 ≈104; arXiv 2001.04515) | **10.1111/rssb.12465** (coincide con `.bib`) |

---

## Cap. 9 — Verificación de garantías (`cap09_verificacion.typ`)

| Obra | Utilidad para el arco |
|---|---|
| _(sin lista «Lecturas Propuestas» y sin `#cite(<…>)` externos)_ | El archivo reúne tablas de trazabilidad y prosa de nodos/SSCH con remisiones internas (`@thm:…`, `@ch:…`). **Barrido 2026-09-29:** cero `#cite` a obras externas. |

**Notas cap. 9.** Asimetría fuerte: la bibliografía comentada de Parte III vive en caps. 7–8. El cap. 9 es (aún) un depósito de tablas + `#pendiente` de consolidación; las lecturas de verificación, si el autor las quiere, habrán de curarse cuando exista el andamiaje expositivo (Fase 3 / plan Semana 2).

---

## Asimetrías documentadas

1. **Cap. 9 sin lecturas / sin `#cite` externos** — fiel al manuscrito actual, no un olvido de fichas.
2. **Parte III ≠ caps. antiguos 10–11 solo:** en `main.typ` la Parte III son caps. **7–9** (OPE, intervalos, verificación). Las keys internas `sec:ch10-*` / `sec:ch11-*` dentro de `cap07`/`cap08` son reliquias de numeración pre-Fase-2.
3. **Claves MMD duplicadas** (`gretton2012` vs `gretton2012kernel`): ambas citadas en cap. 7; no se unifican hoy.
4. **DOI dudoso en `dudik2011doubly`:** OA/S2 apuntan a arXiv 1103.4601; el DOI ACM del `.bib` queda como deuda de integridad (no corregido sin OK autor / verificación Crossref explícita).
5. No se añadió ninguna entrada nueva a `.bib` en esta sesión.

---

## Notas de curación (para el autor)

1. Parte III **no** incluye caps. 10–12 (Parte IV).
2. Próximo paso planificado: bibliografía comentada Parte IV (Mié 30).
3. Si se desea lista de lecturas en cap. 9, partir de las obras ya ancla de 7–8 (Shi, Jiang–Li, Dudík, Thomas) más el protocolo de verificación — decisión **A**, no prosa del agente.
