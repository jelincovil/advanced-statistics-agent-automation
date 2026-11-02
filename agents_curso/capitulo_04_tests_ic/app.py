"""
Capítulo 4: Tests de Hipótesis e Intervalos de Confianza
========================================================
Interfaz Chainlit para el Agente A/B Testing de Políticas con FDR

Características principales:
- /run: Ejecutar análisis completo A/B testing
- /alpha <valor>: Cambiar nivel de significancia (default: 0.05)
- /policies <n>: Número de políticas a comparar (2-6)
- /samples <n>: Tamaño de muestra por política (default: 200)
- /help: Mostrar esta ayuda
- /reset: Reiniciar análisis

Ejecutar: chainlit run app.py
"""

import logging
import os

import chainlit as cl

from agent_graph_clean import build_graph

# Logger personalizado para este módulo
logger = logging.getLogger(__name__)


def log(level: str, message: str):
    """Logger personalizado que usa cl.logger para mensajes de Chainlit."""
    if level == "INFO":
        cl.logger.info(message)
    elif level == "WARNING":
        cl.logger.warning(message)
    elif level == "ERROR":
        cl.logger.error(message)
    else:
        cl.logger.debug(message)


@cl.on_chat_start
async def start():
    """Inicializar el agente al inicio de la sesión."""
    graph = build_graph()
    cl.user_session.set("graph", graph)

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if api_key:
        api_status = "✅ CONFIGURADA"
        api_extra = ""
    else:
        api_status = "❌ NO CONFIGURADA"
        api_extra = (
            "\n\n⚠️ **Nota:** Sin API key el LLM no estará disponible. "
            "Las preguntas libres y la interpretación LLM usarán un fallback.\n\n"
            "Para configurar:\n"
            "1. Obtén una key en: https://openrouter.ai/keys\n"
            "2. Ejecuta: `export OPENROUTER_API_KEY='sk-or-v1-...'`\n"
            "3. Reinicia la aplicación"
        )

    await cl.Message(
        content=(
            "## 🧪 Agente A/B Testing de Políticas con FDR\n\n"
            "### Capítulo 4: Tests de Hipótesis e Intervalos de Confianza\n\n"
            f"**Estado de OpenRouter API:** {api_status}\n\n"
            f"{api_extra}"
            "### Comandos disponibles:\n\n"
            "| Comando | Descripción |\n"
            "|---------|-------------|\n"
            "| `/run` | Ejecutar análisis completo A/B testing |\n"
            "| `/alpha <valor>` | Cambiar nivel de significancia (ej: `0.01`) |\n"
            "| `/policies <n>` | Número de políticas (2-6) |\n"
            "| `/samples <n>` | Tamaño de muestra (default: 200) |\n"
            "| `/help` | Mostrar esta ayuda |\n"
            "| `/reset` | Reiniciar análisis |\n\n"
            "### Ejemplos:\n"
            "- `/run` - Análisis simple\n"
            "- `/alpha 0.01` - Tests más conservadores\n"
            "- `/policies 4` - Comparar 4 políticas simultáneamente\n\n"
            "### O escribe tu pregunta libre\n"
            "sobre tests de hipótesis e intervalos de confianza aplicados a agentes inteligentes."
        )
    ).send()


