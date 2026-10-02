#!/usr/bin/env python3
"""Exact nav successful-wrapper path; witness selects branches, native proofs justify them."""
from pathlib import Path
from dataclasses import dataclass
import json,hashlib
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
OUT=HERE/'development/decoder-v1';OUT.mkdir(parents=True,exist_ok=True)
MOD=1<<256
@dataclass
class V:
 n:int
 t:str
 def constant(self):return self.t.isdecimal()
def signed(n):return n if n<MOD//2 else n-MOD
artifact=json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
witness=json.loads((HERE/'development/passthrough-v1/evm/case-33.json').read_text());data=bytes.fromhex(witness['data'][2:]);rows=witness['trace']['structLogs'];rows=rows[next(i for i,x in enumerate(rows) if x['pc']==344):next(i for i,x in enumerate(rows) if x['pc']==1054)]
instructions={};pc=0
while pc<len(code):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;instructions[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1],'big'));pc+=width+1
valid={pc for pc,(op,_,_) in instructions.items() if op==91}
stack=[V(531649507,'531649507')];states=[];facts={};targets=set()
for k,row in enumerate(rows):
 pc=row['pc'];op,nxt,imm=instructions[pc];facts.update({p:code[p] for p in range(pc,nxt)});states.append({'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack]});extra=''
 if op==91:pass
 elif op==95 or 96<=op<=127:stack.append(V(imm,str(imm)))
 elif op==54:stack.append(V(len(data),'|data|'))
 elif 128<=op<=143:stack.append(stack[-(op-127)])
 elif 144<=op<=159:j=op-143;stack[-1],stack[-1-j]=stack[-1-j],stack[-1]
 elif op==80:stack.pop()
 elif op in [1,3]:
  a,b=stack.pop(),stack.pop();n=(a.n+b.n if op==1 else a.n-b.n)%MOD
  t=str(n) if a.constant() and b.constant() else ('0' if op==3 and a.t==b.t else f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()');stack.append(V(n,t))
 elif op in [17,18]:
  a,b=stack.pop(),stack.pop();truth=a.n>b.n if op==17 else signed(a.n)<signed(b.n);cond=f'{a.t} > {b.t}' if op==17 else f'G.Signed({a.t}) < G.Signed({b.t})';stack.append(V(int(truth),f'(if {cond} then 1 else 0)'))
 elif op==21:a=stack.pop();stack.append(V(int(a.n==0),f'(if {a.t} == 0 then 1 else 0)'))
 elif op==53:
  a=stack.pop();n=int.from_bytes((data+b'\0'*32)[a.n:a.n+32].ljust(32,b'\0'),'big');stack.append(V(n,f'DataWord(data,{a.t})'))
 elif op==27:
  a,b=stack.pop(),stack.pop();assert a.constant();n=(b.n<<a.n)%MOD;t=str(n) if b.constant() else f'ShiftLeft({b.t},{a.t})';stack.append(V(n,t))
  if b.constant():extra=f'    assert ShiftLeft({b.t},{a.t}) == {n} by {{ reveal ShiftLeft(); }}\n'
 elif op in [86,87]:
  dest=stack.pop();assert dest.constant() and dest.n in valid
  take=op==86 or stack.pop().n!=0
  if take:targets.add(dest.n);facts[dest.n]=code[dest.n];assert dest.n==(rows[k+1]['pc'] if k+1<len(rows) else 1054)
 else:raise ValueError(op)
 states[-1]['extra']=extra
terminal=f'Running(1054,prefix+[{",".join(x.t for x in stack)}],mem)';args='prefix,mem';params='prefix: seq<Word>,mem: seq<Byte>';good='\n'.join(('    if ' if i==0 else '    else if ')+f'id == {i} then state == Running({n["pc"]},prefix+[{",".join(n["stack"])}],mem)' for i,n in enumerate(states))+'\n    else false'
s=f'''// SPDX-License-Identifier: MIT
include "{HERE/'Admission.dfy'}"
include "{HERE.parent/'scans/Execution.dfy'}"
module AssertionsNavigationDecoder {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = AssertionsNavigationAdmission
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted(data: seq<Byte>,{params}) {{ I.Admitted(data) && |prefix| <= 980 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {' && '.join(f'code[{p}] == {v}' for p,v in sorted(facts.items()))} }}
  function Targets(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,{params}) {{ Admitted(data,{args}) && (
{good}) }}
'''
for i,n in enumerate(states):
 post=f'Good({i+1},Step(code,destinations,state,value,data),data,{args})' if i<len(states)-1 else f'Step(code,destinations,state,value,data) == {terminal}';extra=n['extra']
 if 96<=n['op']<=97:extra+=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n'
 s+=f'''  lemma Advance{i}(code: seq<Byte>,destinations: set<nat>,state: State,data: seq<Byte>,{params},value: Word)
    requires Matches(code) && Targets() <= destinations && Admitted(data,{args}) && Good({i},state,data,{args})
    ensures state.Running? && Step(code,destinations,state,value,data) != Bad
    ensures {post}
  {{ reveal Matches(); reveal Good(); reveal Step();
{extra}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
s+='}\n';(OUT/'Decoder.generated.dfy').write_text(s);(OUT/'mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':facts,'targets':sorted(targets),'terminalState':terminal,'scope':'Success ABI wrapper344→1054; native per-step obligations and independent output binding pending.'},indent=2)+'\n');print(len(states),'instruction states')
