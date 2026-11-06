# AUDITORÍA DE ENUNCIADOS — `Book/*.lean` contra `capitulos/*.typ`

Fecha: 2026-11-06 (sesión t27). Sin commit — pendiente de decisión del autor.

## Alcance y método

Los **59** teoremas de F0–F2: los 57 con docstring `book:` heredados de las
fases anteriores (63 totales menos los 6 de F3 cotejados en la sesión
precedente) más `ch7_complete_class_esencial` y
`ex_ch9_fallo_overlap_instancia` (en `Book/Audit.lean` pero sin docstring).
Método: extracción de enunciado + docstring por teorema; lectura del pasaje
`.typ` citado; comparación de hipótesis, cuantificadores, clase de
comparación, fuerza de la conclusión y fidelidad numérica; barrido
sistemático de elaboración de racionales literales (la trampa ℕ del
proyecto) sobre **todo** `Book/`, no solo el alcance nominal.

## Veredicto global

- **55/59 FIELES** al libro (con caveats declarados en docstring donde
  corresponde; véanse las notas menores).
- **2 con defecto crítico** (conjunciones vacuas por elaboración en ℕ):
  `ex_ch11_pg_ssch`, `ex_ch9_fallo_mixing`.
- **1 con referencia colgante** en el docstring: `ex_ch5_cadena`.
- **1 con cobertura parcial no declarada**: `ex_ch9_fallo_overlap`.
- **2 correcciones a chequeos propios de F3** (dichos «verificados» en la
  sesión anterior): `ch11_cuantizacion_ejemplo` y `ch11_tasa_tabular`
  tienen conjunciones vacuas por la misma trampa.

## H1 (crítico) — conjunciones vacuas por elaboración en ℕ

Un racional literal sin ascrito de tipo, dentro de una conjunción `∧` que
no tiene ninguna variable o función con valor real que la conduzca,
elabora en **ℕ** con división truncada: `1/2 = 0`, luego toda la
conjunción se reduce a `0 = 0` o `0 ≤ 0` — verdadera y **vacía**. La trampa
estaba documentada en la memoria del proyecto (se pagó en `Cap07OPE` con
el patrón `(43/100 : ℝ)`) pero reapareció en tres módulos. Verificado con
`#check` aislado: las nueve expresiones afectadas elaboran en `ℕ`.

| Teorema | Línea | Conjunción vacía | Debía verificar | En ℝ |
|---|---|---|---|---|
| `ex_ch11_pg_ssch` | `Cap08Intervalos.lean:206` | `(1/2)*(1/2)*(2/3)/4 = 1/12` | gradiente `E[S²]·p(1−p) = 1/12` | **falsa** (da 1/24: factor 1/2 de más — mal codificada además) |
| `ex_ch11_pg_ssch` | `Cap08Intervalos.lean:208` | `(1/5)/16 − ((1/3)/4)² = 1/180` | varianza con baseline `1/180` | verdadera |
| `ch11_cuantizacion_ejemplo` | `Cap11Despliegue.lean:22` | `24/25 − 19/20 = 1/100` | cambio de contribución `1/100` | verdadera |
| `ch11_cuantizacion_ejemplo` | `Cap11Despliegue.lean:23` | `(1/100)(1+3/2) = 1/40` | cota `ε_q(1+C) = 1/40` | verdadera |
| `ex_ch9_fallo_mixing` | `Cap06Fronteras.lean:128` | `E[(X−1/2)²] = 1/4` | covarianza `1/4` | verdadera |
| `ch11_tasa_tabular` | `Cap08Intervalos.lean:240` | `(3/10)² ≤ (1/4)(3/2)` | comparación 72 ≤ 75 (decorativa) | verdadera |
| `ch11_tasa_tabular` | `Cap08Intervalos.lean:241` | `(1/5)² ≤ (1/4)(2/3)` | comparación 24 ≤ 25 (decorativa) | verdadera |

