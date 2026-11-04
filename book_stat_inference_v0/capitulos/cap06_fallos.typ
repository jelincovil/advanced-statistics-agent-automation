#import "../plantilla.typ": *

// Revisión integral: se conservan los encabezados, su orden y las claves
// públicas del original. «Isomorfismo» se interpreta con el alcance del cap. 5.

= Lo que no se transfiere
<ch:fallos>

Una identidad entre riesgo y retorno permite trasladar un criterio de
comparación, pero no produce nuevos datos ni justifica por sí sola un
intervalo de confianza. La representación del @ch:isomorfismo conserva
$J_theta (pi_delta)=-R(theta,delta)$ en una familia de MDP de un paso.
El parámetro sigue siendo desconocido y la regla no puede consultarlo.
Este capítulo estudia qué cambia al pasar a decisiones repetidas, estados
resumidos y evaluación con datos de otra política.

El hilo conductor es SSCH: observar señales, elegir una acción y evaluar
sus consecuencias. Los ejemplos numéricos son sintéticos; las recompensas
no constituyen recomendaciones clínicas. Cada ejemplo distingue el objeto
que deja de estar justificado —representación, identificación, estimación
o decisión— y la información adicional que permitiría continuar.

== Qué cambia al ampliar el problema

=== Límites del Isomorfismo: Contraejemplos
<sec:ch9-contraejemplos>

Un supuesto fuera del alcance de un teorema no es un contraejemplo a ese
teorema. Los casos siguientes delimitan extensiones posibles y exhiben
fallos de afirmaciones más amplias. En particular, ni los estados continuos
ni las variables latentes contradicen la teoría de decisión de Wald.

#thm-env("example", name: [Espacio de Estados Infinito], key: "ex:ch9-estados-infinitos")[
  Considérese $S_(t+1)=S_t+A_t+epsilon.alt_t$, con acciones en $\{-1,1\}$,
  innovaciones independientes $N(0,1)$ y recompensa $-S_t^2$.
  El estado continuo queda fuera de la construcción discreta demostrada
  en el @ch:isomorfismo, pero no impide definir un MDP medible.

  De hecho, para $S_0=s$ y cualquier política no anticipativa,
  $ EE[S_t^2] <= 3s^2+3t^2+3t. $
  Basta escribir $S_t=s+sum_(j<t)A_j+sum_(j<t)epsilon.alt_j$ y usar
  $(x+y+z)^2<=3(x^2+y^2+z^2)$. Por ello, si $0<gamma<1$,
  $sum_(t>=0)gamma^t EE[S_t^2]<infinity$. En este ejemplo el retorno
  esperado existe pese a la recompensa no acotada. La existencia de una
  política óptima y la validez de un algoritmo requieren argumentos
  adicionales; no se deducen de esta cota.

  Un fallo auténtico de integrabilidad aparece si, en una sola decisión,
  $S_0$ tiene distribución Cauchy y la pérdida es $S_0^2$: su esperanza
  es infinita. El problema es la cola de la distribución, no que el
  espacio de estados sea continuo. En SSCH, discretizar una medición
  tampoco elimina automáticamente el error de modelo o la información perdida.
]
#env-alias("ex:ch6-estados-infinitos", kind: "example")

#thm-env("example", name: [Observabilidad Parcial], key: "ex:ch9-observabilidad-parcial")[
  Sea un estado oculto fijo $Z in \{0,1\}$ con probabilidad inicial $1/2$.
  En cada visita se observa una señal independiente condicionalmente en
  $Z$, con $Prob(O_t=Z|Z)=0.8$. Tras las historias $(0,1)$ y $(1,1)$,
  que comparten la última observación, las probabilidades posteriores son
  $ Prob(Z=1|0,1)=1/2, quad Prob(Z=1|1,1)=16/17. $
  La primera razón de verosimilitudes es $4/4=1$ y la segunda $4^2=16$.
  Una decisión con umbral posterior $0.7$ toma acciones distintas en
  esas historias. El último dato no resume la información pertinente.

  Wald observa $X tilde P_theta$, no necesariamente $theta$. El fallo
  consiste aquí en identificar el estado informativo con la última señal.
  Con modelo y prior especificados, el posterior $b_t=Prob(Z=1|H_t)$
  conserva la información para este problema. Para un estado latente
  finito, la creencia pertenece a un simplex de dimensión finita; el
  posterior puede ser infinito-dimensional en modelos más generales.
]
#env-alias("ex:ch6-observabilidad-parcial", kind: "example")

#thm-env("example", name: [Horizonte Infinito sin Ergodicidad], key: "ex:ch9-horizonte-infinito")[
  Dos estados son absorbentes bajo todas las acciones; sus recompensas
  por paso son respectivamente uno y cero. Desde el primero, con
  $gamma=1$, el retorno total es $sum_(t>=0)1=infinity$. Con
  $gamma=0.99$, vale $100$. La ergodicidad no es necesaria para este
  retorno descontado finito.

  Un horizonte de veinte años con un número finito de decisiones y
  recompensas acotadas tampoco produce divergencia por usar $gamma=1$.
  Si se desea el rendimiento medio por paso, este vale uno o cero según
  el estado inicial: es otro objetivo, con otra ecuación de evaluación.
  Antes de trasladar una garantía debe fijarse cuál de estos tres
  funcionales —total finito, total descontado o promedio— se estudia.
]
#env-alias("ex:ch6-horizonte-infinito", kind: "example")

