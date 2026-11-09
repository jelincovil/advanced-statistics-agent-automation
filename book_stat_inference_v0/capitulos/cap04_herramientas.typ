#import "../plantilla.typ": *
#import "@preview/cetz:0.3.4": canvas, draw


= Herramientas de transferencia
<ch:herramientas>
#chapter-alias("ch:arquitectura")
#chapter-alias("ch:reduccion")
#chapter-alias("ch:estimacion")
#chapter-alias("ch:tests")
#chapter-alias("ch:asintotica")
#chapter-alias("ch:semiparametrica")
#chapter-alias("ch:semiparametrica-old")

La transferencia de una garantía exige identificar el modelo estadístico, el objetivo y la unidad de observación. Este capítulo reúne las herramientas para hacerlo: reducción de datos y estimación paramétrica, aproximaciones asintóticas y no paramétricas, y teoría semiparamétrica para objetivos escalares con componentes auxiliares complejos. La suficiencia de una muestra no garantiza por sí sola un estado de Markov controlado; esa distinción y la representación de una decisión se precisan en el @ch:isomorfismo.

#thm-env("example", name: [Motivación: estimar una decisión con modelos auxiliares], key: "ex:ch6-motivacion")[
  Un sistema compara dos acciones a partir de resultados $Y$, tratamiento $A$ y covariables previas $X$. El objetivo puede ser $psi=EE[Y(1)-Y(0)]$. Antes de estimarlo se requieren consistencia, intercambiabilidad condicional y positividad. La propensión $e(X)=P(A=1|X)$ y las medias $m_a (X)=EE[Y|A=a,X]$ ayudan a estimar ese objetivo.

  Ponderar con la propensión verdadera permite una identidad insesgada; sustituirla por una estimación no conserva insesgadez finita automáticamente. La doble robustez pertenece a un estimador aumentado específico: su sesgo poblacional se anula si la propensión o las dos medias condicionales son correctas. Más adelante se deriva esa identidad y se distingue de la normalidad asintótica y de la identificación causal.
]

== Del modelo a la información que conservan los datos

=== El Problema de Inferencia Estadística: Estructura Formal
<sec:ch1-modelo>

Para el investigador que diseña un agente, el modelo paramétrico
$cal(P)_theta$ no es una abstracción: es la _hipótesis de trabajo_ sobre
cómo el ambiente genera observaciones. La inferencia estadística responde:
_dada esta hipótesis y estos datos, qué decisiones son racionales?_ La
quíntupla $cal(I) = (cal(P), theta, SampleSpace, T, cal(C))$ formaliza esta
pregunta.

La inferencia estadística puede caracterizarse como el problema de extraer
información sobre cantidades desconocidas a partir de datos observados,
bajo un modelo estadístico que describe el mecanismo generador de los
datos.

#thm-env("definition", name: [Modelo Estadístico Paramétrico], key: "def:ch1-modelo-parametrico")[
  Un _modelo estadístico paramétrico_ es una familia de distribuciones de
  probabilidad indexada por un parámetro:
  $ cal(P) = {P_theta : theta in ParamSpace} $
  donde:
  - $ParamSpace subset.eq RR^k$ es el _espacio de parámetros_
  - $P_theta$ es una medida de probabilidad sobre el espacio muestral $(SampleSpace, cal(A))$
  - La función $theta |-> P_theta$ se denomina _parametrización_ del modelo

  El modelo se dice _identificable_ si la parametrización es inyectiva:
  $theta_1 eq.not theta_2 => P_(theta_1) eq.not P_(theta_2)$.
]


#thm-env("definition", name: [Función de Densidad/Masa], key: "def:ch1-densidad")[
  Si cada $P_theta$ admite una densidad (o función de masa) respecto a una
  medida $sigma$-finita dominante $mu$, escribimos:
  $ f_theta (x) = (d P_theta) / (d mu) (x) $
  La dominación común se supone en los resultados que utilizan estas densidades. No se impone a toda clase no paramétrica: la clase de todas las leyes con segundo momento finito, por ejemplo, no admite una medida dominante común sigma-finita.
]


#thm-env("definition", name: [Función de Verosimilitud], key: "def:ch1-verosimilitud")[
  Dada una observación $x in SampleSpace$, la _función de verosimilitud_ es:
  $ L(theta; x) := f(x|theta), quad theta in ParamSpace $
  _Nota crucial_: $L(dot; x)$ se considera como función de $theta$ (no de
  $x$). Dos valores $theta_1, theta_2$ se comparan mediante el cociente
  $L(theta_1; x)\/L(theta_2; x)$: valores mayores indican mayor
  compatibilidad con los datos observados.
]


#thm-env("definition", name: [Los Cinco Componentes de la Inferencia], key: "def:ch1-cinco-componentes")[
  Un problema de inferencia estadística completo se especifica mediante la
  quíntupla:
  $ cal(I) = (cal(P), theta, SampleSpace, T, cal(C)) $
  donde:
  + $cal(P)$: modelo estadístico (paramétrico, semiparamétrico o no paramétrico)
  + $theta in ParamSpace$: parámetro de interés (o funcional $g(theta)$)
  + $SampleSpace$: espacio muestral donde se observan los datos $X = (X_1, ..., X_n)$
  + $T: SampleSpace -> cal(T)$: estadístico (función medible de los datos)
  + $cal(C)$: criterio de optimalidad (sesgo, varianza, riesgo, cobertura, etc.)
]

#mi-tabla(
  caption: [Correspondencia entre conceptos estadísticos y componentes de agentes],
  key: "tab:ch1-correspondencia-agentes",
  table(
    columns: (25%, 37.5%, 37.5%),
    align: (left, left, left),
    hl(),
    table.header([*Concepto Estadístico*], [*Interpretación en Agentes*], [*Implementación en LangGraph*]),
    hl(w: 0.6pt),
    [Modelo paramétrico $cal(P)$], [Hipótesis sobre cómo el ambiente genera observaciones], [Modelo explícito; el esquema de tipos no define su ley],
    [Parámetro $theta$], [Cantidad o funcional desconocido de interés], [Objetivo de estimación],
    [Espacio muestral $SampleSpace$], [Espacio de observaciones posibles], [Tipo de entrada del agente],
    [Estadístico $T(X)$], [Estado interno del agente], [Variables almacenadas en `State`],
    [Criterio $cal(C)$], [Función objetivo del agente], [Reglas en nodo `Decidir`],
    [Función de verosimilitud $L(theta; x)$], [Compatibilidad de hipótesis con datos], [Cálculo en nodo `Actualizar`],
    [Distribución posterior $p(theta|x)$], [Creencias actualizadas del agente], [Salida de nodo `Estimar`],
    hl(),
  ),
)

#let box-node(pos, label, name, w: 1.3, h: 0.6, nodefill: rgb(230,230,230)) = {
  draw.rect((pos.at(0) - w, pos.at(1) - h), (pos.at(0) + w, pos.at(1) + h), name: name, fill: nodefill, radius: 0.1)
  draw.content(pos, text(size: 8pt, label))
}

#mi-figura(
  caption: [Diagrama de flujo del proceso de inferencia estadística. El proceso comienza con la especificación del modelo $cal(P)$ y parámetro $theta$, mientras se observan datos $X$. Un estadístico suficiente $T(X)$, cuando existe una reducción útil, resume los datos sin perder la información de verosimilitud; junto con el modelo alimenta la función de verosimilitud $L(theta; X)$. Un criterio $cal(C)$ transforma esta información en una regla de decisión $decrule (X)$, cuya calidad se evalúa mediante el riesgo $Risk(theta, decrule)$. Las flechas de retroalimentación permiten el aprendizaje y actualización del modelo.],
  key: "fig:ch1-flujo-inferencia",
  canvas(length: 0.55cm, {
    import draw: line, circle, content
    circle((-1.8, 2), radius: 1.0, name: "inicio", fill: rgb(220,220,220))
    content((-1.8,2), text(size: 8pt)[Inicio])
    box-node((3, 4.5), [Modelo $cal(P)$], "modelo", w: 1.8, nodefill: blue.lighten(85%))
    box-node((8, 4.5), [Parámetro $theta$], "parametro", w: 1.8, nodefill: blue.lighten(85%))
    box-node((3, -0.5), [Datos $X in cal(X)$], "datos", w: 2.0, nodefill: green.lighten(85%))
    box-node((8.2, -0.5), [Estadístico $T(X)$], "estadistico", w: 2.0, nodefill: green.lighten(85%))
    box-node((13.5, 2), [Verosimilitud $L(theta; X)$], "veros", w: 2.5, nodefill: yellow.lighten(85%))
    box-node((19, 2), [Criterio $cal(C)$], "criterio", w: 1.8, nodefill: orange.lighten(85%))
    circle((22.5, -1.5), radius: 1.6, name: "decision", fill: red.lighten(85%))
    content((22.5,-1.5), text(size: 7.5pt)[Decisión $delta(X)$])
    box-node((22.5, -6.3), align(center)[Evaluación \ Riesgo $R(theta,delta)$], "evaluacion", w: 2.4, h: 0.9, nodefill: purple.lighten(88%))
    circle((16.5, -6.3), radius: 1.0, name: "fin", fill: rgb(220,220,220))
    content((16.5,-6.3), text(size: 8pt)[Fin])
    line("inicio", "modelo", mark: (end: ">"))
    line("inicio", "datos", mark: (end: ">"))
    line("modelo", "parametro", mark: (end: ">"))
    line("datos", "estadistico", mark: (end: ">"))
    line("parametro", "veros", mark: (end: ">"))
    line("estadistico", "veros", mark: (end: ">"))
    line("veros", "criterio", mark: (end: ">"))
    line("criterio", "decision", mark: (end: ">"))
    line("decision", "evaluacion", mark: (end: ">"))
    content((24.2, -4.0), text(size: 7pt)[Acción $a$])
    line("evaluacion", "fin", mark: (end: ">"))
    line("evaluacion.west", "modelo.south", mark: (end: ">"), stroke: (dash: "dashed"))
    content((10.5, -3.3), text(size: 7pt)[Aprendizaje])
    line("evaluacion.south", "datos.south", mark: (end: ">"), stroke: (dash: "dashed"))
    content((10.5, -5.3), text(size: 7pt)[Actualización])
  }),
)

#mi-tabla(
  caption: [Interpretación operativa de los cinco componentes de la inferencia],
  key: "tab:ch1-cinco-componentes",
  table(
    columns: (25%, 37.5%, 37.5%),
    align: (left, left, left),
    hl(),
    table.header([*Componente*], [*Pregunta que responde*], [*Acción del investigador*]),
    hl(w: 0.6pt),
    [$cal(P)$], [¿Qué mecanismos generadores son plausibles?], [Especificar una clase de distribuciones y justificar sus restricciones],
    [$theta$], [¿Qué aspecto del mecanismo nos importa?], [Identificar funcional de interés (ej. media, cuantil)],
    [$SampleSpace$], [¿Qué podemos observar?], [Diseñar protocolo de recolección de datos],
    [$T$], [¿Qué información conserva el resumen?], [Suficiencia para el modelo o eficiencia para un funcional: propiedades distintas],
    [$cal(C)$], [¿Qué cuenta como "buena" inferencia?], [Seleccionar criterio alineado con objetivos del agente],
    hl(),
  ),
)


#thm-env("note", name: [Tres regímenes, un mismo objetivo], key: "rem:ch4-tres-modelos")[
  Un modelo es una clase $cal(P)$ de leyes y el objetivo es un funcional $psi:cal(P)->RR^d$. En el régimen paramétrico regular, la ley se describe por un vector de dimensión finita fija. En el no paramétrico se permite una clase infinita, por ejemplo distribuciones con segundo momento finito o funciones con cierta suavidad. La inferencia semiparamétrica estudia un objetivo finito-dimensional dentro de un modelo con componentes infinitos; puede aplicarse incluso a un modelo observado no paramétrico. No son tres algoritmos ni tres grados de calidad.

  #table(columns: (23%,38%,39%),
    table.header([*Enfoque*],[*Ejemplo*],[*Garantía que debe justificarse*]),
    [Paramétrico], [$Y tilde N(mu,sigma^2)$; interés $mu$], [Regularidad, especificación y Fisher],
    [No paramétrico], [CDF de retornos sin forma fijada], [Convergencia uniforme y bandas],
    [Semiparamétrico], [Valor de una política con regresiones desconocidas], [Gradiente canónico y control del resto],
  )
  La media puede estimarse a tasa $sqrt(n)$ sin especificar la distribución completa, si hay varianza finita. En cambio, estimar una densidad en un punto suele exigir suavidad y una tasa distinta. El tamaño del objetivo no determina por sí solo la dificultad. Una tabla de transición sobre un número fijo de estados y acciones sigue siendo un modelo de dimensión finita.
]

=== Estadísticos y su Clasificación
<sec:ch1-estadisticos>

#thm-env("definition", name: [Función Medible], key: "def:medible-operativa")[
  Una función $T: SampleSpace -> cal(T)$ es _medible_ si para todo conjunto
  "razonable" $B subset.eq cal(T)$, el conjunto ${x in SampleSpace : T(x) in B}$
  es un evento sobre el cual podemos calcular probabilidades.

  #thm-env("example", name: [Intuición], key: "ex:ch1-medible-intuicion")[
    Si $SampleSpace = RR^n$ con la $sigma$-álgebra de Borel, entonces toda
    función continua es medible. En la práctica del curso, asumiremos que
    todos los estadísticos de interés son medibles; la definición formal
    permite definir su distribución; para una esperanza finita se necesita además integrabilidad.
  ]
]


#thm-env("definition", name: [Estadístico], key: "def:ch1-estadistico")[
  Un _estadístico_ es cualquier función medible $T: SampleSpace -> cal(T)$
  del vector de datos $X = (X_1, ..., X_n)$ que no depende de parámetros
  desconocidos.
]


#thm-env("definition", name: [Estimador], key: "def:ch1-estimador")[
  Un _estimador_ de un funcional $psi(theta)$ es un estadístico
  $hat(psi): SampleSpace -> cal(A)_psi$, donde $cal(A)_psi$ es el espacio de estimación declarado, cuyo propósito es aproximar el
  valor verdadero del parámetro satisfaciendo algún tipo de criterio de
  optimalidad. Cuando queremos enfatizar que $hat(theta)$ depende de la
  muestra, escribimos $hat(theta)(X)$ o $hat(theta)_n$ si el tamaño muestral
  $n$ es relevante.
]


#thm-env("example", name: [Estadísticos Fundamentales], key: "ex:ch1-estadisticos-fundamentales")[
  Sea $X_1, ..., X_n$ una muestra aleatoria de una distribución con media
  $mu$ y varianza $sigma^2$ finitas. Los siguientes son estadísticos:
  + *Media muestral:* $overline(X)_n = 1/n sum_(i=1)^n X_i$
  + *Varianza muestral:* $S_n^2 = 1/(n-1) sum_(i=1)^n (X_i - overline(X)_n)^2$
  + *Estadísticos de orden:* $X_((1)) <= X_((2)) <= ... <= X_((n))$
  + *Rango:* $R_n = X_((n)) - X_((1))$

  Cada uno de estos captura diferentes aspectos de la muestra: localización,
  dispersión, extremos. La elección del estadístico apropiado depende del
  problema inferencial en cuestión.
]

=== Criterios de Optimalidad
<sec:ch1-criterios>

Un aspecto central de la inferencia estadística es la evaluación de la
calidad de los procedimientos inferenciales. Los criterios de optimalidad
proporcionan métricas formales para esta evaluación.

#thm-env("definition", name: [Sesgo], key: "def:ch1-sesgo")[
  El _sesgo_ de un estimador $hat(theta)$ para el parámetro $theta$ es:
  $ "Sesgo"_theta (hat(theta)) = EE_theta [hat(theta)(X)] - theta $
  Un estimador es _insesgado_ si $"Sesgo"_theta (hat(theta)) = 0$ para todo
  $theta in ParamSpace$. Se dice _asintóticamente insesgado_ si
  $lim_(n -> infinity) "Sesgo"_theta (hat(theta)_n) = 0$.
]


#thm-env("definition", name: [Varianza y Error Cuadrático Medio], key: "def:ch1-varianza-ecm")[
  Para un estimador $hat(theta)$, definimos:

  *Varianza:*
  $ Var_theta (hat(theta)) = EE_theta [(hat(theta) - EE_theta [hat(theta)])^2] $

  *Error Cuadrático Medio (ECM):*
  $ "ECM"_theta (hat(theta)) = EE_theta [(hat(theta) - theta)^2] $

  Estas cantidades satisfacen la _descomposición sesgo-varianza_:
  $ "ECM"_theta (hat(theta)) = Var_theta (hat(theta)) + ["Sesgo"_theta (hat(theta))]^2 $
]

#proofsketch-env[
  La descomposición se obtiene sumando y restando $EE_theta [hat(theta)]$:
  $
    "ECM"_theta (hat(theta))
    &= EE_theta [(hat(theta) - theta)^2] \
    &= EE_theta [((hat(theta) - EE[hat(theta)]) + (EE[hat(theta)] - theta))^2] \
    &= EE_theta [(hat(theta) - EE[hat(theta)])^2] + 2(EE[hat(theta)] - theta) underbrace(EE[hat(theta) - EE[hat(theta)]], =0) + (EE[hat(theta)] - theta)^2 \
    &= Var_theta (hat(theta)) + ["Sesgo"_theta (hat(theta))]^2
  $
]

#thm-env("example", name: [Cálculo Numérico de Sesgo, Varianza y ECM], key: "ex:ch1-calculo-numerico")[
Suponga cinco indicadores iid de transición $X_i tilde "Bernoulli"(theta)$ bajo una acción fija. La muestra $(1,0,1,0,1)$ da $hat(theta)_1=overline(X)=0.6$ y $hat(theta)_2=0.9 overline(X)=0.54$. Estos son valores observados, no esperanzas.

  Para cualquier $theta$, el primer estimador tiene sesgo cero y riesgo $theta(1-theta)/5$. El segundo tiene sesgo $-0.1theta$, varianza $0.81theta(1-theta)/5$ y riesgo $0.81theta(1-theta)/5+0.01theta^2$. En $theta=0.5$, sus riesgos son $0.05$ y $0.043$, respectivamente. El error observado $0.54-0.5=0.04$ no es el sesgo, que vale $-0.05$.

  El contraído mejora el ECM para $0<theta<19/24$ y lo empeora para $theta>19/24$. Ambos riesgos dependen del parámetro: menor varianza o insesgadez no ordenan por sí solas las reglas. Los cinco registros son sintéticos y se supone independencia entre unidades; transiciones repetidas de un paciente requieren otro análisis.
]


#thm-env("definition", name: [Función de Pérdida y Riesgo], key: "def:ch1-perdida-riesgo")[
  Sea $Loss: ParamSpace times ActionSpace -> RR_(>= 0)$ una _función de
  pérdida_ que mide el costo de tomar la acción $a in ActionSpace$ cuando el
  estado verdadero de la naturaleza es $theta$. El _riesgo_ de una regla de
  decisión $decrule: SampleSpace -> ActionSpace$ es:
  $ Risk(theta, decrule) = EE_(X tilde P_theta)[Loss(theta, decrule (X))] $
]


#thm-env("example", name: [Pérdidas Comunes], key: "ex:ch1-perdidas-comunes")[
  + *Pérdida cuadrática:* $Loss(theta, a) = (theta - a)^2$. El riesgo es el ECM.
  + *Pérdida absoluta:* $Loss(theta, a) = abs(theta - a)$. El riesgo es el error absoluto medio.
  + *Pérdida 0-1:* $Loss(theta, a) = bb(1)(a eq.not theta)$. Usada en clasificación; el riesgo es la probabilidad de error.
  + *Pérdida ponderada:* $Loss(theta, a) = w(theta)(theta - a)^2$ para alguna función de peso $w > 0$.
]

=== Familias Exponenciales: Definición y Propiedades
<sec:ch1-exponenciales>

Las familias exponenciales constituyen una clase central de modelos
paramétricos, tanto por su tratabilidad analítica como por sus propiedades de suficiencia y regularidad. Muchos modelos clásicos
(normal, binomial, Poisson, gamma, beta, multinomial) pertenecen a esta
clase. Para agentes inteligentes, estas familias ofrecen ventajas clave:

- *Actualización eficiente:* El estadístico natural $T(X)$ permite actualizaciones incrementales en tiempo constante respecto del tamaño muestral, para dimensión fija.
- *Reducción suficiente:* $T(X)$ retiene la información del modelo; la minimalidad exige condiciones adicionales.
- *Propiedades inferenciales:* Los estimadores de máxima verosimilitud requieren existencia, identificación y regularidad para sus garantías asintóticas; véase @thm:ch3-mle-propiedades.

#thm-env("definition", name: [Familia Exponencial en Forma Canónica], key: "def:ch1-familia-exponencial")[
  Una familia paramétrica $cal(P)$ admite una _representación exponencial con $k$ componentes_
  si la densidad puede escribirse como:
  $ f(x|eta) = h(x) exp{sum_(j=1)^k eta_j T_j (x) - A(eta)} = h(x) exp{eta^top T(x) - A(eta)} $
  donde:
  - $eta = (eta_1, ..., eta_k)^top in cal(H) subset.eq RR^k$: _parámetro natural_ (o canónico)
  - $T(x) = (T_1 (x), ..., T_k (x))^top$: _estadístico natural_ (o suficiente)
  - $A(eta)$: _función log-partición_; la generadora de cumulantes de $T$ bajo $eta$ es $A(eta+u)-A(eta)$ donde está definida
  - $h(x) >= 0$: factor base respecto de la medida dominante
  - $cal(H) = {eta in RR^k : A(eta) < infinity}$: _espacio de parámetros naturales_
  Para llamar $k$ al rango se requiere independencia afín de los componentes de $T$ respecto de la medida base. Una parametrización puede utilizar solo un subconjunto del dominio natural máximo $cal(H)$.
]


