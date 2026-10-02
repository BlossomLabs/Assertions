#!/usr/bin/env python3
"""Exact symbolic public pick dispatcher and InputParam/int256 decoder."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903'
fixture=json.loads((ROOT/'formal/bytecode/assertions-primitives-control/evidence/20261002-v1/evm-traces/pick-last.json').read_text());logs=[x for x in fixture['trace']['structLogs'] if x['depth']==1];decoder=next(i for i,x in enumerate(logs) if x['pc']==566);body=next(i for i,x in enumerate(logs) if x['pc']==3131)
class X:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def literal(self):return self.t.isdecimal()
def signed(v):return v if v<M//2 else v-M
selector=int('bf50f520',16);relatives={4:X(64,'relative'),36:X(M-1,'index')};length=(len(fixture['data'])-2)//2
for name,path,initial,guard in [('Dispatch',logs[:decoder],[],'4 <= |data| < 0x10000000000000000 && value == 0 && S.ShiftRight(S.DataWord(data,0),224) == D.Selector()'),('Decoder',logs[decoder:body],[X(selector)],'D.Calldata(data,relative,index)')]:
 stack=initial.copy();memory='[]' if name=='Dispatch' else 'mem';rows=[];facts={};targets=set()
 for log in path:
  pc=log['pc'];op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});rows.append({'id':len(rows),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':memory})
  def pop():return stack.pop()
  def push(x):stack.append(x)
  if op==91:pass
  elif op==95 or 96<=op<=127:push(X(imm))
  elif 128<=op<=143:push(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==80:pop()
  elif op==0x34:push(X(0,'value'))
  elif op==0x36:push(X(length,'|data|'))
  elif op==0x35:
   off=pop();push(X(selector<<224,'S.DataWord(data,0)') if name=='Dispatch' else relatives[off.v])
  elif op==0x52:assert name=='Dispatch' and pop().v==64 and pop().v==128;memory='D.Initial()'
  elif op in [1,3]:
   a,b=pop(),pop();v=(a.v+b.v if op==1 else a.v+M-b.v)%M;t=f'(({a.t} as nat)+'+('' if op==1 else 'G.Modulus()-')+f'({b.t} as nat))%G.Modulus()';push(X(v) if a.literal() and b.literal() else X(v,t))
  elif op in [0x10,0x11,0x12,0x14]:
   a,b=pop(),pop();pred={0x10:f'{a.t} < {b.t}',0x11:f'{a.t} > {b.t}',0x12:f'G.Signed({a.t}) < G.Signed({b.t})',0x14:f'{a.t} == {b.t}'}[op];v=int({0x10:a.v<b.v,0x11:a.v>b.v,0x12:signed(a.v)<signed(b.v),0x14:a.v==b.v}[op]);push(X(v) if a.literal() and b.literal() else X(v,f'(if {pred} then 1 else 0)'))
  elif op==0x15:a=pop();push(X(int(a.v==0)) if a.literal() else X(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
  elif op in [0x1b,0x1c]:
   amount,a=pop(),pop();v=(a.v<<amount.v)%M if op==0x1b else a.v>>amount.v;push(X(v,f'S.{"ShiftLeft" if op==0x1b else "ShiftRight"}({a.t},{amount.t})'))
  elif op in [0x56,0x57]:
   dst=pop();assert dst.literal() and code[dst.v]==91;targets.add(dst.v);facts[dst.v]=91
   if op==0x57:pop()
  else:raise ValueError((name,pc,op))
 params='relative: Word,index: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word';args='relative,index,prefix,mem,data,value';state=lambda r:f'S.Running({r["pc"]},prefix+[{",".join(r["stack"])}],{r["memory"]})';terminal=f'S.Running({566 if name=="Dispatch" else 3131},prefix+[{",".join(x.t for x in stack)}],{memory})';good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false';mod='AssertionsPickPublic'+name
 s=f'''// SPDX-License-Identifier: MIT
// Exact physical public pick {name.lower()} path; arbitrary admitted calldata.
include "Spec.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
module {mod} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import D = AssertionsPickPublicSpec
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) {{ |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Admitted({params}) {{ |data| < G.Modulus() && |prefix| <= 960 && {guard} }}
  opaque predicate Good(id: nat,state: S.State,{params})
    requires |data| < G.Modulus()
  {{ Admitted({args}) && (\n{good}) }}
'''
 for i,r in enumerate(rows):
  post=state(rows[i+1]) if i<len(rows)-1 else terminal;push=''
  if 96<=r['op']<=127:w=r['op']-95;push=f'    {"F" if w in [1,2,8] else "P"}.Push{w}(code,{r["pc"]});\n'
  extra='    D.Constant64();\n' if name=='Decoder' else ''
  if name=='Decoder' and r['op'] in [1,3,0x12]:extra+='    D.Pointers(data,relative,index);\n'
  s+=f'''  lemma Advance{i}(code: seq<Byte>,state: S.State,{params})
    requires |data| < G.Modulus() && Admitted({args}) && Matches(code) && Good({i},state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(),state,value,data) == {post}
  {{ reveal Admitted(); reveal Good(); reveal Matches(); reveal S.Step();
    hide S.DataWord(); hide S.Window(); hide G.Decode(); hide S.ShiftRight(); hide S.ShiftLeft();
{extra}{push}    assert S.Fetch(code,{r['pc']}) == S.Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
 s+=f'''  lemma Advance(id: nat,code: seq<Byte>,state: S.State,{params})
    requires |data| < G.Modulus() && Admitted({args}) && Matches(code) && Good(id,state,{args}) && id < {len(rows)}
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(),state,value,data) != S.Bad
    ensures id+1 < {len(rows)} ==> Good(id+1,S.Step(code,Destinations(),state,value,data),{args})
    ensures id+1 == {len(rows)} ==> S.Step(code,Destinations(),state,value,data) == {terminal}
  {{ reveal Good();
'''
 for i in range(len(rows)):s+=f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args}); }}\n'
 s+=f'''  }}
  ghost method Run(code: seq<Byte>,{params}) returns (state: S.State,trace: seq<S.State>)
    requires |data| < G.Modulus() && Matches(code) && Admitted({args})
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
    {{ Advance(id,code,state,{args}); var next := S.Step(code,Destinations(),state,value,data); E.Extend(code,Destinations(),value,data,trace,next); trace := trace+[next];state := next;id := id+1; }}
  }}
}}
'''
 (HERE/(name+'.generated.dfy')).write_text(s);(HERE/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts,'terminal':terminal},indent=2)+'\n');print(name,len(rows))
