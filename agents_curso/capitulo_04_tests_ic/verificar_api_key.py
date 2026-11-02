#!/usr/bin/env python3
"""
VERIFICADOR DE CONFIGURACIÓN DE API KEY
========================================
"""

import os

print("\n" + "=" * 80)
print("VERIFICACIÓN DE CONFIGURACIÓN DE API KEY")
print("=" * 80)

# 1. Revisar si existe archivo .env
env_file = "/home/enrique/Escritorio/Statistical_learning_agent/main_agents/capitulo_04_tests_ic/.env"
if os.path.exists(env_file):
    print(f"\n✓ Archivo .env encontrado: {env_file}")

    # Leer contenido
    with open(env_file, 'r') as f:
        content = f.read()

    # Buscar si ya está configurada la API key
    if "OPENROUTER_API_KEY=" in content:
        print("\n▲ API KEY configurada en el archivo .env:")
        key_val = content.split("OPENROUTER_API_KEY=")[1].split()[0].strip('#')
        if key_val == "TU_API_KEY_AQUI":
            print("  ⚠ SE NECESITA CONFIGURAR: Cambia 'TU_API_KEY_AQUI' con tu key real")
        else:
            print(f"  ✓ Key configurada: {key_val[:15]}...{key_val[-5:]}")
    else:
        print("\n✗ FALTA configuración en .env")
        print("  Completa: OPENROUTER_API_KEY=sk-or-v1-TU_KEY_AQUI")
else:
    print(f"\n✗ No existe archivo .env")
    print(f"  Copia: cp .env.example .env")
    exit(1)

# 2. Verificar variable de entorno actual
api_key = os.environ.get("OPENROUTER_API_KEY", "NOT SET")
print(f"\nVariable de entorno OPENROUTER_API_KEY: {api_key[:15] if api_key != 'NOT SET' else 'NOT SET'}")

# 3. Validaciones
print("\n" + "-" * 80)
print("VALIDACIONES:")
print("-" * 80)

checks = []

# Check 1: Ya está en el OS
if api_key != "NOT SET":
    checks.append(("API key en el sistema operativo", "✓" if api_key.startswith("sk-or-v1-") else "⚠"))
    checks.append(("Formato correcto (sk-or-v1-)", "✓" if api_key.startswith("sk-or-v1-") else "✗"))
else:
    checks.append(("API key en el sistema operativo", "✗"))

# Check 2: Apunta al código
if api_key != "NOT SET" and api_key != "TU_API_KEY_AQUI":
    checks.append(("API key configurada en agente", "✓" if api_key.startswith("sk-or-v1-") else "⚠"))
else:
    checks.append(("API key lista para usar", "✗" if api_key == "NOT SET" else "⚠"))

# 4. Mensaje final
print()
for check_name, check_status in checks:
    print(f"{check_status} {check_name}")

# 5. Instrucciones
print("\n" + "=" * 80)
print("SIGUIENTES PASOS")
print("=" * 80)

if api_key.startswith("sk-or-v1-"):
    print("\n✓ TU AGENTE ESTÁ LISTO PARA USAR LLM")

    print("\nPara probar el agente con LLM:")
    print("  1. Ejecutar: python3 agent_graph_clean.py")
    print("  2. El nodo llm_interpretará los resultados con IA")
    print("\nPara ejecutar la demostrate:")
    print("  python3 final_demo.py")
else:
    print("\n✗ CONFIGURACIÓN INCOMPLETA")
    print("\nPara obtener tu API key:")
    print("  1. Visita: https://openrouter.ai/")
    print("  2. Ve a: https://openrouter.ai/keys")
    print("  3. Genera y copia tu API key")
    print("\nPara configurar:")
    print("  1. Edita .env:")
    print("     vi .env")
    print("  2. Cambia: OPENROUTER_API_KEY=sk-or-v1-TU_KEY_AQUI")
    print("  3. Guarda y vuelve a ejecutar este script")

print("=" * 80 + "\n")