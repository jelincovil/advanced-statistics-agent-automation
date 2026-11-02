"""
app.py - Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre
==================================================================================

Interfaz Chainlit para el agente capstone que integra inferencia estadística
con guía de LLM para la toma de decisiones bajo incertidumbre.

Este agente demuestra tres paradigmas:
1. Solo estadística (intervalos de confianza para guiar exploración)
2. Solo LLM (heurísticas del modelo de lenguaje)
3. Combinado (IC + LLM) → superior

Uso:
    chainlit run app.py

Variables de entorno requeridas:
    OPENROUTER_API_KEY: Clave API para OpenRouter
"""

import os
import chainlit as cl
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

from agent_graph import build_synthesis_graph, StochasticBanditEnv

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
    "current_beliefs": {},
    "data_collected": [],
    "v_estimate": {},
    "uncertainty_width": 10.0,
    "exploration_budget": 20,
    "action_history": [],
    "consultation_results": [],
    "performance_history": [],
    "current_mode": "explore",
    "meta_criterion": {},
    "llm_analysis": "",
    "final_report": {},
    "iteration": 0,
    "ablation_results": {},
    "stopping_reason": "",
    "n_explore_steps": 0,
    "n_consult_steps": 0,
    "n_act_steps": 0
}


# ============================================================================
# Funciones auxiliares de formato
# ============================================================================

def format_synthesis_report(state: dict) -> str:
    """
    Formatea los resultados del agente capstone en Markdown.

    Args:
        state: Estado final del agente

    Retorna:
        Cadena Markdown con los resultados
    """
    report = state.get("final_report", {})
    decision = report.get("decision_process", {})
    inference = report.get("statistical_inference", {})
    ablation = report.get("ablation_study", {})
    llm_contrib = report.get("llm_contribution", {})

    lines = [
        "## 🎯 Reporte del Agente Capstone\n",
        "### Proceso de Decisión\n",
        f"| Acción | Veces |",
        f"|--------|-------|",
        f"| 🔍 Explorar | {decision.get('n_explore', 0)} |",
        f"| 🤖 Consultar LLM | {decision.get('n_consult', 0)} |",
        f"| 🎯 Actuar | {decision.get('n_act', 0)} |",
        f"| **Total** | **{decision.get('total_decisions', 0)}** |",
    ]

    # Secuencia de decisiones
    sequence = decision.get("action_sequence", [])
    if sequence:
        lines.extend([
            "\n#### Secuencia de Decisiones\n",
            "```\n" + " → ".join(sequence) + "\n```"
        ])

    # Inferencia estadística
    lines.extend([
        "\n### Inferencia Estadística\n",
        f"- **Brazo seleccionado**: {inference.get('best_arm', '?')}",
        f"- **Media estimada**: {inference.get('best_mean', 0):.3f}",
        f"- **Incertidumbre final**: {inference.get('final_uncertainty', 0):.3f}",
    ])

    # ICs por brazo
    cis = inference.get("confidence_intervals", {})
    if cis:
        lines.extend([
            "\n#### Intervalos de Confianza por Brazo\n",
            "| Brazo | Media | IC Inferior | IC Superior | Ancho |",
            "|-------|-------|-------------|-------------|-------|",
        ])
        for arm, ci in cis.items():
            width = ci["ci_upper"] - ci["ci_lower"]
            lines.append(
                f"| {arm} | {ci['mean']:.3f} | {ci['ci_lower']:.3f} | "
                f"{ci['ci_upper']:.3f} | {width:.3f} |"
            )

    # Contribución del LLM
    lines.extend([
        "\n### Contribución del LLM\n",
        f"- **Consultas realizadas**: {llm_contrib.get('n_consultations', 0)}",
    ])

    consults = llm_contrib.get("consultations_summary", [])
    if consults:
        for c in consults:
            lines.append(f"  - Iter {c['iter']}: recomendó `{c['rec']}`")

    # Estudio de ablation
    if ablation:
        lines.extend([
            "\n### Estudio de Ablation\n",
            "| Variante | Brazo | Recompensa | Eficiencia | Correcto |",
            "|----------|-------|------------|------------|----------|",
        ])
        labels = {
            "statistics_only": "📊 Solo Estadística",
            "llm_only": "🤖 Solo LLM",
            "combined": "🔗 Combinado (IC+LLM)"
        }
        for name, r in ablation.items():
            label = labels.get(name, name)
            lines.append(
                f"| {label} | {r['best_arm']} | {r['mean_reward']:.3f} | "
                f"{r['efficiency']:.1%} | {'✅' if r['correct'] else '❌'} |"
            )

    # Conclusiones
    conclusions = report.get("conclusions", [])
    if conclusions:
        lines.extend(["\n### Conclusiones\n"])
        for i, c in enumerate(conclusions, 1):
            lines.append(f"{i}. {c}")

    # Referencias
    lines.extend([
        "\n### Referencias\n",
        "- Shi et al. (2024) JASA - *Uncertainty-Aware Decision Making*",
        "- Yao et al. (2023) ICLR ReAct - *Reasoning and Acting*",
        "- Shinn et al. (2023) NeurIPS Reflexion - *Language Agents with Verbal Reinforcement Learning*",
        "- Zhai et al. (2025) AAAI - *Q-values for LLM Agents*",
    ])

    return "\n".join(lines)


