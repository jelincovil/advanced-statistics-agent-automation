"""
app.py - Capítulo 11: Inferencia Secuencial para Funciones de Valor (SAVE)
===========================================================================

Interfaz Chainlit para el agente de inferencia asintótica de V^π.

Este módulo proporciona una interfaz de chat interactiva donde el usuario
puede ejecutar el pipeline SAVE y recibir explicaciones del LLM sobre
inferencia con dependencia temporal.

Uso:
    chainlit run app.py

Variables de entorno requeridas:
    OPENROUTER_API_KEY: Clave API para OpenRouter
"""

import os
import chainlit as cl
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

from agent_graph import build_save_graph, compute_discounted_return
from state_schema import SAVEState

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
    "trajectories": [],
    "v_hat": 0.0,
    "se_estimate": 0.0,
    "asymptotic_ci": {},
    "bootstrap_ci": {},
    "mixing_diagnostics": {},
    "temporal_dependence": {},
    "power_analysis": {},
    "n_min_for_delta": 0,
    "n_trajectories": 200,
    "trajectory_length": 50,
    "gamma": 0.95,
    "true_value": 0.0,
    "batch_sizes": [],
    "batch_se_estimates": [],
    "bootstrap_samples": [],
    "llm_analysis": "",
    "report": {}
}


# ============================================================================
# Funciones auxiliares de formato
# ============================================================================

def format_save_report(state: dict) -> str:
    """
    Formatea los resultados del pipeline SAVE en Markdown.

    Args:
        state: Estado final del agente

    Retorna:
        Cadena Markdown con los resultados
    """
    true_val = state.get("true_value", 0.0)
    report = state.get("report", {})
    est = report.get("estimation", {})
    ci = report.get("confidence_intervals", {})
    mixing = state.get("mixing_diagnostics", {})
    temporal = state.get("temporal_dependence", {})
    power = state.get("power_analysis", {})

    lines = [
        "## 📊 Reporte de Inferencia Asintótica para V^π (SAVE)\n",
        f"**Valor verdadero** V^π = {true_val:.4f}",
        f"**Estimación** V̂ = {est.get('v_hat', 0):.4f} ± {est.get('se', 0):.4f}\n",
        "### Intervalos de Confianza (95%)\n",
        "| Método | Límite Inferior | Límite Superior | Ancho | Cubre V* |",
        "|--------|----------------|-----------------|-------|----------|",
    ]

    asymp = ci.get("asymptotic", {})
    boot = ci.get("bootstrap", {})

    if asymp:
        lines.append(
            f"| Asintótico | {asymp.get('lower', 0):.4f} | {asymp.get('upper', 0):.4f} | "
            f"{asymp.get('width', 0):.4f} | {'✅' if asymp.get('covers_true') else '❌'} |"
        )
    if boot:
        lines.append(
            f"| Block Bootstrap | {boot.get('lower', 0):.4f} | {boot.get('upper', 0):.4f} | "
            f"{boot.get('width', 0):.4f} | {'✅' if boot.get('covers_true') else '❌'} |"
        )

    # Dependencia temporal
    lines.extend([
        "\n### Dependencia Temporal\n",
        f"- **Varianza espectral** σ²_∞ = {temporal.get('spectral_variance', 0):.4f}",
        f"- **Factor de inflación** = {temporal.get('inflation_ratio', 0):.2f}x",
        f"- **τ_int** = {mixing.get('tau_integrated', 0):.2f}",
        f"- **ESS** = {mixing.get('effective_sample_size', 0):.1f} "
        f"(de {mixing.get('raw_sample_size', 0)})",
    ])

    # Autocorrelaciones
    acfs = mixing.get("autocorrelations", [])
    if acfs:
        lines.extend([
            "\n#### Autocorrelación de Retornos\n",
            "| Lag | ρ(k) |",
            "|-----|------|",
        ])
        for a in acfs[:10]:
            lines.append(f"| {a['lag']} | {a['acf']:.4f} |")

    # Análisis de potencia
    power_results = power.get("results", [])
    if power_results:
        lines.extend([
            "\n### Análisis de Potencia (α=0.05, potencia=80%)\n",
            "| δ (efecto) | n_min requerido |",
            "|-------------|------------------|",
        ])
        for r in power_results:
            lines.append(f"| {r['delta']:.2f} | {r['n_required']} |")

    # Recomendaciones
    lines.extend([
        "\n### Recomendaciones\n"
    ])
    for i, rec in enumerate(report.get("recommendations", []), 1):
        lines.append(f"{i}. {rec}")

    # Referencias
    lines.extend([
        "\n### Referencias\n",
        "- Shi et al. (2022) JRSSB - *Sequential Inference for Value Functions*",
        "- Kallus & Uehara (2020) - *Double/Debiased ML for Offline RL*",
        "- Kallus & Uehara (2022) - *Efficiently Breaking the Curse of Horizon*",
    ])

    return "\n".join(lines)


