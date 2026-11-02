"""
app.py — Interfaz Chainlit para el Agente AIPW DR OPE Semiparamétrica
====================================================================

Capítulo 6: Inferencia Semiparamétrica — Doubly Robust OPE

Comandos: /run, /n 500, /alpha 0.01, /sigma 0.2, /seed 123, /config

Uso:
    export OPENROUTER_API_KEY="sk-or-..."
    chainlit run app.py
"""

from __future__ import annotations

import asyncio
from typing import Dict, Any

import chainlit as cl
import numpy as np

from agent_graph import build_graph


# =============================================================================
# Estado global de la sesión
# =============================================================================

_graph = None
_config: Dict[str, Any] = {
    "n_samples": 200,
    "n_states": 2,
    "n_actions": 2,
    "reward_std": 0.1,
    "alpha": 0.05,
    "seed": 42,
}


# =============================================================================
# Eventos del ciclo de vida
# =============================================================================

@cl.on_chat_start
async def start():
    """Inicialización de la sesión de chat."""
    global _graph

    _graph = build_graph()

    welcome = (
        "# 📊 Estimación AIPW Doubly Robust para OPE\n\n"
        "**Capítulo 6: Inferencia Semiparamétrica**\n\n"
        "Compara tres estimadores para evaluar una política off-policy:\n"
        "1. **Direct Method (DM)**: V̂ = Σ P(s) Σ π_e(a|s) Q̂(s,a)\n"
        "2. **Importance Sampling (IS)**: V̂ = (1/n) Σ ρ_i R_i\n"
        "3. **Doubly Robust (DR/AIPW)**: V̂ = V̂_DM + (1/n) Σ ρ_i(R_i - Q̂)\n\n"
        "## 📋 Comandos\n\n"
        "| Comando | Descripción |\n"
        "|---------|-------------|\n"
        "| `/run` | Ejecutar experimento |\n"
        "| `/n 500` | Número de muestras |\n"
        "| `/alpha 0.01` | Nivel de significancia |\n"
        "| `/sigma 0.2` | Desviación de recompensas |\n"
        "| `/seed 123` | Semilla |\n"
        "| `/config` | Configuración actual |\n\n"
        "## 📚 Referencias\n\n"
        "- Bickel et al. (1993) *Efficient and Adaptive Estimation for Semiparametric Models*\n"
        "- Kennedy (2016) *Semiparametric Theory and Empirical Processes in Causal Inference*\n"
        "- Kallus & Uehara (2020) *Double/Debiased ML for Dynamic Treatment Regimes*\n"
        "- Robins, Rotnitzky & Zhao (1994) *Estimation of Regression Coefficients*\n\n"
        "---\n\n"
        f"**Config:** n={_config['n_samples']}, σ={_config['reward_std']}, "
        f"α={_config['alpha']}\n\n"
        "Escriba **`/run`** para ejecutar."
    )

    await cl.Message(content=welcome).send()


@cl.on_message
async def main(message: cl.Message):
    """Manejador principal de mensajes."""
    inp = message.content.strip()

    if inp == "/run":
        await execute_experiment()

    elif inp.startswith("/n "):
        try:
            n = int(inp.split()[1])
            _config["n_samples"] = max(50, min(10000, n))
            await cl.Message(content=f"✅ Muestras = **{_config['n_samples']}**").send()
        except (IndexError, ValueError):
            await cl.Message(content="❌ Use `/n 500` (50-10000).").send()

    elif inp.startswith("/alpha "):
        try:
            a = float(inp.split()[1])
            _config["alpha"] = max(0.001, min(0.20, a))
            await cl.Message(content=f"✅ α = **{_config['alpha']}**").send()
        except (IndexError, ValueError):
            await cl.Message(content="❌ Use `/alpha 0.05`").send()

    elif inp.startswith("/sigma "):
        try:
            s = float(inp.split()[1])
            _config["reward_std"] = max(0.01, min(5.0, s))
            await cl.Message(content=f"✅ σ = **{_config['reward_std']}**").send()
        except (IndexError, ValueError):
            await cl.Message(content="❌ Use `/sigma 0.2`").send()

    elif inp.startswith("/seed "):
        try:
            s = int(inp.split()[1])
            _config["seed"] = s
            await cl.Message(content=f"✅ Semilla = **{_config['seed']}**").send()
        except (IndexError, ValueError):
            await cl.Message(content="❌ Use `/seed 42`").send()

    elif inp == "/config":
        await show_config()

    else:
        await cl.Message(
            content=f"❓ `{inp}` no reconocido. "
            "Comandos: `/run`, `/n`, `/alpha`, `/sigma`, `/seed`, `/config`"
        ).send()


# =============================================================================
# Funciones de ejecución
# =============================================================================

