#import "../plantilla.typ": *

= Problemas abiertos
<ch:problemas>
#chapter-alias("ch:sintesis")
#chapter-alias("ch:conclusiones")

El despliegue deja una pregunta abierta cada vez que cambia una condición
sobre la que descansaba el análisis. Una población distinta puede alterar
el valor agregado; una historia incompleta puede ocultar información usada
para asignar acciones; un modelo de lenguaje puede producir decisiones
sin permitir calcular sus probabilidades. En esas situaciones, antes de
escoger otro estimador conviene precisar qué parte del argumento sigue
siendo válida.

Este capítulo retoma el recorrido para formular esas preguntas. La primera
parte del libro permitió comparar reglas y planificar dentro de modelos
especificados. La evaluación y la inferencia añadieron las condiciones para
aprender de datos. Los casos y el despliegue mostraron cómo una implementación
puede conservar o cambiar el objeto del análisis. Ahora interesa delimitar
lo que falta cuando la información, la política o el entorno exceden esos
supuestos.

Las preguntas se presentan primero a través de sus dificultades de
identificación y estimación. Después se traducen en problemas de trabajo y
en un diseño de agente cuyas garantías deben justificarse por separado.
El SSCH sirve de referencia para interpretar esas dificultades; conserva
su carácter de escenario sintético.

== Qué conclusiones conservamos
<sec:ch13-resultados>

La representación del @ch:isomorfismo conserva el riesgo al escribir una
decisión de Wald como una política en una familia de MDP de un paso. Bayes,
minimax y admisibilidad comparan entonces las mismas reglas con el mismo
criterio. La extensión bayesiana de observación y parada requiere además
un modelo de datos, un prior y un horizonte definidos.

La suficiencia del @ch:herramientas precisa qué información de una muestra
puede retenerse para un parámetro. Al construir un estado controlado, la
pregunta cambia: el resumen debe permitir predecir lo que sucederá bajo
las acciones consideradas. El @ch:fallos y el @ch:verificacion muestran
por qué conviene justificar esa propiedad en el proceso que se utiliza.

Las funciones de influencia y la ortogonalidad permiten estudiar cómo los
errores de los modelos auxiliares afectan a un estimador. En una construcción
DR concreta, la doble robustez identifica combinaciones de modelos para
las que se conserva el centrado poblacional. La precisión asintótica exige
también tasas, momentos y una estimación de varianza adecuados.

La evaluación _off-policy_ del @ch:ope hace explícita la información que
falta cuando una política propone acciones poco representadas en los datos.
Los pesos acumulados pueden tener una varianza elevada en horizontes largos.
Los modelos, las restricciones de política y los cambios de estimando deben
juzgarse por las hipótesis que incorporan y por la conclusión que permiten.

El @ch:inferencia distingue las rutas para cuantificar incertidumbre: las
contribuciones de episodios independientes, la dependencia dentro de una
trayectoria y la aproximación de Bellman mediante bases. El método SAVE
trata la evaluación de políticas aprendidas con una organización secuencial
específica. Estas rutas ofrecen resultados que deben leerse con sus propios
procedimientos; su relación se documenta antes de combinarlas.

== Las fronteras de la evaluación
<sec:ch12-teoria>
#section-alias("sec:ch12-sintesis-marco")

=== Evaluar cuando hay causas comunes no observadas
<sec:ch12-confound>

Una persona que decide puede utilizar información que no queda registrada. Si esa información también se relaciona con el resultado, comparar las acciones a partir de los registros observados deja una causa común sin ajustar. La identificación de $Value^pi$ debe entonces estudiarse bajo un modelo que reconozca esa información ausente.

#thm-env("definition", name: [Confounding No Observado], key: "def:ch12-confound")[
  En un modelo causal de una decisión, hay confusión respecto del ajuste por $S$ cuando falla el intercambio $R(a) independent A | S$ para alguna acción $a$. Una causa común no observada $U$, anterior a la acción, puede producir ese fallo. Las dependencias $P(A|S,U) != P(A|S)$ y $P(R|S,A,U) != P(R|S,A)$ no establecen por sí solas dirección causal ni precedencia temporal. En una evaluación longitudinal, el intercambio se formula para resultados futuros y la historia previa a cada decisión.
]

La dificultad aparece cuando el ajuste por las variables registradas deja sin controlar una causa común de las acciones y los resultados.

// nombre heredado: el enunciado ya no se atribuye a Shi et al. (Fase 1,
// hallazgo H1). Verificado sobre jrsssb_84_3_765.pdf: el artículo —2022,
// JRSS-B 84(3):765–793— no trata confounding no observado (0 apariciones de
// «confound»), por lo que la atribución anterior era insostenible.
#thm-env("note", name: [Sesgo del estimador DR bajo confounding no observado], key: "thm:ch12-shi-confound")[
  Bajo confounding no observado el estimador DR puede conservar un sesgo que la
  reponderación por importancia no elimina: los pesos corrigen la diferencia
  entre política objetivo y de comportamiento, pero no la dependencia común
  entre acción y recompensa mediada por la variable no observada $U$. El sesgo depende del mecanismo completo; puede incluso cancelarse en casos particulares. La ausencia de esta causa común no descarta otras fuentes de confusión.

  Para el tratamiento estándar del sesgo por confounding en estimadores
  ponderados, véase #cite(<hernan2020causal>, form: "prose").
]

Para continuar, hace falta añadir información o formular una conclusión menos exigente. Las siguientes estrategias introducen supuestos distintos y deben justificarse en el diseño correspondiente.

