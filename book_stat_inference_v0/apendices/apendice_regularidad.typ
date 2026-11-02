// Puerto de apendices/apendice_regularidad.tex — Condiciones de Regularidad y Mixing.
#import "../plantilla.typ": *

= Condiciones de Regularidad y Mixing
<app:regularidad>

La dependencia temporal cambia la forma de acumular información y de estimar
la varianza. Las condiciones de este apéndice permiten seguir ese cambio
cuando se trabaja con una trayectoria, en relación con el @ch:fallos y el
@ch:inferencia. Sus definiciones y resultados se consultan junto con el
proceso y el estimador para los que se formula cada conclusión.

== Definiciones de Mixing
<sec:appD-mixing-def>

#thm-env("definition", name: [$alpha$-Mixing (Strong Mixing)], key: "def:appD-alpha")[
  Sea ${X_t}_(t in ZZ)$ un proceso estocástico. Para $k gt.eq 1$,
  definimos:
  $ alpha(k) = sup_(t in ZZ) sup_(A in cal(F)_(-infinity)^t \
    B in cal(F)_(t+k)^infinity) |P(A inter B) - P(A)P(B)| $
  donde $cal(F)_a^b = sigma(X_a, X_(a+1), ..., X_b)$.

  El proceso es _$alpha$-mixing_ si $alpha(k) -> 0$ cuando $k ->
  infinity$.
]

#thm-env("definition", name: [$beta$-Mixing (Absolute Regularity)], key: "def:appD-beta")[
  $ beta(k) = sup_(t in ZZ) EE[sup_(B in cal(F)_(t+k)^infinity)
    |P(B | cal(F)_(-infinity)^t) - P(B)|] $
  El proceso es _$beta$-mixing_ si $beta(k) -> 0$.
]

#thm-env("definition", name: [$phi.alt$-Mixing (Uniform Mixing)], key: "def:appD-phi")[
  $ phi.alt (k) = sup_(t in ZZ) sup_(A in cal(F)_(-infinity)^t, P(A) > 0 \
    B in cal(F)_(t+k)^infinity) |P(B|A) - P(B)| $
]

#thm-env("proposition", name: [Relaciones entre Coeficientes], key: "prop:appD-relaciones")[
  Para todo proceso estocástico:
  $ 2 alpha(k) lt.eq beta(k) lt.eq phi.alt (k) $
  Por tanto: $phi.alt$-mixing $arrow.double$ $beta$-mixing
  $arrow.double$ $alpha$-mixing.
]

== Tasas de Decaimiento
<sec:appD-tasas>

#thm-env("definition", name: [Mixing Geométrico], key: "def:appD-geometrico")[
  Un proceso tiene _mixing geométrico_ si existen $C > 0$ y $rho in
  (0,1)$ tales que:
  $ alpha(k) lt.eq C dot rho^k quad forall k gt.eq 1 $
  Equivalentemente: $alpha(k) = O(e^(-lambda k))$ para algún $lambda >
  0$.
]

#thm-env("definition", name: [Mixing Polinomial], key: "def:appD-polinomial")[
  Un proceso tiene _mixing polinomial de orden $nu$_ si:
  $ alpha(k) = O(k^(-nu)) quad "para algún " nu > 0 $
]

#mi-tabla(
  caption: [Tasas de Mixing y sus Implicaciones para Inferencia],
  key: "tab:appD-tasas",
  table(
    columns: (26%, 26%, 22%, 1fr),
    align: (left, left, left, left),
    hl(),
    table.header([*Tipo de Mixing*], [*Tasa*], [*CLT Válido?*], [*IC Válidos?*]),
    hl(w: 0.6pt),
    [Geométrico], [$alpha(k) lt.eq C rho^k$], [Con momento $2+delta$], [Más varianza positiva y consistente],
    [Polinomial], [$nu delta/(2+delta)>1$], [Con momento $2+delta$], [Más studentización válida],
    [Condición no satisfecha], [Sin sumabilidad suficiente], [Este teorema no decide], [Requiere otra justificación],
    [Sin mixing], [$alpha(k) arrow.r.not 0$], [Puede existir otro CLT], [Requiere otra justificación],
    hl(),
  ),
)

== Condiciones para MDPs Ergódicos
<sec:appD-mdp>

