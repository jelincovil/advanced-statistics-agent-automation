#import "../plantilla_M.typ": *

= Proofs
<app:demostraciones>

Proofs referenced from the body, by topic. Statements marked "sketch"
declare it on line; every other proof is complete. The numbering in the
body points here through its theorem numbers.

== Sufficiency and exponential families

=== Neyman–Fisher factorization <dem:m-factorization>
#proof-env(name: [of @thm:m-factorization])[
  In the dominated model, choose a countable mixture $Q=sum_j c_j P_(theta_j)$,
  $c_j>0$, dominating every law of the family (Halmos–Savage lemma, valid in
  a dominated experiment), and write $f_theta=dif P_theta slash dif Q$. If $T$
  is sufficient, its common conditional kernel $K(t,B)$ is also the law of
  $X|T$ under $Q$; with $g_theta=dif P_theta^T slash dif Q^T$, disintegration
  gives $P_theta (B)=integral_B g_theta (T(x))dif Q(x)$, whence
  $f_theta (x)=g_theta (T(x))$ $Q$-a.s., which is the factorization after
  multiplying by the density of $Q$. Conversely, that factorization makes
  $dif P_theta slash dif Q$ a function of $T$, so
  $ EE_theta [bb(1)_B|T]=EE_Q [f_theta bb(1)_B|T] slash EE_Q [f_theta|T], $
  a function of $T$ independent of $theta$ wherever the denominator is
  positive; outside that support the version is irrelevant under $P_theta$.
  Standard Borel spaces provide the regular kernels used.
]

=== Basu's theorem <dem:m-basu>
#proof-env(name: [of @thm:m-basu])[
  Fix a measurable set $B$ for the ancillary statistic and set
  $h(T)=P_theta (A in B|T)$. By sufficiency $h$ has a version free of $theta$;
  by the tower property $EE_theta [h(T)]=P(A in B)$ for every $theta$; so
  $g(T)=h(T)-P(A in B)$ has mean zero at every parameter and completeness
  kills it: $h(T)=P(A in B)$ a.s. — independence. Conditions: $T$ boundedly
  complete sufficient, $A$ ancillary, conditional probabilities well-defined.
]

=== James–Stein risk identity <dem:m-james-stein>
#proof-env(name: [of the identity in @ex:m-james-stein])[
  Write $delta_("JS")(x)=x+g(x)$ with $g(x)=-(p-2)x slash norm(x)^2$,
  $x != 0$. Stein's identity for squared error gives
  $R(theta,delta_("JS"))=p+EE_theta [norm(g(X))^2+2 div g(X)]$, and for
  $x != 0$, $norm(g)^2=(p-2)^2 slash norm(x)^2$ and
  $div(x slash norm(x)^2)=(p-2) slash norm(x)^2$, so
  $R(theta,delta_("JS"))=p-(p-2)^2 EE_theta [1 slash norm(X)^2]$. The
  expectation is finite for $p>=3$ (integrability of $norm(x)^(-2)$ near
  the origin requires $p>2$), and the risk of $delta_0(X)=X$ is $p$.
]

== Wald criteria

=== Posterior minimization, in detail <dem:m-existencia-bayes>
#proof-env(name: [of @thm:m-bayes-posterior])[
  Each posterior loss $ell_nu (x,a)$ is measurable and finite. Enumerate the
  actions and pick the first index attaining the minimum; its selection
  region is a finite intersection of comparisons of measurable functions, so
  the rule is measurable. Iterated expectation writes the Bayes risk of any
  randomized rule as the expectation of a convex combination of posterior
  losses, each at least $min_a ell_nu (X,a)$; the constructed rule attains
  the bound. Equality for another rule forces the nonnegative difference to
  vanish predictively almost surely, hence its mass on minimizers. Compact
  or noncompact action sets need extra existence and measurable-selection
  hypotheses not asserted here.
]

=== Minimax certified by Bayes <dem:m-bayes-minimax>
#proof-env(name: [of @thm:m-minimax-bayes])[
  For any rule $decrule$,
  $sup_theta R(theta,decrule>=rho_nu (decrule)>=rho_nu (decrule_nu)$. By the
  theorem's condition, $rho_nu (decrule_nu)=sup_theta R(theta,decrule_nu)$;
  chaining yields $sup_theta R(theta,decrule)>=sup_theta R(theta,decrule_nu)$
  for every $decrule$: $decrule_nu$ is minimax. The middle inequality needs
  control of the risk over the *whole* parameter space; constancy on the
  prior's support alone gives the wrong last step.
]