#thm-env("note", name: [Estrategias de Mitigación], key: "prop:ch12-mitigation")[
  Estrategias para manejar confounding no observado:
  + *Instrumental Variables:* Especificar relevancia, exogeneidad y exclusión del instrumento, además de las condiciones adicionales del parámetro causal que se pretende identificar.
  + *Sensitivity Analysis:* Cuantificar el sesgo bajo diferentes
    escenarios de $U$
  + *Bounds:* Construir límites para $Value^pi$ sin asumir no
    confoundamiento
  + *Proxy Variables:* Especificar un modelo de medición y las condiciones de puente y completitud de la ruta elegida; correlación con $U$ no basta para identificación.
]

La adherencia no registrada ofrece una manera de plantear esa dificultad en el SSCH.

#thm-env("example", name: [SSCH con Confounding], key: "ex:ssch-confound", es-sintetico: true)[
  En el SSCH, la adherencia del paciente a las recomendaciones ($U$) no
  es completamente observada. Pacientes más adherentes tienden a
  recibir más intervenciones y también tienen mejores resultados,
  creando confounding. El estimador DR puede estar sesgado si no se controla por $U$; la dirección del sesgo requiere especificar el mecanismo generador.
]

=== Decidir a partir de observaciones parciales
<sec:ch12-pomdp>

La información puede ser parcial incluso antes de decidir qué registrar. En un POMDP, el estado $S_t$ se relaciona con una observación $O_t$ que recibe el agente. Para evaluar una política interesa reconstruir qué puede aprenderse de esas observaciones y qué parte del pasado necesita conservarse.

#thm-env("definition", name: [POMDP], key: "def:ch12-pomdp")[
  Un POMDP se define por la tupla $(StateSpace, ActionSpace, ObsSpace,
  T, O, R, gamma)$ donde:
  - $O_t in ObsSpace$ es la observación en el paso $t$
  - $O(o_t|s_t)$ es la probabilidad de observar $o_t$ dado el estado
    $s_t$
  - Con ley inicial especificada, el agente mantiene $b_t(s)=P(S_t=s|H_t)$, donde $H_t$ incluye observaciones, acciones y recompensas disponibles antes de decidir. Si las recompensas se incorporan a $O_t$, debe declararse esa convención.
]

El historial observado pasa a ser parte de la información de la política. La representación del valor debe respetar esa dependencia y los requisitos de identificación del @ch:ope.

#thm-env("theorem", name: [Identificación en POMDPs], key: "thm:ch12-pomdp-identification")[
Sea $H_t$ la historia observada antes de $A_t$, incluyendo observaciones, acciones y recompensas pasadas. Suponga horizonte finito, la misma ley inicial y los mismos kernels del entorno bajo ambas políticas, que el mecanismo de asignación observado es $b_t(a|H_t)$ y que la asignación no usa información latente adicional relacionada con resultados futuros. Suponga también soporte objetivo cubierto e integrabilidad. Entonces, con
$ W_t=product_(u=0)^t pi_u(A_u|H_u)/b_u(A_u|H_u), $
el cambio de medida sobre historias da
$ J(pi)=EE_b[sum_(t=0)^(H-1)gamma^t W_t R_t]. $
En efecto, $W_t$ es la derivada de la ley objetivo respecto de la observada hasta la recompensa $R_t$; integrar cada término demuestra la igualdad. Una razón solo del tiempo $t$ no corrige la distribución de historias inducida por las acciones anteriores. Si quien asigna acciones observa información latente no registrada, estas hipótesis pueden fallar y la fórmula no identifica en general el valor causal.

]

El estado de creencia ofrece una formulación del problema cuando el modelo de observación está especificado. Para trabajar con datos, las siguientes estrategias abordan partes distintas de esa reconstrucción.

#thm-env("note", name: [Estrategias para OPE en POMDPs], key: "prop:ch12-pomdp-strategies")[
  Estrategias para manejar observabilidad parcial:
  + *State Estimation:* Usar filtros de partículas o filtros de Kalman
    para estimar la distribución de $S_t$ desde la historia completa $H_t$, incluidas las acciones que modifican la predicción
  + *History-Based Policies:* Modelar $pi(a|h_t)$ donde $h_t = (o_0,
    a_0, ..., o_t)$
  + *Recurrent Models:* Usar RNNs o transformers para procesar el
    historial
  + *Belief State MDP:* Convertir el POMDP en un MDP sobre el espacio
    de creencias
]

El mismo ejemplo de seguimiento cambia cuando las mediciones solo revelan una parte del estado que interesa.

#thm-env("example", name: [SSCH como POMDP], key: "ex:ssch-pomdp", es-sintetico: true)[
  En el SSCH, el estado de salud completo del paciente (incluyendo
  factores no medidos como estrés, calidad de sueño) no es
  completamente observable. El médico solo observa mediciones clínicas
  parciales. Esto crea un POMDP donde las políticas deben basarse en
  observaciones incompletas.
]

=== Evaluación de agentes de lenguaje y modelos auxiliares
<sec:ch12-llm>

En un agente de lenguaje, la acción puede ser una secuencia de palabras y su probabilidad depende del contexto utilizado para generarla. La evaluación requiere conocer o modelar ese mecanismo y precisar qué significa comparar dos acciones textuales. Los modelos auxiliares siguientes hacen explícitas esas preguntas.

#thm-env("definition", name: [LLM-Agent], key: "def:ch12-llm")[
  Un LLM-Agent es un sistema donde:
  - *Observación:* $o_t in cal(O)$ (texto, multimodal)
  - *Acción:* $a_t in cal(A)_L = union.big_(k=1)^L Sigma^k$ (secuencia
    de hasta $L$ tokens)
  - *Política:* $pi(a|o) = product_(j=1)^(|a|) p_"LLM" ("token"_j | o,
    "tokens"_(<j))$
]

