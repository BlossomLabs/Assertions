#!/usr/bin/env python3
"""Exact scanName cleanup, nonempty-name subtraction call and classification."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','descriptorOffset','descriptorLength','p','limit','q'];params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, q: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,q'
 def extract(mode,initial,start,terminal,n):
  values=dict(returnPc=14157,descriptorOffset=100,descriptorLength=80,p=10,limit=80,q=10+n);stack=[Expr(int(t) if t.isdecimal() else values['q']-values['p'] if t=='q-p' else values[t],t) for t in initial];pc=start;states=[];required={};dests=set()
  while pc!=terminal:
   op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack]));required.update({i:code[i] for i in range(pc,nxt)});assert len(states)<80
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op in {1,2,3}:
    a,z=stack.pop(),stack.pop();v=(a.value+z.value) if op==1 else (a.value*z.value) if op==2 else (a.value-z.value);v%=MOD
    if a.constant() and z.constant():t=str(v)
    elif op==1 and {a.text,z.text}=={'descriptorOffset','p'}:t='descriptorOffset+p'
    elif op==3 and a.text=='q' and z.text=='p':t='q-p'
    elif op==2 and {a.text,z.text}=={'8','q-p'}:t=str(v)
    else:raise ValueError((mode,pc,op,a.text,z.text))
    stack.append(Expr(v,t))
   elif op==0x35:
    a=stack.pop();assert a.text=='descriptorOffset+p';stack.append(Expr(0,'DataWord(data,descriptorOffset+p)'))
   elif op==0x1c:
    a,z=stack.pop(),stack.pop();assert a.constant() and z.text=='DataWord(data,descriptorOffset+p)';stack.append(Expr(0,f'ShiftRight(DataWord(data,descriptorOffset+p),{a.text})'))
   elif op==0x14:
    a,z=stack.pop(),stack.pop();v=int(a.value==z.value)
    if a.text.startswith('ShiftRight(') or z.text.startswith('ShiftRight('):
     word=a.text if a.text.startswith('ShiftRight(') else z.text;constant=z.text if a.text.startswith('ShiftRight(') else a.text;assert constant.isdecimal();t=f'(if {word} == {constant} then 1 else 0)'
    else:t=str(v)
    stack.append(Expr(v,t))
   elif op==0x15:
    a=stack.pop();assert a.constant();stack.append(Expr(int(a.value==0)))
   elif op in {0x56,0x57}:
    dest=stack.pop()
    if dest.text=='returnPc':assert mode=='Cleanup';nxt=terminal;dests.add('returnPc')
    else:
     assert dest.constant();dests.add(dest.value);required[dest.value]=code[dest.value];assert code[dest.value]==91
     if op==0x56:nxt=dest.value
     else:
      condition=stack.pop()
      if condition.value:nxt=dest.value
   else:raise ValueError((mode,pc,op))
   pc=nxt
  return states,required,dests,[x.text for x in stack]
 call_initial=['returnPc','descriptorOffset','descriptorLength','p','limit','0','0','0','0','q']
 call=extract('SubtractCall',call_initial,14157,23784,7);class_initial=call[3][:-3]+['q-p'];assert call[3][-3:]==['14205','p','q'],call[3]
 configs=[('Cleanup',fields,5707,'returnPc',7),('SubtractCall',call_initial,14157,23784,7),('Ordinary',class_initial,14205,14279,7),('Five',class_initial,14205,14279,5),('Six',class_initial,14205,14279,6)]
 for mode,initial,start,terminal,n in configs:
  shift=216 if mode=='Five' else 208;constant=422944466291 if mode=='Five' else 126943972912743
  rawword=f'ShiftRight(DataWord(data,descriptorOffset+p),{shift})';rawflag=f'(if {rawword} == {constant} then 1 else 0)'
  def display(expr):
   if mode not in ('Five','Six'):return expr
   return expr.replace(rawflag,'Dynamic(data,descriptorOffset,p)').replace(rawword,'NameWord(data,descriptorOffset,p)')
  states,required,dests,expected=call if mode=='SubtractCall' else extract(mode,initial,start,terminal,n);cap=max(max(len(s['stack']) for s in states),len(expected));literal=lambda s:f"Running({s['pc']},prefix+[{','.join(display(x) for x in s['stack'])}],mem)";first=f"Running({start},prefix+[{','.join(initial)}],mem)";final=f"Running({terminal},prefix+[{','.join(display(x) for x in expected)}],mem)";matches=' &&\n    '.join(f'code[{i}] == {v}' for i,v in sorted(required.items()));good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';desttext=','.join(str(d) for d in sorted(d for d in dests if isinstance(d,int)))+(',returnPc' if 'returnPc' in dests else '')
  if desttext.startswith(','):desttext=desttext[1:]
  admit=f'|prefix| <= {1024-cap}'
  if mode=='Cleanup':admit+=' && returnPc < |code| && code[returnPc] == 0x5b'
  else:
   admit+=' && descriptorOffset < 0x10000000000000000 && p < q <= limit <= descriptorLength < 0x10000000000000000'
   if mode=='Ordinary':admit+=' && q-p != 5 && q-p != 6'
   elif mode=='Five':admit+=' && q-p == 5'
   elif mode=='Six':admit+=' && q-p == 6'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact {mode} named typeShape block; full parser remains open.
include "../../scans/Execution.dfy"
module BytecodeCollectionsNamedType{mode} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  import R = BytecodeScanRepresentation
  predicate Admitted(code: seq<Byte>,{params}) {{ {admit} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(returnPc: Word): set<nat> {{ {{{desttext}}} }}
  opaque predicate Good(id: nat,state: State,code: seq<Byte>,{params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
  if mode in ('Five','Six'):
   text+=f'''  opaque function NameWord(data: seq<Byte>,descriptorOffset: Word,p: Word): Word
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
  {{ ShiftRight(DataWord(data,descriptorOffset+p),{shift}) }}
  opaque function Dynamic(data: seq<Byte>,descriptorOffset: Word,p: Word): Word
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
    ensures Dynamic(data,descriptorOffset,p) <= 1
  {{ if NameWord(data,descriptorOffset,p) == {constant} then 1 else 0 }}
  lemma NameDefinition(data: seq<Byte>,descriptorOffset: Word,p: Word)
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
    ensures NameWord(data,descriptorOffset,p) == {rawword}
  {{ hide ShiftRight();reveal NameWord(); }}
  lemma DynamicDefinition(data: seq<Byte>,descriptorOffset: Word,p: Word)
    requires descriptorOffset < 0x10000000000000000 && p < 0x10000000000000000
    ensures Dynamic(data,descriptorOffset,p) == {rawflag}
  {{ hide ShiftRight();reveal Dynamic();NameDefinition(data,descriptorOffset,p); }}
'''
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,code,{args})';normalize="    hide ShiftRight();NameDefinition(data,descriptorOffset,p);DynamicDefinition(data,descriptorOffset,p);\n" if mode in ('Five','Six') else '';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   if s['op'] in (100,101):
    width=s['op']-95;bytes_=list(code[s['pc']+1:s['next']]);fetch=f"    R.WindowFits(code,{s['pc']+1},{width});\n    assert code[{s['pc']+1}..{s['next']}] == {bytes_};\n"
    for k in range(1,width+1):
     if k>1:fetch+=f"    assert {bytes_[:k]}[..{k-1}] == {bytes_[:k-1]};\n"
     fetch+=f"    assert G.Decode({bytes_[:k]}) == {int.from_bytes(bytes(bytes_[:k]),'big')};\n"
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := Step(code,Destinations(returnPc),state,value,data); {post}
  {{ hide ShiftRight();reveal Matches();reveal Good();assert state == {literal(s)};
{normalize}{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});reveal Step();
  }}
'''
  text+='''  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires E.Trace(code,destinations,value,data,left) && E.Trace(code,destinations,value,data,right) && left[|left|-1] == right[0]
    ensures E.Trace(code,destinations,value,data,left+right[1..])
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i] && (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1);assert 0 <= j < |right|-1;assert (left+right[1..])[i] == right[j] && (left+right[1..])[i+1] == right[j+1]; }
    }
  }
'''
  joins=[]
  for start_id in range(0,len(states),12):
   end=min(start_id+12,len(states));block=start_id//12;post=f'state == {final}' if end==len(states) else f'Good({end},state,code,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);var next{i} := Step(code,Destinations(returnPc),state,value,data);E.Extend(code,Destinations(returnPc),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};' for i in range(start_id,end))
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
  {{ hide ShiftRight();state := {first};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/f'{mode}.generated.dfy').write_text(text);(out/f'{mode}.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,mode=mode,states=states,requiredBytes=required,terminalPc=terminal,initialStack=initial,expectedStack=expected,scope='Exact named typeShape blocks with complete generic lower stack and unchanged memory; error, tuple, suffix, codec and public retention remain open.'),indent=2)+'\n');print(mode,len(states),'instructions',expected)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
