# BASELINE — F0 del proyecto ARGUMENTOS

Fecha: 2026-11-06. Fase F0 (reconocer y preservar). Puerta F0: veredicto al final.

## Base real

- HEAD al iniciar F0: `1c98d6b` (Lean t27+t28: auditoría de enunciados F0–F2
  contra los `.typ` y sus correcciones). Árbol limpio salvo `.skill/`
  (infraestructura del agente, sin versionar, fuera del alcance).
- Commit de referencia del paquete: `0460b3f29f35eb0cb2b553712b9c7adb1e37ae77`.
  **HEAD difiere y no se restaura.** La historia intermedia añade: README y
  LICENSE raíz (`604a291`), la versión `v1.0-libro` del libro (`a81b7b1`) y el
  proyecto Lean completo F0–F3 (`0460b3f..69276cb`: 16 archivos tracked,
  +5429/−26) más la auditoría de enunciados t27+t28 (`1c98d6b`). El inventario
  de este proyecto se adapta a la base real, no a la del paquete.

## Inventario del árbol (del árbol real, no del README)

- `book_stat_inference_v0/` — **corpus primario del canon**: el libro en
  Typst (español), `main.typ` con 14 capítulos (`capitulos/`), 8 apéndices,
  `plantilla.typ`, laboratorios `lab00–lab12`, chequeadores
  `verificacion/comprobar_{hallazgos,identidades,secundarios}.py`, ~30–40
  documentos de gobernanza.
- `verificacion_lean/` — frontera de confianza matemática: 9 módulos,
  66 teoremas auditados, 0 `sorry`, dashboard 64 filas / 35 claves
  (P1 14/14 · P2 13/13 · P3 8/8).
- `monografia_M/` — draft M en inglés (61 pp, 13 capítulos) + piloto Lean
  compartido. **Corpus secundario con IDs propios (F7), sin mezclar.**
