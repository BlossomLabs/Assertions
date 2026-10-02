#!/usr/bin/env python3
"""Exact public gather paths; arbitrary count in decoder and empty-array serializer."""
from pathlib import Path
import json,hashlib,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903'
fixture=json.loads((HERE/'fixtures/empty-canonical.json').read_text());ins={};pc=0
while pc<len(code):
 op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
dests={pc for pc,(op,_,_) in ins.items() if op==91}
class X:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def literal(self):return self.t.isdecimal()
def signed(n):return n if n<M//2 else n-M
sel=int('6db7211f',16)
for name,path,initial,guard in [
 ('Dispatch','dispatch',[],f'4 <= |data| < 0x10000000000000000 && value == 0 && ShiftRight(DataWord(data,0),224) == {sel}'),
 ('Decoder','decoder',[X(sel)],'D.Calldata(data,relative,count)'),
 ('EmptySerializer','serializer',[X(sel),X(128)],'D.EmptyHeap(mem)')]:
 if len(sys.argv)>1 and sys.argv[1]!=name:continue
 stack=initial.copy();memory='[]' if name=='Dispatch' else 'mem';rows=[];facts={};targets=set();mems=[]
 for log in fixture[path]:
  pc=log['pc'];op,nxt,imm=ins[pc];facts.update({p:code[p] for p in range(pc,nxt)});r={'id':len(rows),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':memory};rows.append(r)
  def pop():return stack.pop()
  def push(x):stack.append(x)
  if op==91:pass
  elif op==95 or 96<=op<=127:push(X(imm))
  elif 128<=op<=143:push(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==80:pop()
  elif op==0x34:push(X(0,'value'))
  elif op==0x36:push(X(68,'|data|'))
  elif op==0x35:
   off=pop()
   if name=='Dispatch':assert off.v==0;push(X(sel<<224,'DataWord(data,0)'))
   elif off.v==4:push(X(32,'relative'));r['load']='relative'
   elif off.v==36:push(X(0,'count'));r['load']='count'
   else:raise ValueError((name,pc,off.t))
  elif op==0x51:
   off=pop();assert name=='EmptySerializer' and off.v in [64,128];push(X(160 if off.v==64 else 0));r['loadMemory']=off.v
  elif op==0x52:
   off,word=pop(),pop();before=memory;memory='Memory'+str(len(mems)+1)+'(mem)';mems.append((memory,f'Store({before},{off.t},{word.t})'));r['store']=memory
  elif op in [1,3]:
   a,b=pop(),pop();v=(a.v+b.v if op==1 else a.v+M-b.v)%M
   push(X(v) if a.literal() and b.literal() else X(v,f'(({a.t} as nat)+'+('' if op==1 else 'G.Modulus()-')+f'({b.t} as nat))%G.Modulus()'))
  elif op in [0x10,0x11,0x12,0x14]:
   a,b=pop(),pop();truth=a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else signed(a.v)<signed(b.v) if op==0x12 else a.v==b.v
   comp=f'G.Signed({a.t}) < G.Signed({b.t})' if op==0x12 else f'{a.t} '+({0x10:'<',0x11:'>',0x14:'=='}.get(op,'<'))+f' {b.t}'
   push(X(int(truth),f'(if {comp} then 1 else 0)'))
  elif op==0x15:
   a=pop();push(X(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
  elif op in [0x1b,0x1c]:
   amount,arg=pop(),pop();v=((arg.v<<amount.v)%M) if op==0x1b else arg.v>>amount.v
   if name=='Dispatch':assert op==0x1c and amount.v==224;push(X(sel))
   elif amount.literal() and arg.literal():push(X(v))
   else:push(X(v,('ShiftLeft' if op==0x1b else 'ShiftRight')+f'({arg.t},{amount.t})'))
  elif op in [0x56,0x57]:
   dst=pop();assert dst.literal() and dst.v in dests;targets.add(dst.v);facts[dst.v]=code[dst.v]
   if op==0x57:pop()
  elif op==0xf3:
   off,size=pop(),pop();assert off.v==160 and size.v==64;terminal=f'Returned(G.Grow({memory},224)[160..224])'
  else:raise ValueError((name,pc,op))
 if name=='Dispatch':terminal=f'Running(458,prefix+[{sel}],{memory})'
 elif name=='Decoder':terminal='Running(2379,prefix+['+','.join(x.t for x in stack)+'],mem)'
 params='relative: Word,count: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word';args='relative,count,prefix,mem,data,value';state=lambda r:f'Running({r["pc"]},prefix+[{",".join(r["stack"])}],{r["memory"]})'
 good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false';module='AssertionsGatherPublic'+name
 s=f'''// SPDX-License-Identifier: MIT
// Exact physical public gather path; no fixture-value assumptions.
include "Spec.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module {module} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import D = AssertionsGatherPublicSpec
  opaque predicate Matches(code: seq<Byte>) {{ |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Admitted({params}) {{ |data| < G.Modulus() && |prefix| <= 960 && {guard} }}
'''
 for f,body in mems:s+=f'  function {f.removesuffix("(mem)")}(mem: seq<Byte>): seq<Byte> {{ {body} }}\n'
 s+=f'''  opaque predicate Good(id: nat,state: State,{params})
    requires |data| < G.Modulus()
  {{ Admitted({args}) && (\n{good}) }}\n'''
 for i,r in enumerate(rows):
  post=state(rows[i+1]) if i<len(rows)-1 else terminal;push=''
  if 96<=r['op']<=127:
   width=r['op']-95;owner='F' if width in [1,2,8] else 'P';push=f'    {owner}.Push{width}(code,{r["pc"]});\n'
  admissionReveal='reveal Admitted();' if name!='Dispatch' or r['op']==0x1c or (r['op']==0x57 and r['pc']<30) else ''
  extra='    D.EmptySerialization(mem);\n' if name=='EmptySerializer' and (r['op']==0x51 or r['op']==0xf3) else ''
  if name=='EmptySerializer' and r['pc']==17343:extra+='    D.ZeroStride();\n'
  if name=='Dispatch':extra+='    hide DataWord(); hide Window(); hide G.Decode(); hide ShiftRight();\n'
  if name=='Decoder' and r['pc'] in [17234,16522]:extra+='    D.Constant64();\n'
  if name=='Decoder' and r['pc']==16556:extra+='    D.Layout(data,relative,count);\n'
  s+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires |data| < G.Modulus() && |prefix| <= 960 && Admitted({args}) && Matches(code) && Good({i},state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures Step(code,Destinations(),state,value,data) == {post}
    ensures {f'Good({i+1},Step(code,Destinations(),state,value,data),{args})' if i<len(rows)-1 else 'true'}
  {{ reveal Matches(); reveal Good(); {admissionReveal} reveal Step();
{push}{extra}    assert Fetch(code,{r['pc']}) == Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
 s+=f'''  lemma Advance(id: nat,code: seq<Byte>,state: State,{params})
    requires |data| < G.Modulus() && |prefix| <= 960 && Admitted({args}) && Matches(code) && id < {len(rows)} && Good(id,state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures id < {len(rows)-1} ==> Good(id+1,Step(code,Destinations(),state,value,data),{args})
    ensures id == {len(rows)-1} ==> Step(code,Destinations(),state,value,data) == {terminal}
  {{
'''+ '\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} {{ Advance{i}(code,state,{args}); }}' for i in range(len(rows)))+f'''
  }}
  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires |data| < G.Modulus() && |prefix| <= 960 && Matches(code) && Admitted({args})
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == {state(rows[0])} && trace[|trace|-1] == state && state == {terminal}
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
  {{ reveal Good(); state := {state(rows[0])}; trace := [state]; var id: nat := 0;
    while id < {len(rows)}
      invariant id <= {len(rows)} && |trace| == id+1
      invariant E.Trace(code,Destinations(),value,data,trace)
      invariant trace[0] == {state(rows[0])} && trace[|trace|-1] == state
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
      invariant id < {len(rows)} ==> Good(id,state,{args})
      invariant id == {len(rows)} ==> state == {terminal}
      decreases {len(rows)}-id
    {{ Advance(id,code,state,{args}); var next := Step(code,Destinations(),state,value,data);
       E.Extend(code,Destinations(),value,data,trace,next); trace := trace+[next]; state := next; id := id+1;
    }}
  }}
}}
'''
 (HERE/(name+'.generated.dfy')).write_text(s);(HERE/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts,'terminal':terminal},indent=2)+'\n');print(name,len(rows))
