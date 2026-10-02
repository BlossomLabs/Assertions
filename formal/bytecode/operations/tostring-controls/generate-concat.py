#!/usr/bin/env python3
"""Derive signed decimal concatenation macro from the exact reached original runtime bytes."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256

def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+k+1,int.from_bytes(code[pc+1:pc+k+1],'big'));pc+=k+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,start,stop,nums,expressions,guard in [('Concat',7455,1362,[2736964622,1362,MOD-33,96,128,192],['I.Selector(true)','1362','word','96','128','N.Free(word)'],'Q.Input(mem,word)')]:
  vals=nums[:];expr=expressions[:];nodes=[];dests=set();pc=start;memory='mem';stage=0;copies=0
  def pop():return vals.pop(),expr.pop()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  while not nodes or pc!=stop:
   op,nxt,imm=ins[pc];before=expr[:];oldmem=memory;guide=''
   if op==91:pass
   elif op==95 or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==80:pop()
   elif op==21:
    v,e=pop();push(int(v==0),None if e.isdecimal() else f'(if ({e})==0 then 1 else 0)')
   elif op==25:
    a,ae=pop();assert a==31;push(MOD-1-a,'G.Modulus()-32');guide+='A.Mask();'
   elif op==81:
    at,ae=pop();guide+=f'Q.Stage(mem,word,{stage});Q.Bounds(word);'
    guide+=f'C.RoundedMonotone({ae}+32,|{memory}|);'
    if at==64:push(256,'Q.Free(word)');guide+=f'Q.FreePreserved(mem,word,{stage});'
    elif at==128:push(1,'Q.Minus(word)')
    else:assert at==192;push(2,'Q.Length(word)');guide+='Q.First(mem,word);'
   elif op in [1,3]:
    a,ae=pop();b,be=pop();v=(a+b)%MOD if op==1 else (a-b)%MOD
    known={7461:'Q.Free(word)+32',7480:'32+Q.Minus(word)+Q.Length(word)',7481:'Q.Minus(word)+Q.Length(word)'}
    if pc==20463:e='160' if copies==0 else 'N.Free(word)+32'
    elif pc==20468:e='Q.Free(word)+32+Q.Minus(word)' if copies==1 else 'Q.End(word)'
    else:e=known.get(pc);assert e is not None,(pc,ae,be)
    push(v,e);guide+='Q.Bounds(word);'
   elif op==82:
    at,ae=pop();v,ve=pop()
    if pc==20471:
     assert v==0;memory='Q.FirstZero(mem,word)' if copies==1 else 'Q.SecondZero(mem,word)';stage=2 if copies==1 else 4
    elif pc==7483:assert at==256 and v==3;memory='Q.Header(mem,word)';stage=5
    else:assert pc==7487 and at==64 and v==291;memory='Q.Final(mem,word)';stage=6;guide+='Q.Ready(mem,word);'
    guide+=f'Q.Stage(mem,word,{stage});'
   elif op==94:
    at,ae=pop();src,se=pop();n,ne=pop();copies+=1
    if copies==1:assert (at,src,n)==(288,160,1);memory='Q.FirstCopy(mem,word)';stage=1
    else:assert (at,src,n)==(289,224,2);memory='Q.SecondCopy(mem,word)';stage=3
    guide+='Q.Bounds(word);Q.Stage(mem,word,0);'
    if copies==2:guide+='Q.First(mem,word);'
    guide+=f'Q.Stage(mem,word,{stage});'
   elif op in [86,87]:
    target,te=pop();assert te.isdecimal() and ins[target][0]==91;take=op==86 or pop()[0]!=0;dests.add(target)
    if take:nxt=target
   else:raise AssertionError((pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
  assert len(nodes)=={'Concat':94}[name]
  params='prefix:seq<S.Word>,word:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='prefix,word,mem,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},prefix+['+','.join(stack)+f'],{mem}),[],0)'
  first=frame(start,nodes[0]['stack'],'mem');final=frame(stop,expr,memory);step='F.Step(code,destinations,state,self,value,data,observations)';module='OperationsToString'+name
  text='// SPDX-License-Identifier: MIT\n// Generated original-byte decimal macro; native proof pending.\ninclude "../tostring-kernel/Concat.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import CM = BytecodeCopyMachine\n  import C = BytecodeCopyMemory\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import D = OperationsToStringDecimal\n  import Q = OperationsToStringConcatMemory\n  import N = OperationsToStringSign\n  import R = BytecodeScanRepresentation\n  import I = OperationsToStringInputs\n  import K = OperationsToStringFillMemory\n  import B = OperationsCaseFoldBinary\n  import P = OperationsCaseFoldMemory\n  import Return = OperationsToStringReturnKernel\n  import H = OperationsToStringFrame\n'
  text+=f'  predicate Admitted({params}) {{ |prefix|<=1000 && {guard} }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
  text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params}) requires Admitted({args}) {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} Q.Bounds(word);reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
  if name=='Concat':text+='    ensures Return.Layout(state.state.memory,I.Render(word,true),Q.Free(word),Q.End(word))\n'
  
  text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  if name=='Concat':text+='    Q.Ready(mem,word);\n'
  
  text+='    reveal Good();\n  }\n}\n'
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  paths.append(dict(name=name,start=start,nodes=nodes,terminalPc=stop,terminalStack=expr,terminalMemory=memory,destinations=sorted(dests)))
 (out/'concat.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=paths),indent=2)+'\n');print('Generated signed decimal concatenation94 actual instructions; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
