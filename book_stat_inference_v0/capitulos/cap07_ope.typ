#import "../plantilla.typ": *

// Se conservan los encabezados, su orden, etiquetas y alias del original.
// Convención temporal única: H decisiones, t=0,...,H-1.

= Evaluación off-policy
<ch:ope>
#chapter-alias("ch:ope-fundamentos")

Una política propuesta puede diferir de la que produjo los datos disponibles. Evaluar su valor exige relacionar esas dos formas de actuar antes de calcular un promedio. El método directo (DM) estima el valor por sustitución;
la ponderación por importancia (IS) cambia la medida de probabilidad;
el estimador doblemente robusto (DR) combina una predicción bajo la
política objetivo con una corrección residual. Cada procedimiento
requiere una justificación propia. Doble robustez no significa protección
frente a cualquier error ni garantiza menor varianza en toda muestra.

La representación del @ch:isomorfismo conserva el riesgo en un MDP de
un paso. Los resultados de este capítulo se justifican por identificación,
cambio de medida y teoría de estimación; no son corolarios automáticos
de aquella representación. Los límites del @ch:fallos orientan la lectura.

Una política de recomendación, asignación de recursos o seguimiento puede
proponer acciones distintas de las registradas. Comparar los promedios
observados entre quienes recibieron cada acción no reproduce necesariamente
el resultado de aplicar la política propuesta. La evaluación fuera de
política, u OPE, formula con precisión esa pregunta contrafactual.

La ponderación en aprendizaje por refuerzo aparece, entre otros trabajos,
en @precup2000eligibility. La combinación de regresión y ponderación se
desarrolla para bandits contextuales en @dudik2011doubly y para decisiones
secuenciales en @jiang2016doubly. La inferencia eficiente depende además
del modelo estadístico de trayectorias, como muestra @kallus2020double.
Estas contribuciones responden a problemas relacionados, pero no tienen
idénticas hipótesis ni el mismo estimador.

En SSCH, la motivación es evaluar una regla de seguimiento antes de
utilizarla. Los ejemplos serán sintéticos, con recompensas abstractas;
no aportan evidencia sobre tratamientos reales. El propósito es que el
lector pueda reconstruir cada estimación y localizar qué supuesto la
sostiene. Un registro clínico extenso no certifica por sí solo ausencia
de confusión no medida.

== Identificar el valor antes de estimarlo
<sec:ch10-teoria>

=== El Problema de Off-Policy Evaluation
<sec:ch10-problema>

#thm-env("definition", name: [Experimento y objetivo de OPE], key: "def:ch10-ope")[
  Se observan $n$ episodios iid
  $ O_i=(S_(i,0),A_(i,0),R_(i,0),dots.h,S_(i,H)), $
  de horizonte fijo $H$. Las acciones pertenecen a un conjunto finito;
  la política de registro es $b_t (a|s)$ y la política objetivo fija es
  $e_t (a|s)$. Ambas pueden variar con $t$. La distribución inicial
  común es $nu$ y el núcleo de recompensa y transición es
  $K_t (dif r,dif s'|s,a)$. Se supone $abs(R_t)<=R_*$ y
  $0<gamma<=1$ para los resultados acotados de este capítulo.

  El objetivo escalar es
  $ J(e)=EE_e (G)=integral v_0 (s) nu(dif s), $
  donde $v_t$ es el valor desde el tiempo $t$ bajo $e$. Estimar
  $v_0 (s_0)$ en un estado fijado es otro problema; no se obtiene
  promediando indiscriminadamente estados iniciales distintos.
]

Las funciones $b_t$ y $e_t$ equivalen a las políticas $pi_b$ y $pi_e$
de capítulos anteriores. Aquí se abrevian para hacer legibles los pesos.
Un episodio completo constituye una observación estadística; sus $H$
pasos no son $H$ observaciones independientes. El régimen de una sola
trayectoria larga requiere resultados diferentes.

#thm-env("definition", name: [Retorno y funciones de valor], key: "def:ch10-retorno")[
  $ G=sum_(t=0)^(H-1)gamma^t R_t, quad B_H=R_* sum_(t=0)^(H-1)gamma^t. $
  Así, $abs(G)<=B_H$. Con $v_H=0$,
  $ q_t (s,a)=EE[R_t+gamma v_(t+1) (S_(t+1))|S_t=s,A_t=a], $
  $ v_t (s)=sum_a e_t (a|s)q_t (s,a). $
  El modelo directo debe estimar estos valores futuros, no solo la
  recompensa inmediata cuando hay más de una decisión.
]

*Tres familias estadísticas.* Un MDP tabular de tamaño fijo tiene una
parametrización finita de sus transiciones y medias de recompensa;
la ley completa de las recompensas podría seguir sin parametrizarse.
Con estados continuos, estimar funciones libres de recompensa o transición
es un problema no paramétrico. Estimar $J(e)$, escalar, dentro de una
familia que contiene funciones desconocidas de dimensión infinita es un
problema semiparamétrico. El uso de una red neuronal no determina por sí
solo a cuál de estas familias pertenece el modelo.

=== Supuestos de Identificación
<sec:ch10-supuestos>

#assumption-env(name: [Consistencia e intervención bien definida], key: "ass:ch10-consistency")[
  Los estados y recompensas observados coinciden con sus resultados
  potenciales bajo la secuencia de acciones efectivamente recibida.
  Las versiones de cada acción están especificadas y no hay
  interferencia entre episodios. El resultado en $t$ puede depender
  de toda la secuencia previa: no se reduce en general a $R_t (a_t)$.
]

