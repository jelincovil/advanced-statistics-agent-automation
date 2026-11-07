/-
  Exporter de declaraciones elaboradas — F3 (docs/05_EVIDENCIA.md).

  Emite UNA LÍNEA JSON por objetivo (JSONL) a stdout: nombre
  fully-qualified, tipo elaborado serializado de manera estable para este
  entorno (Expr crudo), dependencias directas del enunciado y axiomas
  transitivos. Este archivo ES el vínculo semántico: consulta el entorno
  elaborado vía las APIs públicas de Lean; nada de regex sobre mensajes de
  consola ajenos.

  Los objetivos son TODOS los teoremas con book_key en verificacion_lean
  46 teoremas en total.
-/
import Book.Cap02Wald
import Book.Cap03MDP
import Book.Cap05Representacion
import Book.Cap06Fronteras
import Book.Cap07OPE
import Book.Cap08Intervalos
import Book.Cap11Despliegue
import Book.SSCH
import Lean.Util.CollectAxioms
import Lean.Util.FoldConsts

open Lean Elab Command Meta

namespace Argumentos.Exportador

/-- Objetivos del piloto (cuatro claves, cinco teoremas). -/
def objetivos : List Name := [
  `ch10_curse,
  `ch10_dr,
  `ch10_identificacion,
  `ch10_is_insesgado,
  `ch10_var_dr,
  `ch11_baseline,
  `ch11_baseline_ejemplo,
  `ch11_cuantizacion_ejemplo,
  `ch11_margen_elemental,
  `ch11_mdp_validacion,
  `ch11_monitoreo,
  `ch11_tasa_tabular,
  `ch11_truncamiento,
  `ch7_admisibilidad_bayes,
  `ch7_bayes,
  `ch7_complete_class_bayes,
  `ch7_minimax_bayes,
  `ch7_traduccion_optimos,
  `ch8_bellman_pi,
  `ch8_contraccion,
  `ch8_mejora,
  `ch8_parada,
  `ch8_pi_finita_sin_repeticion,
  `ch8_principio,
  `ch8_punto_fijo_unico,
  `ch8_vi_conv,
  `ch9_admisibilidad,
  `ch9_bayes,
  `ch9_bellman,
  `ch9_ic,
  `ch9_isomorfismo,
  `ch9_secuencial_cota,
  `cor_ch7_bayes_especificas,
  `ex_ch11_pg_ssch,
  `ex_ch5_cadena,
  `ex_ch6_memoria,
  `ex_ch6_minimax_dominada,
  `ex_ch9_confounding,
  `ex_ch9_fallo_mixing,
  `ex_ch9_fallo_overlap,
  `ex_ch9_observabilidad_parcial,
  `prop_ch8_VQ,
  `prop_ch8_acotacion,
  `ssch_mdp_bellman,
  `ssch_minimax_riesgos,
  `ssch_regla_ordinario
]

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
