#import "../plantilla_M.typ": *

= The risk-preserving representation
<ch:m-representation>

An agent receives information and chooses an action whose consequences depend
on an unknown environment. Decision theory describes that choice through a
loss and its expected risk; MDPs describe actions, rewards, and transitions.
Connecting the languages requires preserving the information available for
deciding and the criterion used for comparison.

This chapter constructs an exact representation of a statistical decision
problem as a *family of one-decision MDPs*, indexed by the unknown parameter,
and then proves the structural frontier of that construction: exactly when a
sequential problem admits no such representation with its full strategy class.
The scope is a representation that preserves risk — not a category
equivalence, and no composition of decision rules is ever used.

== The two frames, recalled

#thm-env("definition", name: [Statistical decision problem], key: "def:m-ch4-wald")[
  Let $ParamSpace$ be finite nonempty, $SampleSpace$ finite or countable,
  $ActionSpace$ finite nonempty, and $L:ParamSpace times ActionSpace -> RR$
  bounded. A problem is $cal(D)=(ParamSpace,SampleSpace,(P_theta),ActionSpace,L)$;
  a deterministic rule $decrule:SampleSpace -> ActionSpace$ is chosen without
  knowing $theta$; its risk is
  $ R(theta,decrule)=sum_(x in SampleSpace) P_theta (x)L(theta,decrule(x)). $
  All comparisons happen within the class $cal(D)_0$ of deterministic rules,
  unless stated otherwise.
]

#thm-env("definition", name: [One-decision MDP with terminal state], key: "def:m-ch4-mdp")[
  An initial state $S_0$ in $SampleSpace$ is observed, an action
  $A_0 in ActionSpace$ is chosen, one reward is received, and the process
  reaches a terminal state $s_"fin"$ of zero further reward. A deterministic
  policy is a map $policy:SampleSpace -> ActionSpace$. For the model indexed
  by $theta$, distinguish
  $ V_theta^policy (x)=r_theta (x,policy(x)), quad
    J_theta (policy)=sum_x P_theta (x)V_theta^policy (x): $
  value conditioned on the initial state, and return averaged over the
  initial distribution. Discount one is admissible: a single reward, finite
  horizon.
]

== The representation theorem

#thm-env("theorem", name: [Risk-preserving representation], key: "thm:m-repr")[
  For the problem of @def:m-ch4-wald, construct for each $theta$ an MDP
  $cal(M)_theta$ with initial distribution $P_theta$, reward
  $r_theta (x,a)=-L(theta,a)$, and deterministic transition to the terminal
  state. The correspondence $F(decrule)=policy_decrule$, $policy_decrule (x)=decrule(x)$,
  is a bijection between deterministic rules and deterministic policies on
  the decision states of this family. For every $theta$ and every rule,
  $ J_theta (policy_decrule) = -R(theta,decrule). $
  One policy is used under all models. The bijection refers to pointwise
  functions; two distinct rules may share the same risk, for instance if
  they differ only on observations that are null under every model.
]
#proof-env[
  Rule and policy have the same domain and codomain, and copying them in
  either direction yields inverse maps. By the reward definition,
  $ J_theta (policy_decrule) = sum_x P_theta (x)[-L(theta,decrule(x))] = -R(theta,decrule). $
  Boundedness gives absolute convergence; the terminal transition adds no
  future rewards. More in @dem:m-repr. The three core identities of this
  chapter are the object of the machine-checked verification pilot
  (`VERIFICACION_LEAN_PLAN.md`, Phase 0).
]

#thm-env("note", name: [Scope of the construction], key: "note:m-alcance")[
  The initial state is observable; the index $theta$ is not. The family
  evaluates a common policy; it does not hand the agent the true model, and
  the evaluative reward need not be observable after acting — a statistical
  loss may depend on a truth that never becomes visible, so this is not, by
  itself, a reinforcement-learning reward protocol. The identity uses
  $J_theta$, not $V_theta^policy (x)$; it does not equate a general MDP with
  a one-decision statistical problem.
]

== What travels: criteria within a fixed class

#thm-env("corollary", name: [Bayes criterion], key: "cor:m-bayes")[
  For a prior $nu$, with $rho_nu (decrule)=sum_theta nu(theta)R(theta,decrule)$ and
  $J_nu (policy)=sum_theta nu(theta)J_theta (policy)$, one has
  $J_nu (policy_decrule)=-rho_nu (decrule)$: minimizers of Bayes risk correspond
  to maximizers of average return. The joint law used is
  $nu(theta)P_theta (x)$; it cannot generally be replaced by an
  averaged reward without conditioning on $x$.
]

