#import "../plantilla.typ": *

// Catálogo único: las tablas locales son vistas de estos mismos registros.
// BETA <- filas originales 1, 2: tab:ch1-nodos-diagnostico-b
// POST <- filas originales 3: tab:ch1-nodos-diagnostico-b
// DEC <- filas originales 4, 5, 12: tab:ch1-nodos-diagnostico-b, tab:ch1-trazabilidad
// BAYES <- filas originales 6, 76: tab:ch1-nodos-diagnostico-b, tab:ch7-trazabilidad
// HUM <- filas originales 7: tab:ch1-nodos-diagnostico-b
// SEQ <- filas originales 8: tab:ch1-nodos-diagnostico-b
// LOG <- filas originales 9: tab:ch1-nodos-diagnostico-b
// MOD <- filas originales 10, 40: tab:ch1-trazabilidad, tab:ch6-trazabilidad
// SUF <- filas originales 11, 15, 17, 56, 90: tab:ch1-trazabilidad, tab:ch2-trazabilidad, tab:app-trazabilidad, tab:ch9-trazabilidad
// EXP <- filas originales 13, 55: tab:ch1-trazabilidad, tab:app-trazabilidad
// MOM <- filas originales 14: tab:ch1-trazabilidad
// MSE <- filas originales 16, 26: tab:ch1-trazabilidad, tab:ch3-trazabilidad
// MIN <- filas originales 18: tab:ch2-trazabilidad
// COM <- filas originales 19: tab:ch2-trazabilidad
// BAS <- filas originales 20: tab:ch2-trazabilidad
// EQU <- filas originales 21: tab:ch2-trazabilidad
// RED <- filas originales 22: tab:ch2-trazabilidad
// RB <- filas originales 23, 57: tab:ch3-trazabilidad, tab:app-trazabilidad
// LS <- filas originales 24, 47, 58: tab:ch3-trazabilidad, tab:ch12-trazabilidad, tab:app-trazabilidad
// CR <- filas originales 25, 59: tab:ch3-trazabilidad, tab:app-trazabilidad
// MLE <- filas originales 27: tab:ch3-trazabilidad
// NP <- filas originales 28, 53, 60: tab:ch4-trazabilidad, tab:ch12-trazabilidad, tab:app-trazabilidad
// UMP <- filas originales 29: tab:ch4-trazabilidad
// CI <- filas originales 30, 92: tab:ch4-trazabilidad, tab:ch9-trazabilidad
// FWER <- filas originales 31: tab:ch4-trazabilidad
// FDR <- filas originales 32, 61: tab:ch4-trazabilidad, tab:app-trazabilidad
// POWER <- filas originales 33, 98: tab:ch4-trazabilidad, tab:ch11-trazabilidad
// CLT <- filas originales 34: tab:ch5-trazabilidad
// DELTA <- filas originales 35: tab:ch5-trazabilidad
// GC <- filas originales 36: tab:ch5-trazabilidad
// DON <- filas originales 37, 62: tab:ch5-trazabilidad, tab:app-trazabilidad
// BOOT <- filas originales 38, 54: tab:ch5-trazabilidad, tab:ch12-trazabilidad
// BT <- filas originales 39: tab:ch5-trazabilidad
// TAN <- filas originales 41: tab:ch6-trazabilidad
// EIF <- filas originales 42, 71, 96: tab:ch6-trazabilidad, tab:app-trazabilidad, tab:ch11-trazabilidad
// BOUND <- filas originales 43: tab:ch6-trazabilidad
// ORTH <- filas originales 44, 63: tab:ch6-trazabilidad, tab:app-trazabilidad
// DR <- filas originales 45, 49, 70: tab:ch6-trazabilidad, tab:ch12-trazabilidad, tab:app-trazabilidad
// DML <- filas originales 46, 73: tab:ch6-trazabilidad, tab:app-trazabilidad
// MM <- filas originales 48, 77: tab:ch12-trazabilidad, tab:ch7-trazabilidad
// SIEVE <- filas originales 50, 72, 93: tab:ch12-trazabilidad, tab:app-trazabilidad, tab:ch11-trazabilidad
// EMB <- filas originales 51, 68, 80, 87, 88: tab:ch12-trazabilidad, tab:app-trazabilidad, tab:ch7-trazabilidad, tab:ch9-trazabilidad
// VI <- filas originales 52, 84: tab:ch12-trazabilidad, tab:ch8-trazabilidad
// CC <- filas originales 64, 79: tab:app-trazabilidad, tab:ch7-trazabilidad
// ADM <- filas originales 65, 78, 89: tab:app-trazabilidad, tab:ch7-trazabilidad, tab:ch9-trazabilidad
// BELL <- filas originales 66, 82, 83: tab:app-trazabilidad, tab:ch8-trazabilidad
// PI <- filas originales 67, 85: tab:app-trazabilidad, tab:ch8-trazabilidad
// IS <- filas originales 69: tab:app-trazabilidad
// WALD <- filas originales 74, 75: tab:ch7-trazabilidad
// MDP <- filas originales 81: tab:ch8-trazabilidad
// STOP <- filas originales 86: tab:ch8-trazabilidad
// IMAGE <- filas originales 91: tab:ch9-trazabilidad
// MIX <- filas originales 94: tab:ch11-trazabilidad
// HAC <- filas originales 95: tab:ch11-trazabilidad
// SAVE <- filas originales 97: tab:ch11-trazabilidad

