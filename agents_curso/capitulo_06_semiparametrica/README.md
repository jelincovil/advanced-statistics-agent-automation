# Capítulo 6: Inferencia Semiparamétrica — AIPW Doubly Robust OPE

## Agente para Estimación Off-Policy Semiparamétrica

| Concepto | Manifestación |
|----------|---------------|
| Estimación semiparamétrica | Modelo Q + distribución de datos |
| AIPW / Doubly Robust | V̂ = V̂_DM + (1/n)Σ ρᵢ(Rᵢ − Q̂) |
| Doble robustez | Consistente si Q̂ o π_b son correctos |
| Función de influencia | √n(V̂ − V) → N(0, E[IF²]) |
| Eficiencia semiparamétrica | DR alcanza cota de Cramer-Rao |

## Ejecución
```bash
conda env create -f environment.yml && conda activate cap06_semiparametrica
export OPENROUTER_API_KEY="sk-or-..."
chainlit run app.py
```
## Pipeline del grafo
1. **generate_offpolicy_data** — 200 muestras, 2 estados, 2 acciones
2. **estimate_q** — Q̂(s,a) = media por par estado-acción
3. **compute_dm** — V̂_DM = Σ P(s) Σ πₑ(a|s) Q̂(s,a)
4. **compute_is** — V̂_IS = (1/n) Σ ρᵢ Rᵢ
5. **compute_dr** — V̂_DR = V̂_DM + (1/n) Σ ρᵢ(Rᵢ − Q̂)
6. **compute_influence_function** — IF scores para varianza asintótica
7. **check_robustness** — Corromper Q, verificar DR consistente
8. **compute_ci** — IC = ψ̂ ± z·SE desde la IF
9. **llm_interpret** — Explicación del LLM
10. **report** — Reporte final

## Referencias
- Bickel et al. (1993), Ch. 5-6
- Kennedy (2016), §3.2
- Kallus & Uehara (2020)
- Robins, Rotnitzky & Zhao (1994)
- Hahn (1998)
