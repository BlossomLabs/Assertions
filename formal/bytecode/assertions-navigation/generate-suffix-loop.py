#!/usr/bin/env python3
"""Generate arbitrary-index physical suffix digit iteration, not a finite fixture proof."""
from pathlib import Path
import json,hashlib,sys
EXIT="--exit" in sys.argv
SAMPLE_BYTE=91 if EXIT else 49
MODULE="AssertionsNavigationSuffixExit" if EXIT else "AssertionsNavigationSuffixDigit"
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];OUT=HERE/(('development/suffix-exit-' if EXIT else 'development/suffix-digit-')+('v6' if '--v6' in sys.argv else 'v5' if '--v5' in sys.argv else 'v4' if '--v4' in sys.argv else 'v3' if '--v3' in sys.argv else 'v2' if '--v2' in sys.argv else 'v1'));OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();seg=json.loads((HERE/'development/suffix-segments-v1.json').read_text());assert digest==seg['runtimeSha256'];case=seg['cases'][0];pcs=case['pcSequence'][126:] if EXIT else case['pcSequence'][26:126];MOD=1<<256;FACTOR=1<<248
# Numeric witnesses choose branch discovery only. All resulting native obligations use arbitrary calldata and j.
stack=[(9234,'ret'),(356,'offset'),(12,'length'),(1,'ts'),(11,'te'),(8 if EXIT else 9,'j')];states=[];facts={8234:91};targets=set();extras={}
for i,pc in enumerate(pcs):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});states.append((pc,op,nxt,imm,[t for _,t in stack]));extra=[]
 def pop():return stack.pop()
 def push(n,t=None):stack.append((n,str(n) if t is None else t))
 if op==91:pass
 elif op==95 or width:push(imm)
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:
  k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
 elif op==80:pop()
 elif op in {1,3}:
  (a,at),(b,bt)=pop(),pop();n=(a+b if op==1 else a-b)%MOD
  if at.isdecimal() and bt.isdecimal():push(n)
  elif op==1 and {at,bt}=={'offset','j'}:push(n,'offset+j')
  elif op==1 and {at,bt}=={'j',str(MOD-1)}:push(n,'j-1')
  else:raise ValueError(('unhandled arithmetic',pc,at,bt))
 elif op in {16,17,20}:
  (a,at),(b,bt)=pop(),pop();push(int(a<b if op==16 else a>b if op==17 else a==b))
 elif op==21:a,at=pop();push(int(a==0))
 elif op==25:
  a,at=pop();assert at.isdecimal();push(MOD-1-a)
  assert a in {0,FACTOR-1}
  extra.append('    C.AllOnes();' if a==0 else '    C.LowMask();')
 elif op==53:
  a,at=pop();assert at=='offset+j';push(SAMPLE_BYTE*FACTOR,'DataWord(data,offset+j)')
 elif op in {27,28}:
  (a,at),(b,bt)=pop(),pop();assert at.isdecimal()
  if bt.isdecimal():push(((b<<a)%MOD) if op==27 else b>>a);extra.append(f'    assert {"ShiftLeft" if op==27 else "ShiftRight"}({bt},{at}) == {stack[-1][1]} by {{ reveal ShiftLeft(); reveal G.Shift(); }}')
  elif op==28 and bt=='DataWord(data,offset+j)' and a==248:
   push(SAMPLE_BYTE,'data[offset+j]');extra.append('    B.Calldata(data,offset+j);')
  elif op==27 and bt=='data[offset+j]' and a==248:
   push(SAMPLE_BYTE*FACTOR,'(data[offset+j] as nat)*Factor()');extra.append('    B.Left(data[offset+j]);')
  else:raise ValueError(('unhandled shift',pc,at,bt))
 elif op==22:
  (a,at),(b,bt)=pop(),pop();assert a==MOD-FACTOR and bt=='(data[offset+j] as nat)*Factor()';push(b,bt);extra.append('    H.Mask(data[offset+j],0);\n    T.Commute((data[offset+j] as nat)*Factor(),'+str(MOD-FACTOR)+');')
 elif op in {86,87}:
  a,at=pop()
  if at=='ret':
   assert EXIT and op==86 and i+1==len(pcs);extras[i]='';continue
  assert at.isdecimal();targets.add(a);facts[a]=code[a]
  take=op==86 or pop()[0]!=0
  assert (a if take else nxt)==(pcs[i+1] if i+1<len(pcs) else 8234),(pc,a,take)
 else:raise ValueError((pc,op))
 extras[i]='\n'.join(extra)
