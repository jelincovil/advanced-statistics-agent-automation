#import "../plantilla_M.typ": *

= Markov decision processes
<ch:m-mdp>

Chapter 2 separated data, rules, and consequences. When an action modifies
future opportunities, comparing only immediate losses is insufficient. A
Markov decision process describes those consequences and computes policies
that account for them. The statistical problem returns when rewards or
transitions must be learned from data — Chapters 6–9.

This chapter develops planning guarantees in finite, discounted, known
MDPs, and keeps them distinct from the guarantees needed to learn the model.

== The model and its values

#thm-env("definition", name: [MDP], key: "def:m-mdp")[
  $cal(M)=(StateSpace,ActionSpace,P,r,discount)$ with finite nonempty
  states and actions, $P(s'|s,a)>=0$, $sum_(s') P(s'|s,a)=1$,
  $abs(r(s,a))<=R_"max"<infinity$, $0<=discount<1$. An initial distribution
  $rho$ defines the aggregate value $J_rho^policy =sum_s rho(s)V^policy (s)$.
  Random rewards with conditional mean $r(s,a)$ are allowed; integrability
  and the corresponding bound suffice for the value formulas.
]

#thm-env("definition", name: [Policies and Markov property], key: "def:m-politica")[
  A stationary randomized policy assigns $policy(a|s)$; deterministic
  assigns $policy(s)$. In the general class a policy may depend on time and
  on the whole observed history. Policies use only information available at
  the time of acting. The Markov property is
  $ Prob(S_(t+1)=s'|S_0,A_0,dots.h,S_t,A_t)=P(s'|S_t,A_t), $ plus a reward
  conditional mean determined by $(S_t,A_t)$ — both tied to the state
  actually chosen for the model.
]

#thm-env("definition", name: [Value functions], key: "def:m-valor")[
  For a stationary policy,
  $ V^policy (s)=EE_s^policy [sum_(t=0)^infinity discount^t r(S_t,A_t)], quad
    Q^policy (s,a)=r(s,a)+discount sum_(s')P(s'|s,a)V^policy (s'), $
  the latter also well-defined when $policy(a|s)=0$ (no conditioning on an
  impossible event). Elementary bound: $abs(V^policy (s))<=R_"max" slash(1-discount)$.
]

== Bellman equations, contraction, and computation

