//! Pruebas del checker F2 contra el catálogo de aceptación
//! (docs/08_ACEPTACION.md + acceptance/cases.json).
//!
//! Subconjunto APLICABLE a F2 (checker sin adaptadores): P01–P07 —con
//! P01–P05 como fixtures estructurales; su vínculo Lean real llega en F3—
//! y N01, N02, N03, N04, N05, N06, N07, N08, N10, N11, N12, N18, N19.
//! Los casos restantes (Lean vivo, GLM/replay, Typst, ASPIC+) son puertas
//! de F3–F6 y aquí se declaran fuera de alcance, no pasados por alto.

use argumentos::check::{check, spec_hash, CheckInput, Decision, Rejection};
use argumentos::model::{
    Availability, Claim, ClaimKind, EvidenceKind, EvidenceSpec, Expression, Kernel, Rule,
};
use argumentos::receipt::{Receipt, Termination, TrustMode};
use std::collections::BTreeMap;

// --- Constructores de fixtures ----------------------------------------------

fn claim(
    id: &str,
    kind: ClaimKind,
    expr: Expression,
    scope: &[(&str, &str)],
    assumptions: &[&str],
) -> Claim {
    Claim {
        id: id.into(),
        book_key: None,
        kind,
        statement: format!("{} — fixture", id),
        expression: expr,
        scope: scope
            .iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect(),
        assumptions: assumptions.iter().map(|s| s.to_string()).collect(),
    }
}

fn atom(id: &str) -> Expression {
    Expression::Atom { id: id.into() }
}

fn implies(a: Expression, b: Expression) -> Expression {
    Expression::Implies {
        antecedent: Box::new(a),
        consequent: Box::new(b),
    }
}

fn spec(
    id: &str,
    kind: EvidenceKind,
    claim_id: &str,
    target: &str,
    scope: &[(&str, &str)],
    availability: Availability,
) -> EvidenceSpec {
    EvidenceSpec {
        id: id.into(),
        kind,
        claim_id: claim_id.into(),
        runner_id: match kind {
            EvidenceKind::Lean => "lean-export",
            EvidenceKind::Python => "python-experiment",
        }
        .into(),
        target: target.into(),
        scope: scope
            .iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect(),
        availability,
    }
}

fn argument(
    id: &str,
    conclusion: &str,
    premises: &[&str],
    rule: Rule,
    specs: &[&str],
) -> argumentos::model::Argument {
    argumentos::model::Argument {
        id: id.into(),
        conclusion: conclusion.into(),
        premises: premises.iter().map(|s| s.to_string()).collect(),
        rule,
        evidence_specs: specs.iter().map(|s| s.to_string()).collect(),
    }
}

fn kernel(
    claims: Vec<Claim>,
    args: Vec<argumentos::model::Argument>,
    specs: Vec<EvidenceSpec>,
) -> Kernel {
    Kernel {
        schema_version: "1.0".into(),
        claims,
        arguments: args,
        evidence_specs: specs,
    }
}

/// Recibo válido y reproducido localmente para `spec`.
fn recibo(spec: &EvidenceSpec) -> Receipt {
    Receipt {
        schema_version: "1.0".into(),
        id: format!("R.{}", spec.id),
        spec_id: spec.id.clone(),
        spec_hash: spec_hash(spec),
        source_commit: "fixture".into(),
        environment_hash: "e".repeat(64),
        checker_version: "0.1.0".into(),
        command_argv: vec!["runner".into()],
        working_directory: ".".into(),
        input_hashes: BTreeMap::new(),
        started_at: "t0".into(),
        finished_at: "t1".into(),
        exit_status: Some(0),
        termination: Termination::Completed,
        stdout_sha256: "a".repeat(64),
        stderr_sha256: "b".repeat(64),
        artifacts: vec![],
        execution_passed: true,
        scientific_criterion_met: Some(true),
        observed_checks: vec![],
        trust_mode: TrustMode::LocallyReproduced,
    }
}

