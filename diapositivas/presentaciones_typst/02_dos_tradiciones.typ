// Clase 2 reconstruida desde cap01_dos_tradiciones.typ y cap05_incrustacion.typ.
// Los dos casos finitos son ejercicios didácticos distintos.
#import "tema_clases.typ": s
#set document(title: "Clase 2 — Wald, Bellman y transferencia de garantías")
#set page(width: 13.333in, height: 7.5in, margin: (x: 0.72in, y: 0.46in))
#set text(font: "Liberation Sans", size: 19pt, fill: rgb("#18253B"))

#s(1, 41, "APERTURA", "Dos preguntas sobre una decisión", [

Tras observar una medición, una regla elige una acción.
#v(0.25in)
*Pregunta Wald:* ¿qué pérdida produce la regla bajo cada modelo posible?
#v(0.25in)
*Pregunta Bellman:* ¿cómo cambia la acción las consecuencias futuras?

], "Pedir dos ejemplos: una decisión terminal y otra que altera visitas futuras. Mantener fija la información observada en ambas. 5 min.", "Cap. 1, apertura")
#s(2, 41, "OBJETIVOS", "Resultados de aprendizaje", [

+ Calcular el vector de riesgo de una regla.
+ Construir su MDP terminal y demostrar $J_theta=-R_theta$.
+ Resolver un paso de observación y parada mediante posterior.
+ Delimitar qué inferencia estadística requiere datos y supuestos adicionales.

], "Estos objetivos se comprobarán con un caso finito y un taller. 5 min.", "Cap. 1; cap. 5, thm:ch9-isomorfismo")
#s(3, 41, "RUTA", "Secuencia de 180 minutos", [

#table(columns: (2fr,1fr), inset: 7pt,
  [Motivación y marcos], [60 min],
  [Caso Wald → MDP], [30 min],
  [Descanso], [15 min],
  [Observación/parada y taller], [45 min],
  [Discusión y cierre], [30 min],
)

], "Apertura 15, desarrollo conceptual 45, caso 30, descanso 15, taller 45, discusión 20 y cierre 10. 5 min.", "PLAN_PRESENTACIONES_TYPST.md")
#s(4, 41, "HISTORIA", "Wald: comparar procedimientos", [

Una estimación, un contraste y una recomendación pueden tratarse como reglas que transforman datos en acciones.
#v(0.25in)
La distribución de $X$ bajo $theta$ determina con qué frecuencia incurre cada regla en pérdidas.
#v(0.2in)
El resultado es una *función* de riesgo, no un único número sin criterio adicional.

], "Introducir Wald 1950 a través de su problema, sin atribuir citas textuales no verificadas. 5 min.", "Cap. 1, sec:ch0-historia; wald1950statistical")
#s(5, 41, "WALD", "Cinco objetos antes de comparar", [

#table(columns: (1fr,2fr), inset: 6pt,
  [$Theta$], [modelos posibles],
  [$cal(X)$], [observaciones],
  [$P_theta$], [ley de $X$ bajo $theta$],
  [$cal(A)$], [acciones],
  [$L(theta,a)$], [pérdida],
)

], "Pedir que identifiquen cuál de los cinco objetos define la información disponible y cuál define preferencias. 5 min.", "Cap. 2, def:ch7-problema")
#s(6, 41, "WALD", "La regla y su riesgo", [

Una regla determinista $delta:cal(X) -> cal(A)$ no puede usar el $theta$ desconocido.
#v(0.2in)
#align(center)[$R(theta,delta)=sum_x P_theta (x)L(theta,delta(x)).$]
#v(0.2in)
El riesgo promedia *antes* de conocer qué $x$ se observará.

], "Distinguir el valor de L en un caso observado del riesgo de la regla completa. 6 min.", "Cap. 2, def:ch7-regla; sec:ch7-riesgo")
#s(7, 41, "WALD", "Tres criterios, tres preguntas", [

