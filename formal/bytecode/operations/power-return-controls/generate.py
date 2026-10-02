#!/usr/bin/env python3
"""Retain complete actual integer-power scalar return and signed cleanup."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
CASES={'Unsigned':(1329,['result']),'Signed':(2984,['1329','a','b','result'])}
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+w+1,int.from_bytes(code[pc+1:pc+w+1],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True)
 for label,(start,tail) in CASES.items():
  vals={'a':3,'b':0,'result':42};expr=tail.copy();stack=[vals[x] if x in vals else int(x) for x in expr];nodes=[];needed={};dests=set();pc=start;mem='L.Heap()'
  def pop():return stack.pop(),expr.pop()
  def push(v,t=None):stack.append(v);expr.append(str(v) if t is None else t)
  while True:
   op,nxt,imm=ins[pc];needed.update({i:code[i] for i in range(pc,nxt)});n=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy(),memory=mem);nodes.append(n)
   if op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;assert k<=len(stack);push(stack[-k],expr[-k])
   elif 144<=op<=159:k=op-143;assert k<len(stack);stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op in [1,3]:
    x,xe=pop();y,ye=pop();assert xe.isdecimal() and ye.isdecimal();push((x+y)%(1<<256) if op==1 else (x-y)%(1<<256))
   elif op==0x51:at,ate=pop();assert at==64;push(128)
   elif op==0x52:at,ate=pop();v,ve=pop();assert (at,ve)==(128,'result');mem='L.Packet(result)'
   elif op==0x5b:pass
   elif op==0x56:target,te=pop();assert ins[target][0]==0x5b;needed[target]=code[target];dests.add(target);n['jump']=target;nxt=target
   elif op==0xf3:at,ate=pop();count,ce=pop();assert (at,count)==(128,32);break
   else:raise ValueError((pc,hex(op)))
   pc=nxt
  module='OperationsPowerReturn'+label;good='\n'.join(('    if' if i==0 else '    else if')+f' id=={i} then state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for i,n in enumerate(nodes))+'\n    else false';constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(needed.items()));params='code:seq<Byte>,destinations:set<nat>,state:State,prefix:seq<Word>,a:Word,b:Word,result:Word,value:Word,size:Word,word:Word,headA:Word,headB:Word';passed='code,destinations,state,prefix,a,b,result,value,size,word,headA,headB'
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete actual scalar return. Never edit directly.
include "Memory.dfy"
module {module} {{
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import L = OperationsPowerReturnMemory
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  opaque predicate Good(id:nat,state:State,prefix:seq<Word>,a:Word,b:Word,result:Word) {{
{good}
  }}
'''
  for n in nodes:
   i=n['id'];post='next==Returned(Encode(result,32))' if i+1==len(nodes) else f'Good({i+1},next,prefix,a,b,result)';guide=f'    reveal Matches();reveal Good();L.Layout(result);\n    assert state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]});\n    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n    E.Ordinary(code,destinations,state,value,size,word,headA,headB);reveal Step();\n'
   if n.get('jump'):guide+=f'    assert {n["jump"]} in destinations && code[{n["jump"]}]==0x5b;\n'
   text+=f'''  lemma Advance{i}({params})
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997 && Good({i},state,prefix,a,b,result)
    ensures state.Running? && |state.stack|<=1024
    ensures var next:=E.Execute(code,destinations,state,value,size,word,headA,headB); {post}
  {{
{guide}  }}
'''
  text+='''  lemma Extend(code:seq<Byte>,destinations:set<nat>,trace:seq<State>,state:State,value:Word,size:Word,word:Word,headA:Word,headB:Word)
    requires |trace|>0 && trace[|trace|-1]==state
    requires forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
    ensures forall j:nat :: j+1<|trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)]| ==>
      (trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j],value,size,word,headA,headB)
  {
    forall j:nat | j+1<|trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)]|
      ensures (trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,headA,headB)])[j],value,size,word,headA,headB)
    { if j+1<|trace| {} else { assert j+1==|trace|; assert trace[j]==state; } }
  }
'''
  text+=f'''  ghost method Run({params.replace('state:State,','')}) returns(state:State,trace:seq<State>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=997
    ensures state==Returned(Encode(result,32))
    ensures |trace|=={len(nodes)+1} && trace[0]==Running({start},prefix+[{','.join(tail)}],L.Heap()) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {{
    reveal Good();state:=Running({start},prefix+[{','.join(tail)}],L.Heap());trace:=[state];assert Good(0,state,prefix,a,b,result);
'''
  for i in range(len(nodes)):text+=f'    Advance{i}({passed});Extend(code,destinations,trace,state,value,size,word,headA,headB);state:=E.Execute(code,destinations,state,value,size,word,headA,headB);trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==Running({start},prefix+[{",".join(tail)}],L.Heap());assert trace[|trace|-1]==state;\n'
  text+='  }\n}\n';(out/(label+'.generated.dfy')).write_text(text);(out/(label+'.mapping.json')).write_text(json.dumps(dict(label=label,startPc=start,states=nodes,runtimeSha256=hashlib.sha256(code).hexdigest(),scope='Complete generated physical scalar return; native verification and public retention pending'),indent=2)+'\n');print(label,len(nodes),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
