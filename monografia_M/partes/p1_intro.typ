#import "../plantilla_M.typ": *

#cap-sin-numero[
= Introduction
<ch:m-intro>
]

An imperfect signal can be enough to change a decision. A monitoring system
observes a measurement and chooses between routine attention and
intensified care. To choose, it needs more than a prediction: it must weigh
the cost of each error and the information that was available when it acted.
If the intervention changes next period's measurements, the same question
acquires a temporal dimension.

Statistical decision theory and Markov decision processes (MDPs) describe
those two situations. Wald compares rules by the loss they produce under
each plausible model. Dynamic programming organizes present and future
consequences of actions. This book studies the relation between the two
languages — what can be preserved when passing from one to the other, and
what demands a new argument — and then asks the harder question: *what can
be learned about a decision rule from data, and with what guarantees?*

== The thesis, stated narrowly

A risk-preserving representation exists: any finite Wald decision problem
can be written as a family of one-decision MDPs, indexed by the unknown
parameter, in such a way that the return of the copied policy equals minus
the risk of the rule (Chapter 4). Bayes, minimax, and admissibility travel
through this identity — within a fixed class of rules. What does *not*
travel automatically is everything inferential: an identity between
objectives produces no data, no estimator, no interval. The traceability
discipline of this book consists in saying, at each step, which of the two
kinds of statement is being made.

#thm-env("definition", name: [Informal statement of the representation], key: "def:m-informal")[
  A rule that maps an observation to an action can be read as a policy on
  that same observation. If the reward in each model is the negative loss,
  the average return of the policy coincides with minus the risk of the
  rule. The parameter remains unknown and is not part of the information
  available for acting. @thm:m-repr gives the conditions and the exact
  identity; its converse frontier is @thm:m-frontier.
]

#block(breakable: false)[
#mi-tabla(
  caption: [Objects that must be preserved across the representation. Inferential
  guarantees are justified separately, for the actual experiment.],
  key: "tab:m-correspondencia",
  table(
    columns: (23%, 38%, 1fr),
    align: (left, left, left),
    hl(),
    table.header([*Object*], [*Role in the representation*], [*Distinction to keep*]),
    hl(w: 0.6pt),
    [$ParamSpace$], [Unknown index of the model family], [The decision maker does not observe the parameter],
    [$SampleSpace$], [Observation received by the policy], [The available information is the same],
    [$ActionSpace$], [Common action set], [The same class of rules is compared],
    [$Loss(theta,a)$], [Negated reward], [Evaluation keeps its dependence on the model],
    [$Risk(theta,decrule)$], [Average negative return], [The average uses the distribution of the observation],
    [Interval, test, estimator], [Statistical procedure on data], [Its guarantee needs additional hypotheses],
    hl(),
  ),
)
]

== Reading map

Chapters 1–3 fix the two frameworks: experiments and sufficiency, Wald,
finite discounted MDPs. Chapter 4 proves the representation and its
structural frontier; Chapter 5 the Bayesian stopping extension. Chapters 6–9
are the estimation part: identification and its failures, DM/IS/DR with
their variance analysis, anytime-valid policy evaluation (the monograph's
main addition to the course material), and learned policies. Chapters 10–13
close: transfer certificates, the real-data study, the language-agent
frontier, and open problems. Appendix A carries every proof whose statement
appears in the body and is not explicitly credited to a source.

== Prerequisites

Conditional expectation, convergence in distribution, measurable structure;
estimation, testing, and confidence intervals at the graduate level; norms,
projections, and contraction arguments. Appendix B is a reference summary of
every invoked tool, organized by where the book invokes it.

#pendiente[Exercises are not yet ported to this draft. The companion
course book contains a full set per chapter; they will be adapted once the
English text is stable.]
