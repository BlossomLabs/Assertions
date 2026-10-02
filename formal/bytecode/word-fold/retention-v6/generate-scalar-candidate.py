#!/usr/bin/env python3
"""Translate scalar terminal faults while keeping the 32-byte RETURN oracle.

Canonical output must be byte-identical to the owned baseline generator. Only
the diagnostic parser accepts a changed terminal kind or size; the successful
semantic postcondition remains exactly Returned(Encode(word,32)).
"""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
OWNER = HERE.parent / 'scalar-return'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    path = OWNER / 'generate.py'
    source = path.read_text()
    replacements = [
        ('elif op == 0xf3:\n', 'elif op in (0xf3,0xfd):\n'),
        ("assert offset.text == 'free' and size.value == 32",
         "assert offset.text == 'free' and size.value in (32,33)"),
        ("            elif op == 0xfd:\n                raise ValueError('Successful candidate unexpectedly reached REVERT')\n", ''),
        ("            text += f'''  lemma Advance{i}",
         "            if n['op'] == 0xfd:\n                facts += '    MR.StoredWord(mem,free,word);\\n    MR.StoredFrame(mem,free,word,64);\\n    assert |Store(mem,free,word)| >= free+32;\\n    assert G.Grow(Store(mem,free,word),free+32) == Store(mem,free,word);\\n    assert Step(code,Destinations(),state,value,data).Reverted?;\\n'\n            text += f'''  lemma Advance{i}"),
    ]
    for before, after in replacements:
        assert source.count(before) == 1, 'Scalar mutation adapter drift'
        source = source.replace(before, after)
    namespace = {'__name__': 'fold_scalar_candidate', '__file__': str(path)}
    exec(compile(source, str(path), 'exec'), namespace)
    namespace['generate'](args.output)
    subprocess.run([sys.executable, '-B', OWNER / 'format-generated.py',
                    '--output', args.output, '--include-root', OWNER], check=True)


if __name__ == '__main__':
    main()
