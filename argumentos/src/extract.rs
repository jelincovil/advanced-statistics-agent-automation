//! Adaptador de extracción GLM con replay determinista (docs/06, plan F5).
//!
//! Contrato del proveedor (docs/06): entrada con IDs de bloque y bytes
//! exactos; salida JSON de candidatos con citas textuales y offsets. El
//! alineador verifica `text[start:end] == quote`. GLM nunca escribe
//! releases ni receipts; los campos de aprobación del modelo se rechazan.
//!
//! Sin endpoint configurado: `LiveExtractor` devuelve
//! `ProviderUnavailable` y el flujo continúa en modo replay
//! (`LIVE_PROVIDER_PENDING`, docs/09).

use crate::model::Claim;
use serde::{Deserialize, Serialize};
use sha2::Digest;
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

// ---------------------------------------------------------------------------
// Configuración del proveedor
// ---------------------------------------------------------------------------

/// Configuración del proveedor (templates/provider.example.json del paquete).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ProviderConfig {
    pub provider: String,
    pub base_url_env: String,
    pub api_key_env: String,
    pub model_env: String,
    pub expected_model: String,
    pub live_enabled: bool,
    pub temperature: f64,
    pub seed: Option<u64>,
    pub max_requests: u64,
    pub store_raw_responses: bool,
    /// "replay" o "live".
    pub mode: String,
}

impl ProviderConfig {
    /// Configuración por defecto: replay, sin endpoint.
    pub fn replay_default() -> Self {
        Self {
            provider: "configured_glm_endpoint".into(),
            base_url_env: "ARG_GLM_BASE_URL".into(),
            api_key_env: "ARG_GLM_API_KEY".into(),
            model_env: "ARG_GLM_MODEL".into(),
            expected_model: "GLM 5.3 (no confirmado; sin endpoint en esta VM)".into(),
            live_enabled: false,
            temperature: 0.0,
            seed: None,
            max_requests: 0,
            store_raw_responses: true,
            mode: "replay".into(),
        }
    }

    /// Carga desde archivo JSON estricto.
    pub fn load(path: &Path) -> Result<Self, String> {
        let text = std::fs::read_to_string(path)
            .map_err(|e| format!("no pude leer {}: {}", path.display(), e))?;
        let value =
            crate::strict_json::parse_strict(&text).map_err(|e| format!("JSON estricto: {}", e))?;
        serde_json::from_value(value).map_err(|e| format!("deserialización: {}", e))
    }

    /// ¿Hay endpoint disponible? Verifica las variables de entorno.
    pub fn endpoint_available(&self) -> bool {
        std::env::var(&self.base_url_env).is_ok()
            && std::env::var(&self.api_key_env).is_ok()
            && std::env::var(&self.model_env).is_ok()
    }
}

// ---------------------------------------------------------------------------
// Contrato de extracción
// ---------------------------------------------------------------------------

/// Solicitud de extracción: bloques con sus bytes exactos.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtractionRequest {
    pub prompt_version: String,
    pub blocks: Vec<BlockInput>,
}

/// Un bloque para extraer: ID + contenido exacto.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockInput {
    pub key: String,
    pub kind: String,
    pub name: String,
    /// Contenido exacto del bloque (bytes UTF-8 del thm-env).
    pub content: String,
}

/// Respuesta de extracción: candidatos con citas y offsets.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtractionResponse {
    pub model: String,
    pub prompt_version: String,
    pub candidates: Vec<CandidateClaim>,
    /// Respuesta cruda del proveedor (para replay y auditoría).
    pub raw_response: String,
}

/// Un candidato propuesto por el extractor: NUNCA es autoridad.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CandidateClaim {
    /// Clave del bloque del que proviene.
    pub block_key: String,
    /// El claim propuesto (sin estado de aprobación).
    pub claim: ClaimDraft,
    /// Cita textual exacta del bloque.
    pub quote: String,
    /// Offset UTF-8 de bytes [start, end) dentro del contenido del bloque.
    pub quote_start: usize,
    pub quote_end: usize,
}

/// Borrador de claim propuesto por el extractor. Sin campos de aprobación
/// (ADR-10): el checker decide, no el modelo.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ClaimDraft {
    pub id: String,
    pub kind: String,
    pub statement: String,
    pub scope: BTreeMap<String, String>,
    pub assumptions: Vec<String>,
}

