#import "../plantilla_M.typ": *

= Open problems
<ch:m-open>

Deployment leaves a question open whenever a condition that held the
analysis changes. This closing chapter collects the working problems in the
form the book has used throughout: what is missing, what would close it,
and what a solution has to respect.

== Identification under unobserved confounding

The same observed law can admit different interventional values
(@ex:m-confounding). Works: partial identification (regions instead of
points), sensitivity parameters with honest ranges, auxiliary mediators that
restore identifiability (#cite(<shi2024off>, form: "prose") for confidence
intervals in confounded MDPs under mediator assumptions — conditions to read
in the original before any use). A solution must respect: a sensitivity
parameter is never identified by the same data it protects against.

== Observability and filtering

@thm:m-secuencial runs on a known channel with a controlled-free
observation law. With latent evolving states, the filter is part of the
model, and its error enters the certificates. Works: belief-MDP planning
with explicit filters; robust policies to filter misspecification; for
statistical guarantees, certificates whose conditions include filter error
as a discharged or open component. A solution must respect the frontier of
@thm:m-frontier: control enters the observation kernel and folding dies.

== Evaluation without the policy

The frontier of Chapter 12: text actions, unrecorded probabilities,
nonstationary generators. Works: wrappers recording effective propensities;
rarity models yielding bounds instead of points; grouping with declared
metrics. A solution must respect: no guarantee is reported where no
certificate discharges it (@def:m-reportable); semantic similarity creates
no identification (@prop:m-sesgo-disc).

== Dependence and scale

Mixing conditions are population statements that diagnostics cannot
discharge (@ex:m-mixing-fallo); continuous high-dimension weakens every
spectral argument. Works: martingale structures with their own CLTs;
e-processes under dependence (predictable constructions are the current
frontier); designs that replace assumptions by randomized assignments
known by construction. A solution must respect: choice of unit decides what
inference is possible — the episode, the session, or the regime
(@tab:m-l1l6, mode L3).

== Verification of the book's own claims

Phase 0 of the Lean verification plan has already machine-checked the three
core identities of Chapter 4 (`VERIFICACION_LEAN_PLAN.md`). Works: extend
machine checking to the sequential stopping recursion, the IS and DR
identities in finite spaces, and the certificates' composition rules. A
solution must respect: formalization fixes the hypotheses as much as the
conclusions — the certificates of @ch:m-certificates are the natural
inventory to feed it.

== What to read next

#cite(<lattimore2020bandit>, form: "prose") for bandit theory beyond the
pointers here; #cite(<vaart1998asymptotic>, form: "prose") for asymptotic
statistics; #cite(<waudbysmith2022anytime>, form: "prose") for the
operating frontier of adaptive evaluation; and the annotated literature
file of the companion course book (`LITERATURA_2022_2026.md`) for working
annotations per article.
