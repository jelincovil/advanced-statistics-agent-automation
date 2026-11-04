#import "../plantilla_M.typ": *

= Transfer certificates
<ch:m-certificates>

A guarantee is an object with premises. Chapter 6 produced the vocabulary to
locate failure; this chapter turns it into a small algebra. The claim is
modest and exact: a *certificate* is a tuple with a rule for when it
discharges a guarantee; composition is permitted by three proved rules; and
three computed counterexamples mark the compositions that fail. The output
is a soundness criterion — *what may be reported* — that the rest of the
book then applies to itself, including to the study of Chapter 11.

== The object

#thm-env("definition", name: [Transfer certificate], key: "def:m-certificate")[
  A certificate is a tuple $cal(C)=(K, cal(R), cal(K), sigma)$:
  a claim $K$ about a statistical object, its data regime $cal(R)$
  (experiment and sampling unit), a finite set of conditions $cal(K)$
  (identification, estimator, variance — each with its formal statement), and
  a status map $sigma:cal(K) -> {"design", "proved", "diagnostic", "open"}$.
  A certificate *discharges* $K$ at level $"design"/"proved"$ when every
  condition has status design or proved; a condition at diagnostic or open
  caps the reportable conclusion accordingly (descriptive statement,
  identification region, or sensitivity analysis). Two certificates are
  *compatible* when they are stated for the same regime and their condition
  sets agree on every shared hypothesis.
]

#thm-env("note", name: [Diagnostics are not conditions], key: "note:m-diag")[
  ESS ratios, autocorrelation plots, small Bellman residuals, stable
  numerics: they populate the diagnostic status and nothing else. No
  threshold of any of them discharges overlap, mixing, or identification;
  those are population statements (@note:m-l6, @ex:m-mixing-fallo).
]

== Three composition rules, proved

#thm-env("proposition", name: [R1 — Image transport of sets], key: "thm:m-r1")[
  If $C_n$ covers $theta$ with probability at least $1-alpha$ in regime
  $cal(R)$, then $g(C_n)$ covers $g(theta)$ at the same level. Coverage may
  increase; the image need not be an interval — taking its interval hull
  preserves the inequality when well-defined. Proof: the event
  ${theta in C_n}$ is contained in ${g(theta) in g(C_n)}$. The rule is exact
  and requires no new condition; it never produces a normal interval by
  itself.
]

#thm-env("proposition", name: [R2 — Chained limit with a linking condition], key: "thm:m-r2")[
  A certificate for $sqrt(n)(hat(theta)-theta)arrow.r^d N(0,Sigma)$ and a
  delta-method certificate compose into one for $g(hat(theta))$ *if* $g$ is
  differentiable at $theta$ with nonvanishing gradient on the support of the
  limit (and Slutsky-consistent variance estimation is discharged in the
  same regime), giving variance $nabla g(theta)^T Sigma nabla g(theta)$.
  The link condition is the differentiability with nondegenerate gradient;
  R2 fails at points where it fails (@ex:m-r-falla1). Proofs of the two
  ingredients are in Appendix B; composition is the statement made here
  (`verificacion/m_ch10_certificados.py` recomputes both failure examples).
]

#thm-env("proposition", name: [R3 — Hypothesis transport is exact only with the rejection function], key: "thm:m-r3")[
  Testing $g(theta)=v_0$ means testing the composite set
  ${theta:g(theta)=v_0}$; it coincides with $theta=theta_0$ only if the
  relevant preimage is that point. Level and power are preserved exactly
  when the experiment and the rejection function are preserved under a
  correspondence of hypotheses; changing the data regime (e.g., to dependent
  trajectories) requires a new justification of the statistic's law.
]

== Three computed counterexamples to naive composition

#thm-env("example", name: [Efficiency does not paste through zeros of the gradient], key: "ex:m-r-falla1")[
  $X_i$ i.i.d. $N(theta,1)$; the mean is efficient for $theta$. For
  $g(theta)=theta^2$ with $theta != 0$, $overline(X)^2$ has asymptotic
  variance $4 theta^2 slash n$; at $theta=0$, $n overline(X)^2 tilde chi_1^2$:
  the scale and the limiting law change, and a normal formula patched with a
  zero derivative yields no valid interval. Efficiency is declared for a
  model, a functional, and a regularity notion — R2's link condition is not
  decoration.
]
#thm-env("example", name: [A preimage with two points], key: "ex:m-r-falla2")[
  For $g(theta)=theta^2$, the hypothesis $g(theta)=1$ contains $theta=1$ and
  $theta=-1$; a test built only for $theta=1$ does not control level over
  the composite hypothesis (R3).
]
#thm-env("example", name: [Interval for a selected policy], key: "ex:m-r-falla3")[
  A pointwise $(1-alpha)$ interval for a fixed policy, applied to a policy
  *chosen* because its interval looked best, loses its nominal meaning:
  selection entered the procedure. The valid object is an evaluation on
  independent episodes, a uniform band over the search class, or selective
  inference with its own certificate — three different regimes, three
  different certificates (@note:m-freeze).
]

== The soundness rule

#thm-env("definition", name: [Reportability], key: "def:m-reportable")[
  A guarantee may be reported (with its level) when a discharged certificate
  for it exists, and it must then be reported with regime $cal(R)$ and the
  weakest-link status of its conditions. Otherwise the supported report is
  the degraded one of @def:m-certificate. This is a rule about claims, not
  about effort: a beautiful estimator with an open condition reports less
  than a plain one fully discharged.
]

#block(breakable: false)[
#mi-tabla(
  caption: [Certificates of this book's own guarantees (canonical fragment; status as of this draft — all discharged conditions have their proofs in Appendix A or in the cited sources)],
  key: "tab:m-cert-canon",
  table(columns: (30%, 24%, 24%, 22%), align: left, hl(),
    table.header([*Claim*], [*Regime*], [*Key conditions*], [*Where proved*]), hl(w: 0.6pt),
    [$J_theta (policy_decrule)=-R(theta,decrule)$], [One fold, finite], [Bounded $L$, same rule class], [@thm:m-repr, App. A],
    [Bayes/minimax/admissibility travel], [Same], [Same class both sides], [App. A],
    [Observe-stop recursion optimal], [Finite Bayesian], [Prior, channel, finite $T$], [@thm:m-secuencial, App. A],
    [No folding with controlled channel], [Sequential, finite], [Reachability of the witness], [@thm:m-frontier, App. A],
    [$EE_b (hat(J)_"IS")=J(e)$], [i.i.d. episodes], [Assumptions A1–A3, true weights], [@thm:m-is-insesgado, App. A],
    [DR bias is a product of errors], [One decision], [Integrability, fixed candidates], [@thm:m-dr, App. A],
    [Efficient expansion of DR], [One decision], [Cross-fitting, rates, positivity], [App. A sketch],
    [CS valid under monitoring], [Designed support], [Ratio bound $C$, true weights], [@thm:m-ope-cs, App. A],
    [OBD study conclusions], [Logged bandit], [Per @prop:m-protocolo file], [Ch. 11],
    hl(),
  ),
)
]

== Readings

The calculus is this book's own; its ingredients are standard and credited
in line. The certificate format operationalizes the verification discipline
of #cite(<kallus2020double>, form: "prose") and the protocol file of
Chapter 6; the failure examples are exact computations re-checked by
`verificacion/m_ch10_certificados.py`.
