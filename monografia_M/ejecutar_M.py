"""Runs every M lab and every M checker, registers outputs in resultados_M.json.
Companion of Appendix D. Re-run: `.venv/bin/python ejecutar_M.py`
(uses the companion book's pinned venv by default)."""
from pathlib import Path
import hashlib
import json
import platform
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent
PROGRAMS = [
    *sorted(f"labs/{p.name}" for p in (ROOT / "labs").glob("m_*.py")),
    *sorted(f"verificacion/{p.name}" for p in (ROOT / "verificacion").glob("m_*.py")),
]


def main():
    versions = {"python": platform.python_version(), "platform": platform.platform()}
    for package in ["numpy", "scipy", "scikit-learn", "pandas"]:
        try:
            import importlib.metadata
            versions[package] = importlib.metadata.version(package)
        except Exception:
            versions[package] = None
    results = []
    env = dict(__import__("os").environ, OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1")
    for filename in PROGRAMS:
        started = time.perf_counter()
        try:
            completed = subprocess.run([sys.executable, str(ROOT / filename)], cwd=ROOT,
                                       env=env, capture_output=True, text=True, timeout=1200)
            result = {"file": filename, "returncode": completed.returncode,
                      "stdout": completed.stdout[-4000:], "stderr": completed.stderr[-2000:]}
        except subprocess.TimeoutExpired as error:
            result = {"file": filename, "returncode": None,
                      "stdout": str(error.stdout or "")[-4000:], "stderr": "timeout 1200 s"}
        result["seconds"] = round(time.perf_counter() - started, 2)
        result["sha256"] = hashlib.sha256((ROOT / filename).read_bytes()).hexdigest()
        results.append(result)
        print(filename, result["returncode"], result["seconds"], flush=True)
    (ROOT / "resultados_M.json").write_text(
        json.dumps({"versions": versions, "results": results}, ensure_ascii=False, indent=2),
        encoding="utf-8")
    if any(r["returncode"] != 0 for r in results):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