#assumption-env(name: [Soporte de la política objetivo], key: "ass:ch10-overlap")[
  En las historias alcanzables bajo $e$, toda acción con probabilidad
  objetivo positiva tiene probabilidad positiva bajo el registro.
  Con distribución inicial común y núcleos invariantes, esto asegura
  dominación de la ley objetivo por la ley registrada. Para las cotas
  acotadas se impondrá además $frac(e_t (a|s),b_t (a|s))<=C<infinity$ en el
  soporte pertinente. Esta restricción cuantitativa es más fuerte que
  la mera positividad.
]

#thm-env("definition", name: [Coeficiente de overlap], key: "def:ch10-rho-max")[
  $ rho_"max"=C=sup_(t,s,a) frac(e_t (a|s),b_t (a|s)), $
  tomando el supremo esencial en el soporte pertinente. En espacios
  finitos puede usarse el máximo. El mayor cociente observado en una
  muestra es un diagnóstico, no necesariamente esta cota poblacional.
]

#assumption-env(name: [Intercambiabilidad y estructura de Markov], key: "ass:ch10-markov")[
  Se distinguen dos requisitos. Primero, dado el historial previo a
  actuar, la acción registrada es independiente de los resultados
  potenciales futuros de las intervenciones consideradas
  —intercambiabilidad secuencial—. Segundo, el estado $S_t$ resume ese
  historial para el núcleo de recompensa y transición y para las
  políticas utilizadas. Los núcleos $K_t$ permanecen invariantes al
  sustituir $b$ por $e$.

  La propiedad de Markov observacional no implica ausencia de
  confusión. Con historias completas puede formularse el cambio de
  medida sin exigir un resumen de Markov; en tal caso también cambian
  los argumentos de las políticas y de las funciones de valor.
]

#thm-env("theorem", name: [Identificación del valor de una política], key: "thm:ch10-identificacion")[
  Bajo los supuestos anteriores, defina
  $ rho_t=frac(e_t (A_t|S_t),b_t (A_t|S_t)), quad
    W_t=product_(k=0)^t rho_k, quad W_(-1)=1. $
  Para retornos integrables bajo la ley objetivo,
  $ J(e)=EE_b (W_(H-1)G)=sum_(t=0)^(H-1)gamma^t EE_b (W_t R_t). $
]
#proof-env[
  La ley de un episodio se factoriza en distribución inicial, políticas
  y núcleos $K_t$. En el cociente de leyes se cancelan $nu$ y los
  núcleos, y queda $W_(H-1)$. Para la recompensa en $t$, basta el
  cociente de la historia que termina después de esa recompensa:
  $W_t$. Integrar respecto de cada ley proporciona ambas identidades.
  El argumento usa integrales y también cubre estados continuos.
]

La identificación es poblacional. La consistencia de un estimador, su
varianza finita y la cobertura de un intervalo son afirmaciones distintas.
Los supuestos causales no se verifican completamente con una tabla de
frecuencias o una métrica predictiva.

Una vez expresado el valor en términos de la ley observada, hay varias maneras de estimarlo. El método directo utiliza un modelo de valor; la ponderación cambia la medida con la que se promedian las trayectorias. Comparar ambos permite entender después la corrección residual de DR.

=== Direct Method (DM)
<sec:ch10-dm>

#thm-env("definition", name: [Estimador DM], key: "def:ch10-dm")[
  Ajuste $hat(q)_t$ por un modelo de transición y recompensa o por
  regresiones de Bellman hacia atrás; defina
  $ hat(v)_t (s)=sum_a e_t (a|s)hat(q)_t (s,a), quad hat(v)_H=0. $
  Sobre estados iniciales de evaluación independientes del ajuste,
  $ hat(J)_"DM"=1/n sum_(i=1)^n hat(v)_0 (S_(i,0)). $
  Si se usa cross-fitting, cada predicción procede de un ajuste que
  excluye el episodio completo que se evalúa.
]

#thm-env("proposition", name: [Error y variabilidad de DM], key: "prop:ch10-dm")[
  Condicionalmente en un ajuste independiente, su sesgo es
  $ EE_nu (hat(v)_0-v_0), $
  cuyo valor absoluto no supera
  $EE_nu (sum_a e_0 (a|S_0)abs(hat(q)_0 (S_0,a)-q_0 (S_0,a)))$.
  Su varianza condicional es $Var_nu (hat(v)_0 (S_0))/n$.
  La variabilidad total incluye además la del entrenamiento.
]

No estimar $b$ explícitamente es una ventaja de DM; no permite aprender
respuestas en regiones sin soporte sin restricciones extrapolativas.
En un modelo paramétrico mal especificado, el error puede persistir al
aumentar $n$. En una regresión no paramétrica, la complejidad, la suavidad
y el diseño determinan la precisión. Un buen ajuste de la recompensa
inmediata no garantiza una buena aproximación a $q_t$.

=== Importance Sampling (IS)
<sec:ch10-is>

#thm-env("definition", name: [Razón de importancia por trayectoria], key: "def:ch10-rho")[
  La razón completa es $W_(H-1)=product_(t=0)^(H-1)rho_t$.
  Los resultados exactos siguientes usan probabilidades de registro
  verdaderas, conocidas por diseño o como objetos teóricos. Reemplazarlas
  por estimaciones requiere otro análisis; no conserva automáticamente
  la insesgadez finita.
]

#thm-env("definition", name: [Estimador IS], key: "def:ch10-is")[
  $ hat(J)_"IS"=1/n sum_(i=1)^n W_(i,H-1)G_i. $
  Los pesos son no negativos y no se normalizan empíricamente en esta
  definición. El estimador autonormalizado divide $sum_i W_i G_i$
  por $sum_i W_i$; suele tener sesgo finito y requiere que el denominador
  sea positivo. Es un procedimiento diferente.
]

