#!/usr/bin/env python3
"""Exact raw/no-constraint resolver instructions, arbitrary bytes and byte lengths."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t;self.constant=t is None
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 destinations={p for p,(op,_,_) in ins.items() if op==91}
 pc=3393;s=[E(1017,'ret'),E(68,'paramPointer'),E(128,'assertion'),E(2,'entry'),E(3,'param')];mem='mem';states=[];required={};targets={'ret'};seen=set()
 datawords={100:E(0),132:E(128,'bytesRelative'),164:E(224,'constraintsRelative'),196:E(33,'length'),292:E(0)}
 params='ret: Word, paramPointer: Word, assertion: Word, entry: Word, param: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>'
 args='ret,paramPointer,assertion,entry,param,bytesRelative,constraintsRelative,length,free,prefix,mem,data'
 def pop():return s.pop()
 def push(x):s.append(x)
 def bin(op,a,b):
  if op==1:v=(a.v+b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'
  elif op==2:v=(a.v*b.v)%MOD;t=f'(({a.t} as nat)*({b.t} as nat))%G.Modulus()'
  elif op==3:v=(a.v-b.v)%MOD;t=f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
  elif op==4:v=0 if b.v==0 else a.v//b.v;t=f'(if {b.t} == 0 then 0 else ({a.t} as nat)/({b.t} as nat))'
  elif op in [16,17,18,19,20]:
   predicate={16:f'{a.t} < {b.t}',17:f'{a.t} > {b.t}',18:f'G.Signed({a.t}) < G.Signed({b.t})',19:f'G.Signed({a.t}) > G.Signed({b.t})',20:f'{a.t} == {b.t}'}[op]
   v=int({16:a.v<b.v,17:a.v>b.v,18:signed(a.v)<signed(b.v),19:signed(a.v)>signed(b.v),20:a.v==b.v}[op]);t=f'(if {predicate} then 1 else 0)'
  elif op==27:v=(b.v<<a.v)%MOD if a.v<256 else 0;t=f'S.ShiftLeft({b.t},{a.t})'
  else:raise ValueError(op)
  return E(v) if a.constant and b.constant else E(v,t)
 while True:
  key=(pc,tuple(x.t for x in s),mem)
  assert pc in ins and key not in seen,(pc,'Uncertified cycle');seen.add(key);op,nxt,imm=ins[pc]
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
   a=pop();push(E(MOD-1-a.v) if a.constant else E(MOD-1-a.v,f'S.BitNot({a.t})'));node['guide'].append('    H.ComplementThirty();')
  elif op in [1,2,3,4,16,17,18,19,20,27]:
   push(bin(op,pop(),pop()))
   if op==27:node['guide']+=['    D.DecoderLimit();','    H.ZeroShift();']
  elif op==54:push(E(512,'|data|'))
  elif op==53:
   a=pop();b=datawords[a.v];push(b);node['guide'].append(f'    assert S.DataWord(data,{a.t}) == {b.t};')
  elif op==81:
   a=pop();assert a.v==64 and mem=='mem';push(E(320,'free'));node['guide']+=['    assert S.Load(mem,64) == free;','    assert S.Expand(mem,96) == mem;']
  elif op==82:
   a,b=pop(),pop()
   if pc==3470:off='64';value='NextFree(free,length)'
   elif pc==3478:off='free';value='length'
   elif pc==3494:off='free+32+length';value='0'
   else:raise ValueError(('Unexpected store',pc))
   node['guide']+=[f'    assert {a.t} == {off} && {b.t} == {value};']
   if pc==3494:
    header='S.Store(S.Store(mem,64,NextFree(free,length)),free,length)'
    node['guide']+=['    R.StoredWord(mem,64,NextFree(free,length));','    R.StoredWord(S.Store(mem,64,NextFree(free,length)),free,length);',f'    B.Size({header},free+32,S.Window(data,PayloadOffset(paramPointer,bytesRelative),length));','    B.Rounded((free as nat)+32+length);']
   node['guide']+=[f'    R.StoredWord({mem},{off},{value});'];mem=f'S.Store({mem},{off},{value})'
  elif op==55:
   destination,source,length=pop(),pop(),pop();assert (destination.v,source.v,length.v)==(352,228,33)
   node['guide']+=[f'    assert {destination.t} == free+32 && {source.t} == PayloadOffset(paramPointer,bytesRelative) && {length.t} == length;',f'    assert C.Fits({mem},free+32,PayloadOffset(paramPointer,bytesRelative),length,false);']
   mem=f'B.Calldata({mem},free+32,PayloadOffset(paramPointer,bytesRelative),length,data)'
  elif op in [86,87]:
   destination=pop();condition=None if op==86 else pop();take=op==86 or condition.v!=0
   if pc==18184:
    node['guide']+=[
     '    assert ((|data| as nat)+G.Modulus()-(paramPointer as nat))%G.Modulus() == |data|-paramPointer;',
     '    assert (((|data|-paramPointer)+G.Modulus()-31)%G.Modulus()) == |data|-paramPointer-31;',
     '    assert G.Signed(constraintsRelative) == constraintsRelative && G.Signed(|data|-paramPointer-31) == |data|-paramPointer-31;',
     f'    assert {condition.t} == 1;']
   if destination.t=='ret':assert op==86;break
   assert destination.constant and destination.v in destinations
   required[destination.v]=code[destination.v];targets.add(str(destination.v))
   if take:nxt=destination.v
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 finalstack=[x.t for x in s];assert finalstack==['free'],finalstack
 constraints=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == S.Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
 targetlist=','.join(sorted(targets,key=lambda t:(t=='ret',int(t) if t!='ret' else 0)))
 ordered=sorted(destinations);chunks=[ordered[i:i+32] for i in range(0,len(ordered),32)]
 destfunctions='\n'.join(f'  opaque function DestinationsChunk{i}(): set<nat> {{ {{{",".join(map(str,chunk))}}} }}' for i,chunk in enumerate(chunks))
 destunion='+'.join(f'DestinationsChunk{i}()' for i in range(len(chunks)))
 text=f'''// SPDX-License-Identifier: MIT
// Exact _resolve RAW_BYTES/no-constraints physical execution, arbitrary payload.
include "Memory.dfy"
include "Frame.dfy"
include "Scalar.dfy"
include "../../scans/Fetch.dfy"
module AssertionsRawResolve {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCopyMemory
  import A = AssertionsSignedMachine
  import M = AssertionsRawResolveMachine
  import R = BytecodeScanRepresentation
  import P = AssertionsRawResolveMemory
  import F = BytecodeScanFetch
  import D = BytecodeScanDecoderScalar
  import H = AssertionsRawResolveScalar
  import Q = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  function PayloadOffset(paramPointer: Word, relative: Word): Word
    requires (paramPointer as nat)+relative+32 < G.Modulus()
  {{ paramPointer+relative+32 }}
  function NextFree(free: Word, length: Word): Word
    requires (free as nat)+S.Round32(length)+32 < G.Modulus()
  {{ free+S.Round32(length)+32 }}
{destfunctions}
  opaque function FullRuntimeDestinations(): set<nat> {{ {destunion} }}
  predicate Admitted({params}) {{
    ret in FullRuntimeDestinations() && |prefix| <= 980 &&
    |data| < 0x10000000000000000 && (paramPointer as nat)+128 <= |data| &&
    (paramPointer as nat)+bytesRelative+32+length <= |data| &&
    (paramPointer as nat)+constraintsRelative+32 <= |data| &&
    S.DataWord(data,paramPointer+32) == 0 && S.DataWord(data,paramPointer+64) == bytesRelative &&
    S.DataWord(data,paramPointer+96) == constraintsRelative && S.DataWord(data,paramPointer+bytesRelative) == length &&
    S.DataWord(data,paramPointer+constraintsRelative) == 0 &&
    P.Fits(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data) && S.Load(mem,64) == free
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
  i=n['id'];post=f'next == S.Running(ret,prefix+[free],P.Construct(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data))' if i==len(states)-1 else f'Good({i+1},next,{args})'
  fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else ''
  guide='\n'.join(n['guide'])
  attrs=' {:isolate_assertions}' if n['op'] in [55,82] or n['pc']==18184 else ''
  text+=f'''  lemma{attrs} Advance{i}(code: seq<Byte>, state: S.State, {params}, value: Word)
    requires Matches(code,ret) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
    ensures var next := M.Step(code,Destinations(ret),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal M.Step(); reveal C.Step(); reveal A.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
'''
 calls='\n'.join(f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args},value); }}' for i in range(len(states)))
 text+=f'''  lemma Start(code: seq<Byte>, {params})
    requires Admitted({args}) && Matches(code,ret)
    ensures Good(0,S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem),{args})
    ensures Q.Local(code,S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem))
  {{ reveal Good(); reveal Matches(); }}
  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params}, value: Word)
    requires Matches(code,ret) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
    ensures M.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures Q.Local(code,state) && Q.Local(code,M.Step(code,Destinations(ret),state,value,data))
    ensures var next := M.Step(code,Destinations(ret),state,value,data);
      if id == {len(states)-1} then next == S.Running(ret,prefix+[free],P.Construct(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data)) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word) returns (state: S.State, trace: seq<S.State>)
    requires Matches(code,ret) && Admitted({args})
    ensures state == S.Running(ret,prefix+[free],P.Construct(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data))
    ensures M.Trace(code,Destinations(ret),value,data,trace)
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
    ensures trace[0] == S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem) && trace[|trace|-1] == state
    ensures S.Load(state.memory,free) == length && state.memory[free+32..free+32+length] == data[PayloadOffset(paramPointer,bytesRelative)..PayloadOffset(paramPointer,bytesRelative)+length]
  {{
    state := S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem);
    Start(code,{args}); trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant M.Trace(code,Destinations(ret),value,data,trace)
      invariant forall i {{:trigger trace[i]}} :: 0 <= i < |trace| ==> Q.Local(code,trace[i])
      invariant trace[0] == S.Running(3393,prefix+[ret,paramPointer,assertion,entry,param],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == S.Running(ret,prefix+[free],P.Construct(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data))
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{args},value);
      var next := M.Step(code,Destinations(ret),state,value,data);
      M.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];state := next;id := id+1;
    }}
    P.Built(mem,free,PayloadOffset(paramPointer,bytesRelative),length,data);
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True);(out/'Raw.generated.dfy').write_text(text);(out/'Raw.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'fullRuntimeDestinations':ordered,'scope':'entire internal raw/no-constraints _resolve path under physical caller calldata/memorypremises; symbolic arbitrarypayloadbytes andlength; publicentry/probe branches stillpending'},indent=2)+'\n');print(len(states),'complete raw resolver states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path);a=p.parse_args();generate(a.output)
 if a.dafny:subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/format-generated.py','--output',a.output,'--include-root',HERE],env=dict(os.environ,DAFNY=str(a.dafny.resolve())),check=True)
