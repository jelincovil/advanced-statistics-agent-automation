//! Tipos del kernel v1 (schemas/kernel.schema.json del paquete) y carga
//! estricta en capas (docs/03_CONTRATOS.md):
//!
//! 1. JSON estricto ([`crate::strict_json`]): claves duplicadas, NaN y
//!    no finitos rechazados.
//! 2. Validación JSON Schema contra el esquema del paquete, embebido en
//!    el binario (`additionalProperties: false` en todos los niveles).
//! 3. Deserialización serde tipada.
//! 4. Unicidad de IDs por colección.
//!
//! Ninguna capa decide verdad: la forma no es contenido. Los estados
//! verificados se calculan en F2; estos tipos no tienen campos de
//! aprobación (el esquema los rechaza).

use crate::strict_json::parse_strict;
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, HashSet};
use std::path::Path;

/// Esquema del intercambio piloto v1, embebido: el checker no depende de
/// rutas del repo para validar forma.
pub const KERNEL_SCHEMA: &str =
    include_str!("../spec/argumentos_construccion_v1/schemas/kernel.schema.json");

#[derive(Debug, thiserror::Error)]
pub enum LoadError {
    #[error(transparent)]
    Strict(#[from] crate::strict_json::StrictJsonError),
    #[error("esquema del kernel: {0}")]
    Schema(String),
    #[error("ID duplicado en {coleccion}: '{id}'")]
    DuplicateId { coleccion: &'static str, id: String },
    #[error("deserialización tipada: {0}")]
    Typed(#[from] serde_json::Error),
    #[error("IO: {0}")]
    Io(#[from] std::io::Error),
}

/// Documento kernel completo (intercambio piloto v1).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Kernel {
    pub schema_version: String,
    pub claims: Vec<Claim>,
    pub arguments: Vec<Argument>,
    pub evidence_specs: Vec<EvidenceSpec>,
}

/// Afirmación: unidad del canon. `statement` es prosa no confiable como
/// lógica; la cuantificación vive en la expresión y su evidencia.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Claim {
    pub id: String,
    /// Clave histórica del libro (p. ej. `thm:ch9-isomorfismo`), o null.
    pub book_key: Option<String>,
    pub kind: ClaimKind,
    pub statement: String,
    pub expression: Expression,
    /// Alcance: experimento, población, escenario, horizonte, unidad, dominio.
    pub scope: BTreeMap<String, String>,
    /// Supuestos: referencias a otras afirmaciones; son obligaciones.
    pub assumptions: Vec<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ClaimKind {
    Formal,
    Empirical,
    Conditional,
    Factual,
}

/// AST mínima del contrato: `atom`, `implies`, `and`. Dos IDs no son
/// iguales por similitud textual; no se comparan fórmulas por
/// normalización de cadenas. Los campos desconocidos dentro de una
/// variante los rechaza la capa de esquema (limitación conocida de serde
/// con enums internamente etiquetados y `deny_unknown_fields`).
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "op")]
pub enum Expression {
    #[serde(rename = "atom")]
    Atom { id: String },
    #[serde(rename = "implies")]
    Implies {
        antecedent: Box<Expression>,
        consequent: Box<Expression>,
    },
    #[serde(rename = "and")]
    And { items: Vec<Expression> },
}

/// Argumento: derivación finita de premisas a una conclusión por una regla
/// del registro. Dos argumentos pueden concluir lo mismo; se evalúan
/// por separado.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Argument {
    pub id: String,
    /// ID de la afirmación concluida.
    pub conclusion: String,
    /// IDs de afirmaciones usadas como premisas.
    pub premises: Vec<String>,
    pub rule: Rule,
    /// IDs de specs de evidencia que participan.
    pub evidence_specs: Vec<String>,
}

/// Registro de reglas admitidas en v1 (docs/04). Cualquier otra queda
/// `UNSUPPORTED_RULE` en el checker; el esquema ya la rechaza aquí.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Rule {
    LeanAnchor,
    LeanApply,
    AndIntro,
    ModusPonens,
    EmpiricalRecord,
    ConditionalApplication,
    AliasExact,
}