#thm-env("theorem", name: [Insesgadez de IS], key: "thm:ch10-is-insesgado")[
  Con pesos verdaderos y $EE_e (abs(G))<infinity$,
  $ EE_b (hat(J)_"IS")=J(e). $
  Si además $EE_b (W_(H-1)^2 G^2)<infinity$,
  $ Var_b (hat(J)_"IS")=frac(Var_b (W_(H-1)G),n). $
  La segunda condición no se necesita para la primera igualdad.
]
#proof-env[
  La esperanza de cada sumando coincide con $EE_e (G)$ por
  @thm:ch10-identificacion. La independencia entre episodios proporciona
  la fórmula de varianza. La ley de grandes números da consistencia
  bajo integrabilidad; insesgadez y consistencia no son sinónimos.
  #verdem(<dem:ch10-is-insesgado>)
]

#thm-env("definition", name: [Per-Decision IS (PDIS)], key: "def:ch10-pdis")[
  $ hat(J)_"PDIS"=1/n sum_(i=1)^n sum_(t=0)^(H-1)gamma^t W_(i,t)R_(i,t). $
  Es insesgado con pesos verdaderos bajo las mismas condiciones de
  identificación e integrabilidad de cada término. Elimina de una
  recompensa pasada los pesos de acciones futuras.
]

Cada término PDIS es la esperanza condicional del correspondiente término
IS dado el historial hasta esa recompensa. Su segundo momento no aumenta.
Esto no basta, por sí solo, para ordenar las varianzas de las sumas: también
intervienen covarianzas entre tiempos. Se debe evaluar el procedimiento
completo.

=== Curse-of-Horizon
<sec:ch10-curse>

#thm-env("theorem", name: [Cota de varianza y crecimiento posible], key: "thm:ch10-curse")[
  Si $abs(G)<=B_H$ y $rho_t<=C$, entonces
  $ Var_b (hat(J)_"IS")<=frac(B_H^2 C^H,n). $
  No se requiere independencia entre los pesos de distintos tiempos.
  Esta es una cota superior, no una tasa exacta ni una cota inferior.
]
#proof-env[
  Se tiene $0<=W_(H-1)<=C^H$ y $EE_b (W_(H-1))=1$, por lo que
  $EE_b (W_(H-1)^2)<=C^H$. Finalmente,
  $Var_b (W_(H-1)G)<=EE_b (W_(H-1)^2 G^2)<=B_H^2 C^H$.
  #verdem(<dem:ch10-curse>)
]

*Ejemplo exacto.* En un estado, con acciones iid Bernoulli de parámetros
$p$ bajo $e$ y $b$ bajo el registro, considere recompensa terminal uno,
las demás cero, y $gamma=1$. El valor es uno, pero IS tiene varianza
$ frac(c^H-1,n), quad c=frac(p^2,b)+frac((1-p)^2,1-b). $
La fórmula se obtiene multiplicando segundos momentos de pesos
independientes en este ejemplo específico. Con $p=0.8$, $b=0.5$ y
$H=10$, $c=1.36$ y la varianza por trayectoria es aproximadamente
$20.65$. Un modelo que conoce la recompensa constante evalúa el valor
sin esa variabilidad. La dificultad de IS no equivale a imposibilidad
universal de OPE.

#thm-env("corollary", name: [Implicación para el diseño de evaluación], key: "cor:ch10-curse")[
  En familias donde la varianza realmente crece como $c^H$, mantener
  un error estándar fijo exige un número de episodios del mismo orden.
  Una cota grande basada en $C$ alerta sobre un riesgo, pero no prueba
  que IS sea inutilizable en todos los modelos con ese horizonte.
]

PDIS, pesos de ocupación marginal, modelos de valor y controles de
varianza pueden ayudar bajo condiciones específicas. Recortar pesos
introduce sesgo. DR secuencial todavía puede contener productos de pesos;
no elimina automáticamente el crecimiento con el horizonte.

=== Distributional Shift: Cuando el Mundo Cambia
<sec:ch10-dist-shift>

OPE ya compara dos distribuciones diferentes: las inducidas por $b$ y
por $e$. Lo que se mantiene en el planteamiento básico es la distribución
inicial y el núcleo del entorno. Cambiar también la población inicial
introduce una diferencia adicional; cambiar el núcleo requiere aún más
información.

#thm-env("definition", name: [Cambio de población inicial], key: "def:ch10-covariate")[
  En el caso estudiado aquí, $nu_b$ es la distribución inicial del
  registro y $nu_*$ la de la población objetivo, con absoluta continuidad de $nu_*$ respecto de $nu_b$.
  Los núcleos $K_t$ permanecen invariantes. Defina
  $ u(s)=frac(dif nu_*,dif nu_b)(s). $
  Este cambio no debe confundirse con la diferencia de ocupaciones
  intermedias que las propias políticas generan.
]

#thm-env("proposition", name: [IS con cambio de población inicial], key: "prop:ch10-is-shift")[
  Si se conocen $u$ y las razones de política, y el retorno es integrable,
  $ J_*(e)=EE_b (u(S_0)W_(H-1)G). $
  El promedio de estas contribuciones es insesgado. Para su varianza
  se necesita el segundo momento conjunto de $u(S_0)W_(H-1)G$;
  no se puede factorizar sin condiciones adicionales.
]

Para ilustrar el efecto de $u$ aislado, si $G=1$ y $e=b$, la varianza
por observación de $u(S_0)$ es
$EE_(nu_b) (u^2)-1=chi^2(nu_*||nu_b)$: no es exponencial en esta
divergencia. Estimar $u$ agrega error y exige soporte y regularidad.

