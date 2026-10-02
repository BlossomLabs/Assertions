#!/usr/bin/env python3
"""Extract exact unpack ArrayState six-word zero allocation and shape invocation."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['unpackArray(string,bytes)']=='cb533ade'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','descriptorOffset','descriptorLength','encodedPointer']
 stack=[Expr(v,t) for v,t in zip([5704,100,5,128],fields)];pc=12814;mem='mem';states=[];required={};fp=608;zeroCount=0
 while pc!=9893:
  op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem));assert len(states)<90
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x15:
   a=stack.pop();assert a.constant();stack.append(Expr(1 if a.value==0 else 0))
  elif op==0x51:
   assert stack.pop().value==64 and mem=='mem';stack.append(Expr(fp,'fp'))
  elif op==0x01:
   a,b=stack.pop(),stack.pop();base=a if not a.constant() else b;add=b if base is a else a;assert add.constant() and base.text.startswith('fp');v=base.value+add.value;stack.append(Expr(v,'fp+'+str(v-fp)))
  elif op==0x52:
   a,b=stack.pop(),stack.pop()
   if pc==12829:assert a.text=='64' and b.text=='fp+192';mem='H.Pointer(mem,fp)'
   else:
    assert b.text=='0' and a.value==fp+32*zeroCount;zeroCount+=1;mem='H.Zero(mem,fp,'+str(zeroCount)+')'
  elif op==0x56:
   dest=stack.pop();assert dest.constant() and dest.value in (12869,9893);required[dest.value]=code[dest.value];assert code[dest.value]==0x5b;nxt=dest.value
  else:raise ValueError((pc,op))
  pc=nxt
 expected=fields+['96','fp','12879','descriptorOffset','descriptorLength'];assert [x.text for x in stack]==expected and zeroCount==6, [x.text for x in stack]
 cap=max(max(len(x['stack']) for x in states),len(expected));params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, descriptorOffset: Word, descriptorLength: Word, encodedPointer: Word, fp: Word';args='data,mem,prefix,returnPc,descriptorOffset,descriptorLength,encodedPointer,fp';literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";initial=f"Running(12814,prefix+[{','.join(fields)}],mem)";final=f"Running(9893,prefix+[{','.join(expected)}],{mem})";good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 text=f'''// SPDX-License-Identifier: MIT
// Generated actual unpack ArrayState six-word allocation and descriptor shape call; no public retained claim.
include "Memory.dfy"
include "../../scans/Execution.dfy"
include "../../scans/Fetch.dfy"
module BytecodeCollectionsUnpackShapeInvocation {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import H = BytecodeCollectionsArrayStateMemory
  predicate Admitted({params}) {{ fp < 0x40000000000000000 && 96 <= |mem| < 0x80000000000000000 && |mem|%32 == 0 && H.LoadAt64(mem,fp) && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{12869,9893}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
  operation='    reveal Step();'
  text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures Step(code,Destinations(),state,value,data) != Bad
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
    H.Arithmetic(mem,fp);
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{operation}
  }}
'''
 joins=[]
 for start in range(0,len(states),20):
  end=min(start+20,len(states));block=start//20;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
  text+=f'''  ghost method Block{block}(code: seq<Byte>,initial: State,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args}) && Good({start},initial,{args})
    ensures {post} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {end-start+1} && trace[0] == initial && trace[|trace|-1] == state
  {{ state := initial; trace := [state];
{calls}
  }}
'''
  joins.append(f'    state,part := Block{block}(code,state,{args},value);\n    E.Join(code,Destinations(),value,data,trace,part); trace := trace+part[1..];')
 text+=f'''  ghost method Run(code: seq<Byte>,{params},value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted({args})
    ensures state == {final} && E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == {initial} && trace[|trace|-1] == state
  {{
    state := {initial}; trace := [state]; reveal Good();
    var part: seq<State>;
'''+ '\n'.join(joins)+'\n  }\n}\n'
 out.mkdir(parents=True,exist_ok=True);(out/'Invocation.generated.dfy').write_text(text);(out/'Invocation.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,scope='Actual unpackArray six-word zero state allocation and descriptor shape call only. Descriptor parser, canonical element loops/errors/serialization and full retained public evidence remain open.'),indent=2)+'\n');print(len(states),'actual state allocation/shape invocation instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
