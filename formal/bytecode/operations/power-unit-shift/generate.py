#!/usr/bin/env python3
"""Construct all256 exact unit-word SHL connections and finite range composition."""
import argparse
from pathlib import Path
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 text='// SPDX-License-Identifier: MIT\n// Generated constructive finite SHL basis. Never edit directly.\ninclude "../power-opcode-kernel/Execution.dfy"\nmodule OperationsPowerUnitShift {\n  import M = OperationsSignedMultiplyMachine\n  import C = OperationsSignedMultiplyWordConversion\n  import K = OperationsPowerWordKernel\n'
 for j in range(256):
  text+=f'  lemma Power{j}()\n    ensures K.TwoPower({j})=={1<<j}\n  {{'+(f'Power{j-1}();assert K.TwoPower({j})==2*K.TwoPower({j-1});' if j else '')+'}\n'
  text+=f"""  lemma {{:autoRevealDependencies false}} Shift{j}(amount:M.Word)
    requires amount=={j}
    ensures M.Shift(1,amount)==K.TwoPower({j})
  {{
    var input:bv256:=1;var output:bv256:=0x{1<<j:x};
    C.Inverse256(input);C.Inverse256(output);
    assert input<<{j}==output;
    assert (input as nat)==1 && (output as nat)=={1<<j};
    M.ShiftBridgeAt(1,amount,{j},input,{1<<j});Power{j}();
  }}
"""
 for lo in range(0,256,16):
  hi=lo+16;text+=f'  lemma Block{lo//16}(amount:M.Word)\n    requires {lo}<=amount<{hi}\n    ensures M.Shift(1,amount)==K.TwoPower(amount)\n  {{\n'
  for j in range(lo,hi-1):text+=f'    '+('if' if j==lo else 'else if')+f' amount=={j} {{ Shift{j}(amount); }}\n'
  text+=f'    else {{ assert amount=={hi-1};Shift{hi-1}(amount); }}\n  }}\n'
 text+='  lemma Unit(amount:M.Word)\n    ensures M.Shift(1,amount)==(if amount<256 then K.TwoPower(amount) else 0)\n  {\n    if amount>=256 { M.ShiftDefinition(1,amount); }\n'
 for lo in range(0,256,16):text+=f'    else if amount<{lo+16} {{ Block{lo//16}(amount); }}\n'
 text+='  }\n}\n';(out/'Shift.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
