//! El checker independiente (docs/04_REGLAS_Y_ESTADOS.md, plan F2):
//! resolución de IDs, DAG de soporte, AST exacta, reglas del registro,
//! obligaciones, alcance, estados ortogonales e invalidación transitiva.
//!
//! Sin red, sin LLM, sin procesos: recibe objetos ya cargados y emite un
//! resultado reproducible. Ninguna capa decide verdad: los estados son
//! salidas calculadas, jamás aceptadas de un campo de entrada (ADR-10).
//!
//! Las 7 reglas admitidas en v1 (docs/04). El grafo de soporte usa
//! petgraph; un ciclo que atraviese la conclusión de un argumento marca
//! ese argumento como derivación circular (N07); las reglas alternativas
//! acíclicas siguen válidas (N19).

use crate::model::{Argument, Claim, EvidenceKind, EvidenceSpec, Expression, Kernel, Rule};
use crate::receipt::Receipt;
use petgraph::graphmap::DiGraphMap;
use petgraph::visit::Dfs;
use sha2::Digest;
use std::collections::{BTreeMap, BTreeSet, HashMap};

/// Axiomas estándar del proyecto Lean (verificacion_lean): los únicos
/// aceptados en un LEAN_ANCHOR. `sorryAx` o cualquier axioma añadido
/// rechaza la prueba (N04).
pub const STANDARD_AXIOMS: [&str; 3] = ["propext", "Classical.choice", "Quot.sound"];

#[derive(Debug, Clone, PartialEq)]
pub enum Decision {
    Accepted,
    AcceptedConditional { open: Vec<String> },
    Rejected { reason: Rejection },
    UnsupportedRule,
    Pending { reason: String },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Rejection {
    UnknownReference {
        id: String,
    },
    Cycle {
        camino: Vec<String>,
    },
    AstMismatch {
        esperada: String,
        obtenida: String,
    },
    ScopeMismatch {
        clave: String,
        evidencia: String,
        afirmacion: String,
    },
    NonStandardAxioms {
        axiomas: Vec<String>,
    },
    EmpiricalPromotion,
    StaleEvidence {
        spec: String,
    },
    SelfApproval,
    KindMismatch {
        regla: &'static str,
        detalle: String,
    },
}

impl Rejection {
    /// Descripción accionable de la razón de rechazo.
    pub fn detalle(&self) -> String {
        match self {
            Rejection::UnknownReference { id } => format!("referencia inexistente: {}", id),
            Rejection::Cycle { camino } => format!("derivación circular: {}", camino.join(" → ")),
            Rejection::AstMismatch { esperada, obtenida } => format!(
                "AST no coincide exactamente: esperada {}, obtenida {}",
                esperada, obtenida
            ),
            Rejection::ScopeMismatch {
                clave,
                evidencia,
                afirmacion,
            } => format!(
                "alcance '{}' no coincide: evidencia '{}', afirmación '{}'",
                clave, evidencia, afirmacion
            ),
            Rejection::NonStandardAxioms { axiomas } => {
                format!("axiomas fuera del estándar: {}", axiomas.join(", "))
            }
            Rejection::EmpiricalPromotion => {
                "promoción indebida de resultado empírico a teorema/universal".to_string()
            }
            Rejection::StaleEvidence { spec } => format!(
                "evidencia stale: el hash del spec {} no coincide con su recibo",
                spec
            ),
            Rejection::SelfApproval => {
                "autoaprobación: el estado verificado no se acepta de un campo".to_string()
            }
            Rejection::KindMismatch { regla, detalle } => {
                format!("regla {} mal aplicada: {}", regla, detalle)
            }
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StructureState {
    Valid,
    Invalid,
    Pending,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FormalState {
    LeanChecked,
    Conditional,
    NotApplicable,
    Pending,
    Failed,
    Stale,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EmpiricalState {
    Reproduced,
    Conditional,
    NotApplicable,
    Pending,
    Failed,
    Stale,
}
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EditorialState {
    ExactGenerated,
    AgentReviewed,
    Pending,
    Mismatch,
    Stale,
}

#[derive(Debug, Clone, PartialEq)]
pub struct ArgumentResult {
    pub id: String,
    pub decision: Decision,
    pub obligations: Vec<String>,
    pub evidence_used: Vec<String>,
    pub scope: BTreeMap<String, String>,
    pub diagnostics: Vec<String>,
    pub structure: StructureState,
    pub formal: FormalState,
    pub empirical: EmpiricalState,
    pub editorial: EditorialState,
}

#[derive(Debug, Clone, PartialEq)]
pub struct CheckReport {
    pub canonical_hash: String,
    pub results: BTreeMap<String, ArgumentResult>,
    /// Estado por claim, no solo por argumento. Los huérfanos son
    /// explícitamente Pending y nunca desaparecen del reporte (F06).
    pub claim_states: BTreeMap<String, ClaimState>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum ClaimState {
    Closed,
    Conditional { open: Vec<String> },
    Pending { reason: String },
    Rejected { reason: String },
}

fn compute_claim_states(
    kernel: &Kernel,
    results: &BTreeMap<String, ArgumentResult>,
) -> BTreeMap<String, ClaimState> {
    let mut states = BTreeMap::new();
    for claim in &kernel.claims {
        let support: Vec<_> = kernel
            .arguments
            .iter()
            .filter(|a| a.conclusion == claim.id)
            .filter_map(|a| results.get(&a.id))
            .collect();
        let state = if support.is_empty() {
            ClaimState::Pending {
                reason: "claim sin argumento".into(),
            }
        } else if support
            .iter()
            .any(|r| matches!(r.decision, Decision::Accepted))
        {
            ClaimState::Closed
        } else if support
            .iter()
            .any(|r| matches!(r.decision, Decision::AcceptedConditional { .. }))
        {
            let mut open = Vec::new();
            for r in support {
                if let Decision::AcceptedConditional { open: current } = &r.decision {
                    open.extend(current.iter().cloned());
                }
            }
            open.sort();
            open.dedup();
            ClaimState::Conditional { open }
        } else if support
            .iter()
            .any(|r| matches!(r.decision, Decision::Pending { .. }))
        {
            ClaimState::Pending {
                reason: "sin evidencia validada".into(),
            }
        } else {
            ClaimState::Rejected {
                reason: "todos los argumentos rechazados".into(),
            }
        };
        states.insert(claim.id.clone(), state);
    }
    states
}

pub struct CheckInput<'a> {
    pub kernel: &'a Kernel,
    pub receipts: &'a [Receipt],
}

/// Ejecuta el checker sobre todo el kernel.
pub fn check(input: &CheckInput) -> CheckReport {
    let claims: HashMap<&str, &Claim> = input
        .kernel
        .claims
        .iter()
        .map(|c| (c.id.as_str(), c))
        .collect();
    let specs: HashMap<&str, &EvidenceSpec> = input
        .kernel
        .evidence_specs
        .iter()
        .map(|s| (s.id.as_str(), s))
        .collect();
    // F05: conservar TODOS los recibos. El antiguo Map<&str, &Receipt>
    // seleccionaba silenciosamente el último y hacía depender la decisión
    // del orden de lectura.
    let mut by_spec: HashMap<&str, Vec<&Receipt>> = HashMap::new();
    for receipt in input.receipts {
        by_spec
            .entry(receipt.spec_id.as_str())
            .or_default()
            .push(receipt);
    }

    let mut results: BTreeMap<String, ArgumentResult> = BTreeMap::new();
    for arg in &input.kernel.arguments {
        results.insert(
            arg.id.clone(),
            check_argument(arg, &claims, &specs, &by_spec, input),
        );
    }
    propagate_stale(input, &mut results);
    let canonical = canonical_serialization(&results);
    let canonical_hash = format!("{:x}", sha2::Sha256::digest(canonical.as_bytes()));
    let claim_states = compute_claim_states(input.kernel, &results);
    CheckReport {
        canonical_hash,
        results,
        claim_states,
    }
}

fn check_argument(
    arg: &Argument,
    claims: &HashMap<&str, &Claim>,
    specs: &HashMap<&str, &EvidenceSpec>,
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    input: &CheckInput,
) -> ArgumentResult {
    // N06: resolución de IDs (conclusión, premisas y specs).
    let conclusion = match claims.get(arg.conclusion.as_str()) {
        Some(c) => *c,
        None => {
            return rejected(
                arg,
                Rejection::UnknownReference {
                    id: arg.conclusion.clone(),
                },
            )
        }
    };
    let premise_claims: Vec<&Claim> = match arg
        .premises
        .iter()
        .map(|p| claims.get(p.as_str()).copied())
        .collect::<Option<Vec<_>>>()
    {
        Some(v) => v,
        None => {
            return rejected(
                arg,
                Rejection::UnknownReference {
                    id: arg
                        .premises
                        .iter()
                        .find(|p| !claims.contains_key(p.as_str()))
                        .cloned()
                        .unwrap_or_default(),
                },
            )
        }
    };
    let evidence_specs: Vec<&EvidenceSpec> = match arg
        .evidence_specs
        .iter()
        .map(|e| specs.get(e.as_str()).copied())
        .collect::<Option<Vec<_>>>()
    {
        Some(v) => v,
        None => {
            return rejected(
                arg,
                Rejection::UnknownReference {
                    id: arg
                        .evidence_specs
                        .iter()
                        .find(|e| !specs.contains_key(e.as_str()))
                        .cloned()
                        .unwrap_or_default(),
                },
            )
        }
    };

    // Los supuestos referencian otras afirmaciones (docs/03): deben resolver.
    for c in std::iter::once(conclusion).chain(premise_claims.iter().copied()) {
        if let Some(fantasma) = c
            .assumptions
            .iter()
            .find(|a| !claims.contains_key(a.as_str()))
        {
            return rejected(
                arg,
                Rejection::UnknownReference {
                    id: fantasma.clone(),
                },
            );
        }
    }

    // N03: sin ampliación de alcance. Salvo CONDITIONAL_APPLICATION (que
    // declara el escenario, docs/04.6), cada premisa y la conclusión
    // comparten alcance exacto; la regla condicional solo puede añadir
    // claves, nunca cambiar las existentes.
    if arg.rule == Rule::ConditionalApplication {
        for p in &premise_claims {
            if let Some((k, ev, af)) = conditional_scope_mismatch(&p.scope, &conclusion.scope) {
                return rejected(
                    arg,
                    Rejection::ScopeMismatch {
                        clave: k,
                        evidencia: ev,
                        afirmacion: af,
                    },
                );
            }
        }
    } else {
        for p in &premise_claims {
            if p.scope != conclusion.scope {
                if let Some((k, ev, af)) = scope_mismatch(&p.scope, &conclusion.scope) {
                    return rejected(
                        arg,
                        Rejection::ScopeMismatch {
                            clave: k,
                            evidencia: ev,
                            afirmacion: af,
                        },
                    );
                }
                let clave = conclusion
                    .scope
                    .keys()
                    .find(|k| !p.scope.contains_key(*k))
                    .or_else(|| p.scope.keys().find(|k| !conclusion.scope.contains_key(*k)));
                return rejected(
                    arg,
                    Rejection::ScopeMismatch {
                        clave: clave
                            .cloned()
                            .unwrap_or_else(|| "(alcances distintos)".into()),
                        evidencia: "(alcance de la premisa)".into(),
                        afirmacion: "(alcance de la conclusión)".into(),
                    },
                );
            }
        }
    }

    // N07/N19: la conclusión de este argumento no puede ser (transitivamente)
    // dependencia de sus propias premisas.
    if let Some(camino) = support_cycle(
        &arg.conclusion,
        &arg.premises,
        claims,
        &input.kernel.arguments,
    ) {
        return rejected(arg, Rejection::Cycle { camino });
    }

    // N10: la disponibilidad "candidate" del spec no aprueba nada por sí
    // sola; solo un recibo válido descarga la obligación.
    let mut obligations: Vec<String> = Vec::new();
    let mut diagnostics: Vec<String> = Vec::new();
    let decision = match arg.rule {
        Rule::LeanAnchor => lean_anchor(
            conclusion,
            &evidence_specs,
            by_spec,
            &mut obligations,
            &mut diagnostics,
        ),
        Rule::LeanApply => lean_apply(
            arg,
            conclusion,
            &premise_claims,
            &evidence_specs,
            by_spec,
            &mut obligations,
        ),
        Rule::AndIntro => and_intro(
            arg,
            conclusion,
            &premise_claims,
            &evidence_specs,
            by_spec,
            &mut obligations,
        ),
        Rule::ModusPonens => modus_ponens(
            arg,
            conclusion,
            &premise_claims,
            &evidence_specs,
            by_spec,
            &mut obligations,
        ),
        Rule::EmpiricalRecord => empirical_record(
            conclusion,
            &evidence_specs,
            by_spec,
            &mut obligations,
            &mut diagnostics,
        ),
        Rule::ConditionalApplication => conditional(conclusion, &premise_claims, &mut obligations),
        Rule::AliasExact => alias_exact(
            arg,
            conclusion,
            &premise_claims,
            &evidence_specs,
            by_spec,
            &mut obligations,
        ),
    };
    let (structure, formal, empirical, editorial) = axes(&decision, &evidence_specs);
    // Unión de obligaciones (docs/04): sin duplicados, preservando el
    // orden de primera aparición.
    let mut vistas: BTreeSet<String> = BTreeSet::new();
    obligations.retain(|o| vistas.insert(o.clone()));
    ArgumentResult {
        id: arg.id.clone(),
        decision,
        obligations,
        evidence_used: arg.evidence_specs.clone(),
        scope: conclusion.scope.clone(),
        diagnostics,
        structure,
        formal,
        empirical,
        editorial,
    }
}

// --- Confianza y recibos ---------------------------------------------------

/// Procedencia mínima exigible a un recibo local/atestado. El ejecutor es
/// quien produce el comprobante: el checker valida que el formulario tenga
/// los elementos auditables y no un mero campo booleano de aprobación.
fn provenance_ok(receipt: &Receipt, kind: EvidenceKind) -> bool {
    let commit_ok = receipt.source_commit.len() == 40
        && receipt.source_commit.chars().all(|c| c.is_ascii_hexdigit());
    let environment_ok = receipt.environment_hash.len() == 64
        && receipt
            .environment_hash
            .chars()
            .all(|c| c.is_ascii_hexdigit());
    let observed_ok = match kind {
        EvidenceKind::Lean => receipt.observed_checks.iter().any(|c| {
            c.id.starts_with("lean_provenance") && c.status == crate::receipt::CheckStatus::Pass
        }),
        EvidenceKind::Python => receipt.observed_checks.iter().any(|c| {
            c.id.starts_with("criterion")
                && matches!(
                    c.status,
                    crate::receipt::CheckStatus::Pass | crate::receipt::CheckStatus::Fail
                )
        }),
    };
    commit_ok && environment_ok && !receipt.input_hashes.is_empty() && observed_ok
}

fn trusted_execution(receipt: &Receipt) -> bool {
    receipt.execution_passed
        && receipt.termination == crate::receipt::Termination::Completed
        && receipt.exit_status == Some(0)
        && matches!(
            receipt.trust_mode,
            crate::receipt::TrustMode::LocallyReproduced
                | crate::receipt::TrustMode::AttestedByConfiguredPolicy
        )
}

/// Decisión de una spec con política explícita de duplicados (F05): un
/// único resultado válido gana si todos los candidatos válidos son byte
/// equivalentes salvo el ID; dos válidos contradictorios quedan pendientes
/// de atestación, nunca se resuelven por orden o nombre de archivo.
fn evidence_decision(spec: &EvidenceSpec, by_spec: &HashMap<&str, Vec<&Receipt>>) -> Decision {
    let receipts = match by_spec.get(spec.id.as_str()) {
        Some(rs) => rs,
        None => {
            return Decision::Pending {
                reason: "spec sin recibo".into(),
            }
        }
    };
    let mut valid = Vec::new();
    for r in receipts {
        if r.spec_hash == spec_hash(spec) && trusted_execution(r) && provenance_ok(r, spec.kind) {
            valid.push(*r);
        }
    }
    if valid.is_empty() {
        if receipts.iter().any(|r| r.spec_hash != spec_hash(spec)) {
            return Decision::Rejected {
                reason: Rejection::StaleEvidence {
                    spec: spec.id.clone(),
                },
            };
        }
        return Decision::Pending {
            reason: "recibo no válido: reproducción local o atestación y procedencia insuficientes"
                .into(),
        };
    }
    let mut fingerprints = BTreeSet::new();
    for r in &valid {
        let mut canonical = (*r).clone();
        canonical.id.clear(); // el nombre del recibo no cambia su contenido
        if let Ok(text) = serde_json::to_string(&canonical) {
            fingerprints.insert(text);
        }
    }
    if fingerprints.len() > 1 {
        Decision::Pending {
            reason: "recibos válidos contradictorios para la misma spec; atestación requerida"
                .into(),
        }
    } else {
        Decision::Accepted
    }
}

fn finish_with_obligations(obligations: &[String]) -> Decision {
    if obligations.is_empty() {
        Decision::Accepted
    } else {
        Decision::AcceptedConditional {
            open: open_of(obligations),
        }
    }
}

/// Toda spec aportada tiene que ser válida. Una regla proposicional válida
/// no convierte una evidencia pendiente en LeanChecked (F01/F14).
fn composition_decision(
    arg: &Argument,
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &[String],
) -> Decision {
    for spec in specs {
        let decision = evidence_decision(spec, by_spec);
        if !matches!(decision, Decision::Accepted) {
            return decision;
        }
    }
    if arg.evidence_specs.is_empty() {
        Decision::AcceptedConditional {
            open: open_of(obligations),
        }
    } else {
        finish_with_obligations(obligations)
    }
}

// --- Reglas ----------------------------------------------------------------

/// LEAN_ANCHOR (docs/04.1): spec lean apuntando a la conclusión, alcance
/// compatible, axiomas estándar (N04) y recibo reproducido localmente.
fn lean_anchor(
    conclusion: &Claim,
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
    diagnostics: &mut Vec<String>,
) -> Decision {
    // El ancla Lean respalda afirmaciones formales (contrato del paquete).
    if conclusion.kind != crate::model::ClaimKind::Formal {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "LEAN_ANCHOR",
                detalle: "la conclusión debe ser formal".into(),
            },
        };
    }
    let spec = match specs.iter().find(|s| s.kind == EvidenceKind::Lean) {
        Some(s) => *s,
        None => {
            return Decision::Pending {
                reason: "sin spec lean".into(),
            }
        }
    };
    if spec.claim_id != conclusion.id {
        return Decision::Rejected {
            reason: Rejection::UnknownReference {
                id: spec.claim_id.clone(),
            },
        };
    }
    if let Some((k, ev, af)) = evidence_scope_mismatch(&spec.scope, &conclusion.scope) {
        return Decision::Rejected {
            reason: Rejection::ScopeMismatch {
                clave: k,
                evidencia: ev,
                afirmacion: af,
            },
        };
    }
    let declared = declared_axioms(&spec.scope);
    let fuera: Vec<String> = declared
        .iter()
        .filter(|a| !STANDARD_AXIOMS.contains(&a.as_str()))
        .cloned()
        .collect();
    if !fuera.is_empty() {
        return Decision::Rejected {
            reason: Rejection::NonStandardAxioms { axiomas: fuera },
        };
    }
    obligations.extend(conclusion.assumptions.iter().cloned());
    let decision = evidence_decision(spec, by_spec);
    if matches!(decision, Decision::Accepted) {
        diagnostics.push("recibo válido con producción local o atestación verificable".into());
        finish_with_obligations(obligations)
    } else {
        decision
    }
}

/// LEAN_APPLY (docs/04.2): el wrapper esperado forma parte del spec; prohibido
/// aprobar solo porque `lean` compiló otro teorema del archivo.
fn lean_apply(
    arg: &Argument,
    conclusion: &Claim,
    premises: &[&Claim],
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
) -> Decision {
    if conclusion.kind != crate::model::ClaimKind::Formal {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "LEAN_APPLY",
                detalle: "la conclusión debe ser formal".into(),
            },
        };
    }
    let spec = match specs.iter().find(|s| s.kind == EvidenceKind::Lean) {
        Some(s) => *s,
        None => {
            return Decision::Pending {
                reason: "sin spec lean".into(),
            }
        }
    };
    if spec.claim_id != conclusion.id {
        return Decision::Rejected {
            reason: Rejection::UnknownReference {
                id: spec.claim_id.clone(),
            },
        };
    }
    if let Some((k, ev, af)) = evidence_scope_mismatch(&spec.scope, &conclusion.scope) {
        return Decision::Rejected {
            reason: Rejection::ScopeMismatch {
                clave: k,
                evidencia: ev,
                afirmacion: af,
            },
        };
    }
    let fuera: Vec<String> = declared_axioms(&spec.scope)
        .iter()
        .filter(|a| !STANDARD_AXIOMS.contains(&a.as_str()))
        .cloned()
        .collect();
    if !fuera.is_empty() {
        return Decision::Rejected {
            reason: Rejection::NonStandardAxioms { axiomas: fuera },
        };
    }
    // El objetivo del wrapper declarado en el spec debe coincidir con la
    // conclusión del argumento (N16: mismo nombre con otro tipo también se
    // rechaza aquí, pues el spec declara el objetivo exacto).
    if spec.target != arg.conclusion {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "LEAN_APPLY",
                detalle: format!(
                    "el wrapper declarado apunta a '{}' y la conclusión es '{}'",
                    spec.target, arg.conclusion
                ),
            },
        };
    }
    obligations.extend(arg.premises.iter().cloned());
    obligations.extend(conclusion.assumptions.iter().cloned());
    for premise in premises {
        obligations.extend(premise.assumptions.iter().cloned());
    }
    let decision = evidence_decision(spec, by_spec);
    if matches!(decision, Decision::Accepted) {
        finish_with_obligations(obligations)
    } else {
        decision
    }
}

/// AND_INTRO (docs/04.3): de P y Q obtiene exactamente And(P,Q); mezcla de
/// evidencia formal y empírica produce dossier mixto, no un teorema.
fn and_intro(
    arg: &Argument,
    conclusion: &Claim,
    premises: &[&Claim],
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
) -> Decision {
    if premises.len() < 2 {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "AND_INTRO",
                detalle: "exige dos o más premisas".into(),
            },
        };
    }
    let items: Vec<Expression> = premises.iter().map(|c| c.expression.clone()).collect();
    let esperada = Expression::And { items };
    if conclusion.expression != esperada {
        return Decision::Rejected {
            reason: Rejection::AstMismatch {
                esperada: format!("{:?}", esperada),
                obtenida: format!("{:?}", conclusion.expression),
            },
        };
    }
    obligations.extend(premises.iter().flat_map(|c| c.assumptions.iter().cloned()));
    obligations.extend(conclusion.assumptions.iter().cloned());
    composition_decision(arg, specs, by_spec, obligations)
}

/// MODUS_PONENS (docs/04.4): solo sobre AST exacta P e Implies(P,Q) → Q.
/// No interpreta conectores en español.
fn modus_ponens(
    arg: &Argument,
    conclusion: &Claim,
    premises: &[&Claim],
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
) -> Decision {
    if premises.len() != 2 {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "MODUS_PONENS",
                detalle: format!("exige exactamente 2 premisas, recibió {}", premises.len()),
            },
        };
    }
    let (e0, e1) = (&premises[0].expression, &premises[1].expression);
    // MP estándar (contrato del paquete, docs/04.4): una premisa es
    // Implies(A, B) con A exactamente igual a la otra premisa y B
    // exactamente igual a la conclusión. AST exacta, sin interpretación.
    let mp = |implied: &Expression, otra: &Expression| match implied {
        Expression::Implies {
            antecedent,
            consequent,
        } => **antecedent == *otra && **consequent == conclusion.expression,
        _ => false,
    };
    if !(mp(e0, e1) || mp(e1, e0)) {
        return Decision::Rejected {
            reason: Rejection::AstMismatch {
                esperada: "Implies(A, B) con A = la otra premisa y B = la conclusión".into(),
                obtenida: format!("{:?} ⊢ {:?}", vec![e0, e1], conclusion.expression),
            },
        };
    }
    obligations.extend(premises.iter().flat_map(|c| c.assumptions.iter().cloned()));
    obligations.extend(conclusion.assumptions.iter().cloned());
    composition_decision(arg, specs, by_spec, obligations)
}

/// EMPIRICAL_RECORD (docs/04.5): respalda la afirmación acotada de que E
/// produjo R bajo C. Exige recibo válido y alcance coincidente. NO produce
/// forall: una afirmación formal no se promueve por observación (N08).
fn empirical_record(
    conclusion: &Claim,
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
    diagnostics: &mut Vec<String>,
) -> Decision {
    if conclusion.kind != crate::model::ClaimKind::Empirical {
        // N08: una afirmación no empírica (teorema/universal o condicional)
        // no se promueve por observación de frecuencias.
        return Decision::Rejected {
            reason: Rejection::EmpiricalPromotion,
        };
    }
    let spec = match specs.iter().find(|s| s.kind == EvidenceKind::Python) {
        Some(s) => *s,
        None => {
            return Decision::Pending {
                reason: "sin spec python".into(),
            }
        }
    };
    if spec.claim_id != conclusion.id {
        return Decision::Rejected {
            reason: Rejection::UnknownReference {
                id: spec.claim_id.clone(),
            },
        };
    }
    if let Some((k, ev, af)) = evidence_scope_mismatch(&spec.scope, &conclusion.scope) {
        return Decision::Rejected {
            reason: Rejection::ScopeMismatch {
                clave: k,
                evidencia: ev,
                afirmacion: af,
            },
        };
    }
    obligations.extend(conclusion.assumptions.iter().cloned());
    let decision = evidence_decision(spec, by_spec);
    if !matches!(decision, Decision::Accepted) {
        return decision;
    }
    let negative_claim = matches!(
        conclusion.scope.get("claim_polarity").map(String::as_str),
        Some("negative")
    );
    let criterion_failed = by_spec.get(spec.id.as_str()).is_some_and(|rs| {
        rs.iter()
            .filter(|r| trusted_execution(r))
            .any(|r| r.scientific_criterion_met == Some(false))
    });
    if negative_claim {
        if criterion_failed {
            diagnostics.push("resultado negativo compatible con la afirmación acotada".into());
            finish_with_obligations(obligations)
        } else {
            Decision::Pending {
                reason: "la afirmación negativa requiere su criterio fallido registrado".into(),
            }
        }
    } else if criterion_failed {
        // F03: nunca promover el fracaso del criterio a la afirmación
        // positiva incompatible. No se infiere la negación tampoco.
        Decision::Rejected {
            reason: Rejection::EmpiricalPromotion,
        }
    } else {
        let met = by_spec.get(spec.id.as_str()).is_some_and(|rs| {
            rs.iter()
                .filter(|r| trusted_execution(r))
                .any(|r| r.scientific_criterion_met == Some(true))
        });
        if met {
            diagnostics.push("criterio preregistrado y resultado enlazados".into());
            finish_with_obligations(obligations)
        } else {
            Decision::Pending {
                reason: "criterio preregistrado no resuelto por el recibo".into(),
            }
        }
    }
}