async def execute_experiment():
    """Ejecuta el pipeline completo y muestra resultados."""
    progress = cl.Message(content="⏳ Ejecutando estimación AIPW DR...")
    await progress.send()

    graph_config = {
        "configurable": {"use_llm": True},
        "n_samples": _config["n_samples"],
        "n_states": _config["n_states"],
        "n_actions": _config["n_actions"],
        "reward_std": _config["reward_std"],
        "alpha": _config["alpha"],
        "seed": _config["seed"],
    }

    try:
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(
            None, lambda: _graph.invoke({}, graph_config)
        )
        await progress.update(content="")

        # 1. Estimaciones
        V_true = result.get("_V_true", 0)
        ci = result["ci"]
        dm = ci["dm"]
        is_est = ci["is"]
        dr = ci["dr"]

        await cl.Message(
            content=(
                f"# 📈 Estimación Off-Policy\n\n"
                f"| Estimador | V̂ | SE | Sesgo | ¿Cubre V^π_e? |\n"
                f"|-----------|---:|---:|------:|:--------------:|\n"
                f"| DM | {dm['estimate']:.4f} | {dm['se']:.4f} | {dm['estimate']-V_true:.4f} | "
                f"{'✅' if dm['covers_true'] else '❌'} |\n"
                f"| IS | {is_est['estimate']:.4f} | {is_est['se']:.4f} | {is_est['estimate']-V_true:.4f} | "
                f"{'✅' if is_est['covers_true'] else '❌'} |\n"
                f"| **DR (AIPW)** | **{dr['estimate']:.4f}** | **{dr['se']:.4f}** | **{dr['estimate']-V_true:.4f}** | "
                f"{'✅' if dr['covers_true'] else '❌'} |\n\n"
                f"V^π_e verdadero = **{V_true:.4f}**"
            )
        ).send()

        # 2. Intervalos de confianza
        await cl.Message(
            content=(
                f"# 📐 Intervalos de Confianza al {(1-ci['alpha'])*100}%\n\n"
                f"| Estimador | Límite inf. | Límite sup. | Ancho |\n"
                f"|-----------|------------:|------------:|------:|\n"
                f"| DM | {dm['lower']:.4f} | {dm['upper']:.4f} | {dm['width']:.4f} |\n"
                f"| IS | {is_est['lower']:.4f} | {is_est['upper']:.4f} | {is_est['width']:.4f} |\n"
                f"| **DR** | **{dr['lower']:.4f}** | **{dr['upper']:.4f}** | **{dr['width']:.4f}** |"
            )
        ).send()

        # 3. Doble robustez
        robustness = result["robustness_check"]
        exp1 = robustness.get("experiment_1_corrupt_Q", {})
        exp2 = robustness.get("experiment_2_constant_Q", {})

        await cl.Message(
            content=(
                f"# 🛡️ Verificación de Doble Robustez\n\n"
                f"### Experimento 1: Corromper Q con ruido\n"
                f"| Estimador | Cambio al corromper Q |\n"
                f"|-----------|----------------------:|\n"
                f"| DM | {exp1.get('V_dm_change', 0):.6f} |\n"
                f"| DR | {exp1.get('V_dr_change', 0):.6f} |\n"
                f"| IS | 0.000000 (no depende de Q) |\n\n"
                f"DR más robusto que DM: "
                f"{'✅ **Sí**' if exp1.get('dm_is_more_sensitive') else '⚠️'}\n\n"
                f"### Experimento 2: Q constante = 0\n"
                f"- V_DR(Q=0) = {exp2.get('V_dr_with_constant_Q', 0):.6f}\n"
                f"- V_IS = {exp2.get('V_is', 0):.6f}\n"
                f"- DR ≡ IS: {'✅ **Verificado**' if exp2.get('dr_equals_is') else '❌'}\n\n"
                f"*Con Q̃=0: Ṽ_DR = 0 + (1/n)ΣρᵢRᵢ = V̂_IS*"
            )
        ).send()

        # 4. LLM
        if result.get("llm_analysis"):
            await cl.Message(
                content=f"# 🤖 Interpretación del LLM\n\n{result['llm_analysis']}\n\n"
                "---\n*GPT-4o-mini vía OpenRouter.*"
            ).send()

    except Exception as e:
        await cl.Message(content=f"❌ **Error:** `{str(e)}`").send()


async def show_config():
    """Muestra la configuración actual."""
    await cl.Message(
        content=(
            "# ⚙️ Configuración\n\n"
            "| Parámetro | Valor |\n|-----------|-------|\n"
            f"| n (muestras) | {_config['n_samples']} |\n"
            f"| Estados | {_config['n_states']} |\n"
            f"| Acciones | {_config['n_actions']} |\n"
            f"| σ (ruido) | {_config['reward_std']} |\n"
            f"| α | {_config['alpha']} |\n"
            f"| Semilla | {_config['seed']} |"
        )
    ).send()
