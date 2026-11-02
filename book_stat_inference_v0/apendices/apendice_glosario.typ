// Puerto de apendices/apendice_glosario.tex — Glosario de Notación.
#import "../plantilla.typ": *

= Glosario de Notación
<app:glosario>

El glosario permite recuperar un símbolo y volver al problema en el que se
utiliza. Las categorías distinguen datos, modelos, reglas y valores para
mantener visibles las diferencias que acompañan el recorrido del libro.
La columna de consulta remite al capítulo donde se desarrolla el uso indicado.

== Notación General
<sec:appB-general>

#mi-tabla(
  caption: [Notación matemática general],
  key: "tab:appB-general",
  table(
    columns: (22%, 1fr, 12%),
    align: (left, left, center),
    hl(),
    table.header([*Símbolo*], [*Descripción*], [*Consulta*]),
    hl(w: 0.6pt),
    $RR$, [Conjunto de números reales], [4],
    $RR_(gt.eq 0)$, [Conjunto de números reales no negativos], [4],
    $RR^k$, [Espacio euclídeo de dimensión $k$], [4],
    $NN$, [Conjunto de números naturales ${0,1,2,...}$], [4],
    $EE[X]$, [Esperanza matemática de la variable aleatoria $X$], [4],
    $Var(X)$, [Varianza de $X$], [4],
    $Cov(X,Y)$, [Covarianza entre $X$ e $Y$], [4],
    $X tilde P$, [$X$ sigue la distribución $P$], [4],
    $X attach(->, t: d) Y$, [Convergencia en distribución], [4],
    $X_n attach(->, t: p) X$, [Convergencia en probabilidad], [4],
    $bb(1)_A$, [Función indicadora del conjunto $A$], [4],
    $nabla f$, [Gradiente de la función $f$], [4],
    $nabla^2 f$, [Hessiano de $f$], [4],
    $partial_i f$, [Derivada parcial respecto a la variable $i$], [4],
    $Delta^(k-1)$, [Simplex $(k-1)$-dimensional], [4],
    $Gamma(alpha)$, [Función gamma], [4],
    $cal(O)(n)$, [Notación de Landau (orden de magnitud)], [4],
    hl(),
  ),
)

== Inferencia estadística
<sec:appB-inferencia>

#mi-tabla(
  caption: [Notación de inferencia estadística],
  key: "tab:appB-inferencia",
  table(
    columns: (22%, 1fr, 12%),
    align: (left, left, center),
    hl(),
    table.header([*Símbolo*], [*Descripción*], [*Consulta*]),
    hl(w: 0.6pt),
    $cal(P) = {P_theta}$, [Familia paramétrica de distribuciones], [4],
    $ParamSpace$, [Espacio de parámetros], [4],
    $theta in ParamSpace$, [Parámetro (estado de la naturaleza)], [4],
    $SampleSpace$, [Espacio muestral], [4],
    $X in SampleSpace$, [Vector de datos observados], [4],
    $T: SampleSpace -> cal(T)$, [Estadístico], [4],
    $cal(C)$, [Criterio de optimalidad], [4],
    $hat(theta)$, [Estimador de $theta$], [4],
    $hat(theta)_n$, [Estimador basado en $n$ observaciones], [4],
    $"Sesgo"_theta (hat(theta))$, [Sesgo del estimador $hat(theta)$], [4],
    $"ECM"_theta (hat(theta))$, [Error cuadrático medio], [4],
    $Loss: ParamSpace times ActionSpace -> RR$, [Función de pérdida], [4],
    $Risk(theta, decrule)$, [Riesgo de la regla de decisión $decrule$], [4],
    $decrule: SampleSpace -> ActionSpace$, [Regla de decisión], [4],
    $ActionSpace$, [Espacio de acciones], [4],
    $eta$, [Parámetro natural (familias exponenciales)], [4],
    $T(X)$, [Estadístico natural], [4],
    $A(eta)$, [Función log-partición], [4],
    $h(x)$, [Medida base], [4],
    $cal(H)$, [Espacio de parámetros naturales], [4],
    $I(theta)$, [Información de Fisher], [4],
    $L(theta; x)$, [Función de verosimilitud], [4],
    $ell (theta; x)$, [Log-verosimilitud], [4],
    $pi(theta)$, [Distribución prior], [4],
    $p(theta|x)$, [Distribución posterior], [4],
    hl(),
  ),
)

== Procesos de decisión de Markov
<sec:appB-mdp>

