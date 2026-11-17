# Reproducción v1

## Dependencias

- Rust/Cargo 1.99.1 (probado) y `Cargo.lock`.
- Lean 4.35.0 y **Mathlib para Lean 4.35.0**, commit `56a005855ea17e0b0958f73ec801ae140b0a1679`, ya elaborada.
- `lean` en `PATH` y los paquetes usados en `LEAN_PATH`. Esta VM los prepara en `/opt/mathlib`; no es una dependencia escrita en el código. En otro entorno puede prepararse desde el `lakefile.toml` (misma versión y commit), con `lake exe cache get && lake build` donde se permita escribir el árbol de build de Mathlib.
- Python 3.10+, Git y Bash. No se necesita red si los crates están en cache compatible.

`argumentos/`, `repair_acceptance/` y `verificacion_lean/` contienen todo el código, pruebas y el probe externo. El ZIP original de auditoría no se necesita y no forma parte del comando.

## Comando único

Desde el checkout del commit a verificar, **limpio incluido el contenido no versionado**:

```bash
bash repair_acceptance/reproduce.sh --out /ruta-externa/nueva-evidencia-v1
```

Crea un reporte de reproducción con commit y hash del driver, ejecuta fmt, clippy, tests, Lean/probe, evidencia local, casos individuales y G1–G10. Falla si una generación modifica archivos rastreados. Los resultados quedan en `verification/verification.json`, `verification/acceptance.json`, logs y hashes. El resultado positivo es `COMPLETE_VERIFIED`.

Para copiar exactamente el commit:

```bash
git worktree add --detach /ruta-externa/checkout COMMIT
cd /ruta-externa/checkout
bash repair_acceptance/reproduce.sh --out /ruta-externa/evidence-v1
```

La confianza **solo** se computa dentro de `argumentos verify` al ejecutar el runner permitido. `argumentos check --receipts DIR` importa JSON como no confiable —incluso si declara `attested_by_configured_policy`— y conserva las obligaciones pendientes. No existe atestación automática por commit/hashes.

El estado v1 **no** afirma que todo el libro esté demostrado ni que toda equivalencia esté revisada: `repair_acceptance/claim_review.json` distingue las comparaciones `agent_reviewed` y las `pending_review`. Sus pendientes y las dos deudas de Ibragimov/Gordin se enumeran, no se rebajan para pasar.

## Cierre v1.1.0 (2026-11-17)

El tag `v1.1.0` señala el commit de cierre verificado (`git show v1.1.0`). La
reproducción de referencia corresponde a `1bbc20d`
(`evidencia/repair/smwi7ezya/clean-reproduction/`: C01–C12 y G1–G10 PASS,
`source_commit=1bbc20d`). `FINAL.md` (fase de revisión) y `ESTADO_CONGELADO.md`
(2026-11-10) son históricos; el estado vigente está en `STATE.json`. Ibragimov y
Gordin siguen siendo deuda científica declarada; no se cierran.
