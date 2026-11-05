# verificacion_lean — verificación mecánica del libro `v1.0-libro`

Proyecto Lean 4 + Mathlib que verifica las proposiciones **propias y
críticas** del libro de docencia (`book_stat_inference_v0/`, 275 pp, tag
`v1.0-libro`). Plan aprobado por el autor:
[`../PLAN_LEAN_LIBRO_2026-11-04.md`](../PLAN_LEAN_LIBRO_2026-11-04.md).

## Cómo correr

```bash
cd verificacion_lean
./verificar.sh
```

`verificar.sh` compila cada módulo con `lean` directo (Foundation →
Cap05Representacion → Cap07OPE → Cap06Fronteras → Cap03MDP → SSCH →
Cap02Wald → Cap08Intervalos → Cap11Despliegue → Audit) usando el
`LEAN_PATH` del entorno (Mathlib
precompilada), vuelca la auditoría de axiomas a `build/axioms.log` y falla
si aparece un `sorry` en `Book/` o el axioma prohibido en la auditoría.
Verde = exit 0 con el mensaje final `OK: verificar.sh en verde`.

En esta VM no hay `lake build` local (`/opt/mathlib` es read-only para este
usuario); `lean-toolchain` y `lakefile.toml` están solo para portabilidad
(en otra máquina: `lake exe cache get && lake build`).

El dashboard se regenera tras cada corrida:

```bash
python3 Progress/gen_dashboard.py
```

## Alcance

- Solo resultados **importantes y críticos** del libro; los clásicos
  (LLN, CLT, método delta, bootstrap, Cramér–Rao, Rao–Blackwell, Basu,
  Neyman–Pearson, Benjamini–Hochberg, Wilks, MLE, UCB1, Lai–Robbins,
  Thompson Sampling, SPRT, James–Stein, …) quedan fuera por decisión del
  autor — lista cerrada en el plan §1.
- Inventario priorizado P1/P2/P3 con las claves del libro: plan §2.
- Estado: **F3 cerrada — inventario completo (35/35 filas del plan §2)**.
  P1 14/14: F0 (piloto + minimax), secuencial/Bellman, identificación,
  IS, curse, DR, mejora y certificados de parada, SSCH y transporte de
  conjuntos. P2 13/13: Bayes, minimax-vía-Bayes, admisibilidad y clase
  esencialmente completa (separación de conos), los seis contraejemplos
  del cap. 6, var-DR, baseline y SSCH-Bellman. P3 8/8: cadena de dos
  estados (`σ²_LR = 72`) y gradiente continuo, cuantización,
  truncamiento `H = 46`, monitoreo `α/m(m+1)`, MDP de validación del
  apéndice E, cota espectral reversible (versión finita sobre la cadena
  del libro) y margen elemental `C(2ε)^{1+κ}`. 65 teoremas, 0 `sorry`,
  axiomas limpios.

## Política de calidad (plan §6, no negociable)

1. Cero `sorry` en `Book/` — un archivo con `sorry` no se commitea.
2. `#print axioms` por teorema (`Book/Audit.lean`): esperados solo
   `propext`, `Classical.choice`, `Quot.sound`; cualquier axioma extra se
   registra en el dashboard con justificación.
3. Sin `native_decide` para las proposiciones matemáticas.
4. Trazabilidad bidireccional: cada teorema lleva
   `book: <archivo>:<línea> (key: <clave>)`; el dashboard es la tabla
   inversa (`Progress/DASHBOARD.md`, generado).
5. Fidelidad declarada: la versión finita se documenta en el docstring
   cuando el libro enuncia algo más general (numerable/medible).
6. Las cifras SSCH se prueban como igualdades racionales exactas; prohibido
   verificar con flotantes.

## Estructura

```
lean-toolchain, lakefile.toml    # portabilidad/CI (el runner local es verificar.sh)
verificar.sh                     # runner canónico (puerta de cada fase)
Book/
  Foundation.lean                # problema de Wald finito: risk, mdpReturn, dominates…
  Cap05Representacion.lean       # cap. 5: P1 #1–#6 (piloto + minimax + secuencial/Bellman)
  Cap07OPE.lean                  # cap. 7: P1 #7–#10 + P2 #25 (identificación, IS, curse, DR, var-DR)
  Cap06Fronteras.lean            # cap. 6: P1 #14 + P2 #19–#24 (transporte de conjuntos, contraejemplos)
  Cap03MDP.lean                  # cap. 3: P1 #11–#12 (mejora, pi-finita, contracción, parada)
  SSCH.lean                      # hilo longitudinal SSCH: P1 #13 + P2 #27 (racionales exactos)
  Cap02Wald.lean                 # cap. 2: P2 #15–#18 (Bayes, minimax, admisibilidad, clase completa)
  Cap08Intervalos.lean           # cap. 8: P2 #26 + P3 #31–#32, #34 (baseline, cadena, PG, cota espectral)
  Cap11Despliegue.lean           # cap. 11: P3 #28–#30, #33, #35 (cuantización, truncamiento, monitoreo, MDP, margen)
  Audit.lean                     # #print axioms de cada teorema
Progress/
  DASHBOARD.md                   # teorema ↔ clave ↔ origen ↔ axiomas (generado)
  gen_dashboard.py               # lo genera desde los comentarios book: y axioms.log
```

## Origen del piloto

Los tres primeros teoremas provienen de
[`../monografia_M/pilot_core_proven.lean`](../monografia_M/pilot_core_proven.lean)
(corrida discovery `lean-pilot-mopsis`, 3/3, 2026-11-03), migrados con
nombres canónicos; ese archivo se conserva sin cambios como registro de la
corrida.
