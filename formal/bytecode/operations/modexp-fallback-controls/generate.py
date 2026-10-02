#!/usr/bin/env python3
"""Extract actual successful-reply return versus fallback-loop dispatch."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 spec=importlib.util.spec_from_file_location('gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g);g.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==json.loads((HERE.parent/'inventory.json').read_text())['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];n=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+n,int.from_bytes(code[pc+1:pc+1+n],'big'));pc+=1+n
 mappings=[]
 for name,done,guard,stop in [('Fallback',0,'done==0',9367),('Success',1,'done!=0',3085)]:
  vals=[42,2,2,17,1,done];expr=['returnPc','base','exponent','modulus','result','done'];pc=9354;nodes=[];destinations=set()
  def pop():return vals.pop(),expr.pop()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  while pc!=stop:
   op,nxt,imm=ins[pc];before=expr[:]
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif op==0x3d:push(size,'|returned|')
   elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x06:
    a,ae=pop();m,me=pop();assert m!=0;push(a%m,f'(if ({me})==0 then 0 else (({ae}) as nat)%(({me}) as nat))')
   elif op==0x15:
    a,ae=pop();push(int(a==0),f'Bool(({ae})==0)')
   elif op in [0x56,0x57]:
    target,_=pop();condition=True if op==0x56 else pop()[0]!=0;assert ins[target][0]==0x5b;destinations.add(target)
    if condition:nxt=target
   else:raise AssertionError((pc,op))
   nodes.append({'pc':pc,'opcode':op,'next':ins[pc][1],'immediate':imm,'actualNext':nxt,'stack':before});pc=nxt
  module='OperationsModularPowerFallback'+name;ds='{'+','.join(map(str,sorted(destinations)))+'}'
  params='outer:seq<S.Word>,returnPc:S.Word,base:S.Word,exponent:S.Word,modulus:S.Word,result:S.Word,done:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>'
  args='outer,returnPc,base,exponent,modulus,result,done,mem,returned,cursor,self,value,data,observations'
  def state(pc,stack):return f'M.Frame(S.Running({pc},outer+['+','.join(stack)+'],mem),returned,cursor)'
  step='E.Execute(code,destinations,frame,self,value,data,observations)'
  text='// SPDX-License-Identifier: MIT\n// Generated actual _powMod reply/fallback dispatch. Never edit directly.\ninclude "../modexp-execution/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsModularPowerExecution\n  function Bool(b:bool):S.Word { if b then 1 else 0 }\n'
  text+='  predicate Admitted('+params+') { |outer|<=1000 && modulus>0 && base<modulus && result<modulus && |mem|<G.Modulus() && '+guard+' }\n'
  text+='  predicate Matches(code:seq<S.Byte>) {\n    '+' &&\n    '.join(f'{x["pc"]}<|code| && S.Fetch(code,{x["pc"]})==S.Op({x["opcode"]},{x["next"]},{x["immediate"]})' for x in nodes)+' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(destinations))+'\n  }\n'
  text+='  opaque predicate Good(id:nat,frame:E.Frame,'+params+')\n    requires Admitted('+args+')\n  {\n'
  for i,x in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then frame=='+state(x['pc'],x['stack'])+'\n'
  text+=f'    else if id=={len(nodes)} then frame=='+state(pc,expr)+'\n    else false\n  }\n'
  for i,x in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,frame:E.Frame,{params})\n    requires Matches(code) && {ds}<=destinations && Admitted({args}) && Good({i},frame,{args})\n    ensures Good({i+1},{step},{args})\n  {{ reveal Good(); reveal E.Execute(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(frame:E.Frame,trace:seq<E.Frame>)\n    requires Matches(code) && {ds}<=destinations && Admitted({args})\n    ensures frame=='+state(pc,expr)+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+state(9354,nodes[0]['stack'])+' && trace[|trace|-1]==frame\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n  {\n    frame:='+state(9354,nodes[0]['stack'])+f';trace:=[frame]; reveal Good(); assert Good(0,frame,{args});\n'
  for i,x in enumerate(nodes):text+=f'    Advance{i}(code,destinations,frame,{args}); reveal Good(); assert {step}.state!=S.Bad; E.Extend(code,destinations,self,value,data,observations,trace,{step}); frame:={step};trace:=trace+[frame];assert |trace|=={i+2};assert trace[0]=='+state(9354,nodes[0]['stack'])+';assert trace[|trace|-1]==frame;\n'
  text+='    reveal Good();\n  }\n}\n'
  f=out/(name+'.generated.dfy');f.write_text(text);r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;f.write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  mappings.append({'name':name,'guard':guard,'nodes':nodes,'terminal':state(pc,expr),'destinations':sorted(destinations)})
 (out/'fallback.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'paths':mappings},indent=2)+'\n');print('Generated two complementary reply/fallback dispatch paths',sum(len(x['nodes']) for x in mappings),'actual instructions')
if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--output',type=Path,required=True);generate(a.parse_args().output)
