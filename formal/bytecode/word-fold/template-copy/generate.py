#!/usr/bin/env python3
"""Extract exact fold-loop template allocation, physical calldata copy and padding."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class Expr:
 def __init__(self,value,text=None):self.value=value;self.text=str(value) if text is None else text
 def constant(self):return self.text.isdecimal()
def generate(out):
 artifact=json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text());code=bytes.fromhex(artifact['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();pin=json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections'];assert digest==pin['runtimeSha256'] and pin['methodIdentifiers']['foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)']=='f1d88dc8' and pin['methodIdentifiers']['foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6d24e79c' and pin['methodIdentifiers']['foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)']=='6de60cb0'
 ins={};pc=0
 while pc<len(code):
  op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w],'big'));pc+=1+w
 fields=['returnPc','runPtr','sourceOffset','sourceLength','templateOffset','templateLength','arrayOffset','count']
 stack=[Expr(v,t) for v,t in zip([12157,128,164,32,228,32,292,1],fields)];pc=16426;mem='mem';states=[];required={};fp=320
 while pc!=16484:
  op,nxt,imm=ins[pc];required.update({p:code[p] for p in range(pc,nxt)});states.append(dict(id=len(states),pc=pc,op=op,next=nxt,immediate=imm,stack=[x.text for x in stack],memory=mem));assert len(states)<90
  if op==0x5b:pass
  elif op==0x5f or 96<=op<=127:stack.append(Expr(imm))
  elif 0x80<=op<=0x8f:stack.append(stack[-(op-127)])
  elif 0x90<=op<=0x9f:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1]
  elif op==0x50:stack.pop()
  elif op==0x51:
   assert stack.pop().value==64 and mem=='mem';stack.append(Expr(fp,'fp'))
  elif op==0x01:
   a,b=stack.pop(),stack.pop();texts={a.text,b.text}
   if texts=={'templateLength','31'}:t='templateLength+31'
   elif texts=={'H.Rounded(templateLength)','32'}:t='H.Rounded(templateLength)+32'
   elif texts=={'H.Rounded(templateLength)+32','fp'}:t='H.Free(fp,templateLength)'
   elif texts=={'fp','32'}:t='fp+32'
   elif texts=={'fp+32','templateLength'}:t='fp+32+templateLength'
   else:raise ValueError((pc,texts))
   stack.append(Expr((a.value+b.value)%MOD,t))
  elif op==0x04:
   a,b=stack.pop(),stack.pop();assert a.text=='templateLength+31' and b.text=='32';stack.append(Expr(a.value//b.value,'H.Quot(templateLength)'))
  elif op==0x02:
   a,b=stack.pop(),stack.pop();assert {a.text,b.text}=={'H.Quot(templateLength)','32'};stack.append(Expr(a.value*b.value,'H.Rounded(templateLength)'))
  elif op==0x52:
   a,b=stack.pop(),stack.pop()
   if pc==16453:assert a.text=='64' and b.text=='H.Free(fp,templateLength)';mem='H.Pointer(mem,fp,templateLength)'
   elif pc==16461:assert a.text=='fp' and b.text=='templateLength';mem='H.Head(mem,fp,templateLength)'
   elif pc==16476:assert a.text=='fp+32+templateLength' and b.text=='0';mem='H.Complete(mem,fp,templateOffset,templateLength,data)'
   else:raise ValueError((pc,a.text,b.text))
  elif op==0x37:
   a,b,c=stack.pop(),stack.pop(),stack.pop();assert pc==16470 and (a.text,b.text,c.text)==('fp+32','templateOffset','templateLength');mem='H.Copied(mem,fp,templateOffset,templateLength,data)'
  else:raise ValueError((pc,op))
  pc=nxt
 expected=fields+['0','fp','0'];assert [x.text for x in stack]==expected
 cap=max(max(len(x['stack']) for x in states),len(expected));params='data: seq<Byte>, mem: seq<Byte>, prefix: seq<Word>, returnPc: Word, runPtr: Word, sourceOffset: Word, sourceLength: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word, fp: Word';args='data,mem,prefix,returnPc,runPtr,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count,fp';literal=lambda s:f"Running({s['pc']},prefix+[{','.join(s['stack'])}],{s['memory']})";initial=f"Running(16426,prefix+[{','.join(fields)}],mem)";final=f"Running(16484,prefix+[{','.join(expected)}],{mem})";good='\n'.join('    '+('if' if s['id']==0 else 'else if')+f" id == {s['id']} then state == {literal(s)}" for s in states)+'\n    else false';matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
 text=f'''// SPDX-License-Identifier: MIT
// Generated actual template allocation, CALLDATACOPY and zero padding; no public retained claim.
include "../../word-apply/template-copy/Memory.dfy"
module BytecodeFoldTemplateCopy {{
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import F = BytecodeScanFetch
  import M = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import H = BytecodeApplyTemplateMemory
  predicate Admitted({params}) {{ templateLength < 0x10000000000000000 && fp < 0x20000000000000000 && 96 <= |mem| < 0x40000000000000000 && |mem|%32 == 0 && Load(mem,64) == fp && |data| < 0x10000000000000000 && (templateOffset as nat)+templateLength <= |data| && |prefix| <= {1024-cap} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{}} }}
  opaque predicate Good(id: nat,state: State,{params}) {{ Admitted({args}) && (
{good}) }}
'''
 for s in states:
  i=s['id'];post=f'next == {final}' if i==len(states)-1 else f'Good({i+1},next,{args})';fetch=f"    F.Push{s['op']-95}(code,{s['pc']});\n" if s['op'] in (96,97) else ''
  operation='    reveal M.Step();' if s['op']==0x37 else '    M.Delegate(code,Destinations(),state,value,data);\n    reveal Step();'
  text+=f'''  lemma Advance{i}(code: seq<Byte>,state: State,{params},value: Word)
    requires Matches(code) && Admitted({args}) && Good({i},state,{args})
    ensures M.Step(code,Destinations(),state,value,data) != Bad
    ensures var next := M.Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good();
    H.Arithmetic(fp,templateLength); H.Bounds(mem,fp,templateLength);
    assert state == {literal(s)};
{fetch}    assert Fetch(code,{s['pc']}) == Op({s['op']},{s['next']},{s['immediate']});
{operation}
  }}
'''
 joins=[]
 for start in range(0,len(states),20):
  end=min(start+20,len(states));block=start//20;post=f'state == {final}' if end==len(states) else f'Good({end},state,{args})';calls='\n'.join(f'    Advance{i}(code,state,{args},value);\n    var next{i} := M.Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i}); trace := trace+[next{i}]; state := next{i};' for i in range(start,end))
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
 out.mkdir(parents=True,exist_ok=True);(out/'Copy.generated.dfy').write_text(text);(out/'Copy.mapping.json').write_text(json.dumps(dict(runtimeSha256=digest,states=states,requiredBytes=required,scope='Actual fold template allocation/copy/padding only; no fold count bound; raw connection/full retained public evidence open.'),indent=2)+'\n');print(len(states),'actual template allocation/copy instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output);subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