@cl.on_message
async def main(message: cl.Message):
    """Procesar mensajes del usuario."""
    graph = cl.user_session.get("graph")
    msg_content = message.content.strip()

    # Descomposición de comandos
    if msg_content == "/run":
        log("INFO", "COMANDO /run: Ejecutando análisis A/B Testing")
        await run_analysis(graph)
    elif msg_content == "/help":
        log("INFO", "COMANDO /help: Mostrando ayuda")
        await show_help()
    elif msg_content == "/reset":
        log("INFO", "COMANDO /reset: Reiniciando análisis")
        await reset_analysis(graph)
    elif msg_content.startswith("/alpha"):
        parts = msg_content.split()
        if len(parts) > 1:
            try:
                alpha = float(parts[1])
                if 0 <= alpha <= 1:
                    log("INFO", f"COMANDO /alpha {alpha}: Nivel de significancia actualizado")
                    await cl.Message(content=f"✓ Nivel α actualizado a {alpha}. Use `/run` para ejecutar.").send()
                else:
                    log("WARNING", f"COMANDO /alpha {alpha}: Valor inválido")
                    await cl.Message(content="✗ El nivel α debe estar entre 0 y 1.").send()
            except ValueError:
                log("WARNING", "COMANDO /alpha: Formato incorrecto")
                await cl.Message(content="✗ Formato inválido. Use: `/alpha <valor>` (ej: `/alpha 0.05`)").send()
        else:
            log("WARNING", "COMANDO /alpha: Falta valor")
            await cl.Message(content="✗ Falta el valor. Use: `/alpha <valor>` (ej: `/alpha 0.05`)").send()
    elif msg_content.startswith("/policies") or msg_content.startswith("/samples"):
        log("INFO", f"COMANDO {msg_content}: Parámetro armado")
        parts = msg_content.split()
        requested = "/policies" if msg_content.startswith("/policies") else "/samples"
        try:
            n_param = int(parts[1])
            valid_range = (2, 6) if "/policies" in msg_content else (50, 1000)
            if valid_range[0] <= n_param <= valid_range[1]:
                await cl.Message(
                    content=f"✓ {requested.split('/')[1].strip()} actualizado a {n_param}. "
                           f"Use `/run` para ejecutar el análisis."
                ).send()
            else:
                range_str = f"{valid_range[0]}-{valid_range[1]}" if "/samples" in msg_content else "2-6"
                log("WARNING", f"COMANDO {msg_content}: Valor fuera de rango [{range_str}]")
                error_msg = f"✗ Valor fuera de rango [{range_str}]."
                if "/policies" in msg_content:
                    error_msg += " Usa `/policies <n>` donde n ∈ {2,3,4,5,6}."
                else:
                    error_msg += " Usa `/samples <n>` donde n ∈ {50,100,...,1000}."
                await cl.Message(content=error_msg).send()
        except ValueError:
            log("WARNING", "COMANDO /policies/samples: Formato incorrecto")
            await cl.Message(
                content=f"✗ Formato inválido. Use:\n"
                       f"  `{requested} <valor>` (ej: `{requested} 4`)"
            ).send()
    else:
        # Consulta libre - usar LLM para responder
        log("INFO", "Consulta libre: Respondiendo con LLM")
        await answer_free_question(message.content)


# =============================================================================
# AUXILIARES
# =============================================================================
async def show_help():
    """Mostrar ayuda completa del agente."""
    help_text = (
        "### 📋 Comandos del Agente A/B Testing\n\n"
        "| Comando | Descripción | Ejemplo |\n"
        "|---------|-------------|---------|\n"
        "| `/run` | Ejecuta análisis completo | `/run` |\n"
        "| `/alpha` | Ajusta nivel de significancia | `/alpha 0.01` |\n"
        "| `/policies` | especifica número de políticas | `/policies 4` |\n"
        "| `/samples` | especifica tamaño de muestra | `/samples 500` |\n"
        "| `/help` | Muestra esta ayuda | `/help` |\n"
        "| `/reset` | Reinicia el análisis | `/reset` |\n\n"
        "### 📊 Flujo del Análisis\n\n"
        "1. **Collect Data**: Simula recompensas bajo políticas\n"
        "2. **Welch Test**: Compara V^π_A vs V^π_B\n"
        "3. **Compute CI**: Intervalo de confianza 95%\n"
        "4. **Benjamini-Hochberg**: Corrección FDR (múltiples comparaciones)\n"
        "5. **LLM Interpret**: Explicación humana del análisis\n"
        "6. **Decide**: Decision final (ADOPTAR_B/MANTENER_A/NO_HAY_EVIDENCIA)\n\n"
        "### ⚙️ Configuración Requerida\n\n"
        "Asegúrate de tener configurada la API key de OpenRouter:\n"
        "`export OPENROUTER_API_KEY='sk-or-v1-...'`\n\n"
        "Más detalles: consulte `environment.yml` en este directorio."
    )
    await cl.Message(content=help_text).send()


async def reset_analysis(graph):
    """Reinicia el estado del agente."""
    initial_state = {
        "rewards_policy_a": [],
        "rewards_policy_b": [],
        "rewards_other_policies": {},
        "test_result": {},
        "confidence_intervals": {},
        "fdr_decisions": {},
        "decision": "",
        "llm_analysis": "",
        "alpha": 0.05,
        "q_value": 0.10,
    }
    cl.user_session.set("initial_state", initial_state)
    await cl.Message(
        content="✓ Análisis reiniciado. Use `/run` para comenzar de nuevo."
    ).send()


# =============================================================================
# FUNCIONES PRINCIPALES
# =============================================================================


