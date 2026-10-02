#!/usr/bin/env python3
"""Extract complete zero-code target check and physical error receipt."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,v,t=None):self.value=v;self.text=str(v) if t is None else t
 def constant(self):return self.text.isdecimal()
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'];assert pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6d24e79c' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0';assert any(x['type']=='error' and x.get('name')=='InvalidCallbackTarget' and [v['type'] for v in x['inputs']]==['address'] for x in artifact['abi'])
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91};pc=15859;stack=[Expr(12052),Expr(18176,'target')];memory='Store([],64,128)';states=[];required={};targets=set();consumed=0;params='target: Word, prefix: seq<Word>, returned: seq<Byte>, cursor: nat, observations: seq<X.Observation>, self: Word, value: Word, data: seq<Byte>';args='target,prefix,returned,cursor,observations,self,value,data'
 while True:
  assert len(states)<80;op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=memory,consumed=consumed))
  if op==91:pass
  elif op==95 or 96<=op<=127:stack.append(Expr(imm))
  elif 128<=op<=143:stack.append(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==80:stack.pop()
  elif op in (1,3):
   a,b=stack.pop(),stack.pop();v=(a.value+b.value if op==1 else a.value-b.value)%MOD
   if a.constant() and b.constant():t=str(v)
   elif op==1 and a.text=='128' and b.constant():t=f'128+{b.value}'
   elif op==1 and b.text=='128' and a.constant():t=f'128+{a.value}'
   elif op==3 and a.text=='128+36' and b.text=='128':t='36'
   else:raise ValueError((pc,a.text,b.text))
   stack.append(Expr(v,t))
  elif op==27:
   a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr((b.value<<a.value)%MOD))
  elif op==22:
   a,b=stack.pop(),stack.pop();assert (a.text=='target' and b.value==(1<<160)-1) or (b.text=='target' and a.value==(1<<160)-1);stack.append(Expr(18176,'target'))
  elif op==59:assert stack.pop().text=='target';stack.append(Expr(0));consumed+=1
  elif op==81:assert stack.pop().value==64;stack.append(Expr(128))
  elif op==82:
   offset,datum=stack.pop(),stack.pop();memory=f'Store({memory},{offset.text},{datum.text})'
  elif op in (86,87):
   dest=stack.pop();assert dest.constant() and dest.value in dests;targets.add(dest.value);required[dest.value]=code[dest.value]
   if op==86 or stack.pop().value:nxt=dest.value
  elif op==253:
   offset,size=stack.pop(),stack.pop();assert offset.text=='128' and size.value==36;break
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 assert consumed==1
 cap=max(len(x['stack']) for x in states);literal=lambda s:f"X.Frame(Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']}),returned,cursor+{s['consumed']})";initial=literal(states[0]);final='X.Frame(Reverted(G.Encode(0x54b3288a,4)+G.Encode(target,32)),returned,cursor+1)';good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then frame == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 text=f'''// SPDX-License-Identifier: MIT
// Generated actual code-less target path to complete physical REVERT.
include "../../external-calls/Execution.dfy"
include "../../scans/Push.dfy"
include "Memory.dfy"
include "../../word-apply/target-rejection/Scalar.dfy"
include "../../word-apply/target-rejection/Sequence.dfy"
module BytecodeFoldTargetRejected {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import C = BytecodeCopyMachine
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeFoldTargetErrorMemory
  import SC = BytecodeApplyTargetErrorScalar
  import AM = BytecodeApplyAddressMask
  import Q = BytecodeApplyTargetErrorSequence
  predicate Admitted({params}) {{ X.Context(self) && target < AM.Bound() && |prefix| <= {1024-cap} && cursor < |observations| && observations[cursor] == X.CodeSize(target,0) }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,frame: X.Frame,{params}) {{ Admitted({args}) && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else f"    P.Push4(code,{s['pc']});\n" if s['op']==99 else '';facts=''
  if s['op']==59:
   facts+='    Q.ThreeOne(prefix,12052,target,target);\n    Q.ThreeOne(prefix,12052,target,0);\n    assert frame == X.Frame(Running(15870,(prefix+[12052,target])+[target],Store([],64,128)),returned,cursor);\n    assert X.Address(target) == target;\n    X.CodeSizeStep(code,15870,prefix+[12052,target],Store([],64,128),self,target,0,returned,cursor,observations,value,data);\n    E.WidenStep(code,{},Destinations(),frame,self,value,data,observations);\n'
  else:
   facts+='    X.Delegate(code,Destinations(),frame,self,value,data,observations);\n    C.Delegate(code,Destinations(),frame.state,value,data);\n'
   if s['op']==22:
    reverse=s['pc']==15899;tail='[12052,target,128]' if reverse else '[12052,target]';mem=s['memory'];a='0xffffffffffffffffffffffffffffffffffffffff' if reverse else 'target';b='target' if reverse else '0xffffffffffffffffffffffffffffffffffffffff';facts+=f'    Q.{"FivePair" if reverse else "FourPair"}(prefix,{tail[1:-1]},{a},{b});\n    Q.{"FourOne" if reverse else "ThreeOne"}(prefix,{tail[1:-1]},target);\n    assert frame.state == Running({s["pc"]},(prefix+{tail})+[{a},{b}],{mem});\n    SC.Mask(code,{s["pc"]},Destinations(),prefix+{tail},{mem},target,{str(reverse).lower()},value,data);\n'
   else:
    facts+='    reveal Step();\n'
    if s['op']==27:facts+= '    SC.Selector();\n' if s['pc']==15887 else '    AM.Limit();\n'
  text+=f'''  lemma Advance{i}(code: seq<Byte>,frame: X.Frame,{params})
    requires Matches(code) && Admitted({args}) && Good({i},frame,{args})
    ensures X.Step(code,Destinations(),frame,self,value,data,observations).state != Bad
    ensures var next := X.Step(code,Destinations(),frame,self,value,data,observations); {post}
  {{ hide G.BitAnd(); reveal Matches(); reveal Good();
    H.Frames(target);
    assert frame == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{facts}
  }}
'''
 joins=[]
 for start in range(0,len(states),20):
  end=min(start+20,len(states));block=start//20;post=f'frame == {final}' if end==len(states) else f'Good({end},frame,{args})';calls='\n'.join(f'    Advance{i}(code,frame,{args});\n    var next{i} := X.Step(code,Destinations(),frame,self,value,data,observations);\n    E.Extend(code,Destinations(),self,value,data,observations,trace,next{i});trace := trace+[next{i}];frame := next{i};' for i in range(start,end))
  text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: X.Frame,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == frame
  {{ frame := initial;trace := [frame];
{calls}
  }}
'''
  joins.append(f'    frame,part := Block{block}(code,frame,{args});\n    E.Join(code,Destinations(),self,value,data,observations,trace,part);trace := trace+part[1..];')
 text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted({args})
    ensures frame == {final} && E.Trace(code,Destinations(),self,value,data,observations,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == frame
  {{ frame := {initial};trace := [frame];reveal Good();var part: seq<X.Frame>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
 out.mkdir(parents=True,exist_ok=True);(out/'Rejected.generated.dfy').write_text(text);(out/'Rejected.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),errorSelector='54b3288a',scope='Exact fold code-less target rejection before any allocation; no range-count narrowing; raw composition/full retained public evidence open.'),indent=2)+'\n');print(len(states),'actual zero-code target instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
