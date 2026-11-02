// Puerto de apendices/apendice_demostraciones.tex — Demostraciones Completas.
#import "../plantilla.typ": *

= Demostraciones y argumentos complementarios
<app:demostraciones>

Las demostraciones permiten volver desde un enunciado hasta las razones que
lo sostienen. Este apéndice reúne los argumentos por temas, con referencias
al resultado correspondiente en el cuerpo del libro. Cuando se ofrece un
bosquejo o se remite al desarrollo de la fuente, esa indicación delimita
lo que se presenta aquí.

La lectura puede comenzar en el resultado que haya motivado la consulta.
Las familias exponenciales y la reducción de datos acompañan las herramientas
estadísticas; las pruebas de decisión, programación dinámica y evaluación
siguen las preguntas que enlazan el resto de la exposición.

== Familias exponenciales
<sec:dem-ch1>

La función de log-partición relaciona el modelo con sus momentos. Sus propiedades preparan el uso de los estadísticos naturales del @ch:herramientas.

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4, 9 y 10; sostiene familias exponenciales.
=== Propiedades de la función de log-partición
<dem:ch1-logparticion>
#dem-alias("dem:ch1-suficiencia-natural")

#proof-env(name: [completa del @thm:ch1-logparticion])[
  Sea $f(x|eta) = h(x) exp{eta^top T(x) - A(eta)}$ la densidad de una
  familia exponencial regular con espacio de parámetros naturales
  $cal(H)$ abierto.

  *1. Convexidad de $A(eta)$.* Por definición, $A(eta) = log integral
  h(x) exp{eta^top T(x)} dif mu (x)$. Para cualquier $eta_1, eta_2 in
  cal(H)$ y $lambda in [0,1]$, aplicamos la desigualdad de Hölder:
  $
    exp{A(lambda eta_1 + (1-lambda)eta_2)}
    &= integral h(x) exp{[lambda eta_1 + (1-lambda)eta_2]^top T(x)} dif mu (x) \
    &= integral [h(x) exp{eta_1^top T(x)}]^lambda
       [h(x) exp{eta_2^top T(x)}]^(1-lambda) dif mu (x) \
    &lt.eq (integral h(x) exp{eta_1^top T(x)} dif mu (x))^lambda
       (integral h(x) exp{eta_2^top T(x)} dif mu (x))^(1-lambda) \
    &= exp{lambda A(eta_1) + (1-lambda)A(eta_2)}
  $
  Tomando logaritmos, $A(lambda eta_1 + (1-lambda)eta_2) lt.eq lambda
  A(eta_1) + (1-lambda)A(eta_2)$, por lo que $A$ es convexa.

  *2. $nabla A(eta) = EE_eta [T(X)]$.* Diferenciamos la condición de
  normalización:
  $ 1 = integral f(x|eta) dif mu (x) = integral h(x) exp{eta^top T(x) - A(eta)} dif mu (x) $
  Derivando respecto a $eta_j$ e intercambiando derivación e
  integración (justificado por regularidad):
  $
    0 &= (partial)/(partial eta_j) integral h(x) exp{eta^top T(x) - A(eta)} dif mu (x) \
      &= integral h(x) exp{eta^top T(x) - A(eta)} [T_j (x) - partial_j A(eta)] dif mu (x) \
      &= EE_eta [T_j (X)] - partial_j A(eta)
  $
  Por lo tanto, $partial_j A(eta) = EE_eta [T_j (X)]$ para cada $j$, es
  decir, $nabla A(eta) = EE_eta [T(X)]$.

  *3. $nabla^2 A(eta) = Cov_eta (T(X))$.* Diferenciamos nuevamente la
  identidad $partial_j A(eta) = EE_eta [T_j (X)]$:
  $
    partial_k partial_j A(eta)
    &= (partial)/(partial eta_k) integral T_j (x) f(x|eta) dif mu (x) \
    &= integral T_j (x) (partial)/(partial eta_k) f(x|eta) dif mu (x) \
    &= integral T_j (x) [T_k (x) - partial_k A(eta)] f(x|eta) dif mu (x) \
    &= EE_eta [T_j (X) T_k (X)] - EE_eta [T_j (X)] EE_eta [T_k (X)] \
    &= Cov_eta (T_j (X), T_k (X))
  $
  Por lo tanto, $nabla^2 A(eta) = Cov_eta (T(X))$, que es semidefinida
  positiva por convexidad de $A$. En familias minimales, es definida
  positiva.
]

== Reducción de datos
<sec:dem-ch2>

La factorización y la completitud precisan qué información conserva un estadístico bajo el modelo considerado. Los argumentos siguientes se consultan junto con las condiciones de sus enunciados en el @ch:herramientas.

// CLASIF 2026-09-22: (a) — Factorización citada en caps. 4, 9 y 10; sostiene suficiencia del agente.
=== Teorema de Factorización de Neyman-Fisher
<dem:ch2-neyman-fisher>
#proof-env(name: [del @thm:ch2-neyman-fisher])[
En el modelo dominado puede elegirse una mezcla numerable $Q=sum_j c_j P_(theta_j)$, con $c_j>0$, que domina todas las leyes de la familia (lema de Halmos–Savage). Trabajamos con $f_theta=dif P_theta/dif Q$.
Si $T$ es suficiente, su núcleo condicional común $K(t,B)$ también es la ley de $X$ dado $T$ bajo $Q$. Al escribir $g_theta=dif P_theta^T/dif Q^T$, la desintegración da
$ P_theta(B)=integral K(t,B)g_theta(t)dif Q^(T) (t)=integral_B g_theta(T(x))dif Q(x). $
Luego $f_theta(x)=g_theta(T(x))$, casi seguramente bajo $Q$. Multiplicar por la densidad de $Q$ respecto de la medida dominante da la factorización solicitada.
Recíprocamente, una factorización respecto de la medida original implica que $dif P_theta/dif Q$ es función de $T$, pues la densidad de la mezcla tiene el mismo factor $h$. Entonces
$ EE_theta[bb(1)_B|T]=EE_Q[f_theta bb(1)_B|T]/EE_Q[f_theta|T]=K(T,B) $
donde el denominador es positivo; fuera de ese soporte la versión es irrelevante para $P_theta$. Los espacios estándar de Borel aseguran los núcleos regulares usados. No se integra sobre fibras usando una medida ambiente que les asigne masa cero.
]


=== Criterio de suficiencia minimal
<dem:ch2-lehmann-scheffe-minimal>
#dem-alias("dem:ch2-lehmann-scheffe")
#proof-env(full: [Argumento del criterio de proporcionalidad])[
Bajo las condiciones de versiones y medibilidad del @thm:ch2-lehmann-scheffe-minimal, las clases de observaciones con verosimilitudes proporcionales determinan los cocientes $f_theta/f_(theta_0)$. Su sigma-álgebra es suficiente por factorización. Cualquier estadístico suficiente $S$ hace esos cocientes medibles respecto de $S$; por tanto determina las clases y, por la hipótesis medible del criterio, $T=h(S)$ casi seguramente. Esta es la dirección correcta de la minimalidad. No se necesita ni existe en general una inversa de $h$.
En un modelo multinomial con tamaño fijo conocido, los conteos y las proporciones son transformaciones biyectivas y tienen la misma suficiencia minimal. En una trayectoria de Markov los conteos por pares pueden factorizar la verosimilitud, pero sus totales aleatorios impiden deducir completitud o propiedades UMVUE del experimento multinomial de tamaño fijo.
]


=== Completitud en familias exponenciales
<dem:ch2-completitud-exp>
#dem-alias("dem:ch2-completitud-exponencial")

#proof-env(name: [completa del @thm:ch2-completitud-exp])[
  Sea $cal(P) = {P_eta : eta in Xi}$ una familia exponencial natural
  con densidad:
  $ p(x|eta) = h(x) exp{eta^T T(x) - A(eta)} $
  donde $Xi$ contiene un conjunto abierto en $RR^k$.

  *Definición de completitud:* El estadístico $T(X)$ es _completo_ si
  para toda función medible $g: cal(T) -> RR$ tal que:
  $ EE_eta [g(T(X))] = 0 quad forall eta in Xi $
  se sigue que $g(T(X)) = 0$ casi seguramente bajo todo $P_eta$.

  *Demostración:* Supongamos que $EE_eta [g(T(X))] = 0$ para todo
  $eta in Xi$. Entonces:
  $
    0 &= EE_eta [g(T(X))] = integral g(T(x)) h(x) exp{eta^T T(x) - A(eta)} dif x \
      &= exp{-A(eta)} integral g(T(x)) h(x) exp{eta^T T(x)} dif x
  $
  Multiplicando por $exp{A(eta)}$:
  $ integral g(T(x)) h(x) exp{eta^T T(x)} dif x = 0 quad forall eta in Xi $
  Para justificar unicidad, trabaje con la ley de $T$, no con una transformada en la variable $x$. Fije $eta_0$ interior y defina la medida firmada finita $nu(dif t)=g(t)P_(eta_0)^(T) (dif t)$. Su transformada de Laplace es cero en un entorno del origen, porque
  $ integral exp(u^top t)nu(dif t)=exp(A(eta_0+u)-A(eta_0))EE_(eta_0+u)[g(T)]=0. $
  La integrabilidad absoluta de $g$ bajo cada parámetro asegura existencia en ese entorno. La unicidad de la transformada implica $nu=0$, luego $g(T)=0$ bajo $P_(eta_0)$. La equivalencia de las leyes de $T$ en el soporte común extiende la conclusión a todo parámetro de la familia.

  *Condiciones de regularidad:* Esta demostración requiere:
  + El espacio de parámetros naturales $Xi$ contiene un conjunto
    abierto en $RR^k$
  + La función $h(x) > 0$ en el soporte de la familia
  + La transformada de la medida firmada de $T$ existe en un entorno del origen
  + La función $g$ es medible y la integral está bien definida

  *Alcance:* Aplicar este resultado a conteos de una trayectoria requiere demostrar sus hipótesis en ese experimento. Los conteos de transiciones no tienen en general una ley multinomial de tamaño fijo; tampoco se ha probado aquí que el orden sea ancilar ni que los cocientes de conteos sean insesgados.
]

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4, 9 y 10; sostiene independencia ancilar.
=== Teorema de Basu
<dem:ch2-basu>

