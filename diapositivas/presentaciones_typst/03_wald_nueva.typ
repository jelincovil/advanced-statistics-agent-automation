// Clase 3 reconstruida desde cap02_wald.typ y prototipo_wald.typ.
// SSCH sintético: ninguna recomendación clínica.
#import "tema_clases.typ": s
#set document(title: "Clase 3 — Teoría de decisión de Wald")
#set page(width: 13.333in, height: 7.5in, margin: (x: 0.72in, y: 0.46in))
#set text(font: "Liberation Sans", size: 19pt, fill: rgb("#18253B"))

#s(1, 49, "APERTURA", "Una estimación no elige por sí sola", [

Dos reglas pueden usar la misma estimación y escoger acciones distintas si las pérdidas de los errores difieren.
#v(0.28in)
Pregunta: ¿qué datos, acciones y consecuencias debemos fijar antes de afirmar que una regla es mejor?

], "Pedir tres respuestas y traducirlas a modelo, clase de reglas y pérdida. Tiempo orientativo: 5 min.", "Cap. 2, apertura")
#s(2, 49, "OBJETIVOS", "Qué resolveremos", [

+ Definir regla determinista y aleatorizada, riesgo y dominancia.
+ Calcular una regla Bayes por pérdida posterior.
+ Certificar una regla minimax mediante un riesgo constante.
+ Resolver el SSCH sintético bajo dos clases de reglas.

], "La respuesta del taller debe identificar siempre la clase de comparación. Tiempo orientativo: 5 min.", "Cap. 2, sec:ch7-teoria y ex:ssch-cap07")
#s(3, 49, "RUTA", "180 minutos, un hilo", [

#table(columns: (2fr,1fr), inset: 7pt,
  [Motivación y conceptos], [60 min],
  [Demostración Bernoulli], [30 min],
  [Descanso], [15 min],
  [Taller SSCH], [45 min],
  [Discusión y síntesis], [30 min],
)

], "Apertura 15, conceptos 45, ejemplo 30, pausa 15, taller 45, discusión 20 y cierre 10. Tiempo orientativo: 5 min.", "PLAN_PRESENTACIONES_TYPST.md")
#s(4, 49, "DEFINICIÓN", "El problema estadístico de decisión", [

#align(center)[$cal(E)=(Theta, cal(X), (P_theta)_(theta in Theta), cal(A), L).$]
#v(0.2in)
$theta$ indexa modelos; $X tilde P_theta$ es la observación; $a in cal(A)$ es la acción; $L(theta,a)$ mide la pérdida.
#v(0.14in)
Se requieren reglas medibles y riesgos finitos.

], "No omitir Pθ: sin ley de X no se calcula riesgo. El libro admite pérdida no negativa o suficiente integrabilidad. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-problema")
#s(5, 49, "DEFINICIÓN", "θ desconocido, X observado", [

La regla utiliza la información que llega antes de decidir:
#align(center)[$delta:cal(X) -> cal(A).$]
#v(0.18in)
Una regla que elige la acción usando el verdadero $theta$ define otro problema.

], "Dibujar θ→Pθ→X→δ(X)→acción. θ determina la ley pero no entra como dato del decisor. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-regla")
#s(6, 49, "PÉRDIDAS", "Qué cuenta como error", [

#table(columns: (1fr,1.5fr,1.4fr), inset: 5pt,
  table.header([Tipo], [Pérdida], [Pregunta]),
  [Cuadrática], [$(a-psi(theta))^2$], [precisión de estimación],
  [Absoluta], [$abs(a-psi(theta))$], [mediana posterior],
  [Clasificación], [$1$ si $a != g(theta)$], [error de decisión],
)

], "La pérdida debe tener unidad e interpretación; distintas pérdidas cambian la regla preferida. Tiempo orientativo: 2 min.", "Cap. 2, ex:ch7-perdidas")
#s(7, 49, "REGLAS", "Regla determinista", [

Una regla $delta$ asigna una acción a cada posible observación.
#v(0.18in)
En un problema finito, puede escribirse como tabla $x -> delta(x)$.
#v(0.18in)
La comparación se hace dentro de una clase declarada $cal(D)$.

], "Preguntar si dos reglas que coinciden solo en la muestra observada son la misma regla: no necesariamente. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-regla")
#s(8, 49, "REGLAS", "Regla aleatorizada", [

