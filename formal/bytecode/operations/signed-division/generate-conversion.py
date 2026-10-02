#!/usr/bin/env python3
"""Emit constructive, checked integer/bitvector round trips through doubled widths."""
import argparse, subprocess, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def generate(out):
    text = '''// SPDX-License-Identifier: MIT
// Generated checked construction of fixed-width unsigned integer/bitvector round trips.
module OperationsSignedDivisionWordConversion {
  lemma Nat8(a: int)
    requires 0 <= a < 256
    ensures ((a as bv8) as int) == a
  {}
'''
    for width in (16, 32, 64, 128, 256):
        half = width//2
        base, bound = hex(1 << half), hex(1 << width)
        text += f'''  lemma Join{width}(hi: bv{half}, lo: bv{half})
    ensures ((((hi as bv{width}) << {half}) | (lo as bv{width})) as int) == {base}*(hi as int)+(lo as int)
  {{}}
  lemma Inverse{width}(bits: bv{width})
    ensures ((bits as int) as bv{width}) == bits
  {{}}
  lemma Nat{width}(a: int)
    requires 0 <= a < {bound}
    ensures ((a as bv{width}) as int) == a
  {{
    var quotient := a/{base};
    var remainder := a%{base};
    Nat{half}(quotient); Nat{half}(remainder);
    var bits := (((quotient as bv{half}) as bv{width}) << {half}) | ((remainder as bv{half}) as bv{width});
    Join{width}(quotient as bv{half},remainder as bv{half});
    assert (bits as int) == a;
    Inverse{width}(bits);
    assert (a as bv{width}) == bits;
  }}
'''
    text += '}\n'
    out.mkdir(parents=True, exist_ok=True)
    (out/'Conversion.generated.dfy').write_text(text)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    generate(a.output)
    subprocess.run([sys.executable, '-B', HERE/'format-generated.py', '--output', a.output, '--include-root', HERE], check=True)
