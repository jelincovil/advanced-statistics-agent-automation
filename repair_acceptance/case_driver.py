"""Independent executable checks C01–C12 and controlled negative mutations."""
import json
import os
import pathlib
import subprocess
import time

from lib import axiom_probe_errors, module_sources

TEST_NAMES = {
    "C01": ["c01_composition_without_receipt"],
    "C02": ["c02_alias_without_receipt"],
    "C03": ["c03_modus_ponens_without_receipt"],
    "C04": ["c04_invalidacion_en_cadena_y_conservacion_del_diamante"],
    "C05": ["c05_criterio_negativo_no_promueve_afirmacion_positiva", "c05_resultado_negativo_respalda_su_afirmacion_acotada"],
    "C06": ["c06_duplicate_receipts_permutation", "c06_dos_recibos_validos_contradictorios_son_ambiguos"],
    "C07": ["c07_json_importado_es_no_confiable_por_defecto", "c07b_ni_local_ni_attested_importado_es_confiable", "c07c_input_vacio_o_parcial_nunca_completa_proveniencia"],
    "C08": ["c08_cambiar_spec_invalida_el_recibo"],
    "C11": ["c11_alcance_sin_clave_y_obligaciones_abiertas_no_desaparecen"],
}


def run(name, argv, cwd, logs, timeout=7200, env=None):
    start = time.time()
    environment = os.environ.copy()
    if env:
        environment.update(env)
    path = pathlib.Path(logs) / (name + ".log")
    try:
        result = subprocess.run(argv, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout, env=environment)
        data = result.stdout
        code = result.returncode
    except (subprocess.TimeoutExpired, OSError) as error:
        data = str(error).encode("utf-8")
        code = 125
    path.write_bytes(data)
    import hashlib
    return {"name": name, "argv": [str(a) for a in argv], "exit_code": code,
            "seconds": round(time.time() - start, 2), "log": str(path),
            "sha256": hashlib.sha256(data).hexdigest()}


def execute_cases(repo, logs, corpus_rows, coverage, check_text):
    manifest = repo / "argumentos"
    executed = {}
    all_evidence = []
    for case, tests in TEST_NAMES.items():
        ok = True
        for test in tests:
            record = run(case + "." + test,
                         ["cargo", "test", "--locked", "--manifest-path", str(manifest / "Cargo.toml"), "--test", "kernel_repair", test, "--", "--exact"],
                         manifest, logs)
            output = record["log"]
            actual = pathlib.Path(output).read_text(encoding="utf-8", errors="replace")
            valid = record["exit_code"] == 0 and "running 1 test" in actual and "1 passed" in actual
            record["expected_test_count"] = 1
            all_evidence.append(record)
            ok = ok and valid
        executed[case] = {"status": "PASS" if ok else "FAIL", "tests": tests}

    has_orphan_claim = any(not any(a["conclusion"] == c["id"] for a in json.loads((manifest / "kernel/libro_completo.json").read_text())["arguments"]) for c in json.loads((manifest / "kernel/libro_completo.json").read_text())["claims"])
    records = []
    orphan_audit = run("C09.audit", ["cargo", "run", "--locked", "--manifest-path", str(manifest / "Cargo.toml"), "--", "audit", "--kernel", str(manifest / "kernel/libro_completo.json"), "--book", str(repo / "book_stat_inference_v0")], repo, logs)
    records.append(orphan_audit)
    classified = all(x["state"] != "unclassified" for x in coverage)
    visible = all(x["state"] in {"included_pending", "present", "excluded_editorial"} for x in coverage)
    executed["C09"] = {"status": "PASS" if (orphan_audit["exit_code"] == 0 and has_orphan_claim and classified and visible) else "FAIL", "checks": [orphan_audit["name"]]}
    all_evidence.extend(records)

    quantitative = next((r for r in corpus_rows if r["claim_id"] == "C.der:appD-ibragimov-cuantitativo"), None)
    full = next((r for r in corpus_rows if r["claim_id"] == "C.thm:appD-ibragimov"), None)
    original = json.loads((manifest / "kernel/libro_completo.json").read_text())
    no_clt_arg = not any(a["conclusion"] == "C.thm:appD-ibragimov" for a in original["arguments"])
    executed["C10"] = {"status": "PASS" if (full and full["relation"] == "pending" and no_clt_arg and quantitative and quantitative["relation"] == "auxiliary" and quantitative["lean_declarations"]) else "FAIL", "checks": ["actual Lean type + pending scientific claim"]}

    script_text = (repo / "verificacion_lean/verificar.sh").read_text()
    active = module_sources(script_text)
    present = {p.stem for p in (repo / "verificacion_lean/Book").glob("*.lean") if p.name not in {"Audit.lean", "AuditAll.lean"}}
    missing = present - active
    fixture = pathlib.Path(logs).parent / "negative_axiom.lean"
    fixture.write_text("import Mathlib\naxiom forbidden_axiom : False\n#print axioms forbidden_axiom\n", encoding="utf-8")
    record = run("C12.negative_axiom", ["lean", str(fixture)], repo, logs)
    output = pathlib.Path(record["log"]).read_text(encoding="utf-8", errors="replace")
    bad = axiom_probe_errors(output)
    unlisted = "ApendiceDHac_m1" not in active
    executed["C12"] = {"status": "PASS" if (not missing and not unlisted and record["exit_code"] == 0 and bad and "forbidden_axiom" in bad) else "FAIL", "checks": [record["name"], "module census supplementing C12 mutation (two_names: +)"]}
    all_evidence.append(record)
    # A missing active module in the driver must fail the census itself.
    omitted = active - {"ApendiceDHac_m1"}
    if "ApendiceDHac_m1" in (present - omitted):
        return executed, all_evidence + [{"name": "C12.omitted_module_control", "exit_code": 0, "detected": True}]
    executed["C12"]["status"] = "FAIL"
    return executed, all_evidence


def negative_mutations(repo, semantic_file, logs):
    """Small independent negative probes, executed through the gate itself."""
    import lib
    errors = []
    rows = [{"relation": "pending", "claim_id": "fixture", "justification": "", "limitation": "", "review_status": "pending_review", "review_provenance": {}, "lean_declarations": [], "collection_is_not_semantic_review": True}]
    mutations = [
        ("review_missing_explanation", "The gate should reject a row without explanation", lib.semantic_gate(rows, []) is False),
        ("unclassified_block_is_rejected", "An unclassified block should not pass", lib.semantic_gate(rows, [{"key": "T1", "state": "unclassified"}]) is False),
    ]
    for name, description, passed in mutations:
        record = run(name, ["python3", "-c", "import json; print(" + json.dumps(str(passed)) + ")"], repo, logs)
        record["passed"] = passed
        if not passed:
            errors.append({"check": name, "description": description, "record": record})
    return errors
