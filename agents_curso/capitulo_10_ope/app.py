"""
app.py - Capítulo 10: Off-Policy Evaluation (OPE) Fundamentos
==============================================================

Interfaz Chainlit para el agente de evaluación off-policy.

Este módulo proporciona una interfaz de chat interactiva donde el usuario
puede ejecutar el pipeline completo de OPE y recibir explicaciones del LLM
sobre los resultados.

Uso:
    chainlit run app.py

Variables de entorno requeridas:
    OPENROUTER_API_KEY: Clave API para OpenRouter
"""

import os
import chainlit as cl
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from chainlit.types import ThreadDict

# Importar el grafo del agente
from agent_graph import build_ope_graph
from state_schema import OPEState

# ============================================================================
# Configuración del LLM via OpenRouter
# ============================================================================

llm = ChatOpenAI(
    base_url="https://openrouter.ai/api/v1",
    model="openai/gpt-4o-mini",
    api_key=os.environ.get("OPENROUTER_API_KEY"),
    temperature=0.3
)

# ============================================================================
# Estado inicial por defecto
# ============================================================================

DEFAULT_STATE = {
    "behavior_policy_data": [],
    "target_policy": {},
    "dm_estimate": 0.0,
    "dm_se": 0.0,
    "is_estimate": 0.0,
    "is_se": 0.0,
    "dr_estimate": 0.0,
    "dr_se": 0.0,
    "overlap_diagnostics": {},
    "variance_comparison": {},
    "bias_comparison": {},
    "sensitivity_results": {},
    "true_value": 0.0,
    "n_samples": 500,
    "confidence_level": 0.95,
    "llm_analysis": "",
    "report": {}
}


# ============================================================================
# Funciones auxiliares de formato
# ============================================================================

def format_results_report(state: dict) -> str:
    """
    Formatea los resultados del pipeline OPE en un mensaje legible en Markdown.

    Args:
        state: Estado final del agente después de ejecutar el pipeline

    Retorna:
        Cadena en formato Markdown con los resultados
    """
    true_value = state.get("true_value", 0.0)
    report = state.get("report", {})
    estimates = report.get("estimates", {})

    lines = [
        "## 📊 Reporte de Evaluación Off-Policy (OPE)\n",
        f"**Valor verdadero** V^π_e = {true_value:.4f}\n",
        "### Comparación de Estimadores\n",
        "| Estimador | V̂ | Error Estándar | Sesgo | IC 95% |",
        "|-----------|-----|----------------|-------|--------|",
    ]

    for name, est in estimates.items():
        ci = f"[{est['ci_lower']:.4f}, {est['ci_upper']:.4f}]"
        lines.append(
            f"| {name} | {est['value']:.4f} | {est['se']:.4f} | "
            f"{est['bias']:.4f} | {ci} |"
        )

    # Diagnóstico de overlap
    overlap = state.get("overlap_diagnostics", {})
    lines.extend([
        "\n### Diagnóstico de Overlap\n",
        f"- **Ratio mínimo** π_e/π_b: {overlap.get('min_ratio', 'N/A'):.4f}",
        f"- **Ratio máximo** π_e/π_b: {overlap.get('max_ratio', 'N/A'):.4f}",
        f"- **Ratio medio** π_e/π_b: {overlap.get('mean_ratio', 'N/A'):.4f}",
        f"- **Overlap cumplido**: {'✅ Sí' if overlap.get('overlap_condition_met') else '❌ No'}",
    ])

    if overlap.get("warning"):
        lines.append(f"\n> ⚠️ {overlap['warning']}")

    # Recomendaciones
    lines.extend([
        "\n### Recomendaciones\n"
    ])
    for i, rec in enumerate(report.get("recommendations", []), 1):
        lines.append(f"{i}. {rec}")

    # Análisis de sensibilidad
    sensitivity = state.get("sensitivity_results", {})
    if sensitivity.get("results"):
        lines.extend([
            "\n### Análisis de Sensibilidad\n",
            "| ε | Max Ratio | V^π_e | SE(IS) | Calidad |",
            "|---|-----------|--------|--------|---------|",
        ])
        for r in sensitivity["results"]:
            lines.append(
                f"| {r['epsilon']:.2f} | {r['max_ratio']:.2f} | {r['v_true']:.4f} | "
                f"{r['is_se']:.4f} | {r['overlap_quality']} |"
            )

    lines.extend([
        "\n### Referencias\n",
        "- Jiang & Li (2016): *Doubly Robust Off-Policy Value Evaluation for RL*",
        "- Dudík et al. (2011): *Optimally Solving MDPs with Continuous Actions*",
        "- Thomas et al. (2015): *High Confidence Policy Improvement*",
    ])

    return "\n".join(lines)


