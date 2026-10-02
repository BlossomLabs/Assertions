#!/usr/bin/env python3
"""Generate exact cleanup and physical word return for both square-root exits."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(raw).hexdigest()==inv['runtimeSha256']
 selector=int('677342ce',16);ins={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;ins[pc]=(op,nxt,int.from_bytes(raw[pc+1:nxt],'big'));pc=nxt
 mapping=[]
 for name,start in [('Iterated',11451),('Early',2984)]:
  stack=[str(selector),'1329','n','0']+(['2984','n','0','dead'] if name=='Iterated' else [])+['result'];pc=start;memory='M.Store([],64,128)';nodes=[];dests=set()
  while True:
   op,nxt,imm=ins[pc];before=stack[:];mem=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(str(imm))
   elif 128<=op<=143:stack.append(stack[-(op-127)])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x56:nxt=int(stack.pop());dests.add(nxt)
   elif op==0x51:
    assert stack.pop()=='64';stack.append('128');guide='M.StoreLoad([],64,128);'
    if memory!='M.Store([],64,128)':guide+='M.StoreFrame(M.Store([],64,128),128,result,64);'
   elif op==0x52:
    assert(stack.pop(),stack.pop())==('128','result');memory='M.Store(M.Store([],64,128),128,result)';guide='M.StoreLoad(M.Store([],64,128),128,result);'
   elif op==1:assert {stack.pop(),stack.pop()}=={'32','128'};stack.append('160')
   elif op==3:assert(stack.pop(),stack.pop())==('160','128');stack.append('32')
   elif op==0xf3:
    assert(stack.pop(),stack.pop())==('128','32');guide='M.StoreLoad(M.Store([],64,128),128,result);assert M.Grow(M.Store(M.Store([],64,128),128,result),160)==M.Store(M.Store([],64,128),128,result);'
   else:raise AssertionError((name,pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=mem,after=stack[:],guide=guide));pc=nxt
   if op==0xf3:break
   assert len(nodes)<50
  module='OperationsSquareRootReturn'+name
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical cleanup/return trace; never edit directly.
include "../sqrt-opcode-kernel/Execution.dfy"
module {module} {{
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  predicate Matches(code: seq<M.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{s["pc"]}<|code| && M.Fetch(code,{s["pc"]})==M.Op({s["opcode"]},{s["next"]},{s["immediate"]})' for s in nodes)
  text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))+'\n  }\n'
  text+='  predicate Good(id:nat,state:M.State,n:M.Word,dead:M.Word,result:M.Word) {\n'
  for i,s in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state==M.Running({s["pc"]},['+','.join(s['stack'])+f'],{s["memory"]})\n'
  text+=f'    else if id=={len(nodes)} then state==M.Returned(M.Encode(result,32))\n    else false\n  }}\n'
  for i,s in enumerate(nodes):text+=f'''  lemma Advance{i}(code:seq<M.Byte>,destinations:set<nat>,state:M.State,n:M.Word,dead:M.Word,result:M.Word,value:M.Word,size:M.Word,word:M.Word,a:M.Word)
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Good({i},state,n,dead,result)
    ensures Good({i+1},E.Execute(code,destinations,state,value,size,word,a),n,dead,result)
  {{ {s['guide']} reveal E.Execute();reveal M.Step(); }}
'''
  text+=f'''  method Run(code:seq<M.Byte>,destinations:set<nat>,initial:M.State,n:M.Word,dead:M.Word,result:M.Word,value:M.Word,size:M.Word,word:M.Word,a:M.Word)
    returns(state:M.State,trace:seq<M.State>)
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Good(0,initial,n,dead,result)
    ensures state==M.Returned(M.Encode(result,32))
    ensures |trace|=={len(nodes)+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,a)
  {{
    state:=initial;trace:=[state];
'''
  for i in range(len(nodes)):text+=f'    Advance{i}(code,destinations,state,n,dead,result,value,size,word,a);state:=E.Execute(code,destinations,state,value,size,word,a);trace:=trace+[state];\n'
  text+='  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);mapping.append(dict(name=name,start=start,states=nodes))
 (out/'returns.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(raw).hexdigest(),selector='677342ce',paths=mapping),indent=2)+'\n');print('Generated both physical return paths:',sum(len(p['states']) for p in mapping),'instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
