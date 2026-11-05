# DASHBOARD — verificacion_lean

Generado por `Progress/gen_dashboard.py` el 2026-11-05 desde `Book/*.lean` y `build/axioms.log`. No editar a mano.

## Teoremas verificados

| Teorema | Clave del libro | Origen | Axiomas | Estado |
|---|---|---|---|---|
| `ch8_mejora` (`Cap03MDP.lean`) | `thm:ch8-mejora` @ capitulos/cap03_mdp.typ:120 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_sin_repeticion` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_conteo` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_optimo` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_isomorfismo` (`Cap05Representacion.lean`) | `thm:ch9-isomorfismo` @ capitulos/cap05_incrustacion.typ:41 | piloto 2026-11-03 (m_repr) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_bayes` (`Cap05Representacion.lean`) | `cor:ch9-bayes` @ capitulos/cap05_incrustacion.typ:143 | piloto 2026-11-03 (m_bayes) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_admisibilidad` (`Cap05Representacion.lean`) | `thm:ch9-admisibilidad` @ capitulos/cap05_incrustacion.typ:136 | piloto 2026-11-03 (m_admis) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_traduccion_optimos` (`Cap05Representacion.lean`) | `cor:ch7-traduccion` @ capitulos/cap05_incrustacion.typ:183 | F0 2026-11-04 (nuevo; el piloto no cubría este corolario) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_traduccion` (`Cap05Representacion.lean`) | `cor:ch7-traduccion` @ capitulos/cap05_incrustacion.typ:183 | F0 2026-11-04 (nuevo; el piloto no cubría este corolario) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_secuencial_cota` (`Cap05Representacion.lean`) | `thm:ch9-secuencial` @ capitulos/cap05_incrustacion.typ:92 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_secuencial_alcanza` (`Cap05Representacion.lean`) | `thm:ch9-secuencial` @ capitulos/cap05_incrustacion.typ:92 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_bellman` (`Cap05Representacion.lean`) | `cor:ch9-bellman` @ capitulos/cap05_incrustacion.typ:104 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_ic` (`Cap06Fronteras.lean`) | `thm:ch9-ic` @ capitulos/cap06_fallos.typ:181 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_identificacion` (`Cap07OPE.lean`) | `thm:ch10-identificacion` @ capitulos/cap07_ope.typ:140 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_identificacion_pdis` (`Cap07OPE.lean`) | `thm:ch10-identificacion` @ capitulos/cap07_ope.typ:140 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr_sesgo_m` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (corolario de ch10_dr) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr_sesgo_b` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (corolario de ch10_dr) | `propext, Classical.choice, Quot.sound` | OK |

## Cobertura del inventario (plan §2)

- **P1**: 9/14 filas completadas
- **P2**: 0/13 filas completadas
- **P3**: 0/8 filas completadas
- **Total**: 9/35 filas · 9 claves del libro completadas

## En progreso (teoremas parciales)

- `thm:ch10-identificacion` — dos de tres identidades (J(e) = E_b[W G] y E_b[W_t R_t] = E_e[R_t]); falta J(e) = Σ_t γ^t E_b[W_t R_t].

Axiomas esperados en toda fila: `propext, Classical.choice, Quot.sound`.