/// Especificación de evidencia: qué se va a ejecutar y qué afirmación
/// exacta respalda. `availability` distingue pendiente de candidato; un
/// recibo válido es cosa del runner y del checker, no de este campo.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct EvidenceSpec {
    pub id: String,
    pub kind: EvidenceKind,
    pub claim_id: String,
    /// Runner autorizado del registro (nunca código libre).
    pub runner_id: String,
    /// Declaración objetivo (p. ej. nombre fully-qualified en Lean).
    pub target: String,
    pub scope: BTreeMap<String, String>,
    pub availability: Availability,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum EvidenceKind {
    Lean,
    Python,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Availability {
    Pending,
    Candidate,
}

/// Carga estricta de un documento kernel desde `path`.
pub fn load_kernel(path: &Path) -> Result<Kernel, LoadError> {
    let text = std::fs::read_to_string(path)?;
    kernel_from_str(&text)
}

/// Carga estricta desde texto (mismo contrato que [`load_kernel`]).
pub fn kernel_from_str(text: &str) -> Result<Kernel, LoadError> {
    let value = parse_strict(text)?;
    validate_schema(KERNEL_SCHEMA, &value)?;
    let kernel: Kernel = serde_json::from_value(value)?;
    check_unique_ids(&kernel)?;
    Ok(kernel)
}

/// Validación de forma contra el esquema embebido. Sin red: el esquema no
/// tiene referencias externas.
pub fn validate_schema(schema_text: &str, value: &serde_json::Value) -> Result<(), LoadError> {
    let schema = parse_strict(schema_text)?;
    let validator = jsonschema::validator_for(&schema)
        .map_err(|e| LoadError::Schema(format!("esquema inválido: {}", e)))?;
    if validator.is_valid(value) {
        return Ok(());
    }
    let mut report = String::from("el documento no cumple el esquema:\n");
    for err in validator.iter_errors(value) {
        report.push_str(&format!("  - {} (en {})\n", err, err.instance_path()));
    }
    Err(LoadError::Schema(report))
}

fn check_unique_ids(kernel: &Kernel) -> Result<(), LoadError> {
    check_ids("claims", kernel.claims.iter().map(|c| c.id.clone()))?;
    check_ids("arguments", kernel.arguments.iter().map(|a| a.id.clone()))?;
    check_ids(
        "evidence_specs",
        kernel.evidence_specs.iter().map(|e| e.id.clone()),
    )?;
    Ok(())
}

/// Unicidad de IDs dentro de una colección (docs/03: prohibir IDs duplicados).
/// El esquema ya exige `uniqueItems` dentro de una lista; esto cubre IDs
/// repetidos entre elementos de una misma colección.
fn check_ids(coleccion: &'static str, ids: impl Iterator<Item = String>) -> Result<(), LoadError> {
    let mut seen: HashSet<String> = HashSet::new();
    for id in ids {
        if !seen.insert(id.clone()) {
            return Err(LoadError::DuplicateId { coleccion, id });
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const POSITIVO: &str = r#"{
      "schema_version": "1.0",
      "claims": [{
        "id": "C.P", "book_key": null, "kind": "formal",
        "statement": "prueba", "expression": {"op": "atom", "id": "P"},
        "scope": {}, "assumptions": []
      }],
      "arguments": [],
      "evidence_specs": []
    }"#;

    #[test]
    fn positivo_minimo_carga() {
        let k = kernel_from_str(POSITIVO).unwrap();
        assert_eq!(k.claims.len(), 1);
        assert_eq!(k.claims[0].expression, Expression::Atom { id: "P".into() });
    }

    #[test]
    fn campo_de_aprobacion_rechazado_por_esquema() {
        let mut v = parse_strict(POSITIVO).unwrap();
        v["claims"][0]["approved"] = serde_json::Value::Bool(true);
        let text = serde_json::to_string(&v).unwrap();
        let err = kernel_from_str(&text).unwrap_err();
        assert!(
            matches!(err, LoadError::Schema(_)),
            "era esquema: {:?}",
            err
        );
    }

    #[test]
    fn id_duplicado_rechazado() {
        let mut v = parse_strict(POSITIVO).unwrap();
        let dup = v["claims"][0].clone();
        v["claims"].as_array_mut().unwrap().push(dup);
        let text = serde_json::to_string(&v).unwrap();
        let err = kernel_from_str(&text).unwrap_err();
        match err {
            LoadError::DuplicateId { coleccion, id } => {
                assert_eq!(coleccion, "claims");
                assert_eq!(id, "C.P");
            }
            other => panic!("esperaba DuplicateId, llegó {:?}", other),
        }
    }

    #[test]
    fn regla_desconocida_rechazada() {
        let mut v = parse_strict(POSITIVO).unwrap();
        v["arguments"]
            .as_array_mut()
            .unwrap()
            .push(serde_json::json!({
                "id": "A.1", "conclusion": "C.P", "premises": [],
                "rule": "MAJORITY_VOTE", "evidence_specs": []
            }));
        let text = serde_json::to_string(&v).unwrap();
        assert!(matches!(
            kernel_from_str(&text).unwrap_err(),
            LoadError::Schema(_)
        ));
    }
}
