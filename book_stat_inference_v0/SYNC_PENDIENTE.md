# Sync → Typst.app

**Proyecto:** https://typst.app/project/p8zPrvPw1HfiwjT6xr5aIi
**Actualizado:** 2026-11-03 (reemplaza el manifiesto de la sesión 2026-10-04)

## Estado: PENDIENTE DE SUBIDA MANUAL (acción del autor en la web)

No tengo forma de subir archivos a typst.app desde la VM (la subida es un clic
del autor con su sesión abierta). Lo dejado listo:

- **Libro compilado y verde en repo:** `main.pdf` actualizado (275 pp, typst
  0.15.1, exit 0, 0 advertencias) tras todos los cambios editoriales de hoy.
- **Paquete de subida:** `.scratch/upload_typst_app_2026-11-03.tar.gz`, con
  el layout relativo del proyecto remoto (`exportacion_agente_v1/...`).
  Contiene: `main.typ`, `plantilla.typ`, `notacion.typ`, `prefacio.typ`,
  `main.pdf`, `referencias.bib`, los `.typ` de `capitulos/` y `apendices/`,
  y los documentos de gobernanza (`PENDIENTES.md`, `REGISTRO_DIARIO.md`,
  `PLAN_M_30D_2026-11-02.md`, `DECISIONES_2026-11-02.md`,
  `PROPUESTA_REFORMULACION.md`, `AUDITORIA_BIB_2026-11-03.md`,
  `ALIASES_2026-11-03.json`).

## Lo que cambió en la fuente desde la última sync (2026-10-04)

1. `apendices/apendice_reproduccion.typ` — fix `$nT$` → `$n T$` (bug de
   compilación real), escenarios A/B/C transcritos y verificados (artículo +
   repo SAVE `7533c28`), métricas y réplicas fijadas (N=50/celda, N=10⁵
   true-value), versión fijada por commit; estado: diseño fijado,
   pendiente solo ejecución.
2. `capitulos/cap04_herramientas.typ` — §«Tests de Hipótesis Bayesianos»
   eliminada (aprobada; 0 referencias externas verificadas).
3. `capitulos/intro.typ` — caption de `tab:correspondencia-central` remite a
   la canónica `tab:isomorfismo-completo`.
4. `capitulos/cap05_incrustacion.typ`, `cap06_fallos.typ`,
   `cap07_ope.typ`, `cap08_intervalos.typ`, `plantilla.typ` — **aliases de
   etiquetas migradas**: 95 nuevas claves coherentes con la numeración
   visible (`thm:ch5-*`, `thm:ch6-*`, `thm:ch7-*`, `thm:ch8-*`, más
   secciones), verificadas en render (sonda: vieja y nueva imprimen el mismo
   número; 18 alias potenciales suprimidos por colisión documentada en
   `ALIASES_2026-11-03.json`). Ninguna clave vieja ni referencia cambiada.
5. `PENDIENTES.md` — nota de exactitud 2026-11-03 (foto obsoleta de 16
   marcadores; real: 4 en Apéndice G, 3 cerrados hoy).
6. `REGISTRO_DIARIO.md` — entradas del 2026-11-02/03 (días 1–2 del plan,
   sprint M, D9, PENDIENTE mecánicos, aliases).

## Fuera del alcance de este paquete (repos separados)

- `monografia_M/` (manuscrito M en inglés, v0.1-M) — no pertenece al proyecto
  typst.app del libro de curso; decisión de publicarlo aparte queda del autor.
- `agents_curso/capitulo_09_isomorfismo/` — corrección D9
  (`representation.py` nuevo, `functor.py` reescrito, 47/47 tests).

## Verificación previa a subir (ya corrida en VM)

- `typst 0.15.1 compile main.typ` → exit 0, 275 pp, 0 errores, 0 advertencias.
- `verificacion/comprobar_{hallazgos,identidades,secundarios}.py` → OK ×3.
- Sonda de aliases (main + página de prueba temporal) → Teorema 5.3 ↔ vieja
  y nueva idénticas; secciones idénticas.
