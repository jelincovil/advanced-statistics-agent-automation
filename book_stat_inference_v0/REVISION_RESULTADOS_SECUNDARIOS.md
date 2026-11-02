# Revisión de resultados secundarios

Fecha: 28 de octubre de 2026. Complementa `REVISION_MATEMATICA.md`. La revisión se concentró en los resultados auxiliares de decisión, inferencia clásica, planificación, dependencia y fundamentos de medida, cotejando capítulos, demostraciones y tablas. No equivale a una formalización automática ni a reproducir todas las pruebas de la bibliografía.

## Errores corregidos y mejoras

| Resultado | Hallazgo y corrección |
|---|---|
| Máxima verosimilitud | La prueba tomaba esperanzas bajo parámetros cambiantes y afirmaba una ordenación falsa de entropías. Se usa la ley verdadera, divergencia KL, convergencia uniforme y separación del máximo. Para normalidad se escribe Taylor con Hessiano integrado y condiciones locales explícitas. |
| Clase esencialmente completa | Mejor riesgo promedio no implica dominancia. Se reemplazó la prueba por separación del conjunto compacto convexo de riesgos en el problema finito y una construcción de un riesgo admisible que mejora débilmente al inicial. |
| Existencia de reglas de Bayes | Se retiraron extensiones injustificadas a acciones arbitrarias. Para acciones finitas se demuestra selección medible mediante desempate fijo y optimalidad por esperanza iterada. |
| Cramér–Rao | Se exigió información positiva; se aclaró que la cota inversa de información para estimar el parámetro requiere insesgadez. Se eliminó la aplicación automática de la fórmula binomial de tamaño fijo a conteos aleatorios de visitas. |
| Benjamini–Hochberg | Se añadió una prueba completa del control FDR bajo independencia, con reemplazo de un p-valor nulo por cero. Se evita dividir por cero y se admite superuniformidad. PRDS se atribuye a Benjamini–Yekutieli (2001); correlación positiva no basta. |
| Wilks | Se eliminó la atribución a Neyman–Pearson. Se corrigió la geometría: el estadístico corresponde al complemento del tangente nulo y sus grados de libertad son el rango de las restricciones. El texto se presenta como esquema bajo regularidad. |
| Bootstrap de la media | Se verifica Lindeberg para un arreglo triangular condicional. Se eliminó la tasa injustificada de la varianza empírica bajo solo segundo momento finito; se distingue consistencia de refinamientos de cobertura. |
| CLT y Lindeberg–Feller | Se precisan varianza positiva al estandarizar, independencia por filas y varianza total finita y positiva. Los ejemplos iid se distinguen de visitas repetidas. |
| Equivarianza | Se creó un argumento propio; la referencia anterior conducía a completitud. El riesgo es constante por órbitas, sin deducir minimax de invariancia sola. |
| MCMC y VI | Se reemplazó una supuesta proposición universal de rapidez y sesgo por una nota condicionada. VI puede ser exacta si su familia contiene el posterior y se logra el óptimo global. |
| Aperiodicidad | Un auto-bucle en un estado implica aperiodicidad de toda la cadena solo con irreducibilidad. Se explicita la revisión por clases cuando esta falta. |
| Mixing en MDP | Se precisan inicio estacionario, mecanismo de aleatorización y kernel de recompensas. Las tablas ya no prometen CLT e intervalos por la tasa de mixing aislada. Para mixing polinomial se usa la condición conjunta con el momento disponible. |
| Límite funcional | Se reemplazó la atribución general a Gordin por un caso finito explícito, con ecuación de Poisson, diferencias de martingala y término de borde. La convergencia escalar no sustituye la tightness funcional. |
| Varianza HAC | Se sustituyó la condición insuficiente «mixing geométrico y K=O(n^(1/3))» por crecimiento del ancho, sumabilidad y control agregado del error de autocovarianzas. Se retiró una fórmula incorrecta atribuida a Andrews. |
| Radon–Nikodym | Se añadió sigma-finitud de la medida dominante y se precisó la unicidad respecto de sus conjuntos nulos. |
| Información del MDP | Se corrigió la ley conjunta de recompensa y estado siguiente: se condiciona antes de observar la recompensa actual, no en una sigma-álgebra que ya la contiene. |
| Medibilidad y argmax | Se corrigió una implicación invertida sobre composición. Continuidad de una verosimilitud sola no garantiza existencia ni selección medible de su máximo. |
| Función implícita | Se precisaron dimensiones y vecindario abierto. Invertibilidad de información esperada no equivale a invertibilidad de un Jacobiano muestral. |
| Tablas y categorías editoriales | Se ajustaron correspondencias del glosario y se reclasificaron como notas las recomendaciones, agendas y esquemas de arquitectura que no son proposiciones matemáticas. |

## Resultados examinados que conservan su fórmula

Se conservaron las identidades de log-partición, el criterio de Bayes–minimax, el cálculo Bernoulli de riesgo constante, la mejora y terminación de iteración de políticas con desempate conservador, la cota UCB1 bajo su experimento acotado y la distinción entre Thompson Sampling y decisión de Bayes. Las cotas de bandidos se mantienen como resultados bibliográficos; no se incorporó una demostración completa nueva.

También se conservaron Bonferroni, Holm, las formulaciones condicionadas de MLR/UMPU, delta, Glivenko–Cantelli, Donsker, propagación conjunta de incertidumbre de Q, la cota espectral reversible, el cambio de población inicial, la cobertura mediante un conjunto de modelos, las cotas de truncamiento, la identidad del gradiente de política y el centrado de baselines. Se revisaron sus hipótesis declaradas; esto no certifica que se cumplan en una aplicación concreta.

Composición de funciones medibles, convergencia dominada y proyección sobre un subespacio cerrado conservan sus enunciados. Las demostraciones de resultados externos que solo se citan siguen teniendo ese alcance.

## Verificación reproducible

`python3 verificacion/comprobar_secundarios.py` pasó las siguientes comprobaciones deterministas:

- BH en una rejilla finita independiente: identidad de reemplazo y FDR 0,2 con dos nulas y nivel 0,3 en tres tests.
- Varianza binomial exacta e igualdad con Cramér–Rao para tamaño fijo.
- Contraejemplo de mejora promedio sin dominancia.
- Contraejemplo de cadena reducible con un auto-bucle y otra clase periódica.
- Identidad de Poisson y descomposición martingala en todas las trayectorias binarias de longitud seis.
- Conservación del gradiente Bernoulli al restar baselines prefijadas.
- Sesgo exacto del ejemplo de truncamiento de cola rara.

Se compiló el libro completo con Typst sin errores. Los casos finitos detectan errores algebraicos específicos; no prueban los teoremas asintóticos generales. No se ejecutaron los laboratorios ni se certificaron hipótesis empíricas del SSCH.

## Referencia corregida

La extensión PRDS corresponde a [Benjamini y Yekutieli (2001), The Control of the False Discovery Rate in Multiple Testing under Dependency](https://doi.org/10.1214/aos/1013699998), incorporada a la bibliografía. La prueba añadida al libro cubre independencia; la extensión de dependencia se remite expresamente a esa fuente.
