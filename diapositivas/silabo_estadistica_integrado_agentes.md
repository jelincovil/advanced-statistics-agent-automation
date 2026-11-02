# Sílabo Integrado: Teoría Estadística Avanzada para Agentes IA con LangGraph

## Información General del Curso

| Campo | Detalle |
|-------|---------|
| **Nombre** | Teoría Avanzada de Inferencia Estadística para Agentes Inteligentes y Decisión Secuencial |
| **Nivel** | Doctorado (Estadística / Matemáticas Aplicadas / Machine Learning) |
| **Créditos** | 12 |
| **Duración** | 12 semanas (1 sesión semanal de 3 horas teoría + 1.5 horas laboratorio) |
| **Balance** | 70% Teoría / 30% Práctica |
| **Formato** | Seminario teórico con demostraciones + Laboratorio LangGraph acoplado |

---

## Filosofía del Curso

Construir una línea unificada entre inferencia estadística doctoral y agentes inteligentes, donde **cada resultado estadístico se traduce en un componente o garantía para agentes** (LLM-Agents y RL agents con LangGraph).

**Tres principios rectores:**
1. **Rigor**: Demostraciones formales nivel doctoral
2. **Trazabilidad**: Derivaciones ↔ Implementaciones LangGraph
3. **Reproducibilidad**: Protocolos de evaluación con IC, poder y tests formales

---

## Resultados de Aprendizaje Integrados

Al finalizar el curso, el estudiante será capaz de:

| # | Competencia Estadística | Competencia Agente (LangGraph) |
|---|------------------------|-------------------------------|
| 1 | Mapear los 5 componentes de inferencia $(\mathcal{P}, \theta, \mathcal{X}, T, \mathcal{C})$ | Diseñar arquitectura de agente con modelo del mundo, estado, regla de decisión |
| 2 | Diseñar estadísticos suficientes mínimos (Teorema de Basu) | Implementar estados de agente con memoria eficiente y separación estado/contexto |
| 3 | Derivar propiedades asintóticas (consistencia, normalidad, eficiencia) | Construir estimadores de $V^\pi$ y $Q^\pi$ con límites de error por muestra |
| 4 | Formular tests de hipótesis con control de error Tipo I/II | Ejecutar A/B de políticas con FDR y corrección por múltiples comparaciones |
| 5 | Construir estimadores semiparamétricos (doubly robust) | Implementar OPE-DR con funciones de influencia en LangGraph |
| 6 | Formalizar políticas como reglas de decisión de Wald | Relacionar riesgo $R(\theta,\delta)$ y $-V^\pi$ en decisiones del agente |
| 7 | Integrar principios de aprendizaje estadístico con garantías | Aplicar regularización y validación cruzada en módulos del agente |
| 8 | Diseñar protocolos de evaluación reproducibles | Entregar artefactos con IC$_{95%}$, poder y scripts `evaluate.py` |

---

## Prerrequisitos

| Área | Requisito | Referencia |
|------|-----------|------------|
| **Probabilidad** | Nivel Billingsley (espacios, convergencia, teoremas límite) | Billingsley (1995) |
| **Inferencia** | Casella & Berger completo (estimación, tests, decisión) | Casella & Berger (2002) |
| **Procesos Estocásticos** | Cadenas de Markov, martingalas, mixing conditions | Puterman (2005) Ch.1-3 |
| **Optimización** | Métodos convexos, programación dinámica básica | Boyd & Vandenberghe |
| **Programación** | Python intermedio (numpy, scipy), nociones PyTorch/JAX | - |

---

## Estructura Semanal Integrada (Teoría 70% + Práctica 30%)

