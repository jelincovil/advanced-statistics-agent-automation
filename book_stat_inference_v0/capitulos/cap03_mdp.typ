#import "../plantilla.typ": *

= Procesos de decisión de Markov
<ch:mdp-bellman>
#chapter-alias("ch:mdp")

El @ch:wald separó datos, reglas y consecuencias. Cuando una acción modifica las oportunidades futuras, comparar solo la pérdida inmediata resulta insuficiente. Un proceso de decisión de Markov permite describir esas consecuencias y calcular políticas que consideran el futuro. El problema estadístico aparece cuando sus recompensas o transiciones deben aprenderse a partir de datos.

La programación dinámica de #cite(<bellman1957dynamic>, form: "prose") descompone una decisión secuencial en decisiones actuales y problemas de continuación. Su utilidad depende de que el estado conserve la información necesaria para predecir recompensas y transiciones. Un registro de conversación o una variable denominada «estado» en un programa no satisface automáticamente esa condición.

Este capítulo desarrolla garantías de planificación en MDP finitos, descontados y conocidos. Después distingue esas garantías de las necesarias para aprender el modelo. El @ch:isomorfismo construye una representación precisa de decisiones de Wald en una familia de MDP de un paso con transición terminal determinista; esa construcción no identifica todo problema de inferencia con un MDP secuencial arbitrario.

== Planificar con un modelo conocido
<sec:ch8-teoria>

=== Definición Formal del MDP
<sec:ch8-mdp-def>

#thm-env("definition", name: [Proceso de decisión de Markov], key: "def:ch8-mdp")[
  En este capítulo, $cal(M)=(cal(S),cal(A),P,r,gamma)$ tiene estados y acciones finitos y no vacíos. Para cada $(s,a)$, $P(s'|s,a)>=0$ y $sum_(s') P(s'|s,a)=1$. La recompensa esperada satisface $abs(r(s,a))<=R_"max"<infinity$ y $0<=gamma<1$. Una distribución inicial $rho$ permite definir el valor agregado $J_rho^pi=sum_s rho(s)V^pi(s)$.
]

Se permite una recompensa aleatoria cuya esperanza condicional sea $r(s,a)$; para las fórmulas de valor basta integrabilidad y la cota correspondiente. Un estado terminal puede modelarse como absorbente con recompensa posterior cero. Las extensiones a espacios numerables o continuos necesitan especificar espacios funcionales, medibilidad y existencia de selectores; no se incluyen en el teorema finito.

#thm-env("definition", name: [Política], key: "def:ch8-politica")[
  Una política estacionaria aleatorizada asigna probabilidades $pi(a|s)$; una determinista asigna una acción $pi(s)$. En la clase general, una política puede depender del tiempo y de toda la historia observada. Las políticas deben usar únicamente información disponible al actuar.
]
#thm-env("definition", name: [Propiedad de Markov], key: "def:ch8-markov")[
  Para historias con probabilidad positiva,
  $ Prob(S_(t+1)=s'|S_0,A_0,...,S_t,A_t)=P(s'|S_t,A_t). $
  Además, la recompensa condicional esperada está determinada por $(S_t,A_t)$. Estas propiedades corresponden al estado y al modelo elegidos.
]

=== Funciones de Valor
<sec:ch8-valor>

#thm-env("definition", name: [Valor de estado], key: "def:ch8-V")[
  Para una política estacionaria,
  $ V^pi(s)=EE_s^pi[sum_(t=0)^infinity gamma^t r(S_t,A_t)]. $
]
#thm-env("definition", name: [Valor de acción], key: "def:ch8-Q")[
  $Q^pi(s,a)$ es el retorno esperado al iniciar en $s$, imponer $a$ como primera acción y seguir $pi$ desde el siguiente instante. Esta definición también vale si $pi(a|s)=0$; no condiciona en un suceso imposible bajo la política.
]
#thm-env("proposition", name: [Relación entre valores], key: "prop:ch8-VQ")[
  $ Q^pi(s,a)=r(s,a)+gamma sum_(s')P(s'|s,a)V^pi(s'), quad V^pi(s)=sum_a pi(a|s)Q^pi(s,a). $
]
#thm-env("proposition", name: [Acotación], key: "prop:ch8-acotacion")[
  $abs(V^pi(s))<=R_"max"/(1-gamma)$. Se obtiene tomando valores absolutos y sumando la serie geométrica. La misma cota vale para $Q^pi$.
]

