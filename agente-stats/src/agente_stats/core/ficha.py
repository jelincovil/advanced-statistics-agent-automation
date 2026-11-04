"""Ficha de justificación automática (Fase 2).

Traduce un `OpeResult` a un `Certificate` por la regla del eslabón más
débil. El estimando es obligatorio: sin él, la ficha se RECHAZA con un
error accionable — no se firma un markdown bonito con el warning debajo.
"""
from __future__ import annotations

from dataclasses import dataclass

from agente_stats.certificates import Certificate, Condition
from .ope import OpeResult

DEFAULT_CONDS = (
    ("identificacion", "A1–A3 de la OPE: consistencia, intercambiabilidad secuencial, Markov"),
    ("overlap", "soporte de la política objetivo en la de comportamiento"),
    ("propensions_recorded", "propensión registrada por diseño en los logs"),
    ("variance", "segundos momentos finitos de la contribución"),
    ("estimator_conditions", "condiciones del estimador (tasas, modelos auxiliares)"),
)


@dataclass
class FichaResult:
    certificate: Certificate
    markdown: str


def _status_of(name: str, result: OpeResult, declared: dict | None) -> str:
    if declared and name in declared:
        return declared[name]
    if name == "propensions_recorded":
        return "design"  # mode='recorded' ya fue validado aguas arriba
    if name == "overlap":
        return "diagnostic"  # ESS/weights son diagnósticos, nunca certificado
    if name == "variance":
        return "diagnostic" if result.se == result.se else "open"
    return "open"


def build_ficha(estimand: str | None, result: OpeResult,
                regime: str, unit: str,
                declared_conditions: dict | None = None,
                data_ref: str | None = None) -> FichaResult:
    if not estimand or not str(estimand).strip():
        raise ValueError(
            "ficha rechazada: estimand ausente. Declara el estimando antes de "
            "pedir la ficha (ej. 'valor de la política ε-greedy v14 sobre rondas OBD').")
    conditions = [Condition(name=n, statement=st,
                            status=_status_of(n, result, declared_conditions))
                  for n, st in DEFAULT_CONDS]
    cert = Certificate(estimand=estimand, regime=regime, unit=unit,
                       conditions=conditions, conclusion_level="interval",
                       data_ref=data_ref)
    md = cert.to_markdown()
    if cert.discharged_level() == "descriptive":
        md += ("\n\n**Atención:** el nivel reportable se degrada a "
               "**descriptivo**: hay condiciones abiertas o solo diagnósticas. "
               "Declara las abiertas antes de afirmar cobertura nominal fuera "
               "de este experimento.\n")
    return FichaResult(certificate=cert, markdown=md)
