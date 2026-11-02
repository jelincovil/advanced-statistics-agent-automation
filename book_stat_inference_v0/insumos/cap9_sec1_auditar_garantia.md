# Insumo A — Cap. 9 §1: el problema de auditar una garantía

**Fecha:** 2026-10-01 · **Estado:** outline / bullets / preguntas · **AUTONOMIA 2026-10-01** (el autor no entregó prosa de §1).  
**Tipo:** A — **no** prosa de contribución del capítulo.  
**Capítulo destino:** `capitulos/cap09_verificacion.typ` (`<ch:verificacion>`).  
**Arco:** verificación de garantías + incrustación fiel (cap. 5 / `@thm:ch9-isomorfismo`).

---

## 1. Objetivo de §1

Abrir el capítulo de verificación planteando **qué significa auditar una garantía** transferida por la incrustación $F:\mathbf{Dec}\to\mathbf{MDP}_1$: no basta citar un teorema; hay que (i) nombrar el resultado, (ii) listar condiciones, (iii) decidir el estado de transferencia (`↔` / `↝` / `—`) y (iv) comprobar que la fila existe en la tabla canónica `tab:trazabilidad-canonica`.

Problema que abre el cap.: *una garantía estadística heredada por el agente es una afirmación condicional; auditarla es calcular si las condiciones siguen siendo verificables en el despliegue.*

---

## 2. Esqueleto de secciones / párrafos (títulos + 1 frase guía)

### §1.1 ¿Qué se audita cuando se dice «hay garantía»?
Frase guía: Distinguir el **resultado** (label `thm:`/`cor:`/`prop:`), la **garantía operativa** (columna Garantía) y las **condiciones** (incl. `CONDICIONES SIN ESPECIFICAR`).

### §1.2 De la incrustación fiel al cálculo de herencia
Frase guía: Remitir a `@thm:ch9-isomorfismo` y a `@fig:ch9-incrustacion-dec-mdp`: la auditoría empieza cuando $F$ dice qué se preserva (Bayes / minimax / admisibilidad) y bajo qué alcance (un paso, determinista).

### §1.3 La tricotomía de estado: `↔` / `↝` / `—`
Frase guía: Usar las definiciones operativas de `insumos/cap9_columnas.md` — `↔` transferencia fiel bajo condiciones; `↝` analogía / extensión frágil; `—` sin clasificar — sin inventar relleno de filas.

### §1.4 Por qué hace falta una tabla canónica
Frase guía: Motivar `tab:trazabilidad-canonica` frente a las tablas superpuestas aún presentes en el archivo; el `#pendiente` de «veinte tablas» queda como deuda de redacción (inventario = 13).

### §1.5 Primer síntoma de fallo de auditoría
Frase guía: Anticipar (sin prosa larga) el puente al cap. 6 / cap. 11: cuando una condición no es verificable, la garantía no se «pierde en silencio» — se marca y se degrada el estado (`↝` o CSE).

---

## 3. Anclas del manuscrito a citar (labels reales)

| Label | Rol en §1 |
|---|---|
| `ch:verificacion` | Capítulo anfitrión |
| `tab:trazabilidad-canonica` | Tabla canónica (98 filas) |
| `thm:ch9-isomorfismo` | Funtor fiel $F:\mathbf{Dec}\to\mathbf{MDP}_1$ (cap. 5) |
| `fig:ch9-incrustacion-dec-mdp` | Diagrama CeTZ borrador (2026-10-01) |
| `def:ch9-wald` | Marco Dec (Wald) |
| `def:ch9-mdp` | Marco MDP |
| `note:ch9-extension-no-demostrada` | Límite de alcance (no extender garantías) |
| `thm:ch9-secuencial` | Extensión horizonte $T$ (aún **FALTA** en canónica — ver barrido) |
| `ch:isomorfismo` | Capítulo de la incrustación |
| `isoto` (`<->` en plantilla) | Símbolo de correspondencia objeto-a-objeto |
| Estado `↔` / `↝` / `—` | Columna Estado de la canónica (catálogo del libro; ver `insumos/cap9_columnas.md`) |