#table(columns: (1fr,2fr), inset: 7pt,
  [Admisibilidad], [¿Otra regla mejora el riesgo en todos los modelos?],
  [Bayes], [¿Qué regla minimiza el riesgo promediado por un prior?],
  [Minimax], [¿Qué regla minimiza el peor riesgo?],
)
#v(0.12in)
Ningún criterio se elige automáticamente por la forma de $R$.

], "Pedir un caso donde Bayes y minimax prefieran reglas distintas; se verá con vectores de riesgo en clase 3. 5 min.", "Cap. 1, Wald; cap. 2, sec:ch7-bayes y sec:ch7-minimax")
#s(8, 41, "HISTORIA", "Bellman: la acción cambia el futuro", [

La programación dinámica separa el resultado presente del problema que queda después.
#v(0.24in)
#align(center)[*estado actual → acción → recompensa + estado siguiente*]
#v(0.24in)
La decisión local depende del valor de continuación.

], "Presentar Bellman 1957 como marco de planificación; no equiparar recompensa inmediata con retorno total. 5 min.", "Cap. 1, sec:ch0-historia; bellman1957dynamic")
#s(9, 41, "BELLMAN", "Objetos de un MDP", [

Un MDP especifica estados $cal(S)$, acciones $cal(A)$, transición $P(s'|s,a)$, recompensa $r(s,a)$ y horizonte o descuento.
#v(0.25in)
Una política $pi(a|s)$ puede depender del estado; $V^pi (s)$ condiciona en el estado inicial.

], "Preguntar qué pieza falta si solo se conoce una tabla de recompensas. 5 min.", "Cap. 1, Bellman; cap. 3, def:ch8-mdp")
#s(10, 41, "BELLMAN", "Valor y continuación", [

Para una política fija y un modelo conocido:
#v(0.18in)
#align(center)[$V^pi (s)=sum_a pi(a|s)[r(s,a)+gamma sum_(s')P(s'|s,a)V^pi (s')].$]
#v(0.18in)
El segundo término incorpora lo que una decisión hace posible después.

], "Leer la ecuación de izquierda a derecha. Aclarar que la fórmula por sí sola no estima P ni r desde datos. 6 min.", "Cap. 1, Bellman; cap. 3, thm:ch8-bellman-pi")
#s(11, 41, "COMPARACIÓN", "Dos marcos sobre la misma pregunta", [

#table(columns: (1fr,1fr,1fr), inset: 6pt,
  table.header([Objeto], [Wald], [MDP]),
  [Información], [$X$ antes de actuar], [$S_t$ en cada decisión],
  [Criterio], [$R(theta,delta)$], [$V^pi (s)$ o $J(pi)$],
  [Dinámica], [una acción terminal], [transiciones y futuro],
)

], "La fila de Wald se refiere al problema terminal enseñado aquí; Wald admite problemas secuenciales, pero no son la construcción de un paso. 5 min.", "Cap. 1, riesgo y Bellman; cap. 5")
#s(12, 41, "VOCABULARIO", "Dos usos de «inferencia»", [

*Inferencia estadística:* aprender un objetivo desconocido con datos y cuantificar incertidumbre.
#v(0.26in)
*Ejecución de un modelo entrenado:* producir una salida, con costo, memoria y latencia.
#v(0.18in)
Una ejecución exacta no demuestra que la conclusión estadística sea válida.

], "Pedir un ejemplo de mejora de latencia que cambie la política ejecutada. 5 min.", "Cap. 1, sec:ch1-inferencia-homonimos")
#s(13, 41, "CASO FINITO", "Datos y verdad de referencia", [

$Theta={1/5,4/5}$, $X tilde "Bernoulli"(theta)$ y acciones $a in {0,1}$.
#v(0.18in)
La clase verdadera es $g(theta)=0$ para $theta=1/5$ y $g(theta)=1$ para $theta=4/5$.
#v(0.18in)
Pérdida de clasificación: $L(theta,a)=1$ si $a != g(theta)$; cero en otro caso.

], "Ejemplo didáctico de clasificación terminal, separado del SSCH. Solicitar que escriban Pθ(X=0) y Pθ(X=1). 4 min.", "Ejemplo finito derivado de cap. 5, def:ch9-wald")
#s(14, 41, "CASO FINITO", "La regla utiliza solo X", [