#proof-env(name: [completa del @thm:ch2-basu])[
  Sea $T(X)$ un estadístico suficiente completo y $A(X)$ un
  estadístico ancilar. Queremos demostrar que $T(X)$ y $A(X)$ son
  independientes.

  *Definiciones:*
  - $T(X)$ es _suficiente completo_: la distribución de $X | T(X)$ no
    depende de $theta$, y si $EE_theta [g(T(X))] = 0$ para todo
    $theta$, entonces $g(T(X)) = 0$ casi seguramente.
  - $A(X)$ es _ancilar_: la distribución de $A(X)$ no depende de
    $theta$.

  *Demostración:*

  Para cualquier conjunto medible $B$ en el espacio de $A(X)$,
  consideramos la probabilidad condicional:
  $ h(T(X)) = P_theta (A(X) in B | T(X)) $

  *Paso 1: $h(T(X))$ no depende de $theta$.*

  Por suficiencia de $T(X)$, la distribución condicional $X | T(X)$ no
  depende de $theta$. Por tanto, $P_theta (A(X) in B | T(X))$ tampoco
  depende de $theta$, y podemos escribir $h(T(X))$ sin subíndice
  $theta$.

  *Paso 2: Tomar esperanza sobre $theta$.*
  $
    EE_theta [h(T(X))]
    &= EE_theta [P_theta (A(X) in B | T(X))] \
    &= P_theta (A(X) in B) quad "(ley de la probabilidad total)"
  $
  Como $A(X)$ es ancilar, $P_theta (A(X) in B) = P(A(X) in B)$ no
  depende de $theta$. Por tanto:
  $ EE_theta [h(T(X))] = P(A(X) in B) quad forall theta $

  *Paso 3: Aplicar completitud.*

  Definimos $g(T(X)) = h(T(X)) - P(A(X) in B)$. Entonces:
  $ EE_theta [g(T(X))] = EE_theta [h(T(X))] - P(A(X) in B) = 0 quad forall theta $
  Por completitud de $T(X)$, esto implica que:
  $ g(T(X)) = 0 quad "casi seguramente" $
  Por tanto:
  $ h(T(X)) = P(A(X) in B) quad "casi seguramente" $

  *Paso 4: Conclusión de independencia.*

  La ecuación anterior significa que:
  $ P_theta (A(X) in B | T(X) = t) = P(A(X) in B) quad "para casi todo " t $
  Esto es exactamente la definición de independencia entre $A(X)$ y
  $T(X)$: la distribución condicional de $A(X)$ dado $T(X)$ no depende
  del valor de $T(X)$.

  *Condiciones de regularidad:* Esta demostración requiere:
  + $T(X)$ es suficiente completo
  + $A(X)$ es ancilar
  + Las probabilidades condicionales están bien definidas

  *Alcance:* Aplicar este resultado a conteos de una trayectoria requiere demostrar sus hipótesis en ese experimento. Los conteos de transiciones no tienen en general una ley multinomial de tamaño fijo; tampoco se ha probado aquí que el orden sea ancilar ni que los cocientes de conteos sean insesgados.
]

=== Riesgo de una regla equivariante
<dem:ch2-equivarianza>
#proof-env[
Si $X tilde P_theta$ y el modelo es invariante, $g X tilde P_(g theta)$. Para pérdida invariante y regla equivariante,
$ R(g theta,delta)=EE_theta[L(g theta,delta(g X))]=EE_theta[L(g theta,g delta(X))]=R(theta,delta). $
Se exige que las esperanzas estén definidas. El riesgo es constante en cada órbita. Una acción transitiva da constancia global, pero no demuestra por sí sola minimax ni existencia de una regla óptima equivariante.
]

== Estimación puntual y precisión
<sec:dem-ch3>

Con una reducción de datos justificada, la comparación de estimadores puede apoyarse en condicionamiento, unicidad o cotas de información. Cada argumento conserva el criterio de optimalidad de su enunciado.

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4, 9 y 10; sostiene reducción de varianza.
=== Teorema de Rao-Blackwell
<dem:ch3-rao-blackwell>
#dem-alias("dem:ch2-rao-blackwell-preview")

#proof-env(name: [completa del @thm:ch3-rao-blackwell])[
  Sea $delta(X)$ un estimador arbitrario y $T(X)$ un estadístico
  suficiente. Definimos $delta^*(X) = EE[delta(X) | T(X)]$.

  *Insesgadez:* Si $delta(X)$ es insesgado para $g(theta)$, entonces:
  $ EE_theta [delta^*(X)] = EE_theta [EE[delta(X) | T(X)]] = EE_theta [delta(X)] = g(theta) $
  por la ley de la esperanza iterada. Por tanto, $delta^*(X)$ también
  es insesgado.

  *Reducción de varianza:* Usamos la ley de la varianza total:
  $ Var_theta (delta(X)) = EE_theta [Var_theta (delta(X) | T(X))] + Var_theta (EE_theta [delta(X) | T(X)]) $
  El primer término es $EE_theta [Var_theta (delta(X) | T(X))] gt.eq
  0$ y el segundo término es $Var_theta (delta^*(X))$. Por tanto:
  $ Var_theta (delta(X)) = Var_theta (delta^*(X)) + EE_theta [Var_theta (delta(X) | T(X))] gt.eq Var_theta (delta^*(X)) $
  La igualdad se cumple si y solo si $Var_theta (delta(X) | T(X)) = 0$
  casi seguramente, lo que significa que $delta(X)$ es función de
  $T(X)$.

  *Condiciones de regularidad:* Esta demostración requiere:
  + $T(X)$ es suficiente para $theta$
  + $delta(X)$ es un estimador insesgado
  + Las esperanzas y varianzas condicionales están bien definidas
  + $EE[delta(X)^2] < infinity$ (varianza finita)

  *Aplicación al SSCH tabular:* Fije una fila $(s,a)$ y un número conocido $n$ de transiciones independientes desde ella. Sus cinco conteos de destino son suficientes para la probabilidad multinomial de esa fila. Si se parte del indicador del destino de la primera transición, condicionarlo en esos conteos produce la proporción muestral y reduce la varianza de $p_j(1-p_j)$ a $p_j(1-p_j)/n$. Para todas las filas se conserva el conjunto $N(s,a,s')$; cinco conteos agregados no bastan. La afirmación general es varianza no mayor, con igualdad posible; no se traslada sin justificación a una trayectoria con números aleatorios de visitas.
]

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4, 9 y 10; garantiza UMVUE.
=== Teorema de Lehmann-Scheffé
<dem:ch3-lehmann-scheffe>

#proof-env(name: [completa del @thm:ch3-lehmann-scheffe])[
  Sea $T(X)$ un estadístico suficiente completo y $delta(T(X))$ un
  estimador insesgado para $g(theta)$ con segundo momento finito bajo cada modelo. La comparación se realiza con estimadores insesgados de segundo momento finito. Queremos mostrar que
  $delta(T(X))$ es el UMVUE.

  *Unicidad:* Supongamos que existe otro estimador insesgado
  $tilde(delta)(X)$ para $g(theta)$. Por el teorema de Rao-Blackwell,
  el estimador $tilde(delta)^*(X) = EE[tilde(delta)(X) | T(X)]$ tiene
  varianza menor o igual a $tilde(delta)(X)$ y también es insesgado.

  Como $T(X)$ es suficiente, $tilde(delta)^*(X)$ es función de $T(X)$,
  es decir, $tilde(delta)^*(X) = phi(T(X))$ para alguna función
  $phi$.

  *Aplicación de completitud:* Consideramos la diferencia:
  $ EE_theta [delta(T(X)) - phi(T(X))] = g(theta) - g(theta) = 0 quad forall theta $
  Como $T(X)$ es completo, esto implica que:
  $ delta(T(X)) - phi(T(X)) = 0 quad "casi seguramente" $
  Por tanto, $delta(T(X)) = phi(T(X)) = tilde(delta)^*(X)$ casi
  seguramente.

  *Optimalidad:* Como $tilde(delta)^*(X)$ tiene varianza menor o igual
  a cualquier otro estimador insesgado $tilde(delta)(X)$, y $delta(T(X))
  = tilde(delta)^*(X)$, concluimos que $delta(T(X))$ tiene varianza
  mínima entre todos los estimadores insesgados.

  *Condiciones de regularidad:* Esta demostración requiere:
  + $T(X)$ es suficiente para $theta$
  + $T(X)$ es completo
  + $delta(T(X))$ es insesgado para $g(theta)$
  + Las esperanzas están bien definidas

  *Alcance:* Aplicar este resultado a conteos de una trayectoria requiere demostrar sus hipótesis en ese experimento. Los conteos de transiciones no tienen en general una ley multinomial de tamaño fijo; tampoco se ha probado aquí que el orden sea ancilar ni que los cocientes de conteos sean insesgados.
]

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4, 9 y 10; sostiene cota estadística.
=== Desigualdad de Cramér-Rao
<dem:ch3-cramer-rao>

