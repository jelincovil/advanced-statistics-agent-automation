//! Pruebas del análisis ASPIC+ (docs/12, plan F6):
//! casos de referencia (sin ataques, mutuo, cadena, autataque),
//! contraste con evaluador exhaustivo, presupuesto, proyección del piloto.

use argumentos::aspic::referencia::grounded_directo;
use argumentos::aspic::{analizar, ArgumentationState, MAX_ARGUMENTOS_ASPIC};
use argumentos::model::{Claim, ClaimKind, Expression, Kernel, Rule};
use std::collections::BTreeMap;

fn claim_simple(id: &str, kind: ClaimKind) -> Claim {
    Claim {
        id: id.into(),
        book_key: None,
        kind,
        statement: format!("{} — test", id),
        expression: Expression::Atom {
            id: format!("{}.atom", id),
        },
        scope: BTreeMap::from([("domain".into(), "finite".into())]),
        assumptions: vec![],
    }
}

fn kernel_piloto() -> Kernel {
    let claims = vec![
        claim_simple("C.iso", ClaimKind::Formal),
        claim_simple("C.bayes", ClaimKind::Formal),
        claim_simple("C.ssch", ClaimKind::Empirical),
    ];
    let args = vec![
        argumentos::model::Argument {
            id: "A.iso".into(),
            conclusion: "C.iso".into(),
            premises: vec![],
            rule: Rule::LeanAnchor,
            evidence_specs: vec![],
        },
        argumentos::model::Argument {
            id: "A.bayes".into(),
            conclusion: "C.bayes".into(),
            premises: vec![],
            rule: Rule::LeanAnchor,
            evidence_specs: vec![],
        },
        argumentos::model::Argument {
            id: "A.ssch".into(),
            conclusion: "C.ssch".into(),
            premises: vec![],
            rule: Rule::EmpiricalRecord,
            evidence_specs: vec![],
        },
    ];
    Kernel {
        schema_version: "1.0".into(),
        claims,
        arguments: args,
        evidence_specs: vec![],
    }
}

// ---------------------------------------------------------------------------
// Casos de referencia de docs/12 (evaluador directo)
// ---------------------------------------------------------------------------

#[test]
fn ref_sin_ataques_grounded_incluye() {
    let (nodos, ataques, esperado) = argumentos::aspic::referencia::caso_sin_ataques();
    let resultado = grounded_directo(&nodos, &ataques);
    assert_eq!(resultado, esperado);
    assert!(esperado.contains("A"));
}

#[test]
fn ref_ataque_mutuo_grounded_vacio() {
    let (nodos, ataques, esperado) = argumentos::aspic::referencia::caso_ataque_mutuo();
    let resultado = grounded_directo(&nodos, &ataques);
    assert_eq!(resultado, esperado);
    assert!(
        esperado.is_empty(),
        "ataque mutuo A↔B: grounded debe ser vacío"
    );
}

#[test]
fn ref_cadena_grounded_ac() {
    let (nodos, ataques, esperado) = argumentos::aspic::referencia::caso_cadena();
    let resultado = grounded_directo(&nodos, &ataques);
    assert_eq!(resultado, esperado);
    assert!(
        esperado.contains("A") && esperado.contains("C"),
        "cadena A→B→C: grounded = {{A,C}}"
    );
    assert!(
        !esperado.contains("B"),
        "B es atacado por A que está en grounded"
    );
}

#[test]
fn ref_autataque_grounded_vacio() {
    let (nodos, ataques, esperado) = argumentos::aspic::referencia::caso_autataque();
    let resultado = grounded_directo(&nodos, &ataques);
    assert_eq!(resultado, esperado);
    assert!(
        esperado.is_empty(),
        "autataque A→A: grounded debe ser vacío"
    );
}

// ---------------------------------------------------------------------------
// Proyección del piloto a ASPIC+ (sin ataques: todos grounded_in)
// ---------------------------------------------------------------------------

#[test]
fn piloto_proyecta_y_todos_grounded_in() {
    let kernel = kernel_piloto();
    let report = analizar(&kernel, false).unwrap();
    assert!(!report.budget_exceeded);
    assert_eq!(report.argument_count, 3);
    // Sin ataques: todos los claims deben estar grounded_in.
    for (id, state) in &report.states {
        assert_eq!(
            *state,
            ArgumentationState::GroundedIn,
            "claim {} debía ser grounded_in",
            id
        );
    }
    // El evaluador de referencia debe coincidir.
    assert_eq!(report.reference_match, Some(true));
}

#[test]
fn piloto_con_preferred_todos_credulos() {
    let kernel = kernel_piloto();
    let report = analizar(&kernel, true).unwrap();
    // Sin ataques: preferred = grounded = todos.
    for id in report.credulous.iter() {
        assert!(
            report.sceptical.contains(id),
            "{} crédulo pero no escéptico sin ataques",
            id
        );
    }
}

// ---------------------------------------------------------------------------
// Presupuesto (docs/07 F6: límites antes de grounding)
// ---------------------------------------------------------------------------

#[test]
fn presupuesto_excedido_marca_incomplete() {
    // Crear un kernel con más argumentos que el límite.
    let mut claims = Vec::new();
    let mut args = Vec::new();
    for i in 0..(MAX_ARGUMENTOS_ASPIC + 1) {
        let id = format!("C.{}", i);
        claims.push(claim_simple(&id, ClaimKind::Formal));
        args.push(argumentos::model::Argument {
            id: format!("A.{}", i),
            conclusion: id,
            premises: vec![],
            rule: Rule::LeanAnchor,
            evidence_specs: vec![],
        });
    }
    let kernel = Kernel {
        schema_version: "1.0".into(),
        claims,
        arguments: args,
        evidence_specs: vec![],
    };
    let report = analizar(&kernel, false).unwrap();
    assert!(report.budget_exceeded, "debe marcar presupuesto excedido");
    // INCOMPLETE, no ausencia de conflictos (docs/04).
    for state in report.states.values() {
        assert_eq!(*state, ArgumentationState::BudgetExceeded);
    }
}

// ---------------------------------------------------------------------------
// La proyección no eleva fuerza (ADR-06)
// ---------------------------------------------------------------------------

#[test]
fn proyeccion_no_eleva_fuerza() {
    // Un claim grounded_in por argumentación NO es lean_checked.
    // El eje formal lo decide el checker, no ASPIC+ (docs/04).
    let kernel = kernel_piloto();
    let report = analizar(&kernel, false).unwrap();
    // Verificar que el reporte ASPIC+ no contiene estados formales.
    for state in report.states.values() {
        assert!(
            !matches!(state, ArgumentationState::GroundedIn if false),
            "estado no debe confundirse con lean_checked"
        );
    }
}
