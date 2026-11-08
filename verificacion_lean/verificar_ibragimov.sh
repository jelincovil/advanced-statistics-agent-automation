#!/usr/bin/env bash
# Runner del módulo Book/ApendiceDIbragimov.lean (deuda C.thm:appD-ibragimov).
# Compila el módulo, audita axiomas y falla si hay `sorry` o axiomas extra.
set -euo pipefail
cd "$(dirname "$0")"
BUILD="build"
mkdir -p "$BUILD/Book"
export LEAN_PATH="$PWD/$BUILD:${LEAN_PATH:-}"
lean --root=. -o "$BUILD/Book/ApendiceDIbragimov.olean" Book/ApendiceDIbragimov.lean
lean --root=. AuditIbra.lean | tee "$BUILD/axioms_ibragimov.log"
if grep -q "sorryAx" "$BUILD/axioms_ibragimov.log"; then
  echo "FALLO: sorryAx en la auditoría" >&2; exit 1
fi
if grep -E "depends on axioms: \[" "$BUILD/axioms_ibragimov.log" | grep -vE "\[propext, Classical.choice, Quot.sound\]"; then
  echo "FALLO: axioma prohibido" >&2; exit 1
fi
if grep -n "sorry" Book/ApendiceDIbragimov.lean; then
  echo "FALLO: 'sorry' en Book/ApendiceDIbragimov.lean" >&2; exit 1
fi
echo "OK: ApendiceDIbragimov en verde (módulo compilado, axiomas limpios, sin sorry)."