#proof-env(name: [completa del @thm:ch3-cramer-rao])[
  Sea $delta(X)$ un estimador insesgado para $g(theta)$, es decir,
  $EE_theta [delta(X)] = g(theta)$ para todo $theta$.

  *Paso 1: Derivada de la esperanza.* Diferenciamos ambos lados de la
  ecuación de insesgadez:
  $ g'(theta) = dif/(dif theta) EE_theta [delta(X)] = dif/(dif theta) integral delta(x) p_theta (x) dif x $
  Bajo condiciones de regularidad que permiten diferenciar bajo el
  signo integral:
  $ g'(theta) = integral delta(x) (partial p_theta (x))/(partial theta) dif x = integral delta(x) (partial log p_theta (x))/(partial theta) p_theta (x) dif x $
  Esto es la covarianza entre $delta(X)$ y el score $S_theta (X) =
  (partial log p_theta (X))/(partial theta)$:
  $ g'(theta) = Cov_theta (delta(X), S_theta (X)) $

  *Paso 2: Aplicación de Cauchy-Schwarz.* Por la desigualdad de
  Cauchy-Schwarz:
  $ [Cov_theta (delta(X), S_theta (X))]^2 lt.eq Var_theta (delta(X)) dot Var_theta (S_theta (X)) $

  *Paso 3: Varianza del score.* La varianza del score es la
  información de Fisher:
  $ Var_theta (S_theta (X)) = EE_theta [((partial log p_theta (X))/(partial theta))^2] = I(theta) $

  *Paso 4: Cota de Cramér-Rao.* Combinando los resultados:
  $ [g'(theta)]^2 lt.eq Var_theta (delta(X)) dot I(theta) $
  Reorganizando:
  $ Var_theta (delta(X)) gt.eq ([g'(theta)]^2)/(I(theta)) $

  *Condiciones de regularidad:* Esta demostración requiere:
  + Diferenciabilidad bajo el signo integral: $(partial)/(partial
    theta) integral delta(x) p_theta (x) dif x = integral delta(x)
    (partial p_theta (x))/(partial theta) dif x$
  + Intercambio de derivada e integral: $integral (partial p_theta
    (x))/(partial theta) dif x = (partial)/(partial theta) integral
    p_theta (x) dif x = 0$
  + Información de Fisher positiva y finita: $0<I(theta) < infinity$
  + Varianza finita del estimador: $Var_theta (delta(X)) < infinity$

  *Caso con sesgo:* Si la media del estimador es $g(theta)+b(theta)$ y ambas funciones son diferenciables, el mismo cálculo reemplaza $g'$ por $g'+b'$. Para $N$ ensayos Bernoulli independientes con $N$ fijo conocido, la proporción tiene varianza $theta(1-theta)/N$ y alcanza la cota en el interior. Con conteos de visitas aleatorios de una cadena, este experimento no está dado: hacen falta la información de la trayectoria y condiciones propias; no se concluye automáticamente que un cociente de conteos sea UMVUE.

]

// CLASIF 2026-09-22: (a) — Teorema citado en caps. 4 y 10; sostiene propiedades asintóticas.
=== Propiedades asintóticas del MLE
<dem:ch3-mle-asintotico>
#dem-alias("dem:ch3-mle-asintotica")
#proof-env(full: [Consistencia y normalidad bajo condiciones explícitas])[
Sea $P_(theta_0)$ la ley verdadera y $M(theta)=EE_(theta_0)[log p_theta(X)]$. Suponga una ley uniforme de grandes números para $n^(-1)ell_n$, un máximo poblacional separado en $theta_0$ y un maximizador aproximado $hat(theta)$ con error $o_P(1)$ en el criterio normalizado. Para cada $epsilon>0$, la separación significa
$ M(theta_0)-sup_(norm(theta-theta_0)>=epsilon)M(theta)>0. $
La convergencia uniforme implica que el máximo muestral no puede estar fuera de ese entorno con probabilidad que no tienda a cero. Así $hat(theta)->^P theta_0$. En un modelo correctamente especificado,
$ M(theta_0)-M(theta)=KL(P_(theta_0)||P_theta)>=0. $
La esperanza siempre se toma bajo la ley verdadera. Identificabilidad da unicidad cuando las esperanzas están definidas, pero la convergencia puntual de verosimilitudes no basta para consistencia.
Para normalidad, suponga $theta_0$ interior, score centrado con segundo momento y matriz $I$ positiva definida, ecuación de score satisfecha por $hat(theta)$, y convergencia uniforme del Hessiano normalizado a $-I$ en un entorno del verdadero parámetro. Taylor en forma integral da
$ 0=n^(-1/2)nabla ell_n(theta_0)+A_n sqrt(n)(hat(theta)-theta_0), $
$ A_n=integral_0^1 n^(-1)nabla^2 ell_n(theta_0+u(hat(theta)-theta_0))dif u ->^P -I. $
El CLT iid del score y Slutsky producen $sqrt(n)(hat(theta)-theta_0)->^d N(0,I^(-1))$. Las condiciones de derivación justifican la identidad de información. En una trayectoria dependiente hay que probar otra ley uniforme y otro CLT; esta demostración iid no los proporciona.
]


== Contrastes e interpretación del error
<sec:dem-ch4>

El paso de una distribución de datos a una decisión de contraste exige controlar el error declarado. Las pruebas siguientes acompañan la discusión de potencia, multiplicidad y aproximaciones del @ch:herramientas.

// CLASIF 2026-09-22: (a) — Lema citado en caps. 4, 9 y 10; sostiene máximo poder.
=== Lema de Neyman–Pearson e inversión de tests
<dem:ch4-neyman-pearson>
#dem-alias("dem:ch4-ump")
#dem-alias("dem:ch4-umpu")
#dem-alias("dem:ch4-inversion")
#dem-alias("dem:ch4-bonferroni")
#dem-alias("dem:ch4-mlr")
#proof-env(name: [del lema de Neyman–Pearson])[
Con densidades $p_0,p_1$ respecto de una medida común, tome $Lambda=p_1/p_0$ donde $p_0>0$, $Lambda=infinity$ donde $p_0=0<p_1$ y una versión arbitraria donde ambas son cero. Elija un cuantil $k>=0$ tal que $P_0(Lambda>k)<=alpha<=P_0(Lambda>=k)$. Aleatorice en la igualdad para obtener tamaño exacto $alpha$. La distribución puede tener átomos; no se exige continuidad ni se usa el teorema del valor intermedio.
La regla $phi^*$ que rechaza para $p_1>k p_0$ satisface, para cualquier test $phi$,
$ (phi^*-phi)(p_1-k p_0)>=0. $
Integrar da $EE_1[phi^*-phi]>=k EE_0[phi^*-phi]>=0$ si $EE_0[phi]<=alpha$. Este argumento incluye el soporte donde $p_0=0$.
Para la inversión, un test no aleatorizado $phi_theta$ de nivel $alpha$ define $C(X)={theta:phi_theta(X)=0}$, y $P_theta(theta in C)=1-EE_theta[phi_theta]>=1-alpha$. El conjunto puede ser disconexo. Con aleatorización se incorpora una variable uniforme auxiliar independiente y se invierten los tests realizados con ella.
Los resultados UMP, UMPU y Bonferroni tienen condiciones y argumentos propios, desarrollados en el @ch:herramientas; el lema simple contra simple no demuestra por sí solo todos esos resultados.
]


=== Procedimiento de Benjamini–Hochberg
<dem:ch4-bh>
#proof-env(full: [Control FDR bajo independencia])[
Sea $R$ el número de rechazos BH y $I_0$ el conjunto de nulas verdaderas. Suponga que cada $p_i$, $i in I_0$, es superuniforme y es independiente de los otros p-valores. Defina $R_i^0$ como el número de rechazos al reemplazar $p_i$ por cero. Entonces $R_i^0>=1$ y depende solo de los otros p-valores. La propiedad step-up da
$ {i " rechazado",R=r}={p_i<=alpha r/m,R_i^0=r}. $
En efecto, reemplazar por cero un p-valor ya rechazado no altera el total, y si el reemplazado permite $r$ rechazos, devolver un valor menor que el umbral $alpha r/m$ conserva ese total. Por independencia,
$ EE[bb(1)_(i " rechazado")/max(R,1)]=sum_(r=1)^m 1/r P(p_i<=alpha r/m)P(R_i^0=r)<=alpha/m. $
Sumar sobre $I_0$ da $"FDR"<=m_0 alpha/m<=alpha$. No se divide por cero. Con nulas uniformes la primera cota es igualdad. La extensión a PRDS sobre las nulas verdaderas requiere otro argumento: véase #cite(<benjamini2001dependency>), no el artículo de independencia de 1995.
]


=== Distribución asintótica del LRT: Wilks
<dem:ch4-wilks>
#proof-env(full: [Esquema para restricciones regulares])[
Considere un modelo paramétrico regular de dimensión $d$, parámetro verdadero interior e información $I$ positiva definida. Bajo la nula $g(theta)=0$, suponga que $g$ es continuamente diferenciable y su Jacobiano tiene rango $r$. Se requieren la expansión cuadrática local uniforme de la log-verosimilitud y consistencia/localización de los máximos libre y restringido. En coordenadas blanqueadas por $I^(1/2)$, el score normalizado converge a $Z tilde N(0,I_d)$ y la nula tiene espacio tangente $L$ de dimensión $d-r$.
Maximizar la forma cuadrática libre y sobre $L$ da
$ 2(ell_n(hat(theta))-ell_n(hat(theta)_0))=norm(Z_n-Pi_L Z_n)^2+o_P(1)->^d chi^2(r). $
La diferencia de los máximos corresponde al complemento ortogonal del tangente nulo, de dimensión $r$, no al propio tangente. Fronteras, singularidades o falta de identificación pueden cambiar el límite. Este resultado es distinto del lema de Neyman–Pearson. Véase #cite(<vaart1998asymptotic>), capítulo 16.
]


