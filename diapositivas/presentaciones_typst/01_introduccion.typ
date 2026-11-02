// Clase 1 reconstruida desde capitulos/intro.typ y cap10_casos.typ.
// SSCH: escenario sintético, no evidencia clínica.
#import "tema_clases.typ": s
#set document(title: "Clase 1 — Inferir para decidir")
#set page(width: 13.333in, height: 7.5in, margin: (x: 0.72in, y: 0.46in))
#set text(font: "Liberation Sans", size: 19pt, fill: rgb("#18253B"))

#s(1, 35, "APERTURA", "Inferir para decidir", [

Una medición informa una decisión; el resultado depende de lo que se haga después.
#v(0.35in)
#align(center)[*observación → regla → acción → consecuencia*]
#v(0.3in)
Pregunta inicial: ¿cuándo basta predecir y cuándo necesitamos comparar consecuencias?

], "Abrir con una respuesta individual y pedir que se identifique qué variable se observa antes de actuar. 4 min.", "Introducción, párrafos iniciales")
#s(2, 35, "OBJETIVOS", "Qué podrás hacer al terminar", [

+ Formular observación, acción, pérdida y objetivo de una decisión.
+ Calcular un umbral bajo pérdidas explícitas.
+ Distinguir recompensa inmediata, valor futuro y evidencia estadística.
+ Diagnosticar qué garantía todavía falta para una aplicación.

], "Explicar que se evaluará con una ficha de caso, no con recuerdo de definiciones. 6 min.", "Introducción; cap. 10, sec:ssch-intro")
#s(3, 35, "RUTA", "Tres horas de trabajo", [

#table(columns: (2fr,1fr), inset: 7pt,
  [Motivación y conceptos], [60 min],
  [Ejemplo SSCH guiado], [30 min],
  [Descanso], [15 min],
  [Taller], [45 min],
  [Discusión y síntesis], [30 min],
)

], "La primera hora combina apertura (15) y conceptos (45); el ejemplo ocupa 30; el descanso 15; el taller 45; la discusión 20 y el cierre 10. 5 min.", "PLAN_PRESENTACIONES_TYPST.md, distribución")
#s(4, 35, "CONCEPTO", "Una predicción todavía no es una decisión", [

Una predicción propone $p=P(Y=1|X=x)$.
#v(0.22in)
Una decisión elige $a$ comparando pérdidas esperadas.
#v(0.25in)
#align(center)[$a^*(x)=arg min_a E[L(Y,a)|X=x]$]
#v(0.2in)
La misma $p$ puede llevar a acciones distintas cuando cambia $L$.

], "El ejemplo matemático define Y como resultado binario y X como medición previa. Pedir dos posibles acciones. 5 min.", "Introducción, párrafo inicial; cálculo didáctico")
#s(5, 35, "CONCEPTO", "Información disponible al actuar", [

$X$ es la observación que recibe la regla. $theta$ indexa el modelo y puede ser desconocido.
#v(0.25in)
#align(center)[$X tilde P_theta, quad delta:cal(X) -> cal(A)$]
#v(0.25in)
Una política que ve $theta$ resolvería otro problema.

], "Subrayar la diferencia entre variable observada y parámetro. La notación es la del capítulo 2. 5 min.", "Introducción, sec:ch0-tesis; cap. 2, def:ch7-regla")
#s(6, 35, "CONCEPTO", "Cinco piezas de un problema de decisión", [

#table(columns: (1fr,2fr), inset: 6pt,
  [$Theta$], [modelos posibles],
  [$cal(X)$], [observaciones registradas],
  [$cal(A)$], [acciones disponibles],
  [$P_theta$], [ley de los datos bajo cada modelo],
  [$L(theta,a)$], [pérdida de una acción],
)

], "Pedir al grupo que localice qué pieza falta si solo se entrega un predictor. 6 min.", "Cap. 2, def:ch7-problema")
#s(7, 35, "CONCEPTO", "La pérdida expresa prioridades", [

Una regla no se justifica solo por exactitud predictiva.
#v(0.25in)
Falsas alarmas, omisiones, costo operativo y demora pueden tener pérdidas distintas.
#v(0.25in)
*Condición:* la escala y el responsable de fijar la pérdida deben quedar explícitos.

], "No atribuir valores médicos al ejemplo que sigue; sus números son abstractos. 5 min.", "Introducción, párrafo inicial; cap. 2, ex:ch7-perdidas")
#s(8, 35, "CÁLCULO", "Un ejemplo binario independiente del SSCH", [

