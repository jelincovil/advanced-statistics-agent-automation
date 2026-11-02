#import "../plantilla.typ": *

= Representación Wald → MDP: enunciado, demostración y alcance
<ch:isomorfismo>

Un agente recibe información y elige una acción cuyas consecuencias dependen de un entorno desconocido. La teoría de decisión describe esa elección mediante una pérdida y su riesgo esperado. Los MDP describen acciones, recompensas y transiciones. Para conectar ambos lenguajes debemos conservar la información disponible para decidir y el criterio con el que se comparan las decisiones.

Este capítulo construye una representación exacta de un problema estadístico como una *familia de MDP de una decisión*, indexada por el parámetro desconocido. La identidad central relaciona el riesgo con el retorno esperado desde la distribución inicial. El parámetro no se convierte en una observación y la política no puede utilizarlo. La transición posterior a la acción conduce a un estado terminal; la observación inicial puede ser aleatoria.

La construcción permite traducir Bayes, minimax y admisibilidad dentro de una misma clase de reglas. Su alcance es una representación que preserva el riesgo. No se afirma una equivalencia de categorías ni se utiliza una composición de reglas de decisión. Después se demuestra una extensión concreta: un problema bayesiano de observación y parada, con horizonte finito, admite programación dinámica sobre el posterior. Esta extensión requiere un modelo de observaciones y un prior explícitos.

== Construir la representación y precisar su alcance

=== Recapitulación de los Dos Marcos
<sec:ch9-marcos>

#thm-env("definition", name: [Problema estadístico de decisión], key: "def:ch9-wald")[
  Sean $Theta$ un conjunto finito no vacío, $cal(X)$ un espacio finito o numerable y $cal(A)$ un conjunto finito no vacío. Un problema está especificado por
  $ cal(D) = (Theta, cal(X), (P_theta)_(theta in Theta), cal(A), L), $
  donde $P_theta$ es la distribución de $X$ y $L: Theta times cal(A) -> RR$ es acotada. Una regla determinista es una función $delta: cal(X) -> cal(A)$ elegida sin conocer $theta$. Su riesgo es
  $ R(theta, delta) = sum_(x in cal(X)) P_theta(x) L(theta, delta(x)). $
  Denotamos por $cal(D)_0$ la clase de todas estas reglas. Las comparaciones se harán siempre dentro de esta clase, salvo indicación expresa.
]

La familia $(P_theta)$ forma parte del problema: indica qué puede aprenderse de la observación. El riesgo es una función de $theta$ que evalúa una regla completa. No se exige que una sola regla minimice el riesgo simultáneamente para todos los parámetros.

#thm-env("definition", name: [MDP de una decisión con estado terminal], key: "def:ch9-mdp")[
  Se observa un estado inicial $S_0$ en $cal(X)$, se elige una acción $A_0$ en $cal(A)$ y se recibe una única recompensa. Después el proceso llega a un estado terminal $s_("fin")$, de recompensa cero. Una política determinista es una función $pi: cal(X) -> cal(A)$; su extensión al estado terminal es irrelevante y se fija por convenio.
  Para un modelo indexado por $theta$, distinguimos
  $ V_theta^pi(x) = r_theta(x, pi(x)), quad
    J_theta(pi) = sum_x P_theta(x) V_theta^pi(x). $
  El primer objeto condiciona en el estado inicial; el segundo promedia sobre su distribución. Un descuento igual a uno es admisible porque solo hay una recompensa y el horizonte es finito.
]

=== Representación fundamental de un paso
<sec:ch9-isomorfismo>

#thm-env("theorem", name: [Representación que preserva el riesgo], key: "thm:ch9-isomorfismo")[
  Para el problema de @def:ch9-wald, construya, para cada $theta$, un MDP $cal(M)_theta$ con distribución inicial $P_theta$, recompensa
  $ r_theta(x,a) = -L(theta,a) $
  y transición determinista desde cualquier $(x,a)$ al estado terminal. La correspondencia $F(delta)=pi_delta$, definida por $pi_delta(x)=delta(x)$, es una biyección entre reglas deterministas y políticas deterministas en los estados de decisión de esta familia. Para todo $theta$ y toda regla,
  $ J_theta(pi_delta) = -R(theta,delta). $
  Una única política se utiliza en todos los modelos. La biyección se refiere a funciones puntuales; dos reglas distintas pueden tener el mismo riesgo, por ejemplo si difieren únicamente en observaciones de probabilidad cero bajo todos los modelos.
]

