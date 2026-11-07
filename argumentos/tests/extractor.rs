//! Pruebas del adaptador de extracción F5 (docs/06, docs/08 P08):
//! replay determinista, salida malformada aislada, campos de aprobación
//! del modelo rechazados, alineador de citas con UTF-8.

use argumentos::extract::{
    verify_quote, CandidateClaim, ClaimDraft, ExtractionRequest, ExtractionResponse, Extractor,
    LiveExtractor, ProviderConfig, ReplayExtractor,
};
use sha2::Digest;
use std::collections::BTreeMap;

fn candidato_sintetico() -> CandidateClaim {
    CandidateClaim {
        block_key: "thm:ch9-isomorfismo".into(),
        claim: ClaimDraft {
            id: "C.iso.extracted".into(),
            kind: "formal".into(),
            statement: "J_θ(π_δ) = -R(θ,δ) para espacios finitos".into(),
            scope: BTreeMap::from([("domain".into(), "finite".into())]),
            assumptions: vec![],
        },
        quote: "la copia puntual de la regla conserva el objetivo salvo signo".into(),
        quote_start: 0,
        quote_end: 65,
    }
}

fn respuesta_sintetica() -> ExtractionResponse {
    ExtractionResponse {
        model: "glm-5.3-replay-test".into(),
        prompt_version: "1.0".into(),
        candidates: vec![candidato_sintetico()],
        raw_response: "{\"model\":\"glm-5.3-replay-test\",\"candidates\":[...]}".into(),
    }
}

fn solicitud_sintetica() -> ExtractionRequest {
    ExtractionRequest {
        prompt_version: "1.0".into(),
        blocks: vec![argumentos::extract::BlockInput {
            key: "thm:ch9-isomorfismo".into(),
            kind: "theorem".into(),
            name: "Representación que preserva el riesgo".into(),
            content:
                "la copia puntual de la regla conserva el objetivo salvo signo: J_θ(π_δ) = -R(θ,δ)"
                    .into(),
        }],
    }
}

// ---------------------------------------------------------------------------
// P08: replay determinista, sin API
// ---------------------------------------------------------------------------