Sea $p=P(Y=1|X=x)$. Dos acciones abstractas:
#v(0.18in)
#table(columns: (1.5fr,1fr,1fr), inset: 6pt,
  table.header([Acción], [$Y=0$], [$Y=1$]),
  [Actuar], [$1$], [$1$],
  [Esperar], [$0$], [$5$],
)
#v(0.15in)
Las unidades de pérdida son hipotéticas.

], "Este ejemplo NO usa las recompensas del SSCH tabular; se emplea solo para derivar un umbral. Pedir la pérdida esperada de cada acción. 6 min.", "Cálculo docente separado; cap. 2, riesgo")
#s(9, 35, "CÁLCULO", "Derivación del umbral", [

#align(center)[$E[L|x, "actuar"]=1, quad E[L|x, "esperar"]=5p$]
#v(0.22in)
Actuar reduce la pérdida condicional si:
#align(center)[$1<5p quad "si y solo si" quad p>0,2.$]
#v(0.2in)
En $p=0,2$ hay empate y se necesita una regla de desempate.

], "Pedir despejar p antes de mostrar la desigualdad. Comprobar que ambas pérdidas son 1 en p=0,2. 6 min.", "Cálculo docente; cap. 2, thm:ch7-bayes")
#s(10, 35, "CÁLCULO", "Dos mediciones, dos decisiones", [

Si $p=0,15$, esperar tiene pérdida esperada $0,75<1$.
#v(0.25in)
Si $p=0,30$, esperar tiene pérdida esperada $1,50>1$.
#v(0.25in)
La acción cambia porque la medición modifica $p$; la pérdida permanece fija.

], "Solución del cálculo: 5·0,15=0,75 y 5·0,30=1,50. Pedir que indiquen qué cantidad cambiaría si el costo de actuar fuera 2. 5 min.", "Cálculo docente; cap. 2, riesgo condicional")
#s(11, 35, "LÍMITE", "El umbral depende de las pérdidas", [

Con costo de actuar $c$ y costo de omisión $h$:
#align(center)[$E[L|"actuar"]=c, quad E[L|"esperar"]=h p.$]
#v(0.22in)
El umbral es $p>c/h$ cuando $h>0$.
#v(0.18in)
Cambiar $c$ o $h$ cambia la regla, aunque el predictor sea idéntico.

], "Derivar la expresión y discutir qué ocurre si c≥h; el umbral queda fuera de (0,1). Ningún c/h es una recomendación clínica. 6 min.", "Derivación docente; cap. 2, pérdida y Bayes")
#s(12, 35, "CONCEPTO", "Riesgo: evaluación antes de observar", [

La regla completa $delta$ asigna una acción a cada observación.
#v(0.2in)
El riesgo promedia sobre muestras posibles bajo un modelo:
#align(center)[$R(theta,delta)=E_theta[L(theta,delta(X))].$]
#v(0.18in)
Distinguir este promedio del cálculo condicional de la diapositiva anterior.

], "Pedir distinguir el p posterior condicionado en x del parámetro θ que indexa Pθ. No confundir decisión condicional con riesgo frecuentista. 6 min.", "Cap. 2, sec:ch7-riesgo")
#s(13, 35, "DIAGNÓSTICO", "¿Qué afirmación se sostiene?", [

Una regla puede estar definida y calculada exactamente; su riesgo real puede seguir desconocido.
#v(0.25in)
Clasifica cada frase: *definición*, *cálculo dentro de un modelo* o *conclusión sobre datos reales*.
#v(0.2in)
«Con estas pérdidas, el umbral es 0,2». «La regla mejora resultados clínicos».

], "Respuesta: la primera es cálculo bajo supuestos; la segunda requiere evidencia clínica y no se sigue del cálculo. 6 min.", "Introducción, cierre; cap. 10, alcance del SSCH")
#s(14, 35, "CASO SSCH", "Un escenario sintético con dos diseños", [

El libro usa un SSCH docente. Sus números no proceden de pacientes.
#v(0.2in)
*Diseño tabular:* cinco estados, cuatro acciones, horizonte descontado.
#v(0.16in)
*Subcaso de dos visitas:* cuatro historias enumerables para OPE e intervalos.
#v(0.16in)
No comparten parámetros, horizonte ni datos.

], "Señalar que las etiquetas clínicas son motivación, no pautas terapéuticas. Esta distinción evita mezclar estimandos en clases posteriores. 4 min.", "Introducción; cap. 10, sec:ssch-intro")
#s(15, 35, "CASO SSCH", "Qué fija el modelo tabular", [

