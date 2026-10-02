#!/usr/bin/env python3
"""Exact physical public serializer call and shared RETURN, with symbolic memory."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];M=1<<256
code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();trace=json.loads((ROOT/'formal/bytecode/assertions-primitives-control/gather-composition/evidence/element-native-v1/evm-traces/element-33.json').read_text())['trace']['structLogs'];logs=[x for x in trace if x['depth']==1];at=next(i for i,x in enumerate(logs) if x['pc']==477)
for name,path,stack,guard in [('Before',logs[at:at+8],['arrayBase'],'|mem|%32 == 0 && 96 <= |mem| < G.Modulus() && S.Load(mem,64) == base'),('Return',logs[-8:],['tail'],'96 <= |mem| < G.Modulus() && base <= tail <= |mem| && S.Load(mem,64) == base')]:
 rows=[];facts={};targets=set()
 for log in path:
  pc=log['pc'];op=code[pc];w=op-95 if 96<=op<=127 else 0;nxt=pc+1+w;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});rows.append({'id':len(rows),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':stack.copy(),'memory':'mem'})
  def pop():return stack.pop()
  if op==91:pass
  elif 96<=op<=127:stack.append(str(imm))
  elif 128<=op<=143:stack.append(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x51:assert pop()=='64';stack.append('base')
  elif op==0x56:dst=pop();targets.add(int(dst));facts[int(dst)]=91
  elif op==3:a,b=pop(),pop();stack.append(f'(({a} as nat)+G.Modulus()-({b} as nat))%G.Modulus()')
  elif op==0xf3:assert pop()=='base';pop()
  else:raise ValueError((name,pc,op))
 params='arrayBase: Word,base: Word,tail: Word,prefix: seq<Word>,mem: seq<Byte>,value: Word,data: seq<Byte>';args='arrayBase,base,tail,prefix,mem,value,data';state=lambda r:f'S.Running({r["pc"]},prefix+[{",".join(r["stack"])}],mem)';terminal='S.Running(17316,prefix+[381,arrayBase,base],mem)' if name=='Before' else 'S.Returned(mem[base..tail])';good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == {state(r)}' for i,r in enumerate(rows))+'\n    else false'
 s=f'''// SPDX-License-Identifier: MIT
// Exact physical public gather serializer {name.lower()} path.
include "../../../scans/Execution.dfy"
include "../../../scans/Push.dfy"
module AssertionsGatherSerializer{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  type Word = S.Word
  type Byte = S.Byte
  opaque predicate Matches(code: seq<Byte>) {{ |code| == 20049 && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Admitted({params}) {{ |prefix| <= 960 && {guard} }}
  opaque predicate Good(id: nat,state: S.State,{params}) {{ Admitted({args}) && (\n{good}) }}
'''
 for i,r in enumerate(rows):
  post=state(rows[i+1]) if i<len(rows)-1 else terminal;push=f'    F.Push{r["op"]-95}(code,{r["pc"]});\n' if 96<=r['op']<=127 else ''
  s+=f'''  lemma Advance{i}(code: seq<Byte>,state: S.State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    requires {'base <= tail <= |mem|' if name=='Return' else '|mem| < G.Modulus()'}
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures S.Step(code,Destinations(),state,value,data) == {post}
  {{ reveal Admitted(); reveal Good(); reveal Matches(); reveal S.Step();
    hide S.Load(); hide G.Decode();
{push}    assert S.Fetch(code,{r['pc']}) == S.Op({r['op']},{r['next']},{r['immediate']});
  }}
'''
 s+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: S.State,trace: seq<S.State>)
    requires Matches(code) && Admitted({args})
    requires {'base <= tail <= |mem|' if name=='Return' else '|mem| < G.Modulus()'}
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == {state(rows[0])} && trace[|trace|-1] == state && state == {terminal}
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
  {{ reveal Good(); state := {state(rows[0])}; trace := [state];
'''
 for i in range(len(rows)):s+=f'    Advance{i}(code,state,{args}); var next{i} := S.Step(code,Destinations(),state,value,data); E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};\n'
 s+='  }\n}\n';(HERE/(name+'.generated.dfy')).write_text(s);(HERE/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':rows,'requiredBytes':facts,'terminal':terminal},indent=2)+'\n');print(name,len(rows))