#thm-env("theorem", name: [Propiedades de la Función Log-Partición], key: "thm:ch1-logparticion")[
  Sea $cal(P)$ una familia exponencial regular con espacio de parámetros
  naturales $cal(H)$ abierto. Entonces:
  + $A(eta)$ es *convexa* en $cal(H)$
  + $A(eta)$ es *infinitamente diferenciable* en el interior de $cal(H)$
  + Las primeras derivadas de $A$ generan los *cumulantes* del estadístico natural:
  $ (partial A) / (partial eta_j) = EE_eta [T_j (X)] $ <eq:ch1-momento-1>
  $ (partial^2 A) / (partial eta_j partial eta_l) = Cov_eta (T_j (X), T_l (X)) $ <eq:ch1-momento-2>
]

#proofsketch-env[
  - *Convexidad:* Por la condición de normalización,
    $exp(A(eta)) = integral h(x) exp(eta^top T(x)) dif mu(x)$. La función
    $eta |-> exp(eta^top t)$ es log-lineal (y por tanto log-convexa) para
    cada $t$ fijo. El logaritmo de una integral de funciones log-convexas es
    convexo (desigualdad de Hölder generalizada).
  - *Diferenciabilidad:* Bajo condiciones de regularidad (que permiten
    intercambiar derivación e integración), la suavidad de
    $exp(eta^top T(x))$ en $eta$ se transfiere a $A(eta)$.
  - *Fórmulas de momentos:* Derivando $1 = integral f(x|eta) dif mu(x)$
    respecto a $eta_j$:
    $ 0 = integral (partial)/(partial eta_j) f(x|eta) dif mu(x) = integral (T_j (x) - A'_j (eta)) f(x|eta) dif mu(x) $
    de donde $A'_j (eta) = EE_eta [T_j (X)]$. La segunda derivada se obtiene
    análogamente.

  Ver #cite(<lehmann1998theory>, form: "prose"), Teorema~1.6.1 para la
  demostración completa. #verdem(<dem:ch1-logparticion>)
]

#thm-env("corollary", key: "cor:ch1-covarianza-hessiano")[
  La matriz de covarianzas del estadístico natural es igual al Hessiano de
  $A$:
  $ Cov_eta (T(X)) = nabla^2 A(eta) $
  y por convexidad de $A$, esta matriz es semidefinida positiva. En familias
  minimales, es definida positiva.
]


#thm-env("example", name: [Familia Normal con Varianza Conocida], key: "ex:ch1-normal")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con $sigma^2$
  conocida. La densidad conjunta es:
  $ f(bold(x)|mu) = (1/(2 pi sigma^2))^(n/2) exp{-1/(2 sigma^2) sum_(i=1)^n (x_i - mu)^2} $

  Expandiendo el cuadrado y reorganizando:
  $ f(bold(x)|mu) = (1/(2 pi sigma^2))^(n/2) exp{-(sum x_i^2)/(2 sigma^2)} dot exp{mu/sigma^2 sum_(i=1)^n x_i - (n mu^2)/(2 sigma^2)} $

  Identificamos los componentes:
  - Parámetro natural: $eta = mu\/sigma^2$
  - Estadístico natural: $T(bold(x)) = sum_(i=1)^n x_i$
  - Log-partición: $A(eta) = (n sigma^2 eta^2)/2 = (n mu^2)/(2 sigma^2)$
  - Medida base: $h(bold(x)) = (2 pi sigma^2)^(-n/2) exp(-(sum x_i^2)/(2 sigma^2))$

  *Verificación:* $(partial A)/(partial eta) = n sigma^2 eta = n mu = EE[sum X_i]$ ✓
]


#thm-env("example", name: [Familia Bernoulli/Binomial], key: "ex:ch1-binomial")[
  Sea $X tilde "Binomial"(n, p)$. La función de masa es:
  $ f(x|p) = binom(n, x) p^x (1-p)^(n-x) = binom(n, x) exp{x log(p/(1-p)) + n log(1-p)} $

  Identificamos:
  - Parámetro natural: $eta = log(p/(1-p))$ (log-odds)
  - Estadístico natural: $T(x) = x$
  - Log-partición: $A(eta) = n log(1 + e^eta)$
  - Espacio de parámetros naturales: $cal(H) = RR$

  *Verificación:* $A'(eta) = (n e^eta)/(1+e^eta) = (n p)/1 = n p = EE[X]$ ✓
]


#thm-env("example", name: [Familia Poisson], key: "ex:ch1-poisson")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Poisson"(lambda)$. La densidad
  conjunta es:
  $ f(bold(x)|lambda) = (lambda^(sum x_i) e^(-n lambda)) / (product_(i=1)^n x_i !) = 1/(product x_i !) exp{(log lambda) sum x_i - n lambda} $

  Identificamos:
  - Parámetro natural: $eta = log lambda$
  - Estadístico natural: $T(bold(x)) = sum_(i=1)^n x_i$
  - Log-partición: $A(eta) = n e^eta = n lambda$
  - Espacio de parámetros naturales: $cal(H) = RR$
]

=== Estadísticos Naturales y Suficiencia
<sec:ch1-suficiencia-intro>

Una propiedad fundamental de las familias exponenciales es que el
estadístico natural es automáticamente suficiente.

#thm-env("theorem", name: [El Estadístico Natural es Suficiente], key: "thm:ch1-suficiencia-natural")[
  En una familia exponencial, el estadístico natural $T(X)$ es _suficiente_
  para $eta$ (y por lo tanto para cualquier reparametrización
  $theta = theta(eta)$).
]

#proofsketch-env[
  Por el Teorema de Factorización de Neyman-Fisher (que se desarrollará en
  detalle en el @ch:reduccion), $T$ es suficiente si y solo si la densidad
  factoriza como:
  $ f(x|theta) = g(T(x), theta) dot h(x) $

  En familias exponenciales, esta factorización es evidente de la
  definición:
  $ f(x|eta) = underbrace(exp{eta^top T(x) - A(eta)}, g(T(x), eta)) dot underbrace(h(x), h(x)) $
  #verdem(<dem:ch1-suficiencia-natural>)
]

=== Priors Conjugados y Actualización Bayesiana
<sec:ch1-conjugados>

Las familias conjugadas juegan un papel fundamental en la inferencia
bayesiana, ya que permiten actualizaciones analíticas cerradas del
posterior. Esta propiedad es especialmente valiosa para agentes que deben
actualizar sus creencias en tiempo real con recursos computacionales
limitados. En esta sección, exploramos cómo los priors conjugados se
integran naturalmente con las familias exponenciales, proporcionando un
mecanismo eficiente para el aprendizaje secuencial.

#mi-tabla(
  caption: [Familias conjugadas comunes y su aplicación en agentes],
  key: "tab:ch1-familias-conjugadas",
  table(
    columns: (20%, 25%, 25%, 1fr),
    align: (left, left, left, left),
    hl(),
    table.header([*Modelo*], [*Prior Conjugado*], [*Actualización*], [*Aplicación en Agentes*]),
    hl(w: 0.6pt),
    [Bernoulli/Binomial], [Beta$(alpha, beta)$], [$(alpha+x, beta+n-x)$], [CTR, conversiones binarias],
    [Poisson], [Gamma$(alpha, beta)$], [$(alpha+x, beta+1)$], [Tasas de eventos, conteos],
    [Normal (varianza conocida)], [Normal$(mu_0, sigma_0^2)$], [Fórmulas conjugadas], [Recompensas continuas],
    [Normal (ambos desconocidos)], [Normal-Gamma$(mu_0, lambda, alpha, beta)$], [Actualización cuadrática], [Recompensas con incertidumbre],
    [Multinomial], [Dirichlet$(alpha_1, ..., alpha_k)$], [$(alpha_i + x_i)$], [Distribuciones categóricas],
    hl(),
  ),
)

#thm-env("definition", name: [Familia Conjugada], key: "def:ch1-conjugada")[
  Sea $cal(P) = {P_theta : theta in ParamSpace}$ una familia paramétrica y
  $cal(F) = {p(theta|eta) : eta in cal(H)}$ una familia de distribuciones
  sobre $ParamSpace$. Decimos que $cal(F)$ es _conjugada_ para $cal(P)$ si:
  $ p(theta|x, eta) prop f(x|theta) p(theta|eta) quad => quad p(dot|x, eta) in cal(F) $
  es decir, el posterior pertenece a la misma familia que el prior, con
  hiperparámetros actualizados $eta' = eta'(x, eta)$.
]


#thm-env("example", name: [Beta-Binomial], key: "ex:ch1-beta-binomial")[
  Para $X|theta tilde "Binomial"(n, theta)$ y prior
  $theta tilde "Beta"(alpha, beta)$:
  $ p(theta|x) prop theta^x (1-theta)^(n-x) dot theta^(alpha-1)(1-theta)^(beta-1) = theta^(alpha+x-1)(1-theta)^(beta+n-x-1) $
  Luego $theta|x tilde "Beta"(alpha+x, beta+n-x)$. La actualización es
  aditiva: $(alpha, beta) |-> (alpha+x, beta+n-x)$.

  *Implicación para agentes:* El estado puede almacenar $(alpha, beta)$
  como hiperparámetros suficientes; la actualización ante nueva observación
  $x$ es $O(1)$.
]


#thm-env("example", name: [Gamma-Poisson], key: "ex:ch1-gamma-poisson")[
  Para $X|lambda tilde "Poisson"(lambda)$ y prior
  $lambda tilde "Gamma"(alpha, beta)$:
  $ p(lambda|x) prop lambda^x e^(-lambda) dot lambda^(alpha-1) e^(-beta lambda) = lambda^(alpha+x-1) e^(-(beta+1)lambda) $
  Luego $lambda|x tilde "Gamma"(alpha+x, beta+1)$. Nuevamente, actualización
  aditiva en hiperparámetros.

  *Conexión con suficiencia:* En ambos ejemplos, el estadístico suficiente
  $T(x)$ (éxitos en Binomial, conteo en Poisson) es exactamente la cantidad
  que actualiza el prior conjugado.
]


#thm-env("example", name: [Normal-Gamma para recompensas continuas], key: "ex:ch1-normal-gamma")[
  Considere un agente que observa recompensas continuas
  $X_1, X_2, ... tilde N(mu, tau^(-1))$ donde tanto la media $mu$ como la
  precisión $tau = 1\/sigma^2$ son desconocidas. El prior conjugado es la
  distribución Normal-Gamma:
  $ p(mu, tau|mu_0, lambda, alpha, beta) = "NormalGamma"(mu_0, lambda, alpha, beta) $
  que factoriza como $mu|tau tilde N(mu_0, (lambda tau)^(-1))$ y
  $tau tilde "Gamma"(alpha, beta)$.

  *Actualización secuencial:* Dada observación $x$, los hiperparámetros se
  actualizan como:
  $
    mu'_0 &= (lambda mu_0 + x)/(lambda + 1) \
    lambda' &= lambda + 1 \
    alpha' &= alpha + 1/2 \
    beta' &= beta + (lambda(x - mu_0)^2)/(2(lambda + 1))
  $

  *Estado del agente:* Con prior fijo, el cuádruple $(mu_0, lambda, alpha, beta)$ permite reconstruir el posterior; no es una representación minimal de cuatro dimensiones. Para $n$ fijo, basta $(sum X_i,sum X_i^2)$, y en actualización secuencial se registra también $n$. Un agente LangGraph puede almacenar
  este estado y actualizarlo en $O(1)$ por observación.

  *Decisión informada:* El agente puede calcular:
  - *Estimación puntual:* $hat(mu) = mu'_0$ (media posterior después de incorporar $x$)
  - *Incertidumbre:* $Var(mu|x) = beta'/(lambda'(alpha'-1))$ para $alpha' > 1$
  - *Criterio de decisión:* Mostrar contenido si $hat(mu) > mu_"umbral"$ y $Var(mu|x) < sigma^2_"máx"$

  Este ejemplo ilustra cómo familias conjugadas multidimensionales permiten
  a agentes manejar múltiples parámetros desconocidos simultáneamente con
  actualizaciones eficientes.
]

=== Otras familias paramétricas con estructura
<sec:ch1-otras-familias>

Aunque las familias exponenciales dominan la teoría de estimación óptima,
existen otras clases paramétricas con estructura algebraica que permiten
construir estimadores con propiedades garantizadas. Estas familias
comparten la característica de que sus distribuciones están relacionadas
por transformaciones simples, lo que facilita el análisis de invarianzas y
la derivación de estimadores óptimos bajo criterios específicos.

#thm-env("definition", name: [Familia de localización-escala], key: "def:ch1-localizacion-escala")[
  Una familia $cal(P)$ es de _localización-escala_ si existe una densidad
  base $g$ tal que:
  $ f_(mu,sigma)(x) = 1/sigma g((x-mu)/sigma), quad mu in RR, sigma > 0 $
  donde $g$ es una densidad fija (ej. $g(z) = 1/sqrt(2 pi) e^(-z^2/2)$ para
  la normal).
]


#thm-env("example", name: [Distribución $t$ de Student], key: "ex:ch1-t-student")[
  La distribución $t$ con $nu$ grados de libertad pertenece a una familia
  de localización-escala con densidad base:
  $ g(z) = (Gamma((nu+1)/2)) / (sqrt(nu pi) Gamma(nu/2)) (1 + z^2/nu)^(-(nu+1)/2) $

  *Propiedades estadísticas:*
  - _Colas y robustez:_ Sus colas son más pesadas que las de una normal. La robustez pertenece al procedimiento: la media muestral sigue siendo sensible a valores extremos; una estimación de localización robusta exige especificar su criterio.
  - _Estimación:_ La media existe solo para $nu>1$ y la varianza solo para $nu>2$. Si no existen los momentos requeridos, el CLT de varianza finita no se aplica. La mediana y estimadores M responden a objetivos y criterios que deben especificarse.
  - _Relevancia para agentes:_ Permite estudiar recompensas extremas. Cambiar las colas sin cambiar las recompensas medias ni las transiciones no cambia por sí solo la política que maximiza retorno esperado; otros criterios de riesgo pueden responder de otra manera.
]


#thm-env("definition", name: [Familia de mezclas finitas], key: "def:ch1-mezclas")[
  Una _mezcla finita_ de $K$ componentes es una distribución de la forma:
  $ f(x|bold(theta)) = sum_(k=1)^K w_k f_k (x|theta_k), quad sum_(k=1)^K w_k = 1, quad w_k >= 0 $
  donde cada $f_k$ pertenece a una familia paramétrica (normal, Poisson,
  etc.).
]


#thm-env("example", name: [Mezcla de dos normales], key: "ex:ch1-mezcla-normal")[
  Para $f(x|w,mu_1,mu_2,sigma_1^2,sigma_2^2) = w N(mu_1,sigma_1^2) + (1-w)N(mu_2,sigma_2^2)$:
  - _Multimodalidad:_ Puede modelar poblaciones heterogéneas.
  - _Estimación:_ El algoritmo EM alterna entre asignación de
    responsabilidades (E-step) y maximización de parámetros (M-step).
  - _Aplicación a agentes:_ Útil cuando el ambiente tiene regímenes
    distintos (ej. mercado alcista/bajista) que requieren políticas
    diferentes.
]


#thm-env("definition", name: [Familia de valores extremos], key: "def:ch1-valores-extremos")[
  La familia de _valores extremos_ (GEV) describe la distribución límite del
  máximo (o mínimo) de $n$ variables i.i.d. cuando $n -> infinity$, cuando existen constantes de normalización que producen un límite no degenerado, según el Teorema de Fisher-Tippett-Gnedenko. Incluye tres tipos: Gumbel, Fréchet y
  Weibull.
]


#thm-env("example", name: [Distribución Gumbel], key: "ex:ch1-gumbel")[
La densidad Gumbel es
  $ f(x|mu,beta)=1/beta exp(-(x-mu)/beta-exp(-(x-mu)/beta)), quad beta>0. $
  Si $X_i$ son iid Gumbel, $max_i X_i$ tiene parámetros $(mu+beta log n,beta)$. Para escala conocida, $sum_i exp(-X_i/beta)$ es suficiente para la localización. Con escala desconocida, $exp(-x/beta)$ depende del parámetro y no puede llamarse estadístico natural: la fórmula no define una familia exponencial de dimensión dos con estadísticos fijos. Un modelo de extremos requiere además justificar su dominio de atracción y la elección de bloques o umbrales.
]

Los ejemplos paramétricos permiten ahora formular una pregunta común: qué parte de la muestra conserva la información sobre el parámetro. La suficiencia responde dentro de una familia de distribuciones especificada y dará una base para comparar reducciones de datos.

=== El Principio de Suficiencia
<sec:ch2-suficiencia>

El principio de suficiencia es uno de los pilares fundamentales de la
reducción de datos: permite comprimir toda la información relevante sobre
el parámetro $theta$ contenida en una muestra $X = (X_1, ..., X_n)$ en un
estadístico de dimensión potencialmente mucho menor.

#thm-env("definition", name: [Suficiencia], key: "def:ch2-suficiencia")[
  Sea $X tilde P_theta$ con $theta in ParamSpace$. Un estadístico
  $T: SampleSpace -> cal(T)$ es _suficiente_ para $theta$ si la
  distribución condicional de $X$ dado $T(X) = t$ no depende de $theta$
  para casi todo $t$ bajo cada distribución de $T$, mediante una versión común de la ley condicional.

  Formalmente:
  $ P_theta (X in A | T(X) = t) = P(X in A | T(X) = t) quad forall theta in ParamSpace, forall A in cal(A) $
]


#thm-env("theorem", name: [Factorización de Neyman-Fisher], key: "thm:ch2-neyman-fisher")[
En espacios estándar de Borel y para una familia dominada por una medida $sigma$-finita, $T$ es suficiente si y solo si se pueden elegir densidades con
  $ f_theta (x)=g_theta (T(x))h(x) $
  casi en todas partes para cada parámetro, con factores no negativos medibles. La igualdad es de versiones de densidades; no exige valores determinados en conjuntos nulos.
]

#proof-env[
En el caso discreto, sumar sobre la fibra $T(x)=t$ y cancelar $g_theta (t)$ muestra que la distribución condicional no depende del parámetro. En el caso continuo no se integra una fibra de medida nula usando la medida ambiente: se utiliza una distribución condicional regular. El argumento mediante una medida dominante de probabilidad y derivadas de Radon–Nikodym se desarrolla en #verdem(<dem:ch2-neyman-fisher>).
]

#thm-env("example", name: [Suficiencia en la Distribución Normal], key: "ex:ch2-normal-suficiencia")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con ambos
  parámetros desconocidos. La densidad conjunta es:
  $ f(bold(x)|mu,sigma^2) = (1/(2 pi sigma^2))^(n/2) exp{-1/(2 sigma^2) sum_(i=1)^n (x_i - mu)^2} $

  Expandiendo el cuadrado:
  $ sum_(i=1)^n (x_i - mu)^2 = sum_(i=1)^n x_i^2 - 2 mu sum_(i=1)^n x_i + n mu^2 $

  Por lo tanto:
  $ f(bold(x)|mu,sigma^2) = underbrace((1/(2 pi sigma^2))^(n/2) exp{-1/(2 sigma^2)(sum x_i^2 - 2 mu sum x_i + n mu^2)}, g(T(bold(x)), mu, sigma^2)) dot underbrace(1, h(bold(x))) $
  donde $T(bold(x)) = (sum_(i=1)^n x_i, sum_(i=1)^n x_i^2)$.

  Por el Teorema de Neyman-Fisher, $T(bold(x)) = (sum x_i, sum x_i^2)$ es
  suficiente para $(mu, sigma^2)$. Equivalentemente,
  $T'(bold(x)) = (overline(X), S^2)$ también es suficiente, ya que existe
  una transformación biyectiva entre $T$ y $T'$.
]


#thm-env("example", name: [Suficiencia en la Distribución de Poisson], key: "ex:ch2-poisson-suficiencia")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Poisson"(lambda)$. La función
  de masa conjunta es:
  $ f(bold(x)|lambda) = product_(i=1)^n (lambda^(x_i) e^(-lambda))/(x_i !) = (lambda^(sum x_i) e^(-n lambda))/(product_(i=1)^n x_i !) $

  Reescribiendo:
  $ f(bold(x)|lambda) = underbrace(exp{(log lambda) sum x_i - n lambda}, g(T(bold(x)), lambda)) dot underbrace(1/(product x_i !), h(bold(x))) $

  Por Neyman-Fisher, $T(bold(x)) = sum_(i=1)^n x_i$ es suficiente para
  $lambda$. Notemos que $T$ tiene dimensión 1 independientemente de $n$:
  esto es la esencia de la reducción de datos.
]

=== Suficiencia Minimal
<sec:ch2-suficiencia-minimal>

No todo estadístico suficiente logra la máxima reducción de datos. Por
ejemplo, la muestra completa $X$ siempre es trivialmente suficiente, pero
no proporciona ninguna reducción. Buscamos el estadístico suficiente de
menor "tamaño" posible.