=== Ecuaciones de Bellman
<sec:ch8-bellman>

#thm-env("theorem", name: [Bellman para una política estacionaria], key: "thm:ch8-bellman-pi")[
  $ V^pi(s)=sum_a pi(a|s)[r(s,a)+gamma sum_(s')P(s'|s,a)V^pi(s')]. $
]
#proof-env[
  Separar la recompensa inicial del retorno restante, condicionar en la primera acción y el siguiente estado, y usar estacionariedad. La cota geométrica justifica intercambiar esperanza y suma. Véase también #verdem(<dem:ch8-bellman-exp>).
]
#thm-env("definition", name: [Valor óptimo], key: "def:ch8-optimo")[
  $V^*(s)=sup_pi V^pi(s)$, donde el supremo admite políticas dependientes de la historia. Una política es óptima si alcanza este valor en cada estado.
]
#thm-env("theorem", name: [Bellman de optimalidad], key: "thm:ch8-bellman-opt", aliases: ("thm:ch8-existencia",))[
  En el MDP finito descontado existe una política estacionaria determinista óptima y
  $ V^*(s)=max_a [r(s,a)+gamma sum_(s')P(s'|s,a)V^*(s')]. $
  Con $Q^*(s,a)=r(s,a)+gamma sum_(s')P(s'|s,a)V^*(s')$, se obtiene también
  $ Q^*(s,a)=r(s,a)+gamma sum_(s')P(s'|s,a)max_(a')Q^*(s',a'). $
  El valor óptimo es único; las políticas óptimas pueden ser varias si hay empates.
]
La demostración identifica el punto fijo, construye una política greedy y verifica que domina incluso a políticas con memoria: #verdem(<dem:ch8-existencia>).

La ecuación de Bellman describe un equilibrio entre la recompensa actual y el valor de continuar. Para calcular ese equilibrio necesitamos saber cómo cambia la ecuación cuando cambia la función de valor que se introduce en ella. La contracción permite controlar esa diferencia.

=== Operadores de Bellman y Contracción
<sec:ch8-operadores>

#thm-env("definition", name: [Operadores de Bellman], key: "def:ch8-operador")[
  Para $V in RR^(abs(cal(S)))$,
  $ (T^pi V)(s)=sum_a pi(a|s)[r(s,a)+gamma sum_(s')P(s'|s,a)V(s')], $
  $ (T^*V)(s)=max_a[r(s,a)+gamma sum_(s')P(s'|s,a)V(s')]. $
]
#thm-env("theorem", name: [Contracción en norma supremo], key: "thm:ch8-contraccion")[
  Para $T=T^pi$ o $T=T^*$,
  $ norm(T V-T W)_infinity<=gamma norm(V-W)_infinity. $
]
#proof-env[
  La diferencia de dos máximos está acotada por el máximo de las diferencias absolutas. Cada promedio con $P$ está acotado por $norm(V-W)_infinity$. Multiplicar por $gamma$ da el resultado. Para $T^pi$, el promedio adicional sobre acciones mantiene la cota. Véase #verdem(<dem:ch8-contraccion>).
]
#thm-env("corollary", name: [Puntos fijos únicos], key: "cor:ch8-punto-fijo")[
  La completitud del espacio finito con norma supremo y el teorema de Banach dan puntos fijos únicos: $V^pi$ para $T^pi$ y $V^*$ para $T^*$.
]

La contracción convierte la recursión en un procedimiento de cálculo: al aplicar repetidamente el operador, la distancia al punto fijo se reduce. El residuo de cada paso permitirá además expresar un criterio de parada con un significado preciso.

=== Value Iteration
<sec:ch8-vi>
#section-alias("alg:value-iteration", word: "Algoritmo")

Inicializar $V_0=0$. En cada paso calcular $W=T^*V_k$ y el residuo $e_k=norm(W-V_k)_infinity$. Si se satisface la tolerancia elegida, devolver $V_k$ y una política greedy respecto de ese mismo vector. En otro caso asignar $V_(k+1)=W$ y continuar. Conservar este orden evita aplicar una cota a un vector distinto del usado para extraer la política.

#thm-env("theorem", name: [Convergencia de Value Iteration], key: "thm:ch8-vi-conv")[
  $ norm(V_k-V^*)_infinity<=gamma^k norm(V_0-V^*)_infinity. $
  Con $V_0=0$, la cota es $gamma^k R_"max"/(1-gamma)$.
]
#proof-env[Aplicar la contracción $k$ veces y usar $T^*V^*=V^*$; luego aplicar la cota del valor óptimo.]

#thm-env("corollary", name: [Certificados de parada], key: "cor:ch8-parada")[
  Para cualquier $V$, sea $e=norm(T^*V-V)_infinity$ y sea $pi_V$ greedy respecto de $V$. Entonces
  $ norm(V-V^*)_infinity<=e/(1-gamma), $
  $ norm(V^*-V^(pi_V))_infinity<= (2 gamma e)/(1-gamma)^2. $
  Para certificar error de valor a lo sumo $epsilon.alt$, basta $e<=epsilon.alt(1-gamma)$. Para pérdida de política a lo sumo $epsilon.alt$ y $gamma>0$, basta $e<=epsilon.alt(1-gamma)^2/(2 gamma)$. Si $gamma=0$, maximizar $r$ resuelve directamente el problema.
]
La primera desigualdad usa $norm(V-V^*)<=e+gamma norm(V-V^*)$. La segunda combina esa desigualdad con la cota de una política greedy demostrada en #verdem(<dem:ch8-parada>). Son dos objetivos de precisión diferentes.

=== Policy Iteration
<sec:ch8-pi>

Inicializar una política determinista. Evaluarla resolviendo $(I-gamma P^pi)V^pi=r^pi$. Mejorarla escogiendo acciones que maximicen $r(s,a)+gamma sum_(s')P(s'|s,a)V^pi(s')$. *En un empate, conservar la acción actual si es maximizadora.* Detenerse cuando no cambie ninguna acción. La evaluación aquí es exacta; los errores de un solucionador numérico requieren control adicional.

#thm-env("theorem", name: [Mejora de políticas], key: "thm:ch8-mejora")[
  Una política greedy $pi'$ respecto de $V^pi$ satisface $V^(pi')>=V^pi$. Con la regla de desempate anterior, si cambia una acción, la desigualdad es estricta en al menos un estado.
]
#proof-env[
  Sea $d=T^(pi')V^pi-V^pi>=0$. Entonces
  $ V^(pi')-V^pi=(I-gamma P^(pi'))^(-1)d=sum_(j=0)^infinity gamma^j(P^(pi'))^j d>=0. $
  Si una acción cambia bajo la regla indicada, $d(s)>0$ en algún estado y el término $j=0$ prueba la mejora estricta.
]
#thm-env("corollary", name: [Terminación finita], key: "cor:ch8-pi-finita")[
  No se repite ninguna política antes de detenerse. Hay a lo sumo $abs(cal(A))^(abs(cal(S)))$ políticas deterministas. Al detenerse, $T^*V^pi=V^pi$, de modo que la política es óptima. Este argumento es de mejora y finitud; no afirma que la iteración de políticas sea una contracción.
]