Un kernel $d(a|x)$ da la probabilidad de acción después de observar $x$.
#align(center)[$d(a|x) >= 0, quad sum_a d(a|x)=1.$]
#v(0.18in)
El azar de la regla es independiente del parámetro; no aporta información sobre $theta$.

], "Mostrar que la clase aleatorizada contiene las reglas deterministas como casos con probabilidad cero o uno. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-regla")
#s(9, 49, "RIESGO", "Promediar sobre la muestra", [

Para regla determinista:
#align(center)[$R(theta,delta)=E_theta[L(theta,delta(X))].$]
#v(0.2in)
El riesgo es una función de $theta$. Elegir una acción después de ver $x$ y evaluar el riesgo de la regla completa son operaciones distintas.

], "Pedir expandir la esperanza como suma cuando X es finito. Tiempo orientativo: 2 min.", "Cap. 2, sec:ch7-riesgo")
#s(10, 49, "RIESGO", "Promediar también sobre la aleatorización", [

Para acciones finitas:
#align(center)[$R(theta,d)=E_theta[sum_a d(a|X)L(theta,a)].$]
#v(0.18in)
Primero se promedia la acción condicional en $X$; después se promedia sobre las observaciones.

], "Enfatizar que d(a|x) no depende del θ verdadero. Preparar el taller SSCH. Tiempo orientativo: 2 min.", "Cap. 2, sec:ch7-riesgo")
#s(11, 49, "RIESGO", "Un vector, no una sola cifra", [

Si $Theta={theta_0,theta_1}$, una regla tiene vector:
#align(center)[$(R(theta_0,delta),R(theta_1,delta)).$]
#v(0.2in)
Sin prior, peor caso u otro criterio, dos vectores que se cruzan no quedan ordenados.

], "Dibujar puntos de riesgo en dos dimensiones. Tiempo orientativo: 2 min.", "Cap. 2, sec:ch7-riesgo")
#s(12, 49, "DOMINANCIA", "Mejora uniforme", [

$delta_1$ domina $delta_2$ si su riesgo no es mayor para *todo* $theta$ y es menor para al menos uno.
#v(0.25in)
Una mejora solo en el promedio bajo un prior no prueba dominancia.

], "Solicitar un vector que domine a (3,3): por ejemplo (2,2). Un cruce impide dominancia. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-dominancia")
#s(13, 49, "ADMISIBILIDAD", "Descartar reglas dominadas", [

Una regla es admisible en $cal(D)$ si ninguna otra regla de esa clase la domina.
#v(0.22in)
Admisible no significa «óptima para todo modelo»; tampoco fija un prior.
#v(0.14in)
Cambiar $cal(D)$ puede cambiar la respuesta.

], "El adjetivo siempre debe acompañarse de la clase. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-admisibilidad")
#s(14, 49, "EJEMPLO", "Tres vectores de riesgo", [

#table(columns: (1fr,1fr,1fr), inset: 7pt,
  table.header([Regla], [$R(theta_0)$], [$R(theta_1)$]),
  [A], [$0$], [$4$],
  [B], [$2$], [$2$],
  [C], [$3$], [$3$],
)
B domina C; A y B se cruzan.

], "Ejemplo numérico docente, no parte del SSCH. Pedir identificar regla inadmisible en la clase {A,B,C}. Tiempo orientativo: 2 min.", "Cálculo docente basado en def:ch7-dominancia")
#s(15, 49, "BAYES", "Promedio bajo un prior", [

Un prior $nu$ pondera los riesgos:
#align(center)[$rho_nu(delta)=integral_Theta R(theta,delta) nu(dif theta).$]
#v(0.18in)
Una regla Bayes alcanza el menor riesgo integrado dentro de $cal(D)$.

], "Distinguir el prior sobre θ de la política π de MDP. En Θ finito, la integral es una suma ponderada. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-riesgo-bayes; def:ch7-regla-bayes")
#s(16, 49, "BAYES", "El prior cambia la elección", [

