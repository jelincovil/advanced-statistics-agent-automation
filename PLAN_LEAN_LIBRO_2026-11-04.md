# PLAN — Proyecto Lean de verificación del libro de docencia (`v1.0-libro`)

**Emitido:** 2026-11-04 · **Objeto:** proyecto Lean 4 + Mathlib en una carpeta
del repositorio que verifique mecánicamente las proposiciones y demostraciones
**propias y críticas** del libro de docencia (275 pp, tag `v1.0-libro`).
**Regla de alcance (del autor):** se formalizan los resultados importantes y
críticos del libro; **quedan fuera los clásicos/atribuidos** (ley de grandes
números, CLT, etc. — lista completa en §1).
**Regla madre:** se formaliza lo que el libro afirma, con sus hipótesis; toda
especialización (p. ej. espacios finitos donde el libro dice numerables) se
declara en el docstring del teorema. Un `sorry` no entra jamás al dashboard.

---

## 1. Qué entra y qué no (regla de exclusión explícita)

**EXCLUIDOS por clásicos o atribuidos a la literatura** (el libro los cita con
prueba en apéndice o los atribuye; formalizarlos sería rehacer Mathlib/textos
estándar, no validar el libro): LLN, CLT (Lindeberg–Lévy y su versión mixing),
método delta, bootstrap, Cramér–Rao, Rao–Blackwell, Lehmann–Scheffé, Basu,
factorización Neyman–Fisher, completitud exponencial, Neyman–Pearson e
inversión de tests, Benjamini–Hochberg, Wilks, asintótica del MLE, UCB1,
Lai–Robbins, Thompson Sampling, SPRT, contracción de Bellman per se
(Puterman/Banach), Hoeffding/Ville per se, James–Stein, identidad de gradiente
de política (Sutton), HAC, CLT de mixing, eficiencia de Kallus–Uehara,
SZLS/SAVE, y las proposiciones-repaso del cap. 9 de verificación
(`prop:ch2-suficiencia-politicas`, `prop:ch3-valor-cr`, `prop:ch3-rb-q` —
reenunciados de clásicos).

**Categorías de lo que SÍ entra:**

- **Núcleo P1** — teoremas originales del libro o cuya prueba desplegada es
  obra del libro (la inducción de parada, el desempate de mejora de políticas,
  los certificados residuales con sus dos constantes).
- **Núcleo P2** — resultados finitos que el libro demuestra con su propio
  argumento (minimización posterior con desempate, minimax-vía-Bayes, clase
  esencialmente completa por separación) y **contraejemplos computados del
  cap. 6** (son el corazón pedagógico: confusión, memoria, overlap, mezcla).
- **Ejemplos SSCH** — todas las cifras del hilo longitudinal verificadas como
  igualdades racionales exactas (ninguna aproximación numérica).
- **Puente P3 (decisión del autor)** — resultados limítrofes: versiones finitas
  de despliegue (cuantización, truncamiento, margen), la cadena de 2 estados,
  los racionales exactos del MDP de validación del cap. 11, la micro-lemma del
  reparto α/m(m+1) del monitoreo. Pueden caer sin afectar el núcleo.

## 2. Inventario priorizado (con claves del libro)

### P1 — Núcleo crítico (el proyecto no cierra sin estos)

