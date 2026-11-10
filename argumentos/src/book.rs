//! Parser Typst del libro (docs/06_AUDITORIA_TYPST.md, plan F4).
//!
//! Usa typst-syntax 0.15.1 (alineada con el binario del repo) para
//! parsear la fuente y extraer los bloques `thm-env` con sus etiquetas,
//! nombres, clases y rangos de bytes. Nada de regex: el AST de
//! typst-syntax es el vínculo semántico con la fuente.
//!
//! Dos controles distintos (docs/06):
//! - **Exacto** (este módulo): etiquetas, bloques, source maps,
//!   render determinista.
//! - **Semántico** (F5 con GLM): si la prosa añade causalidad, elimina
//!   hipótesis o universaliza. Aquí solo el estructural.

use sha2::{Digest, Sha256};
use std::collections::BTreeSet;
use std::path::Path;
use typst_syntax::{parse, LinkedNode, SyntaxKind};

/// Un bloque `thm-env` del libro: la unidad de inventario.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct BookBlock {
    /// Archivo relativo al libro (p. ej. `capitulos/cap05_incrustacion.typ`).
    pub file: String,
    /// Clase del entorno: theorem, proposition, corollary, example,
    /// definition, note, assumption…
    pub kind: String,
    /// Nombre visible (el `name: [...]`).
    pub name: String,
    /// Clave del libro (el `key: "..."`), p. ej. `thm:ch9-isomorfismo`.
    pub key: String,
    /// Rango de bytes UTF-8 del contenido (sin corchetes): [start, end).
    pub content_start: usize,
    pub content_end: usize,
    /// SHA-256 del archivo fuente completo.
    pub file_sha256: String,
}

/// Inventario completo del libro.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct BookInventory {
    /// Archivos .typ incluidos por main.typ (orden de recorrido).
    pub files: Vec<String>,
    /// Todos los bloques thm-env encontrados.
    pub blocks: Vec<BookBlock>,
    /// Macros de función encontradas que no están en el conjunto conocido.
    pub unknown_macros: Vec<String>,
    /// Etiquetas `<...>` encontradas (labels de Typst).
    pub labels: Vec<String>,
}

/// Macros conocidas del libro (plantilla.typ): las que sabemos interpretar.
const MACROS_CONOCIDAS: &[&str] = &[
    // Entornos del libro (plantilla.typ)
    "thm-env",
    "env-alias",
    "section-alias",
    "obj-alias",
    "proof-env",
    "proofsketch-env",
    "algorithm-env",
    "assumption-env",
    "codelisting-env",
    "exercise-env",
    "chapter-alias",
    "dem-alias",
    "cap-sin-numero",
    "tabla-garantias",
    "pendiente",
    "mark-appendix-start",
    "hl",
    "verdem",
    // Funciones estándar de Typst
    "mi-tabla",
    "mi-figura",
    "link",
    "read",
    "set",
    "show",
    "import",
    "include",
    "block",
    "rect",
    "grid",
    "table",
    "colbreak",
    "pagebreak",
    "figure",
    "footnote",
    "highlight",
    "sub",
    "super",
    "underbrace",
    "overbrace",
    "bold",
    "italic",
    "raw",
    "image",
    "path",
    "pad",
    "align",
    "place",
    "move",
    "scale",
    "rotate",
    "context",
    "query",
    "counter",
    "state",
    "locate",
    "for",
    "while",
    "if",
    "else",
    "let",
    "fn",
    "not",
    "and",
    "or",
    "in",
    "assert",
    "panic",
    "eval",
    "int",
    "float",
    "str",
    "repr",
    "type",
    "label",
    "numbering",
    "unicode",
    "text",
    "font",
    "page",
    "par",
    "heading",
    "list",
    "enum",
    "terms",
    "stack",
    "box",
    "circle",
    "ellipse",
    "polygon",
    "curve",
    "line",
    "square",
    "canvas",
    "box-node",
    "diamond-node",
    "luma",
    "rgb",
    "content",
    "bibliography",
    "cite",
    "outline",
    "list-of",
    "v",
    "h",
    "emph",
    "ref",
];

/// Resultado del escaneo de un archivo: bloques, macros desconocidas y etiquetas.
pub struct ScanResult {
    pub blocks: Vec<BookBlock>,
    pub unknown_macros: Vec<String>,
    pub labels: Vec<String>,
}

