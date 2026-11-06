//! Pruebas de contrato F1: los fixtures del paquete de especificación.
//! Positivos cargan; negativos de nivel de carga fallan por la razón
//! esperada. Los negativos de reglas (ciclo, conclusión MP, alcance…)
//! son material de F2 y aquí solo se verifica que su ESTRUCTURA carga.

use argumentos::model::{load_kernel, LoadError};
use std::path::Path;

fn fixture(name: &str) -> std::path::PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("spec/argumentos_construccion_v1/examples")
        .join(name)
}

const POSITIVOS: &[&str] = &[
    "valid_structure_pending.json",
    "lean_anchor_pending.json",
    "empirical_pending.json",
];

const NEGATIVOS_DE_REGLAS_F2: &[&str] = &[
    "invalid_conclusion.json",
    "invalid_cycle.json",
    "invalid_empirical_promotion.json",
    "invalid_evidence_target.json",
    "invalid_missing_premise.json",
    "invalid_scope.json",
];

#[test]
fn positivos_del_paquete_cargan() {
    for f in POSITIVOS {
        let k = load_kernel(&fixture(f)).unwrap_or_else(|e| panic!("{} debía cargar: {}", f, e));
        assert!(!k.claims.is_empty(), "{} sin claims", f);
    }
}

#[test]
fn negativo_id_duplicado_falla_por_esa_razon() {
    let err = load_kernel(&fixture("invalid_duplicate_id.json")).unwrap_err();
    match err {
        LoadError::DuplicateId { coleccion, .. } => assert_eq!(coleccion, "claims"),
        other => panic!("esperaba DuplicateId, llegó: {:?}", other),
    }
}

#[test]
fn negativo_autoaprobacion_falla_por_esquema() {
    // El campo de aprobación insertado por el agente debe rechazarse:
    // el estado verificado nunca se acepta de un campo (ADR-10).
    let err = load_kernel(&fixture("invalid_self_approval.json")).unwrap_err();
    assert!(
        matches!(err, LoadError::Schema(_)),
        "esperaba Schema, llegó: {:?}",
        err
    );
}

#[test]
fn negativos_de_reglas_cargan_estructuralmente() {
    // Documentación viva del alcance de F1: estos fixtures violan reglas
    // del CHECKER (F2), no la forma. Cargarlos aquí está bien; rechazarlos
    // por su razón es la puerta de F2.
    for f in NEGATIVOS_DE_REGLAS_F2 {
        assert!(
            load_kernel(&fixture(f)).is_ok(),
            "{} debería ser estructuralmente válido (su rechazo es de F2)",
            f
        );
    }
}

#[test]
fn ida_y_vuelta_canonica() {
    // docs/03: serialización con orden fijo de claves; el ida/vuelta
    // debe preservar el documento.
    let path = fixture("valid_structure_pending.json");
    let original = std::fs::read_to_string(&path).unwrap();
    let k1 = load_kernel(&path).unwrap();
    let serialized = serde_json::to_string_pretty(&k1).unwrap();
    let k2 = argumentos::model::kernel_from_str(&serialized).unwrap();
    assert_eq!(k1, k2);
    // Y el texto original sigue siendo carga válida (determinismo de lectura).
    assert!(argumentos::model::kernel_from_str(&original).is_ok());
}
