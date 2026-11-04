#import "../plantilla_M.typ": *

= A real-data study, executed by the protocol
<ch:m-realdata>

Every preceding chapter made promises. This one executes them, end to end,
on data the authors did not generate. The dataset is a logged-bandit
subsample of the Open Bandit Dataset (OBD), registered on the fashion
e-commerce platform ZOZOTOWN and bundled with version 0.5.7 of the
`obp` source distribution (#cite(<saito2021openbandit>, form: "prose") — the
full campaigns download from ZOZO after a use form; the packaged subsamples
analyzed here carry 10,000 rounds per behavior policy, campaign `all`).
The protocol file precedes the analysis; every number in this chapter is
recomputed by `labs/m_ch11_obd.py` and registered in `resultados_M.json`.

Mode L3 of the failure map applies from the start: a packaged subsample is
not the full campaign. Conclusions are proportional — this is a real-data
study of a protocol, at the scale the packaged data allow.

== Protocol file (fixed before the analysis)

#mi-tabla(
  caption: [The justification file of this chapter, as Chapter 10 requires],
  key: "tab:m-obd-protocolo",
  table(columns: (24%, 1fr), align: left, hl(),
    table.header([*Item*], [*Declaration*]), hl(w: 0.6pt),
    [Estimand], [$J(e)$: expected click of the target policy $e$, one decision per logged round.],
    [Intervention], [$e$ chooses the *item*; the logged position mechanism is kept (positions are features of the mechanism, not of the policy). Stated here because it defines the estimand.],
    [Unit], [One logged round; the packaged subsample is treated as i.i.d. rounds (the campaign design samples sessions; dependence within session is not accessible in this cut — declared open condition, conclusions capped at "independent rounds").],
    [Target $e$], [$epsilon$-greedy, $epsilon=0.5$, over the argmax of a click model fitted on the *separate bts campaign*, frozen before the evaluation log ($K=80$ items: $e(a^*)=0.50625$, $e(a)=0.00625$; ratio bound $C=40.5$ by construction, not estimated).],
    [Behavior $b$], [The `random` campaign (uniform $1/80$). Recorded propensities: verified in data — *all* 10,000 rows show propensity $0.0125$; the bts campaign's recorded propensities span $[4.5 times 10^(-5), 0.95424]$. Overlap is exact by design and checked, not assumed.],
    [Estimators], [DM, IS (true recorded weights), DR (2-fold cross-fitted logistic regressions), and the mixture Hoeffding CS of @thm:m-ope-cs with $C=40.5$, $B=1$.],
    [Variance and CS], [Cross-fitted sample variance for DR (asymptotic, @thm:m-dr-eficiencia regime); the CS is valid at arbitrary stopping times under the same designed support.],
    [Diagnostics], [ESS reported as diagnostic only (@note:m-diag); no threshold asserted.],
    [Sanity references], [On-policy click means of both campaigns ($0.0042$ bts, $0.0038$ random): values of *other* policies, not ground truth for $J(e)$.],
    hl(),
  ),
)

== What was verified by design, and what is only diagnosed

Three conditions of @thm:m-ope-cs are discharged *by design*: i.i.d.
rounds (declared), true weights (recorded propensities, exact in the data),
and ratio bound $C=40.5$ (constructed, since $e$ and $b$ are both known
deterministic functions of frozen objects). Identification (A1–A3) holds in
the campaign design: actions assigned by logged probabilities independent of
potential clicks given the recorded context — with the declared caveat that
context features here are the packaged ones (hashed user features and
affinity scores). The auxiliary-model condition for the DR interval has only
model-class support: logistic regressions on affinity and item features have
no proved rate in this problem, so the DR interval is read as the asymptotic
normal interval of the efficient form, with its own certificate marked
partly open. The mean-behavior conditions of the click model behind $e$
themselves are irrelevant to the validity of $e$ as a *target*: target
policies need not be good.

== Results

#block(breakable: false)[
#mi-tabla(
  caption: [OBD packaged subsamples, campaign `all`: evaluation of the
  $epsilon$-greedy target. All figures recomputed by the lab; intervals as
  declared in the protocol file],
  key: "tab:m-obd-results",
  table(columns: (34%, 22%, 1fr), align: left, hl(),
    table.header([*Quantity*], [*Value*], [*Reading*]), hl(w: 0.6pt),
    [$n$ (rounds)], [10,000], [i.i.d. units as declared],
    [Ratio bound $C$], [40.5], [by construction],
    [ESS fraction (diagnostic)], [0.048], [weights concentrate: only ~5% effective rounds drive IS],
    [IS $hat(J)$], [0.0059], [true weights; asymptotic CIs inferior at this ESS],
    [DR $hat(J)$], [0.0057], [cross-fitted],
    [DM $hat(J)$], [0.0051], [model-based],
    [DR normal CI 95%], [$[-0.0022, 0.0136]$], [includes zero: at binary 0.4% click rates and this ESS, $n=10^4$ does not separate the target's lift from none],
    [CS 95% at $n$], [$[-0.2, 1.0]$ — vacuous], [the nonasymptotic mixture Hoeffding CS with $d=2C=81$ carries width $~sqrt(d^2 log(1 slash alpha) slash n)$: honest arithmetic for anyone who plans monitoring on it],
    hl(),
  ),
)
]

== What the study shows, proportionally

+ *The protocol ran.* Every estimator is defensible under a discharged
  certificate; the chapter needed no informal step between data and report.
  The one weak link — the parametric click model behind the DR regression —
  is marked as such, exactly where it lives (@tab:m-obd-protocolo).
+ *Overlap dominates inference.* At $C=40.5$, ESS=4.8% concentrates the
  weight in the rounds where the target agrees with random logging; the DR
  interval is honest about the price. A "successful" evaluation at this
  design would have required a less greedy target ($epsilon$ closer to 1),
  and would have estimated a less interesting policy. That trade-off is the
  design question the book promised to make explicit (@thm:m-curse is its
  one-dimensional shadow).
+ *Nonasymptotic validity is expensive.* The CS's vacuity at $n=10^4$ is
  not a defect of the method but its price list, printed: variance-adaptive
  e-processes (@note:m-savi-ope) buy back width under the same guarantee.
  Choosing between a tight asymptotic interval and a nonasymptotic
  monitoring tool is a declared decision, not an oversight.
+ *Comparisons are between policies, not to truth.* The sanity references
  show the packaged target's estimated value above both logged policies'
  means — with an interval that eliminates no alternative. The chapter
  reports exactly that.

#pendiente[Scale-up: rerun the identical pipeline on the full campaigns
(download gated by ZOZO's use form) with sessions as units; the packaged
subsample does not expose session independence. Same code, larger $n$,
session-level bootstrap or CS — no change of protocol needed.]
