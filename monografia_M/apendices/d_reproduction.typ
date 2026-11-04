#import "../plantilla_M.typ": *

= Reproduction protocols
<app:reproduction>

Everything in this monograph that can be checked mechanically has a shipped
script. The rule: every displayed number has a producer; every producer has
a fixed seed; every run is registered.

== Layout

- `labs/` — the three chapter laboratories:
  - `m_ch8_labA_stopping.py` — peeking attack on fixed-time CIs vs. the CS
    (stream of @thm:m-ope-cs's regime; M=4,000 runs, burn-in 10).
  - `m_ch8_labB_gridcs.py` — mixture-grid CS: whole-path validity,
    $EE[M_tau]$, final width (M=3,000 runs).
  - `m_ch11_obd.py` — the OBD study end to end (protocol of
    @tab:m-obd-protocolo; data in `labs/data_obd/`, from the obp 0.5.7 sdist
    `#cite(<saito2021openbandit>, form: "prose")`, bundling 10,000-round
    subsamples of campaigns `all`, `men`, `women`).
- `verificacion/` — one checker per chapter for the displays of that
  chapter (`m_ch2_ssch.py`, `m_ch3_bellman.py`, `m_ch3_thompson.py`,
  `m_ch5_stopping.py`, `m_ch6_contraejemplos.py`, `m_ch6_tricotomia.py`,
  `m_ch7_curse.py`, `m_ch8_anytime.py`, `m_ch9_pg.py`, `m_ch9_margin.py`,
  `m_ch10_certificados.py`).
- `pilot_core_proven.lean` — the machine-checked pilot: the three core
  identities of Chapter 4, proved by Lean and re-verifiable with
  `lean pilot_core_proven.lean` (see `VERIFICACION_LEAN_PLAN.md`).
- `resultados_M.json` — registered outputs, seeds, and timings per run.

== Environments

Manuscript: Typst 0.15.1 (`typst compile main.typ`).
Labs: Python 3.12, the pinned environment of the companion book
(numpy 2.5.3, sklearn 1.9.1, pandas 3.1.0 for the OBD lab). The OBD CSVs
travel inside the obp sdist; provenance recorded in
`monografia_M/fichas/saito2021openbandit.md`.

== What a rerun may legitimately change

Seeds fix all random draws of the labs and checkers. Legitimate changes on
rerun: timings and hardware strings. No number in the text may change
without the text changing: that is the contract of Appendix D, and it is
enforced by `verificacion/` re-asserting the displayed figures from first
principles rather than trusting `resultados_M.json`.
