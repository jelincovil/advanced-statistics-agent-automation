# Monografía en Typst — exportación autónoma para la app web

Copia completa y autónoma del proyecto `monografia_typst_v1` en su estado
`v0.2-base`, lista para abrirse en la **app web de Typst** (typst.app).

## Cómo abrirla

1. En typst.app: *New project* y subir **esta carpeta** (arrastrarla conserva
   las subcarpetas `capitulos/`, `apendices/`, `imagenes/`).
2. Archivo de entrada: **`main.typ`**, en la raíz del proyecto.
3. Compila sin ninguna configuración: **274 páginas, 0 warnings**.

## Qué necesita

- El paquete `@preview/cetz:0.3.4`, que usan dos archivos para sendos
  diagramas (`capitulos/cap04_herramientas.typ` y
  `apendices/apendice_langgraph.typ`). La app lo descarga sola la primera vez,
  así que la primera compilación necesita conexión.
- Nada más: no hay fuentes locales, ni plugins, ni `sys.inputs`, ni rutas
  absolutas. Todas las rutas (`#import`, `#include`, `#bibliography`, `#image`)
  se convirtieron a **relativas** para que el proyecto compile desde cualquier
  raíz, también fuera de la app.

## Estructura

| archivo | qué es |
|---|---|
| `main.typ` | ensamblado del libro: portada, frontmatter, las cuatro partes, capítulos, apéndices y bibliografía |
| `plantilla.typ` | entorno completo: contadores, entornos de teorema, `#chapter-alias`, macro `#pendiente`, watermark |
| `prefacio.typ`, `notacion.typ` | páginas de frontmatter |
| `capitulos/` | 13 archivos: Introducción + capítulos 1 a 12 |
| `apendices/` | 7 archivos: apéndices A a G |
| `referencias.bib` | bibliografía (111 claves, 56 citadas en el texto) |
| `PENDIENTES.md` | **la hoja de ruta**: los 16 huecos declarados, con ubicación, y la deuda por fase |
| `MAPA_ESTRUCTURA.md`, `INFORME_FASE1.md`, `INFORME_FASE2.md`, `AUDITORIA_FASE1.md`, `FUENTES.md` | el rastro de las fases de edición, sin reescribir |

## Estado del manuscrito

- **12 capítulos + Introducción + 7 apéndices**, 274 pp.
- Los **16 cuadros rojos `PENDIENTE`** que se ven en el PDF son deliberados: son
  la declaración visible de lo que todavía falta. Están listados en
  `PENDIENTES.md` §1, con su ubicación en el código.
- La tesis está acotada a lo que se demuestra: **incrustación fiel `Dec → MDP`,
  un paso y determinista** (cap. 5). El capítulo de Shi et al. (cap. 8) es la
  Parte III.
- Reglas de trabajo del proyecto, si vas a seguir editándolo: no inventar
  referencias, DOI, años, páginas ni resultados; ante la duda, dejar el
  manuscrito afirmando **menos**, no más; y cada hueco que no se cierre, se
  marca con `#pendiente[…]` en vez de rellenarse con prosa plausible. Los
  detalles y el estado de cada deuda están en `PENDIENTES.md`.

## Qué **no** está en esta exportación

- `jrsssb_84_3_765.pdf` — el artículo de Shi, Zhang, Lu y Song (2022, JRSS-B
  84(3):765-793). Tiene copyright de Wiley y no se distribuye; su referencia
  completa (con DOI) está en `FUENTES.md`.
- `main.pdf` y `_dev_stub.*` — artefactos de compilación, se regeneran.
- `tools/` — scripts de migración de un solo uso (Python) y el verificador de
  citas; ya ejecutados, no hacen falta para compilar.
- Basura de LaTeX (`referencias.aux|.log|.fls|.fdb_latexmk`).

Nota menor: `imagenes/bvm_convergencia.png` viaja en la carpeta, pero hoy no lo
referencia ningún capítulo. `imagenes/grafo_1.png` sí (dos veces, en los
capítulos 9 y 10).
