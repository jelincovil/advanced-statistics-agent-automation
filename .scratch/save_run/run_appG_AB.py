"""Reproducción Apéndice G (Fase 4) de SZLS 2022 sobre commit 7533c28.

Escenarios A/B en `src/exp_int.py` (S_init="int", integrated initial state):
  - valor verdadero: main_get_value(con rep=100000, T variable)
  - N=50 réplicas de (T, n) ∈ {30,50,70} × {25,50,100}
  - Semilla: (((1 + seed) * N + (i + 1)) * 1234567), seed=1 → seeds
  - L = int(sqrt((n*T)**(3/7)))

Métricas (idénticas al driver de los autores): ECP (count cobertura/50),
AL = 2*1.96*σ/√n, log(MSE) con (ŝ−valor)² promediado sobre las 50 réplicas.

Lectura de `est_mean` desde `output/value_int_store` construido con nuestro MC,
por compatibilidad con el formato dict[T] = list de mapas.
"""
import os
import sys
import pickle
import numpy as np
from pathlib import Path

SAVE = Path(__file__).resolve().parent / "save"
sys.path.insert(0, str(SAVE))
os.chdir(SAVE)

from scipy.stats import norm
from src.exp_int import main_get_value, main

OUT = Path("output_save_runs")
OUT.mkdir(exist_ok=True)

NS = (25, 50, 100)
TS = (30, 50, 70)
REP = 100_000
N_REP = 50
SEED = 1

# 1) true values: construir output/value_int_store como dict T→list (los result-
def gather_true_values():
    print("=== verdaderos por T (MC rep=100000) ===")
    main_get_value(T_List=[30, 50, 70], rep=REP, filename_train=None,
                   output_path="output")
    with open("output/value_int_store", "rb") as fh:
        d = pickle.load(fh)
    return d


def cell(T: int, n: int) -> dict:
    # Regenerar una sola réplica siguiendo las seeds de los autores no es posible
    # sin reejecutar todo — dependemos de su mismo ruido. Ejecutamos `main` con
    # su semilla validada y leemos outputs de value store + ci_store.
    #
    # Cambiamos cwd a una subcarpeta por celda para no pisar los stores de TR.
    cells_dir = OUT / f"T{T}_n{n}"
    cells_dir.mkdir(exist_ok=True, parents=True)
    (OUT / "output").mkdir(exist_ok=True)
    os.chdir(cells_dir)
    # seeds: main usa ((1 + seed) * N + (i + 1)) * 1234567 en cada réplica i
    est_mean = pickle.load(open("output/value_int_store", "rb"))[T][0]
    # Capturar CIs/valor punto legacy — rerun completo
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        # pickle CI en celda
        main(seed=SEED, T=T, n=n, N=N_REP, output_path=".")
    return {"ci_output": buf.getvalue()}


def metrics_from_run(estimators: np.ndarray, ci_bounds: list, est_mean: float) -> dict:
    est = np.asarray(estimators, dtype=float)
    covs = sum(1 for lo, hi in ci_bounds if lo < est_mean < hi)
    AL = float(np.mean([hi - lo for lo, hi in ci_bounds]))
    mse = float(np.mean((est - est_mean) ** 2))
    return {"ECP": covs / len(ci_bounds), "AL": AL, "logMSE": float(np.log(mse))}


def run_AB():
    true_by_T = gather_true_values()
    print("true por T:", {t: round(float(np.mean(v)), 6) for t, v in true_by_T.items()})
    print("
=== plan de corrida (implant en src/exp_int.main) ===")
    for T in TS:
        for n in NS:
            print(f"T={T}, n={n}: a ejecutar main(seed={SEED}, N={N_REP})")
            # cell(T, n) ejecutado externamente o aquí en secuencia:
            # output celdas están en ./output_save_runs/T{T}_n{n}
            pass
    # Ejecutamos y parseamos en este mismo harness:
    all_results = {}
    for T in TS:
        for n in NS:
            # crear celda
            cells_dir = OUT / f"T{T}_n{n}"
            cells_dir.mkdir(exist_ok=True, parents=True)
            old = os.getcwd()
            os.chdir(cells_dir)
            (Path("output")).mkdir(exist_ok=True)
            # value_int_store con el T correcto (mins english)
            vstore = {"output": Path("output/value_int_store")}
            pickle.dump({T: true_by_T[T]}, open("output/value_int_store", "wb"))
            import io, contextlib
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                main(seed=SEED, T=T, n=n, N=N_REP, output_path=".")
            out = buf.getvalue()
            # leer CI pickle de outfile_CI
            import glob
            ci_files = glob.glob("CI_store_T_*")
            cis = []
            for f in ci_files:
                try:
                    with open(f, "rb") as fh:
                        while True:
                            cis.append(pickle.load(fh))
                except EOFError:
                    pass
            est_mean = float(np.mean(true_by_T[T]))
            # los estimadores: main_pickle los guarda f_write intermedios — 
            parsers = [r for r in out.split("\n") if "Lower bound" in r]
            lb, ub, countable = [], [], 0
            for line in out.splitlines():
                if "Lower bound" in line:
                    parts = line.split()
                    lb.append(float(parts[2]))
                    ub.append(float(parts[6]))
            al = np.mean(np.array(ub) - np.array(lb)) if lb else None
            ecp = sum(1 for L, U in zip(lb, ub) if L < est_mean < U) / len(lb) if lb else None
            # MSE: del estimador (medias de IC)
            preds = (np.array(lb) + np.array(ub)) / 2 if lb else np.array([])
            mse = float(np.mean((preds - est_mean) ** 2)) if len(preds) else None
            all_results[(T, n)] = {
                "ECP": ecp, "AL": None if al is None else float(al),
                "logMSE": None if mse is None else float(np.log(mse)),
                "n_runs": len(lb),
            }
            print(f"T={T}, n={n}: ECP={all_results[(T,n)]['ECP']}, AL={all_results[(T,n)]['AL']}, logMSE={all_results[(T,n)]['logMSE']}, runs={len(lb)}")
            os.chdir(old)
    return all_results


if __name__ == "__main__":
    import sys
    which = sys.argv[1] if len(sys.argv) > 1 else "AB"
    if which == "AB":
        results = run_AB()
        out_file = Path("/workspace/nucleus/work/projects/p-f4a5f92c912f41d1b16c220e3d6eb24d/repo/agente-stats/examples")
        out_file.mkdir(parents=True, exist_ok=True)
        with open(out_file / "SAVE_results_AB.json", "w") as fh:
            import json
            json.dump({f"{T,n}:{":bred";"bre": json if False else None} for result in []
                           for T, n in [((iter([]) or None), iter([]) or None)]}, fh)
        print("results:")
        for k, v in results.items():
            print(k, v)
