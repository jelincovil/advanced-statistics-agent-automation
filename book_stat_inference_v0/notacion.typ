// Puerto de notacion.tex — capítulo sin numerar (chapter*) de notación y símbolos.
#import "plantilla.typ": *

#cap-sin-numero[
= Notación y símbolos
<notacion>
]

Esta lista reúne los símbolos que acompañan la lectura. Las categorías ayudan a distinguir el parámetro desconocido, los datos disponibles y la regla que actúa sobre ellos. La columna de consulta señala un capítulo donde se desarrolla el uso del símbolo; el glosario amplía estas referencias.

== Conjuntos y Espacios

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $ParamSpace$, [Espacio de parámetros (estados de la naturaleza)], [4],
  $SampleSpace$, [Espacio muestral], [4],
  $ActionSpace$, [Espacio de acciones], [4],
  $StateSpace$, [Espacio de estados (MDP)], [3],
  $ObsSpace$, [Espacio de observaciones (POMDP)], [12],
  $cal(P)_theta$, [Familia de distribuciones parametrizada por $theta$], [4],
  $DecisionSet$, [Clase de reglas de decisión; el problema completo se denota $cal(E)$], [2],
  $cal(M)$, [Proceso de Decisión de Markov (MDP) completo], [3],
  $cal(P)$, [POMDP], [12],
  $RR$ + [, ] + $RR^d$, [Números reales, espacio euclídeo $d$-dimensional], [---],
  $NN$, [Números naturales], [---],
  hl(),
)

== Funciones de Densidad y Verosimilitud

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $f_theta (x)$, [Densidad de $X$ bajo $P_theta$ (frecuentista)], [4],
  $f(x|theta)$, [Densidad de $X$ condicional a $theta$ (bayesiano)], [2],
  $p_theta (x)$, [Alternativa notacional para densidad frecuentista], [4],
  $p(x|theta)$, [Alternativa notacional para densidad bayesiana], [2],
  hl(),
)

== Funciones de Pérdida, Riesgo y Valor

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $Loss(theta, a)$, [Función de pérdida], [4],
  $Risk(theta, decrule)$, [Función de riesgo de la regla $decrule$], [2],
  $reward (s, a)$, [Función de recompensa (MDP)], [3],
  $Value^policy (s)$, [Función de valor de estado bajo política $policy$], [3],
  $Value^* (s)$, [Función de valor óptima], [3],
  $Qfunc^policy (s, a)$, [Función de valor de acción (función Q)], [3],
  $Qfunc^* (s, a)$, [Función Q óptima], [3],
  $G(tau)$, [Retorno descontado de una trayectoria $tau$], [7],
  hl(),
)

== Políticas, Reglas de Decisión y Estimadores

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $decrule$, [Regla de decisión (marco de Wald)], [2],
  $decrule^*$, [Regla de decisión óptima], [2],
  $policy$, [Política (MDP)], [3],
  $policy^*$, [Política óptima], [3],
  $behavpolicy$, [Política de comportamiento (OPE)], [7],
  $T(X)$, [Estadístico (función de los datos)], [4],
  $hat(theta)$, [Estimador del parámetro $theta$], [4],
  $hat(Value)^policy$, [Estimador de la función de valor], [7],
  $hat(Value)^"DM"$, [Estimador Direct Method], [7],
  $hat(Value)^"IS"$, [Estimador Importance Sampling], [7],
  $hat(Value)^"DR"$, [Estimador Doubly Robust], [7],
  $priordist$, [Distribución a priori (Bayes)], [2],
  hl(),
)

== Parámetros y Constantes

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $theta$, [Parámetro (estado de la naturaleza)], [4],
  $discount$, [Factor de descuento ($0 <= discount < 1$)], [3],
  $alpha$, [Nivel de significancia (tests de hipótesis)], [4],
  $beta$, [Probabilidad de error Tipo II], [4],
  $n$, [Tamaño de muestra], [4],
  $T$, [Horizonte temporal], [3],
  $eta$, [Parámetro natural (familias exponenciales)], [4],
  $A(eta)$, [Función de log-partición], [4],
  hl(),
)

