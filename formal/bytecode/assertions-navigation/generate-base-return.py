#!/usr/bin/env python3
"""Generate physical scanName character iteration; fixture PCs are discovery only."""
from pathlib import Path
import json,hashlib,sys
EXIT=True; LIMIT="--limit" in sys.argv
MODULE="AssertionsNavigationBaseLimitReturn" if LIMIT else "AssertionsNavigationBaseByteReturn"
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]
OUT=HERE/('development/base-limit-return-v1' if LIMIT else 'development/base-byte-return-v1');OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
assert hashlib.sha256(code).hexdigest()==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
rows=json.loads((HERE/'development/name-class-gates-v1/evm/case-2.json').read_text())['trace']['structLogs']
start=next(i for i,r in enumerate(rows) if r['pc']==8882 and (int(r['stack'][-4],16)==int(r['stack'][-3],16))==LIMIT)
ret=int(rows[start]['stack'][-8],16)
end=next(i for i in range(start+1,len(rows)) if rows[i]['pc']==ret)
pcs=[r['pc'] for r in rows[start:end]]
stack=['ret','offset','length','p','limit','q','dyn','1']; states=[];facts={};targets=set();extras={}
for i,pc in enumerate(pcs):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({k:code[k] for k in range(pc,nxt)});states.append((pc,op,nxt,imm,list(stack)));extra=[]
 def pop():return stack.pop()
 if op==91:pass
 elif op==95 or width:stack.append(str(imm))
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:
  k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
 elif op==80:pop()
 elif op==1:
  a,b=pop(),pop();assert {a,b}=={'offset','q'};stack.append('offset+q')
 elif op==20:
  a,b=pop(),pop();stack.append(f'(if {a} == {b} then 1 else 0)')
 elif op in {16,17}:
  a,b=pop(),pop();stack.append(f'(if {a} {"<" if op==16 else ">"} {b} then 1 else 0)')
 elif op==21:
  a=pop();stack.append(f'(if {a} == 0 then 1 else 0)')
 elif op==53:
  assert pop()=='offset+q';stack.append('DataWord(data,offset+q)')
 elif op==26:
  assert pop()=='0' and pop()=='DataWord(data,offset+q)';stack.append('data[offset+q]');extra.append('    R.Read(data,offset+q);')
 elif op in {22,23}:
  a,b=pop(),pop();extra.append(f'    T.{"And" if op==22 else "Or"}({a},{b});');stack.append(f'(if {a} == 1 {"&&" if op==22 else "||"} {b} == 1 then 1 else 0)')
 elif op in {86,87}:
  dest=pop()
  if dest=='ret':
   assert EXIT and op==86 and i+1==len(pcs);extras[i]='';continue
  assert dest.isdecimal();targets.add(int(dest));facts[int(dest)]=code[int(dest)]
  if op==87:pop()
 else:raise ValueError((pc,op))
 extras[i]='\n'.join(extra)
