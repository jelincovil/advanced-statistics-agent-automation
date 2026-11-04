#import "../plantilla_M.typ": *

= Estimating policy value: DM, IS, DR
<ch:m-estimadores>

Off-policy evaluation (OPE) asks what a rule is worth using records produced
by a different rule. This chapter fixes the experiment — independent
episodes of a finite horizon — and develops the three estimation routes
with their variance analysis. The sampling regime of a single long
trajectory belongs to Chapter 8's references and to the diagnostics of
Chapter 6.

== The experiment and the assumption set

#thm-env("definition", name: [OPE experiment and target], key: "def:m-ope")[
  $n$ i.i.d. episodes
  $ O_i=(S_(i,0),A_(i,0),R_(i,0),dots.h,S_(i,H)) $ of fixed horizon $H$,
  finite actions; behavior policy $b_t (a|s)$; fixed target policy $e_t (a|s)$
  (both time-varying allowed). Common initial law $nu$; reward/transition
  kernels $K_t (dif r,dif s'|s,a)$; $abs(R_t)<=R_*$; $0<discount<=1$.
  The target is $ J(e)=EE_e (G)=integral v_0 (s)nu(dif s), quad
    G=sum_(t=0)^(H-1)discount^t R_t , $
  with $q_t (s,a)=EE[R_t+discount v_(t+1)(S_(t+1))|S_t=s,A_t=a]$ and
  $v_t (s)=sum_a e_t (a|s)q_t (s,a)$. Estimating $v_0 (s_0)$ at a fixed
  state is a different problem.
]

#assumption-env(name: [Consistency and well-defined intervention], key: "ass:m-consistency")[
  Observed states and rewards equal their potential outcomes under the
  action sequence actually received; action versions are specified; no
  interference between episodes. The outcome at $t$ may depend on the whole
  past sequence.
]
#assumption-env(name: [Support of the target policy], key: "ass:m-overlap")[
  On histories reachable under $e$, every action of positive target
  probability has positive behavior probability. For quantitative bounds we
  impose the ratio bound $e_t slash b_t <= C < infinity$ on the relevant
  support — strictly stronger than positivity; the largest observed ratio in
  a sample is a diagnostic, not the population coefficient
  $rho_"max"=sup e_t slash b_t$.
]
#assumption-env(name: [Exchangeability and Markov structure], key: "ass:m-markov")[
  Given the pre-action history, the recorded action is independent of future
  potential outcomes (sequential exchangeability); $S_t$ summarizes that
  history for kernels and policies. Observational Markovianity does not
  imply absence of confounding (@ex:m-confounding).
]

#thm-env("theorem", name: [Identification of policy value], key: "thm:m-identificacion")[
  Under the assumptions above, with
  $rho_t=e_t (A_t|S_t) slash b_t (A_t|S_t)$, $W_t=product_(k=0)^t rho_k$,
  $W_(-1)=1$, and returns integrable under the target law,
  $ J(e)=EE_b (W_(H-1)G)=sum_(t=0)^(H-1) discount^t EE_b (W_t R_t). $]
#proof-env[Factorize the episode law into initial distribution, policies,
  and kernels; in the density ratio, $nu$ and the kernels cancel, leaving
  $W_(H-1)$; for the reward at $t$ the history up to that reward suffices,
  $W_t$. @dem:m-is-insesgado.]

== Direct method

#thm-env("definition", name: [DM], key: "def:m-dm")[
  Fit $hat(q)_t$ backward through Bellman regressions; with
  $hat(v)_t (s)=sum_a e_t (a|s)hat(q)_t (s,a)$,
  $ hat(J)_"DM" = 1/n sum_(i=1)^n hat(v)_0 (S_(i,0)) $ over evaluation
  states independent of the fit (cross-fitting permitted episode-wise).
]
#thm-env("proposition", name: [DM bias and variability], key: "prop:m-dm")[
  Conditionally on an independent fit, the bias is
  $EE_nu (hat(v)_0-v_0)$, bounded in magnitude by
  $EE_nu [sum_a e_0 (a|S_0) abs(hat(q)_0 (S_0,a)-q_0 (S_0,a))]$, and the
  conditional variance is $Var_nu (hat(v)_0)/n$; total variability includes
  the fit itself. DM needs no explicit $b$ — but it extrapolates into
  support-free regions only by imposing restrictions the data do not
  contain.
]

== Importance sampling

#thm-env("definition", name: [IS and PDIS], key: "def:m-is")[
  $ hat(J)_"IS"=1/n sum_(i=1)^n W_(i,H-1)G_i, quad
    hat(J)_"PDIS"=1/n sum_(i=1)^n sum_(t=0)^(H-1) discount^t W_(i,t)R_(i,t). $
  Exact statements below use *true* behavior probabilities, known by design;
  substituting estimated ones does not automatically preserve finite-sample
  unbiasedness. The self-normalized variant is a different procedure with
  finite bias.
]
#thm-env("theorem", name: [IS unbiasedness], key: "thm:m-is-insesgado")[
  With true weights and $EE_e abs(G)<infinity$,
  $EE_b (hat(J)_"IS")=J(e)$; if $EE_b (W_(H-1)^2G^2)<infinity$, then
  $Var_b (hat(J)_"IS")=Var_b (W_(H-1)G) slash n$. The second-moment
  condition is not needed for unbiasedness (@dem:m-is-insesgado).
]