#thm-env("definition", name: [Evaluación y optimización robustas], key: "def:ch10-dro")[
  Para una política fija y un conjunto explícito de modelos plausibles
  $cal(U)$, la evaluación robusta de recompensa es
  $ J_"rob"(e)=inf_(P in cal(U)) J_P (e). $
  Seleccionar una política robusta supone además maximizar esa cantidad
  sobre las políticas permitidas. En términos de pérdidas, se minimiza
  el peor riesgo. No son el mismo objeto que un estimador puntual OPE.
]

#thm-env("proposition", name: [Alcance de una cota robusta], key: "prop:ch10-dro-garantia")[
  Si un conjunto aleatorio $cal(U)_n$ contiene el modelo verdadero de
  despliegue $P_*$ con probabilidad al menos $1-alpha$, entonces, para
  política fija,
  $ Prob(J_(P_*) (e)>=inf_(P in cal(U)_n)J_P (e))>=1-alpha. $
  *Demostración.* En el suceso $P_* in cal(U)_n$, el ínfimo no supera
  el valor del elemento $P_*$. La dificultad estadística es construir
  un conjunto con la cobertura anunciada, no esta desigualdad.
]

Una bola de KL, otra divergencia o Wasserstein requiere especificar su
centro, métrica, radio y justificación. No hay una cota universal de
producción que dependa solo de escribir un radio $epsilon.alt$. Las bolas
con divergencia $f$ respecto de una medida empírica pueden restringir
el soporte; una ley continua no pertenece automáticamente a ellas.
@duchi2021learning desarrolla garantías bajo condiciones propias de su
formulación, no para cualquier conjunto de incertidumbre.

#thm-env("example", name: [SSCH: cambio de composición poblacional], key: "ex:ssch-dist-shift-cap10", es-sintetico: true)[
  Dos estratos tienen valores condicionales conocidos $v_0=(2,6)$.
  El registro tiene proporciones $(0.8,0.2)$ y la población objetivo
  $(0.3,0.7)$. El valor registrado es $2.8$ y el objetivo es $4.8$.
  Los pesos iniciales son $(0.375,3.5)$, de modo que
  $ 0.8(0.375)2+0.2(3.5)6=4.8. $
  No corregir la población estima otro objetivo; la diferencia es dos
  unidades. No es un porcentaje obtenido de una simulación.

  Si solo se sabe que la proporción del segundo estrato está en
  $[0.6,0.8]$ y se mantienen los valores condicionales, el valor está
  en $[4.4,5.2]$. Es un rango de sensibilidad. Solo sería una región
  con cobertura estadística si también se justificara la cobertura
  del conjunto de proporciones y se incorporara el error al estimar
  los valores condicionales.
]

==== Distinguir población inicial y ocupación de estados
<sec:ch10-shift>

Al cambiar la población inicial aparece un segundo mecanismo de reponderación. El cambio de política no exige igualdad entre las leyes de entrenamiento
y de despliegue; precisamente se corrige su diferencia. La pregunta es
qué componentes del mecanismo siguen siendo transportables.

#thm-env("definition", name: [Dos razones de distribución distintas], key: "def:ch10-shift")[
  El peso $u=frac(dif nu_*,dif nu_b)$ corrige la población inicial. Una razón
  marginal $w_t=d_t^e/d_t^b$ compara ocupaciones de estado y acción en
  un tiempo dado. No son intercambiables. Si cambia además el núcleo
  de recompensa o transición, ninguno de esos cocientes aislados
  identifica automáticamente el valor en el nuevo entorno.
]

DRO constituye una posible formulación de sensibilidad o decisión robusta,
no una obligación ni una solución universal cuando se desconoce el cambio.
Su conexión con minimax de Wald exige especificar la familia de modelos
que se considera plausible. Un radio elegido sin justificación no crea
una garantía de desempeño.

#thm-env("example", name: [SSCH: cambio de población y de respuesta], key: "ex:ch10-shift-ssch", es-sintetico: true)[
  Retome los estratos de @ex:ssch-dist-shift-cap10. Si además del
  cambio a proporciones $(0.3,0.7)$, el valor del segundo estrato pasa
  de seis a cuatro, el valor nuevo es
  $0.3(2)+0.7(4)=3.4$. Reponderar únicamente la población inicial
  con el antiguo modelo produce $4.8$, una diferencia de $1.4$.
  Los mismos pesos iniciales no corrigen una respuesta condicional que
  ha cambiado.

  Un contraste de distribución de estados, como MMD con un kernel y
  calibración especificados, puede detectar diferencias en esos
  estados. No certifica invariancia de recompensas o transiciones,
  ni identifica por sí solo el efecto del cambio de política.
  No existe un umbral MMD universal de $0.05$: su escala depende,
  entre otros factores, del kernel. Véase @gretton2012kernel.
]

=== Doubly Robust (DR)
<sec:ch10-dr>

#thm-env("definition", name: [DR de una decisión y su extensión secuencial], key: "def:ch10-dr")[
  En una decisión, $m(s,a)=EE[R|S=s,A=a]$ y
  $hat(v)(s)=sum_a e(a|s)hat(m)(s,a)$. La contribución es
  $ D_i=hat(v)(S_i)+frac(e(A_i|S_i),hat(b)(A_i|S_i))(R_i-hat(m)(S_i,A_i)). $
  El promedio es $hat(J)_"DR"$. El primer término promedia acciones
  bajo $e$: no puede sustituirse por $hat(m)(S_i,A_i)$.

  Para $H$ decisiones, con modelos entrenados fuera del episodio $i$,
  defina $hat(W)_(i,t)$ mediante las propensiones estimadas y
  $ Delta_(i,t)=R_(i,t)+gamma hat(v)_(t+1) (S_(i,t+1))-hat(q)_t (S_(i,t),A_(i,t)). $
  La contribución secuencial y el estimador son
  $ D_i=hat(v)_0 (S_(i,0))+sum_(t=0)^(H-1)gamma^t hat(W)_(i,t)Delta_(i,t), $
  $ hat(J)_"DR"=1/n sum_(i=1)^n D_i. $
]

