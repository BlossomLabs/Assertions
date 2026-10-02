#!/usr/bin/env python3
"""Derive decimal fill macros from the exact reached original runtime bytes."""
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
  ('FillTake',5649,5649,[20,96,2,128,20],['original','96','left','base','current'],'K.Inv(mem,base,original,current,left) && current>0'),
  ('FillDone',5649,5752,[20,96,0,128,0],['original','96','left','base','current'],'K.Inv(mem,base,original,current,left) && current==0')]:
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
    a,ae=pop();push(MOD-1-a,'B.Mask()' if pc==5726 else None);guide+='B.CellWord(255);' if pc==5726 else ''
   elif op==81:
    at,ae=pop();assert at==128;push(2,'D.Steps(original)');guide+='K.Load(mem,base,D.Steps(original));'
   elif op in [1,3,4,6,16,17,22,27,26]:
    a,ae=pop();b,be=pop();v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,4:lambda:0 if b==0 else a//b,6:lambda:0 if b==0 else a%b,16:lambda:int(a<b),17:lambda:int(a>b),22:lambda:a&b,27:lambda:(b<<a)%MOD if a<256 else 0,26:lambda:0 if a>=32 else (b//(256**(31-a)))%256}[op]()
    if op in [1,3,4,6]:
     known={20555:'left-1',20305:'current%10',20235:'I.Digit(current)',5715:'31+left',5716:'base+31+left',20514:'current/10'}
     ex=known.get(pc) if pc in known else str(v) if ae.isdecimal() and be.isdecimal() else f'(({ae})+G.Modulus()-({be}))%G.Modulus()' if op==3 else f'(({ae})+({be}))%G.Modulus()';push(v,ex)
    elif op==27:
     assert a==248
     if pc==5694:push(v,'B.Cell(I.Digit(current))');guide+='B.CellWord(I.Digit(current));reveal S.ShiftLeft();'
     else:assert b==1;push(v);guide+='B.CellWord(1);reveal S.ShiftLeft();'
    elif op==22:push(v,'B.Cell(I.Digit(current))');guide+='B.MaskCell(I.Digit(current));'
    elif op==26:push(v,'I.Digit(current)');guide+='B.ByteCell(I.Digit(current));'
    else:push(v)
   elif op==83:
    at,ae=pop();v,ve=pop();assert at==161 and v==48;memory='F.Store8(mem,base+31+left,I.Digit(current))';guide+='K.Next(mem,base,original,current,left);P.InBounds(mem,base+31+left,I.Digit(current));'
   elif op in [86,87]:
    target,te=pop();assert te.isdecimal() and ins[target][0]==91;take=op==86 or pop()[0]!=0;dests.add(target)
    if take:nxt=target
   else:raise AssertionError((pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=oldmem,guide=guide));pc=nxt
  assert len(nodes)=={'FillTake':114,'FillDone':5}[name]
  params='prefix:seq<S.Word>,original:S.Word,left:S.Word,base:S.Word,current:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='prefix,original,left,base,current,mem,self,value,data,observations'
  def frame(pc,stack,mem):return f'M.Frame(S.Running({pc},prefix+['+','.join(stack)+f'],{mem}),[],0)'
  first=frame(start,nodes[0]['stack'],'mem');final=frame(stop,expr,memory);step='F.Step(code,destinations,state,self,value,data,observations)';module='OperationsToString'+name
  text='// SPDX-License-Identifier: MIT\n// Generated original-byte decimal macro; native proof pending.\ninclude "../tostring-kernel/FillMemory.dfy"\ninclude "../casefold-machine/Execution.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import CM = BytecodeCopyMachine\n  import F = OperationsCaseFoldMachine\n  import E = OperationsCaseFoldExecution\n  import D = OperationsToStringDecimal\n  import I = OperationsToStringInputs\n  import K = OperationsToStringFillMemory\n  import B = OperationsCaseFoldBinary\n  import P = OperationsCaseFoldMemory\n'
  text+=f'  predicate Admitted({params}) {{ |prefix|<=1000 && left<=78 && {guard} }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '
  text+=' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{params}) requires Admitted({args}) {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} D.WordDigits(original);K.Next(mem,base,original,current,left);reveal Good();reveal F.Step();reveal M.Step();reveal CM.Step();reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]=='+first+' && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n'
  if name=='FillTake':text+='    ensures K.Inv(state.state.memory,base,original,current/10,left-1)\n'
  elif name=='FillDone':text+='    ensures left==0 && K.Payload(mem,base,D.Steps(original))==I.Digits(original)\n'
  text+='  {\n    state:='+first+f';trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]=='+first+';assert trace[|trace|-1]==state;\n'
  if name=='FillTake':text+='    K.Next(mem,base,original,current,left);\n'
  elif name=='FillDone':text+='    K.Finish(mem,base,original,left);\n'
  text+='    reveal Good();\n  }\n}\n'
  if name=='FillDone':text=text.replace('K.Next(mem,base,original,current,left);','')
  r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
  paths.append(dict(name=name,start=start,nodes=nodes,terminalPc=stop,terminalStack=expr,terminalMemory=memory,destinations=sorted(dests)))
 (out/'fill.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=paths),indent=2)+'\n');print('Generated decimal fill macros114+5 actual instructions; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