#proof-env[
  La regla y la política tienen el mismo dominio y codominio; copiarlas en cualquiera de los dos sentidos define aplicaciones inversas. Por la definición de recompensa,
  $ J_theta(pi_delta)
    = sum_x P_theta(x) [-L(theta,delta(x))]
    = -R(theta,delta). $
  La acotación de la pérdida asegura convergencia absoluta de las sumas. La transición terminal garantiza que no existen recompensas futuras que alteren la igualdad. La demostración y sus consecuencias se detallan en @dem:ch9-isomorfismo.
]

#thm-env("note", name: [Alcance de la construcción], key: "note:ch9-extension-no-demostrada")[
  El estado inicial es observable, pero el índice $theta$ es desconocido. La familia sirve para evaluar una política común; no entrega al agente el verdadero modelo. La representación tampoco supone que la recompensa evaluativa pueda observarse después de actuar: una pérdida estadística puede depender de una verdad que continúa desconocida. Por ello no constituye, por sí sola, un protocolo de aprendizaje por refuerzo con recompensas registradas.

  La transición al estado terminal es determinista. Esa propiedad no hace determinista el muestreo de $X$. La identidad demostrada usa $J_theta$, no el valor condicionado $V_theta^pi(x)$. No establece que un MDP general sea equivalente a un problema estadístico de una decisión.
]

#block(breakable: false)[
#mi-figura(
  block(width: 100%, inset: 8pt, stroke: 0.5pt)[
    #align(center)[
      Modelo desconocido $theta$: $X tilde P_theta$ \
      Observación $x$ → regla $delta(x)=pi_delta(x)$ → acción $a$ \
      Evaluación: $L(theta,a)$ → recompensa $-L(theta,a)$ \
      Transición a $s_("fin")$ → fin del episodio
    ]
  ],
  caption: [Representación de una decisión. El parámetro indexa el modelo y la evaluación; la regla utiliza únicamente la observación.],
  key: "fig:ch9-incrustacion-dec-mdp",
)
]

=== Extensión al Caso Secuencial
<sec:ch9-secuencial>

Considere ahora un parámetro fijo desconocido, un prior $b_0$ sobre $Theta$ y observaciones en un conjunto finito $cal(Y)$. Condicionalmente en $theta$, las observaciones sucesivas son independientes con probabilidades conocidas $q_theta(y)$. En cada instante se puede decidir una acción terminal o pagar un costo conocido $c >= 0$ para observar de nuevo. Se permiten como máximo $T$ observaciones y al llegar al horizonte se debe decidir.

Sea $b$ el posterior actual. Defina
$ m_b(y) = sum_(theta in Theta) b(theta) q_theta(y), quad
  B(b,y)(theta) = (b(theta) q_theta(y)) / m_b(y). $
La actualización se usa cuando $m_b(y)>0$; para observaciones de probabilidad predictiva cero se asigna un posterior arbitrario, sin efecto sobre las esperanzas. La pérdida esperada de decidir $a$ es
$ ell(b,a) = sum_theta b(theta) L(theta,a). $

#thm-env("theorem", name: [Programación dinámica bayesiana de observación y parada], key: "thm:ch9-secuencial")[
  Bajo el modelo finito anterior existe una estrategia bayesiana óptima que depende del historial solo mediante el número $k$ de observaciones restantes y el posterior $b$. Su riesgo restante mínimo satisface
  $ W_0(b) = min_(a in cal(A)) ell(b,a), $
  y, para $k>=1$,
  $ W_k(b) = min {min_(a in cal(A)) ell(b,a),
    c + sum_(y in cal(Y)) m_b(y) W_(k-1)(B(b,y))}. $
  La estrategia elige la alternativa que alcanza el mínimo. Los empates pueden resolverse mediante una regla fija. La demostración por inducción está en @dem:ch9-suficiencia-markov.
]