#thm-env("example", name: [Confounding No Observado], key: "ex:ch9-confounding")[
  Sea $U$ Bernoulli con parámetro $1/2$. La acción
  registrada es $A=U$. Compare dos modelos de resultados potenciales:
  en M1, $Y(0)=Y(1)=U$; en M2, $Y(a)=a$. En ambos se observa exactamente
  $Prob(A=Y=0)=Prob(A=Y=1)=1/2$.
  Sin embargo, intervenir fijando $A=1$ da
  $ EE[Y(1)] = cases(1/2 & "en M1", 1 & "en M2"). $
  Hay solapamiento marginal de las acciones, pero la misma ley observada
  admite valores distintos de la intervención. Ningún estimador basado
  solo en esos registros distingue ambos modelos.

  Agregar una covariable independiente de $(U,A,Y)$ tampoco distingue
  ambos modelos. En SSCH, añadir columnas al registro no sustituye un argumento
  de identificación. Aleatorización, medición pertinente o restricciones
  estructurales justificadas pueden cambiar el problema; DM, IS y DR
  no eliminan por su nombre esta ambigüedad.
]
#env-alias("ex:ch6-confounding", kind: "example")

#mi-tabla(
  caption: [Qué limita cada ejemplo], key: "tab:ch9-contraejemplos",
  table(columns: (25%, 34%, 1fr), align: left, hl(),
    table.header([*Situación*], [*Objeto afectado*], [*Conclusión precisa*]), hl(w: 0.6pt),
    [Estado continuo], [Alcance del resultado discreto], [Requiere una extensión medible; no implica imposibilidad.],
    [Señal parcial], [Estado informativo], [La última observación puede perder información de la historia.],
    [Total infinito sin descuento], [Definición del valor], [El retorno puede divergir aun con recompensa acotada.],
    [Confusión no medida], [Identificación causal], [La ley observada puede no determinar el valor de intervenir.],
    [Colas pesadas], [Integrabilidad], [La pérdida esperada puede ser infinita.],
    [Memoria insuficiente], [Modelo de transición], [Bellman sobre el resumen elegido puede resolver otro problema.], hl(),
  ),
)
#obj-alias("tab:ch6-contraejemplos", kind: "tabla")
#section-alias("sec:ch6-contraejemplos")

=== Límites del Isomorfismo: Cuándo NO se Transfieren Garantías
<sec:ch9-limites>

Conviene separar cuatro preguntas: ¿se conserva el objetivo?, ¿lo
identifican los datos?, ¿el estimador converge con la distribución
anunciada?, ¿la decisión seleccionada mantiene esa garantía? Una respuesta
positiva a una pregunta no responde automáticamente las siguientes.

#thm-env("definition", name: [Garantía Transferible], key: "def:ch9-transferible")[
  Una garantía se transporta mediante una representación cuando se
  especifican el experimento, el objetivo, el procedimiento y sus
  correspondencias, y se demuestra que la afirmación probabilística o
  de riesgo se conserva. Al cambiar el experimento —por ejemplo, de
  muestras independientes a una trayectoria adaptativa— hace falta un
  resultado que cubra el nuevo régimen de datos.
]
#env-alias("def:ch6-transferible", kind: "definition")

#thm-env("note", name: [Condiciones suficientes según el régimen], key: "thm:ch9-condiciones")[
  No existe una lista única de condiciones necesarias formada por
  mixing, overlap y tasas $n^(-1/4)$. Son requisitos de resultados
  particulares. Tres rutas ilustran la diferencia:

  + *Retornos completos independientes:* para una política fija, retornos
    iid con varianza positiva y finita admiten el CLT habitual para la
    media. No se exige mixing dentro de cada episodio de horizonte fijo.
  + *Una trayectoria estacionaria:* el CLT de @thm:ch5-clt-agentes
    proporciona una ruta suficiente mediante momentos y mixing.
  + *Estimación ortogonal:* además de identificación, expansión
    asintóticamente lineal y una varianza estimable, se controla el
    resto debido a las funciones auxiliares. Una condición de producto
    de errores puede permitir tasas diferentes para cada función.

  Overlap se necesita para ciertas identificaciones fuera de política;
  no para calcular el valor en un modelo completamente conocido. Cada
  ruta debe acompañarse de su teorema y su unidad de muestreo.
]
#env-alias("thm:ch6-condiciones", kind: "note")

#mi-tabla(
  caption: [Garantías de estimación y de decisión], key: "tab:ch9-tipos",
  table(columns: (23%, 34%, 1fr), align: left, hl(),
    table.header([*Tipo*], [*Pregunta*], [*Justificación*]), hl(w: 0.6pt),
    [Estimación], [¿Se estima $J(pi)$ con cobertura correcta?], [Identificación, expansión y varianza para el muestreo considerado.],
    [Planificación], [¿La política optimiza el modelo dado?], [Existencia y solución del problema de control.],
    [Selección], [¿Es válida la comparación tras elegir una política?], [Evaluación independiente o inferencia uniforme o selectiva apropiada.], hl(),
  ),
)
#obj-alias("tab:ch6-tipos", kind: "tabla")
#section-alias("sec:ch6-limites")

=== Qué puede transportarse bajo condiciones adicionales
<sec:ch6-conjeturas-transferencia>

Las dificultades anteriores permiten precisar qué información adicional necesita una transferencia. En algunos casos basta aplicar un mapa conocido a un conjunto de confianza; en otros, la selección de la política o el cambio de unidad muestral modifica el problema inferencial. Los resultados siguientes delimitan esas situaciones.