fn report_of(k: &Kernel, receipts: &[Receipt]) -> argumentos::check::CheckReport {
    check(&CheckInput {
        kernel: k,
        receipts,
    })
}

const AXIOMAS_STD: &str = "propext,Classical.choice,Quot.sound";

#[test]
fn c01_composition_without_receipt() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let q = claim("Q", ClaimKind::Formal, atom("q"), &[], &[]);
    let pq = claim(
        "PQ",
        ClaimKind::Formal,
        Expression::And {
            items: vec![atom("p"), atom("q")],
        },
        &[],
        &[],
    );
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "PQ",
        "pq",
        &[],
        Availability::Pending,
    );
    let a = argument("A", "PQ", &["P", "Q"], Rule::AndIntro, &["E"]);
    let k = kernel(vec![p, q, pq], vec![a], vec![e]);
    let r = report_of(&k, &[]);
    assert!(!matches!(r.results["A"].decision, Decision::Accepted));
    assert_ne!(
        r.results["A"].formal,
        argumentos::check::FormalState::LeanChecked
    );
}

#[test]
fn c02_alias_without_receipt() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let q = claim("Q", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "Q",
        "q",
        &[],
        Availability::Pending,
    );
    let a = argument("A", "Q", &["P"], Rule::AliasExact, &["E"]);
    let k = kernel(vec![p, q], vec![a], vec![e]);
    assert!(!matches!(
        report_of(&k, &[]).results["A"].decision,
        Decision::Accepted
    ));
}

#[test]
fn c03_modus_ponens_without_receipt() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let imp = claim(
        "I",
        ClaimKind::Formal,
        implies(atom("p"), atom("q")),
        &[],
        &[],
    );
    let q = claim("Q", ClaimKind::Formal, atom("q"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "Q",
        "q",
        &[],
        Availability::Pending,
    );
    let a = argument("A", "Q", &["P", "I"], Rule::ModusPonens, &["E"]);
    let k = kernel(vec![p, imp, q], vec![a], vec![e]);
    assert!(!matches!(
        report_of(&k, &[]).results["A"].decision,
        Decision::Accepted
    ));
}

#[test]
fn c06_duplicate_receipts_permutation() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "p",
        &[("lean_axioms", AXIOMAS_STD)],
        Availability::Candidate,
    );
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let good = recibo(&e);
    let mut bad = good.clone();
    bad.id = "R.other".into();
    bad.execution_passed = false;
    bad.exit_status = Some(1);
    let k = kernel(vec![p], vec![a], vec![e]);
    let first = report_of(&k, &[good.clone(), bad.clone()]);
    let second = report_of(&k, &[bad, good]);
    assert_eq!(first.results["A"].decision, second.results["A"].decision);
}

fn recibo_con_proveniencia(spec: &EvidenceSpec) -> Receipt {
    let mut r = recibo(spec);
    r.source_commit = "a".repeat(40);
    r.input_hashes.insert("fixture".into(), "f".repeat(64));
    r.observed_checks.push(argumentos::receipt::ObservedCheck {
        id: match spec.kind {
            EvidenceKind::Lean => "lean_provenance".into(),
            EvidenceKind::Python => "criterion".into(),
        },
        status: argumentos::receipt::CheckStatus::Pass,
        detail: "fixture aceptable".into(),
    });
    r
}

