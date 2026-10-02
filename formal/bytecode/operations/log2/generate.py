#!/usr/bin/env python3
"""Generate full five-path log2 certificates from actual current instruction bytes.

Rejections, zero custom error and positive branchless library have complete
complementary raw guards. No theorem or public credit is supplied by generation.
"""
import argparse, hashlib, json
from pathlib import Path
if not __debug__: raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256
CASES={'Nonzero':(1,0,0),'Short':(0,0,0),'Args':(0,4,0),'Zero':(0,36,0),'Positive':(0,36,4)}
GUARDS={'Nonzero':'value!=0','Short':'value==0 && size<4','Args':'value==0 && 4<=size<36 && Selector(word)==0x5456bf13','Zero':'value==0 && 36<=size<0x10000000000000000 && Selector(word)==0x5456bf13 && a==0','Positive':'value==0 && 36<=size<0x10000000000000000 && Selector(word)==0x5456bf13 && a>0'}
def signed(v):return v if v<M//2 else v-M

def generate(out,runtime=None):
 inv=json.loads((HERE.parent/'inventory.json').read_text());artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=runtime.read_bytes() if runtime else bytes.fromhex(artifact['deployedBytecode'][2:])
 if not runtime:assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'] and len(code)==inv['runtimeBytes']
 assert inv['compilerIdentity']['methodIdentifiers']['log2(uint256)']=='5456bf13'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width].ljust(width,b'\0'),'big'));pc+=width+1
 dests={p for p,x in ins.items() if x[0]==0x5b};out.mkdir(parents=True,exist_ok=True)
 for name,(value,size,a) in CASES.items():
  pc=0;stack=[];expr=[];memory='[]';memvals={};nodes=[];required={};seen=set();word=int('5456bf13',16)<<224
  def pop():return stack.pop(),expr.pop()
  def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
  while True:
   state=(pc,tuple(stack),tuple(expr),memory);assert state not in seen;seen.add(state)
   op,nxt,imm=ins[pc];assert nxt<=len(code);required.update({i:code[i] for i in range(pc,nxt)})
   node=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr.copy(),memory=memory);nodes.append(node)
   if op==0x5f or 0x60<=op<=0x7f:push(imm)
   elif op==0x34:push(value,'value')
   elif op==0x36:push(size,'size')
   elif op==0x35:
    at,_=pop();assert at in [0,4];push(word if at==0 else a,'word' if at==0 else 'a')
   elif 0x80<=op<=0x8f:k=op-0x7f;push(stack[-k],expr[-k])
   elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e=pop();push(int(v==0),f'K.Bool(({e})==0)' if any(t in e for t in ['a','word','size','value','K.']) else None)
   elif op in [0x01,0x03,0x04,0x10,0x11,0x12,0x14,0x16,0x17,0x1a,0x1b,0x1c]:
    top,te=pop();below,be=pop()
    v={0x01:lambda:(top+below)%M,0x03:lambda:(top-below)%M,0x04:lambda:0 if below==0 else top//below,0x10:lambda:int(top<below),0x11:lambda:int(top>below),0x12:lambda:int(signed(top)<signed(below)),0x14:lambda:int(top==below),0x16:lambda:top&below,0x17:lambda:top|below,0x1a:lambda:0 if top>=32 else (below>>(8*(31-top)))&255,0x1b:lambda:(below<<top)%M if top<256 else 0,0x1c:lambda:below>>top if top<256 else 0}[op]()
    ex={0x01:f'((({te}) as nat)+(({be}) as nat))%Modulus()',0x03:f'((({te}) as nat)+Modulus()-(({be}) as nat))%Modulus()',0x04:f'Quotient({te},{be})',0x10:f'K.Bool(({te})<({be}))',0x11:f'K.Bool(({te})>({be}))',0x12:f'K.Bool(Signed({te})<Signed({be}))',0x14:f'K.Bool(({te})==({be}))',0x16:f'BitAnd({te},{be})',0x17:f'BitOr({te},{be})',0x1a:f'ByteWord({te},{be})',0x1b:f'Shift({be},{te})',0x1c:f'Right({be},{te})'}[op]
    symbolic=any(t in te+be for t in ['a','word','size','value','K.'])
    if op==0x1c and te=='224' and be=='word':ex=str(int('5456bf13',16));node['selector']=True;symbolic=True
    if pc==11017 and op==0x1b:assert v in [0,128];ex='K.R128(a)';node['initialFlag']=True;symbolic=True
    aliases={11036:64,11050:32,11062:16,11073:8,11105:4}
    if pc in aliases and op==0x17:node['orAlias']=[te,be,aliases[pc]];ex=f'K.R{aliases[pc]}(a)';symbolic=True
    if op==0x1b and (below,top) in [(1,64),(0x101020202020303030303030303,128),(0x7e8300b,228)]:node['fixedShift']=[below,top,v]
    push(v,ex if symbolic else None)
   elif op==0x52:
    at,_=pop();v,e=pop();assert at in [64,128,132];node['store']=[at,e];memory=f'Store({memory},{at},{e})';memvals[at]=(v,e)
   elif op==0x51:
    at,_=pop();assert at==64;push(*memvals[at]);node['load']=True;node['outputWord']=memvals.get(128,(0,'0'))[1]
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    at,_=pop();take=op==0x56 or pop()[0]!=0;assert at in dests;node['jump']=at;required[at]=code[at]
    if take:nxt=at
   elif op in [0xf3,0xfd]:
    at,_=pop();width,_=pop()
    if op==0xf3:assert name=='Positive' and (at,width)==(128,32);node['returned']=True;node['outputWord']=memvals[128][1]
    elif name=='Zero':assert (at,width)==(128,36);node['undefined']=True
    else:assert (at,width)==(0,0);node['rejected']=True
    break
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt;assert len(stack)<=1024
  maximum=max(len(n['stack']) for n in nodes);destinations=sorted({n['jump'] for n in nodes if 'jump' in n});constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id=={n['id']} then state==Running({n['pc']},[{','.join(n['stack'])}],{n['memory']})" for n in nodes)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact current log2 executed-byte certificate. Never edit directly.
include "Kernel.dfy"
include "Binary.dfy"
module OperationsBytecodeLog2{name} {{
  import opened OperationsBytecodeLog2Machine
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  function Result(a: Word): Word {{ F.Log(a)%Modulus() }}
  predicate Admitted(value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) {{ {GUARDS[name]} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,destinations))}}} }}
  opaque predicate Good(id: nat,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) {{
{good}
  }}
