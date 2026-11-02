# CSE — Resolución 2026-09-30

**Fecha:** 2026-09-30 · **Tarea:** Mié 30 T1 (A) — resolver filas `CONDICIONES SIN ESPECIFICAR`.

**Regla AUTONOMIA 2026-09-30:** proponer Condiciones **solo** si el teorema/definición citado (`thm:`/`def:`/`cor:`) **enumera** hipótesis en el manuscrito; copiar formulación breve. Si duda o no hay label/enunciado usable → dejar literal `CONDICIONES SIN ESPECIFICAR`. Nunca inventar.

**Fuente de filas:** `LISTA_UNICA_TABLAS_TRAZABILIDAD_2026-09-29.md` (98 filas).

---

## Resumen

| Métrica | Valor |
|---|---|
| Filas totales | 98 |
| Ya tenían condiciones (ch1–ch3) | 18 |
| CSE en lista del 29 | 80 |
| **Propuestas** desde texto del libro (T1) | **31** |
| **CSE que siguen** (sin evidencia textual usable) | **49** |
| CSE resueltas de las 80 | 31 |

Las 18 filas de `tab:ch1|ch2|ch3-trazabilidad` con condiciones llenas se marcan `ya-tenía` (no se reescriben).

---

## Tabla de resolución

| ID | Origen | Resultado | Condición propuesta o CSE | Fuente (label/archivo:línea) | Estado |
|---|---|---|---|---|---|
| 1 | `tab:ch1-nodos-diagnostico-b` | Estado (alpha, beta) | Familia exponencial; T estadístico natural suficiente para eta | `thm:ch1-suficiencia-natural` · capitulos/cap04_herramientas.typ:478 | propuesta |
| 2 | `tab:ch1-nodos-diagnostico-b` | Actualización (alpha, beta) | Prior conjugado a la verosimilitud (uso en familia exponencial) | `def:ch1-conjugada` · capitulos/cap04_herramientas.typ:525 | propuesta |
| 3 | `tab:ch1-nodos-diagnostico-b` | Cálculo de sigma_"post" | Momentos segundos finitos | `def:ch1-varianza-ecm` · capitulos/cap04_herramientas.typ:284 | propuesta |
| 4 | `tab:ch1-nodos-diagnostico-b` | Decisión sigma_"post" < epsilon.alt? | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 5 | `tab:ch1-nodos-diagnostico-b` | Función de pérdida Loss(theta, a) | Loss medible; Risk = EE_theta(Loss) | `def:ch1-perdida-riesgo` · capitulos/cap04_herramientas.typ:343 | propuesta |
| 6 | `tab:ch1-nodos-diagnostico-b` | Regla de decisión delta(x) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 7 | `tab:ch1-nodos-diagnostico-b` | Consulta al médico | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 8 | `tab:ch1-nodos-diagnostico-b` | Retroceso a (A) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 9 | `tab:ch1-nodos-diagnostico-b` | Registrar confianza | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 10 | `tab:ch1-trazabilidad` | Modelo cal(P)_theta (def:ch1-modelo-parametrico) | Identificabilidad, regularidad | `def:ch1-modelo-parametrico` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 11 | `tab:ch1-trazabilidad` | Estadístico T(X) (def:ch1-estadistico) | Medibilidad, suficiencia | `def:ch1-estadistico` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 12 | `tab:ch1-trazabilidad` | Criterio de optimalidad cal(C) | Convexidad, continuidad | LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 13 | `tab:ch1-trazabilidad` | Forma canónica exponencial (def:ch1-familia-exponencial) | Espacio de parámetros naturales abierto, regularidad | `def:ch1-familia-exponencial` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 14 | `tab:ch1-trazabilidad` | Propiedades de A(eta) (thm:ch1-logparticion) | A dos veces diferenciable, convexa | `thm:ch1-logparticion` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 15 | `tab:ch1-trazabilidad` | Suficiencia de T (thm:ch1-suficiencia-natural) | Completitud, suficiencia minimal | `thm:ch1-suficiencia-natural` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 16 | `tab:ch1-trazabilidad` | Descomposición sesgo-varianza (def:ch1-varianza-ecm) | Momentos segundos finitos | `def:ch1-varianza-ecm` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 17 | `tab:ch2-trazabilidad` | Neyman-Fisher (thm:ch2-neyman-fisher) | Factorización verificable | `thm:ch2-neyman-fisher` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 18 | `tab:ch2-trazabilidad` | Suficiencia minimal (thm:ch2-lehmann-scheffe) | Unicidad bajo completitud | `thm:ch2-lehmann-scheffe` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 19 | `tab:ch2-trazabilidad` | Completitud (thm:ch2-completitud-exponencial) | Familia exponencial | `thm:ch2-completitud-exponencial` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 20 | `tab:ch2-trazabilidad` | Teorema de Basu (thm:ch2-basu) | Suficiencia + ancillaridad | `thm:ch2-basu` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 21 | `tab:ch2-trazabilidad` | Equivarianza (thm:ch2-equivarianza) | Grupo de transformaciones invariante | `thm:ch2-equivarianza` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 22 | `tab:ch2-trazabilidad` | prop:ch2-suficiencia-politicas | Suficiencia del estadístico, política determinista | `prop:ch2-suficiencia-politicas` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 23 | `tab:ch3-trazabilidad` | Rao-Blackwell (thm:ch3-rao-blackwell) | Suficiencia del estadístico | `thm:ch3-rao-blackwell` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 24 | `tab:ch3-trazabilidad` | Lehmann-Scheffé (thm:ch3-lehmann-scheffe) | Completitud + suficiencia | `thm:ch3-lehmann-scheffe` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 25 | `tab:ch3-trazabilidad` | Cramér-Rao (thm:ch3-cramer-rao) | Regularidad, información de Fisher finita | `thm:ch3-cramer-rao` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 26 | `tab:ch3-trazabilidad` | Descomp. sesgo-varianza | Momentos segundos finitos | LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 27 | `tab:ch3-trazabilidad` | Propiedades MLE (thm:ch3-mle-propiedades) | Regularidad de Cramér | `thm:ch3-mle-propiedades` · LISTA_UNICA (columna Condiciones ch1–ch3) | ya-tenía |
| 28 | `tab:ch4-trazabilidad` | Neyman-Pearson (thm:ch4-neyman-pearson) | H0 vs H1 simples; nivel alpha; densidades f(·\|theta_0), f(·\|theta_1) | `thm:ch4-neyman-pearson` · capitulos/cap04_herramientas.typ:1542 | propuesta |
| 29 | `tab:ch4-trazabilidad` | Test UMP (thm:ch4-mlr) | Familia con MLR en T(X); H0: theta<=theta_0 vs H1: theta>theta_0; nivel alpha | `thm:ch4-mlr` · capitulos/cap04_herramientas.typ:1606 | propuesta |
| 30 | `tab:ch4-trazabilidad` | Dualidad Test-IC (thm:ch4-inversion) | Familia de tests de nivel alpha para H0: theta=theta_0; C(X)={theta_0: phi=0} | `thm:ch4-inversion` · capitulos/cap04_herramientas.typ:1665 | propuesta |
| 31 | `tab:ch4-trazabilidad` | Bonferroni/Holm (thm:ch4-bonferroni, thm:ch4-holm) | m tests; rechazar si p_i <= alpha/m; control FWER <= alpha | `thm:ch4-bonferroni` · capitulos/cap04_herramientas.typ:1711 | propuesta |
| 32 | `tab:ch4-trazabilidad` | Benjamini-Hochberg (thm:ch4-bh) | p-valores ordenados; independencia o PRDS; control FDR <= alpha | `thm:ch4-bh` · capitulos/cap04_herramientas.typ:1763 | propuesta |
| 33 | `tab:ch4-trazabilidad` | Función de potencia (def:ch4-potencia) | CONDICIONES SIN ESPECIFICAR | `def:ch4-potencia` · capitulos/cap04_herramientas.typ:1524 | CSE |
| 34 | `tab:ch5-trazabilidad` | CLT (thm:ch5-clt) | Xi iid; EE(Xi)=mu; Var(Xi)=sigma^2 < infinity | `thm:ch5-clt` · capitulos/cap04_herramientas.typ:1789 | propuesta |
| 35 | `tab:ch5-trazabilidad` | Delta Method (thm:ch5-delta) | sqrt(n)(T_n - theta) ->d N(0, sigma^2); g diferenciable en theta con g'(theta) != 0 | `thm:ch5-delta` · capitulos/cap04_herramientas.typ:1850 | propuesta |
| 36 | `tab:ch5-trazabilidad` | Glivenko-Cantelli (thm:ch5-gc) | Muestra iid de F; \|\|Fhat_n - F\|\|_infinity -> 0 c.s. | `thm:ch5-gc` · capitulos/cap04_herramientas.typ:1938 | propuesta |
| 37 | `tab:ch5-trazabilidad` | Donsker (thm:ch5-donsker) | Xi iid con distribucion F; proceso empirico -> puente browniano | `thm:ch5-donsker` · capitulos/cap04_herramientas.typ:1978 | propuesta |
| 38 | `tab:ch5-trazabilidad` | Bootstrap consistente (thm:ch5-bootstrap-media) | Xi iid; EE=mu; Var=sigma^2 < infinity; media bootstrap | `thm:ch5-bootstrap-media` · capitulos/cap04_herramientas.typ:2023 | propuesta |
| 39 | `tab:ch5-trazabilidad` | IC Percentil-t (def:ch5-ic-t) | CONDICIONES SIN ESPECIFICAR | `def:ch5-ic-t` · capitulos/cap04_herramientas.typ:2051 | CSE |
| 40 | `tab:ch6-trazabilidad` | Modelo semiparamétrico | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 41 | `tab:ch6-trazabilidad` | Espacio tangente nuisance | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 42 | `tab:ch6-trazabilidad` | IF eficiente (thm:ch6-kallus) | MDP horizonte infinito; regularidad (mixing, overlap); IF eficiente para Value^pi | `thm:ch6-kallus` · capitulos/cap04_herramientas.typ:2544 | propuesta |
| 43 | `tab:ch6-trazabilidad` | Cota de eficiencia (thm:ch6-cota) | Estimador RAL; cota Var(phi_hat) >= \|\|phi^*\|\|^2_{L^2(P)} | `thm:ch6-cota` · capitulos/cap04_herramientas.typ:2417 | propuesta |
| 44 | `tab:ch6-trazabilidad` | Ortogonalidad de Neyman | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 45 | `tab:ch6-trazabilidad` | Doble robustez (thm:ch6-dr) | Ortogonalidad de Neyman; \|\|ghat - g_0\|\|_{L^2} = o_P(n^(-1/4)) | `thm:ch6-dr` · capitulos/cap04_herramientas.typ:2504 | propuesta |
| 46 | `tab:ch6-trazabilidad` | DML (thm:ch6-dml) | Ortogonalidad de Neyman; regularidad; \|\|ghat - g_0\|\|_{L^2} = o_P(n^(-1/4)) | `thm:ch6-dml` · capitulos/cap04_herramientas.typ:2644 | propuesta |
| 47 | `tab:ch12-trazabilidad` | UMVUE (Lehmann-Scheffé) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 48 | `tab:ch12-trazabilidad` | Riesgo minimax (Wald) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 49 | `tab:ch12-trazabilidad` | IF eficiente (Neyman) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 50 | `tab:ch12-trazabilidad` | Teorema de Shi et al. (2022) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 51 | `tab:ch12-trazabilidad` | Incrustación fiel Wald→MDP | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 52 | `tab:ch12-trazabilidad` | Value Iteration | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 53 | `tab:ch12-trazabilidad` | Neyman-Pearson | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 54 | `tab:ch12-trazabilidad` | CLT + Delta Method | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 55 | `tab:app-trazabilidad` | Caracterización de familias exponenciales | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 56 | `tab:app-trazabilidad` | Factorización de Neyman-Fisher | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 57 | `tab:app-trazabilidad` | Rao-Blackwell | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 58 | `tab:app-trazabilidad` | Lehmann-Scheffé | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 59 | `tab:app-trazabilidad` | Cramér-Rao | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 60 | `tab:app-trazabilidad` | Neyman-Pearson | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 61 | `tab:app-trazabilidad` | Benjamini-Hochberg | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 62 | `tab:app-trazabilidad` | CLT funcional (Donsker) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 63 | `tab:app-trazabilidad` | Ortogonalidad de Neyman | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 64 | `tab:app-trazabilidad` | Teorema de clase completa (Wald) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 65 | `tab:app-trazabilidad` | Admisibilidad de Bayes | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 66 | `tab:app-trazabilidad` | Contracción de Bellman | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 67 | `tab:app-trazabilidad` | Teorema de política óptima | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 68 | `tab:app-trazabilidad` | Incrustación fiel Wald→MDP | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 69 | `tab:app-trazabilidad` | Eficiencia de IPW | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 70 | `tab:app-trazabilidad` | Robustez doble (DR) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 71 | `tab:app-trazabilidad` | IF eficiente para V^pi | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 72 | `tab:app-trazabilidad` | Shi et al. IC válidos | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 73 | `tab:app-trazabilidad` | DML (Chernozhukov) | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 74 | `tab:ch7-trazabilidad` | Problema de Wald (def:ch7-problema) | CONDICIONES SIN ESPECIFICAR | `def:ch7-problema` · capitulos/cap02_wald.typ:89 | CSE |
| 75 | `tab:ch7-trazabilidad` | Función de riesgo (def:ch1-perdida-riesgo) | Loss medible; Risk = EE_theta(Loss) | `def:ch1-perdida-riesgo` · capitulos/cap04_herramientas.typ:343 | propuesta |
| 76 | `tab:ch7-trazabilidad` | Regla de Bayes (thm:ch7-bayes) | Prior pi; regla de Bayes minimiza perdida posterior esperada | `thm:ch7-bayes` · capitulos/cap02_wald.typ:179 | propuesta |
| 77 | `tab:ch7-trazabilidad` | Regla minimax (thm:ch7-minimax-bayes) | Regla de Bayes con riesgo constante en el soporte de pi => minimax | `thm:ch7-minimax-bayes` · capitulos/cap02_wald.typ:261 | propuesta |
| 78 | `tab:ch7-trazabilidad` | Admisibilidad (def:ch7-admisibilidad) | CONDICIONES SIN ESPECIFICAR | `def:ch7-admisibilidad` · capitulos/cap02_wald.typ:143 | CSE |
| 79 | `tab:ch7-trazabilidad` | Complete-class (thm:ch7-complete-class) | Compacidad ParamSpace; continuidad Risk; convexidad D; admisibles = limite Bayes | `thm:ch7-complete-class` · capitulos/cap02_wald.typ:239 | propuesta |
| 80 | `tab:ch7-trazabilidad` | Isomorfismo (Nota~thm:ch7-isomorfismo, anticipo informal) | CONDICIONES SIN ESPECIFICAR | `thm:ch7-isomorfismo` · capitulos/cap05_incrustacion.typ:360 | CSE |
| 81 | `tab:ch8-trazabilidad` | MDP (def:ch8-mdp) | CONDICIONES SIN ESPECIFICAR | `def:ch8-mdp` · capitulos/cap03_mdp.typ:84 | CSE |
| 82 | `tab:ch8-trazabilidad` | Ecuación de Bellman (thm:ch8-bellman-opt) | CONDICIONES SIN ESPECIFICAR | `thm:ch8-bellman-opt` · capitulos/cap03_mdp.typ:157 | CSE |
| 83 | `tab:ch8-trazabilidad` | Contracción (thm:ch8-contraccion) | Operadores Bellman^pi y Bellman^*; factor de contraccion discount | `thm:ch8-contraccion` · capitulos/cap03_mdp.typ:178 | propuesta |
| 84 | `tab:ch8-trazabilidad` | Value Iteration (thm:ch8-vi-conv) | Value Iteration; convergencia geometrica con factor discount | `thm:ch8-vi-conv` · capitulos/cap03_mdp.typ:206 | propuesta |
| 85 | `tab:ch8-trazabilidad` | Policy Iteration (thm:ch8-mejora) | Si pi_(k+1) != pi_k entonces Value^(pi_(k+1)) >= Value^(pi_k) (mejora monotona) | `thm:ch8-mejora` · capitulos/cap03_mdp.typ:229 | propuesta |
| 86 | `tab:ch8-trazabilidad` | Criterio de parada (cor:ch8-parada) | Si \|\|Value_(k+1)-Value_k\|\|_infinity <= epsilon.alt (1-discount)/(2 discount) entonc… | `cor:ch8-parada` · capitulos/cap03_mdp.typ:214 | propuesta |
| 87 | `tab:ch9-trazabilidad` | Isomorfismo (thm:ch9-isomorfismo) | Estados finitos/numerables; acciones finitas; perdida acotada; MDP_1 determinista un pa… | `thm:ch9-isomorfismo` · capitulos/cap05_incrustacion.typ:98 | propuesta |
| 88 | `tab:ch9-trazabilidad` | Risk isoto -Value | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 89 | `tab:ch9-trazabilidad` | Admisibilidad isoto Pareto | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 90 | `tab:ch9-trazabilidad` | Suficiencia arrow.r Estado | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 91 | `tab:ch9-trazabilidad` | IC para theta arrow.r IC para Value | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 92 | `tab:ch9-trazabilidad` | Test arrow.r Comparación | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 93 | `tab:ch11-trazabilidad` | Shi et al. (thm:ch11-shi) | MA + CMIA; A1-A3 (Holder, invariante, Sigma_pi); diseno sieve L; TLC martingala | `thm:ch11-shi` · capitulos/cap08_intervalos.typ:218 | propuesta |
| 94 | `tab:ch11-trazabilidad` | CLT mixing (thm:ch11-clt-mixing) | Estacionario alpha-mixing; EE=0; momento 2+delta; sumabilidad alpha(k); varianza largo … | `thm:ch11-clt-mixing` · capitulos/cap08_intervalos.typ:201 | propuesta |
| 95 | `tab:ch11-trazabilidad` | Varianza HAC (def:ch11-hac) | Definicion HAC Newey-West; K_n = O(n^(1/3)) | `def:ch11-hac` · capitulos/cap08_intervalos.typ:254 | propuesta |
| 96 | `tab:ch11-trazabilidad` | IF eficiente | CONDICIONES SIN ESPECIFICAR | — | CSE |
| 97 | `tab:ch11-trazabilidad` | SAVE (def:ch11-save) | CONDICIONES SIN ESPECIFICAR | `def:ch11-save` · capitulos/cap08_intervalos.typ:278 | CSE |
| 98 | `tab:ch11-trazabilidad` | Tamaño de muestra (thm:ch11-n) | Nivel alpha, poder 1-beta, efecto delta, sigma; n >= ((z_(1-alpha/2)+z_(1-beta))/(delta… | `thm:ch11-n` · capitulos/cap08_intervalos.typ:322 | propuesta |

---

## Notas de método

1. Labels tomados del campo Resultado/Garantía/Componente de la lista única.
2. Hipótesis copiadas/comprimidas desde el cuerpo `#thm-env` correspondiente; no se usó literatura externa.
3. Filas sin label (p.ej. «Modelo semiparamétrico», «Espacio tangente nuisance», nodos-b sin thm operable, filas app/ch12 genéricas) → CSE.
4. `thm:ch7-isomorfismo` es anticipo informal → CSE (alcance formal en `thm:ch9-isomorfismo`).
5. Definiciones puras sin lista de hipótesis (`def:ch4-potencia`, `def:ch5-ic-t`, `def:ch7-admisibilidad`, `def:ch8-mdp`, `def:ch11-save`) → CSE; dominio operable explícito sí se propuso (`def:ch1-conjugada`, `def:ch1-varianza-ecm`, `def:ch1-perdida-riesgo`, `def:ch11-hac`).
6. Esta resolución alimenta Condiciones de `tab:trazabilidad-canonica` (T2). Estado ↔/↝ de la canónica = `—` (default AUTONOMIA).