- `agente-stats/` — paquete MCP del agente (stdlib). **No es ancla aprobada**
  (política de docs/10 #6, se mantiene).
- `agents_curso/`, `diapositivas/`, `json_csv_repodir/` — materiales de
  docencia; consumidores potenciales del canon, prioridad al libro.
- `attachments/` — insumos de sesión, no versionado.

## Herramientas disponibles (verificadas hoy)

| Herramienta | Versión observada | Nota |
|---|---|---|
| cargo/rustc | 1.93.1 | de sistema, sin rustup; no se instala nada; se fija `Cargo.lock` y se documenta |
| typst | 0.15.1 | coincide con la versión observada del paquete para `typst-syntax` — la alineación de docs/02 ya está dada |
| lean | 4.33.1 | Mathlib precompilada en `LEAN_PATH` (`/opt/mathlib` read-only); runner `verificar.sh` con `lean` directo |
| python3 | 3.12.14 | numpy 2.5.3, scipy 1.18.1, jsonschema disponible |
| red | disponible | crates.io accesible para F1 |
| disco | 218 GB libres | `argumentos/target/` ignorado por git |

## Controles de línea base (ejecutados hoy)

| Control | Comando | Resultado |
|---|---|---|
| Validación del paquete | `python3 tools/validate_package.py` | **PASS** (11 fixtures; autocomprobación del paquete, no el checker Rust) |
| Esquemas JSON | `python3 tools/check_schema.py` | **PASS** |
| Lean | `./verificar.sh` | **EXIT 0**: 9 módulos, 66 teoremas, 0 `sorry`, sin `sorryAx` |
| Libro — hallazgos | `python3 verificacion/comprobar_hallazgos.py` | **OK** |
| Libro — identidades | `python3 verificacion/comprobar_identidades.py` | **OK** |
| Libro — secundarios | `python3 verificacion/comprobar_secundarios.py` | **OK** |
| Compilación del libro | `typst compile main.typ` | **EXIT 0**, 275 pp, 0 errores 0 advertencias (corrida de línea base en background, job `jmw565cvq`) |

## Inventario Lean y contraste con el libro

El paquete se elaboró contra 3 módulos / 5 teoremas / 4 claves; la base real
tiene **9 módulos / 66 teoremas / 35 claves**. El piloto exigido por F3
(cuatro claves, cinco teoremas: `ch9_isomorfismo`, `ch9_bayes`,
`ch9_admisibilidad`, `ch7_traduccion_optimos`, `ch7_traduccion`) queda
cubierto con exceso; el inventario del kernel se adapta a la base real.

El contraste enunciado↔libro que F0 exige existe y está fresco:
`verificacion_lean/Progress/AUDITORIA_ENUNCIADOS_2026-11-06.md` (t27: 59
enunciados auditados contra sus pasajes `.typ`; 55 fieles; hallazgos
corregidos en t28 y re-testeados). Los alcances que docs/05 manda registrar
están documentados ahí: todo es `finite_specialization` (no
`full_statement_verified`); `ch9_admisibilidad` prueba dominancia par a par
(no admisibilidad cuantificada — un wrapper puede añadirse); `ch9_bayes`
prueba igualdad de promedios (no el conjunto de optimizadores); la clase
determinista de `ch7_minimax_bayes`/`ch7_admisibilidad_bayes` es legítima
por `def:ch9-wald` (𝒟₀ por defecto).

## Riesgos de docs/10 re-verificados contra el árbol actual

1. Bloques reales vs README: **confirmado** — el inventario se tomó del árbol.
2. «5 teoremas / 4 claves / 4/35»: **obsoleto** — hoy 66 / 35 / 35-de-35.
3. `Foundation` con pesos reales sin exigir probabilidades: **confirmado** —
   el kernel registrará `finite_specialization`.
4. El runner busca `sorry` y audita axiomas: **confirmado** — el exporter F3
   leerá declaraciones elaboradas (nombre, tipo, dependencias, axiomas), no
   el dashboard ni la consola.
5. SAVE escenario A con celdas vacías: la discrepancia histórica se
   **preserva** (no se rellena ningún número); el estado fino de las celdas
   del apéndice G se verifica en F4 con el parser Typst.
6. `agente-stats`: **observación del paquete parcialmente desactualizada** —
   `v_H` no aparece con ese nombre en `ope.py` actual (están `_v_from_m`,
   `estimate_dr`) y `compare.py` sí usa `gamma` en los términos de
   continuación (líneas 97, 124–125). La **política se mantiene**: no es
   ancla aprobada sin revisión y regresiones independientes.
7. `certificates.py` con regiones de condiciones abiertas: heredado; el
   kernel no copiará esa promoción automática.
8. `monografia_M`: corpus separado (F7, inventario secundario, IDs propios).
9. Tests verdes = registro técnico, no evidencia científica: adoptado como
   regla del checker (docs/12).
10. No limpiar artefactos históricos: adoptado.

## Problemas heredados (separados de este trabajo)

- Apéndice G del libro: escenario B pendiente, escenario C muerto por
  `Sigma_hat` singular en la réplica 4 — pendiente del libro, no del canon.
- Bibliografía 2022+: mayoría de entradas sin ficha nivel A verificada —
  pista bibliográfica, ajena a este proyecto.
- Sync manual Typst.app del autor — pendiente externo, nunca reportar como
  hecho.

## Decisiones F0

- El paquete se copia a `argumentos/spec/argumentos_construccion_v1/`
  (216 KB, con `MANIFEST.sha256.json`) — `attachments/` no está versionado y
  la construcción debe ser reproducible desde el repo.
- Rust del sistema (1.93.1), sin instalación nueva; la «toolchain» es la de
  la VM y se documenta su versión exacta en `DEPENDENCIES.md` (F1).
- `argumentos/target/` añadido a `.gitignore` (artefactos reconstruibles).
- GLM: sin endpoint configurado en esta VM → F5 se construye con replay
  determinista y `LIVE_PROVIDER_PENDING` (docs/09, salida alternativa).

## Veredicto de la puerta F0

- Ninguna modificación ajena perdida: t27+t28 commiteados como `1c98d6b`
  antes de crear `argumentos/`; nada se revierte ni se limpia.
- HEAD y diferencias contra `0460b3f` registrados arriba.
- Problemas heredados separados y etiquetados.
- Baseline de controles pertinente ejecutada y registrada arriba.

**F0: PASSED.**
