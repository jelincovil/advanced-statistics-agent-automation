"""Instancia racional sintética. No demuestra una ley estadística general."""
from fractions import Fraction as F
import json
p={0:{0:F(4,5),1:F(1,5)},1:{0:F(1,5),1:F(4,5)}}
prior={0:F(7,10),1:F(3,10)}
def loss(theta,a):
    return F(1) if theta==0 and a==1 else F(4) if theta==1 and a==0 else F(0)
risks={t:sum(p[t][x]*loss(t,x) for x in (0,1)) for t in (0,1)}
returns={t:sum(p[t][x]*(-loss(t,x)) for x in (0,1)) for t in (0,1)}
bayes=sum(prior[t]*risks[t] for t in (0,1))
assert risks=={0:F(1,5),1:F(4,5)}
assert bayes==F(19,50)
assert all(returns[t]==-risks[t] for t in risks)
print(json.dumps({'experiment':'ssch_one_decision_exact_v1','risk0':str(risks[0]),'risk1':str(risks[1]),'bayes_risk':str(bayes),'scope':'exact finite synthetic instance'},sort_keys=True))
