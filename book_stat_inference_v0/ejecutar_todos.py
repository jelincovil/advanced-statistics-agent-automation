from pathlib import Path
import hashlib
import importlib.metadata
import json
import os
import platform
import subprocess
import sys
import time

from extraer_laboratorios import extraer


def main():
    root = Path(__file__).resolve().parent
    programs = extraer()
    versions = {'python': platform.python_version(), 'platform': platform.platform()}
    for package in ['numpy', 'scipy', 'scikit-learn', 'gymnasium', 'pandas']:
        versions[package] = importlib.metadata.version(package)
    (root / 'versiones.json').write_text(json.dumps(versions, indent=2), encoding='utf-8')
    results = []
    environment = dict(os.environ)
    environment.update(OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    for filename in programs:
        started = time.perf_counter()
        try:
            completed = subprocess.run([sys.executable, str(root / filename)], cwd=root,
                                       env=environment, capture_output=True, text=True, timeout=600)
            result = {'file': filename, 'returncode': completed.returncode,
                      'stdout': completed.stdout, 'stderr': completed.stderr}
        except subprocess.TimeoutExpired as error:
            result = {'file': filename, 'returncode': None, 'stdout': str(error.stdout or ''),
                      'stderr': 'Tiempo máximo de 600 segundos alcanzado'}
        result['seconds'] = time.perf_counter() - started
        result['sha256'] = hashlib.sha256((root / filename).read_bytes()).hexdigest()
        results.append(result)
        (root / 'resultados_laboratorios.json').write_text(
            json.dumps({'versions': versions, 'results': results}, ensure_ascii=False, indent=2),
            encoding='utf-8')
        print(filename, result['returncode'], round(result['seconds'], 2), flush=True)
    if any(result['returncode'] != 0 for result in results):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
