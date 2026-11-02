"""Handler de updates de estado → Chainlit UI."""

from __future__ import annotations

import chainlit as cl

STREAM_EVERY = 50  # enviar update de UI cada N observaciones


class ChainlitStreamHandler:
    """
    Recibe snapshots del estado del agente y actualiza la UI de Chainlit.
    Throttlea los updates a STREAM_EVERY pasos para no saturar el websocket.
    """

    def __init__(self, theta_true: float, live_msg: cl.Message | None = None):
        self.theta_true = theta_true
        self.live_msg = live_msg  # mensaje vivo que se actualiza in-place
        self._last_sent_count = -1

    async def on_state_update(
        self,
        count: int,
        theta_hat: float,
        kl: float | None,
    ) -> None:
        """Actualiza el mensaje vivo o envía uno nuevo cada STREAM_EVERY pasos."""
        if count == self._last_sent_count:
            return
        self._last_sent_count = count

        kl_val = kl or 0.0
        error = abs(theta_hat - self.theta_true)
        content = (
            f"📊 n={count:,} | θ̂={theta_hat:.4f} | "
            f"D_KL={kl_val:.6f} | error={error:.4f}"
        )

        if self.live_msg is not None:
            self.live_msg.content = content
            await self.live_msg.update()
        else:
            await cl.Message(content=content, author="agent_stream").send()
