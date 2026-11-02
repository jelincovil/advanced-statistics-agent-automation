"""
Cliente compartido para OpenRouter — Lab F.2 Chainlit.

Variables de entorno:
    OPENROUTER_API_KEY   (requerida)
    OPENROUTER_MODEL     (opcional, default: anthropic/claude-opus-4-5)

OpenRouter expone una API compatible con OpenAI en https://openrouter.ai/api/v1
"""

import os
from openai import AsyncOpenAI

OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
DEFAULT_MODEL = os.environ.get("OPENROUTER_MODEL", "anthropic/claude-opus-4-5")


def get_client() -> AsyncOpenAI:
    """Retorna un cliente AsyncOpenAI apuntando a OpenRouter."""
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        raise ValueError("OPENROUTER_API_KEY no configurada.")
    return AsyncOpenAI(
        base_url=OPENROUTER_BASE_URL,
        api_key=api_key,
        default_headers={
            "HTTP-Referer": "https://github.com/lab-f2-sufficient-agent",
            "X-Title": "Lab F.2 Sufficient Agent",
        },
    )


def has_api_key() -> bool:
    return bool(os.environ.get("OPENROUTER_API_KEY"))
