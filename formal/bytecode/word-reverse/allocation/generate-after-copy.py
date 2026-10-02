#!/usr/bin/env python3
"""Actual reverseWords post-copy allocator path, bound to canonical bytes."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;SELECTOR=2874738232
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];digest=hashlib.sha256(code).hexdigest();assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['reverseWords(bytes)']=='ab590638'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 for name,sample,pre in [('AfterCopy',0,'n < 0x800000000000000 && i == 0')]:
  pc=5838;stack=[E(SELECTOR),E(518),E(68,"offset"),E(64,"n*32"),E(96),E(2,"n"),E(128),E(64,"n*32"),E(160),E(64,"n*32")];mem="O.Heap(n,0)";nodes=[];required={};targets=set();seen=set()
  while not (nodes and pc==5846):
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   nodes.append({'id':len(nodes),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':mem})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(E(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x02:
    a,b=stack.pop(),stack.pop();assert {a.t,b.t}=={'i','32'};stack.append(E(a.v*b.v,'i*32'))
   elif op==0x01:
    a,b=stack.pop(),stack.pop();val=(a.v+b.v)%MOD
    if {a.t,b.t}=={'n*32','160'}:stack.append(E(val,'O.Extent(n)'))
    elif {a.t,b.t}=={'i*32','128'}:stack.append(E(val,'128+i*32'))
    elif {a.t,b.t}=={'128+i*32','32'}:stack.append(E(val,'160+i*32'))
    elif {a.t,b.t}=={'i','1'}:stack.append(E(val,'i+1'))
    else:raise ValueError((pc,a.t,b.t))
   elif op==0x10:
    a,b=stack.pop(),stack.pop();assert a.t=='i' and b.t=='n';stack.append(E(int(a.v<b.v)))
   elif op==0x52:
    offset,a=stack.pop(),stack.pop();assert offset.t=='160+i*32' and a.t=='i';mem='O.Heap(n,i+1)'
   elif op==0x15:stack.append(E(int(stack.pop().v==0)))
   elif op==0x57:
    dst,truth=stack.pop(),stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v]
    if truth.v:nxt=dst.v
   elif op==0x56:
    dst=stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v];nxt=dst.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  assert pc==5846
  finalStack=[x.t for x in stack]
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n["memory"]})" for n in nodes)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));final=f'Running({pc},[{','.join(finalStack)}],{mem})'
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual post-copy allocator instructions.
include "../../iota/Output.dfy"
include "../../scans/Execution.dfy"
module BytecodeReverseAllocation{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import O = BytecodeIotaOutput
  predicate Admitted(n: Word, offset: Word, i: Word) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, i: Word) {{ Admitted(n,offset,i) && (
{good}) }}
'''
  for n in nodes:
   i=n['id'];post=f'next == {final}' if i==len(nodes)-1 else f'Good({i+1},next,n,offset,i)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,offset,i) && Good({i},state,n,offset,i)
    ensures state.Running? && |state.stack| <= {max(len(x["stack"]) for x in nodes)} && |state.memory| == O.Extent(n)
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{('    O.Advance(n,i);' if n['op']==0x52 else '')}
    assert state == Running({n['pc']},[{','.join(n['stack'])}],{n["memory"]});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,n,offset,i,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running(5838,[{SELECTOR},518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));\n    state := next{i};' for i in range(len(nodes)))
  text+=f'''  lemma Start(n: Word, offset: Word, i: Word)
    requires Admitted(n,offset,i)
    ensures Good(0,Running(5838,[{SELECTOR},518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0)),n,offset,i)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, i: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,offset,i)
    ensures state == {final}
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(nodes)+1} && trace[0] == Running(5838,[{SELECTOR},518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0)) && trace[|trace|-1] == state
  {{
    Start(n,offset,i);
    state := Running(5838,[{SELECTOR},518,offset,n*32,96,n,128,n*32,160,n*32],O.Heap(n,0));
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':nodes,'requiredBytes':required,'destinations':sorted(targets),'scope':'Development actual post-copy allocator only; public retention remains open.'},indent=2)+'\n');print(name,len(nodes),'actual post-copy states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
