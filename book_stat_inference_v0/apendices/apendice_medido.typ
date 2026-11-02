// Puerto de apendices/apendice_medido.tex — Fundamentos Medido-Teóricos.
#import "../plantilla.typ": *

= Fundamentos Medido-Teóricos
<app:medido>

La formulación de un estimador o una política presupone que las funciones
utilizadas sean medibles y que sus esperanzas estén definidas. Este apéndice
reúne las nociones de medida, integración y proyección que permiten hacer
explícitos esos requisitos. Puede consultarse al estudiar las condiciones
de un resultado, sin apartar del argumento principal todo su desarrollo
técnico.

== $sigma$-Álgebras y Espacios Medibles
<sec:appE-sigma-algebras>

#thm-env("definition", name: [$sigma$-Álgebra], key: "def:appE-sigma-algebra")[
  Sea $Omega$ un conjunto no vacío. Una colección $cal(F)$ de
  subconjuntos de $Omega$ es una $sigma$-_álgebra_ si:
  + $Omega in cal(F)$
  + Si $A in cal(F)$, entonces $A^c in cal(F)$ (cerrado bajo
    complementos)
  + Si ${A_n}_(n=1)^infinity$ es una sucesión en $cal(F)$, entonces
    $union.big_(n=1)^infinity A_n in cal(F)$ (cerrado bajo uniones
    numerables)
]

#thm-env("definition", name: [Espacio Medible], key: "def:appE-espacio-medible")[
  Un _espacio medible_ es un par $(Omega, cal(F))$ donde $Omega$ es un
  conjunto y $cal(F)$ es una σ-álgebra sobre $Omega$.
]

#thm-env("example", name: [σ-Álgebra de Borel], key: "ex:appE-borel")[
  Sea $Omega = RR$. La _σ-álgebra de Borel_ $cal(B)(RR)$ es la
  σ-álgebra más pequeña que contiene todos los intervalos abiertos
  $(a,b) subset RR$. Esta σ-álgebra contiene todos los conjuntos de
  interés práctico en análisis real.
]

== Medibilidad de Funciones
<sec:appE-medibilidad>

#thm-env("definition", name: [Función Medible], key: "def:appE-funcion-medible")[
  Sean $(Omega, cal(F))$ y $(Omega', cal(F)')$ espacios medibles. Una
  función $f: Omega -> Omega'$ es _medible_ si:
  $ f^(-1)(A') in cal(F) quad forall A' in cal(F)' $
]

#thm-env("proposition", name: [Composición de Funciones Medibles], key: "prop:appE-composicion")[
  Si $f: Omega -> Omega'$ es medible y $g: Omega' -> Omega''$ es
  medible, entonces $g compose f: Omega -> Omega''$ es medible.
]

#thm-env("example", name: [Medibilidad de Estadísticos], key: "ex:appE-estadisticos")[
  Sea $X: Omega -> RR^n$ un vector aleatorio. Si $T: RR^n -> RR^k$ es Borel-medible, entonces $T compose X$ es medible. El recíproco para un único $X$ no vale: un $X$ constante puede ocultar la falta de medibilidad de $T$. Toda función continua entre estos espacios es Borel-medible.
]

== Medidas de Probabilidad y Dominación
<sec:appE-medidas>

#thm-env("definition", name: [Medida de Probabilidad], key: "def:appE-medida")[
  Una _medida de probabilidad_ sobre $(Omega, cal(F))$ es una función
  $P: cal(F) -> [0,1]$ tal que:
  + $P(Omega) = 1$
  + Si ${A_n}_(n=1)^infinity$ son conjuntos disjuntos en $cal(F)$,
    entonces:
    $ P(union.big_(n=1)^infinity A_n) = sum_(n=1)^infinity P(A_n) $
]

#thm-env("definition", name: [Espacio de Probabilidad], key: "def:appE-espacio-probabilidad")[
  Un _espacio de probabilidad_ es una terna $(Omega, cal(F), P)$ donde
  $(Omega, cal(F))$ es un espacio medible y $P$ es una medida de
  probabilidad.
]

