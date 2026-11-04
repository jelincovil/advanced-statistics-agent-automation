#import "../plantilla.typ": *
#import "cap09_tabla_canonica.typ": tabla-garantias

= Un cálculo de verificación de garantías
<ch:verificacion>

Una garantía se aplica a un estimando, un experimento y un procedimiento.
No se aplica a un agente por el nombre de sus nodos. Este capítulo organiza
la revisión que conecta esos tres objetos con la decisión final. Un catálogo común permite seguir el alcance de cada resultado cuando interviene en partes distintas del agente.

La pregunta conductora es concreta: *¿qué conclusión está autorizada por
este resultado, para estos datos y esta implementación?* El resultado puede
ser exacto dentro de un modelo, asintótico bajo una secuencia de experimentos,
o una decisión de diseño sin garantía estadística propia. La representación
de Wald del @ch:isomorfismo preserva el riesgo en su familia de una decisión;
no reemplaza la identificación, la inferencia ni la validación del código.

*La ficha de una afirmación.* Registre el objetivo y la población; el modelo
paramétrico, semiparamétrico o no paramétrico; la unidad de muestreo y el
horizonte; el estimador y sus funciones auxiliares; el resultado citado y
sus hipótesis; la evidencia disponible; y la decisión que se pretende tomar.
Por ejemplo, «DR produce un IC válido» es incompleto: falta precisar qué
DR, qué régimen de datos y qué condiciones controlan su resto y varianza.

*Tres clases de evidencia.* Una igualdad algebraica, la pertenencia de
una implementación a una fórmula o una enumeración finita pueden verificarse
directamente. Las condiciones del diseño, como la aleatorización registrada,
requieren documentación. Los supuestos poblacionales, como ausencia de
confusión no medida, regularidad o tasas de aprendizaje, se justifican
mediante argumentos y análisis de sensibilidad; un diagnóstico favorable
no los convierte en hechos demostrados por la muestra.

El dictamen usa cuatro estados: *aplicable bajo supuestos declarados*,
*pendiente de justificación*, *no aplicable* y *regla de diseño*. Las marcas típicas
de filas («↔» / «↝» / no marcada) nunca sustituyen ese dictamen; solo acompañan la comprensión del lector. El primero
no significa que todos los supuestos poblacionales se hayan probado.
Si cambia la población, el horizonte, la política, la regla de parada o el
estimador, se revisa el dictamen. No se transforma una garantía ausente en
una garantía más débil sin demostrar también esta última.

*Protocolo de revisión.*
+ Fijar la afirmación: estimando, comparación, nivel y alcance temporal.
+ Identificar modelo, población, unidad independiente y mecanismo de datos.
+ Escribir el estimador realmente calculado, con sus ajustes y particiones.
+ Asociar un resultado del catálogo y enumerar todas sus hipótesis relevantes.
+ Separar comprobaciones ejecutables, evidencia del diseño y supuestos.
+ Determinar qué conclusión se sostiene y qué falta justificar.
+ Traducirla a una decisión con pérdida, margen o restricción prefijados.
+ Registrar versiones, evidencia, dictamen y causas de revisión.

#mi-figura(
  key: "fig:ch9-protocolo-verificacion",
  caption: [Revisión de una garantía: la evidencia incompleta conserva un dictamen pendiente, no una certificación.],
  block(width: 100%, inset: 8pt, stroke: 0.5pt + luma(180))[
    #align(center)[*Objetivo, modelo, datos y procedimiento*]
    #align(center)[$arrow.b$]
    #align(center)[*Resultado e hipótesis correspondientes*]
    #align(center)[$arrow.b$]
    #table(columns: (1fr, 1fr), inset: 6pt, stroke: none,
      [*Correspondencia y justificación suficientes*], [*Falta una condición o hay una contradicción*],
      [Dictamen condicionado; decisión según pérdida o margen.], [Pendiente o no aplicable; completar evidencia o cambiar procedimiento.],
    )
    #align(center)[$arrow.b$]
    #align(center)[*Registro del alcance y de las condiciones de revisión*]
  ],
)

La tabla relaciona cada resultado con la tarea en la que puede utilizarse y
con el alcance de su conclusión. Las secciones siguientes recorren esas
relaciones desde la información disponible hasta la decisión. Las vistas
locales del catálogo permiten consultar las condiciones pertinentes en cada
paso sin perder la referencia al resultado completo.

#include "cap09_tabla_canonica.typ"

== Conservar la información que necesita la decisión

La revisión comienza por los datos que recibe el agente y por lo que guarda de ellos. Para interpretar una estimación debemos poder reconstruir la unidad de observación, la información anterior a la acción y el mecanismo que produjo el registro.

=== Arquitectura de Nodos: Observación, Creencias, Decisión
<sec:ch1-arquitectura-nodos>

El nodo de observación recibe unidades definidas por el diseño: pacientes,
episodios completos o transiciones de una trayectoria. Registra procedencia,
acción tomada, resultado y mecanismo de asignación cuando corresponda.
Contar filas no determina el número de unidades independientes.

