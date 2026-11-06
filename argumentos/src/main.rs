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
}

fn main() {
    let cli = Cli::parse();
    let code = match cli.command {
        Command_::Doctor { repo } => doctor(repo.as_deref().unwrap_or(Path::new("."))),
    };
    std::process::exit(code);
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
