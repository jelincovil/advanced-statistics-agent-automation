// =============================================================================
// PLANTILLA — Teoría Avanzada de Inferencia Estadística para Agentes Inteligentes
// Puerto de main.tex (preámbulo LaTeX) a Typst.
// =============================================================================

// -----------------------------------------------------------------------------
// COLORES (paridad con \definecolor de main.tex)
// -----------------------------------------------------------------------------
#let waldcolor = rgb(0, 102, 153)
#let mdpcolor = rgb(153, 51, 0)
#let bridgecolor = rgb(102, 0, 102)

// -----------------------------------------------------------------------------
// MACROS DE NOTACIÓN (paridad con \newcommand de main.tex)
// -----------------------------------------------------------------------------

// Notación de densidad: distinción frecuentista vs. bayesiana
#let fcl(x: $x$) = $f_theta (#x)$
#let fba(x: $x$) = $f(#x | theta)$
#let pcl(x: $x$) = $p_theta (#x)$
#let pba(x: $x$) = $p(#x | theta)$

// Espacios y conjuntos numéricos
#let RR = $bb(R)$
#let NN = $bb(N)$
#let ZZ = $bb(Z)$
#let EE = $bb(E)$
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Prob = $bb(P)$

// Espacios del curso
#let ParamSpace = $Theta$
#let SampleSpace = $cal(X)$
#let ActionSpace = $cal(A)$
#let StateSpace = $cal(S)$
#let ObsSpace = $cal(O)$
#let PolicySet = $Pi$
#let DecisionSet = $cal(D)$

// Funciones
#let Loss = $L$
#let Risk = $R$
#let Value = $V$
#let Qfunc = $Q$
#let reward = $r$
#let policy = $pi$
#let behavpolicy = $pi_b$
#let decrule = $delta$
#let prior = $pi_("prior")$
#let priordist = $pi_("prior")$
#let discount = $gamma$

// Operadores
#let BellmanOp = $cal(T)$
#let argmax = math.op("arg max", limits: true)
#let argmin = math.op("arg min", limits: true)

// Isomorfismo
#let isoto = $<->$

// Factor de Bayes, Regret, KL, independencia
#let BF = math.op("BF")
#let Regret = math.op("Regret")
#let KL = math.op("KL")
#let independent = $perp$

// -----------------------------------------------------------------------------
// REFERENCIAS A APÉNDICES (paridad con \verdem, \verlanggraph, \vertabla)
// -----------------------------------------------------------------------------
// Uso: #verdem(<label-de-la-demostracion-en-el-apendice>)
// NOTA: `supplement: none` porque \ref{} en LaTeX solo da el número (no
// antepone "Capítulo"), a diferencia del @ref de Typst por defecto.
#let verdem(target) = context {
  let elem = query(target).first()
  let loc = elem.location()
  let page-format = loc.page-numbering()
  let page-num = numbering(if page-format == none { "1" } else { page-format }, ..counter(page).at(loc))
  [(argument and scope in Appendix~#ref(<app:demostraciones>, supplement: none), p.~#page-num)]
}
// Alias de posición para subsecciones de apendice_demostraciones.typ que
// en LaTeX tenían múltiples \label{} (histórico) sobre la misma
// \subsection — verdem() solo necesita la posición (query + página), no
// un número, así que basta un marcador sin metadata.
#let dem-alias(key) = [#metadata(none)#label(key)]
#let verlanggraph = [(see Appendix~#ref(<app:langgraph>, supplement: none))]
// Uso: #vertabla(<label-de-la-tabla-en-el-apendice>)
// NOTA: #ref(target) ya antepone el supplement ("Tabla") automáticamente, a
// diferencia de \ref{} en LaTeX que da solo el número — no repetir "Tabla~".
#let vertabla(target) = [(see #ref(target) in Appendix~#ref(<app:tablas>, supplement: none))]

// Advertencia reutilizable para el caso ilustrativo SSCH. Todo el hilo
// conductor del SSCH es un escenario sintético: ninguna de sus cifras
// procede de un estudio clínico. Uso: #ejemplo-sintetico[texto]
#let ejemplo-sintetico(body) = block(
  above: 0.8em,
  below: 0.8em,
  width: 100%,
  stroke: 0.5pt + mdpcolor,
  inset: 8pt,
)[
  #set text(size: 9.5pt)
  *Synthetic figures.* #body
]

// Marca inline para los ejemplos del caso sintético SSCH: va junto al número
// del enunciado, para que la condición de sintético sea visible al hojear sin
// repetir la advertencia completa. Se activa con `es-sintetico: true`.
#let sintetico = text(size: 8pt, style: "italic", fill: mdpcolor)[(synthetic)]