#let catalogo-garantias = (
  (id: "BETA", resultado: [Actualización Beta–Bernoulli], componente: [Estado de creencias], alcance: [Posterior exacto dentro del modelo: observaciones Bernoulli iid, prior Beta propio y mecanismo de observación compatible. No modela por sí solo pruebas diagnósticas imperfectas.], fuente: [@def:ch1-conjugada]),
  (id: "POST", resultado: [Varianza posterior], componente: [Resumen de incertidumbre], alcance: [Dispersión de theta condicional en los datos. No es la varianza frecuentista de la media posterior ni demuestra calibración del modelo.], fuente: [@sec:ch1-estado-suficiente]),
  (id: "DEC", resultado: [Decisión y abstención], componente: [Selector de acciones], alcance: [Minimizar pérdida posterior requiere especificar costos y acciones. Un umbral de dispersión añadido es una regla de diseño; no hereda optimalidad Bayes.], fuente: [@sec:ch1-incertidumbre-decision]),
  (id: "HUM", resultado: [Revisión humana], componente: [Derivación y registro], alcance: [Procedimiento operativo, sin garantía estadística automática. Debe especificarse qué información recibe el revisor y qué decisiones puede cambiar.], fuente: [@sec:ch1-arquitectura-nodos]),
  (id: "SEQ", resultado: [Parada y revisiones], componente: [Control temporal], alcance: [Un IC de tamaño fijo no permite detenerse libremente conservando cobertura. Se necesita un método secuencial válido o un plan de análisis que controle el error.], fuente: [@sec:ch4-multiples-politicas]),
  (id: "LOG", resultado: [Trazabilidad], componente: [Registro de evidencia], alcance: [Vincular fórmula, supuestos, datos y versión facilita auditoría. Un registro completo o un hash no prueba validez estadística.], fuente: [@prop:ch12-trazability]),
  (id: "MOD", resultado: [Modelo estadístico], componente: [Especificación del experimento], alcance: [Distinguir ley observada, objetivo e identificación. Una parametrización y un esquema de tipos no prueban que el modelo represente los datos.], fuente: [@sec:ch6-ope-agentes]),
  (id: "SUF", resultado: [Suficiencia], componente: [Resumen de datos], alcance: [La factorización establece suficiencia para una familia especificada. No implica automáticamente estado Markov para futuras decisiones.], fuente: [@thm:ch2-neyman-fisher]),
  (id: "EXP", resultado: [Familia exponencial], componente: [Actualización incremental], alcance: [Bajo el modelo iid y dimensión fija, el estadístico natural puede actualizarse por sumas. No toda familia es minimal ni toda memoria del agente puede descartarse.], fuente: [@thm:ch1-suficiencia-natural]),
  (id: "MOM", resultado: [Log-partición], componente: [Cálculo de momentos], alcance: [Sus derivadas dan momentos bajo diferenciabilidad e intercambio válido con la integral. La identidad es condicional a la familia especificada.], fuente: [@thm:ch1-logparticion]),
  (id: "MIN", resultado: [Suficiencia minimal], componente: [Reducción estadística], alcance: [Minimalidad compara sigma-álgebras suficientes, salvo conjuntos nulos; no minimiza bytes ni equivale a completitud.], fuente: [@sec:ch2-memoria]),
  (id: "COM", resultado: [Completitud], componente: [Unicidad insesgada], alcance: [Si una función integrable del estadístico tiene esperanza cero para todos los parámetros, es nula casi seguramente. No elimina toda redundancia computacional.], fuente: [@sec:ch2-completitud-agentes]),
  (id: "BAS", resultado: [Basu], componente: [Separación de estadísticas], alcance: [Suficiencia completa y ancilaridad implican independencia. Un campo llamado contexto no es ancilar por su nombre.], fuente: [@thm:ch2-basu]),
  (id: "EQU", resultado: [Equivarianza], componente: [Consistencia ante simetrías], alcance: [Comprobar transformaciones del modelo, pérdida y acción. La restricción a reglas equivariantes necesita un argumento separado de optimalidad.], fuente: [@sec:ch2-equivarianza-agentes]),
  (id: "RED", resultado: [Reducción de reglas], componente: [Política basada en un resumen], alcance: [Un núcleo condicional independiente del parámetro preserva el riesgo de reglas aleatorizadas. Para acciones deterministas se necesitan condiciones adicionales.], fuente: [@prop:ch2-suficiencia-politicas]),
  (id: "RB", resultado: [Rao–Blackwell], componente: [Mejora de estimación], alcance: [Condicionamiento implementable en un estadístico suficiente, con segundo momento finito: mismo sesgo y varianza no mayor. No garantiza eficiencia semiparamétrica.], fuente: [@prop:ch3-rb-q]),
  (id: "LS", resultado: [Lehmann–Scheffé], componente: [Selección de estimador], alcance: [Un estimador insesgado con varianza finita, función de un estadístico suficiente completo, es UMVUE. La comparación se restringe a estimadores insesgados.], fuente: [@thm:ch3-lehmann-scheffe]),
  (id: "CR", resultado: [Cramér–Rao], componente: [Referencia de precisión], alcance: [Para valor g(theta), estimación insesgada y experimento paramétrico regular: cota con gradiente de g e inversa de la información del experimento.], fuente: [@prop:ch3-valor-cr]),
  (id: "MSE", resultado: [Sesgo y varianza], componente: [Evaluación de error], alcance: [Con segundo momento finito, ECM = varianza + sesgo al cuadrado. La identidad no prescribe qué estimador minimiza el ECM.], fuente: [@sec:ch3-tradeoff]),
  (id: "MLE", resultado: [Máxima verosimilitud], componente: [Estimación del entorno], alcance: [Consistencia, normalidad y eficiencia requieren condiciones específicas: identificación, regularidad y control de la optimización. No basta maximizar una función.], fuente: [@thm:ch3-mle-propiedades]),
  (id: "NP", resultado: [Neyman–Pearson], componente: [Contraste simple], alcance: [Máxima potencia para dos hipótesis simples y nivel fijado, con aleatorización si corresponde. No es un resultado UMP para toda alternativa compuesta.], fuente: [@thm:ch4-neyman-pearson]),
  (id: "UMP", resultado: [Razón monótona de verosimilitud], componente: [Contraste unilateral], alcance: [UMP solo en las familias y alternativas que cumplen las hipótesis del resultado correspondiente.], fuente: [@thm:ch4-mlr]),
  (id: "CI", resultado: [Inversión de contrastes], componente: [Intervalo y comparación], alcance: [El conjunto invertido hereda el nivel de los contrastes utilizados. Distinguir cobertura finita de asintótica y puntual de simultánea.], fuente: [@thm:ch4-inversion]),
  (id: "FWER", resultado: [Bonferroni y Holm], componente: [Comparaciones múltiples], alcance: [Control de probabilidad de al menos un falso rechazo hasta alpha, con p-valores válidos. No promete ausencia de falsos positivos.], fuente: [@thm:ch4-holm]),
  (id: "FDR", resultado: [Benjamini–Hochberg], componente: [Selección múltiple], alcance: [Control de proporción esperada de falsos descubrimientos bajo independencia o dependencia admitida. No controla la probabilidad de cada decisión individual.], fuente: [@thm:ch4-bh]),
  (id: "POWER", resultado: [Potencia y tamaño muestral], componente: [Planificación], alcance: [Depende de alternativa, efecto, diseño y varianza de la diferencia. La fórmula normal del capítulo de intervalos es una aproximación.], fuente: [@thm:ch11-n]),
  (id: "CLT", resultado: [CLT por episodio], componente: [Error estándar], alcance: [Episodios iid, contribución con varianza finita positiva y resto despreciable. Dependencia dentro de episodios no crea más unidades independientes.], fuente: [@sec:ch11-problema]),
  (id: "DELTA", resultado: [Método delta], componente: [Transformación de estimandos], alcance: [Expansión diferenciable y límite del estimador inicial; si la derivada se anula o el funcional es no regular, revisar la escala y el límite.], fuente: [@thm:ch5-delta]),
  (id: "GC", resultado: [Glivenko–Cantelli], componente: [Distribución empírica], alcance: [Para la CDF univariada iid, convergencia uniforme casi segura; para otras clases, verificar condiciones. No constituye un intervalo por sí sola.], fuente: [@thm:ch5-gc]),
  (id: "DON", resultado: [Donsker], componente: [Proceso empírico], alcance: [Un límite funcional exige la clase y topología apropiadas; estimación de funciones auxiliares o dependencia requieren condiciones adicionales.], fuente: [@thm:ch5-donsker]),
  (id: "BOOT", resultado: [Bootstrap], componente: [Remuestreo para inferencia], alcance: [Respetar unidad independiente o bloques y justificar consistencia para el funcional; considerar el reajuste. Aumentar réplicas no corrige un bootstrap inválido.], fuente: [@sec:ch5-bootstrap-agentes]),
  (id: "BT", resultado: [Bootstrap studentizado], componente: [Refinamiento del IC], alcance: [Mejoras de orden superior necesitan momentos, suavidad y expansión suficientes. No se atribuye un error universal de orden n elevado a menos uno.], fuente: [@def:ch5-ic-t]),
  (id: "TAN", resultado: [Espacio tangente], componente: [Definición de eficiencia], alcance: [El gradiente canónico depende del modelo observado y sus restricciones. Una función centrada cualquiera no es necesariamente eficiente.], fuente: [@sec:ch6-ope-agentes]),
  (id: "EIF", resultado: [Gradiente canónico OPE], componente: [Contribuciones de valor], alcance: [En el modelo Markov de horizonte finito por tiempo: razones marginales y residuos de Bellman. Eficiencia requiere además una expansión regular con resto despreciable.], fuente: [@thm:ch6-kallus]),
  (id: "BOUND", resultado: [Cota semiparamétrica], componente: [Comparación de estimadores], alcance: [Cota entre estimadores regulares en un modelo fijado. No se identifica con la cota de un modelo distinto ni con una garantía finita.], fuente: [@thm:ch6-cota]),
  (id: "ORTH", resultado: [Ortogonalidad], componente: [Momento de estimación], alcance: [Derivada poblacional nula respecto del auxiliar en la verdad; hay que controlar el resto de orden superior y la fluctuación empírica.], fuente: [@sec:ch6-robustez]),
  (id: "DR", resultado: [Doble robustez], componente: [Evaluación aumentada], alcance: [La identidad poblacional y condiciones de convergencia permiten consistencia si uno de los conjuntos auxiliares es correcto. Esto no basta para un IC eficiente.], fuente: [@sec:ch6-dr-agentes]),
  (id: "DML", resultado: [Cross-fitting y DML], componente: [Aprendizaje auxiliar], alcance: [Separación por unidades, convergencia y productos de errores pequeños a escala raíz de n; también momentos y varianza. El algoritmo de partición no prueba esas tasas.], fuente: [@thm:ch6-dml]),
  (id: "WALD", resultado: [Problema y riesgo de Wald], componente: [Criterio de decisión], alcance: [Modelo, espacio de acciones y pérdida especificados; riesgo como esperanza de pérdida. Representar un problema no prueba identificación ni optimalidad.], fuente: [@def:ch7-problema]),
  (id: "BAYES", resultado: [Regla de Bayes], componente: [Minimización posterior], alcance: [Prior y pérdida especificados, riesgo definido y mínimo alcanzado. El resultado es relativo a ese problema.], fuente: [@thm:ch7-bayes]),
  (id: "MM", resultado: [Minimax], componente: [Peor riesgo], alcance: [La certificación Bayes requiere que el riesgo máximo global iguale al riesgo Bayes; constancia solo sobre el soporte del prior no basta.], fuente: [@thm:ch7-minimax-bayes]),
  (id: "ADM", resultado: [Admisibilidad], componente: [No dominancia], alcance: [Ausencia de otra regla que mejore todos los riesgos y alguno estrictamente, dentro de la clase comparada. Bayes no implica admisibilidad sin condiciones.], fuente: [@def:ch7-admisibilidad]),
  (id: "CC", resultado: [Clase completa], componente: [Restricción de reglas], alcance: [Aplicar la versión del teorema con sus condiciones y clase de reglas. No implica que toda regla admisible sea Bayes para un prior propio.], fuente: [@thm:ch7-complete-class]),
  (id: "MDP", resultado: [Modelo de Markov], componente: [Estado y dinámica], alcance: [La ley del siguiente estado y recompensa debe corresponder al historial resumido y a la acción; omitir variables puede romper la representación.], fuente: [@def:ch8-mdp]),
  (id: "BELL", resultado: [Bellman y contracción], componente: [Planificación], alcance: [Para MDP finito descontado y recompensas acotadas, el operador contrae en norma suprema. Convergencia computacional dentro del modelo no valida el modelo.], fuente: [@thm:ch8-contraccion]),
  (id: "VI", resultado: [Iteración de valores], componente: [Cálculo de valor óptimo], alcance: [Modelo finito conocido, descuento menor que uno y actualizaciones exactas dan convergencia geométrica. Aproximación y error del modelo se controlan aparte.], fuente: [@thm:ch8-vi-conv]),
  (id: "PI", resultado: [Mejora y extracción de política], componente: [Selección greedy], alcance: [En el MDP finito descontado, evaluación exacta y elección greedy dan mejora no decreciente y permiten una política óptima determinista.], fuente: [@thm:ch8-mejora]),
  (id: "STOP", resultado: [Residuo de Bellman], componente: [Parada computacional], alcance: [Con contracción gamma, el error de valor no supera el residuo dividido por uno menos gamma. Es distinto de la pérdida de valor de la política extraída.], fuente: [@cor:ch8-parada]),
  (id: "EMB", resultado: [Incrustación Wald–MDP], componente: [Representación de reglas], alcance: [Identidad de retorno integrado y riesgo negativo en la familia de una decisión y transición terminal determinista. No transfiere garantías a cualquier agente.], fuente: [@thm:ch9-isomorfismo]),
  (id: "IMAGE", resultado: [Imagen de un conjunto de confianza], componente: [Transformación de incertidumbre], alcance: [Con mapa conocido g y política fija, g(C) contiene g(theta) siempre que C contiene theta; su cobertura es al menos la del conjunto original.], fuente: [@sec:ch4-ic-delta]),
  (id: "IS", resultado: [Importance sampling], componente: [Reponderación], alcance: [Razones correctas, soporte e integrabilidad permiten insesgadez del estimador no normalizado. Razones estimadas o normalización cambian sus propiedades.], fuente: [@ch:ope]),
  (id: "SIEVE", resultado: [Bellman sieve de SZLS], componente: [Inferencia de valor], alcance: [Procedimiento y condiciones completos del artículo, incluidas aproximación, información y varianza; no equivale al estimador DR.], fuente: [@thm:ch11-shi]),
  (id: "MIX", resultado: [CLT con mixing], componente: [Inferencia dependiente], alcance: [Estacionariedad, momentos, sumabilidad de mixing y varianza de largo plazo positiva según el teorema; un diagnóstico ACF no los prueba.], fuente: [@thm:ch11-clt-mixing]),
  (id: "HAC", resultado: [Varianza de largo plazo], componente: [Studentización], alcance: [Estimar covarianzas y controlar rezagos y error agregado según un resultado de consistencia. No hay un ancho universal.], fuente: [@thm:ch11-var-consistente]),
  (id: "SAVE", resultado: [Evaluación secuencial SAVE], componente: [Políticas aprendidas], alcance: [Respetar bloques, agregación y condiciones de la evaluación secuencial original. No es una corrección DR ni una garantía de optimalidad aprendida.], fuente: [@def:ch11-save]),
)