=== Bandidos Multi-Brazo: Exploración y Aprendizaje
<sec:ch8-bandits>

Un bandido separa el aprendizaje de recompensas de las transiciones físicas. La elección actual modifica los datos disponibles para elecciones futuras. Por ello, un bandido con varias rondas sigue siendo un problema secuencial aunque no cambie el estado físico.

#thm-env("definition", name: [Bandido estocástico], key: "def:ch8-mab")[
  Hay $K$ brazos con distribuciones desconocidas $nu_a$, medias $mu_a$ y horizonte $T$. Las recompensas sucesivas de cada brazo son independientes e idénticamente distribuidas; las secuencias de los brazos son independientes. La acción $A_t$ usa la historia anterior. Definimos $mu^*=max_a mu_a$, $Delta_a=mu^*-mu_a$ y el pseudorregret esperado
  $ cal(R)_T=EE[sum_(t=1)^T Delta_(A_t)]=sum_a Delta_a EE[N_a(T)]. $
]
#thm-env("proposition", name: [Estado físico y estado de información], key: "prop:ch8-mab-mdp")[
  Con medias conocidas, un bandido puede representarse como un MDP de un estado que elige repetidamente un brazo óptimo. Con medias desconocidas, la planificación bayesiana debe incluir el posterior y el horizonte restante. Una única ronda no contiene el beneficio futuro de explorar. El estado físico constante no convierte todo el aprendizaje en un problema de un paso.
]

