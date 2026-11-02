// Fase 2D — Apéndice de reproducibilidad del estudio de simulación de
// Shi, Zhang, Lu & Song (2022), JRSS-B 84(3):765-793. Ver FUENTES.md.
//
// ESTADO: esqueleto. Se fija el experimento, sus parámetros y los
// marcadores de las tablas. El código y los resultados son Fase 4.
// Nada de lo que aquí falta se escribe con prosa plausible: se marca.
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
—A, B y C— que difieren en la forma del núcleo de transición y en el
grado de dependencia temporal.

#pendiente[Las definiciones de los escenarios A, B y C de la fuente
primaria no se transcriben aquí porque no han sido verificadas línea por
línea. Deben copiarse de la fuente antes de reportar cifras: sin la
definición exacta del proceso generador de datos, una tabla de resultados
no es replicable.]

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

#pendiente[Verificar contra la fuente primaria la definición exacta de
las tres métricas y el número de réplicas de Monte Carlo por celda (el
rango de la grilla $(n, T)$ está fijado arriba; el número de réplicas
no). Falta implementar y ejecutar el cálculo con esas definiciones fijadas.]

== Resultados
<sec:appG-resultados>

#pendiente[Las tres tablas siguientes registran la grilla prevista. Sus celdas se completarán con resultados de una ejecución reproducible, una vez fijadas las definiciones y la implementación del experimento.]

#mi-tabla(
  caption: [Escenario A: ECP, AL y $log("MSE")$ por configuración $(n, T)$. Celdas «--»: resultados aún no obtenidos.],
  key: "tab:appG-escenario-a",
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
    [500], [--], [--], [--],
    [1000], [--], [--], [--],
    [1500], [--], [--], [--],
    hl(),
  ),
)

*Lectura de las tablas.* Cobertura cercana al nominal y menor longitud o ECM son tendencias por investigar, no consecuencias monótonas obligatorias en una grilla finita. Con $B$ réplicas independientes, el error Monte Carlo aproximado de la cobertura $hat(p)$ es $sqrt(hat(p)(1-hat(p))/B)$. Se examinan $n$ y $T$ por separado: igual producto $nT$ no hace equivalentes los diseños dependientes. Las garantías asintóticas de @ch:inferencia no certifican por sí solas una tabla finita.

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

#pendiente[Falta fijar la *versión exacta* de la implementación pública del
método `SAVE`. El repositorio ya está verificado —el resumen del artículo remite
a https://github.com/shengzhang37/SAVE—. Debe seleccionarse y registrarse un commit antes de ejecutar y asociar después cada resultado con esa versión.]
