#import "../plantilla.typ": *

= De la garantía al despliegue
<ch:despliegue>

Una garantía describe un procedimiento bajo un modelo y un diseño de datos.
Desplegarlo exige comprobar qué procedimiento se ejecuta realmente, qué
población recibe sus decisiones y qué ocurre cuando las condiciones dejan
de sostenerse. El protocolo del @ch:verificacion proporciona la ficha de
cada afirmación; este capítulo la aplica a transformaciones numéricas,
generación de acciones, presupuestos de cómputo y monitoreo.

Los ejemplos son sintéticos. Las tolerancias operativas se presentan como
decisiones de diseño explícitas, no como constantes universales. El objetivo
es producir una decisión revisable de continuar, restringir, abstenerse o
suspender, con una explicación de su fundamento.

== Lo que puede cambiar al ejecutar el procedimiento

Conviene distinguir dos sentidos de inferencia. La *inferencia estadística*
estudia un objetivo como $J(pi)$ y la incertidumbre de su estimación. La
*ejecución del modelo* transforma entradas en predicciones o acciones mediante
una implementación concreta. Una optimización de ejecución puede conservar
el procedimiento estadístico, alterar sus contribuciones o cambiar la propia
política. Son situaciones diferentes.

Una demostración no se vuelve conjetura porque sus hipótesis no puedan
comprobarse por completo con una muestra. La simulación examina consecuencias
en escenarios especificados; los datos reales permiten diagnósticos parciales;
la identificación y las hipótesis poblacionales requieren argumentos propios.
Ni pasar una batería de pruebas prueba el modelo, ni un resultado favorable
de cobertura certifica cualquier futuro despliegue.

Antes de modificar una implementación, se registra una versión de referencia:
política, población inicial, acciones, recompensa, horizonte, mecanismo de
registro, estimador, funciones auxiliares y regla de decisión. Después se
compara con la versión ejecutada. La comparación debe incluir los mecanismos
de selección y parada, no solo el archivo de pesos de una red.

#mi-figura(key: "fig:ch11-dos-capas",
  caption: [Dos capas y tres efectos posibles de una transformación de ejecución.],
  block(breakable: false, width: 100%, inset: 8pt, stroke: 0.5pt + luma(170))[
    #align(center)[*Inferencia estadística: objetivo, estimador, varianza y condiciones*]
    #align(center)[$arrow.b$]
    #table(columns: (1fr,1fr,1fr), stroke: none, inset: 6pt,
      [*Equivalencia*], [*Perturbación*], [*Cambio de problema*],
      [Misma ley de acciones y mismo cálculo relevante.],
      [Error numérico o aproximación cuantificable.],
      [Otra política, población, recompensa o información disponible.],
      [Conservar la justificación si también se conservan sus hipótesis.],
      [Acotar el efecto y revisar la varianza o la decisión.],
      [Redefinir el objetivo y justificar una evaluación nueva.],
    )
    #align(center)[$arrow.b$]
    #align(center)[*Ejecución: precisión, decodificación, tiempo y registro*]
  ])

La clase de modelo determina qué control se necesita. En un modelo
paramétrico regular puede propagarse una perturbación mediante derivadas
del funcional. En una expansión semiparamétrica importa cómo interactúa
con los errores auxiliares. En una estimación no paramétrica de una función
completa deben revisarse también sesgo, norma y uniformidad. Una tolerancia
adecuada para un promedio no certifica una banda sobre todos los estados.

== Cuantización del modelo que aproxima Q

Sea $hat(q)$ el ajuste estadístico y $tilde(q)$ su versión de precisión
reducida. Separamos el error de aprendizaje $hat(q)-q$ del error de
representación $tilde(q)-hat(q)$. Medir el segundo en un conjunto de prueba
no proporciona automáticamente una cota uniforme en la población.

*Un cálculo de una decisión.* Para episodios iid y política objetivo fija,
use la contribución DR del @ch:ope, con auxiliares ajustados fuera de la
unidad evaluada:
$ D(hat(m),hat(b))=sum_a pi(a|S)hat(m)(S,a)
  +frac(pi(A|S),hat(b)(A|S))(R-hat(m)(S,A)). $
Si $Delta_m=tilde(m)-hat(m)$, entonces
$ D(tilde(m),hat(b))-D(hat(m),hat(b))
  =sum_a pi(a|S)Delta_m (S,a)
  -frac(pi(A|S),hat(b)(A|S))Delta_m (S,A). $
Bajo $norm(Delta_m)_infinity<=epsilon.alt_q$ y
$pi(A|S)/hat(b)(A|S)<=C$, el valor absoluto de la diferencia no supera
$epsilon.alt_q (1+C)$. La cota vale para cada contribución y por tanto para
su media, cuando esas desigualdades valen en el dominio pertinente.