El nodo de inferencia calcula un estimador o una distribución posterior bajo
un modelo explícito. Debe devolver también el estimando, la escala de la
incertidumbre y las condiciones pendientes. El nodo de decisión utiliza esos
resultados junto con una pérdida o un margen prefijado. Un nodo adicional de
revisión conserva los motivos de abstención y las modificaciones humanas.

Un sistema de tipos puede exigir que cada resultado incluya esos campos;
no puede certificar por sí solo suficiencia, identificación causal o cobertura.
La arquitectura implementa el procedimiento que se ha justificado, y su
verificación requiere comprobar que el código coincide con él. #verlanggraph

=== El Estado como Estadístico Suficiente
<sec:ch1-estado-suficiente>

La suficiencia es una propiedad relativa a una familia de distribuciones.
Si $T(X)$ es suficiente para $theta$, la ley condicional de $X$ dado $T$
puede elegirse independiente de $theta$ bajo las condiciones correspondientes.
Esto permite reducir el experimento estadístico, pero no demuestra que $T$
sea un estado Markov suficiente para cualquier entorno secuencial.

En observaciones Bernoulli iid con tamaño fijo conocido, la suma de éxitos
es suficiente minimal para $theta in (0,1)$. Si el tamaño cambia, se registra
también cuántas unidades se observaron. Para un prior Beta fijo, sus parámetros
actualizados codifican éxitos y fracasos; no son una representación universal
de toda la información que necesita un agente.

#[
#set heading(numbering: none, outlined: false)
==== Ejemplo integrador: Agente de diagnóstico médico con asistencia del médico
<ex:ch1-diagnostico-medico-b>
]

*Modelo pedagógico sintético.* Suponga que se observan estados de enfermedad
confirmados $Y_i in {0,1}$ de personas comparables, con observaciones condicionalmente iid,
$Y_i|theta attach(tilde, t: "iid") "Bernoulli"(theta)$ y prior
$theta tilde "Beta"(a_0,b_0)$. No se trata de repetir un test imperfecto en
un mismo paciente. Ese otro problema requiere modelar sensibilidad,
especificidad y dependencia de las pruebas.

Con $s=sum_i Y_i$, el posterior es $"Beta"(a,b)$, donde
$ a=a_0+s, quad b=b_0+n-s. $
La probabilidad predictiva para una nueva persona sin otras covariables es
$p=EE(theta|Y)=a/(a+b)$ y la varianza posterior es
$ Var(theta|Y)=frac(a b,(a+b)^2(a+b+1)). $
Esta varianza describe incertidumbre sobre la prevalencia. No es
$Var_theta (hat(theta))$ ni la varianza predictiva de la enfermedad de la
nueva persona, que es $p(1-p)$.

Considere dos acciones abstractas. Tratar a una persona sana cuesta $c$;
no tratar a una persona enferma cuesta $d$; las otras pérdidas se fijan en
cero. La pérdida se escribe $L(Y,a)$, con $Y$ binaria; no se confunde ese
estado con la prevalencia continua $theta$. Las pérdidas predictivas son
$ ell("tratar")=c(1-p), quad ell("no tratar")=d p. $
Por tanto, tratar minimiza la pérdida entre esas dos acciones si
$ p>frac(c,c+d), $
con indiferencia en la igualdad. El umbral disminuye si aumenta el costo
de omitir una enfermedad. Es una comprobación útil del sentido de la fórmula.

Tome prior $"Beta"(1,1)$ y 12 enfermos confirmados en 100 observaciones.
Entonces $a=13$, $b=89$, $p=13/102 approx 0.12745$ y la desviación posterior
es aproximadamente $0.03286$. Con $c=1,d=9$, el umbral es $0.10$;
las pérdidas son $89/102 approx 0.87255$ al tratar y
$117/102 approx 1.14706$ al no tratar. Dentro de este modelo, la primera
acción tiene menor pérdida esperada. No es una recomendación clínica.

Si se añade «consultar» cuando la desviación posterior supera $0.03$,
esta observación se deriva a revisión. Esa regla es una restricción de
diseño; no es la regla Bayes de dos acciones que acabamos de derivar.
Para justificar una tercera acción óptima hay que especificar el costo
de consultar, la información que aporta y las decisiones posteriores.

#mi-figura(
  caption: [Ejemplo sintético: separar actualización, comparación de pérdidas y revisión.],
  key: "fig:agente-diagnostico-b",
  block(width: 100%, inset: 9pt, stroke: 0.5pt + luma(180))[
    #align(center)[Datos confirmados y mecanismo de observación]
    #align(center)[$arrow.b$]
    #align(center)[Posterior Beta; probabilidad predictiva; pérdidas por acción]
    #align(center)[$arrow.b$]
    #table(columns: (1fr, 1fr), stroke: none, inset: 6pt,
      [*Regla de decisión especificada*], [*Restricción o supuesto pendiente*],
      [Comparar pérdidas y registrar el resultado.], [Derivar a revisión y registrar el motivo.],
    )
  ],
)

