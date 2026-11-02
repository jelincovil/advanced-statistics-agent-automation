#!/bin/bash
# ==============================================================================
# EXECUTAR AGENTE DE CAPÍCULO 4 - STATISTICAL LEARNING
# ==============================================================================
#
# Este script detecta automáticamente su propio directorio y ejecuta el agente
# A/B Testing con FDR desde cualquier ubicación en el sistema.
#
# ==============================================================================

# Detectar este script y su directorio ACCIONAL
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cambiar al directorio del proyecto
cd "$SCRIPT_DIR" || exit 1

# Ejecutar el script principal
python3 agent_graph_clean.py "$@"

exit $?