# ============================================================================
# Handlers de Chainlit
# ============================================================================

@cl.on_chat_start
async def on_chat_start():
    """
    Inicializa la sesión de chat.

    Muestra el mensaje de bienvenida y las instrucciones para el usuario.
    """
    welcome_message = """# 🧮 Capítulo 10: Evaluación Off-Policy (OPE) Fundamentos

Bienvenido al agente interactivo de **Off-Policy Evaluation**.

## ¿Qué hace este agente?

Este agente implementa un pipeline completo de evaluación off-policy con tres estimadores:

1. **Método Directo (DM)**: V̂_DM = Σ_s μ₀(s) Σ_a π_e(a|s) Q̂(s,a)
   - ✅ Baja varianza
   - ❌ Potencialmente sesgado

2. **Importance Sampling (IS)**: V̂_IS = (1/n) Σ ρ_t G_t
   - ✅ Insesgado
   - ❌ Alta varianza (curse of horizon)

3. **Doubly Robust (DR)**: V̂_DR = V̂_DM + (1/n) Σ ρ_t (G_t - Q̂(S_t,A_t))
   - ✅ Doble robustez
   - ✅ Mejor compromiso sesgo-varianza

## Comandos disponibles

- **"ejecutar pipeline"**: Ejecuta el análisis completo de OPE
- **"explicar OPE"**: El LLM explica la teoría de evaluación off-policy
- **"explicar overlap"**: Explica la condición de solapamiento
- **"explicar curse of horizon"**: Explica por qué la varianza crece exponencialmente
- **"análisis de sensibilidad"**: Ejecuta análisis variando ε
- Cualquier otra pregunta será respondida por el LLM

## Referencias clave

- Jiang & Li (2016) - Doubly Robust Off-Policy Value Evaluation
- Dudík et al. (2011) - Optimally Solving MDPs
- Thomas et al. (2015) - High Confidence Policy Improvement
"""

    await cl.Message(content=welcome_message).send()

    # Almacenar el grafo en la sesión del usuario
    cl.user_session.set("graph", build_ope_graph())
    cl.user_session.set("state", DEFAULT_STATE.copy())