#tabla-garantias(("BETA", "POST", "DEC", "BAYES", "HUM", "SEQ", "LOG"),
  key: "tab:ch1-nodos-diagnostico-b", caption: [Componentes y alcance del ejemplo Beta–Bernoulli.])

#[
#set heading(numbering: none, outlined: false)
==== Ejemplo práctico: Agente Bernoulli-Beta
<ex:ch1-bernoulli-beta-b>
]

En un ejemplo de clics, mantenga el mismo modelo con prior
$"Beta"(1,1)$ y observe 18 clics en 100 exposiciones comparables e
condicionalmente independientes dado $theta$. El posterior es $"Beta"(19,83)$ y
$p=19/102 approx 0.18627$. Si mostrar el producto produce beneficio uno
cuando hay clic y cuesta $0.15$ en cada exposición, su beneficio predictivo
es $p-0.15 approx 0.03627$, frente a cero al no mostrarlo.

La decisión favorable se refiere a ese modelo, costo y población. Si las
exposiciones fueron seleccionadas por una política adaptativa o cambió la
población, la verosimilitud y el objetivo deben revisarse. La actualización
conjugada puede seguir siendo algebraicamente correcta para una
verosimilitud especificada y, sin embargo, describir mal el experimento.

=== Incertidumbre y Criterios de Decisión
<sec:ch1-incertidumbre-decision>

Una baja varianza no implica bajo sesgo, buena predicción individual ni
validez causal. Un IC frecuentista tiene una propiedad de cobertura bajo
un diseño; una distribución posterior expresa incertidumbre condicional
en un modelo y un prior. Sus interpretaciones no se intercambian.

El criterio de decisión añade una pérdida, un margen de mejora o una
restricción. Un intervalo estrecho puede estar enteramente en una región
desfavorable; por ello su anchura no basta para autorizar una acción.
Repetir análisis hasta lograr el criterio requiere controlar la regla de
parada. En la incrustación del @ch:isomorfismo, la igualdad es
$J_theta (pi_delta)=-R(theta,delta)$ para el retorno integrado de una decisión.
No es una identidad entre cualquier intervalo y una política óptima.

=== Registrar las condiciones de la representación
<sec:ch1-trazabilidad>

Estas filas distinguen propiedades del modelo, compresión de observaciones y reglas de decisión. Leerlas por separado permite identificar qué justifica la representación de los datos y qué criterio se utiliza para elegir una acción.

#tabla-garantias(("MOD", "SUF", "DEC", "EXP", "MOM", "MSE"),
  key: "tab:ch1-trazabilidad", caption: [Modelo, información y decisión: vista del catálogo.])

=== Conexión con la Correspondencia Estructural
<sec:ch2-isomorfismo>

Reducir una observación y representar una regla en un MDP son operaciones
distintas. La primera necesita suficiencia y una clase de acciones; la segunda
copia la regla en la familia construida en el @ch:isomorfismo.

#thm-env("proposition", name: [Suficiencia y Políticas Óptimas], key: "prop:ch2-suficiencia-politicas")[
  Suponga espacios estándar de Borel y un núcleo condicional común
  $K(dif x|t)$ de $X$ dado $T=t$, independiente del parámetro.
  Para una regla aleatorizada $delta(dif a|x)$ con pérdida integrable,
  defina $delta_T (dif a|t)=integral delta(dif a|x)K(dif x|t)$.
  Entonces $R(theta,delta_T)=R(theta,delta)$ para todo $theta$.
  La comparación se hace en la clase de reglas aleatorizadas.
]
#proof-env[
  Integrar la pérdida bajo $delta_T$ y después sobre la distribución de $T$
  reproduce, por esperanza iterada, la integral original bajo $X$ y $delta$.
  La independencia del núcleo respecto de $theta$ hace implementable la regla.
  Si se exige una acción determinista, esta construcción puede salir de la
  clase permitida. Para acciones en un conjunto convexo y pérdida convexa,
  la media condicional, cuando existe y pertenece al espacio de acciones,
  da riesgo no mayor por Jensen, pero no igualdad automática para toda regla.
]

La aleatorización de esta proposición no amplía silenciosamente el teorema
central, que se enuncia para reglas deterministas. Con acciones discretas,
la media de dos acciones puede no ser una acción admisible.

=== El Estado del Agente como Estadístico Suficiente
<sec:ch2-estado-suficiente>

Para un modelo iid exponencial, el resumen puede actualizarse como
$T_(n+1)=T_n+t(X_(n+1))$. Debe conservarse el tamaño muestral cuando participa
en la verosimilitud. El estado operacional puede necesitar además tiempos,
acciones, probabilidades de asignación y datos para auditoría.