El estado de decisión es $(k,b)$. Observar produce una transición aleatoria determinada por $m_b$; decidir conduce al estado terminal. La actualización del posterior es determinista *dada la observación*, pero el proceso de creencias es generalmente estocástico. El resultado pertenece al enfoque bayesiano de estados de información y no implica optimalidad frecuentista uniforme en $theta$.

#thm-env("corollary", name: [Bellman para el retorno bayesiano], key: "cor:ch9-bellman")[
  Defina $U_k(b)=-W_k(b)$. Entonces
  $ U_0(b)=max_a [-ell(b,a)], $
  $ U_k(b)=max {max_a [-ell(b,a)],
    -c+sum_y m_b(y) U_(k-1)(B(b,y))}. $
  La recompensa al observar es $-c$ y la recompensa terminal esperada es $-ell(b,a)$. La igualdad se obtiene cambiando el signo en la recursión anterior. El estado oculto $theta$ permanece fijo; la actualización afecta la distribución de creencias sobre él.
]

=== Transferencia de Resultados de Inferencia
<sec:ch9-transferencia>

La igualdad entre objetivos no proporciona automáticamente un estimador ni una distribución muestral. Para obtener intervalos, tests o eficiencia se deben definir los datos disponibles, el parámetro objetivo, el estimador y las condiciones del resultado inferencial invocado. Las propuestas de transferencia se examinan en @ch:fallos; la evaluación de políticas y sus intervalos se desarrollan en @ch:ope y @ch:inferencia.

El índice $theta$ de la teoría de decisión puede representar un vector o un mecanismo probabilístico. El teorema principal se ha formulado aquí para conjuntos finitos y observaciones numerables. En espacios medibles más generales, la identidad de esperanzas sigue siendo válida cuando reglas y pérdidas son medibles y las integrales existen; la existencia de óptimos requiere análisis adicional.

#mi-tabla(
  table(columns: (23%, 38%, 39%),
    table.header([*Régimen*], [*Objeto inferencial*], [*Trabajo adicional*]),
    [Paramétrico], [Parámetros finitos de un modelo especificado], [Identificación, especificación y regularidad del estimador],
    [Semiparamétrico], [Objetivo con componentes nuisance funcionales], [Función de influencia, resto de la expansión y tasas de nuisance],
    [No paramétrico], [Funciones o distribuciones en una clase de dimensión infinita], [Complejidad, regularización y control de aproximación],
  ),
  caption: [Preguntas inferenciales que la representación de riesgo deja abiertas. La dimensión del objetivo y la del modelo son conceptos distintos.],
  key: "tab:ch5-regimenes",
)

=== Preservación de Propiedades de Optimalidad
<sec:ch9-optimalidad>

#thm-env("theorem", name: [Admisibilidad y no dominancia], key: "thm:ch9-admisibilidad")[
  Una regla $delta$ es admisible en $cal(D)_0$ si y solo si no existe una política $pi'$ de la clase correspondiente tal que
  $ J_theta(pi') >= J_theta(pi_delta) quad "para todo" theta, $
  con desigualdad estricta para algún $theta$. El orden compara el vector de retornos indexado por los modelos, no por estados iniciales observados. La conclusión se sigue de cambiar el signo en la definición de dominancia; #verdem(<dem:ch9-transferencia-admis>).
]

#thm-env("corollary", name: [Criterio de Bayes], key: "cor:ch9-bayes")[
  Para un prior $nu$ sobre $Theta$, sean
  $ rho_nu(delta)=sum_theta nu(theta)R(theta,delta), quad
    J_nu(pi)=sum_theta nu(theta)J_theta(pi). $
  Entonces $J_nu(pi_delta)=-rho_nu(delta)$. La correspondencia identifica los conjuntos de minimizadores del riesgo de Bayes con los de maximizadores de $J_nu$. La distribución conjunta usada es $nu(theta)P_theta(x)$; en general no se puede reemplazar por una recompensa promediada sin condicionar en $x$. Véase @dem:ch9-transferencia-bayes.
]

Con datos $x$, la regla bayesiana minimiza la pérdida posterior. No se necesita que el prior tenga soporte completo para esta identidad. La admisibilidad de una regla de Bayes es una cuestión adicional; no se deduce aquí para cualquier prior y cualquier situación.

