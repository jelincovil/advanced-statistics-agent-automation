"""Comprobaciones finitas deterministas; no sustituyen las demostraciones."""
from itertools import product
from math import isclose

def igual(x,y):
    assert isclose(x,y,rel_tol=1e-12,abs_tol=1e-12),(x,y)

# Identidad de sesgo DR con dos acciones y candidatos incorrectos.
b=(.7,.3); pi=(.2,.8); m=(2.,5.); mb=(3.,4.); bb=(.6,.4)
j=sum(pi[a]*m[a] for a in range(2)); v=sum(pi[a]*mb[a] for a in range(2))
e=sum(b[a]*(v+pi[a]/bb[a]*(m[a]-mb[a])) for a in range(2))
bias=sum(pi[a]*(bb[a]-b[a])/bb[a]*(mb[a]-m[a]) for a in range(2))
igual(e-j,bias)
for mm,be in [(m,bb),(mb,b)]:
    vv=sum(pi[a]*mm[a] for a in range(2))
    igual(sum(b[a]*(vv+pi[a]/be[a]*(m[a]-mm[a])) for a in range(2)),j)
# AIPW: comprobar signo de ambos errores.
e0=.3; eb=.6; m0,m1=2.,5.; mb0,mb1=1.,7.
d=mb1-mb0+e0/eb*(m1-mb1)-(1-e0)/(1-eb)*(m0-mb0)
igual(d-(m1-m0),(eb-e0)*((mb1-m1)/eb+(mb0-m0)/(1-eb)))
# Trayectorias: cambio de medida y varianza exponencial exacta.
h=5; pb=.3; pe=.7
mean=second=target=wrong=0.
for actions in product((0,1),repeat=h):
    qb=qe=1.
    for a in actions:
        qb*=pb if a else 1-pb; qe*=pe if a else 1-pe
    w=qe/qb
    mean+=qb*w; second+=qb*w*w
    reward=float(all(actions))
    target+=qe*reward
    wrong+=qb*(pe/pb if actions[-1] else (1-pe)/(1-pb))*reward
igual(mean,1.)
igual(second-1,(pe**2/pb+(1-pe)**2/(1-pb))**h-1)
igual(target,pe**h)
assert abs(wrong-target)>1e-3 # una razón final no basta
# Bellman: dos acciones empatadas, valor único y políticas distintas óptimas.
gamma=.9; reward=1.; optimal=reward/(1-gamma); candidate=3.
residual=abs(reward+gamma*candidate-candidate)
igual(abs(candidate-optimal),residual/(1-gamma))
# Riesgo-retorno: todos los mapas binarios en dos observaciones.
for delta in product((0,1),repeat=2):
    for theta in (0,1):
        prob=(.8,.2) if theta==0 else (.3,.7)
        risk=sum(prob[x]*(delta[x]!=theta) for x in (0,1))
        value=sum(prob[x]*(-float(delta[x]!=theta)) for x in (0,1))
        igual(value,-risk)
print('OK: DR, AIPW, IS, contraejemplo de peso local, Bellman y riesgo-retorno.')
