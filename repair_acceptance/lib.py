"""Corpus comparison separated from automatic collection and review status."""
import hashlib
import json
import pathlib
import re

DEBT = {"C.thm:appD-gordin", "C.thm:appD-ibragimov"}


def sha256_text(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def scope_classification(block, claim_keys):
    """Enforce explicit editorial coverage; an unknown kind is not excluded."""
    if block["key"] in claim_keys:
        return {"key": block["key"], "file": block["file"],
                "state": "present", "rationale": "claim vigente visible en el kernel"}
    if block["kind"] in {"definition", "note", "problem"}:
        return {"key": block["key"], "file": block["file"],
                "state": "excluded_editorial", "classification": "editorial_support",
                "rationale": "Definición/nota/problema de contexto: no es un objetivo del plan con una proposición que el libro deba demostrar. No se convierte en claim ni se borra; no computa como cierre matemático."}
    if block["kind"] in {"theorem", "proposition", "lemma", "corollary", "example", "assumption"}:
        return {"key": block["key"], "file": block["file"],
                "state": "included_pending", "classification": "formal_objective_pending",
                "rationale": "Objeto matemático sin claim vigente: debe permanecer visible como objetivo pendiente, no ser eliminado para mejorar cobertura"}
    return {"key": block["key"], "file": block["file"],
            "state": "unclassified", "classification": None,
            "rationale": "Tipo de bloque no clasificado; la puerta debe fallar"}


def build_corpus(repo, kernel, book_inventory, targets, semantic_file=None):
    semantic_file = semantic_file or (repo / "repair_acceptance/semantic_reviews.json")
    semantic = json.loads(semantic_file.read_text(encoding="utf-8"))
    validated = {r["claim_id"]: r for r in semantic["revisiones"]}
    blocks = {b["key"]: b for b in book_inventory["blocks"]}
    book = repo / "book_stat_inference_v0"
    by_claim = {}
    for a in kernel["arguments"]:
        by_claim.setdefault(a["conclusion"], []).append(a)
    specs = {s["id"]: s for s in kernel["evidence_specs"]}
    rows = []
    for claim in kernel["claims"]:
        key = claim.get("book_key")
        block = blocks.get(key)
        if key and not key.startswith("der:") and block is None:
            raise ValueError(f"Clave no resoluble en fuente: {claim['id']} -> {key}")
        source = None
        excerpt = None
        if block:
            source = {k: block[k] for k in ["file", "kind", "name", "content_start", "content_end", "file_sha256"]}
            excerpt = (book / block["file"]).read_bytes()[block["content_start"]:block["content_end"]].decode("utf-8", errors="replace")
        my_args = by_claim.get(claim["id"], [])
        target_rows = []
        for arg in my_args:
            for sid in arg["evidence_specs"]:
                spec = specs[sid]
                target = targets.get(spec["target"])
                if target is None:
                    raise ValueError(f"Objetivo no encontrado: {spec['target']}")
                target_rows.append({
                    "argument_id": arg["id"], "spec_id": sid, "declared_target": spec["target"],
                    "target_scope": spec["scope"], "lean_type": target["type"],
                    "type_sha256": sha256_text(target["type"]), "axioms": target["axioms"],
                    "dependencies": target["dependencies"],
                })
        review = validated.get(claim["id"])
        if review:
            relation = review["relation"]
            status = "agent_reviewed"
            note = review["justificacion"]
            limitation = review["limitacion"]
            reviewed_at = review.get("reviewed_at", semantic["reviewed_at"])
        else:
            # Honest pending outcome, never an automatically inferred partial.
            relation = "pending"
            status = "pending_review"
            statement = claim["statement"]
            note = f"Evaluación semántica no realizada para {claim['id']}: se expone «{statement}» junto al pasaje y tipo elaborado, sin aprobar equivalencia ni inferirla del respaldo."
            limitation = "Revisión pendiente: la recolección automática no mide coincidencia matemática de conclusión, hipótesis o cuantificadores."
            reviewed_at = None
        if claim["id"] in DEBT and relation != "pending":
            raise ValueError(f"La deuda {claim['id']} no puede cerrarse como {relation}")
        rows.append({
            "claim_id": claim["id"], "book_key": key, "kind": claim["kind"],
            "statement": claim["statement"], "hypotheses": claim["assumptions"],
            "scope": claim["scope"], "domain": claim["scope"].get("domain"),
            "source": source, "source_excerpt": excerpt,
            "lean_declarations": target_rows,
            "quantifier_and_conclusion_review": [
                {"argument_id": t["argument_id"], "lean_type": t["lean_type"],
                 "hypotheses": claim["assumptions"], "expression": claim["expression"]}
                for t in target_rows
            ],
            "relation": relation, "review_status": status,
            "justification": note, "limitation": limitation,
            "review_provenance": {"at": reviewed_at, "reviewer": semantic["reviewer"] if reviewed_at else None},
            "collection_is_not_semantic_review": True,
        })
    keys = {c.get("book_key") for c in kernel["claims"] if c.get("book_key")}
    coverage = [scope_classification(b, keys) for b in book_inventory["blocks"]]
    return rows, coverage


def semantic_gate(rows, coverage):
    bad_relation = [r["claim_id"] for r in rows if r["relation"] not in {"exact", "partial", "auxiliary", "pending"}]
    bad_review = [r["claim_id"] for r in rows if not r["justification"] or not r["limitation"] or not r["collection_is_not_semantic_review"]]
    bad_provenance = [r["claim_id"] for r in rows if r["review_status"] == "agent_reviewed" and not r["review_provenance"]["at"]]
    bad_target = [r["claim_id"] for r in rows if r["relation"] in {"exact", "partial", "auxiliary"} and not r["lean_declarations"]]
    bad_scope = [c["key"] for c in coverage if c["state"] == "unclassified"]
    return not (bad_relation or bad_review or bad_provenance or bad_target or bad_scope)


def module_sources(script_text):
    listed = set(re.findall(r"Book/([A-Za-z0-9_]+)\.lean", script_text.split("for mod in ", 1)[1].split("; do", 1)[0]))
    return listed | {"Foundation"}


def axiom_probe_errors(output):
    bad = []
    for line in output.splitlines():
        if "depends on axioms:" in line:
            m = re.search(r"depends on axioms:\s*\[(.*?)\]", line)
            if m:
                bad.extend(x.strip() for x in m.group(1).split(",") if x.strip() not in {"propext", "Classical.choice", "Quot.sound"})
        if "declaration uses `sorry`" in line:
            bad.append("sorry used")
    return bad


def required_input_paths(spec):
    if spec["kind"] == "lean":
        return {"argumentos/evidence/lean_export.lean", "verificacion_lean/verificar.sh"} | {"verificacion_lean/Book/" + p.name for p in pathlib.Path("verificacion_lean/Book").glob("*.lean")}
    return {"argumentos/runners/ssch_bayes_racional.py"}


def required_inputs_present(receipt, spec, repo=None):
    paths = required_input_paths(spec)
    if spec["kind"] == "lean" and repo is not None:
        paths = {"argumentos/evidence/lean_export.lean", "verificacion_lean/verificar.sh"} | {"verificacion_lean/Book/" + p.name for p in (repo / "verificacion_lean/Book").glob("*.lean")}
    return bool(receipt["input_hashes"]) and all(p in receipt["input_hashes"] for p in paths)
