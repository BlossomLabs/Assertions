#!/usr/bin/env python3
"""Format tracked formal JSON compactly without changing gate or specification data."""
import argparse
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
WIDTH = 160


def render(value, depth=0, prefix=0):
    indent = '  ' * depth
    compact = json.dumps(value, separators=(', ', ': '))
    if len(indent) + prefix + len(compact) <= WIDTH or not isinstance(value, (dict, list)):
        return indent + compact
    opening, closing = ('{', '}') if isinstance(value, dict) else ('[', ']')
    lines = [indent + opening]
    items = list(value.items()) if isinstance(value, dict) else list(enumerate(value))
    for ordinal, (key, child) in enumerate(items):
        label = json.dumps(key) + ': ' if isinstance(value, dict) else ''
        child_lines = render(child, depth + 1, len(label)).splitlines()
        if label:
            child_lines[0] = '  ' * (depth + 1) + label + child_lines[0].lstrip()
        if ordinal + 1 < len(items):
            child_lines[-1] += ','
        lines.extend(child_lines)
    return '\n'.join([*lines, indent + closing])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    paths = subprocess.check_output(['git', 'ls-files', '-z', 'formal'], cwd=ROOT).decode().split('\0')
    changed = []
    for name in paths:
        if not name.endswith('.json'):
            continue
        path = ROOT / name
        original = path.read_text()
        value = json.loads(original)
        formatted = render(value) + '\n'
        if json.loads(formatted) != value:
            raise RuntimeError('JSON data changed: ' + name)
        if original != formatted:
            changed.append(name)
            if not args.check:
                path.write_text(formatted)
    if args.check and changed:
        parser.exit(1, 'Reformat formal JSON: ' + ', '.join(changed) + '\n')
    print(f'{"Checked" if args.check else "Formatted"} {len(changed)} changed JSON files.')


if __name__ == '__main__':
    main()