Definimos $delta(x)=x$ para $x in {0,1}$.
#v(0.23in)
Si $X=0$, elegimos $a=0$; si $X=1$, elegimos $a=1$.
#v(0.22in)
La misma regla se usa bajo ambos modelos $theta=1/5$ y $theta=4/5$.

], "Insistir: no cambiar la regla según θ. Eso sería observar el parámetro y alteraría el problema. 3 min.", "Cap. 5, thm:ch9-isomorfismo")
#s(15, 41, "CASO FINITO", "Riesgo bajo θ=1/5", [

La acción correcta es $0$; la regla se equivoca si $X=1$.
#v(0.2in)
#align(center)[$R(1/5,delta)=P_(1/5) (X=1)=1/5.$]
#v(0.2in)
No se promedia sobre el modelo alternativo: el riesgo se evalúa en un $theta$ fijo.

], "Pedir calcular desde la suma de la diapositiva 6. Dos términos, solo uno no nulo. 4 min.", "Cap. 5, def:ch9-wald; cálculo del caso")
#s(16, 41, "CASO FINITO", "Riesgo bajo θ=4/5", [

La acción correcta es $1$; la regla se equivoca si $X=0$.
#v(0.2in)
#align(center)[$R(4/5,delta)=P_(4/5) (X=0)=1-4/5=1/5.$]
#v(0.2in)
El vector de riesgo de $delta$ es $(1/5,1/5)$.

], "Comparar con la regla constante cero: riesgos (0,1). El vector constante no domina a δ. 4 min.", "Cap. 5, def:ch9-wald; cálculo del caso")
#s(17, 41, "REPRESENTACIÓN", "Construir el MDP terminal", [

Para cada $theta$: $S_0=X$ con ley $P_theta$; la política elige $a=pi_delta (X)=delta(X)$.
#v(0.18in)
Se recibe $r_theta (x,a)=-L(theta,a)$ y después se llega a un estado terminal de recompensa cero.
#v(0.18in)
El estado inicial puede ser aleatorio aunque la transición posterior sea determinista.

], "Dibujar en la pizarra X→acción→terminal. θ indexa la familia, no forma parte de la observación. 4 min.", "Cap. 5, def:ch9-mdp; thm:ch9-isomorfismo")
#s(18, 41, "REPRESENTACIÓN", "Retorno en cada modelo", [

La política copiada obtiene recompensa $-1$ cuando clasifica mal y $0$ cuando acierta.
#v(0.2in)
#align(center)[$J_(1/5) (pi_delta)=-1/5, quad J_(4/5) (pi_delta)=-1/5.$]
#v(0.2in)
Se promedia sobre $S_0=X$ bajo el modelo correspondiente.

], "Calcular los dos retornos antes de revelar. Distinguir J promediado de V condicionado en x. 4 min.", "Cap. 5, def:ch9-mdp; cálculo del caso")
#s(19, 41, "DEMOSTRACIÓN", "Por qué Jθ=−Rθ", [

#align(center)[$J_theta (pi_delta)=sum_x P_theta (x)r_theta (x,delta(x))$]
#v(0.15in)
#align(center)[$=-sum_x P_theta (x)L(theta,delta(x))=-R(theta,delta).$]
#v(0.18in)
La igualdad vale para *cada* $theta$ y *cada* regla de la clase construida.

], "Marcar los pasos: misma ley inicial; copia de regla; signo de recompensa; horizonte de un paso. La prueba completa se retoma en clase 6. 5 min.", "Cap. 5, thm:ch9-isomorfismo")
#s(20, 41, "LÍMITE", "Qué no demuestra esta igualdad", [

La correspondencia preserva el criterio de comparación de reglas en el modelo de una decisión.
#v(0.18in)
No identifica el valor desde datos de otra política ni proporciona un intervalo.
#v(0.18in)
Tampoco significa que la recompensa evaluativa sea observada después de actuar.

], "Preguntar qué datos se necesitarían para estimar J de una política no ejecutada. No inferir transferencia de garantías de IC. 5 min.", "Cap. 5, note:ch9-extension-no-demostrada")
#s(21, 41, "PAUSA", "Descanso de 15 minutos", [

