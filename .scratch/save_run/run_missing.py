import glob
import io
import os
import pickle
import sys
import contextlib
from pathlib import Path

import numpy as np

SAVE = Path(__file__).resolve().parent / "save"
sys.path.insert(0, str(SAVE))
from src.exp_int import main as run_cell  # noqa: E402
SAVE_RUN = Path(__file__).resolve().parent

NS = (25, 50, 100)
TS = (30, 50, 70)
N_REP = 50
SEED = 1
DONE = {  # ya completadas en versión actual (file results AB)
    (30, 50),
}


def run():
    results = json.load(open("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples/SAVE_results_AB.json")) \
        if os.path.exists("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples/SAVE_results_AB.json") else {}
    for T in TS:
        for n in NS:
            if (T, n) in DONE:
                print(f"skip T={T}, n={n} (ya calculado)", flush=True)
                continue
            cell = SAVE_RUN / "output_save_runs" / f"T{T}_n{n}"
            cell.mkdir(parents=True, exist_ok=True)
            Path(cell / "output").mkdir(exist_ok=True)
            true_val = float(pickle.load(open(SAVE / "output" / "value_int_store", "rb"))[T][0])
            pickle.dump({T: [true_val]}, open(cell / "output" / "value_int_store", "wb"))
            old = os.getcwd()
            os.chdir(cell)
            run_cell(seed=SEED, T=T, n=n, N=N_REP, output_path=".")
            os.chdir(old)
            # analyze
            f = cell / f"CI_store_T_{T}_n_{n}_S_init_int_simulation_1_2"
            cis = []
            with open(f, "rb") as fh:
                while True:
                    try:
                        cis.append(pickle.load(fh))
                    except EOFError:
                        break
            pairs = [(float(np.asarray(c[0]).flat[0]), float(np.asarray(c[1]).flat[0])) for c in cis]
            lb = np.array([p[0] for p in pairs]); ub = np.array([p[1] for p in pairs])
            ecp = float(np.mean((lb < true_val) & (ub > true_val)))
            al = float(np.mean(ub - lb))
            preds = (lb + ub) / 2
            log_mse = float(np.log(np.mean((preds - true_val) ** 2)))
            results[f"{T},{n}"] = {"ECP": ecp, "AL": al, "logMSE": log_mse, "n_bounds": len(lb)}
            print(f"T={T}, n={n}: ECP={ecp:.2f}, AL={al:.3f}, logMSE={log_mse:.3f}, bounds={len(lb)}", flush=True)
            with open("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples/SAVE_results_AB.json", "w") as fh:
                json.dump(results, fh, indent=1)
    print("cerrado todo")


if __name__ == "__main__":
    import json
    run()