=== StateSchema como Estadístico Suficiente
<sec:ch9-state>

#thm-env("note", name: [Tres requisitos distintos para el estado], key: "thm:ch9-state")[
  Una estructura de datos tipada especifica qué se almacena. La suficiencia estadística se refiere a la información sobre un parámetro contenida en una muestra. Un estado de información para control debe permitir calcular las distribuciones futuras y los costos relevantes. La propiedad de Markov se refiere a una ley de transición condicional. Ninguna de estas propiedades se obtiene únicamente al declarar un `StateSchema`.

  En @thm:ch9-secuencial, el posterior y el horizonte restante constituyen un estado de información bajo el modelo establecido. Si el costo o las observaciones dependen de una variable histórica adicional, esa variable también debe almacenarse o justificarse su eliminación.
]

#thm-env("example", name: [Memoria suficiente para observaciones normales], key: "ex:ch9-state")[
  Sean $Y_1,...,Y_n$ independientes con distribución normal de media $mu$ y varianza conocida $sigma^2>0$, con tamaño $n$ fijo. La factorización de la verosimilitud muestra que $sum_i Y_i$ es suficiente para $mu$. Para actualizar una media a medida que llegan datos puede almacenarse:
  ```python
  estado = {"n": 0, "suma": 0.0}
  def actualizar(estado, y):
      return {"n": estado["n"] + 1, "suma": estado["suma"] + y}
  ```
  El contador es información de diseño para la actualización. Si media y varianza son desconocidas, la pareja $(sum_i Y_i, sum_i Y_i^2)$ es suficiente para el modelo normal con $n$ fijo; se debe almacenar también la suma de cuadrados. Este ejemplo no convierte una trayectoria clínica dependiente en una muestra normal independiente.
]

=== Síntesis de la representación Wald → MDP
<sec:ch7-isomorfismo>

#thm-env("note", name: [Identidad que debe conservarse], key: "thm:ch7-isomorfismo")[
  La identidad exacta es $R(theta,delta)=-J_theta(pi_delta)$, con $J_theta$ promediado sobre $P_theta$. Se mantiene el mismo parámetro, la misma información y la misma clase de decisiones en ambos lados. La recompensa depende del modelo desconocido y la política solo utiliza la observación.
]

#thm-env("corollary", name: [Traducción del criterio minimax], key: "cor:ch7-traduccion")[
  Además de las correspondencias de Bayes y admisibilidad,
  $ inf_(delta in cal(D)_0) sup_(theta in Theta) R(theta,delta)
    = -sup_pi inf_(theta in Theta) J_theta(pi). $
  Si existen óptimos, las reglas minimax corresponden a políticas maximin de la familia. No se intercambia el orden de optimización con el del parámetro. Admitir reglas aleatorizadas exige ampliar ambos lados a la misma clase; un óptimo determinista puede dejar de ser óptimo en la clase ampliada.
]

#thm-env("note", name: [Alcance secuencial demostrado], key: "cor:ch7-secuencial")[
  El resultado secuencial de este capítulo es @thm:ch9-secuencial: observaciones condicionalmente independientes, espacios finitos, prior especificado, costo conocido y horizonte finito. La generalización a observaciones controladas o a estados ocultos dinámicos exige definir el kernel correspondiente y el filtro bayesiano. Este capítulo no afirma un teorema general sobre todos los agentes adaptativos.
]

== Leer las correspondencias a partir de sus condiciones
<sec:ch13-mapa>