Estados $s_1,dots,s_5$ ordenados por severidad abstracta; acciones $a_1,dots,a_4$.
#v(0.2in)
Descuento $gamma=0,9$ y objetivo $V^pi (s_3)$.
#v(0.2in)
La recompensa $r(s,a)$ y la transición $P(s'|s,a)$ son definidas por el simulador.

], "Aclarar que la transición definida por fórmula es un supuesto del simulador, no una estimación humana. 4 min.", "Cap. 10, ex:ssch-cap01")
#s(16, 35, "CASO SSCH", "Recompensa inmediata en s₃", [

#align(center)[
#table(columns: (1fr,1fr,1fr,1fr), inset: 10pt,
  table.header([$a_1$], [$a_2$], [$a_3$], [$a_4$]),
  [$0,0$], [$0,3$], [$0,6$], [$0,5$],
)]
#v(0.22in)
La mejor acción *inmediata* en $s_3$ es $a_3$.
#v(0.15in)
Eso todavía no compara el valor de políticas a largo plazo.

], "Pedir elegir acción antes de mostrar el cierre. Son recompensas abstractas del simulador, no beneficios clínicos. 5 min.", "Cap. 10, tab:ssch-recompensas")
#s(17, 35, "CASO SSCH", "Cuatro políticas constantes", [

Con la transición del simulador y $gamma=0,9$, el valor desde $s_3$ es:
#v(0.16in)
#table(columns: (1fr,1fr), inset: 7pt,
  table.header([Política constante], [$V^pi (s_3)$]),
  [$a_1$ siempre], [$-7,771$],
  [$a_2$ siempre], [$1,636$],
  [$a_3$ siempre], [$5,856$],
  [$a_4$ siempre], [$4,787$],
)

], "Valores calculados con lab00_ssch.py sobre P=model() y evaluate(P,π). No son estimaciones con datos ni resultados clínicos. Pedir por qué a1 acumula valor negativo. 6 min.", "Cap. 10, ex:ssch-cap01; lab00_ssch.py, SHA ce0d025cdc8e")
#s(18, 35, "CASO SSCH", "Una política dependiente del estado mejora", [

La iteración de valores del mismo modelo produce:
#v(0.15in)
#align(center)[$pi^*=(a_2,a_3,a_3,a_4,a_4), quad V^* (s_3) approx 7,097.$]
#v(0.2in)
Esto supera $5,856$, el mejor valor entre las cuatro políticas constantes.
#v(0.2in)
El cálculo compara políticas *dentro del simulador definido*.

], "Value iteration con R y P del lab00, residual supremo <10^(-12). La desigualdad no prueba rendimiento de un tratamiento real ni cobertura estadística. 6 min.", "Cap. 10, ex:ssch-cap01; cálculo sobre lab00_ssch.py")
#s(19, 35, "PUENTE", "Una identidad de un paso", [

En una decisión terminal, una regla $delta(x)$ se copia como política $pi_delta (x)$.
#v(0.18in)
Si la recompensa evaluativa es $r_theta (x,a)=-L(theta,a)$ y se pasa a estado terminal:
#align(center)[$J_theta (pi_delta)=-R(theta,delta).$]
#v(0.15in)
La identidad usa la *misma observación*, la *misma acción* y el promedio bajo $P_theta$.

], "Explicar que θ es desconocido y que la recompensa evaluativa puede no observarse al actuar. La prueba se desarrollará en la clase 6. 6 min.", "Introducción, def:isomorfismo-informal; cap. 5, thm:ch9-isomorfismo")
#s(20, 35, "LÍMITE", "Lo que la identidad no entrega", [

$J=-R$ conserva una comparación dentro de la construcción de un paso.
#v(0.2in)
No proporciona automáticamente:
+ datos sobre acciones no elegidas;
+ identificación de una política nueva;
+ un intervalo de confianza o una garantía de despliegue.

], "Hacer que el grupo señale una hipótesis adicional para cada conclusión. Evitar la frase «toda garantía se transfiere». 5 min.", "Introducción, después de tab:correspondencia-central")
#s(21, 35, "PAUSA", "Descanso: 15 minutos", [

