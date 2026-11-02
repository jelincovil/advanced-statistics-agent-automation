"""
Lab F.2 — Agente Estadístico Suficiente para Bernoulli(θ)
Chat interactivo con Chainlit + streaming LangGraph + análisis LLM.

Arrancar:
    chainlit run chainlit_app.py -w --port 8000

Comandos:
    /run [n] [theta] [agent]   — ejecutar agente (default: n=1000 theta=0.3 sufficient)
    /compare [n] [theta]       — comparar ambos agentes
    /benchmark                 — test de complejidad O(1) vs O(n²)
    /resume [session_id]       — listar o retomar sesión guardada
    <pregunta libre>           — consultar al analyst sobre el último experimento
"""

from __future__ import annotations

import asyncio
import json
import os
import uuid
from typing import Optional

import numpy as np
import chainlit as cl


# ── Parsing de comandos ────────────────────────────────────────────────────────

def _parse_run_args(content: str) -> tuple[int, float, str]:
    """'/run [n] [theta] [agent]' → (n, theta_true, agent_type)"""
    parts = content.split()[1:]
    n, theta, agent = 1000, 0.3, "sufficient"
    for p in parts:
        if p in ("sufficient", "baseline"):
            agent = p
        elif "." in p:
            try:
                theta = float(p)
            except ValueError:
                pass
        else:
            try:
                n = int(p)
            except ValueError:
                pass
    return n, theta, agent


def _parse_compare_args(content: str) -> tuple[int, float]:
    """'/compare [n] [theta]' → (n, theta_true)"""
    parts = content.split()[1:]
    n, theta = 1000, 0.3
    for p in parts:
        if "." in p:
            try:
                theta = float(p)
            except ValueError:
                pass
        else:
            try:
                n = int(p)
            except ValueError:
                pass
    return n, theta


# ── on_chat_start ──────────────────────────────────────────────────────────────

@cl.on_chat_start
async def on_chat_start() -> None:
    cl.user_session.set("last_run_state", None)
    cl.user_session.set("last_run_params", None)
    cl.user_session.set("history", [])
    cl.user_session.set("agent_type", "sufficient")

    await cl.Message(
        content=(
            "**Lab F.2 — Agente Estadístico Suficiente para Bernoulli(θ)**\n\n"
            "Compara el estadístico suficiente $T_n = (\\text{count}, \\text{total})$ "
            "frente a Welford y analiza la pérdida de información.\n\n"
            "**Comandos:**\n"
            "```\n"
            "/run [n] [theta] [agent]   — ejecutar agente con streaming\n"
            "/compare [n] [theta]       — comparar suficiente vs insuficiente\n"
            "/benchmark                 — benchmark O(1) vs O(n²)\n"
            "/resume [session_id]       — listar o retomar checkpoint guardado\n"
            "```\n"
            "O escribe cualquier **pregunta** sobre el experimento en curso.\n\n"
            "_Ejemplos: `/run 2000 0.4` · `/run 500 0.7 baseline` · "
            "`/compare 1000 0.3` · `¿Por qué converge más lento con n pequeño?`_"
        )
    ).send()


# ── handle_run ─────────────────────────────────────────────────────────────────

