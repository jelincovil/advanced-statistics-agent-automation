#import "plantilla.typ": *
#show: libro
#counter(page).update(1)
#include "capitulos/cap05_incrustacion.typ"
= Prueba de aliases
Vieja: @thm:ch9-isomorfismo — Nueva: @thm:ch5-isomorfismo — Deben coincidir.

Vieja: @cor:ch9-bayes — Nueva: @cor:ch5-bayes — Deben coincidir.

Vieja: @sec:ch13-mapa — Nueva: @sec:ch5-mapa — Deben coincidir.

Vieja: @def:ch10-dr — Nueva (cap07, imprime su capítulo): @def:ch7-dr.
