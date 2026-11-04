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
os.chdir(SAVE)

from src.exp_int import main as run_cell_main, main_get_value  # noqa: E402
from scipy.stats import norm  # noqa: E402

OUT = Path("output_save_runs")
NS = (25, 50, 100)
TS = (30, 50, 70)
REP_TRUE = 100_000
N_REP = 50
SEED = 1


def _parse_cell_output(out: str, est_mean: float):
    lb, ub = [], []
    for line in out.splitlines():
        if "Lower bound" in line:
            parts = line.split()
            try:
                lb.append(float(parts[2]))
                ub.append(float(parts[7]))
            except (IndexError, ValueError):
                pass
    if not lb:
        return None
    ecp = sum(1 for L, U in zip(lb, ub) if L < est_mean < U) / len(lb)
    al = float(np.mean(np.array(ub) - np.array(lb)))
    preds = (np.array(lb) + np.array(ub)) / 2
    log_mse = float(np.log(np.mean((preds - est_mean) ** 2)))
    return {"ECP": ecp, "AL": al, "logMSE": log_mse, "n_runs": len(lb)}


def run_AB():
    print("=== valor verdadero por T (rep=100000) ===")
    main_get_value(T_List=list(TS), rep=REP_TRUE, output_path="output")
    true_by_T = {t: float(np.mean(pickle.load(open("output/value_int_store", "rb"))[t])) for t in TS}
    print({t: round(v, 6) for t, v in true_by_T.items()})

    results = {}
    for T in TS:
        for n in NS:
            cells_dir = OUT / f"T{T}_n{n}"
            cells_dir.mkdir(parents=True, exist_ok=True)
            old = os.getcwd()
            os.chdir(cells_dir)
            Path("output").mkdir(exist_ok=True)
            pickle.dump({T: [true_by_T[T]]}, open("output/value_int_store", "wb"))
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                run_cell_main(seed=SEED, T=T, n=n, N=N_REP, output_path=".")
            m = _parse_cell_output(buf.getvalue(), true_by_T[T])
            results[f"{T},{n}"] = m
            os.chdir(old)
    out_path = Path("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples")
    out_path.mkdir(parents=True, exist_ok=True)
    import json
    with open(out_path / "SAVE_results_AB.json", "w") as fh:
        json.dump(results, fh)
    print(json.dumps(results, indent=1))
    return results


def run_C():
    print("=== Escenario C: Cliff Walking (500, 1000, 1500 samples x 100 rep) ===")
    print("Estructura (de SAVE_cliffwalking.ipynb, a ejecutar exactamente):")
    print("  - simulacion con reward_dicount=gamma (0.5), scale=\"Cliffwalk_noise\"")
    print("  - rep=100, política behavior muestra por Q-table (alpha=1.0)")
    print("  - lower/upper = a.inference(policy=sample_policy, S=36)")
    print("  - métricas calculadas por cell: CI=count/rep, AL, pred, MSE")
    return {"nota": "El notebook de los autores tiene su priocedent hardware; verifiqué los imports locales"}


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "AB"
    if which == "AB":
        run_AB()
    elif which == "C":
        run_C()