// Marcador de hueco visible en el PDF. No es una nota de trabajo: es la
// declaración, para el lector, de que ahí falta algo que el manuscrito todavía
// no puede sostener. Debe desaparecer cuando el hueco se cierre, no antes.
// Uso: #pendiente[qué falta exactamente ahí]
#let pendiente(body) = block(
  width: 100%, inset: 8pt, stroke: 1pt + red,
)[ #text(fill: red, weight: "bold")[OPEN — ] #body ]

// -----------------------------------------------------------------------------
// ENTORNOS DE TEOREMA (contador compartido por capítulo, paridad con main.tex)
// -----------------------------------------------------------------------------
// LaTeX: definition/example/theorem/proposition/lemma/corollary/note/problem
//        comparten UN contador (vía [definition]), reiniciado por capítulo.
//        assumption y exercise tienen contador propio, también por capítulo.
//        solution y proofsketch son entornos sin numerar.

// IMPORTANTE — hallazgo de Typst 0.15 documentado aquí porque no es obvio:
// un `figure(numbering: n => context { counter(X).get()... })` que consulta
// OTRO contador dentro de la función de numeración se evalúa, para efectos
// de una REFERENCIA (`@label`) hecha en otro lugar del documento, en la
// posición de la CITA, no en la posición del elemento citado. Esto rompe
// referencias cruzadas entre capítulos (una tabla del cap. 1 referenciada
// desde el cap. 2 imprime "Tabla 2.1" en vez de "Tabla 1.1"). Probado con
// contador propio y con `counter(heading.where(level:1))` nativo: mismo bug.
// Por eso NO se usa el mecanismo nativo de `figure(numbering: ...)` para
// nada que se numere junto con el capítulo. En su lugar, todo (teoremas,
// tablas, figuras) usa el patrón `thm-env`: el número final (ej. "1.1") se
// calcula UNA VEZ, en el momento y lugar de creación del elemento, y se
// hornea como valor plano dentro de `metadata(...)`. Las referencias leen
// ese valor horneado (`ref-show-rule` más abajo) en vez de recalcularlo, así
// que son correctas sin importar desde dónde se citen.
#let chapter-counter = counter(heading.where(level: 1))

// -----------------------------------------------------------------------------
// NUMERACIÓN DE APÉNDICES CON LETRAS (paridad con \appendix de LaTeX book.cls:
// \appendix NO reinicia el contador de capítulos, solo cambia su FORMATO de
// visualización de arábigo a A/B/C... a partir de ese punto). `chapter-counter`
// sigue siendo un contador numérico continuo (14, 15, 16... para los 8
// apéndices); `chapter-display()` es el único punto que decide si un número de
// capítulo dado se muestra como dígito o como letra, usado tanto en el
// encabezado de capítulo/apéndice como en toda referencia horneada
// (`ref-show-rule`) y en la numeración nativa de headings de nivel 2+
// (`heading-numbering`). Llamar a `#mark-appendix-start()` una sola vez en
// main.typ justo antes del primer apéndice.
// -----------------------------------------------------------------------------
#let appendix-boundary = state("appendix-boundary", none)
#let mark-appendix-start() = context appendix-boundary.update(chapter-counter.get().first())

// NOTA: usa `.final()` (no `.get()`) porque el límite se fija UNA sola vez
// en todo el documento (vía `mark-appendix-start()`) y luego nunca cambia;
// `.get()` da el valor "a esta altura del documento" (`none` si se lee
// antes de esa marca, p.ej. desde `list-of()` en el frontmatter), mientras
// que `.final()` da el valor definitivo sin importar la posición de
// lectura — exactamente lo que se necesita para un límite global fijo.
#let chapter-display(n) = context {
  let boundary = appendix-boundary.final()
  if boundary != none and n > boundary {
    numbering("A", n - boundary)
  } else {
    str(n)
  }
}

// Función de numeración de headings (paridad con `set heading(numbering:
// "1.1")`, pero con la primera componente pasando por `chapter-display`).
#let heading-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 {
    chapter-display(n.at(0))
  } else {
    chapter-display(n.at(0)) + [.] + [#(n.slice(1).map(str).join("."))]
  }
}

#let thm-counter = counter("thm-counter")
#let assumption-counter = counter("assumption-counter")
#let exercise-counter = counter("exercise-counter")
#let table-counter = counter("table-counter")
#let image-counter = counter("image-counter")

