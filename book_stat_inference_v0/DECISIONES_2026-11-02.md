# ACTA DE DECISIONES — reformulación a monografía de nivel mundial

**Fecha:** 2026-11-02 · **Autoridad:** delegada por el autor ("toma todas las decisiones")
**Base:** `PROPUESTA_REFORMULACION.md` (2026-11-02) + evaluación de rigor del mismo día
**Documento que fija todas las decisiones abiertas de la propuesta. Sin efecto
retroactivo sobre `PENDIENTES.md`: las deuda editorial sigue su curso propio.**

---

## Decisiones

**D1 — Canal.** Primario: *Foundations & Trends in Machine Learning*
(propuesta en F1). Respaldo a 4 semanas sin interés editorial: *SpringerBriefs
in Statistics* (variante de M recortada a ~125 pp; V4 pasa a problemas
abiertos en esa variante). Último: *IMS Monographs* (CUP).
*Motivo:* el formato FnT (síntesis larga con marco propio) es exactamente la
forma de M; el manuscrito sirve para los tres canales sin reescritura.

**D2 — Doble artefacto (confirmada).** **M** en inglés (monografía de
investigación), **C** en español cerrada como `v1.0-curso`. El curso conserva
su función docente; M no arrastra la deuda editorial del curso.

**D3 — V4 (agentes de lenguaje).* *Capítulo completo de frontera con
resultados de identificación parcial, etiquetados como parciales. Degradación
escrita: si a la entrada de F4 no están consolidados el teorema de
no-identificación y el caso DR con probabilidades registradas, el capítulo
pasa a "problemas abiertos con análisis de identificación" — aun así por
encima de la literatura actual de evaluación de agentes LLM.

**D4 — Título de M.** *Statistical Guarantees for Sequential Decision
Agents: Risk, Representation, and Verification.* C conserva su título actual.

**D5 — Caso con datos reales.** Open Bandit Dataset (ZOZOTOWN) como cap. 11
de M, ejecutando el protocolo de V2 de punta a punta. Respaldo: Diabetes
130-US (ya usado en `agents_curso/capitulo_09_isomorfismo`). SSCH queda como
hilo pedagógico de C y como Apéndice C de M, con su condición sintética.

**D6 — Gobernanza de V1.** Chequeo de literatura acotado a 2 semanas dentro
de F2, antes de redactar nada. Si la caracterización resulta conocida,
degrada a "nota expositiva con demostración completa" por decisión escrita
en `REGISTRO_DIARIO.md`.

**D7 — Alcance negativo (contractual).** No entran: Q-learning/DQN/PPO ni
algoritmos de RL de aprendizaje; capítulo de predicción conforme (solo
mención como problema abierto en V4); los 279 resultados del cap. 4 que
nunca se invocan aguas abajo (cómputo de `MAPA_ESTRUCTURA.md`) van al
Apéndice B de referencia.

**D8 — Gobernanza invariante.** Se mantienen como reglas del proyecto:
protocolo de fichas (.bib solo tras abstract + hipótesis leídos), huecos
declarados (nunca prosa plausible), semillas fijas, `verificacion/*.py` para
toda afirmación numérica, prohibido el laboratorio tautológico, salud de
cierre de fase = `typst compile main.typ` exit 0 + `ejecutar_todos.py` exit 0
+ `verificacion/*.py` OK, y todo capítulo nuevo entra con su *smoke compile*.

**D9 — Laboratorio insignia.** Reimplementar
`agents_curso/capitulo_09_isomorfismo/src/isomorphism_agent/functor.py` sobre
la construcción del teorema del cap. 5 ($S=\mathcal{X}\cup\{s_{\text{fin}}\}$,
inicial $P_\theta$, políticas $\mathcal{X}\to\mathcal{A}$, verificación
integrando sobre $X$). Mínimo aceptable si la reimplementación se difiere:
renombrar afirmaciones (fuera "funtor" y "preserva composición"; dentro
"correspondencia puntual clarividente").

**D10 — Toolchain fijado.** Typst **0.15.1** (el de README) instalado en la
VM el 2026-11-02. Toda compilación del proyecto se hace con esa versión.

**D11 — Difusión.** El capítulo V3 (anytime-valid OPE) se publica como nota
arXiv al finalizar F2, salvo objeción del canal elegido. Visibilidad temprana
y retroalimentación externa antes del envío de M.

---

## Ejecución de Fase 0 (hecha el 2026-11-02)

1. **Typst 0.15.1 instalado** en la VM (`~/.local/bin/typst`), versión idéntica
   a la probada por el README.
2. **Diagnóstico del fallo de compilación.** La nota "FAIL preexistente
   `intro.typ:89` (no tocar a ciegas)" de `PENDIENTES.md` está **obsoleta**:
   no hay error en `intro.typ`. El fallo real era
   `apendices/apendice_reproduccion.typ:148`: `$nT$` se lee en Typst como
   variable desconocida `nT`.
   **Corrección aplicada:** `$nT$` → `$n T$` (producto), un solo carácter de
   clase, sin tocar ninguna otra cosa. `PENDIENTES.md` no se editó; la línea
   obsoleta puede depurarse en su próxima revisión.
3. **Estado post-fix:** `typst compile main.typ` → **exit 0, 0 advertencias,
   275 pp.** PDF de control: `.scratch/check_main.pdf`.
4. **Queda en F0 (abierto):** auditoría `referencias.bib` contra fichas;
   entorno de laboratorio fijado (venv en `book_stat_inference_v0/` según
   README, con sklearn y gymnasium, que faltan en la VM).

## Próximo hito

F1 (semanas 1–3): kit de propuesta de M (6 pp + capítulo muestra de V3).
Precondición cumplida: el repo compila limpio desde hoy.
