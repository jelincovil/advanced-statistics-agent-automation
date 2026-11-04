#import "../plantilla_M.typ": *

= Statistical experiments and comparison
<ch:m-experiments>

Before deciding, one must say what can be learned. A statistical experiment
precisely specifies the data and their possible distributions. This chapter
fixes that vocabulary — experiments, statistics, sufficiency, completeness —
and the comparison of experiments that will later tell us what the
representation of Chapter 4 preserves. The classic results are stated with
their hypotheses; proofs are in Appendix A.

== Experiments and statistics

#thm-env("definition", name: [Statistical experiment], key: "def:m-experiment")[
  An experiment is a triple $cal(E)=(SampleSpace, cal(F), (P_theta)_(theta in ParamSpace))$:
  a measurable space of observations and a family of probability measures
  indexed by a parameter set. The family is part of the object: it declares
  what the observation can reveal about what is unknown. A statistic is a
  measurable map $T:SampleSpace -> cal(T)$. An experiment is dominated when
  all $P_theta$ share a density with respect to one sigma-finite measure.
]

== Data reduction: sufficiency

#thm-env("definition", name: [Sufficiency], key: "def:m-sufficiency")[
  $T$ is sufficient for $theta$ when a version of the conditional
  distribution of the data given $T$ can be chosen not to depend on $theta$.
  Sufficiency is a property of the experiment, not of a storage format:
  declaring a field in a program does not create it (cf. @note:m-state-three).
]

#thm-env("theorem", name: [Neyman–Fisher factorization], key: "thm:m-factorization")[
  In a dominated experiment with standard Borel spaces, $T$ is sufficient if
  and only if the densities factor as $f_theta (x)=g_theta (T(x))h(x)$ for
  measurable $g_theta,h$; $h$ may be chosen independent of $theta$.
]
#proof-env[
  In one direction, a common conditional kernel and the Halmos–Savage
  dominating mixture give $dif P_theta slash dif Q = g_theta (T)$; in the
  other, the conditional expectation under the mixture is seen not to
  depend on $theta$. Full argument and regularity conditions: @dem:m-factorization.
]

#thm-env("definition", name: [Minimal sufficiency], key: "def:m-minimal")[
  $T$ is minimal sufficient if it is sufficient and a function of every
  sufficient statistic (up to null sets). The likelihood-ratio classes
  criterion: under the precise measurability hypotheses of Appendix A, the
  statistic that identifies the proportionality classes of the likelihoods
  is minimal sufficient.
]

#thm-env("definition", name: [Completeness], key: "def:m-complete")[
  $T$ is complete if $EE_theta [g(T)]=0$ for every $theta$ implies
  $g(T)=0$ almost surely under every $P_theta$. Completeness is what turns
  an identity in expectation into an identity of functions.
]

#thm-env("theorem", name: [Basu], key: "thm:m-basu")[
  If $T$ is boundedly complete and sufficient, and $A$ is ancillary (its
  distribution does not depend on $theta$), then $T$ and $A$ are independent
  under every $P_theta$. Proof: @dem:m-basu.
]

Completeness holds in exponential families whose natural parameter space
contains an open set (Appendix B). Trajectory counts of a Markov chain do
*not* inherit the completeness of a fixed-size multinomial experiment:
their random totals define another experiment — this warning will matter
when agents store counts of transitions (Chapter 6).

== An example of what risk comparison buys: James–Stein

#thm-env("example", name: [James–Stein], key: "ex:m-james-stein")[
  For $X tilde N_p (theta,I_p)$, $p>=3$, squared-loss risk, the rule
  $delta_0 (X)=X$ has constant risk $p$, while
  $ delta_("JS")(X)=(1-(p-2)/norm(X)^2)X $ has risk
  $ p - (p-2)^2 EE_theta [1/norm(X)^2] < p . $
  The expectation is finite for $p>=3$; the identity is Stein's lemma
  applied to $div(x slash norm(x)^2)=(p-2) slash norm(x)^2$ (@dem:m-james-stein).
  The dimension at stake is that of the parameter, not the number of
  observations of a scalar mean.
]

== Comparing experiments

#thm-env("note", name: [Blackwell informativeness, at reading level], key: "note:m-blackwell")[
  An experiment $cal(E)$ is more informative than $cal(E)'$ if every risk
  function achievable under $cal(E)'$ is achievable under $cal(E)$
  (equivalently: $cal(E)'$ is a garbling of $cal(E)$, or their Le Cam
  deficiencies vanish in one direction). Sufficiency is the special case
  where a statistic loses nothing. This book uses the vocabulary only where
  it sharpens a claim: Chapter 4's frontier and Chapter 10's certificates.
  The systematic theory is in #cite(<torgersen1991comparison>, form: "prose")
  and #cite(<blackwell1951comparison>, form: "prose").
]

#thm-env("note", name: [Three distinct requirements on a "state"], key: "note:m-state-three")[
  A typed data structure says what is stored. Statistical sufficiency says
  which sample information about a parameter is retained. An information
  state for control must allow computing the relevant future distributions
  and costs. Markovianity is a property of a transition law. None of these
  follows from declaring a `StateSchema`. Chapter 6 gives the failure
  taxonomy; Chapter 4 and Chapter 5 give two settings where the right
  object is provably enough.
]