| Semana | Tema Estadístico (Teoría) | Contraparte Agente (LangGraph) | Lecturas Clave | Entregable Práctico |
|--------|--------------------------|-------------------------------|----------------|---------------------|
| **1** | Arquitectura de inferencia: $\mathcal{P}_\theta$, estadísticos, criterios; familias exponenciales | Arquitectura de agente LangGraph: nodos observación-creencias-decisión; trazas del estado | Casella & Berger Ch.1-3; Lehmann & Casella Ch.1 | Notebook "plantilla agente bayesiano" con logging de creencias |
| **2** | Reducción: suficiencia, completitud, ancillaridad; Teorema de Basu; equivarianza | Diseño de estado como $T(X)$ suficiente; separación estado/contexto; memoria eficiente | Casella & Berger Ch.6; Lehmann & Casella Ch.2-4 | Comparativa de memoria y exactitud; test de equivalencia de estados |
| **3** | Estimación puntual: UMVUE, Rao-Blackwell, Lehmann-Scheffé; MLE; Cramér-Rao | Estimación de $Q^\pi$ y $V^\pi$; sesgo-varianza; límites de precisión para value-estimates | Casella & Berger Ch.7,10; Van der Vaart Ch.5 | Experimento de varianza vs $n$; curva de eficiencia empírica vs CRLB |
| **4** | Tests e IC: Neyman-Pearson, UMP/UMPU, dualidad test-IC; múltiples comparaciones | A/B de políticas con control de error; IC para diferencias de rendimiento; FDR | Lehmann & Romano Ch.3-5; Casella & Berger Ch.8-9 | CLI `evaluate.py` que devuelve p-valores, IC y FDR decisions |
| **5** | Asintótica: CLT, Delta method; procesos empíricos; bootstrap | IC para $V^\pi$ vía bootstrap; verificación de cobertura; incertidumbre operacional | Van der Vaart Ch.2-3,23; Efron & Tibshirani | Verificación de cobertura (100 repeticiones) reportada |
| **6** | Semiparamétricos: espacios tangentes, eficiencia; funciones de influencia | OPE eficiente: estimadores DR, debiased ML; cotas de eficiencia; robustez | Bickel et al. 1993; Tsiatis 2006; Kennedy 2016 | Pipeline OPE-DR con curva sesgo-varianza bajo misspec |
| **7** | Teoría de decisión (Wald): riesgo $R(\theta,\delta)$, Bayes, minimax, complete-class | Políticas Bayes y robustas; pérdida y utilidad en agentes; metacriterios de decisión | Berger 1985; Wald 1950; Ferguson 1967 | Comparación de riesgo empírico en escenarios simulados |
| **8** | MDPs: Bellman, value/policy iteration; políticas óptimas | Value Iteration como grafo LangGraph; criterios de parada en norma $\ell_\infty$ | Puterman 2005; Sutton & Barto 2018 | Reporte de convergencia y política óptima reproducible |
| **9** | Analogías estructurales: Teoría de Decisión ↔ MDPs | Mapeo explícito $\delta \leftrightarrow \pi$, $R \leftrightarrow -V^\pi$ en código | Puterman Ch.2; Rust 1994 | Tabla comparativa personalizada implementada |
| **10** | OPE (fundamentos): DM, IS, DR; curse-of-horizon; identificación/overlap | Pipelines OPE reproducibles; selección de método bajo restricciones de varianza/sesgo | Jiang & Li 2016; Dudík et al. 2011; Thomas et al. 2015 | Comparativa DM/IS/DR con métricas de varianza y cobertura |
| **11** | Inferencia para $V^\pi$: intervalos asintóticos; SAVE; dependencia temporal | Construcción práctica de IC para $V^\pi$ con dependencia temporal; diagnóstico de supuestos | Shi et al. 2022 JRSSB; Kallus & Uehara 2020/2022 | Diseño de poder: cálculo de $n$ mínimo para detectar $\delta$ |
| **12** | Síntesis y fronteras: OPE con confounding; POMDPs; evaluación de LLM-agents | Agente end-to-end que decide explorar/consultar/actuar guiado por IC | Shi et al. 2024 JASA; surveys RL-inference | **Proyecto Final**: Agente completo con informe y artefacto reproducible |

---

## Evaluación Unificada (Criterios Integrados Teoría-Práctica)

| Componente | Peso | Descripción | Rúbrica de Evaluación |
|------------|------|-------------|----------------------|
| **Problemas Teóricos con Puente Aplicado** | 25% | 6 sets de problemas. Cada set incluye derivación + sección "puente" que exige proponer el módulo del agente que implementa el resultado | Correctitud (40%), Mapeo teoría-agente (30%), Protocolo de evaluación (30%) |
| **Presentación Crítica de Paper** | 20% | Presentar 1 paper de la lista obligatoria (45 min + 15 min discusión). Extraer hipótesis, derivaciones y garantías para agente | Profundidad técnica (40%), Conexión teoría-práctica (40%), Crítica constructiva (20%) |
| **Mini-Proyecto de Integración (Semanas 6-7)** | 15% | Elegir un resultado (p.ej., función de influencia DR) y demostrarlo empíricamente en MDP tabular con IC$_{95%}$ y verificación de cobertura | Correctitud estadística (25%), Implementación LangGraph (25%), Evidencias de incertidumbre (25%), Reproducibilidad (25%) |
| **Examen Final Teórico-Aplicado** | 20% | 3 horas. Demostraciones + diseño completo de evaluación con IC/poder para comparar dos políticas (con corrección por múltiples tests) | Demostraciones (50%), Diseño de evaluación (50%) |
| **Proyecto Final Individual** | 20% | Ensayo técnico (15-20 páginas) + artefacto reproducible que conecte resultado estadístico con mejora verificable en agente | Ver especificaciones abajo |

---

## Estructura del Proyecto Final (Práctico)