#thm-env("theorem", name: [UCB1: garantía bajo recompensas acotadas], key: "thm:ch8-ucb1")[
  Para recompensas en $[0,1]$ y $T>=K$, UCB1 juega cada brazo una vez y luego elige un máximo de
  $ hat(mu)_a(t-1)+sqrt((2 log t)/N_a(t-1)). $
  El resultado de #cite(<auer2002finite>) establece
  $ cal(R)_T<=8 sum_(a:Delta_a>0)(log T)/Delta_a +(1+pi^2/3)sum_a Delta_a. $
  Es una cota dependiente de las brechas. No asegura que la constante asintótica sea óptima.
]
Este resultado se usa con atribución bibliográfica; su demostración completa no se desarrolla aquí. Combina concentración de medias con un control del número de selecciones de brazos subóptimos. Las hipótesis de independencia y acotación son parte de la garantía, no propiedades automáticas de datos longitudinales.

#thm-env("proposition", name: [Thompson Sampling y decisión de Bayes], key: "prop:ch8-thompson")[
  Thompson Sampling extrae un vector de medias del posterior conjunto y selecciona un brazo que maximice la muestra. Sin empates, la probabilidad de seleccionar un brazo coincide con su probabilidad posterior de ser óptimo. Esto no implica que minimice el riesgo posterior de la acción actual ni el riesgo bayesiano del horizonte completo.
]
Con una sola ronda restante, la regla de Bayes para maximizar recompensa elige la mayor media posterior. El ejemplo al final del capítulo exhibe la diferencia mediante un cálculo exacto.

#thm-env("theorem", name: [Cota asintótica en bandidos Bernoulli], key: "thm:ch8-lai-robbins")[
  Considérese la familia de bandidos Bernoulli con medias en $(0,1)$ y mejor brazo único. Una política uniformemente eficiente satisface $cal(R)_T=o(T^alpha)$ para todo $alpha>0$ en cada instancia de la familia. La cota de tipo Lai–Robbins es
  $ liminf_(T->infinity) cal(R)_T/(log T)>=sum_(a:Delta_a>0)Delta_a/"kl"(mu_a,mu^*), $
  donde $"kl"(p,q)=p log(p/q)+(1-p)log((1-p)/(1-q))$.
]
La demostración por cambio de medida y sus extensiones se remiten a #cite(<lai1985asymptotically>) y #cite(<lattimore2020bandit>). La formulación se restringe a Bernoulli: para familias generales, la información relevante requiere optimizar sobre distribuciones alternativas. UCB1 no alcanza en general la constante de esta cota. Cualquier afirmación de optimalidad de otra variante debe indicar algoritmo, familia y condiciones.

