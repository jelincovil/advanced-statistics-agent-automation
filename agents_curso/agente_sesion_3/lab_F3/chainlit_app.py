import os
import shlex
from dotenv import load_dotenv

load_dotenv()

import chainlit as cl

from agent.graph import build_graph
from agent.state import AgentState
from stream_handler import StreamHandler
from plot_utils import (
    make_convergence_plot,
    make_comparison_plot,
    make_sample_planning_plot,
)

# Conceptos disponibles para /explain
EXPLAIN_CONCEPTS = {
    "rao-blackwell": (
        "Explica el Teorema de Rao-Blackwell: Var(E[T|S]) ≤ Var(T). "
        "Conecta con el experimento: cómo condicionar sobre T(X)={N(s,a,s')} mejora el estimador MC. "
        "Menciona el estadístico suficiente y la reducción de varianza empírica observada."
    ),
    "cramer-rao": (
        "Explica la Cota de Cramér-Rao: Var(θ̂) ≥ 1/(n·I(θ)). "
        "Conecta con el experimento: qué significa que var_rb ≥ CR_bound, "
        "y cómo I(θ)=1/(θ(1−θ)) para transiciones Bernoulli."
    ),
    "umvue": (
        "Explica el UMVUE de las probabilidades de transición: θ̂(s,a,s')=N(s,a,s')/N(s,a). "
        "Por qué es UMVUE según Lehmann-Scheffé: T(X) es suficiente minimal completo para el modelo Multinomial."
    ),
    "fisher": (
        "Explica la Información de Fisher I(θ)=1/(θ(1−θ)) para el modelo Bernoulli de transiciones. "
        "Qué representa: cuánta información aporta cada observación sobre θ. "
        "Cuándo I(θ) es grande vs pequeño y qué implica para la precisión."
    ),
    "sample-planning": (
        "Explica el sample planning: n_min = 1/(ε²·I(θ)). "
        "Cómo se deriva de la cota de Cramér-Rao. "
        "Qué implica para aplicaciones reales: cuántos episodios necesitas para Var(V̂) ≤ ε²."
    ),
}


def _parse_run_args(args: list[str]) -> tuple[int, float]:
    n_episodes = int(args[0]) if len(args) > 0 else 500
    gamma = float(args[1]) if len(args) > 1 else 0.95
    return n_episodes, gamma


async def _run_experiment(n_episodes: int, gamma: float) -> AgentState:
    initial_state: AgentState = {
        "n_episodes": n_episodes,
        "n_collected": 0,
        "gamma": gamma,
        "counts": {},
        "trajectories": [],
        "history": [],
        "mode": "collect",
        "stream_every": 50,
    }

    graph = build_graph()
    final_state = initial_state

    async with cl.Step(name="Recolectando episodios") as step:
        handler = StreamHandler(step, n_episodes)

        async for event in graph.astream(initial_state):
            node_name = list(event.keys())[0] if event else None
            if node_name:
                state_update = event[node_name]
                if isinstance(state_update, dict):
                    final_state = {**final_state, **state_update}
                    if node_name == "collect":
                        await handler.on_update(final_state)

    return final_state


@cl.on_chat_start
async def on_start():
    cl.user_session.set("last_state", None)
    cl.user_session.set("experiment_history", [])
    await cl.Message(
        content=(
            "**Lab F3 — Estimación Óptima en Agentes**\n\n"
            "Comandos disponibles:\n"
            "- `/run [n_episodios] [gamma]` — ejecuta el experimento (ej: `/run 500 0.95`)\n"
            "- `/compare [n]` — compara MC vs RB vs CR bound con n=100,200,500,1000\n"
            "- `/sample_plan [epsilon]` — calcula n_min para Var(V̂) ≤ ε²\n"
            "- `/explain [concepto]` — explica rao-blackwell|cramer-rao|umvue|fisher|sample-planning\n"
            "- Cualquier pregunta libre sobre los resultados\n\n"
            "Empieza con `/run 500`"
        )
    ).send()