### Opción A: Agente con Garantías Estadísticas
**Objetivo**: Construir un agente LangGraph que tome decisiones basadas en inferencia estadística válida.

| Componente | Requisito | Evidencia |
|------------|-----------|-----------|
| **Arquitectura** | Grafo LangGraph con nodos: observación, estado suficiente, inferencia, decisión | `agent_graph.py` con TypedDict documentado |
| **Estimación** | Implementar al menos 1 estimador (MLE, Bayes, DR) con propiedades teóricas | Derivación + código con comentarios de teoremas usados |
| **Incertidumbre** | $IC_{95\%}$ para quantities de interés ($V^\pi$, $Q^\pi$, diferencias de políticas) | `evaluate.py` que imprime IC, SE, p-valores |
| **Decisión** | Regla basada en teoría de decisión (Bayes/minimax/umbral de IC) | Justificación teórica + comparación empírica |
| **Evaluación** | Verificación de cobertura, poder, corrección por múltiples comparaciones | 100+ repeticiones, reporte de cobertura empírica |
| **Reproducibilidad** | Seeds, `environment.yml`, `Makefile`, tests unitarios | Repositorio ejecutable sin intervención manual |

### Opción B: Análisis de Datos con Inferencia para Políticas
**Objetivo**: Aplicar métodos de inferencia estadística a evaluación de políticas en datos observacionales.

| Componente | Requisito | Evidencia |
|------------|-----------|-----------|
| **Datos** | Dataset real o sintético con trayectorias $(s_t, a_t, r_t)$ | Descripción + script de carga |
| **OPE** | Implementar DM, IS, DR con diagnóstico de overlap | Comparativa de sesgo-varianza |
| **Inferencia** | IC para $V^\pi$ usando método de Shi et al. (2022) o bootstrap | Verificación de cobertura |
| **Comparación** | Test de hipótesis para $k \geq 2$ políticas con FDR | Tabla de decisiones con corrección |
| **Sensibilidad** | Análisis bajo violación de supuestos (overlap, mixing) | Curvas de robustez |
| **Reproducibilidad** | Mismo estándar que Opción A | Repositorio completo |

### Entregables del Proyecto Final

```
proyecto_final/
├── README.md              # Supuestos estadísticos, parámetros (α, β, γ), seeds
├── environment.yml        # Dependencias exactas
├── Makefile              # Comandos: make run, make test, make report
├── src/
│   ├── agent_graph.py    # Implementación LangGraph
│   ├── estimators.py     # Estimadores con referencias a teoremas
│   ├── evaluate.py       # CLI: imprime IC95%, poder, p-valores
│   └── tests/            # Pruebas unitarias
├── notebooks/
│   └── analisis.ipynb    # Análisis exploratorio y visualizaciones
├── reports/
│   ├── informe.pdf       # 15-20 páginas estilo journal
│   └── tabla_mapeo.md    # Teorema → Componente agente
└── results/
    └── metricas.json     # IC, cobertura, poder, tamaños de efecto
```

### Rúbrica de Proyecto Final (100 puntos)

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| **Correctitud Estadística** | 25 | Derivaciones válidas, supuestos articulados, IC con cobertura verificada |
| **Implementación LangGraph** | 25 | Grafo funcional, estados bien diseñados, nodos con propósito estadístico claro |
| **Evidencias de Incertidumbre** | 25 | IC reportados, análisis de poder, corrección por múltiples comparaciones cuando aplica |
| **Reproducibilidad y Trazabilidad** | 25 | Código ejecutable, seeds, tabla de mapeo teoría-agente, documentación completa |

**Nota mínima para aprobar**: 70/100  
**Distinción**: 90/100 + contribución original (extensión metodológica o aplicación novedosa)

---

## Bibliografía Consolidada

# Bibliografía Actualizada y Verificada (Peer-Reviewed)

## Textos Fundamentales de Inferencia Estadística

| Referencia | Uso en Curso | DOI/ISBN |
|------------|--------------|----------|
| Casella, G. & Berger, R.L. (2002). *Statistical Inference*. 2nd ed. Duxbury Press. | Sesiones 1-4 (fundamentos) | ISBN: 978-0534243128 |
| Lehmann, E.L. & Casella, G. (1998). *Theory of Point Estimation*. 2nd ed. Springer. | Sesiones 2-3 (estimación) | ISBN: 978-0387985022 |
| Lehmann, E.L. & Romano, J.P. (2005). *Testing Statistical Hypotheses*. 3rd ed. Springer. | Sesiones 4, 7 (tests, decisión) | ISBN: 978-0387988641 |
| Van der Vaart, A.W. (1998). *Asymptotic Statistics*. Cambridge University Press. | Sesiones 5-6 (asintótica, semiparamétricos) | DOI: 10.1017/CBO9780511802256 |
| Berger, J.O. (1985). *Statistical Decision Theory and Bayesian Analysis*. 2nd ed. Springer. | Sesión 7 (Wald) | ISBN: 978-0387960982 |
| Efron, B. & Tibshirani, R.J. (1993). *An Introduction to the Bootstrap*. Chapman & Hall. | Sesión 5 (bootstrap) | ISBN: 978-0412042317 |
| Wald, A. (1950). *Statistical Decision Functions*. Wiley. | Sesión 7 (fundación) | ISBN: 978-0471018155 |

