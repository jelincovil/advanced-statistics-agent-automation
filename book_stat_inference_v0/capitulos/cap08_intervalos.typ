#import "../plantilla.typ": *

= Intervalos de confianza para funciones de valor
<ch:inferencia>

Una estimación de valor necesita una medida de incertidumbre referida a
un objetivo y a un régimen de datos. Este capítulo distingue tres rutas:
promedios de contribuciones de episodios independientes, inferencia con
una trayectoria dependiente y estimación de Bellman mediante bases.
Una cuarta cuestión aparece al aprender la política con los mismos datos:
el objetivo de evaluación deja de ser una política fijada de antemano.

La evaluación OPE del @ch:ope proporciona estimadores, pero su nombre no
determina la validez del intervalo. Hay que justificar identificación,
expansión asintótica, error de aproximación y estimación de varianza.
Los ejemplos SSCH de este capítulo son cálculos sintéticos reproducibles;
no son resultados de una validación clínica.

La dependencia dentro de una trayectoria no implica dependencia entre
trayectorias. Cien episodios independientes pueden analizarse mediante
cien contribuciones, aunque cada episodio contenga muchas decisiones.
Una trayectoria larga requiere, en cambio, un argumento que tenga en
cuenta su dependencia o una estructura de diferencias de martingala.

#cite(<shi2022statistical>, form: "prose") estudian el valor descontado en
horizonte infinito mediante aproximación sieve y desarrollan SAVE para
políticas dependientes de los datos. La eficiencia semiparamétrica de DRL
se estudia en @kallus2020double y @kallus2022efficiently. Son resultados
con estimadores y modelos diferentes. No cabe atribuir a todos ellos
una misma función eficiente o un bootstrap universal.

La pregunta aplicada debe preceder al cálculo: ¿interesa el valor de una
política, su diferencia frente a una referencia o el rendimiento de una
regla aprendida? Un valor positivo no demuestra mejora frente a otra
política. Un intervalo estrecho tampoco corrige un objetivo no identificado.

== Definir la incertidumbre según el objetivo y los datos
<sec:ch11-teoria>

=== El Problema de Inferencia
<sec:ch11-problema>

Fijadas una política $pi$ y una distribución inicial $nu$, sea
$J(pi)=integral V^pi (s)nu(dif s)$. La inferencia puntual sobre
$V^pi (s_0)$, la inferencia sobre $J(pi)$ y una banda simultánea sobre
muchos estados son objetos distintos. La distribución $nu$ se considera
fija y conocida, salvo indicación contraria; estimarla puede añadir
variabilidad.

Un intervalo asintóticamente exacto de nivel $1-alpha$ satisface
$ Prob(J(pi) in C_n)->1-alpha. $
La validez asintótica conservadora solo requiere que el límite inferior de la cobertura sea al menos $1-alpha$. Ninguna de estas condiciones es una garantía de cobertura para cada tamaño finito.
Tampoco asigna probabilidad posterior al parámetro fijo. Si el estimador
admite una expansión
$ hat(J)-J=1/n sum_(i=1)^n phi(O_i)+o_P (n^(-1/2)), $
con episodios iid, $EE(phi)=0$ y $0<sigma^2=EE(phi^2)<infinity$,
el CLT y una varianza consistente justifican
$ hat(J) plus.minus z_(1-alpha/2)frac(hat(sigma),sqrt(n)). $
Aquí $sigma$ es una desviación de contribuciones; $hat(sigma)/sqrt(n)$
es el error estándar de la estimación. Dividir dos veces por $sqrt(n)$
produce intervalos artificialmente estrechos.

*Modelos e inferencia.* En un modelo paramétrico regular puede usarse
una matriz de covarianza y el método delta. En un modelo semiparamétrico,
el funcional puede tener tasa $sqrt(n)$ aunque sus funciones auxiliares
converjan más lentamente. En un problema no paramétrico, estimar una
función completa suele exigir otra tasa y controlar sesgo de suavización.
No todo funcional admite una expansión regular de primer orden.
#section-alias("sec:ch8-problema")

=== Condiciones de Mixing
<sec:ch11-mixing>

#thm-env("definition", name: [$alpha$-mixing], key: "def:ch11-alpha")[
  Para un proceso estacionario $(X_t)_(t in ZZ)$, defina
  $ alpha(k)=sup_(A in cal(F)_(-infinity)^0,B in cal(F)_k^infinity)
    abs(Prob(A inter B)-Prob(A)Prob(B)), $
  donde las sigma-álgebras corresponden al pasado y al futuro separados
  por $k$ pasos. El proceso es fuertemente mixing si $alpha(k)->0$.
  No basta con que un observable tenga autocorrelación pequeña.
]
#env-alias("def:ch8-alpha", kind: "definition")

#thm-env("definition", name: [Mixing geométrico], key: "def:ch11-geometrico")[
  Existe una cota $alpha(k)<=C r^k$ con $C<infinity$ y $0<r<1$.
  La tasa pertenece a una ley del proceso; una autocorrelación estimada
  no constituye por sí sola una prueba de esa cota.
]
#env-alias("def:ch8-geometrico", kind: "definition")

