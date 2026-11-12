#!/usr/bin/env python3
"""Reproduce the v1 acceptance gates with independently executed evidence.

--out is an external report path. All work products are external. PASS is
computed, never taken from a field in the receipt or from this script.
"""
import argparse
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import time

AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def read_text(path):
    return pathlib.Path(path).read_text(encoding="utf-8", errors="replace")


def read_json(path):
    return json.loads(pathlib.Path(path).read_text(encoding="utf-8"))


def write_json(path, data):
    path = pathlib.Path(path)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)


def run(name, argv, cwd, logs, timeout=7200, env=None):
    start = time.time()
    environment = os.environ.copy()
    if env:
        environment.update(env)
    path = pathlib.Path(logs) / (name + ".log")
    try:
        result = subprocess.run([str(a) for a in argv], cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=environment, timeout=timeout)
        code, data = result.returncode, result.stdout
    except (OSError, subprocess.TimeoutExpired) as error:
        code, data = 125, str(error).encode("utf-8")
    path.write_bytes(data)
    return {"name": name, "argv": [str(a) for a in argv], "exit_code": code,
            "seconds": round(time.time() - start, 2), "log": str(path), "sha256": sha256(data)}


def parse_test_suites(output):
    """Count only actually-run tests. A global green is not per-case evidence."""
    count = 0
    suites = []
    for line in output.splitlines():
        if line.startswith("running ") and " tests" in line:
            number = line.split()[1]
            if number.isdigit():
                count += int(number)
        if line.startswith("test result: ok. "):
            passed = int(line.split("test result: ok. ")[1].split()[0].split(";")[0].replace("passed", "").strip())
            suites.append(passed)
    return count, suites


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=pathlib.Path, required=True)
    parser.add_argument("--out", type=pathlib.Path, required=True)
    args = parser.parse_args()
    repo = args.repo.resolve()
    out = args.out.resolve()
    if out == repo or repo in out.parents:
        parser.error("--out must be outside the checkout")
    work = out.parent / "acceptance_work"
    logs_dir = work / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)
    evidence_root = work
    receipts = evidence_root / "receipts"
    receipts.mkdir(exist_ok=True)
    sys.path.insert(0, str(repo / "repair_acceptance"))
    import case_driver
    import lib

    manifest = repo / "argumentos"
    kernel_path = manifest / "kernel/libro_completo.json"
    book = repo / "book_stat_inference_v0"
    lean = repo / "verificacion_lean"
    cargo = ["cargo", "run", "--locked", "--manifest-path", str(manifest / "Cargo.toml"), "--"]
    evidence = []
    cases = {f"C{i:02d}": "FAIL" for i in range(1, 13)}
    gates = {f"G{i}": "FAIL" for i in range(1, 11)}
    summary = {"errors": []}
    status = "FAIL"
    try:
        head_record = run("git_head", ["git", "rev-parse", "HEAD"], repo, logs_dir)
        status_record = run("git_status", ["git", "status", "--porcelain", "--untracked-files=all"], repo, logs_dir)
        evidence.extend([head_record, status_record])
        for name, command in [
            ("fmt", ["cargo", "fmt", "--check"]),
            ("clippy", ["cargo", "clippy", "--all-targets", "--locked", "--", "-D", "warnings"]),
            ("rust_tests", ["cargo", "test", "--locked"]),
        ]:
            evidence.append(run(name, command, manifest, logs_dir))
        evidence.append(run("lean_runner", ["bash", "verificar.sh"], lean, logs_dir))
        inventory_path = evidence_root / "book_inventory.json"
        evidence.append(run("book_inventory", cargo + ["inventory", "--book", str(book), "--out", str(inventory_path)], repo, logs_dir))
        verify_record = run("proof_reproduction", cargo + ["verify", "--repo", str(repo), "--out", str(receipts)], repo, logs_dir)
        evidence.append(verify_record)
        evidence.append(run("editorial_audit", cargo + ["audit", "--kernel", str(kernel_path), "--book", str(book)], repo, logs_dir))

        lean_environment = os.environ.copy()
        previous = lean_environment.get("LEAN_PATH", "")
        lean_environment["LEAN_PATH"] = str(lean / "build") + (":" + previous if previous else "")
        exporter_path = evidence_root / "lean_export.jsonl"
        export_record = run("lean_export", ["lean", str(manifest / "evidence/lean_export.lean")], repo, logs_dir, env=lean_environment)
        evidence.append(export_record)
        exporter_path.write_bytes((logs_dir / "lean_export.log").read_bytes())

        # The probe source is versioned, not borrowed from a sandbox path.
        probe_source = repo / "repair_acceptance/probe.rs"
        probe = evidence_root / "external_probe"
        (probe / "tests").mkdir(parents=True, exist_ok=True)
        (probe / "tests/probe.rs").write_bytes(probe_source.read_bytes())
        (probe / "Cargo.toml").write_text(
            '[package]\nname="openmathos_probe"\nversion="0.1.0"\nedition="2021"\n'
            '[dependencies]\nargumentos={path=' + json.dumps(str(manifest)) + '}\n', encoding="utf-8")
        evidence.append(run("external_lockfile", ["cargo", "generate-lockfile", "--offline", "--manifest-path", str(probe / "Cargo.toml")], manifest, logs_dir))
        evidence.append(run("external_probe", ["cargo", "test", "--locked", "--offline", "--manifest-path", str(probe / "Cargo.toml")], manifest, logs_dir))

        by_exit = {r["name"]: r["exit_code"] for r in evidence}
        head = read_text(logs_dir / "git_head.log").strip()
        dirty = read_text(logs_dir / "git_status.log").strip()
        kernel = read_json(kernel_path)
        claims, arguments, specs = kernel["claims"], kernel["arguments"], kernel["evidence_specs"]
        inventory = read_json(inventory_path)
        spec_by_id = {s["id"]: s for s in specs}
        tests_text = read_text(logs_dir / "rust_tests.log")
        lean_text = read_text(logs_dir / "lean_runner.log")
        check_text = read_text(logs_dir / "proof_reproduction.log")
        run_count, test_suites = parse_test_suites(tests_text)
        test_ok = by_exit["rust_tests"] == 0 and run_count > 0 and len(test_suites) > 0

        # Actual Lean module census is a source-level closed set, with explicit auditors.
        active = lib.module_sources(read_text(lean / "verificar.sh"))
        present = {p.stem for p in (lean / "Book").glob("*.lean") if p.name not in {"Audit.lean", "AuditAll.lean"}}
        missing_modules = sorted(present - active)
        extra_modules = sorted(active - present)
        lean_ok = (by_exit["lean_runner"] == 0 and not missing_modules and not extra_modules
                   and "AUDIT-ALL:" in lean_text and "0 con axiomas no permitidos" in lean_text
                   and "SIN AUDITAR = 0" in lean_text)
        gates["G4"] = "PASS" if lean_ok else "FAIL"

        targets = {}
        for line in exporter_path.read_text(encoding="utf-8").splitlines():
            if line.strip():
                obj = json.loads(line)
                targets[obj["name"]] = obj
        corpus_rows, coverage = lib.build_corpus(repo, kernel, inventory, targets)
        g6_ok = (len(corpus_rows) == len(claims) and len(coverage) == len(inventory["blocks"]))
        gates["G6"] = "PASS" if g6_ok and lib.semantic_gate(corpus_rows, coverage) else "FAIL"

        # Each case gets its own executed Rust test or an independent CLI/probe.
        executed, case_evidence = case_driver.execute_cases(repo, logs_dir, corpus_rows, coverage, check_text)
        evidence.extend(case_evidence)
        for case, info in executed.items():
            cases[case] = info["status"]
        gates["G2"] = "PASS" if all(x == "PASS" for x in cases.values()) else "FAIL"
        gates["G3"] = "PASS" if test_ok and all(by_exit[n] == 0 for n in ["fmt", "clippy", "external_probe"]) else "FAIL"
        gates["G1"] = "PASS" if verify_record["exit_code"] == 0 and "verify:" in check_text and not missing_modules else "FAIL"

        used_specs = {eid for a in arguments for eid in a["evidence_specs"]}
        unused = sorted(s["id"] for s in specs if s["id"] not in used_specs)
        receipts_files = sorted(receipts.glob("*.json"))
        gates["G5"] = "PASS" if (not unused and len(receipts_files) == len(specs)
                                  and len(corpus_rows) == len(claims) and len(coverage) == len(inventory["blocks"])
                                  and (str(len(arguments)) + "/" + str(len(arguments))) in check_text) else "FAIL"

        # Current inputs are checked individually. The commit is historical
        # identity; exact inputs and elaborated types govern validity.
        provenance_errors = []
        for path in receipts_files:
            receipt = read_json(path)
            spec = spec_by_id.get(receipt["spec_id"])
            if not spec:
                provenance_errors.append(path.name + ":spec missing")
                continue
            if not lib.required_inputs_present(receipt, spec, repo):
                provenance_errors.append(path.name + ":required map incomplete")
            origin = run("origin:" + path.name, ["git", "merge-base", "--is-ancestor", receipt["source_commit"], "HEAD"], repo, logs_dir)
            evidence.append(origin)
            if origin["exit_code"] != 0:
                provenance_errors.append(path.name + ":not an ancestor")
            for rel, expected_hash in receipt["input_hashes"].items():
                candidate = repo / rel
                if not candidate.is_file() or sha256(candidate.read_bytes()) != expected_hash:
                    provenance_errors.append(path.name + ":" + rel)
                if ".." in pathlib.PurePosixPath(rel).parts:
                    provenance_errors.append(path.name + ":escaping path")
            if spec["kind"] == "lean":
                target = targets.get(spec["target"])
                provenance = next((c for c in receipt["observed_checks"] if c["id"].startswith("lean_provenance:")), None)
                if target is None or provenance is None:
                    provenance_errors.append(path.name + ":missing target/provenance")
                elif "type_sha256=" + lib.sha256_text(target["type"]) not in provenance["detail"] or any(x not in AXIOMS for x in target["axioms"]):
                    provenance_errors.append(path.name + ":type or axioms changed")
        gates["G7"] = "PASS" if not provenance_errors and verify_record["exit_code"] == 0 else "FAIL"

        included_without_claim = [c for c in coverage if c["state"] == "included_pending"]
        gates["G8"] = "PASS" if (all(c["state"] != "unclassified" for c in coverage)
                                  and len(included_without_claim) == 0
                                  and by_exit["editorial_audit"] == 0) else "FAIL"

        # G9 validates coherence, not names or a coincidental string.
        documentation_errors = []
        for file in [manifest / "README.md", repo / "STATE.json", repo / "FINAL.md"]:
            if not file.is_file():
                documentation_errors.append(str(file))
        if not documentation_errors:
            try:
                state = read_json(repo / "STATE.json")
                ids = {f["id"] for f in state["findings"]}
                if ids != {f"F{i:02d}" for i in range(1, 15)}:
                    documentation_errors.append("ledger F01-F14 incomplete")
                if state.get("current_commit") != head or state.get("status") != "COMPLETE_VERIFIED":
                    documentation_errors.append("STATE commit/status does not match verified HEAD")
                pending_findings = [f["id"] for f in state["findings"] if f["status"] not in {"fixed", "refuted"} or not f.get("evidence")]
                if pending_findings:
                    documentation_errors.append("unresolved ledger entries: " + repr(pending_findings))
            except (ValueError, KeyError, TypeError) as error:
                documentation_errors.append(str(error))
        gates["G9"] = "PASS" if not documentation_errors else "FAIL"

        # Participating evidence of a clean reproduction is more authoritative
        # than a flag: commit, driver hash and cleanliness were measured there.
        record_path = os.environ.get("REPRODUCTION_RECORD", "")
        reproduction_ok = False
        reproduction_error = None
        if record_path:
            reproduction_file = pathlib.Path(record_path)
            if reproduction_file.is_file():
                record = read_json(reproduction_file)
                actual_sha = sha256((repo / "repair_acceptance/reproduce.sh").read_bytes())
                reproduction_ok = (record.get("source_commit") == head
                                   and record.get("driver_sha256") == actual_sha
                                   and record.get("clean_before") is True
                                   and not dirty
                                   and pathlib.Path(record["driver"]).resolve() == (repo / "repair_acceptance/reproduce.sh").resolve())
            else:
                reproduction_error = "record file absent"
        else:
            reproduction_error = "REPRODUCTION_RECORD absent"
        gates["G10"] = "PASS" if reproduction_ok else "FAIL"

        negative_failures = case_driver.negative_mutations(repo, repo / "repair_acceptance/semantic_reviews.json", logs_dir)
        gates["G6"] = "PASS" if gates["G6"] == "PASS" and not negative_failures else "FAIL"

        relation_counts = {}
        review_counts = {}
        for row in corpus_rows:
            relation_counts[row["relation"]] = relation_counts.get(row["relation"], 0) + 1
            review_counts[row["review_status"]] = review_counts.get(row["review_status"], 0) + 1
        review_document = {
            "schema_version": "claim-review/2",
            "collection": "automatic Lean export and Typst AST; not itself semantic evaluation",
            "review_provenance_file": "repair_acceptance/semantic_reviews.json",
            "reviewed_by": "agent_reviewed",
            "relations": relation_counts,
            "review_pending_count": len(corpus_rows) - review_counts.get("agent_reviewed", 0),
            "rows": corpus_rows,
        }
        write_json(repo / "repair_acceptance/claim_review.json", review_document)
        write_json(evidence_root / "inventory_scope.json", {"rows": coverage})
        summary.update({
            "claims": len(claims), "arguments": len(arguments), "specs": len(specs),
            "receipts": len(receipts_files), "book_blocks": len(inventory["blocks"]),
            "rust_tests_executed": run_count, "missing_lean_modules": missing_modules,
            "extra_lean_modules": extra_modules, "unused_specs": unused,
            "provenance_errors": provenance_errors, "documentation_errors": documentation_errors,
            "reproduction_error": reproduction_error if not reproduction_ok else None,
            "negative_controls_errors": negative_failures,
            "reviews": relation_counts, "agent_reviewed": review_counts.get("agent_reviewed", 0),
            "pending_semantic_reviews": review_counts.get("pending_review", 0),
            "included_without_claim": len(included_without_claim),
            "scientific_debt": ["C.thm:appD-ibragimov", "C.thm:appD-gordin"],
        })
        if all(v == "PASS" for v in cases.values()) and all(v == "PASS" for v in gates.values()):
            status = "PASS"
    except Exception as error:
        summary["errors"].append(type(error).__name__ + ": " + str(error))
    write_json(out, {"status": status, "cases": cases, "gates": gates,
                     "evidence": evidence, "summary": summary,
                     "claim_review": "repair_acceptance/claim_review.json"})
    print(json.dumps({"status": status, "cases": cases, "gates": gates}, ensure_ascii=False))
    return 0 if status == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