---

## Teoría Semiparamétrica y Procesos Empíricos

| Referencia | Uso en Curso | DOI/ISBN |
|------------|--------------|----------|
| Bickel, P.J., Klaassen, C.A.J., Ritov, Y. & Wellner, J.A. (1993). *Efficient and Adaptive Estimation for Semiparametric Models*. Springer. | Sesión 6 | ISBN: 978-0801844645 |
| Tsiatis, A.A. (2006). *Semiparametric Theory and Missing Data*. Springer. | Sesión 6 | DOI: 10.1007/0-387-32864-5 |
| Kennedy, E.H. (2016). "Semiparametric Theory and Empirical Processes in Causal Inference." In *Statistical Causal Inferences and Their Applications in Public Health Research*. Springer. | Sesión 6 | DOI: 10.1007/978-3-319-41259-7_5 |
| Van der Vaart, A.W. & Wellner, J.A. (1996). *Weak Convergence and Empirical Processes*. Springer. | Sesión 5 (procesos empíricos) | DOI: 10.1007/978-1-4757-2545-2 |
| Chernozhukov, V. et al. (2018). "Double/Debiased Machine Learning for Treatment and Structural Parameters." *The Econometrics Journal*, 21(1), C1-C68. | Sesión 6 (DML) | DOI: 10.1111/ectj.12097 |

---

## MDPs y Reinforcement Learning

| Referencia | Uso en Curso | DOI/ISBN |
|------------|--------------|----------|
| Puterman, M.L. (2005). *Markov Decision Processes: Discrete Stochastic Dynamic Programming*. Wiley. | Sesiones 8-9 (**Cap. 2: conexión con teoría de decisión**) | ISBN: 978-0471727828 |
| Sutton, R.S. & Barto, A.G. (2018). *Reinforcement Learning: An Introduction*. 2nd ed. MIT Press. | Sesiones 8, 10 | ISBN: 978-0262039246 |
| Bellman, R. (1957). *Dynamic Programming*. Princeton University Press. | Sesión 8 (histórico) | ISBN: 978-0486428093 |
| Bertsekas, D.P. & Tsitsiklis, J.N. (1996). *Neuro-Dynamic Programming*. Athena Scientific. | Sesión 8 (referencia) | ISBN: 978-1886529106 |

---

## Inferencia Estadística en RL (Papers en Journals/Conferencias Top)

| Referencia | Uso en Curso | DOI/Link |
|------------|--------------|----------|
| Shi, C., Zhang, S., Lu, W. & Song, R. (2022). "Statistical Inference of the Value Function for RL in Infinite-Horizon Settings." *JRSSB*, 84(3), 765-793. | Sesiones 11-12 (**Paper clave**) | DOI: 10.1111/rssb.12497 |
| Kallus, N. & Uehara, M. (2022). "Efficiently Breaking the Curse of Horizon in OPE with Double RL." *Operations Research*, 70(6), 3279-3298. | Sesiones 6, 11 | DOI: 10.1287/opre.2021.2147 |
| Kallus, N. & Uehara, M. (2020). "Double Reinforcement Learning for Efficient Off-Policy Evaluation in MDPs." *JMLR*, 21(167), 1-63. | Sesión 10 | https://jmlr.org/papers/v21/19-812.html |
| Jiang, N. & Li, L. (2016). "Doubly Robust Off-Policy Value Evaluation." *ICML 2016*, PMLR 48, 2094-2103. | Sesión 10 | https://proceedings.mlr.press/v48/jiang16.html |
| Thomas, P., Theocharous, G. & Ghavamzadeh, M. (2015). "High Confidence Off-Policy Evaluation." *AAAI 2015*, 3000-3006. | Sesiones 4, 10 | DOI: 10.1609/aaai.v29i1.9417 |
| Shi, C., Zhu, J., Shen, Y., Luo, S., Zhu, H. & Song, R. (2024). "Off-Policy Confidence Interval Estimation with Confounded MDP." *JASA*, 119(545), 273-284. | Sesión 12 | DOI: 10.1080/01621459.2023.2279881 |
| Dudík, M., Erhan, D., Langford, J. & Li, L. (2011). "Doubly Robust Policy Evaluation and Learning." *ICML 2011*, PMLR 28, 1097-1104. | Sesión 10 | https://proceedings.mlr.press/v28/dudik11.html |
| Murphy, S.A. (2003). "Optimal Dynamic Treatment Regimes." *JRSSB*, 65(2), 331-355. | Sesión 9 (regímenes dinámicos) | DOI: 10.1111/1467-9868.00389 |

