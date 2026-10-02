#!/usr/bin/env python3
"""Actual zipWords instruction segments separated at helper calls."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['zipWords(bytes,bytes)']=='1008e959'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 A=E(100,'a');B=E(228,'b');L=E(96,'length');I=E(1,'index');N=E(3,'length/32');WA=E(7,'wordA');WB=E(11,'wordB');P=E(32,'Position(index)');Q=E(64,'NextPosition(index)');OA=E(132,'WordOffset(a,index)');OB=E(260,'WordOffset(b,index)')
 frame=[E(269019481),E(518),A,L,B,L,E(128),N];loop=frame+[I]
 base='length < 0x8000000000000000 && (a as nat)+(length as nat) < G.Modulus() && (b as nat)+(length as nat) < G.Modulus() && length%32 == 0 && index <= length/32'
 f='269019481,518,a,length,b,length,128,length/32';l=f+',index'
 specs=[
 ('Guard',2094,23581,loop,base+' && index < length/32',l+',0,a,length,2116,index,32'),
 ('AfterPositionAStart',2116,23581,loop+[E(0),A,L,P],base+' && index < length/32',l+',0,a,Position(index),length,2128,index,32'),
 ('AfterPositionAEnd',2128,23604,loop+[E(0),A,P,L,P],base+' && index < length/32',l+',0,a,Position(index),length,2139,Position(index),32'),
 ('AfterEndA',2139,23623,loop+[E(0),A,P,L,Q],base+' && index < length/32',l+',0,2152,NextPosition(index),Position(index),length,a'),
 ('AfterSliceA',2152,23662,loop+[E(0),OA,E(32)],base+' && index < length/32',l+',0,2161,32,WordOffset(a,index)'),
 ('AfterReadA',2161,23581,loop+[E(0),WA],base+' && index < length/32',l+',wordA,0,b,length,2177,index,32'),
 ('AfterPositionBStart',2177,23581,loop+[WA,E(0),B,L,P],base+' && index < length/32',l+',wordA,0,b,Position(index),length,2189,index,32'),
 ('AfterPositionBEnd',2189,23604,loop+[WA,E(0),B,P,L,P],base+' && index < length/32',l+',wordA,0,b,Position(index),length,2200,Position(index),32'),
 ('AfterEndB',2200,23623,loop+[WA,E(0),B,P,L,Q],base+' && index < length/32',l+',wordA,0,2213,NextPosition(index),Position(index),length,b'),
 ('AfterSliceB',2213,23662,loop+[WA,E(0),OB,E(32)],base+' && index < length/32',l+',wordA,0,2222,32,WordOffset(b,index)'),
 ('Tail',2222,2094,loop+[WA,E(0),WB],base+' && index < length/32',f+',index+1'),
 ('Exit',2094,518,frame+[E(3,'index')],base+' && index == length/32','269019481,128')]

 for name,entry,end,initial,pre,final in specs:
  s=initial.copy();pc=entry;memory="mem";states=[];required={};targets=set();seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while pc!=end:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'op':op,'next':nxt,'immediate':imm,'memory':memory})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(E(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [0x01,0x02,0x03]:
    a,b=pop(),pop();v=(a.v+b.v if op==1 else a.v*b.v if op==2 else a.v-b.v)%MOD;t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)*({b.t} as nat))%G.Modulus()' if op==2 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()';push(E(v) if a.constant() and b.constant() else E(v,t))
   elif op==0x19:a=pop();assert a.constant();push(E(MOD-1-a.v))
   elif op==0x52:
    offset_,word_=pop(),pop();assert word_.t in {'wordA','wordB'};memory='Store('+memory+',Target'+('A' if word_.t=='wordA' else 'B')+'(index),'+word_.t+')'
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
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],{n["memory"]})" for n in states)+'\n    else false'
  params='a: Word, b: Word, length: Word, index: Word, wordA: Word, wordB: Word';actual='a,b,length,index,wordA,wordB'
  text=f'''// SPDX-License-Identifier: MIT
// Generated pinned zipWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
module BytecodeZipSegment{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  function Position(index: Word): Word {{ ((index as nat)*32)%G.Modulus() }}
  function NextPosition(index: Word): Word {{ ((index as nat)*32+32)%G.Modulus() }}
  function WordOffset(offset: Word, index: Word): Word {{ ((offset as nat)+(index as nat)*32)%G.Modulus() }}
  function TargetA(index: Word): Word {{ (160+(index as nat)*64)%G.Modulus() }}
  function TargetB(index: Word): Word {{ (192+(index as nat)*64)%G.Modulus() }}
  predicate Admitted({params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}, mem: seq<Byte>) {{ Admitted({actual}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == Running({end},[{final}],{memory})' if i==len(states)-1 else f'Good({i+1},next,{actual},mem)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   assert n['op']!=0x19
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && Good({i},state,{actual},mem)
    ensures state.Running? && |state.stack| <= 24 && Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},[{','.join(n['stack'])}],{n['memory']});
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  first=','.join(x.t for x in initial);calls='\n'.join(f'    Advance{i}(code,state,{actual},mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running({entry},[{first}],mem);\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start({params}, mem: seq<Byte>)
    requires Admitted({actual})
    ensures Good(0,Running({entry},[{first}],mem),{actual},mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual})
    ensures state == Running({end},[{final}],{memory})
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
