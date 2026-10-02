#!/usr/bin/env python3
"""Generate exact private strict-index transitions with arbitrary preserved stack prefix."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;H=MOD//2
CASES={'InvalidHigh':(0,0),'InvalidLow':(0,MOD-1),'Positive':(1,0),'Negative':(1,MOD-1)}
def signed(x):return x if x<H else x-MOD
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['stringAt(bytes,int256)']=='a1bc2139'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,(length,word) in CASES.items():
  pc=11497;stack=[7302,word,length];expr=['ret','word','length'];pyexpr=expr[:];memory='K.Initial()';nodes=[];dests=set();seen=set()
  def pop():return stack.pop(),expr.pop(),pyexpr.pop()
  def push(v,e=None,p=None):stack.append(v);expr.append(str(v) if e is None else e);pyexpr.append(str(v) if p is None else p)
  while pc!=7302:
   assert (pc,tuple(stack),memory) not in seen;seen.add((pc,tuple(stack),memory));op,nxt,imm=ins[pc];n=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr[:],pythonStack=pyexpr[:],memory=memory,guides=[]);nodes.append(n)
   if op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k],pyexpr[-k])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1];pyexpr[-1],pyexpr[-1-k]=pyexpr[-1-k],pyexpr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e,p=pop();push(int(v==0),f'Bool(({e})==0)',f'int(({p})==0)')
   elif op in [1,3,0x12,0x16,0x17,0x1b]:
    a,ae,ap=pop();b,be,bp=pop();v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,0x12:lambda:int(signed(a)<signed(b)),0x16:lambda:a&b,0x17:lambda:a|b,0x1b:lambda:(b<<a)%MOD if a<256 else 0}[op]()
    e={1:f'(({ae})+({be}))%G.Modulus()',3:f'(({ae})+G.Modulus()-({be}))%G.Modulus()',0x12:f'Bool(G.Signed({ae})<G.Signed({be}))',0x16:f'G.BitAnd({ae},{be})',0x17:f'G.BitOr({ae},{be})',0x1b:f'S.ShiftLeft({be},{ae})'}[op]
    p={1:f'(({ap})+({bp}))%MOD',3:f'(({ap})+MOD-({bp}))%MOD',0x12:f'int(signed({ap})<signed({bp}))',0x16:f'(({ap})&({bp}))',0x17:f'(({ap})|({bp}))',0x1b:f'(({bp})<<({ap}))%MOD'}[op]
    if op in [0x16,0x17]:n['guides'].append(f'BooleanBits({ae},{be});')
    if op==0x1b:
     if (a,b)==(255,1):e='G.Modulus()/2';p='H';n['guides'].append('HalfWordShift();')
     elif (a,b)==(225,0x6fbae5d7):e='Err.Header()';p='0xdf75cbae<<224';n['guides'].append('Err.HeaderLiteral();')
     else:raise AssertionError((name,pc,a,b))
    if not any(t in ae+be for t in ['word','length','G.Modulus','Err.Header','Bool']) and op!=0x1b:e=str(v);p=str(v)
    push(v,e,p)
   elif op==0x51:
    at,_,_=pop();assert at==64;push(128);n['guides'].append('K.InitialFits();Err.Frame(word,length);')
   elif op==0x52:
    at,_,_=pop();v,e,_=pop()
    if at==128:assert e=='Err.Header()';memory='Err.SelectorStored()'
    elif at==132:assert e=='word';memory='Err.IndexStored(word)'
    elif at==164:assert e=='length';memory='Err.Finished(word,length)'
    else:raise AssertionError((name,pc,at,e))
   elif op==0x5b:pass
   elif op in [0x56,0x57]:
    dest,de,_=pop();take=op==0x56 or pop()[0]!=0;assert ins[dest][0]==0x5b;dests.add('ret' if de=='ret' else str(dest));n['jump']='ret' if de=='ret' else dest
    if take:nxt=dest
   elif op==0xfd:
    at,_,_=pop();count,_,_=pop();assert (at,count)==(128,68);n['terminal']=True;n['guides'].append('Err.Receipt(word,length);');break
   else:raise AssertionError((name,pc,hex(op)))
   pc=nxt;assert len(nodes)<150
  final='M.Frame(S.Reverted(I.Packet(I.InvalidByteIndex(word,length))),[],0)' if nodes[-1].get('terminal') else 'M.Frame(S.Running(ret,prefix+[I.Position(word,length)],K.Initial()),[],0)'
  ds='{'+','.join(sorted(dests))+'}'
  params='code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,ret:S.Word,word:S.Word,length:S.Word,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>'
  vals='code,destinations,prefix,ret,word,length,self,value,data,observations'
  core='prefix,ret,word,length';step='F.Step(code,destinations,state,self,value,data,observations)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact private strict-index path; native closure remains pending.
include "../string-at-kernel/StrictIndex.dfy"
include "../string-at-kernel/IndexError.dfy"
module OperationsStringAtIndex{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import CM = BytecodeCopyMachine
  import F = OperationsCaseFoldMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsStringAtInputs
  import K = OperationsStringAtKernel
  import N = OperationsStringAtStrictIndex
  import Err = OperationsStringAtIndexError
  function Bool(x:bool):S.Word {{ if x then 1 else 0 }}
  predicate Admitted(prefix:seq<S.Word>,ret:S.Word,word:S.Word,length:S.Word) {{ |prefix|<=980 && length<I.U64 && N.Class(word,length)==N.{name} }}
  predicate Matches(code:seq<S.Byte>,ret:S.Word) {{ ret<|code| && code[ret]==0x5b &&
'''
  text+='    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  consts=sorted(int(x) for x in dests if x!='ret');text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in consts)+'\n  }\n'
  text+=f'  function Destinations(ret:S.Word):set<nat> {{ {ds} }}\n'
  text+='  opaque predicate Good(id:nat,state:M.Frame,prefix:seq<S.Word>,ret:S.Word,word:S.Word,length:S.Word)\n    requires Admitted(prefix,ret,word,length)\n  {\n'
  for n in nodes:text+=f'    {"if" if n["id"]==0 else "else if"} id=={n["id"]} then state==M.Frame(S.Running({n["pc"]},prefix+['+','.join(n['stack'])+f'],{n["memory"]}),[],0)\n'
  text+=f'    else if id=={len(nodes)} then state=={final}\n    else false\n  }}\n'
  text+='''  lemma BooleanBits(a:S.Word,b:S.Word)
    requires a<=1 && b<=1
    ensures G.BitAnd(a,b)==(if a==1 && b==1 then 1 else 0)
    ensures G.BitOr(a,b)==(if a==1 || b==1 then 1 else 0)
  { if a==0 { if b==0 {} else {} } else { if b==0 {} else {} } }
  lemma HalfWordShift()
    ensures S.ShiftLeft(1,255)==G.Modulus()/2
  { reveal S.ShiftLeft(); }
'''
  for n in nodes:
   i=n['id'];guides=''.join(n['guides']);text+=f'''  lemma Advance{i}({params},state:M.Frame)
    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({core}) && Good({i},state,{core})
    ensures Good({i+1},{step},{core})
  {{ N.Bridge(word,length);N.Partition(word,length);N.NegatedLength(length);
'''
   if name in ['Positive','Negative']:text+=f'    N.{name}Result(word,length);\n'
   text+=f'    reveal Good();{guides}F.Delegate(code,destinations,state,self,value,data,observations);M.Delegate(code,destinations,state,self,value,data,observations);CM.Delegate(code,destinations,state.state,value,data);reveal S.Step();reveal G.Step();\n  }}\n'
  chunks=[]
  for ci,lo in enumerate(range(0,len(nodes),12)):
   hi=min(lo+12,len(nodes));chunks.append(ci);text+=f'''  ghost method Chunk{ci}({params},initial:M.Frame) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({core}) && Good({lo},initial,{core})
    ensures Good({hi},state,{core})
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|=={hi-lo+1} && trace[0]==initial && trace[|trace|-1]==state
  {{ state:=initial;trace:=[state];
'''
   for i in range(lo,hi):text+=f'    Advance{i}({vals},state);reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];\n'
   text+='  }\n'
  text+=f'''  ghost method Run({params}) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code,ret) && Destinations(ret)<=destinations && Admitted({core})
    ensures state=={final}
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|=={len(nodes)+1} && trace[0]==M.Frame(S.Running(11497,prefix+[ret,word,length],K.Initial()),[],0) && trace[|trace|-1]==state
  {{ state:=M.Frame(S.Running(11497,prefix+[ret,word,length],K.Initial()),[],0);trace:=[state];reveal Good();assert Good(0,state,{core});
'''
  for ci in chunks:text+=f'    var next{ci},part{ci}:=Chunk{ci}({vals},state);E.Join(code,destinations,self,value,data,observations,trace,part{ci});trace:=trace+part{ci}[1..];state:=next{ci};\n'
  text+='    reveal Good();\n  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);paths.append(dict(name=name,states=nodes,terminal=final,destinations=sorted(dests)));print(name,len(nodes))
 (out/'mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),entry=11497,paths=paths),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