#thm-env("proposition", name: [Transporte de conjuntos de confianza], key: "thm:ch9-ic")[
  Si $C_n$ satisface $Prob_theta (theta in C_n)>=1-alpha$ y el objetivo
  es $g(theta)$, entonces el conjunto imagen $g(C_n)$ satisface
  $ Prob_theta (g(theta) in g(C_n))>=1-alpha. $
  *Demostración.* El suceso $\{theta in C_n\}$ está contenido en
  $\{g(theta) in g(C_n)\}$. La cobertura puede aumentar y el conjunto
  imagen no tiene por qué ser un intervalo. Tomar su envolvente
  intervalar conserva la desigualdad cuando esta está bien definida.

  Esto no construye un intervalo normal. Si, adicionalmente,
  $sqrt(n)(hat(theta)-theta)$ converge a $N(0,Sigma)$ y $g$ es
  diferenciable, el método delta da varianza
  $nabla g(theta)^T Sigma nabla g(theta)$, que debe ser positiva para
  el intervalo normal no degenerado usual. El CLT inicial debe ser
  válido para los datos efectivamente usados.
]
#env-alias("thm:ch6-ic", kind: "proposition")

#thm-env("note", name: [Hipótesis y potencia bajo una transformación], key: "thm:ch9-tests")[
  Contrastar $g(theta)=v_0$ significa contrastar el conjunto
  $\{theta:g(theta)=v_0\}$. Coincide con $theta=theta_0$ solo si la
  preimagen relevante es ese punto. Por ejemplo, para $g(theta)=theta^2$,
  la hipótesis $g(theta)=1$ contiene tanto $theta=1$ como $theta=-1$.
  Un test diseñado únicamente para $theta=1$ no controla por ello el
  nivel sobre toda esa hipótesis compuesta.

  Nivel y potencia se preservan exactamente cuando se conserva el
  experimento y la misma función de rechazo bajo una correspondencia
  de hipótesis. Cambiar a trayectorias dependientes requiere una nueva
  justificación de la distribución del estadístico.
]
#env-alias("thm:ch6-tests", kind: "note")

#thm-env("note", name: [Correspondencias que requieren una prueba propia], key: "prop:ch9-tabla")[
  #table(columns: (28%, 1fr), align: left, hl(),
    table.header([*Resultado*], [*Paso adicional*]), hl(w: 0.6pt),
    [Consistencia], [Continuidad del funcional y convergencia en una topología adecuada.],
    [Normalidad], [Diferenciabilidad pertinente, CLT y resto despreciable.],
    [Cramér–Rao], [Modelo paramétrico regular y parámetro funcional especificado.],
    [Eficiencia semiparamétrica], [Gradiente canónico del modelo observado y estimador que lo alcance.],
    [Test óptimo], [Familia, hipótesis y clase de tests para las que se demuestra optimalidad.],
    [Control FDR], [Valores p válidos y condiciones de dependencia del procedimiento elegido.], hl(),
  )
]
#env-alias("prop:ch6-tabla", kind: "note")

#thm-env("example", name: [Eficiencia no equivale a normalidad de cualquier funcional], key: "thm:ch9-eficiencia")[
  Sean $X_i$ iid $N(theta,1)$. La media es eficiente para $theta$.
  Para $g(theta)=theta^2$, el estimador $overline(X)^2$ tiene, si
  $theta eq.not 0$, varianza asintótica $4theta^2/n$. En $theta=0$,
  $ n overline(X)^2 tilde chi_1^2. $
  La escala y la ley límite cambian; una fórmula normal obtenida
  sustituyendo una derivada nula no proporciona el intervalo habitual.
  La eficiencia se declara respecto de un modelo, un funcional y una
  noción de regularidad. Tampoco basta llamar DR a un estimador para
  que su función de influencia sea la eficiente del modelo de MDP.
]
#env-alias("thm:ch6-eficiencia", kind: "example")

#thm-env("example", name: [Fallo por Violación de Mixing], key: "ex:ch9-fallo-mixing")[
  Elija $Z tilde "Bernoulli"(1/2)$ una sola vez y defina $X_t=Z$ para
  todo $t$. El proceso es estacionario, pero $overline(X)_n=Z$ nunca
  converge en probabilidad a $1/2$. Los sucesos $\{X_0=1\}$ y
  $\{X_k=1\}$ mantienen dependencia $1/4$ para cualquier rezago.
  Si se reemplaza $1/2$ por una proporción desconocida $p$, la ley observada identifica $p$ porque $P(X_0=1)=p$. Sin embargo, alargar una sola trayectoria repite el mismo Bernoulli y no permite estimar consistentemente $p$. Muchas trayectorias con reinicios independientes sí permiten hacerlo: cambia la unidad muestral, no el teorema original.
]
#env-alias("ex:ch6-fallo-mixing", kind: "example")

#thm-env("example", name: [Fallo por Overlap Insuficiente], key: "ex:ch9-fallo-overlap")[
  En una decisión, el registro contiene solo $A=0$ con recompensa cero;
  la política objetivo toma $A=1$ con probabilidad $0.9$. Dos modelos
  asignan a la acción nunca observada recompensas respectivas cero y
  uno. Generan exactamente los mismos registros, pero sus valores
  objetivo son cero y $0.9$. Sin restricciones adicionales no hay
  identificación puntual. DM extrapola; no constituye una solución
  identificada por los datos. El cociente en la acción ausente no es
  un peso observable al que baste asignar «varianza infinita».

  Distinto es el solapamiento débil: si $pi_b (1)=epsilon.alt>0$,
  $pi_e (1)=0.9$ y $R=A$, una contribución IS vale $0.9/epsilon.alt$
  con probabilidad $epsilon.alt$, y cero en otro caso. Entonces
  $ EE[W]=0.9, quad Var(W)=0.81(1/epsilon.alt-1). $
  Con $epsilon.alt=0.01$ la varianza es $80.19$: finita, pero grande.
  Si $0<=R<=1$ y no hay soporte para la acción uno, el primer escenario
  solo permite el intervalo de identificación $[0,0.9]$.
]
#env-alias("ex:ch6-fallo-overlap", kind: "example")