@cl.on_message
async def on_message(message: cl.Message):
    """
    Maneja los mensajes del usuario y ejecuta las acciones correspondientes.
    """
    user_input = message.content.strip().lower()
    graph = cl.user_session.get("graph")
    current_state = cl.user_session.get("state")

    # ---------------------------------------------------------------
    # Comando: Ejecutar pipeline completo
    # ---------------------------------------------------------------
    if "ejecutar" in user_input and "pipeline" in user_input:
        await cl.Message(content="🚀 Ejecutando pipeline completo de OPE...").send()

        try:
            # Ejecutar el grafo LangGraph
            result = graph.invoke(current_state)

            # Actualizar estado en la sesión
            cl.user_session.set("state", result)

            # Si hay análisis del LLM pendiente, consultarlo
            llm_prompt = result.get("llm_analysis", "")
            if llm_prompt:
                response = await llm.ainvoke([
                    SystemMessage(content=(
                        "Eres un profesor de estadística a nivel doctoral. "
                        "Explica los resultados de evaluación off-policy en español, "
                        "usando notación matemática y referenciando la literatura relevante. "
                        "Sé riguroso pero pedagógico."
                    )),
                    HumanMessage(content=llm_prompt)
                ])
                result["llm_analysis"] = response.content

            # Formatear y enviar reporte
            report = format_results_report(result)
            await cl.Message(content=report).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error ejecutando el pipeline: {str(e)}").send()

    # ---------------------------------------------------------------
    # Comando: Explicar OPE
    # ---------------------------------------------------------------
    elif "explicar ope" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre OPE...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral especializado en "
                "aprendizaje por refuerzo. Explica en español y con detalle el concepto "
                "de evaluación off-policy (Off-Policy Evaluation, OPE). Incluye:\n"
                "1. Definición formal del problema\n"
                "2. Los tres estimadores principales (DM, IS, DR)\n"
                "3. La propiedad de doble robustez\n"
                "4. La condición de overlap\n"
                "5. El curse of horizon\n"
                "Usa notación matemática donde sea apropiado."
            )),
            HumanMessage(content="Explícame en detalle qué es la evaluación off-policy (OPE) "
                                "y cuáles son sus principales desafíos metodológicos.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Comando: Explicar overlap
    # ---------------------------------------------------------------
    elif "explicar overlap" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre la condición de overlap...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "la condición de overlap (solapamiento) en evaluación off-policy. "
                "Incluye:\n"
                "1. Definición formal: π_b(a|s) > 0 siempre que π_e(a|s) > 0\n"
                "2. Por qué es necesaria\n"
                "3. Qué pasa cuando se viola\n"
                "4. Cómo diagnosticarla en la práctica\n"
                "5. Estrategias de mitigación"
            )),
            HumanMessage(content="Explícame la condición de overlap en evaluación off-policy.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Comando: Explicar curse of horizon
    # ---------------------------------------------------------------
    elif "curse" in user_input or "horizon" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre el curse of horizon...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el 'curse of horizon' en evaluación off-policy. Incluye:\n"
                "1. Por qué la varianza crece exponencialmente con el horizonte\n"
                "2. La relación con los ratios de importancia\n"
                "3. Cómo afecta a cada estimador\n"
                "4. Estrategias para mitigarlo (truncamiento, DR, etc.)"
            )),
            HumanMessage(content="Explícame el curse of horizon en evaluación off-policy.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Comando: Análisis de sensibilidad
    # ---------------------------------------------------------------
    elif "sensibilidad" in user_input:
        await cl.Message(content="📊 Ejecutando análisis de sensibilidad...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            sensitivity = result.get("sensitivity_results", {})
            if sensitivity.get("results"):
                lines = [
                    "## 📊 Análisis de Sensibilidad al Overlap\n",
                    "| ε | Max Ratio | V^π_e | SE(IS) | Calidad |",
                    "|---|-----------|--------|--------|---------|",
                ]
                for r in sensitivity["results"]:
                    lines.append(
                        f"| {r['epsilon']:.2f} | {r['max_ratio']:.2f} | "
                        f"{r['v_true']:.4f} | {r['is_se']:.4f} | {r['overlap_quality']} |"
                    )

                lines.append(f"\n**Hallazgo clave**: {sensitivity.get('key_finding', '')}")

                await cl.Message(content="\n".join(lines)).send()
            else:
                await cl.Message(content="Ejecuta primero el pipeline completo.").send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Comando: Explicar doble robustez
    # ---------------------------------------------------------------
    elif "doble" in user_input or "robust" in user_input or "dr" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre doble robustez...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "la propiedad de doble robustez del estimador Doubly Robust (DR). "
                "Incluye:\n"
                "1. Definición formal del estimador DR\n"
                "2. Demostración intuitiva de por qué es doblemente robusto\n"
                "3. En qué casos se reduce a IS o DM\n"
                "4. Ventajas sobre IS puro en términos de varianza\n"
                "Referencia: Jiang & Li (2016)"
            )),
            HumanMessage(content="Explícame la propiedad de doble robustez del estimador DR.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Comando: Comparar estimadores
    # ---------------------------------------------------------------
    elif "comparar" in user_input or "estimador" in user_input:
        await cl.Message(content="📊 Preparando comparación de estimadores...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            bias = result.get("bias_comparison", {})
            variance = result.get("variance_comparison", {})

            lines = [
                "## ⚖️ Comparación de Estimadores: Sesgo vs Varianza\n",
                "| Estimador | Sesgo | Varianza | MSE |",
                "|-----------|-------|----------|-----|",
            ]
            for name in bias:
                b = bias[name]
                v = variance.get(name, {})
                mse = b.get("mse", 0)
                var = v.get("variance", 0)
                lines.append(f"| {name} | {b['bias']:.4f} | {var:.4f} | {mse:.4f} |")

            lines.extend([
                "\n### Interpretación\n",
                "- **DM**: Baja varianza pero potencialmente alto sesgo (model bias)",
                "- **IS**: Insesgado pero varianza puede ser explosiva",
                "- **DR**: Mejor compromiso, doble robustez"
            ])

            await cl.Message(content="\n".join(lines)).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Consulta general al LLM
    # ---------------------------------------------------------------
    else:
        await cl.Message(content="💭 Consultando al LLM...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral especializado en "
                "aprendizaje por refuerzo y evaluación off-policy. "
                "Responde en español con rigor académico. "
                "Usa notación matemática cuando sea apropiado. "
                "Si la pregunta es sobre OPE, relaciona la respuesta con los "
                "estimadores DM, IS, DR y la condición de overlap. "
                "Referencias: Jiang & Li (2016), Dudík et al. (2011), Thomas et al. (2015)."
            )),
            HumanMessage(content=message.content)
        ])

        await cl.Message(content=response.content).send()
