#!/usr/bin/env python3
"""Extract complete compiled callback bytes packing helper, not fixture semantics."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])']=='ed6dc3be' and pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])']=='7787eb48'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 destinations={x for x,(op,_,_) in ins.items() if op==0x5b}
 stack=[Expr(16936),Expr(192,'ptr'),Expr(256,'free')];pc=24276;mem='mem';states=[];required={16936:code[16936]};targets={16936}
 while pc!=16936:
  op,nxt,imm=ins[pc];required.update({x:code[x] for x in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem));assert len(states)<100
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x51:
   a=stack.pop();assert a.text=='ptr' and mem=='mem';stack.append(Expr(32,'length'))
  elif op==1:
   a,b=stack.pop(),stack.pop();texts={a.text,b.text}
   if texts=={'ptr','32'}:t='ptr+32'
   elif texts=={'free','length'}:t='free+length'
   else:raise ValueError((pc,texts))
   stack.append(Expr(a.value+b.value,t))
  elif op==0x5e:
   a,b,c=stack.pop(),stack.pop(),stack.pop();assert (a.text,b.text,c.text)==('free','ptr+32','length');mem='H.Copied(mem,ptr,free,length)'
  elif op==0x52:
   a,b=stack.pop(),stack.pop();assert (a.text,b.text)==('free+length','0');mem='H.Packed(mem,ptr,free,length)'
  elif op==0x56:
   dest=stack.pop();assert dest.constant() and dest.value in destinations;targets.add(dest.value);required[dest.value]=code[dest.value];nxt=dest.value
  else:raise ValueError((pc,hex(op)))
  pc=nxt
 assert [x.text for x in stack]==['free+length'];cap=max(max(len(s['stack']) for s in states),1)
 params='data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,ptr: Word,free: Word,length: Word,value: Word';args='data,mem,prefix,ptr,free,length,value'
 literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})"
 initial='Running(24276,prefix+[16936,ptr,free],mem)';final='Running(16936,prefix+[free+length],H.Packed(mem,ptr,free,length))'
 good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false'
 matches=' &&\n    '.join(f'code[{x}] == {v}' for x,v in sorted(required.items()))
 text=f"""// SPDX-License-Identifier: MIT
// Generated complete bytes payload packing helper. Explicit fitting memory; no public evidence claim.
include "../callback-copy/Memory.dfy"
include "../../copy/Execution.dfy"
module BytecodeApplyCallbackPack {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import C = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import H = BytecodeApplyCallbackCopyMemory
  predicate Admitted({params}) {{ H.Fits(mem,ptr,free,length) && Load(mem,ptr) == length && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
"""
 for s in states:
  i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})'
  fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
  operation='    reveal C.Step();' if s['op']==0x5e else '    C.Delegate(code,Destinations(),state,value,data);\n    reveal Step();'
  facts='    H.Bounds(mem,ptr,free,length);\n' if s['op'] in (0x5e,0x52) else ''
  text+=f"""  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures C.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := C.Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{facts}{operation}
  }}
"""
 joins=[]
 for start in range(0,len(states),15):
  end=min(start+15,len(states));block=start//15;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := C.Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
  text+=f"""  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
"""
  joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
 text+=f"""  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good();
    var part: seq<State>;
"""+ '\n'.join(joins)+'\n  }\n}\n'
 out.mkdir(parents=True,exist_ok=True);(out/'Pack.generated.dfy').write_text(text);(out/'Pack.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Complete compiled bytes packing helper PC24276 to16936; admitted arbitrary fitting memory/header, actual MCOPY and padding. Selected/full native/public evidence open.'),indent=2)+'\n');print(len(states),'actual callback bytes packing instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