#[test]
fn c04_invalidacion_en_cadena_y_conservacion_del_diamante() {
    let p = claim("P", ClaimKind::Formal, atom("x"), &[], &[]);
    let q = claim("Q", ClaimKind::Formal, atom("x"), &[], &[]);
    let r = claim("R", ClaimKind::Formal, atom("x"), &[], &[]);
    let ep = spec(
        "E.P",
        EvidenceKind::Lean,
        "P",
        "P",
        &[],
        Availability::Candidate,
    );
    let ap = argument("A.P", "P", &[], Rule::LeanAnchor, &["E.P"]);
    let aq = argument("A.Q", "Q", &["P"], Rule::AliasExact, &[]);
    let ar = argument("A.R", "R", &["Q"], Rule::AliasExact, &[]);
    let k = kernel(vec![p, q, r], vec![ap, aq, ar.clone()], vec![ep.clone()]);
    let mut old = recibo_con_proveniencia(&ep);
    old.spec_hash = "0".repeat(64);
    let out = report_of(&k, &[old]);
    assert!(matches!(
        out.results["A.P"].decision,
        Decision::Rejected { .. }
    ));
    assert!(matches!(
        out.results["A.Q"].decision,
        Decision::Rejected { .. }
    ));
    assert!(matches!(
        out.results["A.R"].decision,
        Decision::Rejected { .. }
    ));

    // Diamante: Q tiene una segunda prueba válida, que impide contaminar R.
    let eq = spec(
        "E.Q",
        EvidenceKind::Lean,
        "Q",
        "Q",
        &[],
        Availability::Candidate,
    );
    let aq_alt = argument("A.Q.alt", "Q", &[], Rule::LeanAnchor, &["E.Q"]);
    let k_d = kernel(
        vec![
            claim("P", ClaimKind::Formal, atom("x"), &[], &[]),
            claim("Q", ClaimKind::Formal, atom("x"), &[], &[]),
            claim("R", ClaimKind::Formal, atom("x"), &[], &[]),
        ],
        vec![
            argument("A.P", "P", &[], Rule::LeanAnchor, &["E.P"]),
            argument("A.Q", "Q", &["P"], Rule::AliasExact, &[]),
            aq_alt,
            ar,
        ],
        vec![ep, eq.clone()],
    );
    let mut stale = recibo_con_proveniencia(&k_d.evidence_specs[0]);
    stale.spec_hash = "0".repeat(64);
    let out = report_of(&k_d, &[stale, recibo_con_proveniencia(&eq)]);
    assert!(matches!(
        out.results["A.Q"].decision,
        Decision::Rejected { .. }
    ));
    assert_eq!(out.results["A.Q.alt"].decision, Decision::Accepted);
    assert!(matches!(
        out.results["A.R"].decision,
        Decision::AcceptedConditional { .. }
    ));
}

#[test]
fn c05_criterio_negativo_no_promueve_afirmacion_positiva() {
    let positive = claim("C.POS", ClaimKind::Empirical, atom("positive"), &[], &[]);
    let e = spec(
        "E.EXP",
        EvidenceKind::Python,
        "C.POS",
        "experiment",
        &[],
        Availability::Candidate,
    );
    let a = argument("A.EXP", "C.POS", &[], Rule::EmpiricalRecord, &["E.EXP"]);
    let k = kernel(vec![positive], vec![a], vec![e.clone()]);
    let mut negative = recibo_con_proveniencia(&e);
    negative.scientific_criterion_met = Some(false);
    assert!(matches!(
        report_of(&k, &[negative]).results["A.EXP"].decision,
        Decision::Rejected {
            reason: Rejection::EmpiricalPromotion
        }
    ));
}

#[test]
fn c05_resultado_negativo_respalda_su_afirmacion_acotada() {
    let scope = [("claim_polarity", "negative")];
    let negative = claim(
        "C.NEG",
        ClaimKind::Empirical,
        atom("bounded_negative"),
        &scope,
        &[],
    );
    let e = spec(
        "E.NEG",
        EvidenceKind::Python,
        "C.NEG",
        "experiment",
        &scope,
        Availability::Candidate,
    );
    let a = argument("A.NEG", "C.NEG", &[], Rule::EmpiricalRecord, &["E.NEG"]);
    let k = kernel(vec![negative], vec![a], vec![e.clone()]);
    let mut r = recibo_con_proveniencia(&e);
    r.scientific_criterion_met = Some(false);
    assert_eq!(
        report_of(&k, &[r]).results["A.NEG"].decision,
        Decision::Accepted
    );
}

