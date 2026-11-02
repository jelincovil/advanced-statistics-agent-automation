# DIFF duplicados — trazabilidad 2026-09-30

**Fecha:** 2026-09-30 · **Tarea:** Extra (V) — informe de filas duplicadas entre las 13 tablas.
**Regla:** sin borrar nada; solo recomendar futura poda.
**Fuente de grupos:** `LISTA_UNICA_TABLAS_TRAZABILIDAD_2026-09-29.md` §«Grupos de duplicados».
**Canónica:** todas las filas duplicadas **entran** en `tab:trazabilidad-canonica` con token en Notas (AUTONOMIA 2026-09-30).

---

## Conteos

| Métrica | Valor |
|---|---|
| Grupos `duplicado(token)` | 21 |
| Filas con marca duplicado | 52 |
| Filas totales en canónica | 98 |

## Grupos

### `duplicado(admisibilidad)` — 3 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 65 | `tab:app-trazabilidad` | Admisibilidad de Bayes |
| 78 | `tab:ch7-trazabilidad` | Admisibilidad (def:ch7-admisibilidad) |
| 89 | `tab:ch9-trazabilidad` | Admisibilidad isoto Pareto |

**Recomendación (no ejecutar):** conservar ID **78** (`tab:ch7-trazabilidad` · Admisibilidad (def:ch7-admisibilidad)). Candidatas a fusionar/podar en el futuro: 65, 89. Autor decide; hoy no se borra.

### `duplicado(bellman)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 66 | `tab:app-trazabilidad` | Contracción de Bellman |
| 82 | `tab:ch8-trazabilidad` | Ecuación de Bellman (thm:ch8-bellman-opt) |

**Recomendación (no ejecutar):** conservar ID **82** (`tab:ch8-trazabilidad` · Ecuación de Bellman (thm:ch8-bellman-opt)). Candidatas a fusionar/podar en el futuro: 66. Autor decide; hoy no se borra.

### `duplicado(benjamini-hochberg)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 61 | `tab:app-trazabilidad` | Benjamini-Hochberg |
| 32 | `tab:ch4-trazabilidad` | Benjamini-Hochberg (thm:ch4-bh) |

**Recomendación (no ejecutar):** conservar ID **32** (`tab:ch4-trazabilidad` · Benjamini-Hochberg (thm:ch4-bh)). Candidatas a fusionar/podar en el futuro: 61. Autor decide; hoy no se borra.

### `duplicado(clt)` — 4 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 62 | `tab:app-trazabilidad` | CLT funcional (Donsker) |
| 94 | `tab:ch11-trazabilidad` | CLT mixing (thm:ch11-clt-mixing) |
| 54 | `tab:ch12-trazabilidad` | CLT + Delta Method |
| 34 | `tab:ch5-trazabilidad` | CLT (thm:ch5-clt) |

**Recomendación (no ejecutar):** conservar ID **34** (`tab:ch5-trazabilidad` · CLT (thm:ch5-clt)). Candidatas a fusionar/podar en el futuro: 54, 62, 94. Autor decide; hoy no se borra.

### `duplicado(complete-class)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 64 | `tab:app-trazabilidad` | Teorema de clase completa (Wald) |
| 79 | `tab:ch7-trazabilidad` | Complete-class (thm:ch7-complete-class) |

**Recomendación (no ejecutar):** conservar ID **79** (`tab:ch7-trazabilidad` · Complete-class (thm:ch7-complete-class)). Candidatas a fusionar/podar en el futuro: 64. Autor decide; hoy no se borra.

### `duplicado(contraccion)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 66 | `tab:app-trazabilidad` | Contracción de Bellman |
| 83 | `tab:ch8-trazabilidad` | Contracción (thm:ch8-contraccion) |

**Recomendación (no ejecutar):** conservar ID **83** (`tab:ch8-trazabilidad` · Contracción (thm:ch8-contraccion)). Candidatas a fusionar/podar en el futuro: 66. Autor decide; hoy no se borra.

### `duplicado(cramer-rao)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 59 | `tab:app-trazabilidad` | Cramér-Rao |
| 25 | `tab:ch3-trazabilidad` | Cramér-Rao (thm:ch3-cramer-rao) |

