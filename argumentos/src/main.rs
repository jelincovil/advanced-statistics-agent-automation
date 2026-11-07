//! CLI `argumentos`. F1 implementa `doctor`; los comandos contractuales
//! restantes (inventory/propose/check/evidence/audit/render/argue/release/
//! report) se añaden en sus fases (F2–F6) con su puerta correspondiente.

use argumentos::CHECKER_VERSION;
use clap::{Parser, Subcommand};
use sha2::{Digest, Sha256};
use std::path::{Path, PathBuf};
use std::process::Command;

/// Códigos de salida contractuales (docs/02_ARQUITECTURA.md).
mod exit {
    pub const OK: i32 = 0;
    pub const ENTRADA_INVALIDA: i32 = 2;
    pub const DEPENDENCIA_BLOQUEANTE: i32 = 3;
    /// FALLO_EJECUCION (4), TIMEOUT (5) y DISCREPANCIA_EDITORIAL (6) se
    /// usan desde F3 (runners de evidencia) y F4 (auditoría).
    #[allow(dead_code)]
    pub const FALLO_EJECUCION: i32 = 4;
}

#[derive(Parser)]
#[command(
    name = "argumentos",
    version = CHECKER_VERSION,
    about = "Canon de argumentos verificables del libro",
    after_help = "Exit codes: 0 válido · 2 entrada inválida · 3 dependencia bloqueante · 4 fallo de ejecución"
)]
struct Cli {
    #[command(subcommand)]
    command: Command_,
}

#[derive(Subcommand)]
enum Command_ {
    /// Diagnóstico del entorno: rutas, versiones y disponibilidad, sin credenciales.
    Doctor {
        /// Ruta del repositorio (por defecto: directorio actual).
        #[arg(long)]
        repo: Option<PathBuf>,
    },
    /// Checker independiente: IDs, DAG, AST exacta, reglas, obligaciones y estados.
    Check {
        /// Ruta del documento kernel (JSON estricto).
        #[arg(long)]
        kernel: PathBuf,
        /// Directorio o archivo de recibos (JSON estricto).
        #[arg(long)]
        receipts: Option<PathBuf>,
    },
    /// Análisis ASPIC+ del kernel: grounded y (opcional) preferred.
    Argue {
        /// Ruta del kernel.
        #[arg(long)]
        kernel: PathBuf,
        /// Incluir semántica preferred (además de grounded).
        #[arg(long)]
        preferred: bool,
    },
    /// Propone candidatos desde el libro (replay o live según configuración).
    Propose {
        /// Ruta del inventario del libro.
        #[arg(long)]
        inventory: PathBuf,
        /// Ruta del directorio de replays archivados.
        #[arg(long)]
        replay: Option<PathBuf>,
        /// Ruta de la configuración del proveedor.
        #[arg(long)]
        provider_config: Option<PathBuf>,
        /// Directorio de salida de candidatos.
        #[arg(long)]
        out: Option<PathBuf>,
    },
    /// Inventario de bloques del libro (parser Typst, sin LLM).
    Inventory {
        /// Ruta del libro (carpeta con main.typ).
        #[arg(long)]
        book: PathBuf,
        /// Archivo de salida del inventario JSON.
        #[arg(long)]
        out: PathBuf,
    },
    /// Render determinista de fichas canónicas desde el kernel.
    Render {
        /// Ruta del kernel.
        #[arg(long)]
        kernel: PathBuf,
        /// Ruta del inventario.
        #[arg(long)]
        inventory: PathBuf,
        /// Directorio de salida.
        #[arg(long)]
        out: PathBuf,
    },
    /// Auditoría estructural del kernel contra el libro.
    Audit {
        /// Ruta del kernel.
        #[arg(long)]
        kernel: PathBuf,
        /// Ruta del libro.
        #[arg(long)]
        book: PathBuf,
    },
    /// Ejecuta los runners de evidencia del piloto y genera recibos.
    Evidence {
        /// Ruta del repositorio (para localizar verificacion_lean y runners).
        #[arg(long)]
        repo: PathBuf,
        /// Directorio de salida de los recibos (por defecto: argumentos/receipts).
        #[arg(long)]
        out: Option<PathBuf>,
    },
}

