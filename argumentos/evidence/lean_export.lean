/-
  Exporter de declaraciones elaboradas — F3 (docs/05_EVIDENCIA.md).

  Emite UNA LÍNEA JSON por objetivo (JSONL) a stdout: nombre
  fully-qualified, tipo elaborado serializado de manera estable para este
  entorno (Expr crudo), dependencias directas del enunciado y axiomas
  transitivos. Este archivo ES el vínculo semántico: consulta el entorno
  elaborado vía las APIs públicas de Lean; nada de regex sobre mensajes de
  consola ajenos.

  Los objetivos son TODOS los teoremas con book_key en verificacion_lean
  285 teoremas en total.
-/
import Book.Cap02Wald
import Book.Cap03MDP
import Book.Cap04Herramientas
import Book.Cap04Suficiencia
import Book.Cap04LoteM16
import Book.Cap04Ch6
import Book.Cap05Asintotica
import Book.Cap04Ejemplos
import Book.Cap05Representacion
import Book.Cap06Fronteras
import Book.Cap07OPE
import Book.Cap08Intervalos
import Book.Cap08Estimadores
import Book.Cap08Poder
import Book.Cap08M6
import Book.Cap11Despliegue
import Book.ApendiceDRegularidad
import Book.Cap03MleM4
import Book.Cap04Ch6DmlM5
import Book.Cap06PesosTasasM5
import Book.Cap04EjemplosM2
import Book.M9Pendientes
import Book.Cap04UmpuM3
import Book.Cap04BhM3
import Book.SSCHEjemplosM7
import Book.SSCHCap06M7
import Book.SSCHCap0405M7
import Book.SSCHCap03M7
import Book.SSCHCap02M7
import Book.SSCHCap01M7
import Book.AppEFuncionImplicitaCond
import Book.AppEFuncionImplicita
import Book.Cap12ProblemasM8
import Book.ApendiceEMedido
import Book.Cap06FallosM6
import Book.M13Mcmc
import Book.ConvergenciaBase
import Book.Cap11HacM1
import Book.Cap04Ch4M6
import Book.Cap08FrozenLake
import Book.ApendiceDErgodicidad
import Book.ApendiceDViolaciones
import Book.Ch2Pendientes
import Book.Ch1Ch2Pendientes
import Book.Cap08BanditsM7
import Book.Ch5CltAgentesM5
import Book.Ch5GcM5
import Book.Ch5EjemplosM5
import Book.Cap10OPE
import Book.Cap08Ch11M10
import Book.Cap02M11
import Book.BarridoM16
import Book.Cap12Problemas
import Book.SSCH
import Book.Cap03LaiRobbinsM7
import Book.AppDHacM9
import Book.Cap04MedibleIntuicionM10
import Book.AppERNM3
import Book.ApendiceEMedidoDctM5
import Book.ApendiceDIbragimov
import Book.GordinCoreM8
import Book.Cap04Ch6Motivacion
import Book.ApendiceEHilbert
import Lean.Util.CollectAxioms
import Lean.Util.FoldConsts

open Lean Elab Command Meta

namespace Argumentos.Exportador

