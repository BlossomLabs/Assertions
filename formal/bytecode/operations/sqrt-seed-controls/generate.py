#!/usr/bin/env python3
"""Bind all fourteen executed seed threshold branches to exact current runtime instructions."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
M='OperationsBytecodeLog2Machine';E='OperationsSquareRootExecution'
STAGES=[(64,11130,11151),(32,11151,11178),(16,11178,11201),(8,11201,11222),(4,11222,11242),(2,11242,11261),(1,11261,11273)]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 inventory=json.loads((HERE.parent/'inventory.json').read_text());artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());raw=bytes.fromhex(artifact['deployedBytecode'].removeprefix('0x'))
 assert hashlib.sha256(raw).hexdigest()==inventory['runtimeSha256'] and inventory['compilerIdentity']['methodIdentifiers']['sqrt(uint256)']=='677342ce'
 instructions={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-0x5f if 0x60<=op<=0x7f else 0;nextpc=pc+1+width;instructions[pc]=(op,nextpc,int.from_bytes(raw[pc+1:nextpc],'big'));pc=nextpc
 destinations={pc for pc,(op,_,_) in instructions.items() if op==0x5b}
 constants='''// SPDX-License-Identifier: MIT
// Generated checked constant unfolding; never edit directly.
include "../sqrt-opcode-kernel/Execution.dfy"
module OperationsSquareRootSeedConstants {
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  lemma Threshold()
    ensures E.Left(1,128)==0x100000000000000000000000000000000
  {
'''
 for i in range(129):constants+=f'    assert M.Pow2({i})=={hex(1<<i)};\n'
 constants+='    reveal E.Left();\n  }\n}\n';(out/'Constants.generated.dfy').write_text(constants)
 mappings=[]
 for width,start,frontier in STAGES:
  for taken in [False,True]:
   name=f'Seed{width}'+('Taken' if taken else 'Skip');module='OperationsSquareRoot'+name;stack=['aa','seed'];pc=start;nodes=[]
   while pc!=frontier:
    op,nextpc,immediate=instructions[pc];before=stack[:];normal=''
    if op==0x5f or 0x60<=op<=0x7f:stack.append(str(immediate))
    elif op==0x5b:pass
    elif 0x80<=op<=0x8f:stack.append(stack[-(op-0x7f)])
    elif 0x90<=op<=0x9f:k=op-0x8f;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
    elif op==0x10:
     top,below=stack.pop(),stack.pop();stack.append(f'(if ({top})<({below}) then 1 else 0)')
    elif op==0x1b:
     amount,value=stack.pop(),stack.pop();expr=f'E.Left({value},{amount})'
     if value=='1' and amount=='128':expr=str(1<<128);normal='C.Threshold();'
     stack.append(expr)
    elif op==0x1c:
     amount,value=stack.pop(),stack.pop();stack.append(f'M.Right({value},{amount})')
    elif op==0x57:
     destination,truth=stack.pop(),stack.pop();nextpc=int(destination) if not taken else nextpc
     assert int(destination) in destinations
    else:raise AssertionError((name,pc,op))
    nodes.append(dict(pc=pc,opcode=op,next=instructions[pc][1],immediate=immediate,stack=before,after=stack[:],actualNext=nextpc,normal=normal));pc=nextpc
    assert len(nodes)<=25
   assert stack==(['aa',f'E.Left(seed,{width})'] if taken and width==1 else [f'M.Right(aa,{2*width})',f'E.Left(seed,{width})'] if taken else ['aa','seed']), (name,stack)
   def shape(pc,stack):return f'M.Running({pc},prefix+['+','.join(stack)+'],mem)'
   text=f'''// SPDX-License-Identifier: MIT
// Generated complete exact seed branch controls; never edit directly.
include "Constants.generated.dfy"
module {module} {{
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import C = OperationsSquareRootSeedConstants
  predicate Admitted(aa: M.Word,prefix: seq<M.Word>) {{ |prefix|<=1000 && aa{' >=' if taken else ' <'}{1<<(2*width)} }}
  predicate Matches(code: seq<M.Byte>) {{
'''
   text+='    '+' &&\n    '.join(f'{n["pc"]}<|code| && M.Fetch(code,{n["pc"]})==M.Op({n["opcode"]},{n["next"]},{n["immediate"]})' for n in nodes)
   relevant={n['actualNext'] for n in nodes if n['opcode']==0x57 and not taken}
   for dest in sorted(relevant):text+=f' &&\n    {dest}<|code| && code[{dest}]==0x5b'
   text+='\n  }\n  predicate Good(id: nat,state: M.State,aa: M.Word,seed: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)\n    requires Admitted(aa,prefix)\n  {\n'
   for i,n in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=={shape(n["pc"],n["stack"])}\n'
   text+=f'    else if id=={len(nodes)} then state=={shape(frontier,stack)}\n    else false\n  }}\n'
   for i,n in enumerate(nodes):
    text+=f'''  lemma Advance{i}(code: seq<M.Byte>,destinations: set<nat>,state: M.State,aa: M.Word,seed: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    requires Matches(code) && {{{','.join(map(str,sorted(relevant)))} }}<=destinations && Admitted(aa,prefix) && Good({i},state,aa,seed,prefix,mem)
    ensures Good({i+1},E.Execute(code,destinations,state,value,size,word,a),aa,seed,prefix,mem)
  {{
    {n['normal']}
    reveal E.Execute(); reveal M.Step();
  }}
'''
   text+=f'''  method Run(code: seq<M.Byte>,destinations: set<nat>,initial: M.State,aa: M.Word,seed: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word) returns(state: M.State,trace: seq<M.State>)
    requires Matches(code) && {{{','.join(map(str,sorted(relevant)))} }}<=destinations && Admitted(aa,prefix) && Good(0,initial,aa,seed,prefix,mem)
    ensures Good({len(nodes)},state,aa,seed,prefix,mem)
    ensures |trace|=={len(nodes)+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,a)
  {{
    state:=initial;trace:=[state];
'''
   for i in range(len(nodes)):text+=f'    Advance{i}(code,destinations,state,aa,seed,prefix,mem,value,size,word,a);state:=E.Execute(code,destinations,state,value,size,word,a);trace:=trace+[state];\n'
   text+='  }\n}\n';(out/(name+'.generated.dfy')).write_text(text)
   mappings.append(dict(name=name,width=width,taken=taken,start=start,frontier=frontier,nodes=nodes))
 (out/'seed.mapping.json').write_text(json.dumps(dict(runtimeSha256=inventory['runtimeSha256'],selector='677342ce',stages=mappings),indent=2)+'\n')
 print('Generated all fourteen actual seed branch traces:',sum(len(m['nodes']) for m in mappings),'executed instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
