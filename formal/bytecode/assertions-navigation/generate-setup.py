#!/usr/bin/env python3
"""Pin the complete public nav empty-path setup through the actual resolver call."""
from pathlib import Path
import json
import hashlib
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
OUT=HERE/'development/setup-v1'
OUT.mkdir(parents=True,exist_ok=True)
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
digest=hashlib.sha256(code).hexdigest()
assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
rows=json.loads((HERE/'development/passthrough-v1/evm/case-33.json').read_text())['trace']['structLogs']
rows=rows[next(i for i,x in enumerate(rows) if x['pc']==1054):next(i for i,x in enumerate(rows) if x['pc']==3393)]
stack=['ret','param','typeOffset','typeLength','pathOffset','0'];memory='mem';states=[];facts={3393:code[3393]}
for row in rows:
 pc=row['pc'];op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});states.append((pc,op,nxt,imm,list(stack),memory))
 if op==0x5b:pass
 elif op==0x5f or 96<=op<=127:stack.append(str(imm))
 elif 0x80<=op<=0x8f:stack.append(stack[-(op-0x7f)])
 elif op==0x50:stack.pop()
 elif op==0x51:assert stack.pop()=='64';stack.append('free')
 elif op==1:a,b=stack.pop(),stack.pop();assert {a,b}=={'free','32'};stack.append('free+32')
 elif op==0x52:
  offset,value=stack.pop(),stack.pop()
  if offset=='64':assert value=='free+32';memory='First(mem,free)'
  else:assert offset=='free' and value=='0';memory='Prepared(mem,free)'
 elif op==0x56:assert stack.pop()=='3393'
 else:raise ValueError(op)
params='free: Word, ret: Word, param: Word, typeOffset: Word, typeLength: Word, pathOffset: Word, prefix: seq<Word>, mem: seq<Byte>'
args='free,ret,param,typeOffset,typeLength,pathOffset,prefix,mem'
initial='Running(1054,prefix+[ret,param,typeOffset,typeLength,pathOffset,0],mem)'
terminal=f'Running(3393,prefix+[{",".join(stack)}],{memory})'
good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},prefix+[{",".join(st)}],{m})' for i,(pc,op,nxt,imm,st,m) in enumerate(states))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
include "{HERE/'Index.dfy'}"
include "{HERE/'Frame.dfy'}"
include "{HERE.parent/'scans/Execution.dfy'}"
module AssertionsNavigationSetup {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = AssertionsNavigationIndex
  import H = AssertionsNavigationFrame
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  predicate Admitted({params}) {{ |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 128 <= free && (free as nat)+64 < G.Modulus() && |prefix| <= 980 }}
  function First(mem: seq<Byte>,free: Word): seq<Byte> requires free+32 < G.Modulus() {{ Store(mem,64,free+32) }}
  function Prepared(mem: seq<Byte>,free: Word): seq<Byte> requires free+32 < G.Modulus() {{ Store(First(mem,free),free,0) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
for i,(pc,op,nxt,imm,st,m) in enumerate(states):
 post=terminal if i==len(states)-1 else f'Running({states[i+1][0]},prefix+[{",".join(states[i+1][4])}],{states[i+1][5]})';extra=''
 if op==0x51:extra='    Q.ExpansionIdentity(mem,96);\n'
 if op in {0x60,0x61}:extra+=f'    F.Push{op-95}(code,{pc});\n'
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args}) && 3393 in destinations
    ensures H.Local(code,state)
    ensures state.Running? && Step(code,destinations,state,value,data) != Bad
    ensures Step(code,destinations,state,value,data) == {post}
    ensures {f'Good({i+1},Step(code,destinations,state,value,data),{args})' if i<len(states)-1 else 'true'}
  {{ reveal Matches(); reveal Good(); reveal Step(); reveal H.Local();
{extra}    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
s+=f'''  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params},value: Word,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && 3393 in destinations
    ensures state == {terminal}
    ensures E.Trace(code,destinations,value,data,trace)
    ensures trace[0] == {initial} && trace[|trace|-1] == state
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
  {{ reveal Good(); state := {initial}; trace := [state];
'''
for i in range(len(states)):s+=f'    Advance{i}(code,destinations,state,{args},value,data);\n    var next{i} := Step(code,destinations,state,value,data);\n    E.Extend(code,destinations,value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};\n    assert |trace| == {i+2};\n    assert trace[0] == {initial};\n    assert forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> H.Local(code,trace[j]);\n'
s+='  }\n}\n'
(OUT/'Setup.dfy').write_text(s)
(OUT/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'entry':1054,'states':states,'requiredBytes':facts,'scope':'Exact public nav empty-path setup to actual resolver entry3393 only; ABI decoder and resolver execution remain open.'},indent=2)+'\n')
print(len(states),'instructions')
