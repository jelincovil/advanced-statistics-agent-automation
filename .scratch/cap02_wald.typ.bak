#import "../plantilla.typ": *

= Teoría de decisión de Wald
<ch:wald>

Una estimación resume lo que los datos permiten conocer; una decisión añade las consecuencias de actuar. Dos agentes pueden compartir la misma estimación y elegir acciones diferentes si los costos de equivocarse son distintos. La teoría de decisión permite expresar esa diferencia y comparar reglas completas bajo incertidumbre.

El marco de #cite(<wald1950statistical>, form: "prose") reúne observaciones, modelos, acciones y pérdidas. En este capítulo se desarrolla primero una decisión basada en una muestra. El capítulo de MDP incorporará consecuencias futuras y el @ch:isomorfismo precisará la representación que conserva el riesgo.

El hilo conductor es una decisión sintética de seguimiento: una señal imperfecta sugiere si conviene intensificar la atención. La pregunta no se resuelve indicando únicamente qué estado parece más probable; también importa cuánto cuesta cada error. Bayes, minimax y admisibilidad ofrecen criterios distintos para comparar reglas. Todos requieren declarar qué reglas están permitidas y qué modelos se consideran posibles.

== Observaciones, pérdidas y criterios de decisión
<sec:ch7-teoria>

=== Cómo se formula una decisión estadística
<sec:ch7-problema-decision>
#section-alias("sec:ch7-problema")

#thm-env("definition", name: [Problema estadístico de decisión], key: "def:ch7-problema")[
  Un problema se especifica mediante
  $ cal(E)=(Theta,cal(X),(P_theta)_(theta in Theta),cal(A),L), $
  donde $Theta$ indexa los modelos posibles, $X tilde P_theta$ es la observación, $cal(A)$ contiene las acciones y $L(theta,a)$ mide su pérdida. Los espacios están provistos de estructuras medibles y las funciones usadas deben ser medibles. Se supone pérdida no negativa o integrabilidad suficiente para que los riesgos considerados sean finitos. Las pérdidas acotadas con signo también son admisibles.
]

El parámetro desconocido y la observación son objetos diferentes. La familia $(P_theta)$ indica cómo la información observada depende de lo desconocido. Una descripción que omita esta familia deja sin especificar la distribución necesaria para calcular el riesgo.

#thm-env("definition", name: [Regla y clase de decisiones], key: "def:ch7-regla")[
  Una regla determinista es una función medible $delta:cal(X)->cal(A)$. Una regla aleatorizada es un kernel $d(a|x)$ sobre acciones; cuando estas son finitas, $d(a|x)>=0$ y $sum_a d(a|x)=1$. La aleatorización utiliza información disponible y azar independiente del parámetro. Denotaremos por $cal(D)$ la clase de reglas permitidas; debe indicarse si incluye aleatorización.
]

=== Función de Riesgo
<sec:ch7-riesgo>

Para una regla determinista,
$ R(theta,delta)=EE_theta[L(theta,delta(X))]. $
Para acciones finitas y una regla aleatorizada,
$ R(theta,d)=EE_theta[sum_a d(a|X)L(theta,a)]. $
El riesgo promedia sobre las muestras y sobre la aleatorización de la regla. Es una función de $theta$; en general ninguna regla minimiza simultáneamente todas sus componentes.

#thm-env("example", name: [Pérdidas y objetivos], key: "ex:ch7-perdidas")[
  #table(columns: (30%, 35%, 35%),
    table.header([*Pérdida*], [*Expresión*], [*Riesgo*]),
    [Cuadrática], [$(a-psi(theta))^2$], [Error cuadrático medio],
    [Absoluta], [$abs(a-psi(theta))$], [Error absoluto esperado],
    [Clasificación], [$bb(1)_(a != g(theta))$], [Probabilidad de clasificación errónea],
    [Cuadrática ponderada], [$w(theta)(a-psi(theta))^2$], [Error ponderado, con $w(theta)>=0$],
  )
  El objetivo $psi(theta)$ puede ser escalar aunque el modelo tenga dimensión infinita. La pérdida de clasificación compara acciones con una categoría $g(theta)$; no exige que todo parámetro sea una etiqueta.
]

