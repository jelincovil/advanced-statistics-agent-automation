"""Tests del contrato del certificado (ficha de justificación)."""
import pytest

from agente_stats.certificates import Certificate, Condition, default_certificate


def cond(name, status):
    return Condition(name=name, statement="x", status=status)


def mkcert(conditions, level):
    """Construye sin validar (para probar la lógica de eslabón más débil)."""
    return Certificate("J(e)", "iid", "episode",
                       conditions=conditions, conclusion_level=level)


def test_open_caps_interval_at_region():
    c = mkcert([cond("id", "design"), cond("overlap", "open")], "interval")
    assert c.discharged_level() == "region"


def test_diagnostic_caps_at_descriptive():
    c = mkcert([cond("id", "design"), cond("variance", "diagnostic")], "guarantee")
    assert c.discharged_level() == "descriptive"


def test_all_design_keeps_declared_level():
    c = default_certificate("J(e)", "iid rounds", "episode",
                            [cond("id", "design"), cond("overlap", "design")],
                            conclusion_level="interval")
    assert c.discharged_level() == "interval"


def test_inconsistent_conclusion_rejected_with_reason():
    with pytest.raises(ValueError) as e:
        default_certificate("J(e)", "iid", "episode",
                            [cond("overlap", "open")],
                            conclusion_level="guarantee")
    msg = str(e.value)
    assert "supera" in msg and "reportable" in msg


def test_valid_creation_passes_and_renders():
    c = default_certificate("J(e)", "iid", "episode",
                            [cond("id", "design"), cond("overlap", "design")],
                            conclusion_level="interval", data_ref="examples/obd.jsonl")
    md = c.to_markdown()
    for needle in ("Estimando", "Régimen muestral", "Unidad", "Conclusión"):
        assert needle in md


def test_equality_of_levels_is_allowed():
    # open + region: declarar región está exactamente en el techo permitido
    default_certificate("J(e)", "iid", "episode", [cond("overlap", "open")],
                        conclusion_level="region")
