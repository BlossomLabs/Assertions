#!/usr/bin/env python3
"""Exact reached strict-index paths and physical custom-error serialization."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;H=MOD//2
CASES={'InvalidHigh':(0,0),'InvalidLow':(0,MOD-1),'Positive':(1,0),'Negative':(1,MOD-1)}
def signed(x):return x if x<H else x-MOD
def generate(out,runtime=None):
 inv=json.loads((HERE.parent/'inventory.json').read_text());code=runtime.read_bytes() if runtime else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert runtime or hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['byteAt(bytes,int256)']=='9ae8e8ea'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=w+1
 dests={p for p,i in ins.items() if i[0]==0x5b};out.mkdir(parents=True,exist_ok=True)
 for name,(b,c) in CASES.items():
  pc=7143;stack=[0x9ae8e8ea,1362,100,b,c];expr=['0x9ae8e8ea','1362','I.Offset(data)+36','I.Length(data)','I.Index(data)'];memory='O.InitialHeap()';nodes=[];required={};seen=set()
  def pop():return stack.pop(),expr.pop()
  def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
  while True:
   assert (pc,tuple(stack),memory) not in seen;seen.add((pc,tuple(stack),memory));op,nxt,imm=ins[pc];required.update({i:code[i] for i in range(pc,nxt)});n={'id':len(nodes),'pc':pc,'opcode':op,'next':nxt,'immediate':imm,'stack':expr.copy(),'memory':memory};nodes.append(n)
   if pc==7156:n['frontier']=True;break
   if op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:v,e=pop();push(int(v==0),f'Bool(({e})==0)' if 'data' in e else None)
   elif op in [1,3,0x12,0x16,0x17,0x1b]:
    a,ae=pop();d,de=pop();v={1:lambda:(a+d)%MOD,3:lambda:(a-d)%MOD,0x12:lambda:int(signed(a)<signed(d)),0x16:lambda:a&d,0x17:lambda:a|d,0x1b:lambda:(d<<a)%MOD if a<256 else 0}[op]()
    e={1:f'(({ae})+({de}))%M',3:f'(({ae})+M-({de}))%M',0x12:f'Bool(N.Signed({ae})<N.Signed({de}))',0x16:f'BitAnd({ae},{de})',0x17:f'BitOr({ae},{de})',0x1b:f'Left({de},{ae})'}[op]
    if op in [0x16,0x17]:
     assert a<=1 and d<=1;n['booleanOperands']=[ae,de]
    if op==0x1b:
     if (a,d)==(255,1):e='N.H';n['halfShift']=True
     elif (a,d)==(225,0x6fbae5d7):e='E.Header';n['selectorShift']=True
     else:raise ValueError((name,pc,a,d))
    push(v,e if 'data' in ae+de or op==0x1b else None)
   elif op==0x51:
    at,_=pop();assert at==64;push(128);n['loadHeap']=memory
   elif op==0x52:
    at,_=pop();v,e=pop();n['store']=[at,e]
    if at==128:memory='E.SelectorStored()'
    elif at==132:memory='E.IndexStored(I.Index(data))'
    elif at==164:memory='E.Finished(I.Index(data),I.Length(data))'
    else:raise ValueError((name,pc,at))
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    dest,_=pop();take=op==0x56 or pop()[0]!=0;assert dest in dests;n['jump']=dest;required[dest]=code[dest]
    if take:nxt=dest
   elif op==0xfd:
    at,_=pop();count,_=pop();assert (at,count)==(128,68);n['terminal']=True;break
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt
  requiredText=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(required.items()));jump=sorted({n['jump'] for n in nodes if 'jump' in n});good='\n'.join('    '+('if' if i==0 else 'else if')+f" id=={i} then state==Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for i,n in enumerate(nodes))+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated strict signed-index path. Never edit directly.
include "Guard.dfy"
module OperationsByteAtIndex{name} {{
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  import S = OperationsByteAtBodyKernel
  import G = OperationsByteAtNegativeGuard
  import E = OperationsByteAtError
  import O = OperationsByteAtOutput
  predicate Admitted(value:Word,data:seq<Byte>) {{
    I.Frame(data) && I.Assigned(data,value) && I.Admission(data,value)==I.{name}
  }}
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {requiredText}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,jump))}}} }}
  opaque predicate Good(id:nat,state:State,value:Word,data:seq<Byte>)
    requires I.Frame(data) && I.Span(data)
  {{
{good}
  }}
'''
  for n in nodes:
   if n.get('frontier'):continue
   i=n['id'];post='next==Reverted(I.InvalidIndex(I.Index(data),I.Length(data)))' if n.get('terminal') else f'Good({i+1},next,value,data)';body='    reveal Good();reveal Matches();reveal Step();\n    S.StrictGuards(I.Index(data),I.Length(data));\n'
   if name=='Negative':body+='    G.NegativeAddition(I.Index(data),I.Length(data));\n'
   if 96<=n['opcode']<=127:
    w=n['opcode']-95
    for k in range(1,w+1):body+=f"    assert I.Load(code,{n['pc']+1},{k})=={int.from_bytes(code[n['pc']+1:n['pc']+1+k],'big')};\n"
   body+=f"    assert Fetch(code,{n['pc']})==Op({n['opcode']},{n['next']},{n['immediate']});\n"
   if n.get('halfShift'):body+='    S.HalfWordShift();\n'
   if n.get('selectorShift'):body+='    S.ActualErrorSelectorShift();\n'
   if n.get('booleanOperands'):body+='    S.BooleanBits('+','.join(n['booleanOperands'])+');\n'
   if n.get('loadHeap'):
    body+='    S.LoadStored([],64,128); B.CopyLength([],I.Encode(128,32),0,64,32);\n'
    if n['loadHeap']!='O.InitialHeap()':body+='    E.Sizes(I.Index(data),I.Length(data));\n    S.LoadFrame(O.InitialHeap(),I.Encode(E.Header,32),0,128,32,64);\n    S.LoadFrame(E.SelectorStored(),I.Encode(I.Index(data),32),0,132,32,64);\n    S.LoadFrame(E.IndexStored(I.Index(data)),I.Encode(I.Length(data),32),0,164,32,64);\n'
   if n.get('terminal'):body+='    E.Receipt(I.Index(data),I.Length(data));\n'
   text+=f'''  lemma Advance{i}(code:seq<Byte>,state:State,value:Word,data:seq<Byte>)
    requires Matches(code) && Admitted(value,data) && Good({i},state,value,data)
    ensures var next:=Step(code,Destinations(),state,value,data); {post}
  {{
{body}  }}
'''
  text+='''  lemma Start(value:Word,data:seq<Byte>)
    requires Admitted(value,data)
    ensures Good(0,Running(7143,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data)],O.InitialHeap()),value,data)
  { reveal Good(); }
'''
  if nodes[-1].get('frontier'):
   text+=f'''  lemma Frontier(state:State,value:Word,data:seq<Byte>)
    requires Admitted(value,data) && Good({len(nodes)-1},state,value,data)
    ensures state==Running(7156,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data),96,0,N.Position(I.Index(data),I.Length(data))],O.InitialHeap())
  {{ reveal Good(); N.{name}Position(I.Index(data),I.Length(data)); }}
'''
  text+='}\n';(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'name':name,'runtimeSha256':hashlib.sha256(code).hexdigest(),'requiredBytes':required,'states':nodes,'scope':'Complete strict-index/error path candidate, not native credit'},indent=2)+'\n');print(name,len(nodes),nodes[-1]['pc'])
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
