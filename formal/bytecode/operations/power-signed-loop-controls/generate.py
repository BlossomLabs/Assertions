#!/usr/bin/env python3
"""Complete compiled signed-power loop segments, without skipping the callee.

Helper invocation stops at its actual entry; the separate complete checked
multiply certificate must discharge that call before loop composition.
"""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
CASES={
 'Initial':(3247,3250,2,['a','b'],'true'),
 'Exit':(3250,2984,0,['a','b','c'],'b==0'),
 'Even':(3250,3278,2,['a','b','c'],'b>0 && b%2==0'),
 'OddInvoke':(3250,20145,3,['a','b','c'],'b%2==1'),
 'AccumulatorReturn':(3275,3278,3,['a','b','c','r'],'true'),
 'LastHalf':(3278,3250,1,['a','b','c'],'b==1'),
 'SquareInvoke':(3278,20145,2,['a','b','c'],'b>=2'),
 'SquareReturn':(3301,3250,1,['a','b','c','r'],'true'),
}
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['exp(int256,uint256)']=='185af0ad'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+w+1,int.from_bytes(code[pc+1:pc+w+1],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True)
 for label,(start,stop,seed,tail,guard) in CASES.items():
  values={'a':3,'b':seed,'c':11,'r':33};stack=[values[x] for x in tail];expr=tail.copy();pc=start;nodes=[];seen=set();needed={stop:code[stop]};destinations={stop}
  assert ins[stop][0]==0x5b
  def pop():return stack.pop(),expr.pop()
  def push(value,text=None):stack.append(value);expr.append(str(value) if text is None else text)
  while pc!=stop:
   assert (pc,tuple(stack)) not in seen;seen.add((pc,tuple(stack)));op,nxt,imm=ins[pc];needed.update({i:code[i] for i in range(pc,nxt)});n=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy());nodes.append(n)
   if op==0x5f or 96<=op<=99:push(imm)
   elif 128<=op<=143:
    k=op-127;assert k<=len(stack);push(stack[-k],expr[-k])
   elif 144<=op<=159:
    k=op-143;assert k<len(stack);stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    value,text=pop();push(int(value==0),f'(if {text}==0 then 1 else 0)')
   elif op==0x16:
    a,ae=pop();b,be=pop();push(a&b,f'BitAnd({ae},{be})')
   elif op==0x1c:
    amount,ae=pop();value,ve=pop();assert (ae,ve)==('1','b');push(value//2,'(b as nat)/2')
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    target,te=pop();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;needed[target]=code[target];destinations.add(target);n['jump']=target
    if take:nxt=target
   else:raise ValueError((pc,hex(op)))
   pc=nxt
  module='OperationsPowerSignedLoop'+label;constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(needed.items()));memory='Store([],64,128)'
  good='\n'.join(('    if' if i==0 else '    else if')+f' id=={i} then state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{memory})' for i,n in enumerate(nodes))+'\n    else false'
  params='code:seq<Byte>,destinations:set<nat>,state:State,prefix:seq<Word>,a:Word,b:Word,c:Word,r:Word,value:Word,size:Word,word:Word,headA:Word,headB:Word';passed='code,destinations,state,prefix,a,b,c,r,value,size,word,headA,headB';result=f'Running({stop},prefix+[{",".join(expr)}],{memory})'
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete actual loop segment. Never edit directly.
include "../power-halving-kernel/Halving.dfy"
module {module} {{
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import H = OperationsPowerHalving
  predicate Admitted(prefix:seq<Word>,a:Word,b:Word,c:Word,r:Word) {{ |prefix|<=997 && ({guard}) }}
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,sorted(destinations)))}}} }}
  opaque predicate Good(id:nat,state:State,prefix:seq<Word>,a:Word,b:Word,c:Word,r:Word) {{
{good}
  }}
'''
  for n in nodes:
   i=n['id'];post=result if i+1==len(nodes) else f'Good({i+1},next,prefix,a,b,c,r)';post='next=='+post if i+1==len(nodes) else post
   guide=f'    reveal Matches(); reveal Good();\n    assert state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{memory});\n    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n    E.Ordinary(code,destinations,state,value,size,word,headA,headB); reveal Step();\n'
   if n['opcode'] in [0x16,0x1c,0x57]:guide+='    H.Halve(b);\n'
   if n.get('jump'):guide+=f'    assert {n["jump"]} in destinations && code[{n["jump"]}]==0x5b;\n'
   text+=f'''  lemma Advance{i}({params})
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,a,b,c,r) && Good({i},state,prefix,a,b,c,r)
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
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,a,b,c,r)
    ensures state=={result}
    ensures |trace|=={len(nodes)+1} && trace[0]==Running({start},prefix+[{','.join(tail)}],{memory}) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {{
    reveal Good(); state:=Running({start},prefix+[{','.join(tail)}],{memory});trace:=[state];
    assert Good(0,state,prefix,a,b,c,r);
'''
  for i in range(len(nodes)):text+=f'    Advance{i}({passed});Extend(code,destinations,trace,state,value,size,word,headA,headB);state:=E.Execute(code,destinations,state,value,size,word,headA,headB);trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==Running({start},prefix+[{",".join(tail)}],{memory});assert trace[|trace|-1]==state;\n'
  text+='  }\n}\n';(out/(label+'.generated.dfy')).write_text(text);(out/(label+'.mapping.json')).write_text(json.dumps(dict(label=label,runtimeSha256=hashlib.sha256(code).hexdigest(),startPc=start,stopPc=stop,inputTail=tail,outputTail=expr,requiredBytes=needed,states=nodes,scope='Complete unverified segment; checked multiplication helper and complete raw/loop/return composition remain open'),indent=2)+'\n');print(label,len(nodes),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