**Recomendación (no ejecutar):** conservar ID **25** (`tab:ch3-trazabilidad` · Cramér-Rao (thm:ch3-cramer-rao)). Candidatas a fusionar/podar en el futuro: 59. Autor decide; hoy no se borra.

### `duplicado(delta-method)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 54 | `tab:ch12-trazabilidad` | CLT + Delta Method |
| 35 | `tab:ch5-trazabilidad` | Delta Method (thm:ch5-delta) |

**Recomendación (no ejecutar):** conservar ID **35** (`tab:ch5-trazabilidad` · Delta Method (thm:ch5-delta)). Candidatas a fusionar/podar en el futuro: 54. Autor decide; hoy no se borra.

### `duplicado(dml)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 73 | `tab:app-trazabilidad` | DML (Chernozhukov) |
| 46 | `tab:ch6-trazabilidad` | DML (thm:ch6-dml) |

**Recomendación (no ejecutar):** conservar ID **46** (`tab:ch6-trazabilidad` · DML (thm:ch6-dml)). Candidatas a fusionar/podar en el futuro: 73. Autor decide; hoy no se borra.

### `duplicado(doble-robustez)` — 3 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 70 | `tab:app-trazabilidad` | Robustez doble (DR) |
| 49 | `tab:ch12-trazabilidad` | IF eficiente (Neyman) |
| 45 | `tab:ch6-trazabilidad` | Doble robustez (thm:ch6-dr) |

**Recomendación (no ejecutar):** conservar ID **45** (`tab:ch6-trazabilidad` · Doble robustez (thm:ch6-dr)). Candidatas a fusionar/podar en el futuro: 49, 70. Autor decide; hoy no se borra.

### `duplicado(donsker)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 62 | `tab:app-trazabilidad` | CLT funcional (Donsker) |
| 37 | `tab:ch5-trazabilidad` | Donsker (thm:ch5-donsker) |

**Recomendación (no ejecutar):** conservar ID **37** (`tab:ch5-trazabilidad` · Donsker (thm:ch5-donsker)). Candidatas a fusionar/podar en el futuro: 62. Autor decide; hoy no se borra.

### `duplicado(if-eficiente)` — 6 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 71 | `tab:app-trazabilidad` | IF eficiente para V^pi |
| 63 | `tab:app-trazabilidad` | Ortogonalidad de Neyman |
| 96 | `tab:ch11-trazabilidad` | IF eficiente |
| 49 | `tab:ch12-trazabilidad` | IF eficiente (Neyman) |
| 42 | `tab:ch6-trazabilidad` | IF eficiente (thm:ch6-kallus) |
| 44 | `tab:ch6-trazabilidad` | Ortogonalidad de Neyman |

**Recomendación (no ejecutar):** conservar ID **42** (`tab:ch6-trazabilidad` · IF eficiente (thm:ch6-kallus)). Candidatas a fusionar/podar en el futuro: 44, 49, 63, 71, 96. Autor decide; hoy no se borra.

### `duplicado(isomorfismo)` — 4 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 68 | `tab:app-trazabilidad` | Incrustación fiel Wald→MDP |
| 51 | `tab:ch12-trazabilidad` | Incrustación fiel Wald→MDP |
| 80 | `tab:ch7-trazabilidad` | Isomorfismo (Nota~thm:ch7-isomorfismo, anticipo informal) |
| 87 | `tab:ch9-trazabilidad` | Isomorfismo (thm:ch9-isomorfismo) |

**Recomendación (no ejecutar):** conservar ID **87** (`tab:ch9-trazabilidad` · Isomorfismo (thm:ch9-isomorfismo)). Candidatas a fusionar/podar en el futuro: 51, 68, 80. Autor decide; hoy no se borra.

### `duplicado(lehmann-scheffe)` — 4 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 58 | `tab:app-trazabilidad` | Lehmann-Scheffé |
| 47 | `tab:ch12-trazabilidad` | UMVUE (Lehmann-Scheffé) |
| 18 | `tab:ch2-trazabilidad` | Suficiencia minimal (thm:ch2-lehmann-scheffe) |
| 24 | `tab:ch3-trazabilidad` | Lehmann-Scheffé (thm:ch3-lehmann-scheffe) |

**Recomendación (no ejecutar):** conservar ID **18** (`tab:ch2-trazabilidad` · Suficiencia minimal (thm:ch2-lehmann-scheffe)). Candidatas a fusionar/podar en el futuro: 24, 47, 58. Autor decide; hoy no se borra.

