# monografia_M — *Statistical Guarantees for Sequential Decision Agents*

English research monograph derived from the Spanish course book
(`book_stat_inference_v0/`), per `book_stat_inference_v0/PROPUESTA_REFORMULACION.md`,
`book_stat_inference_v0/DECISIONES_2026-11-02.md` (D1–D11) and
`book_stat_inference_v0/PLAN_M_30D_2026-11-02.md`. **State: v0.1-M draft —
all 13 chapters and 5 appendices written, compiling clean (61 pp, Typst 0.15.1).**

## Build

```
typst compile main.typ        # main.pdf-equivalent output
```

## Verify everything

```
../book_stat_inference_v0/.venv/bin/python ejecutar_M.py   # labs + checkers -> resultados_M.json
lean pilot_core_proven.lean                                  # Chapter-4 identities, machine-checked
```

## Layout (as built)

```
main.typ, plantilla_M.typ     # assembly + English template (adapted from the book's)
partes/                       # preface + intro + 13 chapters in 3 parts
apendices/                    # A proofs · B tools-by-use · C SSCH · D reproduction · E notation
referencias_M.bib             # curated entries; new ones have fichas/ entries (protocol)
fichas/                       # verification cards for the 2021–2024 sources used
labs/                         # m_ch8_labA/labB (anytime-valid), m_ch11_obd (real-data study)
labs/data_obd/                # OBD subsamples from the obp 0.5.7 sdist (see fichas/saito2021openbandit.md)
verificacion/                 # 11 per-chapter numeric checkers (all asserted from first principles)
pilot_core_proven.lean        # Phase-0 Lean verification (3 theorems, zero sorry)
VERIFICACION_LEAN_PLAN.md     # the phased Lean verification plan
resultados_M.json             # registered outputs (run ejecutar_M.py to regenerate)
```

## Conventions (same as the source repository)

Nothing is claimed beyond what its hypotheses discharge; holes are declared
in red OPEN boxes, never filled with plausible prose; citations of 2021+
work enter `referencias_M.bib` only with a ficha; every displayed number is
recomputable (`verificacion/` and `labs/`); cross-check passes against the
Spanish source guard against scope drift in re-authoring.

## Known open items (v0.1-M)

1. Exercises not yet ported (declared in the intro's OPEN box).
2. OBD study ran on the packaged 10k subsamples; full-campaign rerun is a
   declared OPEN in Chapter 11.
3. Lean phases 1+ are planned work (`VERIFICACION_LEAN_PLAN.md`), Phase 0 done.
4. English prose is a re-authored draft pending the human revision pass per
   the 30-day plan's Phase 4.