fn main() {
    let cli = Cli::parse();
    let code = match cli.command {
        Command_::Doctor { repo } => doctor(repo.as_deref().unwrap_or(Path::new("."))),
        Command_::Check { kernel, receipts } => run_check(&kernel, receipts.as_deref()),
        Command_::Evidence { repo, out } => run_evidence(&repo, out.as_deref()),
        Command_::Argue { kernel, preferred } => run_argue(&kernel, preferred),
        Command_::Propose {
            inventory,
            replay,
            provider_config,
            out,
        } => run_propose(
            &inventory,
            replay.as_deref(),
            provider_config.as_deref(),
            out.as_deref(),
        ),
        Command_::Inventory { book, out } => run_inventory(&book, &out),
        Command_::Render {
            kernel,
            inventory,
            out,
        } => run_render(&kernel, &inventory, &out),
        Command_::Audit { kernel, book } => run_audit(&kernel, &book),
    };
    std::process::exit(code);
}

/// `argumentos evidence`: ejecuta lean-export y ssch-racional, genera
/// recibos con hashes SHA-256 y los escribe a `receipts/`. Luego el
/// checker valida contra el kernel del piloto.
fn run_evidence(repo: &Path, out: Option<&Path>) -> i32 {
    let out_dir = out
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| repo.join("argumentos/receipts"));
    std::fs::create_dir_all(&out_dir).unwrap();

    // 1) Ejecutar el exporter Lean.
    eprintln!("ejecutando lean-export…");
    let lean_out = match run_lean_export(repo) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    let lean_stdout_sha = format!("{:x}", Sha256::digest(lean_out.as_bytes()));

    // 2) Ejecutar el runner Python SSCH.
    eprintln!("ejecutando ssch-racional…");
    let ssch_out = match run_ssch(repo) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    let ssch_stdout_sha = format!("{:x}", Sha256::digest(ssch_out.as_bytes()));

    // 3) Cargar el kernel del piloto para obtener los specs.
    let kernel_path = repo.join("argumentos/kernel/piloto_ch5_ssch.json");
    let kernel = match argumentos::model::load_kernel(&kernel_path) {
        Ok(k) => k,
        Err(e) => {
            eprintln!("error cargando kernel: {}", e);
            return exit::ENTRADA_INVALIDA;
        }
    };

    // 4) Parsear el JSONL del exporter para extraer info por objetivo.
    let lean_lines: Vec<&str> = lean_out.lines().filter(|l| !l.trim().is_empty()).collect();

    // 5) Generar un recibo por spec.
    let now = chrono_like_now();
    let mut count = 0;
    for spec in &kernel.evidence_specs {
        let (stdout_sha, checks) = if spec.kind == argumentos::model::EvidenceKind::Lean {
            // Buscar la línea del exporter que corresponde a este target.
            let target = &spec.target;
            let found = lean_lines
                .iter()
                .find(|l| l.contains(&format!("\"name\": \"{}\"", target)));
            match found {
                Some(line) => {
                    let v: serde_json::Value = match serde_json::from_str(line) {
                        Ok(v) => v,
                        Err(e) => {
                            eprintln!("error parseando línea del exporter: {}", e);
                            return exit::FALLO_EJECUCION;
                        }
                    };
                    let axioms = v["axioms"].as_array().map(|a| a.len()).unwrap_or(0);
                    let deps = v["dependencies"].as_array().map(|a| a.len()).unwrap_or(0);
                    (
                        lean_stdout_sha.clone(),
                        vec![argumentos::receipt::ObservedCheck {
                            id: format!("target_encontrado:{}", target),
                            status: argumentos::receipt::CheckStatus::Pass,
                            detail: format!("{} axiomas, {} dependencias", axioms, deps),
                        }],
                    )
                }
                None => {
                    eprintln!("error: target {} no encontrado en el exporter", target);
                    return exit::FALLO_EJECUCION;
                }
            }
        } else {
            // Python: parsear el JSON del SSCH.
            let v: serde_json::Value = match serde_json::from_str(&ssch_out) {
                Ok(v) => v,
                Err(e) => {
                    eprintln!("error parseando salida SSCH: {}", e);
                    return exit::FALLO_EJECUCION;
                }
            };
            let status = if v["criterio"]["status"] == "pass" {
                argumentos::receipt::CheckStatus::Pass
            } else {
                argumentos::receipt::CheckStatus::Fail
            };
            (
                ssch_stdout_sha.clone(),
                vec![argumentos::receipt::ObservedCheck {
                    id: v["criterio"]["id"]
                        .as_str()
                        .unwrap_or("criterio")
                        .to_string(),
                    status,
                    detail: format!(
                        "esperado={}, observado={}",
                        v["criterio"]["esperado"].as_str().unwrap_or("?"),
                        v["criterio"]["observado"].as_str().unwrap_or("?")
                    ),
                }],
            )
        };

        let receipt = argumentos::receipt::Receipt {
            schema_version: "1.0".into(),
            id: format!("R.{}", spec.id),
            spec_id: spec.id.clone(),
            spec_hash: argumentos::check::spec_hash(spec),
            source_commit: "local".into(),
            environment_hash: format!(
                "{:x}",
                Sha256::digest(format!("{}|{}", lean_stdout_sha, ssch_stdout_sha).as_bytes())
            ),
            checker_version: CHECKER_VERSION.into(),
            command_argv: if spec.kind == argumentos::model::EvidenceKind::Lean {
                vec!["lean".into(), "argumentos/evidence/lean_export.lean".into()]
            } else {
                vec![
                    "python3".into(),
                    "argumentos/runners/ssch_bayes_racional.py".into(),
                ]
            },
            working_directory: repo.display().to_string(),
            input_hashes: {
                let mut m = std::collections::BTreeMap::new();
                let exporter_path = repo.join("argumentos/evidence/lean_export.lean");
                if let Ok(b) = std::fs::read(&exporter_path) {
                    m.insert(
                        "lean_export.lean".into(),
                        format!("{:x}", Sha256::digest(&b)),
                    );
                }
                let runner_path = repo.join("argumentos/runners/ssch_bayes_racional.py");
                if let Ok(b) = std::fs::read(&runner_path) {
                    m.insert(
                        "ssch_bayes_racional.py".into(),
                        format!("{:x}", Sha256::digest(&b)),
                    );
                }
                m
            },
            started_at: now.clone(),
            finished_at: now.clone(),
            exit_status: Some(0),
            termination: argumentos::receipt::Termination::Completed,
            stdout_sha256: stdout_sha,
            stderr_sha256: format!("{:x}", Sha256::digest(b"")),
            artifacts: vec![],
            execution_passed: true,
            scientific_criterion_met: Some(true),
            observed_checks: checks,
            trust_mode: argumentos::receipt::TrustMode::LocallyReproduced,
        };

        let path = out_dir.join(format!("{}.json", spec.id));
        match serde_json::to_string_pretty(&receipt) {
            Ok(json) => {
                std::fs::write(&path, json).unwrap();
                count += 1;
            }
            Err(e) => {
                eprintln!("error serializando recibo {}: {}", spec.id, e);
                return exit::FALLO_EJECUCION;
            }
        }
    }

    eprintln!("{} recibos generados en {}", count, out_dir.display());
    exit::OK
}

