"""
Persistencia SQLite del estadístico suficiente — Lab F.2 Chainlit.

Demo de la ventaja del estadístico suficiente: para reanudar un stream
basta con guardar 2 enteros (count, total). Un agente insuficiente
necesitaría toda la secuencia de observaciones para recuperar el mismo estado.
"""

from __future__ import annotations

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


_DB_PATH = Path(__file__).parent / "checkpoints.db"


class SufficientCheckpointer:
    """Guarda y recupera el estadístico suficiente T_n = (count, total) en SQLite."""

    def __init__(self, db_path: Path | str = _DB_PATH):
        self.db_path = str(db_path)
        self._init_db()

    def _init_db(self) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "CREATE TABLE IF NOT EXISTS checkpoints ("
                "session_id TEXT PRIMARY KEY, "
                "count INT NOT NULL, "
                "total INT NOT NULL, "
                "theta_true REAL NOT NULL, "
                "created_at TEXT DEFAULT CURRENT_TIMESTAMP"
                ")"
            )

    def save(self, session_id: str, state: dict) -> None:
        """Persiste T_n = (count, total) para session_id."""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute(
                "INSERT OR REPLACE INTO checkpoints "
                "(session_id, count, total, theta_true, created_at) VALUES (?, ?, ?, ?, ?)",
                (
                    session_id,
                    state["count"],
                    state["total"],
                    state.get("theta_true") or 0.3,
                    datetime.now().isoformat(timespec="seconds"),
                ),
            )

    def load(self, session_id: str) -> Optional[Dict]:
        """Recupera el estado de session_id. Retorna None si no existe."""
        with sqlite3.connect(self.db_path) as conn:
            row = conn.execute(
                "SELECT session_id, count, total, theta_true, created_at "
                "FROM checkpoints WHERE session_id = ?",
                (session_id,),
            ).fetchone()
        if row is None:
            return None
        count, total = row[1], row[2]
        return {
            "session_id": row[0],
            "count": count,
            "total": total,
            "theta_true": row[3],
            "created_at": row[4],
            "theta_hat": total / count if count > 0 else 0.5,
        }

    def list_sessions(self) -> List[Dict]:
        """Retorna las 10 sesiones más recientes."""
        with sqlite3.connect(self.db_path) as conn:
            rows = conn.execute(
                "SELECT session_id, count, theta_true, created_at "
                "FROM checkpoints ORDER BY created_at DESC LIMIT 10"
            ).fetchall()
        return [
            {
                "session_id": r[0],
                "count": r[1],
                "theta_true": r[2],
                "created_at": r[3],
            }
            for r in rows
        ]

    def delete(self, session_id: str) -> bool:
        """Elimina una sesión. Retorna True si existía."""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute(
                "DELETE FROM checkpoints WHERE session_id = ?", (session_id,)
            )
        return cursor.rowcount > 0
