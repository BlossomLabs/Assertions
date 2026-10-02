#!/usr/bin/env python3
"""Actual empty-name rejection from scanner return through complete error REVERT."""
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
 params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, p: Word, limit: Word, fp: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,p,limit,fp'
 initial=['returnPc','descriptorOffset','descriptorLength','p','limit','0','0','0','0','p'];values=dict(returnPc=9908,descriptorOffset=100,descriptorLength=8,p=2,limit=8,fp=160)
 stack=[Expr(int(x)if x.isdecimal()else values[x],x)for x in initial];pc=14157;states=[];required={};dests=set();memory='mem';small=1295247507;header=small<<225
 while True:
  op,nxt,imm=ins[pc];states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=memory));required.update({i:code[i]for i in range(pc,nxt)});assert len(states)<70
  if op==91:pass
  elif op==95 or 96<=op<=127:stack.append(Expr(imm))
  elif 128<=op<=143:stack.append(stack[-(op-127)])
  elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==80:stack.pop()
  elif op in (1,3):
   a,z=stack.pop(),stack.pop();v=(a.value+z.value if op==1 else a.value-z.value)%MOD
   if a.constant()and z.constant():t=str(v)
   elif op==3 and a.text==z.text:t='0'
   elif op==1 and {a.text,z.text}=={'fp','4'}:t='fp+4'
   elif op==1 and {a.text,z.text}=={'fp','36'}:t='fp+36'
   elif op==3 and a.text=='fp+36'and z.text=='fp':t='36'
   else:raise ValueError((pc,op,a.text,z.text))
   stack.append(Expr(v,t))
  elif op==27:
   a,z=stack.pop(),stack.pop();assert a.constant()and z.constant()and a.value==225 and z.value==small;stack.append(Expr(header))
  elif op==81:
   a=stack.pop();assert a.value==64;stack.append(Expr(values['fp'],'fp'))
  elif op==82:
   off,datum=stack.pop(),stack.pop()
   if off.text=='fp'and datum.value==header:assert memory=='mem';memory='H.First(mem,fp)'
   else:assert off.text=='fp+4'and datum.text=='p'and memory=='H.First(mem,fp)';memory='H.Complete(mem,fp,p)'
  elif op in(86,87):
   dest=stack.pop();assert dest.constant();dests.add(dest.value);required[dest.value]=code[dest.value];assert code[dest.value]==91
   if op==86 or stack.pop().value:nxt=dest.value
  elif op==253:
   off,size=stack.pop(),stack.pop();assert off.text=='fp'and size.value==36 and memory=='H.Complete(mem,fp,p)';break
  else:raise ValueError((pc,op))
  pc=nxt
 cap=max(len(s['stack'])for s in states);literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";first=literal(states[0]);final='Reverted(H.Bytes(p))';matches=' &&\n    '.join(f'code[{i}] == {v}'for i,v in sorted(required.items()));good='\n'.join('    '+('if'if s['id']==0 else'else if')+f" id == {s['id']} then state == {literal(s)}"for s in states)+'\n    else false'
 text=f'''// SPDX-License-Identifier: MIT
// Generated exact empty-name path to complete InvalidTypeDescriptor(p) REVERT.
include "../../scans/Execution.dfy"
include "../../scans/Push.dfy"
include "Scalar.dfy"
module BytecodeCollectionsDescriptorNameEmpty {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import F = BytecodeScanFetch
  import P = BytecodeScanPush
  import H = BytecodeCollectionsDescriptorErrorMemory
  import SC = BytecodeCollectionsDescriptorErrorScalar
  predicate Admitted(code: seq<Byte>,{params}) {{ |prefix| <= {1024-cap} && |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} && {matches} }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  opaque predicate Good(id: nat,state: State,code: seq<Byte>,{params}) {{ Admitted(code,{args}) && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}'if i==len(states)-1 else f'Good({i+1},next,code,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n"if s['op']in(96,97)else f"    P.Push4(code,{s['pc']});\n"if s['op']==99 else '';facts='    SC.Selector();\n'if s['op']==27 else ''
  text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted(code,{args}) && Good({i},state,code,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{ reveal Matches();reveal Good();H.Frames(mem,fp,p);assert state == {literal(s)};
{fetch}{facts}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});reveal Step();
  }}
'''
 joins=[]
 for start in range(0,len(states),12):
  end=min(start+12,len(states));block=start//12;post=f'state == {final}'if end==len(states)else f'Good({end},state,code,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);var next{i} := Step(code,Destinations(),state,value,data);E.Extend(code,Destinations(),value,data,trace,next{i});trace := trace+[next{i}];state := next{i};'for i in range(start,end))
  text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args}) && Good({start},initial,code,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial;trace := [state];
{calls}
  }}
''';joins.append(f'    state,part := Block{block}(code,state,{args},value);E.Join(code,Destinations(),value,data,trace,part);trace := trace+part[1..];')
 text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(code,{args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {first} && trace[|trace|-1] == state
  {{ state := {first};trace := [state];reveal Good();var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
 out.mkdir(parents=True,exist_ok=True);(out/'NameEmpty.generated.dfy').write_text(text);(out/'NameEmpty.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,errorSelector=hex(header>>224)[2:],scope='Full actual empty-name rejection from q=p scanner return, generic complete lower frame and aligned fitting free memory, exact complete error packet; universal preceding scanner/public rejection connection remains open.'),indent=2)+'\n');print(len(states),'complete physical empty-name rejection instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