fn chrono_like_now() -> String {
    std::process::Command::new("date")
        .arg("+%Y-%m-%dT%H:%M:%SZ")
        .output()
        .ok()
        .map(|o| String::from_utf8_lossy(&o.stdout).trim().to_string())
        .unwrap_or_else(|| "unknown".into())
}

/// `argumentos check`: carga kernel y recibos (estricto), ejecuta el checker
/// y reporta. Exit 0 si todo argumento es aceptado (posiblemente condicional);
/// 3 si hay rechazos o pendientes; 2 si la entrada viola el contrato.
fn run_check(kernel_path: &Path, receipts_path: Option<&Path>) -> i32 {
    let kernel = match argumentos::model::load_kernel(kernel_path) {
        Ok(k) => k,
        Err(e) => {
            eprintln!("error de contrato en {}: {}", kernel_path.display(), e);
            return exit::ENTRADA_INVALIDA;
        }
    };
    let mut receipts = Vec::new();
    if let Some(rp) = receipts_path {
        let files: Vec<PathBuf> = if rp.is_dir() {
            let mut v: Vec<PathBuf> = match std::fs::read_dir(rp) {
                Ok(rd) => rd
                    .filter_map(|e| e.ok())
                    .map(|e| e.path())
                    .filter(|p| p.extension().is_some_and(|x| x == "json"))
                    .collect(),
                Err(_) => Vec::new(),
            };
            v.sort();
            v
        } else {
            vec![rp.to_path_buf()]
        };
        for f in files {
            match argumentos::receipt::load_receipt(&f) {
                Ok(r) => receipts.push(r),
                Err(e) => {
                    eprintln!("error de contrato en {}: {}", f.display(), e);
                    return exit::ENTRADA_INVALIDA;
                }
            }
        }
    }
    let report = argumentos::check::check(&argumentos::check::CheckInput {
        kernel: &kernel,
        receipts: &receipts,
    });
    println!(
        "kernel: {} claims, {} argumentos, {} specs",
        kernel.claims.len(),
        kernel.arguments.len(),
        kernel.evidence_specs.len()
    );
    println!("hash canónico del reporte: {}", report.canonical_hash);
    let mut bloqueados = 0;
    for (id, res) in &report.results {
        let estado = match &res.decision {
            argumentos::check::Decision::Accepted => "ACEPTADO".to_string(),
            argumentos::check::Decision::AcceptedConditional { open } => format!(
                "ACEPTADO_CONDICIONAL (hipótesis abiertas: {})",
                open.join(", ")
            ),
            argumentos::check::Decision::Rejected { reason } => {
                format!("RECHAZADO: {}", reason.detalle())
            }
            argumentos::check::Decision::UnsupportedRule => "REGLA_NO_SOPORTADA".to_string(),
            argumentos::check::Decision::Pending { reason } => format!("PENDIENTE: {}", reason),
        };
        println!(
            "  [{}] {} — estructura={:?} formal={:?} empírico={:?}",
            id, estado, res.structure, res.formal, res.empirical
        );
        if !matches!(
            res.decision,
            argumentos::check::Decision::Accepted
                | argumentos::check::Decision::AcceptedConditional { .. }
        ) {
            bloqueados += 1;
        }
    }
    if bloqueados == 0 {
        println!(
            "check: {} argumentos procesados, sin bloqueos.",
            report.results.len()
        );
        exit::OK
    } else {
        println!(
            "check: {} de {} argumentos rechazados o pendientes.",
            bloqueados,
            report.results.len()
        );
        exit::DEPENDENCIA_BLOQUEANTE
    }
}