#thm-env("definition", name: [Suficiencia Minimal], key: "def:ch2-suficiencia-minimal")[
  Un estadístico suficiente $T$ es _minimal_ si, para cualquier otro
  estadístico suficiente $T'$, existe una función medible $phi$ tal que
  $T = phi(T')$ casi seguramente bajo $P_theta$ para todo $theta$.
]


#thm-env("theorem", name: [Caracterización de Suficiencia Minimal (Lehmann-Scheffé)], key: "thm:ch2-lehmann-scheffe", aliases: ("thm:ch2-lehmann-scheffe-minimal",))[
Para una familia dominada con densidades estrictamente positivas en un soporte común, el criterio usual es: si un estadístico medible $T$ satisface
  $ f_theta (x)/f_theta (y) "es constante en" theta <=> T(x)=T(y), $
  con versiones apropiadas fuera de conjuntos nulos y las condiciones medibles de la factorización, entonces es suficiente minimal. Cuando hay ceros, debe usarse proporcionalidad de los vectores de verosimilitud y considerar los soportes; no se dividen densidades nulas.
]

#proof-env[
La relación de proporcionalidad agrupa observaciones que aportan los mismos cocientes de verosimilitud. La factorización muestra suficiencia, y cualquier otro resumen suficiente debe determinar esas clases, salvo conjuntos nulos. Véase #verdem(<dem:ch2-lehmann-scheffe>); no se interpreta el criterio como una igualdad punto a punto para versiones arbitrarias de densidades.
]

#thm-env("example", name: [Suficiencia Minimal en Familias Exponenciales], key: "ex:ch2-minimal-exponencial")[
  En una familia exponencial de rango $k$ en forma canónica:
  $ f(x|eta) = h(x) exp{eta^top T(x) - A(eta)} $

  Para $x, y in SampleSpace$:
  $ (f(x|eta))/(f(y|eta)) = (h(x))/(h(y)) exp{eta^top (T(x) - T(y))} $

  Este cociente no depende de $eta$ si y solo si $T(x) = T(y)$ (asumiendo
  que $eta$ varía en un conjunto abierto). Por el @thm:ch2-lehmann-scheffe,
  el estadístico natural $T(x) = (T_1 (x), ..., T_k (x))$ es suficiente
  minimal cuando la familia es minimal (sin componentes afínmente
  dependientes).
]

=== Completitud
<sec:ch2-completitud>

La completitud es una propiedad adicional que, junto con la suficiencia,
garantiza propiedades de optimalidad únicas. Es fundamental para el
Teorema de Lehmann-Scheffé (@ch:estimacion) y para el Teorema de Basu.

#thm-env("definition", name: [Completitud], key: "def:ch2-completitud")[
  Un estadístico $T$ es _completo_ para la familia
  ${P_theta : theta in ParamSpace}$ si:
  $ EE_theta [g(T)] = 0 "para todo " theta in ParamSpace quad => quad P_theta (g(T) = 0) = 1 "para todo " theta $
  para toda función medible $g$ tal que $EE_theta [abs(g(T))] < infinity$.
]


#thm-env("definition", name: [Completitud Acotada], key: "def:ch2-completitud-acotada")[
  Un estadístico $T$ es _acotadamente completo_ si la condición de
  completitud se cumple para toda función $g$ acotada.
]


#thm-env("theorem", name: [Completitud en Familias Exponenciales], key: "thm:ch2-completitud-exponencial", aliases: ("thm:ch2-completitud-exp",))[
  En una familia exponencial de rango $k$ con espacio de parámetros
  naturales $cal(H)$ que contiene un conjunto abierto de $RR^k$, el
  estadístico natural $T(X)$ es completo.
]

#proofsketch-env[
  Fije un parámetro interior $eta_0$. Si $EE_eta[g(T)]=0$ para todo $eta$, la medida firmada $g(t)P_(eta_0)^T(dif t)$ tiene transformada de Laplace nula cerca de cero. Su unicidad implica que la medida es cero; la equivalencia de las leyes sobre el soporte base extiende la igualdad a toda la familia. La integrabilidad exponencial y los detalles se especifican en #verdem(<dem:ch2-completitud-exponencial>).
]

#thm-env("corollary", key: "cor:ch2-smc")[
  Bajo un dominio natural que contiene un abierto, el estadístico natural es
  *suficiente, minimal y completo* (SMC).
]


#thm-env("example", name: [Familia Exponencial Multinomial para SSCH], key: "ex:ch2-multinomial-ssch")[
Fije estado y acción. Suponga diez transiciones independientes hacia tres categorías con probabilidades estrictamente positivas $(theta_1,theta_2,theta_3)$. Los conteos son multinomiales. Use $theta_3$ como categoría de referencia:
  $ eta_j=log(theta_j/theta_3), quad j=1,2, quad A(eta)=n log(1+e^(eta_1)+e^(eta_2)). $
  El estadístico natural es $(N_1,N_2)$; $N_3=n-N_1-N_2$ es redundante. El parámetro natural recorre $RR^2$, por lo que los conteos son suficientes y completos.

  Para $(N_1,N_2,N_3)=(2,5,3)$, el MLE es $(0.2,0.5,0.3)$. Cada proporción es insesgada, con varianza $theta_j (1-theta_j)/n$; entre categorías, la covarianza es $-theta_j theta_k/n$. Esas covarianzas deben conservarse al propagar incertidumbre hacia el valor. El supuesto multinomial aquí corresponde a transiciones independientes recolectadas para el mismo par estado–acción; no convierte una trayectoria longitudinal completa en datos iid.
]

=== Ancillaridad y el Teorema de Basu
<sec:ch2-ancillaridad>

#thm-env("definition", name: [Estadístico Ancilar], key: "def:ch2-ancilar")[
  Un estadístico $A(X)$ es _ancilar_ (o ancilario) para $theta$ si su
  distribución no depende de $theta$:
  $ P_theta (A(X) in B) = P(A(X) in B) quad forall theta in ParamSpace, forall B $
]


#thm-env("example", name: [Ancilaridad en Modelo de Localización], key: "ex:ch2-ancilar-localizacion")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") f(x - theta)$ donde $f$ es una
  densidad simétrica conocida centrada en cero. Entonces:
  - $overline(X)$ es equivariante bajo traslaciones, pero no es suficiente en una familia de localización general. La suficiencia requiere comprobar la factorización.
  - Los residuos centrados $D_i = X_i - overline(X)$ para $i = 1, ..., n$
    son ancilares: su distribución conjunta no depende de $theta$ ya que
    $(X_i - theta) - 1/n sum_j (X_j - theta) = D_i$

  La configuración de los residuos nos dice sobre la "forma" de la muestra,
  pero no sobre su localización $theta$.
]


#thm-env("theorem", name: [Teorema de Basu], key: "thm:ch2-basu")[
  Sea $T$ un estadístico suficiente completo para $theta$, y sea $A$ un
  estadístico ancilar. Entonces $T$ y $A$ son independientes bajo $P_theta$
  para todo $theta in ParamSpace$.
]

#proof-env[
  Definimos la función $g: cal(T) -> RR$ por:
  $ g(t) = P(A in B | T = t) - P(A in B) $
  para un conjunto medible $B$ arbitrario. Mostraremos que
  $EE_theta [g(T)] = 0$ para todo $theta$:
  $
    EE_theta [g(T)] &= EE_theta [P(A in B | T)] - P(A in B) \
    &= P_theta (A in B) - P(A in B) \
    &= 0
  $
  donde la última igualdad se debe a que $A$ es ancilar, por lo que
  $P_theta (A in B) = P(A in B)$ no depende de $theta$.

  Por completitud de $T$, concluimos que $g(T) = 0$ casi seguramente, es
  decir:
  $ P(A in B | T = t) = P(A in B) quad "para casi todo " t $
  Esto implica que $A$ es independiente de $T$.
]

#thm-env("example", name: [Aplicación del Teorema de Basu], key: "ex:ch2-basu-aplicacion")[
  En la muestra normal $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$
  con $sigma^2$ conocida:
  - $overline(X)$ es suficiente completo para $mu$ (por el @thm:ch2-completitud-exponencial)
  - El vector $(X_1 - overline(X), ..., X_n - overline(X))$ es ancilar (su distribución no depende de $mu$)

  Por el Teorema de Basu, $overline(X)$ es independiente de los residuos
  centrados. En particular, $overline(X)$ es independiente de
  $S^2 = 1/(n-1) sum_(i=1)^n (X_i - overline(X))^2$.

  Esta independencia, que normalmente se demuestra mediante cálculos
  laboriosos con la distribución normal multivariante, se obtiene aquí
  como corolario inmediato de un resultado general.
]

=== Equivarianza
<sec:ch2-equivarianza>

El principio de equivarianza proporciona otra vía de reducción,
restringiendo la clase de estimadores a aquellos que respetan las
simetrías inherentes del problema.

#thm-env("definition", name: [Grupo de Transformaciones e Invariancia], key: "def:ch2-invariancia")[
  Sea $cal(G)$ un grupo que actúa sobre $SampleSpace$ (espacio muestral) y
  sobre $ParamSpace$ (espacio de parámetros). Decimos que el modelo
  ${P_theta : theta in ParamSpace}$ es _invariante_ bajo $cal(G)$ si:
  $ X tilde P_theta quad => quad g X tilde P_(g theta) quad forall g in cal(G) $
  donde $g X$ denota la acción de $g$ sobre $X$ y $g theta$ la acción sobre
  $theta$.
]


#thm-env("definition", name: [Estimador Equivariante], key: "def:ch2-equivariante")[
  Un estimador $hat(theta): SampleSpace -> ParamSpace$ es _equivariante_
  bajo $cal(G)$ si:
  $ hat(theta)(g X) = g hat(theta)(X) quad forall g in cal(G), forall X in SampleSpace $
]


#thm-env("theorem", name: [Principio de Equivarianza], key: "thm:ch2-equivarianza")[
Si el modelo y la pérdida son invariantes y $delta$ es equivariante, entonces $R(g theta,delta)=R(theta,delta)$. El riesgo es constante sobre cada órbita del grupo; es constante en todo el espacio únicamente si la acción es transitiva. La existencia de una regla equivariante minimax requiere hipótesis adicionales y no se deduce de invariancia sola.
]

#proof-env[
Si $X tilde P_theta$, entonces $g X tilde P_(g theta)$. Por equivarianza e invariancia,
  $ R(g theta,delta)=EE_theta[L(g theta,delta(g X))]=EE_theta[L(g theta,g delta(X))]=R(theta,delta). $
  Promediar sobre un grupo no compacto requiere cuidado: una medida de Haar no es en general una probabilidad. No se usa aquí para afirmar minimax. Véase #verdem(<dem:ch2-equivarianza>).
]

#thm-env("example", name: [Equivarianza bajo Traslaciones], key: "ex:ch2-traslaciones")[
  Para $X_1, ..., X_n attach(tilde, t: "iid") f(x - theta)$ con
  $theta in RR$, el grupo de traslaciones $cal(G) = (RR, +)$ actúa por:
  - $g dot x_i = x_i + g$ (sobre los datos)
  - $g dot theta = theta + g$ (sobre el parámetro)

  Un estimador $hat(theta)$ es equivariante si
  $hat(theta)(X_1 + c, ..., X_n + c) = hat(theta)(X_1, ..., X_n) + c$ para
  todo $c in RR$.

  La media muestral $overline(X)$ es equivariante. La mediana muestral
  también lo es. El estimador $hat(theta) = X_1$ (usar solo la primera
  observación) también es equivariante. En el modelo normal con $n>1$ y pérdida cuadrática, su riesgo es $sigma^2$, frente a $sigma^2/n$ de la media; esta comparación no se extiende sin condiciones a toda familia de localización.
]


#thm-env("example", name: [Equivarianza bajo Escala], key: "ex:ch2-escala")[
  Para $X_1, ..., X_n attach(tilde, t: "iid") 1/sigma f(x/sigma)$ con
  $sigma > 0$, el grupo multiplicativo $cal(G) = (RR^+, dot)$ actúa por:
  - $g dot x_i = g dot x_i$ (multiplicación)
  - $g dot sigma = g dot sigma$

  Un estimador $hat(sigma)$ es equivariante si
  $hat(sigma)(c X_1, ..., c X_n) = c dot hat(sigma)(X_1, ..., X_n)$ para
  todo $c > 0$.

  La desviación estándar muestral $S$ es equivariante. También lo es el
  rango $R = X_((n)) - X_((1))$ multiplicado por cualquier constante.
]


== Estimar y comparar la precisión de los procedimientos

Una vez definido qué información retiene la muestra, interesa cómo convertirla en una estimación. El criterio de comparación determina qué mejoras buscamos: reducir riesgo, conservar insesgadez o alcanzar una cota de precisión.

=== Criterios de optimalidad en estimación puntual
<sec:ch3-sesgo-varianza>

La teoría de estimación puntual busca estadísticos $hat(theta)(X)$ que
aproximen el parámetro verdadero $theta$ de manera óptima según algún
criterio formal.

#thm-env("definition", name: [Error Cuadrático Medio], key: "def:ch3-ecm")[
  El _error cuadrático medio_ (ECM) de un estimador $hat(theta)$ es:
  $ "ECM"_theta (hat(theta)) = EE_theta [(hat(theta)(X) - theta)^2] $
]

=== El Teorema de Rao-Blackwell
<sec:ch3-rao-blackwell>

El teorema de Rao-Blackwell proporciona un método constructivo para
mejorar estimadores mediante condicionamiento sobre estadísticos
suficientes (ver @ch:reduccion).

#thm-env("theorem", name: [Rao-Blackwell], key: "thm:ch3-rao-blackwell")[
  Sea $hat(theta)$ un estimador de $theta$ con $EE_theta [hat(theta)^2] < infinity$
  para todo $theta$, y sea $T$ un estadístico suficiente para $theta$.
  Definamos:
  $ tilde(theta) = EE[hat(theta) | T] $
  Entonces:
  + $tilde(theta)$ es un estadístico (función de $T$ únicamente)
  + $EE_theta [tilde(theta)] = EE_theta [hat(theta)]$ (mismo sesgo)
  + $Var_theta (tilde(theta)) <= Var_theta (hat(theta))$ para todo $theta$, con igualdad si y solo si $hat(theta)$ es función de $T$ casi seguramente
]

#proof-env[
  *(1)* Por suficiencia, la distribución condicional de $X$ dado $T$ no
  depende de $theta$ (@def:ch2-suficiencia), por lo que $EE[hat(theta) | T]$
  no depende de $theta$ y es función medible de $T$.

  *(2)* Por la ley de esperanzas iteradas:
  $ EE_theta [tilde(theta)] = EE_theta [EE[hat(theta) | T]] = EE_theta [hat(theta)] $

  *(3)* Por la ley de varianza total:
  $ Var_theta (hat(theta)) = EE_theta [Var(hat(theta) | T)] + Var_theta (EE[hat(theta) | T]) $
  Como $EE_theta [Var(hat(theta) | T)] >= 0$:
  $ Var_theta (hat(theta)) >= Var_theta (tilde(theta)) $
  La igualdad se da si y solo si $Var(hat(theta) | T) = 0$ c.s., es decir,
  $hat(theta)$ es función de $T$.
]

#thm-env("corollary", key: "cor:ch3-rb-insesgado")[
  Si $hat(theta)$ es insesgado, entonces $tilde(theta) = EE[hat(theta) | T]$
  también es insesgado y tiene varianza menor o igual.
]


#thm-env("example", name: [Rao-Blackwellización en Bernoulli], key: "ex:ch3-rb-bernoulli")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Bernoulli"(p)$.
  - Estimador inicial: $hat(p) = X_1$ (insesgado, usa solo una observación)
  - Estadístico suficiente: $T = sum_(i=1)^n X_i$
  - Estimador Rao-Blackwellizado:
  $ tilde(p) = EE[X_1 | T] = T/n = overline(X) $
  La varianza mejora de $Var(X_1) = p(1-p)$ a $Var(overline(X)) = p(1-p)\/n$,
  una reducción por factor $n$.
]

=== El Teorema de Lehmann-Scheffé y UMVUE
<sec:ch3-lehmann-scheffe>

#thm-env("definition", name: [UMVUE], key: "def:ch3-umvue")[
  Un estimador $hat(theta)^*$ es el _estimador insesgado de varianza
  uniformemente mínima_ (UMVUE) para $g(theta)$ si:
  + $EE_theta [hat(theta)^*] = g(theta)$ para todo $theta$ (insesgado)
  + Para cualquier otro estimador insesgado $tilde(theta)$ de $g(theta)$: $Var_theta (hat(theta)^*) <= Var_theta (tilde(theta))$ para todo $theta in ParamSpace$
]


#thm-env("theorem", name: [Lehmann-Scheffé], key: "thm:ch3-lehmann-scheffe")[
  Sea $T$ un estadístico suficiente y completo para $theta$ (ver
  @def:ch2-completitud). Si $hat(theta)$ es cualquier estimador insesgado de varianza finita
  de $g(theta)$, entonces:
  $ hat(theta)^* = EE[hat(theta) | T] $
  es el único UMVUE para $g(theta)$, salvo igualdad casi segura bajo cada modelo.
]

#proof-env[
  *Existencia:* Por Rao-Blackwell (@thm:ch3-rao-blackwell),
  $hat(theta)^* = EE[hat(theta) | T]$ es insesgado y tiene varianza no mayor que la del estimador inicial. La comparación con otros estimadores requiere completitud, como se prueba a continuación.

  *Optimalidad global:* Sea $delta$ cualquier estimador insesgado de
  $g(theta)$. Definamos $delta^* = EE[delta | T]$. Por Rao-Blackwell,
  $Var_theta (delta^*) <= Var_theta (delta)$.

  Ahora, tanto $hat(theta)^*$ como $delta^*$ son funciones de $T$ e
  insesgados para $g(theta)$. Por lo tanto:
  $ EE_theta [hat(theta)^* - delta^*] = g(theta) - g(theta) = 0 quad forall theta $
  Por completitud de $T$ (@def:ch2-completitud), esto implica
  $hat(theta)^* = delta^*$ casi seguramente.

  Por lo tanto, $Var_theta (hat(theta)^*) = Var_theta (delta^*) <= Var_theta (delta)$
  para todo $delta$ insesgado.

  *Unicidad:* Si $hat(theta)_1^*$ y $hat(theta)_2^*$ son ambos UMVUE,
  la igualdad en Rao–Blackwell obliga a que ambos sean funciones de $T$ casi seguramente; la completitud aplicada a su diferencia prueba que coinciden.
]

#thm-env("corollary", key: "cor:ch3-umvue-exponencial")[
  En familias exponenciales regulares, el estadístico natural $T$ es
  suficiente completo (@cor:ch2-smc), y cualquier función insesgada de $T$ con segundo momento finito bajo cada modelo
  es el UMVUE.
]

=== La Cota Inferior de Cramér-Rao
<sec:ch3-cramer-rao>

La cota de Cramér-Rao establece un límite fundamental para la precisión
alcanzable por cualquier estimador insesgado.

#thm-env("definition", name: [Información de Fisher], key: "def:ch3-fisher")[
  Sea $f(x|theta)$ la densidad de $X$ con $theta in ParamSpace subset.eq RR$.
  La _información de Fisher_ es:
  $ I(theta) = EE_theta [(partial/(partial theta) log f(X|theta))^2] $
  Bajo condiciones de regularidad (intercambio de derivación e
  integración):
  $ I(theta) = -EE_theta [(partial^2)/(partial theta^2) log f(X|theta)] $
]


#thm-env("definition", name: [Función Score], key: "def:ch3-score")[
  La _función score_ es:
  $ S(theta; X) = partial/(partial theta) log f(X|theta) $
  Bajo regularidad, $EE_theta [S(theta; X)] = 0$ y
  $Var_theta (S(theta; X)) = I(theta)$.
]


#thm-env("theorem", name: [Cota Inferior de Cramér-Rao], key: "thm:ch3-cramer-rao")[
  Suponga parámetro interior escalar, soporte común, diferenciación bajo la integral para la densidad y para la esperanza del estimador, score centrado, $0<I(theta)<infinity$ y varianza finita. Para cualquier estimador $hat(theta)$ de
  $g(theta)$ con $EE_theta [hat(theta)] = g(theta) + b(theta)$ (donde
  $b(theta)$ es el sesgo):
  $ Var_theta (hat(theta)) >= ([g'(theta) + b'(theta)])^2/I(theta) $
  Para estimadores insesgados ($b(theta) = 0$):
  $ Var_theta (hat(theta)) >= (g'(theta))^2/I(theta) $
  En particular, para estimar $theta$ directamente sin sesgo ($g(theta) = theta$, $b=0$):
  $ Var_theta (hat(theta)) >= 1/I(theta) $
]

