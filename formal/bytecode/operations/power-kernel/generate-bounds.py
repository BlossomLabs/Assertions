#!/usr/bin/env python3
"""Construct compiler power-shortcut bounds from explicit integer products."""
import argparse
from pathlib import Path

def generate(out):
    out.mkdir(parents=True,exist_ok=True)
    body=[]
    for base,exponent,label in [(2,256,'Word'),(2,255,'Half'),(10,77,'DecimalShortcut'),(306,31,'SmallBaseShortcut')]:
        value=base**exponent
        text=f"  lemma {label}Bound()\n    ensures P.Power({base},{exponent})=={hex(value)}\n  {{\n    assert P.Power({base},1)=={base};\n"
        n=1
        for digit in bin(exponent)[3:]:
            text+=f"    P.PowerAdd({base},{n},{n});\n    assert P.Power({base},{2*n})=={hex(base**(2*n))};\n"
            n*=2
            if digit=='1':
                text+=f"    P.PowerAdd({base},{n},1);\n    assert P.Power({base},{n+1})=={hex(base**(n+1))};\n"
                n+=1
        text+='  }\n'
        body.append(text)
    text='// SPDX-License-Identifier: MIT\n// Generated constructive integer power bounds. Never edit directly.\ninclude "Model.dfy"\nmodule OperationsPowerBounds {\n  import K = OperationsPowerWordKernel\n  import P = OperationsCheckedPowerModel\n'+''.join(body)+'''  lemma WordDepth(n:K.Word)
    ensures K.BinaryDepth(n)<=256
  { WordBound();K.TwoPowerMeaning(256);K.DepthBound(n,256); }
  lemma ShortcutRanges(a:nat,b:nat)
    requires (a<=10 && b<=77) || (a<=306 && b<=31)
    ensures P.Power(a,b)<K.M
  {
    if a<=10 && b<=77 {
      K.PowerMonotoneBase(a,10,b);K.PowerMonotoneExponent(10,b,77);DecimalShortcutBound();
    } else {
      K.PowerMonotoneBase(a,306,b);K.PowerMonotoneExponent(306,b,31);SmallBaseShortcutBound();
    }
  }
}
'''
    (out/'Bounds.generated.dfy').write_text(text)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    generate(a.output)
