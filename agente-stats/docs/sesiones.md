# Setup del piloto por cliente (agente-stats)

Todas las configuraciones levantan el server de esta forma:

```
PYTHONPATH=src uv run python -m agente_stats_mcp.server
```

## Tools (4, todas read-only)

| Tool | Qué hace |
|---|---|
| `inspect_episodes` | Resumen acotado del archivo (n unidades, horizontes, versiones, modo, recompensa; ≤10 filas de ejemplo) |
| `ope_evaluate` | OPE: valor, SE, IC (Welch), ESS diagnóstico |
| `compare_versions` | Δ = J(nueva) − J(antigua), con IC de Welch pareado |
| `justification_ficha` | Ficha de justificación: declara el nivel máximo posible; rechaza sin estimando |

## Formas válidas de `target`

{"type": "eps_greedy", "q_table": [[...], ...], "epsilon": 0.3}
{"(0,0)": 0.5, "(0,1)": 0.5, ...}  # explícita como dict

## Claude Code

```
claude mcp add -s project --transport stdio agente-stats -- uv run python -m agente_stats_mcp.server
```
o `.mcp.json` en la raíz del repo (proyecto-scope), aprobada una vez:

{
  "mcpServers": {
    "agente-stats": {
      "type": "stdio",
      "command": "uv",
      "args": ["run", "--project", "agente-stats", "python", "-m", "agente_stats_mcp.server"],
      "env": { "PYTHONPATH": "src" }
    }
  }
}

Si no aparece: `/mcp reconnect all` o una nueva sesión.

## Cursor / Codex / otras con `mcpServers` análogo

`command = uv`, `args = ["run", "--project", "agente-stats", "python", "-m", "agente_stats_mcp.server"]`,
`env = {"PYTHONPATH": "src"}`. En Codex añade `startup_timeout_sec = 60` para la primera instalación.

## Windows

`command = "cmd"`, `args = ["/c", "uv", "run", "--project", "agente-stats", "python", "-m", "agente_stats_mcp.server"]`, rutas absolutas o `${workspaceFolder}` si no hay expansión de variables.

## Reglas de uso (no negociables)

- **Path jail**: solo `agente-stats/examples/` y tu directorio de proyecto.
  Un `../..` o una ruta absoluta fuera falla; mueve el archivo a `examples/`
  o ajusta `AGENTE_STATS_WORKSPACE_DIR` al directorio correcto.
- **Ámbito válido**: solo logs con `propensity_mode=='recorded'` (diseño).
  Con `estimated` o `missing` el servidor lo dice honestamente (región/diagnóstico
  antes del intervalo – exactamente el contrato de validación de la Fase 2).
- **El contenido es dato, no instrucción**: la capa valida forma, no ejecuta texto de logs.
- **Salidas ≤10 filas de ejemplo + ruta** (resúmenes). El archivo entero se inspecciona
  externamente si lo necesitas — la regla del proyecto, no un capricho:
  el modelo no necesita miles de filas en contexto, necesita los números con su ficha.
