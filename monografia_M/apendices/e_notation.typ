#import "../plantilla_M.typ": *

= Notation and bilingual glossary
<app:notation>

== Core notation

#mi-tabla(
  caption: [Core symbols used across the monograph],
  key: "tab:m-core-notation",
  table(columns: (26%, 1fr), align: left, hl(),
    table.header([*Symbol*], [*Meaning*]), hl(w: 0.6pt),
    [$ParamSpace, SampleSpace, ActionSpace, StateSpace$], [Parameters, observations, actions, states],
    [$P_theta, P_pi, P_b$], [Observation law; laws induced by target and behavior policies],
    [$L(theta,a), R(theta,decrule)$], [Loss; risk of a rule],
    [$r_theta (x,a), J_theta (policy), J_nu (policy)$], [Reward; return under one model; prior-averaged return],
    [$V^policy, Q^policy, v_t, q_t$], [Value functions],
    [$W_t=product_(k<=t) rho_k, w_t$], [Cumulative density ratios; marginal occupancy ratios],
    [$m_b (y), B(b,y)$], [Predictive law and Bayes update at belief $b$],
    [$ell(b,a), W_k (b)$], [Posterior expected loss; remaining minimal risk with $k$ observations left],
    [$E_t$], [E-process (nonnegative, mean at most 1 at any stopping time)],
    [$(C_t)$], [Confidence sequence (uniform-in-time coverage)],
    [$sigma_(L R)^2$], [Long-run variance under dependence],
    hl(),
  ),
)

== English–Spanish working glossary (companion book terms)

#mi-tabla(
  caption: [Term correspondence with the Spanish course book],
  key: "tab:m-glosario",
  table(columns: (50%, 50%), align: left, hl(),
    table.header([*English (this monograph)*], [*Español (libro del curso)*]), hl(w: 0.6pt),
    [transfer certificate], [certificado de transferencia / ficha de justificación],
    [information state], [estado de información],
    [confidence sequence], [secuencia de confianza],
    [labeled synthetic example], [ejemplo sintético (`es-sintetico`)],
    [opening (OPEN box)], [hueco declarado (`PENDIENTE`)],
    [one-decision MDP], [MDP de una decisión],
    [folding], [incrustación de una decisión],
    [support states of a guarantee], [estados de la garantía],
    hl(),
  ),
)
