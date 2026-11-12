#!/usr/bin/env bash
# Run from the CLEAN checkout. Nothing mutable or sandbox-specific is needed
# beyond the pinned external Lean/Mathlib installation and installed Cargo.
set -euo pipefail
usage() { echo "usage: bash repair_acceptance/reproduce.sh --out /external/new-evidence-dir" >&2; exit 2; }
if [ "$#" -ne 2 ] || [ "$1" != "--out" ]; then usage; fi
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
[ -z "$(git status --porcelain --untracked-files=all)" ] || { echo "checkout is not clean" >&2; exit 2; }
OUT="$2"
if [ "${OUT#/}" = "$OUT" ]; then OUT="$OLDPWD/$OUT"; fi
[ ! -e "$OUT" ] || { echo "output must be a new external directory: $OUT" >&2; exit 2; }
mkdir -p "$OUT"
RECORD="$OUT/reproduction_record.json"
SOURCE="$(git rev-parse HEAD)"
DRIVER="$ROOT/repair_acceptance/orchestrate.py"
python3 - "$ROOT" "$SOURCE" "$RECORD" "$DRIVER" <<'PY'
import hashlib,json,pathlib,sys
root,source,out,driver=sys.argv[1:]
path=pathlib.Path(root)/'repair_acceptance/reproduce.sh'
data={"source_commit":source,"driver_sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"driver":str(path),"clean_before":True,"external_output":str(pathlib.Path(out).parent)}
pathlib.Path(out).write_text(json.dumps(data,indent=2)+"\n")
PY
export OPENMATHOS_REPRODUCTION=1
export REPRODUCTION_RECORD="$RECORD"
if python3 "$DRIVER" --repo "$ROOT" --out "$OUT/verification"; then
  STATUS=0
else
  STATUS=$?
fi
# A generated tracked file is a material diff, never an ignored side effect.
if [ -n "$(git status --porcelain --untracked-files=all)" ]; then
  git status --short
  printf '%s\n' "generated checkout mutations detected" >&2
  exit 1
fi
if [ "$STATUS" -ne 0 ]; then
  exit "$STATUS"
fi
python3 - "$OUT/verification/verification.json" "$OUT/report.json" <<'PY'
import hashlib,json,pathlib,sys
report=pathlib.Path(sys.argv[1]);content=report.read_bytes();data=json.loads(content)
data['generated_source_commit']='from actual checkout'
data['verification_sha256']=hashlib.sha256(content).hexdigest()
pathlib.Path(sys.argv[2]).write_text(json.dumps(data,indent=2)+"\n")
print('REPRODUCED:',sys.argv[2])
PY
