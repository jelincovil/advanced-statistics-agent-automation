#import "../plantilla_M.typ": *

#cap-sin-numero[
= Preface
]

This monograph is about one discipline: a claim about a sequential decision
agent is only as strong as the chain that links it to data. The chain has
three links. A *representation* link fixes what the decision problem is —
who decides, from what information, under which family of models. An
*estimation* link fixes what the data allow us to learn about a policy and
with what precision. A *verification* link fixes which checks confirm that
the first two links hold in a concrete system.

The book grows out of a doctoral course taught in Spanish (*Teoría Avanzada
de Inferencia Estadística aplicada a la decisión secuencial y los agentes
inteligentes*). The course book is broader; this volume is sharper. It keeps
the representation theorem that anchors the course — a faithful one-step
embedding of Wald decision problems into Markov decision processes — and
builds outward in three directions the course only sketched: the structural
frontier of that embedding, inference that stays valid while data still
accumulate, and a calculus for deciding when a guarantee may be reported.

== Conventions

Every numbered environment carries its hypotheses; every proof is in
Appendix A or is explicitly marked as a sketch with a pointer to its source.
Every displayed number is computed by a script shipped with the book
(Appendix D), with fixed seeds. An OPEN box declares a gap instead of
filling it with plausible prose; several remain, and they are meant to
remain until someone closes them — possibly the reader.

The synthetic example thread SSCH (a hypertension support system) is used
to make every calculation checkable; its figures are not clinical estimates,
and the book says so each time it uses them. The single real-data study
(Chapter 11) is the one place where the protocol is executed end to end on
data that the authors did not generate.

== Acknowledgments of sources

The estimation part draws on the off-policy evaluation literature,
particularly the work of Kallus and Uehara and of Shi, Zhang, Lu and Song;
the anytime-valid part on the program of Ramdas, Vovk and their
collaborators; the decision-theoretic spine on Wald, Ferguson, Berger, and
Puterman. Each result used from these works is stated with its own
hypotheses and cited at the point of use; the annotated bibliography
conventions of the course book apply here in full.