#thm-env("theorem", name: [Ergodicidad Geométrica de Cadenas de Markov], key: "thm:appD-ergodico")[
  Sea ${S_t}$ una cadena de Markov con espacio de estados finito
  $StateSpace$, matriz de transición $P$, y distribución estacionaria
  $mu$. Si la cadena es _irreducible_ y _aperiódica_, entonces:
  + La cadena es geométricamente ergódica:
    $ norm(P^k (s, dot) - mu(dot))_"TV" lt.eq C(s) dot rho^k $
    para algún $rho in (0,1)$ y constante $C(s)$ dependiente del
    estado inicial.
  + En régimen estacionario, el proceso es geométricamente $beta$-mixing (y por tanto
    $alpha$-mixing).
]

#thm-env("corollary", name: [MDPs con Estados Finitos], key: "cor:appD-mdp-finito")[
  Para un MDP $(StateSpace, ActionSpace, P, r, gamma)$ con
  $|StateSpace| < infinity$ y $|ActionSpace| < infinity$, bajo
  cualquier política estacionaria $pi$ que induzca una cadena
  irreducible y aperiódica, con inicio estacionario, asignación de acciones mediante aleatorización fresca y recompensas generadas por el kernel Markov del modelo, el proceso $(S_t, A_t, R_t)$ es geométricamente $alpha$-mixing. Ruido persistente no incluido en el estado requiere otro análisis.
]

#thm-env("proposition", name: [Verificación de Irreducibilidad], key: "prop:appD-verificacion")[
  Una cadena inducida por política $pi$ en MDP es irreducible si:
  + $forall s, s' in StateSpace$, existe secuencia de acciones con
    probabilidad positiva bajo $pi$ que conecta $s$ con $s'$.
  + Equivalentemente: el grafo dirigido con aristas $(s, s')$ donde
    $sum_a pi(a|s) P(s'|s,a) > 0$ es fuertemente conexo.
]

#thm-env("proposition", name: [Verificación de Aperiodicidad], key: "prop:appD-aperiodicidad")[
Para una cadena irreducible, el período es común a todos los estados. Un estado con $P(s,s)>0$ implica período uno para toda la cadena. En general el período de $s$ es $gcd{k>=1:P^(k) (s,s)>0}$. Sin irreducibilidad, una clase con auto-bucle no elimina el período de otras clases; hay que examinar las clases pertinentes.

]

== CLT bajo Dependencia Temporal
<sec:appD-clt>

#thm-env("theorem", name: [CLT de Ibragimov para Procesos $alpha$-Mixing], key: "thm:appD-ibragimov")[
  Sea ${X_t}$ un proceso estacionario $alpha$-mixing con $EE[X_t] =
  0$. Supongamos que:
  + $EE[|X_t|^(2+delta)] < infinity$ para algún $delta > 0$
  + $sum_(k=1)^infinity alpha(k)^(delta\/(2+delta)) < infinity$

  Entonces:
  $ 1/sqrt(n) sum_(t=1)^n X_t attach(->, t: d) N(0, sigma_"LR"^2) $
  donde la _varianza de largo plazo_ es:
  $ sigma_"LR"^2 = Var(X_0) + 2 sum_(k=1)^infinity Cov(X_0, X_k) $
]

#thm-env("corollary", name: [Condición Suficiente para MDPs], key: "cor:appD-clt-mdp")[
  Para MDPs con estados finitos y mixing geométrico ($alpha(k) lt.eq C
  rho^k$), la condición (2) del @thm:appD-ibragimov se satisface
  automáticamente para cualquier $delta > 0$:
  $ sum_(k=1)^infinity (C rho^k)^(delta\/(2+delta)) =
    C^(delta\/(2+delta)) sum_(k=1)^infinity rho^(k delta\/(2+delta)) <
    infinity $
]