#thm-env("theorem", name: [Variance bound and curse of horizon], key: "thm:m-curse")[
  If $abs(G)<=B_H$ and $rho_t<=C$, then
  $ Var_b (hat(J)_"IS") <= B_H^2 C^H slash n , $ an upper bound only. The
  growth it permits is real: in one state, Bernoulli($b$) versus
  Bernoulli($p$) actions and terminal reward one,
  $ Var_b (hat(J)_"IS")=(c^H-1)/n, quad
    c=p^2/b+(1-p)^2/(1-b)=1+(p-b)^2 slash (b(1-b))>1 , $
  by exact multiplication of second moments (`verificacion/m_ch7_curse.py`;
  @dem:m-curse knows why a bound cannot be improved to a lower one).
]

== Doubly robust estimation

#thm-env("definition", name: [DR, one decision and its sequential form], key: "def:m-dr")[
  One decision, $m(s,a)=EE[R|S,A]$:
  $ D_i=hat(v)(S_i)+ frac(e(A_i|S_i),hat(b)(A_i|S_i))(R_i-hat(m)(S_i,A_i)), quad
    hat(v)(s)=sum_a e(a|s)hat(m)(s,a). $
  The direct term averages actions under $e$ — replacing $hat(v)$ by
  $hat(m)(S_i,A_i)$ destroys the identity even with a perfect model. For
  $H$ decisions, with models trained outside episode $i$,
  $ D_i=hat(v)_0 (S_(i,0))+sum_(t=0)^(H-1) discount^t hat(W)_(i,t)
       (R_(i,t)+discount hat(v)_(t+1)(S_(i,t+1))-hat(q)_t (S_(i,t),A_(i,t))). $]

#thm-env("theorem", name: [Double robustness identity], key: "thm:m-dr")[
  For one decision, with fixed candidate functions $overline(m),overline(b)>0$,
  $ EE_b (D)-J(e)=EE_nu [sum_a e(a|S)
    frac(overline(b)(a|S)-b(a|S),overline(b)(a|S))
    (overline(m)(S,a)-m(S,a))]: $
  the bias is a product of both errors and vanishes if either auxiliary is
  right (@dem:m-dr; the sequential cancellation is in the same appendix).
]
#thm-env("proposition", name: [Efficient inference in one decision], key: "thm:m-dr-eficiencia")[
  i.i.d. episodes, finite actions, fixed $e$, uniformly bounded rewards and
  fits, $b,hat(b)>=epsilon.alt>0$, episode-wise cross-fitting with a fixed
  number of folds, both $L^2$ errors to zero with product
  $o_P (n^(-1 slash 2))$, and positive limiting variance. Then
  $ sqrt(n)(hat(J)_"DR"-J)=1/sqrt(n) sum_i phi(O_i)+o_P (1), $
  $ phi(O)=v(S)-J+frac(e(A|S),b(A|S))(R-m(S,A)), $ the canonical gradient in
  the nonparametric one-decision model; its variance is the efficiency bound
  for regular estimators (@dem:m-dr-eficiencia). Efficiency is more than
  double robustness: two $O_P (n^(-1 slash 4))$ errors do not by themselves
  certify the little-o product (@note:m-l6).
]

#thm-env("note", name: [Support states of an evaluation], key: "note:m-niveles")[
  Identification (assumption set), bounded-ratio regime, and finite-second-
  moment regime are successive support states of an OPE claim; each weaker
  state permits proportionally weaker conclusions (regions, then point
  estimates with heavy-tailed variance, then efficient intervals). Declaring
  the state is part of the estimand; truncating weights trades bias for
  variance and must itself be reported — including its threshold and the
  bias it introduced (@ex:m-overlap-fallo for the endpoint case).

  For the time-unconstrained kernel model of finite horizon with unknown
  initial law, the efficient influence function uses marginal occupancy
  ratios $w_t=d_t^e slash d_t^b$ instead of products $W_t$ —
  #cite(<kallus2020double>, form: "prose") with its own conditions
  (Appendix B), independent of the Wald embedding.
]

== Readings

#cite(<jiang2016doubly>, form: "prose") and
#cite(<dudik2011doubly>, form: "prose") for DR in policy evaluation;
#cite(<precup2000eligibility>, form: "prose") for IS via eligibility;
#cite(<thomas2015high>, form: "prose") for high-confidence OPE;
#cite(<liu2018breaking>, form: "prose") for the curse-of-horizon and
breaking it with occupancy ratios;
#cite(<kallus2020double>, form: "prose") and
#cite(<kallus2022efficiently>, form: "prose") for semiparametric
efficiency, each in its own temporal regime.