@cl.on_message
async def on_message(message: cl.Message):
    content = message.content.strip()
    tokens = shlex.split(content)
    command = tokens[0].lower() if tokens else ""
    args = tokens[1:]

    # --- /run ---
    if command == "/run":
        n_episodes, gamma = _parse_run_args(args)
        await cl.Message(
            content=f"Iniciando experimento: **{n_episodes} episodios**, γ={gamma}"
        ).send()

        final_state = await _run_experiment(n_episodes, gamma)
        cl.user_session.set("last_state", final_state)

        # Guardar en historial de comparaciones
        history = cl.user_session.get("experiment_history", [])
        var_mc = final_state.get("var_mc", {})
        var_rb = final_state.get("var_rb", {})
        cr_bounds = final_state.get("cramer_rao_bound", {})
        history.append({
            "n_episodes": n_episodes,
            "mean_var_mc": sum(var_mc.values()) / len(var_mc) if var_mc else 0,
            "mean_var_rb": sum(var_rb.values()) / len(var_rb) if var_rb else 0,
            "mean_cr_bound": sum(cr_bounds.values()) / len(cr_bounds) if cr_bounds else 0,
        })
        cl.user_session.set("experiment_history", history)

        # Gráfica de convergencia
        hist_snaps = final_state.get("history", [])
        value_hat = final_state.get("value_hat", {})
        value_se = final_state.get("value_se", {})
        if hist_snaps:
            plot_bytes = make_convergence_plot(hist_snaps, value_hat, value_se)
            await cl.Message(
                content="**Gráfica de convergencia:**",
                elements=[cl.Image(name="convergencia.png", content=plot_bytes, display="inline")],
            ).send()

        # Análisis LLM con streaming
        analysis = final_state.get("analysis_text", "")
        if analysis:
            async with cl.Step(name="analyst") as step:
                step.output = analysis
            await cl.Message(content=f"**Análisis estadístico:**\n\n{analysis}").send()

    # --- /compare ---
    elif command == "/compare":
        ns_list = [100, 200, 500, 1000]
        gamma = float(args[0]) if args else 0.95
        await cl.Message(
            content=f"Ejecutando comparación con n ∈ {ns_list}, γ={gamma}..."
        ).send()

        results = []
        for n in ns_list:
            await cl.Message(content=f"  → n={n}...").send()
            state = await _run_experiment(n, gamma)
            var_mc = state.get("var_mc", {})
            var_rb = state.get("var_rb", {})
            cr_bounds = state.get("cramer_rao_bound", {})
            results.append({
                "n_episodes": n,
                "mean_var_mc": sum(var_mc.values()) / len(var_mc) if var_mc else 0,
                "mean_var_rb": sum(var_rb.values()) / len(var_rb) if var_rb else 0,
                "mean_cr_bound": sum(cr_bounds.values()) / len(cr_bounds) if cr_bounds else 0,
            })

        plot_bytes = make_comparison_plot(results)
        await cl.Message(
            content="**Comparación multi-run:**",
            elements=[cl.Image(name="comparacion.png", content=plot_bytes, display="inline")],
        ).send()

    # --- /sample_plan ---
    elif command == "/sample_plan":
        epsilon = float(args[0]) if args else 0.05
        last_state = cl.user_session.get("last_state")

        if last_state is None:
            await cl.Message(
                content="Primero ejecuta `/run` para tener datos del experimento."
            ).send()
            return

        fisher_info = last_state.get("fisher_info", {})
        all_fisher = list(fisher_info.values())
        mean_I = sum(all_fisher) / len(all_fisher) if all_fisher else 1.0

        n_min = int(1.0 / (epsilon ** 2 * mean_I)) + 1
        min_eps = last_state.get("min_episodes_for_target", {})

        plot_bytes = make_sample_planning_plot(mean_I, [0.1, 0.05, 0.01, epsilon])
        await cl.Message(
            content=(
                f"**Sample Planning** — para Var(V̂) ≤ ε² con ε={epsilon}:\n\n"
                f"- n_min = **{n_min:,}** episodios\n"
                f"- Basado en: I(θ̂) promedio = {mean_I:.4f}\n"
                f"- Fórmula: n_min = 1 / (ε² · Ī(θ))\n\n"
                f"Otros objetivos calculados:\n"
                + "\n".join(f"  ε={k.replace('eps_','').replace('_','.')}: n_min={v:,}" for k, v in min_eps.items())
            ),
            elements=[cl.Image(name="sample_plan.png", content=plot_bytes, display="inline")],
        ).send()

    # --- /explain ---
    elif command == "/explain":
        concept = args[0].lower() if args else "rao-blackwell"
        if concept not in EXPLAIN_CONCEPTS:
            await cl.Message(
                content=f"Concepto no reconocido. Disponibles: {', '.join(EXPLAIN_CONCEPTS)}"
            ).send()
            return

        prompt = EXPLAIN_CONCEPTS[concept]
        last_state = cl.user_session.get("last_state")
        context = ""
        if last_state:
            n = last_state.get("n_collected", 0)
            var_mc = last_state.get("var_mc", {})
            var_rb = last_state.get("var_rb", {})
            m_mc = sum(var_mc.values()) / len(var_mc) if var_mc else 0
            m_rb = sum(var_rb.values()) / len(var_rb) if var_rb else 0
            context = (
                f"\n\nDatos del experimento actual: n={n}, "
                f"var_MC_promedio={m_mc:.6f}, var_RB_promedio={m_rb:.6f}. "
                f"Usa estos números en tu explicación."
            )

        import anthropic, pathlib
        client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
        system_md = pathlib.Path(__file__).parent / "prompts" / "analyst_system.md"
        system = system_md.read_text() if system_md.exists() else ""

        response_text = ""
        with client.messages.stream(
            model="claude-sonnet-4-6",
            max_tokens=600,
            system=system,
            messages=[{"role": "user", "content": prompt + context}],
        ) as stream:
            for token in stream.text_stream:
                response_text += token

        await cl.Message(content=f"**{concept.upper()}**\n\n{response_text}").send()

    # --- Pregunta libre ---
    else:
        last_state = cl.user_session.get("last_state")
        context = ""
        if last_state:
            n = last_state.get("n_collected", 0)
            var_mc = last_state.get("var_mc", {})
            var_rb = last_state.get("var_rb", {})
            cr = last_state.get("cramer_rao_bound", {})
            m_mc = sum(var_mc.values()) / len(var_mc) if var_mc else 0
            m_rb = sum(var_rb.values()) / len(var_rb) if var_rb else 0
            m_cr = sum(cr.values()) / len(cr) if cr else 0
            context = (
                f"\n\nContexto del último experimento: "
                f"n_collected={n}, var_MC={m_mc:.6f}, var_RB={m_rb:.6f}, CR_bound={m_cr:.6f}. "
                f"Responde la pregunta usando estos datos cuando sea relevante."
            )

        import anthropic, pathlib
        client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
        system_md = pathlib.Path(__file__).parent / "prompts" / "analyst_system.md"
        system = system_md.read_text() if system_md.exists() else ""

        response_text = ""
        with client.messages.stream(
            model="claude-sonnet-4-6",
            max_tokens=800,
            system=system,
            messages=[{"role": "user", "content": content + context}],
        ) as stream:
            for token in stream.text_stream:
                response_text += token

        await cl.Message(content=response_text).send()
