// Puerto de apendices/apendice_langgraph.tex — LangGraph: Formalización Técnica.
#import "../plantilla.typ": *
#import "@preview/cetz:0.3.4": canvas, draw

// Fase 2B — PENDIENTE-CAP11.
// Este apéndice se conserva sin cambios hasta que exista el nuevo cap. 11
// («De la garantía al despliegue»). Solo el cap. 11 y el laboratorio lo
// invocan; si el cap. 11 no lo cita, el apéndice pierde razón de ser y su
// destino se decide en Fase 3. No eliminar antes de esa decisión.
// Nota de la auditoría: atar una monografía a la API de una biblioteca
// concreta compra obsolescencia; el cap. 11 debería hablar de restricciones
// de despliegue en términos agnósticos (cuantización, latencia,
// evaluabilidad de la política), no de un framework.

= LangGraph: organización de los cálculos de un agente
<app:langgraph>

Los capítulos anteriores distinguen observación, estimación y decisión. Este apéndice muestra cómo pueden organizarse esas tareas mediante un grafo de estado en LangGraph. Los nombres de los nodos describen responsabilidades del programa; su relación con un MDP debe justificarse mediante el modelo y la información que conserva el estado, como se discutió en el @ch:verificacion.

== Ontología de Componentes
<app:lg-ontologia>

LangGraph modela agentes como grafos de estado dirigidos. Los
componentes fundamentales son:

// Fix L6 (Entrega 7.B.iv): nota de alcance para distinguir el grafo de
// control interno del agente (determinista por construcción) de la
// dinámica del ambiente (que puede ser estocástica). Antes esta
// distinción quedaba implícita.
#thm-env("note", name: [Nota de alcance: grafo de control vs. dinámica del ambiente], key: "note:appC-grafo-vs-ambiente")[
  El `StateGraph` y sus nodos describen una implementación. Un registro interno $z$ y una posición de ejecución no son automáticamente el estado ambiental $s$ de @def:ch8-mdp. Una actualización puede escribirse $z'=v(z,u)$, donde $u$ contiene observaciones y resultados externos; aun si $v$ es determinista dado $(z,u)$, un $u$ aleatorio induce un siguiente registro aleatorio.

  Para construir un MDP del sistema completo hay que definir estado, acciones, kernel y recompensa, y justificar que el estado conserva la información predictiva necesaria. La representación de una decisión de @thm:ch9-isomorfismo no establece una equivalencia general entre cualquier grafo de ejecución y cualquier MDP.
]

#thm-env("definition", name: [StateGraph], key: "def:app-stategraph")[
  Un `StateGraph` es una tupla $cal(G) = (V, E, cal(S), s_0, F)$ donde:
  - $V$ es el conjunto finito de nodos (funciones de procesamiento)
  - $E subset.eq V times V$ es el conjunto de aristas dirigidas
  - $cal(S)$ es el espacio de estados definido por `StateSchema`
  - $s_0 in cal(S)$ es el estado inicial
  - $F subset.eq V$ es el conjunto de nodos finales
]

#thm-env("definition", name: [Node], key: "def:app-node")[
  Un `Node` procesa un registro y produce una actualización. En una idealización determinista cerrada puede representarse como $v:cal(S)->cal(S)$; si utiliza observaciones o herramientas aleatorias, estas entradas deben explicitarse o integrarse en un kernel. De ello no se deduce que la transición ambiental tenga probabilidad uno.
]

#thm-env("definition", name: [StateSchema], key: "def:app-stateschema")[
  El `StateSchema` describe campos $k_i$ y tipos $tau_i$. El espacio $cal(S)$ es el conjunto de registros válidos que satisfacen ese esquema, no el conjunto de pares campo-tipo. Los tipos y sus espacios medibles, así como la semántica de los operadores de reducción, deben fijarse para una construcción probabilística.
]

#thm-env("definition", name: [ConditionalEdge], key: "def:app-conditionaledge")[
  Una `ConditionalEdge` $e_c: cal(S) -> V$ es una función que
  determina el siguiente nodo basándose en el estado actual:
  $ e_c (s) = v quad arrow.l.r.double quad pi(s) = a_v $
  Puede implementar una elección de control interno. Identificarla con una política ambiental requiere especificar qué acción ejecuta cada rama y qué información utiliza.
]

