#!/usr/bin/env python3
"""Generate exact reached unknown-selector terminal with fixed revert oracle."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args()
mapping=json.loads((HERE/'Operations.mapping.json').read_text());baseline=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(baseline).hexdigest()==mapping['runtimeSha256']
terminals=sorted({n['pc'] for n in mapping['states'] if n.get('terminal')=='rejected' and n['stack']==['Selector(word)','0','0']});assert len(terminals)==16
code=a.runtime.read_bytes() if a.runtime else baseline;assert len(code)==len(baseline) and all(code[pc] in [0xfd,0xf3] for pc in terminals)
clauses=' && '.join(f'code[{pc}] == {code[pc]}' for pc in terminals)
text=f'''// SPDX-License-Identifier: MIT
// Generated exact reached unknown-selector terminals, fixed empty-revert oracle.
include "Bridge.dfy"
module OperationsRawUnknownTerminal {{
  import G = OperationsRawDispatchPhysical
  import B = OperationsRawDispatchBridge
  predicate Matches(code: seq<G.Byte>) {{ |code| == {len(code)} && {clauses} }}
'''
for pc in terminals:
 text+=f'''  lemma End{pc}(code: seq<G.Byte>,word: G.Word,value: G.Word,size: G.Word)
    requires Matches(code)
    ensures G.Step(code,{{}},G.Running({pc},[G.Selector(word),0,0],B.Memory(true)),value,size,word) == G.Reverted([])
  {{ reveal G.Step(); }}
'''
text+='}\n'
a.output.mkdir(parents=True,exist_ok=True);(a.output/'OperationsTerminal.generated.dfy').write_text(text)
subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