#mi-tabla(
  caption: [Notación de MDPs y programación dinámica],
  key: "tab:appB-mdp",
  table(
    columns: (26%, 1fr, 10%),
    align: (left, left, center),
    hl(),
    table.header([*Símbolo*], [*Descripción*], [*Consulta*]),
    hl(w: 0.6pt),
    $cal(M) = (StateSpace, ActionSpace, P, r, discount)$, [MDP], [3],
    $StateSpace$, [Espacio de estados], [3],
    $s in StateSpace$, [Estado], [3],
    $ActionSpace$, [Espacio de acciones], [3],
    $a in ActionSpace$, [Acción], [3],
    $P(s'|s,a)$, [Probabilidad de transición], [3],
    $r: StateSpace times ActionSpace -> RR$, [Función de recompensa], [3],
    $discount in [0,1)$, [Descuento de horizonte infinito; $gamma=1$ se admite en horizonte finito o bajo condiciones adicionales], [3],
    $pi_delta(x)=delta(x)$, [Política determinista; su kernel asigna masa uno a $delta(x)$], [3],
    $pi(a|s)$, [Probabilidad de elegir $a$ en estado $s$], [3],
    $Value^policy: StateSpace -> RR$, [Función de valor de la política $policy$], [3],
    $Value^* (s)$, [Función de valor óptima], [3],
    $policy^*$, [Política óptima], [3],
    $Qfunc^policy: StateSpace times ActionSpace -> RR$, [Función acción-valor], [3],
    $Qfunc^* (s,a)$, [Función acción-valor óptima], [3],
    $BellmanOp$, [Operador de Bellman], [3],
    $BellmanOp^policy$, [Operador de Bellman de la política $policy$], [3],
    $BellmanOp^*$, [Operador de Bellman óptimo], [3],
    $tau = (s_0, a_0, r_0, s_1, a_1, r_1, ...)$, [Trayectoria], [3],
    $G_t = sum_(k=0)^infinity discount^k r_(t+k)$, [Retorno descontado desde el tiempo $t$], [3],
    $H$, [Horizonte (número de pasos)], [3],
    hl(),
  ),
)

== Evaluación Off-Policy e Inferencia (Parte III)
<sec:appB-ope>

#mi-tabla(
  caption: [Notación de evaluación off-policy e inferencia],
  key: "tab:appB-ope",
  table(
    columns: (24%, 1fr, 10%),
    align: (left, left, center),
    hl(),
    table.header([*Símbolo*], [*Descripción*], [*Consulta*]),
    hl(w: 0.6pt),
    $pi_b$, [Política de comportamiento (behavior policy)], [7],
    $pi_e$, [Política objetivo (evaluation policy)], [7],
    $Value^(pi_e)$, [Valor de la política objetivo], [7],
    $hat(Value)^(pi_e)$, [Estimador del valor], [7],
    $rho_t = (pi_e (a_t|s_t))/(pi_b (a_t|s_t))$, [Ratio de importancia en el paso $t$], [7],
    $rho_(0:t) = product_(k=0)^t rho_k$, [Ratio de importancia acumulado], [7],
    $hat(Value)^"IS"$, [Estimador de importancia de muestreo], [7],
    $hat(Value)^"DR"$, [Estimador doblemente robusto], [7],
    $hat(Value)^"DM"$, [Estimador directo (model-based)], [7],
    $Qfunc(s,a)$, [Función acción-valor: retorno futuro esperado tras la primera acción], [7],
    $hat(Qfunc)$, [Estimador de la función acción-valor], [7],
    $psi$, [Parámetro de interés (finito-dimensional)], [4],
    $lambda$, [Parámetro nuisance (infinito-dimensional)], [4],
    $phi(P)$, [Funcional sobre distribuciones], [4],
    $phi.alt (x; P)$, [Función de influencia eficiente], [4],
    $sigma^2(P)$, [Varianza asintótica], [4],
    [$alpha$-mixing], [Coeficiente de mezcla fuerte], [4],
    [$beta$-mixing], [Coeficiente de mezcla absoluta], [4],
    [$phi.alt$-mixing], [Coeficiente de mezcla uniforme], [4],
    hl(),
  ),
)

== Representación Wald → MDP
<sec:appB-isomorfismo>  // nombre heredado; el título dice «incrustación fiel»