#thm-env("example", name: [SSCH: una comparación calculable de exploración], key: "ex:ssch-bandits-cap08", es-sintetico: true)[
  Como ilustración matemática, cuatro opciones tienen probabilidades de éxito $(0.3,0.5,0.6,0.8)$. No son estimaciones clínicas. La media de una selección uniforme es $0.55$, por lo que en 20 rondas su pseudorregret esperado es $20(0.8-0.55)=5$. El oráculo que conoce las medias tiene pseudorregret cero. Probar una vez cada opción cuesta en expectativa $0.5+0.3+0.2+0=1$ de pseudorregret.

  Estas cifras son cálculos de expectativas bajo el modelo declarado. No se atribuyen porcentajes de éxito a UCB1 o Thompson Sampling sin ejecutar un experimento. Una aplicación real necesitaría definir población, resultados observables, tiempos de observación, heterogeneidad y restricciones sobre las acciones.
]

=== Bandidos, Memoria y Horizonte
<sec:ch8-bandits-thompson>

#thm-env("definition", name: [Estado posterior Beta–Bernoulli], key: "def:ch8-mab-thompson")[
  Para brazos Bernoulli con priors Beta independientes, el estado de información reúne $(alpha_a,beta_a)$ para cada brazo y el número de rondas restantes. Tras un éxito en $a$, aumentar $alpha_a$; tras un fracaso, aumentar $beta_a$. La probabilidad predictiva de éxito es $alpha_a/(alpha_a+beta_a)$.
]
#thm-env("proposition", name: [Última ronda], key: "prop:ch8-mab-mdp-thompson")[
  Con una ronda restante y utilidad igual a la recompensa, la acción bayesiana maximiza la media posterior. La exploración no aporta recompensa futura dentro de ese horizonte. Con más rondas, la recursión óptima debe considerar la actualización del posterior y su efecto sobre decisiones posteriores.
]
#thm-env("example", name: [SSCH: muestreo posterior frente a decisión final], key: "ex:ch8-bandit-ssch", es-sintetico: true)[
  Considere dos opciones con posteriores independientes $mu_1 tilde "Beta"(4,1)$ y $mu_2 tilde "Beta"(1,1)$. Sus medias son $0.8$ y $0.5$. Una decisión bayesiana de última ronda elige la primera opción y obtiene recompensa predictiva $0.8$.

  Thompson Sampling elige la primera con probabilidad $Prob(tilde(mu)_1>tilde(mu)_2)=EE[tilde(mu)_1]=0.8$. Como el muestreo interno es independiente de los parámetros verdaderos condicionalmente a los datos, su recompensa predictiva es $0.8(0.8)+0.2(0.5)=0.74$. La diferencia $0.06$ muestra que muestrear del posterior y actuar según esa muestra no equivale a minimizar el riesgo posterior. El cálculo es sintético y no compara desempeño a largo plazo.
]

=== Conexión con Teoría de Decisión de Wald
<sec:ch8-wald>

#thm-env("note", name: [Alcance de la representación], key: "thm:ch8-wald-bellman", aliases: ("thm:ch8-bellman-exp",))[
  En el @ch:isomorfismo, el estado inicial es la observación $X tilde P_theta$, la política reproduce la regla de decisión y la recompensa es $-L(theta,a)$. Después de actuar se pasa determinísticamente a un estado terminal. Para cada parámetro, el valor agregado sobre la distribución inicial satisface $J_theta(pi_delta)=-R(theta,delta)$. Es una familia indexada por $theta$; el agente no recibe ese parámetro desconocido como información para actuar.

  No se introduce una recursión sobre un supuesto «siguiente parámetro» sin especificar su dinámica. La programación dinámica bayesiana de observación y parada requiere un modelo secuencial adicional y un estado posterior suficiente, como se desarrolla por separado en ese capítulo.
]
#thm-env("corollary", name: [Principio de continuación óptima], key: "cor:ch8-principio")[
  En el MDP finito descontado, seleccionar en cada estado una acción que maximice la expresión de Bellman para $V^*$ produce una política óptima. Se deduce de que su operador tiene a $V^*$ como punto fijo. No equivale por sí solo a admisibilidad estadística sobre una familia de modelos desconocidos.
]