#proof-env[
  Utilizamos la desigualdad de Cauchy-Schwarz. Sea $S = S(theta; X)$ la
  función score. Entonces:
  $ Cov_theta (hat(theta), S)^2 <= Var_theta (hat(theta)) dot Var_theta (S) = Var_theta (hat(theta)) dot I(theta) $

  Calculamos la covarianza. Bajo regularidad, diferenciando
  $EE_theta [hat(theta)] = g(theta) + b(theta)$:
  $ dif/(dif theta) integral hat(theta)(x) f(x|theta) dif x = g'(theta) + b'(theta) $
  $ integral hat(theta)(x) (partial f)/(partial theta) dif x = integral hat(theta)(x) f(x|theta) dot (partial log f)/(partial theta) dif x = EE_theta [hat(theta) dot S] $

  Como $EE_theta [S] = 0$:
  $ Cov_theta (hat(theta), S) = EE_theta [hat(theta) dot S] = g'(theta) + b'(theta) $

  Sustituyendo en Cauchy-Schwarz:
  $ (g'(theta) + b'(theta))^2 <= Var_theta (hat(theta)) dot I(theta) $
  Despejando se obtiene la cota.
]

#thm-env("definition", name: [Eficiencia], key: "def:ch3-eficiencia")[
  Un estimador insesgado $hat(theta)$ de $theta$ es _eficiente_ si alcanza
  la cota de Cramér-Rao:
  $ Var_theta (hat(theta)) = 1/I(theta) $
]

La información de una muestra independiente se obtiene sumando las contribuciones de sus observaciones. Esa identidad permite expresar la cota en función del tamaño de muestra.

#thm-env("proposition", name: [Aditividad de la Información], key: "prop:ch3-info-aditiva")[
  Si $X_1, ..., X_n$ son iid con información de Fisher $I_1 (theta)$ por
  observación, entonces la información total es:
  $ I_n (theta) = n dot I_1 (theta) $
]

#proof-env[
  Por independencia, el score total es la suma de scores individuales:
  $ S_n (theta; X_1, ..., X_n) = sum_(i=1)^n partial/(partial theta) log f(X_i|theta) $
  Por independencia e idéntica distribución:
  $ I_n (theta) = Var_theta (S_n) = sum_(i=1)^n Var_theta (S_i) = n dot I_1 (theta) $
]

#thm-env("corollary", name: [Cota de Cramér-Rao para Muestras iid], key: "cor:ch3-cr-iid")[
  Para un estimador insesgado de $theta$ basado en $n$ observaciones iid y bajo las condiciones de Cramér–Rao:
  $ Var_theta (hat(theta)) >= 1/(n dot I_1 (theta)) $
  La cota decrece como $1/n$; no implica que se alcance para todo modelo y parámetro.
]

=== El Estimador de Máxima Verosimilitud
<sec:ch3-mle>

#thm-env("definition", name: [Función de Verosimilitud], key: "def:ch3-verosimilitud")[
  Para datos iid $bold(x) = (x_1, ..., x_n)$, la _función de
  verosimilitud_ es:
  $ L(theta; bold(x)) = product_(i=1)^n f(x_i|theta) $
  La _log-verosimilitud_ es
  $ell(theta; bold(x)) = log L(theta; bold(x)) = sum_(i=1)^n log f(x_i|theta)$.
]


#thm-env("definition", name: [Estimador de Máxima Verosimilitud], key: "def:ch3-mle")[
  El _MLE_ es:
  $ hat(theta)_"MLE" = argmax_(theta in ParamSpace) L(theta; bold(x)) = argmax_(theta in ParamSpace) ell(theta; bold(x)) $
]


#thm-env("theorem", name: [Propiedades del MLE bajo Regularidad], key: "thm:ch3-mle-propiedades", aliases: ("thm:ch3-mle-asintotico",))[
Suponga datos iid de un modelo correctamente especificado e identificable, parámetro verdadero interior, existencia de un máximo y consistencia de la secuencia de máximos elegida. Para garantizar esta última pueden usarse una ley uniforme de grandes números y separación del máximo poblacional. Suponga además score de varianza finita $0<I_1 (theta_0)<infinity$, diferenciabilidad local y convergencia uniforme del Hessiano normalizado a $-I_1 (theta_0)$. Entonces
  $ sqrt(n)(hat(theta)_"MLE"-theta_0) limits(->)^d N(0,I_1 (theta_0)^(-1)). $
  Bajo regularidad local del experimento, alcanza la cota asintótica entre estimadores regulares. La propiedad de invarianza usa maximización de la verosimilitud perfilada si la transformación no es inyectiva. Fronteras, mezclas singulares y mala especificación requieren otros resultados.
]

#proofsketch-env[
  *(Normalidad asintótica)* Expandiendo la ecuación score
  $sum_i S(theta; X_i) = 0$ en Taylor alrededor de $theta_0$:
  $ 0 = sum_(i=1)^n S(theta_0; X_i) + (hat(theta)_"MLE" - theta_0) sum_(i=1)^n S'(tilde(theta); X_i) $
  donde $tilde(theta)$ está entre $hat(theta)_"MLE"$ y $theta_0$.
  Reorganizando:
  $ sqrt(n)(hat(theta)_"MLE" - theta_0) = (1/sqrt(n) sum_(i=1)^n S(theta_0; X_i))/(-1/n sum_(i=1)^n S'(tilde(theta); X_i)) $

  Por el CLT, el numerador converge a $N(0, I_1 (theta_0))$. Por la LGN, el
  denominador converge a $I_1 (theta_0)$. Por Slutsky, el cociente converge
  a $N(0, 1\/I_1 (theta_0))$.

  Ver #cite(<vaart1998asymptotic>, form: "prose"), Capítulo 5.
  #verdem(<dem:ch3-mle-asintotica>)
]

#thm-env("example", name: [MLE para la Normal], key: "ex:ch3-mle-normal")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$. La
  log-verosimilitud es:
  $ ell(mu, sigma^2) = -n/2 log(2 pi) - n/2 log sigma^2 - 1/(2 sigma^2) sum_(i=1)^n (x_i - mu)^2 $

  Las ecuaciones de verosimilitud dan:
  $ hat(mu)_"MLE" = overline(X), quad hat(sigma)^2_"MLE" = 1/n sum_(i=1)^n (X_i - overline(X))^2 $

  El MLE de $sigma^2$ es sesgado (factor $(n-1)/n$), pero consistente y
  asintóticamente eficiente.
]


#thm-env("example", name: [Regularidad, mala especificación y frontera], key: "ex:ch4-regularidad")[
  Si se ajusta una normal de varianza fijada a datos iid de media $mu_0$ y varianza real $tau^2$, el MLE de la media sigue siendo $overline(Y)$. Su varianza asintótica es $tau^2/n$, no la varianza impuesta al modelo dividida por $n$. Estimar la varianza de los datos puede corregir el error estándar de esa media; no corrige automáticamente otros objetivos de un modelo mal especificado.

  En general, un estimador de ecuaciones regulares tiene matriz sándwich $H^(-1)J H^(-top)$, donde $H$ es la derivada media del momento y $J$ su matriz de covarianza. Con dependencia se reemplaza $J$ por una covarianza de largo plazo.

  Para $X_i tilde "Uniforme"(0,theta)$, el máximo converge a escala $n$, no $sqrt(n)$: $n(1-X_((n))/theta)$ converge a una exponencial de media uno. El soporte depende del parámetro y el score formal no tiene media cero. Esta es una frontera del razonamiento regular de Fisher, no una violación de Cramér–Rao.
]

=== Métodos Computacionales Bayesianos: MCMC e Inferencia Variacional
<sec:ch3-mcmc-vi>

Los resultados de optimalidad frecuentista no exigen una fórmula cerrada. Sin embargo, el error numérico debe controlarse por separado del error estadístico. En la práctica
del agente inteligente, las distribuciones a posteriori rara vez admiten
soluciones analíticas, y se requieren métodos computacionales para
aproximar integrales de alta dimensión. Aquí se consideran *Markov Chain Monte Carlo (MCMC)* e *inferencia variacional (VI)*, que aproximan el posterior de maneras distintas.

#thm-env("definition", name: [Algoritmo de Metropolis-Hastings], key: "def:ch3-mh")[
  Sea $pi(theta) prop L(theta) p(theta)$ la distribución a posteriori de
  interés (no normalizada). El algoritmo _Metropolis-Hastings_ genera una
  cadena de Markov ${theta^((t))}$ con distribución estacionaria
  $pi(theta)$ mediante:
  + Dado $theta^((t))$, proponer $theta^* tilde q(dot | theta^((t)))$
  + Calcular la probabilidad de aceptación: $ alpha = min(1, (pi(theta^*) q(theta^((t)) | theta^*))/(pi(theta^((t))) q(theta^* | theta^((t))))) $
  + Con probabilidad $alpha$, aceptar $theta^((t+1)) = theta^*$; caso contrario, $theta^((t+1)) = theta^((t))$

  Bajo recurrencia de Harris positiva, irreducibilidad y aperiodicidad adecuadas, la cadena converge
  a $pi(theta)$ y se satisface el Teorema Ergódico:
  $1/T sum_(t=1)^T g(theta^((t))) -> EE_pi [g(theta)]$ para funciones integrables. Un CLT y un error estándar requieren condiciones adicionales.
]


#thm-env("definition", name: [Inferencia Variacional y ELBO], key: "def:ch3-vi")[
  La _Inferencia Variacional_ aproxima la posterior $pi(theta)$ mediante
  una distribución $q_lambda (theta)$ en una familia variacional
  $cal(Q)$, minimizando la divergencia de Kullback-Leibler:
  $ KL(q_lambda || pi) = EE_(q_lambda)[log q_lambda (theta)] - EE_(q_lambda)[log pi(theta)]. $
  Equivalentemente, se maximiza la _Evidence Lower Bound_ (ELBO):
  $ "ELBO"(lambda) = EE_(q_lambda)[log L(theta)] - KL(q_lambda || p), $
  donde $L(theta)$ es la verosimilitud y $p(theta)$ la prior. La
  maximización del ELBO equivale a minimizar $KL(q_lambda || pi)$, ya que
  $log p(X) = "ELBO"(lambda) + KL(q_lambda || pi)$.
]

Las dos aproximaciones difieren en el error que permanece al aumentar el esfuerzo de cálculo. Esa diferencia importa al utilizar sus resultados para decidir.

#thm-env("note", name: [Comparación MCMC vs. VI], key: "prop:ch3-mcmc-vi-comp")[
Bajo las condiciones ergódicas indicadas, los promedios MCMC convergen al promedio posterior, aunque el error Monte Carlo finito y su varianza requieren control. En VI, la restricción de la familia puede dejar error de aproximación incluso con optimización exacta; ese error es cero si la familia contiene el posterior y se alcanza el mínimo global. Rapidez, escalabilidad y precisión dependen del problema y de la implementación, no son una ordenación universal de ambos métodos.

]

Un posterior conjugado permite observar esa diferencia con una referencia conocida.

#thm-env("example", name: [SSCH --- Estimación Bayesiana de Probabilidades de Transición], key: "ex:ssch-mcmc-vi-cap03", es-sintetico: true)[
Use los conteos sintéticos $(2,5,3)$ y prior $"Dirichlet"(1,1,1)$, uniforme sobre el simplex, sin llamarlo neutral frente a toda parametrización. El posterior es $"Dirichlet"(3,6,4)$ y su media $(3/13,6/13,4/13)$. La varianza de la segunda probabilidad es $6(13-6)/(13^2(14))=3/169$.

  Este posterior permite muestreo directo independiente y proporciona una referencia exacta para comprobar un algoritmo MCMC. Si la familia variacional contiene todas las Dirichlet, contiene el posterior exacto y el mínimo global de KL es cero. Una Dirichlet no factoriza en variables independientes sobre sus coordenadas: suman uno. No se reportan tiempos, ESS ni diagnósticos de cadenas que no se hayan ejecutado.
]

==== Aproximación posterior fuera de la conjugación
<sec:ch3-bayes-comp>

El ejemplo conjugado anterior proporciona una referencia exacta. Fuera de la conjugación, MCMC y la aproximación variacional permiten continuar el cálculo, con errores que deben distinguirse de la incertidumbre estadística. Esa diferencia orienta la lectura de los diagnósticos y del ejemplo siguiente.

*Markov Chain Monte Carlo (MCMC).* La idea central de MCMC es construir
una cadena de Markov cuya distribución estacionaria sea el posterior
$pi(theta|x)$. El algoritmo de Metropolis-Hastings #cite(<gelman2013>)
genera una propuesta $theta^* tilde q(dot|theta^((t)))$ y la acepta con
probabilidad
$alpha = min(1, (pi(theta^*|x) q(theta^((t))|theta^*))/(pi(theta^((t))|x) q(theta^*|theta^((t)))))$.
Bajo condiciones de irreducibilidad y aperiodicidad,
  $theta^((t)) limits(->)^d pi(theta|x)$. El tamaño muestral efectivo y $hat(R)$ son diagnósticos, no pruebas de convergencia. Bajo las condiciones de estacionariedad, momentos y mezcla de @thm:ch4-clt-mixing, un CLT permite aproximar el error Monte Carlo. Para un inicio no estacionario se debe justificar la extensión correspondiente.

*Variational Inference (VI).* VI reformula la inferencia como un
problema de optimización: en lugar de muestrear del posterior, se busca
la distribución $q^*$ en una familia $cal(Q)$ que minimiza
$"KL"(q || pi(dot|x))$. Equivalentemente, VI maximiza el _Evidence Lower
Bound_ (ELBO):
$ "ELBO"(q) = EE_q [log p(x,theta)] - EE_q [log q(theta)]. $
La descomposición $log p(x) = "ELBO"(q) + "KL"(q || pi(dot|x))$ revela
que maximizar el ELBO equivale a minimizar la divergencia KL al
posterior. El ELBO acota la log-evidencia $log p(X)$, no el riesgo de Bayes bajo una pérdida arbitraria. La calidad de decisiones e intervalos requiere evaluar además el efecto de la aproximación posterior.

#thm-env("example", name: [MCMC para el SSCH con Prior No Conjugado], key: "ex:ch3-mcmc-ssch")[
Para tres destinos, parametrice $theta_j=e^(z_j)/(1+e^(z_1)+e^(z_2))$ para $j=1,2$ y $theta_3=1/(1+e^(z_1)+e^(z_2))$. Un prior $z tilde N_2 (0,I)$ induce una logística normal no conjugada. Con conteos $(2,5,3)$,
  $ ell(z)=2z_1+5z_2-10log(1+e^(z_1)+e^(z_2))-norm(z)^2/2+C. $
  Una propuesta simétrica $z'=z+epsilon$, $epsilon tilde N_2 (0,0.1^2 I)$, se acepta con probabilidad $min(1,exp(ell(z')-ell(z)))$. En $z=(0,0)$ y $z'=(0,0.1)$, la diferencia es aproximadamente $0.15044$ y la aceptación vale uno. Esto ilustra un paso, no una cadena convergida. El prior está definido en logits, por lo que no se agrega un jacobiano a esta densidad en $z$.
]

== Contrastar hipótesis con una regla de error explícita

Estimar un objetivo y decidir si los datos contradicen una hipótesis plantean preguntas relacionadas. Para pasar a la segunda debemos fijar las acciones del contraste y los errores que se pretende controlar.

=== Formulación del problema de contraste
<sec:ch4-neyman-pearson>

#thm-env("definition", name: [Hipótesis Estadísticas], key: "def:ch4-hipotesis")[
  Sea $cal(P) = {P_theta : theta in ParamSpace}$ un modelo paramétrico. Un
  _test de hipótesis_ contrasta:
  $ H_0: theta in ParamSpace_0 quad "versus" quad H_1: theta in ParamSpace_1 $
  donde $ParamSpace_0 union ParamSpace_1 subset.eq ParamSpace$ y
  típicamente $ParamSpace_0 inter ParamSpace_1 = emptyset$. $H_0$ es la
  _hipótesis nula_, $H_1$ la _alternativa_. Si $ParamSpace_0 = {theta_0}$,
  $H_0$ es _simple_; de lo contrario es _compuesta_.
]


#thm-env("definition", name: [Test y Región Crítica], key: "def:ch4-test")[
  Un _test_ (no aleatorizado) es una función $phi: SampleSpace -> {0, 1}$:
  - $phi(x) = 1$: rechazar $H_0$
  - $phi(x) = 0$: no rechazar $H_0$

  La _región crítica_ es $C = {x in cal(X): phi(x) = 1}$.

  Un _test aleatorizado_ es $phi: SampleSpace -> [0, 1]$ donde $phi(x)$ es
  la probabilidad de rechazar $H_0$ dado $X = x$.
]


#thm-env("definition", name: [Errores Tipo I y II], key: "def:ch4-errores")[
  #align(center)[
    #table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      hl(),
      table.header([*Decisión*], $H_0$ + [ verdadera], $H_1$ + [ verdadera]),
      hl(w: 0.6pt),
      [No rechazar $H_0$], [Correcta], [Error Tipo II ($beta$)],
      [Rechazar $H_0$], [Error Tipo I ($alpha$)], [Correcta (Poder = $1-beta$)],
      hl(),
    )
  ]
]


#thm-env("definition", name: [Función de Potencia], key: "def:ch4-potencia")[
  La _función de potencia_ de un test $phi$ es:
  $ beta_phi (theta) = EE_theta [phi(X)] = P_theta ("rechazar " H_0) $
  Para $theta in ParamSpace_0$: probabilidad de error Tipo I. Para
  $theta in ParamSpace_1$: _poder_ del test.
]


#thm-env("definition", name: [Tamaño y Nivel], key: "def:ch4-tamano")[
  El _tamaño_ de un test $phi$ es
  $alpha_phi = sup_(theta in ParamSpace_0) beta_phi (theta)$. Un test
  tiene _nivel_ $alpha$ si $alpha_phi <= alpha$.
]


#thm-env("theorem", name: [Lema de Neyman-Pearson], key: "thm:ch4-neyman-pearson")[
  Para el test de $H_0: theta = theta_0$ versus $H_1: theta = theta_1$,
  sea $Lambda(x) = (f(x|theta_1))/(f(x|theta_0))$ el _cociente de
  verosimilitudes_. Para cualquier $alpha in (0,1)$, existe un test
  $phi^*$ de la forma:
  $
    phi^*(x) = cases(
      1 & "si " Lambda(x) > k,
      gamma & "si " Lambda(x) = k,
      0 & "si " Lambda(x) < k,
    )
  $
  donde $k >= 0$ y $gamma in [0,1]$ satisfacen
  $EE_(theta_0)[phi^*(X)] = alpha$.

  Este test $phi^*$ es el _test más potente_ (MP) de nivel $alpha$: para
  cualquier otro test $phi$ con $EE_(theta_0)[phi(X)] <= alpha$:
  $ EE_(theta_1)[phi^*(X)] >= EE_(theta_1)[phi(X)] $
]

#proof-env[
Use densidades $f_0,f_1$ respecto de una medida común. Donde $f_0=0<f_1$, la razón se define como infinita y se rechaza; donde ambas son cero la decisión no afecta el resultado. El umbral se elige como cuantil bajo $P_0$ y se aleatoriza en el átomo si es necesario. Con $D=phi^*-phi$, se tiene $D(f_1-k f_0)>=0$ punto a punto. Integrar da $EE_1[D]>=k EE_0[D]>=0$. Esta prueba evita dividir por cero y no requiere continuidad de la distribución de la razón. Véase #verdem(<dem:ch4-neyman-pearson>).
]

#thm-env("example", name: [Test MP para Normal], key: "ex:ch4-mp-normal")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con $sigma^2$
  conocida. Para $H_0: mu = mu_0$ versus $H_1: mu = mu_1 > mu_0$:
  $ Lambda(bold(x)) = exp{((mu_1 - mu_0))/sigma^2 sum x_i - (n(mu_1^2 - mu_0^2))/(2 sigma^2)} $

  $Lambda(bold(x)) > k$ equivale a $overline(x) > c$ para algún $c$. El
  test MP rechaza cuando $overline(X) > mu_0 + z_(1-alpha) dot sigma/sqrt(n)$.
]

=== Tests Uniformemente Más Potentes
<sec:ch4-ump>

#thm-env("definition", name: [Test UMP], key: "def:ch4-ump")[
  Un test $phi^*$ es _uniformemente más potente_ (UMP) de nivel $alpha$
  si:
  + $sup_(theta in ParamSpace_0) EE_theta [phi^*] <= alpha$
  + Para todo $theta in ParamSpace_1$ y todo test $phi$ de nivel $alpha$: $EE_theta [phi^*] >= EE_theta [phi]$
]


#thm-env("theorem", name: [Existencia de UMP en Familias MLR], key: "thm:ch4-mlr")[
  Sea $cal(P)$ una familia con _cociente de verosimilitudes monótono_
  (MLR) en $T(X)$:
  $ (f(x|theta_2))/(f(x|theta_1)) "es no decreciente en " T(x) "para " theta_2 > theta_1 $

  Para $H_0: theta <= theta_0$ versus $H_1: theta > theta_0$, el test UMP
  de nivel $alpha$ rechaza cuando $T(X) > c$, con aleatorización en $T=c$ si es necesaria, elegida para que $EE_(theta_0)[phi]=alpha$. El orden estocástico inducido por MLR controla el nivel en toda la nula compuesta.
]

#proofsketch-env[
  Para cada $theta_1 > theta_0$, el test de Neyman-Pearson rechaza para
  $Lambda(x)$ grande, que por MLR equivale a $T(x)$ grande. Como la
  región crítica ${T > c}$ no depende de $theta_1$, el mismo test es MP
  para todos los $theta_1 > theta_0$.

  Ver #cite(<lehmann2005testing>, form: "prose"), Capítulo 3.
  #verdem(<dem:ch4-mlr>)
]

