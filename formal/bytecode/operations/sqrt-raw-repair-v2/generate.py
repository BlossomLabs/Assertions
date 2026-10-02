#!/usr/bin/env python3
"""Generate complete complementary raw gates and both accepted sqrt prefixes."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256;SIG=int('677342ce',16)
CASES={'Nonzero':(1,0,0),'Short':(0,0,0),'Args':(0,4,0),'Early':(0,36,0),'Iterated':(0,36,2)}
GUARDS={'Nonzero':'value!=0','Short':'value==0 && size<4','Args':f'value==0 && 4<=size<36 && M.Selector(word)=={SIG}','Early':f'value==0 && 36<=size<0x10000000000000000 && M.Selector(word)=={SIG} && n<=1','Iterated':f'value==0 && 36<=size<0x10000000000000000 && M.Selector(word)=={SIG} && n>=2'}
def generate(out):
 out.mkdir(parents=True,exist_ok=True);raw=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);inv=json.loads((HERE.parent/'inventory.json').read_text());assert hashlib.sha256(raw).hexdigest()==inv['runtimeSha256'] and inv['compilerIdentity']['methodIdentifiers']['sqrt(uint256)']=='677342ce'
 ins={};pc=0
 while pc<len(raw):
  op=raw[pc];width=op-95 if 96<=op<=127 else 0;nxt=pc+1+width;ins[pc]=(op,nxt,int.from_bytes(raw[pc+1:nxt],'big'));pc=nxt
 mappings=[]
 for name,(value,size,n) in CASES.items():
  stack=[];expr=[];memory='[]';nodes=[];dests=set();pc=0;seen=set()
  def push(v,e=None):stack.append(v);expr.append(str(v) if e is None else e)
  def pop():return stack.pop(),expr.pop()
  while True:
   if (name=='Early' and pc==2984) or (name=='Iterated' and pc==11130):break
   assert (pc,tuple(stack),tuple(expr)) not in seen;seen.add((pc,tuple(stack),tuple(expr)))
   op,nxt,imm=ins[pc];before=expr[:];mem=memory;guide=''
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(imm)
   elif op==0x34:push(value,'value')
   elif op==0x36:push(size,'size')
   elif op==0x35:
    at,_=pop();assert at in [0,4];push(SIG<<224 if at==0 else n,'word' if at==0 else 'n')
   elif 128<=op<=143:k=op-127;push(stack[-k],expr[-k])
   elif 144<=op<=159:k=op-143;stack[-1],stack[-1-k]=stack[-1-k],stack[-1];expr[-1],expr[-1-k]=expr[-1-k],expr[-1]
   elif op==0x50:pop()
   elif op==0x15:
    v,e=pop();push(int(v==0),f'Bool(({e})==0)' if any(t in e for t in ['size','value','word','n']) else None)
   elif op in [1,3,16,17,18,20,28]:
    a,ae=pop();b,be=pop();actual={1:(a+b)%MOD,3:(a-b)%MOD,16:int(a<b),17:int(a>b),18:int((a if a<MOD//2 else a-MOD)<(b if b<MOD//2 else b-MOD)),20:int(a==b),28:(b>>a if a<256 else 0)}[op]
    symbolic=any(t in ae+be for t in ['size','value','word','n']);ex={1:f'((({ae}) as nat)+(({be}) as nat))%M.Modulus()',3:f'((({ae}) as nat)+M.Modulus()-(({be}) as nat))%M.Modulus()',16:f'Bool(({ae})<({be}))',17:f'Bool(({ae})>({be}))',18:f'Bool(M.Signed({ae})<M.Signed({be}))',20:f'Bool(({ae})==({be}))',28:f'M.Right({be},{ae})'}[op]
    if op==28:assert (ae,be)==('224','word');ex=str(SIG);guide='assert M.Right(word,224)==M.Selector(word);'
    push(actual,ex if symbolic else None)
   elif op==0x52:
    at,_=pop();v,e=pop();assert (at,v)==(64,128);memory='M.Store([],64,128)'
   elif op in [0x56,0x57]:
    dest,_=pop();take=op==0x56 or pop()[0]!=0;assert ins[dest][0]==0x5b;dests.add(dest)
    if take:nxt=dest
   elif op==0xfd:assert(pop()[0],pop()[0])==(0,0)
   else:raise AssertionError((name,pc,hex(op)))
   nodes.append(dict(pc=pc,opcode=op,next=ins[pc][1],immediate=imm,actualNext=nxt,stack=before,memory=mem,guide=guide));pc=nxt
   if op==0xfd:break
   assert len(nodes)<200
  terminal='M.Reverted([])' if name not in ['Early','Iterated'] else f'M.Running({pc},['+','.join(expr)+f'],{memory})'
  module='OperationsSquareRootRaw'+name
  text=f'''// SPDX-License-Identifier: MIT
// Generated complete raw square-root gate/prefix; never edit directly.
include "../sqrt-opcode-kernel/Execution.dfy"
module {module} {{
  import M = OperationsBytecodeLog2Machine
  import E = OperationsSquareRootExecution
  function Bool(value:bool): M.Word {{ if value then 1 else 0 }}
  predicate Admitted(value:M.Word,size:M.Word,word:M.Word,n:M.Word) {{ {GUARDS[name]} }}
  predicate Matches(code:seq<M.Byte>) {{
'''
  text+='    '+' &&\n    '.join(f'{s["pc"]}<|code| && M.Fetch(code,{s["pc"]})==M.Op({s["opcode"]},{s["next"]},{s["immediate"]})' for s in nodes)
  if dests:text+=' &&\n    '+' &&\n    '.join(f'{d}<|code| && code[{d}]==0x5b' for d in sorted(dests))
  text+='\n  }\n  opaque predicate Good(id:nat,state:M.State,value:M.Word,size:M.Word,word:M.Word,n:M.Word) {\n'
  for i,s in enumerate(nodes):text+=f'    {"if" if i==0 else "else if"} id=={i} then state==M.Running({s["pc"]},['+','.join(s['stack'])+f'],{s["memory"]})\n'
  text+=f'    else if id=={len(nodes)} then state=={terminal}\n    else false\n  }}\n'
  for i,s in enumerate(nodes):text+=f'''  lemma Advance{i}(code:seq<M.Byte>,destinations:set<nat>,state:M.State,value:M.Word,size:M.Word,word:M.Word,n:M.Word)
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Admitted(value,size,word,n) && Good({i},state,value,size,word,n)
    ensures Good({i+1},E.Execute(code,destinations,state,value,size,word,n),value,size,word,n)
  {{ {s['guide']} reveal Good();reveal E.Execute();reveal M.Step(); }}
'''
  text+='''  lemma Extend(code:seq<M.Byte>,destinations:set<nat>,trace:seq<M.State>,state:M.State,value:M.Word,size:M.Word,word:M.Word,n:M.Word)
    requires |trace|>0 && trace[|trace|-1]==state
    requires forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,n)
    ensures forall j:nat :: j+1<|trace+[E.Execute(code,destinations,state,value,size,word,n)]| ==>
      (trace+[E.Execute(code,destinations,state,value,size,word,n)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,n)])[j],value,size,word,n)
  {
    forall j:nat | j+1<|trace+[E.Execute(code,destinations,state,value,size,word,n)]|
      ensures (trace+[E.Execute(code,destinations,state,value,size,word,n)])[j+1]==E.Execute(code,destinations,(trace+[E.Execute(code,destinations,state,value,size,word,n)])[j],value,size,word,n)
    { if j+1<|trace| {} else { assert j+1==|trace|; assert trace[j]==state; } }
  }
'''
  text+=f'''  lemma Start(value:M.Word,size:M.Word,word:M.Word,n:M.Word)
    ensures Good(0,M.Running(0,[],[]),value,size,word,n)
  {{ reveal Good(); }}
  method Run(code:seq<M.Byte>,destinations:set<nat>,value:M.Word,size:M.Word,word:M.Word,n:M.Word)
    returns(state:M.State,trace:seq<M.State>)
    requires Matches(code) && {{{','.join(map(str,sorted(dests)))}}}<=destinations && Admitted(value,size,word,n)
    ensures state=={terminal}
    ensures |trace|=={len(nodes)+1} && trace[0]==M.Running(0,[],[]) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==E.Execute(code,destinations,trace[j],value,size,word,n)
  {{
    state:=M.Running(0,[],[]);trace:=[state];Start(value,size,word,n);
'''
  for i in range(len(nodes)):text+=f'    Advance{i}(code,destinations,state,value,size,word,n);Extend(code,destinations,trace,state,value,size,word,n);state:=E.Execute(code,destinations,state,value,size,word,n);trace:=trace+[state];assert |trace|=={i+2};assert trace[0]==M.Running(0,[],[]);assert trace[|trace|-1]==state;\n'
  text+='    reveal Good();\n  }\n}\n';(out/(name+'.generated.dfy')).write_text(text);mappings.append(dict(name=name,start=0,states=nodes,terminal=terminal,destinations=sorted(dests)))
 (out/'raw.mapping.json').write_text(json.dumps(dict(runtimeSha256=hashlib.sha256(raw).hexdigest(),selector='677342ce',paths=mappings),indent=2)+'\n');print('Generated five raw gates/prefixes:',sum(len(x['states']) for x in mappings),'instructions')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
