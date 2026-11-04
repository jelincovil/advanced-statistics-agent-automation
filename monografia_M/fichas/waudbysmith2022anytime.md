# Ficha — Waudby-Smith, Wu, Ramdas, Karampatziakis & Mineiro (2022/2024)

| Campo | Valor |
|---|---|
| **Clave .bib** | `waudbysmith2022anytime` |
| **Cita** | Waudby-Smith, I., Wu, L., Ramdas, A., Karampatziakis, N., & Mineiro, P. (2022). Anytime-valid off-policy inference for contextual bandits. arXiv:2210.10768 (v3, 2024-08-15). |
| **arXiv** | [2210.10768](https://arxiv.org/abs/2210.10768) |
| **Verificado el** | 2026-11-03 contra la página de arXiv (abstract completo leído). |

## Qué problema trata
Inferencia off-policy (estimación del valor de políticas) sobre datos de
contextual bandits recolectados adaptativamente, con la política de registro
posiblemente cambiando (aprendizaje) y distribuciones de contexto dependientes.

## Qué garantiza
- Secuencias de confianza (CS) doblemente robustas para valores de política
  que varían en el tiempo; bandas para la CDF completa de la recompensa.
- Validez en tiempos de parada arbitrarios; supuestos no paramétricos; no
  exige pesos de importancia uniformemente acotados; se adapta a la varianza
  empírica de los estimadores.

## Qué exige (condiciones declaradas por el abstract)
- Los pesos son funciones predecibles de la información disponible; las
  garantías son uniformes en el tiempo, a lo sumo de nivel α.
- (Cuerpo completo no leído: antes de citar tasas o constantes concretas en M,
  leer las hipótesis formales — conforme al protocolo de fichas.)

## Encaje en M
Cap. 8 (anytime-valid policy evaluation): es la referencia central para OPE
anytime-valid; el capítulo cita su marco y sus condiciones declaradas,
demuestra solo los e-procesos ilustrativos propios.

## Estado
- [x] Abstract + hipótesis a nivel abstract leídos.
- [ ] Cuerpo completo (pendiente si M necesita enunciados formales de sus teoremas).
