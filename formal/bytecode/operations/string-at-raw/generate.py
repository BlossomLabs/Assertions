#!/usr/bin/env python3
"""Generate all ordered stringAt raw rejections and accepted decoder prefix."""
import argparse,hashlib,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;SIG=0xa1bc2139;U64=1<<64
CASES={'Nonzero':(1,0,0,0),'Short':(0,0,0,0),'Args':(0,4,0,0),'OffsetBound':(0,100,U64,0),'LengthWindow':(0,100,U64-1,0),'LengthBound':(0,100,64,U64),'PayloadWindow':(0,101,64,2),'Accepted':(0,101,64,1)}
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((ROOT/'formal/bytecode/operations/inventory.json').read_text());assert hashlib.sha256(code).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['stringAt(bytes,int256)']=='a1bc2139'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 out.mkdir(parents=True,exist_ok=True);mappings=[]
 for name,(value,size,offset,length) in CASES.items():
  vals=[];expr=[];pc=0;memory='[]';nodes=[];dests=set();terminal=None;seen=set()
  def push(v,e=None):vals.append(v);expr.append(str(v) if e is None else e)
  def pop():return vals.pop(),expr.pop()
  while True:
   if name=='Accepted' and pc==7279:break
   assert (pc,tuple(vals),tuple(expr)) not in seen;seen.add((pc,tuple(vals),tuple(expr)));op,nxt,imm=ins[pc];before=expr[:];mem=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif op==0x34:push(value,'value')
   elif op==0x36:push(size,'|data|')
   elif op==0x35:
    at,ae=pop()
    if at==0:push(SIG<<224,'S.DataWord(data,0)')
    elif at==4:push(offset,'I.Offset(data)');guide+='I.Word(data,4);'
    elif at==36:push(0,'I.IndexWord(data)');guide+='I.Word(data,36);'
    else:assert at==offset+4;push(length,'I.Length(data)');guide+='I.Word(data,I.Offset(data)+4);'
   elif 128<=op<=143:k=op-127;push(vals[-k],expr[-k])
   elif 144<=op<=159:k=op-143;vals[-1],vals[-1-k]=vals[-1-k],vals[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e=pop();push(int(v==0),f'Bool(({e})==0)' if not e.isdecimal() else None)
   elif op in [1,3,16,17,18,20,27,28]:
    a,ae=pop();b,be=pop();signed=lambda n:n if n<MOD//2 else n-MOD;v={1:lambda:(a+b)%MOD,3:lambda:(a-b)%MOD,16:lambda:int(a<b),17:lambda:int(a>b),18:lambda:int(signed(a)<signed(b)),20:lambda:int(a==b),27:lambda:(b<<a)%MOD if a<256 else 0,28:lambda:b>>a if a<256 else 0}[op]()
    if op==28:assert ae=='224';push(v,str(SIG));guide+=f'assert S.ShiftRight(S.DataWord(data,0),224)=={SIG};'
    elif ae.isdecimal() and be.isdecimal():push(v);guide+='reveal S.ShiftLeft();' if op==27 else ''
    else:
     ex={1:f'((({ae}) as nat)+(({be}) as nat))%G.Modulus()',3:f'((({ae}) as nat)+G.Modulus()-(({be}) as nat))%G.Modulus()',16:f'Bool(({ae})<({be}))',17:f'Bool(({ae})>({be}))',18:f'Bool(G.Signed({ae})<G.Signed({be}))',20:f'Bool(({ae})==({be}))'}[op];push(v,ex)
   elif op==0x52:
    at,_=pop();v,_=pop();assert(at,v)==(64,128);memory='K.Initial()';guide+='K.InitialFits();'
   elif op in [0x56,0x57]:
    target,te=pop();assert te.isdecimal();take=op==0x56 or pop()[0]!=0;assert ins[target][0]==0x5b;dests.add(target)
    if take:nxt=target
   elif op==0xfd:assert(pop()[0],pop()[0])==(0,0);terminal='S.Reverted([])'
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=mem,guide=guide));pc=nxt
   if terminal:break
   assert len(nodes)<220
  params='self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='self,value,data,observations';module='OperationsStringAtRaw'+name;ds='{'+','.join(map(str,sorted(dests)))+'}'
  def state(pc,stack,mem):return f'M.Frame(S.Running({pc},['+','.join(stack)+f'],{mem}),[],0)'
  final='M.Frame('+terminal+',[],0)' if terminal else state(pc,expr,memory)
  text='// SPDX-License-Identifier: MIT\n// Generated exact stringAt raw prefix. Never edit directly.\ninclude "../string-at-kernel/Kernel.dfy"\nmodule '+module+' {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import C = BytecodeCopyMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsCaseFoldExecution\n  import F = OperationsCaseFoldMachine\n  import I = OperationsStringAtInputs\n  import K = OperationsStringAtKernel\n  function Bool(value:bool):S.Word { if value then 1 else 0 }\n'
  text+=f'  predicate Admitted({params}) {{ I.Frame(data) && I.Assigned(data,value) && I.Admission(data,value)==I.{name} }}\n  predicate Matches(code:seq<S.Byte>) {{\n    '+' &&\n    '.join(f'{n["pc"]}<|code| && S.Fetch(code,{n["pc"]})==S.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n'+f'  function Destinations():set<nat> {{ {ds} }}\n  opaque predicate Good(id:nat,state:M.Frame,{params})\n    requires Admitted({args})\n  {{\n'
  for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=='+state(n['pc'],n['stack'],n['memory'])+'\n'
  text+=f'    else if id=={len(nodes)} then state=='+final+'\n    else false\n  }\n';step='F.Step(code,destinations,state,self,value,data,observations)'
  for i,n in enumerate(nodes):text+=f'  lemma Advance{i}(code:seq<S.Byte>,destinations:set<nat>,state:M.Frame,{params})\n    requires Matches(code) && Destinations()<=destinations && Admitted({args}) && Good({i},state,{args})\n    ensures Good({i+1},{step},{args})\n  {{ {n["guide"]} reveal Good();F.Delegate(code,destinations,state,self,value,data,observations);M.Delegate(code,destinations,state,self,value,data,observations);C.Delegate(code,destinations,state.state,value,data);reveal S.Step();reveal G.Step(); }}\n'
  text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{params}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code) && Destinations()<=destinations && Admitted({args})\n    ensures state=='+final+f'\n    ensures |trace|=={len(nodes)+1} && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state\n    ensures E.Trace(code,destinations,self,value,data,observations,trace)\n  {{\n    state:=M.Frame(S.Running(0,[],[]),[],0);trace:=[state];reveal Good();assert Good(0,state,{args});\n'
  for i,n in enumerate(nodes):text+=f'    Advance{i}(code,destinations,state,{args});reveal Good();assert {step}.state!=S.Bad;E.Extend(code,destinations,self,value,data,observations,trace,{step});state:={step};trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==M.Frame(S.Running(0,[],[]),[],0);assert trace[|trace|-1]==state;\n'
  text+='    reveal Good();\n  }\n}\n';r=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True);assert r.returncode==0,r.stderr;(out/(name+'.generated.dfy')).write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'));mappings.append(dict(name=name,start=0,nodes=nodes,terminal=final,destinations=sorted(dests)))
 (out/'raw.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),paths=mappings),indent=2)+'\n');print('Generated8 complete stringAt raw prefixes;',sum(len(p['nodes']) for p in mappings),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
