import os
import pathlib
import anthropic
from agent.state import AgentState

SYSTEM_PROMPT_FILE = pathlib.Path(__file__).parent.parent.parent / "prompts" / "analyst_system.md"
MODEL = "claude-sonnet-4-6"
MAX_TOKENS = 600


def _load_system_prompt() -> str:
    if SYSTEM_PROMPT_FILE.exists():
        return SYSTEM_PROMPT_FILE.read_text(encoding="utf-8")
    return "Eres un estadístico matemático experto."


def _build_user_message(state: AgentState) -> str:
    n_collected = state.get("n_collected", 0)
    gamma = state.get("gamma", 0.95)
    var_mc = state.get("var_mc", {})
    var_rb = state.get("var_rb", {})
    cramer_rao_bound = state.get("cramer_rao_bound", {})
    min_eps = state.get("min_episodes_for_target", {})
    value_hat = state.get("value_hat", {})
    value_se = state.get("value_se", {})
    violation_rate = state.get("_violation_rate", 0.0)

    mean_var_mc = sum(var_mc.values()) / len(var_mc) if var_mc else 0.0
    mean_var_rb = sum(var_rb.values()) / len(var_rb) if var_rb else 0.0
    mean_cr_bound = sum(cramer_rao_bound.values()) / len(cramer_rao_bound) if cramer_rao_bound else 0.0
    reduction_pct = (mean_var_mc - mean_var_rb) / mean_var_mc * 100 if mean_var_mc > 0 else 0.0
    ratio = mean_var_rb / mean_cr_bound if mean_cr_bound > 0 else float("inf")

    n_min_01 = min_eps.get("eps_0_1", "N/A")
    n_min_005 = min_eps.get("eps_0_05", "N/A")
    n_min_001 = min_eps.get("eps_0_01", "N/A")

    # Top 5 estados más visitados
    top5 = sorted(value_hat.items(), key=lambda x: -abs(x[1]))[:5]
    top5_lines = "\n".join(
        f"  s={s}: V̂={v:.4f} ± {value_se.get(s, 0):.4f}" for s, v in top5
    )

    return (
        f"## Experimento\n"
        f"- Entorno: FrozenLake-v1 (4x4, is_slippery=True)\n"
        f"- Episodios recolectados: {n_collected}\n"
        f"- γ = {gamma}\n\n"
        f"## Resultados del estimador MC vs Rao-Blackwell\n"
        f"- Var promedio MC: {mean_var_mc:.6f}\n"
        f"- Var promedio RB: {mean_var_rb:.6f}\n"
        f"- Reducción de varianza: {reduction_pct:.1f}%\n\n"
        f"## Cota de Cramér-Rao\n"
        f"- CR bound promedio: {mean_cr_bound:.6f}\n"
        f"- Var_RB / CR_bound (ratio, idealmente ≥ 1): {ratio:.3f}\n"
        f"- Tasa de violaciones numéricas: {violation_rate:.1%}\n\n"
        f"## Sample planning\n"
        f"- n_min para ε=0.10: {n_min_01}\n"
        f"- n_min para ε=0.05: {n_min_005}\n"
        f"- n_min para ε=0.01: {n_min_001}\n\n"
        f"## Función de valor (5 estados principales)\n"
        f"{top5_lines}\n\n"
        f"Interpreta estos resultados en 4-5 oraciones. Menciona: "
        f"(1) si la RB redujo varianza como predice el teorema, "
        f"(2) si la cota de CR se respeta, "
        f"(3) qué implica el sample planning para aplicaciones reales, "
        f"(4) limitaciones del prototipo."
    )


async def analyst_node(state: AgentState) -> AgentState:
    client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))
    system_prompt = _load_system_prompt()
    user_message = _build_user_message(state)

    # Streaming sincrónico (anthropic SDK) — acumulamos el texto completo
    analysis_text = ""
    with client.messages.stream(
        model=MODEL,
        max_tokens=MAX_TOKENS,
        system=system_prompt,
        messages=[{"role": "user", "content": user_message}],
    ) as stream:
        for text in stream.text_stream:
            analysis_text += text

    return {**state, "analysis_text": analysis_text}