#thm-env("corollary", key: "cor:ch4-exp-mlr")[
  Las familias exponenciales canónicas de un parámetro, ordenadas por su parámetro natural, tienen MLR en el estadístico
  natural, y admiten tests UMP para hipótesis unilaterales.
]

=== Tests UMPU
<sec:ch4-umpu>

Para hipótesis bilaterales, típicamente no existen tests UMP.

#thm-env("definition", name: [Test Insesgado y UMPU], key: "def:ch4-umpu")[
  Un test $phi$ de nivel $alpha$ es _insesgado_ si
  $beta_phi (theta) >= alpha$ para todo $theta in ParamSpace_1$.

  Un test $phi^*$ es _UMPU_ si es UMP dentro de la clase de tests
  insesgados de nivel $alpha$.
]


#thm-env("theorem", name: [UMPU para Hipótesis Bilateral], key: "thm:ch4-umpu")[
  Sea $f(x|theta) = c(theta) h(x) exp{eta(theta) T(x)}$ con $eta(theta)$
  estrictamente creciente. Para $H_0: theta = theta_0$ vs
  $H_1: theta eq.not theta_0$, el test UMPU de nivel $alpha$ rechaza
  cuando $T(x) < c_1$ o $T(x) > c_2$, donde $c_1, c_2$ se determinan por
  las condiciones $EE_(theta_0)[phi]=alpha$ y $EE_(theta_0)[T phi]=alpha EE_(theta_0)[T]$, bajo regularidad e interioridad del parámetro natural. En modelos discretos se permite aleatorizar en los extremos.
]
_Demostración:_ resultado clásico; véase #cite(<lehmann2005testing>, form: "prose"). // DEC-A4 cita = demostración

=== Dualidad Test-Intervalo de Confianza
<sec:ch4-dualidad>

#thm-env("definition", name: [Intervalo de Confianza], key: "def:ch4-ic")[
  Un _intervalo de confianza_ de nivel $1-alpha$ para $theta$ es un
  intervalo aleatorio $[L(X), U(X)]$ tal que:
  $ P_theta (theta in [L(X), U(X)]) >= 1 - alpha quad forall theta in ParamSpace $
]


#thm-env("theorem", name: [Inversión de Tests], key: "thm:ch4-inversion")[
  Sea ${phi_(theta_0) : theta_0 in ParamSpace}$ una familia de tests no aleatorizados de
  nivel $alpha$ para $H_0: theta = theta_0$. Entonces:
  $ C(X) = {theta_0 : phi_(theta_0)(X) = 0} $
  es una región de confianza de nivel $1-alpha$.
]

#proof-env[
  Para cualquier $theta^* in ParamSpace$:
  $ P_(theta^*)(theta^* in C(X)) = P_(theta^*)(phi_(theta^*)(X) = 0) = 1 - P_(theta^*)(phi_(theta^*)(X) = 1) >= 1 - alpha $
  ya que $phi_(theta^*)$ tiene nivel $alpha$ para $H_0: theta = theta^*$.
]

#thm-env("corollary", name: [IC a partir de Test Z], key: "cor:ch4-ic-z")[
  Para $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con
  $sigma^2$ conocida, invirtiendo el test bilateral de nivel $alpha$:
  $ I C_(1-alpha) = [overline(X) - z_(1-alpha/2) dot sigma/sqrt(n), space overline(X) + z_(1-alpha/2) dot sigma/sqrt(n)] $
]

=== Múltiples Comparaciones
<sec:ch4-multiples>

Cuando se realizan múltiples tests, la probabilidad de al menos un error
Tipo I aumenta.

#thm-env("definition", name: [FWER y FDR], key: "def:ch4-fwer-fdr")[
  El _Family-Wise Error Rate_ es:
  $ "FWER" = P("al menos un falso positivo") $

  Sea $V$ el número de falsos positivos y $R$ el total de rechazos. El
  _False Discovery Rate_ es:
  $ "FDR" = EE[V/max(R,1)] $
]

La distinción entre FWER y FDR cambia lo que significa controlar el error. Incluso antes de escoger una corrección, varios contrastes independientes muestran cómo puede aumentar la probabilidad de algún falso positivo.

#thm-env("proposition", name: [Problema de Multiplicidad], key: "prop:ch4-multiplicidad")[
  Si se realizan $m$ tests independientes de tamaño exacto $alpha$, y todas las
  $H_0$ son verdaderas:
  $ "FWER" = 1 - (1-alpha)^m approx m alpha "para " alpha "pequeño" $
]

Para controlar esa probabilidad sin exigir independencia, puede distribuirse el nivel de error entre los contrastes mediante la desigualdad de la unión.

#thm-env("theorem", name: [Corrección de Bonferroni], key: "thm:ch4-bonferroni")[
  Para p-valores válidos (superuniformes bajo sus nulas) y una familia fijada de $m$ tests, para controlar FWER $<= alpha$, rechazar $H_(0,i)$ solo si
  $p_i <= alpha/m$.
]

#proof-env[
  Por la desigualdad de Boole:
  $ "FWER" = P(union.big_(i in I_0) {p_i <= alpha/m}) <= sum_(i in I_0) P(p_i <= alpha/m) <= abs(I_0) dot alpha/m <= alpha $
  donde $I_0$ es el conjunto de hipótesis nulas verdaderas.
]

#thm-env("example", name: [Pruebas Múltiples en SSCH con Corrección de Bonferroni], key: "ex:ch4-bonferroni-ssch")[
  En el Sistema de Soporte Clínico para Hipertensión, queremos comparar
  la efectividad de 4 tratamientos diferentes ($m=4$). Para cada
  tratamiento, probamos:
  - $H_(0,i)$: El tratamiento $i$ no mejora la presión arterial
  - $H_(1,i)$: El tratamiento $i$ mejora la presión arterial

  *Valores p observados:*
  - Tratamiento 1: $p_1 = 0.03$
  - Tratamiento 2: $p_2 = 0.01$
  - Tratamiento 3: $p_3 = 0.08$
  - Tratamiento 4: $p_4 = 0.04$

  *Sin corrección ($alpha = 0.05$):*
  - Rechazamos $H_(0,1)$, $H_(0,2)$, $H_(0,4)$ (todos con $p < 0.05$)
  - Si las cuatro nulas fueran verdaderas y los tests independientes de tamaño exacto 0.05, FWER sería $1-(1-0.05)^4 approx 0.185$. No se infiere esa probabilidad de los cuatro p-valores observados.

  *Con corrección de Bonferroni ($alpha/m = 0.0125$):*
  - Solo rechazamos $H_(0,2)$ (único con $p < 0.0125$)
  - FWER $<= 0.05$ (controlado)

  *Interpretación:* Sin corrección, rechazaríamos tres hipótesis. Los p-valores no permiten saber cuáles rechazos serían errores. Con Bonferroni, solo el tratamiento 2 (con
  el valor p más pequeño) se considera significativo, protegiéndonos
  contra falsos positivos.
]


#thm-env("theorem", name: [Procedimiento de Holm], key: "thm:ch4-holm")[
  Sea $p_((1)) <= p_((2)) <= ... <= p_((m))$ los p-valores ordenados. El
  procedimiento de Holm:
  + Sea $k = min{i : p_((i)) > alpha/(m-i+1)}$
  + Rechazar $H_(0,(1)), ..., H_(0,(k-1))$

  Si ningún índice cumple la condición, se rechazan todas las hipótesis. Para p-valores válidos, controla FWER bajo dependencia arbitraria y su conjunto de rechazos contiene al de Bonferroni.
]


#thm-env("theorem", name: [Benjamini-Hochberg para FDR], key: "thm:ch4-bh")[
  Sea $p_((1)) <= ... <= p_((m))$ los p-valores ordenados. Definir:
  $ k = max{i : p_((i)) <= (i dot alpha)/m} $
  Si el conjunto es vacío, fijar $k=0$. Rechazar las primeras $k$ hipótesis. Para p-valores válidos, este procedimiento controla
  FDR $<= m_0 alpha/m<=alpha$ si cada p-valor nulo es independiente del vector de todos los demás p-valores, o bajo la condición PRDS sobre el subconjunto de nulas verdaderas. La correlación positiva por sí sola no establece PRDS; véase #cite(<benjamini2001dependency>).
]

#proof-env[
Bajo independencia se usa que, al sustituir un p-valor nulo por cero, el total de rechazos permite acotar su contribución a la FDR por $alpha/m$. La suma da $m_0 alpha/m$. La extensión PRDS requiere un argumento adicional; se atribuye a la literatura, no se deduce de independencia. Véase #verdem(<dem:ch4-bh>).
]


== Aproximar la distribución del error de estimación

Los criterios anteriores describen propiedades de estimadores y contrastes. Para cuantificar su error con muestras grandes necesitamos aproximaciones a sus distribuciones. El recorrido empieza por medias y continúa con transformaciones, funciones y procedimientos de remuestreo.

=== El teorema central del límite
<sec:ch5-clt>

El Teorema Central del Límite (CLT) justifica la aproximación normal para
sumas de variables aleatorias y, por extensión, para la mayoría de los
estimadores estadísticos.

#thm-env("theorem", name: [CLT Clásico de Lindeberg-Lévy], key: "thm:ch5-clt", aliases: ("thm:ch5-clt-ll",))[
  Sea $X_1, X_2, ...$ una sucesión de variables aleatorias iid con
  $EE[X_i] = mu$ y $0<Var(X_i) = sigma^2 < infinity$. Entonces:
  $ sqrt(n)(overline(X)_n - mu) limits(->)^d N(0, sigma^2) $
  o equivalentemente:
  $ (overline(X)_n - mu)/(sigma/sqrt(n)) limits(->)^d N(0, 1) $
]

El CLT es una afirmación límite; no fija un umbral universal de 30 o 50 trayectorias. Asimetría, colas pesadas y pesos extremos pueden retrasar la aproximación. Para usar un intervalo normal se necesita además estimar consistentemente su varianza y justificar la unidad de observación independiente.


#proof-env[
  Sea $phi_X (t) = EE[e^(i t (X - mu))]$ la función característica de
  $X_i - mu$. Tenemos $phi_X (0) = 1$, $phi'_X (0) = 0$, y
  $phi''_X (0) = -sigma^2$.

  La función característica de $Z_n = sqrt(n)(overline(X)_n - mu)$ es:
  $ phi_(Z_n)(t) = [phi_X (t/sqrt(n))]^n $

  Expandiendo en Taylor:
  $ phi_X (t/sqrt(n)) = 1 - (sigma^2 t^2)/(2n) + o(1/n) $

  Por lo tanto:
  $ phi_(Z_n)(t) = (1 - (sigma^2 t^2)/(2n) + o(1/n))^n -> e^(-sigma^2 t^2/2) $

  que es la función característica de $N(0, sigma^2)$. Por el teorema de
  continuidad de Lévy, $Z_n limits(->)^d N(0, sigma^2)$.
]

El CLT clásico cubre variables idénticamente distribuidas. Otros diseños requieren una versión diferente. El teorema de Lindeberg--Feller
relaja esta exigencia: basta controlar las colas de las distribuciones
individuales.

#thm-env("theorem", name: [CLT de Lindeberg-Feller], key: "thm:ch5-lindeberg")[
  Sea ${X_(n,i) : 1 <= i <= k_n}$ un arreglo triangular con variables
  independientes dentro de cada fila (no necesariamente idénticas), con medias y varianzas finitas. Suponga $0<s_n^2<infinity$ en cada fila. Sea
  $s_n^2 = sum_(i=1)^(k_n) sigma_(n,i)^2$.

  Si se cumple la _condición de Lindeberg_: para todo $epsilon.alt > 0$,
  $ 1/s_n^2 sum_(i=1)^(k_n) EE[(X_(n,i) - mu_(n,i))^2 bb(1)_(abs(X_(n,i) - mu_(n,i)) > epsilon.alt s_n)] -> 0 $
  entonces:
  $ (sum_(i=1)^(k_n) (X_(n,i) - mu_(n,i)))/s_n limits(->)^d N(0, 1) $
]
_Demostración:_ resultado clásico; véase #cite(<vaart1998asymptotic>, form: "prose"). // DEC-A4 cita = demostración

La condición de Lindeberg controla la contribución agregada de las colas a la varianza total; que la mayor varianza individual sea despreciable no basta para reemplazarla. Para un agente que combina múltiples fuentes
de evidencia con precisiones heterogéneas —por ejemplo, retornos de
trayectorias de distintas longitudes o políticas con distinto número de
datos— este teorema garantiza que la normalidad asintótica se preserva
incluso cuando las varianzas individuales difieren sustancialmente,
siempre que se cumplan la independencia por filas y la condición de colas escrita en el teorema. Por ejemplo, variables que toman valores $plus.minus sqrt(n)$ con probabilidad $1/(2n)$ cada uno y cero en otro caso tienen varianzas individuales no dominantes, pero sus sumas normalizadas pueden tener límite de Poisson compuesto.


#thm-env("theorem", name: [CLT bajo mezcla fuerte], key: "thm:ch4-clt-mixing")[
  Sea $(Z_t)$ estrictamente estacionaria, de media $mu$, con $EE[abs(Z_0)^(2+delta)]<infinity$ para algún $delta>0$. Defina
  $ alpha(k)=sup_(A in sigma(Z_t\:t<=0), B in sigma(Z_t\:t>=k))abs(P(A inter B)-P(A)P(B)). $
  Si $sum_(k=1)^infinity alpha(k)^(delta/(2+delta))<infinity$ y
  $ tau^2=Var(Z_0)+2sum_(k=1)^infinity Cov(Z_0,Z_k)>0, $
  entonces $sqrt(n)(overline(Z)_n-mu)$ converge a $N(0,tau^2)$. Se cita este teorema de dependencia, sin reproducir aquí su prueba por aproximación de martingalas; véanse #cite(<bradley2005basic>) y las #link("https://www.stat.cmu.edu/~cshalizi/754/2006/notes/lecture-27.pdf")[notas de mezcla de Shalizi].
]

#thm-env("example", name: [La correlación cambia el error estándar], key: "ex:ch4-ar1")[
  Sea $Z_t-mu=rho(Z_(t-1)-mu)+epsilon_t$, con innovaciones gaussianas iid, $abs(rho)<1$ e inicio estacionario. Si la varianza marginal es $sigma_Z^2$, entonces $Cov(Z_0,Z_k)=sigma_Z^2 rho^k$ y
  $ tau^2=sigma_Z^2(1+rho)/(1-rho). $
  Para $rho=0.6$, $tau^2=4sigma_Z^2$: el error estándar de la media es asintóticamente el doble del calculado suponiendo independencia. La equivalencia heurística de tamaño efectivo sería $n/4$ para esta media; no es una identidad universal para todo estimador.
]

Para una sola serie, estimar la varianza marginal y dividir por $n$ omite autocovarianzas. Un estimador HAC o de medias por bloques debe acompañarse de condiciones sobre momentos, dependencia y crecimiento del ancho de banda. Para episodios independientes, se puede trabajar con un retorno por episodio aunque dentro de cada uno haya dependencia.

Muchos objetivos se obtienen transformando estimaciones: una razón, una probabilidad o el valor calculado a partir de transiciones. El método delta permite seguir el efecto de esa transformación sobre la fluctuación de primer orden.

=== El Delta Method
<sec:ch5-delta>

#thm-env("theorem", name: [Delta Method Univariado], key: "thm:ch5-delta")[
  Sea ${T_n}$ una sucesión de estadísticos con
  $sqrt(n)(T_n - theta) limits(->)^d N(0, sigma^2)$. Sea $g: RR -> RR$
  diferenciable en $theta$ con $g'(theta) eq.not 0$. Entonces:
  $ sqrt(n)(g(T_n) - g(theta)) limits(->)^d N(0, [g'(theta)]^2 sigma^2) $
]

El Delta Method es la herramienta fundamental para propagar incertidumbre
a través de cualquier transformación suave. Para un agente, esto
significa que si conocemos la distribución asintótica de un estimador de
parámetros del entorno (digamos, probabilidades de transición), podemos
derivar automáticamente la distribución del valor de la política, que es
una función no lineal de esos parámetros. La demostración es una
aplicación directa del teorema de Slutsky junto con una expansión de
Taylor de primer orden.

#proof-env[
  Por expansión de Taylor:
  $ g(T_n) = g(theta) + g'(theta)(T_n - theta) + o(abs(T_n - theta)) $

  Multiplicando por $sqrt(n)$:
  $ sqrt(n)(g(T_n) - g(theta)) = g'(theta) dot sqrt(n)(T_n - theta) + o_P (1) $

  Como $T_n limits(->)^P theta$, el término residual es $o_P (1)$. Por
  Slutsky, el resultado converge a
  $g'(theta) dot N(0, sigma^2) = N(0, [g'(theta)]^2 sigma^2)$.
]

El Delta Method univariado cubre transformaciones escalares. Para
funciones vectoriales —como las que aparecen al estimar múltiples
componentes de la función de valor— necesitamos la versión multivariada.

#thm-env("theorem", name: [Delta Method Multivariado], key: "thm:ch5-delta-multi")[
  Sea $bold(T)_n in RR^k$ con
  $sqrt(n)(bold(T)_n - bold(theta)) limits(->)^d N(bold(0), bold(Sigma))$.
  Sea $g: RR^k -> RR^m$ diferenciable con Jacobiana
  $bold(J) = nabla g(bold(theta))$. Entonces:
  $ sqrt(n)(g(bold(T)_n) - g(bold(theta))) limits(->)^d N(bold(0), bold(J) bold(Sigma) bold(J)^top) $
]
_Demostración:_ resultado clásico; véase #cite(<vaart1998asymptotic>, form: "prose"). // DEC-A4 cita = demostración

La matriz Jacobiana $bold(J)$ actúa como un amplificador selectivo de la
incertidumbre: direcciones del espacio de parámetros donde $g$ varía
rápidamente (gradiente grande) magnifican la varianza asintótica,
mientras que direcciones planas la atenúan. Para un agente, esto
significa que la incertidumbre en $Value^policy$ depende no solo de
cuánto ruido hay en las estimaciones de transición, sino de cuán
sensible es el valor a cada parámetro — una noción que cuantificaremos
en el @ch:inferencia vía funciones de influencia.

Una aplicación inmediata del Delta Method es derivar la varianza
asintótica de razones de estimadores — un problema que aparece cada vez
que comparamos dos políticas mediante el cociente de sus valores
estimados.

#thm-env("example", name: [Varianza Asintótica del Cociente], key: "ex:ch5-cociente")[
  Si $sqrt(n)((overline(X)_n, overline(Y)_n) - (mu_X, mu_Y)) limits(->)^d N(bold(0), bold(Sigma))$
  con $bold(Sigma) = mat(sigma_X^2, sigma_(X Y); sigma_(X Y), sigma_Y^2)$,
  para $g(x,y) = x/y$ y $mu_Y!=0$:
  $ nabla g = (1/mu_Y, -mu_X/mu_Y^2) $
  $ Var_"asint" (overline(X)_n/overline(Y)_n) = 1/(n mu_Y^2)(sigma_X^2 - 2 mu_X/mu_Y sigma_(X Y) + mu_X^2/mu_Y^2 sigma_Y^2) $
  *Interpretación:* esta fórmula revela un hecho crucial para la
  evaluación comparativa de políticas: la varianza de un cociente de
  valores estimados depende de la correlación $sigma_(X Y)$ entre
  numerador y denominador. Si ambas políticas se evalúan sobre las mismas
  trayectorias (como en importance sampling con el mismo conjunto de
  datos), cuando $mu_X/mu_Y>0$, la covarianza positiva reduce la expresión de varianza del cociente — un
  fenómeno útil para comparaciones pareadas y estimadores de razones. La doble robustez del @ch:ope se fundamenta en una identidad de sesgo producto, que es una propiedad distinta.
]

=== Procesos Empíricos
<sec:ch5-procesos>

#thm-env("definition", name: [Función de Distribución Empírica], key: "def:ch5-empirica")[
  Dada una muestra $X_1, ..., X_n$ iid con distribución $F$:
  $ hat(F)_n (x) = 1/n sum_(i=1)^n bb(1)_(X_i <= x) $
]

La medida empírica asigna masa $1/n$ a cada observación, sumando masas si hay empates. Su CDF $hat(F)_n(x)$ acumula las masas hasta $x$ inclusive; por la ley de los grandes números, $hat(F)_n (x) limits(->)^P F(x)$
punto a punto. Pero necesitamos más: necesitamos que esta convergencia
sea uniforme sobre todo $x$ simultáneamente, porque las decisiones de un
agente dependen de la comparación entre valores en distintos estados, no
de la estimación en un solo punto. El teorema de Glivenko--Cantelli
establece que esta aproximación es uniformemente consistente — un
resultado fundamental para la teoría de bootstrap.

#thm-env("theorem", name: [Glivenko-Cantelli], key: "thm:ch5-gc")[
  Sea $hat(F)_n$ la distribución empírica de una muestra iid de $F$.
  Entonces:
  $ norm(hat(F)_n - F)_infinity = sup_(x in RR) abs(hat(F)_n (x) - F(x)) limits(->)^"a.s." 0 $
]
_Demostración:_ resultado clásico; véase #cite(<vaart1998asymptotic>, form: "prose"). // DEC-A4 cita = demostración

La convergencia uniforme de la CDF no garantiza consistencia del bootstrap para cualquier funcional. Se necesitan condiciones sobre el estadístico, su escala y la regularidad del mapa que lo define. Extremos muestrales y problemas no regulares proporcionan contraejemplos.