#thm-env("corollary", name: [Minimax criterion], key: "cor:m-minimax")[
  $ inf_(decrule in cal(D)_0) sup_(theta in ParamSpace) R(theta,decrule)
    = -sup_policy inf_(theta in ParamSpace) J_theta (policy). $
  When optima exist, minimax rules correspond to maximin policies. Randomizing
  both sides enlarges the classes consistently; a deterministic optimum may
  cease to be optimal in the enlarged class (cf. @ex:m-ssch-cap02).
]

#thm-env("theorem", name: [Admissibility as non-dominated return], key: "thm:m-admis")[
  $decrule$ is admissible in $cal(D)_0$ if and only if no policy of the
  corresponding class satisfies $J_theta (policy')>=J_theta (policy_decrule)$ for
  all $theta$ with strict inequality somewhere. The order compares the vector
  of returns indexed by *models*, not by observed initial states; the
  conclusion is a sign change in the definition of dominance
  (@dem:m-transfer).
]

== The frontier: when the law of the data depends on the rule <sec:m-frontier>

The construction above is a *folding* of one decision into one observation.
Why does it break in honest sequential problems? Because in an MDP the law
of the history depends on the policy, while a statistical experiment assigns
one law per parameter. This can be made into a theorem, which is new in this
monograph (its course-book companion asserts the difficulty in prose).

#thm-env("definition", name: [Sequential problem with observation channel], key: "def:m-canales")[
  Fix finite spaces and horizon $H$. A sequential problem family indexed by
  $theta$ consists of an initial law $mu_theta (s)$, a per-time observation
  kernel $q_theta (y_(t+1)|h_t,a_t)$, reward kernels, and an action set; a
  (history-dependent) strategy $sigma$ assigns actions $a_t=sigma(h_t)$ with
  $h_t=(s_0,a_0,y_1,dots.h)$. The channel is *policy-independent at $t$* if
  $q_theta (dot.c|h_t,a_t)$ does not depend on $a_t$ for all reachable $h_t$.
]

#thm-env("theorem", name: [Structural frontier of risk-preserving folding], key: "thm:m-frontier")[
  Suppose there exist $theta$, a time $t >= 0$, a history $h_t$ reached with
  positive probability under $theta$ by the two prefix-agreeing strategies
  below, and actions $a != a'$ such that
  $ q_theta (B|h_t,a) != q_theta (B|h_t,a') $
  for some event $B$ on the next observation. Then there is no family
  $(tilde(P)_theta)$ of laws on the trajectory space and no loss
  $tilde(L)$ such that, for *every* history-dependent strategy $sigma$, the
  expected total reward of $sigma$ under $theta$ equals minus the Wald risk
  of an associated rule under $tilde(P)_theta$ with the same averaging over
  trajectories. In words: when actions change the law of future observations,
  no Wald experiment folds the whole sequential problem with its strategy
  class.
]
#proof-env[
  Assume such $(tilde(P)_theta,tilde(L))$ existed. Let $sigma,sigma'$ agree
  strictly before $t$ and take $sigma(h_t)=a$, $sigma'(h_t)=a'$. The law of
  the full trajectory induced by a strategy is then fixed; denote it
  $Prob_theta^sigma$. A Wald experiment assigns one law $tilde(P)_theta$ to
  trajectories, so both induced laws would have to equal $tilde(P)_theta$ on
  the cylinder event $E={h_t "occurs", Y_(t+1) in B}$. But
  $ Prob_theta^sigma (E) = Prob_theta^sigma (h_t) dot q_theta (B|h_t,a) $
  and likewise for $sigma'$ with $a'$. By prefix agreement,
  $Prob_theta^sigma (h_t)=Prob_theta^(sigma') (h_t)>0$; hence
  $Prob_theta^sigma (E) != Prob_theta^(sigma') (E)$, contradicting
  $tilde(P)_theta (E)$ being both. The argument is exact in finite spaces;
  in general measurable spaces the same cylinder computation applies with
  regular versions. @dem:m-frontier discusses the boundary — unreachable
  histories exempted by the hypothesis — and the two positive special cases
  used in this book.
]

#thm-env("proposition", name: [The two admissible folds], key: "prop:m-foldings")[
  (i) Horizon one is always foldable: with no future observations, there is
  no law for actions to change (@thm:m-repr).
  (ii) Uncontrolled observe-and-stop problems are foldable at the level of
  information states: the per-observation channel $q_theta (y)$ is
  policy-independent, and control acts only on continuation; Chapter 5 gives
  the exact dynamic program and its hypotheses. Beyond these cases, a
  risk-preserving representation with the full strategy class fails by
  @thm:m-frontier.
]

#thm-env("note", name: [How to read this frontier], key: "note:m-frontera")[
  The theorem is not "the representation is limited"; it is the precise
  reason, and it doubles as a checkable condition: to fold a sequential
  system into one experiment, verify that actions do not enter the
  observation kernel within the episode. Learning-enabled agents usually
  violate it — their actions change what is observed next — which is exactly
  why Part II must treat estimation separately instead of transferring
  guarantees.
]
