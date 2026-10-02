#!/usr/bin/env python3
"""Exact symbolic array header, loop prefix/suffix and completion paths."""
from pathlib import Path
import json,hashlib,sys
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903'
trace=json.loads((ROOT/'formal/bytecode/assertions-primitives-control/gather-composition/evidence/element-native-v1/evm-traces/element-33.json').read_text())['trace']['structLogs'];logs=[x for x in trace if x['depth']==1];pcseq=[x['pc'] for x in logs];begin=pcseq.index(17316);header=pcseq.index(17354,begin);leaf=pcseq.index(17270,header);after=pcseq.index(17382,leaf);again=pcseq.index(17354,after);done=pcseq.index(381,again)
class X:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def literal(self):return self.t.isdecimal()
sel=1840718111
raw=[X(381,'ret'),X(128,'arrayBase'),X(320,'base'),X(0),X(416,'tail'),X(384,'head'),X(1,'count'),X(160,'source'),X(0,'index')]
loop='D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index)'
for name,path,initial,guard in [
 ('Start',logs[begin:header],[X(381,'ret'),X(128,'arrayBase'),X(320,'base')],'D.StartHeap(mem,arrayBase,base,count)'),
 ('Head',logs[header:leaf],raw,loop+' && index < count && S.Load(mem,source) == bytesPtr'),
 ('Tail',logs[after:again],raw+[X(512,'newTail')],'D.LoopHeap(mem,arrayBase,base,newTail,head,count,source,index) && index < count'),
 ('Done',logs[again:done],raw[:-1]+[X(1,'index')],loop+' && index == count')]:
 if len(sys.argv)>1 and sys.argv[1]!=name:continue
 rows=[];facts={};stack=initial.copy();memory='mem';mems=[];targets=set()
 for log in path:
  pc=log['pc'];op=code[pc];w=op-95 if 96<=op<=127 else 0;nxt=pc+1+w;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});rows.append({'id':len(rows),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':memory})
  def pop():return stack.pop()
  def push(x):stack.append(x)
  if op==91:pass
  elif op==95 or 96<=op<=127:push(X(imm))
  elif 128<=op<=143:push(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==80:pop()
  elif op==0x51:
   off=pop();assert (name=='Start' and off.t=='arrayBase') or (name=='Head' and off.t=='source');push(X(1,'count') if name=='Start' else X(224,'bytesPtr'))
  elif op==0x52:
   off,value=pop(),pop();before=memory;memory='Memory'+str(len(mems)+1)+'(mem,base,tail,head,count)';mems.append((memory,f'S.Store({before},{off.t},{value.t})'))
  elif op in [1,3]:
   a,b=pop(),pop();v=(a.v+b.v if op==1 else a.v+M-b.v)%M;push(X(v) if a.literal() and b.literal() else X(v,f'(({a.t} as nat)+'+('' if op==1 else 'G.Modulus()-')+f'({b.t} as nat))%G.Modulus()'))
  elif op==0x19:assert pop().t=='63';push(X(M-64,'G.Modulus()-64'))
  elif op==0x1b:a,b=pop(),pop();assert a.v==5;push(X(b.v*32,'S.ShiftLeft(count,5)'))
  elif op==0x10:
   a,b=pop(),pop();push(X(int(a.v<b.v),f'(if {a.t} < {b.t} then 1 else 0)'))
  elif op==0x15:a=pop();push(X(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
  elif op in [0x56,0x57]:
   dst=pop()
   if dst.t=='ret':targets.add('ret')
   else:assert dst.literal() and code[dst.v]==91;targets.add(str(dst.v));facts[dst.v]=91
   if op==0x57:pop()
  else:raise ValueError((name,pc,op))
 params='ret: Word,arrayBase: Word,base: Word,tail: Word,head: Word,count: Word,source: Word,index: Word,bytesPtr: Word,newTail: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word';args='ret,arrayBase,base,tail,head,count,source,index,bytesPtr,newTail,prefix,mem,data,value'
 state=lambda r:f'S.Running({r["pc"]},prefix+[{",".join(r["stack"])}],{r["memory"]})';terminal=f'S.Running({17354 if name in ["Start","Tail"] else 17270 if name=="Head" else "ret"},prefix+[{",".join(x.t for x in stack)}],{memory})'
 good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false';mod='AssertionsGatherArray'+name
 s=f'''// SPDX-License-Identifier: MIT
// Exact physical array serializer {name.lower()} path, symbolic heap and count.
include "ArraySpec.dfy"
include "../../../scans/Execution.dfy"
include "../../../scans/Push.dfy"
module {mod} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import D = AssertionsGatherArraySpec
  import R = BytecodeScanRepresentation
  import DS = AssertionsGatherCallerSpec
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>,ret: Word) {{ ret < |code| && code[ret] == 0x5b && |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(ret: Word): set<nat> {{ {{{','.join(sorted(targets))}}} }}
  opaque predicate Admitted({params}) {{ |prefix| <= 950 && ret in DS.RuntimeDestinations() && {guard} }}
'''
 for f,body in mems:s+=f'  function {f.split("(")[0]}(mem: seq<Byte>,base: Word,tail: Word,head: Word,count: Word): seq<Byte> {{ {body} }}\n'
 s+=f'  opaque predicate Good(id: nat,state: S.State,{params}) {{ Admitted({args}) && (\n{good}) }}\n'
 for i,r in enumerate(rows):
  post=state(rows[i+1]) if i<len(rows)-1 else terminal;push=''
  if 96<=r['op']<=127:width=r['op']-95;push=f'    F.Push{width}(code,{r["pc"]});\n'
  extra='    D.StartWords(mem,arrayBase,base,count);\n' if name=='Start' else f'    D.LoopWords(mem,arrayBase,base,{"newTail" if name=="Tail" else "tail"},head,count,source,index);\n'
  if name=='Head' and r['op']==0x51:extra+='    R.StoredFrame(mem,head,D.Offset(base,tail),source);\n'
  s+=f'''  lemma Advance{i}(code: seq<Byte>,state: S.State,{params})
    requires Matches(code,ret) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(ret),state,value,data) == {post}
  {{
    reveal Admitted(); reveal Good(); reveal Matches();
{extra}    reveal S.Step();
    hide S.BitNot(); hide S.ShiftLeft(); hide S.Load(); hide S.DataWord(); hide G.Decode();
{push}    assert S.Fetch(code,{r['pc']}) == S.Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
 s+=f'''  lemma Advance(id: nat,code: seq<Byte>,state: S.State,{params})
    requires id < {len(rows)} && Matches(code,ret) && Admitted({args}) && Good(id,state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures id+1 < {len(rows)} ==> Good(id+1,S.Step(code,Destinations(ret),state,value,data),{args})
    ensures id+1 == {len(rows)} ==> S.Step(code,Destinations(ret),state,value,data) == {terminal}
  {{ reveal Good();
'''
 for i in range(len(rows)):s+=f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args}); }}\n'
 s+=f'''  }}
  ghost method Run(code: seq<Byte>,{params}) returns (state: S.State,trace: seq<S.State>)
    requires Matches(code,ret) && Admitted({args})
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == {state(rows[0])} && trace[|trace|-1] == state && state == {terminal}
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
  {{
    reveal Good(); state := {state(rows[0])}; trace := [state]; var id: nat := 0;
    while id < {len(rows)}
      invariant id <= {len(rows)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == {state(rows[0])} && trace[|trace|-1] == state
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
      invariant id < {len(rows)} ==> Good(id,state,{args})
      invariant id == {len(rows)} ==> state == {terminal}
      decreases {len(rows)}-id
    {{ Advance(id,code,state,{args}); var next := S.Step(code,Destinations(ret),state,value,data);
       E.Extend(code,Destinations(ret),value,data,trace,next); trace := trace+[next]; state := next; id := id+1;
    }}
  }}
}}
'''
 (HERE/(name+'.generated.dfy')).write_text(s);(HERE/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts,'terminal':terminal},indent=2)+'\n');print(name,len(rows))
