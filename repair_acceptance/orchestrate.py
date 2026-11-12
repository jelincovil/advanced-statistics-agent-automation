#!/usr/bin/env python3
"""Versioned final driver; no original ZIP/sandbox path is needed."""
import argparse
import hashlib
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from repair_acceptance.verify import run


def main():
    parser = argparse.ArgumentParser(description="Final independent acceptance orchestrator")
    parser.add_argument("--repo", type=pathlib.Path, required=True)
    parser.add_argument("--out", type=pathlib.Path, required=True)
    parser.add_argument("--baseline", action="store_true")
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    records = []
    manifest = repo / "argumentos"
    for name, argv, cwd in [
        ("git_head", ["git", "rev-parse", "HEAD"], repo),
        ("git_status", ["git", "status", "--porcelain", "--untracked-files=all"], repo),
        ("fmt", ["cargo", "fmt", "--check"], manifest),
        ("clippy", ["cargo", "clippy", "--all-targets", "--locked", "--", "-D", "warnings"], manifest),
        ("tests", ["cargo", "test", "--locked"], manifest),
        ("lean", ["bash", "verificar.sh"], repo / "verificacion_lean"),
    ]:
        records.append(run(name, argv, cwd, out))
    probe = out / "external_probe"
    (probe / "tests").mkdir(parents=True)
    (probe / "tests/probe.rs").write_bytes((HERE / "probe.rs").read_bytes())
    (probe / "Cargo.toml").write_text(
        '[package]\nname="openmathos_probe"\nversion="0.1.0"\nedition="2021"\n'
        '[dependencies]\nargumentos={path=' + json.dumps(str(manifest)) + '}\n', encoding="utf-8")
    records.append(run("external_probe", ["cargo", "test", "--locked", "--manifest-path", str(probe / "Cargo.toml")], manifest, out))
    records.append(run("acceptance", [sys.executable, str(HERE / "verify.py"), "--repo", str(repo), "--out", str(out / "acceptance.json")], repo, out))
    complete = all(r["exit_code"] == 0 for r in records) and not (out / "git_status.log").read_text().strip()
    try:
        data = json.loads((out / "acceptance.json").read_text())
        complete = complete and data["status"] == "PASS"
        complete = complete and all(data["cases"].get(f"C{i:02d}") == "PASS" for i in range(1, 13))
        complete = complete and all(data["gates"].get(f"G{i}") == "PASS" for i in range(1, 11))
    except (OSError, ValueError, KeyError, TypeError):
        complete = False
    after = run("git_diff_after", ["git", "status", "--porcelain", "--untracked-files=all", "--no-renames"], repo, out)
    records.append(after)
    complete = complete and after["exit_code"] == 0 and not (out / "git_diff_after.log").read_text().strip() and not args.baseline
    report = {"status": "COMPLETE_VERIFIED" if complete else "BLOCKED_WITH_EVIDENCE",
              "records": records,
              "reserved_debt": ["C.thm:appD-ibragimov", "C.thm:appD-gordin"],
              "scope": "v1 software acceptance with visible pending semantic reviews"}
    (out / "verification.json").write_text(json.dumps(report, indent=2) + "\n")
    print(report["status"])
    return 0 if complete else 1


if __name__ == "__main__":
    sys.exit(main())
