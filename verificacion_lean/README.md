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
Audit) usando el `LEAN_PATH` del entorno (Mathlib
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
- Estado: **F1 cerrada** — P1 completo (14/14 filas del plan §2): F0
  (piloto + minimax), secuencial/Bellman, identificación, IS, curse, DR,
  mejora y certificados de parada, SSCH y transporte de conjuntos;
  40 teoremas, 0 `sorry`, axiomas limpios. P2 (13 filas) y P3 (8) sin
  empezar — no arrancan sin aviso del autor.

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
  Cap07OPE.lean                  # cap. 7: P1 #7–#10 (identificación, IS, curse, DR)
  Cap06Fronteras.lean            # cap. 6: P1 #14 (transporte de conjuntos, R1)
  Cap03MDP.lean                  # cap. 3: P1 #11–#12 (mejora, pi-finita, contracción, parada)
  SSCH.lean                      # hilo longitudinal SSCH: P1 #13 (racionales exactos)
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
