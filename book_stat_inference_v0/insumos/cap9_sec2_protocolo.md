# Insumo A — Cap. 9 §2: el protocolo paso a paso

**Fecha:** 2026-10-02 · **Estado:** outline / pasos / preguntas · **AUTONOMIA 2026-10-02**  
**Tipo:** A — **no** prosa de contribución del capítulo.  
**Capítulo destino:** `capitulos/cap09_verificacion.typ` (`<ch:verificacion>`).  
**Arco:** protocolo operativo de verificación de una garantía heredada (sigue a §1 / `insumos/cap9_sec1_auditar_garantia.md`).

---

## 1. Objetivo de §2

Convertir el problema abierto en §1 («¿qué significa auditar una garantía?») en un **protocolo operativo numerado**: dada una garantía estadística que el libro afirma transferir vía $F:\mathbf{Dec}\to\mathbf{MDP}_1$, el lector debe poder (i) localizarla en `tab:trazabilidad-canonica`, (ii) listar condiciones / CSE, (iii) asignar estado `↔` / `↝` / `—`, (iv) comprobar verificabilidad en despliegue y (v) degradar o documentar evidencia si falla un paso.

§2 **no** rellena filas de la canónica ni escribe la prosa del hilo narrativo; fija el *checklist* que esa prosa deberá narrar.

---

## 2. Esqueleto paso a paso (revisado SuperGrok 2026-10-02 · 8 pasos · 1 frase guía)

0. **Registrar origen canónico.** Anotar identificador del teorema/garantía fuente (label vivo + clave bib si aplica) y **versión del artefacto** (fecha del manuscrito / hash de commit o del PDF de sesión). Sin este ancla, las filas de `tab:trazabilidad-canonica` quedan huérfanas de origen.
1. **Nombrar resultado / label.** Identificar el `thm:` / `cor:` / `prop:` / `def:` vivo que se audita (p. ej. `@thm:ch9-isomorfismo`, `@thm:ch9-secuencial`) — coherente con el paso 0.
2. **Localizar fila en `tab:trazabilidad-canonica`.** Buscar la fila cuyo label coincide; si no hay fila → registrar deuda (barrido FALTA) y no inventar celda.
3. **Listar condiciones / CSE.** Extraer la columna Condiciones; si aparece `CONDICIONES SIN ESPECIFICAR`, no rellenar — anotar CSE y seguir.
4. **Asignar estado `↔` / `↝` / `—`.** Usar las definiciones de `insumos/cap9_columnas.md` (fiel / analogía frágil / sin clasificar); default actual de la canónica = `—` hasta decisión autor.
5. **Verificar en despliegue → degradar si no verificable.** Una sola casilla operativa con dos sub-casillas binarias: (5a) ¿cada condición es observable/testable en el contexto de uso (puente cap. 11 / labs)? (5b) si alguna es **no** → bajar a `↝` o mantener CSE y remitir a §3 / `@ch:fallos` (cap. 6), sin pérdida «en silencio».
6. **Documentar evidencia.** Apuntar a demostración, tabla fuente, ficha de literatura o comentario `AUTONOMIA` que sostiene el juicio (no citar DOI no leídos).
7. **Cerrar fila + hash de evidencia.** Marcar la fila de `tab:trazabilidad-canonica` como *cerrada* en el sentido del protocolo (estado ≠ pendiente de juicio) y registrar un **hash/id de evidencia** (ruta+fecha del artefacto del paso 6, o digest corto). Hace el checklist verificable por máquina.
8. **Cierre checklist.** Confirmar: origen (0) · label · fila canónica · condiciones · estado · (5a)/(5b) · evidencia · fila cerrada+hash. Si falta alguno → el protocolo queda *abierto*, no «aprobado».

> Ajuste SuperGrok (APLICAR-ahora, 2026-10-02): paso 0 nuevo; antiguos 5+6 fusionados en 5; paso 7 = cierre de fila+hash; se **descarta** cualquier paso de «escribir justificación textual» / párrafo de interpretación (viola insumo A).

---

## 3. Anclas del manuscrito (reuso §1 + protocolo)

| Label | Rol en §2 |
|---|---|
| `ch:verificacion` | Capítulo anfitrión |
| `tab:trazabilidad-canonica` | Destino del paso 2 |
| `thm:ch9-isomorfismo` | Ejemplo canónico de resultado a auditar |
| `fig:ch9-incrustacion-dec-mdp` | Diagrama de correspondencias (cap. 5; iteración Vie 2) |
| `thm:ch9-secuencial` | Ejemplo de extensión (aún **FALTA** en canónica) |
| `def:ch9-wald` / `def:ch9-mdp` | Marcos Dec / MDP |
| `note:ch9-extension-no-demostrada` | Límite de alcance al degradar (paso 5b) |
| `ch:isomorfismo` | Origen de la incrustación |
| `ch:fallos` | Puente degradación / mecanismos de fallo |
| Estado `↔` / `↝` / `—` | Salida del paso 4 (ajustable en 5b) |
| `insumos/cap9_columnas.md` | Definiciones operativas de columnas / estados |
| `insumos/cap9_sec1_auditar_garantia.md` | Problema que §2 operacionaliza |
| `BARRIDO_GARANTIAS_CANONICA_2026-10-01.md` | Inventario OK41 / FALTA28 para paso 2 |