Con los vectores anteriores y $nu(theta_0)=0,9$:
#align(center)[$rho_nu(A)=0,4, quad rho_nu(B)=2.$]
#v(0.15in)
Con $nu(theta_0)=0,1$: $rho_nu(A)=3,6$ y $rho_nu(B)=2$.
#v(0.15in)
A es Bayes para el primer prior; B para el segundo, en esta clase.

], "C también está dominada por B. Preguntar por qué Bayes no implica uniformidad en θ. Tiempo orientativo: 2 min.", "Cálculo docente; cap. 2, criterio Bayes")
#s(17, 49, "POSTERIOR", "Elegir después de observar", [

Bajo posterior regular, acción finita y pérdida acotada:
#align(center)[$ell_nu(x,a)=integral L(theta,a) nu(dif theta|x).$]
#v(0.18in)
Elegir un minimizador de $ell_nu(x,a)$ para cada $x$ produce una regla Bayes.

], "Nombrar hipótesis del teorema: posterior regular, A finita, L acotada y medible. Tiempo orientativo: 3 min.", "Cap. 2, thm:ch7-bayes")
#s(18, 49, "PRUEBA", "Por qué funciona la minimización posterior", [

Por esperanza iterada:
#align(center)[$rho_nu(delta)=E[ell_nu(X,delta(X))].$]
#v(0.18in)
Minimizar el integrando para cada observación da una cota inferior alcanzable.
#v(0.18in)
Aleatorizar solo mezcla pérdidas posteriores y no baja del mínimo.

], "Escribir la desigualdad punto a punto y promediar; indicar que los conjuntos predictivamente nulos no determinan la regla. Tiempo orientativo: 3 min.", "Cap. 2, prueba de thm:ch7-bayes")
#s(19, 49, "POSTERIOR", "Acción óptima depende de la pérdida", [

Bajo condiciones de momentos:
+ pérdida cuadrática → media posterior;
+ pérdida absoluta → mediana posterior;
+ pérdida 0–1 para categoría discreta → categoría de mayor masa.
#v(0.1in)
La «moda» de una densidad continua no se deduce de pérdida exacta 0–1.

], "Diferenciar objetivo escalar continuo y clasificación discreta. Tiempo orientativo: 2 min.", "Cap. 2, cor:ch7-bayes-especificas")
#s(20, 49, "TEOREMA", "Bayes y admisibilidad en modelo finito", [

Si $Theta$ es finito y el prior asigna masa positiva a cada $theta$, una regla Bayes de riesgo finito es admisible en la misma clase.
#v(0.18in)
Una mejora estricta en algún $theta$ disminuiría el riesgo integrado, contradiciendo la optimalidad Bayes.

], "La positividad del prior es esencial para la prueba; en espacios continuos se requieren condiciones adicionales. Tiempo orientativo: 3 min.", "Cap. 2, thm:ch7-admisibilidad-bayes")
#s(21, 49, "MINIMAX", "Controlar el peor riesgo", [

#align(center)[$M(delta)=sup_(theta in Theta)R(theta,delta), quad M^*=inf_(delta in cal(D))M(delta).$]
#v(0.2in)
Una regla minimax debe alcanzar $M^*$; que exista un ínfimo no asegura que se alcance.

], "Contrastar con Bayes: supremo versus promedio. El peor caso se define dentro de Θ y la clase declaradas. Tiempo orientativo: 2 min.", "Cap. 2, def:ch7-minimax")
#s(22, 49, "TEOREMA", "Certificación minimax mediante Bayes", [

Si una regla $delta_nu$ es Bayes y
#align(center)[$sup_theta R(theta,delta_nu)=rho_nu(delta_nu)<infinity,$]
entonces es minimax.
#v(0.18in)
Una regla Bayes con riesgo constante en *todo* $Theta$ cumple la condición.

], "No basta constancia sobre el soporte del prior. Enunciar la condición exacta antes de la prueba. Tiempo orientativo: 3 min.", "Cap. 2, thm:ch7-minimax-bayes")
#s(23, 49, "PRUEBA", "Cadena de desigualdades minimax", [

