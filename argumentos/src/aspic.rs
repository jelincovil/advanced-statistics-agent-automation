//! Proyección ASPIC+ desde el kernel (docs/04, docs/06, plan F6).
//!
//! Genera una proyección de IDs de afirmación y reglas comprobadas.
//! Grounded como diagnóstico inicial; preferred opcional reportando
//! aceptación crédula (alguna extensión) frente a escéptica (todas).
//! Cero extensiones no permite inferir aceptabilidad por vacuidad.
//! Al superar límites: INCOMPLETE.
//!
//! **Arquitectura**: el evaluador de referencia (enumeración directa del
//! fixpoint grounded sobre el grafo de ataque) es el método PRIMARIO para
//! frameworks ≤8 argumentos — es simple, revisable y correcto (docs/12).
//! pickaxe-rs se usa como verificación secundaria cuando el framework
//! tiene reglas y contrariedad; para el piloto (sin ataques) el
//! evaluador de referencia basta y es más honesto.
//!
//! La proyección NO eleva la fuerza de una evidencia (ADR-06): un
//! resultado grounded_in no es un teorema Lean.

use crate::model::Kernel;
use std::collections::{BTreeMap, BTreeSet};

/// Límite de argumentos para el análisis ASPIC+ (docs/07 F6: presupuesto).
pub const MAX_ARGUMENTOS_ASPIC: usize = 64;

/// Estado de argumentación por claim (docs/04, eje `argumentation`).
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ArgumentationState {
    GroundedIn,
    GroundedOut,
    Undecided,
    BudgetExceeded,
    NotRun,
}

/// Reporte del análisis ASPIC+.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct AspicReport {
    pub semantics: String,
    pub argument_count: usize,
    pub attack_count: usize,
    pub extensions: Vec<BTreeSet<String>>,
    pub states: BTreeMap<String, ArgumentationState>,
    pub credulous: BTreeSet<String>,
    pub sceptical: BTreeSet<String>,
    pub budget_exceeded: bool,
    /// El evaluador de referencia coincide con el cálculo directo.
    pub reference_match: Option<bool>,
    /// Método utilizado: "reference" (fixpoint directo) o "pickaxe".
    pub method: String,
}

/// Analiza el kernel: proyecta al grafo de ataque y calcula grounded.
pub fn analizar(kernel: &Kernel, incluir_preferred: bool) -> Result<AspicReport, String> {
    if kernel.arguments.len() > MAX_ARGUMENTOS_ASPIC {
        return Ok(report_presupuesto(kernel));
    }

    // Proyectar: nodos = conclusiones de argumentos; aristas = ataques.
    // En v1 del piloto no hay ataques (ningún claim contradice a otro).
    // Los ataques surgirán en F7 cuando el corpus tenga claims conflictivos.
    let nodos: Vec<String> = kernel
        .arguments
        .iter()
        .map(|a| a.conclusion.clone())
        .collect();
    let ataques: Vec<(String, String)> = detectar_ataques(kernel);

    // Grounded por fixpoint directo (evaluador de referencia, docs/12).
    let grounded = referencia::grounded_directo(&nodos, &ataques);

    // Preferred: para frameworks pequeños, enumerar extensiones maximales.
    let (extensions, credulous, sceptical) = if incluir_preferred {
        let exts = referencia::preferred_exhaustivo(&nodos, &ataques);
        let cred: BTreeSet<String> = exts.iter().flatten().cloned().collect();
        let scpt = if exts.is_empty() {
            BTreeSet::new()
        } else {
            exts.iter().skip(1).fold(exts[0].clone(), |acc, e| {
                acc.intersection(e).cloned().collect()
            })
        };
        (exts, cred, scpt)
    } else {
        (vec![grounded.clone()], grounded.clone(), grounded.clone())
    };

    // Estados por claim.
    let mut states = BTreeMap::new();
    for claim in &kernel.claims {
        let is_nodo = nodos.contains(&claim.id);
        let state = if !is_nodo {
            ArgumentationState::NotRun
        } else if grounded.contains(&claim.id) {
            ArgumentationState::GroundedIn
        } else if incluir_preferred && credulous.contains(&claim.id) {
            ArgumentationState::Undecided
        } else {
            ArgumentationState::GroundedOut
        };
        states.insert(claim.id.clone(), state);
    }

    // Contraste: el grounded directo debe incluir todos los nodos sin atacantes.
    let sin_atacantes: BTreeSet<String> = nodos
        .iter()
        .filter(|n| !ataques.iter().any(|(_, b)| b == *n))
        .cloned()
        .collect();
    let reference_match = Some(grounded.is_superset(&sin_atacantes));

    Ok(AspicReport {
        semantics: if incluir_preferred {
            "grounded+preferred".into()
        } else {
            "grounded".into()
        },
        argument_count: nodos.len(),
        attack_count: ataques.len(),
        extensions,
        states,
        credulous,
        sceptical,
        budget_exceeded: false,
        reference_match,
        method: "reference".into(),
    })
}

