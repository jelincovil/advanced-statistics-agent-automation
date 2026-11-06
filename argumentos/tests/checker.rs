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

// --- P01–P05: piloto matemático (estructural; el vínculo Lean vivo es F3) ---

/// P01: ch9_isomorfismo — igualdad exacta y alcance FINITO registrado,
/// nunca full_statement_verified.
#[test]
fn p01_isomorfismo_lean_anchor_con_alcance_finito() {
    let c = claim(
        "C.iso",
        ClaimKind::Formal,
        atom("iso.eq"),
        &[("domain", "finite"), ("statement_scope", "exact_equality")],
        &[],
    );
    let e = spec(
        "E.iso",
        EvidenceKind::Lean,
        "C.iso",
        "ch9_isomorfismo",
        &[
            ("domain", "finite"),
            ("statement_scope", "exact_equality"),
            ("lean_axioms", AXIOMAS_STD),
        ],
        Availability::Pending,
    );
    let a = argument("A.iso", "C.iso", &[], Rule::LeanAnchor, &["E.iso"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    let res = &r.results["A.iso"];
    assert_eq!(res.decision, Decision::Accepted);
    assert_eq!(res.formal, argumentos::check::FormalState::LeanChecked);
    // El alcance queda registrado como especialización finita.
    assert_eq!(res.scope.get("domain").map(String::as_str), Some("finite"));
    assert_eq!(
        res.scope.get("statement_scope").map(String::as_str),
        Some("exact_equality")
    );
}

/// P02: ch9_bayes — igualdad ponderada verificada; el conjunto de
/// optimizadores NO se afirma sin wrapper adicional (queda sin argumento).
#[test]
fn p02_bayes_sin_afirmar_optimizadores() {
    let c_eq = claim(
        "C.bayes.eq",
        ClaimKind::Formal,
        atom("bayes.eq"),
        &[("domain", "finite")],
        &[],
    );
    let c_opt = claim(
        "C.bayes.optimizers",
        ClaimKind::Formal,
        atom("bayes.opt"),
        &[("domain", "finite")],
        &[],
    );
    let e = spec(
        "E.bayes",
        EvidenceKind::Lean,
        "C.bayes.eq",
        "ch9_bayes",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Pending,
    );
    let a = argument("A.bayes", "C.bayes.eq", &[], Rule::LeanAnchor, &["E.bayes"]);
    let k = kernel(vec![c_eq, c_opt], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    assert_eq!(r.results["A.bayes"].decision, Decision::Accepted);
    // No existe argumento por el conjunto de optimizadores: el checker no
    // lo declara verificado por proximidad.
    assert!(!r.results.contains_key("A.optimizers"));
    assert_eq!(r.results.len(), 1);
}

/// P03: ch9_admisibilidad — dominancia par a par; el alcance registra esa
/// forma y no la eleva a admisibilidad cuantificada.
#[test]
fn p03_admisibilidad_dominancia_par_a_par() {
    let expr = implies(atom("dominates"), atom("return_dominates"));
    let c = claim(
        "C.adm",
        ClaimKind::Formal,
        expr,
        &[
            ("domain", "finite"),
            ("statement_scope", "pairwise_dominance"),
        ],
        &[],
    );
    let e = spec(
        "E.adm",
        EvidenceKind::Lean,
        "C.adm",
        "ch9_admisibilidad",
        &[
            ("domain", "finite"),
            ("statement_scope", "pairwise_dominance"),
            ("lean_axioms", AXIOMAS_STD),
        ],
        Availability::Pending,
    );
    let a = argument("A.adm", "C.adm", &[], Rule::LeanAnchor, &["E.adm"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    assert_eq!(r.results["A.adm"].decision, Decision::Accepted);
    assert_eq!(
        r.results["A.adm"]
            .scope
            .get("statement_scope")
            .map(String::as_str),
        Some("pairwise_dominance")
    );
}

/// P04: ch7_traduccion — dos teoremas (óptimos y valores) con sus hipótesis
/// Nonempty/Fintype registradas y conservadas como obligaciones.
#[test]
fn p04_traduccion_hipotesis_registradas() {
    let c_val = claim(
        "C.trad.val",
        ClaimKind::Formal,
        atom("trad.valores"),
        &[("domain", "finite")],
        &["H.Nonempty", "H.Fintype"],
    );
    let c_opt = claim(
        "C.trad.opt",
        ClaimKind::Formal,
        atom("trad.optimos"),
        &[("domain", "finite")],
        &["H.Nonempty", "H.Fintype"],
    );
    let e1 = spec(
        "E.trad.val",
        EvidenceKind::Lean,
        "C.trad.val",
        "ch7_traduccion",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Pending,
    );
    let e2 = spec(
        "E.trad.opt",
        EvidenceKind::Lean,
        "C.trad.opt",
        "ch7_traduccion_optimos",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Pending,
    );
    let a1 = argument(
        "A.trad.val",
        "C.trad.val",
        &[],
        Rule::LeanAnchor,
        &["E.trad.val"],
    );
    let a2 = argument(
        "A.trad.opt",
        "C.trad.opt",
        &[],
        Rule::LeanAnchor,
        &["E.trad.opt"],
    );
    let h_nonempty = claim(
        "H.Nonempty",
        ClaimKind::Factual,
        atom("H.Nonempty"),
        &[("domain", "finite")],
        &[],
    );
    let h_fintype = claim(
        "H.Fintype",
        ClaimKind::Factual,
        atom("H.Fintype"),
        &[("domain", "finite")],
        &[],
    );
    let k = kernel(
        vec![c_val, c_opt, h_nonempty, h_fintype],
        vec![a1, a2],
        vec![e1, e2],
    );
    let r = report_of(
        &k,
        &[recibo(&k.evidence_specs[0]), recibo(&k.evidence_specs[1])],
    );
    for id in ["A.trad.val", "A.trad.opt"] {
        let res = &r.results[id];
        assert_eq!(res.decision, Decision::Accepted, "{}", id);
        // Las hipótesis se conservan como obligaciones, no desaparecen.
        assert!(
            res.obligations.contains(&"H.Nonempty".to_string()),
            "{}",
            id
        );
        assert!(res.obligations.contains(&"H.Fintype".to_string()), "{}", id);
    }
}

/// P05: SSCH — riesgo de Bayes 19/50 como registro empírico exacto con
/// recibo reproducido; nunca teorema universal.
#[test]
fn p05_ssch_registro_empirico_acotado() {
    let c = claim(
        "C.ssch.bayes",
        ClaimKind::Empirical,
        atom("ssch.bayes_19_50"),
        &[
            ("domain", "finite"),
            ("experiment", "ssch_enumeracion_racional"),
            ("population", "dos_modelos_sinteticos"),
        ],
        &[],
    );
    let e = spec(
        "E.ssch",
        EvidenceKind::Python,
        "C.ssch.bayes",
        "ssch_bayes_risk",
        &[
            ("domain", "finite"),
            ("experiment", "ssch_enumeracion_racional"),
            ("population", "dos_modelos_sinteticos"),
        ],
        Availability::Pending,
    );
    let a = argument(
        "A.ssch",
        "C.ssch.bayes",
        &[],
        Rule::EmpiricalRecord,
        &["E.ssch"],
    );
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    let res = &r.results["A.ssch"];
    assert_eq!(res.decision, Decision::Accepted);
    assert_eq!(res.empirical, argumentos::check::EmpiricalState::Reproduced);
    // La afirmación queda acotada al experimento: no hay promoción.
    assert_eq!(
        res.scope.get("experiment").map(String::as_str),
        Some("ssch_enumeracion_racional")
    );
}

/// P06: un argumento condicional mantiene TODAS sus obligaciones.
#[test]
fn p06_condicional_mantiene_obligaciones() {
    let c_teo = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo.h"),
        &[("domain", "finite")],
        &["H.identificacion"],
    );
    let c_cond = claim(
        "C.concl.cond",
        ClaimKind::Conditional,
        atom("concl.en_escenario"),
        &[("domain", "finite"), ("escenario", "declarado")],
        &["H.identificacion", "H.escenario"],
    );
    let a = argument(
        "A.cond",
        "C.concl.cond",
        &["C.teo"],
        Rule::ConditionalApplication,
        &[],
    );
    let h_ident = claim(
        "H.identificacion",
        ClaimKind::Factual,
        atom("H.identificacion"),
        &[("domain", "finite")],
        &[],
    );
    let h_esc = claim(
        "H.escenario",
        ClaimKind::Factual,
        atom("H.escenario"),
        &[("domain", "finite")],
        &[],
    );
    let k = kernel(vec![c_teo, c_cond, h_ident, h_esc], vec![a], vec![]);
    let r = report_of(&k, &[]);
    let res = &r.results["A.cond"];
    match &res.decision {
        Decision::AcceptedConditional { open } => {
            // Ninguna hipótesis se elimina por omisión (docs/04).
            assert!(open.contains(&"H.identificacion".to_string()));
            assert!(open.contains(&"H.escenario".to_string()));
            assert_eq!(open.len(), 2);
        }
        other => panic!("esperaba AcceptedConditional, llegó {:?}", other),
    }
}

/// P07: canonicalización reproducible con UTF-8 y orden de conjuntos;
/// permutar el conjunto de entradas no cambia el reporte canónico.
#[test]
fn p07_canonicalizacion_invariante_a_permutacion() {
    let mk = |orden: usize| {
        let c1 = claim(
            "C.α",
            ClaimKind::Formal,
            atom("x.Δ"),
            &[("dominio", "finito_ñ")],
            &[],
        );
        let c2 = claim(
            "C.β",
            ClaimKind::Formal,
            atom("y.Ω"),
            &[("dominio", "finito_ñ")],
            &[],
        );
        let c3 = claim(
            "C.γ",
            ClaimKind::Formal,
            implies(atom("x.Δ"), atom("y.Ω")),
            &[("dominio", "finito_ñ")],
            &[],
        );
        let a = argument("A.mp", "C.γ", &["C.α", "C.β"], Rule::ModusPonens, &[]);
        let mut claims = vec![c1, c2, c3];
        let mut args = vec![a];
        if orden % 2 == 1 {
            claims.reverse();
            args.reverse();
        }
        kernel(claims, args, vec![])
    };
    let r1 = report_of(&mk(0), &[]);
    let r2 = report_of(&mk(1), &[]);
    assert_eq!(
        r1.canonical_hash, r2.canonical_hash,
        "permutar entradas cambió el reporte"
    );
    // UTF-8 preservado en el alcance reportado.
    assert_eq!(
        r1.results["A.mp"].scope.get("dominio").map(String::as_str),
        Some("finito_ñ")
    );
}

// --- N01–N19: mutaciones adversariales --------------------------------------

/// N01: hipótesis omitida — intentar conclusión incondicional con regla
/// condicional se bloquea.
#[test]
fn n01_hipotesis_omitida_bloquea() {
    let c_teo = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo"),
        &[("domain", "finite")],
        &["H.grande"],
    );
    // La conclusión pretendida es FORMAL (incondicional): el salto se bloquea.
    let c_incond = claim(
        "C.incond",
        ClaimKind::Formal,
        atom("concl"),
        &[("domain", "finite")],
        &[],
    );
    let a = argument(
        "A.salto",
        "C.incond",
        &["C.teo"],
        Rule::ConditionalApplication,
        &[],
    );
    let h_grande = claim(
        "H.grande",
        ClaimKind::Factual,
        atom("H.grande"),
        &[("domain", "finite")],
        &[],
    );
    let k = kernel(vec![c_teo, c_incond, h_grande], vec![a], vec![]);
    let r = report_of(&k, &[]);
    match &r.results["A.salto"].decision {
        Decision::Rejected {
            reason: Rejection::KindMismatch { .. },
        } => {}
        other => panic!("esperaba rechazo por kind, llegó {:?}", other),
    }
}

/// N02: signo de conclusión cambiado — la AST exacta no coincide.
#[test]
fn n02_signo_cambiado_rechaza_ast() {
    // MP válido por lo demás: premisas P y Implies(P,Q); la conclusión
    // declara Implies(Q,P) (signo/orden cambiado) en vez de Q.
    let cp = claim(
        "C.P",
        ClaimKind::Formal,
        atom("P"),
        &[("domain", "finite")],
        &[],
    );
    let cpq = claim(
        "C.PQ",
        ClaimKind::Formal,
        implies(atom("P"), atom("Q")),
        &[("domain", "finite")],
        &[],
    );
    let c_mal = claim(
        "C.mal",
        ClaimKind::Formal,
        implies(atom("Q"), atom("P")),
        &[("domain", "finite")],
        &[],
    );
    let a = argument(
        "A.mp.mal",
        "C.mal",
        &["C.P", "C.PQ"],
        Rule::ModusPonens,
        &[],
    );
    let k = kernel(vec![cp, cpq, c_mal], vec![a], vec![]);
    let r = report_of(&k, &[]);
    match &r.results["A.mp.mal"].decision {
        Decision::Rejected {
            reason: Rejection::AstMismatch { .. },
        } => {}
        other => panic!("esperaba AstMismatch, llegó {:?}", other),
    }
}

/// Contraste directo con los fixtures del paquete: el positivo es aceptado
/// en estructura (condicional, sin evidencia aún) y cada negativo es
/// rechazado por la razón que el validador del paquete clasifica.
#[test]
fn fixtures_del_paquete_contrastados_por_el_checker() {
    let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("spec/argumentos_construccion_v1/examples");
    let cargar = |nombre: &str| {
        let k = argumentos::model::load_kernel(&dir.join(nombre))
            .unwrap_or_else(|e| panic!("{} debía cargar: {}", nombre, e));
        report_of(&k, &[])
    };
    // Positivo: estructura válida, pendiente de evidencia.
    let r = cargar("valid_structure_pending.json");
    assert!(matches!(
        r.results["A.Q"].decision,
        Decision::AcceptedConditional { .. }
    ));
    // Negativos con su razón esperada (clasificación del paquete).
    type EsRazon = fn(&Rejection) -> bool;
    let casos: &[(&str, EsRazon)] = &[
        ("invalid_conclusion.json", |r| {
            matches!(r, Rejection::AstMismatch { .. })
        }),
        ("invalid_cycle.json", |r| {
            matches!(r, Rejection::Cycle { .. })
        }),
        ("invalid_empirical_promotion.json", |r| {
            matches!(r, Rejection::EmpiricalPromotion)
        }),
        ("invalid_evidence_target.json", |r| {
            matches!(r, Rejection::UnknownReference { .. })
        }),
        ("invalid_missing_premise.json", |r| {
            matches!(r, Rejection::UnknownReference { .. })
        }),
        ("invalid_scope.json", |r| {
            matches!(r, Rejection::ScopeMismatch { .. })
        }),
    ];
    for (fichero, es_razon) in casos {
        let r = cargar(fichero);
        let res = r
            .results
            .values()
            .next()
            .unwrap_or_else(|| panic!("{} sin resultados", fichero));
        match &res.decision {
            Decision::Rejected { reason } => assert!(
                es_razon(reason),
                "{} rechazado por razón inesperada: {:?}",
                fichero,
                reason
            ),
            other => panic!("{} debía rechazarse, llegó {:?}", fichero, other),
        }
    }
}

/// N03: finito convertido en numerable — el alcance de la evidencia no
/// cubre el de la afirmación.
#[test]
fn n03_finito_a_numerable_rechaza_alcance() {
    let c = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo"),
        &[("domain", "countable")],
        &[],
    );
    let e = spec(
        "E.lean",
        EvidenceKind::Lean,
        "C.teo",
        "teo",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Pending,
    );
    let a = argument("A.teo", "C.teo", &[], Rule::LeanAnchor, &["E.lean"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    match &r.results["A.teo"].decision {
        Decision::Rejected {
            reason: Rejection::ScopeMismatch { clave, .. },
        } => assert_eq!(clave, "domain"),
        other => panic!("esperaba ScopeMismatch, llegó {:?}", other),
    }
}

/// N04: sorryAx o axioma nuevo — la prueba se rechaza.
#[test]
fn n04_sorry_ax_rechaza() {
    let c = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo"),
        &[("domain", "finite")],
        &[],
    );
    let e = spec(
        "E.lean",
        EvidenceKind::Lean,
        "C.teo",
        "teo",
        &[("domain", "finite"), ("lean_axioms", "propext,sorryAx")],
        Availability::Pending,
    );
    let a = argument("A.teo", "C.teo", &[], Rule::LeanAnchor, &["E.lean"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    match &r.results["A.teo"].decision {
        Decision::Rejected {
            reason: Rejection::NonStandardAxioms { axiomas },
        } => assert_eq!(axiomas, &vec!["sorryAx".to_string()]),
        other => panic!("esperaba NonStandardAxioms, llegó {:?}", other),
    }
}

/// N05: hash de evidencia cambiado — stale y nunca estado vigente por
/// arte de magia (propiedad: cambiar evidencia no mantiene el estado).
#[test]
fn n05_hash_cambiado_marca_stale() {
    let c = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo"),
        &[("domain", "finite")],
        &[],
    );
    let e = spec(
        "E.lean",
        EvidenceKind::Lean,
        "C.teo",
        "teo",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Pending,
    );
    let a = argument("A.teo", "C.teo", &[], Rule::LeanAnchor, &["E.lean"]);
    let k = kernel(vec![c], vec![a], vec![e.clone()]);
    // Antes: vigente.
    let r_ok = report_of(&k, &[recibo(&e)]);
    assert_eq!(r_ok.results["A.teo"].decision, Decision::Accepted);
    // Mutación: el recibo declara un hash que no corresponde al spec actual.
    let mut recibo_mutado = recibo(&e);
    recibo_mutado.spec_hash = "0".repeat(64);
    let r_stale = report_of(&k, &[recibo_mutado]);
    let res = &r_stale.results["A.teo"];
    assert!(matches!(
        res.decision,
        Decision::Rejected {
            reason: Rejection::StaleEvidence { .. }
        }
    ));
    assert_eq!(res.formal, argumentos::check::FormalState::Stale);
    assert_eq!(res.empirical, argumentos::check::EmpiricalState::Stale);
}

/// N06: premisa inexistente — la referencia se rechaza.
#[test]
fn n06_premisa_inexistente_rechaza() {
    let c = claim(
        "C.Q",
        ClaimKind::Formal,
        implies(atom("P"), atom("Q")),
        &[("domain", "finite")],
        &[],
    );
    let a = argument("A.mp", "C.Q", &["C.P.fantasma"], Rule::ModusPonens, &[]);
    let k = kernel(vec![c], vec![a], vec![]);
    let r = report_of(&k, &[]);
    match &r.results["A.mp"].decision {
        Decision::Rejected {
            reason: Rejection::UnknownReference { id },
        } => assert_eq!(id, "C.P.fantasma"),
        other => panic!("esperaba UnknownReference, llegó {:?}", other),
    }
}

/// N07: ciclo de soporte — la derivación circular se rechaza.
#[test]
fn n07_ciclo_de_soporte_rechaza() {
    let c1 = claim(
        "C.uno",
        ClaimKind::Formal,
        atom("uno"),
        &[("domain", "finite")],
        &[],
    );
    let c2 = claim(
        "C.dos",
        ClaimKind::Formal,
        atom("dos"),
        &[("domain", "finite")],
        &[],
    );
    let a1 = argument("A.1", "C.uno", &["C.dos"], Rule::AliasExact, &[]);
    let a2 = argument("A.2", "C.dos", &["C.uno"], Rule::AliasExact, &[]);
    let k = kernel(vec![c1, c2], vec![a1, a2], vec![]);
    let r = report_of(&k, &[]);
    for id in ["A.1", "A.2"] {
        assert!(
            matches!(
                &r.results[id].decision,
                Decision::Rejected {
                    reason: Rejection::Cycle { .. }
                }
            ),
            "{}",
            id
        );
    }
}

/// N08: simulación promovida a teorema universal — rechazo de la promoción.
#[test]
fn n08_simulacion_a_teorema_rechaza() {
    // La afirmación pretende ser FORMAL (un teorema) respaldada por un
    // registro empírico: promoción prohibida.
    let c = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("efecto.universal"),
        &[("domain", "general")],
        &[],
    );
    let e = spec(
        "E.sim",
        EvidenceKind::Python,
        "C.teo",
        "simulacion",
        &[("domain", "general")],
        Availability::Pending,
    );
    let a = argument("A.sim", "C.teo", &[], Rule::EmpiricalRecord, &["E.sim"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    let r = report_of(&k, &[recibo(&k.evidence_specs[0])]);
    match &r.results["A.sim"].decision {
        Decision::Rejected {
            reason: Rejection::EmpiricalPromotion,
        } => {}
        other => panic!("esperaba EmpiricalPromotion, llegó {:?}", other),
    }
}

/// N10: modelo se autoaprueba — un spec "candidate" sin recibo no aprueba
/// nada; el estado verificado no se acepta de un campo.
#[test]
fn n10_autoaprobacion_no_aprueba() {
    let c = claim(
        "C.teo",
        ClaimKind::Formal,
        atom("teo"),
        &[("domain", "finite")],
        &[],
    );
    let e = spec(
        "E.lean",
        EvidenceKind::Lean,
        "C.teo",
        "teo",
        &[("domain", "finite"), ("lean_axioms", AXIOMAS_STD)],
        Availability::Candidate,
    );
    let a = argument("A.teo", "C.teo", &[], Rule::LeanAnchor, &["E.lean"]);
    let k = kernel(vec![c], vec![a], vec![e]);
    // Sin recibo: candidate NO es aprobación.
    let r = report_of(&k, &[]);
    assert!(matches!(
        r.results["A.teo"].decision,
        Decision::Pending { .. }
    ));
    assert_eq!(
        r.results["A.teo"].formal,
        argumentos::check::FormalState::Pending
    );
}

/// N11: JSON duplicado/NaN — la entrada se rechaza en la capa estricta.
#[test]
fn n11_json_duplicado_o_nan_rechaza() {
    let dup = r#"{"schema_version": "1.0", "schema_version": "1.0", "claims": [], "arguments": [], "evidence_specs": []}"#;
    assert!(argumentos::model::kernel_from_str(dup).is_err());
    let nan = r#"{"schema_version": "1.0", "claims": [], "arguments": [], "evidence_specs": [], "extra": NaN}"#;
    assert!(argumentos::model::kernel_from_str(nan).is_err());
}

/// N12: ruta fuera de raíz o symlink — el acceso se rechaza.
#[test]
fn n12_ruta_fuera_de_raiz_rechaza() {
    let root = std::path::Path::new("/tmp/argumentos-test-root");
    assert!(
        argumentos::check::guard_path(root, std::path::Path::new("kernel/claims/a.json")).is_ok()
    );
    assert!(argumentos::check::guard_path(root, std::path::Path::new("../../etc/passwd")).is_err());
    assert!(argumentos::check::guard_path(root, std::path::Path::new("a/../../b.json")).is_err());
    // Symlink: crear uno real y verificar el rechazo.
    let dir = std::env::temp_dir().join(format!("argumentos-n12-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let real = dir.join("real.json");
    std::fs::write(&real, "{}").unwrap();
    let link = dir.join("link.json");
    let _ = std::fs::remove_file(&link);
    std::os::unix::fs::symlink(&real, &link).unwrap();
    assert!(argumentos::check::guard_path(&dir, std::path::Path::new("link.json")).is_err());
    let _ = std::fs::remove_file(&link);
    let _ = std::fs::remove_file(&real);
    let _ = std::fs::remove_dir(&dir);
}

/// N18: premisa pendiente — la obligación se conserva, no desaparece.
#[test]
fn n18_premisa_pendiente_conserva_obligacion() {
    let cp = claim(
        "C.P",
        ClaimKind::Formal,
        atom("P"),
        &[("domain", "finite")],
        &["H.aun.no.verificada"],
    );
    let cq = claim(
        "C.Q",
        ClaimKind::Formal,
        atom("Q"),
        &[("domain", "finite")],
        &[],
    );
    let c_and = claim(
        "C.PQ",
        ClaimKind::Formal,
        Expression::And {
            items: vec![atom("P"), atom("Q")],
        },
        &[("domain", "finite")],
        &[],
    );
    let a = argument("A.and", "C.PQ", &["C.P", "C.Q"], Rule::AndIntro, &[]);
    let h_pend = claim(
        "H.aun.no.verificada",
        ClaimKind::Factual,
        atom("H.pendiente"),
        &[("domain", "finite")],
        &[],
    );
    let k = kernel(vec![cp, cq, c_and, h_pend], vec![a], vec![]);
    let r = report_of(&k, &[]);
    match &r.results["A.and"].decision {
        Decision::AcceptedConditional { open } => {
            assert!(open.contains(&"H.aun.no.verificada".to_string()))
        }
        other => panic!("esperaba AcceptedConditional, llegó {:?}", other),
    }
}

/// N19: reglas alternativas, una circular — solo la derivación acíclica
/// válida se acepta.
#[test]
fn n19_reglas_alternativas_solo_los_acyclicas() {
    // Un ALIAS_EXACT exige el mismo objeto formal: ambas afirmaciones
    // comparten la expresión; difieren en ID (la traducción se evalúa aparte).
    let c = claim(
        "C.objetivo",
        ClaimKind::Formal,
        atom("objetivo"),
        &[("domain", "finite")],
        &[],
    );
    let cbase = claim(
        "C.base",
        ClaimKind::Formal,
        atom("objetivo"),
        &[("domain", "finite")],
        &[],
    );
    // Circular: concluye C desde C.
    let a_circ = argument(
        "A.circ",
        "C.objetivo",
        &["C.objetivo"],
        Rule::AliasExact,
        &[],
    );
    // Válida: concluye C desde una base independiente (alias acíclico).
    let a_ok = argument("A.ok", "C.objetivo", &["C.base"], Rule::AliasExact, &[]);
    let k = kernel(vec![c, cbase], vec![a_circ, a_ok], vec![]);
    let r = report_of(&k, &[]);
    assert!(matches!(
        &r.results["A.circ"].decision,
        Decision::Rejected {
            reason: Rejection::Cycle { .. }
        }
    ));
    assert!(matches!(
        &r.results["A.ok"].decision,
        Decision::AcceptedConditional { .. }
    ));
}