Para cualquier $delta$:
#align(center)[$sup_theta R(theta,delta) >= rho_nu(delta) >= rho_nu(delta_nu)$]
#v(0.12in)
#align(center)[$=sup_theta R(theta,delta_nu).$]
Por tanto ninguna regla tiene peor riesgo menor.

], "Primera desigualdad: supremo ≥ promedio. Segunda: optimalidad Bayes. Igualdad final: condición del teorema sobre todo Θ. Tiempo orientativo: 3 min.", "Cap. 2, prueba de thm:ch7-minimax-bayes")
#s(24, 49, "CASO BERNOULLI", "Una observación para estimar θ", [

$X tilde "Bernoulli"(theta)$, $theta in [0,1]$, acción $a in [0,1]$ y pérdida $(a-theta)^2$.
#v(0.2in)
Compararemos $delta_0 (X)=X$ con una regla que contrae hacia $1/2$.

], "El caso procede del capítulo y permite probar un certificado minimax completo. Tiempo orientativo: 3 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(25, 49, "CASO BERNOULLI", "La regla directa no controla bien el peor caso", [

$delta_0 (X)=X$ es insesgada, pero:
#align(center)[$R(theta,delta_0)=theta(1-theta).$]
#v(0.2in)
Su riesgo máximo se alcanza en $theta=1/2$ y vale $1/4$.

], "Pedir calcular derivada o completar cuadrado. Insesgadez no implica minimax. Tiempo orientativo: 3 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(26, 49, "CASO BERNOULLI", "El prior y la regla posterior", [

Con prior $ "Beta"(1/2,1/2)$ y una observación:
#align(center)[$delta_nu (X)=E[theta|X]=(X+1/2)/2.$]
#v(0.2in)
Es Bayes bajo pérdida cuadrática porque minimiza la pérdida posterior esperada.

], "Mostrar la suma de parámetros posterior: (X+1/2)+(1-X+1/2)=2. Tiempo orientativo: 4 min.", "Cap. 2, thm:ch7-bayes; ex:ch2-bernoulli-minimax")
#s(27, 49, "CASO BERNOULLI", "Qué hace la contracción", [

#align(center)[$delta_nu (0)=1/4, quad delta_nu (1)=3/4.$]
#v(0.18in)
La regla ya no entrega acciones extremas 0 y 1.
#v(0.18in)
Introduce sesgo para reducir el peor riesgo.

], "Pedir comparar con δ0(0)=0 y δ0(1)=1. Tiempo orientativo: 3 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(28, 49, "DERIVACIÓN", "Sesgo y varianza", [

#align(center)[$"Sesgo"(theta)=E_theta[delta_nu (X)]-theta=1/4-theta/2.$]
#v(0.16in)
#align(center)[$"Var"_theta (delta_nu (X))=theta(1-theta)/4.$]
#v(0.16in)
Bajo pérdida cuadrática, riesgo = varianza + sesgo al cuadrado.

], "Explicar E[X]=θ y Var(X)=θ(1−θ). Mantener las dos contribuciones separadas antes de simplificar. Tiempo orientativo: 4 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(29, 49, "DERIVACIÓN", "El riesgo es constante", [

#align(center)[$R(theta,delta_nu)=theta(1-theta)/4+(1/4-theta/2)^2=1/16.$]
#v(0.15in)
#text(size: 16pt)[
#table(columns: (1fr,1fr,1fr), inset: 5pt,
  table.header([$theta$], [$R(theta,delta_0)$], [$R(theta,delta_nu)$]),
  [$0$], [$0$], [$1/16$],
  [$1/2$], [$1/4$], [$1/16$],
  [$1$], [$0$], [$1/16$],
)]
]

], "Expandir (1/4−θ/2)^2 y cancelar términos. La tabla muestra que δν no domina a δ0. Tiempo orientativo: 5 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(30, 49, "CERTIFICADO", "Por qué la regla es minimax", [

