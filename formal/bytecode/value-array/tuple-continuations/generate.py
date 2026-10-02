#!/usr/bin/env python3
"""Exact tuple child continuations through actual checked addition and next call or suffix entry."""
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
 fields=['returnPc','descriptorOffset','descriptorLength','p','limit','0','parentDyn','0','q','sum','0','0','0','e','childDyn','childWords']
 params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, parentDyn: Word, q: Word, sum: Word, e: Word, childDyn: Word, childWords: Word, b: Byte';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,parentDyn,q,sum,e,childDyn,childWords,b'
 def extract(mode,initial,start,terminal,n):
  parent=1 if mode=='CloseParentDynamic' else 0;child=1 if mode in ['CommaDynamic','CloseChildDynamic'] else 0;ch=44 if mode.startswith('Comma') else 41
  values=dict(returnPc=9908,descriptorOffset=100,descriptorLength=80,p=0,limit=80,parentDyn=parent,q=4,sum=3,e=7,childDyn=child,childWords=2,b=ch);stack=[Expr(int(t)if t.isdecimal()else values[t],t)for t in initial];pc=start;states=[];required={};dests=set()
  while pc!=terminal:
   op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack]));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<180
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
   elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
   elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
   elif op==0x50:stack.pop()
   elif op==1:
    a,z=stack.pop(),stack.pop();v=(a.value+z.value)%MOD;pair={a.text,z.text}
    if pair=={'sum','childWords'}:t='sum+childWords'
    elif pair=={'descriptorOffset','e'}:t='descriptorOffset+e'
    elif pair=={'e','1'}:t='e+1'
    elif 'G.Modulus()-44'in pair:t='((G.Modulus()-44+b)%G.Modulus())'
    elif 'G.Modulus()-41'in pair:t='((G.Modulus()-41+G.BitAnd(255,b))%G.Modulus())'
    else:raise ValueError((mode,pc,pair))
    stack.append(Expr(v,t))
   elif op==0x35:
    a=stack.pop();assert a.text=='descriptorOffset+e';stack.append(Expr(0,'DataWord(data,descriptorOffset+e)'))
   elif op==0x1a:
    a,z=stack.pop(),stack.pop();assert a.text=='0';stack.append(Expr(ch,'b'))
   elif op==0x19:
    a=stack.pop();assert a.text in ['43','40'];stack.append(Expr(MOD-a.value-1,'G.Modulus()-'+str(a.value+1)))
   elif op==0x16:
    a,z=stack.pop(),stack.pop();assert {a.text,z.text}=={'255','b'};stack.append(Expr(a.value&z.value,'G.BitAnd('+a.text+','+z.text+')'))
   elif op in {0x10,0x11,0x14}:
    a,z=stack.pop(),stack.pop();stack.append(Expr(int(a.value<z.value if op==0x10 else a.value>z.value if op==0x11 else a.value==z.value)))
   elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
   elif op in {0x56,0x57}:
    dest=stack.pop();assert dest.constant();dests.add(dest.value);required[dest.value]=code[dest.value];assert code[dest.value]==91
    if op==0x56 or stack.pop().value:nxt=dest.value
   else:raise ValueError((mode,pc,op))
   pc=nxt
  return states,required,dests,[x.text for x in stack]
 configs=[(mode,fields,13958,13839 if mode.startswith('Comma')else 14279,0)for mode in ['CommaStatic','CommaDynamic','CloseStatic','CloseParentDynamic','CloseChildDynamic']]
 for mode,initial,start,terminal,n in configs:
  states,required,dests,expected=extract(mode,initial,start,terminal,n);cap=max(max(len(s['stack']) for s in states),len(expected));literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],mem)";first=f"Running({start},prefix+[{','.join(initial)}],mem)";final=f"Running({terminal},prefix+[{','.join(expected)}],mem)";matches=' &&\n    '.join(f'code[{i}] == {v}' for i,v in sorted(required.items()));good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';desttext=','.join(str(d) for d in sorted(d for d in dests if isinstance(d,int)))+(',returnPc' if 'returnPc' in dests else '')
  if desttext.startswith(','):desttext=desttext[1:]
  admit=f'|prefix| <= {1024-cap}'
  admit+=' && descriptorOffset < 0x10000000000000000 && p < q <= e < limit <= descriptorLength < 0x10000000000000000 && parentDyn <= 1 && childDyn <= 1 && childWords >= 1 && sum+childWords < G.Modulus() && b == B.ByteWord(0,DataWord(data,descriptorOffset+e))'
  if mode.startswith('Comma'):admit+=' && b == 44 && childDyn == '+('0'if mode=='CommaStatic'else'1')
  else:
   admit+=' && b == 41'
   if mode=='CloseStatic':admit+=' && parentDyn == 0 && childDyn == 0'
   elif mode=='CloseParentDynamic':admit+=' && parentDyn == 1 && childDyn == 0'
   else:admit+=' && childDyn == 1'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact {mode} tuple continuation block; full parser remains open.
include "../byte-machine/Execution.dfy"
include "../checked-byte-subtract/Scalar.dfy"
module BytecodeCollectionsTuple{mode} {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import BS = BytecodeCollectionsCheckedByteSubtractScalar
  import E = BytecodeCollectionsArrayByteExecution
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
  text+='''  lemma Character(b: Byte)
    requires b == 41 || b == 44
    ensures BitNot(43) == G.Modulus()-44 && BitNot(40) == G.Modulus()-41
    ensures (G.Modulus()-44+b)%G.Modulus() == (if b == 44 then 0 else G.Modulus()-3)
    ensures b == 41 ==> (G.Modulus()-41+b)%G.Modulus() == 0
  {}
'''
  for s in states:
   i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
   if s['op'] in (100,101):
    width=s['op']-95;bytes_=list(code[s['pc']+1:s['next']]);fetch=f"    R.WindowFits(code,{s['pc']+1},{width});\n    assert code[{s['pc']+1}..{s['next']}] == {bytes_};\n"
    for k in range(1,width+1):
     fetch+=f"    assert {bytes_[:k]}[..{k-1}] == {bytes_[:k-1]};\n"
     fetch+=f"    assert G.Decode({bytes_[:k]}) == {int.from_bytes(bytes(bytes_[:k]),'big')};\n"
   step='reveal B.Step();'if s['op']==0x1a else 'B.Delegate(code,Destinations(returnPc),state,value,data);C.Delegate(code,Destinations(returnPc),state,value,data);reveal S.Step();'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures B.Step(code,Destinations(returnPc),state,value,data) != Bad
    ensures var next := B.Step(code,Destinations(returnPc),state,value,data); {post}
  {{ reveal Matches();reveal Good();Character(b);BS.Canonical(b);BS.Reverse(b);BS.ByteIdentity(b);assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});{step}
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
  out.mkdir(parents=True,exist_ok=True);(out/f'{mode}.generated.dfy').write_text(text);(out/f'{mode}.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,mode=mode,states=states,requiredBytes=required,terminalPc=terminal,initialStack=initial,expectedStack=expected,scope='Exact tuple continuation blocks with complete generic lower stack and unchanged memory; error, tuple, suffix, codec and public retention remain open.'),indent=2)+'\n');print(mode,len(states),'instructions',expected)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
