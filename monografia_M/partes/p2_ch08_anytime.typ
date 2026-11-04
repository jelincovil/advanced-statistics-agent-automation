#import "../plantilla_M.typ": *

= Inference while the experiment runs
<ch:m-anytime>

A fixed-time confidence interval is a promise about one analysis at one
sample size. An agent dashboard violates that promise on arrival: the
analyst looks every day, stops when the interval excludes zero, and reports
that moment's interval. Under optional stopping, the nominal coverage of a
fixed-time interval is gone — this is not a subtlety but a different
inferential object. *Safe anytime-valid inference* (SAVI) builds the object
whose guarantee survives exactly that usage: e-processes for testing and
confidence sequences for estimation.

This chapter is self-contained up to Ville's inequality, states the
validity theorem for off-policy confidence sequences with full hypotheses
and proof, and then points to the general framework of
#cite(<waudbysmith2022anytime>, form: "prose") with the conditions its
abstract declares. It is the book's main addition over its course-book
companion (measured gap: the companion contained none of this material).

== E-values and e-processes

#thm-env("definition", name: [E-value], key: "def:m-evalue")[
  A random variable $E >= 0$ is an e-value for a hypothesis $cal(P)$ if
  $sup_(P in cal(P)) EE_P [E] <= 1$. Large observed values are evidence
  against $cal(P)$: by Markov's inequality, $P(E >= 1 slash alpha)<=alpha$
  for every $P in cal(P)$, so $E$ rejects at level $alpha$ when
  $E >= 1 slash alpha$. A likelihood ratio
  $E = q(X) slash p(X)$ is an e-value for the singleton ${p}$:
  $EE_p [E]=1$.
]

#thm-env("definition", name: [E-process and test (super)martingale], key: "def:m-eprocess")[
  With a filtration $(cal(F)_t)$, an e-process for $cal(P)$ is an adapted
  sequence $E_t >= 0$ such that for every $P in cal(P)$ and every stopping
  time $tau$, $EE_P [E_tau] <= 1$. A test supermartingale for $P$ is a
  nonnegative supermartingale starting at $1$; every test supermartingale
  is an e-process for its hypothesis, since optional stopping gives
  $EE[E_tau]<=EE[E_0]=1$ whenever the optional stopping theorem applies
  — for nonnegative supermartingales, Fatou's lemma extends it to arbitrary,
  possibly unbounded, stopping times. Predictable multiplicative factors
  with conditional expectation at most one are the standard constructor.
]

#thm-env("theorem", name: [Ville's inequality], key: "thm:m-ville")[
  If $(M_t)_(t >= 0)$ is a nonnegative supermartingale with $M_0=1$, then
  for every $a>1$,
  $ Prob(exists t: M_t >= a) <= 1/a . $]
#proof-env[
  Let $tau=inf{t:M_t >= a}$ (infinite if never). For each finite $T$,
  $tau and T$ is a bounded stopping time, and on ${tau<=T}$,
  $M_(tau and T)>=a$; hence $a dot Prob(tau<=T)<=EE[M_(tau and T)]<=1$ by
  bounded optional stopping. Let $T -> infinity$:
  $Prob(tau<infinity)=lim_T Prob(tau<=T)<=1 slash a$. The event
  ${exists t:M_t >= a}$ is ${tau<infinity}$.
]

#thm-env("definition", name: [Confidence sequence], key: "def:m-cs")[
  A $(1-alpha)$-CS for $theta$ is a sequence of sets $(C_t)$ with
  $Prob(forall t>=1: theta in C_t)>=1-alpha$: simultaneous — hence valid at
  every stopping time, including "look again tomorrow". Inverting the
  level-$alpha$ test from an e-process gives a CS: with $E_t (theta)$ an
  e-process for each candidate value, $C_t={theta:E_t (theta)<1 slash alpha}$.
]

== A constructor with a full proof: the Hoeffding e-process

#thm-env("definition", name: [Conditionally bounded contributions], key: "def:m-hoeffding-proc")[
  Let $X_t$ be adapted with $EE[X_t|cal(F)_(t-1)]=mu$ and
  $a_t <= X_t <= b_t$ with $a_t,b_t$ predictable and $b_t-a_t<=1$.
  For any predictable $lambda_t$ define the factor
  $ K_t = exp(lambda_t (X_t-mu)-(lambda_t^2)(b_t-a_t)^2 slash 8) $
  and the process $M_t = product_(s<=t) K_s$, $M_0=1$.
]

