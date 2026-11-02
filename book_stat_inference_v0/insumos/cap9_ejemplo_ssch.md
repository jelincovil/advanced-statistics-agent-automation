# Insumo A — Cap. 9: ejemplo trabajado del protocolo sobre el SSCH

**Fecha:** 2026-10-04 · **Estado:** checklist / walkthrough / preguntas · **AUTONOMIA 2026-10-04**  
**Tipo:** A — **no** prosa de contribución del capítulo.  
**Capítulo destino:** `capitulos/cap09_verificacion.typ` (`<ch:verificacion>`).  
**Arco:** instancia del protocolo §2 (`insumos/cap9_sec2_protocolo.md`) aplicada al hilo SSCH; rama NV → §3 (`insumos/cap9_sec3_no_verificable.md`).

---

## 1. Objetivo

Recorrer el protocolo de **8 pasos (+ paso 0)** de `insumos/cap9_sec2_protocolo.md` sobre **una** garantía concreta del libro ligada al SSCH (Sistema de Soporte Clínico para Hipertensión, **sintético**), de modo que el autor pueda narrar un walkthrough sin inventar filas de la canónica ni rellenar CSE.

El ejemplo **no** escribe prosa de contribución; fija el checklist anotado (qué se escribe en cada paso, anclas vivas, estado esperado).

---

## 2. Garantía elegida (labels reales — no inventados)

| Rol | Label vivo | Dónde |
|---|---|---|
| **Garantía auditada** | `@thm:ch6-dr` (Doble Robustez vía IF Eficiente; alias `thm:ch6-doble-robustez`) | `capitulos/cap04_herramientas.typ` |
| **Fila canónica** | «Doble robustez (@thm:ch6-dr)» | `tab:trazabilidad-canonica` / `capitulos/cap09_tabla_canonica.typ` (condiciones: ortogonalidad de Neyman; $\lVert\hat g-g_0\rVert_{L^2}=o_P(n^{-1/4})$; Estado default `—`) |
| **Gancho narrativo SSCH (cap. 9)** | `@ex:ssch-trazability` | `capitulos/cap09_verificacion.typ` — «evaluación de políticas usa DR → garantía de doble robustez» |
| **Ejemplo numérico DR×SSCH** | `@ex:ch6-dr-ssch` | `capitulos/cap04_herramientas.typ` |
| **Intro hilo SSCH** | `<sec:ssch-intro>` + `@ex:ssch-cap01` | `capitulos/cap10_casos.typ` |
| **Prop. de trazabilidad (contexto)** | `@prop:ch12-trazability` | misma zona de `cap09_verificacion.typ` que `ex:ssch-trazability` |

**Por qué esta y no otra.** `ex:ssch-trazability` nombra cuatro garantías; se elige **una** (`thm:ch6-dr`) con fila explícita en la canónica y ejemplo vivo DR–SSCH. Candidatos descartados hoy (siguen disponibles): `thm:ch11-shi` (IC; CSE en filas ch12/app), `thm:ch8-vi-conv` (Value Iteration), UMVUE/Lehmann–Scheffé.

**Relacionados (no auditados hoy):** fila IF eficiente `@thm:ch6-kallus` (condiciones incluyen *overlap*) — útil para la rama NV-id del paso 5.

---

## 3. Checklist paso 0–8 (aplicado al SSCH × `thm:ch6-dr`)