Al volver: ¿por qué $J_theta=-R(theta,delta)$ no demuestra que podamos estimar $J_theta$ desde cualquier registro?

], "Pausar quince minutos. Reanudar pidiendo una respuesta con las palabras «datos» e «identificación».", "Plan de clase")
#s(22, 41, "EXTENSIÓN", "Ahora sí hay una decisión de observar", [

Modelo nuevo: $theta in {0,1}$ con prior $P(theta=1)=1/2$.
#v(0.18in)
Podemos decidir ahora con pérdida 0–1 o pagar $c$ para recibir una señal $Y$ y decidir después.
#v(0.18in)
Solo se permite *una* observación adicional.

], "Separar físicamente este ejemplo del MDP terminal anterior; ahora hay prior, mecanismo de observación y una decisión de parada. 4 min.", "Cap. 5, sec:ch9-secuencial; ejemplo didáctico")
#s(23, 41, "EXTENSIÓN", "La señal tiene precisión 4/5", [

#align(center)[$P(Y=theta|theta)=4/5, quad P(Y != theta|theta)=1/5.$]
#v(0.18in)
El mismo mecanismo se aplica bajo $theta=0$ y $theta=1$.
#v(0.18in)
Antes de observar, $P(Y=1)=P(Y=0)=1/2$.

], "Calcular la probabilidad predictiva por mezcla de los dos modelos. 4 min.", "Cap. 5, modelo de observación qθ; cálculo didáctico")
#s(24, 41, "EXTENSIÓN", "Si paramos ahora", [

Con prior simétrico y pérdida 0–1, cualquiera de las dos acciones terminales tiene riesgo Bayes:
#align(center)[$W_0 (b)=min{P(theta=0),P(theta=1)}=1/2.$]
#v(0.2in)
El empate se resuelve con una regla declarada.

], "Escribir el posterior antes de observar: b=(1/2,1/2). No llamar a esto riesgo frecuentista uniforme. 4 min.", "Cap. 5, thm:ch9-secuencial; cálculo didáctico")
#s(25, 41, "EXTENSIÓN", "Posterior después de Y", [

Si $Y=1$:
#align(center)[$P(theta=1|Y=1)=frac((1/2)(4/5),1/2)=4/5.$]
#v(0.15in)
Si $Y=0$, por simetría $P(theta=1|Y=0)=1/5$.
#v(0.15in)
La acción terminal sigue el valor más probable de $theta$.

], "Mostrar numerador y denominador; pedir reconstruir Y=0 antes de exponer la simetría. 5 min.", "Cap. 5, actualización B(b,y); cálculo didáctico")
#s(26, 41, "EXTENSIÓN", "Riesgo posterior tras observar", [

En ambos valores posibles de $Y$, la menor probabilidad posterior de error es $1/5$.
#v(0.19in)
Como $P(Y=0)=P(Y=1)=1/2$:
#align(center)[$E_Y[W_0 (B(b,Y))]=(1/2)(1/5)+(1/2)(1/5)=1/5.$]

], "La esperanza es sobre la señal predictiva, no sobre un θ conocido. 4 min.", "Cap. 5, thm:ch9-secuencial; cálculo didáctico")
#s(27, 41, "EXTENSIÓN", "Costo bajo: conviene observar", [

Si $c=1/10$, el riesgo Bayes de observar y decidir es:
#align(center)[$c+E_Y[W_0 (B(b,Y))]=1/10+1/5=3/10.$]
#v(0.2in)
Como $3/10<1/2$, la estrategia óptima observa.

], "Pedir comparar la cifra con parar ahora. La conclusión es bayesiana para este prior, pérdida y horizonte. 4 min.", "Cap. 5, thm:ch9-secuencial; cálculo didáctico")
#s(28, 41, "EXTENSIÓN", "Costo alto: conviene parar", [

Si $c=2/5$, observar costaría:
#align(center)[$2/5+1/5=3/5>1/2.$]
#v(0.2in)
La mejor acción es detenerse y decidir con el prior.
#v(0.2in)
La política de observación cambia aunque la precisión de $Y$ permanezca fija.

], "El costo se paga solo si se observa. Preguntar el valor crítico c*=3/10, porque 1/2−1/5=3/10. 4 min.", "Cap. 5, thm:ch9-secuencial; cálculo didáctico")
#s(29, 41, "BELLMAN BAYES", "Recursión del riesgo restante", [

