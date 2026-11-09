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
for mod in Book/Cap08Estimadores.lean Book/Cap08Poder.lean Book/Cap04Herramientas.lean Book/Cap04Suficiencia.lean Book/Cap04LoteM16.lean Book/Cap08M6.lean Book/Cap04Ch6.lean Book/Cap05Asintotica.lean Book/Cap04Ejemplos.lean Book/Cap05Representacion.lean Book/Cap07OPE.lean Book/Cap06Fronteras.lean Book/Cap03MDP.lean Book/SSCH.lean Book/Cap02Wald.lean Book/Cap08Intervalos.lean Book/Cap11Despliegue.lean Book/ApendiceDRegularidad.lean Book/Cap12Problemas.lean Book/BarridoM16.lean Book/Cap02M11.lean Book/Cap08Ch11M10.lean Book/Cap10OPE.lean Book/Ch5EjemplosM5.lean Book/Ch5GcM5.lean Book/Ch5CltAgentesM5.lean Book/Cap08BanditsM7.lean Book/Ch1Ch2Pendientes.lean Book/Ch2Pendientes.lean Book/ApendiceDViolaciones.lean Book/ApendiceDErgodicidad.lean Book/Cap08Bandits.lean Book/Cap08FrozenLake.lean Book/Cap04Ch4M6.lean Book/ConvergenciaBase.lean Book/Cap11HacM1.lean Book/M13Mcmc.lean Book/Cap06FallosM6.lean Book/ApendiceEMedido.lean Book/Cap12ProblemasM8.lean Book/AppEFuncionImplicita.lean Book/AppEFuncionImplicitaCond.lean Book/SSCHCap01M7.lean Book/SSCHCap02M7.lean Book/SSCHCap03M7.lean Book/SSCHCap0405M7.lean Book/SSCHCap06M7.lean Book/SSCHEjemplosM7.lean Book/Cap04BhM3.lean Book/Cap04UmpuM3.lean Book/M9Pendientes.lean Book/Cap04EjemplosM2.lean Book/Cap06PesosTasasM5.lean Book/Cap04Ch6DmlM5.lean Book/Cap03MleM4.lean Book/ApendiceDIbragimov.lean Book/ApendiceEHilbert.lean Book/Cap04Ch6Motivacion.lean Book/GordinCoreM8.lean Book/Cap03LaiRobbinsM7.lean Book/AppDHacM9.lean Book/Cap04MedibleIntuicionM10.lean Book/AppERNM3.lean Book/ApendiceEMedidoDctM5.lean; do
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

# 4) Cero "sorry" en las fuentes (tactic sorry)
if grep -Rn "^[[:space:]]*sorry\b" Book/ --include="*.lean"; then
  echo "FALLO: tactic sorry en Book/" >&2
  exit 1
fi

echo "OK: verificar.sh en verde (módulos compilados, axiomas auditados, sin sorry)."