async def handle_run(msg: cl.Message) -> None:
    from stream_callbacks import STREAM_EVERY
    from plot_utils import make_convergence_plot, compute_history
    from checkpointer import SufficientCheckpointer

    n, theta_true, agent_type = _parse_run_args(msg.content)

    await cl.Message(
        content=f"Ejecutando **{agent_type}** | n={n:,} | θ_true={theta_true} | seed=42"
    ).send()

    rng = np.random.default_rng(42)
    obs = rng.binomial(1, theta_true, n).tolist()

    history: list = []
    final_state: dict = {}
    analysis_text: Optional[str] = None

    # ── Agente suficiente con streaming ──
    if agent_type == "sufficient":
        from analyst_node import build_sufficient_agent_with_analyst
        from sufficient_agent import SufficientState

        app = build_sufficient_agent_with_analyst()
        init_state: SufficientState = {
            "count": 0, "total": 0,
            "observations": obs, "pos": 0,
            "current_x": None, "theta_hat": 0.5,
            "kl": None, "theta_true": theta_true,
            "history": [], "n_total": n, "analysis_text": None,
        }

        stream_msg = cl.Message(content="Iniciando stream...", author="agent_stream")
        await stream_msg.send()

        # astream produce chunks {node_name: delta_dict} — acumulamos manualmente
        _count = 0
        _theta_hat = 0.5
        _kl: float = 0.0
        _pos = 0
        _total = 0

        async for chunk in app.astream(
            init_state,
            config={"recursion_limit": n * 4 + 200},
        ):
            for node_name, delta in chunk.items():
                if node_name == "update":
                    _count = delta.get("count", _count)
                    _total = delta.get("total", _total)

                elif node_name == "decide":
                    _theta_hat = delta.get("theta_hat", _theta_hat)
                    _kl = delta.get("kl") or 0.0
                    error = abs(_theta_hat - theta_true)

                    if _count % STREAM_EVERY == 0:
                        history.append({
                            "n": _count, "theta_hat": _theta_hat,
                            "kl": _kl, "error": error,
                        })
                        stream_msg.content = (
                            f"📊 n={_count:,} | θ̂={_theta_hat:.4f} | "
                            f"D_KL={_kl:.6f} | error={error:.4f}"
                        )
                        await stream_msg.update()

                elif node_name == "analyst":
                    at = delta.get("analysis_text")
                    if at and not analysis_text:
                        analysis_text = at

        final_state = {
            "count": _count, "total": _total,
            "theta_hat": _theta_hat, "kl": _kl,
            "theta_true": theta_true, "analysis_text": analysis_text,
        }

    # ── Agente baseline (sin streaming) ──
    else:
        from baseline_agent import run_baseline

        stream_msg = cl.Message(content="Ejecutando baseline (Welford)...", author="agent_stream")
        await stream_msg.send()

        loop = asyncio.get_event_loop()
        final_state = await loop.run_in_executor(None, run_baseline, obs, theta_true)
        history = compute_history(obs, theta_true, "baseline", STREAM_EVERY)

        theta_hat = final_state["theta_hat"]
        kl = final_state.get("kl") or 0.0
        error = abs(theta_hat - theta_true)
        stream_msg.content = (
            f"📊 n={n:,} | θ̂={theta_hat:.4f} | D_KL={kl:.6f} | error={error:.4f}"
        )
        await stream_msg.update()

    # ── Resumen final ──
    theta_hat = final_state.get("theta_hat", 0.5)
    kl_final = final_state.get("kl") or 0.0
    error_final = abs(theta_hat - theta_true)

    count_final = final_state.get("count") or final_state.get("n") or n
    total_final = final_state.get("total")
    extra = f"- Σxᵢ (total) = {total_final}\n" if total_final is not None else ""

    await cl.Message(
        content=(
            f"**Resultados — {agent_type}**\n"
            f"- n = {count_final:,}\n"
            f"{extra}"
            f"- θ_true = {theta_true}\n"
            f"- θ̂ = {theta_hat:.6f}\n"
            f"- |θ̂ − θ| = {error_final:.6f}\n"
            f"- D_KL = {kl_final:.8f}\n"
        )
    ).send()

    # ── Gráfica de convergencia ──
    if history:
        img_bytes = make_convergence_plot(history, theta_true, agent_type)
        if img_bytes:
            await cl.Image(
                name="convergence", display="inline", content=img_bytes
            ).send()

    # ── Análisis del nodo LLM (solo sufficient) ──
    if analysis_text:
        await cl.Message(
            content=f"**Análisis estadístico**\n\n{analysis_text}",
            author="analyst",
        ).send()

    # ── Guardar en sesión y checkpoint ──
    session_state = {
        "count": count_final,
        "total": final_state.get("total"),
        "theta_hat": theta_hat,
        "kl": kl_final,
        "theta_true": theta_true,
        "agent_type": agent_type,
    }
    cl.user_session.set("last_run_state", session_state)
    cl.user_session.set("last_run_params", {"n": n, "theta_true": theta_true, "agent": agent_type})
    cl.user_session.set("history", history)
    cl.user_session.set("agent_type", agent_type)

    if agent_type == "sufficient" and final_state.get("count"):
        session_id = str(uuid.uuid4())[:8]
        cp = SufficientCheckpointer()
        cp.save(session_id, final_state)
        await cl.Message(
            content=(
                f"Sesión guardada como `{session_id}`. "
                f"Usa `/resume {session_id}` para retomar desde n={count_final:,}."
            )
        ).send()