#[test]
fn c06_dos_recibos_validos_contradictorios_son_ambiguos() {
    let c = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "p",
        &[],
        Availability::Candidate,
    );
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let k = kernel(vec![c], vec![a], vec![e.clone()]);
    let good = recibo_con_proveniencia(&e);
    let mut other = good.clone();
    other.id = "R.other".into();
    other.stdout_sha256 = "0".repeat(64);
    let first = report_of(&k, &[good.clone(), other.clone()]);
    let second = report_of(&k, &[other, good]);
    assert!(matches!(
        first.results["A"].decision,
        Decision::Pending { .. }
    ));
    assert_eq!(first.results["A"].decision, second.results["A"].decision);
}

#[test]
fn c07_json_importado_es_no_confiable_por_defecto() {
    let c = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "p",
        &[],
        Availability::Candidate,
    );
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let k = kernel(vec![c], vec![a], vec![e.clone()]);
    let local = recibo_con_proveniencia(&e);
    let text = serde_json::to_string(&local).unwrap();
    let imported = argumentos::receipt::receipt_from_str(&text).unwrap();
    assert_eq!(imported.trust_mode, TrustMode::UntrustedImport);
    assert!(matches!(
        report_of(&k, &[imported]).results["A"].decision,
        Decision::Pending { .. }
    ));
}

#[test]
fn c08_cambiar_spec_invalida_el_recibo() {
    let c = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "p",
        &[],
        Availability::Candidate,
    );
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let r = recibo_con_proveniencia(&e);
    let mut changed = e.clone();
    changed.target = "otra_declaracion_con_otro_tipo".into();
    let k = kernel(vec![c], vec![a], vec![changed]);
    assert!(matches!(
        report_of(&k, &[r]).results["A"].decision,
        Decision::Rejected {
            reason: Rejection::StaleEvidence { .. }
        }
    ));
}

#[test]
fn c11_alcance_sin_clave_y_obligaciones_abiertas_no_desaparecen() {
    let c = claim(
        "P",
        ClaimKind::Formal,
        atom("p"),
        &[("domain", "finite")],
        &["H"],
    );
    let h = claim("H", ClaimKind::Factual, atom("h"), &[], &[]);
    let e = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "p",
        &[],
        Availability::Candidate,
    );
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let k = kernel(vec![c.clone(), h], vec![a], vec![e.clone()]);
    let r = recibo_con_proveniencia(&e);
    assert!(matches!(
        report_of(&k, &[r]).results["A"].decision,
        Decision::Rejected {
            reason: Rejection::ScopeMismatch { .. }
        }
    ));

    let apply = argument("A.apply", "P", &[], Rule::LeanApply, &["E"]);
    let valid_spec = spec(
        "E",
        EvidenceKind::Lean,
        "P",
        "P",
        &[("domain", "finite")],
        Availability::Candidate,
    );
    let k_apply = kernel(
        vec![c, claim("H", ClaimKind::Factual, atom("h"), &[], &[])],
        vec![apply],
        vec![valid_spec.clone()],
    );
    let r_apply = recibo_con_proveniencia(&valid_spec);
    match &report_of(&k_apply, &[r_apply]).results["A.apply"].decision {
        Decision::AcceptedConditional { open } => assert!(open.contains(&"H".to_string())),
        other => panic!("obligación abierta perdida: {other:?}"),
    }
}

#[test]
fn f10_modulo_hac_activo_no_desaparece_del_runner() {
    let script = std::fs::read_to_string(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../verificacion_lean/verificar.sh"
    ))
    .unwrap();
    assert!(
        script.contains("Book/ApendiceDHac_m1.lean"),
        "el módulo HAC debe estar ejecutado o registrado como archivo: ver F10"
    );
}