#mi-tabla(
  caption: [Correspondencias de la incrustación fiel],
  key: "tab:appB-isomorfismo",  // nombre heredado; el título dice «incrustación fiel»
  table(
    columns: (28%, 34%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Concepto*], [*Wald*], [*MDP*]),
    hl(w: 0.6pt),
    [Parámetro del modelo], $ParamSpace$, [Índice $theta$ de la familia de MDP],
    [Acciones], $ActionSpace$, $ActionSpace$,
    [Observaciones], $SampleSpace$, [Estado inicial observado $X$],
    [Pérdida/Recompensa], $Loss(theta, a)$, $-r_theta(x, a)$,
    [Regla de decisión], $decrule: SampleSpace -> ActionSpace$, $pi_delta(x)=delta(x)$,
    [Riesgo/Retorno], $Risk(theta, decrule)$, $-J_theta(pi_delta)$,
    [Comparación], [Misma clase de reglas], [Misma clase de políticas representadas],
    [Bayes], $min_delta rho_nu(delta)$, $max_pi J_nu(pi)$,
    [Minimax], $inf_delta sup_theta Risk$, $sup_pi inf_theta J_theta(pi)$,
    hl(),
  ),
)

== Sistema de Soporte Clínico para Hipertensión (SSCH)
<sec:appB-ssch>

#mi-tabla(
  caption: [Notación específica del ejemplo SSCH],
  key: "tab:appB-ssch",
  table(
    columns: (22%, 1fr, 12%),
    align: (left, left, center),
    hl(),
    table.header([*Símbolo*], [*Descripción*], [*Consulta*]),
    hl(w: 0.6pt),
    $cal(S) = {s_1, s_2, s_3, s_4, s_5}$, [Estados de salud], [4],
    $s_1$, [Normotensión (PA $<$ 120/80 mmHg)], [4],
    $s_2$, [Presión arterial elevada (120–129/$<$80)], [4],
    $s_3$, [Hipertensión grado 1 (130–139/80–89)], [4],
    $s_4$, [Hipertensión grado 2 ($gt.eq$140/90)], [4],
    $s_5$, [Crisis hipertensiva ($gt.eq$180/120)], [4],
    $cal(A) = {a_1, a_2, a_3, a_4}$, [Intervenciones mensuales], [4],
    $a_1$, [Vigilancia activa], [4],
    $a_2$, [Cambios de estilo de vida], [4],
    $a_3$, [Medicación de primera línea (IECA)], [4],
    $a_4$, [Terapia combinada intensiva], [4],
    $theta_(s,a,s')$, [Probabilidad de transición], [4],
    $N(s,a,s')$, [Conteo de transiciones observadas], [4],
    $r(s,a)$, [Beneficio clínico neto], [4],
    hl(),
  ),
)

== Abreviaciones y Acrónimos
<sec:appB-abreviaciones>

#mi-tabla(
  caption: [Abreviaciones y acrónimos],
  key: "tab:appB-abreviaciones",
  table(
    columns: (26%, 1fr),
    align: (left, left),
    hl(),
    table.header([*Abreviatura*], [*Descripción*]),
    hl(w: 0.6pt),
    [MDP], [Proceso de Decisión de Markov (Markov Decision Process)],
    [POMDP], [Proceso de Decisión de Markov Parcialmente Observable],
    [OPE], [Evaluación Off-Policy (Off-Policy Evaluation)],
    [IS], [Importancia de Muestreo (Importance Sampling)],
    [DR], [Doblemente Robusto (Doubly Robust)],
    [DM], [Método Directo (Direct Method)],
    [PDIS], [Importancia de Muestreo Per-Decisión],
    [UMVUE], [Estimador Uniformemente de Varianza Mínima No Sesgado],
    [CLT], [Teorema Central del Límite],
    [SAVE], [SequentiAl Value Evaluation: evaluación secuencial del valor],
    [SSCH], [Sistema de Soporte Clínico para Hipertensión],
    [LLM], [Modelo de Lenguaje Grande (Large Language Model)],
    [RL], [Aprendizaje por Refuerzo (Reinforcement Learning)],
    [HAC], [Estimador de Covarianza Heterocedástica y Autocorrelacionada],
    [ACC/AHA], [Colegio Americano de Cardiología/Asociación Americana del Corazón],
    [IECA], [Inhibidor de la Enzima Convertidora de Angiotensina],
    hl(),
  ),
)

== Convenciones Tipográficas
<sec:appB-convenciones>

- *Negrita ($bold(X)$):* Vectores y matrices cuando el contexto no es
  ambiguo
- *Caligráfica ($cal(P), cal(F)$):* Familias de conjuntos, σ-álgebras,
  espacios
- *Script ($cal(L)$):* Operadores lineales (ocasional)
- *Blackboard bold ($RR, NN$):* Conjuntos numéricos estándar
- *Itálica ($theta, eta$):* Parámetros, variables escalares
- *Sans serif ($sans(T)$):* Estadísticos cuando se enfatiza su
  naturaleza aleatoria
- *Tipo escritor (`State`):* Código, nombres de variables en
  implementaciones