En un sistema longitudinal, la suficiencia para un parámetro estático no
implica suficiencia predictiva de la siguiente transición. Esa segunda
propiedad exige especificar la dinámica y la información disponible antes
de actuar. Un resumen válido para estimar prevalencia puede ser insuficiente
para elegir tratamientos según la historia de cada paciente.

=== Separación Conceptual: Estado versus Contexto
<sec:ch2-estado-contexto>

Basu establece independencia entre un estadístico suficiente completo y
un estadístico ancilar bajo sus hipótesis. Ancilar significa que su ley no
depende del parámetro; no significa «campo de contexto» ni «variable que
parece secundaria».

Una fecha de medición puede revelar un cambio de población; una covariable
puede ser necesaria para identificar un efecto. No deben descartarse por
llamarlas contexto. La separación de memoria es una decisión de ingeniería
que debe justificarse mediante el modelo y las necesidades de trazabilidad.

=== Diseño de Memoria Eficiente
<sec:ch2-memoria>

Una familia exponencial iid con estadístico aditivo de dimensión fija $k$
permite almacenar $O(k)$ números y actualizar sus sumas en $O(k)$ operaciones.
Esto no implica memoria constante en bits: los contadores necesitan más
bits al crecer $n$, y conservar datos o procedencia tiene otro costo.

La minimalidad estadística compara la información contenida en estadísticas
suficientes, salvo conjuntos nulos. No determina un formato óptimo de archivos
ni permite borrar registros necesarios para detectar errores de medición,
cambios de modelo o decisiones adaptativas.

=== Completitud y Unicidad de la Representación
<sec:ch2-completitud-agentes>

La completitud establece que una función integrable del estadístico con
esperanza cero para todos los parámetros es nula casi seguramente. Junto
con suficiencia e insesgadez, Lehmann–Scheffé da unicidad del estimador UMVUE,
cuando existe y tiene varianza finita.

No es una garantía de representación computacional mínima. Si $T$ es
completo, almacenar $(T,T)$ no destruye esa propiedad y, sin embargo, duplica
un campo. Tampoco compara el UMVUE con todos los estimadores sesgados bajo
error cuadrático medio, ni asegura buen comportamiento fuera del modelo.

=== Equivarianza en el Comportamiento del Agente
<sec:ch2-equivarianza-agentes>

La equivarianza exige que transformar datos y después decidir coincida con
decidir y transformar la acción según la regla correspondiente. Antes de
imponerla deben comprobarse las transformaciones del modelo y de la pérdida.
Cambiar la unidad monetaria, por ejemplo, exige transformar también costos
y umbrales.

Restringir la búsqueda a reglas equivariantes puede simplificar el problema;
conservar optimalidad requiere un resultado adicional sobre esa clase y
ese criterio. La simetría visual de una arquitectura no lo demuestra.

=== Qué respalda la reducción de datos
<sec:ch2-trazabilidad>

#tabla-garantias(("SUF", "MIN", "COM", "BAS", "EQU", "RED"),
  key: "tab:ch2-trazabilidad", caption: [Reducción de información y límites de su uso en un estado.])

=== Conexión con la Correspondencia Estructural
<sec:ch3-isomorfismo>

El valor de una política fija puede ser un funcional de un parámetro del
entorno. La información relevante es la del experimento observado completo,
no necesariamente la de una recompensa aislada.

#thm-env("proposition", name: [Estimación de Valores y Cramér-Rao], key: "prop:ch3-valor-cr")[
  En un experimento paramétrico regular con $n$ episodios iid, sea
  $g(theta)=J_theta (pi)$ diferenciable, con política fija. Si $hat(J)$
  es insesgado para $g(theta)$, tiene varianza finita y se cumplen las
  condiciones de diferenciación e información, entonces
  $ Var_theta (hat(J))>=frac(1,n)nabla g(theta)^T I_1(theta)^(-1)nabla g(theta), $
  donde $I_1$ es la información de Fisher invertible de un episodio.
  Para parámetro escalar, la cota es $(g'(theta))^2/(n I_1(theta))$.
]
#proof-env[
  El score total tiene varianza $n I_1$ y su covarianza con $hat(J)$
  es $nabla g$, al derivar la identidad de insesgadez. La desigualdad
  de covarianzas da la cota. La derivada del funcional no puede omitirse.
]

#thm-env("proposition", name: [Rao-Blackwell para Q-Estimadores], key: "prop:ch3-rb-q")[
  Para política, estado y acción fijos, sea $U$ un estimador de
  $q^pi (s,a)$ con segundo momento finito. Si $T$ es suficiente y
  $tilde(U)=EE(U|T)$ puede elegirse sin usar el parámetro desconocido,
  entonces tiene la misma esperanza y varianza no mayor que $U$.
]
#proof-env[
  La esperanza iterada conserva la media; la descomposición
  $Var(U)=Var(EE(U|T))+EE(Var(U|T))$ prueba la reducción. La suficiencia
  permite una versión implementable del condicionamiento; la identidad
  de varianzas, por sí sola, no proporciona cómo calcularla.
]

