#!/usr/bin/env python3
"""Exact compiler scratch allocation and count guard, before/after zero copy."""
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
 def frame(n):return [E(785862473),E(518),E(100,'offset'),E(n*32,'n*32'),E(128),E(n,'n')]
 specs=[('CountGuard',3537,3564,frame(3)[:-1]+[E(0),E(3,'n')],3,'n < 0x800000000000000'),
        ('ScratchNonempty',3564,3602,frame(3)+[E(0),E(96,'n*32')],3,'0 < n < 0x800000000000000 && Load(mem,64) == 160+n*32'),
        ('ScratchEmpty',3564,3612,frame(0)+[E(0),E(0,'n*32')],0,'n == 0 && Load(mem,64) == 160+n*32')]
 for name,entry,end,initial,sample,pre in specs:
  stack=initial.copy();pc=entry;nodes=[];required={};targets=set();seen=set();mem='mem'
  while pc!=end:
   assert pc not in seen,(name,pc);seen.add(pc);op,nxt,imm=ins[pc]
   for pos in range(pc,nxt):required[pos]=code[pos]
   nodes.append({'id':len(nodes),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':mem})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(E(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x51:assert stack.pop().v==64;stack.append(E(160+sample*32,'160+n*32'))
   elif op==0x52:
    dst,val=stack.pop(),stack.pop();mem=f'Store({mem},{dst.t},{val.t})'
   elif op in [1,3]:
    a,b=stack.pop(),stack.pop();val=(a.v+b.v)%MOD if op==1 else (a.v-b.v)%MOD;tags={a.t,b.t}
    if a.constant() and b.constant():stack.append(E(val))
    elif op==1 and tags=={'n*32','31'}:stack.append(E(val,'n*32+31'))
    elif op==1 and tags=={'n*32','32'}:stack.append(E(val,'n*32+32'))
    elif op==1 and tags=={'n*32+32','160+n*32'}:stack.append(E(val,'192+2*n*32'))
    elif op==1 and tags=={'160+n*32','32'}:stack.append(E(val,'192+n*32'))
    elif op==1 and tags=={'192+n*32','n*32'}:stack.append(E(val,'192+2*n*32'))
    else:raise ValueError((name,pc,op,a.t,b.t))
   elif op==0x19:a=stack.pop();assert a.constant();stack.append(E(MOD-1-a.v))
   elif op==0x16:
    a,b=stack.pop(),stack.pop();assert a.v==MOD-32 and b.t=='n*32+31';stack.append(E(a.v&b.v,'n*32'))
   elif op==0x1b:a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(E((b.v<<a.v)%MOD))
   elif op==0x11:a,b=stack.pop(),stack.pop();stack.append(E(int(a.v>b.v)))
   elif op==0x15:stack.append(E(int(stack.pop().v==0)))
   elif op==0x36:stack.append(E(1000,'|data|'))
   elif op==0x57:
    dst,truth=stack.pop(),stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v]
    if truth.v:nxt=dst.v
   elif op==0x56:
    dst=stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v];nxt=dst.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  if name=='ScratchNonempty':specs.append(('ScratchTail',3603,3612,stack[:-3],sample,'n < 0x800000000000000'))
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));first=','.join(x.t for x in initial);last=','.join(x.t for x in stack)
  good='\n'.join('    '+('if' if x['id']==0 else 'else if')+f" id == {x['id']} then state == Running({x['pc']},[{','.join(x['stack'])}],{x['memory']})" for x in nodes)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated current sortWords scratch allocation segments.
include "../../scans/Execution.dfy"
include "../../scans/Representation.dfy"
include "../../scans/DecoderScalar.dfy"
include "MaskOpcode.dfy"
module BytecodeSort{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import R = BytecodeScanRepresentation
  import SC = BytecodeIotaAllocationScalar
  import DS = BytecodeScanDecoderScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeSortScratchAllocationMaskOpcode
  predicate Admitted(n: Word, mem: seq<Byte>, data: seq<Byte>) {{ {pre} && |mem| <= 192+2*n*32 && |data| < G.Modulus() }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>) {{ Admitted(n,mem,data) && (
{good}) }}
'''
  for x in nodes:
   i=x['id'];post=f'next == Running({end},[{last}],{mem})' if i==len(nodes)-1 else f'Good({i+1},next,n,offset,mem,data)';fetch=f"    F.Push{x['op']-95}(code,{x['pc']});\n" if x['op'] in [96,97] else '';support=''
   if x['op']==0x16:support=f"    MO.Step(code,Destinations(),[{','.join(x['stack'][:-2])}],{x['memory']},n,value,data);\n"
   if x['op']==0x1b:support+='    DS.DecoderLimit();\n'
   if 'ScratchNonempty'==name or 'ScratchEmpty'==name:support+='    R.StoredWord(mem,160+n*32,n*32);\n    R.StoredWord(Store(mem,160+n*32,n*32),64,192+2*n*32);\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,n,offset,mem,data)
    ensures state.Running? && |state.stack| <= {max(len(x['stack']) for x in nodes)} && |state.memory| <= 192+2*n*32
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
{'    reveal Step();' if x['op']!=0x16 else ''}
    SC.Not31(); AM.Mask(n);
{support}    assert state == Running({x['pc']},[{','.join(x['stack'])}],{x['memory']});
{fetch}    assert Fetch(code,{x['pc']}) == Op({x['op']},{x['next']},{x['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,n,offset,mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running({entry},[{first}],mem);\n    state := next{i};' for i in range(len(nodes)))
  text+=f'''  lemma Start(n: Word, offset: Word, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(n,mem,data)
    ensures Good(0,Running({entry},[{first}],mem),n,offset,mem,data)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,mem,data)
    ensures state == Running({end},[{last}],{mem}) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(nodes)+1} && trace[0] == Running({entry},[{first}],mem) && trace[|trace|-1] == state
  {{
    Start(n,offset,mem,data);
    state := Running({entry},[{first}],mem);
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':nodes,'requiredBytes':required,'destinations':sorted(targets),'expectedFinalStack':last,'expectedFinalMemory':mem,'scope':'Development physical scratch segments only; memory/copy/body/retention remain open.'},indent=2)+'\n');print(name,len(nodes),'actual steps',last)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
