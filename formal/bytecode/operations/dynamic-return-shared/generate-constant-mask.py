#!/usr/bin/env python3
"""Construct the compiler's NOT31 mask with checked eight-bit limbs."""
from pathlib import Path
import subprocess,argparse
HERE=Path(__file__).resolve().parent
s='''// SPDX-License-Identifier: MIT
// Generated constructive mask conversion. Never edit directly.
include "Machine.dfy"
module OperationsCodeConstantMask {
  import WC = OperationsAccountWordConversion
  function Full8(): bv8 { 255 }
  function Mask8(): bv8 { 224 }
  lemma FullNat8() ensures (Full8() as int)==255 {}
  lemma MaskNat8() ensures (Mask8() as int)==224 {}
'''
for w in [16,32,64,128,256]:
 h=w//2
 for name,lo,value in [('Full','Full',(1<<w)-1),('Mask','Mask',(1<<w)-32)]:
  s+=f'''  function {name}{w}(): bv{w} {{ ((Full{h}() as bv{w}) << {h}) | ({lo}{h}() as bv{w}) }}
  lemma {name}Nat{w}()
    ensures ({name}{w}() as int)=={value}
  {{
    FullNat{h}(); {lo}Nat{h}();
    WC.Join{w}(Full{h}(),{lo}{h}());
  }}
'''
s+='''  lemma BitsMask256()
    ensures Mask256()==0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
  {}
}
'''
a=argparse.ArgumentParser();a.add_argument('--output',type=Path,required=True);out=a.parse_args().output;out.mkdir(parents=True,exist_ok=True)
r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=s.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stdout+r.stderr
(out/'ConstantMask.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
