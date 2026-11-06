//! JSON estricto para el kernel (docs/03_CONTRATOS.md).
//!
//! Parser propio y revisable, ~300 líneas, sin dependencias más allá de
//! `serde_json::Value` como árbol de salida. Rechaza:
//! - claves duplicadas en objetos (se detectan al insertar, antes de que
//!   el mapa las colapse);
//! - literales `NaN`/`Infinity` (no son JSON) y números que desbordan a
//!   no finito (`1e999`);
//! - ceros iniciales (`01`), comas finales, contenido tras el valor raíz,
//!   BOM y caracteres de control en cadenas.
//!
//! Los errores llevan línea y columna (1-based). La entrada es `&str`, ya
//! UTF-8 válido; los offsets internos son de bytes sobre esa entrada.

use serde_json::{Map, Number, Value};

/// Límite de profundidad: el kernel es plano y poco anidado; un límite
/// explícito evita desbordes de pila con entradas hostiles.
const MAX_DEPTH: usize = 256;

#[derive(Debug, thiserror::Error)]
#[error("JSON estricto: línea {line}, columna {col}: {message}")]
pub struct StrictJsonError {
    /// Línea 1-based donde ocurre el problema.
    pub line: usize,
    /// Columna 1-based (en caracteres de la línea) donde ocurre el problema.
    pub col: usize,
    /// Descripción accionable del problema.
    pub message: String,
}

impl StrictJsonError {
    fn new(line: usize, col: usize, message: impl Into<String>) -> Self {
        Self {
            line,
            col,
            message: message.into(),
        }
    }
}

/// Parsea `input` como JSON estricto.
pub fn parse_strict(input: &str) -> Result<Value, StrictJsonError> {
    let mut p = Parser {
        b: input.as_bytes(),
        pos: 0,
        line: 1,
        col: 1,
        depth: 0,
    };
    if p.b.starts_with(&[0xEF, 0xBB, 0xBF]) {
        return Err(p.err("BOM no permitido en JSON UTF-8"));
    }
    let v = p.value()?;
    p.ws();
    if p.pos < p.b.len() {
        return Err(p.err("contenido tras el valor raíz"));
    }
    Ok(v)
}

struct Parser<'a> {
    b: &'a [u8],
    pos: usize,
    line: usize,
    col: usize,
    depth: usize,
}

impl<'a> Parser<'a> {
    fn err(&self, msg: impl Into<String>) -> StrictJsonError {
        StrictJsonError::new(self.line, self.col, msg)
    }

    fn peek(&self) -> Option<u8> {
        self.b.get(self.pos).copied()
    }

    fn bump(&mut self) -> Option<u8> {
        let c = self.peek()?;
        self.pos += 1;
        if c == b'\n' {
            self.line += 1;
            self.col = 1;
        } else {
            // Los caracteres multibyte consumen varios bytes; la columna
            // cuenta caracteres, que es lo que un humano corrige.
            self.col += 1;
        }
        Some(c)
    }

    /// Espacio en blanco permitido por JSON: espacio, tab, LF, CR.
    fn ws(&mut self) {
        while matches!(self.peek(), Some(b' ' | b'\t' | b'\n' | b'\r')) {
            self.bump();
        }
    }

    fn value(&mut self) -> Result<Value, StrictJsonError> {
        if self.depth >= MAX_DEPTH {
            return Err(self.err("anidamiento excesivo (más de 256 niveles)"));
        }
        match self.peek() {
            Some(b'{') => {
                self.depth += 1;
                let v = self.object();
                self.depth -= 1;
                v
            }
            Some(b'[') => {
                self.depth += 1;
                let v = self.array();
                self.depth -= 1;
                v
            }
            Some(b'"') => Ok(Value::String(self.string()?)),
            Some(b't') => self.literal("true", Value::Bool(true)),
            Some(b'f') => self.literal("false", Value::Bool(false)),
            Some(b'n') => self.literal("null", Value::Null),
            Some(c @ (b'-' | b'0'..=b'9')) => self.number(c),
            Some(c) if c.is_ascii_graphic() => {
                Err(self.err(format!("token inesperado '{}'", c as char)))
            }
            _ => Err(self.err("valor esperado")),
        }
    }

    fn literal(&mut self, word: &str, v: Value) -> Result<Value, StrictJsonError> {
        for expected in word.bytes() {
            match self.bump() {
                Some(c) if c == expected => {}
                _ => return Err(self.err(format!("literal esperado '{}'", word))),
            }
        }
        Ok(v)
    }

