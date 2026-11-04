#import "../plantilla_M.typ": *

= Tools, referenced by use
<app:tools>

Reference only: each entry names the result, its conditions, and where the
body invokes it. Statements not proved in Appendix A are attributed.

== Exponential families

#thm-env("note", name: [Log-partition properties], key: "note:m-logpart")[
  For $f(x|eta)=h(x)exp{eta^top T(x)-A(eta)}$ with open natural space:
  $A$ is convex (Hölder); $nabla A=EE_eta [T(X)]$ and
  $nabla^2 A=Cov_eta (T(X))$ by differentiating under the integral
  (regularity); the Hessian is positive definite in minimal families;
  completeness of $T$ holds when the parameter space contains an open set
  (proof in the course book's appendix; invoked here in Chapter 1).
]

== Asymptotics

#thm-env("note", name: [Lindeberg–Lévy CLT], key: "note:m-clt")[
  i.i.d. with mean $mu$ and $0<sigma^2<infinity$:
  $(S_n-n mu) slash(sigma sqrt(n)) arrow.r^d N(0,1)$ (characteristic
  functions; conditions are only those). Delta method: $g$ differentiable
  with nonvanishing gradient at $mu$ transports the limit with variance
  $nabla g^T Sigma nabla g$; the vanishing-gradient point is exactly where
  @ex:m-r-falla1 stops the naive use. Bootstrap for the mean: with
  $0<sigma^2<infinity$, the triangular-array conditional CLT under the
  Lindeberg condition justifies percentile bootstrap CIs of the mean;
  studentization requires $sigma^2>0$ (conditions in the course book, where
  they are proved).
]

#thm-env("note", name: [Mixing CLT and one spectral bound], key: "note:m-mixing-clt")[
  Strictly stationary, mean zero, $EE abs(X_0)^(2+delta)<infinity$ for some
  $delta>0$, and $sum_k alpha(k)^(delta slash(2+delta))<infinity$ (strong
  mixing on past/future $sigma$-algebras) imply
  $sqrt(T)(macron(X)_T) arrow.r^d N(0,sigma_(L R)^2)$ with
  $sigma_(L R)^2=Var(X_0)+2 sum_(k>=1)Cov(X_0,X_k)$, absolutely summable
  — the form due to the dependent-process literature, quoted from the
  standard lecture treatment. A finite irreducible aperiodic chain is
  geometrically mixing; in general state spaces drift/minorization
  conditions replace that step. Reversible finite chains satisfy
  $norm(P^k (s,dot)-mu)_"TV"<=1 slash 2 sqrt(1 slash mu(s)-1) thin r^k$ with
  $r=max_(j>=2) abs(lambda_j)$ — the modulus matters
  ($mat(0.01,0.99;0.99,0.01)$ has $lambda_2=-0.98$).
]

#thm-env("note", name: [HAC variance estimation], key: "note:m-hac")[
  Bartlett-weighted $hat(sigma)_(L R)^2=hat(c)_0+2 sum_(k=1)^K (1-k slash(K+1))hat(c)_k$;
  sufficient consistency route: $sum_k abs(c_k)<infinity$, $K -> infinity$,
  $K slash T -> 0$, and $sum_(k<=K) abs(hat(c)_k-c_k) arrow.r^P 0$ (the last
  condition must be proved, not assumed from the CLT). Reference:
  #cite(<newey1987hac>, form: "prose"); mixing distinctions:
  #cite(<bradley2005basic>, form: "prose"); bootstrap foundations:
  #cite(<hall1992bootstrap>, form: "prose").
]

== Testing and multiplicity

#thm-env("note", name: [Neyman–Pearson, inversion, BH], key: "note:m-np-bh")[
  With densities $p_0,p_1$, atoms handled by randomization, the
  likelihood-ratio test is most powerful at its level, including points
  where $p_0=0$; test-inversion yields confidence sets with the dual
  coverage. Benjamini–Hochberg controls FDR at $m_0 alpha slash m$ with
  equality under uniform nulls, under independence of null p-values from the
  rest (proofs in the course book); the PRDS extension is
  #cite(<benjamini2001dependency>, form: "prose"), not the 1995 argument.
]

== Bandits

#thm-env("note", name: [UCB1 and Lai–Robbins], key: "note:m-bandits")[
  @thm:m-ucb1 quotes the gap-dependent UCB1 bound of
  #cite(<auer2002finite>, form: "prose") under rewards in $[0,1]$. For
  Bernoulli bandits with means in $(0,1)$ and a unique best arm, any
  uniformly efficient policy satisfies
  $ liminf_(T -> infinity) cal(R)_T slash log T >=
    sum_(a:Delta_a>0) Delta_a slash "kl"(mu_a,mu^*), $
  #cite(<lai1985asymptotically>, form: "prose"); the general family replaces
  kl by an infimum over alternative distributions
  (#cite(<lattimore2020bandit>, form: "prose"), where the change-of-measure
  proofs live). UCB1 does not attain the constant in general.
]

== Semiparametric OPE

#thm-env("note", name: [Kallus–Uehara and SZLS, reading-level], key: "note:m-kallus")[
  In the finite-horizon i.i.d.-episode model with free per-time kernels and
  unknown initial law, the efficient influence function of $J(e)$ is the
  augmentation with marginal occupancy ratios $w_t=d_t^e slash d_t^b$; double
  robustness and its conditions are in
  #cite(<kallus2020double>, form: "prose"). The temporally homogeneous
  infinite-horizon model has another experiment and another bound:
  #cite(<kallus2022efficiently>, form: "prose") — conditions not
  interchangeable. For sieve-based value inference at $gamma<1$ and the
  studentized limit for a fixed policy: Theorem 1 of
  #cite(<shi2022statistical>, form: "prose") with its supplement; the
  sketch in the course book deliberately delegates all its hypotheses.
]