# ── handle_compare ─────────────────────────────────────────────────────────────

async def handle_compare(msg: cl.Message) -> None:
    from plot_utils import compute_history, make_compare_plot
    from stream_callbacks import STREAM_EVERY
    from sufficient_agent import run_agent
    from baseline_agent import run_baseline

    n, theta_true = _parse_compare_args(msg.content)

    await cl.Message(
        content=f"Comparando ambos agentes | n={n:,} | θ_true={theta_true}..."
    ).send()

    rng = np.random.default_rng(42)
    obs = rng.binomial(1, theta_true, n).tolist()

    loop = asyncio.get_event_loop()
    result_suf, result_bas = await asyncio.gather(
        loop.run_in_executor(None, run_agent, obs, theta_true),
        loop.run_in_executor(None, run_baseline, obs, theta_true),
    )

    history_suf = compute_history(obs, theta_true, "sufficient", STREAM_EVERY)
    history_bas = compute_history(obs, theta_true, "baseline", STREAM_EVERY)

    kl_suf = result_suf.get("kl") or 0.0
    kl_bas = result_bas.get("kl") or 0.0
    delta_kl = kl_bas - kl_suf
    th_suf = result_suf["theta_hat"]
    th_bas = result_bas["theta_hat"]

    direction = (
        "insuficiente PEOR" if delta_kl > 1e-12
        else "prácticamente idéntico" if abs(delta_kl) < 1e-12
        else "artefacto numérico — revisar semilla"
    )

    await cl.Message(
        content=(
            f"**Comparación | n={n:,} | θ_true={theta_true}**\n\n"
            f"| Métrica | Suficiente | Insuficiente |\n"
            f"|---------|-----------|---------------|\n"
            f"| θ̂ | {th_suf:.6f} | {th_bas:.6f} |\n"
            f"| D_KL | {kl_suf:.8f} | {kl_bas:.8f} |\n"
            f"| ΔD_KL (ins−suf) | {delta_kl:+.3e} | — |\n\n"
            f"_{direction}_"
        )
    ).send()

    img_bytes = make_compare_plot(history_suf, history_bas, theta_true)
    if img_bytes:
        await cl.Image(name="compare", display="inline", content=img_bytes).send()


# ── handle_benchmark ───────────────────────────────────────────────────────────

async def handle_benchmark(msg: cl.Message) -> None:
    from experiments import run_benchmark

    await cl.Message(
        content="Ejecutando benchmark O(1) vs O(n²) para n ∈ {100, 1 000, 10 000}..."
    ).send()

    loop = asyncio.get_event_loop()
    results = await loop.run_in_executor(
        None, run_benchmark, [100, 1000, 10000], 0.3, 42, False
    )

    rows = [
        "| n | t_suf (s) | t_full (s) | speedup |",
        "|---|-----------|------------|---------|",
    ]
    for r in results:
        rows.append(
            f"| {r.n:,} | {r.t_suf:.6f} | {r.t_full:.4f} | {r.speedup:.1f}× |"
        )

    await cl.Message(
        content="**Benchmark de Complejidad: O(n) vs O(n²)**\n\n" + "\n".join(rows)
    ).send()


