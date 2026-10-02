#!/usr/bin/env python3
"""Generate six complete actual Newton update traces and independent intended stage witnesses."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
STAGES=[(0,11283,11305),(1,11305,11329),(2,11329,11353),(3,11353,11377),(4,11377,11401),(5,11401,11425)]
def generate(out,runtime=None):
 out.mkdir(parents=True,exist_ok=True);inv=json.loads((HERE.parent/'inventory.json').read_text());raw=runtime.read_bytes() if runtime else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert runtime or hashlib.sha256(raw).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['sqrt(uint256)']=='677342ce'
 instructions={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;nextpc=pc+1+width;instructions[pc]=(op,nextpc,int.from_bytes(raw[pc+1:nextpc],'big'));pc=nextpc
 mapping=[]
 for index,start,frontier in STAGES:
  name=f'Newton{index}';module='OperationsSquareRoot'+name;stack=['dead','estimate']+(['1'] if index==0 else []);pc=start;nodes=[];destinations=set()
  while pc!=frontier:
   op,nextpc,imm=instructions[pc];before=stack[:];guide=''
   if op==0x5f or 0x60<=op<=0x7f:stack.append(str(imm))
   elif op==0x5b:pass
   elif 0x80<=op<=0x8f:
    depth=op-0x7f
    if depth<=len(stack):stack.append(stack[-depth])
    else:
     assert depth-len(stack)==2;stack.append('n');guide='assert prefix[|prefix|-2]==n;'
   elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op in [0x01,0x02,0x04]:
    top,below=stack.pop(),stack.pop()
    if op==0x04:assert (top,below)==('n','estimate');stack.append('M.Quotient(n,estimate)')
    elif op==0x02:assert {top,below}=={'n','estimate'};stack.append('((n as nat)*(estimate as nat))%M.Modulus()')
    else:stack.append(f'((({top}) as nat)+(({below}) as nat))%M.Modulus()')
   elif op==0x1c:
    amount,value=stack.pop(),stack.pop();assert amount=='1';output=f'M.Right({value},1)';stack.append('Output(n,estimate)')
   elif op==0x57:
    destination,truth=stack.pop(),stack.pop();assert truth=='estimate' and instructions[int(destination)][0]==0x5b;destinations.add(int(destination));nextpc=int(destination)
   else:raise AssertionError((name,pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=instructions[pc][1],immediate=imm,actualNext=nextpc,stack=before,after=stack[:],guide=guide));pc=nextpc;assert len(nodes)<=25
  assert stack==['dead','Output(n,estimate)']
  def shape(pc,stack):return f'M.Running({pc},prefix+['+','.join(stack)+'],mem)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete actual Newton update trace; never edit directly.
include "../sqrt-opcode-kernel/Kernel.dfy"
module {module} {{
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import K = OperationsSquareRootOpcodeKernel
  import N = OperationsSquareRootNewton
  function Output(n: M.Word,estimate: M.Word): M.Word {{ {output} }}
  predicate Admitted(n: M.Word,estimate: M.Word,prefix: seq<M.Word>) {{
    n>=2 && estimate>0 && 2<=|prefix|<=1000 && prefix[|prefix|-2]==n
  }}
  predicate Matches(code: seq<M.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{s["pc"]}<|code| && M.Fetch(code,{s["pc"]})==M.Op({s["opcode"]},{s["next"]},{s["immediate"]})' for s in nodes)
  text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(destinations))+'\n  }\n'
  text+='  predicate Good(id: nat,state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)\n    requires Admitted(n,estimate,prefix)\n  {\n'
  for i,s in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=={shape(s["pc"],s["stack"])}\n'
  text+=f'    else if id=={len(nodes)} then state=={shape(frontier,stack)}\n    else false\n  }}\n'
  for i,s in enumerate(nodes):text+=f'''  lemma Advance{i}(code: seq<M.Byte>,destinations: set<nat>,state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    requires Matches(code) && {{{','.join(map(str,sorted(destinations)))}}}<=destinations && Admitted(n,estimate,prefix) && Good({i},state,n,estimate,dead,prefix,mem)
    ensures Good({i+1},E.Execute(code,destinations,state,value,size,word,a),n,estimate,dead,prefix,mem)
  {{ {s['guide']} reveal E.Execute();reveal M.Step(); }}
'''
  text+=f'''  lemma SemanticResult(state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)
    requires Admitted(n,estimate,prefix) && Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    requires estimate+n/estimate<M.Modulus()
    ensures state.Running? && |state.stack|>0 && state.stack[|state.stack|-1]==N.Next(n,estimate)
  {{ K.NextArithmetic(n,estimate); }}
  lemma SemanticWitness(state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)
    requires Admitted(n,estimate,prefix) && Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    requires n==123 && estimate==12
    ensures state.Running? && |state.stack|>0
    ensures state.stack[|state.stack|-1]==11
  {{ assert M.Pow2(1)==2;reveal M.Right(); }}
  method Run(code: seq<M.Byte>,destinations: set<nat>,initial: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    returns(state: M.State,trace: seq<M.State>)
    requires Matches(code) && {{{','.join(map(str,sorted(destinations)))}}}<=destinations && Admitted(n,estimate,prefix) && Good(0,initial,n,estimate,dead,prefix,mem)
    ensures Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    ensures |trace|=={len(nodes)+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,a)
  {{
    state:=initial;trace:=[state];
'''
  for i in range(len(nodes)):text+=f'    Advance{i}(code,destinations,state,n,estimate,dead,prefix,mem,value,size,word,a);state:=E.Execute(code,destinations,state,value,size,word,a);trace:=trace+[state];\n'
  text+='  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);mapping.append(dict(name=name,start=start,frontier=frontier,states=nodes,output=output))
 (out/'newton.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(raw).hexdigest(),selector='677342ce',stages=mapping),indent=2)+'\n');print('Generated six full Newton traces:',sum(len(m['states']) for m in mapping),'actual instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
