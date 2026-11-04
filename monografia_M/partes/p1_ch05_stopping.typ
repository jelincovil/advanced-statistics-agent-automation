#import "../plantilla_M.typ": *

= Bayesian stopping and information states
<ch:m-stopping>

The representation of Chapter 4 is one decision. Its first honest sequential
extension is a Bayesian problem of observing and stopping: the parameter is
fixed and unknown, observations arrive under a known, policy-independent
channel, and the only control is whether to pay to see one more observation
or to decide now. Within its hypotheses — finite spaces, explicit prior,
finite horizon — the problem admits exact dynamic programming on the
posterior, and the posterior with the remaining horizon is provably an
*information state*: everything the history can contribute to an optimal
continuation.

== The model

A fixed unknown $theta in ParamSpace$ (finite), a prior $b_0$, observations
in a finite $cal(Y)$, conditionally independent given $theta$ with known
$q_theta (y)$. At each instant: decide a terminal action, or pay $c >= 0$ to
observe once more; at most $T$ observations; at the horizon one must decide.

With current posterior $b$, the predictive law and Bayes update are
$ m_b (y) = sum_(theta) b(theta)q_theta (y), quad
  B(b,y)(theta) = (b(theta)q_theta (y)) / m_b (y), $
used when $m_b (y)>0$ (arbitrary versions otherwise, with no effect on
expectations). The expected loss of deciding $a$ is
$ell(b,a)=sum_theta b(theta)L(theta,a)$.

#thm-env("theorem", name: [Bayesian observe-and-stop dynamic program], key: "thm:m-secuencial")[
  In the finite model above there is a Bayes-optimal strategy that depends
  on the history only through the number $k$ of observations remaining and
  the posterior $b$. Its minimal remaining risk satisfies
  $ W_0 (b) = min_(a in ActionSpace) ell(b,a), $
  and for $k >= 1$,
  $ W_k (b) = min {min_(a in ActionSpace) ell(b,a),,
    c + sum_(y in cal(Y)) m_b (y) W_(k-1)(B(b,y))}. $
  The strategy chooses an alternative attaining the minimum; ties may be
  broken by any fixed rule.
]
#proof-env(full: [Proof, complete (deployed form promised by the course book)])[
  Write any strategy with $k$ observations left as: current choice, then
  continuation strategies for each possible $y$. Two claims make the
  induction work in both directions.

  *(i) The value depends on history only through $(k,b)$.* Given the
  history, the law of the next observation is $m_b (y)$, a function of $b$
  alone, and the posterior after $y$ is $B(b,y)$. The immediate costs are
  $c$ or $ell(b,a)$, also functions of $b$. Hence the continuation problem
  after any history inducing $b$ is the same problem with parameters
  $(k-1,B(b,y))$; its optimal value is $W_(k-1)(B(b,y))$ once that value
  is defined independently of the history, which is precisely the induction
  hypothesis at $k-1$.

  *(ii) The recursion gives the optimal value and an attaining strategy.*
  For $k=0$ the only choice is to decide; the best terminal loss is
  $min_a ell(b,a)$. Suppose the claim for $k-1$ and consider $k$: any
  strategy either decides now — best value $min_a ell(b,a)$ — or observes,
  paying $c$ and then facing $(k-1,B(b,y))$ with probability $m_b (y)$.
  By (i) and the induction hypothesis, the best observation-continuation
  has value $c+sum_y m_b (y)W_(k-1)(B(b,y))$, attained by following the
  $(k-1)$-optimal strategy after each $y$. The better of the two
  alternatives is optimal, and choosing it realizes the minimum. Finiteness
  of $ParamSpace,cal(Y),ActionSpace$ makes every minimum attained and every
  selection measurable; versions at $m_b (y)=0$ are immaterial since the
  corresponding terms vanish in every expectation. This closes the deferred
  proof of the course book; see also @dem:m-suficiencia-markov for the role
  of the information-state condition.
]

#thm-env("corollary", name: [Bellman form for Bayesian return], key: "cor:m-bellman-bayes")[
  With $U_k (b)=-W_k (b)$,
  $ U_0 (b)=max_a [-ell(b,a)], quad
    U_k (b)=max {max_a [-ell(b,a)],, -c+sum_y m_b (y)U_(k-1)(B(b,y))}: $
  reward $-c$ for observing, terminal expected reward $-ell(b,a)$. The
  hidden parameter stays fixed; updating acts on beliefs over it. This is a
  statement of Bayesian optimality on information states; nothing here
  claims uniform frequentist optimality over $theta$.
]

#thm-env("note", name: [Markovianity is not sufficiency], key: "note:m-markov-no-suf")[
  Let $X_1,X_2$ be i.i.d. Bernoulli($theta$). The sequence is Markov, but
  the current state $X_2$ is not sufficient for $theta$ in the sample
  $(X_1,X_2)$: $Prob_theta (X_1=1|X_2)=theta$ depends on $theta$. The
  condition that matters for control is that, for a summary $Z_t$ of the
  history, the law of $(R_t,Z_(t+1))$ given $(H_t,A_t)$ factor through
  $(Z_t,A_t)$; ordinary sufficiency for a static parameter does not give
  that. In @thm:m-secuencial, $(k,b)$ satisfies it because the predictive
  law and update are computable from $(k,b)$ alone (@dem:m-suficiencia-markov).
]

#thm-env("example", name: [SSCH: whether to observe at all], key: "ex:m-ssch-observar", es-sintetico: true)[
  Continuing @ex:m-ssch-cap02: deciding immediately with prior $nu(1)=0.3$
  has minimal risk $min{1.2,,0.7}=0.7$. One signal may be acquired at cost
  $c=0.05$, then one decides. The posteriors are $12 slash 19$ after
  $X=1$ and $3 slash 31$ after $X=0$, with marginals
  $Prob(X=1)=0.38$. The minimum posterior losses are $7 slash 19$ and
  $12 slash 31$, and
  $ Prob(X=1) dot 7/19 + Prob(X=0) dot 12/31 = 0.14+0.24 = 0.38, $
  so observing costs $0.05+0.38=0.43<0.7$: observe. The gain comes from
  information that can change the action — an application of the recursion
  with one observation available, not an optimality claim for longitudinal
  clinical care (`verificacion/m_ch5_stopping.py`).
]

#thm-env("note", name: [Where this stops], key: "note:m-stop-frontera")[
  Controlled observations ($q$ depending on actions) or latent states that
  evolve make the channel policy-dependent and fall outside
  @thm:m-secuencial and outside folding, by @thm:m-frontier: then one must
  specify the control kernel and the Bayesian filter explicitly, or accept
  a problem of another class.
]

== Readings

Sequential analysis and Bayesian sequential decision:
#cite(<degroot1970optimal>, form: "prose");
#cite(<ferguson1967mathematical>, form: "prose"); information states in
stochastic control as in the notes of Tedrake
(#link("https://underactuated.mit.edu/belief.html")[belief state and
planning under uncertainty]).
