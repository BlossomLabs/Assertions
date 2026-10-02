#!/usr/bin/env python3
"""Generate all four exact compiled ASCII-fold loop geometries; native pending."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;TOP=1<<248
CASES={'Done':(0,0,'index==length'),'Below':(1,64,'index<length && data[offset+index]<I.Low(lower)'),
 'Above':(1,91,'index<length && data[offset+index]>I.High(lower)'),
 'Fold':(1,65,'index<length && I.Low(lower)<=data[offset+index]<=I.High(lower)')}
def generate(out):
 canonical=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text())
 assert hashlib.sha256(canonical).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['toLower(bytes)']=='c1459c04';assert inv['compilerIdentity']['methodIdentifiers']['toUpper(bytes)']=='feec0cff'
 ins={};pc=0
 while pc<len(canonical):
  op=canonical[pc];k=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+k,int.from_bytes(canonical[pc+1:pc+1+k],'big'));pc+=1+k
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,(length,cell,guard) in CASES.items():
  vals=[0xc1459c04,1362,100,length,96,3085,100,length,65*TOP,90*TOP,128,0]
  expr=['I.Selector(lower)','1362','offset','length','96','3085','offset','length','B.Cell(I.Low(lower))','B.Cell(I.High(lower))','128','index']
  pc=12208;nodes=[];dests=set();memory='mem'
  def pop():return vals.pop(),expr.pop()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  while True:
   op,nxt,imm=ins[pc];before=expr[:];oldmem=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    a,ae=pop();push(int(a==0),None if ae.isdecimal() else f'(if ({ae})==0 then 1 else 0)')
   elif op==0x19:
    a,ae=pop();assert a==TOP-1;push(MOD-1-a,'B.Mask()');guide+='B.CellWord(255);'
   elif op==0x51:
    at,ae=pop()
    if at==128:push(length,'length');guide+='K.Load(mem,length,128);'
    else:
     assert at==160;push(cell*TOP,'S.Load(mem,160+index)');guide+='K.Load(mem,length,160+index);'
   elif op in [1,3,16,17,22,24,27,26]:
    a,ae=pop();b,be=pop()
    v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,16:lambda:int(a<b),17:lambda:int(a>b),22:lambda:a&b,24:lambda:a^b,27:lambda:(b<<a)%MOD if a<256 else 0,26:lambda:0 if a>=32 else (b//(256**(31-a)))%256}[op]()
    if op==1:
     known={12237:'128+index',12240:'160+index',12318:'32+index',12319:'160+index',12342:'index+1'}
     push(v,known.get(pc) if pc in known else None if ae.isdecimal() and be.isdecimal() else f'(({ae})+({be}))%G.Modulus()')
    elif op==3:assert ae.isdecimal() and be.isdecimal();push(v)
    elif op==27:
     assert a==248 and b in [1,32];push(v);guide+=f'B.CellWord({b});reveal S.ShiftLeft();'
    elif op==22:
     assert a==255*TOP or b==255*TOP
     non=be if a==255*TOP else ae
     if non.startswith('S.Load'):
      push(v,'B.Cell(data[offset+index])');guide+='var cell:=K.First(mem,length,index);assert mem[160+index]==data[offset+index];'
     else:
      assert non.startswith('B.Cell(');push(v,non);arg=non[len('B.Cell('):-1];guide+=f'B.MaskCell({arg});'
    elif op==24:
     assert pc==12297;push(v,'B.Cell(I.Fold(lower,data[offset+index]))');guide+='B.CellWord(32);B.Fold(lower,data[offset+index]);'
    elif op==26:
     assert a==0;push(v,'I.Fold(lower,data[offset+index])');guide+='B.ByteCell(I.Fold(lower,data[offset+index]));'
    else:
     push(v)
     if pc==12259:guide+='B.Compare(data[offset+index],I.Low(lower));'
     elif pc==12283:guide+='B.Compare(data[offset+index],I.High(lower));'
   elif op==0x53:
    at,ae=pop();v,ve=pop();assert at==160 and v==(cell^32)
    memory='F.Store8(mem,160+index,I.Fold(lower,data[offset+index]))';guide+='P.InBounds(mem,160+index,I.Fold(lower,data[offset+index]));C.RoundedMonotone((160+index as nat)+1,|mem|);'
   elif op in [0x56,0x57]:
    target,te=pop();assert te.isdecimal();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;dests.add(target)
    if take:nxt=target
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
   if pc in [12208,10129]:break
   assert len(nodes)<110
  assert len(nodes)==dict(Done=8,Below=52,Above=67,Fold=99)[name]
  params='offset:S.Word,length:S.Word,index:S.Word,lower:bool,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='offset,length,index,lower,mem,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{mem}),[],0)'
  first=frame(12208,nodes[0]['stack'],'mem');final=frame(pc,expr,memory);module='OperationsCaseFold'+name
  text='// SPDX-License-Identifier: MIT\n// Generated exact original-byte case-fold macro; native pending.\ninclude "../casefold-machine/Kernel.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMemory\n  import CM = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import I = OperationsCaseFoldInputs\n  import K = OperationsCaseFoldKernel\n  import B = OperationsCaseFoldBinary\n  import P = OperationsCaseFoldMemory\n'
  text+=f'  predicate Admitted({params}) {{ K.Inv(mem,data,offset,length,index,lower) && ({guard}) }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
  text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params})\n    requires Admitted({args})\n  {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n';step=f'F.Step(code,destinations,state,self,value,data,observations)'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
  newindex='index' if name=='Done' else 'index+1';text+=f'    ensures K.Inv(state.state.memory,data,offset,length,{newindex},lower)\n'
  text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  if name=='Fold':text+='    K.FoldStep(mem,data,offset,length,index,lower);\n'
  elif name!='Done':text+='    K.UnchangedStep(mem,data,offset,length,index,lower);\n'
  text+='    reveal Good();\n  }\n}\n'
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  paths.append(dict(name=name,start=12208,guard=guard,nodes=nodes,terminal=final,destinations=sorted(dests)))
 (out/'controls.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(canonical).hexdigest(),paths=paths),indent=2)+'\n');print('Generated4 case-fold geometries;',sum(len(p['nodes']) for p in paths),'actual instructions; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
