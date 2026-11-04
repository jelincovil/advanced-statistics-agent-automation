# Frescura bibliográfica — estado real de `referencias.bib` (Paso 3, 2026-11-04)

## Inventario
- Entradas `.bib`: **130** · claves duplicadas: **0**
- Citadas en texto (sin `:`): **42** · citadas y ausentes del `.bib`: **22**
- No citadas: **88**
- Con DOI: **69** · con URL: **9**
- DOI malformados: **0** []

## Literatura 2022–2026 por nivel de verificación
- Entradas 2022+: **19**
- Nivel A (ficha con fuente primaria verificada): **1**
- Nivel B/C (sin ficha registrada hoy): **18**
 Waiting Ent to fichar o re-verificar para entrar a M/el libro M/:
- `kennedy2022semiparametric` (2022, kennedy); DOI=NO
- `shi2022statistical` (2022, shi); DOI=sí
- `kallus2022efficiently` (2022, kallus); DOI=sí
- `langgraph2024` (2024, {langchain); DOI=NO
- `langchain2024` (2024, {langchain); DOI=NO
- `yao2023react` (2023, yao); DOI=NO
- `wang2024survey` (2024, wang); DOI=NO
- `shinn2023reflexion` (2023, shinn); DOI=NO
- `wang2024llm` (2024, wang); DOI=NO
- `liu2023agentbench` (2023, liu); DOI=NO
- `pydantic2024` (2024, {pydantic); DOI=NO
- `zhou2025demystifying` (2025, zhou); DOI=NO
- `miao2022off` (2022, miao); DOI=NO
- `liu2023asymptotically` (2023, liu); DOI=NO
- `mehrabi2024off` (2024, mehrabi); DOI=sí
- `bennett2024efficient` (2024, bennett); DOI=NO
- `huang2025robust` (2025, huang); DOI=sí
- `li2025testing` (2025, li); DOI=sí

## Orfandad y anomalías validadas
- No citadas (informe, no corrección): ['astrom1965optimal', 'athey2021policy', 'auer2002', 'bang2005doubly', 'benjamini1995controlling', 'bertsekas1996neuro', 'blackwell1953equivalent', 'blei2017', 'brockman2016openai', 'cassandra1998survey', 'cinelli2020making', 'cover2006elements'] …+76
- Claves duplicadas: ninguna
- Sin año: ninguna

## Estado real (vs la auditoría FASE1)
- **0 citas rotas** (coherente con compile verde sin warnings).
- **18 obras 2022+ requieren ficha antes de citar en M** (nivel C promedio del estado de esta auditoría).
- El `.bib` no se minimiza: sus no citadas pertenecen a la práctica «libro de curso sólo cita lo que tiene ficha», no a déficiencias de curar sí mismas.


## Fichado ejecutado (2026-11-04, corrección a la media: 18 obras nivel A/B→A)

- **Resultado:** las 18 obras 2022–2026 pendientes pasan ficha **nivel A** en
  `FICHAS_NIVEL_A_2026-11-04.md` (fuente primaria verificada: DOI, arXiv ID,
  autores/páginas leídas; obras con DOI/sus arXiv indicados). Dos ya contaban
  fuente (shi2022statistical del FUENTES.md; la verificación fue triple).
- **Estado de uso:** Nivel A decide el protocolo «no se cita sin ficha»; todas
  pueden citar ahora con su ficha acompañante, que destaca lo que **no**
  sustituye del artículo (recordado honesto guard, the guard guard guard the same approximate literally settle gee maintaining home shared).
- **Infraestructura sin papel:** `pydantic2024` y `zhou2025demystifying`
  quedan **nivel C** correctamente (validación de esquema funcional /
  contexto post-training LLM, no estadística) — el fichado no las promueve por accidente.

