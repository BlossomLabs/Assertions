#!/usr/bin/env python3
"""Extract every generic unsigned exponent loop branch; native proofs required."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
MOD=1<<256
CASES={
 'Initial':(20932,20936,2,3,1,3,'true',['21132',str(MOD-1),'b','original']),
 'Exit':(20936,21132,1,3,1,3,'b==1',['21132',str(MOD-1),'b','original','acc','a']),
 'Even':(20936,20936,2,3,1,3,'b>1 && b%2==0 && a>=2 && 1<=acc<a && a*a<Modulus()',['21132',str(MOD-1),'b','original','acc','a']),
 'Odd':(20936,20936,3,3,1,3,'b>1 && b%2==1 && a>=2 && 1<=acc<a && a*a<Modulus()',['21132',str(MOD-1),'b','original','acc','a']),
 'Overflow':(20936,None,2,MOD//2,1,3,'b>1 && a>=2 && 1<=acc<a && a*a>=Modulus()',['21132',str(MOD-1),'b','original','acc','a']),
}
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['exp(uint256,uint256)']=='f5f565f8'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+w+1,int.from_bytes(code[pc+1:pc+w+1],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True)
 for label,(start,stop,b,a,acc,original,guard,tail) in CASES.items():
  values=dict(b=b,a=a,acc=acc,original=original);expr=tail.copy();stack=[values[x] if x in values else int(x) for x in tail];pc=start;nodes=[];seen=set();needed={stop:code[stop]} if stop is not None else {};destinations={stop} if stop is not None else set();memory='Store([],64,128)'
  def pop():return stack.pop(),expr.pop()
  def push(value,text=None):stack.append(value);expr.append(str(value) if text is None else text)
  while True:
   assert (pc,tuple(stack)) not in seen;seen.add((pc,tuple(stack)));op,nxt,imm=ins[pc];needed.update({i:code[i] for i in range(pc,nxt)});n=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy(),memory=memory);nodes.append(n)
   if op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;assert k<=len(stack);push(stack[-k],expr[-k])
   elif 144<=op<=159:
    k=op-143;assert k<len(stack);stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,t=pop();push(int(v==0),f'(if {t}==0 then 1 else 0)')
   elif op in [0x02,0x04,0x11,0x16,0x1b,0x1c]:
    x,xe=pop();y,ye=pop();vs={2:lambda:x*y%MOD,4:lambda:0 if y==0 else x//y,17:lambda:int(x>y),22:lambda:x&y,27:lambda:0 if x>=256 else (y<<x)%MOD,28:lambda:0 if x>=256 else y>>x};ts={2:f'Product({xe},{ye})',4:f'(if {ye}==0 then 0 else {xe}/{ye})',17:f'(if {xe}>{ye} then 1 else 0)',22:f'BitAnd({xe},{ye})',27:f'Shift({ye},{xe})',28:'(b as nat)/2'}
    if op==0x1c:assert (xe,ye)==('1','b')
    push(vs[op](),ts[op])
   elif op==0x52:
    at,ate=pop();v,ve=pop();assert at in [0,4];memory=f'Store({memory},{ate},{ve})'
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    target,te=pop();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;needed[target]=code[target];destinations.add(target);n['jump']=target
    if take:nxt=target
   elif op==0xfd:
    at,ate=pop();count,ce=pop();assert (at,count)==(0,36) and label=='Overflow';n['revert']=True;break
   else:raise ValueError((pc,hex(op)))
   pc=nxt
   if pc==stop:break
  module='OperationsPowerUnsignedLoop'+label;constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(needed.items()));good='\n'.join(('    if' if i==0 else '    else if')+f' id=={i} then state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for i,n in enumerate(nodes))+'\n    else false';params='code:seq<Byte>,destinations:set<nat>,state:State,prefix:seq<Word>,a:Word,b:Word,acc:Word,original:Word,value:Word,size:Word,word:Word,headA:Word,headB:Word';passed='code,destinations,state,prefix,a,b,acc,original,value,size,word,headA,headB';result='Reverted(Panic(17))' if label=='Overflow' else f'Running({stop},prefix+[{",".join(expr)}],Store([],64,128))'
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual generic unsigned exponent loop branch. Never edit directly.
include "../power-halving-kernel/Halving.dfy"
include "../power-unsigned-loop-kernel/Model.dfy"
module {module} {{
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import H = OperationsPowerHalving
  import K = OperationsPowerUnsignedLoopKernel
  predicate Admitted(prefix:seq<Word>,a:Word,b:Word,acc:Word,original:Word) {{ |prefix|<=997 && ({guard}) }}
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,sorted(destinations)))}}} }}
  opaque predicate Good(id:nat,state:State,prefix:seq<Word>,a:Word,b:Word,acc:Word,original:Word) {{
{good}
  }}
'''
  for n in nodes:
   i=n['id'];post='next=='+result if i+1==len(nodes) else f'Good({i+1},next,prefix,a,b,acc,original)';guide=f'    reveal Matches(); reveal Good();\n    assert state==Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]});\n    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n    E.Ordinary(code,destinations,state,value,size,word,headA,headB); reveal Step();\n'
   if label in ['Even','Odd','Overflow']:guide+='    K.QuotientProduct(a,a); H.Halve(b);\n'
   if n['opcode']==0x02:guide+='    K.WordProducts(a,acc);\n'
   if n['opcode']==0x1b:guide+='    PanicShift();\n'
   if n.get('revert'):guide+='    PanicStores(Store([],64,128),17);\n'
   if n.get('jump'):guide+=f'    assert {n["jump"]} in destinations && code[{n["jump"]}]==0x5b;\n'
   text+=f'''  lemma Advance{i}({params})
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,a,b,acc,original) && Good({i},state,prefix,a,b,acc,original)
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
    requires Matches(code) && Destinations()<=destinations && Admitted(prefix,a,b,acc,original)
    ensures state=={result}
    ensures |trace|=={len(nodes)+1} && trace[0]==Running({start},prefix+[{','.join(tail)}],Store([],64,128)) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,headA,headB)
  {{
    reveal Good();state:=Running({start},prefix+[{','.join(tail)}],Store([],64,128));trace:=[state];
    assert Good(0,state,prefix,a,b,acc,original);
'''
  for i in range(len(nodes)):text+=f'    Advance{i}({passed});Extend(code,destinations,trace,state,value,size,word,headA,headB);state:=E.Execute(code,destinations,state,value,size,word,headA,headB);trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==Running({start},prefix+[{",".join(tail)}],Store([],64,128));assert trace[|trace|-1]==state;\n'
  text+='  }\n}\n';(out/(label+'.generated.dfy')).write_text(text);(out/(label+'.mapping.json')).write_text(json.dumps(dict(label=label,runtimeSha256=hashlib.sha256(code).hexdigest(),startPc=start,stopPc=stop,inputTail=tail,outputTail=expr,states=nodes,requiredBytes=needed,scope='Unverified actual loop branch; raw/shortcut/final product/physical return remains open'),indent=2)+'\n');print(label,len(nodes),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
