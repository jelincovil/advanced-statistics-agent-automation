# Guía de Replicación para Asistente IA: Agente de Investigación con OpenRouter y LangGraph

## 🎯 Objetivo
Esta guía proporciona instrucciones paso a paso para que un asistente IA pueda replicar completamente el proyecto "Agente de Investigación con OpenRouter y LangGraph" en un nuevo directorio.

## 📁 Estructura del Proyecto Original
```
tres_agent/
├── agent.py               # Código principal del agente
├── requirements.txt       # Dependencias Python
├── langgraph.json        # Configuración de LangGraph Studio
├── .env                  # Variables de entorno (sensible)
├── README.md             # Documentación principal
├── INSTALL.md            # Instrucciones de instalación
├── test_agent.py         # Pruebas de verificación
├── usage_example.py      # Ejemplos de uso
├── check_config.py       # Verificación completa
├── check_installation.py # Diagnóstico de instalación
├── setup.sh              # Script de configuración automática
└── .langgraph_api/       # Directorio generado automáticamente
```

## 🚀 Pasos de Replicación para Asistente IA

### Paso 1: Crear Directorio de Destino
```bash
# Crear nuevo directorio para el proyecto replicado
mkdir nuevo_agente_investigacion
cd nuevo_agente_investigacion
```

### Paso 2: Generar Archivos Esenciales

#### 2.1 agent.py (Archivo Principal)
```python
import os

from dotenv import load_dotenv
from langchain_community.tools import DuckDuckGoSearchRun
from langchain_openrouter import ChatOpenRouter
from langgraph.prebuilt import create_react_agent

load_dotenv()

# 1. Autenticación Explícita para evitar errores de Header
api_key = os.getenv("OPENROUTER_API_KEY")
model_name = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")

model = ChatOpenRouter(
    model=model_name, api_key=api_key, temperature=0.3, streaming=True
)

# 2. Herramienta DuckDuckGo (Sin necesidad de API Key)
tools = [DuckDuckGoSearchRun()]

# 3. Prompt del Sistema
system_prompt = "Eres un asistente de investigación avanzado. Responde siempre en español y cita tus fuentes."

# 4. Aplicación del Grafo - LangGraph API maneja la persistencia automáticamente
app = create_react_agent(model, tools, prompt=system_prompt)
```

#### 2.2 requirements.txt (Dependencias)
```txt
# Dependencias esenciales para el Agente de Investigación
# Versiones mínimas compatibles

# Core del agente
langchain-openrouter>=0.0.1
langgraph>=0.0.1
python-dotenv>=1.0.0

# Herramientas
langchain-community>=0.0.1
duckduckgo-search>=4.0.0

# Dependencias de LangChain (pueden ser transitivas)
langchain>=0.1.0
langchain-core>=0.1.0

# Dependencias de soporte
httpx>=0.24.0
pydantic>=2.0.0
```

#### 2.3 langgraph.json (Configuración LangGraph)
```json
{
  "dependencies": ["."],
  "graphs": {
    "agent": "./agent.py:app"
  },
  "env": ".env"
}
```

#### 2.4 .env.example (Plantilla de Variables)
```env
# Configuración para el Agente de Investigación con OpenRouter

# 1. Configuración de OpenRouter (REQUERIDO)
# Obtén tu API Key gratuita en: https://openrouter.ai/keys
OPENROUTER_API_KEY="sk-or-v1-REEMPLAZA_CON_TU_CLAVE_REAL"
OPENROUTER_MODEL="google/gemini-2.0-flash-001"

# 2. Configuración de LangSmith (OPCIONAL - para ver trazas)
# Si quieres ver las trazas en LangSmith Studio, descomenta y configura:
# LANGCHAIN_TRACING_V2="true"
# LANGCHAIN_API_KEY="tu_langsmith_api_key_aquí"
# LANGCHAIN_PROJECT="agente_zed_v2"
```

### Paso 3: Generar Archivos de Soporte

#### 3.1 README.md (Documentación Principal)
```markdown
# Agente de Investigación con OpenRouter y LangGraph

Este proyecto implementa un agente de investigación avanzado utilizando **OpenRouter** para modelos de lenguaje y **DuckDuckGo** para búsqueda web, integrado con **LangGraph Studio v2** para visualización y depuración.

## 🚀 Configuración Rápida

1. **Instalar dependencias**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configurar API Key**:
   ```bash
   cp .env.example .env
   # Editar .env con tu API Key de OpenRouter
   ```

3. **Iniciar servidor**:
   ```bash
   langgraph dev
   ```

4. **Abrir interfaz**:
   - Navega a: http://localhost:2024

## 🎯 Características

- 🔍 Búsqueda web en tiempo real con DuckDuckGo
- 🤖 Procesamiento con modelos avanzados de OpenRouter
- 📝 Respuestas en español con citas de fuentes
- 🕰️ Time Travel debugging con LangGraph Studio
- ⚡ Hot Reload durante desarrollo

## 📁 Estructura del Proyecto

- `agent.py` - Implementación principal del agente
- `requirements.txt` - Dependencias Python
- `langgraph.json` - Configuración de LangGraph
- `.env` - Variables de entorno (crear desde .env.example)

## 🔧 Solución de Problemas

Ver `INSTALL.md` para instrucciones detalladas de solución de problemas.
```

