#!/usr/bin/env python3
"""Reached symbolic certificates for actual uniqueWords helper calls."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];MOD=1<<256
class E:
 def __init__(self,v,t=None):self.v=v;self.t=str(v) if t is None else t
 def constant(self):return self.t.isdecimal()
def generate(out):
 code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:]);digest=hashlib.sha256(code).hexdigest();assert digest==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']; assert json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['methodIdentifiers']['uniqueWords(bytes,bool)']=='b58889b6'
 ins={};p=0
 while p<len(code):
  op=code[p];w=op-95 if 96<=op<=127 else 0;ins[p]=(op,p+1+w,int.from_bytes(code[p+1:p+1+w].ljust(w,b'\0'),'big'));p+=1+w
 dests={p for p,(op,_,_) in ins.items() if op==91}
 specs=[
 ('Mod',23523,6619,'length: Word','|prefix| <= 1000',[E(32),E(160,'length')],'length%32'),
 ('Div32',23562,6735,'length: Word','|prefix| <= 1000',[E(32),E(160,'length')],'length/32'),
 ('Mul32',23581,6756,'index: Word, ret: Word','|prefix| <= 1000 && index < 0x10000000000000000 && ret in {6756,6768}',[E(2,'index'),E(32)],'(index as nat)*32'),
 ('Add',23604,6779,'a: Word, b: Word','|prefix| <= 1000 && (a as nat)+(b as nat) < G.Modulus()',[E(64,'a'),E(32,'b')],'(a as nat)+(b as nat)'),
 ('Slice',23623,6792,'offset: Word, length: Word, start: Word, end: Word','|prefix| <= 1000 && start <= end <= length && (offset as nat)+(end as nat) < G.Modulus()',[E(96,'end'),E(64,'start'),E(160,'length'),E(100,'offset')],'((offset as nat)+(start as nat)),((end as nat)-(start as nat))'),
 ('Read32',23662,6801,'offset: Word','|prefix| <= 1000',[E(32),E(100,'offset')],'DataWord(data,offset)'),
 ('Sub1',23784,3833,'kept: Word','|prefix| <= 1000 && kept > 0',[E(1),E(3,'kept')],'(kept as nat)-1'),
 ('Inc1',23760,6909,'kept: Word','|prefix| <= 1000 && kept < G.Modulus()-1',[E(2,'kept')],'(kept as nat)+1')]


 for name,entry,ret,params,pre,args,result in specs:
  names=[x.strip().split(':')[0] for x in params.split(',')];actual=','.join(names);ret_expr='ret' if 'ret' in names else str(ret);suffix=[E(ret,ret_expr)]+args;s=suffix.copy();pc=entry;states=[];required={};targets=set();seen=set()
  def pop():return s.pop()
  def push(x):s.append(x)
  while pc!=ret:
   assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
   for p in range(pc,nxt):required[p]=code[p]
   states.append({'id':len(states),'pc':pc,'stack':[x.t for x in s],'op':op,'next':nxt,'immediate':imm})
   if op==0x5b:pass
   elif op==0x5f or 96<=op<=127:push(E(imm))
   elif 0x80<=op<=0x8f:push(s[-(op-0x7f)])
   elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
   elif op==0x50:pop()
   elif op in [1,2,3,4,6]:
    a,b=pop(),pop();v={1:lambda:(a.v+b.v)%MOD,2:lambda:(a.v*b.v)%MOD,3:lambda:(a.v-b.v)%MOD,4:lambda:0 if b.v==0 else a.v//b.v,6:lambda:0 if b.v==0 else a.v%b.v}[op]()
    if a.constant() and b.constant():push(E(v));continue
    if op==1:t=f'(({a.t} as nat)+({b.t} as nat))%G.Modulus()'
    elif op==2:t=f'(({a.t} as nat)*({b.t} as nat))%G.Modulus()'
    elif op==3:t=f'(({a.t} as nat)+G.Modulus()-({b.t} as nat))%G.Modulus()'
    else:t=f'(if {b.t} == 0 then 0 else ({a.t} as nat){"/" if op==4 else "%"}({b.t} as nat))'
    push(E(v,t))
   elif op in [0x10,0x11,0x14]:
    a,b=pop(),pop();truth=a.v<b.v if op==0x10 else a.v>b.v if op==0x11 else a.v==b.v;push(E(int(truth)))
   elif op==0x15:push(E(int(pop().v==0)))
   elif op==0x17:a,b=pop(),pop();assert a.constant() and b.constant();push(E(a.v|b.v))
   elif op==0x35:a=pop();assert a.t=='offset';push(E(7,'DataWord(data,offset)'))
   elif op==0x57:
    dest,truth=pop(),pop();assert dest.constant() and dest.v in dests;targets.add(dest.v);required[dest.v]=code[dest.v]
    if truth.v:nxt=dest.v
   elif op==0x56:
    dest=pop();assert dest.v in dests and (dest.constant() or dest.t=='ret');targets.add(dest.v);required[dest.v]=code[dest.v];nxt=dest.v
   else:raise ValueError((name,pc,op))
   pc=nxt
  if name=='Mul32':targets.update({6756,6768})
  if name=='Mul2':targets.update({6185,6219})
  if name=='Div2':targets.update({6051,6079})
  for target in targets:required[target]=code[target]
  matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
  good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},prefix+[{','.join(n['stack'])}],mem)" for n in states)+'\n    else false'
  text=f'''// SPDX-License-Identifier: MIT
// Generated actual current Collections helper instructions; no compiler correctness axiom.
include "../../scans/Execution.dfy"
module BytecodeUniqueHelper{name} {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import E = BytecodeScanExecution
  import G = BytecodeGetterMachine
  predicate Admitted(prefix: seq<Word>, {params}) {{ {pre} }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, {params}, mem: seq<Byte>, data: seq<Byte>) {{
    Admitted(prefix,{actual}) && (
{good})
  }}
'''
  for n in states:
   i=n['id'];post=f'next == Running({ret_expr},prefix+[{result}],mem)' if i==len(states)-1 else f'Good({i+1},next,prefix,{actual},mem,data)';fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
   text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, prefix: seq<Word>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Admitted(prefix,{actual}) && Good({i},state,prefix,{actual},mem,data)
    ensures state.Running? && |state.stack| <= 1010
    ensures Step(code,Destinations(),state,value,data).Running?
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},prefix+[{','.join(n['stack'])}],mem);
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
  initial=','.join(x.t for x in suffix);calls='\n'.join(f'    Advance{i}(code,state,prefix,{actual},mem,value,data);\n    var next{i} := Step(code,Destinations(),state,value,data);\n    E.Extend(code,Destinations(),value,data,trace,next{i});\n    trace := trace+[next{i}];\n    state := next{i};' for i in range(len(states)))
  text+=f'''  lemma Start(prefix: seq<Word>, {params}, mem: seq<Byte>, data: seq<Byte>)
    requires Admitted(prefix,{actual})
    ensures Good(0,Running({entry},prefix+[{initial}],mem),prefix,{actual},mem,data)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, {params}, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State, trace: seq<State>)
    requires Matches(code) && Admitted(prefix,{actual})
    ensures state == Running({ret_expr},prefix+[{result}],mem)
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures |trace| == {len(states)+1} && trace[0] == Running({entry},prefix+[{initial}],mem) && trace[|trace|-1] == state
  {{
    Start(prefix,{actual},mem,data);
    state := Running({entry},prefix+[{initial}],mem);
    trace := [state];
{calls}
  }}
}}
'''
  out.mkdir(parents=True,exist_ok=True);(out/(name+'.generated.dfy')).write_text(text);(out/(name+'.mapping.json')).write_text(json.dumps({'runtimeSha256':digest,'states':states,'requiredBytes':required,'destinations':sorted(targets),'finalStack':[x.t for x in s],'scope':'development admitted actual helper path only; body composition and retained evidence remain open'},indent=2)+'\n');print(name,len(states),'states')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 import subprocess,sys
 subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
