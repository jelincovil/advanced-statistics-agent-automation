# Agente de diagnóstico con LangGraph + OpenRouter (GLM 4.7 Flash)

## Requisitos
- Python 3.10 o superior
- API key de OpenRouter (gratuita en openrouter.ai/keys)

## Instalación automática (para asistentes IA)
Ejecuta en el directorio del proyecto:

**Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**
```cmd
setup.bat
```

## Configuración manual (si falla el script)
1. Crear entorno virtual: `python -m venv venv`
2. Activar: `source venv/bin/activate` (o `venv\Scripts\activate`)
3. Instalar: `pip install -r requirements.txt`
4. Crear archivo `.env` con tu `OPENROUTER_API_KEY`

## Ejecución
```bash
langgraph dev
```
Abrir http://localhost:2024 en el navegador.

## Prueba rápida
En LangGraph Studio, introduce como input:
```json
{"messages": [{"role": "user", "content": "1"}]}
```
El agente pedirá interacción humana. Puedes responder `R` o `D`.

## Verificación de instalación
```bash
python check_installation.py
```

## Notas
- El modelo usado es `z-ai/glm-4.7-flash` a través de OpenRouter.
- Para desactivar el modo humano, se puede modificar `consultar_medico` para que siempre retorne `Command(goto="recomendar_tratamiento")`.
```

Ahora voy a verificar que todos los archivos se han creado correctamente: