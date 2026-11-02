# Fuentes primarias

Este repositorio **no distribuye** las obras con copyright que usa como fuente.
Se registran aquí con su referencia completa y DOI, para que puedan obtenerse
por las vías legítimas, y para conservar la trazabilidad sin redistribuir la
obra.

---

## Fuente primaria del Capítulo 11

**Shi, C., Zhang, S., Lu, W., & Song, R. (2022).** Statistical inference of the
value function for reinforcement learning in infinite-horizon settings.
*Journal of the Royal Statistical Society: Series B (Statistical Methodology)*,
**84**(3), 765–793. DOI: [10.1111/rssb.12465](https://doi.org/10.1111/rssb.12465)

- **Archivo local:** `jrsssb_84_3_765.pdf` — *no versionado* (`.gitignore`),
  conservado en disco como material de trabajo.
- **Entrada bibliográfica:** `referencias.bib` → `shi2022statistical`.
- **Verificado contra el propio PDF:** paginación 765–793 (encabezado del
  artículo: «J R Stat Soc Series B. 2022;84:765–793»), DOI, autoría completa,
  el método SAVE (*SequentiAl Value Evaluation*) y la existencia de los
  Apéndices A–E.
- **Datos empíricos del artículo:** 6 pacientes del dataset OhioT1DM, ocho
  semanas, intervalos de 3 h, estado tridimensional, acción binaria según si la
  insulina total del intervalo supera una unidad, recompensa definida por el
  *Index of Glycemic Control*, γ = 0.5.
- **Corrección importante:** las pruebas del Teorema 1 se remiten al
  **Apéndice E.1** y son un *esquema*; el detalle técnico completo está en el
  material suplementario en línea (Secciones B.1 y C.3), que **no** forma parte
  del artículo impreso. Una versión anterior del manuscrito afirmaba que la
  prueba completa estaba en los «Apéndices A–C», lo cual era falso.

## Dataset del ejemplo empírico del artículo

**Marling, C., & Bunescu, R. C. (2018).** The OhioT1DM dataset for blood glucose
level prediction. In *KHD@ IJCAI*, pp. 60–63.

- Referencia transcrita de la lista bibliográfica de Shi et al. (2022), p. 793.
  **No verificada de forma independiente** contra el volumen de KHD@IJCAI.

## Obra citada en el texto, con referencia verificada

**Rodbard, D. (2009).** Interpretation of continuous glucose monitoring data:
glycemic variability and quality of glycemic control. *Diabetes Technology &
Therapeutics*, **11**, S-55.

- Entrada bibliográfica: `referencias.bib` → `rodbard2009interpretation`.
- La lista de Shi et al. (2022) da la paginación abreviada «11, S-55».
- ⚠️ **El rango completo de páginas no está verificado.** La entrada del `.bib`
  usa `pages = {S55}` y no un rango: no se inventa el cierre.
  Verificar contra la revista antes de ampliarlo (el rango suele citarse como
  S55–S67, pero eso **no** se pudo confirmar en la fuente disponible).
