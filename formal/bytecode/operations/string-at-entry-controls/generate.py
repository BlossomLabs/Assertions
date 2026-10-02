#!/usr/bin/env python3
"""Derive exact seven-step validator and index call setup macros."""
import argparse,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];SIG=0xa1bc2139

def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=w+1
 out.mkdir(parents=True,exist_ok=True);paths=[]
 for name,start,stop,st in [('Utf8Call',7279,11583,[hex(SIG),'1362','offset','length','word']),('IndexCall',7291,11497,[hex(SIG),'1362','offset','length','word','96'])]:
  pc=start;nodes=[];dests=set();stack=st[:]
  while pc!=stop:
   op,nxt,imm=ins[pc];nodes.append(dict(pc=pc,opcode=op,next=nxt,immediate=imm,stack=stack[:],memory='K.Initial()'))
   if op==91:pass
   elif op==95 or 96<=op<=127:stack.append(str(imm))
   elif 128<=op<=143:stack.append(stack[-(op-127)])
   elif op==86:dest=stack.pop();assert dest.isdecimal();nxt=int(dest);dests.add(nxt)
   else:raise AssertionError((name,pc,hex(op)))
   pc=nxt
  assert len(nodes)==7
  ps='offset:S.Word,length:S.Word,word:S.Word,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';vs='offset,length,word,self,value,data,observations';step='F.Step(code,destinations,state,self,value,data,observations)'
  def frame(pc,stack):return f'M.Frame(S.Running({pc},['+','.join(stack)+'],K.Initial()),[],0)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact call setup; native verification pending.
include "../string-at-kernel/Kernel.dfy"
module OperationsStringAt{name} {{
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import CM = BytecodeCopyMachine
  import F = OperationsCaseFoldMachine
  import E = OperationsCaseFoldExecution
  import K = OperationsStringAtKernel
  predicate Matches(code:seq<S.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))+'\n  }\n  function Destinations():set<nat> { {'+','.join(map(str,sorted(dests)))+'} }\n'
  text+=f'  opaque predicate Good(id:nat,state:M.Frame,{ps}) {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+frame(n['pc'],n['stack'])+'\n'
  final=frame(stop,stack);initial=frame(start,st);text+=f'    else if id==7 then state=={final}\n    else false\n  }}\n'
  for i in range(7):text+=f'''  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{ps})
    requires Matches(code) && Destinations()<=destinations && Good({i},state,{vs})
    ensures Good({i+1},{step},{vs})
  {{ K.InitialFits();reveal Good();F.Delegate(code,destinations,state,self,value,data,observations);M.Delegate(code,destinations,state,self,value,data,observations);CM.Delegate(code,destinations,state.state,value,data);reveal S.Step();reveal G.Step(); }}
'''
  text+=f'''  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{ps}) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations
    ensures state=={final}
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|==8 && trace[0]=={initial} && trace[|trace|-1]==state
  {{ state:={initial};trace:=[state];reveal Good();assert Good(0,state,{vs});
'''
  for i in range(7):text+=f'    Advance{i}(code,destinations,state,{vs});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];\n'
  text+='    reveal Good();\n  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);paths.append(dict(name=name,states=nodes,terminalPc=stop,terminalStack=stack,destinations=sorted(dests)))
 (out/'mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=paths),indent=2)+'\n');print('Generated fourteen exact call setup instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