#thm-env("example", name: [Fallo por No-Estacionariedad], key: "ex:ch9-fallo-noest")[
  Hay $n/2$ resultados Bernoulli independientes de media $0.2$, seguidos
  de $n/2$ con media $0.8$. La media conjunta estima $0.5$, no la media
  del régimen final. Su varianza es $0.16/n$, de modo que admite un CLT
  para ese promedio de regímenes. La no estacionariedad no elimina
  toda inferencia: obliga a definir qué población y periodo se evalúan.
  Incluir tiempo en el estado puede representar una dinámica no
  homogénea; no prueba estabilidad futura ni devuelve episodios iid.
]
#env-alias("ex:ch6-fallo-noest", kind: "example")

#thm-env("note", name: [Protocolo antes de invocar una garantía], key: "prop:ch9-protocolo")[
  Registrar objetivo, política, periodo, unidad independiente y modelo;
  separar supuestos de identificación de condiciones del estimador;
  citar el resultado aplicable; documentar qué condiciones se conocen
  por diseño y cuáles solo reciben apoyo diagnóstico. Si una condición
  esencial permanece injustificada, informar una estimación descriptiva,
  una región de identificación o un análisis de sensibilidad según el
  caso, sin adjuntar la garantía que no se ha establecido.
]
#env-alias("prop:ch6-protocolo", kind: "note")

Hasta aquí hemos seguido cambios del objetivo y de la información disponible. La estructura temporal de los datos añade otra dificultad: dos estimadores con la misma fórmula pueden tener fluctuaciones diferentes si uno promedia episodios independientes y el otro una trayectoria larga.

=== Condiciones de Regularidad para Dependencia Temporal
<sec:ch5-dependencia>

En $n$ episodios independientes de horizonte fijo, la observación
estadística puede ser una trayectoria completa. En una trayectoria de
longitud $T$, los pasos son dependientes y el argumento asintótico es
otro. Confundir $n$ con $n H$ multiplica ficticiamente la información.
La siguiente ruta suficiente se refiere a un proceso escalar
estacionario, por ejemplo una contribución de influencia ya definida.

#thm-env("definition", name: [Condición de Mixing para CLT], key: "def:ch5-mixing-clt")[
  Para un proceso estrictamente estacionario $(X_t)_(t in ZZ)$, sean
  $cal(F)_(-infinity)^0=sigma(X_t\:t<=0)$ y
  $cal(F)_k^infinity=sigma(X_t\:t>=k)$. Defínase
  $ alpha(k)=sup_(A in cal(F)_(-infinity)^0, B in cal(F)_k^infinity)
    abs(Prob(A inter B)-Prob(A)Prob(B)). $
  La condición utilizada aquí exige que, para algún $delta>0$,
  $ EE[abs(X_0)^(2+delta)]<infinity, quad
    sum_(k=1)^infinity alpha(k)^(delta/(2+delta))<infinity. $
  Es una condición sobre sigma-álgebras de pasado y futuro, no solo
  sobre la correlación entre dos variables.
]
#env-alias("def:ch6-mixing-clt", kind: "definition")

La autocorrelación controla relaciones lineales de un observable;
$alpha(k)$ controla dependencia entre sucesos. No son intercambiables.
Una cadena finita irreducible y aperiódica tiene convergencia geométrica;
en un espacio general, recurrencia positiva y aperiodicidad no bastan
para afirmar esa velocidad. Véase @bradley2005basic para las distinciones
entre nociones de mixing.

#thm-env("proposition", name: [CLT para una contribución estacionaria], key: "thm:ch5-clt-agentes")[
  Bajo @def:ch5-mixing-clt, con $mu=EE[X_0]$,
  $ sqrt(T)(overline(X)_T-mu) ->^d N(0,sigma_(L R)^2), $
  $ sigma_(L R)^2=Var(X_0)+2sum_(k=1)^infinity Cov(X_0,X_k). $
  La serie de covarianzas es absolutamente convergente. Si además
  $sigma_(L R)^2>0$ y $hat(sigma)_(L R)^2 ->^P sigma_(L R)^2$, un
  intervalo asintótico es
  $ overline(X)_T plus.minus z_(1-alpha/2)hat(sigma)_(L R)/sqrt(T). $
  La varianza de la media es aproximadamente $sigma_(L R)^2/T$;
  no se reemplaza una varianza de la media por una varianza sin dividir
  por el tamaño de la trayectoria.
]
#env-alias("thm:ch6-clt-agentes", kind: "proposition")
Este CLT es un resultado externo de teoría de procesos dependientes;
una exposición con estas condiciones es el teorema 355 de
#link("https://www.stat.cmu.edu/~cshalizi/754/2006/notes/lecture-27.pdf")[las notas de Shalizi sobre mixing].
Aplicarlo a un estimador que utiliza funciones aprendidas exige además
controlar el resto de su expansión; el CLT escalar no realiza ese paso.