- *Subíndices ($X_n, theta_0$):* Índices de secuencias, valores
  específicos
- *Superscripts ($V^pi, hat(theta)^((k))$):* Políticas, iteraciones de
  algoritmos

// Fase 2B — trasladada desde el cap. 0 (mapa: cap. 0 §Convenciones de
// Notación -> Apéndice B). Duplica parcialmente «Notación General»;
// la deduplicación es Fase 3.
// El encabezado baja de nivel: el apéndice ya es nivel 1.
=== Convenciones de Notación
<sec:ch0-notacion>

Esta monografía adopta un sistema de notación unificado diseñado para hacer
explícitas las correspondencias de la incrustación fiel. Cada símbolo tiene una
interpretación en el marco estadístico y, cuando aplica, una interpretación
en el marco de agentes.

#[
#set heading(numbering: none, outlined: false)
==== Conjuntos y espacios
]

#align(center)[
  #table(
    columns: (auto, auto, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Símbolo*], [*Interpretación estadística*], [*Interpretación en agentes*]),
    hl(w: 0.6pt),
    [$ParamSpace$ ($Theta$)], [Espacio de parámetros], [Estado oculto del entorno / índice de modelo $P_theta$ (*¡* no confundir con el estado observado $StateSpace$; ver §#ref(<sec:ch0-tesis>, supplement: none))],
    [$SampleSpace$ ($cal(X)$)], [Espacio muestral], [Espacio de observaciones],
    [$ActionSpace$ ($cal(A)$)], [Espacio de acciones], [Espacio de acciones],
    [$StateSpace$ ($cal(S)$)], [---], [Espacio de estados *observados* del MDP],
    [$DecisionSet$ ($cal(D)$)], [Clase de reglas de decisión], [Clase de políticas],
    [$RR$], [Recta real], [Recta real],
    [$NN, ZZ$], [Naturales, enteros], [Naturales, enteros],
    hl(),
  )
]

#[
#set heading(numbering: none, outlined: false)
==== Funciones y operadores
]

#align(center)[
  #table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    hl(),
    table.header([*Símbolo*], [*Definición*], [*Contexto*]),
    hl(w: 0.6pt),
    [$Loss(theta, a)$], [Función de pérdida], [Decisión estadística],
    [$Risk(theta, decrule)$], [Función de riesgo $EE_theta [Loss(theta, decrule (X))]$], [Decisión de Wald],
    [$Value^policy (s)$], [Función de valor de política $pi$], [MDP],
    [$Qfunc^policy (s,a)$], [Función $Q$ de política $pi$], [MDP],
    [$BellmanOp$], [Operador de Bellman], [MDP],
    [$phi^*(dot)$], [Función de influencia eficiente], [Semiparamétrica],
    [$EE[dot]$, $Prob[dot]$], [Esperanza y probabilidad], [General],
    [$Var[dot]$, $Cov[dot, dot]$], [Varianza y covarianza], [General],
    [$argmax$, $argmin$], [Maximizador / minimizador], [Optimización],
    hl(),
  )
]

#[
#set heading(numbering: none, outlined: false)
==== Notación probabilística
]

Escribimos $X tilde P_theta$ para indicar que la variable aleatoria $X$
sigue la distribución $P_theta$ indexada por el parámetro $theta$. La
notación $EE_theta [dot]$ y $Prob_theta [dot]$ especifica que la expectativa
o probabilidad se calcula bajo $P_theta$. Cuando el parámetro es claro por
contexto, omitimos el subíndice.

Para familias exponenciales, usamos la forma canónica
$p(x; eta) = h(x) exp{eta^top T(x) - A(eta)}$, donde $eta$ es el parámetro
natural, $T(x)$ el estadístico suficiente natural y $A(eta)$ la función
generadora de cumulantes.

#[
#set heading(numbering: none, outlined: false)
==== Notación de la incrustación fiel
]

El símbolo $isoto$ orienta la lectura de una correspondencia. La igualdad precisa entre riesgo y retorno se formula en el @ch:isomorfismo, con el promedio sobre la distribución inicial y el índice desconocido del modelo. Al utilizar una tabla conviene volver a esa formulación para identificar qué objeto se compara.

#[
#set heading(numbering: none, outlined: false)
==== Referencias cruzadas
]

Las referencias a resultados de otros capítulos usan la forma Teorema~X.Y,
Definición~X.Y o Proposición~X.Y, donde $X$ es el número de capítulo. Los
apéndices contienen las demostraciones de los resultados más técnicos; cada
enunciado indica explícitamente cuándo la demostración completa se encuentra
en el Apéndice~#ref(<app:demostraciones>, supplement: none).
