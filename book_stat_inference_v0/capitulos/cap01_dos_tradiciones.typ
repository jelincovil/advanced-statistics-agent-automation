#import "../plantilla.typ": *

= Dos tradiciones y el problema de la transferencia de garantías
<ch:tradiciones>

La decisión de seguimiento de la Introducción admite dos preguntas.
Podemos comparar el costo de las reglas que actúan después de una medición,
o estudiar cómo una intervención cambia las oportunidades de las visitas
futuras. La primera conduce al riesgo estadístico; la segunda, a la función
de valor. Seguir el origen de esos conceptos permite entender tanto su
relación como las diferencias que habrá que conservar.

== Riesgo estadístico y consecuencias futuras
<sec:ch0-historia>

Los trabajos de Wald y Bellman ofrecen dos maneras de organizar una decisión
bajo incertidumbre. Cada una hace explícito un aspecto del problema:
qué se pierde al actuar sin conocer el modelo y cómo se acumulan las
consecuencias de una acción a lo largo del tiempo.

#[
#set heading(numbering: none, outlined: false)
=== La síntesis de Wald (1950)
]

En _Statistical Decision Functions_, #cite(<wald1950statistical>, form: "prose")
formula la comparación de procedimientos a partir de observaciones,
acciones y pérdidas. Una estimación o un contraste pueden verse así como
reglas que eligen una acción. La distribución de los datos determina con
qué frecuencia cada regla incurre en una pérdida bajo un modelo dado.

La función de riesgo
$R(theta, decrule) = EE_theta [L(theta, decrule (X))]$
reúne esas consecuencias en un criterio de comparación. A partir de ella
aparecen preguntas diferentes. La admisibilidad busca descartar reglas
dominadas; una regla de Bayes minimiza el riesgo promedio bajo un prior;
el criterio minimax compara el peor riesgo sobre los modelos considerados.
La preferencia por uno de esos criterios depende del problema que se haya
formulado y de la información que se esté dispuesto a introducir.

#[
#set heading(numbering: none, outlined: false)
=== La programación dinámica de Bellman (1957)
]

Cuando una acción altera el futuro, su pérdida inmediata deja de resumir
todas sus consecuencias. La programación dinámica de
#cite(<bellman1957dynamic>, form: "prose") aborda esta dependencia al separar
la acción presente del problema que queda por resolver después. El
principio de optimalidad permite repetir esa separación en cada estado.

En la formulación de MDP que estudiaremos, la tupla
$(StateSpace, ActionSpace, P, r, gamma)$ especifica estados, acciones,
transiciones, recompensas y descuento. Para una política fija, la función
de valor expresa el retorno esperado desde un estado y satisface la
recursión
$ V^pi (s) = sum_a pi(a|s) [r(s,a) + gamma sum_(s') P(s'|s,a) V^pi (s')]. $
La ecuación permite calcular valores dentro del modelo. Cuando sus
transiciones o recompensas se desconocen, aparece además un problema
estadístico: aprender lo necesario para que el cálculo responda al
entorno que interesa.

#[
#set heading(numbering: none, outlined: false)
=== El encuentro en la evaluación de políticas
]

La evaluación de una política con datos generados por otra reúne ambas
perspectivas. El objetivo se define mediante un retorno secuencial, pero
los datos disponibles obligan a estudiar identificación, error de estimación
y precisión. La literatura de evaluación _off-policy_ y de inferencia
semiparamétrica proporciona resultados para responder a esas preguntas
bajo modelos y diseños muestrales específicos.

El trabajo de #cite(<shi2022statistical>, form: "prose") sobre intervalos
para funciones de valor y la revisión de
#cite(<kennedy2022semiparametric>, form: "prose") sobre estimación
doblemente robusta permiten seguir dos aspectos de ese encuentro. Más
adelante distinguiremos la aproximación de Bellman mediante bases de las
construcciones basadas en funciones de influencia. Ambas se ocupan de la
incertidumbre, con procedimientos e hipótesis que conviene leer por separado.

== Dos sentidos de «inferencia»
<sec:ch1-inferencia-homonimos>

En este recorrido, «inferencia» se refiere a aprender algo sobre un objetivo
desconocido a partir de datos y a precisar la incertidumbre de esa conclusión.
Un intervalo para el valor de una política es un ejemplo. Su interpretación
depende del muestreo y del procedimiento que lo produce.

En ingeniería de aprendizaje automático también se llama _inference_ a
la ejecución de un modelo entrenado. En ese uso se estudian el tiempo de
respuesta, la memoria o el costo de producir una salida. Ejecutar el modelo
puede formar parte de un procedimiento estadístico, pero las propiedades
del cálculo y las de la conclusión obtenida requieren argumentos distintos.

La diferencia será especialmente útil en el @ch:despliegue. Una mejora de
latencia puede conservar el procedimiento, introducir un error numérico o
modificar las probabilidades de las acciones. Antes de trasladar una garantía
habrá que precisar cuál de esos cambios ocurrió.

== Cómo leer una garantía a lo largo del libro
<sec:ch0-filosofia>

Las garantías que utilizaremos se refieren a objetos delimitados. Una regla
bayesiana se compara bajo un prior; la contracción de Bellman se establece
para un operador y una norma; un intervalo se interpreta en una secuencia
de experimentos. Su utilidad depende de poder reconocer esos objetos en la
aplicación que se tiene entre manos.

Por eso el libro vuelve sobre el mismo ejemplo desde distintas preguntas.
Primero interesa qué regla reduce una pérdida. Después, cómo planificar con
una dinámica conocida y qué permiten estimar los datos cuando esa dinámica
debe aprenderse. Finalmente, importa si la implementación y la población
conservan las condiciones del análisis. Los cambios de pregunta se hacen
explícitos para que las conclusiones mantengan su alcance.

El @ch:isomorfismo precisará la identidad entre riesgo y retorno en la
representación de una decisión. Los @ch:fallos y @ch:problemas examinarán
lo que hace falta al introducir nuevas formas de dependencia, información
parcial o políticas complejas. El punto de partida es la comparación de
reglas de Wald: antes de calcular una decisión, debemos definir qué cuenta
como error y bajo qué modelos la evaluaremos.