#let thm-names = (
  definition: "Definition",
  example: "Example",
  theorem: "Theorem",
  proposition: "Proposition",
  lemma: "Lemma",
  corollary: "Corollary",
  conjecture: "Conjecture",
  note: "Note",
  problem: "Problem",
)

// Reinicio de contadores en cada \chapter (heading nivel 1).
// chapter-counter (= counter(heading.where(level:1))) se incrementa solo,
// vía `set heading(numbering: "1.1")"; aquí solo reiniciamos los propios.
#let reset-thm-counters(it) = {
  thm-counter.update(0)
  assumption-counter.update(0)
  exercise-counter.update(0)
  table-counter.update(0)
  image-counter.update(0)
  it
}

// Referencias cruzadas: imprime "Definición 2.3" etc. para @label de un entorno
// NOTA: esta show-rule se registra dentro de `libro()`, no aquí a nivel de
// módulo — un `#show` a nivel de módulo no se aplica al documento que hace
// `#import "plantilla.typ": *`, solo se exportan los bindings.
#let ref-show-rule = it => {
  if it.element != none and it.element.func() == metadata {
    let v = it.element.value
    if v != none and type(v) == dictionary and "word" in v {
      // supplement: none => paridad con \ref{} de LaTeX (solo el número,
      // sin anteponer la palabra "Tabla"/"Teorema"/etc.), usado en tablas
      // de referencia cruzada compactas (p.ej. columna "Cap.").
      let bare = it.supplement == none
      let ch-disp = chapter-display(v.ch)
      if "n" in v and v.n != none {
        if bare {
          link(it.element.location(), [#ch-disp.#v.n])
        } else {
          link(it.element.location(), [#v.word~#ch-disp.#v.n])
        }
      } else {
        // Alias de capítulo (sin sub-número), ej. un \label extra sobre
        // \chapter que en LaTeX apunta al mismo número de capítulo.
        if bare {
          link(it.element.location(), [#ch-disp])
        } else {
          link(it.element.location(), [#v.word~#ch-disp])
        }
      }
    } else {
      it
    }
  } else {
    it
  }
}

// Alias de un heading de capítulo (paridad con un segundo \label{...}
// inmediatamente después de \chapter{...}, que en LaTeX captura el mismo
// número). Uso: justo después de la heading `= Título <ch:principal>`,
// agregar `#chapter-alias("ch:alias")`.
#let chapter-alias(key) = context {
  let ch = chapter-counter.get().first()
  [#metadata((word: "Chapter", ch: ch))#label(key)]
}

// Análogo a chapter-alias pero para un heading de nivel 2 (paridad con un
// segundo \label{...} después de \subsection{...}). Uso: justo después de
// `== Título <sec:principal>`, agregar `#section-alias("sec:alias")`.
#let section-alias(key, word: "Section") = context {
  let c = counter(heading).get()
  [#metadata((word: word, ch: c.at(0), n: c.at(1)))#label(key)]
}

// `aliases`: labels adicionales que apuntan al MISMO teorema (paridad con
// varios \label consecutivos en LaTeX que capturan el mismo número —
// patrón usado cuando el original quiere referenciar el mismo resultado
// con nombres distintos).
#let thm-env(kind, body, name: none, key: none, aliases: (), es-sintetico: false) = [
  #thm-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = thm-counter.get().first()
    let word = thm-names.at(kind)
    block(above: 1em, below: 1em, width: 100%)[
      #if key != none { [#metadata((word: word, ch: ch, n: n))#label(key)] }
      #for a in aliases { [#metadata((word: word, ch: ch, n: n))#label(a)] }
      #if kind == "theorem" or kind == "proposition" or kind == "lemma" or kind == "corollary" [
        *#word #ch-disp.#n#if es-sintetico [ #sintetico]#if name != none [ (#name)].* #emph(body)
      ] else [
        *#word #ch-disp.#n#if es-sintetico [ #sintetico]#if name != none [ (#name)].* #body
      ]
    ]
  }
]

#let assumption-env(body, name: none, key: none) = [
  #assumption-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = assumption-counter.get().first()
    block(above: 1em, below: 1em, width: 100%)[
      #if key != none { [#metadata((word: "Assumption", ch: ch, n: n))#label(key)] }
      *Assumption #ch-disp.#n#if name != none [ (#name)].* #body
    ]
  }
]

#let exercise-env(body, key: none) = [
  #exercise-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = exercise-counter.get().first()
    block(above: 1em, below: 0.5em, width: 100%)[
      #if key != none { [#metadata((word: "Exercise", ch: ch, n: n))#label(key)] }
      *Exercise #ch-disp.#n.* #emph(body)
    ]
  }
]

