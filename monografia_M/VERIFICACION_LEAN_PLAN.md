# VERIFICACIÓN LEAN — plan por fases para los resultados de M

**Emitido:** 2026-11-03 · **Objeto:** verificación mecánica (Lean 4 + Mathlib)
de los resultados del manuscrito M. **Regla madre:** se formaliza lo que se
afirma — incluidas las hipótesis. Un teorema formalizado con hipótesis más
fuertes que las del texto se declara como tal.

## Estado actual

**Fase 0 — COMPLETA.** Las tres identidades centrales del cap. 4 están
máquina-verificadas sin `sorry`:

| Resultado del texto | Teorema Lean | Estado |
|---|---|---|
| J_θ(π_δ) = −R(θ,δ) | `m_repr` | ✅ verificado |
| J_ν(π_δ) = −ρ_ν(δ) | `m_bayes` | ✅ verificado |
| dominancia ⇔ retorno-dominancia | `m_admis` | ✅ verificado |

Archivo: `monografia_M/pilot_core_proven.lean` — elabora limpio con
`lean pilot_core_proven.lean` (Lean 4.33.1, Mathlib de `/opt/mathlib`).
Obtenido por la corrida de discovery `lean-pilot-mopsis` (3/3 problemas
resueltos, 2026-11-03) y reconstruido en archivo canónico.
*Alcance honesto:* con conjuntos finitos, las identidades son identidades de
sumas finitas; la estructura de medida (normalización de P_θ) no se usa — el
texto tampoco la necesita. La sobreyectividad/biyectividad de F es trivia de
tipos (mismo tipo función) y no se declara como teorema separado.

## Qué es formalizable y qué no (aceptación anticipada)

| Categoría | Tratamiento |
|---|---|
| Identidades finitas de suma/conjunto (repr., transferencias, frontera finita) | Formalizar (Fases 1–2) |
| Recursión de parada bayesiana con espacios finitos | Formalizar (Fase 2; inducción estructurada) |
| Propiedad de contracción (sup-norma, espacios finitos) y cotas residuales | Formalizar (Fase 2) |
| Insesgadez IS / doble robustez **en espacios finitos** (sumas, no esperanzas abstractas) | Formalizar (Fase 3) |
| Ville para martingalas discretas acotadas + e-proceso Hoeffding (cota de factores) | Fase 4 (necesita martingalas en Mathlib: existe `MeasureTheory.Martingale`; Ville para parada acotada es tratable, la versión no acotada vía Fatou es costosa) |
| Resultados asintóticos (CLT, delta, mixing, eficiencia) | **No** en este plan: dependen de teoría de probabilidad en Mathlib (Lindeberg CLT presente; mixing/HAC no) — se declara cobertura y se deja fuera, no se maquillan. |

## Fases

**Fase 1 (criterio: build verde) — Infraestructura mínima propia.**
Proyecto `lean_verify/` con lakefile apuntando a la Mathlib del sistema;
módulo `FiniteWald.lean`: `FinitePmf` (pesos no negativos que suman 1),
esperanza como suma, problema de Wald, MDP de una decisión; re-prueba de la
Fase 0 sobre la infraestructura; `#print axioms` adjunto al informe (objetivo:
solo `propext`, `Classical.choice`, `Quot.sound`).

**Fase 2 — Parte I del libro.**
- a) Frontera (thm:m-frontier) finita: estrategias como funciones de historia;
  alcance positivo de una historia bajo prefijos comunes; el argumento del
  cilindro como desigualdad de probabilidades de eventos. Es el primer
  enunciado con contenido genuino (no simp): esfuerzo principal de la fase.
- b) Parada bayesiana (thm:m-secuencial): estado `(k, b)` con
  `b : Θ → ℝ≥0` normalizado; inducción sobre `k`; existencia del mínimo por
  finitud. Subtareas ensayadas primero: actualización `B(b,y)` y ley
  predictiva computables.
- c) Contracción Bellman (norma sup en `X → ℝ` finito) + cotas residuales
  del cor:m-parada (álgebra de desigualdades, `linarith`-friendly).

**Fase 3 — Parte II finita.**
IS insesgado (factorización y cancelación de kernels en espacios finitos,
`Finset.prod`/`sum`), identidad DR de una decisión como identidad
algebraica de sumas, cota de la maldición del horizonte (`c^H`). Cada uno
con sus hipótesis de soporte escritas (`b(a|s) > 0` donde hace falta).

**Fase 4 — Anytime-valid discreto.**
Ville para parada acotada (inducción + Markov), e-proceso Hoeffding como
supermartingala con factores `K_t` (condición `E[K|F] ≤ 1` como hipótesis
demostrada para el caso Bernoulli-acotado por convexidad elemental), y la CS
inducida como teorema de cobertura uniforme sobre tiempos acotados. La
versión no acotada se declara OPEN si se alcanza.

**Fase 5 — Certificados como reglas (V2).**
R1 (contención de eventos) trivial en Lean; R3 y los contraejemplos como
teoremas de existencia de dos leyes con la misma proyección observada
(construcción explícita en tipos finitos). Conecta `certificado` como
estructura con un campo `sound : (∀ conds discharged) → claim`.

## Proceso

1. Cada enunciado nuevo se valida primero con `sorry` localmente (como en la
   Fase 0), luego pasa a una corrida de discovery acotada
   (`model_calls_per_problem ≤ 300`, `max_usd_per_problem ≤ 2`), con la
   prueba resultante re-elaborada localmente y registrada en
   `lean_verify/` + informe `#print axioms`.
2. Ningún `sorry` entra al informe final: si un resultado queda OPEN, el
   archivo no lo contiene como `theorem` sino como comentario de alcance.
3. El plan NO afirma verificación completa del libro: los asíntóticos quedan
   fuera por diseño (columna derecha de la tabla), declarado aquí y en el
   cap. 13.

## Coste y responsabilidades

- Fases 1–3: trabajo de 2–3 coridas de discovery más sesiones de ajuste
  local (esta VM tiene toolchain + Mathlib precompilados).
- Fase 4: riesgo medio (martingalas); degradación preacordada: versión
  acotada solamente.
- El capítulo 13 de M enlaza este inventario como trabajo de verificación
  continua; cualquier resultado nuevo de M hereda la regla: enunciado Lean
  con `sorry` antes de afirmar, prueba antes de publicar.
