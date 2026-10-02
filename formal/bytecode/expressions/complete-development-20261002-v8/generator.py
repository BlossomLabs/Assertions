#!/usr/bin/env python3
"""Extract exact reached Expressions helper instructions; Dafny checks every step.
Path witnesses choose finite branches only. Independent input guards are stated
in each certificate and branch consistency is a native proof obligation.
"""
import argparse, hashlib, json, os, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256
class X:
 def __init__(self,v,t=None,aff=None):
  self.v=v;self.t=str(v) if t is None else t;self.aff=aff if aff is not None else ((t,0) if t in ['ptr','free','length','word','index','ret'] else None)
 def constant(self):return self.t.isdecimal()
def generate(out, runtime=None):
 code=runtime.read_bytes() if runtime is not None else bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Expressions.sol/Expressions.json').read_text())['deployedBytecode'][2:])
 digest=hashlib.sha256(code).hexdigest()
 if runtime is None:assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Expressions']['runtimeSha256']
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 params='ptr: Word, length: Word, word: Word, index: Word, free: Word, ret: Word, prefix: seq<Word>, mem: seq<Byte>'
 actual='ptr,length,word,index,free,ret,prefix,mem'
 base='128 <= ptr && (ptr as nat)+32+(length as nat) <= free && (free as nat)+416 < G.Modulus() && |mem|%32 == 0 && 96 <= |mem| < G.Modulus() && (ptr as nat)+32+(length as nat) <= |mem| && Load(mem,ptr) == length && Load(mem,64) == free && 128 <= free && (free as nat)+96 < G.Modulus() && ret in RuntimeDestinations() && ret < |code| && code[ret] == 0x5b && |prefix| <= 980'
 cases=[('Address',5440,['ret','ptr','index'],32,7,3,'length == 32 && word < 0x10000000000000000000000000000000000000000 && Load(mem,ptr+32) == word'),('AddressDirty',5440,['ret','ptr','index'],32,1<<160,3,'length == 32 && 0x10000000000000000000000000000000000000000 <= word && Load(mem,ptr+32) == word')]
 for name,entry,initial,lv,wv,iv,extra in cases:
  env={'ptr':X(128,'ptr'),'length':X(lv,'length'),'word':X(wv,'word'),'index':X(iv,'index'),'free':X(1024,'free'),'ret':X(600,'ret')}
  memory_values={128:(env['length'],0),160:(env['word'],0),64:(env['free'],0)};s=[env[x] for x in initial];pc=entry;memory='mem';states=[];required={};targets=set();seen=set();mems=[]
  def pop():return s.pop()
  def push(x):s.append(x)
  def expr(a,b,op):
   val={'+':lambda:(a.v+b.v)%MOD,'-':lambda:(a.v+MOD-b.v)%MOD,'*':lambda:(a.v*b.v)%MOD}[op]()
   if a.constant() and b.constant():return X(val)
   t=f'(({a.t} as nat){op}({b.t} as nat))%G.Modulus()' if op!='-' else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
   if a.aff and b.constant():
    var,k=a.aff;offset=(k+b.v if op=='+' else k-b.v)%MOD if op in ['+','-'] else None
    if offset is not None:return X(val,f'(({var} as nat)+{offset})%G.Modulus()',(var,offset))
   if b.aff and a.constant() and op=='+':
    var,k=b.aff;offset=(k+a.v)%MOD;return X(val,f'(({var} as nat)+{offset})%G.Modulus()', (var,offset))
   if a.aff and b.aff and a.aff[0]==b.aff[0] and op=='-':return X(val)
   return X(val,t)
  while True:
   key=(pc,tuple(x.t for x in s));assert key not in seen,(name,pc);seen.add(key);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'memory':memory,'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(X(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [1,2,3]:a,b=pop(),pop();push(expr(a,b,{1:'+',2:'*',3:'-'}[op]))
   elif op==0x04:
    a,b=pop(),pop();assert b.v!=0;push(X(a.v//b.v,f'(({a.t} as nat)/({b.t} as nat))'))
   elif op==0x1c:a,b=pop(),pop();push(X(b.v>>a.v,f'ShiftRight({b.t},{a.t})'))
   elif op==0x1b:
    a,b=pop(),pop();assert a.constant() and b.constant();push(X((b.v<<a.v)%MOD))
   elif op==0x14:
    a,b=pop(),pop();push(X(int(a.v==b.v),f'(if {a.t} == {b.t} then 1 else 0)'))
   elif op in [0x10,0x11,0x12]:
    a,b=pop(),pop()
    if op==0x12:
     sa=a.v if a.v<MOD//2 else a.v-MOD;sb=b.v if b.v<MOD//2 else b.v-MOD;v=sa<sb;t=f'G.Signed({a.t}) < G.Signed({b.t})'
    else:v=a.v<b.v if op==0x10 else a.v>b.v;t=a.t+(' < ' if op==0x10 else ' > ')+b.t
    push(X(int(v),f'(if {t} then 1 else 0)'))
   elif op==0x16:
    a,b=pop(),pop();push(X(a.v&b.v,str(a.v&b.v) if a.constant() and b.constant() else f'(({a.t} as bv256)&({b.t} as bv256)) as nat'))
   elif op==0x15:
    a=pop();push(X(int(a.v==0),f'(if {a.t} == 0 then 1 else 0)'))
   elif op==0x51:
    a=pop()
    if a.v in memory_values:v,load_source=memory_values[a.v]
    else:raise ValueError((name,pc,a.t))
    states[-1]['loadSource']=load_source;states[-1]['loadOffset']=a.t;states[-1]['loadResult']=v.t;push(v)
    # Rounded admitted reads do not change memory.
   elif op==0x52:
    off,val=pop(),pop();memory_values[off.v]=(val,len(mems)+1);before=memory;memory='Memory'+str(len(mems)+1)+'('+actual+')';mems.append((memory,f'Store({before},{off.t},{val.t})',off.t,val.t));states[-1]['storePost']=memory
   elif op==0x57:
    dest,truth=pop(),pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    states[-1]['condition']=truth.t;states[-1]['branch']=bool(truth.v)
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=pop()
    if dest.t=='ret':break
    assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   elif op==0xfd:
    off,size=pop(),pop();terminal=f'Reverted(G.Grow({memory},({off.t} as nat)+({size.t} as nat))[{off.t}..({off.t} as nat)+({size.t} as nat)])';break
   else:raise ValueError((name,pc,op))
   pc=nxt
  if op==0x56:terminal=f'Running(ret,prefix+[{",".join(x.t for x in s)}],{memory})'
  local_base=base
  if name.startswith('AsAddress'):
   local_base=base.replace(' && (ptr as nat)+32+(length as nat) <= |mem| && Load(mem,ptr) == length','')
  pre=local_base+' && '+extra
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f' id == {n["id"]} then state == Running({n["pc"]},prefix+[{",".join(n["stack"])}],{n["memory"]})' for n in states)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Exact runtime helper path; every reached instruction is natively checked.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "../AddressFacts.dfy"
include "FrameFacts.dfy"
module ExpressionsPrimitive{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import E = BytecodeScanExecution
  import Q = ExpressionsAddressFacts
  import A = ExpressionsAddressFacts
  import C = ExpressionsAddressCompleteFrameFacts
  function RuntimeDestinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  predicate Admitted(code: seq<Byte>, {params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(ret: Word): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}}+{{ret}} }}