#thm-env("theorem", name: [Validity of the Hoeffding e-process], key: "thm:m-hoeffding-eproc")[
  $M_t$ is a nonnegative supermartingale starting at 1, hence an e-process:
  for every stopping time $tau$, $EE[M_tau]<=1$. Consequently, for i.i.d.
  $X_i$ bounded in an interval of width $w$ and mean $mu$,
  $ C_t = macron(X)_t plus.minus
    sqrt( (w^2 (log(2 slash alpha)+t lambda_0^2 slash 8)) / (t lambda_0) ) $
  optimized over the fixed $lambda_0$ is a valid fixed-$lambda$ CS;
  mixing $K_t (lambda)$ over a probability distribution $F$ on $lambda$
  preserves the e-process property by Tonelli's theorem and yields
  variance-adaptive mixtures — whose tight, nonasymptotic constants are the
  contribution of #cite(<howard2021timeuniform>, form: "prose") and are
  quoted there, not reproved here.
]
#proof-env[
  By Hoeffding's lemma, a mean-zero variable bounded in an interval of
  width $d$ satisfies $EE[e^(lambda Y)]<=e^(lambda^2 d^2 slash 8)$; applied
  conditionally to $X_t-mu$ with $d=b_t-a_t$,
  $EE[K_t|cal(F)_(t-1)]<=1$, so $EE[M_t|cal(F)_(t-1)]=M_(t-1) EE[K_t|cal(F)_(t-1)]<=M_(t-1)$.
  Nonnegative, starts at 1: the claims follow from @def:m-eprocess and
  @thm:m-ville. The displayed form of the interval comes from solving
  $lambda(bar(x))-lambda^2 w^2 slash 8 = log(2 slash alpha) slash t$ for
  $bar(x)$ after the two-sided union bound.
]

== Anytime-valid off-policy evaluation

#thm-env("theorem", name: [OPE confidence sequence under a ratio bound], key: "thm:m-ope-cs")[
  In the one-decision experiment of @def:m-dr with i.i.d. episodes,
  true behavior propensities known by design, target support ratio
  $w=e slash b<=C$ on the target's support, and bounded reward
  $abs(R)<=B$, define $X_i=W_i R_i$ with
  $W_i=e(A_i|S_i) slash b(A_i|S_i)$. Then $EE_b [X_i]=J(e)$
  (@thm:m-identificacion), $abs(X_i)<=C B$, and the process
  $ M_t (lambda) = product_(i<=t) exp(lambda (X_i - J(e)) - (2lambda C B)^2 slash 8) $
  is an e-process for the value hypothesis; the induced
  $(1-alpha)$-CS for $J(e)$ is valid at arbitrary stopping times,
  including continuous monitoring of the logged evaluation.
]
#proof-env[
  @thm:m-identificacion gives the mean; boundedness gives the width
  $2 C B$; the factors have conditional expectation at most one by
  Hoeffding's lemma exactly as in @thm:m-hoeffding-eproc, with note: the
  assumed bound is on the *true* ratio, a designed-support quantity —
  the largest sample ratio is a diagnostic, not this constant
  (@ass:m-overlap). Estimated weights leave the theorem's hypotheses
  (@def:m-is on true weights); their analysis is the framework below.
]

#thm-env("note", name: [The general framework and its declared conditions], key: "note:m-savi-ope")[
  #cite(<waudbysmith2022anytime>, form: "prose") derive doubly robust
  confidence sequences for off-policy mean reward in contextual bandits
  that remain valid at arbitrary stopping times while: relaxing fixed-sample
  analysis, uniformly bounded weights, constant logging policies, and
  constant policy values; allowing the logging policy itself to learn; and
  contexts forming a dependent time series. The e-processes use predictable
  weighting so that no weight bound need be known, and estimates adapt to
  empirical variance. No claim of that strength is proved in this chapter;
  @thm:m-ope-cs is the fully proved backbone in the designed-support
  regime, and the two are used together in Chapter 11.
]

== Using e-values correctly

+ *Predictability is the contract.* Any quantity entering the factor at $t$
  must be fixed before observing $X_t$; choosing the e-process after seeing
  the data voids the guarantee, as does reusing the same data to tune its
  parameters.
+ *Combination rules.* The arithmetic mean of e-values is an e-value
  ($EE[macron(E)]<=1$ by linearity — the proof is one line and worth
  keeping: it licenses running several monitors and combining them without
  new hypotheses). Products combine e-values exactly under independence,
  and by the e-variable calculus of #cite(<vovk2021evalues>, form: "prose").
+ *Power and safety trade off.* The e-process for a designed everything
  freely spendable at $1 slash alpha$ buys the right, not the tightness;
  variance adaptation exists to recover width, cf. @note:m-savi-ope.
+ *Stopping to deploy.* A lower CS bound crossing a deployment margin
  $delta_0$ at a data-dependent time is a level-$alpha$ statement even with
  that continuation rule; the remaining questions — causal scope,
  population, constraints — are outside any interval (@prop:m-protocolo).

== Laboratories

`labs/m_ch8_labA_stopping.py`: optional-stopping attack on the fixed-time
interval versus the CS, with Monte Carlo error of every reported coverage.
`labs/m_ch8_labB_gridcs.py`: mixture-grid CS for OPE value under designed
support; widths reported with their seeds. Outputs are registered in
`resultados_M.json`; the verification suite `verificacion/m_ch8_anytime.py`
rechecks the e-process expectation bound and Ville's threshold numerically.

== Readings

#cite(<ramdas2023game>, form: "prose") for the SAVI program and its
game-theoretic language; #cite(<vovk2021evalues>, form: "prose") for
e-value calibration and combination; #cite(<howard2021timeuniform>,
form: "prose") for nonasymptotic CSs; #cite(<waudbysmith2022anytime>,
form: "prose") for off-policy inference with adaptive logging.