Defs de pérdida/riesgo / valor útiles como remisión, no como núcleo de §1: `def:ch1-perdida-riesgo`, correspondencia $Risk \leftrightarrow -Value$ en la tabla del teorema.

---

## 4. Preguntas abiertas para el autor

1. ¿§1 debe abrir **antes** o **después** del `#include` de la canónica en `cap09_verificacion.typ` (hoy la canónica está al inicio, sin andamiaje)?
2. ¿El lector de §1 ya vio cap. 5, o hay que repetir en una frase el alcance «un paso / determinista»?
3. ¿Quieres que §1 nombre explícitamente el `#pendiente` de las «veinte tablas», o solo remitir a la canónica ya construida?
4. Para el estado `↔`/`↝`: ¿§1 solo define la tricotomía, o ya clasifica 2–3 filas ejemplo (p.ej. isomorfismo / DR / Shi)?
5. ¿Integramos la ficha Landers & Doryab (abajo) como lectura de contraste (verificación DRL formal vs. auditoría estadística de este libro), o queda solo en literatura?

---

## 5. Ficha breve OA + S2 — auditing / verifying guarantees in RL (2022–2026)

### Landers & Doryab (2023) — *Deep Reinforcement Learning Verification: A Survey*

| Campo | Valor |
|---|---|
| **Cita** | Landers, M., & Doryab, A. (2023). Deep Reinforcement Learning Verification: A Survey. *ACM Computing Surveys*. |
| **DOI** | 10.1145/3596444 |
| **OpenAlex** | W4372353038 |
| **Semantic Scholar** | `0860b142a9e6c71974ffbbcb291f5d09d4b48142` |
| **Año / venue** | 2023 · ACM Computing Surveys · ~50 citas (S2 al 2026-10-01) |
| **arXiv** | No listado en S2/OA para este registro |
| **OA PDF** | https://dl.acm.org/doi/pdf/10.1145/3596444 (vía OpenAlex `oa_url`) |

#### Abstract (leído vía OA + S2; no inventado)
Los autores encuestan métodos que **verifican** sistemas de deep RL: no basta el rendimiento óptimo empírico; en dominios de alto coste hace falta asegurar robustez, estabilidad o seguridad. Los algoritmos de verificación pueden garantizar propiedades sobre un conjunto infinito de entradas, con trade-offs de alcance y supuestos de modelado.

#### Supuesto / ángulo clave (para el libro)
La literatura de *DRL verification* certifica propiedades del **sistema/política** (safety, reachability, etc.). El cap. 9 de este libro audita **garantías estadísticas transferidas** (cobertura, DR, admisibilidad) vía condiciones de la incrustación — problema hermano, no idéntico.

#### Qué garantiza / qué exige (según abstract)
- Garantiza (en el sentido del survey): procedimientos que *pueden* asegurar propiedades sobre infinitos inputs.  
- Exige: formulaciones verificables del agente/política y aceptación de límites de los métodos actuales (el abstract enfatiza el surgimiento del área y sus restricciones; **CONDICIONES SIN ESPECIFICAR** a nivel de catálogo del libro hasta lectura de secciones concretas).

#### Encaje
- Cap. **9 §1**: contraste «verificar propiedad del agente» vs. «auditar herencia de garantía estadística».  
- Cap. **11**: puente a despliegue.  
- **No** añadido a `referencias.bib` hoy (solo ficha; abstract leído vía API, no PDF completo sección-a-sección).

#### Estado
- [x] Ficha OA+S2  
- [ ] PDF completo / hipótesis detalladas  
- [ ] Entrada `.bib`  
- [ ] Integración editorial en §1  

---

## 6. Qué no hace este insumo

- No escribe prosa de contribución del cap. 9.  
- No retira el `#pendiente` de «veinte tablas».  
- No edita la canónica.  
- No toca `dem:ch4-wilks` ni `intro.typ:89`.

**AUTONOMIA 2026-10-01:** outline + ficha entregados ante silencio del autor en prosa de §1.
