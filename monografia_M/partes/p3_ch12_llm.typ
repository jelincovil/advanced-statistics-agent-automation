#import "../plantilla_M.typ": *

= Frontier: evaluating language agents
<ch:m-llm>

In a language agent, an action is a token sequence whose probability depends
on the generation context. The evaluation questions of Part II return with
force: what is the action, what is its recorded probability, and what does
comparing two texts mean? This chapter states what transfers and what does
not, with the partial results proven here marked as such and the rest
marked open. Nothing in this chapter claims coverage that the hypotheses do
not discharge.

== The objects

#thm-env("definition", name: [Language agent], key: "def:m-llm-agent")[
  A language agent maps observations $o_t in cal(O)$ (text, possibly
  multimodal) into actions $a_t in cal(A)_L = union.big_(k=1)^L Sigma^k$
  (sequences of up to $L$ tokens), through a policy
  $ policy(a|o) = product_(j=1)^(|a|) p_"LLM" ("token"_j | o, "tokens"_(<j)), $
  computed by the *effective sampler* — after temperature, filters, and
  constraints, whose probabilities may differ from the base model's.
]

#thm-env("proposition", name: [Propensity from log-probabilities], key: "prop:m-logprobs")[
  If the generator returns per-token log-probabilities of the effective
  sampler, the logged probability of a complete action (including its
  termination rule) is computable in log scale as their sum. Limitation: it
  requires access to the log-probs of the model that generated the data —
  absent in most commercial deployments and in cross-vendor logs.
]

== What a decrease in granularity preserves

#thm-env("definition", name: [Template discretization], key: "def:m-templates")[
  Fix $K$ templates and a dissimilarity $d$; map each action to its nearest
  template with a fixed tie-break. The grouped action space is
  $tilde(ActionSpace)={T_1,dots.h,T_K}$. Applying OPE requires specifying how
  an action inside a group is selected and executed, and justifying
  identification for that intervention.
]

#thm-env("proposition", name: [A discretization bound needs a declared metric], key: "prop:m-sesgo-disc")[
  In one decision, let $g(a)$ be the executable template and suppose the
  reward mean satisfies $sup_(s,a) abs(m(s,a)-m(s,g(a)))<=epsilon.alt$. If
  the grouped policy is the image of the original under $g$, integrating
  the reward difference over the initial state gives
  $abs(J(policy)-J(policy_g))<=epsilon.alt$. With an analogous uniform
  condition on $Q^policy$, the performance-difference lemma bounds the
  discounted infinite-horizon gap by $epsilon.alt slash(1-discount)$.
  Semantic similarity alone establishes neither condition
  (@dem:m-sesgo-disc).
]

== Identifiability without the policy's probabilities

#thm-env("proposition", name: [Non-identification without action probabilities], key: "prop:m-noident")[
  Consider one-decision evaluation of a fixed target policy $e$ whose action
  probabilities are *not* computable for any logged or novel observation
  (text out, probabilities unreachable), with contexts $s$ and bounded
  rewards. Then $J(e)$ is not point-identified from records $(S,A,R)$
  alone: $J(e)$ is an integral against the unknown law $e(a|s)$, and two
  laws for $e$ that agree on all logged support but differ on never-logged
  texts induce different values of $J(e)$ with identical records. Point
  estimation is restored only by quantities the record must carry —
  log-probs (@prop:m-logprobs), a registered sampling wrapper, or a
  class constraint on $e$ — and partial identification under explicit
  rarity models is the remaining honest object (@dem:m-noident discusses
  the construction).
]

#thm-env("note", name: [DR conditions for textual actions], key: "note:m-dr-llm")[
  For one-decision evaluation with finitely many templates, @thm:m-dr-eficiencia
  applies if the grouping defines an identified intervention, the target is
  fixed, units are i.i.d., rewards and fits are uniformly bounded, propensities
  (true and fitted) are bounded away from zero on the target support, folds
  split by independent unit, both auxiliaries converge in $L^2$ with product
  $o_P (n^(-1 slash 2))$, and the limiting variance is positive. Sequential
  textual trajectories need the longitudinal estimator and its own theorem;
  the three single-step requirements in isolation do not prove that extension
  (certificate status of each condition: to be discharged per deployment,
  per @ch:m-certificates).
]

#thm-env("note", name: [Report when the guarantee is absent], key: "note:m-nogarantia")[
  When the policy's probabilities are not computable, when the grouping
  changes the estimand without an approximation bound, or when prompt-history
  confounding is absent from the state, the correct report is the absence of
  the guarantee — an identification region, a sensitivity analysis, or a
  descriptive comparison — not a confidence interval with assumed coverage
  (@def:m-reportable).
]

#pendiente[Open development (planned contribution, not claimed here): a
partial-identification calculus for textual actions with rarity models,
and a wrapper protocol that makes commercial samplers record effective
propensities by construction. Will graduate from this box when the proofs
exist.]