$delta_nu$ es Bayes para el prior declarado y tiene riesgo $1/16$ en todo $Theta$.
#v(0.13in)
#align(center)[$sup_theta R(theta,delta) >= rho_nu(delta) >= rho_nu(delta_nu)=1/16$]
para cualquier $delta$.
#v(0.13in)
$delta_nu$ alcanza esa cota en su peor caso.

], "Referir a la cadena de desigualdades vista antes. El prior es menos favorable bajo las condiciones del capítulo. Tiempo orientativo: 4 min.", "Cap. 2, thm:ch7-minimax-bayes; ex:ch2-bernoulli-minimax")
#s(31, 49, "EJERCICIO", "¿Mejor en todos los θ?", [

Calcule ambos riesgos para $theta=1/5$ y para $theta=0$.
#v(0.19in)
¿Demuestra el menor peor riesgo que $delta_nu$ domina a $delta_0$?
#v(0.19in)
Dé una respuesta con el vector o la función de riesgo, no con un adjetivo.

], "Solución: en θ=1/5, δ0=4/25=0,16 y δν=1/16=0,0625; en θ=0, δ0=0 y δν=1/16. No hay dominancia uniforme. Tiempo orientativo: 4 min.", "Cap. 2, ex:ch2-bernoulli-minimax")
#s(32, 49, "PAUSA", "Descanso de 15 minutos", [

Al volver: ¿por qué una regla Bayes de riesgo constante puede certificar minimax, pero una regla Bayes cualquiera no?

], "Pausar quince minutos y pedir una respuesta basada en la igualdad entre riesgo máximo e integrado. Tiempo orientativo: 15 min.", "Plan de clase")
#s(33, 49, "TALLER SSCH", "Señal y costos sintéticos", [

$theta in {0,1}$ indica necesidad abstracta de seguimiento; $X in {0,1}$ es una señal.
#v(0.12in)
$P_0(X=1)=1/5$ y $P_1(X=1)=4/5$.
#v(0.12in)
Falsa intensificación cuesta 1; omitir intensificación necesaria cuesta 4.
#v(0.12in)
Todo es un escenario docente, no una pauta clínica.

], "45 minutos en equipos para diapositivas 33–40: 5 lectura, 25 cálculo, 15 discusión. Mantener explícita la clase de reglas. Tiempo orientativo: 5 min.", "Cap. 2, ex:ssch-cap07")
#s(34, 49, "TALLER SSCH", "Cuatro reglas deterministas", [

#text(size: 16pt)[
#table(columns: (2fr,1fr,1fr), inset: 6pt,
  table.header([Regla], [$R(0)$], [$R(1)$]),
  [Siempre ordinario], [$0$], [$4$],
  [Siempre intensificar], [$1$], [$0$],
  [Seguir $X$], [$1/5$], [$4/5$],
  [Invertir $X$], [$4/5$], [$16/5$],
)]
]
#v(0.1in)
Verifiquen una fila desde probabilidades de error.

], "Para seguir X: bajo θ0 error si X1 (1/5); bajo θ1 error si X0 (1/5) multiplicado por costo4 =4/5. Tiempo orientativo: 5 min.", "Cap. 2, ex:ssch-cap07")
#s(35, 49, "TALLER SSCH", "Bayes con prior ν(1)=3/10", [

#align(center)[$rho_nu(delta)=frac(7,10)R(0,delta)+frac(3,10)R(1,delta).$]
#v(0.14in)
#text(size: 16pt)[
#table(columns: (1.5fr,1fr,1fr,1fr), inset: 5pt,
  table.header([Regla], [Ordinario], [Intensificar], [Seguir $X$]),
  [Riesgo Bayes], [$6/5$], [$7/10$], [$19/50$],
)]
]
La mejor entre las cuatro reglas es seguir la señal.

], "La regla invertida tiene 38/25=1,52, mayor que todas; no se omite de la comparación aunque la tabla destaque las tres relevantes. Tiempo orientativo: 5 min.", "Cap. 2, ex:ssch-cap07")
#s(36, 49, "TALLER SSCH", "Minimax entre las cuatro reglas", [

