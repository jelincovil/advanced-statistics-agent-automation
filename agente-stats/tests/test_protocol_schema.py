"""Suite protocolo/esquema (Fase 3): el servidor se levanta y sus 4 tools
funcionan end-to-end por stdio; el esquema de respuesta se mantiene frozen."""
import json
import subprocess
import sys
import time
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent


@pytest.fixture(scope="module")
def proc():
    import os
    env = dict(os.environ, PYTHONPATH="src")
    p = subprocess.Popen(
        [sys.executable, "-m", "agente_stats_mcp.server"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, text=True, env=env, cwd=str(ROOT))
    yield p
    p.terminate()
    try:
        p.wait(timeout=5)
    except subprocess.TimeoutExpired:
        p.kill()


def msg(p, i, method, params=None):
    m = {"jsonrpc": "2.0", "method": method, "params": params or {}}
    if not method.startswith("notifications/"):
        m["id"] = i
    p.stdin.write(json.dumps(m) + "\n"); p.stdin.flush()


def read_until(p, rid, timeout=30):
    deadline = time.time() + timeout
    while time.time() < deadline:
        line = p.stdout.readline()
        if not line:
            continue
        m = json.loads(line)
        if m.get("id") == rid:
            return m
    raise TimeoutError(rid)


def call(p, rid, tool, args):
    msg(p, rid, "tools/call", {"name": tool, "arguments": args})
    return json.loads(read_until(p, rid)["result"]["content"][0]["text"])


@pytest.fixture(scope="module", autouse=True)
def handshake(proc):
    msg(proc, 1, "initialize", {
        "protocolVersion": "2024-11-05",
        "capabilities": {},
        "clientInfo": {"name": "pytest-smoke", "version": "0.1.0"},
    })
    msg(proc, None, "notifications/initialized")


def test_tools_list_has_exactly_four(proc):
    msg(proc, 2, "tools/list")
    tools = {t["name"] for t in read_until(proc, 2)["result"]["tools"]}
    assert tools == {"inspect_episodes", "ope_evaluate",
                     "compare_versions", "justification_ficha"}


def test_inspect_ok(proc):
    r = call(proc, 3, "inspect_episodes", {"path": "agent_v1_episodes.jsonl"})
    assert r["ok"] and r["summary"]["n_episodes"] == 40


def test_schemas_of_answers(proc):
    pn = {"type": "eps_greedy",
          "q_table": [[-0.5, -1.0], [0.0, -0.5], [0.5, 0.0], [1.0, 0.5], [1.5, 1.0]],
          "epsilon": 0.3}
    r = call(proc, 4, "ope_evaluate", {"path": "agent_v2_episodes.jsonl",
                                       "estimator": "IS", "target": pn})
    required = {"ok", "estimator", "value", "se", "ci95", "level",
                "n_units", "ess_fraction", "eff_samples", "truncated",
                "mean_weight", "max_weight_observed", "gamma", "regime", "notes"}
    assert required.issubset(r.keys()), sorted(r.keys())
    assert r["estimator"] == "IS"
    assert isinstance(r["value"], (int, float))
    assert isinstance(r["ci95"], list) and len(r["ci95"]) == 2


def test_ficha_rejects_empty_estimand_actionable(proc):
    pn = {"type": "eps_greedy",
          "q_table": [[-0.5, -1.0], [0.0, -0.5], [0.5, 0.0], [1.0, 0.5], [1.5, 1.0]],
          "epsilon": 0.3}
    r = call(proc, 7, "justification_ficha",
             {"path": "agent_v2_episodes.jsonl", "estimand": "",
              "estimator": "IS", "target": pn})
    assert r["ok"] is False and "estimand ausente" in r["error"]


def test_path_jail_rejects_outside_with_action(proc):
    r = call(proc, 8, "ope_evaluate", {"path": "/etc/passwd", "estimator": "IS",
                                       "target": {"type": "explicit",
                                                  "policy": {"(0,1)": 1.0}}})
    assert r["ok"] is False
    assert "jail" in r["error"] or "ruta" in r["error"]