=== Admisibilidad y Dominancia
<sec:ch7-admisibilidad>

#thm-env("definition", name: [Dominancia], key: "def:ch7-dominancia")[
  En una clase $cal(D)$, $delta_1$ domina a $delta_2$ si $R(theta,delta_1)<=R(theta,delta_2)$ para todo $theta$, con desigualdad estricta para al menos uno.
]
#thm-env("definition", name: [Admisibilidad], key: "def:ch7-admisibilidad")[
  Una regla es admisible en $cal(D)$ cuando ninguna otra regla de esa clase la domina. La admisibilidad descarta mejoras uniformes; no ordena todas las reglas ni establece optimalidad para un prior particular.
]

#thm-env("example", name: [James–Stein y la dimensión del parámetro], key: "ex:ch7-james-stein")[
  Para $X tilde N_p(theta,I_p)$, $p>=3$, y pérdida $norm(a-theta)^2$, la regla $delta_0(X)=X$ tiene riesgo $p$. El estimador
  $ delta_("JS")(X)=(1-(p-2)/norm(X)^2)X $
  satisface
  $ R(theta,delta_("JS"))=p-(p-2)^2 EE_theta[1/norm(X)^2]<p. $
  Su valor en $X=0$ se define arbitrariamente, pues ese evento tiene probabilidad cero. La esperanza es finita para $p>=3$. El resultado concierne a la dimensión $p$ del parámetro, no al número de observaciones de una media escalar. La identidad de riesgo se justifica en @dem:ch2-james-stein.
]

La admisibilidad permite descartar algunas reglas sin introducir un prior. Para elegir según un promedio de riesgos, debemos especificar cómo se ponderan los modelos posibles. Esa elección conduce al criterio de Bayes.

=== Reglas de Bayes
<sec:ch7-bayes>

#thm-env("definition", name: [Prior y riesgo de Bayes], key: "def:ch7-riesgo-bayes")[
  Un prior $nu$ sobre $Theta$ define el riesgo promedio
  $ rho_nu(delta)=integral_Theta R(theta,delta) nu(dif theta). $
  Se reserva $pi$ para políticas secuenciales. El riesgo de Bayes óptimo es $b(nu)=inf_(delta in cal(D))rho_nu(delta)$.
]
#thm-env("definition", name: [Regla de Bayes], key: "def:ch7-regla-bayes")[
  Una regla $delta_nu$ es de Bayes si alcanza $b(nu)$. Su optimalidad se refiere al prior, a la pérdida y a la clase especificados.
]

#thm-env("theorem", name: [Minimización de la pérdida posterior], key: "thm:ch7-bayes", aliases: ("thm:ch7-existencia-bayes",))[
  Suponga que existe un posterior regular $nu(dif theta|x)$, que $cal(A)$ es finito, y que $L$ es acotada y medible. Defina
  $ ell_nu(x,a)=integral L(theta,a)nu(dif theta|x). $
  Elegir para cada $x$ una acción que minimice $ell_nu(x,a)$, con desempate fijo, produce una regla medible de Bayes en la clase de todas las reglas, incluso aleatorizadas. Toda regla de Bayes debe concentrarse en acciones minimizadoras para casi toda observación según la distribución predictiva. Su comportamiento en conjuntos predictivamente nulos no queda determinado.
]
#proof-env[
  Por esperanza iterada, $rho_nu(delta)=EE[ell_nu(X,delta(X))]$. La minimización puntual da una cota inferior alcanzable y la diferencia respecto de esa cota es no negativa. Si una regla alcanza el mismo riesgo, esa diferencia debe ser cero casi seguramente. Para aleatorización, el costo es una combinación convexa de pérdidas posteriores y no puede ser inferior al mínimo. Los detalles están en @dem:ch7-existencia-bayes.
]

