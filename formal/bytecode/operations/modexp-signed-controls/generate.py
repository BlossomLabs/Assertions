#!/usr/bin/env python3
"""Extract all signed-base/unsigned-exponent modular-power wrapper paths."""
import argparse,hashlib,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;HALF=MOD//2;SELECTOR=0x640c3e5a
CASES={}
for b in [0,1]:
 for m in [0,1]:
  name=f'Enter{b}{m}'
  CASES[name]=(5210,[SELECTOR,1329,MOD-3 if b else 3,3,MOD-17 if m else 17],[str(SELECTOR),'1329','base','exponent','modulusWord'],9244,f'(base>=K.Half)=={str(bool(b)).lower()} && (modulusWord>=K.Half)=={str(bool(m)).lower()}')
for name,base,e,guard in [('ReturnPositiveBase',3,3,'base<K.Half'),('ReturnNegativeEven',MOD-3,2,'base>=K.Half && exponent%2==0'),('ReturnNegativeOdd',MOD-3,3,'base>=K.Half && exponent%2==1')]:
 CASES[name]=(3085,[SELECTOR,1329,base,e,17,0,3390,5241,9,0,17,10],[str(SELECTOR),'1329','base','exponent','modulusWord','0','3390','5241','finalBase','finalExponent','K.Magnitude(modulusWord)','result'],None,guard+' && modulusWord!=0 && result<K.Magnitude(modulusWord)')
def generate(out):
 spec=importlib.util.spec_from_file_location('source_gate',HERE.parent/'modexp-entry-preparation/generate-source-gate.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate);gate.generate(out)
 assert (out/'source-gate.json').read_bytes()==(HERE.parent/'modexp-entry-preparation/source-gate.json').read_bytes()
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256']
 assert inv['compilerIdentity']['methodIdentifiers']['powMod(int256,uint256,int256)']=='640c3e5a'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 out.mkdir(parents=True,exist_ok=True);mappings=[]
 def signed(n):return n if n<HALF else n-MOD
 for name,(start,values,expressions,stop,guard) in CASES.items():
  vals=values[:];expr=expressions[:];pc=start;memory='mem';nodes=[];destinations=set();terminal=None
  wordout='K.SignedResult(result,base>=K.Half && K.Odd(exponent))'
  def pop():return vals.pop(),expr.pop()
  def push(value,expression=None):vals.append(value);expr.append(str(value) if expression is None else expression)
  def binary(op,a,b,ae,be):
   if ae.isdecimal() and be.isdecimal():
    value=(a+b)%MOD if op==1 else (a-b)%MOD if op==3 else (b<<a)%MOD
    return value,str(value),''
   if op==3 and ae=='0' and be in ['base','modulusWord']:
    return (-b)%MOD,f'K.Magnitude({be})',f'K.MagnitudeIdentity({be});'
   if op==3 and ae=='0' and be=='result':
    return (-b)%MOD,'K.SignedResult(result,true)','A.Represent(base,exponent,modulusWord,result);'
   raise AssertionError((name,pc,op,ae,be))
  while True:
   op,nxt,imm=ins[pc];before=expr[:];oldMemory=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;assert k<=len(vals);push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;assert k<len(vals);vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op in [0x01,0x03,0x1b]:
    a,ae=pop();b,be=pop();v,ex,g=binary(op,a,b,ae,be);push(v,ex);guide+=g
   elif op in [0x11,0x12]:
    a,ae=pop();b,be=pop();truth=(a>b) if op==0x11 else signed(a)<signed(b)
    if op==0x12:
     assert be=='0' and ae in ['base','modulusWord'];push(int(truth),f'(if {ae}>=K.Half then 1 else 0)');guide+=f'K.MagnitudeIdentity({ae});'
    else:
     assert ae=='result' and be.isdecimal();push(int(truth),f'(if result>{be} then 1 else 0)');guide+='K.MagnitudeIdentity(modulusWord);'
   elif op==0x15:
    a,ae=pop();push(int(a==0),f'(if {ae}==0 then 1 else 0)')
   elif op==0x16:
    a,ae=pop();b,be=pop();assert {ae,be}=={'1','exponent'};push(a&b,'exponent%2');guide+='H.Halve(exponent);'
   elif op==0x51:
    at,ae=pop();assert at==64;push(128)
    if memory!='mem':guide+=f'L.ReturnLayout(mem,{wordout});'
   elif op==0x52:
    at,ae=pop();value,ve=pop();assert at==128;memory=f'S.Store(mem,128,{wordout})';guide+=f'A.Represent(base,exponent,modulusWord,result);L.ReturnLayout(mem,{wordout});'
   elif op in [0x56,0x57]:
    target,te=pop();assert te.isdecimal();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;destinations.add(target)
    if take:nxt=target
   elif op==0xf3:
    offset,_=pop();length,_=pop();assert (offset,length)==(128,32);terminal=f'S.Returned(G.Encode({wordout},32))';guide+=f'L.ReturnLayout(mem,{wordout});'
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldMemory,guide=guide));pc=nxt
   if terminal is not None or pc==stop:break
   assert len(nodes)<150
  params='base:S.Word,exponent:S.Word,modulusWord:S.Word,finalBase:S.Word,finalExponent:S.Word,result:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>'
  args='base,exponent,modulusWord,finalBase,finalExponent,result,mem,returned,cursor,self,value,data,observations'
  def state(pc,stack,memory):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{memory}),returned,cursor)'
  final='M.Frame('+terminal+',returned,cursor)' if terminal else state(pc,expr,memory)
  module='OperationsModularPowerSigned'+name;dests='{'+','.join(map(str,sorted(destinations)))+'}'
  guard='L.Admitted(mem) && '+guard
  text='// SPDX-License-Identifier: MIT\n// Generated exact signed modular-power wrapper path. Never edit directly.\ninclude "Arithmetic.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsModularPowerExecution\n  import K = OperationsModularPowerSignedKernel\n  import H = OperationsModularPowerHalving\n  import A = OperationsModularPowerSignedArithmetic\n  import L = OperationsModularPowerUnsignedMemory\n'
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
  mappings.append(dict(name=name,start=start,guard=guard,nodes=nodes,terminal=final,destinations=sorted(destinations)))
 (out/'signed.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=mappings),indent=2)+'\n');print('Generated7 complete signed-base powMod wrapper paths:',sum(len(r['nodes']) for r in mappings),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