== Elegir un objetivo y un estimador

Una representación adecuada de los datos permite formular qué se pretende aprender. El valor de una política puede ser un funcional de un modelo paramétrico o de una ley más amplia; esa elección determina cómo se estudian sesgo, varianza y eficiencia.

=== Estimación de Funciones de Valor
<sec:ch3-estimacion-valor>

Defina primero política, población inicial, horizonte y descuento. En un
modelo paramétrico regular, $J=g(theta)$ puede estimarse por sustitución y
analizarse mediante delta. En un modelo semiparamétrico se estudia la
regularidad del funcional y su influencia. En un modelo no paramétrico,
no todo valor puntual ni toda función de valor admite tasa raíz de $n$.

La representación de riesgo del @ch:isomorfismo conserva una cantidad
esperada; no produce una expansión asintótica del estimador de esa cantidad.

=== El Trade-off Sesgo-Varianza en Agentes
<sec:ch3-tradeoff>

Con segundo momento finito,
$ EE((hat(J)-J)^2)=Var(hat(J))+(EE(hat(J))-J)^2. $
Una estimación estable puede estar sistemáticamente desplazada. Una
regularización puede disminuir el ECM a costa de sesgo, aunque excluya
al estimador de una comparación UMVUE.

Para una decisión importa además la distancia al umbral. Dos estimadores
con ECM parecido pueden dar frecuencias distintas de seleccionar una
política inferior. La evaluación debe incluir el objetivo inferencial y
la pérdida de la decisión, sin confundir ambas métricas.

=== Rao-Blackwellización de Estimadores Monte Carlo
<sec:ch3-rb-mc>

Un retorno generado bajo la política objetivo, desde el estado y acción
especificados, estima insesgadamente el valor de horizonte finito. Un
retorno infinito necesita integrabilidad. Si se trunca a $H$ y
$abs(R_t)<=B$, con $0<gamma<1$, el sesgo absoluto frente al valor infinito
se acota por $B gamma^H/(1-gamma)$.

Condicionar un estimador en un resumen con ley condicional conocida puede
reducir varianza; sustituir esa esperanza por una regresión aprendida no
hereda automáticamente el resultado exacto. Una evaluación off-policy
requiere, además, corregir la distribución de las acciones y estados.

=== Límites de Precisión: Cramér-Rao en Agentes
<sec:ch3-limites>

*Ejemplo paramétrico calculable.* Observe $n$ recompensas Bernoulli iid de
probabilidad $theta$ y defina $J=2theta$. La información por observación es
$I_1(theta)=1/(theta(1-theta))$. La cota correcta es
$ Var(hat(J))>=frac(4theta(1-theta),n). $
El estimador $2 overline(X)$ la alcanza. En $theta=0.5$ y $n=100$, la
varianza es $0.01$; omitir la derivada daría $0.0025$, cuatro veces menor.

Para exigir varianza no mayor que $epsilon.alt^2$, la cota proporciona una
condición necesaria sobre $n$ dentro de la clase regular insesgada. Solo
cuando se sabe que el estimador alcanza la cota puede usarse como condición
suficiente de varianza. En este ejemplo, $n>=100$ controla la varianza por
$0.01$ uniformemente en $theta$. Esto no es todavía una garantía de cobertura
ni de potencia de un contraste.

=== Qué precisión puede atribuirse al estimador
<sec:ch3-trazabilidad>

#tabla-garantias(("RB", "LS", "CR", "MSE", "MLE"),
  key: "tab:ch3-trazabilidad", caption: [Estimación: clase comparada, precisión y sesgo.])

== Comparar políticas con un error de decisión declarado

La precisión de una estimación adquiere un significado distinto cuando se usa para elegir entre políticas. La comparación debe incorporar el diseño, la dependencia entre estimaciones y el número de decisiones que se apoyarán en los mismos datos.

=== A/B Testing de Políticas
<sec:ch4-ab-testing>

Para dos políticas fijas, defina $Delta=J(pi_1)-J(pi_0)$ y un margen
relevante $delta_0$. Contraste $H_0:Delta<=delta_0$ frente a
$H_1:Delta>delta_0$. En un ensayo aleatorizado por episodios, el análisis
respeta esa unidad; en OPE, la comparación requiere además identificación,
soporte y la expansión del estimador utilizado.

El nivel controla falsos rechazos bajo la nula según el diseño. No es la
probabilidad posterior de que la política sea peor después de observar un
rechazo. La potencia depende de una alternativa concreta, del tamaño y de
la varianza. Fijar un nivel pequeño no asegura potencia suficiente.

=== Intervalos de Confianza para Diferencias de Valor
<sec:ch4-ic-delta>

Cuando las dos políticas se evalúan sobre los mismos episodios, forme
$D_i^Delta=D_i^("nueva")-D_i^("referencia")$ y estime la varianza de esas
diferencias. Dos intervalos marginales que se solapan no equivalen a un
contraste de la diferencia. Un límite inferior válido superior al margen
aporta evidencia bajo el diseño especificado; un intervalo que contiene
cero no demuestra equivalencia.