#thm-env("theorem", name: [Bellman expectation equation], key: "thm:m-bellman-pi")[
  $ V^policy (s)=sum_a policy(a|s)[r(s,a)+discount sum_(s')P(s'|s,a)V^policy (s')]. $]
#proof-env[Split the return, condition on first action and next state, use
  stationarity; the geometric bound justifies exchanging expectation and
  series. Full details: @dem:m-bellman-exp.]

#thm-env("definition", name: [Bellman operators], key: "def:m-operadores")[
  For $V in RR^abs(StateSpace)$,
  $ (T^policy V)(s)=sum_a policy(a|s)[r(s,a)+discount sum_(s')P(s'|s,a)V(s')], $
  $ (T^*V)(s)=max_a[r(s,a)+discount sum_(s')P(s'|s,a)V(s')]. $]

#thm-env("theorem", name: [Sup-norm contraction], key: "thm:m-contraccion")[
  For $T=T^policy$ or $T=T^*$,
  $ norm(T V-T W)_infinity<=discount norm(V-W)_infinity . $]
#proof-env[The difference of two maxima is bounded by the maximum absolute
  difference; each averaging is bounded by $norm(V-W)_infinity$;
  @dem:m-contraccion.]

#thm-env("corollary", name: [Unique fixed points], key: "cor:m-punto-fijo")[
  Banach's theorem on the finite space with the sup norm gives unique fixed
  points: $V^policy$ of $T^policy$ and $V^*$ of $T^*$.
]

#thm-env("theorem", name: [Optimality], key: "thm:m-bellman-opt")[
  In the finite discounted MDP there exists a deterministic stationary
  optimal policy, and $V^*(s)=max_a[r(s,a)+discount sum_(s')P(s'|s,a)V^*(s')]$.
  The optimal value is unique; optimal policies may not be. A greedy policy
  at the fixed point attains the optimum, including against history-dependent
  policies; @dem:m-existencia.
]

#thm-env("theorem", name: [Value iteration], key: "thm:m-vi")[
  $ norm(V_k-V^*)_infinity<=discount^k norm(V_0-V^*)_infinity$; with
  $V_0=0$, $discount^k R_"max" slash(1-discount)$.
]

#thm-env("corollary", name: [Stopping certificates], key: "cor:m-parada")[
  Let $e=norm(T^*V-V)_infinity$ and $policy_V$ greedy at $V$. Then
  $ norm(V-V^*)_infinity<=e/(1-discount), quad
    norm(V^*-V^(policy_V))_infinity<= (2 discount e)/(1-discount)^2 . $
  Two distinct precision goals: a value error and a policy loss have
  different residual thresholds. Proofs: @dem:m-parada.
]

#thm-env("theorem", name: [Policy improvement and finite termination], key: "thm:m-mejora")[
  A policy greedy at $V^policy$ satisfies $V^(policy')>=V^policy$; with the
  tie-keeping rule, an actual change is a strict improvement somewhere, so
  policy iteration visits no policy twice and stops at an optimal one. It is
  a monotonicity-and-finiteness argument, not a contraction; @dem:m-mejora.
]

== Bandits: a pointer with two computed lessons

#thm-env("theorem", name: [UCB1 under bounded rewards], key: "thm:m-ucb1")[
  For rewards in $[0,1]$ and horizon $T>=K$, UCB1 with
  $ hat(mu)_a+sqrt((2 log t)/N_a) $ has pseudo-regret
  $ cal(R)_T<=8 sum_(a:Delta_a>0)(log T)/Delta_a +(1+pi^2/3)sum_a Delta_a, $
  #cite(<auer2002finite>, form: "prose"). Gap-dependent bound; the asymptotic
  constant is not claimed optimal (Lai–Robbins-type limits are quoted, with
  their hypotheses, in Appendix B).
]

#thm-env("example", name: [Posterior sampling is not posterior optimality], key: "ex:m-thompson", es-sintetico: true)[
  Two arms with independent posteriors $tilde(mu)_1 tilde "Beta"(4,1)$ and
  $tilde(mu)_2 tilde "Beta"(1,1)$ (means $0.8,0.5$). With one round left,
  the Bayes action picks arm 1 (predictive $0.8$). Thompson sampling picks
  arm 1 with $Prob(tilde(mu)_1>tilde(mu)_2)=EE[tilde(mu)_1]=0.8$ (the second
  arm's prior is uniform) and collects $0.8 dot 0.8+0.2 dot 0.5=0.74$.
  Sampling from the posterior and acting on the sample is not minimizing
  posterior risk; the difference is $0.06$ here
  (`verificacion/m_ch3_thompson.py`).
]

#thm-env("example", name: [SSCH reduced two-state model], key: "ex:m-ssch-mdp", es-sintetico: true)[
  States $g,b$, actions 0,1, $discount=0.9$, deterministic transitions:
  ($g$,0) gives 1 and goes to $b$; ($g$,1) gives $0.5$, stays;
  ($b$,0) gives 0, stays; ($b$,1) gives $-0.5$, goes to $g$.
  $V^*=(5,4)$ with action 1 in both states: at $g$,
  $max{1+0.9 dot 4,, 0.5+0.9 dot 5}=5$; at $b$, $max{0.9 dot 4,,-0.5+0.9 dot 5}=4$.
  Iterates from zero: $(1,0),(1.4,0.4),(1.76,0.76)$. Maximizing immediate
  rewards would choose 0 in both states — the example isolates why future
  consequences can pay a present cost (`verificacion/m_ch3_bellman.py`).
]

#thm-env("note", name: [Known model versus learned model], key: "note:m-modelo")[
  A contraction certifies planning inside the model used; it certifies
  nothing about the environment's true value if the model was estimated.
  Estimating transition tables is a finite-dimensional problem in a fixed
  finite space — "tabular" does not mean nonparametric — and in continuous
  state spaces it is a nonparametric one. A scalar objective
  $J_rho^policy$ inside an infinite-dimensional family is the semiparametric
  problem of Part II.
]