=== Condiciones para Preservación de Contracción
<sec:ch8-contraccion-condiciones>

#thm-env("proposition", name: [Condiciones suficientes], key: "thm:ch8-condiciones-contraccion")[
  Un kernel estocástico, recompensas acotadas y $gamma<1$ bastan para que Bellman actúe sobre funciones acotadas y sea una contracción en norma supremo. La recompensa se cancela al comparar dos aplicaciones del operador; su cota asegura que este preserve el espacio. Estas condiciones no se presentan como una caracterización necesaria de todos los operadores posibles.
]
#thm-env("proposition", name: [Proyección y norma pertinente], key: "prop:ch8-perdida")[
  Si una aproximación $Pi$ es Lipschitz con constante $L$ en norma supremo, $Pi T^*$ tiene constante a lo sumo $L gamma$. Por tanto $L gamma<1$ es una condición suficiente de contracción sobre un espacio completo que el operador preserve. Una proyección lineal arbitraria no garantiza esa desigualdad.

  Para evaluar una política fija, si $mu$ es una distribución estacionaria estrictamente positiva de $P^pi$, Jensen da $norm(P^pi v)_mu<=norm(v)_mu$. Una proyección ortogonal en $L^2(mu)$ es no expansiva, de modo que $Pi T^pi$ es una contracción de factor $gamma$ en esa norma. Este argumento no se extiende automáticamente al operador óptimo ni a una distribución de muestreo distinta.
]

#mi-tabla(caption: [Condiciones de convergencia], key: "tab:ch8-preservacion", table(
  columns: (30%, 35%, 35%),
  table.header([*Procedimiento*], [*Condición*], [*Conclusión*]),
  [VI exacto], [MDP finito descontado], [Contracción en norma supremo],
  [PI exacto], [Evaluación exacta y conservación en empates], [Mejora y terminación finita],
  [VI proyectado], [$L gamma<1$ en el espacio indicado], [Punto fijo aproximado único],
  [Evaluación proyectada], [Política fija, distribución estacionaria y proyección ortogonal], [Contracción en $L^2(mu)$],
  [Métodos ajustados a datos], [Hipótesis específicas del estimador y muestreo], [No hay garantía universal],
))

== Del operador de Bellman al cálculo de una política
<sec:ch8-langgraph>

=== Value Iteration como Flujo de Computación
<sec:ch8-vi-flujo>

El nodo de actualización calcula $W=T^*V$. El de verificación calcula $e=norm(W-V)_infinity$ y comprueba la tolerancia seleccionada. El de extracción devuelve una política greedy respecto de $V$, junto con el residuo, el descuento y la cota certificada. Registrar el objetivo —error de valor o pérdida de política— permite interpretar la parada.

=== Criterios de Parada Rigurosos
<sec:ch8-criterios>

Para $0<gamma<1$, $R_"max">0$ y $V_0=0$, una cantidad suficiente de actualizaciones para error de valor $epsilon.alt>0$ es
$ k>=max(0,ceil((log(R_"max"/(epsilon.alt(1-gamma))))/(log(1/gamma)))). $
Para certificar una política, puede usarse directamente el residuo y el @cor:ch8-parada. Cuando $gamma$ se aproxima a uno, ambas cotas se deterioran. Un residuo pequeño calculado con un modelo estimado certifica planificación dentro de ese modelo; no certifica exactitud respecto del entorno verdadero.

#verlanggraph

#[
#set heading(numbering: none, outlined: false)
=== Hilo longitudinal: SSCH
]

