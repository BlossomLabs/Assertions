#!/usr/bin/env python3
"""Actual iota panic-17 and panic-41 physical error traces."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 specs=[
 ('Panic17',23542,'prefix: seq<Word>','|prefix| <= 1000',[],'prefix+',0,0x4e487b71,'17'),
 ('Panic41',23354,'prefix: seq<Word>','|prefix| <= 1000',[],'prefix+',0,0x4e487b71,'65')]

 for name,entry,params,pre,initial,prefix,off,selector,arg in specs:
  actual=','.join(x.strip().split(':')[0] for x in params.split(','));s=initial.copy();pc=entry;mem='Store([],64,128)';states=[];required={};targets=set();seen=set();header=selector<<224
  while True:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'memory':mem,'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:s.append(E(imm))
   elif 0x80<=op<=0x8f:s.append(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:s.pop()
   elif op==0x15:s.append(E(int(s.pop().v==0)))
   elif op==0x11:a,b=s.pop(),s.pop();s.append(E(int(a.v>b.v)))
   elif op in [0x01,0x03]:
    a,b=s.pop(),s.pop();v=(a.v+b.v)%MOD if op==1 else (a.v-b.v)%MOD
    if a.constant() and b.constant():s.append(E(v))
    else:
     assert op==1;s.append(E(v,f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'))
   elif op==0x1b:amount,value=s.pop(),s.pop();assert amount.constant() and value.constant();s.append(E((value.v<<amount.v)%MOD))
   elif op==0x51:assert s.pop().v==64;s.append(E(128))
   elif op==0x52:
    offset,value=s.pop(),s.pop();assert offset.constant();mem=f'Store({mem},{offset.t},{value.t})'
   elif op==0x57:
    dest,truth=s.pop(),s.pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=s.pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   elif op==0xfd:
    offset,size=s.pop(),s.pop();assert offset.v==off and size.v==36;break
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));stackcap=1020 if prefix else max(len(n['stack']) for n in states);memorycap=96 if prefix else 192
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},{prefix}[{','.join(n['stack'])}],{n['memory']})" for n in states)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated reached exact error instructions; native proof pins error bytes.
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
include "../scans/ErrorBytes.dfy"
include "../scans/Scalar.dfy"
module BytecodeIota{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}) {{ Admitted({actual}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == Reverted(G.Encode({selector},4)+G.Encode({arg},32))' if i==len(states)-1 else f'Good({i+1},next,{actual})';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else f"    P.Push4(code,{n['pc']});\n" if n['op']==99 else ''
   extra='    SC.ErrorSelectors();\n' if n['op']==0x1b else ''
   if name=='Unaligned' and n['op']==0x51 and n['memory']!='Store([],64,128)':
    extra+=f'    R.StoredFrame(Store([],64,128),128,{header},64);\n    R.StoredFrame(Store(Store([],64,128),128,{header}),132,length,64);\n'
   support='    R.StoredWord([],64,128);\n    assert |Store([],64,128)| == 96;\n'
   if n['memory']!='Store([],64,128)' or n['op']==0x52:
    support+=f'    R.StoredWord(Store([],64,128),{off},{header});\n'
   if n['memory'].count('Store(')>=3 or (n['op']==0x52 and states[i+1]['memory'].count('Store(')>=3):
    support+=f'    R.StoredWord(Store(Store([],64,128),{off},{header}),{off+4},{arg});\n'
   if n['op']==0xfd:
    support+=f'    ER.PhysicalError(Store([],64,128),{off},{selector},{header},{arg});\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && Good({i},state,{actual})
    ensures state.Running? && |state.stack| <= {stackcap} && |state.memory| <= {memorycap}
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{support}{extra}    assert state == Running({n['pc']},{prefix}[{','.join(n['stack'])}],{n['memory']});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  first=prefix+'['+','.join(x.t for x in initial)+']';calls='\n'.join(f'    Advance{i}(code,state,{actual},value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start({params})
    requires Admitted({actual})
    ensures Good(0,Running({entry},{first},Store([],64,128)),{actual})
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual})
    ensures state == Reverted(G.Encode({selector},4)+G.Encode({arg},32))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},{first},Store([],64,128)) && trace[|trace|-1] == state
  {{
    Start({actual});
    state := Running({entry},{first},Store([],64,128));
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'scope':'development exact reached physical error; full raw admission/entry composition/retention remains separate'},indent=2)+'\n');print(name,len(states),'physical error states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
