@echo off
echo === Configuración del agente de diagnóstico ===
python -m venv venv
call venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
echo Instalación completa. Ejecuta: langgraph dev
