#!/usr/bin/env python3
"""Generate exact initial scaling and final correction instruction traces."""
import argparse, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[3]
STAGES=[('Scale',11273,11283),('Correction',11425,11451)]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:])
 inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(raw).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['sqrt(uint256)']=='677342ce'
 ins={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-95 if 96<=op<=127 else 0; nxt=pc+1+width;ins[pc]=(op,nxt,int.from_bytes(raw[pc+1:nxt],'big'));pc=nxt
 mapping=[]
 for name,start,end in STAGES:
  module='OperationsSquareRoot'+name;stack=['dead','estimate'];nodes=[];dests=set();pc=start
  while pc!=end:
   op,nxt,imm=ins[pc];before=stack[:];guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(str(imm))
   elif 128<=op<=143:
    depth=op-127
    if depth<=len(stack):stack.append(stack[-depth])
    else:assert depth-len(stack)==2;stack.append('n');guide='assert prefix[|prefix|-2]==n;'
   elif 144<=op<=159:
    k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op in [2,3,4,17,28]:
    a,b=stack.pop(),stack.pop()
    if op==2:assert (a,b)==('3','estimate');stack.append('((3*(estimate as nat))%M.Modulus())')
    elif op==4:assert (a,b)==('n','estimate');stack.append('M.Quotient(n,estimate)')
    elif op==17:assert (a,b)==('estimate','M.Quotient(n,estimate)');stack.append('(if estimate>M.Quotient(n,estimate) then 1 else 0)')
    elif op==3:assert a=='estimate';stack.append('Output(n,estimate)')
    else:assert a=='1';stack.append('Output(n,estimate)')
   elif op==87:
    dest,truth=stack.pop(),stack.pop();assert truth=='estimate';nxt=int(dest);dests.add(nxt)
   elif op==86:nxt=int(stack.pop());dests.add(nxt)
   else:raise AssertionError((pc,op))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,after=stack[:],guide=guide));pc=nxt;assert len(nodes)<30
  assert stack==(['dead','Output(n,estimate)','1'] if name=='Scale' else ['dead','Output(n,estimate)'])
  output='M.Right((3*(estimate as nat))%M.Modulus(),1)' if name=='Scale' else '((estimate as nat)+M.Modulus()-(if estimate>M.Quotient(n,estimate) then 1 else 0))%M.Modulus()'
  def shape(pc,s):return f'M.Running({pc},prefix+['+','.join(s)+'],mem)'
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete actual square-root edge trace; never edit directly.
include "../sqrt-opcode-kernel/Kernel.dfy"
module {module} {{
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  import K = OperationsSquareRootOpcodeKernel
  import F = OperationsSquareRootMath
  import N = OperationsSquareRootNewton
  function Output(n: M.Word,estimate: M.Word): M.Word {{ {output} }}
  predicate Admitted(n: M.Word,estimate: M.Word,prefix: seq<M.Word>) {{
    n>=2 && estimate>0 && 2<=|prefix|<=1000 && prefix[|prefix|-2]==n
  }}
  predicate Matches(code: seq<M.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{s["pc"]}<|code| && M.Fetch(code,{s["pc"]})==M.Op({s["opcode"]},{s["next"]},{s["immediate"]})' for s in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  predicate Good(id: nat,state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)\n    requires Admitted(n,estimate,prefix)\n  {\n'
  for i,s in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state=={shape(s["pc"],s["stack"])}\n'
  text+=f'    else if id=={len(nodes)} then state=={shape(end,stack)}\n    else false\n  }}\n'
  args='code: seq<M.Byte>,destinations: set<nat>,state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word'
  for i,s in enumerate(nodes):text+=f'''  lemma Advance{i}({args})
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Admitted(n,estimate,prefix) && Good({i},state,n,estimate,dead,prefix,mem)
    ensures Good({i+1},E.Execute(code,destinations,state,value,size,word,a),n,estimate,dead,prefix,mem)
  {{ {s['guide']} reveal E.Execute(); reveal M.Step(); }}
'''
  if name=='Scale':text+=f'''  lemma SemanticResult(state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>)
    requires Admitted(n,estimate,prefix) && Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    requires estimate<=F.Limit/2
    ensures state.Running? && state.stack==prefix+[dead,3*estimate/2,1]
  {{ K.FirstEstimate(estimate); }}
'''
  else:text+=f'''  lemma SemanticResult(state: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,root: nat)
    requires Admitted(n,estimate,prefix) && Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    requires F.IsRoot(n,root) && root<=estimate<=root+1
    ensures state.Running? && state.stack==prefix+[dead,root]
  {{
    reveal M.Quotient();
    N.Correct(n,estimate,root);
    assert estimate-(if estimate>n/estimate then 1 else 0)==root;
    assert root<M.Modulus();
  }}
'''
  text+=f'''  method Run(code: seq<M.Byte>,destinations: set<nat>,initial: M.State,n: M.Word,estimate: M.Word,dead: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    returns(state: M.State,trace: seq<M.State>)
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Admitted(n,estimate,prefix) && Good(0,initial,n,estimate,dead,prefix,mem)
    ensures Good({len(nodes)},state,n,estimate,dead,prefix,mem)
    ensures |trace|=={len(nodes)+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,a)
  {{
    state:=initial;trace:=[state];
'''
  for i in range(len(nodes)):text+=f'    Advance{i}(code,destinations,state,n,estimate,dead,prefix,mem,value,size,word,a);state:=E.Execute(code,destinations,state,value,size,word,a);trace:=trace+[state];\n'
  text+='  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);mapping.append(dict(name=name,start=start,frontier=end,states=nodes,output=output))
 (out/'edges.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(raw).hexdigest(),selector='677342ce',stages=mapping),indent=2)+'\n')
 print('Generated square-root edges:',sum(len(s['states']) for s in mapping),'instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
