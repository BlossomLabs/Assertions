#!/usr/bin/env python3
"""Emit checked constructive byte extraction from complete unsigned words."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

def generate(out):
 text='// SPDX-License-Identifier: MIT\n// Generated constructive first-byte bitvector bridge; every declaration requires native proof.\ninclude "../../word-apply/word-conversion/Conversion.generated.dfy"\nmodule BytecodeFoldByteShiftV6 {\n  import V = BytecodeApplyWordConversion\n'
 for width in [8,16,32,64,128,256]:
  if width>8:
   half=width//2;factor=1 << half
   text+=f'  opaque function Join{width}(hi: bv{half},lo: bv{half}): bv{width}\n    ensures (Join{width}(hi,lo) as int) == {factor}*(hi as int)+(lo as int)\n  {{ V.Join{width}(hi,lo); ((hi as bv{width}) << {half}) | (lo as bv{width}) }}\n'
   text+=f'  lemma Split{width}(hi: bv{half},lo: bv{half})\n    ensures ((Join{width}(hi,lo) >> {width-8}) as int) == ((hi >> {half-8}) as int)\n  {{ reveal Join{width}(); }}\n'
  if width>8:
   text+=f'  lemma Equal{width}(a: bv{width},b: bv{width})\n    requires (a as int) == (b as int)\n    ensures a == b\n  {{ V.Inverse{width}(a); V.Inverse{width}(b); }}\n'
   text+=f'  lemma FromNat{width}(n: int,bits: bv{width})\n    requires 0 <= n < {1 << width} && (bits as int) == n\n    ensures (n as bv{width}) == bits\n  {{ V.Inverse{width}(bits); }}\n'
   text+=f'  lemma Divide{width}(n: nat)\n    ensures (n/{factor})/{1 << (half-8)} == n/{1 << (width-8)}\n  {{}}\n'
  text+=f'  lemma Top{width}(n: int)\n    requires 0 <= n < {1 << width}\n    ensures (((n as bv{width}) >> {width-8}) as int) == n/{1 << (width-8)}\n  {{\n'
  if width==8:text+='    V.Nat8(n);\n  }\n'
  else:
   text+=f'    hide Join{width}();\n    var quotient := n/{factor}; var remainder := n%{factor};\n    V.Nat{half}(quotient); V.Nat{half}(remainder);\n    var hi := quotient as bv{half}; var lo := remainder as bv{half};\n    assert (hi as int) == quotient; assert (lo as int) == remainder;\n    var joined := Join{width}(hi,lo);\n    assert (joined as int) == {factor}*quotient+remainder;\n    assert {factor}*quotient+remainder == n;\n    FromNat{width}(n,joined);\n    Split{width}(hi,lo); Top{half}(quotient);\n    Divide{width}(n);\n  }}\n'
 text+='}\n';out.mkdir(parents=True,exist_ok=True);(out/'Shift.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