#table(columns: (1fr,1fr,1fr,1fr), inset: 6pt,
  table.header([Regla], [Ordinario], [Intensificar], [Seguir $X$]),
  [Peor riesgo], [$4$], [$1$], [$4/5$],
)
#v(0.15in)
Seguir $X$ es minimax *dentro de estas cuatro reglas deterministas*.

], "La regla invertida tiene peor riesgo 16/5; pedir verificar que no cambia el mínimo. Subrayar la clase restringida. Tiempo orientativo: 5 min.", "Cap. 2, ex:ssch-cap07")
#s(37, 49, "TALLER SSCH", "Ampliar la clase cambia el problema", [

Defina $q_0=P(a=1|X=0)$ y $q_1=P(a=1|X=1)$.
#v(0.17in)
Una regla determinista usa $q_x in {0,1}$; una aleatorizada permite cualquier $q_x in [0,1]$.
#v(0.16in)
Pregunte si el peor riesgo $4/5$ puede disminuir.

], "Precisar que a=1 significa intensificar. La aleatorización no conoce θ. Tiempo orientativo: 5 min.", "Cap. 2, def:ch7-regla; ex:ssch-cap07")
#s(38, 49, "TALLER SSCH", "Riesgos como función de q₀ y q₁", [

#align(center)[$R(0,q)=frac(4,5)q_0+frac(1,5)q_1.$]
#v(0.14in)
#align(center)[$R(1,q)=4[frac(1,5)(1-q_0)+frac(4,5)(1-q_1)].$]
#v(0.14in)
La primera cuenta falsas intensificaciones; la segunda, omisiones.

], "Pedir derivar una de las expresiones con probabilidades condicionales antes de mostrar. Tiempo orientativo: 6 min.", "Cap. 2, ex:ssch-cap07")
#s(39, 49, "TALLER SSCH", "Igualar los dos riesgos", [

Elija $q_1=1$ y $q_0=3/8$.
#v(0.15in)
#align(center)[$R(0,q)=frac(4,5)frac(3,8)+frac(1,5)=1/2.$]
#v(0.12in)
#align(center)[$R(1,q)=4 frac(1,5)(1-frac(3,8))=1/2.$]
El peor riesgo baja de $4/5$ a $1/2$.

], "Igualar riesgos no certifica por sí solo minimax; falta cota inferior. Darla con el prior menos favorable en la siguiente diapositiva. Tiempo orientativo: 6 min.", "Cap. 2, ex:ssch-cap07")
#s(40, 49, "CERTIFICADO", "Por qué 1/2 es minimax", [

Bajo prior $nu^*(1)=1/2$, en $X=0$ el posterior de $theta=1$ es $1/5$: ambas acciones tienen pérdida posterior $4/5$.
#v(0.14in)
En $X=1$, intensificar minimiza pérdida posterior. La regla $q_1=1,q_0=3/8$ es Bayes para $nu^*$ y tiene riesgo constante $1/2$.
#v(0.1in)
Por el teorema Bayes–minimax, es minimax en la clase ampliada.

], "Comparar con prior 3/10: la regla aleatorizada tiene riesgo promedio 1/2, mientras seguir X tiene 19/50. Dos criterios prefieren reglas distintas. Tiempo orientativo: 8 min.", "Cap. 2, thm:ch7-minimax-bayes; ex:ssch-cap07")
#s(41, 49, "TESTS", "Un contraste también es una regla", [

Acciones: rechazar o no rechazar $H_0$.
#v(0.16in)
Bajo $H_0$, riesgo = costo de falso rechazo × probabilidad de rechazar.
#v(0.16in)
Bajo $H_1$, riesgo = costo de falsa aceptación × probabilidad de no rechazar.

], "Bayes con costos y prior no garantiza automáticamente un nivel frecuentista prefijado. Tiempo orientativo: 6 min.", "Cap. 2, prop:ch4-test-decision")
#s(42, 49, "AGENTE", "Del criterio al componente", [

Un agente debe registrar: qué observa, qué desconoce, qué acciones permite y qué pérdida usa.
#v(0.17in)
La regla de decisión se implementa después; su validez exige evaluar el procedimiento completo.
#v(0.17in)
El modelo del mundo no equivale a conocer el verdadero $theta$.

], "Pedir a un equipo una ficha de estado y acción para el SSCH sintético. Tiempo orientativo: 7 min.", "Cap. 2, sec:ch7-langgraph y tab:ch7-trazabilidad")
#s(43, 49, "DISCUSIÓN", "¿Qué criterio elegir?", [

