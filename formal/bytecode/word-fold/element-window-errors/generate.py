#!/usr/bin/env python3
"""Extract complete reached short-template and arbitrary invalid-window error paths."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;HEADER=0x1a0d83de<<224
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91};fields=['returnPc','templateOffset','templateLength','arrayOffset','count'];params='prefix: seq<Word>, returnPc: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, index: Word, value: Word, data: seq<Byte>';args='prefix,returnPc,templateOffset,templateLength,arrayOffset,count,index,value,data'
 for name,entry,length,count,idx in [('Invalid',16728,64,2,1)]:
  stack=[Expr(v,f) for v,f in zip([16419,196,length,260,count],fields)]+([] if name=='Short' else [Expr(idx,'index')]);initialStack=[x.text for x in stack];pc=entry;mem='Store([],64,128)';states=[];required={};targets=set();seen=set();arg='0' if name=='Short' else 'W.At(arrayOffset,index,data)'
  while True:
   key=pc,tuple(x.text for x in stack);assert key not in seen and len(states)<160;seen.add(key);op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem))
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op in (1,2,3):
    a,b=stack.pop(),stack.pop();v=(a.value+b.value if op==1 else a.value*b.value if op==2 else a.value-b.value)%MOD
    if a.constant() and b.constant():text=str(v)
    elif op==3 and a.text=='templateLength' and b.value==32:text='templateLength-32'
    elif op==2 and {a.text,b.text}=={'index','32'}:text='index*32'
    elif op==1 and {a.text,b.text}=={'arrayOffset','index*32'}:text='((arrayOffset as nat)+index*32)%G.Modulus()'
    else:raise ValueError((name,pc,a.text,b.text))
    stack.append(Expr(v,text))
   elif op in (0x10,0x11):
    a,b=stack.pop(),stack.pop();stack.append(Expr(int(a.value<b.value if op==0x10 else a.value>b.value)))
   elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
   elif op==0x1b:
    a,b=stack.pop(),stack.pop();assert a.constant() and b.constant();stack.append(Expr((b.value<<a.value)%MOD))
   elif op==0x35:
    pos=stack.pop();assert pos.value==292 and name=='Invalid';stack.append(Expr(33,'W.At(arrayOffset,index,data)'))
   elif op==0x51:assert stack.pop().value==64;stack.append(Expr(128))
   elif op==0x52:
    off,datum=stack.pop(),stack.pop();assert off.constant();mem=f'Store({mem},{off.text},{datum.text})'
   elif op in (0x56,0x57):
    dest=stack.pop();assert dest.constant() and dest.value in dests;targets.add(dest.value);required[dest.value]=code[dest.value]
    if op==0x56 or stack.pop().value:nxt=dest.value
   elif op==0xfd:
    off,size=stack.pop(),stack.pop();assert off.value==128 and size.value==68;break
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt
  cap=max(len(x['stack']) for x in states);admission='templateLength < 32' if name=='Short' else 'W.Represented(templateLength,arrayOffset,count,data) && templateLength >= 32 && index < count && W.At(arrayOffset,index,data) > templateLength-32';admission+=f' && |prefix| <= {1024-cap}';literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";initial=f"Running({entry},prefix+[{','.join(initialStack)}],Store([],64,128))";final=f'Reverted(G.Encode(0x1a0d83de,4)+G.Encode({arg},32)+G.Encode(templateLength,32))';good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical window rejection path; native proof pins exact error bytes.
include "../element-windows/Inputs.dfy"
include "../../scans/Push.dfy"
include "../../word-apply/window-errors/Memory.dfy"
include "../../word-apply/window-errors/Scalar.dfy"
module BytecodeFoldElementWindowError{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeFoldElementWindowInputs
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import R = BytecodeScanRepresentation
  import H = BytecodeApplyWindowErrorMemory
  import SC = BytecodeApplyWindowErrorScalar
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else f"    P.Push4(code,{s['pc']});\n" if s['op']==99 else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && |state.stack| <= 1024 && |state.memory| <= 224
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    H.Layout({arg},templateLength);
{('    W.Index(templateLength,arrayOffset,count,data,index);' if name=='Invalid' else '')}
{('    SC.Selector();' if s['op']==0x1b else '')}
{('    H.Error(Store([],64,128),'+arg+',templateLength);' if s['op']==0xfd else '')}
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
  joins=[]
  for start in range(0,len(states),20):
   end=min(start+20,len(states));block=start//20;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
   text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
'''
   joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
  text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good();
    var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Development complete physical window error leaf only; raw composition/full retained public evidence open.'),indent=2)+'\n');print(name,len(states),'actual window rejection instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
