# Ficha — Saito, Aihara, Matsutani & Narita (2021): Open Bandit Dataset/Pipeline

| Campo | Valor |
|---|---|
| **Clave .bib** | `saito2021openbandit` |
| **Cita** | Saito, Y., Aihara, S., Matsutani, M., & Narita, Y. (2021). Open Bandit Dataset and Pipeline: Towards Realistic and Reproducible Off-Policy Evaluation. *NeurIPS 2021, Datasets and Benchmarks Track.* |
| **arXiv** | [2008.07146](https://arxiv.org/abs/2008.07146) (v5, 2021-10-26) · **Código:** https://github.com/st-tech/zr-obp |
| **Verificado el** | 2026-11-03 contra la página de arXiv (abstract + metadatos: "Accepted at NeurIPS2021 Datasets and Benchmarks Track"). |

## Qué es
Dataset público de bandits registrados en ZOZOTOWN (e-commerce de moda a gran
escala), recolectado corriendo **varias políticas** en la misma plataforma —
permite comparar estimadores OPE entre políticas de registro. Acompaña el
software Open Bandit Pipeline (`obp`), con estimadores DM/IPW/DR/FIS/SNIPW,
Switch, MRDR, DRos y procedimientos estandarizados.

## Propiedades relevantes para M (declaradas en el abstract/repo)
- Las probabilidades de asignación (propensiones) se registran por diseño:
  el soporte/overlap en el experimento es conocido, no asumido.
- Campañas `all`, `men`, `women`; políticas de registro `bts` (Bernoulli
  Thompson Sampling) y `random`; recompensa binaria (click) y recompensas por
  número de ítems listados.
- Objetivo del cap. 11 de M: ejecutar el protocolo V2 de M sobre datos reales
  (estimando, unidad iid — usuarios/sesiones independientes según el diseño—,
  condiciones de diseño vs. diagnósticas, conclusiones proporcionales).

## Estado
- [x] Abstract + metadatos verificados.
- [ ] Detalles de tamaño/formato en el propio pipeline (se confirman al
  ejecutar; ver `monografia_M/labs/obd_*` y cap. 11, cualquier cifra no
  confirmada queda marcada OPEN).
