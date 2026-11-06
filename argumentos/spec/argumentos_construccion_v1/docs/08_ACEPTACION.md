# Pruebas de aceptación científicas y de software

Cada ID de acceptance/cases.json se convierte en una prueba ejecutable Rust/integración. Registrar comando, fixture, resultado y evidencia; los casos definidos en papel no cuentan como ejecutados. La tabla es el mínimo, no una lista de nombres decorativos.

## Piloto matemático
P01 importar ch9_isomorfismo: verificar igualdad exacta y alcance finito.
P02 ch9_bayes: igualdad ponderada; no afirmar optimizadores sin wrapper adicional.
P03 ch9_admisibilidad: dominancia par a par; wrapper para admisibilidad si se desea cubrir la afirmación completa.
P04 ch7_traduccion_optimos y ch7_traduccion: distinguir teoremas de óptimos y valores, registrar hipótesis Nonempty/Fintype.
P05 SSCH racional: riesgos 1/5,4/5 y Bayes 19/50; cálculo independiente.
P06 argumento condicional mantiene todas sus obligaciones.
P07 canonicalización reproducible con UTF-8 y orden de conjuntos.
P08 replay GLM reproduce candidatos, sin API.
P09 render Typst y auditoría exacta de bloques generados.
P10 solver ASPIC+ contrastado en framework pequeño y exportado.

## Regresiones de alto valor
Las pruebas deben fracasar si se elimina una hipótesis o se cambia un signo en el fixture, si se inserta sorryAx, si se troca un hash o si se transforma finite en countable. Una prueba `value == approx(value)` no demuestra nada y se rechaza como criterio.

## Gate de calidad
cargo fmt --check; cargo clippy --all-targets --locked -- -D warnings; cargo test --locked; test por feature de integración; compilación de wrappers Lean; reproducción del experimento exacto; tests de serialización/schema; presupuesto de recursos del solver. No ejecutar servicios de red para probar el checker. Pruebas live separadas y opcionales según configuración.

## Fidelidad y completitud
Informar separadamente cobertura de archivos, bloques, afirmaciones, claves Lean y argumentos completamente respaldados. La tasa de extracción no tiene ground truth global: utilizar un conjunto piloto anotado y registrar precisión/recall sobre ese conjunto, no sobre todo el libro. No usar exactitud del LLM como garantía semántica.

## Cierre verificable
Un auditor debe poder cambiar una premisa, observar el bloqueo; restaurarla, reproducir Lean/Python; generar el expediente y comprobar el vínculo al pasaje. Debe poder ejecutar check/render/replay sin credenciales de GLM. Todo FAIL/SKIP/BLOCKED debe sobrevivir al resumen final.
