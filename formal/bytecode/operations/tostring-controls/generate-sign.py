#!/usr/bin/env python3
"""Derive exact signed literal/magnitude prefixes from the exact reached original runtime bytes."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256

def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+k+1,int.from_bytes(code[pc+1:pc+k+1],'big'));pc+=k+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,start,stop,nums,expressions,guard in [
  ('SignPositive',2412,5497,[0xa322c40e,1362,20],['I.Selector(true)','1362','word'],'!I.Negative(word,true)'),
  ('SignNegative',2412,5497,[0xa322c40e,1362,MOD-33],['I.Selector(true)','1362','word'],'I.Negative(word,true)')]:
  vals=nums[:];expr=expressions[:];nodes=[];dests=set();pc=start;memory='K.Base()'
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
   elif op==81:
    at,ae=pop();assert at==64;push(128);guide+='K.BaseFits();'
   elif op in [1,3,18,27]:
    a,ae=pop();b,be=pop();asSigned=lambda n:n if n<MOD//2 else n-MOD;v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,18:lambda:int(asSigned(a)<asSigned(b)),27:lambda:(b<<a)%MOD if a<256 else 0}[op]()
    if op==3 and pc==9165:push(v,'I.Magnitude(word,true)');guide+='Q.Magnitude(word);'
    elif op==27:assert a==248 and b==45;push(v,'B.Cell(45)');guide+='B.CellWord(45);reveal S.ShiftLeft();'
    elif op==18:push(v);guide+='Q.Magnitude(word);'
    else:assert ae.isdecimal() and be.isdecimal();push(v)
   elif op==82:
    at,ae=pop();v,ve=pop()
    if pc in [7406,7426]:assert at==64;memory='Q.Allocated(word)';guide+='R.StoredWord(K.Base(),64,Q.Free(word));'
    elif pc in [7410,7431]:assert at==128;memory='Q.Header(word)';guide+='R.StoredWord(Q.Allocated(word),128,|Q.Prefix(word)|);'
    else:assert pc==7441 and at==160;memory='Q.Initial(word)';guide+='Q.Ready(word);'
   elif op in [86,87]:
    target,te=pop();assert te.isdecimal() and ins[target][0]==91;take=op==86 or pop()[0]!=0;dests.add(target)
    if take:nxt=target
   else:raise AssertionError((pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
  assert len(nodes)=={'SignPositive':49,'SignNegative':52}[name]
  params='prefix:seq<S.Word>,word:S.Word,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='prefix,word,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},prefix+['+','.join(stack)+f'],{mem}),[],0)'
  first=frame(start,nodes[0]['stack'],'K.Base()');final=frame(stop,expr,memory);step='F.Step(code,destinations,state,self,value,data,observations)';module='OperationsToString'+name
  text='// SPDX-License-Identifier: MIT\n// Generated original-byte decimal macro; native proof pending.\ninclude "../tostring-kernel/Sign.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import CM = BytecodeCopyMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import D = OperationsToStringDecimal\n  import I = OperationsToStringInputs\n  import K = OperationsToStringMemory\n  import Q = OperationsToStringSign\n  import B = OperationsCaseFoldBinary\n  import R = BytecodeScanRepresentation\n'
  text+=f'  predicate Admitted({params}) {{ prefix==[] && {guard} }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
  text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params}) requires Admitted({args}) {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} Q.Magnitude(word);reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
  if name in ['SignPositive','SignNegative']:text+='    ensures state.state.memory==Q.Initial(word)\n'
  
  text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  if name in ['SignPositive','SignNegative']:text+='    Q.Ready(word);\n'
  
  text+='    reveal Good();\n  }\n}\n'
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  paths.append(dict(name=name,start=start,nodes=nodes,terminalPc=stop,terminalStack=expr,terminalMemory=memory,destinations=sorted(dests)))
 (out/'sign.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=paths),indent=2)+'\n');print('Generated decimal sign/magnitude macros49+52 actual instructions; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
