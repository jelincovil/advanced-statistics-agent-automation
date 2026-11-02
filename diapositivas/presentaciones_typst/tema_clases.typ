// Tema para clases sustantivas con contenido Typst y notas separadas.
#let handout = sys.inputs.at("handout", default: "false") == "true"
#let s(n,total,section,title,body,note,ref) = [
  #pagebreak(weak: true)
  #rect(width: 100%, height: 0.07in, fill: rgb("#183A63"))
  #v(0.14in)
  #text(size: 10pt, weight: "bold", fill: rgb("#7046A4"))[#section]
  #v(0.18in)
  #text(size: 27pt, weight: "bold")[#title]
  #v(0.27in)
  #body
  #if handout [
    #v(0.17in)
    #rect(width: 100%, fill: rgb("#EDF2F8"), inset: 9pt, radius: 5pt)[
      #text(size: 10pt, weight: "bold")[Notas docentes · #note]
    ]
  ]
  #v(1fr)
  #line(length: 100%, stroke: 0.6pt + rgb("#B8C6D8"))
  #text(size: 9pt, fill: rgb("#45556B"))[#ref]
  #h(1fr)
  #text(size: 9pt, fill: rgb("#45556B"))[#n / #total]
]
