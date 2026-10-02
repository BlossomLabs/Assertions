#!/usr/bin/env python3
"""Exact primitive orchestration segments ending only at actual helper boundaries."""
import argparse,hashlib,json,subprocess,sys,os
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256
class X:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out, runtime=None):
 code=runtime.read_bytes() if runtime is not None else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert runtime is not None or digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Assertions']['runtimeSha256']
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 dests={pc for pc,(op,_,_) in ins.items() if op==91}
 params='ret: Word, c: Word, then_: Word, else_: Word, ptr: Word, length: Word, word: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>';args='ret,c,then_,else_,ptr,length,word,free,prefix,mem'
 base='|mem|%32 == 0 && 96 <= |mem| < G.Modulus() && Load(mem,64) == free && 128 <= free && free+64 < G.Modulus() && |prefix| <= 980'
 cases=[('CondStart',1743,3393,['ret','c','then_','else_'],1,''),('CondFirstWord',1770,3975,['ret','c','then_','else_','0','ptr'],1,''),('CondFalse',1783,3393,['ret','c','then_','else_','ptr','0','0','word'],0,'word == 0'),('CondTrue',1783,3393,['ret','c','then_','else_','ptr','0','0','word'],1,'word != 0'),('CondFalseReturn',1815,1017,['ret','c','then_','else_','ptr','0','then_'],1,''),('ResolveStart',1027,3393,['ret','c'],1,''),('PickStart',3131,3393,['ret','c','word'],1,''),('PickWord',3159,7405,['ret','c','word','0','0','ptr'],1,''),('PickExit',3171,None,['ret','c','word','0','ptr','then_'],1,'ret in RuntimeDestinations() && ret < |code| && code[ret] == 0x5b'),('RawReturn',1017,None,['c','ptr'],1,'ptr+32+length <= |mem| && Load(mem,ptr) == length')]
 for name,wv,final in [('GatherFill',2,2435),('GatherFillLast',1,2454)]:
  cases.append((name,2435,final,['ret','c','length','96','free','word','ptr'],wv,'1 <= word <= length && length <= 0xffffffffffffffff && free+32+length*32 < G.Modulus() && ptr == free+32+(length-word)*32'+(' && word > 1' if wv==2 else ' && word == 1')))
 cases += [
 ('ReadStart',1538,3393,['ret','c','word','then_','length'],1,''),
 ('ChainEmpty',2638,None,['ret','c','then_','length'],0,'length == 0'),
 ('ChainStart',2638,3393,['ret','c','then_','length'],1,'length > 0'),
 ('FirstWordRelay',753,3975,['ret','ptr'],1,''),
 ('AddressRelay',758,4031,['ret','word'],1,''),
 ('GatherStart',2379,2435,['ret','c','length'],1,'0 < length <= 0xffffffffffffffff && free+32+length*32 < G.Modulus() && Round32(free+32+length*32) < G.Modulus()'),
 ('GatherStartZero',2379,2461,['ret','c','length'],1,'length == 0'),
 ('GatherHeaderExit',2454,2461,['ret','c','length','96','free','0','ptr'],1,''),
 ('GatherDoneExit',2461,None,['ret','c','length','free','word'],64,'word == length && ret in RuntimeDestinations() && ret < |code| && code[ret] == 0x5b'),
 ('GatherNext',2461,17803,['ret','c','length','free','word'],1,'word < length && c+length*32 < G.Modulus()'),
 ('GatherParam',2508,3393,['ret','c','length','ptr','word','2530','then_'],1,''),
 ('GatherValueStore',2530,2461,['ret','c','length','free','word','ptr'],1,'word < length && free+32+length*32 <= |mem| && Load(mem,free) == length'),
 ('ChainAfterAddress',2704,17922,['ret','c','then_','length','0','word'],1,'length > 0'),
 ('ChainAfterLast',2718,2722,['ret','c','then_','length','else_','0','ptr'],1,''),
 ('OrElseRouteSuccess',3064,3078,['ret','c','then_','else_','word','ptr'],1,'word != 0'),
 ('OrElseRouteFailure',3064,6721,['ret','c','then_','else_','word','ptr'],0,'word == 0'),
 ('OrElseFallback',1820,3393,['ret','c','then_','else_','word','ptr'],0,'word == 0'),
 ('OrElseReturn',3078,None,['ret','c','then_','else_','word','ptr'],1,'word != 0 && ptr+32+length <= |mem| && Load(mem,ptr) == length'),
 ('IsValidRouteSuccess',3353,3367,['ret','c','0','then_','word','ptr'],1,'word != 0'),
 ('IsValidRouteFailure',3353,6721,['ret','c','0','then_','word','ptr'],0,'word == 0'),
 ('IsValidFinishTrue',3367,None,['ret','c','0','then_','word','ptr'],1,'word != 0 && ret in RuntimeDestinations() && ret < |code| && code[ret] == 0x5b'),
 ('IsValidFinishFalse',3367,None,['ret','c','0','then_','word','ptr'],0,'word == 0 && ret in RuntimeDestinations() && ret < |code| && code[ret] == 0x5b'),
 ('GatherTooLarge',2379,None,['ret','c','length'],1,'length > 0xffffffffffffffff'),
 ]
 for name,entry,end,initial,wv,guard in cases:
  env={'ret':X(600,'ret'),'c':X(100,'c'),'then_':X(200,'then_'),'else_':X(300,'else_'),'ptr':X(128,'ptr'),'length':X(64,'length'),'word':X(wv,'word'),'free':X(1024,'free'),'0':X(0),'96':X(96),'2530':X(2530)}
  if name in ['GatherStartZero','ChainEmpty']:env['length']=X(0,'length')
  if name=='GatherTooLarge':env['length']=X(1<<64,'length')
  s=[env[x] for x in initial];pc=entry;memory='mem';states=[];required={};targets=set();mems=[];seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  def binary(a,b,op):
   v=(a.v+b.v if op==1 else a.v*b.v if op==2 else a.v+MOD-b.v)%MOD
   if a.constant() and b.constant():return X(v)
   t=f'(({a.t} as nat){"+" if op==1 else "*"}({b.t} as nat))%G.Modulus()' if op in [1,2] else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()';return X(v,t)
  while pc!=end or not states:
   key=(pc,tuple(x.t for x in s));assert key not in seen;seen.add(key);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   n={'id':len(states),'pc':pc,'stack':[x.t for x in s],'memory':memory,'op':op,'next':nxt,'immediate':imm};states.append(n)
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(X(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [1,2,3]:a,b=pop(),pop();push(binary(a,b,op))
   elif op in [0x10,0x11,0x14]:
    a,b=pop(),pop();v=a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else a.v==b.v;t=a.t+(' < ' if op==0x10 else ' > ' if op==0x11 else ' == ')+b.t;push(X(int(v),f'(if {t} then 1 else 0)'))
   elif op==0x15:
    a=pop();push(X(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
   elif op==0x16:
    a,b=pop(),pop();assert a.constant() and b.constant();push(X(a.v&b.v))
   elif op==0x1b:
    a,b=pop(),pop();assert a.constant() and b.constant();push(X((b.v<<a.v)%MOD))
   elif op==0x51:
    off=pop();result=env['free'] if off.v==64 else env['length'] if off.t in ['ptr','free'] else None;assert result is not None,(name,pc,off.t)
    n['loadOffset']=off.t;push(result)
   elif op==0x52:
    off,val=pop(),pop();before=memory;memory='Memory'+str(len(mems)+1)+'('+args+')';mems.append((memory,f'Store({before},{off.t},{val.t})',off.t,val.t));n['storePost']=memory
   elif op==0x57:
    dest,truth=pop(),pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=pop()
    if dest.t=='ret':end='ret';break
    assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   elif op in [0xf3,0xfd]:
    off,size=pop(),pop();terminal=f'{"Returned" if op==0xf3 else "Reverted"}(G.Grow({memory},({off.t} as nat)+({size.t} as nat))[{off.t}..({off.t} as nat)+({size.t} as nat)])';break
   else:raise ValueError((name,pc,op))
   pc=nxt
  if op not in [0xf3,0xfd]:terminal=f'Running({end},prefix+[{",".join(x.t for x in s)}],{memory})'
  matched=' &&\n    '.join(f'code[{p}] == {b}' for p,b in sorted(required.items()));good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false';local_base=base.replace(' && Load(mem,64) == free','') if name.startswith('GatherFill') or name in ['GatherHeaderExit','GatherDoneExit','GatherNext','GatherValueStore'] else base;pre=local_base+(' && '+guard if guard else '')
  text=f'''// SPDX-License-Identifier: MIT
// Exact bytecode segment; endpoint helpers require separate native composition.
include "../scans/Execution.dfy"
include "../scans/Push.dfy"
include "../assertions-primitives/Scalar.dfy"
module AssertionsControl{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import R = BytecodeScanRepresentation
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import Q = AssertionsPrimitiveScalar
  function RuntimeDestinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  predicate Admitted(code: seq<Byte>, {params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matched} }}
  function Destinations(ret: Word): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}}+{{ret}} }}
'''
  for call,body,off,val in mems:text+=f'  function {call.split("(")[0]}({params}): seq<Byte> {{ {body} }}\n'
  text+=f'''  opaque predicate Good(id: nat, state: State, code: seq<Byte>, {params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == {terminal}' if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else f'    P.Push4(code,{n["pc"]});\n' if n['op']==99 else '';proof=''
   if n['op']==0x51:
    if n['memory']!='mem':
     for call,body,off,val in mems:
      if int(call.split('(')[0][6:])<=int(n['memory'].split('(')[0][6:]):
       before=body[len('Store('):].rsplit(',',2)[0]
       proof+=f'    R.StoredWord({before},{off},{val});\n    R.StoredFrame({before},{off},{val},64);\n'
    proof+=f'    Q.ExpansionIdentity({n["memory"]},({n["loadOffset"]} as nat)+32);\n'
   if n['op']==0x1b:proof+='    reveal ShiftLeft();\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,code,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000
    ensures Step(code,Destinations(ret),state,value,data) != Bad
    ensures var next := Step(code,Destinations(ret),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{fetch}    assert state == Running({n['pc']},prefix+[{','.join(n['stack'])}],{n['memory']});
    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
{proof}  }}
'''
  if len(states)>25:
   branches='\n'.join('    '+('if' if i==0 else 'else if')+f' id == {i} {{ Advance{i}(code,state,{args},value,data); }}' for i in range(len(states)))
   text+=f'''  lemma Advance(id: nat, code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && id < {len(states)} && Good(id,state,code,{args})
    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000 && Step(code,Destinations(ret),state,value,data) != Bad
    ensures id < {len(states)-1} ==> Good(id+1,Step(code,Destinations(ret),state,value,data),code,{args})
    ensures id == {len(states)-1} ==> Step(code,Destinations(ret),state,value,data) == {terminal}
  {{
{branches}
  }}
  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {terminal}
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},prefix+[{','.join(initial)}],mem) && trace[|trace|-1] == state
  {{
    reveal Good();
    state := Running({entry},prefix+[{','.join(initial)}],mem);
    trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
      invariant trace[0] == Running({entry},prefix+[{','.join(initial)}],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,code,{args})
      invariant id == {len(states)} ==> state == {terminal}
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{args},value,data);
      var next := Step(code,Destinations(ret),state,value,data);
      E.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];
      state := next;
      id := id+1;
    }}
  }}
}}
'''
  else:
   calls='\n'.join(f'    Advance{i}(code,state,{args},value,data);\n    var next{i} := Step(code,Destinations(ret),state,value,data);\n    E.Extend(code,Destinations(ret),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running({entry},prefix+[{",".join(initial)}],mem);\n    state := next{i};' for i in range(len(states)))
   text+=f'''  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
     requires Matches(code) && Admitted(code,{args})
     ensures state == {terminal}
     ensures E.Trace(code,Destinations(ret),value,data,trace)
     ensures forall j {{:trigger trace[j]}} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000
     ensures |trace| == {len(states)+1} && trace[0] == Running({entry},prefix+[{','.join(initial)}],mem) && trace[|trace|-1] == state
   {{
     reveal Good();
     state := Running({entry},prefix+[{','.join(initial)}],mem);
     trace := [state];
 {calls}
   }}
 }}
 '''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'runtimeDestinations':sorted(dests),'finalState':terminal,'scope':'Exact helper-bounded segment; no assumed resolver correctness and no public-entry completion.'},indent=2)+'\n');print(name,len(states),'states',terminal,flush=True)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=HERE);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime);subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/unknown/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