#thm-env("example", name: [Cálculo de $sigma_(L R)^2$ en una Cadena de Markov de 2 estados], key: "ex:ch5-cadena")[
  Sea $S_t in \{0,1\}$ con matriz
  $ P=mat(0.8,0.2;0.3,0.7), $
  iniciada en su distribución invariante $(0.6,0.4)$. Defina
  $X_t=10S_t$: el estado y la recompensa no son la misma variable.
  La media de la recompensa es cuatro y su varianza es $24$.
  El segundo autovalor es $0.5$, de modo que
  $ Cov(X_0,X_k)=24(0.5)^k, quad sigma_(L R)^2=72. $
  Para $T=100$, el error estándar asintótico es $sqrt(72/100)=0.849$,
  frente a $sqrt(24/100)=0.490$ si se ignora la dependencia.
  La fórmula finita exacta da
  $ Var(overline(X)_T)=24/T+48/T^2 sum_(k=1)^(T-1)(T-k)(0.5)^k, $
  cuyo valor en $T=100$ es aproximadamente $0.7104$, con error estándar
  $0.843$. La comparación distingue cálculo exacto de aproximación
  asintótica; no afirma una cobertura exacta con cien observaciones.
]
#env-alias("ex:ch6-cadena", kind: "example")

#thm-env("note", name: [Diagnóstico empírico de dependencia], key: "prop:ch5-verificacion")[
  Examinar autocorrelaciones de recompensas, ocupaciones y contribuciones
  del estimador; comparar periodos y reinicios; buscar estados con pocas
  visitas; estudiar sensibilidad a la longitud de bloque o al ancho de
  banda de la varianza. Son diagnósticos de incompatibilidad y fragilidad.
  No certifican una cota poblacional de mixing ni la existencia de
  momentos. Un ajuste log-lineal de autocorrelaciones y un umbral
  arbitrario como $0.95$ no sustituyen una demostración.

  Una estimación HAC, por ejemplo con pesos de Bartlett, toma la forma
  $ hat(sigma)_(L R)^2=hat(c)_0+2sum_(k=1)^K (1-k/(K+1))hat(c)_k, $
  donde $hat(c)_k=T^(-1)sum_(t=k+1)^T (X_t-overline(X))(X_(t-k)-overline(X))$.
  Su consistencia requiere condiciones sobre dependencia, momentos y
  crecimiento de $K$; no basta elegir un valor por inspección.
  Véase @newey1987hac para la construcción de covarianzas HAC.
]
#env-alias("prop:ch6-verificacion", kind: "note")

#mi-tabla(
  caption: [Qué se necesita al cambiar el régimen muestral], key: "tab:ch5-extension",
  table(columns: (25%, 35%, 1fr), align: left, hl(),
    table.header([*Herramienta*], [*Versión dependiente*], [*Condición pendiente*]), hl(w: 0.6pt),
    [CLT de una media], [CLT con varianza de largo plazo], [Dependencia y momentos que permitan ese CLT.],
    [Bootstrap iid], [Remuestreo de episodios o bloques], [Unidad correcta y teorema de consistencia para el funcional y los bloques.],
    [Método delta], [Transformación de un límite conjunto], [Diferenciabilidad y control del resto.], hl(),
  ),
)
#obj-alias("tab:ch6-extension", kind: "tabla")
#section-alias("sec:ch6-dependencia")

== Representación, identificación e inferencia
<sec:ch13-limitaciones>

Los seis mecanismos L1–L6 organizan la revisión sin ampliar la afirmación
formal del @ch:isomorfismo. Los encabezados históricos «isomorfismo
estricto» y «transferencia condicional» se conservan; se refieren aquí,
respectivamente, a límites de representación secuencial y a requisitos
para inferir con datos. Ninguno modifica la identidad de un paso.
#section-alias("sec:ch6-limitaciones")

=== Límites del isomorfismo estricto

*L1. Memoria y propiedad de Markov.* Un estado debe conservar la
información necesaria para predecir la siguiente recompensa y transición
bajo cada acción del modelo. La suficiencia estadística para un parámetro
es una propiedad diferente; no implica automáticamente esta condición.

#thm-env("example", name: [Dos historias con el mismo estado resumido], key: "ex:ch6-memoria")[
  En la decisión final de un episodio, $S_1=0$ siempre, pero la recompensa
  es $R_1=1$ si $A_1=A_0$ y cero en otro caso. Si $A_0$ fue elegido
  uniformemente, una regla que recuerde la acción previa obtiene uno;
  cualquier regla que use solo $S_1$ y aleatorización independiente de
  la historia obtiene esperanza $1/2$. El resumen borra información
  decisiva. Aumentar el estado a $(S_1,A_0)$ corrige este ejemplo y
  permite una ecuación de Bellman para el problema ampliado.
]

*L2. Observabilidad.* El posterior de
@ex:ch9-observabilidad-parcial recupera información para el modelo
latente especificado. Su cálculo presupone conocer o estimar los
mecanismos de observación y evolución. Introducir una creencia no vuelve
conocidos esos mecanismos ni elimina el error de aproximación. En SSCH,
se debe documentar qué historial conserva el agente y qué información
latente se supone representada por su posterior.

*L3. Dinámica, horizonte y muestreo.* Son cuestiones distintas: la
homogeneidad describe un núcleo que no cambia con el tiempo; la
estacionariedad describe una ley del proceso invariante; la ergodicidad
relaciona promedios temporales y poblacionales; el descuento ayuda a
hacer finito un retorno total. Un MDP conocido, finito y descontado
admite planificación óptima aunque la cadena de una política tenga
varias clases recurrentes. Eso no justifica inferencia poblacional
basada en una sola clase observada.

=== Límites de la transferencia condicional

*L4. Identificación causal.* Para interpretar una política como
intervención, la fórmula usual basada en historias observadas necesita
consistencia, positividad e intercambiabilidad secuencial respecto de
esas historias. La última no equivale a observar toda causa del
resultado: exige ausencia de confusión residual relevante para esa
identificación. Otras estrategias de identificación usan otras
restricciones. El @ex:ch9-confounding muestra por qué un buen
ajuste predictivo no permite elegir entre modelos causalmente distintos.