#thm-env("proposition", name: [Alcance del caso finito], key: "prop:ch11-ergodico")[
  Una cadena finita irreducible y aperiódica, iniciada en su ley
  invariante, es geométricamente mixing. Para trasladarlo a acciones
  y recompensas se requiere que su generación siga los núcleos
  especificados sin dependencia latente adicional entre tiempos.
  En espacios generales, recurrencia positiva y aperiodicidad no
  garantizan por sí solas una tasa geométrica.
]
#env-alias("prop:ch8-ergodico", kind: "proposition")

La cadena relevante para los datos es la inducida por la política de
registro. Estudiar exclusivamente la política objetivo no caracteriza
la dependencia de la muestra observada. Véase @bradley2005basic para
las distinciones entre condiciones de mixing.
#section-alias("sec:ch8-mixing")

=== Tasas de Mixing Explícitas para MDPs
<sec:ch11-tasas-explicitas>

#thm-env("theorem", name: [Una cota espectral bajo reversibilidad], key: "thm:ch11-tasa-tabular")[
  Sea $P$ una matriz finita, irreducible, aperiódica y reversible respecto
  de $mu$, con $m$ estados. Si
  $r=max_(j>=2)abs(lambda_j)<1$, entonces
  $ norm(P^k (s,dot)-mu)_"TV"<=1/2 sqrt(frac(1,mu(s))-1)r^k. $
  Con la convención estacionaria
  $beta(k)=sum_s mu(s)norm(P^k (s,dot)-mu)_"TV"$, se obtiene
  $ beta(k)<=1/2 sqrt(m-1)r^k. $
]
#env-alias("thm:ch8-tasa-tabular", kind: "theorem")
#proof-env[
  En $L^2(mu)$, reversibilidad hace autoadjunto al operador de transición.
  Su restricción al subespacio de media cero tiene norma $r$.
  La densidad inicial desde $s$, menos uno, tiene norma
  $sqrt(1/mu(s)-1)$. Aplicar $P^k$ y Cauchy–Schwarz da la cota en
  variación total. Promediar y aplicar nuevamente Cauchy–Schwarz
  produce $sqrt(m-1)$. No se ha supuesto que los autovalores sean positivos.
]

#thm-env("note", name: [Interpretación del gap], key: "cor:ch11-gap")[
  El gap absoluto usado arriba es $1-r$. No debe confundirse con el
  segundo autovalor sin valor absoluto. En
  $P=mat(0.01,0.99;0.99,0.01)$, el autovalor no trivial es $-0.98$:
  ignorar su módulo ocultaría la persistencia de la alternancia.
  Para una matriz no reversible hacen falta otras cotas; una fórmula
  con un único autovalor real ordenado no es una regla general.
  Una matriz estimada agrega incertidumbre a cualquier diagnóstico.
]
#env-alias("cor:ch8-gap", kind: "note")

#thm-env("example", name: [Dependencia y tamaño efectivo de una media], key: "prop:ch11-impacto")[
  Si un observable estacionario tiene autocovarianza
  $Cov(X_0,X_k)=sigma_X^2 rho^k$ con $abs(rho)<1$, entonces
  $ sigma_"LR"^2=sigma_X^2 frac(1+rho,1-rho), quad
    T_"eff" approx T frac(1-rho,1+rho). $
  Para $rho=0.95$ y $T=1000$, el factor de varianza es $39$,
  $T_"eff" approx 25.64$ y el error estándar asintótico se multiplica
  por $sqrt(39) approx 6.24$. Son fórmulas para este observable,
  no para todo proceso con cierta tasa de mixing. Con correlaciones
  negativas, la varianza de la media puede disminuir.
]
#env-alias("prop:ch8-impacto", kind: "example")

#mi-tabla(
  caption: [Régimen de datos y fundamento de la varianza], key: "tab:ch11-tasas",
  table(columns: (28%, 35%, 1fr), align: left, hl(),
    table.header([*Datos*], [*Ruta posible*], [*Condición adicional*]), hl(w: 0.6pt),
    [Episodios independientes], [Varianza entre contribuciones de episodios.], [Reinicios y unidades realmente independientes.],
    [Cadena finita reversible], [Cota espectral con módulo de autovalores.], [Política de registro fija y modelo apropiado.],
    [Estado continuo], [Drift, minoración u otra condición demostrada.], [Una ACF no prueba ergodicidad geométrica.],
    [Residuos martingala], [Varianza condicional y CLT de martingala.], [Filtración, momentos y resto controlados.], hl(),
  ),
)
#obj-alias("tab:ch8-tasas", kind: "tabla")

#algorithm-env(caption: [Selección justificada del método de varianza], key: "alg:ch11-seleccion")[
  + Fijar estimando, política, unidad de muestreo y régimen asintótico.
  + Si hay episodios iid, calcular contribuciones por episodio.
  + Si se usa una trayectoria, identificar la secuencia de influencia
    o momentos y justificar su CLT; distinguir mixing y martingalas.
  + Escoger un estimador de varianza compatible con esa representación.
  + Examinar sensibilidad a ajustes, rezagos y bloques, sin convertir
    umbrales de autocorrelación en certificados de validez.
]
#obj-alias("alg:ch8-seleccion", kind: "algoritmo")
#section-alias("sec:ch8-tasas-explicitas")

