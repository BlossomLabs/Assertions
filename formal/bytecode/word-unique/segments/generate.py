#!/usr/bin/env python3
"""Actual uniqueWords instruction segments separated at helper calls."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['uniqueWords(bytes,bool)']=='b58889b6'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 O=E(100,'offset');L=E(96,'length');B=E(1,'ordered');K=E(1,'kept');I=E(1,'index');J=E(0,'j');W=E(7,'word');V=E(7,'last');Z=E(0,'seen');P=E(32,'Position(index)');N=E(64,'NextPosition(index)');Q=E(132,'WordOffset(offset,index)')
 frame=[E(3045624246),E(518),O,L,B,E(128),K,I]
 f='3045624246,518,offset,length,ordered,128,kept,index'
 base='length < 0x10000000000000000 && (offset as nat)+(length as nat) < G.Modulus() && length%32 == 0 && ordered <= 1 && kept <= index <= length/32 && j <= kept && seen <= 1'
 body=base+' && index < length/32'
 specs=[
 ('Start',6724,23562,frame,base,f+',6735,32,length'),
 ('ReadPrepare',6735,23581,frame+[E(3,'length/32')],body,f+',0,offset,length,6756,index,32'),
 ('AfterPosition',6756,23581,frame+[E(0),O,L,P],body,f+',0,offset,Position(index),length,6768,index,32'),
 ('AfterOtherPosition',6768,23604,frame+[E(0),O,P,L,P],body,f+',0,offset,Position(index),length,6779,Position(index),32'),
 ('AfterEnd',6779,23623,frame+[E(0),O,P,L,N],body,f+',0,6792,NextPosition(index),Position(index),length,offset'),
 ('AfterSlice',6792,23662,frame+[E(0),Q,E(32)],body,f+',0,6801,32,WordOffset(offset,index)'),
 ('OrderedPrepare',6801,23784,frame+[E(0),W],body+' && ordered == 1 && kept > 0',f+',word,0,word,6836,128,3833,1,kept'),
 ('OrderedEmpty',6801,6890,frame[:-2]+[E(0,'kept'),I,E(0),W],body+' && ordered == 1 && kept == 0',f+',word,0'),
 ('OrderedEqual',6836,6890,frame+[W,E(0),W,V],body+' && ordered == 1 && kept > 0 && last == word',f+',word,1'),
 ('OrderedDifferent',6836,6890,frame+[W,E(0),W,E(11,'last')],body+' && ordered == 1 && kept > 0 && last != word',f+',word,0'),
 ('UnorderedStart',6801,6847,frame[:4]+[E(0,'ordered')]+frame[5:]+[E(0),W],body+' && ordered == 0',f+',word,0,0'),
 ('UnorderedRead',6847,6865,frame[:4]+[E(0,'ordered')]+frame[5:]+[W,E(0),J],body+' && ordered == 0 && j < kept',f+',word,0,j,last'),
 ('UnorderedHit',6865,6890,frame[:4]+[E(0,'ordered')]+frame[5:]+[W,E(0),J,V],body+' && ordered == 0 && j < kept && last == word',f+',word,1'),
 ('UnorderedMiss',6865,6847,frame[:4]+[E(0,'ordered')]+frame[5:]+[W,E(0),J,E(11,'last')],body+' && ordered == 0 && j < kept && last != word',f+',word,0,j+1'),
 ('UnorderedDone',6847,6890,frame[:4]+[E(0,'ordered')]+frame[5:]+[W,E(0),E(1,'j')],body+' && ordered == 0 && j == kept',f+',word,0'),
 ('StorePrepare',6890,23760,frame+[W,E(0,'seen')],body+' && seen == 0',f+',word,seen,6925,128,kept,6909,kept'),
 ('StoreTail',6909,6724,frame+[W,E(0,'seen'),E(6925),E(128),K,E(2,'kept+1')],body+' && seen == 0','3045624246,518,offset,length,ordered,128,kept+1,index+1'),
 ('Skip',6890,6724,frame+[W,E(1,'seen')],body+' && seen == 1','3045624246,518,offset,length,ordered,128,kept,index+1'),
 ('Exit',6735,518,frame[:-1]+[E(3,'index'),E(3,'length/32')],base+' && index == length/32','3045624246,128')]


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
    offset_,word_=pop(),pop();memory='Store(mem,Target(kept),word)' if name=='StoreTail' else 'Store(mem,128,kept*32)'
   elif op==0x51:address=pop();assert name=='UnorderedRead';push(E(7,'last'))
   elif op in [0x10,0x14]:a,b=pop(),pop();push(E(int(a.v<b.v if op==0x10 else a.v==b.v)))
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
  params='offset: Word, length: Word, ordered: Word, kept: Word, index: Word, j: Word, word: Word, last: Word, seen: Word';actual='offset,length,ordered,kept,index,j,word,last,seen'
  text=f'''// SPDX-License-Identifier: MIT
// Generated pinned uniqueWords loop instructions between actual helper boundaries.
include "../../scans/Execution.dfy"
include "Scalar.dfy"
module BytecodeUniqueSegment{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  import SC = BytecodeUniqueLoopScalar
  function Position(index: Word): Word {{ ((index as nat)*32)%G.Modulus() }}
  function NextPosition(index: Word): Word {{ ((index as nat)*32+32)%G.Modulus() }}
  function WordOffset(offset: Word, index: Word): Word {{ ((offset as nat)+(index as nat)*32)%G.Modulus() }}
  function Target(kept: Word): Word {{ (160+(kept as nat)*32)%G.Modulus() }}
  predicate MemoryAdmitted(mem: seq<Byte>, j: Word, last: Word) {{ {'160+j*32+32 <= |mem| < G.Modulus() && Round32(|mem|) == |mem| && Load(mem,160+j*32) == last' if name=='UnorderedRead' else 'true'} }}
  predicate Admitted({params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, {params}, mem: seq<Byte>) {{ Admitted({actual}) && MemoryAdmitted(mem,j,last) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == Running({end},[{final}],{memory})' if i==len(states)-1 else f'Good({i+1},next,{actual},mem)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   if n['op']==0x51:fetch+='    SC.NoExpand(mem,j);\n'
   if name=='UnorderedMiss' and n['pc']==6871:fetch+='    SC.Different(last,word);\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted({actual}) && MemoryAdmitted(mem,j,last) && Good({i},state,{actual},mem)
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
    requires Admitted({actual}) && MemoryAdmitted(mem,j,last)
    ensures Good(0,Running({entry},[{first}],mem),{actual},mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted({actual}) && MemoryAdmitted(mem,j,last)
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