#thm-env("corollary", name: [Acciones posteriores para pérdidas habituales], key: "cor:ch7-bayes-especificas")[
  Bajo pérdida cuadrática escalar y segundo momento posterior finito, la media posterior minimiza la pérdida esperada. Bajo pérdida absoluta y primer momento posterior finito, cualquier mediana posterior es óptima. Bajo pérdida 0–1 para una cantidad discreta, se elige una categoría de máxima masa posterior cuando ese máximo existe.

  Estas afirmaciones para acciones continuas se justifican directamente: la pérdida cuadrática se descompone en varianza posterior más distancia cuadrática a la media; la condición de mediana caracteriza el mínimo de la pérdida absoluta. Para un posterior continuo sin átomos, la pérdida exacta $bb(1)_(a!=theta)$ es uno casi seguramente para toda acción fija y no justifica elegir la moda de una densidad.
]

=== Relación entre Admisibilidad y Reglas de Bayes
<sec:ch7-admisibilidad-bayes>

#thm-env("theorem", name: [Admisibilidad bayesiana en un modelo finito], key: "thm:ch7-admisibilidad-bayes")[
  Si $Theta$ es finito, $nu(theta)>0$ para cada parámetro y $delta_nu$ tiene riesgo de Bayes finito, entonces es admisible en la misma clase de comparación. Para espacios continuos se requieren otras condiciones; una desigualdad estricta en un solo punto de masa previa cero no basta para obtener contradicción.
]
#proof-env[
  Una regla dominante tendría una mejora no negativa para todo parámetro y positiva en alguno. Al ponderarla por masas previas estrictamente positivas se obtendría una mejora estricta del riesgo de Bayes, contradiciendo optimalidad. Si el prior no cubre todos los parámetros, el argumento deja de funcionar.
]

#thm-env("theorem", name: [Clase esencialmente completa en un problema finito], key: "thm:ch7-complete-class", aliases: ("thm:ch7-clase-completa",))[
  Suponga finitos $Theta$, $cal(X)$ y $cal(A)$, pérdida finita y todas las reglas aleatorizadas permitidas. Toda regla admisible es de Bayes para algún prior, que puede asignar masa cero a ciertos parámetros. Además, para cualquier regla existe una regla de Bayes cuyo riesgo no es mayor en ningún parámetro. La afirmación se refiere a este problema finito; no establece un teorema general de límites de reglas de Bayes en espacios arbitrarios.
]

La prueba usa la convexidad del conjunto de vectores de riesgo y un hiperplano de soporte; se desarrolla en @dem:ch7-clase-completa. La inclusión de reglas aleatorizadas es relevante para esa convexidad. Ser de Bayes para un prior con ceros no garantiza admisibilidad, como muestra el ejercicio correspondiente.

El promedio bayesiano expresa una manera de comparar la incertidumbre sobre el modelo. Si la decisión se evalúa por su riesgo más alto, la comparación cambia: interesa protegerse frente al peor caso dentro de la familia declarada.

=== Reglas Minimax
<sec:ch7-minimax>

#thm-env("definition", name: [Riesgo máximo y regla minimax], key: "def:ch7-minimax")[
  Defina $M(delta)=sup_(theta in Theta)R(theta,delta)$ y $M^*=inf_(delta in cal(D))M(delta)$. Una regla es minimax si alcanza $M^*$. La existencia del ínfimo como valor no implica que alguna regla lo alcance.
]

#thm-env("theorem", name: [Certificación minimax mediante Bayes], key: "thm:ch7-minimax-bayes", aliases: ("thm:ch7-bayes-minimax",))[
  Si $delta_nu$ es de Bayes y
  $ sup_(theta in Theta)R(theta,delta_nu)=rho_nu(delta_nu)<infinity, $
  entonces es minimax. Basta que $R(theta,delta_nu)<=rho_nu(delta_nu)$ para todos los parámetros. Un caso particular es una regla de Bayes de riesgo constante en todo $Theta$.
]
#proof-env[
  Para cualquier regla $delta$,
  $ sup_theta R(theta,delta)>=rho_nu(delta)>=rho_nu(delta_nu)
    =sup_theta R(theta,delta_nu). $
  El último paso exige el control del riesgo en todo el espacio. Constancia únicamente sobre el soporte del prior no garantiza esa igualdad. Véase @dem:ch7-bayes-minimax.
]

