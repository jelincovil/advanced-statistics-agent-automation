// Puerto de main.tex — ensamblaje completo del libro.
#import "plantilla.typ": *

#show: libro

// -----------------------------------------------------------------------------
// FRONTMATTER (paridad con \frontmatter: numeración romana, sin capítulos)
// -----------------------------------------------------------------------------
#set page(numbering: "i")
#counter(page).update(1)

// Portada (paridad con \maketitle)
#align(center)[
  #v(4em)
  #text(size: 20pt, weight: "bold")[
    Teoría Avanzada de Inferencia Estadística\
    aplicada a la decisión secuencial y los agentes inteligentes
  ]
  #v(1.5em)
  #text(size: 13pt, style: "italic")[
    Un puente formal entre la teoría de decisión de Wald,\
    los procesos de decisión de Markov y la inferencia semiparamétrica\
    para el diseño de agentes con garantías estadísticas
  ]
  #v(3em)
  #text(size: 14pt)[Dr. Jaime Lincovil]\
  #text(size: 12pt)[Lima, Perú]
  #v(1em)
  #text(size: 12pt)[2024]
]
#pagebreak()

// Página de derechos / epígrafe de Bellman
#align(center + horizon)[
  #block(width: 80%)[
    #emph[
      Una política óptima tiene la propiedad de que, cualesquiera que sean
      el estado y decisión iniciales, las decisiones restantes deben
      constituir una política óptima respecto al estado resultante de la
      primera decisión.
    ]
    #v(1em)
    --- #cite(<bellman1957dynamic>, form: "prose")
  ]
]
#pagebreak()

// Prefacio
#include "prefacio.typ"

// Tabla de contenidos
#heading(level: 1, numbering: none)[Índice General]
#outline(title: none, indent: auto)
#pagebreak()

// Índices de figuras y tablas (paridad con \listoffigures / \listoftables)
#list-of("figura", [Índice de Figuras])
#pagebreak()
#list-of("tabla", [Índice de Tablas])
#pagebreak()

// Notación y símbolos
#include "notacion.typ"

// -----------------------------------------------------------------------------
// MAINMATTER (paridad con \mainmatter: numeración arábiga desde 1, capítulos)
// -----------------------------------------------------------------------------
#set page(numbering: "1")
#counter(page).update(1)

// Introducción general (Capítulo 0, sin numerar)
#include "capitulos/intro.typ"
#include "capitulos/cap01_dos_tradiciones.typ"

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Parte I]
  #v(0.5em)
  #text(size: 16pt)[Aparato mínimo necesario]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Una decisión empieza por definir qué se observa y qué consecuencias se comparan. Wald aporta el criterio de riesgo; los MDP incorporan el futuro. Las herramientas estadísticas permitirán después estudiar qué aprendemos de los datos y con qué precisión.]
  ]
]
#pagebreak()

#include "capitulos/cap02_wald.typ"
#include "capitulos/cap03_mdp.typ"
#include "capitulos/cap04_herramientas.typ"

// PARTE II — La correspondencia y sus fronteras (Capítulos 5-6)
#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Parte II]
  #v(0.5em)
  #text(size: 16pt)[La correspondencia y sus fronteras]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Con los dos marcos definidos, podemos preguntar qué se conserva al representar una regla como política. La construcción de un paso precisa esa relación. Sus límites muestran qué información y qué resultados adicionales hacen falta al ampliar el problema.]
  ]
]
#pagebreak()

#include "capitulos/cap05_incrustacion.typ"
#include "capitulos/cap06_fallos.typ"

// PARTE III — Inferencia para agentes (Capítulos 7-9)
#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Parte III]
  #v(0.5em)
  #text(size: 16pt)[Inferencia para agentes]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[
      La evaluación de una política comienza por relacionar su valor con los
      datos disponibles. Después podemos estudiar su incertidumbre y revisar
      qué conclusión permite utilizar un resultado en un agente. Cada paso
      conserva el objetivo, el muestreo y las condiciones de su procedimiento.
    ]
  ]
]
#pagebreak()

#include "capitulos/cap07_ope.typ"
#include "capitulos/cap08_intervalos.typ"
#include "capitulos/cap09_verificacion.typ"

// PARTE IV — Ejercicio y límites (Capítulos 10-12)
#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Parte IV]
  #v(0.5em)
  #text(size: 16pt)[Ejercicio y límites]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Los resultados anteriores adquieren una interpretación concreta al reproducir sus cálculos. Los casos permiten seguir la relación entre modelo, datos y decisión; el despliegue obliga a revisarla cuando cambia el sistema. Las preguntas que quedan abiertas cierran el recorrido.]
  ]
]
#pagebreak()

#include "capitulos/cap10_casos.typ"
#include "capitulos/cap11_despliegue.typ"
#include "capitulos/cap12_problemas.typ"

// -----------------------------------------------------------------------------
// APÉNDICES (paridad con \appendix: numeración A, B, C... desde este punto)
// -----------------------------------------------------------------------------
#mark-appendix-start()

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Apéndices]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Las demostraciones y los materiales de consulta permiten volver sobre los argumentos del libro. La notación, las condiciones de regularidad y los diseños de reproducción se leen junto con el resultado o el experimento al que pertenecen.]
  ]
]
#pagebreak()

#include "apendices/apendice_demostraciones.typ"
#include "apendices/apendice_glosario.typ"
#include "apendices/apendice_langgraph.typ"
#include "apendices/apendice_medido.typ"
#include "apendices/apendice_tablas.typ"
#include "apendices/apendice_regularidad.typ"
#include "apendices/apendice_reproduccion.typ"

// -----------------------------------------------------------------------------
// BACKMATTER
// -----------------------------------------------------------------------------
#heading(level: 1, numbering: none)[Bibliografía]
#bibliography("referencias.bib", title: none, style: "apa")