#thm-env("definition", name: [Dominación], key: "def:appE-dominacion")[
  Sea $cal(P) = {P_theta : theta in ParamSpace}$ una familia de
  medidas de probabilidad sobre $(Omega, cal(F))$. Decimos que
  $cal(P)$ está _dominada_ por una medida $mu$ si:
  $ P_theta lt.double mu quad forall theta in ParamSpace $
  donde $P_theta lt.double mu$ significa que $P_theta (A) = 0$ para
  todo $A in cal(F)$ con $mu(A) = 0$.
]

#thm-env("theorem", name: [Teorema de Radon-Nikodym], key: "thm:appE-radon-nikodym")[
Sea $mu$ una medida $sigma$-finita y $P$ una probabilidad con $P lt.double mu$. Existe una función medible no negativa $f$, finita $mu$-casi en todas partes y única salvo conjuntos $mu$-nulos, tal que
$ P(A)=integral_A f dif mu $
para todo conjunto medible $A$. Se escribe $f=dif P/dif mu$. La hipótesis sobre la medida dominante es parte del resultado; la continuidad absoluta sola no basta para una medida arbitraria.

]

== σ-Álgebras para Espacios de Trayectorias del MDP
<sec:appE-trayectorias>

#thm-env("definition", name: [Espacio de Trayectorias], key: "def:appE-trayectorias")[
  Sea un MDP con $H$ decisiones, indexadas de $0$ a $H-1$. El espacio de trayectorias es:
  $ cal(T) = (StateSpace times ActionSpace times RR)^H times StateSpace. $
  Una trayectoria es $tau=(s_0,a_0,r_0,...,s_(H-1),a_(H-1),r_(H-1),s_H)$.
]

#thm-env("definition", name: [σ-Álgebra de Trayectorias], key: "def:appE-sigma-trayectorias")[
  La σ-álgebra de trayectorias $cal(F)_tau$ se construye como el
  producto de σ-álgebras:
  $ cal(F)_tau = (product.co_(t=0)^(H-1) (cal(B)(StateSpace) times.o
    cal(B)(ActionSpace) times.o cal(B)(RR))) times.o cal(B)(StateSpace) $
  donde $cal(B)(dot)$ denota la σ-álgebra de Borel.
]

#thm-env("definition", name: [Filtración de Historias], key: "def:appE-filtracion")[
  La _filtración de historias_ ${cal(F)_t}_(t=0)^(H-1)$ es una familia
  creciente de σ-álgebras donde $cal(F)_t$ representa la información
  disponible hasta el tiempo $t$:
  $ cal(F)_t = sigma(S_0, A_0, R_0, ..., S_t, A_t, R_t) $
]

#thm-env("proposition", name: [Propiedad de Markov y Filtraciones], key: "prop:appE-markov-filtracion")[
Defina la información antes de observar la recompensa actual como
$ cal(G)_t=sigma(S_0,A_0,R_0,...,S_t,A_t). $
El modelo Markov controlado exige un núcleo $K_t$ tal que
$ P((R_t,S_(t+1)) in B|cal(G)_t)=K_t(B|S_t,A_t). $
La filtración $cal(F)_t$ definida arriba ya contiene $R_t$; condicionar en ella no puede usarse en esta identidad de la ley conjunta antes de observar $R_t$. La homogeneidad añade que $K_t$ no depende de $t$.

]

== Condiciones de Medibilidad para Estimadores y Políticas
<sec:appE-medibilidad-estimadores>

#thm-env("definition", name: [Estimador Medible], key: "def:appE-estimador-medible")[
  Un _estimador_ $hat(theta)_n: SampleSpace^n -> ParamSpace$ es una
  función medible que mapea $n$ observaciones a una estimación del
  parámetro.
]

#thm-env("proposition", name: [Medibilidad de Estimadores Comunes], key: "prop:appE-estimadores-medibles")[
La media muestral es continua y, con las sigma-álgebras de Borel, medible. La composición $g(T(X))$ es medible si $T$ y $g$ lo son. Un argmax requiere existencia y selección medible: por ejemplo, en un espacio paramétrico métrico compacto, con criterio medible en los datos y continuo en el parámetro, se puede elegir un maximizador medible bajo las hipótesis estándar de selección. Continuidad de la verosimilitud sola no garantiza que el máximo exista ni que una elección arbitraria entre empates sea medible.

]

