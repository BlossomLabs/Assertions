#!/usr/bin/env python3
"""Exact physical public resolve RAW/empty-constraints call prefix and RETURN."""
import argparse,hashlib,json,os,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];MOD=1<<256;SELECTOR=0x1fa99b32
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t;self.constant=t is None
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out,runtime=None):
 code=runtime.read_bytes() if runtime else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 destinations={p for p,(op,_,_) in ins.items() if op==91}
 params='relative: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, data: seq<Byte>'
 args='relative,bytesRelative,constraintsRelative,length,data'
 seeds=[('Prefix',0,[],'[]'),('Return',1017,[E(SELECTOR),E(285),E(36,'Pointer(relative)'),E(0),E(160)],'Memory(relative,bytesRelative,constraintsRelative,length,data)')]
 for name,pc,s,mem in seeds:
  states=[];required={};targets=set();seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while True:
   assert (pc,tuple(x.t for x in s),mem) not in seen;seen.add((pc,tuple(x.t for x in s),mem));op,nxt,imm=ins[pc]
   for q in range(pc,nxt):required[q]=code[q]
   node={'id':len(states),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in s],'memory':mem,'guide':[]};states.append(node)
   if op==91:pass
   elif op==95 or 96<=op<=127:push(E(imm))
   elif 128<=op<=143:push(s[-(op-127)])
   elif 144<=op<=159:k=op-143;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==80:pop()
   elif op==21:
    a=pop();push(E(int(a.v==0)) if a.constant else E(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
   elif op in [1,3,16,17,18,20,27,28]:
    a,b=pop(),pop()
    if op==1:v=(a.v+b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'
    elif op==3:v=(a.v-b.v)%MOD;t=f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
    elif op in [16,17,18,20]:
     predicate={16:f'{a.t} < {b.t}',17:f'{a.t} > {b.t}',18:f'G.Signed({a.t}) < G.Signed({b.t})',20:f'{a.t} == {b.t}'}[op];v=int({16:a.v<b.v,17:a.v>b.v,18:signed(a.v)<signed(b.v),20:a.v==b.v}[op]);t=f'(if {predicate} then 1 else 0)'
    elif op==27:v=(b.v<<a.v)%MOD if a.v<256 else 0;t=f'S.ShiftLeft({b.t},{a.t})';node['guide'].append('    D.DecoderLimit();')
    else:
     assert a.v==224;v=SELECTOR;t=str(SELECTOR);node['guide']+=['    ReadSelector(data);',f'    assert S.ShiftRight({b.t},224) == {SELECTOR};']
    push(E(v) if a.constant and b.constant else E(v,t))
   elif op==52:push(E(0))
   elif op==54:push(E(292,'|data|'))
   elif op==53:
    a=pop();b=E(SELECTOR<<224,'S.DataWord(data,0)') if a.v==0 else E(32,'relative');assert a.v in [0,4];push(b)
    if a.v==4:node['guide'].append('    assert S.DataWord(data,4) == relative;')
   elif op==81:
    a=pop()
    if name=='Prefix':assert a.v==64;push(E(128));node['guide'].append('    I.StoredWord([],64,128);')
    else:
     assert a.v==160;push(E(33,'length'));node['guide']+=[f'    MemoryFacts({args});',f'    assert S.Load({mem},160) == length;']
    node['guide'].append(f'    assert S.Expand({mem},{a.t}+32) == {mem};')
   elif op==82:
    a,b=pop(),pop();mem=f'S.Store({mem},{a.t},{b.t})';node['guide'].append(f'    I.StoredWord({node["memory"]},{a.t},{b.t});')
   elif op in [86,87]:
    destination=pop();take=op==86 or pop().v!=0;assert destination.constant and destination.v in destinations
    required[destination.v]=code[destination.v];targets.add(destination.v)
    if take:nxt=destination.v
   elif op in [243,253]:
    offset,size=pop(),pop();assert (offset.v,size.v)==(192,33);node['guide']+=[f'    MemoryFacts({args});',f'    assert G.Grow({mem},192+length) == {mem};',f'    assert {mem}[192..192+length] == data[Offset(relative,bytesRelative)..Offset(relative,bytesRelative)+length];'];break
   else:raise ValueError((pc,hex(op)))
   if name=='Prefix' and nxt==3393:break
   pc=nxt
  targetlist=','.join(map(str,sorted(targets)));constraints=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == S.Running({n["pc"]},[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
  final='S.Running(3393,['+','.join(x.t for x in s)+'],Prepared())' if name=='Prefix' else 'S.Returned(data[Offset(relative,bytesRelative)..Offset(relative,bytesRelative)+length])'
  text=f"""// SPDX-License-Identifier: MIT
// Exact public resolve physical {name.lower()} segment; symbolic bytes/length.
include "../Memory.dfy"
include "../Scalar.dfy"
include "../Frame.dfy"
include "../../../scans/Fetch.dfy"
include "../../Fetch.dfy"
module AssertionsRawPublic{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  import P = AssertionsRawResolveMemory
  import Q = AssertionsRawResolveFrame
  import I = BytecodeScanRepresentation
  import B = BytecodeCopyMemory
  import D = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import J = AssertionsConstraintFetch
  type Word = S.Word
  type Byte = S.Byte
  function Pointer(relative: Word): Word requires relative < 0x10000000000000000 {{ relative+4 }}
  function Offset(relative: Word, bytesRelative: Word): Word
    requires (relative as nat)+bytesRelative+36 < G.Modulus()
  {{ relative+bytesRelative+36 }}
  function Prepared(): seq<Byte> {{ S.Store(S.Store(S.Store([],64,128),64,160),128,0) }}
  opaque function Selector(data: seq<Byte>): Word {{ S.ShiftRight(S.DataWord(data,0),224) }}
  lemma ReadSelector(data: seq<Byte>) ensures Selector(data) == S.ShiftRight(S.DataWord(data,0),224)
  {{ reveal Selector(); }}
  predicate Admitted({params}) {{
    36 <= |data| < 0x10000000000000000 && relative < 0x10000000000000000 &&
    Selector(data) == {SELECTOR} && S.DataWord(data,4) == relative &&
    (relative as nat)+132 <= |data| && (relative as nat)+bytesRelative+36+length <= |data| &&
    (relative as nat)+constraintsRelative+36 <= |data| &&
    S.DataWord(data,relative+36) == 0 && S.DataWord(data,relative+68) == bytesRelative &&
    S.DataWord(data,relative+100) == constraintsRelative && S.DataWord(data,relative+bytesRelative+4) == length &&
    S.DataWord(data,relative+constraintsRelative+4) == 0 &&
    224+S.Round32(length) < 0x10000000000000000
  }}
  opaque function Memory({params}): seq<Byte>
    requires Admitted({args})
  {{ P.Construct(Prepared(),160,Offset(relative,bytesRelative),length,data) }}
  lemma MemoryIsConstruct({params})
    requires Admitted({args})
    ensures Memory({args}) == P.Construct(Prepared(),160,Offset(relative,bytesRelative),length,data)
  {{ reveal Memory(); }}
  lemma MemoryFacts({params})
    requires Admitted({args})
    ensures S.Load(Memory({args}),160) == length
    ensures |Memory({args})|%32 == 0 && 192+length <= |Memory({args})| < 0x10000000000000000
    ensures Memory({args})[192..192+length] == data[Offset(relative,bytesRelative)..Offset(relative,bytesRelative)+length]
    ensures S.Expand(Memory({args}),192) == Memory({args}) && G.Grow(Memory({args}),192+length) == Memory({args})
  {{
    MemoryIsConstruct({args});P.Built(Prepared(),160,Offset(relative,bytesRelative),length,data);
    B.Rounded(192);assert S.Round32(192) == 192;
  }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {constraints} }}
  function Destinations(): set<nat> {{ {{{targetlist}}} }}
  function Expected({params}): S.State requires Admitted({args}) {{ {final} }}
  opaque predicate Good(id: nat, state: S.State, {params}) {{ Admitted({args}) && (
{good}) }}
"""
  for n in states:
   i=n['id'];post=f'next == Expected({args})' if i==len(states)-1 else f'Good({i+1},next,{args})';guide='\n'.join(n['guide']);fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else f'    J.Push4(code,{n["pc"]});\n' if n['op']==99 else ''
   text+=f"""  lemma Advance{i}(code: seq<Byte>, state: S.State, {params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,0,data) != S.Bad
    ensures Q.Local(code,state)
    ensures var next := M.Step(code,Destinations(),state,0,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal M.Step(); reveal A.Step(); reveal C.Step(); reveal S.Step();
{fetch}    assert S.Fetch(code,{n['pc']}) == S.Op({n['op']},{n['next']},{n['immediate']});
{guide}
  }}
"""
  calls='\n'.join(f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args}); }}' for i in range(len(states)))
  text+=f"""  lemma Start({params}) requires Admitted({args}) ensures Good(0,S.Running({states[0]['pc']},[{','.join(states[0]['stack'])}],{states[0]['memory']}),{args})
  {{ reveal Good(); I.StoredWord([],64,128); I.StoredWord(S.Store([],64,128),64,160); }}
  lemma Advance(id: nat, code: seq<Byte>, state: S.State, {params})
    requires Matches(code) && Admitted({args}) && Good(id,state,{args}) && id < {len(states)}
    ensures M.Step(code,Destinations(),state,0,data) != S.Bad && Q.Local(code,state)
    ensures var next := M.Step(code,Destinations(),state,0,data); if id == {len(states)-1} then next == Expected({args}) else Good(id+1,next,{args})
  {{
{calls}
  }}
  ghost method Run(code: seq<Byte>, {params}) returns (state: S.State, trace: seq<S.State>)
    requires Matches(code) && Admitted({args})
    ensures state == Expected({args}) && M.Trace(code,Destinations(),0,data,trace)
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace|-1 ==> Q.Local(code,trace[i])
    ensures trace[0] == S.Running({states[0]['pc']},[{','.join(states[0]['stack'])}],{states[0]['memory']}) && trace[|trace|-1] == state
  {{
    state := S.Running({states[0]['pc']},[{','.join(states[0]['stack'])}],{states[0]['memory']});trace := [state];Start({args});
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1 && M.Trace(code,Destinations(),0,data,trace)
      invariant forall i {{:trigger trace[i]}} :: 0 <= i < |trace|-1 ==> Q.Local(code,trace[i])
      invariant trace[0] == S.Running({states[0]['pc']},[{','.join(states[0]['stack'])}],{states[0]['memory']}) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == Expected({args})
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{args});var next := M.Step(code,Destinations(),state,0,data);M.Extend(code,Destinations(),0,data,trace,next);
      trace := trace+[next];state := next;id := id+1;
    }}
  }}
}}
"""
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required},indent=2)+'\n');print(name,len(states))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
 if a.dafny:subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/format-generated.py','--output',a.output,'--include-root',HERE],env=dict(os.environ,DAFNY=str(a.dafny.resolve())),check=True)