==== Probabilidad de una acción textual

#thm-env("definition", name: [Propensity Score para LLM-Actions], key: "def:ch12-propensity")[
  La probabilidad de una acción textual $a = (t_1, ..., t_K)$ bajo
  política $pi_b$ es:
  $ pi_b (a|o) = product_(j=1)^K p_(pi_b) (t_j | o, t_1, ..., t_(j-1)) $
  El log-propensity es:
  $ log pi_b (a|o) = sum_(j=1)^K log p_(pi_b) (t_j | o, t_(<j)) $
]

El producto representa la probabilidad de la acción completa si incluye el token de terminación o una regla de longitud fija. Debe usar las probabilidades del muestreador efectivo, después de temperatura, filtros y restricciones; las probabilidades del modelo base pueden ser distintas. Con esas condiciones, puede calcularse en escala logarítmica.

#thm-env("proposition", name: [Estimación de Propensity vía Log-Probs], key: "prop:ch12-logprobs")[
  Si el LLM proporciona log-probabilidades por token (e.g., API de
  OpenAI con `logprobs`), entonces:
  $ hat(pi)_b (a|o) = exp(sum_(j=1)^(|a|) "logprob"(t_j)) $
  *Limitación:* Requiere acceso a log-probs del modelo que generó los
  datos.
]

==== Qué información necesita la evaluación

#mi-tabla(
  caption: [Desafíos de OPE en LLM-Agents],
  key: "tab:ch12-desafios",
  table(
    columns: (24%, 30%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Desafío*], [*Implicación*], [*Mitigación Propuesta*]),
    hl(w: 0.6pt),
    [$|ActionSpace| = sum_(k=1)^L |Sigma|^k$], [Los pesos pueden concentrarse], [Discretizar por clusters o templates],
    [$pi_b$ desconocida], [No hay log-probs], [Entrenar modelo surrogate de $pi_b$],
    [No estacionariedad], [Modelo actualizado], [Usar solo datos recientes, detectar drift],
    [Evaluación humana], [$r$ costoso, ruidoso], [Usar LLM-as-judge calibrado],
    [Confounding latente], [Prompt history afecta], [Incluir historia en estado, o bounds],
    hl(),
  ),
)

==== Qué conserva la discretización de acciones

#thm-env("definition", name: [Discretización por Templates], key: "def:ch12-templates")[
  Definir $K$ templates de acción ${T_1, ..., T_K}$ y mapear cada
  acción $a$ al template más cercano:
  $ tilde(a) = argmin_(k in {1,...,K}) d(a, T_k) $
  donde $d$ es una disimilitud explícita, por ejemplo uno menos la similitud coseno, con desempate fijo. BLEU es una puntuación de coincidencia y no debe minimizarse directamente ni interpretarse automáticamente como distancia semántica.

  El espacio agrupado es $tilde(ActionSpace) = {T_1, ..., T_K}$. Aplicar OPE requiere especificar cómo se selecciona y ejecuta una acción dentro de cada grupo y justificar identificación para esa intervención.
]

La representación escogida determina qué diferencias entre acciones se conservan. Su evaluación exige considerar también el error que puede introducir esa agrupación.

#thm-env("proposition", name: [Sesgo de Discretización], key: "prop:ch12-sesgo-disc")[
Una cota concreta requiere fijar el criterio. En una decisión, sea $g(a)$ el template ejecutable y suponga $sup_(s,a)|m(s,a)-m(s,g(a))|<=epsilon$. Si la política agrupada es la imagen de la política original mediante $g$, integrar la diferencia de recompensas da $|J(pi)-J(pi_g)|<=epsilon$. En horizonte infinito descontado, una condición análoga sobre $Q^pi$, uniforme en estados y acciones, permite mediante la identidad de diferencia de rendimiento una cota $epsilon/(1-gamma)$. La semejanza semántica por sí sola no demuestra ninguna de estas condiciones.

]

==== Condiciones de una evaluación DR

#thm-env("note", name: [DR para LLM-Agents: Condiciones], key: "thm:ch12-dr-llm")[
La positividad uniforme de este resultado incluye los denominadores ajustados: se mantienen alejados de cero sobre el soporte objetivo, o se sustituye esa condición por un control explícito de cocientes y momentos ponderados.
Para una evaluación de una decisión con templates finitos se puede aplicar el resultado DR del @ch:ope si la agrupación define una intervención identificada, la política objetivo es fija, las unidades son iid, las recompensas y los ajustes están acotados, hay positividad uniforme y se usa cross-fitting por unidad independiente. Se requiere consistencia $L^2$ de ambos auxiliares y producto de errores $o_P(n^(-1/2))$; dos tasas $o_P(n^(-1/4))$ son suficientes. Con varianza límite positiva, esas condiciones permiten el CLT y el intervalo asociado. Para acciones secuenciales hacen falta el estimador longitudinal y las condiciones de su propio teorema. Los tres requisitos de overlap, aproximación de Q y estimación de propensiones, aislados, no prueban esa extensión.

]

==== Dónde debe revisarse la garantía

El @thm:ch11-shi (presentado en @sec:ch11-shi) y su IC asociado *no* se
transfieren automáticamente a LLM-agents en los siguientes casos:

+ Cuando la política objetivo no es evaluable como densidad
  ($pi(a|s)$ no computable, típico de LLMs comerciales sin acceso a
  log-probs): no se dispone directamente del ratio requerido por esa ruta de evaluación. El soporte puede conocerse por el mecanismo de generación y debe justificarse mediante un argumento separado.
