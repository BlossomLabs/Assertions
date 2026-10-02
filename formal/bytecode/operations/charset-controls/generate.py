#!/usr/bin/env python3
"""Extract exact charset initialization, completion, rejection and next iteration."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;SIG=0x3e8c97e3
CASES={'Start':(4121,[SIG,1289,100,1,0],[str(SIG),'1289','offset','length','mask'],4124,'true'),
'Done':(4124,[SIG,1289,100,0,0,0,0],[str(SIG),'1289','offset','length','mask','0','index'],None,'index==length'),
'Reject':(4124,[SIG,1289,100,1,0,0,0],[str(SIG),'1289','offset','length','mask','0','index'],None,'index<length && !I.Member(mask,data[offset+index])'),
'Next':(4124,[SIG,1289,100,1,128,0,0],[str(SIG),'1289','offset','length','mask','0','index'],4124,'index<length && I.Member(mask,data[offset+index])')}
def generate(out,runtime=None):
 inv=json.loads((HERE.parent/'inventory.json').read_text());canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(canonical).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['charset(bytes,uint256)']=='3e8c97e3';code=runtime.read_bytes() if runtime else canonical
 if runtime:assert len(code)==len(canonical) and [i for i,(a,b) in enumerate(zip(code,canonical)) if a!=b]==[4164] and canonical[4164]==16 and code[4164]==17
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 out.mkdir(parents=True,exist_ok=True);mappings=[]
 for name,(start,values,expressions,stop,guard) in CASES.items():
  vals=values[:];expr=expressions[:];pc=start;memory='mem';nodes=[];dests=set();terminal=None
  def pop():return vals.pop(),expr.pop()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  while True:
   op,nxt,imm=ins[pc];before=expr[:];oldMemory=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;assert k<=len(vals);push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;assert k<len(vals);vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e=pop();push(int(v==0),f'(if ({e})==0 then 1 else 0)' if not e.isdecimal() else None)
   elif op==0x35:
    at,ae=pop();assert at==100;push(7<<248,'S.DataWord(data,offset+index)')
   elif op in [1,3,16,22,23,27,28]:
    a,ae=pop();b,be=pop();v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,16:lambda:int(a<b),22:lambda:a&b,23:lambda:a|b,27:lambda:(b<<a)%MOD if a<256 else 0,28:lambda:b>>a if a<256 else 0}[op]()
    if ae.isdecimal() and be.isdecimal():push(v)
    elif op==1:
     assert {ae,be} in [{'offset','index'},{'index','1'}];push(v,'offset+index' if ae=='offset' or be=='offset' else 'index+1')
    elif op==3:
     assert ae=='0';push(v,f'(G.Modulus()-({be}))%G.Modulus()')
    elif op==16:push(v,f'(if ({ae})<({be}) then 1 else 0)')
    elif op==27:
     assert be=='1';push(v,f'S.ShiftLeft(1,{ae})');guide+='reveal S.ShiftLeft();'
    elif op==28:
     assert ae=='248';push(v,f'S.ShiftRight({be},248)');guide+='K.First(data,offset,length,index);'
    else:push(v,('G.BitAnd' if op==22 else 'G.BitOr')+f'({ae},{be})')
   elif op==0x51:
    at,_=pop();assert at==64;push(128)
    if memory!='mem':guide+=f'K.ReturnLayout(mem,{0 if name=="Reject" else 1});'
   elif op==0x52:
    at,_=pop();value,ve=pop();assert at==128 and value in [0,1];memory=f'S.Store(mem,128,{value})';guide+=f'K.ReturnLayout(mem,{value});'
   elif op in [0x56,0x57]:
    target,te=pop();assert te.isdecimal();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;dests.add(target)
    if pc==4172:guide+='K.Flag(data,offset,length,index,mask);'
    if take:nxt=target
   elif op==0xf3:
    at,_=pop();length,_=pop();assert(at,length)==(128,32);terminal=f'S.Returned(G.Encode({0 if name=="Reject" else 1},32))';guide+=f'K.ReturnLayout(mem,{0 if name=="Reject" else 1});'
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldMemory,guide=guide));pc=nxt
   if terminal is not None or pc==stop:break
   assert len(nodes)<100
  params='offset:S.Word,length:S.Word,mask:S.Word,index:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>'
  args='offset,length,mask,index,mem,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{mem}),[],0)'
  final='M.Frame('+terminal+',[],0)' if terminal else frame(pc,expr,memory);first=frame(start,nodes[0]['stack'],'mem');ds='{'+','.join(map(str,sorted(dests)))+'}';module='OperationsCharset'+name
  text='// SPDX-License-Identifier: MIT\n// Generated exact charset control. Never edit directly.\ninclude "Kernel.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = BytecodeExternalExecution\n  import I = OperationsCharsetInputs\n  import K = OperationsCharsetKernel\n'
  text+=f'  predicate Admitted({params}) {{ K.Memory(mem) && (offset as nat)+length<=|data|<I.U64 && index<=length && ({guard}) }}\n'
  text+='  predicate Matches(code:seq<S.Byte>) {\n    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n'+f'  function Destinations():set<nat> {{ {ds} }}\n  opaque predicate Good(id:nat,state:M.Frame,{params})\n    requires Admitted({args})\n  {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n';step='M.Step(code,destinations,state,self,value,data,observations)'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  text+='    reveal Good();\n  }\n}\n';r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'));mappings.append(dict(name=name,start=start,guard=guard,nodes=nodes,terminal=final,destinations=sorted(dests)))
 (out/'controls.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),candidate=bool(runtime),paths=mappings),indent=2)+'\n');print('Generated4 complete charset control paths;',sum(len(p['nodes']) for p in mappings),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
