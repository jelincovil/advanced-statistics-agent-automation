import Book.Cap05Representacion
import Book.Cap07OPE
import Book.Cap06Fronteras
import Book.Cap03MDP
import Book.SSCH

/-!
# Book.Audit — auditoría de axiomas del proyecto (plan §6)

Cada teorema debe depender solo de `propext`, `Classical.choice` y
`Quot.sound` (el estándar del piloto). `verificar.sh` vuelca la salida
de este archivo a build/axioms.log y falla si aparece el axioma
prohibido — el que marcaría una prueba sin cerrar; por la política de
cero cabos sueltos (plan §6), esa palabra no debe aparecer escrita en
ningún archivo de Book/. -/

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
