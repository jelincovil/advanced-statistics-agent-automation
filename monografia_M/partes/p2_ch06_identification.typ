#import "../plantilla_M.typ": *

= Identification and observable contradictions
<ch:m-identification>

An identity between risk and return transfers a comparison criterion; it
produces no new data and justifies no confidence interval by itself. The
estimation part of the book starts by separating four questions that are
independently answerable and often silently collapsed:

+ *Is the objective preserved?* (representation — Part I)
+ *Do the data identify it?* (this chapter)
+ *Does the estimator converge with the announced distribution?* (Ch. 7–8)
+ *Is the selected decision still guaranteed?* (Ch. 9–10)

A positive answer to one answers none of the next.

== What a guarantee is, made formal

#thm-env("definition", name: [Transferable guarantee], key: "def:m-transferible")[
  A guarantee is transported through a representation when the experiment,
  the target, the procedure, and their correspondences are specified, and
  the probabilistic or risk statement is proved to be preserved. Changing
  the experiment — from independent samples to an adaptive trajectory —
  requires a result covering the new data regime.
]

== Four computed contradictions

Each example isolates one object that ceases to be justified. All numbers
are exact and machine-checked (`verificacion/m_ch6_contraejemplos.py`).

#thm-env("example", name: [Unobserved confounding: same law, different intervention], key: "ex:m-confounding")[
  Let $U tilde "Bernoulli"(1 slash 2)$ and the recorded action be $A=U$.
  Two potential-outcomes models agree exactly on the observed law:
  in M1, $Y(0)=Y(1)=U$; in M2, $Y(a)=a$. Both give
  $Prob(A=Y=0)=Prob(A=Y=1)=1 slash 2$. Yet intervening to set $A=1$ yields
  $ EE[Y(1)] = cases(1 slash 2 & "in M1", 1 & "in M2"). $
  No estimator based on those records distinguishes the two models; adding
  columns independent of $(U,A,Y)$ changes nothing. DM, IS, and DR do not
  remove this ambiguity by name; randomization, pertinent measurement, or
  justified structural restrictions change the problem itself.
]

#thm-env("example", name: [Failure of mixing: one sample is not a sample], key: "ex:m-mixing-fallo")[
  Draw $Z tilde "Bernoulli"(1 slash 2)$ once and set $X_t=Z$ forever. The
  process is stationary, its mean over time never converges to $1 slash 2$,
  and the events ${X_0=1}$, ${X_k=1}$ keep dependence $1 slash 4$ at every
  lag. If $1 slash 2$ is replaced by an unknown proportion $p$, the observed
  law identifies $p$ through $Prob(X_0=1)=p$, but lengthening one trajectory
  repeats the same Bernoulli estimate. Many independent restarts do identify
  it: the sampling unit changed, not the theorem.
]

#thm-env("example", name: [Insufficient overlap: identification, not variance], key: "ex:m-overlap-fallo")[
  A register shows only action $0$ with reward zero; the target policy takes
  action $1$ with probability $0.9$. Two models assigning reward $0$ and $1$
  to the unseen action produce identical registers but target values $0$ and
  $0.9$: with $0<=R<=1$, the identification interval is $[0,0.9]$, and no
  point estimator is identified by the data. DM extrapolates; that is not an
  identification earned by the data. Distinct from this is *weak* overlap:
  $pi_b (1)=epsilon.alt>0$, $pi_e (1)=0.9$, $R=A$. One IS contribution is
  $0.9 slash epsilon.alt$ with probability $epsilon.alt$, zero otherwise:
  $ EE[W]=0.9, quad Var(W)=0.81(1 slash epsilon.alt-1), $
  which at $epsilon.alt=0.01$ equals $80.19$ — finite, not small.
]

#thm-env("example", name: [Nonstationarity refocuses the target], key: "ex:m-noest")[
  $n slash 2$ independent Bernoulli outcomes of mean $0.2$, then $n slash 2$
  of mean $0.8$. The pooled mean estimates $0.5$ — the average of regimes —
  with variance $0.16 slash n$, and it admits a CLT for that average.
  Nonstationarity does not kill inference; it forces a declaration of which
  population and period are being evaluated.
]

