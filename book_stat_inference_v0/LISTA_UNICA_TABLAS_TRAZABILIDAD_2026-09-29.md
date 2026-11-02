# Lista única — tablas de trazabilidad

**Fecha:** 2026-09-29 · **Tarea:** Mar 29 T2 (D) — volcar tablas a lista única (sin consolidar Typst canónica; eso es Mié 30).
**Fuente primaria:** `capitulos/cap09_verificacion.typ` (9 `#mi-tabla`).
**Hermanas aún fuera de cap. 9:** `tab:ch7-trazabilidad` (cap02), `tab:ch8-trazabilidad` (cap03), `tab:ch9-trazabilidad` (cap05), `tab:ch11-trazabilidad` (cap08).
**No incluido:** `tab:ch10-trazabilidad` — **no existe** en el árbol actual (cap. 7/`cap07_ope.typ` no define tabla de trazabilidad con ese patrón).

## Hallazgo de alcance («veinte tablas»)

El `#pendiente` del cap. 9 e INFORME_FASE2 hablan de **veinte** tablas superpuestas.
Inventario verificable hoy: **9 en cap09** + **4 hermanas** = **13** tablas de la familia trazabilidad/nodos-b.
La cifra «20» queda como deuda de redacción del marcador; no se inventan tablas faltantes.

## Criterios

- **duplicado:** la fila comparte ≥1 token canónico de resultado/garantía (p.ej. `lehmann-scheffe`, `shi-ic`, `doble-robustez`) con filas de **otra** tabla. Heurística por texto normalizado; no borra nada.
- **CONDICIONES SIN ESPECIFICAR:** columna Condiciones ausente, vacía, o genérica (`ver texto`, etc.). Filas con condiciones concretas en ch1–ch3 **no** llevan la marca.
- **No** se construye la tabla canónica Typst hoy; **no** se borran filas del `.typ`.

## Resumen de conteos

| Métrica | Valor |
|---|---|
| Tablas en cap09 | 9 |
| Tablas hermanas (fuera) | 4 |
| Tablas totales en esta lista | 13 |
| Filas totales | 98 |
| Filas solo cap09 | 73 |
| Filas marcadas **duplicado** | 52 |
| Grupos de duplicado (tokens) | 21 |
| Filas **CONDICIONES SIN ESPECIFICAR** | 80 |
| Filas con condiciones llenas (ch1–ch3) | 18 |

## Inventario de tablas

