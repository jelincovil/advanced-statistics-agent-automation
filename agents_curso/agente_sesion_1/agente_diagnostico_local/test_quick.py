#!/usr/bin/env python3
"""
Script de prueba rápida para verificar la estructura del agente de diagnóstico.
"""

import os
import sys


def test_structure():
    """Verifica que todos los archivos necesarios existan."""
    print("🔍 Verificando estructura del proyecto...")

    required_files = [
        "requirements.txt",
        "setup.sh",
        "setup.bat",
        ".env",
        "langgraph.json",
        "agent.py",
        "check_installation.py",
        "README.md",
    ]

    missing_files = []
    for file in required_files:
        if os.path.exists(file):
            print(f"✅ {file}")
        else:
            print(f"❌ {file}")
            missing_files.append(file)

    if missing_files:
        print(f"\n❌ Faltan {len(missing_files)} archivos: {missing_files}")
        return False

    print("\n✅ Todos los archivos están presentes.")
    return True


def test_permissions():
    """Verifica permisos de ejecución."""
    print("\n🔍 Verificando permisos...")

    if os.path.exists("setup.sh"):
        import stat

        st = os.stat("setup.sh")
        if st.st_mode & stat.S_IXUSR:
            print("✅ setup.sh tiene permisos de ejecución")
        else:
            print("⚠️  setup.sh no tiene permisos de ejecución")
            print("   Ejecuta: chmod +x setup.sh")
    else:
        print("❌ setup.sh no encontrado")

    return True


def test_env_template():
    """Verifica que el archivo .env tenga el formato correcto."""
    print("\n🔍 Verificando archivo .env...")

    try:
        with open(".env", "r") as f:
            content = f.read()

        required_vars = ["OPENROUTER_API_KEY", "OPENROUTER_MODEL"]
        missing_vars = []

        for var in required_vars:
            if var in content:
                print(f"✅ Variable {var} presente")
            else:
                print(f"❌ Variable {var} faltante")
                missing_vars.append(var)

        if "REEMPLAZAR_CON_CLAVE_REAL" in content:
            print("⚠️  OPENROUTER_API_KEY necesita ser reemplazada con una clave real")
            print("   Obtén una API Key en: https://openrouter.ai/keys")

        if missing_vars:
            print(f"\n❌ Faltan variables: {missing_vars}")
            return False

        return True

    except FileNotFoundError:
        print("❌ Archivo .env no encontrado")
        return False


def test_agent_imports():
    """Intenta importar el agente para verificar dependencias básicas."""
    print("\n🔍 Probando importaciones del agente...")

    try:
        # Intentar importar módulos básicos
        import importlib

        basic_modules = ["dotenv", "math", "os", "typing"]
        for module in basic_modules:
            importlib.import_module(module)
            print(f"✅ Módulo básico: {module}")

        # Verificar que el archivo agent.py existe y es legible
        with open("agent.py", "r") as f:
            lines = f.readlines()
            print(f"✅ agent.py es legible ({len(lines)} líneas)")

        # Verificar estructura básica del agente
        with open("agent.py", "r") as f:
            content = f.read()

        required_classes = ["EstadoDiagnostico", "inicializar", "observar_prueba"]
        found_classes = []

        for cls in required_classes:
            if cls in content:
                found_classes.append(cls)
                print(f"✅ Clase/función: {cls}")
            else:
                print(f"❌ Clase/función faltante: {cls}")

        if len(found_classes) == len(required_classes):
            return True
        else:
            return False

    except Exception as e:
        print(f"❌ Error durante la verificación: {e}")
        return False


def main():
    """Función principal."""
    print("=" * 60)
    print("🧪 PRUEBA RÁPIDA - AGENTE DE DIAGNÓSTICO")
    print("=" * 60)

    # Cambiar al directorio del script si es necesario
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    tests = [
        ("Estructura del proyecto", test_structure),
        ("Permisos de archivos", test_permissions),
        ("Archivo .env", test_env_template),
        ("Importaciones del agente", test_agent_imports),
    ]

    all_passed = True
    for test_name, test_func in tests:
        print(f"\n📋 {test_name}:")
        try:
            if not test_func():
                all_passed = False
        except Exception as e:
            print(f"❌ Error inesperado: {e}")
            all_passed = False

    print("\n" + "=" * 60)
    if all_passed:
        print("✅ ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE!")
        print("\n🎯 Próximos pasos:")
        print("1. Reemplaza OPENROUTER_API_KEY en .env con tu clave real")
        print("2. Ejecuta: ./setup.sh (Linux/macOS) o setup.bat (Windows)")
        print("3. Ejecuta: python check_installation.py")
        print("4. Inicia el servidor: langgraph dev")
        print("5. Abre: http://localhost:2024")
    else:
        print("❌ ALGUNAS PRUEBAS FALLARON")
        print("\n🔧 Solución de problemas:")
        print("- Verifica que todos los archivos estén en el directorio correcto")
        print("- Asegúrate de tener permisos de lectura/ejecución")
        print("- Revisa que .env tenga el formato correcto")

    print("=" * 60)


if __name__ == "__main__":
    main()
