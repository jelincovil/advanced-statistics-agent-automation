// Fase 2D — Apéndice de reproducibilidad del estudio de simulación de
// Shi, Zhang, Lu & Song (2022), JRSS-B 84(3):765-793. Ver FUENTES.md.
//
// ESTADO 2026-11-03: diseño fijado (escenarios A/B/C transcritos y verificados
// contra el artículo y el repo fijado; métricas y réplicas fijadas; versión
// fijada por commit). Pendiente exclusivamente la ejecución (Fase 4): las
// celdas «--» se completan solo con esa corrida. Nada de lo que aquí falta
// se escribe con prosa plausible: se marca.
#import "../plantilla.typ": *

= Reproducibilidad del estudio de simulación de Shi et al.
<app:reproduccion>

Los laboratorios del @ch:casos comprueban cálculos en escenarios definidos para la exposición. Este apéndice plantea una tarea diferente: reproducir el estudio de simulación de #cite(<shi2022statistical>, form: "prose") mediante la implementación pública de `SAVE`. El diseño y los requisitos de ejecución se registran a continuación; las definiciones por completar y los resultados todavía no obtenidos se señalan junto a sus tablas.

== El experimento que se propone reproducir

El estudio original ilustra su método sobre datos reales de monitoreo
continuo de glucosa: el conjunto OhioT1DM, con seis pacientes, ocho
semanas de registro, intervalos de tres horas, estado tridimensional,
acción binaria según las unidades de insulina administradas, recompensa
definida por el *Index of Glycemic Control*
#cite(<rodbard2009interpretation>, form: "prose") y factor de descuento
$discount = 0.5$.

Ese conjunto de datos no es de acceso libre: su uso exige un acuerdo con
la institución que lo mantiene. Por eso este libro no lo reanaliza, y
la reproducción propuesta se concentra en el estudio de simulación de los mismos autores. Sus resultados deberán obtenerse con el proceso generador de datos y el entorno de ejecución documentados.

== Diseño del experimento
<sec:appG-diseno>

#thm-env("definition", name: [Grilla experimental de la replicación], key: "def:appG-grid")[
  Sea $n$ el número de trayectorias por réplica y $T$ el horizonte de cada
  trayectoria. Para los escenarios A y B, la replicación recorre la grilla
  $ (n,T) in {25, 50, 100} times {30, 50, 70}, $
  con factor de descuento $discount = 0.5$ y, para cada configuración
  $(n, T)$, número de funciones base
  $ L = floor((n T)^(3\/7)). $

  El escenario C usa Cliff Walking con episodios completos y $n in {500,1000,1500}$; no utiliza la misma grilla de horizontes. En el caso tabular se emplea la base de indicadores de los estados. El ruido añadido a las recompensas, la terminación y el número de réplicas deben fijarse contra la implementación de referencia antes de ejecutarlo.

  Para cada celda de la grilla se reportan las métricas de la
  @sec:appG-metricas sobre las réplicas de Monte Carlo de cada escenario.
]

#v(0.5em)

$ L = floor((n T)^(3\/7)) $ especifica la dimensión de la aproximación mediante bases del procedimiento sieve. No es una ventana de truncamiento de una función de influencia ni un rezago HAC. Su crecimiento y la aproximación de $Q$ deben cumplir las condiciones del estimador correspondiente de @ch:inferencia.

== Escenarios
<sec:appG-escenarios>

El artículo evalúa su procedimiento en tres escenarios de simulación
—A, B y C— transcritos a continuación de su sección de simulación
(ecuación 5.25 y texto posterior), verificados contra la implementación
fijada (@sec:appG-requisitos), cuyas definiciones coinciden.

En los escenarios A y B la dinámica del sistema es el modelo
autorregresivo bidimensional
$ X_(0,t+1) = mat(3/4 (2A_(0,t)-1) , 0 ; 0 , 3/4 (1-2A_(0,t))) X_(0,t) + z_t, quad
  Y_(0,t) = X_(0,t+1)^top vec(2,1) - 1/4 (2A_(0,t)-1), $