# ============================================================================
# Handlers de Chainlit
# ============================================================================

@cl.on_chat_start
async def on_chat_start():
    """
    Inicializa la sesión de chat con el agente capstone.
    """
    welcome_message = """# 🎯 Capítulo 12: Síntesis - LLM-Agents y Decisión Guiada por Incertidumbre

Bienvenido al **agente capstone** que integra todo el libro.

## Paradigma Central

Este agente demuestra cómo combinar **inferencia estadística** con **orientación de LLM**
para tomar mejores decisiones bajo incertidumbre.

### Tres Modos de Operación

| Modo | Condición | Acción |
|------|-----------|--------|
| 🔍 **EXPLORE** | IC ancho > ε_explore | Recolectar más datos |
| 🤖 **CONSULT** | ε_consult < IC ≤ ε_explore | Preguntar al LLM |
| 🎯 **ACT** | IC ancho ≤ ε_consult | Ejecutar mejor acción |

### Estudio de Ablation

El agente ejecuta 3 variantes:
1. **Solo Estadística**: UCB con ICs, sin LLM
2. **Solo LLM**: Heurísticas del modelo, sin inferencia formal
3. **Combinado**: IC estadístico + guía LLM → **superior**

## Comandos disponibles

- **"ejecutar agente"**: Ejecuta el agente completo con ablation
- **"ejecutar solo estadística"**: Variante sin LLM
- **"ejecutar solo LLM"**: Variante sin IC
- **"explicar paradigma"**: El LLM explica el marco conceptual
- **"explicar ablation"**: Explica el estudio de ablation
- **"explicar meta-criterio"**: Explica los umbrales adaptativos
- **"explicar ReAct"**: Explica Reasoning and Acting
- **"diagnosticar decisión"**: Muestra el proceso de decisión paso a paso
- **"comparar variantes"**: Tabla comparativa de ablation
- Cualquier otra pregunta será respondida por el LLM

## Referencias clave

- Shi et al. (2024) JASA - Uncertainty-Aware Decision Making
- Yao et al. (2023) ICLR ReAct - Reasoning and Acting
- Shinn et al. (2023) NeurIPS Reflexion - Language Agents
- Zhai et al. (2025) AAAI - Q-values for LLM Agents
"""

    await cl.Message(content=welcome_message).send()

    cl.user_session.set("graph", build_synthesis_graph())
    cl.user_session.set("state", DEFAULT_STATE.copy())