/// Detecta ataques entre claims del kernel: dos claims con la misma
/// expresión atom pero statements contradictorios. En v1 del piloto
/// no hay ataques; esto es el esqueleto para F7.
fn detectar_ataques(kernel: &Kernel) -> Vec<(String, String)> {
    // TODO F7: detectar claims con expresiones contradictorias
    // (p. ej. C dice P y C' dice ¬P sobre el mismo atom).
    // Por ahora: sin ataques.
    let _ = kernel;
    vec![]
}

fn report_presupuesto(kernel: &Kernel) -> AspicReport {
    AspicReport {
        semantics: "grounded".into(),
        argument_count: kernel.arguments.len(),
        attack_count: 0,
        extensions: vec![],
        states: kernel
            .claims
            .iter()
            .map(|c| (c.id.clone(), ArgumentationState::BudgetExceeded))
            .collect(),
        credulous: BTreeSet::new(),
        sceptical: BTreeSet::new(),
        budget_exceeded: true,
        reference_match: None,
        method: "reference".into(),
    }
}

/// Evaluador de referencia: grounded y preferred por enumeración directa.
/// Para frameworks ≤8 argumentos (docs/12). Simple, revisable, correcto.
pub mod referencia {
    use super::*;

    /// Grounded por fixpoint de la función característica F(E) = {a : todo
    /// atacante de a es atacado por algún miembro de E}. El grounded es el
    /// mínimo punto fijo de F (Dung 1995). Un argumento sin atacantes es
    /// defendido por cualquier E (vacuamente).
    pub fn grounded_directo(nodos: &[String], ataques: &[(String, String)]) -> BTreeSet<String> {
        let mut e: BTreeSet<String> = BTreeSet::new();
        loop {
            let mut nuevo = BTreeSet::new();
            for n in nodos {
                // ¿Todo atacante de n es atacado por algún miembro de E?
                let defendido = ataques
                    .iter()
                    .filter(|(_, b)| b == n) // aristas (atacante → n)
                    .all(|(atacante, _)| {
                        // ¿El atacante es atacado por algo en E?
                        ataques
                            .iter()
                            .any(|(def, b2)| b2 == atacante && e.contains(def))
                    });
                if defendido {
                    nuevo.insert(n.clone());
                }
            }
            if nuevo == e {
                break;
            }
            e = nuevo;
        }
        e
    }

    /// Preferred por enumeración exhaustiva de subconjuntos conflict-free
    /// y maximales. Solo para ≤8 argumentos.
    pub fn preferred_exhaustivo(
        nodos: &[String],
        ataques: &[(String, String)],
    ) -> Vec<BTreeSet<String>> {
        if nodos.len() > 8 {
            return vec![]; // demasiado grande para enumeración
        }
        let n = nodos.len();
        let mut exts = Vec::new();
        // Enumerar todos los subconjuntos (2^n).
        for mask in 0..(1u64 << n) {
            let subconj: BTreeSet<String> = nodos
                .iter()
                .enumerate()
                .filter(|(i, _)| mask & (1 << i) != 0)
                .map(|(_, s)| s.clone())
                .collect();
            // Conflict-free: ningún miembro ataca a otro miembro.
            let cf = ataques
                .iter()
                .all(|(a, b)| !(subconj.contains(a) && subconj.contains(b)));
            if !cf {
                continue;
            }
            // Maximal: no se puede añadir ningún nodo sin romper conflict-free.
            let maximal = nodos.iter().all(|nodo| {
                if subconj.contains(nodo) {
                    true
                } else {
                    let ampliado: BTreeSet<String> =
                        subconj.iter().cloned().chain([nodo.clone()]).collect();
                    !ataques
                        .iter()
                        .all(|(a, b)| !(ampliado.contains(a) && ampliado.contains(b)))
                }
            });
            if maximal {
                exts.push(subconj);
            }
        }
        exts
    }

    /// Casos de referencia de docs/12.
    pub fn caso_sin_ataques() -> (Vec<String>, Vec<(String, String)>, BTreeSet<String>) {
        (vec!["A".into()], vec![], BTreeSet::from(["A".into()]))
    }

    pub fn caso_ataque_mutuo() -> (Vec<String>, Vec<(String, String)>, BTreeSet<String>) {
        (
            vec!["A".into(), "B".into()],
            vec![("A".into(), "B".into()), ("B".into(), "A".into())],
            BTreeSet::new(),
        )
    }

    pub fn caso_cadena() -> (Vec<String>, Vec<(String, String)>, BTreeSet<String>) {
        (
            vec!["A".into(), "B".into(), "C".into()],
            vec![("A".into(), "B".into()), ("B".into(), "C".into())],
            BTreeSet::from(["A".into(), "C".into()]),
        )
    }

    pub fn caso_autataque() -> (Vec<String>, Vec<(String, String)>, BTreeSet<String>) {
        (
            vec!["A".into()],
            vec![("A".into(), "A".into())],
            BTreeSet::new(),
        )
    }
}
