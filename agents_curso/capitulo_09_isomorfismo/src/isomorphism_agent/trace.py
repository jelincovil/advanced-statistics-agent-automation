"""
Trazabilidad — Tabla Teorema → Componente → Garantía (Tabla 9.2 del libro).

Cada ejecución del agente genera un `TraceLog` que asocia, para cada
resultado teórico invocado, el componente del agente responsable y la
garantía resultante. Esto materializa la auditoría científica: cada IC,
cada test, cada decisión puede rastrearse al teorema del Cap.~9 que lo
respalda.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any
import json
import time


@dataclass
class TraceEntry:
    theorem: str        # ej. "Thm 9.1"
    component: str      # ej. "isomorphism_node"
    guarantee: str      # ej. "Formal"
    value: Any = None
    timestamp: float = field(default_factory=time.time)
    notes: str = ""

    def as_dict(self) -> dict:
        return {"theorem": self.theorem, "component": self.component,
                "guarantee": self.guarantee, "value": self.value,
                "timestamp": self.timestamp, "notes": self.notes}


class TraceLog:
    """Log estructurado de trazabilidad teorema→componente→garantía."""

    # Plantilla por defecto: la Tabla 9.2 del libro
    DEFAULT_TABLE = [
        ("Thm 9.1",  "isomorphism_node",  "Formal",              "δ* == π* under F"),
        ("Thm 9.5",  "state_node",        "Información completa","StateSchema ≅ T(X)"),
        ("Thm 9.7",  "transfer_node",     "Cobertura",           "IC V^π via delta-method"),
        ("Thm 9.8",  "test_node",         "Control de error",    "UMP ↔ política test"),
        ("Thm 9.9",  "decision_node",     "Optimalidad",         "R(θ,δ) ↔ -V^π(s)"),
        ("Thm 9.11", "decision_node",     "Eficiencia",          "Admisibilidad ↔ Pareto"),
        ("Thm 9.13", "verify_node",       "Condicional",         "Mixing+Overlap+Nuisance+Moments"),
        ("Prop 9.14","verify_node",       "Protocolo",           "Verificación antes de garantizar"),
        ("Cor 9.6",  "mdp_node",          "Recursivo",           "Bellman ↔ riesgo recursivo"),
        ("Thm 10.x", "ope_node",          "DR semiparamétrico",  "DM/IS/DR + clipping adaptativo"),
    ]

    def __init__(self):
        self.entries: list[TraceEntry] = []
        self._start = time.time()

    def log(self, theorem: str, component: str, guarantee: str,
            value: Any = None, notes: str = "") -> None:
        self.entries.append(TraceEntry(theorem=theorem, component=component,
                                       guarantee=guarantee, value=value,
                                       notes=notes))

    def to_dataframe(self):
        import pandas as pd
        return pd.DataFrame([e.as_dict() for e in self.entries])

    def to_json(self, path: str | None = None) -> str:
        out = json.dumps([e.as_dict() for e in self.entries], indent=2,
                         default=str)
        if path:
            with open(path, "w") as f:
                f.write(out)
        return out

    def summary_table(self) -> str:
        """Devuelve una tabla ASCII teorema→componente→garantía."""
        rows = ["Theorem     | Component            | Guarantee          | Value",
                "-----------|----------------------|--------------------|--------"]
        for e in self.entries:
            rows.append(f"{e.theorem:11s}| {e.component:21s}| "
                        f"{e.guarantee:19s}| {str(e.value)[:30]}")
        return "\n".join(rows)

    def coverage_report(self) -> dict:
        """Reporta qué teoremas del Cap. 9 fueron invocados en esta ejecución."""
        invoked = {e.theorem for e in self.entries}
        all_theorems = {row[0] for row in self.DEFAULT_TABLE}
        return {
            "invoked": sorted(invoked),
            "missing": sorted(all_theorems - invoked),
            "coverage_pct": 100 * len(invoked & all_theorems) / len(all_theorems),
            "elapsed_s": time.time() - self._start,
        }