#thm-env("definition", name: [Política Medible], key: "def:appE-politica-medible")[
  Una _política_ $policy: StateSpace -> ActionSpace$ es medible si
  para todo conjunto medible $A subset.eq ActionSpace$:
  $ {s in StateSpace : policy(s) in A} in cal(B)(StateSpace) $
]

== Noción de Dominación en Modelos con Estados Continuos
<sec:appE-dominacion-continuo>

#thm-env("definition", name: [Modelo con Estados Continuos], key: "def:appE-estados-continuos")[
  Un modelo dominado por Lebesgue es una familia $cal(P) =
  {P_theta : theta in ParamSpace}$ donde:
  - $SampleSpace = RR^d$
  - Cada $P_theta$ tiene densidad $p_theta (x)$ respecto a la medida
    de Lebesgue. Tener estados reales no asegura esta propiedad: las leyes pueden ser singulares. En espacios de Borel generales se debe especificar otra medida dominante si existe.
]

#thm-env("proposition", name: [Dominación en Modelos Continuos], key: "prop:appE-dominacion-continuo")[
  En modelos con estados continuos, la medida de Lebesgue $lambda$
  domina a toda la familia $cal(P)$ si:
  + Las densidades $p_theta (x)$ existen para todo $theta$
  + Las densidades son continuas en $x$ (o al menos medibles)
]

#thm-env("example", name: [Modelo Gaussiano], key: "ex:appE-gaussiano")[
  Sea $X tilde N(mu, sigma^2)$ con $theta = (mu, sigma^2)$ y $sigma^2>0$. La densidad
  es:
  $ p_theta (x) = 1/sqrt(2 pi sigma^2) exp(-(x-mu)^2/(2sigma^2)) $
  Esta familia está dominada por la medida de Lebesgue en $RR$.
]

== Teorema de la Función Implícita y medibilidad local
<sec:appE-funcion-implicita>

#thm-env("theorem", name: [Teorema de la Función Implícita], key: "thm:appE-funcion-implicita")[
  Sean $x in RR^m$, $y in RR^n$ y $F: U_0 subset RR^(m+n) -> RR^n$ continuamente diferenciable en un abierto $U_0$.
  Supongamos que existe un punto $(x_0, y_0) in RR^(n+m)$ tal que:
  + $F(x_0, y_0) = 0$
  + La matriz jacobiana $(partial F)/(partial y)(x_0, y_0)$ es
    invertible

  Entonces existen vecindades $U$ de $x_0$ y $V$ de $y_0$, y una única
  función $g: U -> V$ tal que:
  + $F(x, g(x)) = 0$ para todo $x in U$
  + $g$ es continuamente diferenciable
  + $g(x_0) = y_0$
]

#thm-env("proposition", name: [Condiciones de Regularidad para el Teorema de la Función Implícita], key: "prop:appE-condiciones-funcion-implicita")[
Para una ecuación de estimación $F(x,theta)=0$, el teorema exige $F$ continuamente diferenciable cerca de la solución y Jacobiano $partial_theta F$ invertible en ella. La información de Fisher es una esperanza y no coincide necesariamente con el Jacobiano de una ecuación muestral. Su invertibilidad no prueba por sí sola la invertibilidad de ese Jacobiano ni la existencia de una solución. Identificación global y no singularidad local son requisitos distintos.

]

== Integrabilidad y Convergencia Dominada
<sec:appE-integrabilidad>

#thm-env("definition", name: [Integrabilidad], key: "def:appE-integrabilidad")[
  Una función medible $f: Omega -> RR$ es _integrable_ respecto a una
  medida $mu$ si:
  $ integral_Omega |f| dif mu < infinity $
]

#thm-env("theorem", name: [Teorema de Convergencia Dominada de Lebesgue], key: "thm:appE-convergencia-dominada")[
  Sea ${f_n}$ una sucesión de funciones medibles tal que $f_n -> f$
  casi seguramente. Si existe una función integrable $g$ tal que
  $|f_n| lt.eq g$ para todo $n$, entonces:
  + $f$ es integrable
  + $integral f_n dif mu -> integral f dif mu$
]