# ============================================================================
# Handlers de Chainlit
# ============================================================================

@cl.on_chat_start
async def on_chat_start():
    """
    Inicializa la sesión de chat.

    Muestra el mensaje de bienvenida y las instrucciones.
    """
    welcome_message = """# 📐 Capítulo 11: Inferencia Asintótica para V^π (SAVE)

Bienvenido al agente interactivo de **Sequential Asymptotic Variance Estimation**.

## ¿Qué hace este agente?

Este agente realiza **inferencia estadística** para funciones de valor V^π,
tomando en cuenta la **dependencia temporal** inherente a los datos de RL.

### Conceptos clave:

1. **Varianza Espectral**: σ²_∞ = Var(G₀) + 2 Σ_{k=1}^∞ Cov(G₀, G_k)
2. **TCL para Cadenas de Markov**: √n(V̂-V*) →d N(0, σ²_∞)
3. **Batch Means**: Estima σ²_∞ dividiendo datos en lotes
4. **Block Bootstrap**: Preserva dependencia en remuestreo
5. **ESS**: Tamaño efectivo de muestra (n/τ_int)

## Comandos disponibles

- **"ejecutar pipeline"**: Ejecuta el análisis SAVE completo
- **"explicar SAVE"**: El LLM explica la teoría SAVE
- **"explicar TCL Markov"**: Explica el TCL para cadenas de Markov
- **"explicar varianza espectral"**: Explica σ²_∞ y la dependencia temporal
- **"explicar batch means"**: Explica el método de batch means
- **"explicar block bootstrap"**: Explica el bootstrap por bloques
- **"análisis de potencia"**: Muestra análisis de potencia
- **"diseño experimental"**: Recomendación de tamaño muestral
- Cualquier otra pregunta será respondida por el LLM

## Referencias clave

- Shi et al. (2022) JRSSB - Sequential Inference for Value Functions
- Kallus & Uehara (2020) - Double/Debiased ML for Offline RL
- Kallus & Uehara (2022) - Efficiently Breaking the Curse of Horizon
"""

    await cl.Message(content=welcome_message).send()

    cl.user_session.set("graph", build_save_graph())
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
    # Ejecutar pipeline completo
    # ---------------------------------------------------------------
    if "ejecutar" in user_input and "pipeline" in user_input:
        await cl.Message(content="🚀 Ejecutando pipeline SAVE completo...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            # Consultar LLM para interpretación
            llm_prompt = result.get("llm_analysis", "")
            if llm_prompt:
                response = await llm.ainvoke([
                    SystemMessage(content=(
                        "Eres un profesor de estadística a nivel doctoral. "
                        "Explica los resultados de inferencia asintótica para V^π "
                        "en español, con notación matemática. Referencia: "
                        "Shi et al. (2022) JRSSB, Kallus & Uehara (2020/2022)."
                    )),
                    HumanMessage(content=llm_prompt)
                ])
                result["llm_analysis"] = response.content

            report = format_save_report(result)
            await cl.Message(content=report).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error ejecutando el pipeline: {str(e)}").send()

    # ---------------------------------------------------------------
    # Explicar SAVE
    # ---------------------------------------------------------------
    elif "explicar save" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre SAVE...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral especializado en "
                "inferencia para aprendizaje por refuerzo. Explica en español y con "
                "detalle el framework SAVE (Sequential Asymptotic Variance Estimation). "
                "Incluye:\n"
                "1. El problema de inferencia para V^π\n"
                "2. Por qué los retornos son dependientes\n"
                "3. La varianza espectral σ²_∞\n"
                "4. Batch means y block bootstrap\n"
                "5. Condiciones de mezcla para el TCL\n"
                "Referencia: Shi et al. (2022) JRSSB"
            )),
            HumanMessage(content="Explícame el framework SAVE para inferencia de V^π.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar TCL para Markov
    # ---------------------------------------------------------------
    elif "tcl" in user_input or "markov" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre el TCL para cadenas de Markov...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el Teorema Central del Límite para cadenas de Markov. Incluye:\n"
                "1. El TCL estándar (iid) y por qué no aplica directamente\n"
                "2. El TCL para cadenas de Markov geométricamente ergódicas\n"
                "3. La condición de mezcla\n"
                "4. La varianza asintótica σ²_∞\n"
                "5. Implicaciones prácticas para inferencia en RL"
            )),
            HumanMessage(content="Explícame el TCL para cadenas de Markov y su aplicación a V^π.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar varianza espectral
    # ---------------------------------------------------------------
    elif "varianza espectral" in user_input or "espectral" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre varianza espectral...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "la varianza espectral en el contexto de datos dependientes. Incluye:\n"
                "1. Definición: σ²_∞ = Var(G₀) + 2 Σ Cov(G₀, G_k)\n"
                "2. Interpretación: cuánta información hay realmente\n"
                "3. Ventana de Bartlett para truncamiento\n"
                "4. Relación con el ESS\n"
                "5. Por qué ignorar la dependencia subestima el SE"
            )),
            HumanMessage(content="Explícame la varianza espectral y su importancia en inferencia.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar batch means
    # ---------------------------------------------------------------
    elif "batch means" in user_input or "lote" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre batch means...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el método de batch means para estimar la varianza de datos dependientes. "
                "Incluye:\n"
                "1. El algoritmo de batch means\n"
                "2. Por qué funciona para datos Markovianos\n"
                "3. Cómo elegir el tamaño de lote\n"
                "4. Convergencia al aumentar el tamaño de lote\n"
                "5. Comparación con otras técnicas (batch means vs block bootstrap)"
            )),
            HumanMessage(content="Explícame el método de batch means para datos dependientes.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Explicar block bootstrap
    # ---------------------------------------------------------------
    elif "bootstrap" in user_input:
        await cl.Message(content="📚 Consultando al LLM sobre block bootstrap...").send()

        response = await llm.ainvoke([
            SystemMessage(content=(
                "Eres un profesor de estadística a nivel doctoral. Explica en español "
                "el block bootstrap para datos dependientes. Incluye:\n"
                "1. Por qué el bootstrap iid falla con dependencia\n"
                "2. Cómo el block bootstrap preserva la estructura temporal\n"
                "3. Cómo elegir el tamaño de bloque\n"
                "4. Block bootstrap vs stationary bootstrap\n"
                "5. Aplicación a intervalos de confianza para V^π"
            )),
            HumanMessage(content="Explícame el block bootstrap para datos dependientes.")
        ])

        await cl.Message(content=response.content).send()

    # ---------------------------------------------------------------
    # Análisis de potencia
    # ---------------------------------------------------------------
    elif "potencia" in user_input or "power" in user_input:
        await cl.Message(content="📊 Mostrando análisis de potencia...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            power = result.get("power_analysis", {})
            if power.get("results"):
                lines = [
                    "## 📊 Análisis de Potencia\n",
                    f"**α** = {power['alpha']}, **Potencia objetivo** = {power['desired_power']}",
                    f"**σ²_∞** = {power['sigma2_infinity']:.4f}",
                    f"**n actual** = {power['current_n']}\n",
                    "| δ (efecto) | n_min | Ratio a n actual |",
                    "|-------------|-------|------------------|",
                ]
                for r in power["results"]:
                    lines.append(
                        f"| {r['delta']:.2f} | {r['n_required']} | {r['ratio_to_current']:.1f}x |"
                    )

                lines.append(f"\n> {power.get('interpretation', '')}")
                await cl.Message(content="\n".join(lines)).send()
            else:
                await cl.Message(content="Ejecuta primero el pipeline completo.").send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Diseño experimental
    # ---------------------------------------------------------------
    elif "diseño" in user_input or "diseño" in user_input or "experiment" in user_input:
        await cl.Message(content="📐 Calculando diseño experimental...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            mixing = result.get("mixing_diagnostics", {})
            power = result.get("power_analysis", {})

            lines = [
                "## 📐 Diseño Experimental Recomendado\n",
                f"| Parámetro | Valor |",
                f"|-----------|-------|",
                f"| n actual | {result.get('n_trajectories', 'N/A')} |",
                f"| ESS | {mixing.get('effective_sample_size', 'N/A')} |",
                f"| τ_int | {mixing.get('tau_integrated', 'N/A')} |",
                f"| σ²_∞ | {power.get('sigma2_infinity', 'N/A')} |",
                f"| n_min (δ=0.2, 80% potencia) | {power.get('results', [{}])[-1].get('n_required', 'N/A') if power.get('results') else 'N/A'} |",
            ]

            lines.extend([
                "\n### Recomendaciones\n",
                "1. Verificar condiciones de mezcla antes de aplicar TCL",
                "2. Usar batch means con tamaño de lote > τ_int",
                "3. Reportar ESS en adición a n",
                "4. Ajustar tamaño muestral por factor de inflación",
            ])

            await cl.Message(content="\n".join(lines)).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Diagnósticos de mezcla
    # ---------------------------------------------------------------
    elif "mezcla" in user_input or "mixing" in user_input or "autocorrel" in user_input:
        await cl.Message(content="📊 Mostrando diagnósticos de mezcla...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            mixing = result.get("mixing_diagnostics", {})
            temporal = result.get("temporal_dependence", {})

            lines = [
                "## 📊 Diagnósticos de Mezcla\n",
                f"- **Mezcla adecuada**: {'✅ Sí' if mixing.get('is_mixed') else '⚠️ Dudosa'}",
                f"- **τ_int** = {mixing.get('tau_integrated', 'N/A'):.2f}",
                f"- **ESS** = {mixing.get('effective_sample_size', 'N/A'):.1f} "
                f"(de {mixing.get('raw_sample_size', 'N/A')})",
                f"- **Factor de inflación SE** = {temporal.get('inflation_ratio', 'N/A'):.2f}x",
            ]

            acfs = mixing.get("autocorrelations", [])
            if acfs:
                lines.extend([
                    "\n#### Autocorrelación de Retornos\n",
                    "| Lag | ρ(k) |",
                    "|-----|------|",
                ])
                for a in acfs[:15]:
                    bar = "█" * int(abs(a["acf"]) * 20)
                    sign = "+" if a["acf"] >= 0 else "-"
                    lines.append(f"| {a['lag']:>2} | {a['acf']:>7.4f} {bar} |")

            lines.append(f"\n> {mixing.get('interpretation', '')}")
            await cl.Message(content="\n".join(lines)).send()

        except Exception as e:
            await cl.Message(content=f"❌ Error: {str(e)}").send()

    # ---------------------------------------------------------------
    # Comparar ICs
    # ---------------------------------------------------------------
    elif "comparar" in user_input or "intervalo" in user_input or "ic" in user_input:
        await cl.Message(content="📊 Comparando intervalos de confianza...").send()

        try:
            result = graph.invoke(current_state)
            cl.user_session.set("state", result)

            asymp = result.get("asymptotic_ci", {})
            boot = result.get("bootstrap_ci", {})

            lines = [
                "## 📊 Comparación de Intervalos de Confianza\n",
                "| Método | Límite Inf. | Límite Sup. | Ancho | Cubre V* |",
                "|--------|-------------|-------------|-------|----------|",
            ]
            if asymp:
                lines.append(
                    f"| Asintótico | {asymp.get('lower', 0):.4f} | {asymp.get('upper', 0):.4f} | "
                    f"{asymp.get('width', 0):.4f} | {'✅' if asymp.get('covers_true') else '❌'} |"
                )
            if boot:
                lines.append(
                    f"| Block Bootstrap | {boot.get('lower', 0):.4f} | {boot.get('upper', 0):.4f} | "
                    f"{boot.get('width', 0):.4f} | {'✅' if boot.get('covers_true') else '❌'} |"
                )

            lines.extend([
                "\n### Interpretación\n",
                "- El IC asintótico asume normalidad (TCL para cadenas de Markov)",
                "- El IC bootstrap es no paramétrico (más robusto)",
                "- Ambos deben cubrir V* en ~95% de las repeticiones",
                f"- V* verdadero = {result.get('true_value', 0):.4f}",
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
                "inferencia estadística para aprendizaje por refuerzo. "
                "Responde en español con rigor académico. "
                "Usa notación matemática cuando sea apropiado. "
                "Temas relevantes: SAVE, TCL para cadenas de Markov, "
                "varianza espectral, batch means, block bootstrap, ESS, "
                "mixing conditions. "
                "Referencias: Shi et al. (2022) JRSSB, Kallus & Uehara (2020/2022)."
            )),
            HumanMessage(content=message.content)
        ])

        await cl.Message(content=response.content).send()