// ---------------------------------------------------------------------------
// Trait Extractor (docs/12: no acoplar a tipos privados de langextract)
// ---------------------------------------------------------------------------

#[derive(Debug, thiserror::Error)]
pub enum ExtractorError {
    #[error("proveedor no disponible: {0}")]
    ProviderUnavailable(String),
    #[error("respuesta malformada: {0}")]
    MalformedResponse(String),
    #[error("error de IO: {0}")]
    Io(#[from] std::io::Error),
    #[error("presupuesto excedido: {0}")]
    BudgetExceeded(String),
}

/// Trait del extractor: entrada con bloques, salida con candidatos.
pub trait Extractor {
    fn extract(&self, request: &ExtractionRequest) -> Result<ExtractionResponse, ExtractorError>;
    fn mode(&self) -> &'static str;
}

// ---------------------------------------------------------------------------
// ReplayExtractor: determinista, sin red
// ---------------------------------------------------------------------------

/// Reproduce exactamente una respuesta archivada. Determinista: la misma
/// entrada produce la misma salida (docs/06: "replay debe reconstruir
/// exactamente candidatos y reportes deterministas").
pub struct ReplayExtractor {
    archive_dir: PathBuf,
}

impl ReplayExtractor {
    pub fn new(archive_dir: impl Into<PathBuf>) -> Self {
        Self {
            archive_dir: archive_dir.into(),
        }
    }

    /// Busca el archivo de replay para esta solicitud (hash del request).
    fn archive_path(&self, request: &ExtractionRequest) -> PathBuf {
        let canon = serde_json::to_string(request).unwrap_or_default();
        let hash = format!("{:x}", sha2::Sha256::digest(canon.as_bytes()));
        self.archive_dir
            .join(format!("replay_{}.json", &hash[..16]))
    }
}

impl Extractor for ReplayExtractor {
    fn extract(&self, request: &ExtractionRequest) -> Result<ExtractionResponse, ExtractorError> {
        let path = self.archive_path(request);
        if !path.exists() {
            return Err(ExtractorError::ProviderUnavailable(format!(
                "sin replay archivado para esta solicitud en {}",
                path.display()
            )));
        }
        let text = std::fs::read_to_string(&path)?;
        let value = crate::strict_json::parse_strict(&text)
            .map_err(|e| ExtractorError::MalformedResponse(format!("JSON estricto: {}", e)))?;
        let response: ExtractionResponse = serde_json::from_value(value)
            .map_err(|e| ExtractorError::MalformedResponse(format!("deserialización: {}", e)))?;
        Ok(response)
    }

    fn mode(&self) -> &'static str {
        "replay"
    }
}

// ---------------------------------------------------------------------------
// LiveExtractor: stub sin endpoint (LIVE_PROVIDER_PENDING)
// ---------------------------------------------------------------------------

pub struct LiveExtractor {
    pub config: ProviderConfig,
}

impl Extractor for LiveExtractor {
    fn extract(&self, _request: &ExtractionRequest) -> Result<ExtractionResponse, ExtractorError> {
        if !self.config.live_enabled {
            return Err(ExtractorError::ProviderUnavailable(
                "live_enabled=false en la configuración".into(),
            ));
        }
        if !self.config.endpoint_available() {
            return Err(ExtractorError::ProviderUnavailable(format!(
                "variables de entorno no configuradas: {}, {}, {}",
                self.config.base_url_env, self.config.api_key_env, self.config.model_env
            )));
        }
        // Con endpoint disponible, aquí iría la llamada HTTP real.
        // No se implementa en v1: docs/09 salida alternativa.
        Err(ExtractorError::ProviderUnavailable(
            "integración live no implementada en v1 (LIVE_PROVIDER_PENDING)".into(),
        ))
    }

    fn mode(&self) -> &'static str {
        "live"
    }
}

// ---------------------------------------------------------------------------
// Alineador: verificar citas exactas (docs/06)
// ---------------------------------------------------------------------------

