#import "../plantilla.typ": *

= Casos de estudio
<ch:casos>
#chapter-alias("app:laboratorio")

Los casos de este capítulo convierten las condiciones de los capítulos
anteriores en cálculos que pueden repetirse. El recorrido distingue un
modelo finito conocido, su estimación a partir de datos, la evaluación de
políticas y la decisión posterior. Un resultado de simulación comprueba
una implementación en un escenario; no sustituye la demostración de un
teorema ni valida una aplicación clínica.

El recorrido comienza con un modelo tabular y continúa con doce laboratorios. Cada uno retoma una pregunta de los capítulos anteriores y la lleva a un cálculo. Los programas completos y sus salidas acompañan la exposición, de modo que el lector puede seguir la relación entre la fórmula y su implementación.

== El caso longitudinal: Sistema de Soporte Clínico para Hipertensión

El SSCH es un escenario docente sintético. Sus estados ordenados y acciones
abstractas permiten estudiar decisiones longitudinales sin atribuir a sus
números un significado médico validado. No se utilizan pacientes reales,
umbrales diagnósticos ni estimaciones de eficacia de medicamentos.

Hay dos experimentos que no deben confundirse. El *SSCH tabular* de cinco
estados estudia estimación paramétrica y planificación con una dinámica
completamente especificada. El *subcaso de dos visitas* de los capítulos
7–9 estudia OPE e intervalos mediante cuatro historias enumerables. Comparten
la motivación pedagógica, pero no los parámetros, el horizonte ni los datos.
Cada comparación mantiene fijo su propio estimando.

#[
#set heading(numbering: none, outlined: false)
=== El modelo tabular y sus recompensas
<sec:ssch-intro>
]

#thm-env("example", name: [SSCH — El MDP Clínico como Modelo Paramétrico], key: "ex:ssch-cap01", es-sintetico: true)[
  Considere cinco estados $s_1,...,s_5$, ordenados de menor a mayor
  severidad abstracta, y cuatro acciones $a_1,...,a_4$. Las denominaciones
  clínicas motivan el escenario, pero ninguna acción representa
  una pauta terapéutica. Se fija $gamma=0.9$ y horizonte descontado infinito.
  El objetivo de comparación será $V^pi (s_3)$.

  Para hacer reproducible la dinámica, use índices $s,j in {0,...,4}$ y
  desplazamientos $d=(0.45,0,-0.45,-0.8)$ para las cuatro acciones. Defina
  $ w_(s,a,j)=exp(-abs(j-(s+d_a))/0.7), quad
    P_(s,a,j)=0.98 frac(w_(s,a,j),sum_(u=0)^4 w_(s,a,u))+0.02/5. $
  Cada fila suma uno y cada entrada es al menos $0.004$. Esta es una elección
  de diseño del simulador, no una estimación de transiciones humanas.

  #mi-tabla(key: "tab:ssch-recompensas", caption: [Recompensas sintéticas del SSCH tabular, en unidades abstractas.],
    table(columns: (1fr,1fr,1fr,1fr,1fr),align: right,hl(),
      table.header([*Estado*],[$a_1$],[$a_2$],[$a_3$],[$a_4$]),hl(w: 0.6pt),
      [$s_1$],[1.0],[0.9],[0.7],[0.5],
      [$s_2$],[0.5],[0.7],[0.6],[0.4],
      [$s_3$],[0.0],[0.3],[0.6],[0.5],
      [$s_4$],[-0.5],[0.0],[0.4],[0.7],
      [$s_5$],[-2.0],[-1.5],[-0.5],[0.2],hl()))

  Cuando $P$ es desconocida, sus veinte filas pertenecen a $Delta^4$:
  hay cien probabilidades y ochenta parámetros libres en el interior.
  La recompensa se considera conocida. Si también se estima, su error
  debe incorporarse a la inferencia de valor.
]

#[
#set heading(numbering: none, outlined: false)
=== Los datos que conservan información de las transiciones
]

#thm-env("example", name: [SSCH — Estadístico Suficiente para las Transiciones], key: "ex:ssch-cap02", es-sintetico: true)[
  Si la distribución inicial y las probabilidades de asignación son
  conocidas o no contienen el parámetro de transición, la verosimilitud
  observada tiene la forma
  $ L(theta;X)=h(X)product_(s,a,j)theta_(s,a,j)^(N_(s,a,j)). $
  La factorización muestra suficiencia de los conteos bajo ese modelo.
  Deben revisarse también el mecanismo de parada, pérdidas de seguimiento
  y recompensas si contienen información sobre el mismo parámetro.

  El número de visitas a una fila puede depender de las transiciones
  anteriores. Por tanto, no es automáticamente ancilar ni independiente
  de los conteos; Basu no autoriza descartarlo. Condicionar retrospectivamente
  en un número de visitas adaptativo tampoco produce sin más un experimento
  multinomial de tamaño fijo.

  Para los cálculos siguientes se usa un *diseño generativo por filas*:
  ochenta transiciones independientes desde cada par estado–acción,
  con tamaño fijado antes de observarlas. Son 1600 transiciones de diseño,
  no 200 pacientes ni una sola trayectoria. En este experimento, cada fila
  es multinomial y las filas son independientes. Guardar cien conteos
  basta para esa verosimilitud; la procedencia y el diseño se conservan aparte.
]

#[
#set heading(numbering: none, outlined: false)
=== Estimar la dinámica y calcular el valor
]

#thm-env("example", name: [SSCH — Estimación de las Probabilidades de Transición], key: "ex:ssch-cap03-b", es-sintetico: true)[
  En el diseño de tamaño fijo $m=80$ por fila,
  $ hat(P)_(s,a,j)=N_(s,a,j)/m, quad
    Cov(hat(P)_(s,a,dot))=frac(1,m)
    ("diag"(P_(s,a,dot))-P_(s,a,dot)P_(s,a,dot)^T). $
  Las frecuencias son insesgadas y UMVUE para sus probabilidades en el
  modelo multinomial completo. La afirmación se refiere a este diseño,
  no a cualquier cociente de conteos de una trayectoria adaptativa.

  Para una política fija,
  $ V^pi=(I-gamma P^pi)^(-1)r^pi. $
  El programa usa exactamente esa ecuación, con matrices compatibles.
  El estimador plug-in de valor no es necesariamente insesgado en muestra
  finita. Su análisis asintótico exige que crezcan los tamaños de las filas
  necesarias y que se cumpla la regularidad del funcional.

  Con el generador y semilla especificados, desde $s_3$ se obtienen
  $hat(V)^(pi_2) approx 0.964091$ y $hat(V)^(pi_3) approx 5.570888$,
  donde $pi_a$ usa siempre la acción $a$. Los valores verdaderos del
  simulador son aproximadamente $1.635906$ y $5.855945$.
]

#[
#set heading(numbering: none, outlined: false)
=== Comparar dos políticas con los mismos datos
]

#thm-env("example", name: [SSCH: comparación de dos políticas del simulador], key: "ex:ssch-cap04-b", es-sintetico: true)[
  Para comparar las acciones abstractas $a_3$ y $a_2$, defina
  $Delta=V^(pi_3) (s_3)-V^(pi_2) (s_3)$ y contraste $H_0:Delta<=0$ frente a
  $H_1:Delta>0$, con un único análisis prefijado.

  La realización generada da $hat(Delta) approx 4.606798$ y error estándar
  delta $0.882817$. El intervalo bilateral normal aproximado al 95% es
  $[2.876508,6.337087]$. La interpretación es evidencia bajo el modelo,
  el diseño por filas y la aproximación asintótica. No es una prueba de
  cobertura finita ni de eficacia clínica.

  La varianza corresponde a la diferencia completa. Si las dos políticas
  comparten parámetros estimados, se incluye su covarianza. Comparar
  varios estados o políticas cambia la familia de contrastes y exige
  un plan de multiplicidad; no se inventan resultados de seis contrastes
  que el programa no calculó.
]

#[
#set heading(numbering: none, outlined: false)
=== Propagar el error de las transiciones al valor
]

#thm-env("example", name: [SSCH — Distribución Asintótica de $hat(V)^pi$], key: "ex:ssch-cap05-b", es-sintetico: true)[
  Con tamaños iguales $m$ por fila y parámetros interiores, el CLT
  multinomial usa escala $sqrt(m)$. Para una perturbación de transición
  $dif P^pi$, con recompensa fija,
  $ dif V^pi=gamma (I-gamma P^pi)^(-1) (dif P^pi)V^pi. $
  Para el componente inicial $s_3$, sea $A^pi=(I-gamma P^pi)^(-1)$.
  La derivada respecto de una entrada de la fila $(s,a)$ es
  $ g_(s,a,j)^pi=gamma A_(s_3,s)^pi pi(a|s)V_j^pi. $
  Se usa en direcciones cuyas entradas suman cero. Para la diferencia,
  se resta el gradiente de ambas políticas y se aplica la covarianza
  multinomial de cada fila, sumando las contribuciones independientes.

  El bootstrap del programa remuestrea conteos multinomiales de tamaño
  ochenta por fila bajo $hat(P)$ y reajusta ambos valores. Es un bootstrap
  paramétrico del diseño generativo, no un remuestreo de pacientes.
  Que su intervalo resulte próximo al normal es una comparación de métodos;
  para estudiar cobertura se necesitan muchas muestras nuevas del modelo
  verdadero y error Monte Carlo.

  La positividad del núcleo construido proporciona una minoración uniforme
  para cualquier política estacionaria del simulador. Esta propiedad no se
  infiere de una ACF favorable. En el diseño de filas independientes no
  se necesita usar un CLT de trayectoria para justificar las frecuencias.
]

El siguiente programa define el modelo completo, genera los conteos,
calcula la varianza por delta y el bootstrap, y contrasta la derivada con
una perturbación numérica que preserva las sumas de fila. Guárdese como
`lab00_ssch.py`; también lo utiliza el laboratorio 8.

#codelisting-env(caption: [`lab00_ssch.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.stats import norm

GAMMA = 0.9
R = np.array(
    [
        [1, 0.9, 0.7, 0.5],
        [0.5, 0.7, 0.6, 0.4],
        [0, 0.3, 0.6, 0.5],
        [-0.5, 0, 0.4, 0.7],
        [-2, -1.5, -0.5, 0.2],
    ]
)
DRIFT = np.array([0.45, 0, -0.45, -0.8])


def model():
    s = np.arange(5)[:, None, None]
    j = np.arange(5)[None, None, :]
    w = np.exp(-np.abs(j - (s + DRIFT[None, :, None])) / 0.7)
    return 0.98 * w / w.sum(axis=2, keepdims=True) + 0.02 / 5