#thm-env("definition", name: [Prior menos favorable], key: "def:ch7-menos-favorable")[
  Un prior $nu^*$ es menos favorable si maximiza $b(nu)=inf_delta rho_nu(delta)$ entre los priors considerados. Puede existir solo una sucesión menos favorable. Bajo la condición del teorema anterior, $b(nu)=M^*$ y $nu$ es menos favorable, porque $b(eta)<=M^*$ para cualquier prior $eta$.
]

#thm-env("example", name: [Estimación Bernoulli con riesgo constante], key: "ex:ch2-bernoulli-minimax")[
  Sea $X tilde "Bernoulli"(theta)$, $theta in [0,1]$, con pérdida $(a-theta)^2$. Bajo prior $"Beta"(1/2,1/2)$, la media posterior es $delta(X)=(X+1/2)/2$. Su sesgo es $1/4-theta/2$ y su varianza es $theta(1-theta)/4$. Por tanto,
  $ R(theta,delta)=theta(1-theta)/4+(1/4-theta/2)^2=1/16. $
  La regla es minimax por @thm:ch7-minimax-bayes. Para $delta_0(X)=X$, el riesgo máximo es $1/4$. La contracción hacia $1/2$ reduce el peor riesgo, aunque introduce sesgo. Este cálculo ilustra cómo una propiedad inferencial modifica una decisión de estimación.
]

=== Tests como reglas de decisión
<sec:ch4-wald>

#thm-env("proposition", name: [Test como regla de decisión], key: "prop:ch4-test-decision")[
  Para hipótesis que particionan $Theta$ en $Theta_0$ y $Theta_1$, las acciones aceptar provisionalmente $H_0$ o rechazarla tienen pérdidas cero al acertar, $w_I>0$ por falso rechazo y $w_(I I)>0$ por falso negativo. El riesgo es $w_I P_theta("rechazar")$ bajo $H_0$ y $w_(I I)P_theta("no rechazar")$ bajo $H_1$.
  Para un problema bayesiano, se rechaza cuando
  $ w_I P(Theta_0|X)<w_(I I)P(Theta_1|X). $
]

El control frecuentista de nivel requiere una restricción sobre las probabilidades de rechazo bajo $Theta_0$. Elegir pérdidas y prior no garantiza automáticamente un nivel prefijado.

== De la regla estadística al diseño de un agente
<sec:ch7-langgraph>

=== El Agente como Decisor Estadístico
<sec:ch7-agente-decisor>

El agente debe registrar qué observa, qué desconoce, qué acciones considera y qué pérdida usa para compararlas. La pérdida expresa el objetivo de decisión; el modelo determina cómo se promedian sus consecuencias. Un parámetro desconocido de la dinámica no es el estado físico observado del paciente.

=== El Modelo Estadístico como Modelo del Mundo
<sec:ch1-modelo-mundo>

El marco de riesgo admite diferentes regímenes. En un modelo paramétrico, $theta$ es un vector finito con interpretación especificada. En un modelo semiparamétrico se distingue un objetivo de interés de funciones nuisance. En un modelo no paramétrico, el índice puede representar una distribución o función en una clase infinita. Ninguna de estas elecciones elimina los supuestos de identificación.

La representación $theta=(psi,eta)$ permite distinguir el objetivo $psi$ de los componentes auxiliares $eta$. Una pérdida $L(theta,a)=(a-psi)^2$ sigue definiendo un problema de decisión aunque $eta$ sea una función. Las herramientas para estimarlo y cuantificar su incertidumbre se desarrollan en @ch:herramientas.

