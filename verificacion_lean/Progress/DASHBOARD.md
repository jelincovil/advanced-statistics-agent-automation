# DASHBOARD — verificacion_lean

Generado por `Progress/gen_dashboard.py` el 2026-11-10 desde `Book/*.lean` y `build/axioms.log`. No editar a mano.

## Resumen

- Ficheros en `Book/`: 68 `*.lean` (incluye los auditores y los módulos sin anotaciones `book:`).
- Módulos con teoremas anotados: 57.
- Teoremas con docstring `book:`: 682 (216 claves distintas).
- Auditados: 682 · **SIN AUDITAR: 0** · axioma extraño: 0.
- Teoremas de `Book/*` en `build/axioms.log`: 2702.
- Axiomas permitidos: `propext, Classical.choice, Quot.sound`.

## Teoremas verificados

| Teorema | Clave del libro | Origen | Axiomas | Estado |
|---|---|---|---|---|
| `thm_appD_ibragimov` (`ApendiceDIbragimov.lean`) | `thm:appD-ibragimov` @ apendices/apendice_regularidad.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_proyeccion` (`ApendiceEHilbert.lean`) | `thm:appE-proyeccion` @ apendices/apendice_medido.typ:225 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_proyeccion_minimo` (`ApendiceEHilbert.lean`) | `thm:appE-proyeccion` @ apendices/apendice_medido.typ:225 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_proyeccion_ortogonal_iff` (`ApendiceEHilbert.lean`) | `thm:appE-proyeccion` @ apendices/apendice_medido.typ:225 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_l2_inner` (`ApendiceEHilbert.lean`) | `ex:appE-l2` @ apendices/apendice_medido.typ:218 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_l2_norm` (`ApendiceEHilbert.lean`) | `ex:appE-l2` @ apendices/apendice_medido.typ:218 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_l2_identifica` (`ApendiceEHilbert.lean`) | `ex:appE-l2` @ apendices/apendice_medido.typ:218 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_l2_hilbert` (`ApendiceEHilbert.lean`) | `ex:appE-l2` @ apendices/apendice_medido.typ:218 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_l2` (`ApendiceEHilbert.lean`) | `ex:appE-l2` @ apendices/apendice_medido.typ:218 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_gaussiano_densidad` (`ApendiceEHilbert.lean`) | `ex:appE-gaussiano` @ apendices/apendice_medido.typ:163 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_gaussiano_pos` (`ApendiceEHilbert.lean`) | `ex:appE-gaussiano` @ apendices/apendice_medido.typ:163 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_gaussiano_integral` (`ApendiceEHilbert.lean`) | `ex:appE-gaussiano` @ apendices/apendice_medido.typ:163 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_gaussiano_dominado` (`ApendiceEHilbert.lean`) | `ex:appE-gaussiano` @ apendices/apendice_medido.typ:163 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_gaussiano` (`ApendiceEHilbert.lean`) | `ex:appE-gaussiano` @ apendices/apendice_medido.typ:163 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_Ioo_medible` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_abierto_medible` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_cerrado_medible` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_numerable_medible` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_singleton_medible` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_borel_generado_por_intervalos` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_borel_minima` (`ApendiceEMedido.lean`) | `ex:appE-borel` @ apendices/apendice_medido.typ:33 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_composicion` (`ApendiceEMedido.lean`) | `prop:appE-composicion` @ apendices/apendice_medido.typ:49 | ? | `` | OK |
| `appE_estadistico_comp` (`ApendiceEMedido.lean`) | `ex:appE-estadisticos` @ apendices/apendice_medido.typ:54 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_constante_oculta_comp` (`ApendiceEMedido.lean`) | `ex:appE-estadisticos` @ apendices/apendice_medido.typ:54 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_constante_oculta` (`ApendiceEMedido.lean`) | `ex:appE-estadisticos` @ apendices/apendice_medido.typ:54 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_continuo_borel` (`ApendiceEMedido.lean`) | `ex:appE-estadisticos` @ apendices/apendice_medido.typ:54 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_G_le_F` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_recompensa_medible_F` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_estado_accion_medible_G` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_markov_nucleo_medible` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_markov_nucleo_probabilidad` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_markov_depende_de_sa` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_markov_homogeneo` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_markov_ley_transicion` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_recompensa_no_medible_bot` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_recompensa_medible_sup` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_filtracion_estricta` (`ApendiceEMedido.lean`) | `prop:appE-markov-filtracion` @ apendices/apendice_medido.typ:116 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_media_muestral_continua` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_media_muestral_medible` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_comp_estimador` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `conjuntoMax_nonempty` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mem_conjuntoMax` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `seleccionMax_max` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `seleccionMax_le` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `seleccionMax_eq_iff` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `medible_de_fibras_finitas` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_seleccion_max_medible` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_argmax_cuadratico_medible` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_argmax_cuadratico_unico` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_maximo_existe_compacto` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_continuidad_sin_maximo` (`ApendiceEMedido.lean`) | `prop:appE-estimadores-medibles` @ apendices/apendice_medido.typ:134 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_dominacion_densidad` (`ApendiceEMedido.lean`) | `prop:appE-dominacion-continuo` @ apendices/apendice_medido.typ:156 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_densidad_probabilidad` (`ApendiceEMedido.lean`) | `prop:appE-dominacion-continuo` @ apendices/apendice_medido.typ:156 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_modelo_continuo_dominado` (`ApendiceEMedido.lean`) | `prop:appE-dominacion-continuo` @ apendices/apendice_medido.typ:156 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_densidad_continua_medible` (`ApendiceEMedido.lean`) | `prop:appE-dominacion-continuo` @ apendices/apendice_medido.typ:156 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_dirac_sin_densidad` (`ApendiceEMedido.lean`) | `prop:appE-dominacion-continuo` @ apendices/apendice_medido.typ:156 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_convergencia_dominada` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_convergencia_dominada_integrable` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_convergencia_dominada_tendsto` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_convergencia_dominada_L1` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_convergencia_dominada_const` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `masaQueEscapa_tendsto` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `masaQueEscapa_integral` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `masaQueEscapa_sin_dominante` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_dct_dominacion_necesaria` (`ApendiceEMedidoDctM5.lean`) | `thm:appE-convergencia-dominada` @ apendices/apendice_medido.typ:201 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_appD_hac_consistencia` (`AppDHacM9.lean`) | `thm:appD-hac-consistencia` @ apendices/apendice_regularidad.typ:162 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ancho_fijo_contraejemplo` (`AppDHacM9.lean`) | `thm:appD-hac-consistencia` @ apendices/apendice_regularidad.typ:162 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_funcion_implicita` (`AppEFuncionImplicita.lean`) | `thm:appE-funcion-implicita` @ apendices/apendice_medido.typ:173 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_funcion_implicita_abierto` (`AppEFuncionImplicita.lean`) | `thm:appE-funcion-implicita` @ apendices/apendice_medido.typ:173 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_funcion_implicita_fderiv` (`AppEFuncionImplicita.lean`) | `thm:appE-funcion-implicita` @ apendices/apendice_medido.typ:173 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_funcion_implicita_germen_unico` (`AppEFuncionImplicita.lean`) | `thm:appE-funcion-implicita` @ apendices/apendice_medido.typ:173 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernFisher_eq` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernFisher_half` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `fisher_informacion_no_da_jacobiano_invertible` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `jacobiano_invertible_sin_solucion` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `identificacion_sin_nonsingularidad` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `nonsingularidad_sin_identificacion` (`AppEFuncionImplicitaCond.lean`) | `prop:appE-condiciones-funcion-implicita` @ apendices/apendice_medido.typ:187 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_medible` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_finita_a_e` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_identidad` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_es_derivada` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_existe_unico` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_ac_iff` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_integral_uno` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_integral_uno_toReal` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_integrable` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_positiva` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_unico` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_densidad_es_derivada` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_unicidad_no_puntual` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_cambio_de_medida` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_cambio_de_medida_conjunto` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_cambio_de_medida_integral` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_fundamental` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_cadena` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_modelo` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_uniforme` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_uniforme_probabilidad` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_uniforme_masa` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_uniforme_verifica` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_uniforme_existe_unico` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_ac_count` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_densidad_count_inexistente` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `appE_rn_hipotesis_sigma_finita_necesaria` (`AppERNM3.lean`) | `thm:appE-radon-nikodym` @ apendices/apendice_medido.typ:85 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_cov` (`BarridoM16.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_tau2` (`BarridoM16.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_tau2_rho_tres_quintos` (`BarridoM16.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_tamano_efectivo` (`BarridoM16.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `no_param_ecdf` (`BarridoM16.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `no_param_kernel_h06` (`BarridoM16.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `no_param_kernel_h11` (`BarridoM16.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `if_media_centrada` (`BarridoM16.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ite_sq_self` (`BarridoM16.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `if_cuantil_media` (`BarridoM16.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `if_cuantil_varianza` (`BarridoM16.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `suf_suficiencia_politicas` (`BarridoM16.lean`) | `prop:ch2-suficiencia-politicas` @ capitulos/cap09_verificacion.typ:227 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `sum_sq_sub` (`BarridoM16.lean`) | `prop:ch3-rb-q` @ capitulos/cap09_verificacion.typ:343 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cs_weighted` (`BarridoM16.lean`) | `prop:ch3-valor-cr` @ capitulos/cap09_verificacion.typ:328 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rb_q` (`BarridoM16.lean`) | `prop:ch3-rb-q` @ capitulos/cap09_verificacion.typ:343 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cr_cota` (`BarridoM16.lean`) | `prop:ch3-valor-cr` @ capitulos/cap09_verificacion.typ:328 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_max_no_supera` (`BarridoM16.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_card_evita` (`BarridoM16.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_prob_igual` (`BarridoM16.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_limite` (`BarridoM16.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas_cuadratica` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas_clasificacion` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas_ponderada` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas_no_negativas` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch7_perdidas_ponderada_medida` (`Cap02M11.lean`) | `ex:ch7-perdidas` @ capitulos/cap02_wald.typ:40 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `james_stein_riesgo` (`Cap02M11.lean`) | `ex:ch7-james-stein` @ capitulos/cap02_wald.typ:61 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `james_stein_mejora` (`Cap02M11.lean`) | `ex:ch7-james-stein` @ capitulos/cap02_wald.typ:61 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `james_stein_valor_nulo` (`Cap02M11.lean`) | `ex:ch7-james-stein` @ capitulos/cap02_wald.typ:61 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_bayes` (`Cap02Wald.lean`) | `thm:ch7-bayes` @ capitulos/cap02_wald.typ:83 | F2 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch7_bayes_cuadratica` (`Cap02Wald.lean`) | `cor:ch7-bayes-especificas` @ capitulos/cap02_wald.typ:92 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch7_bayes_mediana` (`Cap02Wald.lean`) | `cor:ch7-bayes-especificas` @ capitulos/cap02_wald.typ:92 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch7_bayes_moda` (`Cap02Wald.lean`) | `cor:ch7-bayes-especificas` @ capitulos/cap02_wald.typ:92 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch7_bayes_especificas` (`Cap02Wald.lean`) | `cor:ch7-bayes-especificas` @ capitulos/cap02_wald.typ:92 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_minimax_bayes` (`Cap02Wald.lean`) | `thm:ch7-minimax-bayes` @ capitulos/cap02_wald.typ:123 | F2 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_minimax_bayes_constante` (`Cap02Wald.lean`) | `thm:ch7-minimax-bayes` @ capitulos/cap02_wald.typ:123 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_admisibilidad_bayes` (`Cap02Wald.lean`) | `thm:ch7-admisibilidad-bayes` @ capitulos/cap02_wald.typ:101 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_complete_class_bayes` (`Cap02Wald.lean`) | `thm:ch7-complete-class` @ capitulos/cap02_wald.typ:108 | F2 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch4_test_decision` (`Cap02Wald.lean`) | `prop:ch4-test-decision` @ capitulos/cap02_wald.typ:148 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_mejora` (`Cap03MDP.lean`) | `thm:ch8-mejora` @ capitulos/cap03_mdp.typ:120 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_sin_repeticion` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_conteo` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_pi_finita_optimo` (`Cap03MDP.lean`) | `cor:ch8-pi-finita` @ capitulos/cap03_mdp.typ:128 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_contraccion` (`Cap03MDP.lean`) | `thm:ch8-contraccion` @ capitulos/cap03_mdp.typ:82 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_punto_fijo_unico` (`Cap03MDP.lean`) | `cor:ch8-punto-fijo` @ capitulos/cap03_mdp.typ:89 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_parada` (`Cap03MDP.lean`) | `cor:ch8-parada` @ capitulos/cap03_mdp.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_VQ` (`Cap03MDP.lean`) | `prop:ch8-VQ` @ capitulos/cap03_mdp.typ:44 | F-correction 2026-11-06 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_acotacion` (`Cap03MDP.lean`) | `prop:ch8-acotacion` @ capitulos/cap03_mdp.typ:47 | F-correction 2026-11-06 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_bellman_pi` (`Cap03MDP.lean`) | `thm:ch8-bellman-pi` @ capitulos/cap03_mdp.typ:54 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_vi_conv` (`Cap03MDP.lean`) | `thm:ch8-vi-conv` @ capitulos/cap03_mdp.typ:101 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_principio` (`Cap03MDP.lean`) | `cor:ch8-principio` @ capitulos/cap03_mdp.typ:195 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_bellman_opt` (`Cap03MDP.lean`) | `thm:ch8-bellman-opt` @ capitulos/cap03_mdp.typ:63 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_perdida` (`Cap03MDP.lean`) | `prop:ch8-perdida` @ capitulos/cap03_mdp.typ:205 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch8_condiciones_contraccion` (`Cap03MDP.lean`) | `thm:ch8-condiciones-contraccion` @ capitulos/cap03_mdp.typ:202 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `mle_normal_mean` (`Cap03MleM4.lean`) | `ex:ch3-mle-normal` @ capitulos/cap04_herramientas.typ:1086 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_normal_var` (`Cap03MleM4.lean`) | `ex:ch3-mle-normal` @ capitulos/cap04_herramientas.typ:1086 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_normal_bias` (`Cap03MleM4.lean`) | `ex:ch3-mle-normal` @ capitulos/cap04_herramientas.typ:1086 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_normal_bias_gap` (`Cap03MleM4.lean`) | `ex:ch3-mle-normal` @ capitulos/cap04_herramientas.typ:1086 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_normal_bias_factor_tendsto` (`Cap03MleM4.lean`) | `ex:ch3-mle-normal` @ capitulos/cap04_herramientas.typ:1086 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_score_expansion` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_consistency` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `var_const_mul` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_asymptotic_variance` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_attains_cramer_rao` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_invariance` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mle_consistency_separation` (`Cap03MleM4.lean`) | `thm:ch3-mle-propiedades` @ capitulos/cap04_herramientas.typ:1064 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_moment_single` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_moment_pair` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_mean_T` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_mean_T_sq` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_var_X1` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_var_T` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_var_Tdiv` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_rb_variance_improves` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bern_cond_exp` (`Cap03MleM4.lean`) | `ex:ch3-rb-bernoulli` @ capitulos/cap04_herramientas.typ:910 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `fdr_per_null` (`Cap04BhM3.lean`) | `thm:ch4-bh` @ capitulos/cap04_herramientas.typ:1441 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bh_fdr_le` (`Cap04BhM3.lean`) | `thm:ch4-bh` @ capitulos/cap04_herramientas.typ:1441 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bh_fdr_le_alpha` (`Cap04BhM3.lean`) | `thm:ch4-bh` @ capitulos/cap04_herramientas.typ:1441 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gauss_loglik_max` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mean_variance_true` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gauss_sandwich` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `uniform_score` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `uniform_max_cdf_identity` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `uniform_max_cdf_tendsto` (`Cap04Ch4M6.lean`) | `ex:ch4-regularidad` @ capitulos/cap04_herramientas.typ:1099 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_longrun_variance` (`Cap04Ch4M6.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ar1_tau_sq_three_fifths` (`Cap04Ch4M6.lean`) | `ex:ch4-ar1` @ capitulos/cap04_herramientas.typ:1525 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `empirical_cdf_at_two` (`Cap04Ch4M6.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `kernel_uniform_h_small` (`Cap04Ch4M6.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `kernel_rate` (`Cap04Ch4M6.lean`) | `ex:ch4-no-parametrico` @ capitulos/cap04_herramientas.typ:1685 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_max_atom` (`Cap04Ch4M6.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bootstrap_max_tendsto` (`Cap04Ch4M6.lean`) | `ex:ch4-bootstrap-unidad` @ capitulos/cap04_herramientas.typ:1750 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mean_if_exact` (`Cap04Ch4M6.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `quantile_if_variance` (`Cap04Ch4M6.lean`) | `ex:ch4-if-media-cuantil` @ capitulos/cap04_herramientas.typ:1900 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_dr` (`Cap04Ch6.lean`) | `thm:ch6-dr` @ capitulos/cap04_herramientas.typ:1955 | F-correction 2026-11-08 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_dr_propension` (`Cap04Ch6.lean`) | `thm:ch6-dr` @ capitulos/cap04_herramientas.typ:1955 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_dr_modelos` (`Cap04Ch6.lean`) | `thm:ch6-dr` @ capitulos/cap04_herramientas.typ:1955 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_cota` (`Cap04Ch6.lean`) | `thm:ch6-cota` @ capitulos/cap04_herramientas.typ:1919 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_cota_le` (`Cap04Ch6.lean`) | `thm:ch6-cota` @ capitulos/cap04_herramientas.typ:1919 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_cota_igualdad` (`Cap04Ch6.lean`) | `thm:ch6-cota` @ capitulos/cap04_herramientas.typ:1919 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_cota_expect` (`Cap04Ch6.lean`) | `thm:ch6-cota` @ capitulos/cap04_herramientas.typ:1919 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_cota_expect_le` (`Cap04Ch6.lean`) | `thm:ch6-cota` @ capitulos/cap04_herramientas.typ:1919 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch6_varianza_minima` (`Cap04Ch6.lean`) | `cor:ch6-varianza-minima` @ capitulos/cap04_herramientas.typ:1927 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch6_varianza_minima_cota` (`Cap04Ch6.lean`) | `cor:ch6-varianza-minima` @ capitulos/cap04_herramientas.typ:1927 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch6_descomposicion` (`Cap04Ch6.lean`) | `prop:ch6-descomposicion` @ capitulos/cap04_herramientas.typ:1878 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch6_descomposicion_isCompl` (`Cap04Ch6.lean`) | `prop:ch6-descomposicion` @ capitulos/cap04_herramientas.typ:1878 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_neyman` (`Cap04Ch6.lean`) | `thm:ch6-neyman` @ capitulos/cap04_herramientas.typ:1939 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_neyman_cota` (`Cap04Ch6.lean`) | `thm:ch6-neyman` @ capitulos/cap04_herramientas.typ:1939 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_neyman_escala` (`Cap04Ch6.lean`) | `thm:ch6-neyman` @ capitulos/cap04_herramientas.typ:1939 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_kallus_residual` (`Cap04Ch6.lean`) | `thm:ch6-kallus` @ capitulos/cap04_herramientas.typ:1974 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_kallus_pesos` (`Cap04Ch6.lean`) | `thm:ch6-kallus` @ capitulos/cap04_herramientas.typ:1974 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_kallus_inicial` (`Cap04Ch6.lean`) | `thm:ch6-kallus` @ capitulos/cap04_herramientas.typ:1974 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch6_dr_ope_modelos` (`Cap04Ch6.lean`) | `cor:ch6-dr-ope` @ capitulos/cap04_herramientas.typ:1982 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch6_dr_ope_pesos` (`Cap04Ch6.lean`) | `cor:ch6-dr-ope` @ capitulos/cap04_herramientas.typ:1982 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_crossfit_suma` (`Cap04Ch6.lean`) | `thm:ch6-crossfit` @ capitulos/cap04_herramientas.typ:2028 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_crossfit_media` (`Cap04Ch6.lean`) | `thm:ch6-crossfit` @ capitulos/cap04_herramientas.typ:2028 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch6_ral` (`Cap04Ch6.lean`) | `prop:ch6-ral` @ capitulos/cap04_herramientas.typ:1892 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch6_rubin_dag` (`Cap04Ch6.lean`) | `thm:ch6-rubin-dag` @ capitulos/cap04_herramientas.typ:2055 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_dml_identidad` (`Cap04Ch6DmlM5.lean`) | `thm:ch6-dml` @ capitulos/cap04_herramientas.typ:2012 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_dml_doble_robustez` (`Cap04Ch6DmlM5.lean`) | `thm:ch6-dml` @ capitulos/cap04_herramientas.typ:2012 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_dml_resto_pequeno` (`Cap04Ch6DmlM5.lean`) | `thm:ch6-dml` @ capitulos/cap04_herramientas.typ:2012 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_dml_clt` (`Cap04Ch6DmlM5.lean`) | `thm:ch6-dml` @ capitulos/cap04_herramientas.typ:2012 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ipw_true` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `doble_robustez_propension` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `doble_robustez_medias` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `identificacion` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ipw_verdadera_insesgada` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `plugin_sesgado` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `sesgo_finito_propension_estimada` (`Cap04Ch6Motivacion.lean`) | `ex:ch6-motivacion` @ capitulos/cap04_herramientas.typ:17 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_calculo_numerico_observado` (`Cap04Ejemplos.lean`) | `ex:ch1-calculo-numerico` @ capitulos/cap04_herramientas.typ:263 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_calculo_numerico_riesgos_en_medio` (`Cap04Ejemplos.lean`) | `ex:ch1-calculo-numerico` @ capitulos/cap04_herramientas.typ:263 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_calculo_numerico_frontera` (`Cap04Ejemplos.lean`) | `ex:ch1-calculo-numerico` @ capitulos/cap04_herramientas.typ:263 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_cociente_delta` (`Cap04Ejemplos.lean`) | `ex:ch5-cociente` @ capitulos/cap04_herramientas.typ:1593 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_cociente_covarianza` (`Cap04Ejemplos.lean`) | `ex:ch5-cociente` @ capitulos/cap04_herramientas.typ:1593 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_normal_expansion` (`Cap04Ejemplos.lean`) | `ex:ch1-normal` @ capitulos/cap04_herramientas.typ:352 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_normal_derivada_logparticion` (`Cap04Ejemplos.lean`) | `ex:ch1-normal` @ capitulos/cap04_herramientas.typ:352 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_binomial_forma_exponencial` (`Cap04Ejemplos.lean`) | `ex:ch1-binomial` @ capitulos/cap04_herramientas.typ:370 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_binomial_derivada_logparticion` (`Cap04Ejemplos.lean`) | `ex:ch1-binomial` @ capitulos/cap04_herramientas.typ:370 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_poisson_forma_exponencial` (`Cap04Ejemplos.lean`) | `ex:ch1-poisson` @ capitulos/cap04_herramientas.typ:384 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_poisson_derivada_logparticion` (`Cap04Ejemplos.lean`) | `ex:ch1-poisson` @ capitulos/cap04_herramientas.typ:384 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_estadisticos_media_constante` (`Cap04Ejemplos.lean`) | `ex:ch1-estadisticos-fundamentales` @ capitulos/cap04_herramientas.typ:210 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_estadisticos_var_no_negativa` (`Cap04Ejemplos.lean`) | `ex:ch1-estadisticos-fundamentales` @ capitulos/cap04_herramientas.typ:210 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_traslaciones_media` (`Cap04Ejemplos.lean`) | `ex:ch2-traslaciones` @ capitulos/cap04_herramientas.typ:823 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_traslaciones_varianza` (`Cap04Ejemplos.lean`) | `ex:ch2-traslaciones` @ capitulos/cap04_herramientas.typ:823 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_escala_media` (`Cap04Ejemplos.lean`) | `ex:ch2-escala` @ capitulos/cap04_herramientas.typ:839 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_escala_varianza` (`Cap04Ejemplos.lean`) | `ex:ch2-escala` @ capitulos/cap04_herramientas.typ:839 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_escala_desviacion` (`Cap04Ejemplos.lean`) | `ex:ch2-escala` @ capitulos/cap04_herramientas.typ:839 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_mp_normal_forma_factorizada` (`Cap04Ejemplos.lean`) | `ex:ch4-mp-normal` @ capitulos/cap04_herramientas.typ:1272 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_mp_normal_umbral` (`Cap04Ejemplos.lean`) | `ex:ch4-mp-normal` @ capitulos/cap04_herramientas.typ:1272 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_beta_binomial_actualizacion` (`Cap04Ejemplos.lean`) | `ex:ch1-beta-binomial` @ capitulos/cap04_herramientas.typ:459 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_gamma_poisson_actualizacion` (`Cap04Ejemplos.lean`) | `ex:ch1-gamma-poisson` @ capitulos/cap04_herramientas.typ:472 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_pesos` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_valor_objetivo` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_pseudoresultados` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_estimador` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_directo_ips` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_tres_estimadores_distintos` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aumentado_descomposicion` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_ssch_descomposicion` (`Cap04EjemplosM2.lean`) | `ex:ch6-dr-ssch` @ capitulos/cap04_herramientas.typ:1991 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_psi` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_propensiones` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_estratos_condicionales` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_medias_observadas` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_crudo_signo_opuesto` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `sesgo_confusion` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_sesgo_confusion` (`Cap04EjemplosM2.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `hasDerivAt_log_affine` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `hasDerivAt_log_affine_sub` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lognormal_expansion` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `score_normal` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `score_normal_valor` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `score_bernoulli` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `score_bernoulli_media_cero` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `score_conteo` (`Cap04EjemplosM2.lean`) | `ex:ch6-scores-canonicos` @ capitulos/cap04_herramientas.typ:1862 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_cancelacion` (`Cap04EjemplosM2.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_pl_independiente_basal` (`Cap04EjemplosM2.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_invariancia_escala` (`Cap04EjemplosM2.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aipw_identificacion` (`Cap04EjemplosM2.lean`) | `ex:ch6-aipw-intro` @ capitulos/cap04_herramientas.typ:1843 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ope_escalar_no_determina_valor` (`Cap04EjemplosM2.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ope_objetivo_escalar` (`Cap04EjemplosM2.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `parcialmente_lineal_residual` (`Cap04EjemplosM2.lean`) | `ex:ch6-parcialmente-lineal` @ capitulos/cap04_herramientas.typ:1833 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `parcialmente_lineal_beta` (`Cap04EjemplosM2.lean`) | `ex:ch6-parcialmente-lineal` @ capitulos/cap04_herramientas.typ:1833 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap03b_frecuencias_suman_uno` (`Cap04EjemplosM2.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap03b_frecuencia_insesgada` (`Cap04EjemplosM2.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap03b_valor_ecuacion` (`Cap04EjemplosM2.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch1_logparticion` (`Cap04Herramientas.lean`) | `thm:ch1-logparticion` @ capitulos/cap04_herramientas.typ:314 | F-correction 2026-11-07 (nuevo; formalizacion de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch1_covarianza_hessiano` (`Cap04Herramientas.lean`) | `cor:ch1-covarianza-hessiano` @ capitulos/cap04_herramientas.typ:343 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_bonferroni` (`Cap04Herramientas.lean`) | `thm:ch4-bonferroni` @ capitulos/cap04_herramientas.typ:1393 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_neyman_fisher` (`Cap04Herramientas.lean`) | `thm:ch2-neyman-fisher` @ capitulos/cap04_herramientas.typ:600 | F-correction 2026-11-07 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_completitud_const` (`Cap04Herramientas.lean`) | `thm:ch2-completitud-exponencial` @ capitulos/cap04_herramientas.typ:702 | F-correction 2026-11-07 (nuevo; formalizacion de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_completitud_exponencial` (`Cap04Herramientas.lean`) | `thm:ch2-completitud-exponencial` @ capitulos/cap04_herramientas.typ:702 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_completitud_exponencial_vandermonde` (`Cap04Herramientas.lean`) | `thm:ch2-completitud-exponencial` @ capitulos/cap04_herramientas.typ:702 | F-correction 2026-11-08 (caso general; cierra la brecha de ch2_completitud_const) | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch3_info_aditiva` (`Cap04Herramientas.lean`) | `prop:ch3-info-aditiva` @ capitulos/cap04_herramientas.typ:1027 | F-correction 2026-11-07 | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch4_exp_mlr` (`Cap04Herramientas.lean`) | `cor:ch4-exp-mlr` @ capitulos/cap04_herramientas.typ:1311 | F-correction 2026-11-07 | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch4_inversion_simple` (`Cap04Herramientas.lean`) | `thm:ch4-inversion` @ capitulos/cap04_herramientas.typ:1349 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch4_ic_z_simple` (`Cap04Herramientas.lean`) | `cor:ch4-ic-z` @ capitulos/cap04_herramientas.typ:1362 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_neyman_pearson` (`Cap04LoteM16.lean`) | `thm:ch4-neyman-pearson` @ capitulos/cap04_herramientas.typ:1248 | enjambre smw82qi6q / m16 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_multiplicidad` (`Cap04LoteM16.lean`) | `prop:ch4-multiplicidad` @ capitulos/cap04_herramientas.typ:1385 | enjambre smw82qi6q / m16 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_holm` (`Cap04LoteM16.lean`) | `thm:ch4-holm` @ capitulos/cap04_herramientas.typ:1431 | enjambre smw82qi6q / m16 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_mlr` (`Cap04LoteM16.lean`) | `thm:ch4-mlr` @ capitulos/cap04_herramientas.typ:1292 | enjambre smw82qi6q / m16 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch4_bonferroni_ssch` (`Cap04LoteM16.lean`) | `ex:ch4-bonferroni-ssch` @ capitulos/cap04_herramientas.typ:1404 | enjambre smw82qi6q / m16 (nuevo; formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `medible_continua` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `medible_continua_reales` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `preimagen_borel_medible` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `medible_media_muestral` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `medible_varianza_muestral` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ley_es_probabilidad` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ley_apply` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ley_ext` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `esperanza_transporte` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `integrable_transportado_iff` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `esperanza_finita_iff_integrable` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `momento_infinito_sin_integrable` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `uno_no_integrable_volume` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `medible_no_implica_integrable` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `integrable_of_acotado` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `esperanza_acotada` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ley_media_dos_puntos` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `esperanza_media_dos_puntos` (`Cap04MedibleIntuicionM10.lean`) | `ex:ch1-medible-intuicion` @ capitulos/cap04_herramientas.typ:184 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_equivarianza` (`Cap04Suficiencia.lean`) | `thm:ch2-equivarianza` @ capitulos/cap04_herramientas.typ:813 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_lehmann_scheffe_criterio` (`Cap04Suficiencia.lean`) | `thm:ch2-lehmann-scheffe` @ capitulos/cap04_herramientas.typ:657 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_lehmann_scheffe_minimal` (`Cap04Suficiencia.lean`) | `thm:ch2-lehmann-scheffe` @ capitulos/cap04_herramientas.typ:657 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch2_smc` (`Cap04Suficiencia.lean`) | `cor:ch2-smc` @ capitulos/cap04_herramientas.typ:712 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch3_rao_blackwell` (`Cap04Suficiencia.lean`) | `thm:ch3-rao-blackwell` @ capitulos/cap04_herramientas.typ:877 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch3_rb_insesgado` (`Cap04Suficiencia.lean`) | `cor:ch3-rb-insesgado` @ capitulos/cap04_herramientas.typ:904 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch3_lehmann_scheffe` (`Cap04Suficiencia.lean`) | `thm:ch3-lehmann-scheffe` @ capitulos/cap04_herramientas.typ:931 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch3_umvue_exponencial` (`Cap04Suficiencia.lean`) | `cor:ch3-umvue-exponencial` @ capitulos/cap04_herramientas.typ:960 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch2_basu` (`Cap04Suficiencia.lean`) | `thm:ch2-basu` @ capitulos/cap04_herramientas.typ:749 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ch3_cramer_rao` (`Cap04Suficiencia.lean`) | `thm:ch3-cramer-rao` @ capitulos/cap04_herramientas.typ:990 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch3_cr_iid` (`Cap04Suficiencia.lean`) | `cor:ch3-cr-iid` @ capitulos/cap04_herramientas.typ:1040 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch2_normal_suficiencia` (`Cap04Suficiencia.lean`) | `ex:ch2-normal-suficiencia` @ capitulos/cap04_herramientas.typ:610 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch2_poisson_suficiencia` (`Cap04Suficiencia.lean`) | `ex:ch2-poisson-suficiencia` @ capitulos/cap04_herramientas.typ:629 | enjambre smw82qi6q, dirección d4 (formalización de pendiente) | `propext, Classical.choice, Quot.sound` | OK |
| `unbiased_double_root` (`Cap04UmpuM3.lean`) | `thm:ch4-umpu` @ capitulos/cap04_herramientas.typ:1330 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `umpu_coefficient_bound` (`Cap04UmpuM3.lean`) | `thm:ch4-umpu` @ capitulos/cap04_herramientas.typ:1330 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `umpu_three_point` (`Cap04UmpuM3.lean`) | `thm:ch4-umpu` @ capitulos/cap04_herramientas.typ:1330 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `umpu_attainment` (`Cap04UmpuM3.lean`) | `thm:ch4-umpu` @ capitulos/cap04_herramientas.typ:1330 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_clt` (`Cap05Asintotica.lean`) | `thm:ch5-clt` @ capitulos/cap04_herramientas.typ:1464 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch5_clt_retornos` (`Cap05Asintotica.lean`) | `prop:ch5-clt-retornos` @ capitulos/cap04_herramientas.typ:1759 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch4_clt_mixing_var` (`Cap05Asintotica.lean`) | `thm:ch4-clt-mixing` @ capitulos/cap04_herramientas.typ:1517 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_lindeberg_feller` (`Cap05Asintotica.lean`) | `thm:ch5-lindeberg` @ capitulos/cap04_herramientas.typ:1497 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_delta` (`Cap05Asintotica.lean`) | `thm:ch5-delta` @ capitulos/cap04_herramientas.typ:1538 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_delta_multi` (`Cap05Asintotica.lean`) | `thm:ch5-delta-multi` @ capitulos/cap04_herramientas.typ:1570 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch5_delta_q` (`Cap05Asintotica.lean`) | `prop:ch5-delta-q` @ capitulos/cap04_herramientas.typ:1778 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_donsker` (`Cap05Asintotica.lean`) | `thm:ch5-donsker` @ capitulos/cap04_herramientas.typ:1658 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch5_bootstrap_media` (`Cap05Asintotica.lean`) | `thm:ch5-bootstrap-media` @ capitulos/cap04_herramientas.typ:1714 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_isomorfismo` (`Cap05Representacion.lean`) | `thm:ch9-isomorfismo` @ capitulos/cap05_incrustacion.typ:41 | piloto 2026-11-03 (m_repr) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_bayes` (`Cap05Representacion.lean`) | `cor:ch9-bayes` @ capitulos/cap05_incrustacion.typ:143 | piloto 2026-11-03 (m_bayes) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_admisibilidad` (`Cap05Representacion.lean`) | `thm:ch9-admisibilidad` @ capitulos/cap05_incrustacion.typ:136 | piloto 2026-11-03 (m_admis) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_traduccion_optimos` (`Cap05Representacion.lean`) | `cor:ch7-traduccion` @ capitulos/cap05_incrustacion.typ:183 | F0 2026-11-04 (nuevo; el piloto no cubría este corolario) | `propext, Classical.choice, Quot.sound` | OK |
| `ch7_traduccion` (`Cap05Representacion.lean`) | `cor:ch7-traduccion` @ capitulos/cap05_incrustacion.typ:183 | F0 2026-11-04 (nuevo; el piloto no cubría este corolario) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_secuencial_cota` (`Cap05Representacion.lean`) | `thm:ch9-secuencial` @ capitulos/cap05_incrustacion.typ:92 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_secuencial_alcanza` (`Cap05Representacion.lean`) | `thm:ch9-secuencial` @ capitulos/cap05_incrustacion.typ:92 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_bellman` (`Cap05Representacion.lean`) | `cor:ch9-bellman` @ capitulos/cap05_incrustacion.typ:104 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch9_ic` (`Cap06Fronteras.lean`) | `thm:ch9-ic` @ capitulos/cap06_fallos.typ:181 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch9_observabilidad_parcial` (`Cap06Fronteras.lean`) | `ex:ch9-observabilidad-parcial` @ capitulos/cap06_fallos.typ:56 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch9_confounding` (`Cap06Fronteras.lean`) | `ex:ch9-confounding` @ capitulos/cap06_fallos.typ:91 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch9_fallo_mixing` (`Cap06Fronteras.lean`) | `ex:ch9-fallo-mixing` @ capitulos/cap06_fallos.typ:240 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch9_fallo_overlap` (`Cap06Fronteras.lean`) | `ex:ch9-fallo-overlap` @ capitulos/cap06_fallos.typ:249 | F3 2026-11-05 (nuevo); la omisión de la parte (i) declarada en | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch6_memoria` (`Cap06Fronteras.lean`) | `ex:ch6-memoria` @ capitulos/cap06_fallos.typ:408 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch6_minimax_dominada` (`Cap06Fronteras.lean`) | `ex:ch6-minimax-dominada` @ capitulos/cap06_fallos.typ:551 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_horizonte_pesos_esperanza` (`Cap06PesosTasasM5.lean`) | `ex:ch6-horizonte-pesos` @ capitulos/cap06_fallos.typ:453 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_horizonte_pesos_varianza` (`Cap06PesosTasasM5.lean`) | `ex:ch6-horizonte-pesos` @ capitulos/cap06_fallos.typ:453 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_tasas_compatibles` (`Cap06PesosTasasM5.lean`) | `ex:ch6-tasas` @ capitulos/cap06_fallos.typ:486 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_tasas_incompatibles_020` (`Cap06PesosTasasM5.lean`) | `ex:ch6-tasas` @ capitulos/cap06_fallos.typ:486 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_tasas_cuarto_no_pequeno` (`Cap06PesosTasasM5.lean`) | `ex:ch6-tasas` @ capitulos/cap06_fallos.typ:486 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_tasas_parametrico` (`Cap06PesosTasasM5.lean`) | `ex:ch6-tasas` @ capitulos/cap06_fallos.typ:486 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch6_tasas_no_parametrico` (`Cap06PesosTasasM5.lean`) | `ex:ch6-tasas` @ capitulos/cap06_fallos.typ:486 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_identificacion` (`Cap07OPE.lean`) | `thm:ch10-identificacion` @ capitulos/cap07_ope.typ:140 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_identificacion_pdis` (`Cap07OPE.lean`) | `thm:ch10-identificacion` @ capitulos/cap07_ope.typ:140 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr_sesgo_m` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (corolario de ch10_dr) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_dr_sesgo_b` (`Cap07OPE.lean`) | `thm:ch10-dr` @ capitulos/cap07_ope.typ:436 | F1 2026-11-04 (corolario de ch10_dr) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_identificacion_per_decision` (`Cap07OPE.lean`) | `thm:ch10-identificacion` @ capitulos/cap07_ope.typ:140 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_is_insesgado` (`Cap07OPE.lean`) | `thm:ch10-is-insesgado` @ capitulos/cap07_ope.typ:218 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_is_varianza` (`Cap07OPE.lean`) | `thm:ch10-is-insesgado` @ capitulos/cap07_ope.typ:218 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_curse` (`Cap07OPE.lean`) | `thm:ch10-curse` @ capitulos/cap07_ope.typ:252 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_curse_ejemplo` (`Cap07OPE.lean`) | `thm:ch10-curse` @ capitulos/cap07_ope.typ:252 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch10_var_dr` (`Cap07OPE.lean`) | `prop:ch10-var-dr` @ capitulos/cap07_ope.typ:494 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_valor` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_horizonte` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_una_ronda` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_thompson` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_thompson_ultima` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_mab_mdp_thompson_mas_rondas` (`Cap08Bandits.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch8_thompson` (`Cap08Bandits.lean`) | `prop:ch8-thompson` @ capitulos/cap03_mdp.typ:154 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ssch_bandits_cap08` (`Cap08Bandits.lean`) | `ex:ssch-bandits-cap08` @ capitulos/cap03_mdp.typ:166 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `discValue_le` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `discValue_optimal` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bellman_un_estado` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `explorar_estrictamente_mejor` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp` @ capitulos/cap03_mdp.typ:141 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thompson_prob_seleccion` (`Cap08BanditsM7.lean`) | `prop:ch8-thompson` @ capitulos/cap03_mdp.typ:154 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thompson_payoff_le` (`Cap08BanditsM7.lean`) | `prop:ch8-thompson` @ capitulos/cap03_mdp.typ:154 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thompson_payoff_lt` (`Cap08BanditsM7.lean`) | `prop:ch8-thompson` @ capitulos/cap03_mdp.typ:154 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ultima_ronda` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `betaMedia_exito` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `betaMedia_martingala` (`Cap08BanditsM7.lean`) | `prop:ch8-mab-mdp-thompson` @ capitulos/cap03_mdp.typ:178 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ucb_comparacion_indices` (`Cap08BanditsM7.lean`) | `thm:ch8-ucb1` @ capitulos/cap03_mdp.typ:145 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ucb_conteo` (`Cap08BanditsM7.lean`) | `thm:ch8-ucb1` @ capitulos/cap03_mdp.typ:145 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ucb1_cota_regret` (`Cap08BanditsM7.lean`) | `thm:ch8-ucb1` @ capitulos/cap03_mdp.typ:145 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_bandits_cap08` (`Cap08BanditsM7.lean`) | `ex:ssch-bandits-cap08` @ capitulos/cap03_mdp.typ:166 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_bandits_cap08_exploracion` (`Cap08BanditsM7.lean`) | `ex:ssch-bandits-cap08` @ capitulos/cap03_mdp.typ:166 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bandit_ssch_numeros` (`Cap08BanditsM7.lean`) | `ex:ch8-bandit-ssch` @ capitulos/cap03_mdp.typ:181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bandit_ssch_diferencia` (`Cap08BanditsM7.lean`) | `ex:ch8-bandit-ssch` @ capitulos/cap03_mdp.typ:181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_impacto_sigma2` (`Cap08Ch11M10.lean`) | `prop:ch11-impacto` @ capitulos/cap08_intervalos.typ:140 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_impacto_numeros` (`Cap08Ch11M10.lean`) | `prop:ch11-impacto` @ capitulos/cap08_intervalos.typ:140 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ic_studentizacion` (`Cap08Ch11M10.lean`) | `cor:ch11-ic` @ capitulos/cap08_intervalos.typ:243 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ic_escala_episodios` (`Cap08Ch11M10.lean`) | `cor:ch11-ic` @ capitulos/cap08_intervalos.typ:243 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_n_condicion` (`Cap08Ch11M10.lean`) | `thm:ch11-n` @ capitulos/cap08_intervalos.typ:379 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_n_minimo` (`Cap08Ch11M10.lean`) | `thm:ch11-n` @ capitulos/cap08_intervalos.typ:379 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_n_ejemplos` (`Cap08Ch11M10.lean`) | `thm:ch11-n` @ capitulos/cap08_intervalos.typ:379 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_reinforce_if` (`Cap08Ch11M10.lean`) | `prop:ch11-reinforce-if` @ capitulos/cap08_intervalos.typ:519 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ssch_objetivo` (`Cap08Ch11M10.lean`) | `ex:ssch-cap11` @ capitulos/cap08_intervalos.typ:604 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ssch_pareado` (`Cap08Ch11M10.lean`) | `ex:ssch-cap11` @ capitulos/cap08_intervalos.typ:604 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ergodico_mixing` (`Cap08Ch11M10.lean`) | `prop:ch11-ergodico` @ capitulos/cap08_intervalos.typ:91 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_ergodico_geometrico` (`Cap08Ch11M10.lean`) | `prop:ch11-ergodico` @ capitulos/cap08_intervalos.typ:91 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_pg_identidad` (`Cap08Ch11M10.lean`) | `thm:ch11-pg-theorem` @ capitulos/cap08_intervalos.typ:442 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_pg_causalidad` (`Cap08Ch11M10.lean`) | `thm:ch11-pg-theorem` @ capitulos/cap08_intervalos.typ:442 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_clt_mixing_var` (`Cap08Ch11M10.lean`) | `thm:ch11-clt-mixing` @ capitulos/cap08_intervalos.typ:180 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dPhi_sum_eq_zero` (`Cap08Estimadores.lean`) | `def:ch11-var-if` @ capitulos/cap08_intervalos.typ:259 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `abs_hac_le` (`Cap08Estimadores.lean`) | `def:ch11-hac` @ capitulos/cap08_intervalos.typ:270 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `save_separacion` (`Cap08Estimadores.lean`) | `ex:ch11-ej5` @ capitulos/cap08_intervalos.typ:674 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `save_separacion_no_nula` (`Cap08Estimadores.lean`) | `ex:ch11-ej5` @ capitulos/cap08_intervalos.typ:674 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `save_separacion_pos` (`Cap08Estimadores.lean`) | `ex:ch11-ej5` @ capitulos/cap08_intervalos.typ:674 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch8_frozenlake` (`Cap08FrozenLake.lean`) | `ex:ch8-frozenlake` @ capitulos/cap03_mdp.typ:260 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_baseline` (`Cap08Intervalos.lean`) | `prop:ch11-baseline` @ capitulos/cap08_intervalos.typ:469 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_baseline_ejemplo` (`Cap08Intervalos.lean`) | `ex:ssch-drl-cap11` @ capitulos/cap08_intervalos.typ:485 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch5_cadena` (`Cap08Intervalos.lean`) | `ex:ch5-cadena` @ capitulos/cap06_fallos.typ:343 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch5_cadena_varianza_finita` (`Cap08Intervalos.lean`) | `ex:ch5-cadena` @ capitulos/cap06_fallos.typ:343 | t28 2026-11-06 (nuevo; la referencia a este teorema quedaba | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch11_pg_ssch` (`Cap08Intervalos.lean`) | `ex:ch11-pg-ssch` @ capitulos/cap08_intervalos.typ:531 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_tasa_tabular` (`Cap08Intervalos.lean`) | `thm:ch11-tasa-tabular` @ capitulos/cap08_intervalos.typ:110 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `planificacion_poder` (`Cap08Poder.lean`) | `ex:ch11-ej3` @ capitulos/cap08_intervalos.typ:662 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `planificacion_dos_grupos` (`Cap08Poder.lean`) | `ex:ch11-ej3` @ capitulos/cap08_intervalos.typ:662 | enjambre smw82qi6q, m11 | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch10_dm_bias` (`Cap10OPE.lean`) | `prop:ch10-dm` @ capitulos/cap07_ope.typ:179 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch10_dm` (`Cap10OPE.lean`) | `prop:ch10-dm` @ capitulos/cap07_ope.typ:179 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cor_ch10_curse` (`Cap10OPE.lean`) | `cor:ch10-curse` @ capitulos/cap07_ope.typ:277 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch10_is_shift` (`Cap10OPE.lean`) | `prop:ch10-is-shift` @ capitulos/cap07_ope.typ:310 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prop_ch10_dro_garantia` (`Cap10OPE.lean`) | `prop:ch10-dro-garantia` @ capitulos/cap07_ope.typ:334 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch10_truncamiento` (`Cap10OPE.lean`) | `thm:ch10-truncamiento` @ capitulos/cap07_ope.typ:582 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch10_truncamiento_var` (`Cap10OPE.lean`) | `thm:ch10-truncamiento` @ capitulos/cap07_ope.typ:582 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch10_dr_eficiencia` (`Cap10OPE.lean`) | `thm:ch10-dr-eficiencia` @ capitulos/cap07_ope.typ:464 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ssch_dist_shift_cap10` (`Cap10OPE.lean`) | `ex:ssch-dist-shift-cap10` @ capitulos/cap07_ope.typ:353 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch10_shift_ssch` (`Cap10OPE.lean`) | `ex:ch10-shift-ssch` @ capitulos/cap07_ope.typ:393 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ch10_pipeline` (`Cap10OPE.lean`) | `ex:ch10-pipeline` @ capitulos/cap07_ope.typ:658 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ex_ssch_cap10` (`Cap10OPE.lean`) | `ex:ssch-cap10` @ capitulos/cap07_ope.typ:715 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_cuantizacion_ejemplo` (`Cap11Despliegue.lean`) | `cap11-cuantizacion` @ capitulos/cap11_despliegue.typ:97 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_truncamiento` (`Cap11Despliegue.lean`) | `cap11-truncamiento` @ capitulos/cap11_despliegue.typ:167 | F3 2026-11-05 (nuevo) | `propext` | OK |
| `ch11_monitoreo` (`Cap11Despliegue.lean`) | `cap11-monitoreo` @ capitulos/cap11_despliegue.typ:611 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_mdp_validacion` (`Cap11Despliegue.lean`) | `def:appE-mdp-test` @ capitulos/cap11_despliegue.typ:273 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ch11_margen_elemental` (`Cap11Despliegue.lean`) | `cap11-margen` @ capitulos/cap08_intervalos.typ:353 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `hac_error_bound` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `taper_tendsto_zero` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `hacEst_tendsto` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `thm_ch11_var_consistente` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `longRun_ar1` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `hacEst_ar1_tendsto` (`Cap11HacM1.lean`) | `thm:ch11-var-consistente` @ capitulos/cap08_intervalos.typ:282 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_pomdp_identification` (`Cap12Problemas.lean`) | `thm:ch12-pomdp-identification` @ capitulos/cap12_problemas.typ:130 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_logprobs` (`Cap12Problemas.lean`) | `prop:ch12-logprobs` @ capitulos/cap12_problemas.typ:189 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_logprobs_limite` (`Cap12Problemas.lean`) | `prop:ch12-logprobs` @ capitulos/cap12_problemas.typ:189 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_sesgo_disc_finito` (`Cap12Problemas.lean`) | `prop:ch12-sesgo-disc` @ capitulos/cap12_problemas.typ:230 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_sesgo_disc_descontado` (`Cap12Problemas.lean`) | `prop:ch12-sesgo-disc` @ capitulos/cap12_problemas.typ:230 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ch12_sesgo_disc_descontado_valor` (`Cap12Problemas.lean`) | `prop:ch12-sesgo-disc` @ capitulos/cap12_problemas.typ:230 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bias_eq` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `confound_naive_biased` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `confound_misma_ley` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `confound_ate_distintos` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `confound_no_identificable` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `confound_sesgo_cambia_de_signo` (`Cap12ProblemasM8.lean`) | `ex:ssch-confound` @ capitulos/cap12_problemas.typ:107 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdpValue_eq_stateValue` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdp_parcial_toda_politica` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdp_estado_valor` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdp_perdida_estricta` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdp_sin_perdida_si_observa` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `pomdp_informativo_alcanza` (`Cap12ProblemasM8.lean`) | `ex:ssch-pomdp` @ capitulos/cap12_problemas.typ:155 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aipw_eq_of_propensity` (`Cap12ProblemasM8.lean`) | `ex:ssch-reliable` @ capitulos/cap12_problemas.typ:378 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aipw_eq_of_outcome` (`Cap12ProblemasM8.lean`) | `ex:ssch-reliable` @ capitulos/cap12_problemas.typ:378 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aipw_double_robust` (`Cap12ProblemasM8.lean`) | `ex:ssch-reliable` @ capitulos/cap12_problemas.typ:378 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aipw_witness_modelo_malo` (`Cap12ProblemasM8.lean`) | `ex:ssch-reliable` @ capitulos/cap12_problemas.typ:378 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `selected_sound` (`Cap12ProblemasM8.lean`) | `ex:ssch-integration` @ capitulos/cap12_problemas.typ:425 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `error_propagation` (`Cap12ProblemasM8.lean`) | `ex:ssch-integration` @ capitulos/cap12_problemas.typ:425 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rule_may_abstain` (`Cap12ProblemasM8.lean`) | `ex:ssch-integration` @ capitulos/cap12_problemas.typ:425 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `clipping_sesgo_negativo` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `clipping_ejemplo` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `geom_sum_le_inv` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `discounted_tail_bound` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `doce_pasos_no_es_infinito` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `doce_pasos_cola_es_la_cota` (`Cap12ProblemasM8.lean`) | `ex:ssch-limitations` @ capitulos/cap12_problemas.typ:467 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `stepValue_add` (`Cap12ProblemasM8.lean`) | `ex:ssch-cap12` @ capitulos/cap12_problemas.typ:482 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `stepValue_mono` (`Cap12ProblemasM8.lean`) | `ex:ssch-cap12` @ capitulos/cap12_problemas.typ:482 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ic_no_cubre_otro_procedimiento` (`Cap12ProblemasM8.lean`) | `ex:ssch-cap12` @ capitulos/cap12_problemas.typ:482 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `perdidas_comunes_no_negativas` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-perdidas-comunes` @ capitulos/cap04_herramientas.typ:281 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `perdidas_comunes_ecm_descomposicion` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-perdidas-comunes` @ capitulos/cap04_herramientas.typ:281 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `perdidas_comunes_cero_uno_complemento` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-perdidas-comunes` @ capitulos/cap04_herramientas.typ:281 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `suficiente_estadistico_natural` (`Ch1Ch2Pendientes.lean`) | `thm:ch1-suficiencia-natural` @ capitulos/cap04_herramientas.typ:402 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normalGamma_formulas` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-normal-gamma` @ capitulos/cap04_herramientas.typ:485 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normalGamma_precision_crece` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-normal-gamma` @ capitulos/cap04_herramientas.typ:485 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normalGamma_beta_no_decrece` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-normal-gamma` @ capitulos/cap04_herramientas.typ:485 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normalGamma_invariante` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-normal-gamma` @ capitulos/cap04_herramientas.typ:485 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normalGamma_varianza_pos` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-normal-gamma` @ capitulos/cap04_herramientas.typ:485 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tBase_pos` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tBase_even` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tLocEscala_traslacion` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tLocEscala_escala` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tBase_cola_superior` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tBase_cola_inferior` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-t-student` @ capitulos/cap04_herramientas.typ:535 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mezcla_normal_densidad` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-mezcla-normal` @ capitulos/cap04_herramientas.typ:555 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mezcla_normal_varianza_total` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-mezcla-normal` @ capitulos/cap04_herramientas.typ:555 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gumbel_max_estable` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-gumbel` @ capitulos/cap04_herramientas.typ:573 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gumbel_suficiencia_escala` (`Ch1Ch2Pendientes.lean`) | `ex:ch1-gumbel` @ capitulos/cap04_herramientas.typ:573 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_regla_bayes_valores` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_sesgo` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_varianza` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_riesgo_constante` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_riesgo_identidad` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_identidad_riesgo_max` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bernoulli_contraccion_mejora_peor_caso` (`Ch2Pendientes.lean`) | `ex:ch2-bernoulli-minimax` @ capitulos/cap02_wald.typ:139 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `exponencial_cociente` (`Ch2Pendientes.lean`) | `ex:ch2-minimal-exponencial` @ capitulos/cap04_herramientas.typ:667 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `exponencial_minimal` (`Ch2Pendientes.lean`) | `ex:ch2-minimal-exponencial` @ capitulos/cap04_herramientas.typ:667 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_normalizacion` (`Ch2Pendientes.lean`) | `ex:ch2-multinomial-ssch` @ capitulos/cap04_herramientas.typ:718 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_referencia` (`Ch2Pendientes.lean`) | `ex:ch2-multinomial-ssch` @ capitulos/cap04_herramientas.typ:718 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_factorizacion` (`Ch2Pendientes.lean`) | `ex:ch2-multinomial-ssch` @ capitulos/cap04_herramientas.typ:718 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_gibbs` (`Ch2Pendientes.lean`) | `ex:ch2-multinomial-ssch` @ capitulos/cap04_herramientas.typ:718 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_mle_instancia` (`Ch2Pendientes.lean`) | `ex:ch2-multinomial-ssch` @ capitulos/cap04_herramientas.typ:718 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `media_traslacion` (`Ch2Pendientes.lean`) | `ex:ch2-ancilar-localizacion` @ capitulos/cap04_herramientas.typ:736 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `residuos_traslacion` (`Ch2Pendientes.lean`) | `ex:ch2-ancilar-localizacion` @ capitulos/cap04_herramientas.typ:736 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `residuos_formula` (`Ch2Pendientes.lean`) | `ex:ch2-ancilar-localizacion` @ capitulos/cap04_herramientas.typ:736 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `residuos_suma_cero` (`Ch2Pendientes.lean`) | `ex:ch2-ancilar-localizacion` @ capitulos/cap04_herramientas.typ:736 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normal_factorizacion` (`Ch2Pendientes.lean`) | `ex:ch2-basu-aplicacion` @ capitulos/cap04_herramientas.typ:774 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normal_varianza_media` (`Ch2Pendientes.lean`) | `ex:ch2-basu-aplicacion` @ capitulos/cap04_herramientas.typ:774 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `normal_varianza_invariante` (`Ch2Pendientes.lean`) | `ex:ch2-basu-aplicacion` @ capitulos/cap04_herramientas.typ:774 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `suficiencia_politicas` (`Ch2Pendientes.lean`) | `prop:ch2-suficiencia-politicas` @ capitulos/cap09_verificacion.typ:227 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_covarianzas_sumables` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_varianza_finita` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_varianza_media` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_semiancho` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_geometrico` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lr_cadena2_libro` (`Ch5CltAgentesM5.lean`) | `thm:ch5-clt-agentes` @ capitulos/cap06_fallos.typ:324 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_forma_cuadratica` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_sigma2` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_sigma2_matricial` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_sigma2_sin_covarianza` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_sigma_redondeo` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_ic_semiancho` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_varianza_estimador` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `qdelta_subestimacion` (`Ch5EjemplosM5.lean`) | `ex:ch5-qdelta` @ capitulos/cap04_herramientas.typ:1799 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `icPercT_mem_iff` (`Ch5EjemplosM5.lean`) | `def:ch5-ic-t` @ capitulos/cap04_herramientas.typ:1739 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `icPercT_extremos` (`Ch5EjemplosM5.lean`) | `def:ch5-ic-t` @ capitulos/cap04_herramientas.typ:1739 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `icPercT_contiene_estimador` (`Ch5EjemplosM5.lean`) | `def:ch5-ic-t` @ capitulos/cap04_herramientas.typ:1739 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `icPercT_simetrico` (`Ch5EjemplosM5.lean`) | `def:ch5-ic-t` @ capitulos/cap04_herramientas.typ:1739 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `banda_iff_ksStat` (`Ch5EjemplosM5.lean`) | `ex:ch5-bandas` @ capitulos/cap04_herramientas.typ:1676 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `banda_falla_iff` (`Ch5EjemplosM5.lean`) | `ex:ch5-bandas` @ capitulos/cap04_herramientas.typ:1676 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ksQuantile_spec` (`Ch5EjemplosM5.lean`) | `ex:ch5-bandas` @ capitulos/cap04_herramientas.typ:1676 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gc_engine` (`Ch5GcM5.lean`) | `thm:ch5-gc` @ capitulos/cap04_herramientas.typ:1624 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gc_uniform` (`Ch5GcM5.lean`) | `thm:ch5-gc` @ capitulos/cap04_herramientas.typ:1624 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `gc_pointwise` (`Ch5GcM5.lean`) | `thm:ch5-gc` @ capitulos/cap04_herramientas.typ:1624 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `comp_continuous` (`ConvergenciaBase.lean`) | `der:convprob-continuous` @ capitulos/cap04_herramientas.typ:1667 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `consistencia_plug_in` (`ConvergenciaBase.lean`) | `der:convprob-plug-in` @ capitulos/cap09_verificacion.typ | ? | `propext, Classical.choice, Quot.sound` | OK |
| `consistencia_chebyshev` (`ConvergenciaBase.lean`) | `der:convprob-chebyshev` @ apendices/apendice_demostraciones.typ:547 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `posterior_parametros` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `posterior_total` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prior_total` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `posterior_media` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `posterior_media_suma` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `prior_uniforme` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `posterior_varianza_segunda` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dirichlet_no_factoriza` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dKl_no_negativo` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dKl_self` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `aTot_pos` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dMean_pos` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dMean_suma` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `kl_minimo_global_cero` (`M13Mcmc.lean`) | `ex:ssch-mcmc-vi-cap03` @ capitulos/cap04_herramientas.typ:1151 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `logitDen_pos` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `logitSSCH_pos` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `logitSSCH_suma` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ellSSCH_eq_conteos` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ellSSCH_cero` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ellSSCH_decima` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ellSSCH_diferencia` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `exp_decima_cota` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ellSSCH_diferencia_pos` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mh_paso_ssch_acepta_uno` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mhAlpha_mem_Icc` (`M13Mcmc.lean`) | `def:ch3-mh` @ capitulos/cap04_herramientas.typ:1115 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mhAlpha_exp_simetrica` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mul_min_one` (`M13Mcmc.lean`) | `def:ch3-mh` @ capitulos/cap04_herramientas.typ:1115 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mh_detailed_balance` (`M13Mcmc.lean`) | `def:ch3-mh` @ capitulos/cap04_herramientas.typ:1115 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mh_estacionaria` (`M13Mcmc.lean`) | `def:ch3-mh` @ capitulos/cap04_herramientas.typ:1115 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `mhAlpha_ssch_paso` (`M13Mcmc.lean`) | `ex:ch3-mcmc-ssch` @ capitulos/cap04_herramientas.typ:1181 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_psi` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_p_tratado` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_estratos_tratados` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_estratos_no_tratados` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_media_tratados` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_media_no_tratados` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_diferencia_cruda` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_descomposicion` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cap06_sesgo_confusion` (`M9Pendientes.lean`) | `ex:ssch-causal-cap06` @ capitulos/cap04_herramientas.typ:2061 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_prob_independiente_del_basal` (`M9Pendientes.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_denominador_pos` (`M9Pendientes.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cox_parcial_invariante` (`M9Pendientes.lean`) | `ex:ch6-cox` @ capitulos/cap04_herramientas.typ:1840 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ope_determinado_por_tablas` (`M9Pendientes.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ope_escalar_no_determina_funcional` (`M9Pendientes.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `bellman_unique` (`M9Pendientes.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ope_expansion_dos_pasos` (`M9Pendientes.lean`) | `ex:ch6-ope` @ capitulos/cap04_herramientas.typ:1848 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `multinomial_cov_fila` (`M9Pendientes.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_estocastica` (`M9Pendientes.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_valor_bellman` (`M9Pendientes.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_valor_unico` (`M9Pendientes.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_J` (`M9Pendientes.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_regla_ordinario` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_regla_intensificado` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_regla_seguir` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_regla_invertir` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_posterior` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_perdidas_posteriores` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_umbral` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_bayes_sigue` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_retornos` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_secuencial` (`SSCH.lean`) | `ex:ssch-cap09` @ capitulos/cap05_incrustacion.typ:262 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_minimax_riesgos` (`SSCH.lean`) | `ex:ssch-cap07` @ capitulos/cap02_wald.typ:184 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_minimax_certificado` (`SSCH.lean`) | `ex:ssch-cap07` @ capitulos/cap02_wald.typ:184 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_minimax_cota` (`SSCH.lean`) | `ex:ssch-cap07` @ capitulos/cap02_wald.typ:184 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_minimax` (`SSCH.lean`) | `ex:ssch-cap07` @ capitulos/cap02_wald.typ:184 | F1 2026-11-04 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `ssch_mdp_bellman` (`SSCH.lean`) | `ex:ssch-cap08` @ capitulos/cap03_mdp.typ:243 | F3 2026-11-05 (nuevo) | `propext, Classical.choice, Quot.sound` | OK |
| `smoothRow_sum` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `Pssch_row_sum` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `smoothRow_ge` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `Pssch_ge` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `Pssch_ge_four_thousandths` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rSSCH_s1` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rSSCH_s3` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rSSCH_s5` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `Pssch_card_rows` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `Pssch_free_params` (`SSCHCap01M7.lean`) | `ex:ssch-cap01` @ capitulos/cap10_casos.typ:36 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lik_eq_prod_cnt` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `lik_eq_of_cnt_eq` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cnt_eq_of_eq` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `diseno_filas_total` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `cien_conteos` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `razon_media_no_es_media_razones` (`SSCHCap02M7.lean`) | `ex:ssch-cap02` @ capitulos/cap10_casos.typ:70 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `freq_sum` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `freq_nonneg` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `exMean_indicator` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `exCov_indicator` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `eq_zero_of_contract` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `value_unique` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `value_bound` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `viter_contract` (`SSCHCap03M7.lean`) | `ex:ssch-cap03-b` @ capitulos/cap10_casos.typ:98 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `seDelta_pos` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ci95_lo` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ci95_hi` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ci95_excluye_cero` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `regla_decision` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rechazo_unilateral` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `unilateral_positivo` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `limite_decreciente_en_se` (`SSCHCap0405M7.lean`) | `ex:ssch-cap04-b` @ capitulos/cap10_casos.typ:125 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dV_unique` (`SSCHCap0405M7.lean`) | `ex:ssch-cap05-b` @ capitulos/cap10_casos.typ:148 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `resolvent_formula` (`SSCHCap0405M7.lean`) | `ex:ssch-cap05-b` @ capitulos/cap10_casos.typ:148 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `rowsum_zero_perturbation` (`SSCHCap0405M7.lean`) | `ex:ssch-cap05-b` @ capitulos/cap10_casos.typ:148 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `perturbation_single_entry` (`SSCHCap0405M7.lean`) | `ex:ssch-cap05-b` @ capitulos/cap10_casos.typ:148 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `sum_mul_add` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ratio_substitution` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_centering` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dr_unbiased` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `valor_integrado` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `obsLaw_igual` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `tgtLaw_distinto` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `no_identificacion_sin_positividad` (`SSCHCap06M7.lean`) | `ex:ssch-cap06` @ capitulos/cap10_casos.typ:312 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `media_eq` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `varPob_eq` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `se_sq` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `se_bounds` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `ic95_bounds` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `limite_unilateral` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dictamen_margen_040` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `dictamen_margen_047` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `umbral_del_dictamen` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `varIns_eq` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |
| `correccion_no_nula` (`SSCHEjemplosM7.lean`) | `ex:ssch-trazability` @ capitulos/cap09_verificacion.typ:631 | ? | `propext, Classical.choice, Quot.sound` | OK |

## Cobertura por módulo

| Módulo | Teoremas `book:` | Claves |
|---|---|---|
| `ApendiceDIbragimov.lean` | 1 | 1 |
| `ApendiceEHilbert.lean` | 13 | 3 |
| `ApendiceEMedido.lean` | 42 | 6 |
| `ApendiceEMedidoDctM5.lean` | 9 | 1 |
| `AppDHacM9.lean` | 2 | 1 |
| `AppEFuncionImplicita.lean` | 4 | 1 |
| `AppEFuncionImplicitaCond.lean` | 6 | 1 |
| `AppERNM3.lean` | 27 | 1 |
| `BarridoM16.lean` | 20 | 7 |
| `Cap02M11.lean` | 9 | 2 |
| `Cap02Wald.lean` | 10 | 6 |
| `Cap03MDP.lean` | 15 | 13 |
| `Cap03MleM4.lean` | 21 | 3 |
| `Cap04BhM3.lean` | 3 | 1 |
| `Cap04Ch4M6.lean` | 15 | 5 |
| `Cap04Ch6.lean` | 24 | 10 |
| `Cap04Ch6DmlM5.lean` | 4 | 1 |
| `Cap04Ch6Motivacion.lean` | 7 | 1 |
| `Cap04Ejemplos.lean` | 22 | 11 |
| `Cap04EjemplosM2.lean` | 34 | 8 |
| `Cap04Herramientas.lean` | 11 | 9 |
| `Cap04LoteM16.lean` | 5 | 5 |
| `Cap04MedibleIntuicionM10.lean` | 18 | 1 |
| `Cap04Suficiencia.lean` | 13 | 12 |
| `Cap04UmpuM3.lean` | 4 | 1 |
| `Cap05Asintotica.lean` | 9 | 9 |
| `Cap05Representacion.lean` | 8 | 6 |
| `Cap06Fronteras.lean` | 7 | 7 |
| `Cap06PesosTasasM5.lean` | 7 | 2 |
| `Cap07OPE.lean` | 11 | 5 |
| `Cap08Bandits.lean` | 9 | 4 |
| `Cap08BanditsM7.lean` | 17 | 6 |
| `Cap08Ch11M10.lean` | 15 | 8 |
| `Cap08Estimadores.lean` | 5 | 3 |
| `Cap08FrozenLake.lean` | 1 | 1 |
| `Cap08Intervalos.lean` | 6 | 5 |
| `Cap08Poder.lean` | 2 | 1 |
| `Cap10OPE.lean` | 12 | 10 |
| `Cap11Despliegue.lean` | 5 | 5 |
| `Cap11HacM1.lean` | 6 | 1 |
| `Cap12Problemas.lean` | 6 | 3 |
| `Cap12ProblemasM8.lean` | 28 | 6 |
| `Ch1Ch2Pendientes.lean` | 19 | 6 |
| `Ch2Pendientes.lean` | 22 | 6 |
| `Ch5CltAgentesM5.lean` | 6 | 1 |
| `Ch5EjemplosM5.lean` | 15 | 3 |
| `Ch5GcM5.lean` | 3 | 1 |
| `ConvergenciaBase.lean` | 3 | 3 |
| `M13Mcmc.lean` | 30 | 3 |
| `M9Pendientes.lean` | 21 | 4 |
| `SSCH.lean` | 15 | 3 |
| `SSCHCap01M7.lean` | 10 | 1 |
| `SSCHCap02M7.lean` | 6 | 1 |
| `SSCHCap03M7.lean` | 8 | 1 |
| `SSCHCap0405M7.lean` | 12 | 2 |
| `SSCHCap06M7.lean` | 8 | 1 |
| `SSCHEjemplosM7.lean` | 11 | 1 |

## Cobertura del inventario (plan §2)

- **P1**: 14/14 filas completadas
- **P2**: 13/13 filas completadas
- **P3**: 8/8 filas completadas
- **Total**: 35/35 filas · 35 claves del libro completadas

## En progreso (teoremas parciales)


Axiomas esperados en toda fila: `propext, Classical.choice, Quot.sound`.