Más allá de la convergencia puntual, necesitamos entender el
comportamiento del proceso empírico como objeto aleatorio. Esto requiere
extender el CLT a espacios de funciones.

#thm-env("definition", name: [Proceso Empírico], key: "def:ch5-proceso")[
  El _proceso empírico_ es:
  $ bb(G)_n (x) = sqrt(n)(hat(F)_n (x) - F(x)) $
]

Cada $bb(G)_n (x)$ es una variable aleatoria (diferencia escalada entre
CDF empírica y verdadera en $x$), pero la colección ${bb(G)_n (x) : x in RR}$
es un proceso estocástico indexado por $x$. El teorema de Donsker es la
extensión funcional del CLT: así como $sqrt(n)(overline(X)_n - mu)$
converge a una normal, $bb(G)_n$ converge a un proceso Gaussiano.

*¿Por qué un puente Browniano?* Intuitivamente, $bb(G)_n (x)$ tiene media
cero para cada $x$ (porque $EE[hat(F)_n (x)] = F(x)$) y su función de
covarianza es:
$ Cov(bb(G)_n (s), bb(G)_n (t)) = F(min(s,t)) - F(s)F(t) $
que es exactamente la covarianza de un puente Browniano $bb(B)$ compuesto
con $F$. Además, en los extremos $x = plus.minus infinity$,
$bb(G)_n (-infinity) = bb(G)_n (infinity) = 0$ — el proceso está
"anclado" en cero, igual que $bb(B)(0) = bb(B)(1) = 0$. Esta intuición
se formaliza en:

#thm-env("theorem", name: [Donsker], key: "thm:ch5-donsker")[
  Sea ${X_i}$ iid con distribución $F$. El proceso empírico converge
  débilmente en $ell^infinity(RR)$, con la convención de convergencia débil de procesos empíricos y la norma suprema, a un puente Browniano compuesto con $F$:
  $ bb(G)_n limits(->)^d bb(B) compose F $
  donde $bb(B)$ es un puente Browniano con $EE[bb(B)(t)] = 0$ y
  $Cov(bb(B)(s), bb(B)(t)) = min(s,t) - s t$.
]
_Demostración:_ resultado clásico; véase #cite(<vaart1998asymptotic>, form: "prose"). // DEC-A4 cita = demostración

Donsker nos dice que cualquier funcional continuo del proceso empírico
hereda la convergencia débil al correspondiente funcional del puente
Browniano. Para un agente, esto significa que estadísticos como el
estadístico de Kolmogorov-Smirnov
$D_n = sup_x abs(hat(F)_n (x) - F_0 (x))$, bajo la hipótesis $F=F_0$, o la norma $L^2(mu)$ de la diferencia entre CDFs para una medida finita $mu$ especificada, tienen distribuciones asintóticas obtenidas del límite, lo
que permite construir tests de bondad de ajuste y bandas de confianza
para la distribución completa de retornos sin asumir ninguna forma
paramétrica.

#thm-env("example", name: [Bandas de Confianza para la CDF vía Donsker], key: "ex:ch5-bandas")[
  Para una CDF continua y un análisis a tamaño fijo, el teorema de Donsker permite construir una banda de confianza
  asintótica para $F$:
  + Del límite de Donsker, $sup_x abs(bb(G)_n (x)) limits(->)^d sup_(t in [0,1]) abs(bb(B)(t))$, cuya distribución es conocida (distribución de Kolmogorov).
  + Para nivel $1-alpha$, sea $c_alpha$ el cuantil $1-alpha$ de $sup_t abs(bb(B)(t))$. Entonces: $ Prob(F(x) in [hat(F)_n (x) plus.minus c_alpha/sqrt(n)] quad forall x) -> 1-alpha $
  + Para un agente que monitorea la distribución de retornos de una política desplegada, esta banda permite detectar cambios en la distribución (p.ej., deriva del entorno) sin asumir normalidad: si la CDF histórica $F_0$ sale de la banda alrededor de $hat(F)_n$, hay evidencia contra la referencia fija. Si la referencia también se estima o se monitorea repetidamente, deben incorporarse ambas fuentes de incertidumbre o un control secuencial.
]


#thm-env("example", name: [No paramétrico: distribución y suavizado], key: "ex:ch4-no-parametrico")[
  Para los retornos sintéticos $(0,1,2,3,4)$, $hat(F)_5 (2)=3/5$. Esta CDF se calcula sin fijar una familia de densidades. Si se quiere estimar una densidad, el kernel uniforme da
  $ hat(f)_h (x)=1/(2 n h)sum_i bb(1)_(abs(X_i-x)<=h). $
  En $x=2$, con $h=0.6$ resulta $1/6 approx 0.1667$; con $h=1.1$, resulta $3/11 approx 0.2727$. El ancho de banda cambia qué observaciones contribuyen y el suavizado.

  En un punto interior, para densidad suficientemente suave y un kernel simétrico de segundo orden, el sesgo es de orden $h^2$ y la varianza de orden $1/(n h)$. Equilibrarlos motiva $h$ de orden $n^(-1/5)$ y error típico de orden $n^(-2/5)$ en una dimensión. Son órdenes bajo hipótesis explícitas, no garantías para estos cinco datos. Para inferir sobre $f(x)$, el sesgo puede ser comparable al error estándar y debe corregirse o reducirse mediante otra elección de $h$; una banda para la CDF no es un intervalo para la densidad.
]

La aproximación analítica puede resultar difícil cuando el estimador combina varios pasos. El remuestreo intenta reproducir su fluctuación a partir de los datos; para que lo consiga, el esquema de remuestreo debe conservar la estructura que determina esa fluctuación.

=== El Bootstrap
<sec:ch5-bootstrap>

#thm-env("definition", name: [Bootstrap No Paramétrico], key: "def:ch5-bootstrap")[
  Dada una muestra $X_1, ..., X_n$:
  + Generar muestra bootstrap $X_1^*, ..., X_n^*$ muestreando uniformemente con reemplazo de ${X_1, ..., X_n}$
  + Calcular $T_n^* = T(X_1^*, ..., X_n^*)$
  + Repetir $B$ veces para obtener $T_n^(*(1)), ..., T_n^(*(B))$
  + Usar la distribución empírica de ${T_n^(*(b))}$ como aproximación
]

Para estadísticos regulares, $hat(F)_n$ es el análogo no paramétrico
de $F$ que, por Glivenko-Cantelli, converge uniformemente a $F$.
Remuestrear de $hat(F)_n$ produce réplicas del estadístico cuya
distribución condicional aproxima la distribución muestral verdadera. El
siguiente resultado formaliza esta intuición para la media, confirmando
que la distribución bootstrap converge a la misma normal que el
estimador original.

#thm-env("theorem", name: [Consistencia del Bootstrap para la Media], key: "thm:ch5-bootstrap-media")[
  Sea $X_1, ..., X_n$ iid con $EE[X_i] = mu$ y $Var(X_i) = sigma^2 < infinity$.
  Sea $overline(X)_n^*$ la media bootstrap. Condicionalmente en la
  muestra original:
  $ sqrt(n)(overline(X)_n^* - overline(X)_n) limits(->)^d N(0, sigma^2) quad "en probabilidad" $
]

#proofsketch-env[
  Condicionalmente en $X_1, ..., X_n$, las observaciones bootstrap $X_i^*$
  son iid con distribución $hat(F)_n$. La media condicional es
  $overline(X)_n$ y la varianza condicional es
  $hat(sigma)_n^2 -> sigma^2$ por la LGN. Aplicando el CLT
  para el arreglo triangular condicional, verificando además Lindeberg, se obtiene el resultado. La distribución empírica cambia con $n$, por lo que no basta invocar el CLT iid de una ley fija. #verdem(<dem:ch5-bootstrap>)
]

#thm-env("definition", name: [IC Bootstrap Percentil], key: "def:ch5-ic-percentil")[
  El IC percentil de nivel $1-alpha$ es:
  $ I C_"perc" = [hat(theta)_n^(*(alpha/2)), hat(theta)_n^(*(1-alpha/2))] $
  donde $hat(theta)_n^(*(q))$ denota el cuantil $q$ de la distribución
  bootstrap.
]

Los cuantiles percentiles pueden ser asimétricos, pero no corrigen automáticamente el sesgo ni la distorsión de escala. La studentización aproxima la distribución de un pivote y puede mejorar la cobertura bajo condiciones adicionales de momentos, suavidad y expansión asintótica.


#thm-env("example", name: [IC Bootstrap Percentil-t], key: "def:ch5-ic-t")[
  Sea $t_n^* = (hat(theta)_n^* - hat(theta)_n)/(hat(S E)^*(hat(theta)_n^*))$.
  El IC es:
  $ I C_"perc-t" = [hat(theta)_n - t_n^(*(1-alpha/2)) dot hat(S E), space hat(theta)_n - t_n^(*(alpha/2)) dot hat(S E)] $
]

#thm-env("note", name: [Alcance de los refinamientos de cobertura], key: "thm:ch5-cobertura")[
Para modelos y estadísticos que admiten expansiones de Edgeworth válidas y una studentización regular, el bootstrap-t puede ofrecer refinamientos de orden superior respecto de aproximaciones de primer orden; véase #cite(<hall1992bootstrap>). Esos órdenes dependen del procedimiento y de si se estudia una cola o cobertura bilateral. Una afirmación $O(n^(-1))$ no equivale a un error numérico $1/n$ ni proporciona una cota a $n=100$ sin constantes. La validez no se extiende a extremos, fronteras o datos dependientes remuestreados como iid.
]


#thm-env("example", name: [Bootstrap que respeta el muestreo], key: "ex:ch4-bootstrap-unidad")[
  Si hay pacientes independientes con varias visitas, remuestrear pacientes completos preserva la estructura interna de cada unidad. Para una sola serie estacionaria se pueden remuestrear bloques consecutivos bajo condiciones específicas de mezcla y longitud de bloque; típicamente se exige que esta crezca mientras su proporción respecto de $n$ tienda a cero. Esas relaciones por sí solas no cubren todos los estadísticos. Véase #cite(<kunsch1989jackknife>).

  Un contraejemplo iid muestra otro límite: para $X_i tilde "Uniforme"(0,theta)$, el máximo bootstrap nunca supera al máximo observado y lo iguala con probabilidad $1-(1-1/n)^n$, que tiende a $1-e^(-1)$. La distribución límite continua del error escalado del máximo no tiene ese átomo. Por tanto el bootstrap ordinario del máximo no reproduce su distribución límite.
]

=== Asintótica para Funciones de Valor
<sec:ch5-valor>

#thm-env("proposition", name: [CLT para Retornos Monte Carlo], key: "prop:ch5-clt-retornos")[
  Sea ${G_i}_(i=1)^n$ una muestra iid de retornos bajo política $policy$, con el mismo estado inicial fijo $s_0$.
  Si $EE[G^2] < infinity$, entonces:
  $ sqrt(n)(1/n sum_(i=1)^n G_i - Value^policy (s_0)) limits(->)^d N(0, Var(G)) $
]

Esta proposición justifica el procedimiento más básico de evaluación de
políticas: ejecutar $n$ trayectorias independientes, promediar sus
retornos, y reportar un IC basado en la aproximación normal. Es el
fundamento estadístico de la evaluación Monte Carlo que usamos en el
@ch:ope.

La proposición anterior garantiza normalidad para estimadores directos de
$V^policy$. Pero en la práctica, un agente frecuentemente estima
$Q^policy$ (por pares estado-acción) y luego agrega para obtener
$V^policy$. El siguiente resultado propaga la incertidumbre desde las
estimaciones de $Q$ hasta el valor agregado, usando exactamente el Delta
Method multivariado.

#thm-env("proposition", name: [Delta Method para Funciones de Q], key: "prop:ch5-delta-q")[
Para una política fija, suponga convergencia conjunta
  $ sqrt(n)(hat(bold(Q))_n (s)-bold(Q)^pi (s)) limits(->)^d N(0,Sigma_Q). $
  Con el vector $p_s=(pi(a|s))_a$ y $hat(V)_n (s)=p_s^top hat(bold(Q))_n (s)$,
  $ sqrt(n)(hat(V)_n (s)-V^pi (s)) limits(->)^d N(0,p_s^top Sigma_Q p_s). $
  CLT marginales separados no bastan para afirmar este resultado. Si la política se aprende con los mismos datos, el objetivo y la expansión deben revisarse.
]

La varianza asintótica de $hat(Value)_n (s)$ contiene dos tipos de
términos: (i) varianzas puras $policy(a|s)^2 sigma_Q^2 (s,a)$, que
reflejan la incertidumbre en cada estimación de $Q$ ponderada por la
probabilidad de la acción al cuadrado; y (ii) covarianzas
$2 policy(a|s) policy(a'|s) (Sigma_Q)_(a,a')$, que
capturan el hecho de que los estimadores de $Q$ para distintas acciones
en el mismo estado están correlacionados — comparten las mismas
trayectorias. Ignorar estos términos (como haría un IC ingenuo) subestima
o sobrestima la incertidumbre total según el signo de las correlaciones.
Ambos tipos de términos usan entradas de la covarianza del límite escalado; la varianza del estimador de valor es aproximadamente $p_s^top Sigma_Q p_s/n$. Este fenómeno es análogo al del @ex:ch5-cociente y será central en los
estimadores que combinan múltiples fuentes de información en el
@ch:ope.

#thm-env("example", name: [Propagación de Varianza: MDP de 3 estados y 2 acciones], key: "ex:ch5-qdelta")[
  Considere un MDP con $StateSpace = {s_1, s_2, s_3}$ y
  $ActionSpace = {a_1, a_2}$. Para el estado $s_1$, la política es
  $policy(a_1|s_1) = 0.6$, $policy(a_2|s_1) = 0.4$. Se estiman
  $hat(Q)_n (s_1, a_1)$ y $hat(Q)_n (s_1, a_2)$ usando $n=50$ trayectorias
  compartidas, con matriz de covarianza asintótica:
  $ bold(Sigma)_Q = mat(4.0, 1.2; 1.2, 9.0) $
  Esta es la covarianza del límite escalado por $sqrt(n)$; la covarianza aproximada del estimador es $Sigma_Q/n$.
  La varianza asintótica de
  $hat(V)_n (s_1) = 0.6 hat(Q)_n (s_1, a_1) + 0.4 hat(Q)_n (s_1, a_2)$ es:
  $ sigma^2_V = (0.6)^2 (4.0) + (0.4)^2 (9.0) + 2(0.6)(0.4)(1.2) = 1.44 + 1.44 + 0.576 = 3.456 $
  con $sigma_V approx 1.86$. El IC 95% asintótico es:
  $ hat(V)_n (s_1) plus.minus 1.96 times 1.86 / sqrt(50) = hat(V)_n (s_1) plus.minus 0.516 $
  Nótese que si se ignorara la covarianza ($1.2$), la varianza sería
  $2.88$ y el ancho del IC se subestimaría en un 9%, llevando a
  decisiones potencialmente sobre-confiadas del agente.
]


== Estimar un objetivo con modelos auxiliares complejos

En la evaluación de políticas puede interesar un valor escalar, aunque la ley de los datos contenga funciones difíciles de estimar. La teoría semiparamétrica permite estudiar la precisión del objetivo sin reducir todos esos componentes a un vector paramétrico fijo.

=== Modelos semiparamétricos
<sec:ch6-modelos>

La pregunta de interés puede ser pequeña aunque la distribución de los datos sea compleja. Para evaluar una política interesa un escalar, pero puede ser necesario estimar regresiones, mecanismos de asignación y distribuciones de estados. La teoría semiparamétrica distingue la dificultad de estimar esos componentes de la dificultad del objetivo final.

#thm-env("definition", name: [Modelo y objetivo semiparamétricos], key: "def:ch6-semiparametrico")[
  Un modelo semiparamétrico puede escribirse $cal(P)={P_(theta,eta):theta in Theta subset.eq RR^d,eta in cal(H)}$, con $d$ fijo y $eta$ infinito-dimensional. Más generalmente, se define un funcional $psi(P)$ finito-dimensional sobre una clase infinita de leyes. La existencia de una parametrización global por componentes independientes no se supone. El término _nuisance_ designa componentes auxiliares respecto del objetivo, no variables irrelevantes.
]

Usaremos $O$ para una unidad observacional, $P_0$ para su ley verdadera, $psi_0=psi(P_0)$ para el objetivo y $eta$ para las funciones auxiliares. En un problema causal, la identificación de $psi$ a partir de la distribución observada se justifica antes de estudiar su estimación. Las funciones de influencia que siguen se refieren al funcional identificado.

#thm-env("example", name: [Regresión parcialmente lineal], key: "ex:ch6-parcialmente-lineal")[
  Sea $Y=X^top beta+g(Z)+epsilon$, con $EE[epsilon|X,Z]=0$. Defina $m(Z)=EE[X|Z]$ y $ell(Z)=EE[Y|Z]$. Entonces
  $ Y-ell(Z)=(X-m(Z))^top beta+epsilon. $
  Si $M=EE[(X-m(Z))(X-m(Z))^top]$ es invertible,
  $ beta=M^(-1)EE[(X-m(Z))(Y-ell(Z))]. $
  Esta identidad motiva residualizar resultado y exposición. La densidad completa incluye también las leyes de covariables y errores: $g$ no es todo el nuisance. Bajo homocedasticidad, la función de influencia eficiente de $beta$ es $M^(-1)(X-m(Z))epsilon$. La heterocedasticidad cambia la ponderación eficiente. La forma parcialmente lineal impone una restricción; no garantiza una interpretación causal de $beta$.
]
#thm-env("example", name: [Modelo de Cox], key: "ex:ch6-cox")[
  El modelo $h(t|Z)=h_0 (t)exp(Z^top beta)$ combina un vector $beta$ y una función basal $h_0$. Con censura se observa $(U,Delta,Z)$, donde $U$ es el mínimo entre evento y censura. La inferencia requiere condiciones sobre censura, observación y proporcionalidad de riesgos. La verosimilitud parcial evita estimar directamente $h_0$ para calcular $beta$, pero no elimina esas condiciones ni el resto del modelo observado.
]
#thm-env("example", name: [ATE como funcional de la ley observada], key: "ex:ch6-aipw-intro")[
  Con $O=(X,A,Y)$, $A in {0,1}$, defina $e(X)=P(A=1|X)$ y $m_a (X)=EE[Y|A=a,X]$. Bajo consistencia, intercambiabilidad condicional y positividad,
  $ psi(P)=EE[m_1 (X)-m_0 (X)]=EE[Y(1)-Y(0)]. $
  El objetivo depende también de la distribución de $X$. Las tres funciones $(e,m_0,m_1)$ no especifican por sí solas toda la densidad observada. El funcional puede estudiarse en un modelo observado no paramétrico usando herramientas semiparamétricas.
]
#thm-env("example", name: [Objetivo de OPE], key: "ex:ch6-ope")[
  Fije política objetivo, horizonte, descuento y distribución inicial. El objetivo $J^pi$ es un escalar, mientras que dinámica y recompensas pueden variar sobre clases funcionales. Si estados y acciones son finitos y fijos y todas las leyes se parametrizan con tablas finitas, el problema es finito-dimensional; llamarlo semiparamétrico requiere alguna parte genuinamente infinita. Un valor $V^pi (s)$ para todo $s$ continuo es un objetivo funcional, distinto del escalar $J^pi$.
]

=== Scores y Espacios Tangentes en el Par $(theta, g)$
<sec:ch6-tangentes>

El encabezado conserva la notación habitual $(theta,g)$; en las fórmulas se usa $eta$ para el nuisance y $psi$ para el objetivo. Un submodelo permite estudiar perturbaciones de la distribución sin parametrizar globalmente toda la clase.

#thm-env("definition", name: [Submodelo regular y score], key: "def:ch6-score-camino")[
  Un camino $t|->P_t$, con $P_(t=0)=P_0$, es diferenciable en media cuadrática si sus densidades satisfacen
  $ integral (sqrt(p_t)-sqrt(p_0)-t/2 S sqrt(p_0))^2 dif mu=o(t^2), $
  para un $S in L_0^2(P_0)$, llamado score. En modelos suficientemente suaves coincide con $partial_t log p_t|_(t=0)$. La condición $EE_0[S]=0$ procede de normalización y regularidad; no basta escribir una derivada formal.
]
#thm-env("example", name: [Scores de perturbaciones concretas], key: "ex:ch6-scores-canonicos")[
  En la regresión parcialmente lineal con error normal de varianza conocida, perturbar $g$ como $g_t=g+t h$ produce $S_g=h(Z)epsilon/sigma^2$. Esa fórmula requiere el submodelo normal especificado.

  Para Bernoulli condicional, una perturbación admisible $e_t=e+t h$ produce $S_e=h(X)(A-e(X))/(e(X)(1-e(X)))$. Su media condicional dado $X$ es cero.

  En supervivencia, perturbar $h_0$ como $h_(0,t)(u)=h_0 (u)exp(t b(u))$ da, bajo el modelo de intensidad y censura apropiados, el score $integral b(u)dif M(u)$, con $M$ el martingala de conteo compensado. No se sustituye la intensidad por una distribución empírica sin justificarlo.
]
#thm-env("definition", name: [Espacio tangente], key: "def:ch6-tangente")[
  $cal(T)$ es la clausura en $L_0^2(P_0)$ del espacio lineal generado por los scores de caminos regulares admisibles. El producto interno es $⟨f,g⟩=EE_0[f g]$.
]
#thm-env("definition", name: [Espacio tangente auxiliar], key: "def:ch6-tangente-nuisance")[
  $cal(T)_eta$ es la clausura del espacio generado por scores de caminos que mantienen el objetivo fijo. Depende del modelo y del funcional; no se identifica con todas las perturbaciones arbitrarias de funciones empleadas por un algoritmo.
]
#thm-env("note", name: [Qué se mantiene fijo], key: "rem:ch6-traduccion-nuisance")[
  En el ATE, cambiar $m_1$ suele cambiar $psi=EE[m_1-m_0]$. Por ello, una perturbación libre de $m_1$ no es automáticamente una dirección nuisance a objetivo fijo. En la regresión parcialmente lineal, mantener $beta$ fijo aún permite variar otras leyes además de $g$. Estos ejemplos evitan confundir los componentes de trabajo de un estimador con el espacio tangente auxiliar.
]
#thm-env("proposition", name: [Descomposición ortogonal correcta], key: "prop:ch6-descomposicion")[
  Como $cal(T)_eta$ es un subespacio cerrado de $cal(T)$,
  $ cal(T)=cal(T)_eta plus.o (cal(T) inter cal(T)_eta^perp). $
  Las direcciones que varían un parámetro manteniendo otros fijos no son necesariamente ortogonales antes de proyectarlas. La igualdad anterior es la descomposición de Hilbert respecto de un subespacio cerrado.
]

