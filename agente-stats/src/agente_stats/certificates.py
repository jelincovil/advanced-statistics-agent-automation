"""Certificado de justificación (contrato congelado, Fase 0).

La ficha es un objeto CON reglas, no una plantilla de texto:
- `Condition` tiene nombre, enunciado formal y estado ∈
  {"design", "proved", "diagnostic", "open"}.
- `conclusion_level` ∈ {"guarantee", "interval", "region", "descriptive"}.
- La regla de reportabilidad (del cap. 6 del libro / V2): la conclusión no
  puede superar el eslabón más débil de sus condiciones. Eso se calcula con
  `discharged_level()`, no con opiniones.

La librería la cumplimenta automáticamente; la capa MCP solo la formatea.
"""
from __future__ import annotations

from dataclasses import dataclass, field

STATUSES = ("design", "proved", "diagnostic", "open")
LEVELS = ("guarantee", "interval", "region", "descriptive")
_ORDER = {"design": 0, "proved": 1, "diagnostic": 2, "open": 3}


@dataclass
class Condition:
    name: str
    statement: str
    status: str

    def __post_init__(self):
        if self.status not in STATUSES:
            raise ValueError(f"status debe ser uno de {STATUSES}")


@dataclass
class Certificate:
    estimand: str
    regime: str
    unit: str
    conditions: list[Condition] = field(default_factory=list)
    data_ref: str | None = None
    conclusion_level: str = "descriptive"

    def weakest_status(self) -> str | None:
        if not self.conditions:
            return None
        return max((c.status for c in self.conditions), key=_ORDER.get)

    def discharged_level(self) -> str:
        """Nivel reportable según el eslabón más débil (regla V2).
        Fuerza de niveles: guarantee(0) > interval(1) > region(2) > descriptive(3)."""
        w = self.weakest_status()
        if w is None:
            return "descriptive"
        if w in ("design", "proved"):
            return self.conclusion_level
        if w == "diagnostic":
            return "descriptive"
        # open: queda como mucho una región de identificación
        return "region" if self.conclusion_level == "guarantee" else "region"

    def assert_consistent(self) -> None:
        d = self.discharged_level()
        idx = LEVELS.index
        if idx(self.conclusion_level) < idx(d):
            raise ValueError(
                f"conclusion_level={self.conclusion_level!r} supera lo que permiten las "
                f"condiciones (reportable={d!r}; eslabón más débil={self.weakest_status()!r}). "
                "Degrada la conclusión o descarga la condición abierta/diagnóstica.")

    def to_markdown(self) -> str:
        lines = [
            "# Ficha de justificación",
            "",
            f"**Estimando:** {self.estimand}",
            f"**Régimen muestral:** {self.regime}",
            f"**Unidad independiente:** {self.unit}",
            f"**Datos:** {self.data_ref or '—'}",
            "",
            "| Condición | Estado | Enunciado |",
            "|---|---|---|",
        ]
        for c in self.conditions:
            lines.append(f"| {c.name} | {c.status} | {c.statement} |")
        lines += [
            "",
            f"**Conclusión (nivel declarado):** {self.conclusion_level}",
            f"**Nivel reportable según el eslabón más débil:** {self.discharged_level()}",
        ]
        return "\n".join(lines)


def default_certificate(estimand: str, regime: str, unit: str,
                        conditions: list[Condition] | None = None,
                        conclusion_level: str = "interval",
                        data_ref: str | None = None) -> Certificate:
    cert = Certificate(estimand=estimand, regime=regime, unit=unit,
                       conditions=conditions or [], conclusion_level=conclusion_level,
                       data_ref=data_ref)
    cert.assert_consistent()
    return cert
