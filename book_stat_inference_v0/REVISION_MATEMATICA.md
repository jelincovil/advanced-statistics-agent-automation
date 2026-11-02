# Revisión de los doce resultados centrales

Fecha: 28 de octubre de 2026. Alcance: resultados seleccionados en la conversación, sus demostraciones y las aplicaciones directamente relacionadas. Se revisó la coherencia matemática y se corrigieron los archivos del libro integrado; los originales de la raíz se conservaron. Esta revisión no constituye una certificación formal de todos los resultados del manuscrito.

| Resultado | Evaluación y mejora |
|---|---|
| 1. Representación riesgo–retorno | Identidad correcta en la familia de MDP de una decisión. Se sustituyó la prueba antigua que confundía parámetro y observación y pretendía construir un funtor general. Se precisaron el estado terminal y la clase de políticas. |
| 2. Bayes, minimax y admisibilidad | Correctos dentro de clases correspondientes. Se añadió una prueba conjunta: cambio de signo, integración y comparación componente a componente. No se afirma existencia de optimizadores ni intercambio de supremo e ínfimo. |
| 3. Observación y parada bayesiana | Recursión correcta bajo el modelo finito declarado. Se desarrolló la inducción hacia atrás. Se reemplazó la falsa equivalencia suficiencia–Markov por un contraejemplo y la condición predictiva de un estado controlado. |
| 4. Bellman y certificados residuales | Cotas correctas. Se corrigió el paso de desigualdad unilateral a valor absoluto y la afirmación de unicidad de política. El valor es único; las políticas óptimas pueden empatar. |
| 5. Suficiencia, Rao–Blackwell y Lehmann–Scheffé | Se reconstruyeron factorización, minimalidad y el argumento de completitud. Se eliminaron aplicaciones no justificadas de completitud, ancilaridad y UMVUE a conteos de trayectorias. La reducción de varianza se interpreta con momentos finitos. |
| 6. Neyman–Pearson e inversión | Se corrigió la falsa continuidad de la distribución de la razón de verosimilitudes. El umbral se elige por cuantiles con aleatorización en átomos. La prueba usa densidades para incluir soporte nulo bajo la hipótesis nula. |
| 7. Importancia y horizonte | Se sustituyó la prueba por cambio de medida. Se separaron integrabilidad, independencia y segundo momento. La falsa cota inferior exponencial se reemplazó por una cota superior y un ejemplo con varianza exponencial exacta. Se corrigieron pesos acumulados en POMDP. |
| 8. Doble robustez | El capítulo principal tenía la forma correcta; el apéndice usaba una predicción de la acción observada en lugar del promedio objetivo. Se corrigió y se demostró la identidad de sesgo producto y la cancelación longitudinal. |
| 9. IF y eficiencia | Se reemplazaron la fórmula incorrecta del apéndice y la demostración defectuosa de la cota. Se distingue gradiente canónico, score y expansión del estimador. Se explicita el experimento Markov finito con ley inicial desconocida y kernels por tiempo. |
| 10. Ortogonalidad y DML | Se completó una demostración antes vacía: sesgo producto, fluctuación empírica condicional por fold, CLT y varianza consistente. Se mantiene la condición de producto pequeño-o, sin sustituirla por dos tasas grandes-O de un cuarto. |
| 11. Inferencia para valor | Se conserva la distinción entre episodios iid, CLT mixing y aproximación de Bellman por bases. Se corrigió la atribución automática de eficiencia al término lineal de Shi et al. Su resultado se presenta como esquema bajo las condiciones originales, no como demostración completa reproducida aquí. |
| 12. Política aprendida, SAVE y margen | El ejemplo de margen de una decisión tiene una cota válida mediante el evento de gap menor que dos veces el error uniforme. SAVE conserva sus condiciones propias. Se eliminaron del capítulo final umbrales ESS y reglas de discretización presentados como garantías generales. |

## Comprobaciones realizadas

`python3 verificacion/comprobar_identidades.py` verifica por enumeración finita y álgebra numérica las identidades DR y AIPW, el cambio de medida, la varianza exponencial del ejemplo Bernoulli, un contraejemplo de peso solo local, la cota residual de Bellman y riesgo–retorno para todas las reglas binarias del ejemplo. Estas comprobaciones detectan errores concretos; las demostraciones y sus hipótesis sustentan los enunciados generales.

El libro se compiló con Typst 0.15.1 sin errores. La compilación comprueba sintaxis y referencias, no verdad matemática. Las remisiones al apéndice ahora dicen «argumento y alcance», porque algunos resultados externos solo tienen un esquema y una referencia.

## Fuentes y límites

Se consultaron [Kallus y Uehara (2020), JMLR](https://jmlr.org/papers/volume21/19-827/19-827.pdf) para contrastar modelos, razones marginales y eficiencia, y la [ficha y resumen de Shi et al.](https://arxiv.org/abs/2001.04515) para la distinción entre política fija, aproximación por bases y SAVE. La versión actual de arXiv tiene revisiones posteriores a la publicación de 2022: no se considera una verificación línea por línea de la versión publicada ni de sus suplementos.

Las pruebas del libro se delimitan expresamente cuando no reproducen un resultado externo completo. Las condiciones causales, la positividad poblacional y las tasas de estimación no se pueden certificar con diagnósticos de una única muestra. Otros resultados clásicos no incluidos entre los doce, los laboratorios y las hipótesis empíricas del SSCH quedan fuera de esta revisión.
