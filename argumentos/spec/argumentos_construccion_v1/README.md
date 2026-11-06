# ARGUMENTOS — paquete de construcción v1.0
Fecha: 2026-11-04. Autor del proyecto: Jaime Lincovil.
Repositorio destino: https://github.com/jelincovil/advanced-statistics-agent-automation
Base inspeccionada: 0460b3f29f35eb0cb2b553712b9c7adb1e37ae77.

## Qué entrega este paquete
Especificación ejecutable por un agente de desarrollo para construir una base de argumentos completos del libro, auditable contra Typst y respaldada por Lean o experimentos Python. Incluye contratos JSON, ejemplos, casos de aceptación, un validador del paquete y el prompt maestro. No es el software Rust terminado ni una certificación del libro. Los ejemplos no son pruebas científicas ni recibos de ejecución.

## Inicio
1. Extraer este ZIP fuera del repositorio o en una carpeta de insumos.
2. Abrir el repositorio destino con el agente local (GLM seleccionado por el usuario).
3. Entregar al agente MASTER_PROMPT.md íntegro, indicando la ruta de este paquete y del repositorio.
4. El agente ejecuta F0–F8 y deja evidencia, checkpoints y un informe final. No debe detenerse después del plan.

No se precisa convertir el libro a LaTeX. El libro actual permanece como objeto de auditoría; solo las fichas y bloques canónicos se generan desde el kernel. La migración de toda la prosa a generación automática queda fuera del alcance inicial.

## Orden de lectura
MASTER_PROMPT.md → docs/01_DECISIONES.md → docs/02_ARQUITECTURA.md → docs/03_CONTRATOS.md → docs/04_REGLAS_Y_ESTADOS.md → docs/05_EVIDENCIA.md → docs/06_AUDITORIA_TYPST.md → docs/07_PLAN.md → docs/08_ACEPTACION.md → docs/09_OPERACION.md.
Consultar docs/10_RIESGOS_REPO.md, docs/11_FUENTES.md, schemas/, examples/, acceptance/ y templates/ durante la implementación.

## Verificación de esta entrega
`python3 tools/validate_package.py` valida enlaces contractuales y casos de ejemplo, y comprueba el manifiesto SHA-256. Es un control del paquete, no el futuro comprobador lógico Rust. `python3 tools/check_schema.py` añade validación JSON Schema si jsonschema está instalado; su ausencia se informa como SKIP, nunca PASS.

## Condición de cierre
Separar SOFTWARE_READY de CORPUS_CLOSED. Un programa funcional puede tener argumentos del libro pendientes. El inventario debe cubrir todos los bloques objetivos localizados, sin fingir que cada párrafo quedó comprendido semánticamente. La aprobación formal la determina la evidencia reproducida y las reglas implementadas; una valoración del LLM nunca sustituye esa evidencia.