== Aproximaciones y remuestreo
<sec:dem-ch5>

Para utilizar una distribución límite hay que seguir la escala del error y el funcional que se estima. El teorema central del límite, el método delta y el remuestreo permiten examinar esas relaciones.

// CLASIF 2026-09-23: (a) — Teorema vivo @thm:ch5-clt/@thm:ch5-clt-ll citado en cap. 9; base CLT.
=== CLT de Lindeberg-Lévy
<dem:ch5-clt-ll>

#proof-env(name: [completa del @thm:ch5-clt-ll])[
  Sea $X_1, X_2, ..., X_n$ variables aleatorias i.i.d. con $EE[X_i] =
  mu$ y $0<Var(X_i) = sigma^2 < infinity$. Definimos $S_n =
  sum_(i=1)^n X_i$ y consideramos la variable estandarizada:
  $ Z_n = (S_n - n mu)/(sigma sqrt(n)) = 1/sqrt(n) sum_(i=1)^n (X_i - mu)/sigma $

  *Paso 1: Función característica.* Sea $phi.alt_X (t)$ la función
  característica de $X_i$. La función característica de $Z_n$ es:
  $ phi.alt_(Z_n)(t) = [phi.alt_X (t/(sigma sqrt(n)))]^n e^(-i t sqrt(n) mu\/sigma) $

  *Paso 2: Expansión de Taylor.* Expandimos $phi.alt_X$ alrededor de
  $0$:
  $ phi.alt_X (s) = 1 + i s EE[X] - s^2/2 EE[X^2] + o(s^2) $
  Para $s = t\/(sigma sqrt(n))$:
  $ phi.alt_X (t/(sigma sqrt(n))) = 1 + i t/(sigma sqrt(n)) mu - t^2/(2 n sigma^2)(mu^2 + sigma^2) + o(t^2/n) $

  *Paso 3: Combinar términos.* Multiplicando por el factor de
  normalización:
  $ phi.alt_X (t/(sigma sqrt(n))) e^(-i t mu\/(sigma sqrt(n))) = 1 - t^2/(2n) + o(t^2/n) $

  *Paso 4: Límite cuando $n -> infinity$.*
  $ phi.alt_(Z_n)(t) = [1 - t^2/(2n) + o(t^2/n)]^n -> e^(-t^2\/2) $
  por el límite $lim_(n->infinity) (1 + a_n\/n)^n = e^a$ cuando $a_n
  -> a$.

  *Paso 5: Conclusión.* La función característica límite $e^(-t^2\/2)$
  corresponde a la distribución normal estándar $cal(N)(0,1)$. Por el
  teorema de continuidad de Lévy, esto implica:
  $ Z_n attach(->, t: d) cal(N)(0,1) $
  o equivalentemente:
  $ (S_n - n mu)/(sigma sqrt(n)) attach(->, t: d) cal(N)(0,1) $

  *Condiciones de regularidad:* Esta demostración requiere:
  + Las variables $X_i$ son i.i.d.
  + $EE[X_i] = mu$ existe (esperanza finita)
  + $0<Var(X_i) = sigma^2 < infinity$ (varianza finita)
  + La función característica $phi.alt_X (t)$ existe y es dos veces
    diferenciable en $0$

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, el CLT permite aproximar la distribución
  del número de pacientes que mejoran su presión arterial en $n$ pacientes independientes con una medición por paciente. Si $X_i$ indica si el paciente $i$ mejoró (1) o no
  (0), entonces $S_n = sum_(i=1)^n X_i$ sigue aproximadamente una
  distribución normal $cal(N)(n mu, n sigma^2)$ para $n$ grande, donde
  $mu$ es la probabilidad de mejora y $sigma^2 = mu(1-mu)$. Esto
  permite construir intervalos de confianza para la efectividad de un
  tratamiento y realizar pruebas de hipótesis sobre si un tratamiento
  es significativamente mejor que otro.
]

// CLASIF 2026-09-23: (a) — @thm:ch5-delta citado en caps. 9–10; propagación de varianza.
=== Método delta
<dem:ch5-delta>

#proof-env(name: [completa del @thm:ch5-delta])[
  Sea $X_1, X_2, ..., X_n$ variables aleatorias i.i.d. con $EE[X_i] =
  mu$ y $0<Var(X_i) = sigma^2 < infinity$. Supongamos que
  $sqrt(n)(macron(X)_n - mu) attach(->, t: d) cal(N)(0, sigma^2)$ por
  el CLT.

  Sea $g: RR -> RR$ una función diferenciable en $mu$ con derivada
  $g'(mu) eq.not 0$. Queremos encontrar la distribución asintótica de
  $g(macron(X)_n)$.

  *Expansión de Taylor de primer orden:* Expandimos $g$ alrededor de
  $mu$:
  $ g(macron(X)_n) = g(mu) + g'(mu)(macron(X)_n - mu) + R_n $
  donde el residuo $R_n$ satisface $R_n = o_P (|macron(X)_n - mu|)$.

  *Reorganización:*
  $ g(macron(X)_n) - g(mu) = g'(mu)(macron(X)_n - mu) + R_n $

  *Multiplicación por $sqrt(n)$:*
  $ sqrt(n)(g(macron(X)_n) - g(mu)) = g'(mu) sqrt(n)(macron(X)_n - mu) + sqrt(n) R_n $

  *Análisis del residuo:* Como $macron(X)_n attach(->, t: P) mu$ por
  la ley de los grandes números, tenemos:
  $ sqrt(n) R_n = sqrt(n) dot o_P (|macron(X)_n - mu|) = o_P (sqrt(n)|macron(X)_n - mu|) = o_P (1) $
  porque $sqrt(n)(macron(X)_n - mu)$ converge en distribución (y por
  tanto es acotado en probabilidad).

  *Aplicación del teorema de Slutsky:* Por el teorema de Slutsky, si
  $A_n attach(->, t: d) A$ y $B_n attach(->, t: P) 0$, entonces $A_n +
  B_n attach(->, t: d) A$. Por tanto:
  $ sqrt(n)(g(macron(X)_n) - g(mu)) attach(->, t: d) g'(mu) dot cal(N)(0, sigma^2) = cal(N)(0, [g'(mu)]^2 sigma^2) $

  *Caso multivariado:* Para $bold(X)_n in RR^k$ con
  $sqrt(n)(macron(bold(X))_n - bold(mu)) attach(->, t: d) cal(N)(bold(0),
  bold(Sigma))$ y $g: RR^k -> RR$ diferenciable en $bold(mu)$ con
  gradiente $nabla g(bold(mu)) eq.not bold(0)$:
  $ sqrt(n)(g(macron(bold(X))_n) - g(bold(mu))) attach(->, t: d) cal(N)(0, nabla g(bold(mu))^top bold(Sigma) nabla g(bold(mu))) $

  *Condiciones de regularidad:* Esta demostración requiere:
  + $sqrt(n)(macron(X)_n - mu)$ converge en distribución a una normal
  + $g$ es diferenciable en $mu$ (o $bold(mu)$ en el caso
    multivariado)
  + $g'(mu) eq.not 0$ (o $nabla g(bold(mu)) eq.not bold(0)$)
  + El residuo de Taylor es $o_P (|macron(X)_n - mu|)$

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, el método delta permite derivar la
  distribución asintótica de transformaciones no lineales de
  estimadores. Por ejemplo, si estimamos la probabilidad de transición
  $hat(theta)_(i j) = N_(i j)\/N_i$, entonces el log-odds
  $log(hat(theta)_(i j)\/(1-hat(theta)_(i j)))$ tiene distribución
  asintótica normal con varianza $[g'(theta_(i j))]^2 dot
  (theta_(i j)(1-theta_(i j)))/N_i$, donde $g(theta) =
  log(theta\/(1-theta))$ y $g'(theta) = 1\/[theta(1-theta)]$. Esto es
  útil para construir intervalos de confianza en la escala de
  log-odds, bajo un experimento binomial de tamaño fijo y parámetro interior. No se deduce una mejora universal de cobertura ni se transfiere la fórmula a visitas dependientes sin otro CLT.
]

// CLASIF 2026-09-23: (b) — proof-env apunta a @thm:ch5-cobertura (sin cita @ viva); auxiliar de bootstrap (familia citada vía @thm:ch5-bootstrap-media).
=== Consistencia del bootstrap para la media
<dem:ch5-bootstrap-consist>
#dem-alias("dem:ch5-bootstrap")
#dem-alias("thm:ch5-bootstrap-consist")
#proof-env(name: [del @thm:ch5-bootstrap-media])[
Suponga datos iid con $0<sigma^2=Var(X)<infinity$. Condicionalmente a la muestra, las variables bootstrap son iid dentro de cada fila, pero su distribución cambia con $n$. Se necesita el CLT de un arreglo triangular condicional. La varianza empírica $s_n^2=n^(-1)sum_i(X_i-overline(X))^2$ converge a $sigma^2$.
La condición de Lindeberg es
$ 1/n sum_i (X_i-overline(X))^2 bb(1)_(abs(X_i-overline(X))>epsilon sqrt(n)) ->^P 0. $
Para comprobarla, use $overline(X)=O_P(1)$ y compare el umbral con $epsilon sqrt(n)/2$. El término de cola de $X_i^2$ tiene esperanza $EE[X^2 bb(1)_(abs(X)>epsilon sqrt(n)/2)]$, que tiende a cero por integrabilidad. El término de centrado también desaparece. El CLT condicional da la convergencia débil en probabilidad a $N(0,sigma^2)$. La continuidad de la distribución límite convierte la convergencia de funciones de distribución en uniforme; combinada con el CLT original, justifica la aproximación bootstrap.
Si $sigma^2=0$, las observaciones son constantes casi seguramente y ambas fluctuaciones son cero. Para studentizar se exige $sigma^2>0$. Varianza finita no proporciona una tasa $O_P(n^(-1/2))$ de la varianza empírica ni refinamientos de cobertura; esos resultados requieren otras hipótesis.
]