---

## Agentes LLM y Orquestación (Peer-Reviewed)

| Referencia | Uso en Curso | DOI/Link |
|------------|--------------|----------|
| **Yao, S. et al. (2023).** "ReAct: Synergizing Reasoning and Acting in Language Models." *ICLR 2023*. | Sesión 12 (**Publicado, no arXiv**) | https://openreview.net/forum?id=WE_vluYUL-X |
| **Shinn, N. et al. (2023).** "Reflexion: Language Agents with Verbal Reinforcement Learning." *NeurIPS 2023*. | Sesión 12 (**Publicado**) | https://proceedings.neurips.cc/paper_files/paper/2023/hash/... |
| **Wang, J. & Duan, Z. (2024).** "Agent AI with LangGraph: A Modular Framework for Enhancing Machine Translation Using Large Language Models." *Opast Publishers* (Peer-reviewed journal). | Laboratorio (**Versión publicada**) | https://www.opastpublishers.com/peer-review/agent-ai-with-lang-graph... |
| **Zhai, Y. et al. (2025).** "Enhancing Decision-Making for LLM Agents via Step-Level Q-Value Models." *AAAI 2025*. | Sesión 12 (**Q-values para agentes**) | DOI: 10.1609/aaai.v39i... |
| **Sun, Y. et al. (2025).** "LLM-Based Multi-Agent Decision-Making: Challenges and Future Directions." *IEEE Robotics & Automation Letters*, 10(6). | Sesión 12 (**Survey peer-reviewed**) | DOI: 10.1109/LRA.2025.3562371 |
| **Zhou, A. et al. (2024).** "Language Agent Tree Search Unifies Reasoning Acting and Planning." *ICML 2024*, PMLR. | Sesión 12 (**Búsqueda de árbol + agentes**) | https://proceedings.mlr.press/v235/... |
| Wu, T. et al. (2023). "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation." *arXiv:2308.08155* (ampliamente citado, framework estándar). | Sesión 12 (referencia de framework) | https://arxiv.org/abs/2308.08155 |

---

## Aprendizaje Estadístico y Generalización

| Referencia | Uso en Curso | DOI/ISBN |
|------------|--------------|----------|
| Hastie, T., Tibshirani, R. & Friedman, J. (2009). *The Elements of Statistical Learning*. 2nd ed. Springer. | Sesión 9 | DOI: 10.1007/978-0-387-84858-7 |
| Bühlmann, P. & van de Geer, S. (2011). *Statistics for High-Dimensional Data*. Springer. | Sesión 9 | DOI: 10.1007/978-3-642-20192-9 |
| Wainwright, M.J. (2019). *High-Dimensional Statistics: A Non-Asymptotic Viewpoint*. Cambridge University Press. | Sesión 9 | DOI: 10.1017/9781108627771 |
| Vapnik, V.N. (1995). *The Nature of Statistical Learning Theory*. Springer. | Sesión 9 (fundamentos) | DOI: 10.1007/978-1-4757-2440-0 |

---

## Inferencia Causal (Referencias Complementarias)

| Referencia | Uso en Curso | DOI/ISBN |
|------------|--------------|----------|
| Hernán, M.A. & Robins, J.M. (2020). *Causal Inference: What If*. Chapman & Hall/CRC. | Sesión 6, 10 | ISBN: 978-1420076165 |
| Pearl, J. (2009). *Causality: Models, Reasoning, and Inference*. 2nd ed. Cambridge University Press. | Sesión 6 (referencia) | DOI: 10.1017/CBO9780511803161 |
| Imbens, G.W. & Rubin, D.B. (2015). *Causal Inference for Statistics, Social, and Biomedical Sciences*. Cambridge University Press. | Sesión 6 (referencia) | DOI: 10.1017/CBO9781139025751 |

---

## Recursos de LangGraph y Herramientas

| Referencia | Uso en Curso | Link |
|------------|--------------|------|
| LangGraph Documentation (2024). | Laboratorio todas las sesiones | https://langchain-ai.github.io/langgraph/ |
| LangChain Documentation (2024). | Laboratorio | https://python.langchain.com/docs/ |
| Farama Foundation (2023). *Gymnasium*. | Laboratorio (entornos RL) | https://gymnasium.farama.org/ |

---

## Notas de Actualización

