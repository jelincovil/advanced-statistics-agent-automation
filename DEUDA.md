# DEUDA.md — Apéndice de regularidad (`apendice_regularidad.typ`), deudas `C.*`

Registro de deudas con obstrucción precisa. Entregable de esta dirección
(`C.thm:appD-ibragimov`): `verificacion_lean/Book/ApendiceDIbragimov.lean`
(1007 líneas, 0 `sorry`, auditoría de axiomas en `verificacion_lean/AuditIbra.lean`:
18 teoremas, todos con `#print axioms ⊆ {propext, Classical.choice, Quot.sound}`;
runner propio `verificacion_lean/verificar_ibragimov.sh`).

Regla aplicada: lo que no se pudo formalizar **no se enuncia** en Lean; queda aquí
con la obstrucción concreta (qué falta en Mathlib v4.33.1 y por qué).

---

## 1. `C.thm:appD-ibragimov` — CLT de Ibragimov para α-mixing

### 1.1 Verificado mecánicamente

| Declaración | Contenido |
|---|---|
| `integral_comp_fintype`, `integral_comp_pair`, `sum_measureReal_pairs` | integrales de funciones de variables finitas = sumas sobre la ley; marginales y ley conjunta suman 1 |
| `alphaSum`, `alphaCoef`, `abs_desv_le_alphaCoef`, `alphaCoef_le_one` | coeficiente α sobre particiones finitas; domina `|P(f=i,g=j)−P(f=i)P(g=j)|` y es `≤ 1` |
| `abs_cov_le`, `abs_integral_mul_sub_le_alphaCoef` | **desigualdad de covarianza**: `|Cov(u∘f, v∘g)| ≤ 2‖u‖∞‖v‖∞α` |
| `abs_gamma_le` | proceso centrado y estacionario: `|γ(k)| ≤ 2‖val‖∞²α(k)` |
| `summable_abs_gamma`, `summable_abs_gamma_of_rpow` | si `∑α(k)^{δ/(2+δ)} < ∞` (y `0≤α≤1`, `δ>0`) entonces `∑|γ(k)| < ∞`; `σ²_LR = γ(0)+2∑_{k≥1}γ(k)` bien definida |
| `doble_suma_eq` | `∑_{i,j<n} g(|i−j|) = n g(0) + 2∑_{k<n}(n−1−k)g(k+1)` |
| `tendsto_average_doble` | **lema de Bernstein**: `|g(k)|≤Cρ^k`, `0≤ρ<1` ⇒ `n⁻¹∑_{i,j<n}g(|i−j|) → g(0)+2∑_{k≥1}g(k)` |
| `variance_eq_doble`, `tendsto_variance_div` | `Var(∑_{t<n}X_t)/n → σ²_LR` con tasa geométrica |
| `alphaRect_le_alphaSum`, `alphaRect_le_alphaCoef` | **fidelidad**: el `sup_{A,B}` del libro (rectángulos de átomos) está dominado por el coeficiente formal |
| `abs_integral_prod_sub_prod_le` | **independencia asintótica de bloques**: `|E∏_{j<k}u_j(Z_j) − ∏_{j<k}E u_j(Z_j)| ≤ 2B^k∑_{j<k}a_j` bajo `α(σ(Z_0..Z_{j−1}), σ(Z_j)) ≤ a_j` |

Esto cubre la parte "varianza / Lindeberg" del teorema y la sumabilidad de
autocovarianzas bajo la hipótesis del libro. **El teorema del libro no se enuncia
como cerrado**: falta el paso al límite.

### 1.2 Deuda (a): desigualdad de Davydov con momento `2+δ`

El libro sólo pide `E|X_t|^{2+δ} < ∞`; lo verificado usa `‖X‖∞ < ∞` (estado
finito). La cota general es `|γ(k)| ≤ C α(k)^{δ/(2+δ)}‖X‖_{2+δ}²`.

Qué falta exactamente:
1. Interpolación de momentos `‖X‖_{2+δ} ≤ ‖X‖_p^{…}‖X‖_q^{…}` y desigualdad de
   Hölder con exponentes conjugados aplicadas a `∫ ‖f·g‖` — no están empaquetadas
   como lema de covarianza (hay `MeasureTheory.MemLp`, `eLpNorm`, `lintegral`).
2. Truncación `X^M = X·1{|X|≤M}` y convergencia del término de cola
   `E|X|²1{|X|>M} → 0`.
3. Optimización del corte en función de `α(k)` (elección `M = M(α(k))`).

