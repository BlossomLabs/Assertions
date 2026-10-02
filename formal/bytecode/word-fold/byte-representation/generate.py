#!/usr/bin/env python3
"""Emit checked constructive byte extraction from complete unsigned words."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

def generate(out):
 text='// SPDX-License-Identifier: MIT\n// Generated constructive first-byte bitvector bridge; every declaration requires native proof.\ninclude "../../word-apply/word-conversion/Conversion.generated.dfy"\nmodule BytecodeFoldByteShift {\n  import V = BytecodeApplyWordConversion\n'
 for width in [8,16,32,64,128,256]:
  text+=f'  lemma Top{width}(bits: bv{width})\n    ensures ((bits >> {width-8}) as int) == (bits as int)/{1 << (width-8)}\n  {{\n'
  if width==8:text+='  }\n'
  else:
   half=width//2;factor=1 << half
   text+=f'    var hi := ((bits as int)/{factor}) as bv{half};\n    var lo := ((bits as int)%{factor}) as bv{half};\n    V.Nat{half}((bits as int)/{factor}); V.Nat{half}((bits as int)%{factor});\n    V.Join{width}(hi,lo);\n    var joined := ((hi as bv{width}) << {half}) | (lo as bv{width});\n    assert (joined as int) == (bits as int);\n    V.Inverse{width}(bits); V.Inverse{width}(joined);\n    assert bits == joined;\n    assert ((joined >> {width-8}) as int) == ((hi >> {half-8}) as int);\n    Top{half}(hi);\n    assert ((bits as int)/{factor})/{1 << (half-8)} == (bits as int)/{1 << (width-8)};\n  }}\n'
 text+='}\n';out.mkdir(parents=True,exist_ok=True);(out/'Shift.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