    fn object(&mut self) -> Result<Value, StrictJsonError> {
        self.bump(); // '{'
        let mut map = Map::new();
        self.ws();
        if self.peek() == Some(b'}') {
            self.bump();
            return Ok(Value::Object(map));
        }
        loop {
            self.ws();
            if self.peek() != Some(b'"') {
                return Err(self.err("clave de objeto esperada (cadena)"));
            }
            let key = self.string()?;
            self.ws();
            match self.bump() {
                Some(b':') => {}
                _ => return Err(self.err("':' esperado tras la clave")),
            }
            self.ws();
            let val = self.value()?;
            if map.contains_key(&key) {
                return Err(self.err(format!("clave duplicada en el objeto: '{}'", key)));
            }
            map.insert(key, val);
            self.ws();
            match self.bump() {
                Some(b',') => continue,
                Some(b'}') => return Ok(Value::Object(map)),
                _ => return Err(self.err("',' o '}' esperado")),
            }
        }
    }

    fn array(&mut self) -> Result<Value, StrictJsonError> {
        self.bump(); // '['
        let mut items = Vec::new();
        self.ws();
        if self.peek() == Some(b']') {
            self.bump();
            return Ok(Value::Array(items));
        }
        loop {
            self.ws();
            items.push(self.value()?);
            self.ws();
            match self.bump() {
                Some(b',') => continue,
                Some(b']') => return Ok(Value::Array(items)),
                _ => return Err(self.err("',' o ']' esperado")),
            }
        }
    }

    /// Cadena con escapes estándar, incluidos pares sustitutos UTF-16.
    /// Rechaza caracteres de control sin escapar (< 0x20).
    fn string(&mut self) -> Result<String, StrictJsonError> {
        self.bump(); // '"'
        let mut out = String::new();
        loop {
            let c = self.bump().ok_or_else(|| self.err("cadena sin cerrar"))?;
            match c {
                b'"' => return Ok(out),
                b'\\' => {
                    let e = self.bump().ok_or_else(|| self.err("escape sin cerrar"))?;
                    match e {
                        b'"' => out.push('"'),
                        b'\\' => out.push('\\'),
                        b'/' => out.push('/'),
                        b'b' => out.push('\u{0008}'),
                        b'f' => out.push('\u{000C}'),
                        b'n' => out.push('\n'),
                        b'r' => out.push('\r'),
                        b't' => out.push('\t'),
                        b'u' => {
                            let hi = self.hex4()?;
                            let cp = if (0xD800..0xDC00).contains(&hi) {
                                // sustituto alto: exige un sustituto bajo a continuación
                                if self.bump() != Some(b'\\') || self.bump() != Some(b'u') {
                                    return Err(self.err("sustituto alto sin par bajo"));
                                }
                                let lo = self.hex4()?;
                                if !(0xDC00..0xE000).contains(&lo) {
                                    return Err(self.err("sustituto bajo inválido"));
                                }
                                0x10000 + ((hi - 0xD800) << 10) + (lo - 0xDC00)
                            } else if (0xDC00..0xE000).contains(&hi) {
                                return Err(self.err("sustituto bajo sin par alto"));
                            } else {
                                hi
                            };
                            match char::from_u32(cp) {
                                Some(ch) => out.push(ch),
                                None => return Err(self.err("escape \\u inválido")),
                            }
                        }
                        _ => return Err(self.err("escape desconocido")),
                    }
                }
                c if c < 0x20 => {
                    return Err(self.err("carácter de control sin escapar en la cadena"))
                }
                c if c < 0x80 => out.push(c as char),
                _ => {
                    // Byte de continuación de un carácter multibyte: la
                    // entrada es &str válido, así que copiamos el carácter
                    // completo desde el origen.
                    let start = self.pos - 1;
                    let width = utf8_width(c);
                    let end = start + width;
                    if end > self.b.len() {
                        return Err(self.err("carácter UTF-8 truncado"));
                    }
                    let s = std::str::from_utf8(&self.b[start..end])
                        .map_err(|_| self.err("carácter UTF-8 inválido"))?;
                    out.push_str(s);
                    // Consumir los bytes restantes del carácter.
                    for _ in 1..width {
                        self.bump();
                    }
                }
            }
        }
    }

    fn hex4(&mut self) -> Result<u32, StrictJsonError> {
        let mut v: u32 = 0;
        for _ in 0..4 {
            let c = self.bump().ok_or_else(|| self.err("\\u truncado"))?;
            let d = (c as char)
                .to_digit(16)
                .ok_or_else(|| self.err("dígito hexadecimal esperado"))?;
            v = v * 16 + d;
        }
        Ok(v)
    }