#thm-env("definition", name: [Checkpointer], key: "def:app-checkpointer")[
  Un `Checkpointer` $chi: cal(S) times NN -> cal(M)$ es un mecanismo de
  persistencia que almacena estados en memoria $cal(M)$, habilitando:
  - Continuación de ejecución
  - Human-in-the-loop (pausar/reanudar)
  - Rollback a estados anteriores
  - Branching de trayectorias
]

== Correspondencia LangGraph $arrow.l.r$ MDP
<app:lg-correspondencia>

La siguiente tabla muestra analogías de implementación con @ch:mdp-bellman. No define por sí sola un MDP: una construcción formal debe añadir la posición de ejecución al estado cuando sea necesaria, fijar las acciones y especificar las leyes de transición y recompensa.

#mi-tabla(
  caption: [Correspondencia LangGraph $arrow.l.r$ MDP],
  key: "tab:app-lg-mdp",
  table(
    columns: (28%, 28%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*LangGraph*], [*MDP*], [*Interpretación*]),
    hl(w: 0.6pt),
    [`StateSchema`], [Especificación de registros], [El espacio de estados consta de sus instancias válidas],
    [`state` (instancia)], [$s in cal(S)$], [Estado actual],
    [`Node`], [$a in cal(A)$], [Acción (procesamiento)],
    [`ConditionalEdge`], [$pi: cal(S) -> cal(A)$], [Política],
    [`add_edge`], [Enlace de control entre nodos], [No define por sí solo un kernel entre estados],
    [`add_conditional_edges`], [Selección de la siguiente operación], [Su interpretación como política requiere definir las acciones],
    [`Checkpointer`], [Historia $h_t$], [Trayectoria almacenada],
    [`START`], [$s_0$], [Estado inicial],
    [`END`], [$s_T$ (terminal)], [Estado terminal],
    [Función de nodo], [Actualización del registro], [La recompensa debe especificarse aparte],
    [`compile()`], [Cierre de $pi$], [Política ejecutable],
    [`stream()`], [Simulación], [Generación de trayectoria],
    hl(),
  ),
)

== Diagrama de Arquitectura Genérica
<app:lg-diagrama-generico>

El siguiente diagrama ilustra la arquitectura genérica de un agente
LangGraph con ciclo de decisión:

#let box-node(pos, label, name, w: 1.3, h: 0.6, nodefill: rgb(230,230,230)) = {
  draw.rect((pos.at(0) - w, pos.at(1) - h), (pos.at(0) + w, pos.at(1) + h), name: name, fill: nodefill, radius: 0.1)
  draw.content(pos, text(size: 8pt, label))
}

#let diamond-node(pos, label, name, w: 1.6, h: 1.0, nodefill: rgb(255,235,180)) = {
  let (x, y) = pos
  draw.line((x - w, y), (x, y + h), (x + w, y), (x, y - h), close: true, name: name, fill: nodefill)
  draw.content(pos, text(size: 7pt, label))
}

#mi-figura(
  caption: [Arquitectura genérica de agente LangGraph con ciclo ReAct.
    Las anotaciones en colores indican la correspondencia MDP.],
  key: "fig:app-lg-generic",
  canvas(length: 0.6cm, {
    import draw: line, circle, content
    circle((0, 6), radius: 0.8, name: "start", fill: green.lighten(70%))
    content((0, 6), text(size: 8pt, weight: "bold")[S])
    box-node((4, 6), [Observar], "observe", nodefill: rgb(240,240,240))
    box-node((8, 6), [Razonar], "reason", nodefill: rgb(240,240,240))
    diamond-node((8, 2), [¿Actuar?], "decide")
    box-node((4, 2), [Ejecutar], "act", w: 1.5, nodefill: rgb(240,240,240))
    box-node((8, -2), [Responder], "respond", nodefill: rgb(240,240,240))
    circle((8, -6), radius: 0.8, name: "end", fill: red.lighten(70%))
    content((8, -6), text(size: 8pt, weight: "bold")[E])

    line("start", "observe", mark: (end: ">"))
    line("start", "act", mark: (end: ">"))
    line("observe", "reason", mark: (end: ">"))
    line("reason", "decide", mark: (end: ">"))
    line("decide", "act", mark: (end: ">"))
    content((5.8, 3.2), text(size: 7pt)[sí])
    line("decide", "respond", mark: (end: ">"))
    content((9, 0), text(size: 7pt)[no])
    line("act", "observe", mark: (end: ">"))
    line("respond", "end", mark: (end: ">"))

    content((5.5, 7.3), text(size: 7pt, style: "italic", fill: waldcolor)[$s <- "env"$])
    content((9.5, 7.3), text(size: 7pt, style: "italic", fill: bridgecolor)[$Q(s,a)$])
    content((1.5, 3.6), text(size: 7pt, style: "italic", fill: mdpcolor)[$a = pi(s)$])
  }),
)

