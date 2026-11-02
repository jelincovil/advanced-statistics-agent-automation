from pathlib import Path
import ast
import re


def extraer():
    root = Path(__file__).resolve().parent
    source = (root / 'capitulos/cap10_casos.typ').read_text(encoding='utf-8')
    programs = []
    filename = None
    collecting = False
    lines = []
    for line in source.splitlines():
        if line.startswith('#codelisting-env'):
            match = re.search(r'`(lab[0-9]+[a-z]?_[^`]+\.py)`', line)
            filename = match.group(1) if match else None
        elif filename and line.strip() == '```python':
            collecting = True
            lines = []
        elif collecting and line.strip() == '```':
            programs.append((filename, '\n'.join(lines) + '\n'))
            filename = None
            collecting = False
        elif collecting:
            lines.append(line)
    if len(programs) != 14:
        raise ValueError(f'Se esperaban 14 programas y se encontraron {len(programs)}')
    for filename, content in programs:
        content = content.rstrip() + '\n'
        ast.parse(content, filename=filename)
        destination = root / filename
        if destination.exists() and destination.read_text(encoding='utf-8') != content:
            raise FileExistsError(f'{filename} difiere del listado; revisar antes de sobrescribir')
        destination.write_text(content, encoding='utf-8')
    return [filename for filename, _ in programs]


if __name__ == '__main__':
    print('\n'.join(extraer()))