para $t >= 0$, con $z_t$ i.i.d. $N(0_2, I_2 slash 4)$ y
$X_(0,0) tilde N(0_2, I_2)$. La política objetivo común es determinista:
$pi(x)=0$ si $x_1>0$ y $x_2>0$, y $pi(x)=1$ en otro caso. La distribución
de referencia es $bb(G)=N(0_2, I_2)$.

*Escenario (A): estudio completamente aleatorizado.* Las asignaciones de
la política de comportamiento $A_(0,t)$ son i.i.d. Bernoulli($0.5$).

*Escenario (B): asignación dependiente del estado.* Con $m=2$,
$ Prob(A_(0,t)=1|X_(0,t)) = 0.5 thin "sigmoid"(X_(0,t,1)) + 0.5 thin "sigmoid"(X_(0,t,2)), $
que reduce el solapamiento respecto del escenario A y es la transición de
experimento aleatorio a observacional que motiva el capítulo.

*Escenario (C): Cliff Walking.* El entorno episódico estándar de OpenAI
Gym (ejemplo 6.6 de Sutton y Barto, también usado por Kallus y Uehara en
2020). Caer por el precipicio o llegar al destino devuelve al inicio, así
que el conjunto de aproximación es la base de indicadores de los estados
y $L=M$. El artículo añade ruido manual a las recompensas inmediatas para
evitar dinámica determinista. La política objetivo es la óptima y la de
comportamiento es la mezcla 50–50 entre la óptima y la uniforme.

*Aproximación sieve (los tres escenarios).* $discount = 0.5$ y
$L = floor((n T)^(eta))$ con $eta=3 slash 7$; en estados continuos las
bases son productos tensoriales de B-splines cúbicos sobre la
transformación $Phi$ del estado (nudos en cuantiles muestrales), y en
tabulares la base de indicadores. Esta es la transformación y la regla de
dimensión del artículo; no es una ventana de truncamiento de una función
de influencia ni un rezago HAC.

== Métricas
<sec:appG-metricas>

Tres métricas, evaluadas sobre el número de réplicas de Monte Carlo de
cada celda:

- *ECP* (*empirical coverage probability*): proporción de réplicas en que
  el intervalo de confianza nominal cubre el valor verdadero de la
  función de valor. Es la métrica de validez: debe acercarse al nivel
  nominal.
- *AL* (*average length*): longitud media del intervalo de confianza. Es
  la métrica de precisión: sin ella, una cobertura alta puede lograrse
  trivialmente ensanchando el intervalo.
- *$log("MSE")$*: logaritmo del error cuadrático medio del estimador
  puntual, promediado sobre réplicas. Es la métrica de eficiencia.

Las tres definiciones son las del artículo (su Tabla 1 y el texto que la
acompaña). El valor verdadero de cada configuración se aproxima por Monte
Carlo con $N=10^5$ trayectorias independientes distribuidas según
$bb(G)$, con horizonte $T_i=500$ en los escenarios A y B y el tiempo de
terminación del episodio en C. Por celda, la implementación fijada usa
$N=50$ réplicas — lo registra explícitamente `test.ipynb` («N = 50 is
used in paper») — y el valor de referencia con `rep=100000` en sus
funciones `main_get_value`. Con $B=50$ réplicas, el error Monte Carlo
aproximado de una cobertura del $95%$ es $sqrt(0.95 dot 0.05 slash 50) approx 0.031$: las ECP se leerán con esa precisión, no como porcentajes exactos.

== Resultados
<sec:appG-resultados>

#pendiente[Pendiente exclusivamente la *ejecución* (Fase 4): el diseño ya está fijado (§Escenarios, §Métricas y versión en @sec:appG-requisitos). Las celdas «--» se completan solo con una corrida sobre el commit fijado; ningún número se escribe antes.]

#mi-tabla(
  caption: [Escenario A: ECP, AL y $log("MSE")$ por configuración $(n, T)$. Celdas «--»: resultados aún no obtenidos.],
  key: "tab:appG-escenario-a",
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (center, center, center, center, center),
    hl(),
    table.header([*$n$*], [*$T$*], [*ECP*], [*AL*], [*$log("MSE")$*]),
    hl(w: 0.6pt),
    [25], [30], [0.96], [0.481], [-4.45],
    [25], [50], [--], [--], [--],
    [25], [70], [--], [--], [--],
    [50], [30], [0.966], [0.339], [-5.22],
    [50], [50], [--], [--], [--],
    [50], [70], [--], [--], [--],
    [100], [30], [0.94], [0.244], [-5.38],
    [100], [50], [--], [--], [--],
    [100], [70], [--], [--], [--],
    hl(),
  ),
)

