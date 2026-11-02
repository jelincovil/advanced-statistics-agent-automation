# Agente Estadistico Asintotico — Capitulo 5

> **Version:** 1.0.0  
> **Fecha:** 2026-05-17  
> **Requisitos:** Python 3.9+, NumPy, SciPy

---

## Resumen Ejecutivo

El **Agente Estadistico Asintotico** es la implementacion operacional del **Capitulo 5: Teoria Asintotica y Metodos de Remuestreo** del texto *Inferencia Estadistica para Agentes Inteligentes*. Este agente:

1. **Estima** el valor de una politica $V^\pi$ via Monte Carlo.
2. **Cuantifica** la incertidumbre con intervalos de confianza bootstrap (percentil y percentil-t).
3. **Diagnostica** dependencia temporal mediante mixing geometrico (Prop 5.2).
4. **Propaga** incertidumbre desde $Q^\pi$ hasta $V^\pi$ via Delta Method multivariado (Thm 5.5).
5. **Descompone** la varianza en epistemica (reducible, $O(1/n)$) y aleatoria (irreducible).
6. **Decide** autonomamente si la precision es suficiente para actuar (Lab F.5.1).

---

## Estructura del Paquete

```
agente_estadistico_cap5/
├── agente_asintotico.py   # Implementacion completa (modulos 1-8)
├── ejemplo_ssch.py        # Ejemplo de ejecucion: caso SSCH
├── README.md              # Este archivo
└── requirements.txt       # Dependencias
```

---

## Instalacion y Uso

### Requisitos

```bash
pip install numpy scipy
```

### Urapido (ejemplo SSCH)

```bash
python ejemplo_ssch.py
```

### Uso como libreria

```python
import numpy as np
from agente_asintotico import (
    AgenteEstadisticoAsintotico,
    ConfiguracionAgente,
    bootstrap_ci,
    diagnosticar_mixing,
    descomponer_incertidumbre,
    decidir_recoleccion,
    propagar_desde_Q,
)

# Configurar agente
cfg = ConfiguracionAgente(
    alpha=0.05,              # IC al 95%
    B=1000,                  # 1000 replicas bootstrap
    epsilon_tolerancia=0.5,  # Umbral de ancho IC
    tipo_ic="percentil-t",   # Refinamiento de segundo orden
)

# Datos: retornos de trayectorias
retornos = np.random.normal(5.0, 2.0, size=100)

# Ejecutar pipeline completo
agente = AgenteEstadisticoAsintotico(config=cfg)
reporte = agente.evaluar_politica(retornos=retornos)

print(reporte)
```

---

## Modulos Implementados

### 1. `bootstrap_ci()` — Motor Bootstrap

Implementa `thm:ch5-bootstrap-media` (consistencia) y las definiciones `def:ch5-ic-percentil` / `def:ch5-ic-t`.

| Parametro | Descripcion |
|-----------|-------------|
| `retornos` | Array (n,) de retornos $G_i$ |
| `B` | Numero de replicas (>= 1000 recomendado) |
| `alpha` | Nivel de significancia |
| `tipo` | `"percentil"` (O(n^{-1/2})) o `"percentil-t"` (O(n^{-1})) |
| `block_size` | None=iid, int=bootstrap por bloques para datos dependientes |

**Referencia teorica:** `thm:ch5-bootstrap-media`, `def:ch5-ic-percentil`, `def:ch5-ic-t`, `thm:ch5-cobertura`

---

### 2. `diagnosticar_mixing()` — Diagnostico de Dependencia

Implementa `prop:ch5-verificacion`: calcula autocorrelaciones, ajusta decaimiento exponencial, estima $\hat{\rho}$.

**Salida:**
- `rho_estimado`: coeficiente de decaimiento $\hat{\rho} = e^{\beta_1}$
- `mixing_ok`: True si $\hat{\rho} < 0.95$
- `varianza_largo_plazo`: $\sigma^2_{LR} = \gamma_0 + 2\sum \gamma_k$