| # | key | archivo | filas | columnas (header) | ¿en cap09? |
|---|---|---|---|---|---|
| 1 | `tab:ch1-nodos-diagnostico-b` | `capitulos/cap09_verificacion.typ` | 9 | Componente del Agente, Operación/Decisión, Concepto Estadístico Correspondiente | sí |
| 2 | `tab:ch1-trazabilidad` | `capitulos/cap09_verificacion.typ` | 7 | Resultado Teórico, Componente del Agente, Garantía, Condiciones | sí |
| 3 | `tab:ch2-trazabilidad` | `capitulos/cap09_verificacion.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía, Condiciones | sí |
| 4 | `tab:ch3-trazabilidad` | `capitulos/cap09_verificacion.typ` | 5 | Resultado Teórico, Componente del Agente, Garantía, Condiciones | sí |
| 5 | `tab:ch4-trazabilidad` | `capitulos/cap09_verificacion.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía | sí |
| 6 | `tab:ch5-trazabilidad` | `capitulos/cap09_verificacion.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía | sí |
| 7 | `tab:ch6-trazabilidad` | `capitulos/cap09_verificacion.typ` | 7 | Resultado Teórico, Componente del Agente, Garantía | sí |
| 8 | `tab:ch12-trazabilidad` | `capitulos/cap09_verificacion.typ` | 8 | Componente, Justificación Teórica, Garantía, Referencia | sí |
| 9 | `tab:app-trazabilidad` | `capitulos/cap09_verificacion.typ` | 19 | Teorema/Resultado, Cap., Componente LangGraph, Garantía | sí |
| 10 | `tab:ch7-trazabilidad` | `capitulos/cap02_wald.typ` | 7 | Resultado Teórico, Componente del Agente, Garantía | hermana |
| 11 | `tab:ch8-trazabilidad` | `capitulos/cap03_mdp.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía | hermana |
| 12 | `tab:ch9-trazabilidad` | `capitulos/cap05_incrustacion.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía | hermana |
| 13 | `tab:ch11-trazabilidad` | `capitulos/cap08_intervalos.typ` | 6 | Resultado Teórico, Componente del Agente, Garantía | hermana |

## Lista única de filas

| ID | Origen (key) | Resultado | Componente | Garantía | Condiciones | Marcas |
|---|---|---|---|---|---|---|
| 1 | `tab:ch1-nodos-diagnostico-b` | Estado (alpha, beta) | Almacenamiento del estadístico suficiente | Estadístico suficiente minimal (thm:ch1-suficiencia-natural) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 2 | `tab:ch1-nodos-diagnostico-b` | Actualización (alpha, beta) | alpha <- alpha + x, beta <- beta + (1-x) | Actualización Bayesiana con prior conjugado (def:ch1-conjugada) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 3 | `tab:ch1-nodos-diagnostico-b` | Cálculo de sigma_"post" | sqrt((alpha beta)/((alpha+beta)^2(alpha+beta+1))) | Varianza posterior (def:ch1-varianza-ecm) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 4 | `tab:ch1-nodos-diagnostico-b` | Decisión sigma_"post" < epsilon.alt? | Bifurcación estadística basada en incertidumbre | Criterio de optimalidad con restricción de varianza | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 5 | `tab:ch1-nodos-diagnostico-b` | Función de pérdida Loss(theta, a) | Costos asimétricos c y d | Función de pérdida (def:ch1-perdida-riesgo) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 6 | `tab:ch1-nodos-diagnostico-b` | Regla de decisión delta(x) | Tratar si hat(theta) > d/(c+d) y sigma_"post" < epsilon.alt | Regla de Bayes que minimiza el riesgo | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 7 | `tab:ch1-nodos-diagnostico-b` | Consulta al médico | Bifurcación humana | Incorporación de conocimiento experto externo | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 8 | `tab:ch1-nodos-diagnostico-b` | Retroceso a (A) | Repetición de la prueba | Muestreo secuencial (paradigma mencionado en sec:ch1-incertidumbre-decision) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 9 | `tab:ch1-nodos-diagnostico-b` | Registrar confianza | Log de decisión con métricas de incertidumbre | Documentación de procedimiento y trazabilidad estadística | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 10 | `tab:ch1-trazabilidad` | Modelo cal(P)_theta (def:ch1-modelo-parametrico) | Modelo del mundo en State | Representación formal | Identificabilidad, regularidad | — |
| 11 | `tab:ch1-trazabilidad` | Estadístico T(X) (def:ch1-estadistico) | Campos del StateSchema | Compresión de datos | Medibilidad, suficiencia | — |
| 12 | `tab:ch1-trazabilidad` | Criterio de optimalidad cal(C) | Función objetivo del agente | Métrica de evaluación | Convexidad, continuidad | — |
| 13 | `tab:ch1-trazabilidad` | Forma canónica exponencial (def:ch1-familia-exponencial) | Estructura de actualización | Eficiencia computacional | Espacio de parámetros naturales abierto, regularidad | — |
| 14 | `tab:ch1-trazabilidad` | Propiedades de A(eta) (thm:ch1-logparticion) | Cálculo de momentos | Estadísticas exactas | A dos veces diferenciable, convexa | — |
| 15 | `tab:ch1-trazabilidad` | Suficiencia de T (thm:ch1-suficiencia-natural) | Estado minimal | Información completa | Completitud, suficiencia minimal | — |
| 16 | `tab:ch1-trazabilidad` | Descomposición sesgo-varianza (def:ch1-varianza-ecm) | Análisis de estimadores de V^pi | Diagnóstico de error | Momentos segundos finitos | duplicado(sesgo-varianza) |
| 17 | `tab:ch2-trazabilidad` | Neyman-Fisher (thm:ch2-neyman-fisher) | Diseño de StateSchema | Suficiencia del estado | Factorización verificable | duplicado(neyman-fisher) |
| 18 | `tab:ch2-trazabilidad` | Suficiencia minimal (thm:ch2-lehmann-scheffe) | Estado de dimensión mínima | Compresión máxima | Unicidad bajo completitud | duplicado(lehmann-scheffe) |
| 19 | `tab:ch2-trazabilidad` | Completitud (thm:ch2-completitud-exponencial) | Unicidad de representación | Sin redundancia | Familia exponencial | — |
| 20 | `tab:ch2-trazabilidad` | Teorema de Basu (thm:ch2-basu) | Separación estado/contexto | Independencia garantizada | Suficiencia + ancillaridad | — |
| 21 | `tab:ch2-trazabilidad` | Equivarianza (thm:ch2-equivarianza) | Políticas simétricas | Consistencia ante transformaciones | Grupo de transformaciones invariante | — |
| 22 | `tab:ch2-trazabilidad` | prop:ch2-suficiencia-politicas | Política basada en T | Optimalidad preservada | Suficiencia del estadístico, política determinista | — |
| 23 | `tab:ch3-trazabilidad` | Rao-Blackwell (thm:ch3-rao-blackwell) | Mejora de estimadores de Qfunc^policy | Reducción de varianza | Suficiencia del estadístico | duplicado(rao-blackwell) |
| 24 | `tab:ch3-trazabilidad` | Lehmann-Scheffé (thm:ch3-lehmann-scheffe) | Unicidad del estimador óptimo | UMVUE garantizado | Completitud + suficiencia | duplicado(lehmann-scheffe) |
| 25 | `tab:ch3-trazabilidad` | Cramér-Rao (thm:ch3-cramer-rao) | Límite inferior de incertidumbre | Cota fundamental | Regularidad, información de Fisher finita | duplicado(cramer-rao) |
| 26 | `tab:ch3-trazabilidad` | Descomp. sesgo-varianza | Análisis de estimadores de valor | Diagnóstico de error | Momentos segundos finitos | duplicado(sesgo-varianza) |
| 27 | `tab:ch3-trazabilidad` | Propiedades MLE (thm:ch3-mle-propiedades) | Estimación de parámetros del ambiente | Eficiencia asintótica | Regularidad de Cramér | — |
| 28 | `tab:ch4-trazabilidad` | Neyman-Pearson (thm:ch4-neyman-pearson) | Regla óptima para comparar 2 políticas | Máximo poder | (columna ausente) | duplicado(neyman-pearson); CONDICIONES SIN ESPECIFICAR |
| 29 | `tab:ch4-trazabilidad` | Test UMP (thm:ch4-mlr) | Detección de mejoras unilaterales | UMP garantizado | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 30 | `tab:ch4-trazabilidad` | Dualidad Test-IC (thm:ch4-inversion) | IC para diferencias de valor | Cobertura 1-alpha | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 31 | `tab:ch4-trazabilidad` | Bonferroni/Holm (thm:ch4-bonferroni, thm:ch4-holm) | Control FWER en comparaciones múltiples | Sin falsos positivos | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 32 | `tab:ch4-trazabilidad` | Benjamini-Hochberg (thm:ch4-bh) | Selección entre muchas políticas | Control FDR | (columna ausente) | duplicado(benjamini-hochberg); CONDICIONES SIN ESPECIFICAR |
| 33 | `tab:ch4-trazabilidad` | Función de potencia (def:ch4-potencia) | Evaluación de capacidad de detección | Poder cuantificado | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 34 | `tab:ch5-trazabilidad` | CLT (thm:ch5-clt) | Normalidad de estimadores de Value^policy | Base para IC | (columna ausente) | duplicado(clt); CONDICIONES SIN ESPECIFICAR |
| 35 | `tab:ch5-trazabilidad` | Delta Method (thm:ch5-delta) | Propagación de incertidumbre | Varianza derivada | (columna ausente) | duplicado(delta-method); CONDICIONES SIN ESPECIFICAR |
| 36 | `tab:ch5-trazabilidad` | Glivenko-Cantelli (thm:ch5-gc) | Consistencia de distribución de retornos | Convergencia uniforme | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 37 | `tab:ch5-trazabilidad` | Donsker (thm:ch5-donsker) | Tests no paramétricos | Proceso límite | (columna ausente) | duplicado(donsker); CONDICIONES SIN ESPECIFICAR |
| 38 | `tab:ch5-trazabilidad` | Bootstrap consistente (thm:ch5-bootstrap-media) | IC bootstrap para Value^policy | Validez asintótica | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 39 | `tab:ch5-trazabilidad` | IC Percentil-t (def:ch5-ic-t) | IC con refinamiento | Error O(n^(-1)) | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 40 | `tab:ch6-trazabilidad` | Modelo semiparamétrico | Framework OPE | Flexibilidad en nuisance | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 41 | `tab:ch6-trazabilidad` | Espacio tangente nuisance | Componentes no especificados | Separación formal | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 42 | `tab:ch6-trazabilidad` | IF eficiente (thm:ch6-kallus) | Fórmula DR para Value^policy | Eficiencia | (columna ausente) | duplicado(if-eficiente); CONDICIONES SIN ESPECIFICAR |
| 43 | `tab:ch6-trazabilidad` | Cota de eficiencia (thm:ch6-cota) | Límite inferior de varianza | Benchmark | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 44 | `tab:ch6-trazabilidad` | Ortogonalidad de Neyman | Robustez a errores de nuisance | Primer orden | (columna ausente) | duplicado(if-eficiente); CONDICIONES SIN ESPECIFICAR |
| 45 | `tab:ch6-trazabilidad` | Doble robustez (thm:ch6-dr) | Consistencia flexible | OR-garantía | (columna ausente) | duplicado(doble-robustez); CONDICIONES SIN ESPECIFICAR |
| 46 | `tab:ch6-trazabilidad` | DML (thm:ch6-dml) | Uso de ML para nuisance | Validez inferencial | (columna ausente) | duplicado(dml); CONDICIONES SIN ESPECIFICAR |
| 47 | `tab:ch12-trazabilidad` | UMVUE (Lehmann-Scheffé) | Estimador hat(theta) | Eficiencia | (columna ausente) | duplicado(lehmann-scheffe); CONDICIONES SIN ESPECIFICAR |
| 48 | `tab:ch12-trazabilidad` | Riesgo minimax (Wald) | Función de pérdida | Robustez | (columna ausente) | duplicado(minimax); CONDICIONES SIN ESPECIFICAR |
| 49 | `tab:ch12-trazabilidad` | IF eficiente (Neyman) | Estimador DR | Doble robustez | (columna ausente) | duplicado(doble-robustez,if-eficiente); CONDICIONES SIN ESPECIFICAR |
| 50 | `tab:ch12-trazabilidad` | Teorema de Shi et al. (2022) | IC para Value^pi | Cobertura asintótica | (columna ausente) | duplicado(shi-ic); CONDICIONES SIN ESPECIFICAR |
| 51 | `tab:ch12-trazabilidad` | Incrustación fiel Wald→MDP | Operador Bellman | Optimalidad | (columna ausente) | duplicado(isomorfismo); CONDICIONES SIN ESPECIFICAR |
| 52 | `tab:ch12-trazabilidad` | Value Iteration | Política pi^ | Convergencia | (columna ausente) | duplicado(value-iteration); CONDICIONES SIN ESPECIFICAR |
| 53 | `tab:ch12-trazabilidad` | Neyman-Pearson | Test de hipótesis | Nivel controlado | (columna ausente) | duplicado(neyman-pearson); CONDICIONES SIN ESPECIFICAR |
| 54 | `tab:ch12-trazabilidad` | CLT + Delta Method | Bootstrap | Validación empírica | (columna ausente) | duplicado(clt,delta-method); CONDICIONES SIN ESPECIFICAR |
| 55 | `tab:app-trazabilidad` | Caracterización de familias exponenciales | StateSchema tipado | Representación canónica | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 56 | `tab:app-trazabilidad` | Factorización de Neyman-Fisher | Diseño de State | Suficiencia del estado | (columna ausente) | duplicado(neyman-fisher); CONDICIONES SIN ESPECIFICAR |
| 57 | `tab:app-trazabilidad` | Rao-Blackwell | Agregación de estimaciones | Reducción de varianza | (columna ausente) | duplicado(rao-blackwell); CONDICIONES SIN ESPECIFICAR |
| 58 | `tab:app-trazabilidad` | Lehmann-Scheffé | Estimador único óptimo | UMVUE garantizado | (columna ausente) | duplicado(lehmann-scheffe); CONDICIONES SIN ESPECIFICAR |
| 59 | `tab:app-trazabilidad` | Cramér-Rao | Cota inferior de varianza | Benchmark de eficiencia | (columna ausente) | duplicado(cramer-rao); CONDICIONES SIN ESPECIFICAR |
| 60 | `tab:app-trazabilidad` | Neyman-Pearson | Test binario óptimo | UMP garantizado | (columna ausente) | duplicado(neyman-pearson); CONDICIONES SIN ESPECIFICAR |
| 61 | `tab:app-trazabilidad` | Benjamini-Hochberg | Selección múltiple | Control de FDR | (columna ausente) | duplicado(benjamini-hochberg); CONDICIONES SIN ESPECIFICAR |
| 62 | `tab:app-trazabilidad` | CLT funcional (Donsker) | Bootstrap para IC | Validez asintótica | (columna ausente) | duplicado(clt,donsker); CONDICIONES SIN ESPECIFICAR |
| 63 | `tab:app-trazabilidad` | Ortogonalidad de Neyman | Estimadores robustos | Insensibilidad local | (columna ausente) | duplicado(if-eficiente); CONDICIONES SIN ESPECIFICAR |
| 64 | `tab:app-trazabilidad` | Teorema de clase completa (Wald) | Restricción a políticas Bayes | Completitud | (columna ausente) | duplicado(complete-class); CONDICIONES SIN ESPECIFICAR |
| 65 | `tab:app-trazabilidad` | Admisibilidad de Bayes | Justificación Bayesiana | Optimalidad | (columna ausente) | duplicado(admisibilidad); CONDICIONES SIN ESPECIFICAR |
| 66 | `tab:app-trazabilidad` | Contracción de Bellman | apply_bellman node | Convergencia | (columna ausente) | duplicado(bellman,contraccion); CONDICIONES SIN ESPECIFICAR |
| 67 | `tab:app-trazabilidad` | Teorema de política óptima | extract_policy node | pi^ determinista | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 68 | `tab:app-trazabilidad` | Incrustación fiel Wald→MDP | Arquitectura completa | Transferencia condicional de resultados | (columna ausente) | duplicado(isomorfismo); CONDICIONES SIN ESPECIFICAR |
| 69 | `tab:app-trazabilidad` | Eficiencia de IPW | Nodo importance_weight | Insesgadez | (columna ausente) | CONDICIONES SIN ESPECIFICAR |
| 70 | `tab:app-trazabilidad` | Robustez doble (DR) | Nodo compute_dr | Consistencia parcial | (columna ausente) | duplicado(doble-robustez); CONDICIONES SIN ESPECIFICAR |
| 71 | `tab:app-trazabilidad` | IF eficiente para V^pi | influence_function.py | Eficiencia semiparam. | (columna ausente) | duplicado(if-eficiente); CONDICIONES SIN ESPECIFICAR |
| 72 | `tab:app-trazabilidad` | Shi et al. IC válidos | Nodo compute_ci | Cobertura 1-alpha | (columna ausente) | duplicado(shi-ic); CONDICIONES SIN ESPECIFICAR |
| 73 | `tab:app-trazabilidad` | DML (Chernozhukov) | Cross-fitting pipeline | Regularidad | (columna ausente) | duplicado(dml); CONDICIONES SIN ESPECIFICAR |
| 74 | `tab:ch7-trazabilidad` | Problema de Wald (def:ch7-problema) | Especificación del problema | Formalización | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 75 | `tab:ch7-trazabilidad` | Función de riesgo (def:ch1-perdida-riesgo) | Métrica de rendimiento | Evaluación | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 76 | `tab:ch7-trazabilidad` | Regla de Bayes (thm:ch7-bayes) | Política óptima bajo prior | Optimalidad Bayes | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 77 | `tab:ch7-trazabilidad` | Regla minimax (thm:ch7-minimax-bayes) | Política robusta | Peor caso | (columna ausente) | duplicado(minimax); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 78 | `tab:ch7-trazabilidad` | Admisibilidad (def:ch7-admisibilidad) | No-dominancia | Pareto | (columna ausente) | duplicado(admisibilidad); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 79 | `tab:ch7-trazabilidad` | Complete-class (thm:ch7-complete-class) | Justificación Bayes-límite | Clase completa | (columna ausente) | duplicado(complete-class); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 80 | `tab:ch7-trazabilidad` | Isomorfismo (Nota~thm:ch7-isomorfismo, anticipo informal) | Conexión con MDP | Risk isoto -Value | (columna ausente) | duplicado(isomorfismo); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 81 | `tab:ch8-trazabilidad` | MDP (def:ch8-mdp) | Modelo del problema | Formalización | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 82 | `tab:ch8-trazabilidad` | Ecuación de Bellman (thm:ch8-bellman-opt) | Recursión de planificación | Optimalidad | (columna ausente) | duplicado(bellman); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 83 | `tab:ch8-trazabilidad` | Contracción (thm:ch8-contraccion) | Convergencia del planificador | discount^k | (columna ausente) | duplicado(contraccion); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 84 | `tab:ch8-trazabilidad` | Value Iteration (thm:ch8-vi-conv) | Algoritmo de planificación | Geométrica | (columna ausente) | duplicado(value-iteration); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 85 | `tab:ch8-trazabilidad` | Policy Iteration (thm:ch8-mejora) | Mejora de políticas | Monotónica | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 86 | `tab:ch8-trazabilidad` | Criterio de parada (cor:ch8-parada) | Condición de terminación | epsilon.alt-optimalidad | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 87 | `tab:ch9-trazabilidad` | Isomorfismo (thm:ch9-isomorfismo) | Justificación de arquitectura | Formal, alcance acotado (un paso, determinista) --- ver Nota~note:ch9-extension-no-demostrada | (columna ausente) | duplicado(isomorfismo); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 88 | `tab:ch9-trazabilidad` | Risk isoto -Value | Equivalencia de objetivos | Optimalidad | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 89 | `tab:ch9-trazabilidad` | Admisibilidad isoto Pareto | No-dominancia de políticas | Eficiencia | (columna ausente) | duplicado(admisibilidad); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 90 | `tab:ch9-trazabilidad` | Suficiencia arrow.r Estado | Diseño de StateSchema | Información completa | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 91 | `tab:ch9-trazabilidad` | IC para theta arrow.r IC para Value | Cuantificación de incertidumbre | Cobertura | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 92 | `tab:ch9-trazabilidad` | Test arrow.r Comparación | Selección de políticas | Control de error | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 93 | `tab:ch11-trazabilidad` | Shi et al. (thm:ch11-shi) | Validez de IC para Value^pi | Cobertura | (columna ausente) | duplicado(shi-ic); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 94 | `tab:ch11-trazabilidad` | CLT mixing (thm:ch11-clt-mixing) | Normalidad asintótica | Justificación | (columna ausente) | duplicado(clt); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 95 | `tab:ch11-trazabilidad` | Varianza HAC (def:ch11-hac) | Estimador para dependencia | Consistencia | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 96 | `tab:ch11-trazabilidad` | IF eficiente | Fórmula de varianza óptima | Eficiencia | (columna ausente) | duplicado(if-eficiente); CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 97 | `tab:ch11-trazabilidad` | SAVE (def:ch11-save) | Corrección de sesgo | Robustez | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |
| 98 | `tab:ch11-trazabilidad` | Tamaño de muestra (thm:ch11-n) | Planificación de experimentos | Poder | (columna ausente) | CONDICIONES SIN ESPECIFICAR; fuera-cap09 |

## Grupos de duplicados (por token canónico)

### `admisibilidad` (3 apariciones)
- tab:app-trazabilidad :: Admisibilidad de Bayes
- tab:ch7-trazabilidad :: Admisibilidad (def:ch7-admisibilidad)
- tab:ch9-trazabilidad :: Admisibilidad isoto Pareto

### `bellman` (2 apariciones)
- tab:app-trazabilidad :: Contracción de Bellman
- tab:ch8-trazabilidad :: Ecuación de Bellman (thm:ch8-bellman-opt)

### `benjamini-hochberg` (2 apariciones)
- tab:app-trazabilidad :: Benjamini-Hochberg
- tab:ch4-trazabilidad :: Benjamini-Hochberg (thm:ch4-bh)

### `clt` (4 apariciones)
- tab:app-trazabilidad :: CLT funcional (Donsker)
- tab:ch11-trazabilidad :: CLT mixing (thm:ch11-clt-mixing)
- tab:ch12-trazabilidad :: CLT + Delta Method
- tab:ch5-trazabilidad :: CLT (thm:ch5-clt)

### `complete-class` (2 apariciones)
- tab:app-trazabilidad :: Teorema de clase completa (Wald)
- tab:ch7-trazabilidad :: Complete-class (thm:ch7-complete-class)

### `contraccion` (2 apariciones)
- tab:app-trazabilidad :: Contracción de Bellman
- tab:ch8-trazabilidad :: Contracción (thm:ch8-contraccion)

### `cramer-rao` (2 apariciones)
- tab:app-trazabilidad :: Cramér-Rao
- tab:ch3-trazabilidad :: Cramér-Rao (thm:ch3-cramer-rao)

### `delta-method` (2 apariciones)
- tab:ch12-trazabilidad :: CLT + Delta Method
- tab:ch5-trazabilidad :: Delta Method (thm:ch5-delta)

### `dml` (2 apariciones)
- tab:app-trazabilidad :: DML (Chernozhukov)
- tab:ch6-trazabilidad :: DML (thm:ch6-dml)

### `doble-robustez` (3 apariciones)
- tab:app-trazabilidad :: Robustez doble (DR)
- tab:ch12-trazabilidad :: IF eficiente (Neyman)
- tab:ch6-trazabilidad :: Doble robustez (thm:ch6-dr)

### `donsker` (2 apariciones)
- tab:app-trazabilidad :: CLT funcional (Donsker)
- tab:ch5-trazabilidad :: Donsker (thm:ch5-donsker)

### `if-eficiente` (6 apariciones)
- tab:app-trazabilidad :: IF eficiente para V^pi
- tab:app-trazabilidad :: Ortogonalidad de Neyman
- tab:ch11-trazabilidad :: IF eficiente
- tab:ch12-trazabilidad :: IF eficiente (Neyman)
- tab:ch6-trazabilidad :: IF eficiente (thm:ch6-kallus)
- tab:ch6-trazabilidad :: Ortogonalidad de Neyman

### `isomorfismo` (4 apariciones)
- tab:app-trazabilidad :: Incrustación fiel Wald→MDP
- tab:ch12-trazabilidad :: Incrustación fiel Wald→MDP
- tab:ch7-trazabilidad :: Isomorfismo (Nota~thm:ch7-isomorfismo, anticipo informal)
- tab:ch9-trazabilidad :: Isomorfismo (thm:ch9-isomorfismo)

### `lehmann-scheffe` (4 apariciones)
- tab:app-trazabilidad :: Lehmann-Scheffé
- tab:ch12-trazabilidad :: UMVUE (Lehmann-Scheffé)
- tab:ch2-trazabilidad :: Suficiencia minimal (thm:ch2-lehmann-scheffe)
- tab:ch3-trazabilidad :: Lehmann-Scheffé (thm:ch3-lehmann-scheffe)

### `minimax` (2 apariciones)
- tab:ch12-trazabilidad :: Riesgo minimax (Wald)
- tab:ch7-trazabilidad :: Regla minimax (thm:ch7-minimax-bayes)

### `neyman-fisher` (2 apariciones)
- tab:app-trazabilidad :: Factorización de Neyman-Fisher
- tab:ch2-trazabilidad :: Neyman-Fisher (thm:ch2-neyman-fisher)

### `neyman-pearson` (3 apariciones)
- tab:app-trazabilidad :: Neyman-Pearson
- tab:ch12-trazabilidad :: Neyman-Pearson
- tab:ch4-trazabilidad :: Neyman-Pearson (thm:ch4-neyman-pearson)

### `rao-blackwell` (2 apariciones)
- tab:app-trazabilidad :: Rao-Blackwell
- tab:ch3-trazabilidad :: Rao-Blackwell (thm:ch3-rao-blackwell)

### `sesgo-varianza` (2 apariciones)
- tab:ch1-trazabilidad :: Descomposición sesgo-varianza (def:ch1-varianza-ecm)
- tab:ch3-trazabilidad :: Descomp. sesgo-varianza

### `shi-ic` (3 apariciones)
- tab:app-trazabilidad :: Shi et al. IC válidos
- tab:ch11-trazabilidad :: Shi et al. (thm:ch11-shi)
- tab:ch12-trazabilidad :: Teorema de Shi et al. (2022)

### `value-iteration` (2 apariciones)
- tab:ch12-trazabilidad :: Value Iteration
- tab:ch8-trazabilidad :: Value Iteration (thm:ch8-vi-conv)

## Notas para Mié 30 (tabla canónica)

1. Resolver con el autor las filas CSE (tarea A del Mié 30) antes de volcar a Typst.
2. Decidir si las 4 hermanas se mueven físicamente a cap. 9 o solo se referencian.
3. El esquema de columnas propuesto está en `insumos/cap9_columnas.md` (AUTONOMIA 2026-09-29).
4. Wilks / `dem:ch4-wilks`: no aparece en estas tablas; **NO TOCAR**.