=== CLT para Procesos Mixing
<sec:ch11-clt>

#thm-env("theorem", name: [CLT bajo mixing fuerte], key: "thm:ch11-clt-mixing")[
  Para un proceso estrictamente estacionario de media cero, suponga
  $EE(abs(X_0)^(2+delta))<infinity$ para algún $delta>0$ y
  $sum_(k>=1)alpha(k)^(delta/(2+delta))<infinity$. Entonces
  $ frac(1,sqrt(T))sum_(t=1)^T X_t ->^d N(0,sigma_"LR"^2), $
  $ sigma_"LR"^2=Var(X_0)+2sum_(k>=1)Cov(X_0,X_k). $
  Para un intervalo normal no degenerado se necesita además
  $sigma_"LR"^2>0$ y estimación consistente de esa varianza.
]
#env-alias("thm:ch8-clt-mixing", kind: "theorem")

Este resultado de teoría de procesos dependientes no controla por sí solo
el error de funciones aprendidas. Si $X_t$ se reemplaza por una
contribución estimada, hay que demostrar que la sustitución y el resto
son despreciables a la escala usada. El @ch:fallos desarrolla esta frontera.
#section-alias("sec:ch8-clt")

=== El Teorema de Shi et al. (2022)
<sec:ch11-shi>

Aquí cambia el horizonte del objetivo: se considera
$V^pi (s)=EE_pi (sum_(t>=0)gamma^t R_t|S_0=s)$, con $0<gamma<1$,
aunque cada trayectoria observada tenga longitud $T$. No es el retorno
truncado a $T$ usado como objetivo en otros procedimientos.

*La ecuación que permite estimar.* Para mostrar la construcción de
Bellman, tome un vector de bases $f(s,a)$ y una aproximación
$q_beta (s,a)=f(s,a)^T beta$. Defina
$ u_pi (s)=sum_a pi(a|s)f(s,a), quad a_nu=integral u_pi (s)nu(dif s). $
Con $N=n T$, use
$ hat(M)=frac(1,N)sum_(i,t)f_(i,t) (f_(i,t)-gamma u_pi (S_(i,t+1)))^T, $
$ hat(h)=frac(1,N)sum_(i,t)f_(i,t)R_(i,t), quad
  hat(beta)=hat(M)^(-1)hat(h), quad hat(J)=a_nu^T hat(beta). $
Las sumas cubren los $T$ pares de transición de cada trayectoria.
Estas fórmulas necesitan invertibilidad. Una matriz casi singular puede
hacer inestable tanto la estimación como su error estándar.

En un modelo lineal exacto, el residuo
$epsilon.alt_(i,t)=R_(i,t)+gamma u_pi (S_(i,t+1))^T beta-f_(i,t)^T beta$
tiene media condicional cero si la ecuación de Bellman es válida dado
el historial previo a observar recompensa y siguiente estado. El
momento $f_(i,t)epsilon.alt_(i,t)$ es entonces una diferencia de
martingala. En una aproximación sieve, las bases crecen y se debe controlar
además el error de aproximación. No basta con ajustar una regresión flexible.

#thm-env("note", name: [Alcance del Teorema 1 de SZLS], key: "thm:ch11-shi")[
  Bajo las hipótesis completas de su Teorema 1, incluidos los requisitos
  sobre bases, regularidad, información y crecimiento de dimensiones,
  #cite(<shi2022statistical>, form: "prose") obtienen, para política fija,
  $ frac(sqrt(n T)(hat(J)(pi;nu)-J(pi;nu)),hat(sigma)(pi;nu)) ->^d N(0,1), $
  en los regímenes admitidos con $n$ o $T$ creciente. Es una referencia
  al resultado original, no un teorema DR ni una transcripción completa
  de sus hipótesis.
]
#env-alias("thm:ch8-shi", kind: "note")

MA describe la transición Markov; CMIA describe la independencia
condicional en media de la recompensa respecto del pasado dado estado
y acción. Ninguna de esas siglas equivale, por definición, a identificación
causal de intervenciones con confusión no medida. Tampoco «no estimar
la política de registro» significa poder evaluar acciones sin información:
la información del diseño y la invertibilidad siguen siendo esenciales.

#thm-env("corollary", name: [Intervalo por studentización], key: "cor:ch11-ic")[
  Siempre que se haya establecido el límite studentizado anterior,
  $ hat(J)(pi;nu) plus.minus z_(1-alpha/2)frac(hat(sigma)(pi;nu),sqrt(n T)) $
  tiene cobertura asintótica $1-alpha$. En un procedimiento basado en
  episodios de horizonte fijo con contribución por episodio, la escala
  correspondiente es $sqrt(n)$ y no se reemplaza por $sqrt(n T)$.
]
#env-alias("cor:ch8-ic", kind: "corollary")
#verdem(<dem:ch11-shi>)

Una expansión asintótica describe la escala y la distribución límite del error. Para utilizarla con datos necesitamos además estimar su varianza en el mismo régimen de muestreo. La elección entre episodios, trayectorias y bloques determina qué contribuciones pueden promediarse.
#section-alias("sec:ch8-shi")

== Estimación de Varianza
<sec:ch11-varianza>

