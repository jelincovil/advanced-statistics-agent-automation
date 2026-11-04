#import "../plantilla_M.typ": *

= Wald's decision theory
<ch:m-wald>

An estimate summarizes what the data allow one to know; a decision adds the
consequences of acting. Wald's framework reunites observations, models,
actions, and losses, and compares complete rules under uncertainty. This
chapter develops a single decision from one sample; the MDP chapter adds
future consequences, and Chapter 4 makes their relation exact.

// The running synthetic thread is introduced here: an imperfect signal
// suggests whether to intensify follow-up. All its figures are illustrative.

== Problems, rules, and risk

#thm-env("definition", name: [Statistical decision problem], key: "def:m-wald")[
  A problem is specified as
  $ cal(E)=(ParamSpace,SampleSpace,(P_theta)_(theta in ParamSpace),ActionSpace,L), $
  with measurable structures everywhere and functions measurable as needed.
  Losses are nonnegative or integrable enough that the risks considered are
  finite; bounded losses of either sign are admissible.
]

#thm-env("definition", name: [Rules and classes], key: "def:m-reglas")[
  A deterministic rule is a measurable $decrule:SampleSpace -> ActionSpace$;
  a randomized rule is a kernel $d(a|x)$ with $d(a|x)>=0$ and $sum_a d(a|x)=1$
  (finite actions). Randomization uses available information plus randomness
  independent of the parameter. The class of allowed rules $cal(D)$ must be
  declared; comparisons change when it changes.
]

Risk: for a deterministic rule, $R(theta,decrule)=EE_theta [L(theta,decrule(X))]$;
for randomized, $R(theta,d)=EE_theta [sum_a d(a|X)L(theta,a)]$. Risk is a
function of $theta$; in general no single rule minimizes all its components.

#thm-env("definition", name: [Dominance and admissibility], key: "def:m-dominancia")[
  $decrule_1$ dominates $decrule_2$ in $cal(D)$ if
  $R(theta,decrule_1)<=R(theta,decrule_2)$ for all $theta$ with strict
  inequality somewhere. A rule is admissible when nothing in its class
  dominates it. Admissibility discards uniform improvements; it does not
  order rules nor establish optimality for a particular prior.
]

== Criteria: Bayes, minimax, and their ties

#thm-env("definition", name: [Prior and Bayes risk], key: "def:m-riesgo-bayes")[
  A prior $nu$ defines $rho_nu (decrule)=integral R(theta,decrule)nu(dif theta)$
  and the optimal Bayes value $b(nu)=inf_(decrule in cal(D))rho_nu (decrule)$.
  A rule attaining the infimum is a Bayes rule — optimal relative to the
  prior, loss, and declared class.
]

#thm-env("theorem", name: [Posterior loss minimization], key: "thm:m-bayes-posterior")[
  Suppose a regular posterior $nu(dif theta|x)$ exists, $ActionSpace$ is
  finite, and $L$ is bounded and measurable. Choose, for each $x$, an action
  minimizing the posterior loss $ell_nu (x,a)=integral L(theta,a)nu(dif theta|x)$,
  with a fixed tie-break. The resulting rule is measurable and Bayes among
  all rules, randomized included; every Bayes rule concentrates on
  minimizers for predictively almost every observation. Details: @dem:m-existencia-bayes.
]

#thm-env("theorem", name: [Minimax certified by Bayes], key: "thm:m-minimax-bayes")[
  If $decrule_nu$ is Bayes and
  $sup_theta R(theta,decrule_nu)=rho_nu (decrule_nu)<infinity$ — in particular
  if its risk is constant on all of $ParamSpace$ — then it is minimax.
  Constancy only on the prior's support does not suffice (@dem:m-bayes-minimax).
]

#thm-env("theorem", name: [Essentially complete class, finite problem], key: "thm:m-clase-completa")[
  With finite $ParamSpace,SampleSpace,ActionSpace$, finite loss, and all
  randomized rules allowed, every admissible rule is Bayes for some prior
  (possibly assigning zero mass to some parameters), and every rule has a
  Bayes rule whose risk is nowhere larger. Convexity and a supporting
  hyperplane; proof in @dem:m-clase-completa. This is a statement about the
  finite problem, not a general Bayes-limits theorem.
]

#thm-env("proposition", name: [Bayes rules are admissible under a positive prior], key: "thm:m-adm-bayes")[
  If $ParamSpace$ is finite, $nu(theta)>0$ everywhere, and $decrule_nu$ has
  finite Bayes risk, then $decrule_nu$ is admissible within the same class.
]

== Tests as decision rules and the thread example

#thm-env("proposition", name: [Tests as rules], key: "prop:m-test-decision")[
  Hypotheses partition $ParamSpace$; accepting/rejecting have losses
  $w_I,w_(I I)>0$ for the two error types. The Bayes rule rejects when
  $w_I Prob(ParamSpace_0|X)<w_(I I)Prob(ParamSpace_1|X)$. Frequentist level
  control is an additional constraint; choosing losses and a prior does not
  guarantee a prescribed level.
]

#thm-env("example", name: [SSCH: signal, loss, and class of rules], key: "ex:m-ssch-cap02", es-sintetico: true)[
  $theta in {0,1}$: need for intensified follow-up. Signal $X in {0,1}$ with
  $P_0 (X=1)=0.2$, $P_1 (X=1)=0.8$. Losses $1$ for intensifying without need,
  $4$ for missing the need. With prior $nu(1)=0.3$:
  #table(columns: (34%, 20%, 20%, 26%),
    table.header([*Rule*], [$R(0)$], [$R(1)$], [*Bayes risk*]),
    [Always routine], [0], [4], [1.20],
    [Always intensified], [1], [0], [0.70],
    [Follow the signal], [0.20], [0.80], [0.38],
    [Invert the signal], [0.80], [3.20], [1.52],
  )
  Following the signal is Bayes and minimax among the four deterministic
  rules. Allowing randomization, a better worst-case rule intensifies always
  if $X=1$ and with probability $3/8$ if $X=0$: both risks equal $1/2$, and
  the prior $nu^* (1)=1/2$ certifies minimaxity via @thm:m-minimax-bayes
  (verification: `verificacion/m_ch2_ssch.py`).
]

#thm-env("note", name: [What each criterion does not promise], key: "note:m-criterios")[
  Minimax controls the worst expected risk inside the declared family; it is
  not safety per trajectory and the least worst case may still be bad.
  Posterior minimality is relative to the prior. Switching criteria using
  the same data used for evaluation defines a new procedure whose risk must
  be analyzed as a whole.
]

== Readings

#cite(<wald1950statistical>, form: "prose") for the foundation;
#cite(<berger1985statistical>, form: "prose") and
#cite(<ferguson1967mathematical>, form: "prose") for losses, Bayes and
minimax rules; each read with its class of rules and hypotheses.