assert [t for _,t in stack]==(['j'] if EXIT else ['ret','offset','length','ts','te','j-1']),stack
params='ret: Word, offset: Word, length: Word, ts: Word, te: Word, j: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>';args='ret,offset,length,ts,te,j,prefix,mem,data'
s=f'''// SPDX-License-Identifier: MIT
// Physical one-digit loop refinement for arbitrary admitted calldata and index.
include "{HERE/'ByteRead.dfy'}"
include "{HERE/'BitMath.dfy'}"
include "{HERE/'Constants.dfy'}"
include "{HERE/'Frame.dfy'}"
include "{HERE.parent/'scans/Execution.dfy'}"
module {MODULE} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import B = AssertionsNavigationByteRead
  import H = AssertionsNavigationHighByte
  import T = AssertionsNavigationBitMath
  import C = AssertionsNavigationConstants
  import Q = AssertionsNavigationFrame
  import F = BytecodeScanFetch{chr(10)+'  import E = BytecodeScanExecution' if '--v6' in sys.argv else ''}
  function Factor(): nat {{ {FACTOR} }}
  predicate Admitted({params}) {{ ts < j && j+2 <= te <= length && (offset as nat)+length <= |data| < 0x10000000000000000 && {"data[offset+j] == 91" if EXIT else "48 <= data[offset+j] <= 57"} && |prefix| <= 980 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
'''
s+='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},prefix+[{",".join(st)}],mem)' for i,(pc,op,nxt,imm,st) in enumerate(states))+'\n    else false) }\n'
for i,(pc,op,nxt,imm,st) in enumerate(states):
 post=('Running(ret,prefix+[j],mem)' if EXIT else 'Running(8234,prefix+[ret,offset,length,ts,te,j-1],mem)') if i+1==len(states) else f'Running({states[i+1][0]},prefix+[{",".join(states[i+1][4])}],mem)'
 width=op-95 if 96<=op<=127 else 0
 extra=(f'    F.Push{width}(code,{pc});\n' if width else '')+extras[i]
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args}) && {{{','.join(map(str,sorted(targets)))}}} <= destinations {'&& ret in destinations && ret < |code| && code[ret] == 91' if EXIT else ''}
    ensures Q.Local(code,state)
    ensures Step(code,destinations,state,value,data) == {post}
    ensures {f'Good({i+1},Step(code,destinations,state,value,data),{args})' if i+1<len(states) else 'true'}
  {{ reveal Matches(); reveal Good(); reveal Step(); reveal Q.Local();
    hide BitNot(); hide DataWord(); hide ShiftRight(); hide ShiftLeft(); hide G.BitAnd(); hide G.Shift();
{extra}
    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
if '--v6' in sys.argv:
 terminal='Running(ret,prefix+[j],mem)' if EXIT else 'Running(8234,prefix+[ret,offset,length,ts,te,j-1],mem)'
 extraPre=' && ret in destinations && ret < |code| && code[ret] == 91' if EXIT else ''
 targetSet='{'+','.join(map(str,sorted(targets)))+'}'
 s+=f'''  lemma Advance(id: nat,code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && id < {len(states)} && Good(id,state,{args}) && {targetSet} <= destinations{extraPre}
    ensures Q.Local(code,state)
    ensures id+1 < {len(states)} ==> Good(id+1,Step(code,destinations,state,value,data),{args})
    ensures id+1 == {len(states)} ==> Step(code,destinations,state,value,data) == {terminal}
  {{
'''
 for i in range(len(states)):
  s+=('    if ' if i==0 else '    else if ')+f'id == {i} {{ Advance{i}(code,destinations,state,{args},value); }}\n'
 s+=f'''  }}
  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && {targetSet} <= destinations{extraPre}
    ensures state == {terminal}
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(8234,prefix+[ret,offset,length,ts,te,j],mem) && trace[|trace|-1] == state
    ensures forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> Q.Local(code,trace[k])
  {{
    reveal Good();
    state := Running(8234,prefix+[ret,offset,length,ts,te,j],mem); trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,destinations,value,data,trace)
      invariant trace[0] == Running(8234,prefix+[ret,offset,length,ts,te,j],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,{args})
      invariant id == {len(states)} ==> state == {terminal}
      invariant forall k {{:trigger trace[k]}} :: 0 <= k < |trace|-1 ==> Q.Local(code,trace[k])
      decreases {len(states)}-id
    {{
      Advance(id,code,destinations,state,{args},value);
      var next := Step(code,destinations,state,value,data);
      E.Extend(code,destinations,value,data,trace,next);
      assert forall k {{:trigger (trace+[next])[k]}} :: 0 <= k < |trace| ==> Q.Local(code,(trace+[next])[k]);
      trace := trace+[next]; state := next; id := id+1;
    }}
  }}
'''
s+='}\n';(OUT/('Exit.dfy' if EXIT else 'Digit.dfy')).write_text(s);(OUT/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':facts,'targets':sorted(targets),'scope':'Arbitrary admitted one-digit suffix loop; no public-entry or full suffix claim.'},indent=2)+'\n');print(len(states),'instructions')
