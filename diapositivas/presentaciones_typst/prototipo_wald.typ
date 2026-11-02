// Prototipo docente: capítulo 2, Wald. Cotejado con ex:ch2-bernoulli-minimax.
#set document(title: "Wald — estimación Bernoulli y criterio minimax")
#set page(width: 13.333in, height: 7.5in, margin: (x: 0.72in, y: 0.46in))
#set text(font: "Liberation Sans", size: 20pt, fill: rgb("#18253B"))
#let handout = sys.inputs.at("handout", default: "false") == "true"
#let s(n, title, body, note, ref) = [
  #pagebreak(weak: true)
  #rect(width: 100%, height: 0.07in, fill: rgb("#183A63"))
  #v(0.15in)
  #text(size: 10pt, weight: "bold", fill: rgb("#7046A4"))[WALD · ESTIMACIÓN Y RIESGO]
  #v(0.2in)
  #text(size: 28pt, weight: "bold")[#title]
  #v(0.32in)
  #body
  #if handout [
    #v(0.18in)
    #rect(width: 100%, fill: rgb("#EDF2F8"), inset: 10pt, radius: 5pt)[
      #text(size: 10pt, weight: "bold")[Notas docentes · #note]
    ]
  ]
  #v(1fr)
  #line(length: 100%, stroke: 0.6pt + rgb("#B8C6D8"))
  #text(size: 9pt, fill: rgb("#45556B"))[#ref]
  #h(1fr)
  #text(size: 9pt, fill: rgb("#45556B"))[#n / 8]
]

#s(1, [¿Qué regla controla el peor riesgo?], [
  Observamos una sola variable Bernoulli y queremos estimar su probabilidad de éxito.
  #v(0.25in)
  #align(center)[$X tilde "Bernoulli"(theta), quad theta in [0,1]$]
  #v(0.3in)
  *Pregunta:* ¿es la regla intuitiva $delta_0(X)=X$ minimax bajo pérdida cuadrática?
], [Abrir con la predicción del grupo. No confundir una observación con la estimación de una media repetida. Tiempo sugerido: 4 minutos.], [Cap. 2 · ex:ch2-bernoulli-minimax])

#s(2, [Modelo, acción y riesgo], [
  La acción es una estimación $a in [0,1]$; su pérdida es $L(theta,a)=(a-theta)^2$.
  #v(0.25in)
  #align(center)[$R(theta,delta)=E_theta[(delta(X)-theta)^2]$]
  #v(0.25in)
  El criterio minimax compara $M(delta)=sup_(theta in [0,1]) R(theta,delta)$.
], [Revisar los cinco objetos: parámetro, observación, familia, acción y pérdida. La regla debe ser medible y el riesgo finito. Tiempo: 5 minutos.], [Cap. 2 · def:ch7-problema; def:ch7-minimax])

#s(3, [La regla directa tiene peor riesgo 1/4], [
  Para $delta_0(X)=X$, el sesgo es cero y la varianza de $X$ es $theta(1-theta)$.
  #v(0.25in)
  #align(center)[$R(theta,delta_0)=theta(1-theta)$]
  #v(0.25in)
  Esta parábola alcanza su máximo en $theta=1/2$:
  #align(center)[$M(delta_0)=1/4.$]
], [Pedir derivar el máximo completando cuadrado o con derivada. La insesgadez no implica minimax. Tiempo: 6 minutos.], [Cap. 2 · ex:ch2-bernoulli-minimax])

#s(4, [Una regla que contrae hacia 1/2], [
  Con prior $ "Beta"(1/2,1/2)$, la media posterior para una observación es
  #v(0.25in)
  #align(center)[$delta_nu(X)=(X+1/2)/2=X/2+1/4.$]
  #v(0.25in)
  Bajo pérdida cuadrática, la media posterior minimiza pérdida posterior esperada: esta regla es Bayes para ese prior.
], [Mostrar actualización Beta(1/2+X, 1/2+1−X). El prior es propio y positivo en el interior. No afirmar que toda regla Bayes sea minimax. Tiempo: 6 minutos.], [Cap. 2 · thm:ch7-bayes; ex:ch2-bernoulli-minimax])

#s(5, [Derivación: el riesgo es constante], [
  #align(center)[$"Sesgo"=1/4-theta/2, quad "Var"=theta(1-theta)/4$]
  #v(0.15in)
  #align(center)[$R(theta,delta_nu)=theta(1-theta)/4+(1/4-theta/2)^2=1/16.$]
  #v(0.18in)
  #text(size: 14pt)[#table(columns: (1fr, 1fr, 1fr), inset: 5pt,
    table.header([$theta$], [$R(theta,delta_0)$], [$R(theta,delta_nu)$]),
    [$0$], [$0$], [$1/16$],
    [$1/2$], [$1/4$], [$1/16$],
    [$1$], [$0$], [$1/16$],
  )]
], [Expandir el cuadrado y cancelar los términos en θ. La regla contraída mejora el peor caso, pero empeora el riesgo en los extremos. Tiempo: 8 minutos.], [Cap. 2 · ex:ch2-bernoulli-minimax])

#s(6, [Certificado minimax, paso a paso], [
  Para cualquier regla $delta$:
  #v(0.18in)
  #align(center)[$sup_theta R(theta,delta) >= rho_nu(delta) >= rho_nu(delta_nu)$]
  #v(0.18in)
  Como $R(theta,delta_nu)=1/16$ para todo $theta$,
  #align(center)[$rho_nu(delta_nu)=sup_theta R(theta,delta_nu)=1/16.$]
  Por tanto, ninguna regla tiene peor riesgo menor y $delta_nu$ es minimax.
], [Explicar cada desigualdad: supremo ≥ promedio; optimalidad Bayes; constancia del riesgo en todo Θ. La igualdad final no se sigue de constancia solo en el soporte del prior. Tiempo: 8 minutos.], [Cap. 2 · thm:ch7-minimax-bayes; prueba inmediata])

#s(7, [Ejercicio: riesgo en dos parámetros], [
  Sin mirar la solución, calcule $R(theta,delta_0)$ y $R(theta,delta_nu)$ para:
  #v(0.3in)
  #align(center)[$theta=0,2 quad "y" quad theta=0,5.$]
  #v(0.3in)
  Después explique por qué «menor peor riesgo» no significa «menor riesgo en cada parámetro».
], [Solución: en θ=0,2, R0=0,16 y Rν=0,0625; en θ=0,5, R0=0,25 y Rν=0,0625. En θ=0, R0=0 < 1/16. Tiempo: 10 minutos con discusión.], [Cap. 2 · cálculo a partir de ex:ch2-bernoulli-minimax])

#s(8, [Qué se ha demostrado y qué falta], [
  *Resultado:* en este modelo de una observación y pérdida cuadrática, $delta_nu$ alcanza riesgo máximo $1/16$.
  #v(0.3in)
  *Alcance:* cambiar pérdida, clase de reglas o diseño de datos requiere un análisis nuevo.
  #v(0.3in)
  *Puente:* un agente que decide repetidamente necesita además dinámica, observación y criterio temporal.
], [Cerrar con la distinción entre decisión terminal y secuencial. Remitir a los capítulos 3 y 5; no transferir automáticamente la prueba minimax a un MDP general. Tiempo: 4 minutos.], [Cap. 2 · thm:ch7-minimax-bayes; cap. 5 · note:ch9-extension-no-demostrada])