== Value Iteration como StateGraph
<app:lg-value-iteration>

Ilustramos la implementación de Value Iteration (Algoritmo de
Value Iteration del @ch:mdp-bellman) como un `StateGraph`.

#mi-figura(
  caption: [Value Iteration implementado como `StateGraph`. El nodo
    _Aplicar Bellman_ corresponde al operador de Bellman $cal(T)$ del
    Teorema de contracción del @ch:mdp-bellman.],
  key: "fig:app-lg-vi",
  canvas(length: 0.6cm, {
    import draw: line, circle, content
    circle((0, 4), radius: 0.9, name: "start", fill: green.lighten(70%))
    content((0, 4), text(size: 7pt, weight: "bold")[START])
    box-node((4.5, 4), align(center)[Inicializar \ $V_0(s) = 0$], "init", w: 1.8, h: 0.9, nodefill: blue.lighten(85%))
    box-node((9, 4), align(center)[Aplicar Bellman \ $V_(k+1) = cal(T) V_k$], "bellman", w: 2.0, h: 0.9, nodefill: blue.lighten(85%))
    diamond-node((9.3, 0), align(center)[$norm(V_(k+1) - V_k)$ \ $< epsilon.alt$?], "check", w: 2.4, h: 1.4, nodefill: rgb(255,225,180))
    box-node((4.5, 0), align(center)[Extraer $pi_V$ \ $pi_V(s) = argmax_a Q_V(s,a)$], "extract", w: 2.6, h: 0.95, nodefill: blue.lighten(85%))
    circle((0, 0), radius: 0.9, name: "end", fill: red.lighten(70%))
    content((0, 0), text(size: 7pt, weight: "bold")[END])

    line("start", "init", mark: (end: ">"))
    line("init", "bellman", mark: (end: ">"))
    line("bellman", "check", mark: (end: ">"))
    line((9.3, -1.4), (9.3, -2.7), (12.2, -2.7), (12.2, 4), "bellman.east", mark: (end: ">"))
    content((12.6, 0.5), text(size: 7pt)[no])
    line("check", "extract", mark: (end: ">"))
    content((7.3, 1.3), text(size: 7pt)[sí])
    line("extract", "end", mark: (end: ">"))
  }),
)

=== Descripción del StateSchema

El `StateSchema` para Value Iteration contiene:
- `V`: diccionario ${s |-> V(s)}$, función de valor actual
- `V_prev`: función de valor de la iteración anterior
- `iteration`: contador de iteraciones $k$
- `delta`: $norm(V_(k+1) - V_k)_infinity$, criterio de convergencia
- `policy`: diccionario ${s |-> a}$, política extraída
- `converged`: booleano indicando terminación

=== Descripción de Nodos

- *Inicializar:* Establece $V_0(s) = 0$ para todo $s in cal(S)$, $k =
  0$, `converged = False`.