== Espacios de Hilbert y Proyecciones Ortogonales
<sec:appE-hilbert>

#thm-env("definition", name: [Espacio de Hilbert], key: "def:appE-hilbert")[
  Un _espacio de Hilbert_ es un espacio vectorial completo $cal(H)$
  equipado con un producto interno $⟨dot, dot⟩$ que
  induce una norma $norm(f) = sqrt(⟨f, f⟩)$.
]

#thm-env("example", name: [Espacio $L^2(P)$], key: "ex:appE-l2")[
  El espacio $L^2(P)$ identifica funciones de cuadrado integrable que coinciden $P$-casi seguramente; sus elementos son esas clases de equivalencia. Es un
  espacio de Hilbert con:
  - Producto interno: $⟨f, g⟩ = EE_P [f g]$
  - Norma: $norm(f)_2 = sqrt(EE_P [f^2])$
]

#thm-env("theorem", name: [Teorema de Proyección], key: "thm:appE-proyeccion")[
  Sea $cal(H)$ un espacio de Hilbert y $cal(M) subset cal(H)$ un
  subespacio cerrado. Para todo $f in cal(H)$, existe un único
  elemento $P_cal(M) f in cal(M)$ tal que:
  $ norm(f - P_cal(M) f) = min_(g in cal(M)) norm(f - g) $
  Además, $f - P_cal(M) f$ es ortogonal a $cal(M)$.
]

== Resumen de Condiciones Técnicas
<sec:appE-resumen>

#mi-tabla(
  caption: [Condiciones Técnicas por Capítulo],
  key: "tab:appE-condiciones",
  table(
    columns: (14%, 24%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Capítulo*], [*Resultado*], [*Condiciones Medido-Teóricas*]),
    hl(w: 0.6pt),
    [Capítulo 4], [Modelos paramétricos], [Medida dominante común, densidades medibles],
    [Capítulo 4], [Estadísticos suficientes], [Medibilidad de $T(X)$, σ-álgebra generada por $T$],
    [Capítulo 4], [UMVUE], [Suficiencia, completitud, insesgadez y segundo momento],
    // NOTA DE INTEGRIDAD: las 5 filas siguientes (Caps. 5, 6, 8, 9, 10)
    // en el LaTeX original carecen parcial o totalmente de separadores
    // "&" entre columnas (p.ej. "Capítulo 8         MDPs
    // σ-álgebra..." sin ningún "&"), lo cual habría producido celdas
    // mal alineadas o texto desbordado en el PDF. Reconstruidas aquí
    // en 3 columnas por inferencia directa del contenido, sin agregar
    // ni quitar información. Las filas para Cap. 4 y Cap. 7 ya estaban
    // ausentes en el original (el propio autor lo señala en un TODO:
    // "Verificar si faltan filas Cap. 4 y Cap. 7"); se preservan
    // ausentes, sin agregarlas.
    [Capítulo 4], [Convergencia asintótica], [$L^2(P)$ completo, convergencia dominada],
    [Capítulo 4], [Eficiencia semiparamétrica], [Espacio de Hilbert $L^2(P)$, proyección ortogonal],
    [Capítulo 3], [MDPs], [σ-álgebra de trayectorias, filtración de historias],
    [Capítulo 5], [Incrustación fiel (un paso, determinista)], [Espacios numerables, acciones finitas, pérdida acotada y medibilidad],
    [Capítulo 5], [Extensión estocástica general (*problema abierto*, @note:ch9-extension-no-demostrada)], [Requiere especificar el modelo, los núcleos y el alcance de la representación],
    [Capítulo 7], [OPE], [Medibilidad de políticas, dominación de medidas],
    hl(),
  ),
)

// Nota al pie de la tabla (no `#footnote`: dentro de un `mi-tabla` la nota se
// coloca aquí, legible junto al cuadro).
#text(size: 9pt)[
  La tabla ofrece puntos de consulta sobre las herramientas utilizadas.
  Las condiciones completas se leen en el enunciado del resultado y en
  el modelo al que se aplica.
]
