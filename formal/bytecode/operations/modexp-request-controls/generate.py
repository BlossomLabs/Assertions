#!/usr/bin/env python3
"""Extract exact reached six-store MODEXP packet construction and GAS instruction."""
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
 for name,guard,stop in [('Request','exponent>=0x100000000',9331)]:
  vals=[42,2,0x100000000,17,1];expr=['returnPc','base','exponent','modulus','result'];pc=9283;nodes=[];destinations=set();memory='S.Store([],64,128)';stores={64:128};cursor='cursor'
  def pop():return vals.pop(),expr.pop()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  while pc!=stop:
   op,nxt,imm=ins[pc];before=expr[:];memBefore=memory;cursorBefore=cursor
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif op==0x3d:push(size,'|returned|')
   elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x01:
    a,ae=pop();b,be=pop();assert ae.isdigit() and be.isdigit();push(a+b)
   elif op==0x51:
    at,_=pop();assert at==64;push(128)
   elif op==0x52:
    at,_=pop();v,ve=pop();assert at in [128,160,192,224,256,288];memory=f'S.Store({memory},{at},{ve})'
   elif op==0x5a:
    push(999,'gas');cursor='cursor+1'
   else:raise AssertionError((pc,op))
   nodes.append({'pc':pc,'opcode':op,'next':ins[pc][1],'immediate':imm,'actualNext':nxt,'stack':before,'memory':memBefore,'cursor':cursorBefore});pc=nxt
  module='OperationsModularPowerRequest'+name;ds='{'+','.join(map(str,sorted(destinations)))+'}'
  params='outer:seq<S.Word>,returnPc:S.Word,base:S.Word,exponent:S.Word,modulus:S.Word,result:S.Word,returned:seq<S.Byte>,cursor:nat,self:S.Word,gas:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>'
  args='outer,returnPc,base,exponent,modulus,result,returned,cursor,self,gas,value,data,observations'
  def state(pc,stack,mem,cur):return f'M.Frame(S.Running({pc},outer+['+','.join(stack)+f'],{mem}),returned,{cur})'
  step='E.Execute(code,destinations,frame,self,value,data,observations)'
  text='// SPDX-License-Identifier: MIT\n// Generated actual physical MODEXP request/GAS prefix. Never edit directly.\ninclude "../modexp-precompile/Call.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsModularPowerExecution\n  function Bool(b:bool):S.Word { if b then 1 else 0 }\n'
  text+='  predicate Admitted('+params+') { |outer|<=1008 && modulus>0 && M.Context(self) && cursor<|observations| && observations[cursor]==M.Gas(gas) && '+guard+' }\n'
  text+='  predicate Matches(code:seq<S.Byte>) {\n    '+' &&\n    '.join([f'{x["pc"]}<|code| && S.Fetch(code,{x["pc"]})==S.Op({x["opcode"]},{x["next"]},{x["immediate"]})' for x in nodes]+[f'{d}<|code| && code[{d}]==0x5b' for d in sorted(destinations)])+'\n  }\n'
  text+='  opaque predicate Good(id:nat,frame:E.Frame,'+params+')\n    requires Admitted('+args+')\n  {\n'
  for i,x in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then frame=='+state(x['pc'],x['stack'],x['memory'],x['cursor'])+'\n'
  text+=f'    else if id=={len(nodes)} then frame=='+state(pc,expr,memory,cursor)+'\n    else false\n  }\n'
  for i,x in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,frame:E.Frame,{params})\n    requires Matches(code) && {ds}<=destinations && Admitted({args}) && Good({i},frame,{args})\n    ensures Good({i+1},{step},{args})\n  {{ reveal Good(); reveal E.Execute(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(frame:E.Frame,trace:seq<E.Frame>)\n    requires Matches(code) && {ds}<=destinations && Admitted({args})\n    ensures frame=='+state(pc,expr,memory,cursor)+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+state(9283,nodes[0]['stack'],nodes[0]['memory'],nodes[0]['cursor'])+' && trace[|trace|-1]==frame\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n  {\n    frame:='+state(9283,nodes[0]['stack'],nodes[0]['memory'],nodes[0]['cursor'])+f';trace:=[frame]; reveal Good(); assert Good(0,frame,{args});\n'
  for i,x in enumerate(nodes):text+=f'    Advance{i}(code,destinations,frame,{args}); reveal Good(); assert {step}.state!=S.Bad; E.Extend(code,destinations,self,value,data,observations,trace,{step}); frame:={step};trace:=trace+[frame];assert |trace|=={i+2};assert trace[0]=='+state(9283,nodes[0]['stack'],nodes[0]['memory'],nodes[0]['cursor'])+';assert trace[|trace|-1]==frame;\n'
  text+='    reveal Good();\n  }\n}\n'
  f=out/(name+'.generated.dfy');f.write_text(text);r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;f.write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  mappings.append({'name':name,'guard':guard,'nodes':nodes,'terminal':state(pc,expr,memory,cursor),'destinations':sorted(destinations)})
 (out/'request.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'paths':mappings},indent=2)+'\n');print('Generated physical six-store MODEXP request and GAS prefix',sum(len(x['nodes']) for x in mappings),'actual instructions')
if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--output',type=Path,required=True);generate(a.parse_args().output)
