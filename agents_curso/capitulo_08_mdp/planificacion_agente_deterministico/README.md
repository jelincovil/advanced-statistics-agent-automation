# Planificación de un Agente Estadístico Determinístico

Documento de planificación basado en el material del Capítulo 8 (MDPs, operador
de Bellman, convergencia de Value Iteration) y en el análisis crítico de
`agente_8.txt`.

## Archivos

- `planificacion_agente_deterministico.tex` — Código fuente LaTeX.
- `planificacion_agente_deterministico.pdf` — PDF compilado (8 páginas, A4).

## Compilación

```bash
tectonic planificacion_agente_deterministico.tex
# o, alternativamente:
pdflatex planificacion_agente_deterministico.tex && pdflatex planificacion_agente_deterministico.tex
```

Requiere TikZ (`tikz` + librerías `positioning, arrows.meta, calc, fit,
shapes.geometric, backgrounds`).

## Estructura del documento

1. **Motivación y marco conceptual** — el agente determinístico como pieza
   elegante pero frágil del formalismo de Bellman.
2. **Definición formal** — tupla (π, V, P̂, r̂, D), ecuación de Bellman para
   políticas, operador T^π.
3. **Supuestos operativos** — suficiencia de Markov, conocimiento de P,
   estacionariedad, overlap.
4. **Arquitectura del agente** — diagrama TikZ del pipeline
   estado → política → acción → transición → estimación → replanificación.
5. **Algoritmo determinista** — VI con modelo estimado, política greedy,
   criterio de parada recomendado y ejemplo numérico ilustrativo.
6. **Modos de falla** — Markov roto, P̂ sesgado, ausencia de overlap,
   explotación prematura, con ilustración clínica SSCH.
7. **Conexión con el Capítulo 11 y el isomorfismo Wald–MDP** — mezcla lenta,
   IC anchos, recursión de riesgo.
8. **Recomendaciones de diseño** — seis reglas operativas R1–R6.

## Macros heredadas

`\cT`, `\Vopt`, `\Vpi`, `\norminf`, `\cS`, `\cA`, `\ones`, `\R`, más macros
propias del documento (`\Phat`, `\rhat`, `\pibeh`, `\pigreedy`, `\risk`).
