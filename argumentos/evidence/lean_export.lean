/-
  Exporter de declaraciones elaboradas — F3 (docs/05_EVIDENCIA.md).

  Emite UNA LÍNEA JSON por objetivo (JSONL) a stdout: nombre
  fully-qualified, tipo elaborado serializado de manera estable para este
  entorno (Expr crudo), dependencias directas del enunciado y axiomas
  transitivos. Este archivo ES el vínculo semántico: consulta el entorno
  elaborado vía las APIs públicas de Lean; nada de regex sobre mensajes de
  consola ajenos.

  Los objetivos del piloto son las cuatro claves del capítulo 5 y sus
  cinco teoremas (docs/08): ch9_isomorfismo, ch9_bayes, ch9_admisibilidad,
  ch7_traduccion_optimos, ch7_traduccion.
-/
import Book.Cap05Representacion
import Lean.Util.CollectAxioms
import Lean.Util.FoldConsts

open Lean Elab Command Meta

namespace Argumentos.Exportador

/-- Objetivos del piloto (cuatro claves, cinco teoremas). -/
def objetivos : List Name :=
  [`ch9_isomorfismo, `ch9_bayes, `ch9_admisibilidad, `ch7_traduccion_optimos, `ch7_traduccion]

/-- Escapa una cadena para incluirla como literal JSON. -/
def jsonEsc (s : String) : String :=
  s.foldl (init := "") fun acc c =>
    acc ++
      (match c with
      | '"' => "\\\""
      | '\\' => "\\\\"
      | '\n' => "\\n"
      | '\r' => "\\r"
      | '\t' => "\\t"
      | c => String.push "" c)

end Argumentos.Exportador

open Argumentos.Exportador

elab "exportar_objetivos" : command => do
  let env ← getEnv
  let mut lineas : Array String := #[]
  for n in objetivos do
    match env.find? n with
    | none => throwError "[exporter] declaración no encontrada: {n}"
    | some info =>
      -- Axiomas transitivos (la misma maquinaria que #print axioms).
      let axs ← collectAxioms n
      let axsOrdenados := (axs.toList.map toString).toArray.qsort (· < ·) |>.toList
      -- Dependencias directas: constantes usadas por la declaración
      -- (tipo y valor, docs/05: auditar auxiliares transitivos).
      let deps := (Lean.ConstantInfo.getUsedConstantsAsSet info).toList.map toString |>.toArray.qsort (· < ·) |>.toList
      -- Tipo elaborado, serializado de manera estable para este entorno.
      let tipoFormat ← liftTermElabM <| Meta.ppExpr info.type
      let tipo := Format.pretty tipoFormat
      let axJson := String.intercalate ", " (axsOrdenados.map fun a => "\"" ++ jsonEsc a ++ "\"")
      let depJson := String.intercalate ", " (deps.map fun d => "\"" ++ jsonEsc d ++ "\"")
      let linea :=
        "{\"name\": \"" ++ jsonEsc n.toString ++ "\", " ++
        "\"type\": \"" ++ jsonEsc tipo ++ "\", " ++
        "\"axioms\": [" ++ axJson ++ "], " ++
        "\"dependencies\": [" ++ depJson ++ "]}"
      lineas := lineas.push linea
  for l in lineas do
    IO.println l

exportar_objetivos