+ Cuando la agrupación de acciones modifica el estimando sin una cota de aproximación — la cobertura nominal del IC no está
  garantizada.
+ Cuando el confounding por historial de prompt no está incluido en el
  estado — la identificación (MA/CMIA) falla.

En estos regímenes el agente debe reportar la ausencia de garantía
explícitamente, no un IC con cobertura asumida.

==== Organizar una evaluación de acciones textuales

Primero se define la acción completa, incluyendo el mecanismo de terminación y el contexto disponible. Sus probabilidades deben corresponder al mecanismo efectivo de muestreo, con sus filtros y transformaciones. Un modelo surrogate introduce error de estimación que debe entrar en el análisis.

Agrupar acciones exige definir la intervención dentro de cada grupo; la distancia semántica no basta para preservar recompensas ni transiciones. Los pesos se calculan por unidad evaluada, y el diagnóstico habitual es $"ESS"=(sum_(i=1)^n w_i)^2/sum_(i=1)^n w_i^2$ cuando el denominador es positivo. No hay un umbral universal de ESS que certifique soporte poblacional, identificación o cobertura.

Si se truncan los pesos, se cambia el estimador y aparece un posible sesgo. El umbral debe acompañarse de un análisis de ese sesgo y de la inferencia resultante. La evaluación debe declarar el estimando, la unidad de partición, la agrupación de acciones, los pesos y las hipótesis del intervalo utilizado.

=== Un diseño de agente y las garantías que habría que justificar
<sec:ch12-e2e>

*Algoritmo: Decisión Basada en IC*
+ *Observar:* Recibir $o_t$
+ *Actualizar estado:* $T_(t+1) = "update"(T_t, o_t)$
+ *Estimar valor:* $hat(Value)^pi = f(T_(t+1))$
+ *Construir IC:* $"IC" = [hat(Value)^pi plus.minus z_0.975 dot
  hat(sigma)\/sqrt(n)]$
+ *Decidir:*
  $ "Decisión" = cases(
    "EXPLORAR" & "si " "ancho"("IC") > epsilon.alt,
    "ACTUAR" & "si " "ancho"("IC") lt.eq epsilon.alt " y " L_"IC" gt.eq Value_"min",
    "CONSULTAR" & "si " "ancho"("IC") lt.eq epsilon.alt " y " L_"IC" < Value_"min",
  ) $

#thm-env("note", name: [Objetivos de garantía del diseño], key: "thm:ch12-garantias")[
  El diseño plantea los siguientes objetivos, que requieren resultados e hipótesis específicos antes de atribuirlos a una implementación:
  + *Cobertura:* IC con cobertura asintótica $gt.eq 1-alpha$
  + *Consistencia:* Decisiones convergen a óptimas
  + *Eficiencia:* Estimadores alcanzan cota semiparamétrica
  + *Trazabilidad:* Cada componente justificado teóricamente
]

=== Una agenda a partir de las condiciones que faltan
<sec:ch12-fronteras>

Las dificultades anteriores permiten distinguir tareas que suelen confundirse: identificar el valor, estimarlo con precisión y sostener una decisión posterior. La tabla relaciona cada pregunta con el trabajo adicional que exige dentro del alcance de esta monografía.

#mi-tabla(
  caption: [Agenda de Investigación: Problemas Abiertos],
  key: "tab:ch12-agenda",
  table(
    columns: (18%, 32%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Área*], [*Problema Central*], [*Dirección de Investigación*]),
    hl(w: 0.6pt),
    [Confounding], [Identificación sin no-confoundamiento], [Desarrollar bounds no paramétricos para $Value^pi$ que no asuman no confoundamiento, extendiendo el trabajo de #cite(<shi2024off>, form: "prose") sobre MDP confundidos],
    [POMDPs], [Inferencia con observabilidad parcial], [Diseñar estimadores DR que operen directamente sobre el espacio de creencias, sin necesidad de estimar el estado latente],
    [LLM-Agents], [Evaluación de políticas estocásticas complejas], [Desarrollar teoría de OPE para acciones textuales de espacio discreto combinatorio y dependencia de contexto],
    [Teoría], [Condiciones de mixing en MDPs continuos], [Caracterizar tasas de mixing para MDPs con estados continuos y políticas no estacionarias],
    [Aplicación], [Validación en dominios reales], [Diseñar protocolos de validación que combinen garantías teóricas con evaluación empírica robusta],
    hl(),
  ),
)

#thm-env("note", name: [Problemas de Alto Impacto], key: "prop:ch12-high-impact")[
  Problemas con mayor potencial de impacto:
  + *OPE con Confounding:* Métodos que relajen el supuesto de no
    confoundamiento sin perder eficiencia
  + *LLM-Agent Evaluation:* Frameworks estadísticos para evaluar
    agentes basados en modelos de lenguaje
  + *Sample-Efficient OPE:* Métodos que requieran menos trayectorias
    sin sacrificar precisión
  + *Causal RL:* Integración de inferencia causal con aprendizaje por
    refuerzo
]

