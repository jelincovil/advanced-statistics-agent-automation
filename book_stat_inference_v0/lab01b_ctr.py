from fractions import Fraction

success, n = 18, 100
a, b = 1 + success, 1 + n - success
p = a / (a + b)
cost = 0.15
print(f"Posterior Beta({a},{b}); beneficio esperado={p-cost:.6f}")
print("Mostrar:", p > cost)
# Var(theta|datos)<=1/[4(n+a0+b0+1)]. Cota para todo numero de exitos.
minimum_n = next(
    k for k in range(1000) if Fraction(1, 4 * (k + 3)) < Fraction(1, 400)
)
print("n suficiente por cota uniforme para SD<0.05:", minimum_n)
assert minimum_n == 98