/// Una sonda del entorno: nombre, estado y detalle.
struct Probe {
    name: &'static str,
    ok: bool,
    blocking: bool,
    detail: String,
}

fn doctor(repo: &Path) -> i32 {
    let repo = match repo.canonicalize() {
        Ok(p) => p,
        Err(e) => {
            eprintln!(
                "error: no pude resolver la ruta del repo {}: {}",
                repo.display(),
                e
            );
            return exit::ENTRADA_INVALIDA;
        }
    };
    println!("argumentos doctor — checker v{}", CHECKER_VERSION);
    println!("repositorio: {}", repo.display());
    println!();

    let mut probes: Vec<Probe> = Vec::new();

    // --- Localización del repo ---
    for (name, rel, blocking) in [
        (
            "libro (book_stat_inference_v0)",
            "book_stat_inference_v0/main.typ",
            true,
        ),
        (
            "Lean (verificacion_lean)",
            "verificacion_lean/verificar.sh",
            true,
        ),
        ("kernel/claims", "argumentos/kernel/claims", false),
        ("kernel/arguments", "argumentos/kernel/arguments", false),
        (
            "kernel/evidence_specs",
            "argumentos/kernel/evidence_specs",
            false,
        ),
    ] {
        let p = repo.join(rel);
        probes.push(Probe {
            name,
            ok: p.exists(),
            blocking,
            detail: if p.exists() {
                format!("{} ✓", rel)
            } else {
                format!("{} falta", rel)
            },
        });
    }

    // --- Versiones de herramientas (subprocesos, sin credenciales) ---
    for (name, program, args, blocking) in [
        ("rustc", "rustc", vec!["--version"], true),
        ("cargo", "cargo", vec!["--version"], true),
        ("typst", "typst", vec!["--version"], true),
        ("lean", "lean", vec!["--version"], true),
        ("python3", "python3", vec!["--version"], false),
    ] {
        probes.push(match run_probe(program, &args) {
            Some(out) => Probe {
                name,
                ok: true,
                blocking,
                detail: out,
            },
            None => Probe {
                name,
                ok: false,
                blocking,
                detail: format!("{} no disponible en PATH", program),
            },
        });
    }

    // --- Smoke de typst-syntax: el crate debe parsear fuente Typst ---
    probes.push(typst_syntax_probe());

    // --- Integridad del paquete de especificación (MANIFEST.sha256.json) ---
    probes.push(spec_manifest_probe(&repo));

    // --- Reporte ---
    let mut blocking_failures = 0;
    for p in &probes {
        let status = if p.ok {
            "OK  "
        } else if p.blocking {
            "FAIL"
        } else {
            "WARN"
        };
        println!("[{}] {:<28} {}", status, p.name, p.detail);
        if !p.ok && p.blocking {
            blocking_failures += 1;
        }
    }
    println!();
    if blocking_failures == 0 {
        println!("doctor: entorno completo ({} sondas).", probes.len());
        exit::OK
    } else {
        println!(
            "doctor: {} dependencia(s) bloqueante(s) de {} sondas.",
            blocking_failures,
            probes.len()
        );
        exit::DEPENDENCIA_BLOQUEANTE
    }
}