---

## 4. Preguntas abiertas para el autor

1. ¿§2 debe numerar los 8 pasos como lista tipográfica en el capítulo, o como subsecciones `§2.1`…`§2.8`?
2. ¿El protocolo se ilustra con **un** walkthrough completo (p. ej. isomorfismo) o con **tres** mini-ejemplos (`↔` / `↝` / FALTA)?
3. ¿El paso 5 (verificar→degradar) remite ya a plantillas del cap. 11, o queda abstracto hasta que cap. 11 tenga prosa? ¿El «hash de evidencia» del paso 7 es ruta+fecha o digest git?
4. ¿Quién puede marcar `↔` en una fila: solo el autor, o el agente con evidencia textual del `#thm-env` (como en CSE_RESOLUCION)?
5. ¿Integramos Prudencio et al. (ficha abajo) como lectura de contraste («taxonomía de problemas offline → ítems del protocolo»), o queda solo en `LITERATURA_2022_2026.md`?

---

## 5. Ficha breve OA + S2 — protocolos / taxonomía de evaluación en offline RL (2022–2026)

### Prudencio, Máximo & Colombini (2023) — *A Survey on Offline Reinforcement Learning: Taxonomy, Review, and Open Problems*

| Campo | Valor |
|---|---|
| **Cita** | Prudencio, R. F., Máximo, M. R. O. A., & Colombini, E. L. (2023). A Survey on Offline Reinforcement Learning: Taxonomy, Review, and Open Problems. *IEEE Transactions on Neural Networks and Learning Systems*. |
| **DOI** | 10.1109/TNNLS.2023.3250269 |
| **OpenAlex** | W4360584316 |
| **Semantic Scholar** | `61e7a3d5606043594a8ce377870479f77a6b58c2` |
| **Año / venue** | 2023 (registro S2 también lista 2022 preprint) · IEEE TNNLS · ~356 citas OA / ~454 S2 al 2026-10-02 |
| **arXiv** | 2203.01387 |
| **OA PDF** | vía IEEE / arXiv `https://arxiv.org/abs/2203.01387` |

#### Abstract (leído vía OA + S2; no inventado)
El survey constata el auge del RL profundo y los dominios donde interactuar con el ambiente es costoso o peligroso. El **offline RL** aprende solo de datasets estáticos de interacciones previas; los autores proponen una **taxonomía**, revisan métodos y enumeran **problemas abiertos** (incl. evaluación y supuestos de los datos).

#### Supuesto / ángulo clave (para el libro)
Distinto de Landers & Doryab (2023, verificación formal de DRL): aquí el foco es la **taxonomía de supuestos y huecos de evaluación** del paradigma offline. Para §2 aporta contraste: un protocolo de auditoría de garantías estadísticas debe recorrer, de forma explícita, las mismas zonas grises que el survey marca como open problems (datos, evaluación, supuestos), sin confundirlas con certificación formal de la política.

#### Qué garantiza / qué exige (según abstract)
- Garantiza (en el sentido del survey): un mapa organizado del área offline RL y una lista de problemas abiertos.  
- Exige: datasets estáticos y aceptación de límites del paradigma; **CONDICIONES SIN ESPECIFICAR** a nivel del catálogo del libro hasta lectura sección-a-sección del PDF.

#### Encaje
- Cap. **9 §2**: ítems del protocolo ↔ taxonomía de supuestos/evaluación.  
- Caps. **7–8**: OPE / intervalos como instancia de «evaluación offline».  
- Cap. **11**: despliegue / verificabilidad.  
- **No** añadido a `referencias.bib` hoy.

#### Estado
- [x] Ficha OA+S2  
- [ ] PDF completo / hipótesis detalladas  
- [ ] Entrada `.bib`  
- [ ] Integración editorial en §2  

**Nota de búsqueda:** se exploró también Patterson et al., *Empirical Design in Reinforcement Learning* (arXiv:2304.01315, OA W4362655362) — muy afin al ángulo «protocolo empírico» — pero Semantic Scholar devolvió HTTP 429 al resolver `paperId`; se priorizó Prudencio por IDs OA+S2 completos y verificados hoy. Candidato a ficha futura cuando S2 responda.

---

## 6. Qué no hace este insumo

- No escribe prosa de contribución del cap. 9.  
- No retira el `#pendiente` de «veinte tablas».  
- No edita la canónica ni rellena Estados.  
- No toca `dem:ch4-wilks` ni `intro.typ:89`.  
- No añade `.bib`.

**AUTONOMIA 2026-10-02:** protocolo en 8 pasos (+paso 0; 5+6 fusionados; cierre fila+hash vía SuperGrok) + ficha Prudencio ante silencio del autor en prosa de §2.