Si el registro verdadero $b$ se conoce, el incremento tiene esperanza
condicional cero al promediar sobre la acción. Cuantizar el auxiliar no
produce entonces necesariamente sesgo de DR, aunque puede cambiar su
varianza. Si $hat(b)$ también está estimado, la esperanza del incremento es
$ EE(sum_a pi(a|S)frac(hat(b)(a|S)-b(a|S),hat(b)(a|S))Delta_m (S,a)). $
Con soporte controlado, aparece un producto de errores. Para conservar una
expansión eficiente original se necesitan condiciones que hagan despreciables
el resto y la diferencia de influencias: no basta una etiqueta de precisión
«8 bits». Con registro conocido y un auxiliar fijo distinto puede mantenerse
un CLT para las nuevas contribuciones sin mantener la varianza eficiente.

#thm-env("example", key: "cap11-cuantizacion")[
  *Ejemplo verificable.* Tome una acción binaria, $b(1)=0.5$, $pi(1)=0.75$,
  $R=A$ y $hat(m)=(0.2,0.8)$. Las contribuciones DR son $0.55$ y $0.95$,
  con media $0.75$. Una perturbación $(0.01,-0.01)$ las cambia en
  $(-0.01,0.01)$. La media permanece igual, pero la dispersión aumenta.
  La cota anterior es $0.01(1+1.5)=0.025$. El programa al final del capítulo
  comprueba estas identidades. Una alteración pequeña de números no significa
  que deba conservarse sin cambios el error estándar anterior.
]

*Transferencia de un intervalo mediante una cota.* Suponga que el intervalo
original $[hat(J)-h,hat(J)+h]$ tiene la cobertura afirmada y que
$abs(tilde(J)-hat(J))<=B_q$. Entonces
$ [tilde(J)-h-B_q,tilde(J)+h+B_q] $
contiene el intervalo original. Conserva al menos su cobertura si la cota
es determinista; si solo se cumple con probabilidad $1-eta$, la cobertura
se reduce como máximo en $eta$ por la unión de eventos. Aquí se mantiene
el semiancho original $h$: sustituirlo por otro calculado después de la
cuantización exige una justificación adicional.

*Cuando Q selecciona acciones.* Si una política greedy usa un aproximador
con error uniforme a lo sumo $epsilon.alt$ respecto de $Q^*$, una acción
puede cambiar cuando la brecha entre las dos mejores acciones no supera
$2epsilon.alt$. En un MDP descontado con las condiciones usuales de Bellman,
la pérdida uniforme de valor de esa política se acota por
$2epsilon.alt/(1-gamma)$. La desigualdad compara con $Q^*$; si solo se conoce
el error de cuantización respecto de $hat(Q)$, falta añadir el error de
aprendizaje. Con valores $1$ y $0.99$, errores de magnitud $0.006$ pueden
invertir la elección. La discontinuidad de argmax impide describir todos
los cambios de despliegue como degradaciones suaves.

== Decodificación especulativa

No toda decodificación especulativa modifica la distribución objetivo.
El método exacto de
#link("https://proceedings.mlr.press/v202/leviathan23a.html")[Leviathan, Kalman y Matias (2023)]
utiliza propuestas y una corrección de aceptación para conservar la ley
del modelo objetivo bajo las condiciones de su algoritmo. La afirmación
se refiere a la distribución, no a producir exactamente la misma secuencia
con cualquier semilla o implementación.

La revisión distingue tres casos. Si el algoritmo implementado conserva
la ley de la política evaluada, no hay un cambio de política por ese motivo.
Si usa una aproximación, cambia temperatura, truncamiento de vocabulario,
reglas de aceptación o límites de generación, debe caracterizarse la ley
efectiva. Si no puede caracterizarse, ciertas rutas de OPE dejan de ser
operativas; esto no equivale por sí solo a demostrar falta de identificación
del valor por cualquier método.

La política incluye cómo se convierte la salida en una acción: generación,
validación, filtros, reintentos, selección entre candidatos y posibles
intervenciones humanas. La probabilidad de una secuencia de tokens no es
la probabilidad de una categoría asignada después a muchas secuencias.
Tampoco basta normalizar probabilidades de las acciones observadas si quedan
otras acciones posibles fuera del denominador.

*Ficha de equivalencia.* Registre la política de referencia, el mecanismo
ejecutado, la propiedad de equivalencia alegada y la evidencia que la
sostiene. Una prueba de equivalencia del algoritmo y pruebas del código
atienden preguntas distintas. Comparar frecuencias en un conjunto finito
de entradas puede detectar discrepancias, pero no demuestra igualdad de
leyes para todas las historias.

== Latencia como restricción de diseño

Una latencia menor no cambia necesariamente la inferencia: puede obtenerse
con una implementación equivalente. El cambio estadístico aparece cuando
se reduce el horizonte, se aproxima una recursión, se descartan datos o se
seleccionan resultados según su tiempo de respuesta.

#thm-env("example", key: "cap11-truncamiento")[
  *Truncamiento de horizonte.* Si $abs(R_t)<=R_max$ y $0<gamma<1$, el error
  entre el retorno infinito y el truncado después de $H$ recompensas se acota
  por
  $ B_H=frac(R_max gamma^H,1-gamma). $
  Para garantizar $B_H<=epsilon.alt$ basta escoger el menor entero no negativo
  que cumpla la desigualdad. Con $R_max=1.2$, $gamma=0.9$ y tolerancia $0.1$,
  se necesita $H>=46$. Veinte o cinco pasos definen aproximaciones distintas;
  un IC válido para el retorno truncado no cubre automáticamente el infinito.
]

