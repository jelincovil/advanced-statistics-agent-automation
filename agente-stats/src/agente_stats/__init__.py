"""agente-stats: core estadístico del proyecto MCP del libro (sin dependencias de MCP)."""
from .certificates import Certificate, Condition, default_certificate
from .core.compare import VersionComparison, compare_versions
from .core.ficha import FichaResult, build_ficha
from .core.ope import OpeResult, estimate_dr, estimate_is
from .schemas import SchemaError, load_jsonl, summarize, validate_episode

__all__ = [
    "Certificate", "Condition", "default_certificate",
    "VersionComparison", "compare_versions", "FichaResult", "build_ficha",
    "OpeResult", "estimate_dr", "estimate_is",
    "SchemaError", "load_jsonl", "summarize", "validate_episode",
]
__version__ = "0.1.0"
