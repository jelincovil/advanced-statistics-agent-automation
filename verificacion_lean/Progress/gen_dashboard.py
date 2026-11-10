#!/usr/bin/env python3
"""Genera Progress/DASHBOARD.md desde los comentarios `book:` de Book/*.lean
y la auditoria build/axioms.log (producida por ./verificar.sh).
Convencion del plan §3: el dashboard se genera, no se edita a mano.

Cambios respecto de la versión de smw85 (473a208), al pasar de 65 a 67 ficheros
en `Book/` y de 174 a 2699 teoremas auditados:

1. Extracción de `book:` robusta: se empareja el docstring con el `theorem` que
   documenta (antes `.+?` con `re.S` podía tragarse docstrings intermedios) y la
   localización `.typ` puede venir sin número de línea — dos filas del libro
   (`der:convprob-plug-in`, `der:convprob-abs-le`) lo hacen y hacían *abortar*
   el generador con `AttributeError`.
2. La auditoría se indexa por nombre completo (`Book.M.foo`) y por nombre corto;
   una fila se considera auditada si su teorema casa con la misma prioridad con
   que Lean resuelve el nombre: primero el módulo del propio fichero, después el
   nombre corto único. Así funciona igual con `Audit.lean` (nombres cortos) y
   con `AuditAll.lean` (nombres completos).
3. Estado por fila: `OK` / `SIN AUDITAR` / `AXIOMA EXTRAÑO`, más un resumen y la
   cobertura por módulo y por clave en el propio DASHBOARD.
4. `--check` convierte el dashboard en puerta: sale 1 si queda alguna fila sin
   auditar o con axiomas fuera de `propext, Classical.choice, Quot.sound`.
   `./verificar.sh` lo usa como último paso.
5. Además del DASHBOARD escribe `Progress/AUDITORIA_COBERTURA.md`: la parte
   mecánica (clave → teoremas, módulos, auditoría) delante de la auditoría de
   enunciados de 2026-11-06, que es semántica y no se puede regenerar sola.
"""
import argparse
import datetime
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOG = ROOT / "build" / "axioms.log"
BOOK = ROOT / "Book"

# Filas del inventario del plan §2 ya completadas, por fase: lista de claves
# que las cubren. Cada clave debe aparecer en la tabla generada (se verifica).
COMPLETADAS = {
    "P1": ["thm:ch9-isomorfismo", "cor:ch9-bayes", "thm:ch9-admisibilidad",
           "cor:ch7-traduccion", "thm:ch10-dr", "thm:ch9-ic",
           "thm:ch9-secuencial", "cor:ch9-bellman", "thm:ch8-mejora",
           "thm:ch10-identificacion", "thm:ch10-is-insesgado",
           "thm:ch10-curse", "cor:ch8-parada", "ex:ssch-cap09"],
    "P2": ["thm:ch7-bayes", "thm:ch7-minimax-bayes", "thm:ch7-admisibilidad-bayes",
           "thm:ch7-complete-class", "ex:ch6-memoria", "ex:ch9-confounding",
           "ex:ch9-fallo-mixing", "ex:ch9-fallo-overlap",
           "ex:ch9-observabilidad-parcial", "ex:ch6-minimax-dominada",
           "prop:ch10-var-dr", "prop:ch11-baseline", "ex:ssch-cap08"],
    "P3": ["ex:ch5-cadena", "ex:ch11-pg-ssch", "cap11-cuantizacion",
           "cap11-truncamiento", "cap11-monitoreo", "def:appE-mdp-test",
           "thm:ch11-tasa-tabular", "cap11-margen"],
}
# Claves con teoremas parciales: lo probado y lo que falta.
PARCIALES = {}
INVENTARIO = {"P1": 14, "P2": 13, "P3": 8}  # filas del plan §2
LIMPIO = "propext, Classical.choice, Quot.sound"
PERMITIDOS = {"propext", "Classical.choice", "Quot.sound"}

# Docstring + declaración `theorem`. El `book:` tiene que ABRIR el docstring: si
# se acepta en cualquier posición, los comentarios de prosa que citan «book:
# ...» (cabeceras de módulo, notas) se cuentan como si documentaran el teorema
# siguiente. El cuerpo se corta en el primer `-/` (dot atemperado) para que un
# docstring no se trague los siguientes. Se aceptan atributos, `private`,
# `protected` y `noncomputable` entre el cierre del docstring y la declaración.
DOC_THEOREM = re.compile(
    r"/--\s*book:(?P<cuerpo>(?:(?!-/).)*)-/\s*(?:@\[[^\]]*\]\s*)*"
    r"(?:(?:private|protected|noncomputable)\s*)*"
    r"theorem\s+(?P<nombre>\w+)", re.S)