/// CONDITIONAL_APPLICATION (docs/04.6): la conclusión es CONDICIONAL a H en
/// el escenario; H queda como obligación abierta (N01, P06, N18).
fn conditional(conclusion: &Claim, premises: &[&Claim], obligations: &mut Vec<String>) -> Decision {
    if conclusion.kind != crate::model::ClaimKind::Conditional {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "CONDITIONAL_APPLICATION",
                detalle: "la conclusión debe ser condicional".into(),
            },
        };
    }
    obligations.extend(premises.iter().flat_map(|c| c.assumptions.iter().cloned()));
    obligations.extend(conclusion.assumptions.iter().cloned());
    Decision::AcceptedConditional {
        open: open_of(obligations),
    }
}

/// ALIAS_EXACT (docs/04.7): mismo objeto formal/expresión y mismo alcance;
/// la traducción en lenguaje natural se evalúa aparte (N03).
fn alias_exact(
    arg: &Argument,
    conclusion: &Claim,
    premises: &[&Claim],
    specs: &[&EvidenceSpec],
    by_spec: &HashMap<&str, Vec<&Receipt>>,
    obligations: &mut Vec<String>,
) -> Decision {
    if premises.len() != 1 {
        return Decision::Rejected {
            reason: Rejection::KindMismatch {
                regla: "ALIAS_EXACT",
                detalle: format!("exige exactamente 1 premisa, recibió {}", premises.len()),
            },
        };
    }
    let origen = premises[0];
    if origen.expression != conclusion.expression {
        return Decision::Rejected {
            reason: Rejection::AstMismatch {
                esperada: format!("{:?}", origen.expression),
                obtenida: format!("{:?}", conclusion.expression),
            },
        };
    }
    if let Some((k, ev, af)) = scope_mismatch(&origen.scope, &conclusion.scope) {
        return Decision::Rejected {
            reason: Rejection::ScopeMismatch {
                clave: k,
                evidencia: ev,
                afirmacion: af,
            },
        };
    }
    obligations.extend(origen.assumptions.iter().cloned());
    obligations.extend(conclusion.assumptions.iter().cloned());
    composition_decision(arg, specs, by_spec, obligations)
}

