#import "../plantilla.typ": *

#cap-sin-numero[
= Introducción
<ch:introduccion>
]

Una señal imperfecta puede bastar para cambiar una decisión. Un sistema de
seguimiento, por ejemplo, observa una medición y elige entre mantener la
atención habitual o intensificarla. Para decidir necesita algo más que una
predicción: debe considerar cuánto cuesta cada error y qué información
estaba disponible al actuar. Si la intervención modifica las observaciones
de la visita siguiente, la misma pregunta adquiere una dimensión temporal.

La teoría de decisión estadística y los procesos de decisión de Markov
permiten describir esas dos situaciones. Wald compara reglas mediante la
pérdida que producen bajo distintos modelos posibles. La programación
dinámica organiza las consecuencias presentes y futuras de las acciones.
Este libro recorre la relación entre ambos enfoques para estudiar qué
puede conservarse al pasar de uno a otro y qué exige una justificación nueva.

El ejemplo de seguimiento reaparece a lo largo de la exposición como un
Sistema de Soporte Clínico para Hipertensión, SSCH. Se trata de un escenario
sintético: las cifras permiten comprobar cálculos y observar fallos en un
modelo conocido. Sus variantes responden a preguntas distintas; el
@ch:casos especifica cuáles comparten una dinámica y cuáles constituyen
experimentos separados.

== De una decisión a su representación secuencial
<sec:ch0-tesis>

La relación entre los marcos se vuelve precisa cuando conservamos la
información que utiliza quien decide. El parámetro desconocido indexa los
modelos posibles, mientras que la observación determina qué acción puede
elegirse. En el @ch:isomorfismo, esa decisión se representa mediante una
familia de MDP con una sola acción antes de llegar al estado terminal.

#thm-env("definition", name: [Representación de una decisión estadística], key: "def:isomorfismo-informal")[
  Una regla que transforma la observación en una acción puede interpretarse
  como una política sobre esa misma observación. Si la recompensa de cada
  modelo es la pérdida con signo cambiado, el retorno promedio de la
  política coincide con el riesgo negativo de la regla. El parámetro
  permanece desconocido y no se incorpora a la información disponible para
  elegir la acción. El @thm:ch9-isomorfismo establece las condiciones y la
  identidad exacta de esta representación.
]

La correspondencia permite traducir los criterios de Bayes, minimax y
admisibilidad cuando se mantiene la misma clase de reglas. Al incorporar
observaciones sucesivas, en cambio, hay que especificar cómo se generan y
qué memoria resume la historia. El problema bayesiano de observación y
parada del @ch:isomorfismo muestra una extensión concreta con horizonte
finito y un posterior que actúa como estado de información.

#block(breakable: false)[
#mi-tabla(
  caption: [Objetos que deben conservarse al representar una decisión. Las garantías inferenciales se justifican para el experimento y el procedimiento correspondientes.],
  key: "tab:correspondencia-central",
  table(
    columns: (23%, 38%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Objeto*], [*Papel en la representación*], [*Distinción que debe mantenerse*]),
    hl(w: 0.6pt),
    [$ParamSpace$], [Índice desconocido de la familia de modelos], [El decisor no observa el parámetro],
    [$SampleSpace$], [Observación que recibe la política], [La información disponible es la misma],
    [$ActionSpace$], [Conjunto común de acciones], [Se compara la misma clase de reglas],
    [$Loss(theta,a)$], [Recompensa con signo cambiado], [La evaluación conserva su dependencia del modelo],
    [$Risk(theta,decrule)$], [Retorno promedio negativo], [El promedio usa la distribución de la observación],
    [Intervalo, test o estimador], [Procedimiento estadístico sobre datos], [Su garantía requiere hipótesis adicionales],
    hl(),
  ),
)
]

Esta separación orienta el resto del libro. Una identidad entre objetivos
no aporta por sí sola datos informativos sobre una política nueva. La
suficiencia estadística de una muestra tampoco asegura que su resumen sea
un estado de Markov controlado. Para evaluar una política necesitamos
identificar su valor en la distribución observada; para construir un
intervalo, controlar además el error de estimación y su varianza.

== El recorrido de la exposición

El @ch:tradiciones sitúa las preguntas en las dos tradiciones que las
formularon. Después, el @ch:wald introduce pérdidas, riesgos y criterios de
comparación, y el @ch:mdp-bellman añade las consecuencias futuras de una
acción. El @ch:herramientas desarrolla las propiedades estadísticas que
se utilizarán al estudiar datos y estimadores.

Con ese vocabulario, el @ch:isomorfismo construye la representación de
una decisión y el @ch:fallos examina dónde cambia el problema al extenderla.
Los capítulos de evaluación e intervalos (@ch:ope y @ch:inferencia)
precisan entonces qué permiten aprender los datos de otra política y cómo
cuantificar la incertidumbre. El @ch:verificacion convierte esas exigencias
en una revisión de afirmaciones concretas.

Los cálculos del @ch:casos ponen a prueba la comprensión del recorrido:
cada experimento declara su modelo y compara lo calculado con el objetivo
que pretende estimar. El @ch:despliegue examina qué debe revisarse al llevar
un procedimiento a una implementación y a una población determinadas.
El @ch:problemas cierra la exposición con las preguntas que permanecen
cuando la información es parcial, la política no puede evaluarse o la
dependencia temporal es difícil de controlar.

== Guía de lectura
<sec:ch0-guia>

Quien se interese por la decisión estadística puede seguir desde el
@ch:wald hasta el @ch:isomorfismo y consultar el @ch:herramientas según
las propiedades inferenciales que necesite. Para estudiar evaluación de
políticas, el recorrido central pasa por el @ch:ope y el @ch:inferencia,
con apoyo en las funciones de influencia, el método delta y la dependencia
temporal. El @ch:verificacion ayuda a relacionar cada resultado con una
aplicación.

Quien provenga del aprendizaje por refuerzo puede comenzar por el
@ch:mdp-bellman y contrastar después la planificación con modelo conocido
con los problemas de estimación del @ch:ope. Para el diseño de sistemas,
el @ch:despliegue y el Apéndice~#ref(<app:langgraph>, supplement: none)
permiten seguir el paso del procedimiento estadístico al código. Las
fronteras de los agentes de lenguaje se discuten en el @ch:problemas;
su lectura presupone distinguir una política ejecutable de una política
cuya probabilidad de acción se conoce.

#[
#set heading(numbering: none, outlined: false)
=== Prerrequisitos formales
]

La exposición utiliza esperanza condicional, convergencia de variables
aleatorias y nociones de medida, junto con estimación, contrastes e
intervalos de confianza. Las normas, las proyecciones y los argumentos de
contracción requieren álgebra lineal y análisis. El
Apéndice~#ref(<app:medido>, supplement: none) reúne las definiciones técnicas
y el glosario permite recuperar la notación cuando cambia el contexto.

La primera distinción que conviene llevar a la lectura es sencilla:
una regla puede estar bien definida y un algoritmo puede calcularla con
precisión, mientras que su valor en el entorno sigue siendo desconocido.
Comprender cómo se pasa de una afirmación a la otra será el hilo del libro.