### 1.3 Deuda (b): bloqueo de Bernstein (independencia asintótica de bloques)

Para concentrar `(1/√n)∑_{t≤n}X_t` en bloques grandes de tamaño `p` separados por
huecos `q` se necesita, para funciones características de bloques,
`|E∏_{j≤k} f_j − ∏_{j≤k} E f_j| ≤ 2k α(q) ∏‖f_j‖∞`.

**Parcialmente cerrado**: `abs_integral_prod_sub_prod_le` prueba exactamente esa
desigualdad (forma `2B^k∑_j a_j`) para funciones **reales** acotadas de bloques,
a partir de la hipótesis `α(σ(Z_0,…,Z_{j−1}), σ(Z_j)) ≤ a_j` (coeficiente del
bloque pasado completo contra el siguiente).

Qué falta exactamente:
1. **Subaditividad de α sobre joins** de σ-álgebras finitas
   (`α(∨_{i<j}σ(Z_i), σ(Z_j)) ≤ ∑_{i<j} α(σ(Z_i),σ(Z_j))`), que es lo que permite
   descargar esa hipótesis desde los coeficientes por pares. No está en Mathlib ni
   en este archivo.
2. Versión **ℂ-valuada** de la desigualdad de covarianza y del lema de bloques
   (este archivo los prueba sólo para `ℝ`; para ℂ la misma prueba va con `‖·‖`,
   pero no está hecha), que es la que se aplica a `exp(i t B_j)`.
3. `charFun` de sumas de variables **dependientes**: Mathlib sólo da el producto de
   funciones características en el caso iid
   (`ProbabilityTheory.charFun_inv_sqrt_mul_sum`,
   `Mathlib/Probability/CentralLimitTheorem.lean:44`).

### 1.4 Deuda (c): resto de Taylor de orden `2+δ`

Mathlib tiene `taylor_charFun_two` y `taylorWithinEval_charFun_two_zero`
(`Mathlib/MeasureTheory/Measure/CharacteristicFunction/TaylorExpansion.lean:125,150`),
con resto `o(t²)` y segundo momento finito. El argumento de bloques necesita la
cota `|φ(t) − (1 − t²γ(0)/2)| ≤ C|t|^{2+δ}E|X|^{2+δ}` para que la acumulación de
restos sobre `k` bloques de tamaño `p` sea despreciable cuando `p·k ≈ n` y
`p/k → 0`; esa cota (y su encadenamiento con el lema de Bernstein) no está.

### 1.5 Lo que sí existe (para no sobreestimar la deuda)

* Continuidad de Lévy: `ProbabilityMeasure.tendsto_iff_tendsto_charFun`
  (`Mathlib/MeasureTheory/Measure/LevyConvergence.lean:215`). Es decir, el paso
  "convergencia de funciones características ⇒ convergencia en distribución" ya
  está resuelto en Mathlib; la deuda es el análisis de bloques con α-mixing.
* CLT iid: `tendstoInDistribution_inv_sqrt_mul_sum_sub`
  (`Mathlib/Probability/CentralLimitTheorem.lean:124`).

### 1.6 Estimación del trabajo restante

≈ 450–700 líneas: α para ℂ y versión ℂ del telescopaje (≈120), subaditividad sobre
joins (≈80), bloqueo con huecos (≈150), Taylor `2+δ` y pegado (≈250), más el caso
no acotado (≈150). Ninguna obstrucción de principio; es volumen de análisis, no falta de
infraestructura crítica (salvo 1.2/1.3.1/1.4, que hay que construir).

---

## 2. `C.thm:appD-gordin` — CLT funcional (martingala, `D[0,1]` Skorokhod)

Estado: **deuda externa declarada**. La claim no se cierra. El argumento interno
del libro está formalizado en `verificacion_lean/Book/GordinCoreM8.lean` y
auditado; lo que falta no es volumen de análisis dentro del modelo del libro,
sino (i) una hipótesis que el modelo formal **no** tiene y (ii) infraestructura
que la Mathlib instalada no tiene. Las dos cosas se detallan abajo por separado
porque tienen remedios distintos.

### 2.1 Verificado mecánicamente

`Book/GordinCoreM8.lean` compila con la Mathlib instalada (Lean 4.35.0) y sus
declaraciones dependen sólo de `{propext, Classical.choice, Quot.sound}`
(0 `sorryAx`; auditoría propia en
`.ultramath/smwa5izeq/m1/work/AuditGordin.lean`):

