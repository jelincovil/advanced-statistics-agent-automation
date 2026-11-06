//! Recibos de evidencia (schemas/receipt.schema.json) con la consistencia
//! adicional que docs/12 exige en código, más allá del esquema:
//! `execution_passed = true` exige `termination = completed` y
//! `exit_status = Some(0)`.
//!
//! Un recibo ingresado es candidato: para certificar hay que reproducirlo
//! o verificarlo bajo una política de atestación explícita. `trust_mode`
//! registra esa distinción; el hash detecta cambio de bytes, no veracidad.

use crate::strict_json::parse_strict;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::path::Path;

/// Esquema de recibos v1, embebido.
pub const RECEIPT_SCHEMA: &str =
    include_str!("../spec/argumentos_construccion_v1/schemas/receipt.schema.json");

#[derive(Debug, thiserror::Error)]
pub enum ReceiptError {
    #[error(transparent)]
    Strict(#[from] crate::strict_json::StrictJsonError),
    #[error("esquema del recibo: {0}")]
    Schema(String),
    #[error("deserialización tipada: {0}")]
    Typed(#[from] serde_json::Error),
    #[error("consistencia: execution_passed=true exige termination=completed y exit_status=0")]
    Inconsistent,
    #[error("IO: {0}")]
    Io(#[from] std::io::Error),
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Receipt {
    pub schema_version: String,
    pub id: String,
    pub spec_id: String,
    pub spec_hash: String,
    pub source_commit: String,
    pub environment_hash: String,
    pub checker_version: String,
    pub command_argv: Vec<String>,
    pub working_directory: String,
    pub input_hashes: BTreeMap<String, String>,
    pub started_at: String,
    pub finished_at: String,
    pub exit_status: Option<i64>,
    pub termination: Termination,
    pub stdout_sha256: String,
    pub stderr_sha256: String,
    pub artifacts: Vec<Artifact>,
    /// Ejecución con exit 0 y terminación completa. Distinto de
    /// `scientific_criterion_met` y de `claim_supported` (docs/03).
    pub execution_passed: bool,
    pub scientific_criterion_met: Option<bool>,
    pub observed_checks: Vec<ObservedCheck>,
    pub trust_mode: TrustMode,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Termination {
    Completed,
    Timeout,
    ResourceLimit,
    LaunchFailed,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Artifact {
    pub path: String,
    pub sha256: String,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ObservedCheck {
    pub id: String,
    pub status: CheckStatus,
    pub detail: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum CheckStatus {
    Pass,
    Fail,
    Skip,
    Pending,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum TrustMode {
    LocallyReproduced,
    UntrustedImport,
    AttestedByConfiguredPolicy,
}

/// Carga estricta de un recibo: JSON estricto → esquema → tipos →
/// consistencia código+esquema de `execution_passed`.
pub fn load_receipt(path: &Path) -> Result<Receipt, ReceiptError> {
    let text = std::fs::read_to_string(path)?;
    receipt_from_str(&text)
}

pub fn receipt_from_str(text: &str) -> Result<Receipt, ReceiptError> {
    let value = parse_strict(text)?;
    let schema = parse_strict(RECEIPT_SCHEMA)?;
    let validator = jsonschema::validator_for(&schema)
        .map_err(|e| ReceiptError::Schema(format!("esquema inválido: {}", e)))?;
    if !validator.is_valid(&value) {
        let mut report = String::from("el recibo no cumple el esquema:\n");
        for err in validator.iter_errors(&value) {
            report.push_str(&format!("  - {} (en {})\n", err, err.instance_path()));
        }
        return Err(ReceiptError::Schema(report));
    }
    let receipt: Receipt = serde_json::from_value(value)?;
    // Consistencia en código (docs/12): no basta confiar en el esquema.
    if receipt.execution_passed
        && (receipt.termination != Termination::Completed || receipt.exit_status != Some(0))
    {
        return Err(ReceiptError::Inconsistent);
    }
    Ok(receipt)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn recibo_minimo(execution_passed: bool, termination: &str, exit: Option<i64>) -> String {
        let exit_json = match exit {
            Some(e) => e.to_string(),
            None => "null".to_string(),
        };
        format!(
            r#"{{
              "schema_version": "1.0", "id": "R.1", "spec_id": "E.1",
              "spec_hash": "{}", "source_commit": "0000", "environment_hash": "{}",
              "checker_version": "0.1.0", "command_argv": ["true"],
              "working_directory": "/tmp", "input_hashes": {{}},
              "started_at": "t0", "finished_at": "t1",
              "exit_status": {}, "termination": "{}",
              "stdout_sha256": "{}", "stderr_sha256": "{}",
              "artifacts": [], "execution_passed": {},
              "scientific_criterion_met": null, "observed_checks": [],
              "trust_mode": "locally_reproduced"
            }}"#,
            "a".repeat(64),
            "b".repeat(64),
            exit_json,
            termination,
            "c".repeat(64),
            "d".repeat(64),
            execution_passed
        )
    }

    #[test]
    fn recibo_consistente_carga() {
        let text = recibo_minimo(true, "completed", Some(0));
        assert!(receipt_from_str(&text).is_ok());
    }

    #[test]
    fn execution_passed_sin_exit_cero_rechazado() {
        let text = recibo_minimo(true, "completed", Some(1));
        assert!(matches!(
            receipt_from_str(&text).unwrap_err(),
            ReceiptError::Inconsistent
        ));
    }

    #[test]
    fn execution_passed_con_timeout_rechazado() {
        let text = recibo_minimo(true, "timeout", Some(0));
        assert!(matches!(
            receipt_from_str(&text).unwrap_err(),
            ReceiptError::Inconsistent
        ));
    }

    #[test]
    fn fallo_ejecucion_honesto_carga() {
        // execution_passed=false con exit 1 es un recibo válido: registra
        // un fallo real, no lo convierte en aprobación por defecto.
        let text = recibo_minimo(false, "completed", Some(1));
        assert!(receipt_from_str(&text).is_ok());
    }
}
