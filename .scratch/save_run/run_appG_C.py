import sys, os
sys.path.insert(0, '/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/.scratch/save_run/save')
sys.path.insert(0, '/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/.scratch/save_run/save/cliffwalking_exp')
import pickle
import numpy as np
from model.AGENT import *
from lib.envs.cliff_walking import CliffWalkingEnv
import numpy.random as npr


def run_scenario_C(n_samples: int, rep: int = 100, seed: int = 1, gamma: float = 0.5):
    env = CliffWalkingEnv()
    Q_space = np.load('/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/.scratch/save_run/save/cliffwalking_exp/Q-table-cliff.npz')['xxx']
    prob1 = np.ones(env.nA) / env.nA
    alpha = 1.0
    betabeta = 0.5
    def sample_policy(observation):
        probs = alpha * Q_space[observation, :] + (1 - alpha) * prob1
        return np.random.choice(env.nA, 1, p=probs / probs.sum())[0]
    def behavior_policy(observation):
        probs = betabeta * Q_space[observation, :] + (1 - betabeta) * prob1
        return np.random.choice(env.nA, 1, p=probs / probs.sum())[0]

    rng = np.random.default_rng(seed)
    npr.seed(seed)
    random.seed(seed) if False else None

    a = simulation(env, n=n_samples, reward_dicount=gamma, scale="Cliffwalk_noise")
    est_mean = -3.301610434961245
    bounds, preds, cov, al = [], [], 0, []
    fails = 0
    for _ in range(rep):
        a.buffer = {}
        a.gen_buffer(total_N=None, S_init=None, policy=behavior_policy)
        try:
            a.B_spline_degrade()
            lb, ub = a.inference(policy=sample_policy, S=36)
            lb = float(np.asarray(lb).flat[0]); ub = float(np.asarray(ub).flat[0])
        except Exception as e:
            fails += 1
            continue
        pred = (lb + ub) / 2
        bounds.append((lb, ub))
        preds.append(pred)
        al.append(ub - lb)
        cov += int(lb < est_mean < ub)
    if fails:
        print(f"  (réplicas fallidas por singularidad:  matríz singular de Sigma_hat = {fails} de {rep} рэясிற кегள் bouquets)^2)")
    ecp = cov / len(al) if al else None
    al_mean = float(np.mean(al)) if al else None
    preds = np.array(preds)
    mse = float(np.mean((preds - est_mean) ** 2)) if len(preds) else None
    log_mse = float(np.log(mse)) if mse else None
    return {"n_samples": n_samples, "n_bounds": len(al),
            "ECP": ecp, "AL": al_mean, "logMSE": log_mse}


if __name__ == "__main__":
    import json
    out = {}
    for n in (500, 1000, 1500):
        out[str(n)] = run_scenario_C(n)
        print(f"C n={n}: {out[str(n)]}", flush=True)
    out_file = '/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples/SAVE_results_C.json'
    with open(out_file, 'w') as fh:
        json.dump(out, fh, indent=1)
    print('escrito', out_file)