| Declaración | Contenido |
|---|---|
| `Chain.poisson_solution` | si `π(f)=0` hay `h` centrada con `f = h - P h` (principio del máximo + `Q = I - P + π(·)1` invertible) |
| `Chain.gordin_decomposition` | la identidad telescópica del libro, literal, para toda trayectoria |
| `Chain.boundary_abs_le`, `Chain.tendsto_boundary_div_sqrt` | el término de borde es `≤ 2∑_y|h y|`, luego `o(1)` tras dividir por `√n` |
| `Chain.martIncrement`, `Chain.martSum`, `Chain.martIncrement_cond_mean` | el incremento es una diferencia de martingala (media condicional nula) |
| `Chain.condVar`, `Chain.sigmaSq`, `condVar_nonneg`, `sigmaSq_nonneg` | `v(x) = ∑_y P_xy (h y - P h x)²` y `σ² = π(v)`, con `σ² ≥ 0` |
| `Chain.bracket_poisson`, `Chain.bracket_decomposition` | **segunda** ecuación de Poisson para `v - σ²` y su telescopaje |

**Corrección de fidelidad (nueva).** El docstring del módulo anunciaba además
`Chain.cesaro_condVar` («la variación cuadrática condicional normalizada
converge … con tasa `O(1/n)`»). Esa declaración **no existe**: `rg -n
cesaro_condVar` da una única aparición en todo el repositorio, la del propio
docstring (línea 41), y `#check @Chain.cesaro_condVar` falla con
`unknown constant` (`.ultramath/smwa5izeq/m1/evidence/phantom-cesaro.txt`).
Además, tal como estaba redactada («para toda trayectoria») es falsa: una
trayectoria constante `s ≡ x` da el promedio `v(x)`, que no es `σ²` salvo que
`v` sea constante `π`-c.s. La condición de bracket correcta es c.s. (o Cesàro
a lo largo de trayectorias genéricas); su prueba necesita un LGN de
martingalas, que no está. Es el único paso *interno* del libro que ni está
formalizado ni es elemental con estado finito.

### 2.2 La identificación `σ² = ∑_k Cov(f(S_0), f(S_k))` no se sigue de `Chain`

El enunciado del libro (`book_stat_inference_v0/apendices/apendice_regularidad.typ:137`)
pide **cadena finita irreducible y aperiódica**. La estructura `Chain` de
`GordinCoreM8.lean` no incluye aperiodicidad (su docstring (iii) lo declara, y
es correcto para los pasos de §2.1). Para la identificación de `σ²` eso no es
inocuo: **sin aperiodicidad el enunciado es falso**, no meramente difícil.

Contraejemplo formalizado en `.ultramath/smwa5izeq/m1/GordinPeriodico.lean`
(compila, axiomas ⊆ `{propext, Classical.choice, Quot.sound}`): la cadena de
dos estados `P x y = 1` si `y ≠ x`, `π = (1/2,1/2)`, observable `f = (1,-1)`.

* satisface **todos** los campos de `Chain` (estocástica, `π` invariante,
  irreducible por alcanzabilidad) — es la cadena periódica de período 2;
* la solución de Poisson centrada es `h = (1/2,-1/2)` y
  `σ² = π(condVar h) = 0` (`sigmaSq_hPer`);
* `γ(k) = ∑_x π_x f(x)(P^k f)(x) = (-1)^k` (`gamma_fPer`), luego
  `∑_k γ(k)` **no converge** (`not_summable_gamma`): el término general no
  tiende a 0;
* teorema `contraejemplo_periodico`: existen `D`, `f`, `h` con
  `D.avg f = 0`, `D.avg h = 0`, `f = h - P h`, `D.sigmaSq h = 0`,
  `∀ k, γ(k) = (-1)^k` y `¬ Summable γ`;
  `identificacion_falla` lo especializa: lado izquierdo `0`, lado derecho
  indefinido.

Consecuencia operativa: cerrar esa pieza exige **añadir al modelo** o bien
aperiodicidad (la hipótesis del libro: `{n : (P^n)(x,x) > 0}` con mcd 1 para
todo `x`), de la que se sigue en dimensión finita un decaimiento geométrico
`|(P^k f)(x)| ≤ C ρ^k`, o bien esa cota como hipótesis explícita. Con ella el
camino es corto y no depende de nada ausente en Mathlib:
`h = ∑_k P^k f` (serie geométrica de operadores), `h - P h = f`,
`σ² = ⟨h,h⟩ - ⟨Ph,Ph⟩ = 2⟨f,h⟩ - ⟨f,f⟩ = γ(0) + 2∑_{k≥1} γ(k)`
(producto interno `⟨u,v⟩ = ∑_x π_x u_x v_x` y Cauchy–Schwarz de `Finset`).
Mientras la hipótesis no exista en `Chain`, **la claim no debe enunciarse**.