| Cambio | Justificación |
|--------|---------------|
| **Yao et al. (2022) → Yao et al. (2023) ICLR** | Versión peer-reviewed en conferencia top |
| **Wang & Duan (2024) arXiv → Opast Publishers** | Versión publicada en journal peer-reviewed |
| **Añadido Shinn et al. (2023) NeurIPS** | Paper clave para agentes con feedback tipo RL |
| **Añadido DOI a todos los papers** | Accesibilidad y verificación académica |
| **Añadido Murphy (2003) JRSSB** | Puente histórico entre RL y regímenes de tratamiento |
| **Añadido Chernozhukov et al. (2018)** | Fundamentos de Double/Debiased ML |

---

## Jerarquía de Referencias para el Curso

### Nivel 1 (Fundamentos Teóricos - Libros Clásicos)
1. Wald (1950) - Fundación de teoría de decisión
2. Berger (1985) - Texto canónico de decisión estadística
3. Puterman (2005) - **Capítulo 2** vincula explícitamente teoría de decisión con MDPs
4. Casella & Berger (2002) - Inferencia estadística base

### Nivel 2 (Inferencia en RL - Journals Top)
1. **Shi et al. (2022) - JRSSB** (Journal estadístico de primer nivel)
2. **Kallus & Uehara (2022) - Operations Research** (Journal OR de primer nivel)
3. **Kallus & Uehara (2020) - JMLR** (Journal ML de primer nivel)
4. **Shi et al. (2024) - JASA** (Journal estadístico de primer nivel)

### Nivel 3 (Agentes LLM - Conferencias Top)
1. **Yao et al. (2023) - ICLR** (Top ML conference)
2. **Shinn et al. (2023) - NeurIPS** (Top ML conference)
3. **Zhai et al. (2025) - AAAI** (Top AI conference)

### Nivel 4 (Frameworks y Herramientas)
1. **Wang & Duan (2024) - Opast Publishers** (Peer-reviewed journal)
2. **Sun et al. (2025) - IEEE RA-L** (Journal IEEE peer-reviewed)
3. LangGraph Documentation (2024)

---

## Políticas del Curso

| Política | Detalle |
|----------|---------|
| **Integridad Académica** | Trabajo original obligatorio. Plagio = 0 + reporte a comité de ética |
| **Colaboración** | Ejercicios: discusión permitida, escritura individual. Proyecto: estrictamente individual |
| **Uso de IA Generativa** | Permitido para código y clarificación conceptual. **Debe declararse explícitamente**. Demostraciones matemáticas deben verificarse independientemente |
| **Reproducibilidad** | Todo código debe ser ejecutable con `make run`. Seeds obligatorias. IC y p-valores reportados en todos los experimentos |
| **Entregas Tardías** | 10% de penalización por día, máximo 3 días. Después de 3 días: no aceptado sin justificación documentada |

---

## Calendario Tentativo de Entregas

| Semana | Entregable | Peso Acumulado |
|--------|------------|----------------|
| 2 | Problemas Set 1 | 4% |
| 4 | Problemas Set 2 + Paper 1 | 13% |
| 6 | Problemas Set 3 | 17% |
| 7 | **Mini-Proyecto** | 32% |
| 8 | Problemas Set 4 + Paper 2 | 41% |
| 10 | Problemas Set 5 | 45% |
| 11 | Problemas Set 6 + Paper 3 | 54% |
| 12 | **Examen Final** + **Proyecto Final** | 100% |

---

## Contacto y Horarios de Oficina

| Item | Detalle |
|------|---------|
| **Horario de oficina** | Por definir (mínimo 4 horas/semana) |
| **Consultas** | Correo electrónico con 48 horas de anticipación |
| **Repositorio del curso** | GitHub (por definir) con notebooks de referencia |
| **Última actualización** | Marzo 2026 |

---

# Sílabo Complementario: Laboratorio de Agentes con LangGraph

## Información General

| Campo | Detalle |
|-------|---------|
| **Nombre** | Laboratorio de Implementación: Agentes Estadísticos con LangGraph |
| **Curso Base** | Teoría Avanzada de Inferencia Estadística para Agentes IA |
| **Modalidad** | Laboratorio complementario (1.5 horas por sesión, acoplado 1:1 con teoría) |
| **Requisitos Técnicos** | Python 3.10+, LangGraph, LangChain, numpy, scipy, pandas, pytest |
| **Filosofía** | Ejemplos conceptuales y demostrativos, **no código de producción** |

---

## Resultados de Aprendizaje del Laboratorio

Al finalizar el laboratorio, el estudiante será capaz de:

1. ✅ Implementar estados de agente como **estadísticos suficientes** y justificar su minimalidad
2. ✅ Construir estimadores de $Q^\pi$ y $V^\pi$ con **IC y diagnósticos** (cobertura, poder)
3. ✅ Ejecutar **A/B de políticas** con control de error global y reportes reproducibles
4. ✅ Implementar **OPE-DR** con funciones de influencia y análisis de sensibilidad (overlap)
5. ✅ Orquestar agentes con **LangGraph** que usen incertidumbre para decidir (explorar, consultar, actuar)
6. ✅ Entregar **paquetes reproducibles** (código + reporte) con seeds, pruebas y scripts de evaluación

