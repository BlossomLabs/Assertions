#!/usr/bin/env python3
"""Extract each exact scanName iteration branch from the pinned Collections runtime."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','descriptorOffset','descriptorLength','p','limit','q'];params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, q: Word, b: Byte';args=','.join(['data','mem','prefix',*fields,'b'])
 cases=[('End',5,0,'q >= limit'),('Digit',2,50,'q < limit && 48 <= b < 58'),('Lower',2,105,'q < limit && 97 <= b < 123'),('OtherLow',2,0,'q < limit && b < 48'),('OtherMid',2,91,'q < limit && 58 <= b < 97'),('OtherHigh',2,123,'q < limit && 123 <= b')]
 out.mkdir(parents=True,exist_ok=True)
 for name,q,byte,condition in cases:
  stack=[Expr(v,t)for v,t in zip([5704,100,5,0,5,q],fields)];states=[];required={};pc=19247
  while not states or pc not in {19247,5707}:
   op,nxt,imm=ins[pc];required.update({i:code[i]for i in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack]));assert len(states)<70
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x01:
    a,z=stack.pop(),stack.pop();texts={a.text,z.text}
    if texts=={'q','descriptorOffset'}:stack.append(Expr(a.value+z.value,'descriptorOffset+q'))
    elif texts=={'q','1'}:stack.append(Expr(q+1,'q+1'))
    else:raise ValueError((pc,texts))
   elif op==0x35:
    a=stack.pop();assert a.text=='descriptorOffset+q';stack.append(Expr(0,'DataWord(data,descriptorOffset+q)'))
   elif op==0x1a:
    a,z=stack.pop(),stack.pop();assert a.text=='0' and z.text=='DataWord(data,descriptorOffset+q)';stack.append(Expr(byte,'b'))
   elif op in {0x10,0x11}:
    a,z=stack.pop(),stack.pop();stack.append(Expr(int(a.value<z.value if op==0x10 else a.value>z.value)))
   elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
   elif op in {0x16,0x17}:
    a,z=stack.pop(),stack.pop();assert a.constant()and z.constant();stack.append(Expr(a.value&z.value if op==0x16 else a.value|z.value))
   elif op in {0x56,0x57}:
    dest=stack.pop();assert dest.constant()and dest.value in {5707,19290,19247};required[dest.value]=code[dest.value];assert code[dest.value]==0x5b
    if op==0x56 or stack.pop().value!=0:nxt=dest.value
   else:raise ValueError((pc,op))
   pc=nxt
  expected=fields[:-1]+(['q+1']if pc==19247 else ['q']);assert [x.text for x in stack]==expected
  cap=max(max(len(s['stack'])for s in states),len(expected));initial=f"Running(19247,prefix+[{','.join(fields)}],mem)";final=f"Running({pc},prefix+[{','.join(expected)}],mem)";literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)";good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()))
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact scanName {name.lower()} iteration; universal branch proof, no public retention claim.
include "../byte-machine/Scalar.dfy"
include "../byte-machine/Execution.dfy"
include "../../scans/Fetch.dfy"
module BytecodeCollectionsScanName{name} {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import F = BytecodeScanFetch
  predicate Admitted({params}) {{ descriptorOffset < 0x10000000000000000 && p <= q && limit <= descriptorLength < 0x10000000000000000 && |prefix| <= {1024-cap} && {condition} && (q >= limit || b == B.ByteWord(0,DataWord(data,descriptorOffset+q))) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{5707,19247,19290}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
  for s in states:
   i=s['id'];post=f'next == {final}'if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n"if s['op']in(96,97)else''
   step='    reveal B.Step();'if s['op']==0x1a else'    B.Delegate(code,Destinations(),state,value,data); C.Delegate(code,Destinations(),state,value,data); reveal S.Step();'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures B.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := B.Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{step}
  }}
'''
  text+='''  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires E.Trace(code,destinations,value,data,left) && E.Trace(code,destinations,value,data,right)
    requires left[|left|-1] == right[0]
    ensures E.Trace(code,destinations,value,data,left+right[1..])
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures B.Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i] && (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1); assert 0 <= j < |right|-1; assert (left+right[1..])[i] == right[j] && (left+right[1..])[i+1] == right[j+1]; }
    }
  }
'''
  joins=[]
  for start in range(0,len(states),15):
   end=min(start+15,len(states));block=start//15;post=f'state == {final}'if end==len(states)else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);\n    var next{i} := B.Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};'for i in range(start,end))
   text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
'''
   joins.append(f'    state,part := Block{block}(code,state,{args},value);\n    Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
  text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good(); var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  (out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,terminalPc=pc,scope='One exact generic name-scanner iteration branch only. Full descriptor/canonical codecs/serialization and retained public graph remain open.'),indent=2)+'\n');print(name,len(states),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
