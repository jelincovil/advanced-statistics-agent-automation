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
}

fn main() {
    let cli = Cli::parse();
    let code = match cli.command {
        Command_::Doctor { repo } => doctor(repo.as_deref().unwrap_or(Path::new("."))),
        Command_::Check { kernel, receipts } => run_check(&kernel, receipts.as_deref()),
    };
    std::process::exit(code);
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
