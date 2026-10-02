#!/usr/bin/env python3
"""Decode the exact Param[] compiler element helper, including signed-offset branches."""
import json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
ins={};pc=0
while pc<len(code):
 op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
dests={pc for pc,(op,_,_) in ins.items() if op==91}
common='''// SPDX-License-Identifier: MIT
// Independent physical calldata element rule; signed ABI offsets stay explicit.
include "../../scans/Scalar.dfy"
module AssertionsGatherElementSpec {
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import P = BytecodeScanScalar
  function RuntimeDestinations(): set<nat> { %s }
  function Bound(data: seq<S.Byte>, base: G.Word): G.Word { (|data|+2*G.Modulus()-base-127)%%G.Modulus() }
  predicate Accepts(data: seq<S.Byte>, slot: G.Word, base: G.Word) {
    G.Signed(S.DataWord(data,slot)) < G.Signed(Bound(data,base))
  }
  function Pointer(data: seq<S.Byte>, slot: G.Word, base: G.Word): G.Word { (base+S.DataWord(data,slot))%%G.Modulus() }
  lemma Complement126()
    ensures S.BitNot(126) == G.Modulus()-127
  {
    P.Narrow(126);
    assert !(126 as bv256) == 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81;
  }
  lemma Budget(data: seq<S.Byte>, base: G.Word)
    requires |data| < G.Modulus()
    ensures ((S.BitNot(126) as nat)+((|data|+G.Modulus()-base)%%G.Modulus()))%%G.Modulus() == Bound(data,base)
  { Complement126(); }
}
''' % ('{'+','.join(map(str,sorted(dests)))+'}')
(HERE/'ElementSpec.dfy').write_text(common)
params='ret: Word, slot: Word, base: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>'
args='ret,slot,base,prefix,mem,data'
for success in [True,False]:
 name='ElementSuccess' if success else 'ElementFailure';module='AssertionsGather'+name
 stack=['ret','slot','base'];pc=17803;rows=[];required={}
 while True:
  op,nxt,imm=ins[pc]
  for p in range(pc,nxt):required[p]=code[p]
  rows.append(dict(id=len(rows),pc=pc,op=op,next=nxt,immediate=imm,stack=stack.copy()))
  if op==91:pass
  elif op==95 or 96<=op<=127:stack.append(str(imm))
  elif 128<=op<=143:stack.append(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x35:off=stack.pop();stack.append('DataWord(data,'+off+')')
  elif op==0x36:stack.append('|data|')
  elif op==0x19:word=stack.pop();stack.append('BitNot('+word+')')
  elif op in [1,3]:
   a,b=stack.pop(),stack.pop();stack.append(f'(({a} as nat)+'+('' if op==1 else 'G.Modulus()-')+f'({b} as nat))%G.Modulus()')
  elif op==0x12:
   a,b=stack.pop(),stack.pop();stack.append(f'(if G.Signed({a}) < G.Signed({b}) then 1 else 0)')
  elif op==0x57:
   dest,truth=stack.pop(),stack.pop();required[int(dest)]=code[int(dest)];nxt=int(dest) if success else nxt
  elif op==0xfd:terminal='Reverted([])';break
  elif op==0x56:stack.pop();terminal='Running(ret,prefix+['+','.join(stack)+'],mem)';break
  else:raise Exception(op)
  pc=nxt
 matched=' && '.join(f'code[{p}] == {b}' for p,b in sorted(required.items()))
 admitted=f'|data| < G.Modulus() && |prefix| <= 980 && ret in D.RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && '+('D.Accepts(data,slot,base)' if success else '!D.Accepts(data,slot,base)')
 good='\n'.join(('    if' if i==0 else '    else if')+f' id == {i} then state == Running({r["pc"]},prefix+['+','.join(r['stack'])+'],mem)' for i,r in enumerate(rows))
 text=f'''// SPDX-License-Identifier: MIT
// Generated exact physical element decoder path; full signed input words.
include "ElementSpec.dfy"
include "../../scans/Execution.dfy"
module {module} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import D = AssertionsGatherElementSpec
  opaque predicate Matches(code: seq<Byte>) {{ |code| == 20049 && {matched} }}
  function Destinations(ret: Word): set<nat> {{ {{ret,17823}} }}
  predicate Admitted(code: seq<Byte>, {params}) {{ {admitted} }}
  opaque predicate Good(id: nat, state: State, code: seq<Byte>, {params}) {{
    Admitted(code,{args}) && (
{good}
    else false)
  }}
'''
 for i,r in enumerate(rows):
  post=f'Good({i+1},Step(code,Destinations(ret),state,value,data),code,{args})' if i<len(rows)-1 else f'Step(code,Destinations(ret),state,value,data) == {terminal}'
  push=''
  if r['op']==0x60:push=f'    F.Push1(code,{r["pc"]});\n'
  if r['op']==0x61:push=f'    F.Push2(code,{r["pc"]});\n'
  text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, value: Word)
    requires Matches(code) && Good({i},state,code,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures Step(code,Destinations(ret),state,value,data) != Bad && {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{push}    assert state == Running({r['pc']},prefix+[{','.join(r['stack'])}],mem);
    assert Fetch(code,{r['pc']}) == Op({r['op']},{r['next']},{r['immediate']});
'''
  if r['op'] in [0x12,0x57]:text+='    D.Budget(data,base);\n'
  text+='  }\n'
 text+=f'''  lemma Advance(id: nat, code: seq<Byte>, state: State, {params}, value: Word)
    requires Matches(code) && id < {len(rows)} && Good(id,state,code,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000 && Step(code,Destinations(ret),state,value,data) != Bad
    ensures id < {len(rows)-1} ==> Good(id+1,Step(code,Destinations(ret),state,value,data),code,{args})
    ensures id == {len(rows)-1} ==> Step(code,Destinations(ret),state,value,data) == {terminal}
  {{
'''+ '\n'.join(('    if' if i==0 else '    else if')+f' id == {i} {{ Advance{i}(code,state,{args},value); }}' for i in range(len(rows)))+f'''
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {terminal}
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures |trace| == {len(rows)+1} && trace[0] == Running(17803,prefix+[ret,slot,base],mem) && trace[|trace|-1] == state
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
  {{
    reveal Good();
    state := Running(17803,prefix+[ret,slot,base],mem); trace := [state];
    var id: nat := 0;
    while id < {len(rows)}
      invariant id <= {len(rows)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == Running(17803,prefix+[ret,slot,base],mem) && trace[|trace|-1] == state
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
      invariant id < {len(rows)} ==> Good(id,state,code,{args})
      invariant id == {len(rows)} ==> state == {terminal}
      decreases {len(rows)}-id
    {{
      Advance(id,code,state,{args},value);
      var next := Step(code,Destinations(ret),state,value,data);
      E.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next]; state := next; id := id+1;
    }}
  }}
}}
'''
 (HERE/(name+'.generated.dfy')).write_text(text)
 (HERE/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),states=rows,requiredBytes=required,terminal=terminal),indent=2)+'\n')
 print(name,len(rows))