La **parte algebraica** de esa cadena, la que *no* necesita ninguna hipótesis
adicional, ya está formalizada y auditada en
`.ultramath/smwa5izeq/m1/GordinSigmaAlgebra.lean` (axiomas dentro de
`{propext, Classical.choice, Quot.sound}`, 0 `sorry`, Lean 4.35.0), para toda
`Chain` y toda `h`: `sigmaSq_eq` prueba `σ² = ⟨h,h⟩ - ⟨Ph,Ph⟩` y
`sigmaSq_eq_two_avg` prueba `σ² = 2⟨f,h⟩ - ⟨f,f⟩` bajo la ecuación de Poisson.
Queda la representación en serie y la telescopía de las covarianzas.

### 2.3 Lo que falta en la Mathlib instalada (Lean 4.35.0)

Evidencia reproducible: `.ultramath/smwa5izeq/m1/evidence/probe_mathlib_435.sh`
(salida en `probe.out`). Recuento de ficheros `.lean` que mencionan el término:

| Pieza necesaria | Estado en `/opt/mathlib` (4.35.0) |
|---|---|
| espacio `D[0,1]` de trayectorias càdlàg y su topología (Skorokhod `J₁`, métricas, completitud/separabilidad) | **ausente**: `skorokhod` → 0 ficheros |
| topología sobre el espacio de trayectorias (de cualquier tipo) | **ausente**: ningún módulo la construye; `IsCadlag` no se usa en `Probability/` |
| criterio de tightness para procesos (Aldous / momentos) | **ausente**; sólo el criterio abstracto de conjuntos tight de medidas |
| CLT funcional / de martingalas (Lindeberg para diferencias, bracket, estabilidad) | **ausente**: `lindeberg`, `martingale central`, `invariance principle`, `donsker` → 0 |
| variación cuadrática / bracket predecible `⟨M⟩` | **ausente**: `quadratic variation` → 0 |
| principio de invariancia (Donsker) | **ausente** |

Lo que **sí** hay y se reutilizaría (esto acota la deuda, no la elimina):

* `Topology/Order/Cadlag.lean` (196 líneas): `IsRightContinuous`, `IsCadlag`,
  `IsCaglad` como **predicados de regularidad** (no el espacio ni su topología).
* `MeasureTheory/Measure/Tight.lean`: `IsTightMeasureSet`.
* `MeasureTheory/Measure/Prokhorov.lean` (708 líneas): Prokhorov (tight ⇒
  clausura compacta: `isCompact_closure_of_isTightMeasureSet`; recíproco en
  espacios métricos completos y segundo numerables).
* `MeasureTheory/Measure/LevyProkhorovMetric.lean` (704 líneas): métrica de
  Lévy–Prokhorov sobre `ProbabilityMeasure`, base de la convergencia débil.
* `MeasureTheory/Function/ConvergenceInDistribution.lean` (348 líneas):
  `TendstoInDistribution`, Portmanteau, aplicación continua, Slutsky.
* `Probability/BrownianMotion/` (334 + projective family): `IsPreBrownianReal`,
  `IsBrownianReal` — el **objeto límite** ya se puede enunciar.
* `Probability/Martingale/*`: convergencia a.s. y Lᵖ, upcrossing, parada
  opcional. `Probability/CentralLimitTheorem.lean`: **sólo** CLT 1-D iid.

### 2.4 Corrección de la nota anterior (versión de Mathlib)

La §2 previa decía «obstrucción verificada en Mathlib v4.33.1: `cadlag` → 0
resultados». En la Mathlib **instalada** (Lean 4.35.0, `lean --version`;
`/opt/mathlib/lean-toolchain`) ya hay càdlàg, Prokhorov, Lévy–Prokhorov y
movimiento browniano; mantener la frase anterior induce a duplicar trabajo que
ya no hace falta. Además el repositorio **declara** otra versión:
`verificacion_lean/lean-toolchain` y `lakefile.toml` fijan `v4.33.1`, mientras
`verificar.sh` compila contra la Mathlib del entorno, que es 4.35.0. La deuda
se cita contra 4.35.0 y conviene alinear los pines (o documentar que es
deliberado) para que el próximo `lake build` no cambie el conjunto de módulos.

### 2.5 Estimación del trabajo restante

