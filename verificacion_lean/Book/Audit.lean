import Book.Cap02Wald
import Book.Cap04Herramientas
import Book.Cap08Intervalos
import Book.Cap11Despliegue
import Book.SSCH
import Book.Cap06Fronteras
import Book.Cap07OPE
import Book.ApendiceDRegularidad

/-! # Book.Audit — auditoría de axiomas del proyecto (plan §6) -/

#print axioms ch9_isomorfismo
#print axioms ch9_bayes
#print axioms ch9_admisibilidad
#print axioms ch7_traduccion_optimos
#print axioms ch7_traduccion
#print axioms ch10_identificacion
#print axioms ch10_identificacion_pdis
#print axioms ch10_dr
#print axioms ch10_dr_sesgo_m
#print axioms ch10_dr_sesgo_b
#print axioms ch9_ic
#print axioms ch10_identificacion_per_decision
#print axioms ch10_is_insesgado
#print axioms ch10_is_varianza
#print axioms ch9_secuencial_cota
#print axioms ch9_secuencial_alcanza
#print axioms ch9_bellman
#print axioms ch8_mejora
#print axioms ch8_pi_finita_sin_repeticion
#print axioms ch8_pi_finita_conteo
#print axioms ch8_pi_finita_optimo
#print axioms ch8_contraccion
#print axioms ch8_punto_fijo_unico
#print axioms ch8_parada
#print axioms Qpi
#print axioms prop_ch8_VQ
#print axioms ch8_bellman_pi
#print axioms ch8_vi_conv
#print axioms ch8_principio
#print axioms ch8_bellman_opt
#print axioms prop_ch8_perdida
#print axioms ch8_condiciones_contraccion
#print axioms ch10_curse
#print axioms ch10_curse_ejemplo
#print axioms ssch_regla_ordinario
#print axioms ssch_regla_intensificado
#print axioms ssch_regla_seguir
#print axioms ssch_regla_invertir
#print axioms ssch_posterior
#print axioms ssch_perdidas_posteriores
#print axioms ssch_umbral
#print axioms ssch_bayes_sigue
#print axioms ssch_retornos
#print axioms ssch_secuencial
#print axioms ssch_minimax_riesgos
#print axioms ssch_minimax_certificado
#print axioms ssch_minimax_cota
#print axioms ssch_minimax
#print axioms ch7_bayes
#print axioms postMean
#print axioms cor_ch7_bayes_cuadratica
#print axioms cor_ch7_bayes_mediana
#print axioms postMass
#print axioms cor_ch7_bayes_moda
#print axioms cor_ch7_bayes_especificas
#print axioms ch7_minimax_bayes
#print axioms ch7_minimax_bayes_constante
#print axioms ch7_admisibilidad_bayes
#print axioms ch7_complete_class_bayes
#print axioms ch7_complete_class_esencial
#print axioms prop_ch4_test_decision
#print axioms ex_ch9_observabilidad_parcial
#print axioms ex_ch9_confounding
#print axioms ex_ch9_fallo_mixing
#print axioms ex_ch9_fallo_overlap
#print axioms ex_ch9_fallo_overlap_instancia
#print axioms ex_ch6_memoria
#print axioms ex_ch6_minimax_dominada
#print axioms ch10_var_dr
#print axioms ssch_mdp_bellman
#print axioms ch11_baseline
#print axioms ch11_baseline_ejemplo
#print axioms ex_ch5_cadena
#print axioms ex_ch5_cadena_varianza_finita
#print axioms ex_ch11_pg_ssch
#print axioms ch11_tasa_tabular
#print axioms ch11_cuantizacion_ejemplo
#print axioms ch11_truncamiento
#print axioms ch11_monitoreo
#print axioms ch11_mdp_validacion
#print axioms ch11_margen_elemental
#print axioms prop_ch8_acotacion
#print axioms ch1_logparticion
#print axioms cor_ch1_covarianza_hessiano
#print axioms ch4_bonferroni
#print axioms ch2_neyman_fisher
#print axioms ch2_completitud_const
#print axioms tendsto_exp_mul_neg
#print axioms ch2_completitud_exponencial
#print axioms fiber_weight_pos
#print axioms ch2_completitud_exponencial_pointwise

/-! ## Apéndice D — condiciones de regularidad y mixing -/

#print axioms Book.ApendiceD.relaciones
#print axioms Book.ApendiceD.two_mul_alpha_le_beta
#print axioms Book.ApendiceD.beta_le_phi
#print axioms Book.ApendiceD.beta_libro_atomo
#print axioms Book.ApendiceD.two_mul_alphaFam_le_betaFam
#print axioms Book.ApendiceD.betaFam_le_phiFam
#print axioms Book.ApendiceD.tendsto_alpha_of_tendsto_phi
#print axioms Book.ApendiceD.summable_rpow_of_geometric
#print axioms Book.ApendiceD.tsum_rpow_geometric
#print axioms Book.ApendiceD.irreducible_iff_fuertementeConexo
#print axioms Book.ApendiceD.mdp_irreducible_iff
#print axioms Book.ApendiceD.aperiodic_of_selfloop
#print axioms Book.ApendiceD.return_eventually_pos
