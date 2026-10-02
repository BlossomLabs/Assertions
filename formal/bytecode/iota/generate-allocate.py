#!/usr/bin/env python3
"""Actual iota header allocation and pre-copy transitions."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256;SELECTOR=2368205965
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];digest=hashlib.sha256(code).hexdigest();assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['iotaWords(uint256)']=='8d27f48d'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 for name,sample,pre in [('AllocateNonempty',2,'0 < n < 0x800000000000000'),('AllocateEmpty',0,'n == 0')]:
  pc=5576;mem="Store([],64,128)";stack=[E(SELECTOR),E(518),E(sample,"n"),E(96),E(sample*32,"n*32")];nodes=[];required={};targets=set();seen=set()
  while pc!=(5614 if name=='AllocateNonempty' else 5623):
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   nodes.append({'id':len(nodes),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.t for x in stack],'memory':mem})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(E(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==0x51:
    assert stack.pop().v==64 and mem=='Store([],64,128)';stack.append(E(128))
   elif op==0x52:
    offset,a=stack.pop(),stack.pop();assert offset.constant();mem=f'Store({mem},{offset.t},{a.t})'
   elif op==0x01:
    a,b=stack.pop(),stack.pop();val=(a.v+b.v)%MOD
    if a.constant() and b.constant():stack.append(E(val))
    elif {a.t,b.t}=={'n*32','31'}:stack.append(E(val,'n*32+31'))
    elif {a.t,b.t}=={'Aligned(n)','32'}:stack.append(E(val,'Plus(n)'))
    elif {a.t,b.t}=={'Plus(n)','128'}:stack.append(E(val,'Free(n)'))
    else:raise ValueError((pc,a.t,b.t))
   elif op==0x19:
    a=stack.pop();assert a.constant();stack.append(E(MOD-1-a.v))
   elif op==0x16:
    a,b=stack.pop(),stack.pop();assert a.v==MOD-32 and b.t=='n*32+31';stack.append(E(a.v&b.v,'Aligned(n)'))
   elif op==0x36:stack.append(E(36,'|data|'))
   elif op==0x15:stack.append(E(int(stack.pop().v==0)))
   elif op==0x57:
    dst,truth=stack.pop(),stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v]
    if truth.v:nxt=dst.v
   elif op==0x56:
    dst=stack.pop();assert dst.constant() and dst.v in dests;targets.add(dst.v);required[dst.v]=code[dst.v];nxt=dst.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  assert pc==(5614 if name=='AllocateNonempty' else 5623)
  finalStack=[x.t for x in stack]
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n["memory"]})" for n in nodes)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));final=f'Running({pc},[{','.join(finalStack)}],{mem})'
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual iota header allocation and pre-copy instructions.
include "Arithmetic.dfy"
include "AllocationScalar.dfy"
include "MaskOpcode.dfy"
include "../alignment/Mask.dfy"
include "../scans/Representation.dfy"
module BytecodeIota{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import A = BytecodeIotaArithmetic
  import SC = BytecodeIotaAllocationScalar
  import AM = BytecodeWordLengthMask
  import MO = BytecodeIotaMaskOpcode
  import R = BytecodeScanRepresentation
  opaque function Aligned(n: Word): Word
    requires n < 0x800000000000000
  {{ G.BitAnd(n*32+31,BitNot(31)) }}
  opaque function Plus(n: Word): Word
    requires n < 0x800000000000000
  {{ ((Aligned(n) as nat)+32)%G.Modulus() }}
  opaque function Free(n: Word): Word
    requires n < 0x800000000000000
  {{ ((Plus(n) as nat)+128)%G.Modulus() }}
  lemma DefineAligned(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == G.BitAnd(n*32+31,BitNot(31))
  {{ reveal Aligned(); }}
  lemma DefinePlus(n: Word)
    requires n < 0x800000000000000
    ensures Plus(n) == ((Aligned(n) as nat)+32)%G.Modulus()
  {{ reveal Plus(); }}
  lemma DefineFree(n: Word)
    requires n < 0x800000000000000
    ensures Free(n) == ((Plus(n) as nat)+128)%G.Modulus()
  {{ reveal Free(); }}
  lemma AlignedLength(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == n*32
  {{ DefineAligned(n); AM.Mask(n); }}
  lemma PlusLength(n: Word)
    requires n < 0x800000000000000
    ensures Plus(n) == n*32+32
  {{ AlignedLength(n); DefinePlus(n); }}
  lemma FreeLength(n: Word)
    requires n < 0x800000000000000
    ensures Free(n) == n*32+160
  {{ PlusLength(n); DefineFree(n); }}
  lemma Normalized(n: Word)
    requires n < 0x800000000000000
    ensures Aligned(n) == n*32 && Plus(n) == n*32+32 && Free(n) == n*32+160
  {{ AlignedLength(n); PlusLength(n); FreeLength(n); }}
  predicate Admitted(n: Word, data: seq<Byte>) {{ {pre} && |data| < G.Modulus() }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, n: Word, data: seq<Byte>) {{ Admitted(n,data) && (
{good}) }}
'''
  for n in nodes:
   i=n['id'];post=f'next == {final}' if i==len(nodes)-1 else f'Good({i+1},next,n,data)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, n: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,data) && Good({i},state,n,data)
    ensures state.Running? && |state.stack| <= {max(len(x["stack"]) for x in nodes)} && |state.memory| <= 160
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
{("" if n["pc"]==5591 else "    reveal Step();")}
    A.Fit(n);
    Normalized(n);
    SC.Not31();
{('    assert state == Running(5591,[2368205965,518,n,96,128,n*32]+[n*32+31,0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0],Store(Store([],64,128),128,n*32));\n    MO.Step(code,Destinations(),[2368205965,518,n,96,128,n*32],Store(Store([],64,128),128,n*32),n,value,data);\n    assert Step(code,Destinations(),state,value,data) == Running(5592,[2368205965,518,n,96,128,n*32]+[n*32],Store(Store([],64,128),128,n*32));' if n['pc']==5591 else '    DefinePlus(n);' if n['pc']==5594 else '    DefineFree(n);' if n['pc']==5596 else '')}
    R.StoredWord([],64,128);
    R.StoredWord(Store([],64,128),128,n*32);
    R.StoredWord(Store(Store([],64,128),128,n*32),64,Free(n));
    assert state == Running({n['pc']},[{','.join(n['stack'])}],{n["memory"]});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,n,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(nodes)))
  text+=f'''  lemma Start(n: Word, data: seq<Byte>)
    requires Admitted(n,data)
    ensures Good(0,Running(5576,[{SELECTOR},518,n,96,n*32],Store([],64,128)),n,data)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, n: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,data)
    ensures state == {final}
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(nodes)+1} && trace[0] == Running(5576,[{SELECTOR},518,n,96,n*32],Store([],64,128)) && trace[|trace|-1] == state
  {{
    Start(n,data);
    state := Running(5576,[{SELECTOR},518,n,96,n*32],Store([],64,128));
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':nodes,'requiredBytes':required,'destinations':sorted(targets),'scope':'Development actual header allocation and pre-copy transitions only; public retention remains open.'},indent=2)+'\n');print(name,len(nodes),'actual allocation header states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