== Operadores y Funciones Especiales

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $BellmanOp^policy$, [Operador de Bellman para política $policy$], [3],
  $BellmanOp^*$, [Operador de Bellman óptimo], [3],
  $P(s'|s,a)$, [Kernel de transición], [3],
  $rho_t$, [Importance ratio en tiempo $t$], [7],
  $rho_(0:T)$, [Importance ratio acumulado], [7],
  $phi^*(O)$, [Función de influencia eficiente], [4],
  $I(theta)$, [Información de Fisher], [4],
  $cal(I)(theta)$, [Matriz de información de Fisher], [4],
  hl(),
)

== Probabilidad y Esperanza

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $Prob$, [Medida de probabilidad], [---],
  $EE$, [Esperanza matemática], [---],
  $EE^policy [dot]$, [Esperanza bajo política $policy$], [3],
  $EE_theta [dot]$, [Esperanza bajo $P_theta$], [4],
  $Var(dot)$, [Varianza], [---],
  $Cov(dot, dot)$, [Covarianza], [---],
  $limits(->)^d$, [Convergencia en distribución], [4],
  $limits(->)^P$, [Convergencia en probabilidad], [4],
  $limits(->)^"a.s."$, [Convergencia casi segura], [4],
  hl(),
)

// Extra V 2026-10-11 (Dom 11): nuisance y tasas, alineado con
// @def:ch6-nuisance-rates (cap. 4) y con L6 / @thm:ch9-condiciones (cap. 6).
// Discrepancia NO resuelta (prosa no editada): L6 (cap06) escribe los nuisance
// como $hat(mu)$, $hat(rho)$; @thm:ch9-condiciones y @def:ch6-nuisance-rates,
// como $hat(Q)$, $hat(pi)_b$; la nota «producto de errores» (cap. 4) como
// $hat(m)$, $hat(e)$. Se registra la forma de @def:ch6-nuisance-rates.
#block(breakable: false)[
== Funciones Nuisance y Tasas

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $g = (hat(Qfunc), hat(behavpolicy))$, [Funciones nuisance del estimador DR (función Q y política de comportamiento estimadas)], [4],
  $g_0$, [Valor verdadero de los nuisance], [4],
  $o_P (a_n)$, [Sucesión $X_n$ con $X_n \/ a_n limits(->)^P 0$], [4],
  $o_P (n^(-1\/4))$, [Condición suficiente simétrica por auxiliar; la condición general es producto de errores $o_P(n^(-1/2))$, junto con los demás supuestos (@def:ch6-nuisance-rates)], [4],
  hl(),
)
]

== Normas y Distancias

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  hl(),
  table.header([*Símbolo*], [*Significado*], [*Consulta*]),
  hl(w: 0.6pt),
  $norm(dot)$, [Norma euclídea], [---],
  $norm(dot)_infinity$, [Norma del supremo], [3],
  $norm(dot)_2$, [Norma $L^2$], [4],
  hl(),
)

== Abreviaturas

#table(
  columns: (auto, 1fr),
  align: (left, left),
  hl(),
  table.header([*Abreviatura*], [*Significado*]),
  hl(w: 0.6pt),
  [MDP], [Markov Decision Process (Proceso de Decisión de Markov)],
  [POMDP], [Partially Observable MDP],
  [OPE], [Off-Policy Evaluation],
  [DM], [Direct Method],
  [IS], [Importance Sampling],
  [DR], [Doubly Robust],
  [UMVUE], [Uniformly Minimum Variance Unbiased Estimator],
  [UMP], [Uniformly Most Powerful],
  [UMPU], [Uniformly Most Powerful Unbiased],
  [IC], [Intervalo de Confianza],
  [CLT], [Central Limit Theorem (Teorema Central del Límite)],
  [IF], [Influence Function (Función de Influencia)],
  [FDR], [False Discovery Rate],
  [FWER], [Family-Wise Error Rate],
  [HAC], [Heteroskedasticity and Autocorrelation Consistent],
  [LLM], [Large Language Model],
  hl(),
)