Al volver, una pregunta de recuperación:
#v(0.28in)
¿Por qué el valor $7,097$ del SSCH tabular es un cálculo del simulador y no una afirmación sobre pacientes?

], "Pausar exactamente 15 minutos. Al volver pedir dos respuestas: origen de P/r y ausencia de validación clínica.", "Plan de clase")
#s(22, 35, "TALLER", "Producto: ficha de una decisión", [

Trabajen en equipos con el SSCH sintético y el ejemplo binario separado.
#v(0.16in)
Entreguen una hoja con: observación, acciones, objetivo, pérdidas/recompensas, dato necesario y conclusión permitida.
#v(0.14in)
Tiempo: 5 min consigna · 25 min trabajo · 15 min puesta en común.

], "No mezclar los números del umbral binario con el modelo SSCH de cinco estados. Evaluar claridad del estimando y límites. 45 min para las diapositivas 22–27.", "Introducción; cap. 10, sec:ssch-intro")
#s(23, 35, "TALLER", "Datos de trabajo", [

*Ejemplo binario:* $c=2$, $h=5$, $p(x_1)=0,30$ y $p(x_2)=0,60$.
#v(0.17in)
*SSCH tabular:* $r(s_3,.)=(0;0,3;0,6;0,5)$ y $V^* (s_3)=7,097$.
#v(0.17in)
*Dato faltante:* no hay resultados clínicos humanos en ninguno de los dos ejemplos.

], "Recordar que c y h son pérdidas hipotéticas. El SSCH usa recompensa, no la pérdida c/h. 5 min de lectura de datos dentro del taller.", "Cálculo docente; cap. 10, tab:ssch-recompensas")
#s(24, 35, "TALLER", "Tarea A: nueva regla binaria", [

Deriven el umbral con $c=2$ y $h=5$.
#v(0.18in)
¿Qué acción corresponde a $p(x_1)=0,30$? ¿Y a $p(x_2)=0,60$?
#v(0.17in)
Registren también la acción en el empate.

], "Solución: umbral p>0,4; esperar para 0,30; actuar para 0,60; en p=0,4 fijar desempate. 10 min dentro del taller.", "Cálculo docente, riesgo condicional")
#s(25, 35, "TALLER", "Tarea B: criterio temporal", [

En $s_3$, ¿qué acción maximiza la recompensa inmediata?
#v(0.2in)
¿Puede inferirse de esa fila el valor $V^* (s_3)$ sin la transición $P$?
#v(0.2in)
Compare $V^* (s_3)=7,097$ con la mejor política constante $5,856$.

], "Respuesta: a3; no se obtiene V* sin P y sin horizonte/descuento. Diferencia ≈1,241 unidades del simulador. 10 min.", "Cap. 10, ex:ssch-cap01; lab00_ssch.py")
#s(26, 35, "TALLER", "Tarea C: auditar una conclusión", [

Evalúen estas frases:
#v(0.18in)
1. «La política calculada vale $7,097$ en el simulador fijado».
#v(0.18in)
2. «La política mejora resultados de personas con hipertensión».
#v(0.18in)
Escriban qué evidencia respalda cada una y cuál falta.

], "La primera se puede reproducir desde R,P,γ,π y estado inicial; la segunda no se justifica con este simulador. 10 min.", "Introducción; cap. 10, apertura")
#s(27, 35, "SOLUCIÓN", "Ficha corregida y alcance", [

*Binario:* umbral $0,4$; esperar en $x_1$ y actuar en $x_2$.
#v(0.15in)
*SSCH:* acción inmediata $a_3$ en $s_3$; valor óptimo del modelo $7,097$.
#v(0.15in)
*Dictamen:* resultado computacional de un simulador especificado; ninguna conclusión clínica.

], "Pedir que los equipos revisen su ficha según estas tres líneas y entreguen una versión corregida. 5 min de cierre del taller.", "Cálculos del taller")
#s(28, 35, "DISCUSIÓN", "¿Qué faltaría para estudiar datos reales?", [

Distinguir tres preguntas:
+ ¿Qué política se quiere evaluar?
+ ¿Cómo se obtuvieron las acciones y los resultados?
+ ¿Qué supuestos permiten identificar el valor?
#v(0.16in)
Una base grande no responde por sí sola la tercera.

], "Moderación 15 min: asignar una pregunta por equipo y exigir un ejemplo de supuesto no verificable con datos observados. No evaluar tratamientos concretos.", "Introducción; cap. 7, supuestos de identificación")
#s(29, 35, "COMPROBACIÓN", "Tres frases para clasificar", [

