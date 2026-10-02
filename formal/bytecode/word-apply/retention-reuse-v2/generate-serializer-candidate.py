#!/usr/bin/env python3
"""Keep success semantics while exposing a mutated terminal's EVM state kind.

The existing parser already supports RETURN and REVERT. Its mutant-only
diagnostic originally re-proved the entire ABI memory slice before reaching the
unchanged Returned postcondition. The state constructor is sufficient to show
the contradiction. Baseline generated files must remain byte-identical.
"""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OWNER = HERE.parent / 'serializer-repair-v2'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    path = OWNER / 'generate.py'
    source = path.read_text()
    before = 'assert R.Stage(mem,free,n,payload,4)[free..free+64+n*32] == R.Bytes(n,payload);'
    after = 'assert S.Step(code,Destinations(),state,value,data).Reverted?;'
    assert source.count(before) == 1, 'Candidate serializer adapter drift'
    source = source.replace(before, after)
    ns = {'__name__': 'candidate_serializer_parser', '__file__': str(path)}
    exec(compile(source, str(path), 'exec'), ns)
    ns['generate'](a.output)
    subprocess.run([sys.executable, '-B', OWNER.parent / 'map-prefix/format-generated.py',
                    '--output', a.output, '--include-root', OWNER], check=True)


if __name__ == '__main__':
    main()