#block(breakable: false)[
#mi-tabla(
  table(columns: (28%, 38%, 34%),
    table.header([*Objeto*], [*Correspondencia*], [*Respaldo y alcance*]),
    [$theta$], [Índice desconocido de la familia], [@thm:ch9-isomorfismo],
    [$X tilde P_theta$], [Estado inicial y su distribución], [Una decisión observable],
    [$delta(x)$], [$pi_delta(x)$], [Biyección entre funciones],
    [$L(theta,a)$], [$-r_theta(x,a)$], [Recompensa evaluativa],
    [$R(theta,delta)$], [$-J_theta(pi_delta)$], [Identidad de objetivos],
    [Bayes], [Retorno promedio máximo bajo el prior], [@cor:ch9-bayes],
    [Minimax], [Retorno mínimo sobre modelos, maximizado], [@cor:ch7-traduccion],
    [Admisibilidad], [No dominancia sobre modelos], [@thm:ch9-admisibilidad],
    [Posterior y horizonte], [Estado de información], [@thm:ch9-secuencial; modelo finito],
    [Suficiencia, ancillaridad], [Sin equivalencia general con estado mínimo o contexto descartable], [Requieren análisis propio],
    [Cobertura y eficiencia], [Propiedades de estimadores especificados], [Requieren resultados inferenciales adicionales],
  ), caption: [Correspondencias exactas y límites. Las filas inferenciales no son consecuencias automáticas de la identidad entre riesgo y retorno.],
  key: "tab:isomorfismo-completo",
)
]

== De la representación a una decisión concreta

La identidad de objetivos puede orientar la organización de un agente si se distingue qué información recibe cada paso. El ejemplo de seguimiento permite cerrar el recorrido con una regla y una comparación de riesgos que pueden calcularse explícitamente.

=== Arquitectura Trazable
<sec:ch9-arquitectura>

El nodo de observación produce los datos disponibles. El nodo de estado almacena la información cuya adecuación se ha justificado para el modelo. El nodo de inferencia estima los objetos desconocidos; el nodo de decisión utiliza una regla explícita. Cada paso tiene una responsabilidad verificable. La identidad de objetivos no certifica por sí sola la arquitectura completa.

=== Garantías y condiciones
<sec:ch9-garantias>

La cobertura pertenece a un intervalo, un objetivo y un régimen muestral concretos. El control de error requiere especificar las hipótesis, la selección y la regla de parada. La eficiencia exige un modelo y una cota de referencia. La consistencia de un estimador no basta para probar convergencia a una decisión única: pueden existir empates o regiones donde las acciones sean casi equivalentes.

#[
#set heading(numbering: none, outlined: false)
=== Trazabilidad: Del Teorema al Componente
<sec:ch9-trazabilidad>
]

#block(breakable: false)[
#mi-tabla(
  table(columns: (34%, 32%, 34%),
    table.header([*Resultado*], [*Componente*], [*Conclusión disponible*]),
    [@thm:ch9-isomorfismo], [Evaluación de reglas], [Retorno igual a riesgo negativo],
    [@cor:ch9-bayes], [Selección bajo prior], [Óptimos del mismo criterio promedio],
    [@thm:ch9-admisibilidad], [Comparación de políticas], [No dominancia en la clase fijada],
    [@thm:ch9-secuencial], [Estado posterior y parada], [Optimalidad bayesiana en el modelo finito],
    [Resultado inferencial adicional], [Intervalo o test], [Solo la garantía y condiciones de ese resultado],
  ), caption: [Trazabilidad de la representación y del problema bayesiano de parada.], key: "tab:ch9-trazabilidad",
)
]

#[
#set heading(numbering: none, outlined: false)
=== Hilo longitudinal: SSCH
]