@cl.on_message
async def on_message(message: cl.Message):
    """
    Maneja los mensajes del usuario.
    """
    user_input = message.content.strip().lower()
    graph = cl.user_session.get("graph")
    current_state = cl.user_session.get("state")

    # ---------------------------------------------------------------
    # Ejecutar agente completo
    # ---------------------------------------------------------------
    if "ejecutar agente" in user_input or ("ejecutar" in user_input and "ablation" not in user_input):
        await cl.Message(content="🚀 Ejecutando agente capstone completo...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            # Interpretar con LLM
            llm_prompt = result.get("llm_analysis", "")
            if llm_prompt:
                response = await llm.ainvoke([
                    SystemMessage(content=(
                        "Eres un profesor de estadística a nivel doctoral especializado en "
                        "aprendizaje por refuerzo y agentes de IA. "
                        "Explica los resultados del agente capstone en español, "
                        "analizando el proceso de decisión, la contribución del LLM, "
                        "y los resultados del estudio de ablation. "
                        "Referencia: Shi et al. (2024) JASA, Yao et al. (2023) ReAct."
                    )),
                    HumanMessage(content=llm_prompt)
                ])
                result["llm_analysis"] = response.content

            report = format_synthesis_report(result)

            # Agregar análisis del LLM
            if result.get("llm_analysis"):
                report += "\n\n---\n\n### 🤖 Análisis del LLM\n\n"
                report += result["llm_analysis"]

            await cl.Message(content=report).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error ejecutando el agente: {str(e)}").send()

    # ---------------------------------------------------------------
    # Explicar paradigma
    # ---------------------------------------------------------------
    elif "explicar paradigma" in user_input or "paradigma" in user_input:
        await cl.Message(content="📚 Consultando al LLM...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el paradigma de 'Decisión Guiada por Incertidumbre con LLM Agents'. "
                "Incluye:\n"
                "1. El problema de exploración vs explotación\n"
                "2. Cómo los intervalos de confianza guían la exploración\n"
                "3. El rol del LLM como consultor estratégico\n"
                "4. Los tres modos: EXPLORE, CONSULT, ACT\n"
                "5. Por qué la combinación estadística + LLM es superior\n"
                "Referencia: Shi et al. (2024) JASA, Yao et al. (2023) ReAct"
            )),
            HumanMessage(content="Explícame el paradigma de decisión guiada por "
                                "incertidumbre con agentes LLM.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar ablation
    # ---------------------------------------------------------------
    elif "ablation" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre el estudio de ablation...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el estudio de ablation en el contexto de agentes de decisión con LLM. "
                "Incluye:\n"
                "1. Qué es un estudio de ablation y por qué es importante\n"
                "2. Las tres variantes: solo estadística, solo LLM, combinado\n"
                "3. Qué se espera de cada variante\n"
                "4. Por qué la variante combinada debería ser superior\n"
                "5. Limitaciones y consideraciones metodológicas\n"
                "Referencia: Yao et al. (2023) ICLR ReAct, Shi et al. (2024) JASA"
            )),
            HumanMessage(content="Explícame el estudio de ablation y qué muestra.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar meta-criterio
    # ---------------------------------------------------------------
    elif "meta-criterio" in user_input or "meta" in user_input or "umbral" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre meta-criterio...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el concepto de meta-criterio adaptativo en el contexto de agentes de "
                "decisión. Incluye:\n"
                "1. Qué son los umbrales ε_explore y ε_consult\n"
                "2. Cómo se ajustan dinámicamente según el presupuesto\n"
                "3. La relación con el criterio de información de Akaike (AIC)\n"
                "4. Por qué la adaptación de umbrales mejora la eficiencia\n"
                "5. Conexión con el principio de optimalidad de Bellman"
            )),
            HumanMessage(content="Explícame el meta-criterio adaptativo del agente.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar ReAct
    # ---------------------------------------------------------------
    elif "react" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre ReAct...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de IA a nivel doctoral. Explica en español "
                "el framework ReAct (Reasoning and Acting) de Yao et al. (2023). "
                "Incluye:\n"
                "1. La distinción entre razonamiento (thought) y acción (action)\n"
                "2. Cómo ReAct mejora sobre CoT puro\n"
                "3. La integración con entornos externos\n"
                "4. Aplicaciones en RL y agentes autónomos\n"
                "5. Relación con nuestro agente capstone\n"
                "Referencia: Yao et al. (2023) ICLR"
            )),
            HumanMessage(content="Explícame el framework ReAct.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Diagnosticar decisión
    # ---------------------------------------------------------------
    elif "diagnosticar" in user_input or "proceso" in user_input:
        await cl.Message(content="🔍 Ejecutando agente para diagnóstico...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            history = result.get("action_history", [])
            consultations = result.get("consultation_results", [])
            v_est = result.get("v_estimate", {})
            perf = result.get("performance_history", [])

            lines = [
                "## 🔍 Diagnóstico del Proceso de Decisión\n",
                "### Secuencia Completa de Decisiones\n",
            ]

            # Reconstruir iteraciones
            step = 0
            for action in history:
                step += 1
                if action == "explore":
                    lines.append(f"**Paso {step}**: 🔍 EXPLORE — Recolectar datos")
                elif action == "consult_llm":
                    # Encontrar la consulta correspondiente
                    idx = min(sum(1 for a in history[:step] if a == "consult_llm") - 1,
                             len(consultations) - 1)
                    if idx >= 0 and idx < len(consultations):
                        rec = consultations[idx].get("recommendation", "?")
                        lines.append(f"**Paso {step}**: 🤖 CONSULT — LLM recomendó: `{rec}`")
                    else:
                        lines.append(f"**Paso {step}**: 🤖 CONSULT — Consultar LLM")
                elif action == "act":
                    arm = v_est.get("best_arm", "?")
                    lines.append(f"**Paso {step}**: 🎯 ACT — Brazo {arm}")

            # Estadísticas
            n_explore = history.count("explore")
            n_consult = history.count("consult_llm")
            n_act = history.count("act")

            lines.extend([
                f"\n### Resumen\n",
                f"- Total de decisiones: {len(history)}",
                f"- Exploración: {n_explore} ({n_explore/max(len(history),1):.0%})",
                f"- Consultas LLM: {n_consult} ({n_cons/max(len(history),1):.0%})",
                f"- Acciones: {n_act} ({n_act/max(len(history),1):.0%})",
                f"- Brazo final: {v_est.get('best_arm', '?')}",
                f"- Incertidumbre final: {result.get('uncertainty_width', 0):.3f}",
            ])

            if perf:
                lines.append(f"- Recompensa media: {np.mean(perf):.3f}")

            await cl.Message(content="\n".join(lines)).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Comparar variantes
    # ---------------------------------------------------------------
    elif "comparar" in user_input or "variante" in user_input:
        await cl.Message(content="📊 Ejecutando agente para comparación...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            ablation = result.get("ablation_results", {})

            if ablation:
                lines = [
                    "## 📊 Comparación de Variantes (Ablation)\n",
                    "| Variante | Brazo | Recompensa | Eficiencia | Correcto |",
                    "|----------|-------|------------|------------|----------|",
                ]
                labels = {
                    "statistics_only": "📊 Solo Estadística",
                    "llm_only": "🤖 Solo LLM",
                    "combined": "🔗 Combinado (IC+LLM)"
                }
                for name, r in ablation.items():
                    label = labels.get(name, name)
                    lines.append(
                        f"| {label} | {r['best_arm']} | {r['mean_reward']:.3f} | "
                        f"{r['efficiency']:.1%} | {'✅' if r['correct'] else '❌'} |"
                    )

                lines.extend([
                    "\n### Análisis\n",
                    "- **Solo Estadística**: Usa UCB e ICs. Robusto pero puede ser conservador.",
                    "- **Solo LLM**: Usa heurísticas del modelo. Puede ser efectivo pero sin garantías.",
                    "- **Combinado**: ICs guían la exploración + LLM aporta estrategia. **Superior**."
                ])

                await cl.Message(content="\n".join(lines)).send()
            else:
                await cl.Message(content="Ejecuta primero el agente completo.").send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Mostrar ICs
    # ---------------------------------------------------------------
    elif "ic" in user_input or "intervalo" in user_input or "confianza" in user_input:
        await cl.Message(content="📊 Calculando intervalos de confianza...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            v_est = result.get("v_estimate", {})
            cis = v_est.get("all_ci", {})

            if cis:
                lines = [
                    "## 📊 Intervalos de Confianza por Brazo\n",
                    "| Brazo | Media | IC 95% Inferior | IC 95% Superior | Ancho |",
                    "|-------|-------|-----------------|-----------------|-------|",
                ]
                for arm, ci in cis.items():
                    width = ci["ci_upper"] - ci["ci_lower"]
                    best = "⭐" if arm == v_est.get("best_arm") else ""
                    lines.append(
                        f"| {arm} {best} | {ci['mean']:.3f} | {ci['ci_lower']:.3f} | "
                        f"{ci['ci_upper']:.3f} | {width:.3f} |"
                    )

                # Verificar solapamiento
                all_uppers = [ci["ci_upper"] for ci in cis.values()]
                all_lowers = [ci["ci_lower"] for ci in cis.values()]

                lines.extend([
                    f"\n- **Ancho máximo IC**: {result.get('uncertainty_width', 0):.3f}",
                    f"- **¿ICs se superponen?**: "
                    f"{'Sí — no se puede distinguir' if max(all_lowers) < min(all_uppers) else 'Parcial'}",
                    f"- **Brazo seleccionado**: {v_est.get('best_arm', '?')}",
                ])

                await cl.Message(content="\n".join(lines)).send()
            else:
                await cl.Message(content="No hay datos suficientes. Ejecuta el agente primero.").send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Mostrar contribución del LLM
    # ---------------------------------------------------------------
    elif "llm" in user_input and ("contribución" in user_input or "contribución" in user_input):
        await cl.Message(content="📊 Mostrando contribución del LLM...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            consultations = result.get("consultation_results", [])

            if consultations:
                lines = [
                    "## 🤖 Contribución del LLM\n",
                    f"**Consultas totales**: {len(consultations)}\n",
                ]

                for i, c in enumerate(consultations, 1):
                    lines.append(f"### Consulta {i} (Iteración {c.get('iteration', '?')})\n")
                    lines.append(f"**Recomendación**: `{c.get('recommendation', '?')}`\n")
                    lines.append(f"**Respuesta**:\n> {c.get('response', 'N/A')[:300]}...\n")

                await cl.Message(content="\n".join(lines)).send()
            else:
                await cl.Message(content="No hubo consultas al LLM en esta ejecución.").send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Explicar Reflexion
    # ---------------------------------------------------------------
    elif "reflexion" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre Reflexion...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de IA a nivel doctoral. Explica en español "
                "el framework Reflexion de Shinn et al. (2023) NeurIPS. "
                "Incluye:\n"
                "1. El mecanismo de reflexión verbal\n"
                "2. Cómo se usa el lenguaje natural como memoria\n"
                "3. La diferencia con RL convencional\n"
                "4. Aplicaciones en agentes autónomos\n"
                "5. Relación con nuestro agente capstone que usa consultas al LLM\n"
                "Referencia: Shinn et al. (2023) NeurIPS"
            )),
            HumanMessage(content="Explícame el framework Reflexion.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Consulta general al LLM
    # ---------------------------------------------------------------
    else:
        await cl.Message(content="💭 Consultando al LLM...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística e IA a nivel doctoral. "
                "Tu especialidad es la intersección entre inferencia estadística, "
                "aprendizaje por refuerzo y agentes con modelos de lenguaje. "
                "Responde en español con rigor académico. "
                "Usa notación matemática cuando sea apropiado. "
                "Temas relevantes: decisión bajo incertidumbre, intervalos de confianza, "
                "exploración-explotación, LLM agents, ReAct, Reflexion, "
                "off-policy evaluation, SAVE, Q-values para agentes. "
                "Referencias: Shi et al. (2024) JASA, Yao et al. (2023) ReAct, "
                "Shinn et al. (2023) Reflexion, Zhai et al. (2025) AAAI."
            )),
            HumanMessage(content=message.content)
        ])

        await cl.Message(content=response.content).send()