*Por qué importa el término inicial.* En un estado, sea $R=A$,
$b(1)=1/2$, $e(1)=3/4$ y modelo exacto $m(a)=a$. El residuo es cero.
El término correcto vale $3/4$, mientras que usar $m(A)$ produce media
$1/2$. Incluso un modelo perfecto falla con aquella fórmula incorrecta.

#thm-env("theorem", name: [Identidad de doble robustez], key: "thm:ch10-dr")[
  Para una decisión, trate $overline(m)$ y $overline(b)>0$ como funciones
  fijas independientes de la muestra de evaluación, y sea $D$ la
  contribución anterior con esas funciones. Entonces
  $ EE_b (D)-J(e)=EE_nu (sum_a e(a|S)
    frac(overline(b)(a|S)-b(a|S),overline(b)(a|S))
    (overline(m)(S,a)-m(S,a))). $
  Si todos los términos son integrables, el sesgo se anula cuando
  $overline(m)=m$ o $overline(b)=b$.
]
#proof-env[
  Condicione en $S$, promedie la acción con $b$ y sustituya
  $EE[R|S,A]=m(S,A)$. Al restar $sum_a e(a|S)m(S,a)$, se agrupan
  los errores con factor $1-b/overline(b)$. No se requiere que ambos
  modelos sean correctos. #verdem(<dem:ch10-dr>)
]

Con propensiones alejadas de cero, Cauchy–Schwarz acota el sesgo por un
producto de errores $L^2$. La insesgadez con funciones exactamente
correctas es distinta de la consistencia con funciones aprendidas.
Esta última requiere también una ley de grandes números y control de
los pesos. Para el estimador secuencial, con horizonte fijo, la misma
cancelación opera si todos los $q_t$ son correctos o todas las
propensiones son correctas; la demostración se presenta en el apéndice.
No significa que una única regresión correcta en un tiempo arbitrario
baste para todo el episodio.

#thm-env("proposition", name: [Inferencia eficiente en una decisión], key: "thm:ch10-dr-eficiencia")[
  Suponga episodios iid, acciones finitas, $e$ fija, recompensas y
  regresiones ajustadas uniformemente acotadas, y $b,hat(b)>=epsilon.alt>0$.
  Use un número fijo de folds de tamaños proporcionales a $n$, con
  separación por episodios. En cada fold, los dos errores $L^2$
  convergen a cero y su producto es $o_P (n^(-1/2))$, para la norma
  respecto de $nu(s)e(a|s)$. Si la varianza indicada abajo es positiva,
  $ sqrt(n)(hat(J)_"DR"-J)=1/sqrt(n)sum_(i=1)^n phi(O_i)+o_P (1), $
  $ phi(O)=v(S)-J+frac(e(A|S),b(A|S))(R-m(S,A)). $
  En el modelo observado no paramétrico de una decisión, $phi$ es el
  gradiente canónico. Su varianza es la cota de eficiencia para
  estimadores regulares; la varianza muestral de las contribuciones
  cross-fitted estima esa varianza bajo estas condiciones.
]
#verdem(<dem:ch10-dr-eficiencia>)

La eficiencia exige más que doble robustez. Tener un componente correcto
y otro convergente a una función incorrecta puede dar consistencia sin
la función de influencia eficiente anterior. Dos errores
$O_P (n^(-1/4))$ no garantizan el pequeño orden de su producto; tasas
algo más rápidas o un argumento adicional pueden proporcionarlo.

Para un MDP finito en horizonte con núcleos temporales sin restricciones
adicionales y distribución inicial desconocida, la función eficiente
usa razones marginales de ocupación $w_t=d_t^e/d_t^b$ en lugar de
$W_t$. El @ch:semiparametrica especifica ese modelo y la expansión
correspondiente. El estimador secuencial por productos presentado aquí
no debe declararse eficiente en todo modelo Markov por llevar el nombre DR.

#thm-env("example", name: [DR puede aumentar la varianza], key: "prop:ch10-var-dr")[
  Sea $R=0$ siempre, $b(1)=1/2$ y $e(1)=1$. Con modelo
  $overline(m)(a)=1$ para ambas acciones y propensión correcta,
  $D=1-2A$, cuya media es cero y varianza uno. IS es idénticamente
  cero. El modelo es no nulo y tiene error cuadrático finito, pero
  aumenta la varianza. Un residuo útil puede reducirla; esa reducción
  no está garantizada para una aproximación arbitraria.
]

#mi-figura(
  caption: [Elección de estimador después de justificar identificación. Las condiciones son requisitos de análisis, no umbrales automáticos de cobertura.],
  key: "fig:ch10-arbol-ope",
  table(columns: (18%, 40%, 1fr), align: left, hl(),
    table.header([*Ruta*], [*Información utilizada*], [*Comprobación adicional*]), hl(w: 0.6pt),
    [DM], [Modelo de valor de la política objetivo.], [Error de aproximación y del entrenamiento.],
    [IS / PDIS], [Probabilidades de registro y objetivo.], [Momentos de pesos y retornos; soporte.],
    [DR], [Modelo de valor y corrección ponderada.], [Resto, separación muestral y varianza del estimador concreto.],
    [IS recortado], [Pesos limitados por un umbral.], [Sesgo añadido y regla de elección del umbral.], hl(),
  ),
)

=== Comparación de Estimadores
<sec:ch10-comparacion>

