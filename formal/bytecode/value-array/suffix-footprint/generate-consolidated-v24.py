#!/usr/bin/env python3
"""Exact empty/dynamic/static footprint calculation before any suffix rejection guard."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value)if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k'];params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, end: Word, dyn: Word, words: Word, q: Word, k: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k'
 for mode,q,k,dyn,words in [('Empty',31,0,0,3),('Dynamic',32,2,1,1),('Static',32,2,0,3)]:
  start=14433;terminal=14481;initial=fields.copy();values=dict(returnPc=9908,descriptorOffset=100,descriptorLength=80,p=10,limit=80,end=30,dyn=dyn,words=words,q=q,k=k,b=93);stack=[Expr(values[t],t)for t in initial];pc=start;states=[];required={};dests=set()
  while pc!=terminal:
   op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack]));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<200
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:j=op-143;stack[-1],stack[-1-j]=stack[-1-j],stack[-1]
   elif op==0x50:stack.pop()
   elif op in {1,2,3,4}:
    a,z=stack.pop(),stack.pop()
    if op==1:
     v=(a.value+z.value)%MOD
     if {a.text,z.text}=={'end','1'}:t='end+1'
     elif {a.text,z.text}=={'q','1'}:t='q+1'
     elif {a.text,z.text}=={'descriptorOffset','q'}:t='descriptorOffset+q'
     else:raise ValueError((mode,pc,op,a.text,z.text))
    elif op==2:
     assert {a.text,z.text}=={'words','k'};v=a.value*z.value;t='words*k'
    elif op==3:
     assert a.text=='q'and z.text=='end+1';v=(a.value-z.value)%MOD;t='q-(end+1)'
    else:
     assert a.text=='words*k'and z.text=='words'and words>0;v=a.value//z.value;t='k'
    stack.append(Expr(v,t))
   elif op==0x35:
    a=stack.pop();assert a.text=='descriptorOffset+q';stack.append(Expr(0,'DataWord(data,descriptorOffset+q)'))
   elif op==0x1a:
    a,z=stack.pop(),stack.pop();assert a.text=='0'and z.text=='DataWord(data,descriptorOffset+q)';stack.append(Expr(93,'b'))
   elif op==0x17:
    a,z=stack.pop(),stack.pop();v=a.value|z.value
    if a.constant()and z.constant():t=str(v)
    elif {a.text,z.text} in [{'k','1'},{'k','words'},{'k','words*k'}]:t=f'G.BitOr({a.text},{z.text})'
    else:raise ValueError((mode,pc,op,a.text,z.text))
    stack.append(Expr(v,t))
   elif op in {0x10,0x11,0x14}:
    a,z=stack.pop(),stack.pop();v=int(a.value<z.value if op==0x10 else a.value>z.value if op==0x11 else a.value==z.value);stack.append(Expr(v))
   elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
   elif op in {0x56,0x57}:
    dest=stack.pop();assert dest.constant();dests.add(dest.value);required[dest.value]=code[dest.value];assert code[dest.value]==91
    if op==0x56 or stack.pop().value:nxt=dest.value
   else:raise ValueError((mode,pc,op))
   pc=nxt
  expected=[x.text for x in stack];assert expected==fields[:6]+['1'if mode=='Empty'else'dyn','1'if mode=='Empty'else'words*k'if mode=='Static'else'words']+['q','k'],expected
  cap=max(max(len(s['stack'])for s in states),len(expected));literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)";first=f"Running({start},prefix+[{','.join(initial)}],mem)";final=f"Running({terminal},prefix+[{','.join(expected)}],mem)";matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()));good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false';desttext=','.join(str(d)for d in sorted(dests));admit=f'|prefix| <= {1024-cap} && descriptorOffset < 0x10000000000000000 && p < end < q <= limit <= descriptorLength < 0x10000000000000000 && words >= 1 && words <= 0xffffffff*(end-p) && k <= 0xffffffff*10+9 && dyn <= 1 && (dyn == 0 || words == 1)'
  if mode=='Empty':admit+=' && q == end+1 && k == 0'
  elif mode=='Dynamic':admit+=' && q > end+1 && dyn == 1 && words == 1'
  else:admit+=' && q > end+1 && dyn == 0 && words*k < G.Modulus()'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact {mode} typeShape footprint calculation before the suffix guard; rejecting connection remains open.
include "../byte-machine/Execution.dfy"
include "Scalar.dfy"
include "../checked-multiply/Scalar.dfy"
module BytecodeCollectionsSuffixFootprint{mode} {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import F = BytecodeScanFetch
  import R = BytecodeScanRepresentation
  import W = BytecodeCollectionsSuffixFootprintScalar
  import MS = BytecodeCollectionsCheckedMultiplyScalar
  predicate Admitted(code: seq<Byte>,{params}) {{ {admit} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(returnPc: Word): set<nat> {{ {{{desttext}}} }}
  opaque predicate Good(id: nat,state: State,code: seq<Byte>,{params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   if s['op'] in (99,100,101):
    width=s['op']-95;bytes_=list(code[s['pc']+1:s['next']]);fetch=f"    R.WindowFits(code,{s['pc']+1},{width});\n    assert code[{s['pc']+1}..{s['next']}] == {bytes_};\n"
    for k in range(1,width+1):fetch+=f"    assert G.Decode({bytes_[:k]}) == {int.from_bytes(bytes(bytes_[:k]),'big')};\n"
   step='    reveal B.Step();' if s['op']==0x1a else '    B.Delegate(code,Destinations(returnPc),state,value,data);C.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();'
   scalars='    W.ProductFits(words,k,p,end);MS.ProductQuotient(k,words);\n' if mode=='Static' else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures B.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := B.Step(code,Destinations(returnPc),state,value,data); {post}
  {{ reveal Matches();reveal Good();assert state == {literal(s)};
{fetch}{scalars}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{step}
  }}
'''
  text+='''  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires E.Trace(code,destinations,value,data,left) && E.Trace(code,destinations,value,data,right) && left[|left|-1] == right[0]
    ensures E.Trace(code,destinations,value,data,left+right[1..])
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures B.Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i] && (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1);assert 0 <= j < |right|-1;assert (left+right[1..])[i] == right[j] && (left+right[1..])[i+1] == right[j+1]; }
    }
  }
'''
  joins=[]
  for start_id in range(0,len(states),12):
   end=min(start_id+12,len(states));block=start_id//12;post=f'state == {final}' if end==len(states) else f'Good({end},state,code,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);var next{i} := B.Step(code,Destinations(returnPc),state,value,data);E.Extend(code,Destinations(returnPc),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(start_id,end))
   text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args}) && Good({start_id},initial,code,{args})
    ensures {post} && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == {end-start_id+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial;trace := [state];
{calls}
  }}
''';joins.append(f'    state,part := Block{block}(code,state,{args},value);Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];')
  text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {final} && E.Trace(code,Destinations(returnPc),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {first} && trace[|trace|-1] == state
  {{ state := {first};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/f'{mode}.generated.dfy').write_text(text);(out/f'{mode}.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,mode=mode,states=states,requiredBytes=required,terminalPc=terminal,initialStack=initial,expectedStack=expected,scope='Exact complete typeShape suffix footprint calculation with unchanged full lower stack and memory, including arbitrary admitted decimal stop and derived fitting static products. Guard, recursive rejection, codec and retention connections remain open.'),indent=2)+'\n');print(mode,len(states),'instructions',expected)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated-consolidated-v24.py','--output',a.output,'--include-root',HERE],check=True)
