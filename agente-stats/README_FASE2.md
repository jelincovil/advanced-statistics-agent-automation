# agente-stats — núcleo estadístico del proyecto MCP del libro

**Fase 1.5 (2026-11-03):** Fase 0 (contrato JSONL + ficha) y Fase 2 (OPE,
comparación de versiones, ficha automática) ejecutadas y verificadas. Sin
dependencias externas para el core (`agente_stats`): stdlib; `pytest` para tests.

## Layout del núcleo

```
src/agente_stats/
  schemas.py                 # contrato JSONL estricto + errores accionables (Fase 0)
  certificates.py            # ficha de justificación congelada + eslabón más débil (Fase 0)
  core/
    episode_logger.py        # π por diseño; C_max + tasa + seed por episodio (Fase 1)
    ope.py                   # estimate_is (trayectoria) y estimate_dr (secuencial+fold) (Fase 2)
    compare.py               # compare_versions con IC Welch pareado (Fase 2)
    ficha.py                 # build_ficha: traduce OpeResult a Certificate (Fase 2)
  golden_episodes.py         # dorados v1/v2 (Fase 0, regenerables con semilla)
  adapters/obd.py            # OBD → JSONL (stdlib csv; licencia Apache-2.0 vendorizada)
tests/                       # 35 tests: schemas 11, golden 5, certificates 6, Fase 2 13
examples/                    # JSONL validados + README + NOTICE/licencia OBD
```

## Verificación coplrapide

```bash
cd agente-stats
PYTHONPATH=src python3 -m pytest -q
# 35 tests en verde
```

Y, sobre datos reproducibles del proyecto:
- 47/47 → 54/54 tests del laboratorio `capitulo_09_isomorfismo` (D9 + Fase 1).
- 5/5 tests de emisión del laboratorio `capitulo_10_ope` (Fase 1).
- TabularMDP canónico: IS y DR reconstruyen el valor verdadero dentro del SE;
  `soft-cubierta` sobre 10 000 rondas OBD reproduce la media observada
  (0.0038) con ESS=1; rechazo accionable cuando la target no aparece en el
  log (ESS=0) — no divide por cero, declara.

## Reglas de la casa (estáticas)

- Nada se afirma más fuerte que las condiciones: `certificates.discharged_level`
  es la fuente de verdad; ficha se rechaza con mensaje accionable si el
  estimando o el régimen no se declaran.
- El core no imprime nada en ningún proceso MCP: stdout es del protocolo.
- Salidas = resumen + diagnóstico + ruta (nunca filas cruadas) — compatible
  con la capa MCP de la Fase 3.
