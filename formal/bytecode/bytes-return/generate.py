#!/usr/bin/env python3
"""Generate the actual dynamic bytes return path for arbitrary aligned payloads."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[2]; MOD=1<<256; SELECTOR=2368205965
class Expr:
 def __init__(self,value,text=None): self.value=value; self.text=str(value) if text is None else text
 def constant(self): return self.text.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text()); code=bytes.fromhex(obj['deployedBytecode'][2:]); pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']; digest=hashlib.sha256(code).hexdigest()
 assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['iotaWords(uint256)']=='8d27f48d'
 ins={}; p=0
 while p<len(code):
  op=code[p]; width=op-95 if 96<=op<=127 else 0; ins[p]=(op,p+1+width,int.from_bytes(code[p+1:p+1+width].ljust(width,b'\0'),'big')); p+=1+width
 dests={p for p,(op,_,_) in ins.items() if op==91}
 pc=518; stack=[Expr(SELECTOR,"selector"),Expr(128)]; stage=0; nodes=[]; required={}; targets=set(); seen=set()
 while True:
  assert pc not in seen; seen.add(pc); op,nxt,imm=ins[pc]
  for p in range(pc,nxt): required[p]=code[p]
  nodes.append({'id':len(nodes),'pc':pc,'op':op,'next':nxt,'immediate':imm,'stack':[x.text for x in stack],'stage':stage})
  if op==0x5b: pass
  elif op==0x5f or 96<=op<=127: stack.append(Expr(imm))
  elif 0x80<=op<=0x8f: stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f: k=op-143; stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50: stack.pop()
  elif op==0x51:
   a=stack.pop(); assert a.constant() and a.value in {64,128}
   stack.append(Expr(224,'O.Extent(n)') if a.value==64 else Expr(64,'n*32'))
  elif op==0x52:
   offset,a=stack.pop(),stack.pop()
   if stage==0: assert offset.text=='O.Extent(n)' and a.constant(); stage=1
   elif stage==1: assert offset.value==256 and a.text=='n*32'; stage=2
   else: assert stage==3 and offset.value==352 and a.text=='0'; stage=4
  elif op in {0x01,0x03}:
   a,b=stack.pop(),stack.pop(); value=(a.value+b.value if op==1 else a.value-b.value)%MOD
   if a.constant() and b.constant(): stack.append(Expr(value))
   elif op==1 and {a.text,b.text}=={'31','n*32'}: stack.append(Expr(value,'n*32+31'))
   else: stack.append(Expr(value,f'({a.text}+{b.text})' if op==1 else f'({a.text}-{b.text})'))
  elif op==0x19:
   a=stack.pop(); assert a.constant(); stack.append(Expr(MOD-1-a.value))
  elif op==0x16:
   a,b=stack.pop(),stack.pop(); assert a.text=='n*32+31' and b.value==MOD-32; stack.append(Expr(a.value&b.value,'n*32'))
  elif op==0x5e:
   dst,src,length=stack.pop(),stack.pop(),stack.pop(); assert dst.value==288 and src.text=='160' and length.text=='n*32' and stage==2; stage=3
  elif op==0x56:
   dst=stack.pop(); assert dst.constant() and dst.value in dests; targets.add(dst.value); required[dst.value]=code[dst.value]; nxt=dst.value
  elif op in {0xf3,0xfd}:
   assert pc==498 and stage==4 and stack[-1].value==224 and stack[-2].value==128; break
  else: raise ValueError((pc,op))
  pc=nxt
 def state(node): return f'Running({node["pc"]},[{",".join(node["stack"])}],R.Stage(n,payload,{node["stage"]}))'
 good='\n'.join('    '+('if' if node['id']==0 else 'else if')+f' id == {node["id"]} then state == {state(node)}' for node in nodes)+'\n    else false'
 matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 text=f'''// SPDX-License-Identifier: MIT
// Generated actual shared dynamic bytes serializer instructions.
include "Memory.dfy"
include "../iota-return/MaskOpcode.dfy"
include "../iota-return/SubOpcode.dfy"
include "../scans/Fetch.dfy"
module BytecodeAlignedBytesReturnControl {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import M = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import O = BytecodeIotaOutput
  import R = BytecodeAlignedBytesReturnMemory
  import RM = BytecodeIotaReturnMaskOpcode
  import RS = BytecodeIotaReturnSubOpcode
  import SC = BytecodeIotaAllocationScalar
  predicate Admitted(n: Word, payload: seq<Byte>) {{ n < 0x800000000000000 && |payload| == n*32 }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, n: Word, payload: seq<Byte>, selector: Word) {{ Admitted(n,payload) && (
{good}) }}
'''
 for node in nodes:
  i=node['id']; post=f'next == Returned(R.Bytes(n,payload))' if i==len(nodes)-1 else f'Good({i+1},next,n,payload,selector)'
  extra=''; prefix='['+','.join(node['stack'][:-3])+']'
  if node['pc']==496:
   prefix='['+','.join(node['stack'][:-2])+']'
   extra=f'    assert state == Running(496,{prefix}+[160+n*32,224+n*64],R.Stage(n,payload,4));\n    RS.Step(code,Destinations(),{prefix},R.Stage(n,payload,4),n,value,data);\n    assert S.Step(code,Destinations(),state,value,data) == Running(497,{prefix}+[64+n*32],R.Stage(n,payload,4));\n    M.Delegate(code,Destinations(),state,value,data);'
  elif node['op']==0x5e:
   extra=f'    assert state == Running(20967,{prefix}+[n*32,160,O.Extent(n)+64],R.Stage(n,payload,2));\n    R.ActualCopy(code,n,payload,{prefix},value,data);\n    assert M.Step(code,{{}},state,value,data) == Running(20968,{prefix},R.Stage(n,payload,3));\n    E.WidenStep(code,{{}},Destinations(),state,value,data);'
  elif node['op'] in {0xf3,0xfd}:
   extra='    assert state == Running(498,[selector]+[64+n*32,O.Extent(n)],R.Stage(n,payload,4));\n    R.Return(code,n,payload,[selector],value,data);\n    assert M.Step(code,{},state,value,data) == Returned(R.Bytes(n,payload));\n    E.WidenStep(code,{},Destinations(),state,value,data);'
   if node['op']==0xfd: extra='    M.Delegate(code,Destinations(),state,value,data);\n    reveal S.Step();\n    assert R.Stage(n,payload,4)[O.Extent(n)..O.Extent(n)+64+n*32] == R.Bytes(n,payload);'
  elif node['op']==0x16:
   prefix='['+','.join(node['stack'][:-2])+']'
   extra=f'    assert state == Running(20985,{prefix}+[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0,n*32+31],R.Stage(n,payload,{node["stage"]}));\n    RM.Step(code,Destinations(),{prefix},R.Stage(n,payload,{node["stage"]}),n,value,data);\n    assert S.Step(code,Destinations(),state,value,data) == Running(20986,{prefix}+[n*32],R.Stage(n,payload,{node["stage"]}));\n    M.Delegate(code,Destinations(),state,value,data);'
  else:
   extra='    M.Delegate(code,Destinations(),state,value,data);\n    reveal S.Step();'
   if node['pc']==21215: extra+='\n    R.FirstStore(n,payload);'
   elif node['pc']==20957: extra+='\n    R.SecondStore(n,payload);'
   elif node['pc']==20975: extra+='\n    R.FinalStore(n,payload);'
   elif node['op']==0x19: extra+='\n    SC.Not31();'
  fetch=f'    F.Push{node["op"]-95}(code,{node["pc"]});\n' if node['op'] in {96,97} else ''
  text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(n,payload) && Good({i},state,n,payload,selector)
    ensures state.Running? && |state.stack| <= {max(len(x['stack']) for x in nodes)} && |state.memory| <= O.Extent(n)+96+n*32
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
    R.Sizes(n,payload,{node['stage']}); R.Headers(n,payload,{node['stage']});
    assert state == {state(node)};
{fetch}    assert Fetch(code,{node['pc']}) == Op({node['op']},{node['next']},{node['immediate']});
{extra}
  }}
'''
 calls='\n'.join(f'    Advance{i}(code,state,n,payload,selector,value,data);\n    var next{i} := M.Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    assert trace[0] == Running(518,[selector,128],R.Heap(n,payload));\n    state := next{i};' for i in range(len(nodes)))
 text+=f'''  lemma Start(n: Word, payload: seq<Byte>, selector: Word)
    requires Admitted(n,payload)
    ensures Good(0,Running(518,[selector,128],R.Heap(n,payload)),n,payload,selector)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, n: Word, payload: seq<Byte>, selector: Word, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(n,payload)
    ensures state == Returned(R.Bytes(n,payload))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(nodes)+1} && trace[0] == Running(518,[selector,128],R.Heap(n,payload)) && trace[|trace|-1] == state
  {{
    Start(n,payload,selector); state := Running(518,[selector,128],R.Heap(n,payload)); trace := [state];
{calls}
  }}
}}
'''
 out.mkdir(parents=True,exist_ok=True); (out/'Control.generated.dfy').write_text(text); (out/'Control.mapping.json').write_text(json.dumps({'runtimeSha256':digest,'states':nodes,'requiredBytes':required,'destinations':sorted(targets),'scope':'Development actual serializer only. No completed public bytecode coverage.'},indent=2)+'\n'); print(len(nodes),'actual serializer states')
if __name__=='__main__':
 p=argparse.ArgumentParser(); p.add_argument('--output',type=Path,required=True); a=p.parse_args(); generate(a.output); subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