BOOK_LOC = re.compile(r"([\w/]+\.typ)(?::(\d+))?")
KEY = re.compile(r"key:\s*\**\s*([^\s*),;]+)")
ORIGEN = re.compile(r"Origen: ([^\n]+)")
# `(.*)` y no `([^']+)`: los nombres Lean pueden acabar en apóstrofo
# (`Ch11M10.fexp_const'`); con la clase negada, su línea de auditoría se perdía.
AXIOM_LINE = re.compile(r"^'(.*)' depends on axioms: \[(.*)\]$", re.M)


def extrae_filas():
    """(nombre, clave, localización, fichero, origen) por teorema anotado."""
    filas, sin_clave = [], []
    for src in sorted(BOOK.glob("*.lean")):
        if src.name == "Audit.lean":          # auditor, no contiene el libro
            continue
        for m in DOC_THEOREM.finditer(src.read_text(encoding="utf-8")):
            cuerpo, nombre = m.group("cuerpo"), m.group("nombre")
            primera = cuerpo.splitlines()[0] if cuerpo.splitlines() else ""
            loc = BOOK_LOC.search(primera) or BOOK_LOC.search(cuerpo[:300])
            clave = KEY.search(primera) or KEY.search(cuerpo[:300])
            if not loc or not clave:
                sin_clave.append((src.name, nombre, cuerpo[:80]))
                continue
            sitio = loc.group(1) + (f":{loc.group(2)}" if loc.group(2) else "")
            origen = ORIGEN.search(cuerpo)
            filas.append((nombre, clave.group(1), sitio, src.stem,
                          origen.group(1).rstrip(". ") if origen else "?"))
    return filas, sin_clave


def carga_axiomas():
    """{nombre completo: axiomas}, {nombre corto: [(completo, axiomas)]}."""
    if not LOG.exists():
        print("FALLO: build/axioms.log no existe — corre ./verificar.sh primero.",
              file=sys.stderr)
        sys.exit(1)
    completos, cortos = {}, defaultdict(list)
    for nombre, axs in AXIOM_LINE.findall(LOG.read_text(encoding="utf-8")):
        completos[nombre] = axs
        cortos[nombre.split(".")[-1]].append((nombre, axs))
    return completos, cortos


def axiomas_de(nombre, modulo, completos, cortos):
    """Resuelve como Lean: módulo propio primero, luego nombre corto único."""
    if f"Book.{modulo}.{nombre}" in completos:
        return completos[f"Book.{modulo}.{nombre}"]
    candidatos = cortos.get(nombre, [])
    for completo, axs in candidatos:
        if modulo and completo.startswith(f"Book.{modulo}."):
            return axs
    if len({axs for _, axs in candidatos}) == 1:
        return candidatos[0][1]
    return None


