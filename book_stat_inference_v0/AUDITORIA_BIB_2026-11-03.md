# AUDITORÍA EXPRESS `referencias.bib` — 2026-11-03

**Origen:** PLAN M-30D, día 2. **Alcance:** informe, sin correcciones.
**Método:** parseo estructural del `.bib`; extracción de claves citadas en
todos los `.typ` (formas `#cite(<clave>)` y `@clave`, excluidas las
referencias cruzadas `@thm:`, `@ch:`, …); cobertura de verificación buscada en
**todos** los documentos de trabajo del repo (`LITERATURA_2022_2026.md`,
`FUENTES.md`, `BIBLIOGRAFIA_COMENTADA_PARTE_III/IV.md`, `AUDITORIA_FASE1.md`,
`INFORME_FASE1.md`, `CORRECCIONES_H01_H60.md`, insumos). Todo número de este
informe es reproducible con un comando sobre el repositorio.

---

## 1. Resumen

| Chequeo | Resultado |
|---|---|
| Entradas `.bib` | **130**, sin claves duplicadas, sin entradas sin año |
| DOI malformados (no `10.*`) | **0** |
| Citas rotas en el manuscrito | **0** (consistente con `typst compile` exit 0 sin advertencias del día 1) |
| Entradas no citadas en el cuerpo | 87 (informativo; esperado tras la fusión 13→12 capítulos y las listas de lectura) |
| Entradas 2022–2026 | **19**, en tres niveles de verificación (§2) |

## 2. Literatura 2022–2026: niveles de verificación registrada

**Nivel A — verificada en fuente primaria con artefacto propio (3):**
- `shi2022statistical` — `FUENTES.md`: verificada contra el PDF del artículo
  (paginación, DOI, método SAVE, apéndices).
- `shi2024off` — ficha completa en `LITERATURA_2022_2026.md` (COPE; DOI,
  arXiv, identificadores OA/S2, hipótesis leídas).
- `kallus2022efficiently` — registrada en `BIBLIOGRAFIA_COMENTADA_PARTE_III/IV`.

**Nivel B — mencionada en auditorías/informes previos, nivel de verificación
por precisar al incorporarla (8):**
`kennedy2022semiparametric` (INFORME_FASE1, AUDITORIA_FASE1) ·
`langchain2024` · `yao2023react` · `wang2024survey` · `shinn2023reflexion` ·
`wang2024llm` · `liu2023agentbench` · `pydantic2024`
(todos en AUDITORIA_FASE1; esa campaña era de integridad global de la
bibliografía —sin inventos ni completados—, no una ficha por obra).

**Nivel C — sin rastro de verificación documentada (8):**
`langgraph2024` · `zhou2025demystifying` · `miao2022off` ·
`liu2023asymptotically` · `mehrabi2024off` · `bennett2024efficient` ·
`huang2025robust` · `li2025testing`.

> Criterio aplicado: "rastro" = la clave aparece literalmente en algún
> documento de verificación del repo, o la obra casa con una ficha de
> `LITERATURA_2022_2026.md` por (primer autor, año). No se afirma que las
> entradas de nivel C estén mal: se afirma que no hay registro de su
> verificación.

## 3. Conclusión y pendientes

1. **La integridad referencial está sana:** 0 citas rotas, 0 duplicados,
   0 DOI anómalos; coherente con la compilación limpia y con las campañas
   previas (AUDITORIA_FASE1 2026-09-22, correcciones H01–H60 desde 2026-10-29).
2. **Para M, protocolo operativo:** toda obra 2022–2026 entra a
   `referencias_M.bib` solo con ficha en `monografia_M/fichas/` (nivel A) o
   re-verificación por ficha nueva si hoy está en nivel B o C. Las 8 de nivel
   C son las primeras de la cola si M las necesita.
3. **Patrón a conservar:** el de `FUENTES.md` (referencia completa + DOI +
   qué se verificó contra el PDF) para toda fuente primaria clave de M.
4. Fuera de alcance express: validación de páginas/años contra fuente
   primaria para el resto del `.bib` (se hace por ficha al migrar).

---

# Anexo — reproducción de laboratorios (día 2)

Entorno: venv nueva con `requirements.txt` fijado
(numpy 2.5.3 · scipy 1.18.1 · scikit-learn 1.9.1 · gymnasium 1.3.0 · pandas 3.1.0).
`ejecutar_todos.py` completo: **14/14 exit 0, `stdout` idéntico al registrado,
hashes de scripts idénticos**. Único cambio en `versiones.json`: la cadena
`platform` (kernel del host, de `6.14.0-37` a `7.0.0-31`) — información del
entorno real de ejecución, no deriva de resultados.