#thm-env("note", name: [Compromisos entre sesgo y varianza], key: "thm:ch10-tradeoff")[
  #table(columns: (15%, 43%, 1fr), align: left, hl(),
    table.header([*Método*], [*Base de la validez*], [*Riesgo principal*]), hl(w: 0.6pt),
    [DM], [Valor ajustado que converge al objetivo.], [Sesgo de modelo y extrapolación.],
    [IS], [Cambio de medida con pesos verdaderos.], [Concentración de pesos y segundos momentos grandes.],
    [PDIS], [Cambio de medida hasta cada recompensa.], [Persistencia de pesos acumulados y covarianzas temporales.],
    [DR], [Cancelación residual bajo una de las dos familias correctas.], [Ambas familias incorrectas; resto o varianza sin controlar.], hl(),
  )
]

No hay un orden universal de varianzas «baja, media, alta». Comparar
estimaciones sobre los mismos episodios es útil para diagnosticar
sensibilidad, pero la coincidencia de DM, IS y DR no demuestra ausencia
de confusión o validez de los intervalos. Tampoco debe elegirse el método
por el intervalo más favorable y luego interpretar su cobertura como
si la elección hubiera sido previa.

La comparación entre estimadores vuelve sobre la misma restricción de información: los datos deben representar las acciones que necesita la política objetivo. Los diagnósticos siguientes permiten examinar cómo aparece esa dificultad en la muestra y qué decisiones de análisis obliga a revisar.

=== Diagnósticos de Overlap
<sec:ch10-diagnosticos>

#thm-env("definition", name: [Tamaño efectivo basado en pesos], key: "def:ch10-ess")[
  Para pesos no negativos $w_i$ con suma positiva,
  $ "ESS"=frac((sum_i w_i)^2,sum_i w_i^2). $
  Está entre uno y $n$. Describe concentración de estos pesos, no
  certifica soporte poblacional ni la información efectiva de cualquier
  estimador. Si todos los pesos son cero, la expresión no está definida.
]

Conviene indicar si se calcula con $W_(H-1)$, con $W_t$ por tiempo o con
razones marginales. Para los cuatro pesos $(0.25,0.75,0.75,2.25)$,
la suma es cuatro, la suma de cuadrados $6.25$ y el ESS es $2.56$.
La media y el máximo no determinan por sí solos la suma de cuadrados.
Un ESS elevado también puede coexistir con una región objetivo nunca
representada en la muestra.

=== Protocolo de Fallback ante Overlap Insuficiente
<sec:ch10-fallback>

La respuesta depende de si faltan datos, si el modelo impone restricciones
extrapolativas o si existe información pero está muy concentrada. Cambiar
el estimador no restituye soporte ausente.

#thm-env("definition", name: [Estados de la evaluación de soporte], key: "def:ch10-niveles")[
  + *Soporte justificado:* proviene del diseño o de supuestos explícitos;
    se examina además la concentración de pesos.
  + *Concentración preocupante:* pocas trayectorias dominan los pesos;
    se estudia sensibilidad sin deducir automáticamente invalidez.
  + *Soporte no establecido:* la muestra y la información de diseño no
    permiten justificar la condición poblacional.
  + *Falta de soporte conocida:* una región visitada por $e$ tiene
    probabilidad cero bajo el registro. Sin restricciones adicionales,
    el valor completo puede no estar identificado.
]

#thm-env("theorem", name: [Sesgo y varianza por truncamiento], key: "thm:ch10-truncamiento")[
  Sea $W=W_(H-1)$ verdadero, $abs(G)<=B_H$ y $M>0$ fijo. Para
  $hat(J)_M=n^(-1)sum_i min(W_i,M)G_i$,
  $ abs(EE_b (hat(J)_M)-J)<=B_H EE_b ((W-M)_+), $
  $ Var_b (hat(J)_M)<=frac(B_H^2 min(M^2,M),n). $
  El sesgo depende de la masa ponderada de la cola, no solo de
  $Prob_b (W>M)$.
]
#proof-env[
  Reste $EE_b (W G)$ y aplique valor absoluto. Para la varianza,
  $min(W,M)^2<=M^2$ y también $min(W,M)^2<=M W$, con $EE_b (W)=1$.
  Un umbral fijo generalmente mantiene sesgo al aumentar $n$.
  Si $M_n$ es determinista, $M_n->infinity$ y $M_n/n->0$, la cota
  de varianza tiende a cero y el sesgo también, por convergencia
  dominada de $(W-M_n)_+$ cuando el experimento y $H$ permanecen fijos.
]

#thm-env("note", name: [Elección del umbral], key: "prop:ch10-truncamiento")[
  Recortar en el percentil 95 no asegura sesgo pequeño. Un percentil
  muestral es aleatorio y las cotas para $M$ fijo no se trasladan
  automáticamente a una elección sobre la misma muestra. Puede
  prefijarse una rejilla, usar datos independientes para elegir o
  desarrollar un resultado uniforme que cubra la selección.
  Reportar estabilidad ante varios umbrales es un diagnóstico, no
  una demostración de cobertura.
]

*Ejemplo de cola rara.* Si $e(1)=1$, $b(1)=0.01$ y $R=A$, entonces
$W=100$ con probabilidad $0.01$ y cero en otro caso. El valor es uno.
Recortar en $M=10$ produce esperanza $0.1$: sesgo $-0.9$ aunque
$Prob(W>M)=0.01$. La cota correcta usa
$EE((W-10)_+)=0.9$.

