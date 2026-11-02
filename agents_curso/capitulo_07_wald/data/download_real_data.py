"""
download_real_data.py — Fetch the real UCI German Credit dataset.

Run this once if you have network access to replace the bundled
synthetic CSV with the real one.

Usage (from the project root):
    python data/download_real_data.py
"""
import sys
from pathlib import Path
import pandas as pd

OUT = Path(__file__).parent / "german_credit.csv"

def main():
    try:
        from sklearn.datasets import fetch_openml
        bunch = fetch_openml("credit-g", version=1, as_frame=True)
    except Exception as e:
        sys.exit(f"Could not fetch from OpenML: {e}\n"
                 "Falling back: keep using the bundled synthetic CSV.")
    df = bunch.frame.copy()
    df.rename(columns={"class": "class"}, inplace=True)
    df.to_csv(OUT, index=False)
    print(f"Saved real German Credit dataset to {OUT}: {df.shape}")
    print(f"bad rate = {(df['class']=='bad').mean():.3f}")


if __name__ == "__main__":
    main()