#### 3.2 INSTALL.md (Instrucciones Detalladas)
```markdown
# Instalación y Configuración del Agente de Investigación

## 📋 Requisitos Previos

- Python 3.8+
- API Key de OpenRouter (gratuita en https://openrouter.ai/keys)

## 🔧 Configuración Paso a Paso

### 1. Preparar Entorno
```bash
# Crear entorno virtual (opcional)
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
```

### 2. Instalar Dependencias
```bash
pip install -r requirements.txt
```

### 3. Configurar API Key
```bash
# Copiar plantilla
cp .env.example .env

# Editar .env con tu API Key real
# Obtén tu API Key en: https://openrouter.ai/keys
```

### 4. Verificar Instalación
```bash
python -c "from agent import app; print('✅ Agente cargado correctamente')"
```

### 5. Iniciar Servidor
```bash
langgraph dev
```

### 6. Acceder a la Interfaz
- Abre tu navegador en: http://localhost:2024
- Selecciona el grafo "agent"
- Usa el playground para interactuar

## 🐛 Solución de Problemas

### Error: "Missing Authentication header"
- Verifica que `.env` tenga la API Key correcta
- Obtén nueva API Key en: https://openrouter.ai/keys

### Error: "ModuleNotFoundError"
- Ejecuta: `pip install --upgrade -r requirements.txt`

### Error: Puerto 2024 en uso
- Usa: `langgraph dev --port 3000`

## 📚 Recursos
- [OpenRouter Models](https://openrouter.ai/models)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
```

### Paso 4: Generar Archivos de Prueba y Ejemplos

#### 4.1 test_agent.py (Pruebas de Verificación)
```python
#!/usr/bin/env python3
"""
Archivo de prueba para verificar el funcionamiento del agente de investigación.
"""

import os
import sys

from dotenv import load_dotenv


def test_imports():
    """Prueba que todas las importaciones necesarias funcionen."""
    print("🔍 Probando importaciones...")

    try:
        from langchain_openrouter import ChatOpenRouter
        print("✅ langchain_openrouter importado correctamente")
    except ImportError as e:
        print(f"❌ Error importando langchain_openrouter: {e}")
        return False

    try:
        from langchain_community.tools import DuckDuckGoSearchRun
        print("✅ DuckDuckGoSearchRun importado correctamente")
    except ImportError as e:
        print(f"❌ Error importando DuckDuckGoSearchRun: {e}")
        return False

    try:
        from langgraph.prebuilt import create_react_agent
        print("✅ create_react_agent importado correctamente")
    except ImportError as e:
        print(f"❌ Error importando create_react_agent: {e}")
        return False

    return True


def test_env_variables():
    """Prueba que las variables de entorno estén configuradas."""
    print("\n🔍 Probando variables de entorno...")

    load_dotenv()

    api_key = os.getenv("OPENROUTER_API_KEY")
    model_name = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")

    if not api_key or api_key == "sk-or-v1-REEMPLAZA_CON_TU_CLAVE_REAL":
        print("❌ OPENROUTER_API_KEY no está configurada correctamente")
        print("   Por favor, edita el archivo .env y reemplaza la clave de API")
        print("   Obtén una API Key gratuita en: https://openrouter.ai/keys")
        return False

    print(f"✅ OPENROUTER_API_KEY configurada (longitud: {len(api_key)} caracteres)")
    print(f"✅ OPENROUTER_MODEL configurado como: {model_name}")

    return True


def test_agent_creation():
    """Prueba la creación del agente."""
    print("\n🔍 Probando creación del agente...")

    try:
        load_dotenv()

        api_key = os.getenv("OPENROUTER_API_KEY")
        model_name = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")

        # Crear modelo
        from langchain_openrouter import ChatOpenRouter

        model = ChatOpenRouter(
            model=model_name, api_key=api_key, temperature=0, streaming=True
        )
        print("✅ Modelo ChatOpenRouter creado correctamente")

        # Crear herramienta
        from langchain_community.tools import DuckDuckGoSearchRun

        tools = [DuckDuckGoSearchRun()]
        print("✅ Herramienta DuckDuckGoSearchRun creada correctamente")

        # Crear aplicación
        from langgraph.prebuilt import create_react_agent

        system_prompt = "Eres un asistente de investigación avanzado. Responde siempre en español y cita tus fuentes."

        app = create_react_agent(model, tools, prompt=system_prompt)
        print("✅ Aplicación del grafo creada correctamente")

        return True

    except Exception as e:
        print(f"❌ Error creando el agente: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Función principal de prueba."""
    print("=" * 60)
    print("🧪 PRUEBA DEL AGENTE DE INVESTIGACIÓN")
    print("=" * 60)

    # Paso 1: Probar importaciones
    if not test_imports():
        print("\n❌ Prueba de importaciones fallida")
        sys.exit(1)

    # Paso 2: Probar variables de entorno
    if not test_env_variables():
        print("\n❌ Prueba de variables de entorno fallida")
        sys.exit(1)

    # Paso 3: Probar creación del agente
    if not test_agent_creation():
        print("\n❌ Prueba de creación del agente fallida")
        sys.exit(1)

    print("\n" + "=" * 60)
    print("✅ ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE!")
    print("=" * 60)
    print("\n🎯 Ahora puedes ejecutar el servidor de desarrollo con:")
    print("   langgraph dev")
    print("\n🌐 El servidor estará disponible en: http://localhost:2024")


if __name__ == "__main__":
    main()
```

