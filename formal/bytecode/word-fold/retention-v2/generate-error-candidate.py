#!/usr/bin/env python3
"""Translate a changed CallbackFailed terminal, retaining the REVERT oracle."""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OWNER = HERE.parent / 'callback-failed-repair-v2'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    path = OWNER / 'generate.py'
    source = path.read_text()
    replacements = [
        ('elif op==253:\n', 'elif op in (253,243):\n'),
        ('            fetch=f"',
         "            if op==243:facts+='    assert Step(code,Destinations(),state,value,data).Returned?;\\n'\n            fetch=f\""),
    ]
    for before, after in replacements:
        assert source.count(before) == 1, 'Error mutation adapter drift'
        source = source.replace(before, after)
    namespace = {'__name__': 'fold_error_candidate', '__file__': str(path)}
    exec(compile(source, str(path), 'exec'), namespace)
    namespace['generate'](args.output)
    subprocess.run([sys.executable, '-B', OWNER / 'format-generated.py',
                    '--output', args.output, '--include-root', OWNER], check=True)


if __name__ == '__main__':
    main()
