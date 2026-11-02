"""Genera las 4 figuras del manual LaTeX.

1. fig_isomorphism_diagram.pdf — Diagrama del funtor F: Dec → MDP
2. fig_traceability_table.pdf — Tabla teorema→componente→garantía
3. fig_diabetes_results.pdf — Comparación DM/IS/DR/DR* en Diabetes
4. fig_verification_protocol.pdf — Protocolo Prop. 9.14
"""
import sys
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

# Configurar fonts
fm.fontManager.addfont('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')
plt.rcParams['font.sans-serif'] = ['DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams['font.size'] = 10

OUT_DIR = Path(__file__).resolve().parent / "figures"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# Figura 1: Diagrama del funtor F
# ---------------------------------------------------------------------------
def fig_isomorphism_diagram():
    fig, ax = plt.subplots(figsize=(10, 5), constrained_layout=True)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')

    # Caja Wald
    wald_box = FancyBboxPatch((0.2, 0.5), 3.5, 4, boxstyle="round,pad=0.1",
                              linewidth=1.5, edgecolor='#1f3a5f',
                              facecolor='#e8eef7')
    ax.add_patch(wald_box)
    ax.text(1.95, 4.2, 'Marco de Wald', ha='center', fontsize=12,
            fontweight='bold', color='#1f3a5f')
    wald_items = [
        r'$\Theta$ (parámetros)',
        r'$\mathcal{X}$ (espacio muestral)',
        r'$\mathcal{A}$ (acciones)',
        r'$L(\theta, a)$ (pérdida)',
        r'$\delta:\mathcal{X}\to\mathcal{A}$',
        r'$R(\theta,\delta) = \mathbb{E}[L]$',
    ]
    for i, t in enumerate(wald_items):
        ax.text(0.5, 3.7 - i*0.5, t, fontsize=9, color='#1f3a5f')

    # Caja MDP
    mdp_box = FancyBboxPatch((6.3, 0.5), 3.5, 4, boxstyle="round,pad=0.1",
                             linewidth=1.5, edgecolor='#5a2d1f',
                             facecolor='#f7ede8')
    ax.add_patch(mdp_box)
    ax.text(8.05, 4.2, 'Marco MDP', ha='center', fontsize=12,
            fontweight='bold', color='#5a2d1f')
    mdp_items = [
        r'$\mathcal{S}$ (estados)',
        r'$\mathcal{X} \to \mathcal{S}$',
        r'$\mathcal{A}$ (acciones)',
        r'$-r(s,a)$ (recompensa negativa)',
        r'$\pi:\mathcal{S}\to\mathcal{A}$',
        r'$V^\pi(s) = \mathbb{E}[\sum \gamma^t r_t]$',
    ]
    for i, t in enumerate(mdp_items):
        ax.text(6.6, 3.7 - i*0.5, t, fontsize=9, color='#5a2d1f')

    # Flecha F
    arrow = FancyArrowPatch((3.7, 2.5), (6.3, 2.5),
                            arrowstyle='->', mutation_scale=25,
                            linewidth=2.5, color='#2c7a2c')
    ax.add_patch(arrow)
    ax.text(5.0, 2.8, r'$F$', ha='center', fontsize=20,
            fontweight='bold', color='#2c7a2c')
    ax.text(5.0, 2.2, r'funtor', ha='center', fontsize=9,
            color='#2c7a2c', style='italic')
    ax.text(5.0, 1.7, r'$R(\theta,\delta) \leftrightarrow -V^\pi(s)$',
            ha='center', fontsize=9, color='#444444')

    ax.set_title('Isomorfismo estructural Wald-MDP (Teorema 9.1)',
                 fontsize=13, fontweight='bold', pad=12)
    fig.savefig(OUT_DIR / "fig_isomorphism_diagram.pdf")
    plt.close(fig)
    print("[OK] fig_isomorphism_diagram.pdf")


# ---------------------------------------------------------------------------
# Figura 2: Tabla de trazabilidad
# ---------------------------------------------------------------------------
def fig_traceability_table():
    fig, ax = plt.subplots(figsize=(11, 4.5), constrained_layout=True)
    ax.axis('off')

    rows = [
        ["Teorema", "Componente", "Garantía", "Estado"],
        ["Thm 9.1 (Isomorfismo)", "isomorphism_node", "Formal", "✓"],
        ["Thm 9.5 (Secuencial)", "mdp_node", "Recursivo", "✓"],
        ["Thm 9.7 (IC transfer)", "transfer_node", "Cobertura", "✓"],
        ["Thm 9.8 (Test transfer)", "test_node", "Control de error", "✓"],
        ["Thm 9.9 (R↔-V)", "decision_node", "Optimalidad", "✓"],
        ["Thm 9.10 (Estado)", "state_node", "Información completa", "✓"],
        ["Thm 9.11 (Adm.↔Pareto)", "decision_node", "Eficiencia", "✓"],
        ["Thm 9.13 (Condiciones)", "verify_node", "Condicional", "✓"],
        ["Prop 9.14 (Protocolo)", "verify_node", "Verificación", "✓"],
    ]
    cell_text = rows[1:]
    col_labels = rows[0]
    table = ax.table(cellText=cell_text, colLabels=col_labels,
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1.0, 1.5)

    # Estilo cabecera
    for j in range(4):
        cell = table[0, j]
        cell.set_facecolor('#1f3a5f')
        cell.set_text_props(color='white', fontweight='bold')

    # Colorear filas
    for i in range(1, len(rows)):
        for j in range(4):
            cell = table[i, j]
            if i % 2 == 0:
                cell.set_facecolor('#f0f4fa')
            else:
                cell.set_facecolor('#ffffff')
            if j == 3:
                cell.set_text_props(color='#2c7a2c', fontweight='bold')

    ax.set_title('Tabla 9.2 — Trazabilidad Teorema → Componente → Garantía',
                 fontsize=12, fontweight='bold', pad=20)
    fig.savefig(OUT_DIR / "fig_traceability_table.pdf")
    plt.close(fig)
    print("[OK] fig_traceability_table.pdf")


# ---------------------------------------------------------------------------
# Figura 3: Resultados OPE en Diabetes
# ---------------------------------------------------------------------------
def fig_diabetes_results():
    # Datos del run
    estimators = ['DM', 'IS', 'DR', 'DR* (adaptive)']
    values = [-0.1120, -0.1158, -0.1090, -0.1102]
    lo =     [-0.1123, -0.1200, -0.1132, -0.1132]
    hi =     [-0.1117, -0.1116, -0.1049, -0.1072]
    err_lo = [v - l for v, l in zip(values, lo)]
    err_hi = [h - v for v, h in zip(values, hi)]

    fig, ax = plt.subplots(figsize=(8, 4.5), constrained_layout=True)
    x = np.arange(len(estimators))
    colors = ['#6c8ebf', '#b85450', '#82b366', '#d6b656']

    ax.errorbar(x, values, yerr=[err_lo, err_hi],
                fmt='o', markersize=12, capsize=6, capthick=2,
                linewidth=2, color='#1f3a5f', ecolor='#444444')
    for i, (xi, vi, c) in enumerate(zip(x, values, colors)):
        ax.scatter(xi, vi, s=200, color=c, zorder=5, edgecolor='black')

    ax.axhline(-0.1114, color='red', linestyle='--', linewidth=1.5,
               label='V$^{π_b}$ (comportamiento observado)')
    ax.set_xticks(x)
    ax.set_xticklabels(estimators, fontsize=11)
    ax.set_ylabel(r'$\hat{V}^{\pi_e}$', fontsize=12)
    ax.set_title('Estimación de $V^{\\pi_e}$ en Diabetes 130-US Hospitals\n'
                 '(n=30,035 encuentros eval)', fontsize=12, fontweight='bold')
    ax.legend(loc='lower right', fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.13, -0.10)

    # Anotaciones
    ax.annotate('λ* = 1.003', xy=(3, -0.1102), xytext=(3, -0.105),
                ha='center', fontsize=9,
                arrowprops=dict(arrowstyle='->', color='#888888'))

    fig.savefig(OUT_DIR / "fig_diabetes_results.pdf")
    plt.close(fig)
    print("[OK] fig_diabetes_results.pdf")


# ---------------------------------------------------------------------------
# Figura 4: Protocolo de verificación
# ---------------------------------------------------------------------------
def fig_verification_protocol():
    fig, ax = plt.subplots(figsize=(10, 5), constrained_layout=True)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5.5)
    ax.axis('off')

    # Cuatro condiciones como cajas
    conditions = [
        ("Mixing", r"$\sum_k \alpha(k)^{\delta/(2+\delta)} < \infty$",
         "OK\nα(1)=1.000", '#82b366'),
        ("Overlap", r"$\pi_b(a|s) \geq \eta \cdot \pi(a|s)$",
         "OK\nESS=24060/30035", '#82b366'),
        ("Nuisance", r"$\|\hat{Q}-Q\| = o_P(n^{-1/4})$",
         "FAIL\nrate=0.10 > 0.076", '#b85450'),
        ("Moments", r"$\mathbb{E}[|r|^{2+\delta}] < \infty$",
         "OK\n1.12e-01", '#82b366'),
    ]

    for i, (title, formula, status, color) in enumerate(conditions):
        x0 = 0.3 + i * 2.4
        box = FancyBboxPatch((x0, 1.5), 2.0, 3, boxstyle="round,pad=0.1",
                             linewidth=2, edgecolor=color,
                             facecolor='white')
        ax.add_patch(box)
        ax.text(x0 + 1.0, 4.0, title, ha='center', fontsize=11,
                fontweight='bold', color=color)
        ax.text(x0 + 1.0, 3.2, formula, ha='center', fontsize=9,
                color='#333333')
        ax.text(x0 + 1.0, 2.2, status, ha='center', fontsize=9,
                fontweight='bold', color=color)

    # Flecha hacia abajo
    arrow = FancyArrowPatch((5.0, 1.3), (5.0, 0.6),
                            arrowstyle='->', mutation_scale=25,
                            linewidth=2.5, color='#1f3a5f')
    ax.add_patch(arrow)

    # Caja resultado
    result_box = FancyBboxPatch((2.0, 0.0), 6.0, 0.6, boxstyle="round,pad=0.05",
                                linewidth=2, edgecolor='#b85450',
                                facecolor='#f7ede8')
    ax.add_patch(result_box)
    ax.text(5.0, 0.3, 'NO TRANSFERIBLE → fallback: Cross-fitting (Chernozhukov 2018) + DM',
            ha='center', fontsize=10, fontweight='bold', color='#b85450')

    ax.set_title('Protocolo de Verificación (Proposición 9.14) — Diabetes 130-US',
                 fontsize=12, fontweight='bold', pad=10)
    fig.savefig(OUT_DIR / "fig_verification_protocol.pdf")
    plt.close(fig)
    print("[OK] fig_verification_protocol.pdf")


if __name__ == "__main__":
    fig_isomorphism_diagram()
    fig_traceability_table()
    fig_diabetes_results()
    fig_verification_protocol()
    print(f"\nFiguras guardadas en {OUT_DIR}")
