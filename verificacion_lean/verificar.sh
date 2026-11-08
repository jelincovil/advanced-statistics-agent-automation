#!/usr/bin/env bash
# verificar.sh — runner canónico del proyecto (PLAN_LEAN_LIBRO_2026-11-04.md §5).
#
# /opt/mathlib es read-only para este usuario: no hay `lake build` local.
# Se compila con `lean` directo sobre el LEAN_PATH del entorno (Mathlib
# precompilada) y se generan los .olean locales para los imports entre módulos.
#
# Uso:            ./verificar.sh
# Puerta F0:      exit 0 ⇔ todos los módulos compilan, cero "sorry" en Book/,
#                 sin sorryAx en la auditoría.
set -euo pipefail
cd "$(dirname "$0")"

BUILD="build"
rm -rf "$BUILD"
mkdir -p "$BUILD/Book"

# LEAN_PATH local = build (absoluto) + Mathlib del entorno
export LEAN_PATH="$PWD/$BUILD:${LEAN_PATH:-}"

# 1) Foundation (sin dependencias locales) → olean
echo "== Book/Foundation.lean"
lean --root=. -o "$BUILD/Book/Foundation.olean" Book/Foundation.lean

# 2) Capítulos, en orden de dependencia
for mod in Book/Cap04Herramientas.lean Book/Cap05Representacion.lean Book/Cap07OPE.lean Book/Cap06Fronteras.lean Book/Cap03MDP.lean Book/SSCH.lean Book/Cap02Wald.lean Book/Cap08Intervalos.lean Book/Cap11Despliegue.lean Book/ApendiceDRegularidad.lean; do
  echo "== $mod"
  lean --root=. -o "$BUILD/${mod%.lean}.olean" "$mod"
done

# 3) Auditoría de axiomas
echo "== Book/Audit.lean"
lean --root=. Book/Audit.lean | tee "$BUILD/axioms.log"
if grep -q "sorryAx" "$BUILD/axioms.log"; then
  echo "FALLO: sorryAx en la auditoría" >&2
  exit 1
fi

# 4) Cero "sorry" en las fuentes
if grep -rn "sorry" Book/ ; then
  echo "FALLO: 'sorry' en Book/" >&2
  exit 1
fi

echo "OK: verificar.sh en verde (módulos compilados, axiomas auditados, sin sorry)."