Qué queda sin verificar de lo afirmado en el registro/dashboard:
- `ex:ch11-pg-ssch` (#32): el **gradiente 1/12** y la **varianza 1/180**.
  Siguen verificados: momentos (∫x², ∫x⁴), varianza sin baseline 13/720 y
  reducción 9/13.
- `cap11-cuantizacion` (#28): el **cambio 1/100** y la **cota 1/40**.
  Siguen verificadas: las contribuciones DR 19/20, 11/20 y la perturbada
  24/25.
- `ex:ch9-fallo-mixing` (#21): la **covarianza 1/4**. Sigue verificada: la
  media muestral ≡ Z.
- `thm:ch11-tasa-tabular` (#34): solo las dos conjunciones decorativas;
  **todo el contenido sustantivo** (forma cerrada, TV por paso, cotas por
  estado y estacionaria) está verificado en ℝ.

Corrección propuesta (pendiente de aprobación): ascrito `:ℝ` al primer
factor de cada conjunción; en `Cap08Intervalos.lean:206` corregir además
la expresión a `(1:ℝ)/2 * (2/3) * (1/2) * (1/2) = 1/12` (densidad ×
integral × p(1−p)).

## H2 — referencia colgante en `ex_ch5_cadena`

El docstring (`Cap08Intervalos.lean:127`) remite a
`ex_ch5_cadena_varianza_finita`, que **no existe** en `Book/`. La fórmula
finita exacta del libro (cap06_fallos.typ:343:
`Var(X̄_T) = 24/T + 48/T²·Σ_{k=1}^{T−1}(T−k)(1/2)^k ≈ 0.7104` en `T=100`)
y el paréntesis del plan #31 («varianza exacta finita, racional exacto»)
no están formalizados. El resto del teorema (media 4, varianza 24,
covarianza 24(1/2)^k, σ²_LR=72) es fiel y está verificado.

## H3 — cobertura parcial no declarada en `ex_ch9_fallo_overlap`

El ejemplo del libro (cap06_fallos.typ:249) tiene dos partes: (i) **sin
soporte** — dos modelos con los mismos registros y valores objetivo 0 y
0.9, no identificación; (ii) **solapamiento débil** — `Var(W) =
0.81(1/ε−1)`, con ε=0.01 → 80.19. El Lean formaliza solo (ii) (exacta,
con la instancia 8019/100); la parte (i) no está formalizada ni declarada
como omitida en el docstring. El plan #22 describía la fila con ambas
partes.

## Notas menores (sin acción obligatoria)

- `ch8_contraccion` / `ch8_punto_fijo_unico`: solo `T*`; el libro enuncia
  la contracción y el punto fijo único también para `T^π` (declarado en
  docstring). El par `T^π` se usa internamente (serie de Neumann de
  `Vpi`) pero no como teorema auditado.
- `ch9_isomorfismo`: el libro añade que `F(δ)=π_δ` es biyección; es
  trivial (mismo espacio de funciones `X → A`) y no se enuncia.
- `cor:ch9-bayes`: la frase «identifica los conjuntos de minimizadores
  del riesgo de Bayes con los de maximizadores de J_ν» no es teorema
  separado (corolario inmediato de la identidad probada).
- `ch11_baseline`: se verifica `E[z·b]=0`; la frase «puede reemplazarse
  `G_t` por `G_t−b_t`» no está como conclusión (consecuencia inmediata).
- `ex_ch9_fallo_mixing`: la covarianza «para todo rezago» es implícita en
  el modelo degenerado `X_t ≡ Z`; el enunciado no indexa `k` (además del
  defecto H1).
- `ex_ch9_observabilidad_parcial`: la segunda conjunción verifica
  `P((0,0)) = 17/50`, cantidad que el libro no menciona (numéricamente
  igual al normalizador de `(1,1)` por la simetría del canal).
- `ex_ch9_confounding`: el binder `y` de la primera conjunción no se usa
  y los dos indicadores son idénticos; renderización oblicua, contenido
  correcto (la ley observada coincide y `E[Y(1)]` = 1/2 vs 1).
- `ch10_var_dr`: formaliza exactamente el `prop:ch10-var-dr` del libro
  (R=0, D=1−2A, media 0, varianza 1, IS≡0) ✓. El micro-ejemplo
  «3/4 vs 1/2» del texto previo (cap07_ope.typ:432, que el plan #25 usaba
  como descripción) no está formalizado — declarado en el docstring.
- `ch7_minimax_bayes` / `ch7_admisibilidad_bayes`: la clase determinista
  es legítima porque el libro define `𝒟₀` determinista como clase por
  defecto (cap05_incrustacion.typ:17: «Las comparaciones se harán siempre
  dentro de esta clase, salvo indicación expresa»); la clase ampliada del
  ejemplo SSCH está cubierta directamente por `ssch_minimax`.

## Cotejos positivos (resumen)

- **SSCH**: las tres tablas del libro (riesgos por regla en
  cap05:262/cap02:184, posteriores 12/19 y 3/31, umbral 1/5, minimax
  aleatorizado 3/8 con riesgos 1/2 certificado por ν*=1/2, cota ∀δ,
  retornos −1/5 y −4/5, W₀=7/10, W₁=43/100) — **exactas** en racionales.
  `ssch_mdp_bellman`: tabla del MDP reducido (cap03:243) entrada por
  entrada (r, transiciones, γ=9/10), V*=(5,4), iteradas (1,0), (7/5,2/5),
  (44/25,19/25) — exactas.
- **cap03**: `ch8_mejora` con la regla de desempate del libro como
  hipótesis `hcambio` (fiel), `ch8_pi_finita_*` (las tres partes),
  `ch8_parada` con las dos cotas exactas del libro.
- **cap05**: `ch9_secuencial_cota/alcanza` cubren el teorema completo
  (recursión W = mínimo sobre estrategias), `ch9_bellman` exacto,
  `ch7_traduccion`/`_optimos` exactos sobre `𝒟₀` (el libro delimita la
  clase explícitamente), `ch9_admisibilidad`/`ch9_bayes` exactos.
- **cap07**: las tres identidades de `thm:ch10-identificacion` (los tres
  teoremas juntos), `ch10_is_insesgado/varianza`, `ch10_curse` (cota
  B²C^H/n) y el ejemplo exacto (c equivalente a la forma del libro,
  verificada algebraicamente), `ch10_dr` y sus dos corolarios (la
  identidad de sesgo coincide término a término con cap07:436).
- **cap06**: `ch9_ic` (transporte), los contraejemplos de confounding,
  memoria y minimax dominada — números exactos contra el .typ.
- **cap02**: `ch7_bayes` (existencia + Bayes entre aleatorizadas +
  concentración), `ch7_complete_class_bayes`/`_esencial` (las dos partes
  del teorema del libro), `ch7_minimax_bayes` (con el alcance de clase
  declarado).

## Propuestas (pendientes de aprobación del autor)

1. Ascritos `:ℝ` en las siete conjunciones de H1 (tres archivos) y
   corrección de la expresión del gradiente en `Cap08Intervalos.lean:206`.
2. Escribir `ex_ch5_cadena_varianza_finita` (la fórmula finita del libro
   en racionales exactos) o corregir el docstring de `ex_ch5_cadena`.
3. Declarar en el docstring de `ex_ch9_fallo_overlap` la omisión de la
   mitad «sin soporte», o formalizarla.
4. Re-correr `./verificar.sh` y regenerar el dashboard tras 1–3.

## Actualización (t28, mismo día) — correcciones aplicadas

Con autorización del autor: (1) ascritos `:ℝ` en las siete conjunciones
de H1 y gradiente corregido a `E[S²]·p(1−p) = (1/2)·(2/3)·(1/2)·(1/2)`;
re-test con el mismo `#check`: las siete elaboran en ℝ. (2) Escrito
`ex_ch5_cadena_varianza_finita`: en `T = 100` la fórmula finita vale
exactamente `444/625 + 3/(625·2^99)` — `444/625 = 0.7104` es el decimal
del libro y `3/(625·2^99)` la corrección. (3) Declarada la omisión de la
parte «sin soporte» en el docstring de `ex_ch9_fallo_overlap`. (4)
`./verificar.sh` en verde (9 módulos, 66 teoremas, 0 sorry) y dashboard
regenerado (64 filas, 35/35). H1–H3 saldados. Sin commit.

