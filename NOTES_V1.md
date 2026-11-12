# Notas de versión 1

## Qué se garantiza

La aceptación es ejecutable desde un checkout limpio con `bash repair_acceptance/reproduce.sh --out DIR`. Se exige:

- fmt, clippy (`-D warnings`), suite completa y probe externo con lockfile.
- Compilación de todo módulo Lean activo, censo de la fuente, auditoría de axiomas y ausencia efectiva de `sorryAx`.
- C12 con un axioma prohibido y C01–C12 cada uno con prueba identificable.
- Generación local de recibos con fuentes requeridas, objetivo, tipo y axiomas, sin confianza importada ni listas incompletas.
- Registro de cada afirmación y cada bloque, visible incluido el pendiente. No se exige ninguna cantidad artificial de huecos.
- Invariante semántico: ninguna atribución de confianza o equivalencia proviene de un campo importado; la información recolectada no sustituye revisión.

## Qué no se garantiza

No se certifica que todo el libro esté demostrado. La matriz distingue 3 correspondencias `exact`, 5 `partial`, un auxiliar revisado y 236 `pending`; solo 12 filas llevan revisión sustantiva `agent_reviewed`, y las restantes 233 están explícitamente `pending_review`. Son pendientes de revisión matemática, no aprobados por defecto. Los argumentos auxiliares con evidencia no transforman esos pendientes en pruebas concluidas.

La comparación exacta se limita a la matriz: `claim_review.json` incluye fuente, texto y tipo; la evaluación está en `semantic_reviews.json`, con limitaciones de cada fila. La cobertura editorial no confunde definiciones/notas auxiliares con teoremas abiertos.

## Deudas científicas

- `thm:appD-ibragimov`: falta el límite distribucional normal del CLT; cuantitativos conservados como `auxiliary`.
- `thm:appD-gordin`: falta D[0,1]/Skorokhod, tightness, bracket c.s. y CLT funcional de martingalas; la aperiodicidad necesita declararse para la identificación de σ² mediante covarianzas.

## Reproducibilidad y versiones

Lean 4.35.0 y Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`; Rust 1.99.1 con `Cargo.lock`. El probe se resuelve offline y luego utiliza su propio lockfile. Los dashboards generados ya no incluyen fecha variable. El driver no requiere el ZIP de auditoría original ni escribe en el checkout; compara `reproduction_record.json`, hash del script y HEAD real para impedir resultados basados solo en una flag.