| Paso | Qué se anota (insumo; no prosa) | Anclas | Estado esperado |
|---|---|---|---|
| **0** Origen canónico | Label fuente `thm:ch6-dr` + versión artefacto (fecha manuscrito / hash sesión `2026-10-04`) | `tab:trazabilidad-canonica`; `ch:verificacion` | — (meta) |
| **1** Nombrar label | `thm:ch6-dr`; gancho SSCH `ex:ssch-trazability` / `ex:ch6-dr-ssch` | `sec:ssch-intro`, `ex:ssch-cap01` | — |
| **2** Fila canónica | Localizar fila «Doble robustez (@thm:ch6-dr)»; **no** inventar celda | `tab:trazabilidad-canonica`; barrido OK41/FALTA28 | fila **existe** (OK) |
| **3** Condiciones / CSE | Copiar condiciones de la fila: ortogonalidad Neyman + tasa $n^{-1/4}$; **no rellenar** si hubiera CSE en filas hermanas DR (ch12/app) | fila canónica; `insumos/cap9_columnas.md` | condiciones **especificadas** en esta fila (no CSE) |
| **4** Estado ↔/↝/— | Default canónica = `—` hasta juicio autor | `insumos/cap9_columnas.md` | **`—`** (default) |
| **5** ¿Verificable? | (5a) ¿Ortogonalidad / tasas de nuisance / *overlap* de la política de logging son testables en despliegue SSCH? (5b) Si **no** (típico: no-confounding clínico / overlap de guías vs. logging) → **no** subir a ↔; degradar | `fig:ch9-protocolo-verificacion`; puente cap. 11; `ch:fallos` | rama **«no»** plausible → ver §4 |
| **6** Evidencia | Apuntar a `#thm-env` de `thm:ch6-dr`, `ex:ch6-dr-ssch`, ficha lit Dom 4, comentario AUTONOMIA; **sin** DOI no leídos | `ex:ssch-trazability`; LITERATURA | evidencia parcial (abstract lit + thm vivo) |
| **7** Cierre + hash | Si se cierra como degradada: Estado `↝` + hash = path+fecha de este insumo / ficha | protocolo §2 paso 7 | **abierto** hasta decisión autor |
| **8** Checklist | Origen · label · fila · condiciones · estado · 5a/5b · evidencia · hash | los de arriba | **protocolo abierto** (no «aprobado») |

Diagrama de flujo: `@fig:ch9-protocolo-verificacion` (iteración Dom 4).

---

## 4. Rama §3 (NV) — condiciones no verificables en despliegue SSCH

En el SSCH **sintético**, las cifras no son evidencia clínica (`ex:ssch-cap01`). Al *aplicar* el protocolo como si el SSCH fuera un despliegue real, varias condiciones del clúster DR/IF suelen caer en **NV**:

| Condición / supuesto | Tipo NV (§3) | Acción (sin pérdida silenciosa) |
|---|---|---|
| Overlap / soporte de la política evaluada vs. logging clínico | **NV-id** | Degradar a `↝`; cotas de ID parcial (ficha Khan et al. 2023 en §3); **no** inventar test de overlap |
| No-confounding / adherencia no observada (medicación concomitante) | **NV-id** / puente fallo | `↝` + remisión `@ch:fallos`; nota hermano Bruns-Smith & Zhou 2023 (ya en insumo §3) |
| Tasas $n^{-1/4}$ de nuisance en EHR real | **NV-test** | `↝`; checklist evidencia → cap. 11 |
| Filas hermanas DR con `CONDICIONES SIN ESPECIFICAR` | **CSE** | **No rellenar**; Estado `—` |

**Remisión:** `insumos/cap9_sec3_no_verificable.md` (árbol NV-obs / NV-test / NV-id / CSE) · `fig:ch9-protocolo-verificacion` rama «no» · `note:ch9-extension-no-demostrada` si el alcance del funtor no cubre el caso clínico.

---

## 5. Preguntas abiertas para el autor

1. ¿La prosa del walkthrough vive en cap. 9 junto a `ex:ssch-trazability`, en cap. 10 tras `sec:ssch-intro`, o como caja remisa desde ambos?
2. ¿Confirmamos `thm:ch6-dr` como label canónico del ejemplo, o preferís `thm:ch11-shi` / `thm:ch6-kallus` (overlap explícito)?
3. ¿Ante NV-id clínico el Estado pasa a `↝` automáticamente en la fila DR, o fila a fila con visto bueno?
4. ¿Se narra el SSCH **sintético** como contraejemplo pedagógico («el protocolo detecta que no hay despliegue real → no hay ↔»), o se finge un despliegue hipotético?
5. ¿Integramos Nambiar et al. 2023 (ficha abajo) solo en LITERATURA / este insumo, o como lectura de contraste en la prosa del walkthrough?

