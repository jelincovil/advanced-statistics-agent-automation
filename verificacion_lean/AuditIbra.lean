import Book.ApendiceDIbragimov

/-! Auditoría de axiomas de `Book/ApendiceDIbragimov.lean`. -/

open Book.ApendiceDIbragimov MeasureTheory ProbabilityTheory
open scoped ENNReal Topology

#print axioms integral_comp_fintype
#print axioms sum_measureReal_pairs
#print axioms abs_cov_le
#print axioms alphaCoef_le_one
#print axioms abs_integral_mul_sub_le_alphaCoef
#print axioms abs_gamma_le
#print axioms summable_abs_gamma
#print axioms summable_abs_gamma_of_rpow
#print axioms doble_suma_eq
#print axioms tendsto_average_doble
#print axioms variance_eq_doble
#print axioms tendsto_variance_div
#print axioms alphaRect_le_alphaSum
#print axioms alphaRect_le_alphaCoef
#print axioms abs_rectDev_le_alphaSum
#print axioms abs_integral_prod_sub_prod_le
#print axioms normSup_prod_bloque_le
