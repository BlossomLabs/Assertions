#!/usr/bin/env python3
"""Extract actual sortWords initial copy allocation; never edit its outputs."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];digest=hashlib.sha256(code).hexdigest();assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['sortWords(bytes)']=='2ed74f49'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 specs=[('CopyHeader',3468,3510,[E(785862473),E(518),E(100,'offset'),E(96,'n*32'),E(96)],'Store([],64,128)'),
        ('CopyTail',3511,23562,[E(785862473),E(518),E(100,'offset'),E(96,'n*32'),E(96),E(128),E(100,'offset'),E(96,'n*32'),E(96,'n*32'),E(160),E(100,'offset'),E(96,'n*32')],'mem')]
 for name,entry,end,initial,memory in specs:
  stack=initial.copy();pc=entry;nodes=[];required={};targets=set();seen=set();mem=memory
  while pc!=end:
   assert pc not in seen,(name,pc,[(x.t,x.v) for x in stack]);seen.add(pc);op,nxt,imm=ins[pc]
   for pos in range(pc,nxt):required[pos]=code[pos]
   nodes.append({'id':len(nodes),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':mem})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(E(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x51:
    assert stack.pop().v==64 and mem=='Store([],64,128)';stack.append(E(128))
   elif op==0x52:
    dst,val=stack.pop(),stack.pop();mem=f'Store({mem},{dst.t},{val.t})'
   elif op in [1,2,4]:
    a,b=stack.pop(),stack.pop();val=(a.v+b.v)%MOD if op==1 else (a.v*b.v)%MOD if op==2 else (0 if b.v==0 else a.v//b.v)
    if a.constant() and b.constant():
     stack.append(E(val));pc=nxt;continue
    tags={a.t,b.t}
    if op==1 and tags=={'n*32','31'}:tag='n*32+31'
    elif op==4 and a.t=='n*32+31' and b.t=='32':tag='n'
    elif op==2 and tags=={'n','32'}:tag='n*32'
    elif op==1 and tags=={'n*32','32'}:tag='n*32+32'
    elif op==1 and tags=={'n*32+32','128'}:tag='160+n*32'
    elif op==1 and tags=={'n*32','160'}:tag='160+n*32'
    else:raise ValueError((name,pc,op,a.t,b.t))
    stack.append(E(val,tag))
   elif op==0x56:
    dst=stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v];nxt=dst.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));first=','.join(x.t for x in initial);last=','.join(x.t for x in stack)
  good='\n'.join('    '+('if' if x['id']==0 else 'else if')+f" id == {x['id']} then state == Running({x['pc']},[{','.join(x['stack'])}],{x['memory']})" for x in nodes)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated current sortWords initial-copy instructions, before/after CALLDATACOPY.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeSortAllocation{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  predicate Admitted(n: Word, mem: seq<Byte>) {{ n < 0x800000000000000 && |mem| <= 192+n*32 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>) {{ Admitted(n,mem) && (
{good}) }}
'''
  for x in nodes:
   i=x['id'];post=f'next == Running({end},[{last}],{mem})' if i==len(nodes)-1 else f'Good({i+1},next,n,offset,mem)';fetch=f"    F.Push{x['op']-95}(code,{x['pc']});\n" if x['op'] in [96,97] else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,mem) && Good({i},state,n,offset,mem)
    ensures state.Running? && |state.stack| <= {max(len(x['stack']) for x in nodes)} && |state.memory| <= 192+n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),64,160+n*32);
    R.StoredWord(Store(Store([],64,128),64,160+n*32),128,n*32);
    assert (n*32+31)/32 == n;
    assert state == Running({x['pc']},[{','.join(x['stack'])}],{x['memory']});
{fetch}    assert Fetch(code,{x['pc']}) == Op({x['op']},{x['next']},{x['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,n,offset,mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running({entry},[{first}],{memory});\n    state := next{i};' for i in range(len(nodes)))
  text+=f'''  lemma Start(n: Word, offset: Word, mem: seq<Byte>)
    requires Admitted(n,mem)
    ensures Good(0,Running({entry},[{first}],{memory}),n,offset,mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem)
    ensures state == Running({end},[{last}],{mem}) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(nodes)+1} && trace[0] == Running({entry},[{first}],{memory}) && trace[|trace|-1] == state
  {{
    Start(n,offset,mem);
    state := Running({entry},[{first}],{memory});
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':nodes,'requiredBytes':required,'destinations':sorted(targets),'expectedFinalStack':last,'expectedFinalMemory':mem,'scope':'Development initial copy allocation segments only; physical copy and complete public retention remain open.'},indent=2)+'\n');print(name,len(nodes),'actual steps',last)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