def limpio(axs):
    return {a.strip() for a in axs.split(",") if a.strip()} <= PERMITIDOS


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="sale 1 si alguna fila no está auditada o no es limpia")
    ap.add_argument("--fecha", default=datetime.date.today().isoformat())
    args = ap.parse_args()

    filas, sin_clave = extrae_filas()
    completos, cortos = carga_axiomas()

    registros = []
    for nombre, clave, sitio, modulo, origen in filas:
        axs = axiomas_de(nombre, modulo, completos, cortos)
        if axs is None:
            estado = "SIN AUDITAR"
        elif limpio(axs):
            estado = "OK"
        else:
            estado = "AXIOMA EXTRAÑO"
        registros.append((nombre, clave, sitio, modulo, origen, axs, estado))

    claves = {r[1] for r in registros}
    faltan = [c for cs in COMPLETADAS.values() for c in cs if c not in claves]
    if faltan:
        print(f"FALLO: filas completadas sin teorema: {faltan}", file=sys.stderr)
        return 1

    sin_auditar = [r for r in registros if r[6] == "SIN AUDITAR"]
    sucios = [r for r in registros if r[6] == "AXIOMA EXTRAÑO"]
    ok = [r for r in registros if r[6] == "OK"]
    teoremas_auditados = set(completos)

    out = ["# DASHBOARD — verificacion_lean", "",
           f"Generado por `Progress/gen_dashboard.py` el {args.fecha} desde "
           "`Book/*.lean` y `build/axioms.log`. No editar a mano.", "",
           "## Resumen", "",
           f"- Ficheros en `Book/`: {len(list(BOOK.glob('*.lean')))} `*.lean` "
           "(incluye los auditores y los módulos sin anotaciones `book:`).",
           f"- Módulos con teoremas anotados: {len({r[3] for r in registros})}.",
           f"- Teoremas con docstring `book:`: {len(registros)} "
           f"({len(claves)} claves distintas).",
           f"- Auditados: {len(ok)} · **SIN AUDITAR: {len(sin_auditar)}** · "
           f"axioma extraño: {len(sucios)}.",
           f"- Teoremas de `Book/*` en `build/axioms.log`: {len(teoremas_auditados)}.",
           f"- Axiomas permitidos: `{LIMPIO}`.", ""]
    if sin_clave:
        out += [f"- Docstrings `book:` con localización o clave no reconocible "
                f"(no entran en la tabla): {len(sin_clave)} — " +
                ", ".join(f"`{n}` (`{f}`)" for f, n, _ in sin_clave), ""]

    out += ["## Teoremas verificados", "",
            "| Teorema | Clave del libro | Origen | Axiomas | Estado |",
            "|---|---|---|---|---|"]
    for nombre, clave, sitio, modulo, origen, axs, estado in registros:
        axs_s = f"`{axs}`" if axs is not None else "—"
        out.append(f"| `{nombre}` (`{modulo}.lean`) | `{clave}` @ {sitio} | "
                   f"{origen} | {axs_s} | {estado} |")

    if sin_auditar:
        out += ["", "## Teoremas sin auditar", ""]
        for nombre, clave, sitio, modulo, _, _, _ in sin_auditar:
            out.append(f"- `{nombre}` (`{modulo}.lean`) — `{clave}` @ {sitio}")
    if sucios:
        out += ["", "## Teoremas con axiomas fuera del conjunto permitido", ""]
        for nombre, clave, _, modulo, _, axs, _ in sucios:
            out.append(f"- `{nombre}` (`{modulo}.lean`) — `{clave}`: `{axs}`")

    por_modulo = defaultdict(lambda: [0, set()])
    for nombre, clave, *_resto in registros:
        por_modulo[_resto[1]][0] += 1
        por_modulo[_resto[1]][1].add(clave)
    out += ["", "## Cobertura por módulo", "",
            "| Módulo | Teoremas `book:` | Claves |", "|---|---|---|"]
    for modulo in sorted(por_modulo):
        n, ks = por_modulo[modulo]
        out.append(f"| `{modulo}.lean` | {n} | {len(ks)} |")

    out += ["", "## Cobertura del inventario (plan §2)", ""]
    for fase in ("P1", "P2", "P3"):
        out.append(f"- **{fase}**: {len(COMPLETADAS[fase])}/{INVENTARIO[fase]} "
                   "filas completadas")
    total = sum(INVENTARIO.values())
    done = sum(len(v) for v in COMPLETADAS.values())
    out += [f"- **Total**: {done}/{total} filas · {done} claves "
            "del libro completadas", "",
            "## En progreso (teoremas parciales)", ""]
    for clave, nota in PARCIALES.items():
        out.append(f"- `{clave}` — {nota}.")
    out += ["", f"Axiomas esperados en toda fila: `{LIMPIO}`.", ""]
    (ROOT / "Progress" / "DASHBOARD.md").write_text("\n".join(out),
                                                   encoding="utf-8")

    # Cobertura mecánica de enunciados: clave → teoremas/módulos. La auditoría
    # semántica (AUDITORIA_ENUNCIADOS_*.md) sigue siendo manual; esto le da el
    # censo exacto sobre el que aplicarse.
    por_clave = defaultdict(list)
    for nombre, clave, sitio, modulo, _, axs, estado in registros:
        por_clave[clave].append((nombre, modulo, sitio, estado))
    cob = ["# AUDITORÍA DE COBERTURA — claves del libro en `Book/*.lean`", "",
           f"Generado por `Progress/gen_dashboard.py` el {args.fecha}. Censo "
           "mecánico: para cada clave `book:`, qué teoremas la formalizan y si "
           "están auditados. La auditoría **semántica** (¿el enunciado Lean dice "
           "lo que dice el libro?) es `AUDITORIA_ENUNCIADOS_*.md` y no se "
           "regenera sola.", "",
           f"- Claves con al menos un teorema: {len(por_clave)}",
           f"- Teoremas con clave: {len(registros)}",
           f"- Claves con teorema sin auditar: {len({r[1] for r in sin_auditar})}",
           "", "| Clave | Teoremas | Módulos | Estados |", "|---|---|---|---|"]
    for clave in sorted(por_clave):
        ts = por_clave[clave]
        mods = sorted({t[1] for t in ts})
        est = Counter(t[3] for t in ts)
        cob.append(f"| `{clave}` | {len(ts)} | {len(mods)} | " +
                   ", ".join(f"{k}: {v}" for k, v in sorted(est.items())) + " |")
    (ROOT / "Progress" / "AUDITORIA_COBERTURA.md").write_text("\n".join(cob) + "\n",
                                                             encoding="utf-8")

    print(f"OK: DASHBOARD.md ({len(registros)} teoremas, {len(ok)} auditados, "
          f"{len(sin_auditar)} SIN AUDITAR, {len(sucios)} con axioma extraño; "
          f"{done}/{total} filas del plan).")
    if sin_clave:
        print(f"AVISO: {len(sin_clave)} docstrings `book:` sin clave/locación "
              f"reconocible: {sin_clave}", file=sys.stderr)
    if args.check and (sin_auditar or sucios):
        print("FALLO: la puerta --check exige SIN AUDITAR = 0 y axiomas limpios.",
              file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