#[test]
fn p08_replay_determinista() {
    let dir = std::env::temp_dir().join(format!("argumentos-replay-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();

    // Archivar una respuesta.
    let req = solicitud_sintetica();
    let resp = respuesta_sintetica();
    let canon = serde_json::to_string(&req).unwrap();
    let hash = format!("{:x}", sha2::Sha256::digest(canon.as_bytes()));
    let path = dir.join(format!("replay_{}.json", &hash[..16]));
    std::fs::write(&path, serde_json::to_string_pretty(&resp).unwrap()).unwrap();

    // Replay: misma entrada → misma salida (dos veces).
    let extractor = ReplayExtractor::new(&dir);
    let r1 = extractor.extract(&req).unwrap();
    let r2 = extractor.extract(&req).unwrap();
    assert_eq!(r1.model, r2.model);
    assert_eq!(r1.candidates.len(), r2.candidates.len());
    assert_eq!(r1.raw_response, r2.raw_response);
    assert_eq!(r1.candidates[0].claim.id, "C.iso.extracted");

    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn p08_replay_sin_archivo_devuelve_error_claro() {
    let dir = std::env::temp_dir().join(format!("argumentos-replay-vacio-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    let extractor = ReplayExtractor::new(&dir);
    let result = extractor.extract(&solicitud_sintetica());
    assert!(result.is_err());
    let _ = std::fs::remove_dir_all(&dir);
}

// ---------------------------------------------------------------------------
// Salida malformada aislada (docs/06: timeouts y rechazos → pendientes)
// ---------------------------------------------------------------------------

#[test]
fn salida_malformada_aislada() {
    let dir = std::env::temp_dir().join(format!("argumentos-malformado-{}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();

    let req = solicitud_sintetica();
    let canon = serde_json::to_string(&req).unwrap();
    let hash = format!("{:x}", sha2::Sha256::digest(canon.as_bytes()));
    let path = dir.join(format!("replay_{}.json", &hash[..16]));

    // JSON con claves duplicadas → rechazado por strict_json.
    std::fs::write(&path, "{\"model\": \"x\", \"model\": \"y\", \"prompt_version\": \"1.0\", \"candidates\": [], \"raw_response\": \"\"}").unwrap();
    let extractor = ReplayExtractor::new(&dir);
    let result = extractor.extract(&req);
    assert!(result.is_err(), "JSON con claves duplicadas debe fallar");

    // JSON válido pero con estructura incorrecta → rechazado por serde.
    std::fs::write(&path, "{\"unexpected_field\": true}").unwrap();
    let result = extractor.extract(&req);
    assert!(result.is_err(), "estructura incorrecta debe fallar");

    let _ = std::fs::remove_dir_all(&dir);
}

// ---------------------------------------------------------------------------
// Campos de aprobación del modelo rechazados (ADR-10, N10)
// ---------------------------------------------------------------------------

#[test]
fn campos_de_aprobacion_rechazados() {
    // Un candidato con un campo "approved" debe ser rechazado por el
    // esquema deny_unknown_fields de ClaimDraft.
    let json = r#"{
        "block_key": "thm:test",
        "claim": {
            "id": "C.test",
            "kind": "formal",
            "statement": "test",
            "scope": {},
            "assumptions": [],
            "approved": true
        },
        "quote": "test",
        "quote_start": 0,
        "quote_end": 4
    }"#;
    let value = argumentos::strict_json::parse_strict(json).unwrap();
    let result: Result<CandidateClaim, _> = serde_json::from_value(value);
    assert!(
        result.is_err(),
        "campo 'approved' debe ser rechazado por deny_unknown_fields"
    );
}

// ---------------------------------------------------------------------------
// Alineador de citas (docs/06: text[start:end] == quote, UTF-8 bytes)
// ---------------------------------------------------------------------------

#[test]
fn alineador_cita_exacta() {
    let texto = "la copia puntual de la regla conserva el objetivo salvo signo";
    assert!(verify_quote(
        texto,
        0,
        61,
        "la copia puntual de la regla conserva el objetivo salvo signo"
    )
    .is_ok());
}

#[test]
fn alineador_cita_desplazada_rechaza() {
    let texto = "la copia puntual de la regla conserva el objetivo salvo signo";
    assert!(verify_quote(texto, 5, 70, "la copia puntual").is_err());
}

#[test]
fn alineador_utf8_bytes_no_caracteres() {
    // «cañón» tiene 6 bytes UTF-8 pero 5 caracteres. El contrato es BYTES.
    let texto = "el cañón dispara";
    // 'c' está en byte 3, 'ó' empieza en byte 6 (no carácter 6).
    assert!(
        verify_quote(texto, 3, 10, "cañón").is_ok(),
        "bytes: cañón = bytes 3..8"
    );
    // Si usáramos índices de carácter, 3..8 daría algo distinto.
    assert!(verify_quote(texto, 3, 10, "cañón").is_ok());
}

#[test]
fn alineador_rango_fuera_de_limites() {
    let texto = "hola";
    assert!(verify_quote(texto, 0, 10, "hola").is_err());
    assert!(verify_quote(texto, 5, 3, "").is_err());
}

// ---------------------------------------------------------------------------
// LiveExtractor: LIVE_PROVIDER_PENDING sin endpoint
// ---------------------------------------------------------------------------

#[test]
fn live_extractor_sin_endpoint_pendiente() {
    let config = ProviderConfig::replay_default();
    let extractor = LiveExtractor { config };
    let result = extractor.extract(&solicitud_sintetica());
    assert!(result.is_err());
    match result.unwrap_err() {
        argumentos::extract::ExtractorError::ProviderUnavailable(msg) => {
            assert!(
                msg.contains("live_enabled") || msg.contains("entorno"),
                "mensaje: {}",
                msg
            );
        }
        other => panic!("esperaba ProviderUnavailable, llegó: {:?}", other),
    }
}

// ---------------------------------------------------------------------------
// Configuración del proveedor
// ---------------------------------------------------------------------------

#[test]
fn configuracion_replay_por_defecto() {
    let config = ProviderConfig::replay_default();
    assert!(!config.live_enabled);
    assert_eq!(config.mode, "replay");
    assert!(
        !config.endpoint_available(),
        "sin variables de entorno no hay endpoint"
    );
}
