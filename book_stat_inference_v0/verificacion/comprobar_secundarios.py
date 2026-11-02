"""Casos finitos deterministas para detectar errores; no pruebas generales."""
from itertools import product
from math import comb, isclose

def eq(x,y):
    assert isclose(x,y,rel_tol=1e-11,abs_tol=1e-11),(x,y)

# BH: p-valores nulos independientes superuniformes sobre rejilla.
def bh(p,alpha):
    r=max([0]+[i for i,x in enumerate(sorted(p),1) if x<=alpha*i/len(p)+1e-14])
    return {i for i,x in enumerate(p) if r and x<=alpha*r/len(p)+1e-14}
alpha=.3; grid=[i/10 for i in range(1,11)]; fdr=0
for nulls in product(grid,repeat=2):
    p=list(nulls)+[.01]; rejected=bh(p,alpha); r=len(rejected)
    fdr+=len(rejected & {0,1})/max(r,1)/100
    for i in (0,1):
        pp=p.copy();pp[i]=0;r0=len(bh(pp,alpha))
        for k in range(1,4):
            assert (i in rejected and r==k)==(p[i]<=alpha*k/3+1e-14 and r0==k)
assert fdr<=2*alpha/3+1e-12
# Cramer-Rao exacto para proporción binomial de tamaño fijo.
n=7;p=.3
mean=sum(comb(n,k)*p**k*(1-p)**(n-k)*(k/n) for k in range(n+1))
var=sum(comb(n,k)*p**k*(1-p)**(n-k)*(k/n-p)**2 for k in range(n+1))
eq(mean,p);eq(var,p*(1-p)/n)
# Menor riesgo promedio no implica dominancia.
r0=(1.,1.);r1=(0.,2.);prior=(.9,.1)
assert sum(x*y for x,y in zip(prior,r1))<sum(x*y for x,y in zip(prior,r0))
assert not all(x<=y for x,y in zip(r1,r0))
# Cadena reducible: un auto-bucle y otra clase de período 2.
P=((1,0,0),(0,0,1),(0,1,0))
assert P[0][0]==1 and P[1][1]==0
P2=[[sum(P[i][k]*P[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
assert P2[1][1]==1  # no convierte toda la cadena en aperiódica
# Ecuación de Poisson y descomposición martingala, cadena simétrica.
P=((.75,.25),(.25,.75));f=(-1.,1.);h=(-2.,2.)
ph=[sum(P[i][j]*h[j] for j in range(2)) for i in range(2)]
for i in range(2):eq(h[i]-ph[i],f[i])
for states in product((0,1),repeat=6):
    eq(sum(f[x] for x in states[1:]),sum(h[states[t]]-ph[states[t-1]] for t in range(1,6))+ph[states[0]]-ph[states[-1]])
# Baseline: centrado del score y conservación de gradiente Bernoulli.
p=.75
for baseline in (0.,.25,1.,2.):
    eq(sum((p if a else 1-p)*(a-p)*(a-baseline) for a in (0,1)),p*(1-p))
# Sesgo de clipping del ejemplo de cola rara.
eq(.01*min(100,10)-1,-.9)
print(f'OK: BH (FDR={fdr:.6f}), Cramer-Rao, dominancia, aperiodicidad, Poisson, baseline y clipping.')