'''
  for call,body,off,val in mems:
   text+=f'  opaque function {call.split("(")[0]}({params}): seq<Byte> {{ {body} }}\n'
   text+=f'  lemma {call.split("(")[0]}Definition({params})\n    ensures {call} == {body}\n  {{ reveal {call.split("(")[0]}(); }}\n'
   member=call.split('(')[0];previous=body[len('Store('):].rsplit(',',2)[0]
   text+=f'''  lemma {member}StoreFacts({params})
    requires |{previous}|%32 == 0
    ensures |{call}|%32 == 0 && |{call}| >= |{previous}| && |{call}| >= ({off} as nat)+32
    ensures Load({call},{off}) == {val}
  {{
    {member}Definition({actual});
    C.StoreProgress({previous},{off},{val});
  }}
  lemma {member}Frame({params}, other: Word, observed: Word)
    requires (other as nat)+32 <= |{previous}|
    requires (other as nat)+32 <= {off} || ({off} as nat)+32 <= other
    requires Load({previous},other) == observed
    ensures Load({call},other) == observed
  {{
    {member}Definition({actual});
    R.StoredFrame({previous},{off},{val},other);
  }}
'''
  text+=f'''  opaque predicate Good(id: nat, state: State, code: seq<Byte>, {params}) {{ Admitted(code,{actual}) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post=f'next == {terminal}' if i==len(states)-1 else f'Good({i+1},next,code,{actual})'
   fetch=f'    F.Push{n["op"]-95}(code,{n["pc"]});\n' if n['op'] in [96,97] else f'    P.Push4(code,{n["pc"]});\n' if n['op']==99 else ''
   extra_proof='    Q.IndexFacts(length,index);\n    Q.OffsetFacts(ptr,length,index,mem);\n' if name in ['RawWordPositive','RawWordNegative'] else ''
   if n['op']==0x51:
    upto=int(n['memory'].split('(')[0][6:]) if n['memory']!='mem' else 0
    for number,(call,body,off,val) in enumerate(mems[:upto],1):
     before=body[len('Store('):].rsplit(',',2)[0]
     extra_proof+=f'    Memory{number}StoreFacts({actual});\n'
     if number>n['loadSource']:
      extra_proof+=f'    Memory{number}Frame({actual},{n["loadOffset"]},{n["loadResult"]});\n'
    if upto > 6:
     # Keep each caller's solver context bounded to one physical store.
     for depth in range(upto+1):
      image='mem' if depth==0 else f'Memory{depth}({actual})'
      summary=f'    ensures Load({image},{n["loadOffset"]}) == {n["loadResult"]}\n' if depth>=n['loadSource'] else ''
      step='' if depth==0 else f'    Read{i}Through{depth-1}(code,{actual});\n    Memory{depth}StoreFacts({actual});\n'
      if depth>n['loadSource']:step+=f'    Memory{depth}Frame({actual},{n["loadOffset"]},{n["loadResult"]});\n'
      text+=f'''  lemma Read{i}Through{depth}(code: seq<Byte>, {params})
    requires Admitted(code,{actual})
    ensures |{image}|%32 == 0 && |{image}| >= |mem|
{summary}  {{
{step}  }}
'''
     extra_proof=f'    Read{i}Through{upto}(code,{actual});\n'
    extra_proof+=f'    Q.ExpansionIdentity({n["memory"]},({n["loadOffset"]} as nat)+32);\n'
   if n['op']==0x51:
    text+=f'''  lemma Read{i}(code: seq<Byte>, {params})
    requires Admitted(code,{actual})
    ensures Load({n["memory"]},{n["loadOffset"]}) == {n["loadResult"]}
    ensures Expand({n["memory"]},({n["loadOffset"]} as nat)+32) == {n["memory"]}
  {{
{extra_proof}  }}
'''
    extra_proof=f'    Read{i}(code,{actual});\n'
   if n['op']==0x52:
    extra_proof+=f'    {n["storePost"].split("(")[0]}Definition({actual});\n'
   if name.startswith('AsAddress') and n['op']==0x57:extra_proof+='    Q.AddressShift(word);\n'
   if n['op']==0x1b:extra_proof+='    A.Shifts();\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,code,{actual})
    ensures state.Running? && |state.stack| <= 1024
    ensures Step(code,Destinations(ret),state,value,data) != Bad
    ensures var next := Step(code,Destinations(ret),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
{fetch}    assert state == Running({n['pc']},prefix+[{','.join(n['stack'])}],{n['memory']});
    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
{extra_proof}  }}
'''
  branches='\n'.join('    '+('if' if i==0 else 'else if')+f' id == {i} {{ Advance{i}(code,state,{actual},value,data); }}' for i in range(len(states)))
  text+=f'''  lemma Advance(id: nat, code: seq<Byte>, state: State, {params}, value: Word, data: seq<Byte>)
    requires Matches(code) && id < {len(states)} && Good(id,state,code,{actual})
    ensures state.Running? && Step(code,Destinations(ret),state,value,data) != Bad
    ensures id < {len(states)-1} ==> Good(id+1,Step(code,Destinations(ret),state,value,data),code,{actual})
    ensures id == {len(states)-1} ==> Step(code,Destinations(ret),state,value,data) == {terminal}
  {{
    reveal Good();
{branches}
  }}
'''
  text+=f'''  ghost method Run(code: seq<Byte>, {params}, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(code,{actual})
    ensures state == {terminal}
    ensures E.Trace(code,Destinations(ret),value,data,trace)
    ensures trace[0] == Running({entry},prefix+[{','.join(initial)}],mem) && trace[|trace|-1] == state
    ensures |trace| == {len(states)+1}
  {{
    reveal Good();
    state := Running({entry},prefix+[{','.join(initial)}],mem);
    trace := [state];
    var id: nat := 0;
    while id < {len(states)}
      invariant id <= {len(states)} && |trace| == id+1
      invariant E.Trace(code,Destinations(ret),value,data,trace)
      invariant trace[0] == Running({entry},prefix+[{','.join(initial)}],mem) && trace[|trace|-1] == state
      invariant id < {len(states)} ==> Good(id,state,code,{actual})
      invariant id == {len(states)} ==> state == {terminal}
      decreases {len(states)}-id
    {{
      Advance(id,code,state,{actual},value,data);
      var next := Step(code,Destinations(ret),state,value,data);
      E.Extend(code,Destinations(ret),value,data,trace,next);
      trace := trace+[next];
      state := next;
      id := id+1;
    }}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'entry':entry,'states':states,'requiredBytes':required,'destinations':sorted(targets),'runtimeDestinations':sorted(dests),'expectedFinalState':terminal,'scope':'Exact helper path only. Public dispatcher/decoder/resolver composition remains open.'},indent=2)+'\n');print(name,len(states),'instruction states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=HERE);p.add_argument('--runtime',type=Path);a=p.parse_args();generate(a.output,a.runtime)
 subprocess.run([sys.executable,'-B',ROOT/'formal/bytecode/unknown/format-generated.py','--output',a.output,'--include-root',a.output.resolve()],check=True)