*Árbol de respuesta:*
```
Si falta soporte poblacional:
    delimitar población/política evaluable, o presentar cotas y supuestos
Si el soporte existe pero los pesos se concentran:
    comparar métodos y sensibilidad; revisar momentos y error de modelo
Si se recortan pesos:
    registrar umbral, criterio de elección y tratamiento del sesgo
Emitir un intervalo nominal solo con una justificación inferencial aplicable
```
Un intervalo multiplicado por $1.5$ no tiene cobertura garantizada por
ese factor. Una estimación DM puede presentarse como extrapolación
condicionada al modelo, no como reparación automática de identificación.

=== Verificación en Línea de Supuestos
<sec:ch10-verificacion>

Monitorear aporta evidencia sobre incompatibilidades, pero observar
continuamente y detenerse al obtener un resultado favorable modifica el
procedimiento. Los intervalos de tamaño fijo no son automáticamente
válidos bajo parada opcional.

#thm-env("definition", name: [Indicadores de monitoreo], key: "def:ch10-indicadores")[
  Registrar pesos por acción y acumulados, máximo observado, ESS por
  horizonte, cuantiles, fracción de peso concentrada en pocos episodios,
  ocupaciones por estado y residuos de Bellman. Para pesos de media
  positiva puede calcularse su coeficiente de variación. Examinar la
  dependencia entre unidades cuando estas no sean episodios independientes.
]

#thm-env("note", name: [Calibración de alertas], key: "prop:ch10-umbrales")[
  Los umbrales operativos se fijan antes de la evaluación y se calibran
  respecto de escenarios, tamaño de muestra, política y costo del error.
  Una alerta indica revisión; su ausencia no acredita una garantía.
  No hay valores universales de ESS, peso máximo o autocorrelación
  que certifiquen identificación, mixing o cobertura del 95%.
]

#thm-env("example", name: [Pipeline de monitoreo], key: "ex:ch10-pipeline")[
  ```
  AL CERRAR UN EPISODIO:
      validar horizonte, acciones, recompensas y probabilidades registradas
      guardar versión de la política y población inicial de evaluación
      actualizar pesos acumulados y diagnósticos por tiempo
      contrastar con los criterios operativos fijados previamente
      si hay alerta: emitir diagnóstico y análisis de sensibilidad
      en el punto de análisis previsto:
          calcular estimador, varianza por episodio y alcance de la inferencia
  ```
  Si la política de registro se adapta entre episodios usando resultados
  previos, conservar sus probabilidades condicionales reales. El régimen
  iid planteado al inicio deja de ser aplicable sin una justificación
  específica para esos datos adaptativos.
]

#mi-tabla(
  caption: [Respuesta a dificultades de evaluación], key: "tab:ch10-respuesta",
  table(columns: (24%, 33%, 1fr), align: left, hl(),
    table.header([*Situación*], [*Qué compromete*], [*Respuesta*]), hl(w: 0.6pt),
    [Soporte ausente], [Identificación sin extrapolación.], [Restringir objetivo, justificar modelo o presentar cotas.],
    [Pesos concentrados], [Precisión de ciertos estimadores.], [Examinar segundos momentos, sensibilidad y diseño de datos.],
    [Dependencia no modelada], [Varianza e inferencia.], [Usar unidades y teoremas apropiados.],
    [Cambio del entorno], [Transportabilidad del valor.], [Separar población inicial de cambios del núcleo.],
    [Modelo de valor deficiente], [DM y parte de DR.], [Revisar ajuste y soporte; usar ponderación solo si está justificada.], hl(),
  ),
)

== Convertir la evaluación en una decisión documentada
<sec:ch10-langgraph>

El agente debe conservar un registro que permita reconstruir la pregunta
estadística: versión de $e$, horizonte, descuento, definición de recompensa,
población inicial, unidad independiente, probabilidades registradas y
particiones de entrenamiento. La identificación se documenta antes de
seleccionar el estimador. Un nodo de diagnóstico no puede comprobar por
sí solo intercambiabilidad ni corregir un estado insuficiente.

Una implementación separa validación de episodios, entrenamiento de
funciones auxiliares, cálculo de contribuciones, diagnóstico e informe.
Los modelos se entrenan fuera de los episodios en que se evalúan sus
residuos. El informe distingue estimación, error estándar, evidencia de
soporte y supuestos no contrastables. El Laboratorio
#ref(<lab:F10>, supplement: none) del Apéndice
#ref(<app:laboratorio>, supplement: none) es el lugar de integración;
su implementación debe respetar estas fórmulas y no reutilizar reglas
que conviertan ESS en una certificación automática.

#[
#set heading(numbering: none, outlined: false)
=== Hilo longitudinal: SSCH
]

