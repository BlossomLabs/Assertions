#!/usr/bin/env python3
"""Extract the exact nonunderflowing shared Collections checked-subtract routine."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','right','left'];stack=fields.copy();pc=23784;states=[];required={}
 while pc!='returnPc':
  op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=stack.copy()));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<30
  if op==0x5b:pass
  elif 96<=op<=127:stack.append(str(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==3:a,z=stack.pop(),stack.pop();assert a=='left'and z=='right';stack.append('left-right')
  elif op==0x11:a,z=stack.pop(),stack.pop();assert a=='left-right'and z=='left';stack.append('0')
  elif op==0x15:a=stack.pop();assert a=='0';stack.append('1')
  elif op==0x57:dest=stack.pop();condition=stack.pop();assert dest=='13698'and condition=='1';nxt=13698;required[nxt]=code[nxt];assert code[nxt]==91
  elif op==0x56:dest=stack.pop();assert dest=='returnPc';nxt='returnPc'
  else:raise ValueError((pc,op))
  pc=nxt
 assert stack==['left-right'];cap=max(max(len(s['stack'])for s in states),1);params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, left: Word, right: Word';args='data,mem,prefix,returnPc,left,right';initial='Running(23784,prefix+[returnPc,right,left],mem)';final='Running(returnPc,prefix+[left-right],mem)';literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)";matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()));good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated exact nonunderflowing checked subtraction with arbitrary lower frame and return JUMPDEST.
include "../../scans/Execution.dfy"
module BytecodeCollectionsCheckedSubtract {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  predicate Admitted(code: seq<Byte>,{params}) {{ |prefix| <= {1024-cap} && returnPc < |code| && code[returnPc] == 0x5b && right <= left }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(returnPc: Word): set<nat> {{ {{13698,returnPc}} }}
  opaque predicate Good(id: nat,state: State,code: seq<Byte>,{params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}'if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n"if s['op']in(96,97)else''
  text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := Step(code,Destinations(returnPc),state,value,data); {post}
  {{ reveal Matches();reveal Good();assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});reveal Step();
  }}
'''
 calls='\n'.join(f'    Advance{i}(code,state,{args},value);var next{i} := Step(code,Destinations(returnPc),state,value,data);E.Extend(code,Destinations(returnPc),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};'for i in range(len(states)))
 text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {final} && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial};trace := [state];reveal Good();
{calls}
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Subtract.generated.dfy').write_text(text);(out/'Subtract.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,terminalPc='returnPc',expectedStack=['left-right'],scope='Actual nonunderflowing checked subtraction routine only, with generic valid return destination. Underflow/panic and complete parser/codec/public retention remain open.'),indent=2)+'\n');print(len(states),'actual checked-subtract instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