*Planificación interrumpida.* Para un operador de Bellman contractivo con
factor $gamma$, el residuo $e=norm(cal(T)V-V)_infinity$ da la cota
$norm(V-V^*)_infinity<=e/(1-gamma)$. Es una cota computacional dentro del
modelo utilizado. No incorpora incertidumbre de transiciones estimadas ni
es, por sí sola, una cota de pérdida de la política extraída.

*Selección por tiempo de respuesta.* Conservar solo episodios que terminan
antes del plazo puede seleccionar casos fáciles. El objetivo pasa a ser
una población condicionada por finalización, salvo que se justifique una
corrección de observación o censura. Si se detiene una simulación cuando
su media parece favorable, cambia la regla de muestreo. Un presupuesto
fijo de réplicas independientes y una parada dependiente de resultados
no tienen la misma justificación inferencial.

*Presupuesto conjunto.* La ficha registra por separado error estadístico,
error de representación y error de truncamiento. Solo pueden sumarse cotas
cuando se refieren a la misma cantidad, norma y versión del procedimiento.
La probabilidad de exceder una latencia y el error de estimación de valor
son métricas diferentes; una no sustituye a la otra.

== Cuando una restricción de ejecución cambia la decisión

La dificultad central es evaluar el procedimiento que efectivamente actúa.
Hay que separar tres obstáculos: probabilidades difíciles de calcular,
ausencia de soporte e identificación causal insuficiente. Cada uno requiere
una respuesta distinta.

Una política objetivo que puede ejecutarse pero cuya masa de probabilidad
no se evalúa fácilmente puede estudiarse on-policy en nuevos episodios,
si el experimento está autorizado y bien definido. Una simulación de acciones
objetivo puede aproximar integrales de un modelo directo, con su error
Monte Carlo y sus supuestos. En cambio, IS necesita razones pertinentes;
no puede reemplazarlas por números arbitrarios. Las políticas deterministas
con regla conocida sí tienen probabilidades evaluables: cero o uno.

La falta de soporte es otro problema. Si una acción relevante para la
objetivo nunca puede observarse bajo el registro, la ley observada puede
ser compatible con varios resultados contrafactuales y valores distintos.
Un modelo directo que extrapola aporta restricciones adicionales; no recupera
una garantía no paramétrica por cambiar de estimador. La confusión no medida
constituye aún otra limitación, que no resuelve conocer las probabilidades
nominales de un algoritmo.

*Caso operativo SSCH.* En el subcaso de dos visitas de los capítulos 8–9,
la diferencia estimada es $0.475$ y el límite inferior unilateral aproximado
al 95% es $0.45837$. Para un margen prefijado $0.40$, el contraste aporta
evidencia bajo ese diseño. Si la versión ejecutada modifica la política,
el intervalo sigue refiriéndose a la versión evaluada. Se necesita una
nueva evaluación o una cota de diferencia de valores justificada; no basta
con conservar el nombre SSCH.

La abstención se define como una acción operativa: mantener una alternativa
previamente evaluada, derivar a revisión o suspender la automatización,
según el problema. Cada alternativa tiene consecuencias y un responsable.
No se presupone que «no actuar» carezca de pérdida ni que volver a una
política anterior sea siempre adecuado para una población que cambió.

== Protocolo de validación empírica

El protocolo comienza con la ficha del @ch:verificacion y termina con un
dictamen limitado al escenario examinado. Combina verificación de fórmulas,
comprobaciones del diseño, simulación con verdad conocida y seguimiento del
sistema ejecutado. Los apartados siguientes cumplen funciones diferentes;
ningún promedio de sus resultados reemplaza una condición de identificación.

El código reproducible que acompaña este capítulo realiza una simulación
controlada, calcula esperanzas DR por recursión y comprueba una perturbación
numérica. No despliega un agente, no estima auxiliares con ML y no certifica
una aplicación real. Cuando la aplicación aprende funciones o selecciona
políticas, la validación debe repetir también esas etapas.

== Qué permite comprobar la validación
<sec:appE-objetivos>

+ *Corrección del cálculo:* verificar que el valor de referencia y el
  estimador corresponden al mismo horizonte, descuento y población inicial.
+ *Comportamiento inferencial:* estimar sesgo, variabilidad, cobertura y
  longitud de intervalos, acompañados de incertidumbre Monte Carlo.
+ *Sensibilidad:* cambiar de forma controlada soporte, dependencia,
  especificación de auxiliares y precisión numérica.
+ *Funcionamiento del sistema:* comprobar acciones de abstención, registros,
  límites de tiempo y detección de versiones incompatibles.
+ *Alcance del dictamen:* distinguir condiciones comprobadas en el experimento,
  supuestos poblacionales declarados y evidencia aún pendiente.

La eficiencia semiparamétrica es relativa a un modelo y una clase de
estimadores regulares. Una varianza pequeña o un RMSE favorable en una
simulación no demuestra que se alcance esa cota. La doble robustez tampoco
implica insesgadez exacta cuando los auxiliares son aprendidos en la muestra.

