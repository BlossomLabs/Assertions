#!/usr/bin/env python3
"""Actual controls surrounding the callback packing helper; observed GAS separate."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])']=='ed6dc3be' and pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])']=='7787eb48'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 destinations={x for x,(op,_,_) in ins.items() if op==0x5b}
 common=[Expr(12484),Expr(18176,'target'),Expr(192,'ptr'),Expr(0,'index'),Expr(0),Expr(9971805,'gasBefore')]
 for name,entry,stop,initialStack,expected in [
  ('Before',16909,24276,[Expr(12484),Expr(18176,'target'),Expr(192,'ptr'),Expr(0,'index'),Expr(0),Expr(0),Expr(9971805,'gasBefore')],['12484','target','ptr','index','0','gasBefore','0','0','target','16936','ptr','free']),
  ('After',16936,16946,common+[Expr(0),Expr(0),Expr(18176,'target'),Expr(288,'free+length')],['12484','target','ptr','index','0','gasBefore','0','0','target','free+length','0','free','length','free','target'])]:
  stack=initialStack[:];startTexts=[x.text for x in stack];pc=entry;states=[];required={stop:code[stop]};targets={stop}
  while pc!=stop:
   op,nxt,imm=ins[pc];required.update({x:code[x] for x in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack]));assert len(states)<100
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x51:a=stack.pop();assert a.text=='64';stack.append(Expr(256,'free'))
   elif op==0x1b:a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr((b.value<<a.value)%MOD))
   elif op==3:
    a,b=stack.pop(),stack.pop()
    if a.constant() and b.constant():t=str((a.value-b.value)%MOD)
    else:assert (a.text,b.text)==('free+length','free');t='length'
    stack.append(Expr((a.value-b.value)%MOD,t))
   elif op==0x16:a,b=stack.pop(),stack.pop();assert a.value==(1<<160)-1 and b.text=='target';stack.append(Expr(b.value,'target'))
   elif op==0x56:
    dest=stack.pop();assert dest.constant() and dest.value in destinations;targets.add(dest.value);required[dest.value]=code[dest.value];nxt=dest.value
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt
  assert [x.text for x in stack]==expected,(name,[x.text for x in stack]);cap=max(max(len(s['stack']) for s in states),len(expected))
  params='data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,target: Word,ptr: Word,index: Word,free: Word,length: Word,gasBefore: Word,value: Word';args='data,mem,prefix,target,ptr,index,free,length,gasBefore,value'
  literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)"
  initial=f"Running({entry},prefix+[{','.join(startTexts)}],mem)";final=f"Running({stop},prefix+[{','.join(expected)}],mem)"
  good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{x}] == {v}' for x,v in sorted(required.items()))
  text=f"""// SPDX-License-Identifier: MIT
// Generated complete callback controls surrounding bytes-packing helper; GAS/call observations separate.
include "Mask.dfy"
include "../../scans/Execution.dfy"
module BytecodeApplyCallbackPack{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeApplyAddressMask
  import O = BytecodeApplyCallbackPackMask
  predicate Admitted({params}) {{ target < A.Bound() && 96 <= |mem| < G.Modulus() && |mem|%32 == 0 && Load(mem,64) == free && (free as nat)+length < G.Modulus() && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
"""
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})'
   fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   if s['op']==0x16:
    tail=s['stack'][:-2];facts=f"    assert state == Running(16922,(prefix+[{','.join(tail)}])+[target,0xffffffffffffffffffffffffffffffffffffffff],mem);\n    O.At(code,Destinations(),prefix+[{','.join(tail)}],mem,target,value,data);\n"
   else:
    facts='    reveal Step();\n'
    if s['op']==0x1b:facts+='    A.Limit();\n'
   text+=f"""  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    hide G.BitAnd(); reveal Matches(); reveal Good();
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{facts}  }}
"""
  joins=[]
  for start in range(0,len(states),15):
   end=min(start+15,len(states));block=start//15;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
   text+=f"""  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
"""
   joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
  text+=f"""  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good();
    var part: seq<State>;
"""+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Exact controls surrounding bytes pack helper, explicit canonical target/memory pointer/arithmetic. Native/full public closure open.'),indent=2)+'\n');print(name,len(states),'actual callback control instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