#thm-env("theorem", name: [CLT funcional para una cadena finita], key: "thm:appD-gordin")[
Sea $S_t$ una cadena finita irreducible y aperiódica, iniciada en su ley estacionaria $mu$, y $f$ una función real con $EE_mu[f]=0$. Entonces, en $D[0,1]$ con la topología de Skorokhod,
$ n^(-1/2)sum_(t=1)^(floor(n u))f(S_t)->^d sigma W(u), $
con $sigma^2=sum_(k in ZZ)Cov(f(S_0),f(S_k))$. Un argumento suficiente usa la ecuación de Poisson $h-P h=f$, cuya solución centrada existe en esta cadena finita. Se escribe
$ sum_(t=1)^n f(S_t)=sum_(t=1)^(n) (h(S_t)-P h(S_(t-1)))+P h(S_0)-P h(S_n). $
Los sumandos son diferencias de martingala acotadas. Ergodicidad hace converger la variación cuadrática condicional normalizada; el CLT funcional de martingalas da el límite y el término de borde es uniformemente despreciable. Es un caso concreto de aproximación de martingalas. Un CLT escalar, por sí solo, no prueba un límite funcional: también se necesita tightness.

]

== Estimación de la Varianza de Largo Plazo
<sec:appD-varianza>

#thm-env("definition", name: [Estimador HAC de Newey-West], key: "def:appD-hac")[
  El estimador HAC (Heteroskedasticity and Autocorrelation Consistent)
  es:
  $ hat(sigma)_"HAC"^2 = hat(gamma)_0 + 2 sum_(k=1)^(K_n) w(k\/K_n)
    hat(gamma)_k $
  donde:
  - $hat(gamma)_k = 1/n sum_(t=k+1)^n (X_t - macron(X))(X_(t-k) -
    macron(X))$
  - $w(dot)$ es un kernel (Bartlett: $w(x) = 1 - x$ para $x in
    [0,1]$)
  - $K_n$ es el bandwidth (ancho de banda)
]

#thm-env("theorem", name: [Consistencia del Estimador HAC], key: "thm:appD-hac-consistencia")[
Para el kernel de Bartlett, suponga una serie estrictamente estacionaria con segundo momento finito, autocovarianzas absolutamente sumables, $K_n->infinity$, $K_n/n->0$ y
$ sum_(k=0)^(K_n)abs(hat(gamma)_k-gamma_k)->^P 0. $
Entonces $hat(sigma)_"HAC"^2->^P sigma_"LR"^2$. La prueba separa el error de estimación, la cola omitida y el sesgo de ponderación, como en @thm:ch11-var-consistente. La condición agregada de covarianzas debe demostrarse para el proceso. Mixing geométrico y una cota superior $K_n=O(n^(1/3))$ no bastan: esa cota permite incluso un ancho fijo y no especifica momentos ni control empírico.

]

#thm-env("note", name: [Selección de Bandwidth], key: "prop:appD-bandwidth")[
El ancho se elige dentro de las condiciones del resultado usado. $K_n=floor(n^(1/3))$ es una secuencia candidata, no una garantía universal de consistencia. Las reglas plug-in de Andrews dependen del kernel y de una estimación de cantidades espectrales; no se reducen a elevar la autocorrelación de primer orden a un tercio. Debe justificarse también una selección aleatoria realizada con los datos.

]

== Tabla de Referencia: Ambiente $arrow.r$ Condiciones $arrow.r$ Garantías
<sec:appD-tabla>

#mi-tabla(
  caption: [Condiciones Requeridas por Tipo de Ambiente],
  key: "tab:appD-ambientes",
  table(
    columns: (18%, 30%, 20%, 1fr),
    align: (left, left, left, left),
    hl(),
    table.header([*Tipo de MDP*], [*Condiciones*], [*Mixing*], [*Garantías*]),
    hl(w: 0.6pt),
    [Tabular, finito], [Inicio estacionario; irreducible y aperiódico], [Geométrico], [CLT con momentos; IC con varianza válida],
    [Con absorción], [Diseño episódico o transitorio explícito], [No se deduce], [Analizar unidades y horizonte],
    [Lineal (LQR)], [Estabilidad más condiciones del ruido], [Requiere prueba], [Momentos y estimador específicos],
    [Con aprox. funciones], [Contracción en espacio de funciones], [Depende], [Condicional],
    [POMDP], [Filtro estable], [Puede fallar], [Verificar],
    [No estacionario], [Coeficientes uniformes en el tiempo y momentos apropiados], [Verificar; puede existir mixing], [Requiere un resultado para el régimen no estacionario],
    hl(),
  ),
)

Los coeficientes de dependencia describen propiedades de la ley del proceso. Los diagnósticos de una muestra aportan evidencia parcial sobre ella. Esa diferencia debe conservarse al interpretar la tabla y al elegir el procedimiento de incertidumbre.