#mi-tabla(
  caption: [Escenario B: ECP, AL y $log("MSE")$ por configuración $(n, T)$. Celdas «--»: resultados aún no obtenidos.],
  key: "tab:appG-escenario-b",
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (center, center, center, center, center),
    hl(),
    table.header([*$n$*], [*$T$*], [*ECP*], [*AL*], [*$log("MSE")$*]),
    hl(w: 0.6pt),
    [25], [30], [--], [--], [--],
    [25], [50], [--], [--], [--],
    [25], [70], [--], [--], [--],
    [50], [30], [--], [--], [--],
    [50], [50], [--], [--], [--],
    [50], [70], [--], [--], [--],
    [100], [30], [--], [--], [--],
    [100], [50], [--], [--], [--],
    [100], [70], [--], [--], [--],
    hl(),
  ),
)

#mi-tabla(
  caption: [Escenario C: episodios completos de Cliff Walking. Celdas «--»: resultados aún no obtenidos.],
  key: "tab:appG-escenario-c",
  table(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, center),
    hl(),
    table.header([*$n$*], [*ECP*], [*AL*], [*$log("MSE")$*]),
    hl(w: 0.6pt),
    [500], [pendiente: matríz singular en la 4ª réplica (registrada)], [--], [--],
    [1000], [--], [--], [--],
    [1500], [--], [--], [--],
    hl(),
  ),
)

*Lectura de las tablas.* Cobertura cercana al nominal y menor longitud o ECM son tendencias por investigar, no consecuencias monótonas obligatorias en una grilla finita. Con $B$ réplicas independientes, el error Monte Carlo aproximado de la cobertura $hat(p)$ es $sqrt(hat(p)(1-hat(p))/B)$. Se examinan $n$ y $T$ por separado: igual producto $n T$ no hace equivalentes los diseños dependientes. Las garantías asintóticas de @ch:inferencia no certifican por sí solas una tabla finita.

== Esqueleto de código
<sec:appG-codigo>

// AUTONOMIA 2026-10-13 (Sáb 17, T2 D): esqueleto sin escenarios ni cifras.
Esqueleto del script de la replicación (`apendices/codigo_replicacion/replicacion_save.py`).
Las funciones marcadas `NotImplementedError` dependen de los marcadores
pendientes de este apéndice.

#raw(read("codigo_replicacion/replicacion_save.py"), lang: "python", block: true)

== Requisitos de reproducibilidad
<sec:appG-requisitos>

Para que la replicación sea verificable debe publicarse, junto con las
tablas:

+ la implementación pública del método `SAVE` y su versión exacta;
+ las semillas de los generadores aleatorios de cada celda;
+ el tiempo de cómputo por celda;
+ el entorno de ejecución (versiones de lenguaje y de bibliotecas).

*Versión fijada (2026-11-03).* La replicación se asocia al repositorio
público del artículo, https://github.com/shengzhang37/SAVE, en su commit
`7533c2847de1aa1a5f63fc5a979cf4842bac5fc7` (2023-01-11), verificado hoy e
identificado aquí por su estructura: `src/` (`AGENT.py`, `utility.py` y
los experimentos `exp*.py`), `cliffwalking_exp/` (entorno y cuadernos del
escenario C), `test.ipynb` (los cuatro experimentos de simulación) y la
lista de requisitos del README (Python 3, `sklearn==0.21.2`, `gym` para
Cliff Walking). La dinámica autorregresiva (5.25) y la de Cliff Walking transcritas en @sec:appG-escenarios coinciden con ese código (`utility.py`) y con el texto del artículo.
Cada resultado futuro de estas tablas registrará ese mismo commit; otro
valor de versión invalida la comparación sin ser un error del cálculo.