== Funciones de influencia y modelos auxiliares
<sec:dem-ch6>

La identidad de centrado y la cota de eficiencia responden a preguntas distintas. Los argumentos semiparamétricos permiten localizar qué papel desempeñan las funciones auxiliares en cada una.

// CLASIF 2026-09-23: (a) — @thm:ch6-doble-robustez/@thm:ch6-dr citado en caps. 9–10.
=== Doble robustez y expansión con cross-fitting
<app:dem-crossfitting>
#dem-alias("dem:ch6-doble-robustez")
#dem-alias("dem:ch6-dml")
#proof-env(name: [de la identidad AIPW y del caso suficiente DML])[
Con la notación del @thm:ch6-dr, condicionar en $X$ da
$ EE[D|X]=overline(m)_1-overline(m)_0+e/overline(e)(m_1-overline(m)_1)-(1-e)/(1-overline(e))(m_0-overline(m)_0). $
Restar $m_1-m_0$ y agrupar produce
$ EE[D]-psi_0=EE[(overline(e)-e)((overline(m)_1-m_1)/overline(e)+(overline(m)_0-m_0)/(1-overline(e)))]. $
Para DML, escriba $D_0=psi_0+phi_"eff"$ y sea $P_k$ la media del fold $k$, de tamaño $n_k$. La descomposición exacta es
$ hat(psi)-psi_0=(P_n-P)D_0+sum_k n_k/n ((P_k-P)(hat(D)_k-D_0)+P(hat(D)_k-D_0)). $
Condicional al entrenamiento del fold, la varianza del término empírico centrado es a lo sumo $norm(hat(D)_k-D_0)_2^2/n_k$. Acotación, positividad y consistencia de auxiliares implican que esa norma es $o_P(1)$. Chebyshev condicional y $K$ fijo dan un término total $o_P(n^(-1/2))$, sin suponer independencia entre folds.
La identidad de sesgo y Cauchy–Schwarz acotan el último término por una constante multiplicada por el producto de errores del @thm:ch6-dml. Es también $o_P(n^(-1/2))$. El CLT iid aplicado a $phi_"eff"$ completa la expansión. La misma convergencia cuadrática de los pseudoresultados, junto con la ley de grandes números, justifica su varianza empírica consistente.
]


=== Función de influencia eficiente para OPE
<dem:ch6-if-ope>
#proof-env(full: [Derivación en el modelo Markov de horizonte finito])[
Usamos exactamente el experimento del @thm:ch6-kallus: episodios iid, $H$ fijo, kernels libres por tiempo y ley inicial desconocida. Defina $epsilon_t=R_t+gamma v_(t+1)(S_(t+1))-q_t(S_t,A_t)$. Entonces
$ phi_"eff"=v_0(S_0)-J+sum_(t=0)^(H-1) gamma^t w_t(S_t,A_t)epsilon_t. $
El score de cualquier submodelo se descompone en un componente inicial, scores de asignación y scores de los kernels de recompensa/transición. Cada componente tiene media condicional cero. Derivar el retorno esperado da, para el componente inicial, el producto interno con $v_0-J$; para el kernel del tiempo $t$, da el producto interno con $gamma^t w_t epsilon_t$, por cambio de la ocupación objetivo a la observada. La derivada respecto de la política de comportamiento es cero. Los términos cruzados se anulan por condicionamiento temporal. Así, $EE[phi_"eff" s]$ representa la derivada para todo score $s$.
Cada sumando pertenece al espacio tangente de su kernel y el inicial al de la ley inicial. La función pertenece al espacio tangente completo y es, por ello, el gradiente canónico. Esta identificación usa la libertad de los kernels por tiempo; imponer homogeneidad cambia el espacio tangente. Véase #cite(<kallus2020double>).
Para el estimador aumentado, si todas las $q_t$ son correctas, los residuos tienen media condicional cero para cualquier peso candidato integrable. Si todos los $w_t$ son correctos, el cambio de medida transforma la esperanza del residuo candidato en
$ EE_pi[R_t+gamma overline(v)_(t+1)(S_(t+1))-overline(v)_t(S_t)]. $
La suma descontada cancela los términos de valor, incluido el inicial, y $overline(v)_H=0$ deja $J$. Esta prueba es poblacional para candidatos fijos; la eficiencia de ajustes estimados exige además controlar sus errores.
]


=== Cota semiparamétrica de varianza
<dem:ch6-bkrw>
#dem-alias("dem:ch6-cota")
#dem-alias("dem:ch6-if-eficiente")
#proof-env(name: [del @thm:ch6-cota])[
Sea $cal(T)$ el espacio tangente cerrado en $L_0^2(P)$. Toda IF $phi$ de un estimador regular asintóticamente lineal representa las mismas derivadas: $EE[phi s]=dot(psi)(s)$ para cada score $s$. El gradiente canónico $phi_"eff"$ satisface esas identidades y pertenece a $cal(T)$. Por densidad, $h=phi-phi_"eff"$ es ortogonal a $cal(T)$. Por Pitágoras,
$ EE[phi^2]=EE[phi_"eff"^2]+EE[h^2]>=EE[phi_"eff"^2]. $
Hay igualdad si y solo si $h=0$ en $L^2(P)$. El argumento establece una cota; construir un estimador que la alcance requiere una expansión con resto despreciable.
]


== Decisión de Wald
<sec:dem-ch7>

Los criterios del @ch:wald comparan riesgos dentro de una clase de reglas. Las demostraciones de esta sección se refieren al modelo y al criterio que declara cada resultado.

// CLASIF 2026-09-23: (a) — @thm:ch7-existencia-bayes/@thm:ch7-bayes citado en caps. 2 y 10.
=== Identidad de riesgo de James–Stein
<dem:ch2-james-stein>

#proof-env(name: [de la identidad de riesgo de James–Stein])[
  Escriba $delta_("JS")(x)=x+g(x)$, donde
  $g(x)=-(p-2)x/norm(x)^2$ para $x != 0$. Para $X tilde N_p(theta,I_p)$,
  la identidad de Stein para el riesgo cuadrático da
  $ R(theta,delta_("JS"))=p+EE_theta[norm(g(X))^2+2 div g(X)]. $
  Para $x != 0$,
  $norm(g(x))^2=(p-2)^2/norm(x)^2$ y
  $div g(x)=-(p-2)(p-2)/norm(x)^2$,
  pues $div(x/norm(x)^2)=(p-2)/norm(x)^2$. Por tanto,
  $ R(theta,delta_("JS"))=p-(p-2)^2 EE_theta[1/norm(X)^2]. $
  La esperanza es finita para $p>=3$. Como el término que se resta es
  positivo, el riesgo es estrictamente menor que el riesgo $p$ de
  $delta_0(X)=X$.
]

=== Existencia de reglas de Bayes con acciones finitas
<dem:ch7-existencia-bayes>
#proof-env(name: [del @thm:ch7-existencia-bayes])[
Bajo las condiciones del capítulo, cada pérdida posterior $ell_nu(x,a)$ es medible y finita. Enumere las acciones y elija el primer índice que alcanza el mínimo. Su región de selección es una intersección finita de comparaciones entre funciones medibles, así que la regla es medible.
La esperanza iterada escribe el riesgo de cualquier regla aleatorizada como la esperanza de una combinación convexa de pérdidas posteriores. Cada combinación es mayor o igual que $min_a ell_nu(X,a)$. La regla construida alcanza esa cota. Si otra regla alcanza el mismo riesgo, la diferencia no negativa tiene esperanza cero y debe anularse casi seguramente, por lo que solo asigna masa a minimizadores salvo conjuntos predictivamente nulos.
Para acciones compactas o no compactas se requieren hipótesis adicionales de existencia y selección medible. Continuidad puntual de la pérdida no justifica por sí sola intercambiar límite e integral ni seleccionar un argmin medible. Aquí no se afirma esa extensión.
]


=== Conexión Bayes-Minimax
<dem:ch7-bayes-minimax>