/// Escanea un archivo .typ y extrae todos los bloques thm-env.
pub fn scan_typst_file(path: &Path, rel_path: &str) -> Result<ScanResult, String> {
    let text = std::fs::read_to_string(path)
        .map_err(|e| format!("no pude leer {}: {}", path.display(), e))?;
    let file_sha = format!("{:x}", Sha256::digest(text.as_bytes()));

    let root = parse(&text);
    let linked = LinkedNode::new(&root);
    let mut blocks = Vec::new();
    let mut unknown = BTreeSet::new();
    let mut labels = BTreeSet::new();

    walk(&linked, &mut |node| {
        // Detectar todos los FuncCall para macros desconocidas.
        if node.kind() == SyntaxKind::FuncCall {
            if let Some(ident) = node.children().next() {
                if ident.kind() == SyntaxKind::Ident {
                    let fname = ident.leaf_text().to_string();
                    if !MACROS_CONOCIDAS.contains(&fname.as_str()) {
                        unknown.insert(fname.clone());
                    }
                    if fname == "thm-env" {
                        if let Some(block) = extract_thm_env(node, rel_path, &file_sha) {
                            blocks.push(block);
                        }
                    }
                }
            }
        }
        // Detectar etiquetas `<...>`.
        if node.kind() == SyntaxKind::Label {
            let txt = node.leaf_text().to_string();
            // Las etiquetas van como `<texto>`; quitar los angle brackets.
            let inner = txt.trim_start_matches('<').trim_end_matches('>');
            if !inner.is_empty() {
                labels.insert(inner.to_string());
            }
        }
    });

    Ok(ScanResult {
        blocks,
        unknown_macros: unknown.into_iter().collect(),
        labels: labels.into_iter().collect(),
    })
}

/// Extrae un bloque thm-env de un nodo FuncCall.
fn extract_thm_env(node: &LinkedNode, rel_path: &str, file_sha: &str) -> Option<BookBlock> {
    // FuncCall → Ident("thm-env") + Args(...)
    let args = node.children().nth(1)?;
    if args.kind() != SyntaxKind::Args {
        return None;
    }

    let mut kind = String::new();
    let mut name = String::new();
    let mut key = String::new();
    let mut content_range = None;

    for arg in args.children() {
        match arg.kind() {
            SyntaxKind::Str => {
                // Primer argumento posicional: la clase del entorno.
                let raw = arg.leaf_text().to_string();
                kind = raw.trim_matches('"').to_string();
            }
            SyntaxKind::Named => {
                // name: [...] o key: "..."
                let mut children = arg.children();
                let ident = children.next()?;
                if ident.kind() != SyntaxKind::Ident {
                    continue;
                }
                let arg_name = ident.leaf_text().to_string();
                match arg_name.as_str() {
                    "name" => {
                        // El valor es un ContentBlock → extraer el texto plano.
                        for c in arg.children() {
                            if c.kind() == SyntaxKind::ContentBlock {
                                name = plain_text(&c);
                            }
                        }
                    }
                    "key" => {
                        for c in arg.children() {
                            if c.kind() == SyntaxKind::Str {
                                let raw = c.leaf_text().to_string();
                                key = raw.trim_matches('"').to_string();
                            }
                        }
                    }
                    _ => {}
                }
            }
            SyntaxKind::ContentBlock => {
                // El cuerpo del teorema: el ContentBlock trailing.
                // Buscar el Markup interno para el rango sin corchetes.
                for c in arg.children() {
                    if c.kind() == SyntaxKind::Markup {
                        let r = c.range();
                        content_range = Some((r.start, r.end));
                    }
                }
            }
            _ => {}
        }
    }

    let (cs, ce) = content_range?;
    Some(BookBlock {
        file: rel_path.to_string(),
        kind,
        name,
        key,
        content_start: cs,
        content_end: ce,
        file_sha256: file_sha.to_string(),
    })
}

/// Extrae el texto plano de un nodo (sin markup, para el `name:`).
fn plain_text(node: &LinkedNode) -> String {
    let mut out = String::new();
    collect_text(node, &mut out);
    out.trim().to_string()
}

fn collect_text(node: &LinkedNode, out: &mut String) {
    if node.leaf_text().is_empty() {
        for child in node.children() {
            collect_text(&child, out);
        }
    } else {
        let t = node.leaf_text();
        if !matches!(
            node.kind(),
            SyntaxKind::LeftBracket | SyntaxKind::RightBracket
        ) {
            out.push_str(t);
        }
    }
}

/// Recorre el árbol en profundidad llamando `f` en cada nodo.
fn walk(node: &LinkedNode, f: &mut dyn FnMut(&LinkedNode)) {
    f(node);
    for child in node.children() {
        walk(&child, f);
    }
}

/// Inventa todo el libro: lee main.typ, encuentra los includes y escanea
/// cada archivo incluido.
pub fn scan_book(book_path: &Path) -> Result<BookInventory, String> {
    let main = book_path.join("main.typ");
    let main_text =
        std::fs::read_to_string(&main).map_err(|e| format!("no pude leer main.typ: {}", e))?;

    // Encontrar los includes: #include("capitulos/...") o #include <...>
    let mut files = vec!["main.typ".to_string()];
    let root = parse(&main_text);
    let linked = LinkedNode::new(&root);
    let mut includes = Vec::new();
    walk(&linked, &mut |node| {
        // `#include "file.typ"` es un ModuleInclude (no FuncCall).
        if node.kind() == SyntaxKind::ModuleInclude {
            for child in node.children() {
                if child.kind() == SyntaxKind::Str {
                    let raw = child.leaf_text().to_string();
                    let path = raw.trim_matches('"');
                    includes.push(path.to_string());
                }
            }
        }
    });

    let mut all_blocks = Vec::new();
    let mut all_unknown = BTreeSet::new();
    let mut all_labels = BTreeSet::new();

    // Escanear main.typ mismo.
    let main_result = scan_typst_file(&main, "main.typ")?;
    all_blocks.extend(main_result.blocks);
    all_unknown.extend(main_result.unknown_macros);
    all_labels.extend(main_result.labels);

    // Escanear cada archivo incluido.
    for inc in &includes {
        let p = book_path.join(inc);
        if p.exists() {
            files.push(inc.clone());
            let result = scan_typst_file(&p, inc)?;
            all_blocks.extend(result.blocks);
            all_unknown.extend(result.unknown_macros);
            all_labels.extend(result.labels);
        } else {
            eprintln!("aviso: include no resuelto: {}", inc);
        }
    }

    Ok(BookInventory {
        files,
        blocks: all_blocks,
        unknown_macros: all_unknown.into_iter().collect(),
        labels: all_labels.into_iter().collect(),
    })
}

