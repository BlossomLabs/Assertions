#!/usr/bin/env python3
"""Extract actual unsigned modular-power wrapper, zero panic and scalar RETURN."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
SELECTOR=0x44852766
CASES={'Enter':(4610,[SELECTOR,1329,2,1,17],[str(SELECTOR),'1329','base','exponent','modulus'],9244),
       'Return':(3085,[SELECTOR,1329,2,1,17,0,3390,2,0,17,42],[str(SELECTOR),'1329','base','exponent','modulus','0','3390','finalBase','finalExponent','modulus','result'],None),
       'Zero':(9244,[3390,2,1,0],['returnPc','base','exponent','modulus'],None)}
def generate(out):
 spec=importlib.util.spec_from_file_location('source_gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate);gate.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256']
 assert inv['compilerIdentity']['methodIdentifiers']['powMod(uint256,uint256,uint256)']=='44852766'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 out.mkdir(parents=True,exist_ok=True);mappings=[]
 for name,(start,values,expressions,stop) in CASES.items():
  vals=values[:];expr=expressions[:];pc=start;memory='mem';nodes=[];destinations=set();terminal=None
  def pop():return vals.pop(),expr.pop()
  def push(value,expression=None):vals.append(value);expr.append(str(value) if expression is None else expression)
  while True:
   op,nxt,imm=ins[pc];before=expr[:];oldMemory=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;assert k<=len(vals);push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;assert k<len(vals);vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op in [0x01,0x03,0x1b]:
    a,ae=pop();b,be=pop();assert ae.isdecimal() and be.isdecimal();push((a+b)%MOD if op==1 else (a-b)%MOD if op==3 else (b<<a)%MOD)
   elif op==0x51:
    at,ae=pop();assert at==64;push(128)
    if memory!='mem':guide+='L.ReturnLayout(mem,result);'
   elif op==0x52:
    at,ae=pop();value,ve=pop();assert at in [0,4,128]
    if at==128:assert ve=='result';memory='S.Store(mem,128,result)';guide+='L.ReturnLayout(mem,result);'
    elif at==0:memory='S.Store(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000)';guide+='Q.StoredWord(mem,0,0x4e487b7100000000000000000000000000000000000000000000000000000000);'
    else:assert at==4 and value==18;memory='L.Panic(mem)';guide+='L.PanicLayout(mem);'
   elif op in [0x56,0x57]:
    target,_=pop();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;destinations.add(target)
    if take:nxt=target
   elif op in [0xf3,0xfd]:
    offset,_=pop();length,_=pop();assert (offset,length)==((128,32) if name=='Return' else (0,36))
    terminal='S.Returned(G.Encode(result,32))' if name=='Return' else 'S.Reverted(L.PanicData())';guide+='L.ReturnLayout(mem,result);' if name=='Return' else 'L.PanicLayout(mem);'
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldMemory,guide=guide));pc=nxt
   if terminal is not None or pc==stop:break
   assert len(nodes)<100
  params='outer:seq<S.Word>,returnPc:S.Word,base:S.Word,exponent:S.Word,modulus:S.Word,finalBase:S.Word,finalExponent:S.Word,result:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>'
  args='outer,returnPc,base,exponent,modulus,finalBase,finalExponent,result,mem,returned,cursor,self,value,data,observations'
  prefix='outer+' if name=='Zero' else ''
  def state(pc,stack,memory):return f'M.Frame(S.Running({pc},{prefix}['+','.join(stack)+f'],{memory}),returned,cursor)'
  final='M.Frame('+terminal+',returned,cursor)' if terminal else state(pc,expr,memory)
  module='OperationsModularPowerUnsigned'+name;dests='{'+','.join(map(str,sorted(destinations)))+'}'
  guard='|outer|<=1000 && L.Admitted(mem)'+(' && modulus==0' if name=='Zero' else '')
  text='// SPDX-License-Identifier: MIT\n// Generated exact unsigned modular-power wrapper path. Never edit directly.\ninclude "Memory.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsModularPowerExecution\n  import Q = BytecodeScanRepresentation\n  import L = OperationsModularPowerUnsignedMemory\n'
  text+='  predicate Admitted('+params+') { '+guard+' }\n  predicate Matches(code:seq<S.Byte>) {\n    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if destinations:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(destinations))
  text+='\n  }\n  function Destinations():set<nat> { '+dests+' }\n  opaque predicate Good(id:nat,frame:E.Frame,'+params+')\n    requires Admitted('+args+')\n  {\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then frame=='+state(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then frame=='+final+'\n    else false\n  }\n'
  step='E.Execute(code,destinations,frame,self,value,data,observations)'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,frame:E.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},frame,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good(); reveal E.Execute(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(frame:E.Frame,trace:seq<E.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures frame=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+state(start,nodes[0]['stack'],'mem')+' && trace[|trace|-1]==frame\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n  {\n    frame:='+state(start,nodes[0]['stack'],'mem')+f';trace:=[frame];reveal Good();assert Good(0,frame,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,frame,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});frame:={step};trace:=trace+[frame];assert |trace|=={i+2};assert trace[0]=='+state(start,nodes[0]['stack'],'mem')+';assert trace[|trace|-1]==frame;\n'
  text+='    reveal Good();\n  }\n}\n';f=out/(name+'.generated.dfy');f.write_text(text)
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,(name,r.stderr);f.write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  mappings.append(dict(name=name,start=start,nodes=nodes,terminal=final,destinations=sorted(destinations)))
 (out/'unsigned.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=mappings),indent=2)+'\n');print('Generated3 complete unsigned powMod body/return/zero paths:',sum(len(r['nodes']) for r in mappings),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