A. «El riesgo esperado es $5p$ en el ejemplo binario».
#v(0.15in)
B. «El valor óptimo del simulador es $7,097$».
#v(0.15in)
C. «Un IC del 95 % para el valor real cubrirá correctamente».
#v(0.15in)
¿Cuál es identidad, cálculo computacional y garantía inferencial pendiente?

], "A: igualdad dentro del modelo de pérdidas; B: resultado computacional del simulador; C: requiere estimador, muestreo y validación de condiciones. 5 min.", "Introducción, distinción final")
#s(30, 35, "CIERRE", "Qué conservar para la clase siguiente", [

Antes de comparar reglas, fijar *modelo, observación, acción, pérdida y criterio*.
#v(0.2in)
Antes de usar un resultado, preguntar *qué se ha demostrado, con qué datos y bajo qué condiciones*.
#v(0.2in)
Siguiente clase: las tradiciones de Wald y Bellman.

], "Cierre 10 min junto con la comprobación anterior. Pedir una pregunta abierta por estudiante. Lectura: cap. 1 y selección de cap. 2.", "Introducción, guía de lectura")
#s(31, 35, "RESPALDO", "La transición del SSCH tabular", [

Para índices $s,j in {0,dots,4}$ y desplazamientos $d_a$:
#align(center)[$w_(s,a,j)=exp(-abs(j-(s+d_a))/0,7)$]
#v(0.12in)
#align(center)[$P_(s,a,j)=0,98 frac(w_(s,a,j),sum_u w_(s,a,u))+0,02/5.$]
Cada fila suma uno y cada entrada es al menos $0,004$.

], "Diapositiva de consulta, fuera de los 180 minutos. La fórmula es decisión de diseño del simulador. Cotejada con ex:ssch-cap01.", "Cap. 10, ex:ssch-cap01")
#s(32, 35, "RESPALDO", "Valor de una política fija", [

En el modelo tabular descontado:
#align(center)[$V^pi = r^pi + gamma P^pi V^pi.$]
#v(0.2in)
Si $gamma<1$:
#align(center)[$V^pi=(I-gamma P^pi)^(-1)r^pi.$]
Esto permite reproducir los valores de las cuatro políticas constantes.

], "Diapositiva de consulta. La inversión existe para matriz estocástica finita y gamma=0,9. Ecuación de Bellman se estudia en clase 4.", "Cap. 3, thm:ch8-bellman-pi; lab00_ssch.py")
#s(33, 35, "RESPALDO", "Prueba de la identidad de un paso", [

Con transición terminal y recompensa $r_theta (x,a)=-L(theta,a)$:
#align(center)[$J_theta (pi_delta)=sum_x P_theta (x)r_theta (x,delta(x))$]
#align(center)[$=-sum_x P_theta (x)L(theta,delta(x))=-R(theta,delta).$]
La política no observa $theta$.

], "Diapositiva de consulta, no inferir equivalencia general de MDPs. La versión completa y condiciones están en thm:ch9-isomorfismo.", "Cap. 5, thm:ch9-isomorfismo")
#s(34, 35, "RESPALDO", "Proveniencia del cálculo SSCH", [

Archivo: $ "lab00_ssch.py" $ · SHA-256 inicial:
#v(0.12in)
#text(size: 12pt)[ce0d025cdc8e35d506bb465e6e40b20448db67b7744c61d21aef11864e37ba66]
#v(0.2in)
$P$ se genera con `model()`; $V^pi$ se calcula con `evaluate(P, pi)`; $V^*$ se obtuvo por iteración de valores.

], "Guardar el hash antes de cambiar el código. Para el óptimo: 261 iteraciones desde cero, residuo supremo <10^(-12). Sin semilla porque estas tres operaciones son deterministas.", "Cap. 10; lab00_ssch.py")
#s(35, 35, "RESPALDO", "Dos regímenes del SSCH", [

*Tabular:* cinco estados, cuatro acciones, horizonte infinito, $gamma=0,9$.
#v(0.22in)
*Dos visitas:* cuatro historias enumerables para evaluación off-policy e intervalos.
#v(0.22in)
Mismo motivo pedagógico; estimandos y datos distintos.

], "Diapositiva de consulta para evitar mezclar tablas entre clases 8–11. Fuente cap. 10, sec:ssch-intro.", "Cap. 10, sec:ssch-intro")