Para $k$ observaciones posibles:
#align(center)[$W_0 (b)=min_a ell(b,a)$]
#v(0.12in)
#align(center)[$W_k (b)=min{min_a ell(b,a), c+sum_y m_b (y)W_(k-1) (B(b,y))}.$]
La decisión compara *parar* con *observar y continuar*.

], "Derivar el caso k=1 con los números anteriores. El posterior b y k forman el estado; la prueba formal es por inducción. 6 min.", "Cap. 5, thm:ch9-secuencial")
#s(30, 41, "TALLER", "Tarea: cambiar la precisión", [

Mantenga prior $1/2$ y pérdida 0–1, pero use señal correcta con probabilidad $7/10$.
#v(0.16in)
1. Calcule el riesgo posterior esperado tras una observación.
#v(0.12in)
2. Compare observar con parar para $c=1/10$ y $c=1/4$.
#v(0.12in)
3. Escriba el umbral de costo para que observar mejore el riesgo.

], "45 minutos en equipos para diapositivas 30–31: 5 consigna, 25 cálculo, 15 cotejo y discusión. No usar resultados de la señal 4/5 sin recalcular. Fuente: misma recursión, parámetro cambiado.", "Cap. 5, thm:ch9-secuencial; variante didáctica")
#s(31, 41, "SOLUCIÓN", "Resultado del taller", [

Con precisión $7/10$, el error posterior mínimo es $3/10$.
#v(0.15in)
Para $c=1/10$: $1/10+3/10=2/5<1/2$ → observar.
#v(0.15in)
Para $c=1/4$: $1/4+3/10=11/20>1/2$ → parar.
#v(0.15in)
Observar mejora si $c<1/5$; en el umbral hay empate.

], "Solicitar que justifiquen la probabilidad predictiva 1/2 y el posterior 7/10 o 3/10. El riesgo posterior esperado es 3/10. Cerrar taller con comparación de dos costos.", "Cálculo del taller")
#s(32, 41, "DISCUSIÓN", "Dos construcciones, dos alcances", [

*Una decisión terminal:* copia una regla dada y conserva $J_theta=-R(theta,delta)$ para cada modelo.
#v(0.18in)
*Observación y parada:* optimiza sobre si comprar información; necesita prior, $q_theta$, costo y horizonte.
#v(0.18in)
La segunda no se obtiene gratis de la primera.

], "20 minutos de discusión: pedir que cada equipo enumere la información adicional exigida para observación/parada.", "Cap. 5, thm:ch9-isomorfismo y thm:ch9-secuencial")
#s(33, 41, "DISCUSIÓN", "¿Qué no se transfirió?", [

El cálculo de $J=-R$ no aportó:
+ un mecanismo para registrar recompensas observables;
+ soporte para evaluar acciones no elegidas;
+ una distribución muestral para construir un IC.
#v(0.12in)
Cada resultado inferencial exige su propio diseño y sus hipótesis.

], "Pedir una condición para OPE y otra para un IC. Respuestas esperadas: overlap y control de varianza/unidad muestral, respectivamente.", "Cap. 1, encuentro en OPE; cap. 5, note:ch9-extension-no-demostrada")
#s(34, 41, "DISCUSIÓN", "Ejecutar un modelo no es estimar un valor", [

Un sistema puede producir una acción en milisegundos y ejecutar correctamente su código.
#v(0.2in)
Eso no demuestra que $V^pi$ esté identificado, estimado sin sesgo o cubierto por un intervalo.
#v(0.2in)
Una mejora de latencia puede cambiar la política; habría que comprobarlo.

], "Utilizar los dos sentidos de inferencia del capítulo 1. Pedir un ejemplo de cambio de implementación que altere probabilidades de acción.", "Cap. 1, sec:ch1-inferencia-homonimos")
#s(35, 41, "COMPROBACIÓN", "Clasifique estas tres afirmaciones", [

