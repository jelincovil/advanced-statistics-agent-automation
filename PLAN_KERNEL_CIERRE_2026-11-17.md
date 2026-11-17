# Plan de cierre — kernel de argumentos (línea v1)

Fecha: 2026-11-17. Punto de partida medido hoy, no contado de memoria.
Rama: `kernel-repair-revision-v1` en `1bbc20d`; working tree limpio.

## 0. Estado medido

- La rama está 8 commits por delante de `main` (== `omm/main` @ `893d19a`). Nada de
  la línea v1 está empujado ni fusionado: ni la rama ni su linaje (`004ca96` … `1bbc20d`).
- Etiquetas: `v1.0.0` → `3909bd9` (existe en esta rama, no en `main`); `v1.0-libro` →
  ancestro de `main`. Mover `v1.0.0` sería reasignarle un tag existente: decisión explícita.
- Reproducción limpia de `1bbc20d` ya realizada
  (`evidencia/repair/smwi7ezya/clean-reproduction/`, `source_commit=1bbc20d`):
  `acceptance.json` = PASS, C01–C12 y G1–G10 PASS (releído hoy). No hay que repetirla
  salvo que cambie algún archivo.
- Kernel (`argumentos/kernel/`): 251 claims / 293 argumentos / 330 specs / 330 recibos.
- `repair_acceptance/claim_review.json`: 75 `exact` / 139 `partial` / 31 `auxiliary` /
  6 `pending`; 0 `pending_review`. Los 6 `pending` son deliberados, ninguno se cierra:
  - `C.thm:ch8-ucb1` — falta el evento de confianza (Hoeffding + unión); UCB1/Hoeffding
    están excluidos por la regla de alcance del kernel.
  - `C.thm:ch11-clt-mixing` — CLT de mezclas excluido por alcance; no hay prueba local.
  - `C.thm:appD-ibragimov` y `C.thm:appD-gordin` — deudas científicas declaradas.
  - `A.medible-borel` y `A.probabilidad-datos` — supuestos ambiente sin enunciado/target
    del libro; no admiten exact/partial/auxiliary.
- `pendientes.json`: 2 deudas, ambas NO_FORMAL_PROOF (ibragimov, gordin).
- `STATE.json` ya refleja 251/293/330 y `COMPLETE_VERIFIED`. `FINAL.md` y
  `ESTADO_CONGELADO.md` son documentos históricos con cifras antiguas
  (241/210/287 y "68 módulos"): no son el estado actual.

## 1. Definición de «terminar v1»

1. La línea v1 incorporada a `main` y publicada en `omm/main` (con decisión de tag).
2. Documentación de cierre coherente con `1bbc20d` (o marcando lo histórico).
3. Toolchain Lean declarada igual que la compilada (4.35.0) o discrepancia documentada.
4. Deudas científicas declaradas y cuantificadas, no ocultas ni cerradas artificialmente.
5. Limpieza de residuos que sí tocan el repositorio.

Lo que NO es «terminar»: cerrar ibragimov/gordin como teoremas, reasignar tags sin
autorización, o borrar `.ultramath/` (1.4 GB, git-ignored, es la única constancia de
los enjambres).

## 2. Fases

### F1. Publicación de la línea v1 — decisión y ejecución (requiero tu OK)
1. Confirmar que la reproducción de `1bbc20d` se acepta como evidencia de cierre (ya PASS).
2. Fast-forward `main` → `1bbc20d` y push de `main` a `omm/main`.
   Alternativa conservadora, si prefieres no tocar `main`: push sólo de la rama.
3. Tag: (a) dejar `v1.0.0` donde está y crear `v1.1.0` sobre `1bbc20d` (recomendado), o
   (b) reasignar `v1.0.0` a `1bbc20d` (requiere instrucción explícita), o (c) no etiquetar.
4. Verificar con `github_fetch`/`github_pull_request` tras el push (la vista local puede quedar desfasada).