*Transferencia por imagen.* Si $C$ cubre un parámetro $theta$ y $g$ es un
mapa conocido para una política fija, entonces
$ theta in C => g(theta) in g(C). $
Por tanto, $g(C)$ tiene cobertura al menos igual a la de $C$. En dimensión
mayor o con $g$ no monótona, transformar solo dos extremos puede fallar.
Por ejemplo, para $g(theta)=theta^2$ y $C=[-1,2]$, la imagen es $[0,4]$;
usar únicamente los cuadrados de los extremos produce $[1,4]$ y pierde cero.

=== Comparación de Múltiples Políticas
<sec:ch4-multiples-politicas>

Bonferroni y Holm controlan FWER con p-valores válidos; no eliminan todo
falso positivo. Benjamini–Hochberg controla FDR bajo las condiciones de
dependencia admitidas. FDR no es una probabilidad de error individual ni
una autorización automática para desplegar la mejor variante observada.
Seleccionar políticas y evaluarlas con los mismos datos introduce otra
fuente de selección que también debe tratarse.

Repetir un test de Wald de tamaño fijo en cada consulta no produce un
contraste secuencial válido. El SPRT es un contraste secuencial de razón
de verosimilitudes, no un test de rangos. Su aplicación exige hipótesis,
modelo y fronteras apropiados; no justifica cualquier regla de parada.
Puede usarse una secuencia de confianza válida para todo tiempo o un plan
de análisis con control de revisiones, según el experimento.

En la ruta bayesiana, las odds posteriores son el factor de Bayes por las
odds previas. Para dos hipótesis y pérdidas $c$ por falsa adopción y $d$ por
falsa omisión, se elige la alternativa cuando las odds posteriores superan
$c/d$, bajo esa matriz de pérdidas. El factor de Bayes aislado no elimina
el prior, la pérdida ni el mecanismo de observación. Tampoco otorga por sí
solo control frecuentista de error bajo parada opcional.

=== Qué error controla la comparación
<sec:ch4-trazabilidad>

#tabla-garantias(("NP", "UMP", "CI", "FWER", "FDR", "POWER", "SEQ"),
  key: "tab:ch4-trazabilidad", caption: [Contrastes, multiplicidad y revisiones temporales.])

== Relacionar el intervalo con su régimen de muestreo

La forma del estimador no determina por sí sola cómo cuantificar su incertidumbre. El remuestreo, las aproximaciones normales y las transformaciones de conjuntos de confianza deben conservar el objetivo y la estructura de los datos.

=== Cuantificación de Incertidumbre vía Bootstrap
<sec:ch5-bootstrap-agentes>

Para una media de retornos de episodios iid, el bootstrap remuestrea
*episodios completos*. Para comparar políticas se conserva el emparejamiento
dentro de cada episodio. Si el estimador aprende modelos auxiliares, se
reajusta el procedimiento o se justifica una aproximación basada en su
influencia; fijar todos los ajustes cambia lo que se remuestrea.

Una trayectoria larga requiere bloques u otro método válido para la
dependencia. Un funcional no regular puede invalidar el bootstrap ordinario.
El número de réplicas controla el error Monte Carlo del remuestreo, no el
sesgo ni la validez del método. Un refinamiento de orden superior requiere
más condiciones que un CLT y una varianza finita.

=== Intervalos de Confianza para Decisiones
<sec:ch5-ic-decisiones>

Separe tres preguntas: si el intervalo es válido para el estimando, si su
precisión es suficiente y si la comparación supera el margen de decisión.
Un intervalo estrecho no repara falta de soporte ni una población incorrecta.

Si el procedimiento recoge más datos cuando la anchura es grande, debe
analizarse también esa regla de parada. La alternativa de congelar el diseño
y usar un nuevo conjunto independiente de evaluación cambia el experimento
y debe quedar registrada. En ambos casos, el dictamen es específico de la
regla completa, no de una sola fórmula de error estándar.

=== Incertidumbre Epistémica versus Aleatoria
<sec:ch5-epistemica>

En una media regular de unidades iid, la varianza de estimación puede ser
del orden $1/n$, mientras que la dispersión de un retorno individual no
desaparece. Esa distinción ayuda a separar precisión inferencial de riesgo
predictivo.

No toda incertidumbre epistémica disminuye como $1/n$: identificación
parcial, sesgo de modelo, dependencia fuerte y problemas no regulares pueden
impedirlo. Más datos del mismo mecanismo no resuelven por sí solos confusión
no medida ni falta de acciones observadas.

=== Cómo se justifica el intervalo
<sec:ch5-trazabilidad>

#tabla-garantias(("CLT", "DELTA", "GC", "DON", "BOOT", "BT"),
  key: "tab:ch5-trazabilidad", caption: [Resultados asintóticos y remuestreo: condiciones antes que fórmulas.])

