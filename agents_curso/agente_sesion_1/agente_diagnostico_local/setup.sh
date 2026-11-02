#!/bin/bash
set -e

echo "=== Configuración del agente de diagnóstico con LangGraph + OpenRouter ==="

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Actualizar pip
pip install --upgrade pip

# Instalar dependencias exactas
pip install -r requirements.txt

# Verificar que OpenRouter API key está presente
if [ ! -f .env ]; then
    echo "ERROR: No existe archivo .env. Crea uno con OPENROUTER_API_KEY=..."
    exit 1
fi

# Verificar la clave (básico)
grep -q "OPENROUTER_API_KEY" .env || (echo "Falta OPENROUTER_API_KEY en .env" && exit 1)

echo "Instalación completa. Para iniciar el servidor:"
echo "  source venv/bin/activate"
echo "  langgraph dev"
