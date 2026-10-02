#!/usr/bin/env python3
"""Extract actual arbitrary-index stamping iteration and exit paths."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,v,t=None):self.value=v;self.text=str(v) if t is None else t
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];digest=hashlib.sha256(code).hexdigest();assert digest==pin['runtimeSha256'];assert pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6d24e79c' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91};fields=['returnPc','callPtr','arrayOffset','count','word','index'];params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, callPtr: Word, arrayOffset: Word, count: Word, word: Word, index: Word, templateLength: Word, value: Word';args='data,mem,prefix,returnPc,callPtr,arrayOffset,count,word,index,templateLength,value'
 for name,idx in [('Iteration',1),('Exit',2)]:
  stack=[Expr(v,t) for v,t in zip([11291,256,324,2,99,idx],fields)];initialStack=[x.text for x in stack];pc=16850;memory='mem';states=[];required={11291:code[11291]};targets={11291};seen=set()
  while not states or pc != (16850 if name=='Iteration' else 11291):
   key=pc,tuple(x.text for x in stack);assert key not in seen and len(states)<100;seen.add(key);op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=memory))
   if op==91:pass
   elif op==95 or 96<=op<=127:stack.append(Expr(imm))
   elif 128<=op<=143:stack.append(stack[-(op-127)])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==80:stack.pop()
   elif op in (1,2):
    a,b=stack.pop(),stack.pop();v=(a.value+b.value if op==1 else a.value*b.value)%MOD
    if a.constant() and b.constant():t=str(v)
    elif op==2 and {a.text,b.text}=={'index','32'}:t='index*32'
    elif op==1 and {a.text,b.text}=={'arrayOffset','index*32'}:t='((arrayOffset as nat)+index*32)%G.Modulus()'
    elif op==1 and {a.text,b.text}=={'callPtr','W.At(arrayOffset,index,data)'}:t='callPtr+W.At(arrayOffset,index,data)'
    elif op==1 and {a.text,b.text}=={'callPtr+W.At(arrayOffset,index,data)','32'}:t='callPtr+W.At(arrayOffset,index,data)+32'
    elif op==1 and {a.text,b.text}=={'index','1'}:t='index+1'
    else:raise ValueError((name,pc,a.text,b.text))
    stack.append(Expr(v,t))
   elif op==16:a,b=stack.pop(),stack.pop();stack.append(Expr(int(a.value<b.value)))
   elif op==21:stack.append(Expr(int(stack.pop().value==0)))
   elif op==53:
    pos=stack.pop();assert pos.value==356;stack.append(Expr(3,'W.At(arrayOffset,index,data)'))
   elif op==82:
    offset,datum=stack.pop(),stack.pop();assert offset.text=='callPtr+W.At(arrayOffset,index,data)+32' and datum.text=='word';memory=f'Store(mem,{offset.text},word)'
   elif op in (86,87):
    dest=stack.pop();assert dest.value in dests;targets.add(dest.value);required[dest.value]=code[dest.value]
    assert dest.constant() or dest.text=='returnPc'
    if op==86 or stack.pop().value:nxt=dest.value
   else:raise ValueError((name,pc,hex(op)))
   pc=nxt
  expected=fields[:-1]+['index+1'] if name=='Iteration' else []
  assert [x.text for x in stack]==expected
  initial=f"Running(16850,prefix+[{','.join(initialStack)}],mem)";terminal=f"Running({pc},prefix+[{','.join(expected)}],{memory})" if expected else 'Running(11291,prefix,mem)';cap=max(max(len(x['stack']) for x in states),len(expected));admission='index == count' if name=='Exit' else 'W.Valid(templateLength,arrayOffset,count,data) && index < count && callPtr < 0x20000000000000000 && |mem|%32 == 0 && |mem| < 0x80000000000000000 && (callPtr as nat)+32+templateLength <= |mem|';admission+=f' && returnPc == 11291 && |prefix| <= {1024-cap}'
  literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual stamping loop leaf; arbitrary finite indices and words.
include "../../word-apply/windows/Inputs.dfy"
include "../../scans/Push.dfy"
module BytecodeFoldStamp{name} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ {admission} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
  for s in states:
   i=s['id'];post=f'next == {terminal}' if i==len(states)-1 else f'Good({i+1},next,{args})';facts=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   if name=='Iteration':facts+='    W.Index(templateLength,arrayOffset,count,data,index);\n'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures state.Running? && |state.stack| <= 1024 && Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal(s)};
{facts}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
  joins=[]
  for start in range(0,len(states),20):
   end=min(start+20,len(states));block=start//20;post=f'state == {terminal}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
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
    ensures state == {terminal} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial}; trace := [state]; reveal Good(); var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Exact fold-context stamping iteration/exit returning11291; full memory/accumulator-first engine/raw iteration/callback/output/retained proof open.'),indent=2)+'\n');print(name,len(states),'actual stamping instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