=== Políticas Bayesianas
<sec:ch7-bayesianas>

Para una decisión terminal, se minimiza la pérdida posterior esperada. Si la acción altera observaciones futuras, debe incluirse el costo futuro en la optimización. Una sucesión de acciones miopes que minimizan la pérdida inmediata no es necesariamente bayesianamente óptima para el horizonte completo. El @thm:ch9-secuencial formaliza un caso finito de observación y parada sobre estados de creencia.

=== Políticas Minimax: Robustez
<sec:ch7-robustez>

El criterio minimax controla el máximo riesgo esperado dentro de la familia declarada. Su interpretación depende de que esa familia y la pérdida describan las incertidumbres relevantes. No es una garantía de seguridad en cada trayectoria ni cubre automáticamente entornos fuera de la clase. La aleatorización puede mejorar el máximo riesgo.

=== Metacriterios de Decisión
<sec:ch7-metacriterios>

La elección del criterio se justifica por el problema: disponibilidad de un prior defendible, costos de error, incertidumbres plausibles y restricciones de operación. Puede estudiarse sensibilidad a varios priors o a una clase de modelos. Cambiar de criterio según los mismos datos utilizados para evaluar la regla define un procedimiento nuevo, cuyo riesgo debe analizarse como un todo.

#[
#set heading(numbering: none, outlined: false)
=== Hilo longitudinal: SSCH
]

#thm-env("example", name: [SSCH: señal, pérdida y clase de reglas], key: "ex:ssch-cap07", es-sintetico: true)[
  Considere el ejemplo sintético de @ex:ssch-cap09: $theta in {0,1}$ indica necesidad de seguimiento intensificado; $P_0(X=1)=0.2$ y $P_1(X=1)=0.8$. Se pierde una unidad al intensificar sin necesidad y cuatro al no intensificar cuando sí se necesita. Con prior $nu(1)=0.3$ se obtiene:
  #table(columns: (34%, 20%, 20%, 26%),
    table.header([*Regla*], [$R(0)$], [$R(1)$], [*Riesgo promedio*]),
    [Siempre ordinario], [0], [4], [1.20],
    [Siempre intensificado], [1], [0], [0.70],
    [Seguir la señal], [0.20], [0.80], [0.38],
    [Invertir la señal], [0.80], [3.20], [1.52],
  )
  Seguir la señal es Bayes y minimax entre las cuatro reglas deterministas. Al permitir aleatorización, una regla mejor en peor caso intensifica siempre si $X=1$ y con probabilidad $3/8$ si $X=0$. Sus riesgos son ambos $1/2$, inferiores a $0.8$.

  Para verificar minimax en la clase ampliada, use el prior $nu^*(1)=1/2$. Si $X=0$, el posterior de $theta=1$ es $1/5$, justo el umbral de indiferencia; si $X=1$, es $4/5$ y conviene intensificar. La regla aleatorizada es Bayes para ese prior y tiene riesgo constante, por lo que es minimax. La elección de la clase cambia la respuesta aunque los datos y las pérdidas sean idénticos.
]

=== Trazabilidad: Del Teorema al Componente
<sec:ch7-trazabilidad>

#mi-tabla(table(columns: (33%, 33%, 34%),
  table.header([*Resultado*], [*Componente*], [*Alcance*]),
  [@def:ch7-problema], [Especificación de datos y pérdidas], [Define el problema evaluado],
  [@thm:ch7-bayes], [Minimización posterior], [Riesgo promedio bajo el prior],
  [@thm:ch7-minimax-bayes], [Comparación de peor caso], [Control sobre toda la clase de modelos],
  [@thm:ch7-admisibilidad-bayes], [Descarte de reglas dominadas], [Modelo finito y prior positivo],
  [@thm:ch7-complete-class], [Organización de reglas], [Problema finito con aleatorización],
), caption: [Del criterio de decisión a su uso en el agente.], key: "tab:ch7-trazabilidad")

=== La misma decisión expresada como una política
<sec:ch1-wald-preview>

