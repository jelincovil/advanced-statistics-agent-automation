#import "../plantilla_M.typ": *

= Learned policies: evaluation, gradients, SAVE
<ch:m-learned>

Everything so far evaluated a *fixed* policy. When the same data also train
the policy, the object evaluated can change with each block — and the error
that evaluation must control changes character. This chapter fixes the
three pieces that remain rigorous here: the policy-gradient identity with
its baseline calculus, the sequential organization of evaluation (SAVE),
and the margin condition that converts estimation error into decision loss.

== Policy gradient with a computed baseline

#thm-env("definition", name: [Differentiable policy objective], key: "def:m-pg")[
  Finite horizon $H$, fixed initial distribution, environment kernel
  independent of the policy parameter $theta$,
  $J(theta)=EE_theta (sum_(t=0)^(H-1) discount^t R_t)$, action score
  $z_t=nabla_theta log pi_theta (A_t|S_t)$, return-to-go $G_t$; enough
  integrability to exchange derivative and integral.
]

#thm-env("theorem", name: [Policy gradient identity], key: "thm:m-pg")[
  $ nabla_theta J(theta)=EE_theta (sum_(t=0)^(H-1) discount^t z_t G_t)
    =EE_theta (sum_(t=0)^(H-1) discount^t z_t q_t^(pi_theta)(S_t,A_t)). $]
#proof-env[
  Only action probabilities depend on $theta$, so the trajectory score is
  $sum_t z_t$; rewards before $t$ vanish in expectation against $z_t$
  (conditional mean zero given history); conditioning on $(S_t,A_t)$
  substitutes $G_t$ by $q_t$. Full steps: @dem:m-pg. Infinite horizon needs
  domination conditions: $discount<1$ alone does not control an arbitrarily
  large score.
]

#thm-env("proposition", name: [Baselines: centring and variance], key: "prop:m-baseline")[
  If $b_t$ depends on the pre-action history but not on the sampled action,
  $EE(z_t b_t)=0$ under integrability, and $G_t$ may be replaced by
  $G_t-b_t$ without changing the gradient's mean. For a vectorial
  single-time contribution, minimizing the trace of the conditional
  variance gives
  $ b^* (s)=frac(EE(norm(z)^2 G|S=s),EE(norm(z)^2|S=s)), $
  when the denominator is positive — which need not equal $V(s)$, and does
  not solve the many-times minimization automatically.
]

#thm-env("example", name: [A baseline can help, hurt, or kill variance], key: "ex:m-baseline", es-sintetico: true)[
  One abstract decision: $A$ Bernoulli with $p=1 slash(1+e^(-theta))$,
  $R=A$, $p=0.75$; true gradient $p(1-p)=0.1875$. Contribution without
  baseline $A(A-p)$: values in ${0,0.25}$, variance $0.01171875$. Baseline
  $b=p$: values ${0.5625,0.0625}$, variance $0.046875$ — four times larger.
  Baseline $b=1-p$: value $0.1875$ for both actions, variance zero.
  Same model, three outcomes (`verificacion/m_ch9_pg.py`).
]
#thm-env("example", name: [Continuous state, checkable gradient], key: "ex:m-pg-ssch", es-sintetico: true)[
  $S$ uniform on $[-1,1]$, $pi_theta (1|s)=1 slash(1+e^(-theta s))$,
  $R=A S$; at $theta=0$ the true gradient is $EE(S^2) slash 4=1 slash 12$.
  Contribution without baseline has variance $13 slash 720$; with
  $b(s)=s slash 2$ it is $1 slash 180$: a reduction of $9 slash 13 approx 69.2%$
  from $EE(S^2)=1 slash 3$ and $EE(S^4)=1 slash 5$ alone
  (`verificacion/m_ch9_pg.py`).
]

== When the data also train the policy

Let $pi_k$ be learned before an evaluation block and $hat(J)_k$ estimate its
value; a weighted average with predetermined weights $a_k$ estimates a
mixture of values of *different* policies, and against a final $pi_f$
appears the term
$ sum_k a_k (J(pi_k)-J(pi_f)), quad sum_k a_k=1, $
which does not vanish by respecting temporal order even with centred block
errors. Controlling it at the interval's scale is the problem SAVE
(SequentiAl Value Evaluation) solves by its specific partition, aggregation,
and studentization; an arbitrary average of DR contributions does not
reproduce it.

#thm-env("note", name: [What may be attributed, and to what], key: "note:m-save-atrib")[
  The value-function inference of
  #cite(<shi2022statistical>, form: "prose") obtains, for a fixed policy,
  a studentized
  $ sqrt(n T)(hat(J)(policy;nu)-J(policy;nu)) slash hat(sigma)(policy;nu)
    arrow.r^d N(0,1) $ under the complete hypotheses of their Theorem 1 —
  bases, regularity, information, dimension growth — in their regimes with
  $n$ or $T$ increasing. Appendix B carries the reading-level statement;
  their proofs are an outline in the article and full in its supplement.
  Sequential evaluation under their Teorems 3–4 ties value rates to margin
  conditions; none of it is a re-statement of DR, none of it follows from
  the Wald embedding, and learning the logging policy is its own problem.
]

#thm-env("example", name: [Margin converts error into loss, elementarily], key: "ex:m-margin", es-sintetico: true)[
  Two actions, $Delta(s)=abs(q(s,1)-q(s,0))$, and suppose
  $Prob(0<Delta(S)<=u)<=C u^kappa$. If $norm(hat(q)-q)_infinity<=epsilon.alt$,
  a wrong greedy action has positive gap at most $2 epsilon.alt$, so
  $ EE(q(S,a^* (S))-q(S,hat(a)(S))) <= C(2 epsilon.alt)^(1+kappa). $
  Ties cost zero. This calculation is self-contained for one decision; it
  certifies no neural error rate and substitutes none of the article's
  longitudinal conditions (`verificacion/m_ch9_margin.py`).
]

#thm-env("note", name: [Freeze, then evaluate], key: "note:m-freeze")[
  With a policy learned and frozen on one part of the data, evaluation on
  independent episodes conditions on the training set: the target is the
  value of *that* policy — not the unknown optimal one — and Chapters 7–8
  apply as stated. A pointwise interval for the learned policy is never a
  simultaneous band over the whole search.
]

== Readings

#cite(<shi2022statistical>, form: "prose") with its supplement before any
use of its normalization; #cite(<sutton2018reinforcement>, form: "prose")
for policy gradients in context; #cite(<kallus2020double>, form: "prose")
for what efficiency means in the same temporal model.
