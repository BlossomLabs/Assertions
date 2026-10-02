#!/usr/bin/env python3
"""Extract the exact arbitrary-length case-fold copy/allocation initialization."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;TOP=1<<248
def generate(out):
 canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(canonical).hexdigest()==inv['runtimeSha256']
 ins={};pc=0
 while pc<len(canonical):
  op=canonical[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+k,int.from_bytes(canonical[pc+1:pc+1+k],'big'));pc+=1+k
 out.mkdir(parents=True,exist_ok=True);name='Start';guard='true'
 vals=[0xc1459c04,1362,100,1,96,3085,100,1,65*TOP,90*TOP]
 expr=['I.Selector(lower)','1362','offset','length','96','3085','offset','length','B.Cell(I.Low(lower))','B.Cell(I.High(lower))']
 pc=12150;nodes=[];dests=set();memory='mem'
 def pop():return vals.pop(),expr.pop()
 def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
 while pc!=12208:
  op,nxt,imm=ins[pc];before=expr[:];oldmem=memory;guide=''
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:push(imm)
  elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
  elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
  elif op==0x50:pop()
  elif op==0x51:
   at,ae=pop();assert at==64;push(128);guide+='K.BaseFits();'
  elif op in [1,2,4]:
   a,ae=pop();b,be=pop();v=(a+b)%MOD if op==1 else (a*b)%MOD if op==2 else 0 if b==0 else a//b
   ex={12159:'length+31',12164:'(length+31)/32',12165:'S.Round32(length)',12168:'32+S.Round32(length)',12174:'K.Free(length)',12188:'160',12197:'160+length'}[pc];push(v,ex)
  elif op==0x52:
   at,ae=pop();v,ve=pop()
   if pc==12177:assert at==64;memory='K.Allocated(length)';guide+='K.BaseFits();R.StoredWord(mem,64,K.Free(length));'
   elif pc==12185:assert at==128;memory='S.Store(K.Allocated(length),128,length)';guide+='R.StoredWord(K.Allocated(length),128,length);'
   else:assert pc==12200 and at==161 and v==0;memory='K.Initial(data,offset,length)';guide+='K.InitialInv(data,offset,length,lower);'
  elif op==0x37:
   dst,de=pop();src,se=pop();n,ne=pop();assert (dst,src,n)==(160,100,1);memory='C.Calldata(S.Store(K.Allocated(length),128,length),160,offset,length,data)';guide+='C.Size(S.Store(K.Allocated(length),128,length),160,S.Window(data,offset,length));'
  else:raise AssertionError((pc,hex(op)))
  nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
 assert len(nodes)==51
 params='offset:S.Word,length:S.Word,index:S.Word,lower:bool,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='offset,length,index,lower,mem,self,value,data,observations'
 def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{mem}),[],0)'
 first=frame(12150,nodes[0]['stack'],'mem');final=frame(pc,expr,memory);module='OperationsCaseFold'+name
 text='// SPDX-License-Identifier: MIT\n// Generated exact original-byte case-fold macro; native pending.\ninclude "../casefold-machine/Kernel.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMemory\n  import CM = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import I = OperationsCaseFoldInputs\n  import K = OperationsCaseFoldKernel\n  import B = OperationsCaseFoldBinary\n  import P = OperationsCaseFoldMemory\n  import R = BytecodeScanRepresentation\n'
 text+=f'  predicate Admitted({params}) {{ K.Input(data,offset,length) && mem==K.Base() && index==0 }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
 text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
 if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
 text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
 text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params})\n    requires Admitted({args})\n  {{\n'
 for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
 text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n';step=f'F.Step(code,destinations,state,self,value,data,observations)'
 for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
 text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
 newindex='0';text+=f'    ensures K.Inv(state.state.memory,data,offset,length,{newindex},lower)\n'
 text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
 for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
 text+='    K.InitialInv(data,offset,length,lower);\n'
 text+='    reveal Good();\n  }\n}\n'
 r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
 (out/'initialization.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(canonical).hexdigest(),paths=[dict(name=name,start=12150,nodes=nodes,terminal=final,destinations=sorted(dests))]),indent=2)+'\n');print('Generated exact51-instruction case-fold initialization; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