| # | Resultado (clave del libro) | Fuente | Estado hoy | Módulo destino |
|---|---|---|---|---|
| 1 | `thm:ch9-isomorfismo` — $J_\theta(\pi_\delta) = -R(\theta,\delta)$ | `cap05_incrustacion.typ` + `dem:ch9-isomorfismo` | **HECHO** (piloto `m_repr`) | `Book/Cap05.lean` |
| 2 | `cor:ch9-bayes` — transferencia de Bayes | idem | **HECHO** (`m_bayes`) | `Book/Cap05.lean` |
| 3 | `thm:ch9-admisibilidad` — admisibilidad ↔ retorno-dominancia | idem + `dem:ch9-transferencia-admis` | **HECHO** (`m_admis`) | `Book/Cap05.lean` |
| 4 | `cor:ch7-traduccion` — minimax: $\inf\sup R = -\sup\inf J$ | cap05 §Síntesis | **PENDIENTE** (el piloto no lo cubrió) | `Book/Cap05.lean` |
| 5 | `thm:ch9-secuencial` — recursión de observación/parada $W_k$ (inducción completa; el libro desplegó la prueba que era esbozo) | cap05 + `dem:ch9-suficiencia-markov` | pendiente — **el más difícil del P1** | `Book/Cap05.lean` |
| 6 | `cor:ch9-bellman` — $U_k = -W_k$ | cap05 | pendiente (corolario de #5) | `Book/Cap05.lean` |
| 7 | `thm:ch10-identificacion` — cambio de medida en espacios finitos ($J = \mathbb{E}_b[W_{H-1}G] = \sum_t \gamma^t \mathbb{E}_b[W_t R_t]$) | cap07 + `dem:ch10-is-insesgado` | pendiente | `Book/Cap07.lean` |
| 8 | `thm:ch10-is-insesgado` — insesgadez de IS (versión finita) | cap07 | pendiente (corolario de #7) | `Book/Cap07.lean` |
| 9 | `thm:ch10-curse` — cota $B_H^2 C^H/n$ + **ejemplo exacto** $\mathrm{Var} = (c^H-1)/n$ con $c = 1 + (p-b)^2/(b(1-b))$ | cap07 + `dem:ch10-curse` | pendiente | `Book/Cap07.lean` |
| 10 | `thm:ch10-dr` — identidad DR de una decisión (sesgo = producto de errores), versión finita con sumas | cap07 + `dem:ch10-dr` | pendiente | `Book/Cap07.lean` |
| 11 | `thm:ch8-mejora` + `cor:ch8-pi-finita` — mejora de políticas con **regla de desempate del libro** (cambio ⇒ mejora estricta; terminación finita) | cap03 | pendiente | `Book/Cap03.lean` |
| 12 | `cor:ch8-parada` — certificados residuales: $\|V-V^*\| \le e/(1-\gamma)$ y $\|V^*-V^{\pi_V}\| \le 2\gamma e/(1-\gamma)^2$ | cap03 + `dem:ch8-parada` | pendiente | `Book/Cap03.lean` |
| 13 | SSCH (tabla de riesgos, posterior $12/19$ y $3/31$, umbral $1/5$, minimax aleatorizado $3/8$ con riesgos $1/2$ certificado por prior $1/2$, observar $0.05+0.38=0.43<0.7$) | `ex:ssch-cap07`, `ex:ssch-cap09` | pendiente — igualdades racionales exactas | `Book/SSCH.lean` |
| 14 | `thm:ch9-ic` — transporte de conjuntos por imagen (R1 de los certificados) | cap06 §conjeturas-transferencia | pendiente (contención de sucesos) | `Book/Cap06.lean` |

### P2 — Núcleo (segunda ola)

| # | Resultado | Fuente | Módulo |
|---|---|---|---|
| 15 | `thm:ch7-bayes` — minimización de pérdida posterior con acciones finitas, aleatorización y desempate por primer índice | cap02 + `dem:ch7-existencia-bayes` | `Book/Cap02.lean` |
| 16 | `thm:ch7-minimax-bayes` — Bayes de riesgo constante ⇒ minimax | cap02 + `dem:ch7-bayes-minimax` | `Book/Cap02.lean` |
| 17 | `thm:ch7-admisibilidad-bayes` — prior positivo finito ⇒ admisible | cap02 | `Book/Cap02.lean` |
| 18 | `thm:ch7-complete-class` — clase esencialmente completa (separación convexa en el problema finito) — el más duro del P2 | cap02 + `dem:ch7-clase-completa` | `Book/Cap02.lean` |
| 19 | `ex:ch6-memoria` — dos historias, mismo resumen: recompensa $R_1 = \mathbb{1}\{A_1=A_0\}$; recordar gana 1, olvidar $1/2$ | cap06 | `Book/Cap06.lean` |
| 20 | `ex:ch9-confounding` — M1/M2 con la misma ley observada e $\mathbb{E}[Y(1)] = 1/2$ vs $1$ | cap06 | `Book/Cap06.lean` |
| 21 | `ex:ch9-fallo-mixing` — $X_t = Z$: la media muestral es $Z \in \{0,1\}$, nunca converge a $1/2$ | cap06 | `Book/Cap06.lean` |
| 22 | `ex:ch9-fallo-overlap` — sin soporte (valores 0 vs 0.9); débil: $\mathrm{Var}(W) = 0.81(1/\varepsilon - 1) = 80.19$ con $\varepsilon = 0.01$ (racional exacto $8019/100$) | cap06 | `Book/Cap06.lean` |
| 23 | `ex:ch9-observabilidad-parcial` — posterior $16/17$ y $1/2$ (razones de verosimilitud $16$ y $1$) | cap06 | `Book/Cap06.lean` |
| 24 | `ex:ch6-minimax-dominada` — $V^a=(1,0)$ domina a $V^b=(0,0)$; ambas maximin | cap06 | `Book/Cap06.lean` |
| 25 | `prop:ch10-var-dr` — con $m$ exacta, el término correcto vale $3/4$ y usar $m(A)$ da $1/2$ | cap07 | `Book/Cap07.lean` |
| 26 | `prop:ch11-baseline` + ejemplo $p=0.75$: varianzas $0.01171875$ / $0.046875$ / $0$ (baseline óptima $b=1-p$) | cap08 | `Book/Cap08.lean` |
| 27 | `ex:ssch-cap08` — $V^*=(5,4)$ verifica Bellman; iteradas $(1,0),(1.4,0.4),(1.76,0.76)$ | cap03 | `Book/SSCH.lean` |

### P3 — Puente (opcional; decisión del autor)

| # | Resultado | Módulo |
|---|---|---|
| 28 | Cuantización (cap. 11 §"Cuantización"): $\|\Delta D\| \le \epsilon_q(1+C)$ + ejemplo $0.55/0.95 \pm 0.01$ con cota $0.025$ | `Book/Cap11.lean` |
| 29 | Truncamiento: $B_H = R_{\max}\gamma^H/(1-\gamma)$; con $R_{\max}=1.2,\gamma=0.9,\varepsilon=0.1$, $H \ge 46$ (verificación racional) | `Book/Cap11.lean` |
| 30 | Monitoreo: $\sum_{m=1}^M \alpha/m(m+1) = \alpha(1-1/(M+1)) \le \alpha$ (telescopio + Boole) | `Book/Cap11.lean` |
| 31 | `ex:ch5-cadena` — cadena de 2 estados: $\mathrm{Cov}=24(0.5)^k$, $\sigma^2_{LR}=72$, varianza exacta finita $\approx 0.7104$ en $T=100$ (racional exacto) | `Book/Cap08.lean` |
| 32 | `ex:ch11-pg-ssch` — gradiente $1/12$; varianzas $13/720$ y $1/180$; reducción $9/13$ (momentos de uniforme en $[-1,1]$) | `Book/Cap08.lean` |
| 33 | MDP de validación (cap. 11, `def:appE-mdp-test`): verificar por sustitución con racionales que el $V_\infty$ y $v_0(5)$ enunciados resuelven $(I-\gamma P)V = r$ y la recursión hacia atrás con $v_5=0$ | `Book/Cap11.lean` |
| 34 | `thm:ch11-tasa-tabular` — cota espectral reversible (limítrofe clásico; solo si el autor quiere la versión del libro) | `Book/Cap08.lean` |
| 35 | Margen elemental: $\mathbb{E}[\text{pérdida}] \le C(2\epsilon)^{1+\kappa}$ bajo la hipótesis de masa explícita | `Book/Cap11.lean` |

## 3. Estructura del proyecto

```
verificacion_lean/                    # carpeta NUEVA en la raíz del repo
  lean-toolchain                       # 4.33.1 (coincide con /opt/lean)
  lakefile.toml                        # solo portabilidad/CI; local usa LEAN_PATH
  README.md                            # cómo correr, alcance, exclusiones
  verificar.sh                         # runner: `lean` sobre cada archivo con LEAN_PATH
  Book/
    Foundation.lean                    # problema de Wald finito, MDP, notación
    Cap02Wald.lean                     # #15–#18
    Cap03MDP.lean                      # #11–#12
    Cap05Representacion.lean           # #1–#6 (migra el piloto) + SSCH observar
    Cap06Fronteras.lean                # #14, #19–#24
    Cap07OPE.lean                      # #7–#10, #25
    Cap08Intervalos.lean               # #26, #31–#32, (#34)
    Cap11Despliegue.lean               # #28–#30, #33, #35
    SSCH.lean                          # #13, #27 — solo igualdades racionales
    Certificados.lean                  # reglas R1/R3 como teoremas + contraejemplos
  Progress/
    DASHBOARD.md                       # teorema ↔ clave del libro ↔ axiomas
```

Convención de nombres: cada declaración lleva un comentario
`-- book: capitulos/capXX.typ:<línea> key: <clave>` y su nombre en snake_case
deriva de la clave (`thm:ch9-secuencial` → `theorem ch9_secuencial`).
El dashboard se genera con un script de una página desde los comentarios.

## 4. Política de fidelidad de enunciados

- Capa base: **espacios finitos** (Θ, X, A, S `Fintype`), riesgo/retorno como
  sumas con pesos no negativos normalizables (el mismo estilo del piloto,
  que mantuvo los axiomas limpios). Donde el libro afirma más general
  (numerable/measurable), el docstring declara: «versión finita del enunciado;
  el libro lo enuncia para X numerable en cap05.typ:...».
- Los ejemplos SSCH se prueban como **igualdades racionales exactas**
  (`norm_num`/`decide` sobre `ℚ`); prohibido verificar con flotantes.
- Los enunciados de OPE finitos llevan las hipótesis de soporte del libro
  (b > 0 donde la identificación lo exige) — nunca se relajan.

## 5. Entorno y factibilidad (verificado hoy)

- Lean **4.33.1** con **Mathlib precompilada** en `LEAN_PATH` (arranque de VM:
  2–3 s por archivo en caliente). `/opt/mathlib` es **read-only** para este
  usuario ⇒ `lake build` no puede escribir allí; el runner canónico local es
  `verificar.sh` invocando `lean <archivo>` con el `LEAN_PATH` del entorno
  (mecánica ya probada con el piloto: 3/3 teoremas, 0 `sorry`, axiomas limpios).
- `lakefile.toml` + `lean-toolchain` se incluyen solo para portabilidad
  (otra máquina con `lake exe cache get`); **no** son el mecanismo local.
- Las pruebas duras (#5 parada, #18 separación convexa) se atacan con
  **corridas de discovery acotadas** (sin red, como el piloto):
  ≤ 300 llamadas y ≤ 2 USD por problema, con re-elaboración local de cada
  prueba y auditoría `#print axioms` antes de integrar.

## 6. Política de calidad (no negociable)

1. **Cero `sorry`** en `Book/` — un archivo con `sorry` no se commitea.
2. **`#print axioms` por teorema**: esperados solo `propext`,
   `Classical.choice`, `Quot.sound`. Cualquier axioma extra se registra en el
   dashboard con su justificación (los archivos con `PMF` podrían añadir
   `MeasureTheory` — si aparece, se documenta o se reformula a sumas).
3. **Sin `native_decide`** para las proposiciones matemáticas (solo `decide`
   sobre estructuras demostrablemente decibles).
4. Trazabilidad bidireccional: comentario → clave del libro; dashboard →
   tabla inversa. La cobertura se reporta como «claves del libro cubiertas /
   claves del inventario P1–P3».
5. Ninguna prueba "a ciegas": cada enunciado se congela primero (compila con
   `sorry`), se contrasta con el `.typ` línea a línea, y recién entonces se
   prueba.

## 7. Proceso por teorema

1. Congelar el enunciado con docstring (fidelidad + clave) — compila con `sorry`.
2. Contraste contra `capitulos/*.typ` (¿dice el libro exactamente esto?).
3. Intento local de prueba (simp/inducción/norm_num).
4. Si no cede en el tiempo acordado: corrida discovery acotada (§5).
5. Re-elaboración local + auditoría de axiomas.
6. Dashboard + entrada en `REGISTRO_DIARIO.md`.

## 8. Fases con criterios de aceptación

| Fase | Contenido | Aceptación medible | Estimación |
|---|---|---|---|
| **F0** — andamiaje | crear `verificacion_lean/`, `Foundation.lean`, migrar el piloto (#1–#3), `verificar.sh`, README, dashboard | `verificar.sh` verde; 0 `sorry`; axiomas limpios; #1–#3 + minimax (#4) probados | 0.5–1 día |
| **F1** — núcleo P1 | #5–#14 (parada, identificación, IS, curse, DR, mejora+desempate, certificados residuales, SSCH completo, R1) | dashboard: P1 completo (14/14); `verificar.sh` verde; 0 `sorry` | 2–3 días + discovery |
| **F2** — núcleo P2 | #15–#27 (Bayes/minimax/admisibilidad/clase completa + contraejemplos cap. 6) | P2 completo (13/13); ídem calidad | 1.5–2 días |
| **F3** — puente P3 (si el autor lo aprueba) | #28–#35 | según alcance aprobado | 1–1.5 días |
| **F4** — cierre | `INFORME_LEAN_<fecha>.md`: tabla cobertura claves↔teoremas↔axiomas, exclusiones respetadas, límites declarados | informe revisado; dashboard final | 0.5 día |

## 9. Presupuesto discovery propuesto

Como el piloto (que consumió ~120k tokens de entrada por 3 problemas):
por problema ≤ 300 llamadas de modelo y ≤ 2 USD; P1 estimado en 6–10
corridas (la parada y la DR finita son las caras; IS/curse son álgebra de
sumas). Total estimado del proyecto: **≤ 20 USD** en discovery, más el trabajo
local de cada prueba.

## 10. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| `thm:ch9-secuencial` (inducción sobre estrategias) excede el esfuerzo | Declarar la recursión como definición + probar (a) cota inferior de toda estrategia y (b) existencia de la estrategia que la alcanza; si (b) resiste, registrar en dashboard como «recursión verificada, existencia de estrategia óptima pendiente» — nunca `sorry` |
| Clase completa (#18) necesita separación convexa no trivial | Mathlib tiene separación; si el coste es alto, se declara P3-reubicado con conformidad del autor |
| Archivos con `PMF` arrastran axiomas extra | Mantener la capa de sumas del piloto; `PMF` solo donde la probabilidad condicional es imprescindible (posteriores), con auditoría |
| Deriva de enunciados ("verifiqué otra cosa") | Paso 2 del proceso obligatorio + doble lectura de la clave |
| Corrupción de strings al escribir .lean (ya sufrida en .typ) | Escribir los archivos por fs_create y re-leer antes de compilar; jamás reemplazos shell con texto no verificado |

## 11. Decisiones del autor (para arrancar F0)

1. **Carpeta y nombre:** `verificacion_lean/` en la raíz (propuesto) — ¿ok?
2. **P3:** ¿se aprueba el lote puente (#28–#35) o el proyecto cierra en P2?
   Mi recomendación: aprobar #28–#30 y #33 (baratos y anclan cap. 11) y dejar
   #31/#32/#34/#35 como opcional final.
3. **Presupuesto discovery:** confirmar ≤ 2 USD / problema, ≤ 20 USD total.
4. **Migración del piloto:** copiar `m_repr/m_bayes/m_admis` a
   `Cap05Representacion.lean` como origen canónico del libro (el archivo de
   `monografia_M/` se conserva con una nota de referencia, no se mueve).
5. **Cadena `thm:ch11-tasa-tabular` (#34):** limítrofe clásico — dentro o fuera.

## 12. Entregables

1. `verificacion_lean/` completo: fuentes, runner, README, dashboard.
2. `INFORME_LEAN_<fecha>.md`: cobertura P1–P3 contra claves del libro, tabla de
   axiomas por teorema, exclusiones respetadas, límites declarados.
3. Entradas de `REGISTRO_DIARIO.md` por fase, y nota en el propio libro
   (cap. 9/apéndice) cuando la cobertura P1 esté completa: «las identidades
   del núcleo están verificadas mecánicamente en `verificacion_lean/`».