#thm-env("definition", name: [Varianza de contribuciones por episodio], key: "def:ch11-var-if")[
  Si $D_i$ son contribuciones de evaluación y $hat(J)=overline(D)$,
  defina $hat(phi)_i=D_i-overline(D)$ y
  $ s_D^2=frac(1,n-1)sum_i hat(phi)_i^2, quad
    hat("SE")=frac(s_D,sqrt(n)). $
  Para contribuciones cross-fitted, la consistencia de esta fórmula
  requiere las condiciones de la expansión; no se deduce de tratar
  los ajustes compartidos como si fueran independientes.
]
#env-alias("def:ch8-var-if", kind: "definition")

#thm-env("definition", name: [Varianza HAC con pesos de Bartlett], key: "def:ch11-hac")[
  Para una secuencia estimada $hat(phi)_t$, con promedio $overline(phi)$,
  $ hat(c)_k=frac(1,T)sum_(t=k+1)^T
    (hat(phi)_t-overline(phi))(hat(phi)_(t-k)-overline(phi)), $
  $ hat(sigma)_"HAC"^2=hat(c)_0+2sum_(k=1)^K
    (1-frac(k,K+1))hat(c)_k. $
  El error estándar de una media es $hat(sigma)_"HAC"/sqrt(T)$.
  El crecimiento de $K$ debe cumplir el teorema de consistencia usado;
  elegir $K$ del orden $T^(1/3)$ no es una regla válida para todo proceso.
]
#env-alias("def:ch8-hac", kind: "definition")

#thm-env("proposition", name: [Consistencia: una ruta suficiente para HAC], key: "thm:ch11-var-consistente")[
  Sea $c_k$ la autocovarianza de una secuencia estacionaria y suponga
  $sum_(k>=0)abs(c_k)<infinity$, $K->infinity$, $K/T->0$ y
  $ sum_(k=0)^K abs(hat(c)_k-c_k)->^P 0. $
  Entonces $hat(sigma)_"HAC"^2->^P sigma_"LR"^2$.
]
#env-alias("thm:ch8-var-consistente", kind: "proposition")
#proof-env[
  El error se separa en estimación de covarianzas, cola omitida y
  ponderación de Bartlett. El primero se acota por dos veces la suma
  del enunciado. Los otros tienden a cero por sumabilidad y convergencia
  de los pesos a uno en cada rezago fijo. La condición sobre las
  covarianzas estimadas debe demostrarse; no se obtiene solo del CLT.
]

En la ecuación de Bellman anterior, si los momentos son diferencias de
martingala y la aproximación es despreciable, se utiliza una matriz
sandwich compatible con ellos. En dimensión fija, una forma es
$ hat(Omega)=frac(1,N)sum_(i,t)f_(i,t)f_(i,t)^T hat(epsilon.alt)_(i,t)^2, $
$ hat(sigma)^2=a_nu^T hat(M)^(-1)hat(Omega)hat(M)^(-T)a_nu. $
Esta fórmula no es una varianza HAC genérica ni una cota de eficiencia
semiparamétrica por definición. Si falla la propiedad martingala, las
covarianzas de los momentos pueden dejar de anularse.

*Bootstrap: qué se remuestrea.* Con episodios iid se remuestrean episodios
completos. Con una trayectoria se consideran bloques u otro método
justificado para su dependencia. Cuando el estimador aprende funciones,
remuestrear solo las contribuciones fijadas exige que la aproximación
lineal ya controle ese aprendizaje; otro procedimiento puede requerir
reajustar los modelos en cada réplica. La validez del bootstrap debe
probarse para el funcional y el estimador concretos. Que los bloques
crezcan y sean pequeños frente a $T$ no constituye, por sí solo, una
prueba completa. Véase también @hall1992bootstrap.

Hasta aquí la interpretación del intervalo descansaba en un objetivo fijado para la evaluación. Si los datos también actualizan la política, la cantidad evaluada puede cambiar entre bloques. SAVE aborda esa organización secuencial mediante un procedimiento específico.
#section-alias("sec:ch8-varianza")

== SAVE: Corrección de Sesgo
<sec:ch11-save>

Se conserva el título histórico, pero SAVE aborda la evaluación secuencial
de políticas aprendidas; no es una corrección residual IS equivalente a DR.

#thm-env("definition", name: [SAVE y orden de aprendizaje], key: "def:ch11-save")[
  SAVE significa SequentiAl Value Evaluation. El procedimiento de
  #cite(<shi2022statistical>, form: "prose") actualiza políticas y
  evaluaciones en bloques ordenados. Puede tratar no unicidad de la
  política óptima bajo sus condiciones. La partición, agregación y
  studentización deben seguir el procedimiento original; un promedio
  arbitrario de contribuciones DR no lo reproduce.
]
#env-alias("def:ch8-save", kind: "definition")

*La dificultad que hay que resolver.* Si $pi_k$ se aprende antes de un
bloque de evaluación y $hat(J)_k$ estima su valor, un promedio con pesos
predeterminados $a_k$ suma estimaciones de políticas distintas. Para
compararlo con una política final $pi_f$, aparece el término
$ sum_k a_k (J(pi_k)-J(pi_f)), quad sum_k a_k=1. $
Aunque cada evaluación tenga un error centrado, ese término no se anula
por respetar el orden temporal. Se necesita controlarlo a la escala del
intervalo. Esta descomposición explica el problema; no define la fórmula
exacta de SAVE.