// Paridad con \begin{algorithm}...\caption{}...\end{algorithm} (paquete
// `algorithm`, sin algpseudocode — en este libro son listas numeradas con
// caption, no pseudocódigo formal). Uso:
//   #algorithm-env(caption: [Mi algoritmo], key: "alg:x")[+ Paso 1 ...]
#let algorithm-counter = counter("algorithm-counter")
#let algorithm-env(body, caption: none, key: none) = [
  #algorithm-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = algorithm-counter.get().first()
    block(above: 1em, below: 1em, width: 100%, stroke: 0.5pt, inset: 8pt)[
      #if key != none { [#metadata((word: "Algorithm", ch: ch, n: n))#label(key)] }
      #text(size: 10pt)[*Algorithm #ch-disp.#n*#if caption != none [: #caption] else [.]]
      #v(0.3em)
      #body
    ]
  }
]

// Paridad con \begin{lstlisting}[caption=...] (paquete `listings`, sin
// \counterwithin{lstlisting}{chapter} en main.tex) — numeración GLOBAL
// (no reiniciada por capítulo) a través de todo el libro, rotulada
// "Listado N" (babel spanish). Ningún \label{lst:...} referencia estos
// bloques en el original, así que no necesita metadata-baking.
#let codelisting-counter = counter("codelisting-counter")
#let codelisting-env(body, caption: none) = [
  #codelisting-counter.step()
  #context {
    let n = codelisting-counter.get().first()
    block(above: 1em, below: 1em, width: 100%)[
      #body
      #v(0.3em)
      #text(size: 10pt)[*Listado #n*#if caption != none [: #caption] else [.]]
    ]
  }
]

// -----------------------------------------------------------------------------
// TABLAS Y FIGURAS NUMERADAS POR CAPÍTULO (paridad con book.cls; NO usar
// `#figure(...)` nativo con `@label` para nada que se cite entre capítulos —
// ver nota arriba sobre el bug de referencias). Uso:
//   #mi-tabla(table(columns: 3, [...]), caption: [Mi tabla], key: "tab:x")
//   #mi-figura(image("../imagenes/x.png"), caption: [Mi figura], key: "fig:x")
// -----------------------------------------------------------------------------
// Marcador invisible para las listas de tablas/figuras (paridad con
// \listoffigures/\listoftables) — separado del `metadata` usado por
// `key`/`aliases` para no interferir con `ref-show-rule`.
#let listing-entry(kind, ch, n, caption) = metadata((kind: kind, ch: ch, n: n, caption: caption))

#let mi-tabla(content, caption: none, key: none, aliases: ()) = [
  #table-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = table-counter.get().first()
    align(center)[
      #content
      #v(0.5em)
      #if key != none { [#metadata((word: "Table", ch: ch, n: n))#label(key)] }
      #for a in aliases { [#metadata((word: "Table", ch: ch, n: n))#label(a)] }
      #listing-entry("tabla", ch, n, caption)
      #text(size: 10pt)[*Table #ch-disp.#n*#if caption != none [: #caption] else [.]]
    ]
  }
]

#let mi-figura(content, caption: none, key: none) = [
  #image-counter.step()
  #context {
    let ch = chapter-counter.get().first()
    let ch-disp = chapter-display(ch)
    let n = image-counter.get().first()
    align(center)[
      #content
      #v(0.5em)
      #if key != none { [#metadata((word: "Figure", ch: ch, n: n))#label(key)] }
      #listing-entry("figura", ch, n, caption)
      #text(size: 10pt)[*Figure #ch-disp.#n*#if caption != none [: #caption] else [.]]
    ]
  }
]

// Paridad con \listoffigures / \listoftables. Uso: #list-of("figura",
// [Índice de Figuras]) / #list-of("tabla", [Índice de Tablas]).
#let list-of(kind, title) = {
  heading(level: 1, numbering: none)[#title]
  context {
    let entries = query(metadata).filter(el => (
      type(el.value) == dictionary and "kind" in el.value and el.value.kind == kind
    ))
    for el in entries {
      let v = el.value
      let ch-disp = chapter-display(v.ch)
      let loc = el.location()
      let page-format = loc.page-numbering()
      let page-num = numbering(if page-format == none { "1" } else { page-format }, ..counter(page).at(loc))
      block(above: 0.5em, below: 0.5em)[
        #box(width: 3em)[#ch-disp.#v.n] #box(width: 1fr)[#(if v.caption != none { v.caption } else { [] })] #box[#page-num]
      ]
    }
  }
}