== Revisar las funciones auxiliares y el resto de estimación

En la ruta semiparamétrica, el objetivo puede ser escalar mientras que sus modelos auxiliares son complejos. La revisión debe seguir la influencia utilizada, la identidad de centrado y los errores que permanecen al estimar esos componentes.

=== OPE como Problema Semiparamétrico
<sec:ch6-ope-agentes>

OPE puede formularse en modelos paramétricos, semiparamétricos o no
paramétricos. La clasificación depende de las restricciones sobre la ley,
no de que se use una red neuronal. Un funcional escalar de una ley no
paramétrica puede analizarse con herramientas semiparamétricas de influencia
y eficiencia, si es regular.

Para un mismo valor $J(pi)$, un modelo paramétrico del entorno permite una
ruta por verosimilitud y delta; un modelo flexible de funciones auxiliares
requiere controlar el resto de una expansión; estimar una función completa
puede exigir tasas y sesgos distintos. Cada ruta tiene su propio espacio
comparado y su propia cota. El modelo Markov por tiempo del @thm:ch6-kallus
no se sustituye por uno estacionario infinito sin revisar la influencia.

=== Diseño de Estimadores DR
<sec:ch6-dr-agentes>

Para una decisión, observe episodios iid $O=(S,A,R)$ con política de registro
$b(a|s)$ y política objetivo fija $pi(a|s)$. Sea
$m(s,a)=EE(R|S=s,A=a)$ y
$J=EE(sum_a pi(a|S)m(S,a))$. La interpretación como intervención requiere
las condiciones de identificación del problema. Con ajustes externos al
episodio evaluado, la contribución correcta es
$ D(O;hat(m),hat(b))=sum_a pi(a|S)hat(m)(S,a)
  +frac(pi(A|S),hat(b)(A|S))(R-hat(m)(S,A)). $
El término directo promedia sobre las acciones de la política objetivo;
no es simplemente $hat(m)(S,A)$.

Para funciones fijadas $tilde(m),tilde(b)$, denominadores positivos y
cantidades integrables, la esperanza condicional y la suma sobre acciones dan
$ EE(D)-J=EE(sum_a pi(a|S)
  frac(tilde(b)(a|S)-b(a|S),tilde(b)(a|S))
  (tilde(m)(S,a)-m(S,a))). $
Así se ve la cancelación cuando uno de los dos auxiliares es correcto.
La consistencia muestral necesita además convergencia y control de las
fluctuaciones. Para varios tiempos, se usa la contribución secuencial o
marginal apropiada del @ch:ope, no una copia de la fórmula de una decisión.

=== Ortogonalidad y Robustez
<sec:ch6-robustez>

La identidad anterior muestra un resto de producto. Con propensiones ajustadas uniformemente alejadas de cero en el soporte objetivo y normas compatibles, su magnitud se controla por una constante por el producto
de errores de los auxiliares. Para que no afecte un CLT a escala raíz de $n$,
ese producto debe ser $o_P (n^(-1/2))$, junto con las demás condiciones de la
expansión. No basta que ambos modelos parezcan razonables.

Como ilustración de tasas, errores $O_P (n^(-0.30))$ y $O_P (n^(-0.25))$
producen un producto $O_P (n^(-0.55))$, despreciable frente a $n^(-1/2)$.
Dos errores meramente $O_P (n^(-0.25))$ solo dan $O_P (n^(-1/2))$, que no
asegura el pequeño orden requerido. Cross-fitting ayuda a controlar un
término empírico; no demuestra estas tasas ni elimina falta de soporte.

Los trabajos de #cite(<chernozhukov2018double>) y #cite(<kallus2020double>)
desarrollan resultados para modelos y procedimientos especificados. La
aplicación debe documentar el que corresponde; «usa ML» no es una hipótesis
suficiente. Eficiencia, ortogonalidad y doble robustez son propiedades
relacionadas, pero no equivalentes.

=== Qué aporta la construcción semiparamétrica
<sec:ch6-trazabilidad>

#tabla-garantias(("MOD", "TAN", "EIF", "BOUND", "ORTH", "DR", "DML"),
  key: "tab:ch6-trazabilidad", caption: [Modelo, influencia y condiciones de inferencia con aprendizaje auxiliar.])

=== Reunir la evidencia de una evaluación
<sec:ch12-trazabilidad>

El mapa reúne rutas distintas: decisión de Wald, planificación dentro de un
MDP, evaluación de políticas e inferencia. No son eslabones que puedan
intercambiarse. En particular, el sandwich de Bellman sieve, SAVE y la
varianza de contribuciones DR por episodio responden a procedimientos
diferentes, como se explicó en el @ch:inferencia.

#tabla-garantias(("WALD", "BAYES", "MM", "EMB", "BELL", "VI", "DR", "CLT", "SIEVE", "SAVE", "CI", "BOOT"),
  key: "tab:ch12-trazabilidad", caption: [Mapa de rutas: representación, planificación e inferencia.])