#thm-env("note", name: [Margen y tasas de valor], key: "thm:ch11-szls-tasas")[
  Los Teoremas 3–4 de SZLS relacionan errores de estimación de $Q$ con
  tasas de valor bajo condiciones de margen. Las tasas dependen de
  la norma de error; no se puede trasladar una tasa uniforme a un
  error $L^2$ sin otro argumento.
]
#env-alias("thm:ch8-szls-tasas", kind: "note")

#thm-env("example", key: "cap11-margen")[
  *Ejemplo elemental de una decisión.* Con dos acciones, sea
  $Delta(s)=abs(q(s,1)-q(s,0))$ y suponga
  $Prob(0<Delta(S)<=u)<=C u^kappa$. Si
  $norm(hat(q)-q)_infinity<=epsilon.alt$, una acción greedy incorrecta
  solo puede tener gap positivo menor o igual a $2epsilon.alt$. Por tanto,
  $ EE(q(S,a^*(S))-q(S,hat(a)(S)))<=C(2epsilon.alt)^(1+kappa). $
  Los empates tienen pérdida cero. Este cálculo es autocontenido para una
  decisión; no certifica que una red neuronal alcance el error supuesto,
  ni sustituye las condiciones longitudinales del artículo.
]

#thm-env("note", name: [Qué se puede atribuir a SAVE], key: "prop:ch11-save")[
  Evaluar con orden temporal atiende la adaptación, pero no demuestra
  por sí solo ausencia de sesgo, doble robustez o varianza menor que IS.
  Con una política aprendida y congelada puede usarse evaluación en
  episodios independientes, condicionando en el entrenamiento. Ese
  objetivo es el valor de la política aprendida, no necesariamente el
  valor óptimo desconocido.
]
#env-alias("prop:ch8-save", kind: "note")
#section-alias("sec:ch8-save")

== Diseño de Poder y Tamaño de Muestra
<sec:ch11-poder>

#thm-env("proposition", name: [Planificación normal aproximada], key: "thm:ch11-n")[
  Para un contraste bilateral de nivel $alpha$, diferencia positiva
  relevante $delta$, poder aproximado $1-beta$ y desviación $sigma_D$
  de la contribución de la diferencia por unidad independiente,
  $ n approx ceil(frac((z_(1-alpha/2)+z_(1-beta))^2 sigma_D^2,delta^2)). $
  Es una aproximación de planificación, no una garantía finita universal.
  La varianza debe corresponder al estimador, diseño y objetivo elegidos.
]
#env-alias("thm:ch8-n", kind: "proposition")

Con $alpha=0.05$, poder $0.80$ y efecto estandarizado $0.2$, cuantiles
normales precisos dan $n=197$. Redondear primero a $1.96$ y $0.84$ da
$196$; para planificar conviene redondear el tamaño al final. Si
$delta=0.5$ y $sigma_D=2$, se necesitan aproximadamente $126$ unidades
para poder $80%$ y $169$ para $90%$. Son unidades independientes, no
pasos de una misma trayectoria.

Para dos grupos independientes de igual tamaño, la varianza de la
diferencia es la suma de las varianzas de sus medias y el tamaño debe
especificarse por grupo. Para dos políticas evaluadas sobre los mismos
episodios, se usa la varianza de sus diferencias, incluida la covarianza.
Añadir automáticamente un factor dos puede desperdiciar o subestimar
información. La dependencia y los errores de modelos auxiliares requieren
una planificación adicional o simulación del procedimiento completo.
#section-alias("sec:ch8-poder")

== Diagnóstico de Supuestos
<sec:ch11-diagnostico>

La ficha de evaluación debe separar condiciones del diseño, supuestos
del modelo y señales empíricas. El ESS y los pesos informan sobre
concentración; no certifican soporte poblacional. Una ACF informa sobre
un observable; no prueba mixing. Residuos de Bellman pequeños no prueban
identificación causal ni ausencia de sesgo de aproximación.

Una simulación de cobertura necesita un valor verdadero conocido,
repetir todo el ajuste y contar la fracción de intervalos que lo contienen.
Con $M$ réplicas independientes, el error Monte Carlo estimado es
$sqrt(hat(p)(1-hat(p))/M)$. Si $M=2000$ y la cobertura es $0.95$,
es aproximadamente $0.0049$. Una cobertura de $0.88$ no se repara
multiplicando intervalos por un factor elegido después de ver el
resultado: primero se investiga si falla el sesgo, la varianza, la
selección o el régimen muestral. No se reportan aquí corridas de
simulación que no hayan sido realizadas.
#section-alias("sec:ch8-diagnostico")

== Deep Reinforcement Learning: Policy Gradient y REINFORCE
<sec:ch11-drl>

Aprender una política e inferir su valor son tareas diferentes. Para
hacer explícito el cálculo del gradiente, se usa primero horizonte
finito $H$, distribución inicial fija y núcleo del entorno que no
depende del parámetro de política $theta$.