// Sin numerar (paridad con \newenvironment{solution}/{proofsketch})
#let solution-env(body) = block(above: 1em, below: 1em, width: 100%)[
  *Solution.* #emph(body) #h(1fr) $square$
]

#let proofsketch-env(body) = block(above: 1em, below: 1em, width: 100%)[
  _Proof sketch._ #body #h(1fr) $square$
]

// Paridad con \begin{proof} (amsthm estándar, vía babel[spanish] se
// traduce a "Demostración."). Usado en varios capítulos para demostraciones
// completas (no sketches).
// `full:` reemplaza el encabezado por completo (paridad con
// \begin{proof}[Texto] de amsthm cuando el texto NO empieza con
// "Demostración", p.ej. "Esquema de demostración del Teorema~X").
#let proof-env(body, name: none, full: none) = block(above: 1em, below: 1em, width: 100%)[
  #if full != none [_#full._] else if name != none [_Proof #name._] else [_Proof._] #body #h(1fr) $square$
]

// -----------------------------------------------------------------------------
// PÁGINA, TIPOGRAFÍA, IDIOMA (paridad con geometry/babel/fancyhdr)
// -----------------------------------------------------------------------------
#let watermark-text = "DRAFT v0.1-M — Statistical Guarantees for Sequential Decision Agents"

// Regla horizontal para tablas estilo booktabs (paridad con \toprule / \midrule
// / \bottomrule). Uso dentro de un `#table(...)`:
//   #table(columns: .., stroke: none,
//     hl(), table.header([*A*], [*B*]), hl(w: 0.6pt),
//     [1], [2],
//     hl(),
//   )
#let hl(w: 1pt) = table.hline(stroke: w)

// Paridad con \chapter* de LaTeX: capítulo sin número (prefacio, notación,
// introducción). NO consume un valor del contador de capítulo, a diferencia
// de un `= Título` normal. Uso:
//   #cap-sin-numero[= Prefacio <prefacio>]
#let cap-sin-numero(body) = {
  set heading(numbering: none)
  body
}

// Paridad con \epigraph{cita}{atribución} (paquete epigraph). Uso:
//   #epigraph[«Cita.»][Autor, año]
#let epigraph(quote, author) = align(right)[
  #block(width: 60%)[
    #emph(quote)
    #v(0.3em)
    #align(right)[--- #author]
  ]
  #v(1em)
]

#let libro(body) = {
  set document(title: "Statistical Guarantees for Sequential Decision Agents: Risk, Representation, and Verification", author: "Jaime Lincovil")
  set text(lang: "en", size: 11pt)
  show ref: ref-show-rule
  set page(
    paper: "a4",
    margin: (inside: 3cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: "1",
    background: rotate(45deg, reflow: true)[
      #text(fill: gray.transparentize(94%), size: 40pt)[#watermark-text]
    ],
    header: context {
      let page-num = counter(page).get().first()
      let chapters = query(heading.where(level: 1)).filter(h => h.location().page() <= here().page())
      let chapter-title = if chapters.len() > 0 { chapters.last().body } else { [] }
      set text(size: 9pt, style: "italic")
      if calc.even(page-num) {
        chapter-title
      } else {
        align(right)[#chapter-title]
      }
      line(length: 100%, stroke: 0.4pt)
    },
  )
  set par(justify: true, first-line-indent: 0em)
  set table(stroke: none, inset: 6pt)
  set heading(numbering: heading-numbering)
  show heading.where(level: 1): set heading(supplement: it => context {
    let n = chapter-counter.at(it.location()).first()
    let boundary = appendix-boundary.final()
    if boundary != none and n > boundary [Appendix] else [Chapter]
  })
  show heading.where(level: 2): set heading(supplement: [Section])

  show heading.where(level: 1): it => {
    set par(justify: false)
    pagebreak(weak: true)
    reset-thm-counters(none)
    v(2em)
    if it.numbering != none {
      context {
        let n = chapter-counter.get().first()
        let boundary = appendix-boundary.final()
        let word = if boundary != none and n > boundary [Appendix] else [Chapter]
        text(size: 14pt, weight: "bold")[#word #chapter-display(n)]
      }
      v(0.3em)
    }
    text(size: 24pt, weight: "bold", hyphenate: false)[#it.body]
    v(1.5em)
  }
  show heading.where(level: 2): it => {
    set par(justify: false)
    v(1em)
    text(size: 16pt, weight: "bold", hyphenate: false)[#it.body]
    v(0.5em)
  }

  body
}
