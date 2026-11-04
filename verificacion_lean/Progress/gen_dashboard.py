#!/usr/bin/env python3
"""Genera Progress/DASHBOARD.md desde los comentarios `book:` de Book/*.lean
y la auditoria build/axioms.log (producida por ./verificar.sh).
Convencion del plan §3: el dashboard se genera, no se edita a mano."""
import datetime
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOG = ROOT / "build" / "axioms.log"

# Filas del inventario del plan §2 ya completadas, por fase: lista de claves
# que las cubren. Cada clave debe aparecer en la tabla generada (se verifica).
COMPLETADAS = {
    "P1": ["thm:ch9-isomorfismo", "cor:ch9-bayes", "thm:ch9-admisibilidad",
           "cor:ch7-traduccion"],
    "P2": [],
    "P3": [],
}
INVENTARIO = {"P1": 14, "P2": 13, "P3": 8}  # filas del plan §2
LIMPIO = "propext, Classical.choice, Quot.sound"


def main() -> int:
    if not LOG.exists():
        print("FALLO: build/axioms.log no existe — corre ./verificar.sh primero.",
              file=sys.stderr)
        return 1
    axioms = dict(re.findall(r"^'(\w+)' depends on axioms: \[(.*)\]$",
                             LOG.read_text(encoding="utf-8"), re.M))
    rows, claves = [], set()
    for src in sorted((ROOT / "Book").glob("*.lean")):
        for m in re.finditer(r"/-- book: (.+?)\n(.*?)-/\ntheorem (\w+)",
                             src.read_text(encoding="utf-8"), re.S):
            head, body, name = m.groups()
            key = re.search(r"key: ([\w:-]+)", head).group(1)
            loc = re.search(r"([\w/]+\.typ:\d+)", head).group(1)
            origen = re.search(r"Origen: ([^\n]+)", body)
            rows.append((name, key, loc, src.name,
                         origen.group(1).rstrip(". ") if origen else "?",
                         axioms.get(name, "(no auditado)")))
            claves.add(key)
    # Integridad: toda fila declarada completada debe estar cubierta arriba.
    faltan = [c for cs in COMPLETADAS.values() for c in cs if c not in claves]
    if faltan:
        print(f"FALLO: filas completadas sin teorema: {faltan}", file=sys.stderr)
        return 1
    out = ["# DASHBOARD — verificacion_lean", "",
           f"Generado por `Progress/gen_dashboard.py` el "
           f"{datetime.date.today().isoformat()} desde `Book/*.lean` y "
           "`build/axioms.log`. No editar a mano.", "",
           "## Teoremas verificados", "",
           "| Teorema | Clave del libro | Origen | Axiomas | Estado |",
           "|---|---|---|---|---|"]
    for name, key, loc, src, origen, ax in rows:
        estado = "OK" if name in axioms else "SIN AUDITAR"
        out.append(f"| `{name}` (`{src}`) | `{key}` @ {loc} | {origen} | "
                   f"`{ax}` | {estado} |")
    out += ["", "## Cobertura del inventario (plan §2)", ""]
    for fase in ("P1", "P2", "P3"):
        out.append(f"- **{fase}**: {len(COMPLETADAS[fase])}/{INVENTARIO[fase]} "
                   "filas completadas")
    total = sum(INVENTARIO.values())
    done = sum(len(v) for v in COMPLETADAS.values())
    out += [f"- **Total**: {done}/{total} filas · {len(claves)} claves "
            f"del libro cubiertas", "",
            f"Axiomas esperados en toda fila: `{LIMPIO}`.", ""]
    (ROOT / "Progress" / "DASHBOARD.md").write_text("\n".join(out),
                                                    encoding="utf-8")
    print(f"OK: DASHBOARD.md ({len(rows)} teoremas, {done}/{total} filas).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
