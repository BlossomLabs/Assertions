#!/usr/bin/env python3
"""Exact current sum scalar return stack, physical stores and RETURN."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91};s=[(3904669827,'3904669827'),(23,'total')];pc=604;mem='Store([],64,128)';states=[];required={};targets=set();seen=set()
 while True:
  assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
  for p in range(pc,nxt):required[p]=code[p]
  states.append({'id':len(states),'pc':pc,'stack':[x[1] for x in s],'memory':mem,'op':op,'next':nxt,'immediate':imm})
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:s.append((imm,str(imm)))
  elif 0x80<=op<=0x8f:s.append(s[-(op-0x7f)])
  elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
  elif op==0x50:s.pop()
  elif op==0x51:
   a=s.pop();assert a== (64,'64');s.append((128,'128'))
  elif op==0x52:
   offset,value=s.pop(),s.pop();assert offset==(128,'128') and value[1]=='total';mem='Store(Store([],64,128),128,total)'
  elif op in [1,3]:
   a,b=s.pop(),s.pop();assert a[1].isdecimal() and b[1].isdecimal();v=a[0]+b[0] if op==1 else a[0]-b[0];assert v>=0;s.append((v,str(v)))
  elif op==0x56:
   dest=s.pop();assert dest[1].isdecimal() and dest[0] in dests;targets.add(dest[0]);required[dest[0]]=code[dest[0]];nxt=dest[0]
  elif op==0xf3:
   assert s.pop()==(128,'128') and s.pop()==(32,'32');break
  else:raise ValueError((pc,op))
  pc=nxt
 matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));cap=max(len(n['stack']) for n in states)
 good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for n in states)+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated physical scalar-return instructions from the pinned current runtime.
include "../scans/Execution.dfy"
module BytecodeIndexReturn {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import R = BytecodeScanRepresentation
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, total: Word) {{
{good}
  }}
'''
 for n in states:
  i=n['id'];post='next == Returned(G.Encode(total,32))' if i==len(states)-1 else f'Good({i+1},next,total)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
  text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, total: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,total)
    ensures state.Running? && |state.stack| <= {cap} && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    assert |Store([],64,128)| == 96;
    R.StoredWord(Store([],64,128),128,total);
    R.StoredFrame(Store([],64,128),128,total,64);
    assert |Store(Store([],64,128),128,total)| == 160;
    assert state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
 calls='\n'.join(f'    Advance{i}(code,state,total,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(states)))
 text+=f'''  lemma Start(total: Word)
    ensures Good(0,Running(604,[3904669827,total],Store([],64,128)),total)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, total: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code)
    ensures state == Returned(G.Encode(total,32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(604,[3904669827,total],Store([],64,128)) && trace[|trace|-1] == state
  {{
    Start(total);
    state := Running(604,[3904669827,total],Store([],64,128));
    trace := [state];
{calls}
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Return.generated.dfy').write_text(text);(out/'Return.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'maximumStackWords':cap,'scope':'development exact physical scalar return; complete entry connection and retained evidence remain open'},indent=2)+'\n');print('Return',len(states),'actual physical return states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