#thm-env("proposition", name: [Identidad entre riesgo y retorno de una decisión], key: "prop:ch1-correspondencia")[
  En la familia de una decisión definida en @thm:ch9-isomorfismo, la política $pi_delta(x)=delta(x)$ recibe recompensa evaluativa $r_theta(x,a)=-L(theta,a)$ y cumple
  $ J_theta(pi_delta)=-R(theta,delta). $
  El retorno $J_theta$ promedia sobre $X tilde P_theta$. La política es común a todos los parámetros y no observa el verdadero $theta$. La igualdad se obtiene sustituyendo la recompensa dentro de la esperanza.
]

#[
#set heading(numbering: none, outlined: false)
=== Cuando la acción cambia el futuro
]

El capítulo siguiente estudia qué cambia cuando una acción modifica el estado y las recompensas futuras. Primero supondrá conocido el modelo para separar la planificación de la estimación. La identidad de una decisión no reemplaza el análisis dinámico, y las garantías de cálculo tampoco sustituyen las garantías inferenciales sobre modelos aprendidos.

Los ejercicios retoman esas diferencias de criterio. Permiten comprobar cómo cambian la regla y su riesgo al modificar el prior, la pérdida o la clase de decisiones permitidas.

== Ejercicios
<sec:ch7-ejercicios>

#exercise-env(key: "ex:ch7-ej1")[
  Sea $X|theta tilde N(theta,1)$ y $theta tilde N(mu_0,tau^2)$ con $tau^2>0$. Derive posterior, regla bajo pérdida cuadrática y riesgo de Bayes. Estudie el límite de la regla cuando $tau^2$ aumenta y distinga ese límite de la existencia de un prior propio límite.
]
#exercise-env(key: "ex:ch7-ej2")[
  Compare estimar una media escalar con $n$ observaciones y estimar un vector de dimensión $p$ a partir de $X tilde N_p(theta,I_p)$. Explique cuál dimensión interviene en James–Stein. Calcule el riesgo de $X$ y use la identidad del apéndice para comparar con la regla contraída.
]
#exercise-env(key: "ex:ch7-ej3")[
  Reproduzca el cálculo Bernoulli de @ex:ch2-bernoulli-minimax. Determine las acciones cuando $X=0$ y $X=1$, el sesgo y el riesgo constante. Justifique por qué el prior utilizado es menos favorable.
]
#exercise-env(key: "ex:ch7-ej4")[
  Sin observaciones informativas, considere dos parámetros y dos acciones con pérdidas $L(0,a_0)=0$, $L(1,a_0)=2$ y $L(0,a_1)=L(1,a_1)=0$. Bajo un prior concentrado en $theta=0$, ambas acciones son de Bayes. Muestre que una está dominada y que constancia de su riesgo sobre el soporte del prior no certifica minimax.
]
#exercise-env(key: "ex:ch7-ej5")[
  En el SSCH, escriba los riesgos en función de $q_0=P(a=1|X=0)$ y $q_1=P(a=1|X=1)$. Verifique la regla minimax aleatorizada y el prior que la certifica. Compare su riesgo bajo $nu(1)=0.3$ con el de seguir la señal. Explique por qué un criterio puede preferir una regla que el otro no prefiere.
]

== Lecturas Propuestas
<sec:ch7-lecturas>

#cite(<wald1950statistical>, form: "prose") presenta el marco fundacional. Para pérdidas, reglas bayesianas y minimax, consulte #cite(<berger1985statistical>, form: "prose") y #cite(<ferguson1967mathematical>, form: "prose"). Los ejemplos deben leerse con la clase de reglas y las condiciones de cada resultado.

Como apoyo abierto, las notas de
#link("https://stat210a.berkeley.edu/fall-2025/reader/minimax-estimation.html")[Stat 210A sobre estimación minimax]
desarrollan la certificación mediante Bayes. Los argumentos utilizados aquí se incluyen en el apéndice para que el alcance de cada afirmación sea comprobable.
