import Book.Cap05Representacion

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