- *Aplicar Bellman:* Computa
  $ V_(k+1)(s) = max_(a in cal(A)) [r(s,a) + gamma sum_(s')
    P(s' mid(|) s, a) V_k (s')] $
  Actualiza `delta` y `iteration`.

- *Extraer una política aproximada:* Para el vector almacenado $V$, computa $Q_V(s,a)=r(s,a)+gamma sum_(s')P(s'|s,a)V(s')$ y una política greedy $pi_V$. Con residuo $e=norm(cal(T)V-V)_infinity$, el error de valor no supera $e/(1-gamma)$ y la pérdida de la política está acotada por $2gamma e/(1-gamma)^2$. Una tolerancia positiva no implica optimalidad exacta. Si `delta` se calculó con el iterado anterior, se vuelve a calcular el residuo del vector devuelto para aplicar estas cotas.

=== Arista Condicional

La `ConditionalEdge` después del nodo Bellman implementa:

```
def should_continue(state: VIState) -> str:
    if state["delta"] < epsilon:
        return "extract_policy"
    else:
        return "apply_bellman"
```

== Patrones de Diseño para Agentes con Garantías
<app:lg-patrones>

=== Patrón: Estimador DR como Nodo

Para integrar el estimador Doubly Robust (@ch:ope-fundamentos) en un
agente evaluador:

+ El `StateSchema` incluye campos para datos logged $cal(D)$, modelo
  de propensity $hat(mu)$, modelo de outcome $hat(Q)$.

+ Un nodo `fit_nuisance` ajusta $hat(mu)$ y $hat(Q)$ con cross-fitting
  (ver Apéndice~#ref(<app:dem-crossfitting>, supplement: none)).

+ Un nodo `compute_dr` calcula
  $ hat(J)=1/n sum_(i=1)^n hat(D)_i, quad hat(phi)_i=hat(D)_i-hat(J). $
  El pseudoresultado $hat(D)_i$ estima valor; la contribución centrada $hat(phi)_i$ se utiliza para estimar su varianza. Debe elegirse la fórmula de una decisión o longitudinal que corresponda al experimento.

+ Un nodo `compute_ci` construye el IC de nivel $(1-alpha)$ usando la
  varianza estimada de la IF.

=== Patrón: A/B Testing con Control de FDR

Para evaluar múltiples políticas candidatas con BH, deben fijarse las candidatas antes de la evaluación o justificar la selección, obtener p-valores válidos y verificar independencia suficiente o una condición admitida como PRDS. Compartir una política basal no establece por sí solo esas condiciones. Bajo esos requisitos:

+ Nodo `generate_hypotheses`: Define $H_(0,j): V^(pi_j) lt.eq
  V^(pi_0)$
+ Nodo `compute_pvalues`: Calcula $p_j$ para cada $j = 1, ..., m$
+ Nodo `apply_bh`: Aplica Benjamini-Hochberg al nivel $alpha$
+ `ConditionalEdge`: Selecciona políticas con $p_j lt.eq hat(t)_"BH"$

=== Patrón: Human-in-the-Loop con Checkpointer

El `Checkpointer` habilita intervención humana:

+ Nodo `propose_action` genera acción candidata
+ `interrupt_before=["execute"]` pausa antes de ejecutar
+ Humano revisa y aprueba/modifica en interfaz
+ Nodo `execute` procede con acción (modificada o no)
+ El estado $h_t$ incluye flag `human_approved`

== Una organización posible del código
<app:lg-codigo>

Los laboratorios del @ch:casos permiten seguir los cálculos estadísticos
en programas reproducibles. Para una implementación por grafos, conviene
mantener separados los estados, las funciones de nodo y los procedimientos
de estimación. La estructura siguiente ilustra esa separación como una
propuesta de organización:

```
statistical-agents-langgraph/
|-- chapter01_exponential_families/
|-- chapter02_sufficiency/
|-- chapter03_estimation/
|-- ...
|-- chapter12_synthesis/
|-- common/
|   |-- state_schemas.py
|   |-- influence_functions.py
|   `-- dr_estimators.py
`-- notebooks/
    `-- interactive_examples.ipynb
```

En esa organización, cada directorio puede reunir:
- `agent.py`: Implementación del `StateGraph`
- `nodes.py`: Funciones de nodo
- `tests.py`: Tests unitarios
- `README.md`: Documentación y correspondencias teóricas

== Notas sobre Versiones y Compatibilidad
<app:lg-versiones>

Los ejemplos de esta monografía fueron desarrollados con:
- `langgraph` $gt.eq$ 0.2.0
- `langchain-core` $gt.eq$ 0.3.0
- Python $gt.eq$ 3.10

Al reproducir los fragmentos conviene registrar las versiones efectivamente utilizadas y comprobar su compatibilidad. Esa información acompaña al código y a sus resultados, como se describe en la Sección~#ref(<app:lg-codigo>, supplement: none).