#thm-env("definition", name: [Objetivo diferenciable de política], key: "def:ch11-pg")[
  Sea $pi_theta$ una política diferenciable con soporte fijo,
  $J(theta)=EE_theta (sum_(t=0)^(H-1)gamma^t R_t)$ y
  $G_t=sum_(k=t)^(H-1)gamma^(k-t)R_k$.
  El score de acción es $z_t=nabla_theta log pi_theta (A_t|S_t)$.
  Se supone integrabilidad suficiente para intercambiar derivada e integral.
]
#env-alias("def:ch8-pg", kind: "definition")

#thm-env("theorem", name: [Identidad del gradiente de política], key: "thm:ch11-pg-theorem")[
  En el experimento anterior,
  $ nabla_theta J(theta)=EE_theta (sum_(t=0)^(H-1)gamma^t z_t G_t)
    =EE_theta (sum_(t=0)^(H-1)gamma^t z_t q_t^(pi_theta) (S_t,A_t)). $
]
#env-alias("thm:ch8-pg-theorem", kind: "theorem")
#proof-env[
  El score de la trayectoria es $sum_t z_t$, porque solo las
  probabilidades de acción dependen de $theta$. Multiplicarlo por el
  retorno total y tomar esperanza da la derivada. Las recompensas
  anteriores a la acción $t$ tienen producto de esperanza cero con
  $z_t$, cuyo promedio condicional dado el historial es cero.
  Restan los retornos desde $t$, con factor $gamma^t$. Condicionar en
  $S_t,A_t$ permite sustituir $G_t$ por $q_t$. Para horizonte infinito
  se necesitan condiciones adicionales de dominación y convergencia;
  $gamma<1$ por sí solo no controla un score arbitrariamente grande.
]

#thm-env("definition", name: [REINFORCE], key: "def:ch11-reinforce")[
  Con la política congelada durante un episodio, calcule
  $ hat(g)=sum_(t=0)^(H-1)gamma^t z_t G_t $
  y actualice $theta$ mediante $theta+eta hat(g)$. La contribución es
  insesgada bajo el modelo y las condiciones anteriores. Que el
  gradiente sea insesgado no prueba convergencia global de la optimización.
]
#env-alias("def:ch8-reinforce", kind: "definition")

#thm-env("proposition", name: [Baseline: centrado y varianza], key: "prop:ch11-baseline")[
  Si $b_t$ depende del historial anterior a actuar, pero no de la acción
  muestreada, $EE(z_t b_t)=0$ bajo integrabilidad. Puede reemplazarse
  $G_t$ por $G_t-b_t$ sin alterar la esperanza del gradiente.
  Una baseline aprendida con la misma acción o resultado necesita
  un argumento adicional de independencia o corrección.
]
#env-alias("prop:ch8-baseline", kind: "proposition")

Para una contribución vectorial de un solo tiempo, minimizar la traza
de su varianza condicional da
$ b^*(s)=frac(EE(norm(z)^2 G|S=s),EE(norm(z)^2|S=s)), $
si el denominador es positivo. No tiene que coincidir con $V(s)$.
En varios tiempos intervienen además covarianzas entre contribuciones;
la fórmula local no resuelve automáticamente la minimización global.

#thm-env("example", name: [SSCH: baseline con cálculo exacto], key: "ex:ssch-drl-cap11", es-sintetico: true)[
  En una decisión abstracta, $A$ es Bernoulli con
  $p=1/(1+exp(-theta))$ y $R=A$. El score es $A-p$ y el gradiente
  verdadero es $p(1-p)$. Tome $p=0.75$, de modo que el gradiente es
  $0.1875$.

  Sin baseline, la contribución $A(A-p)$ vale cero o $0.25$ y su
  varianza es $0.01171875$. La baseline de valor $b=p=0.75$ produce
  contribuciones $0.5625$ o $0.0625$: conserva la media, pero su
  varianza es $0.046875$, cuatro veces mayor. La baseline óptima
  $b=1-p=0.25$ produce $0.1875$ para ambas acciones y varianza cero.
  Una baseline puede mejorar, empeorar o anular la varianza según
  el problema. No se ha simulado una red ni estimado un beneficio clínico.
]
#section-alias("sec:ch8-drl")

=== El criterio de la política y la estimación del gradiente
<sec:ch11-pg>

El parámetro que indexa la política no debe confundirse con el parámetro
estadístico desconocido del entorno. Si se define una pérdida de política
como el negativo del retorno, derivar respecto de su parámetro cambia
el signo del gradiente de valor; no convierte todo aprendizaje profundo
en una transferencia de la representación de Wald.

#thm-env("definition", name: [Gradiente y aproximación por un crítico], key: "def:ch11-pg-v2")[
  Para el objetivo finito definido antes, la identidad exacta utiliza
  $q_t^(pi_theta)$ y los factores $gamma^t$. Sustituir esa función por
  $hat(q)_t$ produce un estimador cuyo sesgo incluye
  $ EE_theta (sum_t gamma^t z_t (hat(q)_t (S_t,A_t)-q_t^(pi_theta) (S_t,A_t))). $
  Este término no es cero para un crítico arbitrario.
]
#env-alias("def:ch8-pg-v2", kind: "definition")

