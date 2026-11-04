#import "../plantilla_M.typ": *

= The synthetic SSCH thread
<app:ssch>

SSCH — a hypertension support scenario — is a controlled laboratory for the
book's computations. *Synthetic figures*: none of its numbers are clinical
estimates; the point of the thread is that every claim about it can be
recomputed exactly (`book_stat_inference_v0/lab00_ssch.py` for the
longitudinal variant and `monografia_M/verificacion/` for the displays
used in the chapters).

== The one-signal decision

$theta in {0,1}$ indexes need for intensified follow-up; signal $X in {0,1}$
with $P_0 (X=1)=0.2$, $P_1 (X=1)=0.8$; losses 1 and 4 for the two errors.
Used in @ex:m-ssch-cap02 (risk table, Bayes and minimax rules, and the
randomized minimax at $3 slash 8$ with risk $1 slash 2$) and
@ex:m-ssch-observar (one observation at cost $0.05$: total risk $0.43 < 0.7$).

== Two-state dynamics

Deterministic transitions among ${g,b}$, $discount=0.9$; $V^*=(5,4)$ with
the myopic-optimal comparison in @ex:m-ssch-mdp. The lesson repeated across
the book: immediate-reward maximization can pay no future cost, and proves
nothing about learned models.

== Two-visit evaluation and paired comparison

The two-visit case of the course book (Chapter 10 there) produces the
contribution table reused for intervals: true values $1.425$ (evaluated
policy, $0.75$) and $0.950$ (reference, $0.5$); in the displayed realization
of $n=100$ independent episodes, DR normal interval $[1.376, 1.474]$ and
paired-difference interval $[0.455, 0.495]$ — paired contributions use
within-episode differences, with their covariance included. The example's
own caution applies: reproducible from the table, not a coverage claim at
$n=100$, and not clinical evidence.

== What the thread is for (and not for)

It lets a reader verify an entire argument — representation, Bellman
recursion, DR identity, baseline variance — with a pocket calculator or the
shipped scripts. It does not validate any deployment claim; every clinical
reading is blocked where the example is stated (`es-sintetico` markers).