== Protocolo 1: Simulación de MDP Controlado
<sec:appE-mdp>

=== Configuración del MDP de Prueba

#thm-env("definition", name: [MDP de Validación Estándar], key: "def:appE-mdp-test")[
  Se utilizan tres estados, dos acciones y descuento $gamma=0.9$.
  Las recompensas de @tab:appE-mdp son deterministas dado estado y acción.
  La política objetivo fija es $pi(a_1|s)=0.6$, $pi(a_2|s)=0.4$.
  El registro de la simulación principal asigna probabilidad $0.5$ a cada
  acción. Los episodios comienzan en $s_1$, tienen cinco decisiones y se
  generan independientemente. El objetivo simulado es $J_5=V_0^pi (s_1)$.
]

#mi-tabla(key: "tab:appE-mdp", caption: [MDP sintético de validación: probabilidades y recompensas de diseño.],
  table(columns: (22%,19%,19%,19%,1fr),align:center,hl(),
    table.header([*Par*],[$P(s_1)$],[$P(s_2)$],[$P(s_3)$],[$r$]),hl(w:0.6pt),
    [$(s_1,a_1)$],[0.7],[0.2],[0.1],[1.0],
    [$(s_1,a_2)$],[0.3],[0.5],[0.2],[0.5],
    [$(s_2,a_1)$],[0.2],[0.6],[0.2],[0.8],
    [$(s_2,a_2)$],[0.1],[0.3],[0.6],[1.2],
    [$(s_3,a_1)$],[0.4],[0.3],[0.3],[0.3],
    [$(s_3,a_2)$],[0.2],[0.2],[0.6],[0.7],hl()))

=== Cálculo de Valores Verdaderos

Para horizonte infinito se resuelve
$ V_infinity^pi=(I-gamma P^pi)^(-1)r^pi, $
con $P^pi=sum_a pi(a|s)P(dot|s,a)$ y $r^pi=sum_a pi(a|s)r(s,a)$.
El cálculo numérico da
$ V_infinity^pi approx (7.651602,7.732035,7.191250)^T. $
La política es constante respecto del estado, pero no uniforme entre acciones.

Para cinco decisiones se calcula hacia atrás:
$ v_5(s)=0, quad q_t (s,a)=r(s,a)+gamma sum_j P(s_j|s,a)v_(t+1) (s_j), $
$ v_t (s)=sum_a pi(a|s)q_t (s,a). $
Se obtiene
$ v_0 approx (3.198864,3.279764,2.738539)^T. $
El parámetro de cobertura del programa es $J_5 approx 3.198864$, no el
primer componente del vector de horizonte infinito. Compararlos sin
controlar la cola generaría un falso diagnóstico de sesgo.

=== Procedimiento de Validación

#algorithm-env(key: "alg:appE-cobertura", caption: [Validación de cobertura para un procedimiento especificado.])[
  + Fijar objetivo, generador, horizonte, tamaño y procedimiento antes de simular.
  + Calcular la verdad analítica o numérica con error controlado.
  + Generar $M$ muestras independientes; en cada una repetir las etapas
    de entrenamiento, selección y evaluación que realmente use el método.
  + Registrar estimación, error estándar, extremos del IC y fallos numéricos.
    No eliminar silenciosamente las réplicas fallidas.
  + Calcular sesgo, RMSE, cobertura y longitud; estimar su error Monte Carlo.
  + Comparar con tolerancias prefijadas y conservar los escenarios donde
    el procedimiento resulte insuficiente o no aplicable.
]

En la ejecución de referencia, $M=1000$, $n=200$ episodios y $H=5$.
Los auxiliares se fijan de antemano: $q$ verdadero o $0.8q$, y registro
correcto o una función incorrecta $(0.8,0.2)$. Se añade $0.8q$ redondeado
a una cifra decimal con registro correcto. Se calcula el DR secuencial
con razones acumuladas, término inicial y residuos de Bellman. Los IC son
normales por episodios, de validez asintótica, no intervalos exactos.

El uso de funciones verdaderas en algunos escenarios es una herramienta
para aislar propiedades matemáticas. No representa acceso a la verdad en
una aplicación ni valida un ajuste de redes neuronales.

=== Métricas de Evaluación

Con estimaciones $hat(J)_m$ y errores estándar $hat(s)_m$, defina
$ hat(B)=overline(hat(J))-J, quad
  s_"MC"^2=frac(1,M-1)sum_m (hat(J)_m-overline(hat(J)))^2. $
El error Monte Carlo del sesgo es $s_"MC"/sqrt(M)$. La cobertura estimada es
$hat(C)=M^(-1)sum_m bb(1)_(J in C_m)$ y su error Monte Carlo plug-in es
$sqrt(hat(C)(1-hat(C))/M)$. En coberturas cero o uno, ese error plug-in
se anula sin demostrar ausencia de incertidumbre; use un intervalo binomial.

