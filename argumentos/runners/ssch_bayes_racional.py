#!/usr/bin/env python3
"""Runner SSCH del piloto — enumeración racional exacta (docs/05_EVIDENCIA.md).

Modelo SSCH del capítulo 5 (cap05_incrustacion.typ:262):
  P0(X=1) = 1/5, P1(X=1) = 4/5;
  L(0,0)=0, L(0,1)=1, L(1,0)=4, L(1,1)=0;
  prior ν(1) = 3/10.
Regla «seguir la señal»: δ(x) = x.
Riesgos por enumeración racional exacta (fractions.Fraction):
  R(0, δ) = 1/5, R(1, δ) = 4/5, riesgo de Bayes = 19/50.

Criterio preregistrado (se fija ANTES de la ejecución, docs/05):
  bayes_riesgo == 19/50 exacto (racional, no float).
Este ejemplo es sintético y exacto, no evidencia clínica.
"""
from fractions import Fraction as F
import json
import sys

# --- Especificación del experimento (inmutable dentro de la corrida) ---
PRIOR = {0: F(7, 10), 1: F(3, 10)}          # ν(1) = 3/10
SEÑAL = {0: {0: F(4, 5), 1: F(1, 5)},        # P0(X=0)=4/5, P0(X=1)=1/5
         1: {0: F(1, 5), 1: F(4, 5)}}        # P1(X=0)=1/5, P1(X=1)=4/5
PÉRDIDA = {0: {0: F(0), 1: F(1)},            # L(0,·)
           1: {0: F(4), 1: F(0)}}            # L(1,·)
REGLA = "seguir_la_señal"                     # δ(x) = x

CRITERIO_BAYES = F(19, 50)


def riesgo(θ: int, regla) -> F:
    """R(θ, δ) = Σ_x P_θ(x) · L(θ, δ(x)) por enumeración exacta."""
    total = F(0)
    for x in (0, 1):
        a = regla(x)
        total += SEÑAL[θ][x] * PÉRDIDA[θ][a]
    return total


def fraccion_str(f: F) -> str:
    return f"{f.numerator}/{f.denominator}"


def main() -> int:
    regla = (lambda x: x) if REGLA == "seguir_la_señal" else None
    assert regla is not None, "regla no implementada"

    r0 = riesgo(0, regla)
    r1 = riesgo(1, regla)
    bayes = PRIOR[0] * r0 + PRIOR[1] * r1

    criterio = bayes == CRITERIO_BAYES
    resultado = {
        "experimento": "ssch_enumeracion_racional",
        "regla": REGLA,
        "riesgos": {"R0": fraccion_str(r0), "R1": fraccion_str(r1)},
        "riesgo_bayes": fraccion_str(bayes),
        "criterio": {
            "id": "bayes_riesgo_19_50",
            "esperado": fraccion_str(CRITERIO_BAYES),
            "observado": fraccion_str(bayes),
            "status": "pass" if criterio else "fail",
        },
        "nota": "sintético y exacto; no evidencia clínica (docs/05)",
    }
    print(json.dumps(resultado, ensure_ascii=False, indent=1))
    return 0 if criterio else 1


if __name__ == "__main__":
    sys.exit(main())