/// Render de fichas canónicas: genera un archivo .typ por claim del kernel.
/// Determinista: dos ejecuciones producen bytes idénticos (docs/06).
pub fn render_fichas(
    kernel: &crate::model::Kernel,
    inventory: &BookInventory,
    out_dir: &Path,
) -> Result<usize, String> {
    std::fs::create_dir_all(out_dir)
        .map_err(|e| format!("no pude crear {}: {}", out_dir.display(), e))?;
    let mut count = 0;
    for claim in &kernel.claims {
        let ficha = render_ficha(claim, inventory);
        let path = out_dir.join(format!("{}.typ", claim.id.replace('.', "_")));
        std::fs::write(&path, &ficha)
            .map_err(|e| format!("no pude escribir {}: {}", path.display(), e))?;
        count += 1;
    }
    Ok(count)
}

/// Genera el texto .typ de una ficha (determinista).
fn render_ficha(claim: &crate::model::Claim, inventory: &BookInventory) -> String {
    let mut out = String::new();
    out.push_str("// Ficha canónica generada por argumentos — no editar a mano.\n");
    out.push_str(&format!("// ID: {}\n", claim.id));
    if let Some(bk) = &claim.book_key {
        out.push_str(&format!("// book_key: {}\n", bk));
    }
    out.push('\n');
    out.push_str(&format!("= {} ({:?})\n\n", claim.id, claim.kind));
    out.push_str(&format!("== Enunciado\n\n{}\n\n", claim.statement));

    // Alcance
    out.push_str("== Alcance\n\n");
    for (k, v) in &claim.scope {
        out.push_str(&format!("- {}: {}\n", k, v));
    }
    out.push('\n');

    // Supuestos
    if !claim.assumptions.is_empty() {
        out.push_str("== Supuestos (obligaciones)\n\n");
        for a in &claim.assumptions {
            out.push_str(&format!("- {}\n", a));
        }
        out.push('\n');
    }

    // Referencia al libro
    if let Some(bk) = &claim.book_key {
        if let Some(block) = inventory.blocks.iter().find(|b| &b.key == bk) {
            out.push_str("== Fuente en el libro\n\n");
            out.push_str(&format!(
                "- Archivo: {} (bytes {}..{})\n",
                block.file, block.content_start, block.content_end
            ));
            out.push_str(&format!("- Entorno: {} ({})\n", block.kind, block.name));
            out.push_str(&format!("- SHA-256 del archivo: {}\n", block.file_sha256));
        }
    }

    out
}

/// Compara el kernel contra el inventario: cada book_key del kernel debe
/// existir en el libro. Devuelve las discrepancias.
pub fn audit_structural(kernel: &crate::model::Kernel, inventory: &BookInventory) -> Vec<String> {
    let mut hallazgos = Vec::new();
    let keys: BTreeSet<&str> = inventory.blocks.iter().map(|b| b.key.as_str()).collect();
    for claim in &kernel.claims {
        if let Some(bk) = &claim.book_key {
            if bk.starts_with("der:") {
                hallazgos.push(format!(
                    "AUXILIAR: {} es derivación interna declarada y no exige caja propia ({})",
                    bk, claim.id
                ));
            } else if !keys.contains(bk.as_str()) {
                hallazgos.push(format!(
                    "claim {} referencia book_key '{}' no encontrado en el libro",
                    claim.id, bk
                ));
            }
        }
    }
    // F07: también la dirección libro → kernel. Son entradas de cobertura,
    // no errores de referencia; aparecen para que cada bloque deba quedar
    // revisado o excluido justificadamente, nunca olvidado por el contador.
    let claim_keys: BTreeSet<&str> = kernel
        .claims
        .iter()
        .filter_map(|c| c.book_key.as_deref())
        .collect();
    for block in &inventory.blocks {
        if !claim_keys.contains(block.key.as_str()) {
            hallazgos.push(format!(
                "COBERTURA: bloque '{}' ({}/{}) sin claim; pendiente de revisión o exclusión justificada",
                block.key, block.file, block.kind
            ));
        }
    }
    hallazgos
}