#mi-tabla(key: "tab:appE-metricas", caption: [Métricas y alcance de su interpretación.],
  table(columns:(20%,38%,1fr),align:left,hl(),
    table.header([*Métrica*],[*Cálculo*],[*Interpretación*]),hl(w:0.6pt),
    [Cobertura],[Fracción de IC que contienen el objetivo.],[Reportar incertidumbre binomial; no exigir igualdad numérica a 0.95.],
    [Sesgo],[Media de errores y su error Monte Carlo.],[Distinguir sesgo sustantivo de ruido de simulación.],
    [Calibración del SE],[$sqrt(M^(-1)sum_m hat(s)_m^2)$ frente a $s_"MC"$.],[Compara varianza estimada y dispersión muestral; no prueba eficiencia.],
    [RMSE],[$sqrt(M^(-1)sum_m (hat(J)_m-J)^2)$.],[Combina sesgo y variabilidad para ese objetivo.],
    [Longitud y fallos],[Longitud media y proporción de ejecuciones fallidas.],[La cobertura aislada puede ocultar intervalos inútiles o réplicas descartadas.],hl()))

*Resultados obtenidos.* La tabla reproduce la ejecución del programa adjunto.
«Correcto» describe las funciones fijadas, no un diagnóstico aprendido.

#mi-tabla(caption: [Simulación de referencia: mil muestras de doscientos episodios.],
  table(columns:(37%,16%,16%,16%,1fr),align:left,hl(),
    table.header([*Escenario*],[*Sesgo*],[*Cobertura*],[*MCSE*],[*RMSE*]),hl(w:0.6pt),
    [Ambos correctos],[-0.001046],[0.951],[0.0068],[0.021366],
    [Solo Q correcto],[0.000449],[0.944],[0.0073],[0.076099],
    [Solo registro correcto],[-0.001844],[0.938],[0.0076],[0.027548],
    [Ambos incorrectos],[1.047845],[0.000],[—],[1.055570],
    [Q cuantizado; registro correcto],[-0.002005],[0.948],[0.0070],[0.027915],hl()))

Por ilustración, un requisito de diseño puede ser que el límite inferior
unilateral de Wilson al 95% para la cobertura supere $0.93$. En los
escenarios de ambos correctos, solo Q correcto, solo registro correcto y
Q cuantizado, los límites son $0.9385$, $0.9308$, $0.9242$ y $0.9352$.
El tercero no satisface ese criterio con esta ejecución. No corresponde
ajustar la tolerancia después para hacerlo pasar; puede ampliarse el estudio
o revisarse el método. Wilson es aquí una aproximación binomial para
incertidumbre Monte Carlo, no una prueba exacta de cobertura poblacional.
Si se pretende un dictamen simultáneo sobre muchos escenarios, también
se controla esa multiplicidad.

== Protocolo 2: Verificación de Overlap
<sec:appE-overlap>

=== Escenarios de Prueba

La igualdad de políticas hace unitarios los pesos de importancia, pero no
prueba que el estimador tenga un IC óptimo. Con soporte insuficiente pueden
observarse solo pesos aparentemente benignos: el ESS de los datos existentes
no cuenta las acciones que nunca aparecen.

#mi-tabla(key: "tab:appE-overlap", caption: [Soporte y concentración: escenarios distintos.],
  table(columns:(23%,37%,1fr),align:left,hl(),
    table.header([*Escenario*],[*Configuración*],[*Conclusión permitida*]),hl(w:0.6pt),
    [Misma política],[$b=pi$ conocido.],[Pesos iguales a uno; revisar el resto de condiciones.],
    [Soporte amplio],[Probabilidades de registro alejadas de cero en acciones objetivo.],[Evaluar precisión sin umbral universal de ESS.],
    [Concentración],[Probabilidades pequeñas pero positivas en acciones relevantes.],[Puede haber alta varianza y mala aproximación normal en muestra finita.],
    [Sin soporte],[$b(a|s)=0$ y $pi(a|s)>0$ en un estado relevante.],[La ruta por importancia no se justifica; DM requiere otras restricciones.],
    [Registro incompleto],[No se conserva el mecanismo efectivo de asignación.],[Pendiente de reconstrucción; no inventar probabilidades.],hl()))

=== Procedimiento de Verificación de Diagnósticos

#algorithm-env(key: "alg:appE-overlap", caption: [Comprobación de soporte y evaluación de alertas.])[
  + En simulación, comprobar el soporte del generador y la alcanzabilidad
    de estados, no solo las acciones presentes en una muestra.
  + Calcular pesos compatibles con el estimador y su unidad: por episodio,
    por tiempo o razones marginales según corresponda.
  + Registrar ESS, máximos y colas como diagnósticos de concentración.
  + Calibrar alertas en escenarios separados de aquellos usados para evaluarlas;
    reportar sensibilidad y falsas alarmas con incertidumbre binomial.
  + Ante ausencia estructural de soporte, suspender la afirmación afectada
    o cambiar explícitamente diseño, población, política o supuestos.
]

En el programa, sustituir el registro por $(1,0)$ mientras la política
objetivo usa la segunda acción con probabilidad $0.4$ produce una violación
estructural detectable. No se generan pesos con denominador artificial
$10^(-9)$ ni se exige que su ESS observado sea cercano a cero. En datos
reales, cero observaciones no demuestra por sí solo probabilidad cero;
tampoco una probabilidad ajustada positiva demuestra soporte suficiente.