#mi-tabla(
  caption: [Alcance de las preguntas en esta monografía. «Parcial» indica resultados para casos restringidos; «abierto» indica que el problema formulado aquí queda sin resolver en el libro.],
  key: "tab:ch12-estados",
  table(
    columns: (10%, 30%, 13%, 1fr),
    align: (left, left, left, left),
    hl(),
    table.header([*ID*], [*Problema*], [*Estado*], [*Señal en la literatura*]),
    hl(w: 0.6pt),
    [P12-1], [OPE con confounding no observado], [Parcial], [Intervalos con MDP confundido @shi2024off; cotas _sharp_ en MDP robustos @bennett2024efficient],
    [P12-2], [Mitigación sin no-confoundamiento], [Abierto], [Estrategias (IV, sensibilidad, cotas, _proxies_) sin teorema propio],
    [P12-3], [OPE en POMDP], [Parcial], [Caso episódico vía _proxies_ @miao2022off; falta el caso de horizonte largo en el espacio de creencias],
    [P12-4], [Evaluación de LLM-agents], [Abierto], [Sin protocolo OPE para acciones textuales],
    [P12-5], [_Mixing_ en MDP continuos], [Abierto], [Los métodos recientes suponen _mixing_ @mehrabi2024off],
    [P12-6], [Validación en dominios reales], [Abierto], [Infraestructura de laboratorios; sin protocolo cerrado],
    [P12-7], [OPE eficiente en muestra], [Parcial], [Eficiencia semiparamétrica y maldición del horizonte @kallus2022efficiently],
    [P12-8], [Causal RL], [Abierto], [Puentes parciales; sin integración formal en el libro],
    [P12-9], [Agente _end-to-end_ con garantías], [Abierto], [Marco del capítulo; no es resultado cerrado],
    hl(),
  ),
)

=== Qué significaría sostener esas garantías
<sec:ch12-reflexion>

La pregunta por la confiabilidad vuelve así a una relación entre el diseño y sus condiciones de uso. Los criterios siguientes describen qué se espera documentar y revisar en un agente; cada propiedad estadística conserva el alcance del procedimiento que la respalda.

#thm-env("definition", name: [Agente Confiable], key: "def:ch12-reliable")[
  Un agente es _confiable_ si:
  + *Validación Estadística:* Sus decisiones están respaldadas por
    garantías estadísticas verificables
  + *Transparencia:* Cada componente puede ser trazado hasta su
    justificación teórica
  + *Robustez:* Declara las variaciones del modelo que tolera y los límites de esa tolerancia
  + *Interpretabilidad:* Sus decisiones pueden ser explicadas en
    términos del dominio
]

Esos criterios pueden relacionarse con resultados concretos de la inferencia, siempre que el modelo y el procedimiento cumplan sus hipótesis.

#thm-env("note", name: [Resultados que pueden respaldar el diseño], key: "prop:ch12-framework-reliability")[
  Bajo las hipótesis correspondientes, el diseño puede apoyarse en:
  + *Garantías de Cobertura:* Los IC del @ch:inferencia tienen
    cobertura asintótica verificable
  + *Trazabilidad Completa:* Cada componente puede ser rastreado hasta
    su origen teórico
  + *Robustez DR:* La identidad del @ch:ope precisa las combinaciones de modelos auxiliares para las que se conserva el centrado
  + *Eficiencia:* La función de influencia del @ch:semiparametrica permite comparar la varianza con la cota del modelo
]

Estas exigencias pueden leerse como condiciones por justificar en una implementación del SSCH.

#thm-env("example", name: [Agente SSCH Confiable], key: "ex:ssch-reliable", es-sintetico: true)[
  Para estudiar la confiabilidad de una implementación SSCH, habría que justificar que:
  - Cada recomendación viene con un IC que cuantifica la incertidumbre
  - La política puede ser explicada en términos de los principios de
    Bellman
  - El estimador DR es robusto ante errores en el modelo de
    transiciones
  - La eficiencia semiparamétrica garantiza que no se desperdicia
    información
]

== Del problema abierto al diseño de una evaluación
<sec:ch12-langgraph>

=== Conservar la información entre componentes
<sec:ch12-integracion>

Una vez fijados el objetivo y el experimento, la arquitectura debe conservar la información que exige el procedimiento. La separación de responsabilidades permite revisar dónde se estiman los modelos auxiliares, cómo se calcula el valor y qué evidencia utiliza la decisión.

#thm-env("definition", name: [Arquitectura del Agente], key: "def:ch12-architecture")[
  Un agente basado en el marco Wald-MDP tiene los siguientes
  componentes:
  + *Módulo de Estimación:* Implementa $hat(Qfunc)$ y $hat(pi)_b$
    usando métodos semiparamétricos
  + *Módulo de Evaluación:* Calcula $hat(Value)^"DR"$ y sus IC mediante una ruta inferencial justificada para ese estimador y ese muestreo
  + *Módulo de Inferencia:* Proporciona garantías estadísticas y tests
    de hipótesis
  + *Módulo de Decisión:* Usa la información del módulo de evaluación
    para tomar decisiones
]

El objetivo y la incertidumbre deben viajar con la estimación a lo largo de los módulos. De ese modo, la decisión puede recuperar qué se calculó y bajo qué condiciones.

#thm-env("note", name: [Flujo de Información], key: "prop:ch12-flow")[
  El flujo de información entre componentes:
  + Datos observacionales $arrow.r$ Módulo de Estimación $arrow.r$
    $hat(Qfunc), hat(pi)_b$
  + $hat(Qfunc), hat(pi)_b$ $arrow.r$ Módulo de Evaluación
    $arrow.r$ $hat(Value)^"DR", "IC"$
  + $hat(Value)^"DR", "IC"$ $arrow.r$ Módulo de Inferencia
    $arrow.r$ Tests; el cálculo prospectivo de poder recibe además alternativa, nivel, diseño y varianza especificados
  + $hat(Value)^"DR", "IC"$, tests $arrow.r$ Módulo de Decisión
    $arrow.r$ Acción
]

El flujo anterior permite describir cómo una comparación del SSCH llegaría hasta la decisión.