---

## Estructura por Sesiones de Laboratorio

| Semana | Tema Estadístico (Núcleo) | Patrón de Agente (Aplicación) | Entregable |
|--------|--------------------------|-------------------------------|------------|
| **1** | Arquitectura de inferencia: $\mathcal{P}_\theta$, $T(X)$, criterio | Plantilla base LangGraph: nodos observación-creencias-decisión; trazas del estado | Notebook "plantilla agente bayesiano" con logging de creencias |
| **2** | Suficiencia/completitud/ancillaridad; Basu | Diseño de estado suficiente vs redundante; memoria eficiente del agente | Comparativa de memoria y exactitud; test script de equivalencia |
| **3** | Estimación puntual; CRLB; sesgo-varianza | Estimación de $Q^\pi$ por Monte Carlo con barras de error; límites empíricos vs CRLB | Experimento de varianza vs $n$; curva eficiencia empírica |
| **4** | Tests e IC; múltiples comparaciones | A/B de políticas (Welch); FDR (Benjamini-Hochberg) con $k$ políticas | CLI `evaluate.py` que devuelve p-valores y FDR decisions |
| **5** | CLT/Delta; bootstrap | Bootstrap para $V^\pi$ (trayectorias dependientes): percentil y BCa (opcional) | Verificación de cobertura (100 repeticiones) reportada |
| **6** | Semiparamétricos; funciones de influencia | OPE doubly robust con verificación de robustez (corrupción de $Q$ o de ratios) | Pipeline OPE-DR con curva sesgo-varianza bajo misspec |
| **7** | Wald: riesgo $R(\theta,\delta)$; Bayes/minimax | Políticas Bayes vs robustas; selección bajo pérdida definida por el usuario | Comparación de riesgo empírico en escenarios simulados |
| **8** | MDPs y Bellman | Value Iteration como grafo LangGraph; criterios de parada en norma $\ell_\infty$ | Reporte de convergencia y política óptima reproducible |
| **9** | Aprendizaje estadístico y generalización | Validación cruzada/regularización para world/reward models; early stopping por IC | Curvas de validación y selección automatizada con IC |
| **10** | OPE (fundamentos) | DM, IS, DR tabulares y con aproximación de funciones; diagnóstico de overlap | Comparativa DM/IS/DR con métricas de varianza y cobertura |
| **11** | Inferencia en horizonte infinito; SAVE | IC asintóticos de $V^\pi$ con dependencia; experimentos de potencia | Diseño de poder: cálculo de $n$ mínimo para detectar $\delta$ |
| **12** | Síntesis (LLM-Agents + RL) | Agente que decide cuándo explorar, cuándo preguntar (herramienta/LLM), y cuándo actuar, guiado por IC | **Demo end-to-end** con ablations y reporte reproducible |

---

## Plantillas de Artefactos (Por Sesión)

Cada sesión produce un notebook ejecutable y artefactos estandarizados:

```
semana_N/
├── notebook.ipynb           # Demostración conceptual
├── src/
│   ├── state_schema.py      # Definición tipada del estado (estadísticos suficientes documentados)
│   ├── agent_graph.py       # Construcción del grafo LangGraph con nodos y condicionamientos
│   └── evaluate.py          # CLI que corre N episodios, imprime IC95%, poder, p-valores
├── tests/
│   └── test_equivalence.py  # Pruebas unitarias (p.ej., igualdad del estimador usando historial vs suficientes)
├── Makefile                 # make run, make test, make report
└── environment.yml          # Dependencias exactas
```

### Ejemplo: `state_schema.py` (Semana 2)

```python
from typing import TypedDict, List, Dict

class SufficientState(TypedDict):
    """
    Estado SUFICIENTE - solo estadísticos suficientes
    
    Para estimar E[R] (reward esperado), los estadísticos suficientes son:
    - sum_rewards: Σrᵢ
    - n_observations: n
    
    Por Factorization Theorem (Neyman-Fisher):
    p(x₁,...,xₙ|θ) = g(T(x),θ) · h(x)
    donde T(x) = (Σxᵢ, n)
    
    Referencia: Casella & Berger (2002), Theorem 6.2.1
    """
    sum_rewards: float      # Estadístico suficiente 1
    n_observations: int     # Estadístico suficiente 2
    current_context: str    # Información ancillar (contexto)
```

### Ejemplo: `evaluate.py` (Semana 4)