#thm-env("example", name: [SSCH: dos decisiones con cálculo completo], key: "ex:ssch-cap10", es-sintetico: true)[
  Considere dos visitas, un estado y acciones binarias independientes
  entre visitas bajo cada política. La recompensa abstracta es
  $R_t=A_t$, $gamma=0.9$, $b_t (1)=0.5$ y $e_t (1)=0.75$.
  El valor exacto es
  $ J(e)=0.75+0.9(0.75)=1.425. $
  Use modelos fijados independientemente de los episodios:
  $hat(q)_1 (a)=0.2+0.6a$, por lo que $hat(v)_1=0.65$, y
  $hat(q)_0 (a)=0.1+0.8a+0.9(0.65)=0.685+0.8a$.
  Entonces $hat(v)_0=1.285$. No son los modelos verdaderos.

  Cada trayectoria binaria tiene probabilidad $1/4$ bajo $b$.
  Los cocientes por acción son $0.5$ para cero y $1.5$ para uno.
  La tabla enumera contribuciones, no resultados de una corrida aleatoria.

  #table(columns: (auto, auto, auto, auto, auto), align: right, hl(),
    table.header([*$(A_0,A_1)$*], [*$W_1$*], [*IS*], [*PDIS*], [*DR*]), hl(w: 0.6pt),
    [$(0,0)$], [0.25], [0], [0], [1.190],
    [$(0,1)$], [0.75], [0.675], [0.675], [1.370],
    [$(1,0)$], [0.75], [0.750], [1.500], [1.300],
    [$(1,1)$], [2.25], [4.275], [3.525], [1.840], hl(),
  )

  Para $(1,0)$, el retorno es uno. IS vale $0.75$ y PDIS vale
  $1.5$. Los residuos de DR son $0.1$ y $-0.2$, de donde
  $ D=1.285+1.5(0.1)+0.9(0.75)(-0.2)=1.300. $
  Al promediar las cuatro filas con probabilidad $1/4$, IS, PDIS y
  DR dan $1.425$; DM permanece en $1.285$. La diferencia de DM es
  $-0.140$. Las varianzas exactas por episodio son, respectivamente,
  $2.7928125$, $1.7521875$ y $0.061525$. Para $n$ episodios iid y estos
  modelos fijos, cada varianza del promedio se divide por $n$.

  La menor varianza de DR en este ejemplo se debe al ajuste y al modelo
  concretos. No demuestra un orden universal ni proporciona un
  intervalo clínico. Si se usaran los valores verdaderos,
  $q_1 (a)=a$ y $q_0 (a)=a+0.675$, ambos residuos serían cero y DR
  devolvería $1.425$ en todos los episodios de este entorno determinista.
]

#[
#set heading(numbering: none, outlined: false)
=== Conexión con el @ch:inferencia
]

El próximo capítulo estudia cómo cuantificar la incertidumbre del valor.
Para episodios iid, se trabaja con contribuciones por episodio; no hace
falta declarar que todos los pasos son independientes. Para una trayectoria
larga, la varianza puede requerir autocovarianzas o una representación
martingala. El régimen muestral determina la herramienta.

En estimadores aprendidos, el intervalo necesita además controlar el
resto de estimación de las funciones auxiliares. La eficiencia
semiparamétrica de OPE y los resultados de aproximación de funciones de
valor son desarrollos diferentes: no debe atribuirse a cualquier teorema
de evaluación una función eficiente o un bootstrap que no establece.

Al comparar dos políticas sobre los mismos episodios se usa la
variabilidad de la diferencia de contribuciones, incluida su covarianza.
Si la política se elige con esos datos, debe separarse la evaluación o
emplearse inferencia apropiada para la selección. Una estimación puntual
mayor que la de referencia no basta para autorizar un despliegue.

== Ejercicios
<sec:ch10-ejercicios>

#exercise-env(key: "ex:ch10-ej1")[
  Factorice la ley de una trayectoria con $H$ decisiones y demuestre
  las dos identidades de @thm:ch10-identificacion. Distinga la condición
  para esperanza finita de la necesaria para varianza finita. Explique
  qué cambia si la distribución inicial objetivo es diferente.
]

#exercise-env(key: "ex:ch10-ej2")[
  Suponga $abs(G)<=1$, $C=2$ y $H=20$. Calcule la cota superior de
  varianza de IS y un tamaño suficiente según esa cota para que sea
  menor que uno. Explique por qué no es un tamaño necesario. Construya
  un caso de recompensa cero que impida interpretar la cota como
  crecimiento obligatorio de la varianza.
]

#exercise-env(key: "ex:ch10-ej3")[
  Derive la identidad de sesgo de DR en una decisión. En un estado,
  tome $b(1)=1/2$, $e(1)=1$, $m(1)=1$, $overline(b)(1)=1/4$ y
  $overline(m)(1)=0$. Calcule esperanza y sesgo de DR. Compare con
  el caso en que solo una de las funciones coincide con la verdadera.
]

#exercise-env(key: "ex:ch10-ej4")[
  Cien pesos tienen media $1.5$ y máximo $50$. Explique por qué esto
  no determina el ESS. Calcule el ESS si los otros 99 pesos son
  $100/99$; compárelo con el de tres pesos iguales a $50$ y los
  restantes cero. Interprete qué información adicional se necesita
  para evaluar soporte poblacional.
]

#exercise-env(key: "ex:ch10-ej5")[
  Se dispone de mil episodios, cien decisiones por episodio, un
  máximo observado de cocientes igual a cinco y un modelo con
  $R^2=0.7$. Explique por qué estos datos no bastan para escoger un
  estimador con garantía. Diseñe la ficha de evaluación, incluyendo
  objetivo, identificación, pesos por horizonte, separación muestral,
  modelo de valor, sesgo por recorte y método de incertidumbre.
]

== Lecturas Propuestas
<sec:ch10-lecturas>

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Obligatorias
]

+ #cite(<jiang2016doubly>): estimación DR secuencial; distinguir los supuestos
  de insesgadez de los escenarios donde se alcanza una cota de varianza.
+ #cite(<dudik2011doubly>): evaluación y aprendizaje en bandits contextuales;
  identificar el promedio inicial bajo la política objetivo.
+ #cite(<thomas2015high>): evaluación con alta confianza; examinar las
  condiciones concretas de las cotas, no solo el valor estimado.

#[
#set heading(numbering: none, outlined: false)
=== Lecturas Complementarias
]

+ @kallus2020double y #cite(<kallus2022efficiently>): razones marginales,
  modelos de trayectorias y eficiencia; diferenciar horizontes finitos
  de formulaciones estacionarias.
+ #cite(<liu2018breaking>): evaluación mediante distribuciones de ocupación.
+ #cite(<duchi2021learning>): construcción y alcance de objetivos robustos.
+ @sugiyama2012machine y #cite(<quinonero2009dataset>): cambios de distribución
  y condiciones de transporte; @gretton2012kernel para contrastes de
  dos muestras basados en kernels.