*L5. Soporte y concentración de pesos.* Debe haber soporte de los
estados y acciones que visita la política objetivo, no solo de las
acciones en estados frecuentes del registro. Los pesos por trayectoria
multiplican razones y pueden concentrarse con el horizonte aun cuando
cada razón sea finita. Recortar pesos puede reducir varianza y añadir
sesgo; su magnitud debe incorporarse a la evaluación.

#thm-env("example", name: [Costo de un horizonte largo], key: "ex:ch6-horizonte-pesos")[
  En un modelo de un estado, acciones iid bajo cada política y horizonte
  $H$, sean $pi_e (1)=p=0.8$, $pi_b (1)=b$ y recompensa terminal siempre
  igual a uno. El valor es uno. IS por trayectoria usa
  $ W_H=product_(t=1)^H frac(pi_e (A_t), pi_b (A_t)). $
  Por independencia, $EE_b (W_H)=1$ y
  $ Var_b (W_H)=c^H-1, quad c=p^2/b+(1-p)^2/(1-b). $
  Para $b=0.5$, $c=1.36$; para $b=0.2$, $c=3.25$. El estimador
  promedio sobre $n$ trayectorias tiene esa varianza dividida por $n$.
  Como aquí se conoce que la recompensa es constante, se puede evaluar
  sin IS: la explosión es de este procedimiento, no una imposibilidad
  universal de evaluación.
]

#mi-figura(
  caption: [Varianza exacta de IS por trayectoria en el ejemplo de recompensa terminal constante. No son resultados de simulación ni curvas de PDIS.],
  key: "fig:ch6-varianza-is",
  table(columns: (auto, auto, auto, auto), align: right, hl(),
    table.header([*$b$*], [*$H=1$*], [*$H=5$*], [*$H=10$*]), hl(w: 0.6pt),
    [0.8], [0], [0], [0],
    [0.5], [0.36], [3.65], [20.65],
    [0.2], [2.25], [361.59], [131 471.10], hl(),
  ),
)

*L6. Error de las funciones auxiliares.* Para una expansión ortogonal
con resto acotado por $C a_n b_n$, donde $a_n$ y $b_n$ son errores
$L^2$ de dos funciones auxiliares, la condición pertinente es
$a_n b_n=o_P (n^(-1/2))$, junto con los demás supuestos de la expansión.
No es una ley universal de todos los estimadores. La separación de
muestras ayuda a controlar términos empíricos; no establece tasas de
aprendizaje por sí sola.

#thm-env("example", name: [Tasas compatibles e incompatibles], key: "ex:ch6-tasas")[
  Si $a_n=O_P (n^(-0.30))$ y $b_n=O_P (n^(-0.25))$, su producto es
  $O_P (n^(-0.55))=o_P (n^(-1/2))$. Si ambas tasas son
  $O_P (n^(-0.20))$, el límite disponible para el resto es
  $O_P (n^(-0.40))$, insuficiente para garantizar inferencia a escala
  $sqrt(n)$. Dos tasas exactamente $O_P (n^(-1/4))$ tampoco aseguran
  el pequeño orden requerido. Un resto concreto puede cancelar, pero
  esa cancelación necesita prueba.

  En un modelo paramétrico regular correctamente especificado, tasas
  $n^(-1/2)$ para ambos componentes suelen hacer este producto pequeño.
  En una regresión no paramétrica de suavidad $beta$ y dimensión $d$,
  la tasa ilustrativa $n^(-beta/(2beta+d))$, bajo las condiciones del
  método y diseño, supera $n^(-1/4)$ si $beta>d/2$. La dimensión fija
  por sí sola no establece esa desigualdad ni garantiza que un bosque
  o una red alcance la tasa. El modelo semiparamétrico conserva un
  objetivo de dimensión baja, pero no elimina esta dificultad.
]

En evaluación de MDP, las funciones y normas pertinentes dependen del
modelo de trayectorias. La construcción de @kallus2020double emplea
funciones de valor y razones de ocupación marginal; no autoriza a
sustituirlas sin más por propensiones de una sola acción. Sus condiciones
son propias de esa construcción, independientes de la incrustación de Wald.

#mi-figura(
  caption: [Mapa de los seis mecanismos: cada fila señala el primer objeto que debe revisarse.],
  key: "fig:ch6-mapa-mecanismos",
  table(columns: (12%, 26%, 1fr), align: left, hl(),
    table.header([*Límite*], [*Objeto*], [*Pregunta operativa*]), hl(w: 0.6pt),
    [L1], [Memoria del estado], [¿Historias resumidas igual requieren decisiones distintas?],
    [L2], [Información observada], [¿Qué parte del estado se infiere y bajo qué modelo?],
    [L3], [Dinámica y muestreo], [¿Se evalúa un episodio, una trayectoria o un régimen cambiante?],
    [L4], [Intervención], [¿La ley observada determina el resultado de cambiar la política?],
    [L5], [Soporte], [¿Hay información en las regiones visitadas por la política objetivo?],
    [L6], [Estimador], [¿El resto y la varianza permiten la distribución anunciada?], hl(),
  ),
)

*Cuándo coinciden Bayes, minimax y admisibilidad.* La propiedad de
Markov y la observación del estado no eliminan la incertidumbre sobre
el modelo. Para evitar que siglas como MA y CMIA sustituyan hipótesis,
se distinguen dos formulaciones explícitas. MA y CMIA no aparecen como
condiciones formales en este libro: quedan como abreviaturas viejas
(*Markov action*, acciones que obedecen un núcleo Markov en el historial;
*conditional mean independence of actions*, media condicional de la
recompensa dado estado y acción) — incompatibles con la notación
usada. Nuestro siguiente paso formaliza esas dos formulaciones, no la sigla.