== Protocolo 3: Verificación de Mixing
<sec:appE-mixing>

=== Tests de Estacionariedad

ADF contrasta una hipótesis de raíz unitaria dentro de una especificación
de serie temporal. KPSS contrasta estacionariedad de nivel o tendencia
según su versión. Rechazar una nula o no rechazar otra no demuestra que
el proceso observado sea estacionario, y ninguno de esos resultados prueba
mixing geométrico del estado completo.

La elección de rezagos, términos deterministas, tamaño y variables observadas
importa. Un cambio de política durante la recolección puede modificar la ley
sin que un test tenga potencia suficiente para detectarlo. Los diagnósticos
se registran como evidencia parcial, no como casillas obligatorias capaces
de certificar una condición poblacional.

La primera decisión es identificar el régimen muestral. Episodios con
reinicios independientes permiten una ruta iid por contribuciones completas.
Una trayectoria larga necesita una justificación de dependencia y varianza
compatible. El experimento principal de este capítulo usa episodios iid;
no requiere aprobar ADF ni estimar una tasa de mixing para su CLT.

=== Estimación de Tasa de Mixing

Una regresión de $log(abs(hat(rho)_k))$ sobre el rezago describe, como mucho,
un patrón de autocorrelación estimada de un observable. No estima en general
los coeficientes de mixing entre sigma-álgebras. Correlaciones negativas,
ceros y ruido en rezagos grandes hacen aún más frágil esa interpretación.

#algorithm-env(key: "alg:appE-mixing", caption: [Justificación de dependencia y análisis de sensibilidad.])[
  + Identificar política de registro, ley inicial, unidad y posible adaptación.
  + Si el núcleo finito es conocido, estudiar irreducibilidad, aperiodicidad
    y las condiciones de la cota utilizada; exigir reversibilidad cuando
    se emplee la cota espectral que la necesita.
  + Si el núcleo se estima, incorporar su incertidumbre y evitar interpretar
    un autovalor plug-in como certificado poblacional.
  + Examinar ACF de las contribuciones relevantes y sensibilidad a rezagos
    HAC o longitudes de bloque, como diagnósticos complementarios.
  + Registrar qué condición permite el CLT y qué estimador de varianza es
    consistente bajo ella. Si falta, conservar el dictamen pendiente.
]

El ejemplo de @ex:ch9-fallo-mixing ilustra una cadena conocida con autocovarianza $0.6^k$ y
varianza de largo plazo cuatro. Su cobertura HAC de muestra finita fue
$0.918$ con error Monte Carlo $0.0123$. Ese resultado ayuda a discutir
calibración; no autoriza a afirmar cobertura nominal porque HAC y bootstrap
produzcan intervalos visualmente parecidos.

== Protocolo 4: Validación de Estimadores DR
<sec:appE-dr>

=== Comparación de Estimadores

La comparación mantiene fijo el estimando y separa especificación,
identificación y precisión. «Overlap malo» no es sinónimo de «sin soporte».
Un estimador IS con soporte y razones correctas puede ser insesgado y tener
varianza demasiado grande para ser útil. DR no domina siempre a DM o IS
en varianza o RMSE.

#mi-tabla(key: "tab:appE-estimadores", caption: [Qué se espera bajo auxiliares fijos y soporte suficiente.],
  table(columns:(28%,22%,22%,1fr),align:left,hl(),
    table.header([*Funciones*],[*DM*],[*IS*],[*DR*]),hl(w:0.6pt),
    [Q y registro correctos],[Centrado si integración correcta.],[Centrado.],[Centrado; comparar varianzas.],
    [Solo Q correcto],[Puede ser centrado.],[Puede tener sesgo.],[Centrado con la fórmula y condiciones apropiadas.],
    [Solo registro correcto],[Puede tener sesgo.],[Centrado.],[Centrado; no se garantiza eficiencia.],
    [Ambos incorrectos],[Sin garantía general.],[Sin garantía general.],[Puede tener sesgo grande.],
    [Sin soporte],[Extrapolación bajo supuestos adicionales.],[No justificado por la ley observada.],[No recupera una garantía no paramétrica por sí solo.],hl()))

=== Verificación de Doble Robustez

#algorithm-env(key: "alg:appE-dr", caption: [Identidad poblacional, comportamiento muestral y aprendizaje.])[
  + Escribir la contribución exacta del estimador, incluidos horizonte,
    valor inicial y pesos, y fijar su población objetivo.
  + Con un generador conocido, calcular su esperanza por enumeración,
    integración o recursión cuando sea posible.
  + Examinar auxiliares ambos correctos, solo uno correcto y ambos incorrectos.
    No exigir que el último caso tenga sesgo menor que los anteriores.
  + Repetir muestras para estimar sesgo y varianza con error Monte Carlo.
  + Si se aprenden auxiliares, repetir ese aprendizaje y respetar la separación
    por unidades; revisar las condiciones del CLT además de la consistencia.
]

En la simulación, la esperanza exacta de DR es $3.198864$ cuando alguno
de los dos conjuntos auxiliares es correcto. Con ambos incorrectos es
$4.239321$. La diferencia no contradice doble robustez: el procedimiento
está fuera de los casos que anulan el resto. Un resto de producto tampoco
implica que dos errores grandes se cancelen o que su sesgo sea menor que
cuando uno de ellos es cero.

