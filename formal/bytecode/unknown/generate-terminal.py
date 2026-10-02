import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);p.add_argument('--contract');a=p.parse_args();root=a.root;out=a.output;out.mkdir(parents=True,exist_ok=True)
for name in ['Assertions','Expressions','Collections']:
 if a.contract and name!=a.contract:continue
 mapping=json.loads((root/'formal/bytecode/dispatch'/f'{name}.mapping.json').read_text());code=bytes.fromhex(json.loads((root/'artifacts/contracts'/f'{name}.sol/{name}.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==mapping['runtimeSha256']
 if a.runtime and name==a.contract:
  candidate=a.runtime.read_bytes();assert len(candidate)==len(code);code=candidate
 node=next(n for n in mapping['states'] if n['pc']==({'Assertions':265,'Expressions':66,'Collections':457}[name]) and n['stack']==['Selector(word)','0','0']);pc=node['pc'];assert code[pc] in [0xfd,0xf3]
 text=f'''// SPDX-License-Identifier: MIT
// Generated exact terminal instruction check with a fixed empty-revert oracle.
include "Bridge.dfy"
module BytecodeUnknown{name}Terminal {{
  import G = BytecodeGetterMachine
  import B = BytecodeUnknownBridge
  predicate Matches(code: seq<G.Byte>) {{ |code| == {len(code)} && code[{pc}] == {code[pc]} }}
  lemma End(code: seq<G.Byte>, word: G.Word, value: G.Word, size: G.Word)
    requires Matches(code)
    ensures G.Step(code,{{}},G.Running({pc},[G.Selector(word),0,0],B.Memory(true)),value,size,word) == G.Reverted([])
  {{ reveal G.Step(); }}
}}
'''
 (out/f'{name}Terminal.generated.dfy').write_text(text)

import subprocess,sys
subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',out,'--include-root',HERE],check=True)
