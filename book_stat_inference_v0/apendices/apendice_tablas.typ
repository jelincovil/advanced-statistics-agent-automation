// Puerto de apendices/apendice_tablas.tex — Tablas de Correspondencia.
#import "../plantilla.typ": *

= Tablas de Correspondencia
<app:tablas>

Las tablas permiten volver de un componente del agente al concepto estadístico que interviene en él. Se utilizan como material de consulta junto con el @ch:isomorfismo y el @ch:verificacion: una correspondencia orienta la lectura, y su conclusión precisa se determina en el resultado citado.

== Correspondencias entre la decisión y su representación
<app:tab-isomorfismo>  // nombre heredado; el título dice «incrustación fiel»

La primera tabla recorre los objetos que relacionan la decisión de Wald y su representación. Para la identidad exacta entre riesgo y retorno se consulta el @thm:ch9-isomorfismo; los límites de la extensión se precisan en la @note:ch9-extension-no-demostrada.

#mi-tabla(
  caption: [Incrustación fiel Wald $arrow.l.r$ MDP: correspondencias y su estatus],
  key: "tab:app-isomorfismo-completo",  // nombre heredado; el título dice «incrustación fiel»
  table(
    columns: (22%, 24%, 1fr, 8%),
    align: (left, left, left, center),
    hl(),
    table.header([*Wald*], [*MDP*], [*Interpretación*], [*Consulta*]),
    hl(w: 0.6pt),
    table.cell(colspan: 4)[_Espacios fundamentales_],
    [Espacio paramétrico $Theta$], [Estado oculto del entorno (POMDP) / índice del núcleo $P_theta$ (MDP robusto/bayesiano-adaptativo)], [Verdad subyacente a inferir; nunca el estado observado $cal(S)$], [#ref(<ch:arquitectura>, supplement: none)],
    [Espacio muestral $cal(X)$], [Espacio de observaciones], [Datos/percepciones], [#ref(<ch:arquitectura>, supplement: none)],
    [Espacio de acciones $cal(A)$], [Espacio de acciones $cal(A)$], [Decisiones disponibles], [#ref(<ch:wald>, supplement: none)],
    [Modelo $P_theta$], [Ley inicial de la representación], [Familia de MDP de una decisión], [#ref(<ch:mdp-bellman>, supplement: none)],
    table.cell(colspan: 4)[_Funciones de evaluación_],
    [Pérdida $L(theta, a)$], [Recompensa negativa $-r(s,a)$], [Costo de decisión], [#ref(<ch:wald>, supplement: none)],
    [Riesgo $R(theta, delta)$], [Costo esperado], [$EE[L]$ vs $-EE[r]$], [#ref(<ch:wald>, supplement: none)],
    [Riesgo de Bayes $r(delta, pi)$], [Valor bajo prior], [Evaluación global], [#ref(<ch:wald>, supplement: none)],
    [Riesgo minimax], [Valor adversarial], [Peor caso garantizado], [#ref(<ch:wald>, supplement: none)],
    table.cell(colspan: 4)[_Estrategias_],
    [Regla de decisión $delta$], [Política $pi$], [Mapeo observación $arrow.r$ acción], [#ref(<ch:isomorfismo>, supplement: none)],
    [Estimador $hat(theta)$], [Actor (determinista)], [Aproximación puntual], [#ref(<ch:estimacion>, supplement: none)],
    [Regla aleatorizada], [Política estocástica], [$pi(a mid(|) s)$], [#ref(<ch:isomorfismo>, supplement: none)],
    [Regla de Bayes $delta^*$], [Política óptima $pi^*$], [Minimiza riesgo esperado], [#ref(<ch:isomorfismo>, supplement: none)],
    table.cell(colspan: 4)[_Principios de optimalidad_],
    [Admisibilidad], [Pareto-optimalidad], [No dominancia estricta], [#ref(<ch:wald>, supplement: none)],
    [Clase completa], [Clase que domina las reglas externas], [No exige que cada miembro sea admisible], [#ref(<ch:wald>, supplement: none)],
    [Teorema de clase completa], [Sin equivalencia general con Bellman], [Comparación global de riesgos], [#ref(<ch:isomorfismo>, supplement: none)],
    table.cell(colspan: 4)[_Reducción de información_],
    [Estadístico suficiente $T(X)$], [Resumen para un parámetro], [La propiedad predictiva se verifica aparte], [#ref(<ch:reduccion>, supplement: none)],
    [Suficiencia minimal], [Reducción estadística minimal], [No caracteriza un estado de control], [#ref(<ch:reduccion>, supplement: none)],
    [Completitud], [Unicidad de funciones insesgadas de $T$], [No equivale a identificabilidad], [#ref(<ch:reduccion>, supplement: none)],
    table.cell(colspan: 4)[_Eficiencia y cotas_],
    [Cota de Cramér-Rao], [Cota de varianza], [Límite inferior], [#ref(<ch:estimacion>, supplement: none)],
    [UMVUE], [Estimador insesgado de mínima varianza], [Dentro de la clase insesgada], [#ref(<ch:estimacion>, supplement: none)],
    [IF eficiente $phi^*$], [Gradiente canónico del funcional], [Determina la cota de varianza], [#ref(<ch:semiparametrica>, supplement: none)],
    [Eficiencia semiparamétrica], [Eficiencia relativa], [$"Var"\/"Var"^*$], [#ref(<ch:semiparametrica>, supplement: none)],
    table.cell(colspan: 4)[_Inferencia y evaluación_],
    [Test de hipótesis], [Clasificación de políticas], [$H_0: V^pi lt.eq V^(pi_0)$], [#ref(<ch:tests>, supplement: none)],
    [Intervalo de confianza], [IC para $V^pi$], [Cuantificación de incertidumbre], [#ref(<ch:inferencia>, supplement: none)],
    [Off-Policy Evaluation], [Evaluación contrafactual], [$V^pi$ desde datos de $mu$], [#ref(<ch:ope>, supplement: none)],
    [Estimador DR], [AIPW para MDPs], [Robustez doble], [#ref(<ch:ope>, supplement: none)],
    hl(),
  ),
)

== Correspondencia de Estimadores
<app:tab-estimadores>

La siguiente tabla detalla los estimadores principales y sus análogos
en el contexto de evaluación de políticas.

#mi-tabla(
  caption: [Correspondencia de Estimadores],
  key: "tab:app-estimadores",
  table(
    columns: (22%, 20%, 1fr, 10%),
    align: (left, left, left, center),
    hl(),
    table.header([*Estadística Clásica*], [*OPE/RL*], [*Expresión*], [*Consulta*]),
    hl(w: 0.6pt),
    [Media muestral $macron(X)$], [Monte Carlo], [$1/n sum_i G_i$], [#ref(<ch:asintotica>, supplement: none)],
    [MLE $hat(theta)_"ML"$], [MLE de $P$, $r$], [$argmax ell (theta)$], [#ref(<ch:estimacion>, supplement: none)],
    [Horvitz-Thompson], [IPW de una decisión], [$1/n sum_i (pi(a_i|s_i))/(mu(a_i|s_i)) r_i$], [#ref(<ch:ope>, supplement: none)],
    [Regresión ajustada], [DM de una decisión], [$1/n sum_i sum_a pi(a|s_i)hat(q)(s_i,a)$], [#ref(<ch:ope>, supplement: none)],
    [AIPW], [DR para $V^pi$], [$hat(V)_"DM" + hat(V)_"IPW" - hat(V)_"DM,IPW"$], [#ref(<ch:ope>, supplement: none)],
    [Aumento por regresión], [DR con $hat(Q)$], [Doble robustez bajo sus condiciones; no garantiza menor varianza para cualquier ajuste], [#ref(<ch:ope>, supplement: none)],
    [Bootstrap percentil], [Bootstrap para IC], [$[hat(V)^*_(alpha\/2), hat(V)^*_(1-alpha\/2)]$], [#ref(<ch:asintotica>, supplement: none)],
    hl(),
  ),
)

== Correspondencia de Condiciones de Regularidad
<app:tab-regularidad>

La inferencia válida requiere condiciones de regularidad. La
siguiente tabla las unifica entre los marcos.

#mi-tabla(
  caption: [Condiciones de Regularidad],
  key: "tab:app-regularidad",
  table(
    columns: (26%, 30%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Condición Clásica*], [*Análogo OPE*], [*Implicación*]),
    hl(w: 0.6pt),
    [Soporte objetivo cubierto], [Overlap: $pi lt.double mu$], [$pi(a|s) > 0 arrow.double mu(a|s) > 0$ en los estados pertinentes],
    [Identificabilidad], [Modelo observado e intervención especificados], [Positividad es un requisito de algunas rutas, no identificación general],
    [Regularidad inferencial], [Momentos, tasas y dependencia controlados], [La suavidad aislada no garantiza un CLT],
    [Momentos finitos], [$EE[rho^2 r^2] < infinity$], [Varianza finita de IPW],
    [iid], [Trayectorias independientes], [Agregación válida],
    [Estacionariedad del proceso], [Kernel homogéneo e inicio invariante], [Un kernel constante no fija la ley inicial],
    [Ergodicidad y mixing], [Propiedades distintas del proceso], [Ergodicidad sola no implica mixing],
    hl(),
  ),
)

// Fix M6 (Entrega 8.B): la tabla E.4 usa el triplete genérico
// "Ergodicidad → Mixing → Convergencia" sin distinguir que para el
// resultado ancla de la Parte III (SZLS, Teorema 1), la ergodicidad es
// prescindible cuando T es acotado. Agregada nota remitiendo al
// catálogo A1-A5 corregido.
#thm-env("note", name: [Catálogo A1–A5 para SZLS], key: "note:appE-A1-A5")[
  La tabla anterior resume condiciones _genéricas_. Para el resultado
  ancla de la Parte III (Teorema 1 de SZLS, @ch:inferencia), las
  condiciones precisas son *MA* (Markov), *CMIA* (independencia
  condicional en media), *A1* (suavidad Hölder), *A2* (distribución
  invariante), *A3* (invertibilidad de $Sigma_policy$; ergodicidad
  geométrica _solo si_ $T -> infinity$), *A4* (tasa de estimación de
  política) y *A5* (margen). La ergodicidad es *prescindible* cuando
  $T$ es acotado — el TLC de martingala de SZLS no la requiere en ese
  régimen. Ver @ch:inferencia, §11.2 para el enunciado formal.
]

== Correspondencia de Cotas y Tasas
<app:tab-cotas>

#mi-tabla(
  caption: [Cotas de Eficiencia y Tasas de Convergencia],
  key: "tab:app-cotas",
  table(
    columns: (18%, 30%, 1fr, 10%),
    align: (left, left, left, center),
    hl(),
    table.header([*Cota/Tasa*], [*Expresión*], [*Contexto OPE*], [*Consulta*]),
    hl(w: 0.6pt),
    [Cramér-Rao], [$nabla g^top I_n(theta)^(-1)nabla g$], [Cota para estimadores insesgados de $g(theta)$ en un experimento regular], [#ref(<ch:estimacion>, supplement: none)],
    [Eficiencia semiparam.], [$sigma_*^2 = EE[(phi^*)^2]$], [Varianza del límite a escala $sqrt(n)$; varianza del estimador aproximadamente $sigma_*^2/n$], [#ref(<ch:semiparametrica>, supplement: none)],
    [Tasa paramétrica], [$O_P(n^(-1\/2))$], [Error estocástico bajo regularidad], [#ref(<ch:asintotica>, supplement: none)],
    [Tasa no paramétrica], [Depende de norma, suavidad y modelo], [No hay una tasa universal], [#ref(<ch:semiparametrica>, supplement: none)],
    [Tasa DML], [Producto de errores $o_P(n^(-1/2))$], [Más consistencia, momentos y partición válida], [#ref(<ch:inferencia>, supplement: none)],
    hl(),
  ),
)

== Glosario de Términos
<sec:glosario-tablas>

/ Admisibilidad: Una regla de decisión $delta$ es admisible si no
  existe otra regla $delta'$ que la domine uniformemente en riesgo.

/ AIPW: _Augmented Inverse Probability Weighting_. Estimador que
  combina IPW con un modelo de regresión, logrando robustez doble.

/ "Bellman, Operador de": Operador $cal(T)$ definido por
  $(cal(T)V)(s) = max_a [r(s,a) + gamma sum_(s') P(s'|s,a) V(s')]$.
  Su punto fijo es $V^*$.

/ "Clase Completa": Conjunto de reglas de decisión tal que para
  cualquier regla fuera del conjunto existe una dentro que la domina.

/ Completitud: Un estadístico $T$ es completo si $EE_theta [g(T)] =
  0$ para todo $theta$ implica $g(T) = 0$ c.s.

/ "Cramér-Rao, Cota de": Cota inferior para la varianza de estimadores
  insesgados: $"Var"(hat(theta)) gt.eq I(theta)^(-1)$.

/ Cross-fitting: Técnica de partición de datos para estimar funciones
  auxiliares fuera del fold evaluado. Facilita el control empírico, pero no elimina todo sobreajuste ni sustituye hipótesis de tasas e independencia.

/ DML: _Double/Debiased Machine Learning_. Marco para inferencia
  válida usando estimadores de ML para funciones nuisance.

/ DR: _Doubly Robust_. Propiedad de consistencia bajo especificación
  correcta de al menos uno de dos modelos.

/ "Eficiencia Semiparamétrica": Lograr la cota de varianza mínima
  dentro de la clase de estimadores regulares asintóticamente
  lineales.

/ "Función de Influencia": Derivada funcional del funcional
  estadístico, caracteriza el comportamiento asintótico del
  estimador.

/ IPW: _Inverse Probability Weighting_. Reponderar observaciones por
  el inverso de la probabilidad de tratamiento/acción.

/ "Isomorfismo (en este libro)": Incrustación fiel que preserva
  operaciones entre dos sistemas matemáticos; en el caso Wald–MDP,
  demostrada para el subcaso de un paso y determinista
  (@thm:ch9-isomorfismo), con la generalización estocástica como
  problema abierto (Nota~@note:ch9-extension-no-demostrada).

/ MDP: _Markov Decision Process_. Modelo de decisión secuencial con
  estados, acciones, transiciones y recompensas.

/ "Neyman-Pearson, Lema de": El test de razón de verosimilitudes es
  más potente al contrastar una hipótesis simple contra otra simple, al nivel fijado.

/ OPE: _Off-Policy Evaluation_. Estimar el valor de una política
  usando datos generados por otra política.

/ "Ortogonalidad de Neyman": Anulación de la derivada poblacional del momento respecto de los auxiliares en la verdad. Transferirla al estimador requiere una expansión y control del resto.

/ Overlap: Condición de que el soporte de la política objetivo esté
  contenido en el de la política de comportamiento.

/ "Rao-Blackwell, Teorema de": Condicionar un estimador insesgado a
  un estadístico suficiente reduce (o mantiene) la varianza.

/ Suficiencia: Un estadístico $T(X)$ es suficiente para $theta$ si la
  distribución condicional de $X mid(|) T$ no depende de $theta$.

/ UMVUE: _Uniformly Minimum Variance Unbiased Estimator_. Estimador
  insesgado con mínima varianza para todo $theta$.

/ "Valor, Función de": $V^pi (s) = EE^pi [sum_(t=0)^infinity gamma^t
  r_t mid(|) s_0 = s]$. Retorno esperado descontado bajo política
  $pi$.

/ "Wald, Teoría de Decisión de": Marco formal que unifica inferencia
  estadística como problema de decisión con pérdidas, riesgos y
  reglas de decisión.

== Índice de Notación por Capítulo
<app:tab-notacion-capitulo>

La @tab:app-notacion-intro indica dónde se introduce cada símbolo
principal.

#mi-tabla(
  caption: [Primera Aparición de Símbolos],
  key: "tab:app-notacion-intro",
  table(
    columns: (14%, 26%, 12%, 1fr),
    align: (left, left, center, center),
    hl(),
    table.header([*Símbolo*], [*Significado*], [*Consulta*], [*Sección*]),
    hl(w: 0.6pt),
    [$Theta$], [Espacio paramétrico], [#ref(<ch:arquitectura>, supplement: none)], [#ref(<sec:ch1-modelo>, supplement: none)],
    [$cal(X)$], [Espacio muestral], [#ref(<ch:arquitectura>, supplement: none)], [#ref(<sec:ch1-modelo>, supplement: none)],
    [$T(X)$], [Estadístico suficiente], [#ref(<ch:reduccion>, supplement: none)], [#ref(<sec:ch2-suficiencia>, supplement: none)],
    [$hat(theta)$], [Estimador puntual], [#ref(<ch:estimacion>, supplement: none)], [#ref(<sec:ch3-sesgo-varianza>, supplement: none)],
    [$I(theta)$], [Información de Fisher], [#ref(<ch:estimacion>, supplement: none)], [#ref(<sec:ch3-cramer-rao>, supplement: none)],
    [$phi_alpha$], [Función de test], [#ref(<ch:tests>, supplement: none)], [#ref(<sec:ch4-neyman-pearson>, supplement: none)],
    [$phi^*$], [IF eficiente], [#ref(<ch:semiparametrica>, supplement: none)], [#ref(<sec:ch6-eficiencia>, supplement: none)],
    [$L(theta, a)$], [Función de pérdida], [#ref(<ch:wald>, supplement: none)], [#ref(<sec:ch7-problema-decision>, supplement: none)],
    [$R(theta, delta)$], [Función de riesgo], [#ref(<ch:wald>, supplement: none)], [#ref(<sec:ch7-riesgo>, supplement: none)],
    [$cal(S)$], [Espacio de estados MDP], [#ref(<ch:mdp-bellman>, supplement: none)], [#ref(<sec:ch8-mdp-def>, supplement: none)],
    [$V^pi$], [Función de valor], [#ref(<ch:mdp-bellman>, supplement: none)], [#ref(<sec:ch8-valor>, supplement: none)],
    [$cal(T)$], [Operador de Bellman], [#ref(<ch:mdp-bellman>, supplement: none)], [#ref(<sec:ch8-operadores>, supplement: none)],
    [$Psi: "Wald" -> "MDP"$], [Incrustación fiel], [#ref(<ch:isomorfismo>, supplement: none)], [#ref(<sec:ch9-isomorfismo>, supplement: none)],
    [$rho$], [Importance ratio], [#ref(<ch:ope>, supplement: none)], [#ref(<sec:ch10-is>, supplement: none)],
    [$hat(V)_"DR"$], [Estimador DR], [#ref(<ch:ope>, supplement: none)], [#ref(<sec:ch10-dr>, supplement: none)],
    hl(),
  ),
)

== Catálogo de recursos para ejercicios adicionales
<sec:catalogo-datasets>

Esta sección propone recursos públicos para ejercicios adicionales. Las referencias de la tabla remiten a conceptos relacionados, no a análisis ejecutados con esos datos. Los capítulos actuales emplean ejemplos teóricos y simulaciones; no se atribuyen a estos recursos sus resultados sintéticos. Cada análisis adicional debe fijar la versión de los datos, sus filtros y su diseño inferencial. FrozenLake es un simulador, no una muestra fija.

#mi-tabla(
  caption: [Recursos sugeridos: tamaños originales orientativos y consultas conceptuales, no análisis ejecutados.],
  key: "tab:catalogo-datasets",
  table(
    columns: (24%, 10%, 10%, 8%, 1fr),
    align: (left, center, center, right, left),
    hl(),
    table.header([*Dataset*], [*Consulta*], [*Ejemplo*], [*$n$*], [*Fuente / Acceso*]),
    hl(w: 0.6pt),
    [NASA CMAPSS Turbofan (FD001)], [#ref(<ch:estimacion>, supplement: none)], [#ref(<ex:ch3-mle-normal>, supplement: none)], [20,631], [`kaggle.com/datasets/behrad3d/nasa-cmaps`],
    [UCI Heart Disease (Cleveland)], [#ref(<ch:estimacion>, supplement: none), #ref(<ch:tests>, supplement: none)], [#ref(<ex:ch3-ej1>, supplement: none), #ref(<ex:ch4-mp-normal>, supplement: none)], [303], [`archive.ics.uci.edu/dataset/45`],
    [California Housing], [#ref(<ch:tests>, supplement: none)], [#ref(<ex:ch4-mp-normal>, supplement: none)], [20,640], [`sklearn.datasets.fetch_california_housing()`],
    [UCI Auto MPG], [#ref(<ch:asintotica>, supplement: none)], [#ref(<ex:ch5-cociente>, supplement: none)], [398], [`archive.ics.uci.edu/dataset/9`],
    [NHANES 2017–2018], [#ref(<ch:asintotica>, supplement: none)], [#ref(<ex:ch5-bandas>, supplement: none)], [5,769], [`wwwn.cdc.gov/nchs/nhanes/continuousnhanes/`],
    [NHEFS (Hernán \& Robins)], [#ref(<ch:semiparametrica>, supplement: none)], [#ref(<ex:ch6-aipw-intro>, supplement: none)], [1,566], [`hsph.harvard.edu/miguel-hernan/causal-inference-book/`],
    [Haberman's Survival], [#ref(<ch:semiparametrica>, supplement: none)], [#ref(<ex:ch6-cox>, supplement: none)], [306], [`archive.ics.uci.edu/dataset/43`],
    [FrozenLake-v1 (Gymnasium)], [#ref(<ch:mdp-bellman>, supplement: none)], [#ref(<ex:ch8-frozenlake>, supplement: none)], [---], [`gymnasium.farama.org/environments/toy_text/frozen_lake/`],
    [S\&P 500 (FRED: SP500)], [#ref(<ch:inferencia>, supplement: none)], [#ref(<ex:ch11-ej1>, supplement: none)], [Variable], [`fred.stlouisfed.org/series/SP500`; ventana disponible de diez años],
    hl(),
  ),
)

#[
#set heading(numbering: none, outlined: false)
=== Fragmentos de carga en Python
]

Los siguientes fragmentos ilustran la carga de una selección de recursos, no la de cada entrada del catálogo. Se requieren `pandas`, `numpy` y, para FrozenLake, `gymnasium` (la ejecución de validación usa la versión registrada en el paquete de laboratorios). NASA requiere adquirir primero el archivo `train_FD001.txt` de la fuente indicada. Los tamaños de la tabla son previos a filtros: en Auto MPG, eliminar las seis filas indicadas deja 392 de las 398 originales. Para inferencia poblacional con NHANES deben incorporarse pesos, estratos y conglomerados y definirse las mediciones elegidas; el fragmento solo prepara una muestra descriptiva.

#codelisting-env(caption: [NASA CMAPSS Turbofan FD001.])[
```python
import pandas as pd
cols = ['unit','cycle','os1','os2','os3'] + \
      [f's{i}' for i in range(1,22)]
df = pd.read_csv('train_FD001.txt', sep=r'\s+',
                 header=None, names=cols)
# RUL = ciclo maximo - ciclo actual por unidad
df['RUL'] = df.groupby('unit')['cycle'] \
              .transform('max') - df['cycle']
```
]

#codelisting-env(caption: [UCI Heart Disease (Cleveland).])[
```python
import pandas as pd
url = ('https://archive.ics.uci.edu/ml/machine-learning-databases'
       '/heart-disease/processed.cleveland.data')
cols = ['age','sex','cp','trestbps','chol','fbs','restecg',
        'thalach','exang','oldpeak','slope','ca','thal','target']
df = pd.read_csv(url, header=None, names=cols, na_values='?')
df['target'] = (df['target'] > 0).astype(int)
```
]

#codelisting-env(caption: [UCI Auto MPG.])[
```python
import pandas as pd
url = ('https://archive.ics.uci.edu/ml/machine-learning-databases'
       '/auto-mpg/auto-mpg.data')
df = pd.read_csv(url, sep=r'\s+', header=None, na_values='?',
    names=['mpg','cylinders','displacement','horsepower',
           'weight','acceleration','model_year','origin','name'])
df.dropna(inplace=True)  # elimina 6 filas con HP faltante
```
]

#codelisting-env(caption: [NHANES 2017–2018 (presion sistolica).])[
```python
import pandas as pd
url_demo = ('https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018'
            '/DEMO_J.XPT')
url_bpx  = ('https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018'
            '/BPX_J.XPT')
demo = pd.read_sas(url_demo, format='xport', encoding='utf-8')
bpx  = pd.read_sas(url_bpx,  format='xport', encoding='utf-8')
df = demo[['SEQN','RIAGENDR']].merge(
         bpx[['SEQN','BPXSY1']], on='SEQN').dropna()
```
]

#codelisting-env(caption: [S\&P 500 via FRED.])[
```python
import pandas as pd
url = 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=SP500'
sp500 = pd.read_csv(url, na_values='.')
date_column = sp500.columns[0]
sp500[date_column] = pd.to_datetime(sp500[date_column])
prices = sp500.set_index(date_column)['SP500'].dropna().sort_index()
ret = prices.pct_change(fill_method=None).dropna()
print(prices.index.min(), prices.index.max(), len(ret))
```
]

#codelisting-env(caption: [FrozenLake-v1 (Gymnasium).])[
```python
import gymnasium as gym
import numpy as np

env = gym.make('FrozenLake-v1', is_slippery=True,
               render_mode=None)
nS, nA = env.observation_space.n, env.action_space.n

def value_iteration(env, gamma=0.99, tol=1e-8):
    model = env.unwrapped.P
    nS, nA = env.observation_space.n, env.action_space.n
    V = np.zeros(nS)
    for _ in range(10_000):
        V_new = np.array([
            max(sum(p*(r + gamma*(not terminal)*V[s_])
                    for p,s_,r,terminal in model[s][a])
                for a in range(nA))
            for s in range(nS)])
        if np.max(np.abs(V_new - V)) < tol:
            break
        V = V_new
    return V

V_star = value_iteration(env)
```
]

#[
#set heading(numbering: none, outlined: false)
=== Notas éticas y advertencias
]

- *NHANES:* Los microdatos públicos de NHANES no contienen
  identificadores directos; el acceso a datos enlazados con
  mortalidad requiere un _research data center_ (RDC) de los CDC.
- *NHEFS:* El dataset de Hernán \& Robins es de libre descarga con
  fines educativos; citar #cite(<hernan2020causal>, form: "prose") al
  reutilizarlo.
- *Boston Housing:* Este dataset _no_ se utiliza en la monografía dado
  que contiene una variable proxy de raza (`B`) cuya inclusión es
  éticamente problemática. Se usó California Housing como alternativa
  limpia.
- *NASA CMAPSS:* Datos sintéticos de simulación; no representan
  fallos reales de motores individuales ni información propietaria.
