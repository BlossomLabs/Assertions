#!/usr/bin/env python3
"""Exact four array suffix rejection guards through complete error REVERT."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value)if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256'];ins={};pc=0
 while pc<len(code):
  op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+width,int.from_bytes(code[pc+1:pc+1+width],'big'));pc+=1+width
 fields=['returnPc','descriptorOffset','descriptorLength','p','limit','end','dyn','words','q','k'];params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, end: Word, dyn: Word, words: Word, q: Word, k: Word, b: Byte, fp: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,end,dyn,words,q,k,b,fp'
 modes=[('AtLimit',80,2,3,0),('WrongClose',32,2,3,65),('Wide',32,2,0x100000000,93),('Zero',32,0,0,93)]
 for mode,q,k,words,b in modes:
  values=dict(returnPc=9908,descriptorOffset=100,descriptorLength=80,p=10,limit=80,end=30,dyn=0,words=words,q=q,k=k,b=b,fp=160);stack=[Expr(values[f],f)for f in fields];pc=14481;states=[];required={};dests=set();memory='mem';small=1295247507;header=small<<225
  while True:
   op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=memory));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<150
   if op==91:pass
   elif op==95 or 96<=op<=127:stack.append(Expr(imm))
   elif 128<=op<=143:stack.append(stack[-(op-127)])
   elif 144<=op<=159:j=op-143;stack[-1],stack[-1-j]=stack[-1-j],stack[-1]
   elif op==80:stack.pop()
   elif op in(1,3):
    a,z=stack.pop(),stack.pop();v=(a.value+z.value if op==1 else a.value-z.value)%MOD
    if a.constant()and z.constant():text=str(v)
    elif op==1 and {a.text,z.text}=={'descriptorOffset','q'}:text='descriptorOffset+q'
    elif op==1 and {a.text,z.text}=={'end','1'}:text='end+1'
    elif op==1 and {a.text,z.text}=={'fp','4'}:text='fp+4'
    elif op==1 and {a.text,z.text}=={'fp','36'}:text='fp+36'
    elif op==3 and a.text=='fp+36'and z.text=='fp':text='36'
    else:raise ValueError((mode,pc,op,a.text,z.text))
    stack.append(Expr(v,text))
   elif op==0x35:
    a=stack.pop();assert a.text=='descriptorOffset+q';stack.append(Expr(0,'DataWord(data,descriptorOffset+q)'))
   elif op==0x1a:
    a,z=stack.pop(),stack.pop();assert a.text=='0'and z.text=='DataWord(data,descriptorOffset+q)';stack.append(Expr(b,'b'))
   elif op==0x17:
    a,z=stack.pop(),stack.pop();assert {a.text,z.text}=={'k','words'};stack.append(Expr(a.value|z.value,'G.BitOr('+a.text+','+z.text+')'))
   elif op in(0x10,0x11,0x14):
    a,z=stack.pop(),stack.pop();v=int(a.value<z.value if op==0x10 else a.value>z.value if op==0x11 else a.value==z.value);stack.append(Expr(v))
   elif op==0x15:stack.append(Expr(int(stack.pop().value==0)))
   elif op==27:
    a,z=stack.pop(),stack.pop();assert a.constant()and z.constant()and a.value==225 and z.value==small;stack.append(Expr(header))
   elif op==81:
    a=stack.pop();assert a.value==64;stack.append(Expr(values['fp'],'fp'))
   elif op==82:
    off,datum=stack.pop(),stack.pop()
    if off.text=='fp'and datum.value==header:assert memory=='mem';memory='H.First(mem,fp)'
    else:assert off.text=='fp+4'and datum.text=='q'and memory=='H.First(mem,fp)';memory='H.Complete(mem,fp,q)'
   elif op in(86,87):
    dest=stack.pop();assert dest.constant();dests.add(dest.value);required[dest.value]=code[dest.value];assert code[dest.value]==91
    if op==86 or stack.pop().value:nxt=dest.value
   elif op==253:
    off,size=stack.pop(),stack.pop();assert off.text=='fp'and size.value==36 and memory=='H.Complete(mem,fp,q)';break
   else:raise ValueError((mode,pc,op))
   pc=nxt
  cap=max(len(s['stack'])for s in states);literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";first=literal(states[0]);final='Reverted(H.Bytes(q))';matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()));good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false'
  admit=f'|prefix| <= {1024-cap} && descriptorOffset < 0x10000000000000000 && end < q < 0x10000000000000000 && limit <= descriptorLength < 0x10000000000000000 && |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp'
  if mode=='AtLimit':admit+=' && q >= limit'
  else:
   admit+=' && q < limit && b == B.ByteWord(0,DataWord(data,descriptorOffset+q))'
   if mode=='WrongClose':admit+=' && b != 93'
   elif mode=='Wide':admit+=' && b == 93 && (k > 0xffffffff || words > 0xffffffff)'
   else:admit+=' && b == 93 && k == 0 && words <= 0xffffffff && q != end+1'
  text=f'''// SPDX-License-Identifier: MIT
// Generated exact {mode} suffix guard through complete InvalidTypeDescriptor(q).
include "../parser-execution/Execution.dfy"
include "../../scans/Push.dfy"
include "../descriptor-error-foundation/Scalar.dfy"
include "Scalar.dfy"
module BytecodeCollectionsSuffixRejection{mode} {{
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeCollectionsDescriptorErrorMemory
  import SC = BytecodeCollectionsDescriptorErrorScalar
  import W = BytecodeCollectionsArrayWordBound
  import SW = BytecodeCollectionsSuffixRejectionScalar
  predicate Admitted(code: seq<Byte>,{params}) {{ {admit} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  opaque predicate Good(id: nat,state: State,code: seq<Byte>,{params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
  for state in states:
   i=state['id'];post=f'next == {final}'if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f"    F.Push{state['op']-95}(code,{state['pc']});\n"if state['op']in(96,97)else f"    P.Push4(code,{state['pc']});\n"if state['op']==99 else '';facts='    SC.Selector();\n'if state['op']==27 else '';facts+=('    SW.OrWide(words,k);\n'if mode=='Wide'else'    W.OrBound(words,k);\n'if mode=='Zero'else'')
   step='    reveal B.Step();'if state['op']==0x1a else'    B.Delegate(code,Destinations(),state,value,data);C.Delegate(code,Destinations(),state,value,data);reveal S.Step();'
   text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures B.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := B.Step(code,Destinations(),state,value,data); {post}
  {{ hide G.BitOr();reveal Matches();reveal Good();H.Frames(mem,fp,q);assert state == {literal(state)};
{fetch}{facts}    assert Fetch(code,{state['pc']}) == Op({state['op']},{state['next']},{state['immediate']});
{step}
  }}
'''
  joins=[]
  for start in range(0,len(states),12):
   stop=min(start+12,len(states));block=start//12;post=f'state == {final}'if stop==len(states)else f'Good({stop},state,code,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);var next{i} := B.Step(code,Destinations(),state,value,data);E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};'for i in range(start,stop))
   text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args}) && Good({start},initial,code,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {stop-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ hide G.BitOr();state := initial;trace := [state];
{calls}
  }}
''';joins.append(f'    state,part := Block{block}(code,state,{args},value);X.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
  text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {first} && trace[|trace|-1] == state
  {{ hide G.BitOr();state := {first};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
  out.mkdir(parents=True,exist_ok=True);(out/(mode+'.generated.dfy')).write_text(text);(out/(mode+'.mapping.json')).write_text(json.dumps(dict(runtimeSha256=digest,mode=mode,states=states,requiredBytes=required,errorSelector=hex(header>>224)[2:],initialStack=fields,scope='Complete exact suffix guards after actual footprint calculation through InvalidTypeDescriptor(q) REVERT; deriving preceding footprint/recursive parser caller admission and complete native retained codec closure remains open.'),indent=2)+'\n');print(mode,len(states),'complete rejection instructions')
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);a=ap.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated-consolidated-v24.py','--output',a.output,'--include-root',HERE],check=True)