Ya no es «CLT funcional de martingalas completo»: es

1. `D[0,1]` + topología `J₁` (métricas de Skorokhod, completitud,
   separabilidad, continuidad de la evaluación) — **≈ 1200–2000 líneas**; es
   el trozo dominante y no depende de nada de probabilidad.
2. Criterio de tightness en `D` (Aldous, vía desigualdad maximal de martingala
   acotada) — **≈ 300–500 líneas**, reutilizando Prokhorov.
3. CLT de martingalas para las distribuciones finito-dimensionales
   (funciones características de sumas dependientes + continuidad de Lévy) —
   **≈ 500–900 líneas**.
4. Identificación del límite como `σW` (cierre del f.d.d. a ley en `D`) —
   **≈ 200–400 líneas**.
5. `σ² = γ(0) + 2∑_{k≥1} γ(k)` con aperiodicidad añadida a `Chain`. La parte
   algebraica **ya está hecha** (`GordinSigmaAlgebra.lean`: `sigmaSq_eq`,
   `sigmaSq_eq_two_avg`); queda la representación `h = ∑_k P^k f` (sumabilidad
   geométrica, `h - Ph = f`, `π(h) = 0`) y la telescopía
   `⟨f,h⟩ = ∑_k γ(k)` — **≈ 100–150 líneas**. *Muy por debajo* de lo estimado
   antes, porque no necesita nada de lo anterior (ver §2.2).

Orden recomendado: primero 5 (cierra una pieza real y fija la hipótesis
correcta), después 1, luego 3, 4, 2.

### 2.6 Lo que no se toca

No se modifica `argumentos/kernel/{libro_completo,pendientes}.json` en esta
deuda: `C.thm:appD-gordin` **no** se cierra. Los artefactos verificables son
`verificacion_lean/Book/GordinCoreM8.lean`, `.ultramath/smwa5izeq/m1/GordinPeriodico.lean`,
`.ultramath/smwa5izeq/m1/GordinSigmaAlgebra.lean` y las auditorías citadas.

Nota de integración: los dos ficheros nuevos viven hoy en
`.ultramath/smwa5izeq/m1/`, que está ignorado por git. Si se quieren conservar
en el repositorio, el destino natural es `verificacion_lean/Book/`
(`GordinPeriodico.lean` y `GordinSigmaAlgebra.lean`, ambos `import
GordinCoreM8`) y añadirlos a la lista de módulos de `verificar.sh` antes de
`Book/Audit.lean`; ninguno de los dos requiere `sorry` ni axiomas fuera de
`{propext, Classical.choice, Quot.sound}`.

---

## 3. `C.thm:appD-hac-consistencia` — consistencia del estimador HAC

La conclusión del libro es `σ̂²_HAC →^P σ²_LR` bajo `K_n→∞`, `K_n/n→0` y la
condición agregada `∑_{k≤K_n}|γ̂_k − γ_k| →^P 0`.
Obstrucción precisa: Mathlib tiene `TendstoInMeasure` (la noción de convergencia
en probabilidad) y la LGN iid (`Mathlib/Probability/StrongLaw.lean`), pero **no**
una LGN para sucesiones α-mixing/ergódicas, que es la única vía para descargar la
condición agregada desde las hipótesis del proceso. Sin esa LGN, la alternativa
honesta es la versión **determinista**: cotas explícitas
`|σ̂²_HAC − Σ_{k≤K} w(k/K)γ_k| ≤ b_T(2K+1)` más cola y sesgo de ponderación
(la dirección d2 del enjambre trabaja esta fidelidad). El teorema del libro, tal
cual (con `→^P`), no se formaliza sin la LGN de mixing.

---

## 4. `C.thm:appD-ergodico` y `C.cor:appD-mdp-finito`

Fuera del alcance de este documento (los cubren sus propios archivos). El lema
`abs_gamma_le` de este entregable es reutilizable para el paso
`β-mixing ≤ sup_x ‖P^k(x,·)−π‖_TV` y para el cálculo de `σ²_LR` del corolario MDP.

---

## 5. Nota para el kernel y los recibos

No se modifican `argumentos/kernel/{libro_completo,pendientes}.json` ni
`argumentos/receipts/`: la claim `C.thm:appD-ibragimov` **no** se cierra. Si el
coordinador quiere registrar el avance parcial, el artefacto verificable es
`verificacion_lean/Book/ApendiceDIbragimov.lean` + `verificacion_lean/AuditIbra.lean`
(compilación directa con `lean` y `LEAN_PATH` del entorno; sin `lake build`).