== The L1–L6 failure map

#mi-tabla(
  caption: [The map of six failure mechanisms; each row names the first object to audit.],
  key: "tab:m-l1l6",
  table(columns: (12%, 26%, 1fr), align: left, hl(),
    table.header([*Mode*], [*Object*], [*Operational question*]), hl(w: 0.6pt),
    [L1], [State memory], [Do histories collapsed into the same summary require different decisions?],
    [L2], [Observed information], [What is inferred, under which model, from which history?],
    [L3], [Dynamics and sampling], [One episode, one trajectory, or a changing regime?],
    [L4], [Intervention], [Does the observed law determine the outcome of changing the policy?],
    [L5], [Support], [Is there information in the regions the target policy visits?],
    [L6], [Estimator], [Do remainder and variance permit the announced distribution?],
    hl(),
  ),
)

#thm-env("example", name: [L1: two histories, one summary], key: "ex:m-l1")[
  At the final decision of an episode, $S_1=0$ always, but the reward is
  $R_1=1$ if $A_1=A_0$ and zero otherwise, with $A_0$ chosen uniformly.
  A rule remembering the previous action scores $1$; any rule using only
  $S_1$ plus independent randomization scores $1 slash 2$. The summary
  erased decisive information; enlarging the state to $(S_1,A_0)$ restores a
  Bellman equation for the enlarged problem.
]

#thm-env("note", name: [Auxiliary-function error rates are joint], key: "note:m-l6")[
  For an orthogonal expansion with remainder bounded by $C a_n b_n$ (errors
  $L^2$ of two auxiliaries), the condition is $a_n b_n=o_P (n^(-1 slash 2))$,
  together with the other hypotheses of the expansion — not a universal law.
  With $a_n=O_P (n^(-0.30))$, $b_n=O_P (n^(-0.25))$ the product is
  $o_P (n^(-1 slash 2))$; two rates of $n^(-0.20)$ each give $O_P (n^(-0.40))$,
  which does not certify root-n inference. Cross-fitting controls empirical
  terms; it establishes no learning rates by itself.
]

== When do Bayes, minimax, and admissibility coincide?

In a known model with fixed initial distribution $nu$, all policies are
compared by one scalar $J_nu (policy)$: if the maximum is attained, the
attaining policies are exactly the admissible ones for loss $-J_nu$ over a
single "parameter", and Bayes and minimax coincide on that scalar. Indexing
risk by initial states instead, $R(s,policy)=-V^policy (s)$, makes the
comparison vectorial; a uniformly optimal stationary policy exists in the
finite discounted MDP and dominates everything else, so admissibility and
uniform optimality coincide — *but* minimax may admit additional policies:

#thm-env("example", name: [A minimax policy can be dominated], key: "ex:m-minimax-dominada")[
  One decision, two initial states, feasible value vectors $V^a=(1,0)$ and
  $V^b=(0,0)$. The first dominates the second, yet
  $min_s V^a (s)=min_s V^b (s)=0$: both are maximin. Under a prior with
  positive mass on the first state only $a$ is Bayes; under a prior
  concentrated on the second, both are. Existence of a uniformly optimal
  policy does not equate the three solution sets.
]

With an unknown model family, the prior and the worst case matter again:
observing the state does not reveal the model (`verificacion/m_ch6_tricotomia.py`).

== The justification file

#thm-env("note", name: [Protocol before invoking a guarantee], key: "prop:m-protocolo")[
  Record the target (with horizon, discount, initial population, period),
  the policy (fixed, learned, or selected during evaluation), the
  independent unit, the model and which of its parts are designed versus
  estimated; separate identification assumptions from estimator conditions;
  cite the applicable result; document which conditions are known by design
  and which have only diagnostic support. If an essential condition remains
  unjustified, report a descriptive estimate, an identification region, or a
  sensitivity analysis — without attaching the guarantee that was not
  established. Chapter 10 turns this file into algebra.
]