#### 4.2 usage_example.py (Ejemplos de Uso)
```python
#!/usr/bin/env python3
"""
usage_example.py - Ejemplos de uso del Agente de Investigación

Este archivo muestra diferentes formas de interactuar con el agente
de investigación configurado con OpenRouter y DuckDuckGo.
"""

import os

from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()


def print_header(title):
    """Imprime un encabezado decorado."""
    print("\n" + "=" * 60)
    print(f"📚 {title}")
    print("=" * 60)


def example_basic_imports():
    """Ejemplo 1: Importaciones básicas y configuración."""
    print_header("1. IMPORTACIONES BÁSICAS Y CONFIGURACIÓN")

    print("🔧 Configurando el agente paso a paso...")

    # Importar componentes
    from langchain_community.tools import DuckDuckGoSearchRun
    from langchain_openrouter import ChatOpenRouter
    from langgraph.prebuilt import create_react_agent

    # Obtener configuración
    api_key = os.getenv("OPENROUTER_API_KEY")
    model_name = os.getenv("OPENROUTER_MODEL", "google/gemini-2.0-flash-001")

    print(f"✅ Modelo configurado: {model_name}")
    print(f"✅ API Key: {'Configurada' if api_key else 'No configurada'}")

    # Crear modelo
    model = ChatOpenRouter(
        model=model_name, api_key=api_key, temperature=0, streaming=True
    )

    # Crear herramienta de búsqueda
    search_tool = DuckDuckGoSearchRun()
    print(f"✅ Herramienta: {search_tool.name}")
    print(f"   Descripción: {search_tool.description}")

    # Prompt del sistema
    system_prompt = "Eres un asistente de investigación avanzado. Responde siempre en español y cita tus fuentes."

    # Crear agente
    app = create_react_agent(model=model, tools=[search_tool], prompt=system_prompt)

    print("✅ Agente creado exitosamente!")
    print("   Nombre: create_react_agent")
    print("   Herramientas disponibles: 1 (DuckDuckGoSearchRun)")

    return app


def example_simple_query(app):
    """Ejemplo 2: Consulta simple al agente."""
    print_header("2. CONSULTA SIMPLE AL AGENTE")

    print("🤔 Haciendo una pregunta al agente...")

    # Configurar entrada
    inputs = {
        "messages": [
            {
                "role": "user",
                "content": "¿Cuáles son las últimas noticias sobre inteligencia artificial?",
            }
        ]
    }

    print("📤 Enviando consulta...")
    print(f"   Pregunta: {inputs['messages'][0]['content']}")

    print(
        "\n📥 Respuesta simulada (en LangGraph Studio verías la ejecución en tiempo real):"
    )
    print("""
    El agente realizaría los siguientes pasos:
    1. 🧠 Analizar la consulta del usuario
    2. 🔍 Ejecutar búsqueda en DuckDuckGo sobre "últimas noticias inteligencia artificial"
    3. 📄 Procesar los resultados de búsqueda
    4. ✍️  Generar respuesta en español citando fuentes
    5. 💾 Guardar el estado para posible "Time Travel"
    """)


def main():
    """Función principal."""
    print("=" * 60)
    print("🤖 EJEMPLOS DE USO - AGENTE DE INVESTIGACIÓN")
    print("=" * 60)
    print("\nEste archivo muestra cómo usar el agente configurado en agent.py")
    print("Para ejecutar el agente, usa: langgraph dev")
    print("Luego abre: http://localhost:2024\n")

    # Ejemplo 1
    try:
        app = example_basic_imports()
    except Exception as e:
        print(f"❌ Error en ejemplo 1: {e}")
        print("   Asegúrate de tener configurado el archivo .env correctamente")
        app = None

    # Ejemplo 2
    if app:
        example_simple_query(app)

    print_header("🚀 PRÓXIMOS PASOS")

    next_steps = [
        ("1. Configurar API Key", "Edita .env con tu clave de OpenRouter"),
        ("2. Iniciar servidor", "Ejecuta: langgraph dev"),
        ("3. Abrir Studio", "Navega a: http://localhost:2024"),
        ("4. Probar agente", "Usa el playground para hacer preguntas"),
    ]

    for step, description in next_steps:
        print(f"   {step}: {description}")

    print("\n" + "=" * 60)
    print("📚 Para más información, consulta README.md")
    print("=" * 60)


if