// --- Utilidades --------------------------------------------------------------

/// Hipótesis abiertas de un `AcceptedConditional`: unión sin duplicados
/// (docs/04: obligaciones de la salida = unión de las de las entradas).
fn open_of(obligations: &[String]) -> Vec<String> {
    let mut vistas: BTreeSet<&str> = BTreeSet::new();
    obligations
        .iter()
        .filter(|o| vistas.insert(o.as_str()))
        .cloned()
        .collect()
}

/// Claves compartidas que difieren entre dos alcances.
fn scope_mismatch(
    spec: &BTreeMap<String, String>,
    claim_scope: &BTreeMap<String, String>,
) -> Option<(String, String, String)> {
    spec.iter()
        .filter_map(|(k, v)| claim_scope.get(k).map(|vc| (k, v, vc)))
        .find(|(_, v, vc)| v != vc)
        .map(|(k, v, vc)| (k.clone(), v.clone(), vc.clone()))
}

/// Evidencia/conclusión: toda clave del alcance de la conclusión debe
/// aparecer en la spec con el mismo valor. La spec puede añadir metadatos
/// de ejecución (`lean_axioms`, criterio), nunca borrar especializaciones.
fn evidence_scope_mismatch(
    spec_scope: &BTreeMap<String, String>,
    claim_scope: &BTreeMap<String, String>,
) -> Option<(String, String, String)> {
    if let Some(diff) = scope_mismatch(spec_scope, claim_scope) {
        return Some(diff);
    }
    if let Some(missing) = claim_scope.keys().find(|k| !spec_scope.contains_key(*k)) {
        return Some((
            missing.clone(),
            "(ausente en la evidencia)".into(),
            claim_scope[missing].clone(),
        ));
    }
    None
}

