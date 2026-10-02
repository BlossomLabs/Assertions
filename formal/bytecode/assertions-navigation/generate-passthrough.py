from pathlib import Path
import json
import hashlib
root=Path(__file__).resolve().parents[3];here=root/'formal/bytecode/assertions-navigation';out=here/'development/passthrough-v3';out.mkdir(parents=True,exist_ok=True);artifact=json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((root/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256'];trace=json.loads((here/'development/passthrough-v1/evm/case-33.json').read_text())['trace']['structLogs'];trace=trace[next(i for i,x in enumerate(trace) if x['pc']==1081):];stack=['ret','param','typeOffset','typeLength','pathOffset','0','0','ptr'];states=[];facts={}
for row in trace:
 pc=row['pc'];op=code[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;imm=int.from_bytes(code[pc+1:nxt],'big');facts.update({p:code[p] for p in range(pc,nxt)});states.append((pc,op,nxt,imm,list(stack)))
 if op==0x5b:pass
 elif op==0x5f or 96<=op<=127:stack.append(str(imm))
 elif 0x80<=op<=0x8f:stack.append(stack[-(op-0x7f)])
 elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
 elif op==0x50:stack.pop()
 elif op==0x03:a,b=stack.pop(),stack.pop();assert a==b;stack.append('0')
 elif op==0x57:stack.pop();assert stack.pop()=='0'
 elif op==0x51:assert stack.pop()=='ptr';stack.append('length')
 elif op==1:a,b=stack.pop(),stack.pop();assert {a,b}=={'ptr','32'};stack.append('ptr+32')
 elif op==0xf3:break
 else:raise Exception(op)
params='ptr: Word, length: Word, ret: Word, param: Word, typeOffset: Word, typeLength: Word, pathOffset: Word, prefix: seq<Word>, mem: seq<Byte>';args='ptr,length,ret,param,typeOffset,typeLength,pathOffset,prefix,mem';initial='Running(1081,prefix+[ret,param,typeOffset,typeLength,pathOffset,0,0,ptr],mem)';terminal='Returned(mem[ptr+32..ptr+32+length])';good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({pc},prefix+[{",".join(st)}],mem)' for i,(pc,op,nxt,imm,st) in enumerate(states))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
include "{here/'Index.dfy'}"
include "{here/'Frame.dfy'}"
include "{here.parent/'scans/Execution.dfy'}"
module AssertionsNavigationPassthrough {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import Q = AssertionsNavigationIndex
  import H = AssertionsNavigationFrame
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  predicate Admitted({params}) {{ |mem|%32 == 0 && |mem| < G.Modulus() && (ptr as nat)+32+(length as nat) <= |mem| && Load(mem,ptr) == length && |prefix| <= 980 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
for i,(pc,op,nxt,imm,st) in enumerate(states):
 post=terminal if i==len(states)-1 else f'Running({states[i+1][0]},prefix+[{",".join(states[i+1][4])}],mem)';extra=''
 if op==0x51:extra='    Q.ExpansionIdentity(mem,(ptr as nat)+32);\n'
 if op==0xf3:extra='    Q.ExpansionIdentity(mem,(ptr as nat)+32+(length as nat));\n'
 if op in {0x60,0x61}:extra+=f'    F.Push{op-95}(code,{pc});\n'
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,{params},value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures H.Local(code,state)
    ensures state.Running? && Step(code,destinations,state,value,data) != Bad
    ensures Step(code,destinations,state,value,data) == {post}
    ensures {'' if i==len(states)-1 else f'Good({i+1},Step(code,destinations,state,value,data),{args})'}{'true' if i==len(states)-1 else ''}
  {{ reveal Matches(); reveal Good(); reveal Step(); reveal H.Local();
{extra}    assert Fetch(code,{pc}) == Op({op},{nxt},{imm});
  }}
'''
s+=f'''  ghost method Run(code: seq<Byte>,destinations: set<nat>,{params},value: Word,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {terminal}
    ensures E.Trace(code,destinations,value,data,trace)
    ensures forall i {{:trigger trace[i]}} :: 0 <= i < |trace|-1 ==> H.Local(code,trace[i])
    ensures trace[0] == {initial} && trace[|trace|-1] == state
  {{ reveal Good(); state := {initial}; trace := [state];
'''
for i in range(len(states)):s+=f'    Advance{i}(code,destinations,state,{args},value,data);\n    var next{i} := Step(code,destinations,state,value,data);\n    E.Extend(code,destinations,value,data,trace,next{i});\n    trace := trace+[next{i}]; state := next{i};\n    assert |trace| == {i+2};\n    assert forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> H.Local(code,trace[j]);\n    assert trace[0] == {initial};\n'
s+='  }\n}\n';(out/'Passthrough.dfy').write_text(s);(out/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'entry':1081,'states':states,'requiredBytes':facts,'scope':'Exact post-resolver nav empty-path continuation only; decoder and resolver connection remain open.'},indent=2)+'\n');print(len(states),'instructions')
