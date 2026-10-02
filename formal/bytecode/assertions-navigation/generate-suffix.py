#!/usr/bin/env python3
"""Exact suffixStart initialization; loop body refinement is separate."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=HERE/'development/suffix-init-v1'
OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest=hashlib.sha256(code).hexdigest()
segments=json.loads((HERE/'development/suffix-segments-v1.json').read_text())
assert digest==segments['runtimeSha256']
pcs=segments['cases'][0]['pcSequence'][:26]
stack=['ret','offset','length','ts','te'];states=[];facts={8234:91};targets=set()
for i,pc in enumerate(pcs):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big')
 facts.update({p:code[p] for p in range(pc,nxt)})
 states.append((pc,op,nxt,imm,list(stack)))
 if op==0x5b:pass
 elif op==0x5f or width:stack.append(str(imm))
 elif 0x80<=op<=0x8f:stack.append(stack[-(op-0x7f)])
 elif 0x90<=op<=0x9f:
  k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
 elif op==0x50:stack.pop()
 elif op==3:
  a,b=stack.pop(),stack.pop();assert (a,b)==('te','2');stack.append('te-2')
 elif op==0x11:
  a,b=stack.pop(),stack.pop();assert (a,b)==('te-2','te');stack.append('0')
 elif op==0x15:
  a=stack.pop();assert a=='0';stack.append('1')
 elif op in {0x56,0x57}:
  target=stack.pop();targets.add(int(target));facts[int(target)]=code[int(target)]
  if op==0x57:assert stack.pop()=='1'
  assert int(target)==(pcs[i+1] if i+1<len(pcs) else 8234)
 else:raise ValueError((pc,op,stack))
assert stack==['ret','offset','length','ts','te','te-2'],stack
params='ret: Word, offset: Word, length: Word, ts: Word, te: Word, prefix: seq<Word>, mem: seq<Byte>'
args='ret,offset,length,ts,te,prefix,mem'
terminal='Running(8234,prefix+[ret,offset,length,ts,te,te-2],mem)'
s=f'''// SPDX-License-Identifier: MIT
// Exact physical initialization. This alone does not certify the suffix loop.
include "{HERE/'Frame.dfy'}"
include "{HERE.parent/'scans/Execution.dfy'}"
module AssertionsNavigationSuffixInit {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationFrame
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  predicate Admitted({params}) {{ 2 <= te && |prefix| <= 980 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
'''
s+='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},prefix+[{",".join(st)}],mem)' for i,(pc,op,nxt,imm,st) in enumerate(states))+'\n    else false) }\n'
for i,(pc,op,nxt,imm,st) in enumerate(states):
 post=terminal if i==len(states)-1 else f'Running({states[i+1][0]},prefix+[{",".join(states[i+1][4])}],mem)'
 extra=f'    F.Push{width}(code,{pc});\n' if (width:=op-95 if 96<=op<=127 else 0) else ''
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args}) && {{{','.join(map(str,sorted(targets)))}}} <= destinations
    ensures H.Local(code,state)
    ensures Step(code,destinations,state,value,data) == {post}
    ensures {f'Good({i+1},Step(code,destinations,state,value,data),{args})' if i+1<len(states) else 'true'}
  {{ reveal Matches(); reveal Good(); reveal Step(); reveal H.Local();
{extra}    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
s+=f'''  lemma Advance(id: nat,code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && id < {len(states)} && Good(id,state,{args}) && {{{','.join(map(str,sorted(targets)))}}} <= destinations
    ensures H.Local(code,state)
    ensures id+1 < {len(states)} ==> Good(id+1,Step(code,destinations,state,value,data),{args})
    ensures id+1 == {len(states)} ==> Step(code,destinations,state,value,data) == {terminal}
  {{
'''
for i in range(len(states)):
 s+=('    if ' if i==0 else '    else if ')+f'id == {i} {{ Advance{i}(code,destinations,state,{args},value,data); }}\n'
s+=f'''  }}
  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params},value: Word,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && {{{','.join(map(str,sorted(targets)))}}} <= destinations
    ensures state == {terminal}
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8219,prefix+[ret,offset,length,ts,te],mem) && trace[|trace|-1] == state
    ensures forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {{
    reveal Good();
    state := Running(8219,prefix+[ret,offset,length,ts,te],mem); trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8219,prefix+[ret,offset,length,ts,te],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == {terminal}
      invariant forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
      decreases {len(states)}-id
    {{
      Advance(id,code,destinations,state,{args},value,data);
      var next := Step(code,destinations,state,value,data);
      E.Extend(code,destinations,value,data,trace,next);
      assert forall k {{:trigger (trace+[next])[k]}} :: 0 <= k < |trace| ==> H.Local(code,(trace+[next])[k]);
      trace := trace+[next]; state := next; id := id+1;
    }}
  }}
}}\n''' 
(OUT/'Init.dfy').write_text(s)
(OUT/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'terminal':terminal,'requiredBytes':facts,'targets':sorted(targets),'scope':'26 initialization instructions only, arbitrary representable te >=2; loop and descriptor semantic caller remain open.'},indent=2)+'\n')
print(len(states),'physical initialization instructions')