/// Alcance condicional: puede especializar añadiendo claves, pero no
/// eliminar ni cambiar las ya establecidas.
fn conditional_scope_mismatch(
    premise_scope: &BTreeMap<String, String>,
    conclusion_scope: &BTreeMap<String, String>,
) -> Option<(String, String, String)> {
    evidence_scope_mismatch(conclusion_scope, premise_scope)
}

/// Axiomas declarados en el alcance del spec (clave `lean_axioms`, coma-separada).
fn declared_axioms(scope: &BTreeMap<String, String>) -> Vec<String> {
    scope
        .get("lean_axioms")
        .map(|s| {
            s.split(',')
                .map(str::trim)
                .filter(|s| !s.is_empty())
                .map(String::from)
                .collect()
        })
        .unwrap_or_default()
}

/// Los cuatro ejes a partir de la decisión y la evidencia usada (docs/04).
fn axes(
    decision: &Decision,
    specs: &[&EvidenceSpec],
) -> (StructureState, FormalState, EmpiricalState, EditorialState) {
    let structure = match decision {
        Decision::Rejected { .. } => StructureState::Invalid,
        _ => StructureState::Valid,
    };
    let lean = specs.iter().any(|s| s.kind == EvidenceKind::Lean);
    let python = specs.iter().any(|s| s.kind == EvidenceKind::Python);
    let (formal, empirical) = match decision {
        Decision::Accepted => (
            if lean {
                FormalState::LeanChecked
            } else {
                FormalState::NotApplicable
            },
            if python {
                EmpiricalState::Reproduced
            } else {
                EmpiricalState::NotApplicable
            },
        ),
        Decision::AcceptedConditional { .. } => {
            (FormalState::Conditional, EmpiricalState::Conditional)
        }
        Decision::Rejected {
            reason: Rejection::StaleEvidence { .. },
        } => (FormalState::Stale, EmpiricalState::Stale),
        Decision::Rejected { .. } => (FormalState::Failed, EmpiricalState::Failed),
        Decision::UnsupportedRule | Decision::Pending { .. } => {
            (FormalState::Pending, EmpiricalState::Pending)
        }
    };
    (structure, formal, empirical, EditorialState::Pending)
}

/// N05: invalidación transitiva. Un recibo cuyo `spec_hash` no coincide con
/// el hash canónico del spec actual marca stale ese spec y el argumento que
/// lo usa (los descendientes se propagan por el grafo de soporte).
fn propagate_stale(input: &CheckInput, results: &mut BTreeMap<String, ArgumentResult>) {
    // 1) Los recibos con spec_hash obsoleto invalidan directamente solo
    // los argumentos que los usan.
    for res in results.values_mut() {
        if res.evidence_used.iter().any(|spec_id| {
            input.receipts.iter().any(|r| {
                input.kernel.evidence_specs.iter().any(|s| {
                    s.id == spec_id.as_str() && s.id == r.spec_id && r.spec_hash != spec_hash(s)
                })
            })
        }) {
            let used = res
                .evidence_used
                .iter()
                .find(|spec_id| {
                    input.receipts.iter().any(|r| {
                        input.kernel.evidence_specs.iter().any(|s| {
                            s.id == spec_id.as_str()
                                && s.id == r.spec_id
                                && r.spec_hash != spec_hash(s)
                        })
                    })
                })
                .cloned()
                .unwrap_or_default();
            res.decision = Decision::Rejected {
                reason: Rejection::StaleEvidence { spec: used },
            };
            res.formal = FormalState::Stale;
            res.empirical = EmpiricalState::Stale;
            res.editorial = EditorialState::Stale;
        }
    }

    // 2) Punto fijo (F02). Un claim falla solo si todos sus argumentos
    // posibles fallaron. Los argumentos que concluyen lo mismo por otra
    // vía no se contaminan: así se conservan las alternativas del diamante.
    loop {
        let mut supported: HashMap<&str, bool> = HashMap::new();
        for arg in &input.kernel.arguments {
            let ok = results.get(&arg.id).is_some_and(|r| {
                matches!(
                    r.decision,
                    Decision::Accepted | Decision::AcceptedConditional { .. }
                )
            });
            supported
                .entry(arg.conclusion.as_str())
                .and_modify(|v| *v |= ok)
                .or_insert(ok);
        }

        let mut changed = false;
        let claims_with_arguments: BTreeSet<&str> = input
            .kernel
            .arguments
            .iter()
            .map(|a| a.conclusion.as_str())
            .collect();
        for arg in &input.kernel.arguments {
            let already_supported = results.get(&arg.id).is_some_and(|r| {
                matches!(
                    r.decision,
                    Decision::Accepted | Decision::AcceptedConditional { .. }
                )
            });
            if !already_supported {
                continue;
            }
            let conclusion_claim = input.kernel.claims.iter().find(|c| c.id == arg.conclusion);
            let dependencies = arg.premises.iter().chain(
                conclusion_claim
                    .map(|c| c.assumptions.iter())
                    .into_iter()
                    .flatten(),
            );
            let failed = dependencies
                .filter(|dep| {
                    claims_with_arguments.contains(dep.as_str())
                        && !supported.get(dep.as_str()).copied().unwrap_or(false)
                })
                .cloned()
                .collect::<Vec<_>>();
            if let Some(first) = failed.first() {
                if let Some(res) = results.get_mut(&arg.id) {
                    res.decision = Decision::Rejected {
                        reason: Rejection::StaleEvidence {
                            spec: format!("soporte invalidado transitivamente: {first}"),
                        },
                    };
                    res.formal = FormalState::Stale;
                    res.empirical = EmpiricalState::Stale;
                    res.editorial = EditorialState::Stale;
                    res.diagnostics.push(format!(
                        "invalidación transitiva por {first}; no afecta alternativas válidas"
                    ));
                    changed = true;
                }
            }
        }
        if !changed {
            break;
        }
    }
}