    /// Número según la gramática JSON: `-? (0 | [1-9][0-9]*) (frac)? (exp)?`.
    /// Enteros sin fracción/exponente se conservan como enteros exactos;
    /// el resto pasa por `f64` con rechazo explícito de no finitos.
    fn number(&mut self, first: u8) -> Result<Value, StrictJsonError> {
        let start = self.pos;
        let mut has_frac = false;
        let mut has_exp = false;
        if first == b'-' {
            self.bump();
        }
        // parte entera
        match self.peek() {
            Some(b'0') => {
                self.bump();
                if matches!(self.peek(), Some(b'0'..=b'9')) {
                    return Err(self.err("cero inicial no permitido"));
                }
            }
            Some(b'1'..=b'9') => {
                while matches!(self.peek(), Some(b'0'..=b'9')) {
                    self.bump();
                }
            }
            _ => return Err(self.err("dígito esperado")),
        }
        // fracción
        if self.peek() == Some(b'.') {
            has_frac = true;
            self.bump();
            if !matches!(self.peek(), Some(b'0'..=b'9')) {
                return Err(self.err("dígito esperado tras el punto"));
            }
            while matches!(self.peek(), Some(b'0'..=b'9')) {
                self.bump();
            }
        }
        // exponente
        if matches!(self.peek(), Some(b'e' | b'E')) {
            has_exp = true;
            self.bump();
            if matches!(self.peek(), Some(b'+' | b'-')) {
                self.bump();
            }
            if !matches!(self.peek(), Some(b'0'..=b'9')) {
                return Err(self.err("dígito esperado en el exponente"));
            }
            while matches!(self.peek(), Some(b'0'..=b'9')) {
                self.bump();
            }
        }
        let text = std::str::from_utf8(&self.b[start..self.pos])
            .map_err(|_| self.err("número inválido"))?;
        if !has_frac && !has_exp {
            if let Ok(u) = text.parse::<u64>() {
                return Ok(Value::Number(Number::from(u)));
            }
            if let Ok(i) = text.parse::<i64>() {
                return Ok(Value::Number(Number::from(i)));
            }
        }
        let f: f64 = text.parse().map_err(|_| self.err("número inválido"))?;
        match Number::from_f64(f) {
            // `from_f64` devuelve None para no finitos: NaN/Infinity y
            // desbordes como 1e999 se rechazan aquí.
            Some(n) => Ok(Value::Number(n)),
            None => Err(self.err(format!("número no finito o fuera de rango: {}", text))),
        }
    }
}

fn utf8_width(first_byte: u8) -> usize {
    match first_byte {
        0xC0..=0xDF => 2,
        0xE0..=0xEF => 3,
        0xF0..=0xF7 => 4,
        _ => 1,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn acepta_json_valido_basico() {
        for src in [
            "null",
            "true",
            "false",
            "[]",
            "{}",
            "[1, -2.5e3, 0.25]",
            "\"hola\"",
        ] {
            assert!(parse_strict(src).is_ok(), "debía aceptar: {}", src);
        }
    }

    #[test]
    fn rechaza_clave_duplicada() {
        let e = parse_strict(r#"{"a": 1, "a": 2}"#).unwrap_err();
        assert!(e.message.contains("duplicada"), "{}", e);
    }

    #[test]
    fn rechaza_nan_e_infinity() {
        assert!(parse_strict("NaN").is_err());
        assert!(parse_strict("Infinity").is_err());
        assert!(parse_strict(r#"{"a": NaN}"#).is_err());
        assert!(parse_strict("-Infinity").is_err());
    }

    #[test]
    fn rechaza_no_finito_por_desborde() {
        assert!(parse_strict("1e999").is_err());
    }

    #[test]
    fn rechaza_basura_tras_raiz() {
        assert!(parse_strict("{} x").is_err());
        assert!(parse_strict("[1] [2]").is_err());
    }

    #[test]
    fn rechaza_coma_final() {
        assert!(parse_strict("[1,]").is_err());
        assert!(parse_strict(r#"{"a": 1,}"#).is_err());
    }

    #[test]
    fn rechaza_cero_inicial() {
        assert!(parse_strict("01").is_err());
    }

    #[test]
    fn rechaza_bom() {
        assert!(parse_strict("\u{FEFF}{}").is_err());
    }

    #[test]
    fn rechaza_control_en_cadena() {
        assert!(parse_strict("\"a\u{1}b\"").is_err());
    }

    #[test]
    fn acepta_pares_sustitutos() {
        let v = parse_strict(r#""😀""#).unwrap();
        assert_eq!(v, Value::String("😀".to_string()));
        let v = parse_strict("\"\\ud83d\\ude00\"").unwrap();
        assert_eq!(v, Value::String("😀".to_string()));
    }

    #[test]
    fn rechaza_sustituto_huerfano() {
        assert!(parse_strict("\"\\ud83d\"").is_err());
        assert!(parse_strict("\"\\ude00\"").is_err());
    }

    #[test]
    fn rechaza_anidamiento_excesivo() {
        let deep = "[".repeat(300) + &"]".repeat(300);
        assert!(parse_strict(&deep).is_err());
    }

    #[test]
    fn enteros_exactos_se_conservan() {
        let v = parse_strict("9007199254740993").unwrap(); // 2^53+1, no representable en f64
        assert_eq!(v.as_u64(), Some(9007199254740993));
    }
}
