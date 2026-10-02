#!/usr/bin/env python3
"""Derive both exact stringAt selected-cell paths from original bytes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;SIG=0xa1bc2139

def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,length,cell in [('Ascii',1,65),('NonAscii',2,194)]:
  pc=7302;stack=[SIG,1362,100,length,0,96,0,0];expr=[hex(SIG),'1362','offset','length','word','96','0','position'];py=[str(SIG),'1362','offset','length','word','96','0','position'];memory='K.Initial()';nodes=[];dests=set();seen=set()
  def pop():return stack.pop(),expr.pop(),py.pop()
  def push(v,e=None,p=None):stack.append(v);expr.append(str(v) if e is None else e);py.append(str(v) if p is None else p)
  while pc!=1362:
   assert (pc,tuple(stack),memory) not in seen;seen.add((pc,tuple(stack),memory));op,nxt,imm=ins[pc];n=dict(id=len(nodes),pc=pc,opcode=op,next=nxt,immediate=imm,stack=expr[:],pythonStack=py[:],memory=memory,guides=[]);nodes.append(n)
   if op==95 or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k],py[-k])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1];py[-1],py[-1-k]=py[-1-k],py[-1]
   elif op==80:pop()
   elif op==21:v,e,p=pop();push(int(v==0),f'Bool(({e})==0)',f'int(({p})==0)')
   elif op==0x35:
    at,e,p=pop();assert at==100;push(cell<<248,f'S.DataWord(data,{e})',f'load({p})')
   elif op==81:
    at,e,p=pop();assert at==64;push(128);n['guides'].append('K.InitialFits();U.FreePreserved(K.Initial(),position);')
   elif op==82:
    at,ae,_=pop();v,e,p=pop()
    if pc==7208:assert (at,v)==(64,192);memory='B.FreeSet()'
    elif pc==7216:assert (at,v)==(128,1);memory='B.Header()'
    elif pc==7232:assert (at,v)==(161,0);memory='B.Finished(data,offset,length,position)'
    elif pc==7358:assert at==128;memory='U.FirstError(K.Initial())';n['guides'].append('U.HeadLiteral();')
    elif pc==7365:assert at==132;memory='U.ErrorMemory(K.Initial(),position)'
    else:raise AssertionError((name,pc,at,v))
   elif op==55:
    at,ae,_=pop();source,se,_=pop();count,ce,_=pop();assert (pc,at,source,count)==(7225,160,100,1);memory='B.Copied(data,offset,length,position)'
   elif op in [1,2,3,4,16,17,22,27,28]:
    a,ae,ap=pop();b,be,bp=pop();v={1:lambda:(a+b)%MOD,2:lambda:(a*b)%MOD,3:lambda:(a-b)%MOD,4:lambda:0 if b==0 else a//b,16:lambda:int(a<b),17:lambda:int(a>b),22:lambda:a&b,27:lambda:(b<<a)%MOD if a<256 else 0,28:lambda:b>>a if a<256 else 0}[op]()
    e={1:f'(({ae})+({be}))%G.Modulus()',2:f'(({ae})*({be}))%G.Modulus()',3:f'(({ae})+G.Modulus()-({be}))%G.Modulus()',4:f'(if ({be})==0 then 0 else ({ae})/({be}))',16:f'Bool(({ae})<({be}))',17:f'Bool(({ae})>({be}))',22:f'G.BitAnd({ae},{be})',27:f'S.ShiftLeft({be},{ae})',28:f'S.ShiftRight({be},{ae})'}[op]
    p={1:f'(({ap})+({bp}))%MOD',2:f'(({ap})*({bp}))%MOD',3:f'(({ap})+MOD-({bp}))%MOD',4:f'(0 if ({bp})==0 else ({ap})//({bp}))',16:f'int(({ap})<({bp}))',17:f'int(({ap})>({bp}))',22:f'(({ap})&({bp}))',27:f'(({bp})<<({ap}))%MOD',28:f'(({bp})>>({ap}))'}[op]
    known={7327:('offset+position','offset+position'),20235:('position+1','position+1'),20338:('offset+position','offset+position'),20343:('1','1'),7190:('32','32'),7195:('1','1'),7196:('32','32'),7199:('64','64'),7205:('192','192'),7219:('160','160'),7228:('161','161'),7362:('132','132'),7368:('164','164'),3244:('36','36')}
    if pc in known:e,p=known[pc]
    elif pc in [7331,7337,7340]:
     e='B.Cell(data,offset,length,position)';p='cell';n['guides'].append('U.First(data,offset,length,position,0);' if pc==7331 else 'U.ShiftCell(B.Cell(data,offset,length,position));' if pc==7337 else 'U.Mask(B.Cell(data,offset,length,position));')
    elif pc==7356:e='U.Head()';p='0x41972036<<224';n['guides'].append('U.HeadLiteral();')
    elif ae.isdecimal() and be.isdecimal():e=str(v);p=str(v)
    push(v,e,p)
   elif op==91:pass
   elif op in [86,87]:
    target,te,_=pop();take=op==86 or pop()[0]!=0;assert ins[target][0]==91 and te.isdecimal();dests.add(target)
    if take:nxt=target
   elif op==253:
    at,_,_=pop();count,_,_=pop();assert (at,count)==(128,36);n['guides'].append('U.ErrorPacket(K.Initial(),position);');n['terminal']=True;break
   else:raise AssertionError((name,pc,hex(op)))
   pc=nxt;assert len(nodes)<=170
  assert len(nodes)=={'Ascii':146,'NonAscii':53}[name]
  params='offset:S.Word,length:S.Word,word:S.Word,position:S.Word,data:seq<S.Byte>,self:S.Word,value:S.Word,observations:seq<M.Observation>';args='offset,length,word,position,data,self,value,observations';step='F.Step(code,destinations,state,self,value,data,observations)';first='M.Frame(S.Running(7302,[0xa1bc2139,1362,offset,length,word,96,0,position],K.Initial()),[],0)';final='M.Frame(S.Running(1362,[0xa1bc2139,128],B.Finished(data,offset,length,position)),[],0)' if name=='Ascii' else 'M.Frame(S.Reverted(U.Packet(position)),[],0)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact selected-cell body, including one-byte copy; native pending.
include "Memory.dfy"
module OperationsStringAtBody{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import CM = BytecodeCopyMachine
  import M = BytecodeExternalMachine
  import F = OperationsCaseFoldMachine
  import E = OperationsCaseFoldExecution
  import U = OperationsUtf8Kernel
  import K = OperationsStringAtKernel
  import B = OperationsStringAtBodyMemory
  function Bool(x:bool):S.Word {{ if x then 1 else 0 }}
  predicate Admitted({params}) {{ U.Memory(K.Initial()) && B.Input(data,offset,length,position) && B.Cell(data,offset,length,position){'<' if name=='Ascii' else '>='}128 }}
  predicate Matches(code:seq<S.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))+'\n  }\n';text+='  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n';text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params}) requires Admitted({args}) {{\n'
  for n in nodes:text+=f'    {"if" if n["id"]==0 else "else if"} id=={n["id"]} then state==M.Frame(S.Running({n["pc"]},['+','.join(n['stack'])+f'],{n["memory"]}),[],0)\n'
  text+=f'    else if id=={len(nodes)} then state=={final}\n    else false\n  }}\n'
  for n in nodes:
   i=n['id'];delegates='F.Delegate(code,destinations,state,self,value,data,observations);M.Delegate(code,destinations,state,self,value,data,observations);'+('reveal CM.Step();' if n['opcode']==55 else 'CM.Delegate(code,destinations,state.state,value,data);');text+=f'''  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})
    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})
    ensures Good({i+1},{step},{args})
  {{ B.Bounds(data,offset,length,position);B.Stages(data,offset,length,position);K.InitialFits();
    reveal Good();{''.join(n['guides'])}{delegates}reveal S.Step();reveal G.Step();
  }}
'''
  chunks=[]
  for ci,lo in enumerate(range(0,len(nodes),12)):
   hi=min(lo+12,len(nodes));chunks.append(ci);text+=f'''  ghost method Chunk{ci}(code:seq<S.Byte>,destinations:set<nat>,initial:M.Frame,{params}) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({lo},initial,{args})
    ensures Good({hi},state,{args})
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|=={hi-lo+1} && trace[0]==initial && trace[|trace|-1]==state
  {{ state:=initial;trace:=[state];
'''
   for i in range(lo,hi):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];\n'
   text+='  }\n'
  text+=f'''  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && Admitted({args})
    ensures state=={final}
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|=={len(nodes)+1} && trace[0]=={first} && trace[|trace|-1]==state
  {{ state:={first};trace:=[state];reveal Good();assert Good(0,state,{args});
'''
  for ci in chunks:text+=f'    var next{ci},part{ci}:=Chunk{ci}(code,destinations,state,{args});E.Join(code,destinations,self,value,data,observations,trace,part{ci});trace:=trace+part{ci}[1..];state:=next{ci};\n'
  text+='    reveal Good();\n  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);paths.append(dict(name=name,states=nodes,terminal=final,destinations=sorted(dests)));print(name,len(nodes))
 (out/'mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),entry=7302,paths=paths),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