#proof-env(name: [completa del @thm:ch7-bayes-minimax])[
  Sea $cal(D) = (ParamSpace, ActionSpace, SampleSpace, Loss)$ un
  problema de decisión. El riesgo minimax es:
  $ inf_decrule sup_(theta in ParamSpace) Risk(theta, decrule) $
  y el riesgo Bayesiano bajo un a priori $pi$ es:
  $ r(pi, decrule) = integral_(ParamSpace) Risk(theta, decrule) dif pi(theta) $

  *Teorema de conexión Bayes-Minimax:* Si existe una regla de Bayes
  $decrule^pi$ bajo algún a priori $pi$ tal que su riesgo es
  constante, es decir, $Risk(theta, decrule^pi) = c$ para todo $theta
  in ParamSpace$, entonces $decrule^pi$ es una regla minimax.

  *Demostración:*

  *Paso 1: Riesgo minimax $lt.eq$ riesgo constante.*
  $ inf_decrule sup_theta Risk(theta, decrule) lt.eq sup_theta Risk(theta, decrule^pi) = c $

  *Paso 2: Riesgo Bayesiano $lt.eq$ riesgo minimax.* Para cualquier
  regla $decrule$:
  $ r(pi, decrule) = integral Risk(theta, decrule) dif pi(theta) lt.eq integral sup_(theta') Risk(theta', decrule) dif pi(theta) = sup_(theta') Risk(theta', decrule) $
  Tomando el mínimo sobre todas las reglas:
  $ inf_decrule r(pi, decrule) lt.eq inf_decrule sup_(theta') Risk(theta', decrule) $

  *Paso 3: Riesgo Bayesiano de $decrule^pi$.* Como $decrule^pi$ es una
  regla de Bayes:
  $ r(pi, decrule^pi) = inf_decrule r(pi, decrule) $

  *Paso 4: Igualdad de riesgos.* Como $Risk(theta, decrule^pi) = c$
  para todo $theta$:
  $ r(pi, decrule^pi) = integral Risk(theta, decrule^pi) dif pi(theta) = integral c dif pi(theta) = c $

  *Paso 5: Conclusión.* Combinando los resultados:
  $ c = r(pi, decrule^pi) = inf_decrule r(pi, decrule) lt.eq inf_decrule sup_(theta') Risk(theta', decrule) lt.eq c $
  Por tanto:
  $ inf_decrule sup_(theta') Risk(theta', decrule) = c = sup_theta Risk(theta, decrule^pi) $
  Lo que significa que $decrule^pi$ es una regla minimax.

  *Condiciones de regularidad:* Esta demostración requiere:
  + Existe un a priori $pi$ con soporte en $ParamSpace$
  + Existe una regla de Bayes $decrule^pi$ bajo $pi$
  + El riesgo $Risk(theta, decrule^pi)$ es constante en $theta$
  + Los riesgos están bien definidos y las integrales convergen

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, este teorema permite encontrar políticas
  de tratamiento minimax (que minimizan el peor caso) buscando
  políticas Bayesianas con riesgo constante. Por ejemplo, si
  construimos un a priori $pi$ sobre la distribución de presión
  arterial y encontramos una política $decrule^pi$ que tiene el mismo
  riesgo clínico para todos los posibles valores verdaderos de la
  presión arterial, entonces esta política es minimax. Esto es
  una optimalidad relativa a la pérdida, la familia de modelos y la clase de reglas. No impone por sí sola un umbral aceptable de daño ni garantiza seguridad clínica: el menor de los peores riesgos disponibles todavía puede ser elevado.
]

// CLASIF 2026-09-23: (a) — @thm:ch7-clase-completa/@thm:ch7-complete-class citado en caps. 2 y 10.
=== Clase esencialmente completa en el problema finito
<dem:ch7-clase-completa>
#proof-env(name: [del @thm:ch7-clase-completa])[
Con parámetros, datos y acciones finitos, las reglas aleatorizadas forman un producto finito de simplex compactos. El mapa que envía una regla a su vector de riesgos es lineal y continuo. Su imagen $C subset RR^d$ es por tanto compacta y convexa.
Sea $r in C$ un riesgo admisible. El conjunto convexo abierto $U={u:u_j<r_j " para todo " j}$ es disjunto de $C$. Separación convexa proporciona $w!=0$ y $w^T c>=w^T u$ para todo $c in C,u in U$. Como $U$ es ilimitado hacia abajo en cada coordenada, necesariamente $w_j>=0$. Tomando $u$ hacia $r$ se obtiene $w^T c>=w^T r$. Normalizar por $sum_j w_j>0$ produce un prior para el que $r$ minimiza el riesgo de Bayes.
Para cualquier $r_0 in C$, minimice $sum_j r_j$ sobre el compacto no vacío $C inter {r:r<=r_0}$. Un minimizador $r_*$ no puede ser dominado: una mejora estricta en alguna coordenada disminuiría la suma sin salir del conjunto. Es admisible y, por el párrafo anterior, Bayes; además $r_*<=r_0$. Esto demuestra la completitud esencial. El prior obtenido puede tener ceros. Mejor riesgo promedio bajo un prior no implica dominancia coordenada a coordenada; la prueba usa separación y compactitud, no esa implicación falsa.
]


== Programación dinámica
<sec:dem-ch8>

La contracción permite pasar de las ecuaciones de Bellman a un procedimiento de cálculo. Los argumentos de esta sección acompañan la planificación con modelo conocido del @ch:mdp-bellman.

// CLASIF 2026-09-23: (b) — dem de @thm:ch8-bellman-exp (alias de nota informal); sin cita @ viva; el formal vivo es @thm:ch8-bellman-pi.
=== Ecuación de Bellman de expectación
<dem:ch8-bellman-exp>
#dem-alias("dem:ch8-bellman-opt")