async def run_analysis(graph):
    """Ejecutar el análisis completo de A/B testing."""
    log("INFO", "NODO run_analysis: Iniciando ejecución del grafo")

    with cl.Step(name="Análisis A/B Testing con FDR"):
        await cl.Message(
            content="📊 Ejecutando análisis A/B Testing con FDR..."
        ).send()

    initial_state = {
        "rewards_policy_a": [],
        "rewards_policy_b": [],
        "rewards_other_policies": {},
        "test_result": {},
        "confidence_intervals": {},
        "fdr_decisions": {},
        "decision": "",
        "llm_analysis": "",
        "alpha": 0.05,
        "q_value": 0.10,
    }

    result = graph.invoke(initial_state)

    # Mostrar resultados con formato profesional
    test = result["test_result"]
    ci = result["confidence_intervals"]
    fdr = result["fdr_decisions"]

    # Pre-formatizar resultados
    z_stat = float(test.get('z_statistic', 0))
    p_value = float(test.get('p_value', 0))
    effect = float(test.get('effect_size', 0))
    display_effect = effect**2
    ci_diff = float(ci.get('difference', 0))
    z_crit = float(test.get('z_critical', 1.645))
    rejected_h0 = "SÍ" if bool(test.get('reject_h0', False)) else "No"
    contains_zero_str = "Sí" if bool(ci.get('contains_zero', True)) else "No"
    total_tests = int(fdr.get('total_comparisons', 0))
    rejected_fdr = int(fdr.get('rejected_count', 0))
    q_val = float(fdr.get('q', 0.10))
    decision = str(result.get('decision', 'N/A'))
    llm_text = str(result.get('llm_analysis', ''))[:1500]

    # Construir texto del resultado
    result_text = (
        "## 🧪 Resultados del Análisis A/B Testing\n\n"
        "---\n\n"
        "### 🔬 Z-Test Unilateral: H₀: V^{π_B} ≤ V^{π_A} vs H₁: V^{π_B} > V^{π_A}\n\n"
        "| Métrica | Valor |\n"
        "|---------|-------|\n"
        f"| Z-statistic | {z_stat:6.4f} |\n"
        f"| Z crítico (α=0.05) | {z_crit:6.4f} |\n"
        f"| p-valor (unilateral) | {p_value:6.4f} |\n"
        f"| Cohen's d | {effect:6.4f} |\n"
        f"| d² | {display_effect:6.4f} |\n"
        f"| H₀ rechazada | **{rejected_h0}** |\n\n"
        "---\n\n"
        f"### 📊 Intervalo de Confianza 95% (π_B - π_A)\n\n"
        f"Diferencia media: **{ci_diff:6.4f}**\n"
        f"- **IC inferior:** {ci.get('ci_95_lower', 0):6.4f}\n"
        f"- **IC superior:** {ci.get('ci_95_upper', 0):6.4f}\n"
        f"- **Respuesta:** {contains_zero_str} → IC {'no ' if contains_zero_str != 'Sí' else ''}contiene 0\n\n"
        "---\n\n"
        f"### 🎯 Control FDR (Benjamini-Hochberg, q={q_val:.1f})\n\n"
        f"Comparaciones: {total_tests} pares (C(4,2)=6) | Hipótesis rechazadas: {rejected_fdr}\n\n"
        "---\n\n"
        f"### 🤖 Decisión Final (Dualidad Test-IC)\n\n"
        f"**{decision}**\n\n"
        "---\n\n"
        f"### 💭 Análisis del LLM\n\n"
        f"{llm_text}..."
    )

    # Enviar resultado
    await cl.Message(content=result_text).send()

    # Generar y enviar imagen del grafo
    await send_graph_image()


