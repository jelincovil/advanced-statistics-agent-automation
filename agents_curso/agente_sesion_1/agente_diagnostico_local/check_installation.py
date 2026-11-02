#!/usr/bin/env python3
import importlib
import sys


def check_module(module_name):
    try:
        importlib.import_module(module_name)
        print(f"✅ {module_name}")
        return True
    except ImportError:
        print(f"❌ {module_name}")
        return False


def main():
    print("=== Verificando instalación del agente ===")
    modules = ["langgraph", "langchain", "langchain_openrouter", "dotenv", "langsmith"]
    all_ok = all(check_module(m) for m in modules)
    if not all_ok:
        print("Instalación incompleta. Ejecuta: pip install -r requirements.txt")
        sys.exit(1)
    print("\n✅ Todas las dependencias están presentes.")
    print("Ahora puedes ejecutar: langgraph dev")
    print("Recuerda tener tu API key de OpenRouter en el archivo .env")


if __name__ == "__main__":
    main()
