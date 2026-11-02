import chainlit as cl


class StreamHandler:
    def __init__(self, step: cl.Step, total: int):
        self.step = step
        self.total = total

    async def on_update(self, state: dict) -> None:
        n = state.get("n_collected", 0)
        counts: dict = state.get("counts", {})
        unique_states = len({s for (s, a, sp) in counts})
        unique_transitions = len(counts)

        self.step.output = (
            f"Episodio {n}/{self.total} | "
            f"estados visitados: {unique_states} | "
            f"transiciones únicas: {unique_transitions}"
        )
        await self.step.update()