El cálculo de esperanza se realiza por propagación de ocupaciones ponderadas
en el modelo conocido. Es más informativo para comprobar la identidad que
exigir $abs(hat(J)-J)<epsilon.alt$ en una sola muestra. Las cifras observadas
de cobertura siguen siendo resultados de muestra finita con auxiliares
fijos; no prueban tasas de aprendizaje ni eficiencia semiparamétrica.

== Verificación Previa al Despliegue
<sec:appE-checklist>

El dictamen se refiere a una versión y un uso definidos. Una evidencia
pendiente no se convierte en «verificada» por la ausencia de una alarma.
Un piloto limitado puede ser una decisión operacional, pero debe describirse
como tal y no como una garantía estadística general.

#mi-tabla(key: "tab:appE-checklist", caption: [Ficha de decisión previa al uso de una versión.],
  table(columns:(8%,47%,1fr),align:left,hl(),
    table.header([*N.º*],[*Comprobación*],[*Evidencia requerida*]),hl(w:0.6pt),
    [1],[Objetivo, población, horizonte y recompensa definidos.],[Ficha del estimando.],
    [2],[Política evaluada vinculada a la ejecutada.],[Versión y argumento de equivalencia o nueva evaluación.],
    [3],[Identificación y soporte de la ruta elegida.],[Diseño documentado y supuestos pendientes explícitos.],
    [4],[Unidad y dependencia tratadas correctamente.],[Derivación de contribuciones y varianza.],
    [5],[Selección, aprendizaje y revisiones temporales incluidos.],[Particiones, plan de análisis y condiciones de expansión.],
    [6],[Errores numéricos y truncamiento controlados.],[Cotas o estudio de sensibilidad con alcance declarado.],
    [7],[Métricas de simulación y fallos reportados.],[Resultados con incertidumbre Monte Carlo.],
    [8],[Criterio de decisión y abstención prefijados.],[Margen o pérdida, responsable y acción alternativa.],
    [9],[Registro y monitoreo capaces de detectar cambios relevantes.],[Esquema de datos, alarmas y causas de suspensión.],
    [10],[Límites comunicados y revisión asignada.],[Dictamen fechado y condiciones de reevaluación.],hl()))

No se exige que DR gane siempre ni que el ESS supere un número universal.
Los criterios técnicos deben probar lo que afirman. Un denominador cero
puede detectarse por una comprobación estructural del generador; una tasa
de convergencia no puede probarse con la misma clase de comprobación.

== Pseudocódigo de Validación
<sec:appE-codigo>

El esquema siguiente separa las métricas de simulación del dictamen sobre
una aplicación. Es pseudocódigo: las funciones nombradas representan
operaciones que deben implementarse para el problema concreto. El archivo
`validar_despliegue.py` adjunto sí es ejecutable y produce las cifras de este
capítulo para el generador especificado.

#codelisting-env(caption: [Revisión de una versión sin certificaciones automáticas de supuestos.])[
```text
validar_version (ficha, procedimiento, escenarios, tolerancias):
    comprobar_coherencia_de_objetivo_y_version (ficha)
    obligaciones = enumerar_hipotesis_del_resultado (ficha)
    evidencia = clasificar_evidencia (obligaciones)
        # algebra/codigo, diseno documentado, supuesto poblacional

    si hay_contradiccion_de_identificacion_o_soporte (evidencia):
        devolver "NO APLICABLE", motivo_y_alternativas_explicitadas

    resultados = []
    para escenario en escenarios:
        verdad = calcular_objetivo_del_mismo_horizonte (escenario)
        para replica en 1..M:
            datos = generar_muestra_independiente (escenario)
            salida = ejecutar_procedimiento_completo (datos)
                # incluye ajuste y seleccion cuando correspondan
            registrar_estimacion_intervalo_y_fallos (salida, verdad)
        resultados.agregar(resumir_con_error_Monte_Carlo ())

    si falta_justificacion_necesaria (evidencia):
        devolver "PENDIENTE", evidencia, resultados
    si no_satisface_criterios_prefijados (resultados, tolerancias):
        devolver "REVISAR", resultados, causas_a_investigar

    devolver "APLICABLE BAJO SUPUESTOS DECLARADOS", ficha,
             evidencia, resultados, limites_y_causas_de_revision
```
]

Para reproducir la simulación, instale NumPy y ejecute
`python validar_despliegue.py`. El paquete incluye versión usada, semilla,
salida de consola y resultados estructurados. La ejecución no necesita datos
privados, una API de lenguaje ni una biblioteca de orquestación.

*Control mínimo de errores.* El programa comprueba que las filas de transición
suman uno, que las transiciones simuladas pertenecen al espacio de estados,
que las esperanzas DR de los casos correctos coinciden con el objetivo,
y que el ejemplo de perturbación satisface su cota. Estas comprobaciones
son específicas; no equivalen a verificar todas las condiciones de un teorema
para datos futuros.

== Interpretación de Resultados
<sec:appE-interpretacion>