#thm-env("example", name: [Integración en SSCH], key: "ex:ssch-integration", es-sintetico: true)[
  En el SSCH, la integración funciona así:
  - El módulo de estimación ajusta modelos de transición y recompensa
    usando datos históricos
  - El módulo de evaluación calcula el valor de cada política
    candidata con ICs
  - El módulo de inferencia verifica si las diferencias son
    estadísticamente significativas
  - El módulo de decisión selecciona la política con mayor valor,
    respetando los ICs
]

=== Responder a una limitación del análisis
<sec:ch12-limitaciones>

Las limitaciones reaparecen en el flujo de datos: una acción poco observada dificulta el cambio de medida, una trayectoria dependiente exige tratar su varianza y un modelo auxiliar introduce error de aproximación. La respuesta debe referirse a la dificultad que se ha encontrado.

#thm-env("note", name: [Limitaciones del Marco], key: "prop:ch12-limitations")[
  Limitaciones principales:
  + *Overlap:* Una condición suficiente de control de razones es $pi_b (a|s) gt.eq eta dot pi_e (a|s)$ con $eta>0$; no es necesaria para toda variante DR
  + *Mixing:* El Teorema de Shi et al. requiere condiciones de mixing
  + *Nuisance Estimation:* La calidad de $hat(Qfunc)$ y $hat(pi)_b$
    afecta la performance
  + *Horizonte Infinito:* La estimación de valor es más difícil en
    horizontes largos
]

Una respuesta posible es modificar el procedimiento o acotar el objetivo. Cada cambio requiere registrar la nueva pregunta y el error que se acepta.

#thm-env("definition", name: [Estrategias de Mitigación], key: "def:ch12-mitigation-strategies")[
  Estrategias para manejar limitaciones:
  + *Clipping de Ratios:* Truncar $rho = pi_e \/ pi_b$ para evitar
    varianza excesiva
  + *Importance Sampling Truncado:* Descartar trayectorias con ratios
    extremos
  + *Modelos Nuisance Robustos:* Usar métodos robustos para estimar
    $Qfunc$ y $pi_b$
  + *Horizonte Finito:* Elegir $H$ mediante una cota de cola, por ejemplo $R_max gamma^H/(1-gamma)$ para recompensas acotadas, o declarar expresamente un nuevo estimando finito. Dependencia débil no controla por sí sola esa cola.
]

En una evaluación longitudinal del SSCH, esos cambios deben relacionarse con la información disponible en cada visita.

#thm-env("example", name: [Limitaciones en SSCH], key: "ex:ssch-limitations", es-sintetico: true)[
  Considere un tercer escenario hipotético, distinto del muestreo tabular por filas y del caso de dos visitas: episodios independientes de doce decisiones mensuales, ley inicial fijada y probabilidades de registro conocidas, con observaciones y recompensas por visita. Su objetivo es el retorno descontado de esas doce decisiones. Antes de especificar kernels y políticas concretos, solo pueden plantearse dificultades posibles:
  - *Overlap:* Algunas políticas agresivas tienen baja probabilidad
    bajo $pi_b$
  - *Mixing:* Las transiciones de salud tienen dependencia temporal de
    largo plazo
  - *Nuisance:* Los modelos de transición son aproximados
  - *Alternativas por evaluar:* El clipping introduce sesgo y exige estudiar su magnitud. El horizonte de doce meses define aquí el objetivo, no una aproximación automáticamente válida a un retorno infinito. Estas opciones no constituyen una solución demostrada para los otros SSCH del libro.
]

#[
#set heading(numbering: none, outlined: false)
=== El recorrido del SSCH leído como una evaluación
]

#thm-env("example", name: [SSCH: preguntas que acompañan una decisión], key: "ex:ssch-cap12", es-sintetico: true)[
  Al volver al SSCH, conviene seguir la pregunta de cada experimento.
  El caso tabular y el subcaso de dos visitas tienen diseños distintos,
  descritos en el @ch:casos. Sus cifras se interpretan dentro de esos diseños.

  #table(
    columns: (24%, 38%, 1fr),
    table.header([*Recorrido*], [*Pregunta*], [*Límite de la conclusión*]),
    [@ch:wald], [¿Qué costo asignamos a cada error?], [La regla depende de la pérdida y la clase de decisiones],
    [@ch:mdp-bellman], [¿Qué política optimiza la dinámica conocida?], [La planificación se refiere al modelo especificado],
    [@ch:herramientas], [¿Qué permiten estimar los datos?], [La propiedad corresponde al estimador y al muestreo],
    [@ch:isomorfismo], [¿Se conserva el riesgo al representar la regla?], [La identidad se demuestra para la familia construida],
    [@ch:ope y @ch:inferencia], [¿Podemos evaluar otra política y cuantificar su incertidumbre?], [Identificación, soporte y ruta inferencial deben justificarse],
    [@ch:verificacion y @ch:despliegue], [¿La implementación conserva esas condiciones?], [Un cambio de población, procedimiento o política obliga a revisar],
  )

  La continuidad del ejemplo está en esas preguntas. Un cálculo de riesgo,
  una comparación de políticas y un intervalo responden a objetivos que se
  relacionan, pero cuya interpretación depende del experimento. El registro
  de cada decisión permite recuperar qué datos y qué supuestos la sostienen.
]

== Preguntas para continuar el trabajo
<sec:ch13-problemas-abiertos>

Las dificultades de identificación, observación y dependencia pueden formularse ahora como objetivos de investigación. Los enunciados siguientes precisan qué se buscaría obtener dentro de los modelos indicados. Su resolución general queda fuera de los resultados desarrollados en el libro.

