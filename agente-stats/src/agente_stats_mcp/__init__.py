"""Capa MCP del proyecto: servidor stdio ligero sobre `agente_stats.core`.

Invariantes de la casa (Fase 3 del plan):
- stdout es SOLO del protocolo MCP; todo logging va a stderr (con un humo
  aparte que lo mide mutando el hijo).
- Path jail: solo `examples/` del proyecto y el workspace del alumno
  (variables `AGENTE_STATS_EXAMPLES_DIR`, `AGENTE_STATS_WORKSPACE_DIR`,
  con defaults locales saneados). Cualquier ruta fuera de la jail se rechaza.
- Salidas = resumen + diagnóstico + ≤10 filas de ejemplo + ruta, nunca el
  archivo crudo.
- Rechazos: `ToolRejection` se traduce a respuesta con `is_error=True`
  y un mensaje accionable; nunca a una excepción desnuda.
- `readOnlyHint: true` en todas las tools.
"""