En un modelo conocido con distribución inicial fija $nu$, todas las
políticas se comparan por el mismo escalar $J_nu (pi)$. Si el supremo se
alcanza, las políticas que lo maximizan son precisamente las admisibles
para la pérdida $-J_nu$ en el problema de parámetro único; Bayes y minimax
también optimizan ese escalar. Esta coincidencia no requiere inferir un
parámetro y no afirma optimalidad en estados que $nu$ no visita.

Si se usa cada estado inicial como índice del riesgo,
$R(s,pi)=-V^pi (s)$, la comparación es vectorial. Para un MDP finito
con recompensa acotada y $0<=gamma<1$, existe una política estacionaria
óptima en todos los estados (@puterman2005markov). Toda política que sea
estrictamente peor en alguno queda dominada por ella. Así, las admisibles
son las uniformemente óptimas en esta clase. Un prior con masa positiva
en cada estado tiene las mismas políticas de Bayes, pero un criterio
minimax puede admitir políticas adicionales.

#thm-env("example", name: [Una política minimax puede ser dominada], key: "ex:ch6-minimax-dominada")[
  En una decisión con dos estados iniciales, dos políticas factibles
  tienen vectores de valor $V^a=(1,0)$ y $V^b=(0,0)$. La primera domina
  a la segunda. Sin embargo,
  $ min_s V^a (s)=min_s V^b (s)=0. $
  Ambas son maximin si estas son las únicas opciones relevantes; con
  pérdida negativa ambas son minimax. Bajo un prior que asigne masa
  positiva al primer estado, solo $a$ es Bayes. Si el prior concentra
  toda su masa en el segundo, ambas son Bayes. Por tanto, existencia
  de una política uniformemente óptima no implica igualdad de los
  tres conjuntos de soluciones.
]

#mi-figura(
  caption: [Alcance de la coincidencia de criterios. La comparación depende de qué se toma como parámetro y de la distribución inicial.],
  key: "fig:ch6-tricotomia",
  table(columns: (29%, 1fr), align: left, hl(),
    table.header([*Problema*], [*Relación entre criterios*]), hl(w: 0.6pt),
    [Modelo conocido, objetivo escalar fijo], [Si existe óptimo, Bayes, minimax y admisibilidad coinciden en maximizar ese objetivo.],
    [Riesgo indexado por estados], [Optimalidad uniforme y admisibilidad coinciden bajo existencia; Bayes necesita soporte apropiado; minimax puede incluir políticas dominadas.],
    [Familia de modelos desconocidos], [Vuelven a importar el prior y el peor caso; observar el estado no revela el modelo.], hl(),
  ),
)

=== Una síntesis de las limitaciones

La clasificación paramétrica, semiparamétrica o no paramétrica se refiere
a la familia de leyes, no a si el algoritmo utiliza aprendizaje automático.
Un MDP tabular de tamaño fijo con transiciones desconocidas tiene un
número finito de parámetros. Un modelo de regresiones desconocidas sobre
un estado continuo puede ser infinito-dimensional; estimar un valor
escalar dentro de él plantea un problema semiparamétrico.

En cualquiera de esos casos, el primer obstáculo puede ser identificación,
antes de discutir tasas. Con identificación, una especificación paramétrica
incorrecta puede dar intervalos estrechos alrededor del objetivo equivocado.
Una clase más flexible reduce algunas restricciones, pero puede aumentar
el error de estimación. La ortogonalidad protege frente a ciertos errores
de primer orden; no corrige ausencia de soporte, confusión no medida o
una política seleccionada con los mismos datos sin ajuste inferencial.

*Aplicación al agente SSCH.* Su reporte debe declarar la política que se
evalúa, el horizonte, la población inicial, la información usada para
actuar y el régimen de recolección. Si aprende una política, puede reservar
episodios independientes para evaluarla condicionalmente en el conjunto
de entrenamiento. Un intervalo puntual para esa política no es una
banda simultánea para todas las políticas consideradas durante la búsqueda.

== Cómo se manifiesta una condición que falta
<sec:appD-violaciones>

#thm-env("example", name: [Violación de Irreducibilidad], key: "ex:appD-irreducible")[
  En las dos clases absorbentes de @ex:ch9-fallo-mixing,
  una trayectoria revela su clase, pero su longitud no aporta nuevas realizaciones independientes para estimar consistentemente la probabilidad poblacional de inicio. Condicionar el análisis a la clase observada
  cambia el objetivo y debe declararse. Reinicios independientes con
  la distribución inicial de interés aportan información sobre la mezcla.
  Redefinir nombres de estados no crea esa información.

  Reducibilidad no implica siempre múltiples distribuciones invariantes:
  puede haber estados transitorios y una sola clase cerrada. Debe
  analizarse la cadena concreta, no sustituir ese análisis por una etiqueta.
]

#thm-env("example", name: [Violación de Aperiodicidad], key: "ex:appD-aperiodico")[
  Considere la cadena determinista $0,1,0,1,dots.h$ con fase inicial
  uniforme. Es estacionaria y periódica. Para $X_t=S_t$,
  $ abs(overline(X)_T-1/2)<=1/(2T). $
  El promedio sí converge, aunque la distribución desde un estado
  inicial fijo oscile. El límite a escala $sqrt(T)$ es degenerado y
  la serie usual de autocovarianzas no es absolutamente convergente.
  Este caso no cumple la ruta de mixing anterior; no demuestra que
  todo promedio periódico deje de converger.
  Añadir ruido de transición cambia el proceso y no valida
  retrospectivamente los datos originales.
]

