from typing import TypedDict


class AgentState(TypedDict, total=False):
    # Configuración del experimento
    n_episodes: int          # Total de episodios a recolectar
    n_collected: int         # Episodios recolectados hasta ahora
    gamma: float             # Factor de descuento γ (default 0.95)

    # Estadístico suficiente T(X)
    counts: dict             # N(s,a,s') — conteos de transiciones

    # Datos brutos
    trajectories: list       # [(s,a,r,s'), ...] por episodio

    # Estimadores
    theta_hat: dict          # UMVUE: N(s,a,s') / N(s,a)
    q_mc: dict               # Estimador Monte Carlo bruto Q̂_MC(s,a)
    q_rb: dict               # Rao-Blackwell Q̃(s,a) = E[Q_MC | T(X)]

    # Varianzas empíricas
    var_mc: dict             # Varianza empírica del estimador MC
    var_rb: dict             # Varianza empírica del estimador RB

    # Fisher e información de Cramér-Rao
    fisher_info: dict        # I(θ̂_{s,a,s'}) = 1 / (θ̂(1−θ̂))
    cramer_rao_bound: dict   # CR(s,a,s') = 1 / (N(s,a) · I(θ̂))

    # Función de valor
    value_hat: dict          # V̂^π(s) por estado
    value_se: dict           # SE(V̂^π(s))

    # Sample planning
    min_episodes_for_target: dict  # {'eps_0.1': n1, 'eps_0.05': n2, 'eps_0.01': n3}

    # Histórico para gráficas
    history: list            # Snapshots (n, var_mc_mean, var_rb_mean, cr_bound_mean)

    # Resultado del nodo analyst
    analysis_text: str

    # Control de flujo
    mode: str                # 'collect' | 'estimate' | 'compare' | 'sample_plan' | 'done'
    stream_every: int        # Emitir update Chainlit cada N episodios (default 50)