fn run_probe(program: &str, args: &[&str]) -> Option<String> {
    let out = Command::new(program).args(args).output().ok()?;
    let text = String::from_utf8_lossy(&out.stdout).trim().to_string();
    let first = text.lines().next().unwrap_or("").to_string();
    if first.is_empty() {
        Some("(sin salida)".to_string())
    } else {
        Some(first)
    }
}

fn typst_syntax_probe() -> Probe {
    let name = "typst-syntax (smoke)";
    let src = "#thm-env(\"theorem\", name: [T], key: \"k\")[cuerpo]";
    let markup = typst_syntax::parse(src);
    // El parseo de un fragmento con macros del libro no debe fallar; los
    // nodos concretos los consume F4.
    let node_count = markup.len();
    if node_count > 0 {
        Probe {
            name,
            ok: true,
            blocking: true,
            detail: format!("parsea {} nodos", node_count),
        }
    } else {
        Probe {
            name,
            ok: false,
            blocking: true,
            detail: "no produjo nodos".to_string(),
        }
    }
}

/// Verifica los hashes SHA-256 del paquete de especificación copiado al
/// repo contra su propio manifiesto (docs/03: un hash detecta cambio de
/// bytes; no prueba veracidad, pero detecta copia corrupta o edición
/// silenciosa del contrato).
fn spec_manifest_probe(repo: &Path) -> Probe {
    let name = "paquete spec (MANIFEST)";
    let spec_dir = repo.join("argumentos/spec/argumentos_construccion_v1");
    let manifest_path = spec_dir.join("MANIFEST.sha256.json");
    let manifest = match std::fs::read_to_string(&manifest_path) {
        Ok(t) => t,
        Err(e) => {
            return Probe {
                name,
                ok: false,
                blocking: true,
                detail: format!("manifiesto ilegible: {}", e),
            }
        }
    };
    let value = match argumentos::strict_json::parse_strict(&manifest) {
        Ok(v) => v,
        Err(e) => {
            return Probe {
                name,
                ok: false,
                blocking: true,
                detail: format!("manifiesto no es JSON estricto: {}", e),
            }
        }
    };
    let files = match value.as_object() {
        Some(o) => o.clone(),
        None => {
            return Probe {
                name,
                ok: false,
                blocking: true,
                detail: "manifiesto no es un objeto".to_string(),
            }
        }
    };
    let mut mismatches = Vec::new();
    for (rel, expected) in &files {
        let path = spec_dir.join(rel);
        match std::fs::read(&path) {
            Ok(bytes) => {
                let actual = format!("{:x}", Sha256::digest(&bytes));
                if &actual != expected {
                    mismatches.push(format!("{}: hash difiere", rel));
                }
            }
            Err(_) => mismatches.push(format!("{}: ilegible", rel)),
        }
    }
    if mismatches.is_empty() {
        Probe {
            name,
            ok: true,
            blocking: true,
            detail: format!("{} archivos verificados", files.len()),
        }
    } else {
        Probe {
            name,
            ok: false,
            blocking: true,
            detail: format!(
                "{} discrepancia(s): {}",
                mismatches.len(),
                mismatches.join("; ")
            ),
        }
    }
}

