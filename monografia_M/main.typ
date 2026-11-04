// Statistical Guarantees for Sequential Decision Agents — monograph M.
#import "plantilla_M.typ": *

#show: libro

// -----------------------------------------------------------------------------
// FRONTMATTER
// -----------------------------------------------------------------------------
#set page(numbering: "i")
#counter(page).update(1)

#align(center)[
  #v(4em)
  #text(size: 20pt, weight: "bold")[
    Statistical Guarantees for Sequential Decision Agents
  ]
  #v(1.5em)
  #text(size: 13pt, style: "italic")[
    Risk, Representation, and Verification
  ]
  #v(1em)
  #text(size: 11pt)[
    From Wald's decision theory and Markov decision processes\
    to evaluation, inference, and verifiable guarantees for agents
  ]
  #v(3em)
  #text(size: 14pt)[Jaime Lincovil]\
  #text(size: 12pt)[Lima, Peru]
  #v(1em)
  #text(size: 12pt)[Draft v0.1-M · 2026]
]
#pagebreak()

// Epigraph
#align(center + horizon)[
  #block(width: 80%)[
    #emph[
      An optimal policy has the property that whatever the initial state and
      initial decision are, the remaining decisions must constitute an optimal
      policy with regard to the state resulting from the first decision.
    ]
    #v(1em)
    --- #cite(<bellman1957dynamic>, form: "prose")
  ]
]
#pagebreak()

// Preface
#include "partes/prefacio.typ"

#heading(level: 1, numbering: none)[Contents]
#outline(title: none, indent: auto)
#pagebreak()

#list-of("figura", [List of Figures])
#pagebreak()
#list-of("tabla", [List of Tables])
#pagebreak()

// -----------------------------------------------------------------------------
// MAINMATTER
// -----------------------------------------------------------------------------
#set page(numbering: "1")
#counter(page).update(1)

#include "partes/p1_intro.typ"

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Part I]
  #v(0.5em)
  #text(size: 16pt)[Representation: what a decision problem is]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Statistical experiments organize what can be learned from
    data; Wald's framework compares rules by risk; dynamic programming adds
    the future. One representation theorem and one stopping result tie these
    languages together with information constraints kept explicit.]
  ]
]
#pagebreak()

#include "partes/p1_ch01_experiments.typ"
#include "partes/p1_ch02_wald.typ"
#include "partes/p1_ch03_mdp.typ"
#include "partes/p1_ch04_representation.typ"
#include "partes/p1_ch05_stopping.typ"

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Part II]
  #v(0.5em)
  #text(size: 16pt)[Estimation with someone else's data]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Evaluating a policy means identifying its functional in
    the observed law, estimating it under the actual sampling regime, and
    quantifying uncertainty at the right scale — including while the
    experiment still runs.]
  ]
]
#pagebreak()

#include "partes/p2_ch06_identification.typ"
#include "partes/p2_ch07_estimators.typ"
#include "partes/p2_ch08_anytime.typ"
#include "partes/p2_ch09_learned.typ"

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Part III]
  #v(0.5em)
  #text(size: 16pt)[Transfer and verification]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[A guarantee is an object with premises. Transfer
    certificates make those premises algebraic; a real-data study executes the
    protocol end to end; the frontier asks what survives when actions are
    text and policies are unobserved.]
  ]
]
#pagebreak()

#include "partes/p3_ch10_certificates.typ"
#include "partes/p3_ch11_realdata.typ"
#include "partes/p3_ch12_llm.typ"
#include "partes/p3_ch13_open.typ"

// -----------------------------------------------------------------------------
// APPENDICES
// -----------------------------------------------------------------------------
#mark-appendix-start()

#pagebreak()
#align(center + horizon)[
  #text(size: 22pt, weight: "bold")[Appendices]
  #v(2em)
  #block(width: 70%)[
    #text(size: 12pt)[Proofs support every result used in the body; the tools
    appendix is reference only, organized by what the rest of the book
    invokes. The synthetic SSCH thread is consolidated for exercises and
    replication.]
  ]
]
#pagebreak()

#include "apendices/a_proofs.typ"
#include "apendices/b_tools.typ"
#include "apendices/c_ssch.typ"
#include "apendices/d_reproduction.typ"
#include "apendices/e_notation.typ"

// -----------------------------------------------------------------------------
// BACKMATTER
// -----------------------------------------------------------------------------
#heading(level: 1, numbering: none)[Bibliography]
#bibliography("referencias_M.bib", title: none, style: "apa")
