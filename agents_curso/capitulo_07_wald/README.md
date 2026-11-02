# Lab F.7 — Agente Estadístico de Wald para Decisiones Crediticias

Prototipo en LangGraph de un agente de decisión bajo incertidumbre que
implementa la teoría de Wald del Capítulo 7: regla de Bayes, regla
minimax, admisibilidad y un meta-selector que escala al humano bajo
alta entropía posterior.

## Arquitectura del grafo

```
  observar -> posterior -> riesgo_bayes -> riesgo_minimax -> meta_selector -> END
```

Cada nodo es una función pura `AgentState -> AgentState`. La pureza
permite testearlos sin LangGraph (ver `tests/test_sanity.py`).

| Nodo              | Cap. 7                       | Implementación                                       |
|-------------------|------------------------------|------------------------------------------------------|
| `observar`        | $x \in \mathcal{X}$          | Recibe el vector de atributos del solicitante        |
| `posterior`       | Actualización Bayesiana      | Beta($\alpha,\beta$) por moment-matching             |
| `riesgo_bayes`    | $R(\theta,\delta_B)$         | $\mathbb{E}_{\theta\mid x}[L(\theta,a)]$            |
| `riesgo_minimax`  | $R(\theta,\delta_M)$         | $\sup_{\theta\in CR_{0.9}} L(\theta,a)$              |
| `meta_selector`   | Selección de regla           | Entropía + acuerdo $\Rightarrow$ Bayes/Minimax/Escalar |

## Matriz de pérdida

Convención Statlog (definida por el donante del dataset):

|              | accept | reject | escalate |
|--------------|:------:|:------:|:--------:|
| **good**     |  0     |  1     |  1.5     |
| **bad**      |  5     |  0     |  1.5     |

El umbral de Bayes para `{accept, reject}` es
$\theta^* = L(\text{good},\text{reject}) / (L(\text{good},\text{reject}) + L(\text{bad},\text{accept})) = 1/6 \approx 0.167$.
La acción `escalate` está construida para ser **estrictamente dominada** en el
cálculo de riesgo puro (su costo plano 1.5 > 5/6, el riesgo de Bayes
máximo): así sólo el meta-selector la activa, vía entropía posterior.

## Instalación local

```bash
pip install -r requirements.txt
python run_experiment.py
```

Esperado en ~5 segundos:

```
Train accuracy: 0.748
Test  accuracy: 0.740
Bayes threshold (closed):  0.1667
max p_hat among accepted: 0.1665
min p_hat among rejected: 0.1667
```

La coincidencia entre el umbral cerrado (1/6) y el observado (0.1665/0.1667)
es la **verificación empírica del Teorema de Bayes** del Capítulo 7.

## Sustitución por el dataset real

El CSV incluido (`data/german_credit.csv`) es **sintético** pero replica la
estructura del Statlog real (1000 filas, 20 atributos, 31.4% bad rate).
Para usar el real:

```bash
python data/download_real_data.py     # fetch from OpenML
python run_experiment.py
```

No hace falta cambiar otra cosa: los nombres de columnas son idénticos al
fetch de OpenML (`credit-g` v1).

## Tests

```bash
python tests/test_sanity.py
# o:  python -m pytest tests/ -v
```

Los 7 tests verifican propiedades teóricas:

1. El umbral cerrado de Bayes es $1/6$.
2. La regla de Bayes acepta justo debajo del umbral y rechaza justo encima.
3. La región de rechazo de minimax contiene la de Bayes (más conservadora).
4. El meta-selector escala bajo desacuerdo + alta entropía.
5. El meta-selector usa Bayes bajo certeza.
6. El riesgo esperado es lineal en $p$.
7. El peor caso sobre $[p_{lo}, p_{hi}]$ se alcanza en un extremo (consecuencia de la linealidad).

## Parámetros editables (`config.py`)

| Parámetro                      | Default | Efecto                                         |
|--------------------------------|---------|------------------------------------------------|
| `SEED`                         | 42      | Reproducibilidad                               |
| `POSTERIOR_KAPPA`              | 30.0    | Concentración del Beta posterior. **Baje a 5 para ver más activaciones del meta-selector** |
| `ENTROPY_THRESHOLD`            | 0.55    | Sobre este nivel: usa minimax                  |
| `ESCALATE_ENTROPY_THRESHOLD`   | 0.75    | Sobre este nivel + desacuerdo: escala          |
| `MINIMAX_CRED_LEVEL`           | 0.90    | Amplitud del intervalo de credibilidad         |
| `LOSS[("bad","accept")]`       | 5.0     | Asimetría 5:1 del Statlog. Cámbiela para sensibilidad |

## Conexión con el Cap. 8 (MDPs)

Cada decisión individual aquí es un MDP de un paso con
$\Risk(\theta, \delta) = -V^\pi(s)$. El isomorfismo Wald–MDP del
Cap. 11 se manifestará al extender este agente a decisiones
secuenciales (e.g., préstamos renovables con observación posterior del
desempeño del prestatario, donde $\theta$ se aprende dinámicamente).

## Preguntas de exploración

1. **Sensibilidad al prior**: Cambie `POSTERIOR_KAPPA` a 5, 30, 100 y
   reporte cómo cambia la proporción de decisiones `escalate`.
2. **Doble robustez**: Reemplace `LogisticRegression` por
   `RandomForestClassifier` (probabilidades mejor calibradas). ¿Mejora
   la pérdida total realizada?
3. **Verificación del complete-class theorem**: La regla minimax
   debería ser Bayes con respecto a algún prior $\Lambda^*$ menos
   favorable. Encuéntrelo numéricamente y muestre que coincide con la
   regla minimax implementada.
4. **Calibración**: Use `CalibratedClassifierCV` para obtener
   probabilidades calibradas y compare la pérdida total. ¿Se acerca
   la pérdida pura de Bayes al óptimo de Bayes teórico
   $r(\Lambda) = \sum_x \min_a R(\theta,a) \, m(x)$?
