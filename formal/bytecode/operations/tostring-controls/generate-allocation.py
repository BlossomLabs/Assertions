#!/usr/bin/env python3
"""Derive decimal nonzero allocation macro from the exact reached original runtime bytes."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256

def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+k+1,int.from_bytes(code[pc+1:pc+k+1],'big'));pc+=k+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,start,stop,nums,expressions,guard in [('Allocate',5576,5649,[20,96,2,0],['original','96','D.Steps(original)','0'],'A.Input(mem,data,base,original)')]:
  vals=nums[:];expr=expressions[:];nodes=[];dests=set();pc=start;memory='mem'
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
    at,ae=pop();assert at==64;push(128,'base');guide+='A.Load(mem,data,base,original);'
   elif op==54:push(36,'|data|')
   elif op in [1,3,17,22,27]:
    a,ae=pop();b,be=pop();v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,17:lambda:int(a>b),22:lambda:a&b,27:lambda:(b<<a)%MOD if a<256 else 0}[op]()
    known={5613:'D.Steps(original)+31',5617:'S.Round32(D.Steps(original))',5620:'32+S.Round32(D.Steps(original))',5622:'A.Free(base,D.Steps(original))',5635:'base+32',5641:'base+32+D.Steps(original)'}
    assert pc in known or (ae.isdecimal() and be.isdecimal()) or op==17
    push(v,known.get(pc));guide+='A.Round(D.Steps(original));' if pc==5617 else 'reveal S.ShiftLeft();' if op==27 else ''
   elif op==82:
    at,ae=pop();v,ve=pop()
    if pc==5609:assert at==128 and v==2;memory='A.Header(mem,base,D.Steps(original))';guide+='R.StoredWord(mem,base,D.Steps(original));'
    else:assert pc==5625 and at==64 and v==192;memory='A.Allocated(mem,base,D.Steps(original))';guide+='R.StoredWord(A.Header(mem,base,D.Steps(original)),64,A.Free(base,D.Steps(original)));'
   elif op==55:
    at,ae=pop();src,se=pop();n,ne=pop();assert at==160 and src==36 and n==2;memory='A.Initial(mem,data,base,D.Steps(original))';guide+='A.Begin(mem,data,base,original);'
   elif op in [86,87]:
    target,te=pop();assert te.isdecimal() and ins[target][0]==91;take=op==86 or pop()[0]!=0;dests.add(target)
    if take:nxt=target
   else:raise AssertionError((pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
  assert len(nodes)=={'Allocate':53}[name]
  params='prefix:seq<S.Word>,original:S.Word,base:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='prefix,original,base,mem,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},prefix+['+','.join(stack)+f'],{mem}),[],0)'
  first=frame(start,nodes[0]['stack'],'mem');final=frame(stop,expr,memory);step='F.Step(code,destinations,state,self,value,data,observations)';module='OperationsToString'+name
  text='// SPDX-License-Identifier: MIT\n// Generated original-byte decimal macro; native proof pending.\ninclude "../tostring-kernel/Allocation.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import CM = BytecodeCopyMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import D = OperationsToStringDecimal\n  import A = OperationsToStringAllocation\n  import R = BytecodeScanRepresentation\n  import I = OperationsToStringInputs\n  import K = OperationsToStringFillMemory\n  import B = OperationsCaseFoldBinary\n  import P = OperationsCaseFoldMemory\n  import H = OperationsToStringFrame\n'
  text+=f'  predicate Admitted({params}) {{ |prefix|<=1000 && D.Steps(original)<=78 && {guard} }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
  text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params}) requires Admitted({args}) {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} D.WordDigits(original);reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
  if name=='Allocate':text+='    ensures K.Inv(state.state.memory,base,original,original,D.Steps(original))\n    ensures H.Stable(mem,state.state.memory,|mem|)\n    ensures |state.state.memory|==A.Free(base,D.Steps(original))\n'
  
  text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  if name=='Allocate':text+='    A.Begin(mem,data,base,original);\n'
  
  text+='    reveal Good();\n  }\n}\n'
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  paths.append(dict(name=name,start=start,nodes=nodes,terminalPc=stop,terminalStack=expr,terminalMemory=memory,destinations=sorted(dests)))
 (out/'allocation.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=paths),indent=2)+'\n');print('Generated decimal allocation macro53 actual instructions; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