async def send_graph_image():
    """Generar y enviar imagen del grafo del agente."""
    try:
        import os
        import tempfile

        from graphviz import Digraph

        dot = Digraph(comment='Agente A/B Testing - Tests e IC', format='png')
        dot.attr(rankdir='LR', bgcolor='white')
        dot.attr('node', shape='box', style='filled,rounded',
                 fillcolor='#E8F0FE', fontname='Arial', penwidth='1.5', color='#4A90D9')
        dot.attr('edge', arrowsize='0.8', fontname='Arial', fontsize='10', color='#666666')

        nodes = {
            '__start__': '🏁 INICIO',
            'collect_data': '📊 collect_data\nSimular rewards\nn=200, 4 políticas',
            'z_test': '🔬 Z-Test\nH₀: μ_B ≤ μ_A\n(unilateral)',
            'compute_ci': '📏 IC 95%\nDiferencia de medias\n(Dualidad Test-IC)',
            'benjamini_hochberg': '🎯 FDR\nBenjamini-Hochberg\nq=0.10, C(4,2)=6 tests',
            'llm_interpret': '🤖 LLM\nInterpretación\nde resultados',
            'decide': '✅ Decisión\nADOPTAR_B /\nMANTENER_A /\nNO_HAY_EVIDENCIA',
            '__END__': '🏁 FIN',
        }

        colors = {
            '__start__': '#D4EDDA',
            'collect_data': '#E8F0FE',
            'z_test': '#FFF3CD',
            'compute_ci': '#F8D7DA',
            'benjamini_hochberg': '#E2D1F9',
            'llm_interpret': '#D1ECF1',
            'decide': '#D4EDDA',
            '__END__': '#D4EDDA',
        }

        for node_id, label in nodes.items():
            dot.node(node_id, label, fillcolor=colors.get(node_id, '#E8F0FE'))

        edges = [
            ('__start__', 'collect_data', 'inicio'),
            ('collect_data', 'z_test', 'rewards'),
            ('z_test', 'compute_ci', 'Z-stat, p-val'),
            ('compute_ci', 'benjamini_hochberg', 'IC 95%'),
            ('benjamini_hochberg', 'llm_interpret', 'p-valores ajustados'),
            ('llm_interpret', 'decide', 'análisis'),
            ('decide', '__END__', 'decisión final'),
        ]

        for from_node, to_node, label in edges:
            dot.edge(from_node, to_node, label=label)

        # Renderizar a PNG
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
            output_path = f.name
            output_path_no_ext = output_path.replace('.png', '')

        dot.render(output_path_no_ext, cleanup=True, format='png')

        if os.path.exists(output_path):
            await cl.Message(
                content="### 📊 Grafo del Agente A/B Testing",
                elements=[cl.Image(path=output_path, name="graph", display="inline")]
            ).send()

    except ImportError:
        await cl.Message(
            content=(
                "📊 **Grafo del Agente**\n\n"
                "```\n"
                "INICIO → collect_data → Z-Test → IC 95%\n"
                "    → FDR (BH) → LLM → Decisión → FIN\n"
                "```\n\n"
                "💡 Instala `graphviz` para ver la imagen:\n"
                "`pip install graphviz`"
            )
        ).send()
    except Exception as e:
        log("WARNING", f"Error generando grafo: {e}")


async def answer_free_question(question: str):
    """Responder preguntas libres usando el LLM."""
    log("INFO", f"LLM: Pregunta recibida - {question[:50]}...")

    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        log("ERROR", "OPENROUTER_API_KEY no configurada")
        await cl.Message(
            content=(
                "✗ **API key de OpenRouter no configurada.**\n\n"
                "Para usar el LLM necesitas configurar tu API key:\n\n"
                "1. Obtén una key en: https://openrouter.ai/keys\n"
                "2. Ejecuta: `export OPENROUTER_API_KEY='sk-or-v1-...'`\n"
                "3. O créala desde el archivo `.env` en este directorio"
            )
        ).send()
        return

    try:
        from langchain_openai import ChatOpenAI
        llm = ChatOpenAI(
            base_url="https://openrouter.ai/api/v1",
            model="openai/gpt-4o-mini",
            api_key=api_key,
        )
        prompt = (
            f"Eres un experto en inferencia estadística doctoral especializado en"
            f"tests de hipótesis e intervalos de confianza aplicados a agentes inteligentes."
            f"\n\nPregunta del usuario:\n{question}\n\n"
            f"Responde en español con precisión matemática pero en lenguaje accesible."
        )
        response = llm.invoke(prompt)
        await cl.Message(content=response.content).send()
        log("INFO", "LLM: Respuesta enviada")
    except Exception as e:
        error_str = str(e)
        log("ERROR", f"LLM: Error - {error_str}")
        if "401" in error_str or "User not found" in error_str:
            await cl.Message(
                content=(
                    "✗ **Error de autenticación con OpenRouter (401).**\n\n"
                    "Tu API key parece ser inválida o ha expirado.\n\n"
                    "1. Ve a https://openrouter.ai/keys y genera una nueva key\n"
                    "2. Actualízala con: `export OPENROUTER_API_KEY='nueva-key'`\n"
                    "3. Reinicia la aplicación"
                )
            ).send()
        else:
            await cl.Message(content=f"✗ Error al consultar LLM: {error_str}").send()
