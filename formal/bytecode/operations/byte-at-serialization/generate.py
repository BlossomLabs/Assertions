#!/usr/bin/env python3
"""Complete exact byteAt allocation/copy/ABI-return path, generation is no proof."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
POS='Position(data)';SRC='Source(data)'
def signed(n):return n if n<MOD//2 else n-MOD
def generate(out,runtime=None):
 inv=json.loads((HERE.parent/'inventory.json').read_text());code=runtime.read_bytes() if runtime else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert runtime or hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];candidateCopy=code[18907]==0x37;assert code[18907] in [0x37,0x5e]
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+w+1,int.from_bytes(code[pc+1:pc+w+1],'big'));pc+=w+1
 dests={p for p,i in ins.items() if i[0]==0x5b};out.mkdir(parents=True,exist_ok=True)
 pc=7156;stack=[0x9ae8e8ea,1362,100,1,0,96,0,0];expr=['0x9ae8e8ea','1362','I.Offset(data)+36','I.Length(data)','I.Index(data)','96','0',POS];memory='O.InitialHeap()';bank={64:128};nodes=[];required={};seen=set()
 def pop():return stack.pop(),expr.pop()
 def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
 while True:
  assert (pc,tuple(stack),memory) not in seen;seen.add((pc,tuple(stack),memory));op,nxt,imm=ins[pc];required.update({i:code[i] for i in range(pc,nxt)});n={'id':len(nodes),'pc':pc,'opcode':op,'next':nxt,'immediate':imm,'stack':expr.copy(),'memory':memory};nodes.append(n)
  if op==0x5f or 96<=op<=127:push(imm)
  elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
  elif op==0x50:pop()
  elif op==0x15:v,e=pop();push(int(v==0),f'Bool(({e})==0)' if 'data' in e else None)
  elif op==0x19:v,e=pop();push(MOD-1-v,f'M-1-({e})' if 'data' in e else None)
  elif op in [1,2,3,4,0x11,0x16]:
   a,ae=pop();b,be=pop();v={1:lambda:(a+b)%MOD,2:lambda:(a*b)%MOD,3:lambda:(a-b)%MOD,4:lambda:0 if b==0 else a//b,0x11:lambda:int(a>b),0x16:lambda:a&b}[op]()
   e={1:f'(({ae})+({be}))%M',2:f'(({ae})*({be}))%M',3:f'(({ae})+M-({be}))%M',4:f'(if ({be})==0 then 0 else ({ae})/({be}))',0x11:f'Bool(({ae})>({be}))',0x16:f'BitAnd({ae},{be})'}[op]
   if pc==20338:assert v==100;e=SRC;n['sourceProjection']=True
   if pc==20343:assert v==1;e='1';n['oneCount']=True
   if op==0x16:assert(a,b)==(32,MOD-32);n['alignOne']=True
   push(v,e if 'data' in ae+be or n.get('sourceProjection') else None)
  elif op==0x51:
   at,_=pop();assert at in bank;push(bank[at]);n['load']=at
  elif op==0x52:
   at,_=pop();value,ve=pop();bank[at]=value;n['store']=[at,ve]
   if (at,value)==(64,192):memory='O.Allocated()'
   elif (at,value)==(128,1):memory='O.TemporaryHeader()'
   elif (at,value)==(161,0):memory=f'O.Temporary(data,{SRC})'
   elif (at,value)==(192,32):memory=f'O.OffsetHeader(data,{SRC})'
   elif (at,value)==(224,1):memory=f'O.LengthHeader(data,{SRC})'
   elif (at,value)==(257,0):memory='Finished(data)'
   else:raise ValueError((pc,at,value))
  elif op==0x37:
   at,_=pop();source,se=pop();count,_=pop()
   if pc==18907:assert candidateCopy and (at,source,count)==(256,160,1);memory='Copied(data)';n['candidateCopy']=True
   else:assert(at,source,count)==(160,100,1);memory=f'O.Selected(data,{SRC})'
   n['copy']=True
  elif op==0x5e:
   at,_=pop();source,_=pop();count,_=pop();assert(at,source,count)==(256,160,1);memory='Copied(data)';n['move']=True
  elif op==0x5b:pass
  elif op in [0x56,0x57]:
   dest,_=pop();take=op==0x56 or pop()[0]!=0;assert dest in dests;n['jump']=dest;required[dest]=code[dest]
   if take:nxt=dest
  elif op==0xf3:
   at,_=pop();count,_=pop();assert(at,count)==(192,96);n['terminal']=True;break
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(required.items()));jumps=sorted({n['jump'] for n in nodes if 'jump' in n});good='\n'.join('    '+('if' if i==0 else 'else if')+f" id=={i} then state==Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for i,n in enumerate(nodes))+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical original-byte serialization. Never edit directly.
include "../byte-at-body-support/Kernel.dfy"
module OperationsByteAtSerialization {{
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import N = OperationsByteAtIndices
  import B = OperationsByteAtMemory
  import K = OperationsByteAtAdmissionKernel
  import S = OperationsByteAtBodyKernel
  import O = OperationsByteAtOutput
  predicate Valid(data:seq<Byte>) {{ I.Frame(data) && I.Span(data) && N.FitsIndex(I.Index(data),I.Length(data)) }}
  function Position(data:seq<Byte>):Word
    requires Valid(data)
  {{ N.Position(I.Index(data),I.Length(data)) }}
  function Source(data:seq<Byte>):Word
    requires Valid(data)
    ensures Source(data)<|data|
  {{ N.OriginalByteWindow(I.Offset(data),I.Length(data),I.Index(data),|data|);I.Offset(data)+36+Position(data) }}
  function Copied(data:seq<Byte>):seq<Byte>
    requires Valid(data)
  {{ {('B.Copy(O.LengthHeader(data,Source(data)),data,160,256,1)' if candidateCopy else 'O.Copied(data,Source(data))')} }}
  function Finished(data:seq<Byte>):seq<Byte>
    requires Valid(data)
  {{ K.StoreWord(Copied(data),257,0) }}
  predicate Admitted(value:Word,data:seq<Byte>) {{ value==0 && I.Assigned(data,value) && Valid(data) }}
  opaque predicate Matches(code:seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations():set<nat> {{ {{{','.join(map(str,jumps))}}} }}
  opaque predicate Good(id:nat,state:State,value:Word,data:seq<Byte>)
    requires Valid(data)
  {{
{good}
  }}
'''
 for n in nodes:
  i=n['id'];post=f'Good({i+1},next,value,data)' if not n.get('terminal') else 'next==Returned(I.ByteEnvelope(data[Source(data)]))';body='    reveal Good();reveal Matches();reveal Step();\n    N.OriginalByteWindow(I.Offset(data),I.Length(data),I.Index(data),|data|);O.Sizes(data,Source(data));\n'
  if 96<=n['opcode']<=127:
   w=n['opcode']-95
   for k in range(1,w+1):body+=f"    assert I.Load(code,{n['pc']+1},{k})=={int.from_bytes(code[n['pc']+1:n['pc']+1+k],'big')};\n"
  body+=f"    assert Fetch(code,{n['pc']})==Op({n['opcode']},{n['next']},{n['immediate']});\n"
  if n.get('load'):body+='    S.HeapLoads(data,Source(data));S.TemporaryLength(data,Source(data));\n'
  if n.get('alignOne'):body+='    S.AlignOne();\n'
  if n.get('terminal'):body+='    O.Receipt(data,Source(data));\n'
  text+=f'''  lemma Advance{i}(code:seq<Byte>,state:State,value:Word,data:seq<Byte>)
    requires Matches(code) && Admitted(value,data) && Good({i},state,value,data)
    ensures var next:=Step(code,Destinations(),state,value,data); {post}
  {{
{body}  }}
'''
 copiedNode=next(n for n in nodes if n['pc']==18908)
 witnessBody='B.CopiedByte(O.LengthHeader(data,Source(data)),data,160,256,1,0);' if candidateCopy else 'O.OriginalByte(data,Source(data));'
 text+=f'''  lemma SemanticWitness(state:State,value:Word,data:seq<Byte>)
    requires Admitted(value,data) && Good({copiedNode['id']},state,value,data)
    requires Source(data)==100 && data[Source(data)]==165 && I.Cell(data,160)==0
    ensures state.Running? && |state.memory|>256
    ensures state.memory[256]==165
  {{ reveal Good(); {witnessBody} }}
'''
 text+='''  lemma Start(value:Word,data:seq<Byte>)
    requires Admitted(value,data)
    ensures Good(0,Running(7156,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data),96,0,Position(data)],O.InitialHeap()),value,data)
  { reveal Good(); }
}
'''
 (out/'Control.generated.dfy').write_text(text);(out/'serialization.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'requiredBytes':required,'states':nodes,'scope':'Unverified complete actual original-byte allocation/copy/serialization certificate'},indent=2)+'\n');print('Complete physical byteAt serialization',len(nodes),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