=== Funciones de Influencia
<sec:ch6-influencia>

#thm-env("definition", name: [Función de influencia], key: "def:ch6-if")[
  Una función $phi in L_0^2(P_0)$ representa la derivada del funcional si, para todo camino regular con score $S$,
  $ lr(dif/(dif t) psi(P_t) bar)_(t=0)=EE_0[phi(O)S(O)]. $
  El funcional debe ser diferenciable por caminos, con derivada lineal continua en el espacio tangente. Las distintas funciones que representan la misma derivada pueden diferir por un elemento de $cal(T)^perp$.
]
#thm-env("proposition", name: [Expansión asintóticamente lineal], key: "prop:ch6-ral")[
  Para unidades iid, si un estimador admite
  $ hat(psi)-psi_0=1/n sum_i phi(O_i)+o_P (n^(-1/2)), $
  con $EE_0[phi]=0$ y $0<EE_0[phi^2]<infinity$, entonces
  $ sqrt(n)(hat(psi)-psi_0) limits(->)^d N(0,EE_0[phi^2]). $
  Para un estimador regular en el modelo, su función de influencia debe representar las derivadas del objetivo. La existencia de una representación del funcional no demuestra por sí sola esta expansión para un estimador propuesto.
]

#thm-env("example", name: [Media y cuantil sin modelo paramétrico], key: "ex:ch4-if-media-cuantil")[
  Para la media, $phi(y)=y-psi$ y la expansión de la media muestral es exacta. Para el cuantil $q_tau$, si la densidad es continua y positiva en él, la función de influencia es
  $ phi_tau (y)=(tau-bb(1)_(y<=q_tau))/f(q_tau). $
  La varianza límite es $tau(1-tau)/f(q_tau)^2$. Una densidad pequeña cerca del cuantil amplifica la incertidumbre. Si hay un átomo o densidad cero, esta fórmula y el CLT regular pueden fallar. Así, dos objetivos escalares del mismo modelo no paramétrico pueden exigir condiciones diferentes.
]

=== Eficiencia Semiparamétrica
<sec:ch6-eficiencia>

#thm-env("definition", name: [Gradiente canónico], key: "def:ch6-if-eficiente")[
  La función de influencia eficiente es la proyección de cualquier representante $phi$ sobre el espacio tangente completo:
  $ phi_"eff"=Pi(phi|cal(T)). $
  Si se parte de un score paramétrico de interés $S_theta$, el score eficiente es $S_"eff"=S_theta-Pi(S_theta|cal(T)_eta)$. En una parametrización regular con información eficiente invertible, la IF eficiente es $I_"eff"^(-1)S_"eff"$. Proyectar una IF y residualizar un score son operaciones distintas.
]
#thm-env("note", name: [Ejemplos de la distinción score–IF], key: "rem:ch6-if-ejemplos")[
  En la normal de media desconocida y varianza conocida, el score es $(Y-mu)/sigma^2$, mientras que la IF de la media es $Y-mu$: falta la normalización por información si se confunden ambos. En Cox, el score parcial tampoco es por sí solo la IF del estimador. En el ATE, la IF eficiente en el modelo observado no paramétrico es
  $ phi_"eff" (O)=m_1 (X)-m_0 (X)+A/e(X)(Y-m_1 (X))-(1-A)/(1-e(X))(Y-m_0 (X))-psi_0. $
  Se requieren momentos finitos y control de los denominadores para usarla en inferencia de varianza finita.
]
#thm-env("theorem", name: [Cota de eficiencia], key: "thm:ch6-cota")[
  Para un estimador regular asintóticamente lineal con IF $phi$,
  $ EE_0[phi^2]>=EE_0[phi_"eff"^2]. $
  La igualdad exige $phi=phi_"eff"$ en $L^2(P_0)$.
]
#proof-env[
  Escriba $phi=phi_"eff"+h$ con $h in cal(T)^perp$. Pitágoras da $norm(phi)^2=norm(phi_"eff")^2+norm(h)^2$. El componente descartado está en el complemento del espacio tangente completo, no en el espacio nuisance. Véase #verdem(<dem:ch6-cota>).
]
#thm-env("corollary", name: [Varianza de referencia], key: "cor:ch6-varianza-minima")[
  La cota por observación es $sigma_"eff"^2=EE_0[phi_"eff"^2]$; un estimador eficiente tiene varianza asintótica $sigma_"eff"^2/n$. Alcanzarla requiere construir un estimador con resto despreciable; no se garantiza únicamente escribiendo la IF.
]

=== Ortogonalidad de Neyman
<sec:ch6-neyman>

#thm-env("definition", name: [Ortogonalidad de un momento], key: "def:ch6-neyman")[
  Sea $M(psi,eta)=EE_(P_0)[m(O;psi,eta)]$, con $M(psi_0,eta_0)=0$. Hay ortogonalidad de Neyman si
  $ lr(dif/(dif t) EE_(P_0)[m(O;psi_0,eta_0+t h)] bar)_(t=0)=0 $
  para toda dirección admisible $h$. La distribución de integración permanece fija en $P_0$; se perturba el argumento auxiliar del momento.
]
#thm-env("proposition", name: [Ortogonalidad, sesgo y eficiencia], key: "thm:ch6-neyman")[
  Si el mapa auxiliar tiene una expansión de segundo orden con resto controlado, la ortogonalidad elimina el término lineal de su error. No garantiza por sí sola eficiencia, doble robustez global ni identificación. Multiplicar un momento ortogonal por una constante no nula conserva sus raíces y la ortogonalidad, pero cambia el momento: por ello no puede caracterizarse como una IF eficiente única sin normalización y condiciones adicionales.
]

La ortogonalidad controla perturbaciones locales alrededor de $eta_0$. La doble robustez que sigue es una identidad algebraica más fuerte para un momento particular. Conviene comprobar ambas propiedades por separado.

La ortogonalidad describe cómo cambia un momento al perturbar sus componentes auxiliares. En los estimadores aumentados siguientes, esa relación se hace visible mediante una identidad de sesgo y permite distinguir doble robustez de eficiencia.

=== Estimadores Doubly Robust
<sec:ch6-dr>

#thm-env("definition", name: [Estimador AIPW y doble robustez], key: "def:ch6-dr")[
  Para funciones candidatas $overline(e)$ y $overline(m)_a$, defina el pseudoresultado
  $ D(O;overline(eta))=overline(m)_1 (X)-overline(m)_0 (X)+A/(overline(e)(X))(Y-overline(m)_1 (X))-(1-A)/(1-overline(e)(X))(Y-overline(m)_0 (X)). $
  AIPW promedia $D$ con funciones ajustadas fuera de cada fold. Su momento centrado es $D-psi$. La media de una IF centrada estima cero, no $psi$.
]
#thm-env("theorem", name: [Identidad exacta de doble robustez], key: "thm:ch6-dr", aliases: ("thm:ch6-doble-robustez",))[
  Para funciones candidatas fijas y denominadores alejados de cero,
  $ EE_0[D(O;overline(eta))]-psi_0=EE_0[(overline(e)-e)( (overline(m)_1-m_1)/overline(e)+(overline(m)_0-m_0)/(1-overline(e)))]. $
  La igualdad se obtiene condicionando en $X$. El lado derecho es cero si $overline(e)=e$ o si $overline(m)_0=m_0$ y $overline(m)_1=m_1$. Para funciones estimadas, consistencia exige además una ley de grandes números y control de sus errores; no se afirma insesgadez finita con ajustes reutilizados en la misma muestra.
]
#proof-env[
  La esperanza del término tratado es $e/overline(e)(m_1-overline(m)_1)$; la contribución no tratada entra con signo negativo y su esperanza es $-(1-e)/(1-overline(e))(m_0-overline(m)_0)$. Sumarlas con $overline(m)_1-overline(m)_0$ y restar $m_1-m_0$ produce la fórmula. Véase #verdem(<dem:ch6-doble-robustez>).
]

La identidad permite comparar errores sin exigir tasas iguales: si un componente converge rápido, el otro puede hacerlo más despacio. La consistencia cuando un solo modelo es correcto no implica automáticamente un intervalo eficiente calculado como si ambos lo fueran.

=== IF Eficiente para $Value^policy$
<sec:ch6-ope-if>
#section-alias("sec:ch6-ope")

Fijamos un experimento para evitar mezclar resultados de una decisión, trayectorias finitas y horizonte infinito. Observamos $n$ trayectorias iid $O=(S_0,A_0,R_0,...,S_H)$ bajo una política de comportamiento $b_t$. Dentro de cada trayectoria, el kernel conjunto de recompensa y siguiente estado es Markov y puede variar libremente con $t$. Las políticas objetivo $pi_t$ son fijas y la distribución inicial desconocida es común a comportamiento y objetivo. Hay $H$ decisiones, $0<=gamma<=1$ y recompensas acotadas. Se exige cobertura y razones marginales acotadas.

Defina $q_t(s,a)$ como el retorno esperado desde $s$ imponiendo la primera acción $a$ y continuando después bajo $pi$, mediante el kernel del entorno. Así queda definida incluso si $pi_t(a|s)=0$. Escriba $v_t(s)=sum_a pi_t(a|s)q_t(s,a)$, $v_H=0$ y $J=EE[v_0(S_0)]$. En los ajustes se fija también $hat(v)_H=0$ y $hat(v)_t=sum_a pi_t hat(q)_t$. La razón marginal es $w_t(s,a)=d_t^pi(s,a)/d_t^b(s,a)$, entre distribuciones estado–acción del mismo tiempo; no es el producto de razones de una trayectoria.

#thm-env("theorem", name: [Gradiente canónico en el modelo Markov finito], key: "thm:ch6-kallus", aliases: ("thm:ch6-if-ope",))[
  En el modelo no paramétrico Markov de kernels por tiempo descrito arriba,
  $ phi_"eff" (O)=v_0 (S_0)-J+sum_(t=0)^(H-1)gamma^t w_t (S_t,A_t)[R_t+gamma v_(t+1) (S_(t+1))-q_t (S_t,A_t)]. $
  Es la forma de diferencias de Bellman del gradiente para OPE Markov de horizonte finito; véase #cite(<kallus2020double>). Si se conoce la ley inicial y se integra respecto de ella, se elimina el componente $v_0 (S_0)-J$ asociado a estimarla. Las restricciones de homogeneidad temporal o un horizonte infinito definen otros modelos y pueden cambiar el gradiente eficiente.
]

Cada residuo tiene esperanza condicional cero con las funciones verdaderas, pero no es cero observación por observación. El término inicial integra el valor con la población objetivo. Los pesos corrigen la distribución de estados y acciones; en modelos con memoria, las razones acumuladas y el estado de historia corresponden a otro espacio tangente. La versión estacionaria de horizonte infinito de #cite(<kallus2022efficiently>) no se obtiene simplemente extendiendo esta suma sin revisar normalización, muestreo y regularidad.

#thm-env("corollary", name: [Estimador aumentado para OPE], key: "cor:ch6-dr-ope")[
  Con ajustes externos al fold de evaluación y $hat(v)_t=sum_a pi_t (a|s)hat(q)_t (s,a)$, use
  para cada observación $i$ suprima el índice de entrenamiento $-k(i)$ en la siguiente notación abreviada:
  $ hat(epsilon)_(i,t) = R_(i,t)+gamma hat(v)_(t+1) (S_(i,t+1))-hat(q)_t (S_(i,t),A_(i,t)), $
  $ hat(D)_i = hat(v)_0 (S_(i,0))+sum_(t=0)^(H-1)gamma^t hat(w)_t (S_(i,t),A_(i,t))hat(epsilon)_(i,t), $
  $ hat(J)=1/n sum_i hat(D)_i. $
  La identidad poblacional es correcta si todas las funciones $q_t$ son correctas o si todas las razones $w_t$ lo son. Bajo convergencia e integrabilidad apropiadas, esto da consistencia. Para eficiencia y un CLT se necesitan controles adicionales de productos de errores. La prueba de centrado y cancelación está en #verdem(<dem:ch6-if-ope>).
]

#thm-env("example", name: [OPE de una decisión: cálculo completo], key: "ex:ch6-dr-ssch")[
  En un contexto fijo, hay dos acciones. La política observada es $b=(0.6,0.4)$ y la objetivo $pi=(0.3,0.7)$. Tres registros sintéticos son $(A,R)=(1,5),(2,8),(1,3)$; las predicciones fijadas antes de evaluar son $hat(q)=(4,7)$. La predicción bajo la política objetivo es $hat(v)=0.3(4)+0.7(7)=6.1$ para los tres registros.

  #table(columns: (15%,20%,30%,35%),
    table.header([*Registro*],[*Peso*],[*Residuo ponderado*],[*Pseudoresultado*]),
    [1],[$0.5$],[$0.5(5-4)=0.5$],[$6.6$],
    [2],[$1.75$],[$1.75(8-7)=1.75$],[$7.85$],
    [3],[$0.5$],[$0.5(3-4)=-0.5$],[$5.6$],
  )
  Por tanto $hat(J)=(6.6+7.85+5.6)/3=401/60 approx 6.6833$. El estimador directo es $6.1$ y el de importancia simple es $(0.5(5)+1.75(8)+0.5(3))/3=6$. Sus diferencias son muestrales: tres registros no verifican consistencia ni eficiencia. Sustituir $hat(v)$ por $hat(q)(A_i)$ en el término directo cambia la política que se promedia y destruye la identidad de doble robustez.
]

=== Debiased Machine Learning
<sec:ch6-dml>

#thm-env("definition", name: [DML mediante momentos ortogonales], key: "def:ch6-dml")[
  DML combina momentos ortogonales con ajustes auxiliares separados de las observaciones donde se evalúan. En general resuelve $n^(-1)sum_i m(O_i;hat(psi),hat(eta)_(-k(i)))=0$. Para el ATE, el momento es $D-psi$ y la solución es la media de los pseudoresultados $D$. El trabajo de #cite(<chernozhukov2018double>) establece condiciones generales; aquí se explicita un caso suficiente.
]

Dividir las unidades iid en un número fijo $K>=2$ de folds de proporciones positivas. Ajustar $e,m_0,m_1$ fuera de cada fold; calcular $D_i$ dentro de él; promediar todos los $D_i$. Estimar $hat(sigma)^2=n^(-1)sum_i (D_i-hat(psi))^2$ y, cuando se cumplen las condiciones siguientes, usar $hat(psi) plus.minus z_(1-alpha/2)hat(sigma)/sqrt(n)$.

#thm-env("theorem", name: [Un caso suficiente para AIPW con cross-fitting], key: "thm:ch6-dml")[
  Suponga unidades iid, $abs(Y)<=C$, propensión verdadera y ajustada en $[c,1-c]$ para un $c>0$, ajustes de resultados uniformemente acotados, $K$ fijo y folds de tamaño proporcional a $n$. En cada fold, suponga convergencia $L^2(P_X)$ de las tres funciones y
  $ norm(hat(e)-e)_2 (norm(hat(m)_1-m_1)_2+norm(hat(m)_0-m_0)_2)=o_P (n^(-1/2)). $
  Si $sigma_"eff"^2=EE_0[phi_"eff"^2]>0$, entonces
  $ sqrt(n)(hat(psi)-psi_0)=1/sqrt(n)sum_i phi_"eff"(O_i)+o_P (1) limits(->)^d N(0,sigma_"eff"^2). $
  La varianza empírica de los pseudoresultados centrados es consistente. Véase #verdem(<dem:ch6-dml>). Estas hipótesis son suficientes, no necesarias; resultados con desenlaces no acotados requieren condiciones de momentos adicionales.
]

La ortogonalidad controla el sesgo poblacional; el cross-fitting controla un término empírico que reutilizar los datos puede hacer difícil de acotar. Estimadores sin cross-fitting también pueden ser válidos bajo condiciones de complejidad adecuadas. Separar folds no vuelve independientes los pseudoresultados entre sí ni resuelve la dependencia temporal de las unidades originales.

=== Condiciones para Validez de Cross-Fitting
<sec:ch6-crossfit-condiciones>

#thm-env("definition", name: [Tasas de producto], key: "def:ch6-nuisance-rates")[
  En el teorema anterior importa el producto de errores. Que cada componente sea $o_P (n^(-1/4))$ es una condición suficiente. Tasas $O_P (n^(-0.3))$ y $O_P (n^(-0.25))$ también dan un producto $o_P (n^(-1/2))$. Dos tasas meramente $O_P (n^(-1/4))$ solo aseguran $O_P (n^(-1/2))$, que puede dejar un sesgo en el límite. No hay una tasa individual necesaria de un cuarto para todos los modelos.
]
#thm-env("proposition", name: [Unidad de partición], key: "thm:ch6-crossfit")[
  La independencia usada en la prueba corresponde a la unidad $O_i$. Con pacientes independientes y visitas repetidas, se particiona por paciente. Con episodios independientes, por episodio. Dividir aleatoriamente transiciones de una misma trayectoria no satisface la prueba iid. Una única serie requiere un argumento específico de dependencia, separación temporal y, cuando proceda, bloques con huecos.
]
#thm-env("note", name: [Diagnósticos y límites de verificación], key: "prop:ch6-verificacion-tasas")[
  Curvas de aprendizaje, residuos y pérdidas fuera de muestra ayudan a detectar problemas, pero no certifican una tasa $o_P (n^(-1/4))$ con una muestra finita. La pérdida predictiva incluye ruido irreducible y no es automáticamente el error $L^2$ respecto de una función desconocida. No existen umbrales universales de $R^2$ que validen DML. Una simulación con verdad conocida puede estudiar tasas y cobertura bajo su mecanismo declarado; no demuestra esas propiedades para la población real.
]
#mi-tabla(caption: [Diagnósticos y alcance], key: "tab:ch6-diagnostico", table(
  columns: (30%,35%,35%),
  table.header([*Comprobación*],[*Qué aporta*],[*Qué no establece*]),
  [Propensiones y pesos], [Detecta solapamiento empírico débil], [Positividad poblacional garantizada],
  [Pérdida fuera de muestra], [Compara ajustes en datos separados], [Tasa asintótica del nuisance],
  [Identificadores de folds], [Detecta fuga entre unidades], [Independencia de una serie],
  [Simulación repetida], [Cobertura bajo un modelo conocido], [Validez causal en datos reales],
))

=== Inferencia Causal: DAGs y Criterio Backdoor
<sec:ch6-causal>

La inferencia estadística de un funcional observado y su interpretación causal son preguntas distintas. Las propiedades de AIPW no pueden corregir una identificación causal equivocada.

#thm-env("definition", name: [DAG causal], key: "def:ch6-dag")[
  Un DAG es un grafo dirigido acíclico. Su interpretación causal requiere un modelo de intervenciones, por ejemplo ecuaciones estructurales con supuestos sobre las perturbaciones exógenas. La factorización observacional o la condición de Markov por sí solas no determinan los efectos de intervenir.
]
#thm-env("definition", name: [Criterio backdoor], key: "def:ch6-backdoor")[
  En un DAG causal apropiado, $Z$ satisface el criterio si no contiene descendientes del tratamiento $A$ y bloquea todos los caminos entre $A$ e $Y$ que empiezan con una flecha hacia $A$. Con consistencia y positividad, el criterio permite identificar
  $ EE[Y(a)]=integral EE[Y|A=a,Z=z]dif P_Z (z). $
]
#thm-env("proposition", name: [Ajuste gráfico y resultados potenciales], key: "thm:ch6-rubin-dag")[
  En un modelo causal estructural compatible, el criterio backdoor es una condición gráfica suficiente para el ajuste. En resultados potenciales, consistencia, $Y(a) independent A|Z$ y positividad permiten derivar la misma fórmula por esperanza iterada. No se afirma el recíproco: una independencia distribucional puede ocurrir por restricciones particulares aunque el criterio gráfico falle. Los supuestos causales no se verifican únicamente con la distribución observada.
]
#proof-env[
  Por intercambiabilidad, $EE[Y(a)|Z]=EE[Y(a)|A=a,Z]$. Por consistencia, el último término es $EE[Y|A=a,Z]$. Integrar respecto de $Z$ da la fórmula. El criterio gráfico justifica el ajuste dentro de un modelo causal; véanse #cite(<pearl2009causality>) y #cite(<hernan2020causal>).
]
#thm-env("example", name: [SSCH: confusión y estandarización], key: "ex:ssch-causal-cap06", es-sintetico: true)[
  Considere dos estratos previos $Z=0,1$, cada uno con probabilidad $1/2$. El resultado es un puntaje adverso, de modo que menos es mejor. Las propensiones son $e(0)=0.2$, $e(1)=0.8$; las medias sin intervención son $m_0=(10,20)$ y con intervención $m_1=(8,16)$.

  En el DAG supuesto aparecen $Z->A$, $Z->Y$ y $A->Y$. Si $Z$ basta para ajuste, el efecto es $psi=(8-10)/2+(16-20)/2=-3$. Entre tratados, las proporciones de estratos son $(0.2,0.8)$, de modo que $EE[Y|A=1]=14.4$. Entre no tratados son $(0.8,0.2)$, de modo que $EE[Y|A=0]=12$. La diferencia cruda es $+2.4$: tiene signo opuesto al efecto ajustado.

  Este cálculo es poblacional bajo un mecanismo sintético completo para las medias y asignación. No se presenta un intervalo de confianza sin especificar tamaño muestral y variabilidad del resultado. El contraste ilustra por qué un buen predictor y una asociación observada no bastan para identificar una decisión causal.
]