def evaluate(P, pi):
    pp = np.einsum("sa,saj->sj", pi, P)
    rr = (pi * R).sum(axis=1)
    inv = np.linalg.inv(np.eye(5) - GAMMA * pp)
    return inv @ rr, inv


def gradient(P, pi, initial=2):
    v, inv = evaluate(P, pi)
    return (
        GAMMA
        * inv[initial, :, None, None]
        * pi[:, :, None]
        * v[None, None, :]
    )


def delta_variance(P, grad, m):
    return float(
        np.sum(
            (np.sum(P * grad**2, axis=2) - np.sum(P * grad, axis=2) ** 2)
            / m
        )
    )


def main():
    P = model()
    rng = np.random.default_rng(20261027)
    m = 80
    counts = np.array(
        [
            [rng.multinomial(m, P[s, a]) for a in range(4)]
            for s in range(5)
        ]
    )
    phat = counts / m
    policies = [np.eye(4)[np.full(5, a)] for a in range(4)]
    vals = [evaluate(phat, pi)[0][2] for pi in policies]
    true = [evaluate(P, pi)[0][2] for pi in policies]
    g = gradient(phat, policies[2]) - gradient(phat, policies[1])
    se = np.sqrt(delta_variance(phat, g, m))
    diff = vals[2] - vals[1]
    print("Diseno: 80 transiciones independientes por fila; total 1600")
    print("Valores verdaderos desde s3:", np.round(true, 6))
    print("Valores estimados desde s3:", np.round(vals, 6))
    print(f"Diferencia a3-a2={diff:.6f}; SE delta={se:.6f}")
    print(
        "IC normal 95%:",
        np.round(diff + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
    )
    print(f"p unilateral normal={norm.sf(diff/se):.6g}")
    boot = []
    for _ in range(1000):
        pb = np.array(
            [
                [rng.multinomial(m, phat[s, a]) / m for a in range(4)]
                for s in range(5)
            ]
        )
        boot.append(
            evaluate(pb, policies[2])[0][2]
            - evaluate(pb, policies[1])[0][2]
        )
    print(
        "IC bootstrap parametrico 95%:",
        np.round(np.quantile(boot, [0.025, 0.975]), 6),
    )
    # Comprobacion direccional de la derivada, dentro del simplex.
    d = np.zeros_like(P)
    d[2, 2, 0] = 1
    d[2, 2, 1] = -1
    h = 1e-6
    gd = gradient(P, policies[2])
    fd = (
        evaluate(P + h * d, policies[2])[0][2]
        - evaluate(P - h * d, policies[2])[0][2]
    ) / (2 * h)
    assert np.isclose(fd, np.sum(gd * d), rtol=1e-5)
    assert np.allclose(P.sum(axis=2), 1) and np.min(P) > 0
    print("Filas estocasticas y derivada direccional: OK")


if __name__ == "__main__":
    main()
```
]

*Salida de la ejecución de referencia.*
#[
#set text(size: 8pt)
```text
Diseno: 80 transiciones independientes por fila; total 1600
Valores verdaderos desde s3: [-7.771309  1.635906  5.855945  4.786908]
Valores estimados desde s3: [-5.091062  0.964091  5.570888  4.835083]
Diferencia a3-a2=4.606798; SE delta=0.882817
IC normal 95%: [2.876508 6.337087]
p unilateral normal=9.029e-08
IC bootstrap parametrico 95%: [2.998922 6.409819]
Filas estocasticas y derivada direccional: OK
```
]

#[
#set heading(numbering: none, outlined: false)
=== Pasar del diseño por filas a episodios observacionales
]

#thm-env("example", name: [SSCH — OPE Semiparamétrica con Datos Observacionales], key: "ex:ssch-cap06", es-sintetico: true)[
  El diseño generativo anterior es paramétrico finito. Para pasar a datos
  longitudinales observacionales, hay que especificar otra ley de muestreo,
  la política de registro y la información que precede a cada acción.
  La interpretación causal exige consistencia, intercambio secuencial
  y positividad respecto del historial pertinente; un estado discretizado
  puede omitir confusores. No se presumen esas propiedades para un hospital.

  En el modelo Markov por tiempo, horizonte fijo $H$ y episodios iid del
  @thm:ch6-kallus, con ley inicial desconocida compartida, la influencia
  eficiente para el valor integrado tiene la forma
  $ phi(O)=v_0(S_0)-J+sum_(t=0)^(H-1)gamma^t w_t (S_t,A_t)
    (R_t+gamma v_(t+1) (S_(t+1))-q_t (S_t,A_t)), quad v_H=0. $
  Aquí $w_t$ es una razón *marginal* de ocupación. No es automáticamente
  el producto de razones de acciones de la trayectoria. Cambiar el modelo
  a historias completas, a homogeneidad temporal o a horizonte infinito
  puede cambiar la influencia y su cota.

  La doble robustez da una identidad de centrado bajo los conjuntos de
  auxiliares correctos. Un IC regular requiere además control de productos
  de errores, fluctuaciones empíricas y varianza. No se reemplaza ese
  argumento por una afirmación genérica de sesgo cuadrático en un solo
  modelo de recompensa. Los laboratorios 6 y 10 separan ambas tareas.
]

#[
#set heading(numbering: none, outlined: false)
== De los cálculos del caso a los experimentos reproducibles
]

Los programas usan escenarios sintéticos con verdad conocida y un entorno
público de simulación, CartPole. No se presenta una replicación de NHEFS ni
un análisis de pacientes. Cada salida «esperada» que se reproduce es una
salida efectivamente obtenida con el código adjunto; una semilla fija facilita
repetición dentro del entorno documentado, pero no demuestra una propiedad
asintótica.

*Ejecución.* El paquete incluye `lab00_ssch.py`, los doce laboratorios
(con 1 dividido en dos programas), `ejecutar_todos.py`, versiones y salidas.
8 importa el modelo de 0; todos los archivos se mantienen en la misma
carpeta. Los demás programas no requieren ejecutar los anteriores. Ejecute:

```sh
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python ejecutar_todos.py
```

El código estadístico usa NumPy, SciPy y scikit-learn; 10 añade Gymnasium.
La arquitectura por nodos se describe sin exigir un servicio LLM ni una
cuenta externa. No se atribuyen garantías estadísticas a un framework.
Las versiones de la ejecución de referencia constan en `versiones.json`.

*Lectura de resultados.* La media de una simulación, su error Monte Carlo,
un intervalo inferencial y una cota determinista responden a preguntas
distintas. Los laboratorios indican cuál calculan. Las preguntas de extensión
no se presentan como experimentos ya realizados.

#mi-tabla(key: "tab:lab-reparto-f1-f12", caption: [Preguntas y fundamentos de los doce laboratorios.],
  table(columns: (auto,1fr,auto),align:left,hl(),
    table.header([*Lab*],[*Contenido*],[*Capítulo vinculado*]),hl(w:0.6pt),
    [1],[Modelos y actualización],[4],
    [2],[Suficiencia y memoria],[4],
    [3],[Rao–Blackwell y precisión],[4],
    [4],[Comparación e intervalos],[4],
    [5],[Bootstrap y cobertura],[4],
    [6],[AIPW y cross-fitting],[4],
    [7],[Decisión y bandits],[2],
    [8],[Programación dinámica],[3],
    [9],[Incrustación de una decisión],[5],
    [10],[OPE],[7],
    [11],[Dependencia e inferencia],[8],
    [12],[Agentes y síntesis],[11],hl()))

#[
#show heading.where(level: 3): set heading(numbering: none, outlined: false)
#show heading.where(level: 4): set heading(numbering: none, outlined: false)

== Laboratorio 1: Modelo del Mundo y Estadístico Suficiente
<lab:F1>
El primer laboratorio sigue el paso de las observaciones a la actualización de un modelo. La formulación del @ch:arquitectura y la @def:ch1-conjugada permiten interpretar qué se aprende en cada actualización.

=== Laboratorio 1.1: Agente de Diagnóstico Médico con Asistencia Experta
<lab:F1.1>

==== Objetivo

Implementar una actualización Beta–Bernoulli y distinguir probabilidad
predictiva, incertidumbre sobre una prevalencia y pérdida de decisión.
Se reproduce el ejemplo sintético del @ch:verificacion, sin afirmar que
una prevalencia poblacional sea un diagnóstico individual.

==== Conexión Teórica

Con prior $"Beta"(a_0,b_0)$ y observaciones Bernoulli iid confirmadas,
$T=(n,sum_i Y_i)$ determina el posterior. Las probabilidades de falso
positivo y falso negativo pertenecen a otro modelo: no están representadas
por sumar resultados de pruebas imperfectas como si fueran estados verdaderos.

==== Planteamiento
<ex:ch1-diagnostico-medico>

Tome prior $"Beta"(1,1)$ y doce estados positivos confirmados de cien
personas independientes e intercambiables. El posterior es $"Beta"(13,89)$.
Para una persona nueva sin covariables, $p=13/102$. La pérdida predictiva de
tratar es $c(1-p)$ y la de no tratar es $d p$; el umbral es $c/(c+d)$.
Con $c=1,d=9$, se prefiere la primera acción en el problema de dos opciones.

Añadir una regla que deriva a revisión si la desviación posterior supera
$0.03$ cambia el procedimiento. La revisión puede ser razonable como
restricción de diseño, pero su optimalidad exige modelar su costo y la
información que aporta. No se denomina a esa regla «Bayes óptima» sin más.

#mi-figura(key: "fig:agente-diagnostico", caption: [Actualización, comparación de pérdidas y revisión del caso sintético.],
  block(width:100%,inset:8pt,stroke:0.5pt+luma(180))[
    #align(center)[Datos binarios confirmados → posterior Beta]
    #align(center)[$arrow.b$]
    #table(columns:(1fr,1fr),stroke:none,inset:6pt,
      [*Comparar pérdidas*],[*Revisar restricción*],
      [Elegir entre las dos acciones especificadas.],[Derivar si la regla adicional exige consulta.])
    #align(center)[$arrow.b$]
    #align(center)[Registrar objetivo, supuestos, cifras y motivo de la decisión]
  ])

#mi-tabla(key: "tab:ch1-nodos-diagnostico", caption: [Qué implementa cada componente y qué no demuestra.],
  table(columns:(24%,34%,1fr),align:left,hl(),
    table.header([*Componente*],[*Operación*],[*Alcance*]),hl(w:0.6pt),
    [Actualizar],[Sumar éxitos y fracasos],[Exacto bajo el modelo Bernoulli especificado.],
    [Cuantificar],[Media y varianza posterior],[No equivalen a cobertura frecuentista.],
    [Decidir],[Comparar pérdidas predictivas],[Depende de costos y acciones.],
    [Revisar],[Aplicar restricción adicional],[Regla de diseño, no teorema clínico.],hl()))

#codelisting-env(caption: [`lab01a_beta.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
from math import sqrt


def update(a, b, y):
    if y not in (0, 1):
        raise ValueError("Se requiere estado binario confirmado")
    return a + y, b + 1 - y


a, b = 1.0, 1.0
for y in [1] * 12 + [0] * 88:
    a, b = update(a, b, y)
p = a / (a + b)
sd = sqrt(a * b / ((a + b) ** 2 * (a + b + 1)))
c, d = 1.0, 9.0
losses = {"tratar": c * (1 - p), "no_tratar": d * p}
action = min(losses, key=losses.get)
print(f"Posterior Beta({a:.0f},{b:.0f}); p={p:.6f}; SD={sd:.6f}")
print(f"Umbral={c/(c+d):.3f}; accion de dos opciones={action}")
print("Regla adicional SD<=0.03:", action if sd <= 0.03 else "consultar")
assert action == "tratar" and sd > 0.03
```
]
#[
#set text(size: 8pt)
```text
Posterior Beta(13,89); p=0.127451; SD=0.032859
Umbral=0.100; accion de dos opciones=tratar
Regla adicional SD<=0.03: consultar
```
]

==== Preguntas de Exploración

+ Derive el umbral cuando $d=3c$ y explique por qué disminuye al aumentar
  el costo de omisión. Mantenga separados el estado binario y su probabilidad.
+ Compare priors $"Beta"(1,1)$ y $"Beta"(10,2)$ sobre la misma secuencia.
  Examine sensibilidad, sin calificar al prior uniforme como universalmente
  no informativo.
+ Modele una prueba imperfecta con sensibilidad y especificidad conocidas.
  Derive su verosimilitud en términos de prevalencia y explique por qué
  la actualización Beta conjugada ordinaria deja de ser válida en general.

=== Laboratorio 1.2: Agente Bernoulli-Beta para Optimización de CTR
<lab:F1.2>
#dem-alias("ex:ch1-bernoulli-beta")

==== Objetivo

Relacionar el posterior de una tasa de clic con una utilidad concreta y
un costo por exposición. El caso necesita una política de observación
compatible con el modelo, no solo una fórmula de actualización.

==== Planteamiento

Con dieciocho clics de cien exposiciones y prior $"Beta"(1,1)$,
el beneficio predictivo de mostrar un producto que produce uno por clic
y cuesta $0.15$ por exposición es $19/102-0.15 approx 0.036275$.
Para este objetivo, el signo del beneficio determina la decisión.

La varianza posterior satisface
$ Var(theta|X)=frac(p(1-p),n+a_0+b_0+1)
  <=frac(1,4(n+a_0+b_0+1)). $
Con prior uniforme, la cota estricta de desviación menor que $0.05$
se obtiene para $n>=98$. Es una cota de dispersión posterior, no un
cálculo de potencia ni una garantía de calibración frecuentista.

#codelisting-env(caption: [`lab01b_ctr.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
from fractions import Fraction

success, n = 18, 100
a, b = 1 + success, 1 + n - success
p = a / (a + b)
cost = 0.15
print(f"Posterior Beta({a},{b}); beneficio esperado={p-cost:.6f}")
print("Mostrar:", p > cost)
# Var(theta|datos)<=1/[4(n+a0+b0+1)]. Cota para todo numero de exitos.
minimum_n = next(
    k for k in range(1000) if Fraction(1, 4 * (k + 3)) < Fraction(1, 400)
)
print("n suficiente por cota uniforme para SD<0.05:", minimum_n)
assert minimum_n == 98
```
]
#[
#set text(size: 8pt)
```text
Posterior Beta(19,83); beneficio esperado=0.036275
Mostrar: True
n suficiente por cota uniforme para SD<0.05: 98
```
]

==== Preguntas de Exploración

+ Derive la cota uniforme para otros priors y tolerancias, distinguiendo
  desigualdad estricta y no estricta.
+ Compare sesgo y ECM de media posterior y frecuencia empírica para
  varios valores verdaderos, usando réplicas e incertidumbre Monte Carlo.
+ Extienda a cinco productos y registre el mecanismo adaptativo de selección.
  Compare la decisión de una sola ronda con Thompson Sampling de 7.

== Laboratorio 2: Compresión del Estado (Suficiencia)
<lab:F2>
La actualización anterior plantea qué información conviene guardar. Este laboratorio examina la compresión de los datos mediante la suficiencia del @ch:reduccion.

=== Objetivo

Mostrar una reducción suficiente y un resumen realmente insuficiente.
La media incremental con tamaño muestral no pierde información estadística
respecto de la suma en aritmética exacta; errores de redondeo son una cuestión
diferente.

=== Conexión Teórica

En Bernoulli iid, el historial, $(n,sum X_i)$ y $(n,overline(X))$ contienen
la misma información para la verosimilitud. Guardar solo el último dato
no es suficiente cuando hay más de una observación. El criterio de razones
de verosimilitud permite exhibir la diferencia sin inventar una divergencia
KL atribuida a «insuficiencia» de la media.

=== Dataset y Setup

Mil observaciones Bernoulli de probabilidad $0.3$, generador local y semilla
20261027. Se cuentan operaciones; no se publican tiempos supuestos de una
máquina no medida. Recalcular la suma de todo el historial en cada llegada
cuesta en total orden $n^2$, frente a orden $n$ para las actualizaciones.

=== Implementación

#codelisting-env(caption: [`lab02_suficiencia.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np

rng = np.random.default_rng(20261027)
x = rng.binomial(1, 0.3, size=1000)
n = total = 0
online = 0.0
for y in x:
    n += 1
    total += int(y)
    online += (y - online) / n
assert np.isclose(total / n, online) and np.isclose(x.mean(), online)
print(f"n={n}; exitos={total}; media={online:.6f}")
print("Conteos, historial y (n,media) coinciden: OK")
# Un resumen realmente insuficiente: el ultimo dato.
# Estas muestras tienen mismo ultimo dato y razones de verosimilitud distintas.
a = np.array([0, 0, 0, 1])
b = np.array([1, 1, 0, 1])
for theta in [0.2, 0.7]:
    ratio = (theta / (1 - theta)) ** (a.sum() - b.sum())
    print(f"Razón L(a)/L(b) en theta={theta}: {ratio:.6f}")
print("Operaciones suma completa a cada llegada:", n * (n + 1) // 2)
print("Actualizaciones incrementales:", n)
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
n=1000; exitos=305; media=0.305000
Conteos, historial y (n,media) coinciden: OK
Razón L(a)/L(b) en theta=0.2: 16.000000
Razón L(a)/L(b) en theta=0.7: 0.183673
Operaciones suma completa a cada llegada: 500500
Actualizaciones incrementales: 1000
```
]

Las dos muestras de cuatro observaciones tienen el mismo último dato y
razones de verosimilitud que dependen de $theta$: ese resumen no es
suficiente. La coincidencia de los tres cálculos de la media comprueba la
implementación; la factorización es la justificación estadística.

=== Preguntas de Exploración

+ Repita con Poisson y conserve el tamaño muestral cuando no sea fijo.
+ En una normal de varianza conocida, compare media y mediana mediante
  distribuciones muestrales. No llame «varianza posterior» a cualquier
  variabilidad de un estimador.
+ En $N(mu,1)$ iid con al menos dos observaciones, identifique una
  estadística ancilar basada en residuos y use Basu bajo sus hipótesis.
  Una correlación muestral cercana a cero no demuestra independencia.

== Laboratorio 3: Estimación Óptima en Agentes
<lab:F3>
Con los datos representados, la siguiente pregunta es cómo cambia la precisión al modificar un estimador. Los argumentos del @ch:estimacion proporcionan el criterio para comparar esas alternativas.

=== Laboratorio 3.1: Estimación de Funciones de Valor
<lab:F3.1>

==== Objetivo

Construir un ejemplo donde el condicionamiento Rao–Blackwell sea calculable,
la cota de precisión incluya la derivada del funcional y la comparación
entre estimadores pueda verificarse por simulación.

==== Conexión Teórica

Para $X_i$ Bernoulli iid, defina un retorno abstracto de una decisión
$G=2X$ y su valor $J=2theta$. El estimador $U=2X_1$ es insesgado.
Si $T=sum_i X_i$, la intercambiabilidad da
$ EE(U|T)=2T/n. $
Sus varianzas son $4theta(1-theta)$ y $4theta(1-theta)/n$.
No se ha sustituido una esperanza condicional desconocida por una regresión
sin justificar el error adicional.

==== Laboratorio 3.2: Rao-Blackwellización de Estimadores Monte Carlo

El programa genera veinte mil muestras de tamaño veinte. El objeto
aleatorio comparado es un estimador por muestra, no veinte mil observaciones
tratadas como una sola muestra de entrenamiento.

#codelisting-env(caption: [`lab03_rb.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np

rng = np.random.default_rng(20261027)
M, n, theta = 20000, 20, 0.3
x = rng.binomial(1, theta, size=(M, n))
u = 2 * x[:, 0]
rb = 2 * x.mean(axis=1)
print(f"Objetivo J=2theta={2*theta:.3f}")
print(f"Var teorica inicial={4*theta*(1-theta):.6f}")
print(f"Var teorica RB y cota CR={4*theta*(1-theta)/n:.6f}")
print(
    f"Var simulada inicial={u.var(ddof=1):.6f}; RB={rb.var(ddof=1):.6f}"
)
print(f"Medias simuladas: {u.mean():.6f}, {rb.mean():.6f}")
# No se usa una asercion aleatoria para demostrar un teorema.
assert np.isclose(4 * theta * (1 - theta) / n, 0.042)
```
]
#[
#set text(size: 8pt)
```text
Objetivo J=2theta=0.600
Var teorica inicial=0.840000
Var teorica RB y cota CR=0.042000
Var simulada inicial=0.845121; RB=0.041860
Medias simuladas: 0.606400, 0.600420
```
]

La desigualdad de varianzas se demuestra por esperanza condicional. Las
varianzas simuladas aproximan las cantidades exactas; una realización
favorable no prueba un resultado universal.

==== Laboratorio 3.3: Cramér-Rao como Límite de Precisión del Agente

En el interior Bernoulli, $I_1(theta)=1/(theta(1-theta))$ y $g'(theta)=2$,
por lo que la cota regular insesgada para $J=g(theta)$ es
$ Var(hat(J))>=frac((g'(theta))^2,n I_1(theta))
  =frac(4theta(1-theta),n). $
El estimador Rao–Blackwell la alcanza. La cota no afirma que todo estimador
sesgado tenga varianza superior ni que cualquier función de valor sea regular.

*Ejemplo numérico (SSCH) #sintetico.*
<ex:ssch-cap03>
En una fila multinomial de tamaño fijado ochenta, observar 24 transiciones
a un estado da frecuencia $0.30$ y error estándar plug-in
$sqrt(0.3(0.7)/80) approx 0.051235$. Es un ejemplo de fila independiente,
no una cifra extraída de la ejecución de `lab00_ssch.py`. El valor longitudinal
requiere todas las filas usadas por la política y su propagación conjunta.

==== Preguntas de Exploración

+ Derive el sesgo y ECM de un estimador contraído de $theta$ y compárelo
  con el UMVUE; explique por qué una menor varianza no viola Cramér–Rao.
+ En el modelo tabular, verifique numéricamente la derivada en varias
  direcciones del simplex antes de calcular la varianza delta.
+ Compare horizonte finito e infinito: con recompensas acotadas por $B$,
  derive el error de truncamiento $B gamma^H/(1-gamma)$.

== Laboratorio 4: Tests e Intervalos de Confianza en Agentes
<lab:F4>
La comparación entre políticas añade una decisión al cálculo del valor. El @ch:tests y el @ch:verificacion permiten seguir qué error controla el contraste y qué información requiere su interpretación.

=== Laboratorio 4.1: A/B Testing de Políticas

Defina una diferencia de valores bajo la misma población, recompensa,
horizonte y descuento. Contraste $H_0:Delta<=delta_0$ frente a
$H_1:Delta>delta_0$. Cambiar el descuento entre políticas cambia el criterio
y no constituye por sí solo una comparación de mejora.

Con episodios compartidos, el error estándar usa las diferencias pareadas.
Holm controla FWER con p-valores válidos; BH requiere las condiciones de
dependencia correspondientes para FDR. Ninguno autoriza repetir libremente
el análisis hasta obtener significación.

=== Laboratorio 4.2: Ejemplo SSCH #sintetico — Medicación vs. Estilo de Vida
<ex:ssch-cap04>

El título conserva su motivación, pero el cálculo usa las dos políticas
abstractas del subcaso de dos visitas de @ex:ssch-cap11. Las contribuciones
pareadas son $0.520,0.340,0.430,0.610$. Se considera una realización iid
con veinticinco apariciones de cada historia; esas frecuencias no fueron
impuestas por estratificación. La misma estimación puede superar un margen
$0.40$ y no aportar evidencia suficiente para superar $0.47$.

#codelisting-env(caption: [`lab04_comparacion.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.stats import norm

# Realizacion posible de 100 episodios iid, no diseno de cuotas.
d = np.tile([0.520, 0.340, 0.430, 0.610], 25)
se = d.std(ddof=1) / np.sqrt(len(d))
est = d.mean()
print(f"Diferencia={est:.6f}; SE={se:.6f}")
print(
    "IC bilateral 95%:",
    np.round(est + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
for margin in [0.40, 0.47]:
    z = (est - margin) / se
    p = norm.sf(z)
    lower = est - norm.ppf(0.95) * se
    print(
        f"Margen={margin:.2f}; p unilateral={p:.6f}; limite={lower:.6f}; rechazo={p<.05}"
    )
# Holm con p-valores ilustrativos prefijados, no seis comparaciones clinicas.
p = np.array([0.002, 0.018, 0.040, 0.070, 0.20, 0.80])
order = np.argsort(p)
adj = np.empty(6)
adj[order] = np.minimum(
    1, np.maximum.accumulate((6 - np.arange(6)) * p[order])
)
print("p ajustados Holm (ejemplo separado):", adj)
```
]
#[
#set text(size: 8pt)
```text
Diferencia=0.475000; SE=0.010113
IC bilateral 95%: [0.455179 0.494821]
Margen=0.40; p unilateral=0.000000; limite=0.458366; rechazo=True
Margen=0.47; p unilateral=0.310507; limite=0.458366; rechazo=False
p ajustados Holm (ejemplo separado): [0.012 0.09  0.16  0.21  0.4   0.8  ]
```
]

Los seis p-valores usados para ilustrar Holm son una lista sintética
separada. No representan seis hallazgos del SSCH. La conclusión estadística
del ejemplo no se interpreta como comparación de medicamentos.

==== Preguntas de Exploración

+ Compare un intervalo de diferencias pareadas con la suma incorrecta
  de varianzas que ignora su covarianza.
+ Diseñe tres análisis intermedios con niveles cuya suma sea $0.05$.
  Justifique el control por unión de eventos y discuta el costo en potencia.
+ Simule potencia para márgenes y tamaños prefijados; reporte error Monte
  Carlo y no seleccione el margen después de ver los resultados.

== Laboratorio 5: Asintótica Aplicada en Agentes
<lab:F5>
Una vez calculado el estimador, interesa reproducir su variación entre muestras. El laboratorio utiliza las aproximaciones y el remuestreo del @ch:asintotica para estudiar esa incertidumbre.

=== Laboratorio 5.1: Bootstrap de Políticas

Se estudia cobertura en un experimento con verdad conocida. Cada réplica
genera cien contribuciones iid de la distribución equiprobable de cuatro
valores del subcaso de dos visitas. Dentro de cada réplica se construye un
IC normal y uno percentil con 499 remuestras de episodios. Se realizan
500 réplicas independientes. La cobertura estimada tiene error Monte Carlo
$sqrt(hat(p)(1-hat(p))/500)$.

#codelisting-env(caption: [`lab05_bootstrap.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.stats import norm

rng = np.random.default_rng(20261027)
# Distribucion conocida de las contribuciones pareadas del ejemplo de dos visitas.
values = np.array([0.520, 0.340, 0.430, 0.610])
truth = values.mean()
M, n, B = 500, 100, 499
cover = np.zeros((M, 2), bool)
length = np.zeros((M, 2))
for j in range(M):
    d = rng.choice(values, size=n)
    se = d.std(ddof=1) / np.sqrt(n)
    intervals = [
        d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se,
        np.quantile(
            rng.choice(d, size=(B, n)).mean(axis=1), [0.025, 0.975]
        ),
    ]
    for k, (lo, hi) in enumerate(intervals):
        cover[j, k] = lo <= truth <= hi
        length[j, k] = hi - lo
for k, name in enumerate(["Normal", "Bootstrap percentil"]):
    p = cover[:, k].mean()
    mcse = np.sqrt(p * (1 - p) / M)
    print(
        f"{name}: cobertura={p:.3f}; MCSE={mcse:.4f}; longitud={length[:,k].mean():.5f}"
    )
print(f"M={M}; n={n}; B={B}; verdadero={truth:.3f}")
print("Varianza individual:", values.var())
print("Varianza de la media:", values.var() / n)
```
]

Las contribuciones usan modelos fijados de antemano. Si se aprende una
política o auxiliares en la misma muestra, ese aprendizaje debe incluirse
en el procedimiento de evaluación y remuestreo o controlarse mediante
una expansión válida. No se extrapola la cobertura del ejemplo a ese otro
estimador.

=== Laboratorio 5.2: Incertidumbre Epistémica vs. Aleatoria

La distribución de una contribución tiene varianza $0.010125$; la media de
cien contribuciones iid tiene varianza $0.00010125$. La variabilidad individual
permanece aunque aumente el tamaño, mientras la de la media disminuye bajo
este diseño. Más datos no eliminan sesgo de modelo o falta de identificación.

*Ejemplo numérico (SSCH) #sintetico.*
<ex:ssch-cap05>
#[
#set text(size: 8pt)
```text
Normal: cobertura=0.958; MCSE=0.0090; longitud=0.03958
Bootstrap percentil: cobertura=0.950; MCSE=0.0097; longitud=0.03900
M=500; n=100; B=499; verdadero=0.475
Varianza individual: 0.010124999999999999
Varianza de la media: 0.00010124999999999998
```
]

Estas son coberturas de una simulación limitada y completamente especificada,
no una demostración de validez general. Aumentar las réplicas Monte Carlo
mejora su precisión; aumentar las remuestras bootstrap resuelve otra fuente
de error numérico.

==== Preguntas de Exploración

+ Aumente separadamente el número de réplicas, el tamaño muestral y las
  remuestras internas. Distinga los tres efectos.
+ Compare una razón de valores cuyo denominador está alejado de cero con
  otra cuyo denominador se aproxima a cero; revise delta y bootstrap.
+ Introduzca aprendizaje de auxiliares y compare reajuste completo con
  mantener ajustes fijos. Identifique el estimando y la incertidumbre en
  cada procedimiento.

== Laboratorio 6: DML y Estimación Semiparamétrica
<lab:F6>
Cuando la estimación utiliza modelos auxiliares, hay que separar el aprendizaje de esos modelos de la evaluación del objetivo. El @ch:semiparametrica y el @thm:ch6-dml explican la relación que se examina en este laboratorio.

=== Objetivo

Implementar AIPW con cross-fitting y separar dos verificaciones: la identidad
poblacional de doble robustez y el comportamiento de un estimador aprendido
en una muestra. Se utiliza un generador conocido, sin atribuir el resultado
a una replicación de datos clínicos.

=== Conexión Teórica

Con $e(X)=Prob(A=1|X)$ y $m_a (X)=EE(Y|A=a,X)$, el pseudoresultado es
$ D=m_1(X)-m_0(X)+frac(A(Y-m_1(X)),e(X))
  -frac((1-A)(Y-m_0(X)),1-e(X)). $
Su esperanza es el ATE bajo identificación. La influencia centrada es
$D-psi$, no $D$ sin centrar. Para inferencia con ajustes aprendidos se
requieren condiciones de momentos, soporte, convergencia y productos de
errores, además de la separación de entrenamiento y evaluación.

=== Dataset y Setup

Se generan dos mil unidades iid con $X$ uniforme en $[-1,1]$,
$e(X)=1/(1+exp(-0.6X))$, $m_0(X)=X+X^2$ y
$m_1(X)=m_0(X)+1+0.5X$. El error es normal estándar, independiente de
covariable y asignación. En este generador, el ATE es exactamente uno.
Se ajustan cinco folds con propensión logística y regresiones cuadráticas
separadas por brazo. Las funciones verdaderas pertenecen a los modelos
ajustados; el ejercicio no demuestra validez para todo algoritmo ML.

=== Implementación

#codelisting-env(caption: [`lab06_aipw.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.special import expit
from scipy.stats import norm
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.model_selection import KFold

rng = np.random.default_rng(20261027)
n = 2000
x = rng.uniform(-1, 1, size=n)
X = x[:, None]
e = expit(0.6 * x)
a = rng.binomial(1, e)
m0 = x + x * x
m1 = m0 + 1 + 0.5 * x
y = m0 + a * (1 + 0.5 * x) + rng.normal(size=n)
eh = np.zeros(n)
h0 = np.zeros(n)
h1 = np.zeros(n)
for train, test in KFold(5, shuffle=True, random_state=42).split(X):
    ps = LogisticRegression(C=1e6, max_iter=1000).fit(X[train], a[train])
    eh[test] = ps.predict_proba(X[test])[:, 1]
    for arm, out in [(0, h0), (1, h1)]:
        ix = train[a[train] == arm]
        design = np.column_stack([x[ix], x[ix] ** 2])
        model = LinearRegression().fit(design, y[ix])
        out[test] = model.predict(
            np.column_stack([x[test], x[test] ** 2])
        )
assert np.all((eh > 0) & (eh < 1))
d = h1 - h0 + a * (y - h1) / eh - (1 - a) * (y - h0) / (1 - eh)
se = d.std(ddof=1) / np.sqrt(n)
print(f"ATE verdadero=1; AIPW={d.mean():.6f}; SE={se:.6f}")
print(
    "IC normal 95%:",
    np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
print(
    "Propensiones ajustadas min,max:", np.round([eh.min(), eh.max()], 6)
)
# Identidad poblacional DR comprobada por cuadratura, no por una sola muestra.
z, w = np.polynomial.legendre.leggauss(80)
w = w / 2
true_e = expit(0.6 * z)
t0 = z + z * z
t1 = t0 + 1 + 0.5 * z
for name, ee, u0, u1 in [
    ("ambos correctos", true_e, t0, t1),
    ("solo propension", true_e, np.zeros_like(z), np.zeros_like(z)),
    ("solo resultado", np.full_like(z, 0.5), t0, t1),
    (
        "ambos incorrectos",
        np.full_like(z, 0.5),
        np.zeros_like(z),
        np.zeros_like(z),
    ),
]:
    expected = (
        u1
        - u0
        + true_e * (t1 - u1) / ee
        - (1 - true_e) * (t0 - u0) / (1 - ee)
    )
    print(f"Esperanza AIPW, {name}: {w@expected:.6f}")
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
ATE verdadero=1; AIPW=0.977928; SE=0.045716
IC normal 95%: [0.888328 1.067529]
Propensiones ajustadas min,max: [0.334971 0.695206]
Esperanza AIPW, ambos correctos: 1.000000
Esperanza AIPW, solo propension: 1.000000
Esperanza AIPW, solo resultado: 1.000000
Esperanza AIPW, ambos incorrectos: 1.245613
```
]

La segunda parte integra la esperanza poblacional mediante cuadratura.
Muestra la cancelación cuando uno de los auxiliares es verdadero y un sesgo
cuando ambos son incorrectos en este ejemplo. Una única estimación muestral
cercana a uno no habría demostrado consistencia. La comprobación de
propensiones finitas no prueba positividad poblacional; aquí esta se conoce
por el generador.

=== Preguntas de Exploración

+ Repita la simulación para varios tamaños y reporte sesgo, RMSE, cobertura
y error Monte Carlo, reajustando todos los modelos en cada réplica.
+ Sustituya la propensión o las regresiones por constantes. Distinga
consistencia bajo una especificación correcta de validez del IC calculado
como si ambas fueran correctas.
+ Sustituya los modelos paramétricos por aproximadores no paramétricos y
registre qué condiciones de la expansión siguen justificadas. El desempeño
predictivo por sí solo no demuestra el producto de tasas requerido.
+ Si se aplica a datos reales, documente exposición, población, faltantes,
identificación y diseño. No reutilice los valores verdaderos de este simulador.

=== Ejercicios sobre identificación y modelos auxiliares

Los cálculos anteriores permiten volver a las condiciones que justifican el estimador. Los ejercicios siguientes examinan el papel del modelo, de la observación y de la separación entre entrenamiento y evaluación.

#exercise-env(key: "ex:ch6-ej1")[
  En una familia regular de localización con densidad conocida $f(x-mu)$,
  derive el score, su información y la influencia eficiente para $mu$.
  Indique condiciones de diferenciabilidad e integrabilidad. Explique
  por qué el modelo es paramétrico y qué cambiaría si $f$ fuera desconocida.
]
#exercise-env(key: "ex:ch6-ej2")[
  Observe $(X,S,S Y)$, con $S$ indicador de observación. Bajo
  independencia condicional entre $Y$ y $S$ dado $X$, propensión conocida $e(X)>0$, segundo momento de $Y$ y $EE[Var(Y|X)/e(X)]<infinity$,
  derive la influencia de $psi=EE(Y)$ usando $m(X)=EE(Y|X)$.
  Distinga identificación, centrado y eficiencia; el resultado $Y$ no
  está disponible cuando $S=0$.
]
#exercise-env(key: "ex:ch6-ej3")[
  Para ATE bajo intercambio condicional y positividad, escriba AIPW usando
  ambas regresiones $m_0,m_1$ y la propensión $e$. Derive su resto poblacional
  cuando los auxiliares son funciones fijas. Construya un ejemplo en el que
  ambos modelos incorrectos produzcan sesgo distinto de cero.
]
#exercise-env(key: "ex:ch6-ej4")[
  Diseñe cross-fitting de cinco folds para mil episodios independientes,
  sin repartir visitas del mismo episodio entre entrenamiento y evaluación.
  Indique qué evidencia apoya las tasas requeridas y por qué error predictivo
  pequeño o balance muestral no demuestra por sí solo una tasa poblacional.
]
#exercise-env(key: "ex:ch6-ej5")[
  En $Y=beta X+g(Z)+epsilon.alt$, especifique exogeneidad condicional,
  varianza del error y modelo de covariables antes de derivar una influencia
  eficiente. Compare homocedasticidad y heterocedasticidad; explique por qué
  OLS que omite $g(Z)$ puede ser inconsistente, no solo menos eficiente.
]

== Laboratorio 7: Regla de Decisión de Wald
<lab:F7>
El recorrido vuelve ahora a la elección de una regla. La pérdida y el criterio de riesgo del @ch:wald permiten interpretar por qué las mismas observaciones pueden conducir a decisiones diferentes.

=== Objetivo

Distinguir la regla de Bayes de una decisión de los algoritmos de exploración
en un bandit. Thompson Sampling no se identifica con la política Bayes
óptima de horizonte finito; UCB1 tampoco se denomina regla minimax de Wald.

=== Conexión Teórica

Con una ronda restante y recompensa Bernoulli, la acción Bayes maximiza
la media posterior. Con varias rondas, la elección afecta la información
futura y la optimización bayesiana es un problema dinámico. Thompson Sampling
muestrea parámetros del posterior y actúa según ellos: es otro procedimiento.

El código mide pseudo-arrepentimiento
$ sum_(t=1)^T (max_a theta_a-theta_(A_t)). $
Es aleatorio por la selección de acciones, pero no incluye el ruido de la
recompensa realizada. No es el riesgo Bayes integrado respecto de un prior.
Una media de cien corridas tampoco verifica una cota de orden asintótico.

=== Dataset y Setup

Cinco brazos Bernoulli con probabilidades $(0.1,0.3,0.5,0.7,0.9)$,
dos mil rondas y cien corridas por algoritmo. Se comparan Thompson Sampling,
UCB1 y $epsilon.alt$-greedy con $epsilon.alt=0.1$. Se incluyen todas las
rondas iniciales en el pseudo-arrepentimiento. Las semillas se fijan por
corrida; no se supone que produzcan trayectorias idénticas entre algoritmos.

=== Implementación

#codelisting-env(caption: [`lab07_bandit.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np

THETA = np.array([0.1, 0.3, 0.5, 0.7, 0.9])
K = len(THETA)


def run(method, seed, T=2000):
    rng = np.random.default_rng(seed)
    counts = np.zeros(K, int)
    sums = np.zeros(K)
    regret = 0.0
    for t in range(T):
        if method == "TS":
            a = int(np.argmax(rng.beta(1 + sums, 1 + counts - sums)))
        elif method == "UCB1":
            a = (
                t
                if t < K
                else int(
                    np.argmax(
                        sums / counts
                        + np.sqrt(2 * np.log(t + 1) / counts)
                    )
                )
            )
        else:
            a = (
                int(rng.integers(K))
                if rng.random() < 0.1
                else int(np.argmax(sums / np.maximum(counts, 1)))
            )
        y = rng.binomial(1, THETA[a])
        counts[a] += 1
        sums[a] += y
        regret += THETA.max() - THETA[a]  # Incluye las rondas iniciales.
    assert counts.sum() == T
    return regret


if __name__ == "__main__":
    for method in ["TS", "UCB1", "epsilon-greedy"]:
        values = np.array([run(method, 20261027 + j) for j in range(100)])
        print(
            f"{method}: pseudo-regret medio={values.mean():.3f}; MCSE={values.std(ddof=1)/10:.3f}"
        )
    # Una decision restante: Bayes elige la mayor media posterior.
    means = np.array([3 / 4, 5 / 10])
    print("Bayes con una ronda restante:", int(np.argmax(means)))
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
TS: pseudo-regret medio=14.404; MCSE=0.451
UCB1: pseudo-regret medio=94.150; MCSE=1.294
epsilon-greedy: pseudo-regret medio=104.736; MCSE=2.287
Bayes con una ronda restante: 0
```
]

La comparación corresponde a este vector de probabilidades, horizonte e
inicialización. No demuestra superioridad uniforme, admisibilidad ni
optimalidad minimax. El error Monte Carlo acompaña las medias para evitar
interpretar una sola trayectoria como propiedad general.

=== Preguntas de Exploración

+ Compare medias posteriores y Thompson Sampling con una sola ronda
restante; explique por qué las decisiones pueden diferir.
+ Varíe las brechas entre brazos y el prior. Reporte por separado el
arrepentimiento inicial y el total, con incertidumbre Monte Carlo.
+ Para dos brazos y un horizonte pequeño, enumere estados de creencia y
resuelva la recursión Bayes exacta. Compárela con Thompson Sampling.
+ Si diseña un selector entre algoritmos, evalúelo en corridas nuevas.
No atribuya al selector las garantías de sus componentes sin otro argumento.

== Laboratorio 8: MDP y Programación Dinámica
<lab:F8>
Cuando una acción cambia el futuro, la comparación requiere una función de valor. El @ch:mdp-bellman y el @thm:ch8-contraccion dan el fundamento para seguir el cálculo y su residuo.

=== Objetivo

Calcular la política óptima del SSCH tabular mediante iteración de valores
y evaluación exacta de políticas. Se distingue una cota determinista del
error computacional de la incertidumbre por estimar el modelo.

=== Conexión Teórica

En el modelo finito descontado, Bellman contrae en norma suprema. Si
$e=norm(cal(T)V-V)_infinity$, entonces
$ norm(V-V^*)_infinity<=e/(1-gamma). $
El programa termina por esta cota. La pérdida de la política greedy es
otra cantidad y requiere su cota correspondiente. La iteración de políticas
se ejecuta con evaluación por sistema lineal y conserva la acción previa
en empates numéricos. No se afirma una tasa cuadrática universal.

=== Dataset y Setup

Se importa `model`, `R`, `GAMMA` y `evaluate` de `lab00_ssch.py`.
El planificador recibe el modelo verdadero conocido del simulador, no la
matriz estimada con ochenta transiciones por fila. El contraste entre ambas
matrices queda como extensión para separar error estadístico y computacional.

=== Implementación

#codelisting-env(caption: [`lab08_bellman.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from lab00_ssch import model, R, GAMMA, evaluate

P = model()


def qvalues(v):
    return R + GAMMA * np.einsum("saj,j->sa", P, v)


def bellman(v):
    return qvalues(v).max(axis=1)


v = np.zeros(5)
for k in range(10000):
    v = bellman(v)
    res = np.max(np.abs(bellman(v) - v))
    if res / (1 - GAMMA) < 1e-9:
        break
else:
    raise RuntimeError("VI no converge")
pi = np.zeros(5, int)
for j in range(1000):
    vp, _ = evaluate(P, np.eye(4)[pi])
    q = qvalues(vp)
    new = pi.copy()
    # Conservar accion anterior en empates numericos.
    for s in range(5):
        best = int(q[s].argmax())
        if q[s, best] > q[s, pi[s]] + 1e-12:
            new[s] = best
    if np.array_equal(new, pi):
        break
    pi = new
else:
    raise RuntimeError("PI no converge")
assert np.max(np.abs(v - vp)) < 1e-8
print("Politica optima (acciones 1..4):", pi + 1)
print("V* por PI:", np.round(vp, 6))
print(f"VI: {k+1} actualizaciones; PI: {j+1} evaluaciones")
print(f"Residuo VI={res:.3e}; cota error valor={res/(1-GAMMA):.3e}")
rng = np.random.default_rng(42)
for _ in range(100):
    x, y = rng.normal(size=(2, 5))
    assert (
        np.max(np.abs(bellman(x) - bellman(y)))
        <= GAMMA * np.max(np.abs(x - y)) + 1e-12
    )
print("Comprobaciones numericas de contraccion: OK")
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
Politica optima (acciones 1..4): [2 3 3 4 4]
V* por PI: [7.77928  7.311139 7.096966 7.102004 6.46565 ]
VI: 216 actualizaciones; PI: 3 evaluaciones
Residuo VI=9.645e-11; cota error valor=9.645e-10
Comprobaciones numericas de contraccion: OK
```
]

La coincidencia entre VI y PI y las comprobaciones numéricas detectan
posibles errores de implementación. El teorema de contracción justifica
la cota para todas las entradas del espacio considerado; probar cien pares
de vectores no sustituye ese teorema. Los números de iteraciones tampoco
son una comparación directa de costos: una evaluación de política y una
actualización de valores no realizan el mismo trabajo.

=== Preguntas de Exploración

+ Cambie el descuento y compare residuo, cota de error y número de
actualizaciones. No use una fórmula que divida por $norm(V_0)$ si $V_0=0$.
+ Planifique con la matriz estimada de 0 y evalúe la política resultante
bajo la matriz verdadera. Separe error de planificación y error del modelo.
+ Extienda a un entorno con estados terminales. En el backup, anule el
valor futuro después de la terminación; documente aparte la truncación
por un límite artificial de tiempo.

== Laboratorio 9: Demostración de la Incrustación Fiel
<lab:F9>
Con la regla y el proceso definidos, podemos comprobar qué conserva su representación. Este laboratorio examina la identidad del @thm:ch9-isomorfismo dentro del alcance del @ch:isomorfismo.

=== Objetivo

Verificar por enumeración la identidad de riesgo y retorno en un problema
finito de una decisión. La demostración general está en el capítulo teórico;
este laboratorio comprueba todas las reglas del ejemplo.

=== Conexión Teórica

El índice desconocido $theta$ identifica la ley de observación. El estado
observado del MDP es $x$, no $theta$. Para cada regla determinista
$delta(x)$, la política copiada recibe recompensa evaluativa
$-L(theta,delta(x))$ y termina. Al promediar respecto de $P_theta$,
$ J_theta (pi_delta)=-R(theta,delta). $
No se entrega al agente el parámetro verdadero ni se presupone que la
recompensa evaluativa pueda observarse en una aplicación.

=== Dataset y Setup

Hay dos modelos, dos observaciones posibles y dos acciones. La matriz de
probabilidades de observación es
$ P_X=mat(0.8,0.2;0.2,0.8), $
y la de pérdidas, con filas por modelo y columnas por acción, es
$ L=mat(0,1;3,0). $
El prior asigna probabilidad $1/2$ a cada modelo. Se enumeran las cuatro
reglas deterministas, incluida la que elige una acción distinta para cada
observación. No se confunde la optimización de una acción posterior con
una verificación del riesgo de una regla completa.

=== Implementación

#codelisting-env(caption: [`lab09_incrustacion.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from itertools import product

# Experimento finito: theta indexa modelos, x es el estado observado.
theta = np.array([0.2, 0.8])
prior = np.array([0.5, 0.5])
PX = np.array([[0.8, 0.2], [0.2, 0.8]])  # Filas theta; columnas x=0,1.
L = np.array([[0, 1], [3, 0.0]])  # Filas theta; acciones 0,1.
rules = list(product([0, 1], repeat=2))
risks = []
for rule in rules:
    risk = np.array(
        [
            sum(PX[k, x] * L[k, rule[x]] for x in range(2))
            for k in range(2)
        ]
    )
    ret = np.array(
        [
            sum(PX[k, x] * (-L[k, rule[x]]) for x in range(2))
            for k in range(2)
        ]
    )
    assert np.allclose(risk, -ret)
    risks.append(risk)
    print(f"regla={rule}; riesgo={risk}; retorno={ret}")
risks = np.array(risks)
bayes = risks @ prior
best = int(bayes.argmin())
print("Regla Bayes:", rules[best], "; riesgo Bayes:", bayes[best])
assert rules[best] == (0, 1)
# Imagen exacta de un conjunto: objetivo de una accion fijada, no optimizada.
C = np.array([0.25, 0.55])
c = 0.2
print("Imagen por g(theta)=-c*(1-theta):", -c * (1 - C))
print("Todas las reglas enumeradas satisfacen J=-R: OK")
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
regla=(0, 0); riesgo=[0. 3.]; retorno=[ 0. -3.]
regla=(0, 1); riesgo=[0.2 0.6]; retorno=[-0.2 -0.6]
regla=(1, 0); riesgo=[0.8 2.4]; retorno=[-0.8 -2.4]
regla=(1, 1); riesgo=[1. 0.]; retorno=[-1.  0.]
Regla Bayes: (0, 1) ; riesgo Bayes: 0.4
Imagen por g(theta)=-c*(1-theta): [-0.15 -0.09]
Todas las reglas enumeradas satisfacen J=-R: OK
```
]

La regla Bayes del experimento finito es $(0,1)$ y su riesgo Bayes es $0.4$.
La última línea de imagen de un conjunto es un ejemplo separado: para una
acción fijada y $g(theta)=-0.2(1-theta)$, la imagen de $[0.25,0.55]$ es
$[-0.15,-0.09]$. Si el conjunto inicial fuera un IC válido, su imagen
heredaría al menos su cobertura. No se convierte un intervalo posterior
en uno frecuentista mediante un cambio de nombre, ni se afirma cobertura
para una política seleccionada con los mismos datos sin tratar la selección.

=== Preguntas de Exploración

+ Cambie el prior y calcule todas las pérdidas Bayes. Identifique los
valores donde cambia la regla y cómo se resuelven empates.
+ Añada una segunda decisión con observación intermedia. Especifique el
nuevo problema y explique qué parte ya no queda cubierta por la identidad
de una decisión del libro.
+ Para un funcional no monótono, compare la imagen del conjunto completo
con la transformación de sus extremos. Distinga esta construcción del
método delta local.

== Laboratorio 10: Off-Policy Evaluation
<lab:F10>
La evaluación pasa ahora a datos producidos por otra política. El @ch:ope y el @ch:inferencia permiten distinguir la estimación del valor, los diagnósticos y la incertidumbre de la comparación.

=== Laboratorio 10.1: Pipeline OPE Completo en CartPole

==== Objetivo

Comparar DM, IS, PDIS y DR secuencial en CartPole con horizonte truncado
prefijado de veinte decisiones y descuento $0.99$. El objetivo es el retorno
hasta esa truncación o terminación anterior; no es el valor infinito ni
el rendimiento hasta el límite estándar del entorno.

El registro elige cada acción con probabilidad $0.5$. La política objetivo
es una función fija de las coordenadas observadas:
$ pi(1|s)=0.2+0.6/(1+exp(-(4s_3+s_4))). $
Las probabilidades de ambas acciones suman uno y están entre $0.2$ y $0.8$.
No se asigna el mismo numerador a las dos acciones ni se inventa una
propensión pequeña para sustituir datos ausentes.

==== Arquitectura LangGraph

La arquitectura conceptual tiene nodos de recolección, ajuste de $q_t$,
contribuciones y diagnóstico. El código los ejecuta como funciones de
Python para que el cálculo sea inspeccionable sin un servicio externo.
Si se encapsulan en LangGraph, deben conservarse exactamente los mismos
datos, particiones y fórmulas; la orquestación no añade validez estadística.

Se usan seiscientos episodios de entrenamiento independientes de mil de
evaluación. El crítico se ajusta hacia atrás mediante regresión ridge y
rasgos polinómicos, ponderando la continuación por la política objetivo.
Puede estar mal especificado. Las probabilidades de registro son conocidas;
esto conserva el centrado de IS y DR bajo el diseño, condicionado al ajuste
externo, con las condiciones de integrabilidad pertinentes.

La contribución DR de un episodio es
$ D_i=hat(v)_0(S_(i,0))+sum_(t=0)^(H_i-1)gamma^t rho_(i,0:t)
  (R_(i,t)+gamma hat(v)_(t+1) (S_(i,t+1))-hat(q)_t (S_(i,t),A_(i,t))), $
con continuación cero después de terminar. El código incluye el término
inicial, descuento, razón acumulada, valor siguiente y tratamiento de la
terminación. Los intervalos usan variación entre episodios independientes.

La interfaz del entorno sigue la
#link("https://gymnasium.farama.org/api/env/")[documentación oficial de Gymnasium]:
se fijan semillas al reiniciar y se distinguen terminación y truncación.
En este objetivo finito, ambas ponen fin al retorno observado.

#codelisting-env(caption: [`lab10_cartpole.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
import gymnasium as gym
from scipy.special import expit
from scipy.stats import norm

H, GAMMA = 20, 0.99


def target(s):
    p = 0.2 + 0.6 * expit(4 * s[2] + s[3])
    return np.array([1 - p, p])


def collect(n, seed, on_target=False):
    rng = np.random.default_rng(seed)
    env = gym.make("CartPole-v1")
    data = []
    for _ in range(n):
        s, _ = env.reset(seed=int(rng.integers(2**31 - 1)))
        episode = []
        for t in range(H):
            probs = target(s) if on_target else np.array([0.5, 0.5])
            a = int(rng.choice(2, p=probs))
            nxt, r, terminated, truncated, _ = env.step(a)
            end = bool(terminated or truncated or t == H - 1)
            episode.append(
                (s.copy(), a, float(r), nxt.copy(), end, float(probs[a]))
            )
            s = nxt
            if end:
                break
        data.append(episode)
    env.close()
    return data


def features(s, a):
    return np.r_[1.0, s, s * s, float(a), a * s]


def fit_q(train):
    beta = [np.zeros(14) for _ in range(H)]

    def value(t, s):
        if t >= H:
            return 0.0
        return sum(
            target(s)[a] * (features(s, a) @ beta[t]) for a in range(2)
        )

    for t in reversed(range(H)):
        rows = [ep[t] for ep in train if len(ep) > t]
        if not rows:
            raise ValueError(
                "Sin datos de entrenamiento para este tiempo"
            )
        X = np.array([features(s, a) for s, a, r, nxt, end, b in rows])
        y = np.array(
            [
                r + (0 if end else GAMMA * value(t + 1, nxt))
                for s, a, r, nxt, end, b in rows
            ]
        )
        beta[t] = np.linalg.solve(X.T @ X + 0.1 * np.eye(14), X.T @ y)
    return beta


def scores(episode, beta):
    def q(t, s, a):
        return float(features(s, a) @ beta[t]) if t < H else 0.0

    def v(t, s):
        return (
            sum(target(s)[a] * q(t, s, a) for a in range(2))
            if t < H
            else 0.0
        )

    dm = v(0, episode[0][0])
    dr = dm
    w = 1.0
    pdis = 0.0
    ret = 0.0
    for t, (s, a, r, nxt, end, b) in enumerate(episode):
        if not (0 < b <= 1):
            raise ValueError("Propension registrada no valida")
        w *= target(s)[a] / b
        ret += GAMMA**t * r
        pdis += GAMMA**t * w * r
        dr += (
            GAMMA**t
            * w
            * (r + (0 if end else GAMMA * v(t + 1, nxt)) - q(t, s, a))
        )
    return dm, w * ret, pdis, dr, w, ret


def pipeline():
    train = collect(600, 20261027)
    evaluation = collect(1000, 20261028)
    beta = fit_q(train)
    out = np.array([scores(ep, beta) for ep in evaluation])
    for k, name in enumerate(["DM", "IS", "PDIS", "DR"]):
        est = out[:, k].mean()
        se = out[:, k].std(ddof=1) / np.sqrt(len(out))
        print(f"{name}: media={est:.5f}; SE entre episodios={se:.5f}")
    # El SE de DM no contempla el sesgo de aproximacion ni todo el entrenamiento.
    d = out[:, 3]
    se = d.std(ddof=1) / np.sqrt(len(d))
    print(
        "IC DR normal 95%:",
        np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 5),
    )
    w = out[:, 4]
    print(
        f"ESS pesos finales={w.sum()**2/(w@w):.2f}/1000; max={w.max():.3f}"
    )
    # Referencia independiente on-policy: estimacion MC, no verdad exacta.
    reference = collect(5000, 20261029, on_target=True)
    g = np.array(
        [
            sum(GAMMA**t * row[2] for t, row in enumerate(ep))
            for ep in reference
        ]
    )
    print(
        f"Referencia on-policy={g.mean():.5f}; SE={g.std(ddof=1)/np.sqrt(len(g)):.5f}"
    )
    assert np.isfinite(out).all() and np.all(w > 0)
    return {
        "n_evaluation": len(out),
        "horizon": H,
        "dr": float(d.mean()),
        "se": float(se),
    }


if __name__ == "__main__":
    pipeline()
```
]

*Salida de la ejecución de referencia.*
#[
#set text(size: 8pt)
```text
DM: media=16.98554; SE entre episodios=0.00096
IS: media=16.85609; SE entre episodios=0.53158
PDIS: media=17.12232; SE entre episodios=0.24905
DR: media=17.30569; SE entre episodios=0.04221
IC DR normal 95%: [17.22297 17.38842]
ESS pesos finales=535.29/1000; max=4.014
Referencia on-policy=17.24282; SE=0.02907
```
]

La referencia on-policy usa otros cinco mil episodios y tiene su propio
error Monte Carlo; no es una verdad exacta. El SE impreso para DM solo
describe variación de su predicción entre estados iniciales condicionada
al entrenamiento: no contempla su sesgo de aproximación ni toda la
incertidumbre del ajuste. No debe interpretarse como un IC válido para
el valor verdadero. En este experimento, el IC DR se justifica por la
ruta de contribuciones independientes y registro conocido; no por SAVE.

=== Laboratorio 10.2: Diagnóstico de Overlap y Protocolo de Fallback

El soporte se conoce aquí por construcción. El ESS de los pesos finales
resume su concentración en la muestra; no certifica soporte poblacional,
normalidad del estimador ni cobertura. La unidad del denominador del ESS
es el episodio, coherente con esos pesos.

Si un registro necesario tiene probabilidad cero bajo la política de
comportamiento y positiva bajo la objetivo, la evaluación por importancia
no está identificada a partir de esos datos sin supuestos adicionales.
Si hay concentración extrema, se informa sensibilidad y precisión; no se
cambia silenciosamente a DM como si garantizara el mismo objetivo. Recortar
pesos introduce sesgo, y restringir acciones o población puede cambiar el
estimando. Cada alternativa necesita una justificación y un dictamen nuevo.

==== Preguntas de Exploración

+ Repita entrenamiento y evaluación en muestras nuevas para medir sesgo,
RMSE y cobertura. Use una referencia on-policy mucho más precisa y reporte
su error residual.
+ Varíe el horizonte y mantenga fijas las políticas. Examine pesos acumulados,
ESS y varianza de IS, PDIS y DR sin atribuir eficiencia universal a DR.
+ Compare pesos recortados y normalizados, documentando el sesgo y la
fórmula de varianza correspondiente. No use el IC de IS sin modificaciones.
+ Añada nodos de orquestación y compruebe que sus contribuciones coinciden
con las funciones de referencia para los mismos episodios.

== Laboratorio 11: Inferencia Secuencial para Funciones de Valor
<lab:F11>
La estructura temporal de los datos vuelve a ser decisiva al construir un intervalo. El @ch:inferencia, el @thm:ch11-clt-mixing y la @def:ch11-hac orientan la elección de la varianza y la lectura de sus límites.

=== Objetivo

Estudiar el efecto de dependencia temporal en una media y comparar HAC,
bootstrap por bloques y un IC que ignora la dependencia. «Secuencial»
describe aquí la estructura de los datos; el análisis se hace al tamaño
prefijado y no proporciona validez bajo parada opcional.

=== Conexión Teórica

Use una cadena estacionaria de dos estados con matriz
$ P=mat(0.8,0.2;0.2,0.8) $
y observable $X_t in {-1,1}$. Su media es cero, su varianza uno y su
autocovarianza es $0.6^k$. Por tanto,
$ sigma_"LR"^2=1+2sum_(k>=1)0.6^k=4. $
El error estándar asintótico de la media es $2/sqrt(T)$, frente a
$1/sqrt(T)$ si se ignora la dependencia. Esta comparación tiene verdad
analítica; no se deduce de que dos intervalos resulten parecidos.

La cadena es reversible y su radio no trivial es $0.6$. La distancia en
variación total desde cualquiera de sus estados es $0.5(0.6)^k$.
El tiempo calculado para esa cota no se generaliza a cualquier MDP mediante
una fórmula que solo incluya un autovalor estimado.

=== Dataset y Setup

Mil pasos de una cadena iniciada en su distribución estacionaria uniforme.
Se muestran HAC con rezagos 10, 20 y 40, y bootstrap de bloques móviles con
longitud veinte y 999 remuestras. Una evaluación de cobertura adicional
usa 500 cadenas nuevas para el intervalo iid incorrecto y HAC de rezago
veinte. El estudio no estima cobertura del bootstrap en esas 500 réplicas.

=== Implementación

#codelisting-env(caption: [`lab11_dependencia.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.stats import norm

P = np.array([[0.8, 0.2], [0.2, 0.8]])
rho = 0.6
T = 1000


def chain(rng, n):
    x = np.empty(n)
    state = int(rng.integers(2))
    for t in range(n):
        x[t] = 2 * state - 1
        if rng.random() < 0.2:
            state = 1 - state
    return x


def hac(x, K):
    if not (0 <= K < len(x)):
        raise ValueError("Rezagos fuera de rango")
    z = x - x.mean()
    n = len(z)
    v = z @ z / n
    for k in range(1, K + 1):
        v += 2 * (1 - k / (K + 1)) * (z[k:] @ z[:-k]) / n
    if v < -1e-10:
        raise ArithmeticError("Varianza negativa: revisar implementacion")
    return max(0.0, v)


rng = np.random.default_rng(20261027)
x = chain(rng, T)
print(f"Media verdadera=0; estimada={x.mean():.5f}; varianza LR exacta=4")
for K in [10, 20, 40]:
    var = hac(x, K)
    se = np.sqrt(var / T)
    print(
        f"HAC K={K}: LR={var:.5f}; IC={np.round(x.mean()+np.array([-1,1])*norm.ppf(.975)*se,5)}"
    )
# Moving block bootstrap: bloques solapados y longitud prefijada.
b, B = 20, 999
starts = rng.integers(0, T - b + 1, size=(B, int(np.ceil(T / b))))
ix = (starts[:, :, None] + np.arange(b)).reshape(B, -1)[:, :T]
boot = x[ix].mean(axis=1)
print(
    "IC block bootstrap percentil:",
    np.round(np.quantile(boot, [0.025, 0.975]), 5),
)
r = max(abs(np.linalg.eigvals(P - np.ones((2, 2)) * 0.5)))
k = int(np.ceil(np.log(2 * 0.01) / np.log(r)))
print(
    f"Radio no trivial={r:.2f}; gap absoluto={1-r:.2f}; pasos TV<=0.01: {k}"
)
print(
    f"Tamano efectivo asintotico del observable: {T*(1-rho)/(1+rho):.1f}"
)
M = 500
covered = np.zeros((M, 2), bool)
for j in range(M):
    y = chain(rng, T)
    ses = [y.std(ddof=1) / np.sqrt(T), np.sqrt(hac(y, 20) / T)]
    for c, se in enumerate(ses):
        covered[j, c] = abs(y.mean()) <= norm.ppf(0.975) * se
for c, name in enumerate(["iid aplicado incorrectamente", "HAC K=20"]):
    p = covered[:, c].mean()
    print(f"{name}: cobertura={p:.3f}; MCSE={np.sqrt(p*(1-p)/M):.4f}")
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
Media verdadera=0; estimada=-0.10600; varianza LR exacta=4
HAC K=10: LR=3.49375; IC=[-0.22185  0.00985]
HAC K=20: LR=4.15126; IC=[-0.23228  0.02028]
HAC K=40: LR=4.96757; IC=[-0.24414  0.03214]
IC block bootstrap percentil: [-0.232   0.0203]
Radio no trivial=0.60; gap absoluto=0.40; pasos TV<=0.01: 8
Tamano efectivo asintotico del observable: 250.0
iid aplicado incorrectamente: cobertura=0.660; MCSE=0.0212
HAC K=20: cobertura=0.918; MCSE=0.0123
```
]

El tamaño efectivo $T/4$ corresponde al observable y a su varianza
asintótica, no a un conteo universal de datos independientes. Las coberturas
observadas incluyen error Monte Carlo. Los rezagos fijos de esta ejecución
son elecciones de muestra finita; no constituyen por sí solos una secuencia
de anchos que pruebe consistencia HAC al crecer $T$.

Episodios de CartPole reiniciados independientemente no deben declararse
dependientes solo porque cada uno contiene transiciones correlacionadas.
Por eso este laboratorio utiliza una trayectoria realmente dependiente.

=== Preguntas de Exploración

+ Repita con autocorrelación negativa y explique por qué ignorar dependencia
no siempre estrecha el intervalo: también puede hacerlo más ancho.
+ Estudie cobertura del bootstrap por bloques con varias longitudes y
muchas cadenas nuevas. Declare el costo y error Monte Carlo.
+ Construya una cadena no reversible y explique qué parte de la cota
espectral anterior deja de estar justificada.
+ Compare una media de una trayectoria larga con una media de retornos
de episodios independientes, identificando la unidad de cada varianza.

== Laboratorio 12: LLM-Agents y Síntesis
<lab:F12>
El último laboratorio reúne las preguntas anteriores en un agente con acciones registradas. El @ch:verificacion y el @ch:sintesis permiten recuperar qué se ha evaluado y qué conclusiones quedan por justificar.

=== Objetivo

Evaluar dos políticas de selección de acciones discretas en un simulador
de diálogos. El experimento no ejecuta un modelo de lenguaje: representa
un selector entre cuatro acciones abstractas para aislar el problema
estadístico. El valor verdadero puede calcularse por Bellman finito.

=== Conexión Teórica

Las probabilidades registradas corresponden al mecanismo que selecciona
la acción realmente ejecutada. Clasificar después un texto libre en cuatro
categorías no convierte las probabilidades de sus tokens en probabilidades
de esas categorías. Para trasladar el análisis a un agente real se necesita
un mecanismo de selección documentado y una política objetivo definida
sobre las mismas acciones y estados.

El contraste usa diferencias pareadas de contribuciones DR por diálogo,
con $H=3$ y $gamma=0.9$. Un rechazo bilateral no demuestra superioridad
sin examinar el signo; aquí se utiliza un contraste unilateral de mejora
prefijado, junto con un intervalo bilateral descriptivo.

=== Dataset y Setup

Dos estados observados, cuatro acciones y dos mil diálogos independientes.
La política de registro es $(0.4,0.3,0.2,0.1)$ y la candidata
$(0.2,0.5,0.1,0.2)$. El código especifica todas las medias de recompensa
Bernoulli y transiciones entre estados. Los críticos se fijan en el 80%
de los valores verdaderos para introducir una mala especificación
controlada; no son modelos entrenados con acceso a información real.

El registro correcto mantiene el centrado DR en este simulador. El estado
inicial es uniforme y el valor objetivo promedia respecto de esa ley.
Sumar una constante común a todos los logits no cambia una distribución
softmax: el programa incluye esta comprobación para impedir interpretar
ese desplazamiento como una política mejorada.

=== Implementación

#codelisting-env(caption: [`lab12_dialogos.py`. Código ejecutado.])[
#set text(size: 8pt)
```python
import numpy as np
from scipy.stats import norm

H, GAMMA = 3, 0.9
B = np.array([0.4, 0.3, 0.2, 0.1])
E = np.array([0.2, 0.5, 0.1, 0.2])
MU = np.array([[0.6, 0.8, 0.1, 0.3], [0.4, 0.7, 0.2, 0.5]])
P1 = np.array([[0.2, 0.1, 0.4, 0.3], [0.4, 0.3, 0.6, 0.5]])


def truth(policy):
    v = np.zeros((H + 1, 2))
    q = np.zeros((H, 2, 4))
    for t in reversed(range(H)):
        q[t] = MU + GAMMA * ((1 - P1) * v[t + 1, 0] + P1 * v[t + 1, 1])
        v[t] = q[t] @ policy
    return v, q


def evaluate(ep, policy, qhat):
    vhat = qhat @ policy
    value = vhat[0, ep[0][0]]
    w = 1.0
    for t, (s, a, r, nxt) in enumerate(ep):
        w *= policy[a] / B[a]
        vn = 0 if t == H - 1 else vhat[t + 1, nxt]
        value += GAMMA**t * w * (r + GAMMA * vn - qhat[t, s, a])
    return value, w


rng = np.random.default_rng(20261027)
N = 2000
ve, qe = truth(E)
vb, qb = truth(B)
# Auxiliares fijos deliberadamente imperfectos: registro exacto mantiene el centrado.
qhe = 0.8 * qe
qhb = 0.8 * qb
contrib = []
weights = []
for _ in range(N):
    s = int(rng.integers(2))
    ep = []
    for t in range(H):
        a = int(rng.choice(4, p=B))
        r = int(rng.binomial(1, MU[s, a]))
        nxt = int(rng.binomial(1, P1[s, a]))
        ep.append((s, a, r, nxt))
        s = nxt
    de, w = evaluate(ep, E, qhe)
    db, _ = evaluate(ep, B, qhb)
    contrib.append(de - db)
    weights.append(w)
d = np.array(contrib)
w = np.array(weights)
se = d.std(ddof=1) / np.sqrt(N)
true = ve[0].mean() - vb[0].mean()
p = norm.sf(d.mean() / se)
print(
    f"Diferencia verdadera={true:.6f}; estimada DR={d.mean():.6f}; SE={se:.6f}"
)
print(
    "IC bilateral 95%:",
    np.round(d.mean() + np.array([-1, 1]) * norm.ppf(0.975) * se, 6),
)
print(
    f"Limite inferior unilateral={d.mean()-norm.ppf(.95)*se:.6f}; p={p:.6g}"
)
print(f"ESS pesos finales={w.sum()**2/(w@w):.2f}/{N}")
print("Decision de mejora, analisis unico:", p < 0.05)
assert np.isclose(B.sum(), 1) and np.isclose(E.sum(), 1)
# Sumar una constante a todos los logits NO cambia una politica softmax.
softmax = lambda z: np.exp(z - z.max()) / np.exp(z - z.max()).sum()
assert np.allclose(softmax(np.log(B) + 0.3), B)
print("Invariancia softmax a desplazamiento comun: OK")
```
]

=== Resultados Esperados

#[
#set text(size: 8pt)
```text
Diferencia verdadera=0.195388; estimada DR=0.226384; SE=0.016039
IC bilateral 95%: [0.194948 0.257821]
Limite inferior unilateral=0.200002; p=1.54763e-45
ESS pesos finales=751.79/2000
Decision de mejora, analisis unico: True
Invariancia softmax a desplazamiento comun: OK
```
]

La diferencia verdadera y la estimada corresponden al simulador, no a un
benchmark de calidad de LLM. La decisión de mejora utiliza un único análisis
con políticas fijadas de antemano. El ESS describe los pesos observados;
no valida la abstracción de texto, la recompensa ni la propiedad Markov.

=== Preguntas de Exploración

+ Diseñe un selector real entre acciones discretas que registre las
probabilidades exactas, la versión de la política y la información disponible
antes de actuar. Defina cómo se mantiene estable la recompensa.
+ Aprenda críticos en diálogos separados y compare su error y la varianza
DR. Si selecciona la candidata con datos, reserve evaluación independiente
o justifique un procedimiento que trate la selección.
+ Prefije momentos de revisión y un control de error secuencial válido.
No detenga un test ordinario la primera vez que su p-valor sea pequeño.
+ Compare predicción de siguiente estado y recompensa usando estado resumido
frente a historia. Un aumento de precisión puede revelar una limitación;
ningún umbral arbitrario de accuracy demuestra o refuta por sí solo todas
las condiciones Markov e identificación necesarias.

El cierre de cada laboratorio debe identificar el estimando, las unidades,
el modelo, la fórmula implementada, la evidencia calculada y el límite de
la conclusión. El @ch:verificacion proporciona el procedimiento para
registrarlo; el despliegue requiere revisar nuevamente esas condiciones
cuando cambian datos, política o entorno.
]

Los experimentos permiten reconocer qué cálculo corresponde a cada afirmación. El paso siguiente consiste en conservar esa relación cuando el procedimiento se ejecuta bajo restricciones de tiempo, precisión y acceso a las acciones. El @ch:despliegue estudia cómo documentar esos cambios y cuándo requieren otra evaluación.