### F2. Documentación de cierre (bajo coste)
1. `FINAL.md`: añadir encabezado "histórica — ver STATE.json y 1bbc20d" o regenerarla.
2. `argumentos/CHANGELOG.md`: entrada para `1bbc20d` (ya lista la evidencia).
3. `REPRODUCE.md`/`ESTADO_CONGELADO.md`: anotar qué es histórico.

### F3. Toolchain Lean (medio coste; toca hashes de evidencia)
`verificacion_lean/lean-toolchain` y `lakefile.toml` fijan v4.33.1 pero todo se compila
con Mathlib 4.35.0 (Lean 4.35.0). Opciones: pinear 4.35.0, o documentar la discrepancia.
Cualquier edición en `verificacion_lean/` invalida recibos ligados a esas fuentes →
regenerar evidencia y repetir reproducción limpia. Estimación: 1 sesión.

### F4. Docstring fantasma (condicionada a F3 o junto con ella)
`GordinCoreM8.lean` anuncia `Chain.cesaro_condVar`, declaración inexistente
(verificado: `#check` falla; única aparición es el propio docstring). Corregir el texto
no prueba el Cesàro a.s. (requiere LGN de martingalas); sólo elimina la anuncio falso.
Mismo coste que F3 (toca fuente Lean → puertas de nuevo).

### F5. Ibragimov — único avance matemático realista para este cierre (opcional, requiere OK)
Estimación de DEUDA.md §1.6: ≈450–700 líneas.
1. `abs_integral_prod_sub_prod_le_C` → versión ℂ del telescopaje (≈120).
2. Subaditividad de α sobre joins de σ-álgebras finitas (≈80).
3. Bloqueo con huecos para funciones características (≈150).
4. Resto de Taylor 2+δ y pegado (≈250); caso no acotado (≈150).
5. Regla de alcance: UCB1/Hoeffding/CLT-mixing siguen excluidos; el CLT distribucional
   de Ibragimov podría seguir sin cerrarse aunque estas piezas entren.
Criterio de parada: la pieza que no avance se documenta en DEUDA.md y se detiene;
ninguna claim se cierra sin la prueba completa.

### F6. Gordin funcional — fuera de este cierre
DEUDA.md §2.5: D[0,1]+J₁ (≈1200–2000), tightness Aldous (≈300–500), CLT de martingalas
(≈500–900), identificación σW (≈200–400). Es un proyecto aparte de meses, con enjambres
si lo autorizas. Aquí sólo queda declarada como deuda externa, como hasta ahora.

### F7. Limpieza menor (decisión tuya)
- `book_stat_inference_v0/main.pdf` tracked y posiblemente desactualizado: decidir
  conservarlo o pasar a artefacto no versionado (sin reescribir historia).
- `EVIDENCIA`/`.ultramath` (1.4 GB): ya git-ignored; no mover.
- `repar_acceptance/historical/`, logs legados: conservar como archivo.

### F8. Puertas finales
Tras lo que se haga en F1–F4: `verificar.sh`, evidencia local, reprodución limpia nueva
con `--out` fuera del checkout, y `acceptance.json` PASS. Sin esto, nada se da por cerrado.

## 3. Lo que necesito que decidas (para ejecutar F1 en adelante)

1. Publicación: ¿fast-forward `main` + push a `omm/main`, o sólo la rama, o nada?
2. Tag: `v1.1.0` nuevo (recomendado), reasignar `v1.0.0`, o ninguno.
3. Pin de toolchain: 4.35.0 o documentar 4.33.1 declarado vs 4.35.0 compilado.
4. Docstring fantasma: corregir en F4 (re-corre puertas) o dejar anotado en DEUDA.md.
5. Ibragimov (F5): ¿entra en este cierre o queda declarada igual que Gordin?
6. `main.pdf`: ¿se conserva o se desversiona?

Sin (1)–(2) el kernel v1 seguirá siendo un commit local verde y reproducido, pero
no publicado. Ningún paso de este plan empuja, etiqueta ni cierra claims sin tu instrucción.