/// Verifica que `text[start..end]` (bytes UTF-8) sea exactamente `quote`.
/// Distingue offsets UTF-8 de caracteres: el contrato es BYTES.
pub fn verify_quote(text: &str, start: usize, end: usize, quote: &str) -> Result<(), String> {
    if start >= text.len() || end > text.len() || start > end {
        return Err(format!(
            "rango [{}, {}) fuera de los límites del texto (len {})",
            start,
            end,
            text.len()
        ));
    }
    let fragment = &text[start..end];
    if fragment != quote {
        return Err(format!(
            "cita no coincide: esperada {:?} en [{}, {}), encontrada {:?}",
            &quote[..quote.len().min(40)],
            start,
            end,
            &fragment[..fragment.len().min(40)]
        ));
    }
    Ok(())
}

// ---------------------------------------------------------------------------
// Diff semántico (docs/06: exacto primero, redacción después)
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum DiffKind {
    MissingClaim,
    UnsupportedClaim,
    MissingAssumption,
    ChangedQuantifier,
    ChangedScope,
    StaleEvidence,
    NumericalMismatch,
    UnresolvedMapping,
    HarmlessWording,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Diff {
    pub kind: DiffKind,
    pub detail: String,
    /// Fragmento exacto del candidato (para auditoría).
    pub source_fragment: String,
}

/// Compara un claim existente del kernel contra un candidato propuesto.
/// Exacto primero (scope, kind, assumptions), redacción después.
pub fn semantic_diff(existing: &Claim, candidate: &CandidateClaim) -> Vec<Diff> {
    let mut diffs = Vec::new();

    // Alcance: cambio de dominio o de cualquier clave compartida.
    for (k, v) in &candidate.claim.scope {
        match existing.scope.get(k) {
            Some(ev) if ev != v => {
                diffs.push(Diff {
                    kind: DiffKind::ChangedScope,
                    detail: format!("alcance '{}': kernel='{}', candidato='{}'", k, ev, v),
                    source_fragment: candidate.quote.clone(),
                });
            }
            None => {
                // Clave nueva en el candidato: informativo, no necesariamente error.
            }
            _ => {}
        }
    }
    for (k, v) in &existing.scope {
        if !candidate.claim.scope.contains_key(k) {
            diffs.push(Diff {
                kind: DiffKind::ChangedScope,
                detail: format!(
                    "alcance '{}' presente en el kernel pero ausente en el candidato (era '{}')",
                    k, v
                ),
                source_fragment: candidate.quote.clone(),
            });
        }
    }

    // Supuestos faltantes.
    for a in &existing.assumptions {
        if !candidate.claim.assumptions.contains(a) {
            diffs.push(Diff {
                kind: DiffKind::MissingAssumption,
                detail: format!("supuesto '{}' del kernel ausente en el candidato", a),
                source_fragment: candidate.quote.clone(),
            });
        }
    }

    // Kind: cambio de clase de afirmación.
    let existing_kind = format!("{:?}", existing.kind).to_lowercase();
    if existing_kind != candidate.claim.kind {
        diffs.push(Diff {
            kind: DiffKind::ChangedQuantifier,
            detail: format!(
                "kind: kernel='{}', candidato='{}'",
                existing_kind, candidate.claim.kind
            ),
            source_fragment: candidate.quote.clone(),
        });
    }

    // Redacción: si todo lo anterior está bien, una diferencia de
    // statement es harmless_wording (revisión editorial, no matemática).
    if diffs.is_empty() && existing.statement != candidate.claim.statement {
        diffs.push(Diff {
            kind: DiffKind::HarmlessWording,
            detail: "diferencia de redacción en el enunciado (revisión editorial)".into(),
            source_fragment: candidate.quote.clone(),
        });
    }

    diffs
}

// ---------------------------------------------------------------------------
// Validación de candidatos (docs/06: campos de aprobación rechazados)
// ---------------------------------------------------------------------------

/// Valida un candidato: la cita debe alinear y no debe contener campos
/// de aprobación. El modelo NUNCA aprueba (ADR-10).
pub fn validate_candidate(
    candidate: &CandidateClaim,
    block_content: &str,
) -> Result<Vec<Diff>, String> {
    // Verificar la cita con el alineador.
    verify_quote(
        block_content,
        candidate.quote_start,
        candidate.quote_end,
        &candidate.quote,
    )
    .map_err(|e| format!("alineación fallida para {}: {}", candidate.claim.id, e))?;
    Ok(Vec::new()) // Sin diffs estructurales en la validación básica.
}