/-- Objetivos del piloto (cuatro claves, cinco teoremas). -/
def objetivos : List Name := [
  `ch12_pomdp_identification,
  `ch12_logprobs,
  `ch12_sesgo_disc_descontado_valor,
  `Book.BarridoM16.suf_suficiencia_politicas,
  `Book.BarridoM16.rb_q,
  `Book.BarridoM16.cr_cota,
  `Book.BarridoM16.ar1_tau2,
  `Book.BarridoM16.no_param_kernel_h06,
  `Book.BarridoM16.if_cuantil_varianza,
  `Book.BarridoM16.bootstrap_prob_igual,
  `Cap02M11.ex_ch7_perdidas,
  `Cap02M11.james_stein_riesgo,
  `Ch11M10.ch11_impacto_sigma2,
  `Ch11M10.ch11_ic_studentizacion,
  `Ch11M10.ch11_n_condicion,
  `Ch11M10.ch11_reinforce_if,
  `Ch11M10.ch11_ssch_objetivo,
  `Ch11M10.ch11_ergodico_mixing,
  `Ch11M10.ch11_pg_identidad,
  `Ch11M10.ch11_clt_mixing_var,
  `Book.Cap10OPE.prop_ch10_dm,
  `Book.Cap10OPE.cor_ch10_curse,
  `Book.Cap10OPE.prop_ch10_is_shift,
  `Book.Cap10OPE.prop_ch10_dro_garantia,
  `Book.Cap10OPE.thm_ch10_truncamiento,
  `Book.Cap10OPE.thm_ch10_dr_eficiencia,
  `Book.Cap10OPE.ex_ssch_dist_shift_cap10,
  `Book.Cap10OPE.ex_ch10_shift_ssch,
  `Book.Cap10OPE.ex_ch10_pipeline,
  `Book.Cap10OPE.ex_ssch_cap10,
  `BookCh5M5.qdelta_sigma2,
  `BookCh5M5.icPercT_mem_iff,
  `BookCh5M5.banda_iff_ksStat,
  `BookCh5GcM5.gc_engine,
  `BookCh5CltAgentesM5.lr_cadena2_libro,
  `Cap08Bandits.discValue_le,
  `Cap08Bandits.ucb_comparacion_indices,
  `Cap08Bandits.thompson_prob_seleccion,
  `Cap08Bandits.ultima_ronda,
  `Cap08Bandits.ssch_bandits_cap08,
  `Cap08Bandits.bandit_ssch_numeros,
  `Book.Cap04Ch1Ch2.perdidas_comunes_no_negativas,
  `Book.Cap04Ch1Ch2.suficiente_estadistico_natural,
  `Book.Cap04Ch1Ch2.normalGamma_formulas,
  `Book.Cap04Ch1Ch2.tBase_pos,
  `Book.Cap04Ch1Ch2.mezcla_normal_densidad,
  `Book.Cap04Ch1Ch2.gumbel_max_estable,
  `Book.Cap04Ch2.bernoulli_riesgo_constante,
  `Book.Cap04Ch2.exponencial_minimal,
  `Book.Cap04Ch2.multinomial_factorizacion,
  `Book.Cap04Ch2.media_traslacion,
  `Book.Cap04Ch2.normal_factorizacion,
  `Book.Cap04Ch2.suficiencia_politicas,
  `Book.ApendiceDM3.irreducible_dos_clases_absorbentes,
  `Book.ApendiceDM3.aperiodico_oscilante,
  `Book.ApendiceDM3.summable_potencia_alpha,
  `Book.ApendiceDM3.ergodico_geometrico,
  `Book.ApendiceDM3.mdp_finito_mixing,
  `Book.Ch8Bandits.ex_ch8_frozenlake,
  `Cap04M6.gauss_loglik_max,

  `ch1_logparticion,
  `cor_ch1_covarianza_hessiano,
  `ch4_bonferroni,
  `ch2_neyman_fisher,
  `ch2_completitud_exponencial,
  `ch10_curse,
  `ch10_dr,
  `ch10_identificacion,
  `ch10_is_insesgado,
  `ch10_var_dr,
  `prop_ch4_test_decision,
  `prop_ch3_info_aditiva,
  `cor_ch4_exp_mlr,
  `thm_ch4_inversion_simple,
  `cor_ch4_ic_z_simple,
  `ch11_baseline,
  `ch11_baseline_ejemplo,
  `ch11_cuantizacion_ejemplo,
  `ch11_margen_elemental,
  `ch11_mdp_validacion,
  `ch11_monitoreo,
  `ch11_tasa_tabular,
  `ch11_truncamiento,
  `ch7_admisibilidad_bayes,
  `ch7_bayes,
  `ch7_complete_class_bayes,
  `ch7_minimax_bayes,
  `ch7_traduccion_optimos,
  `ch8_bellman_pi,
  `ch8_bellman_opt,
  `prop_ch8_perdida,
  `ch8_condiciones_contraccion,
  `ch8_contraccion,
  `ch8_mejora,
  `ch8_parada,
  `ch8_pi_finita_sin_repeticion,
  `ch8_principio,
  `ch8_punto_fijo_unico,
  `ch8_vi_conv,
  `ch9_admisibilidad,
  `ch9_bayes,
  `ch9_bellman,
  `ch9_ic,
  `ch9_isomorfismo,
  `ch9_secuencial_cota,
  `cor_ch7_bayes_especificas,
  `ex_ch11_pg_ssch,
  `ex_ch5_cadena,
  `ex_ch6_memoria,
  `ex_ch6_minimax_dominada,
  `ex_ch9_confounding,
  `ex_ch9_fallo_mixing,
  `ex_ch9_fallo_overlap,
  `ex_ch9_observabilidad_parcial,
  `prop_ch8_VQ,
  `prop_ch8_acotacion,
  `ssch_mdp_bellman,
  `ssch_minimax_riesgos,
  `ssch_regla_ordinario,
  `Book.ApendiceD.relaciones,
  `Book.ApendiceD.irreducible_iff_fuertementeConexo,
  `Book.ApendiceD.aperiodic_of_selfloop,
  `Book.ApendiceD.summable_rpow_of_geometric,
  `Cap08Estimadores.dPhi_sum_eq_zero,
  `Cap08Estimadores.abs_hac_le,
  `Cap08Estimadores.save_separacion,
  `Cap08Poder.planificacion_poder,
  `Book.Cap04Suficiencia.ch2_lehmann_scheffe_criterio,
  `Book.Cap04Suficiencia.ch2_lehmann_scheffe_minimal,
  `Book.Cap04Suficiencia.cor_ch2_smc,
  `Book.Cap04Suficiencia.ex_ch2_normal_suficiencia,
  `Book.Cap04Suficiencia.ex_ch2_poisson_suficiencia,
  `Book.Cap04Suficiencia.ch2_basu,
  `Book.Cap04Suficiencia.ch2_equivarianza,
  `Book.Cap04Suficiencia.ch3_rao_blackwell,
  `Book.Cap04Suficiencia.cor_ch3_rb_insesgado,
  `Book.Cap04Suficiencia.ch3_lehmann_scheffe,
  `Book.Cap04Suficiencia.cor_ch3_umvue_exponencial,
  `Book.Cap04Suficiencia.ch3_cramer_rao,
  `Book.Cap04Suficiencia.cor_ch3_cr_iid,
  `Cap04M16.ch4_neyman_pearson,
  `Cap04M16.ch4_multiplicidad,
  `Cap04M16.ch4_holm,
  `Cap04M16.ch4_mlr,
  `Cap04M16.ex_ch4_bonferroni_ssch,
  `Cap08M6.P_eigen_w,
  `Cap08M6.gap_abs,
  `Cap08M6.prop_ch11_impacto_factor,
  `Cap08M6.prop_ch11_baseline_optima,
  `thm_ch6_dr,
  `thm_ch6_cota,
  `cor_ch6_varianza_minima,
  `prop_ch6_descomposicion,
  `thm_ch6_neyman,
  `thm_ch6_kallus_residual,
  `cor_ch6_dr_ope_modelos,
  `thm_ch6_crossfit_suma,
  `prop_ch6_ral,
  `thm_ch6_rubin_dag,
  `BookCap05.ch5_clt,
  `BookCap05.prop_ch5_clt_retornos,
  `BookCap05.ch4_clt_mixing_var,
  `BookCap05.ch5_lindeberg_feller,
  `BookCap05.ch5_delta,
  `BookCap05.ch5_delta_multi,
  `BookCap05.prop_ch5_delta_q,
  `BookCap05.ch5_donsker,
  `BookCap05.ch5_bootstrap_media,
  `Book.Cap04Ejemplos.ch1_calculo_numerico_observado,
  `Book.Cap04Ejemplos.ch1_normal_expansion,
  `Book.Cap04Ejemplos.ch1_binomial_forma_exponencial,
  `Book.Cap04Ejemplos.ch1_poisson_forma_exponencial,
  `Book.Cap04Ejemplos.ch1_beta_binomial_actualizacion,
  `Book.Cap04Ejemplos.ch1_gamma_poisson_actualizacion,
  `Book.Cap04Ejemplos.ch1_estadisticos_media_constante,
  `Book.Cap04Ejemplos.ch2_traslaciones_media,
  `Book.Cap04Ejemplos.ch2_escala_media,
  `Book.Cap04Ejemplos.ch4_mp_normal_forma_factorizada,
  `Book.Cap04Ejemplos.ch5_cociente_delta
,
  `Book.Cap04Ch1Ch2.gumbel_suficiencia_escala,
  `Book.Cap04Ch1Ch2.mezcla_normal_varianza_total,
  `Book.Cap04Ch1Ch2.normalGamma_beta_no_decrece,
  `Book.Cap04Ch1Ch2.normalGamma_invariante,
  `Book.Cap04Ch1Ch2.normalGamma_precision_crece,
  `Book.Cap04Ch1Ch2.normalGamma_varianza_pos,
  `Book.Cap04Ch1Ch2.perdidas_comunes_cero_uno_complemento,
  `Book.Cap04Ch1Ch2.perdidas_comunes_ecm_descomposicion,
  `Book.Cap04Ch1Ch2.tBase_cola_inferior,
  `Book.Cap04Ch1Ch2.tBase_cola_superior,
  `Book.Cap04Ch1Ch2.tBase_even,
  `Book.Cap04Ch1Ch2.tLocEscala_escala,
  `Book.Cap04Ch1Ch2.tLocEscala_traslacion,
  `Book.Cap04Ch2.bernoulli_contraccion_mejora_peor_caso,
  `Book.Cap04Ch2.bernoulli_identidad_riesgo_max,
  `Book.Cap04Ch2.bernoulli_regla_bayes_valores,
  `Book.Cap04Ch2.bernoulli_riesgo_identidad,
  `Book.Cap04Ch2.bernoulli_sesgo,
  `Book.Cap04Ch2.bernoulli_varianza,
  `Book.Cap04Ch2.exponencial_cociente,
  `Book.Cap04Ch2.multinomial_gibbs,
  `Book.Cap04Ch2.multinomial_mle_instancia,
  `Book.Cap04Ch2.multinomial_normalizacion,
  `Book.Cap04Ch2.multinomial_referencia,
  `Book.Cap04Ch2.normal_suma_cuadrados,
  `Book.Cap04Ch2.normal_varianza_invariante,
  `Book.Cap04Ch2.normal_varianza_media,
  `Book.Cap04Ch2.residuos_formula,
  `Book.Cap04Ch2.residuos_suma_cero,
  `Book.Cap04Ch2.residuos_traslacion,
  `Book.Cap04Ch2.riesgoB_eq,
  `Cap04M6.gauss_loglik_max,
  `Book.Cap10OPE.dr_residual_orthogonal,
  `Book.Cap10OPE.prop_ch10_dm_bias,
  `Book.Cap10OPE.shift_var_ratio_chi2,
  `Book.Cap10OPE.thm_ch10_truncamiento_var,
  `Cap02M11.ex_ch7_perdidas_clasificacion,
  `Cap02M11.ex_ch7_perdidas_cuadratica,
  `Cap02M11.ex_ch7_perdidas_ponderada,
  `Cap02M11.ex_ch7_perdidas_ponderada_medida,
  `Cap02M11.james_stein_mejora,
  `Cap02M11.james_stein_valor_nulo,
  `Ch11M10.ch11_clt_mixing_var,
  `Ch11M10.ch11_ergodico_mixing,
  `Ch11M10.ch11_ic_studentizacion,
  `Ch11M10.ch11_impacto_sigma2,
  `Ch11M10.ch11_n_condicion,
  `Ch11M10.ch11_pg_identidad,
  `Ch11M10.ch11_reinforce_if,
  `Ch11M10.ch11_ssch_objetivo
,
  `Cap11M1.thm_ch11_var_consistente,
  `Book.Cap04EjemplosM2.dr_ssch_estimador,
  `Book.Cap04EjemplosM2.score_bernoulli,
  `Book.Cap04EjemplosM2.aipw_identificacion,
  `Book.Cap04EjemplosM2.parcialmente_lineal_beta,
  `Book.Cap04EjemplosM2.cap03b_valor_ecuacion,
  `Cap04M3BH.bh_fdr_le,
  `Cap04M3U.umpu_three_point,
  `Ch3MleM4.mle_score_expansion,
  `Ch3MleM4.mle_normal_mean,
  `Ch3MleM4.bern_var_Tdiv,
  `Cap06M5.ch6_horizonte_pesos_varianza,
  `Cap06M5.ch6_tasas_compatibles,
  `Cap04Ch6M5.ch6_dml_clt,
  `Cap06M6.ch9_state,
  `Cap06M6.ch9_estados_infinitos,
  `Cap06M6.ch9_horizonte_infinito,
  `Cap06M6.ch9_eficiencia,
  `Cap06M6.ch9_fallo_noest,
  `SSCHCap01M7.smoothRow_sum,
  `SSCHCap02M7.lik_eq_prod_cnt,
  `SSCHCap03M7.freq_sum,
  `SSCHCap04M7.regla_decision,
  `SSCHCap05M7.resolvent_formula,
  `SSCHCap06M7.dr_centering,
  `SSCHCap06M7.dr_unbiased,
  `SSCHEjemplosM7.media_eq,
  `SSCHEjemplosM7.umbral_del_dictamen,
  `Book.Cap12ProblemasM8.confound_no_identificable,
  `Book.Cap12ProblemasM8.pomdp_perdida_estricta,
  `Book.Cap12ProblemasM8.aipw_double_robust,
  `Book.Cap12ProblemasM8.selected_sound,
  `Book.Cap12ProblemasM8.discounted_tail_bound,
  `Book.Cap12ProblemasM8.ic_no_cubre_otro_procedimiento,
  `M9.cap06_psi,
  `M9.cox_prob_independiente_del_basal,
  `M9.ope_determinado_por_tablas,
  `AppEImplicita.appE_funcion_implicita,
  `AppECond.bernFisher_eq,
  `Book.M13.kl_minimo_global_cero,
  `Book.M13.posterior_parametros,
  `Book.M13.logitSSCH_pos,
  `Book.M13.mh_paso_ssch_acepta_uno,
  `MeasureTheory.TendstoInMeasure.add,
  `MeasureTheory.TendstoInMeasure.consistencia_chebyshev,
  `MeasureTheory.TendstoInMeasure.of_abs_le,
  `MeasureTheory.TendstoInMeasure.consistencia_plug_in,
  `MeasureTheory.TendstoInMeasure.comp_continuous,
  `MeasureTheory.TendstoInMeasure.mul_const,
  `MeasureTheory.TendstoInMeasure.mul_zero,
  `MeasureTheory.TendstoInMeasure.const_mul,
  `MeasureTheory.TendstoInMeasure.sub,
  `MeasureTheory.TendstoInMeasure.neg,
  `MeasureTheory.TendstoInMeasure.const,
  `Book.ApendiceE.appE_borel_generado_por_intervalos,
  `Book.ApendiceE.appE_composicion,
  `Book.ApendiceE.appE_estadistico_comp,
  `Book.ApendiceE.appE_markov_nucleo_medible,
  `Book.ApendiceE.appE_seleccion_max_medible,
  `Book.ApendiceE.appE_dominacion_densidad ,
  `ApendiceEHilbert.appE_proyeccion ,
  `ApendiceEHilbert.appE_l2 ,
  `ApendiceEHilbert.appE_gaussiano ,
  `Ch6Motivacion.identificacion ,
  `Ch6Motivacion.doble_robustez_propension ,
  `Ch6Motivacion.doble_robustez_medias ,
  `Ch6Motivacion.ipw_true ,
  `Book.ApendiceDIbragimov.thm_appD_ibragimov ,
  `ApendiceDGordinM8.Chain.poisson_solution ,
  `ApendiceDGordinM8.Chain.gordin_decomposition ,
  `ApendiceDGordinM8.Chain.tendsto_boundary_div_sqrt ,
  `ApendiceDGordinM8.Chain.martIncrement_cond_mean ,
  `ApendiceDGordinM8.Chain.bracket_decomposition ,
  `ApendiceDGordinM8.Chain.harmonic_eq_zero ,
  `ApendiceDGordinM8.Chain.boundary_abs_le ,
  `Cap03M7.lai_robbins ,
  `AppDHacM9.thm_appD_hac_consistencia ,
  `Book.Cap04MedibleIntuicionM10.medible_continua_reales ,
  `Book.Cap04MedibleIntuicionM10.ley_apply ,
  `Book.Cap04MedibleIntuicionM10.esperanza_finita_iff_integrable ,
  `Book.AppERNM3.appE_rn_existe_unico ,
  `Book.ApendiceEMedidoDctM5.appE_convergencia_dominada
]

/-- Escapa una cadena para incluirla como literal JSON. -/
def jsonEsc (s : String) : String :=
  s.foldl (init := "") fun acc c =>
    acc ++
      (match c with
      | '"' => "\\\""
      | '\\' => "\\\\"
      | '\n' => "\\n"
      | '\r' => "\\r"
      | '\t' => "\\t"
      | c => String.push "" c)

end Argumentos.Exportador

open Argumentos.Exportador

elab "exportar_objetivos" : command => do
  let env ← getEnv
  let mut lineas : Array String := #[]
  for n in objetivos do
    match env.find? n with
    | none => throwError "[exporter] declaración no encontrada: {n}"
    | some info =>
      -- Axiomas transitivos (la misma maquinaria que #print axioms).
      let axs ← collectAxioms n
      let axsOrdenados := (axs.toList.map toString).toArray.qsort (· < ·) |>.toList
      -- Dependencias directas: constantes usadas por la declaración
      -- (tipo y valor, docs/05: auditar auxiliares transitivos).
      let deps := (Lean.ConstantInfo.getUsedConstantsAsSet info).toList.map toString |>.toArray.qsort (· < ·) |>.toList
      -- Tipo elaborado, serializado de manera estable para este entorno.
      let tipoFormat ← liftTermElabM <| Meta.ppExpr info.type
      let tipo := Format.pretty tipoFormat
      let axJson := String.intercalate ", " (axsOrdenados.map fun a => "\"" ++ jsonEsc a ++ "\"")
      let depJson := String.intercalate ", " (deps.map fun d => "\"" ++ jsonEsc d ++ "\"")
      let linea :=
        "{\"name\": \"" ++ jsonEsc n.toString ++ "\", " ++
        "\"type\": \"" ++ jsonEsc tipo ++ "\", " ++
        "\"axioms\": [" ++ axJson ++ "], " ++
        "\"dependencies\": [" ++ depJson ++ "]}"
      lineas := lineas.push linea
  for l in lineas do
    IO.println l

exportar_objetivos