#let tabla-garantias(ids, key: none, caption: [], aliases: ()) = {
  set par(justify: false)
  show table.cell: set text(hyphenate: false)
  let seleccion = ids.map(id => catalogo-garantias.find(r => r.id == id))
  assert(seleccion.all(r => r != none), message: "Identificador de garantía desconocido")
  mi-tabla(key: key, caption: caption, aliases: aliases, table(
    columns: (22%, 21%, 1fr), align: left, inset: 5pt, hl(),
    table.header([*Resultado*], [*Componente*], [*Conclusión condicionada y frontera*]), hl(w: 0.6pt),
    ..seleccion.map(r => (table.cell(breakable: false)[*#r.id* · #r.resultado #linebreak() #r.fuente], table.cell(breakable: false, r.componente), table.cell(breakable: false, r.alcance))).flatten(),
    hl(),
  ))
}

La tabla es un catálogo de afirmaciones condicionadas, no una certificación
de implementaciones. Los identificadores permiten remitir a una sola
formulación; las tablas posteriores son vistas temáticas del mismo catálogo.
La evidencia y el dictamen se registran por aplicación.

#tabla-garantias(catalogo-garantias.map(r => r.id), key: "tab:trazabilidad-canonica", caption: [Catálogo canónico de garantías: resultados, componentes y límites de aplicación.])
