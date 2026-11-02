# Literatura 2022–2026 — fichas

Registro de fichas para *Agentes Estadísticos con Garantías*.  
Protocolo: nada entra al `.bib` sin abstract + hipótesis leídos; no se inventan citas ni DOIs.

---

## Shi, Zhu, Shen, Luo, Zhu & Song (2024) — JASA

| Campo | Valor |
|---|---|
| **Cita** | Shi, C., Zhu, J., Shen, Y., Luo, S., Zhu, H., & Song, R. (2024). Off-Policy Confidence Interval Estimation with Confounded Markov Decision Process. *Journal of the American Statistical Association*, *119*(545), 273–284. |
| **DOI** | [10.1080/01621459.2022.2110878](https://doi.org/10.1080/01621459.2022.2110878) |
| **arXiv** | [2202.10589](https://arxiv.org/abs/2202.10589) |
| **Código** | https://github.com/Mamba413/cope |
| **Fuentes de ficha** | Semantic Scholar (DOI lookup); abstract arXiv/JASA. Fecha de ficha: 2026-09-22. |

### Qué problema trata
Construir un **intervalo de confianza offline** para el valor de una política objetivo a partir de datos observacionales en horizonte infinito, cuando el MDP está **confundido** (hay variables no medidas que confunden las acciones observadas).

### Qué supuesto sustituye al “no-confounding”
En lugar de asumir **ausencia de confounders no medidos** (no unmeasured confounding), asumen la existencia de **variables auxiliares que median** el efecto de las acciones sobre la dinámica del sistema. Con esos mediadores, el valor de la política objetivo es **identificable** en un MDP confundido.

### Qué garantiza
- Estimador off-policy del valor de la política, eficiente y **robusto a posible mala especificación** del modelo.
- **Cuantificación de incertidumbre** rigurosa: intervalos de confianza para el valor de la política en ese régimen confundido.
- Justificación teórica + evidencia en simulaciones y datos reales de ridesharing.

### Qué exige
1. Datos observacionales pre-recolectados (evaluación off-policy / offline).
2. Variables auxiliares **mediadoras** acción → dinámica (no basta con “cualquier proxy”).
3. Marco de MDP confundido en horizonte infinito.
4. Condiciones técnicas del estimador/IC (según el artículo; no se inventan aquí sin leer el cuerpo completo).

### Encaje en el libro
- Catálogo de garantías / IC off-policy bajo violación de no-confounding.
- Relevante para **cap. 6 L4 (confounding)**, **cap. 12** (frontera *confounding no observado* / agenda `tab:ch12-agenda`) y para la tabla canónica del **cap. 9** (auditar condiciones).
- Comparar más adelante con SAVE / NSAVE y con métodos conformes (semana 1 del plan).

### Estado
- [x] Abstract + claim central leídos (fuentes arriba).
- [ ] Cuerpo completo (hipótesis formales, teoremas de IC) — pendiente antes de afirmar tasas/cobertura en el texto del libro.
- [ ] Entrada `.bib` — crear solo tras esa lectura.

---

## Wei (2025) — NSAVE / arXiv:2505.13809

| Campo | Valor |
|---|---|
| **Cita** | Wei, H. (2025). Semiparametric Off-Policy Inference for Optimal Policy Values under Possible Non-Uniqueness. arXiv:2505.13809. |
| **DOI (preprint)** | [10.48550/arxiv.2505.13809](https://doi.org/10.48550/arxiv.2505.13809) |
| **arXiv** | [2505.13809](https://arxiv.org/abs/2505.13809) |
| **OpenAlex** | [W4415020600](https://openalex.org/W4415020600) (citas: 0; type: preprint) |
| **Semantic Scholar** | [8e17d10c63aa4548999e951fc0e4bf63bfa3ef9d](https://www.semanticscholar.org/paper/8e17d10c63aa4548999e951fc0e4bf63bfa3ef9d) (citas: 0) |
| **Código** | No verificado en el PDF (2026-09-23). |
| **Fuentes de ficha** | Semantic Scholar + OpenAlex (API key) + PDF arXiv. Fecha: 2026-09-23. |

### Qué problema trata
Inferencia off-policy para el **valor de políticas óptimas** en MDPs cuando la óptima puede ser **no única** o casi determinista; propone **NSAVE** (Nonparametric SequentiAl Value Evaluation) con inferencia basada en martingalas.

### Qué garantiza (según abstract + Thm 5.1/5.6 leídos)
- Caracterización de EIF / no-regularidad cuando óptimas competidoras tienen gradientes de primer orden distintos.
- Cota de eficiencia semiparamétrica y estimador ponderado uniforme bajo óptimo único.
- NSAVE: estabilidad bajo no-unicidad; **doble robustez** si nuisances alineadas con la política de evaluación (Thm 5.6).
- Aproximación por suavizado y plantilla post-selección con cobertura uniforme bajo su condición de calibración conjunta (claim del paper; no trasladada al texto del libro).

### Qué exige (hipótesis leídas; lista no exhaustiva de tasas)
A.1–A.3 (muestreo i.i.d. de episodios, Markov, estacionariedad); A.4–A.6 (regularidad auxiliar / unicidad / empates distinguibles según resultado); A.7–A.11 para normalidad martingala de NSAVE (Thm 5.1). Condiciones adicionales A.12+ para resultados de suavizado.

### Encaje en el libro
Contraste directo con **SAVE** (`def:ch11-save`, cap. 8). Ver `COMPARE_SAVE_NSAVE.md`.

### Estado
- [x] Abstract + hipótesis A.1–A.11 leídos en PDF.
- [ ] Pruebas completas / tasas numéricas — no afirmar en prosa del manuscrito aún.
- [ ] Entrada `.bib` — diferida (misma política que ficha Shi JASA).

---


## Luo, Fan & Wu (2025) — NeurIPS 2025

| Campo | Valor |
|---|---|
| **Cita** | Luo, T., Fan, X., & Wu, W. (2025). Simultaneous Statistical Inference for Off-Policy Evaluation in Reinforcement Learning. *Advances in Neural Information Processing Systems 38* (NeurIPS 2025), 78425–78459. |
| **DOI** | [10.52202/085713-2367](https://doi.org/10.52202/085713-2367) |
| **arXiv** | No localizado (2026-09-24); no inventar. PDF vía OpenReview (login/HTML gate en fetch automático). |
| **OpenAlex** | [W7196936303](https://openalex.org/W7196936303) (type: conference-paper; venue: NeurIPS 38) |
| **Semantic Scholar** | [582d13421439bfc04ccb3b0410d5f879168c964d](https://www.semanticscholar.org/paper/582d13421439bfc04ccb3b0410d5f879168c964d) (citas: 1; CorpusId 289333402; DBLP conf/nips/LuoFW25) |
| **OpenReview** | https://openreview.net/forum?id=BM1GqmkEHS (poster NeurIPS 2025; CC BY 4.0) |
| **Autores (OpenAlex)** | Tianpai Luo, Xinyuan Fan, Weichi Wu *(S2 romaniza Tian-Zhao Luo / Xinyu Fan; misma obra)* |
| **Código** | No verificado (2026-09-24). |
| **Fuentes de ficha** | Semantic Scholar (DOI) + OpenAlex (W7196936303) + abstract OpenReview/S2. Fecha: 2026-09-24. |

### Qué problema trata
Construir el **primer marco de inferencia simultánea** teóricamente justificado para **OPE**: regiones de confianza simultáneas (SCRs) sobre un espacio de estados iniciales infinito/continuo, frente a estimaciones puntuales o IC *punto a punto*.

### Qué garantiza (según abstract; sin cuerpo/hipótesis formales leídos)
- SCRs **asintóticamente correctas** sobre todo el espacio de estados.
- Estimación de $Q$ por **sieves** + aproximación gaussiana (alta dimensión) sobre regiones convexas.
- Algoritmo de **bootstrap multiplicador** para construir las SCRs.
- Anchos de SCR que exceden los IC puntuales solo por un **factor logarítmico** (casi óptimo en eficiencia, claim del paper).
- Demostración empírica en simulaciones y en el dataset **OhioT1DM**.

### Qué exige
CONDICIONES SIN ESPECIFICAR a nivel de hipótesis formales (A1…): ficha a nivel abstract; PDF libre no extraído en esta sesión. Pendiente antes de afirmar tasas/cobertura en el manuscrito.

### OhioT1DM
El abstract **declara** análisis del dataset OhioT1DM (además de simulaciones). No se verificaron aquí n.º de pacientes ni protocolo frente a Marling & Bunescu (2018) — no inventar; contrastar si se integra al cap. 8/10.

### Encaje en el libro
- Catálogo de **IC / OPE** y garantías simultáneas (vs IC punto a punto de SZLS/SAVE).
- Caps. **7–8** (OPE / intervalos) y **9** (auditoría de condiciones); contraste con sieves en SZLS.
- Dato empírico OhioT1DM: enlaza con menciones ya existentes (cap. 8, Ap. G / FUENTES).

### Estado
- [x] Abstract leído (S2 + OpenReview).
- [ ] Cuerpo + hipótesis formales — pendiente (PDF OpenReview no bajó como PDF en box; sin arXiv).
- [ ] Entrada `.bib` — diferida (misma política que Shi/NSAVE).

---


## Shi (2025) — Survey inferencia estadística en RL / arXiv:2502.16195

| Campo | Valor |
|---|---|
| **Cita** | Shi, C. (2025). Statistical Inference in Reinforcement Learning: A Selective Survey. arXiv:2502.16195v2 [stat.ML] (17 Apr 2025). Festschrift en honor a Michael Kosorok (submitted). |
| **DOI (preprint)** | [10.48550/arXiv.2502.16195](https://doi.org/10.48550/arXiv.2502.16195) |
| **arXiv** | [2502.16195](https://arxiv.org/abs/2502.16195) · PDF: https://arxiv.org/pdf/2502.16195 |
| **OpenAlex** | [W4414838671](https://openalex.org/W4414838671) (type: preprint; cited_by_count API: 0 al fichar) |
| **Semantic Scholar** | [f811e4b147239dee1d5d914766dae44a78222e58](https://www.semanticscholar.org/paper/f811e4b147239dee1d5d914766dae44a78222e58) (citas S2: 5; CorpusId 276575301; DBLP journals/corr/abs-2502-16195) |
| **Autor** | Chengchun Shi (LSE) |
| **Código** | No aplica (survey). Curso relacionado mencionado: https://github.com/callmespring/RL-short-course |
| **Fuentes de ficha** | S2 + OpenAlex + PDF arXiv (abstract + §1–2 + §5 Table 4.2 + §6). Fecha: 2026-09-25. |

### Qué problema trata
Revisión **selectiva** de herramientas de **inferencia estadística en RL**: (i) tests de hipótesis (énfasis en el supuesto de Markov / independencia condicional) y (ii) **construcción de intervalos de confianza off-policy** para el retorno esperado $J(\pi)$ de una política objetivo a partir de datos offline.

### Taxonomía de métodos de IC (Table 4.2 del survey, leída en PDF)
Filas = *cómo* se construye el IC; columnas = *qué* estimador puntual de $J(\pi)$:

| Construcción IC \\ Estimador | Model-based | Direct method | Importance sampling | Doubly robust |
|---|---|---|---|---|
| **Concentration inequalities** | — | Feng et al. 2020 | Thomas et al. 2015 | Thomas & Brunskill 2016; Jiang & Li 2016; Zhou et al. 2023a |
| **Normal approximation** | — | Luckett et al. 2020; Liao et al. 2021; Shi et al. 2022 | Wang et al. 2023a | Shi et al. 2021a; Liao et al. 2022; Kallus & Uehara 2022; Thomas & Brunskill 2016 |
| **Bootstrap** | Hanna et al. 2017 | Hao et al. 2021 | — | Hanna et al. 2017 |
| **Empirical likelihood** | — | — | Dai et al. 2020 (CoinDICE) | — |

Notas del survey (no trasladar como teoremas del libro): DR + tasas nuisance $o_p(N^{-1/4})$ → equivalencia martingala → IC Wald; si las tasas fallan, IF de orden alto (Shi et al. 2021a). Casi todos asumen $\pi$ **conocida**; si $\pi=\pi^*$ estimada y no única: m-out-of-n bootstrap, online one-step, subagging.

### Otros temas del survey (fuera de Table 4.2)
- §4: tests del supuesto de Markov (y CI condicional / series temporales).
- §6: tests de **estacionariedad** / change-point; **A/B testing** con efectos a largo plazo vía RL; inferencia en **bandits** con datos adaptativos.

### Encaje en el libro (catálogo $isoto$ / $arrow.squiggly$ ≡ ↔ / ↝)
El catálogo del libro (`tab:isomorfismo-completo` en cap. 5; convención en `PENDIENTES.md`) marca correspondencias Wald↔MDP con $isoto$ (exacto en alcance demostrado) y $arrow.squiggly$ (transferencia condicional). Filas de inferencia ya en el catálogo: IF→FIE/DR ($arrow.squiggly$), Neyman ($arrow.squiggly$), CLT mixing ($arrow.squiggly$), SZLS/SAVE (---). Cap. 7–8 desarrollan DM / IS / DR / SAVE y IC asintóticos; cap. 4 el bootstrap clásico.

### Estado
- [x] Abstract leído (S2 + PDF).
- [x] Taxonomía §5 / Table 4.2 leída en PDF (no solo título).
- [ ] Hipótesis formales de cada celda de la tabla — no afirmar tasas/cobertura en prosa del manuscrito.
- [ ] Entrada `.bib` — diferida (política: ficha hoy; .bib solo tras abstract+hipótesis *y* pedido del plan; T1 pide ficha).

---

## Matriz Extra 2026-09-25 — survey Table 4.2 ↔ catálogo / cobertura del libro

Convención libro: `$isoto$` = ↔ (exacto en alcance); `$arrow.squiggly$` = ↝ (condicional); `---` = sin correspondencia formal en la tabla canónica.

| Celda survey (fila × columna) | ¿Cubierto en el libro? | Dónde / símbolo | Hueco explícito |
|---|---|---|---|
| Normal approx × DR | **Sí (núcleo)** | Cap. 7–8 DR + SZLS/SAVE; catálogo: IF/Neyman/CLT ↝; SAVE --- | Ampliar filas de catálogo a «IC Wald OPE» si se formaliza |
| Normal approx × Direct (V/Q) | **Parcial** | Cap. 7 DM; asintótica value fns en cap. 4 | Sin fila canónica DM→IC; Luckett/Liao no fichados |
| Normal approx × IS | **Parcial** | Cap. 7 IS + curse-of-horizon | Wang et al. 2023a no fichado; IC IS débil frente a DR |
| Normal approx × Model-based | **Casi no** | Menciona model-based en prosa OPE, sin IC dedicado | Hueco: CI model-based (ninguna celda survey tampoco llena mucho) |
| Concentration × IS/DR/DM | **No / mínimo** | Cap. 8 habla IC; no desarrolla cotas de concentración tipo Thomas/Jiang como método canónico | **Hueco fuerte**: inequalities de concentración para OPE |
| Bootstrap × Model-based / DM / DR | **Parcial (tooling)** | Cap. 4: bootstrap clásico + IC percentil; Luo 2025 (ficha 24-sep) multiplier bootstrap SCR | **Hueco**: bootstrap *OPE-específico* (Hanna, Hao) no integrado; sin ↝ en catálogo |
| Empirical likelihood × IS (CoinDICE) | **No** | — | **Hueco**: likelihood empírica / CoinDICE |
| IC cuando $\pi=\pi^*$ no única | **Parcial (literatura)** | NSAVE ficha 23-sep; SAVE en caps. 8/11 | Survey lista m-out-of-n / one-step / subagging — no están en catálogo ↔/↝ |
| Tests Markov (§4 survey) | **Anunciado, no desarrollado** | Cap. 6 L1 (Markov) es esqueleto PENDIENTE | Hueco operativo = deuda cap. 6 |
| Tests estacionariedad (§6) | **Anunciado** | Cap. 6 L3 | Idem |
| A/B testing largo plazo (§6) | **No** | — | Hueco (despliegue / cap. 11?) |
| Inferencia bandits adaptativa (§6) | **No** | — | Hueco (fuera de MDP foco del libro) |
| Confounding / mediadores | **Fuera Table 4.2** | Ficha Shi JASA 2024 (cope) | Survey no taxonomiza confounding; libro sí lo planea en L4 |

### Resumen de huecos prioritarios (para autor / backlog)
1. Concentration inequalities para OPE (fila entera del survey).
2. Empirical likelihood / CoinDICE.
3. Bootstrap OPE-específico vs solo bootstrap clásico del cap. 4.
4. Formalizar en catálogo ↔/↝ las filas «IC Wald OPE» y «SCR simultáneas» (Luo 2025).
5. Temas §6 survey (A/B, bandits, stationarity tests) vs alcance MDP del libro — decidir inclusión.

---

## Línea conformal — ficha conjunta (2026-09-26)

Dos trabajos de **cobertura en muestra finita** (o casi) para OPE vía predicción conforme / datos auxiliares. Entran en el catálogo del libro como línea **conformal / finite-sample CI** frente a la línea asintótica Wald/DR/SAVE (caps. 7–8). **No** añadidos a `.bib` hoy (solo ficha; abstract + hipótesis leídos en PDF arXiv).

### A) Foffano, Russo & Proutière (2023) — Conformal OPE in MDPs / arXiv:2304.02574

| Campo | Valor |
|---|---|
| **Cita** | Foffano, D., Russo, A., & Proutière, A. (2023). Conformal Off-Policy Evaluation in Markov Decision Processes. *IEEE Conference on Decision and Control (CDC)*. También arXiv:2304.02574v2 (19 Sep 2023). |
| **DOI (publicado)** | [10.1109/CDC49753.2023.10383469](https://doi.org/10.1109/CDC49753.2023.10383469) |
| **DOI (preprint)** | [10.48550/arXiv.2304.02574](https://doi.org/10.48550/arXiv.2304.02574) |
| **arXiv** | [2304.02574](https://arxiv.org/abs/2304.02574) · PDF local: `2304.02574.pdf` |
| **OpenAlex** | Publicado: [W4391020688](https://openalex.org/W4391020688) (cited_by_count API: 9); preprint arXiv: [W4362679650](https://openalex.org/W4362679650) |
| **Semantic Scholar** | [3831a0318d9db98eac73a54a6b3e9e25a84aa2e2](https://www.semanticscholar.org/paper/3831a0318d9db98eac73a54a6b3e9e25a84aa2e2) (citas S2: 11; CorpusId 257952395; DOI CDC en externalIds) |
| **Fuentes de ficha** | S2 + OpenAlex + PDF arXiv (abstract, Assump. 1, Props. 1–2). Fecha: 2026-09-26. |

#### Supuesto clave
**Assumption 1:** $P^{\pi}(\cdot\mid x)$ absolutamente continua w.r.t. $P^{\pi_b}(\cdot\mid x)$ (overlap / soporte); datos de calibración i.i.d. bajo la política de comportamiento. La validez conforme usa **weighted exchangeability** (extiende Taufiq et al. 2022 de bandits contextuales a MDPs de horizonte finito).

#### Qué garantiza (énfasis: muestra finita)
Intervalo conforme $Ĉ_n(x)$ que contiene la recompensa/retorno de la política objetivo con nivel prescrito $1-\alpha$ **en muestra finita**, no solo asintóticamente. Con pesos estimados $\hat w$: cobertura $\ge 1-\alpha-\Delta_w$ (Prop. 2; $\Delta_w$ error de pesos). Scores asimétricos + métodos de shift buscan intervalos más cortos que baselines conformes centrados en la behavior policy.

#### Qué exige
1. Datos offline bajo $\pi_b$; split train/calibración.
2. Overlap (Assump. 1) para pesos de importance bien definidos.
3. Estimación de pesos $w(x,y)$ (error acotado $\Rightarrow$ pérdida de cobertura $\Delta_w$).
4. Espacios de estado/acción tratados en el paper (énfasis empírico en problemas con $X,Y$ manejables; ver §V del PDF).

#### Encaje en el catálogo ↔/↝
- Llena el **hueco «concentration / conformal»** frente a IC Wald/DR del survey Shi 2025 (matriz 25-sep).
- Caps. **7–8** (OPE / IC): garantía **finite-sample** alternativa a CLT + bootstrap.
- Catálogo: candidato a fila «IC conforme OPE» ($arrow.squiggly$ / por definir) — **no** integrado aún en tabla canónica.

#### Estado
- [x] Abstract + Assump. 1 + Props. 1–2 leídos en PDF.
- [ ] Pruebas completas / todos los algoritmos de §V — no afirmar tasas en prosa del libro.
- [ ] Entrada `.bib` — diferida (status: `ficha`).

### B) Mandyam et al. (2025) — PERRY / arXiv:2507.20068

| Campo | Valor |
|---|---|
| **Cita** | Mandyam, A., Meng, J., Gao, G., Sun, J., Schwager, M., Engelhardt, B. E., & Brunskill, E. (2025). PERRY: Policy Evaluation with Confidence Intervals using Auxiliary Data. arXiv:2507.20068. *Transactions on Machine Learning Research* (según frontmatter del PDF / venue S2). |
| **DOI (preprint)** | [10.48550/arXiv.2507.20068](https://doi.org/10.48550/arXiv.2507.20068) |
| **arXiv** | [2507.20068](https://arxiv.org/abs/2507.20068) · PDF local: `2507.20068.pdf` |
| **OpenAlex** | [W6891744960](https://openalex.org/W6891744960) (type: preprint; cited_by_count API: 0 al fichar) |
| **Semantic Scholar** | [ea2ee7a0e7cbe1c462eb45196f46a46ec559c867](https://www.semanticscholar.org/paper/ea2ee7a0e7cbe1c462eb45196f46a46ec559c867) (citas S2: 4; CorpusId 280322911; venue TMLR) |
| **Fuentes de ficha** | S2 + OpenAlex (DOI directo) + PDF arXiv (abstract, Assumps. 1–3, Thm 1–2). Fecha: 2026-09-26. |

#### Supuesto clave
Dos métodos: **CP-Gen** (conformal ponderado para $V^\pi(s)$ en estados continuos, con $\epsilon$-aproximación de pesos) y **DR-PPI** (doubly robust + prediction-powered inference para $V^\pi$ promedio, con datos sintéticos/auxiliares). Para CP-Gen: Lipschitz de políticas y dinámicas + suavidad del score (Assumps. 1–3). Los datos auxiliares/sintéticos pueden estar sesgados; la corrección IS/DR es la que sostiene validez.

#### Qué garantiza (énfasis: muestra finita vs asintótico)
- **CP-Gen (Thm 1):** banda conforme con cobertura $\ge 1-\alpha-\Delta_w$ en muestra finita (pérdida $\Delta_w$ por estimación/$\epsilon$-approx de pesos); extiende Foffano et al. a estados continuos + datos sintéticos.
- **DR-PPI (Thm 2):** CI **asintóticamente** válidos ($\liminf$ cobertura $\ge 1-\alpha$) aun si el generativo auxiliar está mal especificado, si la corrección IS es consistente.

#### Qué exige
1. Dataset offline + (opcional) trayectorias auxiliares/sintéticas.
2. Para CP-Gen: Assumps. 1–3 y control de $\epsilon_s,\epsilon_r$ / error de pesos.
3. Para DR-PPI: corrección IS/WIS/PDIS consistente; régimen asintótico $n,M,N_f\to\infty$.
4. CONDICIONES SIN ESPECIFICAR a nivel de tasas numéricas concretas en el libro (no trasladar cotas $\tilde O(\cdot)$ sin decisión editorial).

#### Encaje en el catálogo ↔/↝
- Continúa la línea conformal de Foffano; añade **datos auxiliares** y puente DR–PPI.
- Caps. **7–8**; contraste con SAVE/NSAVE (asintótica/martingala) y con concentration inequalities del hueco survey.
- Catálogo: misma fila candidata «IC conforme / PPI-OPE»; DR-PPI enlaza con IF/DR ya ↝ en el libro.

#### Estado
- [x] Abstract + Assumps. 1–3 + Thm 1–2 leídos en PDF.
- [ ] Integración editorial / comparación numérica con baselines del cap. 8 — no hecha.
- [ ] Entrada `.bib` — diferida (status: `ficha`).

### Lectura conjunta (catálogo)
| Dimensión | Foffano 2023 | PERRY 2025 |
|---|---|---|
| Objeto | Intervalo conforme OPE en MDP horizonte finito | CP-Gen: $V^\pi(s)$; DR-PPI: $V^\pi$ global |
| Tipo de garantía | Finite-sample (con $\Delta_w$ si pesos estimados) | CP-Gen: finite-sample (con $\Delta_w$); DR-PPI: asintótica |
| Datos auxiliares | No (énfasis en weighted CP + scores) | Sí (sintéticos / gen. model) |
| Estados continuos | Limitado / métodos de pesos | $\epsilon$-reweighting explícito |
| Hueco libro que tocan | Concentration/conformal OPE (matriz 25-sep) | Idem + PPI + robustez a gen. sesgado |

## Índice de fichas pendientes (plan semana 1)

| Día | Trabajo | Estado |
|---|---|---|
| 22 sep | Shi et al. JASA (esta ficha) | hecha (abstract-level) |
| 23 sep | Semiparamétrica valores de política óptima / NSAVE (arXiv 2505.13809) | hecha (abstract + hipótesis PDF; sin .bib) |
| 24 sep | Luo, Fan & Wu (NeurIPS 2025), sieves + bootstrap | hecha (abstract-level; sin .bib; sin arXiv) |
| 25 sep | Survey IC en RL (arXiv 2502.16195) | hecha (abstract + §5 taxonomía Table 4.2; sin .bib) |
| 26 sep | OPE conforme (2304.02574) + PERRY (2507.20068) | hecha (ficha conjunta; abstract+hip. PDF; sin .bib) |
| 27 sep | Evaluación estadística LLMs: Bowyer et al. 2503.01747 + Miller 2411.00640 | hecha (fichas; PDF leído; sin .bib) |

## Evaluación estadística de LLMs — ficha conjunta (2026-09-27)

Dos trabajos sobre **incertidumbre / IC en evaluación de LLMs**, orientados al **cap. 11 (despliegue / evaluación)**. El position paper ICML 2025 advierte que el TLC subestima la incertidumbre con $n$ pequeño; Miller (2024) documenta IC reportados *too narrow* cuando se ignora clustering y da el marco frecuentista (SE, pares, potencia). **No** añadidos a `.bib` (solo ficha; abstract + claims leídos en PDF arXiv).

### A) Bowyer, Aitchison & Ivanova (2025) — Position: Don't use the CLT… / arXiv:2503.01747

| Campo | Valor |
|---|---|
| **Cita** | Bowyer, S., Aitchison, L., & Ivanova, D. R. (2025). Position: Don't Use the CLT in LLM Evals With Fewer Than a Few Hundred Datapoints. *International Conference on Machine Learning (ICML)* (venue S2/DBLP: `conf/icml/BowyerAI25`). También arXiv:2503.01747v3 (28 May 2025). |
| **DOI (preprint)** | [10.48550/arXiv.2503.01747](https://doi.org/10.48550/arXiv.2503.01747) |
| **arXiv** | [2503.01747](https://arxiv.org/abs/2503.01747) · PDF local: `pdfs/2503.01747.pdf` |
| **OpenAlex** | [W4416045832](https://openalex.org/W4416045832) (type: preprint; cited_by_count API: 0 al fichar; venue primaria arXiv) |
| **Semantic Scholar** | [4ca76fd94f9227eb3c2cd717206734645932dc4e](https://www.semanticscholar.org/paper/4ca76fd94f9227eb3c2cd717206734645932dc4e) (citas S2: 22; CorpusId 276774652; DBLP conf/icml/BowyerAI25; ArXiv 2503.01747) |
| **Fuentes de ficha** | S2 + OpenAlex + PDF arXiv (abstract + posición + §recomendaciones Bayesianas). Fecha: 2026-09-27. |

#### Claim / supuesto clave
**Posición:** los métodos basados en el **TLC** son adecuados cuando el benchmark tiene *miles* de ítems, pero **fallan** en evals LLM con $n$ pequeño / benchmarks especializados: subestiman dramáticamente la incertidumbre (barras de error *too small*). Recomiendan alternativas **frecuentistas y bayesianas** fáciles de implementar (p. ej. intervalos bayesianos para diferencia u odds ratio; librería `bayes_evals`).

#### Qué garantiza
No un teorema de cobertura nuevo del libro: una **advertencia metodológica** + evidencia experimental (simulaciones) de que IC/CLT y bootstrap quedan mal calibrados en régimen small-data, mientras métodos bayesianos mantienen cobertura y a menudo producen intervalos más eficientes a cobertura dada.

#### Qué exige
1. Reconocer el tamaño efectivo del eval ($N$, agrupación, pareado).
2. No reportar solo media ± SE-CLT cuando $N \ll$ cientos.
3. Para comparación de modelos: preferir análisis pareado / bayesiano según el diseño.
4. CONDICIONES SIN ESPECIFICAR a nivel de umbral numérico único «pocos cientos» en prosa del libro sin decisión editorial (el título del paper fija el orden de magnitud).

#### Encaje en el libro (cap. 11)
- Cap. **11 (despliegue / evaluación)**: protocolo de reporte de incertidumbre al evaluar agentes/LLM en producción o leaderboards.
- Contraste productivo con Miller 2024 (abajo), que *sí* recomienda SE vía TLC como default — Bowyer acota el dominio donde eso deja de valer.
- Enlaza con F.12 (LLM-Agents) y con huecos de evaluación del catálogo.

#### Estado
- [x] Abstract + claim central + recomendaciones leídos en PDF.
- [ ] Integración editorial en prosa del cap. 11 — no hecha.
- [ ] Entrada `.bib` — diferida (status: `ficha`).

### B) Miller (2024) — Adding Error Bars to Evals / arXiv:2411.00640

| Campo | Valor |
|---|---|
| **Cita** | Miller, E. (2024). Adding Error Bars to Evals: A Statistical Approach to Language Model Evaluations. arXiv:2411.00640v1 (1 Nov 2024). |
| **DOI (preprint)** | [10.48550/arXiv.2411.00640](https://doi.org/10.48550/arXiv.2411.00640) |
| **arXiv** | [2411.00640](https://arxiv.org/abs/2411.00640) · PDF local: `pdfs/2411.00640.pdf` |
| **OpenAlex** | [W4404345312](https://openalex.org/W4404345312) (type: preprint; cited_by_count API: 7 al fichar) |
| **Semantic Scholar** | [4ba6a858d4c77b8b6dcd2bcf8b159eb8c1353e6b](https://www.semanticscholar.org/paper/4ba6a858d4c77b8b6dcd2bcf8b159eb8c1353e6b) (citas S2: 133; CorpusId 273798465; ArXiv 2411.00640) |
| **Relación con 2503.01747** | Citado por Bowyer et al. como trabajo reciente sobre barras de error en evals; candidato principal entre refs/relacionados por el tema **IC demasiado estrechos** («too narrow»). |
| **Fuentes de ficha** | S2 + OpenAlex + PDF arXiv (abstract, recomendaciones 1–5, §sobre IC too narrow, conclusión). Fecha: 2026-09-27. |

#### Claim / supuesto clave
Las evals son **experimentos** sobre una superpoblación de preguntas. El autor muestra que IC reportados en la literatura (caso de lectura/comprensión citado en el PDF) pueden ser **anti-conservadores (too narrow)** si se ignora la estructura (p. ej. clustering), y formula SE ingenuos, *clustered*, y contrastes **pareados** entre modelos.

#### Qué garantiza
Marco analítico (no garantía finite-sample tipo conforme): fórmulas de SE vía TLC; SE agrupados cuando las preguntas vienen en grupos; inferencia sobre diferencias *question-level* pareadas; reducción de varianza (resampleo / next-token probs); análisis de potencia para dimensionar el eval.

#### Qué exige
1. Conceptualizar ítems como muestra de una superpoblación.
2. Reportar SE / IC, no solo el punto SOTA en negrita.
3. Si hay grupos relacionados → SE clustered (si no, IC pueden quedar *too narrow*).
4. Comparar modelos por diferencias pareadas, no solo por medias marginales.
5. Usar power analysis antes de afirmar superioridad.

#### Encaje en el libro (cap. 11)
- Cap. **11**: checklist de evaluación estadística al desplegar / comparar agentes LLM.
- Complementa Bowyer: Miller da el *cómo* frecuentista estándar; Bowyer marca cuándo el TLC deja de bastar ($n$ pequeño).
- F.12 / despliegue: lenguaje común «error bars on evals».

#### Estado
- [x] Abstract + recomendaciones + pasajes «too narrow» leídos en PDF.
- [ ] Integración editorial en cap. 11 — no hecha.
- [ ] Entrada `.bib` — diferida (status: `ficha`).

### Lectura conjunta (cap. 11)
| Dimensión | Bowyer et al. 2025 | Miller 2024 |
|---|---|---|
| Objeto | Calibración de IC/CLT con $n$ pequeño | Diseño y análisis estadístico de evals |
| Mensaje fuerte | TLC → barras *too small* si $N$ ≪ cientos | IC literarios a veces *too narrow* (clustering); usar SE/pares/potencia |
| Herramienta | Bayes (y frecuentista no-CLT) + `bayes_evals` | SE-CLT, clustered SE, paired diffs, power |
| Tensión útil | Acota el dominio del default CLT de Miller | Default operacional cuando $N$ es grande |


## Landers & Doryab (2023) — DRL Verification survey (ficha 2026-10-01)

| Campo | Valor |
|---|---|
| **Cita** | Landers, M., & Doryab, A. (2023). Deep Reinforcement Learning Verification: A Survey. *ACM Computing Surveys*. DOI 10.1145/3596444 |
| **OpenAlex** | W4372353038 |
| **Semantic Scholar** | `0860b142a9e6c71974ffbbcb291f5d09d4b48142` |
| **arXiv** | No en registro S2/OA |
| **Encaje** | Cap. 9 §1 (auditar garantía) — contraste verificación formal DRL vs. auditoría estadística de herencia vía $F$. También cap. 11. |
| **Estado** | `ficha` — abstract OA+S2 leído; **no** `.bib` hoy. Detalle en `insumos/cap9_sec1_auditar_garantia.md`. |


## Prudencio, Máximo & Colombini (2023) — Offline RL survey (ficha 2026-10-02)

| Campo | Valor |
|---|---|
| **Cita** | Prudencio, R. F., Máximo, M. R. O. A., & Colombini, E. L. (2023). A Survey on Offline Reinforcement Learning: Taxonomy, Review, and Open Problems. *IEEE TNNLS*. DOI 10.1109/TNNLS.2023.3250269 |
| **OpenAlex** | W4360584316 |
| **Semantic Scholar** | `61e7a3d5606043594a8ce377870479f77a6b58c2` |
| **arXiv** | 2203.01387 |
| **Encaje** | Cap. 9 §2 (protocolo paso a paso) — taxonomía/open problems de evaluación offline vs. checklist de auditoría estadística. Contraste con Landers & Doryab (verificación formal DRL). También caps. 7–8, 11. |
| **Estado** | `ficha` — abstract OA+S2 leído; **no** `.bib` hoy. Detalle en `insumos/cap9_sec2_protocolo.md`. |
| **Nota** | Patterson et al. arXiv:2304.01315 (OA W4362655362) candidato «empirical design / protocolo»; S2 `paperId` pendiente (HTTP 429 el 2026-10-02). |



## Khan, Saveski & Ugander (2023) — OPE beyond overlap / partial ID (ficha 2026-10-03)

| Campo | Valor |
|---|---|
| **Cita** | Khan, S., Saveski, M., & Ugander, J. (2023). Off-policy evaluation beyond overlap: partial identification through smoothness. arXiv:2305.11812. DOI 10.48550/arXiv.2305.11812 |
| **OpenAlex** | W4377372456 |
| **Semantic Scholar** | `d186f3787e1679211eee8b9b8b37f9228c063764` |
| **arXiv** | 2305.11812 |
| **Encaje** | Cap. 9 §3 (condición no verificable) — overlap como NV-id; cotas de identificación parcial en lugar de pérdida silenciosa de garantía. También caps. 7–8, 11. |
| **Estado** | `ficha` — abstract OA+S2 leído; **no** `.bib` hoy. Detalle en `insumos/cap9_sec3_no_verificable.md`. |
| **Nota** | Bruns-Smith & Zhou 2023 (OA W4320351330; S2 `71a5ece57b39f098762d6123660ecb597886057a`; arXiv 2302.00662) candidato hermano (sensitivity a confounding secuencial); no fichado como principal hoy. |


## Nambiar et al. (2023) — Deep Offline RL for treatment optimization (ficha 2026-10-04)

| Campo | Valor |
|---|---|
| **Cita** | Nambiar, M., Ghosh, S., Ong, P., Chan, Y. E., Bee, Y. M., & Krishnaswamy, P. (2023). Deep Offline Reinforcement Learning for Real-world Treatment Optimization Applications. *KDD '23*, pp. 4673–4684. DOI 10.1145/3580305.3599800 |
| **OpenAlex** | W4385568106 |
| **Semantic Scholar** | `c6e7f5097e1073f164d4c580a0b2652b882cc34e` |
| **arXiv** | 2302.07549 |
| **Encaje** | Cap. 9 ejemplo protocolo×SSCH — contraste offline RL clínico real (diabetes/sepsis) vs. SSCH sintético; puente OPE/DR/NV-id. También caps. 7–8, 11–12. |
| **Estado** | `ficha` — abstract OA+S2+Crossref leído; **no** `.bib` hoy. Detalle en `insumos/cap9_ejemplo_ssch.md`. |
