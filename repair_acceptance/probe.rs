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
    let pq = claim("PQ", ClaimKind::Formal, Expression::And { items: vec![atom("p"), atom("q")] }, &[], &[]);
    let e = spec("E", EvidenceKind::Lean, "PQ", "pq", &[], Availability::Pending);
    let a = argument("A", "PQ", &["P", "Q"], Rule::AndIntro, &["E"]);
    let k = kernel(vec![p,q,pq], vec![a], vec![e]);
    let r = report_of(&k, &[]);
    assert!(!matches!(r.results["A"].decision, Decision::Accepted));
    assert_ne!(r.results["A"].formal, argumentos::check::FormalState::LeanChecked);
}

#[test]
fn c02_alias_without_receipt() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let q = claim("Q", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec("E", EvidenceKind::Lean, "Q", "q", &[], Availability::Pending);
    let a = argument("A", "Q", &["P"], Rule::AliasExact, &["E"]);
    let k = kernel(vec![p,q], vec![a], vec![e]);
    assert!(!matches!(report_of(&k,&[]).results["A"].decision, Decision::Accepted));
}

#[test]
fn c03_modus_ponens_without_receipt() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let imp = claim("I", ClaimKind::Formal, implies(atom("p"),atom("q")), &[], &[]);
    let q = claim("Q", ClaimKind::Formal, atom("q"), &[], &[]);
    let e = spec("E", EvidenceKind::Lean, "Q", "q", &[], Availability::Pending);
    let a = argument("A", "Q", &["P","I"], Rule::ModusPonens, &["E"]);
    let k = kernel(vec![p,imp,q], vec![a], vec![e]);
    assert!(!matches!(report_of(&k,&[]).results["A"].decision, Decision::Accepted));
}

#[test]
fn c06_duplicate_receipts_permutation() {
    let p = claim("P", ClaimKind::Formal, atom("p"), &[], &[]);
    let e = spec("E", EvidenceKind::Lean, "P", "p", &[("lean_axioms", AXIOMAS_STD)], Availability::Candidate);
    let a = argument("A", "P", &[], Rule::LeanAnchor, &["E"]);
    let good = recibo(&e);
    let mut bad = good.clone();
    bad.id = "R.other".into();
    bad.execution_passed = false;
    bad.exit_status = Some(1);
    let k = kernel(vec![p], vec![a], vec![e]);
    let first = report_of(&k, &[good.clone(),bad.clone()]);
    let second = report_of(&k, &[bad,good]);
    assert_eq!(first.results["A"].decision, second.results["A"].decision);
}
