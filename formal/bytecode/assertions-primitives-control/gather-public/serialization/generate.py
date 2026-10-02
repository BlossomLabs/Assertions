#!/usr/bin/env python3
"""Symbolic exact compiled bytes encoder PC17270 -> scanned caller return."""
import json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest=='84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903'
rows=[];facts={};stack=['ret','dst','src'];memory='mem';mems=[];pc=17270
while pc<17316:
 op=code[pc];w=op-95 if 96<=op<=127 else 0;nxt=pc+1+w;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});rows.append({'id':len(rows),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':stack.copy(),'memory':memory})
 def pop():return stack.pop()
 if op==91:pass
 elif op==95 or 96<=op<=127:stack.append(str(imm))
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
 elif op==80:pop()
 elif op==0x51:assert pop()=='src';stack.append('length')
 elif op==0x52:
  off,value=pop(),pop();before=memory;memory='Memory'+str(len(mems)+1)+'(mem,dst,src,length)';mems.append((memory,f'S.Store({before},{off},{value})'))
 elif op==0x5e:
  dst,src,length=pop(),pop(),pop();before=memory;memory='Memory'+str(len(mems)+1)+'(mem,dst,src,length)';mems.append((memory,f'CM.Memory({before},{dst},{src},{length})'))
 elif op==1:
  a,b=pop(),pop();stack.append(str((int(a)+int(b))%M) if a.isdecimal() and b.isdecimal() else f'(({a} as nat)+({b} as nat))%G.Modulus()')
 elif op==0x19:assert pop()=='31';stack.append('G.Modulus()-32')
 elif op==0x16:assert pop()=='((length as nat)+(31 as nat))%G.Modulus()';assert pop()=='G.Modulus()-32';stack.append('S.Round32(length)')
 elif op==0x56:assert pop()=='ret';assert len(stack)==1;break
 else:raise ValueError((pc,op,stack))
 pc=nxt
params='ret: Word,dst: Word,src: Word,length: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>,value: Word';args='ret,dst,src,length,prefix,mem,data,value';imgargs='mem,dst,src,length';state=lambda r:'S.Running('+str(r['pc'])+',prefix+['+','.join(r['stack'])+'],'+r['memory']+')'
good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
// Exact physical encoder for arbitrary-length bytes, including MCOPY and padding.
include "Spec.dfy"
include "../../../assertions-resolution/raw/Machine.dfy"
include "../../../scans/Push.dfy"
include "../../../assertions-resolution/raw/Frame.dfy"
module AssertionsGatherBytesEncoder {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import C = AssertionsRawResolveMachine
  import CP = BytecodeCopyMachine
  import CM = BytecodeCopyMemory
  import A = AssertionsSignedMachine
  import D = AssertionsGatherBytesSpec
  import DS = AssertionsGatherCallerSpec
  import RF = AssertionsRawResolveFrame
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>,ret: Word) {{ ret < |code| && code[ret] == 0x5b && |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(ret: Word): set<nat> {{ {{ret}} }}
  opaque predicate Admitted({params}) {{ |prefix| <= 960 && ret in DS.RuntimeDestinations() && D.Heap(mem,dst,src,length) }}
'''
for f,body in mems:s+=f'  function {f.split("(")[0]}({imgargs.replace("mem","mem: seq<Byte>").replace("dst","dst: Word").replace("src","src: Word").replace("length","length: Word")}): seq<Byte> {{ {body} }}\n'
s+=f'  opaque predicate Good(id: nat,state: S.State,{params})\n    requires D.Heap(mem,dst,src,length)\n  {{ Admitted({args}) && (\n{good}) }}\n'
for i,r in enumerate(rows):
 post=state(rows[i+1]) if i<len(rows)-1 else 'S.Running(ret,prefix+[D.End(dst,length)],Memory3(mem,dst,src,length))'
 push=''
 if 96<=r['op']<=127:width=r['op']-95;push=f'    F.Push{width}(code,{r["pc"]});\n'
 extra='    D.Allocation(length);\n' if r['op'] in [0x19,0x16] else ''
 s+=f'''  lemma Advance{i}(code: seq<Byte>,state: S.State,{params})
    requires D.Heap(mem,dst,src,length) && Matches(code,ret) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000 && RF.Local(code,state)
    ensures C.Step(code,Destinations(ret),state,value,data) == {post}
  {{
    reveal Admitted(); reveal Good(); reveal Matches(); D.Bounds(mem,dst,src,length);
    reveal C.Step(); reveal A.Step(); reveal CP.Step(); reveal S.Step();
    hide G.BitAnd(); hide S.BitNot(); hide S.Load(); hide S.DataWord(); hide G.Decode();
{extra}{push}    assert S.Fetch(code,{r['pc']}) == S.Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
s+=f'''  lemma Advance(id: nat,code: seq<Byte>,state: S.State,{params})
    requires D.Heap(mem,dst,src,length) && id < {len(rows)} && Matches(code,ret) && Admitted({args}) && Good(id,state,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000 && RF.Local(code,state)
    ensures C.Step(code,Destinations(ret),state,value,data) != S.Bad
    ensures id+1 < {len(rows)} ==> Good(id+1,C.Step(code,Destinations(ret),state,value,data),{args})
    ensures id+1 == {len(rows)} ==> C.Step(code,Destinations(ret),state,value,data) == S.Running(ret,prefix+[D.End(dst,length)],Memory3(mem,dst,src,length))
  {{ reveal Good();
'''
for i in range(len(rows)):s+=f'    {"if" if i==0 else "else if"} id == {i} {{ Advance{i}(code,state,{args}); }}\n'
s+=f'''  }}
  ghost method Run(code: seq<Byte>,{params}) returns (state: S.State,trace: seq<S.State>)
    requires D.Heap(mem,dst,src,length) && Matches(code,ret) && Admitted({args})
    ensures C.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == S.Running(17270,prefix+[ret,dst,src],mem) && trace[|trace|-1] == state
    ensures state == S.Running(ret,prefix+[D.End(dst,length)],Memory3(mem,dst,src,length))
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000 && RF.Local(code,trace[j])
  {{
    reveal Admitted(); reveal Good(); state := S.Running(17270,prefix+[ret,dst,src],mem); trace := [state]; var id: nat := 0;
    while id < {len(rows)}
      invariant id <= {len(rows)} && |trace| == id+1
      invariant C.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == S.Running(17270,prefix+[ret,dst,src],mem) && trace[|trace|-1] == state
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000 && RF.Local(code,trace[j])
      invariant id < {len(rows)} ==> Good(id,state,{args})
      invariant id == {len(rows)} ==> state == S.Running(ret,prefix+[D.End(dst,length)],Memory3(mem,dst,src,length))
      decreases {len(rows)}-id
    {{
      Advance(id,code,state,{args}); var next := C.Step(code,Destinations(ret),state,value,data);
      C.Extend(code,Destinations(ret),value,data,trace,next); trace := trace+[next]; state := next; id := id+1;
    }}
  }}
}}
'''
(HERE/'Bytes.generated.dfy').write_text(s);(HERE/'Bytes.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts,'terminal':post},indent=2)+'\n');print(len(rows),'physical instructions')