#thm-env("example", name: [Mixing Lento (Polinomial)], key: "ex:appD-lento")[
  Suponga que se ha demostrado $alpha(k)<=C k^(-nu)$ y que existe
  el momento de orden $2+delta$. La sumabilidad utilizada en
  @def:ch5-mixing-clt queda asegurada si
  $ nu delta/(2+delta)>1. $
  Con $delta=2$, basta $nu>2$; una cota con $nu=1$ no permite concluir
  ese CLT. Que la condición suficiente no se verifique tampoco prueba
  que todo CLT sea imposible. Hace falta otro argumento.

  En una cadena finita irreducible y aperiódica, un cuello de botella
  puede producir convergencia geométrica muy lenta; no la convierte
  por sí solo en polinomial. Aumentar bloques o tamaño muestral no
  repara un supuesto falso, y no existe un tamaño universal que
  garantice cobertura nominal.
]

== Revisar la afirmación antes de utilizarla
<sec:appD-protocolo>

El protocolo produce una ficha de justificación, no una certificación
automática de supuestos poblacionales a partir de diagnósticos.

+ *Fijar la pregunta.* Escribir $J(pi)$ con horizonte, descuento,
  distribución inicial, población y periodo. Distinguir política fija,
  aprendida con datos independientes y seleccionada durante la evaluación.
+ *Identificar las unidades.* Registrar número de pacientes o episodios
  independientes, longitud de trayectorias y posibles dependencias entre
  unidades. Separar muestras por unidad completa cuando ese sea el
  supuesto de independencia.
+ *Justificar el modelo.* Documentar qué memoria conserva el estado,
  qué es observado y qué es latente; distinguir núcleo conocido de
  núcleo estimado. La conectividad del grafo estimado no prueba que el
  grafo poblacional sea el mismo.
+ *Justificar identificación.* Explicitar la fuente de intercambiabilidad
  y el soporte relevante. Si se conoce la política de asignación por
  diseño, conservar sus probabilidades registradas. La ausencia de una
  acción en una muestra finita no prueba probabilidad poblacional cero.
+ *Elegir el resultado inferencial.* Registrar CLT, expansión, normas,
  momentos, control del resto y método de varianza que correspondan.
  Evitar mezclar episodios independientes con teoremas de una trayectoria
  estacionaria o trasladar tasas de un estimador a otro.
+ *Examinar fragilidad.* Mostrar pesos, ocupaciones, autocorrelaciones y
  sensibilidad a modelado, bloques o recorte. El ESS de pesos
  $frac((sum_i w_i)^2, sum_i w_i^2)$ no es automáticamente el tamaño efectivo
  por dependencia serial ni una prueba de cobertura.
+ *Emitir una conclusión proporcional.* Separar condiciones garantizadas
  por diseño, demostradas para el modelo, apoyadas solo por diagnóstico
  y no justificadas. Si falta identificación, presentar sensibilidad o
  cotas cuando sean posibles. Si falla la inferencia, conservar el
  resultado descriptivo con su alcance, sin un intervalo nominal injustificado.

*Ejemplo de cierre de la ficha.* «Se evalúa una política fijada antes de
analizar cien episodios independientes de tres visitas. La incertidumbre
se calcula entre episodios. Las probabilidades de asignación se conocen
por diseño y el soporte requerido está garantizado en el modelo del
estudio. No se afirma validez para una política reajustada durante estas
visitas ni para otra población inicial». Este texto identifica qué nueva
pregunta exigiría otra evaluación, sin inventar un resultado numérico.

== Relacionar cada garantía con su justificación
<sec:appD-resumen>

#mi-tabla(
  caption: [Condiciones y límites de su verificación], key: "tab:appD-checklist",
  table(columns: (23%, 43%, 1fr), align: left, hl(),
    table.header([*Garantía*], [*Base de la justificación*], [*Límite diagnóstico*]), hl(w: 0.6pt),
    [Identidad riesgo–retorno], [Construcción de un paso y misma clase de reglas del @ch:isomorfismo.], [Se verifica algebraicamente; no requiere una prueba de mixing.],
    [IC para una media iid], [Independencia, objetivo fijo, varianza finita positiva y CLT con varianza consistente.], [La muestra finita no certifica los momentos.],
    [IC con dependencia], [CLT apropiado y estimador consistente de la varianza asintótica.], [Una ACF favorable no prueba mixing.],
    [Valor fuera de política], [Identificación y soporte de la ley objetivo en la ley observada.], [ESS no certifica soporte poblacional.],
    [Eficiencia ortogonal], [Gradiente correcto, expansión regular, resto pequeño y varianza válida.], [Validación predictiva no demuestra tasas asintóticas.],
    [Bootstrap], [Teorema para el funcional, el muestreo y el remuestreo utilizados.], [Bloques largos no garantizan consistencia por sí solos.],
    [Garantía tras selección], [Separación de evaluación o resultado uniforme o selectivo aplicable.], [Un IC puntual no cubre toda una búsqueda de políticas.], hl(),
  ),
)

La contribución de este capítulo es precisar la pregunta que debe
resolverse antes de atribuir una garantía al agente. Los capítulos de
evaluación e intervalos desarrollan procedimientos para regímenes
específicos; su validez debe leerse junto con esas condiciones, sin
extender la representación de un paso a entornos que no cubre.

Con estas distinciones, la evaluación fuera de política puede formularse como un problema concreto: aprender el valor de una regla usando acciones registradas por otra. El capítulo siguiente comienza por identificar ese valor y después compara los estimadores que permiten aproximarlo.