assert stack==['q','dyn','1'],stack
terminal='Running(ret,prefix+[q,dyn,1],mem)'
retPre=' && ret in destinations && ret < |code| && code[ret] == 91'
admission='p < q == limit <= length' if LIMIT else 'p < q < limit <= length'
character=' && dyn <= 1'+('' if LIMIT else ' && data[offset+q] != 91')
params='ret: Word,offset: Word,length: Word,p: Word,limit: Word,q: Word,dyn: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>';args='ret,offset,length,p,limit,q,dyn,prefix,mem,data'
s=f'''// SPDX-License-Identifier: MIT
// Exact physical character iteration for arbitrary lowercase ASCII letters or digits.
include "{HERE/'Name.dfy'}"
include "{HERE/'ByteOpcode.dfy'}"
include "{HERE/'BooleanBits.dfy'}"
include "{HERE/'NameFrame.dfy'}"
include "{HERE/'NameTrace.dfy'}"
include "{HERE/'TypeConstants.dfy'}"
module {MODULE} {{
  import opened BytecodeScanMachine
  import K = AssertionsNavigationTypeConstants
  import G = BytecodeGetterMachine
  import A = AssertionsSignedMachine
  import B = AssertionsByteMachine
  import R = AssertionsNavigationByteOpcode
  import T = AssertionsNavigationBooleanBits
  import N = AssertionsNavigationName
  import H = AssertionsNavigationNameFrame
  import E = AssertionsNavigationNameTrace
  import F = BytecodeScanFetch
  predicate Admitted({params}) {{ {admission} && (offset as nat)+length <= |data| < 0x10000000000000000{character} && |prefix| <= 960 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{k}] == {v}' for k,v in sorted(facts.items()))} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
'''
s+='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},prefix+[{",".join(st)}],mem)' for i,(pc,op,nxt,imm,st) in enumerate(states))+'\n    else false) }\n'
for i,(pc,op,nxt,imm,st) in enumerate(states):
 post=terminal if i+1==len(states) else f'Running({states[i+1][0]},prefix+[{",".join(states[i+1][4])}],mem)'
 extra=extras[i]
 if op!=26:extra='    B.Delegate(code,destinations,state,value,data);\n    A.Delegate(code,destinations,state,value,data);\n    reveal Step();\n'+extra
 else:extra='    reveal B.Step();\n'+extra
 if 96<=op<=127:extra=f'    F.Push{op-95}(code,{pc});\n'+extra
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args}) && {{{','.join(map(str,sorted(targets)))}}} <= destinations{retPre}
    ensures H.Local(code,state)
    ensures B.Step(code,destinations,state,value,data) == {post}
  {{
    reveal Matches(); reveal Good(); reveal H.Local(); reveal AssertionsNavigationFrame.Local();
    hide DataWord(); hide BitNot(); hide G.BitAnd(); hide G.BitOr();
{extra}
    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
targetSet='{'+','.join(map(str,sorted(targets)))+'}'
s+=f"""  lemma Advance(id: nat,code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && id < {len(states)} && Good(id,state,{args}) && {targetSet} <= destinations{retPre}
    ensures H.Local(code,state)
    ensures id+1 < {len(states)} ==> Good(id+1,B.Step(code,destinations,state,value,data),{args})
    ensures id+1 == {len(states)} ==> B.Step(code,destinations,state,value,data) == {terminal}
  {{
    reveal Good();
"""
for i in range(len(states)):
 s+=('    if ' if i==0 else '    else if ')+f'id == {i} {{ Advance{i}(code,destinations,state,{args},value); }}\n'
s+=f"""  }}
  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params},value: Word) returns (trace: seq<State>)
    requires Matches(code) && Admitted({args}) && {targetSet} <= destinations{retPre}
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,q,dyn,1],mem)
    ensures trace[|trace|-1] == {terminal}
    ensures forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {{
    reveal Good();
    var state := Running(8882,prefix+[ret,offset,length,p,limit,q,dyn,1],mem);
    trace := [state]; var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8882,prefix+[ret,offset,length,p,limit,q,dyn,1],mem)
      invariant trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == {terminal}
      invariant forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
      decreases {len(states)}-id
    {{
      Advance(id,code,destinations,state,{args},value);
      var next := B.Step(code,destinations,state,value,data);
      assert next.Running? by {{ reveal Good(); }}
      E.Extend(code,destinations,value,data,trace,next);
      forall k {{:trigger (trace+[next])[k]}} | 0 <= k < |trace|
        ensures H.Local(code,(trace+[next])[k])
      {{ if k < |trace|-1 {{ assert (trace+[next])[k] == trace[k]; }} }}
      trace := trace+[next]; state := next; id := id+1;
    }}
  }}
"""
s+='}\n'
# Use a local import for the ordinary local-state predicate.
s=s.replace('  import H = AssertionsNavigationNameFrame','  import Q = AssertionsNavigationFrame\n  import H = AssertionsNavigationNameFrame').replace('reveal AssertionsNavigationFrame.Local();','reveal Q.Local();')
(OUT/'Character.dfy').write_text(s)
(OUT/'inventory.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'pcSequence':pcs,'destinations':sorted(targets),'instructionCount':len(states),'scope':'Single arbitrary admitted scanner segment; not full descriptor parsing.'},indent=2)+'\n')
print(len(states),'physical instructions')