Con prior defendible, Bayes compara el promedio.
#v(0.17in)
Si interesa proteger un conjunto de modelos, minimax controla el peor riesgo de esa clase.
#v(0.17in)
Admisibilidad descarta mejoras uniformes sin ordenar todos los pares.

], "20 minutos de discusión con el SSCH: por qué seguir X es Bayes para ν(1)=0,3, pero la regla aleatorizada mejora el peor caso. Tiempo orientativo: 7 min.", "Cap. 2, sec:ch7-metacriterios")
#s(44, 49, "CIERRE", "Tres comprobaciones antes de decidir", [

1. Declare $Theta$, $P_theta$, $cal(A)$, $L$ y $cal(D)$.
#v(0.13in)
2. Calcule el riesgo de la *regla completa*.
#v(0.13in)
3. Diga si compara promedio Bayes, peor caso o dominancia.
#v(0.16in)
Siguiente clase: el futuro entra mediante MDP y Bellman.

], "10 minutos con un ticket de salida: cada estudiante corrige una afirmación demasiado amplia sobre Bayes o minimax. Tiempo orientativo: 10 min.", "Cap. 2, cierre")
#s(45, 49, "RESPALDO", "James–Stein: qué dimensión importa", [

Para $X tilde N_p(theta,I_p)$ y pérdida $norm(a-theta)^2$, con $p>=3$:
#align(center)[$R(theta,X)=p.$]
#v(0.15in)
La contracción James–Stein puede reducir ese riesgo en todo $theta$.
#v(0.15in)
$p$ es la *dimensión del parámetro*, no el tamaño muestral de una media escalar.

], "La prueba está en el apéndice. No usar el ejemplo para afirmar que toda contracción domina. Diapositiva de respaldo.", "Cap. 2, ex:ch7-james-stein")
#s(46, 49, "RESPALDO", "Bayes admisible: argumento finito", [

Si una regla dominara a $delta_nu$ y $nu(theta)>0$ en todo $Theta$ finito:
#v(0.15in)
La mejora de riesgo sería no negativa en todos los modelos y positiva en alguno.
#v(0.15in)
Su promedio bajo $nu$ sería positivo: contradicción con optimalidad Bayes.

], "La prueba falla si el prior pone masa cero en el modelo donde ocurre la mejora estricta.", "Cap. 2, thm:ch7-admisibilidad-bayes")
#s(47, 49, "RESPALDO", "Clase esencialmente completa", [

En problemas finitos, incluir reglas aleatorizadas hace convexo el conjunto de vectores de riesgo.
#v(0.18in)
La prueba de la clase esencialmente completa usa separación convexa; no se reproduce aquí.
#v(0.18in)
El resultado no afirma que cada regla Bayes sea admisible sin condiciones.

], "Remitir al apéndice para la prueba formal. Distinguir este resultado del teorema Bayes–minimax.", "Cap. 2, thm:ch7-complete-class")
#s(48, 49, "RESPALDO", "Una decisión como política terminal", [

Copie $delta(x)$ en $pi_delta(x)$, fije $r_theta(x,a)=-L(theta,a)$ y transite a estado terminal.
#align(center)[$J_theta (pi_delta)=-R(theta,delta).$]
#v(0.16in)
La identidad conserva el criterio, pero no da estimador ni intervalo para datos nuevos.

], "Repaso del puente hacia las clases 4–6; no inferir equivalencia de MDP generales.", "Cap. 2, prop:ch1-correspondencia; cap. 5")
#s(49, 49, "RESPALDO", "Fuentes y lectura", [

Wald (1950), *Statistical Decision Functions*.
#v(0.14in)
Berger (1985), *Statistical Decision Theory and Bayesian Analysis*.
#v(0.14in)
Ferguson (1967), *Mathematical Statistics: A Decision Theoretic Approach*.
#v(0.14in)
Cap. 2 y apéndice de demostraciones del libro local.

], "Cotejar ediciones y claves en referencias.bib antes de imprimir bibliografía final. Diapositiva de respaldo.", "Cap. 2, lecturas propuestas")