### `duplicado(minimax)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 48 | `tab:ch12-trazabilidad` | Riesgo minimax (Wald) |
| 77 | `tab:ch7-trazabilidad` | Regla minimax (thm:ch7-minimax-bayes) |

**Recomendación (no ejecutar):** conservar ID **77** (`tab:ch7-trazabilidad` · Regla minimax (thm:ch7-minimax-bayes)). Candidatas a fusionar/podar en el futuro: 48. Autor decide; hoy no se borra.

### `duplicado(neyman-fisher)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 56 | `tab:app-trazabilidad` | Factorización de Neyman-Fisher |
| 17 | `tab:ch2-trazabilidad` | Neyman-Fisher (thm:ch2-neyman-fisher) |

**Recomendación (no ejecutar):** conservar ID **17** (`tab:ch2-trazabilidad` · Neyman-Fisher (thm:ch2-neyman-fisher)). Candidatas a fusionar/podar en el futuro: 56. Autor decide; hoy no se borra.

### `duplicado(neyman-pearson)` — 3 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 60 | `tab:app-trazabilidad` | Neyman-Pearson |
| 53 | `tab:ch12-trazabilidad` | Neyman-Pearson |
| 28 | `tab:ch4-trazabilidad` | Neyman-Pearson (thm:ch4-neyman-pearson) |

**Recomendación (no ejecutar):** conservar ID **28** (`tab:ch4-trazabilidad` · Neyman-Pearson (thm:ch4-neyman-pearson)). Candidatas a fusionar/podar en el futuro: 53, 60. Autor decide; hoy no se borra.

### `duplicado(rao-blackwell)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 57 | `tab:app-trazabilidad` | Rao-Blackwell |
| 23 | `tab:ch3-trazabilidad` | Rao-Blackwell (thm:ch3-rao-blackwell) |

**Recomendación (no ejecutar):** conservar ID **23** (`tab:ch3-trazabilidad` · Rao-Blackwell (thm:ch3-rao-blackwell)). Candidatas a fusionar/podar en el futuro: 57. Autor decide; hoy no se borra.

### `duplicado(sesgo-varianza)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 16 | `tab:ch1-trazabilidad` | Descomposición sesgo-varianza (def:ch1-varianza-ecm) |
| 26 | `tab:ch3-trazabilidad` | Descomp. sesgo-varianza |

**Recomendación (no ejecutar):** conservar ID **16** (`tab:ch1-trazabilidad` · Descomposición sesgo-varianza (def:ch1-varianza-ecm)). Candidatas a fusionar/podar en el futuro: 26. Autor decide; hoy no se borra.

### `duplicado(shi-ic)` — 3 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 72 | `tab:app-trazabilidad` | Shi et al. IC válidos |
| 93 | `tab:ch11-trazabilidad` | Shi et al. (thm:ch11-shi) |
| 50 | `tab:ch12-trazabilidad` | Teorema de Shi et al. (2022) |

**Recomendación (no ejecutar):** conservar ID **93** (`tab:ch11-trazabilidad` · Shi et al. (thm:ch11-shi)). Candidatas a fusionar/podar en el futuro: 50, 72. Autor decide; hoy no se borra.

### `duplicado(value-iteration)` — 2 apariciones

| ID(es) | Origen | Resultado |
|---|---|---|
| 52 | `tab:ch12-trazabilidad` | Value Iteration |
| 84 | `tab:ch8-trazabilidad` | Value Iteration (thm:ch8-vi-conv) |

**Recomendación (no ejecutar):** conservar ID **84** (`tab:ch8-trazabilidad` · Value Iteration (thm:ch8-vi-conv)). Candidatas a fusionar/podar en el futuro: 52. Autor decide; hoy no se borra.

---

## Criterio de recomendación (documentado)

1. Preferir fila con label `thm:`/`def:` explícito en Resultado.
2. Preferir tabla de capítulo «viva» frente a `tab:app-trazabilidad` / `tab:ch12-trazabilidad` (mapa).
3. Preferir fila con Condiciones `ya-tenía` o `propuesta` frente a CSE.
4. **No se ejecuta poda hoy** (plan: retención hasta OK autor / Vie 2 del plan de consolidación).