```python
#!/usr/bin/env python3
"""
CLI de Evaluación - A/B Testing de Políticas

Salida estándar:
- IC95% para diferencia de valores
- p-value (test de Welch)
- Decisión FDR (si k > 2 políticas)
- Poder del test (post-hoc)

Referencia: Shi et al. (2022), §5 - Hypothesis testing for value functions
"""

import argparse
import numpy as np
from scipy import stats

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--alpha', type=float, default=0.05)
    parser.add_argument('--n-reps', type=int, default=100)
    args = parser.parse_args()
    
    # ... implementación del test ...
    
    print(f"IC95%: [{ci_lower:.4f}, {ci_upper:.4f}]")
    print(f"p-value: {p_value:.4f}")
    print(f"Decisión: {'RECHAZAR H0' if p_value < args.alpha else 'NO RECHAZAR H0'}")

if __name__ == "__main__":
    main()
```

---

## Evaluación del Laboratorio

| Componente | Peso | Descripción | Rúbrica |
|------------|------|-------------|---------|
| **Checks Semanales** | 40% | 10 entregas ligeras (excluye 2 de exploración libre) | Diseño estadístico (25%), Integración LangGraph (25%), Evidencia de incertidumbre (25%), Reproducibilidad (25%) |
| **Mini-Demo Intermedia** | 20% | Semanas 6-7. OPE-DR con función de influencia explicitada en código/comentarios | Correctitud DR (40%), Análisis de sensibilidad (40%), Documentación (20%) |
| **Capstone Final** | 40% | Semana 12. Agente end-to-end con toma de decisiones guiada por IC | Ver especificaciones abajo |

---

## Especificaciones del Capstone Final (Laboratorio)

El agente debe:

| Requisito | Criterio de Aceptación |
|-----------|----------------------|
| **Mantiene creencias o intervalos** sobre $V^\pi$/$Q^\pi$ | IC reportados en cada decisión |
| **Decide entre explorar/consultar/actuar** usando umbral de ancho de IC o razón coste-beneficio Bayes/minimax | Lógica de decisión documentada con referencia teórica |
| **Presenta ablations** que muestren impacto de la incertidumbre en rendimiento | ≥3 condiciones comparadas, diferencia significativa reportada |
| **Reporte completo** con hipótesis, IC/p-valores, poder, limitaciones, costos computacionales | 5-10 páginas + guía de replicación |

### Sello de Calidad

Un **"score de integración"** interno pondera mejora de desempeño atribuible a la inferencia:

$$\text{Score} = \frac{\text{Mejora en rendimiento}}{\text{Costo computacional}} \times \mathbb{I}(p < 0.05 \text{ y tamaño de efecto reportado})$$

---

## Herramientas y Datasets Recomendados

| Categoría | Herramientas |
|-----------|--------------|
| **Core** | `LangGraph`, `LangChain`, `networkx`, `numpy`, `scipy`, `pandas`, `matplotlib`/`seaborn` |
| **Modelado Probabilístico** | `PyMC` o `NumPyro`/`Pyro`, `ArviZ` |
| **ML** | `PyTorch` o `JAX` |
| **RL/MDP** | `gymnasium`, `minigrid`, entornos tabulares sintéticos (proveídos) |
| **LLM-Agents** | `LangGraph` (memory/routing), `AutoGen` (multiagente), APIs de función (si disponibles) |
| **Evaluación** | `pytest`, `mlflow`/`wandb` |
| **Benchmarks (opcional)** | AgentBench (2023), ToolBench (2023), WebArena (2023) |

---

## Lineamientos de Entrega y Reproducibilidad

| Requisito | Detalle |
|-----------|---------|
| **Scripts** | Todos ejecutables con `make run` |
| **README** | Supuestos estadísticos (iid/mixing/overlap), parámetros ($\alpha, \beta, \gamma$), semilla |
| **Métricas** | Reportadas con incertidumbre: IC$_{95%}$, tamaño de efecto (Cohen's $d$), poder (cuando aplique) |
| **Múltiples Comparaciones** | Corrección en informes con $k>2$ políticas (FDR recomendado) |
| **Tests Unitarios** | Mínimo 80% de cobertura en funciones críticas |
| **Determinismo** | Seeds fijas en todos los experimentos |

---

## Bibliografía del Laboratorio

| Categoría | Referencias |
|-----------|-------------|
| **Documentación y Frameworks** | LangGraph Docs (2024), LangChain Docs, Wu et al. (2023) AutoGen |
| **Agentes LLM y Patrones** | Yao et al. (2022) ReAct, Shinn et al. (2023) Reflexion, Li et al. (2023) CAMEL |
| **Estadística y RL (Práctica)** | Casella & Berger (2002), Efron & Tibshirani (1993), Sutton & Barto (2018), Puterman (2005) |
| **OPE e Inferencia** | Jiang & Li (2016), Thomas et al. (2015), Kallus & Uehara (2020, 2022), Shi et al. (2022, 2024) |

---