#thm-env("example", name: [SSCH: decidir a partir de una señal], key: "ex:ssch-cap09", es-sintetico: true)[
  Este ejemplo aislado ilustra una decisión de seguimiento. No utiliza datos clínicos ni representa una recomendación terapéutica. El estado desconocido $theta in {0,1}$ indica si existe necesidad de seguimiento intensificado. La señal $X in {0,1}$ satisface $P_0(X=1)=0.2$ y $P_1(X=1)=0.8$. Las acciones son seguimiento ordinario ($a=0$) e intensificado ($a=1$). Las pérdidas ilustrativas son
  $ L(0,0)=0, quad L(0,1)=1, quad L(1,0)=4, quad L(1,1)=0. $

  #table(columns: (35%, 20%, 20%, 25%),
    table.header([*Regla*], [$R(0,delta)$], [$R(1,delta)$], [*Riesgo de Bayes*]),
    [Siempre $a=0$], [0], [4], [1.20],
    [Siempre $a=1$], [1], [0], [0.70],
    [$a=X$], [0.20], [0.80], [0.38],
    [$a=1-X$], [0.80], [3.20], [1.52],
  )

  El prior usado en la última columna es $nu(1)=0.3$. Por ejemplo, el riesgo de seguir la señal es $0.7 times 0.2+0.3 times 0.8=0.38$. En la familia de MDP correspondiente, sus retornos son $J_0=-0.2$ y $J_1=-0.8$. Son retornos promedio sobre señales, no valores condicionados en una señal particular.

  Si $p=P(theta=1|X)$, las pérdidas posteriores de las acciones son $4p$ y $1-p$. Se intensifica cuando $p>1/5$. Para $X=1$, el posterior es $12/19$; para $X=0$, es $3/31$. Por tanto, la regla de Bayes sigue la señal. La tabla enumera todas las reglas deterministas y confirma esa elección.

  Antes de observar, decidir inmediatamente tiene riesgo mínimo $0.7$. Si se permite obtener una señal con costo $0.05$, el riesgo total es $0.05+0.38=0.43$: conviene observar en este diseño. El beneficio proviene de información que puede cambiar la acción. Esta comparación aplica la recursión bayesiana con una observación disponible; no demuestra optimalidad de una política clínica longitudinal.
]

La representación deja así una identidad precisa y una extensión bayesiana delimitada. Al modificar la memoria, el horizonte o el mecanismo de datos aparecen preguntas nuevas. El @ch:fallos examina esos cambios para reconocer qué parte del argumento necesita otra justificación.

== Ejercicios
<sec:ch9-ejercicios>

#exercise-env(key: "ex:ch9-ej1")[
  Para $X tilde "Bernoulli"(theta)$ con $theta in {0.2,0.8}$, acciones ${0,1}$ y pérdida cuadrática, construya la familia de una decisión. Calcule los riesgos de las cuatro reglas deterministas y verifique la identidad con sus retornos. Compare Bayes bajo prior uniforme y minimax dentro de esa clase.
]
#exercise-env(key: "ex:ch9-ej2")[
  Formule Rao–Blackwell para una pérdida convexa y un estadístico suficiente, indicando las condiciones de integrabilidad y del espacio de acciones. Explique por qué la media condicional de una acción puede no pertenecer a un conjunto de acciones discretas. Determine qué cambia al permitir aleatorización.
]
#exercise-env(key: "ex:ch9-ej3")[
  Para una muestra independiente de tamaño fijo de una distribución exponencial de tasa desconocida, factorice la verosimilitud y proponga una memoria suficiente. Distinga esta propiedad de una afirmación sobre transiciones de un proceso controlado.
]
#exercise-env(key: "ex:ch9-ej4")[
  Demuestre @thm:ch9-admisibilidad escribiendo los cuantificadores de dominancia. Explique por qué el orden se toma sobre $theta$. Analice si la conclusión cambia al ampliar simultáneamente las clases a decisiones aleatorizadas.
]
#exercise-env(key: "ex:ch9-ej5")[
  En el ejemplo SSCH de este capítulo, calcule el posterior para ambas señales y la regla de Bayes. Antes de recibir ninguna señal, permita obtener una única observación, en total, con costo $c=0.05$ y aplique @thm:ch9-secuencial desde el prior indicado. Determine si conviene observar o decidir inmediatamente.
]

== Lecturas Propuestas
<sec:ch9-lecturas>

La teoría de riesgo y los criterios de decisión se desarrollan en
#cite(<berger1985statistical>, form: "prose") y
#cite(<ferguson1967mathematical>, form: "prose").
La programación dinámica y la formulación de MDP se estudian en
#cite(<puterman2005markov>, form: "prose"). La representación de este capítulo debe leerse junto con las hipótesis específicas de cada resultado de esas obras.

Como apoyo abierto, las notas de Will Fithian sobre
#link("https://www.stat.berkeley.edu/~wfithian/courses/stat210a/models.html")[teoría de decisión estadística]
precisan modelo, pérdida y riesgo; las notas de Russ Tedrake sobre
#link("https://underactuated.mit.edu/belief.html")[planificación bajo incertidumbre]
explican los estados de creencia. Estas referencias sirven de orientación; las demostraciones de los enunciados particulares usados aquí están incluidas en el apéndice.