A. «En el MDP terminal, $J_theta (pi_delta)=-R(theta,delta)$».
#v(0.13in)
B. «Con $c=1/10$ y señal $4/5$, conviene observar bajo el prior fijado».
#v(0.13in)
C. «Un IC para $J$ tendrá cobertura 95 % en un registro real».
#v(0.13in)
¿Qué hipótesis y evidencia sostienen cada una?

], "A: teorema con condiciones de construcción; B: cálculo Bayes específico; C: no se deduce, requiere diseño, estimador y condiciones de inferencia. 5 min.", "Caps. 1 y 5")
#s(36, 41, "CIERRE", "Tres ideas para la clase siguiente", [

1. El *riesgo* evalúa reglas bajo modelos posibles.
#v(0.15in)
2. Bellman añade transiciones y consecuencias futuras.
#v(0.15in)
3. La identidad de un paso conserva una comparación, no toda garantía.
#v(0.2in)
Siguiente clase: riesgo, Bayes, minimax y admisibilidad de Wald.

], "10 minutos con la comprobación anterior. Lectura previa: cap. 2, secciones de riesgo y Bayes.", "Cap. 1, cierre")
#s(37, 41, "RESPALDO", "La posterior en dos líneas", [

Con prior $1/2$ y señal correcta $q$:
#align(center)[$P(Y=1)=(1/2)q+(1/2)(1-q)=1/2.$]
#v(0.18in)
#align(center)[$P(theta=1|Y=1)=frac((1/2)q,1/2)=q.$]
Para $Y=0$, la posterior de $theta=1$ es $1-q$.

], "Respaldar la solución del taller sin usar fórmulas memorizadas. Fuente: Bayes y modelo del ejemplo.", "Derivación didáctica a partir de cap. 5")
#s(38, 41, "RESPALDO", "Prueba por inducción del paso Bellman", [

Base: con $k=0$, solo queda elegir $a$ y pagar $ell(b,a)$.
#v(0.18in)
Paso: con $k>0$, o se decide ya o se paga $c$, se observa $y$ con probabilidad $m_b (y)$ y queda el problema óptimo de $k-1$.
#v(0.18in)
El mínimo de las dos alternativas da $W_k (b)$.

], "Prueba esquemática para el modelo finito; la fuente completa está en el apéndice de demostraciones.", "Cap. 5, thm:ch9-secuencial; apéndice A")
#s(39, 41, "RESPALDO", "Tres reglas en el caso finito", [

#table(columns: (1fr,1fr,1fr), inset: 7pt,
  table.header([Regla], [$R(1/5,delta)$], [$R(4/5,delta)$]),
  [$delta(x)=x$], [$1/5$], [$1/5$],
  [$delta(x)=0$], [$0$], [$1$],
  [$delta(x)=1$], [$1$], [$0$],
)
Ninguna de las constantes domina a $delta(x)=x$.

], "El propósito es visualizar que el riesgo es un vector sobre Θ. La clase 3 definirá dominancia formal.", "Caso finito de esta clase")
#s(40, 41, "RESPALDO", "Falta de soporte: un contraejemplo", [

Si la política de registro nunca elige $a=1$, los datos no contienen recompensas de esa acción.
#v(0.22in)
Dos entornos pueden producir el mismo registro bajo $a=0$ y asignar valores distintos a $a=1$.
#v(0.22in)
Por ello el valor de una política que elige $a=1$ no queda identificado solo por ese registro.

], "No confundir este problema con la identidad J=−R, que es una igualdad dentro de modelos dados.", "Cap. 7, ass:ch10-overlap; anticipo")
#s(41, 41, "RESPALDO", "Fuentes para continuar", [

*Wald (1950):* Statistical Decision Functions.
#v(0.16in)
*Bellman (1957):* Dynamic Programming.
#v(0.16in)
*Libro local:* capítulos 1, 2, 3 y 5; prueba detallada en apéndice A.
#v(0.16in)
Cada cita concreta debe cotejarse con su entrada en `referencias.bib`.

], "Diapositiva de consulta. Las referencias se toman de las claves bibliográficas del manuscrito, sin citas textuales directas.", "Cap. 1, wald1950statistical y bellman1957dynamic")
