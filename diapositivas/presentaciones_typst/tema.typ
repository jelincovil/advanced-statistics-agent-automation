// Tema común de presentaciones académicas. Typst 0.15.1.
#let handout = sys.inputs.at("handout", default: "false") == "true"
#let frame(number, total, section, title, body, detail, notes, source) = [
  #pagebreak(weak: true)
  #rect(width: 100%, height: 0.07in, fill: rgb("#183A63"))
  #v(0.2in)
  #text(size: 10pt, weight: "bold", fill: rgb("#7046A4"))[#section]
  #v(0.25in)
  #text(size: 29pt, weight: "bold")[#title]
  #v(0.45in)
  #text(size: 22pt)[#body]
  #v(0.36in)
  #rect(width: 100%, fill: rgb("#EDF2F8"), inset: 14pt, radius: 7pt)[
    #text(size: 18pt)[#detail]
  ]
  #if handout [
    #v(0.25in)
    #text(size: 11pt, weight: "bold")[Notas docentes]
    #v(0.05in)
    #text(size: 11pt)[#notes]
  ]
  #v(1fr)
  #line(length: 100%, stroke: 0.6pt + rgb("#B8C6D8"))
  #text(size: 9pt, fill: rgb("#45556B"))[#source]
  #h(1fr)
  #text(size: 9pt, fill: rgb("#45556B"))[#number / #total]
]
