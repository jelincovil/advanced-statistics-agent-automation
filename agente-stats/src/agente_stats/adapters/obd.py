"""Adaptador Open Bandit Dataset → JSONL del contrato (stdlib csv, sin obp).

Lee las filas básicas del CSV del submuestreo vendorizado (Apache-2.0, ver
NOTICE.txt en `monografia_M/labs/data_obd/`): una ronda = una unidad H=1 con
acción = item_id, propensión registrada por diseño y recompensa binaria.
"""
from __future__ import annotations

import csv
import json
from pathlib import Path

AFFINITY_COLS = ("user-item_affinity_0", "user-item_affinity_1",
                 "user-item_affinity_2", "user-item_affinity_3")


def obd_csv_to_episodes(csv_path: str | Path, limit: int = 200,
                        campaign: str = "random") -> list[dict]:
    csv_path = Path(csv_path)
    episodes = []
    with csv_path.open("r", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for i, row in enumerate(reader):
            if i >= limit:
                break
            action = int(row["item_id"])
            prop = float(row["propensity_score"])
            features = {"position": float(row["position"])}
            for col in AFFINITY_COLS:
                features[f"affinity_{col.rsplit('_', 1)[-1]}"] = float(row[col])
            episodes.append({
                "episode_id": f"obd-{campaign}-{i:05d}",
                "unit": {"kind": "obd-round", "id": f"r-{i:05d}"},
                "policy_version": f"obd-{campaign}-campaign@2021",
                "horizon": 1,
                "propensity_mode": "recorded",
                "meta": {"seed": 0, "source": str(csv_path),
                         "environment": "ZOZOTOWN logged bandit subsample (obp 0.5.7), Apache-2.0"},
                "steps": [{
                    "t": 0,
                    "context": {"features": features},
                    "action": action,
                    "propensity": prop,
                    "reward": float(row["click"]),
                }],
            })
    return episodes


def write_adapter_output(csv_path: str | Path, out_path: str | Path,
                         limit: int = 200, campaign: str = "random") -> Path:
    episodes = obd_csv_to_episodes(csv_path, limit=limit, campaign=campaign)
    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as fh:
        for e in episodes:
            fh.write(json.dumps(e, ensure_ascii=False) + "\n")
    return out_path
