# Materiales del piloto (ámbito y qué ve el alumno)

- **Sesión:** `PILOTO_SESION_3H.md` (autocontenida: setup → los dos estimadores →
  paso comparativo → ficha). Coherente con este documento.
- **Setup por cliente:** `docs/sesiones.md` (Claude Code principal, Cursor, Codex, Windows).
- **Issue de feedback:** `docs/ISSUE_TEMPLATE_FEEDBACK.md` (específica: 9 preguntas
  de una línea, dos datos útiles de entorno, y los dos valores redondeados).
- **Humo (5 min):** `./setup.sh` en `agente-stats/`.

Números de la sesión (verde-convergentes internamente, determinísticos por seed):

1. `inspect_episodes`: 24 episodios, H=10, versión `opeagent-v2@1.0.0`, modo recorded.
2. `ope_evaluate IS/DR`: IS ≈ 0.784 vs DR ≈ 0.872 vs verdadero ≈ 0.828
   (ambos dentro de un SE de la verdad).
3. `compare_versions`: Δ = −3.07 (se=1.19, CI=[−5.41, −0.73]) — la ε-greedy
   del argmax rinde peor que uniforme en este entorno, lo que el capítulo predice.
4. `justification_ficha`: nivel=region, weakest=open — la ficha termina el
   experimento honestamente, no firmando cobertura nominal.
