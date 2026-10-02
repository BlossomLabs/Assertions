#!/usr/bin/env python3
"""Parse both EVM termination opcodes without changing the error packet oracle.

The baseline generator specializes the noncanonical predicate path to REVERT.
This adapter admits RETURN as another physical termination instruction so that a
single-byte fault reaches the unchanged Reverted postcondition. It changes no
semantic packet, admission, trace, or postcondition expression. Baseline output
must regenerate byte-for-byte identically before using it for a mutation.
"""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OWNER = HERE.parent / 'predicate-error-repair-v3'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    path = OWNER / 'generate.py'
    source = path.read_text()
    changes = {
        'elif op == 253:': 'elif op in (243,253):',
        "if s['op'] == 253:": "if s['op'] in (243,253):",
    }
    for before, after in changes.items():
        assert source.count(before) == 1, 'Candidate parser adapter drift'
        source = source.replace(before, after)
    ns = {'__name__': 'candidate_predicate_parser', '__file__': str(path)}
    exec(compile(source, str(path), 'exec'), ns)
    ns['generate'](a.output)
    subprocess.run([sys.executable, '-B', OWNER.parent / 'map-prefix/format-generated.py',
                    '--output', a.output, '--include-root', OWNER], check=True)


if __name__ == '__main__':
    main()