#thm-env("proposition", name: [Momentos del gradiente y función de influencia], key: "prop:ch11-reinforce-if")[
  Para una política fija y episodios iid, sea
  $Z(O)=sum_t gamma^t z_t G_t$, con segundo momento finito. El promedio
  $hat(g)$ satisface un CLT multivariado con matriz
  $Sigma=Var(Z(O))$. Como estimador de la media $EE(Z)$ de una ley
  observada, su función de influencia es $Z(O)-EE(Z)$.
  La matriz $Sigma$ es una covarianza, no una función de influencia.
  Tampoco es automáticamente el gradiente canónico del valor $J$ en
  un modelo de MDP ni coincide con la influencia de DR.
]
#env-alias("prop:ch8-reinforce-if", kind: "proposition")

#thm-env("example", name: [Estado continuo y gradiente verificable], key: "ex:ch11-pg-ssch", es-sintetico: true)[
  Sea $S$ uniforme en $[-1,1]$, $pi_theta (1|s)=1/(1+exp(-theta s))$
  y recompensa abstracta $R=A S$. En $theta=0$, $p=1/2$ y el score
  es $S(A-1/2)$. El gradiente verdadero es
  $ EE(S^2)/4=1/12. $
  Sin baseline, la contribución es $Z=A S^2/2$, de varianza $13/720$.
  Con baseline $b(s)=s/2$, vale $Z_b=S^2/4$, de varianza $1/180$.
  Se obtiene usando $EE(S^2)=1/3$ y $EE(S^4)=1/5$. La reducción de
  varianza es $9/13$, aproximadamente 69.2%, en este modelo exacto.
  No se ha entrenado una red ni afirmado convergencia a una política óptima.
]
#env-alias("ex:ch8-pg-ssch", kind: "example")
#section-alias("sec:ch8-pg")

== Interpretar el intervalo en la decisión
<sec:ch11-langgraph>

=== Construcción de IC
<sec:ch11-ic-agente>

El agente registra objetivo, política, distribución inicial y unidad
independiente. Para DR de una decisión con episodios iid, usa la
contribución correcta del @ch:ope. Esta versión promedia también el estado inicial observado; puede utilizarse con $nu$ conocida, pero no se le atribuye automáticamente la eficiencia del modelo con $nu$ desconocida. Para aprovechar una ley inicial conocida debe especificarse la integración del término directo y la influencia del modelo correspondiente:
$ D_i=sum_a pi(a|S_i)hat(m)(S_i,a)+
  frac(pi(A_i|S_i),hat(b)(A_i|S_i))(R_i-hat(m)(S_i,A_i)). $
Entrena las funciones fuera del episodio evaluado y comprueba las
condiciones de la expansión. Calcula $overline(D)$, $s_D^2$ y
$overline(D) plus.minus z_(1-alpha/2)s_D/sqrt(n)$.
Para un episodio de varias decisiones usa su contribución secuencial
completa; para una trayectoria o un estimador sieve, la varianza y escala
se sustituyen por las justificadas para ese procedimiento.
#section-alias("sec:ch8-ic-agente")

=== Decisiones Guiadas por IC
<sec:ch11-decisiones>

Para comparar políticas, forme contribuciones pareadas
$D_i^Delta=D_i^("nueva")-D_i^("referencia")$. El intervalo de la
diferencia usa su varianza, no el solapamiento visual entre dos
intervalos marginales. La hipótesis de mejora relevante puede ser
$Delta>delta_0$ para un margen prefijado, no necesariamente $Delta>0$.

Un límite inferior unilateral por encima de $delta_0$ aporta evidencia
según el nivel y el diseño establecidos. No basta por sí solo para
aprobar un despliegue: permanecen el alcance causal, la población y
las restricciones de decisión. Repetir el análisis hasta que el límite
sea positivo requiere inferencia secuencial válida o un plan de análisis
que controle esas revisiones.

#verlanggraph
#section-alias("sec:ch8-decisiones")

=== Trazabilidad: Del Teorema al Componente
<sec:ch11-trazabilidad>

#mi-tabla(
  caption: [Correspondencia entre inferencia y componentes], key: "tab:ch11-trazabilidad",
  table(columns: (27%, 38%, 1fr), align: left, hl(),
    table.header([*Resultado*], [*Componente*], [*Alcance*]), hl(w: 0.6pt),
    [Expansión por episodio], [Contribuciones y varianza entre episodios.], [Política fija y resto controlado.],
    [CLT mixing], [Secuencia de influencia y varianza de largo plazo.], [Dependencia y momentos especificados.],
    [Bellman sieve], [Bases, momentos, inversión y sandwich.], [Información y aproximación controladas.],
    [SAVE], [Aprendizaje y evaluación por bloques ordenados.], [Procedimiento y condiciones originales.],
    [Comparación pareada], [Diferencias de contribuciones.], [Incluye covarianza entre políticas.],
    [Planificación de poder], [Varianza de la diferencia relevante.], [Aproximación para un diseño definido.], hl(),
  ),
)

#[
#set heading(numbering: none, outlined: false)
=== Hilo longitudinal: SSCH
]