=== Essentially complete class, finite problem <dem:m-clase-completa>
#proof-env(name: [of @thm:m-clase-completa])[
  With parameters, data, and actions finite, randomized rules form a finite
  product of compact simplices, and the risk vector map is linear and
  continuous: its image $C subset RR^d$ is compact and convex. For an
  admissible $r in C$, the open convex set $U={u:u_j<r_j "for all" j}$ is
  disjoint from $C$; separation gives $w != 0$ with $w^T c>=w^T u$ for all
  $c in C,u in U$, necessarily $w_j>=0$ (unboundedness downward), and
  $w^T c>=w^T r$; normalizing produces a prior under which $r$ minimizes
  Bayes risk. For any $r_0$, minimize $sum_j r_j$ over the nonempty compact
  $C inter {r<=r_0}$: the minimizer cannot be dominated and is Bayes by the
  previous argument — essential completeness, with zeros allowed in the
  prior. A better prior average does not imply coordinate dominance; the
  proof uses separation and compactness, not that false implication.
]

== Dynamic programming

=== Bellman expectation identity <dem:m-bellman-exp>
#proof-env(name: [of @thm:m-bellman-pi])[
  With $G_t=R_t+discount G_(t+1)$ and the Markov property,
  $V^policy (s)=EE^policy [R_t+discount G_(t+1)|S_t=s]$ splits by the tower
  property into the expected immediate reward plus
  $discount EE^policy [V^policy (S_(t+1))|S_t=s]$; conditioning on the
  action and using the kernel yields the displayed equation. Conditions:
  finite or countable state space, finite actions, $discount<1$, bounded
  rewards (the geometric tail bounds the exchange of sum and expectation),
  valid kernels.
]

=== Contraction and fixed points <dem:m-contraccion>
#proof-env(name: [of @thm:m-contraccion])[
  For a fixed $s$, let $a^*$ attain $(T^*V)(s)$; then
  $(T^*V)(s)-(T^*W)(s)<=discount sum_(s') P(s'|s,a^*)(V(s')-W(s'))
  <=discount norm(V-W)_infinity$; repeating with the roles exchanged bounds
  the absolute difference. Averaging over actions preserves the bound for
  $T^policy$. Conditions as stated; completeness of bounded functions in
  sup norm is the completeness of uniform convergence — Banach's theorem
  applies and gives the two unique fixed points of @cor:m-punto-fijo.
]

=== Existence and uniqueness of the optimal value <dem:m-existencia>
#proof-env(name: [of @thm:m-bellman-opt])[
  The fixed point $V^*$ exists and is unique (previous proof). For any
  stationary $policy$, $T^policy V^*<=T^*V^*=V^*$; monotonicity and iteration
  give $V^policy<=V^*$. For policies that may depend on history, the Bellman
  inequality holds conditionally before each action; iterating it through
  $h$ decisions yields
  $EE_policy [sum_(t<h)discount^t R_t+discount^h V^*(S_h)|S_0=s]<=V^*(s)$, and
  the last term vanishes as $h$ grows ($V^*$ bounded, $discount<1$). A greedy
  stationary policy at $V^*$ attains equality because its operator has the
  same fixed point; ties may multiply optima, not the value.
]

=== Policy improvement <dem:m-mejora>
#proof-env(name: [of @thm:m-mejora])[
  Let $d=T^(policy')V^policy -V^policy>=0$ for $policy'$ greedy at $V^policy$;
  then $V^(policy')-V^policy=(I-discount P^(policy'))^(-1)d
  =sum_(j>=0) discount^j (P^(policy'))^j d>=0$; with the tie-keeping rule a
  changed action makes $d(s)>0$ somewhere, and iteration visits no policy
  twice among finitely many; at a fixed point $T^*V^policy=V^policy$, so the
  policy is optimal by @thm:m-bellman-opt.
]

=== Residual certificates <dem:m-parada>
#proof-env(name: [of @cor:m-parada])[
  Write $delta=norm(V-V^*)_infinity$, $d=norm(V^(policy_V)-V^*)_infinity$,
  with $policy_V$ greedy at $V$ so $T^(policy_V)V=T^*V$. Fixed points and
  contraction give
  $d<=discount delta+discount norm(V-V^(policy_V))_infinity
    <=discount delta+discount(delta+d)$, hence $(1-discount)d<=2 discount delta$;
  and with $e=norm(T^*V-V)_infinity$, $delta<=e+discount delta$, so
  $delta<=e slash(1-discount)$ and
  $d<=2 discount e slash(1-discount)^2$. Requires $discount<1$; the policy
  bound is zero when $discount=0$.
]

