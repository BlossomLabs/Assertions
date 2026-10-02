#!/usr/bin/env python3
"""Generate a physical typeShape dynamic-element fixed-array suffix completion; fixtures discover PCs only."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]
MODULE="AssertionsNavigationArrayDynamicFinish"
OUT=HERE/'development/array-dynamic-finish-v1';OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
assert hashlib.sha256(code).hexdigest()==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
rows=json.loads((HERE/'development/array-shape-gates-v1/evm/case-1.json').read_text())['trace']['structLogs']
start=next(i for i,r in enumerate(rows) if r['pc']==9047)
end=next(i for i in range(start+1,len(rows)) if rows[i]['pc']==8882)
pcs=[r['pc'] for r in rows[start:end]]
stack=['ret','offset','length','p','limit','end','dyn','words','q','k','end+1'];initial=list(stack)
states=[];facts={};targets=set();extras={}
for i,pc in enumerate(pcs):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({at:code[at] for at in range(pc,nxt)});states.append((pc,op,nxt,imm,list(stack)));extra=[]
 def pop():return stack.pop()
 if op==91:pass
 elif op==95 or width:stack.append(str(imm))
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:
  depth=op-143;stack[-1],stack[-1-depth]=stack[-1-depth],stack[-1]
 elif op==80:pop()
 elif op in {1,2,3,4}:
  a,b=pop(),pop()
  if op==1:
   if {a,b}=={'offset','q'}:result='offset+q'
   elif {a,b}=={'q','1'}:result='q+1'
   else:result=f'({a}+{b})'
  elif op==2:
   assert {a,b}=={'words','k'};extra.append('    V.ProductStep(words,k);');result='V.Product(words,k)'
  elif op==3:result=f'(({a})-({b}))'
  else:
   assert b=='words' and a=='V.Product(words,k)';extra.append('    V.ProductNatural(words,k);\n    V.ProductDivide(words,k);');result='k'
  stack.append(result)
 elif op in {16,17,20}:
  a,b=pop(),pop();comparison='<' if op==16 else '>' if op==17 else '=='
  stack.append(f'(if {a} {comparison} {b} then 1 else 0)')
 elif op==21:
  a=pop();stack.append(f'(if {a} == 0 then 1 else 0)')
 elif op==53:
  assert pop()=='offset+q';stack.append('DataWord(data,offset+q)')
 elif op==26:
  assert pop()=='0' and pop()=='DataWord(data,offset+q)';stack.append('data[offset+q]');extra.append('    R.Read(data,offset+q);')
 elif op==22:
  a,b=pop(),pop();assert '255' in {a,b};value=b if a=='255' else a
  extra.append(f'    U.Mask({value});');stack.append(value)
 elif op==23:
  a,b=pop(),pop()
  if a.startswith('(if') and b.startswith('(if'):
   extra.append(f'    T.Or({a},{b});');stack.append(f'(if {a} == 1 || {b} == 1 then 1 else 0)')
  else:
   extra.append(f'    V.OrBound({a},{b});');stack.append(f'G.BitOr({a},{b})')
 elif op in {86,87}:
  dest=pop();assert dest.isdecimal();targets.add(int(dest));facts[int(dest)]=code[int(dest)]
  if op==87:pop()
 else:raise ValueError((pc,op))
 extras[i]='\n'.join(extra)
assert stack[:5]==initial[:5] and len(stack)==8 and stack[5]=='q+1',stack
print('terminal expressions:',stack[-2:])
terminal='Running(8882,prefix+['+','.join(stack)+'],mem)'
retPre=''
admission='p <= end && end+1 < q < limit <= length'
character=' && dyn == 1 && words == 1 && 1 <= k <= 4294967295 && words*k <= 4294967295 && data[offset+q] == 93'
params='ret: Word,offset: Word,length: Word,p: Word,limit: Word,end: Word,dyn: Word,words: Word,q: Word,k: Word,prefix: seq<Word>,mem: seq<Byte>,data: seq<Byte>'
args='ret,offset,length,p,limit,end,dyn,words,q,k,prefix,mem,data'
s=f'''// SPDX-License-Identifier: MIT
// Exact physical decimal dynamic-element fixed-array suffix completion for arbitrary bounded accumulators.
include "{HERE/'Name.dfy'}"
include "{HERE/'ByteOpcode.dfy'}"
include "{HERE/'BooleanBits.dfy'}"
include "{HERE/'NameFrame.dfy'}"
include "{HERE/'NameTrace.dfy'}"
include "{HERE/'ArrayByteMask.dfy'}"
include "{HERE/'ArraySizeMath.dfy'}"
include "{HERE/'../scans/Push.dfy'}"
module {MODULE} {{
  import opened BytecodeScanMachine
  import U = AssertionsNavigationArrayByteMask
  import V = AssertionsNavigationArraySizeMath
  import PN = BytecodeScanPush
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
 if op!=26:extra='    V.ProductNatural(words,k);\n    V.OrBound(V.Product(words,k),k);\n    V.OrBound(words,k);\n    B.Delegate(code,destinations,state,value,data);\n    A.Delegate(code,destinations,state,value,data);\n    reveal Step();\n'+extra
 else:extra='    reveal B.Step();\n'+extra
 if 96<=op<=127:extra=f'    {"PN" if op==99 else "F"}.Push{op-95}(code,{pc});\n'+extra
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
    ensures trace[0] == Running(9047,prefix+[ret,offset,length,p,limit,end,dyn,words,q,k,end+1],mem)
    ensures trace[|trace|-1] == {terminal}
    ensures forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> H.Local(code,trace[k])
  {{
    reveal Good();
    var state := Running(9047,prefix+[ret,offset,length,p,limit,end,dyn,words,q,k,end+1],mem);
    trace := [state]; var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(9047,prefix+[ret,offset,length,p,limit,end,dyn,words,q,k,end+1],mem)
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
(OUT/'inventory.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'pcSequence':pcs,'destinations':sorted(targets),'instructionCount':len(states),'scope':'Single arbitrary physical dynamic-element fixed-array suffix completion; not whole descriptor parsing.'},indent=2)+'\n')
print(len(states),'physical instructions')