Un resultado fuera de tolerancia inicia una investigación causal del fallo
del procedimiento. Aumentar el ancho de un intervalo hasta que cubra la
verdad de simulación puede ocultar sesgo, errores de objetivo o selección.
Modificar el método exige evaluar la nueva versión en escenarios reservados
o nuevas réplicas, manteniendo visibles las decisiones tomadas.

#mi-tabla(key: "tab:appE-acciones", caption: [Hallazgos, posibles causas y revisión requerida.],
  table(columns:(25%,35%,1fr),align:left,hl(),
    table.header([*Hallazgo*],[*Causas posibles*],[*Acción*]),hl(w:0.6pt),
    [Cobertura baja],[Sesgo, SE incorrecto, colas, selección u objetivo distinto.],[Separar causas; revisar expansión y diseño antes de cambiar varianza.],
    [Cobertura alta],[Conservadurismo, intervalos muy amplios o referencia errónea.],[Examinar longitud y verdad usada; no estrechar por conveniencia.],
    [Pesos concentrados],[Poco soporte práctico o política distante.],[Cuantificar precisión y sensibilidad; declarar sesgo si se recortan pesos.],
    [Soporte ausente],[Acciones relevantes nunca registradas.],[Suspender la ruta afectada o justificar un nuevo diseño o modelo.],
    [Cambio temporal],[Población, política, medición o dinámica diferentes.],[Localizar el cambio y reevaluar la garantía pertinente.],
    [Fallo de registro],[Probabilidades, versiones o resultados incompletos.],[Corregir procedencia; abstenerse cuando no pueda reconstruirse.],hl()))

#thm-env("example", key: "cap11-monitoreo")[
  *Monitoreo y multiplicidad temporal.* Revisar cada día un IC ordinario hasta
  que sea favorable no conserva su nivel. Una opción elemental, para datos
  independientes de media fija y contribuciones acotadas en $[a,b]$, consiste
  en prefijar tamaños $n_m$ y asignar
  $ alpha_m=frac(alpha,m(m+1)). $
  La suma de los niveles es $alpha$. Por Hoeffding, los límites inferiores
  $ L_m=overline(D)_(n_m)-(b-a)sqrt(frac(log(1/alpha_m),2n_m)) $
  satisfacen $Prob(exists m: L_m>J)<=alpha$ por la unión de eventos.
  No se requiere independencia entre revisiones, pero sí las condiciones de
  cada desigualdad y el objetivo fijo. En DR deben acotarse las contribuciones
  con sus pesos, no solo las recompensas. Si cambia la política objetivo o
  se ajusta el estimador adaptativamente, este argumento no se traslada sin
  revisión. Para construcciones más eficientes, véase
  #link("https://arxiv.org/abs/1810.08240")[Howard et al. (2021), sobre secuencias de confianza].
]

Las alarmas técnicas, como ausencia de una versión o datos mal formados,
no necesitan fingir ser tests estadísticos. Las alarmas de degradación de
rendimiento sí requieren definir qué se contrasta, con qué población y
cómo se controlan las revisiones. Suspender por precaución operacional y
concluir estadísticamente que el valor cayó son afirmaciones diferentes.

== Conservar las razones y los límites de la decisión
<sec:appE-limitaciones>

Cada versión conserva el estimando y sus unidades; la política y el mecanismo
de acción; el origen y diseño de los datos; los supuestos de identificación;
la ruta inferencial; los errores de aproximación y precisión; los resultados
de evaluación con incertidumbre; y el responsable de revisión. Se distingue
lo comprobado en código, lo documentado por diseño y lo asumido sobre la
población. No se usa una columna «verificado» para borrar esas diferencias.

*Cambio de población.* Suponga diferencias de valor condicionales $0.5$ y
$-0.2$ en dos grupos. Con pesos poblacionales $(0.9,0.1)$, la diferencia
integrada es $0.43$; con pesos $(0.4,0.6)$ es $0.08$. Aunque las diferencias
dentro de cada grupo no cambien, el objetivo agregado sí cambia. El intervalo
de la primera población no responde automáticamente a la segunda. Una
reponderación exige soporte y los supuestos de transporte pertinentes.

*Condiciones de suspensión.* Deben quedar definidos los cambios que obligan
a revisar: versión de política no evaluada, nueva población relevante,
pérdida del registro de acciones, alteración de recompensa, fallos de soporte,
parada no contemplada o error numérico que excede la cota usada. El registro
de suspensión indica qué garantía deja de sostenerse, qué operación se
interrumpe y qué evidencia se necesita para reanudarla.

La contribución formal del libro sigue siendo la representación fiel de
una decisión de Wald en la familia de MDP correspondiente. Los protocolos
de este capítulo añaden disciplina para usar resultados estadísticos en
sistemas ejecutables; no amplían aquella representación a todos los agentes
ni convierten un informe favorable de simulación en una autorización general
de despliegue.

Al conservar ese registro, las preguntas que siguen abiertas quedan mejor delimitadas. Algunas requieren nuevos datos; otras, un modelo de observación o un resultado inferencial diferente. El último capítulo vuelve sobre ellas para precisar qué se ha resuelto en el recorrido y qué trabajo permitiría continuarlo.