== The representation and its frontier

=== Representation, in detail <dem:m-repr>
#proof-env(name: [of @thm:m-repr])[
  As in the body: the maps are mutual inverses on the decision states, and
  $J_theta (policy_decrule)=sum_x P_theta (x)r_theta (x,decrule(x))
  =-sum_x P_theta (x)L(theta,decrule(x))=-R(theta,decrule)$, with absolute
  convergence from boundedness and no future rewards by the terminal
  transition. No statement is made — or needed — about sequential problems
  in general.
]

=== Criteria transfer <dem:m-transfer>
#proof-env(name: [of @cor:m-bayes, @cor:m-minimax, and @thm:m-admis])[
  Integrating the identity with a prior gives $J_nu (policy_decrule)=-rho_nu (decrule)$;
  negating reverses extrema and their sets. For minimax,
  $sup_policy inf_theta J_theta (policy)=sup_policy (-sup_theta R(theta,decrule_policy))
  =-inf_decrule sup_theta R(theta,decrule)$ by the bijection. Dominance
  compares weak/strict inequalities over $theta$; negating turns risk-dominance
  exactly into return-dominance. Classes are enlarged consistently on both
  sides when randomization is allowed.
]

=== The structural frontier, in detail <dem:m-frontier>
#proof-env(name: [of @thm:m-frontier — boundary discussion])[
  The body's proof is exact as stated. Boundary remarks.
  (i) The hypothesis needs the witness history reachable: differing
  transition laws only on null histories can be tolerated by versions (the
  experiment can collapse null events), which is why reachability is assumed.
  (ii) The negative claim is about a *single* family $(tilde(P)_theta)$ with
  strategy-class preservation: folding is always possible after enlarging the
  index set to include the strategy itself — the trivial, uninteresting
  representation that returns the original MDP family.
  (iii) The two admissible folds of @prop:m-foldings are exactly where the
  obstruction vanishes: no future observation exists (horizon one), or its
  law does not depend on the action (uncontrolled stopping, handled at
  information states).
]

=== Information states versus sufficiency <dem:m-suficiencia-markov>
#proof-env(name: [of @note:m-markov-no-suf])[
  For $X_1,X_2$ i.i.d. Bernoulli($theta$), $0<theta<1$, the sequence is
  Markov, yet $P_theta (X_1=1|X_2)=theta$ depends on $theta$: $X_2$ is not
  sufficient. The control-relevant condition for a summary $Z_t=f_t (H_t)$
  is that the law of $(R_t,Z_(t+1))$ given $(H_t,A_t)$ depend only on
  $(Z_t,A_t)$ for every admissible action, plus a measurable update and a
  compatible criterion; this is what $(k,b)$ satisfies in
  @thm:m-secuencial, by the predictive-law and update computations in its
  proof clause (i).
]

== Off-policy estimation

=== IS unbiasedness and PDIS <dem:m-is-insesgado>
#proof-env(name: [of @thm:m-identificacion and @thm:m-is-insesgado])[
  Factorize the episode measure into initial law, policies, and environment
  kernels; in the density ratio the environment factors cancel, leaving
  $W_(H-1)$, and analogously $W_t$ on the history ending after reward $t$.
  Then $EE_b [W_t R_t]=EE_pi [R_t]$ and $EE_b [W_(H-1)G]=EE_pi [G]=J(pi)$
  under integrability; the sample mean has the same expectation; second
  moments, when finite, give the variance formula. True propensities are
  used; substitutions are another theorem. A causal reading further needs
  identification of the intervention mechanism (A1–A3 needs of @def:m-ope).
]

=== The curse example <dem:m-curse>
#proof-env(name: [of @thm:m-curse])[
  $EE_b (W)=1$, $0<=W<=C^H$, so
  $Var(hat(J)_"IS")<=B_H^2 C^H slash n$ — upper bound only: with all rewards
  zero the variance is zero, so no positive lower bound exists uniformly.
  For the growth example: one-step ratio second moment
  $c=p^2 slash b+(1-p)^2 slash(1-b)=1+(p-b)^2 slash(b(1-b))>1$; i.i.d.
  actions give $EE_b (W^2)=c^H$ exactly, and
  $Var=(c^H-1) slash n$ with constant terminal return.
]

