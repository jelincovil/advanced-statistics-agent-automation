import gymnasium as gym
from agent.state import AgentState

BATCH_SIZE = 50


async def collect_node(state: AgentState) -> AgentState:
    counts = dict(state.get("counts", {}))
    trajectories = list(state.get("trajectories", []))
    history = list(state.get("history", []))
    n_collected = state.get("n_collected", 0)
    n_episodes = state.get("n_episodes", 500)
    stream_every = state.get("stream_every", 50)

    env = gym.make("FrozenLake-v1", map_name="4x4", is_slippery=True)

    for _ in range(BATCH_SIZE):
        obs, _ = env.reset()
        s = int(obs)
        episode = []
        done = False

        while not done:
            a = env.action_space.sample()
            obs_next, reward, terminated, truncated, _ = env.step(a)
            sp = int(obs_next)
            done = terminated or truncated

            key = (s, a, sp)
            counts[key] = counts.get(key, 0) + 1
            episode.append((s, a, float(reward), sp))
            s = sp

        trajectories.append(episode)

    env.close()

    n_collected += BATCH_SIZE

    # Snapshot para gráficas (se llenará con varianzas reales en nodos posteriores)
    if n_collected % stream_every == 0 or n_collected >= n_episodes:
        history.append({
            "n": n_collected,
            "var_mc_mean": None,
            "var_rb_mean": None,
            "cr_bound_mean": None,
        })

    mode = "collect" if n_collected < n_episodes else "estimate"

    return {
        **state,
        "counts": counts,
        "trajectories": trajectories,
        "history": history,
        "n_collected": n_collected,
        "mode": mode,
    }
