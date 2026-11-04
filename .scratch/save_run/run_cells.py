import glob
import io
import json
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


def run():
    results = {}
    for T in TS:
        for n in NS:
            cell = SAVE_RUN / "output_save_runs" / f"T{T}_n{n}"
            cell.mkdir(parents=True, exist_ok=True)
            Path(cell / "output").mkdir(exist_ok=True)
            true_val = float(pickle.load(open(SAVE / "output" / "value_int_store", "rb"))[T][0])
            pickle.dump({T: [true_val]}, open(cell / "output" / "value_int_store", "wb"))
            # Eliminar pickles prior para idempotencia:
            for f in glob.glob(str(cell / "CI_store_T_*")):
                os.remove(f)
            # Correr en este cwd con el mismo output_path relativo
            old = os.getcwd()
            os.chdir(cell)
            run_cell(seed=SEED, T=T, n=n, N=N_REP, output_path=".")
            os.chdir(old)
            # leer CI pickle
            cis = []
            for f in sorted(glob.glob(str(cell / "CI_store_T_*"))):
                with open(f, "rb") as fh:
                    while True:
                        try:
                            cis.append(pickle.load(fh))
                        except EOFError:
                            break
            def to_num(x):
                a = np.asarray(x)
                return float(a.flat[0])
            pairs = [(to_num(c[0]), to_num(c[1])) for c in cis]
            lb, ub = [p[0] for p in pairs], [p[1] for p in pairs]
            ecp = sum(1 for L, U in zip(lb, ub) if L < true_val < U) / len(lb) if lb else None
            al = float(np.mean(np.array(ub) - np.array(lb))) if lb else None
            preds = (np.array(lb) + np.array(ub)) / 2 if lb else None
            log_mse = float(np.log(np.mean((preds - true_val) ** 2))) if preds is not None else None
            results[f"{T},{n}"] = {"ECP": ecp, "AL": al, "logMSE": log_mse}
            print(f"T={T}, n={n}: bounds={len(lb)}, ECP={results[f'{T},{n}']['ECP']:.2f}, "
                  f"AL={results[f'{T},{n}']['AL']:.3f}, logMSE={results[f'{T},{n}']['logMSE']:.3f}",
                  flush=True)
    out_path = Path("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples")
    out_path.mkdir(parents=True, exist_ok=True)
    with open(out_path / "SAVE_results_AB.json", "w") as fh:
        json.dump(results, fh)
    print("escrito SAVE_results_AB.json")


if __name__ == "__main__":
    run()