#[
#set heading(numbering: none, outlined: false)
=== Causalidad y Sensibilidad
]

Un confusor no medido que afecte asignación y resultado puede invalidar la interpretación causal aunque los modelos observados se ajusten correctamente. El análisis de sensibilidad cuantifica cómo cambiaría la conclusión bajo desviaciones especificadas; no detecta ni descarta toda confusión oculta. Una variable instrumental define otro análisis y exige supuestos propios. Para decisiones longitudinales se requiere identificación secuencial y control de positividad en las historias pertinentes.

El recorrido del capítulo puede resumirse así: definir el objetivo y la ley observada; justificar identificación; elegir la clase de modelos; derivar una expansión y controlar su resto; estimar la varianza según la unidad de muestreo. La representación del @ch:isomorfismo preserva un objetivo de decisión bajo condiciones explícitas, pero no sustituye ninguno de esos pasos inferenciales.

El recorrido ha pasado de conservar información a controlar el error de un objetivo estimado. Estas herramientas se utilizarán después con una pregunta adicional: qué se mantiene cuando una regla se representa como política y los datos proceden de un proceso secuencial. El @ch:isomorfismo empieza por fijar esa representación; cada uso inferencial conservará las condiciones desarrolladas aquí.

== Ejercicios
<sec:ch4-ejercicios>


#exercise-env(key: "ex:ch1-ej0")[
  Implemente una actualización secuencial Normal-Gamma para la media de una sola secuencia iid, según @ex:ch1-normal-gamma. Fije prior propio $(mu_0,lambda,alpha,beta)=(0,1,2,1)$ y semilla 20261027. La siguiente regla es ilustrativa, no una solución óptima de parada ni un test secuencial de nivel controlado.
  + Diseñe un `StateSchema` que almacene los hiperparámetros $(mu_0, lambda, alpha, beta)$.
  + Implemente el nodo `actualizar` que recibe una observación $x$ (recompensa continua) y actualiza el estado según las fórmulas del ejemplo.
  + Implemente el nodo `decidir` que:
    - Calcula la media posterior $hat(mu)$ y varianza $Var(mu|x)$
    - Decide `detener` si $hat(mu) > 0.5$ y $Var(mu|x) < 0.1$
    - Decide `continuar` en caso contrario, hasta un máximo de 100 observaciones
  + Simule 100 observaciones de $N(0.6, 0.2^2)$ y trace la evolución de $hat(mu)$ y $Var(mu|x)$.
]

#exercise-env(key: "ex:ch1-ej1")[
  Demuestre que la distribución Gamma$(alpha, beta)$ con densidad
  $ f(x|alpha, beta) = beta^alpha / Gamma(alpha) x^(alpha-1) e^(-beta x), quad x > 0 $
  pertenece a una familia exponencial de rango 2 cuando tanto $alpha$ como
  $beta$ son desconocidos. Identifique el parámetro natural
  $eta = (eta_1, eta_2)$, el estadístico natural $T(x) = (T_1 (x), T_2 (x))$,
  y la función log-partición $A(eta)$.
]

#exercise-env(key: "ex:ch1-ej2")[
  Para la familia Normal$(mu, sigma^2)$ con ambos parámetros desconocidos:
  + Escriba la densidad en forma exponencial canónica, identificando $eta$, $T(x)$, $h(x)$ y $A(eta)$.
  + Verifique que $nabla A(eta) = EE_eta [T(X)]$ calculando explícitamente ambos lados.
  + Calcule la matriz de covarianzas $Cov_eta (T(X))$ usando el @cor:ch1-covarianza-hessiano y verifique el resultado directamente.
]

#exercise-env(key: "ex:ch1-ej3")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con $sigma^2$
  conocida. Considere los siguientes estimadores de $mu$:
  + $hat(mu)_1 = overline(X)$ (media muestral)
  + $hat(mu)_2 = X_1$ (primera observación)
  + $hat(mu)_3 = c overline(X)$ para $c in (0,1)$ fijo (estimador contraído)

  Para cada estimador, calcule el sesgo, la varianza y el ECM. ¿Cuál es
  óptimo bajo pérdida cuadrática? ¿Depende la respuesta del valor
  verdadero de $mu$?
]

#exercise-env(key: "ex:ch1-ej4")[
  Considere un agente que observa secuencialmente datos $X_1, X_2, ...$ de
  una distribución Poisson$(lambda)$ desconocida y debe estimar $lambda$
  en cada paso.
  + ¿Cuál es el estadístico suficiente para $lambda$ basado en $X_1, ..., X_n$?
  + Diseñe un `StateSchema` minimal que permita al agente actualizar su estimación de $lambda$ de forma incremental sin almacenar todas las observaciones pasadas.
  + Si el agente usa un prior Gamma$(alpha_0, beta_0)$ para $lambda$, ¿cómo debe modificarse el estado para mantener el posterior actualizado?
]

#exercise-env(key: "ex:ch1-ej5")[
  Sea $cal(D) = (ParamSpace, (P_theta), ActionSpace, SampleSpace, Loss)$ un problema de
  decisión con $ParamSpace = {0, 1}$, $ActionSpace = {0, 1}$, y pérdida
  0-1: $Loss(theta, a) = bb(1)(theta eq.not a)$.
  + Escriba la función de riesgo $Risk(theta, decrule)$ para una regla de decisión general $decrule$.
  + Fije $P_0 (X=1)=0.2$ y $P_1 (X=1)=0.8$. Represente la observación como estado inicial y la pérdida negativa como recompensa evaluativa indexada por $theta$.
  + Verifique $J_theta (pi_delta)=-R(theta,delta)$ y promedie con prior $nu(theta=1)=p$. Explique por qué el estado inicial no revela el parámetro desconocido.
]

#exercise-env(key: "ex:ch1-ej6")[
  Compare el modelo Beta-Binomial (@ex:ch1-beta-binomial) y
  Normal-Gamma (@ex:ch1-normal-gamma):
  + Identifique las similitudes y diferencias en la estructura de sus estados internos.
  + Analice la complejidad computacional de la actualización en cada caso.
  + Discuta en qué escenarios prácticos sería preferible cada modelo:
    - Bernoulli-Beta: CTR en anuncios, conversiones binarias
    - Normal-Gamma: Recompensas continuas (ventas, tiempo de sesión)
  + Proponga un criterio de decisión híbrido para un agente que maneje tanto conversiones binarias como recompensas continuas.
]


#exercise-env(key: "ex:ch2-ej1")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Uniforme"(0, theta)$ con
  $theta > 0$ desconocido.
  + Escriba la densidad conjunta $f(bold(x)|theta)$.
  + Use el Teorema de Neyman-Fisher para mostrar que $T(bold(x)) = X_((n)) = max{X_1, ..., X_n}$ es suficiente para $theta$.
  + ¿Es $(sum X_i, X_((n)))$ también suficiente? ¿Por qué esto no contradice la minimalidad de $X_((n))$?
]

#exercise-env(key: "ex:ch2-ej2")[
  Para la familia de Cauchy $f(x|theta) = 1/(pi(1 + (x-theta)^2))$,
  $theta in RR$:
  + Muestre que esta familia NO es exponencial.
  + Use el criterio de Lehmann-Scheffé para argumentar que el vector de estadísticos de orden $(X_((1)), ..., X_((n)))$ es suficiente minimal.
  + ¿Qué implicaciones tiene esto para el diseño del estado de un agente que modela observaciones Cauchy?
]

#exercise-env(key: "ex:ch2-ej3")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Exponencial"(lambda)$ con
  $lambda > 0$.
  + Muestre que $T = sum_(i=1)^n X_i$ es suficiente completo para $lambda$.
  + Muestre que $A = (X_1 /T, X_2 /T, ..., X_(n-1)/T)$ es ancilar (el vector completo de $n$ proporciones tiene distribución Dirichlet$(1,...,1)$, y su subvector tampoco depende de $lambda$).
  + Use el Teorema de Basu para concluir que $T$ y $A$ son independientes sin hacer cálculos directos.
  + ¿Cómo se traduce esta independencia al diseño de un agente que estima tasas de eventos?
]

#exercise-env(key: "ex:ch2-ej4")[
  Considere el modelo de localización-escala:
  $X_1, ..., X_n attach(tilde, t: "iid") 1/sigma f((x-mu)/sigma)$ con
  $(mu, sigma) in RR times RR^+$.
  + Identifique el grupo de transformaciones afines bajo el cual el modelo es invariante.
  + Muestre que $(overline(X), S)$ es un estimador equivariante de $(mu, sigma)$.
  + Si la pérdida es $Loss((mu,sigma), (a,b)) = (mu-a)^2/sigma^2 + (sigma-b)^2/sigma^2$, ¿es invariante bajo el grupo? ¿Qué implica esto para el riesgo de estimadores equivariantes?
]

#exercise-env(key: "ex:ch2-ej5")[
  Un agente observa secuencialmente tiempos entre eventos
  $X_1, X_2, ... attach(tilde, t: "iid") "Gamma"(alpha, beta)$ donde
  $alpha$ es conocido pero $beta$ es desconocido.
  + Identifique el estadístico suficiente minimal para $beta$ basado en $n$ observaciones.
  + Diseñe un `StateSchema` que permita actualización incremental del estado cuando llega $X_(n+1)$.
  + Si el agente usa un prior $"Gamma"(a_0, b_0)$ para $beta$, ¿cómo se extiende el estado para mantener el posterior?
  + Calcule la complejidad espacial y temporal de su diseño.
]


#exercise-env(key: "ex:ch3-ej1")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Poisson"(lambda)$. Considere
  el estimador inicial $hat(lambda) = X_1$.
  + Muestre que $hat(lambda)$ es insesgado para $lambda$.
  + Identifique el estadístico suficiente $T$ para $lambda$.
  + Calcule $tilde(lambda) = EE[X_1 | T]$ y verifique que $tilde(lambda) = overline(X)$.
  + Compare $Var(hat(lambda))$ con $Var(tilde(lambda))$.
]

#exercise-env(key: "ex:ch3-ej2")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Exponencial"(theta)$ con
  $f(x|theta) = theta e^(-theta x)$, $x > 0$.
  + Muestre que $T = sum_(i=1)^n X_i$ es suficiente completo.
  + Para $n>2$, encuentre el UMVUE de $theta$ y compruebe que tiene varianza finita.
  + Encuentre el UMVUE de $1\/theta$ (la media de la distribución).
  + Calcule la información de Fisher y verifique que el UMVUE de $1\/theta$ alcanza la cota de Cramér-Rao.
]

#exercise-env(key: "ex:ch3-ej3")[
  Para la familia $"Uniforme"(0, theta)$:
  + Calcule el score formal dentro del soporte y compruebe que su esperanza no es cero.
  + Explique por qué no se puede aplicar la cota regular de Cramér–Rao.
  + Muestre que $hat(theta) = (n+1)/n X_((n))$ es insesgado.
  + Calcule $Var(hat(theta))$ y compare con la cota de Cramér-Rao. ¿Qué paso de la prueba regular falla?
]

#exercise-env(key: "ex:ch3-ej4")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Gamma"(alpha, beta)$ con
  $alpha$ conocido y $beta$ desconocido.
  + Derive el MLE $hat(beta)_"MLE"$.
  + Calcule la información de Fisher $I_1 (beta)$.
  + Establezca la distribución asintótica de $hat(beta)_"MLE"$.
  + ¿Es $hat(beta)_"MLE"$ el UMVUE?
]

#exercise-env(key: "ex:ch3-ej5")[
  Un agente observa retornos
  $G_1, ..., G_n attach(tilde, t: "iid") N(Value^policy, sigma^2)$ con
  $sigma^2$ conocida.
  + Muestre que $hat(Value)^policy = overline(G)$ es el UMVUE de $Value^policy$.
  + Derive la cota de Cramér-Rao y verifique que $overline(G)$ la alcanza.
  + Si el agente quiere $Var(hat(Value)^policy) <= 0.01$ y $sigma^2 = 4$, ¿cuántas trayectorias necesita?
  + Diseñe un test de nivel $alpha = 0.05$ para $H_0: Value^policy <= 0$ vs $H_1: Value^policy > 0$.
]


#exercise-env(key: "ex:ch4-ej1")[
  Sea $X tilde "Exponencial"(lambda)$. Para $H_0: lambda = 1$ vs
  $H_1: lambda = 2$:
  + Derive el cociente de verosimilitudes $Lambda(x)$.
  + Muestre que el test MP rechaza para $X < c$.
  + Encuentre $c$ para nivel $alpha = 0.05$.
  + Calcule el poder del test.
]

#exercise-env(key: "ex:ch4-ej2")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Poisson"(lambda)$.
  + Muestre que la familia tiene MLR en $T = sum X_i$.
  + Derive el test UMP de nivel $alpha$ para $H_0: lambda <= lambda_0$ vs $H_1: lambda > lambda_0$.
  + ¿Existe un test UMP para $H_0: lambda = lambda_0$ vs $H_1: lambda eq.not lambda_0$? Justifique.
]

#exercise-env(key: "ex:ch4-ej3")[
  Para $X_1, ..., X_n attach(tilde, t: "iid") N(mu, sigma^2)$ con
  $sigma^2$ desconocida:
  + Derive el test t de nivel $alpha$ para $H_0: mu = mu_0$.
  + Use inversión de tests para derivar el IC $1-alpha$ para $mu$.
  + Verifique que este es el IC t clásico.
]

#exercise-env(key: "ex:ch4-ej4")[
  Un agente compara 10 políticas contra una base. Los p-valores son:
  0.001, 0.01, 0.02, 0.03, 0.04, 0.06, 0.08, 0.12, 0.25, 0.50.
  + Aplique Bonferroni con $alpha = 0.05$. ¿Cuáles rechaza?
  + Aplique Holm. ¿Cuáles rechaza?
  + Aplique Benjamini-Hochberg. ¿Cuáles rechaza?
  + Compare los resultados e interprete para el agente.
]

#exercise-env(key: "ex:ch4-ej5")[
  Un agente quiere detectar una diferencia $Delta Value = 0.5$ entre
  políticas, con $sigma = 2$, nivel bilateral $alpha = 0.05$ y poder $1-beta = 0.80$, con grupos independientes de igual tamaño y varianza conocida.
  + Calcule el tamaño de efecto $delta = Delta Value \/ sigma$.
  + Calcule el tamaño de muestra necesario por grupo.
  + Si solo puede recolectar $n = 50$ trayectorias por política, ¿cuál es el poder real?
  + ¿Qué $Delta Value$ mínimo puede detectar con $n = 50$ y poder 0.80?
]


#exercise-env(key: "ex:ch5-ej1")[
  Sea $X_1, ..., X_n attach(tilde, t: "iid") "Poisson"(lambda)$. Considere
  $g(lambda) = sqrt(lambda)$.
  + Use el CLT para establecer la distribución asintótica de $overline(X)_n$.
  + Aplique el Delta Method para derivar la distribución asintótica de $sqrt(overline(X)_n)$.
  + Construya un IC asintótico de nivel 95% para $sqrt(lambda)$.
]

#exercise-env(key: "ex:ch5-ej2")[
  Sea $X_1, ..., X_n$ una muestra de distribución desconocida.
  + Describa el procedimiento bootstrap para estimar la varianza de la mediana muestral.
  + ¿Por qué el bootstrap es particularmente útil para la mediana (vs. la media)?
  + Diseñe una simulación para verificar cobertura del IC bootstrap percentil.
]

#exercise-env(key: "ex:ch5-ej3")[
  Un agente estima $Value^policy$ con retornos
  $G_i attach(tilde, t: "iid") N(Value^policy, sigma^2)$.
  + Describa un protocolo de simulación para verificar cobertura del IC bootstrap.
  + Si la cobertura empírica es 0.87 para un IC nominal 0.95, ¿qué diagnóstico sugiere?
  + Proponga una corrección y explique cuándo sería apropiada.
]

#exercise-env(key: "ex:ch5-ej4")[
  Un agente estima $Qfunc^policy (s,a)$ para $K$ pares estado-acción.
  Cada estimador tiene varianza asintótica $sigma^2/n$.
  + Si $Value^policy (s) = 1/K sum_a Qfunc^policy (s,a)$, derive la varianza asintótica de $hat(Value)^policy (s)$.
  + Use el Delta Method si el agente calcula $exp(Value^policy (s))$.
  + ¿Cómo afectan las correlaciones entre estimadores de Q?
]

#exercise-env(key: "ex:ch5-ej5")[
  Un agente tiene 100 trayectorias bajo $policy_0$ y 100 bajo $policy_1$.
  + Diseñe un procedimiento bootstrap para IC de $Value^(policy_1) - Value^(policy_0)$.
  + ¿Cómo manejaría pares de trayectorias que comparten la misma aleatorización o unidad? Un estado inicial fijo común no crea dependencia por sí solo.
  + Proponga un test de permutación y especifique la hipótesis de intercambio o el mecanismo de aleatorización que lo hace válido.
]


#exercise-env(key: "ex:ch4-ej-modelos")[
  Compare estimar una media, una CDF, una densidad puntual y el valor de una política. Para cada objetivo, declare un modelo, unidad de muestreo, estimador y condición de regularidad. Explique por qué «no paramétrico» no equivale a «sin supuestos».
]
#exercise-env(key: "ex:ch4-ej-dr")[
  Retome el contraejemplo DR del cuerpo (@thm:ch6-dr, donde ambas funciones, propensión y recompensa, permiten distinguir casos): use $overline(e)=(0.4,0.6)$, $overline(m)_0=(11,19)$ y $overline(m)_1=(9,15)$. Calcule el sesgo con la identidad DR. Repita con propensión correcta y luego con ambas regresiones correctas. Compruebe qué propiedad es poblacional y qué haría falta para construir un intervalo muestral.
]
#exercise-env(key: "ex:ch4-ej-dependencia")[
  Derive la varianza de largo plazo del AR(1) y compare $rho=0$, $0.6$ y $-0.4$. Diseñe una simulación de cobertura con réplicas independientes y reporte el error Monte Carlo de la cobertura estimada. No confunda repetir una simulación con aumentar la longitud de una sola trayectoria.
]

== Lecturas Propuestas
<sec:ch4-lecturas>

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Obligatorias
]

+ #cite(<casella2002statistical>, form: "prose") y #cite(<lehmann1998theory>, form: "prose"): suficiencia, completitud y estimación puntual. Usar el segundo para revisar el alcance de los resultados de invariancia.
+ #cite(<lehmann2005testing>, form: "prose"): tests óptimos, aleatorización e inversión de tests.
+ #cite(<vaart1998asymptotic>, form: "prose"): estimación regular, método delta, procesos empíricos y bootstrap. El método delta se desarrolla en el capítulo 3, no en el 2.
+ #cite(<bickel1993efficient>, form: "prose") y #cite(<tsiatis2006semiparametric>, form: "prose"): espacios tangentes, gradiente canónico y cotas de eficiencia.

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Complementarias
]

+ #cite(<kennedy2022semiparametric>, form: "prose"): introducción a funciones de influencia y estimación de funcionales (la referencia alternativa citada aquí antes no tenía entrada en el `.bib`; sustituida 2026-11-03).
+ #cite(<chernozhukov2018double>, form: "prose"): momentos ortogonales, cross-fitting y condiciones sobre los restos.
+ #cite(<kallus2020double>, form: "prose") y #cite(<kallus2022efficiently>, form: "prose"): distinguir los modelos finitos por tiempo de los modelos estacionarios de horizonte infinito antes de trasladar una IF.
+ #cite(<efron1993introduction>, form: "prose"), #cite(<hall1992bootstrap>, form: "prose") y #cite(<kunsch1989jackknife>, form: "prose"): remuestreo, refinamientos y dependencia.
+ #cite(<bradley2005basic>, form: "prose") y #cite(<newey1987hac>, form: "prose"): condiciones de mezcla y estimación de varianza con autocorrelación.
+ #cite(<hernan2020causal>, form: "prose") y #cite(<pearl2009causality>, form: "prose"): identificación causal y límites del ajuste observado.
