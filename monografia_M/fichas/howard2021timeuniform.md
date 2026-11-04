# Ficha — Howard, Ramdas, McAuliffe & Sekhon (2021)

| Campo | Valor |
|---|---|
| **Clave .bib** | `howard2021timeuniform` |
| **Cita** | Howard, S. R., Ramdas, A., McAuliffe, J., & Sekhon, J. (2021). Time-uniform, nonparametric, nonasymptotic confidence sequences. *The Annals of Statistics*, 49(2), 1055–1080. |
| **arXiv** | [1810.08240](https://arxiv.org/abs/1810.08240) |
| **Verificado el** | 2026-11-03; datos bibliográficos confirmados vía búsqueda de fuente primaria (AoS 49(2)). |

## Qué problema trata
Construcción de secuencias de confianza (intervalos uniformes en el tiempo)
para medias de observaciones condicionalmente sub-gaussianas o acotadas, con
cotas explícitas no asintóticas (lineales y "stitched"), y la dualidad
test secuencial ↔ secuencia de confianza.

## Qué garantiza (a nivel abstract/resultados conocidos)
- Cobertura simultánea P(∀t ≥ 1: θ ∈ (L_t, U_t)) ≥ 1−α bajo condiciones de
  sub-gaussianidad condicional (varianza de la cota controlada), sin
  independencia ni estacionariedad.

## Encaje en M
Cap. 8: referencia de la técnica de "stitching"; el capítulo demuestra con
detalle solo la desigualdad de Ville y el e-proceso Hoeffding ilustrativo, y
remite aquí para las CS no asintóticas óptimas. No se transcriben constantes
de sus teoremas sin leer su forma exacta (OPEN si hiciera falta).

## Estado
- [x] Datos y alcance a nivel abstract confirmados.
- [ ] Cuerpo completo (pendiente para constantes de las cotas stitched).
