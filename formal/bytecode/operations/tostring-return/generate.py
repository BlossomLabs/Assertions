#!/usr/bin/env python3
"""Extract all exact75 common decimal string serializer/RETURN instructions."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;TOP=1<<248
def generate(out):
 canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(canonical).hexdigest()==inv['runtimeSha256']
 ins={};pc=0
 while pc<len(canonical):
  op=canonical[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+k,int.from_bytes(canonical[pc+1:pc+1+k],'big'));pc+=1+k
 out.mkdir(parents=True,exist_ok=True);name='Return';guard='true'
 vals=[0x6900a3ae,128]
 expr=['selector','base']
 pc=1362;nodes=[];dests=set();memory='mem';stage=lambda n:f'Q.{n}(mem,body,base,free)'
 def pop():return vals.pop(),expr.pop()
 def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
 while True:
  op,nxt,imm=ins[pc];before=expr[:];oldmem=memory;guide=''
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:push(imm)
  elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
  elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
  elif op==0x50:pop()
  elif op==0x51:
   at,ae=pop()
   if at==64:push(192,'free')
   else:assert at==128;push(1,'|body|')
   guide+='Q.Stages(mem,body,base,free);'
  elif op==0x19:
   a,ae=pop();assert a==31;push(MOD-32);guide+='Q.Mask();'
  elif op in [1,3,22]:
   a,ae=pop();b,be=pop();v=(a+b)%MOD if op==1 else (a-b)%MOD if op==3 else a&b
   ex={18949:'free+32',18902:'base+32',18906:'free+64',18913:'free+32+|body|',18914:'free+64+|body|',18924:'|body|+31',18925:'S.Round32(|body|)',18927:'free+32+S.Round32(|body|)',18928:'free+64+S.Round32(|body|)',1307:'64+S.Round32(|body|)'}[pc];push(v,ex)
   if op==22:guide+='Q.Round(|body|);'
  elif op==0x52:
   at,ae=pop();v,ve=pop()
   if pc==18941:assert (at,v)==(192,32);memory=stage('Head')
   elif pc==18897:assert (at,v)==(224,1);memory=stage('Length')
   else:assert pc==18915 and (at,v)==(257,0);memory=stage('Final')
   guide+='Q.Stages(mem,body,base,free);'
  elif op==0x5e:
   dst,de=pop();src,se=pop();n,ne=pop();assert (dst,src,n)==(256,160,1);memory=stage('Payload');guide+='Q.Stages(mem,body,base,free);'
  elif op==0x56:
   target,te=pop();assert te.isdecimal() and ins[target][0]==0x5b;dests.add(target);nxt=target
  elif op==0xf3:
   at,ae=pop();n,ne=pop();assert (at,n)==(192,96);guide+='Q.Stages(mem,body,base,free);'
  else:raise AssertionError((pc,hex(op)))
  nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
  if op==0xf3:break
 assert len(nodes)==75
 params='selector:S.Word,body:seq<S.Byte>,base:S.Word,free:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='selector,body,base,free,mem,self,value,data,observations'
 def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{mem}),[],0)'
 first=frame(1362,nodes[0]['stack'],'mem');final='M.Frame(S.Returned(Q.Canonical(body)),[],0)';module='OperationsToString'+name
 text='// SPDX-License-Identifier: MIT\n// Generated exact original-byte generic dynamic serializer macro; native pending.\ninclude "Kernel.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMemory\n  import CM = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import Q = OperationsToStringReturnKernel\n'
 text+=f'  predicate Admitted({params}) {{ Q.Layout(mem,body,base,free) }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
 text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
 if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
 text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
 text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params})\n    requires Admitted({args})\n  {{\n'
 for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
 text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n';step=f'F.Step(code,destinations,state,self,value,data,observations)'
 for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
 text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
 
 text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
 for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
 
 text+='    reveal Good();\n  }\n}\n'
 r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
 (out/'return.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(canonical).hexdigest(),paths=[dict(name=name,start=1362,nodes=nodes,terminal=final,destinations=sorted(dests))]),indent=2)+'\n');print('Generated exact75-instruction generic decimal physical serializer/RETURN; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