#proof-env(name: [completa del @thm:ch8-bellman-exp])[
  Sea $policy$ una política estacionaria y $G_t = sum_(k=0)^infinity
  discount^k R_(t+k)$ el retorno desde el tiempo $t$.

  *Paso 1: Definición de la función de valor.*
  $ Value^policy (s) = EE^policy [G_t | S_t = s] $

  *Paso 2: Descomposición del retorno.*
  $ G_t = R_t + discount R_(t+1) + discount^2 R_(t+2) + dots.c = R_t + discount G_(t+1) $

  *Paso 3: Aplicación de la ley de esperanzas iteradas.*
  $
    Value^policy (s)
    &= EE^policy [G_t | S_t = s] \
    &= EE^policy [R_t + discount G_(t+1) | S_t = s] \
    &= EE^policy [R_t | S_t = s] + discount EE^policy [G_(t+1) | S_t = s]
  $

  *Paso 4: Condicional sobre la acción.* Por la ley de la probabilidad
  total:
  $ EE^policy [R_t | S_t = s] = sum_(a in ActionSpace) policy(a|s) EE^policy [R_t | S_t = s, A_t = a] $
  Por la propiedad de Markov, $EE^policy [R_t | S_t = s, A_t = a] =
  r(s,a)$, por lo que:
  $ EE^policy [R_t | S_t = s] = sum_(a in ActionSpace) policy(a|s) r(s,a) $

  *Paso 5: Condicional sobre el siguiente estado.*
  $
    EE^policy [G_(t+1) | S_t = s]
    &= EE^policy [EE^policy [G_(t+1) | S_(t+1)] mid(|) S_t = s] \
    &= EE^policy [Value^policy (S_(t+1)) mid(|) S_t = s]
  $
  Condicional sobre la acción:
  $
    EE^policy [Value^policy (S_(t+1)) | S_t = s]
    &= sum_(a in ActionSpace) policy(a|s) EE^policy [Value^policy (S_(t+1)) | S_t = s, A_t = a] \
    &= sum_(a in ActionSpace) policy(a|s) sum_(s' in StateSpace) P(s'|s,a) Value^policy (s')
  $

  *Paso 6: Combinación de resultados.*
  $
    Value^policy (s)
    &= sum_(a in ActionSpace) policy(a|s) r(s,a) + discount sum_(a in ActionSpace) policy(a|s) sum_(s' in StateSpace) P(s'|s,a) Value^policy (s') \
    &= sum_(a in ActionSpace) policy(a|s) [ r(s,a) + discount sum_(s' in StateSpace) P(s'|s,a) Value^policy (s') ]
  $

  *Condiciones de regularidad:* Esta demostración requiere:
  + Espacio de estados $StateSpace$ finito o numerable
  + Espacio de acciones $ActionSpace$ finito
  + Factor de descuento $discount in [0,1)$
  + Recompensas acotadas: $|r(s,a)| lt.eq R_max$ para todo $(s,a)$
  + Kernel de transición válido: $P(s'|s,a) gt.eq 0$, $sum_(s')
    P(s'|s,a) = 1$
  + Propiedad de Markov: $P(S_(t+1), R_t | S_t, A_t, H_(t-1)) =
    P(S_(t+1), R_t | S_t, A_t)$

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, la ecuación de Bellman de expectación
  permite calcular el valor esperado a largo plazo de seguir una
  política de tratamiento $pi$ desde un estado de salud $s$. Por
  ejemplo, si $s$ representa "presión arterial alta", entonces
  $Value^policy (s)$ es el beneficio esperado acumulado de seguir la
  política $pi$ a partir de ese estado. La ecuación descompone este
  valor en el beneficio inmediato de la acción elegida $r(s,a)$ más el
  beneficio descontado esperado del siguiente estado de salud
  $discount sum_(s') P(s'|s,a) Value^policy (s')$. Esta recursión es
  fundamental para algoritmos como Policy Iteration y Value Iteration
  que encuentran políticas óptimas en la práctica clínica.
]

// CLASIF 2026-09-23: (a) — @thm:ch8-contraccion citado en caps. 3 y 10.
=== Contracción del operador de Bellman
<dem:ch8-contraccion>

#proof-env(name: [completa del @thm:ch8-contraccion])[
  Sea $BellmanOp: cal(V) -> cal(V)$ el operador de Bellman definido
  como:
  $ (BellmanOp V)(s) = max_(a in ActionSpace) { r(s,a) + discount sum_(s' in StateSpace) P(s'|s,a) V(s') } $
  donde $cal(V)$ es el espacio de funciones acotadas $V: StateSpace ->
  RR$ con la norma $ell_infinity$:
  $ norm(V)_infinity = sup_(s in StateSpace) |V(s)| $

  *Demostración de contracción:* Para cualesquiera funciones $V, W in
  cal(V)$, consideramos:
  $ norm(BellmanOp V - BellmanOp W)_infinity = sup_(s in StateSpace) |(BellmanOp V)(s) - (BellmanOp W)(s)| $
  Para un estado $s$ fijo, sea $a^*$ la acción que maximiza $(BellmanOp
  V)(s)$. Entonces:
  $
    (BellmanOp V)(s) - (BellmanOp W)(s)
    &lt.eq [ r(s,a^*) + discount sum_(s') P(s'|s,a^*) V(s') ]
       - [ r(s,a^*) + discount sum_(s') P(s'|s,a^*) W(s') ] \
    &= discount sum_(s') P(s'|s,a^*) (V(s') - W(s'))
  $
  Repitiendo la desigualdad con $V$ y $W$ intercambiados se acotan ambos signos. Usando que $P(s'|s,a^*) gt.eq 0$ y
  $sum_(s') P(s'|s,a^*) = 1$:
  $
    |(BellmanOp V)(s) - (BellmanOp W)(s)| <= discount norm(V-W)_infinity
  $
  Como esto vale para todo $s$, tenemos:
  $ norm(BellmanOp V - BellmanOp W)_infinity lt.eq discount norm(V - W)_infinity $
  Por tanto, $BellmanOp$ es una contracción con factor $discount in
  [0,1)$.

  *Condiciones de regularidad:* Esta demostración requiere:
  + Espacio de estados $StateSpace$ finito o numerable
  + Espacio de acciones $ActionSpace$ finito
  + Factor de descuento $discount in [0,1)$
  + Recompensas acotadas: $|r(s,a)| lt.eq R_max$ para todo $(s,a)$
  + Kernel de transición válido: $P(s'|s,a) gt.eq 0$, $sum_(s')
    P(s'|s,a) = 1$

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, esta propiedad de contracción garantiza
  que el algoritmo de Value Iteration converge a la función de valor
  óptima $V^*$ independientemente de la inicialización. Con un factor
  de descuento $gamma = 0.95$ (típico en decisiones médicas a largo
  plazo), el error se reduce geométricamente en cada iteración, lo que
  permite obtener políticas de tratamiento óptimas en tiempo
  computacional razonable. La contracción asegura unicidad del valor óptimo; distintas políticas pueden alcanzarlo cuando hay empates.
]

// CLASIF 2026-09-23: (a) — @thm:ch8-existencia alias de @thm:ch8-bellman-opt citado en caps. 3 y 10.
=== Existencia y unicidad de $V^*$
<dem:ch8-existencia>

#proof-env(name: [completa del @thm:ch8-existencia])[
  Sea $cal(V)$ el espacio de funciones acotadas $V: StateSpace -> RR$
  con la norma $ell_infinity$:
  $ norm(V)_infinity = sup_(s in StateSpace) |V(s)| $

  *Paso 1: $cal(V)$ es un espacio métrico completo.* El espacio
  $(cal(V), norm(dot)_infinity)$ es completo porque toda sucesión de
  Cauchy de funciones acotadas converge uniformemente a una función
  acotada.

  *Paso 2: $BellmanOp$ es una contracción.* Por el
  @thm:ch8-contraccion, el operador de Bellman satisface:
  $ norm(BellmanOp V - BellmanOp W)_infinity lt.eq discount norm(V - W)_infinity $
  para todo $V, W in cal(V)$, donde $discount in [0,1)$.

  *Paso 3: Aplicación del teorema del punto fijo de Banach.* Por el
  teorema del punto fijo de Banach, toda contracción en un espacio
  métrico completo tiene un único punto fijo. Por tanto, existe una
  única función $V^* in cal(V)$ tal que:
  $ V^* = BellmanOp V^* $

  *Paso 4: Interpretación.* Esta función $V^*$ es la función de valor
  óptima:
  $ V^*(s) = max_policy Value^policy (s) $
  para todo $s in StateSpace$.

  Para justificar la optimalidad, para cada política estacionaria $pi$ se tiene $T^pi V^*<=T^*V^*=V^*$. Monotonía e iteración de $T^pi$ dan $V^pi<=V^*$. Una política determinista greedy alcanza igualdad, pues su operador tiene el mismo punto fijo. Para una política que depende de la historia, la desigualdad de Bellman vale condicionalmente antes de cada acción. Iterándola durante $h$ decisiones se obtiene
  $ EE_pi[sum_(t=0)^(h-1)gamma^t R_t+gamma^h V^*(S_h)|S_0=s]<=V^*(s). $
  Como $V^*$ es acotada y $gamma<1$, el término final desaparece al hacer $h$ crecer. Bajo integrabilidad del retorno, esto prueba $V^pi(s)<=V^*(s)$ también para políticas históricas.

  *Paso 5: Convergencia de Value Iteration.* Además, el teorema de
  Banach garantiza que para cualquier función inicial $V_0 in cal(V)$,
  la sucesión $V_(n+1) = BellmanOp V_n$ converge a $V^*$ con tasa
  geométrica:
  $ norm(V_n - V^*)_infinity lt.eq discount^n norm(V_0 - V^*)_infinity $

  *Condiciones de regularidad:* Esta demostración requiere:
  + Espacio de estados $StateSpace$ finito o numerable
  + Espacio de acciones $ActionSpace$ finito
  + Factor de descuento $discount in [0,1)$
  + Recompensas acotadas: $|r(s,a)| lt.eq R_max$ para todo $(s,a)$
  + Kernel de transición válido: $P(s'|s,a) gt.eq 0$, $sum_(s')
    P(s'|s,a) = 1$

  *Aplicación al contexto MDP (SSCH):* En el Sistema de Soporte
  Clínico para Hipertensión, este teorema garantiza que existe una
  única función de valor óptima $V^*$ que representa el beneficio
  esperado a largo plazo de seguir la política de tratamiento óptima
  desde cada estado de salud. La unicidad concierne al valor. Una política greedy respecto del punto fijo lo alcanza, pues su operador tiene ese mismo punto fijo. Pueden existir varias políticas óptimas. La cota geométrica determina el número de iteraciones a partir de la tolerancia y del error inicial; no establece un número universal de iteraciones.
]

=== Cota residual para una política greedy
<dem:ch8-parada>

#proof-env(name: [del certificado residual de pérdida de política])[
  Sea $T^*$ el operador óptimo, sea $T^pi$ el operador de una política
  $pi$ y suponga que $pi_V$ es greedy respecto de $V$, de modo que
  $T^(pi_V)V=T^*V$. Escriba
  $delta=norm(V-V^*)_infinity$ y
  $d=norm(V^(pi_V)-V^*)_infinity$. Por las ecuaciones de punto fijo,
  la igualdad de greedy y la contracción de ambos operadores,
  $
    d
    &= norm(T^*V^*-T^(pi_V)V^(pi_V))_infinity \\
    &<= gamma delta + gamma norm(V-V^(pi_V))_infinity \\
    &<= gamma delta + gamma(delta+d).
  $
  Luego $(1-gamma)d<=2 gamma delta$, así que
  $d<=2 gamma delta/(1-gamma)$.

  Si $e=norm(T^*V-V)_infinity$, la contracción de $T^*$ también da
  $delta<=e+gamma delta$, y por tanto $delta<=e/(1-gamma)$. Al
  combinar las cotas,
  $ norm(V^(pi_V)-V^*)_infinity <= 2 gamma e/(1-gamma)^2. $
  Estas desigualdades requieren $gamma in [0,1)$ y una política greedy
  bien definida; la cota de política es cero cuando $gamma=0$.
]

== Representación entre decisiones y políticas
<sec:dem-ch9>

Las correspondencias se leen con el alcance de la representación del @ch:isomorfismo. Es importante conservar qué información utiliza la regla, qué distribución se promedia y dentro de qué clase se comparan los riesgos.

// CLASIF 2026-09-24: (a) — @thm:ch9-isomorfismo citado en caps. 2, 5, 10, 12; sostiene incrustación fiel.
=== Representación que preserva el riesgo
<dem:ch9-isomorfismo>
#proof-env(name: [del @thm:ch9-isomorfismo])[
Para cada $theta$, el estado inicial es $X tilde P_theta$, la recompensa de la única decisión es $r_theta(x,a)=-L(theta,a)$ y la transición lleva a un estado terminal de recompensa cero. La política $pi_delta(x)=delta(x)$ usa la observación, no el parámetro desconocido. Entonces
$ J_theta(pi_delta)=sum_x P_theta(x)r_theta(x,delta(x))=-sum_x P_theta(x)L(theta,delta(x))=-R(theta,delta). $
La correspondencia es biyectiva entre las funciones de decisión y las políticas en los estados de decisión. Las acciones en el estado terminal se identifican por ser irrelevantes. La acotación de la pérdida asegura integrabilidad. No se afirma una equivalencia entre todos los problemas secuenciales y los experimentos de Wald.
]


=== Bayes, minimax y admisibilidad
<dem:ch9-transferencia-bayes>
#dem-alias("dem:ch9-transferencia-admis")
#proof-env[
Integrar la identidad anterior con un prior $nu$ da $J_nu(pi_delta)=-rho_nu(delta)$. Por tanto una regla minimiza el riesgo de Bayes si y solo si su política maximiza ese retorno. Además
$ inf_delta sup_theta R(theta,delta)=-sup_pi inf_theta J_theta(pi). $
Estas son igualdades de valores y correspondencias entre optimizadores cuando existen; no prueban su existencia ni intercambian $inf$ y $sup$. Finalmente, una regla que domina a otra tiene riesgo menor o igual en todo $theta$, con desigualdad estricta en alguno, exactamente cuando su política tiene mayor o igual retorno en todo $theta$, con desigualdad estricta en alguno. Esto prueba la correspondencia de admisibilidad. Todas las comparaciones usan la misma clase: si se permiten reglas aleatorizadas, también deben permitirse las políticas correspondientes.
]


=== Suficiencia estadística y estado predictivo
<dem:ch9-suficiencia-markov>
#proof-env(full: [Contraejemplo y condición que sí basta])[
Sea $X_1,X_2$ iid Bernoulli$(theta)$, con $0<theta<1$. El proceso es Markov, pero el estado actual $X_2$ no es suficiente para $theta$ en la muestra $(X_1,X_2)$: $P_theta(X_1=1|X_2)=theta$. Por tanto la propiedad de Markov no implica suficiencia estadística.
Para un resumen $Z_t=f_t(H_t)$, la condición pertinente para control es que la ley de $(R_t,Z_(t+1))$ dado $(H_t,A_t)$ dependa solo de $(Z_t,A_t)$, para todas las acciones admisibles. Junto con actualización medible y criterio de recompensa compatible, esta condición permite programación dinámica en $Z_t$. La suficiencia para un parámetro estático no establece esa propiedad de transición. En el problema bayesiano del @thm:ch9-secuencial, el posterior y el horizonte restante sí la satisfacen: la distribución predictiva y la actualización posterior se calculan a partir de ellos. Para $k=0$ solo se decide y el mínimo es $min_a ell(b,a)$. Supuesta la fórmula para $k-1$, cualquier estrategia con $k$ observaciones disponibles debe parar, con costo mínimo $min_a ell(b,a)$, u observar, con costo mínimo $c+sum_y m_b(y)W_(k-1)(B(b,y))$. La hipótesis inductiva permite alcanzar cada valor de continuación. Tomar el menor de ambas alternativas prueba la fórmula y construye una estrategia óptima; la finitud asegura mínimos y desempates medibles.
]


== Evaluación fuera de política
<sec:dem-ch10>

El cambio de medida y la corrección residual permiten relacionar el valor objetivo con la ley observada. Sus argumentos deben interpretarse junto con el modelo de trayectorias y el horizonte del @ch:ope.

// CLASIF 2026-09-24: (a) — @thm:ch10-is-insesgado citado en cap. 7; sostiene IS.
=== Insesgadez del IS
<dem:ch10-is-insesgado>
#proof-env(name: [del @thm:ch10-is-insesgado])[
En un episodio de $H$ decisiones, suponga que las leyes iniciales y los kernels del entorno coinciden y que el soporte objetivo está cubierto por comportamiento. Factorizar las densidades de la trayectoria cancela los factores del entorno y deja
$ dif P_pi/dif P_b=W_(H-1)=product_(t=0)^(H-1)pi_t(A_t|H_t)/b_t(A_t|H_t). $
Si $EE_pi[|G|]<infinity$, entonces $EE_b[W G]=EE_pi[G]=J(pi)$. La media de $n$ episodios tiene esa misma esperanza. La independencia y el segundo momento finito permiten además $Var(hat(J))=Var_b(W G)/n$, pero no se necesitan para la identidad de esperanza.
Aplicar el mismo cambio de medida a la historia hasta $R_t$ da $EE_b[W_t R_t]=EE_pi[R_t]$. Así se justifica PDIS, sin condicionar productos futuros en una historia que omita la recompensa y el siguiente estado. Se usan las propensiones verdaderas; sustituirlas por ajustes no preserva automáticamente insesgadez finita. Una interpretación causal requiere además identificación del mecanismo de intervención.
]


=== Varianza de importancia y horizonte
<dem:ch10-curse>
#proof-env(name: [del ejemplo y la cota del @thm:ch10-curse])[
Sea $W$ el peso acumulado de $H$ decisiones, con razones por acción acotadas por $C$ y $|G|<=B_H$. Por cambio de medida $EE_b[W]=1$, y $0<=W<=C^H$. Para episodios iid,
$ Var(hat(J)_"IS")<=EE_b[W^2G^2]/n<=B_H^2 C^H/n. $
Esta es una cota superior. La sola acotación no permite una cota inferior positiva: si todas las recompensas son cero, la varianza es cero.
Para mostrar que el crecimiento exponencial es posible, tome acciones independientes Bernoulli$(b)$ bajo comportamiento y Bernoulli$(p)$ bajo objetivo, con $0<b<1$, $p!=b$, y retorno terminal constante $G=1$ (descuento uno). La razón de un paso tiene segundo momento
$ c=p^2/b+(1-p)^2/(1-b)=1+(p-b)^2/(b(1-b))>1. $
La independencia da $EE_b[W^2]=c^H$ y, exactamente,
$ Var(hat(J)_"IS")=(c^H-1)/n. $
Se trata de un ejemplo de dificultad para IS, no de una imposibilidad universal para todos los estimadores.
]


=== Doble robustez del DR
<dem:ch10-dr>
#proof-env(name: [de la identidad de una decisión y su extensión])[
Sea $m(s,a)=EE[R|S=s,A=a]$, $S tilde nu$, y sea $pi$ fija. Para candidatos fijos $overline(m),overline(b)$ con denominadores positivos en el soporte objetivo, defina
$ overline(v)(s)=sum_a pi(a|s)overline(m)(s,a), quad D=overline(v)(S)+pi(A|S)/overline(b)(A|S)(R-overline(m)(S,A)). $
Condicionar en $S,A$ y restar $J=EE_nu[sum_a pi(a|S)m(S,a)]$ da
$ EE_b[D]-J=EE_nu[sum_a pi(a|S)(overline(b)(a|S)-b(a|S))/overline(b)(a|S)(overline(m)(S,a)-m(S,a))]. $
El sesgo se anula si $overline(b)=b$ o $overline(m)=m$. El término directo debe ser $overline(v)(S)$; usar $overline(m)(S,A)$ promedia bajo la política observada y no produce esta identidad.
En horizonte finito use $overline(v)_0+sum_t gamma^t overline(W)_t(R_t+gamma overline(v)_(t+1)-overline(q)_t)$, con pesos acumulados y $overline(v)_H=0$. Si todas las $q_t$ son correctas, cada residuo tiene media cero condicional a la historia y acción. Si todos los pesos son correctos, el cambio de medida y la cancelación telescópica dejan $J$. No basta con acertar un solo tiempo del horizonte. Para modelos aprendidos, el centrado condicional requiere entrenamiento externo; la inferencia añade condiciones de tasas y momentos.
]


=== Eficiencia del DR de una decisión
<dem:ch10-dr-eficiencia>
#proof-env(full: [Expansión bajo condiciones suficientes])[
Para episodios iid de una decisión, ley inicial desconocida, política objetivo fija y modelo observado no paramétrico, la IF eficiente es
$ phi(O)=v(S)-J+pi(A|S)/b(A|S)(R-m(S,A)). $
Suponga acciones finitas, recompensas y regresiones ajustadas acotadas, propensiones verdaderas y ajustadas mayores que $c>0$ en el soporte objetivo, y cross-fitting con un número fijo de folds. Si ambos auxiliares convergen en $L^2$ y su producto de errores es $o_P(n^(-1/2))$, la identidad anterior y Cauchy–Schwarz controlan el sesgo. El argumento condicional de @app:dem-crossfitting controla la fluctuación empírica. Luego
$ hat(J)-J=1/n sum_i phi(O_i)+o_P(n^(-1/2)). $
Si $0<EE[phi^2]<infinity$, el CLT y la varianza empírica consistente dan inferencia eficiente. Una tasa $O_P(n^(-1/2))$ de un auxiliar no convierte por sí sola cualquier resto en $o_P(n^(-1/2))$. Para episodios de varios tiempos la IF y las tasas se verifican en el modelo longitudinal correspondiente.
]