=== Confounding no observado: identificación parcial y métodos robustos

Cuando la ausencia de confusión no observada no puede justificarse, puede ser más adecuado buscar un conjunto de valores compatibles con los datos y con supuestos de sensibilidad. La literatura de identificación parcial de Manski (1990) e Imbens y Manski (2004) ofrece un punto de partida para estudiar cotas de $Value^(pi_e)$. La pregunta siguiente precisa una forma de continuar ese trabajo:

#thm-env("problem", name: [Cotas eficientes bajo confounding parcial], key: "prob:confounding")[
  Dado un nivel de confounding no observado acotado por un parámetro de
  sensibilidad $Gamma$, caracterizar la función de influencia eficiente
  para las cotas de $Value^(pi_e)$ y construir intervalos de confianza
  para dichas cotas que sean óptimos en el sentido semiparamétrico.
]

Los trabajos de un solo período (Rosenbaum, 2002; Yadlowsky et al., 2022) permiten estudiar cómo se formula la sensibilidad. La extensión solicitada al caso secuencial de horizonte largo queda fuera del desarrollo de esta monografía.

=== POMDPs: inferencia con observabilidad parcial

En un POMDP, el estado de creencia $b_t$ depende de la información observada y del modelo de filtrado. Si el estado latente es finito, la creencia es un vector de probabilidades; para espacios generales puede ser una distribución de dimensión infinita. Además del cálculo de una política, interesa saber cómo el error del filtro afecta a la evaluación estadística:

#thm-env("problem", name: [Inferencia eficiente en POMDPs con estado latente finito], key: "prob:pomdp")[
  Para un POMDP con espacio de estados latentes finito $|StateSpace| =
  K$ conocido, caracterizar la IF eficiente para $Value^(pi_e)$ en
  términos de las distribuciones de filtrado $P(s_t | H_t)$, con historia completa y ley inicial especificada,
  y derivar estimadores DR que hereden la doble robustez del caso de
  observabilidad completa.
]

El trabajo de Tennenholtz, Shalit y Mannor (2020) sobre OPE con
confounding latente representa avances en esta dirección, pero sin las
garantías de eficiencia semiparamétrica que el @prob:pomdp solicita.

=== LLM-agents: evaluación sin acceso a la política

Cuando una política $pi$ produce acciones pero su mecanismo de generación no permite calcular $pi(a|s)$, los cocientes habituales de OPE no están directamente disponibles. El historial de conversación añade además un espacio de información extenso. La pregunta consiste en precisar qué datos y qué restricciones permitirían recuperar una evaluación en ese régimen.

#thm-env("problem", name: [OPE para políticas no evaluables], key: "prob:llm-ope")[
  Desarrollar métodos de evaluación off-policy para políticas $pi_e$
  cuya densidad $pi_e (a|s)$ no es computacionalmente accesible, ya sea
  mediante estimación del ratio $pi_e (a|s)\/pi_b (a|s)$ directamente
  como razón de densidades, o mediante métodos de evaluación que no
  requieran dichos ratios.
]

El método directo utiliza un modelo de valor y evita calcular algunos cocientes, a cambio de depender de la calidad de ese modelo. Una propuesta para el problema anterior tendría que precisar qué información sustituye a las probabilidades de acción y cómo se controla el sesgo que pueda quedar.

=== Condiciones de mixing en espacios continuos de alta dimensión

Las condiciones de mixing del @ch:herramientas y los resultados del @ch:inferencia
están formuladas para cadenas de Markov en espacios de estados
discretos o en $RR^d$ con $d$ fijo. En aplicaciones modernas de RL con
redes neuronales profundas, el espacio de estados efectivo tiene
dimensión muy alta y la cadena de Markov inducida por $pi_b$ puede no
satisfacer las condiciones de mixing geométrico bajo las que el CLT se
extiende.

#thm-env("problem", name: [Condiciones de mixing en espacios de alta dimensión], key: "prob:mixing")[
  Caracterizar clases de MDPs con espacio de estados en $RR^d$ (o en
  espacios de secuencias) bajo las cuales la cadena de Markov inducida
  por políticas representadas por redes neuronales satisface
  condiciones de mixing polynomial, y derivar tasas de convergencia
  explícitas para el CLT del estimador DR.
]

== Cómo orientar el trabajo que sigue
<sec:ch13-direcciones>

Una forma de avanzar consiste en escoger una dificultad y declarar qué
información adicional permitiría tratarla. En presencia de confusión no
observada, por ejemplo, un análisis de sensibilidad necesita definir el
modelo de desviación antes de construir sus cotas. En observación parcial,
hay que fijar la relación entre el estado latente, el registro disponible
y las acciones. Esa delimitación permite comparar un método nuevo con los
resultados de los capítulos anteriores.

Otra línea de trabajo es sostener una evaluación cuando el sistema cambia.
El @ch:despliegue distingue los cambios de implementación, política y
población. Un protocolo de auditoría puede apoyarse en esa distinción para
registrar la evidencia de cada versión, sus condiciones de revisión y el
alcance de las decisiones que permite tomar.

Aprender una política con datos observacionales plantea una exigencia
adicional a evaluarla. La selección favorece candidatas con resultados
muestrales altos y obliga a considerar la incertidumbre del procedimiento
completo. El diseño de evaluaciones independientes, restricciones de
política y criterios conservadores ofrece preguntas que conectan la
comparación de riesgos del @ch:wald con los problemas de aprendizaje fuera
de línea. Cada propuesta debe precisar cómo se justifica la decisión final.

== Ejercicios
<sec:ch12-ejercicios>

=== Ejercicios Teóricos