/// Hash canónico del spec (SHA-256 de su serialización con orden fijo).
pub fn spec_hash(spec: &EvidenceSpec) -> String {
    let canon = serde_json::to_string(spec).unwrap_or_default();
    format!("{:x}", sha2::Sha256::digest(canon.as_bytes()))
}

/// Serialización canónica de resultados: IDs ordenados, arrays ordenados,
/// determinista (P07: permutar el conjunto de entradas no la cambia).
fn canonical_serialization(results: &BTreeMap<String, ArgumentResult>) -> String {
    let mut partes: Vec<String> = Vec::new();
    for (id, res) in results {
        let mut obligadas = res.obligations.clone();
        obligadas.sort();
        let mut usadas = res.evidence_used.clone();
        usadas.sort();
        let mut diags = res.diagnostics.clone();
        diags.sort();
        let mut claves: Vec<_> = res
            .scope
            .iter()
            .map(|(k, v)| format!("{}={}", k, v))
            .collect();
        claves.sort();
        partes.push(format!(
            "{}|{:?}|{}|{}|{}|{}|{:?}|{:?}|{:?}",
            id,
            res.decision,
            obligadas.join(","),
            usadas.join(","),
            diags.join(";"),
            claves.join(","),
            res.structure,
            res.formal,
            res.empirical
        ));
    }
    partes.join("\n")
}

/// N07/N19: ciclo de soporte para UN argumento. Grafo de dependencia
/// (conclusión → premisa: "X depende de Y"); si la conclusión del
/// argumento es alcanzable desde sus propias premisas, la derivación es
/// circular. Per-argumento: una regla alternativa acíclica que concluye
/// lo mismo sigue válida (N19).
fn support_cycle(
    conclusion: &str,
    premises: &[String],
    claims: &HashMap<&str, &Claim>,
    arguments: &[Argument],
) -> Option<Vec<String>> {
    let mut graph: DiGraphMap<&str, ()> = DiGraphMap::new();
    for a in arguments {
        for p in &a.premises {
            graph.add_edge(a.conclusion.as_str(), p.as_str(), ());
        }
    }
    // Los supuestos referencian otras afirmaciones (docs/03): también son
    // aristas de dependencia (el ciclo del paquete va por aquí).
    for c in claims.values() {
        for s in &c.assumptions {
            graph.add_edge(c.id.as_str(), s.as_str(), ());
        }
    }
    let mut camino: Vec<String> = Vec::new();
    for p in premises {
        let mut dfs = Dfs::new(&graph, p.as_str());
        while let Some(nodo) = dfs.next(&graph) {
            camino.push(nodo.to_string());
            if nodo == conclusion {
                camino.push(conclusion.to_string());
                return Some(camino);
            }
        }
    }
    None
}

/// N12: guarda de rutas. Rechaza `..`, rutas absolutas fuera de la raíz y
/// symlinks.
pub fn guard_path(
    root: &std::path::Path,
    candidate: &std::path::Path,
) -> Result<std::path::PathBuf, String> {
    for comp in candidate.components() {
        if let std::path::Component::ParentDir = comp {
            return Err(format!(
                "ruta {} escapa de la raíz (componente ..)",
                candidate.display()
            ));
        }
    }
    let resolved = root.join(candidate);
    match resolved.symlink_metadata() {
        Ok(md) if md.file_type().is_symlink() => {
            Err(format!("ruta {} es un symlink", resolved.display()))
        }
        _ => Ok(resolved),
    }
}

/// Constructor de resultado rechazado con ejes coherentes.
fn rejected(arg: &Argument, reason: Rejection) -> ArgumentResult {
    ArgumentResult {
        id: arg.id.clone(),
        decision: Decision::Rejected {
            reason: reason.clone(),
        },
        obligations: Vec::new(),
        evidence_used: Vec::new(),
        scope: BTreeMap::new(),
        diagnostics: vec![reason.detalle()],
        structure: StructureState::Invalid,
        formal: FormalState::Failed,
        empirical: EmpiricalState::Failed,
        editorial: EditorialState::Pending,
    }
}
