#!/usr/bin/env python3
"""Generate all60 exact compiled successful-body instructions; no proof credit."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];M=1<<256
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--runtime',type=Path);args=p.parse_args();out=args.output;out.mkdir(parents=True,exist_ok=True)
artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());code=args.runtime.read_bytes() if args.runtime else bytes.fromhex(artifact['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert args.runtime or hashlib.sha256(code).hexdigest()==inv['runtimeSha256'];assert inv['compilerIdentity']['methodIdentifiers']['hash(bytes)']=='aa1e84de'
ins={};pc=0
while pc<len(code):
 op=code[pc];width=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+width+1,int.from_bytes(code[pc+1:pc+width+1],'big'));pc+=width+1
pc=7568;stack=[int('aa1e84de',16),1329,68,2];expr=[str(stack[0]),'1329','source','count'];memory='K.Initial()';nodes=[];needed={};dests=set();seen=set()
def pop():return stack.pop(),expr.pop()
def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
while True:
 assert pc in ins and (pc,tuple(stack)) not in seen;seen.add((pc,tuple(stack)));op,nxt,imm=ins[pc];needed.update({i:code[i] for i in range(pc,nxt)})
 n=dict(id=len(nodes),pc=pc,next=nxt,opcode=op,immediate=imm,stack=expr.copy(),memory=memory);nodes.append(n)
 if op==0x5f or 96<=op<=127:push(imm)
 elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k])
 elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
 elif op==0x50:pop()
 elif op==0x51:
  at,ae=pop();assert at==64;push(128);n['load']=True
 elif op in [0x01,0x03]:
  a,ae=pop();b,be=pop();v=(a+b)%M if op==1 else (a-b)%M
  symbolic=any(t in ae+be for t in ['source','count','result'])
  expression=f'((({ae}) as nat)+(({be}) as nat))%Modulus()' if op==1 else f'((({ae}) as nat)+Modulus()-(({be}) as nat))%Modulus()'
  if pc==20054:expression='128+(count as nat)';n['countAdd']=True
  if pc==7591:expression='count';n['countSub']=True
  push(v,expression if symbolic else None)
 elif op==0x37:
  target,te=pop();source,se=pop();count,ce=pop();assert(target,source,count)==(128,68,2);memory='K.Copied(data,source,count)';n['copy']=True
 elif op==0x52:
  at,ae=pop();v,ve=pop();n['store']=[ae,ve]
  if pc==20057:assert(at,v)==(130,0);memory='K.Cleared(data,source,count)'
  elif pc==1335:assert at==128;memory=f'K.Finished(data,source,count,{ve})';written=ve
  else:raise ValueError((pc,at))
 elif op==0x20:
  offset,oe=pop();count,ce=pop();assert(offset,count)==(128,2);push(1234567,'result');n['hash']=True
 elif op==0x5b:pass
 elif op==0x56:
  dest,de=pop();assert ins[dest][0]==0x5b;needed[dest]=code[dest];dests.add(dest);n['jump']=dest;nxt=dest
 elif op==0xf3:
  offset,oe=pop();count,ce=pop();assert(offset,count)==(128,32);n['returned']=True;break
 else:raise ValueError((pc,hex(op)))
 pc=nxt
assert len(nodes)==60
maximum=max(len(n["stack"]) for n in nodes)
constraints=' &&\n    '.join(f'code[{i}]=={v}' for i,v in sorted(needed.items()));good='\n'.join(('    if' if n['id']==0 else '    else if')+f' id=={n["id"]} then state==Running({n["pc"]},[{",".join(n["stack"])}],{n["memory"]})' for n in nodes)+'\n    else false'
head='// SPDX-License-Identifier: MIT\n// Generated complete exact successful hash body; never edit directly.\ninclude "Kernel.dfy"\n'
imports='  import opened OperationsHashBytesMachine\n  import E = OperationsHashBytesExecution\n  import K = OperationsHashSuccessKernel\n'
params='code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>'
passed='code,state,data,source,count,result,hashes'
state=head+'module OperationsHashSuccessState {\n'+imports+f'''  opaque predicate Matches(code: seq<Byte>) {{ |code|=={len(code)} &&
    {constraints}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(dests)))}}} }}
  opaque predicate Good(id: nat,state: State,data: seq<Byte>,source: Word,count: Word,result: Word)
    requires count<0x10000000000000000
  {{
{good}
  }}
}}
''';(out/'State.generated.dfy').write_text(state)
entryIncludes=['include "State.generated.dfy"'];entryImports=imports+'  import opened OperationsHashSuccessState\n';blockCalls=[]
for low in range(0,len(nodes),20):
 high=min(low+20,len(nodes));label='Block'+str(low//20);module='OperationsHashSuccess'+label
 text=head+'include "State.generated.dfy"\ninclude "Opcodes.dfy"\nmodule '+module+' {\n'+imports+'  import opened OperationsHashSuccessState\n  import O = OperationsHashSuccessOpcodes\n'
 for n in nodes[low:high]:
  i=n['id'];post='next==Returned(Encode(result,32))' if n.get('returned') else f'Good({i+1},next,data,source,count,result)'
  guide=f'    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();\n    K.Heaps(data,source,count,result);\n    assert state==Running({n["pc"]},[{",".join(n["stack"])}],{n["memory"]});\n'
  if 96<=n['opcode']<=127:
   for width in range(1,n['opcode']-95+1):guide+=f'    assert code[{n["pc"]+width}]=={code[n["pc"]+width]};\n'
  guide+=f'    assert Fetch(code,{n["pc"]})==Op({n["opcode"]},{n["next"]},{n["immediate"]});\n'
  if n.get('load'):guide+=f'    O.LoadMemory(code,Destinations(),data,hashes,{n["pc"]},[{",".join(n["stack"][:-1])}],{n["memory"]});\n'
  if n.get('jump'):guide+=f'    O.Jump(code,Destinations(),data,hashes,{n["pc"]},[{",".join(n["stack"][:-1])}],{n["jump"]},{n["memory"]});\n'
  if n.get('copy'):guide+=f'    E.CopyOpcode(code,Destinations(),K.Initial(),data,0,0,hashes,{n["pc"]},[{",".join(n["stack"][:-3])}],128,source,count);\n'
  if n.get('hash'):guide+=f'    K.Payload(data,source,count,result,hashes);\n    E.HashOpcode(code,Destinations(),K.Cleared(data,source,count),data,0,0,hashes,{n["pc"]},[{",".join(n["stack"][:-2])}],128,count);\n'
  if n.get('jump'):guide+=f'    assert {n["jump"]} in Destinations() && code[{n["jump"]}]==0x5b;\n'
  if n.get('returned'):guide+=f'    K.Receipt(data,source,count,{written});\n'
  if n.get('load') and n['pc']==7574:guide='    O.LoadState(code,state,data,source,count,result,hashes);\n'
  text+=f'''  lemma Advance{i}({params})
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good({i},state,data,source,count,result)
    ensures state.Running? && |state.stack|<={maximum}
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); {post}
  {{
{guide}  }}
'''
 calls='\n'.join(f'    Advance{i}({passed});\n    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);' for i in range(low,high));post='state==Returned(Encode(result,32))' if high==len(nodes) else f'Good({high},state,data,source,count,result)'
 text+=f'''  ghost method RunBlock({params.replace('state: State','initial: State')}) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good({low},initial,data,source,count,result)
    ensures {post}
  {{ state:=initial;
{calls}
  }}
}}
''';(out/(label+'.generated.dfy')).write_text(text);entryIncludes.append('include "'+label+'.generated.dfy"');entryImports+='  import B'+str(low//20)+' = '+module+'\n';blockCalls.append('    state:=B'+str(low//20)+'.RunBlock('+passed+');')
checkpoint=next(n for n in nodes if n['pc']==1335)
semantic=f'''  lemma SemanticResult({params})
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good({checkpoint['id']},state,data,source,count,result)
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==result
  {{ reveal Good(); }}
  lemma SemanticWitness({params})
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good({checkpoint['id']},state,data,source,count,result)
    requires count==2 && result==0xbc07f95faa953d0c799ffc75a8afda081bafda1396ac3ec9ba52784dccf67316
    requires data[source..(source as nat)+(count as nat)]==[165,165]
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==result
  {{ reveal Good(); }}
'''
entry=head+'\n'.join(entryIncludes)+'\nmodule OperationsHashSuccessEntry {\n'+entryImports+semantic+f'''  ghost method Run({params.replace('state: State,','')},initial: State) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes)
    requires initial==Running(7568,[2854126814,1329,source,count],K.Initial())
    ensures state==Returned(Encode(result,32))
  {{
    reveal Good(); state:=initial;
    assert Good(0,state,data,source,count,result);
{chr(10).join(blockCalls)}
  }}
}}
''';(out/'Entry.generated.dfy').write_text(entry);(out/'body.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(code).hexdigest(),states=nodes,requiredBytes=needed,startPc=7568,totalInstructions=len(nodes),scope='Unverified body-only complete actual instruction certificate; raw decoder and public entry remain open'),indent=2)+'\n');print('Generated',len(nodes),'complete body instructions')
