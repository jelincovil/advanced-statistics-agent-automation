# Planificación de presentaciones académicas en Typst

Fecha: 30 de octubre de 2026.

## Organización general

13 clases de tres horas: una para la introducción y una para cada uno de los doce capítulos. Total: 39 horas, incluidos los descansos. Los módulos son bloques internos de cada clase, no sesiones adicionales.

Público de referencia: posgrado o formación avanzada. Idioma: español. Prerrequisitos: probabilidad, esperanza condicional, cálculo y álgebra lineal.

Se propone Typst con Touying y un estilo académico tipo Beamer, formato 16:9, tema común, bloques de hipótesis y resultados, notas docentes y handout. La versión del paquete se fijará al validar el prototipo. Referencia: https://typst.app/universe/package/touying/

## Distribución de cada clase

| Bloque | Minutos |
|---|---:|
| Motivación, repaso y objetivos | 15 |
| Desarrollo conceptual | 45 |
| Demostración o ejemplo trabajado | 30 |
| Descanso | 15 |
| Taller, ejercicios o laboratorio | 45 |
| Discusión y comprobación del aprendizaje | 20 |
| Síntesis y preparación de la clase siguiente | 10 |
| **Total** | **180** |

## Plan por clase

| Clase | Capítulo | Contenidos centrales | Actividad principal | Diapositivas base |
|---|---|---|---|---:|
| 1 | Introducción | Problema conductor, decisión bajo incertidumbre, riesgo y retorno, mapa del curso y prerrequisitos | Diagnóstico inicial y formulación del caso SSCH | 35–40 |
| 2 | Dos tradiciones y el problema de la transferencia de garantías | Wald, Bellman, significados de inferencia y transferencia de garantías | Comparar ambos marcos sobre un mismo problema | 40–45 |
| 3 | Teoría de decisión de Wald | Pérdidas, riesgo, dominancia, admisibilidad, Bayes y minimax | Resolver un problema finito y comparar reglas | 45–50 |
| 4 | Procesos de decisión de Markov | Modelo, funciones V/Q, Bellman, contracción y algoritmos de planificación | Calcular iteraciones y comprobar cotas residuales | 45–50 |
| 5 | Herramientas de transferencia | Suficiencia, estimación, contrastes, asintótica e introducción a influencia/DR | Ejercicios encadenados que conecten las herramientas | 50–60 |
| 6 | Representación Wald → MDP: enunciado, demostración y alcance | Construcción, identidad J = −R, transferencia de criterios y límites | Demostrar la representación y resolver observación/parada | 40–45 |
| 7 | Lo que no se transfiere | Identificación, soporte, dependencia, irregularidad y contraejemplos | Diagnosticar afirmaciones inválidas y reformularlas | 40–45 |
| 8 | Evaluación off-policy | Identificación, DM, IS, PDIS, DR, pesos y eficiencia | Comparar estimadores en un ejemplo secuencial | 45–55 |
| 9 | Intervalos de confianza para funciones de valor | Unidad muestral, CLT, varianza, HAC, métodos por bases y alcance de SAVE | Construir y comparar intervalos bajo distintos diseños | 45–55 |
| 10 | Un cálculo de verificación de garantías | Protocolo de auditoría, evidencia, supuestos y decisiones | Elaborar una ficha de verificación por equipos | 35–45 |
| 11 | Casos de estudio | Integración de los 14 laboratorios y comparación de resultados | Taller con casos seleccionados y discusión conjunta | 35–45 |
| 12 | De la garantía al despliegue | Cuantización, latencia, cambios de política, validación y monitoreo | Auditar una modificación de implementación | 40–50 |
| 13 | Problemas abiertos | Confusión, POMDP, acciones textuales, aproximación y preguntas de investigación | Presentar y discutir propuestas de investigación | 35–45 |

El presupuesto corregido es de **530–630 diapositivas base**. La suma sustituye el total de 565–675 indicado por error en la conversación. No incluye apariciones progresivas ni diapositivas de respaldo. Son rangos orientativos, no cuotas que deban rellenarse.

## Tratamiento de los capítulos más extensos

### Clase 5: Herramientas de transferencia

El capítulo 4 se aborda mediante una ruta integrada en una única clase de tres horas:

1. Modelos y reducción: familias exponenciales, conjugación y suficiencia.
2. Estimación: sesgo, varianza, Rao–Blackwell y alcance de las cotas de precisión.
3. Contrastes: error de tipo I, inversión de tests y multiplicidad.
4. Asintótica: CLT, delta y remuestreo.
5. Influencia y doble robustez: función del aprendizaje auxiliar y condiciones adicionales.

Las demostraciones largas se asignan como lectura previa y respaldo. Las herramientas se retoman en las clases 8 y 9; no se pretende demostrar todo el capítulo 4 durante esta sesión.

### Clase 11: Casos de estudio

Los catorce programas se distribuyen como preparación y actividades durante el curso. La clase 11 integra sus resultados y desarrolla casos representativos: SSCH, AIPW, CartPole y dependencia temporal.

| Grupo de actividades | Programas |
|---|---|
| Modelo y estado | lab00_ssch.py, lab01a_beta.py, lab01b_ctr.py, lab02_suficiencia.py |
| Estimación e incertidumbre | lab03_rb.py, lab04_comparacion.py, lab05_bootstrap.py, lab06_aipw.py |
| Decisión y planificación | lab07_bandit.py, lab08_bellman.py, lab09_incrustacion.py |
| Evaluación secuencial | lab10_cartpole.py, lab11_dependencia.py, lab12_dialogos.py |

No se exige ejecutar y explicar línea por línea los catorce programas en una sola clase. Cada actividad identifica entrada, salida, estimando, supuestos y límite de interpretación.

## Estructura de cada presentación

- Pregunta motivadora y entre dos y cuatro objetivos observables.
- Modelo, estimando y supuestos.
- Resultado central y demostración por etapas.
- Ejemplo trabajado, figura o fragmento breve de código.
- Contraejemplo o límite de aplicación.
- Ejercicio con solución en las notas.
- Síntesis y preparación de la clase siguiente.

## Diseño compartido

Formato 16:9, fondo claro, alto contraste y notación consistente. Paleta sugerida: azul para decisión estadística, marrón/naranja para MDP y violeta para la relación entre marcos. Los colores se acompañan de rótulos.

Una afirmación principal por diapositiva. Las hipótesis deben mostrarse junto al resultado. Las pruebas largas se remiten al respaldo. Las tablas densas se convierten en comparaciones pequeñas y el código se presenta en fragmentos legibles. Los ejemplos SSCH se rotulan como sintéticos y distinguen sus diferentes diseños.

Las notas docentes incluyen fuente o etiqueta del libro, explicación oral, tiempo estimado, transición y solución de actividades. Las referencias se vinculan con etiquetas o bibliografía para evitar numeración manual obsoleta.

## Material de respaldo

Los siete apéndices alimentan las pruebas, el glosario, los fundamentos medido-teóricos, la regularidad y los ejemplos de implementación. No añaden clases al total de trece.

## Secuencia de producción

1. Fijar la versión de las fuentes y las correcciones que alimentan las presentaciones.
2. Construir un prototipo de 6–8 diapositivas del capítulo 2 y comprobar fórmulas, tablas, pruebas, notas y handout.
3. Producir introducción y capítulos 1–4.
4. Producir capítulos 5–9.
5. Producir capítulos 10–12 y vincular los laboratorios y resultados disponibles.
6. Realizar revisión matemática, ensayo de duración, compilación y comprobación visual.
7. Entregar fuentes Typst, PDFs de exposición, handouts, notas docentes, ejercicios y respaldo.

Cada entrada debe compilar de manera independiente, compartir tema y notación y utilizar rutas relativas. La plantilla se valida antes de extenderla a todo el curso.

## Entregables previstos

- 13 presentaciones principales en Typst.
- 13 PDFs de exposición y sus versiones handout.
- Notas docentes y soluciones de ejercicios por clase.
- Diapositivas de respaldo y bibliografía pertinente.
- Material de laboratorio con versiones, semillas y resultados identificados.

## Estado y criterios de aceptación

Este archivo es una planificación; no implica que las presentaciones estén construidas. La corrección integral del libro sigue en curso. SAVE y el agente operativo conservarán su condición de pendientes hasta completar su validación; no se presentarán como resultados reproducidos.

Una presentación se acepta cuando sus objetivos, condiciones matemáticas, ejemplos y ejercicios son coherentes; las cifras tienen procedencia; no hay desbordes ni referencias rotas; exposición, notas y handout corresponden a la misma versión; y su ensayo cabe en 180 minutos incluidos los descansos.