#thm-env("note", name: [Propiedades de Trazabilidad], key: "prop:ch12-trazability")[
  Un registro enlazado permite localizar la justificación de una decisión,
  reproducir su cálculo si se conservan los insumos y detectar cambios en
  sus condiciones. No demuestra verdad del modelo, cobertura empírica
  universal ni corrección del software. La reproducibilidad requiere datos
  o generador, código, versiones, parámetros y resultados contrastables.
  Un hash identifica bytes; no certifica el significado de una garantía.
]

#thm-env("example", name: [Trazabilidad en SSCH], key: "ex:ssch-trazability", es-sintetico: true)[
  Retome el ejemplo de dos visitas de @ex:ssch-cap11. El objetivo es la
  diferencia entre una política que toma acción uno con probabilidad
  $0.75$ y una referencia con probabilidad $0.5$, con descuento $0.9$.
  Hay cien episodios iid de un entorno sintético, con modelos de evaluación
  fijados previamente y política de registro conocida. El horizonte es
  finito: no se utiliza el resultado sieve de horizonte infinito.

  *Modelo y datos.* En cada visita, el registro elige acciones con
  probabilidad $0.5$ y la recompensa sintética es la acción. Los episodios
  se reinician independientemente. Las cuatro historias de acciones son
  equiprobables; la muestra considerada tiene 25 de cada una como
  realización posible, no como cuota impuesta por el diseño.

  *Estimador.* Las contribuciones pareadas de diferencia son
  $0.520,0.340,0.430,0.610$, cada una repetida 25 veces. Por ello,
  $ hat(Delta)=0.475, quad
    s_Delta^2=frac(100,99)(0.010125), quad
    "SE"=sqrt(s_Delta^2/100) approx 0.010113. $
  Su media poblacional es $0.475$ y su varianza poblacional $0.010125$;
  se verifican enumerando las cuatro historias. No se necesita invocar
  eficiencia semiparamétrica para justificar el CLT de estas contribuciones
  fijas, acotadas e independientes entre episodios.

  *Garantía inferencial.* La ruta del catálogo es DR → CLT → CI. El IC
  bilateral normal aproximado al 95% es $[0.455,0.495]$. La propiedad
  afirmada es asintótica; el cálculo de cien episodios no prueba cobertura
  exacta. La varianza pareada conserva la covarianza entre políticas.

  *Decisión.* Suponga un margen prefijado $delta_0=0.40$ y contraste
  unilateral al 5%. El límite inferior correspondiente es
  $ 0.475-1.64485(0.010113) approx 0.45837. $
  Supera el margen. Bajo el experimento y la aproximación declarados,
  el dictamen es evidencia de mejora superior a $0.40$ en recompensa
  sintética. No es una conclusión clínica ni una garantía de mejora
  en otra población.

  *Qué invalida o limita el dictamen.* Reutilizar los cien episodios
  para seleccionar la política, detenerse al obtener significación,
  perder soporte o sustituir episodios por transiciones dependientes
  obliga a revisar la inferencia. Si cambia solo el margen a $0.47$,
  manteniendo todo lo demás, el límite inferior ya no lo supera:
  no hay evidencia suficiente de esa mejora mayor. Cambiar el criterio
  después de observar resultados tampoco conserva el análisis prefijado.
]

*Aplicación del mismo esquema a un modelo paramétrico.* En el ejemplo
$J=2theta$, la ruta es MOD → CR y, para inferencia, una construcción de IC
válida para $theta$ seguida de IMAGE. En la ruta semiparamétrica DR, la
identidad de producto debe acompañarse del control de errores. En una
estimación no paramétrica de $V(s)$ sobre muchos estados, se añaden sesgo
de aproximación y requisitos de uniformidad. El nombre «valor» no permite
usar el mismo certificado para los tres problemas.

== Recuperar la justificación de cada componente
<app:tab-trazabilidad>

La vista final reúne resultados que intervienen en varias tareas del agente. Los componentes son funciones conceptuales que pueden implementarse en
LangGraph u otro sistema. La herramienta de orquestación no modifica las
hipótesis estadísticas. Las condiciones de cada fila se leen junto con
el resultado completo y con la ficha de la aplicación.

#tabla-garantias(("EXP", "SUF", "RB", "LS", "CR", "NP", "FDR", "DON", "ORTH", "CC", "ADM", "BELL", "PI", "EMB", "IS", "DR", "EIF", "SIEVE", "DML"),
  key: "tab:app-trazabilidad", aliases: ("tab:trazabilidad-completa",),
  caption: [Resultados y componentes: vista operacional del catálogo canónico.])

Para cerrar una revisión, el agente debe poder reconstruir qué se estimó,
con qué datos, qué hipótesis se declararon, qué resultado se aplicó y por
qué la decisión respeta su alcance. Una condición no justificada permanece
visible. Esa disciplina prepara el análisis de casos y despliegue sin
presentar una correspondencia matemática acotada como garantía general.