**Referencia teorica:** `prop:ch5-verificacion`, `def:ch5-mixing-clt`, `thm:ch5-clt-agentes`

---

### 3. `descomponer_incertidumbre()` — Descomposicion de Varianza

Implementa el **Lab F.5.2**: separa varianza en epistemica ($c_{ep}/n$) y aleatoria (constante) mediante aumento secuencial de $n$.

**Metodo:**
1. Submuestrea en $n_{seq} = [50, 100, 200, 500, 1000, 2000, 5000]$
2. Ajusta modelo: $\text{Var}(\hat{V}_n) = c_1/n + c_2/n^2$
3. El termino dominante $c_1/n$ es la **epistemica**

**Referencia teorica:** `Lab F.5.2`, `prop:ch5-clt-retornos`, `thm:ch5-clt-agentes`

---

### 4. `propagar_desde_Q()` — Delta Method

Implementa `thm:ch5-delta-multi`: propaga incertidumbre desde estimaciones de $Q^\pi$ hasta $V^\pi = \sum_a \pi(a|s) Q^\pi(s,a)$.

**Formula:**
$$\sigma^2_V = \mathbf{J} \boldsymbol{\Sigma}_Q \mathbf{J}^\top$$
$$\mathbf{J} = [\pi(a_1|s), \ldots, \pi(a_{|A|}|s)]$$

**Soporta transformaciones:** `"identidad"`, `"exp"`, o callable personalizado.

**Referencia teorica:** `thm:ch5-delta-multi`, `prop:ch5-delta-q`, `ex:ch5-qdelta`

---

### 5. `decidir_recoleccion()` — Modulo de Decision

Implementa el **Lab F.5.1**:

$$\text{Si } U - L > \epsilon \Rightarrow \text{recolectar mas datos}$$
$$\text{Si } U - L \leq \epsilon \Rightarrow \text{actuar}$$

La recomendacion de $n$ adicional usa la escala $O(1/\sqrt{n})$ del CLT: $n_{nuevo} \approx n_{actual} \cdot (W_{actual}/\epsilon)^2$.

**Referencia teorica:** `Lab F.5.1`, `thm:ch5-clt`

---

### 6. `AgenteEstadisticoAsintotico` — Orquestador Integrado

Ejecuta el pipeline completo:

```
Entrada → DiagnosticoMixing → Bootstrap → DeltaMethod → 
→ Descomposicion → Decision → Reporte
```

Cada modulo se activa automaticamente segun la configuracion y los datos.

---

## Conexiones con el Capitulo 5

| Modulo | Teorema/Definicion | Laboratorio | Supuesto Critico No Verificable |
|--------|-------------------|-------------|--------------------------------|
| Estimacion puntual | `prop:ch5-clt-retornos` | F.5.1 | $\mathbb{E}[G^2] < \infty$ |
| Diagnostico mixing | `prop:ch5-verificacion` | F.5.2 | Estacionariedad estricta |
| Bootstrap percentil | `thm:ch5-bootstrap-media` + `def:ch5-ic-percentil` | F.5.1 | iid subyacente |
| Bootstrap percentil-t | `def:ch5-ic-t` + `thm:ch5-cobertura` | F.5.1 | Varianza bootstrap consistente |
| Delta Method | `thm:ch5-delta-multi` | F.5.2 | Diferenciabilidad de $g$ |
| Descomposicion | `Lab F.5.2` | F.5.2 | Homocedasticidad de varianza aleatoria |
| Decision | `Lab F.5.1` | F.5.1 | $\epsilon$ es parametro externo |

---

## Dependencias

```
numpy >= 1.21.0
scipy >= 1.7.0
```

Ver `requirements.txt` para versiones exactas.

---

## Licencia

Implementacion academica para el Capitulo 5. Uso libre con atribucion.
