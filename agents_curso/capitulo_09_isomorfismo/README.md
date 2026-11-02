# Agente Estadístico: Isomorfismo Wald-MDP

Implementación Python + LangGraph del **isomorfismo estructural** entre la teoría de decisión estadística de Wald y los procesos de decisión de Markov (MDPs), basado en el Capítulo 9 del libro de referencia.

## ¿Qué es?

Un agente estadístico que operacionaliza el funtor $F:\mathbf{Dec}\to\mathbf{MDP}$ del Capítulo 9, con:

- **8 nodos LangGraph**: observation → state → inference → decision → isomorphism → transfer → test → verify
- **Funtor F** con estado terminal explícito (corrige bug de v1)
- **Transferencia de IC** vía delta-method (Teorema 9.7)
- **Transferencia de tests UMP** (Teorema 9.8)
- **OPE con DM / IS / DR** + clipping adaptativo (Su et al. 2020)
- **Protocolo de verificación Prop. 9.14** automático (mixing / overlap / nuisance / momentos)
- **Bootstrap secuencial** con corrección por mixing (Liao et al. 2021)
- **Trazabilidad estructurada** teorema→componente→garantía

## Estructura

```
isomorphism-agent/
├── src/isomorphism_agent/      # Paquete Python
│   ├── __init__.py             # API pública (v2.0.0)
│   ├── state.py                # WaldState, MDPState, AgentState
│   ├── wald.py                 # WaldProblem, bayes_rule, wald_test
│   ├── mdp.py                  # MDP, value_iteration, optimal_policy
│   ├── functor.py              # F, F_inv, verify_isomorphism (Thm 9.1)
│   ├── transfer.py             # ic_transfer_delta (Thm 9.7), test_transfer_ump (Thm 9.8)
│   ├── ope.py                  # DM, IS, DR + clipping adaptativo
│   ├── verify.py               # Prop. 9.14
│   ├── bootstrap.py            # Block bootstrap + mixing (Liao 2021)
│   ├── trace.py                # TraceLog teorema→componente→garantía
│   └── agent.py                # build_agent, run_agent (LangGraph)
├── tests/                      # 39 tests pytest (todos pasan)
│   ├── test_isomorphism.py     # 14 tests del funtor F y transferencia
│   ├── test_agent.py           # 7 tests end-to-end
│   ├── test_ope.py             # 5 tests DM/IS/DR
│   └── test_v2.py              # 13 tests de mejoras v2
├── notebooks/
│   └── demo.ipynb              # Demo paso a paso con Diabetes 130-US
├── manual/                     # Manual LaTeX estilo MIT Press técnico
│   ├── manual.tex              # Fuente LaTeX
│   ├── references.bib          # 15 referencias
│   ├── manual.pdf              # PDF compilado (12 páginas)
│   └── figures/                # 4 figuras PDF
├── data/                       # Dataset Diabetes 130-US
│   └── dataset_diabetes/
├── pyproject.toml              # Dependencias
└── README.md                   # Este archivo
```

## Instalación

```bash
cd isomorphism-agent
pip install -e .
```

Dependencias: Python 3.10+, numpy, scipy, scikit-learn, pandas, matplotlib, langgraph, typing_extensions.

## Uso rápido

```python
import numpy as np
from isomorphism_agent import run_agent

# Datos Bernoulli(θ=0.4), n=100
data = np.random.binomial(1, 0.4, size=100)

# Ejecutar agente completo
result = run_agent(data, prior={'alpha': 2.0, 'beta': 2.0},
                   loss_args={'cost_treat': 0.2, 'cost_skip': 1.0})

print(f"θ̂ = {result['theta_hat']:.4f}")
print(f"Acción Bayes δ* = {result['bayes_action']}")
print(f"Acción MDP   π* = {result['mdp_action']}")
print(f"Isomorfismo OK? {result['isomorphism_ok']}")
print(f"Transferible?  {result['transferable']}")

# Trazabilidad
print(result['trace_log'].summary_table())
```

## Tests

```bash
pytest tests/ -v
# 39 tests, todos pasan en ~2s
```

## Reproducir la aplicación a Diabetes 130-US

```bash
# 1. Descargar dataset (UCI ML Repository)
#    https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008
#    Colocar en data/dataset_diabetes/diabetic_data.csv

# 2. Ejecutar el pipeline OPE
python ../scripts/diabetes_application.py
```

Resultado esperado:

| Estimador | V̂^π_e | IC 95%       | ESS    | ρ_max |
|-----------|--------|--------------|--------|-------|
| DM        | -0.112 | [-0.112, -0.112] | --- | --- |
| IS        | -0.116 | [-0.120, -0.112] | 24060 | 5.37 |
| DR        | -0.109 | [-0.113, -0.105] | 24060 | 5.37 |
| DR*       | -0.110 | [-0.113, -0.107] | 27577 | 1.00 |

**Protocolo Prop. 9.14**: detecta nuisance rate > n^(-1/4) → **no transferible**, sugiere cross-fitting + DM.

## Compilar el manual

```bash
cd manual
tectonic manual.tex
# Genera manual.pdf (12 páginas, ~250 KB)
```

## Iteración v1 → v2

**v1** (Laboratorio F.9 del apéndice) era funcional pero tenía 6 limitaciones:
1. Bug en F: P=identidad + γ=1 hacía diverger VI
2. F_inv con tolerancias demasiado estrictas
3. OPE no manejaba π_e determinista (ρ=∞)
4. Sin protocolo de verificación Prop. 9.14
5. Sin bootstrap secuencial
6. Sin trazabilidad estructurada

**v2** corrige las 6 y añade clipping adaptativo (Su 2020). Tests: 26 → 39, todos pasan.

## Referencias clave

- Wald, A. (1950). *Statistical Decision Functions*. Wiley.
- Bellman, R. (1957). *Dynamic Programming*. Princeton UP.
- Puterman, M. L. (2005). *Markov Decision Processes*. Wiley.
- Berger, J. O. (1985). *Statistical Decision Theory and Bayesian Analysis*. Springer.
- Athey, S. & Wager, S. (2021). Policy learning with observational data. *Econometrica*.
- Su, Y. et al. (2020). Adaptive doubly robust policy evaluation. arXiv:2007.08043.
- Liao, P. et al. (2021). Off-policy evaluation for mobile health. arXiv:2106.00764.
- Chernozhukov, V. et al. (2018). Double/debiased ML. *Econometrics Journal*.
- Strack, B. et al. (2014). Impact of HbA1c on hospital readmission. *BioMed Research International*.

## Licencia

MIT.
