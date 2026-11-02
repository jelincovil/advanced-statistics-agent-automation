#import "plantilla.typ": *

#cap-sin-numero[
= Prefacio
<prefacio>
]

== Una pregunta que une el recorrido

Un agente observa una parte del mundo y debe actuar antes de conocerlo por
completo. Puede estimar qué ocurrirá, comparar las consecuencias de sus
acciones o aplazar la decisión para obtener información. En cualquiera de
esos casos necesita distinguir lo que sabe de lo que supone. Esta monografía
estudia cómo expresar esa distinción con las herramientas de la teoría de
decisión y de la inferencia estadística.

La pregunta que guía el libro es qué permite afirmar una garantía cuando se
pasa de un problema estadístico a un sistema que decide de manera secuencial.
La teoría de Wald aporta el lenguaje de pérdidas, riesgos y reglas; los
procesos de decisión de Markov describen cómo una acción modifica las
posibilidades futuras. Entre ambos se construye una representación precisa
de una decisión de Wald como una familia de MDP de un paso. La identidad
entre riesgo y retorno que resulta de esa construcción permite comparar las
mismas reglas en los dos lenguajes (@thm:ch9-isomorfismo).

Al llegar a la evaluación de políticas, aparecen preguntas adicionales.
Los datos pueden proceder de otra política, las observaciones de una misma
trayectoria pueden depender entre sí y la política evaluada puede haberse
aprendido con esos datos. La representación de una decisión ayuda a formular
el problema; cada conclusión inferencial exige además su propio resultado,
con un objetivo, un procedimiento y unas hipótesis definidos.

== Cómo se desarrolla el argumento

El recorrido empieza por las dos tradiciones que dieron forma a estas
preguntas. La primera parte presenta la decisión de Wald y la planificación
en MDP, y reúne las herramientas estadísticas necesarias para estudiar
estimadores e incertidumbre. La segunda establece la representación entre
los marcos y examina los cambios que pueden invalidar una transferencia.
Con esa distinción, la tercera parte aborda la evaluación de políticas con
datos de otra política, los intervalos para su valor y la revisión de las
condiciones que sostienen cada afirmación.

La cuarta parte lleva esas preguntas a cálculos y programas reproducibles.
El caso sintético de soporte clínico permite seguir decisiones, estimadores
y límites sin atribuir a las cifras una validación médica. Los laboratorios
amplían ese recorrido y el capítulo de despliegue estudia qué ocurre cuando
se modifica la implementación o la población. El último capítulo retoma las
preguntas que siguen abiertas y precisa qué faltaría para responderlas.

Los apéndices acompañan la lectura. Las demostraciones desarrollan argumentos
que conviene consultar junto con sus enunciados; el glosario, las tablas y
las condiciones de regularidad permiten recuperar una definición sin
interrumpir el argumento principal. El apéndice de LangGraph describe una
posible organización del código, y el de reproducción distingue el diseño
del experimento de los resultados que todavía deben obtenerse.

== Preparación y formas de lectura

Se presupone familiaridad con probabilidad, esperanza condicional,
estimación y contrastes de hipótesis, junto con nociones de álgebra lineal y
análisis. La formulación de los MDP se desarrolla en el @ch:mdp-bellman;
no hace falta experiencia previa con una biblioteca de agentes para seguir
el argumento.

La lectura continua permite ver cómo una misma pregunta cambia al introducir
nuevos datos o decisiones futuras. Quien ya conozca estadística matemática
puede consultar el @ch:herramientas según lo necesite y detenerse en la
representación del @ch:isomorfismo. Quien trabaje en aprendizaje por refuerzo
puede comenzar por el @ch:mdp-bellman y volver al @ch:wald para examinar
cómo se comparan las reglas bajo incertidumbre. La Introducción propone
otros recorridos de acuerdo con el problema que interese al lector.

== El alcance de una garantía

A lo largo del libro, una garantía acompaña siempre a una afirmación
concreta. Puede referirse al riesgo de una regla, a la convergencia de un
algoritmo o a la cobertura de un intervalo. Conviene conservar esa precisión
al interpretar los ejemplos: resolver la planificación dentro de un modelo
conocido y estimar el valor de una política a partir de datos plantean
exigencias diferentes.

El @ch:verificacion ofrece un procedimiento para registrar esa relación
entre afirmación, hipótesis y evidencia. Los diagnósticos, las simulaciones
y la documentación del diseño aportan información complementaria. Cuando
una condición queda sin justificar, la conclusión conserva ese límite.
Los problemas pendientes de reproducción se indican junto al experimento
al que pertenecen.

== Agradecimientos

El profesor Jaime Lincovil agradece a la comunidad de profesores y alumnos
del doctorado de Estadística la oportunidad de compartir y discutir la
aplicación de la teoría y los métodos estadísticos al diseño de agentes.

#v(2em)
#align(right)[_Lima, Perú, marzo de 2026_]