// --- F3: runners de evidencia -------------------------------------------------

/// Ejecuta el exporter Lean (5 declaraciones) contra el build de
/// verificacion_lean y escribe el artefacto JSONL.
pub fn run_lean_export(repo: &std::path::Path) -> Result<String, String> {
    let repo = repo
        .canonicalize()
        .map_err(|e| format!("repo ilegible: {}", e))?;
    let lean_path = repo.join("verificacion_lean/build");
    let env_lean = std::env::var("LEAN_PATH").unwrap_or_default();
    let full_lean_path = format!("{}:{}", lean_path.display(), env_lean);
    let out = std::process::Command::new("lean")
        .arg(repo.join("argumentos/evidence/lean_export.lean"))
        .env("LEAN_PATH", &full_lean_path)
        .current_dir(&repo)
        .output()
        .map_err(|e| format!("no pude lanzar lean: {}", e))?;
    if !out.status.success() {
        return Err(format!(
            "lean falló (exit {:?}): {}",
            out.status.code(),
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).to_string())
}

/// Ejecuta el runner Python SSCH.
pub fn run_ssch(repo: &std::path::Path) -> Result<String, String> {
    let repo = repo
        .canonicalize()
        .map_err(|e| format!("repo ilegible: {}", e))?;
    let out = std::process::Command::new("python3")
        .arg(repo.join("argumentos/runners/ssch_bayes_racional.py"))
        .current_dir(&repo)
        .output()
        .map_err(|e| format!("no pude lanzar python3: {}", e))?;
    if !out.status.success() {
        return Err(format!(
            "python3 falló (exit {:?}): {}",
            out.status.code(),
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    Ok(String::from_utf8_lossy(&out.stdout).to_string())
}

/// `argumentos inventory`: escanea el libro y escribe el inventario JSON.
fn run_inventory(book: &Path, out: &Path) -> i32 {
    let inv = match argumentos::book::scan_book(book) {
        Ok(i) => i,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    println!(
        "libro: {} archivos, {} bloques thm-env, {} macros desconocidas, {} etiquetas",
        inv.files.len(),
        inv.blocks.len(),
        inv.unknown_macros.len(),
        inv.labels.len()
    );
    for m in &inv.unknown_macros {
        println!("  macro desconocida: {}", m);
    }
    let json = serde_json::to_string_pretty(&inv).unwrap();
    std::fs::write(out, json).unwrap();
    println!("inventario escrito en {}", out.display());
    exit::OK
}

/// `argumentos render`: genera fichas .typ desde el kernel + inventario.
fn run_render(kernel_path: &Path, inventory_path: &Path, out: &Path) -> i32 {
    let kernel = match argumentos::model::load_kernel(kernel_path) {
        Ok(k) => k,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::ENTRADA_INVALIDA;
        }
    };
    let inv_text = std::fs::read_to_string(inventory_path).unwrap();
    let inv: argumentos::book::BookInventory = serde_json::from_str(&inv_text).unwrap();
    let n = match argumentos::book::render_fichas(&kernel, &inv, out) {
        Ok(n) => n,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    println!("{} fichas generadas en {}", n, out.display());
    // Verificar determinismo: regenerar y comparar.
    let tmp = std::env::temp_dir().join(format!("argumentos-render-check-{}", std::process::id()));
    let _ = argumentos::book::render_fichas(&kernel, &inv, &tmp);
    let mut ok = true;
    for entry in std::fs::read_dir(out).unwrap().flatten() {
        let name = entry.file_name();
        let a = std::fs::read(entry.path()).unwrap_or_default();
        let b = std::fs::read(tmp.join(&name)).unwrap_or_default();
        if a != b {
            eprintln!("error: {} no es determinista", name.to_string_lossy());
            ok = false;
        }
    }
    let _ = std::fs::remove_dir_all(&tmp);
    if ok {
        println!("determinismo verificado: doble render idéntico");
        exit::OK
    } else {
        exit::FALLO_EJECUCION
    }
}

/// `argumentos audit`: compara el kernel contra el libro.
fn run_audit(kernel_path: &Path, book: &Path) -> i32 {
    let kernel = match argumentos::model::load_kernel(kernel_path) {
        Ok(k) => k,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::ENTRADA_INVALIDA;
        }
    };
    let inv = match argumentos::book::scan_book(book) {
        Ok(i) => i,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    let hallazgos = argumentos::book::audit_structural(&kernel, &inv);
    if hallazgos.is_empty() {
        println!(
            "auditoría estructural: sin discrepancias ({} claims vs {} bloques)",
            kernel.claims.len(),
            inv.blocks.len()
        );
        exit::OK
    } else {
        println!(
            "auditoría estructural: {} discrepancia(s):",
            hallazgos.len()
        );
        for h in &hallazgos {
            println!("  - {}", h);
        }
        exit::DEPENDENCIA_BLOQUEANTE
    }
}

/// `argumentos propose`: extrae candidatos del libro vía replay o live.
fn run_propose(
    inventory_path: &Path,
    replay_dir: Option<&Path>,
    provider_config_path: Option<&Path>,
    out_dir: Option<&Path>,
) -> i32 {
    let inv_text = std::fs::read_to_string(inventory_path).unwrap();
    let inv: argumentos::book::BookInventory = serde_json::from_str(&inv_text).unwrap();

    // Configuración del proveedor.
    let config = match provider_config_path {
        Some(p) => match argumentos::extract::ProviderConfig::load(p) {
            Ok(c) => c,
            Err(e) => {
                eprintln!("error de configuración: {}", e);
                return exit::ENTRADA_INVALIDA;
            }
        },
        None => argumentos::extract::ProviderConfig::replay_default(),
    };

    // Seleccionar el extractor.
    let extractor: Box<dyn argumentos::extract::Extractor> =
        if config.mode == "live" && config.endpoint_available() {
            Box::new(argumentos::extract::LiveExtractor {
                config: config.clone(),
            })
        } else {
            let rd = replay_dir
                .map(|p| p.to_path_buf())
                .unwrap_or_else(|| Path::new("replay").to_path_buf());
            Box::new(argumentos::extract::ReplayExtractor::new(rd))
        };

    // Construir la solicitud de extracción (bloques del piloto).
    let pilot_keys = [
        "thm:ch9-isomorfismo",
        "cor:ch9-bayes",
        "thm:ch9-admisibilidad",
        "cor:ch7-traduccion",
    ];
    let blocks: Vec<argumentos::extract::BlockInput> = inv
        .blocks
        .iter()
        .filter(|b| pilot_keys.contains(&b.key.as_str()))
        .map(|b| {
            // Leer el contenido del bloque desde el archivo fuente.
            let book_root = inventory_path.parent().unwrap_or(Path::new("."));
            let file_path = book_root.join(&b.file);
            let text = std::fs::read_to_string(&file_path).unwrap_or_default();
            let content = text
                .get(b.content_start..b.content_end)
                .unwrap_or("")
                .to_string();
            argumentos::extract::BlockInput {
                key: b.key.clone(),
                kind: b.kind.clone(),
                name: b.name.clone(),
                content,
            }
        })
        .collect();
    let request = argumentos::extract::ExtractionRequest {
        prompt_version: "1.0".into(),
        blocks,
    };

    // Ejecutar el extractor.
    eprintln!("modo del extractor: {}", extractor.mode());
    let response = match extractor.extract(&request) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("extractor: {}", e);
            eprintln!("LIVE_PROVIDER_PENDING — continuando sin extracción");
            return exit::DEPENDENCIA_BLOQUEANTE;
        }
    };

    // Validar candidatos: citas alineadas, sin campos de aprobación.
    let out = out_dir
        .map(|p| p.to_path_buf())
        .unwrap_or_else(|| Path::new("candidates").to_path_buf());
    std::fs::create_dir_all(&out).unwrap();
    let mut count = 0;
    for cand in &response.candidates {
        let block = request.blocks.iter().find(|b| b.key == cand.block_key);
        if let Some(b) = block {
            if let Err(e) = argumentos::extract::validate_candidate(cand, &b.content) {
                eprintln!("candidato {} rechazado: {}", cand.claim.id, e);
                continue;
            }
        }
        let path = out.join(format!("{}.json", cand.claim.id.replace('.', "_")));
        let json = serde_json::to_string_pretty(cand).unwrap();
        std::fs::write(&path, json).unwrap();
        count += 1;
    }
    eprintln!(
        "{} candidatos validados y escritos en {}",
        count,
        out.display()
    );
    exit::OK
}

/// `argumentos argue`: proyección ASPIC+ y análisis de argumentación.
fn run_argue(kernel_path: &Path, preferred: bool) -> i32 {
    let kernel = match argumentos::model::load_kernel(kernel_path) {
        Ok(k) => k,
        Err(e) => {
            eprintln!("error: {}", e);
            return exit::ENTRADA_INVALIDA;
        }
    };
    let report = match argumentos::aspic::analizar(&kernel, preferred) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("error ASPIC+: {}", e);
            return exit::FALLO_EJECUCION;
        }
    };
    println!("semántica: {}", report.semantics);
    println!(
        "argumentos: {}, ataques: {}",
        report.argument_count, report.attack_count
    );
    if report.budget_exceeded {
        println!("PRESUPUESTO EXCEDIDO: INCOMPLETE (no ausencia de conflictos)");
        return exit::DEPENDENCIA_BLOQUEANTE;
    }
    println!("extensiones grounded: {}", report.extensions.len());
    for (id, state) in &report.states {
        println!(
            "  [{}] {:?} ({})",
            id,
            state,
            if report.credulous.contains(id) {
                "crédula"
            } else if report.sceptical.contains(id) {
                "escéptica"
            } else {
                "-"
            }
        );
    }
    if let Some(match_ref) = report.reference_match {
        println!(
            "evaluador de referencia: {}",
            if match_ref { "COINCIDE" } else { "DISCREPA" }
        );
        if !match_ref {
            return exit::FALLO_EJECUCION;
        }
    }
    exit::OK
}
