#!/usr/bin/env python3
"""Generate first-byte extraction with pure bitvector and integer interfaces."""
import argparse, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

def generate(out):
 text='// SPDX-License-Identifier: MIT\n// Generated first-byte bridge; all declarations require native proof.\ninclude "../../word-apply/word-conversion/Conversion.generated.dfy"\nmodule BytecodeFoldByteShiftV7 {\n  import V = BytecodeApplyWordConversion\n'
 for width in [8,16,32,64,128,256]:
  if width>8:
   half=width//2;factor=1 << half;divisor=1 << (width-8);small=1 << (half-8)
   text+=f'  lemma Halves{width}(bits: bv{width}) returns (hi: bv{half},lo: bv{half})\n    ensures (bits as int) == {factor}*(hi as int)+(lo as int)\n    ensures bits >> {width-8} == ((hi >> {half-8}) as bv{width})\n  {{\n    hi := (bits >> {half}) as bv{half}; lo := bits as bv{half};\n    assert bits == ((hi as bv{width}) << {half}) | (lo as bv{width});\n    V.Join{width}(hi,lo);\n  }}\n'
   text+=f'  lemma Extend{width}(bits: bv{half})\n    ensures ((bits as bv{width}) as int) == (bits as int)\n  {{\n    assert (bits as bv{width}) == (((0 as bv{half}) as bv{width}) << {half}) | (bits as bv{width});\n    V.Join{width}(0,bits);\n  }}\n'
   text+=f'  lemma Divide{width}(n: int,hi: int,lo: int)\n    requires n == {factor}*hi+lo && 0 <= hi && 0 <= lo < {factor}\n    ensures n/{divisor} == hi/{small}\n  {{\n    assert n/{factor} == hi;\n    assert (n/{factor})/{small} == n/{divisor};\n  }}\n'
  text+=f'  lemma Top{width}(bits: bv{width})\n    ensures ((bits >> {width-8}) as int) == (bits as int)/{1 << (width-8)}\n  {{\n'
  if width>8:
   text+=f'    var hi,lo := Halves{width}(bits);\n    Extend{width}(hi >> {half-8});\n    Top{half}(hi);\n    Divide{width}(bits as int,hi as int,lo as int);\n'
  text+='  }\n'
 text+='}\n';out.mkdir(parents=True,exist_ok=True);(out/'Shift.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