+ *Confounding No Observado:* Construya un modelo causal con confusión no observada y positividad en el que IS sea sesgado. Derive el sesgo y construya otro caso donde se cancele. Explique por qué confusión no implica sesgo distinto de cero para toda política y recompensa.

+ *POMDPs:* Para $K$ estados latentes, represente las creencias en el simplex de dimensión $K-1$. Distinga cardinalidad infinita de dimensión infinita y explique qué cambia con un espacio latente general.

+ *LLM-Agents:* Suponga tokens independientes, políticas producto $pi$ y $b$ con soporte cubierto y recompensa terminal constante uno. Demuestre $EE_b(W_L^2)=(sum_x pi(x)^2/b(x))^L$ y derive la varianza de IS para $n$ textos iid. Compare con $pi=b$ y explique por qué no hay un crecimiento universal al cambiar la recompensa o la dependencia entre tokens.

+ *Mixing:* Fije una política cuya cadena sea finita, irreducible, aperiódica, reversible e iniciada en su ley invariante. Use el gap espectral absoluto para probar mezcla geométrica. Explique por qué irreducibilidad y aperiodicidad solas no bastan en espacios generales.

+ *SAVE:* Distinga el resultado de política fija de @thm:ch11-shi del procedimiento SAVE para políticas aprendidas. Para comparar con IS, especifique un mismo objetivo, modelo y régimen muestral. Diseñe una comparación de sesgo, varianza y cobertura sin presuponer dominancia de varianza.

=== Ejercicios Prácticos

+ *Implementación de DR:* Implemente el estimador DR para el SSCH
  usando Python. Compare con IS y DM cuando el modelo de recompensa
  está mal especificado.

+ *ICs para $Value^pi$:* Implemente el cálculo de ICs usando el
  procedimiento de Shi et al. con su estimador de varianza; compare por separado con una ruta que justifique HAC. Valide la
  cobertura mediante simulación.

+ *Análisis de Poder:* En un diseño de episodios iid con diferencias pareadas de desviación estándar $sigma_D=2$, use la aproximación normal bilateral de nivel 5% para detectar una diferencia de 0.5 con poder 80%. Calcule $n=ceil((z_(0.975)+z_(0.8))^2 sigma_D^2/0.5^2)$ y explique por qué ese diseño y su varianza no se transfieren automáticamente a otro SSCH.

+ *LLM-Agent OPE:* Implemente un estimador de propensity para acciones
  textuales usando log-probabilidades de un LLM. Evalúe una política
  simple.

+ *POMDP State Estimation:* Implemente un filtro de partículas para
  estimar el estado latente en un POMDP simple. Compare con el caso
  completamente observable.

=== Ejercicios de Síntesis

+ *Mapa de Trazabilidad:* Para un agente que usted diseñe, cree un
  mapa de trazabilidad completo conectando cada componente con su
  justificación teórica.

+ *Análisis de Limitaciones:* Identifique las limitaciones del marco
  Wald-MDP en su dominio de aplicación. Proporcione estrategias de
  mitigación específicas.

+ *Diseño de Experimento:* Diseñe un experimento para validar las
  garantías del marco en un dominio real. Incluya métricas de
  cobertura, eficiencia y robustez.

+ *Extensión Teórica:* Proponga una extensión del marco para manejar
  uno de los problemas abiertos identificados en la
  @sec:ch12-fronteras.

+ *Agente Confiable:* Diseñe un agente confiable para un dominio de su
  elección. Justifique cada componente usando el marco Wald-MDP.

== Lecturas Propuestas
<sec:ch12-lecturas>

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Obligatorias
]

+ *#cite(<shi2022statistical>, form: "prose")*, "Statistical Inference
  for RL".

+ *#cite(<kallus2022efficiently>, form: "prose")*, "Efficient OPE".

== Decidir con la información que se tiene
<sec:ch13-epilogo>

La medición imperfecta de la Introducción sigue planteando la misma elección:
actuar con lo observado o buscar información antes de hacerlo. Después del
recorrido podemos describir mejor esa elección. La pérdida precisa qué
consecuencias importan; el modelo indica cómo se relacionan con los datos;
la regla establece qué información usa la acción. Si la decisión afecta
al futuro, las transiciones y el horizonte completan el problema.

La incertidumbre acompaña a esa descripción. Conocer el valor óptimo en un
modelo tabular no determina el valor de una política en una población
nueva. Una estimación favorable requiere además entender qué datos la
producen y con qué precisión aproxima su objetivo. Los intervalos, los
contrastes y las cotas permiten expresar parte de esa incertidumbre bajo
condiciones que deben permanecer visibles.

El procedimiento de verificación permite volver desde una decisión hasta
sus razones. Ante una discrepancia, se puede examinar la distribución de
los datos, el soporte de las acciones, el error de los modelos auxiliares o
la implementación del estimador. Esa posibilidad de revisión es parte del
uso de una garantía: el registro de sus condiciones orienta lo que hay que
comprobar cuando cambia la situación.

Los apéndices permiten seguir ese trabajo con más detalle. Reúnen argumentos,
notación y condiciones, además de un diseño de reproducción cuyos resultados
pendientes se señalan junto al experimento. El lector puede consultar esos
materiales al retomar una demostración, reproducir un cálculo o formular
una pregunta nueva.

Una decisión posterior volverá a exigir el mismo cuidado: precisar qué se
quiere conseguir, qué información está disponible y qué conclusión permiten
los datos. Las herramientas del libro ayudan a responder esas preguntas y
a reconocer cuándo todavía hace falta aprender algo antes de actuar.

#v(1em)
#align(right)[_Lima, Perú, 2026_]