'''
  for n in nodes:
   i=n['id'];op=n['opcode'];st='['+','.join(n['stack'])+']';mem=n['memory'];guide=f'    reveal Good(); reveal Matches(); reveal Step();\n    assert state==Running({n["pc"]},{st},{mem});\n'
   if 0x60<=op<=0x7f:
    for w in range(1,op-0x5f+1):guide+=f'    assert Immediate(code,{n["pc"]+1},{w})=={int.from_bytes(code[n["pc"]+1:n["pc"]+1+w],"big")};\n'
   guide+=f'    assert Fetch(code,{n["pc"]})==Op({op},{n["next"]},{n["immediate"]});\n'
   if n.get('selector'):guide+='    SelectorRight(word);\n'
   if n.get('initialFlag'):guide+='    K.InitialOpcode(a);\n'
   if n.get('orAlias'):
    te,be,k=n['orAlias'];guide+=f'    SymmetricBits({te},{be});\n    assert BitOr({te},{be})==K.R{k}(a);\n'
   if n.get('fixedShift'):guide+='    K.FixedShift('+','.join(map(str,n['fixedShift']))+');\n'
   if 'jump' in n:guide+=f'    assert {n["jump"]} in Destinations() && code[{n["jump"]}]==0x5b;\n'
   if n.get('load'):
    guide+='    StoreLoad([],64,128);\n'
    if mem!='Store([],64,128)':
     if name=='Zero':guide+='    StoreFrame(Store([],64,128),128,K.ErrorWord,64);\n    StoreFrame(Store(Store([],64,128),128,K.ErrorWord),132,0,64);\n'
     else:guide+=f'    StoreFrame(Store([],64,128),128,{n["outputWord"]},64);\n'
   if n.get('store'):at,e=n['store'];guide+=f'    StoreLoad({mem},{at},{e});\n'
   if n.get('returned'):
    guide+=f'    StoreLoad(Store([],64,128),128,{n["outputWord"]});\n    SymmetricBits(ByteWord(Right(a,K.R4(a)),K.Table),K.R4(a));\n    K.Pipeline(a);\n'
   if n.get('undefined'):guide+='    K.ErrorStores(Store([],64,128));\n'
   post='next==Returned(Encode(Result(a),32))' if n.get('returned') else 'next==Reverted(K.Undefined())' if n.get('undefined') else 'next==Reverted([])' if n.get('rejected') else f'Good({i+1},next,value,size,word,a,b,c)'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good({i},state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<={maximum} && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); {post}
  {{
{guide}  }}
'''
  if name=='Positive':
   checkpoint=next(n for n in nodes if n.get('store',[None])[0]==128);condition='state.stack[|state.stack|-2]==Result(a)'
   for label,fixed in [('SemanticResult',''),('SemanticWitness','    requires a==4\n')]:
    text+=f'''  lemma {label}(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good({checkpoint['id']},state,value,size,word,a,b,c)
{fixed}    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures {condition}
  {{ reveal Good(); K.Pipeline(a); {('K.FourthInput(); K.OrZero(Right(K.Table,4));' if label=='SemanticWitness' else '')} SymmetricBits(ByteWord(Right(a,K.R4(a)),K.Table),K.R4(a)); }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,value,size,word,a,b,c);\n    state:=Step(code,Destinations(),state,value,size,word,a,b,c);' for i in range(len(nodes)))
  outcome='Returned(Encode(Result(a),32))' if name=='Positive' else 'Reverted(K.Undefined())' if name=='Zero' else 'Reverted([])'
  text+=f'''  ghost method Run(code: seq<Byte>,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c)
    ensures state=={outcome}
  {{
    reveal Good(); state:=Running(0,[],[]); assert Good(0,state,value,size,word,a,b,c);
{calls}
  }}
}}
'''
  (out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(name=name,runtimeSha256=hashlib.sha256(code).hexdigest(),runtimeBytes=len(code),candidateRuntime=bool(runtime),maximumStackWords=maximum,requiredBytes=required,states=nodes,scope='Unverified complete raw log2 current executed-byte trace; no public credit'),indent=2)+'\n');print(name,len(nodes))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
