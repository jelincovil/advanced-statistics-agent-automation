#!/usr/bin/env python3
"""
Lista rápida de opciones del agente - desde cualquier directorio
===============================================================

Muestra las opciones disponibles para ejecutar el agente.
"""

import os
import sys

project_dir = "/home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic"

print("\n" + "=" * 80)
print("AGENTE DE A/B TESTING CON CONTROL FDR - Opciones Disponibles")
print("=" * 80)

print("""
📌 EJECUTAR EL AGENTE (desde ANY directorio)

   1. Opción recomendada (Short):
      $ cd /home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic
      $ ./execute.sh

   2. Opción directa (Python):
      $ cd /home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic
      $ python3 run_simulation.py agent_graph_clean.py

   3. Opción final (Demo con escenarios múltiples):
      $ cd /home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic
      $ python3 run_simulation.py final_demo.py

   4. Opción entorno (si tienes múltiples capítulos):
      Cambia el capítulo en: /agent_graph/main_agents/capitulo_X_XX/
      Luego ejecuta: ./execute.sh

─────────────────────────────────────────────────────────────────────

🔧 CONFIGURACIÓN DE API KEY (OPTIONAL)

   Configurar API key de OpenRouter para habilitar interpretación IA:

   1. Copiar plantilla:
      $ cp .env.example .env

   2. Editar con tu key:
      $ vi .env
      Cambia: OPENROUTER_API_KEY=sk-or-v1-TU_KEY_AQUI

   3. Aplicar:
      $ export OPENROUTER_API_KEY=sk-or-v1-TU_KEY_AQUI

   4. Ejecutar (ya con key):
      $ ./execute.sh

─────────────────────────────────────────────────────────────────────

✅ VERIFICAR INSTALACIÓN

   Dependencias:
      $ pip3 install langchain-openai langgraph scipy numpy chainlit

   API Key:
      $ python3 -c "import os; print(os.environ.get('OPENROUTER_API_KEY', 'NO SET'))"

─────────────────────────────────────────────────────────────────────

📁 UBICACIÓN DEL PROYECTO

   Absolute path: /home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic/
   Working dir: Detectado dinámicamente (no es fijo)

─────────────────────────────────────────────────────────────────────

📊 FUNCIÓN: EJECUTAR DESDE CUALQUIER DIRECTORIO

   Ejemplo (desde ~/Documentos):
      $ cd ~/Documentos
      $ /home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic/execute.sh

─────────────────────────────────────────────────────────────────────

📖 INFORMACIÓN ADICIONAL

   Ver documentación completa: cat README_FINAL.md

   Ver API key ejemplo: cat .env.example

─────────────────────────────────────────────────────────────────────

✨ CARACTERÍSTICAS IMPLEMENTADAS

   ✓ Comparaciones múltiples (4 políticas)
   ✓ Control FDR (Benjamini-Hochberg)
   ✓ Niveles configurables (α, Q)
   ✓ Grafo LangGraph (6 nodos, 5 aristas)
   ✓ Welch Test, IC 95%, Cohen's d
   ✓ Interpretación con IA (OpenRouter)
   ✓ Tabla de resultados consolidada

─────────────────────────────────────────────────────────────────────

💡 NOTA IMPORTANTE

   El script NO requiere directorio fijo.
   Usa ./execute.sh desde CUALQUIER directorio para ejecutar el agente.

─────────────────────────────────────────────────────────────────────
""")

print("=" * 80)
print("TIP: Ejecuta 'cat README_FINAL.md' para más detalles")
print("=" * 80 + "\n")

sys.exit(0)