---

## 6. Ficha literatura OA + S2 — offline RL clínico / optimización de tratamiento (2023)

### Nambiar, Ghosh, Ong, Chan, Bee & Krishnaswamy (2023) — *Deep Offline Reinforcement Learning for Real-world Treatment Optimization Applications*

| Campo | Valor |
|---|---|
| **Cita** | Nambiar, M., Ghosh, S., Ong, P., Chan, Y. E., Bee, Y. M., & Krishnaswamy, P. (2023). Deep Offline Reinforcement Learning for Real-world Treatment Optimization Applications. In *Proceedings of the 29th ACM SIGKDD Conference on Knowledge Discovery and Data Mining (KDD '23)* (pp. 4673–4684). |
| **DOI** | 10.1145/3580305.3599800 |
| **arXiv** | 2302.07549 |
| **OpenAlex** | W4385568106 |
| **Semantic Scholar** | `c6e7f5097e1073f164d4c580a0b2652b882cc34e` |
| **Año / venue** | 2023 · KDD '23 · Crossref pages 4673–4684 · citas OA ~23 / S2 ~42 al 2026-10-04 |
| **OA PDF** | vía ACM / DOI |

#### Abstract (leído vía OA + S2; no inventado)
Hay interés creciente en recomendar estrategias de tratamiento óptimas en enfermedades crónicas y cuidados críticos. El RL encaja en la decisión secuencial, pero debe entrenarse y evaluarse **solo** sobre registros retrospectivos (exploración online insegura). La mayoría de estudios de optimización de tratamiento usan métodos *off-policy* (p. ej. DDQN) que rinden mal en settings puramente offline. Avances como CQL ayudan, pero quedan retos cuando ejemplos subóptimos dominan el dataset y hay **restricciones estrictas de seguridad**. Los autores proponen un muestreo de transiciones teóricamente motivado para el desbalance de acciones en entrenamiento offline RL, con experimentos en tareas reales de **diabetes** y **sepsis**.

#### Qué garantiza / qué exige (según abstract)
- **Garantiza (en el sentido del paper):** un enfoque práctico de muestreo de transiciones para offline RL clínico bajo desbalance de acciones; evaluación empírica en dos tareas médicas reales.  
- **Exige:** datasets retrospectivos; seguridad / no exploración online; lidiar con ejemplos subóptimos dominantes. **CONDICIONES SIN ESPECIFICAR** respecto al catálogo ↔/↝ del libro hasta lectura sección-a-sección del PDF (no se lee hoy el full paper para `.bib`).

#### Encaje cap. 9 / SSCH
- Walkthrough Dom 4: contraste **offline RL clínico real** (diabetes/sepsis) vs. SSCH **sintético** hipertensión — el protocolo de auditoría estadística (DR / overlap / NV-id) es el puente, no la certificación de la política aprendida.  
- Caps. **7–8** (OPE / IC), **11** (despliegue / seguridad), **12** (confounding / limitaciones SSCH).  
- Complementa Prudencio et al. 2023 (taxonomía offline) y Khan et al. 2023 (OPE beyond overlap).  
- **No** añadido a `referencias.bib` hoy.

#### Estado
- [x] Ficha OA + S2 + Crossref (venue/páginas)  
- [ ] PDF completo / hipótesis detalladas  
- [ ] Entrada `.bib`  
- [ ] Integración editorial en prosa del walkthrough  

---

## 7. Qué no hace este insumo

- No escribe prosa de contribución del cap. 9 ni del cap. 10.  
- No edita filas de `tab:trazabilidad-canonica` ni rellena CSE.  
- No toca `dem:ch4-wilks` ni `intro.typ:89`.  
- No añade `.bib`.

**AUTONOMIA 2026-10-04:** walkthrough SSCH × `thm:ch6-dr` + checklist 0–8 + rama NV + ficha Nambiar et al. 2023 ante silencio del autor en prosa del ejemplo.