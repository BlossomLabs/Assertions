#!/usr/bin/env python3
"""Exact physical successful calldata Constraint decoder, unbounded symbolic inputs."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t;self.constant=t is None
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out,runtime=None):
 code=runtime.read_bytes() if runtime else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest()
 if runtime is None:assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 destinations={p for p,(op,_,_) in ins.items() if op==91}
 pc=19377;s=[E(7723,'ret'),E(292,'offset')];mem='mem';states=[];required={};targets={'ret'};seen=set();alignment=[]
 datawords={292:E(7,'kind'),324:E(64,'referenceRelative'),356:E(0,'length')}
 params='ret: Word, offset: Word, kind: Word, referenceRelative: Word, length: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>'
 args='ret,offset,kind,referenceRelative,length,free,prefix,mem,data'
 def pop():return s.pop()
 def push(x):s.append(x)
 def binary(op,a,b):
  if op==1:v=(a.v+b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'
  elif op==3:v=(a.v-b.v)%MOD;t=f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
  elif op in [16,17,18,20]:
   pred={16:f'{a.t} < {b.t}',17:f'{a.t} > {b.t}',18:f'G.Signed({a.t}) < G.Signed({b.t})',20:f'{a.t} == {b.t}'}[op]
   v=int({16:a.v<b.v,17:a.v>b.v,18:signed(a.v)<signed(b.v),20:a.v==b.v}[op]);t=f'(if {pred} then 1 else 0)'
  elif op==27:v=(b.v<<a.v)%MOD if a.v<256 else 0;t=f'S.ShiftLeft({b.t},{a.t})'
  else:raise ValueError(op)
  return E(v) if a.constant and b.constant else E(v,t)
 while True:
  key=(pc,tuple(x.t for x in s),mem);assert pc in ins and key not in seen,(pc,'Uncertified cycle');seen.add(key);op,nxt,imm=ins[pc]
  for q in range(pc,nxt):required[q]=code[q]
  node={'id':len(states),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in s],'memory':mem,'guide':[]};states.append(node)
  if op==91:pass
  elif op==95 or 96<=op<=127:push(E(imm))
  elif 128<=op<=143:push(s[-(op-127)])
  elif 144<=op<=159:k=op-143;s[-1],s[-1-k]=s[-1-k],s[-1]
  elif op==80:pop()
  elif op==21:
   a=pop();push(E(int(a.v==0)) if a.constant else E(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
  elif op==25:
   a=pop();assert a.v==31;push(E(MOD-32));node['guide'].append('    H.Complement31();')
  elif op==22:
   a,b=pop(),pop();v=a.v&b.v;assert a.v==MOD-32
   if pc==18422:
    node['guide']+=[f'    assert {b.t} == length+31;','    L.Rounded(length);','    HH.Commute(G.Modulus()-32,length+31);'];push(E(v,'S.Round32(length)'))
   else:
    assert pc==18353
    node['guide']+=[f'    assert {b.t} == S.Round32(length)+63;','    L.Mask(S.Round32(length)+63);','    HH.Commute(G.Modulus()-32,S.Round32(length)+63);','    B.Rounded(length);','    assert (S.Round32(length)+63)/32*32 == S.Round32(length)+32;'];push(E(v,'S.Round32(length)+32'))
  elif op==23:
   a,b=pop(),pop();assert a.v==0 and b.v==0;node['guide']+=[f'    assert {a.t} == 0 && {b.t} == 0;','    H.BoolOr(0,0);'];push(E(0))
  elif op in [1,3,16,17,18,20,27]:
   push(binary(op,pop(),pop()))
   if op==27:node['guide'].append('    D.DecoderLimit();')
  elif op==54:push(E(388,'|data|'))
  elif op==53:
   a=pop();b=datawords[a.v];push(b);node['guide'].append(f'    assert S.DataWord(data,{a.t}) == {b.t};')
  elif op==81:
   a=pop();assert a.v==64
   if pc==18306:push(E(224,'free'))
   else:
    assert pc==18345;push(E(288,'free+64'));node['guide']+=['    R.StoredWord(mem,64,free+64);','    R.StoredFrame(S.Store(mem,64,free+64),free,kind,64);']
   node['guide'] += [f'    assert S.Load({mem},64) == {s[-1].t};',f'    assert S.Expand({mem},96) == {mem};']
  elif op==82:
   a,b=pop(),pop()
   off,val={18339:('64','free+64'),19414:('free','kind'),18385:('64','NextFree(free,length)'),18465:('free+64','length'),18503:('free+96+length','0'),19455:('free+32','free+64')}[pc]
   node['guide'] += alignment
   if pc==18503:
    node['guide'] += ['    assert (free as nat)+64+length < G.Modulus();','    assert ((free+64 as nat)+(length as nat))%G.Modulus() == free+64+length;']
   node['guide'] += [f'    assert {a.t} == {off} && {b.t} == {val};',f'    R.StoredWord({mem},{off},{val});']
   alignment.append(f'    R.StoredWord({mem},{off},{val});');mem=f'S.Store({mem},{off},{val})'
  elif op in [55,94]:
   destination,source,size=pop(),pop(),pop();assert (destination.v,source.v,size.v)==(320,388,0)
   node['guide'] += [f'    assert {destination.t} == free+96 && {source.t} == PayloadOffset(offset,referenceRelative) && {size.t} == length;',f'    assert C.Fits({mem},free+96,PayloadOffset(offset,referenceRelative),length,{str(op==94).lower()});']
   alignment += [f'    B.Size({mem},free+96,S.Window(data,PayloadOffset(offset,referenceRelative),length));','    B.Rounded((free as nat)+96+length);']
   mem=f'B.Calldata({mem},free+96,PayloadOffset(offset,referenceRelative),length,data)'
  elif op in [86,87]:
   destination=pop();condition=None if op==86 else pop();take=op==86 or condition.v!=0
   if not destination.constant:
    assert op==86 and destination.t=='ret';break
   assert destination.v in destinations;required[destination.v]=code[destination.v];targets.add(str(destination.v))
   if pc==18478:
    node['guide'] += ['    assert ((offset as nat)+referenceRelative)%G.Modulus() == offset+referenceRelative;','    assert ((offset+referenceRelative as nat)+length)%G.Modulus() == offset+referenceRelative+length;','    assert ((32 as nat)+(offset+referenceRelative+length as nat))%G.Modulus() == offset+referenceRelative+length+32;']
   if take:nxt=destination.v
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 finalstack=[x.t for x in s];assert finalstack==['free'],finalstack
 constraints=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
 targetlist=','.join(sorted(targets,key=lambda t:(t=='ret',int(t) if t!='ret' else 0)))
 text=f'''// SPDX-License-Identifier: MIT
// Complete physical calldata Constraint decoder; arbitrary reference bytes/length.
include "DecoderMemory.dfy"
include "../raw/Frame.dfy"
include "DecoderScalar.dfy"
include "And.dfy"
include "Addresses.dfy"
include "../../scans/Fetch.dfy"
module AssertionsConstraintDecoder {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  import A = AssertionsSignedMachine
  import M = AssertionsRawResolveMachine
  import R = BytecodeScanRepresentation
  import P = AssertionsConstraintDecoderMemory
  import F = BytecodeScanFetch
  import D = BytecodeScanDecoderScalar
  import H = AssertionsConstraintDecoderScalar
  import L = AssertionsPrimitiveLowMask
  import HH = AssertionsConstraintAnd
  import V = AssertionsConstraintAddresses
  import Q = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  function PayloadOffset(offset: Word, relative: Word): Word
    requires (offset as nat)+relative+32 < G.Modulus()
  {{ offset+relative+32 }}
  function NextFree(free: Word, length: Word): Word
    requires (free as nat)+S.Round32(length)+96 < G.Modulus()
  {{ free+S.Round32(length)+96 }}
  predicate Admitted({params}) {{
    |prefix| <= 980 && kind <= 8 &&
    |data| < 0x10000000000000000 && (offset as nat)+64 <= |data| &&
    (offset as nat)+referenceRelative+32+length <= |data| &&
    S.DataWord(data,offset) == kind && S.DataWord(data,offset+32) == referenceRelative &&
    S.DataWord(data,offset+referenceRelative) == length &&
    P.Fits(mem,free,PayloadOffset(offset,referenceRelative),length,data) && S.Load(mem,64) == free
  }}
  opaque predicate Matches(code: seq<Byte>, ret: Word) {{
    |code| == {len(code)} && ret < |code| && code[ret] == 91 &&
    {constraints}
  }}
  function Destinations(ret: Word): set<nat> {{ {{{targetlist}}} }}
  opaque predicate Good(id: nat, state: S.State, {params}) {{
    Admitted({args}) && (
{good})
  }}
'''
 for n in states:
  i=n['id'];post=f'next == S.Running(ret,prefix+[free],P.Construct(mem,free,kind,PayloadOffset(offset,referenceRelative),length,data))' if i==len(states)-1 else f'Good({i+1},next,{args})'
  fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else ''
  guide='\n'.join(n['guide'])
  attrs=' {:isolate_assertions}' if n['op'] in [22,55,82] or n['pc']==18184 else ''
  before='    B.Rounded(length); V.Normalize(free,length,offset,referenceRelative);' if n['pc'] in [18478,18492,18503] else ''
  text+=f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word)
    requires Matches(code,ret) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
    ensures var next := M.Step(code,Destinations(ret),state,value,data); {post}
  {{
    hide G.BitAnd();
{before}
    reveal Matches(); reveal Good(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
'''
 calls='\n'.join(f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args},value); }}' for i in range(len(states)))
 text+=f'''  lemma Start(code: seq<Byte>, {params})
    requires Admitted({args}) && Matches(code,ret)
    ensures Good(0,S.Running(19377,prefix+[ret,offset],mem),{args})
    ensures Q.Local(code,S.Running(19377,prefix+[ret,offset],mem))
  {{ reveal Good(); reveal Matches(); }}
  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word)
    requires Matches(code,ret) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
    ensures var next := M.Step(code,Destinations(ret),state,value,data);
      if id == {len(states)-1} then next == S.Running(ret,prefix+[free],P.Construct(mem,free,kind,PayloadOffset(offset,referenceRelative),length,data)) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word) returns (state: S.State, trace: seq<S.State>)
    requires Matches(code,ret) && Admitted({args})
    ensures state == S.Running(ret,prefix+[free],P.Construct(mem,free,kind,PayloadOffset(offset,referenceRelative),length,data))
    ensures M.Trace(code,Destinations(ret),value,data,trace)
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
    ensures trace[0] == S.Running(19377,prefix+[ret,offset],mem) && trace[|trace|-1] == state
    ensures S.Load(state.memory,free) == kind && S.Load(state.memory,free+32) == free+64 && S.Load(state.memory,free+64) == length && state.memory[free+96..free+96+length] == data[PayloadOffset(offset,referenceRelative)..PayloadOffset(offset,referenceRelative)+length]
  {{
    state := S.Running(19377,prefix+[ret,offset],mem);
    Start(code,{args}); trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant M.Trace(code,Destinations(ret),value,data,trace)
      invariant forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
      invariant trace[0] == S.Running(19377,prefix+[ret,offset],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == S.Running(ret,prefix+[free],P.Construct(mem,free,kind,PayloadOffset(offset,referenceRelative),length,data))
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{args},value);
      var next := M.Step(code,Destinations(ret),state,value,data);
      M.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];state := next;id := id+1;
    }}
    P.Built(mem,free,kind,PayloadOffset(offset,referenceRelative),length,data);
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Decoder.generated.dfy').write_text(text);(out/'Decoder.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'scope':'complete successful calldata Constraint decoder under explicit physical bounds; arbitrary kind0..8/reference bytes/length; failures and validator loop remain open'},indent=2)+'\n');print(len(states),'complete constraint decoder states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
 if a.dafny:subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/format-generated.py','--output',a.output,'--include-root',HERE],env=dict(os.environ,DAFNY=str(a.dafny.resolve())),check=True)