#thm-env("example", name: [SSCH: intervalo y comparación pareada], key: "ex:ssch-cap11", es-sintetico: true)[
  Retome el entorno de dos visitas de @ex:ssch-cap10. La política
  objetivo toma acción uno con probabilidad $0.75$; la referencia
  con probabilidad $0.5$. Sus valores verdaderos son $1.425$ y $0.950$,
  respectivamente. Los modelos de evaluación se fijan de antemano.

  Para la referencia, use $hat(q)_1(a)=0.2+0.6a$ y
  $hat(q)_0(a)=0.1+0.8a+0.9(0.5)$. Sus contribuciones DR, junto con
  las del capítulo anterior, son:

  #table(columns: (auto, auto, auto, auto), align: right, hl(),
    table.header([*$(A_0,A_1)$*], [*Objetivo*], [*Referencia*], [*Diferencia*]), hl(w: 0.6pt),
    [$(0,0)$], [1.190], [0.670], [0.520],
    [$(0,1)$], [1.370], [1.030], [0.340],
    [$(1,0)$], [1.300], [0.870], [0.430],
    [$(1,1)$], [1.840], [1.230], [0.610], hl(),
  )

  Considere una realización de $n=100$ episodios iid en la que cada
  trayectoria aparece 25 veces. No se ha impuesto por diseño esa
  frecuencia. Para la política objetivo,
  $ hat(J)=1.425, quad s_D^2=frac(100,99)(0.061525), quad "SE" approx 0.02493. $
  Su intervalo normal aproximado del 95% es $[1.376,1.474]$.
  La varianza empírica de las diferencias es
  $s_Delta^2=(100/99)(0.010125)$, por lo que
  $ hat(Delta)=0.475, quad "SE"_Delta approx 0.01011, quad
    "IC"_(95%) approx [0.455,0.495]. $
  Este intervalo usa las diferencias dentro de los mismos episodios.
  El cálculo es reproducible a partir de la tabla; no demuestra
  cobertura exacta en cien episodios ni evidencia de superioridad clínica.
]

#[
#set heading(numbering: none, outlined: false)
=== De un intervalo a una afirmación revisable
]

La inferencia depende de una cadena de justificaciones: identificación,
objetivo, régimen muestral, expansión y varianza. La identidad de riesgo
y retorno del @ch:isomorfismo no sustituye ninguno de esos pasos.
El @ch:verificacion organiza el paso siguiente: relacionar el resultado con el cálculo que realiza un agente y registrar qué conclusión autoriza. Esa revisión conservará el objetivo, el régimen de datos y la forma de estimar la varianza que dieron sentido al intervalo.

== Ejercicios
<sec:ch11-ejercicios>

#exercise-env(key: "ex:ch11-ej1")[
  Para un AR(1) estacionario con innovaciones iid de varianza finita
  $tau^2$ y coeficiente $rho$ con $abs(rho)<1$, calcule varianza
  marginal y de largo plazo. Distinga el cálculo de covarianzas de
  las condiciones suficientes para aplicar un CLT. Compare $rho=0.95$
  y $rho=-0.95$.
]
#exercise-env(key: "ex:ch11-ej2")[
  Implemente HAC con pesos de Bartlett. Use la misma secuencia de
  contribuciones y varios rezagos máximos; describa sensibilidad y
  sesgos posibles. Explique por qué un resultado numérico estable
  no demuestra consistencia del estimador.
]
#exercise-env(key: "ex:ch11-ej3")[
  Para una diferencia con desviación por episodio $sigma_D=2$ y
  efecto $0.5$, calcule tamaños aproximados para poder 80% y 90%,
  nivel bilateral 5%. Con cien episodios, calcule el efecto detectable
  aproximado al 80%. Repita el planteamiento para dos grupos independientes.
]
#exercise-env(key: "ex:ch11-ej4")[
  Diseñe una simulación de cobertura con valor verdadero calculado por
  Bellman. Repita el ajuste completo en cada réplica y reporte sesgo,
  cobertura, longitud e incertidumbre Monte Carlo. Incluya un escenario
  con pesos concentrados y otro con sesgo de aproximación persistente.
]
#exercise-env(key: "ex:ch11-ej5")[
  Explique por qué SAVE no es una reescritura de DR. Para políticas
  distintas evaluadas en bloques, derive el término que separa un
  promedio de valores de bloque del valor de una política final.
  Compare con congelar una política y evaluarla en episodios independientes.
]

== Lecturas Propuestas
<sec:ch11-lecturas>

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Obligatorias
]

+ #cite(<shi2022statistical>, form: "prose"): distinguir evaluación fija,
  aproximación sieve y evaluación secuencial de políticas aprendidas;
  leer las hipótesis completas antes de aplicar su normalización.
+ #cite(<kallus2020double>, form: "prose"): modelo de trayectorias,
  razones marginales y eficiencia semiparamétrica.
+ #cite(<kallus2022efficiently>, form: "prose"): condiciones de evaluación
  eficiente en su régimen temporal específico.

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Complementarias
]

+ #cite(<newey1987hac>): construcción de covarianzas HAC y sus condiciones.
+ #cite(<bradley2005basic>): nociones de mixing y relaciones entre ellas.
+ #cite(<hall1992bootstrap>): fundamento y límites de procedimientos bootstrap.
+ #cite(<sutton2018reinforcement>): gradientes de política y relación entre
  evaluación, aproximación y optimización.
