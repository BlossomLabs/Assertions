#!/usr/bin/env python3
"""Exact bytes decoder empty rejections; five exhaustive fitting-size classes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;U64=1<<64
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['reverseWords(bytes)']=='ab590638'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 cases=[
 ('HeadShort',8,32,0,'|data| < 36'),
 ('OffsetLarge',100,U64,0,'36 <= |data| && Head(data) >= 0x10000000000000000'),
 ('HeaderShort',40,32,0,'36 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 > |data|'),
 ('LengthLarge',100,32,U64,'36 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 <= |data| && Length(data) >= 0x10000000000000000'),
 ('TailShort',100,32,64,'36 <= |data| && Head(data) < 0x10000000000000000 && (Head(data) as nat)+36 <= |data| && Length(data) < 0x10000000000000000 && (Head(data) as nat)+36+(Length(data) as nat) > |data|')]
 for name,size,head,length,pre in cases:
  pc=846;s=[E(2874738232)];states=[];required={};targets=set();seen=set()
  while True:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:s.append(E(imm))
   elif op==0x36:s.append(E(size,'|data|'))
   elif 0x80<=op<=0x8f:s.append(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:s.pop()
   elif op in [1,3]:
    a,b=s.pop(),s.pop();v=(a.v+b.v)%MOD if op==1 else (a.v-b.v)%MOD
    if a.constant() and b.constant():s.append(E(v))
    elif op==1 and {a.t,b.t}=={'4','Head(data)'}:s.append(E(v,'HeadPosition(data)'))
    elif op==1 and {a.t,b.t}=={'32','HeadPosition(data)'}:s.append(E(v,'Offset(data)'))
    else:s.append(E(v,f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'))
   elif op==0x1b:amount,a=s.pop(),s.pop();assert amount.constant() and a.constant();s.append(E((a.v<<amount.v)%MOD))
   elif op==0x15:s.append(E(int(s.pop().v==0)))
   elif op in [0x11,0x12]:
    a,b=s.pop(),s.pop();signed=lambda x:x if x<MOD//2 else x-MOD;truth=a.v>b.v if op==0x11 else signed(a.v)<signed(b.v);s.append(E(int(truth)))
   elif op==0x35:
    a=s.pop()
    if a.v==4:s.append(E(head,'Head(data)'))
    elif a.v==4+head:s.append(E(length,'Length(data)'))
    else:raise ValueError((name,'unexpected load',pc,a.v,a.t))
   elif op==0x57:
    dest,truth=s.pop(),s.pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=s.pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   elif op==0xfd:assert s.pop().v==0 and s.pop().v==0;break
   else:raise ValueError((name,pc,op))
   pc=nxt
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()));cap=max(len(n['stack']) for n in states)
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},[{','.join(n['stack'])}],mem)" for n in states)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual raw bytes decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
module BytecodeReverseRaw{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function Head(data: seq<Byte>): Word {{ DataWord(data,4) }}
  function HeadPosition(data: seq<Byte>): Word {{ ((Head(data) as nat)+4)%G.Modulus() }}
  function Length(data: seq<Byte>): Word {{ DataWord(data,HeadPosition(data)) }}
  function Offset(data: seq<Byte>): Word {{ ((Head(data) as nat)+36)%G.Modulus() }}
  predicate Admitted(data: seq<Byte>) {{ 4 <= |data| < 0x10000000000000000 && {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, data: seq<Byte>, mem: seq<Byte>) {{ Admitted(data) && (
{good}) }}
'''
  for n in states:
   i=n['id'];post='next == Reverted([])' if i==len(states)-1 else f'Good({i+1},next,data,mem)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   if n['op']==0x1b:fetch+='    DS.DecoderLimit();\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, data: seq<Byte>, mem: seq<Byte>, value: Word)
    requires Matches(code) && Admitted(data) && Good({i},state,data,mem)
    ensures state.Running? && |state.stack| <= {cap} && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},[{','.join(n['stack'])}],mem);
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  calls='\n'.join(f'    Advance{i}(code,state,data,mem,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running(846,[2874738232],mem);\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(846,[2874738232],mem),data,mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(846,[2874738232],mem) && trace[|trace|-1] == state
  {{
    Start(data,mem);
    state := Running(846,[2874738232],mem);
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/('Raw'+name+'.generated.dfy')).write_text(text);(out/('Raw'+name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'scope':'development raw bytes decoder class only, not completed public evidence'},indent=2)+'\n');print(name,len(states),'exact empty rejection states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE.parent/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