=== Double robustness, one decision and sequential <dem:m-dr>
#proof-env(name: [of @thm:m-dr])[
  One decision, candidates fixed with positive denominators on the target
  support: condition on $S$ and average the action under $b$ to get
  $ EE[D|S]=sum_a [e(a|S) overline(m)(S,a)
    + (e(a|S) slash overline(b)(a|S)) b(a|S)(m(S,a)-overline(m)(S,a))]; $
  subtracting $sum_a e(a|S)m(S,a)$ groups the errors into
  $sum_a e(a|S)((overline(b)-b) slash overline(b))(overline(m)-m)$, the
  displayed product form; it vanishes if $overline(b)=b$ or $overline(m)=m$.
  Sequentially, with all $q_t$ correct each residual has conditional mean
  zero for any integrable candidate weight; with all weights correct, the
  change of measure telescopes the sum of values to $J$ (with
  $overline(v)_H=0$), the same cancellation written for the finite-horizon
  estimator of @def:m-dr. Learned models need external training and their
  own rates; one correct single time does not suffice for the episode.
]

=== Efficient expansion, one decision <dem:m-dr-eficiencia>
#proof-env(full: [Sketch under the theorem's sufficient conditions])[
  With $D_0=J+phi_"eff"$ and fold means $P_k$, write
  $ hat(J)-J=(P_n-P)D_0 + sum_k (n_k slash n)((P_k-P)(hat(D)_k-D_0)+P(hat(D)_k-D_0)). $
  Conditional on a fold's training, the centered empirical term has
  variance at most $norm(hat(D)_k-D_0)_2^2 slash n_k$; boundedness,
  positivity, and consistency make that norm $o_P (1)$, and a fixed number
  of folds with Chebyshev gives an $o_P (n^(-1 slash 2))$ term without
  cross-fold independence. The bias identity of @dem:m-dr and Cauchy–Schwarz
  control the last term by the product of errors, also $o_P (n^(-1 slash 2))$
  by hypothesis. The i.i.d. CLT on $phi_"eff"$ and the consistent empirical
  variance complete the expansion. This is the argument's scheme with its
  conditions named; the full technical verification is textbook semiparametrics.
]

== Learned policies

=== Policy gradient identity <dem:m-pg>
#proof-env(name: [of @thm:m-pg])[
  The trajectory log-density under $theta$ has derivative $sum_t z_t$ (only
  action probabilities depend on $theta$, by @def:m-pg's kernel
  independence). Multiplying by the total return and exchanging derivative
  and expectation gives $nabla_theta J=EE_theta [(sum_t z_t)G_0]$; each
  score multiplies only rewards from its time onward, because
  $EE_theta [z_t (sum_(s<t)discount^s R_s)|cal(H)_t]$ has conditional mean
  $EE_theta [z_t|cal(H)_t]=0$ times a constant — zero. Weighting by
  $discount^t$ and conditioning on $(S_t,A_t)$ replaces $G_t$ by $q_t$,
  via the tower property inside the expectation. A learned critic
  $hat(q)_t$ injects error $EE_theta [sum_t discount^t z_t(hat(q)_t-q_t)]$,
  nonzero in general (@def:m-pg in @ch:m-learned).
]

== Textual actions

=== Discretization bound <dem:m-sesgo-disc>
#proof-env(full: [Sketch of @prop:m-sesgo-disc])[
  One decision: $abs(J(policy)-J(policy_g))=abs(integral sum_a [policy(a|s)m(s,a)
  -policy_g (a|s)m(s,g(a))] nu(dif s))<=epsilon.alt$ by the uniform
  condition and the image-policy construction. With
  $sup_(s,a) abs(Q^policy (s,a)-Q^policy (s,g(a)))<=epsilon.alt$, the
  performance-difference lemma telescopes the discounted gap into
  per-time conditions, each at most $epsilon.alt discount^t$, summing to
  $epsilon.alt slash(1-discount)$. Neither hypothesis follows from
  embedding similarity of texts.
]

=== Non-identification construction <dem:m-noident>
#proof-env(name: [of @prop:m-noident])[
  With records $(S,A,R)$ only and $e$ unconstrained on never-logged texts,
  let $e_1,e_2$ assign different probabilities to a text $a^*$ never in
  support of the behavior record but of positive record-context
  probability. The observable law is untouched; the values differ by
  $(e_1 (a^*|s)-e_2 (a^*|s))m(s,a^*) != 0$ whenever $m(s,a^*) != 0$,
  which is compatible with every logged record. Hence no point
  identification without carrying the action probability or a class
  restriction. Bounds from rarity models are the identified object that
  remains.
]
