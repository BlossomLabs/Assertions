#!/usr/bin/env python3
"""Exact physical PC-zero route to the iotaWords wrapper under loaded selector admission."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91};pc=0;s=[];mem='[]';states=[];required={};targets=set();seen=set()
 while pc!=789:
  assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
  for p in range(pc,nxt):required[p]=code[p]
  states.append({'id':len(states),'pc':pc,'stack':[x[1] for x in s],'memory':mem,'op':op,'next':nxt,'immediate':imm})
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:s.append((imm,str(imm)))
  elif 0x80<=op<=0x8f:s.append(s[-(op-0x7f)])
  elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
  elif op==0x50:s.pop()
  elif op==0x34:s.append((0,'value'))
  elif op==0x36:s.append((100,'|data|'))
  elif op==0x35:assert s.pop()==(0,'0');s.append((2368205965<<224,'DataWord(data,0)'))
  elif op==0x1c:
   amount,word=s.pop(),s.pop();assert amount==(224,'224') and word[1]=='DataWord(data,0)';s.append((2368205965,'2368205965'))
  elif op==0x15:x=s.pop();s.append((int(x[0]==0),str(int(x[0]==0))))
  elif op in [0x10,0x11,0x14]:
   a,b=s.pop(),s.pop();v=int(a[0]<b[0] if op==0x10 else a[0]>b[0] if op==0x11 else a[0]==b[0]);s.append((v,str(v)))
  elif op==0x52:assert s.pop()==(64,'64') and s.pop()==(128,'128');mem='Store([],64,128)'
  elif op==0x57:
   dest,truth=s.pop(),s.pop();assert dest[1].isdecimal() and dest[0] in dests;targets.add(dest[0]);required[dest[0]]=code[dest[0]]
   if truth[0]:nxt=dest[0]
  elif op==0x56:
   dest=s.pop();assert dest[1].isdecimal() and dest[0] in dests;targets.add(dest[0]);required[dest[0]]=code[dest[0]];nxt=dest[0]
  else:raise ValueError((pc,op))
  pc=nxt
 assert s==[(2368205965,'2368205965')]
 matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));cap=max(len(n['stack']) for n in states)
 good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for n in states)+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated current runtime instructions from PC zero to the iotaWords wrapper.
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
module BytecodeIotaPrefix {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  opaque predicate SelectorAdmitted(data: seq<Byte>) {{ ShiftRight(DataWord(data,0),224) == 2368205965 }}
  predicate Admitted(value: Word, data: seq<Byte>) {{ value == 0 && 4 <= |data| < 0x10000000000000000 && SelectorAdmitted(data) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, value: Word, data: seq<Byte>) {{ Admitted(value,data) && (
{good}) }}
'''
 for n in states:
  i=n['id'];post='next == Running(789,[2368205965],Store([],64,128))' if i==len(states)-1 else f'Good({i+1},next,value,data)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
  if n['op']==0x1c:fetch+='    reveal SelectorAdmitted();\n'
  if n['op']==0x63:fetch=f"    P.Push4(code,{n['pc']});\n"
  text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,value,data)
    ensures state.Running? && |state.stack| <= {cap} && |state.memory| <= 96
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
 # PUSH4 recursive Decode needs explicit full unrolling via native helper.
 text=text.replace('  import E = BytecodeScanExecution\n','  import E = BytecodeScanExecution\n  import G = BytecodeGetterMachine\n')
 calls='\n'.join(f'    Advance{i}(code,state,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running(0,[],[]);\n    state := next{i};' for i in range(len(states)))
 text+=f'''  lemma Start(value: Word, data: seq<Byte>)
    requires Admitted(value,data)
    ensures Good(0,Running(0,[],[]),value,data)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(value,data)
    ensures state == Running(789,[2368205965],Store([],64,128))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {{
    Start(value,data);
    state := Running(0,[],[]);
    trace := [state];
{calls}
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Prefix.generated.dfy').write_text(text);(out/'Prefix.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'maximumStackWords':cap,'scope':'development exact admitted physical prefix only; representation selector and complete public retention remain separate'},indent=2)+'\n');print('Prefix',len(states),'actual physical routing states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