#thm-env("example", name: [SSCH: modelo reducido de dos estados], key: "ex:ssch-cap08", es-sintetico: true)[
  Para aislar el efecto del futuro, se introduce una reducción pedagógica, no una especificación completa del caso longitudinal. Hay estados $g$ y $b$, acciones $0$ y $1$, y descuento $gamma=0.9$. Todas las transiciones son deterministas:
  #table(columns: (20%,20%,30%,30%),
    table.header([*Estado*],[*Acción*],[*Recompensa*],[*Siguiente estado*]),
    [$g$],[$0$],[$1$],[$b$],
    [$g$],[$1$],[$0.5$],[$g$],
    [$b$],[$0$],[$0$],[$b$],
    [$b$],[$1$],[$-0.5$],[$g$],
  )
  La solución es $V^*(g)=5$, $V^*(b)=4$, con acción $1$ en ambos estados. En $g$, los valores de las acciones son $1+0.9(4)=4.6$ y $0.5+0.9(5)=5$. En $b$ son $0.9(4)=3.6$ y $-0.5+0.9(5)=4$. Esto verifica Bellman y, por unicidad, prueba optimalidad.

  Desde cero, las primeras iteraciones son $V_1=(1,0)$, $V_2=(1.4,0.4)$ y $V_3=(1.76,0.76)$. Maximizar solo la recompensa inmediata elegiría $0$ en ambos estados. El ejemplo muestra por qué el costo actual puede compensarse con consecuencias futuras; no valida una recomendación clínica.
]

=== FrozenLake-v1: Verificación Computacional en Entorno Estándar
<sec:ch8-frozenlake>

#thm-env("example", name: [Value Iteration con modelo tabular explícito], key: "ex:ch8-frozenlake")[
  Se usa el mapa estándar `4x4` de FrozenLake-v1, con deslizamiento y $gamma=0.99$. Las acciones son izquierda, abajo, derecha y arriba, codificadas de 0 a 3. Las recompensas son uno al alcanzar la meta y cero en los demás casos. El indicador terminal anula el retorno futuro. Se resuelve el modelo base, sin el límite temporal del wrapper de episodios.

  ```python
  import gymnasium as gym
  import numpy as np

  env = gym.make("FrozenLake-v1", map_name="4x4", is_slippery=True)
  P = env.unwrapped.P
  gamma = 0.99
  V = np.zeros(16)
  for k in range(10000):
      Q = np.array([
          [sum(p * (r + gamma * (not done) * V[next_s])
               for p, next_s, r, done in P[s][a])
           for a in range(4)] for s in range(16)
      ])
      W = Q.max(axis=1)
      residual = np.max(np.abs(W - V))
      if residual <= 1e-12:
          break
      V = W
  else:
      raise RuntimeError("No se alcanzo la tolerancia")
  policy = Q.argmax(axis=1)
  print(gym.__version__, k, residual, V[[0, 14, 15]])
  env.close()
  ```

  Con Gymnasium 1.4.0, esta ejecución devuelve $k=703$, residuo aproximadamente $9.805 times 10^(-13)$ y valores $(0.54202593,0.86283743,0)$. El índice $k$ cuenta las actualizaciones aceptadas antes de comprobar la parada; se realizan 704 evaluaciones del operador. La cota de error del vector es menor que $10^(-10)$ y la cota conservadora de pérdida de la política es menor que $1.98 times 10^(-8)$.

  El valor inicial es un retorno descontado, no una tasa de éxito por episodio. Esta comprobación numérica ilustra las fórmulas; no sustituye la prueba de contracción ni informa una comparación experimental entre algoritmos. Documentación: #link("https://gymnasium.farama.org/environments/toy_text/frozen_lake/")[FrozenLake de Gymnasium].
]

=== Trazabilidad: Del Teorema al Componente
<sec:ch8-trazabilidad>

#mi-tabla(caption: [Garantías y evidencia necesaria], key: "tab:ch8-trazabilidad", table(
  columns: (30%,35%,35%),
  table.header([*Resultado*],[*Componente*],[*Comprobación*]),
  [MDP], [Representación del estado], [Kernel, recompensa y propiedad de Markov],
  [Bellman], [Planificador], [Modelo y objetivo descontado definidos],
  [Contracción], [Actualizador de valores], [Descuento y norma],
  [Mejora de políticas], [Evaluación y mejora], [Exactitud y regla de desempate],
  [Cota residual], [Parada y extracción], [Mismo vector para residuo y política],
  [Inferencia del valor], [Estimador basado en trayectorias], [Supuestos estadísticos adicionales],
))

