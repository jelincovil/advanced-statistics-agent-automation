import Book.ApendiceDErgodicidad
import Book.ApendiceDIbragimov
import Book.ApendiceDRegularidad
import Book.ApendiceDViolaciones
import Book.ApendiceEHilbert
import Book.ApendiceEMedido
import Book.ApendiceEMedidoDctM5
import Book.AppDHacM9
import Book.AppEFuncionImplicita
import Book.AppEFuncionImplicitaCond
import Book.AppERNM3
import Book.BarridoM16
import Book.Cap02M11
import Book.Cap02Wald
import Book.Cap03LaiRobbinsM7
import Book.Cap03MDP
import Book.Cap03MleM4
import Book.Cap04BhM3
import Book.Cap04Ch4M6
import Book.Cap04Ch6
import Book.Cap04Ch6DmlM5
import Book.Cap04Ch6Motivacion
import Book.Cap04Ejemplos
import Book.Cap04EjemplosM2
import Book.Cap04Herramientas
import Book.Cap04LoteM16
import Book.Cap04MedibleIntuicionM10
import Book.Cap04Suficiencia
import Book.Cap04UmpuM3
import Book.Cap05Asintotica
import Book.Cap05Representacion
import Book.Cap06FallosM6
import Book.Cap06Fronteras
import Book.Cap06PesosTasasM5
import Book.Cap07OPE
import Book.Cap08Bandits
import Book.Cap08BanditsM7
import Book.Cap08Ch11M10
import Book.Cap08Estimadores
import Book.Cap08FrozenLake
import Book.Cap08Intervalos
import Book.Cap08M6
import Book.Cap08Poder
import Book.Cap10OPE
import Book.Cap11Despliegue
import Book.Cap11HacM1
import Book.Cap12Problemas
import Book.Cap12ProblemasM8
import Book.Ch1Ch2Pendientes
import Book.Ch2Pendientes
import Book.Ch5CltAgentesM5
import Book.Ch5EjemplosM5
import Book.Ch5GcM5
import Book.ConvergenciaBase
import Book.Foundation
import Book.GordinCoreM8
import Book.M13Mcmc
import Book.M9Pendientes
import Book.SSCH
import Book.SSCHCap01M7
import Book.SSCHCap02M7
import Book.SSCHCap03M7
import Book.SSCHCap0405M7
import Book.SSCHCap06M7
import Book.SSCHEjemplosM7

/-!
# Auditoría exhaustiva de `Book/*` — `AuditAll.lean`

`Book/Audit.lean` audita a mano 174 teoremas; los módulos de `Book/` contienen
muchos más. Este módulo cierra la brecha sin listas que envejezcan: recorre el
entorno ya elaborado, toma **todos** los teoremas cuyo módulo de origen es
`Book.*` y emite para cada uno la misma línea que `#print axioms`:

```
'<nombre completo>' depends on axioms: [<axiomas>]
```

de modo que `Progress/gen_dashboard.py` la consume sin cambios (casa por
sufijo de nombre). Además falla (`throwError`) si algún teorema depende de un
axioma fuera de `{propext, Classical.choice, Quot.sound}` —lo que incluye
`sorryAx`—, así que `verificar.sh` sigue siendo una puerta real: si la
auditoría no está limpia, el runner no llega al final.

Convenio del proyecto (plan §5): la puerta F0 exige cero `sorry`. Esta
auditoría lo comprueba sobre el entorno entero en vez de sobre una lista
elegida a mano, y por tanto no se queda corta cuando se añaden módulos.
-/

open Lean in
run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  let permitidos : List Name := [`propext, `Classical.choice, `Quot.sound]
  let mut total := 0
  let mut malos : Array (Name × Array Name) := #[]
  for (n, ci) in env.constants.toList do
    match ci with
    | .thmInfo _ =>
      if let some idx := env.getModuleIdxFor? n then
        if (toString (mods[idx.toNat]!)).startsWith "Book." then
          total := total + 1
          let axs ← Lean.collectAxioms n
          let s := String.intercalate ", " (axs.toList.map toString)
          logInfo m!"'{n}' depends on axioms: [{s}]"
          unless axs.all (fun a => permitidos.contains a) do
            malos := malos.push (n, axs)
    | _ => pure ()
  logInfo m!"AUDIT-ALL: {toString total} teoremas de Book/* auditados, {toString malos.size} con axiomas no permitidos"
  unless malos.isEmpty do
    throwError m!"AuditAll: axiomas no permitidos en {toString malos.size} teoremas: {malos}"
