#!/usr/bin/env python3
"""Generate seven complete raw rejection traces from current runtime bytes.

No native/public credit from this generator. Every reached opcode/immediate and
actual jump destination is bound; complete actual calldata feeds the machine.
"""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
CASES={
 'Nonzero':dict(value=1,size=0,a=0,b=0,c=0),
 'Short':dict(value=0,size=0,a=0,b=0,c=0),
 'Args':dict(value=0,size=4,a=0,b=0,c=0),
 'OffsetBound':dict(value=0,size=100,a=1<<64,b=0,c=0),
 'LengthWindow':dict(value=0,size=100,a=(1<<64)-1,b=0,c=0),
 'LengthBound':dict(value=0,size=100,a=64,b=1<<64,c=0),
 'PayloadWindow':dict(value=0,size=101,a=64,b=2,c=0),
}
def signed(v):return v if v<MOD//2 else v-MOD
def generate(out,runtime=None):
 inventory=json.loads((HERE.parent/'inventory.json').read_text());artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=runtime.read_bytes() if runtime else bytes.fromhex(artifact['deployedBytecode'][2:])
 assert runtime or hashlib.sha256(code).hexdigest()==inventory['runtimeSha256']
 assert inventory['compilerIdentity']['methodIdentifiers']['byteAt(bytes,int256)']=='9ae8e8ea'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1].ljust(width,b'\0'),'big'));pc+=width+1
 jumpdest={p for p,x in ins.items() if x[0]==0x5b};out.mkdir(parents=True,exist_ok=True)
 for name,case in CASES.items():
  pc=0;stack=[];expr=[];memory='[]';nodes=[];required={};seen=set()
  def pop():return stack.pop(),expr.pop()
  def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
  while True:
   state=(pc,tuple(stack),tuple(expr),memory);assert state not in seen;seen.add(state)
   op,nxt,imm=ins[pc];assert nxt<=len(code);required.update({i:code[i] for i in range(pc,nxt)})
   node=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy(),memory=memory);nodes.append(node)
   if op==0x5f or 0x60<=op<=0x7f:push(imm)
   elif op==0x34:push(case['value'],'value')
   elif op==0x36:push(case['size'],'|data|')
   elif op==0x35:
    at,ae=pop();v=(int('9ae8e8ea',16)<<224) if at==0 else case['a'] if at==4 else case['c'] if at==36 else case['b'] if at==case['a']+4 else None;assert v is not None,(name,pc,at)
    push(v,f'I.DataWord(data,{ae})')
   elif op==0x1c:
    amount,ae=pop();v,ve=pop();assert amount==224
    push(v>>amount,str(int('9ae8e8ea',16)));node['selectorProjection']=True
   elif 0x80<=op<=0x8f:k=op-0x7f;push(stack[-k],expr[-k])
   elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:v,e=pop();push(int(v==0),f'Bool(({e})==0)' if 'data' in e or 'value' in e else None)
   elif op in [0x01,0x03,0x10,0x11,0x12,0x14,0x1b]:
    a,ae=pop();b,be=pop();v={0x01:lambda:(a+b)%MOD,0x03:lambda:(a-b)%MOD,0x10:lambda:int(a<b),0x11:lambda:int(a>b),0x12:lambda:int(signed(a)<signed(b)),0x14:lambda:int(a==b),0x1b:lambda:(b<<a)%MOD if a<256 else 0}[op]()
    expressions={0x01:f'((({ae}) as nat)+(({be}) as nat))%M',0x03:f'((({ae}) as nat)+M-(({be}) as nat))%M',0x10:f'Bool(({ae})<({be}))',0x11:f'Bool(({ae})>({be}))',0x12:f'Bool(N.Signed({ae})<N.Signed({be}))',0x14:f'Bool(({ae})==({be}))',0x1b:f'Left({be},{ae})'}
    push(v,expressions[op] if 'data' in ae+be or 'value' in ae+be else None)
    if op==0x1b:assert(a,b)==(64,1);node['offsetLimitShift']=True
   elif op==0x52:
    at,ae=pop();v,ve=pop();assert at==64 and v==128;memory=f'B.Copy({memory},I.Encode({ve},32),0,{ae},32)'
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    dest,_=pop();take=op==0x56 or pop()[0]!=0;assert dest in jumpdest;node['jump']=dest;required[dest]=code[dest]
    if take:nxt=dest
   elif op==0xfd:
    at,_=pop();count,_=pop();assert at==0 and count==0;node['reverted']=True;break
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt;assert len(stack)<=1024
  constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(required.items()));destinations=sorted({n['jump'] for n in nodes if 'jump' in n});maximum=max(len(n['stack']) for n in nodes)
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id=={n['id']} then state==Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for n in nodes)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete raw rejection trace. Never edit directly.
include "AdmissionKernel.dfy"
module OperationsByteAt{name} {{
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  predicate Admitted(value: Word,data: seq<Byte>) {{
    I.Frame(data) && I.Assigned(data,value) && I.Admission(data,value)==I.{name}
  }}
  opaque predicate Matches(code: seq<Byte>) {{
    |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,destinations))}}} }}
  opaque predicate Good(id: nat,state: State,value: Word,data: seq<Byte>)
    requires I.Frame(data)
  {{
{good}
  }}
'''
  for n in nodes:
   i=n['id'];post='next==Reverted([])' if n.get('reverted') else f'Good({i+1},next,value,data)';guide=f'    reveal Good(); reveal Matches(); reveal Step();\n    assert state==Running({n["pc"]},[{",".join(n["stack"])}],{n["memory"]});\n'
   if n['opcode']>=0x60 and n['opcode']<=0x7f:
    width=n['opcode']-0x5f
    for k in range(1,width+1):guide+=f'    assert I.Load(code,{n["pc"]+1},{k})=={int.from_bytes(code[n["pc"]+1:n["pc"]+1+k],"big")};\n'
   guide+=f'    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n'
   if n.get('selectorProjection'):guide+='    K.AssignedSelector(data,value);\n'
   if n.get('offsetLimitShift'):guide+='    K.OffsetLimitShift();\n'
   if 'jump' in n:guide+=f'    assert {n["jump"]} in Destinations() && code[{n["jump"]}]==0x5b;\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,value: Word,data: seq<Byte>)
    requires Matches(code) && Admitted(value,data) && Good({i},state,value,data)
    ensures state.Running? && |state.stack|<={maximum} && |state.memory|<=96
    ensures var next:=Step(code,Destinations(),state,value,data); {post}
  {{
{guide}  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,value,data);\n    state:=Step(code,Destinations(),state,value,data);' for i in range(len(nodes)))
  text+=f'''  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns(state: State)
    requires Matches(code) && Admitted(value,data)
    ensures state==Reverted([])
  {{
    reveal Good();
    state:=Running(0,[],[]);
    assert Good(0,state,value,data);
{calls}
  }}
}}
'''
  (out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(name=name,runtimeSha256=hashlib.sha256(code).hexdigest(),runtimeBytes=len(code),candidateRuntime=bool(runtime),maximumStackWords=maximum,requiredBytes=required,states=nodes,scope='Unverified full actual-data raw rejection trace; no public credit'),indent=2)+'\n');print(name,len(nodes))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
