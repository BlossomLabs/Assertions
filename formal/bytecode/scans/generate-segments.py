#!/usr/bin/env python3
"""Actual sum loop straight-line instruction segments, separated at helper calls."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 O=E(68,'offset');L=E(96,'length');T=E(3,'total');I=E(1,'index');C=E(3,'length/32');W=E(7,'word');P=E(32,'Position(index)');N=E(64,'NextPosition(index)');Q=E(100,'WordOffset(offset,index)')
 frame=[E(394725771),E(604),O,L];loop=frame+[T,C,I]
 base='length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32'
 specs=[
 ('BodyStart',0xacf,0x5be3,frame,base.replace(' && length%32 == 0',''),'394725771,604,offset,length,0,2779,32,length'),
 ('Aligned',0xadb,0x5c0a,frame+[E(0),E(0,'length%32')],base,'394725771,604,offset,length,0,0,2824,32,length'),
 ('Count',0xb08,0xb0c,frame+[E(0),E(0),C],base,'394725771,604,offset,length,0,length/32,0'),
 ('Guard',0xb0c,0x5c1d,loop,base+' && index < length/32','394725771,604,offset,length,total,length/32,index,offset,length,2849,index,32'),
 ('AfterMulFirst',0xb21,0x5c1d,loop+[O,L,P],base+' && index < length/32','394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2861,index,32'),
 ('AfterMulSecond',0xb2d,0x5c34,loop+[O,P,L,P],base+' && index < length/32','394725771,604,offset,length,total,length/32,index,offset,Position(index),length,2872,Position(index),32'),
 ('AfterEnd',0xb38,0x5c47,loop+[O,P,L,N],base+' && index < length/32','394725771,604,offset,length,total,length/32,index,2885,NextPosition(index),Position(index),length,offset'),
 ('AfterSlice',0xb45,0x5c6e,loop+[Q,E(32)],base+' && index < length/32','394725771,604,offset,length,total,length/32,index,2894,32,WordOffset(offset,index)'),
 ('AfterRead',0xb4e,0x5c34,loop+[W],base+' && index < length/32','394725771,604,offset,length,total,length/32,index,2904,word,total'),
 ('AfterSum',0xb58,0xb0c,loop+[W],base+' && index < length/32','394725771,604,offset,length,word,length/32,(index as nat)+1'),
 ('Exit',0xb0c,0x25c,frame+[T,C,E(3,'index')],base+' && index == length/32','394725771,total')]
 for name,entry,end,initial,pre,final in specs:
  s=initial.copy();pc=entry;states=[];required={};targets=set();seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while pc!=end:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(E(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op==0x01:
    a,b=pop(),pop();v=(a.v+b.v)%MOD;push(E(v) if a.constant() and b.constant() else E(v,f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'))
   elif op==0x10:a,b=pop(),pop();push(E(int(a.v<b.v)))
   elif op==0x15:push(E(int(pop().v==0)))
   elif op==0x57:
    dest,truth=pop(),pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],mem)" for n in states)+'\n    else false'
  params='offset: Word, length: Word, total: Word, index: Word, word: Word';actual='offset,length,total,index,word'
  text=f'''// SPDX-License-Identifier: MIT
// Generated pinned sum loop instructions between actual helper boundaries.
include "Execution.dfy"
module BytecodeSum{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word {{ ((index as nat)*32)%G.Modulus() }}
  function NextPosition(index: Word): Word {{ (((index as nat)+1)*32)%G.Modulus() }}
  function WordOffset(offset: Word, index: Word): Word {{ ((offset as nat)+(index as nat)*32)%G.Modulus() }}
  predicate Admitted({params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}, mem: seq<Byte>) {{ Admitted({actual}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == Running({end},[{final}],mem)' if i==len(states)-1 else f'Good({i+1},next,{actual},mem)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && Good({i},state,{actual},mem)
    ensures state.Running? && |state.stack| <= 20 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},[{','.join(n['stack'])}],mem);
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  first=','.join(x.t for x in initial);calls='\n'.join(f'    Advance{i}(code,state,{actual},mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start({params}, mem: seq<Byte>)
    requires Admitted({actual})
    ensures Good(0,Running({entry},[{first}],mem),{actual},mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual})
    ensures state == Running({end},[{final}],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},[{first}],mem) && trace[|trace|-1] == state
  {{
    Start({actual},mem);
    state := Running({entry},[{first}],mem);
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'expectedFinalStack':final,'scope':'development admitted actual loop segment only; unbounded loop/public entry and retained evidence remain open'},indent=2)+'\n');print(name,len(states),'states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