#[
#set heading(numbering: none, outlined: false)
=== Del modelo conocido al modelo aprendido
]

Estimar $P$ mediante un modelo paramétrico fija una familia de transiciones de dimensión finita. En un espacio finito fijo, incluso una tabla completamente libre tiene dimensión finita: «tabular» no significa automáticamente «no paramétrico». En espacios continuos pueden emplearse modelos no paramétricos de transición o recompensa, con condiciones de suavidad y cobertura. Un enfoque semiparamétrico puede dirigir la inferencia al escalar $J_rho^pi$ dejando componentes auxiliares de dimensión infinita.

Estas son elecciones sobre el modelo estadístico, distintas del algoritmo de Bellman. Una tabla estimada que sigue siendo estocástica conserva la contracción de su operador exacto; aun así, su punto fijo puede diferir del valor verdadero. El @ch:herramientas desarrolla instrumentos para analizar esa incertidumbre; el @ch:ope estudia evaluación con datos de otra política. El @ch:isomorfismo delimita la representación de Wald y el @ch:fallos estudia fronteras de transferencia.

== Ejercicios
<sec:ch8-ejercicios>

#exercise-env(key: "ex:ch8-ej1")[
  Use la tabla completa del ejemplo reducido de SSCH. Escriba Bellman, verifique $V^*=(5,4)$ y calcule las tres primeras iteraciones desde cero. Evalúe la política que siempre elige $0$ y compare ambas políticas.
]
#exercise-env(key: "ex:ch8-ej2")[
  Demuestre la contracción de $T^pi$ y construya un MDP con varias políticas óptimas y un único valor óptimo. Explique por qué cambiar acciones empatadas puede impedir la parada basada en igualdad de políticas.
]
#exercise-env(key: "ex:ch8-ej3")[
  Para $R_"max"=10$, $gamma=0.95$ y $V_0=0$, calcule cantidades suficientes de actualizaciones para errores de valor $0.1$ y $0.01$. Después calcule los umbrales residuales que certifican esas mismas tolerancias como pérdidas de política. Distinga ambas preguntas.
]
#exercise-env(key: "ex:ch8-ej4")[
  Compare el costo de una actualización de VI con el de resolver el sistema lineal de PI. Explique por qué menos iteraciones no implica necesariamente menor tiempo total. Identifique qué cambia si la evaluación de la política es aproximada.
]
#exercise-env(key: "ex:ch8-ej5")[
  En la representación de un paso del @ch:isomorfismo, derive $J_theta(pi_delta)=-R(theta,delta)$ integrando sobre el estado inicial. Indique qué hipótesis adicionales exigiría representar una decisión con observaciones futuras dependientes de las acciones.
]

== Lecturas Propuestas
<sec:ch8-lecturas>

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Obligatorias
]

+ #cite(<puterman2005markov>, form: "prose"), _Markov Decision Processes_: modelos descontados, evaluación y mejora de políticas.
+ #cite(<sutton2018reinforcement>, form: "prose"), _Reinforcement Learning_: capítulos sobre MDP y programación dinámica. Distinguir modelo conocido y aprendizaje.

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Complementarias
]

+ #cite(<bellman1957dynamic>, form: "prose"), _Dynamic Programming_: principio de optimalidad.
+ #cite(<lattimore2020bandit>, form: "prose"), _Bandit Algorithms_: UCB, cotas por cambio de medida y muestreo posterior. #link("https://tor-lattimore.com/downloads/book/book.pdf")[Texto de los autores].
+ Documentación de FrozenLake enlazada en el ejemplo: revisar recompensas, terminalidad y diferencia entre el modelo base y los wrappers antes de replicar resultados.
