# Capítulo 4: Tests de Hipótesis e Intervalos de Confianza en Agentes

## Agente A/B Testing de Políticas con FDR

### Conceptos Estadísticos Demostrados

| Concepto Teórico | Manifestación en el Agente |
|-------------------|---------------------------|
| Test de Neyman-Pearson | Test de Welch para comparar V^{π_A} vs V^{π_B} |
| Dualidad test-IC | Rechazar H₀ ⟺ 0 ∉ IC_{95%} |
| Error Tipo I/II | Falso positivo/negativo en comparación de políticas |
| Poder del test | Capacidad de detectar diferencias reales entre políticas |
| Benjamini-Hochberg | Control de FDR para k ≥ 2 comparaciones simultáneas |
| Tamaño del efecto | Cohen's d para cuantificar significancia práctica |

### Arquitectura del Grafo LangGraph

```
collect_data → welch_test → compute_ci → benjamini_hochberg → llm_interpret → decide → END
```

### Instalación y Ejecución

```bash
conda env create -f environment.yml
conda activate cap04_tests_ic
chainlit run app.py
```

### Referencias

- Lehmann & Romano (2005), Ch.3-5 - Two-sample problems
- Shi et al. (2022), §5 - Hypothesis testing for value functions
- Thomas et al. (2015) - High confidence off-policy evaluation
