#!/usr/bin/env python3
"""Extract the exact arbitrary descriptor shape-to-typeShape call frame."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','descriptorOffset','descriptorLength'];stack=fields.copy();pc=9893;states=[];required={}
 while pc!=13839:
  op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=stack.copy()));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<30
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:stack.append(str(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x56:dest=stack.pop();assert dest=='13839';nxt=13839;required[nxt]=code[nxt];assert code[nxt]==0x5b
  else:raise ValueError((pc,op))
  pc=nxt
 expected=fields+['0','0','0','9908','descriptorOffset','descriptorLength','0','descriptorLength'];assert stack==expected,stack
 params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength';cap=max(max(len(s['stack'])for s in states),len(expected));initial=f"Running(9893,prefix+[{','.join(fields)}],mem)";final=f"Running(13839,prefix+[{','.join(expected)}],mem)";literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)";matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()));good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated exact arbitrary descriptor shape-to-typeShape call frame; no public claim.
include "../../scans/Execution.dfy"
module BytecodeCollectionsShapeTypeCall {{
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{13839}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ |prefix| <= {1024-cap} && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}'if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n"if s['op']in(96,97)else''
  text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches();reveal Good();assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});reveal Step();
  }}
'''
 calls='\n'.join(f'    Advance{i}(code,state,{args},value);\n    var next{i} := Step(code,Destinations(),state,value,data);E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};'for i in range(len(states)))
 text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && |prefix| <= {1024-cap}
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial};trace := [state];reveal Good();
{calls}
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Call.generated.dfy').write_text(text);(out/'Call.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,terminalPc=13839,expectedStack=expected,scope='Exact descriptor shape-to-typeShape call frame only; full parser/codec/retained public evidence remains open.'),indent=2)+'\n');print(len(states),'actual shape-to-typeShape call instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
