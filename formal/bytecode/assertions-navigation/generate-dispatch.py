#!/usr/bin/env python3
"""Exact physical dispatcher route for the nav selector; arbitrary admitted calldata."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
OUT=HERE/'development/dispatch-v5';OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
rows=json.loads((HERE/'development/passthrough-v1/evm/case-33.json').read_text())['trace']['structLogs'];rows=rows[:next(i for i,x in enumerate(rows) if x['pc']==344)]
stack=[];memory='[]';states=[];facts={344:code[344]};targets=set()
for row in rows:
 pc=row['pc'];op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+width+1;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});states.append((pc,op,nxt,imm,list(stack),memory))
 if op==91:pass
 elif op==95 or 96<=op<=127:stack.append(str(imm))
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:j=op-143;stack[-1],stack[-1-j]=stack[-1-j],stack[-1]
 elif op==80:stack.pop()
 elif op==82:offset,value=stack.pop(),stack.pop();assert (offset,value)==('64','128');memory='Prepared()'
 elif op==52:stack.append('value')
 elif op==54:stack.append('|data|')
 elif op==53:assert stack.pop()=='0';stack.append('DataWord(data,0)')
 elif op==28:amount,arg=stack.pop(),stack.pop();assert amount=='224' and arg=='DataWord(data,0)';stack.append('531649507')
 elif op in {16,17,20}:
  a,b=stack.pop(),stack.pop();comparison={16:'<',17:'>',20:'=='}[op];stack.append(f'(if {a} {comparison} {b} then 1 else 0)')
 elif op==21:a=stack.pop();stack.append(f'(if {a} == 0 then 1 else 0)')
 elif op in {86,87}:
  target=int(stack.pop());targets.add(target);facts[target]=code[target]
  if op==87:stack.pop()
 else:raise ValueError(op)
assert stack==['531649507']
args='data,value';params='data: seq<Byte>,value: Word'
good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},[{",".join(st)}],{m})' for i,(pc,op,nxt,imm,st,m) in enumerate(states))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
include "{HERE/'Frame.dfy'}"
include "{HERE.parent/'scans/Push.dfy'}"
module AssertionsNavigationDispatch {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = AssertionsNavigationFrame
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  import PN = BytecodeScanPush
  predicate Admitted({params}) {{ 4 <= |data| < 0x10000000000000000 && value == 0 && ShiftRight(DataWord(data,0),224) == 531649507 }}
  function Prepared(): seq<Byte> {{ Store([],64,128) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Targets(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
for i,(pc,op,nxt,imm,st,m) in enumerate(states):
 post=f'Running(344,[531649507],Prepared())' if i==len(states)-1 else f'Running({states[i+1][0]},[{",".join(states[i+1][4])}],{states[i+1][5]})'
 extra=f'    F.Push{op-95}(code,{pc});\n' if op in {96,97,99} else ''
 # Push4 is decoded directly by Fetch; Push1/2 have dedicated facts.
 if op==99:extra=f'    PN.Push4(code,{pc});\n'
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params})
    requires Matches(code) && Targets() <= destinations && {'|data| < G.Modulus() && ' if i == 11 else ''}Good({i},state,{args})
    ensures H.Local(code,state)
    ensures Step(code,destinations,state,value,data) == {post}
    ensures {f'Good({i+1},Step(code,destinations,state,value,data),{args})' if i<len(states)-1 else 'true'}
  {{ reveal Good(); reveal Matches(); reveal Step();
{extra}    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
s+=f'''  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Targets() <= destinations && Admitted({args})
    ensures state == Running(344,[531649507],Prepared())
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
  {{ reveal Good(); state := Running(0,[],[]); trace := [state];
'''
for i in range(len(states)):
 s+=f'''    Advance{i}(code,destinations,state,{args});
    var next{i} := Step(code,destinations,state,value,data);
    E.Extend(code,destinations,value,data,trace,next{i});
    trace := trace+[next{i}]; state := next{i};
    assert |trace| == {i+2};
    assert forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> H.Local(code,trace[j]);
'''
s+='  }\n}\n';(OUT/'Dispatch.dfy').write_text(s)
(OUT/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':facts},indent=2)+'\n')
print(len(states),'physical instructions')
