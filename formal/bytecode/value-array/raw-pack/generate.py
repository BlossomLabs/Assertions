#!/usr/bin/env python3
"""Exact descriptor/bytes-array-head decoder empty rejections; nine fitting-size classes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;U64=1<<64
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['packArray(string,bytes[])']=='9c780aab'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 baseA='68 <= |data| && HeadA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36+(LengthA(data) as nat) <= |data|'
 cases=[
 ('HeadShort',8,32,0,64,0,'|data| < 68'),
 ('FirstOffsetLarge',100,U64,0,64,0,'68 <= |data| && HeadA(data) >= 0x10000000000000000'),
 ('FirstHeaderShort',68,64,0,64,0,'68 <= |data| && HeadA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36 > |data|'),
 ('FirstLengthLarge',132,64,U64,64,0,'68 <= |data| && HeadA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36 <= |data| && LengthA(data) >= 0x10000000000000000'),
 ('FirstTailShort',132,64,64,64,0,'68 <= |data| && HeadA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36 <= |data| && LengthA(data) < 0x10000000000000000 && (HeadA(data) as nat)+36+(LengthA(data) as nat) > |data|'),
 ('SecondOffsetLarge',100,64,0,U64,0,baseA+' && HeadB(data) >= 0x10000000000000000'),
 ('SecondHeaderShort',100,64,0,96,0,baseA+' && HeadB(data) < 0x10000000000000000 && (HeadB(data) as nat)+36 > |data|'),
 ('SecondLengthLarge',196,64,32,128,U64,baseA+' && HeadB(data) < 0x10000000000000000 && (HeadB(data) as nat)+36 <= |data| && LengthB(data) >= 0x10000000000000000'),
 ('SecondTailShort',196,64,32,128,64,baseA+' && HeadB(data) < 0x10000000000000000 && (HeadB(data) as nat)+36 <= |data| && LengthB(data) < 0x10000000000000000 && (HeadB(data) as nat)+36+32*(LengthB(data) as nat) > |data|')]

 for name,size,headA,lengthA,headB,lengthB,pre in cases:
  pc=827;s=[E(2625112747)];states=[];required={};targets=set();seen=set()
  while True:
   key=(pc,tuple(x.t for x in s));assert key not in seen;seen.add(key);assert len(states)<500;op,nxt,imm=ins[pc]
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
    elif op==1 and {a.t,b.t}=={'4','HeadA(data)'}:s.append(E(v,'HeadPositionA(data)'))
    elif op==1 and {a.t,b.t}=={'32','HeadPositionA(data)'}:s.append(E(v,'OffsetA(data)'))
    elif op==1 and {a.t,b.t}=={'4','HeadB(data)'}:s.append(E(v,'HeadPositionB(data)'))
    elif op==1 and {a.t,b.t}=={'32','HeadPositionB(data)'}:s.append(E(v,'OffsetB(data)'))
    else:s.append(E(v,f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()' if op==1 else f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'))
   elif op==0x1b:
    amount,a=s.pop(),s.pop();assert amount.constant()
    if amount.v==5 and a.t=='LengthB(data)':s.append(E((a.v<<amount.v)%MOD,'ArrayBytes(data)'))
    else:assert a.constant();s.append(E((a.v<<amount.v)%MOD))
   elif op==0x15:s.append(E(int(s.pop().v==0)))
   elif op in [0x10,0x11,0x12]:
    a,b=s.pop(),s.pop();signed=lambda x:x if x<MOD//2 else x-MOD;truth=a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else signed(a.v)<signed(b.v);s.append(E(int(truth)))
   elif op==0x35:
    a=s.pop()
    if a.t=='HeadPositionA(data)':s.append(E(lengthA,'LengthA(data)'))
    elif a.t=='HeadPositionB(data)':s.append(E(lengthB,'LengthB(data)'))
    elif a.v==4:s.append(E(headA,'HeadA(data)'))
    elif a.v==36:s.append(E(headB,'HeadB(data)'))
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
// Generated actual raw descriptor/bytes-array-head decoder empty-rejection path.
include "../../scans/Execution.dfy"
include "../../scans/DecoderScalar.dfy"
include "../../word-apply/array-stride/Stride.dfy"
module BytecodeCollectionsPackRaw{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import AS = BytecodeApplyArrayStride
  import DS = BytecodeScanDecoderScalar
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  function HeadA(data: seq<Byte>): Word {{ DataWord(data,4) }}
  function HeadB(data: seq<Byte>): Word {{ DataWord(data,36) }}
  function HeadPositionA(data: seq<Byte>): Word {{ ((HeadA(data) as nat)+4)%G.Modulus() }}
  function HeadPositionB(data: seq<Byte>): Word {{ ((HeadB(data) as nat)+4)%G.Modulus() }}
  function LengthA(data: seq<Byte>): Word {{ DataWord(data,HeadPositionA(data)) }}
  function LengthB(data: seq<Byte>): Word {{ DataWord(data,HeadPositionB(data)) }}
  function OffsetA(data: seq<Byte>): Word {{ ((HeadA(data) as nat)+36)%G.Modulus() }}
  function OffsetB(data: seq<Byte>): Word {{ ((HeadB(data) as nat)+36)%G.Modulus() }}
  function ArrayBytes(data: seq<Byte>): Word {{ ((LengthB(data) as nat)*32)%G.Modulus() }}
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
   if n['op']==0x1b:
    if n['stack'][-2:]==['LengthB(data)','5']:
     fetch+='    AS.Scalar(LengthB(data));\n    assert ArrayBytes(data) == 32*(LengthB(data) as nat);\n'
    else:fetch+='    DS.DecoderLimit();\n'
   # Isolate the fitting offset arithmetic from unrelated calldata-word facts.
   if n['op']==1 and len(n['stack']) >= 2:
    for operand in ['A','B']:
     if set(n['stack'][-2:]) == {'32',f'HeadPosition{operand}(data)'}:
      fetch+=f'    assert Head{operand}(data) < 0x10000000000000000;\n    assert HeadPosition{operand}(data) == (Head{operand}(data) as nat)+4;\n    assert Offset{operand}(data) == (Head{operand}(data) as nat)+36;\n    assert (HeadPosition{operand}(data) as nat)+32 == Offset{operand}(data);\n'
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
  calls='\n'.join(f'    Advance{i}(code,state,data,mem,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running(827,[2625112747],mem);\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start(data: seq<Byte>, mem: seq<Byte>)
    requires Admitted(data)
    ensures Good(0,Running(827,[2625112747],mem),data,mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(827,[2625112747],mem) && trace[|trace|-1] == state
  {{
    Start(data,mem);
    state := Running(827,[2625112747],mem);
    trace := [state];
{calls}
  }}
}}
'''
  # Long second-operand paths use proved trace blocks; all instruction and terminal obligations remain.
  if len(states) > 100:
   start_method=text.index('  ghost method Run(')
   text=text[:start_method]
   joins=[]
   for block_start in range(0,len(states),20):
    block_end=min(block_start+20,len(states));block_id=block_start//20
    first_state=f"Running({states[block_start]['pc']},[{','.join(states[block_start]['stack'])}],mem)"
    last_contract='state == Reverted([])' if block_end==len(states) else f'Good({block_end},state,data,mem)'
    block_calls='\n'.join(f'    Advance{i}(code,state,data,mem,value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(block_start,block_end))
    text+=f'''  ghost method Block{block_id}(code: seq<Byte>, initial: State, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data) && Good({block_start},initial,data,mem)
    ensures {last_contract}
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {block_end-block_start+1} && trace[0] == {first_state} && trace[|trace|-1] == state
    ensures trace[0] == initial
  {{
    reveal Good();
    assert initial == {first_state};
    state := initial; trace := [state];
{block_calls}
  }}
'''
    joins.append(f'    state,part := Block{block_id}(code,state,data,mem,value);\n    E.Join(code,Destinations(),value,data,trace,part);\n    trace := trace+part[1..];')
   joined='\n'.join(joins)
   text+=f'''  ghost method Run(code: seq<Byte>, data: seq<Byte>, mem: seq<Byte>, value: Word) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(data)
    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running(827,[2625112747],mem) && trace[|trace|-1] == state
  {{
    Start(data,mem);
    state := Running(827,[2625112747],mem);
    trace := [state];
    var part: seq<State>;
{joined}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/('Raw'+name+'.generated.dfy')).write_text(text);(out/('Raw'+name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'scope':'development raw descriptor/bytes-array-head decoder class only, not completed public evidence'},indent=2)+'\n');print(name,len(states),'exact empty rejection states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
