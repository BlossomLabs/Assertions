#!/usr/bin/env python3
"""Extract complete map/keep/skip result iteration from exact current runtime."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,v,t=None):self.value=v;self.text=str(v) if t is None else t
 def constant(self):return self.text.isdecimal()
def generate(out):
 obj=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(obj['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'];assert pin['methodIdentifiers']['mapWords(bytes,address,bytes,uint256[])']=='ed6dc3be' and pin['methodIdentifiers']['filterWords(bytes,address,bytes,uint256[])']=='7787eb48'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 dests={pc for pc,(op,_,_) in ins.items() if op==91};out.mkdir(parents=True,exist_ok=True)
 for kind,mode,result in [('Map',0,11),('Keep',1,1),('Skip',1,0)]:
  names=['returnPc','sourceOffset','sourceLength','target','templateOffset','templateLength','arrayOffset','count',str(mode),'out','n','kept','ptr','index','word','0','result']
  values=[5526,68,96,18176,228,64,324,0,mode,128,3,1,256,1,7,0,result];stack=[Expr(v,t) for v,t in zip(values,names)];pc=12484;mem='mem';states=[];required={12391:code[12391]};targets={12391}
  while pc!=12391:
   assert len(states)<100;op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem))
   if op==91:pass
   elif op==95 or 96<=op<=127:stack.append(Expr(imm))
   elif 128<=op<=143:stack.append(stack[-(op-127)])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==80:stack.pop()
   elif op in (1,2):
    a,b=stack.pop(),stack.pop();v=(a.value+b.value if op==1 else a.value*b.value)%MOD
    if a.constant() and b.constant():t=str(v)
    elif op==2 and '32' in {a.text,b.text} and ('kept' in {a.text,b.text} or 'index' in {a.text,b.text}):t=('kept' if 'kept' in {a.text,b.text} else 'index')+'*32'
    elif op==1 and 'out' in {a.text,b.text} and ('kept*32' in {a.text,b.text} or 'index*32' in {a.text,b.text}):t='out+'+('kept*32' if 'kept*32' in {a.text,b.text} else 'index*32')
    elif op==1 and '32' in {a.text,b.text} and ('out+kept*32' in {a.text,b.text} or 'out+index*32' in {a.text,b.text}):t=('out+kept*32' if 'out+kept*32' in {a.text,b.text} else 'out+index*32')+'+32'
    elif op==1 and a.text in {'kept','index'} and b.text=='1':t=a.text+'+1'
    elif op==1 and b.text in {'kept','index'} and a.text=='1':t=b.text+'+1'
    else:raise ValueError((kind,pc,a.text,b.text))
    stack.append(Expr(v,t))
   elif op==17:
    a,b=stack.pop(),stack.pop();stack.append(Expr(int(a.value>b.value)))
   elif op==21:stack.append(Expr(int(stack.pop().value==0)))
   elif op==82:
    a,b=stack.pop(),stack.pop();assert a.text==('out+index*32+32' if kind=='Map' else 'out+kept*32+32') and b.text==('result' if kind=='Map' else 'word');mem=f'Store(mem,{a.text},{b.text})'
   elif op in (86,87):
    target=stack.pop();assert target.constant() and target.value in dests;targets.add(target.value);required[target.value]=code[target.value]
    if op==86 or stack.pop().value:nxt=target.value
   else:raise ValueError((kind,pc,hex(op)))
   pc=nxt
  finalNames=names[:14];finalNames[11]='kept' if kind=='Skip' else 'kept+1';finalNames[13]='index+1';assert [x.text for x in stack]==finalNames,(kind,[x.text for x in stack],finalNames)
  fields='returnPc: Word,sourceOffset: Word,sourceLength: Word,target: Word,templateOffset: Word,templateLength: Word,arrayOffset: Word,count: Word,out: Word,n: Word,kept: Word,ptr: Word,index: Word,word: Word,result: Word';args='data,mem,prefix,returnPc,sourceOffset,sourceLength,target,templateOffset,templateLength,arrayOffset,count,out,n,kept,ptr,index,word,result,value';params='data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,'+fields+',value: Word'
  cap=max(len(s['stack']) for s in states);condition='true' if kind=='Map' else 'result == '+str(result);literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";initial=literal(states[0]);final=f"Running(12391,prefix+[{','.join(finalNames)}],{mem})";good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete physical {kind.lower()} result iteration, arbitrary input/result words.
include "../../scans/Execution.dfy"
module BytecodeApplyResult{kind} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  predicate Admitted({params}) {{ 0 < n < 0x800000000000000 && index < n && kept <= index && (out as nat)+32+32*n < G.Modulus() && {condition} && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params})
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ hide G.BitAnd(); reveal Matches(); reveal Good(); reveal Step();
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
  }}
'''
  joins=[]
  for start in range(0,len(states),20):
   end=min(start+20,len(states));block=start//20;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args});\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(start,end))
   text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial;trace := [state];
{calls}
  }}
'''
   joins.append(f'    state,part := Block{block}(code,state,{args});\n    E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
  text+=f'''  ghost method Run(code: seq<Byte>,{params}) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{ state := {initial};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  (out/(kind+'.generated.dfy')).write_text(text);(out/(kind+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,destinations=sorted(targets),scope='Exact successful result iteration; arbitrary original and map result words, canonical keep/skip results. Complete raw entry/error/loop/retained public evidence pending.'),indent=2)+'\n');print(kind,len(states),'actual result iteration instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE.parent/'map-prefix/format-generated.py','--output',a.output,'--include-root',HERE],check=True)