# ── handle_resume ──────────────────────────────────────────────────────────────

async def handle_resume(msg: cl.Message) -> None:
    from checkpointer import SufficientCheckpointer

    cp = SufficientCheckpointer()
    parts = msg.content.split()

    if len(parts) == 1:
        sessions = cp.list_sessions()
        if not sessions:
            await cl.Message(
                content="No hay sesiones guardadas. Ejecuta `/run` primero."
            ).send()
            return
        lines = ["**Sesiones guardadas:**\n"]
        for s in sessions:
            lines.append(
                f"- `{s['session_id']}` — n={s['count']:,}, "
                f"θ_true={s['theta_true']}, guardada: {s['created_at']}"
            )
        lines.append("\nUsa `/resume <session_id>` para retomar.")
        await cl.Message(content="\n".join(lines)).send()
        return

    session_id = parts[1]
    saved = cp.load(session_id)
    if not saved:
        await cl.Message(content=f"Sesión `{session_id}` no encontrada.").send()
        return

    count = saved["count"]
    total = saved["total"]
    theta_true = saved["theta_true"]
    theta_hat = saved["theta_hat"]

    await cl.Message(
        content=(
            f"**Sesión `{session_id}` restaurada**\n"
            f"- n (count) = {count:,}\n"
            f"- Σxᵢ (total) = {total}\n"
            f"- θ̂ = {theta_hat:.6f}\n"
            f"- θ_true = {theta_true}\n\n"
            "_Esta es la ventaja del estadístico suficiente: sólo 2 enteros "
            f"(count={count}, total={total}) bastan para reanudar completamente el estimador, "
            "sin necesidad de guardar toda la historia de observaciones._"
        )
    ).send()

    cl.user_session.set("last_run_state", saved)
    cl.user_session.set("last_run_params", {
        "n": count, "theta_true": theta_true, "agent": "sufficient"
    })


# ── handle_free_question ───────────────────────────────────────────────────────

async def handle_free_question(msg: cl.Message) -> None:
    from llm_client import get_client, has_api_key, DEFAULT_MODEL

    if not has_api_key():
        await cl.Message(
            content=(
                "⚠️ `OPENROUTER_API_KEY` no configurada. "
                "No puedo responder preguntas libres sin acceso al LLM."
            )
        ).send()
        return

    last_state = cl.user_session.get("last_run_state")
    if not last_state:
        await cl.Message(
            content="Ejecuta primero un experimento con `/run` para tener contexto."
        ).send()
        return

    context_block = json.dumps(last_state, indent=2, ensure_ascii=False)
    system_prompt = (
        "Eres un asistente estadístico experto en teoría de la estimación y suficiencia. "
        "Tienes acceso al estado del último experimento ejecutado. "
        "Responde con precisión matemática pero de forma accesible. "
        "Responde en español."
    )
    user_content = (
        f"ESTADO DEL EXPERIMENTO:\n```json\n{context_block}\n```\n\n"
        f"Pregunta: {msg.content}"
    )

    client = get_client()
    response_msg = cl.Message(content="", author="analyst")
    await response_msg.send()

    stream = await client.chat.completions.create(
        model=DEFAULT_MODEL,
        max_tokens=500,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content},
        ],
        stream=True,
    )
    async for chunk in stream:
        delta = chunk.choices[0].delta.content
        if delta:
            await response_msg.stream_token(delta)

    await response_msg.update()


# ── on_message ─────────────────────────────────────────────────────────────────

@cl.on_message
async def on_message(msg: cl.Message) -> None:
    content = msg.content.strip()
    if content.startswith("/run"):
        await handle_run(msg)
    elif content.startswith("/compare"):
        await handle_compare(msg)
    elif content.startswith("/benchmark"):
        await handle_benchmark(msg)
    elif content.startswith("/resume"):
        await handle_resume(msg)
    else:
        await handle_free_question(msg)