== Inferencia para funciones de valor
<sec:dem-ch11>

El @ch:inferencia distingue la aproximación de Bellman mediante bases de la ruta semiparamétrica. Las fuentes y los alcances se indican junto a cada argumento para conservar esa distinción.

// Fix L2 (Entrega 7.B.ii): A.11.1 estaba vacío (solo TODO). Completado con
// el esquema de demostración del Teorema 1 de SZLS (corregido en Entrega
// 5), citando explícitamente que la prueba detallada está en el paper
// original.
// CLASIF 2026-09-24: (a) — @thm:ch11-shi citado en caps. 8, 10, 12; sostiene asintótica SZLS.
=== Inferencia de Shi, Zhang, Lu y Song para política fija
<dem:ch11-shi>
#proof-env(full: [Esquema, sujeto a las condiciones del artículo])[
El @thm:ch11-shi usa la aproximación de Bellman por bases y la studentización del artículo #cite(<shi2022statistical>). La ecuación muestral se linealiza alrededor de la aproximación poblacional. El error se separa en una suma de residuos de Bellman premultiplicados por la inversa de la matriz de momentos y un resto de aproximación y estimación. Las hipótesis de diseño, momentos, dependencia, invertibilidad y crecimiento de la base controlan ese resto en relación con el error estándar. El CLT pertinente y la consistencia de la varianza producen
$ sqrt(n T)(hat(J)-J)/hat(sigma) limits(->)^d N(0,1). $
Este es un esquema de lectura, no una demostración completa: se requieren todas las condiciones del teorema y su suplemento. El término lineal de este estimador no se identifica automáticamente con un gradiente semiparamétrico eficiente. Tampoco se reemplaza su estimador de varianza por uno HAC arbitrario sin justificar otra expansión. Para una política aprendida, SAVE añade una organización secuencial y condiciones propias; el resultado de política fija no basta.
]


=== Eficiencia de Kallus–Uehara
<dem:ch11-kallus>
#proof-env(full: [Alcance del argumento de eficiencia])[
En el experimento finito con episodios iid del @thm:ch6-kallus, la IF se obtiene como en #verdem(<dem:ch6-if-ope>). Para que un estimador DRL alcance su varianza se necesita que su expansión tenga esa IF y resto despreciable. #cite(<kallus2020double>) establece condiciones para ajustes cruzados de funciones de valor y razones marginales. El modelo temporalmente homogéneo de horizonte infinito de #cite(<kallus2022efficiently>) admite otro experimento y otra cota; sus condiciones no se sustituyen por las del caso finito. Aquí no se reproduce la prueba técnica completa de ninguno de los dos artículos.
]
