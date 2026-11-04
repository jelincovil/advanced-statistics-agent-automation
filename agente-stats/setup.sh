#!/usr/bin/env bash
# Setup + smoke de 5 minutos para el piloto del curso (PLAN_MCP_V2, Fase 4).
set -euo pipefail
cd "$(dirname "$0")"

command -v uv >/dev/null 2>&1 || {
  echo "uv no está. Instálalo: brew install uv (mac) | pip install uv." >&2
  exit 1
}

echo "[1/4] instalando entorno"
uv sync --quiet 2>/dev/null || uv pip install -q "mcp==1.12.2" "pydantic>=2.11,<2.12" pytest --python .venv/bin/python 2>/dev/null || true

echo "[2/4] PYTHONPATH=src python -m agente_stats_mcp.server (init/tools-list hijo)"
PYTHONPATH=src uv run python - <<'PYEOF'
import json, subprocess, sys, time, os
env = dict(os.environ, PYTHONPATH="src")
proc = subprocess.Popen(
    [sys.executable, "-m", "agente_stats_mcp.server"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    text=True, env=env)
def msg(i, m, p=None):
    proc.stdin.write(json.dumps({"jsonrpc": "2.0", "method": m, "params": p or {}, "id": i}) + "\n"); proc.stdin.flush()
def read_until(rid, timeout=25):
    d = time.time() + timeout
    while time.time() < d:
        line = proc.stdout.readline()
        if not line: continue
        m = json.loads(line)
        if m.get("id") == rid: return m
    raise TimeoutError(rid)
msg(1, "initialize", {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "smoke", "version": "0.1"}})
proc.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}}) + "\n"); proc.stdin.flush()
msg(2, "tools/list")
tools = {t["name"] for t in read_until(2)["result"]["tools"]}
assert tools == {"inspect_episodes", "ope_evaluate", "compare_versions", "justification_ficha"}, tools
print("tools OK:", sorted(tools))
proc.terminate()
PYEOF

echo "[3/4] test de protocolo y esquema (tests/test_protocol_schema.py)"
PYTHONPATH=src uv run pytest tests/test_protocol_schema.py -q 2>/dev/null || \
  PYTHONPATH=src .venv/bin/pytest tests/test_protocol_schema.py -q 2>/dev/null || \
  PYTHONPATH=src ../agents_curso/capitulo_09_isomorfismo/.venv/bin/pytest tests/test_protocol_schema.py -q --import-mode=importlib

echo "[4/4] listo. En Claude Code: añade este proyecto, aprébalo una vez (véase docs/sesiones)."
